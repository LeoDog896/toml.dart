#!/bin/bash

# This script is used by the CI pipeline to execute this example.

# Run the `bin/example.dart` script and remember output.
output=$(dart pub run example)
echo "$output"

# Compare output with expected output.
if [[ "$output" != "Hello, World!" ]]; then
  exit 1
fi
