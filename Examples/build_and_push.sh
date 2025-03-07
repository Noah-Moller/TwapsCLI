#!/bin/bash

# Build the Twaps framework
echo "Building Twaps framework..."
swift build

# Compile the example Twap
echo "Compiling example Twap..."
swiftc -emit-library -o SimpleTwap.dylib Examples/SimpleTwap.swift -module-name SimpleTwap

# Push the Twap to the server
echo "Pushing Twap to the server..."
# Use the Swift source file directly instead of the dylib and automatically confirm the push
swift run TwapsCLI push Examples/SimpleTwap.swift --url simple.twap --yes

echo "Done!" 