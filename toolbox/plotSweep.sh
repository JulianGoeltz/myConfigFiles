#!/bin/bash

if [ $# -eq 0 ]; then
echo "go through folders given as arguments, and process all the .hdf5 files in
the simulations subfolder with 
      ./plot.py plot_seedsweep [list of hdf5s]
IF:
   * for each yaml there is a hdf5, training.svg and volts.svg
   * no plot_sweep*.svg file in that folder already"
exit;
fi

[ ! -f "plot.py" ] && echo "Execute this command in a 'code' subfolder, needs 'plot.py' to work" && exit

count=0
for fold in $@; do
	echo $fold
	[ ! -d $fold ] && echo "    is not an existing folder" && continue

	if [[ $(ls $fold/plot_sweep_* 2>/dev/null | wc -l) -ne 0 ]]; then
		echo "    plot_sweep already exists."
		continue
	fi

	gothrough=true
	for yaml in $(ls $fold/*.yaml); do
		base=$(basename ${yaml::-5})
		# echo "$yaml -> $base"
		if [[ "$(ls $fold/simulations/$base*.hdf5 2>/dev/null | wc -l)" -ne 1 ]] ||
		   [[ "$(ls $fold/simulations/$base*training.svg 2>/dev/null | wc -l)" -ne 1 ]] ||
		   [[ "$(ls $fold/simulations/$base*volts.svg 2>/dev/null | wc -l)" -ne 1 ]]; then
			# echo doesnt\ exist
			gothrough=false
		fi
	done
	if ! $gothrough; then
		echo "    didn't train all yamls yet"
		continue
	fi

	sbatch -p short --wrap "./plot.py plot_seedsweep $fold/simulations/*hdf5"
	# ./plot.py plot_seedsweep $fold/simulations/*hdf5
	# echo "    ./plot.py plot_seedsweep $fold/simulations/*hdf5"
	count=$(($count+1))
done
echo "Started $count plottings"
