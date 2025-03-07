import SwiftUI

// MARK: - Text View

public struct TwapText: TwapView {
    private let text: String
    private var font: Font?
    private var foregroundColor: Color?
    private var isBold: Bool = false
    private var isItalic: Bool = false
    
    public init(_ text: String) {
        self.text = text
    }
    
    public func toSwiftUI() -> some View {
        var view = Text(text)
        
        if let font = font {
            view = view.font(font)
        }
        
        if let foregroundColor = foregroundColor {
            view = view.foregroundColor(foregroundColor)
        }
        
        if isBold {
            view = view.bold()
        }
        
        if isItalic {
            view = view.italic()
        }
        
        return view
    }
    
    public func toSwiftUICode() -> String {
        var code = "Text(\"\(text)\")"
        
        if let font = font {
            code += ".font(.\(fontToString(font)))"
        }
        
        if let foregroundColor = foregroundColor {
            code += ".foregroundColor(\(colorToString(foregroundColor)))"
        }
        
        if isBold {
            code += ".bold()"
        }
        
        if isItalic {
            code += ".italic()"
        }
        
        return code
    }
    
    // Helper methods for code generation
    private func fontToString(_ font: Font) -> String {
        // This is a simplified implementation
        return "body"
    }
    
    private func colorToString(_ color: Color) -> String {
        // This is a simplified implementation
        return ".primary"
    }
}

// MARK: - Text Modifiers

extension TwapText {
    public func font(_ font: Font) -> TwapText {
        var copy = self
        copy.font = font
        return copy
    }
    
    public func foregroundColor(_ color: Color) -> TwapText {
        var copy = self
        copy.foregroundColor = color
        return copy
    }
    
    public func bold() -> TwapText {
        var copy = self
        copy.isBold = true
        return copy
    }
    
    public func italic() -> TwapText {
        var copy = self
        copy.isItalic = true
        return copy
    }
}

// MARK: - Button View

public struct TwapButton<Label: TwapView>: TwapView {
    private let label: Label
    private let action: () -> Void
    
    public init(action: @escaping () -> Void, @TwapViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public func toSwiftUI() -> some View {
        Button(action: action) {
            label.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        """
        Button(action: {
            // Action code would be here
        }) {
            \(label.toSwiftUICode())
        }
        """
    }
}

// MARK: - Stack Views

public struct TwapVStack<Content: TwapView>: TwapView {
    private let content: Content
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @TwapViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public func toSwiftUI() -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            content.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        let spacingCode = spacing != nil ? ", spacing: \(spacing!)" : ""
        return """
        VStack(alignment: .\(alignmentToString(alignment))\(spacingCode)) {
            \(content.toSwiftUICode())
        }
        """
    }
    
    private func alignmentToString(_ alignment: HorizontalAlignment) -> String {
        switch alignment {
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        default:
            return "center"
        }
    }
}

public struct TwapHStack<Content: TwapView>: TwapView {
    private let content: Content
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @TwapViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public func toSwiftUI() -> some View {
        HStack(alignment: alignment, spacing: spacing) {
            content.toSwiftUI()
        }
    }
    
    public func toSwiftUICode() -> String {
        let spacingCode = spacing != nil ? ", spacing: \(spacing!)" : ""
        return """
        HStack(alignment: .\(alignmentToString(alignment))\(spacingCode)) {
            \(content.toSwiftUICode())
        }
        """
    }
    
    private func alignmentToString(_ alignment: VerticalAlignment) -> String {
        switch alignment {
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        default:
            return "center"
        }
    }
} 