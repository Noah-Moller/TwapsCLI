#!/bin/bash

# Build the Twaps framework
echo "Building Twaps framework..."
swift build

# Run the CLI tool
echo "Running CLI tool..."
swift run TwapsCLI version

# Create a simple Swift script that uses the Twaps framework
echo "Creating a simple example script..."
cat > example.swift << 'EOF'
import Foundation
import Twaps

// Define a simple Hello World Twap
let helloWorldTwap = Twap(
    id: "com.example.helloworld",
    version: "1.0.0",
    author: "Twaps Framework"
) {
    TwapVStack {
        TwapText("Hello, World!")
            .font(.largeTitle)
            .bold()
        
        TwapText("This is a sample Twap")
            .font(.body)
            .italic()
        
        TwapButton(action: {
            print("Button tapped!")
        }) {
            TwapText("Tap Me")
                .bold()
        }
    }
}

// Generate the code
let metadata = TwapCodeGenerator.extractMetadata(from: helloWorldTwap)
let codeGenerator = TwapCodeGenerator(twap: helloWorldTwap, metadata: metadata)
let generatedCode = codeGenerator.generateCode()

// Print the generated code
print("Generated Swift Code:")
print("-------------------")
print(generatedCode)
print("-------------------")
EOF

# Run the example script
echo "Running the example script..."
swift -I.build/debug -L.build/debug -lTwaps example.swift

# Clean up
rm example.swift 