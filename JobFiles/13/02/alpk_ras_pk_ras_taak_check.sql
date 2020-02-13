create or replace PACKAGE     ras.pk_ras_taak_check IS

  /* GD 16-11-2011 */
  FUNCTION f_taak_open_uniek(p_object_categorie_id NUMBER, p_ref_id NUMBER) RETURN NUMBER;
  
  /* 27-04-2012 */
  FUNCTION f_mag_persoon_taak_zien(p_taak_id NUMBER, p_persoon_id NUMBER) RETURN NUMBER;
  /* 16-07-2019 */
  FUNCTION f_can_p_edit_if_not_c(p_taak_id NUMBER, p_persoon_id NUMBER) RETURN NUMBER;  

  /* 30-07-2019 */
  FUNCTION f_check_cat_ou_exists(p_categorie_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER;
  /* FV 13-01-2020 */ 
  FUNCTION f_can_apex_execute(p_taak_id NUMBER) RETURN NUMBER;
  /* FV 15-01-2020 */ 
  FUNCTION f_can_fu_be_made(p_cat_ou_id NUMBER) RETURN NUMBER;
  
END;
/

create or replace PACKAGE BODY     ras.pk_ras_taak_check IS

  /* GD 16-11-2011 */
  FUNCTION f_taak_open_uniek(p_object_categorie_id NUMBER, p_ref_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER, cp_ref_id NUMBER) IS
         SELECT 'J'
         FROM RAS_TA_TAAK
         WHERE OBJECT_CATEGORIE_ID = cp_object_categorie_id
         AND   REF_ID = cp_ref_id
         AND   TAAK_STATE_CODE = pk_ras_taak_general.c_open;
     -- VARIABLES --
     v_loc NUMBER := 1;
  BEGIN
     FOR r_cur IN c_cur(p_object_categorie_id, p_ref_id) LOOP
         v_loc := 0;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  /* 27-04-2012 */
  FUNCTION f_mag_persoon_taak_zien(p_taak_id NUMBER, p_persoon_id NUMBER) RETURN NUMBER IS
     -- ROWTYPES --
     r_ta_taak RAS_TA_TAAK%ROWTYPE := NULL;
     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     r_ta_taak := PK_RAS_TAAK_GENERAL.F_GET_TAAK_RECORD(p_taak_id);

     SELECT 1 INTO v_loc
       FROM table(pk_cebe_org_int.f_get_pers_opvolgers(p_persoon_id))
      WHERE pk_cebe_org_int.f_is_persoon_actief_in_unit(per_persoon_id, r_ta_taak.owner_org_unit_id) = 1;
     RETURN v_loc;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      RETURN 0;
    WHEN TOO_MANY_ROWS
    THEN
      RETURN 1;
  END;
  
  /* FV 16-07-2019 */
  -- TERRIBLE PERFORMANCE
  FUNCTION f_can_p_edit_if_not_c(p_taak_id NUMBER, p_persoon_id NUMBER) RETURN NUMBER IS
     -- ROWTYPES --
     r_ta_taak RAS_TA_TAAK%ROWTYPE := NULL;
     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     r_ta_taak := PK_RAS_TAAK_GENERAL.F_GET_TAAK_RECORD(p_taak_id);
     SELECT 1 INTO v_loc
       FROM table(pk_cebe_org_int.f_get_pers_opvolgers(p_persoon_id))
       WHERE pk_cebe_org_int.f_is_persoon_actief_in_unit(per_persoon_id, r_ta_taak.owner_org_unit_id) = 1
        AND r_ta_taak.taak_state_code <> 'CLOSED';
       RETURN v_loc;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      RETURN 0;
    WHEN TOO_MANY_ROWS
    THEN
      RETURN 1;
  END;
    /* FV 30-07-2019 */
  FUNCTION f_check_cat_ou_exists(p_categorie_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER IS 
     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     SELECT 1 INTO v_loc
       FROM ras_ta_categorie_org_unit catou
      WHERE catou.categorie_id = p_categorie_id AND catou.org_unit_id = p_org_unit_id;
     RETURN v_loc;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      RETURN 0;
    WHEN TOO_MANY_ROWS
    THEN
      RETURN 1;
  END;

  FUNCTION f_can_apex_execute(p_taak_id NUMBER) RETURN NUMBER IS
     -- VARIABLES --
     v_loc NUMBER := 0;
     BEGIN
      SELECT 1 INTO v_loc
      FROM ras_ta_taak ta,ras_ta_object_categorie oc,ras_actie a
      WHERE ta.taak_id = p_taak_id
        AND (ta.ref_id IS NOT NULL OR LENGTH(TRIM (ta.ref_id)) <> 0 OR ta.ref_id = 0)
        AND ta.object_categorie_id = oc.object_categorie_id
        AND oc.actie_id = a.actie_id
        AND a.actie_type_code = 'PAGE';
      RETURN v_loc;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        RETURN 0;
      WHEN TOO_MANY_ROWS
        THEN
          RETURN 1;
  END;
  
  FUNCTION f_can_fu_be_made(p_cat_ou_id NUMBER) RETURN NUMBER IS
    -- VARIABLES --
    -- TODO: ONLY ONE FU can exist
    v_loc NUMBER := 0;
    BEGIN
      SELECT 1 INTO v_loc
      FROM ras_ta_cat_org_unit_fu fu
      WHERE fu.categorie_org_unit_id = p_cat_ou_id;
      RETURN v_loc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN 0;
      WHEN TOO_MANY_ROWS THEN RETURN 1;
  END;   
END;
