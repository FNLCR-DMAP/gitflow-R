#!/bin/sh -l

cd "$1"

last_commit="$2"

current_dir="$1"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Checking latest push to $current_branch\n"

echo "Latest commit hash is $last_commit\n"

current_test_paths=($(find tests/ -name "*.py" | grep -v "__init__.py"))

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

current_function_paths=($(find src/spac/ -name "*.py" | grep -v "__init__.py"))

function_scripts=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'src/spac/' | sed 's:.*/::' | \
                grep -v "__init__.py" | grep -iE '*.py$'))

function_script_paths=($(git diff "$last_commit" HEAD \
                --name-only $current_branch | \
                grep -E 'src/spac/' | grep -v "__init__.py" \
                | grep -iE '*.py$'))

echo -e "\nFunction script changed: \n${function_scripts[*]}\n"

function_updated=()

for script in "${function_script_paths[@]}"
do
  mod_func_list=($(grep -E '^def\s+\w+\(' $script | cut -d ' ' -f 2 | cut -d '(' -f 1))
  echo -e "\nFunction changed in $script:"

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
        echo -e "\nTest script also changed for function: $function_name\n"
      fi
  else
      echo -e "\nNo test script for function: $function_name\n"
  fi

done

test_set=($(printf "%s\n" "${test_script_paths[@]}" | sort -u))

echo -e "\nExisting Test Files to Run are: "

# Create a new array to store the updated values
updated_test_paths=()

# Iterate over the current_test_paths array
for test in "${test_set[@]}"; do
    # Check if the item is present in the allowed_paths array
    found=false
    for existing_test in "${current_test_paths[@]}"; do
        if [ "$test" = "$existing_test" ]; then
            found=true
            break
        fi
    done

    # Add the item to the updated_test_paths array if it's present in the allowed_paths array
    if [ "$found" = true ]; then
        updated_test_paths+=("$test")
        echo "$test"
    fi
done

# Assign the updated array back to the original array
test_set=("${updated_test_paths[@]}")


test_records=()

for test_to_run in "${test_set[@]}"
do 
  echo -e "\nTesting: $test_to_run"
  
  echo "====================================================================="
  
  pytest $test_to_run
  
  echo "====================================================================="

  pytest_exit_status=$?

  if [ $pytest_exit_status -eq 0 ]; then
      echo -e "\nTest passed\n"
      test_records+=("$test_to_run : Passed. ")
  else
      echo -e "\nTest failed\n"
      test_records+=("$test_to_run : Failed. ")
  fi
done

echo -e "\n\nTseting Finished!"

for record in "${test_records[@]}";
do
  echo $record
done
