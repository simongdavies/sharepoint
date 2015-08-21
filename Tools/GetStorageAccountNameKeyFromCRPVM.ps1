switch-azuremode -name AzureResourceManager


$rgname = "ADPDC-2015820-16572"

$vmname = "ad-pdc"



$vm = Get-AzureVM -ResourceGroupName $rgname -Name $vmname
$disks = $vm.StorageProfileText | convertFrom-json
$storageaccount = [System.Uri] $disks.OSDisk.VirtualHardDisk.Uri
$storageAccountName = ($storageaccount.Host.Split('.'))[0]
Write-host $storageAccountName
Write-host (Get-AzureStorageAccountKey -ResourceGroupName $rgname -Name $storageAccountName -Verbose).Key1

Stop-AzureVM -ResourceGroupName $rgname -Name $vmname -Verbose -Force