
$openmrs_folder_name = 'openmrs_test_server_folder'
$openmrs_user_name = 'openmrs_test'

$openmrs_server_path = "~/openmrs/$($openmrs_folder_name)"
$maven_path = Get-Command mvn | select -expandproperty Path

# Make sure maven exists in the PATH
If ( !(Test-Path $maven_path) ) {
  echo "Couldn't find maven at directory '$maven_path'"
  exit 1
}

# Make sure the openmrs server folder doesn't exist
If ( Test-Path -Path $openmrs_server_path ) {
  $answer = Read-Host -Prompt "$($openmrs_server_path) already exists. Do you want to delete it? (y/n)"
  If ( $answer -eq 'y' ) {
    Remove-Item -Recurse $openmrs_server_path
    echo "Deleted $openmrs_server_path"
  } Else {
    exit 1
  }
}

# Test MySQL connection
mysql -u root --password=openmrs -e "show databases" *> $null
If ( $LASTEXITCODE -eq 0 ) {
  echo "Connection to MySQL Successful."
} Else {
  echo "Error: Failed to connect to MySQL, check your credentials."
  exit 1
}

# Make a MySQL test user
$sql_password = 'openmrs'  # read-host 'Enter MySQL Root Password' -AsSecureString
mysql -u root --password=$sql_password -e "CREATE USER '$openmrs_user_name'@'localhost' IDENTIFIED BY ''" *> $null
If ( $LASTEXITCODE -eq 0 ) {
  echo "Successfully added new user '$openmrs_user_name' to the database."
} Else {
  echo "Error: Failed to add new user '$openmrs_user_name' to the database."
  exit 1
}

# Grant permissions to the new user
mysql -u root --password=$sql_password -e "GRANT ALL PRIVILEGES ON * . * TO '$openmrs_user_name'@'localhost'" *> $null
If ( $LASTEXITCODE -eq 0 ) {
  echo "Successfully granted all privileges to '$openmrs_user_name'."
} Else {
  echo "Error: Failed to grant privileges to user '$openmrs_user_name'."
  exit 1
}

# Test MySQL connection with new user
mysql -u $openmrs_user_name -e "show databases" *> $null
If ( $LASTEXITCODE -eq 0 ) {
  echo "MySQL connection with new user successful."
} Else {
  echo "Error: Failed to connect to MySQL as '$openmrs_user_name'."
  exit 1
}

python test_old.py $maven_path $openmrs_user_name
python test_new.py $maven_path $openmrs_user_name

# Remove the test user from the database
mysql -u root --password=$sql_password -e "DROP USER '$openmrs_user_name'@'localhost'" *> $null
If ( $LASTEXITCODE -eq 0 ) {
  echo "Successfully removed '$openmrs_user_name' from the database."
} Else {
  echo "Error: Failed to drop user '$openmrs_user_name' from the database."
  exit 1
}
