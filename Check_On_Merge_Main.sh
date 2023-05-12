#!/bin/sh -l

cd $1

current_dir="$1"
# Check if DESCRIPTION file exist

all_test_files=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'tests/' | grep -v '/fixtures' | \
                grep -v "__init__.py" | grep -v '^helper-.*.py$'))

echo -e "\nTests to run are: "
for test in ${all_test_files[@]};
do
  echo $test
done

test_records=()

for test_to_run in "${all_test_files[@]}"
do 
  echo "\nTesting: $test_to_run"
  
  echo "====================================================================="
  
  pytest $test_to_run
  
  echo "====================================================================="

  pytest_exit_status=$?

  if [ $pytest_exit_status -eq 0 ]; then
      echo "\nTest passed\n"
      test_records+=("$test_to_run : Passed. ")
  else
      echo "\nTest failed\n"
      test_records+=("$test_to_run : Failed. ")
  fi
done

echo "\n\nTseting Finished!"

for record in "${test_records[@]}";
do
  echo $record
done
