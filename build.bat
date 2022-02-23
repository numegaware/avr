echo off

set OUTPUT_FILE_NAME=flash
set INPUT_FILE_NAME=index
set OS=WIN


echo on

%CD%\project\avrasm32 -o %CD%\dist\%OUTPUT_FILE_NAME%.hex -fI %CD%\src\%INPUT_FILE_NAME%.asm
pause
