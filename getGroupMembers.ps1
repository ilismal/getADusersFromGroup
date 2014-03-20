Param ([string]$group = $(throw "-group is required"), $isNested, $nestedFrom)
Import-Module ActiveDirectory

#We'll export the output to a text file named after the target group
if $isNested -eq "yes"
{
	$file_name = $(".\" + $nestedFrom + "_members.txt")
}
else
{
	$file_name = $(".\" + $group + "_members.txt")
}
$users = Get-ADGroupMember -I $group | sort Name | Format-List SamAccountName | Out-File $file_name
#Remove empty lines and
#Keep only the last word of the "Name : " line (where the userID is)
(gc $file_name) |? {$_.trim() -ne  "" }| %{$_.Split()[-1]} | Set-Content $file_name
#Get the name from the given UserIDs
$members = Get-Content $file_name
foreach ($member in $members)
{
	if($member.StartsWith("IR_"))
	{
		#
		if $isNested -eq "yes"
		{
			.\getGroupMembers.ps1 -group $member -isNested yes -nestedFrom $nestedFrom
		}
		else
		{
			.\getGroupMembers.ps1 -group $member -isNested yes -nestedFrom $group
		}
	}
	else
	{
		Get-ADUser -I $member | Format-Table -HideTableHeaders UserPrincipalName, Surname, GivenName | Out-File -encoding ascii -Append $file_name
	}
}
(gc $file_name) | ? {$_.trim() -ne  "" } | Set-Content $file_name
