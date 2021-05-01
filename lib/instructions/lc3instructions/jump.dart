import 'package:dart_lc3_vm/vm.dart';

class Jump implements Instruction {
  final int r;
  final int PCRegisterAddress;

  Jump(this.r, this.PCRegisterAddress);

  @override
  bool call(MemoryReader memoryReader, MemoryWriter memoryWriter, RegisterReader registerReader, RegisterWriter registerWriter) {
    registerWriter.write(PCRegisterAddress, registerReader.read(r));
    return true;
  }
}