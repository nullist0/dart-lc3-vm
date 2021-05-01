import 'package:dart_lc3_vm/vm.dart';

class Not implements Instruction {
  final int r0, r1;

  Not(this.r0, this.r1);

  @override
  bool call(MemoryReader memoryReader, MemoryWriter memoryWriter, RegisterReader registerReader, RegisterWriter registerWriter) {
    registerWriter.write(
        r0,
        ~registerReader.read(r1)
    );
    registerWriter.updateCONDWith(r0);

    return true;
  }
}