$TVSource = "\\192.168.1.53\Multimedia\TV Shows" # Location of all TV Shows
$OutputFile = (Join-Path $TVSource "IncorrectFolders.csv.")
$incorrectFolder = @()

$TVFolders = Get-ChildItem -path $TVSource -Attributes Directory | Sort-Object # Get all show folder names
Foreach ($ShowFolder in $TVFolders) {
    $SeasonFolder = Get-ChildItem -path $ShowFolder.FullName -Attributes Directory | Sort-Object # Get all season folder names
    $i=0
    Clear-Host
    $ShowFolder.FullName
    foreach ($Season in $SeasonFolder) {
        $i++
        write-host
	    If (!($Season.FullName -match(“ [0-9][0-9]")) -and !($Season.FullName -match(“Special"))) { # If Season folder does NOT have two digits and is NOT Specials
		    If ($Season.FullName -match(“Extra")) { # E comes before S so catch out of order structure
                $NewName = "Specials" # Purposed New name for Folder
                $i--
            }
            else {
                $NewName = "Season {0:d2}" -f $i # Purposed New name for Folder 
            }
            $Loop = 0
            while ($Loop -eq 0) {
                $PurposedName = (Join-Path $ShowFolder.FullName $NewName)
                if (Test-path $PurposedName) { # Check if Purposed name exists
                    $Season.FullName
                    Read-host -prompt "$NewName - Duplicate folder Found! Press any key to Merge Folders"
                    Get-ChildItem $Season.FullName | Move-Item -Destination $PurposedName -Confirm # Move all contents to folder we are keeping
                    if($Season.GetFiles().Count -eq 0) { # Is this folder empty
                        Remove-Item $Season.FullName # Delete duplicate
                        $Loop++
                    }
                }
                else { # Purposed name does not exist
                    write-host $Season.FullName
                    write-host "Change to: $PurposedName"
                    write-host "[ Yes ]   [ No ]   [ Custom Folder Name ]   [ Fix Folder Counter ($i) ]"
                    $MakeChange = read-host -prompt "(Y:N:C:F)"
                    switch($MakeChange) {
                        "Y" { # Perform Rename if user agrees
                            rename-item -path $Season.FullName -NewName $NewName 
                            $Loop++    
                        } 
                        "N" { # Add path to output file
                            $IncorrectFolder += $Season
                            write-host "Path Added to File"
                            $loop++
                        }
                        "c" { # Prompt for custom folder name
                            $NewName = read-host -prompt "Input new folder Name"
                        }
                        "f" { # Prompt for $i fix and generate new folder name
                            [int]$i = read-host -prompt "What number should this be? ($i)"
                            $NewName = "Season {0:d2}" -f $i # Purposed New name for Folder
                        }
                    } # Switch $MakeChange
                } # Else 
            } # While $Loop
	    } # Season Check
    }
}
$IncorrectFolder | select fullname | Export-csv $OutputFile -force # Output array to a file
$IncorrectFolder = $Null