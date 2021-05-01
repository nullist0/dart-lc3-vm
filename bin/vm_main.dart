import 'dart:io';

import 'package:dart_lc3_vm/instructions/lc3instructions/add.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/and.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/branch.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/jump.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/jump_register.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/load.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/load_effetive_address.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/load_indirect.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/load_register.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/not.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/store.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/store_indirect.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/store_register.dart';
import 'package:dart_lc3_vm/instructions/lc3instructions/trap.dart';
import 'package:dart_lc3_vm/instructions/map_instruction_rule.dart';
import 'package:dart_lc3_vm/memory.dart';
import 'package:dart_lc3_vm/memory/lc3memory.dart';
import 'package:dart_lc3_vm/reader/memory_reader.dart';
import 'package:dart_lc3_vm/reader/register_reader.dart';
import 'package:dart_lc3_vm/register.dart';
import 'package:dart_lc3_vm/register/lc3register.dart';
import 'package:dart_lc3_vm/vm.dart';
import 'package:dart_lc3_vm/writer/memory_writer.dart';
import 'package:dart_lc3_vm/writer/register_writer.dart';
enum Registers {
  R0,
  R1,
  R2,
  R3,
  R4,
  R5,
  R6,
  R7,
  PC,
  COND,
  COUNT,
}
extension RegisterAddress on Registers {
  int get address => index;
}

enum Opcode {
  Branch,     /* branch */
  Add,    /* add  */
  Load,     /* load */
  Store,     /* store */
  JumpRegister,    /* jump register */
  And,    /* bitwise and */
  LoadRegister,    /* load register */
  StoreRegister,    /* store register */
  ReturnFromInterrupt,    /* ReTurn from Interrupt (unused) */
  Not,    /* bitwise not */
  LoadIndirect,    /* load indirect */
  StoreIndirect,    /* store indirect */
  Jump,    /* jump */
  Reserved,    /* reserved (unused) */
  LoadEffectiveAddress,    /* load effective address */
  Trap    /* execute trap */
}

enum ConditionFlags {
  Positive, /* P */
  Zero, /* Z */
  Negative, /* N */
}

extension ConditionValue on ConditionFlags {
  int get value {
    switch (this) {
      case ConditionFlags.Positive:
        return 1 << 0;
      case ConditionFlags.Zero:
        return 1 << 1;
      case ConditionFlags.Negative:
        return 1 << 2;
    }
  }
}

enum Traps {
  GetChar,
  Out,
  Puts,
  In,
  PutsPrint,
  Halt
}

extension TrapAddress on Traps {
  int get address => index + 0x20;
}

enum MemoryMappedRegister {
  KeyboardStatus, // keyboard status 0xFE00
  KeyboardData  // keyboard data 0xFE02
}

extension MemoryMappedRegisterAddress on MemoryMappedRegister {
  int get address {
    switch(this) {
      case MemoryMappedRegister.KeyboardStatus: return 0xFE00;
      case MemoryMappedRegister.KeyboardData: return 0xFE02;
    }
  }
}

const PC_START = 0x3000;

extension UpdateRegister on Register {
  void update(int r) {
    if(this[r] == 0) {
      this[Registers.COND.address] = ConditionFlags.Zero.value;
    } else if (this[r] >> 15 == 1) {
      this[Registers.COND.address] = ConditionFlags.Negative.value;
    } else {
      this[Registers.COND.address] = ConditionFlags.Positive.value;
    }
  }
}

void initIO() {
  stdin.lineMode = false;
}

void initMemory(Memory memory, Register register) {
  memory.addMappedRegister(MemoryMappedRegister.KeyboardStatus.address, () {
    memory[MemoryMappedRegister.KeyboardStatus.address] = (1 << 15);
    memory[MemoryMappedRegister.KeyboardData.address] = stdin.readByteSync();
    return 1 << 15;
  });

  memory
    ..addTrapRoutine(Traps.GetChar.address, () {
      register[Registers.R0.address] = stdin.readByteSync();
      return true;
    })
    ..addTrapRoutine(Traps.Out.address, () {
      stdout.write(String.fromCharCode(register[Registers.R0.address] & 0x7F));
      return true;
    })
    ..addTrapRoutine(Traps.Puts.address, () {
      var offset = register[Registers.R0.address];
      var char = memory[offset++] & 0x7F;

      while (char != 0x0000) {
        stdout.write(String.fromCharCode(char));
        char = memory[offset++] & 0x7F;
      }
      return true;
    })
    ..addTrapRoutine(Traps.In.address, () {
      print('Enter a character: ');
      var char = stdin.readByteSync();
      stdout.write(String.fromCharCode(char));
      register[Registers.R0.address] = char;
      return true;
    })
    ..addTrapRoutine(Traps.PutsPrint.address, () {
      var offset = register[Registers.R0.address];
      var val = memory[offset++];

      while (val != 0) {
        stdout.write((val & 0xFF).toRadixString(16));
        stdout.write(((val >> 8) & 0x7F).toRadixString(16));

        val = memory[offset++];
      }
      return true;
    })
    ..addTrapRoutine(Traps.Halt.address, () {
      print('HALT');
      return false;
    });
}

void initRule(InstructionRule<Opcode> rule) {
  rule
    ..addRule(Opcode.Branch, (x) => Branch((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.COND.address, Registers.PC.address))
    ..addRule(Opcode.Add,
            (x) => ((x >> 5) & 0x1) == 1
            ? Add((x >> 9) & 0x7, (x >> 6) & 0x7, (x & 0x1F).signExtend(5, 2))
            : AddRegister((x >> 9) & 0x7, (x >> 6) & 0x7, x & 0x7))
    ..addRule(Opcode.Load, (x) => Load((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.PC.address))
    ..addRule(Opcode.Store, (x) => Store((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.PC.address))
    ..addRule(Opcode.JumpRegister, (x) => ((x >> 11) & 0x1) == 1
        ? JumpRegister((x & 0x7FF).signExtend(11, 2), Registers.R7.address, Registers.PC.address)
        : JumpRegisterR((x >> 6) & 0x7, Registers.R7.address, Registers.PC.address))
    ..addRule(Opcode.And,
            (x) => ((x >> 5) & 0x1) == 1
            ? And((x >> 9) & 0x7, (x >> 6) & 0x7, (x & 0x1F).signExtend(5, 2))
            : AndRegister((x >> 9) & 0x7, (x >> 6) & 0x7, x & 0x7))
    ..addRule(Opcode.LoadRegister, (x) => LoadRegister((x >> 9) & 0x7, (x >> 6) & 0x7, (x & 0x3F).signExtend(6, 2)))
    ..addRule(Opcode.StoreRegister, (x) => StoreRegister((x >> 9) & 0x7, (x >> 6) & 0x7, (x & 0x3F).signExtend(6, 2)))
    ..addRule(Opcode.Not, (x) => Not((x >> 9) & 0x7, (x >> 6) & 0x7))
    ..addRule(Opcode.LoadIndirect, (x) => LoadIndirect((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.PC.address))
    ..addRule(Opcode.StoreIndirect, (x) => StoreIndirect((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.PC.address))
    ..addRule(Opcode.Jump, (x) => Jump((x >> 6) & 0x7, Registers.PC.address))
    ..addRule(Opcode.LoadEffectiveAddress, (x) => LoadEffectiveAddress((x >> 9) & 0x7, (x & 0x1FF).signExtend(9, 2), Registers.PC.address))
    ..addRule(Opcode.Trap, (x) => Trap(x & 0xFF));
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('lc3 [image-file1] ...');
    exit(2);
  }

  Memory memory = LC3Memory(1 << 16);
  Register register = LC3Register();
  InstructionRule<Opcode> lc3rule = MapInstructionRule((int x) => Opcode.values[x >> 12]);

  for(var filenames in arguments) {
    memory.loadFile(File(filenames));
  }

  initIO();
  initMemory(memory, register);
  initRule(lc3rule);

  MemoryReader memoryReader = LC3MemoryReader(memory, lc3rule);
  MemoryWriter memoryWriter = LC3MemoryWriter(memory);
  RegisterReader registerReader = LC3RegisterReader(register, Registers.PC.address);
  RegisterWriter registerWriter = LC3RegisterWriter(register, register.update);

  AbstractVirtualMachine vm = VirtualMachine(memoryReader, memoryWriter, registerReader, registerWriter);

  vm.run(Registers.PC.address, PC_START);
}
