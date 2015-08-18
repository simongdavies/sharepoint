switch-azuremode -name AzureResourceManager


$rgname = "HA-2015811-12579"

$vmname = "sql-w"



$vm = Get-AzureVM -ResourceGroupName $rgname -Name $vmname
$disks = $vm.StorageProfileText | convertFrom-json
$storageaccount = [System.Uri] $disks.OSDisk.VirtualHardDisk.Uri
$storageAccountName = ($storageaccount.Host.Split('.'))[0]
Write-host $storageAccountName
Write-host (Get-AzureStorageAccountKey -ResourceGroupName $rgname -Name $storageAccountName -Verbose).Key1

Stop-AzureVM -ResourceGroupName $rgname -Name $vmname -Verbose -Force