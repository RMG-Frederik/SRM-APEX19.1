prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.03.31'
,p_release=>'19.1.0.00.15'
,p_default_workspace_id=>25301121654823498838
,p_default_application_id=>127683
,p_default_owner=>'FVT'
);
end;
/
prompt --application/shared_components/plugins/region_type/jjs_simple_grid
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(18862910167445342644)
,p_plugin_type=>'REGION TYPE'
,p_name=>'JJS_SIMPLE_GRID'
,p_display_name=>'Simple Grid'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#IMAGE_PREFIX#libraries/apex/#MIN_DIRECTORY#model#MIN#.js',
'#IMAGE_PREFIX#libraries/apex/#MIN_DIRECTORY#widget.stickyWidget#MIN#.js',
'#IMAGE_PREFIX#libraries/apex/#MIN_DIRECTORY#widget.tableModelViewBase#MIN#.js',
'#IMAGE_PREFIX#libraries/apex/#MIN_DIRECTORY#widget.grid#MIN#.js',
'#PLUGIN_FILES#simple_grid.js'))
,p_css_file_urls=>'#PLUGIN_FILES#simple_grid.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'type t_sort_rec is record (',
'    col varchar2(200),',
'    dir varchar2(6)',
');',
'type t_sorts is table of t_sort_rec index by pls_integer;',
'empty_sorts t_sorts;',
'empty_filters apex_exec.t_filters;',
'',
'function get_effective_region_columns (',
'    p_column_mapping   in varchar2,',
'    p_region_columns   in apex_plugin.t_region_columns )',
'    return apex_plugin.t_region_columns',
'is',
'    l_region_columns   apex_plugin.t_region_columns;',
'    l_context          apex_exec.t_context;',
'    l_count            pls_integer;',
'    l_columns          apex_exec.t_columns;',
'    l_column           apex_exec.t_column;',
'    l_type             varchar2(30);',
'begin',
'',
'    if p_column_mapping is not null then',
'    begin',
'        -- The run time and design time columns can be different so need to create',
'        -- new region_column metadata based on what columns actually exist',
'        -- Note: This is expensive because it executes the query. But we need the',
'        -- column metadata including sort info and to a lesser extent the format mask.',
'        -- Maybe someday there will be a way to get the apex_exec columns another way. ',
'        l_context := apex_exec.open_query_context(',
'            p_first_row         => 1,',
'            p_max_rows          => 1);',
'',
'        l_count := apex_exec.get_column_count(l_context);',
'        for i in 1 .. l_count loop',
'            l_column := apex_exec.get_column(l_context, i);',
'            -- get column info based on p_column_mapping',
'            case p_column_mapping',
'            when ''POS'' then',
'                if i > p_region_columns.count then',
'                    l_region_columns(i) := p_region_columns(p_region_columns.last);',
'                else',
'                    l_region_columns(i) := p_region_columns(i);',
'                end if;',
'            when ''NAME'' then',
'                for j in 1 .. p_region_columns.count loop',
'                    if p_region_columns(j).name = l_column.name then',
'                        l_region_columns(i) := p_region_columns(j);',
'                        exit;',
'                    end if;',
'                end loop;',
'            when ''TYPE'' then',
'                l_type := apex_exec.get_data_type(l_column.data_type);',
'                for j in 1 .. p_region_columns.count loop',
'                    if p_region_columns(j).name = l_type then',
'                        l_region_columns(i) := p_region_columns(j);',
'                        exit;',
'                    end if;',
'                end loop;',
'            -- else NONE',
'            end case;',
'            l_region_columns(i).name := l_column.name;',
'            if l_region_columns(i).heading is null then',
'                l_region_columns(i).heading := initcap(regexp_replace(l_column.name, ''[_$]'', '' ''));',
'            end if;',
'        end loop;',
'',
'        apex_exec.close(l_context);',
'',
'    exception when others then',
'        apex_exec.close(l_context);',
'        raise;',
'    end;',
'    else',
'        -- have fixed columns',
'        -- the run time and design time columns are the same so use the region column metadata as is',
'        l_region_columns := p_region_columns;',
'    end if;',
'',
'    return l_region_columns;',
'end get_effective_region_columns;',
'',
'-- implicit in/out is APEX_JSON context',
'procedure simple_grid_columns (',
'    p_region                   in apex_plugin.t_region,',
'    p_effective_region_columns in apex_plugin.t_region_columns)',
'is',
'    l_col              apex_plugin.t_region_column;',
'',
'    function alignment(p_alignment in varchar2) return varchar2',
'    is',
'        l_return varchar2(30);',
'    begin',
'        l_return := case p_alignment ',
'                      when ''END'' then ''end''',
'                      when ''RIGHT'' then ''end''',
'                      when ''START'' then ''start''',
'                      when ''LEFT'' then ''start''',
'                      when ''CENTER'' then ''center''',
'                      else ''start''',
'                      end;',
'        return l_return;',
'    end;',
'begin',
'',
'    -- the columns object is already open',
'    for i in 1 .. p_effective_region_columns.count loop',
'        l_col := p_effective_region_columns(i);',
'        apex_json.open_object(l_col.name);',
'        apex_json.write(''heading'', l_col.heading);',
'        apex_json.write(''headingAlignment'', alignment(l_col.heading_alignment));',
'        apex_json.write(''alignment'', alignment(l_col.value_alignment));',
'        apex_json.write(''label'', l_col.attribute_09);',
'        apex_json.write(''headingCssClasses'', l_col.attribute_11);',
'        apex_json.write(''columnCssClasses'', l_col.value_css_classes);',
'        apex_json.write(''cellTemplate'', l_col.attribute_01);',
'        apex_json.write(''escape'', l_col.escape_output);',
'        apex_json.write(''noStretch'', case l_col.attribute_08 ',
'                                          when ''D'' then',
'                                              case when p_region.attribute_16 = ''N'' then true else false end',
'                                          when ''N'' then true else false end);',
'        apex_json.write(''canHide'', case when l_col.is_displayed and l_col.attribute_04 = ''Y'' then true else false end);',
'        -- trouble with is_displayed is that it takes away the heading etc. so that is why we have Initially Hidden',
'        apex_json.write(''hidden'', case when not l_col.is_displayed or l_col.attribute_10 = ''Y'' then true else false end);',
'--        apex_json.write(''linkTargetColumn'', todo);',
'--        apex_json.write(''linkText'', todo);',
'--        apex_json.write(''linkAttributes'', todo);',
'--        apex_json.write(''helpid'', todo);',
'        apex_json.write(''usedAsRowHeader'', case when l_col.attribute_05 = ''Y'' then true else false end);',
'        apex_json.write(''canSort'', case when l_col.attribute_02 != ''NO'' then true else false end);',
'        apex_json.write(''sortDirection'', case l_col.attribute_02 when ''ASC'' then ''asc'' when ''DESC'' then ''desc'' else null end);',
'        apex_json.write(''sortIndex'', case when l_col.attribute_02 in (''ASC'', ''DESC'') then l_col.attribute_03 else null end);',
'        apex_json.write(''seq'', to_number(nvl(l_col.attribute_12, i * 10)));',
'        apex_json.write(''width'', to_number(l_col.attribute_07) );',
'        apex_json.write(''frozen'', case when l_col.attribute_13 = ''Y'' then true else false end);',
'        -- not a grid or model property but used to set model identityField',
'        apex_json.write(''pk'', case when l_col.attribute_06 = ''Y'' then true else false end);',
'        apex_json.write(''index'', i - 1); -- make sure this is to be the order of columns back from apex_exec',
'        apex_json.close_object;',
'    end loop;',
'end simple_grid_columns;',
'',
'-- implicit in/out is APEX_JSON context',
'procedure simple_grid_data (',
'    p_region         in apex_plugin.t_region,',
'    p_effective_region_columns in apex_plugin.t_region_columns,',
'    p_first_row      in pls_integer,',
'    p_max_rows       in pls_integer,',
'    p_sorts          in t_sorts default empty_sorts,',
'    p_filters        in apex_exec.t_filters default empty_filters)',
'is',
'    c_has_total_records constant boolean := case when p_region.attribute_09 = ''Y'' then true else false end;',
'    l_columns          apex_exec.t_columns;',
'    l_context          apex_exec.t_context;',
'    l_col              apex_plugin.t_region_column;',
'    l_count            number;',
'    l_col_count        pls_integer;',
'    l_more_data        boolean;',
'    l_sorts            t_sorts;',
'    l_order_bys        apex_exec.t_order_bys;',
'    l_sort_seq         pls_integer;',
'begin',
'',
'    for i in 1 .. p_effective_region_columns.count loop',
'        l_col := p_effective_region_columns(i);',
'        apex_exec.add_column(',
'            p_columns => l_columns,',
'            p_column_name => l_col.name,',
'            p_format_mask => l_col.format_mask',
'        );',
'        if p_sorts.count = 0 and l_col.attribute_02 in (''ASC'', ''DESC'') then',
'            l_sort_seq := to_number(l_col.attribute_03);',
'            l_sorts(l_sort_seq).col := l_col.name;',
'            l_sorts(l_sort_seq).dir := l_col.attribute_02;',
'        end if;',
'    end loop;',
'',
'    if p_sorts is not null then',
'        l_sorts := p_sorts;',
'    end if;',
'',
'    if l_sorts.first is not null then',
'        for i in l_sorts.first .. l_sorts.last loop',
'            apex_exec.add_order_by(',
'                p_order_bys     => l_order_bys,',
'                p_column_name   => l_sorts(i).col,',
'                p_direction     => case l_sorts(i).dir when ''ASC'' then apex_exec.c_order_asc else apex_exec.c_order_desc end );',
'        end loop;',
'    end if;',
'',
'    l_context := apex_exec.open_query_context(',
'        p_order_bys         => l_order_bys,',
'        p_filters           => p_filters,',
'        p_first_row         => p_first_row,',
'        p_max_rows          => p_max_rows + 1, -- ask for 1 more to know if there is more data',
'        p_total_row_count   => c_has_total_records,',
'        p_columns           => l_columns);',
'',
'    -- the json structure returned is very specific to what the model is expecting',
'    apex_json.open_array(''values'');',
'    l_count := 0;',
'    l_more_data := false;',
'    l_col_count := apex_exec.get_column_count(l_context);',
'    while apex_exec.next_row(l_context) loop',
'        if l_count >= p_max_rows then',
'            l_more_data := true;',
'            exit;',
'        end if;',
'        l_count := l_count + 1;',
'        apex_json.open_array;',
'        for i in 1 .. l_col_count loop',
'            if apex_exec.get_column(l_context, i).data_type in (apex_exec.c_data_type_blob, apex_exec.c_data_type_bfile, apex_exec.c_data_type_clob ) then',
'                apex_json.write( ''[lob]'' );',
'            else',
'                apex_json.write( apex_exec.get_varchar2(l_context, i) ); -- this applies the format mask if there is one.',
'            end if;',
'        end loop;',
'        apex_json.close_array;',
'    end loop;',
'    apex_json.close_array;',
'    apex_json.write(''firstRow'', p_first_row);',
'    apex_json.write(''moreData'', l_more_data);',
'    if c_has_total_records then',
'        apex_json.write(''totalRows'', apex_exec.get_total_row_count(l_context) );',
'    end if;',
'    apex_exec.close(l_context);',
'',
'exception when others then',
'    apex_exec.close(l_context);',
'    raise;',
'end simple_grid_data;',
'',
'function simple_grid_render (',
'    p_region              in apex_plugin.t_region,',
'    p_plugin              in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'    return apex_plugin.t_region_render_result ',
'is',
'    c_lazy_load    constant boolean := case when p_region.attribute_02 = ''Y'' then true else false end;',
'    c_column_sort  constant boolean := case when instr(p_region.attribute_01, ''SORT'') > 0 then true else false end;',
'    c_reorder_col  constant boolean := case when instr(p_region.attribute_01, ''REORDER'') > 0 then true else false end;',
'    c_resize_col   constant boolean := case when instr(p_region.attribute_01, ''RESIZE'') > 0 then true else false end;',
'    c_has_js_init  constant boolean := case when length(p_region.init_javascript_code) > 0 then true else false end;',
'    c_footer       constant boolean := case when p_region.attribute_03 = ''Y'' then true else false end;',
'    c_select_cells constant boolean := case when p_region.attribute_04 = ''CELL'' then true else false end;',
'    c_multiple     constant boolean := case when p_region.attribute_05 = ''Y'' then true else false end;',
'    c_sel_control  constant boolean := case when p_region.attribute_06 = ''Y'' then true else false end;',
'    c_select_all   constant boolean := case when p_region.attribute_07 = ''Y'' then true else false end;',
'    c_scroll       constant boolean := case when p_region.attribute_08 = ''SCROLL'' then true else false end;',
'    c_has_total_records constant boolean := case when p_region.attribute_09 = ''Y'' then true else false end;',
'    c_rows_per_page constant number := nvl(p_region.attribute_10, 15);',
'    c_show_range   constant boolean := case when p_region.attribute_11 = ''Y'' then true else false end;',
'    c_page_selector constant boolean := case when not c_scroll and p_region.attribute_12 = ''LIST'' then true else false end;',
'    c_page_links   constant boolean := case when not c_scroll and p_region.attribute_12 = ''LINKS'' then true else false end;',
'    c_load_more    constant boolean := case when c_scroll and p_region.attribute_13 = ''Y'' then true else false end;',
'    c_first_last   constant boolean := case when not c_scroll and p_region.attribute_14 = ''Y'' then true else false end;',
'    c_show_null_as constant varchar2(4000) := nvl(p_region.attribute_15, '''');',
'    c_column_mapping constant varchar2(20) := p_region.attribute_17;',
'    c_persist_cols constant boolean := case when p_region.attribute_18 = ''Y'' then true else false end;',
'    c_has_size     constant boolean := case when p_region.attribute_19 = ''REGION'' then true else false end;',
'    c_sticky       constant boolean := case when p_region.attribute_19 = ''PAGE'' then true else false end;',
'    c_grid_height  constant varchar2(20) := p_region.attribute_20;',
'    l_region_columns apex_plugin.t_region_columns;',
'    l_model_name   varchar2(32767);',
'    l_colmap       varchar2(32767);',
'    l_data         clob;',
'    l_buffer       varchar2( 32767 );',
'    l_buffer2      varchar2( 32767 );',
'    l_offset       pls_integer;',
'    l_amount       pls_integer;',
'    l_result       apex_plugin.t_region_render_result;',
'begin',
'    apex_plugin_util.debug_region(p_plugin, p_region, p_is_printer_friendly);',
'',
'    l_region_columns := get_effective_region_columns(',
'        p_column_mapping => c_column_mapping,',
'        p_region_columns => p_region.region_columns);',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    simple_grid_columns(p_region, l_region_columns);',
'    apex_json.close_object;',
'    l_colmap := to_char(apex_json.get_clob_output);',
'    apex_json.free_output;',
'',
'    l_model_name := ''m'' || p_region.static_id;',
'',
'    -- client and server must agree on this DOM id',
'    sys.htp.p( ''<div class="sizer"><div id="'' || apex_escape.html_attribute( p_region.static_id ) || ''_g"></div></div>'' );',
'',
'    if not c_lazy_load then',
'        sys.htp.p( ''<script type="text/javascript">'' );',
'        -- client and server must agree on this global variable',
'        sys.htp.prn( ''var gSGdata_'' || p_region.id || '' = '' );',
'',
'        apex_json.initialize_clob_output;',
'        apex_json.open_object;',
'',
'        simple_grid_data(',
'            p_region => p_region,',
'            p_effective_region_columns => l_region_columns,',
'            p_first_row   => 1,',
'            -- for traditional paging get rows_per_page records or at least 50',
'            p_max_rows    => case when c_scroll then 50 else greatest( c_rows_per_page, 50) end );',
'',
'        apex_json.close_object;',
'        ',
'        l_data   := apex_json.get_clob_output;',
'        l_amount := 8000;',
'        l_offset := 1;',
'        begin',
'            loop',
'                l_buffer := null;',
'                sys.dbms_lob.read( l_data, l_amount, l_offset, l_buffer );',
'                if l_buffer2 is not null then',
'                    l_buffer := l_buffer2 || l_buffer;',
'                end if;',
'',
'                sys.htp.prn( substr(l_buffer, 1, 7950));',
'',
'                l_buffer2 := substr(l_buffer, 7951);',
'                l_offset  := l_offset + l_amount;',
'                l_amount  := 8000;',
'            end loop;',
'        exception',
'             when no_data_found then',
'                 null;',
'        end;',
'        sys.htp.prn(l_buffer2);',
'        sys.htp.p('';'');',
'        sys.htp.p(''</script>'');',
'        apex_json.free_output;',
'    end if;',
'',
'-- strange that I couldn''t get add_library to work with apex files; the #MIN*# substitutions didn''t work',
'--    apex_javascript.add_library (',
'--        p_name => ''model#MIN#'', p_directory => c_apex_dir );',
'-- added to JavaScript File URLs below',
'',
'    apex_javascript.add_onload_code (',
'        p_code => ''simpleGridRegionInit('' ||',
'                case when c_has_js_init then p_region.init_javascript_code || ''('' end || ''{''||',
'                apex_javascript.add_attribute( ''ajaxIdentifier'', apex_plugin.get_ajax_identifier, false, true ) ||',
'                apex_javascript.add_attribute( ''itemsToSubmit'', apex_plugin_util.page_item_names_to_jquery( p_region.ajax_items_to_submit ), false, true ) ||',
'                apex_javascript.add_attribute( ''regionStaticId'', p_region.static_id, false, true ) ||',
'                apex_javascript.add_attribute( ''regionId'', to_char(p_region.id), false, true ) ||',
'                apex_javascript.add_attribute( ''persistColumnState'', c_persist_cols, false, true ) ||',
'                apex_javascript.add_attribute( ''gridHeight'', c_grid_height, false, true ) ||',
'                apex_javascript.add_attribute( ''lazyLoad'', c_lazy_load, false, true ) ||',
'                apex_javascript.add_attribute( ''modelName'', l_model_name, false, true ) ||',
'                ''modelOptions: {'' ||',
'                    apex_javascript.add_attribute( ''hasTotalRecords'', c_has_total_records, false, false ) ||',
'                    -- identityField set by client',
'                ''},'' ||',
'                apex_javascript.add_attribute( ''columnSort'', c_column_sort, false, true ) ||',
'                apex_javascript.add_attribute( ''columnSortMultiple'', c_column_sort, false, true ) ||',
'                apex_javascript.add_attribute( ''reorderColumns'', c_reorder_col, false, true ) ||',
'                apex_javascript.add_attribute( ''resizeColumns'', c_resize_col, false, true ) ||',
'                apex_javascript.add_attribute( ''noDataMessage'', p_region.no_data_found_message, false, true ) ||',
'                apex_javascript.add_attribute( ''footer'', c_footer, false, true ) ||',
'                apex_javascript.add_attribute( ''hasSize'', c_has_size, false, true ) ||',
'                apex_javascript.add_attribute( ''multiple'', c_multiple, false, true ) ||',
'                apex_javascript.add_attribute( ''multipleCells'', c_multiple, false, true ) ||',
'                apex_javascript.add_attribute( ''rowHeader'', case when c_sel_control then ''plain'' else ''none'' end, false, true ) ||',
'                apex_javascript.add_attribute( ''rowHeaderCheckbox'', c_sel_control, false, true ) ||',
'                ''pagination: {'' ||',
'                    apex_javascript.add_attribute( ''scroll'', c_scroll, false, true ) ||',
'                    apex_javascript.add_attribute( ''showPageSelector'', c_page_selector, false, true ) ||',
'                    apex_javascript.add_attribute( ''showPageLinks'', c_page_links, false, true ) ||',
'                    apex_javascript.add_attribute( ''firstAndLastButtons'', c_first_last, false, true ) ||',
'                    apex_javascript.add_attribute( ''loadMore'', c_load_more, false, true ) ||',
'                    apex_javascript.add_attribute( ''showRange'', c_show_range, false, false ) ||',
'                ''},'' ||',
'                apex_javascript.add_attribute( ''rowsPerPage'', c_rows_per_page, false, true ) ||',
'                apex_javascript.add_attribute( ''selectAll'', c_select_all, false, true ) ||',
'                apex_javascript.add_attribute( ''selectCells'', c_select_cells, false, true ) ||',
'                apex_javascript.add_attribute( ''stickyFooter'', c_sticky, false, true ) ||',
'                apex_javascript.add_attribute( ''stickyTop'', c_sticky, false, true ) ||',
'                apex_javascript.add_attribute( ''showNullAs'', c_show_null_as, false, true ) ||',
'                ''columns: [''|| l_colmap ||'']'' ||',
'                ''}'' || case when c_has_js_init then '')'' end || '');'' );',
'',
'    return l_result;',
'end simple_grid_render;',
'',
'function simple_grid_ajax (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin )',
'    return apex_plugin.t_region_ajax_result',
'is',
'    c_column_mapping constant varchar2(20) := p_region.attribute_17;',
'    l_result      apex_plugin.t_region_ajax_result;',
'    l_region_columns apex_plugin.t_region_columns;',
'    l_path        varchar2(32767);',
'    l_path2       varchar2(32767);',
'    l_sort_path   varchar2(32767);',
'    l_filter_path varchar2(32767);',
'    l_first_row   number;',
'    l_max_rows    number;',
'    l_sorts       t_sorts;',
'    l_sort_seq    pls_integer;',
'    l_count       pls_integer;',
'    l_filters     apex_exec.t_filters;',
'    l_filter_type apex_exec.t_filter_type;',
'    l_filter_col  varchar2(32767);',
'begin',
'    apex_plugin_util.debug_region(p_plugin, p_region);',
'',
'    l_region_columns := get_effective_region_columns(',
'        p_column_mapping => c_column_mapping,',
'        p_region_columns => p_region.region_columns);',
'',
'    -- fetchData is for getting model data',
'    l_path := ''regions[1]''; -- expect just one region and expect the right request to be routed here',
'    if apex_json.does_exist( l_path || ''.fetchData'' ) then',
'        l_path := l_path || ''.fetchData'';',
'        -- the other possibility is the model sends primaryKeys property but currently don''t handle that',
'        -- or if the model were for a tree parentId property but also not expecting that',
'        l_first_row := apex_json.get_number(l_path || ''.firstRow'');',
'        l_max_rows := apex_json.get_number(l_path || ''.maxRows'');',
'',
'        -- get filter info from request',
'        if apex_json.does_exist( l_path || ''.filters'' ) then',
'            l_path2 := l_path || ''.filters'';',
'            l_count := apex_json.get_count( l_path2 );',
'',
'            for i in 1 .. l_count loop',
'                l_filter_path := l_path2 || ''['' || i || '']'';',
'                l_filter_col := apex_json.get_varchar2(l_filter_path || ''.column'');',
'                l_filter_type := apex_json.get_number(l_filter_path || ''.type'');',
'                case when l_filter_type in (',
'                        apex_exec.c_filter_eq,',
'                        apex_exec.c_filter_not_eq,',
'                        apex_exec.c_filter_gt,',
'                        apex_exec.c_filter_gte,',
'                        apex_exec.c_filter_lt,',
'                        apex_exec.c_filter_lte,',
'                        apex_exec.c_filter_starts_with,',
'                        apex_exec.c_filter_not_starts_with,',
'                        apex_exec.c_filter_ends_with,',
'                        apex_exec.c_filter_not_ends_with,',
'                        apex_exec.c_filter_contains,',
'                        apex_exec.c_filter_not_contains,',
'                        apex_exec.c_filter_regexp',
'                    ) and apex_json.does_exist( l_filter_path || ''.value'' ) then',
'',
'                    apex_exec.add_filter(',
'                        p_filters => l_filters,',
'                        p_filter_type => l_filter_type,',
'                        p_column_name => l_filter_col,',
'                        p_value => apex_json.get_varchar2(l_filter_path || ''.value'')',
'                    );',
'                when l_filter_type in (apex_exec.c_filter_null, apex_exec.c_filter_not_null) then',
'',
'                    apex_exec.add_filter(',
'                        p_filters => l_filters,',
'                        p_filter_type => l_filter_type,',
'                        p_column_name => l_filter_col',
'                    );',
'                when l_filter_type in (apex_exec.c_filter_in, apex_exec.c_filter_not_in)',
'                    and apex_json.does_exist( l_filter_path || ''.values'' ) then',
'',
'                    apex_exec.add_filter(',
'                        p_filters => l_filters,',
'                        p_filter_type => l_filter_type,',
'                        p_column_name => l_filter_col,',
'                        p_values => apex_json.get_t_varchar2(l_filter_path || ''.values'')',
'                    );',
'                when l_filter_type in (apex_exec.c_filter_between, apex_exec.c_filter_not_between)',
'                    and apex_json.does_exist( l_filter_path || ''.fromValue'' ) and apex_json.does_exist( l_filter_path || ''.toValue'' ) then',
'',
'                    apex_exec.add_filter(',
'                        p_filters => l_filters,',
'                        p_filter_type => l_filter_type,',
'                        p_column_name => l_filter_col,',
'                        p_from_value => apex_json.get_varchar2(l_filter_path || ''.fromValue''),',
'                        p_to_value => apex_json.get_varchar2(l_filter_path || ''.toValue'')',
'                    );',
'                -- todo there are a few more filter types to handle',
'                end case;',
'            end loop;',
'            -- todo persist filters somehow?',
'        end if;',
'',
'        -- get sort info from request',
'        if apex_json.does_exist( l_path || ''.sorts'' ) then',
'            l_path2 := l_path || ''.sorts'';',
'            l_count := apex_json.get_count( l_path2 );',
'',
'            for i in 1 .. l_count loop',
'                l_sort_path := l_path2 || ''['' || i || '']'';',
'                l_sort_seq := to_number(apex_json.get_varchar2(l_sort_path || ''.index''));',
'                l_sorts(l_sort_seq).col := apex_json.get_varchar2(l_sort_path || ''.column'');',
'                l_sorts(l_sort_seq).dir := apex_json.get_varchar2(l_sort_path || ''.direction'');',
'            end loop;',
'            -- todo persist sort order somehow?',
'        end if;',
'',
'        -- the json structure returned is very specific to what the model is expecting',
'        apex_json.open_object(''fetchedData'');',
'        simple_grid_data(',
'            p_region => p_region,',
'            p_effective_region_columns => l_region_columns,',
'            p_first_row   => l_first_row,',
'            p_max_rows    => l_max_rows,',
'            p_sorts       => l_sorts,',
'            p_filters     => l_filters);',
'        apex_json.close_object;',
'    end if;',
'',
'    -- getColumns is for when the columns change only applies to source type PL/SQL function returning SQL',
'    l_path := ''regions[1]''; -- expect just one region and expect the right request to be routed here',
'    if apex_json.does_exist( l_path || ''.getColumns'' ) then',
'        l_path := l_path || ''.getColumns'';',
'        apex_json.open_object(''columns'');',
'        simple_grid_columns(p_region, l_region_columns);',
'        apex_json.close_object;',
'    end if;',
'',
'    return l_result;',
'end simple_grid_ajax;'))
,p_api_version=>2
,p_render_function=>'simple_grid_render'
,p_ajax_function=>'simple_grid_ajax'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE:INIT_JAVASCRIPT_CODE:COLUMNS:COLUMN_HEADING:HEADING_ALIGNMENT:VALUE_ALIGNMENT:VALUE_CSS:VALUE_ESCAPE_OUTPUT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A simple grid report region using the APEX grid widget. Reporting only; no editing. Supports grid features such as frozen columns, selection, and all the pagination options.',
'Proof of concept/Work in progress. Doesn''t support column groups, aggregates, highlights, or control breaks. Supports dynamic columns.'))
,p_version_identifier=>'1'
,p_files_version=>70
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046149129912207468)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Cell Template'
,p_attribute_type=>'HTML'
,p_is_required=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_examples=>'<em>&FIRST_NAME. &LAST_NAME.</em>'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>HTML markup template to go in the cells of this column. Reference columns with syntax:</p>',
'<code>&COLUMN_NAME.</code>',
'<p>See apex.util.applyTemplate for details on substitution syntax.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046150072051211947)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Sort'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Specify if and how the grid should be sorted on this column.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19046150952788214528)
,p_plugin_attribute_id=>wwv_flow_api.id(19046150072051211947)
,p_display_sequence=>10
,p_display_value=>'Don''t Sort'
,p_return_value=>'NONE'
,p_help_text=>'The grid will not be sorted on this column.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19046151377754217635)
,p_plugin_attribute_id=>wwv_flow_api.id(19046150072051211947)
,p_display_sequence=>20
,p_display_value=>'Ascending'
,p_return_value=>'ASC'
,p_help_text=>'The grid will be sorted ascending on this column.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19046151700068219487)
,p_plugin_attribute_id=>wwv_flow_api.id(19046150072051211947)
,p_display_sequence=>30
,p_display_value=>'Descending'
,p_return_value=>'DESC'
,p_help_text=>'The grid will be sorted descending on this column.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19046164703987342085)
,p_plugin_attribute_id=>wwv_flow_api.id(19046150072051211947)
,p_display_sequence=>40
,p_display_value=>'Not Allowed'
,p_return_value=>'NO'
,p_help_text=>'The user is not able to choose this column for sorting.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046153236394240168)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Sort Order'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'1'
,p_display_length=>5
,p_max_length=>10
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19046150072051211947)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'ASC,DESC'
,p_help_text=>'Specify the sort order for this column. If the grid is sorted on multiple columns then first sort on the column with the lowest Sort Order then on the column with the next lowest Sort Order and so on.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046166002613350799)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Allow user to show/hide'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Specify if the user is allowed to show or hide this column.'
);
end;
/
begin
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046167568811371795)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Use as Row Header'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Set to Yes if this column is the row header for the row. The value of this column is used by assistive technology to associate the row with this column value.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19046168611989382510)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>6
,p_display_sequence=>1
,p_prompt=>'Primary Key'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Set to Yes if this column is a primary key.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19055468180550716947)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Width'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_show_in_wizard=>false
,p_display_length=>5
,p_max_length=>10
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>'The minimum width of the column in pixels. Leave empty for browser to choose initial default width.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19055469732268722096)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Stretch'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'D'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Specify if the width of the column can stretch to make use of additional width.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19055470794032724367)
,p_plugin_attribute_id=>wwv_flow_api.id(19055469732268722096)
,p_display_sequence=>10
,p_display_value=>'Use Region Setting'
,p_return_value=>'D'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19055472036014726652)
,p_plugin_attribute_id=>wwv_flow_api.id(19055469732268722096)
,p_display_sequence=>20
,p_display_value=>'Yes'
,p_return_value=>'Y'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19055490232793727529)
,p_plugin_attribute_id=>wwv_flow_api.id(19055469732268722096)
,p_display_sequence=>30
,p_display_value=>'No'
,p_return_value=>'N'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19058945978979085983)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Alternate Heading Label'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_show_in_wizard=>false
,p_display_length=>60
,p_max_length=>200
,p_is_translatable=>true
,p_help_text=>'Provide a plain text alternative heading label when the heading includes markup. The alternate label is used in menus and any other place where heading markup is not desired.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19058948063193143032)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>10
,p_display_sequence=>45
,p_prompt=>'Initially Hidden'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19046166002613350799)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Specify if the column is initially hidden.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19058969915456339977)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Heading CSS Classes'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_show_in_wizard=>false
,p_display_length=>60
,p_max_length=>400
,p_is_translatable=>false
,p_help_text=>'CSS classes to add to the column header.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19058971102815374764)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>12
,p_display_sequence=>5
,p_prompt=>'Column Order'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'10'
,p_display_length=>5
,p_max_length=>10
,p_is_translatable=>false
,p_help_text=>'Specify the order of the column. Smaller numbers are closer to the start of the row and larger numbers closer to the end of the row.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19058972046810381237)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COLUMN'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Frozen'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Specify if this column is frozen so that it does not scroll horizontally.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18862944365861490865)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Column Header Options'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'SORT:REORDER:RESIZE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'These options control how the user can interact with the grid column headings.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(18862944906695494936)
,p_plugin_attribute_id=>wwv_flow_api.id(18862944365861490865)
,p_display_sequence=>10
,p_display_value=>'Sort'
,p_return_value=>'SORT'
,p_help_text=>'Column headers have sort controls.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(18862945365237497287)
,p_plugin_attribute_id=>wwv_flow_api.id(18862944365861490865)
,p_display_sequence=>20
,p_display_value=>'Reorder'
,p_return_value=>'REORDER'
,p_help_text=>'Columns can be reordered'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(18862945715853499419)
,p_plugin_attribute_id=>wwv_flow_api.id(18862944365861490865)
,p_display_sequence=>30
,p_display_value=>'Resize'
,p_return_value=>'RESIZE'
,p_help_text=>'Columns can be resized'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18862946430356547660)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Lazy Load'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>When Yes, no data for the Simple Grid is fetched as part of rendering the page. When the page loads it makes a request to fetch data. This ',
'can be useful to make the page load faster when the SQL Query takes a long time or if the Simple Grid region is not initially visible.</p>',
'<p>When No, the initial data for the Simple Grid is fetched and rendered as part of the page rendering.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18991446270107735342)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Show Footer'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If Yes a footer is shown. If No the footer is not shown.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18991447436597752841)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Selection Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'ROW'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify the selection mode. This can be changed at run time using code such as:</p>',
'<pre><code>',
'apex.region("region-static-id").call( "option", "selectCells", true ); // cell selection mode',
'apex.region("region-static-id").call( "option", "selectCells", false ); // row selection mode',
'</code></pre>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(18991448287752757004)
,p_plugin_attribute_id=>wwv_flow_api.id(18991447436597752841)
,p_display_sequence=>10
,p_display_value=>'Rows'
,p_return_value=>'ROW'
,p_help_text=>'Select rows'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(18991448635592758461)
,p_plugin_attribute_id=>wwv_flow_api.id(18991447436597752841)
,p_display_sequence=>20
,p_display_value=>'Cells'
,p_return_value=>'CELL'
,p_help_text=>'Select cells'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18991446874932749215)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Multiple Selection'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Specifies if multiple rows (or cells) can be selected.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18991449731273777035)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Show Selection Control'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Specify if a checkbox (or radio button for single selection) is shown in a row selector header.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(18991450334226783770)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Select All'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Specify if select all is allowed. Only applies when selecting multiple rows is possible. If this is Yes and Show Selection Control is Yes there is a checkbox at the top of the row selection header column that selects all rows. If Show Selection Contr'
||'ol is false all rows can still be selected using Ctrl+A.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020162864170645304)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Pagination Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'SCROLL'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Select either traditional or scroll pagination. Traditional paging shows one page of rows at a time and has next and previous page buttons. Scroll paging adds more rows as the user scrolls.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19020163772419646533)
,p_plugin_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_display_sequence=>10
,p_display_value=>'Scroll'
,p_return_value=>'SCROLL'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19020164166670648017)
,p_plugin_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_display_sequence=>20
,p_display_value=>'Traditional'
,p_return_value=>'PAGE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020165067858655866)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Show Total Row Count'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify whether to display the total row count in the grid footer. This also affects how scroll pagination works.</p>',
'<p>Note - An additional query is performed to obtain the total row count, which may hinder performance, especially on very large data sets.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020166054045761569)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Rows Per Page'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'15'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PAGE'
,p_help_text=>'For traditional paging this controls how many rows are shown on the page. Setting too large a value can result in poor performance.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020176988229989889)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>95
,p_prompt=>'Show Range'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Show the range of rows in the grid footer or not.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020177814574996225)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Page Navigation'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'LINKS'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PAGE'
,p_lov_type=>'STATIC'
,p_help_text=>'Specify if the grid footer includes pagination controls to go directly to a specific page. Only applies to traditional pagination.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19020178701615997279)
,p_plugin_attribute_id=>wwv_flow_api.id(19020177814574996225)
,p_display_sequence=>10
,p_display_value=>'Links'
,p_return_value=>'LINKS'
,p_help_text=>'Show page links.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19020179137331998768)
,p_plugin_attribute_id=>wwv_flow_api.id(19020177814574996225)
,p_display_sequence=>20
,p_display_value=>'Select List'
,p_return_value=>'LIST'
,p_help_text=>'Show a drop down select list of pages.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19020179497590999480)
,p_plugin_attribute_id=>wwv_flow_api.id(19020177814574996225)
,p_display_sequence=>30
,p_display_value=>'None'
,p_return_value=>'NONE'
,p_help_text=>'No direct page navigation.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020182167286145394)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Load More'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'SCROLL'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'When Yes, a Load More button is used to add more rows. When No, more rows are added automatically when the user scrolls to the end.',
'This only applies to scroll pagination and only when Show Total Row count is No.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020183125858163370)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_prompt=>'Show First and Last Buttons'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19020162864170645304)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PAGE'
,p_help_text=>'In addition to next and previous buttons show first and last buttons. Only applies for traditional pagination and when Show Total Row Count is Yes.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19020184187604187658)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Show Null Values as'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_show_in_wizard=>false
,p_display_length=>10
,p_max_length=>100
,p_is_translatable=>false
,p_examples=>'-null-'
,p_help_text=>'When a value is null show this text instead.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19055512856809763386)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_prompt=>'Stretch Columns'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'This controls the default column width stretching behavior when the grid is wider than all the columns. When Yes the default will be to stretch column widths to fill any empty space. This can be overridden for each column with the column Stretch attr'
||'ibute.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19072006604967286136)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_prompt=>'Column Mapping'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_null_text=>'default'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This only applies when Source Type is PL/SQL Function Body returning SQL Query <b>and</b> the SQL query returned can have different columns.',
'At design time the columns returned by the function may not be the same as the ones at run time. In addition the set of columns',
'could vary from one request to the next. This attribute determines how the design time metadata is matched with and used for run time',
'columns. If the design time and run time columns will always be the same then this must be set to the "default" value.</p>',
'<p>The client code must be aware of when the column metadata changes. Typically this happens when region page items to submit have changed and the',
'simple grid region is going to be refreshed. Rather than refresh the region with the Refresh DA action or apex.region(...).refresh() the following',
'must be called:</p>',
'<pre><code>apex.region("<i>static-id</i>").changeColumns(key);',
'</code></pre>',
'<p>The argument <code>key</code> is a string that uniquely represents the column configuration so that column state can be persisted correctly and',
'not confused with other column configurations.</p>'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072109924206479796)
,p_plugin_attribute_id=>wwv_flow_api.id(19072006604967286136)
,p_display_sequence=>5
,p_display_value=>'None'
,p_return_value=>'NONE'
,p_help_text=>'Run time columns are not matched with design time column metadata. Default column metadata is used and the heading is derived from the column name.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072008049386296743)
,p_plugin_attribute_id=>wwv_flow_api.id(19072006604967286136)
,p_display_sequence=>10
,p_display_value=>'By Position'
,p_return_value=>'POS'
,p_help_text=>'<p>The i<sup>th</sup> run time column is matched with the i<sup>th</sup> design time column. If there are more run time columns than design time columns the last design time column is used for all the extra ones. In this way a single design time colu'
||'mn could be used for all the run time columns.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072008468363310830)
,p_plugin_attribute_id=>wwv_flow_api.id(19072006604967286136)
,p_display_sequence=>20
,p_display_value=>'By Column Name'
,p_return_value=>'NAME'
,p_help_text=>'Run time columns are matched with design time column metadata by column name. If there is no matching column name then default column metadata is used and the heading is derived from the column name.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072008801576330908)
,p_plugin_attribute_id=>wwv_flow_api.id(19072006604967286136)
,p_display_sequence=>30
,p_display_value=>'By Data Type'
,p_return_value=>'TYPE'
,p_help_text=>'Run time columns are matched with design time column metadata by data type. The design time columns should have column names that match standard data types such as VARCHAR2, DATE, NUMBER etc.  The heading is derived from the run time column name. Not'
||' Yet Implemented.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19072167952856774064)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>164
,p_prompt=>'Persist Column State'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Column state consists of the width, order, frozen, and visibility of each column.',
'If yes the column state will be persisted in client session storage.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19072903299615551362)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>190
,p_prompt=>'Heading Fixed To'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'REGION'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Specify how to handle sticky header and footer, and scroll area.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072904972556558731)
,p_plugin_attribute_id=>wwv_flow_api.id(19072903299615551362)
,p_display_sequence=>10
,p_display_value=>'None'
,p_return_value=>'NONE'
,p_help_text=>'The heading and footer do not stick as the page scrolls and there is no specific height given to the grid.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072905368485560808)
,p_plugin_attribute_id=>wwv_flow_api.id(19072903299615551362)
,p_display_sequence=>20
,p_display_value=>'Region'
,p_return_value=>'REGION'
,p_help_text=>'The heading and footer do not stick as the page scrolls. The grid is given a specific height and the rows will scroll within the grid.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(19072907537271573678)
,p_plugin_attribute_id=>wwv_flow_api.id(19072903299615551362)
,p_display_sequence=>30
,p_display_value=>'Page'
,p_return_value=>'PAGE'
,p_help_text=>'The heading and footer stick as the page scrolls.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(19072908765523581739)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>200
,p_prompt=>'Grid Height'
,p_attribute_type=>'NUMBER'
,p_is_required=>false
,p_default_value=>'200'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(19072903299615551362)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'REGION'
,p_help_text=>'Specify the height of the grid widget. Only applies when the Heading Fixed To Region.'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(18862910739220342677)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'function(options) {',
'    options.persistSelection = true;',
'    options.modelOptions.pageSize = 200;    ',
'    return options;',
'}',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter a JavaScript function that takes a configuration options object for the Simple Grid region, modifies the object, and returns it. This allows advanced customization of the Simple Grid. The options are for the grid widget. See the JavaScript A'
||'PIs grid documentation for details.</p>',
'<p>Additional options include:</p>',
'<ul>',
'<li>regionId - The region id. Must not be modified.</li>',
'<li>regionStaticId - The region static id or id. Must not be modified.</li>',
'<li>ajaxIdentifier - The ajax identifier for this plugin. Must not be modified.</li>',
'<li>modelOptions - An object with additional options to be given to the apex.model.create function.</li>',
'<li>persistColumnState - Set from the Persist Column State attribute.</li>',
'<li>lazyLoad - Set from the Lazy Load attribute.</li>',
'<li>persistColumnStatePrefix - Only applicable when the columns change dynamically and the column state is persisted.</li>',
'<li>gridHeight - Set from the Grid Height attribute.</li>',
'</ul>',
'<p>Most of the options are set based on declarative attributes.</p>'))
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(18862910325293342676)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_name=>'SOURCE_LOCATION'
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'select empno,',
'       ename,',
'       job,',
'       sal',
'  from emp',
' where deptno = :P1_DEPTNO',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Specify the source of data for the Simple Grid.</p>',
'<p>Remember to include any page items used in the SQL query or Where Clause in the Page Items to Submit attribute.</p>',
'<p>When the Source Type is PL/SQL Function Body returning SQL Query the columns returned by the function can always be the same or can be different depending on page item values.',
'The columns in the returned SQL Query at design time become column child nodes and you can configure each column. ',
'If the columns can be different from one request to the next then see the Column Mapping attribute for how the run time columns map onto the design time columns.</p>'))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19058985763098730737)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_name=>'gridactivatecell'
,p_display_name=>'Activate Cell'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19058985318276730735)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_name=>'gridpagechange'
,p_display_name=>'Page Change'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(19058985071057730735)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_name=>'gridselectionchange'
,p_display_name=>'Selection Change'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0D0A202A2053696D706C652047726964204150455820726567696F6E20706C7567696E20666F722067726964207769646765740D0A202A2F0D0A2F2A676C6F62616C2077696E646F772C617065782A2F0D0A282066756E6374696F6E28207574696C';
wwv_flow_api.g_varchar2_table(2) := '2C207769646765745574696C2C20726567696F6E2C20242029207B0D0A202020202275736520737472696374223B0D0A0D0A2020202077696E646F772E73696D706C6547726964526567696F6E496E6974203D2066756E6374696F6E286F7074696F6E73';
wwv_flow_api.g_varchar2_table(3) := '29207B0D0A2020202020202020766172206D6F64656C2C2067726964242C2073697A6572242C20636F6C756D6E4D656E75242C20646174612C206D6F726544617461202F2A20696E74656E74696F6E616C6C7920756E646566696E6564202A2F2C0D0A20';
wwv_flow_api.g_varchar2_table(4) := '202020202020202020202073746F72616765203D206E756C6C2C0D0A20202020202020202020202076616C756573203D206E756C6C2C0D0A202020202020202020202020746F74616C203D206E756C6C2C0D0A2020202020202020202020206375727265';
wwv_flow_api.g_varchar2_table(5) := '6E7446696C74657273203D206E756C6C2C0D0A202020202020202020202020637572436F6C756D6E4D656E75436F6E74657874203D206E756C6C2C0D0A202020202020202020202020726571756573744368616E6765436F6C756D6E73203D2066616C73';
wwv_flow_api.g_varchar2_table(6) := '653B0D0A0D0A2020202020202020617065782E64656275672E696E666F2822496E69742073696D706C65206772696420726567696F6E3A20222C206F7074696F6E7320293B0D0A0D0A202020202020202066756E6374696F6E206372656174654D6F6465';
wwv_flow_api.g_varchar2_table(7) := '6C2829207B0D0A20202020202020202020202076617220662C0D0A202020202020202020202020202020206669656C6473203D206F7074696F6E732E636F6C756D6E735B305D2C0D0A2020202020202020202020202020202069644669656C6473203D20';
wwv_flow_api.g_varchar2_table(8) := '5B5D3B0D0A0D0A202020202020202020202020666F722028206620696E206669656C64732029207B0D0A2020202020202020202020202020202069662028206669656C64732E6861734F776E50726F70657274792866292029207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(9) := '2020202020202020202020202069662028206669656C64735B665D2E706B2029207B0D0A20202020202020202020202020202020202020202020202069644669656C64732E707573682866293B0D0A20202020202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(10) := '0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A202020202020202020202020696620282069644669656C64732E6C656E677468203D3D3D20302029207B0D0A2020202020202020202020202020202069644669';
wwv_flow_api.g_varchar2_table(11) := '656C6473203D206E756C6C3B0D0A2020202020202020202020207D0D0A2020202020202020202020206D6F64656C203D20617065782E6D6F64656C2E63726561746528206F7074696F6E732E6D6F64656C4E616D652C20242E657874656E6428207B7D2C';
wwv_flow_api.g_varchar2_table(12) := '206F7074696F6E732E6D6F64656C4F7074696F6E732C207B0D0A2020202020202020202020202020202073686170653A20227461626C65222C0D0A202020202020202020202020202020207265636F7264497341727261793A20747275652C0D0A202020';
wwv_flow_api.g_varchar2_table(13) := '202020202020202020202020206964656E746974794669656C643A2069644669656C64732C0D0A202020202020202020202020202020206669656C64733A206F7074696F6E732E636F6C756D6E735B305D2C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(14) := '706167696E6174696F6E547970653A202270726F6772657373697665222C0D0A20202020202020202020202020202020726567696F6E49643A206F7074696F6E732E726567696F6E49642C0D0A20202020202020202020202020202020616A6178496465';
wwv_flow_api.g_varchar2_table(15) := '6E7469666965723A206F7074696F6E732E616A61784964656E7469666965722C0D0A20202020202020202020202020202020706167654974656D73546F5375626D69743A206F7074696F6E732E6974656D73546F5375626D69742C0D0A20202020202020';
wwv_flow_api.g_varchar2_table(16) := '2020202020202020202F2F204E65697468657220746865206D6F64656C206F72207468652076696577206578706563747320746865206669656C642F636F6C756D6E20636F6E66696775726174696F6E20746F206368616E676520627574207468617420';
wwv_flow_api.g_varchar2_table(17) := '697320736F6D657468696E670D0A202020202020202020202020202020202F2F207468697320726567696F6E20737570706F7274732E0D0A202020202020202020202020202020202F2F205573696E67207468697320756E646F63756D656E746564206F';
wwv_flow_api.g_varchar2_table(18) := '7074696F6E20746F20616C6C6F772067657474696E67206E657720636F6C756D6E732066726F6D2074686520736572766572206174207468652073616D652074696D652061732067657474696E67206E657720646174610D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(19) := '20202020202F2F2054686973206973206E6F74207768617420697420697320696E74656E64656420666F722062757420756E74696C2074686572652069732061206265747465722077617920666F7220766965777320746F20686F6F6B20696E746F2074';
wwv_flow_api.g_varchar2_table(20) := '68650D0A202020202020202020202020202020202F2F206D6F64656C20726571756573747320746869732077696C6C206861766520746F20646F2E20576F756C64206E6F74206265206E65656465642069662077696C6C696E6720746F20686176652074';
wwv_flow_api.g_varchar2_table(21) := '776F207265717565737473207768656E2074686520636F6C756D6E73206368616E67652E0D0A202020202020202020202020202020202F2F2073656520636F6D6D656E746564206F757420636F646520696E206368616E6765436F6C756D6E730D0A2020';
wwv_flow_api.g_varchar2_table(22) := '202020202020202020202020202063616C6C5365727665723A2066756E6374696F6E28206D446174612C206D4F7074696F6E732029207B0D0A202020202020202020202020202020202020202076617220703B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(23) := '20202020206966202820726571756573744368616E6765436F6C756D6E732029207B0D0A2020202020202020202020202020202020202020202020206D446174612E726567696F6E735B305D2E676574436F6C756D6E73203D20747275653B0D0A202020';
wwv_flow_api.g_varchar2_table(24) := '2020202020202020202020202020202020202020202F2F206D75737420636C65617220736F7274732062656361757365207468657920646F6E2774206170706C7920746F20746865206E657720636F6C756D6E730D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(25) := '2020202020202020202064656C657465206D446174612E726567696F6E735B305D2E6665746368446174612E736F7274733B0D0A20202020202020202020202020202020202020202020202064656C657465206D446174612E726567696F6E735B305D2E';
wwv_flow_api.g_varchar2_table(26) := '6665746368446174612E66696C746572733B0D0A2020202020202020202020202020202020202020202020202F2F20757365207375636365737320736F207765206765742061636365737320746F2074686520726573706F6E7365206461746120626566';
wwv_flow_api.g_varchar2_table(27) := '6F726520746865206D6F64656C20646F65733B20617373756D6573206D6F64656C20646F65736E27742075736520737563636573730D0A2020202020202020202020202020202020202020202020206D4F7074696F6E732E73756363657373203D206675';
wwv_flow_api.g_varchar2_table(28) := '6E6374696F6E28726573706F6E73654461746129207B0D0A202020202020202020202020202020202020202020202020202020207661722066657463686564203D20726573706F6E7365446174612E726567696F6E735B305D2E66657463686564446174';
wwv_flow_api.g_varchar2_table(29) := '612C0D0A2020202020202020202020202020202020202020202020202020202020202020636F6C756D6E73203D20726573706F6E7365446174612E726567696F6E735B305D2E636F6C756D6E733B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(30) := '20202020202020202F2F207361766520746865206461746120666F7220746865206372656174696F6E206F662061206E6577206D6F64656C0D0A2020202020202020202020202020202020202020202020202020202076616C756573203D206665746368';
wwv_flow_api.g_varchar2_table(31) := '65642E76616C7565733B0D0A202020202020202020202020202020202020202020202020202020206D6F726544617461203D20666574636865642E6D6F7265446174613B0D0A20202020202020202020202020202020202020202020202020202020746F';
wwv_flow_api.g_varchar2_table(32) := '74616C203D20666574636865642E746F74616C526F77733B0D0A202020202020202020202020202020202020202020202020202020202F2F206E6F77206C696520616E6420736179207468657265206973206E6F20646174612062656361757365206974';
wwv_flow_api.g_varchar2_table(33) := '20646F65736E27742066697420746865206F6C6420636F6C756D6E7320616E797761790D0A20202020202020202020202020202020202020202020202020202020666574636865642E76616C756573203D205B5D3B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(34) := '202020202020202020202020202020666574636865642E6D6F726544617461203D2066616C73653B0D0A2020202020202020202020202020202020202020202020202020202073657454696D656F75742866756E6374696F6E2829207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(35) := '2020202020202020202020202020202020202020202020202020202F2F2075706461746520636F6C756D6E206D6574616461746120666F7220757365206279206772696420616E64206E6577206D6F64656C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(36) := '202020202020202020202020202020206F7074696F6E732E636F6C756D6E735B305D203D20636F6C756D6E733B0D0A20202020202020202020202020202020202020202020202020202020202020206C6F6164436F6C756D6E537461746528636F6C756D';
wwv_flow_api.g_varchar2_table(37) := '6E73293B0D0A20202020202020202020202020202020202020202020202020202020202020206372656174654D6F64656C28293B202F2F206F766572777269746520646566696E6974696F6E206F66206578697374696E67206D6F64656C0D0A20202020';
wwv_flow_api.g_varchar2_table(38) := '202020202020202020202020202020202020202020202020202020202F2F2075706461746520677269642077697468206E657720636F6C756D6E206D657461646174610D0A20202020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(39) := '2067726964242E6772696428226F7074696F6E222C2022636F6C756D6E7322295B305D203D20636F6C756D6E733B0D0A20202020202020202020202020202020202020202020202020202020202020202F2F2074656C6C20746865206772696420746865';
wwv_flow_api.g_varchar2_table(40) := '20636F6C756D6E732068617665206368616E67656420616E642062792073657474696E6720746865206D6F64656C4E616D650D0A20202020202020202020202020202020202020202020202020202020202020202F2F2069742077696C6C207377697463';
wwv_flow_api.g_varchar2_table(41) := '6820746F2075736520746865206E6577206D6F64656C207468617420776173206A757374206372656174656420696E636C7564696E67207375627363726962696E6720746F206D6F64656C206E6F74696669636174696F6E730D0A202020202020202020';
wwv_flow_api.g_varchar2_table(42) := '20202020202020202020202020202020202020202020202F2F20616E6420616C736F206361757365732072656672657368696E67207468652067726964207769646765742E0D0A2020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(43) := '20202067726964242E67726964282272656672657368436F6C756D6E7322290D0A2020202020202020202020202020202020202020202020202020202020202020202020202E6772696428226F7074696F6E222C20226D6F64656C4E616D65222C206F70';
wwv_flow_api.g_varchar2_table(44) := '74696F6E732E6D6F64656C4E616D65293B0D0A202020202020202020202020202020202020202020202020202020207D2C2031293B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(45) := '20207D0D0A2020202020202020202020202020202020202020726571756573744368616E6765436F6C756D6E73203D2066616C73653B0D0A202020202020202020202020202020202020202070203D20617065782E7365727665722E706C7567696E2820';
wwv_flow_api.g_varchar2_table(46) := '6D446174612C206D4F7074696F6E7320293B0D0A202020202020202020202020202020202020202072657475726E20703B0D0A202020202020202020202020202020207D2C0D0A2020202020202020202020207D20292C2076616C7565732C20746F7461';
wwv_flow_api.g_varchar2_table(47) := '6C2C206D6F72654461746120293B0D0A2020202020202020202020202F2F20616674657220746865206D6F64656C206973206372656174656420646F6E2774207573652074686520696E697469616C206461746120616E79206D6F72650D0A2020202020';
wwv_flow_api.g_varchar2_table(48) := '20202020202020746F74616C203D2076616C756573203D206E756C6C3B0D0A2020202020202020202020206D6F726544617461203D20756E646566696E65643B0D0A20202020202020207D0D0A0D0A202020202020202066756E6374696F6E2075706461';
wwv_flow_api.g_varchar2_table(49) := '74654D6F64656C4665746368446174612829207B0D0A20202020202020202020202076617220702C20636F6C2C0D0A20202020202020202020202020202020636F6C4D6170203D206F7074696F6E732E636F6C756D6E735B305D2C0D0A20202020202020';
wwv_flow_api.g_varchar2_table(50) := '202020202020202020736F727473203D205B5D2C0D0A20202020202020202020202020202020666574636844617461203D206D6F64656C2E6765744F7074696F6E2820226665746368446174612220293B0D0A0D0A202020202020202020202020666574';
wwv_flow_api.g_varchar2_table(51) := '6368446174612E736F727473203D20736F7274733B0D0A202020202020202020202020666F722028207020696E20636F6C4D61702029207B0D0A202020202020202020202020202020206966202820636F6C4D61702E6861734F776E50726F7065727479';
wwv_flow_api.g_varchar2_table(52) := '28207020292029207B0D0A2020202020202020202020202020202020202020636F6C203D20636F6C4D61705B705D3B0D0A20202020202020202020202020202020202020206966202820636F6C2E736F7274446972656374696F6E2029207B0D0A202020';
wwv_flow_api.g_varchar2_table(53) := '202020202020202020202020202020202020202020736F7274732E7075736828207B0D0A20202020202020202020202020202020202020202020202020202020636F6C756D6E3A20702C0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(54) := '20202020646972656374696F6E3A20636F6C2E736F7274446972656374696F6E2E746F55707065724361736528292C0D0A20202020202020202020202020202020202020202020202020202020696E6465783A20636F6C2E736F7274496E6465780D0A20';
wwv_flow_api.g_varchar2_table(55) := '20202020202020202020202020202020202020202020207D20293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A2020202020202020202020206966';
wwv_flow_api.g_varchar2_table(56) := '20282063757272656E7446696C746572732026262063757272656E7446696C746572732E6C656E677468203E20302029207B0D0A202020202020202020202020202020206665746368446174612E66696C74657273203D2063757272656E7446696C7465';
wwv_flow_api.g_varchar2_table(57) := '72733B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020206665746368446174612E66696C74657273203D205B5D3B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(58) := '2020202066756E6374696F6E20726573697A6528696E697429207B0D0A2020202020202020202020207661722077203D2073697A6572242E776964746828292C0D0A2020202020202020202020202020202068203D2073697A6572242E68656967687428';
wwv_flow_api.g_varchar2_table(59) := '293B0D0A0D0A2020202020202020202020207574696C2E7365744F7574657257696474682867726964242C2077293B0D0A20202020202020202020202069662028206F7074696F6E732E68617353697A652029207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(60) := '2020207574696C2E7365744F757465724865696768742867726964242C2068293B0D0A2020202020202020202020207D0D0A2020202020202020202020206966202821696E697429207B0D0A2020202020202020202020202020202067726964242E6772';
wwv_flow_api.g_varchar2_table(61) := '6964282022726573697A652220293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A202020202020202066756E6374696F6E20676574436F6C756D6E53746174654B65792829207B0D0A202020202020202020202020726574';
wwv_flow_api.g_varchar2_table(62) := '75726E20286F7074696F6E732E70657273697374436F6C756D6E5374617465507265666978203F206F7074696F6E732E70657273697374436F6C756D6E5374617465507265666978202B20225F22203A20222229202B2022636F6C756D6E73223B0D0A20';
wwv_flow_api.g_varchar2_table(63) := '202020202020207D0D0A0D0A202020202020202066756E6374696F6E2070657273697374436F6C756D6E537461746528636F6C756D6E7329207B0D0A20202020202020202020202076617220692C20632C0D0A2020202020202020202020202020202063';
wwv_flow_api.g_varchar2_table(64) := '6F6C73203D205B5D3B0D0A0D0A20202020202020202020202069662028202173746F726167652029207B0D0A2020202020202020202020202020202072657475726E3B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020666F';
wwv_flow_api.g_varchar2_table(65) := '72202869203D20303B2069203C20636F6C756D6E732E6C656E6774683B20692B2B29207B0D0A2020202020202020202020202020202063203D20636F6C756D6E735B695D3B0D0A20202020202020202020202020202020636F6C732E70757368287B0D0A';
wwv_flow_api.g_varchar2_table(66) := '20202020202020202020202020202020202020206E616D653A20632E70726F70657274792C0D0A202020202020202020202020202020202020202077696474683A20632E77696474682C0D0A20202020202020202020202020202020202020207365713A';
wwv_flow_api.g_varchar2_table(67) := '20632E7365712C0D0A202020202020202020202020202020202020202066726F7A656E3A20632E66726F7A656E2C0D0A202020202020202020202020202020202020202068696464656E3A20632E68696464656E0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(68) := '20207D293B0D0A2020202020202020202020207D0D0A20202020202020202020202073746F726167652E7365744974656D2820676574436F6C756D6E53746174654B657928292C204A534F4E2E737472696E6769667928636F6C732920293B0D0A202020';
wwv_flow_api.g_varchar2_table(69) := '20202020207D0D0A0D0A202020202020202066756E6374696F6E206C6F6164436F6C756D6E537461746528636F6C756D6E7329207B0D0A20202020202020202020202076617220692C20632C20646573745F636F6C2C20636F6C733B0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(70) := '202020202020202069662028202173746F726167652029207B0D0A2020202020202020202020202020202072657475726E3B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020636F6C73203D2073746F726167652E67657449';
wwv_flow_api.g_varchar2_table(71) := '74656D2820676574436F6C756D6E53746174654B6579282920293B0D0A2020202020202020202020206966202820636F6C732029207B0D0A20202020202020202020202020202020747279207B0D0A202020202020202020202020202020202020202063';
wwv_flow_api.g_varchar2_table(72) := '6F6C73203D204A534F4E2E70617273652820636F6C7320293B0D0A2020202020202020202020202020202020202020666F7220282069203D20303B2069203C20636F6C732E6C656E6774683B20692B2B2029207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '2020202020202020202063203D20636F6C735B695D3B0D0A202020202020202020202020202020202020202020202020646573745F636F6C203D20636F6C756D6E735B632E6E616D655D3B0D0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(74) := '206966202820646573745F636F6C2029207B0D0A202020202020202020202020202020202020202020202020202020206966202820632E73657120262620747970656F6620632E736571203D3D3D20226E756D626572222029207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(75) := '20202020202020202020202020202020202020202020202020646573745F636F6C2E736571203D20632E7365713B0D0A202020202020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(76) := '202020202020206966202820632E776964746820262620747970656F6620632E7769647468203D3D3D20226E756D6265722220262620632E7769647468203E2032302029207B0D0A20202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(77) := '20202020646573745F636F6C2E7769647468203D20632E77696474680D0A202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020202020202069662028202820632E6869';
wwv_flow_api.g_varchar2_table(78) := '6464656E203D3D3D2074727565207C7C20632E68696464656E203D3D3D2066616C7365202920262620646573745F636F6C2E63616E486964652029207B0D0A2020202020202020202020202020202020202020202020202020202020202020646573745F';
wwv_flow_api.g_varchar2_table(79) := '636F6C2E68696464656E203D20632E68696464656E3B0D0A202020202020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020202020206966202820632E66726F7A656E203D3D3D';
wwv_flow_api.g_varchar2_table(80) := '2074727565207C7C20632E66726F7A656E203D3D3D2066616C73652029207B0D0A2020202020202020202020202020202020202020202020202020202020202020646573745F636F6C2E66726F7A656E203D20632E66726F7A656E3B0D0A202020202020';
wwv_flow_api.g_varchar2_table(81) := '202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D2063617463682028';
wwv_flow_api.g_varchar2_table(82) := '20652029207B0D0A2020202020202020202020202020202020202020617065782E64656275672E7761726E2820224661696C656420746F206C6F616420636F6C756D6E732066726F6D2073657373696F6E2073746F726167652E222C20652E746F537472';
wwv_flow_api.g_varchar2_table(83) := '696E67282920293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020202020696620286F7074696F6E732E70657273697374436F6C756D6E537461746529207B0D0A';
wwv_flow_api.g_varchar2_table(84) := '20202020202020202020202073746F72616765203D20617065782E73746F726167652E67657453636F70656453657373696F6E53746F72616765287B0D0A202020202020202020202020202020207072656669783A20225347222C0D0A20202020202020';
wwv_flow_api.g_varchar2_table(85) := '2020202020202020207573655061676549643A20747275652C0D0A20202020202020202020202020202020726567696F6E49643A206F7074696F6E732E726567696F6E49640D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A0D';
wwv_flow_api.g_varchar2_table(86) := '0A202020202020202069662028216F7074696F6E732E6C617A794C6F616429207B0D0A20202020202020202020202064617461203D2077696E646F775B22675347646174615F22202B206F7074696F6E732E726567696F6E49645D3B0D0A202020202020';
wwv_flow_api.g_varchar2_table(87) := '20202020202076616C756573203D20646174612E76616C7565733B0D0A2020202020202020202020206966202820646174612E746F74616C526F77732029207B0D0A20202020202020202020202020202020746F74616C203D20646174612E746F74616C';
wwv_flow_api.g_varchar2_table(88) := '526F77733B0D0A2020202020202020202020207D0D0A2020202020202020202020206D6F726544617461203D20646174612E6D6F7265446174613B0D0A20202020202020207D0D0A0D0A20202020202020206372656174654D6F64656C28293B0D0A0D0A';
wwv_flow_api.g_varchar2_table(89) := '20202020202020207570646174654D6F64656C46657463684461746128293B0D0A0D0A20202020202020202F2F20636F6C756D6E206D656E750D0A2020202020202020636F6C756D6E4D656E7524203D20242820223C6469762069643D2722202B20206F';
wwv_flow_api.g_varchar2_table(90) := '7074696F6E732E726567696F6E5374617469634964202B20225F636F6C5F6D656E7522202B202227207374796C653D27646973706C61793A6E6F6E653B273E3C2F6469763E2220293B0D0A202020202020202024282022626F64792220292E617070656E';
wwv_flow_api.g_varchar2_table(91) := '642820636F6C756D6E4D656E752420293B0D0A2020202020202020636F6C756D6E4D656E75242E6D656E7528207B0D0A2020202020202020202020206974656D733A205B0D0A202020202020202020202020202020207B20747970653A2022746F67676C';
wwv_flow_api.g_varchar2_table(92) := '65222C206F6E4C6162656C3A2022556E667265657A65222C206F66664C6162656C3A2022467265657A65222C206765743A2066756E6374696F6E202829207B202F2F206931386E0D0A202020202020202020202020202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(93) := '637572436F6C756D6E4D656E75436F6E746578742E636F6C756D6E2E66726F7A656E3B0D0A202020202020202020202020202020207D2C207365743A2066756E6374696F6E202820762029207B0D0A202020202020202020202020202020202020202067';
wwv_flow_api.g_varchar2_table(94) := '726964242E677269642876203F2022667265657A65436F6C756D6E22203A2022756E667265657A65436F6C756D6E222C20637572436F6C756D6E4D656E75436F6E746578742E636F6C756D6E20293B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(95) := '2070657273697374436F6C756D6E53746174652867726964242E677269642822676574436F6C756D6E732229293B0D0A202020202020202020202020202020207D0D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(96) := '2020207B20747970653A2022736570617261746F7222207D2C0D0A202020202020202020202020202020207B20747970653A2022616374696F6E222C206C6162656C3A202248696465222C2064697361626C65643A2066756E6374696F6E2829207B0D0A';
wwv_flow_api.g_varchar2_table(97) := '202020202020202020202020202020202020202072657475726E2021637572436F6C756D6E4D656E75436F6E746578742E636F6C756D6E2E63616E486964653B0D0A202020202020202020202020202020207D2C20616374696F6E3A2066756E6374696F';
wwv_flow_api.g_varchar2_table(98) := '6E2829207B0D0A202020202020202020202020202020202020202067726964242E67726964282268696465436F6C756D6E222C20637572436F6C756D6E4D656E75436F6E746578742E636F6C756D6E20293B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(99) := '2020202070657273697374436F6C756D6E53746174652867726964242E677269642822676574436F6C756D6E732229293B0D0A202020202020202020202020202020207D0D0A202020202020202020202020202020207D2C0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(100) := '2020202020207B2069643A202273686F77222C20747970653A20227375624D656E75222C2064697361626C65643A20747275652C206C6162656C3A202253686F77222C206D656E753A207B206974656D733A205B205D7D0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(101) := '20202020207D0D0A2020202020202020202020205D2C0D0A2020202020202020202020206265666F72654F70656E3A2066756E6374696F6E286D656E7529207B0D0A2020202020202020202020202020202076617220692C20636F6C2C2073686F774D65';
wwv_flow_api.g_varchar2_table(102) := '6E752C0D0A202020202020202020202020202020202020202073686F77436F6C756D6E73203D205B5D2C0D0A2020202020202020202020202020202020202020636F6C756D6E73203D2067726964242E677269642822676574436F6C756D6E7322293B0D';
wwv_flow_api.g_varchar2_table(103) := '0A0D0A2020202020202020202020202020202066756E6374696F6E2073686F77436F6C756D6E2829207B0D0A202020202020202020202020202020202020202067726964242E67726964282273686F77436F6C756D6E222C20746869732E636F6C4E616D';
wwv_flow_api.g_varchar2_table(104) := '6520293B0D0A202020202020202020202020202020202020202070657273697374436F6C756D6E53746174652867726964242E677269642822676574436F6C756D6E732229293B0D0A202020202020202020202020202020207D0D0A0D0A202020202020';
wwv_flow_api.g_varchar2_table(105) := '20202020202020202020666F72202869203D20303B2069203C20636F6C756D6E732E6C656E6774683B20692B2B29207B0D0A2020202020202020202020202020202020202020636F6C203D20636F6C756D6E735B695D3B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(106) := '2020202020202020206966202820636F6C2E63616E4869646520262620636F6C2E68696464656E2029207B0D0A20202020202020202020202020202020202020202020202073686F77436F6C756D6E732E707573682820636F6C20293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(107) := '2020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020202020202073686F774D656E75203D20636F6C756D6E4D656E75242E6D656E7528202266696E64222C202273686F77222029';
wwv_flow_api.g_varchar2_table(108) := '3B0D0A2020202020202020202020202020202073686F774D656E752E64697361626C6564203D20747275653B0D0A2020202020202020202020202020202073686F774D656E752E6D656E752E6974656D73203D205B5D3B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(109) := '2020202020696620282073686F77436F6C756D6E732E6C656E6774682029207B0D0A202020202020202020202020202020202020202073686F774D656E752E64697361626C6564203D2066616C73653B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(110) := '202073686F77436F6C756D6E732E736F72742866756E6374696F6E28612C6229207B0D0A20202020202020202020202020202020202020202020202072657475726E20612E736571202D20622E7365713B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(111) := '2020207D293B0D0A2020202020202020202020202020202020202020666F72202869203D20303B2069203C2073686F77436F6C756D6E732E6C656E6774683B20692B2B2029207B0D0A202020202020202020202020202020202020202020202020636F6C';
wwv_flow_api.g_varchar2_table(112) := '203D2073686F77436F6C756D6E735B695D3B0D0A20202020202020202020202020202020202020202020202073686F774D656E752E6D656E752E6974656D732E70757368287B0D0A20202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(113) := '747970653A2022616374696F6E222C0D0A202020202020202020202020202020202020202020202020202020206C6162656C3A20636F6C2E6C6162656C207C7C20636F6C2E68656164696E672C0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(114) := '20202020202020636F6C4E616D653A20636F6C2E70726F70657274792C0D0A20202020202020202020202020202020202020202020202020202020616374696F6E3A2073686F77436F6C756D6E0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(115) := '2020207D293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A20202020202020207D293B0D0A0D0A20202020202020206966202820216F7074696F6E';
wwv_flow_api.g_varchar2_table(116) := '732E6163746976617465436F6C756D6E48656164657220262620216F7074696F6E732E63616E63656C436F6C756D6E4865616465722029207B0D0A2020202020202020202020206F7074696F6E732E6163746976617465436F6C756D6E48656164657220';
wwv_flow_api.g_varchar2_table(117) := '3D2066756E6374696F6E28206576656E742C2075692029207B0D0A202020202020202020202020202020202F2F20746F646F2066696E642061206265747465722077617920746F2073686172652074686520636F6C756D6E20696E666F20776974682074';
wwv_flow_api.g_varchar2_table(118) := '6865206D656E7520616374696F6E730D0A20202020202020202020202020202020637572436F6C756D6E4D656E75436F6E74657874203D2075693B0D0A2020202020202020202020202020202075692E686561646572242E616464436C61737328226973';
wwv_flow_api.g_varchar2_table(119) := '2D61637469766522290D0A20202020202020202020202020202020202020202E617474722822617269612D657870616E646564222C20227472756522293B0D0A20202020202020202020202020202020636F6C756D6E4D656E75242E6D656E7528202274';
wwv_flow_api.g_varchar2_table(120) := '6F67676C65222C2075692E686561646572242C2066616C736520292E6F6E2820226D656E756166746572636C6F73652E6D656E75627574746F6E222C2066756E6374696F6E28206576656E742C20726573756C742029207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(121) := '202020202020202020202428207468697320292E6F66662820222E6D656E75627574746F6E2220293B0D0A202020202020202020202020202020202020202075692E686561646572242E72656D6F7665436C61737328202269732D616374697665222029';
wwv_flow_api.g_varchar2_table(122) := '0D0A2020202020202020202020202020202020202020202020202E61747472282022617269612D657870616E646564222C202266616C73652220293B0D0A202020202020202020202020202020207D20292E66696E64282022612C20627574746F6E2C20';
wwv_flow_api.g_varchar2_table(123) := '2E612D4D656E752D6C6162656C2220292E666972737428292E666F63757328293B0D0A2020202020202020202020207D3B0D0A2020202020202020202020206F7074696F6E732E63616E63656C436F6C756D6E486561646572203D2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(124) := '28206576656E742C2075692029207B0D0A202020202020202020202020202020206966202820636F6C756D6E4D656E75242E697328223A76697369626C6522292029207B0D0A2020202020202020202020202020202020202020636F6C756D6E4D656E75';
wwv_flow_api.g_varchar2_table(125) := '242E6D656E752822746F67676C6522293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D3B0D0A20202020202020207D0D0A0D0A20202020202020206F7074696F6E732E736F72744368616E6765203D206F707469';
wwv_flow_api.g_varchar2_table(126) := '6F6E732E736F72744368616E6765207C7C2066756E6374696F6E28206576656E742C2075692029207B0D0A20202020202020202020202076617220692C20636F6C2C20696E6465782C0D0A202020202020202020202020202020206F726967696E616C49';
wwv_flow_api.g_varchar2_table(127) := '6E646578203D2075692E636F6C756D6E2E736F7274496E6465782C0D0A20202020202020202020202020202020636F6C756D6E73203D2067726964242E677269642822676574436F6C756D6E7322293B0D0A0D0A202020202020202020202020696E6465';
wwv_flow_api.g_varchar2_table(128) := '78203D20313B0D0A202020202020202020202020666F72202869203D20303B2069203C20636F6C756D6E732E6C656E6774683B20692B2B29207B0D0A20202020202020202020202020202020636F6C203D20636F6C756D6E735B695D3B0D0A2020202020';
wwv_flow_api.g_varchar2_table(129) := '20202020202020202020206966202820636F6C2E736F7274496E6465782029207B0D0A2020202020202020202020202020202020202020696620282075692E616374696F6E203D3D3D20226368616E6765222029207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(130) := '2020202020202020202020206966202820636F6C203D3D3D2075692E636F6C756D6E2029207B0D0A20202020202020202020202020202020202020202020202020202020696E646578203D20636F6C2E736F7274496E6465783B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(131) := '202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D20656C736520696620282075692E616374696F6E203D3D3D2022616464222029207B0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(132) := '6966202820636F6C2E736F7274496E646578203E3D20696E6465782029207B0D0A20202020202020202020202020202020202020202020202020202020696E646578203D20636F6C2E736F7274496E646578202B20313B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(133) := '202020202020202020202020207D0D0A20202020202020202020202020202020202020207D20656C736520696620282075692E616374696F6E203D3D3D202272656D6F7665222029207B0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(134) := '6966202820636F6C203D3D3D2075692E636F6C756D6E2029207B0D0A2020202020202020202020202020202020202020202020202020202064656C65746520636F6C2E736F7274496E6465783B0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(135) := '2020202020202064656C65746520636F6C2E736F7274446972656374696F6E3B0D0A2020202020202020202020202020202020202020202020207D20656C7365206966202820636F6C2E736F7274496E646578203E206F726967696E616C496E64657829';
wwv_flow_api.g_varchar2_table(136) := '207B0D0A20202020202020202020202020202020202020202020202020202020636F6C2E736F7274496E646578202D3D20313B0D0A2020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(137) := '7D20656C736520696620282075692E616374696F6E203D3D3D2022636C65617222207C7C2075692E616374696F6E203D3D3D2022736574222029207B0D0A20202020202020202020202020202020202020202020202064656C65746520636F6C2E736F72';
wwv_flow_api.g_varchar2_table(138) := '74496E6465783B0D0A20202020202020202020202020202020202020202020202064656C65746520636F6C2E736F7274446972656374696F6E3B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(139) := '0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020696620282075692E616374696F6E20213D3D2022636C656172222026262075692E616374696F6E20213D3D202272656D6F7665222029207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(140) := '202020202075692E636F6C756D6E2E736F7274496E646578203D20696E6465783B0D0A2020202020202020202020202020202075692E636F6C756D6E2E736F7274446972656374696F6E203D2075692E646972656374696F6E3B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(141) := '202020207D0D0A20202020202020202020202067726964242E67726964282272656672657368436F6C756D6E7322293B0D0A2020202020202020202020207570646174654D6F64656C46657463684461746128293B0D0A2020202020202020202020206D';
wwv_flow_api.g_varchar2_table(142) := '6F64656C2E636C6561724461746128293B0D0A20202020202020207D2C0D0A20202020202020206F7074696F6E732E636F6C756D6E52656F72646572203D206F7074696F6E732E636F6C756D6E52656F72646572207C7C2066756E6374696F6E28206576';
wwv_flow_api.g_varchar2_table(143) := '656E742C2075692029207B0D0A20202020202020202020202070657273697374436F6C756D6E53746174652867726964242E677269642822676574436F6C756D6E732229293B0D0A20202020202020207D3B0D0A20202020202020206F7074696F6E732E';
wwv_flow_api.g_varchar2_table(144) := '636F6C756D6E526573697A65203D206F7074696F6E732E636F6C756D6E526573697A65207C7C2066756E6374696F6E28206576656E742C2075692029207B0D0A20202020202020202020202070657273697374436F6C756D6E5374617465286772696424';
wwv_flow_api.g_varchar2_table(145) := '2E677269642822676574436F6C756D6E732229293B0D0A20202020202020207D3B0D0A0D0A20202020202020206772696424203D20242820222322202B206F7074696F6E732E726567696F6E5374617469634964202B20225F672220293B0D0A20202020';
wwv_flow_api.g_varchar2_table(146) := '2020202073697A657224203D2067726964242E706172656E7428293B0D0A202020202020202073697A6572242E63737328226F766572666C6F77222C202268696464656E22293B0D0A2020202020202020696620286F7074696F6E732E68617353697A65';
wwv_flow_api.g_varchar2_table(147) := '29207B0D0A20202020202020202020202073697A6572242E637373282022686569676874222C206F7074696F6E732E67726964486569676874207C7C2032303020293B0D0A20202020202020207D0D0A2020202020202020726573697A65287472756529';
wwv_flow_api.g_varchar2_table(148) := '3B202F2F206265666F726520677269642077696467657420697320637265617465640D0A20202020202020206C6F6164436F6C756D6E5374617465286F7074696F6E732E636F6C756D6E735B305D293B0D0A202020202020202067726964242E67726964';
wwv_flow_api.g_varchar2_table(149) := '28206F7074696F6E7320293B0D0A0D0A20202020202020202F2F20546869732069732063757272656E746C7920756E646F63756D656E746564206275742069742064657465637473207768656E20616E20656C656D656E7427732073697A65206368616E';
wwv_flow_api.g_varchar2_table(150) := '6765732E204947207573657320746869732E0D0A20202020202020207769646765745574696C2E6F6E456C656D656E74526573697A65282067726964242E706172656E7428295B305D2C2066756E6374696F6E2829207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(151) := '20726573697A6528293B0D0A20202020202020207D20293B0D0A0D0A20202020202020202F2F20546869732069732063757272656E746C7920756E646F63756D656E746564206275742049206861766520626C6F676765642061626F75742069742E0D0A';
wwv_flow_api.g_varchar2_table(152) := '20202020202020207769646765745574696C2E6F6E5669736962696C6974794368616E6765282067726964245B305D2C2066756E6374696F6E2873686F7729207B0D0A202020202020202020202020696620282073686F772029207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(153) := '202020202020202020207769646765745574696C2E757064617465526573697A6553656E736F7273282073697A6572245B305D20293B0D0A20202020202020202020202020202020726573697A6528293B0D0A2020202020202020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(154) := '2020202020207D20293B0D0A0D0A2020202020202020617065782E726567696F6E2E63726561746528206F7074696F6E732E726567696F6E53746174696349642C207B0D0A202020202020202020202020747970653A202267726964222C0D0A20202020';
wwv_flow_api.g_varchar2_table(155) := '20202020202020207769646765744E616D653A202267726964222C0D0A202020202020202020202020666F6375733A2066756E6374696F6E2829207B0D0A2020202020202020202020202020202067726964242E677269642822666F63757322293B0D0A';
wwv_flow_api.g_varchar2_table(156) := '2020202020202020202020207D2C0D0A202020202020202020202020726566726573683A2066756E6374696F6E2829207B0D0A202020202020202020202020202020206D6F64656C2E636C6561724461746128293B0D0A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(157) := '2C0D0A2020202020202020202020207769646765743A2066756E6374696F6E2829207B0D0A2020202020202020202020202020202072657475726E2067726964243B0D0A2020202020202020202020207D2C0D0A202020202020202020202020616C7465';
wwv_flow_api.g_varchar2_table(158) := '726E6174654C6F6164696E67496E64696361746F723A2066756E6374696F6E2820656C656D656E742C206C6F6164696E67496E64696361746F72242029207B0D0A202020202020202020202020202020207661722063656C6C24203D2067726964242E67';
wwv_flow_api.g_varchar2_table(159) := '72696428202267657441637469766543656C6C46726F6D436F6C756D6E4974656D222C20656C656D656E7420293B0D0A20202020202020202020202020202020696620282063656C6C242029207B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(160) := '72657475726E207574696C2E73686F775370696E6E6572282063656C6C242C207B0D0A2020202020202020202020202020202020202020202020207370696E6E6572436C6173733A2022752D50726F63657373696E672D2D63656C6C5265667265736822';
wwv_flow_api.g_varchar2_table(161) := '0D0A20202020202020202020202020202020202020207D293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D2C0D0A2020202020202020202020202F2F206578747261206D6574686F64730D0A2020202020202020';
wwv_flow_api.g_varchar2_table(162) := '202020206765744D6F64656C3A2066756E6374696F6E2829207B0D0A2020202020202020202020202020202072657475726E206D6F64656C3B0D0A2020202020202020202020207D2C0D0A2020202020202020202020202F2A2A0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(163) := '20202020202A20416E206172726179206F662066696C746572206F626A656374732E0D0A202020202020202020202020202A2040706172616D2041727261792066696C746572730D0A202020202020202020202020202A2040706172616D20737472696E';
wwv_flow_api.g_varchar2_table(164) := '672066696C746572732E636F6C756D6E0D0A202020202020202020202020202A2040706172616D20696E74656765722066696C746572732E747970650D0A202020202020202020202020202A2040706172616D20737472696E672066696C746572732E76';
wwv_flow_api.g_varchar2_table(165) := '616C75650D0A202020202020202020202020202A2040706172616D20737472696E672066696C746572732E66726F6D56616C75650D0A202020202020202020202020202A2040706172616D20737472696E672066696C746572732E746F56616C75650D0A';
wwv_flow_api.g_varchar2_table(166) := '202020202020202020202020202A2040706172616D20737472696E672066696C746572732E76616C7565730D0A202020202020202020202020202A2F0D0A20202020202020202020202073657446696C746572733A2066756E6374696F6E2866696C7465';
wwv_flow_api.g_varchar2_table(167) := '727329207B0D0A2020202020202020202020202020202063757272656E7446696C74657273203D2066696C746572733B0D0A202020202020202020202020202020207570646174654D6F64656C46657463684461746128293B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(168) := '202020202020206D6F64656C2E636C6561724461746128293B0D0A2020202020202020202020207D2C0D0A20202020202020202020202067657446696C746572733A2066756E6374696F6E2829207B0D0A20202020202020202020202020202020726574';
wwv_flow_api.g_varchar2_table(169) := '75726E2063757272656E7446696C746572733B0D0A2020202020202020202020207D2C0D0A2020202020202020202020206368616E6765436F6C756D6E733A2066756E6374696F6E2870657273697374436F6C756D6E537461746550726566697829207B';
wwv_flow_api.g_varchar2_table(170) := '0D0A202020202020202020202020202020202F2F2072657175657374206E657720636F6C756D6E7320616E642064617461206F6E6C79206966207468652070726566697820686173206368616E6765640D0A202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(171) := '20282070657273697374436F6C756D6E537461746550726566697820213D3D206F7074696F6E732E70657273697374436F6C756D6E53746174655072656669782029207B0D0A202020202020202020202020202020202020202072657175657374436861';
wwv_flow_api.g_varchar2_table(172) := '6E6765436F6C756D6E73203D20747275653B0D0A20202020202020202020202020202020202020206F7074696F6E732E70657273697374436F6C756D6E5374617465507265666978203D2070657273697374436F6C756D6E53746174655072656669783B';
wwv_flow_api.g_varchar2_table(173) := '0D0A20202020202020202020202020202020202020206D6F64656C2E636C6561724461746128293B0D0A202020202020202020202020202020207D0D0A2F2A207468652074776F2072657175657374207761790D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(174) := '2076617220703B0D0A202020202020202020202020202020202F2F20746F646F206D616B6520757365206F66206B65790D0A202020202020202020202020202020202F2F206572726F7220696620746869732068617070656E73207768696C6520612072';
wwv_flow_api.g_varchar2_table(175) := '65667265736820697320616C736F2068617070656E696E672E0D0A202020202020202020202020202020202F2F20206E6565642067756172642C0D0A202020202020202020202020202020202F2F20746F646F2073686F756C6420616C736F206465626F';
wwv_flow_api.g_varchar2_table(176) := '756E6365206368616E6765206576656E7473207468617420647269766520746869730D0A2020202020202020202020202020202070203D20617065782E7365727665722E706C7567696E287B0D0A20202020202020202020202020202020202020207265';
wwv_flow_api.g_varchar2_table(177) := '67696F6E733A205B207B0D0A20202020202020202020202020202020202020202020202069643A206F7074696F6E732E726567696F6E53746174696349642C0D0A202020202020202020202020202020202020202020202020616A61784964656E746966';
wwv_flow_api.g_varchar2_table(178) := '6965723A206F7074696F6E732E616A61784964656E7469666965722C0D0A202020202020202020202020202020202020202020202020676574436F6C756D6E733A20747275650D0A20202020202020202020202020202020202020207D5D2C0D0A202020';
wwv_flow_api.g_varchar2_table(179) := '2020202020202020202020202020202020706167654974656D733A206F7074696F6E732E6974656D73546F5375626D69740D0A202020202020202020202020202020207D2C207B0D0A202020202020202020202020202020202020202064617461547970';
wwv_flow_api.g_varchar2_table(180) := '653A20226A736F6E220D0A202020202020202020202020202020207D20293B0D0A20202020202020202020202020202020702E646F6E652866756E6374696F6E286461746129207B0D0A20202020202020202020202020202020202020206F7074696F6E';
wwv_flow_api.g_varchar2_table(181) := '732E636F6C756D6E735B305D203D20646174612E726567696F6E735B305D2E636F6C756D6E733B0D0A20202020202020202020202020202020202020206372656174654D6F64656C28293B202F2F206F766572777269746520646566696E6974696F6E20';
wwv_flow_api.g_varchar2_table(182) := '6F66206578697374696E67206D6F64656C0D0A202020202020202020202020202020202020202067726964242E6772696428226F7074696F6E222C2022636F6C756D6E7322295B305D203D20646174612E726567696F6E735B305D2E636F6C756D6E733B';
wwv_flow_api.g_varchar2_table(183) := '0D0A202020202020202020202020202020202020202067726964242E67726964282272656672657368436F6C756D6E7322290D0A2020202020202020202020202020202020202020202020202E6772696428226F7074696F6E222C20226D6F64656C4E61';
wwv_flow_api.g_varchar2_table(184) := '6D65222C206F7074696F6E732E6D6F64656C4E616D65293B0D0A202020202020202020202020202020207D293B0D0A2A2F0D0A2020202020202020202020207D0D0A20202020202020207D20293B0D0A202020207D3B0D0A7D20292820617065782E7574';
wwv_flow_api.g_varchar2_table(185) := '696C2C20617065782E7769646765742E7574696C2C20617065782E726567696F6E2C20617065782E6A517565727920293B0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(18862947135951567790)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_file_name=>'simple_grid.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E612D4756207B0D0A20202020626F726465723A2031707820736F6C696420234530453045303B0D0A7D0D0A2E612D47562D666F6F746572207B0D0A20202020626F726465723A2031707820736F6C696420234530453045303B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(19071926126912665503)
,p_plugin_id=>wwv_flow_api.id(18862910167445342644)
,p_file_name=>'simple_grid.css'
,p_mime_type=>'text/css'
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
