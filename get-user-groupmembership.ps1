# (Get-ADGroup -Properties * -Filter {GroupCategory -eq "security"}).CN | sort
# (Get-ADGroup -Properties * -Filter {GroupCategory -eq "security"}).CN.count

$SEARCH_BASE = "CN=Users,DC=rds,DC=local"
$OUTPUT_FILE = "C:\Desktop\acl.csv"

# Get All Users from specified OU
$allUsers = Get-ADUser -Filter * -Properties DistinguishedName,Displayname,Samaccountname,WhenCreated -SearchBase $SEARCH_BASE
# DEBUG:
#Write-Host $allUsers

# Create a list from the Users. Each element will have [Displayname, DistinguishedName, Samaccountname, Group Membership Count].
$usersList = @()
foreach ($user in $allUsers) {
    # DEBUG:
    #Write-Host $user

    $groupMembershipCategory = @()

    # Group Membership Count
    $groupMembershipCount = (Get-ADPrincipalGroupMembership -Identity $user.Samaccountname).count
    # DEBUG:
    #Write-Host $groupMembershipCount

    # Getting Group Membership from user
    $groupMembership = Get-ADPrincipalGroupMembership -Identity $user.Samaccountname

    

    # Categories Group Membership
    #if ( ($groupMembership.name -eq "Domain Users") -and ($groupMembership.name -eq "Domain Admins") -and ($groupMembership.name -eq "RDSH-SBD-S1_SA") ) {
    if ( ($groupMembership.name -eq "Domain Users") -and ($groupMembership.name -eq "Domain Admins") ) {
        $groupMembershipCategory += "System Administrator"
    }
    if  ( ($groupMembership.name -eq "Enterprise Admins") ) {
        $groupMembershipCategory += "Enterprise Admins"
    }
    if  ( ($groupMembership.name -eq "Domain Guests") -or ($groupMembership.name -eq "Guests") ) {
        $groupMembershipCategory += "Guests"
    }
    else {
        $groupMembershipCategory += "Unknown"
    }

    # DEBUG:
    #Write-Host $groupMembership.name
    
    $memberOf = ($groupMembership | Select-Object -ExpandProperty Name) -join "`r`n" | Out-String
    #write-host $groupMembershipCategory
    $groupCategory = $groupMembershipCategory -join "`r`n" | Out-String

    #$MemberOf = (Get-ADPrincipalGroupMembership $user.DistinguishedName | Select-Object -ExpandProperty Name) -join "`r`n" | Out-String
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name "Displayname" -Value $user.Displayname
    $item | Add-Member -type NoteProperty -Name "DistinguishedName" -Value $user.DistinguishedName
    $item | Add-Member -type NoteProperty -Name "Samaccountname" -Value $user.Samaccountname
    $item | Add-Member -type NoteProperty -Name "GroupMembership" -Value $memberOf
    $item | Add-Member -type NoteProperty -Name "GroupMembershipCategory" -Value $groupCategory
    $item | Add-Member -type NoteProperty -Name "GroupMembershipCount" -Value $groupMembershipCount
    $item | Add-Member -type NoteProperty -Name "WhenCreated" -Value $user.WhenCreated
    $usersList += $item
}

# DEBUG:
#Write-Host $usersList
$usersList | Export-csv -Path $OUTPUT_FILE -NoTypeInformation
