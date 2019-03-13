#!/bin/zsh

if [ $# -eq 0 ]; then
echo "go through folders given as arguments, and process all the .hdf5 files in
the simulations subfolder with 
      ./plot.py plot_seedsweep [list of hdf5s]
IF:
   * for each yaml there is a readonly hdf5
   * no plot_sweep*.svg file in that folder already"
exit;
fi

# check whether a plot.py exists in current folder
[ ! -f "plot.py" ] && echo "Execute this command in a 'code' subfolder, needs 'plot.py' to work" && exit

# if first argument is not a file, we take it as the simulations subfolder.
# if it is not set, throw an error if there is more than one such subfolder
if [ ! -e $1 ]; then
	subFolder="$1"
	subFolderSet=true
	shift
	echo "Looking in the $subFolder subfolders"
else
	subFolder="simulations"
	subFolderSet=false
fi

countSubmit=0
countDone=0
countNotfinished=0
for fold in $@; do
	[ ! -d $fold ] && continue
	# && echo "    is not an existing folder" 

	echo $fold

	if [ $(ls $fold/simulations* -d 2>/dev/null | wc -l) -gt 1 ] && ! $subFolderSet; then
		echo "Folder $fold has more than one simulations# subfolder:"
		ls $fold/simulations* -d
		echo "you have to specify which one you want to use"
		exit
	fi

	if [[ $(find $fold -name 'plot_sweep_*' 2>/dev/null | wc -l) -ne 0 ]]; then
		echo "    plot_sweep already exists."
		countDone=$(($countDone+1))
		continue
	fi

	# check if more than one yaml file
	if [[ "$(ls $fold/*.yaml | wc -l)" -lt 2 ]]; then
		echo "    only plot sweeps for more than one yaml"
		continue
	fi

	gothrough=true
	for yaml in $(ls $fold/*.yaml); do
		base=$(basename ${yaml:0:-5})
		# echo "$yaml -> $base"
		if [[ "$(find $fold/$subFolder -name ${base}_\*.hdf5 -perm a=r  2>/dev/null | wc -l)" -ne 1 ]]; then
			# echo doesnt\ exist
			gothrough=false
		fi
	done
	if ! $gothrough; then
		echo "    didn't train all yamls yet"
		countNotfinished=$(($countNotfinished+1))
		continue
	fi

	# filetype=.png can be used
	# sbatch -p short --wrap " ./plot.py plot_seedsweep $fold/$subFolder/*hdf5"
	nohup ./plot.py plot_seedsweep $fold/$subFolder/*hdf5 &
	# ./plot.py plot_seedsweep $fold/$subFolder/*hdf5
	# echo "    ./plot.py plot_seedsweep $fold/$subFolder/*hdf5"
	countSubmit=$(($countSubmit+1))
done
echo "Started $countSubmit plottings ($countNotfinished not finished, $countDone already done)"
