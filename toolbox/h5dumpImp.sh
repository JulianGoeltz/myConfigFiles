#!/bin/bash

# set -euo pipefail

# get string from hdf5 file (and nothing but string)
default_path=input/yaml_pure

filehdf5=$1
hdf5_path=${2:-$default_path}
fileyaml=${filehdf5:0:-4}yaml
tmp=$(python - <<-EOF
import h5py, os, os.path as osp, yccp
if osp.isfile('$filehdf5') and osp.splitext('$filehdf5')[1] == '.hdf5':
    with h5py.File('$filehdf5') as hf:
        file = hf['$hdf5_path'].value
elif osp.isfile('$filehdf5') and osp.splitext('$filehdf5')[1] == '.yaml':
    with open('$filehdf5') as file:
        tmp = yccp.load(file)
else:
    print("need correct file")
    exit()
if "$hdf5_path" == "default_path":
    tmp = yccp.load(file)
    tmp.pop('_metainfo', None)
    tmp['cache'].pop('precision', None)
    tmp['config'].pop('sim_eval_different_taums', None)
    tmp['simulation'].pop('num_batched_training_steps', None)
    tmp['simulation'].pop('report_every', None)
    print(yccp.dump(tmp))
else:
    print(file)
EOF
)
if [[ "$3" == "yaml" ]]; then
	echo "$tmp" > "$fileyaml"
else
	echo "$tmp"
fi

