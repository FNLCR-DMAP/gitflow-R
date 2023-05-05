#!/bin/sh -l

cd "$1"

pytest --version

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"
echo "Checking latest push to $current_branch"

R_script_test=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'tests/' | grep -v '/fixtures' | \
                sed 's:.*/::' | grep -v '^helper-.*.py$'))
                
echo -e "Test script changed: \n${R_script_test[*]}\n"

R_script_func=($(git diff "$last_commit" HEAD --name-only $current_branch | \
                grep -E 'src/spac/' | sed 's:.*/::' | grep -iE '*.py$'))
                
echo -e "Function script changed: \n${R_script_func[*]}\n"

for R_script in "${R_script_func[@]}"
do
  test_file=$(ls tests/testthat | grep -iE "$R_script" | grep -iE "test")
  if [[ ! " ${R_script_test[*]} " =~ " ${test_file} " ]]; then
    R_script_test+=("$test_file")
  fi
done

echo -e "Tests to run as: \n${R_script_test[*]}\n"

# poetry add --dev pytest

for test_to_run in "${R_script_test[@]}"
do 
  
  test_call='pytest tests/$test_to_run'

  
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

