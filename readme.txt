##Unlimited party mod for Fallout 2

This mod removes dialogue charisma checks on party join in Fallout 2.

- [Special notes](#special-notes)
- [Installation](#installation)
- [Unistallation](#uninstallation)
- [Reporting issues](#reporting-issues)
- [Author](#author)
- [License](#license)
- [Used software](#used-software)
- [Changelog](#changelog)


###Special notes
- **It will ONLY work if you have killap's patch** or restoration pack installed. You can get those at http://www.killap.net.
- It does not remove other checks (karma, etc). Companions may still refuse to join because of that.
- It should be **compatible with any other mod** provided that "unlimited party" is installed last. It patches files instead of overwriting them.
- Starting a **new game is not required**.
- It affects the following companions:
    * Brain bot
    * Cassidy
    * Cat Jules
    * Davin
    * Dex
    * Dogmeat
    * Goris
    * Kitsune
    * K-9
    * Lenny
    * Marcus
    * Miria
    * Miron
    * Robodog
    * Sulik
    * Vic

###Reporting issues
The mod is tested on Windows XP x86. If you have any issues, reach me on [github](https://github.com/burner1024/fallout2-unlimited-party-mod/issues). Attach logs (fallout2-unlimited-party-mod-X/tools/logs) so I could debug.

###Installation
- Download "Source code (zip)" archive from [latest release page](https://github.com/burner1024/fallout2-unlimited-party-mod/releases/latest)
- Unzip into game directory (should result in [Fallout2 directory]\fallout2-unlimited-party-mod-X, where X is current mod version)
- Launch install.bat

###Uninstallation
- Launch uninstall.bat

###Author
- burner1024 @ Github

###License
- It's provided as is, without any guarantee. Feel free to use it in any way that you see fit.

###Used software
* Noid's compiler (from http://www.nirran.com/Fallout2moddingTools.php)
* Ruby (http://ruby.org)
* Gema (http://gema.sourceforge.net)

###Changelog
* Version 6: fix bug that prevented characters with CHA less than 2 to recruit companions. Also, be more verbose during installation and fix some non-critical warnings
* Version 5: fix typo that caused Miria to be not affected
* Version 4: really fix space bug, better code style, graceful handling of missing files, better logging
* Version 3: fixed installation into a directory with spaces
* Version 2: fixed installation bug, added support for Restoration pack NPCs, Miria and Davin, updated readme.
* Version 1: initial release.
