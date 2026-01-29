winget install Microsoft.OpenJDK.25
wget https://www.badgerpunch.com/booster/kickass.zip -OutFile kickass.zip
wget https://www.badgerpunch.com/booster/vice.zip -OutFile vice.zip

# Not so sure this works...
wget https://sourceforge.net/projects/c64-debugger/files/C64%2065XE%20NES%20Debugger%20v0.64.58.6.win32.zip -OutFile debugger.zip
Expand-Archive -DestinationPath tools kickass.zip
Expand-Archive -DestinationPath tools vice.zip
Expand-Archive -DestinationPath tools/debugger debugger.zip
del kickass.zip
del vice.zip
del debugger.zip
