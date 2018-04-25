<#
    Enable-Http2OnWebApps.ps1
#>
$Subscription = "<MY SUBSCRIPTION>"

Login-AzureRmAccount
Select-AzureRmSubscription -Subscription $Subscription
$apps = Get-AzureRmWebApp
foreach($a in $apps) {
    $c= Get-AzureRmResource -ResourceType "Microsoft.Web/sites/config" -ResourceName $a.Name -ResourceGroupName $a.ResourceGroup -ApiVersion 2016-08-01
    $c.Properties.http20Enabled = $true
    $c | Set-AzureRmResource -ApiVersion 2016-08-01 -force 
}