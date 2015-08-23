Switch-AzureMode -name AzureResourceManager

# Count of runs
$count = 5

# Variables
$templateFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\mainTemplate-serialized.json"
$paramsFile = "C:\Users\kenazk\Desktop\GitHub\sharepoint\parameters.json"
$params = Get-content $paramsFile | convertfrom-json
$location = "eastus"
$rgprefix = "T20"
$storageType = "Standard_LRS"
$sql = "Standard_D3"
$ad = "Standard_D1"
$sp = "Standard_D3"

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
    $hash.StorageAccountType = $storageType
    $hash.witnessVMSize = "Standard_D1"
    $hash.spVMSize = $sp
    $hash.sqlVMSize = $sql
    $hash.adVMSize = $ad

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

    Start-sleep -s 5
}


