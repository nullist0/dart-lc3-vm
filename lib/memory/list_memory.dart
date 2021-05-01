import 'package:dart_lc3_vm/memory.dart';

abstract class ListMemory implements Memory {
  final int _mask;
  
  final List<int> _memory;
  
  final Map<int, int Function()> _mappedRegister = {};
  final Map<int, bool Function()> _trapRoutines = {};

  ListMemory(int size, int bytes)
      : _memory = List.filled(size, 0), 
        _mask = (1 << (8 * bytes)) - 1;
  
  @override
  int operator [](int address) {
    address &= _mask;
    if (_mappedRegister.containsKey(address)) {
      return _mappedRegister[address]!();
    }
    return _memory[address];
  }

  @override
  operator []=(int address, int value) {
    _memory[address & _mask] = value & _mask;
  }

  @override
  void addMappedRegister(int address, int Function() read) {
    _mappedRegister[address & _mask] = read;
  }
  
  @override
  void addTrapRoutine(int address, bool Function() routine) {
    _trapRoutines[address & _mask] = routine;
  }
  
  @override
  TrapRoutine readTrapRoutine(int address) {
    address &= _mask;
    var routine = _trapRoutines[address];
    if (routine == null) throw Exception('there is no trap routine at ${address.toRadixString(16)}');
    return routine;
  }
}
