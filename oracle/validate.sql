/*
Validation script to check if XE installed
Usage: sqlplus -L system/oracle @script > /dev/null
exit $?
*/


select count(1)
from all_objects;

exit
