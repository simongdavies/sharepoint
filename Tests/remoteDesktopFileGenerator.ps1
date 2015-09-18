switch-azuremode -name AzureResourceManager

$groups = Get-AzureResourceGroup | where {$_.ResourceGroupName -like "T62*" }
$results = @();

$d = get-date
$group = "" + $d.Year + '-' + $d.Month + '-' + $d.Day 

$folder = "C:\daily\" + $d.Year + '-' + $d.Month + '-' + $d.Day 
$dsuffix = "" + $d.hour + $d.minute + $d.Second
$file = $folder + '\rdpManagerInput-' + $dsuffix + '.txt' 

foreach($rg in $groups)
{
    $publicIp = Get-AzureResource -ResourceGroupName $rg.ResourceGroupName -ApiVersion "2015-06-15" -ResourceType Microsoft.Network/publicIpAddresses -Name "rdpIp" 
    $publicIp
    #$publicIp.Properties.ipAddress >> $file
}



