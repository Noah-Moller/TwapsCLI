import SwiftUI
import Twaps

@main
struct TwapsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var generatedCode: String = ""
    @State private var isCompiling: Bool = false
    @State private var compilationResult: String = ""
    @State private var twapURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Twaps Framework Demo")
                .font(.largeTitle)
                .bold()
            
            Button("Generate Hello World Twap") {
                generateTwap()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCompiling)
            
            if !generatedCode.isEmpty {
                VStack(alignment: .leading) {
                    Text("Generated Code:")
                        .font(.headline)
                    
                    ScrollView {
                        Text(generatedCode)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                }
                
                Button("Compile Twap") {
                    compileTwap()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isCompiling || generatedCode.isEmpty)
                
                if isCompiling {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                if !compilationResult.isEmpty {
                    Text(compilationResult)
                        .foregroundColor(compilationResult.contains("Error") ? .red : .green)
                        .padding()
                }
                
                if let twapURL = twapURL {
                    Button("Load Twap") {
                        // In a real app, you would load the Twap here
                        print("Loading Twap from: \(twapURL.path)")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCompiling || compilationResult.contains("Error"))
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 600, height: 500)
    }
    
    private func generateTwap() {
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
        generatedCode = codeGenerator.generateCode()
    }
    
    private func compileTwap() {
        guard !generatedCode.isEmpty else { return }
        
        isCompiling = true
        compilationResult = "Compiling..."
        
        DispatchQueue.global().async {
            do {
                // Create a temporary file for the generated code
                let tempDir = FileManager.default.temporaryDirectory
                let sourceFile = tempDir.appendingPathComponent("TwapSource.swift")
                let outputFile = tempDir.appendingPathComponent("HelloWorldTwap.dylib")
                
                // Write the generated code to a file
                try generatedCode.write(to: sourceFile, atomically: true, encoding: .utf8)
                
                // Compile the source code into a dynamic library
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
                
                // Set up the compilation arguments
                process.arguments = [
                    "-emit-library",              // Create a dynamic library
                    "-o", outputFile.path,        // Output path
                    "-module-name", "TwapModule", // Module name
                    sourceFile.path               // Source file
                ]
                
                // Run the compilation process
                try process.run()
                process.waitUntilExit()
                
                // Check if compilation was successful
                if process.terminationStatus == 0 {
                    DispatchQueue.main.async {
                        twapURL = outputFile
                        compilationResult = "Twap compiled successfully to: \(outputFile.path)"
                        isCompiling = false
                    }
                } else {
                    DispatchQueue.main.async {
                        compilationResult = "Error: Compilation failed with exit code \(process.terminationStatus)"
                        isCompiling = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    compilationResult = "Error: \(error.localizedDescription)"
                    isCompiling = false
                }
            }
        }
    }
} 