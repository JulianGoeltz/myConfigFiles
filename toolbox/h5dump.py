#!/usr/bin/env python
"""
e.g. with
    run_nmpm_software $(which h5dump.py) master_grad0_20190626-135749_W37.hdf5 input/git-sha input/nmpm_module input/git-diff
"""

import argparse
import h5py
import os
import os.path as osp
import sys

parser = argparse.ArgumentParser(description='different h5dumping')
parser.add_argument('file')
parser.add_argument('paths', default=-1, nargs='*')
args = parser.parse_args()

filename = args.file
if isinstance(args.paths, list):
    iterator = args.paths
else:
    iterator = ['input/yaml_pure']

if osp.isfile(filename) and osp.splitext(filename)[1] == '.hdf5':
    with h5py.File(filename) as hf:
        for path in iterator:
            if len(iterator) > 1:
                print(path)

            print(hf[path][()])
