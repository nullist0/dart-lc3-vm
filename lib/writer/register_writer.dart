import 'package:dart_lc3_vm/register.dart';
import 'package:dart_lc3_vm/vm.dart';

class LC3RegisterWriter implements RegisterWriter {
  final Register register;
  final void Function(int) update;

  LC3RegisterWriter(this.register, this.update);

  @override
  void write(int address, int value) => register[address] = value;

  @override
  void updateCONDWith(int address) => update(address);
}