#!/usr/bin/env python3
"""
hex2mem.py — convert objcopy verilog byte hex to $readmemh 32-bit word hex
ARM little-endian: byte[0]=bits[7:0], byte[3]=bits[31:24]
"""
import sys

def convert(infile, outfile):
    byte_map = {}
    cur_addr = 0
    with open(infile) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('@'):
                cur_addr = int(line[1:], 16)
            else:
                for b in line.split():
                    byte_map[cur_addr] = int(b, 16)
                    cur_addr += 1

    if not byte_map:
        print("ERROR: empty hex file", file=sys.stderr)
        sys.exit(1)

    max_byte = max(byte_map.keys())
    num_words = (max_byte // 4) + 1

    with open(outfile, 'w') as f:
        f.write('@00000000\n')
        for i in range(num_words):
            ba = i * 4
            b0 = byte_map.get(ba,   0)  # [7:0]
            b1 = byte_map.get(ba+1, 0)  # [15:8]
            b2 = byte_map.get(ba+2, 0)  # [23:16]
            b3 = byte_map.get(ba+3, 0)  # [31:24]
            word = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0
            f.write(f'{word:08X}\n')

if __name__ == '__main__':
    convert(sys.argv[1], sys.argv[2])
