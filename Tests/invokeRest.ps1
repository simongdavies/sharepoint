# Get authorization context 
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$clientId = '10c1fb59-aff1-491f-a256-c46ac27aaa08'
$subscriptionId = '85182b66-6daa-40c6-bfa8-42dcc6d6845e'
 
$authUrl = "https://login.windows.net/72f988bf-86f1-41af-91ab-2d7cd011db47"
 
$AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authUrl
 
$result = $AuthContext.AcquireToken("https://management.core.windows.net/",
$clientId,
[Uri]"http://myapp1",
[Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto)
 
$authHeader = @{
'Content-Type'='application\json'
'Authorization'=$result.CreateAuthorizationHeader()
}

#Get all AzureResourceGroups 
$obj = @(); 

$groups = Get-AzureResourceGroup | where {$_.ResourceGroupName -like "T*" }
foreach($rg in $groups)
{ 
    # Collect all VMs
    $vms = Get-AzureVM -ResourceGroupName $rg.ResourceGroupName

    # Collect failed deployment
    $deploymentsFailed = Get-AzureResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName | where {$_.ProvisioningState -like "Failed" }

    # Collect Public IP to RDP
    $publicIp = Get-AzureResource -ResourceGroupName $rg.ResourceGroupName -ApiVersion "2015-06-15" -ResourceType Microsoft.Network/publicIpAddresses -Name "rdpIp"

    foreach($vm in $vms)
    {
        # Collect private IP of VM
        $privateIp = (Get-AzureNetworkInterface -ResourceGroupName $rg.ResourceGroupName -Name $($vm.Name + '-nic')).IpConfigurations.privateIPaddress
        $instanceStatusUri = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($rg.ResourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($vm.Name)/InstanceView?api-version=2015-06-15"
        $vmStatus = Invoke-RestMethod -Uri $instanceStatusUri -Headers $authHeader -method GET 
        $vmStatus.extensions | select Name, {$_.Statuses.code}
        foreach($ext in $vmStatus.extensions)
        {
            $ob = New-Object -TypeName PSObject
		    $ob | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $rg.ResourceGroupName -Force
            $ob | Add-Member -MemberType NoteProperty -Name FailedDeployment -Value $deploymentsFailed.deploymentName
		    $ob | Add-Member -MemberType NoteProperty -Name VMName -Value $vm.Name -Force
		    $ob | Add-Member -MemberType NoteProperty -Name VmProvisioningState -Value $vm.ProvisioningState -Force
            $ob | Add-Member -MemberType NoteProperty -Name ExtensionName -Value $ext.name -Force
            $ob | Add-Member -MemberType NoteProperty -Name ExtensionStatus -Value $ext.statuses.code -Force
            $ob | Add-Member -MemberType NoteProperty -Name RdpIP -Value $publicIP.Properties.ipAddress
            $ob | Add-Member -MemberType NoteProperty -Name PrivateIp -value $privateIp 
		    $obj += $ob
        }            
    }
} 


# Output to CSV 
$d = get-date
$folder = "C:\daily\" + $d.Year + '-' + $d.Month + '-' + $d.Day 
$dsuffix = "" + $d.hour + $d.minute + $d.Second
$file = '\rgOutput-' + $dsuffix + '.csv'

New-Item -ItemType Directory -Force -Path $folder

$obj | export-csv -Path $($folder+$file)
   

