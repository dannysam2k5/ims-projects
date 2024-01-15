-- 16/09/2014
-- Authour: Daniel Sam
-- Script: Load_Picture_from File SP.sql
-- Description: The Stored procedure is intended to load pictures from a file into the database.



create or replace procedure ims_load_picture_from_file(i_afisid in integer,
i_photo_filename varchar2, i_sign_filename varchar2, i_fillform_filename varchar2, i_otherform_filename varchar2, i_printcard_filename varchar2, i_passport_filename varchar2) is

photo_file bfile := bfilename('LOAD_SCRATCH_DIR',i_photo_filename);
sign_file bfile := bfilename('LOAD_SCRATCH_DIR',i_sign_filename);
fillform_file bfile := bfilename('LOAD_SCRATCH_DIR',i_fillform_filename);
otherform_file bfile := bfilename('LOAD_SCRATCH_DIR',i_otherform_filename);
printcard_file bfile := bfilename('LOAD_SCRATCH_DIR',i_printcard_filename);
passport_file bfile := bfilename('LOAD_SCRATCH_DIR',i_passport_filename);

i_photo blob;
i_sign blob;
i_fillform blob;
i_otherform blob;
i_printcard blob;
i_passport blob;

amt_photo number;
amt_sign number;
amt_fillform number;
amt_otherform number;
amt_printcard number;
amt_passport number;

begin

-- open the target BLOB locator
dbms_output.put_line('Creating temproary BLOB files');
dbms_lob.createtemporary(i_photo, TRUE);
dbms_lob.createtemporary(i_sign,TRUE);
dbms_lob.createtemporary(i_fillform,TRUE);
dbms_lob.createtemporary(i_otherform,TRUE);
dbms_lob.createtemporary(i_printcard,TRUE);
dbms_lob.createtemporary(i_passport,TRUE);

dbms_output.put_line('Opening BLOB files');
dbms_lob.open(photo_file, dbms_lob.file_readonly);
dbms_lob.open(sign_file, dbms_lob.file_readonly);
dbms_lob.open(fillform_file, dbms_lob.file_readonly);
dbms_lob.open(otherform_file, dbms_lob.file_readonly);
dbms_lob.open(printcard_file, dbms_lob.file_readonly);
dbms_output.put_line('Opening passport files');
dbms_lob.open(passport_file, dbms_lob.file_readonly);

-- get length of file
amt_photo := dbms_lob.getlength(photo_file);
amt_sign := dbms_lob.getlength(sign_file);
amt_fillform := dbms_lob.getlength(fillform_file);
amt_otherform := dbms_lob.getlength(otherform_file);
amt_printcard := dbms_lob.getlength(printcard_file);
amt_passport := dbms_lob.getlength(passport_file);


dbms_output.put_line('Size of photo file: '||amt_photo);
dbms_output.put_line('Size of signature file: '||amt_sign);
dbms_output.put_line('Size of filled form file: '||amt_fillform);
dbms_output.put_line('Size of other form file: '||amt_otherform);
dbms_output.put_line('Size of printed card file: '||amt_printcard);
dbms_output.put_line('Size of printed card file: '||amt_passport);

-- load contents of the BFILE into the BLOB column
 begin
  dbms_lob.loadfromfile(i_photo,photo_file,amt_photo);
  dbms_output.put_line('Loaded photo');
  if i_photo is not null then
    update demographic.person set photo = i_photo where afisid = i_afisid;
  end if;
 exception
  when others then
   null;
 end;

begin
dbms_lob.loadfromfile(i_sign,sign_file,amt_sign);
dbms_output.put_line('Loaded signature');
if i_sign is not null then
update demographic.person set signature = i_sign where afisid = i_afisid;
end if;
exception
  when others then
   null;
 end;

 -- filled form
begin
  dbms_lob.loadfromfile(i_fillform,fillform_file,amt_fillform);
  dbms_output.put_line('Loaded filled form');
  if i_fillform is not null then
    update demographic.person set filledforms = i_fillform where afisid = i_afisid;
  end if;
exception
  when others then
   null;
end;

 -- other form
begin
dbms_lob.loadfromfile(i_otherform,otherform_file,amt_otherform);
dbms_output.put_line('Loaded other form');
if i_otherform is not null then
update demographic.person set otherforms = i_otherform where afisid = i_afisid;
end if;
exception
  when others then
   null;
 end;


 -- printed card
begin
dbms_lob.loadfromfile(i_printcard,printcard_file,amt_printcard);
dbms_output.put_line('Loaded printed card');
if i_printcard is not null then
update demographic.person set printedidcard = i_printcard where afisid = i_afisid;
end if;
exception
  when others then
   null;
 end;

 -- passport
begin
dbms_lob.loadfromfile(i_passport,passport_file,amt_passport);
dbms_output.put_line('Loaded passport');
if i_passport is not null then
update demographic.person set passport = i_passport where afisid = i_afisid;
end if;
exception
  when others then
   null;
 end;

commit;

-- close BLOBs
dbms_lob.close(passport_file);
dbms_output.put_line('Closed passport file');
dbms_lob.close(printcard_file);
dbms_output.put_line('Closed printed card file');
dbms_lob.close(otherform_file);
dbms_output.put_line('Closed other form file');
dbms_lob.close(fillform_file);
dbms_output.put_line('Closed filled form file');
dbms_lob.close(sign_file);
dbms_output.put_line('Closed signature file');
dbms_lob.close(photo_file);
dbms_output.put_line('Closed photo file');

exception
 when others then
  dbms_output.put_line('Error updating BLOB fields: '||sqlerrm);
end;