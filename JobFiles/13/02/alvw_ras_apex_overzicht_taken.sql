CREATE OR REPLACE FORCE VIEW "V_RAS_APEX_OVERZICHT_TAKEN" ("DEADLINE_DATUM", "BINNEN", "DEADLINE_IN", "DEADLINE_CLASS", "OBJ_CAT_ID", "CAT_ID", "CATEGORIE", "TITEL_TEKST", "OMSCHRIJVING", "CLOSED_OMS", "TAAK_STATE_CODE", "OWNER_PID", "OWNER_OUID", "OWNER", "AANVRAGER", "AANVRAGER_ID", "OBJECT_ID", "REF_ID", "TAAK_ID", "ACTIE") AS 
  SELECT /*+ INDEX(RAS_TA_CATEGORIE_I) */
         t.deadline_datum,
          TO_DATE (t.deadline_datum, 'dd-mm-yyyy') - TRUNC (SYSDATE) binnen,
          pk_ras_apex_taken.f_get_deadline_tag (
             TO_DATE (t.deadline_datum, 'dd-mm-yyyy') - TRUNC (SYSDATE),
             t.deadline_datum)
             deadline_in,
          pk_ras_apex_taken.f_get_deadline_class (
             TO_DATE (t.deadline_datum, 'dd-mm-yyyy') - TRUNC (SYSDATE))
             deadline_class,
          t.object_categorie_id obj_cat_id,   
          pk_ras_taak_general.f_get_cat_from_oc (t.object_categorie_id)
             cat_id,
          LOWER (
             pk_ras_taak_general.f_get_categorie_desc_from_taak (
                t.object_categorie_id))
             categorie,
          t.titel_tekst,
          t.omschrijving,
          t.closed_oms,
          t.taak_state_code,
          NVL (t.owner_persoon_id, 0) OWNER_PID,
          t.owner_org_unit_id OWNER_OUID,
          NVL (pk_cebe_per.f_get_naam_formatted (owner_persoon_id),
               pk_cebe_org_general.f_get_org_unit_naam (t.owner_org_unit_id))
             owner,
          NVL (pk_cebe_per.f_get_naam_ora_inc_inac (t.creatie_door),
               t.creatie_door)
             aanvrager,
          t.creatie_door aanvrager_id,
          oc.object_id,
          t.ref_id,
          t.taak_id,
          (SELECT actie_type_code
             FROM ras_actie
            WHERE actie_id = oc.actie_id)
             actie
     FROM ras_ta_taak t, ras_ta_object_categorie oc, ras_ta_categorie c
    WHERE     t.object_categorie_id = oc.object_categorie_id
          AND oc.categorie_id = c.categorie_id
          --     AND oc.actie_id = ra.actie_id
          --     AND ( (ra.actie_type_code = 'PAGE') OR (ra.actie_type_code IS NULL));
          AND c.apex_flag = 'J'
