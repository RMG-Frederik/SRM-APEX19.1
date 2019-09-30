set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.4.00.12'
,p_default_workspace_id=>1234567890
,p_default_application_id=>101
,p_default_owner=>'KELVIN'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/item_type/kalc_apex_range_slider
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(93701575287045718783)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'KALC.APEX.RANGE.SLIDER'
,p_display_name=>'KALC Range Slider'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#PLUGIN_FILES#kalcRangeSlider-min.js'
,p_css_file_urls=>'#PLUGIN_FILES#iThing.css'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'FUNCTION kalc_range_slider_render (',
'    p_item                IN apex_plugin.t_page_item,',
'    p_plugin              IN apex_plugin.t_plugin,',
'    p_value               IN VARCHAR2,',
'    p_is_readonly         IN BOOLEAN,',
'    p_is_printer_friendly IN BOOLEAN )',
'  RETURN apex_plugin.t_page_item_render_result',
'IS',
'  -- Version 1.1 - make slider width 100% (solves visual issues when screen width/container are small - e.g. on mobile phones)',
'  l_slider_id        VARCHAR2(271)  := UPPER(p_item.name)||''_kalcRangeSlider'';',
'  l_month_labels     VARCHAR2(2000) := '''';',
'  l_ora_months       VARCHAR2(2000) := '''';',
'  -- Plugin Attribute Values',
'  l_type                apex_application_page_items.attribute_01%TYPE := p_item.attribute_01; -- Type of slider',
'  l_date_format         apex_application_page_items.attribute_02%TYPE := p_item.attribute_02; -- Date Format',
'  l_range_min           apex_application_page_items.attribute_03%TYPE := p_item.attribute_03; -- Range Minimum',
'  l_range_max           apex_application_page_items.attribute_04%TYPE := p_item.attribute_04; -- Range Maximum',
'  l_step                apex_application_page_items.attribute_05%TYPE := p_item.attribute_05; -- Range Step for Integer Sliders',
'  l_format_integer      apex_application_page_items.attribute_06%TYPE := p_item.attribute_06; -- Format the Integer Y/N  v1.2',
'  l_thousand_separator  VARCHAR2(1)                                   := '','';                 -- NLS thousand separator  v1.2',
'  l_date_step           apex_application_page_items.attribute_07%TYPE := p_item.attribute_07; -- Date Range Step',
'  l_week_startday       apex_application_page_items.attribute_08%TYPE := p_item.attribute_08; -- Week start day',
'  l_min_page_item       apex_application_page_items.attribute_09%TYPE := p_item.attribute_09; -- Min Value Page Item',
'  l_max_page_item       apex_application_page_items.attribute_10%TYPE := p_item.attribute_10; -- Max Value Page Item',
'  l_ruler               apex_application_page_items.attribute_11%TYPE := p_item.attribute_11; -- Include a Ruler?',
'  l_major_scale         apex_application_page_items.attribute_12%TYPE := p_item.attribute_12; -- Major scale ticks',
'  l_minor_scale         apex_application_page_items.attribute_13%TYPE := p_item.attribute_13; -- Minor scale ticks',
'  l_exclude_min_width   apex_application_page_items.attribute_15%TYPE := p_item.attribute_15; -- Exclude Minimum Width  v1.2',
'  l_left_val            NUMBER;',
'  l_right_val           NUMBER;',
'  l_int_major_scale     NUMBER;',
'  l_int_minor_scale     NUMBER;',
'  l_no_of_steps         NUMBER := 0;   --v1.1',
'  l_right_pad           NUMBER := 35;  --v1.1 Slider container padding value (ensures right label is visible)',
'BEGIN',
'  -- Debug this item if running in debug mode',
'  IF apex_application.g_debug THEN',
'    apex_plugin_util.debug_page_item( p_plugin              => p_plugin,',
'                                      p_page_item           => p_item,',
'                                      p_value               => p_value,',
'                                      p_is_readonly         => p_is_readonly,',
'                                      p_is_printer_friendly => p_is_printer_friendly );',
'  END IF;',
'  -- Get NLS thousand separator',
'  BEGIN',
'    SELECT SUBSTR(value,2)',
'    INTO   l_thousand_separator',
'    FROM   nls_session_parameters',
'    WHERE  parameter = ''NLS_NUMERIC_CHARACTERS'';',
'  EXCEPTION',
'    WHEN no_data_found THEN',
'      l_thousand_separator := '','';',
'  END;',
'  -- Create a div element to turn into the slider',
'  sys.htp.p( ''<div id="''||l_slider_id||''"></div>'' );',
'  --',
'  -- Ruler or not? Add correct javascript',
'  IF l_ruler = ''Y'' THEN',
'    apex_javascript.add_library( p_name => ''jQAllRangeSliders-withRuler-min'', p_directory => p_plugin.file_prefix, p_version => NULL );',
'  ELSE',
'    apex_javascript.add_library( p_name => ''jQAllRangeSliders-min'', p_directory => p_plugin.file_prefix, p_version => NULL );',
'  END IF;',
'  --',
'  -- Position the label against the slider rather than at the top of the containing div',
'  apex_css.add( p_css => ''#''||UPPER(p_item.name)||''_CONTAINER {display: flex; align-items: flex-end;}'');',
'  apex_css.add( p_css => ''#''||UPPER(p_item.name)||''_LABEL {padding-bottom:5px;}'');',
'  --',
'  -- Add some margin to the sliders for when both user min and max are very close to the slider range min or max',
'  -- Also set the min width of the slider container to the number of "steps" in the slider plus the margin - so at least 1 pixel per slider step - v1.1',
'  IF l_type = ''DATE'' THEN',
'    l_no_of_steps := TO_DATE(l_range_max, l_date_format)-TO_DATE(l_range_min, l_date_format)+1;',
'    IF l_date_format = ''DD-MON-YYYY'' THEN',
'      IF l_exclude_min_width = ''N'' THEN',
'        l_no_of_steps := l_no_of_steps + 130;',
'        apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: ''||l_no_of_steps||''px; margin: 0px 65px;}'');',
'      ELSE',
'        apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: 131px; margin: 0px 65px;}'');',
'      END IF;',
'      -- v1.1 Pad the right of the slider container to keep labels visible',
'      l_right_pad := l_right_pad + 65;',
'      apex_css.add( p_css => ''#''||UPPER(p_item.name)||''_CONTAINER > div.t-Form-inputContainer {padding-right: ''||l_right_pad||''px;}'');',
'    ELSE',
'      IF l_exclude_min_width = ''N'' THEN',
'        l_no_of_steps := l_no_of_steps + 90;',
'        apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: ''||l_no_of_steps||''px; margin: 0px 45px;}'');',
'      ELSE',
'        apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: 91px; margin: 0px 45px;}'');',
'      END IF;',
'      -- v1.1 Pad the right of the slider container to keep labels visible',
'      l_right_pad := l_right_pad + 45;',
'      apex_css.add( p_css => ''#''||UPPER(p_item.name)||''_CONTAINER > div.t-Form-inputContainer {padding-right: ''||l_right_pad||''px;}'');',
'    END IF;',
'  ELSE',
'    l_no_of_steps := TRUNC(TRUNC(TO_NUMBER(l_range_max))-TRUNC(TO_NUMBER(l_range_min))/NVL(l_step,1))+1+30;',
'    IF l_exclude_min_width = ''N'' THEN',
'      apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: ''||l_no_of_steps||''px; margin: 0px 15px;}'');',
'    ELSE',
'      apex_css.add( p_css => ''#''||l_slider_id||'' {width: 100%; min-width: 31px; margin: 0px 15px;}'');',
'    END IF;',
'    -- v1.1 Pad the right of the slider container to keep labels visible',
'    l_right_pad := l_right_pad + 10;',
'    apex_css.add( p_css => ''#''||UPPER(p_item.name)||''_CONTAINER > div.t-Form-inputContainer {padding-right: ''||l_right_pad||''px;}'');',
'  END IF;',
'  --',
'  -- Set month labels based on the current NLS SESSION language',
'  IF  l_type = ''DATE'' THEN',
'    FOR i IN 1..12 LOOP',
'      l_month_labels := l_month_labels||TO_CHAR(TO_DATE(''01''||LPAD(TO_CHAR(i),2,''0'')||''2016'',''DDMMYYYY''),''fmMon'')||'','';',
'      l_ora_months   := l_ora_months||TO_CHAR(TO_DATE(''01''||LPAD(TO_CHAR(i),2,''0'')||''2016'',''DDMMYYYY''),''MON'')||'','';',
'    END LOOP;',
'    l_month_labels := TRIM('','' FROM l_month_labels);',
'    l_ora_months   := TRIM('','' FROM l_ora_months);',
'  END IF;',
'  --',
'  apex_javascript.add_onload_code(',
'    p_code =>',
'      ''kalc_range_slider_start(''||',
'        apex_javascript.add_value(l_slider_id, TRUE) ||',
'        apex_javascript.add_value(l_type, TRUE) ||',
'        apex_javascript.add_value(l_date_format, TRUE) ||',
'        apex_javascript.add_value(l_month_labels, TRUE) ||',
'        apex_javascript.add_value(l_ora_months, TRUE) ||',
'        CASE',
'          WHEN l_type = ''INTEGER'' THEN apex_javascript.add_value(TRUNC(TO_NUMBER(l_range_min)), TRUE)',
'          WHEN l_type = ''DATE''    THEN apex_javascript.add_value(TO_DATE(l_range_min, l_date_format), TRUE)',
'        END ||',
'        CASE',
'          WHEN l_type = ''INTEGER'' THEN apex_javascript.add_value(TRUNC(TO_NUMBER(l_range_max)), TRUE)',
'          WHEN l_type = ''DATE''    THEN apex_javascript.add_value(TO_DATE(l_range_max, l_date_format), TRUE)',
'        END ||',
'        CASE',
'          WHEN l_type = ''INTEGER'' THEN apex_javascript.add_value(TRUNC(TO_NUMBER(l_step)), TRUE)',
'          WHEN l_type = ''DATE''    THEN apex_javascript.add_value(l_date_step, TRUE)',
'        END ||',
'        apex_javascript.add_value(l_week_startday, TRUE) ||',
'        apex_javascript.add_value(l_format_integer, TRUE) ||',
'        apex_javascript.add_value(l_thousand_separator, TRUE) ||',
'        apex_javascript.add_value(l_min_page_item, TRUE) ||',
'        apex_javascript.add_value(l_max_page_item, TRUE) ||',
'        apex_javascript.add_value(l_ruler, TRUE) ||',
'        CASE',
'          WHEN l_type = ''INTEGER'' THEN apex_javascript.add_value(TRUNC(TO_NUMBER(l_major_scale)), TRUE)',
'          WHEN l_type = ''DATE''    THEN apex_javascript.add_value(l_major_scale, TRUE)',
'        END ||',
'        CASE',
'          WHEN l_type = ''INTEGER'' THEN apex_javascript.add_value(TRUNC(TO_NUMBER(l_minor_scale)), FALSE)',
'          WHEN l_type = ''DATE''    THEN apex_javascript.add_value(l_minor_scale, FALSE)',
'        END ||',
'      '');'',',
'    p_key => l_slider_id',
'  );',
'  --',
'  RETURN NULL;',
'END kalc_range_slider_render;'))
,p_render_function=>'kalc_range_slider_render'
,p_standard_attributes=>'VISIBLE:SESSION_STATE:READONLY:QUICKPICK:WIDTH:HEIGHT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Displays a Range Slider - Options are Integer or Date range sliders<br />',
'Requires at a minimum, two page items that will be updated when the slider values are changed by the end user<br />',
'Only available for Desktop themes'))
,p_version_identifier=>'1.2'
,p_about_url=>'https://github.com/kalconsultancyltd/kalc-range-slider'
,p_files_version=>177
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701628837664014255)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Slider Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'INTEGER'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Select the data type that the slider will show<br />',
'Version 1 supports INTEGER or DATE range sliders'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701629122875015989)
,p_plugin_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_display_sequence=>10
,p_display_value=>'Integer'
,p_return_value=>'INTEGER'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701629981002017317)
,p_plugin_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_display_sequence=>30
,p_display_value=>'Date'
,p_return_value=>'DATE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701813245304420423)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Date Format'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'DD-MM-YYYY'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'DATE'
,p_lov_type=>'STATIC'
,p_examples=>'When the NLS language is FRENCH and DD-MON-YYYY is selected, month 04 will give a month label of "Avr." but the value will be stored as "AVR. " (including the space)'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Select the date format used by the Date Range Slider<br />',
'<br />',
'Notes for date format DD-MON-YYYY<br />',
'"Month" labels will automatically use format <b>fmMON</b> when you select DD-MON-YYYY<br />',
'The values will still be updated using <b>MON</b><br />',
'This helps visually when using a non english language e.g. FRENCH<br />'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701822281481516881)
,p_plugin_attribute_id=>wwv_flow_api.id(93701813245304420423)
,p_display_sequence=>10
,p_display_value=>'DD-MM-YYYY'
,p_return_value=>'DD-MM-YYYY'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701822673254518573)
,p_plugin_attribute_id=>wwv_flow_api.id(93701813245304420423)
,p_display_sequence=>20
,p_display_value=>'DD-MON-YYYY'
,p_return_value=>'DD-MON-YYYY'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701634439286540214)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Range Min'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Integer Slider:<br />',
'0<br />',
'100<br />',
'54321<br />',
'&PXX_INT_SLIDER_RANGE_MIN.<br />',
'<br />',
'Date Slider:<br />',
'10-01-1980<br />',
'01-12-2015<br />',
'01-JAN-2000<br />',
'&PXX_DATE_SLIDER_RANGE_MIN.'))
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'The minimum value that the range slider will have. This value must be less than the Range Maximum value<br />',
'You must specify values appropriate to the slider type<br />',
'You can use application or page item substitutions to make this dynamic on page start e.g. <b>&Pxx_MY_RANGE_START.</b><br />',
'<br />',
'If you have used a substitution, ensure that the substituted value is appropriate<br />',
'If using a Date range slider ensure that the date format of the substitution is the same as selected'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701634730496542570)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Range Max'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Integer Slider:<br />',
'0<br />',
'100<br />',
'54321<br />',
'&PXX_INT_SLIDER_RANGE_MAX.<br />',
'<br />',
'Date Slider:<br />',
'10-01-1980<br />',
'01-12-2015<br />',
'01-JAN-2000<br />',
'&PXX_DATE_SLIDER_RANGE_MAX.'))
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'The maximum value that the range slider will have. This value mut be greater than the Range Minimum value<br />',
'You must specify values appropriate to the slider type<br />',
'You can use substitutions to make this dynamic on page start e.g. <b>&Pxx_MY_RANGE_END.</b><br />',
'<br />',
'If you have used a substitution, ensure that the substituted value is appropriate<br />',
'If using a Date range slider ensure that the date format of the substitution is the same as selected'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701635087580552372)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Range Step'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'INTEGER'
,p_help_text=>'Define the Step value for the Integer slider values (defaults to 1)'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701728948150535825)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Format Integer'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'INTEGER'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Format the integer with NLS thousand seperators?<br />',
'<br />',
'For use with numbers greater than 999<br />',
'Example: 1234567<br />',
'If set to Y then the left and right handle will show the number as 1,234,567 rather than 1234567<br />',
'<br />',
'Note: The scale labels will also be formatted in this manner (999G999G999G999G999) - the database NLS thousand separator will used'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701698472050364152)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Date Range Step'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'days'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'DATE'
,p_lov_type=>'STATIC'
,p_help_text=>'Select an appropriate date range slider step'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701793332846440803)
,p_plugin_attribute_id=>wwv_flow_api.id(93701698472050364152)
,p_display_sequence=>10
,p_display_value=>'Days'
,p_return_value=>'days'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701699173942368197)
,p_plugin_attribute_id=>wwv_flow_api.id(93701698472050364152)
,p_display_sequence=>20
,p_display_value=>'Months'
,p_return_value=>'months'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701699525017368964)
,p_plugin_attribute_id=>wwv_flow_api.id(93701698472050364152)
,p_display_sequence=>30
,p_display_value=>'Weeks'
,p_return_value=>'weeks'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701754892378098844)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Date Range Week Start Day'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'1'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701628837664014255)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'DATE'
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Defaults to Monday<br />',
'<br />',
'This value is used when a Date Range Step of <b>weeks</b> is selected<br />',
'Any date value for the left and right markers or when using a "scale" of week - markers are moved to this day of the week'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701755116265109381)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>10
,p_display_value=>'Sunday'
,p_return_value=>'0'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701755587109109887)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>20
,p_display_value=>'Monday'
,p_return_value=>'1'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701755993344110445)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>30
,p_display_value=>'Tuesday'
,p_return_value=>'2'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701756393532111086)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>40
,p_display_value=>'Wednesday'
,p_return_value=>'3'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701756778956111605)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>50
,p_display_value=>'Thursday'
,p_return_value=>'4'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701757190405112248)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>60
,p_display_value=>'Friday'
,p_return_value=>'5'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(93701757508488113420)
,p_plugin_attribute_id=>wwv_flow_api.id(93701754892378098844)
,p_display_sequence=>70
,p_display_value=>'Saturday'
,p_return_value=>'6'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701645432896754748)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Min Value Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'The page item to hold the value of the left hand "minimum" marker of the range slider<br />',
'<br />',
'If using a Date range slider ensure that the date format of the page item is the same as the plugin selected date format'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701645763407757333)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Max Value Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'The page item to hold the value of the right hand edge of the range slider<br />',
'<br />',
'If using a Date range slider ensure that the date format of the page item is the same as the plugin selected date format'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701643239737659744)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Include Ruler'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Select Yes/No to include a visible ruler in the slider bar<br />',
'Integer Range sliders can have a Major scale or a Major and a Minor scale<br />',
'Date Range sliders only currently support a Major scale'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701705869011441386)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Major Scale'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701643239737659744)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Enter an approprate value for the major scale<br />',
'<br />',
'For Integer Range sliders - enter an integer value',
'<br />',
'For a Date Range slider, valid values are: <b>month</b>, <b>week</b> or <b>day</b><br />',
'Month labels will be of "fmMon" oracle format regardless of the plugin selected date format'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(93701706177750443030)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Minor Scale'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(93701643239737659744)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Enter an approprate value for the minor scale<br />',
'<br />',
'For Integer sliders - enter an integer value. The minor scale must be smaller than the major scale',
'<br />',
'Note: A minor scale is not (currently) implemented for a Date Range Slider and any value placed here will be ignored'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1698230387966596)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Exclude Min WIdth'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'By default, a minimum width is defined for the slider that represents a single pixel per "step"<br />',
'This ensures that all values within the range are selectable via the UI<br />',
'This option allows you to exclude this minimum width where you have a very large range - be aware that not all values will be selectable through the UI'))
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2166756E6374696F6E28652C74297B6B616C635F72616E67655F736C696465725F73746172743D66756E6374696F6E28612C6E2C722C732C692C6F2C752C6C2C672C702C632C642C442C662C682C6D297B737769746368286E297B636173652244415445';
wwv_flow_api.g_varchar2_table(2) := '223A76617220493D6E657720446174652C783D6E657720446174652C593D732E73706C697428222C22292C4D3D617065782E6974656D2864292E67657456616C756528292C623D617065782E6974656D2844292E67657456616C756528292C773D706172';
wwv_flow_api.g_varchar2_table(3) := '7365496E74284D2E737562737472696E6728302C3229292C6B3D7061727365496E7428622E737562737472696E6728302C3229293B7377697463682872297B636173652244442D4D4F4E2D59595959223A6C656674446174654D6F6E74683D592E696E64';
wwv_flow_api.g_varchar2_table(4) := '65784F66284D2E737562737472696E6728332C34292E746F55707065724361736528292B4D2E737562737472696E6728342C4D2E696E6465784F6628222D222C3329292E746F4C6F776572436173652829292C6C65667444617465596561723D70617273';
wwv_flow_api.g_varchar2_table(5) := '65496E74284D2E736C696365284D2E696E6465784F6628222D222C33292B3129292C7269676874446174654D6F6E74683D592E696E6465784F6628622E737562737472696E6728332C34292E746F55707065724361736528292B622E737562737472696E';
wwv_flow_api.g_varchar2_table(6) := '6728342C622E696E6465784F6628222D222C3329292E746F4C6F776572436173652829292C726967687444617465596561723D7061727365496E7428622E736C69636528622E696E6465784F6628222D222C33292B3129293B627265616B3B6465666175';
wwv_flow_api.g_varchar2_table(7) := '6C743A6C656674446174654D6F6E74683D7061727365496E74284D2E737562737472696E6728332C3529292D312C6C65667444617465596561723D7061727365496E74284D2E736C696365283629292C7269676874446174654D6F6E74683D7061727365';
wwv_flow_api.g_varchar2_table(8) := '496E7428622E737562737472696E6728332C3529292D312C726967687444617465596561723D7061727365496E7428622E736C696365283629297D76617220763D6E65772044617465286C65667444617465596561722C6C656674446174654D6F6E7468';
wwv_flow_api.g_varchar2_table(9) := '2C77292C533D6E6577204461746528726967687444617465596561722C7269676874446174654D6F6E74682C6B293B6966286C213D742973776974636828493D6F2C783D752C6C297B63617365226D6F6E746873223A492E736574446174652831292C78';
wwv_flow_api.g_varchar2_table(10) := '2E7365744D6F6E746828752E6765744D6F6E746828292B31292C782E736574446174652831293B627265616B3B63617365227765656B73223A492E73657444617465286F2E6765744461746528292B28672D6F2E676574446179282929292C782E736574';
wwv_flow_api.g_varchar2_table(11) := '4461746528752E6765744461746528292B28672D752E67657444617928292B3729297D656C736520493D6F2C783D753B73776974636828225922213D667C7C683D3D747C7C2264617922213D682626226D6F6E746822213D682626227765656B22213D68';
wwv_flow_api.g_varchar2_table(12) := '3F65282223222B61292E6461746552616E6765536C69646572287B626F756E64733A7B6D696E3A492C6D61783A787D2C64656661756C7456616C7565733A7B6D696E3A762C6D61783A537D2C666F726D61747465723A66756E6374696F6E2865297B7661';
wwv_flow_api.g_varchar2_table(13) := '7220742C612C6E3D732E73706C697428222C22292C693D22222B652E67657446756C6C5965617228293B73776974636828743D652E6765744461746528293C31303F2230222B652E6765744461746528293A22222B652E6765744461746528292C613D65';
wwv_flow_api.g_varchar2_table(14) := '2E6765744D6F6E746828293C393F2230222B28652E6765744D6F6E746828292B31293A22222B28652E6765744D6F6E746828292B31292C72297B636173652244442D4D4F4E2D59595959223A72657475726E20742B222D222B6E5B7061727365496E7428';
wwv_flow_api.g_varchar2_table(15) := '61292D315D2B222D222B693B64656661756C743A72657475726E20742B222D222B612B222D222B697D7D7D293A65282223222B61292E6461746552616E6765536C69646572287B626F756E64733A7B6D696E3A492C6D61783A787D2C64656661756C7456';
wwv_flow_api.g_varchar2_table(16) := '616C7565733A7B6D696E3A762C6D61783A537D2C7363616C65733A5B7B66697273743A66756E6374696F6E2865297B76617220743D6E657720446174652865293B73776974636828742E736574486F75727328302C302C302C30292C68297B6361736522';
wwv_flow_api.g_varchar2_table(17) := '6D6F6E7468223A742E736574446174652831293B627265616B3B63617365227765656B223A742E7365744461746528742E6765744461746528292B28672D742E676574446179282929297D72657475726E20747D2C656E643A66756E6374696F6E286529';
wwv_flow_api.g_varchar2_table(18) := '7B72657475726E20657D2C6E6578743A66756E6374696F6E2865297B76617220743D6E657720446174652865293B73776974636828742E736574486F75727328302C302C302C30292C68297B6361736522646179223A742E7365744461746528742E6765';
wwv_flow_api.g_varchar2_table(19) := '744461746528292B31293B627265616B3B63617365226D6F6E7468223A742E7365744D6F6E746828742E6765744D6F6E746828292B31292C742E736574446174652831293B627265616B3B63617365227765656B223A742E7365744461746528742E6765';
wwv_flow_api.g_varchar2_table(20) := '744461746528292B37297D72657475726E20747D2C6C6162656C3A66756E6374696F6E2865297B76617220742C613D6E657720446174652865293B7377697463682868297B6361736522646179223A743D612E6765744461746528293C31303F2230222B';
wwv_flow_api.g_varchar2_table(21) := '612E6765744461746528293A22222B612E6765744461746528293B627265616B3B63617365226D6F6E7468223A743D595B612E6765744D6F6E746828295D3B627265616B3B63617365227765656B223A743D612E6765744461746528293C31303F223022';
wwv_flow_api.g_varchar2_table(22) := '2B612E6765744461746528293A22222B612E6765744461746528297D72657475726E20747D7D5D2C666F726D61747465723A66756E6374696F6E2865297B76617220742C612C6E3D732E73706C697428222C22292C693D22222B652E67657446756C6C59';
wwv_flow_api.g_varchar2_table(23) := '65617228293B73776974636828743D652E6765744461746528293C31303F2230222B652E6765744461746528293A22222B652E6765744461746528292C613D652E6765744D6F6E746828293C393F2230222B28652E6765744D6F6E746828292B31293A22';
wwv_flow_api.g_varchar2_table(24) := '222B28652E6765744D6F6E746828292B31292C72297B636173652244442D4D4F4E2D59595959223A72657475726E20742B222D222B6E5B7061727365496E742861292D315D2B222D222B693B64656661756C743A72657475726E20742B222D222B612B22';
wwv_flow_api.g_varchar2_table(25) := '2D222B697D7D7D292C6C297B636173652264617973223A65282223222B61292E6461746552616E6765536C6964657228226F7074696F6E222C2273746570222C7B646179733A317D293B627265616B3B63617365226D6F6E746873223A65282223222B61';
wwv_flow_api.g_varchar2_table(26) := '292E6461746552616E6765536C6964657228226F7074696F6E222C2273746570222C7B6D6F6E7468733A317D293B627265616B3B63617365227765656B73223A65282223222B61292E6461746552616E6765536C6964657228226F7074696F6E222C2273';
wwv_flow_api.g_varchar2_table(27) := '746570222C7B7765656B733A317D297D65282223222B61292E706172656E7428292E706172656E7428292E6F6E2822726573697A65222C66756E6374696F6E28297B65282223222B61292E6461746552616E6765536C696465722822726573697A652229';
wwv_flow_api.g_varchar2_table(28) := '7D292C65282223745F427574746F6E5F6E6176436F6E74726F6C2229262665282223745F427574746F6E5F6E6176436F6E74726F6C22292E6F6E2822636C69636B222C66756E6374696F6E28297B73657454696D656F75742866756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(29) := '65282223222B61292E6461746552616E6765536C696465722822726573697A6522297D2C323030297D292C65282223222B61292E62696E6428227573657256616C7565734368616E676564222C66756E6374696F6E28652C74297B76617220612C6E2C73';
wwv_flow_api.g_varchar2_table(30) := '2C6F2C753D692E73706C697428222C22292C6C3D742E76616C7565732E6D696E2C673D22222B6C2E67657446756C6C5965617228293B613D6C2E6765744461746528293C31303F2230222B6C2E6765744461746528293A22222B6C2E6765744461746528';
wwv_flow_api.g_varchar2_table(31) := '292C6E3D6C2E6765744D6F6E746828293C393F2230222B286C2E6765744D6F6E746828292B31293A22222B286C2E6765744D6F6E746828292B31293B76617220703D742E76616C7565732E6D61782C633D22222B702E67657446756C6C5965617228293B';
wwv_flow_api.g_varchar2_table(32) := '73776974636828733D702E6765744461746528293C31303F2230222B702E6765744461746528293A22222B702E6765744461746528292C6F3D702E6765744D6F6E746828293C393F2230222B28702E6765744D6F6E746828292B31293A22222B28702E67';
wwv_flow_api.g_varchar2_table(33) := '65744D6F6E746828292B31292C72297B636173652244442D4D4F4E2D59595959223A617065782E6974656D2864292E73657456616C756528612B222D222B755B7061727365496E74286E292D315D2E746F55707065724361736528292B222D222B67292C';
wwv_flow_api.g_varchar2_table(34) := '617065782E6974656D2844292E73657456616C756528732B222D222B755B7061727365496E74286F292D315D2E746F55707065724361736528292B222D222B63293B627265616B3B64656661756C743A617065782E6974656D2864292E73657456616C75';
wwv_flow_api.g_varchar2_table(35) := '6528612B222D222B6E2B222D222B67292C617065782E6974656D2844292E73657456616C756528732B222D222B6F2B222D222B63297D7D293B627265616B3B6361736522494E5445474552223A76617220563D7061727365496E7428617065782E697465';
wwv_flow_api.g_varchar2_table(36) := '6D2864292E67657456616C75652829293B56213D7426264E614E213D567C7C28563D7061727365496E74286F29293B766172204E3D7061727365496E7428617065782E6974656D2844292E67657456616C75652829293B4E213D7426264E614E213D4E7C';
wwv_flow_api.g_varchar2_table(37) := '7C284E3D7061727365496E74287529292C2259223D3D663F68213D7426264E614E213D7061727365496E7428682926266D213D7426264E614E213D7061727365496E74286D293F65282223222B61292E72616E6765536C69646572287B626F756E64733A';
wwv_flow_api.g_varchar2_table(38) := '7B6D696E3A7061727365496E74286F292C6D61783A7061727365496E742875297D2C64656661756C7456616C7565733A7B6D696E3A562C6D61783A4E7D2C7363616C65733A5B7B66697273743A66756E6374696F6E2865297B72657475726E20657D2C6E';
wwv_flow_api.g_varchar2_table(39) := '6578743A66756E6374696F6E2865297B72657475726E20652B7061727365496E742868297D2C73746F703A66756E6374696F6E2865297B72657475726E21317D2C6C6162656C3A66756E6374696F6E2865297B72657475726E2259223D3D703F652E746F';
wwv_flow_api.g_varchar2_table(40) := '537472696E6728292E7265706C616365282F5C42283F3D285C647B337D292B283F215C6429292F672C63293A657D7D2C7B66697273743A66756E6374696F6E2865297B72657475726E20657D2C6E6578743A66756E6374696F6E2865297B72657475726E';
wwv_flow_api.g_varchar2_table(41) := '2065257061727365496E742868293D3D3D7061727365496E742868292D313F652B287061727365496E74286D292B31293A652B7061727365496E74286D297D2C73746F703A66756E6374696F6E2865297B72657475726E21317D2C6C6162656C3A66756E';
wwv_flow_api.g_varchar2_table(42) := '6374696F6E28297B72657475726E206E756C6C7D7D5D2C666F726D61747465723A66756E6374696F6E2865297B72657475726E2259223D3D703F4D6174682E726F756E642865292E746F537472696E6728292E7265706C616365282F5C42283F3D285C64';
wwv_flow_api.g_varchar2_table(43) := '7B337D292B283F215C6429292F672C63293A657D7D293A68213D7426264E614E213D7061727365496E74286829262665282223222B61292E72616E6765536C69646572287B626F756E64733A7B6D696E3A7061727365496E74286F292C6D61783A706172';
wwv_flow_api.g_varchar2_table(44) := '7365496E742875297D2C64656661756C7456616C7565733A7B6D696E3A562C6D61783A4E7D2C7363616C65733A5B7B66697273743A66756E6374696F6E2865297B72657475726E20657D2C6E6578743A66756E6374696F6E2865297B72657475726E2065';
wwv_flow_api.g_varchar2_table(45) := '2B7061727365496E742868297D2C73746F703A66756E6374696F6E2865297B72657475726E21317D2C6C6162656C3A66756E6374696F6E2865297B72657475726E2259223D3D703F652E746F537472696E6728292E7265706C616365282F5C42283F3D28';
wwv_flow_api.g_varchar2_table(46) := '5C647B337D292B283F215C6429292F672C63293A657D7D5D2C666F726D61747465723A66756E6374696F6E2865297B72657475726E2259223D3D703F4D6174682E726F756E642865292E746F537472696E6728292E7265706C616365282F5C42283F3D28';
wwv_flow_api.g_varchar2_table(47) := '5C647B337D292B283F215C6429292F672C63293A657D7D293A65282223222B61292E72616E6765536C69646572287B626F756E64733A7B6D696E3A7061727365496E74286F292C6D61783A7061727365496E742875297D2C64656661756C7456616C7565';
wwv_flow_api.g_varchar2_table(48) := '733A7B6D696E3A562C6D61783A4E7D7D292C6C26262222213D6C262665282223222B61292E72616E6765536C6964657228226F7074696F6E222C2273746570222C7061727365496E74286C29292C65282223222B61292E706172656E7428292E70617265';
wwv_flow_api.g_varchar2_table(49) := '6E7428292E6F6E2822726573697A65222C66756E6374696F6E28297B65282223222B61292E72616E6765536C696465722822726573697A6522297D292C65282223745F427574746F6E5F6E6176436F6E74726F6C2229262665282223745F427574746F6E';
wwv_flow_api.g_varchar2_table(50) := '5F6E6176436F6E74726F6C22292E6F6E2822636C69636B222C66756E6374696F6E28297B73657454696D656F75742866756E6374696F6E28297B65282223222B61292E72616E6765536C696465722822726573697A6522297D2C323030297D292C652822';
wwv_flow_api.g_varchar2_table(51) := '23222B61292E62696E6428227573657256616C7565734368616E676564222C66756E6374696F6E28652C74297B617065782E6974656D2864292E73657456616C7565287061727365496E74284D6174682E726F756E6428742E76616C7565732E6D696E29';
wwv_flow_api.g_varchar2_table(52) := '29292C617065782E6974656D2844292E73657456616C7565287061727365496E74284D6174682E726F756E6428742E76616C7565732E6D61782929297D297D7D7D28617065782E6A5175657279293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1717741514023226)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'kalcRangeSlider-min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A21206A5152616E6765536C6964657220352E372E32202D20323031362D30312D3138202D20436F7079726967687420284329204775696C6C61756D652047617574726561752032303132202D204D495420616E642047504C7633206C6963656E7365';
wwv_flow_api.g_varchar2_table(2) := '732E2A2F2166756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C696465724D6F757365546F756368222C612E75692E6D6F7573652C7B656E61626C65643A21302C5F6D6F757365496E69';
wwv_flow_api.g_varchar2_table(3) := '743A66756E6374696F6E28297B76617220623D746869733B612E75692E6D6F7573652E70726F746F747970652E5F6D6F757365496E69742E6170706C792874686973292C746869732E5F6D6F757365446F776E4576656E743D21312C746869732E656C65';
wwv_flow_api.g_varchar2_table(4) := '6D656E742E62696E642822746F75636873746172742E222B746869732E7769646765744E616D652C66756E6374696F6E2861297B72657475726E20622E5F746F75636853746172742861297D297D2C5F6D6F75736544657374726F793A66756E6374696F';
wwv_flow_api.g_varchar2_table(5) := '6E28297B6128646F63756D656E74292E756E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F7563684D6F766544656C6567617465292E756E62696E642822746F756368656E642E222B74686973';
wwv_flow_api.g_varchar2_table(6) := '2E7769646765744E616D652C746869732E5F746F756368456E6444656C6567617465292C612E75692E6D6F7573652E70726F746F747970652E5F6D6F75736544657374726F792E6170706C792874686973297D2C656E61626C653A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(7) := '297B746869732E656E61626C65643D21307D2C64697361626C653A66756E6374696F6E28297B746869732E656E61626C65643D21317D2C64657374726F793A66756E6374696F6E28297B746869732E5F6D6F75736544657374726F7928292C612E75692E';
wwv_flow_api.g_varchar2_table(8) := '6D6F7573652E70726F746F747970652E64657374726F792E6170706C792874686973292C746869732E5F6D6F757365496E69743D6E756C6C7D2C5F746F75636853746172743A66756E6374696F6E2862297B69662821746869732E656E61626C65642972';
wwv_flow_api.g_varchar2_table(9) := '657475726E21313B622E77686963683D312C622E70726576656E7444656661756C7428292C746869732E5F66696C6C546F7563684576656E742862293B76617220633D746869732C643D746869732E5F6D6F757365446F776E4576656E743B746869732E';
wwv_flow_api.g_varchar2_table(10) := '5F6D6F757365446F776E2862292C64213D3D746869732E5F6D6F757365446F776E4576656E74262628746869732E5F746F756368456E6444656C65676174653D66756E6374696F6E2861297B632E5F746F756368456E642861297D2C746869732E5F746F';
wwv_flow_api.g_varchar2_table(11) := '7563684D6F766544656C65676174653D66756E6374696F6E2861297B632E5F746F7563684D6F76652861297D2C6128646F63756D656E74292E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F75';
wwv_flow_api.g_varchar2_table(12) := '63684D6F766544656C6567617465292E62696E642822746F756368656E642E222B746869732E7769646765744E616D652C746869732E5F746F756368456E6444656C656761746529297D2C5F6D6F757365446F776E3A66756E6374696F6E2862297B7265';
wwv_flow_api.g_varchar2_table(13) := '7475726E20746869732E656E61626C65643F612E75692E6D6F7573652E70726F746F747970652E5F6D6F757365446F776E2E6170706C7928746869732C5B625D293A21317D2C5F746F756368456E643A66756E6374696F6E2862297B746869732E5F6669';
wwv_flow_api.g_varchar2_table(14) := '6C6C546F7563684576656E742862292C746869732E5F6D6F75736555702862292C6128646F63756D656E74292E756E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F7563684D6F766544656C65';
wwv_flow_api.g_varchar2_table(15) := '67617465292E756E62696E642822746F756368656E642E222B746869732E7769646765744E616D652C746869732E5F746F756368456E6444656C6567617465292C746869732E5F6D6F757365446F776E4576656E743D21312C6128646F63756D656E7429';
wwv_flow_api.g_varchar2_table(16) := '2E7472696767657228226D6F757365757022297D2C5F746F7563684D6F76653A66756E6374696F6E2861297B72657475726E20612E70726576656E7444656661756C7428292C746869732E5F66696C6C546F7563684576656E742861292C746869732E5F';
wwv_flow_api.g_varchar2_table(17) := '6D6F7573654D6F76652861297D2C5F66696C6C546F7563684576656E743A66756E6374696F6E2861297B76617220623B623D22756E646566696E6564223D3D747970656F6620612E746172676574546F7563686573262622756E646566696E6564223D3D';
wwv_flow_api.g_varchar2_table(18) := '747970656F6620612E6368616E676564546F75636865733F612E6F726967696E616C4576656E742E746172676574546F75636865735B305D7C7C612E6F726967696E616C4576656E742E6368616E676564546F75636865735B305D3A612E746172676574';
wwv_flow_api.g_varchar2_table(19) := '546F75636865735B305D7C7C612E6368616E676564546F75636865735B305D2C612E70616765583D622E70616765582C612E70616765593D622E70616765592C612E77686963683D317D7D297D286A5175657279292C66756E6374696F6E28612C62297B';
wwv_flow_api.g_varchar2_table(20) := '2275736520737472696374223B612E776964676574282275692E72616E6765536C69646572447261676761626C65222C612E75692E72616E6765536C696465724D6F757365546F7563682C7B63616368653A6E756C6C2C6F7074696F6E733A7B636F6E74';
wwv_flow_api.g_varchar2_table(21) := '61696E6D656E743A6E756C6C7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465724D6F757365546F7563682E70726F746F747970652E5F6372656174652E6170706C792874686973292C73657454696D656F7574';
wwv_flow_api.g_varchar2_table(22) := '28612E70726F787928746869732E5F696E6974456C656D656E7449664E6F7444657374726F7965642C74686973292C3130297D2C64657374726F793A66756E6374696F6E28297B746869732E63616368653D6E756C6C2C612E75692E72616E6765536C69';
wwv_flow_api.g_varchar2_table(23) := '6465724D6F757365546F7563682E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F696E6974456C656D656E7449664E6F7444657374726F7965643A66756E6374696F6E28297B746869732E5F6D6F757365496E69742626';
wwv_flow_api.g_varchar2_table(24) := '746869732E5F696E6974456C656D656E7428297D2C5F696E6974456C656D656E743A66756E6374696F6E28297B746869732E5F6D6F757365496E697428292C746869732E5F636163686528297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C';
wwv_flow_api.g_varchar2_table(25) := '63297B22636F6E7461696E6D656E74223D3D3D622626286E756C6C3D3D3D637C7C303D3D3D612863292E6C656E6774683F746869732E6F7074696F6E732E636F6E7461696E6D656E743D6E756C6C3A746869732E6F7074696F6E732E636F6E7461696E6D';
wwv_flow_api.g_varchar2_table(26) := '656E743D61286329297D2C5F6D6F75736553746172743A66756E6374696F6E2861297B72657475726E20746869732E5F636163686528292C746869732E63616368652E636C69636B3D7B6C6566743A612E70616765582C746F703A612E70616765597D2C';
wwv_flow_api.g_varchar2_table(27) := '746869732E63616368652E696E697469616C4F66667365743D746869732E656C656D656E742E6F666673657428292C746869732E5F747269676765724D6F7573654576656E7428226D6F757365737461727422292C21307D2C5F6D6F757365447261673A';
wwv_flow_api.g_varchar2_table(28) := '66756E6374696F6E2861297B76617220623D612E70616765582D746869732E63616368652E636C69636B2E6C6566743B72657475726E20623D746869732E5F636F6E73747261696E74506F736974696F6E28622B746869732E63616368652E696E697469';
wwv_flow_api.g_varchar2_table(29) := '616C4F66667365742E6C656674292C746869732E5F6170706C79506F736974696F6E2862292C746869732E5F747269676765724D6F7573654576656E742822736C696465724472616722292C21317D2C5F6D6F75736553746F703A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(30) := '297B746869732E5F747269676765724D6F7573654576656E74282273746F7022297D2C5F636F6E73747261696E74506F736974696F6E3A66756E6374696F6E2861297B72657475726E2030213D3D746869732E656C656D656E742E706172656E7428292E';
wwv_flow_api.g_varchar2_table(31) := '6C656E67746826266E756C6C213D3D746869732E63616368652E706172656E742E6F6666736574262628613D4D6174682E6D696E28612C746869732E63616368652E706172656E742E6F66667365742E6C6566742B746869732E63616368652E70617265';
wwv_flow_api.g_varchar2_table(32) := '6E742E77696474682D746869732E63616368652E77696474682E6F75746572292C613D4D6174682E6D617828612C746869732E63616368652E706172656E742E6F66667365742E6C65667429292C617D2C5F6170706C79506F736974696F6E3A66756E63';
wwv_flow_api.g_varchar2_table(33) := '74696F6E2861297B746869732E5F636163686549664E656365737361727928293B76617220623D7B746F703A746869732E63616368652E6F66667365742E746F702C6C6566743A617D3B746869732E656C656D656E742E6F6666736574287B6C6566743A';
wwv_flow_api.g_varchar2_table(34) := '617D292C746869732E63616368652E6F66667365743D627D2C5F636163686549664E65636573736172793A66756E6374696F6E28297B6E756C6C3D3D3D746869732E63616368652626746869732E5F636163686528297D2C5F63616368653A66756E6374';
wwv_flow_api.g_varchar2_table(35) := '696F6E28297B746869732E63616368653D7B7D2C746869732E5F63616368654D617267696E7328292C746869732E5F6361636865506172656E7428292C746869732E5F636163686544696D656E73696F6E7328292C746869732E63616368652E6F666673';
wwv_flow_api.g_varchar2_table(36) := '65743D746869732E656C656D656E742E6F666673657428297D2C5F63616368654D617267696E733A66756E6374696F6E28297B746869732E63616368652E6D617267696E3D7B6C6566743A746869732E5F7061727365506978656C7328746869732E656C';
wwv_flow_api.g_varchar2_table(37) := '656D656E742C226D617267696E4C65667422292C72696768743A746869732E5F7061727365506978656C7328746869732E656C656D656E742C226D617267696E526967687422292C746F703A746869732E5F7061727365506978656C7328746869732E65';
wwv_flow_api.g_varchar2_table(38) := '6C656D656E742C226D617267696E546F7022292C626F74746F6D3A746869732E5F7061727365506978656C7328746869732E656C656D656E742C226D617267696E426F74746F6D22297D7D2C5F6361636865506172656E743A66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(39) := '6966286E756C6C213D3D746869732E6F7074696F6E732E706172656E74297B76617220613D746869732E656C656D656E742E706172656E7428293B746869732E63616368652E706172656E743D7B6F66667365743A612E6F666673657428292C77696474';
wwv_flow_api.g_varchar2_table(40) := '683A612E776964746828297D7D656C736520746869732E63616368652E706172656E743D6E756C6C7D2C5F636163686544696D656E73696F6E733A66756E6374696F6E28297B746869732E63616368652E77696474683D7B6F757465723A746869732E65';
wwv_flow_api.g_varchar2_table(41) := '6C656D656E742E6F75746572576964746828292C696E6E65723A746869732E656C656D656E742E776964746828297D7D2C5F7061727365506978656C733A66756E6374696F6E28612C62297B72657475726E207061727365496E7428612E637373286229';
wwv_flow_api.g_varchar2_table(42) := '2C3130297C7C307D2C5F747269676765724D6F7573654576656E743A66756E6374696F6E2861297B76617220623D746869732E5F707265706172654576656E744461746128293B746869732E656C656D656E742E7472696767657228612C62297D2C5F70';
wwv_flow_api.g_varchar2_table(43) := '7265706172654576656E74446174613A66756E6374696F6E28297B72657475726E7B656C656D656E743A746869732E656C656D656E742C6F66667365743A746869732E63616368652E6F66667365747C7C6E756C6C7D7D7D297D286A5175657279292C66';
wwv_flow_api.g_varchar2_table(44) := '756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C69646572222C7B6F7074696F6E733A7B626F756E64733A7B6D696E3A302C6D61783A3130307D2C64656661756C7456616C7565733A7B';
wwv_flow_api.g_varchar2_table(45) := '6D696E3A32302C6D61783A35307D2C776865656C4D6F64653A6E756C6C2C776865656C53706565643A342C6172726F77733A21302C76616C75654C6162656C733A2273686F77222C666F726D61747465723A6E756C6C2C6475726174696F6E496E3A302C';
wwv_flow_api.g_varchar2_table(46) := '6475726174696F6E4F75743A3430302C64656C61794F75743A3230302C72616E67653A7B6D696E3A21312C6D61783A21317D2C737465703A21312C7363616C65733A21312C656E61626C65643A21302C73796D6D6574726963506F736974696F6E6E696E';
wwv_flow_api.g_varchar2_table(47) := '673A21317D2C5F76616C7565733A6E756C6C2C5F76616C7565734368616E6765643A21312C5F696E697469616C697A65643A21312C6261723A6E756C6C2C6C65667448616E646C653A6E756C6C2C726967687448616E646C653A6E756C6C2C696E6E6572';
wwv_flow_api.g_varchar2_table(48) := '4261723A6E756C6C2C636F6E7461696E65723A6E756C6C2C6172726F77733A6E756C6C2C6C6162656C733A6E756C6C2C6368616E67696E673A7B6D696E3A21312C6D61783A21317D2C6368616E6765643A7B6D696E3A21312C6D61783A21317D2C72756C';
wwv_flow_api.g_varchar2_table(49) := '65723A6E756C6C2C5F6372656174653A66756E6374696F6E28297B746869732E5F73657444656661756C7456616C75657328292C746869732E6C6162656C733D7B6C6566743A6E756C6C2C72696768743A6E756C6C2C6C656674446973706C617965643A';
wwv_flow_api.g_varchar2_table(50) := '21302C7269676874446973706C617965643A21307D2C746869732E6172726F77733D7B6C6566743A6E756C6C2C72696768743A6E756C6C7D2C746869732E6368616E67696E673D7B6D696E3A21312C6D61783A21317D2C746869732E6368616E6765643D';
wwv_flow_api.g_varchar2_table(51) := '7B6D696E3A21312C6D61783A21317D2C746869732E5F637265617465456C656D656E747328292C746869732E5F62696E64526573697A6528292C73657454696D656F757428612E70726F787928746869732E726573697A652C74686973292C31292C7365';
wwv_flow_api.g_varchar2_table(52) := '7454696D656F757428612E70726F787928746869732E5F696E697456616C7565732C74686973292C31297D2C5F73657444656661756C7456616C7565733A66756E6374696F6E28297B746869732E5F76616C7565733D7B6D696E3A746869732E6F707469';
wwv_flow_api.g_varchar2_table(53) := '6F6E732E64656661756C7456616C7565732E6D696E2C6D61783A746869732E6F7074696F6E732E64656661756C7456616C7565732E6D61787D7D2C5F62696E64526573697A653A66756E6374696F6E28297B76617220623D746869733B746869732E5F72';
wwv_flow_api.g_varchar2_table(54) := '6573697A6550726F78793D66756E6374696F6E2861297B622E726573697A652861297D2C612877696E646F77292E726573697A6528746869732E5F726573697A6550726F7879297D2C5F696E697457696474683A66756E6374696F6E28297B746869732E';
wwv_flow_api.g_varchar2_table(55) := '636F6E7461696E65722E63737328227769647468222C746869732E656C656D656E742E776964746828292D746869732E636F6E7461696E65722E6F757465725769647468282130292B746869732E636F6E7461696E65722E77696474682829292C746869';
wwv_flow_api.g_varchar2_table(56) := '732E696E6E65724261722E63737328227769647468222C746869732E636F6E7461696E65722E776964746828292D746869732E696E6E65724261722E6F757465725769647468282130292B746869732E696E6E65724261722E77696474682829297D2C5F';
wwv_flow_api.g_varchar2_table(57) := '696E697456616C7565733A66756E6374696F6E28297B746869732E5F696E697469616C697A65643D21302C746869732E76616C75657328746869732E5F76616C7565732E6D696E2C746869732E5F76616C7565732E6D6178297D2C5F7365744F7074696F';
wwv_flow_api.g_varchar2_table(58) := '6E3A66756E6374696F6E28612C62297B746869732E5F736574576865656C4F7074696F6E28612C62292C746869732E5F7365744172726F77734F7074696F6E28612C62292C746869732E5F7365744C6162656C734F7074696F6E28612C62292C74686973';
wwv_flow_api.g_varchar2_table(59) := '2E5F7365744C6162656C734475726174696F6E7328612C62292C746869732E5F736574466F726D61747465724F7074696F6E28612C62292C746869732E5F736574426F756E64734F7074696F6E28612C62292C746869732E5F73657452616E67654F7074';
wwv_flow_api.g_varchar2_table(60) := '696F6E28612C62292C746869732E5F736574537465704F7074696F6E28612C62292C746869732E5F7365745363616C65734F7074696F6E28612C62292C746869732E5F736574456E61626C65644F7074696F6E28612C62292C746869732E5F736574506F';
wwv_flow_api.g_varchar2_table(61) := '736974696F6E6E696E674F7074696F6E28612C62297D2C5F76616C696450726F70657274793A66756E6374696F6E28612C622C63297B72657475726E206E756C6C3D3D3D617C7C22756E646566696E6564223D3D747970656F6620615B625D3F633A615B';
wwv_flow_api.g_varchar2_table(62) := '625D7D2C5F736574537465704F7074696F6E3A66756E6374696F6E28612C62297B2273746570223D3D3D61262628746869732E6F7074696F6E732E737465703D622C746869732E5F6C65667448616E646C6528226F7074696F6E222C2273746570222C62';
wwv_flow_api.g_varchar2_table(63) := '292C746869732E5F726967687448616E646C6528226F7074696F6E222C2273746570222C62292C746869732E5F6368616E67656428213029297D2C5F7365745363616C65734F7074696F6E3A66756E6374696F6E28612C62297B227363616C6573223D3D';
wwv_flow_api.g_varchar2_table(64) := '3D61262628623D3D3D21317C7C6E756C6C3D3D3D623F28746869732E6F7074696F6E732E7363616C65733D21312C746869732E5F64657374726F7952756C65722829293A6220696E7374616E63656F66204172726179262628746869732E6F7074696F6E';
wwv_flow_api.g_varchar2_table(65) := '732E7363616C65733D622C746869732E5F75706461746552756C6572282929297D2C5F73657452616E67654F7074696F6E3A66756E6374696F6E28612C62297B2272616E6765223D3D3D61262628746869732E5F62617228226F7074696F6E222C227261';
wwv_flow_api.g_varchar2_table(66) := '6E6765222C62292C746869732E6F7074696F6E732E72616E67653D746869732E5F62617228226F7074696F6E222C2272616E676522292C746869732E5F6368616E67656428213029297D2C5F736574426F756E64734F7074696F6E3A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(67) := '28612C62297B22626F756E6473223D3D3D61262622756E646566696E656422213D747970656F6620622E6D696E262622756E646566696E656422213D747970656F6620622E6D61782626746869732E626F756E647328622E6D696E2C622E6D6178297D2C';
wwv_flow_api.g_varchar2_table(68) := '5F736574576865656C4F7074696F6E3A66756E6374696F6E28612C62297B2822776865656C4D6F6465223D3D3D617C7C22776865656C5370656564223D3D3D6129262628746869732E5F62617228226F7074696F6E222C612C62292C746869732E6F7074';
wwv_flow_api.g_varchar2_table(69) := '696F6E735B615D3D746869732E5F62617228226F7074696F6E222C6129297D2C5F7365744C6162656C734F7074696F6E3A66756E6374696F6E28612C62297B6966282276616C75654C6162656C73223D3D3D61297B696628226869646522213D3D622626';
wwv_flow_api.g_varchar2_table(70) := '2273686F7722213D3D622626226368616E676522213D3D622972657475726E3B746869732E6F7074696F6E732E76616C75654C6162656C733D622C226869646522213D3D623F28746869732E5F6372656174654C6162656C7328292C746869732E5F6C65';
wwv_flow_api.g_varchar2_table(71) := '66744C6162656C282275706461746522292C746869732E5F72696768744C6162656C28227570646174652229293A746869732E5F64657374726F794C6162656C7328297D7D2C5F736574466F726D61747465724F7074696F6E3A66756E6374696F6E2861';
wwv_flow_api.g_varchar2_table(72) := '2C62297B22666F726D6174746572223D3D3D6126266E756C6C213D3D6226262266756E6374696F6E223D3D747970656F6620622626226869646522213D3D746869732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C';
wwv_flow_api.g_varchar2_table(73) := '6162656C28226F7074696F6E222C22666F726D6174746572222C62292C746869732E6F7074696F6E732E666F726D61747465723D746869732E5F72696768744C6162656C28226F7074696F6E222C22666F726D6174746572222C6229297D2C5F73657441';
wwv_flow_api.g_varchar2_table(74) := '72726F77734F7074696F6E3A66756E6374696F6E28612C62297B226172726F777322213D3D617C7C62213D3D2130262662213D3D21317C7C623D3D3D746869732E6F7074696F6E732E6172726F77737C7C28623D3D3D21303F28746869732E656C656D65';
wwv_flow_api.g_varchar2_table(75) := '6E742E72656D6F7665436C617373282275692D72616E6765536C696465722D6E6F4172726F7722292E616464436C617373282275692D72616E6765536C696465722D776974684172726F777322292C746869732E6172726F77732E6C6566742E63737328';
wwv_flow_api.g_varchar2_table(76) := '22646973706C6179222C22626C6F636B22292C746869732E6172726F77732E72696768742E6373732822646973706C6179222C22626C6F636B22292C746869732E6F7074696F6E732E6172726F77733D2130293A623D3D3D2131262628746869732E656C';
wwv_flow_api.g_varchar2_table(77) := '656D656E742E616464436C617373282275692D72616E6765536C696465722D6E6F4172726F7722292E72656D6F7665436C617373282275692D72616E6765536C696465722D776974684172726F777322292C746869732E6172726F77732E6C6566742E63';
wwv_flow_api.g_varchar2_table(78) := '73732822646973706C6179222C226E6F6E6522292C746869732E6172726F77732E72696768742E6373732822646973706C6179222C226E6F6E6522292C746869732E6F7074696F6E732E6172726F77733D2131292C746869732E5F696E69745769647468';
wwv_flow_api.g_varchar2_table(79) := '2829297D2C5F7365744C6162656C734475726174696F6E733A66756E6374696F6E28612C62297B696628226475726174696F6E496E223D3D3D617C7C226475726174696F6E4F7574223D3D3D617C7C2264656C61794F7574223D3D3D61297B6966287061';
wwv_flow_api.g_varchar2_table(80) := '727365496E7428622C313029213D3D622972657475726E3B6E756C6C213D3D746869732E6C6162656C732E6C6566742626746869732E5F6C6566744C6162656C28226F7074696F6E222C612C62292C6E756C6C213D3D746869732E6C6162656C732E7269';
wwv_flow_api.g_varchar2_table(81) := '6768742626746869732E5F72696768744C6162656C28226F7074696F6E222C612C62292C746869732E6F7074696F6E735B615D3D627D7D2C5F736574456E61626C65644F7074696F6E3A66756E6374696F6E28612C62297B22656E61626C6564223D3D3D';
wwv_flow_api.g_varchar2_table(82) := '612626746869732E746F67676C652862297D2C5F736574506F736974696F6E6E696E674F7074696F6E3A66756E6374696F6E28612C62297B2273796D6D6574726963506F736974696F6E6E696E67223D3D3D61262628746869732E5F726967687448616E';
wwv_flow_api.g_varchar2_table(83) := '646C6528226F7074696F6E222C612C62292C746869732E6F7074696F6E735B615D3D746869732E5F6C65667448616E646C6528226F7074696F6E222C612C6229297D2C5F637265617465456C656D656E74733A66756E6374696F6E28297B226162736F6C';
wwv_flow_api.g_varchar2_table(84) := '75746522213D3D746869732E656C656D656E742E6373732822706F736974696F6E22292626746869732E656C656D656E742E6373732822706F736974696F6E222C2272656C617469766522292C746869732E656C656D656E742E616464436C6173732822';
wwv_flow_api.g_varchar2_table(85) := '75692D72616E6765536C6964657222292C746869732E636F6E7461696E65723D6128223C64697620636C6173733D2775692D72616E6765536C696465722D636F6E7461696E657227202F3E22292E6373732822706F736974696F6E222C226162736F6C75';
wwv_flow_api.g_varchar2_table(86) := '746522292E617070656E64546F28746869732E656C656D656E74292C746869732E696E6E65724261723D6128223C64697620636C6173733D2775692D72616E6765536C696465722D696E6E657242617227202F3E22292E6373732822706F736974696F6E';
wwv_flow_api.g_varchar2_table(87) := '222C226162736F6C75746522292E6373732822746F70222C30292E63737328226C656674222C30292C746869732E5F63726561746548616E646C657328292C746869732E5F63726561746542617228292C746869732E636F6E7461696E65722E70726570';
wwv_flow_api.g_varchar2_table(88) := '656E6428746869732E696E6E6572426172292C746869732E5F6372656174654172726F777328292C226869646522213D3D746869732E6F7074696F6E732E76616C75654C6162656C733F746869732E5F6372656174654C6162656C7328293A746869732E';
wwv_flow_api.g_varchar2_table(89) := '5F64657374726F794C6162656C7328292C746869732E5F75706461746552756C657228292C746869732E6F7074696F6E732E656E61626C65647C7C746869732E5F746F67676C6528746869732E6F7074696F6E732E656E61626C6564297D2C5F63726561';
wwv_flow_api.g_varchar2_table(90) := '746548616E646C653A66756E6374696F6E2862297B72657475726E206128223C646976202F3E22295B746869732E5F68616E646C655479706528295D2862292E62696E642822736C6964657244726167222C612E70726F787928746869732E5F6368616E';
wwv_flow_api.g_varchar2_table(91) := '67696E672C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6368616E6765642C7468697329297D2C5F63726561746548616E646C65733A66756E6374696F6E28297B746869732E6C65667448616E646C653D74686973';
wwv_flow_api.g_varchar2_table(92) := '2E5F63726561746548616E646C65287B69734C6566743A21302C626F756E64733A746869732E6F7074696F6E732E626F756E64732C76616C75653A746869732E5F76616C7565732E6D696E2C737465703A746869732E6F7074696F6E732E737465702C73';
wwv_flow_api.g_varchar2_table(93) := '796D6D6574726963506F736974696F6E6E696E673A746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E677D292E617070656E64546F28746869732E636F6E7461696E6572292C746869732E726967687448616E646C653D';
wwv_flow_api.g_varchar2_table(94) := '746869732E5F63726561746548616E646C65287B69734C6566743A21312C626F756E64733A746869732E6F7074696F6E732E626F756E64732C76616C75653A746869732E5F76616C7565732E6D61782C737465703A746869732E6F7074696F6E732E7374';
wwv_flow_api.g_varchar2_table(95) := '65702C73796D6D6574726963506F736974696F6E6E696E673A746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E677D292E617070656E64546F28746869732E636F6E7461696E6572297D2C5F6372656174654261723A66';
wwv_flow_api.g_varchar2_table(96) := '756E6374696F6E28297B746869732E6261723D6128223C646976202F3E22292E70726570656E64546F28746869732E636F6E7461696E6572292E62696E642822736C6964657244726167207363726F6C6C207A6F6F6D222C612E70726F78792874686973';
wwv_flow_api.g_varchar2_table(97) := '2E5F6368616E67696E672C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6368616E6765642C7468697329292C746869732E5F626172287B6C65667448616E646C653A746869732E6C65667448616E646C652C726967';
wwv_flow_api.g_varchar2_table(98) := '687448616E646C653A746869732E726967687448616E646C652C76616C7565733A7B6D696E3A746869732E5F76616C7565732E6D696E2C6D61783A746869732E5F76616C7565732E6D61787D2C747970653A746869732E5F68616E646C65547970652829';
wwv_flow_api.g_varchar2_table(99) := '2C72616E67653A746869732E6F7074696F6E732E72616E67652C776865656C4D6F64653A746869732E6F7074696F6E732E776865656C4D6F64652C776865656C53706565643A746869732E6F7074696F6E732E776865656C53706565647D292C74686973';
wwv_flow_api.g_varchar2_table(100) := '2E6F7074696F6E732E72616E67653D746869732E5F62617228226F7074696F6E222C2272616E676522292C746869732E6F7074696F6E732E776865656C4D6F64653D746869732E5F62617228226F7074696F6E222C22776865656C4D6F646522292C7468';
wwv_flow_api.g_varchar2_table(101) := '69732E6F7074696F6E732E776865656C53706565643D746869732E5F62617228226F7074696F6E222C22776865656C537065656422297D2C5F6372656174654172726F77733A66756E6374696F6E28297B746869732E6172726F77732E6C6566743D7468';
wwv_flow_api.g_varchar2_table(102) := '69732E5F6372656174654172726F7728226C65667422292C746869732E6172726F77732E72696768743D746869732E5F6372656174654172726F772822726967687422292C746869732E6F7074696F6E732E6172726F77733F746869732E656C656D656E';
wwv_flow_api.g_varchar2_table(103) := '742E616464436C617373282275692D72616E6765536C696465722D776974684172726F777322293A28746869732E6172726F77732E6C6566742E6373732822646973706C6179222C226E6F6E6522292C746869732E6172726F77732E72696768742E6373';
wwv_flow_api.g_varchar2_table(104) := '732822646973706C6179222C226E6F6E6522292C746869732E656C656D656E742E616464436C617373282275692D72616E6765536C696465722D6E6F4172726F772229297D2C5F6372656174654172726F773A66756E6374696F6E2862297B7661722063';
wwv_flow_api.g_varchar2_table(105) := '2C643D6128223C64697620636C6173733D2775692D72616E6765536C696465722D6172726F7727202F3E22292E617070656E6428223C64697620636C6173733D2775692D72616E6765536C696465722D6172726F772D696E6E657227202F3E22292E6164';
wwv_flow_api.g_varchar2_table(106) := '64436C617373282275692D72616E6765536C696465722D222B622B224172726F7722292E6373732822706F736974696F6E222C226162736F6C75746522292E63737328622C30292E617070656E64546F28746869732E656C656D656E74293B7265747572';
wwv_flow_api.g_varchar2_table(107) := '6E20633D227269676874223D3D3D623F612E70726F787928746869732E5F7363726F6C6C5269676874436C69636B2C74686973293A612E70726F787928746869732E5F7363726F6C6C4C656674436C69636B2C74686973292C642E62696E6428226D6F75';
wwv_flow_api.g_varchar2_table(108) := '7365646F776E20746F7563687374617274222C63292C647D2C5F70726F78793A66756E6374696F6E28612C622C63297B76617220643D41727261792E70726F746F747970652E736C6963652E63616C6C2863293B72657475726E20612626615B625D3F61';
wwv_flow_api.g_varchar2_table(109) := '5B625D2E6170706C7928612C64293A6E756C6C7D2C5F68616E646C65547970653A66756E6374696F6E28297B72657475726E2272616E6765536C6964657248616E646C65227D2C5F626172547970653A66756E6374696F6E28297B72657475726E227261';
wwv_flow_api.g_varchar2_table(110) := '6E6765536C69646572426172227D2C5F6261723A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6261722C746869732E5F6261725479706528292C617267756D656E7473297D2C5F6C6162656C547970653A6675';
wwv_flow_api.g_varchar2_table(111) := '6E6374696F6E28297B72657475726E2272616E6765536C696465724C6162656C227D2C5F6C6566744C6162656C3A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C6162656C732E6C6566742C746869732E5F6C';
wwv_flow_api.g_varchar2_table(112) := '6162656C5479706528292C617267756D656E7473297D2C5F72696768744C6162656C3A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C6162656C732E72696768742C746869732E5F6C6162656C547970652829';
wwv_flow_api.g_varchar2_table(113) := '2C617267756D656E7473297D2C5F6C65667448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C65667448616E646C652C746869732E5F68616E646C655479706528292C617267756D656E747329';
wwv_flow_api.g_varchar2_table(114) := '7D2C5F726967687448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E726967687448616E646C652C746869732E5F68616E646C655479706528292C617267756D656E7473297D2C5F67657456616C';
wwv_flow_api.g_varchar2_table(115) := '75653A66756E6374696F6E28612C62297B72657475726E20623D3D3D746869732E726967687448616E646C65262628612D3D622E6F7574657257696474682829292C612A28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F70';
wwv_flow_api.g_varchar2_table(116) := '74696F6E732E626F756E64732E6D696E292F28746869732E636F6E7461696E65722E696E6E6572576964746828292D622E6F75746572576964746828213029292B746869732E6F7074696F6E732E626F756E64732E6D696E7D2C5F747269676765723A66';
wwv_flow_api.g_varchar2_table(117) := '756E6374696F6E2861297B76617220623D746869733B73657454696D656F75742866756E6374696F6E28297B622E656C656D656E742E7472696767657228612C7B6C6162656C3A622E656C656D656E742C76616C7565733A622E76616C75657328297D29';
wwv_flow_api.g_varchar2_table(118) := '7D2C31297D2C5F6368616E67696E673A66756E6374696F6E28297B746869732E5F75706461746556616C7565732829262628746869732E5F74726967676572282276616C7565734368616E67696E6722292C746869732E5F76616C7565734368616E6765';
wwv_flow_api.g_varchar2_table(119) := '643D2130297D2C5F646561637469766174654C6162656C733A66756E6374696F6E28297B226368616E6765223D3D3D746869732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C6162656C28226F7074696F6E222C22';
wwv_flow_api.g_varchar2_table(120) := '73686F77222C226869646522292C746869732E5F72696768744C6162656C28226F7074696F6E222C2273686F77222C22686964652229297D2C5F726561637469766174654C6162656C733A66756E6374696F6E28297B226368616E6765223D3D3D746869';
wwv_flow_api.g_varchar2_table(121) := '732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C6162656C28226F7074696F6E222C2273686F77222C226368616E676522292C746869732E5F72696768744C6162656C28226F7074696F6E222C2273686F77222C22';
wwv_flow_api.g_varchar2_table(122) := '6368616E67652229297D2C5F6368616E6765643A66756E6374696F6E2861297B613D3D3D21302626746869732E5F646561637469766174654C6162656C7328292C28746869732E5F75706461746556616C75657328297C7C746869732E5F76616C756573';
wwv_flow_api.g_varchar2_table(123) := '4368616E67656429262628746869732E5F74726967676572282276616C7565734368616E67656422292C61213D3D21302626746869732E5F7472696767657228227573657256616C7565734368616E67656422292C746869732E5F76616C756573436861';
wwv_flow_api.g_varchar2_table(124) := '6E6765643D2131292C613D3D3D21302626746869732E5F726561637469766174654C6162656C7328297D2C5F75706461746556616C7565733A66756E6374696F6E28297B76617220613D746869732E5F6C65667448616E646C65282276616C756522292C';
wwv_flow_api.g_varchar2_table(125) := '623D746869732E5F726967687448616E646C65282276616C756522292C633D746869732E5F6D696E28612C62292C643D746869732E5F6D617828612C62292C653D63213D3D746869732E5F76616C7565732E6D696E7C7C64213D3D746869732E5F76616C';
wwv_flow_api.g_varchar2_table(126) := '7565732E6D61783B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E5F6D696E28612C62292C746869732E5F76616C7565732E6D61783D746869732E5F6D617828612C62292C657D2C5F6D696E3A66756E6374696F6E28612C6229';
wwv_flow_api.g_varchar2_table(127) := '7B72657475726E204D6174682E6D696E28612C62297D2C5F6D61783A66756E6374696F6E28612C62297B72657475726E204D6174682E6D617828612C62297D2C5F6372656174654C6162656C3A66756E6374696F6E28622C63297B76617220643B726574';
wwv_flow_api.g_varchar2_table(128) := '75726E206E756C6C3D3D3D623F28643D746869732E5F6765744C6162656C436F6E7374727563746F72506172616D657465727328622C63292C623D6128223C646976202F3E22292E617070656E64546F28746869732E656C656D656E74295B746869732E';
wwv_flow_api.g_varchar2_table(129) := '5F6C6162656C5479706528295D286429293A28643D746869732E5F6765744C6162656C52656672657368506172616D657465727328622C63292C625B746869732E5F6C6162656C5479706528295D286429292C627D2C5F6765744C6162656C436F6E7374';
wwv_flow_api.g_varchar2_table(130) := '727563746F72506172616D65746572733A66756E6374696F6E28612C62297B72657475726E7B68616E646C653A622C68616E646C65547970653A746869732E5F68616E646C655479706528292C666F726D61747465723A746869732E5F676574466F726D';
wwv_flow_api.g_varchar2_table(131) := '617474657228292C73686F773A746869732E6F7074696F6E732E76616C75654C6162656C732C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A746869732E6F7074696F6E732E6475';
wwv_flow_api.g_varchar2_table(132) := '726174696F6E4F75742C64656C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D7D2C5F6765744C6162656C52656672657368506172616D65746572733A66756E6374696F6E28297B72657475726E7B666F726D61747465723A7468';
wwv_flow_api.g_varchar2_table(133) := '69732E5F676574466F726D617474657228292C73686F773A746869732E6F7074696F6E732E76616C75654C6162656C732C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A74686973';
wwv_flow_api.g_varchar2_table(134) := '2E6F7074696F6E732E6475726174696F6E4F75742C64656C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D7D2C5F676574466F726D61747465723A66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E66';
wwv_flow_api.g_varchar2_table(135) := '6F726D61747465723D3D3D21317C7C6E756C6C3D3D3D746869732E6F7074696F6E732E666F726D61747465723F746869732E5F64656661756C74466F726D61747465723A746869732E6F7074696F6E732E666F726D61747465727D2C5F64656661756C74';
wwv_flow_api.g_varchar2_table(136) := '466F726D61747465723A66756E6374696F6E2861297B72657475726E204D6174682E726F756E642861297D2C5F64657374726F794C6162656C3A66756E6374696F6E2861297B72657475726E206E756C6C213D3D61262628615B746869732E5F6C616265';
wwv_flow_api.g_varchar2_table(137) := '6C5479706528295D282264657374726F7922292C612E72656D6F766528292C613D6E756C6C292C617D2C5F6372656174654C6162656C733A66756E6374696F6E28297B746869732E6C6162656C732E6C6566743D746869732E5F6372656174654C616265';
wwv_flow_api.g_varchar2_table(138) := '6C28746869732E6C6162656C732E6C6566742C746869732E6C65667448616E646C65292C746869732E6C6162656C732E72696768743D746869732E5F6372656174654C6162656C28746869732E6C6162656C732E72696768742C746869732E7269676874';
wwv_flow_api.g_varchar2_table(139) := '48616E646C65292C746869732E5F6C6566744C6162656C282270616972222C746869732E6C6162656C732E7269676874297D2C5F64657374726F794C6162656C733A66756E6374696F6E28297B746869732E6C6162656C732E6C6566743D746869732E5F';
wwv_flow_api.g_varchar2_table(140) := '64657374726F794C6162656C28746869732E6C6162656C732E6C656674292C746869732E6C6162656C732E72696768743D746869732E5F64657374726F794C6162656C28746869732E6C6162656C732E7269676874297D2C5F73746570526174696F3A66';
wwv_flow_api.g_varchar2_table(141) := '756E6374696F6E28297B72657475726E20746869732E5F6C65667448616E646C65282273746570526174696F22297D2C5F7363726F6C6C5269676874436C69636B3A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E656E';
wwv_flow_api.g_varchar2_table(142) := '61626C65643F28612E70726576656E7444656661756C7428292C746869732E5F626172282273746172745363726F6C6C22292C746869732E5F62696E6453746F705363726F6C6C28292C766F696420746869732E5F636F6E74696E75655363726F6C6C69';
wwv_flow_api.g_varchar2_table(143) := '6E6728227363726F6C6C5269676874222C342A746869732E5F73746570526174696F28292C3129293A21317D2C5F636F6E74696E75655363726F6C6C696E673A66756E6374696F6E28612C622C632C64297B69662821746869732E6F7074696F6E732E65';
wwv_flow_api.g_varchar2_table(144) := '6E61626C65642972657475726E21313B746869732E5F62617228612C63292C643D647C7C352C642D2D3B76617220653D746869732C663D31362C673D4D6174682E6D617828312C342F746869732E5F73746570526174696F2829293B746869732E5F7363';
wwv_flow_api.g_varchar2_table(145) := '726F6C6C54696D656F75743D73657454696D656F75742866756E6374696F6E28297B303D3D3D64262628623E663F623D4D6174682E6D617828662C622F312E35293A633D4D6174682E6D696E28672C322A63292C643D35292C652E5F636F6E74696E7565';
wwv_flow_api.g_varchar2_table(146) := '5363726F6C6C696E6728612C622C632C64297D2C62297D2C5F7363726F6C6C4C656674436C69636B3A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E656E61626C65643F28612E70726576656E7444656661756C742829';
wwv_flow_api.g_varchar2_table(147) := '2C746869732E5F626172282273746172745363726F6C6C22292C746869732E5F62696E6453746F705363726F6C6C28292C766F696420746869732E5F636F6E74696E75655363726F6C6C696E6728227363726F6C6C4C656674222C342A746869732E5F73';
wwv_flow_api.g_varchar2_table(148) := '746570526174696F28292C3129293A21317D2C5F62696E6453746F705363726F6C6C3A66756E6374696F6E28297B76617220623D746869733B746869732E5F73746F705363726F6C6C48616E646C653D66756E6374696F6E2861297B612E70726576656E';
wwv_flow_api.g_varchar2_table(149) := '7444656661756C7428292C622E5F73746F705363726F6C6C28297D2C6128646F63756D656E74292E62696E6428226D6F757365757020746F756368656E64222C746869732E5F73746F705363726F6C6C48616E646C65297D2C5F73746F705363726F6C6C';
wwv_flow_api.g_varchar2_table(150) := '3A66756E6374696F6E28297B6128646F63756D656E74292E756E62696E6428226D6F757365757020746F756368656E64222C746869732E5F73746F705363726F6C6C48616E646C65292C746869732E5F73746F705363726F6C6C48616E646C653D6E756C';
wwv_flow_api.g_varchar2_table(151) := '6C2C746869732E5F626172282273746F705363726F6C6C22292C636C65617254696D656F757428746869732E5F7363726F6C6C54696D656F7574297D2C5F63726561746552756C65723A66756E6374696F6E28297B746869732E72756C65723D6128223C';
wwv_flow_api.g_varchar2_table(152) := '64697620636C6173733D2775692D72616E6765536C696465722D72756C657227202F3E22292E617070656E64546F28746869732E696E6E6572426172297D2C5F73657452756C6572506172616D65746572733A66756E6374696F6E28297B746869732E72';
wwv_flow_api.g_varchar2_table(153) := '756C65722E72756C6572287B6D696E3A746869732E6F7074696F6E732E626F756E64732E6D696E2C6D61783A746869732E6F7074696F6E732E626F756E64732E6D61782C7363616C65733A746869732E6F7074696F6E732E7363616C65737D297D2C5F64';
wwv_flow_api.g_varchar2_table(154) := '657374726F7952756C65723A66756E6374696F6E28297B6E756C6C213D3D746869732E72756C65722626612E666E2E72756C6572262628746869732E72756C65722E72756C6572282264657374726F7922292C746869732E72756C65722E72656D6F7665';
wwv_flow_api.g_varchar2_table(155) := '28292C746869732E72756C65723D6E756C6C297D2C5F75706461746552756C65723A66756E6374696F6E28297B746869732E5F64657374726F7952756C657228292C746869732E6F7074696F6E732E7363616C6573213D3D21312626612E666E2E72756C';
wwv_flow_api.g_varchar2_table(156) := '6572262628746869732E5F63726561746552756C657228292C746869732E5F73657452756C6572506172616D65746572732829297D2C76616C7565733A66756E6374696F6E28612C62297B76617220633B69662822756E646566696E656422213D747970';
wwv_flow_api.g_varchar2_table(157) := '656F662061262622756E646566696E656422213D747970656F662062297B69662821746869732E5F696E697469616C697A65642972657475726E20746869732E5F76616C7565732E6D696E3D612C746869732E5F76616C7565732E6D61783D622C746869';
wwv_flow_api.g_varchar2_table(158) := '732E5F76616C7565733B746869732E5F646561637469766174654C6162656C7328292C633D746869732E5F626172282276616C756573222C612C62292C746869732E5F6368616E676564282130292C746869732E5F726561637469766174654C6162656C';
wwv_flow_api.g_varchar2_table(159) := '7328297D656C736520633D746869732E5F626172282276616C756573222C612C62293B72657475726E20637D2C6D696E3A66756E6374696F6E2861297B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E76616C75657328612C74';
wwv_flow_api.g_varchar2_table(160) := '6869732E5F76616C7565732E6D6178292E6D696E2C746869732E5F76616C7565732E6D696E7D2C6D61783A66756E6374696F6E2861297B72657475726E20746869732E5F76616C7565732E6D61783D746869732E76616C75657328746869732E5F76616C';
wwv_flow_api.g_varchar2_table(161) := '7565732E6D696E2C61292E6D61782C746869732E5F76616C7565732E6D61787D2C626F756E64733A66756E6374696F6E28612C62297B72657475726E20746869732E5F697356616C696456616C75652861292626746869732E5F697356616C696456616C';
wwv_flow_api.g_varchar2_table(162) := '75652862292626623E61262628746869732E5F736574426F756E647328612C62292C746869732E5F75706461746552756C657228292C746869732E5F6368616E67656428213029292C746869732E6F7074696F6E732E626F756E64737D2C5F697356616C';
wwv_flow_api.g_varchar2_table(163) := '696456616C75653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F66206126267061727365466C6F61742861293D3D3D617D2C5F736574426F756E64733A66756E6374696F6E28612C62297B746869732E6F70';
wwv_flow_api.g_varchar2_table(164) := '74696F6E732E626F756E64733D7B6D696E3A612C6D61783A627D2C746869732E5F6C65667448616E646C6528226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473292C746869732E5F726967687448616E646C65';
wwv_flow_api.g_varchar2_table(165) := '28226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473292C746869732E5F62617228226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473297D2C7A6F6F6D496E3A66756E';
wwv_flow_api.g_varchar2_table(166) := '6374696F6E2861297B746869732E5F62617228227A6F6F6D496E222C61297D2C7A6F6F6D4F75743A66756E6374696F6E2861297B746869732E5F62617228227A6F6F6D4F7574222C61297D2C7363726F6C6C4C6566743A66756E6374696F6E2861297B74';
wwv_flow_api.g_varchar2_table(167) := '6869732E5F626172282273746172745363726F6C6C22292C746869732E5F62617228227363726F6C6C4C656674222C61292C746869732E5F626172282273746F705363726F6C6C22297D2C7363726F6C6C52696768743A66756E6374696F6E2861297B74';
wwv_flow_api.g_varchar2_table(168) := '6869732E5F626172282273746172745363726F6C6C22292C746869732E5F62617228227363726F6C6C5269676874222C61292C746869732E5F626172282273746F705363726F6C6C22297D2C726573697A653A66756E6374696F6E28297B746869732E63';
wwv_flow_api.g_varchar2_table(169) := '6F6E7461696E6572262628746869732E5F696E6974576964746828292C746869732E5F6C65667448616E646C65282275706461746522292C746869732E5F726967687448616E646C65282275706461746522292C746869732E5F62617228227570646174';
wwv_flow_api.g_varchar2_table(170) := '652229297D2C656E61626C653A66756E6374696F6E28297B746869732E746F67676C65282130297D2C64697361626C653A66756E6374696F6E28297B746869732E746F67676C65282131297D2C746F67676C653A66756E6374696F6E2861297B613D3D3D';
wwv_flow_api.g_varchar2_table(171) := '62262628613D21746869732E6F7074696F6E732E656E61626C6564292C746869732E6F7074696F6E732E656E61626C6564213D3D612626746869732E5F746F67676C652861297D2C5F746F67676C653A66756E6374696F6E2861297B746869732E6F7074';
wwv_flow_api.g_varchar2_table(172) := '696F6E732E656E61626C65643D612C746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D64697361626C6564222C2161293B76617220623D613F22656E61626C65223A2264697361626C65223B746869';
wwv_flow_api.g_varchar2_table(173) := '732E5F6261722862292C746869732E5F6C65667448616E646C652862292C746869732E5F726967687448616E646C652862292C746869732E5F6C6566744C6162656C2862292C746869732E5F72696768744C6162656C2862297D2C64657374726F793A66';
wwv_flow_api.g_varchar2_table(174) := '756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C617373282275692D72616E6765536C696465722D776974684172726F77732075692D72616E6765536C696465722D6E6F4172726F772075692D72616E6765536C696465722D';
wwv_flow_api.g_varchar2_table(175) := '64697361626C656422292C746869732E5F64657374726F795769646765747328292C746869732E5F64657374726F79456C656D656E747328292C746869732E656C656D656E742E72656D6F7665436C617373282275692D72616E6765536C696465722229';
wwv_flow_api.g_varchar2_table(176) := '2C746869732E6F7074696F6E733D6E756C6C2C612877696E646F77292E756E62696E642822726573697A65222C746869732E5F726573697A6550726F7879292C746869732E5F726573697A6550726F78793D6E756C6C2C746869732E5F62696E64526573';
wwv_flow_api.g_varchar2_table(177) := '697A653D6E756C6C2C612E5769646765742E70726F746F747970652E64657374726F792E6170706C7928746869732C617267756D656E7473297D2C5F64657374726F795769646765743A66756E6374696F6E2861297B746869735B225F222B615D282264';
wwv_flow_api.g_varchar2_table(178) := '657374726F7922292C746869735B615D2E72656D6F766528292C746869735B615D3D6E756C6C7D2C5F64657374726F79576964676574733A66756E6374696F6E28297B746869732E5F64657374726F79576964676574282262617222292C746869732E5F';
wwv_flow_api.g_varchar2_table(179) := '64657374726F7957696467657428226C65667448616E646C6522292C746869732E5F64657374726F795769646765742822726967687448616E646C6522292C746869732E5F64657374726F7952756C657228292C746869732E5F64657374726F794C6162';
wwv_flow_api.g_varchar2_table(180) := '656C7328297D2C5F64657374726F79456C656D656E74733A66756E6374696F6E28297B746869732E636F6E7461696E65722E72656D6F766528292C746869732E636F6E7461696E65723D6E756C6C2C746869732E696E6E65724261722E72656D6F766528';
wwv_flow_api.g_varchar2_table(181) := '292C746869732E696E6E65724261723D6E756C6C2C746869732E6172726F77732E6C6566742E72656D6F766528292C746869732E6172726F77732E72696768742E72656D6F766528292C746869732E6172726F77733D6E756C6C7D7D297D286A51756572';
wwv_flow_api.g_varchar2_table(182) := '79292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C6964657248616E646C65222C612E75692E72616E6765536C69646572447261676761626C652C7B63757272656E744D6F7665';
wwv_flow_api.g_varchar2_table(183) := '3A6E756C6C2C6D617267696E3A302C706172656E74456C656D656E743A6E756C6C2C6F7074696F6E733A7B69734C6566743A21302C626F756E64733A7B6D696E3A302C6D61783A3130307D2C72616E67653A21312C76616C75653A302C737465703A2131';
wwv_flow_api.g_varchar2_table(184) := '7D2C5F76616C75653A302C5F6C6566743A302C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E65';
wwv_flow_api.g_varchar2_table(185) := '6C656D656E742E6373732822706F736974696F6E222C226162736F6C75746522292E6373732822746F70222C30292E616464436C617373282275692D72616E6765536C696465722D68616E646C6522292E746F67676C65436C617373282275692D72616E';
wwv_flow_api.g_varchar2_table(186) := '6765536C696465722D6C65667448616E646C65222C746869732E6F7074696F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C696465722D726967687448616E646C65222C21746869732E6F7074696F6E732E69734C';
wwv_flow_api.g_varchar2_table(187) := '656674292C746869732E656C656D656E742E617070656E6428223C64697620636C6173733D2775692D72616E6765536C696465722D68616E646C652D696E6E657227202F3E22292C746869732E5F76616C75653D746869732E5F636F6E73747261696E74';
wwv_flow_api.g_varchar2_table(188) := '56616C756528746869732E6F7074696F6E732E76616C7565297D2C64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E656D70747928292C612E75692E72616E6765536C69646572447261676761626C652E70726F746F7479';
wwv_flow_api.g_varchar2_table(189) := '70652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B2269734C65667422213D3D627C7C63213D3D2130262663213D3D21317C7C633D3D3D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(190) := '66743F2273746570223D3D3D622626746869732E5F636865636B537465702863293F28746869732E6F7074696F6E732E737465703D632C746869732E7570646174652829293A22626F756E6473223D3D3D623F28746869732E6F7074696F6E732E626F75';
wwv_flow_api.g_varchar2_table(191) := '6E64733D632C746869732E7570646174652829293A2272616E6765223D3D3D622626746869732E5F636865636B52616E67652863293F28746869732E6F7074696F6E732E72616E67653D632C746869732E7570646174652829293A2273796D6D65747269';
wwv_flow_api.g_varchar2_table(192) := '63506F736974696F6E6E696E67223D3D3D62262628746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E673D633D3D3D21302C746869732E7570646174652829293A28746869732E6F7074696F6E732E69734C6566743D63';
wwv_flow_api.g_varchar2_table(193) := '2C746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D6C65667448616E646C65222C746869732E6F7074696F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C6964';
wwv_flow_api.g_varchar2_table(194) := '65722D726967687448616E646C65222C21746869732E6F7074696F6E732E69734C656674292C746869732E5F706F736974696F6E28746869732E5F76616C7565292C746869732E656C656D656E742E747269676765722822737769746368222C74686973';
wwv_flow_api.g_varchar2_table(195) := '2E6F7074696F6E732E69734C65667429292C612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D2C5F636865636B52616E67653A66756E63';
wwv_flow_api.g_varchar2_table(196) := '74696F6E2861297B72657475726E20613D3D3D21317C7C21746869732E5F697356616C696456616C756528612E6D696E29262621746869732E5F697356616C696456616C756528612E6D6178297D2C5F697356616C696456616C75653A66756E6374696F';
wwv_flow_api.g_varchar2_table(197) := '6E2861297B72657475726E22756E646566696E656422213D747970656F662061262661213D3D213126267061727365466C6F6174286129213D3D617D2C5F636865636B537465703A66756E6374696F6E2861297B72657475726E20613D3D3D21317C7C70';
wwv_flow_api.g_varchar2_table(198) := '61727365466C6F61742861293D3D3D617D2C5F696E6974456C656D656E743A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F696E6974456C656D656E742E6170706C7928746869';
wwv_flow_api.g_varchar2_table(199) := '73292C303D3D3D746869732E63616368652E706172656E742E77696474687C7C6E756C6C3D3D3D746869732E63616368652E706172656E742E77696474683F73657454696D656F757428612E70726F787928746869732E5F696E6974456C656D656E7449';
wwv_flow_api.g_varchar2_table(200) := '664E6F7444657374726F7965642C74686973292C353030293A28746869732E5F706F736974696F6E28746869732E5F76616C7565292C746869732E5F747269676765724D6F7573654576656E742822696E697469616C697A652229297D2C5F626F756E64';
wwv_flow_api.g_varchar2_table(201) := '733A66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E626F756E64737D2C5F63616368653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F63616368';
wwv_flow_api.g_varchar2_table(202) := '652E6170706C792874686973292C746869732E5F6361636865506172656E7428297D2C5F6361636865506172656E743A66756E6374696F6E28297B76617220613D746869732E656C656D656E742E706172656E7428293B746869732E63616368652E7061';
wwv_flow_api.g_varchar2_table(203) := '72656E743D7B656C656D656E743A612C6F66667365743A612E6F666673657428292C70616464696E673A7B6C6566743A746869732E5F7061727365506978656C7328612C2270616464696E674C65667422297D2C77696474683A612E776964746828297D';
wwv_flow_api.g_varchar2_table(204) := '7D2C5F706F736974696F6E3A66756E6374696F6E2861297B76617220623D746869732E5F676574506F736974696F6E466F7256616C75652861293B746869732E5F6170706C79506F736974696F6E2862297D2C5F636F6E73747261696E74506F73697469';
wwv_flow_api.g_varchar2_table(205) := '6F6E3A66756E6374696F6E2861297B76617220623D746869732E5F67657456616C7565466F72506F736974696F6E2861293B72657475726E20746869732E5F676574506F736974696F6E466F7256616C75652862297D2C5F6170706C79506F736974696F';
wwv_flow_api.g_varchar2_table(206) := '6E3A66756E6374696F6E2862297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6170706C79506F736974696F6E2E6170706C7928746869732C5B625D292C746869732E5F6C6566743D622C746869732E5F';
wwv_flow_api.g_varchar2_table(207) := '73657456616C756528746869732E5F67657456616C7565466F72506F736974696F6E286229292C746869732E5F747269676765724D6F7573654576656E7428226D6F76696E6722297D2C5F707265706172654576656E74446174613A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(208) := '28297B76617220623D612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F707265706172654576656E74446174612E6170706C792874686973293B72657475726E20622E76616C75653D746869732E5F76616C75';
wwv_flow_api.g_varchar2_table(209) := '652C627D2C5F73657456616C75653A66756E6374696F6E2861297B61213D3D746869732E5F76616C7565262628746869732E5F76616C75653D61297D2C5F636F6E73747261696E7456616C75653A66756E6374696F6E2861297B696628613D4D6174682E';
wwv_flow_api.g_varchar2_table(210) := '6D696E28612C746869732E5F626F756E647328292E6D6178292C613D4D6174682E6D617828612C746869732E5F626F756E647328292E6D696E292C613D746869732E5F726F756E642861292C746869732E6F7074696F6E732E72616E6765213D3D213129';
wwv_flow_api.g_varchar2_table(211) := '7B76617220623D746869732E6F7074696F6E732E72616E67652E6D696E7C7C21312C633D746869732E6F7074696F6E732E72616E67652E6D61787C7C21313B62213D3D2131262628613D4D6174682E6D617828612C746869732E5F726F756E6428622929';
wwv_flow_api.g_varchar2_table(212) := '292C63213D3D2131262628613D4D6174682E6D696E28612C746869732E5F726F756E6428632929292C613D4D6174682E6D696E28612C746869732E5F626F756E647328292E6D6178292C613D4D6174682E6D617828612C746869732E5F626F756E647328';
wwv_flow_api.g_varchar2_table(213) := '292E6D696E297D72657475726E20617D2C5F726F756E643A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E73746570213D3D21312626746869732E6F7074696F6E732E737465703E303F4D6174682E726F756E6428612F';
wwv_flow_api.g_varchar2_table(214) := '746869732E6F7074696F6E732E73746570292A746869732E6F7074696F6E732E737465703A617D2C5F676574506F736974696F6E466F7256616C75653A66756E6374696F6E2861297B69662821746869732E63616368657C7C21746869732E6361636865';
wwv_flow_api.g_varchar2_table(215) := '2E706172656E747C7C6E756C6C3D3D3D746869732E63616368652E706172656E742E6F66667365742972657475726E20303B613D746869732E5F636F6E73747261696E7456616C75652861293B76617220623D28612D746869732E6F7074696F6E732E62';
wwv_flow_api.g_varchar2_table(216) := '6F756E64732E6D696E292F28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F7074696F6E732E626F756E64732E6D696E292C633D746869732E63616368652E706172656E742E77696474682C643D746869732E63616368652E';
wwv_flow_api.g_varchar2_table(217) := '706172656E742E6F66667365742E6C6566742C653D746869732E6F7074696F6E732E69734C6566743F303A746869732E63616368652E77696474682E6F757465723B72657475726E20746869732E6F7074696F6E732E73796D6D6574726963506F736974';
wwv_flow_api.g_varchar2_table(218) := '696F6E6E696E673F622A28632D322A746869732E63616368652E77696474682E6F75746572292B642B653A622A632B642D657D2C5F67657456616C7565466F72506F736974696F6E3A66756E6374696F6E2861297B76617220623D746869732E5F676574';
wwv_flow_api.g_varchar2_table(219) := '52617756616C7565466F72506F736974696F6E416E64426F756E647328612C746869732E6F7074696F6E732E626F756E64732E6D696E2C746869732E6F7074696F6E732E626F756E64732E6D6178293B72657475726E20746869732E5F636F6E73747261';
wwv_flow_api.g_varchar2_table(220) := '696E7456616C75652862297D2C5F67657452617756616C7565466F72506F736974696F6E416E64426F756E64733A66756E6374696F6E28612C622C63297B76617220642C652C663D6E756C6C3D3D3D746869732E63616368652E706172656E742E6F6666';
wwv_flow_api.g_varchar2_table(221) := '7365743F303A746869732E63616368652E706172656E742E6F66667365742E6C6566743B72657475726E20746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E673F28612D3D746869732E6F7074696F6E732E69734C6566';
wwv_flow_api.g_varchar2_table(222) := '743F303A746869732E63616368652E77696474682E6F757465722C643D746869732E63616368652E706172656E742E77696474682D322A746869732E63616368652E77696474682E6F75746572293A28612B3D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(223) := '66743F303A746869732E63616368652E77696474682E6F757465722C643D746869732E63616368652E706172656E742E7769647468292C303D3D3D643F746869732E5F76616C75653A28653D28612D66292F642C652A28632D62292B62297D2C76616C75';
wwv_flow_api.g_varchar2_table(224) := '653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869732E5F636163686528292C613D746869732E5F636F6E73747261696E7456616C75652861292C746869732E5F706F736974696F6E28';
wwv_flow_api.g_varchar2_table(225) := '6129292C746869732E5F76616C75657D2C7570646174653A66756E6374696F6E28297B746869732E5F636163686528293B76617220613D746869732E5F636F6E73747261696E7456616C756528746869732E5F76616C7565292C623D746869732E5F6765';
wwv_flow_api.g_varchar2_table(226) := '74506F736974696F6E466F7256616C75652861293B61213D3D746869732E5F76616C75653F28746869732E5F747269676765724D6F7573654576656E7428227570646174696E6722292C746869732E5F706F736974696F6E2861292C746869732E5F7472';
wwv_flow_api.g_varchar2_table(227) := '69676765724D6F7573654576656E7428227570646174652229293A62213D3D746869732E63616368652E6F66667365742E6C656674262628746869732E5F747269676765724D6F7573654576656E7428227570646174696E6722292C746869732E5F706F';
wwv_flow_api.g_varchar2_table(228) := '736974696F6E2861292C746869732E5F747269676765724D6F7573654576656E7428227570646174652229297D2C706F736974696F6E3A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869';
wwv_flow_api.g_varchar2_table(229) := '732E5F636163686528292C613D746869732E5F636F6E73747261696E74506F736974696F6E2861292C746869732E5F6170706C79506F736974696F6E286129292C746869732E5F6C6566747D2C6164643A66756E6374696F6E28612C62297B7265747572';
wwv_flow_api.g_varchar2_table(230) := '6E20612B627D2C7375627374726163743A66756E6374696F6E28612C62297B72657475726E20612D627D2C73746570734265747765656E3A66756E6374696F6E28612C62297B72657475726E20746869732E6F7074696F6E732E737465703D3D3D21313F';
wwv_flow_api.g_varchar2_table(231) := '622D613A28622D61292F746869732E6F7074696F6E732E737465707D2C6D756C7469706C79537465703A66756E6374696F6E28612C62297B72657475726E20612A627D2C6D6F766552696768743A66756E6374696F6E2861297B76617220623B72657475';
wwv_flow_api.g_varchar2_table(232) := '726E20746869732E6F7074696F6E732E737465703D3D3D21313F28623D746869732E5F6C6566742C746869732E706F736974696F6E28746869732E5F6C6566742B61292C746869732E5F6C6566742D62293A28623D746869732E5F76616C75652C746869';
wwv_flow_api.g_varchar2_table(233) := '732E76616C756528746869732E61646428622C746869732E6D756C7469706C795374657028746869732E6F7074696F6E732E737465702C612929292C746869732E73746570734265747765656E28622C746869732E5F76616C756529297D2C6D6F76654C';
wwv_flow_api.g_varchar2_table(234) := '6566743A66756E6374696F6E2861297B72657475726E2D746869732E6D6F76655269676874282D61297D2C73746570526174696F3A66756E6374696F6E28297B696628746869732E6F7074696F6E732E737465703D3D3D21312972657475726E20313B76';
wwv_flow_api.g_varchar2_table(235) := '617220613D28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F7074696F6E732E626F756E64732E6D696E292F746869732E6F7074696F6E732E737465703B72657475726E20746869732E63616368652E706172656E742E7769';
wwv_flow_api.g_varchar2_table(236) := '6474682F617D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B66756E6374696F6E206328612C62297B72657475726E22756E646566696E6564223D3D747970656F6620613F627C7C21313A617D612E77';
wwv_flow_api.g_varchar2_table(237) := '6964676574282275692E72616E6765536C69646572426172222C612E75692E72616E6765536C69646572447261676761626C652C7B6F7074696F6E733A7B6C65667448616E646C653A6E756C6C2C726967687448616E646C653A6E756C6C2C626F756E64';
wwv_flow_api.g_varchar2_table(238) := '733A7B6D696E3A302C6D61783A3130307D2C747970653A2272616E6765536C6964657248616E646C65222C72616E67653A21312C647261673A66756E6374696F6E28297B7D2C73746F703A66756E6374696F6E28297B7D2C76616C7565733A7B6D696E3A';
wwv_flow_api.g_varchar2_table(239) := '302C6D61783A32307D2C776865656C53706565643A342C776865656C4D6F64653A6E756C6C7D2C5F76616C7565733A7B6D696E3A302C6D61783A32307D2C5F77616974696E67546F496E69743A322C5F776865656C54696D656F75743A21312C5F637265';
wwv_flow_api.g_varchar2_table(240) := '6174653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E6373732822706F736974696F6E222C22';
wwv_flow_api.g_varchar2_table(241) := '6162736F6C75746522292E6373732822746F70222C30292E616464436C617373282275692D72616E6765536C696465722D62617222292C746869732E6F7074696F6E732E6C65667448616E646C652E62696E642822696E697469616C697A65222C612E70';
wwv_flow_api.g_varchar2_table(242) := '726F787928746869732E5F6F6E496E697469616C697A65642C7468697329292E62696E6428226D6F7573657374617274222C612E70726F787928746869732E5F63616368652C7468697329292E62696E64282273746F70222C612E70726F787928746869';
wwv_flow_api.g_varchar2_table(243) := '732E5F6F6E48616E646C6553746F702C7468697329292C746869732E6F7074696F6E732E726967687448616E646C652E62696E642822696E697469616C697A65222C612E70726F787928746869732E5F6F6E496E697469616C697A65642C746869732929';
wwv_flow_api.g_varchar2_table(244) := '2E62696E6428226D6F7573657374617274222C612E70726F787928746869732E5F63616368652C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6F6E48616E646C6553746F702C7468697329292C746869732E5F6269';
wwv_flow_api.g_varchar2_table(245) := '6E6448616E646C657328292C746869732E5F76616C7565733D746869732E6F7074696F6E732E76616C7565732C746869732E5F736574576865656C4D6F64654F7074696F6E28746869732E6F7074696F6E732E776865656C4D6F6465297D2C6465737472';
wwv_flow_api.g_varchar2_table(246) := '6F793A66756E6374696F6E28297B746869732E6F7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292C746869732E6F7074696F6E732E726967687448616E646C652E756E62696E6428222E62617222292C746869732E6F70';
wwv_flow_api.g_varchar2_table(247) := '74696F6E733D6E756C6C2C612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28612C62297B2272616E676522';
wwv_flow_api.g_varchar2_table(248) := '3D3D3D613F746869732E5F73657452616E67654F7074696F6E2862293A22776865656C5370656564223D3D3D613F746869732E5F736574576865656C53706565644F7074696F6E2862293A22776865656C4D6F6465223D3D3D612626746869732E5F7365';
wwv_flow_api.g_varchar2_table(249) := '74576865656C4D6F64654F7074696F6E2862297D2C5F73657452616E67654F7074696F6E3A66756E6374696F6E2861297B69662828226F626A65637422213D747970656F6620617C7C6E756C6C3D3D3D6129262628613D2131292C61213D3D21317C7C74';
wwv_flow_api.g_varchar2_table(250) := '6869732E6F7074696F6E732E72616E6765213D3D2131297B69662861213D3D2131297B76617220623D6328612E6D696E2C746869732E6F7074696F6E732E72616E67652E6D696E292C643D6328612E6D61782C746869732E6F7074696F6E732E72616E67';
wwv_flow_api.g_varchar2_table(251) := '652E6D6178293B746869732E6F7074696F6E732E72616E67653D7B6D696E3A622C6D61783A647D7D656C736520746869732E6F7074696F6E732E72616E67653D21313B746869732E5F7365744C65667452616E676528292C746869732E5F736574526967';
wwv_flow_api.g_varchar2_table(252) := '687452616E676528297D7D2C5F736574576865656C53706565644F7074696F6E3A66756E6374696F6E2861297B226E756D626572223D3D747970656F662061262630213D3D61262628746869732E6F7074696F6E732E776865656C53706565643D61297D';
wwv_flow_api.g_varchar2_table(253) := '2C5F736574576865656C4D6F64654F7074696F6E3A66756E6374696F6E2861297B286E756C6C3D3D3D617C7C613D3D3D21317C7C227A6F6F6D223D3D3D617C7C227363726F6C6C223D3D3D6129262628746869732E6F7074696F6E732E776865656C4D6F';
wwv_flow_api.g_varchar2_table(254) := '6465213D3D612626746869732E656C656D656E742E706172656E7428292E756E62696E6428226D6F757365776865656C2E62617222292C746869732E5F62696E644D6F757365576865656C2861292C746869732E6F7074696F6E732E776865656C4D6F64';
wwv_flow_api.g_varchar2_table(255) := '653D61297D2C5F62696E644D6F757365576865656C3A66756E6374696F6E2862297B227A6F6F6D223D3D3D623F746869732E656C656D656E742E706172656E7428292E62696E6428226D6F757365776865656C2E626172222C612E70726F787928746869';
wwv_flow_api.g_varchar2_table(256) := '732E5F6D6F757365576865656C5A6F6F6D2C7468697329293A227363726F6C6C223D3D3D622626746869732E656C656D656E742E706172656E7428292E62696E6428226D6F757365776865656C2E626172222C612E70726F787928746869732E5F6D6F75';
wwv_flow_api.g_varchar2_table(257) := '7365576865656C5363726F6C6C2C7468697329297D2C5F7365744C65667452616E67653A66756E6374696F6E28297B696628746869732E6F7074696F6E732E72616E67653D3D3D21312972657475726E21313B76617220613D746869732E5F76616C7565';
wwv_flow_api.g_varchar2_table(258) := '732E6D61782C623D7B6D696E3A21312C6D61783A21317D3B22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D696E2626746869732E6F7074696F6E732E72616E67652E6D696E213D3D21313F622E6D61';
wwv_flow_api.g_varchar2_table(259) := '783D746869732E5F6C65667448616E646C652822737562737472616374222C612C746869732E6F7074696F6E732E72616E67652E6D696E293A622E6D61783D21312C22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72';
wwv_flow_api.g_varchar2_table(260) := '616E67652E6D61782626746869732E6F7074696F6E732E72616E67652E6D6178213D3D21313F622E6D696E3D746869732E5F6C65667448616E646C652822737562737472616374222C612C746869732E6F7074696F6E732E72616E67652E6D6178293A62';
wwv_flow_api.g_varchar2_table(261) := '2E6D696E3D21312C746869732E5F6C65667448616E646C6528226F7074696F6E222C2272616E6765222C62297D2C5F736574526967687452616E67653A66756E6374696F6E28297B76617220613D746869732E5F76616C7565732E6D696E2C623D7B6D69';
wwv_flow_api.g_varchar2_table(262) := '6E3A21312C6D61783A21317D3B22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D696E2626746869732E6F7074696F6E732E72616E67652E6D696E213D3D21313F622E6D696E3D746869732E5F726967';
wwv_flow_api.g_varchar2_table(263) := '687448616E646C652822616464222C612C746869732E6F7074696F6E732E72616E67652E6D696E293A622E6D696E3D21312C22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D61782626746869732E6F';
wwv_flow_api.g_varchar2_table(264) := '7074696F6E732E72616E67652E6D6178213D3D21313F622E6D61783D746869732E5F726967687448616E646C652822616464222C612C746869732E6F7074696F6E732E72616E67652E6D6178293A622E6D61783D21312C746869732E5F72696768744861';
wwv_flow_api.g_varchar2_table(265) := '6E646C6528226F7074696F6E222C2272616E6765222C62297D2C5F6465616374697661746552616E67653A66756E6374696F6E28297B746869732E5F6C65667448616E646C6528226F7074696F6E222C2272616E6765222C2131292C746869732E5F7269';
wwv_flow_api.g_varchar2_table(266) := '67687448616E646C6528226F7074696F6E222C2272616E6765222C2131297D2C5F7265616374697661746552616E67653A66756E6374696F6E28297B746869732E5F73657452616E67654F7074696F6E28746869732E6F7074696F6E732E72616E676529';
wwv_flow_api.g_varchar2_table(267) := '7D2C5F6F6E496E697469616C697A65643A66756E6374696F6E28297B746869732E5F77616974696E67546F496E69742D2D2C303D3D3D746869732E5F77616974696E67546F496E69742626746869732E5F696E69744D6528297D2C5F696E69744D653A66';
wwv_flow_api.g_varchar2_table(268) := '756E6374696F6E28297B746869732E5F636163686528292C746869732E6D696E28746869732E5F76616C7565732E6D696E292C746869732E6D617828746869732E5F76616C7565732E6D6178293B76617220613D746869732E5F6C65667448616E646C65';
wwv_flow_api.g_varchar2_table(269) := '2822706F736974696F6E22292C623D746869732E5F726967687448616E646C652822706F736974696F6E22292B746869732E6F7074696F6E732E726967687448616E646C652E776964746828293B746869732E656C656D656E742E6F6666736574287B6C';
wwv_flow_api.g_varchar2_table(270) := '6566743A617D292C746869732E656C656D656E742E63737328227769647468222C622D61297D2C5F6C65667448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F68616E646C6550726F787928746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(271) := '6C65667448616E646C652C617267756D656E7473297D2C5F726967687448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F68616E646C6550726F787928746869732E6F7074696F6E732E726967687448616E646C652C617267';
wwv_flow_api.g_varchar2_table(272) := '756D656E7473297D2C5F68616E646C6550726F78793A66756E6374696F6E28612C62297B76617220633D41727261792E70726F746F747970652E736C6963652E63616C6C2862293B72657475726E20615B746869732E6F7074696F6E732E747970655D2E';
wwv_flow_api.g_varchar2_table(273) := '6170706C7928612C63297D2C5F63616368653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F63616368652E6170706C792874686973292C746869732E5F636163686548616E64';
wwv_flow_api.g_varchar2_table(274) := '6C657328297D2C5F636163686548616E646C65733A66756E6374696F6E28297B746869732E63616368652E726967687448616E646C653D7B7D2C746869732E63616368652E726967687448616E646C652E77696474683D746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(275) := '726967687448616E646C652E776964746828292C746869732E63616368652E726967687448616E646C652E6F66667365743D746869732E6F7074696F6E732E726967687448616E646C652E6F666673657428292C746869732E63616368652E6C65667448';
wwv_flow_api.g_varchar2_table(276) := '616E646C653D7B7D2C746869732E63616368652E6C65667448616E646C652E6F66667365743D746869732E6F7074696F6E732E6C65667448616E646C652E6F666673657428297D2C5F6D6F75736553746172743A66756E6374696F6E2862297B612E7569';
wwv_flow_api.g_varchar2_table(277) := '2E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6D6F75736553746172742E6170706C7928746869732C5B625D292C746869732E5F6465616374697661746552616E676528297D2C5F6D6F75736553746F703A66756E63';
wwv_flow_api.g_varchar2_table(278) := '74696F6E2862297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6D6F75736553746F702E6170706C7928746869732C5B625D292C746869732E5F636163686548616E646C657328292C746869732E5F7661';
wwv_flow_api.g_varchar2_table(279) := '6C7565732E6D696E3D746869732E5F6C65667448616E646C65282276616C756522292C746869732E5F76616C7565732E6D61783D746869732E5F726967687448616E646C65282276616C756522292C746869732E5F7265616374697661746552616E6765';
wwv_flow_api.g_varchar2_table(280) := '28292C746869732E5F6C65667448616E646C6528292E74726967676572282273746F7022292C746869732E5F726967687448616E646C6528292E74726967676572282273746F7022297D2C5F6F6E447261674C65667448616E646C653A66756E6374696F';
wwv_flow_api.g_varchar2_table(281) := '6E28612C62297B696628746869732E5F636163686549664E656365737361727928292C622E656C656D656E745B305D3D3D3D746869732E6F7074696F6E732E6C65667448616E646C655B305D297B696628746869732E5F737769746368656456616C7565';
wwv_flow_api.g_varchar2_table(282) := '7328292972657475726E20746869732E5F73776974636848616E646C657328292C766F696420746869732E5F6F6E44726167526967687448616E646C6528612C62293B746869732E5F76616C7565732E6D696E3D622E76616C75652C746869732E636163';
wwv_flow_api.g_varchar2_table(283) := '68652E6F66667365742E6C6566743D622E6F66667365742E6C6566742C746869732E63616368652E6C65667448616E646C652E6F66667365743D622E6F66667365742C746869732E5F706F736974696F6E42617228297D7D2C5F6F6E4472616752696768';
wwv_flow_api.g_varchar2_table(284) := '7448616E646C653A66756E6374696F6E28612C62297B696628746869732E5F636163686549664E656365737361727928292C622E656C656D656E745B305D3D3D3D746869732E6F7074696F6E732E726967687448616E646C655B305D297B696628746869';
wwv_flow_api.g_varchar2_table(285) := '732E5F737769746368656456616C75657328292972657475726E20746869732E5F73776974636848616E646C657328292C766F696420746869732E5F6F6E447261674C65667448616E646C6528612C62293B746869732E5F76616C7565732E6D61783D62';
wwv_flow_api.g_varchar2_table(286) := '2E76616C75652C746869732E63616368652E726967687448616E646C652E6F66667365743D622E6F66667365742C746869732E5F706F736974696F6E42617228297D7D2C5F706F736974696F6E4261723A66756E6374696F6E28297B76617220613D7468';
wwv_flow_api.g_varchar2_table(287) := '69732E63616368652E726967687448616E646C652E6F66667365742E6C6566742B746869732E63616368652E726967687448616E646C652E77696474682D746869732E63616368652E6C65667448616E646C652E6F66667365742E6C6566743B74686973';
wwv_flow_api.g_varchar2_table(288) := '2E63616368652E77696474682E696E6E65723D612C746869732E656C656D656E742E63737328227769647468222C61292E6F6666736574287B6C6566743A746869732E63616368652E6C65667448616E646C652E6F66667365742E6C6566747D297D2C5F';
wwv_flow_api.g_varchar2_table(289) := '6F6E48616E646C6553746F703A66756E6374696F6E28297B746869732E5F7365744C65667452616E676528292C746869732E5F736574526967687452616E676528297D2C5F737769746368656456616C7565733A66756E6374696F6E28297B6966287468';
wwv_flow_api.g_varchar2_table(290) := '69732E6D696E28293E746869732E6D61782829297B76617220613D746869732E5F76616C7565732E6D696E3B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E5F76616C7565732E6D61782C746869732E5F76616C7565732E6D61';
wwv_flow_api.g_varchar2_table(291) := '783D612C21307D72657475726E21317D2C5F73776974636848616E646C65733A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E6C65667448616E646C653B746869732E6F7074696F6E732E6C65667448616E646C653D746869';
wwv_flow_api.g_varchar2_table(292) := '732E6F7074696F6E732E726967687448616E646C652C746869732E6F7074696F6E732E726967687448616E646C653D612C746869732E5F6C65667448616E646C6528226F7074696F6E222C2269734C656674222C2130292C746869732E5F726967687448';
wwv_flow_api.g_varchar2_table(293) := '616E646C6528226F7074696F6E222C2269734C656674222C2131292C746869732E5F62696E6448616E646C657328292C746869732E5F636163686548616E646C657328297D2C5F62696E6448616E646C65733A66756E6374696F6E28297B746869732E6F';
wwv_flow_api.g_varchar2_table(294) := '7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292E62696E642822736C69646572447261672E626172207570646174652E626172206D6F76696E672E626172222C612E70726F787928746869732E5F6F6E447261674C6566';
wwv_flow_api.g_varchar2_table(295) := '7448616E646C652C7468697329292C746869732E6F7074696F6E732E726967687448616E646C652E756E62696E6428222E62617222292E62696E642822736C69646572447261672E626172207570646174652E626172206D6F76696E672E626172222C61';
wwv_flow_api.g_varchar2_table(296) := '2E70726F787928746869732E5F6F6E44726167526967687448616E646C652C7468697329297D2C5F636F6E73747261696E74506F736974696F6E3A66756E6374696F6E2862297B76617220632C643D7B7D3B72657475726E20642E6C6566743D612E7569';
wwv_flow_api.g_varchar2_table(297) := '2E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F636F6E73747261696E74506F736974696F6E2E6170706C7928746869732C5B625D292C642E6C6566743D746869732E5F6C65667448616E646C652822706F736974696F';
wwv_flow_api.g_varchar2_table(298) := '6E222C642E6C656674292C633D746869732E5F726967687448616E646C652822706F736974696F6E222C642E6C6566742B746869732E63616368652E77696474682E6F757465722D746869732E63616368652E726967687448616E646C652E7769647468';
wwv_flow_api.g_varchar2_table(299) := '292C642E77696474683D632D642E6C6566742B746869732E63616368652E726967687448616E646C652E77696474682C647D2C5F6170706C79506F736974696F6E3A66756E6374696F6E2862297B612E75692E72616E6765536C69646572447261676761';
wwv_flow_api.g_varchar2_table(300) := '626C652E70726F746F747970652E5F6170706C79506F736974696F6E2E6170706C7928746869732C5B622E6C6566745D292C746869732E656C656D656E742E776964746828622E7769647468297D2C5F6D6F757365576865656C5A6F6F6D3A66756E6374';
wwv_flow_api.g_varchar2_table(301) := '696F6E28622C632C642C65297B69662821746869732E656E61626C65642972657475726E21313B76617220663D746869732E5F76616C7565732E6D696E2B28746869732E5F76616C7565732E6D61782D746869732E5F76616C7565732E6D696E292F322C';
wwv_flow_api.g_varchar2_table(302) := '673D7B7D2C683D7B7D3B72657475726E20746869732E6F7074696F6E732E72616E67653D3D3D21317C7C746869732E6F7074696F6E732E72616E67652E6D696E3D3D3D21313F28672E6D61783D662C682E6D696E3D66293A28672E6D61783D662D746869';
wwv_flow_api.g_varchar2_table(303) := '732E6F7074696F6E732E72616E67652E6D696E2F322C682E6D696E3D662B746869732E6F7074696F6E732E72616E67652E6D696E2F32292C746869732E6F7074696F6E732E72616E6765213D3D21312626746869732E6F7074696F6E732E72616E67652E';
wwv_flow_api.g_varchar2_table(304) := '6D6178213D3D2131262628672E6D696E3D662D746869732E6F7074696F6E732E72616E67652E6D61782F322C682E6D61783D662B746869732E6F7074696F6E732E72616E67652E6D61782F32292C746869732E5F6C65667448616E646C6528226F707469';
wwv_flow_api.g_varchar2_table(305) := '6F6E222C2272616E6765222C67292C746869732E5F726967687448616E646C6528226F7074696F6E222C2272616E6765222C68292C636C65617254696D656F757428746869732E5F776865656C54696D656F7574292C746869732E5F776865656C54696D';
wwv_flow_api.g_varchar2_table(306) := '656F75743D73657454696D656F757428612E70726F787928746869732E5F776865656C53746F702C74686973292C323030292C746869732E7A6F6F6D496E28652A746869732E6F7074696F6E732E776865656C5370656564292C21317D2C5F6D6F757365';
wwv_flow_api.g_varchar2_table(307) := '576865656C5363726F6C6C3A66756E6374696F6E28622C632C642C65297B72657475726E20746869732E656E61626C65643F28746869732E5F776865656C54696D656F75743D3D3D21313F746869732E73746172745363726F6C6C28293A636C65617254';
wwv_flow_api.g_varchar2_table(308) := '696D656F757428746869732E5F776865656C54696D656F7574292C746869732E5F776865656C54696D656F75743D73657454696D656F757428612E70726F787928746869732E5F776865656C53746F702C74686973292C323030292C746869732E736372';
wwv_flow_api.g_varchar2_table(309) := '6F6C6C4C65667428652A746869732E6F7074696F6E732E776865656C5370656564292C2131293A21317D2C5F776865656C53746F703A66756E6374696F6E28297B746869732E73746F705363726F6C6C28292C746869732E5F776865656C54696D656F75';
wwv_flow_api.g_varchar2_table(310) := '743D21317D2C6D696E3A66756E6374696F6E2861297B72657475726E20746869732E5F6C65667448616E646C65282276616C7565222C61297D2C6D61783A66756E6374696F6E2861297B72657475726E20746869732E5F726967687448616E646C652822';
wwv_flow_api.g_varchar2_table(311) := '76616C7565222C61297D2C73746172745363726F6C6C3A66756E6374696F6E28297B746869732E5F6465616374697661746552616E676528297D2C73746F705363726F6C6C3A66756E6374696F6E28297B746869732E5F7265616374697661746552616E';
wwv_flow_api.g_varchar2_table(312) := '676528292C746869732E5F747269676765724D6F7573654576656E74282273746F7022292C746869732E5F6C65667448616E646C6528292E74726967676572282273746F7022292C746869732E5F726967687448616E646C6528292E7472696767657228';
wwv_flow_api.g_varchar2_table(313) := '2273746F7022297D2C7363726F6C6C4C6566743A66756E6374696F6E2861297B72657475726E20613D617C7C312C303E613F746869732E7363726F6C6C5269676874282D61293A28613D746869732E5F6C65667448616E646C6528226D6F76654C656674';
wwv_flow_api.g_varchar2_table(314) := '222C61292C746869732E5F726967687448616E646C6528226D6F76654C656674222C61292C746869732E75706461746528292C766F696420746869732E5F747269676765724D6F7573654576656E7428227363726F6C6C2229297D2C7363726F6C6C5269';
wwv_flow_api.g_varchar2_table(315) := '6768743A66756E6374696F6E2861297B72657475726E20613D617C7C312C303E613F746869732E7363726F6C6C4C656674282D61293A28613D746869732E5F726967687448616E646C6528226D6F76655269676874222C61292C746869732E5F6C656674';
wwv_flow_api.g_varchar2_table(316) := '48616E646C6528226D6F76655269676874222C61292C746869732E75706461746528292C766F696420746869732E5F747269676765724D6F7573654576656E7428227363726F6C6C2229297D2C7A6F6F6D496E3A66756E6374696F6E2861297B69662861';
wwv_flow_api.g_varchar2_table(317) := '3D617C7C312C303E612972657475726E20746869732E7A6F6F6D4F7574282D61293B76617220623D746869732E5F726967687448616E646C6528226D6F76654C656674222C61293B613E62262628622F3D322C746869732E5F726967687448616E646C65';
wwv_flow_api.g_varchar2_table(318) := '28226D6F76655269676874222C6229292C746869732E5F6C65667448616E646C6528226D6F76655269676874222C62292C746869732E75706461746528292C746869732E5F747269676765724D6F7573654576656E7428227A6F6F6D22297D2C7A6F6F6D';
wwv_flow_api.g_varchar2_table(319) := '4F75743A66756E6374696F6E2861297B696628613D617C7C312C303E612972657475726E20746869732E7A6F6F6D496E282D61293B76617220623D746869732E5F726967687448616E646C6528226D6F76655269676874222C61293B613E62262628622F';
wwv_flow_api.g_varchar2_table(320) := '3D322C746869732E5F726967687448616E646C6528226D6F76654C656674222C6229292C746869732E5F6C65667448616E646C6528226D6F76654C656674222C62292C746869732E75706461746528292C746869732E5F747269676765724D6F75736545';
wwv_flow_api.g_varchar2_table(321) := '76656E7428227A6F6F6D22297D2C76616C7565733A66756E6374696F6E28612C62297B69662822756E646566696E656422213D747970656F662061262622756E646566696E656422213D747970656F662062297B76617220633D4D6174682E6D696E2861';
wwv_flow_api.g_varchar2_table(322) := '2C62292C643D4D6174682E6D617828612C62293B0A746869732E5F6465616374697661746552616E676528292C746869732E6F7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292C746869732E6F7074696F6E732E726967';
wwv_flow_api.g_varchar2_table(323) := '687448616E646C652E756E62696E6428222E62617222292C746869732E5F76616C7565732E6D696E3D746869732E5F6C65667448616E646C65282276616C7565222C63292C746869732E5F76616C7565732E6D61783D746869732E5F726967687448616E';
wwv_flow_api.g_varchar2_table(324) := '646C65282276616C7565222C64292C746869732E5F62696E6448616E646C657328292C746869732E5F7265616374697661746552616E676528292C746869732E75706461746528297D72657475726E7B6D696E3A746869732E5F76616C7565732E6D696E';
wwv_flow_api.g_varchar2_table(325) := '2C6D61783A746869732E5F76616C7565732E6D61787D7D2C7570646174653A66756E6374696F6E28297B746869732E5F76616C7565732E6D696E3D746869732E6D696E28292C746869732E5F76616C7565732E6D61783D746869732E6D617828292C7468';
wwv_flow_api.g_varchar2_table(326) := '69732E5F636163686528292C746869732E5F706F736974696F6E42617228297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B66756E6374696F6E206328622C632C642C65297B746869732E6C616265';
wwv_flow_api.g_varchar2_table(327) := '6C313D622C746869732E6C6162656C323D632C746869732E747970653D642C746869732E6F7074696F6E733D652C746869732E68616E646C65313D746869732E6C6162656C315B746869732E747970655D28226F7074696F6E222C2268616E646C652229';
wwv_flow_api.g_varchar2_table(328) := '2C746869732E68616E646C65323D746869732E6C6162656C325B746869732E747970655D28226F7074696F6E222C2268616E646C6522292C746869732E63616368653D6E756C6C2C746869732E6C6566743D622C746869732E72696768743D632C746869';
wwv_flow_api.g_varchar2_table(329) := '732E6D6F76696E673D21312C746869732E696E697469616C697A65643D21312C746869732E7570646174696E673D21312C746869732E496E69743D66756E6374696F6E28297B746869732E42696E6448616E646C6528746869732E68616E646C6531292C';
wwv_flow_api.g_varchar2_table(330) := '746869732E42696E6448616E646C6528746869732E68616E646C6532292C2273686F77223D3D3D746869732E6F7074696F6E732E73686F773F2873657454696D656F757428612E70726F787928746869732E506F736974696F6E4C6162656C732C746869';
wwv_flow_api.g_varchar2_table(331) := '73292C31292C746869732E696E697469616C697A65643D2130293A73657454696D656F757428612E70726F787928746869732E4166746572496E69742C74686973292C316533292C746869732E5F726573697A6550726F78793D612E70726F7879287468';
wwv_flow_api.g_varchar2_table(332) := '69732E6F6E57696E646F77526573697A652C74686973292C612877696E646F77292E726573697A6528746869732E5F726573697A6550726F7879297D2C746869732E44657374726F793D66756E6374696F6E28297B746869732E5F726573697A6550726F';
wwv_flow_api.g_varchar2_table(333) := '7879262628612877696E646F77292E756E62696E642822726573697A65222C746869732E5F726573697A6550726F7879292C746869732E5F726573697A6550726F78793D6E756C6C2C746869732E68616E646C65312E756E62696E6428222E706F736974';
wwv_flow_api.g_varchar2_table(334) := '696F6E6E657222292C746869732E68616E646C65313D6E756C6C2C746869732E68616E646C65322E756E62696E6428222E706F736974696F6E6E657222292C746869732E68616E646C65323D6E756C6C2C746869732E6C6162656C313D6E756C6C2C7468';
wwv_flow_api.g_varchar2_table(335) := '69732E6C6162656C323D6E756C6C2C746869732E6C6566743D6E756C6C2C746869732E72696768743D6E756C6C292C746869732E63616368653D6E756C6C7D2C746869732E4166746572496E69743D66756E6374696F6E28297B746869732E696E697469';
wwv_flow_api.g_varchar2_table(336) := '616C697A65643D21307D2C746869732E43616368653D66756E6374696F6E28297B226E6F6E6522213D3D746869732E6C6162656C312E6373732822646973706C61792229262628746869732E63616368653D7B7D2C746869732E63616368652E6C616265';
wwv_flow_api.g_varchar2_table(337) := '6C313D7B7D2C746869732E63616368652E6C6162656C323D7B7D2C746869732E63616368652E68616E646C65313D7B7D2C746869732E63616368652E68616E646C65323D7B7D2C746869732E63616368652E6F6666736574506172656E743D7B7D2C7468';
wwv_flow_api.g_varchar2_table(338) := '69732E4361636865456C656D656E7428746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E4361636865456C656D656E7428746869732E6C6162656C322C746869732E63616368652E6C6162656C32292C74686973';
wwv_flow_api.g_varchar2_table(339) := '2E4361636865456C656D656E7428746869732E68616E646C65312C746869732E63616368652E68616E646C6531292C746869732E4361636865456C656D656E7428746869732E68616E646C65322C746869732E63616368652E68616E646C6532292C7468';
wwv_flow_api.g_varchar2_table(340) := '69732E4361636865456C656D656E7428746869732E6C6162656C312E6F6666736574506172656E7428292C746869732E63616368652E6F6666736574506172656E7429297D2C746869732E436163686549664E65636573736172793D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(341) := '28297B6E756C6C3D3D3D746869732E63616368653F746869732E436163686528293A28746869732E4361636865576964746828746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E43616368655769647468287468';
wwv_flow_api.g_varchar2_table(342) := '69732E6C6162656C322C746869732E63616368652E6C6162656C32292C746869732E436163686548656967687428746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E436163686548656967687428746869732E6C';
wwv_flow_api.g_varchar2_table(343) := '6162656C322C746869732E63616368652E6C6162656C32292C746869732E4361636865576964746828746869732E6C6162656C312E6F6666736574506172656E7428292C746869732E63616368652E6F6666736574506172656E7429297D2C746869732E';
wwv_flow_api.g_varchar2_table(344) := '4361636865456C656D656E743D66756E6374696F6E28612C62297B746869732E4361636865576964746828612C62292C746869732E436163686548656967687428612C62292C622E6F66667365743D612E6F666673657428292C622E6D617267696E3D7B';
wwv_flow_api.g_varchar2_table(345) := '6C6566743A746869732E5061727365506978656C7328226D617267696E4C656674222C61292C72696768743A746869732E5061727365506978656C7328226D617267696E5269676874222C61297D2C622E626F726465723D7B6C6566743A746869732E50';
wwv_flow_api.g_varchar2_table(346) := '61727365506978656C732822626F726465724C6566745769647468222C61292C72696768743A746869732E5061727365506978656C732822626F7264657252696768745769647468222C61297D7D2C746869732E436163686557696474683D66756E6374';
wwv_flow_api.g_varchar2_table(347) := '696F6E28612C62297B622E77696474683D612E776964746828292C622E6F7574657257696474683D612E6F75746572576964746828297D2C746869732E43616368654865696768743D66756E6374696F6E28612C62297B622E6F75746572486569676874';
wwv_flow_api.g_varchar2_table(348) := '4D617267696E3D612E6F75746572486569676874282130297D2C746869732E5061727365506978656C733D66756E6374696F6E28612C62297B72657475726E207061727365496E7428622E6373732861292C3130297C7C307D2C746869732E42696E6448';
wwv_flow_api.g_varchar2_table(349) := '616E646C653D66756E6374696F6E2862297B622E62696E6428227570646174696E672E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C655570646174696E672C7468697329292C622E62696E6428227570646174652E';
wwv_flow_api.g_varchar2_table(350) := '706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C65557064617465642C7468697329292C622E62696E6428226D6F76696E672E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C654D6F';
wwv_flow_api.g_varchar2_table(351) := '76696E672C7468697329292C622E62696E64282273746F702E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C6553746F702C7468697329297D2C746869732E506F736974696F6E4C6162656C733D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(352) := '28297B696628746869732E436163686549664E656365737361727928292C6E756C6C213D3D746869732E6361636865297B76617220613D746869732E476574526177506F736974696F6E28746869732E63616368652E6C6162656C312C746869732E6361';
wwv_flow_api.g_varchar2_table(353) := '6368652E68616E646C6531292C623D746869732E476574526177506F736974696F6E28746869732E63616368652E6C6162656C322C746869732E63616368652E68616E646C6532293B746869732E6C6162656C315B645D28226F7074696F6E222C226973';
wwv_flow_api.g_varchar2_table(354) := '4C65667422293F746869732E436F6E73747261696E74506F736974696F6E7328612C62293A746869732E436F6E73747261696E74506F736974696F6E7328622C61292C746869732E506F736974696F6E4C6162656C28746869732E6C6162656C312C612E';
wwv_flow_api.g_varchar2_table(355) := '6C6566742C746869732E63616368652E6C6162656C31292C746869732E506F736974696F6E4C6162656C28746869732E6C6162656C322C622E6C6566742C746869732E63616368652E6C6162656C32297D7D2C746869732E506F736974696F6E4C616265';
wwv_flow_api.g_varchar2_table(356) := '6C3D66756E6374696F6E28612C622C63297B76617220642C652C662C673D746869732E63616368652E6F6666736574506172656E742E6F66667365742E6C6566742B746869732E63616368652E6F6666736574506172656E742E626F726465722E6C6566';
wwv_flow_api.g_varchar2_table(357) := '743B672D623E3D303F28612E63737328227269676874222C2222292C612E6F6666736574287B6C6566743A627D29293A28643D672B746869732E63616368652E6F6666736574506172656E742E77696474682C653D622B632E6D617267696E2E6C656674';
wwv_flow_api.g_varchar2_table(358) := '2B632E6F7574657257696474682B632E6D617267696E2E72696768742C663D642D652C612E63737328226C656674222C2222292C612E63737328227269676874222C6629297D2C746869732E436F6E73747261696E74506F736974696F6E733D66756E63';
wwv_flow_api.g_varchar2_table(359) := '74696F6E28612C62297B28612E63656E7465723C622E63656E7465722626612E6F7574657252696768743E622E6F757465724C6566747C7C612E63656E7465723E622E63656E7465722626622E6F7574657252696768743E612E6F757465724C65667429';
wwv_flow_api.g_varchar2_table(360) := '262628613D746869732E6765744C656674506F736974696F6E28612C62292C623D746869732E6765745269676874506F736974696F6E28612C6229297D2C746869732E6765744C656674506F736974696F6E3D66756E6374696F6E28612C62297B766172';
wwv_flow_api.g_varchar2_table(361) := '20633D28622E63656E7465722B612E63656E746572292F322C643D632D612E63616368652E6F7574657257696474682D612E63616368652E6D617267696E2E72696768742B612E63616368652E626F726465722E6C6566743B72657475726E20612E6C65';
wwv_flow_api.g_varchar2_table(362) := '66743D642C617D2C746869732E6765745269676874506F736974696F6E3D66756E6374696F6E28612C62297B76617220633D28622E63656E7465722B612E63656E746572292F323B72657475726E20622E6C6566743D632B622E63616368652E6D617267';
wwv_flow_api.g_varchar2_table(363) := '696E2E6C6566742B622E63616368652E626F726465722E6C6566742C627D2C746869732E53686F7749664E65636573736172793D66756E6374696F6E28297B2273686F77223D3D3D746869732E6F7074696F6E732E73686F777C7C746869732E6D6F7669';
wwv_flow_api.g_varchar2_table(364) := '6E677C7C21746869732E696E697469616C697A65647C7C746869732E7570646174696E677C7C28746869732E6C6162656C312E73746F702821302C2130292E66616465496E28746869732E6F7074696F6E732E6475726174696F6E496E7C7C30292C7468';
wwv_flow_api.g_varchar2_table(365) := '69732E6C6162656C322E73746F702821302C2130292E66616465496E28746869732E6F7074696F6E732E6475726174696F6E496E7C7C30292C746869732E6D6F76696E673D2130297D2C746869732E4869646549664E65656465643D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(366) := '28297B746869732E6D6F76696E673D3D3D2130262628746869732E6C6162656C312E73746F702821302C2130292E64656C617928746869732E6F7074696F6E732E64656C61794F75747C7C30292E666164654F757428746869732E6F7074696F6E732E64';
wwv_flow_api.g_varchar2_table(367) := '75726174696F6E4F75747C7C30292C746869732E6C6162656C322E73746F702821302C2130292E64656C617928746869732E6F7074696F6E732E64656C61794F75747C7C30292E666164654F757428746869732E6F7074696F6E732E6475726174696F6E';
wwv_flow_api.g_varchar2_table(368) := '4F75747C7C30292C746869732E6D6F76696E673D2131297D2C746869732E6F6E48616E646C654D6F76696E673D66756E6374696F6E28612C62297B746869732E53686F7749664E656365737361727928292C746869732E436163686549664E6563657373';
wwv_flow_api.g_varchar2_table(369) := '61727928292C746869732E55706461746548616E646C65506F736974696F6E2862292C746869732E506F736974696F6E4C6162656C7328297D2C746869732E6F6E48616E646C655570646174696E673D66756E6374696F6E28297B746869732E75706461';
wwv_flow_api.g_varchar2_table(370) := '74696E673D21307D2C746869732E6F6E48616E646C65557064617465643D66756E6374696F6E28297B746869732E7570646174696E673D21312C746869732E63616368653D6E756C6C7D2C746869732E6F6E48616E646C6553746F703D66756E6374696F';
wwv_flow_api.g_varchar2_table(371) := '6E28297B746869732E4869646549664E656564656428297D2C746869732E6F6E57696E646F77526573697A653D66756E6374696F6E28297B746869732E63616368653D6E756C6C7D2C746869732E55706461746548616E646C65506F736974696F6E3D66';
wwv_flow_api.g_varchar2_table(372) := '756E6374696F6E2861297B6E756C6C213D3D746869732E6361636865262628612E656C656D656E745B305D3D3D3D746869732E68616E646C65315B305D3F746869732E557064617465506F736974696F6E28612C746869732E63616368652E68616E646C';
wwv_flow_api.g_varchar2_table(373) := '6531293A746869732E557064617465506F736974696F6E28612C746869732E63616368652E68616E646C653229297D2C746869732E557064617465506F736974696F6E3D66756E6374696F6E28612C62297B622E6F66667365743D612E6F66667365742C';
wwv_flow_api.g_varchar2_table(374) := '622E76616C75653D612E76616C75657D2C746869732E476574526177506F736974696F6E3D66756E6374696F6E28612C62297B76617220633D622E6F66667365742E6C6566742B622E6F7574657257696474682F322C643D632D612E6F75746572576964';
wwv_flow_api.g_varchar2_table(375) := '74682F322C653D642B612E6F7574657257696474682D612E626F726465722E6C6566742D612E626F726465722E72696768742C663D642D612E6D617267696E2E6C6566742D612E626F726465722E6C6566742C673D622E6F66667365742E746F702D612E';
wwv_flow_api.g_varchar2_table(376) := '6F757465724865696768744D617267696E3B72657475726E7B6C6566743A642C6F757465724C6566743A662C746F703A672C72696768743A652C6F7574657252696768743A662B612E6F7574657257696474682B612E6D617267696E2E6C6566742B612E';
wwv_flow_api.g_varchar2_table(377) := '6D617267696E2E72696768742C63616368653A612C63656E7465723A637D7D2C746869732E496E697428297D612E776964676574282275692E72616E6765536C696465724C6162656C222C612E75692E72616E6765536C696465724D6F757365546F7563';
wwv_flow_api.g_varchar2_table(378) := '682C7B6F7074696F6E733A7B68616E646C653A6E756C6C2C666F726D61747465723A21312C68616E646C65547970653A2272616E6765536C6964657248616E646C65222C73686F773A2273686F77222C6475726174696F6E496E3A302C6475726174696F';
wwv_flow_api.g_varchar2_table(379) := '6E4F75743A3530302C64656C61794F75743A3530302C69734C6566743A21317D2C63616368653A6E756C6C2C5F706F736974696F6E6E65723A6E756C6C2C5F76616C7565436F6E7461696E65723A6E756C6C2C5F696E6E6572456C656D656E743A6E756C';
wwv_flow_api.g_varchar2_table(380) := '6C2C5F76616C75653A6E756C6C2C5F6372656174653A66756E6374696F6E28297B746869732E6F7074696F6E732E69734C6566743D746869732E5F68616E646C6528226F7074696F6E222C2269734C65667422292C746869732E656C656D656E742E6164';
wwv_flow_api.g_varchar2_table(381) := '64436C617373282275692D72616E6765536C696465722D6C6162656C22292E6373732822706F736974696F6E222C226162736F6C75746522292E6373732822646973706C6179222C22626C6F636B22292C746869732E5F637265617465456C656D656E74';
wwv_flow_api.g_varchar2_table(382) := '7328292C746869732E5F746F67676C65436C61737328292C746869732E6F7074696F6E732E68616E646C652E62696E6428226D6F76696E672E6C6162656C222C612E70726F787928746869732E5F6F6E4D6F76696E672C7468697329292E62696E642822';
wwv_flow_api.g_varchar2_table(383) := '7570646174652E6C6162656C222C612E70726F787928746869732E5F6F6E5570646174652C7468697329292E62696E6428227377697463682E6C6162656C222C612E70726F787928746869732E5F6F6E5377697463682C7468697329292C2273686F7722';
wwv_flow_api.g_varchar2_table(384) := '213D3D746869732E6F7074696F6E732E73686F772626746869732E656C656D656E742E6869646528292C746869732E5F6D6F757365496E697428297D2C64657374726F793A66756E6374696F6E28297B746869732E6F7074696F6E732E68616E646C652E';
wwv_flow_api.g_varchar2_table(385) := '756E62696E6428222E6C6162656C22292C746869732E6F7074696F6E732E68616E646C653D6E756C6C2C746869732E5F76616C7565436F6E7461696E65723D6E756C6C2C746869732E5F696E6E6572456C656D656E743D6E756C6C2C746869732E656C65';
wwv_flow_api.g_varchar2_table(386) := '6D656E742E656D70747928292C746869732E5F706F736974696F6E6E6572262628746869732E5F706F736974696F6E6E65722E44657374726F7928292C746869732E5F706F736974696F6E6E65723D6E756C6C292C612E75692E72616E6765536C696465';
wwv_flow_api.g_varchar2_table(387) := '724D6F757365546F7563682E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F637265617465456C656D656E74733A66756E6374696F6E28297B746869732E5F76616C7565436F6E7461696E65723D6128223C6469762063';
wwv_flow_api.g_varchar2_table(388) := '6C6173733D2775692D72616E6765536C696465722D6C6162656C2D76616C756527202F3E22292E617070656E64546F28746869732E656C656D656E74292C746869732E5F696E6E6572456C656D656E743D6128223C64697620636C6173733D2775692D72';
wwv_flow_api.g_varchar2_table(389) := '616E6765536C696465722D6C6162656C2D696E6E657227202F3E22292E617070656E64546F28746869732E656C656D656E74297D2C5F68616E646C653A66756E6374696F6E28297B76617220613D41727261792E70726F746F747970652E736C6963652E';
wwv_flow_api.g_varchar2_table(390) := '6170706C7928617267756D656E7473293B72657475726E20746869732E6F7074696F6E732E68616E646C655B746869732E6F7074696F6E732E68616E646C65547970655D2E6170706C7928746869732E6F7074696F6E732E68616E646C652C61297D2C5F';
wwv_flow_api.g_varchar2_table(391) := '7365744F7074696F6E3A66756E6374696F6E28612C62297B2273686F77223D3D3D613F746869732E5F75706461746553686F774F7074696F6E2862293A28226475726174696F6E496E223D3D3D617C7C226475726174696F6E4F7574223D3D3D617C7C22';
wwv_flow_api.g_varchar2_table(392) := '64656C61794F7574223D3D3D61292626746869732E5F7570646174654475726174696F6E7328612C62292C746869732E5F736574466F726D61747465724F7074696F6E28612C62297D2C5F736574466F726D61747465724F7074696F6E3A66756E637469';
wwv_flow_api.g_varchar2_table(393) := '6F6E28612C62297B22666F726D6174746572223D3D3D612626282266756E6374696F6E223D3D747970656F6620627C7C623D3D3D213129262628746869732E6F7074696F6E732E666F726D61747465723D622C746869732E5F646973706C617928746869';
wwv_flow_api.g_varchar2_table(394) := '732E5F76616C756529297D2C5F75706461746553686F774F7074696F6E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E73686F773D612C2273686F7722213D3D746869732E6F7074696F6E732E73686F773F28746869732E656C656D65';
wwv_flow_api.g_varchar2_table(395) := '6E742E6869646528292C746869732E5F706F736974696F6E6E65722E6D6F76696E673D2131293A28746869732E656C656D656E742E73686F7728292C746869732E5F646973706C617928746869732E6F7074696F6E732E68616E646C655B746869732E6F';
wwv_flow_api.g_varchar2_table(396) := '7074696F6E732E68616E646C65547970655D282276616C75652229292C746869732E5F706F736974696F6E6E65722E506F736974696F6E4C6162656C732829292C746869732E5F706F736974696F6E6E65722E6F7074696F6E732E73686F773D74686973';
wwv_flow_api.g_varchar2_table(397) := '2E6F7074696F6E732E73686F777D2C5F7570646174654475726174696F6E733A66756E6374696F6E28612C62297B7061727365496E7428622C3130293D3D3D62262628746869732E5F706F736974696F6E6E65722E6F7074696F6E735B615D3D622C7468';
wwv_flow_api.g_varchar2_table(398) := '69732E6F7074696F6E735B615D3D62297D2C5F646973706C61793A66756E6374696F6E2861297B746869732E6F7074696F6E732E666F726D61747465723D3D3D21313F746869732E5F646973706C617954657874284D6174682E726F756E64286129293A';
wwv_flow_api.g_varchar2_table(399) := '746869732E5F646973706C61795465787428746869732E6F7074696F6E732E666F726D6174746572286129292C746869732E5F76616C75653D617D2C5F646973706C6179546578743A66756E6374696F6E2861297B746869732E5F76616C7565436F6E74';
wwv_flow_api.g_varchar2_table(400) := '61696E65722E746578742861297D2C5F746F67676C65436C6173733A66756E6374696F6E28297B746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D6C6566744C6162656C222C746869732E6F707469';
wwv_flow_api.g_varchar2_table(401) := '6F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C696465722D72696768744C6162656C222C21746869732E6F7074696F6E732E69734C656674297D2C5F706F736974696F6E4C6162656C733A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(402) := '297B746869732E5F706F736974696F6E6E65722E506F736974696F6E4C6162656C7328297D2C5F6D6F757365446F776E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D2C5F6D6F75736555';
wwv_flow_api.g_varchar2_table(403) := '703A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D2C5F6D6F7573654D6F76653A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D';
wwv_flow_api.g_varchar2_table(404) := '2C5F6F6E4D6F76696E673A66756E6374696F6E28612C62297B746869732E5F646973706C617928622E76616C7565297D2C5F6F6E5570646174653A66756E6374696F6E28297B2273686F77223D3D3D746869732E6F7074696F6E732E73686F7726267468';
wwv_flow_api.g_varchar2_table(405) := '69732E75706461746528297D2C5F6F6E5377697463683A66756E6374696F6E28612C62297B746869732E6F7074696F6E732E69734C6566743D622C746869732E5F746F67676C65436C61737328292C746869732E5F706F736974696F6E4C6162656C7328';
wwv_flow_api.g_varchar2_table(406) := '297D2C706169723A66756E6374696F6E2861297B6E756C6C3D3D3D746869732E5F706F736974696F6E6E6572262628746869732E5F706F736974696F6E6E65723D6E6577206328746869732E656C656D656E742C612C746869732E7769646765744E616D';
wwv_flow_api.g_varchar2_table(407) := '652C7B73686F773A746869732E6F7074696F6E732E73686F772C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A746869732E6F7074696F6E732E6475726174696F6E4F75742C6465';
wwv_flow_api.g_varchar2_table(408) := '6C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D292C615B746869732E7769646765744E616D655D2822706F736974696F6E6E6572222C746869732E5F706F736974696F6E6E657229297D2C706F736974696F6E6E65723A66756E';
wwv_flow_api.g_varchar2_table(409) := '6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869732E5F706F736974696F6E6E65723D61292C746869732E5F706F736974696F6E6E65727D2C7570646174653A66756E6374696F6E28297B746869';
wwv_flow_api.g_varchar2_table(410) := '732E5F706F736974696F6E6E65722E63616368653D6E756C6C2C746869732E5F646973706C617928746869732E5F68616E646C65282276616C75652229292C2273686F77223D3D3D746869732E6F7074696F6E732E73686F772626746869732E5F706F73';
wwv_flow_api.g_varchar2_table(411) := '6974696F6E4C6162656C7328297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E6461746552616E6765536C69646572222C612E75692E72616E6765536C696465722C';
wwv_flow_api.g_varchar2_table(412) := '7B6F7074696F6E733A7B626F756E64733A7B6D696E3A6E6577204461746528323031302C302C31292E76616C75654F6628292C6D61783A6E6577204461746528323031322C302C31292E76616C75654F6628297D2C64656661756C7456616C7565733A7B';
wwv_flow_api.g_varchar2_table(413) := '6D696E3A6E6577204461746528323031302C312C3131292E76616C75654F6628292C6D61783A6E6577204461746528323031312C312C3131292E76616C75654F6628297D7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E676553';
wwv_flow_api.g_varchar2_table(414) := '6C696465722E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E616464436C617373282275692D6461746552616E6765536C6964657222297D2C64657374726F793A66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(415) := '746869732E656C656D656E742E72656D6F7665436C617373282275692D6461746552616E6765536C6964657222292C612E75692E72616E6765536C696465722E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F73657444';
wwv_flow_api.g_varchar2_table(416) := '656661756C7456616C7565733A66756E6374696F6E28297B746869732E5F76616C7565733D7B6D696E3A746869732E6F7074696F6E732E64656661756C7456616C7565732E6D696E2E76616C75654F6628292C6D61783A746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(417) := '64656661756C7456616C7565732E6D61782E76616C75654F6628297D7D2C5F73657452756C6572506172616D65746572733A66756E6374696F6E28297B746869732E72756C65722E72756C6572287B6D696E3A6E6577204461746528746869732E6F7074';
wwv_flow_api.g_varchar2_table(418) := '696F6E732E626F756E64732E6D696E2E76616C75654F662829292C6D61783A6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829292C7363616C65733A746869732E6F7074696F6E732E7363616C65';
wwv_flow_api.g_varchar2_table(419) := '737D297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B282264656661756C7456616C756573223D3D3D627C7C22626F756E6473223D3D3D6229262622756E646566696E656422213D747970656F66206326266E756C6C213D3D632626';
wwv_flow_api.g_varchar2_table(420) := '746869732E5F697356616C69644461746528632E6D696E292626746869732E5F697356616C69644461746528632E6D6178293F612E75692E72616E6765536C696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C';
wwv_flow_api.g_varchar2_table(421) := '5B622C7B6D696E3A632E6D696E2E76616C75654F6628292C6D61783A632E6D61782E76616C75654F6628297D5D293A612E75692E72616E6765536C696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C74686973';
wwv_flow_api.g_varchar2_table(422) := '2E5F746F417272617928617267756D656E747329297D2C5F68616E646C65547970653A66756E6374696F6E28297B72657475726E226461746552616E6765536C6964657248616E646C65227D2C6F7074696F6E3A66756E6374696F6E2862297B69662822';
wwv_flow_api.g_varchar2_table(423) := '626F756E6473223D3D3D627C7C2264656661756C7456616C756573223D3D3D62297B76617220633D612E75692E72616E6765536C696465722E70726F746F747970652E6F7074696F6E2E6170706C7928746869732C617267756D656E7473293B72657475';
wwv_flow_api.g_varchar2_table(424) := '726E7B6D696E3A6E6577204461746528632E6D696E292C6D61783A6E6577204461746528632E6D6178297D7D72657475726E20612E75692E72616E6765536C696465722E70726F746F747970652E6F7074696F6E2E6170706C7928746869732C74686973';
wwv_flow_api.g_varchar2_table(425) := '2E5F746F417272617928617267756D656E747329297D2C5F64656661756C74466F726D61747465723A66756E6374696F6E2861297B76617220623D612E6765744D6F6E746828292B312C633D612E6765744461746528293B72657475726E22222B612E67';
wwv_flow_api.g_varchar2_table(426) := '657446756C6C5965617228292B222D222B2831303E623F2230222B623A62292B222D222B2831303E633F2230222B633A63297D2C5F676574466F726D61747465723A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E666F726D';
wwv_flow_api.g_varchar2_table(427) := '61747465723B72657475726E28746869732E6F7074696F6E732E666F726D61747465723D3D3D21317C7C6E756C6C3D3D3D746869732E6F7074696F6E732E666F726D617474657229262628613D746869732E5F64656661756C74466F726D617474657229';
wwv_flow_api.g_varchar2_table(428) := '2C66756E6374696F6E2861297B72657475726E2066756E6374696F6E2862297B72657475726E2061286E65772044617465286229297D7D2861297D2C76616C7565733A66756E6374696F6E28622C63297B76617220643D6E756C6C3B72657475726E2064';
wwv_flow_api.g_varchar2_table(429) := '3D746869732E5F697356616C6964446174652862292626746869732E5F697356616C6964446174652863293F612E75692E72616E6765536C696465722E70726F746F747970652E76616C7565732E6170706C7928746869732C5B622E76616C75654F6628';
wwv_flow_api.g_varchar2_table(430) := '292C632E76616C75654F6628295D293A612E75692E72616E6765536C696465722E70726F746F747970652E76616C7565732E6170706C7928746869732C746869732E5F746F417272617928617267756D656E747329292C7B6D696E3A6E65772044617465';
wwv_flow_api.g_varchar2_table(431) := '28642E6D696E292C6D61783A6E6577204461746528642E6D6178297D7D2C6D696E3A66756E6374696F6E2862297B72657475726E20746869732E5F697356616C6964446174652862293F6E6577204461746528612E75692E72616E6765536C696465722E';
wwv_flow_api.g_varchar2_table(432) := '70726F746F747970652E6D696E2E6170706C7928746869732C5B622E76616C75654F6628295D29293A6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D696E2E6170706C79287468697329297D2C6D61783A66';
wwv_flow_api.g_varchar2_table(433) := '756E6374696F6E2862297B72657475726E20746869732E5F697356616C6964446174652862293F6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D61782E6170706C7928746869732C5B622E76616C75654F66';
wwv_flow_api.g_varchar2_table(434) := '28295D29293A6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D61782E6170706C79287468697329297D2C626F756E64733A66756E6374696F6E28622C63297B76617220643B72657475726E20643D74686973';
wwv_flow_api.g_varchar2_table(435) := '2E5F697356616C6964446174652862292626746869732E5F697356616C6964446174652863293F612E75692E72616E6765536C696465722E70726F746F747970652E626F756E64732E6170706C7928746869732C5B622E76616C75654F6628292C632E76';
wwv_flow_api.g_varchar2_table(436) := '616C75654F6628295D293A612E75692E72616E6765536C696465722E70726F746F747970652E626F756E64732E6170706C7928746869732C746869732E5F746F417272617928617267756D656E747329292C7B6D696E3A6E6577204461746528642E6D69';
wwv_flow_api.g_varchar2_table(437) := '6E292C6D61783A6E6577204461746528642E6D6178297D7D2C5F697356616C6964446174653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F66206126266120696E7374616E63656F6620446174657D2C5F74';
wwv_flow_api.g_varchar2_table(438) := '6F41727261793A66756E6374696F6E2861297B72657475726E2041727261792E70726F746F747970652E736C6963652E63616C6C2861297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964';
wwv_flow_api.g_varchar2_table(439) := '676574282275692E6461746552616E6765536C6964657248616E646C65222C612E75692E72616E6765536C6964657248616E646C652C7B5F73746570733A21312C5F626F756E647356616C7565733A7B7D2C5F6372656174653A66756E6374696F6E2829';
wwv_flow_api.g_varchar2_table(440) := '7B746869732E5F637265617465426F756E647356616C75657328292C612E75692E72616E6765536C6964657248616E646C652E70726F746F747970652E5F6372656174652E6170706C792874686973297D2C5F67657456616C7565466F72506F73697469';
wwv_flow_api.g_varchar2_table(441) := '6F6E3A66756E6374696F6E2861297B76617220623D746869732E5F67657452617756616C7565466F72506F736974696F6E416E64426F756E647328612C746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C746869732E';
wwv_flow_api.g_varchar2_table(442) := '6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829293B72657475726E20746869732E5F636F6E73747261696E7456616C7565286E65772044617465286229297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B7265';
wwv_flow_api.g_varchar2_table(443) := '7475726E2273746570223D3D3D623F28746869732E6F7074696F6E732E737465703D632C746869732E5F637265617465537465707328292C766F696420746869732E7570646174652829293A28612E75692E72616E6765536C6964657248616E646C652E';
wwv_flow_api.g_varchar2_table(444) := '70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D292C766F69642822626F756E6473223D3D3D622626746869732E5F637265617465426F756E647356616C756573282929297D2C5F637265617465426F756E64';
wwv_flow_api.g_varchar2_table(445) := '7356616C7565733A66756E6374696F6E28297B746869732E5F626F756E647356616C7565733D7B6D696E3A746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C6D61783A746869732E6F7074696F6E732E626F756E6473';
wwv_flow_api.g_varchar2_table(446) := '2E6D61782E76616C75654F6628297D7D2C5F626F756E64733A66756E6374696F6E28297B72657475726E20746869732E5F626F756E647356616C7565737D2C5F63726561746553746570733A66756E6374696F6E28297B696628746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(447) := '6E732E737465703D3D3D21317C7C21746869732E5F697356616C69645374657028292972657475726E20766F696428746869732E5F73746570733D2131293B76617220613D6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D69';
wwv_flow_api.g_varchar2_table(448) := '6E2E76616C75654F662829292C623D6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829292C633D612C643D302C653D6E657720446174653B666F7228746869732E5F73746570733D5B5D3B623E3D';
wwv_flow_api.g_varchar2_table(449) := '63262628313D3D3D647C7C652E76616C75654F662829213D3D632E76616C75654F662829293B29653D632C746869732E5F73746570732E7075736828632E76616C75654F662829292C633D746869732E5F6164645374657028612C642C746869732E6F70';
wwv_flow_api.g_varchar2_table(450) := '74696F6E732E73746570292C642B2B3B652E76616C75654F6628293D3D3D632E76616C75654F662829262628746869732E5F73746570733D2131297D2C5F697356616C6964537465703A66756E6374696F6E28297B72657475726E226F626A656374223D';
wwv_flow_api.g_varchar2_table(451) := '3D747970656F6620746869732E6F7074696F6E732E737465707D2C5F616464537465703A66756E6374696F6E28612C622C63297B76617220643D6E6577204461746528612E76616C75654F662829293B72657475726E20643D746869732E5F6164645468';
wwv_flow_api.g_varchar2_table(452) := '696E6728642C2246756C6C59656172222C622C632E7965617273292C643D746869732E5F6164645468696E6728642C224D6F6E7468222C622C632E6D6F6E746873292C643D746869732E5F6164645468696E6728642C2244617465222C622C372A632E77';
wwv_flow_api.g_varchar2_table(453) := '65656B73292C643D746869732E5F6164645468696E6728642C2244617465222C622C632E64617973292C643D746869732E5F6164645468696E6728642C22486F757273222C622C632E686F757273292C643D746869732E5F6164645468696E6728642C22';
wwv_flow_api.g_varchar2_table(454) := '4D696E75746573222C622C632E6D696E75746573292C643D746869732E5F6164645468696E6728642C225365636F6E6473222C622C632E7365636F6E6473297D2C5F6164645468696E673A66756E6374696F6E28612C622C632C64297B72657475726E20';
wwv_flow_api.g_varchar2_table(455) := '303D3D3D637C7C303D3D3D28647C7C30293F613A28615B22736574222B625D28615B22676574222B625D28292B632A28647C7C3029292C61297D2C5F726F756E643A66756E6374696F6E2861297B696628746869732E5F73746570733D3D3D2131297265';
wwv_flow_api.g_varchar2_table(456) := '7475726E20613B666F722876617220622C632C643D746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F6628292C653D746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C663D4D6174682E6D61';
wwv_flow_api.g_varchar2_table(457) := '7828302C28612D65292F28642D6529292C673D4D6174682E666C6F6F7228746869732E5F73746570732E6C656E6774682A66293B746869732E5F73746570735B675D3E613B29672D2D3B666F72283B672B313C746869732E5F73746570732E6C656E6774';
wwv_flow_api.g_varchar2_table(458) := '682626746869732E5F73746570735B672B315D3C3D613B29672B2B3B72657475726E20673E3D746869732E5F73746570732E6C656E6774682D313F746869732E5F73746570735B746869732E5F73746570732E6C656E6774682D315D3A303D3D3D673F74';
wwv_flow_api.g_varchar2_table(459) := '6869732E5F73746570735B305D3A28623D746869732E5F73746570735B675D2C633D746869732E5F73746570735B672B315D2C632D613E612D623F623A63297D2C7570646174653A66756E6374696F6E28297B746869732E5F637265617465426F756E64';
wwv_flow_api.g_varchar2_table(460) := '7356616C75657328292C746869732E5F637265617465537465707328292C612E75692E72616E6765536C6964657248616E646C652E70726F746F747970652E7570646174652E6170706C792874686973297D2C6164643A66756E6374696F6E28612C6229';
wwv_flow_api.g_varchar2_table(461) := '7B72657475726E20746869732E5F61646453746570286E657720446174652861292C312C62292E76616C75654F6628297D2C7375627374726163743A66756E6374696F6E28612C62297B72657475726E20746869732E5F61646453746570286E65772044';
wwv_flow_api.g_varchar2_table(462) := '6174652861292C2D312C62292E76616C75654F6628297D2C73746570734265747765656E3A66756E6374696F6E28612C62297B696628746869732E6F7074696F6E732E737465703D3D3D21312972657475726E20622D613B76617220633D4D6174682E6D';
wwv_flow_api.g_varchar2_table(463) := '696E28612C62292C643D4D6174682E6D617828612C62292C653D302C663D21312C673D613E623B666F7228746869732E61646428632C746869732E6F7074696F6E732E73746570292D633C30262628663D2130293B643E633B29663F643D746869732E61';
wwv_flow_api.g_varchar2_table(464) := '646428642C746869732E6F7074696F6E732E73746570293A633D746869732E61646428632C746869732E6F7074696F6E732E73746570292C652B2B3B72657475726E20673F2D653A657D2C6D756C7469706C79537465703A66756E6374696F6E28612C62';
wwv_flow_api.g_varchar2_table(465) := '297B76617220633D7B7D3B666F7228766172206420696E206129612E6861734F776E50726F7065727479286429262628635B645D3D615B645D2A62293B72657475726E20637D2C73746570526174696F3A66756E6374696F6E28297B696628746869732E';
wwv_flow_api.g_varchar2_table(466) := '6F7074696F6E732E737465703D3D3D21312972657475726E20313B76617220613D746869732E5F73746570732E6C656E6774683B72657475726E20746869732E63616368652E706172656E742E77696474682F617D7D297D286A5175657279292C66756E';
wwv_flow_api.g_varchar2_table(467) := '6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E6564697452616E6765536C69646572222C612E75692E72616E6765536C696465722C7B6F7074696F6E733A7B747970653A2274657874222C726F756E643A31';
wwv_flow_api.g_varchar2_table(468) := '7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465722E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E616464436C617373282275692D656469745261';
wwv_flow_api.g_varchar2_table(469) := '6E6765536C6964657222297D2C64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C617373282275692D6564697452616E6765536C6964657222292C612E75692E72616E6765536C696465722E70726F74';
wwv_flow_api.g_varchar2_table(470) := '6F747970652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B282274797065223D3D3D627C7C2273746570223D3D3D62292626746869732E5F7365744C6162656C4F7074696F6E2862';
wwv_flow_api.g_varchar2_table(471) := '2C63292C2274797065223D3D3D62262628746869732E6F7074696F6E735B625D3D6E756C6C3D3D3D746869732E6C6162656C732E6C6566743F633A746869732E5F6C6566744C6162656C28226F7074696F6E222C6229292C612E75692E72616E6765536C';
wwv_flow_api.g_varchar2_table(472) := '696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D2C5F7365744C6162656C4F7074696F6E3A66756E6374696F6E28612C62297B6E756C6C213D3D746869732E6C6162656C732E6C6566742626';
wwv_flow_api.g_varchar2_table(473) := '28746869732E5F6C6566744C6162656C28226F7074696F6E222C612C62292C746869732E5F72696768744C6162656C28226F7074696F6E222C612C6229297D2C5F6C6162656C547970653A66756E6374696F6E28297B72657475726E226564697452616E';
wwv_flow_api.g_varchar2_table(474) := '6765536C696465724C6162656C227D2C5F6372656174654C6162656C3A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6372656174654C6162656C2E6170706C7928746869732C';
wwv_flow_api.g_varchar2_table(475) := '5B622C635D293B72657475726E206E756C6C3D3D3D622626642E62696E64282276616C75654368616E6765222C612E70726F787928746869732E5F6F6E56616C75654368616E67652C7468697329292C647D2C5F61646450726F70657274696573546F50';
wwv_flow_api.g_varchar2_table(476) := '6172616D657465723A66756E6374696F6E2861297B72657475726E20612E747970653D746869732E6F7074696F6E732E747970652C612E737465703D746869732E6F7074696F6E732E737465702C612E69643D746869732E656C656D656E742E61747472';
wwv_flow_api.g_varchar2_table(477) := '2822696422292C617D2C5F6765744C6162656C436F6E7374727563746F72506172616D65746572733A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6765744C6162656C436F6E';
wwv_flow_api.g_varchar2_table(478) := '7374727563746F72506172616D65746572732E6170706C7928746869732C5B622C635D293B72657475726E20746869732E5F61646450726F70657274696573546F506172616D657465722864297D2C5F6765744C6162656C52656672657368506172616D';
wwv_flow_api.g_varchar2_table(479) := '65746572733A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6765744C6162656C52656672657368506172616D65746572732E6170706C7928746869732C5B622C635D293B7265';
wwv_flow_api.g_varchar2_table(480) := '7475726E20746869732E5F61646450726F70657274696573546F506172616D657465722864297D2C5F6F6E56616C75654368616E67653A66756E6374696F6E28612C62297B76617220633D21313B633D622E69734C6566743F746869732E5F76616C7565';
wwv_flow_api.g_varchar2_table(481) := '732E6D696E213D3D746869732E6D696E28622E76616C7565293A746869732E5F76616C7565732E6D6178213D3D746869732E6D617828622E76616C7565292C632626746869732E5F7472696767657228227573657256616C7565734368616E6765642229';
wwv_flow_api.g_varchar2_table(482) := '7D7D297D286A5175657279292C66756E6374696F6E2861297B2275736520737472696374223B612E776964676574282275692E6564697452616E6765536C696465724C6162656C222C612E75692E72616E6765536C696465724C6162656C2C7B6F707469';
wwv_flow_api.g_varchar2_table(483) := '6F6E733A7B747970653A2274657874222C737465703A21312C69643A22227D2C5F696E7075743A6E756C6C2C5F746578743A22222C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465724C6162656C2E70726F746F74';
wwv_flow_api.g_varchar2_table(484) := '7970652E5F6372656174652E6170706C792874686973292C746869732E5F637265617465496E70757428297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B2274797065223D3D3D623F746869732E5F736574547970654F7074696F6E';
wwv_flow_api.g_varchar2_table(485) := '2863293A2273746570223D3D3D622626746869732E5F736574537465704F7074696F6E2863292C612E75692E72616E6765536C696465724C6162656C2E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D';
wwv_flow_api.g_varchar2_table(486) := '2C5F637265617465496E7075743A66756E6374696F6E28297B746869732E5F696E7075743D6128223C696E70757420747970653D27222B746869732E6F7074696F6E732E747970652B2227202F3E22292E616464436C617373282275692D656469745261';
wwv_flow_api.g_varchar2_table(487) := '6E6765536C696465722D696E70757456616C756522292E617070656E64546F28746869732E5F76616C7565436F6E7461696E6572292C746869732E5F736574496E7075744E616D6528292C746869732E5F696E7075742E62696E6428226B65797570222C';
wwv_flow_api.g_varchar2_table(488) := '612E70726F787928746869732E5F6F6E4B657955702C7468697329292C746869732E5F696E7075742E626C757228612E70726F787928746869732E5F6F6E4368616E67652C7468697329292C226E756D626572223D3D3D746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(489) := '74797065262628746869732E6F7074696F6E732E73746570213D3D21312626746869732E5F696E7075742E61747472282273746570222C746869732E6F7074696F6E732E73746570292C746869732E5F696E7075742E636C69636B28612E70726F787928';
wwv_flow_api.g_varchar2_table(490) := '746869732E5F6F6E4368616E67652C746869732929292C746869732E5F696E7075742E76616C28746869732E5F74657874297D2C5F736574496E7075744E616D653A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(491) := '66743F226C656674223A227269676874223B746869732E5F696E7075742E6174747228226E616D65222C746869732E6F7074696F6E732E69642B61297D2C5F6F6E5377697463683A66756E6374696F6E28622C63297B612E75692E72616E6765536C6964';
wwv_flow_api.g_varchar2_table(492) := '65724C6162656C2E70726F746F747970652E5F6F6E5377697463682E6170706C7928746869732C5B622C635D292C746869732E5F736574496E7075744E616D6528297D2C5F64657374726F79496E7075743A66756E6374696F6E28297B746869732E5F69';
wwv_flow_api.g_varchar2_table(493) := '6E7075742E72656D6F766528292C746869732E5F696E7075743D6E756C6C7D2C5F6F6E4B657955703A66756E6374696F6E2861297B72657475726E2031333D3D3D612E77686963683F28746869732E5F6F6E4368616E67652861292C2131293A766F6964';
wwv_flow_api.g_varchar2_table(494) := '20307D2C5F6F6E4368616E67653A66756E6374696F6E28297B76617220613D746869732E5F72657475726E436865636B656456616C756528746869732E5F696E7075742E76616C2829293B61213D3D21312626746869732E5F7472696767657256616C75';
wwv_flow_api.g_varchar2_table(495) := '652861297D2C5F7472696767657256616C75653A66756E6374696F6E2861297B76617220623D746869732E6F7074696F6E732E68616E646C655B746869732E6F7074696F6E732E68616E646C65547970655D28226F7074696F6E222C2269734C65667422';
wwv_flow_api.g_varchar2_table(496) := '293B746869732E656C656D656E742E74726967676572282276616C75654368616E6765222C5B7B69734C6566743A622C76616C75653A617D5D297D2C5F72657475726E436865636B656456616C75653A66756E6374696F6E2861297B76617220623D7061';
wwv_flow_api.g_varchar2_table(497) := '727365466C6F61742861293B72657475726E2069734E614E2862297C7C69734E614E284E756D626572286129293F21313A627D2C5F736574547970654F7074696F6E3A66756E6374696F6E2861297B227465787422213D3D612626226E756D6265722221';
wwv_flow_api.g_varchar2_table(498) := '3D3D617C7C746869732E6F7074696F6E732E747970653D3D3D617C7C28746869732E5F64657374726F79496E70757428292C746869732E6F7074696F6E732E747970653D612C746869732E5F637265617465496E7075742829297D2C5F73657453746570';
wwv_flow_api.g_varchar2_table(499) := '4F7074696F6E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E737465703D612C226E756D626572223D3D3D746869732E6F7074696F6E732E747970652626746869732E5F696E7075742E61747472282273746570222C61213D3D21313F';
wwv_flow_api.g_varchar2_table(500) := '613A22616E7922297D2C5F646973706C6179546578743A66756E6374696F6E2861297B746869732E5F696E7075742E76616C2861292C746869732E5F746578743D617D2C656E61626C653A66756E6374696F6E28297B612E75692E72616E6765536C6964';
wwv_flow_api.g_varchar2_table(501) := '65724C6162656C2E70726F746F747970652E656E61626C652E6170706C792874686973292C746869732E5F696E7075742E61747472282264697361626C6564222C6E756C6C297D2C64697361626C653A66756E6374696F6E28297B612E75692E72616E67';
wwv_flow_api.g_varchar2_table(502) := '65536C696465724C6162656C2E70726F746F747970652E64697361626C652E6170706C792874686973292C746869732E5F696E7075742E61747472282264697361626C6564222C2264697361626C656422297D7D297D286A5175657279293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(93701626751879984836)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'jQAllRangeSliders-min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A21206A5152616E6765536C6964657220352E372E32202D20323031362D30312D3138202D20436F7079726967687420284329204775696C6C61756D652047617574726561752032303132202D204D495420616E642047504C7633206C6963656E7365';
wwv_flow_api.g_varchar2_table(2) := '732E2A2F2166756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C696465724D6F757365546F756368222C612E75692E6D6F7573652C7B656E61626C65643A21302C5F6D6F757365496E69';
wwv_flow_api.g_varchar2_table(3) := '743A66756E6374696F6E28297B76617220623D746869733B612E75692E6D6F7573652E70726F746F747970652E5F6D6F757365496E69742E6170706C792874686973292C746869732E5F6D6F757365446F776E4576656E743D21312C746869732E656C65';
wwv_flow_api.g_varchar2_table(4) := '6D656E742E62696E642822746F75636873746172742E222B746869732E7769646765744E616D652C66756E6374696F6E2861297B72657475726E20622E5F746F75636853746172742861297D297D2C5F6D6F75736544657374726F793A66756E6374696F';
wwv_flow_api.g_varchar2_table(5) := '6E28297B6128646F63756D656E74292E756E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F7563684D6F766544656C6567617465292E756E62696E642822746F756368656E642E222B74686973';
wwv_flow_api.g_varchar2_table(6) := '2E7769646765744E616D652C746869732E5F746F756368456E6444656C6567617465292C612E75692E6D6F7573652E70726F746F747970652E5F6D6F75736544657374726F792E6170706C792874686973297D2C656E61626C653A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(7) := '297B746869732E656E61626C65643D21307D2C64697361626C653A66756E6374696F6E28297B746869732E656E61626C65643D21317D2C64657374726F793A66756E6374696F6E28297B746869732E5F6D6F75736544657374726F7928292C612E75692E';
wwv_flow_api.g_varchar2_table(8) := '6D6F7573652E70726F746F747970652E64657374726F792E6170706C792874686973292C746869732E5F6D6F757365496E69743D6E756C6C7D2C5F746F75636853746172743A66756E6374696F6E2862297B69662821746869732E656E61626C65642972';
wwv_flow_api.g_varchar2_table(9) := '657475726E21313B622E77686963683D312C622E70726576656E7444656661756C7428292C746869732E5F66696C6C546F7563684576656E742862293B76617220633D746869732C643D746869732E5F6D6F757365446F776E4576656E743B746869732E';
wwv_flow_api.g_varchar2_table(10) := '5F6D6F757365446F776E2862292C64213D3D746869732E5F6D6F757365446F776E4576656E74262628746869732E5F746F756368456E6444656C65676174653D66756E6374696F6E2861297B632E5F746F756368456E642861297D2C746869732E5F746F';
wwv_flow_api.g_varchar2_table(11) := '7563684D6F766544656C65676174653D66756E6374696F6E2861297B632E5F746F7563684D6F76652861297D2C6128646F63756D656E74292E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F75';
wwv_flow_api.g_varchar2_table(12) := '63684D6F766544656C6567617465292E62696E642822746F756368656E642E222B746869732E7769646765744E616D652C746869732E5F746F756368456E6444656C656761746529297D2C5F6D6F757365446F776E3A66756E6374696F6E2862297B7265';
wwv_flow_api.g_varchar2_table(13) := '7475726E20746869732E656E61626C65643F612E75692E6D6F7573652E70726F746F747970652E5F6D6F757365446F776E2E6170706C7928746869732C5B625D293A21317D2C5F746F756368456E643A66756E6374696F6E2862297B746869732E5F6669';
wwv_flow_api.g_varchar2_table(14) := '6C6C546F7563684576656E742862292C746869732E5F6D6F75736555702862292C6128646F63756D656E74292E756E62696E642822746F7563686D6F76652E222B746869732E7769646765744E616D652C746869732E5F746F7563684D6F766544656C65';
wwv_flow_api.g_varchar2_table(15) := '67617465292E756E62696E642822746F756368656E642E222B746869732E7769646765744E616D652C746869732E5F746F756368456E6444656C6567617465292C746869732E5F6D6F757365446F776E4576656E743D21312C6128646F63756D656E7429';
wwv_flow_api.g_varchar2_table(16) := '2E7472696767657228226D6F757365757022297D2C5F746F7563684D6F76653A66756E6374696F6E2861297B72657475726E20612E70726576656E7444656661756C7428292C746869732E5F66696C6C546F7563684576656E742861292C746869732E5F';
wwv_flow_api.g_varchar2_table(17) := '6D6F7573654D6F76652861297D2C5F66696C6C546F7563684576656E743A66756E6374696F6E2861297B76617220623B623D22756E646566696E6564223D3D747970656F6620612E746172676574546F7563686573262622756E646566696E6564223D3D';
wwv_flow_api.g_varchar2_table(18) := '747970656F6620612E6368616E676564546F75636865733F612E6F726967696E616C4576656E742E746172676574546F75636865735B305D7C7C612E6F726967696E616C4576656E742E6368616E676564546F75636865735B305D3A612E746172676574';
wwv_flow_api.g_varchar2_table(19) := '546F75636865735B305D7C7C612E6368616E676564546F75636865735B305D2C612E70616765583D622E70616765582C612E70616765593D622E70616765592C612E77686963683D317D7D297D286A5175657279292C66756E6374696F6E28612C62297B';
wwv_flow_api.g_varchar2_table(20) := '2275736520737472696374223B612E776964676574282275692E72616E6765536C69646572447261676761626C65222C612E75692E72616E6765536C696465724D6F757365546F7563682C7B63616368653A6E756C6C2C6F7074696F6E733A7B636F6E74';
wwv_flow_api.g_varchar2_table(21) := '61696E6D656E743A6E756C6C7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465724D6F757365546F7563682E70726F746F747970652E5F6372656174652E6170706C792874686973292C73657454696D656F7574';
wwv_flow_api.g_varchar2_table(22) := '28612E70726F787928746869732E5F696E6974456C656D656E7449664E6F7444657374726F7965642C74686973292C3130297D2C64657374726F793A66756E6374696F6E28297B746869732E63616368653D6E756C6C2C612E75692E72616E6765536C69';
wwv_flow_api.g_varchar2_table(23) := '6465724D6F757365546F7563682E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F696E6974456C656D656E7449664E6F7444657374726F7965643A66756E6374696F6E28297B746869732E5F6D6F757365496E69742626';
wwv_flow_api.g_varchar2_table(24) := '746869732E5F696E6974456C656D656E7428297D2C5F696E6974456C656D656E743A66756E6374696F6E28297B746869732E5F6D6F757365496E697428292C746869732E5F636163686528297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C';
wwv_flow_api.g_varchar2_table(25) := '63297B22636F6E7461696E6D656E74223D3D3D622626286E756C6C3D3D3D637C7C303D3D3D612863292E6C656E6774683F746869732E6F7074696F6E732E636F6E7461696E6D656E743D6E756C6C3A746869732E6F7074696F6E732E636F6E7461696E6D';
wwv_flow_api.g_varchar2_table(26) := '656E743D61286329297D2C5F6D6F75736553746172743A66756E6374696F6E2861297B72657475726E20746869732E5F636163686528292C746869732E63616368652E636C69636B3D7B6C6566743A612E70616765582C746F703A612E70616765597D2C';
wwv_flow_api.g_varchar2_table(27) := '746869732E63616368652E696E697469616C4F66667365743D746869732E656C656D656E742E6F666673657428292C746869732E5F747269676765724D6F7573654576656E7428226D6F757365737461727422292C21307D2C5F6D6F757365447261673A';
wwv_flow_api.g_varchar2_table(28) := '66756E6374696F6E2861297B76617220623D612E70616765582D746869732E63616368652E636C69636B2E6C6566743B72657475726E20623D746869732E5F636F6E73747261696E74506F736974696F6E28622B746869732E63616368652E696E697469';
wwv_flow_api.g_varchar2_table(29) := '616C4F66667365742E6C656674292C746869732E5F6170706C79506F736974696F6E2862292C746869732E5F747269676765724D6F7573654576656E742822736C696465724472616722292C21317D2C5F6D6F75736553746F703A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(30) := '297B746869732E5F747269676765724D6F7573654576656E74282273746F7022297D2C5F636F6E73747261696E74506F736974696F6E3A66756E6374696F6E2861297B72657475726E2030213D3D746869732E656C656D656E742E706172656E7428292E';
wwv_flow_api.g_varchar2_table(31) := '6C656E67746826266E756C6C213D3D746869732E63616368652E706172656E742E6F6666736574262628613D4D6174682E6D696E28612C746869732E63616368652E706172656E742E6F66667365742E6C6566742B746869732E63616368652E70617265';
wwv_flow_api.g_varchar2_table(32) := '6E742E77696474682D746869732E63616368652E77696474682E6F75746572292C613D4D6174682E6D617828612C746869732E63616368652E706172656E742E6F66667365742E6C65667429292C617D2C5F6170706C79506F736974696F6E3A66756E63';
wwv_flow_api.g_varchar2_table(33) := '74696F6E2861297B746869732E5F636163686549664E656365737361727928293B76617220623D7B746F703A746869732E63616368652E6F66667365742E746F702C6C6566743A617D3B746869732E656C656D656E742E6F6666736574287B6C6566743A';
wwv_flow_api.g_varchar2_table(34) := '617D292C746869732E63616368652E6F66667365743D627D2C5F636163686549664E65636573736172793A66756E6374696F6E28297B6E756C6C3D3D3D746869732E63616368652626746869732E5F636163686528297D2C5F63616368653A66756E6374';
wwv_flow_api.g_varchar2_table(35) := '696F6E28297B746869732E63616368653D7B7D2C746869732E5F63616368654D617267696E7328292C746869732E5F6361636865506172656E7428292C746869732E5F636163686544696D656E73696F6E7328292C746869732E63616368652E6F666673';
wwv_flow_api.g_varchar2_table(36) := '65743D746869732E656C656D656E742E6F666673657428297D2C5F63616368654D617267696E733A66756E6374696F6E28297B746869732E63616368652E6D617267696E3D7B6C6566743A746869732E5F7061727365506978656C7328746869732E656C';
wwv_flow_api.g_varchar2_table(37) := '656D656E742C226D617267696E4C65667422292C72696768743A746869732E5F7061727365506978656C7328746869732E656C656D656E742C226D617267696E526967687422292C746F703A746869732E5F7061727365506978656C7328746869732E65';
wwv_flow_api.g_varchar2_table(38) := '6C656D656E742C226D617267696E546F7022292C626F74746F6D3A746869732E5F7061727365506978656C7328746869732E656C656D656E742C226D617267696E426F74746F6D22297D7D2C5F6361636865506172656E743A66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(39) := '6966286E756C6C213D3D746869732E6F7074696F6E732E706172656E74297B76617220613D746869732E656C656D656E742E706172656E7428293B746869732E63616368652E706172656E743D7B6F66667365743A612E6F666673657428292C77696474';
wwv_flow_api.g_varchar2_table(40) := '683A612E776964746828297D7D656C736520746869732E63616368652E706172656E743D6E756C6C7D2C5F636163686544696D656E73696F6E733A66756E6374696F6E28297B746869732E63616368652E77696474683D7B6F757465723A746869732E65';
wwv_flow_api.g_varchar2_table(41) := '6C656D656E742E6F75746572576964746828292C696E6E65723A746869732E656C656D656E742E776964746828297D7D2C5F7061727365506978656C733A66756E6374696F6E28612C62297B72657475726E207061727365496E7428612E637373286229';
wwv_flow_api.g_varchar2_table(42) := '2C3130297C7C307D2C5F747269676765724D6F7573654576656E743A66756E6374696F6E2861297B76617220623D746869732E5F707265706172654576656E744461746128293B746869732E656C656D656E742E7472696767657228612C62297D2C5F70';
wwv_flow_api.g_varchar2_table(43) := '7265706172654576656E74446174613A66756E6374696F6E28297B72657475726E7B656C656D656E743A746869732E656C656D656E742C6F66667365743A746869732E63616368652E6F66667365747C7C6E756C6C7D7D7D297D286A5175657279292C66';
wwv_flow_api.g_varchar2_table(44) := '756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C69646572222C7B6F7074696F6E733A7B626F756E64733A7B6D696E3A302C6D61783A3130307D2C64656661756C7456616C7565733A7B';
wwv_flow_api.g_varchar2_table(45) := '6D696E3A32302C6D61783A35307D2C776865656C4D6F64653A6E756C6C2C776865656C53706565643A342C6172726F77733A21302C76616C75654C6162656C733A2273686F77222C666F726D61747465723A6E756C6C2C6475726174696F6E496E3A302C';
wwv_flow_api.g_varchar2_table(46) := '6475726174696F6E4F75743A3430302C64656C61794F75743A3230302C72616E67653A7B6D696E3A21312C6D61783A21317D2C737465703A21312C7363616C65733A21312C656E61626C65643A21302C73796D6D6574726963506F736974696F6E6E696E';
wwv_flow_api.g_varchar2_table(47) := '673A21317D2C5F76616C7565733A6E756C6C2C5F76616C7565734368616E6765643A21312C5F696E697469616C697A65643A21312C6261723A6E756C6C2C6C65667448616E646C653A6E756C6C2C726967687448616E646C653A6E756C6C2C696E6E6572';
wwv_flow_api.g_varchar2_table(48) := '4261723A6E756C6C2C636F6E7461696E65723A6E756C6C2C6172726F77733A6E756C6C2C6C6162656C733A6E756C6C2C6368616E67696E673A7B6D696E3A21312C6D61783A21317D2C6368616E6765643A7B6D696E3A21312C6D61783A21317D2C72756C';
wwv_flow_api.g_varchar2_table(49) := '65723A6E756C6C2C5F6372656174653A66756E6374696F6E28297B746869732E5F73657444656661756C7456616C75657328292C746869732E6C6162656C733D7B6C6566743A6E756C6C2C72696768743A6E756C6C2C6C656674446973706C617965643A';
wwv_flow_api.g_varchar2_table(50) := '21302C7269676874446973706C617965643A21307D2C746869732E6172726F77733D7B6C6566743A6E756C6C2C72696768743A6E756C6C7D2C746869732E6368616E67696E673D7B6D696E3A21312C6D61783A21317D2C746869732E6368616E6765643D';
wwv_flow_api.g_varchar2_table(51) := '7B6D696E3A21312C6D61783A21317D2C746869732E5F637265617465456C656D656E747328292C746869732E5F62696E64526573697A6528292C73657454696D656F757428612E70726F787928746869732E726573697A652C74686973292C31292C7365';
wwv_flow_api.g_varchar2_table(52) := '7454696D656F757428612E70726F787928746869732E5F696E697456616C7565732C74686973292C31297D2C5F73657444656661756C7456616C7565733A66756E6374696F6E28297B746869732E5F76616C7565733D7B6D696E3A746869732E6F707469';
wwv_flow_api.g_varchar2_table(53) := '6F6E732E64656661756C7456616C7565732E6D696E2C6D61783A746869732E6F7074696F6E732E64656661756C7456616C7565732E6D61787D7D2C5F62696E64526573697A653A66756E6374696F6E28297B76617220623D746869733B746869732E5F72';
wwv_flow_api.g_varchar2_table(54) := '6573697A6550726F78793D66756E6374696F6E2861297B622E726573697A652861297D2C612877696E646F77292E726573697A6528746869732E5F726573697A6550726F7879297D2C5F696E697457696474683A66756E6374696F6E28297B746869732E';
wwv_flow_api.g_varchar2_table(55) := '636F6E7461696E65722E63737328227769647468222C746869732E656C656D656E742E776964746828292D746869732E636F6E7461696E65722E6F757465725769647468282130292B746869732E636F6E7461696E65722E77696474682829292C746869';
wwv_flow_api.g_varchar2_table(56) := '732E696E6E65724261722E63737328227769647468222C746869732E636F6E7461696E65722E776964746828292D746869732E696E6E65724261722E6F757465725769647468282130292B746869732E696E6E65724261722E77696474682829297D2C5F';
wwv_flow_api.g_varchar2_table(57) := '696E697456616C7565733A66756E6374696F6E28297B746869732E5F696E697469616C697A65643D21302C746869732E76616C75657328746869732E5F76616C7565732E6D696E2C746869732E5F76616C7565732E6D6178297D2C5F7365744F7074696F';
wwv_flow_api.g_varchar2_table(58) := '6E3A66756E6374696F6E28612C62297B746869732E5F736574576865656C4F7074696F6E28612C62292C746869732E5F7365744172726F77734F7074696F6E28612C62292C746869732E5F7365744C6162656C734F7074696F6E28612C62292C74686973';
wwv_flow_api.g_varchar2_table(59) := '2E5F7365744C6162656C734475726174696F6E7328612C62292C746869732E5F736574466F726D61747465724F7074696F6E28612C62292C746869732E5F736574426F756E64734F7074696F6E28612C62292C746869732E5F73657452616E67654F7074';
wwv_flow_api.g_varchar2_table(60) := '696F6E28612C62292C746869732E5F736574537465704F7074696F6E28612C62292C746869732E5F7365745363616C65734F7074696F6E28612C62292C746869732E5F736574456E61626C65644F7074696F6E28612C62292C746869732E5F736574506F';
wwv_flow_api.g_varchar2_table(61) := '736974696F6E6E696E674F7074696F6E28612C62297D2C5F76616C696450726F70657274793A66756E6374696F6E28612C622C63297B72657475726E206E756C6C3D3D3D617C7C22756E646566696E6564223D3D747970656F6620615B625D3F633A615B';
wwv_flow_api.g_varchar2_table(62) := '625D7D2C5F736574537465704F7074696F6E3A66756E6374696F6E28612C62297B2273746570223D3D3D61262628746869732E6F7074696F6E732E737465703D622C746869732E5F6C65667448616E646C6528226F7074696F6E222C2273746570222C62';
wwv_flow_api.g_varchar2_table(63) := '292C746869732E5F726967687448616E646C6528226F7074696F6E222C2273746570222C62292C746869732E5F6368616E67656428213029297D2C5F7365745363616C65734F7074696F6E3A66756E6374696F6E28612C62297B227363616C6573223D3D';
wwv_flow_api.g_varchar2_table(64) := '3D61262628623D3D3D21317C7C6E756C6C3D3D3D623F28746869732E6F7074696F6E732E7363616C65733D21312C746869732E5F64657374726F7952756C65722829293A6220696E7374616E63656F66204172726179262628746869732E6F7074696F6E';
wwv_flow_api.g_varchar2_table(65) := '732E7363616C65733D622C746869732E5F75706461746552756C6572282929297D2C5F73657452616E67654F7074696F6E3A66756E6374696F6E28612C62297B2272616E6765223D3D3D61262628746869732E5F62617228226F7074696F6E222C227261';
wwv_flow_api.g_varchar2_table(66) := '6E6765222C62292C746869732E6F7074696F6E732E72616E67653D746869732E5F62617228226F7074696F6E222C2272616E676522292C746869732E5F6368616E67656428213029297D2C5F736574426F756E64734F7074696F6E3A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(67) := '28612C62297B22626F756E6473223D3D3D61262622756E646566696E656422213D747970656F6620622E6D696E262622756E646566696E656422213D747970656F6620622E6D61782626746869732E626F756E647328622E6D696E2C622E6D6178297D2C';
wwv_flow_api.g_varchar2_table(68) := '5F736574576865656C4F7074696F6E3A66756E6374696F6E28612C62297B2822776865656C4D6F6465223D3D3D617C7C22776865656C5370656564223D3D3D6129262628746869732E5F62617228226F7074696F6E222C612C62292C746869732E6F7074';
wwv_flow_api.g_varchar2_table(69) := '696F6E735B615D3D746869732E5F62617228226F7074696F6E222C6129297D2C5F7365744C6162656C734F7074696F6E3A66756E6374696F6E28612C62297B6966282276616C75654C6162656C73223D3D3D61297B696628226869646522213D3D622626';
wwv_flow_api.g_varchar2_table(70) := '2273686F7722213D3D622626226368616E676522213D3D622972657475726E3B746869732E6F7074696F6E732E76616C75654C6162656C733D622C226869646522213D3D623F28746869732E5F6372656174654C6162656C7328292C746869732E5F6C65';
wwv_flow_api.g_varchar2_table(71) := '66744C6162656C282275706461746522292C746869732E5F72696768744C6162656C28227570646174652229293A746869732E5F64657374726F794C6162656C7328297D7D2C5F736574466F726D61747465724F7074696F6E3A66756E6374696F6E2861';
wwv_flow_api.g_varchar2_table(72) := '2C62297B22666F726D6174746572223D3D3D6126266E756C6C213D3D6226262266756E6374696F6E223D3D747970656F6620622626226869646522213D3D746869732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C';
wwv_flow_api.g_varchar2_table(73) := '6162656C28226F7074696F6E222C22666F726D6174746572222C62292C746869732E6F7074696F6E732E666F726D61747465723D746869732E5F72696768744C6162656C28226F7074696F6E222C22666F726D6174746572222C6229297D2C5F73657441';
wwv_flow_api.g_varchar2_table(74) := '72726F77734F7074696F6E3A66756E6374696F6E28612C62297B226172726F777322213D3D617C7C62213D3D2130262662213D3D21317C7C623D3D3D746869732E6F7074696F6E732E6172726F77737C7C28623D3D3D21303F28746869732E656C656D65';
wwv_flow_api.g_varchar2_table(75) := '6E742E72656D6F7665436C617373282275692D72616E6765536C696465722D6E6F4172726F7722292E616464436C617373282275692D72616E6765536C696465722D776974684172726F777322292C746869732E6172726F77732E6C6566742E63737328';
wwv_flow_api.g_varchar2_table(76) := '22646973706C6179222C22626C6F636B22292C746869732E6172726F77732E72696768742E6373732822646973706C6179222C22626C6F636B22292C746869732E6F7074696F6E732E6172726F77733D2130293A623D3D3D2131262628746869732E656C';
wwv_flow_api.g_varchar2_table(77) := '656D656E742E616464436C617373282275692D72616E6765536C696465722D6E6F4172726F7722292E72656D6F7665436C617373282275692D72616E6765536C696465722D776974684172726F777322292C746869732E6172726F77732E6C6566742E63';
wwv_flow_api.g_varchar2_table(78) := '73732822646973706C6179222C226E6F6E6522292C746869732E6172726F77732E72696768742E6373732822646973706C6179222C226E6F6E6522292C746869732E6F7074696F6E732E6172726F77733D2131292C746869732E5F696E69745769647468';
wwv_flow_api.g_varchar2_table(79) := '2829297D2C5F7365744C6162656C734475726174696F6E733A66756E6374696F6E28612C62297B696628226475726174696F6E496E223D3D3D617C7C226475726174696F6E4F7574223D3D3D617C7C2264656C61794F7574223D3D3D61297B6966287061';
wwv_flow_api.g_varchar2_table(80) := '727365496E7428622C313029213D3D622972657475726E3B6E756C6C213D3D746869732E6C6162656C732E6C6566742626746869732E5F6C6566744C6162656C28226F7074696F6E222C612C62292C6E756C6C213D3D746869732E6C6162656C732E7269';
wwv_flow_api.g_varchar2_table(81) := '6768742626746869732E5F72696768744C6162656C28226F7074696F6E222C612C62292C746869732E6F7074696F6E735B615D3D627D7D2C5F736574456E61626C65644F7074696F6E3A66756E6374696F6E28612C62297B22656E61626C6564223D3D3D';
wwv_flow_api.g_varchar2_table(82) := '612626746869732E746F67676C652862297D2C5F736574506F736974696F6E6E696E674F7074696F6E3A66756E6374696F6E28612C62297B2273796D6D6574726963506F736974696F6E6E696E67223D3D3D61262628746869732E5F726967687448616E';
wwv_flow_api.g_varchar2_table(83) := '646C6528226F7074696F6E222C612C62292C746869732E6F7074696F6E735B615D3D746869732E5F6C65667448616E646C6528226F7074696F6E222C612C6229297D2C5F637265617465456C656D656E74733A66756E6374696F6E28297B226162736F6C';
wwv_flow_api.g_varchar2_table(84) := '75746522213D3D746869732E656C656D656E742E6373732822706F736974696F6E22292626746869732E656C656D656E742E6373732822706F736974696F6E222C2272656C617469766522292C746869732E656C656D656E742E616464436C6173732822';
wwv_flow_api.g_varchar2_table(85) := '75692D72616E6765536C6964657222292C746869732E636F6E7461696E65723D6128223C64697620636C6173733D2775692D72616E6765536C696465722D636F6E7461696E657227202F3E22292E6373732822706F736974696F6E222C226162736F6C75';
wwv_flow_api.g_varchar2_table(86) := '746522292E617070656E64546F28746869732E656C656D656E74292C746869732E696E6E65724261723D6128223C64697620636C6173733D2775692D72616E6765536C696465722D696E6E657242617227202F3E22292E6373732822706F736974696F6E';
wwv_flow_api.g_varchar2_table(87) := '222C226162736F6C75746522292E6373732822746F70222C30292E63737328226C656674222C30292C746869732E5F63726561746548616E646C657328292C746869732E5F63726561746542617228292C746869732E636F6E7461696E65722E70726570';
wwv_flow_api.g_varchar2_table(88) := '656E6428746869732E696E6E6572426172292C746869732E5F6372656174654172726F777328292C226869646522213D3D746869732E6F7074696F6E732E76616C75654C6162656C733F746869732E5F6372656174654C6162656C7328293A746869732E';
wwv_flow_api.g_varchar2_table(89) := '5F64657374726F794C6162656C7328292C746869732E5F75706461746552756C657228292C746869732E6F7074696F6E732E656E61626C65647C7C746869732E5F746F67676C6528746869732E6F7074696F6E732E656E61626C6564297D2C5F63726561';
wwv_flow_api.g_varchar2_table(90) := '746548616E646C653A66756E6374696F6E2862297B72657475726E206128223C646976202F3E22295B746869732E5F68616E646C655479706528295D2862292E62696E642822736C6964657244726167222C612E70726F787928746869732E5F6368616E';
wwv_flow_api.g_varchar2_table(91) := '67696E672C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6368616E6765642C7468697329297D2C5F63726561746548616E646C65733A66756E6374696F6E28297B746869732E6C65667448616E646C653D74686973';
wwv_flow_api.g_varchar2_table(92) := '2E5F63726561746548616E646C65287B69734C6566743A21302C626F756E64733A746869732E6F7074696F6E732E626F756E64732C76616C75653A746869732E5F76616C7565732E6D696E2C737465703A746869732E6F7074696F6E732E737465702C73';
wwv_flow_api.g_varchar2_table(93) := '796D6D6574726963506F736974696F6E6E696E673A746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E677D292E617070656E64546F28746869732E636F6E7461696E6572292C746869732E726967687448616E646C653D';
wwv_flow_api.g_varchar2_table(94) := '746869732E5F63726561746548616E646C65287B69734C6566743A21312C626F756E64733A746869732E6F7074696F6E732E626F756E64732C76616C75653A746869732E5F76616C7565732E6D61782C737465703A746869732E6F7074696F6E732E7374';
wwv_flow_api.g_varchar2_table(95) := '65702C73796D6D6574726963506F736974696F6E6E696E673A746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E677D292E617070656E64546F28746869732E636F6E7461696E6572297D2C5F6372656174654261723A66';
wwv_flow_api.g_varchar2_table(96) := '756E6374696F6E28297B746869732E6261723D6128223C646976202F3E22292E70726570656E64546F28746869732E636F6E7461696E6572292E62696E642822736C6964657244726167207363726F6C6C207A6F6F6D222C612E70726F78792874686973';
wwv_flow_api.g_varchar2_table(97) := '2E5F6368616E67696E672C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6368616E6765642C7468697329292C746869732E5F626172287B6C65667448616E646C653A746869732E6C65667448616E646C652C726967';
wwv_flow_api.g_varchar2_table(98) := '687448616E646C653A746869732E726967687448616E646C652C76616C7565733A7B6D696E3A746869732E5F76616C7565732E6D696E2C6D61783A746869732E5F76616C7565732E6D61787D2C747970653A746869732E5F68616E646C65547970652829';
wwv_flow_api.g_varchar2_table(99) := '2C72616E67653A746869732E6F7074696F6E732E72616E67652C776865656C4D6F64653A746869732E6F7074696F6E732E776865656C4D6F64652C776865656C53706565643A746869732E6F7074696F6E732E776865656C53706565647D292C74686973';
wwv_flow_api.g_varchar2_table(100) := '2E6F7074696F6E732E72616E67653D746869732E5F62617228226F7074696F6E222C2272616E676522292C746869732E6F7074696F6E732E776865656C4D6F64653D746869732E5F62617228226F7074696F6E222C22776865656C4D6F646522292C7468';
wwv_flow_api.g_varchar2_table(101) := '69732E6F7074696F6E732E776865656C53706565643D746869732E5F62617228226F7074696F6E222C22776865656C537065656422297D2C5F6372656174654172726F77733A66756E6374696F6E28297B746869732E6172726F77732E6C6566743D7468';
wwv_flow_api.g_varchar2_table(102) := '69732E5F6372656174654172726F7728226C65667422292C746869732E6172726F77732E72696768743D746869732E5F6372656174654172726F772822726967687422292C746869732E6F7074696F6E732E6172726F77733F746869732E656C656D656E';
wwv_flow_api.g_varchar2_table(103) := '742E616464436C617373282275692D72616E6765536C696465722D776974684172726F777322293A28746869732E6172726F77732E6C6566742E6373732822646973706C6179222C226E6F6E6522292C746869732E6172726F77732E72696768742E6373';
wwv_flow_api.g_varchar2_table(104) := '732822646973706C6179222C226E6F6E6522292C746869732E656C656D656E742E616464436C617373282275692D72616E6765536C696465722D6E6F4172726F772229297D2C5F6372656174654172726F773A66756E6374696F6E2862297B7661722063';
wwv_flow_api.g_varchar2_table(105) := '2C643D6128223C64697620636C6173733D2775692D72616E6765536C696465722D6172726F7727202F3E22292E617070656E6428223C64697620636C6173733D2775692D72616E6765536C696465722D6172726F772D696E6E657227202F3E22292E6164';
wwv_flow_api.g_varchar2_table(106) := '64436C617373282275692D72616E6765536C696465722D222B622B224172726F7722292E6373732822706F736974696F6E222C226162736F6C75746522292E63737328622C30292E617070656E64546F28746869732E656C656D656E74293B7265747572';
wwv_flow_api.g_varchar2_table(107) := '6E20633D227269676874223D3D3D623F612E70726F787928746869732E5F7363726F6C6C5269676874436C69636B2C74686973293A612E70726F787928746869732E5F7363726F6C6C4C656674436C69636B2C74686973292C642E62696E6428226D6F75';
wwv_flow_api.g_varchar2_table(108) := '7365646F776E20746F7563687374617274222C63292C647D2C5F70726F78793A66756E6374696F6E28612C622C63297B76617220643D41727261792E70726F746F747970652E736C6963652E63616C6C2863293B72657475726E20612626615B625D3F61';
wwv_flow_api.g_varchar2_table(109) := '5B625D2E6170706C7928612C64293A6E756C6C7D2C5F68616E646C65547970653A66756E6374696F6E28297B72657475726E2272616E6765536C6964657248616E646C65227D2C5F626172547970653A66756E6374696F6E28297B72657475726E227261';
wwv_flow_api.g_varchar2_table(110) := '6E6765536C69646572426172227D2C5F6261723A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6261722C746869732E5F6261725479706528292C617267756D656E7473297D2C5F6C6162656C547970653A6675';
wwv_flow_api.g_varchar2_table(111) := '6E6374696F6E28297B72657475726E2272616E6765536C696465724C6162656C227D2C5F6C6566744C6162656C3A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C6162656C732E6C6566742C746869732E5F6C';
wwv_flow_api.g_varchar2_table(112) := '6162656C5479706528292C617267756D656E7473297D2C5F72696768744C6162656C3A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C6162656C732E72696768742C746869732E5F6C6162656C547970652829';
wwv_flow_api.g_varchar2_table(113) := '2C617267756D656E7473297D2C5F6C65667448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E6C65667448616E646C652C746869732E5F68616E646C655479706528292C617267756D656E747329';
wwv_flow_api.g_varchar2_table(114) := '7D2C5F726967687448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F70726F787928746869732E726967687448616E646C652C746869732E5F68616E646C655479706528292C617267756D656E7473297D2C5F67657456616C';
wwv_flow_api.g_varchar2_table(115) := '75653A66756E6374696F6E28612C62297B72657475726E20623D3D3D746869732E726967687448616E646C65262628612D3D622E6F7574657257696474682829292C612A28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F70';
wwv_flow_api.g_varchar2_table(116) := '74696F6E732E626F756E64732E6D696E292F28746869732E636F6E7461696E65722E696E6E6572576964746828292D622E6F75746572576964746828213029292B746869732E6F7074696F6E732E626F756E64732E6D696E7D2C5F747269676765723A66';
wwv_flow_api.g_varchar2_table(117) := '756E6374696F6E2861297B76617220623D746869733B73657454696D656F75742866756E6374696F6E28297B622E656C656D656E742E7472696767657228612C7B6C6162656C3A622E656C656D656E742C76616C7565733A622E76616C75657328297D29';
wwv_flow_api.g_varchar2_table(118) := '7D2C31297D2C5F6368616E67696E673A66756E6374696F6E28297B746869732E5F75706461746556616C7565732829262628746869732E5F74726967676572282276616C7565734368616E67696E6722292C746869732E5F76616C7565734368616E6765';
wwv_flow_api.g_varchar2_table(119) := '643D2130297D2C5F646561637469766174654C6162656C733A66756E6374696F6E28297B226368616E6765223D3D3D746869732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C6162656C28226F7074696F6E222C22';
wwv_flow_api.g_varchar2_table(120) := '73686F77222C226869646522292C746869732E5F72696768744C6162656C28226F7074696F6E222C2273686F77222C22686964652229297D2C5F726561637469766174654C6162656C733A66756E6374696F6E28297B226368616E6765223D3D3D746869';
wwv_flow_api.g_varchar2_table(121) := '732E6F7074696F6E732E76616C75654C6162656C73262628746869732E5F6C6566744C6162656C28226F7074696F6E222C2273686F77222C226368616E676522292C746869732E5F72696768744C6162656C28226F7074696F6E222C2273686F77222C22';
wwv_flow_api.g_varchar2_table(122) := '6368616E67652229297D2C5F6368616E6765643A66756E6374696F6E2861297B613D3D3D21302626746869732E5F646561637469766174654C6162656C7328292C28746869732E5F75706461746556616C75657328297C7C746869732E5F76616C756573';
wwv_flow_api.g_varchar2_table(123) := '4368616E67656429262628746869732E5F74726967676572282276616C7565734368616E67656422292C61213D3D21302626746869732E5F7472696767657228227573657256616C7565734368616E67656422292C746869732E5F76616C756573436861';
wwv_flow_api.g_varchar2_table(124) := '6E6765643D2131292C613D3D3D21302626746869732E5F726561637469766174654C6162656C7328297D2C5F75706461746556616C7565733A66756E6374696F6E28297B76617220613D746869732E5F6C65667448616E646C65282276616C756522292C';
wwv_flow_api.g_varchar2_table(125) := '623D746869732E5F726967687448616E646C65282276616C756522292C633D746869732E5F6D696E28612C62292C643D746869732E5F6D617828612C62292C653D63213D3D746869732E5F76616C7565732E6D696E7C7C64213D3D746869732E5F76616C';
wwv_flow_api.g_varchar2_table(126) := '7565732E6D61783B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E5F6D696E28612C62292C746869732E5F76616C7565732E6D61783D746869732E5F6D617828612C62292C657D2C5F6D696E3A66756E6374696F6E28612C6229';
wwv_flow_api.g_varchar2_table(127) := '7B72657475726E204D6174682E6D696E28612C62297D2C5F6D61783A66756E6374696F6E28612C62297B72657475726E204D6174682E6D617828612C62297D2C5F6372656174654C6162656C3A66756E6374696F6E28622C63297B76617220643B726574';
wwv_flow_api.g_varchar2_table(128) := '75726E206E756C6C3D3D3D623F28643D746869732E5F6765744C6162656C436F6E7374727563746F72506172616D657465727328622C63292C623D6128223C646976202F3E22292E617070656E64546F28746869732E656C656D656E74295B746869732E';
wwv_flow_api.g_varchar2_table(129) := '5F6C6162656C5479706528295D286429293A28643D746869732E5F6765744C6162656C52656672657368506172616D657465727328622C63292C625B746869732E5F6C6162656C5479706528295D286429292C627D2C5F6765744C6162656C436F6E7374';
wwv_flow_api.g_varchar2_table(130) := '727563746F72506172616D65746572733A66756E6374696F6E28612C62297B72657475726E7B68616E646C653A622C68616E646C65547970653A746869732E5F68616E646C655479706528292C666F726D61747465723A746869732E5F676574466F726D';
wwv_flow_api.g_varchar2_table(131) := '617474657228292C73686F773A746869732E6F7074696F6E732E76616C75654C6162656C732C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A746869732E6F7074696F6E732E6475';
wwv_flow_api.g_varchar2_table(132) := '726174696F6E4F75742C64656C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D7D2C5F6765744C6162656C52656672657368506172616D65746572733A66756E6374696F6E28297B72657475726E7B666F726D61747465723A7468';
wwv_flow_api.g_varchar2_table(133) := '69732E5F676574466F726D617474657228292C73686F773A746869732E6F7074696F6E732E76616C75654C6162656C732C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A74686973';
wwv_flow_api.g_varchar2_table(134) := '2E6F7074696F6E732E6475726174696F6E4F75742C64656C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D7D2C5F676574466F726D61747465723A66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E66';
wwv_flow_api.g_varchar2_table(135) := '6F726D61747465723D3D3D21317C7C6E756C6C3D3D3D746869732E6F7074696F6E732E666F726D61747465723F746869732E5F64656661756C74466F726D61747465723A746869732E6F7074696F6E732E666F726D61747465727D2C5F64656661756C74';
wwv_flow_api.g_varchar2_table(136) := '466F726D61747465723A66756E6374696F6E2861297B72657475726E204D6174682E726F756E642861297D2C5F64657374726F794C6162656C3A66756E6374696F6E2861297B72657475726E206E756C6C213D3D61262628615B746869732E5F6C616265';
wwv_flow_api.g_varchar2_table(137) := '6C5479706528295D282264657374726F7922292C612E72656D6F766528292C613D6E756C6C292C617D2C5F6372656174654C6162656C733A66756E6374696F6E28297B746869732E6C6162656C732E6C6566743D746869732E5F6372656174654C616265';
wwv_flow_api.g_varchar2_table(138) := '6C28746869732E6C6162656C732E6C6566742C746869732E6C65667448616E646C65292C746869732E6C6162656C732E72696768743D746869732E5F6372656174654C6162656C28746869732E6C6162656C732E72696768742C746869732E7269676874';
wwv_flow_api.g_varchar2_table(139) := '48616E646C65292C746869732E5F6C6566744C6162656C282270616972222C746869732E6C6162656C732E7269676874297D2C5F64657374726F794C6162656C733A66756E6374696F6E28297B746869732E6C6162656C732E6C6566743D746869732E5F';
wwv_flow_api.g_varchar2_table(140) := '64657374726F794C6162656C28746869732E6C6162656C732E6C656674292C746869732E6C6162656C732E72696768743D746869732E5F64657374726F794C6162656C28746869732E6C6162656C732E7269676874297D2C5F73746570526174696F3A66';
wwv_flow_api.g_varchar2_table(141) := '756E6374696F6E28297B72657475726E20746869732E5F6C65667448616E646C65282273746570526174696F22297D2C5F7363726F6C6C5269676874436C69636B3A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E656E';
wwv_flow_api.g_varchar2_table(142) := '61626C65643F28612E70726576656E7444656661756C7428292C746869732E5F626172282273746172745363726F6C6C22292C746869732E5F62696E6453746F705363726F6C6C28292C766F696420746869732E5F636F6E74696E75655363726F6C6C69';
wwv_flow_api.g_varchar2_table(143) := '6E6728227363726F6C6C5269676874222C342A746869732E5F73746570526174696F28292C3129293A21317D2C5F636F6E74696E75655363726F6C6C696E673A66756E6374696F6E28612C622C632C64297B69662821746869732E6F7074696F6E732E65';
wwv_flow_api.g_varchar2_table(144) := '6E61626C65642972657475726E21313B746869732E5F62617228612C63292C643D647C7C352C642D2D3B76617220653D746869732C663D31362C673D4D6174682E6D617828312C342F746869732E5F73746570526174696F2829293B746869732E5F7363';
wwv_flow_api.g_varchar2_table(145) := '726F6C6C54696D656F75743D73657454696D656F75742866756E6374696F6E28297B303D3D3D64262628623E663F623D4D6174682E6D617828662C622F312E35293A633D4D6174682E6D696E28672C322A63292C643D35292C652E5F636F6E74696E7565';
wwv_flow_api.g_varchar2_table(146) := '5363726F6C6C696E6728612C622C632C64297D2C62297D2C5F7363726F6C6C4C656674436C69636B3A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E656E61626C65643F28612E70726576656E7444656661756C742829';
wwv_flow_api.g_varchar2_table(147) := '2C746869732E5F626172282273746172745363726F6C6C22292C746869732E5F62696E6453746F705363726F6C6C28292C766F696420746869732E5F636F6E74696E75655363726F6C6C696E6728227363726F6C6C4C656674222C342A746869732E5F73';
wwv_flow_api.g_varchar2_table(148) := '746570526174696F28292C3129293A21317D2C5F62696E6453746F705363726F6C6C3A66756E6374696F6E28297B76617220623D746869733B746869732E5F73746F705363726F6C6C48616E646C653D66756E6374696F6E2861297B612E70726576656E';
wwv_flow_api.g_varchar2_table(149) := '7444656661756C7428292C622E5F73746F705363726F6C6C28297D2C6128646F63756D656E74292E62696E6428226D6F757365757020746F756368656E64222C746869732E5F73746F705363726F6C6C48616E646C65297D2C5F73746F705363726F6C6C';
wwv_flow_api.g_varchar2_table(150) := '3A66756E6374696F6E28297B6128646F63756D656E74292E756E62696E6428226D6F757365757020746F756368656E64222C746869732E5F73746F705363726F6C6C48616E646C65292C746869732E5F73746F705363726F6C6C48616E646C653D6E756C';
wwv_flow_api.g_varchar2_table(151) := '6C2C746869732E5F626172282273746F705363726F6C6C22292C636C65617254696D656F757428746869732E5F7363726F6C6C54696D656F7574297D2C5F63726561746552756C65723A66756E6374696F6E28297B746869732E72756C65723D6128223C';
wwv_flow_api.g_varchar2_table(152) := '64697620636C6173733D2775692D72616E6765536C696465722D72756C657227202F3E22292E617070656E64546F28746869732E696E6E6572426172297D2C5F73657452756C6572506172616D65746572733A66756E6374696F6E28297B746869732E72';
wwv_flow_api.g_varchar2_table(153) := '756C65722E72756C6572287B6D696E3A746869732E6F7074696F6E732E626F756E64732E6D696E2C6D61783A746869732E6F7074696F6E732E626F756E64732E6D61782C7363616C65733A746869732E6F7074696F6E732E7363616C65737D297D2C5F64';
wwv_flow_api.g_varchar2_table(154) := '657374726F7952756C65723A66756E6374696F6E28297B6E756C6C213D3D746869732E72756C65722626612E666E2E72756C6572262628746869732E72756C65722E72756C6572282264657374726F7922292C746869732E72756C65722E72656D6F7665';
wwv_flow_api.g_varchar2_table(155) := '28292C746869732E72756C65723D6E756C6C297D2C5F75706461746552756C65723A66756E6374696F6E28297B746869732E5F64657374726F7952756C657228292C746869732E6F7074696F6E732E7363616C6573213D3D21312626612E666E2E72756C';
wwv_flow_api.g_varchar2_table(156) := '6572262628746869732E5F63726561746552756C657228292C746869732E5F73657452756C6572506172616D65746572732829297D2C76616C7565733A66756E6374696F6E28612C62297B76617220633B69662822756E646566696E656422213D747970';
wwv_flow_api.g_varchar2_table(157) := '656F662061262622756E646566696E656422213D747970656F662062297B69662821746869732E5F696E697469616C697A65642972657475726E20746869732E5F76616C7565732E6D696E3D612C746869732E5F76616C7565732E6D61783D622C746869';
wwv_flow_api.g_varchar2_table(158) := '732E5F76616C7565733B746869732E5F646561637469766174654C6162656C7328292C633D746869732E5F626172282276616C756573222C612C62292C746869732E5F6368616E676564282130292C746869732E5F726561637469766174654C6162656C';
wwv_flow_api.g_varchar2_table(159) := '7328297D656C736520633D746869732E5F626172282276616C756573222C612C62293B72657475726E20637D2C6D696E3A66756E6374696F6E2861297B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E76616C75657328612C74';
wwv_flow_api.g_varchar2_table(160) := '6869732E5F76616C7565732E6D6178292E6D696E2C746869732E5F76616C7565732E6D696E7D2C6D61783A66756E6374696F6E2861297B72657475726E20746869732E5F76616C7565732E6D61783D746869732E76616C75657328746869732E5F76616C';
wwv_flow_api.g_varchar2_table(161) := '7565732E6D696E2C61292E6D61782C746869732E5F76616C7565732E6D61787D2C626F756E64733A66756E6374696F6E28612C62297B72657475726E20746869732E5F697356616C696456616C75652861292626746869732E5F697356616C696456616C';
wwv_flow_api.g_varchar2_table(162) := '75652862292626623E61262628746869732E5F736574426F756E647328612C62292C746869732E5F75706461746552756C657228292C746869732E5F6368616E67656428213029292C746869732E6F7074696F6E732E626F756E64737D2C5F697356616C';
wwv_flow_api.g_varchar2_table(163) := '696456616C75653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F66206126267061727365466C6F61742861293D3D3D617D2C5F736574426F756E64733A66756E6374696F6E28612C62297B746869732E6F70';
wwv_flow_api.g_varchar2_table(164) := '74696F6E732E626F756E64733D7B6D696E3A612C6D61783A627D2C746869732E5F6C65667448616E646C6528226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473292C746869732E5F726967687448616E646C65';
wwv_flow_api.g_varchar2_table(165) := '28226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473292C746869732E5F62617228226F7074696F6E222C22626F756E6473222C746869732E6F7074696F6E732E626F756E6473297D2C7A6F6F6D496E3A66756E';
wwv_flow_api.g_varchar2_table(166) := '6374696F6E2861297B746869732E5F62617228227A6F6F6D496E222C61297D2C7A6F6F6D4F75743A66756E6374696F6E2861297B746869732E5F62617228227A6F6F6D4F7574222C61297D2C7363726F6C6C4C6566743A66756E6374696F6E2861297B74';
wwv_flow_api.g_varchar2_table(167) := '6869732E5F626172282273746172745363726F6C6C22292C746869732E5F62617228227363726F6C6C4C656674222C61292C746869732E5F626172282273746F705363726F6C6C22297D2C7363726F6C6C52696768743A66756E6374696F6E2861297B74';
wwv_flow_api.g_varchar2_table(168) := '6869732E5F626172282273746172745363726F6C6C22292C746869732E5F62617228227363726F6C6C5269676874222C61292C746869732E5F626172282273746F705363726F6C6C22297D2C726573697A653A66756E6374696F6E28297B746869732E63';
wwv_flow_api.g_varchar2_table(169) := '6F6E7461696E6572262628746869732E5F696E6974576964746828292C746869732E5F6C65667448616E646C65282275706461746522292C746869732E5F726967687448616E646C65282275706461746522292C746869732E5F62617228227570646174';
wwv_flow_api.g_varchar2_table(170) := '652229297D2C656E61626C653A66756E6374696F6E28297B746869732E746F67676C65282130297D2C64697361626C653A66756E6374696F6E28297B746869732E746F67676C65282131297D2C746F67676C653A66756E6374696F6E2861297B613D3D3D';
wwv_flow_api.g_varchar2_table(171) := '62262628613D21746869732E6F7074696F6E732E656E61626C6564292C746869732E6F7074696F6E732E656E61626C6564213D3D612626746869732E5F746F67676C652861297D2C5F746F67676C653A66756E6374696F6E2861297B746869732E6F7074';
wwv_flow_api.g_varchar2_table(172) := '696F6E732E656E61626C65643D612C746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D64697361626C6564222C2161293B76617220623D613F22656E61626C65223A2264697361626C65223B746869';
wwv_flow_api.g_varchar2_table(173) := '732E5F6261722862292C746869732E5F6C65667448616E646C652862292C746869732E5F726967687448616E646C652862292C746869732E5F6C6566744C6162656C2862292C746869732E5F72696768744C6162656C2862297D2C64657374726F793A66';
wwv_flow_api.g_varchar2_table(174) := '756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C617373282275692D72616E6765536C696465722D776974684172726F77732075692D72616E6765536C696465722D6E6F4172726F772075692D72616E6765536C696465722D';
wwv_flow_api.g_varchar2_table(175) := '64697361626C656422292C746869732E5F64657374726F795769646765747328292C746869732E5F64657374726F79456C656D656E747328292C746869732E656C656D656E742E72656D6F7665436C617373282275692D72616E6765536C696465722229';
wwv_flow_api.g_varchar2_table(176) := '2C746869732E6F7074696F6E733D6E756C6C2C612877696E646F77292E756E62696E642822726573697A65222C746869732E5F726573697A6550726F7879292C746869732E5F726573697A6550726F78793D6E756C6C2C746869732E5F62696E64526573';
wwv_flow_api.g_varchar2_table(177) := '697A653D6E756C6C2C612E5769646765742E70726F746F747970652E64657374726F792E6170706C7928746869732C617267756D656E7473297D2C5F64657374726F795769646765743A66756E6374696F6E2861297B746869735B225F222B615D282264';
wwv_flow_api.g_varchar2_table(178) := '657374726F7922292C746869735B615D2E72656D6F766528292C746869735B615D3D6E756C6C7D2C5F64657374726F79576964676574733A66756E6374696F6E28297B746869732E5F64657374726F79576964676574282262617222292C746869732E5F';
wwv_flow_api.g_varchar2_table(179) := '64657374726F7957696467657428226C65667448616E646C6522292C746869732E5F64657374726F795769646765742822726967687448616E646C6522292C746869732E5F64657374726F7952756C657228292C746869732E5F64657374726F794C6162';
wwv_flow_api.g_varchar2_table(180) := '656C7328297D2C5F64657374726F79456C656D656E74733A66756E6374696F6E28297B746869732E636F6E7461696E65722E72656D6F766528292C746869732E636F6E7461696E65723D6E756C6C2C746869732E696E6E65724261722E72656D6F766528';
wwv_flow_api.g_varchar2_table(181) := '292C746869732E696E6E65724261723D6E756C6C2C746869732E6172726F77732E6C6566742E72656D6F766528292C746869732E6172726F77732E72696768742E72656D6F766528292C746869732E6172726F77733D6E756C6C7D7D297D286A51756572';
wwv_flow_api.g_varchar2_table(182) := '79292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E72616E6765536C6964657248616E646C65222C612E75692E72616E6765536C69646572447261676761626C652C7B63757272656E744D6F7665';
wwv_flow_api.g_varchar2_table(183) := '3A6E756C6C2C6D617267696E3A302C706172656E74456C656D656E743A6E756C6C2C6F7074696F6E733A7B69734C6566743A21302C626F756E64733A7B6D696E3A302C6D61783A3130307D2C72616E67653A21312C76616C75653A302C737465703A2131';
wwv_flow_api.g_varchar2_table(184) := '7D2C5F76616C75653A302C5F6C6566743A302C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E65';
wwv_flow_api.g_varchar2_table(185) := '6C656D656E742E6373732822706F736974696F6E222C226162736F6C75746522292E6373732822746F70222C30292E616464436C617373282275692D72616E6765536C696465722D68616E646C6522292E746F67676C65436C617373282275692D72616E';
wwv_flow_api.g_varchar2_table(186) := '6765536C696465722D6C65667448616E646C65222C746869732E6F7074696F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C696465722D726967687448616E646C65222C21746869732E6F7074696F6E732E69734C';
wwv_flow_api.g_varchar2_table(187) := '656674292C746869732E656C656D656E742E617070656E6428223C64697620636C6173733D2775692D72616E6765536C696465722D68616E646C652D696E6E657227202F3E22292C746869732E5F76616C75653D746869732E5F636F6E73747261696E74';
wwv_flow_api.g_varchar2_table(188) := '56616C756528746869732E6F7074696F6E732E76616C7565297D2C64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E656D70747928292C612E75692E72616E6765536C69646572447261676761626C652E70726F746F7479';
wwv_flow_api.g_varchar2_table(189) := '70652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B2269734C65667422213D3D627C7C63213D3D2130262663213D3D21317C7C633D3D3D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(190) := '66743F2273746570223D3D3D622626746869732E5F636865636B537465702863293F28746869732E6F7074696F6E732E737465703D632C746869732E7570646174652829293A22626F756E6473223D3D3D623F28746869732E6F7074696F6E732E626F75';
wwv_flow_api.g_varchar2_table(191) := '6E64733D632C746869732E7570646174652829293A2272616E6765223D3D3D622626746869732E5F636865636B52616E67652863293F28746869732E6F7074696F6E732E72616E67653D632C746869732E7570646174652829293A2273796D6D65747269';
wwv_flow_api.g_varchar2_table(192) := '63506F736974696F6E6E696E67223D3D3D62262628746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E673D633D3D3D21302C746869732E7570646174652829293A28746869732E6F7074696F6E732E69734C6566743D63';
wwv_flow_api.g_varchar2_table(193) := '2C746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D6C65667448616E646C65222C746869732E6F7074696F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C6964';
wwv_flow_api.g_varchar2_table(194) := '65722D726967687448616E646C65222C21746869732E6F7074696F6E732E69734C656674292C746869732E5F706F736974696F6E28746869732E5F76616C7565292C746869732E656C656D656E742E747269676765722822737769746368222C74686973';
wwv_flow_api.g_varchar2_table(195) := '2E6F7074696F6E732E69734C65667429292C612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D2C5F636865636B52616E67653A66756E63';
wwv_flow_api.g_varchar2_table(196) := '74696F6E2861297B72657475726E20613D3D3D21317C7C21746869732E5F697356616C696456616C756528612E6D696E29262621746869732E5F697356616C696456616C756528612E6D6178297D2C5F697356616C696456616C75653A66756E6374696F';
wwv_flow_api.g_varchar2_table(197) := '6E2861297B72657475726E22756E646566696E656422213D747970656F662061262661213D3D213126267061727365466C6F6174286129213D3D617D2C5F636865636B537465703A66756E6374696F6E2861297B72657475726E20613D3D3D21317C7C70';
wwv_flow_api.g_varchar2_table(198) := '61727365466C6F61742861293D3D3D617D2C5F696E6974456C656D656E743A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F696E6974456C656D656E742E6170706C7928746869';
wwv_flow_api.g_varchar2_table(199) := '73292C303D3D3D746869732E63616368652E706172656E742E77696474687C7C6E756C6C3D3D3D746869732E63616368652E706172656E742E77696474683F73657454696D656F757428612E70726F787928746869732E5F696E6974456C656D656E7449';
wwv_flow_api.g_varchar2_table(200) := '664E6F7444657374726F7965642C74686973292C353030293A28746869732E5F706F736974696F6E28746869732E5F76616C7565292C746869732E5F747269676765724D6F7573654576656E742822696E697469616C697A652229297D2C5F626F756E64';
wwv_flow_api.g_varchar2_table(201) := '733A66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E626F756E64737D2C5F63616368653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F63616368';
wwv_flow_api.g_varchar2_table(202) := '652E6170706C792874686973292C746869732E5F6361636865506172656E7428297D2C5F6361636865506172656E743A66756E6374696F6E28297B76617220613D746869732E656C656D656E742E706172656E7428293B746869732E63616368652E7061';
wwv_flow_api.g_varchar2_table(203) := '72656E743D7B656C656D656E743A612C6F66667365743A612E6F666673657428292C70616464696E673A7B6C6566743A746869732E5F7061727365506978656C7328612C2270616464696E674C65667422297D2C77696474683A612E776964746828297D';
wwv_flow_api.g_varchar2_table(204) := '7D2C5F706F736974696F6E3A66756E6374696F6E2861297B76617220623D746869732E5F676574506F736974696F6E466F7256616C75652861293B746869732E5F6170706C79506F736974696F6E2862297D2C5F636F6E73747261696E74506F73697469';
wwv_flow_api.g_varchar2_table(205) := '6F6E3A66756E6374696F6E2861297B76617220623D746869732E5F67657456616C7565466F72506F736974696F6E2861293B72657475726E20746869732E5F676574506F736974696F6E466F7256616C75652862297D2C5F6170706C79506F736974696F';
wwv_flow_api.g_varchar2_table(206) := '6E3A66756E6374696F6E2862297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6170706C79506F736974696F6E2E6170706C7928746869732C5B625D292C746869732E5F6C6566743D622C746869732E5F';
wwv_flow_api.g_varchar2_table(207) := '73657456616C756528746869732E5F67657456616C7565466F72506F736974696F6E286229292C746869732E5F747269676765724D6F7573654576656E7428226D6F76696E6722297D2C5F707265706172654576656E74446174613A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(208) := '28297B76617220623D612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F707265706172654576656E74446174612E6170706C792874686973293B72657475726E20622E76616C75653D746869732E5F76616C75';
wwv_flow_api.g_varchar2_table(209) := '652C627D2C5F73657456616C75653A66756E6374696F6E2861297B61213D3D746869732E5F76616C7565262628746869732E5F76616C75653D61297D2C5F636F6E73747261696E7456616C75653A66756E6374696F6E2861297B696628613D4D6174682E';
wwv_flow_api.g_varchar2_table(210) := '6D696E28612C746869732E5F626F756E647328292E6D6178292C613D4D6174682E6D617828612C746869732E5F626F756E647328292E6D696E292C613D746869732E5F726F756E642861292C746869732E6F7074696F6E732E72616E6765213D3D213129';
wwv_flow_api.g_varchar2_table(211) := '7B76617220623D746869732E6F7074696F6E732E72616E67652E6D696E7C7C21312C633D746869732E6F7074696F6E732E72616E67652E6D61787C7C21313B62213D3D2131262628613D4D6174682E6D617828612C746869732E5F726F756E6428622929';
wwv_flow_api.g_varchar2_table(212) := '292C63213D3D2131262628613D4D6174682E6D696E28612C746869732E5F726F756E6428632929292C613D4D6174682E6D696E28612C746869732E5F626F756E647328292E6D6178292C613D4D6174682E6D617828612C746869732E5F626F756E647328';
wwv_flow_api.g_varchar2_table(213) := '292E6D696E297D72657475726E20617D2C5F726F756E643A66756E6374696F6E2861297B72657475726E20746869732E6F7074696F6E732E73746570213D3D21312626746869732E6F7074696F6E732E737465703E303F4D6174682E726F756E6428612F';
wwv_flow_api.g_varchar2_table(214) := '746869732E6F7074696F6E732E73746570292A746869732E6F7074696F6E732E737465703A617D2C5F676574506F736974696F6E466F7256616C75653A66756E6374696F6E2861297B69662821746869732E63616368657C7C21746869732E6361636865';
wwv_flow_api.g_varchar2_table(215) := '2E706172656E747C7C6E756C6C3D3D3D746869732E63616368652E706172656E742E6F66667365742972657475726E20303B613D746869732E5F636F6E73747261696E7456616C75652861293B76617220623D28612D746869732E6F7074696F6E732E62';
wwv_flow_api.g_varchar2_table(216) := '6F756E64732E6D696E292F28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F7074696F6E732E626F756E64732E6D696E292C633D746869732E63616368652E706172656E742E77696474682C643D746869732E63616368652E';
wwv_flow_api.g_varchar2_table(217) := '706172656E742E6F66667365742E6C6566742C653D746869732E6F7074696F6E732E69734C6566743F303A746869732E63616368652E77696474682E6F757465723B72657475726E20746869732E6F7074696F6E732E73796D6D6574726963506F736974';
wwv_flow_api.g_varchar2_table(218) := '696F6E6E696E673F622A28632D322A746869732E63616368652E77696474682E6F75746572292B642B653A622A632B642D657D2C5F67657456616C7565466F72506F736974696F6E3A66756E6374696F6E2861297B76617220623D746869732E5F676574';
wwv_flow_api.g_varchar2_table(219) := '52617756616C7565466F72506F736974696F6E416E64426F756E647328612C746869732E6F7074696F6E732E626F756E64732E6D696E2C746869732E6F7074696F6E732E626F756E64732E6D6178293B72657475726E20746869732E5F636F6E73747261';
wwv_flow_api.g_varchar2_table(220) := '696E7456616C75652862297D2C5F67657452617756616C7565466F72506F736974696F6E416E64426F756E64733A66756E6374696F6E28612C622C63297B76617220642C652C663D6E756C6C3D3D3D746869732E63616368652E706172656E742E6F6666';
wwv_flow_api.g_varchar2_table(221) := '7365743F303A746869732E63616368652E706172656E742E6F66667365742E6C6566743B72657475726E20746869732E6F7074696F6E732E73796D6D6574726963506F736974696F6E6E696E673F28612D3D746869732E6F7074696F6E732E69734C6566';
wwv_flow_api.g_varchar2_table(222) := '743F303A746869732E63616368652E77696474682E6F757465722C643D746869732E63616368652E706172656E742E77696474682D322A746869732E63616368652E77696474682E6F75746572293A28612B3D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(223) := '66743F303A746869732E63616368652E77696474682E6F757465722C643D746869732E63616368652E706172656E742E7769647468292C303D3D3D643F746869732E5F76616C75653A28653D28612D66292F642C652A28632D62292B62297D2C76616C75';
wwv_flow_api.g_varchar2_table(224) := '653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869732E5F636163686528292C613D746869732E5F636F6E73747261696E7456616C75652861292C746869732E5F706F736974696F6E28';
wwv_flow_api.g_varchar2_table(225) := '6129292C746869732E5F76616C75657D2C7570646174653A66756E6374696F6E28297B746869732E5F636163686528293B76617220613D746869732E5F636F6E73747261696E7456616C756528746869732E5F76616C7565292C623D746869732E5F6765';
wwv_flow_api.g_varchar2_table(226) := '74506F736974696F6E466F7256616C75652861293B61213D3D746869732E5F76616C75653F28746869732E5F747269676765724D6F7573654576656E7428227570646174696E6722292C746869732E5F706F736974696F6E2861292C746869732E5F7472';
wwv_flow_api.g_varchar2_table(227) := '69676765724D6F7573654576656E7428227570646174652229293A62213D3D746869732E63616368652E6F66667365742E6C656674262628746869732E5F747269676765724D6F7573654576656E7428227570646174696E6722292C746869732E5F706F';
wwv_flow_api.g_varchar2_table(228) := '736974696F6E2861292C746869732E5F747269676765724D6F7573654576656E7428227570646174652229297D2C706F736974696F6E3A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869';
wwv_flow_api.g_varchar2_table(229) := '732E5F636163686528292C613D746869732E5F636F6E73747261696E74506F736974696F6E2861292C746869732E5F6170706C79506F736974696F6E286129292C746869732E5F6C6566747D2C6164643A66756E6374696F6E28612C62297B7265747572';
wwv_flow_api.g_varchar2_table(230) := '6E20612B627D2C7375627374726163743A66756E6374696F6E28612C62297B72657475726E20612D627D2C73746570734265747765656E3A66756E6374696F6E28612C62297B72657475726E20746869732E6F7074696F6E732E737465703D3D3D21313F';
wwv_flow_api.g_varchar2_table(231) := '622D613A28622D61292F746869732E6F7074696F6E732E737465707D2C6D756C7469706C79537465703A66756E6374696F6E28612C62297B72657475726E20612A627D2C6D6F766552696768743A66756E6374696F6E2861297B76617220623B72657475';
wwv_flow_api.g_varchar2_table(232) := '726E20746869732E6F7074696F6E732E737465703D3D3D21313F28623D746869732E5F6C6566742C746869732E706F736974696F6E28746869732E5F6C6566742B61292C746869732E5F6C6566742D62293A28623D746869732E5F76616C75652C746869';
wwv_flow_api.g_varchar2_table(233) := '732E76616C756528746869732E61646428622C746869732E6D756C7469706C795374657028746869732E6F7074696F6E732E737465702C612929292C746869732E73746570734265747765656E28622C746869732E5F76616C756529297D2C6D6F76654C';
wwv_flow_api.g_varchar2_table(234) := '6566743A66756E6374696F6E2861297B72657475726E2D746869732E6D6F76655269676874282D61297D2C73746570526174696F3A66756E6374696F6E28297B696628746869732E6F7074696F6E732E737465703D3D3D21312972657475726E20313B76';
wwv_flow_api.g_varchar2_table(235) := '617220613D28746869732E6F7074696F6E732E626F756E64732E6D61782D746869732E6F7074696F6E732E626F756E64732E6D696E292F746869732E6F7074696F6E732E737465703B72657475726E20746869732E63616368652E706172656E742E7769';
wwv_flow_api.g_varchar2_table(236) := '6474682F617D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B66756E6374696F6E206328612C62297B72657475726E22756E646566696E6564223D3D747970656F6620613F627C7C21313A617D612E77';
wwv_flow_api.g_varchar2_table(237) := '6964676574282275692E72616E6765536C69646572426172222C612E75692E72616E6765536C69646572447261676761626C652C7B6F7074696F6E733A7B6C65667448616E646C653A6E756C6C2C726967687448616E646C653A6E756C6C2C626F756E64';
wwv_flow_api.g_varchar2_table(238) := '733A7B6D696E3A302C6D61783A3130307D2C747970653A2272616E6765536C6964657248616E646C65222C72616E67653A21312C647261673A66756E6374696F6E28297B7D2C73746F703A66756E6374696F6E28297B7D2C76616C7565733A7B6D696E3A';
wwv_flow_api.g_varchar2_table(239) := '302C6D61783A32307D2C776865656C53706565643A342C776865656C4D6F64653A6E756C6C7D2C5F76616C7565733A7B6D696E3A302C6D61783A32307D2C5F77616974696E67546F496E69743A322C5F776865656C54696D656F75743A21312C5F637265';
wwv_flow_api.g_varchar2_table(240) := '6174653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E6373732822706F736974696F6E222C22';
wwv_flow_api.g_varchar2_table(241) := '6162736F6C75746522292E6373732822746F70222C30292E616464436C617373282275692D72616E6765536C696465722D62617222292C746869732E6F7074696F6E732E6C65667448616E646C652E62696E642822696E697469616C697A65222C612E70';
wwv_flow_api.g_varchar2_table(242) := '726F787928746869732E5F6F6E496E697469616C697A65642C7468697329292E62696E6428226D6F7573657374617274222C612E70726F787928746869732E5F63616368652C7468697329292E62696E64282273746F70222C612E70726F787928746869';
wwv_flow_api.g_varchar2_table(243) := '732E5F6F6E48616E646C6553746F702C7468697329292C746869732E6F7074696F6E732E726967687448616E646C652E62696E642822696E697469616C697A65222C612E70726F787928746869732E5F6F6E496E697469616C697A65642C746869732929';
wwv_flow_api.g_varchar2_table(244) := '2E62696E6428226D6F7573657374617274222C612E70726F787928746869732E5F63616368652C7468697329292E62696E64282273746F70222C612E70726F787928746869732E5F6F6E48616E646C6553746F702C7468697329292C746869732E5F6269';
wwv_flow_api.g_varchar2_table(245) := '6E6448616E646C657328292C746869732E5F76616C7565733D746869732E6F7074696F6E732E76616C7565732C746869732E5F736574576865656C4D6F64654F7074696F6E28746869732E6F7074696F6E732E776865656C4D6F6465297D2C6465737472';
wwv_flow_api.g_varchar2_table(246) := '6F793A66756E6374696F6E28297B746869732E6F7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292C746869732E6F7074696F6E732E726967687448616E646C652E756E62696E6428222E62617222292C746869732E6F70';
wwv_flow_api.g_varchar2_table(247) := '74696F6E733D6E756C6C2C612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28612C62297B2272616E676522';
wwv_flow_api.g_varchar2_table(248) := '3D3D3D613F746869732E5F73657452616E67654F7074696F6E2862293A22776865656C5370656564223D3D3D613F746869732E5F736574576865656C53706565644F7074696F6E2862293A22776865656C4D6F6465223D3D3D612626746869732E5F7365';
wwv_flow_api.g_varchar2_table(249) := '74576865656C4D6F64654F7074696F6E2862297D2C5F73657452616E67654F7074696F6E3A66756E6374696F6E2861297B69662828226F626A65637422213D747970656F6620617C7C6E756C6C3D3D3D6129262628613D2131292C61213D3D21317C7C74';
wwv_flow_api.g_varchar2_table(250) := '6869732E6F7074696F6E732E72616E6765213D3D2131297B69662861213D3D2131297B76617220623D6328612E6D696E2C746869732E6F7074696F6E732E72616E67652E6D696E292C643D6328612E6D61782C746869732E6F7074696F6E732E72616E67';
wwv_flow_api.g_varchar2_table(251) := '652E6D6178293B746869732E6F7074696F6E732E72616E67653D7B6D696E3A622C6D61783A647D7D656C736520746869732E6F7074696F6E732E72616E67653D21313B746869732E5F7365744C65667452616E676528292C746869732E5F736574526967';
wwv_flow_api.g_varchar2_table(252) := '687452616E676528297D7D2C5F736574576865656C53706565644F7074696F6E3A66756E6374696F6E2861297B226E756D626572223D3D747970656F662061262630213D3D61262628746869732E6F7074696F6E732E776865656C53706565643D61297D';
wwv_flow_api.g_varchar2_table(253) := '2C5F736574576865656C4D6F64654F7074696F6E3A66756E6374696F6E2861297B286E756C6C3D3D3D617C7C613D3D3D21317C7C227A6F6F6D223D3D3D617C7C227363726F6C6C223D3D3D6129262628746869732E6F7074696F6E732E776865656C4D6F';
wwv_flow_api.g_varchar2_table(254) := '6465213D3D612626746869732E656C656D656E742E706172656E7428292E756E62696E6428226D6F757365776865656C2E62617222292C746869732E5F62696E644D6F757365576865656C2861292C746869732E6F7074696F6E732E776865656C4D6F64';
wwv_flow_api.g_varchar2_table(255) := '653D61297D2C5F62696E644D6F757365576865656C3A66756E6374696F6E2862297B227A6F6F6D223D3D3D623F746869732E656C656D656E742E706172656E7428292E62696E6428226D6F757365776865656C2E626172222C612E70726F787928746869';
wwv_flow_api.g_varchar2_table(256) := '732E5F6D6F757365576865656C5A6F6F6D2C7468697329293A227363726F6C6C223D3D3D622626746869732E656C656D656E742E706172656E7428292E62696E6428226D6F757365776865656C2E626172222C612E70726F787928746869732E5F6D6F75';
wwv_flow_api.g_varchar2_table(257) := '7365576865656C5363726F6C6C2C7468697329297D2C5F7365744C65667452616E67653A66756E6374696F6E28297B696628746869732E6F7074696F6E732E72616E67653D3D3D21312972657475726E21313B76617220613D746869732E5F76616C7565';
wwv_flow_api.g_varchar2_table(258) := '732E6D61782C623D7B6D696E3A21312C6D61783A21317D3B22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D696E2626746869732E6F7074696F6E732E72616E67652E6D696E213D3D21313F622E6D61';
wwv_flow_api.g_varchar2_table(259) := '783D746869732E5F6C65667448616E646C652822737562737472616374222C612C746869732E6F7074696F6E732E72616E67652E6D696E293A622E6D61783D21312C22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72';
wwv_flow_api.g_varchar2_table(260) := '616E67652E6D61782626746869732E6F7074696F6E732E72616E67652E6D6178213D3D21313F622E6D696E3D746869732E5F6C65667448616E646C652822737562737472616374222C612C746869732E6F7074696F6E732E72616E67652E6D6178293A62';
wwv_flow_api.g_varchar2_table(261) := '2E6D696E3D21312C746869732E5F6C65667448616E646C6528226F7074696F6E222C2272616E6765222C62297D2C5F736574526967687452616E67653A66756E6374696F6E28297B76617220613D746869732E5F76616C7565732E6D696E2C623D7B6D69';
wwv_flow_api.g_varchar2_table(262) := '6E3A21312C6D61783A21317D3B22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D696E2626746869732E6F7074696F6E732E72616E67652E6D696E213D3D21313F622E6D696E3D746869732E5F726967';
wwv_flow_api.g_varchar2_table(263) := '687448616E646C652822616464222C612C746869732E6F7074696F6E732E72616E67652E6D696E293A622E6D696E3D21312C22756E646566696E656422213D747970656F6620746869732E6F7074696F6E732E72616E67652E6D61782626746869732E6F';
wwv_flow_api.g_varchar2_table(264) := '7074696F6E732E72616E67652E6D6178213D3D21313F622E6D61783D746869732E5F726967687448616E646C652822616464222C612C746869732E6F7074696F6E732E72616E67652E6D6178293A622E6D61783D21312C746869732E5F72696768744861';
wwv_flow_api.g_varchar2_table(265) := '6E646C6528226F7074696F6E222C2272616E6765222C62297D2C5F6465616374697661746552616E67653A66756E6374696F6E28297B746869732E5F6C65667448616E646C6528226F7074696F6E222C2272616E6765222C2131292C746869732E5F7269';
wwv_flow_api.g_varchar2_table(266) := '67687448616E646C6528226F7074696F6E222C2272616E6765222C2131297D2C5F7265616374697661746552616E67653A66756E6374696F6E28297B746869732E5F73657452616E67654F7074696F6E28746869732E6F7074696F6E732E72616E676529';
wwv_flow_api.g_varchar2_table(267) := '7D2C5F6F6E496E697469616C697A65643A66756E6374696F6E28297B746869732E5F77616974696E67546F496E69742D2D2C303D3D3D746869732E5F77616974696E67546F496E69742626746869732E5F696E69744D6528297D2C5F696E69744D653A66';
wwv_flow_api.g_varchar2_table(268) := '756E6374696F6E28297B746869732E5F636163686528292C746869732E6D696E28746869732E5F76616C7565732E6D696E292C746869732E6D617828746869732E5F76616C7565732E6D6178293B76617220613D746869732E5F6C65667448616E646C65';
wwv_flow_api.g_varchar2_table(269) := '2822706F736974696F6E22292C623D746869732E5F726967687448616E646C652822706F736974696F6E22292B746869732E6F7074696F6E732E726967687448616E646C652E776964746828293B746869732E656C656D656E742E6F6666736574287B6C';
wwv_flow_api.g_varchar2_table(270) := '6566743A617D292C746869732E656C656D656E742E63737328227769647468222C622D61297D2C5F6C65667448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F68616E646C6550726F787928746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(271) := '6C65667448616E646C652C617267756D656E7473297D2C5F726967687448616E646C653A66756E6374696F6E28297B72657475726E20746869732E5F68616E646C6550726F787928746869732E6F7074696F6E732E726967687448616E646C652C617267';
wwv_flow_api.g_varchar2_table(272) := '756D656E7473297D2C5F68616E646C6550726F78793A66756E6374696F6E28612C62297B76617220633D41727261792E70726F746F747970652E736C6963652E63616C6C2862293B72657475726E20615B746869732E6F7074696F6E732E747970655D2E';
wwv_flow_api.g_varchar2_table(273) := '6170706C7928612C63297D2C5F63616368653A66756E6374696F6E28297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F63616368652E6170706C792874686973292C746869732E5F636163686548616E64';
wwv_flow_api.g_varchar2_table(274) := '6C657328297D2C5F636163686548616E646C65733A66756E6374696F6E28297B746869732E63616368652E726967687448616E646C653D7B7D2C746869732E63616368652E726967687448616E646C652E77696474683D746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(275) := '726967687448616E646C652E776964746828292C746869732E63616368652E726967687448616E646C652E6F66667365743D746869732E6F7074696F6E732E726967687448616E646C652E6F666673657428292C746869732E63616368652E6C65667448';
wwv_flow_api.g_varchar2_table(276) := '616E646C653D7B7D2C746869732E63616368652E6C65667448616E646C652E6F66667365743D746869732E6F7074696F6E732E6C65667448616E646C652E6F666673657428297D2C5F6D6F75736553746172743A66756E6374696F6E2862297B612E7569';
wwv_flow_api.g_varchar2_table(277) := '2E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6D6F75736553746172742E6170706C7928746869732C5B625D292C746869732E5F6465616374697661746552616E676528297D2C5F6D6F75736553746F703A66756E63';
wwv_flow_api.g_varchar2_table(278) := '74696F6E2862297B612E75692E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F6D6F75736553746F702E6170706C7928746869732C5B625D292C746869732E5F636163686548616E646C657328292C746869732E5F7661';
wwv_flow_api.g_varchar2_table(279) := '6C7565732E6D696E3D746869732E5F6C65667448616E646C65282276616C756522292C746869732E5F76616C7565732E6D61783D746869732E5F726967687448616E646C65282276616C756522292C746869732E5F7265616374697661746552616E6765';
wwv_flow_api.g_varchar2_table(280) := '28292C746869732E5F6C65667448616E646C6528292E74726967676572282273746F7022292C746869732E5F726967687448616E646C6528292E74726967676572282273746F7022297D2C5F6F6E447261674C65667448616E646C653A66756E6374696F';
wwv_flow_api.g_varchar2_table(281) := '6E28612C62297B696628746869732E5F636163686549664E656365737361727928292C622E656C656D656E745B305D3D3D3D746869732E6F7074696F6E732E6C65667448616E646C655B305D297B696628746869732E5F737769746368656456616C7565';
wwv_flow_api.g_varchar2_table(282) := '7328292972657475726E20746869732E5F73776974636848616E646C657328292C766F696420746869732E5F6F6E44726167526967687448616E646C6528612C62293B746869732E5F76616C7565732E6D696E3D622E76616C75652C746869732E636163';
wwv_flow_api.g_varchar2_table(283) := '68652E6F66667365742E6C6566743D622E6F66667365742E6C6566742C746869732E63616368652E6C65667448616E646C652E6F66667365743D622E6F66667365742C746869732E5F706F736974696F6E42617228297D7D2C5F6F6E4472616752696768';
wwv_flow_api.g_varchar2_table(284) := '7448616E646C653A66756E6374696F6E28612C62297B696628746869732E5F636163686549664E656365737361727928292C622E656C656D656E745B305D3D3D3D746869732E6F7074696F6E732E726967687448616E646C655B305D297B696628746869';
wwv_flow_api.g_varchar2_table(285) := '732E5F737769746368656456616C75657328292972657475726E20746869732E5F73776974636848616E646C657328292C766F696420746869732E5F6F6E447261674C65667448616E646C6528612C62293B746869732E5F76616C7565732E6D61783D62';
wwv_flow_api.g_varchar2_table(286) := '2E76616C75652C746869732E63616368652E726967687448616E646C652E6F66667365743D622E6F66667365742C746869732E5F706F736974696F6E42617228297D7D2C5F706F736974696F6E4261723A66756E6374696F6E28297B76617220613D7468';
wwv_flow_api.g_varchar2_table(287) := '69732E63616368652E726967687448616E646C652E6F66667365742E6C6566742B746869732E63616368652E726967687448616E646C652E77696474682D746869732E63616368652E6C65667448616E646C652E6F66667365742E6C6566743B74686973';
wwv_flow_api.g_varchar2_table(288) := '2E63616368652E77696474682E696E6E65723D612C746869732E656C656D656E742E63737328227769647468222C61292E6F6666736574287B6C6566743A746869732E63616368652E6C65667448616E646C652E6F66667365742E6C6566747D297D2C5F';
wwv_flow_api.g_varchar2_table(289) := '6F6E48616E646C6553746F703A66756E6374696F6E28297B746869732E5F7365744C65667452616E676528292C746869732E5F736574526967687452616E676528297D2C5F737769746368656456616C7565733A66756E6374696F6E28297B6966287468';
wwv_flow_api.g_varchar2_table(290) := '69732E6D696E28293E746869732E6D61782829297B76617220613D746869732E5F76616C7565732E6D696E3B72657475726E20746869732E5F76616C7565732E6D696E3D746869732E5F76616C7565732E6D61782C746869732E5F76616C7565732E6D61';
wwv_flow_api.g_varchar2_table(291) := '783D612C21307D72657475726E21317D2C5F73776974636848616E646C65733A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E6C65667448616E646C653B746869732E6F7074696F6E732E6C65667448616E646C653D746869';
wwv_flow_api.g_varchar2_table(292) := '732E6F7074696F6E732E726967687448616E646C652C746869732E6F7074696F6E732E726967687448616E646C653D612C746869732E5F6C65667448616E646C6528226F7074696F6E222C2269734C656674222C2130292C746869732E5F726967687448';
wwv_flow_api.g_varchar2_table(293) := '616E646C6528226F7074696F6E222C2269734C656674222C2131292C746869732E5F62696E6448616E646C657328292C746869732E5F636163686548616E646C657328297D2C5F62696E6448616E646C65733A66756E6374696F6E28297B746869732E6F';
wwv_flow_api.g_varchar2_table(294) := '7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292E62696E642822736C69646572447261672E626172207570646174652E626172206D6F76696E672E626172222C612E70726F787928746869732E5F6F6E447261674C6566';
wwv_flow_api.g_varchar2_table(295) := '7448616E646C652C7468697329292C746869732E6F7074696F6E732E726967687448616E646C652E756E62696E6428222E62617222292E62696E642822736C69646572447261672E626172207570646174652E626172206D6F76696E672E626172222C61';
wwv_flow_api.g_varchar2_table(296) := '2E70726F787928746869732E5F6F6E44726167526967687448616E646C652C7468697329297D2C5F636F6E73747261696E74506F736974696F6E3A66756E6374696F6E2862297B76617220632C643D7B7D3B72657475726E20642E6C6566743D612E7569';
wwv_flow_api.g_varchar2_table(297) := '2E72616E6765536C69646572447261676761626C652E70726F746F747970652E5F636F6E73747261696E74506F736974696F6E2E6170706C7928746869732C5B625D292C642E6C6566743D746869732E5F6C65667448616E646C652822706F736974696F';
wwv_flow_api.g_varchar2_table(298) := '6E222C642E6C656674292C633D746869732E5F726967687448616E646C652822706F736974696F6E222C642E6C6566742B746869732E63616368652E77696474682E6F757465722D746869732E63616368652E726967687448616E646C652E7769647468';
wwv_flow_api.g_varchar2_table(299) := '292C642E77696474683D632D642E6C6566742B746869732E63616368652E726967687448616E646C652E77696474682C647D2C5F6170706C79506F736974696F6E3A66756E6374696F6E2862297B612E75692E72616E6765536C69646572447261676761';
wwv_flow_api.g_varchar2_table(300) := '626C652E70726F746F747970652E5F6170706C79506F736974696F6E2E6170706C7928746869732C5B622E6C6566745D292C746869732E656C656D656E742E776964746828622E7769647468297D2C5F6D6F757365576865656C5A6F6F6D3A66756E6374';
wwv_flow_api.g_varchar2_table(301) := '696F6E28622C632C642C65297B69662821746869732E656E61626C65642972657475726E21313B76617220663D746869732E5F76616C7565732E6D696E2B28746869732E5F76616C7565732E6D61782D746869732E5F76616C7565732E6D696E292F322C';
wwv_flow_api.g_varchar2_table(302) := '673D7B7D2C683D7B7D3B72657475726E20746869732E6F7074696F6E732E72616E67653D3D3D21317C7C746869732E6F7074696F6E732E72616E67652E6D696E3D3D3D21313F28672E6D61783D662C682E6D696E3D66293A28672E6D61783D662D746869';
wwv_flow_api.g_varchar2_table(303) := '732E6F7074696F6E732E72616E67652E6D696E2F322C682E6D696E3D662B746869732E6F7074696F6E732E72616E67652E6D696E2F32292C746869732E6F7074696F6E732E72616E6765213D3D21312626746869732E6F7074696F6E732E72616E67652E';
wwv_flow_api.g_varchar2_table(304) := '6D6178213D3D2131262628672E6D696E3D662D746869732E6F7074696F6E732E72616E67652E6D61782F322C682E6D61783D662B746869732E6F7074696F6E732E72616E67652E6D61782F32292C746869732E5F6C65667448616E646C6528226F707469';
wwv_flow_api.g_varchar2_table(305) := '6F6E222C2272616E6765222C67292C746869732E5F726967687448616E646C6528226F7074696F6E222C2272616E6765222C68292C636C65617254696D656F757428746869732E5F776865656C54696D656F7574292C746869732E5F776865656C54696D';
wwv_flow_api.g_varchar2_table(306) := '656F75743D73657454696D656F757428612E70726F787928746869732E5F776865656C53746F702C74686973292C323030292C746869732E7A6F6F6D496E28652A746869732E6F7074696F6E732E776865656C5370656564292C21317D2C5F6D6F757365';
wwv_flow_api.g_varchar2_table(307) := '576865656C5363726F6C6C3A66756E6374696F6E28622C632C642C65297B72657475726E20746869732E656E61626C65643F28746869732E5F776865656C54696D656F75743D3D3D21313F746869732E73746172745363726F6C6C28293A636C65617254';
wwv_flow_api.g_varchar2_table(308) := '696D656F757428746869732E5F776865656C54696D656F7574292C746869732E5F776865656C54696D656F75743D73657454696D656F757428612E70726F787928746869732E5F776865656C53746F702C74686973292C323030292C746869732E736372';
wwv_flow_api.g_varchar2_table(309) := '6F6C6C4C65667428652A746869732E6F7074696F6E732E776865656C5370656564292C2131293A21317D2C5F776865656C53746F703A66756E6374696F6E28297B746869732E73746F705363726F6C6C28292C746869732E5F776865656C54696D656F75';
wwv_flow_api.g_varchar2_table(310) := '743D21317D2C6D696E3A66756E6374696F6E2861297B72657475726E20746869732E5F6C65667448616E646C65282276616C7565222C61297D2C6D61783A66756E6374696F6E2861297B72657475726E20746869732E5F726967687448616E646C652822';
wwv_flow_api.g_varchar2_table(311) := '76616C7565222C61297D2C73746172745363726F6C6C3A66756E6374696F6E28297B746869732E5F6465616374697661746552616E676528297D2C73746F705363726F6C6C3A66756E6374696F6E28297B746869732E5F7265616374697661746552616E';
wwv_flow_api.g_varchar2_table(312) := '676528292C746869732E5F747269676765724D6F7573654576656E74282273746F7022292C746869732E5F6C65667448616E646C6528292E74726967676572282273746F7022292C746869732E5F726967687448616E646C6528292E7472696767657228';
wwv_flow_api.g_varchar2_table(313) := '2273746F7022297D2C7363726F6C6C4C6566743A66756E6374696F6E2861297B72657475726E20613D617C7C312C303E613F746869732E7363726F6C6C5269676874282D61293A28613D746869732E5F6C65667448616E646C6528226D6F76654C656674';
wwv_flow_api.g_varchar2_table(314) := '222C61292C746869732E5F726967687448616E646C6528226D6F76654C656674222C61292C746869732E75706461746528292C766F696420746869732E5F747269676765724D6F7573654576656E7428227363726F6C6C2229297D2C7363726F6C6C5269';
wwv_flow_api.g_varchar2_table(315) := '6768743A66756E6374696F6E2861297B72657475726E20613D617C7C312C303E613F746869732E7363726F6C6C4C656674282D61293A28613D746869732E5F726967687448616E646C6528226D6F76655269676874222C61292C746869732E5F6C656674';
wwv_flow_api.g_varchar2_table(316) := '48616E646C6528226D6F76655269676874222C61292C746869732E75706461746528292C766F696420746869732E5F747269676765724D6F7573654576656E7428227363726F6C6C2229297D2C7A6F6F6D496E3A66756E6374696F6E2861297B69662861';
wwv_flow_api.g_varchar2_table(317) := '3D617C7C312C303E612972657475726E20746869732E7A6F6F6D4F7574282D61293B76617220623D746869732E5F726967687448616E646C6528226D6F76654C656674222C61293B613E62262628622F3D322C746869732E5F726967687448616E646C65';
wwv_flow_api.g_varchar2_table(318) := '28226D6F76655269676874222C6229292C746869732E5F6C65667448616E646C6528226D6F76655269676874222C62292C746869732E75706461746528292C746869732E5F747269676765724D6F7573654576656E7428227A6F6F6D22297D2C7A6F6F6D';
wwv_flow_api.g_varchar2_table(319) := '4F75743A66756E6374696F6E2861297B696628613D617C7C312C303E612972657475726E20746869732E7A6F6F6D496E282D61293B76617220623D746869732E5F726967687448616E646C6528226D6F76655269676874222C61293B613E62262628622F';
wwv_flow_api.g_varchar2_table(320) := '3D322C746869732E5F726967687448616E646C6528226D6F76654C656674222C6229292C746869732E5F6C65667448616E646C6528226D6F76654C656674222C62292C746869732E75706461746528292C746869732E5F747269676765724D6F75736545';
wwv_flow_api.g_varchar2_table(321) := '76656E7428227A6F6F6D22297D2C76616C7565733A66756E6374696F6E28612C62297B69662822756E646566696E656422213D747970656F662061262622756E646566696E656422213D747970656F662062297B76617220633D4D6174682E6D696E2861';
wwv_flow_api.g_varchar2_table(322) := '2C62292C643D4D6174682E6D617828612C62293B0A746869732E5F6465616374697661746552616E676528292C746869732E6F7074696F6E732E6C65667448616E646C652E756E62696E6428222E62617222292C746869732E6F7074696F6E732E726967';
wwv_flow_api.g_varchar2_table(323) := '687448616E646C652E756E62696E6428222E62617222292C746869732E5F76616C7565732E6D696E3D746869732E5F6C65667448616E646C65282276616C7565222C63292C746869732E5F76616C7565732E6D61783D746869732E5F726967687448616E';
wwv_flow_api.g_varchar2_table(324) := '646C65282276616C7565222C64292C746869732E5F62696E6448616E646C657328292C746869732E5F7265616374697661746552616E676528292C746869732E75706461746528297D72657475726E7B6D696E3A746869732E5F76616C7565732E6D696E';
wwv_flow_api.g_varchar2_table(325) := '2C6D61783A746869732E5F76616C7565732E6D61787D7D2C7570646174653A66756E6374696F6E28297B746869732E5F76616C7565732E6D696E3D746869732E6D696E28292C746869732E5F76616C7565732E6D61783D746869732E6D617828292C7468';
wwv_flow_api.g_varchar2_table(326) := '69732E5F636163686528292C746869732E5F706F736974696F6E42617228297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B66756E6374696F6E206328622C632C642C65297B746869732E6C616265';
wwv_flow_api.g_varchar2_table(327) := '6C313D622C746869732E6C6162656C323D632C746869732E747970653D642C746869732E6F7074696F6E733D652C746869732E68616E646C65313D746869732E6C6162656C315B746869732E747970655D28226F7074696F6E222C2268616E646C652229';
wwv_flow_api.g_varchar2_table(328) := '2C746869732E68616E646C65323D746869732E6C6162656C325B746869732E747970655D28226F7074696F6E222C2268616E646C6522292C746869732E63616368653D6E756C6C2C746869732E6C6566743D622C746869732E72696768743D632C746869';
wwv_flow_api.g_varchar2_table(329) := '732E6D6F76696E673D21312C746869732E696E697469616C697A65643D21312C746869732E7570646174696E673D21312C746869732E496E69743D66756E6374696F6E28297B746869732E42696E6448616E646C6528746869732E68616E646C6531292C';
wwv_flow_api.g_varchar2_table(330) := '746869732E42696E6448616E646C6528746869732E68616E646C6532292C2273686F77223D3D3D746869732E6F7074696F6E732E73686F773F2873657454696D656F757428612E70726F787928746869732E506F736974696F6E4C6162656C732C746869';
wwv_flow_api.g_varchar2_table(331) := '73292C31292C746869732E696E697469616C697A65643D2130293A73657454696D656F757428612E70726F787928746869732E4166746572496E69742C74686973292C316533292C746869732E5F726573697A6550726F78793D612E70726F7879287468';
wwv_flow_api.g_varchar2_table(332) := '69732E6F6E57696E646F77526573697A652C74686973292C612877696E646F77292E726573697A6528746869732E5F726573697A6550726F7879297D2C746869732E44657374726F793D66756E6374696F6E28297B746869732E5F726573697A6550726F';
wwv_flow_api.g_varchar2_table(333) := '7879262628612877696E646F77292E756E62696E642822726573697A65222C746869732E5F726573697A6550726F7879292C746869732E5F726573697A6550726F78793D6E756C6C2C746869732E68616E646C65312E756E62696E6428222E706F736974';
wwv_flow_api.g_varchar2_table(334) := '696F6E6E657222292C746869732E68616E646C65313D6E756C6C2C746869732E68616E646C65322E756E62696E6428222E706F736974696F6E6E657222292C746869732E68616E646C65323D6E756C6C2C746869732E6C6162656C313D6E756C6C2C7468';
wwv_flow_api.g_varchar2_table(335) := '69732E6C6162656C323D6E756C6C2C746869732E6C6566743D6E756C6C2C746869732E72696768743D6E756C6C292C746869732E63616368653D6E756C6C7D2C746869732E4166746572496E69743D66756E6374696F6E28297B746869732E696E697469';
wwv_flow_api.g_varchar2_table(336) := '616C697A65643D21307D2C746869732E43616368653D66756E6374696F6E28297B226E6F6E6522213D3D746869732E6C6162656C312E6373732822646973706C61792229262628746869732E63616368653D7B7D2C746869732E63616368652E6C616265';
wwv_flow_api.g_varchar2_table(337) := '6C313D7B7D2C746869732E63616368652E6C6162656C323D7B7D2C746869732E63616368652E68616E646C65313D7B7D2C746869732E63616368652E68616E646C65323D7B7D2C746869732E63616368652E6F6666736574506172656E743D7B7D2C7468';
wwv_flow_api.g_varchar2_table(338) := '69732E4361636865456C656D656E7428746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E4361636865456C656D656E7428746869732E6C6162656C322C746869732E63616368652E6C6162656C32292C74686973';
wwv_flow_api.g_varchar2_table(339) := '2E4361636865456C656D656E7428746869732E68616E646C65312C746869732E63616368652E68616E646C6531292C746869732E4361636865456C656D656E7428746869732E68616E646C65322C746869732E63616368652E68616E646C6532292C7468';
wwv_flow_api.g_varchar2_table(340) := '69732E4361636865456C656D656E7428746869732E6C6162656C312E6F6666736574506172656E7428292C746869732E63616368652E6F6666736574506172656E7429297D2C746869732E436163686549664E65636573736172793D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(341) := '28297B6E756C6C3D3D3D746869732E63616368653F746869732E436163686528293A28746869732E4361636865576964746828746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E43616368655769647468287468';
wwv_flow_api.g_varchar2_table(342) := '69732E6C6162656C322C746869732E63616368652E6C6162656C32292C746869732E436163686548656967687428746869732E6C6162656C312C746869732E63616368652E6C6162656C31292C746869732E436163686548656967687428746869732E6C';
wwv_flow_api.g_varchar2_table(343) := '6162656C322C746869732E63616368652E6C6162656C32292C746869732E4361636865576964746828746869732E6C6162656C312E6F6666736574506172656E7428292C746869732E63616368652E6F6666736574506172656E7429297D2C746869732E';
wwv_flow_api.g_varchar2_table(344) := '4361636865456C656D656E743D66756E6374696F6E28612C62297B746869732E4361636865576964746828612C62292C746869732E436163686548656967687428612C62292C622E6F66667365743D612E6F666673657428292C622E6D617267696E3D7B';
wwv_flow_api.g_varchar2_table(345) := '6C6566743A746869732E5061727365506978656C7328226D617267696E4C656674222C61292C72696768743A746869732E5061727365506978656C7328226D617267696E5269676874222C61297D2C622E626F726465723D7B6C6566743A746869732E50';
wwv_flow_api.g_varchar2_table(346) := '61727365506978656C732822626F726465724C6566745769647468222C61292C72696768743A746869732E5061727365506978656C732822626F7264657252696768745769647468222C61297D7D2C746869732E436163686557696474683D66756E6374';
wwv_flow_api.g_varchar2_table(347) := '696F6E28612C62297B622E77696474683D612E776964746828292C622E6F7574657257696474683D612E6F75746572576964746828297D2C746869732E43616368654865696768743D66756E6374696F6E28612C62297B622E6F75746572486569676874';
wwv_flow_api.g_varchar2_table(348) := '4D617267696E3D612E6F75746572486569676874282130297D2C746869732E5061727365506978656C733D66756E6374696F6E28612C62297B72657475726E207061727365496E7428622E6373732861292C3130297C7C307D2C746869732E42696E6448';
wwv_flow_api.g_varchar2_table(349) := '616E646C653D66756E6374696F6E2862297B622E62696E6428227570646174696E672E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C655570646174696E672C7468697329292C622E62696E6428227570646174652E';
wwv_flow_api.g_varchar2_table(350) := '706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C65557064617465642C7468697329292C622E62696E6428226D6F76696E672E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C654D6F';
wwv_flow_api.g_varchar2_table(351) := '76696E672C7468697329292C622E62696E64282273746F702E706F736974696F6E6E6572222C612E70726F787928746869732E6F6E48616E646C6553746F702C7468697329297D2C746869732E506F736974696F6E4C6162656C733D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(352) := '28297B696628746869732E436163686549664E656365737361727928292C6E756C6C213D3D746869732E6361636865297B76617220613D746869732E476574526177506F736974696F6E28746869732E63616368652E6C6162656C312C746869732E6361';
wwv_flow_api.g_varchar2_table(353) := '6368652E68616E646C6531292C623D746869732E476574526177506F736974696F6E28746869732E63616368652E6C6162656C322C746869732E63616368652E68616E646C6532293B746869732E6C6162656C315B645D28226F7074696F6E222C226973';
wwv_flow_api.g_varchar2_table(354) := '4C65667422293F746869732E436F6E73747261696E74506F736974696F6E7328612C62293A746869732E436F6E73747261696E74506F736974696F6E7328622C61292C746869732E506F736974696F6E4C6162656C28746869732E6C6162656C312C612E';
wwv_flow_api.g_varchar2_table(355) := '6C6566742C746869732E63616368652E6C6162656C31292C746869732E506F736974696F6E4C6162656C28746869732E6C6162656C322C622E6C6566742C746869732E63616368652E6C6162656C32297D7D2C746869732E506F736974696F6E4C616265';
wwv_flow_api.g_varchar2_table(356) := '6C3D66756E6374696F6E28612C622C63297B76617220642C652C662C673D746869732E63616368652E6F6666736574506172656E742E6F66667365742E6C6566742B746869732E63616368652E6F6666736574506172656E742E626F726465722E6C6566';
wwv_flow_api.g_varchar2_table(357) := '743B672D623E3D303F28612E63737328227269676874222C2222292C612E6F6666736574287B6C6566743A627D29293A28643D672B746869732E63616368652E6F6666736574506172656E742E77696474682C653D622B632E6D617267696E2E6C656674';
wwv_flow_api.g_varchar2_table(358) := '2B632E6F7574657257696474682B632E6D617267696E2E72696768742C663D642D652C612E63737328226C656674222C2222292C612E63737328227269676874222C6629297D2C746869732E436F6E73747261696E74506F736974696F6E733D66756E63';
wwv_flow_api.g_varchar2_table(359) := '74696F6E28612C62297B28612E63656E7465723C622E63656E7465722626612E6F7574657252696768743E622E6F757465724C6566747C7C612E63656E7465723E622E63656E7465722626622E6F7574657252696768743E612E6F757465724C65667429';
wwv_flow_api.g_varchar2_table(360) := '262628613D746869732E6765744C656674506F736974696F6E28612C62292C623D746869732E6765745269676874506F736974696F6E28612C6229297D2C746869732E6765744C656674506F736974696F6E3D66756E6374696F6E28612C62297B766172';
wwv_flow_api.g_varchar2_table(361) := '20633D28622E63656E7465722B612E63656E746572292F322C643D632D612E63616368652E6F7574657257696474682D612E63616368652E6D617267696E2E72696768742B612E63616368652E626F726465722E6C6566743B72657475726E20612E6C65';
wwv_flow_api.g_varchar2_table(362) := '66743D642C617D2C746869732E6765745269676874506F736974696F6E3D66756E6374696F6E28612C62297B76617220633D28622E63656E7465722B612E63656E746572292F323B72657475726E20622E6C6566743D632B622E63616368652E6D617267';
wwv_flow_api.g_varchar2_table(363) := '696E2E6C6566742B622E63616368652E626F726465722E6C6566742C627D2C746869732E53686F7749664E65636573736172793D66756E6374696F6E28297B2273686F77223D3D3D746869732E6F7074696F6E732E73686F777C7C746869732E6D6F7669';
wwv_flow_api.g_varchar2_table(364) := '6E677C7C21746869732E696E697469616C697A65647C7C746869732E7570646174696E677C7C28746869732E6C6162656C312E73746F702821302C2130292E66616465496E28746869732E6F7074696F6E732E6475726174696F6E496E7C7C30292C7468';
wwv_flow_api.g_varchar2_table(365) := '69732E6C6162656C322E73746F702821302C2130292E66616465496E28746869732E6F7074696F6E732E6475726174696F6E496E7C7C30292C746869732E6D6F76696E673D2130297D2C746869732E4869646549664E65656465643D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(366) := '28297B746869732E6D6F76696E673D3D3D2130262628746869732E6C6162656C312E73746F702821302C2130292E64656C617928746869732E6F7074696F6E732E64656C61794F75747C7C30292E666164654F757428746869732E6F7074696F6E732E64';
wwv_flow_api.g_varchar2_table(367) := '75726174696F6E4F75747C7C30292C746869732E6C6162656C322E73746F702821302C2130292E64656C617928746869732E6F7074696F6E732E64656C61794F75747C7C30292E666164654F757428746869732E6F7074696F6E732E6475726174696F6E';
wwv_flow_api.g_varchar2_table(368) := '4F75747C7C30292C746869732E6D6F76696E673D2131297D2C746869732E6F6E48616E646C654D6F76696E673D66756E6374696F6E28612C62297B746869732E53686F7749664E656365737361727928292C746869732E436163686549664E6563657373';
wwv_flow_api.g_varchar2_table(369) := '61727928292C746869732E55706461746548616E646C65506F736974696F6E2862292C746869732E506F736974696F6E4C6162656C7328297D2C746869732E6F6E48616E646C655570646174696E673D66756E6374696F6E28297B746869732E75706461';
wwv_flow_api.g_varchar2_table(370) := '74696E673D21307D2C746869732E6F6E48616E646C65557064617465643D66756E6374696F6E28297B746869732E7570646174696E673D21312C746869732E63616368653D6E756C6C7D2C746869732E6F6E48616E646C6553746F703D66756E6374696F';
wwv_flow_api.g_varchar2_table(371) := '6E28297B746869732E4869646549664E656564656428297D2C746869732E6F6E57696E646F77526573697A653D66756E6374696F6E28297B746869732E63616368653D6E756C6C7D2C746869732E55706461746548616E646C65506F736974696F6E3D66';
wwv_flow_api.g_varchar2_table(372) := '756E6374696F6E2861297B6E756C6C213D3D746869732E6361636865262628612E656C656D656E745B305D3D3D3D746869732E68616E646C65315B305D3F746869732E557064617465506F736974696F6E28612C746869732E63616368652E68616E646C';
wwv_flow_api.g_varchar2_table(373) := '6531293A746869732E557064617465506F736974696F6E28612C746869732E63616368652E68616E646C653229297D2C746869732E557064617465506F736974696F6E3D66756E6374696F6E28612C62297B622E6F66667365743D612E6F66667365742C';
wwv_flow_api.g_varchar2_table(374) := '622E76616C75653D612E76616C75657D2C746869732E476574526177506F736974696F6E3D66756E6374696F6E28612C62297B76617220633D622E6F66667365742E6C6566742B622E6F7574657257696474682F322C643D632D612E6F75746572576964';
wwv_flow_api.g_varchar2_table(375) := '74682F322C653D642B612E6F7574657257696474682D612E626F726465722E6C6566742D612E626F726465722E72696768742C663D642D612E6D617267696E2E6C6566742D612E626F726465722E6C6566742C673D622E6F66667365742E746F702D612E';
wwv_flow_api.g_varchar2_table(376) := '6F757465724865696768744D617267696E3B72657475726E7B6C6566743A642C6F757465724C6566743A662C746F703A672C72696768743A652C6F7574657252696768743A662B612E6F7574657257696474682B612E6D617267696E2E6C6566742B612E';
wwv_flow_api.g_varchar2_table(377) := '6D617267696E2E72696768742C63616368653A612C63656E7465723A637D7D2C746869732E496E697428297D612E776964676574282275692E72616E6765536C696465724C6162656C222C612E75692E72616E6765536C696465724D6F757365546F7563';
wwv_flow_api.g_varchar2_table(378) := '682C7B6F7074696F6E733A7B68616E646C653A6E756C6C2C666F726D61747465723A21312C68616E646C65547970653A2272616E6765536C6964657248616E646C65222C73686F773A2273686F77222C6475726174696F6E496E3A302C6475726174696F';
wwv_flow_api.g_varchar2_table(379) := '6E4F75743A3530302C64656C61794F75743A3530302C69734C6566743A21317D2C63616368653A6E756C6C2C5F706F736974696F6E6E65723A6E756C6C2C5F76616C7565436F6E7461696E65723A6E756C6C2C5F696E6E6572456C656D656E743A6E756C';
wwv_flow_api.g_varchar2_table(380) := '6C2C5F76616C75653A6E756C6C2C5F6372656174653A66756E6374696F6E28297B746869732E6F7074696F6E732E69734C6566743D746869732E5F68616E646C6528226F7074696F6E222C2269734C65667422292C746869732E656C656D656E742E6164';
wwv_flow_api.g_varchar2_table(381) := '64436C617373282275692D72616E6765536C696465722D6C6162656C22292E6373732822706F736974696F6E222C226162736F6C75746522292E6373732822646973706C6179222C22626C6F636B22292C746869732E5F637265617465456C656D656E74';
wwv_flow_api.g_varchar2_table(382) := '7328292C746869732E5F746F67676C65436C61737328292C746869732E6F7074696F6E732E68616E646C652E62696E6428226D6F76696E672E6C6162656C222C612E70726F787928746869732E5F6F6E4D6F76696E672C7468697329292E62696E642822';
wwv_flow_api.g_varchar2_table(383) := '7570646174652E6C6162656C222C612E70726F787928746869732E5F6F6E5570646174652C7468697329292E62696E6428227377697463682E6C6162656C222C612E70726F787928746869732E5F6F6E5377697463682C7468697329292C2273686F7722';
wwv_flow_api.g_varchar2_table(384) := '213D3D746869732E6F7074696F6E732E73686F772626746869732E656C656D656E742E6869646528292C746869732E5F6D6F757365496E697428297D2C64657374726F793A66756E6374696F6E28297B746869732E6F7074696F6E732E68616E646C652E';
wwv_flow_api.g_varchar2_table(385) := '756E62696E6428222E6C6162656C22292C746869732E6F7074696F6E732E68616E646C653D6E756C6C2C746869732E5F76616C7565436F6E7461696E65723D6E756C6C2C746869732E5F696E6E6572456C656D656E743D6E756C6C2C746869732E656C65';
wwv_flow_api.g_varchar2_table(386) := '6D656E742E656D70747928292C746869732E5F706F736974696F6E6E6572262628746869732E5F706F736974696F6E6E65722E44657374726F7928292C746869732E5F706F736974696F6E6E65723D6E756C6C292C612E75692E72616E6765536C696465';
wwv_flow_api.g_varchar2_table(387) := '724D6F757365546F7563682E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F637265617465456C656D656E74733A66756E6374696F6E28297B746869732E5F76616C7565436F6E7461696E65723D6128223C6469762063';
wwv_flow_api.g_varchar2_table(388) := '6C6173733D2775692D72616E6765536C696465722D6C6162656C2D76616C756527202F3E22292E617070656E64546F28746869732E656C656D656E74292C746869732E5F696E6E6572456C656D656E743D6128223C64697620636C6173733D2775692D72';
wwv_flow_api.g_varchar2_table(389) := '616E6765536C696465722D6C6162656C2D696E6E657227202F3E22292E617070656E64546F28746869732E656C656D656E74297D2C5F68616E646C653A66756E6374696F6E28297B76617220613D41727261792E70726F746F747970652E736C6963652E';
wwv_flow_api.g_varchar2_table(390) := '6170706C7928617267756D656E7473293B72657475726E20746869732E6F7074696F6E732E68616E646C655B746869732E6F7074696F6E732E68616E646C65547970655D2E6170706C7928746869732E6F7074696F6E732E68616E646C652C61297D2C5F';
wwv_flow_api.g_varchar2_table(391) := '7365744F7074696F6E3A66756E6374696F6E28612C62297B2273686F77223D3D3D613F746869732E5F75706461746553686F774F7074696F6E2862293A28226475726174696F6E496E223D3D3D617C7C226475726174696F6E4F7574223D3D3D617C7C22';
wwv_flow_api.g_varchar2_table(392) := '64656C61794F7574223D3D3D61292626746869732E5F7570646174654475726174696F6E7328612C62292C746869732E5F736574466F726D61747465724F7074696F6E28612C62297D2C5F736574466F726D61747465724F7074696F6E3A66756E637469';
wwv_flow_api.g_varchar2_table(393) := '6F6E28612C62297B22666F726D6174746572223D3D3D612626282266756E6374696F6E223D3D747970656F6620627C7C623D3D3D213129262628746869732E6F7074696F6E732E666F726D61747465723D622C746869732E5F646973706C617928746869';
wwv_flow_api.g_varchar2_table(394) := '732E5F76616C756529297D2C5F75706461746553686F774F7074696F6E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E73686F773D612C2273686F7722213D3D746869732E6F7074696F6E732E73686F773F28746869732E656C656D65';
wwv_flow_api.g_varchar2_table(395) := '6E742E6869646528292C746869732E5F706F736974696F6E6E65722E6D6F76696E673D2131293A28746869732E656C656D656E742E73686F7728292C746869732E5F646973706C617928746869732E6F7074696F6E732E68616E646C655B746869732E6F';
wwv_flow_api.g_varchar2_table(396) := '7074696F6E732E68616E646C65547970655D282276616C75652229292C746869732E5F706F736974696F6E6E65722E506F736974696F6E4C6162656C732829292C746869732E5F706F736974696F6E6E65722E6F7074696F6E732E73686F773D74686973';
wwv_flow_api.g_varchar2_table(397) := '2E6F7074696F6E732E73686F777D2C5F7570646174654475726174696F6E733A66756E6374696F6E28612C62297B7061727365496E7428622C3130293D3D3D62262628746869732E5F706F736974696F6E6E65722E6F7074696F6E735B615D3D622C7468';
wwv_flow_api.g_varchar2_table(398) := '69732E6F7074696F6E735B615D3D62297D2C5F646973706C61793A66756E6374696F6E2861297B746869732E6F7074696F6E732E666F726D61747465723D3D3D21313F746869732E5F646973706C617954657874284D6174682E726F756E64286129293A';
wwv_flow_api.g_varchar2_table(399) := '746869732E5F646973706C61795465787428746869732E6F7074696F6E732E666F726D6174746572286129292C746869732E5F76616C75653D617D2C5F646973706C6179546578743A66756E6374696F6E2861297B746869732E5F76616C7565436F6E74';
wwv_flow_api.g_varchar2_table(400) := '61696E65722E746578742861297D2C5F746F67676C65436C6173733A66756E6374696F6E28297B746869732E656C656D656E742E746F67676C65436C617373282275692D72616E6765536C696465722D6C6566744C6162656C222C746869732E6F707469';
wwv_flow_api.g_varchar2_table(401) := '6F6E732E69734C656674292E746F67676C65436C617373282275692D72616E6765536C696465722D72696768744C6162656C222C21746869732E6F7074696F6E732E69734C656674297D2C5F706F736974696F6E4C6162656C733A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(402) := '297B746869732E5F706F736974696F6E6E65722E506F736974696F6E4C6162656C7328297D2C5F6D6F757365446F776E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D2C5F6D6F75736555';
wwv_flow_api.g_varchar2_table(403) := '703A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D2C5F6D6F7573654D6F76653A66756E6374696F6E2861297B746869732E6F7074696F6E732E68616E646C652E747269676765722861297D';
wwv_flow_api.g_varchar2_table(404) := '2C5F6F6E4D6F76696E673A66756E6374696F6E28612C62297B746869732E5F646973706C617928622E76616C7565297D2C5F6F6E5570646174653A66756E6374696F6E28297B2273686F77223D3D3D746869732E6F7074696F6E732E73686F7726267468';
wwv_flow_api.g_varchar2_table(405) := '69732E75706461746528297D2C5F6F6E5377697463683A66756E6374696F6E28612C62297B746869732E6F7074696F6E732E69734C6566743D622C746869732E5F746F67676C65436C61737328292C746869732E5F706F736974696F6E4C6162656C7328';
wwv_flow_api.g_varchar2_table(406) := '297D2C706169723A66756E6374696F6E2861297B6E756C6C3D3D3D746869732E5F706F736974696F6E6E6572262628746869732E5F706F736974696F6E6E65723D6E6577206328746869732E656C656D656E742C612C746869732E7769646765744E616D';
wwv_flow_api.g_varchar2_table(407) := '652C7B73686F773A746869732E6F7074696F6E732E73686F772C6475726174696F6E496E3A746869732E6F7074696F6E732E6475726174696F6E496E2C6475726174696F6E4F75743A746869732E6F7074696F6E732E6475726174696F6E4F75742C6465';
wwv_flow_api.g_varchar2_table(408) := '6C61794F75743A746869732E6F7074696F6E732E64656C61794F75747D292C615B746869732E7769646765744E616D655D2822706F736974696F6E6E6572222C746869732E5F706F736974696F6E6E657229297D2C706F736974696F6E6E65723A66756E';
wwv_flow_api.g_varchar2_table(409) := '6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662061262628746869732E5F706F736974696F6E6E65723D61292C746869732E5F706F736974696F6E6E65727D2C7570646174653A66756E6374696F6E28297B746869';
wwv_flow_api.g_varchar2_table(410) := '732E5F706F736974696F6E6E65722E63616368653D6E756C6C2C746869732E5F646973706C617928746869732E5F68616E646C65282276616C75652229292C2273686F77223D3D3D746869732E6F7074696F6E732E73686F772626746869732E5F706F73';
wwv_flow_api.g_varchar2_table(411) := '6974696F6E4C6162656C7328297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E6461746552616E6765536C69646572222C612E75692E72616E6765536C696465722C';
wwv_flow_api.g_varchar2_table(412) := '7B6F7074696F6E733A7B626F756E64733A7B6D696E3A6E6577204461746528323031302C302C31292E76616C75654F6628292C6D61783A6E6577204461746528323031322C302C31292E76616C75654F6628297D2C64656661756C7456616C7565733A7B';
wwv_flow_api.g_varchar2_table(413) := '6D696E3A6E6577204461746528323031302C312C3131292E76616C75654F6628292C6D61783A6E6577204461746528323031312C312C3131292E76616C75654F6628297D7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E676553';
wwv_flow_api.g_varchar2_table(414) := '6C696465722E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E616464436C617373282275692D6461746552616E6765536C6964657222297D2C64657374726F793A66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(415) := '746869732E656C656D656E742E72656D6F7665436C617373282275692D6461746552616E6765536C6964657222292C612E75692E72616E6765536C696465722E70726F746F747970652E64657374726F792E6170706C792874686973297D2C5F73657444';
wwv_flow_api.g_varchar2_table(416) := '656661756C7456616C7565733A66756E6374696F6E28297B746869732E5F76616C7565733D7B6D696E3A746869732E6F7074696F6E732E64656661756C7456616C7565732E6D696E2E76616C75654F6628292C6D61783A746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(417) := '64656661756C7456616C7565732E6D61782E76616C75654F6628297D7D2C5F73657452756C6572506172616D65746572733A66756E6374696F6E28297B746869732E72756C65722E72756C6572287B6D696E3A6E6577204461746528746869732E6F7074';
wwv_flow_api.g_varchar2_table(418) := '696F6E732E626F756E64732E6D696E2E76616C75654F662829292C6D61783A6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829292C7363616C65733A746869732E6F7074696F6E732E7363616C65';
wwv_flow_api.g_varchar2_table(419) := '737D297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B282264656661756C7456616C756573223D3D3D627C7C22626F756E6473223D3D3D6229262622756E646566696E656422213D747970656F66206326266E756C6C213D3D632626';
wwv_flow_api.g_varchar2_table(420) := '746869732E5F697356616C69644461746528632E6D696E292626746869732E5F697356616C69644461746528632E6D6178293F612E75692E72616E6765536C696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C';
wwv_flow_api.g_varchar2_table(421) := '5B622C7B6D696E3A632E6D696E2E76616C75654F6628292C6D61783A632E6D61782E76616C75654F6628297D5D293A612E75692E72616E6765536C696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C74686973';
wwv_flow_api.g_varchar2_table(422) := '2E5F746F417272617928617267756D656E747329297D2C5F68616E646C65547970653A66756E6374696F6E28297B72657475726E226461746552616E6765536C6964657248616E646C65227D2C6F7074696F6E3A66756E6374696F6E2862297B69662822';
wwv_flow_api.g_varchar2_table(423) := '626F756E6473223D3D3D627C7C2264656661756C7456616C756573223D3D3D62297B76617220633D612E75692E72616E6765536C696465722E70726F746F747970652E6F7074696F6E2E6170706C7928746869732C617267756D656E7473293B72657475';
wwv_flow_api.g_varchar2_table(424) := '726E7B6D696E3A6E6577204461746528632E6D696E292C6D61783A6E6577204461746528632E6D6178297D7D72657475726E20612E75692E72616E6765536C696465722E70726F746F747970652E6F7074696F6E2E6170706C7928746869732C74686973';
wwv_flow_api.g_varchar2_table(425) := '2E5F746F417272617928617267756D656E747329297D2C5F64656661756C74466F726D61747465723A66756E6374696F6E2861297B76617220623D612E6765744D6F6E746828292B312C633D612E6765744461746528293B72657475726E22222B612E67';
wwv_flow_api.g_varchar2_table(426) := '657446756C6C5965617228292B222D222B2831303E623F2230222B623A62292B222D222B2831303E633F2230222B633A63297D2C5F676574466F726D61747465723A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E666F726D';
wwv_flow_api.g_varchar2_table(427) := '61747465723B72657475726E28746869732E6F7074696F6E732E666F726D61747465723D3D3D21317C7C6E756C6C3D3D3D746869732E6F7074696F6E732E666F726D617474657229262628613D746869732E5F64656661756C74466F726D617474657229';
wwv_flow_api.g_varchar2_table(428) := '2C66756E6374696F6E2861297B72657475726E2066756E6374696F6E2862297B72657475726E2061286E65772044617465286229297D7D2861297D2C76616C7565733A66756E6374696F6E28622C63297B76617220643D6E756C6C3B72657475726E2064';
wwv_flow_api.g_varchar2_table(429) := '3D746869732E5F697356616C6964446174652862292626746869732E5F697356616C6964446174652863293F612E75692E72616E6765536C696465722E70726F746F747970652E76616C7565732E6170706C7928746869732C5B622E76616C75654F6628';
wwv_flow_api.g_varchar2_table(430) := '292C632E76616C75654F6628295D293A612E75692E72616E6765536C696465722E70726F746F747970652E76616C7565732E6170706C7928746869732C746869732E5F746F417272617928617267756D656E747329292C7B6D696E3A6E65772044617465';
wwv_flow_api.g_varchar2_table(431) := '28642E6D696E292C6D61783A6E6577204461746528642E6D6178297D7D2C6D696E3A66756E6374696F6E2862297B72657475726E20746869732E5F697356616C6964446174652862293F6E6577204461746528612E75692E72616E6765536C696465722E';
wwv_flow_api.g_varchar2_table(432) := '70726F746F747970652E6D696E2E6170706C7928746869732C5B622E76616C75654F6628295D29293A6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D696E2E6170706C79287468697329297D2C6D61783A66';
wwv_flow_api.g_varchar2_table(433) := '756E6374696F6E2862297B72657475726E20746869732E5F697356616C6964446174652862293F6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D61782E6170706C7928746869732C5B622E76616C75654F66';
wwv_flow_api.g_varchar2_table(434) := '28295D29293A6E6577204461746528612E75692E72616E6765536C696465722E70726F746F747970652E6D61782E6170706C79287468697329297D2C626F756E64733A66756E6374696F6E28622C63297B76617220643B72657475726E20643D74686973';
wwv_flow_api.g_varchar2_table(435) := '2E5F697356616C6964446174652862292626746869732E5F697356616C6964446174652863293F612E75692E72616E6765536C696465722E70726F746F747970652E626F756E64732E6170706C7928746869732C5B622E76616C75654F6628292C632E76';
wwv_flow_api.g_varchar2_table(436) := '616C75654F6628295D293A612E75692E72616E6765536C696465722E70726F746F747970652E626F756E64732E6170706C7928746869732C746869732E5F746F417272617928617267756D656E747329292C7B6D696E3A6E6577204461746528642E6D69';
wwv_flow_api.g_varchar2_table(437) := '6E292C6D61783A6E6577204461746528642E6D6178297D7D2C5F697356616C6964446174653A66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F66206126266120696E7374616E63656F6620446174657D2C5F74';
wwv_flow_api.g_varchar2_table(438) := '6F41727261793A66756E6374696F6E2861297B72657475726E2041727261792E70726F746F747970652E736C6963652E63616C6C2861297D7D297D286A5175657279292C66756E6374696F6E28612C62297B2275736520737472696374223B612E776964';
wwv_flow_api.g_varchar2_table(439) := '676574282275692E6461746552616E6765536C6964657248616E646C65222C612E75692E72616E6765536C6964657248616E646C652C7B5F73746570733A21312C5F626F756E647356616C7565733A7B7D2C5F6372656174653A66756E6374696F6E2829';
wwv_flow_api.g_varchar2_table(440) := '7B746869732E5F637265617465426F756E647356616C75657328292C612E75692E72616E6765536C6964657248616E646C652E70726F746F747970652E5F6372656174652E6170706C792874686973297D2C5F67657456616C7565466F72506F73697469';
wwv_flow_api.g_varchar2_table(441) := '6F6E3A66756E6374696F6E2861297B76617220623D746869732E5F67657452617756616C7565466F72506F736974696F6E416E64426F756E647328612C746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C746869732E';
wwv_flow_api.g_varchar2_table(442) := '6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829293B72657475726E20746869732E5F636F6E73747261696E7456616C7565286E65772044617465286229297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B7265';
wwv_flow_api.g_varchar2_table(443) := '7475726E2273746570223D3D3D623F28746869732E6F7074696F6E732E737465703D632C746869732E5F637265617465537465707328292C766F696420746869732E7570646174652829293A28612E75692E72616E6765536C6964657248616E646C652E';
wwv_flow_api.g_varchar2_table(444) := '70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D292C766F69642822626F756E6473223D3D3D622626746869732E5F637265617465426F756E647356616C756573282929297D2C5F637265617465426F756E64';
wwv_flow_api.g_varchar2_table(445) := '7356616C7565733A66756E6374696F6E28297B746869732E5F626F756E647356616C7565733D7B6D696E3A746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C6D61783A746869732E6F7074696F6E732E626F756E6473';
wwv_flow_api.g_varchar2_table(446) := '2E6D61782E76616C75654F6628297D7D2C5F626F756E64733A66756E6374696F6E28297B72657475726E20746869732E5F626F756E647356616C7565737D2C5F63726561746553746570733A66756E6374696F6E28297B696628746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(447) := '6E732E737465703D3D3D21317C7C21746869732E5F697356616C69645374657028292972657475726E20766F696428746869732E5F73746570733D2131293B76617220613D6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D69';
wwv_flow_api.g_varchar2_table(448) := '6E2E76616C75654F662829292C623D6E6577204461746528746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F662829292C633D612C643D302C653D6E657720446174653B666F7228746869732E5F73746570733D5B5D3B623E3D';
wwv_flow_api.g_varchar2_table(449) := '63262628313D3D3D647C7C652E76616C75654F662829213D3D632E76616C75654F662829293B29653D632C746869732E5F73746570732E7075736828632E76616C75654F662829292C633D746869732E5F6164645374657028612C642C746869732E6F70';
wwv_flow_api.g_varchar2_table(450) := '74696F6E732E73746570292C642B2B3B652E76616C75654F6628293D3D3D632E76616C75654F662829262628746869732E5F73746570733D2131297D2C5F697356616C6964537465703A66756E6374696F6E28297B72657475726E226F626A656374223D';
wwv_flow_api.g_varchar2_table(451) := '3D747970656F6620746869732E6F7074696F6E732E737465707D2C5F616464537465703A66756E6374696F6E28612C622C63297B76617220643D6E6577204461746528612E76616C75654F662829293B72657475726E20643D746869732E5F6164645468';
wwv_flow_api.g_varchar2_table(452) := '696E6728642C2246756C6C59656172222C622C632E7965617273292C643D746869732E5F6164645468696E6728642C224D6F6E7468222C622C632E6D6F6E746873292C643D746869732E5F6164645468696E6728642C2244617465222C622C372A632E77';
wwv_flow_api.g_varchar2_table(453) := '65656B73292C643D746869732E5F6164645468696E6728642C2244617465222C622C632E64617973292C643D746869732E5F6164645468696E6728642C22486F757273222C622C632E686F757273292C643D746869732E5F6164645468696E6728642C22';
wwv_flow_api.g_varchar2_table(454) := '4D696E75746573222C622C632E6D696E75746573292C643D746869732E5F6164645468696E6728642C225365636F6E6473222C622C632E7365636F6E6473297D2C5F6164645468696E673A66756E6374696F6E28612C622C632C64297B72657475726E20';
wwv_flow_api.g_varchar2_table(455) := '303D3D3D637C7C303D3D3D28647C7C30293F613A28615B22736574222B625D28615B22676574222B625D28292B632A28647C7C3029292C61297D2C5F726F756E643A66756E6374696F6E2861297B696628746869732E5F73746570733D3D3D2131297265';
wwv_flow_api.g_varchar2_table(456) := '7475726E20613B666F722876617220622C632C643D746869732E6F7074696F6E732E626F756E64732E6D61782E76616C75654F6628292C653D746869732E6F7074696F6E732E626F756E64732E6D696E2E76616C75654F6628292C663D4D6174682E6D61';
wwv_flow_api.g_varchar2_table(457) := '7828302C28612D65292F28642D6529292C673D4D6174682E666C6F6F7228746869732E5F73746570732E6C656E6774682A66293B746869732E5F73746570735B675D3E613B29672D2D3B666F72283B672B313C746869732E5F73746570732E6C656E6774';
wwv_flow_api.g_varchar2_table(458) := '682626746869732E5F73746570735B672B315D3C3D613B29672B2B3B72657475726E20673E3D746869732E5F73746570732E6C656E6774682D313F746869732E5F73746570735B746869732E5F73746570732E6C656E6774682D315D3A303D3D3D673F74';
wwv_flow_api.g_varchar2_table(459) := '6869732E5F73746570735B305D3A28623D746869732E5F73746570735B675D2C633D746869732E5F73746570735B672B315D2C632D613E612D623F623A63297D2C7570646174653A66756E6374696F6E28297B746869732E5F637265617465426F756E64';
wwv_flow_api.g_varchar2_table(460) := '7356616C75657328292C746869732E5F637265617465537465707328292C612E75692E72616E6765536C6964657248616E646C652E70726F746F747970652E7570646174652E6170706C792874686973297D2C6164643A66756E6374696F6E28612C6229';
wwv_flow_api.g_varchar2_table(461) := '7B72657475726E20746869732E5F61646453746570286E657720446174652861292C312C62292E76616C75654F6628297D2C7375627374726163743A66756E6374696F6E28612C62297B72657475726E20746869732E5F61646453746570286E65772044';
wwv_flow_api.g_varchar2_table(462) := '6174652861292C2D312C62292E76616C75654F6628297D2C73746570734265747765656E3A66756E6374696F6E28612C62297B696628746869732E6F7074696F6E732E737465703D3D3D21312972657475726E20622D613B76617220633D4D6174682E6D';
wwv_flow_api.g_varchar2_table(463) := '696E28612C62292C643D4D6174682E6D617828612C62292C653D302C663D21312C673D613E623B666F7228746869732E61646428632C746869732E6F7074696F6E732E73746570292D633C30262628663D2130293B643E633B29663F643D746869732E61';
wwv_flow_api.g_varchar2_table(464) := '646428642C746869732E6F7074696F6E732E73746570293A633D746869732E61646428632C746869732E6F7074696F6E732E73746570292C652B2B3B72657475726E20673F2D653A657D2C6D756C7469706C79537465703A66756E6374696F6E28612C62';
wwv_flow_api.g_varchar2_table(465) := '297B76617220633D7B7D3B666F7228766172206420696E206129612E6861734F776E50726F7065727479286429262628635B645D3D615B645D2A62293B72657475726E20637D2C73746570526174696F3A66756E6374696F6E28297B696628746869732E';
wwv_flow_api.g_varchar2_table(466) := '6F7074696F6E732E737465703D3D3D21312972657475726E20313B76617220613D746869732E5F73746570732E6C656E6774683B72657475726E20746869732E63616368652E706172656E742E77696474682F617D7D297D286A5175657279292C66756E';
wwv_flow_api.g_varchar2_table(467) := '6374696F6E28612C62297B2275736520737472696374223B612E776964676574282275692E6564697452616E6765536C69646572222C612E75692E72616E6765536C696465722C7B6F7074696F6E733A7B747970653A2274657874222C726F756E643A31';
wwv_flow_api.g_varchar2_table(468) := '7D2C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465722E70726F746F747970652E5F6372656174652E6170706C792874686973292C746869732E656C656D656E742E616464436C617373282275692D656469745261';
wwv_flow_api.g_varchar2_table(469) := '6E6765536C6964657222297D2C64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C617373282275692D6564697452616E6765536C6964657222292C612E75692E72616E6765536C696465722E70726F74';
wwv_flow_api.g_varchar2_table(470) := '6F747970652E64657374726F792E6170706C792874686973297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B282274797065223D3D3D627C7C2273746570223D3D3D62292626746869732E5F7365744C6162656C4F7074696F6E2862';
wwv_flow_api.g_varchar2_table(471) := '2C63292C2274797065223D3D3D62262628746869732E6F7074696F6E735B625D3D6E756C6C3D3D3D746869732E6C6162656C732E6C6566743F633A746869732E5F6C6566744C6162656C28226F7074696F6E222C6229292C612E75692E72616E6765536C';
wwv_flow_api.g_varchar2_table(472) := '696465722E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D2C5F7365744C6162656C4F7074696F6E3A66756E6374696F6E28612C62297B6E756C6C213D3D746869732E6C6162656C732E6C6566742626';
wwv_flow_api.g_varchar2_table(473) := '28746869732E5F6C6566744C6162656C28226F7074696F6E222C612C62292C746869732E5F72696768744C6162656C28226F7074696F6E222C612C6229297D2C5F6C6162656C547970653A66756E6374696F6E28297B72657475726E226564697452616E';
wwv_flow_api.g_varchar2_table(474) := '6765536C696465724C6162656C227D2C5F6372656174654C6162656C3A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6372656174654C6162656C2E6170706C7928746869732C';
wwv_flow_api.g_varchar2_table(475) := '5B622C635D293B72657475726E206E756C6C3D3D3D622626642E62696E64282276616C75654368616E6765222C612E70726F787928746869732E5F6F6E56616C75654368616E67652C7468697329292C647D2C5F61646450726F70657274696573546F50';
wwv_flow_api.g_varchar2_table(476) := '6172616D657465723A66756E6374696F6E2861297B72657475726E20612E747970653D746869732E6F7074696F6E732E747970652C612E737465703D746869732E6F7074696F6E732E737465702C612E69643D746869732E656C656D656E742E61747472';
wwv_flow_api.g_varchar2_table(477) := '2822696422292C617D2C5F6765744C6162656C436F6E7374727563746F72506172616D65746572733A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6765744C6162656C436F6E';
wwv_flow_api.g_varchar2_table(478) := '7374727563746F72506172616D65746572732E6170706C7928746869732C5B622C635D293B72657475726E20746869732E5F61646450726F70657274696573546F506172616D657465722864297D2C5F6765744C6162656C52656672657368506172616D';
wwv_flow_api.g_varchar2_table(479) := '65746572733A66756E6374696F6E28622C63297B76617220643D612E75692E72616E6765536C696465722E70726F746F747970652E5F6765744C6162656C52656672657368506172616D65746572732E6170706C7928746869732C5B622C635D293B7265';
wwv_flow_api.g_varchar2_table(480) := '7475726E20746869732E5F61646450726F70657274696573546F506172616D657465722864297D2C5F6F6E56616C75654368616E67653A66756E6374696F6E28612C62297B76617220633D21313B633D622E69734C6566743F746869732E5F76616C7565';
wwv_flow_api.g_varchar2_table(481) := '732E6D696E213D3D746869732E6D696E28622E76616C7565293A746869732E5F76616C7565732E6D6178213D3D746869732E6D617828622E76616C7565292C632626746869732E5F7472696767657228227573657256616C7565734368616E6765642229';
wwv_flow_api.g_varchar2_table(482) := '7D7D297D286A5175657279292C66756E6374696F6E2861297B2275736520737472696374223B612E776964676574282275692E6564697452616E6765536C696465724C6162656C222C612E75692E72616E6765536C696465724C6162656C2C7B6F707469';
wwv_flow_api.g_varchar2_table(483) := '6F6E733A7B747970653A2274657874222C737465703A21312C69643A22227D2C5F696E7075743A6E756C6C2C5F746578743A22222C5F6372656174653A66756E6374696F6E28297B612E75692E72616E6765536C696465724C6162656C2E70726F746F74';
wwv_flow_api.g_varchar2_table(484) := '7970652E5F6372656174652E6170706C792874686973292C746869732E5F637265617465496E70757428297D2C5F7365744F7074696F6E3A66756E6374696F6E28622C63297B2274797065223D3D3D623F746869732E5F736574547970654F7074696F6E';
wwv_flow_api.g_varchar2_table(485) := '2863293A2273746570223D3D3D622626746869732E5F736574537465704F7074696F6E2863292C612E75692E72616E6765536C696465724C6162656C2E70726F746F747970652E5F7365744F7074696F6E2E6170706C7928746869732C5B622C635D297D';
wwv_flow_api.g_varchar2_table(486) := '2C5F637265617465496E7075743A66756E6374696F6E28297B746869732E5F696E7075743D6128223C696E70757420747970653D27222B746869732E6F7074696F6E732E747970652B2227202F3E22292E616464436C617373282275692D656469745261';
wwv_flow_api.g_varchar2_table(487) := '6E6765536C696465722D696E70757456616C756522292E617070656E64546F28746869732E5F76616C7565436F6E7461696E6572292C746869732E5F736574496E7075744E616D6528292C746869732E5F696E7075742E62696E6428226B65797570222C';
wwv_flow_api.g_varchar2_table(488) := '612E70726F787928746869732E5F6F6E4B657955702C7468697329292C746869732E5F696E7075742E626C757228612E70726F787928746869732E5F6F6E4368616E67652C7468697329292C226E756D626572223D3D3D746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(489) := '74797065262628746869732E6F7074696F6E732E73746570213D3D21312626746869732E5F696E7075742E61747472282273746570222C746869732E6F7074696F6E732E73746570292C746869732E5F696E7075742E636C69636B28612E70726F787928';
wwv_flow_api.g_varchar2_table(490) := '746869732E5F6F6E4368616E67652C746869732929292C746869732E5F696E7075742E76616C28746869732E5F74657874297D2C5F736574496E7075744E616D653A66756E6374696F6E28297B76617220613D746869732E6F7074696F6E732E69734C65';
wwv_flow_api.g_varchar2_table(491) := '66743F226C656674223A227269676874223B746869732E5F696E7075742E6174747228226E616D65222C746869732E6F7074696F6E732E69642B61297D2C5F6F6E5377697463683A66756E6374696F6E28622C63297B612E75692E72616E6765536C6964';
wwv_flow_api.g_varchar2_table(492) := '65724C6162656C2E70726F746F747970652E5F6F6E5377697463682E6170706C7928746869732C5B622C635D292C746869732E5F736574496E7075744E616D6528297D2C5F64657374726F79496E7075743A66756E6374696F6E28297B746869732E5F69';
wwv_flow_api.g_varchar2_table(493) := '6E7075742E72656D6F766528292C746869732E5F696E7075743D6E756C6C7D2C5F6F6E4B657955703A66756E6374696F6E2861297B72657475726E2031333D3D3D612E77686963683F28746869732E5F6F6E4368616E67652861292C2131293A766F6964';
wwv_flow_api.g_varchar2_table(494) := '20307D2C5F6F6E4368616E67653A66756E6374696F6E28297B76617220613D746869732E5F72657475726E436865636B656456616C756528746869732E5F696E7075742E76616C2829293B61213D3D21312626746869732E5F7472696767657256616C75';
wwv_flow_api.g_varchar2_table(495) := '652861297D2C5F7472696767657256616C75653A66756E6374696F6E2861297B76617220623D746869732E6F7074696F6E732E68616E646C655B746869732E6F7074696F6E732E68616E646C65547970655D28226F7074696F6E222C2269734C65667422';
wwv_flow_api.g_varchar2_table(496) := '293B746869732E656C656D656E742E74726967676572282276616C75654368616E6765222C5B7B69734C6566743A622C76616C75653A617D5D297D2C5F72657475726E436865636B656456616C75653A66756E6374696F6E2861297B76617220623D7061';
wwv_flow_api.g_varchar2_table(497) := '727365466C6F61742861293B72657475726E2069734E614E2862297C7C69734E614E284E756D626572286129293F21313A627D2C5F736574547970654F7074696F6E3A66756E6374696F6E2861297B227465787422213D3D612626226E756D6265722221';
wwv_flow_api.g_varchar2_table(498) := '3D3D617C7C746869732E6F7074696F6E732E747970653D3D3D617C7C28746869732E5F64657374726F79496E70757428292C746869732E6F7074696F6E732E747970653D612C746869732E5F637265617465496E7075742829297D2C5F73657453746570';
wwv_flow_api.g_varchar2_table(499) := '4F7074696F6E3A66756E6374696F6E2861297B746869732E6F7074696F6E732E737465703D612C226E756D626572223D3D3D746869732E6F7074696F6E732E747970652626746869732E5F696E7075742E61747472282273746570222C61213D3D21313F';
wwv_flow_api.g_varchar2_table(500) := '613A22616E7922297D2C5F646973706C6179546578743A66756E6374696F6E2861297B746869732E5F696E7075742E76616C2861292C746869732E5F746578743D617D2C656E61626C653A66756E6374696F6E28297B612E75692E72616E6765536C6964';
wwv_flow_api.g_varchar2_table(501) := '65724C6162656C2E70726F746F747970652E656E61626C652E6170706C792874686973292C746869732E5F696E7075742E61747472282264697361626C6564222C6E756C6C297D2C64697361626C653A66756E6374696F6E28297B612E75692E72616E67';
wwv_flow_api.g_varchar2_table(502) := '65536C696465724C6162656C2E70726F746F747970652E64697361626C652E6170706C792874686973292C746869732E5F696E7075742E61747472282264697361626C6564222C2264697361626C656422297D7D297D286A5175657279292C66756E6374';
wwv_flow_api.g_varchar2_table(503) := '696F6E2861297B2275736520737472696374223B76617220623D7B66697273743A66756E6374696F6E2861297B72657475726E20617D2C6E6578743A66756E6374696F6E2861297B72657475726E20612B317D2C666F726D61743A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(504) := '297B7D2C6C6162656C3A66756E6374696F6E2861297B72657475726E204D6174682E726F756E642861297D2C73746F703A66756E6374696F6E28297B72657475726E21317D7D3B612E776964676574282275692E72756C6572222C7B6F7074696F6E733A';
wwv_flow_api.g_varchar2_table(505) := '7B6D696E3A302C6D61783A3130302C7363616C65733A5B5D7D2C5F6372656174653A66756E6374696F6E28297B746869732E656C656D656E742E616464436C617373282275692D72756C657222292C746869732E5F6372656174655363616C657328297D';
wwv_flow_api.g_varchar2_table(506) := '2C64657374726F793A66756E6374696F6E28297B746869732E656C656D656E742E72656D6F7665436C617373282275692D72756C657222292C746869732E656C656D656E742E656D70747928297D2C5F726567656E65726174653A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(507) := '297B746869732E656C656D656E742E656D70747928292C746869732E5F6372656174655363616C657328297D2C5F7365744F7074696F6E3A66756E6374696F6E28612C62297B72657475726E226D696E223D3D3D617C7C226D6178223D3D3D6126266221';
wwv_flow_api.g_varchar2_table(508) := '3D3D746869732E6F7074696F6E735B615D3F28746869732E6F7074696F6E735B615D3D622C766F696420746869732E5F726567656E65726174652829293A227363616C6573223D3D3D6126266220696E7374616E63656F662041727261793F2874686973';
wwv_flow_api.g_varchar2_table(509) := '2E6F7074696F6E732E7363616C65733D622C766F696420746869732E5F726567656E65726174652829293A766F696420307D2C5F6372656174655363616C65733A66756E6374696F6E28297B696628746869732E6F7074696F6E732E6D6178213D3D7468';
wwv_flow_api.g_varchar2_table(510) := '69732E6F7074696F6E732E6D696E29666F722876617220613D303B613C746869732E6F7074696F6E732E7363616C65732E6C656E6774683B612B2B29746869732E5F6372656174655363616C6528746869732E6F7074696F6E732E7363616C65735B615D';
wwv_flow_api.g_varchar2_table(511) := '2C61297D2C5F6372656174655363616C653A66756E6374696F6E28632C64297B76617220653D612E657874656E64287B7D2C622C63292C663D6128223C64697620636C6173733D2775692D72756C65722D7363616C6527202F3E22292E617070656E6454';
wwv_flow_api.g_varchar2_table(512) := '6F28746869732E656C656D656E74293B662E616464436C617373282275692D72756C65722D7363616C65222B64292C746869732E5F6372656174655469636B7328662C65297D2C5F6372656174655469636B733A66756E6374696F6E28612C62297B7661';
wwv_flow_api.g_varchar2_table(513) := '7220632C642C652C663D622E666972737428746869732E6F7074696F6E732E6D696E2C746869732E6F7074696F6E732E6D6178292C673D746869732E6F7074696F6E732E6D61782D746869732E6F7074696F6E732E6D696E2C683D21303B646F20633D66';
wwv_flow_api.g_varchar2_table(514) := '2C663D622E6E6578742863292C643D284D6174682E6D696E28662C746869732E6F7074696F6E732E6D6178292D4D6174682E6D617828632C746869732E6F7074696F6E732E6D696E29292F672C653D746869732E5F6372656174655469636B28632C662C';
wwv_flow_api.g_varchar2_table(515) := '62292C612E617070656E642865292C652E63737328227769647468222C3130302A642B222522292C682626633E746869732E6F7074696F6E732E6D696E2626652E63737328226D617267696E2D6C656674222C3130302A28632D746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(516) := '6E732E6D696E292F672B222522292C683D21313B7768696C652821746869732E5F73746F7028622C6629297D2C5F73746F703A66756E6374696F6E28612C62297B72657475726E20612E73746F702862297C7C623E3D746869732E6F7074696F6E732E6D';
wwv_flow_api.g_varchar2_table(517) := '61787D2C5F6372656174655469636B3A66756E6374696F6E28622C632C64297B76617220653D6128223C64697620636C6173733D2775692D72756C65722D7469636B27207374796C653D27646973706C61793A696E6C696E652D626C6F636B27202F3E22';
wwv_flow_api.g_varchar2_table(518) := '292C663D6128223C64697620636C6173733D2775692D72756C65722D7469636B2D696E6E657227202F3E22292E617070656E64546F2865292C673D6128223C7370616E20636C6173733D2775692D72756C65722D7469636B2D6C6162656C27202F3E2229';
wwv_flow_api.g_varchar2_table(519) := '2E617070656E64546F2866293B72657475726E20672E7465787428642E6C6162656C28622C6329292C642E666F726D617428652C622C63292C657D7D297D286A5175657279293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(93701627202905985747)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'jQAllRangeSliders-withRuler-min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2A0D0A202A205468656D6520666F72206A5152616E6765536C696465720D0A202A20496E73706972656420627920687474703A2F2F6373736465636B2E636F6D2F6974656D2F3338312F6974756E65732D31302D73746F726167652D6261720D0A20';
wwv_flow_api.g_varchar2_table(2) := '2A2020202020202020616E6420687474703A2F2F6373736465636B2E636F6D2F6974656D2F3237362F707572652D6373732D6172726F772D776974682D626F726465722D746F6F6C7469700D0A202A2F0D0A0D0A2E75692D72616E6765536C696465727B';
wwv_flow_api.g_varchar2_table(3) := '0D0A20206865696768743A20333070783B0D0A202070616464696E672D746F703A20343070783B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722C0D0A2E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E67';
wwv_flow_api.g_varchar2_table(4) := '65536C696465722D6172726F777B0D0A20202D7765626B69742D626F782D73697A696E673A636F6E74656E742D626F783B0D0A20202020202D6D6F7A2D626F782D73697A696E673A636F6E74656E742D626F783B0D0A20202020202020202020626F782D';
wwv_flow_api.g_varchar2_table(5) := '73697A696E673A636F6E74656E742D626F783B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D776974684172726F7773202E75692D72616E6765536C696465722D636F6E7461696E65727B0D0A20206D617267696E3A203020313570783B0D0A';
wwv_flow_api.g_varchar2_table(6) := '7D0D0A0D0A2E75692D72616E6765536C696465722D776974684172726F7773202E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D6E6F4172726F77202E75692D72616E6765536C696465722D';
wwv_flow_api.g_varchar2_table(7) := '636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D6172726F777B0D0A20202D7765626B69742D626F782D736861646F773A20696E736574203070782034707820367078202D327078205247424128302C302C302C302E35293B0D0A20';
wwv_flow_api.g_varchar2_table(8) := '202020202D6D6F7A2D626F782D736861646F773A20696E736574203070782034707820367078202D327078205247424128302C302C302C302E35293B0D0A20202020202020202020626F782D736861646F773A20696E7365742030707820347078203670';
wwv_flow_api.g_varchar2_table(9) := '78202D327078205247424128302C302C302C302E35293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C65642E75692D72616E6765536C696465722D776974684172726F7773202E75692D72616E6765536C696465722D636F6E';
wwv_flow_api.g_varchar2_table(10) := '7461696E65722C0D0A2E75692D72616E6765536C696465722D64697361626C65642E75692D72616E6765536C696465722D6E6F4172726F77202E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E6765536C69646572';
wwv_flow_api.g_varchar2_table(11) := '2D64697361626C6564202E75692D72616E6765536C696465722D6172726F777B0D0A20202D7765626B69742D626F782D736861646F773A20696E736574203070782034707820367078202D327078205247424128302C302C302C302E33293B0D0A202020';
wwv_flow_api.g_varchar2_table(12) := '20202D6D6F7A2D626F782D736861646F773A20696E736574203070782034707820367078202D327078205247424128302C302C302C302E33293B0D0A20202020202020202020626F782D736861646F773A20696E73657420307078203470782036707820';
wwv_flow_api.g_varchar2_table(13) := '2D327078205247424128302C302C302C302E33293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6E6F4172726F77202E75692D72616E6765536C696465722D636F6E7461696E65727B0D0A20202D6D6F7A2D626F726465722D726164697573';
wwv_flow_api.g_varchar2_table(14) := '3A203470783B0D0A2020626F726465722D7261646975733A203470783B0D0A2020626F726465722D6C6566743A20736F6C69642031707820233531353836323B0D0A2020626F726465722D72696768743A20736F6C69642031707820233531353836323B';
wwv_flow_api.g_varchar2_table(15) := '0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C65642E75692D72616E6765536C696465722D6E6F4172726F77202E75692D72616E6765536C696465722D636F6E7461696E65727B0D0A2020626F726465722D636F6C6F723A2023';
wwv_flow_api.g_varchar2_table(16) := '3834393061333B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D6172726F777B0D0A20096865696768743A20333070783B0D0A0D0A2020626F726465722D746F703A2073';
wwv_flow_api.g_varchar2_table(17) := '6F6C69642031707820233233326133323B0D0A2020626F726465722D626F74746F6D3A20736F6C69642031707820233661373137393B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465';
wwv_flow_api.g_varchar2_table(18) := '722D636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6172726F777B0D0A2020626F726465722D746F702D636F6C6F723A20233439353736623B0D0A2020626F726465';
wwv_flow_api.g_varchar2_table(19) := '722D626F74746F6D2D636F6C6F723A20233963613762333B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D6172726F772C0D0A2E75692D72616E6765536C696465722D6C';
wwv_flow_api.g_varchar2_table(20) := '6162656C7B0D0A20206261636B67726F756E643A20233637373037463B0D0A20206261636B67726F756E643A202D6D6F7A2D6C696E6561722D6772616469656E7428746F702C20233637373037462030252C20233838384441302031303025293B0D0A20';
wwv_flow_api.g_varchar2_table(21) := '206261636B67726F756E643A202D7765626B69742D6772616469656E74286C696E6561722C206C65667420746F702C206C65667420626F74746F6D2C20636F6C6F722D73746F702830252C23363737303746292C20636F6C6F722D73746F702831303025';
wwv_flow_api.g_varchar2_table(22) := '2C2338383844413029293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D636F6E7461696E65722C0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D';
wwv_flow_api.g_varchar2_table(23) := '72616E6765536C696465722D6172726F772C0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6C6162656C7B0D0A20206261636B67726F756E643A20233935613462643B0D0A20206261636B67';
wwv_flow_api.g_varchar2_table(24) := '726F756E643A202D6D6F7A2D6C696E6561722D6772616469656E7428746F702C20233935613462642030252C20236232626264382031303025293B0D0A20206261636B67726F756E643A202D7765626B69742D6772616469656E74286C696E6561722C20';
wwv_flow_api.g_varchar2_table(25) := '6C65667420746F702C206C65667420626F74746F6D2C20636F6C6F722D73746F702830252C23393561346264292C20636F6C6F722D73746F7028313030252C2362326262643829293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6172726F';
wwv_flow_api.g_varchar2_table(26) := '777B0D0A202077696474683A313470783B0D0A2020637572736F723A706F696E7465723B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6C6566744172726F777B0D0A2020626F726465722D7261646975733A34707820302030203470783B0D';
wwv_flow_api.g_varchar2_table(27) := '0A2020626F726465722D6C6566743A20736F6C69642031707820233531353836323B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6C6566744172726F777B0D0A20626F726465';
wwv_flow_api.g_varchar2_table(28) := '722D6C6566742D636F6C6F723A20233837393261323B200D0A7D0D0A0D0A2E75692D72616E6765536C696465722D72696768744172726F777B0D0A2020626F726465722D7261646975733A30203470782034707820303B0D0A2020626F726465722D7269';
wwv_flow_api.g_varchar2_table(29) := '6768743A20736F6C69642031707820233531353836323B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D72696768744172726F777B0D0A20626F726465722D72696768742D636F';
wwv_flow_api.g_varchar2_table(30) := '6C6F723A20233837393261323B200D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6172726F772D696E6E65727B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A2020746F703A203530253B0D0A2020626F726465723A20313070';
wwv_flow_api.g_varchar2_table(31) := '7820736F6C6964207472616E73706172656E743B0D0A202077696474683A303B0D0A20206865696768743A303B0D0A0D0A20206D617267696E2D746F703A202D313070783B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6C6566744172726F';
wwv_flow_api.g_varchar2_table(32) := '77202E75692D72616E6765536C696465722D6172726F772D696E6E65727B0D0A2020626F726465722D72696768743A3130707820736F6C696420236134613862373B0D0A20206C6566743A20303B0D0A20206D617267696E2D6C6566743A202D3870783B';
wwv_flow_api.g_varchar2_table(33) := '0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6C6566744172726F773A686F766572202E75692D72616E6765536C696465722D6172726F772D696E6E65727B0D0A2020626F726465722D72696768743A3130707820736F6C6964202362336236';
wwv_flow_api.g_varchar2_table(34) := '63323B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6C6566744172726F77202E75692D72616E6765536C696465722D6172726F772D696E6E65722C0D0A2E75692D72616E6765';
wwv_flow_api.g_varchar2_table(35) := '536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6C6566744172726F773A686F766572202E75692D72616E6765536C696465722D6172726F772D696E6E65727B0D0A2020626F726465722D72696768742D636F6C6F723A20';
wwv_flow_api.g_varchar2_table(36) := '236262633063663B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D72696768744172726F77202E75692D72616E6765536C696465722D6172726F772D696E6E65727B0D0A2020626F726465722D6C6566743A3130707820736F6C696420236134';
wwv_flow_api.g_varchar2_table(37) := '613862373B0D0A202072696768743A20303B0D0A20206D617267696E2D72696768743A202D3870783B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D72696768744172726F773A686F766572202E75692D72616E6765536C696465722D617272';
wwv_flow_api.g_varchar2_table(38) := '6F772D696E6E65727B0D0A2020626F726465722D6C6566743A3130707820736F6C696420236233623663323B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D7269676874417272';
wwv_flow_api.g_varchar2_table(39) := '6F77202E75692D72616E6765536C696465722D6172726F772D696E6E65722C0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D72696768744172726F773A686F766572202E75692D72616E6765';
wwv_flow_api.g_varchar2_table(40) := '536C696465722D6172726F772D696E6E65727B0D0A2020626F726465722D6C6566742D636F6C6F723A20236262633063663B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D696E6E65724261727B0D0A202077696474683A20313130253B0D0A';
wwv_flow_api.g_varchar2_table(41) := '20206865696768743A20313030253B0D0A20206C6566743A202D313070783B0D0A20206F766572666C6F773A2068696464656E3B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D6261727B0D0A096261636B67726F756E643A20233638613164';
wwv_flow_api.g_varchar2_table(42) := '363B0D0A20206F7061636974793A302E373B0D0A20206865696768743A20323970783B0D0A20206D617267696E3A31707820303B0D0A20202D6D6F7A2D626F726465722D7261646975733A203470783B0D0A2020626F726465722D7261646975733A2034';
wwv_flow_api.g_varchar2_table(43) := '70783B0D0A2020637572736F723A6D6F76653B0D0A09637572736F723A677261623B0D0A09637572736F723A202D6D6F7A2D677261623B0D0A20200D0A092D7765626B69742D626F782D736861646F773A20696E73657420302032707820367078205247';
wwv_flow_api.g_varchar2_table(44) := '424128302C302C302C302E35293B0D0A20202020202D6D6F7A2D626F782D736861646F773A20696E73657420302032707820367078205247424128302C302C302C302E35293B0D0A20202020202020202020626F782D736861646F773A20696E73657420';
wwv_flow_api.g_varchar2_table(45) := '302032707820367078205247424128302C302C302C302E35293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E6765536C696465722D6261727B0D0A20206261636B67726F756E643A20233933616563';
wwv_flow_api.g_varchar2_table(46) := '613B0D0A0D0A20202D7765626B69742D626F782D736861646F773A20696E73657420302032707820367078205247424128302C302C302C302E33293B0D0A20202020202D6D6F7A2D626F782D736861646F773A20696E7365742030203270782036707820';
wwv_flow_api.g_varchar2_table(47) := '5247424128302C302C302C302E33293B0D0A20202020202020202020626F782D736861646F773A20696E73657420302032707820367078205247424128302C302C302C302E33293B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D68616E646C';
wwv_flow_api.g_varchar2_table(48) := '657B0D0A0977696474683A313070783B0D0A096865696768743A333070783B0D0A096261636B67726F756E643A207472616E73706172656E743B0D0A09637572736F723A636F6C2D726573697A653B0D0A7D0D0A0D0A2E75692D72616E6765536C696465';
wwv_flow_api.g_varchar2_table(49) := '722D6C6162656C7B0D0A202070616464696E673A2035707820313070783B0D0A2020626F74746F6D3A343070783B0D0A0D0A20202D6D6F7A2D626F726465722D7261646975733A203470783B0D0A20202020202020626F726465722D7261646975733A20';
wwv_flow_api.g_varchar2_table(50) := '3470783B0D0A0D0A20202D7765626B69742D626F782D736861646F773A20307078203170782030707820236332633564363B0D0A20202020202D6D6F7A2D626F782D736861646F773A20307078203170782030707820236332633564363B0D0A20202020';
wwv_flow_api.g_varchar2_table(51) := '202020202020626F782D736861646F773A20307078203170782030707820236332633564363B0D0A0D0A2020636F6C6F723A77686974653B0D0A2020666F6E742D73697A653A313570783B0D0A0D0A2020637572736F723A636F6C2D726573697A653B0D';
wwv_flow_api.g_varchar2_table(52) := '0A7D0D0A0D0A2E75692D72616E6765536C696465722D6C6162656C2D696E6E65727B0D0A2020706F736974696F6E3A206162736F6C7574653B0D0A2020746F703A20313030253B0D0A20206C6566743A203530253B0D0A2020646973706C61793A20626C';
wwv_flow_api.g_varchar2_table(53) := '6F636B3B0D0A20207A2D696E6465783A39393B0D0A2020626F726465722D6C6566743A203130707820736F6C6964207472616E73706172656E743B0D0A2020626F726465722D72696768743A203130707820736F6C6964207472616E73706172656E743B';
wwv_flow_api.g_varchar2_table(54) := '0D0A0D0A20206D617267696E2D6C6566743A202D313070783B0D0A2020626F726465722D746F703A203130707820736F6C696420233838384441303B0D0A7D0D0A0D0A2E75692D72616E6765536C696465722D64697361626C6564202E75692D72616E67';
wwv_flow_api.g_varchar2_table(55) := '65536C696465722D6C6162656C2D696E6E65727B0D0A2020626F726465722D746F702D636F6C6F723A20236232626264383B200D0A7D0D0A0D0A2E75692D6564697452616E6765536C696465722D696E70757456616C75657B0D0A202077696474683A32';
wwv_flow_api.g_varchar2_table(56) := '656D3B0D0A2020746578742D616C69676E3A63656E7465723B0D0A2020666F6E742D73697A653A313570783B0D0A7D0D0A0D0A2E75692D72616E6765536C69646572202E75692D72756C65722D7363616C657B0D0A2020706F736974696F6E3A6162736F';
wwv_flow_api.g_varchar2_table(57) := '6C7574653B0D0A2020746F703A303B0D0A20206C6566743A303B0D0A2020626F74746F6D3A303B0D0A202072696768743A303B0D0A7D0D0A0D0A2E75692D72616E6765536C69646572202E75692D72756C65722D7469636B207B200D0A2020666C6F6174';
wwv_flow_api.g_varchar2_table(58) := '3A206C6566743B200D0A7D0D0A0D0A2E75692D72616E6765536C69646572202E75692D72756C65722D7363616C6530202E75692D72756C65722D7469636B2D696E6E65727B0D0A2020636F6C6F723A77686974653B0D0A20206D617267696E2D746F703A';
wwv_flow_api.g_varchar2_table(59) := '3170783B0D0A2020626F726465722D6C6566743A2031707820736F6C69642077686974653B0D0A20206865696768743A323970783B0D0A202070616464696E672D6C6566743A3270783B0D0A2020706F736974696F6E3A72656C61746976653B0D0A7D0D';
wwv_flow_api.g_varchar2_table(60) := '0A0D0A2E75692D72616E6765536C69646572202E75692D72756C65722D7363616C6530202E75692D72756C65722D7469636B2D6C6162656C7B0D0A2020706F736974696F6E3A6162736F6C7574653B0D0A2020626F74746F6D3A203670783B0D0A7D0D0A';
wwv_flow_api.g_varchar2_table(61) := '0D0A2E75692D72616E6765536C69646572202E75692D72756C65722D7363616C6531202E75692D72756C65722D7469636B2D696E6E65727B0D0A2020626F726465722D6C6566743A31707820736F6C69642077686974653B0D0A20206D617267696E2D74';
wwv_flow_api.g_varchar2_table(62) := '6F703A20323570783B0D0A20206865696768743A203570783B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(93701627929894992095)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'iThing.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '436F70797269676874202863292032303132204775696C6C61756D652047617574726561750D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E';
wwv_flow_api.g_varchar2_table(2) := '206F627461696E696E670D0A6120636F7079206F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468650D0A22536F66747761726522292C20746F206465616C20696E';
wwv_flow_api.g_varchar2_table(3) := '2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E670D0A776974686F7574206C696D69746174696F6E207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D65';
wwv_flow_api.g_varchar2_table(4) := '7267652C207075626C6973682C0D0A646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C20636F70696573206F662074686520536F6674776172652C20616E6420746F0D0A7065726D697420706572736F6E7320746F';
wwv_flow_api.g_varchar2_table(5) := '2077686F6D2074686520536F667477617265206973206675726E697368656420746F20646F20736F2C207375626A65637420746F0D0A74686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F7079726967';
wwv_flow_api.g_varchar2_table(6) := '6874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C2062650D0A696E636C7564656420696E20616C6C20636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F6620746865';
wwv_flow_api.g_varchar2_table(7) := '20536F6674776172652E0D0A0D0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C0D0A45585052455353204F5220494D504C4945442C2049';
wwv_flow_api.g_varchar2_table(8) := '4E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F460D0A4D45524348414E544142494C4954592C204649544E45535320464F52204120504152544943554C415220505552504F534520414E44';
wwv_flow_api.g_varchar2_table(9) := '0D0A4E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C444552532042450D0A4C4941424C4520464F5220414E5920434C41494D2C2044414D41';
wwv_flow_api.g_varchar2_table(10) := '474553204F52204F54484552204C494142494C4954592C205748455448455220494E20414E20414354494F4E0D0A4F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C204F5554204F46204F';
wwv_flow_api.g_varchar2_table(11) := '5220494E20434F4E4E454354494F4E0D0A574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F4654574152452E';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(93701798720767924794)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'jQRangeSlider-MIT-License.txt'
,p_mime_type=>'text/plain'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4B414C20436F6E73756C74616E6379204C74642D2020415045582052616E676520536C6964657220506C7567696E202D2070726F766964656420756E64657220746865204D4954206C6963656E73650D0A55736573206A5152616E6765536C6964657220';
wwv_flow_api.g_varchar2_table(2) := '76352E372E322028687474703A2F2F6768757373652E6769746875622E696F2F6A5152616E6765536C696465722F290D0A0D0A436F6E746163743A206B616C636F6E73756C74616E63796C746440686F746D61696C2E636F6D0D0A76657273696F6E2031';
wwv_flow_api.g_varchar2_table(3) := '2E322D2031372F30312F323031370D0A5465737465642077697468204F7261636C65204170706C69636174696F6E204578707265737320352E302E340D0A0D0A436F70797269676874202863292032303137204B414C20436F6E73756C74616E6379204C';
wwv_flow_api.g_varchar2_table(4) := '74640D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F70790D0A6F66207468697320736F667477617265';
wwv_flow_api.g_varchar2_table(5) := '20616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C0D0A696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20';
wwv_flow_api.g_varchar2_table(6) := '696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730D0A746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73';
wwv_flow_api.g_varchar2_table(7) := '652C20616E642F6F722073656C6C0D0A636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730D0A6675726E697368656420746F20';
wwv_flow_api.g_varchar2_table(8) := '646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365';
wwv_flow_api.g_varchar2_table(9) := '207368616C6C20626520696E636C7564656420696E20616C6C0D0A636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F4654574152452049532050524F564944';
wwv_flow_api.g_varchar2_table(10) := '454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F520D0A494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252';
wwv_flow_api.g_varchar2_table(11) := '414E54494553204F46204D45524348414E544142494C4954592C0D0A4649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C20';
wwv_flow_api.g_varchar2_table(12) := '5448450D0A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845520D0A4C494142494C4954592C205748455448455220494E2041';
wwv_flow_api.g_varchar2_table(13) := '4E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0D0A4F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F52';
wwv_flow_api.g_varchar2_table(14) := '2054484520555345204F52204F54484552204445414C494E475320494E205448450D0A534F4654574152452E';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(93701805887662940639)
,p_plugin_id=>wwv_flow_api.id(93701575287045718783)
,p_file_name=>'kalcRangeSlider-MIT-License.txt'
,p_mime_type=>'text/plain'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
