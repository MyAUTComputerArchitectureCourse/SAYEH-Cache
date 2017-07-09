# ! /usr/bin/bash

# This file is a bash file for compiling and simulatation of SAYEH basic computer.
# Filename and entity name of each module is listed in the module_list file that exists in the root of the
# project. This bash script reads each line and give the module_name_file to the ghdl with -a tag to compile to the object file.

# Created at 3-4-2017

cd out                                            # Change the current directory to the /out

rm *						# Removing all last generated copiled files

input=../module_list                              # Module file list 

# Color Constants
GREEN='\033[0;32m'                                # Green Color
RED='\033[0;31m'                                  # Red Color
PURPLE='\033[0;35m'                               # Purple Color
NC='\033[0m'                                      # No Color
YELLOW='\033[0;33m'                               # Yellow Color

platform='unknown'
if [ `uname` = 'Linux' ]; then
  platform='linux'
elif [ `uname` = 'Darwin' ]; then
  platform='mac'
fi

echo "${YELLOW}VHDL code GHDL compiling script${NC}"

echo "${RED}!!!!! Caution : The green text color doesn't show that the module compiled successfully!!!!!${NC}"
echo "${PURPLE}Module compiling phase${NC}"
while read file module_name
do
  analyz_out="$(ghdl -a ../$file)"                # Analyz module
  if [ -z $analyz_out ];then
    echo "${GREEN}File $file analyzed.${NC}"
    evaluate_out="$(ghdl -e $module_name)"          # Evaluate module
    if [ -z $evaluate_out ];then
      echo "${GREEN}module $module_name evaluated.${NC}"
    fi
  fi
done < "$input"

echo "${PURPLE}Testbench compiling phase${NC}"

# Compiling test bench file and producing vcd file to show the wave
ghdl -a ../tb/tb.vhd
echo "${GREEN}/tb/tb.vhd analyzed.${NC}"
ghdl -e TB
echo "${GREEN}module TB evaluated.${NC}"

echo "${PURPLE}Testbench wave exporting phase${NC}"
ghdl -r TB --vcd=wave.vcd

if [ $platform = 'linux' ]; then
  gtkwave wave.vcd
elif [ $platform = 'mac' ]; then
  open -a gtkwave wave.vcd
fi
