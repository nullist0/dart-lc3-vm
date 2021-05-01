import 'package:dart_lc3_vm/vm.dart';

class Branch implements Instruction {
  final int flags;
  final int pcOffset;

  final int CONDRegisterAddress;
  final int PCRegisterAddress;

  Branch(this.flags, this.pcOffset, this.CONDRegisterAddress, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter
  ) {
    if (flags & registerReader.read(CONDRegisterAddress) > 0) {
      registerWriter.write(
          PCRegisterAddress,
          registerReader.read(PCRegisterAddress) + pcOffset
      );
    }
    return true;
  }
}