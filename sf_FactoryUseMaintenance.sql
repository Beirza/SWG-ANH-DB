

CREATE  FUNCTION `sf_FactoryUseMaintenance`(fID BIGINT(20)) RETURNS int(11)
BEGIN





  DECLARE maint INTEGER;
  DECLARE maintcalc INTEGER;
  DECLARE maintchar VARCHAR(128);
  DECLARE rate INTEGER;
  DECLARE decayrate INTEGER;
  DECLARE quantity INTEGER;

  DECLARE active INTEGER;
  DECLARE struct_condition INTEGER;
  DECLARE percent FLOAT;
  DECLARE owner BIGINT(20);
  DECLARE bank INTEGER;
  DECLARE cr INTEGER;
  DECLARE ret INTEGER;
  DECLARE maxcondition INTEGER;
  DECLARE currentcondition INTEGER;




  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
  BEGIN
    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;
    RETURN 3;
  END;




  SELECT s.owner FROM structures s WHERE s.ID =fID INTO owner;
  SELECT b.credits FROM banks b WHERE b.id =(owner+4) INTO bank;







  SELECT sa.VALUE FROM structure_attributes sa WHERE sa.structure_id =fID AND sa.attribute_id = 382 INTO maintchar;
  SELECT CAST(maintchar AS SIGNED) INTO maint;





  SELECT st.maint_cost_wk FROM structures s INNER JOIN structure_type_data st ON (s.TYPE = st.TYPE) WHERE s.ID =fID  INTO rate;
  SELECT st.decay_rate FROM structures s INNER JOIN structure_type_data st ON (s.TYPE = st.TYPE) WHERE s.ID =fID  INTO decayrate;

  SELECT st.max_condition FROM structures s INNER JOIN structure_type_data st ON (s.TYPE = st.TYPE) WHERE s.ID =fID  INTO maxcondition;





  IF(maint >= rate)THEN


      SELECT CAST((maint - (rate/336)) AS SIGNED) INTO maintcalc;
      SELECT CAST((maintcalc ) AS CHAR(128)) INTO maintchar;


      UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id = fID AND sa.attribute_id = 382;






      return 0;


   END IF;

  IF(maint < rate)THEN
    SELECT ((rate/336)-maint) INTO cr;

    SELECT '0' INTO maintchar;

    UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id =fID AND sa.attribute_id = 382;
    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;


  END IF;



  IF(bank >= cr) THEN

    UPDATE banks SET credits = credits-cr WHERE id =(owner+4);





    return 1;

  END IF;


  IF(bank < cr) THEN

    UPDATE banks SET credits = 0 WHERE id =(owner+4);

    SELECT((rate/336) - bank) INTO cr;




    SELECT (cr/(rate/100)) INTO percent;
    SELECT s.condition  FROM structures WHERE s.ID = fID INTO currentcondition;
    if (currentcondition+(decayrate*percent)) >0 THEN
    	UPDATE structures s SET s.condition = (s.condition +(decayrate*percent)) WHERE s.ID = fID;
    ELSE
    	UPDATE structures s SET s.condition =0 ;
	END if;




    SELECT s.condition FROM structures s WHERE s.ID = fID  INTO struct_condition;






    if(struct_condition >= maxcondition) THEN
      UPDATE structures s SET s.condition = maxcondition WHERE s.ID = fID;
      return 3;
    END IF;



    UPDATE factories f SET f.active = 0 WHERE f.ID = fID;




    return 2;

  END IF;







  RETURN 5;





END
