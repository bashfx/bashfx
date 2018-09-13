#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================
  
  [ "$(type -t require_lib)" = function ] && require_lib "colors" || source "./colors.bash"

#-------------------------------------------------------------------------------
# Package Vars
#-------------------------------------------------------------------------------
  
  this_pkg='terminal'
	inc_terminal="${BASH_SOURCE[0]}"

#-------------------------------------------------------------------------------
# Init Vars
#-------------------------------------------------------------------------------


  tab=$'\t'
  nl=$'\n'

  char_diam='\xE1\x9B\x9C'
  char_delta='\xE2\x96\xB3'
  char_pass='\xE2\x9C\x93'
  char_fail='\xE2\x9C\x97'
  char_dots='\xE2\x80\xA6'

  char_space='\x20'
  char_null='\x01'

  line="$(sed -n '2,2 p' $BASH_SOURCE)$nl"
  bline="$(sed -n '3,3 p' $BASH_SOURCE)$nl"

#-------------------------------------------------------------------------------
# Init Vars
#-------------------------------------------------------------------------------

  opt_list+=( quiet force verbose silly debug yes dev_mode dry_mode )

  opt_quiet=1
  opt_force=1
  opt_verbose=1
  opt_silly=1
  opt_debug=1
  opt_yes=1
  opt_dev_mode=1
  opt_dry_mode=1


#-------------------------------------------------------------------------------
# Common Flags
#-------------------------------------------------------------------------------

  set_flag_true "--debug" opt_debug
  set_flag_true "--info"  opt_verbose
  set_flag_true "--silly" opt_silly
  set_flag_true "--quiet" opt_quiet
  set_flag_true "--force" opt_force
  set_flag_true "--dev"   opt_dev_mode
  set_flag_true "--dry"   opt_dry_mode
  set_flag_true "--yes"   opt_yes

  if [ $opt_quiet   -eq 1 ]; then
     [ $opt_silly   -eq 0 ] && opt_verbose=0
     [ $opt_verbose -eq 0 ] && opt_debug=0
  fi

  # if [ $opt_dump    -eq 0 ]; then
  #   opt_verbose=0
  # fi

  # if [ $opt_force   -eq 0 ]; then
  #   opt_safe_mode=1
  #   opt_yes=0
  # fi


#-------------------------------------------------------------------------------
# Printers
#-------------------------------------------------------------------------------


  function __printf(){
    local text color prefix
    text=${1:-}; color=${2:-white2}; prefix=${!3:-};
    [ $opt_quiet -eq 1 ] && [ -n "$text" ] && printf "${prefix}${!color}%b${x}" "${text}" 1>&2 || :
  }

  function __print(){
    local text color prefix
    text=${1:-}; color=${2:-white2}; prefix=${!3:-};
    [ $opt_quiet -eq 1 ] && [ -n "$text" ] && printf "${prefix}${!color}%b${x}\n" "${text}" 1>&2 || :
  }

  function p(){
    [ $opt_quiet -eq 1 ] && [ -n "$1" ] && printf "${@}\n" 1>&2 || :
  }

  function res(){
    local ok="$2"
    local err="$3"
    [[ "$1" =~ (0|true)  ]] && local res="${pass}${ok}$grey"
    [[ "$1" =~ (1|false) ]] && local res="${fail}${err}$grey"
    echo "$res"
  }

  function not_dry(){
  	[ "$opt_dry_mode" -eq 1 ]; return $?;
  }

  function is_dev(){
    [ "$opt_dev_mode" -eq 0 ]; return $?;
  }

  function is_debug(){
    [ "$opt_debug" -eq 0 ]; return $?;
  }

  function run(){
    local cmd="$1"
    if not_dry; then
      eval "$cmd";
      return $?
    else
      dtrace "Dry Running Command...$nl$line   $cmd$nl$line"
    fi
  }


  function line(){
    local lcol llen lx
    lcol="$2"; llen="$1"; lx=$(tput sgr0)
    printf "${lcol}%*s${lx}\n" "${llen:-$(tput cols)}" '' | tr ' ' - 1>&2
  }








#-------------------------------------------------------------------------------
# Loggers
#-------------------------------------------------------------------------------

  function    info(){ local text=${1:-}; [ $opt_debug   -eq 0 ] && __print "$lambda$text" "blue"; }
  function   silly(){ local text=${1:-}; [ $opt_silly   -eq 0 ] && __print "$dots$text" "purple"; }
  function   trace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$text"   "grey2"; }

  function  ftrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$char_fail $text"   "red2"; }
  function  ptrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$char_pass $text$x" "green2"; }
  function  wtrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$char_delta $text$x" "orange"; }
  function  itrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$char_diam $text$x" "blue"; }
  function  devtrace(){ local text=${1:-}; [ $opt_dev_mode -eq 0 ] && __print "$char_diam $text$x" "purple"; }
  function  dtrace(){ local text=${1:-}; [ $opt_dry_mode -eq 0 ] && __print "$char_diam $text$x" "purple2"; }

  function   error(){ local text=${1:-}; __print "$char_fail $text" "red2"; has_error=1; }
  function    warn(){ local text=${1:-}; __print "$char_delta $text$x" "orange";  }
  function    pass(){ local text=${1:-}; __print "$char_pass $text$x" "green2"; }
  function    dout(){ local text=${1:-}; __print "$char_delta $text$x" "purple2"; }
  function success(){ local text=${1:-}; __print "\n$char_pass $1 [$2] \n"; }
  function   fatal(){ trap - EXIT; __print "\n$char_fail $1 [$2] \n"; exit 1; }
  function   quiet(){ [ -t 1 ] && opt_quiet=${1:-1} || opt_quiet=1; }

#-------------------------------------------------------------------------------
# Confirm
#-------------------------------------------------------------------------------

  function confirm() {
    local ret;ret=1
    __printf "${1}? > " "white" #:-Are you sure ?

    [ $opt_yes -eq 0 ] && __printf "${bld}${green}yes${x}\n" && return 0;
    #[ $opt_no  -eq 0 ] && __printf "${bld}${red}no${x}" && ret=1;

    while read -r -n 1 -s answer; do
      #info "try answer..."
      [ $? -eq 1 ] && exit 1;
      
      if [[ $answer = [YyNn10tf+\-q] ]]; then
        [[ $answer = [Yyt1+] ]] && __printf "${bld}${green}yes${x}" && ret=0 || :
        [[ $answer = [Nnf0\-] ]] && __printf "${bld}${red}no${x}" && ret=1 || :
        [[ $answer = [q] ]] && __printf "\n" && exit 1 || :
        break
      fi
    done
    __printf "\n"
    return $ret
  }

  function prompt_path(){
    local res ret next
    prompt="$1"
    prompt_sure="$2"
    default="$3"

    #fancy -> set defualt and escape prompt shell values and chars
    prompt=$(eval echo "$prompt")

    while [[ -z "$next" ]]; do
      read -p "$prompt? > ${bld}${green}" __NEXT_DIR
      res=$(eval echo $__NEXT_DIR)
      [ -z "$res" ] && res="$default"
      if [ -n "$res" ]; then

        [ "$res" = '!' ] && { echo "auto"; return 1; }
        [ "$res" = '?' ] && { echo "cancelled"; return 1; }

        if confirm "${x}${prompt_sure} [ ${blue}$res${x} ] (y/n)"; then
          if [ ! -d "$res" ]; then
            error "Couldn't find the directory ($res). Try Again. Or '?' to cancel. '!' for auto."
          else
            next=1
          fi
        fi
      else
        warn "Invalid Entry! Try Again."
      fi
    done
    echo "$res"
  }


  function cprint() {
      local typ len r
      typ=$1
      case $typ in
          v) alpha="aeiouy" ;;
          c) alpha="bcdfghjklmnpqrstvwxz" ;;
          V) alpha="AEIOUY" ;;
          C) alpha="BCDFGHJKLMNPQRSTVWXZ" ;;
          n) alpha="0123456789" ;;
          h) alpha="0123456789abcdef" ;;
          *) echo "** Undefined **" ; exit 1 ;;
      esac
      len=${#alpha}
      r=$((RANDOM%len))
      echo -en ${alpha:r:1}
  }

  function rprint() {
      code=$1
      for i in $(seq 1 ${#code})
      do
          c=${code:i-1:1}
          cprint $c
      done
      echo
  }
