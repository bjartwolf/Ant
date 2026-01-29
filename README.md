Ant
===

C64 implementation of [Langton's Ant](http://en.wikipedia.org/wiki/Langton's_ant) in 6502 Assembler

![screenshot](https://raw.github.com/bjartwolf/Ant/master/screenshot.png)

Originally developed using Vintage Studio <https://github.com/moozzyk/VintageStudio>
and 64TASS, but migrating to Kick Assembler and Retro Studio.

❯ & 'C:\Program Files\Microsoft\jdk-25.0.1.8-hotspot\bin\java.exe' -jar .\tools\kickass\KickAss.jar .\Main.asm -o ant.pr❯ & 'C:\Program Files\Microsoft\jdk-25.0.1.8-hotspot\bin\java.exe' -jar .\tools\kickass\KickAss.jar .\Main.asm -o ant.prg

❯ & '.\tools\vice\bin\c1541.exe' -format mydisk,01 d64 ant.d64 -write main.prg main
