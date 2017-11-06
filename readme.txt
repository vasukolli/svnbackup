Systax:

files_purge <directory>

Usage: 
-set "RETENTION" variable in script file
-execute command
files_purge  /home/user/Documents/script/tests/


Test:

-create old files
touch -t <date> <filename>
 ex: touch -t 201710120000 samplefile

-execute script on folder where above files created


Sample:

vasu@vasu-Aspire-5733Z ~/Documents/script $ cd tests/
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ touch -t 201710120000 file1
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ touch -t 201710120000 file2
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ touch  file3
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ ls
file1  file2  file3
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ ls -alh
total 8.0K
drwxr-xr-x 2 vasu vasu 4.0K Nov  6 22:58 .
drwxr-xr-x 3 vasu vasu 4.0K Nov  6 22:58 ..
-rw-r--r-- 1 vasu vasu    0 Oct 12 00:00 file1
-rw-r--r-- 1 vasu vasu    0 Oct 12 00:00 file2
-rw-r--r-- 1 vasu vasu    0 Nov  6 22:58 file3
vasu@vasu-Aspire-5733Z ~/Documents/script/tests $ cd ..
vasu@vasu-Aspire-5733Z ~/Documents/script $ ./files_purge  ~/Documents/script/tests/
Files to be deleted:
/home/vasu/Documents/script/tests/file1
/home/vasu/Documents/script/tests/file2
Continue (y/n)?y
yes
removed '/home/vasu/Documents/script/tests/file1'
removed '/home/vasu/Documents/script/tests/file2'
vasu@vasu-Aspire-5733Z ~/Documents/script $ 


