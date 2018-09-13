#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================
	this_pkg='trap'
  inc_trap="${BASH_SOURCE[0]}"


  require_lib "terminal"

#-------------------------------------------------------------------------------
# Sig / Flow
#-------------------------------------------------------------------------------

  function handle_sigint(){ s="$?"; kill 0; exit $s;  }
  function handle_sigtstp(){ kill -s SIGSTOP $$; }
  function handle_input(){ [ -t 0 ] && stty -echo -icanon time 0 min 0; }
  function cleanup(){ [ -t 0 ] && stty sane; }
  function fin(){
    local E="$?"
    cleanup
    [ $E -eq 0 ] && __print "${pass} ${green}${1:-Done}.${x}\n\n" \
                 || __print "$red2$fail ${1:-${err:-Cancelled}}.${x}\n\n"
  }

#-------------------------------------------------------------------------------
# Traps
#-------------------------------------------------------------------------------

  trap handle_sigint INT
  trap handle_sigint SIGTERM
  trap handle_sigtstp SIGTSTP
  trap handle_input CONT
  trap fin EXIT

