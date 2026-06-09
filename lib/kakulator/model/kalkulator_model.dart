class KalkulatorModel {
  final String input;
  final String hasil;

  const KalkulatorModel({
    required this.input,
    required this.hasil,
  });

  KalkulatorModel copyWith({
    String? input,
    String? hasil,
  }) {
    return KalkulatorModel(
      input: input ?? this.input,
      hasil: hasil ?? this.hasil,
    );
  }
}
