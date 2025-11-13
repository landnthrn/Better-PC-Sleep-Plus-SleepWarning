@echo off
chcp 65001 >nul 2>&1
title PC IS SLEEPY
color 0A

echo.
echo.
echo  ██████╗░░█████╗░   ██╗░██████╗  ░██████╗██╗░░░░░███████╗███████╗██████╗░██╗░░░██╗
echo  ██╔══██╗██╔══██╗   ██║██╔════╝  ██╔════╝██║░░░░░██╔════╝██╔════╝██╔══██╗╚██╗░██╔╝
echo  ██████╔╝██║░░╚═╝   ██║╚█████╗░  ╚█████╗░██║░░░░░█████╗░░█████╗░░██████╔╝░╚████╔╝░
echo  ██╔═══╝░██║░░██╗   ██║░╚═══██╗  ░╚═══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░░░╚██╔╝░░
echo  ██║░░░░░╚█████╔╝   ██║██████╔╝  ██████╔╝███████╗███████╗███████╗██║░░░░░░░░██║░░░
echo  ╚═╝░░░░░░╚════╝░   ╚═╝╚═════╝░  ╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░░░░╚═╝░░░
echo.
echo  █▀▀ ▄▀█ █▄░█ █▀▀ █▀▀ █░░   █░█░█ █ ▀█▀ █░█   █▀▀ ▀█▀ █▀█ █░░ ▄█▄ █▀▀
echo  █▄▄ █▀█ █░▀█ █▄▄ ██▄ █▄▄   ▀▄▀▄▀ █ ░█░ █▀█   █▄▄ ░█░ █▀▄ █▄▄ ░▀░ █▄▄
echo.
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ███████╗
echo  ██╔════╝
echo  ██████╗░
echo  ╚════██╗
echo  ██████╔╝
echo  ╚═════╝░
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ░░██╗██╗
echo  ░██╔╝██║
echo  ██╔╝░██║
echo  ███████║
echo  ╚════██║
echo  ░░░░░╚═╝
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ██████╗░
echo  ╚════██╗
echo  ░█████╔╝
echo  ░╚═══██╗
echo  ██████╔╝
echo  ╚═════╝░
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ██████╗░
echo  ╚════██╗
echo  ░░███╔═╝
echo  ██╔══╝░░
echo  ███████╗
echo  ╚══════╝
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ░░███╗░░
echo  ░████║░░
echo  ██╔██║░░
echo  ╚═╝██║░░
echo  ███████╗
echo  ╚══════╝
echo.
timeout /t 1 /nobreak >nul 2>&1

echo.
echo.
echo  ░██████╗██╗░░░░░███████╗███████╗██████╗░  ████████╗██╗███╗░░░███╗███████╗
echo  ██╔════╝██║░░░░░██╔════╝██╔════╝██╔══██╗  ╚══██╔══╝██║████╗░████║██╔════╝
echo  ╚█████╗░██║░░░░░█████╗░░█████╗░░██████╔╝  ░░░██║░░░██║██╔████╔██║█████╗░░
echo  ░╚═══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░  ░░░██║░░░██║██║╚██╔╝██║██╔══╝░░
echo  ██████╔╝███████╗███████╗███████╗██║░░░░░  ░░░██║░░░██║██║░╚═╝░██║███████╗
echo  ╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░  ░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚══════╝
echo.
timeout /t 2 /nobreak >nul 2>&1

echo Preparing for sleep...
echo.

REM Pause any active media playback (only if media is currently playing)
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $sessionManager = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync().GetAwaiter().GetResult(); if ($sessionManager) { $sessions = $sessionManager.GetSessions(); $isPlaying = $false; foreach ($session in $sessions) { $playbackInfo = $session.GetPlaybackInfo(); if ($playbackInfo -and $playbackInfo.PlaybackStatus -eq 'Playing') { $isPlaying = $true; break; } }; if ($isPlaying) { $wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys([char]0xB3); } } } catch { }" >nul 2>&1

REM Brief pause before sleep
timeout /t 1 /nobreak >nul 2>&1

echo Executing sleep...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)}"

exit
