:: V1.04::
@echo off
:menu
echo.
echo Select an option:
echo 1. Create WinRE partition from Os partition
echo 2. Create WinRE partition from exiting partition
echo 3. Exit
set /p choice=Enter your choice (1, 2, or 3): 

if %choice%==1 goto RE_ext
if %choice%==2 goto RE
if %choice%==3 goto exit
echo Invalid choice, please try again.
goto menu

:RE_ext
echo.
diskpart /s Ext.dll
cls
goto RE

:RE
echo.
@echo off
setlocal

echo List of Volumes:
echo =================
(
echo list volume
) | diskpart
@echo NOTE: ***All data will be deleted on selected volume***
set /p volumeNumber=Select the volume number to Deploy WinRE environment: 

(
echo select volume %volumeNumber%
echo assign letter=Z
) | diskpart



@echo off
setlocal

REM Delete all files and directories except autounattend.xml
for /d %%D in (Z:\*) do if /i "%%D" neq "Z:\autounattend.xml" rd /s /q "%%D"
for %%F in (Z:\*) do if /i "%%F" neq "Z:\autounattend.xml" del /f /q "%%F"

@echo off
REM Prompt user to select the ISO file
echo Please select the Windows ISO file.
setlocal enabledelayedexpansion
for /f "tokens=*" %%i in ('powershell -command "Add-Type -AssemblyName System.Windows.Forms; $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $OpenFileDialog.Filter = 'ISO Files (*.iso)|*.iso'; $OpenFileDialog.ShowDialog() | Out-Null; $OpenFileDialog.FileName"') do set ISOFile=%%i

REM Check if the user selected a file
if "%ISOFile%"=="" (
    echo No file selected. Exiting...
    pause
    exit /b
)

REM Mount the ISO file
echo Mounting ISO file...
powershell -command "Mount-DiskImage -ImagePath '%ISOFile%'"
if errorlevel 1 (
    echo Failed to mount ISO file. Exiting...
    pause
    exit /b
)

REM Check if the ISO was mounted successfully
powershell -command "Get-DiskImage -ImagePath '%ISOFile%' | Get-Volume | Select-Object -ExpandProperty DriveLetter" > temp.txt
set /p DriveLetter=<temp.txt
del temp.txt

REM Check if the drive letter was found
if "%DriveLetter%"=="" (
    echo Failed to retrieve drive letter. Exiting...
    pause
    exit /b
)

REM Copy all files and directories from the mounted ISO to the Z: drive
echo Copying files from %DriveLetter% to Z:...
xcopy "%DriveLetter%:\*" "Z:\" /E /H /C /I /Y
if errorlevel 1 (
    echo Failed to copy files. Exiting...
    pause
    exit /b
)

REM Dismount the ISO file
echo Dismounting ISO file...
powershell -command "Dismount-DiskImage -ImagePath '%ISOFile%'"
if errorlevel 1 (
    echo Failed to dismount ISO file. Please dismount manually.
    pause
    exit /b
)

REM Display a message when done
echo Files copied successfully to Z:


@echo off
setlocal

(
echo select volume Z
echo remove letter=Z
) | diskpart

cls
echo WinRE_deployed_succesfully.
pause

exit

:exit
echo.
exit


