if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

$wiresock = "C:\Program Files\WireSock VPN Client\bin\wiresock-client.exe"
$arguments = "run -config C:\VPN\wg-vpn.conf -log-level none"
Start-Process -FilePath $wiresock -ArgumentList $arguments