#Nelson Figueroa

#ptable is a hash
#functions below

#Caution when creating .txt file manually
#Any extra lines will give errors when trying to split.

function create_partition{
	param ($ptable)

	#Prompt for drive and partition number, combine to key drive:number
	$driveletter = read-host -prompt "Enter drive letter"
	$partition = read-host -prompt "Enter partition number"
	$key = $driveletter + ":" + $partition

	#Check if this exists already. If it does, cancel process
	if ($ptable.ContainsKey($key)){
		write-host "Partition already Exists." -ForegroundColor Red
		return $ptable
	}

	#Prompt for other settings
	$offset = read-host -prompt "Enter partition offset"
	$size = read-host -prompt "Enter partition size"
	$type = read-host -prompt "Enter partition type (Reserved, Basic, etc)"

	#Then append them, tab deliminator
	$value = $offset + $tab + $size + $tab + $type

	#Assign to hash and return
	$ptable[$key] = $value
	write-host "Partition created." -ForegroundColor Green
	return $ptable
} #End create_partition

function modify_partition{
	param ($ptable)

	#Prompt for drive and partition number, combine to key drive:number
	$driveletter = read-host -prompt "Enter drive letter"
	$partition = read-host -prompt "Enter partition number"
	$key = $driveletter + ":" + $partition

	#Check if key does not exist.
	if (!$ptable.ContainsKey($key)){
		write-host "Partition does not exist." -ForegroundColor Red
		return $ptable
	}

	#Get partition fields to display when prompting
	$value = $ptable[$key]
	$value_array = $value.split($tab)
	$offset = $value_array[0]
	$size = $value_array[1]
	$type = $value_array[2]

	#Prompt for other settings
	$offset = read-host -prompt "Enter partition offset (Current = $offset)"
	$size = read-host -prompt "Enter partition size (Current = $size)"
	$type = read-host -prompt "Enter new partition type (Current = $type)"

	#Then append them, tab deliminator
	$value = $offset + $tab + $size + $tab + $type

	#Assign to hash and return
	$ptable[$key] = $value
	write-host "Partition modified." -ForegroundColor Green
	return ($ptable)
} #End modify_partition

function remove_partition{
	param ($ptable)

	#Prompt for drive and partition number, combine to key drive:number
	$driveletter = read-host -prompt "Enter drive letter"
	$partition = read-host -prompt "Enter partition number"
	$key = $driveletter + ":" + $partition

	#Check if key does not exist.
	if (!$ptable.ContainsKey($key)){
		write-host "Partition does not exist." -ForegroundColor Red
		return $ptable
	}

	#remove
	$ptable.Remove($key)
	write-host "Partition removed." -ForegroundColor Green
	return ($ptable)
}

function list_partitions{
	param ($ptable)

	#write-host "Drive   Part.   Offset  Size    Type $newline" -ForegroundColor Blue
	write-host ("Drive","Part.","Offset","Size","Type") -Separator "$tab" -ForegroundColor Blue
	write-host "---------------------------------------- $newline" -ForegroundColor blue

	foreach ($key in $ptable.keys){
		#$key = actual key of hash
		#split $key into drive and partition number, split by colon
		$key_array = $key.split(":")
		$driveletter = $key_array[0]
		$partition = $key_array[1]

		#split value into it's components
		#split the value of each key by $tab
		$value = $ptable[$key]
		$value_array = $value.split($tab)
		$offset = $value_array[0]
		$size = $value_array[1]
		$type = $value_array[2]

		#write-host "$driveletter   $partition    $offset    $size   $type"
		Write-Host ($driveletter,$partition,$offset,$size,$type) -Separator "$tab"

	}

	return ($ptable)
	}

function quit_program{
	param ($ptable)

	#Prompt for save
	$answer = read-host -prompt "Would you like to save the file? y/n"

	#If n, exit program
	if ($answer -eq "n"){
		write-host "Goodbye." -ForegroundColor Green
		#exit # End Script...Not needed?
	}

	else {

		#If yes, foreach every key in $ptable
		foreach ($key in $ptable.keys){

			#Append $key and $value with $tab in the middle and $newline
			$value = $ptable[$key] #Get value of key
			$line += "$key$tab$value$newline" #print key + value, add newline too

			#set-content overwrites file,
			#so we need to create one long $line to write to file, as shown above

		} #End foreach loop

		#Write line to file
		$line | set-content $fn
		write-host "File saved. Goodbye." -ForegroundColor Green
		#No need for return statement, or else program continues
	}

} #End quit_program

####################### Main Script ##########################

#Initialize Hash Table
$ptable = @{}

#No \n r \t in powershell
#Use ASCII values
$tab = [char]9
$newline = [char]13

#Prompt for file name to read-from
#it will put a colon and space automatically
$fn = read-host -prompt "Enter file containing partition information"

#test-path to check if file exists.
if (Test-Path $fn) {
	#If it exists, read from file
	#read file, gets stored in array "contents"
	$contents = get-content $fn

	#Go through every line in array, assign to hash.
	#$line is a dummy variable for the loop
	foreach ($line in $contents){

		#Split fields by tab deliminator
		$fields = $line.split($tab)

		#$key variable
		$key = $fields[0]

		#Re-append the remaining fields (offset, size, type) into a string of fields
		$value = $fields[1] + $tab + $fields[2] + $tab + $fields[3] #no more fields?

		#Add the string of fields as value into hash referenced by key (drive:number)
		$ptable[$key] = $value

		#write-host "Key = $key, Value = $value" #Testing

	} #End foreach
} #End if

#Initialize variable
$choice = ""

#Loop to print menu options and call appropriate function based on user choice until they say quit
while ($choice -ne "quit") {

	write-host "$newline"
	write-host "# Disk Partition Manager #$newline" -ForegroundColor Blue
	write-host "-------------------------- $newline" -ForegroundColor Blue
	write-host "create = Create a new partition $newline"
	write-host "modify = Modify a partition $newline"
  write-host "remove = Remove a partition $newline"
	write-host "list = List existing partitions $newline"
	write-host "quit = Quit program $newline"
	$choice = read-host -prompt "Enter your choice"
	write-host "$newline"

	#Call appropriate function
	switch ($choice) {

		#reassign $ptable since functions are returning a value
		create {$ptable = create_partition $ptable}
		modify {$ptable = modify_partition $ptable}
		remove {$ptable = remove_partition $ptable}
		list {$ptable = list_partitions $ptable}
		quit {$ptable = quit_program $ptable} #Is $ptable needed?
		default {write-host "Illegal Option" -ForegroundColor Red}

	} #End switch

} #End while loop / menu
