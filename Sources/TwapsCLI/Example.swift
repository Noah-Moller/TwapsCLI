import Foundation
import Twaps

/// A simple example that demonstrates the Twaps framework
struct Example {
    static func run() {
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
        
        // Create a temporary file for the generated code
        let tempDir = FileManager.default.temporaryDirectory
        let sourceFile = tempDir.appendingPathComponent("TwapSource.swift")
        let outputFile = tempDir.appendingPathComponent("HelloWorldTwap.dylib")
        
        do {
            // Write the generated code to a file
            try generatedCode.write(to: sourceFile, atomically: true, encoding: .utf8)
            print("Generated code written to: \(sourceFile.path)")
            
            // Compile the Twap
            try Twaps.compile(helloWorldTwap, to: outputFile)
            print("Twap compiled successfully to: \(outputFile.path)")
            
            // In a real app, you would now load the Twap using TwapLoader
            print("In a real app, you would now load the Twap using:")
            print("let viewController = try TwapLoader.loadTwap(from: URL(fileURLWithPath: \"\(outputFile.path)\"))")
            print("// Then display the view controller in your app")
        } catch {
            print("Error: \(error)")
        }
    }
} 