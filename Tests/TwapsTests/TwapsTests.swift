import XCTest
import SwiftUI
@testable import Twaps

final class TwapsTests: XCTestCase {
    func testTwapTextToSwiftUICode() {
        let text = TwapText("Hello, World!")
            .bold()
            .italic()
            .font(.title)
        
        let code = text.toSwiftUICode()
        XCTAssertTrue(code.contains("Text(\"Hello, World!\")"))
        XCTAssertTrue(code.contains(".bold()"))
        XCTAssertTrue(code.contains(".italic()"))
        XCTAssertTrue(code.contains(".font("))
    }
    
    func testTwapVStackToSwiftUICode() {
        let stack = TwapVStack {
            TwapText("Hello")
        }
        
        let code = stack.toSwiftUICode()
        XCTAssertTrue(code.contains("VStack"))
        XCTAssertTrue(code.contains("Text(\"Hello\")"))
    }
    
    func testTwapCodeGeneration() {
        let twap = Twap(
            id: "com.example.test",
            version: "1.0.0",
            author: "Test Author"
        ) {
            TwapVStack {
                TwapText("Hello, World!")
            }
        }
        
        let metadata = TwapCodeGenerator.extractMetadata(from: twap)
        XCTAssertEqual(metadata.id, "com.example.test")
        XCTAssertEqual(metadata.version, "1.0.0")
        XCTAssertEqual(metadata.author, "Test Author")
        
        let codeGenerator = TwapCodeGenerator(twap: twap, metadata: metadata)
        let code = codeGenerator.generateCode()
        
        XCTAssertTrue(code.contains("import SwiftUI"))
        XCTAssertTrue(code.contains("@_cdecl(\"createDynamicView\")"))
        XCTAssertTrue(code.contains("struct TwapView: View"))
        XCTAssertTrue(code.contains("Text(\"Hello, World!\")"))
    }
} 