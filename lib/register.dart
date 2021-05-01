abstract class Register {
  int operator [](int address);
  operator []=(int address, int value);
}
