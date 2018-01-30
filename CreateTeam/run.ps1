# POST method: $req
$input = Get-Content $request -Raw -Encoding UTF8 | ConvertFrom-Json

$name = $input.name
$owner = $input.owner
$alias = $name.ToLower() -replace "[^a-zæøå0-9]", "-"
$alias = $alias -replace "[æå]", "a"
$alias = $alias -replace "[ø]", "o"
$description = $input.description

$password = ConvertTo-SecureString $env:CUSTOMCONNSTR_ADMIN_PASSWORD -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($env:ADMIN_ACCOUNT, $password)
 
Connect-MicrosoftTeams -Credential $credentials

$team = New-Team -DisplayName $name -Description $description -Alias $alias -AccessType Private -AddCreatorAsMember $true

Add-TeamUser -GroupId $team.GroupId -User $owner -Role Owner
Add-TeamUser -GroupId $team.GroupId -User $owner -Role Member

#Set-TeamMemberSettings -GroupId $team.groupId -AllowCreateUpdateChannels $false -AllowDeleteChannels $false -AllowAddRemoveApps $false -AllowCreateUpdateRemoveTabs $false -AllowCreateUpdateRemoveConnectors $false

Disconnect-MicrosoftTeams

$output = @{
    groupId = $team.GroupId
    alias = $alias
    name = $name
    description = $description
}

Out-File -Encoding UTF8 -FilePath $response -inputObject ($output | ConvertTo-Json)