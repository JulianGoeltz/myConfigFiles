#!/usr/bin/env python2
# encoding: utf-8
# program by Oliver Breitwieser https://github.com/obreitwi
from __future__ import print_function

import sys
import itertools as it
from docopt import docopt
import re
import os.path as osp
from pprint import pprint

__doc__ = \
"""
Usage:
    {prgm} [-v] [-R] [-f KEY]... [-l KEY]... [-r KEY]... FILENAME...
    {prgm} -h | --help
    {prgm} --version

    Receives a bunch of FILENAMEs and sorts them according to the numbers
    contained in key-number pairs in the filename. A pair has the form
    <KEY>_<NUM>. Several pairs are conjoined by "-". NUM can be integers or
    floats (in regular or scientific notation).

    This script was written to sort the result-plots of parameter-sweeps
    in different orders before viewing them.

Options:
    -h --help         Show this help.

    --version         Show version.

    -v --verbose      Be verbose

    -r --reverse KEY  Order KEY in reverse.

    -R --reverse-all  Order all keys reverse. If -r is specified, those
                      keys will not be sorted in reverse.

    -f --first KEY    Sort by KEY first (in order of specification).

    -l --last KEY     Sort by KEY last (in order of specification).

""".format(prgm=osp.basename(sys.argv[0]))

__version__ = "0.0.3"

# _matcher = re.compile("([^-/]+?)_(\d+\.?\d*(?:e(?:\+|-|)\d+)?|[A-Za-z]+)(?:-|$|/|\.)")
# in case the file is has suffix like dw_100-l2r_0.0010-learn_0.0050_training.svg
_matcher = re.compile("([^-/]+?)_(\d+\.?\d*(?:e(?:\+|-|)\d+)?|[A-Za-z]+)(?:-|_|$|/)")


def parse_filenames_for_numbers(filenames):
    retval = {}
    for fn in filenames:
        fn_nums = retval[fn] = {}
        for k,v in _matcher.findall(fn):
            try:
                v = float(v)
            except ValueError:
                v = hash(v)
            fn_nums[k] = v
    return retval

def get_order(filename):
    return [m[0] for m in _matcher.findall(filename)]


def sorted_filename(filenames, first=[], last=[],
        reverse=[], reverse_all=False, verbose=False):
    # matcher = re.compile("([^-/_]+?)_(\d+\.?\d*(?:e(?:\+|-|)\d+)?)(?:-|$|/)")
    # fn_to_nums = {fn: {k: (float(v) if len(v) > 0 else 0.) for k,v in matcher.findall(fn)}\
            # for fn in filenames}
    fn_to_nums = parse_filenames_for_numbers(filenames)

    if verbose:
        print(fn_to_nums)

    print("There are {} files ".format(len(fn_to_nums)), file=sys.stderr)

    num_numbers = map(len, fn_to_nums.itervalues())
    assert min(num_numbers) == max(num_numbers), "Amount of numbers varies"

    key_set = set()
    for fnk in fn_to_nums.itervalues():
        key_set.update(fnk.iterkeys())

    assert len(key_set) == min(num_numbers),\
        "Key values are not the same accross filenames" 

    assert len(set(first).union(last)) == len(first+last),\
        "Duplicates found in first and last."

    set_firstlast = set(first+last)
    if not (set_firstlast <= key_set):
        raise ValueError("Unknown keys: {}".format(
            ", ".join(set_firstlast-key_set)))

    reverse_key = {k: reverse_all for k in key_set}

    for rk in reverse:
        reverse_key[rk] = not reverse_key[rk]

    order = get_order(filenames[0])

    # remove items from the order that are specified
    for v in it.chain(first, last):
        order.remove(v)

    order = first + order + last

    print("Sorting like {}.".format(str(order)), file=sys.stderr)
    if verbose:
        print("Final order:", order)

    for i in xrange(-1, -len(order)-1, -1):
        filenames = sorted(filenames, key=lambda fn: fn_to_nums[fn][order[i]],
                reverse=reverse_key[order[i]])
        if verbose:
            print(">> Filenames after sorting by:", order[i])
            pprint(filenames)

    return filenames


if __name__ == '__main__':
    args = docopt( __doc__, version=__version__)

    for filename in sorted_filename(args["FILENAME"],
            first=args["--first"], last=args["--last"],
            reverse=args["--reverse"],
            reverse_all=args["--reverse-all"],
            verbose=args["--verbose"]):
        print(filename)

