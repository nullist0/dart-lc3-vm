# Dart LC3 Implementation
This is the implementation of lc3 using Dart.
The reference is the article [Write your Own Virtual Machine](https://justinmeiners.github.io/lc3-vm/).

# Implementations
There are two implementations of LC3VM.
1. bin/main.dart: Simple straight forward implementation of the article.
2. bin/vm_main.dart & lib/*.dart: Implementation applying some architecture.

# Usage

To build, follow these commands.
```shell
git clone https://github.com/out-of-existence/dart-lc3-vm.git
cd dart-lc3-vm
dart compile exe ./bin/vm_main.dart -o ./bin/lc3-vm
```

To run 2048 game, follow this command.
```shell
./bin/lc3-vm ./obj/2048.obj
```

To run a simple rogue-like game, follow this command.
```shell
./bin/lc3-vm ./obj/rogue.obj
```

# License

```text
MIT License

Copyright (c) 2021 Lee PyeongWon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```