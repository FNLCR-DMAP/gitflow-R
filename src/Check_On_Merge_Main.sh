#!/bin/sh -l

cd $1

current_dir="$1"

touch ${current_dir}/test.log
# Check if DESCRIPTION file exist

if [ -f DESCRIPTION ]; then
    echo "DESCRIPTION exist."
    
    R -e 'library(devtools);sink(file="'${current_dir}'/test.log");load_all();document();check();sink()'  
    
    cat test.log
    
    echo "====================================================================="
    
    message_check=$(tail -n 1 test.log | cut -d'|' -f 1 | cut -d' ' -f 2)
    echo "Message Check: $message_check"
    if [ "$message_check" = "FAIL" ]; then
      echo "Failed integration test, please check the log."
      exit 2
    else
      if [ "$message_check" = "errors" ]; then
        error_num=$(tail -n 1 test.log | cut -d'|' -f 1 | cut -d' ' -f 1)
        if [ "$error_num" != "0" ]; then
          echo "Number of errors in test is $error_num"
          exit 2
        else
          echo "Passed Check!"
        fi
        
      else
        error_num=$(tail -n3 test.log | head -n1 | cut -d'|' -f 1 | cut -d' ' -f 1)
        
        if [ "$error_num" != "0" ]; then
          echo "Number of errors in test is $error_num"
          exit 2
        else
          echo "Passed Check!"
        fi
      fi
    fi
else 
    echo "DESCRIPTION file does not exist."
    exit 1
fi

