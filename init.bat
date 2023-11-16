@echo off
echo System Initalized
start C:\Scripts\automation\transp.ahk
start C:\Scripts\automation\winterm.ahk
start C:\Scripts\automation\uncap.exe

pushd "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools"
cmd /c "VsDevCmd.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("=", 2); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])" 
  }
}
popd
Write-Host "`nVisual Studio 2022 Command Prompt variables set." -ForegroundColor Yellow
