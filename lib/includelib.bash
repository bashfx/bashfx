#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================
	this_pkg='package'
	inc_package="${BASH_SOURCE[0]}"
	#this_fx+=( set_flag_true set_flag_false include require_lib use_cmd command_exists )

#-------------------------------------------------------------------------------
# Opt Vars
#-------------------------------------------------------------------------------

  #opt_list+=(  )

#-------------------------------------------------------------------------------
# Common Flags
#-------------------------------------------------------------------------------

  args=("${@}")
  #args=( "${args[@]/\-*}" ); #delete anything that looks like an option

##------------------------------------------------------------------------------

	function set_flag_true(){
		set_arg "$1" "$2" 0
	}

	function set_flag_false(){
		set_arg "$1" "$2" 1
	}

  function set_arg(){
    local flag opt val; flag="$1"; opt="$2"; val="$3"
    if [[ "${args[@]}" =~ "$flag" ]]; then
	    args=( "${args[@]//$flag/}" );
	    cmd="${opt}=$val";
	    eval "$cmd"
	   #echo "${opt} ${!opt} $val"
	  fi
  }

##------------------------------------------------------------------------------

	function include(){
		source "${@}"
	}

	function require_lib(){
		local lib src inc
		lib="$1"
		inc="inc_${lib}"
		base="${LOCAL_LIB:-$FX_LIB}"
		src="$base/${lib}.bash"
		#echo "pkg $this_pkg / ${!inc}"
		if [ -z "${!inc}" ]; then
			if [ -f "$src" ]; then
					source "$src"
			else
				echo "Missing $src $inc (from $this_pkg)" && return 1
			fi
		fi
		return 0
	}

	#command must exist
	function use_cmd(){
		local args=("${@}")
  	for c in "${args[@]}"; do
  		if command_exists "$c"; then
  			echo "$(which $c)"
  			break
  		fi
  	done
  	#exit 1
	}

	function command_exists() {
		type "$1" &> /dev/null ;
	}



##------------------------------------------------------------------------------