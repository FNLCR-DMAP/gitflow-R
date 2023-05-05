#!/bin/sh -l

cd $1

current_dir="$1"
# Check if DESCRIPTION file exist

R_scripts=($(ls ./src/spac))
                
function_name_list=()

R_script_test=()

for script in "${R_scripts[@]}"; do
  function_name="${script%.R}"
  function_name_list+=("${script%.R}")
  
  test_file=$(ls tests/ | grep -iE "$script" | grep -iE "test")
  R_script_test+=("$test_file")
done


printf "%-35s %-35s\n" "Function_Scripts" "Test_scripts"
line=$(printf "%-$(($(tput cols)-1))s" "")
line=${line// /-}
printf "%s\n" "$line"
for ((i=0; i<${#function_name_list[@]}; i++)); do
  if [ -z "${R_script_test[i]}" ];
  then
    printf "%-35s %-35s\n" "${function_name_list[i]}" "MISSING"
    printf "%s\n" "$line"
  else
    printf "%-35s %-35s\n" "${function_name_list[i]}" "${R_script_test[i]}"
    printf "%s\n" "$line"
  fi
done

for test_to_run in ${R_script_test[@]}
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

