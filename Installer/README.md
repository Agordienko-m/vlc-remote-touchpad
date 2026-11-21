# vlc_remote

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 🎬 VLC Remote & Touchpad v1.3 — Control VLC Media Player & Windows PC from Android

A lightweight wireless remote control for **VLC Media Player**, Windows mouse/keyboard touchpad, and PC power management from your Android smartphone over your local network (Wi-Fi / Ethernet).

### ✨ Key Features
* **Bilingual Interface (EN / RU):** Instant language switching inside both the Android app and Windows server (with automatic system language detection), plus language selection during Windows setup.
* **VLC Media Remote:** Play/pause, seek timeline, volume control, audio track switching, subtitles toggle, and fullscreen mode.
* **Wireless Touchpad & Keyboard:** Control your Windows cursor right from your phone screen — smooth movement with adjustable sensitivity (`1.0` to `8.0`), single/double tap, physical **Left / Right Click** buttons, scroll bar, and remote text input (supports Cyrillic & Latin).
* **Smart PC Shutdown:** Remotely shut down your PC with a confirmation prompt. Before turning off Windows, the server gracefully closes VLC so the player saves your exact video playback position.
* **Auto-Reconnect & Background Tray:** Automatically restores connection after minimizing the mobile app. The Windows server minimizes to the system tray and automatically configures Windows Firewall (port `8085`) upon installation.

### 📦 Release Assets
* **`VLC_Remote_Setup.exe`** — Windows 10/11 (x64) Server Installer (English / Russian).
* **`app-release.apk`** — Android Remote & Touchpad Client.
* **`README.txt`** — Step-by-step setup guide.

### ⚡ Quick Start
1. Enable the **Web** interface in **VLC** on your PC (`Tools -> Preferences -> All -> Interface -> Main interfaces`) and set a password under `Lua -> Lua HTTP`.
2. Install and run **`VLC_Remote_Setup.exe`** on your Windows PC, enter your VLC password, and start the server.
3. Install **`app-release.apk`** on your Android device (connected to the same Wi-Fi network), enter the local IP address shown in the server window, and tap **Connect**.

---

# 🇷🇺 Русская версия (Описание)

Беспроводной пульт управления плеером **VLC**, курсором мыши, клавиатурой и питанием компьютера на Windows с Android-смартфона через локальную сеть (Wi-Fi / Ethernet).

### ✨ Основные возможности
* **Два языка (EN / RU):** мгновенное переключение языка в интерфейсе Android-пульта и Windows-сервера (с автоопределением языка системы), а также выбор языка при установке программы.
* **Пульт управления VLC:** воспроизведение/пауза, перемотка, громкость, переключение аудиодорожек, субтитров и полноэкранного режима.
* **Беспроводной тачпад и клавиатура:** управление курсором Windows с экрана телефона (настройка скорости от `1.0` до `8.0`, одиночный и двойной тап, кнопки **ЛКМ / ПКМ**, полоса прокрутки и ввод текста с клавиатуры смартфона).
* **Умное выключение ПК:** перед выключением Windows сервер мягко закрывает VLC, чтобы плеер сохранил последнюю позицию просмотра видео.
* **Автопереподключение и трей:** пульт сам восстанавливает связь после сворачивания, а сервер сворачивается в системный трей и автоматически открывает порт `8085` в Брандмауэре при установке.
