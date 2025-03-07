# Product Requirements Document (PRD) for the Twaps Framework

**Product:** Twaps Framework  
**Platform:** macOS (Swift)  
**Version:** 0.1 (Initial Prototype)  
**Prepared by:** Noah Moller 
**Date:** 7th of March 2025

---

## 1. Overview

The Twaps Framework is a Swift-based library that provides a declarative DSL—modeled after SwiftUI—for building "Twaps": self-contained, dynamic native macOS UI modules. These modules are compiled into deployable binaries (e.g., dynamic libraries) that can be uploaded to a central Twaps index and dynamically loaded by client apps, effectively creating "the web for native macOS apps."

---

## 2. Problem Statement & Objectives

### Problem Statement
Native macOS apps lack an equivalent to the web’s dynamic content model, where content (HTML/JS) is modular and dynamically loaded. Developers need a way to create modular, updateable UI components that are compiled natively and can be distributed and dynamically loaded at runtime.

### Objectives
- **DSL API:** Provide a Swift DSL, similar in syntax to SwiftUI, to define Twap content.
- **Compile-Time Code Generation:** Automatically transform DSL definitions into Swift source code that exposes a standardized entry point (e.g., a function named `createDynamicView`).
- **Dynamic Loading:** Ensure that the generated binary (dylib) can be dynamically loaded by client applications.
- **Developer Experience:** Create a user-friendly workflow that allows developers to author Twaps with minimal boilerplate.
- **Seamless Deployment:** Integrate with a CLI tool that packages the compiled binary for upload to the Twaps index.

---

## 3. Target Audience

- **Native macOS Developers:** Developers building macOS apps seeking modular, dynamic UI components.
- **Content Creators:** Individuals or teams who want to design dynamic native UI modules without extensive web infrastructure.
- **Enterprise & Indie Developers:** Those who require updateable UI components that can be deployed separately from the main application.

---

## 4. Product Scope

### In-Scope Features
- **Declarative DSL Syntax:**  
  - A set of view types and layout containers inspired by SwiftUI.
  - Support for common UI components (e.g., Text, Button, VStack, HStack).
- **Compile-Time Code Generation:**  
  - Use a code generation mechanism (e.g., Sourcery or Swift macros) to produce a Swift source file from the Twap DSL.
  - The generated source must include a function (e.g., `createDynamicView`) marked with `@_cdecl("createDynamicView")` that returns an `UnsafeMutableRawPointer` to an NSHostingController wrapping the dynamic view.
- **Binary Packaging:**  
  - Integration with a CLI tool to compile the generated Swift source into a dynamic library (dylib).
  - Ensure the binary exports the standardized entry point for dynamic loading.
- **Dynamic Loading API:**  
  - A standardized mechanism for client apps to load and display Twaps at runtime.

### Out-of-Scope
- Networking and the central Twaps index server (handled by another component).
- Support for platforms other than macOS (initially).

---

## 5. Functional Requirements

1. **DSL API:**  
   - Provide a Swift DSL with view builders and modifiers similar to SwiftUI.
   - Allow developers to declare UI components (e.g., title, text, buttons) for a Twap.

2. **Code Generation:**  
   - Implement a code generation pipeline (using Sourcery or Swift macros) that converts DSL definitions into a Swift source string or file.
   - Ensure the generated code includes a function with the signature:
     ```swift
     @_cdecl("createDynamicView")
     public func createDynamicView() -> UnsafeMutableRawPointer { ... }
     ```
3. **Packaging and Compilation:**  
   - Include a CLI tool or build script that compiles the generated Swift source into a dynamic library.
   - Handle unique naming or versioning to avoid caching issues with dynamic libraries.
   - Ensure proper code signing and symbol export.

4. **Dynamic Loading:**  
   - Expose a standardized entry point for client apps to load the Twap dynamically (e.g., using dlopen/dlsym).
   - Provide clear error handling if dynamic loading fails.

5. **Developer Workflow:**  
   - Offer documentation and examples that demonstrate how to use the DSL.
   - Provide tooling that integrates with Xcode and the Swift Package Manager.
   - Generate useful diagnostics and error messages during the code generation process.

---

## 6. Non-Functional Requirements

- **Performance:**  
  - Code generation and dynamic loading should add minimal overhead.
  - The generated UI should render smoothly on macOS.
  
- **Usability:**  
  - The DSL must feel intuitive to SwiftUI developers.
  - Generated code should be clear and maintainable.

- **Extensibility:**  
  - The framework should allow easy addition of new UI components or modifiers.
  - The code generation system should be modular and adaptable.

- **Security:**  
  - Generated binaries must be code-signed and meet macOS security requirements.
  - The framework should limit exposure of unsafe APIs.

- **Maintainability:**  
  - The code generation templates or macros must be well-documented.
  - The project should be organized as a Swift Package with clear separation of concerns.

---

## 7. User Stories / Use Cases

- **Story 1: Building a Twap**  
  *As a developer, I want to use a Swift DSL similar to SwiftUI to define a Twap so that I can quickly create dynamic native UI modules.*

- **Story 2: Generating a Binary**  
  *As a developer, I want my Twap DSL to generate a Swift source file at compile time that defines a standardized entry point, so I can compile it into a dynamic library.*

- **Story 3: Dynamic Loading**  
  *As a developer, I want a consistent API for loading my Twap binary dynamically so that client apps can integrate it seamlessly.*

- **Story 4: Developer Feedback**  
  *As a developer, I need clear error messages and diagnostics during code generation and compilation to help me debug issues quickly.*

---

## 8. Technical Approach

- **Language & Tools:**  
  - Swift 5.x and macOS.
  - Swift Package Manager for dependency management.
  - Sourcery for code generation, with a future goal to integrate Swift macros when stable.
  
- **Architecture:**  
  - **DSL Layer:** Swift types and protocols that mimic SwiftUI’s view builders.
  - **Code Generation Layer:** Templates (using Sourcery) or macros that transform DSL definitions into a Swift source file.
  - **Packaging Layer:** A CLI tool or build script that compiles the generated code into a dynamic library.
  - **Export Mechanism:** A standardized exported symbol (e.g., `createDynamicView`) for dynamic loading by client apps.

- **Build & Deployment:**  
  - Automate code generation and compilation through build scripts.
  - Generate unique filenames for dynamic libraries to avoid caching issues.
  - Ensure the binaries are correctly code-signed.

---

## 9. Milestones & Timeline

- **Phase 1 (4-6 Weeks):**  
  - Define the DSL syntax and implement core view components.
  - Develop initial prototypes and sample Twaps.

- **Phase 2 (6-8 Weeks):**  
  - Implement the code generation pipeline using Sourcery (or macros).
  - Develop the CLI tool for compiling Twaps.

- **Phase 3 (4 Weeks):**  
  - Integrate dynamic loading into a sample client app.
  - Refine error handling, documentation, and developer feedback.

- **Phase 4 (Ongoing):**  
  - Gather developer feedback and iterate on the framework.
  - Expand the DSL with additional UI components and modifiers.

---

## 10. Risks and Mitigations

- **Toolchain Limitations:**  
  - *Risk:* Swift macros may not be fully stable.  
  - *Mitigation:* Use Sourcery initially.

- **Complex Code Generation:**  
  - *Risk:* The DSL might become too complex for reliable code generation.  
  - *Mitigation:* Start with a limited set of core components and iterate.

- **Dynamic Loading Challenges:**  
  - *Risk:* Issues with code signing and library caching.  
  - *Mitigation:* Use unique library names per build and robust error handling.

- **Adoption:**  
  - *Risk:* The DSL may be too different from SwiftUI for developers to adopt.  
  - *Mitigation:* Provide clear documentation, examples, and community support.

---

## 11. Success Metrics

- **Developer Adoption:**  
  - Number of downloads and integrations of the Twaps Framework.
  - Feedback from early adopters regarding ease of use and functionality.

- **Performance Benchmarks:**  
  - Speed of code generation and dynamic library compilation.
  - Runtime performance and smooth rendering of dynamic views.

- **Quality of Output:**  
  - Clarity and correctness of generated Swift source code.
  - Reliability of dynamic loading and integration with client apps.

---

## 12. Conclusion

The Twaps Framework will empower macOS developers to create dynamic, web-like native UI modules using a SwiftUI-inspired DSL. By leveraging compile-time code generation and a standardized dynamic loading mechanism, the framework will enable modular and updateable UI components that can be distributed and loaded on demand. The initial focus is on core functionality and a smooth developer experience, with plans for iterative improvement based on community feedback.

---