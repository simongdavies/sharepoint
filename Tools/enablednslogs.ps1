$dnslogName = 'Microsoft-Windows-DNS-Client/Operational'
$dnslog = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $dnslogName 
$dnslog.IsEnabled=$true
$dnslog.SaveChanges()

(Get-WinEvent -ListLog Microsoft-Windows-DNS-Client/Operational).IsEnabled | Out-File D:\isEnabled.txt;  
Get-WinEvent -LogName Microsoft-Windows-DNS-Client/Operational | Out-File D:\dnsClientlog.txt
