# will add RDM

function AddRDM{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("RawPhysical","RawVirtual")]
        [string]
        $Dtype,
        $VM,
        $volname
    )
$VMhost = Get-VM -Name $VM | Get-VMHost      
$vol = irm -Uri "http://$($ibox)/api/rest/volumes?name=$($volname)" -Credential $iboxcreds -AllowUnencryptedAuthentication -SkipCertificateCheck
if($vol.result){
    $lun = Get-SCSILun -VMhost $VMhost -LunType Disk |?{$_.CanonicalName -eq "naa.6$($vol.result.serial)"}
    if($lun){
        New-HardDisk -VM $VM -DiskType $Dtype -DeviceName $lun.ConsoleDeviceName
        Write-Host("RDM Connected") -ForegroundColor Green}
    else{Write-Host("Lun not found on ESX") -ForegroundColor Red}
}else{Write-Host("Volume Not Found on ibox") -ForegroundColor Red}
}
