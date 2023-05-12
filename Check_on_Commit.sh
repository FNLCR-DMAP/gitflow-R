#!/bin/sh -l

cd "$1"

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Checking latest push to $current_branch"

echo "Latest commit hash is $last_commit"

pytest --version

test_scripts=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'tests/' | grep -v '/fixtures' | \
                sed 's:.*/::' | grep -v '^helper-.*.py$'))
                
echo -e "Test script changed: \n${test_scripts[*]}\n"

function_scripts=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'src/spac/' | sed 's:.*/::' | grep -iE '*.py$'))
                
echo -e "Function script changed: \n${function_scripts[*]}\n"

all_test_files=($(ls tests/ | grep -iE "test_"))

for function_name in "${function_scripts[@]}"
do
  test_file=$(ls tests/testthat | grep -iE "$function_name" | grep -iE "test")
  if [[ ! " ${R_script_test[*]} " =~ " ${test_file} " ]]; then
    test_scripts+=("$test_file")
  fi
done


echo -e "Tests to run as: \n${test_scripts[*]}\n"

# poetry add --dev pytest

for test_to_run in "${all_test_files[@]}"
do 
  echo $test_to_run
  test_call='pytest tests/'$test_to_run

  
  echo "====================================================================="
  echo "Running $test_call"
  
  echo $(pytest tests/$test_to_run) > ${current_dir}/python_test_log.log
  
  cat python_test_log.log
  
  echo "====================================================================="
  echo "====================================================================="
  
  message_check=$(cat python_test_log.log)

  if [ -s python_test_log.log ] && [[ ! $message_check =~ "FAILED tests/" ]]; then
      echo "Passed Check!"
  else
      echo "Failed Check!"
      exit 2
  fi
done

