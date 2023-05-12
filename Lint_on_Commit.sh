#!/bin/sh -l

cd "$1"

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Checking latest push to $current_branch"

echo "Latest commit hash is $last_commit"

test_scripts=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'tests/'))
                
echo -e "Test script changed: \n${test_scripts[*]}\n"

function_scripts=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'src/spac/'))
                
echo -e "Function script changed: \n${function_scripts[*]}\n"


Lint_list=( "${test_scripts[@]}" "${function_scripts[@]}" )

echo -e "Lint to run as: \n${Lint_list[*]}\n"

for test_to_run in "${Lint_list[@]}"
do   
  echo "====================================================================="

  flake8 $test_to_run
  
  echo "====================================================================="
done


