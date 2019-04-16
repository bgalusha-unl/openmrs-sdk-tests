import pexpect
import sys
import os
from pexpect.popen_spawn import PopenSpawn

TIMEOUT = 900
maven_path = sys.argv[1]

child = None
if os.name == 'nt':
    print('Detected Platform: Windows')
    child = PopenSpawn(maven_path + ' openmrs-sdk:setup', encoding="utf-8")
elif os.name == 'posix':
    print('Detected Platform: Unix')
    child = pexpect.spawn('mvn openmrs-sdk:setup', encoding='utf-8')
else:
    print('Error, unsupported system')

child.logfile = sys.stdout

child.expect('Setting up a new server...', timeout=TIMEOUT)
child.expect('Specify server id', timeout=TIMEOUT)
child.sendline('myserver')
child.expect('Which one do you choose?', timeout=TIMEOUT)
child.sendline('1')
child.expect('Which one do you choose?', timeout=TIMEOUT)
child.sendline('2')
child.expect('What port would you like your server to use?', timeout=TIMEOUT)
child.sendline('')
child.expect('If you want to enable remote debugging by default when running the server,', timeout=TIMEOUT)
child.sendline('')
child.expect('Which database would you like to use?', timeout=TIMEOUT)
child.sendline('1')
child.expect('The distribution requires MySQL database. Please specify database uri', timeout=TIMEOUT)
child.sendline('')
