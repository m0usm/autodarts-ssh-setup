@echo off
setlocal EnableDelayedExpansion
title Autodarts Pi - SSH Key Setup

REM ============================================
REM  Sprache waehlen / Choose language
REM ============================================
echo ============================================
echo  Autodarts Pi - SSH Key Setup
echo ============================================
echo.
echo  [1] Deutsch
echo  [2] English
echo.
choice /c 12 /n /m "Sprache / Language [1/2]: "
if errorlevel 2 (goto lang_en) else (goto lang_de)

:lang_de
set "YN=jn"
set "T_YN=[J/N]"
set "T_NOSSH=FEHLER: SSH-Client nicht gefunden."
set "T_NOSSH2=Installieren: Einstellungen > System > Optionale Features > OpenSSH-Client"
set "T_STEP1=[Schritt 1] SSH-Key"
set "T_KEYEXISTS=Es gibt schon einen Autodarts-Key auf diesem PC."
set "T_KEYHINT1=Hinweis: Ein neuer Key ersetzt den alten - Pis, die den alten"
set "T_KEYHINT2=         kennen, muessen dann neu eingerichtet werden."
set "T_KEYNEW=Neuen Key erstellen?"
set "T_KEYUSE=Vorhandener Key wird verwendet."
set "T_KEYCREATE=SSH-Key fuer Autodarts erstellen?"
set "T_KEYABORT=Ohne Key geht es nicht - abgebrochen."
set "T_STEP2=[Schritt 2] IP-Adresse"
set "T_IP=IP-Adresse des Pi (steht z.B. im Router): "
set "T_IPEMPTY=Bitte eine IP-Adresse eingeben."
set "T_PING=Pruefe Erreichbarkeit von"
set "T_PINGFAIL=Pi nicht erreichbar unter"
set "T_PINGRETRY=Andere IP eingeben?"
set "T_PINGCONT=Fahre trotzdem fort..."
set "T_PINGOK=Pi erreichbar."
set "T_STEP3=[Schritt 3] Benutzername"
set "T_USER=Benutzername auf dem Pi (z.B. autodart): "
set "T_USEREMPTY=Bitte einen Benutzernamen eingeben."
set "T_STEP4=[Schritt 4] Key wird uebertragen zu"
set "T_PW=Du musst jetzt EINMALIG das Pi-Passwort eingeben (beim Tippen ist nichts zu sehen)."
set "T_COPYFAIL=FEHLER: Key konnte nicht uebertragen werden."
set "T_COPYFAIL2=Stimmen IP, Benutzername und Passwort?"
set "T_DONE=Fertig - Teste die Verbindung..."
set "T_TESTOK=Verbindung ohne Passwort erfolgreich."
set "T_TESTFAIL=Test fehlgeschlagen - Login ohne Passwort klappt noch nicht."
set "T_FUTURE=Kuenftig verbinden mit:   ssh autodarts"
goto start

:lang_en
set "YN=yn"
set "T_YN=[Y/N]"
set "T_NOSSH=ERROR: SSH client not found."
set "T_NOSSH2=Install it: Settings > System > Optional features > OpenSSH Client"
set "T_STEP1=[Step 1] SSH key"
set "T_KEYEXISTS=An Autodarts key already exists on this PC."
set "T_KEYHINT1=Note: A new key replaces the old one - Pis that know the old"
set "T_KEYHINT2=      key will have to be set up again."
set "T_KEYNEW=Create a new key?"
set "T_KEYUSE=Using the existing key."
set "T_KEYCREATE=Create an SSH key for Autodarts?"
set "T_KEYABORT=A key is required - aborted."
set "T_STEP2=[Step 2] IP address"
set "T_IP=IP address of the Pi (e.g. from your router): "
set "T_IPEMPTY=Please enter an IP address."
set "T_PING=Checking reachability of"
set "T_PINGFAIL=Pi not reachable at"
set "T_PINGRETRY=Enter a different IP?"
set "T_PINGCONT=Continuing anyway..."
set "T_PINGOK=Pi reachable."
set "T_STEP3=[Step 3] Username"
set "T_USER=Username on the Pi (e.g. autodart): "
set "T_USEREMPTY=Please enter a username."
set "T_STEP4=[Step 4] Transferring key to"
set "T_PW=You now have to enter the Pi password ONCE (nothing is shown while typing)."
set "T_COPYFAIL=ERROR: The key could not be transferred."
set "T_COPYFAIL2=Are IP, username and password correct?"
set "T_DONE=Done - Testing the connection..."
set "T_TESTOK=Passwordless connection successful."
set "T_TESTFAIL=Test failed - passwordless login does not work yet."
set "T_FUTURE=From now on connect with:   ssh autodarts"
goto start

:start
echo.

REM --- Ist der SSH-Client installiert? / SSH client installed? ---
where ssh >nul 2>&1
if errorlevel 1 (
    echo !T_NOSSH!
    echo !T_NOSSH2!
    pause
    exit /b 1
)

set "KEY=%USERPROFILE%\.ssh\id_autodarts"
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

REM ============================================
REM  Schritt 1 / Step 1: SSH-Key
REM ============================================
echo !T_STEP1!
echo.
if exist "!KEY!" (
    echo !T_KEYEXISTS!
    echo !T_KEYHINT1!
    echo !T_KEYHINT2!
    choice /c !YN! /n /m "!T_KEYNEW! !T_YN!: "
    if errorlevel 2 (
        echo !T_KEYUSE!
    ) else (
        del /q "!KEY!" "!KEY!.pub" 2>nul
        ssh-keygen -t ed25519 -f "!KEY!" -N "" -C "autodarts-%COMPUTERNAME%"
    )
) else (
    choice /c !YN! /n /m "!T_KEYCREATE! !T_YN!: "
    if errorlevel 2 (
        echo !T_KEYABORT!
        pause
        exit /b 1
    )
    ssh-keygen -t ed25519 -f "!KEY!" -N "" -C "autodarts-%COMPUTERNAME%"
)
echo.

REM ============================================
REM  Schritt 2 / Step 2: IP
REM ============================================
:askip
echo !T_STEP2!
set "PI_IP="
set /p PI_IP="!T_IP!"
if "!PI_IP!"=="" (
    echo !T_IPEMPTY!
    echo.
    goto askip
)

echo !T_PING! !PI_IP! ...
ping -n 1 -w 1500 !PI_IP! >nul
if errorlevel 1 (
    echo !T_PINGFAIL! !PI_IP!
    choice /c !YN! /n /m "!T_PINGRETRY! !T_YN!: "
    if not errorlevel 2 (
        echo.
        goto askip
    )
    echo !T_PINGCONT!
) else (
    echo !T_PINGOK!
)
echo.

REM ============================================
REM  Schritt 3 / Step 3: Benutzername / Username
REM ============================================
:askuser
echo !T_STEP3!
set "PI_USER="
set /p PI_USER="!T_USER!"
if "!PI_USER!"=="" (
    echo !T_USEREMPTY!
    echo.
    goto askuser
)
echo.

REM --- Alten Host-Eintrag fuer diese IP entfernen / remove old host key for this IP ---
ssh-keygen -R !PI_IP! >nul 2>&1

REM ============================================
REM  Schritt 4 / Step 4: Key uebertragen / transfer key
REM ============================================
echo !T_STEP4! !PI_USER!@!PI_IP!
echo !T_PW!
echo.

type "!KEY!.pub" | ssh -o StrictHostKeyChecking=accept-new !PI_USER!@!PI_IP! "mkdir -p ~/.ssh && chmod 700 ~/.ssh && k=$(cat) && touch ~/.ssh/authorized_keys && (grep -qxF \"$k\" ~/.ssh/authorized_keys || echo \"$k\" >> ~/.ssh/authorized_keys) && chmod 600 ~/.ssh/authorized_keys"
if errorlevel 1 (
    echo.
    echo !T_COPYFAIL!
    echo !T_COPYFAIL2!
    pause
    exit /b 1
)

REM --- Kurzbefehl "ssh autodarts" / shortcut "ssh autodarts" in SSH config ---
powershell -NoProfile -Command "$f=Join-Path $env:USERPROFILE '.ssh\config'; $c=''; if(Test-Path $f){$c=[IO.File]::ReadAllText($f)}; $c=[regex]::Replace($c,'(?m)^Host autodarts\r?\n(?:[ \t]+[^\r\n]*\r?\n?)*',''); $b=@('Host autodarts','  HostName '+$env:PI_IP,'  User '+$env:PI_USER,'  IdentityFile ~/.ssh/id_autodarts','  StrictHostKeyChecking accept-new') -join [char]10; $out=($c.TrimEnd()+[char]10+[char]10+$b+[char]10).TrimStart(); [IO.File]::WriteAllText($f,$out)"

echo.
echo ============================================
echo  !T_DONE!
echo ============================================
echo.

ssh -o BatchMode=yes autodarts "echo !T_TESTOK!"
if errorlevel 1 echo !T_TESTFAIL!

echo.
echo !T_FUTURE!
echo.
pause
 