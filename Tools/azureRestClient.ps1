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

# Output Objects
$obj = @();
$obj2 = @(); 


 $instanceStatusUri = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($rg.ResourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($vm.Name)/InstanceView?api-version=2015-06-15"
  $vmStatus = Invoke-RestMethod -Uri $instanceStatusUri -Headers $authHeader -method GET 