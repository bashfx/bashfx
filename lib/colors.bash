#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================

  this_pkg='colors'
	inc_colors="${BASH_SOURCE[0]}"

  red=$(tput setaf 1)
  red2=$(tput setaf 9)
  yellow=$(tput setaf 11)
  orange=$(tput setaf 214)
  green=$(tput setaf 2)
  green2=$(tput setaf 10)
  blue=$(tput setaf 12)
  cyan=$(tput setaf 123)
  purple=$(tput setaf 213)
  purple2=$(tput setaf 99)
  grey=$(tput setaf 244)
  grey2=$(tput setaf 240)
  white=$(tput setaf 248)
  white2=$(tput setaf 15)
  
  x=$(tput sgr0)
  eol="$(tput el)"
  bld="$(tput bold)"
  rvm="$(tput rev)"