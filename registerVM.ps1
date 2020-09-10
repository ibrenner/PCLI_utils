# will register all VMs in a specific datastore 

    function registerVM{
        param (
            $DS,
            $VMFolder,
            $ESXHost
            )
        $registered = @{}
        Get-VM -Datastore $DS | %{$_.Extensiondata.LayoutEx.File | where {$_.Name -like "*.vmx"} | %{$registered.Add($_.Name.split('/')[-1],$true)}}
        New-PSDrive -Name TgtDS -Location $DS -PSProvider VimDatastore -Root '\' | Out-Null
        write-host("Processing... please wait...")
        $unregistered = @(Get-ChildItem -Path TgtDS: -Recurse | where {$_.FolderPath -notmatch ".snapshot" -and $_.Name -like "*.vmx" -and !$registered.ContainsKey($_.Name)})
        Remove-PSDrive -Name TgtDS
        foreach($VMXFile in $unregistered) {
            write-host("Registering $($VMXFile.Name)") -ForegroundColor Blue
            New-VM -VMFilePath $VMXFile.DatastoreFullPath -VMHost $ESXHost -Location $VMFolder -RunAsync
            }
    }
