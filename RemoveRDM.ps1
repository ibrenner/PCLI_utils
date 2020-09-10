# will remove all RDMs from specific VM

Function Remove-RDMs ($vm_name, $DelFlag){
    $VM = Get-VM -Name $vm_name
    if($VM -and $VM.PowerState -eq "PoweredOff"){
        $VM_WithRDM = Get-View $VM.id
        $VM_Devices = $VM_WithRDM.Config.Hardware.Device
        $VM_RdmDisks = $VM_Devices | where {$_.Backing.CompatibilityMode -eq "physicalMode" -or $_.Backing.CompatibilityMode -eq "virtualMode" -or ($_.DeviceInfo.Label -match "Hard Disk "  -and $_.CapacityInKB -eq "0")}
        if ($VM_RdmDisks){
        $idx = 0
        $VirtualMachinConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $VirtualMachinConfigSpec.deviceChange = @()
            Foreach ($VM_RdmDisk in $VM_RdmDisks){           
              $RDM_Key = $VM_RdmDisk.key
              $RDM_Name = $VM_RdmDisk.Backing.FileName
              if($VM_RdmDisk.Backing.CompatibilityMode -eq "physicalMode"){
                  $RDM_Name2 = $RDM_Name.Split(".",2)[0] +"-rdmp." + $RDM_Name.Split(".",2)[1]
              }else{
                $RDM_Name2 = $RDM_Name.Split(".",2)[0] +"-rdm." + $RDM_Name.Split(".",2)[1] 
              }
              $VirtualMachinConfigSpec.deviceChange += New-Object VMware.Vim.VirtualDeviceConfigSpec
              $VirtualMachinConfigSpec.deviceChange[$idx].device = New-Object VMware.Vim.VirtualDevice
              $VirtualMachinConfigSpec.deviceChange[$idx].device.key = $RDM_Key
              $VirtualMachinConfigSpec.deviceChange[$idx].operation = "remove"
              if ($Delflag -eq "yes"){
                    $svcRef = new-object VMware.Vim.ManagedObjectReference
                    $svcRef.Type = "ServiceInstance"
                    $svcRef.Value = "ServiceInstance"
                    $serviceInstance = get-view $svcRef
                    $fileMgr = Get-View $serviceInstance.Content.fileManager
                    $datacenter = (Get-View (Get-VM $VM.Name | Get-Datacenter).ID).get_MoRef()
                    write-host($RDM_Name, $RDM_Name2, $datacenter)
                    $fileMgr.DeleteDatastoreFile_Task($RDM_Name, $datacenter)
                    $fileMgr.DeleteDatastoreFile_Task($RDM_Name2, $datacenter)             
              }$idx++   
            }
        $VM_WithRDM.ReconfigVM_Task($VirtualMachinConfigSpec)
        }else{
            write-host("No RDMs found") -ForegroundColor Red
        }
    }else{
        write-host("VM not found or not powered off") -ForegroundColor Red
    }
}

