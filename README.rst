VLClive Plus
============

Overview
--------

VLClive Plus is an extension that integrates Streamlink into the VLC media player.

VLClive Plus is written in Lua and uses the VLC Lua plugin interface.

Credits to original author Julian Niedermeier - https://github.com/sleighsoft/VLClive 

Current Capabilities
--------------------

VLClive Plus is build on top of VLClive

VLClive works using Livestreamer http://docs.livestreamer.io/install.html

VLClive Plus Features

- Auto Update
- Select Streaming Source or Manual enter Custom Source
- Add Streamers to favourite list for quick access
- Remove your favourite streamers for quick access (Broken)
- Quickly check if your favourite Twitch streamers are online (Broken)
- Custom quality settings

Installation
------------

1. Install Streamlink: https://streamlink.github.io/install.html
(If you use Windows, add it the the Path Variable as well!)

2. Download the Lua file from /src/VLClivePlus.lua

3. Place it in the correct folder:

  * Windows: <Path_to_VLC_installation_directory>\\lua\\extensions\\
  * Linux: ~/.local/share/vlc/lua/extensions/
  * Mac OS X: /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

4. Run it from the 'View' tab in VLC

Note: Additional Plugins maybe required


Configuration File
------------------

Saved Favourites configuration file "vlclive.config" is located in

  * Windows: Windows: C:\\Users\\<username>\\AppData\\Roaming\\vlc\\lua\\extensions\\userdata\\vlclive\\
  * Linux: 
  * Mac OS X: /library/Application Support/org.videolan.vlc/lua/extensions/userdata/vlclive/


Contributing
------------

If you wish to report a bug or contribute code, please take a look
at `CONTRIBUTING.rst <CONTRIBUTING.rst>`_ first.
