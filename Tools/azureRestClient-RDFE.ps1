switch-azuremode -name AzureServiceManagement

Import-AzurePublishSettingsFile 'C:\users\kenazk\Downloads\Microsoft Azure Internal Consumption-9-10-2015-credentials.publishsettings'

$SubscriptionId = (Get-AzureSubscription | ? IsDefault).SubscriptionId
$account = Get-AzureAccount | ? { $_.Subscriptions.Contains($SubscriptionId) -and $_.Type -eq "Certificate" } 
$certificate = ls Cert:\CurrentUser\My | ? Thumbprint -eq $account.Id

#$body = [xml](get-content C:\daily\2015-9-10\nonformatted.xml)
$body = "C:\daily\2015-9-10\nonformatted.xml"

$uri = "https://management.core.windows.net/85182b66-6daa-40c6-bfa8-42dcc6d6845e/services/hostedservices/kenazvm2/deployments/kenazvm2/roles/kenazvm2"
$response = Invoke-WebRequest -Method PUT -Uri $uri -Certificate $certificate -InFile $body -Headers @{ "x-ms-version" = "2015-09-01" } -ErrorAction Ignore -debug

