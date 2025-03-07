import SwiftUI
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

// This code would be used in a real app to compile the Twap
// try Twaps.compile(helloWorldTwap, to: URL(fileURLWithPath: "HelloWorldTwap.dylib"))

// For demonstration purposes, we'll just print the generated code
let metadata = TwapCodeGenerator.extractMetadata(from: helloWorldTwap)
let codeGenerator = TwapCodeGenerator(twap: helloWorldTwap, metadata: metadata)
print(codeGenerator.generateCode()) 