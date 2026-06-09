class KalkulatorRepository {
  String hitung(String input) {
    try {
      final ekspresi = input.trim();
      double result = 0;

      if (ekspresi.contains('+')) {
        final angka = ekspresi.split('+');
        result = double.parse(angka[0]) + double.parse(angka[1]);
      } else if (ekspresi.contains('-')) {
        final angka = ekspresi.split('-');
        result = double.parse(angka[0]) - double.parse(angka[1]);
      } else if (ekspresi.contains('×')) {
        final angka = ekspresi.split('×');
        result = double.parse(angka[0]) * double.parse(angka[1]);
      } else if (ekspresi.contains('÷')) {
        final angka = ekspresi.split('÷');
        result = double.parse(angka[0]) / double.parse(angka[1]);
      }

      return result.toStringAsFixed(0);
    } catch (e) {
      return 'Error';
    }
  }
}
