-- 20/02/2015
-- Authour: Daniel Sam
-- Script: extract_finger_prints.sql
-- Description: The Stored procedure extract the finger prints of applicants in the DAFIS database.



create or replace PROCEDURE extract_finger_prints IS

 vblob BLOB;
 vstart NUMBER := 1;
 bytelen NUMBER := 32000;
 len NUMBER;
 my_vr RAW(32000);
 x NUMBER;

 l_output utl_file.file_type;
 v_filename varchar2(100);

 cursor print_cur is
	SELECT 
			p.personalidno pid
			,tbf.afisid afisid
			,tbf.FPPOSITION FPPOSITION
			,tbf.FPIMAGE FPIMAGE
FROM DAFIS.TBFPIMAGES tbf,DEMOGRAPHIC.PERSON p
where tbf.afisid = p.afisid 
AND  p.personalidno = 'CAN-010015818-0'
/*
(
'CAN-010015818-0',
'SYR-010057305-8',
'CHE-010058278-1',
'ITA-010029187-2',
'IND-010021116-6',
'LBN-010013827-1',
'PHL-010014312-1',
'IND-010036451-5',
'USA-010062272-1',
'DEU-010039539-B',
'ISR-010017620-G',
'IND-010065496-0',
'ISR-010005652-F',
'ISR-010005651-E',
'IND-010003589-D')
*/
order by tbf.AFISID,tbf.FPPOSITION;

 print_cur_rec print_cur%rowtype;

BEGIN

 for print_cur_rec in print_cur 
 loop
 -- initialize variables
 vstart := 1;
 bytelen := 32000;

  -- get length of blob
  len := dbms_lob.getlength(print_cur_rec.FPIMAGE);
  -- select blob into variable
  vblob := print_cur_rec.FPIMAGE;

  -- set filename
  v_filename := print_cur_rec.pid||'_'||print_cur_rec.FPPOSITION||'.wsq';
  
  
  
 -- define output directory
	l_output := utl_file.fopen('PHOTO_DIR', v_filename,'wb', 32760);
  
  -- save blob length
	x := len;

	-- if small enough for a single write
	IF len < 32760 THEN 
	utl_file.put_raw(l_output,vblob);
	 utl_file.fflush(l_output);
	ELSE -- write in pieces
	 vstart := 1;
	
		WHILE vstart < len and bytelen > 0
		LOOP
		 dbms_lob.read(vblob,bytelen,vstart,my_vr);

		 utl_file.put_raw(l_output,my_vr);
		 utl_file.fflush(l_output); 

		-- set the start position for the next cut
		 vstart := vstart + bytelen;

		-- set the end position if less than 32000 bytes
		 x := x - bytelen;
		 IF 
		 x < 32000 
		 THEN bytelen := x; 
		 END IF;
		
		END LOOP;
	
  utl_file.fclose(l_output);

	end if;	
	
 end loop;
 utl_file.fclose(l_output); 
  
end;