import 'package:dart_lc3_vm/register.dart';

abstract class MapRegister implements Register {
  final int _mask;
  final Map<int, int> _register = {};

  MapRegister(int bytes) : _mask = (1 << 8 * bytes) - 1;

  @override
  int operator [](int address) => _register[address & _mask] ?? 0;

  @override
  operator []=(int address, int value) {
    _register[address & _mask] = value & _mask;
  }
}
