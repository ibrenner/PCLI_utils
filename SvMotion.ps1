
function migrateVM($src_ds, $dst_ds) {
    $offvm = get-datastore $src_ds | Get-VM |?{$_.PowerState -eq 'PoweredOff'}
    $onvm = get-datastore $src_ds | Get-VM |?{$_.PowerState -eq 'PoweredOn'}    
    if($offvm){
        runmigrate -machines $offvm -destDS $dst_ds
    }
    if($onvm){
        runmigrate -machines $onvm -destDS $dst_ds
    }
}

function runmigrate($machines, $destDS) {
    Foreach ($VM in $machines){
        write-host -fore Cyan `n`t "Migrating " $VM " ..."
        $sourceDS=get-vm $VM | get-datastore    
        $snpsht=get-vm $VM | get-snapshot
        if(!$snpsht){
            Move-VM $VM -Datastore $destDS -runasync
            $snpsht=$null
            }
        else{
            write-host -fore Cyan `n`t "Snapshot found skipping " $VM " ..."
            }
    }
}

