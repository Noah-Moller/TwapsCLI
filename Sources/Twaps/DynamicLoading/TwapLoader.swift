import Foundation
import SwiftUI
import AppKit

/// Responsible for dynamically loading Twap binaries
public class TwapLoader {
    /// Error types that can occur during Twap loading
    public enum LoadError: Error {
        case libraryNotFound
        case symbolNotFound
        case invalidHostingController
    }
    
    /// Loads a Twap from a dynamic library at the given path
    /// - Parameter path: The file path to the dynamic library
    /// - Returns: An NSViewController containing the Twap's view
    /// - Throws: LoadError if the Twap cannot be loaded
    public static func loadTwap(from path: URL) throws -> NSViewController {
        // Open the dynamic library
        guard let handle = dlopen(path.path, RTLD_NOW) else {
            throw LoadError.libraryNotFound
        }
        
        defer {
            dlclose(handle)
        }
        
        // Look up the createDynamicView symbol
        guard let createDynamicViewSymbol = dlsym(handle, "createDynamicView") else {
            throw LoadError.symbolNotFound
        }
        
        // Convert the symbol to a function pointer and call it
        typealias CreateDynamicViewFunction = @convention(c) () -> UnsafeMutableRawPointer
        let createDynamicView = unsafeBitCast(createDynamicViewSymbol, to: CreateDynamicViewFunction.self)
        let rawPointer = createDynamicView()
        
        // Convert the raw pointer back to an NSHostingController
        let hostingController = Unmanaged<NSHostingController<AnyView>>.fromOpaque(rawPointer).takeRetainedValue()
        return hostingController
    }
}

/// A SwiftUI view that loads and displays a Twap
public struct TwapHostingView: View {
    private let twapURL: URL
    @State private var viewController: NSViewController?
    @State private var loadError: Error?
    
    public init(twapURL: URL) {
        self.twapURL = twapURL
    }
    
    public var body: some View {
        Group {
            if let viewController = viewController {
                TwapViewControllerRepresentable(viewController: viewController)
            } else if let loadError = loadError {
                VStack {
                    Text("Failed to load Twap")
                        .font(.headline)
                    Text(loadError.localizedDescription)
                        .font(.body)
                }
                .padding()
            } else {
                ProgressView()
                    .onAppear {
                        loadTwap()
                    }
            }
        }
    }
    
    private func loadTwap() {
        DispatchQueue.global().async {
            do {
                let controller = try TwapLoader.loadTwap(from: twapURL)
                DispatchQueue.main.async {
                    self.viewController = controller
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadError = error
                }
            }
        }
    }
}

/// A SwiftUI wrapper for NSViewController
struct TwapViewControllerRepresentable: NSViewControllerRepresentable {
    let viewController: NSViewController
    
    func makeNSViewController(context: NSViewControllerRepresentableContext<TwapViewControllerRepresentable>) -> NSViewController {
        viewController
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: NSViewControllerRepresentableContext<TwapViewControllerRepresentable>) {
        // No updates needed
    }
} 