# NovaClean 🧹 ✨

NovaClean is a fully-functional modern, lightweight, and high-performance system cleaning utility designed exclusively for macOS. Built with **SwiftUI**, it offers a premium glassmorphic interface to keep your Mac lean, fast, and free of unnecessary junk.

## 🚀 Key Features

- **Deep System Scan**: Identifies cache files, logs, and temporary data using a high-speed streaming engine.
- **Smart Junk Definitions**: Powered by an external JSON-based architecture for safe and precise file identification.
- **Dynamic Theming**: Fully responsive Light and Dark modes with custom-tailored color palettes and glassmorphic cards.
- **Safe-by-Design**: Implements Path Sanitization to protect critical system directories.
- **Localization**: Implements localization. English and Spanish so far.

## 🏗 Architecture & Technology

NovaClean follows the **MVVM (Model-View-ViewModel)** architectural pattern, ensuring a clean (architecture) separation of concerns:

- **View Layer**: Pure SwiftUI using the latest `@State`, `@Environment`, and `AnyShapeStyle` for a reactive UI.
- **Service Layer (`FileSystemService`)**: A robust engine handling file system operations, AppleScript execution for elevated privileges, and asynchronous scanning.
- **Data Layer**: JSON-driven junk definitions allowing for easy updates without recompiling the core engine.

<p align="center">
  <img src="Media/nc01.png" width="300" height="900" title="">
  <img src="Media/nc02.png" width="300" height="900" title="">
  <img src="Media/nc03.png" width="300" height="900" title="">
  <img src="Media/nc04.png" width="300" height="900" title="">
</p>

### Highlights:
- **Streaming Scan**: Doesn't block the UI thread, providing real-time feedback to the user.
- **Security-First**: Uses `ConfigurationRepository` to prevent directory traversal attacks or accidental deletion of system files.
- **Native Performance**: Zero third-party dependencies. Built entirely with Apple's native frameworks.

## 📸 Interface

The UI leverages **Glassmorphism** and **Material effects** to blend perfectly with the macOS aesthetic. Each card adapts its visual weight using `AnyShapeStyle` to provide depth in Dark Mode and clarity in Light Mode.

## 🛠 Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/arnabau/NovaClean.git](https://github.com/arnabau/NovaClean.git)

Note for macOS users: You can get just the binary, bu keep in mind NovaClean is not yet notarized by Apple, you might need to run **xattr -cr /Applications/NovaClean.app** in your terminal to bypass the "Developer cannot be verified" warning. Another way to do this is to use the "install.sh" file, which will perform the process for you. The app and the install.sh file must be in the same location. Alternatively, you can compile the app by yourself.
