
CREATE FUNCTION `sf_HarvesterUseMaintenance`(hID BIGINT(20)) RETURNS int(11)
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
  DECLARE currentcondition INTEGER;




  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
  BEGIN
    UPDATE harvesters h SET h.active = 0 WHERE h.ID = hID;
    RETURN 3;
  END;




  SELECT s.owner FROM structures s WHERE s.ID =hID INTO owner;
  SELECT b.credits FROM banks b WHERE b.id =(owner+4) INTO bank;





  SELECT sa.VALUE FROM structure_attributes sa WHERE sa.structure_id =hID AND sa.attribute_id = 382 INTO maintchar;
  SELECT CAST(maintchar AS SIGNED) INTO maint;





  SELECT st.maint_cost_wk FROM structures s INNER JOIN structure_type_data st ON (s.TYPE = st.TYPE) WHERE s.ID =hID  INTO rate;
  SELECT st.decay_rate FROM structures s INNER JOIN structure_type_data st ON (s.TYPE = st.TYPE) WHERE s.ID =hID  INTO decayrate;





  IF(maint >= rate)THEN
      SELECT CAST((maint - (rate/336)) AS SIGNED) INTO maintcalc;
      SELECT CAST((maintcalc) AS CHAR(128)) INTO maintchar;
      UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id =hID AND sa.attribute_id = 382;






      return 0;


   END IF;

  IF(maint < rate)THEN
    SELECT ((rate/336)-maint) INTO cr;

    SELECT '0' INTO maintchar;

    UPDATE structure_attributes sa SET sa.VALUE = maintchar WHERE sa.structure_id =hID AND sa.attribute_id = 382;
    UPDATE harvesters h SET h.active = 0 WHERE h.ID = hID;


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





    SELECT s.condition FROM structures s WHERE s.ID =hID  INTO struct_condition;





    if(struct_condition <= 0) THEN
      UPDATE structures s SET s.condition = 0 WHERE s.ID =hID;
      return 3;
    END IF;



    UPDATE harvesters h SET h.active = 0 WHERE h.ID = hID;




    return 2;

  END IF;







  RETURN 5;





END