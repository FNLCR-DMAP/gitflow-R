#!/bin/sh -l

cd $1

current_dir="$1"
# Check if DESCRIPTION file exist

all_test_files=$(ls tests/ | grep -iE "test_")

echo -e "Tests to run as: \n${all_test_files[*]}\n"


for test_to_run in "${all_test_files[@]}"
do 
  
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

# echo $(pytest tests/ -k "intergrate") > ${current_dir}/python_test_log.log

# cat python_test_log.log

# echo "====================================================================="
# echo "====================================================================="

# message_check=$(cat python_test_log.log | grep -E "FAILED tests/")

# message_check=$(cat python_test_log.log)

if [ -s python_test_log.log ] && [[ ! $message_check =~ "FAILED tests/" ]]; then
    echo "Passed Check!"
else
    echo "Failed Check!"
    exit 2
fi


