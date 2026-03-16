# 🎯 Syllabus Conqueror · Deep Focus Edition

Syllabus Conqueror is a high-performance, visually stunning desktop application designed to help students and professionals master their curriculum through structured planning and deep focus sessions. Developed with **Qt 6.5+** and **C++17**, it combines advanced session management with a premium dark-themed user interface.

![Syllabus Conqueror Banner](https://img.shields.io/badge/Status-Beta-brightgreen?style=for-the-badge)
![Qt Version](https://img.shields.io/badge/Qt-6.5+-41CD52?style=for-the-badge&logo=qt)
![C++ Version](https://img.shields.io/badge/C++-17-00599C?style=for-the-badge&logo=c%2B%2B)

---

## ✨ Key Features

### 📅 Dual-Mode Workflow
- **Planning Mode**: Organize your syllabus into topics, assign marks/weights, and track your progress through a persistent list.
- **Focus Mode**: Transition into a distraction-free environment with a dedicated focus timer and simplified view to maximize productivity.

### 📊 Progress Tracking
- **Secured Marks Tracking**: Real-time calculation of your current standing vs. total marks.
- **Persistent Data**: Built-in SQLite integration ensures your topics and session history are never lost.

### 🍱 Premium UI/UX
- **Modern Aesthetics**: A sleek "Deep Focus" dark theme with glassmorphism-inspired elements.
- **Smooth Animations**: High-performance QML transitions between planning and focus states.
- **Status Banners**: Context-aware notifications for session completion.

---

## 🛠️ Technical Stack

- **Framework**: [Qt 6.5+](https://www.qt.io/) (Quick, Sql, Gui, Core)
- **Language**: C++17
- **Frontend**: QML (Qt Quick Controls 2)
- **Persistence**: SQLite (via `QSqlDatabase`)
- **Build System**: CMake 3.16+

---

## 🚀 Getting Started

### Prerequisites
- Qt 6.5 or later
- CMake 3.16+
- A C++17 compliant compiler (MSVC, GCC, or Clang)

### Building from Source

1. **Clone the repository**:
   ```bash
   git clone https://github.com/DeepFocusStudios/SyllabusConqueror.git
   cd SyllabusConqueror
   ```

2. **Configure and Build**:
   ```bash
   mkdir build
   cd build
   cmake ..
   cmake --build .
   ```

3. **Run the Application**:
   ```bash
   ./appSyllabusConqueror
   ```

---

## 📂 Project Structure

- `Main.qml`: Main application entry point and state management.
- `TopicModel.cpp/h`: C++ backend for managing syllabus topics.
- `SessionModel.cpp/h`: Logic for handling study sessions.
- `DatabaseManager.cpp/h`: SQLite integration and table initialization.
- `FocusController.cpp/h`: Core logic for the Focus Mode timer and states.
- `WindowManager.cpp/h`: Platform-specific window management (e.g., focus mode behavior).
- `PlanningView.qml` & `FocusView.qml`: Principal UI components for each mode.

---

## 📜 License & Credits

Developed by **Deep Focus Studios**. All rights reserved.
Built with ❤️ for learners who want to conquer their syllabus.
