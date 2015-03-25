-- Substitution Strings


-- Don't expire passwords
alter profile default limit password_life_time unlimited;

-- Can verify here:
-- select username, profile from dba_users;
-- select * from dba_profiles

exit
