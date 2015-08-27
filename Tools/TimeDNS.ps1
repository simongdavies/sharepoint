$timeout="15"
$domain = "download.microsoft.com"
$server = "127.0.0.1"
$logFile = "log.txt"

#$domain = "a767.dscms.akamai.net"
#$server = "88.221.81.192"
#$domain = "xx.xx.f1.internal.cloudapp.net"
#$server = "8.8.8.8"

clear
dnscmd.exe /ClearCache | tee -FilePath $logFile
(./dig.exe `@$server A $domain +retry=0 +timeout=$timeout) | tee -FilePath $logFile -Append

""
"When, How Long"
$lastFail = 0
for ($i = 0; $i -lt 10000000; $i++)
{
    $when = Get-Date
    "------------ $when " | Out-File $logFile -Append

    dnscmd.exe /ClearCache  | Out-File $logFile -Append

    $result = (./dig.exe `@$server A $domain +retry=0 +timeout=$timeout)
    $result | Out-File $logFile -Append

    $status = $result | where { $_.Contains(" status")} | Select -First 1
    $howlong = $result | where { $_.Contains(" time")} | Select -First 1
    "$i, $when, $howlong, $status" | tee -FilePath $logFile -Append

    $gotError = $false
    if ($howlong -ilike "*timed out*")
    {
        $gotError = "timeout"
    }
    else
    {
        $ms = $howlong.Replace("msec", "").Split(":") | Select -Last 1
        $ms = $ms -as [int]
        if ($ms -gt 3000)
        {
            $gotError = "slow response $ms"
        }

        $gotA = ($result -join "`n").Contains("IN`tA`t")
        if (!$gotA)
        {
            $gotError = "incomplete"
        }
    }

    if ($gotError)
    {
        "Got Error: $gotError" | tee -FilePath $logFile -Append
        $result
        "Last failed $($i -$lastFail) queries ago" | tee -FilePath $logFile -Append
        $LastFail = $i
        Start-Sleep -Seconds 10
    }

    #Start-Sleep -Seconds 1
}
