import 'package:dart_lc3_vm/memory.dart';

mixin LittleEndian implements Memory {
  int swap(int x, int byte) {
    return (x << (4 * byte)) | (x >> (4 * byte));
  }
}