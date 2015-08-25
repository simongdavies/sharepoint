switch-azuremode -name AzureResourceManager


$rgname = "T20-2015822-165743"

$vmname = "ad-pdc"



$vm = Get-AzureVM -ResourceGroupName $rgname -Name $vmname
$disks = $vm.StorageProfileText | convertFrom-json
$storageaccount = [System.Uri] $disks.OSDisk.VirtualHardDisk.Uri
$storageAccountName = ($storageaccount.Host.Split('.'))[0]
Write-host $storageAccountName
Write-host (Get-AzureStorageAccountKey -ResourceGroupName $rgname -Name $storageAccountName -Verbose).Key1

Stop-AzureVM -ResourceGroupName $rgname -Name $vmname -Verbose -Force