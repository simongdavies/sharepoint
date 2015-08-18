switch-azuremode -name AzureResourceManager

$resourceGroupName = "T5-2015817-155944"

$resourceType = "Microsoft.Network/publicIpaddresses" 
$apiversion = "2015-05-01-preview"
$name = "rdpIp"

$resource = Get-AzureResource -ResourceGroupName $resourceGroupName -Name $name -ApiVersion $apiversion -ResourceType $resourceType
write-host $resourceGroupName
write-host $resource.Properties.ipAddress

Get-AzureNetworkInterface -ResourceGroupName $resourceGroupName | select Name, {$_.Ipconfigurations.privateIpAddress}