import 'package:dart_lc3_vm/vm.dart';

class Load implements Instruction {
  final int r0, pcOffset;
  final int PCRegisterAddress;

  Load(this.r0, this.pcOffset, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter
  ) {
    var address = registerReader.read(PCRegisterAddress) + pcOffset;
    registerWriter.write(
      r0,
      memoryReader.read(address)
    );
    registerWriter.updateCONDWith(r0);

    return true;
  }
}