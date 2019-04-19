import pexpect
import sys
import os

TIMEOUT = 900
mysql_user = sys.argv[1]
openmrs_server_folder = sys.argv[2]

child = None
if os.name == "nt":
    print("Error: Windows not supported")
elif os.name == "posix":
    child = pexpect.spawn("mvn openmrs-sdk:setup", encoding="utf-8")
else:
    print("Error: Unsupported system")

# for debugging, print the program"s output to stdout
#child.logfile = sys.stdout
try:
    child.expect("Setting up a new server", timeout=TIMEOUT)
    child.expect("Specify server id", timeout=TIMEOUT)
    child.sendline(openmrs_server_folder)
    child.expect("Which one do you choose?", timeout=TIMEOUT)
    child.sendline("1")
    child.expect("Which one do you choose?", timeout=TIMEOUT)
    child.sendline("2")
    child.expect("What port would you like your server to use?", timeout=TIMEOUT)
    child.sendline("")
    child.expect("If you want to enable remote debugging by default when running the server,", timeout=TIMEOUT)
    child.sendline("")
    child.expect("Which database would you like to use?", timeout=TIMEOUT)
    child.sendline("1")
    child.expect("The distribution requires MySQL database. Please specify database uri", timeout=TIMEOUT)
    child.sendline("")
    child.expect("Please specify database username", timeout=TIMEOUT)
    child.sendline(mysql_user)
    child.expect("Please specify database password", timeout=TIMEOUT)
    child.sendline("")
    child.expect("Failed to connect to the specified database", timeout=5)
except:
    sys.exit(1)
sys.exit(0)
