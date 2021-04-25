import 'dart:io';

import 'memory/memory.dart';
import 'register/register.dart';

abstract class VM {
  void load(File file);
  void run();
}

class LC3VM implements VM {
  final Register _register;
  final Memory _memory;

  LC3VM(
      Register register,
      Memory memory,
  ) : _register = register, _memory = memory;

  @override
  void load(File file) {
    var data = file.readAsBytesSync();
    var len = (data.length / 2).truncate();
    var origin = (data[0] << 8) + data[1];

    for (var i = 1; i < len; i++) {
      if (2 * i + 1 < data.length) {
        _memory[origin + i - 1] = (data[2 * i] << 8) + data[2 * i + 1];
      } else {
        _memory[origin + i - 1] = (data[2 * i] << 8);
      }
    }
  }

  @override
  void run() {
    // TODO: implement run
  }
}