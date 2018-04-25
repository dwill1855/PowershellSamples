<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.115
	 Created on:   	3/10/2016 2:47 PM
	 Created by:   	 
	 Organization: 	 
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
[cmdletbinding(PositionalBinding =$true)]
param (
	$VMName,
	$VMSize,
	$VNET,
	$VNETSubnet,
	$VNETResourceGroup,
	$ResourceGroup,
	$Location,
	$OSDiskURI = $null,
	$VMIP,
	$OSVersion,
	$AVSetName = $null

)
if (!(Get-AzureRmResourceGroup))
{
	New-AzureRmResourceGroup -ResourceGroupName $ResourceGroup -Location $Location
	
}

$VNICName = $VMName + "-nic"

if($AVSetName -ne $null -and $AVSetName -ne "") {
	New-AzureRmAvailabilitySet -AvailabilitySetName $AVSetName -PlatformFaultDomainCount 3 -PlatformUpdateDomainCount 3 -ResourceGroupName $ResourceGroup -Location $Location
	$AV = Get-AzureRmAvailabilitySet -AvailabilitySetName $AVSetName -ResourceGroupName $ResourceGroup
	$VM = New-AzureRmVMConfig -VMName $VMName -VMSize $VMsize -AvailabilitySetId $AV.Id
}
else{
	$VM = New-AzureRmVMConfig -VMName $VMName -VMSize $VMsize
}

$VMVNETObject = Get-AzureRmVirtualNetwork -Name $VNET -ResourceGroupName $VNETResourceGroup

$VMSubnetObject = Get-AzureRmVirtualNetworkSubnetConfig -Name $VMSubnet -VirtualNetwork $VMVNETObject

$VNIC = New-AzureRmNetworkInterface -Name $VNICName -ResourceGroupName $ResourceGroup -Location $Location -SubnetId $VMVNETObject.Subnets[0].Id -PrivateIpAddress $VMIP

Add-AzureRmVMNetworkInterface -VM $VM -Id $VNIC.Id
if($OSVersion.ToLower() -eq "linux") {
	Set-AzureRmVMOSDisk -VM $VM -Name $VMName -VhdUri $OsDiskUri -CreateOption "Attach" -Linux
}
else {
	Set-AzureRmVMOSDisk -VM $VM -Name $VMName -VhdUri $OsDiskUri -CreateOption "Attach" -Windows
}
$NEWVM = New-AzureRmVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VM