# Autodarts SSH Key Setup

Windows-Skript, das einen SSH-Key für einen Autodarts-Pi erstellt und überträgt. Danach kommst du ohne Passwort auf den Pi, einfach mit:

```
ssh autodarts
```

Gedacht zum Mitnehmen: Du kannst es auf jedem Windows-PC laufen lassen, z.B. bei Freunden.

## Ablauf

0. **Sprache:** Deutsch oder English (`1`/`2`).
1. **Key:** Das Skript fragt, ob ein SSH-Key erstellt werden soll (`J/N`).
2. **IP:** Du gibst die IP-Adresse des Pi ein. Das Skript prüft sie mit einem Ping.
3. **Benutzername:** Du gibst den Benutzernamen auf dem Pi ein.
4. **Passwort:** Du gibst einmal das Pi-Passwort ein, dann wird der Key übertragen.
5. **Test:** Das Skript prüft, ob der Login ohne Passwort klappt.

## Voraussetzungen

- Windows 10 oder 11 mit OpenSSH-Client. Der ist meist vorinstalliert, sonst unter *Einstellungen → System → Optionale Features* nachinstallieren.
- Der Pi ist im selben Netzwerk und SSH ist aktiviert.

## Was das Skript macht

- **Eigener Key:** Es legt einen eigenen Key unter `%USERPROFILE%\.ssh\id_autodarts` an. Vorhandene SSH-Keys, z.B. für GitHub, bleiben unberührt.
- **Kein doppelter Eintrag:** Der Key wird nur einmal in `~/.ssh/authorized_keys` auf dem Pi eingetragen, auch wenn du das Skript mehrmals laufen lässt.
- **Kurzbefehl:** Es trägt `Host autodarts` in `%USERPROFILE%\.ssh\config` ein. Wenn du es mit einer neuen IP startest, wird der Eintrag aktualisiert.
- **Alter Host-Eintrag:** Es entfernt den alten Host-Key für diese IP. So gibt es keine Warnung, wenn ein anderer Pi dieselbe IP hat.

## Nutzung

`autodarts-ssh-keysetup.bat` herunterladen und doppelklicken.
