#!/usr/bin/env python
import os
os.system('nasm -f bin -o print.bin -l print.lst print.asm')
print(open('print.lst','r').read())
x=1
for c in open('print.bin','rb').read():
    print('0x%02X, '%c, end='' if x % 16 else '\n')
    x+=1
