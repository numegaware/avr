echo off

set OUTPUT_FILE_NAME=index
set INPUT_FILE_NAME=index
set OS=WIN

if exist dist\ (
  echo Folder "dist" is exist
) else (
  echo Creating folder "dist"...
  mkdir "dist"
)

echo on
%CD%\avr_modules\avrasm32 -o %CD%\dist\%OUTPUT_FILE_NAME%.hex -fI %CD%\src\%INPUT_FILE_NAME%.asm
pause
