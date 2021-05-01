import 'package:dart_lc3_vm/memory.dart';
import 'package:dart_lc3_vm/vm.dart';

class LC3MemoryWriter implements MemoryWriter {
  final Memory memory;

  LC3MemoryWriter(this.memory);

  @override
  void write(int address, int value) => memory[address] = value;
}
