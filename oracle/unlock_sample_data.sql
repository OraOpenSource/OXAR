set define '^'
set verify off

ACCEPT new_hr_pass CHAR PROMPT 'Please enter a password for the hr schema: ' HIDE

alter user hr account unlock;
/

alter user hr identified by ^new_hr_pass;
/

exit
