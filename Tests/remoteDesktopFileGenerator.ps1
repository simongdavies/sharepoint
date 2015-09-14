switch-azuremode -name AzureResourceManager

$groups = Get-AzureResourceGroup | where {$_.ResourceGroupName -like "T59*" }
$results = @();

$d = get-date
$group = "" + $d.Year + '-' + $d.Month + '-' + $d.Day 

foreach($rg in $groups)
{
    $publicIp = Get-AzureResource -ResourceGroupName $rg.ResourceGroupName -ApiVersion "2015-06-15" -ResourceType Microsoft.Network/publicIpAddresses -Name "rdpIp"
    $ob = New-Object -TypeName PSObject
	$ob | Add-Member -MemberType NoteProperty -Name Host -Value $publicIP.Properties.ipAddress -Force
	$ob | Add-Member -MemberType NoteProperty -Name Description -Value $rg.ResourceGroupName -Force
    $ob | Add-Member -MemberType NoteProperty -Name DisplayName -Value $rg.ResourceGroupName -Force
    $ob | Add-Member -MemberType NoteProperty -Name Group -Value $group -Force
    $results+=$ob
}

$folder = "C:\daily\" + $d.Year + '-' + $d.Month + '-' + $d.Day 
$dsuffix = "" + $d.hour + $d.minute + $d.Second
$file = $folder + '\rdpManagerInput-' + $dsuffix + '.csv' 

$results | export-csv $file
