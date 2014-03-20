Param ([string]$file=$(throw "-group is required"))
Import-Module ActiveDirectory

$groups = Get-Content $file
foreach ($group in $groups)
{
	.\getGroupMembers.ps1 -group $group
}
