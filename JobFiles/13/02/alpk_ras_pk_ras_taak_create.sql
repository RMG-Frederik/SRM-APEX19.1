create or replace PACKAGE     ras.pk_ras_taak_create IS

  /* constanten */
  c_dbms_log BOOLEAN := TRUE;

  /* GD 16-11-2011 */
  FUNCTION f_creatie_taak(
                           p_object_categorie_id     NUMBER,
                           p_ref_id                  NUMBER,
                           p_titel                   VARCHAR2,
                           p_description             VARCHAR2,
                           p_deadline_date           DATE,
                           p_owner_org_unit_id       NUMBER,
                           p_owner_persoon_id        NUMBER,
                           p_prioriteit_id           NUMBER DEFAULT NULL,
                           p_shedule_date            DATE DEFAULT NULL
                         ) RETURN NUMBER;

   FUNCTION f_lock_taak(p_taak_id NUMBER) RETURN NUMBER;

   PROCEDURE p_wijzig_taak(p_taak_id NUMBER
                          ,p_prioriteit_id NUMBER
                          ,p_shedule_datum DATE
                          ,p_deadline_datum DATE
                          ,p_owner_persoon_id NUMBER);
   
     PROCEDURE p_wijzigen_taak(p_taak_id NUMBER,
                          p_omschrijving VARCHAR2,
                          p_opmerking VARCHAR2,
                          p_deadline_datum DATE,
                          p_toegewezen_persoon NUMBER,
                          p_toegewezen_unit NUMBER
                         ); 
   PROCEDURE p_wijzig_taak_cat_ou(p_cat_org_unit_id NUMBER,
                                  p_toewijzing_id NUMBER,
                                  p_toew_org_unit_id NUMBER,
                                p_toew_persoon_id NUMBER,
                                  p_aantal_dagen_deadline NUMBER); 
                                  
   FUNCTION f_create_opmerking(p_taak_id NUMBER, p_opmerking_tekst VARCHAR2) RETURN NUMBER;

   FUNCTION f_create_taak_object(p_taak_id IN ras_ta_taak_object.taak_id%TYPE,
                                 p_object_id IN ras_ta_taak_object.object_id%TYPE,
                                 p_ref_id IN ras_ta_taak_object.ref_id%TYPE,
                                 p_ref_code IN ras_ta_taak_object.ref_code%TYPE)
   RETURN ras_ta_taak_object.taak_object_id%TYPE;
   
   FUNCTION f_create_taak_cat_ou(
                                   p_categorie_id    NUMBER,
                                   p_org_unit_id    NUMBER,
                                   p_toewijzing_id    NUMBER,
                                   p_toew_org_unit_id    number,
                                   p_toew_persoon_id    number,
                                   p_aantal_dagen_deadline    number

   ) return number;

END;
/

create or replace PACKAGE BODY     ras.pk_ras_taak_create IS

  gc_submodule_naam VARCHAR2(30) := 'TAKEN';

  /* GD 16-11-2011 */
  FUNCTION f_creatie_taak(
                           p_object_categorie_id     NUMBER,
                           p_ref_id                  NUMBER,
                           p_titel                   VARCHAR2,
                           p_description             VARCHAR2,
                           p_deadline_date           DATE,
                           p_owner_org_unit_id       NUMBER,
                           p_owner_persoon_id        NUMBER,
                           p_prioriteit_id           NUMBER DEFAULT NULL,
                           p_shedule_date            DATE DEFAULT NULL
                         ) RETURN NUMBER IS
     -- VARIABLES --
     e_taak_niet_uniek EXCEPTION;

     v_uniek_check NUMBER := NULL;
     v_taak_uniek  NUMBER := NULL;
     v_taak_prior  NUMBER := NULL;
     v_loc         NUMBER := NULL;
  BEGIN
     v_uniek_check := pk_ras_taak_general.f_get_object_categorie_uniek(p_object_categorie_id);
     IF v_uniek_check = 1 THEN   -- controleer of er een unieke open taak moet zijn --
        v_taak_uniek := pk_ras_taak_check.f_taak_open_uniek(p_object_categorie_id, p_ref_id);
     END IF;
         /*-------------------------------------------------------------------*/
         IF c_dbms_log THEN
             dbms_output.put_line('v_uniek_check: ' || v_uniek_check);
             dbms_output.put_line('v_taak_uniek: '  || v_taak_uniek);
         END IF;
         /*-------------------------------------------------------------------*/


     IF (v_uniek_check = 0) OR (v_uniek_check = 1 AND v_taak_uniek = 1) THEN

        IF p_prioriteit_id IS NULL
        THEN
          v_taak_prior := pk_ras_taak_general.f_get_object_categorie_prior(p_object_categorie_id);
        ELSE
          v_taak_prior := p_prioriteit_id;
        END IF;

        -- Insert van de taak in RAS_TA_TAAK --
        INSERT INTO RAS_TA_TAAK
                (
                  OBJECT_CATEGORIE_ID,
                  REF_ID,
                  PRIORITEIT_ID,
                  TITEL_TEKST,
                  OMSCHRIJVING,
                  SHEDULE_DATUM,
                  DEADLINE_DATUM,
                  OWNER_ORG_UNIT_ID,
                  OWNER_PERSOON_ID
                )
        VALUES
                (
                 p_object_categorie_id,
                 p_ref_id,
                 v_taak_prior,
                 p_titel,
                 p_description,
                 p_shedule_date,
                 p_deadline_date,
                 p_owner_org_unit_id,
                 p_owner_persoon_id
                )
        RETURNING TAAK_ID INTO v_loc;
     ELSE
        RAISE e_taak_niet_uniek;
     END IF;

     RETURN v_loc;
  EXCEPTION
  WHEN e_taak_niet_uniek
  THEN
  dbms_output.put_line('taak niet uniek?');
    pk_ras_error.p_raise_handled_error('RAS-000007', gc_submodule_naam, p_titel);  -- taak niet uniej
    RAISE;
  END;

  FUNCTION f_lock_taak(p_taak_id NUMBER) RETURN NUMBER
  IS
    v_dummy NUMBER;
  BEGIN
    SELECT 1 INTO v_dummy FROM ras_ta_taak WHERE taak_id = p_taak_id FOR UPDATE NOWAIT;

    RETURN 0;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN -1;
  END;

  PROCEDURE p_wijzig_taak(p_taak_id NUMBER
                         ,p_prioriteit_id NUMBER
                         ,p_shedule_datum DATE
                         ,p_deadline_datum DATE
                         ,p_owner_persoon_id NUMBER)
  IS
  BEGIN
     UPDATE ras_ta_taak
        SET prioriteit_id = p_prioriteit_id
           ,shedule_datum = p_shedule_datum
           ,deadline_datum = p_deadline_datum
           ,owner_persoon_id = p_owner_persoon_id
      WHERE taak_id = p_taak_id;
  END;

  PROCEDURE p_wijzigen_taak(p_taak_id NUMBER,
                          p_omschrijving VARCHAR2,
                          p_opmerking VARCHAR2,
                          p_deadline_datum DATE,
                          p_toegewezen_persoon NUMBER,
                          p_toegewezen_unit NUMBER
                         )
  IS
  BEGIN
     UPDATE ras_ta_taak
        SET omschrijving = p_omschrijving,
           owner_org_unit_id = p_toegewezen_unit,
           owner_persoon_id = p_toegewezen_persoon,
           deadline_datum = p_deadline_datum,
           closed_oms = p_opmerking
      WHERE taak_id = p_taak_id;
  --    IF p_opmerking IS NOT NULL THEN    
  --      INSERT INTO RAS_TA_TAAK_OPMERKING (TAAK_ID, OPMERKING_TEKST) VALUES (p_taak_id, p_opmerking);
   --   END IF;
  END;

  FUNCTION f_create_opmerking(p_taak_id NUMBER, p_opmerking_tekst VARCHAR2) RETURN NUMBER IS
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     INSERT INTO RAS_TA_TAAK_OPMERKING (TAAK_ID, OPMERKING_TEKST) VALUES
                                       (p_taak_id, p_opmerking_tekst)
     RETURNING TAAK_OPMERKING_ID INTO v_loc;

     RETURN v_loc;
  END;
  -- FV 23/01/2020: beheren taak categorie ou
PROCEDURE p_wijzig_taak_cat_ou(p_cat_org_unit_id NUMBER,
                                  p_toewijzing_id NUMBER,
                                  p_toew_org_unit_id NUMBER,
                                  p_toew_persoon_id NUMBER,
                                  p_aantal_dagen_deadline NUMBER) IS
  BEGIN
    UPDATE RAS_TA_CATEGORIE_ORG_UNIT
     SET TOEWIJZING_ID = p_toewijzing_id,
         TOEW_ORG_UNIT_ID = p_toew_org_unit_id,
         TOEW_PERSOON_ID = p_toew_persoon_id,
         AANTAL_DAGEN_DEADLINE = p_aantal_dagen_deadline 
     WHERE CATEGORIE_ORG_UNIT_ID = p_cat_org_unit_id;
  END;
  -- FV 03/07/2019: beheren taak categorie ou
   FUNCTION f_create_taak_cat_ou(p_categorie_id NUMBER,
                                 p_org_unit_id NUMBER,
                                 p_toewijzing_id NUMBER,
                                 p_toew_org_unit_id NUMBER,
                                 p_toew_persoon_id NUMBER,
                                 p_aantal_dagen_deadline NUMBER) return number IS
     -- VARIABLES --
     v_loc NUMBER := NULL;
  BEGIN
     INSERT INTO RAS_TA_CATEGORIE_ORG_UNIT (CATEGORIE_ID, ORG_UNIT_ID,TOEWIJZING_ID,TOEW_ORG_UNIT_ID,TOEW_PERSOON_ID,AANTAL_DAGEN_DEADLINE) VALUES
                                           (p_categorie_id, p_org_unit_id, p_toewijzing_id, p_toew_org_unit_id,p_toew_persoon_id , p_aantal_dagen_deadline)
     RETURNING CATEGORIE_ORG_UNIT_ID INTO v_loc;

     RETURN v_loc;
  END;


  ------------------------------------------------------------------------------
  -- NN 22/10/2012: link leggen tussen taak en object
  FUNCTION f_create_taak_object(p_taak_id IN ras_ta_taak_object.taak_id%TYPE,
                                p_object_id IN ras_ta_taak_object.object_id%TYPE,
                                p_ref_id IN ras_ta_taak_object.ref_id%TYPE,
                                p_ref_code IN ras_ta_taak_object.ref_code%TYPE)
  RETURN ras_ta_taak_object.taak_object_id%TYPE
  IS
    -- VARIABLES --
    v_loc       ras_ta_taak_object.taak_object_id%TYPE := NULL;
  BEGIN
      BEGIN
         SELECT TAAK_OBJECT_ID
         INTO v_loc
         FROM RAS_TA_TAAK_OBJECT
         WHERE TAAK_ID = p_taak_id
         AND   OBJECT_ID = p_object_id
         AND   NVL(REF_ID,-1) = NVL(p_ref_id,-1)
         AND   NVL(REF_CODE,'x') = NVL(p_ref_code,'x');
      EXCEPTION WHEN NO_DATA_FOUND THEN
          BEGIN
              INSERT INTO RAS_TA_TAAK_OBJECT
                    (TAAK_ID,
                     OBJECT_ID,
                     REF_ID,
                     REF_CODE)
              VALUES (p_taak_id,
                      p_object_id,
                      p_ref_id,
                      p_ref_code)
              RETURNING TAAK_OBJECT_ID INTO v_loc;
          END;
      END;

      RETURN v_loc;
   END f_create_taak_object;

END;