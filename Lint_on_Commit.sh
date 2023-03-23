#!/bin/sh -l

cd "$1"

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"
echo "Checking latest push to $current_branch"

R_script_test=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'tests/'))
                
echo -e "Test script changed: \n${R_script_test[*]}\n"

R_script_func=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'src/scworkflow/'))
                
echo -e "Function script changed: \n${R_script_func[*]}\n"


Lint_list=( "${R_script_test[@]}" "${R_script_func[@]}" )

echo -e "Lint to run as: \n${R_script_test[*]}\n"

for test_to_run in "${Lint_list[@]}"
do 
  
  echo "====================================================================="

  echo $(pylint $test_to_run} > ${current_dir}/lint.log
  
  cat lint.log

  
  echo "====================================================================="
  echo "====================================================================="
done


