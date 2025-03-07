# Twaps: The Web for Native macOS Apps

Twaps is an experimental framework that brings web-like dynamics to native macOS applications. The name "Twaps" stands for "The Web for Apps" - a vision of enabling dynamic, modular UI components in native Swift applications.

## 🧪 Experimental Project

**Note:** This is an experimental project created to explore the concept of dynamic native UI modules. It is not intended for production use at this stage. The code is shared to inspire discussion and collaboration around the idea of bringing web-like dynamics to native app development.

## 🌟 Vision

The web revolutionized content distribution by allowing dynamic loading of content without requiring application updates. Twaps aims to bring similar capabilities to native macOS applications:

- **Dynamic UI Components**: Load SwiftUI views at runtime without app recompilation
- **Modular Architecture**: Create self-contained UI modules that can be distributed independently
- **Native Performance**: Enjoy the performance and integration benefits of native code
- **Simple Distribution**: Push updates to a server and have clients automatically receive them

## 🏗️ Architecture

The Twaps ecosystem consists of three main components:

1. **TwapsCLI**: A command-line tool for building and publishing Twaps
2. **TwapsServer**: A simple server for hosting and distributing Twaps
3. **TwapsClient**: A macOS app for loading and displaying Twaps

### How It Works

1. Developers create Twaps using Swift and SwiftUI
2. The TwapsCLI compiles Twaps into dynamic libraries
3. Twaps are pushed to the TwapsServer for distribution
4. The TwapsClient loads Twaps from the server and displays them

## 🚀 Getting Started

See the individual repositories for detailed instructions:

- [TwapsCLI](https://github.com/Noah-Moller/TwapsCLI)
- [TwapsServer](https://github.com/Noah-Moller/TwapsServer)
- [TwapsClient](https://github.com/Noah-Moller/TwapsClient)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤔 Limitations and Considerations

- This is a proof of concept and has many limitations
- Dynamic code loading has security implications that should be carefully considered
- The approach relies on Swift ABI stability and may not work across all Swift versions
- Error handling and edge cases are not fully implemented

## 🔮 Future Possibilities

- Support for iOS and other Apple platforms
- Enhanced security model with code signing
- Dependency management for Twaps
- A marketplace for discovering and sharing Twaps

## 🙏 Acknowledgements

Inspired by the web's dynamic content model and the power of SwiftUI.
