VLClive Plus
============

Overview
--------

VLClive Plus is an extension that integrates livestreamer into the VLC media player.

VLClive Plus is written in Lua and uses the VLC Lua plugin interface.

Credits to original author Julian Niedermeier - https://github.com/sleighsoft/VLClive 

Current Capabilities
--------------------

VLClive Plus is build on top of VLClive

Note: VLClive currently only works with twitch.tv streams 

- Select Streaming Source
- Add/Remove your favourite streamers for quick access (Remove Currently Broke)
- Import all your favourite streamers from twitch.tv with one click
- Quickly check if your favourite streamers are online (Twitch Only)
- Use all available quality settings


Installation
------------

1. Install Livestreamer: http://docs.livestreamer.io/install.html
(If you use Windows, add it the the Path Variable as well!)

2. Download the Lua file from /src/VLClivePlus.lua

3. Place it in the correct folder:

  * Windows: <Path_to_VLC_installation_directory>\\lua\\extensions\\
  * Linux: ~/.local/share/vlc/lua/extensions/
  * Mac OS X: /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

4. Run it from the 'View' tab in VLC

5. Please report all bugs immediately :)

6. Thank you for giving it a shot, much appreciated

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
