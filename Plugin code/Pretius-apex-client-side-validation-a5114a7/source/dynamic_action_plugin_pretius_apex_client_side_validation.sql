set define off
set verify off
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040100 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,1306414406437536));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2011.02.12');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,102);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/dynamic_action/pretius_apex_client_side_validation
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'DYNAMIC ACTION'
 ,p_name => 'PRETIUS_APEX_CLIENT_SIDE_VALIDATION'
 ,p_display_name => 'Pretius APEX Client Side Validation'
 ,p_category => 'EXECUTE'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'/*'||unistr('\000a')||
'  author: Bartosz Ostrowski ostrowski.bartosz@gmail.com, bostrowski@pretius.com'||unistr('\000a')||
'  1.0 release date: 2015-09-16'||unistr('\000a')||
'  1.1 release date: 2016-04-19'||unistr('\000a')||
'*/'||unistr('\000a')||
''||unistr('\000a')||
'e_validation_failed exception;'||unistr('\000a')||
'type t_tab is table of varchar2(4000) index by binary_integer;'||unistr('\000a')||
''||unistr('\000a')||
'function render_validation ('||unistr('\000a')||
'  p_dynamic_action in apex_plugin.t_dynamic_action,'||unistr('\000a')||
'  p_plugin         in apex_plugin.t_plugin '||unistr('\000a')||
') return apex_plugin.t_dynamic_'||
'action_render_result'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_result apex_plugin.t_dynamic_action_render_result;'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  apex_css.add_file (  '||unistr('\000a')||
'    p_name => ''pretius_validation_style'','||unistr('\000a')||
'    p_directory => p_plugin.file_prefix, '||unistr('\000a')||
'    p_version => null'||unistr('\000a')||
'  );'||unistr('\000a')||
''||unistr('\000a')||
'  apex_javascript.add_library('||unistr('\000a')||
'    p_name      => ''pretius_validation'','||unistr('\000a')||
'    p_directory => p_plugin.file_prefix,'||unistr('\000a')||
'    p_version   => NULL '||unistr('\000a')||
'  );'||unistr('\000a')||
''||unistr('\000a')||
'  v_result.ajax_identifier := APEX_'||
'PLUGIN.GET_AJAX_IDENTifIER();'||unistr('\000a')||
'  v_result.attribute_01 := p_dynamic_action.attribute_01;'||unistr('\000a')||
'  v_result.attribute_02 := replace(replace(p_dynamic_action.attribute_02, chr(13), ''''), chr(10), '''');'||unistr('\000a')||
'  v_result.attribute_04 := p_dynamic_action.attribute_04;'||unistr('\000a')||
'  v_result.attribute_05 := p_dynamic_action.attribute_05;'||unistr('\000a')||
'  v_result.attribute_06 := p_dynamic_action.attribute_06;'||unistr('\000a')||
'  v_result.attribute_07 := p_dynamic'||
'_action.attribute_07;'||unistr('\000a')||
'  v_result.attribute_08 := NVL(p_dynamic_action.attribute_08, 0);'||unistr('\000a')||
'  v_result.attribute_10 := p_plugin.attribute_01;'||unistr('\000a')||
''||unistr('\000a')||
'  v_result.javascript_function := ''function() { pretius_validation(this, ''''''||p_plugin.file_prefix||'''''');}'';    '||unistr('\000a')||
''||unistr('\000a')||
'  APEX_PLUGIN_UTIL.DEBUG_DYNAMIC_ACTION ('||unistr('\000a')||
'    p_plugin         => p_plugin,'||unistr('\000a')||
'    p_dynamic_action => p_dynamic_action'||unistr('\000a')||
'  );  '||unistr('\000a')||
''||unistr('\000a')||
'  return v_result;'||unistr('\000a')||
''||unistr('\000a')||
'EX'||
'CEPTION'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    htp.p( SQLERRM );'||unistr('\000a')||
'    return v_result;'||unistr('\000a')||
'end render_validation;'||unistr('\000a')||
''||unistr('\000a')||
'FUNCTION GET_VALUE ('||unistr('\000a')||
'  P_NAME IN VARCHAR2 )'||unistr('\000a')||
'  RETURN VARCHAR2'||unistr('\000a')||
'IS'||unistr('\000a')||
'  v_value VARCHAR2(32767);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  v_value := V(P_NAME);'||unistr('\000a')||
'  '||unistr('\000a')||
'  RETURN CASE'||unistr('\000a')||
'    WHEN v_value = ''%null%'' then NULL'||unistr('\000a')||
'    ELSE v_value'||unistr('\000a')||
'  end;'||unistr('\000a')||
'end GET_VALUE;'||unistr('\000a')||
''||unistr('\000a')||
'function current_time_ms'||unistr('\000a')||
'  return number'||unistr('\000a')||
'is'||unistr('\000a')||
'  out_result number;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  select '||unistr('\000a')||
'    extr'||
'act(day from(systimestamp - to_timestamp(''1970-01-01'', ''YYYY-MM-DD''))) * 86400000 + to_number(to_char(sys_extract_utc(systimestamp), ''SSSSSFF3''))'||unistr('\000a')||
'  into '||unistr('\000a')||
'    out_result'||unistr('\000a')||
'  from '||unistr('\000a')||
'    dual;'||unistr('\000a')||
'    '||unistr('\000a')||
'  return out_result;'||unistr('\000a')||
'end current_time_ms;'||unistr('\000a')||
''||unistr('\000a')||
'function perform_binds('||unistr('\000a')||
'  p_string in varchar2,'||unistr('\000a')||
'  p_escape in boolean default false'||unistr('\000a')||
') return varchar2 '||unistr('\000a')||
'is'||unistr('\000a')||
'  v_item_names DBMS_SQL.VARCHAR2_TABLE;'||unistr('\000a')||
'  '||unistr('\000a')||
'  v_item_value v'||
'archar2(100);'||unistr('\000a')||
'  v_string varchar2(32000);'||unistr('\000a')||
'  v_test_number number;'||unistr('\000a')||
'  v_isnumber boolean := false;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  v_string := p_string;'||unistr('\000a')||
'  v_item_names := WWV_FLOW_UTILITIES.GET_BINDS( v_string ); '||unistr('\000a')||
'  '||unistr('\000a')||
'  for i in 1..v_item_names.count loop'||unistr('\000a')||
'  '||unistr('\000a')||
'    v_item_value := APEX_UTIL.GET_SESSION_STATE ('||unistr('\000a')||
'      p_item => ltrim(v_item_names(i), '':'')'||unistr('\000a')||
'    );'||unistr('\000a')||
''||unistr('\000a')||
'    if p_escape then'||unistr('\000a')||
'      --jesli w sesji jest uzyty apostrof, we'||
'-escape-uj go'||unistr('\000a')||
'      v_item_value := replace(v_item_value, chr(39), chr(39)||chr(39));'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'    if v_item_value is null then'||unistr('\000a')||
'      v_string := replace(v_string, v_item_names(i), ''NULL'');'||unistr('\000a')||
'      continue;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'    begin'||unistr('\000a')||
'      v_test_number := to_number(v_item_value);  '||unistr('\000a')||
'      v_isnumber := true;'||unistr('\000a')||
'    exception'||unistr('\000a')||
'      when others then'||unistr('\000a')||
'        v_isnumber := false;'||unistr('\000a')||
'    end;'||unistr('\000a')||
''||unistr('\000a')||
'    if v_isnumb'||
'er then'||unistr('\000a')||
'      v_string := replace(v_string, v_item_names(i), v_item_value);'||unistr('\000a')||
'    else'||unistr('\000a')||
'      v_string := replace(v_string, v_item_names(i), chr(39)||v_item_value||chr(39));'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'  '||unistr('\000a')||
'  end loop;'||unistr('\000a')||
'  '||unistr('\000a')||
'  v_string := apex_plugin_util.replace_substitutions ('||unistr('\000a')||
'    p_value => v_string,'||unistr('\000a')||
'    p_escape => true '||unistr('\000a')||
'  );'||unistr('\000a')||
'  '||unistr('\000a')||
'  return v_string;'||unistr('\000a')||
'  '||unistr('\000a')||
'end perform_binds;'||unistr('\000a')||
''||unistr('\000a')||
'function get_func_boolean_result('||unistr('\000a')||
'  p_code in v'||
'archar2'||unistr('\000a')||
') return boolean'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_func_block varchar2(32000);'||unistr('\000a')||
'  v_result varchar2(1);'||unistr('\000a')||
'  v_code varchar2(32000);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  '||unistr('\000a')||
'  v_code := perform_binds( p_code, true );'||unistr('\000a')||
'  v_code := replace(v_code, ''declare'', ''DECLARE'');'||unistr('\000a')||
'  v_code := replace(v_code, ''begin'', ''BEGIN'');'||unistr('\000a')||
''||unistr('\000a')||
'  if instr(v_code, ''DECLARE'') > 0 then'||unistr('\000a')||
'    v_code := replace(v_code, ''DECLARE'', ''function test return boolean is'');'||unistr('\000a')||
'  elsif instr(v_code, '''||
'BEGIN'') > 0 then'||unistr('\000a')||
'    v_code := replace(v_code, ''BEGIN'', ''function test return boolean is begin'');'||unistr('\000a')||
'  else'||unistr('\000a')||
'    v_code := ''function test return boolean is begin ''||v_code||'' end;'';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  v_func_block := '''||unistr('\000a')||
'    declare'||unistr('\000a')||
'      v_result boolean;'||unistr('\000a')||
'      ''||v_code||'''||unistr('\000a')||
'    begin'||unistr('\000a')||
'      v_result := test();'||unistr('\000a')||
''||unistr('\000a')||
'      if v_result then'||unistr('\000a')||
'        :out := 1;'||unistr('\000a')||
'      else'||unistr('\000a')||
'        :out := 0;'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end; '||unistr('\000a')||
'  '''||
';'||unistr('\000a')||
'  --htp.p(v_func_block);'||unistr('\000a')||
'  execute immediate v_func_block using out v_result;'||unistr('\000a')||
''||unistr('\000a')||
'  if v_result = 1 then'||unistr('\000a')||
'    return true;'||unistr('\000a')||
'  else'||unistr('\000a')||
'    return false;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'end get_func_boolean_result;'||unistr('\000a')||
''||unistr('\000a')||
'function get_plsql_expression_result('||unistr('\000a')||
'  p_expression in varchar2'||unistr('\000a')||
') return boolean'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_expression varchar2(32000);'||unistr('\000a')||
'  v_func_block varchar2(32000);'||unistr('\000a')||
'  v_result varchar2(1);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  v_expression := perform_binds( p'||
'_expression, true );'||unistr('\000a')||
'  v_func_block := '''||unistr('\000a')||
'    begin '||unistr('\000a')||
'      if ''||v_expression||'' then '||unistr('\000a')||
'        return 1; '||unistr('\000a')||
'      else '||unistr('\000a')||
'       return 0; '||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end;'||unistr('\000a')||
'  '';'||unistr('\000a')||
' '||unistr('\000a')||
'  v_result := APEX_PLUGIN_UTIL.GET_PLSQL_FUNCTION_RESULT( v_func_block );'||unistr('\000a')||
''||unistr('\000a')||
'  if v_result = ''1'' then'||unistr('\000a')||
'    return true;'||unistr('\000a')||
'  else'||unistr('\000a')||
'    return false;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'end get_plsql_expression_result;'||unistr('\000a')||
''||unistr('\000a')||
'function getItemFormatMask('||unistr('\000a')||
'  p_item_id in varch'||
'ar2'||unistr('\000a')||
') return varchar2 is'||unistr('\000a')||
'  v_format_mask varchar2(200);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  select '||unistr('\000a')||
'    FORMAT_MASK '||unistr('\000a')||
'  into'||unistr('\000a')||
'    v_format_mask'||unistr('\000a')||
'  from '||unistr('\000a')||
'    APEX_APPLICATION_PAGE_ITEMS '||unistr('\000a')||
'  where '||unistr('\000a')||
'    application_id = :APP_ID'||unistr('\000a')||
'    and page_id = :APP_PAGE_ID '||unistr('\000a')||
'    and item_name = p_item_id;'||unistr('\000a')||
''||unistr('\000a')||
'  return v_format_mask;  '||unistr('\000a')||
''||unistr('\000a')||
'EXCEPTION'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    return null;'||unistr('\000a')||
'end getItemFormatMask;'||unistr('\000a')||
''||unistr('\000a')||
'function selectCountFromQuery('||unistr('\000a')||
'  p_query in va'||
'rchar2'||unistr('\000a')||
') return number'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_query varchar2(32000);'||unistr('\000a')||
'  v_count number :=0;'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
''||unistr('\000a')||
'  v_query := perform_binds( p_query, true );'||unistr('\000a')||
'  v_query := ''select count(1) from (''|| v_query ||'')'';'||unistr('\000a')||
''||unistr('\000a')||
'  execute immediate v_query into v_count;'||unistr('\000a')||
''||unistr('\000a')||
'  return v_count;'||unistr('\000a')||
''||unistr('\000a')||
'end selectCountFromQuery;'||unistr('\000a')||
''||unistr('\000a')||
'function rtrim_ws('||unistr('\000a')||
'  p_val in varchar2'||unistr('\000a')||
') return varchar2'||unistr('\000a')||
'as'||unistr('\000a')||
''||unistr('\000a')||
'begin'||unistr('\000a')||
'  return rtrim(replace(replace(p_val,chr(13),null),chr(10),nu'||
'll));'||unistr('\000a')||
'end rtrim_ws;'||unistr('\000a')||
''||unistr('\000a')||
'procedure isRunConditionMatched('||unistr('\000a')||
'  p_condition_type_code in varchar2,'||unistr('\000a')||
'  p_condition_expression1 in varchar2,'||unistr('\000a')||
'  p_condition_expression2 in varchar2,'||unistr('\000a')||
'  p_out_run out number,'||unistr('\000a')||
'  p_out_msg out varchar2'||unistr('\000a')||
''||unistr('\000a')||
')'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_cond_type varchar2(100) := p_condition_type_code;'||unistr('\000a')||
'  v_cond_1  VARCHAR2(32767) := WWV_FLOW.DO_SUBSTITUTIONS(p_condition_expression1);'||unistr('\000a')||
'  v_cond_2  VARCHAR2(32767) := WWV_FLOW'||
'.DO_SUBSTITUTIONS(p_condition_expression2);'||unistr('\000a')||
'  e_stop_processing exception;'||unistr('\000a')||
'  e_return_true exception;'||unistr('\000a')||
'  e_return_false exception;'||unistr('\000a')||
'  e_unkown_condition exception;'||unistr('\000a')||
'  e_return_no_condition exception;'||unistr('\000a')||
''||unistr('\000a')||
'  v_test_boolean boolean;'||unistr('\000a')||
'  v_test_result varchar2(3200);'||unistr('\000a')||
'  v_test_number number;'||unistr('\000a')||
''||unistr('\000a')||
'  l_val varchar2(4000);'||unistr('\000a')||
'  l_len number;'||unistr('\000a')||
''||unistr('\000a')||
'BEGIN'||unistr('\000a')||
''||unistr('\000a')||
'  if p_condition_type_code is null then'||unistr('\000a')||
'    raise e_return_no_condition'||
';'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  if v_cond_type = ''NEVER'' then'||unistr('\000a')||
'    raise e_return_false;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ALWAYS'' then'||unistr('\000a')||
'    raise e_return_true;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''SQL_EXPRESION'', ''SQL_EXPRESSION'') then'||unistr('\000a')||
'    v_test_result := ''select 1 from dual where ''||perform_binds( v_cond_1 );'||unistr('\000a')||
''||unistr('\000a')||
'    if selectCountFromQuery( v_test_result ) = 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''FUNCTI'||
'ON_BODY'' then'||unistr('\000a')||
''||unistr('\000a')||
'    v_test_boolean := get_func_boolean_result( v_cond_1 );'||unistr('\000a')||
''||unistr('\000a')||
'    if NOT v_test_boolean then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ITEM_IS_NOT_NULL'' then '||unistr('\000a')||
'    if GET_VALUE( v_cond_1 ) is null then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type =''EXISTS'' then'||unistr('\000a')||
'    if selectCountFromQuery( v_cond_1 ) <= 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if'||
';'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type =''NOT_EXISTS'' then'||unistr('\000a')||
'    if selectCountFromQuery( v_cond_1 ) > 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type =''VAL_OF_ITEM_IN_COND_EQ_COND2'' then'||unistr('\000a')||
'    if GET_VALUE( v_cond_1 ) <> v_cond_2 OR GET_VALUE( v_cond_1 ) is null then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;      '||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type in (''PLSQL_EXPRESSION'',''PLSQL_EXPRESION'') then'||unistr('\000a')||
'    if not get_pls'||
'ql_expression_result( v_cond_1 ) then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''ITEM_IS_NOT_ZERO'',''ITEM_NOT_ZERO'')  then'||unistr('\000a')||
'    if NVL( V( RTRIM_WS(v_cond_1) ),''x'' ) = ''0'' then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ITEM_CONTAINS_NO_SPACES'' then'||unistr('\000a')||
'    if INSTR(REPLACE(V(WWV_FLOW.DO_SUBSTITUTIONS(RTRIM_WS(v_cond_1),''TEXT'')),''%null%'',NULL),'' '') > 0 then'||unistr('\000a')||
'  '||
'     raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''ITEM_NOT_NULL_OR_ZERO'', ''ITEM_IS_NOT_NULL_OR_ZERO'', ''FLOW_ITEM_IS_NOT_NULL_OR_ZERO'') then'||unistr('\000a')||
'    if V(RTRIM_WS(v_cond_1)) IS NULL OR V(RTRIM_WS(v_cond_1)) = ''0'' then'||unistr('\000a')||
'        raise e_return_false;'||unistr('\000a')||
'    end if;    '||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ITEM_IS_ALPHANUMERIC'' then'||unistr('\000a')||
''||unistr('\000a')||
'    l_len := NVL(LENGTH(REPLACE(V(WWV_FLOW.DO_SUBSTITUTIONS(UPPER(RTRIM_WS'||
'(v_cond_1)),''TEXT'')),''%null%'',NULL)),0);'||unistr('\000a')||
'    l_val := REPLACE(V(UPPER(v_cond_1)),''%null%'',NULL);'||unistr('\000a')||
''||unistr('\000a')||
'    FOR J IN 1..L_LEN LOOP'||unistr('\000a')||
'      if INSTR(''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_'',SUBSTR(L_VAL,J,1)) = 0 then'||unistr('\000a')||
'        raise e_return_false;'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end LOOP;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ITEM_IS_NUMERIC'' then'||unistr('\000a')||
'    begin'||unistr('\000a')||
'      v_test_number := REPLACE(V(WWV_FLOW.DO_SUBSTIT'||
'UTIONS(RTRIM_WS(v_cond_1),''TEXT'')),''%null%'',NULL);'||unistr('\000a')||
'    exception '||unistr('\000a')||
'      when others then'||unistr('\000a')||
'        raise e_return_false;'||unistr('\000a')||
'    end;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''ITEM_IS_NOT_NUMERIC'' then'||unistr('\000a')||
'      begin'||unistr('\000a')||
'         v_test_number := REPLACE(V(WWV_FLOW.DO_SUBSTITUTIONS(RTRIM_WS( v_cond_1 ),''TEXT'')),''%null%'',NULL);'||unistr('\000a')||
'         raise e_return_false; '||unistr('\000a')||
'      exception when others then'||unistr('\000a')||
'         null;'||unistr('\000a')||
'      end;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_'||
'cond_type IN (''VAL_OF_ITEM_IN_COND_NOT_EQ_COND2'', ''VAL_OF_ITEM_IN_COND_NOT_EQ_COND_TEXT'', ''VALUE_OF_ITEM_NAMED_IN_COND1_NOT_EQUAL_TEXT_IN_COND2'') then'||unistr('\000a')||
'    if NVL(V(RTRIM_WS( v_cond_1 )),''Mjhakb'') = NVL(WWV_FLOW.DO_SUBSTITUTIONS( v_cond_1 ),''mjHbka'') then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''ITEM_IS_NULL'',''FLOW_ITEM_IS_NULL'') then'||unistr('\000a')||
'    if REPLACE(V(RTRIM_WS( v_cond_1 )),'||
'''%null%'',NULL) IS NULL then'||unistr('\000a')||
'      null;'||unistr('\000a')||
'    ELSE'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''ITEM_IS_NULL_OR_ZERO'') then'||unistr('\000a')||
'    if V(RTRIM_WS( v_cond_1 )) IS NULL OR V(RTRIM_WS( v_cond_1 )) = ''0'' then'||unistr('\000a')||
'      null;'||unistr('\000a')||
'    ELSE'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type IN (''ITEM_IS_ZERO'') then'||unistr('\000a')||
'    if NVL(V(RTRIM_WS( v_cond_1 )),''x'') <> ''0'' then'||unistr('\000a')||
'      raise e_return_'||
'false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''VALUE_OF_ITEM_IN_CONDITION_IN_COLON_DELIMITED_LIST'' then'||unistr('\000a')||
'    IF INSTR('':''||WWV_FLOW.DO_SUBSTITUTIONS(v_cond_2,''TEXT'')||'':'','':''||V(RTRIM_WS( v_cond_1 ))||'':'') > 0 THEN'||unistr('\000a')||
'      null;'||unistr('\000a')||
'    ELSE'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_cond_type = ''VALUE_OF_ITEM_IN_CONDITION_NOT_IN_COLON_DELIMITED_LIST'' then'||unistr('\000a')||
'    if instr('':''||WWV_FLOW.DO_SUBSTITUTIONS('||
' v_cond_2,''TEXT'')||'':'','':''||V(RTRIM_WS( v_cond_1 ))||'':'') > 0 THEN'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      null;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  else'||unistr('\000a')||
'    raise e_unkown_condition;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  raise e_return_true;'||unistr('\000a')||
''||unistr('\000a')||
'EXCEPTION'||unistr('\000a')||
'  when e_return_no_condition then'||unistr('\000a')||
'    p_out_run := 1;'||unistr('\000a')||
'    p_out_msg := ''No condition for validation'';'||unistr('\000a')||
'  when e_return_true then'||unistr('\000a')||
'    p_out_run := 1;'||unistr('\000a')||
'    p_out_msg := ''Condition [''||v_cond_ty'||
'pe||''] passed.'';'||unistr('\000a')||
'  when e_return_false then'||unistr('\000a')||
'    p_out_run := 0;'||unistr('\000a')||
'    p_out_msg := ''Condition [''||v_cond_type||''] not passed. Validation is not executed.'';'||unistr('\000a')||
'  when e_unkown_condition then'||unistr('\000a')||
'    p_out_run := 2;'||unistr('\000a')||
'    p_out_msg := ''Condition type [''|| v_cond_type || ''] not suppoerted. Sorry'';'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    p_out_run := 2;'||unistr('\000a')||
'    p_out_msg := ''Unexpected error: ''||SQLERRM;'||unistr('\000a')||
'end isRunConditionMatched;'||unistr('\000a')||
''||unistr('\000a')||
''||
'procedure validate('||unistr('\000a')||
'  P_VALIDATION_TYPE in varchar2,'||unistr('\000a')||
'  p_validation_name in varchar2,'||unistr('\000a')||
'  p_validation_expression1 in varchar2,'||unistr('\000a')||
'  p_validation_expression2 in varchar2,'||unistr('\000a')||
'  p_validation_error_text in varchar2,'||unistr('\000a')||
'  p_out_error_text out varchar2,'||unistr('\000a')||
'  p_out_status out number,'||unistr('\000a')||
'  p_out_msg out varchar2'||unistr('\000a')||
')'||unistr('\000a')||
'is'||unistr('\000a')||
'  L_EXPRESSION1 VARCHAR2(32767) := WWV_FLOW.DO_SUBSTITUTIONS(p_validation_expression1);'||unistr('\000a')||
'  L_EXPRESSION2 V'||
'ARCHAR2(32767) := WWV_FLOW.DO_SUBSTITUTIONS(p_validation_expression2);'||unistr('\000a')||
'  L_VALUE VARCHAR2(32767);'||unistr('\000a')||
'  L_LEN number;'||unistr('\000a')||
'  l_boolean boolean;'||unistr('\000a')||
'  '||unistr('\000a')||
'  v_val_type varchar2(3200) := P_VALIDATION_TYPE;'||unistr('\000a')||
'  v_val_name varchar2(3200) := P_VALIDATION_name;'||unistr('\000a')||
''||unistr('\000a')||
'  e_return_true exception;'||unistr('\000a')||
'  e_return_false exception;'||unistr('\000a')||
'  e_unknown_validation exception;'||unistr('\000a')||
''||unistr('\000a')||
'  v_test_number number;'||unistr('\000a')||
'  v_test_date date;'||unistr('\000a')||
'  v_test_result varchar2(32'||
'00);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  p_out_error_text := p_validation_error_text;'||unistr('\000a')||
''||unistr('\000a')||
'  --obsluga walidacji wbudowanych'||unistr('\000a')||
'  if P_VALIDATION_TYPE = ''NATIVE_NUMBER_FIELD'' then'||unistr('\000a')||
'    p_out_error_text := REPLACE(APEX_LANG.MESSAGE(''APEX.NUMBER_FIELD.VALUE_INVALID''), ''APEX.NUMBER_FIELD.VALUE_INVALID'', ''#LABEL# must be Numeric.'');'||unistr('\000a')||
''||unistr('\000a')||
'  elsif P_VALIDATION_TYPE = ''ITEM_REQUIRED'' then'||unistr('\000a')||
'    p_out_error_text := REPLACE(APEX_LANG.MESSAGE(''APEX'||
'.PAGE_ITEM_IS_REQUIRED'', L_EXPRESSION2), ''APEX.PAGE_ITEM_IS_REQUIRED'', ''#LABEL# must have some value.'');'||unistr('\000a')||
''||unistr('\000a')||
'  elsif P_VALIDATION_TYPE = ''NATIVE_DATE_PICKER'' then'||unistr('\000a')||
'    p_out_error_text := REPLACE(APEX_LANG.MESSAGE(''APEX.DATEPICKER_VALUE_INVALID'', L_EXPRESSION2), ''APEX.DATEPICKER_VALUE_INVALID'', ''#LABEL# does not match format ''||L_EXPRESSION2||''.'');'||unistr('\000a')||
'  end if;'||unistr('\000a')||
'  --//obsluga walidacji wbudowanych    '||unistr('\000a')||
''||unistr('\000a')||
'  '||
'if v_val_type =''EXISTS'' then'||unistr('\000a')||
'    if selectCountFromQuery( L_EXPRESSION1 ) <= 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''NOT_EXISTS'' then'||unistr('\000a')||
'    if selectCountFromQuery( L_EXPRESSION1 ) > 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_NOT_ZERO'' then'||unistr('\000a')||
'    if NOT NVL(GET_VALUE(L_EXPRESSION1),''x'') != ''0'' then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;    '||unistr('\000a')||
''||
''||unistr('\000a')||
'  elsif v_val_type in (''ITEM_NOT_NULL'', ''ITEM_REQUIRED'') then'||unistr('\000a')||
'    if GET_VALUE(L_EXPRESSION1) IS NULL then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_NOT_NULL_OR_ZERO'' then'||unistr('\000a')||
'    L_VALUE := GET_VALUE(L_EXPRESSION1);'||unistr('\000a')||
''||unistr('\000a')||
'    if L_VALUE IS NULL OR L_VALUE = ''0'' then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type = ''ITEM_IS_ALPHANUMERIC'' then'||unistr('\000a')||
'    L_VALUE := GET_VALUE('||
'L_EXPRESSION1);'||unistr('\000a')||
'    L_LEN   := NVL(LENGTH(L_VALUE),0);'||unistr('\000a')||
'    FOR J IN 1 .. L_LEN LOOP '||unistr('\000a')||
'      if INSTR(''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_'',SUBSTR(L_VALUE,J,1)) = 0 then'||unistr('\000a')||
'        raise e_return_false;'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end LOOP;  '||unistr('\000a')||
'    '||unistr('\000a')||
'  elsif v_val_type in (''NATIVE_NUMBER_FIELD'', ''ITEM_IS_NUMERIC'')  then'||unistr('\000a')||
'    L_VALUE := GET_VALUE(L_EXPRESSION1);'||unistr('\000a')||
'    BEGIN'||unistr('\000a')||
'      v_test_numb'||
'er := to_number( replace(replace(L_VALUE, '','', NULL), ''.'', null) );'||unistr('\000a')||
'    EXCEPTION'||unistr('\000a')||
'      WHEN OTHERS then'||unistr('\000a')||
'        raise e_return_false;'||unistr('\000a')||
'    end;'||unistr('\000a')||
'    '||unistr('\000a')||
'  elsif v_val_type =''ITEM_CONTAINS_NO_SPACES'' then'||unistr('\000a')||
'    if INSTR(GET_VALUE(L_EXPRESSION1),'' '') > 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type in (''ITEM_IS_DATE'', ''NATIVE_DATE_PICKER'') then'||unistr('\000a')||
'    L_VALUE := GET_VALUE(L_EXPRESSION1);'||unistr('\000a')||
''||
'    if L_VALUE is not null then'||unistr('\000a')||
'      begin'||unistr('\000a')||
'        v_test_date := to_date(L_VALUE, nvl(getItemFormatMask(L_EXPRESSION1),''DD-MON-RR''));'||unistr('\000a')||
'      exception'||unistr('\000a')||
'        when others then'||unistr('\000a')||
'          raise e_return_false;'||unistr('\000a')||
'      end;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IS_TIMESTAMP'' then'||unistr('\000a')||
'    raise e_unknown_validation;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type IN (''SQL_EXPRESION'', ''SQL_EXPRESSION'') then'||unistr('\000a')||
'    v_test_result := ''sele'||
'ct 1 from dual where ''||perform_binds( L_EXPRESSION1, true );'||unistr('\000a')||
''||unistr('\000a')||
'    if selectCountFromQuery( v_test_result ) = 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type in (''PLSQL_EXPRESION'', ''PLSQL_EXPRESSION'') then'||unistr('\000a')||
'    '||unistr('\000a')||
'    if not get_plsql_expression_result( L_EXPRESSION1 ) then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''PLSQL_ERROR'' then'||unistr('\000a')||
'    raise e_return_false;'||unistr('\000a')||
''||unistr('\000a')||
'  '||
'elsif v_val_type =''FUNC_BODY_RETURNING_ERR_TEXT'' then'||unistr('\000a')||
'    '||unistr('\000a')||
'    v_test_result := APEX_PLUGIN_UTIL.GET_PLSQL_FUNCTION_RESULT( L_EXPRESSION1 );'||unistr('\000a')||
''||unistr('\000a')||
'    if v_test_result is not null then'||unistr('\000a')||
'      p_out_error_text := v_test_result; '||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''FUNC_BODY_RETURNING_BOOLEAN'' then'||unistr('\000a')||
'    l_boolean := get_func_boolean_result( L_EXPRESSION1 );'||unistr('\000a')||
''||unistr('\000a')||
'    if not l_boolean t'||
'hen'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''REGULAR_EXPRESSION'' then'||unistr('\000a')||
'    L_VALUE := GET_VALUE(L_EXPRESSION1);'||unistr('\000a')||
'    if not REGEXP_LIKE (l_value, l_expression2) then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_IN_STRING2'' then  '||unistr('\000a')||
'    if instr(L_EXPRESSION2, get_value(L_EXPRESSION1)) = 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_'||
'val_type =''ITEM_IN_VALIDATION_NOT_IN_STRING2'' then'||unistr('\000a')||
'    if instr(L_EXPRESSION2, get_value(L_EXPRESSION1)) > 0 then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_EQ_STRING2'' then'||unistr('\000a')||
'    L_VALUE := GET_VALUE(L_EXPRESSION1);'||unistr('\000a')||
''||unistr('\000a')||
'    if L_EXPRESSION2 = l_value then'||unistr('\000a')||
'      l_boolean := true;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      l_boolean := false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'    if not l_boolean then'||unistr('\000a')||
'      raise'||
' e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_NOT_EQ_STRING2'' then'||unistr('\000a')||
'    if L_EXPRESSION2 = get_value(L_EXPRESSION1) then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_CONTAINS_ONLY_CHAR_IN_STRING2'' then'||unistr('\000a')||
'    l_value := get_value(l_expression1);'||unistr('\000a')||
'    '||unistr('\000a')||
'    if l_value is null then'||unistr('\000a')||
'      l_boolean := true;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      for i in 1 .. length('||
'l_value) loop'||unistr('\000a')||
'        if instr(l_expression2, substr(l_value, i, 1)) = 0 then'||unistr('\000a')||
'          l_boolean := false;'||unistr('\000a')||
'          exit;'||unistr('\000a')||
'        end if;'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if not l_boolean then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_CONTAINS_AT_LEAST_ONE_CHAR_IN_STRING2'' then'||unistr('\000a')||
'    l_boolean := false;'||unistr('\000a')||
'    l_value   := get_value(l_expression1);'||unistr('\000a')||
''||unistr('\000a')||
'    if l'||
'_value is null then'||unistr('\000a')||
'      l_boolean := false;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      for i in 1..length(l_value) loop'||unistr('\000a')||
'        if instr(l_expression2, substr(l_value, i, 1)) > 0 then'||unistr('\000a')||
'          l_boolean := true;'||unistr('\000a')||
'          exit;'||unistr('\000a')||
'        end if;'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if not l_boolean then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  elsif v_val_type =''ITEM_IN_VALIDATION_CONTAINS_NO_CHAR_IN_STRING2'' then'||unistr('\000a')||
'  '||unistr('\000a')||
'    '||
'l_value := get_value(l_expression1);'||unistr('\000a')||
'    if l_value is null then'||unistr('\000a')||
'      l_boolean := true;'||unistr('\000a')||
'    else'||unistr('\000a')||
'      for i in 1..length(l_value) loop'||unistr('\000a')||
'        if instr(l_expression2, substr(l_value, i, 1)) > 0 then'||unistr('\000a')||
'          l_boolean := false;'||unistr('\000a')||
'          exit;'||unistr('\000a')||
'        end if;'||unistr('\000a')||
'      end loop;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
'    '||unistr('\000a')||
'    if not l_boolean then'||unistr('\000a')||
'      raise e_return_false;'||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  else'||unistr('\000a')||
'    raise e_unknown_validatio'||
'n;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  raise e_return_true;'||unistr('\000a')||
''||unistr('\000a')||
'EXCEPTION'||unistr('\000a')||
'  when e_return_true then'||unistr('\000a')||
'    p_out_status := 1;'||unistr('\000a')||
'    p_out_msg := ''Validation "''|| v_val_name ||''" [''|| v_val_type ||''] passed'';'||unistr('\000a')||
'  when e_return_false then'||unistr('\000a')||
'    p_out_status := 0;'||unistr('\000a')||
'    p_out_msg := ''Validation "''|| v_val_name ||''" [''|| v_val_type ||''] failed'';'||unistr('\000a')||
'  when e_unknown_validation then'||unistr('\000a')||
'    p_out_status := 2;'||unistr('\000a')||
'    p_out_msg := ''Validation type [''|'||
'| v_val_type || ''] not suppoerted. Sorry'';'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    p_out_status := 2;'||unistr('\000a')||
'    p_out_error_text := ''Error occured while performin validation: ''||replace(replace(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, chr(13), '' ''), chr(10), '' '');'||unistr('\000a')||
'    p_out_msg := ''Error occured while performin validation: ''||replace(replace(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, chr(13), '' ''), chr(10), '' '');'||unistr('\000a')||
'end validate;'||unistr('\000a')||
''||unistr('\000a')||
'p'||
'rocedure collectLogs('||unistr('\000a')||
'  pi_names IN t_tab,'||unistr('\000a')||
'  pi_codes IN t_tab,'||unistr('\000a')||
'  pi_statuses IN t_tab,'||unistr('\000a')||
'  pi_msges IN t_tab,'||unistr('\000a')||
'  pi_conditions IN t_tab,'||unistr('\000a')||
'  po_exception OUT varchar2,'||unistr('\000a')||
'  po_json OUT varchar2'||unistr('\000a')||
') is'||unistr('\000a')||
'  v_logs_json varchar2(32000);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  if pi_names.count > 0 then'||unistr('\000a')||
'    for i in pi_names.first..pi_names.last loop'||unistr('\000a')||
'      v_logs_json := v_logs_json||''{'||unistr('\000a')||
'        "validationCode": "''||pi_codes(i)||''",'||unistr('\000a')||
'        "v'||
'alidationName": "''||pi_names(i)||''",'||unistr('\000a')||
'        "validationMsg": "''||pi_msges(i)||''",'||unistr('\000a')||
'        "validationCondition": "''||pi_conditions(i)||''",'||unistr('\000a')||
'        "passed": ''||pi_statuses(i)||'''||unistr('\000a')||
'      }'';'||unistr('\000a')||
'    '||unistr('\000a')||
'      if i <> pi_names.last then'||unistr('\000a')||
'        v_logs_json := v_logs_json||'','';'||unistr('\000a')||
'      end if;'||unistr('\000a')||
'    end loop;'||unistr('\000a')||
''||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  po_json := v_logs_json;'||unistr('\000a')||
''||unistr('\000a')||
'EXCEPTION'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    po_exception := SQLERRM;'||unistr('\000a')||
'end col'||
'lectLogs;'||unistr('\000a')||
''||unistr('\000a')||
'function getFieldsToReValidate('||unistr('\000a')||
'  p_item_name in varchar2'||unistr('\000a')||
') return varchar2 is'||unistr('\000a')||
'  v_items_to_validate varchar2(3200);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
''||unistr('\000a')||
'  select'||unistr('\000a')||
'    listagg(''#''||ASSOCIATED_ITEM, '','') within group( order by 1 )'||unistr('\000a')||
'  into '||unistr('\000a')||
'    v_items_to_validate'||unistr('\000a')||
'  from ('||unistr('\000a')||
'    select '||unistr('\000a')||
'      distinct'||unistr('\000a')||
'        ASSOCIATED_ITEM'||unistr('\000a')||
'    from'||unistr('\000a')||
'      APEX_APPLICATION_PAGE_VAL aapv'||unistr('\000a')||
'    where '||unistr('\000a')||
'      application_id = :APP_ID'||unistr('\000a')||
'      and '||
'page_id = :APP_PAGE_ID'||unistr('\000a')||
'      and instr('':''||CONDITION_EXPRESSION1||CONDITION_EXPRESSION2||VALIDATION_EXPRESSION1||VALIDATION_EXPRESSION2||'':'', p_item_name) > 0'||unistr('\000a')||
'      and ASSOCIATED_ITEM <> p_item_name  '||unistr('\000a')||
'  );'||unistr('\000a')||
''||unistr('\000a')||
'  return v_items_to_validate;'||unistr('\000a')||
''||unistr('\000a')||
'end getFieldsToReValidate;'||unistr('\000a')||
''||unistr('\000a')||
'function validation_result( '||unistr('\000a')||
'  p_time in number,'||unistr('\000a')||
'  p_item in varchar2,'||unistr('\000a')||
'  p_passed in varchar2,'||unistr('\000a')||
'  p_message in varchar2,'||unistr('\000a')||
'  p_revalida'||
'te in varchar2,'||unistr('\000a')||
'  p_logs in varchar2'||unistr('\000a')||
') return varchar2 is'||unistr('\000a')||
'  v_time_mask varchar2(24) := ''999G999G999G999G990D0000'';'||unistr('\000a')||
'begin'||unistr('\000a')||
'  return '''||unistr('\000a')||
'    {'||unistr('\000a')||
'      "validation_result": {'||unistr('\000a')||
'        "time": {'||unistr('\000a')||
'          "ms": "''     ||replace(to_char(p_time, v_time_mask),'' '', '''')||''",'||unistr('\000a')||
'          "seconds": "''||replace(to_char((p_time/1000), v_time_mask),'' '', '''')||''",'||unistr('\000a')||
'          "minutes": "''||replace(to_char((p_time/1000/6'||
'0), v_time_mask),'' '', '''')||''"'||unistr('\000a')||
'        },'||unistr('\000a')||
'        "item": "''||p_item||''",'||unistr('\000a')||
'        "passed": ''||p_passed||'','||unistr('\000a')||
'        "message": "''||p_message||''",'||unistr('\000a')||
'        "revalidate": "''||p_revalidate||''",'||unistr('\000a')||
'        "logs": [''||p_logs||'']'||unistr('\000a')||
'      }'||unistr('\000a')||
'    }'||unistr('\000a')||
'  '';'||unistr('\000a')||
'end;'||unistr('\000a')||
''||unistr('\000a')||
'function ajax_validation ('||unistr('\000a')||
'  p_dynamic_action in apex_plugin.t_dynamic_action,'||unistr('\000a')||
'  p_plugin         in apex_plugin.t_plugin '||unistr('\000a')||
') return apex_plugin.t_dynamic_a'||
'ction_ajax_result'||unistr('\000a')||
'is'||unistr('\000a')||
'  v_val_names t_tab;'||unistr('\000a')||
'  v_val_statuses t_tab;'||unistr('\000a')||
'  v_val_codes t_tab;'||unistr('\000a')||
'  v_val_msges t_tab;'||unistr('\000a')||
'  v_val_conditions t_tab;'||unistr('\000a')||
'  v_revalidate number := NVL(p_dynamic_action.attribute_08, 0);'||unistr('\000a')||
'  v_reval_fields varchar2(4000);'||unistr('\000a')||
'  v_result apex_plugin.t_dynamic_action_ajax_result;'||unistr('\000a')||
'  v_item_id varchar2(100) := apex_application.g_x01;'||unistr('\000a')||
'  v_validation_msg varchar2(32000);'||unistr('\000a')||
''||unistr('\000a')||
'  v_cond_out_msg varchar2('||
'3200);'||unistr('\000a')||
'  v_cond_out_run number;'||unistr('\000a')||
''||unistr('\000a')||
'  v_val_out_msg varchar2(3200);'||unistr('\000a')||
'  v_val_out_status number;'||unistr('\000a')||
''||unistr('\000a')||
'  v_label varchar2(100);'||unistr('\000a')||
'  '||unistr('\000a')||
'  v_logs_json varchar2(32000);'||unistr('\000a')||
''||unistr('\000a')||
'  v_log_exception varchar2(32000);'||unistr('\000a')||
'  v_val_count number :=0;'||unistr('\000a')||
'  e_validation_not_found exception;'||unistr('\000a')||
''||unistr('\000a')||
'  v_val_error_text varchar2(32000);'||unistr('\000a')||
'  v_itemsReValidate varchar2(32000);'||unistr('\000a')||
''||unistr('\000a')||
'  v_time_start number;'||unistr('\000a')||
'  v_time_end number;'||unistr('\000a')||
'  v_time_diff number;'||unistr('\000a')||
'begin'||unistr('\000a')||
'  v'||
'_time_start := current_time_ms();'||unistr('\000a')||
''||unistr('\000a')||
'  if v_revalidate = 1 then'||unistr('\000a')||
'    v_reval_fields := getFieldsToReValidate(v_item_id);'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  BEGIN'||unistr('\000a')||
'    select'||unistr('\000a')||
'      LABEL'||unistr('\000a')||
'    into'||unistr('\000a')||
'      v_label'||unistr('\000a')||
'    from'||unistr('\000a')||
'      APEX_APPLICATION_PAGE_ITEMS'||unistr('\000a')||
'    where'||unistr('\000a')||
'      application_id = :APP_ID'||unistr('\000a')||
'      and page_id = :APP_PAGE_ID'||unistr('\000a')||
'      and ITEM_NAME = v_item_id;'||unistr('\000a')||
''||unistr('\000a')||
'  EXCEPTION'||unistr('\000a')||
'    when no_data_found then'||unistr('\000a')||
'      v_label := ''label no'||
't found'';'||unistr('\000a')||
'    WHEN OTHERS then'||unistr('\000a')||
'      v_label := SQLERRM;'||unistr('\000a')||
'  end;'||unistr('\000a')||
''||unistr('\000a')||
'  for validation_row in ('||unistr('\000a')||
'    select'||unistr('\000a')||
'      *'||unistr('\000a')||
'    from ('||unistr('\000a')||
'      select '||unistr('\000a')||
'        VALIDATION_TYPE_CODE,'||unistr('\000a')||
'        VALIDATION_name,'||unistr('\000a')||
'        validation_expression1,'||unistr('\000a')||
'        validation_expression2,'||unistr('\000a')||
'        VALIDATION_FAILURE_TEXT,'||unistr('\000a')||
'        VALIDATION_SEQUENCE,'||unistr('\000a')||
'        CONDITION_TYPE,'||unistr('\000a')||
'        CONDITION_TYPE_CODE,'||unistr('\000a')||
'        CONDITION_EXPRESSION1,'||unistr('\000a')||
''||
'        CONDITION_EXPRESSION2             '||unistr('\000a')||
'      from'||unistr('\000a')||
'        APEX_APPLICATION_PAGE_VAL aapv'||unistr('\000a')||
'      where'||unistr('\000a')||
'        aapv.application_id = :APP_ID'||unistr('\000a')||
'        and aapv.page_id = :APP_PAGE_ID'||unistr('\000a')||
'        and aapv.ASSOCIATED_ITEM = v_item_id'||unistr('\000a')||
'        and ( '||unistr('\000a')||
'          aapv.CONDITION_TYPE_CODE <> ''NEVER'' '||unistr('\000a')||
'          OR aapv.CONDITION_TYPE_CODE is null'||unistr('\000a')||
'        )'||unistr('\000a')||
'      union all'||unistr('\000a')||
''||unistr('\000a')||
'      select'||unistr('\000a')||
'        DISPLAY_AS_CODE '||
'VALIDATION_TYPE_CODE,'||unistr('\000a')||
'        DISPLAY_AS_CODE VALIDATION_name,'||unistr('\000a')||
'        v_item_id validation_expression1,'||unistr('\000a')||
'        FORMAT_MASK validation_expression2,'||unistr('\000a')||
'        ''item buildin validation ''||DISPLAY_AS_CODE VALIDATION_FAILURE_TEXT,'||unistr('\000a')||
'        999999999999 VALIDATION_SEQUENCE,'||unistr('\000a')||
'        null CONDITION_TYPE,'||unistr('\000a')||
'        null CONDITION_TYPE_CODE,'||unistr('\000a')||
'        null CONDITION_EXPRESSION1,'||unistr('\000a')||
'        null CONDITION_EXPRESSION'||
'2'||unistr('\000a')||
'      from'||unistr('\000a')||
'        APEX_APPLICATION_PAGE_ITEMS'||unistr('\000a')||
'      where'||unistr('\000a')||
'        application_id = :APP_ID'||unistr('\000a')||
'        and page_id = :APP_PAGE_ID'||unistr('\000a')||
'        and ITEM_NAME = v_item_id'||unistr('\000a')||
'        and DISPLAY_AS_CODE in (''NATIVE_NUMBER_FIELD'', ''NATIVE_DATE_PICKER'') '||unistr('\000a')||
''||unistr('\000a')||
'      union all'||unistr('\000a')||
''||unistr('\000a')||
'      select'||unistr('\000a')||
'        ''ITEM_REQUIRED'','||unistr('\000a')||
'        ''ITEM_REQUIRED'','||unistr('\000a')||
'        v_item_id,'||unistr('\000a')||
'        FORMAT_MASK,'||unistr('\000a')||
'        ''item buildin validation ITEM_'||
'REQUIRED'','||unistr('\000a')||
'        999999999999,'||unistr('\000a')||
'        null,'||unistr('\000a')||
'        null,'||unistr('\000a')||
'        null,'||unistr('\000a')||
'        null'||unistr('\000a')||
'      from'||unistr('\000a')||
'        APEX_APPLICATION_PAGE_ITEMS'||unistr('\000a')||
'      where'||unistr('\000a')||
'        application_id = :APP_ID'||unistr('\000a')||
'        and page_id = :APP_PAGE_ID'||unistr('\000a')||
'        and ITEM_NAME = v_item_id'||unistr('\000a')||
'        and upper(IS_REQUIRED) = ''YES'''||unistr('\000a')||
'    )'||unistr('\000a')||
'    order by'||unistr('\000a')||
'      VALIDATION_SEQUENCE asc'||unistr('\000a')||
'  ) LOOP'||unistr('\000a')||
'    v_val_count := v_val_count +1;'||unistr('\000a')||
'    '||unistr('\000a')||
'    isRunCondi'||
'tionMatched('||unistr('\000a')||
'      p_condition_type_code => validation_row.condition_type_code,'||unistr('\000a')||
'      p_condition_expression1 => validation_row.condition_expression1,'||unistr('\000a')||
'      p_condition_expression2 => validation_row.condition_expression2,'||unistr('\000a')||
'      p_out_run => v_cond_out_run,'||unistr('\000a')||
'      p_out_msg => v_cond_out_msg'||unistr('\000a')||
'    );'||unistr('\000a')||
''||unistr('\000a')||
'    if v_cond_out_run in (0,2) then'||unistr('\000a')||
'      v_val_names( v_val_names.count+1 ) := htf.escape_sc( valida'||
'tion_row.VALIDATION_name );'||unistr('\000a')||
'      v_val_codes( v_val_codes.count+1 ) := htf.escape_sc( validation_row.VALIDATION_TYPE_CODE );'||unistr('\000a')||
'      v_val_conditions( v_val_conditions.count+1 ) := htf.escape_sc( v_cond_out_msg );'||unistr('\000a')||
''||unistr('\000a')||
'      if v_cond_out_run = 2 then'||unistr('\000a')||
'        v_val_msges( v_val_msges.count+1) := htf.escape_sc( ''Error occured in validation.'');'||unistr('\000a')||
'        v_val_statuses( v_val_statuses.count+1 ) := ''"error"'||
''';    '||unistr('\000a')||
'        v_validation_msg := ''Error occured in validation.'';'||unistr('\000a')||
'        raise e_validation_failed; '||unistr('\000a')||
'      else'||unistr('\000a')||
'        v_val_statuses( v_val_statuses.count+1 ) := ''null'';'||unistr('\000a')||
'        v_val_msges( v_val_msges.count+1) := htf.escape_sc( ''null'' );'||unistr('\000a')||
'        continue;'||unistr('\000a')||
'      end if;'||unistr('\000a')||
''||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'    validate('||unistr('\000a')||
'      P_VALIDATION_TYPE => validation_row.VALIDATION_TYPE_CODE,'||unistr('\000a')||
'      p_validation_name => valid'||
'ation_row.VALIDATION_name,'||unistr('\000a')||
'      p_validation_expression1 => validation_row.validation_expression1,'||unistr('\000a')||
'      p_validation_expression2 => validation_row.validation_expression2,'||unistr('\000a')||
'      p_validation_error_text => validation_row.VALIDATION_FAILURE_TEXT,'||unistr('\000a')||
'      p_out_error_text => v_val_error_text,'||unistr('\000a')||
'      p_out_status => v_val_out_status,'||unistr('\000a')||
'      p_out_msg => v_val_out_msg'||unistr('\000a')||
'    );'||unistr('\000a')||
'    '||unistr('\000a')||
'    v_val_msges( v_val_ms'||
'ges.count+1) := htf.escape_sc(v_val_out_msg);'||unistr('\000a')||
'    v_val_names( v_val_names.count+1 ) := htf.escape_sc(validation_row.VALIDATION_name);'||unistr('\000a')||
'    v_val_codes( v_val_codes.count+1 ) := htf.escape_sc(validation_row.VALIDATION_TYPE_CODE);'||unistr('\000a')||
'    v_val_conditions( v_val_conditions.count+1 ) := htf.escape_sc( v_cond_out_msg );'||unistr('\000a')||
''||unistr('\000a')||
'    if v_val_out_status = 1 then'||unistr('\000a')||
'      v_val_statuses( v_val_statuses.count+1 ) := ''t'||
'rue'';'||unistr('\000a')||
'      continue;'||unistr('\000a')||
'    elsif v_val_out_status = 0 then'||unistr('\000a')||
'      v_val_statuses( v_val_statuses.count+1 ) := ''false'';'||unistr('\000a')||
'      v_validation_msg := v_val_error_text;'||unistr('\000a')||
'      raise e_validation_failed; '||unistr('\000a')||
'    else --2'||unistr('\000a')||
'      v_val_statuses( v_val_statuses.count+1 ) := ''"error"'';'||unistr('\000a')||
'      v_validation_msg := ''Error occured while performin validation.'';'||unistr('\000a')||
'      raise e_validation_failed; '||unistr('\000a')||
'    end if;'||unistr('\000a')||
''||unistr('\000a')||
'  end LOOP;'||unistr('\000a')||
''||unistr('\000a')||
''||
'  if v_val_count = 0 then'||unistr('\000a')||
'    raise e_validation_not_found;'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  collectLogs(v_val_names, v_val_codes, v_val_statuses, v_val_msges, v_val_conditions, v_log_exception, v_logs_json);'||unistr('\000a')||
''||unistr('\000a')||
'  if v_log_exception is not null then'||unistr('\000a')||
'    htp.p( v_log_exception );'||unistr('\000a')||
'  end if;'||unistr('\000a')||
''||unistr('\000a')||
'  v_time_end := current_time_ms();'||unistr('\000a')||
'  v_time_diff := v_time_end - v_time_start;'||unistr('\000a')||
''||unistr('\000a')||
'  htp.p( validation_result(v_time_diff, v_item_id, '||
'''true'', ''Field is valid.'', v_reval_fields, v_logs_json ) );'||unistr('\000a')||
''||unistr('\000a')||
'  return v_result;'||unistr('\000a')||
'EXCEPTION'||unistr('\000a')||
'  when e_validation_not_found then'||unistr('\000a')||
'    v_time_end := current_time_ms();'||unistr('\000a')||
'    v_time_diff := v_time_end - v_time_start;'||unistr('\000a')||
''||unistr('\000a')||
'    htp.p( validation_result(v_time_diff, v_item_id, chr(34)||''not_found''||chr(34), ''Validation for this field not found'', v_reval_fields, ''[]'' ) );'||unistr('\000a')||
''||unistr('\000a')||
'    return v_result;'||unistr('\000a')||
'  when e_validation_'||
'failed then'||unistr('\000a')||
'    v_validation_msg := htf.escape_sc(v_validation_msg);'||unistr('\000a')||
'    v_validation_msg := replace(v_validation_msg, chr(35)||''LABEL''||chr(35), v_label);'||unistr('\000a')||
'    v_validation_msg := replace(v_validation_msg, chr(13)||chr(10), ''\n'');'||unistr('\000a')||
''||unistr('\000a')||
'    collectLogs(v_val_names, v_val_codes, v_val_statuses, v_val_msges, v_val_conditions, v_log_exception, v_logs_json);'||unistr('\000a')||
'    '||unistr('\000a')||
'    v_time_end := current_time_ms();'||unistr('\000a')||
'    v_'||
'time_diff := v_time_end - v_time_start;'||unistr('\000a')||
''||unistr('\000a')||
'    htp.p( validation_result(v_time_diff, v_item_id, ''false'', v_validation_msg, v_reval_fields, v_logs_json ) );'||unistr('\000a')||
''||unistr('\000a')||
'    return v_result;'||unistr('\000a')||
'  WHEN OTHERS then'||unistr('\000a')||
'    htp.p(''ajax_validation: ''||SQLERRM );'||unistr('\000a')||
'    return v_result;'||unistr('\000a')||
'end ajax_validation;'
 ,p_render_function => 'render_validation'
 ,p_ajax_function => 'ajax_validation'
 ,p_substitute_attributes => false
 ,p_attribute_01 => '<span class="t-Form-error">#ERROR_MESSAGE#</span>'
 ,p_version_identifier => '1.1.1'
 ,p_about_url => 'http://pretius.com/technologies/apex-client-side-validation-plugin-2/'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 99645830410494612 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Global Error template'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '<span class="t-Form-error">#ERROR_MESSAGE#</span>'
 ,p_is_translatable => false
 ,p_help_text => '<p>'||unistr('\000a')||
'This attribute contains default error message template which is displayed after validation failure. Validation messages are rendered with this template when the plugin attribute&nbsp;<strong>Override global template</strong>&nbsp;defined on page is set to&nbsp;<strong>NO</strong>.'||unistr('\000a')||
'</p>'||unistr('\000a')||
'<p>'||unistr('\000a')||
'Default: &lt;span class=&quot;apexBuildInErrorText&quot;&gt;&lt;br&gt;#ERROR_MESSAGE#&lt;/span&gt;'||unistr('\000a')||
'</p>'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 17
 ,p_prompt => 'Render validation result'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => '1'
 ,p_is_translatable => false
 ,p_help_text => '<style>'||unistr('\000a')||
'  table.pretius_desc {'||unistr('\000a')||
'    margin: 5px;'||unistr('\000a')||
'  }'||unistr('\000a')||
''||unistr('\000a')||
'  table.pretius_desc td {'||unistr('\000a')||
'    padding: 10px;'||unistr('\000a')||
'  }'||unistr('\000a')||
''||unistr('\000a')||
'  table.pretius_desc tr:nth-child(even) {'||unistr('\000a')||
'    background: #F3F3F3;'||unistr('\000a')||
'  }'||unistr('\000a')||
''||unistr('\000a')||
'</style>'||unistr('\000a')||
''||unistr('\000a')||
'<p>'||unistr('\000a')||
'  This attribute defines how validation result should be displayed. Available option are described below:'||unistr('\000a')||
'</p>'||unistr('\000a')||
'<table class="pretius_desc" cellpadding="0" cellspacing="0">'||unistr('\000a')||
'  <tr >'||unistr('\000a')||
'    <th data-column="0" tabindex="0" unselectable="on">'||unistr('\000a')||
'      <div >Option</div>'||unistr('\000a')||
'    </th>'||unistr('\000a')||
'    <th data-column="1" tabindex="0" unselectable="on">'||unistr('\000a')||
'      <div >Description</div>'||unistr('\000a')||
'    </th>'||unistr('\000a')||
'  </tr>'||unistr('\000a')||
'  <tr>'||unistr('\000a')||
'    <td valign="top">Custom callback function</td>'||unistr('\000a')||
'    <td valign="top">This option allows developer to define custom validation result handling with JavaScript. When this option is selected, attribute <strong>Callback function</strong> is accessible. <strong>Callback function </strong>attribute is described in this document.</td>'||unistr('\000a')||
'  </tr>'||unistr('\000a')||
'  <tr>'||unistr('\000a')||
'    <td valign="top">Error text and highlight field</td>'||unistr('\000a')||
'    <td valign="top">Validation message is displayed after validation. Text field is highlighted. Highlight color depends on CSS classes <em>pretius_highlight_success</em> and <em>pretius_highlight_error.</em>'||unistr('\000a')||
'    </td>'||unistr('\000a')||
'  </tr>'||unistr('\000a')||
'  <tr>'||unistr('\000a')||
'    <td valign="top">Error text and icons after field</td>'||unistr('\000a')||
'    <td valign="top">Validation message and status image indicators are displayed after validation.</td>'||unistr('\000a')||
'  </tr>'||unistr('\000a')||
'  <tr>'||unistr('\000a')||
'    <td valign="top">Error text only</td>'||unistr('\000a')||
'    <td valign="top">Only the validation message is displayed after validation failure.</td>'||unistr('\000a')||
'  </tr>'||unistr('\000a')||
''||unistr('\000a')||
'</table>'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 100731416116974694 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Error text only'
 ,p_return_value => '1'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99528120368920798 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => 'Error text and icons after field'
 ,p_return_value => '3'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99528528333923169 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 40
 ,p_display_value => 'Error text and highlight field'
 ,p_return_value => '4'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 100731818887975545 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 99
 ,p_display_value => 'Custom callback function'
 ,p_return_value => '2'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 100732709668982360 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 18
 ,p_prompt => 'Callback function'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => '2'
 ,p_help_text => '<style>table.pretius_desc{margin: 5px;}table.pretius_desc td{padding: 10px;}table.pretius_desc tr:nth-child(even){background: #F3F3F3;}</style><p> This attribute defines custom validation result handling with Java Script function implementation. Function declaration is defined as below:</p><pre>function( triggeringElement, itemName, validationResult, errorHTML, errorClass )</pre><p> Function arguments:</p><table class="pretius_desc" cellspacing="0" cellpadding="0"> <tr> <th> Argument </th> <th> Type </th> <th> Description </th> </tr><tr> <td>triggeringElement</td><td>jQuery object</td><td>jQuery reference to validated item field</td></tr><tr> <td>itemName</td><td>String</td><td>Validated APEX item name</td></tr><tr> <td>validationResult</td><td>JSON object</td><td>JSON object containing information about validation result. The structure of JSON object is described under this table</td></tr><tr> <td> <p>errorHTML</p></td><td>HTML string</td><td>Validation error message rendered with error template (attribute <strong>Global</strong><strong> Error template</strong> or <strong>Error template</strong>)</td></tr><tr> <td>errorClass</td><td>String</td><td>jQuery selector to validation message</td></tr></table><p><strong>validationResult</strong> description:</p><table class="pretius_desc" cellspacing="0" cellpadding="0"> <tr> <th> Object attribute </th> <th> Type </th> <th> Description </th> </tr><tr> <td>item</td><td>String</td><td>Name of validated APEX item (e.g. P1_CUSTOMER_ID)</td></tr><tr> <td>message</td><td>String</td><td>Rendered Error Message if validation failed (plain text)</td></tr><tr> <td>passed</td><td>Boolean</td><td>Validation result (true/false)</td></tr><tr> <td>revalidate</td><td>String</td><td>List of APEX Items that will be revalidated after current validation ends (eg. P1_CUSTOMER_NAME,P1_CUSTOMER_ADDRESS)</td></tr><tr> <td>time</td><td>JSON object</td><td> <pre>Execution time of PL/SQL validation process (object attributes are "ms", "seconds" and "minutes")</pre> </td></tr><tr> <td>logs</td><td>Array of JSON</td><td> <p>Each object of the array contains information about performed validations</p></td></tr></table><p><strong>validationResult.logs.logs</strong> describes each validation that was performed for APEX item. Description of JSON object in array:</p><table class="pretius_desc" cellspacing="0" cellpadding="0"> <tbody> <tr> <td><strong>Object attribute</span></strong></td><td><strong>Type</span></strong></td><td><strong>Description</span></strong></td><td><strong>Example</strong></td></tr><tr> <td>passed</td><td>Boolean</td><td>validation result</td><td>true</td></tr><tr> <td>validationCode</td><td>String</td><td>APEX validation code</td><td>ITEM_NOT_NULL</td></tr><tr> <td>validationCondition</td><td>String</td><td>Information about validation condition result</td><td>Condition [PLSQL_EXPRESSION] passed.</td></tr><tr> <td>validationMsg</td><td>String</td><td>Validation message defined in APEX validation</td><td>Validation "P4_NAME not null" [ITEM_NOT_NULL] failed</td></tr><tr> <td>validationName</td><td>String</td><td>Validation name that was executed for specific item</td><td>P4_NAME not null</td></tr></tbody></table>'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 99520336935821560 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Show validation processing'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => '1'
 ,p_is_translatable => false
 ,p_help_text => '<p>'||unistr('\000a')||
'  When this attribute is set to&nbsp;<strong>Yes</strong>, the image is displayed after item field during validation process.'||unistr('\000a')||
'</p>'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99521106591822266 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99520336935821560 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Yes'
 ,p_return_value => '1'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99521508322822695 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99520336935821560 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'No'
 ,p_return_value => '0'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 99637917804055785 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 30
 ,p_prompt => 'Error message place holder'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'BEFORE_LABEL'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 100730814038974066 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'IN_LIST'
 ,p_depending_on_expression => '1,3,4'
 ,p_help_text => '<p>This attribute defines where validation message should be located.</p>'||unistr('\000a')||
'<p>In APEX 4.x validation message&nbsp;is allowed before or after item label.</p>'||unistr('\000a')||
'<p>In APEX 5.x validation message is allowed before or after item label and before or after item.</p>'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99638721959056985 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99637917804055785 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Before label'
 ,p_return_value => 'BEFORE_LABEL'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99639124730057749 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99637917804055785 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'After label'
 ,p_return_value => 'AFTER_LABEL'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99639528193058703 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99637917804055785 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => 'Before item (only APEX 5)'
 ,p_return_value => 'BEFORE_ITEM'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99639930963059512 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99637917804055785 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 40
 ,p_display_value => 'After item (only APEX 5)'
 ,p_return_value => 'AFTER_ITEM'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 99641437936089904 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 12
 ,p_prompt => 'Error template'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '<span class="t-Form-error">#ERROR_MESSAGE#</span>'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 99649326039502868 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'Y'
 ,p_help_text => '<p>'||unistr('\000a')||
'  This attribute contains validation message template, which is used to render validation message after performing validation on the fly.'||unistr('\000a')||
'</p>'||unistr('\000a')||
''
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 99649326039502868 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 7
 ,p_display_sequence => 10
 ,p_prompt => 'Override global template'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'N'
 ,p_is_translatable => false
 ,p_help_text => '<p>When this attribute is set to <strong>Yes</strong>, the <strong>Error template</strong> is used to render validation message. Otherwise validation message is rendered from&nbsp;<strong>Global</strong><strong> Error template</strong>&nbsp;plugin attribute.</p>'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99650130888504279 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99649326039502868 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Yes'
 ,p_return_value => 'Y'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 99650533658505007 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 99649326039502868 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'No'
 ,p_return_value => 'N'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 16258221796276336 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 80
 ,p_prompt => 'Re-validate depending fields'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => '1'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 16259128376278199 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 16258221796276336 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Yes'
 ,p_return_value => '1'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 16259530108278658 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 16258221796276336 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'No'
 ,p_return_value => '0'
  );
wwv_flow_api.create_plugin_event (
  p_id => 98873537036137513 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_name => 'pretius_validation_ended'
 ,p_display_name => 'validation ended'
  );
wwv_flow_api.create_plugin_event (
  p_id => 98862933846830952 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_name => 'pretius_validation_failed'
 ,p_display_name => 'validation not passed'
  );
wwv_flow_api.create_plugin_event (
  p_id => 98871718457065841 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_name => 'pretius_validation_init'
 ,p_display_name => 'validation started'
  );
wwv_flow_api.create_plugin_event (
  p_id => 98925022610541333 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_name => 'pretius_validation_not_found'
 ,p_display_name => 'validation not found'
  );
wwv_flow_api.create_plugin_event (
  p_id => 98863209736833409 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_name => 'pretius_validation_success'
 ,p_display_name => 'validation passed'
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '696D672E76616C69646174696F6E4C6F61646572496D672C200D0A696D672E707265746975735F76616C5F737563636573732C0D0A696D672E707265746975735F76616C5F6661696C6564207B0D0A202070616464696E672D6C6566743A203370783B0D';
wwv_flow_api.g_varchar2_table(2) := '0A20206865696768743A20313270783B0D0A7D0D0A0D0A2E617065784275696C64496E4572726F7254657874207B0D0A2020636F6C6F723A207265643B0D0A7D0D0A0D0A2E742D466F726D2D696E707574436F6E7461696E657220696E7075745B747970';
wwv_flow_api.g_varchar2_table(3) := '653D2274657874225D2E707265746975735F686967686C696768745F6572726F722C20200D0A2E742D466F726D2D696E707574436F6E7461696E657220696E7075742E746578745F6669656C642E707265746975735F686967686C696768745F6572726F';
wwv_flow_api.g_varchar2_table(4) := '722C0D0A696E7075742E707265746975735F686967686C696768745F6572726F72207B0D0A20206261636B67726F756E642D636F6C6F723A20234646453445343B0D0A7D0D0A0D0A0D0A2E742D466F726D2D696E707574436F6E7461696E657220696E70';
wwv_flow_api.g_varchar2_table(5) := '75745B747970653D2274657874225D2E707265746975735F686967686C696768745F737563636573732C0D0A2E742D466F726D2D696E707574436F6E7461696E657220696E7075742E746578745F6669656C642E707265746975735F686967686C696768';
wwv_flow_api.g_varchar2_table(6) := '745F737563636573732C0D0A696E7075742E707265746975735F686967686C696768745F73756363657373207B0D0A20206261636B67726F756E642D636F6C6F723A20234534464645363B0D0A7D';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 2912217716235601 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_file_name => 'pretius_validation_style.css'
 ,p_mime_type => 'text/css'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E20707265746975735F76616C69646174696F6E28206F626A2C2066696C655F7072656669782029207B0D0A0D0A202066756E6374696F6E206765744572726F7254656D706C6174652820617474726962757465732029207B0D0A2020';
wwv_flow_api.g_varchar2_table(2) := '202072657475726E20617474726962757465732E6174747269627574653037203D3D20275927203F20617474726962757465732E6174747269627574653036203A20617474726962757465732E61747472696275746531303B0D0A20207D0D0A0D0A2020';
wwv_flow_api.g_varchar2_table(3) := '66756E6374696F6E206765744572726F72436C6173732820617474726962757465732029207B0D0A2020202076617220636F6E7461696E6572203D202428206765744572726F7254656D706C617465282061747472696275746573202920292E66696C74';
wwv_flow_api.g_varchar2_table(4) := '65722866756E6374696F6E28297B0D0A2020202020206966202820242874686973292E697328273A636F6E7461696E732822234552524F525F4D455353414745232229272920290D0A202020202020202072657475726E20747275653B0D0A202020207D';
wwv_flow_api.g_varchar2_table(5) := '292C0D0A2020202073656C6563746F72203D20272E272B636F6E7461696E65722E617474722827636C61737327292E73706C697428272027292E6A6F696E28272E27293B202020200D0A0D0A2020202072657475726E2073656C6563746F723B0D0A2020';
wwv_flow_api.g_varchar2_table(6) := '7D0D0A0D0A202066756E6374696F6E2072656D6F7665486967686C69676874732820656C656D20297B0D0A20202020656C656D2E72656D6F7665436C6173732827707265746975735F686967686C696768745F6572726F7227292E72656D6F7665436C61';
wwv_flow_api.g_varchar2_table(7) := '73732827707265746975735F686967686C696768745F7375636365737327293B0D0A20207D0D0A0D0A202066756E6374696F6E2072656D6F7665496E64696361746F72732820656C656D20297B0D0A20202020656C656D2E706172656E7428292E66696E';
wwv_flow_api.g_varchar2_table(8) := '6428272E707265746975735F76616C5F6661696C65642C2E707265746975735F76616C5F737563636573732C202E76616C69646174696F6E4C6F61646572496D6727292E72656D6F766528293B0D0A20207D0D0A0D0A202066756E6374696F6E2072656D';
wwv_flow_api.g_varchar2_table(9) := '6F76654572726F724D657373616765282072656E6465724F7074696F6E2C20706C7567696E417474726962757465732C20706172656E742029207B0D0A2020202076617220656C656D3272656D6F7665203D20706172656E742E66696E642820706C7567';
wwv_flow_api.g_varchar2_table(10) := '696E417474726962757465732E617065784572726F72436C61737320293B0D0A0D0A202020206966202872656E6465724F7074696F6E20213D2032290D0A202020202020656C656D3272656D6F76652E72656D6F766528293B0D0A2020202020200D0A20';
wwv_flow_api.g_varchar2_table(11) := '207D0D0A0D0A202066756E6374696F6E2063616C6C6261636B46756E74696F6E28726573756C742C20706C7567696E417474726962757465732C206576656E744461746129207B0D0A202020206576616C28222866756E6374696F6E2874726967676572';
wwv_flow_api.g_varchar2_table(12) := '696E67456C656D656E742C6974656D4E616D652C76616C69646174696F6E526573756C742C206572726F7248544D4C2C206572726F72436C617373297B222B63616C6C6261636B2B227D292874726967676572696E67456C656D656E742C206974656D5F';
wwv_flow_api.g_varchar2_table(13) := '69642C20726573756C742E76616C69646174696F6E5F726573756C742C206576656E74446174612E76616C69646174696F6E506C7567696E2E6572726F7248544D4C2C20706C7567696E417474726962757465732E617065784572726F72436C61737329';
wwv_flow_api.g_varchar2_table(14) := '22293B20200D0A20207D0D0A0D0A202066756E6374696F6E2068616E646C6550726573657473282070726573657449642029207B0D0A2020202069662028207072657365744964203D3D20332029200D0A20202020202072656D6F7665496E6469636174';
wwv_flow_api.g_varchar2_table(15) := '6F7273282074726967676572696E67456C656D656E7420293B0D0A20202020656C73652069662028207072657365744964203D3D20342029200D0A20202020202072656D6F7665486967686C6967687473282074726967676572696E67456C656D656E74';
wwv_flow_api.g_varchar2_table(16) := '20293B0D0A20207D3B0D0A0D0A2020766172200D0A2020202062726F777365724576656E74203D206F626A2E62726F777365724576656E742E747970652C200D0A2020202074726967676572696E67456C656D656E74203D2024286F626A2E7472696767';
wwv_flow_api.g_varchar2_table(17) := '6572696E67456C656D656E74292C200D0A202020206973436865636B626F78203D2074726967676572696E67456C656D656E742E697328273A636865636B626F7827292C200D0A202020206973526164696F203D2074726967676572696E67456C656D65';
wwv_flow_api.g_varchar2_table(18) := '6E742E697328273A726164696F27292C200D0A2020202069734669656C64536574203D2074726967676572696E67456C656D656E742E697328276669656C6473657427292C200D0A202020206974656D5F6964203D206E756C6C2C200D0A202020206974';
wwv_flow_api.g_varchar2_table(19) := '656D56616C7565203D206E756C6C2C200D0A202020206974656D5265666572656E6365203D206E756C6C2C200D0A202020206C6F61646572496D67203D206E756C6C2C200D0A2020202061747472696275746573203D206F626A2E616374696F6E2C200D';
wwv_flow_api.g_varchar2_table(20) := '0A20202020706C7567696E41747472696275746573203D206E756C6C2C200D0A2020202063616C6C6261636B203D206F626A2E616374696F6E2E61747472696275746530323B200D0A202020206576656E7444617461203D206E756C6C2C200D0A202020';
wwv_flow_api.g_varchar2_table(21) := '20786872203D206E756C6C2C0D0A2020202066616465496E54696D65203D203530302C0D0A20202020616E696D6174654F626A203D207B0D0A202020202020277370656373273A207B0D0A2020202020202020276F706163697479273A20310D0A202020';
wwv_flow_api.g_varchar2_table(22) := '2020207D2C0D0A202020202020276F7074696F6E73273A207B0D0A2020202020202020276475726174696F6E273A2066616465496E54696D650D0A2020202020207D0D0A202020207D3B0D0A0D0A0D0A0D0A0D0A2020696620282069734669656C645365';
wwv_flow_api.g_varchar2_table(23) := '742029207B0D0A202020206974656D5F6964203D2074726967676572696E67456C656D656E742E617474722827696427293B0D0A202020206974656D56616C7565203D20242E6D616B6541727261792874726967676572696E67456C656D656E742E6669';
wwv_flow_api.g_varchar2_table(24) := '6E6428273A696E7075743A76697369626C653A636865636B656427292E6D61702866756E6374696F6E28297B2072657475726E20746869732E76616C7565207D29292E6A6F696E28273A27293B0D0A20207D0D0A2020656C736520696620282069734368';
wwv_flow_api.g_varchar2_table(25) := '65636B626F78207C7C206973526164696F2029207B0D0A202020206974656D5F6964203D2074726967676572696E67456C656D656E742E706172656E747328276669656C6473657427292E666972737428292E617474722827696427293B0D0A20202020';
wwv_flow_api.g_varchar2_table(26) := '6974656D56616C7565203D20242E6D616B6541727261792874726967676572696E67456C656D656E742E706172656E747328276669656C6473657427292E666972737428292E66696E6428273A696E7075743A76697369626C653A636865636B65642729';
wwv_flow_api.g_varchar2_table(27) := '2E6D61702866756E6374696F6E28297B2072657475726E20746869732E76616C7565207D29292E6A6F696E28273A27293B0D0A202020200D0A20207D0D0A2020656C7365207B0D0A202020206974656D5F6964203D2074726967676572696E67456C656D';
wwv_flow_api.g_varchar2_table(28) := '656E742E617474722827696427293B0D0A202020206974656D56616C7565203D2074726967676572696E67456C656D656E742E76616C28293B0D0A0D0A20207D0D0A20200D0A20206974656D5265666572656E6365203D2024282723272B6974656D5F69';
wwv_flow_api.g_varchar2_table(29) := '64293B0D0A20206C6F61646572496D67203D206974656D5265666572656E63652E706172656E7428292E66696E6428272E76616C69646174696F6E4C6F61646572496D6727293B0D0A20200D0A20206C6F61646572496D67203D206C6F61646572496D67';
wwv_flow_api.g_varchar2_table(30) := '2E73697A652829203E2030203F206C6F61646572496D67203A202428273C696D67207372633D22272B66696C655F7072656669782B276C6F6164696E674261722E6769662220636C6173733D2276616C69646174696F6E4C6F61646572496D672220616C';
wwv_flow_api.g_varchar2_table(31) := '743D226C6F6164696E67223E27293B0D0A0D0A0D0A2020706C7567696E41747472696275746573203D207B0D0A2020202072656E6465724F7074696F6E3A207061727365496E7428617474726962757465732E6174747269627574653031292C0D0A2020';
wwv_flow_api.g_varchar2_table(32) := '2020617065784572726F72436C6173733A206765744572726F72436C61737328206174747269627574657320292C0D0A2020202073686F7750726F63657373696E673A20617474726962757465732E61747472696275746530342C0D0A20202020657272';
wwv_flow_api.g_varchar2_table(33) := '6F72506C616365486F6C6465723A20617474726962757465732E61747472696275746530352C0D0A202020206572726F7254656D706C6174653A206765744572726F7254656D706C61746528206174747269627574657320290D0A20207D3B0D0A0D0A20';
wwv_flow_api.g_varchar2_table(34) := '206576656E7444617461203D207B0D0A2020202076616C69646174696F6E506C7567696E3A207B0D0A2020202020206974656D3A2074726967676572696E67456C656D656E742C0D0A2020202020206974656D49643A206974656D5F69642C0D0A202020';
wwv_flow_api.g_varchar2_table(35) := '2020206C6162656C3A202428275B666F723D272B6974656D5F69642B275D27292C0D0A2020202020206C6162656C546578743A202428275B666F723D272B6974656D5F69642B275D27292E7465787428292C0D0A2020202020207061737365643A206E75';
wwv_flow_api.g_varchar2_table(36) := '6C6C2C0D0A2020202020206D6573736167653A206E756C6C2C0D0A2020202020206572726F7248544D4C3A20706C7567696E417474726962757465732E6572726F7254656D706C6174650D0A202020207D0D0A20207D3B0D0A0D0A202068616E646C6550';
wwv_flow_api.g_varchar2_table(37) := '7265736574732820706C7567696E417474726962757465732E72656E6465724F7074696F6E20293B0D0A0D0A20202F2F6F62736C7567612061747279627574752070726F63657373696E670D0A202069662028706C7567696E417474726962757465732E';
wwv_flow_api.g_varchar2_table(38) := '73686F7750726F63657373696E67203D3D203129207B0D0A202020206C6F61646572496D672E72656D6F766528293B0D0A202020206974656D5265666572656E63652E616674657228206C6F61646572496D672E66616465496E2866616465496E54696D';
wwv_flow_api.g_varchar2_table(39) := '652920293B0D0A20207D0D0A0D0A20202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A20202F2F20444120707265746975735F76616C69646174696F6E5F696E6974207C7C0D0A20202F2F2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(40) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A0D0A2020617065782E64656275672827507265746975732076616C69646174696F6E3A2076616C69646174696F6E20686173206265656E207374617274656420666F72206974656D203D20272B6974';
wwv_flow_api.g_varchar2_table(41) := '656D5F69642B272E27293B0D0A202074726967676572696E67456C656D656E742E747269676765722827707265746975735F76616C69646174696F6E5F696E6974272C206576656E7444617461293B0D0A0D0A20202F2F77796B6F6E616A20616A617820';
wwv_flow_api.g_varchar2_table(42) := '772063656C75207370726177647A656E69612077616C696461636A690D0A2020786872203D20242E616A6178287B0D0A2020202075726C3A277777765F666C6F772E73686F77272C0D0A20202020747970653A27706F7374272C0D0A2020202064617461';
wwv_flow_api.g_varchar2_table(43) := '547970653A276A736F6E272C0D0A202020202F2F64617461547970653A2768746D6C272C0D0A20202020747261646974696F6E616C3A20747275652C0D0A20202020646174613A207B0D0A202020202020705F726571756573743A20224E41544956453D';
wwv_flow_api.g_varchar2_table(44) := '222B206F626A2E616374696F6E2E616A61784964656E7469666965722C0D0A202020202020705F666C6F775F69643A202476282770466C6F77496427292C0D0A202020202020705F666C6F775F737465705F69643A202476282770466C6F775374657049';
wwv_flow_api.g_varchar2_table(45) := '6427292C0D0A202020202020705F696E7374616E63653A202476282770496E7374616E636527292C0D0A202020202020705F6172675F6E616D65733A205B206974656D5F6964205D2C0D0A202020202020705F6172675F76616C7565733A205B20697465';
wwv_flow_api.g_varchar2_table(46) := '6D56616C7565205D2C0D0A2020202020207830313A206974656D5F69640D0A2020202020202F2F7830323A2027736561726368270D0A202020207D2C0D0A202020200D0A20202020737563636573733A2066756E6374696F6E2820726573756C742C2074';
wwv_flow_api.g_varchar2_table(47) := '6578745374617475732C20616A61784F626A20297B202F2F547970653A2046756E6374696F6E2820416E797468696E6720646174612C20537472696E6720746578745374617475732C206A71584852206A7158485220290D0A2020202020202F2F6F6273';
wwv_flow_api.g_varchar2_table(48) := '6C7567612077796761736E6965636961207365736A6920617065780D0A202020202020766172206C6162656C2C20706172656E742C206572726F72546578742C20617065784572726F72203D2066616C73653B0D0A2020202020200D0A2020202020206C';
wwv_flow_api.g_varchar2_table(49) := '6162656C203D202428276C6162656C5B666F723D272B6974656D5F69642B275D27293B0D0A0D0A2020202020206966202820242E696E41727261792820706C7567696E417474726962757465732E6572726F72506C616365486F6C6465722C20205B2742';
wwv_flow_api.g_varchar2_table(50) := '45464F52455F4954454D272C202741465445525F4954454D275D29203E202D3120290D0A2020202020202020706172656E74203D2024282723272B6974656D5F6964292E706172656E7428293B0D0A202020202020656C7365207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(51) := '20706172656E74203D206C6162656C2E706172656E7428293B0D0A2020202020207D0D0A0D0A20202020202069662028706C7567696E417474726962757465732E73686F7750726F63657373696E67203D3D2031290D0A20202020202020206C6F616465';
wwv_flow_api.g_varchar2_table(52) := '72496D672E666164654F7574283530302C2066756E6374696F6E28297B20242874686973292E72656D6F76652829207D293B0D0A0D0A202020202020747279207B0D0A202020202020202074657374203D20726573756C742E76616C69646174696F6E5F';
wwv_flow_api.g_varchar2_table(53) := '726573756C742E6D6573736167653B0D0A20202020202020206572726F7254657874203D2028706C7567696E417474726962757465732E6572726F7254656D706C617465292E7265706C6163652827234552524F525F4D45535341474523272C20726573';
wwv_flow_api.g_varchar2_table(54) := '756C742E76616C69646174696F6E5F726573756C742E6D657373616765293B0D0A2020202020207D2063617463682865727229207B0D0A2020202020202020617065784572726F72203D20747275653B0D0A20202020202020202F2F6E6965207564616C';
wwv_flow_api.g_varchar2_table(55) := '6F2073696520777963687779636963206F637A656B6977616E656A206F64706F776965647A692077616C696461636A690D0A0D0A20202020202020206966202820726573756C742E616464496E666F20213D3D20756E646566696E656429207B0D0A2020';
wwv_flow_api.g_varchar2_table(56) := '20202020202020206966202820726573756C742E616464496E666F20213D3D202220222029207B0D0A202020202020202020202020616C6572742820726573756C742E616464496E666F2B273A20272B726573756C742E6572726F7220293B0D0A202020';
wwv_flow_api.g_varchar2_table(57) := '20202020202020202072657475726E20766F69642830293B0D0A202020202020202020207D0D0A20202020202020202020656C7365207B0D0A2020202020202020202020206572726F7254657874203D2028706C7567696E417474726962757465732E65';
wwv_flow_api.g_varchar2_table(58) := '72726F7254656D706C617465292E7265706C6163652827234552524F525F4D45535341474523272C20726573756C742E6572726F72293B0D0A0D0A202020202020202020202020726573756C74203D20207B0D0A20202020202020202020202020202276';
wwv_flow_api.g_varchar2_table(59) := '616C69646174696F6E5F726573756C74223A207B0D0A202020202020202020202020202020202274696D65223A206E756C6C2C0D0A20202020202020202020202020202020226974656D223A206974656D5F69642C0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(60) := '20202022706173736564223A2066616C73652C0D0A20202020202020202020202020202020226D657373616765223A20726573756C742E6572726F722C0D0A2020202020202020202020202020202022726576616C6964617465223A206E756C6C2C0D0A';
wwv_flow_api.g_varchar2_table(61) := '20202020202020202020202020202020226C6F6773223A205B5D0D0A20202020202020202020202020207D0D0A2020202020202020202020207D3B0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(62) := '202072656D6F76654572726F724D6573736167652820706C7567696E417474726962757465732E72656E6465724F7074696F6E2C20706C7567696E417474726962757465732C20706172656E7420293B0D0A0D0A0D0A2020202020206576656E74446174';
wwv_flow_api.g_varchar2_table(63) := '612E76616C69646174696F6E506C7567696E2E6572726F7248544D4C203D206572726F72546578743B0D0A2020202020206576656E74446174612E76616C69646174696F6E506C7567696E2E706173736564203D20726573756C742E76616C6964617469';
wwv_flow_api.g_varchar2_table(64) := '6F6E5F726573756C742E7061737365643B0D0A2020202020206576656E74446174612E76616C69646174696F6E506C7567696E2E6D657373616765203D20726573756C742E76616C69646174696F6E5F726573756C742E6D6573736167653B0D0A202020';
wwv_flow_api.g_varchar2_table(65) := '20202020200D0A2020202020206966202820726573756C742E76616C69646174696F6E5F726573756C742E726576616C6964617465202029207B0D0A20202020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(66) := '2D5C5C0D0A20202020202020202F2F204153534F434941544544204954454D5320726576616C69646174696F6E207C7C0D0A20202020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A202020202020';
wwv_flow_api.g_varchar2_table(67) := '2020617065782E64656275672827507265746975732076616C69646174696F6E3A20746865206669656C64732028272B726573756C742E76616C69646174696F6E5F726573756C742E726576616C69646174652B27292077696C6C2062652076616C6964';
wwv_flow_api.g_varchar2_table(68) := '617465642061732074686569722076616C69646174696F6E2061726520646570656E64656E74206F6E206974656D203D20272B6974656D5F69642B272E27293B0D0A0D0A20202020202020202F2F646F726F626963206F62736C7567652077616C696461';
wwv_flow_api.g_varchar2_table(69) := '636A6920706F6C20636865636B626F78206920726164696F20626F20616B7475616C6E69652077796B6F6E61206669656C6473657420747269676765720D0A2020202020202020242820726573756C742E76616C69646174696F6E5F726573756C742E72';
wwv_flow_api.g_varchar2_table(70) := '6576616C696461746520292E747269676765722862726F777365724576656E74293B0D0A2020202020207D0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A2020202020202F2F56616C696461636A612070727A65737AC5';
wwv_flow_api.g_varchar2_table(71) := '82617C7C0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A2020202020206966202820726573756C742E76616C69646174696F6E5F726573756C742E706173736564203D3D207472756529207B0D0A0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(72) := '2F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A20202020202020202F2F20524556414C49444154494F4E207C7C0D0A20202020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F20202020202020200D0A2020202020202020617065782E64656275';
wwv_flow_api.g_varchar2_table(73) := '672827507265746975732076616C69646174696F6E3A2076616C69646174696F6E20666F72206974656D203D20272B6974656D5F69642B2720656E646564207769746820737563636573732E27293B0D0A202020202020202074726967676572696E6745';
wwv_flow_api.g_varchar2_table(74) := '6C656D656E742E747269676765722827707265746975735F76616C69646174696F6E5F73756363657373272C206576656E7444617461293B0D0A0D0A202020202020202069662028706C7567696E417474726962757465732E72656E6465724F7074696F';
wwv_flow_api.g_varchar2_table(75) := '6E203D3D203329207B20202020202020200D0A2020202020202020202072656D6F7665496E64696361746F7273282074726967676572696E67456C656D656E7420293B0D0A2020202020202020202074726967676572696E67456C656D656E742E616674';
wwv_flow_api.g_varchar2_table(76) := '657228202428273C696D6720636C6173733D22707265746975735F76616C5F7375636365737322207372633D22272B66696C655F7072656669782B2776616C69646174696F6E5F737563636573732E706E672220616C743D2276616C69646174696F6E20';
wwv_flow_api.g_varchar2_table(77) := '73756363657373223E27292E66616465496E2866616465496E54696D652920293B0D0A20202020202020207D0D0A2020202020202020656C73652069662028706C7567696E417474726962757465732E72656E6465724F7074696F6E203D3D2034290D0A';
wwv_flow_api.g_varchar2_table(78) := '2020202020202020202074726967676572696E67456C656D656E742E616464436C6173732827707265746975735F686967686C696768745F7375636365737327293B2020202020200D0A2020202020207D0D0A0D0A2020202020202F2F2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(79) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A2020202020202F2F56616C696461636A61206E6965207A6E616C657A696F6E617C7C0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A202020202020656C';
wwv_flow_api.g_varchar2_table(80) := '7365206966202820726573756C742E76616C69646174696F6E5F726573756C742E706173736564203D3D20276E6F745F666F756E642729207B0D0A0D0A20202020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(81) := '2D2D2D2D2D2D2D2D2D5C5C0D0A20202020202020202F2F4441206576656E7420707265746975735F76616C69646174696F6E5F6E6F745F666F756E64207C7C0D0A20202020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(82) := '2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A2020202020202020617065782E64656275672827507265746975732076616C69646174696F6E3A206E6F2076616C69646174696F6E20666F756E6420666F72206974656D203D20272B6974656D5F69642B272E27';
wwv_flow_api.g_varchar2_table(83) := '293B0D0A202020202020202074726967676572696E67456C656D656E742E747269676765722827707265746975735F76616C69646174696F6E5F6E6F745F666F756E64272C206576656E7444617461293B0D0A20202020202020200D0A20202020202020';
wwv_flow_api.g_varchar2_table(84) := '20617065782E64656275672827507265746975732076616C69646174696F6E3A2076616C69646174696F6E20666F72206974656D203D20272B6974656D5F69642B2720656E6465642E27293B0D0A202020202020202074726967676572696E67456C656D';
wwv_flow_api.g_varchar2_table(85) := '656E742E747269676765722827707265746975735F76616C69646174696F6E5F656E646564272C206576656E7444617461293B0D0A0D0A202020202020202072657475726E20766F69642830293B0D0A2020202020207D0D0A0D0A2020202020202F2F2D';
wwv_flow_api.g_varchar2_table(86) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A2020202020202F2F56616C696461636A61206E69652070727A65737AC582617C7C0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A20202020202065';
wwv_flow_api.g_varchar2_table(87) := '6C7365207B0D0A20202020202020200D0A0D0A20202020202020206966202820242E696E41727261792820706C7567696E417474726962757465732E72656E6465724F7074696F6E2C205B312C332C20345D29203E202D312029207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(88) := '202020206572726F7254657874203D2024286572726F7254657874292E63737328276F706163697479272C2030292E616464436C6173732827666F726365446973706C617927293B0D0A0D0A2020202020202020202069662028706C7567696E41747472';
wwv_flow_api.g_varchar2_table(89) := '6962757465732E6572726F72506C616365486F6C646572203D3D20274245464F52455F4C4142454C2729207B0D0A2020202020202020202020206C6162656C2E6265666F726528206572726F72546578742E616E696D61746528616E696D6174654F626A';
wwv_flow_api.g_varchar2_table(90) := '2E73706563732C20616E696D6174654F626A2E6F7074696F6E732920293B0D0A202020202020202020207D0D0A20202020202020202020656C73652069662028706C7567696E417474726962757465732E6572726F72506C616365486F6C646572203D3D';
wwv_flow_api.g_varchar2_table(91) := '202741465445525F4C4142454C2729207B0D0A2020202020202020202020206C6162656C2E616674657228206572726F72546578742E616E696D61746528616E696D6174654F626A2E73706563732C20616E696D6174654F626A2E6F7074696F6E732920';
wwv_flow_api.g_varchar2_table(92) := '293B0D0A202020202020202020207D0D0A20202020202020202020656C73652069662028706C7567696E417474726962757465732E6572726F72506C616365486F6C646572203D3D20274245464F52455F4954454D2729207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(93) := '20202074726967676572696E67456C656D656E742E6265666F726528206572726F72546578742E616E696D61746528616E696D6174654F626A2E73706563732C20616E696D6174654F626A2E6F7074696F6E732920293B0D0A202020202020202020207D';
wwv_flow_api.g_varchar2_table(94) := '0D0A20202020202020202020656C73652069662028706C7567696E417474726962757465732E6572726F72506C616365486F6C646572203D3D202741465445525F4954454D2729207B0D0A20202020202020202020202074726967676572696E67456C65';
wwv_flow_api.g_varchar2_table(95) := '6D656E742E616674657228206572726F72546578742E616E696D61746528616E696D6174654F626A2E73706563732C20616E696D6174654F626A2E6F7074696F6E732920293B0D0A202020202020202020207D0D0A20202020202020202020656C736520';
wwv_flow_api.g_varchar2_table(96) := '7B0D0A202020202020202020202020616C6572742827506C7567696E2073657474696E6773206572726F722E20506C6561736520636865636B20706C7567696E20636F6E66696775726174696F6E206F722073656E6420652D6D61696C20746F20617065';
wwv_flow_api.g_varchar2_table(97) := '7840707265746975732E636F6D20666F722068656C702E27293B0D0A202020202020202020207D0D0A0D0A20202020202020207D0D0A0D0A20202020202020202F2F6F6273C58275676120505245534554C393570D0A202020202020202069662028706C';
wwv_flow_api.g_varchar2_table(98) := '7567696E417474726962757465732E72656E6465724F7074696F6E203D3D203329207B0D0A2020202020202020202072656D6F7665496E64696361746F7273282074726967676572696E67456C656D656E7420293B0D0A20202020202020202020747269';
wwv_flow_api.g_varchar2_table(99) := '67676572696E67456C656D656E742E616674657228202428273C696D6720636C6173733D22707265746975735F76616C5F6661696C656422207372633D22272B66696C655F7072656669782B2776616C69646174696F6E5F6661696C65642E706E672220';
wwv_flow_api.g_varchar2_table(100) := '616C743D2276616C69646174696F6E206661696C6564223E27292E66616465496E2866616465496E54696D652920293B0D0A20202020202020207D0D0A2020202020202020656C73652069662028706C7567696E417474726962757465732E72656E6465';
wwv_flow_api.g_varchar2_table(101) := '724F7074696F6E203D3D203429207B0D0A2020202020202020202074726967676572696E67456C656D656E742E616464436C6173732827707265746975735F686967686C696768745F6572726F7227293B0D0A20202020202020207D0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(102) := '202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D0A20202020202020202F2F204441206576656E7420707265746975735F76616C69646174696F6E5F6661696C6564207C7C0D0A20202020';
wwv_flow_api.g_varchar2_table(103) := '202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A2020202020202020617065782E64656275672827507265746975732076616C69646174696F6E3A2076616C69646174696F6E20666F7220';
wwv_flow_api.g_varchar2_table(104) := '6974656D203D20272B6974656D5F69642B2720656E6465642077697468206661696C7572652E27293B0D0A202020202020202074726967676572696E67456C656D656E742E747269676765722827707265746975735F76616C69646174696F6E5F666169';
wwv_flow_api.g_varchar2_table(105) := '6C6564272C206576656E7444617461293B0D0A0D0A2020202020207D0D0A0D0A20202020202069662028706C7567696E417474726962757465732E72656E6465724F7074696F6E203D3D203229207B0D0A202020202020202063616C6C6261636B46756E';
wwv_flow_api.g_varchar2_table(106) := '74696F6E28726573756C742C20706C7567696E417474726962757465732C206576656E7444617461293B0D0A2020202020207D0D0A0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D5C5C0D';
wwv_flow_api.g_varchar2_table(107) := '0A2020202020202F2F204441206576656E7420707265746975735F76616C69646174696F6E5F656E6465647C7C0D0A2020202020202F2F2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F2F0D0A2020202020206170';
wwv_flow_api.g_varchar2_table(108) := '65782E64656275672827507265746975732076616C69646174696F6E3A2076616C69646174696F6E20666F72206974656D203D20272B6974656D5F69642B2720656E6465642E27293B0D0A20202020202074726967676572696E67456C656D656E742E74';
wwv_flow_api.g_varchar2_table(109) := '7269676765722827707265746975735F76616C69646174696F6E5F656E646564272C206576656E7444617461293B0D0A0D0A0D0A0D0A2020202020200D0A202020207D2C0D0A202020200D0A202020206572726F723A2066756E6374696F6E286A715848';
wwv_flow_api.g_varchar2_table(110) := '522C20746578745374617475732C206572726F725468726F776E297B202F2F6A71584852206A715848522C20537472696E6720746578745374617475732C20537472696E67206572726F725468726F776E0D0A202020202020616C65727428274572726F';
wwv_flow_api.g_varchar2_table(111) := '72206F636375726564207768696C652072657472696576696E6720414A415820646174613A20272B746578745374617475732B225C6E222B6572726F725468726F776E293B0D0A202020207D0D0A20207D293B0D0A0D0A7D0D0A0D0A';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 2912906502240781 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_file_name => 'pretius_validation.js'
 ,p_mime_type => 'application/javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '47494638396140004000840000242624C4C2C4E4E2E4D4D2D4F4F2F4CCCACCECEAECDCDADCFCFAFCC4C6C4E4E6E4D4D6D4F4F6F4CCCECCECEEECDCDEDCFCFEFC000000000000000000000000000000000000000000000000000000000000000000000000';
wwv_flow_api.g_varchar2_table(2) := '00000000000000000021FF0B4E45545343415045322E30030100000021F90409060010002C00000000400040000005FE20248E6469928C212CC3280440101C676DDFB8682C721F9080A0105020E48E488883E7F38D10C3682C492D190ACD2C63249516AA';
wwv_flow_api.g_varchar2_table(3) := '4902369B0576A52DF0ED406E6F45E7EE4C6D12B7DDDC78374D8710127778707A72087D100381646F1084673F7D0E808A3E8C8E520206865446230C0D943D9697429D5506090A24A8A101A3A4250E0647043D0228A077090F8C102F3084A6100632C22708';
wwv_flow_api.g_varchar2_table(4) := '93320F24B5640F9B260806B571563D09D0274C3EB32392D70E545851C2C43E0D360E6DB79E0109E160574205D0EA59DD266364AA9E872232F5DA2438A12050027CFE44205828C25E9B6525F4DD6197B044B340D628C1ABF844621B7E227219E4682291A2';
wwv_flow_api.g_varchar2_table(5) := '810AFE436D24298241A84E0F28A1635962DB9D052135D22C8180D2C09E27779AB0E9C6E11D8442955052F02B50B6A41092B55940340B4EA82462066A20F223566627A52EFA4A821204040CD232209096EDD3AF68DBCA4D4BB6AEDDBB7847786C82D2EE5E';
wwv_flow_api.g_varchar2_table(6) := '1F09FE56B20B5457D52614BF16DCAA55975D93371707EA95B4F01D052E1541C4DAF44E38B164C8822E03818D66AC92EFCC347A07AB601F20435DDDD9F90EA3C69385BEEE313325A5CD2C198CF661ECB00FE03411746DD2BB9DE7E4C2BE91593902B78F95';
wwv_flow_api.g_varchar2_table(7) := '08062406F322813002CB03F031319D84C302488F5C818DC22365F34D56B27697BEC6FA7BED7B80ACD178E545320B18330201C6C9900A09C8047130DB0DA060371C732440B61433C8DDB09239AD94D50A7D09A5160A341BF6F04C1F96B5C248883DD48704';
wwv_flow_api.g_varchar2_table(8) := '861B9E88625F745847898B1B2ED8078B338E1062857D30506013342AD2C07B0939109E163A9E441D4D46E6F68F2E4B26C5C003A305791C916431A0C002054C4263030B60E64F080021F90409060010002C00000000400040000005FE20248E6469928C21';
wwv_flow_api.g_varchar2_table(9) := '2C03392C8FC19C746DDFA2B12441DF933EDFC280C0198F10C720C804327D0307725A32149ECC99081B2C18A848C2951B74927B0502F876386747EEE0627D12C7835AC8DD9750D345043C7B3D79833E0A7F224B8685863D887F0E827B8D8652607E220C0D';
wwv_flow_api.g_varchar2_table(10) := '83957B9754060990220E9D7083A07A014537043E02289C64090F79100C0AB367A00801000005370893010F2492580FAD34B9C541AABFC000CC270B4F5F23C93D09AA380EBB3DBDD2D30035A658B1230C01DD74DBC770E5D307346358A4B889220FF15BF3';
wwv_flow_api.g_varchar2_table(11) := 'E5AA8950702641B67D34C80104C0AAC43D32EA109618B0705E350377BC493450715E4311E1B82490680263C77223FE7CC5D14892E249607E1EC41146D204C1970C41AEAC79E2004E732A0BF23C2140614502E8CE1C1C0A046781A26E0432158133C0B533';
wwv_flow_api.g_varchar2_table(12) := '73A69A30BA30E4937C5A21F8C2F9ECC9ADB062718A65C0960101B66FA5A29D4BB7AEDDBB6B1E3E1979572F93047EDFD40D2AF22A44BB04CF349029B4EE22320B129F393B9530175B71FC8585CA0B42D927743F378160988C66A618DD34287507ADE820A4';
wwv_flow_api.g_varchar2_table(13) := 'EE6465CA79F208C66E284B0CCC6475CA3BA7493278DD239388D2CAC222F0CAC7043B322C132130FE8A8BF1DB5C54211810714DD13EB29ECCDEFA4455F5005EC058818D42AF6ED6D090ED5D6A633DB6F6876EE0368F35BA8336B4E4438C554670A21D7150';
wwv_flow_api.g_varchar2_table(14) := 'B86030483E0404770E09A9ED61C61D0621241925A818B2CC1F96DDE1C920F44D7121865B38C2D71FB891B8CA20E345C24886C0D5C40072647C484603EF25024E1C36EE151D493BD608A38F7631F0C0673D1A93235AB92C508020953410D9924684000021';
wwv_flow_api.g_varchar2_table(15) := 'F90409060010002C00000000400040000005FE20248E6469928CF11C0D392C8FC19C746DDFA2B12441DF933EDFC280C0198F10C720C804327D0307725A32149ECC99081B2C18A848C2951B74927B0902F876386747EEE0627D12C7835AC8DD97A68F083C';
wwv_flow_api.g_varchar2_table(16) := '7B3D79823E0A7E224B8584853D877E808B708D52606A230C0D828C82955406098F3981719C779E495F380486289A64090F79100C0AAF67A8063D973508A4010F240EBF3E0F4535B5C43EB97CC7340B4FAA22C37CA8380EB73DCC412D340E5CC1980109D6';
wwv_flow_api.g_varchar2_table(17) := '48D4C024BAD1346358A2B488220FE1D35C09270A6709D2F127DF64024CB403D8AF4E9C2AA70A964030904BC011D9EC2934A148DF08040927A2B873E9419C021A4D4073330742442CE5FE343288730FA39B7B214596FA77865F4C11ACDC28F0E8C6D9CD11';
wwv_flow_api.g_varchar2_table(18) := 'CA982C1849A6E44F123CC93438C9E4DD5108396105C5F3B4C4415A0CB212D0CAC067550808B232D83A56ECD7B368D3AA056A312D80B770E3BE6DF864D6530372F30220EAF02C46BD7181B9E9F61570E07C6EECDE4460186E809524BF0668FC760084A965';
wwv_flow_api.g_varchar2_table(19) := '9E12A0FC56045F704F2753F602F5CED1CD9C034C8A7C533465A47714F763C01940016790DDD0D38897B2005E103E3FD91DB3B1EA12B951864400BCB7DE03C0E57141856080532A02C6015F923780D7D54150D124FD69E0BB0379117CAF175ED8937D47AC';
wwv_flow_api.g_varchar2_table(20) := '60B119F7C0FA11495145C5B220FA1FE1418452C25BDEE1A00975987167E38220EF64779F09DBEC61C61DF0FDE11F0E8809E24C23C03C88834B926CC1A14D53A813A21E8DC0E447527B987287518898181B7871108708030062E1A252B2C5834D29346241';
wwv_flow_api.g_varchar2_table(21) := 'CE533F92B1638029DDC4C003411D094C8F55D5B240018170D2C0020A407944080021F90409060010002C00000000400040000005FE20248E6469928C212C03392C8FC19C746DDFA2B12441DF933EDFC280C0198F10C720C804327D0307725A32149ECC99';
wwv_flow_api.g_varchar2_table(22) := '081B2C18A848C2951B74927B0502F876386747EEE0627D12C7835AC8DD9750D345043C7B3D79833E0A7F224B8685863D887F818C708E52607E220C0D838D839654060990220E9C947B9F495F38043E02289B64090F79100C0AB167A9063D983408823D0F';
wwv_flow_api.g_varchar2_table(23) := '240EC1410F4535B7C641BB7CC9340B4FABA4C109A9380E633ECE410D35A558AF230C01D774C5C2C458D425DB4FA3B689220FC323E14F09270A6709EDF326F061B147E21D9771004BB47253E50EB684080C6289974B56C2138BFA8D40E0F0A2897271FC3C';
wwv_flow_api.g_varchar2_table(24) := '88F3CDA309696EFEE640A8C8E5A1498E6EF4C1D468F204CA330C0472F95793541C0523DD40EB4982D9930537B9A8245A222899062CE13135B15096D137534BC4C9C4A02B01AF0C86661581A02B83AF67CD8E5DCBB6AD5B1A1283E8731B974F5D1FB5B2CE';
wwv_flow_api.g_varchar2_table(25) := 'E49220A9B8B6FCCE3470CAB76D46A58171AEDDCB4501C83304A70A8823E56A93B196CB4068E32672CFC44F7D6E9D7AF7D0A9334B6B4E8E93873099BC174BF72849F68EE78B0C32F72AE1F7C96D8F08A2FAA04D4E574D2BC42CBB74CD8D048201F1A8B402';
wwv_flow_api.g_varchar2_table(26) := '00A0C5080251AD9FC092AAAA173001A88B0F80898141D8F798A4D2698E679DF0E2E3078065DA86D3EEA85D728CCF7F3C266001A456C326A90018877610F471A7E0782410F01B0DDDEC41C2821406201618A0DD91078515FA4205631A8EC06185171EC18B';
wwv_flow_api.g_varchar2_table(27) := '231B8EA8A0875430E7468A2A3208D0897BC0182379B8F5C6858D1C7E579303C26195E088050C4040890901A998083D062000116331F0C0553C8AE70511483275CB02B9C038065908646943080021F90409060010002C00000000400040000005FE20248E';
wwv_flow_api.g_varchar2_table(28) := '6469928C212C03392C8FC19C746DDFA2B12441DF933EDFC280C0198F10C720C804327D0307725A32149ECC99081B2C18A848C2951B74927B0502F876386747EEE0627D12C7835AC8DD9750D345043C7B3D79833E0A7F224B8685863D887F818C708E5260';
wwv_flow_api.g_varchar2_table(29) := '7E220C0D838D839654060990220E9C947B9F495F38043E02289B64090F79100C0AB167A9063D983408823D0F240EC1410F4535B7C641BB7CC9340B4FABA4C109A9380E633ECE410D35A558AF230C01D774C5C2C458D425DB4FA3B689220FC323E14F0927';
wwv_flow_api.g_varchar2_table(30) := '0A6709EDF326F061B147E21D9771004BB47253E50EB684080C6289974B56C2138BFA8D40E0F0A2897271FC3C88F3CDA309696EFEE640A8C8E5A1498E6EF4C1D468F204CA330C0472F95793541C0502E240EB4982D9930537B9A8245A62E499062CE13135';
wwv_flow_api.g_varchar2_table(31) := 'B15096D137534BC481808081570604BC861D9A554457B168BD965DCBB6AD5B1A1283E8731B974F5D1FB5B2CEE49220A9B8B6FC9E3AB5C836A3D2C038D7EEE5A200E419825383BA9172B549D9CA6520B47103B9276232257572C97AF7D0A9334B6B4A7693';
wwv_flow_api.g_varchar2_table(32) := '6770E29EA57B94347BA7F34506987B95F0FBC4B64704517DCC26A7AB26025FE9B0B874DD8C04020001C84E09DA870481A82D68282F08A03B74305682C4636030EFBAE67000A85F0FDDFC89F0D36099B631385501F6F8A10770E96033DF78C004905A0D9B';
wwv_flow_api.g_varchar2_table(33) := 'A4E2407E08AA6BE7C220F110E01B0DA90490608266DCE1CF3CAD4C48E1697B20F387001A6EB8852301F0740447212258E11E73D181628AECAD18C780976803E37A323EF69B8430E6884503EE454200013D7288C539536538A18F3D20991501068821A21E';
wwv_flow_api.g_varchar2_table(34) := '0305B9D615319ED2C0028DCD13020021F90409060011002C000000004000400084242624C4C2C4E4E2E4D4D2D4F4F2F4CCCACCECEAECDCDADCFCFAFC444644C4C6C4E4E6E4D4D6D4F4F6F4CCCECCECEEECDCDEDCFCFEFC00000000000000000000000000';
wwv_flow_api.g_varchar2_table(35) := '000000000000000000000000000000000000000000000000000000000005FE60248E6469928D011D0E393090D19C746DDFA2C12841DF933E1FC380C0198F91C720C804327D8307725A32149ECC99081B2C18A848C2951B74927B0502F876386747EE2063';
wwv_flow_api.g_varchar2_table(36) := '7D12C783DAC8DDA750D345043C7B3D79833E0B7F224B8685863D887F0F827B8D8652607E220D0E83957B9754060A9039936E9E71A0495F380487289C640A1079110D0BB167AA063DAA2708A610249258104535B7A641BB7CC7340C4FAC22C43D0ABE370F';
wwv_flow_api.g_varchar2_table(37) := 'B9BD24BC4103350F5CC2230D01D674D4E3D358D2256358A4B6892210EA495C0A270B670AEDF326E1C8D813F18E8C807F75E254B973ED1F82825CE269C387F0C4227E231030AC68A25C1C3F10E214E078029A9B3911FE266269C8D123468D6EF2912C19A7';
wwv_flow_api.g_varchar2_table(38) := '41C033FE66028AB320A41B673A49287BC2C0241994414BF824E3402593784977F21BFA266A0985B61A6825B0B50150AB2210686DC095EC58B068D3AA5D4B230180B770E326600B918902B771F302389816A62CBC7AE10650BBEF0CA7C072D55EE4020D71';
wwv_flow_api.g_varchar2_table(39) := 'DC9C3AFD92E9E95870A6A402524500ECF8ABCE3B2212700E1CE0F2CCC28615557E9BC034C9BA4F488D260DF95FE69A3B57BFAD3D0F369316230EE806505A6703AA412EF35A1D804850044EAB99108EB83502CF7F105CA6F6C4B5ABC0099C871D00954AE6';
wwv_flow_api.g_varchar2_table(40) := '3E2408A8046E82C0E8F0C37C7801632548BC06106B201800A03F00F823DCC4076F55C0D60E7EAFD88410407F004AC5986B801885C5282400130052345C27DA01CE5818077B112CE6463C040C64C300CE74B3871977F4F30F6A7B38E34800C66437232A7B';
wwv_flow_api.g_varchar2_table(41) := '1078838A9DC0E1884C7F2C45898F8360F8078FB86D3188897F3420E1193872E1402D156593A41E31B1546574841039A196333500015551D248A55AB7305080209538C0C002675211020021F90409060010002C00000000400040000005FE20248E646992';
wwv_flow_api.g_varchar2_table(42) := '8C212C03392C8FC19C746DDFA2B12441DF933EDFC280C0198F10C720C804327D0307725A32149ECC99081B2C18A848C2951B74927B0502F876386747EEE0627D12C7835AC8DD9750D345043C7B3D79833E0A7F224B8685863D887F0E827B8D8652607323';
wwv_flow_api.g_varchar2_table(43) := '0C0D83957B9754010001A00E9D7083A0495F380900AF01289C64090F79100C0AB367AA063D7E3504AFC301022392580F4535B9934CBD7CCB2702A2C3B024C83D09AA380EBB3DD0410D35D5D6B0ACB801DB74A63D0FD858E825E6E6B19A89220FEFC75C09';
wwv_flow_api.g_varchar2_table(44) := '27E5F46049C367A21D1763241004A41760204140714A005C38CA21410463CE201441D1DCC3138BCEF81321A0E3308B1FFE19DC51436062407B1F4D2C8893C9E4AB03C0626A8A33D266439D2766BA51E9531E50886E14B8A487F2A8332C0B7C3605FAC04D';
wwv_flow_api.g_varchar2_table(45) := '039B05A6EA6C29D2A656A0118FFE41C0A02C01B3656F895DCBB6AD5B824F998C7C2B2223960476B1A8658BC04D02A16436BA557AA641D5C2742184E4B280F099BD47FB2655E926535B6A6EA4C47DF2F68E08C064F6AD754C661C04AE6EDAE6C502490FCD';
wwv_flow_api.g_varchar2_table(46) := 'B598878E382CFBE8EA27A645487673402C83CD417242009D8CEF37B9262873E1763167B627C2F32D4F384030186A7D4810381EC0B2092CAA507B016325486B5C79218B30080E9E5CA335CA3F91C720E3F913B4C39F59C07C7D1B5AE721C083773570A28A';
wwv_flow_api.g_varchar2_table(47) := '8077B46530C2624969275A3724F83288197724001F18A4DDE1C91ECA8CE548001BEE71E1111232828A2173D1411B2527EE41201D256AD8621C0FE2C300716484C84503EA25E24D1C3ACAD55F4C3FE638A3908931F0C06641DA925809B92C5080209534D0';
wwv_flow_api.g_varchar2_table(48) := '588F4784000021F90409060010002C00000000400040000005FE20248E6469924DA002E4B03C0673CE746D434400EC3C3BAAC0C0C280B8198F90436FE913059F0307725AD23197A4A7B660A02205D76B56AB4D10BCB55C58FC239317E8D3621D1EBBCBE7';
wwv_flow_api.g_varchar2_table(49) := 'B84849673BEF6E0A7A227D7E108077827A7C853C768841525E79238D8E6D9040925406098A2203964D87992A9B100E5D37392A02257D050194100C0A2988A706A6360809410F2406610708064427B5BE64B9400945340B5AAA22084B04CFCF350EB79AC1';
wwv_flow_api.g_varchar2_table(50) := '50340E6EAE23C2A3540ECAC023E1D233B1E283270FEA22EC65270A8009D3F127F664F446BC0334AE5F0956804AE88274CA2004040313A18094C0A18901144720C8D4D022834C791E406A60510E243810FEB8DDE9587223A28A2EF5959C110D11837F6EF8';
wwv_flow_api.g_varchar2_table(51) := 'CD5C0749810048D9769250766741CDA242E5216AA092CCA7A42310BA4940D48D0CA855108960C0950101AE5F8362A5D6F5ABD7AE63D3AA5DCBD69D4CB611CBC4D572356DCCA947DD04C4FA135003917ED76204B4209F4DBB3D3F223A90B62F202955DDA4';
wwv_flow_api.g_varchar2_table(52) := '8D4C660FA4BD330D07469509EB5C2D9F32A1DCE918505DC087777E7E42526326CC0619507E320B425E805011340DD29A8462372C072198850EB8D26524100C78EAE5A7191204760FA0819CA70A2E5E0C447CCA206E5D13384FE10CB0EF887632FC187063';
wwv_flow_api.g_varchar2_table(53) := '6E02F529A95A16D48E7AFB89A7E4BE46D74871AA57A6DE100C96C95304C0360333A5045CF008453AA1A15929D92408C403624D7157297549084483482C2461861A5634086A1862528A7E7A78980988A518880603F55965A25FDF39B40D242CDE91407036';
wwv_flow_api.g_varchar2_table(54) := 'EE16448E65F03813030FCC06E48435AE55CB02DCB0D8406149521102003B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 99468035644404937 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_file_name => 'loadingBar.gif'
 ,p_mime_type => 'image/gif'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D49484452000000140000001408060000008D891D0D0000001974455874536F6674776172650041646F626520496D616765526561647971C9653C0000032069545874584D4C3A636F6D2E61646F62652E786D700000000000';
wwv_flow_api.g_varchar2_table(2) := '3C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241';
wwv_flow_api.g_varchar2_table(3) := '646F626520584D5020436F726520352E302D633036302036312E3133343737372C20323031302F30322F31322D31373A33323A30302020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72';
wwv_flow_api.g_varchar2_table(4) := '672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F22';
wwv_flow_api.g_varchar2_table(5) := '20786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F7572';
wwv_flow_api.g_varchar2_table(6) := '6365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204353352057696E646F77732220786D704D4D3A496E7374616E636549443D22786D702E6969643A4343373334304442344233343131453541303937';
wwv_flow_api.g_varchar2_table(7) := '4146303744443138373931322220786D704D4D3A446F63756D656E7449443D22786D702E6469643A4343373334304443344233343131453541303937414630374444313837393132223E203C786D704D4D3A4465726976656446726F6D2073745265663A';
wwv_flow_api.g_varchar2_table(8) := '696E7374616E636549443D22786D702E6969643A4343373334304439344233343131453541303937414630374444313837393132222073745265663A646F63756D656E7449443D22786D702E6469643A4343373334304441344233343131453541303937';
wwv_flow_api.g_varchar2_table(9) := '414630374444313837393132222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3EBC72D771000001E04944415478DABCD4CD4BD4411CC7';
wwv_flow_api.g_varchar2_table(10) := '71D75614420F918917BB98281D842E1511AD295984209A58170F25287B302ADAB0C20EE5C32142F21F082F8A080A0621E4D321BDA5F6A024D8B250948107172C3659B6F7C8676198A64EAB3F78B13BBF87EFCC7C67BE1348A5525999BC027B16305695EB';
wwv_flow_api.g_varchar2_table(11) := '3E2BC515D4E3987917514C60042BF6CB476712BBBFD99E4EF2D08335F4A2501FBF473E1EE1239EE1A0FB71D0691FC0209A308DDBF880647A4628C353DC42051AF02B1DC01D61B7823D463596AD60E632F9F9843A74E222FAEC0076C04ADCC110BA704481';
wwv_flow_api.g_varchar2_table(12) := 'DD69997B2714E8053A70C917F08152F044EDE7788897566AFAAD7BA6C308B6D1EACBE169BCB156CF043C831086F11937F5EC3E36958E599CF28DF03016ACF63C2E6B511A711771346BAAE9DCC634DABF029AFFBF9D7CBDC394D536FB70D47927F9AF4589';
wwv_flow_api.g_varchar2_table(13) := '6B1B64595BA44FD334DBE2BB166EDC59A843F8E90B6872578322B5CDE2DCC30E5A701E5FB565C650801C9CC55B5FC00155C20DB5BFE107C29AE62A6A35D20DCDA81D25EAC05BCBAFF491D957931AED8693B362757652D564F21CA29613BE4A69C317050E';
wwv_flow_api.g_varchar2_table(14) := '7B82A5477E0D735AC4EB48FCEFB42953B5986A58C76B2CAAEC8EE302CA558257B1649F3641CF08CC29734E475744394D59398F2A7766B36FEDDF019BA9EB8F000300D89586BAB70FB20A0000000049454E44AE426082';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 99531426659977693 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_file_name => 'validation_failed.png'
 ,p_mime_type => 'image/png'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '89504E470D0A1A0A0000000D49484452000000140000001408060000008D891D0D0000001974455874536F6674776172650041646F626520496D616765526561647971C9653C0000032069545874584D4C3A636F6D2E61646F62652E786D700000000000';
wwv_flow_api.g_varchar2_table(2) := '3C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B633964223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D2241';
wwv_flow_api.g_varchar2_table(3) := '646F626520584D5020436F726520352E302D633036302036312E3133343737372C20323031302F30322F31322D31373A33323A30302020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F72';
wwv_flow_api.g_varchar2_table(4) := '672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F22';
wwv_flow_api.g_varchar2_table(5) := '20786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F7572';
wwv_flow_api.g_varchar2_table(6) := '6365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204353352057696E646F77732220786D704D4D3A496E7374616E636549443D22786D702E6969643A4642463631453933344233343131453542423646';
wwv_flow_api.g_varchar2_table(7) := '3833454636363444334536312220786D704D4D3A446F63756D656E7449443D22786D702E6469643A4642463631453934344233343131453542423646383345463636344433453631223E203C786D704D4D3A4465726976656446726F6D2073745265663A';
wwv_flow_api.g_varchar2_table(8) := '696E7374616E636549443D22786D702E6969643A4642463631453931344233343131453542423646383345463636344433453631222073745265663A646F63756D656E7449443D22786D702E6469643A4642463631453932344233343131453542423646';
wwv_flow_api.g_varchar2_table(9) := '383345463636344433453631222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E79B503AF0000016E4944415478DA62FCFFFF3F033501';
wwv_flow_api.g_varchar2_table(10) := '130395010B8C61BDDA0C5D8E17889D80D81188F580981188AF02F13E28FE80ACF868E8295403D1803F10B703B1269AB803106703F12D20AE03E295C478B918883760310C19A801F10A20AE2564600810F79010644D409C88CB401120EE25D2A0A9407C19';
wwv_flow_api.g_varchar2_table(11) := 'CAEE0662316C0682C24D8E08C3EA81380788DD81F839100B03712A462C03810B11868122A219CAF600627E5822C1E6423D24F61520AE06E26F48625548862503F13C20E682F2E5B0B9900D4A7F06623F20BE0FC417A01AA7439311086440F90C58F4A2B8';
wwv_flow_api.g_varchar2_table(12) := 'F03E9406D99A05656F036263206EC4631803342C310C3C00A59981B804883BA0FCA7040C63408A7114033702F177247E3910F701B116D4B069380CFB0BC4F3B11908CAA793D1141702F125A8CB187118380788CFE2CA29A064B1154D8C194F323A00CDAA';
wwv_flow_api.g_varchar2_table(13) := '38B3DE4F68F69B49449A9C0F4D0D5FB1165F48E00734CCD60071381083CA3551A897DF00F11968C1B0139B2D8C83BEC406083000811A462E4C6EB4FF0000000049454E44AE426082';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 99532124934978557 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 100691937586019569 + wwv_flow_api.g_id_offset
 ,p_file_name => 'validation_success.png'
 ,p_mime_type => 'image/png'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
set define on
prompt  ...done
