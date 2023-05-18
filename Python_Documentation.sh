#!/bin/bash

mkdir docs/
cd docs/
theme="sphinx_rtd_theme"


echo "Parsing pyproject.toml..."
raw_author_array=()
counter=0
while IFS= read -r line && [ $counter -lt 8 ]; do
  raw_author_array+=("$line")
  ((counter++))
done < ../pyproject.toml

name=$(echo "${raw_author_array[1]}" | cut -d '=' -f 2)
name=${name//\"/}
name=${name//, /,}
echo $name

version=$(echo "${raw_author_array[2]}" | cut -d '=' -f 2)
version=${version//\"/}
version=${version//, /,}
echo $version

authors=$(echo "${raw_author_array[4]}" | cut -d '=' -f 2)
authors=$(echo "$authors" | sed 's/^ \+\[//')
authors=${authors%\]}
authors=${authors//\"/}
authors=$(echo "$authors")
echo $authors

echo "Running Quickstart..."

sphinx-quickstart -q --sep \
	--ext-autodo \
	--makefile \
	-p="$name" \
	-a="$authors" \
	-v="$version" \
	-r="" \
	-l="en";

echo "Quickstart Configured..."


echo "Updating Configuration..."

echo "import os" >> source/conf.py
echo "import os" >> source/conf.py
echo "import sys" >> source/conf.py
echo "path = os.path.abspath('../../src')" >> source/conf.py
echo "sys.path.insert(0,path)" >> source/conf.py



sed -i "s/^html_theme = .*/html_theme = \"$theme\"/" source/conf.py

sed -i '/:caption: Contents:/a \\n\tmodules' source/index.rst

echo "Updating documentation..."
sphinx-apidoc -f -o source ../src/spac

echo "Generating html now..."
make html

cp docs/build/html/* .