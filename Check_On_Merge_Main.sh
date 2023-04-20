#!/bin/sh -l

cd $1

current_dir="$1"
# Check if DESCRIPTION file exist

if [ -f DESCRIPTION ]; then
    echo "DESCRIPTION exist."
    
    echo $(pytest tests/ -k "intergrate") > ${current_dir}/python_test_log.log
    
    cat python_test_log.log
    
  echo "====================================================================="
  echo "====================================================================="
  
  message_check=$(cat python_test_log.log | grep -E "FAILED tests/")

  message_check=$(cat python_test_log.log)

  if [ -s python_test_log.log ] && [[ ! $message_check =~ "FAILED tests/" ]]; then
      echo "Passed Check!"
  else
      echo "Failed Check!"
      exit 2
  fi
done

