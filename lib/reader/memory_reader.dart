import 'package:dart_lc3_vm/memory.dart';
import 'package:dart_lc3_vm/vm.dart';

class LC3MemoryReader implements MemoryReader {
  final Memory memory;
  final InstructionRule parser;

  LC3MemoryReader(this.memory, this.parser);

  @override
  int read(int address) => memory[address];

  @override
  Instruction readAsInstruction(int address) {
    return parser.get(memory[address]);
  }

  @override
  TrapRoutine readAsTrapRoutine(int address) => memory.readTrapRoutine(address);
}