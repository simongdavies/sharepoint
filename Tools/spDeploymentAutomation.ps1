Switch-AzureMode -name AzureResourceManager

# Count of runs
$count = 4

# Variables
$templateFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\mainTemplate-serialized.json"
$paramsFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\parameters.json"
$params = Get-content $paramsFile | convertfrom-json
$location = "southeastasia"
$rgprefix = "T8"

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
    $hash.dnsPrefix = "spha" + $dsuffix
    $hash.spCADNSPrefix = "spha" + $dsuffix + "ca"
    $hash.storageAccountNamePrefix = "sa" + $dsuffix
    $hash.location = $location

    # Run as asynchronous job
    $jobName = "spDeployment-" + $i;
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


