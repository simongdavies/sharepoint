switch-azuremode -name AzureResourceManager

$resourceGroupName = "T8-2015818-9548"

$resourceType = "Microsoft.Network/publicIpaddresses" 
$apiversion = "2015-05-01-preview"
$name = "rdpIp"

$resource = Get-AzureResource -ResourceGroupName $resourceGroupName -Name $name -ApiVersion $apiversion -ResourceType $resourceType
write-host $resourceGroupName
write-host $resource.Properties.ipAddress

Get-AzureNetworkInterface -ResourceGroupName $resourceGroupName | select Name, {$_.Ipconfigurations.privateIpAddress}