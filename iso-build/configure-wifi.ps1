#Requires -RunAsAdministrator

$ErrorActionPreference = "SilentlyContinue"

$SSID = "EVO_MARTINELLI_5G"
$Password = "marti5elen"

$WifiProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <name>$SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$Password</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

$ProfilePath = "$env:TEMP\wifi-profile.xml"
$WifiProfile | Out-File -FilePath $ProfilePath -Encoding UTF8 -Force

Start-Sleep -Seconds 2

netsh wlan add profile filename="$ProfilePath" user=all
netsh wlan connect name="$SSID"

Start-Sleep -Seconds 5

Remove-Item $ProfilePath -Force -ErrorAction SilentlyContinue

Write-Host "✅ WiFi configured: $SSID" -ForegroundColor Green
