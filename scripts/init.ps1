pushd "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools"
cmd /c "VsDevCmd.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("=", 2); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])" 
  }
}
popd
Write-Host "`nVisual Studio 2019 Command Prompt variables set." -ForegroundColor Yellow
