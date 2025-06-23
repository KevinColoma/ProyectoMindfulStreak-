import 'package:flutter_test/flutter_test.dart';

int calcularEdad(DateTime fechaNacimiento) {
  final hoy = DateTime.now();
  int edad = hoy.year - fechaNacimiento.year;
  if (fechaNacimiento.month > hoy.month ||
      (fechaNacimiento.month == hoy.month && fechaNacimiento.day > hoy.day)) {
    edad--;
  }
  return edad;
}

void main() {
  test('calcularEdad retorna edad correcta', () {
    final nacimiento = DateTime(2000, 6, 9);
    final edad = calcularEdad(nacimiento);
    final ahora = DateTime.now();
    final esperado = ahora.year - 2000 - ((ahora.month < 6 || (ahora.month == 6 && ahora.day < 9)) ? 1 : 0);

    expect(edad, esperado);
  });
}
