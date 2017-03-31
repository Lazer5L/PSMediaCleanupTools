$TVSource = "\\192.168.1.53\Multimedia\TV Shows" # Location of all TV Shows
$incorrect = @()

$TVFolders = Get-ChildItem -path $TVSource -Attributes Directory # Get all show folder names
Foreach ($ShowFolder in $TVFolders) {
    $SeasonFolder = Get-ChildItem -path $ShowFolder.FullName -Attributes Directory # Get all season folder names
    foreach ($Season in $SeasonFolder) {
	    If (!($Season.FullName -match(“ [0-9][0-9]"))) { # If Season folder does NOT have two digits
		    $Incorrect += $Season
            $Season.FullName
	    }
	    $Files = Get-ChildItem -path $Season.FullName -Attributes !Directory # Get all file names
	    Foreach ($file in $Files) {
		    If (!($file.FullName -match(“s[0-9][0-9]e[0-9][0-9]"))) { # If episode does NOT have S99E99
			    $Incorrect += $file
		    }
        }
    }
}

$Incorrect | select fullname | Export-csv “\\192.168.1.53\Multimedia\ProblemItems.csv” -force # Output array to a file
$Incorrect = $Null