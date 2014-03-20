Param ([string]$group = $(throw "-group is required"), $isNested, $nestedFrom)
Import-Module ActiveDirectory

#We'll export the output to a text file named after the target group
#If the script is casted with the -isNested flag, we know that we are dealing with a group within a group
if ($isNested -eq "yes")
{
	$file_name = $(".\" + $nestedFrom + "_members.txt")
}
else
{
	$file_name = $(".\" + $group + "_members.txt")
}
$temporaryFile = ".\temp.txt"
#We get rid of previous temporary files, if any
if (Test-Path $temporaryFile)
{
	Remove-Item $temporaryFile
}
#Get the UserIDs that belong to the target group
$users = Get-ADGroupMember -I $group | sort Name | Format-List SamAccountName | Out-File $temporaryFile #$file_name
#Remove empty lines and \\
#Keep only the last word of the line (where the userID is)
(gc $temporaryFile) |? {$_.trim() -ne  "" }| %{$_.Split()[-1]} | Set-Content $temporaryFile
#Get the name from the given UserIDs
$members = Get-Content $temporaryFile
#Remove previous files just in the first iteration
if ($isNested -ne "yes")
{
	Remove-Item $file_name
}
foreach ($member in $members)
{
	#In our environment usernames are seven chars long, bigger members would be groups
	#Let's use some recursion here...
	if ($member.length -gt 7)
	{
		if ($isNested -eq "yes")
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
#Remove temporary files
if (Test-Path $temporaryFile)
{
	Remove-Item $temporaryFile
}
#Remove duplicate lines
(gc $file_name) | ? {$_.trim() -ne  "" } | sort -Unique | Set-Content $file_name
