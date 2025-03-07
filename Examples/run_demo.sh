#!/bin/bash

# Build the Twaps framework
echo "Building Twaps framework..."
swift build

# Run the demo app
echo "Running demo app..."
swift run -Xswiftc -I.build/debug -Xlinker -L.build/debug Examples/TwapsDemo/main.swift 