#! /usr/bin/env python

"""
Some of Amanda's textgrid have their marks splited into two lines (i.e., with \n in them). This script find those
and fix them
"""

import argparse
import re

if __name__ == "__main__":

    # command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("textgrid_in", help="TextGrid to be examined")
    parser.add_argument("textgrid_out", help="corrected TextGrid")
    args = parser.parse_args()

    textgrid_in = open(args.textgrid_in, 'r')
    textgrid_out = open(args.textgrid_out, 'w')
    line = textgrid_in.readline()
    while line:
        occurances = [m.start() for m in re.finditer('"', line)]
        if len(occurances) == 2 or len(occurances) == 0:
            textgrid_out.write(line)
        else:
            line = line.rstrip() + textgrid_in.readline()
            textgrid_out.write(line)
        line = textgrid_in.readline()
    textgrid_in.close()
    textgrid_out.close()