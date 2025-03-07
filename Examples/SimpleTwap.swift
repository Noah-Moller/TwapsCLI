import SwiftUI
import AppKit

@_cdecl("createDynamicView")
public func createDynamicView() -> UnsafeMutableRawPointer {
    let view = AnyView(
        VStack {
            Text("Hello from Twaps!")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("This view was dynamically loaded from a Twap.")
                .font(.title2)
                .padding()
            
            Button("Click Me") {
                print("Button clicked!")
                
                // Create an alert
                let alert = NSAlert()
                alert.messageText = "Button Clicked"
                alert.informativeText = "You clicked the button in a dynamically loaded Twap!"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Twaps Framework Demo")
                .font(.caption)
                .padding(.top, 20)
        }
        .padding(30)
        .frame(width: 400, height: 300)
    )
    
    let hostingController = NSHostingController(rootView: view)
    return Unmanaged.passRetained(hostingController).toOpaque()
}

// Dummy global to force the export of createDynamicView.
public let __forceExport_createDynamicView: Void = {
    _ = createDynamicView
}() 