getADusersFromGroup
===================

These scripts get the data from all the users who belong to each of the groups provided by a text input file. If there are groups within the target group, the script recursively gathers all the users who belong to the nested groups.

Usage
=====

To get all the users from a list of groups:
.\usersGroup.ps1 -file _input_file.txt_

To get the members of a given group:
.\getGroupMembers.ps1 -group _ADgroup_
