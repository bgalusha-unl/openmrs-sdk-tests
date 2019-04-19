
#!/bin/bash

openmrs_folder_name='test_folder'
openmrs_user_name='openmrs_test'
openmrs_server_path="$HOME/openmrs/$openmrs_folder_name"

# Make sure the openmrs server folder doesn't exist
if [[ -d "$openmrs_server_path" ]]
then
  read -p "$openmrs_server_path already exists. Do you want to delete it? (y/n)" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    rm -rf $openmrs_server_path
    echo "Deleted $openmrs_server_path"
  else
    exit 1
  fi
else
  echo "$openmrs_server_path does not exist, skipping removal"
fi

# Test MySQL connection
read -s -p "Enter the MySQL root password: " sql_password
echo
mysql -u root --password=$sql_password -e "show databases" > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "Connection to MySQL Successful."
else
  echo "Error: Failed to connect to MySQL, check your credentials."
  exit 1
fi

# Make a MySQL test user
mysql -u root --password=$sql_password -e "CREATE USER '$openmrs_user_name'@'localhost' IDENTIFIED BY ''" > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "Successfully added new user '$openmrs_user_name' to the database."
else
  echo "Error: Failed to add new user '$openmrs_user_name' to the database."
  exit 1
fi

# Grant permissions to the new user
mysql -u root --password=$sql_password -e "GRANT ALL PRIVILEGES ON * . * TO '$openmrs_user_name'@'localhost'" > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "Successfully granted all privileges to '$openmrs_user_name'."
else
  echo "Error: Failed to grant privileges to user '$openmrs_user_name'."
  exit 1
fi

# Test MySQL connection with new user
mysql -u $openmrs_user_name -e "show databases" > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "MySQL connection with new user successful."
else
  echo "Error: Failed to connect to MySQL as '$openmrs_user_name'."
  exit 1
fi

echo
echo "---BEGIN TESTS---"
echo

for TEST_FILE in $(ls test*.py)
do
  python3 $TEST_FILE $openmrs_user_name $openmrs_folder_name
  if [[ $? -eq 0 ]]
  then
    echo "$TEST_FILE Passed"
  else
    echo "$TEST_FILE Failed"
  fi

  rm -rf $openmrs_server_path
done

echo
echo "---TESTS FINISHED---"
echo

# Remove the test user from the database
mysql -u root --password=$sql_password -e "DROP USER '$openmrs_user_name'@'localhost'" > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
  echo "Successfully removed '$openmrs_user_name' from the database."
else
  echo "Error: Failed to drop user '$openmrs_user_name' from the database."
  exit 1
fi
