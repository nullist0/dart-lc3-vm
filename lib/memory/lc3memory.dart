import 'dart:io';

import 'package:dart_lc3_vm/memory/list_memory.dart';
import 'package:dart_lc3_vm/memory/little_endian.dart';

/// 2 byte word, little endian, list memory.
class LC3Memory extends ListMemory with LittleEndian {
  LC3Memory(int size) : super(size, 2);

  @override
  void loadFile(File file) {
    var byte2list = file
        .readAsBytesSync()
        .buffer
        .asInt16List()
        .map((e) => e & 0xFFFF)
        .toList();

    var address = swap(byte2list[0], 2);
    for (var i = 1; i < byte2list.length; i++) {
      this[address] = swap(byte2list[i], 2);
      address++;
    }
  }
}
