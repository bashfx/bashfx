#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================
	this_pkg='sudo'
	inc_sudo="${BASH_SOURCE[0]}"

  require_lib "terminal"

#-------------------------------------------------------------------------------
# Common Flags
#-------------------------------------------------------------------------------

	opt_can_sudo=1


##------------------------------------------------------------------------------
	function can_sudo(){
		$(sudo -n true);
		opt_can_sudo=$?;
		return $opt_can_sudo;
	}


	function get_sudo(){
		if [[ "$EUID" = 0 ]]; then
		  :
		else
	    sudo -k # make sure to ask for password on next sudo
	    if sudo true; then
	      :
        echo "ok sudo"
	    else
        echo "Wrong password"
        exit 1
	    fi
		fi
	}

  function check_dir_perm(){
    local this_user this_dir this_perm  this_group  this_owner ret
    this_user="$1"
    this_dir="$2"
    ret=1

    if [ ! -d $this_dir ]; then
      parent_dir="$( cd "$(dirname "$this_dir")"   || exit; pwd)"
      [ -d $parent_dir ] && this_dir="$parent_dir"
    fi

    if [ -d $this_dir ]; then

      this=( $(stat -L -c "%a %G %U" $this_dir) )
      this_perm=${this[0]}
      this_group=${this[1]}
      this_owner=${this[2]}


      if (( ($this_perm & 0002) != 0 )); then
          # Everyone has write access
          ret=0
      elif (( ($this_perm & 0020) != 0 )); then
          # Some group has write access.
          # Is user in that group?
          gs=( $(groups $this_user) )
          for g in "${gs[@]}"; do
              if [[ $this_group == $g ]]; then
                  ret=0
                  break
              fi
          done
      elif (( ($this_perm & 0200) != 0 )); then
          # The owner has write access.
          # Does the user own the file?
          [[ $this_user == $this_owner ]] && ret=0
      fi
    else
      printf "Dir [$this_dir] does not exist!"
      exit 1
    fi

    return $ret
  }


##------------------------------------------------------------------------------
  function sudo_add_file(){
    local dest data mode ret
    dest=$1; data=$2; mode="$3"

    if check_dir_perm $USER $dest; then
      #info "$USER has permission to write to $dest"
      [ -n "$mode" ] && echo "$data" > $dest \
                     || echo "$data" >> $dest  #default mode is append
      ret=$?;
    else
      warn "$USER does not have permission to write to $dest"
      if ! can_sudo; then
        warn "Sudo is required to append to $dest"
        exit 1
      else
        echo "add to $dest"
        if not_dry; then

          { sudo bash -c 'touch "${0}"' "$dest"; }
          [ -n "$mode" ] && { sudo bash -c 'echo "${0}" >  "${1}"' "$data" "$dest"; ret=$?; } \
                         || { sudo bash -c 'echo "${0}" >> "${1}"' "$data" "$dest"; ret=$?; }

        else
          dtrace "Dry mode sudo append $dest"
        fi
      fi
    fi
    return $ret
  }

  function sudo_rm_file(){
    :
  }

  function sudo_rm_rf(){
    :
  }

  function sudo_copy(){
  	local src dest ret
  	src=$1; dest=$2; ret=1

    if check_dir_perm $USER $dest; then
      #info "$USER has permission to write to $dest"
      cp --no-preserve=all -r $src $dest; ret=$?  #preserve all may not work on mac
    else
      warn "$USER does not have permission to write to $dest"
      if ! can_sudo; then
        warn "Sudo is required to cp to $dest"
        exit 1
      else
        if not_dry; then
          #sudo touch $dest
          info "Doing copy as root"
          { sudo bash -c 'touch "${0}"' "$dest"; }
          { sudo bash -c 'cp --no-preserve=all -r "${0}" "${1}"' "$src" "$dest"; ret=$?; } #preserve all may not work on mac

          if is_debug; then
            line 10
            ls $dest
          fi

        else
          dtrace "Dry mode sudo cp"
        fi
      fi

    fi
		return $ret;
  }



  function sudo_mkdir(){
  	local dest ret
  	dest="$1"
    if check_dir_perm $USER $dest; then
      #info "$USER has permission to write to $dest"
      mkdir -p "$dest"; ret=$?
    else
      warn "$USER does not have permission to write to $dest"
      if ! can_sudo; then
        warn "Sudo is required to mk $dest"
        exit 1
      else
        if not_dry; then
          #sudo mkdir -p "$dest"
          { sudo bash -c ' mkdir -p "${0}"' "$dest"; ret=$?; }
        else
          dtrace "Dry mode sudo mkdir"
        fi
      fi     
    fi
		return $ret;
  }


  function sudo_perm(){
    local perm dest ret
    perm="$1"
    dest="$2"
    rec="$3"
    if check_dir_perm $USER $dest; then
      chmod $rec $perm $dest
    else
      warn "$USER does not have permission to change perms at $dest"
      if ! can_sudo; then
        warn "Sudo is required to chmod at $dest"
        exit 1
      else
        if not_dry; then
          #sudo mkdir -p "$dest"
          { sudo bash -c ' chmod ${0} ${1} "${2}"' "$rec" "$perm" "$dest"; ret=$?; }
        else
          dtrace "Dry mode sudo chmod"
        fi
      fi 
    fi
  }


  function sudo_bak(){
    :
  }

  function sudo_restore(){
    :
  }

  function sudo_safe_edit(){
    :
  }

  # function sudo_copy_files(){
  #   local src dest files arr i this
  #   dest="$1"; shift;
  #   src="$1"; shift;
  #   files="${@}"
  #   if [ ! -w "$dest" ]; then
  #     if can_sudo; then
  #       warn "Sudo is required to mk $target"
  #       exit 1
  #     else
  #       if not_dry; then
  #         for f in "${files[@]}"; do
  #           this="$src/$f"

  #         done
  #       else
  #         dtrace "Dry mode sudo cp ${files[@]}"
  #       fi
  #     fi
  #   fi

  # }
#echo "$0  ${BASH_SOURCE[0]}"