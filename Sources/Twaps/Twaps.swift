import Foundation
import SwiftUI

/// The Twaps framework provides a declarative DSL for building dynamic native macOS UI modules.
public enum Twaps {
    /// The current version of the Twaps framework
    public static let version = "0.1.0"
    
    /// Compiles a Twap into a dynamic library
    /// - Parameters:
    ///   - twap: The Twap to compile
    ///   - outputPath: The path where the dynamic library should be saved
    /// - Throws: An error if compilation fails
    public static func compile<Content: TwapView>(
        _ twap: Twap<Content>,
        to outputPath: URL
    ) throws {
        // Extract metadata from the Twap
        let metadata = TwapCodeGenerator.extractMetadata(from: twap)
        
        // Generate the Swift code
        let codeGenerator = TwapCodeGenerator(twap: twap, metadata: metadata)
        let sourceCode = codeGenerator.generateCode()
        
        // Create a temporary directory for the build
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        // Write the source code to a file
        let sourceFile = tempDir.appendingPathComponent("TwapSource.swift")
        try sourceCode.write(to: sourceFile, atomically: true, encoding: .utf8)
        
        // Compile the source code into a dynamic library
        try compileSwiftSource(at: sourceFile, to: outputPath)
    }
    
    /// Compiles Swift source code into a dynamic library
    private static func compileSwiftSource(at sourcePath: URL, to outputPath: URL) throws {
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
    
    /// Publishes a Twap to a server
    /// - Parameters:
    ///   - twap: The Twap to publish
    ///   - sourceCode: The Swift source code of the Twap
    ///   - url: The URL where the Twap will be accessible
    ///   - serverURL: The URL of the server to publish to
    ///   - completion: A completion handler that will be called when the operation completes
    public static func publish<Content: TwapView>(
        _ twap: Twap<Content>,
        sourceCode: String,
        url: String,
        to serverURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Extract metadata from the Twap
        let metadata = TwapCodeGenerator.extractMetadata(from: twap)
        
        // Prepare the Twap for publishing
        let serverTwap = TwapPublisher.prepareTwap(sourceCode: sourceCode, url: url, id: metadata.id)
        
        // Publish the Twap
        TwapPublisher.publishTwap(twap: serverTwap, to: serverURL, completion: completion)
    }
} 