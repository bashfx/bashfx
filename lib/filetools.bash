#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================
  this_pkg='filetools'
  inc_filetools="${BASH_SOURCE[0]}"

  require_lib "terminal"

#-------------------------------------------------------------------------------

  BASH_RC_GLB="/etc/bash.bashrc"
  BASH_RC_SKEL="/etc/skel/.bashrc"
  BASH_RC="$HOME/.bashrc"



  [ -f "$HOME/.profile" ] && BASH_PROFILE="$HOME/.profile" \
                          || BASH_PROFILE="$HOME/.bash_profile"



#-------------------------------------------------------------------------------
# File Writer
#-------------------------------------------------------------------------------
  function file_replace_line(){
    local res=
    local ret=
    local match_key="$1"
    local data="$2"
    local src="$3"

    #itrace "Try replace line with $match_key, $data, ($src)"

    found=$(file_perl_match "$match_key" $src)

    #[ -z "$match_key" ] && log "Missing Match key ($match_key)" && return 1
    #log "Found $found [$match_key] ?"

    if [ -n "$found" ]; then
      sed -i.bak "s|.*${match_key}.*|${data}|gi" $src
      ret=$?
      rm -f "${src}.bak"
      #itrace "Replacing $match_key line"
    else
      #add the line
      $(file_add_line "$data" $src)
      ret=$?
      #make sure it was added
      res=$(file_perl_match "$data" "$src")
      ret=$?
      #itrace "Adding $match_key line ($ret)"
    fi

    return $ret
  }


  function file_perl_match(){
    local res=
    local ret=
    if [ ! -z "$1" ] && [ ! -z "$2" ]; then
      local key="${1}"
      local file="${2}"

      if [[ "$OSTYPE" =~ ^darwin  ]]; then #if os=osx
        res=$(perl -nle "print $& if m{$key}" "$file") #for osx/bsd
        local len=${#res}
        [ $len -gt 0 ] && ret=0 || ret=1
        #itrace "Found len[${#res}] [$key] [$file] using perl? $(res $ret)"
      else
        res=$(grep -o -P "$key" "$file")
        ret=$?
      fi

    fi
    echo $res
    return $ret
  }



  function file_add_line(){
    local res=
    local ret=
    local data="$1"
    local src="$2"
    [ -n "$src" ] && [ -f "$src" ] && ret=0 &&  printf "%s\\n" "$data" >> $src || ret=1
    #itrace "Did we add line? $data ($src)... $(res $ret)"
    return $ret
  }

  function file_del_line(){
    local res=
    local ret=
    local match_line="$1"
    local src="$2"
    sed -i.bak "s|${match_line}||gi" $src
    ret=$?
    rm -f "${src}.bak"
    return $ret
  }


  function file_kv_match(){
    local res=
    local ret=
    if [ ! -z "$1" ] && [ ! -z "$2" ]; then
      res=$(awk -v "id=$1" 'BEGIN { FS = "=" } $1 == id { print $2 ; exit }' $2)
      ret=$?
    fi
    echo $res
    return $ret
  }


  function file_rc_keys(){
    local res=
    local ret=
    if [ ! -z "$1" ]; then
      #just keys no aliases
      res=$( perl -n -e'/^(export)?\s?([[:alnum:]_\.]+)=([^=]*)/ && print "$2 \n"' "$1")
      ret=$?
    fi
    #itrace "Finding Keys... $ret"
    echo $res
    return $ret
  }

#-------------------------------------------------------------------------------
# File Tools
#-------------------------------------------------------------------------------



  function file_marker(){
    local delim dst dend mode lbl
    mode="$1"
    lbl="$2"
    delim="$3"
    dst='#'; dend='#';
    [ "$delim" = "js" ] && { dst='\/\*'; dend='\*\/'; } || :
    if [ "$mode" = "str" ]; then
      str="${dst}----${block_lbl}:str----${dend}"
    else
      str="${dst}----${block_lbl}:end----${dend}"
    fi
    echo "$str"
  }

  function file_add_block(){
    local newval src block_lbl match_st match_end data res ret
    newval="$1"; src="$2"; block_lbl="$3"; delim="$4"; ret=1;
    match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
    match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

    #check if block already exists...
    res=$(file_find_block "$src" "$block_lbl" "${delim}" )
    ret=$?

    if [ $ret -gt 0 ]; then #nomatch
			data="$(cat <<-EOF
				${match_st}
				#added:$(date +%d-%m-%Y" "%H:%M:%S)
				${newval}
				${match_end}
			EOF
      )";
      #echo "$data" >> $src
      sudo_add_file "$src" "$data" #default mode is append
      ret=$?
    fi
    return $ret
  }




  function file_del_block(){
    local src block_lbl match_st match_end data res ret dst dend
    src="$1"
    block_lbl="$2"
    delim="$3";

    match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
    match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

    sed -i.bak "/${match_st}/,/${match_end}/d" "$src" #this works on ubuntu
    ret=$?
    #make sure it was removed
    res=$(file_find_block "$src" "$block_lbl" "${delim}" )
  
    ret=$?
    printf "$res"

    #flip ret, if notfound then success
    [ $ret -gt 0 ] && ret=0 || ret=1

    #log "$(res $ret) Cannot Find? (Delete Complete)"
    rm -f "${src}.bak"
    return $ret
  }


  function file_find_block(){
    local src block_lbl match_st match_end data res ret
    src="$1"; block_lbl="$2"; delim="$3"; ret=1
    match_st=$(file_marker "str" "${block_lbl}" "${delim}")
    match_end=$(file_marker "end" "${block_lbl}" "${delim}")

    res=$(sed -n "/${match_st}/,/${match_end}/p" "$src")

    [ -z "$res" ] && ret=1 || ret=0;

    echo "$res"
    return $ret;
  }



  function profile_addvar(){
    local ret res data dest key val
    lbl="$1.$2"
    key="$2"
    val="$3"
    dest="${4:-$BASH_RC}"
    [ ! -f "$dest" ] && touch "$dest"
    res=$(file_find_block "$dest" "$lbl" ); ret=$?
    if [ $ret -eq 1 ]; then
			data="$(cat <<-EOF
				${tab} $key="$val"
			EOF
			)";
			res=$(file_add_block "$data" "$src" "$lbl" )
			ret=$?
    fi
  }



  function profile_rmvar(){
    :
  }



	function profile_link(){
		local lbl ret res data rc_file
    lbl="${1:-$script_id}"
    rc_file="${2:-$script_rc_file}"
    src="${3:-$BASH_RC}"
		#[ ! -f "$script_rc_file" ] && make_rc || :
		if [ -f "$rc_file" ]; then

			[ ! -f "$src" ] && touch "$src"

			res=$(file_find_block "$src" "$lbl" ); ret=$?
			if [ $ret -eq 1 ]; then
				data="$(cat <<-EOF
					${tab} if [ -f "$rc_file" ] ; then
					${tab}   source "$rc_file"
					${tab} else
					${tab}   [ -t 1 ] && echo "\$(tput setaf 214)${rc_file} is missing, ${lbl} link or unlink to fix ${x}" ||:
					${tab} fi
				EOF
				)";
				res=$(file_add_block "$data" "$src" "$lbl" )
				ret=$?
			fi
		else
			error "File doesnt exist @ $src"
		fi
	}



	function profile_unlink(){
		local lbl ret res data src lbl
    lbl="${1:-$script_id}"
    rc_file="${2:-$script_rc_file}"
    src="${3:-$BASH_RC}"

		[ -f "$rc_file" ] && rm -f "$rc_file"

		res=$(file_del_block "$src" "$lbl" );ret=$?

		[ $ret -eq 0 ] && wtrace ".${lbl}rc removed from $src" || echo "Something went worng!"
	}
