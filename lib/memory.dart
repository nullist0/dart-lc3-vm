import 'dart:io';

typedef TrapRoutine = bool Function();

abstract class Memory {
  int operator [](int address);
  operator []=(int address, int value);

  void loadFile(File file);

  void addMappedRegister(int address, int Function() read);
  void addTrapRoutine(int address, TrapRoutine routine);
  
  TrapRoutine readTrapRoutine(int address);
}
