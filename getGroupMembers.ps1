Param ([string]$group = $(throw "-group is required"), $isNested, $nestedFrom)
Import-Module ActiveDirectory

#We'll export the output to a text file named after the target group
if ($isNested -eq "yes")
{
	$file_name = $(".\" + $nestedFrom + "_members.txt")
}
else
{
	$file_name = $(".\" + $group + "_members.txt")
}
$temporaryFile = ".\temp.txt"
if (Test-Path $temporaryFile)
{
	Remove-Item $temporaryFile
}
$users = Get-ADGroupMember -I $group | sort Name | Format-List SamAccountName | Out-File $temporaryFile #$file_name
#Remove empty lines and \\
#Keep only the last word of the "Name : " line (where the userID is)
#(gc $file_name) |? {$_.trim() -ne  "" }| %{$_.Split()[-1]} | Set-Content $file_name
(gc $temporaryFile) |? {$_.trim() -ne  "" }| %{$_.Split()[-1]} | Set-Content $temporaryFile
#Get the name from the given UserIDs
$members = Get-Content $temporaryFile
if ($isNested -ne "yes")
{
	Remove-Item $file_name
}
foreach ($member in $members)
{
	if($member.ToLower().StartsWith("cs_") -or $member.ToLower().StartsWith("ir_") -or $member.ToLower().StartsWith("lr_") -or $member.ToLower().StartsWith("mbna_") -or $member.ToLower().StartsWith("mm") -or $member.ToLower().StartsWith("rs_") -or $member.ToLower().StartsWith("sccm") -or $member.ToLower().StartsWith("sp_") or $member.ToLower().StartsWith("dg"))
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
if (Test-Path $temporaryFile)
{
	Remove-Item $temporaryFile
}
(gc $file_name) | ? {$_.trim() -ne  "" } | sort -Unique | Set-Content $file_name
