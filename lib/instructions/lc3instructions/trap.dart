import 'package:dart_lc3_vm/vm.dart';

class Trap implements Instruction {
  final int trap;

  Trap(this.trap);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    return memoryReader.readAsTrapRoutine(trap)();
  }
}