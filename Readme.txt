MPxConverter is a free, open source program that acts as a graphical interface for the AMV-Codec-Tools, a special FFMpeg build that contains AMV (Advanced Media Video) encoding possibilities. This program is derrived (and thought to be somewhat an improved version) of Bytessence AMVConverter. The main features are open source, code portability, speed, and compatibility with more video formats. The old AMVConverter was limited because it was useful only with Actions Chipsets. However this new implementation can work for Actions and Sunplus hardware  players. It has been tested on Actions ATJ2093H and Sunplus SPMP3052.

More information is available on http://www.bytessence.com

Changelog for Bytessence MPxConverter: 

Version 1.3
 - Interface enhancements
 - Added possibility to save the conversion list and load it back
 - Added possibility to remove all the videos in the list
 - Added the '.mpeg' extension in the open video dialog
 - Added a new help document
 - Added a specific error when a file cannot be added in the list
 - Added new settings dialog
 - Added option to skip/replace/ask if a video file already exists
 - Added option for changing the interface update speed
 - Added option to automatically clear converted videos from the list
 - Added more error checking
 - Improved event handling while conversion is in progress
 - Fixed a bug when moving videos up/down in the list (column contents weren't preserved)
 - Fix a bug that was preventing some settings to be stored (under Linux)
 - Fixed the widget resizing problems (under Linux)
 - Fixed small bugs and potential vulnerabilities

Version 1.2
 - The list columns are now stored in the settings file
 - The remaining time indicator is now more accurate
 - Added a more reliable way of calculating the total progress
 - The progress is also shown on the titlebar while converting
 - Added drag and drop support
 - Fixed a bug with the input path in the "Add video" dialog
 - Fixed a bug that was preventing the main window to show up after closing it
   in minimized state (from the taskbar)
 - Added Urdu, Turkish and German translations in the main package
 - Updated code for PureBasic 4.30
 - Re-compiled the included AMV-Codec-Tools FFMpeg executable (SVN-r589)
 - Made other minor changes (changed item highlight color, formatted the code)

Version 1.1
 - Made all the paths relative (for languages and log) for full portability
 - Removed the useless window color
 - Fixed the video remove action mixing colours in the video list
 - Added multiple file selection feature so you can add more files with a single click
 - Added 'estimated time of arrival' column so you know how much time is left until a 
   video file is converted
 - The video options you last used are now stored in the settings file
 - The program now remembers the position and the size of the main window
 - Different profile files can be now chosen from the Settings dialog
 - Added splash screen upon startup (it can be turned off in Settings)

Version 1.0
 - Added LibFAAD support for the included FFmpeg build
 - Added .mp4 extension to the open file dialog on Windows version
 - Added updated Hungarian, Italian and Spanish translations in the package
 - Fixed a small bug (conversion wouldn't stop when the button was pressed)

Version 0.9
 - New design (as requested), closer to the old AMV converter
 - Now the conversion parameters are stored in a file so you can add custom resolutions, tweak the quality, etc.
 - The conversion options aren't mixed together anymore, they're now separated (e.g each player has it's own recommended values, preventing "Format error" warnings)
 - Fixed a small bug where the log file was created even if the option was deactivated
 - Removed RockChip / Anyka from the list

Version 0.8
 - Added Italian translation
 - Fixed problem with xvidcore.dll (now it's built as static lib in ffmpeg)
 - Made other minor changes
