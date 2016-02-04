#!/bin/bash


get_target_from_config()
{
	config_file_path="$1"
	cat .config | grep "^CONFIG_TARGET_BOARD=" | sed 's/\"$//g' | sed 's/^.*\"//g'
}


if [ -z "${BASH_VERSION}" ] || [ "${BASH_VERSION:0:1}" -lt '4' ]; then
	echo 'Build script was designed to work with bash in version 4 (at least). Exiting...'
	exit 1
fi

#parse parameters
target="$1"

#initialize constants

#working directories
scriptpath="$(readlink -f "$0")"
top_dir="${scriptpath%/${0##*/}}"
targets_dir="$top_dir/targets"
patches_dir="$top_dir/patches-generic"
compress_js_dir="$top_dir/compressed_javascript"

#script for building netfilter patches
netfilter_patch_script="$top_dir/netfilter-match-modules/integrate_netfilter_modules.sh"

#openwrt branch
branch_name="Chaos Calmer"
branch_id="chaos_calmer"
branch_packages_path="packages"

# set svn revision number to use
# you can set this to an alternate revision
# or empty to checkout latest
rnum=48220


cd "$top_dir"


if [ -d "$top_dir/package-prepare" ] ; then
	rm -rf "$top_dir/package-prepare"
fi


#create common download directory if it doesn't exist
if [ ! -d "$top_dir/downloaded" ] ; then
	mkdir "$top_dir/downloaded"
fi

openwrt_src_dir="$top_dir/downloaded/$branch_id"
openwrt_package_dir="$top_dir/downloaded/$branch_id-packages"
if [ -n "$rnum" ] ; then
	openwrt_src_dir="$top_dir/downloaded/$branch_id-$rnum"
	openwrt_package_dir="$top_dir/downloaded/$branch_id-packages-$rnum"
else
	rm -rf "$openwrt_src_dir"
	rm -rf "$openwrt_package_dir"
fi


#download openwrt source if we haven't already
if [ ! -d "$openwrt_src_dir" ] ; then
	revision=""
	if [ -n "$rnum" ] ; then
		revision=" -r $rnum "
	fi
	echo "fetching openwrt source"
	rm -rf "$branch_name" "$branch_id"
	svn checkout $revision -q svn://svn.openwrt.org/openwrt/branches/$branch_id/
	if [ ! -d "$branch_id" ] ; then
		echo "ERROR: could not download source, exiting"
		exit
	fi
	cd "$branch_id"
	find . -name ".svn" | xargs -r rm -rf
	cd "$top_dir"
	mv "$branch_id" "$openwrt_src_dir"
fi

rm -rf "$openwrt_src_dir/dl"
ln -s "$top_dir/downloaded" "$openwrt_src_dir/dl"


#remove old build files
rm -rf "$target-src"
rm -rf "$top_dir/built/$target"
rm -rf "$top_dir/images/$target"

#copy source to new, target build directory
cp -r "$openwrt_src_dir" "$target-src"




#copy target default configuration to build directory
cp "$targets_dir/$target/profiles/default/config" "$top_dir/${target}-src/.config"

	#enter build directory and make sure we get rid of all those pesky .svn files,
	#and any crap left over from editing
	cd "$top_dir/$target-src"
	find . -name ".svn"  | xargs rm -rf
	find . -name "*~"    | xargs rm -rf
	find . -name ".*sw*" | xargs rm -rf

	#patch & build
	scripts/patch-kernel.sh . "$patches_dir/" >/dev/null 2>&1
	scripts/patch-kernel.sh . "$targets_dir/$target/patches/" >/dev/null 2>&1
	sh $netfilter_patch_script . "$top_dir/netfilter-match-modules" 1 1 >/dev/null 2>&1

	openwrt_target=$(get_target_from_config "./.config")

	#save openwrt variables for rebuild
	echo "$rnum" > "$revision_save_dir/OPENWRT_REVISION"
	echo "$branch_name"  > "$revision_save_dir/OPENWRT_BRANCH"

	make V=50

	#free up disk space
	rm -rf "$top_dir/$target-src/build_dir"

	#copy packages to built/target directory
	mkdir -p "$top_dir/built/$target/default"
	package_base_dir=$(find bin -name "base")
	package_files=$(find "$package_base_dir" -name "*.ipk")
	index_files=$(find "$package_base_dir" -name "Packa*")
	if [ -n "$package_files" ] && [ -n "$index_files" ] ; then
		for pf in $package_files ; do
			cp "$pf" "$top_dir/built/$target/default/"
		done
		for inf in $index_files ; do
			cp "$inf" "$top_dir/built/$target/default/"
		done
	fi

	cd "$top_dir"
