================================================================================
                VLC REMOTE & TOUCHPAD — SETUP & USER GUIDE
================================================================================

This suite allows you to control VLC Media Player, your Windows mouse cursor, 
keyboard input, and PC power state directly from your Android smartphone over 
your local network.

Included files:
1. VLC_Remote_Setup.exe — Server installer for Windows 10/11 (x64).
2. app-release.apk — Remote control & touchpad app for Android.

IMPORTANT: Both your Windows PC (via Wi-Fi or Ethernet cable) and your Android 
smartphone (via Wi-Fi) must be connected to the same local network / router.

--------------------------------------------------------------------------------
STEP 1. CONFIGURE VLC MEDIA PLAYER ON WINDOWS (ONE-TIME SETUP)
--------------------------------------------------------------------------------
1. Open VLC Media Player on your PC.
2. Go to the top menu: Tools -> Preferences (or press Ctrl + P).
3. In the bottom-left corner, switch "Show settings" from "Simple" to "All".
4. In the left sidebar, expand "Interface" and click "Main interfaces".
5. On the right side, check ONLY the "Web" box (leave "Console" unchecked).
6. In the left sidebar, expand "Main interfaces" and select "Lua".
7. Under "Lua HTTP" on the right, enter any simple password in the "Password" 
   field (for example: 1234) and remember it.
8. Click "Save" and completely restart VLC Media Player.
   (Optional: To make VLC remember where you stopped watching a video, go to 
   Tools -> Preferences -> Interface and set "Continue playback?" to "Always").

--------------------------------------------------------------------------------
STEP 2. INSTALL AND START THE WINDOWS SERVER
--------------------------------------------------------------------------------
1. Run VLC_Remote_Setup.exe, select your preferred installer language 
   (English or Russian), and complete the setup wizard.
   (The installer automatically adds a Windows Firewall rule for TCP port 8085).
2. Launch "VLC Remote Server".
3. Enter the password you set in VLC preferences (e.g., 1234) and click the 
   Start Server button.
4. Note the local IP address displayed in the server window (usually looks 
   like 192.168.0.xxx or 192.168.1.xxx).

--------------------------------------------------------------------------------
STEP 3. INSTALL THE APP ON YOUR ANDROID SMARTPHONE
--------------------------------------------------------------------------------
1. Copy app-release.apk to your Android smartphone and open it.
2. When prompted, allow installation from this source and tap "Install".
3. Make sure your phone is connected to the same Wi-Fi network as your PC.
4. Open "VLC Remote" on your phone, enter the local IP address shown in the 
   Windows server window (port 8085), and tap "Connect".

--------------------------------------------------------------------------------
KEY FEATURES
--------------------------------------------------------------------------------
* VLC Media Remote:
  Control playback (play/pause, timeline seeking, volume, fullscreen toggle, 
  audio track selection, and subtitles).
* Wireless Touchpad & Keyboard:
  Switch to Touchpad mode from the top bar. Supports:
  - smooth cursor movement with adjustable sensitivity slider (1.0x to 8.0x);
  - single tap (left click), double tap, and dedicated Left / Right click 
    buttons at the bottom;
  - vertical scrolling along the right edge of the touchpad;
  - remote text typing from your phone's keyboard (supports Latin & Cyrillic).
* Smart PC Shutdown:
  Tap "Shut Down PC" at the bottom of the remote screen. After confirmation, 
  the server gracefully closes VLC first (so your video playback position is 
  saved) and shuts down Windows after a 5-second delay.

--------------------------------------------------------------------------------
USEFUL TIPS
--------------------------------------------------------------------------------
* Background Connection Stability: The app automatically reconnects when 
  brought back from the background. For maximum reliability on Android, long-press 
  the "VLC Remote" app icon -> App info -> Battery -> select "Unrestricted".
* System Tray on Windows: Clicking the close ("X") button minimizes the server 
  to the Windows system tray (near the clock) so your remote keeps working. 
  To exit completely, right-click the tray icon and select "Exit".
* Language Switching: You can switch between English and Russian at any time 
  using the EN/RU button in the top bar of both the Android app and Windows server.
================================================================================


================================================================================
              VLC REMOTE & TOUCHPAD — ИНСТРУКЦИЯ ПО УСТАНОВКЕ
================================================================================

Комплект позволяет управлять плеером VLC, курсором мыши, вводом текста и 
выключением компьютера на Windows прямо со смартфона на Android.

В комплект входят два файла:
1. VLC_Remote_Setup.exe — сервер для компьютера на Windows.
2. app-release.apk — приложение-пульт и тачпад для смартфона на Android.

ВАЖНО: Для работы программы компьютер (по Wi-Fi или сетевому кабелю) 
и смартфон (по Wi-Fi) должны быть подключены к одному роутеру.

--------------------------------------------------------------------------------
ШАГ 1. НАСТРОЙКА ПЛЕЕРА VLC НА КОМПЬЮТЕРЕ (ДЕЛАЕТСЯ ОДИН РАЗ)
--------------------------------------------------------------------------------
1. Откройте плеер VLC на компьютере.
2. Перейдите в меню: Инструменты -> Настройки (или нажмите Ctrl + P).
3. В левом нижнем углу переключите «Показывать настройки» на «Все».
4. В левом списке раскройте раздел «Интерфейс» и нажмите «Основные интерфейсы».
5. Справа поставьте галочку ТОЛЬКО напротив пункта «Веб» 
   (галочку «Консоль» ставить не нужно).
6. В левом списке раскройте «Основные интерфейсы» и выберите пункт «Lua».
7. В блоке «Lua HTTP» справа впишите любой простой пароль в поле «Пароль» 
   (например: 1234) и запомните его.
8. Нажмите «Сохранить» и полностью перезапустите плеер VLC.
   (Чтобы VLC запоминал место остановки видео, убедитесь, что в разделе 
   «Интерфейс» пункт «Продолжить воспроизведение?» установлен в «Всегда»).

--------------------------------------------------------------------------------
ШАГ 2. УСТАНОВКА И ЗАПУСК СЕРВЕРА НА WINDOWS
--------------------------------------------------------------------------------
1. Запустите файл VLC_Remote_Setup.exe и следуйте инструкциям мастера.
   (Установщик сам скопирует файлы и откроет порт 8085 в Брандмауэре Windows).
2. Запустите программу «VLC Remote Server».
3. Введите пароль, который вы задали в настройках VLC (например, 1234), 
   и нажмите кнопку запуска сервера.
4. Запомните локальный IP-адрес компьютера, который отобразится в окне 
   сервера (обычно вида 192.168.0.xxx или 192.168.1.xxx).

--------------------------------------------------------------------------------
ШАГ 3. УСТАНОВКА ПРИЛОЖЕНИЯ НА СМАРТФОН (ANDROID)
--------------------------------------------------------------------------------
1. Скопируйте файл app-release.apk на смартфон и откройте его.
2. При запросе системы разрешите установку приложений из этого источника 
   и нажмите «Установить».
3. Убедитесь, что смартфон подключён к тому же Wi-Fi, что и компьютер.
4. Откройте «VLC Remote» на телефоне, введите IP-адрес компьютера из окна 
   сервера (порт 8085) и нажмите «Подключиться».

--------------------------------------------------------------------------------
ОСНОВНЫЕ ВОЗМОЖНОСТИ ПРИЛОЖЕНИЯ
--------------------------------------------------------------------------------
* Пульт VLC:
  Управление воспроизведением (пауза, перемотка, громкость, полноэкранный 
  режим, переключение звуковых дорожек и субтитров).
* Беспроводной тачпад и клавиатура:
  Переключение в режим тачпада в верхней панели пульта. Поддерживает:
  - перемещение курсора пальцем и настройку скорости (чувствительности);
  - одиночный тап (левый клик), двойной тап и кнопки ЛКМ / ПКМ внизу экрана;
  - прокрутку страниц (скролл) по правой полосе панели;
  - ввод текста на компьютере с клавиатуры смартфона (включая кириллицу).
* Выключение компьютера:
  Кнопка «Выключить ПК» в нижней части пульта. После подтверждения сервер 
  сначала аккуратно закрывает плеер VLC (чтобы сохранить позицию просмотра 
  видео), а затем выключает Windows через 5 секунд.

--------------------------------------------------------------------------------
ПОЛЕЗНЫЕ СОВЕТЫ
--------------------------------------------------------------------------------
* Стабильная связь в фоне: При возврате в приложение пульт автоматически 
  восстанавливает связь. Для максимальной стабильности зажмите иконку 
  «VLC Remote» на рабочем столе телефона -> О приложении -> Батарея 
  (Контроль активности) -> выберите «Нет ограничений».
* Сворачивание в трей на ПК: Нажатие на крестик окна сервера сворачивает его 
  в системный трей (рядом с часами), чтобы не прерывать работу пульта. Для 
  полного выхода нажмите правой кнопкой по иконке в трее -> «Выход».
* Выход на смартфоне: Для полного закрытия пульта и отключения от сервера 
  используйте кнопку выхода в правом верхнем углу экрана приложения.
================================================================================
