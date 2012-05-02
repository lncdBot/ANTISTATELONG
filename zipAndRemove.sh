#!/usr/bin/env bash

# ran as: 
#   ./zipAndRemove.sh  | tee zipAndRemoveOut.txt
#

# find all mprage and run dcm files
# zip them, and remove (compressing about 50%)
#
# skips if dcm count is not what is expected (244 or 224)
#  many mprage dirs skipped b/c count is 192

# list of files is written to dcmlist.txt
# 


rootdir=$(pwd);
(find . -type d -iname mprage; find . -type d -iname run\*)|tee dcmlist.txt | while read dir; do
 
  cd $dir
  dcmcount=$(ls *dcm | wc -l)
  if [[ "$dcmcount" =~ "224" || "$dcmcount" =~ "244" || "$dcmcount" =~ "192" ]]; then
   zip dcms.zip *dcm && rm *dcm || echo "zip error for $dir!!!"
  else
   echo -e "$dir failed -- not the right num of dcms ($dcmcount)" 
   echo -e "\tcd $dir"
   echo -e "\tzip dcms.zip dcm\*"
   echo -e "\trm \*dcm"
  fi
  cd $rootdir
done | tee zipAndRemoveOut.txt

# 192 count wasn't allowed, fixed:
#  grep '192)' zipAndRemoveOut.txt |cut -d' ' -f 1 | while read rage; do pushd $rage; zip dcms.zip *dcm && rm *dcm || echo "fail $rage";  popd; done | tee -a zipAndRemoveOut.txt
