import 'package:dart_lc3_vm/memory.dart';

abstract class MemoryReader {
  int read(int address);

  Instruction readAsInstruction(int address);
  TrapRoutine readAsTrapRoutine(int address);
}

abstract class MemoryWriter {
  void write(int address, int value);
}

abstract class RegisterReader {
  int read(int address);
  int readPC();
}

abstract class RegisterWriter {
  void write(int address, int value);
  void updateCONDWith(int address);
}

abstract class Instruction {
  bool call(
      MemoryReader memoryReader,
      MemoryWriter memoryWriter,
      RegisterReader registerReader,
      RegisterWriter registerWriter
  );
}

typedef OpcodeParser<T> = T Function(int value);
typedef InstructionParser = Instruction Function(int value);

abstract class InstructionRule<T> {
  Instruction get(int value);
  void addRule(T op, InstructionParser parser);
}

abstract class AbstractVirtualMachine {
  void run(int PCRegisterAddress, int startAddress);
}

class VirtualMachine implements AbstractVirtualMachine {
  final MemoryReader memoryReader;
  final MemoryWriter memoryWriter;

  final RegisterReader registerReader;
  final RegisterWriter registerWriter;

  VirtualMachine(this.memoryReader, this.memoryWriter, this.registerReader, this.registerWriter);

  @override
  void run(int PCRegisterAddress, int startAddress) {
    var isRunning = true;
    registerWriter.write(PCRegisterAddress, startAddress);

    while (isRunning) {
      var programCounter = registerReader.readPC();

      var instr = memoryReader.readAsInstruction(programCounter);

      isRunning = instr(
          memoryReader,
          memoryWriter,
          registerReader,
          registerWriter
      );
    }
  }
}
