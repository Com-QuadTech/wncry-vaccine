$mypath = $args[0]

# (Get-Item -Path ".\" -Verbose).FullName

Write-Host $mypath

Whoami

Write-Host ' '
Write-Host '=================================================='
Write-Host ' МЕНЯЮ ПОЛИТИКУ ИСПОЛНЕНИЯ СКРИПТОВ PS '
Write-Host '=================================================='
Set-ExecutionPolicy Bypass -Force

Write-Host ' '
Write-Host '=================================================='
Write-Host ' БЛОКИРУЮ ПОРТЫ 135-139,445,3389,5000 '
Write-Host '=================================================='
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=445 name='Block_TCP-445'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=135 name='Block_TCP-135'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=136 name='Block_TCP-136'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=137 name='Block_TCP-137'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=138 name='Block_TCP-138'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=139 name='Block_TCP-139'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=3389 name='Block_TCP-3389'"
cmd.exe /c "netsh advfirewall firewall add rule dir=in action=block protocol=tcp localport=5000 name='Block_TCP-5000'"

Write-Host ' '
Write-Host '=================================================='
Write-Host ' ВКЛЮЧАЮ БРАНДМАУЭР WINDOWS '
Write-Host '=================================================='

cmd.exe /c "netsh advfirewall set allprofiles state on"

Write-Host ' '
Write-Host '=================================================='
Write-Host ' ОТКЛЮЧАЮ ПРОТОКОЛ SMB (v1) В РЕЕСТРЕ '
Write-Host '=================================================='

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force
Write-Host 'OK. '

Write-Host ' '
Write-Host '=================================================='
Write-Host ' УДАЛЯЮ ПРОТОКОЛ SMBv1 ИЗ КОМПОНЕНТОВ WINDOWS '
Write-Host '=================================================='

cmd.exe /c "dism /online /norestart /disable-feature /featurename:SMB1Protocol"

Write-Host ' '
Write-Host '=================================================='
Write-Host ' УБИВАЮ ОПАСНЫЕ ПРОЦЕССЫ '
Write-Host '=================================================='

Get-Process ksmmainsvc*,mssecsvc*,taskhsvc*,*wanadecryptor* # | Format-List *

foreach($badProc in Get-Process ksmmainsvc*,mssecsvc*,taskhsvc*,*wanadecryptor*){    
    Stop-Process -Name $badProc.Name
}

Write-Host '=================================================='
Write-Host ' ПЕРЕЗАГРУЖАЮСЬ В SAFE MODE '
Write-Host '=================================================='

$fso = New-Object -ComObject scripting.filesystemobject
$fso.DeleteFolder("C:\Shell")

#md C:\Shell

Copy-Item -Path $mypath -Destination C:\ -Recurse

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" Shell -Type String -Value "C:\Shell\SafeMode.bat" -Force

cmd.exe /c "bcdedit /set {default} safeboot minimal"

cmd.exe /c "shutdown -r -t 0"