import 'package:dart_lc3_vm/register.dart';
import 'package:dart_lc3_vm/vm.dart';

class LC3RegisterReader implements RegisterReader {
  final Register register;
  final int PCRegisterAddress;

  LC3RegisterReader(this.register, this.PCRegisterAddress);

  @override
  int read(int address) => register[address];

  @override
  int readPC() => register[PCRegisterAddress]++;
}