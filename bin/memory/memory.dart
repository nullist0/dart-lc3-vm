import 'dart:io';

import '../register/register.dart';

abstract class Instruction {
  void call(Register register, Memory memory);
}

abstract class Memory {
  operator []=(int address, int value);
  int operator [](int address);
}
