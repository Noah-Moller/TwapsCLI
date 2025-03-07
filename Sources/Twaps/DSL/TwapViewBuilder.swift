import SwiftUI

@resultBuilder
public struct TwapViewBuilder {
    public static func buildBlock<Content: TwapView>(_ content: Content) -> Content {
        content
    }
    
    public static func buildBlock<C1: TwapView, C2: TwapView>(_ c1: C1, _ c2: C2) -> TwapTupleView2<C1, C2> {
        TwapTupleView2(c1, c2)
    }
    
    public static func buildBlock<C1: TwapView, C2: TwapView, C3: TwapView>(_ c1: C1, _ c2: C2, _ c3: C3) -> TwapTupleView3<C1, C2, C3> {
        TwapTupleView3(c1, c2, c3)
    }
    
    public static func buildEither<TrueContent: TwapView, FalseContent: TwapView>(first: TrueContent) -> Either<TrueContent, FalseContent> {
        .first(first)
    }
    
    public static func buildEither<TrueContent: TwapView, FalseContent: TwapView>(second: FalseContent) -> Either<TrueContent, FalseContent> {
        .second(second)
    }
    
    public static func buildOptional<Content: TwapView>(_ content: Content?) -> OptionalContent<Content> {
        OptionalContent(content: content)
    }
    
    public static func buildArray<Content: TwapView>(_ components: [Content]) -> ArrayContent<Content> {
        ArrayContent(content: components)
    }
}

// Helper types for the result builder
public enum Either<First: TwapView, Second: TwapView>: TwapView {
    case first(First)
    case second(Second)
    
    public func toSwiftUI() -> some View {
        switch self {
        case .first(let view):
            view.toSwiftUI()
        case .second(let view):
            view.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        switch self {
        case .first(let view):
            view.toSwiftUICode()
        case .second(let view):
            view.toSwiftUICode()
        }
    }
}

public struct OptionalContent<Content: TwapView>: TwapView {
    let content: Content?
    
    public func toSwiftUI() -> some View {
        if let content = content {
            content.toSwiftUI()
        } else {
            EmptyView()
        }
    }
    
    public func toSwiftUICode() -> String {
        if let content = content {
            return content.toSwiftUICode()
        } else {
            return "EmptyView()"
        }
    }
}

public struct ArrayContent<Content: TwapView>: TwapView {
    let content: [Content]
    
    public func toSwiftUI() -> some View {
        ForEach(0..<content.count, id: \.self) { index in
            content[index].toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        let contentCode = content.map { $0.toSwiftUICode() }.joined(separator: "\n")
        return """
        VStack {
            \(contentCode)
        }
        """
    }
}

// Tuple view for multiple content items
public struct TwapTupleView2<C1: TwapView, C2: TwapView>: TwapView {
    private let item1: C1
    private let item2: C2
    
    public init(_ item1: C1, _ item2: C2) {
        self.item1 = item1
        self.item2 = item2
    }
    
    public func toSwiftUI() -> some View {
        VStack {
            item1.toSwiftUI()
            item2.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        """
        \(item1.toSwiftUICode())
        \(item2.toSwiftUICode())
        """
    }
}

public struct TwapTupleView3<C1: TwapView, C2: TwapView, C3: TwapView>: TwapView {
    private let item1: C1
    private let item2: C2
    private let item3: C3
    
    public init(_ item1: C1, _ item2: C2, _ item3: C3) {
        self.item1 = item1
        self.item2 = item2
        self.item3 = item3
    }
    
    public func toSwiftUI() -> some View {
        VStack {
            item1.toSwiftUI()
            item2.toSwiftUI()
            item3.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        """
        \(item1.toSwiftUICode())
        \(item2.toSwiftUICode())
        \(item3.toSwiftUICode())
        """
    }
} 