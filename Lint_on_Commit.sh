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

current_python_scripts_paths=($(find tests/ src/spac/ -type f -name "*.py" | grep -v "__init__.py"))

Lint_list=( "${test_scripts[@]}" "${function_scripts[@]}" )

echo -e "\nExisting Files to Lint are: "

# Create a new array to store the updated values
updated_lint_paths=()

# Iterate over the current_test_paths array
for lint in "${Lint_list[@]}"; do
    # Check if the item is present in the allowed_paths array
    found=false
    for existing_file in "${current_python_scripts_paths[@]}"; do
        if [ "$lint" = "$existing_file" ]; then
            found=true
            break
        fi
    done

    # Add the item to the updated_test_paths array if it's present in the allowed_paths array
    if [ "$found" = true ]; then
        updated_lint_paths+=("$lint")
        echo "$lint"
    fi
done

# Assign the updated array back to the original array
Lint_list=("${updated_lint_paths[@]}")



echo -e "Lint to run as: \n${Lint_list[*]}\n"

for test_to_run in "${Lint_list[@]}"
do   
  echo "====================================================================="
  echo "Linting: $test_to_run"
  flake8 $test_to_run
  echo "Finished."
  echo "====================================================================="
done


