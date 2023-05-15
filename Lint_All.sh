#!/bin/sh -l

all_python_scripts=($(find ./ \( -path "*/tests/*" -o -path "*/src/*" \) \
                      -type f \
                      -name "*.py" \
                      ! -name "*__*"))

echo -e "\Lints to run are: "
for lint in ${all_python_scripts[@]};
do
  echo $lint
done


for lint in "${all_python_scripts[@]}"
do   
  echo "====================================================================="
  echo "Linting: $lint"
  flake8 $lint
  echo "Done."
  echo "====================================================================="
done


