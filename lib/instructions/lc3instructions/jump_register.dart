import 'package:dart_lc3_vm/vm.dart';

class JumpRegister implements Instruction {
  final int pcOffset, r7, PCRegisterAddress;

  JumpRegister(this.pcOffset, this.r7, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    registerWriter.write(r7, registerReader.read(PCRegisterAddress));
    registerWriter.write(PCRegisterAddress, registerReader.read(PCRegisterAddress) + pcOffset);
    return true;
  }
}

class JumpRegisterR implements Instruction {
  final int r1, r7, PCRegisterAddress;

  JumpRegisterR(this.r1, this.r7, this.PCRegisterAddress);
  @override
  bool call(MemoryReader memoryReader, MemoryWriter memoryWriter, RegisterReader registerReader, RegisterWriter registerWriter) {
    registerWriter.write(r7, registerReader.read(PCRegisterAddress));
    registerWriter.write(PCRegisterAddress, registerReader.read(r1));
    return true;
  }
}