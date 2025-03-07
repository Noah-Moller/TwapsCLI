import Foundation
import ArgumentParser
import Twaps

/**
 * TwapsCLI - Command-line interface for the Twaps framework
 *
 * This CLI tool provides commands for building, managing, and publishing Twaps.
 * Twaps are self-contained, dynamic native macOS UI modules that can be
 * loaded at runtime by client applications.
 */
struct TwapsCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "twaps",
        abstract: "A tool for building and managing Twaps",
        subcommands: [
            Build.self,
            Version.self,
            ExampleCommand.self,
            Push.self
        ]
    )
    
    /**
     * Build Command
     *
     * Compiles a Swift source file containing a Twap definition into a dynamic library (.dylib).
     * The dynamic library can then be loaded by client applications at runtime.
     */
    struct Build: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "build",
            abstract: "Build a Twap from a Swift source file"
        )
        
        /// The path to the Swift source file containing the Twap definition
        @Argument(help: "The path to the Swift source file containing the Twap definition")
        var inputPath: String
        
        /// Optional output path for the compiled Twap
        @Option(name: .shortAndLong, help: "The path where the compiled Twap should be saved")
        var output: String?
        
        /**
         * Run the build command
         *
         * This method:
         * 1. Determines the output path for the compiled Twap
         * 2. Compiles the Swift source file into a dynamic library
         * 3. Reports success or failure
         */
        func run() throws {
            let inputURL = URL(fileURLWithPath: inputPath)
            
            // Determine the output path
            let outputURL: URL
            if let output = output {
                outputURL = URL(fileURLWithPath: output)
            } else {
                // Default to the same directory as the input file, but with a .dylib extension
                outputURL = inputURL.deletingPathExtension().appendingPathExtension("dylib")
            }
            
            print("Building Twap from \(inputURL.path)")
            print("Output will be saved to \(outputURL.path)")
            
            // Compile the Twap source file
            try compileTwapSource(at: inputURL, to: outputURL)
            
            print("Successfully built Twap!")
        }
        
        /**
         * Compile a Swift source file into a dynamic library
         *
         * Uses the Swift compiler (swiftc) to compile the source file into a dynamic library.
         * The dynamic library will export the createDynamicView function that client apps can call.
         *
         * - Parameters:
         *   - sourcePath: The path to the Swift source file
         *   - outputPath: The path where the compiled dynamic library should be saved
         */
        private func compileTwapSource(at sourcePath: URL, to outputPath: URL) throws {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
            
            // Set up the compilation arguments
            process.arguments = [
                "-emit-library",              // Create a dynamic library
                "-o", outputPath.path,        // Output path
                "-module-name", "TwapModule", // Module name
                sourcePath.path               // Source file
            ]
            
            // Run the compilation process
            try process.run()
            process.waitUntilExit()
            
            // Check if compilation was successful
            if process.terminationStatus != 0 {
                throw NSError(
                    domain: "com.twaps.compiler",
                    code: Int(process.terminationStatus),
                    userInfo: [NSLocalizedDescriptionKey: "Failed to compile Twap"]
                )
            }
        }
    }
    
    /**
     * Version Command
     *
     * Prints the current version of the Twaps framework.
     */
    struct Version: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "version",
            abstract: "Print the version of the Twaps framework"
        )
        
        func run() {
            print("Twaps Framework v\(Twaps.version)")
        }
    }
    
    /**
     * Example Command
     *
     * Runs a simple example that demonstrates the Twaps framework.
     * This is useful for users to understand how to create and use Twaps.
     */
    struct ExampleCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "example",
            abstract: "Run a simple example that demonstrates the Twaps framework"
        )
        
        func run() {
            Example.run()
        }
    }
    
    /**
     * Push Command
     *
     * Pushes a Twap to the server for distribution.
     * This command can handle both Swift source files and compiled dynamic libraries.
     * If a dynamic library is provided, the user will be prompted for the original source file.
     */
    struct Push: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "push",
            abstract: "Push a Twap to the server"
        )
        
        /// The path to the Twap file (either a .swift source file or a .dylib compiled file)
        @Argument(help: "The path to the compiled Twap (.dylib file) or Swift source file")
        var twapPath: String
        
        /// Optional custom URL for the Twap (defaults to the filename with .twap extension)
        @Option(name: .shortAndLong, help: "The URL where the Twap will be accessible")
        var url: String?
        
        /// The server URL to push the Twap to (defaults to localhost)
        @Option(name: .shortAndLong, help: "The server URL to push the Twap to")
        var server: String = "http://localhost:8080/twap"
        
        /// Flag to automatically confirm the push without prompting
        @Flag(name: .shortAndLong, help: "Automatically confirm the push without prompting")
        var yes: Bool = false
        
        /**
         * Run the push command
         *
         * This method:
         * 1. Validates the input file
         * 2. Reads the source code (either directly or by prompting for the source file)
         * 3. Prepares the Twap for publishing
         * 4. Confirms with the user (unless --yes flag is used)
         * 5. Publishes the Twap to the server
         */
        func run() throws {
            let twapURL = URL(fileURLWithPath: twapPath)
            
            // Check if the file exists
            guard FileManager.default.fileExists(atPath: twapURL.path) else {
                throw ValidationError("File not found at path: \(twapURL.path)")
            }
            
            // Determine the URL for the Twap
            // If no URL is provided, use the filename with .twap extension
            let twapPublicURL = url ?? twapURL.lastPathComponent.replacingOccurrences(of: ".swift", with: ".twap").replacingOccurrences(of: ".dylib", with: ".twap")
            
            // Read the source code
            let sourceCode: String
            
            // Check if the file is a Swift source file or a dylib
            if twapURL.pathExtension.lowercased() == "swift" {
                // Read the Swift source file directly
                do {
                    sourceCode = try String(contentsOf: twapURL, encoding: .utf8)
                } catch {
                    throw ValidationError("Failed to read Swift source file: \(error.localizedDescription)")
                }
            } else {
                // For dylib files, we need to prompt for the source
                print("Please provide the path to the original Swift source file:")
                guard let sourcePath = readLine(), !sourcePath.isEmpty else {
                    throw ValidationError("No source path provided")
                }
                
                let sourceURL = URL(fileURLWithPath: sourcePath)
                guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                    throw ValidationError("Source file not found at path: \(sourceURL.path)")
                }
                
                do {
                    sourceCode = try String(contentsOf: sourceURL, encoding: .utf8)
                } catch {
                    throw ValidationError("Failed to read Swift source file: \(error.localizedDescription)")
                }
            }
            
            // Prepare the Twap for publishing
            // This converts the source code to the format expected by the server
            let serverTwap = TwapPublisher.prepareTwap(sourceCode: sourceCode, url: twapPublicURL)
            
            // Convert the Twap to JSON for display
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let jsonData = try encoder.encode(serverTwap)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            
            print("Twap JSON:")
            print(jsonString)
            
            // Check if we should automatically confirm the push
            let shouldPush: Bool
            if yes {
                shouldPush = true
            } else {
                print("\nWould you like to push this Twap to the server? (y/n)")
                let pushResponse = readLine()?.lowercased() ?? "n"
                shouldPush = pushResponse == "y"
            }
            
            if shouldPush {
                // Create a semaphore to wait for the network request to complete
                // This is necessary because the publishTwap method is asynchronous
                let semaphore = DispatchSemaphore(value: 0)
                var publishError: Error?
                
                // Publish the Twap
                TwapPublisher.publishTwap(twap: serverTwap, to: server) { result in
                    switch result {
                    case .success:
                        print("Successfully pushed Twap to server!")
                        print("Your Twap is now available at: \(twapPublicURL)")
                        print("You can access it in the TwapsClient app by entering: \(twapPublicURL)")
                    case .failure(let error):
                        publishError = error
                    }
                    semaphore.signal()
                }
                
                // Wait for the network request to complete
                _ = semaphore.wait(timeout: .distantFuture)
                
                // Check for errors
                if let error = publishError {
                    throw error
                }
            } else {
                print("Twap push cancelled")
            }
        }
    }
}

/**
 * ServerTwap
 *
 * A struct that matches the server's expected format for a Twap.
 * This is used for encoding/decoding Twaps when communicating with the server.
 */
struct ServerTwap: Codable {
    /// The source code of the Twap (with newlines escaped)
    let source: String
    
    /// A unique identifier for the Twap
    let id: String
    
    /// The URL where the Twap will be accessible
    let url: String
}

// Start the CLI
TwapsCLI.main() 