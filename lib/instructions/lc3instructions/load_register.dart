import 'package:dart_lc3_vm/vm.dart';

class LoadRegister implements Instruction {
  final int r0, r1, offset;

  LoadRegister(this.r0, this.r1, this.offset);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter
      ) {
    var address = registerReader.read(r1) + offset;
    registerWriter.write(
        r0,
        memoryReader.read(address)
    );
    registerWriter.updateCONDWith(r0);

    return true;
  }
}