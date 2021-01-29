#!/bin/bash

# This script compiles all examples in the `example` directory that have a
# `web` subdirectory using `webdev build`.

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `test-web.dart` file.
examples_dir="$root_dir/example"
for example in $(find "$examples_dir" -name pubspec.yaml); do
  example_dir=$(dirname "$example")
  example_name=$(basename "$example_dir")

  # Change into the example's root directory.
  cd "$example_dir"

  # Compile example if it is a web example.
  if [ -d "web" ]; then
    echo "Building '$example_name' example..."
    if ! webdev build; then
      echo "------------------------------------------------------------------"
      echo "Error when building '$example_name' example!" >&2
      exit 1
    fi
  fi
done

echo "========================================================================"
echo "Built all web examples successfully!"
