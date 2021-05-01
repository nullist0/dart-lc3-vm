import 'dart:io';

const MEMORY_SIZE = 1 << 16;
var memory = List.filled(MEMORY_SIZE, 0);

enum RegisterAddress {
  R_R0,
  R_R1,
  R_R2,
  R_R3,
  R_R4,
  R_R5,
  R_R6,
  R_R7,
  R_PC,
  R_COND,
  R_COUNT,
}

enum Opcode {
  OP_BR,     /* branch */
  OP_ADD,    /* add  */
  OP_LD,     /* load */
  OP_ST,     /* store */
  OP_JSR,    /* jump register */
  OP_AND,    /* bitwise and */
  OP_LDR,    /* load register */
  OP_STR,    /* store register */
  OP_RTI,    /* unused */
  OP_NOT,    /* bitwise not */
  OP_LDI,    /* load indirect */
  OP_STI,    /* store indirect */
  OP_JMP,    /* jump */
  OP_RES,    /* reserved (unused) */
  OP_LEA,    /* load effective address */
  OP_TRAP    /* execute trap */
}

enum ConditionFlags {
  FL_POS, /* P */
  FL_ZRO, /* Z */
  FL_NEG, /* N */
}

extension Condition on ConditionFlags {
  int value() {
    switch (this) {
      case ConditionFlags.FL_POS:
        return 1 << 0;
      case ConditionFlags.FL_ZRO:
        return 1 << 1;
      case ConditionFlags.FL_NEG:
        return 1 << 2;
    }
  }
}

enum Trap {
  TRAP_GETC,
  TRAP_OUT,
  TRAP_PUTS,
  TRAP_IN,
  TRAP_PUTSP,
  TRAP_HALT,
  TRAP_NONE
}

extension TrapConverter on Trap {
  static Trap from(int x) {
    switch(x) {
      case 0x20:
        return Trap.TRAP_GETC;
      case 0x21:
        return Trap.TRAP_OUT;
      case 0x22:
        return Trap.TRAP_PUTS;
      case 0x23:
        return Trap.TRAP_IN;
      case 0x24:
        return Trap.TRAP_PUTSP;
      case 0x25:
        return Trap.TRAP_HALT;
    }
    return Trap.TRAP_NONE;
  }
}

enum MemoryMappedRegister {
  MR_KBSR, // keyboard status 0xFE00
  MR_KBDR  // keyboard data 0xFE02
}

const PC_START = 0x3000;
var register = <RegisterAddress, int>{}..addAll(RegisterAddress.values.asMap().map((key, value) => MapEntry(value, key)));

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('lc3 [image-file1] ...');
    exit(2);
  }

  for (var arg in arguments) {
    try {
      read_image(arg);
    } catch (e) {
      print(e);
      exit(1);
    }
  }

  register[RegisterAddress.R_PC] = PC_START;

  // stdin.lineMode = false;

  var isRunning = true;

  while (isRunning) {
    var pc = register[RegisterAddress.R_PC]!;
    register[RegisterAddress.R_PC] = pc + 1;
    var instr = mem_read(pc);
    var op = Opcode.values[instr >> 12];

    print('$op ${instr.toRadixString(2).padLeft(16, '0')}');

    switch (op) {
      case Opcode.OP_BR:
        {
          var nzp = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);
          if (nzp & register[RegisterAddress.R_COND]! > 0) {
            register[RegisterAddress.R_PC] = register[RegisterAddress.R_PC]! + pc_offset;
            register[RegisterAddress.R_PC] = register[RegisterAddress.R_PC]! & 0xFFFF;
          }
        }
        break;
      case Opcode.OP_ADD:
        {
          var r0 = (instr >> 9) & 0x7;
          var r1 = (instr >> 6) & 0x7;
          var imm_flag = (instr >> 5) & 0x1;

          if (imm_flag == 1) {
            var imm5 = sign_extend(instr & 0x1F, 5);
            register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r1]]! + imm5;
          } else {
            var r2 = instr & 0x7;
            register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r1]]! + register[RegisterAddress.values[r2]]!;
          }

          register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r0]]! & 0xFFFF;

          update_flags(r0);
        }
        break;
      case Opcode.OP_LD:
        {
          var r0 = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);
          var address = register[RegisterAddress.R_PC]! + pc_offset;
          address &= 0xFFFF;

          register[RegisterAddress.values[r0]] = mem_read(address);
          update_flags(r0);
        }
        break;
      case Opcode.OP_ST:
        {
          var r0 = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);
          var address = register[RegisterAddress.R_PC]! + pc_offset;
          address &= 0xFFFF;

          mem_write(address, register[RegisterAddress.values[r0]]!);
        }
        break;
      case Opcode.OP_JSR:
        {
          var pc_flag = (instr >> 11) & 0x1;
          register[RegisterAddress.R_R7] = register[RegisterAddress.R_PC]!;

          if (pc_flag == 1) {
            var pc_offset = sign_extend(instr & 0x7FF, 11);
            register[RegisterAddress.R_PC] = register[RegisterAddress.R_PC]! + pc_offset;
            register[RegisterAddress.R_PC] = register[RegisterAddress.R_PC]! & 0xFFFF;
          } else {
            var r = (instr >> 6) & 0x7;
            register[RegisterAddress.R_PC] = register[RegisterAddress.values[r]]!;
          }
        }
        break;
      case Opcode.OP_AND:
        {
          var r0 = (instr >> 9) & 0x7;
          var r1 = (instr >> 6) & 0x7;
          var imm_flag = (instr >> 5) & 0x1;

          if (imm_flag == 1) {
            var imm5 = sign_extend(instr & 0x1F, 5);
            register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r1]]! & imm5;
          } else {
            var r2 = instr & 0x7;
            register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r1]]! & register[RegisterAddress.values[r2]]!;
          }

          update_flags(r0);
        }
        break;
      case Opcode.OP_LDR:
        {
          var r0 = (instr >> 9) & 0x7;
          var r1 = (instr >> 6) & 0x7;
          var offset = sign_extend(instr & 0x3F, 6);
          var address = register[RegisterAddress.values[r1]]! + offset;
          address &= 0xFFFF;

          register[RegisterAddress.values[r0]] = mem_read(address);
          update_flags(r0);
        }
        break;
      case Opcode.OP_STR:
        {
          var r0 = (instr >> 9) & 0x7;
          var r1 = (instr >> 6) & 0x7;
          var offset = sign_extend(instr & 0x3F, 6);

          var address = register[RegisterAddress.values[r1]]! + offset;
          address &= 0xFFFF;

          mem_write(
              address,
              register[RegisterAddress.values[r0]]!
          );
        }
        break;
      case Opcode.OP_NOT:
        {
          var r0 = (instr >> 9) & 0x7;
          var r1 = (instr >> 6) & 0x7;

          register[RegisterAddress.values[r0]] = (~register[RegisterAddress.values[r1]]! & 0xFFFF);
          update_flags(r0);
        }
        break;
      case Opcode.OP_LDI:
        {
          var r0 = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);
          var address = register[RegisterAddress.R_PC]! + pc_offset;
          address &= 0xFFFF;

          register[RegisterAddress.values[r0]] = mem_read(mem_read(address));
          update_flags(r0);
        }
        break;
      case Opcode.OP_STI:
        {
          var r = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);
          var address = register[RegisterAddress.R_PC]! + pc_offset;
          address &= 0xFFFF;

          mem_write(
              mem_read(address),
              register[RegisterAddress.values[r]]!
          );
        }
        break;
      case Opcode.OP_JMP:
        {
          var r = (instr >> 6) & 0x7;
          register[RegisterAddress.R_PC] = register[RegisterAddress.values[r]]!;
        }
        break;
      case Opcode.OP_LEA:
        {
          var r0 = (instr >> 9) & 0x7;
          var pc_offset = sign_extend(instr & 0x1FF, 9);

          register[RegisterAddress.values[r0]] = register[RegisterAddress.R_PC]! + pc_offset;
          register[RegisterAddress.values[r0]] = register[RegisterAddress.values[r0]]! & 0xFFFF;
          update_flags(r0);
        }
        break;
      case Opcode.OP_TRAP:
        {
          var trap = TrapConverter.from(instr & 0xFF);
          switch (trap) {
            case Trap.TRAP_GETC:
              {
                register[RegisterAddress.R_R0] = stdin.readByteSync();
              }
              break;
            case Trap.TRAP_OUT:
              {
                stdout.write(String.fromCharCode(register[RegisterAddress.R_R0]! & 0x7F));
              }
              break;
            case Trap.TRAP_PUTS:
              {
                var offset = register[RegisterAddress.R_R0]!;
                var char = mem_read(offset++) & 0x7F;

                while (char != 0x0000) {
                  stdout.write(String.fromCharCode(char));
                  char = mem_read(offset++) & 0x7F;
                }
              }
              break;
            case Trap.TRAP_IN:
              {
                print('Enter a character: ');
                var char = stdin.readByteSync();
                stdout.write(String.fromCharCode(char));
                register[RegisterAddress.R_R0] = char;
              }
              break;
            case Trap.TRAP_PUTSP:
              {
                var offset = register[RegisterAddress.R_R0]!;
                var val = mem_read(offset++);

                while (val != 0) {
                  stdout.write((val & 0xFF).toRadixString(16));
                  stdout.write(((val >> 8) % 0x7F).toRadixString(16));

                  val = mem_read(offset++);
                }
              }
              break;
            case Trap.TRAP_HALT:
              print('HALT');
              isRunning = false;
              break;
            case Trap.TRAP_NONE:
              break;
          }
        }
        break;
      case Opcode.OP_RES:
      case Opcode.OP_RTI:
      default:
        break;
    }
  }
}

void read_image(String path) {
  var file = File(path);
  if (!(file.existsSync())) throw FileSystemException("file doesn't exist", path);
  read_image_file(file);
}

void read_image_file(File file) {
  var data = file.readAsBytesSync();
  var len = (data.length / 2).truncate();
  var origin = (data[0] << 8) + data[1];

  for (var i = 1; i < len; i++) {
    if (2 * i + 1 < data.length) {
      memory[origin + i - 1] = (data[2 * i] << 8) + data[2 * i + 1];
      // memory[origin + i - 1] = (data[2 * i + 1] << 8) + data[2 * i];
    } else {
      memory[origin + i - 1] = (data[2 * i] << 8);
      // memory[origin + i - 1] = data[2 * i];
    }
  }
}

int swap16(int x) {
  return (x << 8) | (x >> 8);
}

int mem_read(int address) {
  if (address == 0xFE00) {
    // if (check_key()) {
    memory[0xFE00] = (1 << 15);
    memory[0xFE02] = stdin.readByteSync();
    // } else {
    //   memory[0xFE00] = 0;
    // }
  }
  return memory[address];
}

void mem_write(int address, int value) {
  memory[address] = value;
}

int sign_extend(int x, int bit_count) {
  if ((x >> (bit_count - 1)) & 1 == 1) {
    x |= (0xFFFF << bit_count);
  }
  return x;
}

void update_flags(int r) {
  if(register[RegisterAddress.values[r]] == 0) {
    register[RegisterAddress.R_COND] = ConditionFlags.FL_ZRO.value();
  } else if (register[RegisterAddress.values[r]]! >> 15 == 1) {
    register[RegisterAddress.R_COND] = ConditionFlags.FL_NEG.value();
  } else {
    register[RegisterAddress.R_COND] = ConditionFlags.FL_POS.value();
  }
}