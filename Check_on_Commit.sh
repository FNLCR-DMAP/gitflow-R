#!/bin/sh -l

cd "$1"

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Checking latest push to $current_branch"

echo "Latest commit hash is $last_commit"

pytest --version

test_scripts=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'tests/' | grep -v '/fixtures' | \
                sed 's:.*/::' | grep -v "__init__.py" | \
                grep -v '^helper-.*.py$'))

test_script_paths=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'tests/' | grep -v '/fixtures' | \
                grep -v "__init__.py" | grep -v '^helper-.*.py$'))


echo -e "Test script changed: \n${test_scripts[*]}\n"

function_scripts=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'src/spac/' | sed 's:.*/::' | \
                grep -v "__init__.py" | grep -iE '*.py$'))

function_script_paths=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'src/spac/' | grep -v "__init__.py" \
                | grep -iE '*.py$'))

echo -e "Function script changed: \n${function_scripts[*]}\n"

function_updated=()

for script in "${function_script_paths[@]}"
do
  mod_func_list=($(grep -E '^def\s+\w+\(' $script | cut -d ' ' -f 2 | cut -d '(' -f 1))
  echo "Function changed in $script:"

  for function in "${mod_func_list[@]}"
  do
    echo "$function"
  done

  function_updated=("${function_updated[@]}" "${mod_func_list[@]}")
done


for function_name in "${function_updated[@]}"
do
  test_scripts_found=($(find tests/  -type f -name "test_$function_name*" ! -path "*/__*" -exec echo {} \;))

  if [ ${#test_scripts_found[@]} -gt 0 ]; then
      if [[ ! " ${function_script_paths[*]} " =~ " ${test_scripts_found} " ]]; then
        test_script_paths+=("$test_scripts_found")
      else
        echo "Test script also changed for function: $function_name"
      fi
  else
      echo "No test script for function: $function_name"
  fi

done

test_set=($(printf "%s\n" "${test_script_paths[@]}" | sort -u))

echo -e "Tests to run are: "
for test in ${test_set[@]};
do
  echo $test
done

test_records=()

for test_to_run in "${test_set[@]}"
do 
  echo "Testing: $test_to_run"
  
  echo "====================================================================="
  
  pytest $test_to_run
  
  echo "====================================================================="

  pytest_exit_status=$?

  if [ $pytest_exit_status -eq 0 ]; then
      echo "Test passed"
      test_records+=("$test_to_run : Passed. ")
  else
      echo "Test failed"
      test_records+=("$test_to_run : Failed. ")
  fi
done

for record in "${test_records[@]}";
do
  echo $record
done
