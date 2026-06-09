import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProfileRepository {
  ProfileRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ImagePicker? imagePicker,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _imagePicker = imagePicker ?? ImagePicker();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ImagePicker _imagePicker;

  User? get currentUser => _firebaseAuth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    _ensureUserDocument(user);
    return _userDoc(user.uid).snapshots();
  }

  Future<void> _ensureUserDocument(User user) async {
    try {
      await _userDoc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'Plan Flex User',
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Jangan matikan halaman profile hanya karena sinkron Firestore gagal.
    }
  }

  Future<void> updateProfileName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    await user.updateDisplayName(cleanName);
    await _userDoc(user.uid).set({
      'uid': user.uid,
      'name': cleanName,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> pickAndSaveProfilePhoto(ImageSource source) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (pickedFile == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(p.join(appDir.path, 'profile_photos'));
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final extension = p.extension(pickedFile.path).isEmpty ? '.jpg' : p.extension(pickedFile.path);
    final savedPath = p.join(
      profileDir.path,
      '${user.uid}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );

    final savedFile = await File(pickedFile.path).copy(savedPath);

    await _userDoc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'photoPath': savedFile.path,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return savedFile.path;
  }

  Future<void> removeProfilePhoto(String? oldPath) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    if (oldPath != null && oldPath.trim().isNotEmpty) {
      try {
        final file = File(oldPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Gagal menghapus foto lokal: $e');
      }
    }

    await _userDoc(user.uid).set({
      'photoPath': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendResetPasswordEmail() async {
    final email = _firebaseAuth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw Exception('Email akun tidak ditemukan');
    }

    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
