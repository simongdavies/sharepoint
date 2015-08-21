switch-azuremode -name AzureResourceManager

$count = 4
$templateFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\tests\vmtemplate.json"
$paramsFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\tests\vmtemplate-parameters.json"
$params = Get-content $paramsFile | convertfrom-json
$location = "westus"
$rgprefix = "singleVM"

# Generate parameter object
$hash = @{};
foreach($param in $params.psobject.Properties)
{
    $hash.Add($param.Name, $param.Value.Value);
}

#Create new Resource Groups and Deployments for each run
for($i = 0; $i -lt $count; $i++)
{
    # Create new Resource Group
    $d = get-date
    $rgname = $rgprefix + '-'+ $d.Year + $d.Month + $d.Day + '-' + $d.Hour + $d.Minute + $d.Second
    New-AzureResourceGroup -Name $rgname -Location $location -Verbose 
    
    # Construct parameter set
    $dsuffix = "" + $d.hour + $d.minute + $d.Second
    $hash.dnsNameForPublicIP = "test" + $dsuffix
    $hash.newStorageAccountName = "sa" + $dsuffix
    $hash.location = $location

    # Run as asynchronous job
    $jobName = "dep-" + $i;
    $sb = {
        param($rgname, $templateFile, $hash)
        function createSharepointDeployment($rgname, $templateFile, $hash)
        {
            $dep = $rgname + "-dep"; 
            New-AzureResourceGroupDeployment -ResourceGroupName $rgname -Name $dep -TemplateFile $templateFile -TemplateParameterObject $hash -Verbose 
        }
        createSharepointDeployment $rgname $templateFile $hash
    }
    $job = start-job -Name $jobName -ScriptBlock $sb -ArgumentList $rgname, $templateFile, $hash
}


