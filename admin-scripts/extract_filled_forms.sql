-- run as system or DBA user
create directory photo_dir as '/home/oracle/ims/PhotoDir';

grant read, write on directory photo_dir to demographic;

-- run as DEMOGRAPHIC
create or replace PROCEDURE extract_filled_form IS

 vblob BLOB;
 vstart NUMBER := 1;
 bytelen NUMBER := 32000;
 len NUMBER;
 my_vr RAW(32000);
 x NUMBER;

 l_output utl_file.file_type;
 v_filename varchar2(100);

 cursor photo_cur is
	SELECT 
		to_char(p.applicationdt,'yyyymmdd') as appdate
		,p.personalidno as PID
		,filledforms
	FROM demographic.person p
	WHERE (
			p.MOBILNO1 IS NOT  NULL
		OR p.MOBILNO2 IS NOT  NULL
		OR p.MOBILNO3 IS NOT  NULL
		OR p.BUSINESTELNO IS NOT NULL
		OR p.hometelno is not null
		)
	AND (
		(length(p.MOBILNO1) <> 10)
		or (length(p.MOBILNO2) <> 10)
		or (length(p.MOBILNO3) <> 10)
		or (length(p.BUSINESTELNO) <> 10)
		or (length(p.hometelno) <> 10)
		)
	AND TRUNC(p.applicationdt) BETWEEN '25-JAN-13' AND  TRUNC(SYSDATE)
	AND filledforms is NOT null
	and testdata = 0
  ORDER BY 2,1;

 photo_cur_rec photo_cur%rowtype;

BEGIN

 for photo_cur_rec in photo_cur 
 loop
 -- initialize variables
 vstart := 1;
 bytelen := 32000;

  -- get length of blob
  len := dbms_lob.getlength(photo_cur_rec.filledforms);
  -- select blob into variable
  vblob := photo_cur_rec.filledforms;

  -- set filename
  v_filename := photo_cur_rec.pid||'_'||photo_cur_rec.appdate||'.jpg';
  
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
/
