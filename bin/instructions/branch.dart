import '../memory/memory.dart';
import '../register/register.dart';

class Branch implements Instruction {
  final int instruction;

  Branch(this.instruction);

  @override void call(Register register, Memory memory) {
    var nzp = (instruction >> 9) & 0x7;
    // var pc_offset = sign_extend(instr & 0x1FF, 9);
    // if (nzp & register[RegisterValue.R_COND] > 0) {
    //   register[RegisterValue.R_PC] += pc_offset;
    //   register[RegisterValue.R_PC] &= 0xFFFF;
    // }
  }
}
