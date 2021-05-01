import 'package:dart_lc3_vm/vm.dart';

class StoreRegister implements Instruction {
  final int r0, r1, offset;

  StoreRegister(this.r0, this.r1, this.offset);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    var address = registerReader.read(r1) + offset;
    memoryWriter.write(
        address,
        registerReader.read(r0)
    );
    return true;
  }

}