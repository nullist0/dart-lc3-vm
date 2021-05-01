import 'package:dart_lc3_vm/vm.dart';

class StoreIndirect implements Instruction {
  final int r, pcOffset;
  final int PCRegisterAddress;

  StoreIndirect(this.r, this.pcOffset, this.PCRegisterAddress);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    var address = registerReader.read(PCRegisterAddress) + pcOffset;
    memoryWriter.write(
        memoryReader.read(address),
        registerReader.read(r)
    );
    return true;
  }

}