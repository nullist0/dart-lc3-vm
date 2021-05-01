import 'package:dart_lc3_vm/vm.dart';

class Add implements Instruction {
  final int r0, r1, imm;

  Add(this.r0, this.r1, this.imm);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    registerWriter.write(
        r0,
        registerReader.read(r1) + imm
    );
    registerWriter.updateCONDWith(r0);
    return true;
  }
}

class AddRegister implements Instruction {
  final int r0, r1, r2;

  AddRegister(this.r0, this.r1, this.r2);

  @override
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter) {
    registerWriter.write(
        r0,
        registerReader.read(r1) + registerReader.read(r2)
    );
    registerWriter.updateCONDWith(r0);

    return true;
  }
}
