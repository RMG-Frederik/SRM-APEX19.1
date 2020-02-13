create or replace PACKAGE     pk_ras_taak_general IS

  -- constanten --
  c_open         CONSTANT VARCHAR2(12) := 'OPEN';
  c_inexecution  CONSTANT VARCHAR2(12) := 'INEXECUTION';
  c_closed       CONSTANT VARCHAR2(12) := 'CLOSED';
  c_completed    CONSTANT VARCHAR2(12) := 'COMPLETED';
  c_canceled     CONSTANT VARCHAR2(12) := 'CANCELED';

  /*TC 05/12/2011*/
  FUNCTION f_get_c_open RETURN VARCHAR2;

  FUNCTION f_get_c_inexecution RETURN VARCHAR2;

  FUNCTION f_get_c_closed RETURN VARCHAR2;

  FUNCTION f_get_c_completed RETURN VARCHAR2;

  FUNCTION f_get_c_canceled RETURN VARCHAR2;


  --- RAS_TA_CATEGORIE - functies --
  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_id(p_categorie_code VARCHAR2) RETURN NUMBER;
  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_code(p_categorie_id NUMBER) RETURN VARCHAR;
  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_desc(p_categorie_id NUMBER) RETURN VARCHAR2;
  /* TC 01-12-2011 */
  FUNCTION f_get_categorie_desc_from_taak(p_object_categorie_id NUMBER) RETURN VARCHAR2;
  -- RAS_TA_OBJECT_CATEGORIE - functies --
  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_id(p_object_code VARCHAR2, p_categorie_code VARCHAR2) RETURN NUMBER;
  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_prior(p_object_categorie_id NUMBER) RETURN NUMBER;
  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_uniek(p_object_categorie_id NUMBER) RETURN NUMBER;
  /* GD 20-02-2012 */
  FUNCTION f_get_object_cat_categorie_id(p_object_categorie_id NUMBER) RETURN NUMBER;
  /* GD 16-11-2011 */
  FUNCTION f_get_object_cat_man_close(p_object_categorie_id NUMBER) RETURN NUMBER;

  FUNCTION f_get_obj_cat_aanp_deadl(p_object_categorie_id NUMBER) RETURN VARCHAR2;
  
FUNCTION f_get_obj_cat_auto_inexec(p_object_categorie_id NUMBER) RETURN VARCHAR2;  

  -- RAS_TA_TAAK - functies --
  FUNCTION f_get_taak_state(p_taak_id NUMBER) RETURN VARCHAR2;
  FUNCTION f_get_taak_titel(p_taak_id NUMBER) RETURN VARCHAR2;
  FUNCTION f_get_taak_oms(p_taak_id NUMBER) RETURN VARCHAR2;

  FUNCTION f_get_taak_object(p_taak_id IN NUMBER, p_object_code IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION f_taak_op_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION f_taak_overdeadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER;

  FUNCTION f_taak_1dag_van_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER;

   FUNCTION f_taak_3dag_van_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER;

  -- RAS_TA_TAAK - acties --
  /* GD 16-11-2011 */
  PROCEDURE p_afsluiten_taak(p_taak_id          NUMBER,
                             p_close_state      VARCHAR2,
                             p_close_remark     VARCHAR2);

  /* GD 16-11-2011 */
  PROCEDURE p_set_owner_taak(p_taak_id     NUMBER,
                             p_owner_persoon_id    NUMBER);

  FUNCTION f_get_owner_taak(p_taak_id NUMBER) RETURN NUMBER;

  /* GD 16-11-2011 */
  PROCEDURE p_clear_owner(p_taak_id     NUMBER);

  /* TC 06-12-2011*/
  FUNCTION f_get_actie_id(p_taak_id NUMBER ) RETURN NUMBER;

  /* GD 16-02-2012 */
  FUNCTION f_get_taak_record(p_taak_id NUMBER) RETURN RAS_TA_TAAK%ROWTYPE;

  /* GD 07-05-2012 */
  PROCEDURE p_update_taak_text(p_taak_id NUMBER, p_titel VARCHAR2, p_body VARCHAR2);

  FUNCTION f_cat_is_auto_assign(p_object_categorie_id NUMBER) RETURN VARCHAR2;

  /* PD 09-09-2014 */
  FUNCTION f_get_open_taak_id(p_object_code VARCHAR2, p_categorie_code VARCHAR2, p_ref_id NUMBER) RETURN NUMBER;

  PROCEDURE p_update_taak_schedule(p_taak_id NUMBER, p_schedule_date DATE);

   /* BV 27-03-2015 */
  FUNCTION f_get_taak_id_notclosed(p_object_code VARCHAR2, p_categorie_code VARCHAR2, p_ref_id NUMBER) RETURN NUMBER;

  FUNCTION f_get_deadline_datum(p_schedule_date DATE, p_deadline_date DATE) RETURN DATE;

  FUNCTION f_mag_deadline_wijzigen(p_object_categorie_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER;

  /* FV 19/06/2019 */
  -- Get list of taak categories based on unit and object
  FUNCTION f_get_cats_for_unit_and_code(p_org_unit_id NUMBER,p_object_code VARCHAR2 DEFAULT 'TAAK') RETURN col_ras_ta_categorie;
  -- Get the omschrijving of a toewijzing combined withe the name of the assigned person/unit --
  FUNCTION f_get_toewijzing_desc(p_toewijzing_id NUMBER) RETURN VARCHAR2;
  -- Get the id of the categorie org unit
  FUNCTION f_get_cat_org_unit_id(p_cat_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER;
  -- Get the id of the default follow up task --
  FUNCTION f_get_cat_unit_default_fu_taak(p_cat_id NUMBER, p_org_unit_id NUMBER) RETURN VARCHAR2;
  -- Get the description of the category attached to an objectcategory id --
  FUNCTION f_get_cat_from_oc(p_obj_cat_id NUMBER) RETURN NUMBER;
  -- Get the description of the category attached to an objectcategory id --
  FUNCTION f_get_cat_desc_from_oc(p_obj_cat_id NUMBER) RETURN VARCHAR2;
  FUNCTION f_get_def_deadline_cat(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER;
  FUNCTION f_get_toewijzing_id_cat(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER;
  FUNCTION f_get_toewijzing_persoon_id(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER;
  FUNCTION f_get_toewijzing_org_unit_id(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER;
  PROCEDURE p_delete_toewijzingswaarde(p_cat_owner_id NUMBER);
  PROCEDURE p_add_vervolgtaak(p_obj_cat_id NUMBER,p_fu_categorie_id NUMBER, p_default_flag VARCHAR2);
  PROCEDURE p_add_toewijzingswaarde(p_cat_id NUMBER,p_owner_org_unit_id NUMBER, p_persoon_id NUMBER);
  PROCEDURE p_delete_vervolgtaak(p_cat_org_unit_fu_id NUMBER);
END;
/

create or replace PACKAGE BODY     ras.pk_ras_taak_general IS

  gc_submodule_naam VARCHAR2(30) := 'TAKEN';

  /*TC 05/12/2011*/
  FUNCTION f_get_c_open RETURN VARCHAR2
  IS
  BEGIN
    RETURN c_open;
  END;

  FUNCTION f_get_c_inexecution RETURN VARCHAR2
  IS
  BEGIN
    RETURN c_inexecution;
  END;

  FUNCTION f_get_c_closed RETURN VARCHAR2
  IS
  BEGIN
    RETURN c_closed;
  END;

  FUNCTION f_get_c_completed RETURN VARCHAR2
  IS
  BEGIN
    RETURN c_completed;
  END;

  FUNCTION f_get_c_canceled RETURN VARCHAR2
  IS
  BEGIN
    RETURN c_canceled;
  END;

    --- RAS_TA_CATEGORIE - functies --
  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_id(p_categorie_code VARCHAR2) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_categorie_code VARCHAR2) IS
         SELECT CATEGORIE_ID
         FROM RAS_TA_CATEGORIE
         WHERE CATEGORIE_CODE = cp_categorie_code;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_categorie_code) LOOP
         v_loc := r_cur.CATEGORIE_ID;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;
  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_code(p_categorie_id NUMBER) RETURN VARCHAR IS
     -- CURSORS --
     CURSOR c_cur(cp_categorie_id NUMBER) IS
         SELECT CATEGORIE_CODE
         FROM RAS_TA_CATEGORIE
         WHERE CATEGORIE_ID = cp_categorie_id;
     -- VARIABLES --
     v_loc VARCHAR2(30) := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_categorie_id) LOOP
         v_loc := r_cur.CATEGORIE_CODE;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  /* GD 16-11-2011 */
  FUNCTION f_get_categorie_desc(p_categorie_id NUMBER) RETURN VARCHAR2 IS
     -- CURSORS --
     CURSOR c_cur(cp_categorie_id NUMBER) IS
         SELECT CATEGORIE_OMS
         FROM RAS_TA_CATEGORIE
         WHERE CATEGORIE_ID = cp_categorie_id;
     -- VARIABLES --
     v_loc VARCHAR2(255) := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_categorie_id) LOOP
         v_loc := r_cur.CATEGORIE_OMS;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  /* TC 01-12-2011 */
  FUNCTION f_get_categorie_desc_from_taak(p_object_categorie_id NUMBER) RETURN VARCHAR2 IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER) IS
         SELECT TC.CATEGORIE_OMS
         FROM RAS_TA_CATEGORIE TC, RAS_TA_OBJECT_CATEGORIE TOC
         WHERE TC.CATEGORIE_ID = TOC.CATEGORIE_ID
           AND TOC.OBJECT_CATEGORIE_ID = cp_object_categorie_id;
     -- VARIABLES --
     v_categorie_oms VARCHAR2(255);
  BEGIN
     OPEN c_cur(p_object_categorie_id);
     FETCH c_cur INTO v_categorie_oms;
     IF c_cur%NOTFOUND
     THEN
        v_categorie_oms := NULL;
     END IF;
     CLOSE c_cur;

     RETURN v_categorie_oms;
  END;

  -- RAS_TA_OBJECT_CATEGORIE - functies --
  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_id(p_object_code VARCHAR2, p_categorie_code VARCHAR2) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_id NUMBER, cp_categorie_id NUMBER) IS
         SELECT OBJECT_CATEGORIE_ID
         FROM RAS_TA_OBJECT_CATEGORIE
         WHERE OBJECT_ID = cp_object_id
         AND   CATEGORIE_ID = cp_categorie_id;
     -- VARIABLES --
     v_loc          NUMBER := NULL;
     v_object_id    NUMBER := NULL;
     v_categorie_id NUMBER := NULL;
  BEGIN
     v_object_id    := pk_ras_general.f_get_object_id(p_object_code);
     v_categorie_id := pk_ras_taak_general.f_get_categorie_id(p_categorie_code);

     IF (v_object_id IS NOT NULL) AND (v_categorie_id IS NOT NULL) THEN

        FOR r_cur IN c_cur(v_object_id, v_categorie_id) LOOP
            v_loc := r_cur.OBJECT_CATEGORIE_ID;
            EXIT;
        END LOOP;

     ELSE
        v_loc := null;                                                            -- object_id en/of categorie_id niet gevonden --
     END IF;

     RETURN v_loc;
  END;

  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_prior(p_object_categorie_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER) IS
         SELECT PRIORITEIT_ID
         FROM RAS_TA_OBJECT_CATEGORIE
         WHERE OBJECT_CATEGORIE_ID = cp_object_categorie_id;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_object_categorie_id) LOOP
         v_loc := r_cur.PRIORITEIT_ID;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  /* GD 16-11-2011 */
  FUNCTION f_get_object_categorie_uniek(p_object_categorie_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER) IS
        SELECT DECODE(UNIEK_OPEN_FLAG,'J',1,0) UNIEK_OPEN
        FROM RAS_TA_OBJECT_CATEGORIE
        WHERE OBJECT_CATEGORIE_ID = cp_object_categorie_id;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_object_categorie_id) LOOP
         v_loc := r_cur.UNIEK_OPEN;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  FUNCTION f_get_object_cat_categorie_id(p_object_categorie_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER) IS
         SELECT CATEGORIE_ID
         FROM RAS_TA_OBJECT_CATEGORIE
         WHERE OBJECT_CATEGORIE_ID = cp_object_categorie_id;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_object_categorie_id) LOOP
         v_loc := r_cur.CATEGORIE_ID;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  /* GD 16-11-2011 */
  FUNCTION f_get_object_cat_man_close(p_object_categorie_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_object_categorie_id NUMBER) IS
          SELECT DECODE(MAN_CLOSE_FLAG,'J',1,0) MAN_CLOSE
          FROM RAS_TA_OBJECT_CATEGORIE
          WHERE OBJECT_CATEGORIE_ID = cp_object_categorie_id;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_object_categorie_id) LOOP
         v_loc := r_cur.MAN_CLOSE;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  FUNCTION f_get_obj_cat_aanp_deadl(p_object_categorie_id NUMBER) RETURN VARCHAR2
  IS
    v_return VARCHAR2(1);
  BEGIN
    BEGIN
      SELECT aanp_deadl_flag INTO v_return
        FROM ras_ta_object_categorie
       WHERE object_categorie_id = p_object_categorie_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        v_return := 'N';
    END;
    RETURN v_return;
  END;
  
  FUNCTION f_get_obj_cat_auto_inexec(p_object_categorie_id NUMBER) RETURN VARCHAR2
  IS
    v_return VARCHAR2(1);
  BEGIN
    BEGIN
      SELECT auto_inexec_flag INTO v_return
        FROM ras_ta_object_categorie
       WHERE object_categorie_id = p_object_categorie_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        v_return := 'J';
    END;
    RETURN v_return;
  END;  

  FUNCTION f_get_taak_state(p_taak_id NUMBER) RETURN VARCHAR2 IS
     -- CURSORS --
     CURSOR c_cur(cp_taak_id NUMBER) IS
         SELECT TAAK_STATE_CODE
         FROM RAS_TA_TAAK
         WHERE TAAK_ID = cp_taak_id;
     -- VARIABLES --
     v_loc VARCHAR2(12) := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_taak_id) LOOP
         v_loc := r_cur.TAAK_STATE_CODE;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  FUNCTION f_get_taak_titel(p_taak_id NUMBER) RETURN VARCHAR2 IS
       -- CURSORS --
     CURSOR c_cur(cp_taak_id NUMBER) IS
         SELECT TITEL_TEKST
         FROM RAS_TA_TAAK
         WHERE TAAK_ID = cp_taak_id;
     -- VARIABLES --
     v_loc VARCHAR2(300) := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_taak_id) LOOP
         v_loc := r_cur.TITEL_TEKST;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;
  FUNCTION f_get_taak_oms(p_taak_id NUMBER) RETURN VARCHAR2 IS
       -- CURSORS --
     CURSOR c_cur(cp_taak_id NUMBER) IS
         SELECT CLOSED_OMS
         FROM RAS_TA_TAAK
         WHERE TAAK_ID = cp_taak_id;
     -- VARIABLES --
     v_loc VARCHAR2(3000) := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_taak_id) LOOP
         v_loc := r_cur.CLOSED_OMS;
         EXIT;
     END LOOP;

     RETURN v_loc;
  END;

  ------------
  -- Creatie: NN op 26102012
   FUNCTION f_get_taak_object(p_taak_id IN NUMBER, p_object_code IN VARCHAR2)
   RETURN VARCHAR2
   IS
     v_ref_code       ras_ta_taak_object.ref_code%TYPE;
     v_ref_id         ras_ta_taak_object.ref_id%TYPE;
     v_object_id      ras_object.object_id%TYPE;
   BEGIN
     v_object_id := pk_ras_general.f_get_object_id(p_object_code);

     SELECT ref_code, ref_id
     INTO v_ref_code, v_ref_id
     FROM ras_ta_taak_object
     WHERE taak_id = p_taak_id
     AND object_id = v_object_id;

      IF v_ref_code IS NOT NULL
      THEN
        RETURN v_ref_code;
      ELSE
        RETURN v_ref_id;
      END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;
   END f_get_taak_object;

  FUNCTION f_taak_op_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE pk_ras_taak_general.f_get_deadline_datum(shedule_datum, deadline_datum) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE+1)
          AND taak_state_code != 'CLOSED'
          AND owner_org_unit_id IN (SELECT org_unit_id
                                      FROM cb_org_unit
                                    START WITH org_unit_id IN (SELECT ou.org_unit_id
                                                                 FROM cb_org_unit ou, cb_org_unit_persoon oup
                                                                WHERE ou.org_unit_id = oup.org_unit_id
                                                                  AND persoon_id = pk_ras_globals.f_get_g_persoon_id)
                                    CONNECT BY PRIOR org_unit_id = master_org_unit_id);

      CURSOR c_cur1(cp_taak_id NUMBER) IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE pk_ras_taak_general.f_get_deadline_datum(shedule_datum, deadline_datum) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE+1)
          AND taak_state_code != 'CLOSED'
          AND taak_id = cp_taak_id;

     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     IF p_taak_id IS NULL
     THEN
       FOR r_cur IN c_cur LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     ELSE
       FOR r_cur1 IN c_cur1(p_taak_id) LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     END IF;

     RETURN v_loc;
  END;

  FUNCTION f_taak_overdeadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur IS
         SELECT 'J'
         FROM RAS_TA_TAAK
         WHERE SYSDATE > pk_ras_taak_general.f_get_deadline_datum(shedule_datum, deadline_datum)
         AND TAAK_STATE_CODE != 'CLOSED'
         AND OWNER_ORG_UNIT_ID IN (
                                   SELECT ORG_UNIT_ID
                                   FROM CB_ORG_UNIT
                                   START WITH ORG_UNIT_ID IN (
                                                              SELECT OU.ORG_UNIT_ID
                                                                FROM CB_ORG_UNIT OU,
                                                                     CB_ORG_UNIT_PERSOON OUP
                                                               WHERE OU.ORG_UNIT_ID = OUP.ORG_UNIT_ID
                                                                 AND OUP.PERSOON_ID = pk_ras_globals.f_get_g_persoon_id
                                                             )
                                   CONNECT BY PRIOR ORG_UNIT_ID = MASTER_ORG_UNIT_ID
                                  );
     CURSOR c_cur1(cp_taak_id NUMBER) IS
         SELECT 'J'
         FROM RAS_TA_TAAK
         WHERE SYSDATE > pk_ras_taak_general.f_get_deadline_datum(shedule_datum, deadline_datum)
           AND TAAK_STATE_CODE != 'CLOSED'
           AND TAAK_ID = cp_taak_id;
     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     IF p_taak_id IS NULL THEN
        FOR r_cur IN c_cur LOOP
            v_loc := 1;
            EXIT;
        END LOOP;
     ELSE
        FOR r_cur1 IN c_cur1(p_taak_id) LOOP
            v_loc := 1;
            EXIT;
        END LOOP;
     END IF;

     RETURN v_loc;
  END;

  FUNCTION f_taak_1dag_van_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE SYSDATE+1 >= NVL(TRUNC(SHEDULE_DATUM), TRUNC(DEADLINE_DATUM))
          AND taak_state_code != 'CLOSED'
          AND owner_org_unit_id IN (SELECT org_unit_id
                                      FROM cb_org_unit
                                    START WITH org_unit_id IN (SELECT ou.org_unit_id
                                                                 FROM cb_org_unit ou, cb_org_unit_persoon oup
                                                                WHERE ou.org_unit_id = oup.org_unit_id
                                                                  AND persoon_id = pk_ras_globals.f_get_g_persoon_id)
                                    CONNECT BY PRIOR org_unit_id = master_org_unit_id);

      CURSOR c_cur1(cp_taak_id NUMBER) IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE SYSDATE+1 >= NVL(TRUNC(SHEDULE_DATUM), TRUNC(DEADLINE_DATUM))
          AND taak_state_code != 'CLOSED'
          AND taak_id = cp_taak_id;

     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     IF p_taak_id IS NULL
     THEN
       FOR r_cur IN c_cur LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     ELSE
       FOR r_cur1 IN c_cur1(p_taak_id) LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     END IF;

     RETURN v_loc;
  END;

  FUNCTION f_taak_3dag_van_deadline(p_taak_id NUMBER DEFAULT NULL) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE SYSDATE+3 >= NVL(TRUNC(SHEDULE_DATUM), TRUNC(DEADLINE_DATUM))
          AND taak_state_code != 'CLOSED'
          AND owner_org_unit_id IN (SELECT org_unit_id
                                      FROM cb_org_unit
                                    START WITH org_unit_id IN (SELECT ou.org_unit_id
                                                                 FROM cb_org_unit ou, cb_org_unit_persoon oup
                                                                WHERE ou.org_unit_id = oup.org_unit_id
                                                                  AND persoon_id = pk_ras_globals.f_get_g_persoon_id)
                                    CONNECT BY PRIOR org_unit_id = master_org_unit_id);

      CURSOR c_cur1(cp_taak_id NUMBER) IS
        SELECT 'J'
        FROM RAS_TA_TAAK
        WHERE SYSDATE+3 >= NVL(TRUNC(SHEDULE_DATUM), TRUNC(DEADLINE_DATUM))
          AND taak_state_code != 'CLOSED'
          AND taak_id = cp_taak_id;

     -- VARIABLES --
     v_loc NUMBER := 0;
  BEGIN
     IF p_taak_id IS NULL
     THEN
       FOR r_cur IN c_cur LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     ELSE
       FOR r_cur1 IN c_cur1(p_taak_id) LOOP
           v_loc := 1;
           EXIT;
       END LOOP;
     END IF;

     RETURN v_loc;
  END;


  /* GD 16-11-2011 */
  PROCEDURE p_afsluiten_taak(p_taak_id          NUMBER,
                             p_close_state      VARCHAR2,
                             p_close_remark     VARCHAR2) IS
    e_closed EXCEPTION;
  BEGIN
     IF pk_ras_taak_general.f_get_taak_state(p_taak_id) != c_closed THEN
         UPDATE RAS_TA_TAAK
         SET TAAK_STATE_CODE = c_closed,
             TAAK_CLOSED_STATE_CODE = p_close_state,
             CLOSED_OMS             = p_close_remark
         WHERE TAAK_ID = p_taak_id;
         --
     ELSE
        RAISE e_closed;
     END IF;
  EXCEPTION
    WHEN e_closed THEN
      pk_ras_error.p_raise_handled_error('RAS-000008', gc_submodule_naam);  -- taak reeds afgesloten
      RAISE;
  END;

  /* GD 16-11-2011 */
  PROCEDURE p_set_owner_taak(
                             p_taak_id     NUMBER,
                             p_owner_persoon_id    NUMBER) IS
    e_closed EXCEPTION;
  BEGIN
     IF (pk_ras_taak_general.f_get_taak_state(p_taak_id) != c_closed) OR
        (pk_ras_taak_general.f_get_owner_taak(p_taak_id) IS NULL) THEN
         UPDATE ras_ta_taak
         SET owner_persoon_id = p_owner_persoon_id
         WHERE taak_id = p_taak_id;
         --
     ELSE
         RAISE e_closed;
     END IF;
  EXCEPTION
    WHEN e_closed THEN
      pk_ras_error.p_raise_handled_error('RAS-000008', gc_submodule_naam);  -- taak reeds afgesloten
      RAISE;
  END;

  /* GD 06-12-2013 */
  FUNCTION f_get_owner_taak(p_taak_id NUMBER) RETURN NUMBER IS
     -- CURSORS --
     CURSOR c_cur(cp_taak_id NUMBER) IS
        SELECT OWNER_PERSOON_ID
        FROM RAS_TA_TAAK
        WHERE TAAK_ID = cp_taak_id;
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     FOR r_cur IN c_cur(p_taak_id) LOOP
         v_loc := r_cur.owner_persoon_id;
     END LOOP;

     RETURN v_loc;
  END;

  /* GD 16-11-2011 */
  PROCEDURE p_clear_owner(p_taak_id     NUMBER) IS
    e_not_inexecution EXCEPTION;
  BEGIN
    IF pk_ras_taak_general.f_get_taak_state(p_taak_id) = c_inexecution THEN
        UPDATE RAS_TA_TAAK
        SET  owner_persoon_id = NULL
        WHERE TAAK_ID = p_taak_id;
        --
    ELSE
        RAISE e_not_inexecution;
    END IF;
  EXCEPTION
    WHEN e_not_inexecution THEN
      pk_ras_error.p_raise_handled_error('RAS-000009', gc_submodule_naam);  -- De taak staat niet meer in execution
      RAISE;
  END;

  FUNCTION f_get_actie_id(p_taak_id NUMBER ) RETURN NUMBER
  IS
    CURSOR c_actie IS
      SELECT toc.actie_id
        FROM ras_ta_taak tt, ras_ta_object_categorie toc
       WHERE tt.object_categorie_id = toc.object_categorie_id
         AND tt.taak_id = p_taak_id
         AND toc.actie_id IS NOT NULL;

    v_actie_id NUMBER;
  BEGIN
    OPEN c_actie;
    FETCH c_actie INTO v_actie_id;
    IF c_actie%NOTFOUND
    THEN
      v_actie_id := NULL;
    END IF;
    CLOSE c_actie;
    RETURN v_actie_id;
  END;

  FUNCTION f_get_taak_record(p_taak_id NUMBER) RETURN RAS_TA_TAAK%ROWTYPE IS
     -- ROWTYPES --
     r_loc RAS_TA_TAAK%ROWTYPE := NULL;
  BEGIN
     BEGIN
         SELECT *
         INTO r_loc
         FROM RAS_TA_TAAK
         WHERE TAAK_ID = p_taak_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN r_loc := NULL;
     END;

     RETURN r_loc;
  END;

  PROCEDURE p_update_taak_text(p_taak_id NUMBER, p_titel VARCHAR2, p_body VARCHAR2) IS
  BEGIN
     UPDATE RAS_TA_TAAK
     SET TITEL_TEKST = p_titel,
         OMSCHRIJVING = p_body
     WHERE TAAK_ID = p_taak_id;
  END;

  FUNCTION f_cat_is_auto_assign(p_object_categorie_id NUMBER) RETURN VARCHAR2
  IS
    v_ok VARCHAR2(1);
  BEGIN
    SELECT auto_assign_flag INTO v_ok
      FROM ras_ta_object_categorie
     WHERE object_categorie_id = p_object_categorie_id;
  RETURN v_ok;
  END;

  /* PD 09-09-2014 */
  FUNCTION f_get_open_taak_id(p_object_code VARCHAR2, p_categorie_code VARCHAR2, p_ref_id NUMBER) RETURN NUMBER
  IS
    v_taak_id NUMBER := NULL;
  BEGIN
    BEGIN
    SELECT T.TAAK_ID
    INTO v_taak_id
    FROM RAS_TA_TAAK T
    WHERE T.OBJECT_CATEGORIE_ID = pk_ras_taak_api.f_get_object_categorie_id(p_object_code, p_categorie_code)
      AND T.REF_ID = p_ref_id
      AND T.TAAK_STATE_CODE in ('OPEN','INEXECUTION');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN TOO_MANY_ROWS THEN
        pk_ras_error.p_raise_handled_error('RAS-000047', gc_submodule_naam);  -- meerdere open taken
        RAISE;
    END;

    RETURN v_taak_id;
  END;

  PROCEDURE p_update_taak_schedule(p_taak_id NUMBER, p_schedule_date DATE)
  IS
  BEGIN
    UPDATE ras_ta_taak
       SET shedule_datum = p_schedule_date
     WHERE taak_id = p_taak_id;
  END;

  /* BV 27-03-2015 */
  FUNCTION f_get_taak_id_notclosed(p_object_code VARCHAR2, p_categorie_code VARCHAR2, p_ref_id NUMBER) RETURN NUMBER
  IS
    v_taak_id NUMBER := NULL;
  BEGIN
    BEGIN
    SELECT T.TAAK_ID
    INTO v_taak_id
    FROM RAS_TA_TAAK T
    WHERE T.OBJECT_CATEGORIE_ID = pk_ras_taak_api.f_get_object_categorie_id(p_object_code, p_categorie_code)
      AND T.REF_ID = p_ref_id
      AND T.TAAK_STATE_CODE != 'CLOSED';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN TOO_MANY_ROWS THEN
        pk_ras_error.p_raise_handled_error('RAS-000047', gc_submodule_naam);  -- meerdere open taken
        RAISE;
    END;

    RETURN v_taak_id;
  END;

  FUNCTION f_get_deadline_datum(p_schedule_date DATE, p_deadline_date DATE) RETURN DATE
  IS
    v_date DATE;
  BEGIN
    v_date := NVL(p_schedule_date, p_deadline_date);
    IF v_date = TRUNC(v_date)
    THEN
      v_date := to_date(to_char(v_date, 'DD/MM/YYYY') || ' 23:59:59', 'DD/MM/YYYY HH24:MI:SS');
    END IF;
    RETURN v_date;
  END;

  FUNCTION f_mag_deadline_wijzigen(p_object_categorie_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER
  IS
    v_ok NUMBER := 0;
    v_aanp_deadl_flag VARCHAR2(1);
  BEGIN
    v_aanp_deadl_flag := pk_ras_taak_general.f_get_obj_cat_aanp_deadl(p_object_categorie_id);
    IF pk_cebe_org_int.f_heeft_persoon_rol(pk_ras_globals.f_get_g_persoon_id, p_org_unit_id, 'ADMIN') = 1
       AND v_aanp_deadl_flag ='J'
    THEN
       v_ok := 1;
    END IF;
    RETURN v_ok;
  END;

  -- fvantroy 05/07/2019
  -- Ophalen alle categorieen die hangen aan unit en onderliggende units
  -- Optioneel kan een object meegegeven worden als extra filter
  FUNCTION f_get_cats_for_unit_and_code(p_org_unit_id NUMBER,p_object_code VARCHAR2 DEFAULT 'TAAK') RETURN col_ras_ta_categorie IS
  --VARS
  v_col_ras_ta_categorie   col_ras_ta_categorie;
  BEGIN
    SELECT DISTINCT obj_ras_ta_categorie(catobj.object_categorie_id, cat.categorie_code,cat.categorie_oms)
    BULK COLLECT INTO v_col_ras_ta_categorie
    FROM ras_ta_categorie cat, ras_ta_categorie_org_unit catou,ras_ta_object_categorie catobj, ras_object obj
    WHERE catou.org_unit_id IN (SELECT DISTINCT org_unit_id FROM TABLE(pk_cebe_org_general.f_get_org_units(p_org_unit_id)))
    AND catobj.categorie_id = cat.categorie_id
    AND catou.categorie_id = cat.categorie_id
    AND obj.object_code = p_object_code
    AND catobj.object_id = obj.object_id;
    return v_col_ras_ta_categorie;
  END;

  FUNCTION f_get_toewijzing_desc(p_toewijzing_id NUMBER) RETURN VARCHAR2 IS
  -- VARIABLES --
  v_loc VARCHAR2(120) := NULL;
  BEGIN
    SELECT TOEWIJZING_OMS INTO v_loc
    FROM RAS_TA_TOEWIJZING
    WHERE TOEWIJZING_ID = p_toewijzing_id;
    RETURN v_loc;
  END;

  FUNCTION f_get_cat_org_unit_id(p_cat_id NUMBER, p_org_unit_id NUMBER) RETURN NUMBER IS
    v_cat_org_unit_id NUMBER:=NULL;
    BEGIN
        BEGIN
            SELECT CATEGORIE_ORG_UNIT_ID
            INTO v_cat_org_unit_id
            FROM RAS_TA_CATEGORIE_ORG_UNIT TC
            WHERE TC.CATEGORIE_ID = p_cat_id
            AND TC.ORG_UNIT_ID = p_org_unit_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN NULL;

        END;
        RETURN v_cat_org_unit_id;
    END;
  FUNCTION f_get_cat_unit_default_fu_taak(p_cat_id NUMBER, p_org_unit_id NUMBER) RETURN VARCHAR2 IS
    v_fu_cat_id NUMBER := NULL;
    v_cat_org_unit_id NUMBER := f_get_cat_org_unit_id(p_cat_id,p_org_unit_id);
    BEGIN
      SELECT FU_CATEGORIE_ID INTO v_fu_cat_id
      FROM ras_ta_cat_org_unit_fu
      WHERE DEFAULT_FLAG = 'J' AND CATEGORIE_ORG_UNIT_ID = v_cat_org_unit_id ;
      RETURN f_get_categorie_desc(v_fu_cat_id);
    END;

      /* GD 16-11-2011 */
  FUNCTION f_get_cat_desc_from_oc(p_obj_cat_id NUMBER) RETURN VARCHAR2 IS
     v_loc VARCHAR2(255) := NULL;
  BEGIN
    BEGIN
         SELECT cat.CATEGORIE_OMS into v_loc
         FROM RAS_TA_CATEGORIE cat, RAS_TA_OBJECT_CATEGORIE ocat
         WHERE ocat.object_categorie_id = p_obj_cat_id
         AND ocat.CATEGORIE_ID = cat.categorie_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                v_loc := '';
    END;
     RETURN v_loc;
  END;

  FUNCTION f_get_cat_from_oc(p_obj_cat_id NUMBER) RETURN NUMBER IS
       v_loc NUMBER := 0;
  BEGIN
    BEGIN
         SELECT CATEGORIE_ID into v_loc
         FROM RAS_TA_OBJECT_CATEGORIE
         WHERE object_categorie_id = p_obj_cat_id ;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                v_loc := 0;
    END;
     RETURN v_loc;
  END;

  FUNCTION f_get_def_deadline_cat(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER IS
    v_werkdagen NUMBER:=0;
    BEGIN
        BEGIN
        SELECT catou.AANTAL_DAGEN_DEADLINE into v_werkdagen
        FROM RAS_TA_CATEGORIE_ORG_UNIT catou
        WHERE catou.categorie_id = p_obj_cat_id
        AND catou.org_unit_id = p_org_unit_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN v_werkdagen := 0;
        END;
    return v_werkdagen;
  END;
  FUNCTION f_get_toewijzing_id_cat(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER IS
    v_toew_id NUMBER:=0;
    BEGIN
        BEGIN
        SELECT catou.toewijzing_id into v_toew_id
        FROM RAS_TA_CATEGORIE_ORG_UNIT catou
        WHERE catou.categorie_id = p_obj_cat_id
        AND catou.org_unit_id = p_org_unit_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN v_toew_id := 0;
        END;
    return v_toew_id;
    END;
  FUNCTION f_get_toewijzing_persoon_id(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER IS
    v_toew_waarde NUMBER:=0;
    BEGIN
        BEGIN
        SELECT catou.toew_persoon_id into v_toew_waarde
        FROM RAS_TA_CATEGORIE_ORG_UNIT catou
        WHERE catou.categorie_id = p_obj_cat_id
        AND catou.org_unit_id = p_org_unit_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN v_toew_waarde := 0;
        END;
         return v_toew_waarde;
    END;

      FUNCTION f_get_toewijzing_org_unit_id(p_obj_cat_id NUMBER,p_org_unit_id NUMBER) RETURN NUMBER IS
    v_toew_waarde NUMBER:=0;
    BEGIN
            BEGIN
        SELECT catou.toew_org_unit_id into v_toew_waarde
        FROM RAS_TA_CATEGORIE_ORG_UNIT catou
        WHERE catou.categorie_id = p_obj_cat_id
        AND catou.org_unit_id = p_org_unit_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN v_toew_waarde := 0;
        END;
        return v_toew_waarde;
    END;

    PROCEDURE p_delete_toewijzingswaarde(p_cat_owner_id NUMBER) IS
    BEGIN
        DELETE FROM RAS_TA_CATEGORIE_OWNER
        WHERE CATEGORIE_OWNER_ID = p_cat_owner_id;
    END;

    PROCEDURE p_delete_vervolgtaak(p_cat_org_unit_fu_id NUMBER) IS
        BEGIN
        DELETE FROM ras_ta_cat_org_unit_fu
        WHERE cat_org_unit_fu_id = p_cat_org_unit_fu_id;
    END;

    PROCEDURE p_add_toewijzingswaarde(p_cat_id NUMBER,p_owner_org_unit_id NUMBER, p_persoon_id NUMBER) IS
    BEGIN
     INSERT INTO RAS_TA_CATEGORIE_OWNER (CATEGORIE_ID,OWNER_ORG_UNIT_ID,PERSOON_ID)
     VALUES
     (p_cat_id,p_owner_org_unit_id,p_persoon_id);
    END;
    
    PROCEDURE p_add_vervolgtaak(p_obj_cat_id NUMBER,p_fu_categorie_id NUMBER, p_default_flag VARCHAR2) IS
    BEGIN
     INSERT INTO RAS_TA_CAT_ORG_UNIT_FU (CATEGORIE_ORG_UNIT_ID,FU_CATEGORIE_ID,DEFAULT_FLAG)
     VALUES
     (p_obj_cat_id,p_fu_categorie_id,p_default_flag);
    END;
END;