switch-azuremode -name AzureResourceManager

$location = "*"
$rgPrefix = "T20*"

$sb = {
        param($rgname)
        function deleteSharepointDeployments($rgname)
        {
            Remove-AzureResourceGroup -Name $rgname -Force -Verbose 
        }
        deleteSharepointDeployments $rgname
    }

$rg = Get-AzureResourceGroup | where {$_.Location -like $location } | where {$_.ResourceGroupName -like $rgPrefix } | where {$_.ResourceGroupName -notlike "T22s-2015824-161549"}
foreach($g in $rg)
{
    Start-job -Name "job" -ScriptBlock $sb -ArgumentList $g.ResourceGroupName
}

