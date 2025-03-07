import SwiftUI

/// The core protocol for all Twap views
public protocol TwapView {
    /// The SwiftUI view type that this Twap view converts to
    associatedtype SwiftUIViewType: View
    
    /// Converts the Twap view to a SwiftUI view
    @ViewBuilder func toSwiftUI() -> SwiftUIViewType
    
    /// Returns a string representation of the SwiftUI code that would render this view
    func toSwiftUICode() -> String
}

/// A type-erased wrapper for any TwapView
public struct AnyTwapView: TwapView {
    private let _toSwiftUI: () -> AnyView
    private let _toSwiftUICode: () -> String
    
    public init<V: TwapView>(_ view: V) {
        self._toSwiftUI = { AnyView(view.toSwiftUI()) }
        self._toSwiftUICode = { view.toSwiftUICode() }
    }
    
    public func toSwiftUI() -> AnyView {
        _toSwiftUI()
    }
    
    public func toSwiftUICode() -> String {
        _toSwiftUICode()
    }
}

/// A container for a Twap module
public struct Twap<Content: TwapView>: TwapView {
    private let content: Content
    private let metadata: TwapMetadata
    
    public init(
        id: String,
        version: String = "1.0.0",
        author: String = "Unknown",
        @TwapViewBuilder content: () -> Content
    ) {
        self.metadata = TwapMetadata(id: id, version: version, author: author)
        self.content = content()
    }
    
    public func toSwiftUI() -> some View {
        content.toSwiftUI()
    }
    
    public func toSwiftUICode() -> String {
        content.toSwiftUICode()
    }
}

/// Metadata for a Twap
public struct TwapMetadata {
    public let id: String
    public let version: String
    public let author: String
    
    public init(id: String, version: String, author: String) {
        self.id = id
        self.version = version
        self.author = author
    }
} 