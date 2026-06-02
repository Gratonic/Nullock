# Nullock

---

<div align="center">

![Contributors](https://github.com/Gratonic/Nullock/graphs/contributors)
![Forks](https://github.com/Gratonic/Nullock/network/members)
![Stargazers](https://github.com/Gratonic/Nullock/stargazers)
![License](https://img.shields.io/badge/license-MIT-blue)
[![Discord](https://img.shields.io/discord/Nullock?color=7289da&label=Discord&logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/UYKFAjf9gk)

</div>

## Vision

---

We, the Nullock Team, aim to provide the community with a modern, free, and open source alternative to paywalled tools like Burp Suite.

We envision a Web Hacking Suite that the community can freely clone, modify, and distribute — a platform built around freedom, transparency, and customization.

A tool that is so customizable and transformable that people can't help but love it.

Nullock is more than just a tool for the individual; it is a Web Hacking Suite that the FOSS and Cybersecurity community can build, improve, and evolve together.

We swear to do our best to uphold and maintain:

- Free and Open Source (FOSS) Values
- Industry Standards
- Enterprise Quality

## Build

---

### Requirements

- CMake 3.31+
- A C++20 compiler (MSVC 2022 / GCC 13+ / Clang 16+)
- Qt6.10.x (Core, Gui, Qml, Quick, Network, etc.)
- OpenSSL 3.5.x 

### CMake Build and Compile Commands

***point CMAKE_PREFIX_PATH at your Qt install***

On Linux:
```
cmake -B Build -DCMAKE_BUILD_TYPE=Release

cmake --build Build
```

On Windows:
```
cmake -S . -B Build -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_PREFIX_PATH="C:/Qt/6.7.3/msvc2019_64"
cmake --build Build --config Release --target NullockApp
```

***On Windows the QML module library needs to live alongside the exe before
running, and Qt's runtime needs to be deployed too:***
```
copy Build\Src\FrontEnd\GUI\Release\FrontEndGUI.dll Build\Src\App\Release\
"<Qt>/bin/windeployqt.exe" --release --qmldir Src\App ^
    Build\Src\App\Release\NullockApp.exe
```

***run from project root***

On Linux:
```
./Build/Src/App/NullockApp
```

On Windows:
```
Build\Src\App\Release\NullockApp.exe
```

## Roadmap

---

- [] GUI and ThemesAPI
- [] CA and Proxy Core
- [] Overview
- [] Proxy Hub
- [] Intercept Hub
- [] Repeater Hub
- [] Intruder Hub
- [] Device Hub
- [] Workspace
- [] Settings 
- [] ExtensionsAPI

## Project Structure

---

### Back End

| Area | File Path | State | Notes |
| Cache | /Src/BackEnd/Cache/ | Work in progress | Back End Cache Logic/Controllers |

### Core

| Area | File Path | State | Notes |
| APIs | Src/Core/APIs/ | Work in progress | API code (ex: ExtensionsAPI, ManagerAPI, ThemesAPI) | These APIs are used to interact with various modules. |
| AppController | Src/Core/AppController/ | Work in progress | Module(s) use to change the widgets displayed when tabs are clicked in the left side tab manager in the UI. A special signal is transmitted when x button is clicked, this/these module(s) use this signal to determine what to change in the UI. |
| Database | Src/Core/Database/ | Work in progress | Files such as .dat, .png, .jpeg, .json files that are shared throughout the program program are stored here. There may also be database management code stored here. |
| Networking | Src/Core/Networking/ | Work in progress | All non-proxy networking library code goes here. |
| NullE | Src/Core/NullE/ | Work in progress | Nullock Evaluation (Vulnerability Detection Engine/Model) code |
| Proxy | Src/Core/NullE/ | Work in progress | Nullock's stand-alone proxy's code |
| Utils | Src/Core/Utils/ | Work in progress | Utilities libary code (ex: clear_terminal()) |

### Front End

| Area | File Path | State | Notes |
| GUI | Src/FrontEnd/GUI/ | Work in progress | Main Front End Code (QML6.10.x and C++20)
| Resources | Src/FrontEnd/Resources | Work in progress | Image and other resource related files (ex: nullock_logo.png) used by the Front End are stored here. |
