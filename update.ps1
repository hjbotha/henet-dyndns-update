$hostname = "hostname"
$password = "password"

# Don't change below this line

$url = "http://dyn.dns.he.net/nic/update?hostname={0}&password={1}" -f $hostname, $password

$regkey = 'HKCU:\Software\Henning\dns.he.updater'

# get oldip from registry
$oldip = $( (Get-ItemProperty -path $regkey).oldip )
if (-not $oldip) { $oldip = "UNKNOWN"; }

# get newip

$myip = $(Invoke-WebRequest http://ipv6.myexternalip.com/raw).Content
Write-Host $myip 
Write-Host $oldip 

if ( $myip -like $oldip ) {
  Write-Host "IP unchanged."
  exit 0
}

$netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

if($netAssembly)
{
    $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
    $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

    $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

    if($instance)
    {
        $bindingFlags = "NonPublic","Instance"
        $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

        if($useUnsafeHeaderParsingField)
        {
          $useUnsafeHeaderParsingField.SetValue($instance, $true)
        }
    }
}


$result = Invoke-WebRequest $url
Write-Host $result
if ($result -match '(good|nochg) (.*)') {
  New-Item -Path $regkey -Type directory -Force 
  Set-ItemProperty -path $regkey -name oldip -value $myip 
}

