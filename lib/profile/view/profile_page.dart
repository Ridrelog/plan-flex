import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/profile_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = ProfileRepository();
  final TextEditingController _nameController = TextEditingController();

  bool _isSavingName = false;
  bool _isProcessingPhoto = false;

  static const Color _primary = Color(0xFF235347);
  static const Color _secondary = Color(0xFF8EB69B);
  static const Color _background = Color(0xFFF4FBF6);
  static const Color _darkText = Color(0xFF051F20);
  static const Color _borderColor = Color(0xFFD7E8DC);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editName(String currentName) async {
    _nameController.text = currentName;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Edit Nama',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Nama pengguna',
              prefixIcon: const Icon(Icons.person_rounded),
              filled: true,
              fillColor: const Color(0xFFF6FAF7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => Navigator.pop(context, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context, _nameController.text.trim()),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    if (result.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() => _isSavingName = true);
    try {
      await _repository.updateProfileName(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _showPhotoOptions(String? currentPhotoPath) async {
    if (_isProcessingPhoto) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Foto Profile',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _PhotoOptionButton(
                        icon: Icons.photo_library_rounded,
                        title: 'Galeri',
                        onTap: () {
                          Navigator.pop(context);
                          _pickPhoto(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PhotoOptionButton(
                        icon: Icons.camera_alt_rounded,
                        title: 'Kamera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickPhoto(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (currentPhotoPath != null && currentPhotoPath.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removePhoto(currentPhotoPath);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _isProcessingPhoto = true);
    try {
      final path = await _repository.pickAndSaveProfilePhoto(source);
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profile berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPhoto = false);
    }
  }

  Future<void> _removePhoto(String? currentPhotoPath) async {
    setState(() => _isProcessingPhoto = true);
    try {
      await _repository.removeProfilePhoto(currentPhotoPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profile berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPhoto = false);
    }
  }

  Future<void> _sendResetPassword() async {
    try {
      await _repository.sendResetPasswordEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link reset password sudah dikirim ke email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim reset password: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    await _repository.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User belum login'),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _repository.profileStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final firebaseName = user.displayName?.trim();
        final firestoreName = data?['name']?.toString().trim();
        final name = (firebaseName != null && firebaseName.isNotEmpty)
            ? firebaseName
            : (firestoreName != null && firestoreName.isNotEmpty)
                ? firestoreName
                : 'Plan Flex User';
        final email = user.email ?? data?['email']?.toString() ?? 'Tidak ada email';
        final uid = user.uid;
        final photoPath = data?['photoPath']?.toString();
        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';
        final hasLocalPhoto = photoPath != null && photoPath.trim().isNotEmpty && File(photoPath).existsSync();

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHero(
                    name: name,
                    email: email,
                    firstLetter: firstLetter,
                    photoPath: hasLocalPhoto ? photoPath : null,
                    isSavingName: _isSavingName,
                    isProcessingPhoto: _isProcessingPhoto,
                    onEditName: () => _editName(name),
                    onChangePhoto: () => _showPhotoOptions(photoPath),
                  ),
                  const SizedBox(height: 20),
                  _InfoCard(
                    title: 'Informasi Akun',
                    children: [
                      _InfoTile(
                        icon: Icons.badge_rounded,
                        title: 'Nama',
                        value: name,
                      ),
                      _InfoTile(
                        icon: Icons.email_rounded,
                        title: 'Email',
                        value: email,
                      ),
                      _InfoTile(
                        icon: Icons.key_rounded,
                        title: 'User ID',
                        value: uid,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    icon: Icons.lock_reset_rounded,
                    title: 'Reset Password',
                    subtitle: 'Kirim link reset password ke email akun ini',
                    onTap: _sendResetPassword,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun Plan-Flex',
                    isDanger: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: _primary,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String email;
  final String firstLetter;
  final String? photoPath;
  final bool isSavingName;
  final bool isProcessingPhoto;
  final VoidCallback onEditName;
  final VoidCallback onChangePhoto;

  const _ProfileHero({
    required this.name,
    required this.email,
    required this.firstLetter,
    required this.photoPath,
    required this.isSavingName,
    required this.isProcessingPhoto,
    required this.onEditName,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF235347), Color(0xFF5F937D), Color(0xFFA9CFBB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF235347).withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                  child: photoPath == null
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Color(0xFF235347),
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isProcessingPhoto ? null : onChangePhoto,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF235347).withOpacity(0.15)),
                      ),
                      child: isProcessingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF235347)),
                            )
                          : const Icon(Icons.camera_alt_rounded, color: Color(0xFF235347), size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _HeroButton(
                icon: Icons.edit_rounded,
                label: 'Edit Nama',
                isLoading: isSavingName,
                onTap: isSavingName ? null : onEditName,
              ),
              _HeroButton(
                icon: Icons.photo_camera_back_rounded,
                label: 'Ganti Foto',
                isLoading: false,
                onTap: isProcessingPhoto ? null : onChangePhoto,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _HeroButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF235347)),
                )
              else
                Icon(icon, color: const Color(0xFF235347), size: 19),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF235347),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _ProfilePageState._borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              color: _ProfilePageState._darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F2E9),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: const Color(0xFF235347), size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.blueGrey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ProfilePageState._darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDanger;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red.shade600 : const Color(0xFF235347);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _ProfilePageState._borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDanger ? Colors.red.shade50 : const Color(0xFFE5F2E9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4FBF6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF235347), size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _ProfilePageState._darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
