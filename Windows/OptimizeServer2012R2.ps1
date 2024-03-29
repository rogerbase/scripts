<#

.SYNOPSIS
Optimizes Windows Server 2012 R2 running in a VDS environment.

.DESCRIPTION
This script disables services, disables scheduled tasks and modifies the registry to optimize system performance on Windows Server 2012 R2 running in a VDS environment.
Tested on Windows Server 2012 R2 6.3.9600 Build 9600.

.NOTES
This script makes changes to the system registry and performs other configuration changes.
Start PowerShell as an administrator before running this script.

#>

$PauseFor2 = "Start-Sleep 2"
$TimeZone = "Russian Standard Time"

# Array of registry objects that will be created
$CreateRegistry =
@("DisableTaskOffload DWORD - Disable Task Offloading.", "'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' /v DisableTaskOffload /t REG_DWORD /d 0x1 /f"),
  ("HideSCAHealth DWORD - Hide Action Center Icon.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v HideSCAHealth /t REG_DWORD /d 0x1 /f"),
  ("HideSCAVolume DWORD - Hide Volume Icon.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v HideSCAVolume /t REG_DWORD /d 0x1 /f"),
  ("NoRemoteRecursiveEvents DWORD - Turn off change notify events for file and folder changes.", "'HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v NoRemoteRecursiveEvents /t REG_DWORD /d 0x1 /f"),
  ("SendAlert DWORD - Do not send Administrative alert during system crash.", "'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' /v SendAlert /t REG_DWORD /d 0x0 /f"),
  ("ServicesPipeTimeout DWORD - Increase services startup timeout from 30 to 45 seconds.", "'HKLM\SYSTEM\CurrentControlSet\Control' /v ServicesPipeTimeout /t REG_DWORD /d 0xafc8 /f"),
  ("DisableFirstRunCustomize DWORD - Disable Internet Explorer first-run customise wizard.", "'HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' /v DisableFirstRunCustomize /t REG_DWORD /d 0x1 /f"),
  ("AllowTelemetry DWORD - Disable telemetry.", "'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection' /v AllowTelemetry /t REG_DWORD /d 0x0 /f"),
  ("Enabled DWORD - Disable offline files.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache' /v Enabled /t REG_DWORD /d 0x0 /f"),
  ("Enable REG_SZ - Disable Defrag.", "'HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' /v Enable /t REG_SZ /d N /f"),
  ("NoAutoUpdate DWORD - Disable Windows Autoupdate.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' /v NoAutoUpdate /t REG_DWORD /d 0x1 /f"),
  ("NoAutoUpdate DWORD - Disable Windows Autoupdate.", "'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' /v NoAutoUpdate /t REG_DWORD /d 0x1 /f"),
  ("AUOptions DWORD - Disable Windows Autoupdate.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' /v AUOptions /t REG_DWORD /d 0x1 /f"),
  ("ScheduleInstallDay DWORD - Disable Windows Autoupdate.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' /v ScheduleInstallDay /t REG_DWORD /d 0x0 /f"),
  ("ScheduleInstallTime DWORD - Disable Windows Autoupdate.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' /v ScheduleInstallTime /t REG_DWORD /d 0x3 /f"),
  ("EnableAutoLayout DWORD - Disable Background Layout Service.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout' /v EnableAutoLayout /t REG_DWORD /d 0x0 /f"),
  ("DumpFileSize DWORD - Reduce DedicatedDumpFile DumpFileSize to 2 MB.", "'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' /v DumpFileSize /t REG_DWORD /d 0x2 /f"),
  ("IgnorePagefileSize DWORD - Reduce DedicatedDumpFile DumpFileSize to 2 MB.", "'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' /v IgnorePagefileSize /t REG_DWORD /d 0x1 /f"),
  ("Paths DWORD - Reduce IE Temp File.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths' /v Paths /t REG_DWORD /d 0x4 /f"),
  ("CacheLimit DWORD - Reduce IE Temp File.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path1' /v CacheLimit /t REG_DWORD /d 0x100 /f"),
  ("CacheLimit DWORD - Reduce IE Temp File.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path2' /v CacheLimit /t REG_DWORD /d 0x100 /f"),
  ("CacheLimit DWORD - Reduce IE Temp File.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path3' /v CacheLimit /t REG_DWORD /d 0x100 /f"),
  ("CacheLimit DWORD - Reduce IE Temp File.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path4' /v CacheLimit /t REG_DWORD /d 0x100 /f"),
  ("DisableLogonBackgroundImage DWORD - Disable Logon Background Image.", "'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' /v DisableLogonBackgroundImage /t REG_DWORD /d 0x1 /f"),
  ("EnableFirstLogonAnimation DWORD - Disable First Logon Animation.", "'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v EnableFirstLogonAnimation /t REG_DWORD /d 0x0 /f"),
  ("DisableCharmsHint DWORD - Disable Charms Bar.", "'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI' /v DisableCharmsHint /t REG_DWORD /d 0x1 /f"),
  ("DisableTLcorner DWORD - Disable Metro Switcher.", "'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI' /v DisableTLcorner /t REG_DWORD /d 0x1 /f"),
  ("DisableTRCorner DWORD - Disable Metro Switcher.", "'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI' /v DisableTRCorner /t REG_DWORD /d 0x1 /f")
 
# Array of registry objects that will be deleted
$DeleteRegistry =
@("StubPath - Themes Setup.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{2C7339CF-2B09-4501-B3F3-F3508C9228ED}' /v StubPath /f"),
  ("StubPath - WinMail.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{44BBA840-CC51-11CF-AAFA-00AA00B6015C}' /v StubPath /f"),
  ("StubPath x64 - WinMail.", "'HKLM\SOFTWARE\WOW6432Node\Microsoft\Active Setup\Installed Components\{44BBA840-CC51-11CF-AAFA-00AA00B6015C}' /v StubPath /f"),
  ("StubPath - Enable TLS1.1 and 1.2.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{66C64F22-FC60-4E6C-A6B5-F0D580E680CE}' /v StubPath /f"),
  ("StubPath - Disable SSL3.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{7D715857-A67C-4C2F-A929-038448584D63}' /v StubPath /f"),
  ("StubPath - Windows Desktop Update.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4340}' /v StubPath /f"),
  ("StubPath - Web Platform Customizations.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4383}' /v StubPath /f"),
  ("StubPath - DotNetFrameworks.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}' /v StubPath /f"),
  ("StubPath x64 - DotNetFrameworks.", "'HKLM\SOFTWARE\WOW6432Node\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}' /v StubPath /f"),
  ("StubPath - IE ESC for Admins.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' /v StubPath /f"),
  ("StubPath - IE ESC for Users.", "'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' /v StubPath /f")

# Array of registry objects that will be modified
$ModifyRegistry =
@("DisablePagingExecutive DWORD from 0x0 to 0x1 - Keep drivers and kernel on physical memory.", "'HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management' /v DisablePagingExecutive /t REG_DWORD /d 0x1 /f"),
  ("EventLog DWORD from 0x3 to 0x1 - Log print job error notifications in Event Viewer.", "'HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers' /v EventLog /t REG_DWORD /d 0x1 /f"),
  ("CrashDumpEnabled DWORD from 0x7 to 0x0 - Disable crash dump creation.", "'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' /v CrashDumpEnabled /t REG_DWORD /d 0x0 /f"),
  ("LogEvent DWORD from 0x1 to 0x0 - Disable system crash logging to Event Log.", "'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' /v LogEvent /t REG_DWORD /d 0x0 /f"),
  ("ErrorMode DWORD from 0x0 to 0x2 - Hide hard error messages.", "'HKLM\SYSTEM\CurrentControlSet\Control\Windows' /v ErrorMode /t REG_DWORD /d 0x2 /f"),
  ("MaxSize DWORD from 0x01400000 to 0x00010000 - Reduce Application Event Log size to 64KB", "'HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Application' /v MaxSize /t REG_DWORD /d 0x10000 /f"),
  ("MaxSize DWORD from 0x0140000 to 0x00010000 - Reduce Security Event Log size to 64KB.", "'HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Security' /v MaxSize /t REG_DWORD /d 0x10000 /f"),
  ("MaxSize DWORD from 0x0140000 to 0x00010000 - Reduce System Event Log size to 64KB.", "'HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\System' /v MaxSize /t REG_DWORD /d 0x10000 /f"),
  ("ClearPageFileAtShutdown DWORD to 0x0 - Disable clear Page File at shutdown.", "'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' /v ClearPageFileAtShutdown /t REG_DWORD /d 0x0 /f"),
  ("DisablePasswordChange DWORD from 0x0 to 0x1 - Disable Machine Account Password Changes.", "'HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' /v DisablePasswordChange /t REG_DWORD /d 0x1 /f"),
  ("TimeoutValue DWORD from 0x41 to 0xC8 - Increase Disk I/O Timeout to 200 seconds.", "'HKLM\SYSTEM\CurrentControlSet\Services\Disk' /v TimeoutValue /t REG_DWORD /d 0xC8 /f"),
  ("Win32PrioritySeparation DWORD from 0x0000018 to 0x0000026 - Adjust for Best Performance of Programs.", "'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl' /v Win32PrioritySeparation /t REG_DWORD /d 0x26 /f"),
  ("HideFileExt DWORD from 0x1 to 0x0 - Show extensions for known file types.", "'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v HideFileExt /t REG_DWORD /d 0x0 /f"),
  ("EnableAutoTray DWORD from 0x1 to 0x0 - Always show all tray icons.", "'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer' /v EnableAutoTray /t REG_DWORD /d 0x0 /f")

# Array of service objects that will be set to disabled
$Services =
@("ALG - Application Layer Gateway Service.", "ALG"),
  ("AppMgmt - Application Management.", "AppMgmt"),
  ("BITS - Background Intelligent Transfer Service.", "BITS"),
  ("DPS - Diagnostic Policy Service.", "DPS"),
  ("fdPHost - Function Discovery Provider Host.", "fdPHost"),
  ("WdiServiceHost - Diagnostic Service Host.", "WdiServiceHost"),
  ("WdiSystemHost - Diagnostic System Host.", "WdiSystemHost"),
  ("DiagTrack - Diagnostics Tracking Service.", "DiagTrack"),
  ("EFS - Encrypting File System [EFS].", "EFS"),
  ("Eaphost - Extensible Authentication Protocol.", "Eaphost"),
  ("FDResPub - Function Discovery Resource Publication.", "FDResPub"),
  ("UI0Detect - Interactive Services Detection.", "UI0Detect"),
  ("SharedAccess - Internet Connection Sharing [ICS].", "SharedAccess"),
  ("iphlpsvc - IP Helper.", "iphlpsvc"),
  ("lltdsvc - Link-Layer Topology Discovery Mapper.", "lltdsvc"),
  ("MSiSCSI - Microsoft iSCSI Initiator Service.", "MSiSCSI"),
  ("smphost - Microsoft Storage Spaces SMP.", "smphost"),
  ("hkmsvc - Health Key and Certificate Management.", "hkmsvc"),
  ("IEEtwCollectorService - Internet Explorer ETW Collector Service.", "IEEtwCollectorService"),
  ("NcaSvc - Network Connectivity Assistant.", "NcaSvc"),
  ("napagent - Network Access Protection Agent.", "napagent"),
  ("defragsvc - Optimize drives.", "defragsvc"),
  ("wercplsupport - Problem Reports and Solutions Control Panel.", "wercplsupport"),
  ("RasMan - Remote Access Connection Manager.", "RasMan"),
  ("SstpSvc - Secure Socket Tunneling Protocol Service.", "SstpSvc"),
  ("SNMPTRAP - SNMP Trap.", "SNMPTRAP"),
  ("sacsvr - Special Administration Console Helper.", "sacsvr"),
  ("svsvc - Spot Verifier.", "svsvc"),
  ("SSDPSRV - SSDP Discovery.", "SSDPSRV"),
  ("TieringEngineService - Storage Tiers Management.", "TieringEngineService"),
  ("SysMain - Superfetch.", "SysMain"),
  ("TapiSrv - Telephony.", "TapiSrv"),
  ("UALSVC - User Access Logging Service.", "UALSVC"),
  ("WerSvc - Windows Error Reporting Service.", "WerSvc"),
  ("dot3svc - Wired AutoConfig.", "dot3svc"),
  ("swprv - Microsoft Software Shadow Copy Provider.", "swprv"),
  ("VSS - Volume Shadow Copy.", "VSS")

# Array of scheduled task objects that will be set to disabled
$ScheduledTasks = 
@("'AD RMS Rights Policy Template Management (Manual)'", "'\Microsoft\Windows\Active Directory Rights Management Services Client\'"),
   ("SmartScreenSpecific", "'\Microsoft\Windows\AppID\'"),
   ("AitAgent", "'\Microsoft\Windows\Application Experience\'"),
   ("ProgramDataUpdater", "'\Microsoft\Windows\Application Experience\'"),
   ("Proxy", "'\Microsoft\Windows\Autochk\'"),
   ("ProactiveScan", "'\Microsoft\Windows\Chkdsk\'"),
   ("Consolidator", "'\Microsoft\Windows\Customer Experience Improvement Program\'"),
   ("KernelCeipTask", "'\Microsoft\Windows\Customer Experience Improvement Program\'"),
   ("UsbCeip", "'\Microsoft\Windows\Customer Experience Improvement Program\'"),
   ("ServerCeipAssistant", "'\Microsoft\Windows\Customer Experience Improvement Program\Server\'"),
   ("'Data Integrity Scan'", "'\Microsoft\Windows\Data Integrity Scan\'"),
   ("'Data Integrity Scan for Crash Recovery'", "'\Microsoft\Windows\Data Integrity Scan\'"),
   ("ScheduledDefrag", "'\Microsoft\Windows\Defrag\'"),
   ("LPRemove", "'\Microsoft\Windows\MUI\'"),
   ("BindingWorkItemQueueHandler", "'\Microsoft\Windows\NetCfg\'"),
   ("GatherNetworkInfo", "'\Microsoft\Windows\NetTrace\'"),
   ("Secure-Boot-Update", "'\Microsoft\Windows\PI\'"),
   ("Sqm-Tasks", "'\Microsoft\Windows\PI\'"),
   ("AnalyzeSystem", "'\Microsoft\Windows\Power Efficiency Diagnostics\'"),
   ("MobilityManager", "'\Microsoft\Windows\Ras\'"),
   ("RegIdleBackup", "'\Microsoft\Windows\Registry\'"),
   ("CleanupOldPerfLogs", "'\Microsoft\Windows\Server Manager\'"),
   ("ServerManager", "'\Microsoft\Windows\Server Manager\'"),
   ("StartComponentCleanup", "'\Microsoft\Windows\Servicing\'"),
   ("Configuration", "'\Microsoft\Windows\Software Inventory Logging\'"),
   ("SpaceAgentTask", "'\Microsoft\Windows\SpacePort\'"),
   ("'Storage Tiers Management Initialization'", "'\Microsoft\Windows\Storage Tiers Management\'"),
   ("Tpm-Maintenance", "'\Microsoft\Windows\TPM\'"),
   ("ResolutionHost", "'\Microsoft\Windows\WDI\'"),
   ("QueueReporting", "'\Microsoft\Windows\Windows Error Reporting\'"),
   ("'Scheduled Start'", "'\Microsoft\Windows\WindowsUpdate\'"),
   ("'Scheduled Start With Network'", "'\Microsoft\Windows\WindowsUpdate\'"),
   ("'License Validation'", "'\Microsoft\Windows\WS\'"),
   ("BfeOnServiceStartTypeChange", "'\Microsoft\Windows\Windows Filtering Platform\'"),
   ("WSTask", "'\Microsoft\Windows\WS\'")

Write-Host "Adding various registry entires for improving system performance." -ForeGroundColor Green
Invoke-Expression $PauseFor2

# Creating Registry Objects
foreach ($CreateRegistryObject in $CreateRegistry) {
  Write-Host Creating registry object $CreateRegistryObject[0] -ForegroundColor Cyan
  Invoke-Expression ("reg add " + $CreateRegistryObject[1]) | Out-Null
  Invoke-Expression $PauseFor2
}

Write-Host "Removing Active Setup registry entries for reducing logon times." -ForegroundColor Green
Invoke-Expression $PauseFor2

# Deleting Registry Objects
foreach ($DeleteRegistryObject in $DeleteRegistry) {
  Write-Host Deleting registry object $DeleteRegistryObject[0] -Foregroundcolor Cyan
  Invoke-Expression ("reg delete " + $DeleteRegistryObject[1]) 2>&1
  Invoke-Expression $PauseFor2
}

Write-Host "Modifying various registry entires for improving system performance." -ForeGroundColor Green
Invoke-Expression $PauseFor2

# Modifying Registry Objects
foreach ($ModifyRegistryObject in $ModifyRegistry) {
  Write-Host Modifying $ModifyRegistryObject[0] -ForegroundColor Cyan
  Invoke-Expression ("reg add " + $ModifyRegistryObject[1]) | Out-Null
  Invoke-Expression $PauseFor2
}

Write-Host "Disabling services for reducing system footprint and improving performance." -ForeGroundColor Green
Invoke-Expression $PauseFor2

# Disabling Services
foreach ($ServiceObject in $Services) {
  if ((Invoke-Expression ("Get-Service " + $ServiceObject[1])).StartType -eq "Disabled") {
    Write-Host Service $ServiceObject[1] already disabled -ForegroundColor Cyan
  }
  else {
    Write-Host Disabling service $ServiceObject[0] -ForegroundColor Cyan
    Invoke-Expression ("Set-Service " + $ServiceObject[1] + " -StartupType Disabled") | Out-Null
    Invoke-Expression $PauseFor2
  }
}

Write-Host "Disabling scheduled tasks for reducing system footprint and improving performance." -ForeGroundColor Green
Invoke-Expression $PauseFor2

# Disabling Scheduled Tasks
foreach ($ScheduledTaskObject in $ScheduledTasks) {
  if ((Invoke-Expression ("Get-ScheduledTask -TaskName " + $ScheduledTaskObject[0] + " -TaskPath " + $ScheduledTaskObject[1])).State -eq "Disabled") {
    Write-Host Scheduled task $ScheduledTaskObject[0] already disabled -ForegroundColor Cyan
  }
  else {
    Write-Host Disabling scheduled task $ScheduledTaskObject[0] -ForegroundColor Cyan
    Invoke-Expression ("Disable-ScheduledTask -TaskName " + $ScheduledTaskObject[0] + " -TaskPath " + $ScheduledTaskObject[1]) | Out-Null
    Invoke-Expression $PauseFor2
  }
}

Write-Host "Installing additional software and performing some minor optimizations." -ForeGroundColor Green
Invoke-Expression $PauseFor2

# Temporarily enable Windows Update service
Get-Service -Name wuauserv | Set-Service -StartupType Manual | Out-Null

# Set HTTPS - TLS 1.2 for this PowerShell session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install Chocolatey
Write-Host Installing Chocolatey. -ForegroundColor Cyan
if (Test-Path "C:\ProgramData\chocolatey\bin\choco.exe") {
  Write-Host An existing Chocolatey installation was detected. -ForegroundColor Cyan
}
else {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
choco feature enable -n=allowGlobalConfirmation | Out-Null

# Install Chromium
Write-Host Installing Chromium. -ForegroundColor Cyan
if (Test-Path "C:\Program Files\Chromium\Application\chrome.exe") {
  Write-Host Chromium is already installed. -ForegroundColor Cyan
}
else {
  choco install chromium -y -r
  choco install setdefaultbrowser -y -r
  Start-Process -FilePath "C:\ProgramData\chocolatey\lib\setdefaultbrowser\tools\SetDefaultBrowser\SetDefaultBrowser.exe" -NoNewWindow -ArgumentList "HKLM Chromium"
}

# Install 7-Zip
Write-Host Installing 7-Zip. -ForegroundColor Cyan
if (Test-Path "C:\Program Files\7-Zip\7z.exe") {
  Write-Host 7-Zip is already installed. -ForegroundColor Cyan
}
else {
  choco install 7zip -y -r
}

# Install SQLite DB Browser
Write-Host Installing SQLite DB Browser. -ForegroundColor Cyan
if (Test-Path "C:\Program Files\DB Browser for SQLite\DB Browser for SQLite.exe") {
  Write-Host SQLite DB Browser is already installed. -ForegroundColor Cyan
}
else {
  choco install sqlitebrowser -y -r
}

# Install Mem Reduct
Write-Host Installing Mem Reduct. -ForegroundColor Cyan
if (Test-Path "C:\Program Files\Mem Reduct\memreduct.exe") {
  Write-Host Mem Reduct is already installed. -ForegroundColor Cyan
}
else {
  choco install memreduct -y -r
}

# Uninstall Internet Explorer
Write-Host Uninstalling Internet Explorer. -ForegroundColor Cyan
if ((Get-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online).State -eq "Enabled") {
  Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart | Out-Null
}
if (Test-Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk") {
  Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Internet Explorer.lnk"
}

# Activate High Perfomance power plan
Write-Host Activating High Perfomance power plan. -ForegroundColor Cyan
$power_plan = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"      
powercfg /setactive ([string]$power_plan.InstanceID).Replace("Microsoft:PowerPlan\{", "").Replace("}", "")

# Disable UAC
Write-Host Disabling UAC. -ForegroundColor Cyan
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force | Out-Null

# Modify the existing page file
Write-Host Setting the existing page file to 1024MB. -ForegroundColor Cyan
$CurrentPageFile = Get-WmiObject -Query "Select * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"
$CurrentPageFile.InitialSize = [int]1024
$CurrentPageFile.MaximumSize = [int]1024
$CurrentPageFile.Put() | Out-Null

# Shortcuts on desktop
Get-ChildItem -Path $env:USERPROFILE\Desktop | Where-Object { $_.Name -like "*.website" } | Remove-Item
Start-Process $env:SYSTEMROOT\system32\rundll32.exe -ArgumentList "shell32.dll,Control_RunDLL desk.cpl,,0"

# Time zone
Write-Host Changing the time zone to $TimeZone. -ForegroundColor Cyan
tzutil /s $TimeZone

# Disable Windows Update service
Get-Service -Name wuauserv | Set-Service -StartupType Disabled | Out-Null

Write-Host "All optimizations are complete. Please restart your system." -ForegroundColor Yellow

switch (Read-Host "Restart computer now? [y/n]") {
  y { Restart-computer -Force -Confirm:$false }
  n { Write-Host Restart cancelled. -ForegroundColor Yellow }
  default { Write-Warning "Invalid input" }
}