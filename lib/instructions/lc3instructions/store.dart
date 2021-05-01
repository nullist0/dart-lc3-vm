import 'package:dart_lc3_vm/vm.dart';

class Store implements Instruction {
  final int r0, pcOffset;
  final int PCRegisterAddress;

  Store(this.r0, this.pcOffset, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    var address = registerReader.read(PCRegisterAddress) + pcOffset;
    memoryWriter.write(
        address,
        registerReader.read(r0)
    );
    return true;
  }
}