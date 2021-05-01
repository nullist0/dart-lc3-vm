import 'package:dart_lc3_vm/vm.dart';

extension BitOperation on int {
  int signExtend(int signBitPosition, int byte) {
    var x = this;
    var mask = (1 << (8 * byte)) - 1;
    if ((x >> (signBitPosition - 1)) & 1 == 1) {
      x |= (mask << signBitPosition);
    }
    return x;
  }
}

class MapInstructionRule<Opcode> implements InstructionRule<Opcode> {
  final OpcodeParser<Opcode> _opcodeParser;
  final Map<Opcode, InstructionParser> _rules = {};

  MapInstructionRule(OpcodeParser<Opcode> parser): _opcodeParser = parser;

  @override
  Instruction get(int value) {
    var rule = _rules[_opcodeParser(value)];
    if (rule == null) throw Exception('there is no rule for the opcode ${_opcodeParser(value)} with the value $value');
    return rule(value);
  }

  @override
  void addRule(Opcode op, InstructionParser parser) {
    _rules[op] = parser;
  }
}