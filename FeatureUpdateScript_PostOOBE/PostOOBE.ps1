
#Set FIPS at OS level to enabled
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy" -Name "Enabled" -Value "1" -Force

#Flags system to say that fips-cc-mode has failed
if ([System.Security.Cryptography.Cryptoconfig]::AllowOnlyFipsAlgorithms) {
  Write-Host("FIPS is enabled on Windows");
}else{
  Write-Host("FIPS is NOT enabled on Windows");
}

REG ADD "HKLM\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings" /v "fips-cc-mode-failed" /t REG_SZ /d "no" /f
REG ADD "HKLM\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings" /v "fips-cc-mode-enabled" /t REG_SZ /d "yes" /f
REG ADD "HKLM\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings" /v "enable-fips-cc-mode" /t REG_SZ /d "yes" /f
REG ADD "HKLM\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings" /v "fips-cc-mode-gps-selftest-result" /t REG_SZ /d "successful" /f

#forces restart of Palo Alto GlobalProtect
taskkill /F /IM PanGPS.exe
taskkill /F /IM PanGPA.exe
Restart-Service -Name PanGPS

#Install Chrome
Start-Process msiexec.exe -ArgumentList "/i C:\Util\Logs\Win11IPU\FED006F1\googlechromestandaloneenterprise64.msi /qn /norestart" -Wait -ErrorAction SilentlyContinue
start-sleep -Seconds 60

#Clear Staged Content such as chrome, setupcomplete,settingsconfig
Remove-Item -Path "C:\Util\Logs\Win11IPU\FED006F1" -Recurse -Force -ErrorAction SilentlyContinue
start-sleep -Seconds 3
Remove-Item -Path "C:\ProgramData\FeatureUpdate\Win11_22H2" -Recurse -Force -ErrorAction SilentlyContinue
start-sleep -Seconds 3
Remove-Item -Path "C:\Users\Default\AppData\Local\Microsoft\Windows\wsus" -Recurse -Force -ErrorAction SilentlyContinue
start-sleep -Seconds 3

#Restart System 
shutdown /r /t 0