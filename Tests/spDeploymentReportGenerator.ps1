#Get all AzureResourceGroups 
$groups = Get-AzureResourceGroup | where {$_.ResourceGroupName -like "T5*" }
foreach($rg in $groups)
{ 
    # Collect all VMs
    $vms = Get-AzureVM -ResourceGroupName $rg.ResourceGroupName

    # Collect Public IP to RDP
    $publicIp = Get-AzureResource -ResourceGroupName $rg.ResourceGroupName -ApiVersion "2015-06-15" -ResourceType Microsoft.Network/publicIpAddresses -Name "rdpIp"

    foreach($vm in $vms)
    {
        # Collect private IP of VM
        $privateIp = (Get-AzureNetworkInterface -ResourceGroupName $rg.ResourceGroupName -Name $($vm.Name + '-nic')).IpConfigurations.privateIPaddress
        # Get instance view of VM
       
        $vmStatus = Get-AzureVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Status
        
        foreach($ext in $vmStatus.extensions)
        {
            $ob = New-Object -TypeName PSObject
		    $ob | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $rg.ResourceGroupName -Force
		    $ob | Add-Member -MemberType NoteProperty -Name VMName -Value $vm.Name -Force
		    $ob | Add-Member -MemberType NoteProperty -Name VmProvisioningState -Value $vm.ProvisioningState -Force
            $ob | Add-Member -MemberType NoteProperty -Name ExtensionName -Value $ext.name -Force
            $ob | Add-Member -MemberType NoteProperty -Name ExtensionStatus -Value $ext.statuses.code -Force
            $ob | Add-Member -MemberType NoteProperty -Name ExtensionMessage -Value $ext.statuses.message -Force
            $ob | Add-Member -MemberType NoteProperty -Name RdpIP -Value $publicIP.Properties.ipAddress
            $ob | Add-Member -MemberType NoteProperty -Name PrivateIp -value $privateIp 
		    $obj += $ob
        }            
    }

    Write-Progress -Activity "Generating deployment report for $($rg.ResourceGroupName)"
    # Generate report for Deployments
    $deployments = Get-AzureResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName
    foreach($dep in $deployments)
    {
        Write-Progress -Activity "Generating deployment report for $($rg.ResourceGroupName)" -Status "Working on $($dep.DeploymentName)"
        $ob = New-Object -TypeName PSObject
        $ob | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $dep.ResourceGroupName -Force
        $ob | Add-Member -MemberType NoteProperty -Name DeploymentName -Value $dep.DeploymentName -Force
        $ob | Add-Member -MemberType NoteProperty -Name ProvisioningState -Value $dep.ProvisioningState -Force
        $ob | Add-Member -MemberType NoteProperty -Name Timestamp -Value $dep.Timestamp -Force
        $obj2 += $ob
    }

} 


# Output to CSV 
$d = get-date
$folder = "C:\daily\" + $d.Year + '-' + $d.Month + '-' + $d.Day 
$dsuffix = "" + $d.hour + $d.minute + $d.Second
$file = '\rgOutput-' + $dsuffix + '-VMs.csv'
$file2 = '\rgOutput-' + $dsuffix + '-deployments.csv'

New-Item -ItemType Directory -Force -Path $folder

$obj | export-csv -Path $($folder+$file)
$obj2 | export-csv -Path $($folder+$file2)

write-host "Completed"
   

