#!/bin/bash
#
# A fun little screen saver app for the terminal
# run it: `./ss.sh`
#
#### Characters #####
star=$'\xe2\x98\x85'
comm=$'\xe2\x8c\x98'

#### Colors #########
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
GRAY=`tput setaf 7`
DARK_ORANGE=`tput setaf 208`
ORANGE=`tput setaf 214`
LIGHT_ORANGE=`tput setaf 220`
BOLD=`tput bold`
DIM=`tput dim`
UNDER=`tput smul`
RESET=`tput sgr0`

# term_size2 - Dynamically display terminal window size
draw_border() {
  tput home
  cols=$(tput cols)
  rows=$(tput lines)
  # Top
  for i in $(seq 0 $((cols-1))); do
    echo -n ${star};
  done
  # Left
  for i in $(seq 1 $((rows-2))); do
    echo ${star};
  done
  tput cup $((rows-1)) 0
  # Bottom
  for i in $(seq 0 $((cols-1))); do
    echo -n ${star};
  done
  # Right
  for i in $(seq 1 $((rows-2))); do
    tput cup $((i)) $((cols-1))
    echo ${star}
  done
}

block_color() {
  color_switch_steps=100
  color_num=$(($((steps/color_switch_steps))%7))
  color=${RED}
  case ${color_num} in
  0)
    color=${RED} ;;
  1)
    color=${ORANGE} ;;
  2)
    color=${YELLOW} ;;
  3)
    color=${GREEN} ;;
  4)
    color=${CYAN} ;;
  5)
    color=${BLUE} ;;
  6)
    color=${MAGENTA} ;;
  esac
  echo ${color}
}

draw_block() {
  x=$1
  y=$2
  size=$3
  block_color
  for i in $(seq 0 $((size))); do
    tput cup $((y+i)) ${x}
    for j in $(seq 0 $((size*2))); do
      echo -n ${comm}
    done
  done
  echo -n ${RESET}
}

draw_debug_box() {
  tput home
  echo -n "Block: ${size_x}x${size_y} ($((vector_x*dir_x)),$((vector_y*dir_y))) @ [${block_x},${block_y}] : ${steps} "
}

vector_x=3
vector_y=1
block_x=1
block_y=1
dir_x=1
dir_y=1
size_y=1
size_x=$((size_y*2))
steps=0

redraw() {
  draw_debug_box
  draw_block ${block_x} ${block_y} ${size_y}
}

step() {
  cols=$(tput cols)
  rows=$(tput lines)
  next_x=$((block_x+vector_x*dir_x))
  next_y=$((block_y+vector_y*dir_y))

  # Left edge
  if [ $((next_x)) -le 1 ]; then
    dir_x=$((dir_x*-1))
    next_x=1
  fi
  # Right edge
  if [ $((next_x+size_x)) -ge $((cols-2)) ]; then
    dir_x=$((dir_x*-1))
    next_x=$((cols-2-size_x))
  fi
  # Top Edge
  if [ $((next_y)) -le 1 ]; then
    dir_y=$((dir_y*-1))
    next_y=1
  fi
  # Bottom Edge
  if [ $((next_y+size_y)) -ge $((rows-2)) ]; then
    dir_y=$((dir_y*-1))
    next_y=$((rows-2-size_y))
  fi

  block_x=${next_x}
  block_y=${next_y}
  steps=$((steps+1))
  redraw
}

init() {
  tput clear
  draw_border
  redraw
}

trap init WINCH
tput civis
init
while true; do
  sleep .005
  step
done
