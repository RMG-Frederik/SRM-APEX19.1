create or replace PACKAGE RAS.PK_RAS_APEX_TAKEN AS 
/******************************************************************************
   NAME:       PK_RAS_APEX_TAKEN
   PURPOSE: Keep all actions needed for the "tasks" part of SRM in one place

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/06/2016   fvantroy        Created this package.
******************************************************************************/

  -- Public type declarations
  type display_value_pair is record(
    display_value varchar2(255),
    return_value  varchar2(255)
  );
  type display_value_pair_group is record(
    display_value varchar2(255),
    return_value  varchar2(255),
    group_value  varchar2(255)
  );
  type tt_dvp is table of display_value_pair;
  type tt_dvpg is table of display_value_pair_group;

COLL_NAME_TASK constant VARCHAR2(25) := 'TASK_FILTERS';

FUNCTION all_cats_for_crm_objects return tt_dvpg pipelined;

FUNCTION f_get_user_units(p_persoon_id NUMBER, p_org_sturing_type_code VARCHAR2 DEFAULT NULL) RETURN ops$cebe.col_cb_org_unit;

FUNCTION f_get_number_urgent RETURN NUMBER;

FUNCTION f_get_deadline_tag(p_number_of_days NUMBER, p_deadline DATE) RETURN VARCHAR2;

FUNCTION f_get_deadline_class(p_number_of_days NUMBER) RETURN VARCHAR2;

PROCEDURE p_set_default_waarden;

PROCEDURE P_bewaar_nieuwe_taak;

PROCEDURE p_get_cat_org_unit_id(p_id NUMBER ); 

-- **********************************************
-- * TASK FILTER / OVERVIEW SPECIFIC PROCEDURES *
-- **********************************************

PROCEDURE p_init_task_filters;
PROCEDURE p_do_search_tasks(p_search_query IN VARCHAR2,p_region_id NUMBER, p_report_alias VARCHAR2, p_app_page_id NUMBER,p_app_id NUMBER);
PROCEDURE p_set_items_from_task_filters;
PROCEDURE p_apply_task_filters;
END PK_RAS_APEX_TAKEN;
/

create or replace PACKAGE BODY RAS.PK_RAS_APEX_TAKEN AS

  -- PRIVATE FUNCTIONS/PROCEDURES
  
  -- Take org unit id and return ,delimited string of oracle logins of persons in that org
  FUNCTION f_get_ora_p_for_org(p_unit_id IN NUMBER) RETURN VARCHAR2 AS
    v_result VARCHAR2(1000):='null';
  BEGIN
    select LISTAGG(return_value,',') WITHIN GROUP (ORDER BY return_value) as concatenation into v_result
    from table(pk_cebe_org_lov.persons_in_unit_by_ora(p_unit_id));
    IF v_result IS NULL THEN
      return '0';
    ELSE
      return v_result;
    END IF;
  END f_get_ora_p_for_org;

  -- Take person id and return ,delimited string of units for that person
  FUNCTION f_get_units_for_p(p_persoon_id IN NUMBER) RETURN VARCHAR2 AS
    v_result VARCHAR2(1000):='null';
  BEGIN
    select LISTAGG(org_unit_id,',') WITHIN GROUP (ORDER BY org_unit_id) as concatenation into v_result
    from table(pk_cebe_org_int.f_get_persoon_units(p_persoon_id));
    IF v_result IS NULL THEN
      return '0';
    ELSE
      return v_result;
    END IF;
  END f_get_units_for_p;  
  
  -- Take a : delimited string of persoon ids and return the names attached to it's id's 
  FUNCTION f_get_toegewezen_from_id(p_values IN VARCHAR2) RETURN VARCHAR2 AS
  p_names VARCHAR2(2000) := null;
  p_naam VARCHAR2(250) := null;
  p_vert_code NUMBER := null;
  BEGIN
    FOR id IN
    (SELECT trim(regexp_substr(p_values, '[^:]+', 1, LEVEL)) sub
     FROM dual
     CONNECT BY LEVEL <= regexp_count(p_values, ':')+1
    )
    LOOP
    IF p_values IS NOT NULL THEN
      p_naam :=  INITCAP(pk_cebe_per.f_get_naam_formatted (id.sub));
    END IF;
    IF p_naam IS NULL THEN
      -- Here we should try some other way of getting a name
      p_naam := p_vert_code || ' naamloos'; 
    END IF;
    p_names := p_names || p_naam || ' of ';
    END LOOP;
    return SUBSTR(p_names, 1, LENGTH(p_names) - 4);
  END f_get_toegewezen_from_id;
  
  -- Take a : delimited string of oracle logins and return the names attached to them 
  FUNCTION f_get_toegewezen_from_ora(p_values IN VARCHAR2) RETURN VARCHAR2 AS
  p_names VARCHAR2(2000) := null;
  p_naam VARCHAR2(250) := null;
  p_vert_code NUMBER := null;
  BEGIN
    FOR id IN
    (SELECT trim(regexp_substr(p_values, '[^:]+', 1, LEVEL)) sub
     FROM dual
     CONNECT BY LEVEL <= regexp_count(p_values, ':')+1
    )
    LOOP
    IF p_values IS NOT NULL THEN
      p_naam := INITCAP(pk_cebe_per.f_get_naam_ora_inc_inac (id.sub));
    END IF;
    IF p_naam IS NULL THEN
      -- Here we should try some other way of getting a name
      p_naam := p_vert_code || ' naamloos'; 
    END IF;
    p_names := p_names || p_naam || ' of ';
    END LOOP;
    return SUBSTR(p_names, 1, LENGTH(p_names) - 4);
  END f_get_toegewezen_from_ora;
  
  -- Take a : delimited string of categorie ids and return the descreiptions attached to it's id's 
  FUNCTION f_get_cats_from_id(p_values IN VARCHAR2) RETURN VARCHAR2 AS
  p_names VARCHAR2(2000) := null;
  p_naam VARCHAR2(250) := null;
  p_vert_code NUMBER := null;
  BEGIN
    FOR id IN
    (SELECT trim(regexp_substr(p_values, '[^:]+', 1, LEVEL)) sub
     FROM dual
     CONNECT BY LEVEL <= regexp_count(p_values, ':')+1
    )
    LOOP
    IF p_values IS NOT NULL THEN
      p_naam :=  INITCAP(pk_ras_taak_general.f_get_categorie_desc(id.sub));
    END IF;
    IF p_naam IS NULL THEN
      p_naam := p_vert_code || ' naamloos'; 
    END IF;
    p_names := p_names || p_naam || ' of ';
    END LOOP;
    return SUBSTR(p_names, 1, LENGTH(p_names) - 4);
  END f_get_cats_from_id;
 
  -- Take a : delimited string of unit ids and return the name attached to it's id's 
  FUNCTION f_get_units_from_id(p_values IN VARCHAR2) RETURN VARCHAR2 AS
  p_names VARCHAR2(2000) := null;
  p_naam VARCHAR2(250) := null;
  p_vert_code NUMBER := null;
  BEGIN
    FOR id IN
    (SELECT trim(regexp_substr(p_values, '[^:]+', 1, LEVEL)) sub
     FROM dual
     CONNECT BY LEVEL <= regexp_count(p_values, ':')+1
    )
    LOOP
    IF p_values IS NOT NULL THEN
      p_naam :=  INITCAP(pk_cebe_org_general.f_get_org_unit_naam(id.sub));
    END IF;
    IF p_naam IS NULL THEN
      p_naam := p_vert_code || ' naamloos'; 
    END IF;
    p_names := p_names || p_naam || ' of ';
    END LOOP;
    return SUBSTR(p_names, 1, LENGTH(p_names) - 4);
  END f_get_units_from_id; 
  
  -- Take a : delimited string of Status codes and return a friendly name
  FUNCTION f_get_status_from_code(p_values IN VARCHAR2) RETURN VARCHAR2 AS
  p_names VARCHAR2(2000) := null;
  p_naam VARCHAR2(250) := null;
  p_vert_code NUMBER := null;
  BEGIN
    FOR id IN
    (SELECT trim(regexp_substr(p_values, '[^:]+', 1, LEVEL)) sub
     FROM dual
     CONNECT BY LEVEL <= regexp_count(p_values, ':')+1
    )
    LOOP
    IF p_values IS NOT NULL THEN
      CASE id.sub
            WHEN 'OPEN' THEN p_naam := APEX_LANG.MESSAGE('SRM_TAAK_STATUS_OPEN');
            WHEN 'CLOSED' THEN p_naam := APEX_LANG.MESSAGE('SRM_TAAK_STATUS_CLOSED');
            WHEN 'INEXECUTION' THEN p_naam := APEX_LANG.MESSAGE('SRM_TAAK_STATUS_INEXEC');
            WHEN 'CANCELLED' THEN p_naam := APEX_LANG.MESSAGE('SRM_TAAK_STATUS_CANCELLED');
            ELSE p_naam := 'Naamloos';
      END CASE;  
    END IF;
    p_names := p_names || p_naam || ' of ';
    END LOOP;
    return SUBSTR(p_names, 1, LENGTH(p_names) - 4);
  END f_get_status_from_code; 
  
  PROCEDURE p_exec_task_IR_filters(p_coll_name VARCHAR2, 
                                   p_region_id NUMBER, 
                                   p_report_alias VARCHAR2, 
                                   p_app_page_id NUMBER,
                                   p_app_id NUMBER) AS
  BEGIN   
    -- We start always by resetting the report
    APEX_IR.RESET_REPORT(p_app_page_id, p_region_id, p_report_alias);  
    -- Zoek de selected standpunten (misschien ooit multiselect)
    FOR standpunt in (select seq_id,c001,c002,c003,c004,n001,n002,n003 from apex_collections where collection_name = p_coll_name and n001= 1 and n002 = 1 and n003 = 1)  loop
        if standpunt.seq_id = 3 then
        -- if standpunt mijn(unit) combine 2 filters
          RAS.PK_ras_zoek.p_add_filter_to_IR(p_region_id,p_report_alias,'OWNER_OUID',f_get_units_for_p(v('SRM_PERSOON_ID')),'IN',p_app_page_id,p_app_id);
          RAS.PK_ras_zoek.p_add_filter_to_IR(p_region_id,p_report_alias,'OWNER_PID',v('SRM_PERSOON_ID') || ',0' ,'IN',p_app_page_id,p_app_id);
        else
          RAS.PK_ras_zoek.p_add_filter_to_IR(p_region_id,p_report_alias,standpunt.c002,standpunt.c003,standpunt.c004,p_app_page_id,p_app_id);
        end if;
    END LOOP;
    -- Overloop alle filters in onze apex collectie die active staan
    FOR filter in (select seq_id,c001,c002,c003,c004,n001,n002,n003 from apex_collections where collection_name = p_coll_name and n001= 0 and n002 = 1)  loop
       RAS.PK_ras_zoek.p_add_filter_to_IR(p_region_id,p_report_alias,filter.c002,filter.c003,filter.c004,p_app_page_id,p_app_id);
    END LOOP;
END p_exec_task_IR_filters;
  
  FUNCTION all_cats_for_crm_objects return tt_dvpg pipelined is
    t_retval display_value_pair_group;
    cursor c_lov is 
    select  
      NVL(c.categorie_oms, c.categorie_code) as display_value,
      c.categorie_id as return_value,
      o.object_oms  as group_value
    from ras_ta_categorie c, ras_ta_object_categorie oc, ras_object o
    where c.categorie_id = oc.categorie_id
    and oc.object_id =o.object_id
    and o.object_code in ('TAAK','CONTACT_MOM','ORDERSET','SRM_PERSOON','OFFERTE')
    ORDER BY group_value, display_value;        
    BEGIN   
      for ii in c_lov
      loop
        t_retval.display_value := ii.display_value;
        t_retval.return_value  := ii.return_value;
        t_retval.group_value := ii.group_value;
        pipe row(t_retval);
      end loop;
    
  END all_cats_for_crm_objects; 
  
  FUNCTION f_get_user_units(p_persoon_id NUMBER, p_org_sturing_type_code VARCHAR2 DEFAULT NULL) RETURN ops$cebe.col_cb_org_unit AS
  BEGIN
    -- TODO: Implementation required for FUNCTION PK_SRM_TAKEN.f_get_user_units
    RETURN NULL;
  END f_get_user_units;

  FUNCTION f_get_deadline_tag(p_number_of_days NUMBER, p_deadline DATE) RETURN VARCHAR2 IS
    v_tekst VARCHAR2(100) :=null;
  BEGIN
         CASE
             WHEN p_number_of_days > 3 THEN v_tekst := p_deadline;
             WHEN (p_number_of_days >1) AND (p_number_of_days <=3) THEN v_tekst := APEX_LANG.MESSAGE('TAAK_DEADLINE_DAGEN',p_number_of_days);
             WHEN p_number_of_days = 1 THEN v_tekst := APEX_LANG.MESSAGE('TAAK_DEADLINE_DAG');
             WHEN p_number_of_days = 0 THEN v_tekst := APEX_LANG.MESSAGE('TAAK_DEADLINE_VANDAAG');
             WHEN p_number_of_days = -1 THEN v_tekst := '- ' || APEX_LANG.MESSAGE('TAAK_DEADLINE_DAG');
             WHEN (p_number_of_days <-1) AND (p_number_of_days >=-3) THEN v_tekst := APEX_LANG.MESSAGE('TAAK_DEADLINE_DAGEN',p_number_of_days);
             WHEN p_number_of_days < 3 THEN v_tekst := p_deadline;
          END CASE;
    RETURN v_tekst;
  END f_get_deadline_tag;

  FUNCTION f_get_deadline_class(p_number_of_days NUMBER) RETURN VARCHAR2 IS
    v_class VARCHAR2(50) :=null;
  BEGIN
          CASE
             WHEN p_number_of_days > 3 THEN v_class := 'longer';
             WHEN (p_number_of_days >1) AND (p_number_of_days <=3) THEN v_class := 'twodays';
             WHEN p_number_of_days = 1 THEN v_class := 'oneday';
             WHEN p_number_of_days = 0 THEN v_class := 'today';
             WHEN p_number_of_days < 0 THEN v_class := 'over';
          END CASE;
    RETURN v_class;
  END f_get_deadline_class;

  FUNCTION f_get_number_urgent RETURN NUMBER IS
    v_number NUMBER := 5;
  BEGIN
    SELECT COUNT(t.taak_id)
      INTO v_number
      FROM ras_ta_taak t, ras_ta_object_categorie oc, ras_ta_categorie c
     WHERE     t.object_categorie_id = oc.object_categorie_id
       AND oc.categorie_id = c.categorie_id
       AND c.apex_flag = 'J'
       AND t.owner_org_unit_id IN (SELECT org_unit_id
                                      FROM cb_org_unit
                                   START WITH org_unit_id IN (SELECT /*+INDEX(CB_ORG_UNIT_PERSOON_U1) */ou.org_unit_id
                                                                FROM cb_org_unit ou,
                                                                     cb_org_unit_persoon oup,
                                                                     TABLE (pk_cebe_org_int.f_get_pers_opvolgers (v ('SRM_PERSOON_ID'))) per
                                                               WHERE ou.org_unit_id =  oup.org_unit_id
                                                                 and per.per_persoon_id = oup.persoon_id)
                                   CONNECT BY PRIOR org_unit_id = master_org_unit_id)
       AND t.taak_state_code != 'CLOSED';     
    return v_number;
  END;

  PROCEDURE p_get_cat_org_unit_id(p_id NUMBER) IS
    -- vars
    p_deadline NUMBER:=0;
    p_toew_id NUMBER:=0;
    p_toew_persoon NUMBER:=0;
    p_toew_ou NUMBER :=0;
    p_cat_id NUMBER := 0;
    p_ou_id NUMBER :=0;
    begin
       -- p_id:= nvl(pk_ras_taak_general.f_get_cat_org_unit_id(v('P96_CATEGORIE_ID'),v('P96_ORG_UNIT_ID')),0);
       -- apex_util.set_session_state('P96_CATEGORIE_ORG_UNIT_ID',p_id);

        IF p_id = 0 THEN
            -- Set all empty
            apex_util.set_session_state('P96_ORG_UNIT_ID',v('P96_SL_OU'));
            apex_util.set_session_state('P96_CATEGORIE_ID',p_cat_id);
            apex_util.set_session_state('P96_AANTAL_DAGEN_DEADLINE',p_deadline);
            apex_util.set_session_state('P96_TOEWIJZING_ID',p_toew_id);
            apex_util.set_session_state('P96_TOEW_PERSOON_ID',p_toew_persoon);
            apex_util.set_session_state('P96_TOEW_ORG_UNIT_ID',p_toew_ou);
         ELSE
            -- Get defaults
            BEGIN
                SELECT TOEWIJZING_ID,
                       TOEW_PERSOON_ID,
                       TOEW_ORG_UNIT_ID,
                       AANTAL_DAGEN_DEADLINE,
                       CATEGORIE_ID,
                       ORG_UNIT_ID
                INTO p_toew_id,
                     p_toew_persoon,
                     p_toew_ou,
                     p_deadline,
                     p_cat_id,
                     p_ou_id
                FROM V_RAS_APEX_OVERZICHT_TAAK_CAT
                WHERE CATEGORIE_ORG_UNIT_ID = p_id;
                EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
            apex_util.set_session_state('P96_ORG_UNIT_ID',p_ou_id);
            apex_util.set_session_state('P96_CATEGORIE_ID',p_cat_id);
            apex_util.set_session_state('P96_AANTAL_DAGEN_DEADLINE',p_deadline);
            apex_util.set_session_state('P96_TOEWIJZING_ID',p_toew_id);
            apex_util.set_session_state('P96_TOEW_PERSOON_ID',p_toew_persoon);
            apex_util.set_session_state('P96_TOEW_ORG_UNIT_ID',p_toew_ou);
          END IF;
    end;
  PROCEDURE p_set_default_waarden IS
        v_Cat_Id NUMBER  ;
        v_Ou_Id NUMBER  ;
        v_catou_exists NUMBER :=0;
        v_master_id NUMBER :=0;
        v_Titel VARCHAR2(200) :='';
        v_Oms VARCHAR2(1000);
        v_Deadline NUMBER;
        v_Toewijzing_id NUMBER;
        v_Persoon_id NUMBER;
        v_Unit_id NUMBER;
        v_Fu NUMBER;
    BEGIN
        -- First check if combo exists else change ou
        v_Cat_Id := pk_ras_taak_general.f_get_cat_from_oc(v('P82_OBJECT_CATEGORIE_ID'));
        v_Ou_Id := v('SRM_USER_DEF_UNIT_ID');
        v_catou_exists := pk_ras_taak_check.f_check_cat_ou_exists(v_Cat_Id,v_Ou_Id);
        APEX_UTIL.set_session_state('SRM_CATEGORIE',v_Cat_Id);
        v_Deadline := pk_ras_taak_general.f_get_def_deadline_cat(v_Cat_Id, v_Ou_Id);
        if v_Deadline <> 0 then
            APEX_UTIL.set_session_state('P82_DEADLINE_DATUM',pk_cebe_kal.f_schuif_dagen('VOORUIT', trunc(sysdate), v_Deadline));
        else
            APEX_UTIL.set_session_state('P82_DEADLINE_DATUM','');
        end if;
        v_Toewijzing_id := pk_ras_taak_general.f_get_toewijzing_id_cat(v_Cat_Id, v_Ou_Id);
        CASE v_Toewijzing_id
            WHEN 1 THEN -- spec user
                v_Persoon_id := pk_ras_taak_general.f_get_toewijzing_persoon_id(v_Cat_Id, v_Ou_Id);
                v_Unit_id := pk_ras_taak_general.f_get_toewijzing_org_unit_id(v_Cat_Id, v_Ou_Id);
                APEX_UTIL.set_session_state('P82_OWNER_PERSOON_ID',v_Persoon_id);
                APEX_UTIL.set_session_state('P82_OWNER_ORG_UNIT_ID',v_Unit_id);
            WHEN 2 THEN -- login user
                v_Persoon_id := v('SRM_USER_ID');
                v_Unit_id := 0;
                APEX_UTIL.set_session_state('P82_OWNER_PERSOON_ID',v_Persoon_id);
                APEX_UTIL.set_session_state('P82_OWNER_ORG_UNIT_ID',v_Unit_id);
            WHEN 3 THEN -- spec unit
                v_Unit_id := pk_ras_taak_general.f_get_toewijzing_org_unit_id(v_Cat_Id, v_Ou_Id);
                v_Persoon_id := 0;
                APEX_UTIL.set_session_state('P82_OWNER_ORG_UNIT_ID',v_Unit_id);
                APEX_UTIL.set_session_state('P82_OWNER_PERSOON_ID',v_Persoon_id);
            WHEN 4 THEN -- login unit
                v_Unit_id := v('SRM_USER_DEF_UNIT_ID');
                v_Persoon_id := 0;
                APEX_UTIL.set_session_state('P82_OWNER_ORG_UNIT_ID',v_Unit_id);
                APEX_UTIL.set_session_state('P82_OWNER_PERSOON_ID',v_Persoon_id);
            ELSE
                v_Persoon_id := 0;
                v_Unit_id := 0;
        END CASE;        
        v_Fu := v('P82_IS_FU');
        CASE v('P82_OBJECT_REFERENCE')
            WHEN 'TAAK' THEN 
               if v_Fu = 0 THEN
                   v_Titel := pk_ras_taak_general.f_get_categorie_desc(v_Cat_Id) || ' - ' || v('SRM_USER_NAAM');           
                    v_Oms := 'omschrijving voor ' || v_Titel;
               ELSE
                    v_Titel := pk_ras_taak_general.f_get_categorie_desc(v_Cat_Id) || ' (Vervolgtaak van ' || pk_ras_taak_general.f_get_taak_titel(v('P82_REF_ID')) || ')';          
                    v_Oms := pk_ras_taak_general.f_get_taak_oms(v('P82_REF_ID'));
               END IF;
            WHEN 'CONTACT_MOM' THEN 
                if v_Fu = 0 THEN
                v_Titel := pk_ras_taak_general.f_get_categorie_desc(v_Cat_Id) || ' - ' || v('P82_INFO');
                v_Oms := 'omschrijving voor ' || v_Titel;
               ELSE
                v_Titel := pk_ras_taak_general.f_get_categorie_desc(v_Cat_Id) || ' (Vervolgtaak van ' || pk_ras_taak_general.f_get_taak_titel(v('P82_REF_ID')) || ')';
                v_Oms := pk_ras_taak_general.f_get_taak_oms(v('P82_REF_ID'));
               END IF;
            WHEN 'OFFERTE' THEN
                v_Titel := pk_ras_taak_general.f_get_categorie_desc(v_Cat_Id) || ' - ' || v('P82_INFO');
                v_Oms := 'omschrijving voor ' || v_Titel;
        END CASE;       
        APEX_UTIL.set_session_state('P82_TITEL_TEKST',v_Titel);
        APEX_UTIL.set_session_state('P82_OMSCHRIJVING',v_Oms);
END;

  PROCEDURE p_bewaar_nieuwe_taak is
    v_object_categorie_id     NUMBER;
    v_ref_id                  NUMBER;
    v_titel                   VARCHAR2(250);
    v_description             VARCHAR2(3000);
    v_deadline_date           DATE;
    v_owner_org_unit_id       NUMBER;
    v_owner_persoon_id        NUMBER;
    v_result NUMBER :=NULL;
  BEGIN
    v_object_categorie_id :=    v('P82_OBJECT_CATEGORIE_ID');
    v_ref_id              :=    v('P82_REF_ID');
     v_titel               :=    v('P82_TITEL_TEKST');
    v_description         :=    v('P82_OMSCHRIJVING');
    v_deadline_date       :=    v('P82_DEADLINE_DATUM');
    v_owner_org_unit_id   :=    v('P82_OWNER_ORG_UNIT_ID');
    if v('P82_OWNER_PERSOON_ID') = '0' THEN
        v_owner_persoon_id    := NULL;
    else
        v_owner_persoon_id    :=    v('P82_OWNER_PERSOON_ID');
    end if;
v_result:= pk_ras_taak_create.f_creatie_taak(v_object_categorie_id,v_ref_id,v_titel,v_description,v_deadline_date,v_owner_org_unit_id,v_owner_persoon_id);              
END;

  PROCEDURE p_init_task_filters AS
  BEGIN
    IF NOT APEX_COLLECTION.COLLECTION_EXISTS (COLL_NAME_TASK) THEN 
      APEX_COLLECTION.CREATE_COLLECTION(COLL_NAME_TASK);
      -- Set standpunt toggle
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_STANDPUNT_MIJN_ORG'),'AANVRAGER_ID',f_get_ora_p_for_org(v('SRM_USER_TOP_UNIT_ID')),'IN',1,1,0);                                                                  -- SEQ 1                                                                        
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_STANDPUNT_MIJN_UNIT'),'OWNER_OUID',f_get_units_for_p(v('SRM_PERSOON_ID')),'IN',1,1,0);                                                                 -- SEQ 2    
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_STANDPUNT_MIJN(UNIT)'),'',f_get_units_for_p(v('SRM_PERSOON_ID')) || ',' || pk_cebe_per.f_get_naam_formatted(v('SRM_PERSOON_ID')),'IN',1,1,0);                                                                -- SEQ 3     
      RAS.pk_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_STANDPUNT_MIJN'),'OWNER_PID',v('SRM_PERSOON_ID'),'EQ',1,1,1);            -- SEQ 4                                                               
      -- Set possible filters
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS')|| ' = Open of In uitvoering','TAAK_STATE_CODE','OPEN,INEXECUTION','IN',0,1,0);    --SEQ 5                                             
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_CATEGORIE'),'CAT_ID','','',0,0,0);                                                      --SEQ 6
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS'),'AANVRAGER','','',0,0,0);    --SEQ 7
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS'),'OWNER','','',0,0,0);    --SEQ 8
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS'),'OWNER','','',0,0,0);    --SEQ 9
      RAS.PK_ras_zoek.p_add_filter(COLL_NAME_TASK,APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS'),'TAAK_STATE_CODE','Inexecution','IN',0,0,0);    --SEQ 10 
    END IF;
  END p_init_task_filters;
  
  PROCEDURE p_do_search_tasks(p_search_query IN VARCHAR2,
                              p_region_id NUMBER, 
                              p_report_alias VARCHAR2, 
                              p_app_page_id NUMBER,
                              p_app_id NUMBER) AS
  BEGIN
    p_exec_task_IR_filters(COLL_NAME_TASK, p_region_id , p_report_alias , p_app_page_id , p_app_id );    
  END p_do_search_tasks;
  
  PROCEDURE p_apply_task_filters AS
    p_display_title VARCHAR2(1000) := null;
    BEGIN
      -- Status, SEQ 5
      p_display_title := APEX_LANG.MESSAGE('SRM_FILTER_LABEL_STATUS') || ' = ' || f_get_status_from_code(v('P80_STATUS'));
      RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_STATUS'),COLL_NAME_TASK,5,p_display_title,'TAAK_STATE_CODE','IN');
      -- Categorie, SEQ 6
      p_display_title := APEX_LANG.MESSAGE('SRM_FILTER_LABEL_CATEGORIE') || ' = ' || f_get_cats_from_id(v('P80_CATEGORIE'));
      RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_CATEGORIE'),COLL_NAME_TASK,6,p_display_title,'CAT_ID','IN');
      -- Aanvrager: SEQ 7
      p_display_title := APEX_LANG.MESSAGE('SRM_FILTER_LABEL_AANVRAGER') || ' = ' || f_get_toegewezen_from_ora(v('P80_AANVRAGER'));
     -- RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_AANVRAGER'),COLL_NAME_TASK,7,p_display_title,'AANVRAGER','IN');
     RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_AANVRAGER'),COLL_NAME_TASK,7,p_display_title,'AANVRAGER_ID','IN');
      -- Toegewezen persoon, SEQ 8
      p_display_title := APEX_LANG.MESSAGE('SRM_FILTER_LABEL_PERSOON_TOEGEWEZEN') || ' = ' || f_get_toegewezen_from_id(v('P80_OWNER'));
      RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_OWNER'),COLL_NAME_TASK,8,p_display_title,'OWNER_PID','IN');
      -- Toegewezen unit, SEQ 9
      p_display_title := APEX_LANG.MESSAGE('SRM_FILTER_LABEL_UNIT_TOEGEWEZEN') || ' = ' || f_get_units_from_id(v('P80_OWNER_UNIT'));
      RAS.pk_ras_zoek.p_set_IR_simple_filter(v('P80_OWNER_UNIT'),COLL_NAME_TASK,9,p_display_title,'OWNER_OUID','IN');
      -- Deadline, SEQ 10
      RAS.pk_ras_zoek.p_set_IR_fromto_filter(v('P80_DEADLINE_VAN'),v('P80_DEADLINE_TOT'),COLL_NAME_TASK,10,'Deadline ','DEADLINE_DATUM','DATE');
  END p_apply_task_filters;
  
  PROCEDURE p_set_items_from_task_filters AS
  BEGIN
    -- For now loop over collection and use sequence in a case
    FOR filter in (select seq_id,c001,c002,c003,c004,n001,n002,n003 from apex_collections where collection_name = COLL_NAME_TASK and n001= 0)  loop
      CASE
        WHEN filter.seq_id = 5 THEN 
          apex_util.set_session_state('P80_STATUS_HIDDEN',filter.c003);
        WHEN filter.seq_id = 6 THEN 
          apex_util.set_session_state('P80_CATEGORIE_HIDDEN',filter.c003);
        WHEN filter.seq_id = 7 THEN 
          apex_util.set_session_state('P80_AANVRAGER_HIDDEN',filter.c003);
        WHEN filter.seq_id = 8 THEN
          apex_util.set_session_state('P80_OWNER_HIDDEN',filter.c003); 
        WHEN filter.seq_id = 9 THEN 
          apex_util.set_session_state('P80_OWNER_UNIT_HIDDEN',filter.c003); 
        WHEN filter.seq_id = 10 THEN 
           apex_util.set_session_state('P80_DEADLINE_VAN',''); 
      END CASE;
    END LOOP; 
  END p_set_items_from_task_filters; 

END PK_RAS_APEX_TAKEN;

