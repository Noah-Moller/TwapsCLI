import Foundation
import SwiftUI

/// Responsible for generating Swift code from a Twap definition
public class TwapCodeGenerator {
    private let twap: any TwapView
    private let metadata: TwapMetadata
    
    public init(twap: any TwapView, metadata: TwapMetadata) {
        self.twap = twap
        self.metadata = metadata
    }
    
    /// Generates the Swift source code for the Twap
    public func generateCode() -> String {
        """
        // Generated by Twaps Framework
        // Twap ID: \(metadata.id)
        // Version: \(metadata.version)
        // Author: \(metadata.author)
        
        import SwiftUI
        
        // MARK: - Twap View
        
        struct TwapView: View {
            var body: some View {
                \(twap.toSwiftUICode())
            }
        }
        
        // MARK: - Dynamic Loading Entry Point
        
        @_cdecl("createDynamicView")
        public func createDynamicView() -> UnsafeMutableRawPointer {
            let view = TwapView()
            let hostingController = NSHostingController(rootView: view)
            return Unmanaged.passRetained(hostingController).toOpaque()
        }
        """
    }
    
    /// Writes the generated code to a file
    public func writeToFile(at path: URL) throws {
        let code = generateCode()
        try code.write(to: path, atomically: true, encoding: .utf8)
    }
}

/// Extension to extract metadata from a Twap
extension TwapCodeGenerator {
    public static func extractMetadata<Content: TwapView>(from twap: Twap<Content>) -> TwapMetadata {
        // This is a workaround since we can't directly access the private metadata property
        // In a real implementation, we might want to redesign this to make metadata more accessible
        let mirror = Mirror(reflecting: twap)
        for child in mirror.children {
            if let metadata = child.value as? TwapMetadata {
                return metadata
            }
        }
        
        // Fallback to a default metadata if we can't extract it
        return TwapMetadata(id: "unknown", version: "1.0.0", author: "Unknown")
    }
} 