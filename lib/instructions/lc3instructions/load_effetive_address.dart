import 'package:dart_lc3_vm/vm.dart';

class LoadEffectiveAddress implements Instruction {
  final int r0, pcOffset;
  final int PCRegisterAddress;

  LoadEffectiveAddress(this.r0, this.pcOffset, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    registerWriter.write(r0, registerReader.read(PCRegisterAddress) + pcOffset);
    registerWriter.updateCONDWith(r0);

    return true;
  }
}