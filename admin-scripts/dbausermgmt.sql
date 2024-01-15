/*
#SCRIPT:	dbausermgmt.sql
#AUTHOR:	Daniel Sam
#DATE:		23-July-2013
#REV:		1.1.P
#MODF:		
#PLATFORM:	Linux
#
#PURPOSE:	Creates External Database Users
#
#######################################################
#                                                     #
#######################################################
*/
 -- Create schema for dba's
create user &&username identified by imsnia123 
default tablespace ts_afis
temporary tablespace temp
quota unlimited on ts_afis;

GRANT CREATE session, resource, create view TO &&username;
 
grant ims_role to &&username;
 
 -- grants access to demographic tables
grant select on demographic.PAYCARD to &&username;
grant select on demographic.PAYCARDERR to &&username;
grant select on demographic.PAYCARDHIST to &&username;
grant select on demographic.PRINTHIST to &&username;
grant select on demographic.PERSON_GROUPIDCHECK to &&username;
grant select on demographic.PERSON_WORKFLOW to &&username;
grant select on demographic.LOOKUPSSETTINGS to &&username;
grant select on demographic.PERSON to &&username;

-- grants access to ims_reports views

grant select on ims_reports.daily_sold_cards to &&username;
grant select on ims_reports.daily_reg_applicants to &&username;
grant select on ims_reports.registration_per_nationality to &&username; 
grant select on ims_reports.registration_per_site to &&username;
grant select on ims_reports.registration_per_operator to &&username;
grant select on ims_reports.registration_per_occupation to &&username;


-- After Logon Script
create or replace TRIGGER &&username.after_logon_trg
AFTER LOGON ON &&username.SCHEMA
BEGIN
  DBMS_APPLICATION_INFO.set_module(USER, 'Initialized');
  EXECUTE IMMEDIATE 'ALTER SESSION SET current_schema=DEMOGRAPHIC';
END;
/
