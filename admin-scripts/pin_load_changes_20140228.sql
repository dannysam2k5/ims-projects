-- 28/02/2014
-- Authour: Daniel Sam
-- script to amend pin and serial number loading
-- changes 
-- 1. add column (cardtype) to paycard table to show card type e.g. First Issue (I1), Second Issue (I2), etc
-- 2. existing records are updated with 'I1' in card_type column
-- 3. LOAD_NEW_PINS procedure updated to include card_type parameter used to populate cardtype column



spool pin_load_changes_20140228.txt
-- 1.
alter table paycard add cardtype varchar2(2);

-- 2.
update paycard set cardtype = 'I1';

commit;

connect ims_reports

alter table pin_audit add cardtype varchar2(2);

update pin_audit set cardtype = 'I1';

-- 3. updated procedure

create or replace
procedure load_new_pins(i_cardtype varchar2) authid current_user is

  s_date  date;    -- start time of load
  f_date  date;    -- finish time of load
  p_before number; -- counter for available valid pins before load
  p_after  number; -- counter for available valid pins after load
  p_reject number; -- counter for rejected pins
  p_valid number;  -- counter for valid pins
  p_keyno number; -- counter for keyno
  
  -- get new pins from csv file
  cursor new_pin_cur is
  select serial_no, pin from load_pins;
  
  -- check validity of new pin, serial no against existing
  cursor check_pin_cur(s in varchar2, p in varchar2) is
  select serno, pin from demographic.paycard where serno = s;
  
  check_pin_rec check_pin_cur%rowtype;
  
 begin
  -- initialise counters
  p_valid := 0;
  p_before := 0;
  p_after := 0;
  p_reject := 0;
  s_date := sysdate;
  
  
  -- calculate number of unused pins
  select count(*) into p_before from demographic.paycard where issuedt is null and usedt is null;
  
  -- get max keyno from table
  select max(keyno)
	into p_keyno
	from demographic.paycard;
  
  -- fetch new pin, serial set
  for new_pin_rec in new_pin_cur
  loop
   -- compare new serial, pin set against exisiting
  
   open check_pin_cur(ltrim(rtrim(new_pin_rec.serial_no)), ltrim(rtrim(new_pin_rec.pin))); 
   fetch check_pin_cur into check_pin_rec;
     
   if check_pin_cur%NOTFOUND then
    -- pin, serial number NOT loaded
    begin
	   p_keyno := p_keyno + 1;
     insert into demographic.paycard (keyno,serno, pin,cardtype) values (p_keyno,ltrim(rtrim(new_pin_rec.serial_no)), ltrim(rtrim(new_pin_rec.pin)),i_cardtype);
	   p_valid := p_valid + 1;
     commit;
    end; 
   else
    -- pin, serial number ALREADY loaded
	  begin
     insert into pin_reject (pin, serialno, load_date, description) 
	   values (new_pin_rec.pin, new_pin_rec.serial_no, sysdate, 'PIN, Serial No combination already exists');
     commit;
     p_reject := p_reject + 1;
    end;
   end if;
   close check_pin_cur;
  end loop;
 
  f_date := sysdate;
  select count(*) into p_after from demographic.paycard where issuedt is null and usedt is null;
  -- update pin audit table
  insert into PIN_AUDIT(start_date, finish_date,num_loaded,free_pins_before,free_pins_after,pins_reject,cardtype)
  values (s_date, f_date, p_valid, p_before, p_after,p_reject,i_cardtype);
  
  commit;
 
 exception
  when others then
    raise_application_error(-20000,sqlerrm);
 end;
 /
 
 spool off
 
 exit
 
/* -- Procedure Execution 
 
 BEGIN
GENERATEPIN(I_PINSET => 10000,
			I_BATCHTYPE => 'I2');
END;
/

 -- Legends
I_BATCHTYPE >> I1 (First Issuance)
			   I2 (Renewal)
			   R  (Replacement)
			   U   (Update)
			   
*/	