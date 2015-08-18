switch-azuremode -name AzureResourceManager

$location = "west*"
$rgPrefix = "t5*"

$sb = {
        param($rgname)
        function deleteSharepointDeployments($rgname)
        {
            Remove-AzureResourceGroup -Name $rgname -Force -Verbose 
        }
        deleteSharepointDeployments $rgname
    }

$rg = Get-AzureResourceGroup | where {$_.Location -like $location } | where {$_.ResourceGroupName -like $rgPrefix } 
foreach($g in $rg)
{
    Start-job -Name "job" -ScriptBlock $sb -ArgumentList $g.ResourceGroupName
}

