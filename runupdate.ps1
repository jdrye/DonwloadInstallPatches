Get-Module -ListAvailable | Where-Object { $_.Name -Like "VMware*" } | Import-Module -Confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server vCenter
$vms = Get-VM
$WUScript = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\PSWindowsUpdate.log} # –AutoReboot or -IgnoreReboot
 

foreach($vm in $vms)
{
    $vmname = Get-VM $vm
    if ($vmname.guest.guestfamily -Match "WindowsGuest")
        {
        if ($vmname.guest.state -Match "Running")
            {
            if ($vmname.name -Match "onevmfortest")
                {
                if ($vmname.name -notmatch "notthisvmplease")
                    {
                    echo "willbeupdate :"
                    echo $vmname.name
                    Get-Item "\\share\PSWindowsUpdate" | Copy-VMGuestFile -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\" -VM $vm -LocalToGuest -Force
                    Set-ExecutionPolicy RemoteSigned
                    Invoke-WUInstall -ComputerName $vm -Script $WUScript -Confirm:$false
                    }
                else 
                {
                echo "wontbeupdate :"
                echo $vmname.name
                }
            }
        }
}
}
