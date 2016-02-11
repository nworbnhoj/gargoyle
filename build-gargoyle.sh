#!/bin/bash

if [ $(echo "$@" | grep "help") ] ; then
	echo ""
	echo "build-gargoyle is a build script for the Garoyle Router firmware."
	echo ""
	echo "  build-gargoyle [openwrt|help] [architecture].[profile] package package ...."
	echo "    openwrt                forces the openwrt to build (optional)"
	echo "    architecture           builds a single architecture"
	echo "    architecture.profile   builds a single architecture profile"
	echo "    package                builds to one or more packages."
	echo ""
	echo "  Examples:"
	echo "    build-gargoyle                       builds openwrt for all architectures and profiles"
	echo "    build-gargoyle openwrt               builds openwrt for all architectures and profiles"
	echo "    build-gargoyle openwrt ar71xx        builds openwrt and all ar71xx profiles"
	echo "    build-gargoyle ar71xx                builds all ar71xx profiles (and openwrt if necessary)"
	echo "    build-gargoyle ar71xx.usb            builds the ar71xx usb profile (and openwrt if necessary)"
	echo "    build-gargoyle ar71xx.usb gargoyle   builds the gargoyle package for ar71xx usb profile (and openwrt if necessary)"
	echo ""
	exit
fi


set_constant_variables()
{
	#working directories
	scriptpath="$(readlink -f "$0")"
	top_dir="${scriptpath%/${0##*/}}"
	targets_dir="$top_dir/targets"
	patches_dir="$top_dir/patches-generic"
	compress_js_dir="$top_dir/compressed_javascript"

	#script for building netfilter patches
	netfilter_patch_script="$top_dir/netfilter-match-modules/integrate_netfilter_modules.sh"

	num_build_thread_str=""
	#num_build_thread_str="-j1"

	js_compress="true"
	translation_type="internationalize"
	fallback_lang="English-EN"
	active_lang="English-EN"
}


set_version_variables()
{
	full_gargoyle_version="1.9.X"

	#openwrt branch
	branch_name="Chaos Calmer"
	branch_id="chaos_calmer"
	branch_is_trunk="0"
	branch_packages_path="packages"

	# set svn revision number to use
	# you can set this to an alternate revision
	# or empty to checkout latest
	rnum=48220

	#set date here, so it's guaranteed the same for all images
	#even though build can take several hours
	build_date=$(date +"%B %d, %Y")

	gargoyle_git_revision=$(git log -1 --pretty=format:%h )


	# Full display version in gargoyle web interface
	if [ -z "$full_gargoyle_version" ] ; then
		full_gargoyle_version="$1"
	fi
	if [ -z "$full_gargoyle_version" ] ; then
		full_gargoyle_version="Unknown"
	fi

	# Used in gargoyle banner
	short_gargoyle_version=$(echo "$full_gargoyle_version" | awk '{ print $1 ; }' | sed 's/[^0-9^A-Z^a-z^\.^\-^_].*$//g' )

	# Used for file naming
	lower_short_gargoyle_version=$(echo "$short_gargoyle_version" | tr 'A-Z' 'a-z' )

	# Used for package versioning/numbering, needs to be a numeric, eg 1.2.3
	numeric_gargoyle_version=$(echo "$short_gargoyle_version" | sed 's/[Xx]/0/' )
	not_numeric=$(echo "$numeric_gargoyle_version" | sed 's/[\.0123456789]//g')
	if [ -n "$not_numeric" ] ; then
		numeric_gargoyle_version="0.9.9"
	fi

	#echo "full        = \"$full_gargoyle_version\""
	#echo "short       = \"$short_gargoyle_version\""
	#echo "short lower = \"$lower_short_gargoyle_version\""
	#echo "numeric     = \"$numeric_gargoyle_version\""

}



get_target_from_config()
{
	config_file_path="$1"
	cat .config | grep "^CONFIG_TARGET_BOARD=" | sed 's/\"$//g' | sed 's/^.*\"//g'
}

create_gargoyle_banner()
{
	echo "BUILDING BANNER"
	local target="$1"
	local profile="$2"
	local date="$3"
	local gargoyle_version="$4"
	local gargoyle_commit="$5"
	local openwrt_branch="$6"
	local openwrt_revision="$7"
	local banner_file_path="$8"
	local revision_save_dir="$9"

	local openwrt_branch_str="OpenWrt $openwrt_branch branch"
	if [ "$openwrt_branch" = "trunk" ] ; then
		openwrt_branch_str="OpenWrt trunk"
	fi

	local top_line=$(printf "| %-26s| %-35s|" "Gargoyle version $gargoyle_version" "$openwrt_branch_str")
	local middle_line=$(printf "| %-26s| %-35s|" "Gargoyle revision $gargoyle_commit" "OpenWrt revision r$openwrt_revision")
	local bottom_line=$(printf "| %-26s| %-35s|" "Built $date" "Target  $target/$profile")

	cat << 'EOF' >"$banner_file_path"
------------------------------------------------------------------
|            _____                             _                 |
|           |  __ \                           | |                |
|           | |  \/ __ _ _ __ __ _  ___  _   _| | ___            |
|           | | __ / _' | '__/ _' |/ _ \| | | | |/ _ \           |
|           | |_\ \ (_| | | | (_| | (_) | |_| | |  __/           |
|            \____/\__,_|_|  \__, |\___/ \__, |_|\___|           |
|                             __/ |       __/ |                  |
|                            |___/       |___/                   |
|                                                                |
|----------------------------------------------------------------|
EOF
#'

	echo "$top_line"    >> "$banner_file_path"
	echo "$middle_line" >> "$banner_file_path"
	echo "$bottom_line" >> "$banner_file_path"
	echo '------------------------------------------------------------------' >> "$banner_file_path"

	#save openwrt variables for rebuild
	echo "$openwrt_revision" > "$revision_save_dir/OPENWRT_REVISION"
	echo "$openwrt_branch"  > "$revision_save_dir/OPENWRT_BRANCH"

}


do_js_compress()
{
	uglifyjs_arg1="$1"
	uglifyjs_arg2="$2"

	rm -rf "$compress_js_dir"
	mkdir "$compress_js_dir"
	escaped_package_dir=$(echo "$top_dir/package-prepare/" | sed 's/\//\\\//g' | sed 's/\-/\\-/g' ) ;
	for jsdir in $(find "${top_dir}/package-prepare" -path "*/www/js") ; do
		pkg_rel_path=$(echo $jsdir | sed "s/$escaped_package_dir//g");
		mkdir -p "$compress_js_dir/$pkg_rel_path"
		cp "$jsdir/"*.js "$compress_js_dir/$pkg_rel_path/"
		cd "$compress_js_dir/$pkg_rel_path/"

		for jsf in *.js ; do
	 		if [ -n "$uglifyjs_arg2" ] ; then
				"$uglifyjs_arg1" "$uglifyjs_arg2" "$jsf" > "$jsf.cmp"
			else
				"$uglifyjs_arg1" "$jsf" > "$jsf.cmp"
			fi
	 		mv "$jsf.cmp" "$jsf"
	 	done
	done
	cp -r "$compress_js_dir"/* "$top_dir/package-prepare/"

	cd "$top_dir"
}


compress_javascript()
{
		cd "$top_dir"

		uglify_test=$( echo 'var abc = 1;' | uglifyjs  2>/dev/null )
		if [ "$uglify_test" != 'var abc=1' ] &&  [ "$uglify_test" != 'var abc=1;' ]  ; then

			node_bin="$top_dir/node/node"
			uglifyjs_bin="$top_dir/UglifyJS/bin/uglifyjs"
			if [ ! -e "$node_bin" ] && [ ! -e "$uglifyjs_bin" ] ; then
				echo ""
				echo "**************************************************************************"
				echo "**  uglifyjs is not installed globally, attempting to build it          **"
				echo "**************************************************************************"
				echo ""

				#node
				git clone git://github.com/joyent/node.git
				cd node
				git checkout v0.11.14
				./configure
				make 1>/dev/null
				cd "$top_dir"


				#uglifyjs
				git clone git://github.com/mishoo/UglifyJS.git
				cd UglifyJS/bin
				git checkout v1.3.5
				cd "$top_dir"
			fi
			uglify_test=$( echo 'var abc = 1;' | "$node_bin" "$uglifyjs_bin"  2>/dev/null )
			if [ "$uglify_test" = 'var abc=1' ] ||  [ "$uglify_test" = 'var abc=1;' ]  ; then
				js_compress="true"
				do_js_compress "$node_bin" "$uglifyjs_bin"
			else
				js_compress="false"
				echo ""
				echo "**************************************************************************"
				echo "**  WARNING: Cannot compress javascript -- uglifyjs could not be built  **"
				echo "**************************************************************************"
				echo ""
			fi
		else
			js_compress="true"
			do_js_compress "uglifyjs"
		fi
		cd "$top_dir"
}


distrib_copy_arch_ind_ipk()
{
	local tgt="$1"
	local ltype="$2"
	local di=1

	local dpkgs=$(find "$top_dir/package" -path '*plugin-gargoyle-*' -and -name 'Makefile' -and -not -path '*-i18n-*' | xargs grep -s -l "DEPENDS:=+gargoyle$" | xargs grep -s -l "PKGARCH:=all$" | awk -F'/' '{print $(NF-1)}')

	# printf -- '%s\n' "${dpkgs[@]}"

	if [ ! -d "$top_dir/Distribution/architecture-independent packages ]" ] ; then
		mkdir -p "$top_dir/Distribution/architecture-independent packages"
	fi
	#if [ ! -d "$top_dir/Distribution/theme packages ]" ] ; then
	#	mkdir -p "$top_dir/Distribution/theme packages"
	#fi

	if [ ! -d "$top_dir/Distribution/theme packages ]" ] && [ "$ltype" = 'internationalize' ] ; then
		mkdir -p "$top_dir/Distribution/language packages"
	fi

	while true; do
		local apkg=$(echo "$dpkgs" | awk -v rec=$di 'NR==rec {print $0}')
		[[ -z "$apkg" ]] &&
		{
			break
		} || {
			ipkg=("$top_dir/$tgt-src/bin/$tgt/packages/${apkg}"*"ipk")
			[[ -f "${ipkg[0]}" ]] &&
			{
				cp -f "$top_dir/$tgt-src/bin/$tgt/packages/$apkg"*".ipk" "$top_dir/Distribution/architecture-independent packages/"
			}
		}
		let di++
	done
	#cp -f "$top_dir/$tgt-src/bin/$tgt/packages/plugin-gargoyle-theme-"*".ipk" "$top_dir/Distribution/theme packages/"

	if [ "$ltype" = 'internationalize' ] ; then
		cp -f "$top_dir/$tgt-src/bin/$tgt/packages/plugin-gargoyle-i18n-"*".ipk" "$top_dir/Distribution/language packages/"
	fi
}


distrib_init ()
{
	if [ ! -d "$top_dir/Distribution" ] ; then
		mkdir "$top_dir/Distribution"
	fi
	#git log --since=5/16/2013 $(git log -1 --pretty=format:%h) --pretty=format:"%h%x09%ad%x09%s" --date=short > "$top_dir/Distribution/changelog.txt"
	git log $(git describe --abbrev=0 --tags)..$(git log -1 --pretty=format:%h) --no-merges --pretty=format:"%h%x09%ad%x09%s" --date=short > "$top_dir/Distribution/Gargoyle changelog.txt"
	svn log -r "$rnum":36425 svn://svn.openwrt.org/openwrt/branches/attitude_adjustment/ > "$top_dir/Distribution/OpenWrt changelog.txt"
	cp -fR "$top_dir/LICENSES" "$top_dir/Distribution/"
}


download_openwrt()
{
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
}




######################################################################################################
## Begin Main Body of Build Script                                                                  ##
######################################################################################################


if [ -z "${BASH_VERSION}" ] || [ "${BASH_VERSION:0:1}" -lt '4' ]; then
	echo 'Build script was designed to work with bash in version 4 (at least). Exiting...'
	exit 1
fi

#initialize constants
set_constant_variables
set_version_variables

#parse parameters
if [ "$1" == "openwrt" ] ; then
	build_openwrt=true
	shift
fi
targets=$(echo $1  | sed 's/\..*$//')
profile=$(echo $1 | sed 's/^[^.]*[\.]*//')
shift
packages=$@

cd "$top_dir"

if [ -d "$top_dir/package-prepare" ] ; then
	rm -rf "$top_dir/package-prepare"
fi

[ ! -z $(which python 2>&1) ] && {
	#whether localize or internationalize, the packages directory is going to be modified
	#default behavior is internationalize; defined in Makefile
	[ "$translation_type" = "localize" ] 	&& "$top_dir/i18n-scripts/localize.py" "$fallback_lang" "$active_lang" \
											|| "$top_dir/i18n-scripts/internationalize.py" "$active_lang"
} || {
	active_lang=$(sh ./i18n-scripts/intl_ltd.sh "$translation_type" "$active_lang")
}

if [ "$js_compress" = "true" ]  ; then
	compress_javascript
fi

#create common download directory if it doesn't exist
if [ ! -d "$top_dir/downloaded" ] ; then
	mkdir "$top_dir/downloaded"
fi

# setup the openwrt directory
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
	download_openwrt
fi

rm -rf "$openwrt_src_dir/dl"
ln -s "$top_dir/downloaded" "$openwrt_src_dir/dl"

if [ "$targets" = "ALL" ]  || [ -z "$targets" ] ; then
	targets=$(ls $targets_dir | sed 's/custom//g' 2>/dev/null)
	profile="default"
fi

for target in $targets ; do

	cd "$top_dir"

	if [ "$build_openwrt" = true ] ; then # clobber all build files from prior builds
		rm -rf "$target-src/*"
	fi

	if [ -z "$profile" ] ; then # no specified profile so remove all old images
		rm -rf "$top_dir/built/$target"
		rm -rf "$top_dir/images/$target"
	else 															# remove just the profiles images
		profile_images=$(cat "$targets_dir/$target/profiles/$profile/profile_images" 2>/dev/null)
		mkdir -p "$top_dir/images/$target/"
		for pi in $profile_images ; do
			rm -rf "$top_dir/images/$target/"*"$pi"*
		done
	fi

	if [ "$build_openwrt" = true ] || [ ! -e "$target-src/bin" ] ; then # must build openwrt
		build_openwrt=false												# once only
		cp -r "$openwrt_src_dir" "$target-src"						# copy openwrt into build directory
	fi

	package_dir="$top_dir/package-prepare"
	if [ ! -d "$package_dir" ] ; then
		package_dir="$top_dir/package"
	fi

	# identify gargoyle-specific packages that must be replaced for this build
	redundant_packages=$(ls "$package_dir" )	# all packages (default)
	if [ -n "$packages" ] ; then		# if packages specified in runtime parameters
		redundant_packages=$packages	# then use them
	fi

	# remove redundant gargoyle-specific packages from build directory
	mkdir -p "$target-src/package"
	for gp in $redundant_packages ; do # remove all packages for this target
		IFS_ORIG="$IFS"
		IFS_LINEBREAK="$(printf '\n\r')"
		IFS="$IFS_LINEBREAK"
		matching_packages=$(find "$target-src/package" -name "$gp")
		for mp in $matching_packages ; do
			if [ -d "$mp" ] && [ -e "$mp/Makefile" ] ; then
				rm -rf "$mp"
			fi
		done
		IFS="$IFS_ORIG"
	done

	# copy missing gargoyle-specific packages to build directory
	gargoyle_packages=$(ls "$package_dir" )
	for gp in $gargoyle_packages ; do
		found=$(find $target-src/package/* -prune -name "$gp")
		if [ -z "$found" ] ; then
			cp -r "$package_dir/$gp" "$target-src/package"
		fi
	done

	[ ! -z $(which python 2>&1) ] && {
		#finish internationalization by setting the target language & adding the i18n plugin to the config file
		#finish localization just deletes the (now unnecessary) language packages from the config file
		[ "$translation_type" = "localize" ] 	&& "$top_dir/i18n-scripts/finalize_translation.py" 'localize' "$target" \
												|| "$top_dir/i18n-scripts/finalize_translation.py" 'internationalize' "$active_lang" "$target"
	} || {
		#NOTE: localize is not supported because it requires python
		"$top_dir/i18n-scripts/finalize_tran_ltd.sh" "$target-src" "$active_lang"
	}

	cd "$top_dir/$target-src"

	# get rid of all those pesky .svn files, and any crap left over from editing
	find . -name ".svn"  | xargs rm -rf
	find . -name "*~"    | xargs rm -rf
	find . -name ".*sw*" | xargs rm -rf

	# patch openwrt
	scripts/patch-kernel.sh . "$patches_dir/" >/dev/null 2>&1		# patch openwrt generic
	scripts/patch-kernel.sh . "$targets_dir/$target/patches/" >/dev/null 2>&1
	sh $netfilter_patch_script . "$top_dir/netfilter-match-modules" 1 1 >/dev/null 2>&1

# build only profiles specied by parameters, or build all profiles
	profiles=$profile;
	if [ -z "$profiles" ] ; then
		profiles=$(ls "$targets_dir/$target/profiles")
	fi

	for profile in $profiles ; do

		#copy target default configuration to build directory
		cp "$targets_dir/$target/profiles/$profile/config" "$top_dir/${target}-src/.config"

		openwrt_target=$(get_target_from_config "./.config")
		create_gargoyle_banner "$openwrt_target" "$profile" "$build_date" "$short_gargoyle_version" "$gargoyle_git_revision" "$branch_name" "$rnum" "package/base-files/files/etc/banner" "."

		echo ""
		echo "**************************************************************************"
		echo "        Gargoyle is now building target: $target / $profile"
		echo "**************************************************************************"
		echo ""

		make -j1 GARGOYLE_VERSION="$numeric_gargoyle_version" GARGOYLE_VERSION_NAME="$lower_short_gargoyle_version" GARGOYLE_PROFILE="$profile"

		if [ -e "bin" ] ; then
		# free up disk space
		#	rm -rf "build_dir"
		#	rm -rf "staging_dir"

			#copy packages to built/target directory
			mkdir -p "$top_dir/built/$target/$profile"
			package_base_dir=$(find bin -name "base")
			package_files=$(find "$package_base_dir" -name "*.ipk")
			index_files=$(find "$package_base_dir" -name "Packa*")
			if [ -n "$package_files" ] && [ -n "$index_files" ] ; then
				for pf in $package_files ; do
					cp "$pf" "$top_dir/built/$target/$profile/"
				done
				for inf in $index_files ; do
					cp "$inf" "$top_dir/built/$target/$profile/"
				done
			fi

			#copy images to images/target directory
			mkdir -p "$top_dir/images/$target"
			arch=$(ls bin)
			profile_images=$(cat "$targets_dir/$target/profiles/$profile/profile_images" 2>/dev/null)
			for pi in $profile_images ; do
				candidates=$(ls "bin/$arch/"*"$pi"* 2>/dev/null | sed 's/^.*\///g')
				for c in $candidates ; do
					if [ ! -d "bin/$arch/$c" ] ; then
						newname=$(echo "$c" | sed "s/openwrt/gargoyle_$lower_short_gargoyle_version/g")
						cp "bin/$arch/$c" "$top_dir/images/$target/$newname"
					fi
				done
			done
		fi

	done # profile build

done # target build
