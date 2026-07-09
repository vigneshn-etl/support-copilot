-- ENV: internal-qa | DB: trd | dumped: 2026-07-09 | server 14.17
--
-- PostgreSQL database dump
--

\restrict 1giFFTCBgsWr7eOJZkO4Gb6H3o2cHQOuq5eW9cwDaxJ2xFHJgxcU4RGdtfhug2m

-- Dumped from database version 14.17
-- Dumped by pg_dump version 14.23 (Ubuntu 14.23-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mfp; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mfp;


--
-- Name: mfp_td; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mfp_td;


--
-- Name: target_setting; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA target_setting;


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: approval; Type: TYPE; Schema: mfp; Owner: -
--

CREATE TYPE mfp.approval AS ENUM (
    'op',
    'rp'
);


--
-- Name: permission; Type: TYPE; Schema: mfp; Owner: -
--

CREATE TYPE mfp.permission AS ENUM (
    'read',
    'plan',
    'admin'
);


--
-- Name: scopetype; Type: TYPE; Schema: mfp; Owner: -
--

CREATE TYPE mfp.scopetype AS ENUM (
    'actuals',
    'morphed',
    'working',
    'saved',
    'submitted',
    'approved',
    'hidden'
);


--
-- Name: approval; Type: TYPE; Schema: mfp_td; Owner: -
--

CREATE TYPE mfp_td.approval AS ENUM (
    'op',
    'rp'
);


--
-- Name: permission; Type: TYPE; Schema: mfp_td; Owner: -
--

CREATE TYPE mfp_td.permission AS ENUM (
    'read',
    'plan',
    'admin'
);


--
-- Name: scopetype; Type: TYPE; Schema: mfp_td; Owner: -
--

CREATE TYPE mfp_td.scopetype AS ENUM (
    'actuals',
    'morphed',
    'working',
    'saved',
    'submitted',
    'approved',
    'hidden'
);


--
-- Name: agent_sender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agent_sender AS ENUM (
    'user',
    'agent',
    'system'
);


--
-- Name: queue_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.queue_state AS ENUM (
    'PENDING',
    'QUEUED',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


--
-- Name: undo_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.undo_status AS ENUM (
    'invalid',
    'undone'
);


--
-- Name: approval; Type: TYPE; Schema: target_setting; Owner: -
--

CREATE TYPE target_setting.approval AS ENUM (
    'op',
    'rp'
);


--
-- Name: permission; Type: TYPE; Schema: target_setting; Owner: -
--

CREATE TYPE target_setting.permission AS ENUM (
    'read',
    'plan',
    'admin'
);


--
-- Name: scopetype; Type: TYPE; Schema: target_setting; Owner: -
--

CREATE TYPE target_setting.scopetype AS ENUM (
    'actuals',
    'morphed',
    'working',
    'saved',
    'submitted',
    'approved',
    'hidden'
);


--
-- Name: sync_plan_data_wide(); Type: PROCEDURE; Schema: mfp; Owner: -
--

CREATE PROCEDURE mfp.sync_plan_data_wide()
    LANGUAGE plpgsql
    AS $$
BEGIN
    Delete 
    from mfp_td.sys_gen_wide 
    where sys_version = 'system';
    
    Insert Into mfp_td.sys_gen_wide
    Select 'system', pdw.time, pdw.product, pdw.product, pdw.prodlife, Coalesce(pdw.storecount,0), Coalesce(pdw.storecount,0), Coalesce(pdw.net_sls_u,0), Coalesce(pdw.net_sls_r,0), Coalesce(pdw.net_sls_c,0), Coalesce(pdw.pos_md_r,0), Coalesce(pdw.boh_r,0), Coalesce(pdw.boh_u,0), Coalesce(pdw.boh_c,0), Coalesce(pdw.eoh_u,0), Coalesce(pdw.eoh_r,0), Coalesce(pdw.eoh_c,0), Coalesce(pdw.rec_u,0), Coalesce(pdw.rec_c,0), Coalesce(pdw.rec_r,0), Coalesce(pdw.committed_u,0), Coalesce(pdw.committed_c,0), Coalesce(pdw.committed_r,0), Coalesce(pdw.on_order_u,0), Coalesce(pdw.on_order_c,0), Coalesce(pdw.on_order_r,0), Coalesce(pdw.inv_adjustment_u,0), Coalesce(pdw.inv_adjustment_r,0), Coalesce(pdw.inv_adjustment_c,0), Coalesce(pdw.mos_u,0), Coalesce(pdw.mos_r,0), Coalesce(pdw.mos_c,0), Coalesce(pdw.shrink_u,0), Coalesce(pdw.shrink_r,0), Coalesce(pdw.shrink_c,0), Coalesce(pdw.net_dc_xfer_u,0), Coalesce(pdw.net_dc_xfer_r,0), Coalesce(pdw.net_dc_xfer_c,0), Coalesce(pdw.perm_md_r,0), Coalesce(pdw.perm_md_c,0), Coalesce(pdw.perm_md_move_inv_u,0), Coalesce(pdw.perm_md_inv_r_csp,0), Coalesce(pdw.net_sls_r_adj,0), Coalesce(pdw.net_sls_c_adj,0), Coalesce(pdw.shrink_r_adj,0), Coalesce(pdw.shrink_c_adj,0), Coalesce(pdw.perm_md_inv_u_edit,0), Coalesce(pdw.perm_md_inv_r_at_new_aur_edit,0), Coalesce(pdw.perm_md_inv_c_edit,0)
    from mfp.plan_data_wide as pdw 
    inner join mfp.plans p 
    on p.id = pdw.id 
    where 
    ((module = 'bottom_up' and version in ('rp','wp')) or module = 'middle_out')
    and not exists
    (
        Select time, product, prodlife
        from mfp_td.sys_gen_wide
    );
END
$$;


--
-- Name: add_to_assortment(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_to_assortment(input_jsessionid text, scope_product text, scope_location text, scope_start text, scope_floorset text) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$
DECLARE

s1 text;
s2 text;
s3 text;
s4_1 text;
s4_2 text;
s4_3 text;
s4_4 text;
s5 text;
s6 text;
s7 text;
s7_1 text;
s8 text;
s9 text;
s10 text;
s11 text;
s12 text;
s13 text;
s14 text;
s15 text;
s16 text;
s17 text;
s18 text;
s19 text;
s20 text;
s21 text;
s21_x text;
s21_y text;
s22 text;
s23 text;
s24 text;
s25 text;
s26 text;
s26_X text;
s27 text;
s28 text;
s28_1 text;
s28_X text;
s28_X1 text;
s28_X2 text;
s28_Y text;
s29 text;
s29_1 text;
s30 text;
s31 text;
s32 text;
s33 text;
s34 text;
s35 text;
s36 text;
s36_1 text;
s37 text;
s38 text;
s39 text;
s39_test text;
s40 text;
s41 text;
s41_1 text;
s42 text;
s43 text;
s43_1 text;
s44 text;
s45 text;
s46 text;
s47 text;
s48 text;
s49 text;
s50 text;
s51 text;
s51_1 text;
added_prods refcursor;

v_uuid_temp text;
v_uuid text;
table_input_t1 text;
table_cart_master_temp text;
table_cart_style text;
table_cart_stylecolorsize text;
table_cart_stylecolor text;
table_default_cart_params text;
table_temp_sclr_chnl_attr text;
table_ma_imgattr text;
table_temp_assort text;
table_final_list text;
table_spec_img text;

s100 text;
s101 text;
s102 text;
s103 text;
s104 text;
s104_a text;
s105 text;
s106 text;
s107 text;
s108 text;
s109 text;
s110 text;
s111 text;
s112 text;
s113 text;
s114 text;
s115 text;
s110_1 text;
s110_2 text;
s110_3 text;
s110_4 text;
s110_5 text;

s113_1 text;
s113_2 text;

tst_df_temp text;
tst_md_seq text;
tst_df text;
tst_df_with_style text;
tst_md_tktp_md text;

table_xt text;
table_yt text;
table_zt text;

table_xt_flag text;
table_zt_flow_flag text;
table_zt_pre text;
s_pre_110_1 text;
s113_post text;

s001_x text;
s002_x text;
s003_x text;
s004_x text;
s005_x text;
s006_x text;
s007_x text;
s008_x text;
s009_x text;
s010_x text;
v_already_ata integer;

BEGIN


--RETURN NULL;
EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;

table_input_t1 := 'input_t1'||v_uuid;
table_cart_master_temp := 'cart_master_temp'||v_uuid;
table_cart_style := 'cart_style'||v_uuid;
table_cart_stylecolorsize := 'cart_stylecolorsize'||v_uuid;
table_cart_stylecolor := 'cart_stylecolor'||v_uuid;
table_default_cart_params := 'default_cart_params'||v_uuid;
table_temp_sclr_chnl_attr := 'temp_sclr_chnl_attr'||v_uuid;
table_spec_img := 'temp_space_img'||v_uuid;
table_ma_imgattr := 'table_ma_imgattr'||v_uuid;
table_temp_assort := 'table_temp_assort'||v_uuid;
table_final_list := 'table_final_list'||v_uuid;


tst_df_temp := 'tst_df_temp'||v_uuid;
tst_md_seq := 'tst_md_seq'||v_uuid;
tst_df := 'tst_df'||v_uuid;
tst_df_with_style := 'tst_df_with_style'||v_uuid;
tst_md_tktp_md := 'tst_md_tktp_md'||v_uuid;

table_xt := 'table_xt'||v_uuid;
table_yt := 'table_yt'||v_uuid;
table_zt := 'table_zt'||v_uuid;

table_xt_flag := 'table_xt_flag'||v_uuid;
table_zt_flow_flag := 'table_zt_flow_flag'||v_uuid;
table_zt_pre  := 'table_zt_pre'||v_uuid;


s1 := 'create temporary table '||table_input_t1||' as select '''||$1||''' as jsid,'''||$2||''' as scope_product,'''||$3||''' as scope_location ,'''||$4||''' as scope_start,'''||$5||''' as scope_floorset
    ';

-- delete from debug_stats_ts where stat_id='s1';

s2 := '
    create temporary table '||table_cart_master_temp||' as
    select
    distinct
    jsessionid
    ,  style_sequence
    ,  style_id as incoming_style_id
    ,  style_name
    ,  style_description
    ,  style_type
    ,  cccolor
    ,  stylecolor_id as incoming_stylecolor_id
    ,  stylecolor_type
    ,  stylecolor_name
    ,  stylecolor_description
    ,  null::text final_style_id
    ,  null::text final_stylecolor_id
    ,  initiator
    ,  null::text as cccolorfamily
    ,  null::text as cccolorid
    ,  null::text as color_description
    ,  img
    ,  job_priority
    ,  null::text class_id
    ,  null::text subclass_id
    ,  null::text class_name
    ,  null::text subclass_name
    from cart_master
    where
    jsessionid in (select jsid from '||table_input_t1||')
    and isProcessed=0
    '
    ;

s3 := '
    create temporary table '||table_cart_style||' as
    select jsessionid
    , style_sequence
    , case when style_type = ''similar'' then uuid_generate_v4()::text else incoming_style_id end AS final_style_id
    , incoming_style_id
    , style_type
    , style_name  as displayed_style_name
    , style_description  as displayed_style_description
    from
    (
    select distinct jsessionid, style_sequence, style_type, incoming_style_id, style_name, style_description from '||table_cart_master_temp||'
    where jsessionid in (select jsid from '||table_input_t1||')
    ) x
    ';


s4_1 := '
    Update '||table_cart_master_temp||' a
    set final_style_id = b.final_style_id
    from '||table_cart_style||' b
    where
    a.incoming_style_id=b.incoming_style_id
    and a.style_type=b.style_type
    and a.jsessionid=b.jsessionid
    and a.style_sequence=b.style_sequence
    and a.jsessionid in (select jsid from '||table_input_t1||')
    ';



s4_2 := '
    Update '||table_cart_master_temp||' a
    set class_id = b.ancestor1,
        subclass_id = b.ancestor0
    from trd_h_prodstd b
    where
    b.id = a.incoming_style_id
    ';



s4_3 := '
    Update '||table_cart_master_temp||' a
    set class_name = b.name
    from trd_d_product b
    where
    b.id = a.class_id
    ';



s4_4 := '
    Update '||table_cart_master_temp||' a
    set subclass_name = b.name
    from trd_d_product b
    where
    b.id = a.subclass_id
    ';



s5 := '
    create temporary table '||table_cart_stylecolor||' as
    select jsessionid
    , style_sequence
    , case when stylecolor_type = ''similar'' then uuid_generate_v4()::text else incoming_stylecolor_id end AS final_stylecolor_id
    , incoming_stylecolor_id
    , stylecolor_type
    , case when stylecolor_type = ''similar'' then style_name||'' ''||color_description else stylecolor_name end as displayed_stylecolor_name
    , case when stylecolor_type = ''similar'' then style_description ||'' ''||color_description else stylecolor_description end as displayed_stylecolor_description
    , incoming_style_id
    , style_type
    , cccolor
    from
    (
    select distinct jsessionid,style_sequence, incoming_style_id,final_style_id, style_type,incoming_stylecolor_id, stylecolor_type, a.cccolor
    , style_name, style_description, stylecolor_name, stylecolor_description, b.color_description
    from '||table_cart_master_temp||' a, (select lookup_value as cccolor, target_value color_description from trd_l_dependencylookup where target_id = ''color_description'' and lookup_id = ''cccolor'') b
    where jsessionid in (select jsid from '||table_input_t1||') and a.cccolor = b.cccolor
    ) x
    '
    ;


s6 := '
    Update '||table_cart_master_temp||' a set
    final_stylecolor_id = b.final_stylecolor_id
    , stylecolor_name = displayed_stylecolor_name
    , stylecolor_description = displayed_stylecolor_description
    from '||table_cart_stylecolor||' b
    where
    a.incoming_stylecolor_id=b.incoming_stylecolor_id
    and a.cccolor = b.cccolor
    and a.incoming_style_id=b.incoming_style_id
    and a.style_type=b.style_type
    and a.stylecolor_type=b.stylecolor_type
    and a.jsessionid=b.jsessionid
    and a.style_sequence=b.style_sequence
    and a.jsessionid in (select jsid from '||table_input_t1||')
    '
    ;



s7 := '
    CREATE temporary TABLE '||table_cart_stylecolorsize||' AS
    SELECT
           case when stylecolor_type=''similar'' then uuid_generate_v4()::text else stylecolorsize_id end AS final_stylecolorsize_id
         , sizeattribute    AS size_name
         , sizeattribute    AS size_description
         , incoming_stylecolor_id
         , incoming_style_id
         , final_style_id
         , final_stylecolor_id
         , stylecolor_type
         , jsessionid
         , item_diff_2
         , item_diff_3
         , isvalid
    FROM   (SELECT
           a.incoming_stylecolor_id
           , a.incoming_style_id
           , uuid_generate_v4()::text stylecolorsize_id
           , parent_size as item_diff_2
           , size_id as item_diff_3
           , target_value as sizeattribute
           , 1 as isvalid
           , a.jsessionid
           , a.style_type
           , a.stylecolor_type
           , a.final_style_id
           , a.final_stylecolor_id
          FROM   '||table_cart_master_temp||' a
                 , trd_ma_styleattributes c
                 , trd_l_dependencylookup d
                 , trd_size_range_mapping e
          WHERE  c.product = a.incoming_style_id
            and d.lookup_value = e.size_range and d.target_value = e.size_desc
            and lookup_id = ''size_range'' and lookup_value = c.sty_size_range
            and stylecolor_type=''similar''
          )x
          '
          ;

s7_1 := '
    insert into '||table_cart_stylecolorsize||'
    SELECT
           case when stylecolor_type=''similar'' then uuid_generate_v4()::text else stylecolorsize_id end AS final_stylecolorsize_id
         , sizeattribute    AS size_name
         , sizeattribute    AS size_description
         , incoming_stylecolor_id
         , incoming_style_id
         , final_style_id
         , final_stylecolor_id
         , stylecolor_type
         , jsessionid
         , item_diff_2
         , item_diff_3
         , isvalid
    FROM   (SELECT
           a.incoming_stylecolor_id
           , a.incoming_style_id
           , b.product stylecolorsize_id
           , b.parent_id
           , item_diff_2
           , item_diff_3
           , b.sizeattribute
           , b.isvalid
           , a.jsessionid
           , a.style_type
           , a.stylecolor_type
           , a.final_style_id
           , a.final_stylecolor_id
          FROM   '||table_cart_master_temp||' a
                 , trd_ma_sizeattributes b
          WHERE  a.incoming_stylecolor_id = b.parent_id
          and stylecolor_type=''existing''
          )x
          '
          ;

EXECUTE s1;
-- insert into trigger_test_delete_me values ('s1:', clock_timestamp());
EXECUTE s2;
-- insert into trigger_test_delete_me values ('s2:', clock_timestamp());
EXECUTE s3;
-- insert into trigger_test_delete_me values ('s3:', clock_timestamp());
EXECUTE s4_1;
-- insert into trigger_test_delete_me values ('s4_1:', clock_timestamp());
EXECUTE s5;
-- insert into trigger_test_delete_me values ('s5:', clock_timestamp());
EXECUTE s6;
-- insert into trigger_test_delete_me values ('s6:', clock_timestamp());
EXECUTE s7;
-- insert into trigger_test_delete_me values ('s7:', clock_timestamp());
EXECUTE s7_1;
-- insert into trigger_test_delete_me values ('s7_1:', clock_timestamp());

-- Check if the product is already in assortment. If yes then return

execute '
select count(*)
from (
select distinct a.product, a.location
from
(select distinct product,location  from trd_ma_stylecolorchannelattributes where record_state = 0 and (product, location) in (select distinct final_stylecolor_id,'''||$3||''' as prod_loc from '||table_cart_master_temp||')) a,
(select distinct product,location  from trd_a_assortment where (product, location) in (select distinct final_stylecolor_id, '''||$3||''' as prod_loc from '||table_cart_master_temp||')) b
where
a.product=b.product
and a.location=b.location
)x
' into v_already_ata;

if v_already_ata > 0 then
  s002_x := '
  insert into plan_queue (product, location, initiator, initiated_at)
  select final_stylecolor_id, '''||$3||''', initiator :: uuid, now() from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')
  ';
  EXECUTE s002_x;
  s003_x := 'select final_stylecolor_id product from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')';
  
  s004_x := 'update cart_master set isProcessed=1 where jsessionid in (select jsid from  '||table_input_t1||')';
  EXECUTE s004_x;
  s005_x := 'insert into cart_master_archive select * from cart_master  where jsessionid in (select jsid from  '||table_input_t1||')';
  s006_x := 'insert into cart_params_archive select * from cart_params  where jsessionid in (select jsid from  '||table_input_t1||')';
  s007_x := 'insert into cart_ranging_archive select * from cart_ranging  where jsessionid in (select jsid from  '||table_input_t1||')';
  EXECUTE s005_x;
  EXECUTE s006_x;
  EXECUTE s007_x;
  s008_x := 'delete from cart_master where jsessionid in (select jsid from  '||table_input_t1||')';
  s009_x := 'delete from cart_params where jsessionid in (select jsid from  '||table_input_t1||')';
  s010_x := 'delete from cart_ranging where jsessionid in (select jsid from  '||table_input_t1||')';
  EXECUTE s008_x;
  EXECUTE s009_x;
  EXECUTE s010_x;
  OPEN added_prods FOR EXECUTE s003_x;
  
  RAISE NOTICE 'Marked Cart as isProcessed:%', 'START:'|| now();
  
   RETURN added_prods;
end if;

s8 := 'delete from trd_d_product where id in (select final_style_id from '||table_cart_style||' WHERE style_type=''similar'' and jsessionid in (select jsid from '||table_input_t1||'))';


s9 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_style_id AS id
       , COALESCE(displayed_style_name, ''S5-'' || nextval(''style_sequence'') || ''-'' || displayed_style_name) AS NAME
       , COALESCE(displayed_style_description, ''S5-'' || nextval(''style_sequence'') ||''-'' || displayed_style_description) AS description
       , ''style'' AS levelid
    FROM   '||table_cart_style||'
    WHERE style_type=''similar''
    ';



s10 := '
delete from trd_d_product where id in (select distinct final_stylecolor_id from '||table_cart_stylecolor||' WHERE stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';


s11 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_stylecolor_id              AS id
           , displayed_stylecolor_name        AS NAME
           , displayed_stylecolor_description AS description
           , ''stylecolor''             AS levelid
    FROM '||table_cart_stylecolor||'
    WHERE stylecolor_type=''similar''
    '
    ;




s12 := '
delete from trd_d_product where id in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' WHERE stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s13 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_stylecolorsize_id            AS id
           , size_name        AS NAME
           , size_description AS description
           , ''stylecolorsize'' AS levelid
    FROM   '||table_cart_stylecolorsize||'
    WHERE stylecolor_type=''similar''
    '
    ;



-- CREATING HIERARCHY

s14 := '
delete from trd_h_prodstd where id in (select distinct final_style_id from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s15 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_style_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
                , ancestor7
FROM   '||table_cart_master_temp||' a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 , ancestor7 from trd_h_prodstd) b
WHERE style_type=''similar''
and a.incoming_style_id = b.id
'
;



s16 := '
delete from trd_h_prodstd where id in (select distinct final_stylecolor_id from '||table_cart_master_temp||'  where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s17 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_stylecolor_id
                , final_style_id
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
                , ancestor7
FROM   '||table_cart_master_temp||'   a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 , ancestor7 from trd_h_prodstd) b
WHERE stylecolor_type=''similar''
and a.incoming_stylecolor_id = b.id
'
;



s18 := '
delete from trd_h_prodstd where id in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s19 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_stylecolorsize_id
                , final_stylecolor_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
FROM    '||table_cart_stylecolorsize||'  a,
trd_h_prodstd b
WHERE stylecolor_type=''similar''
and a.final_stylecolor_id = b.id
'
;

s20 := '
delete from trd_ma_styleattributes where product in (select distinct final_style_id from '||table_cart_master_temp||' WHERE style_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

-- updating cccolor and cccolorfamily

s21 := '
update '||table_cart_master_temp||' a set cccolorfamily = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''cccolorfamily'' and lookup_value=a.cccolor
';

s21_x := '
update '||table_cart_master_temp||' a set cccolorid = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''color_code'' and lookup_value=a.cccolor
';

s21_y := '
update '||table_cart_master_temp||' a set color_description = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''color_description'' and lookup_value=a.cccolor
';


s22 := '
delete from trd_l_dependencylookup where target_id=''patternedtostyle'' and target_value in (select distinct final_style_id from  '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s23 := '
delete from trd_l_dependencylookup where target_id=''patternedtostylecolor'' and target_value in (select distinct final_stylecolor_id from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';





s24 := '
insert into trd_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''style'' as lookup_id, incoming_style_id as lookup_value, ''patternedtostyle'' target_id, final_style_id as target_value
from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||')
';


s25 := '
insert into trd_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''stylecolor'' as lookup_id, incoming_stylecolor_id as lookup_value, ''patternedtostylecolor'' target_id, final_stylecolor_id as target_value
from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||')
';


-- STYLE ATTRIBUTES

S26 := '
INSERT INTO trd_ma_styleattributes
            (product      
            ,sty_knit_or_woven
            ,sty_fabrication
            ,sty_sleeve_length
            ,sty_leg_opening
            ,sty_brand
            ,sty_body_style_silhouette
            ,sty_occasion_usage
            ,sty_detail
            ,sty_finish_style
            ,sty_private_label
            ,sty_license
            ,sty_license_vs_non_licensed
            ,sty_hazmat_code
            ,sty_prop_65_warning
            ,sty_material_content
            ,sty_item_type
            ,sty_dwrise
            ,sty_length
            ,sty_neckline
            ,sty_toeshape
            ,sty_heel_height
            ,sty_bottom_length
            ,sty_v_360_smoothing
            ,sty_franchise
            ,sty_key_item
            ,sty_single_vs_multi_pack
            ,sty_ticket_type
            ,sty_vpn
            ,sty_size_range
            ,ccstylecreatedate
            ,sty_is_locked
            ,sty_s5_adopted
            ,sty_patterned_after 
        ,sty_knit_fit -- Added by CA ON 03.18.2025
            )
SELECT final_style_id as product
        ,sty_knit_or_woven
            , null as sty_fabrication
        ,sty_sleeve_length
        ,sty_leg_opening
        ,sty_brand
        ,sty_body_style_silhouette
            , null as sty_occasion_usage
            , null as sty_detail
            , null as sty_finish_style
        ,sty_private_label
            , null as sty_license
        ,sty_license_vs_non_licensed
            , null as sty_hazmat_code
            , null as sty_prop_65_warning
            , null as sty_material_content
            , null as sty_item_type
        ,sty_dwrise
        ,sty_length
        ,sty_neckline
            , null as sty_toeshape
        ,sty_heel_height
            , null as sty_bottom_length
            , null as sty_v_360_smoothing
            , null as sty_franchise
            , null as sty_key_item
        ,sty_single_vs_multi_pack
            , null as sty_ticket_type
            , null as sty_vpn
        ,sty_size_range
            , null as ccstylecreatedate
            , null as sty_is_locked
            ,''Y''
            , a.incoming_style_id

        -- new add on 03.18.2025 CA
        , sty_knit_fit
from (select distinct final_style_id, style_type, incoming_style_id, class_id, subclass_id, class_name, subclass_name from '||table_cart_master_temp||') a, trd_ma_styleattributes b
where a.incoming_style_id=b.product
and a.style_type=''similar''
';


s26_X := '
Update trd_ma_styleattributes b
set plm_size_range = sty_size_range, sty_is_locked = ''Y'', sty_s5_adopted = ''Y''
from (select distinct final_style_id, style_type, stylecolor_type, incoming_style_id  from '||table_cart_master_temp||') a
where a.incoming_style_id=b.product
and a.style_type=''existing'' and a.stylecolor_type=''existing''
';


-- STYLECOLOR ATTRIBUTES

s27 := '
delete from trd_ma_stylecolorattributes where product in (select distinct final_stylecolor_id from '||table_cart_master_temp||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';



s28 := '
INSERT INTO trd_ma_stylecolorattributes
        (product
         ,cc_item_diff_1
         ,cc_unit_retail
         ,cc_unit_retail_cad
         ,cc_pattern
         ,cc_graphic
         ,cc_fashion_basic
         ,cc_holiday
         ,cc_property_type
         ,cc_internet_exclusive
         ,cc_web_color_discription
         ,cc_export_hts
         ,cc_commercial_invoice_description
         ,cc_season_code
         ,cc_dtr
         ,cc_dw_color_family
         ,cc_channel_reorder
         ,cc_ticket_season_code
         ,cc_sub_programs
         ,cc_music_genre
         ,cc_clearance_str_product
         ,cc_po_supplier
         ,cc_origin_country_id
         ,cc_country_of_sourcing
         ,cc_country_of_manufacturing
         ,cc_unit_cost
         ,cc_freight
         ,cc_royalty
         ,cc_duty
         ,cc_ship_method
         ,cc_lading_port
         ,cc_hts
         ,cc_primary_supplier
         ,cc_sub_brand
         ,cc_pattern_type
         ,cc_pop_print_neutral
         ,cc_debut_season_code
         ,cc_matchback
         ,cc_primary_collection
         ,cc_secondary_collection
         ,cc_vpn_color
                  ,cc_orig_unit_retail
         ,cc_orig_unit_retail_cad
         ,cc_first_rec_week
         ,cc_first_inv_week
         ,cc_first_sale_week
         ,cc_first_md_week
         ,cc_last_md_week
         ,cc_last_rec_week
         ,cc_store_price_status
         ,cc_ifc_price_status
         ,cc_omni_price_type
         ,ccstylecolorcreatedate
         ,cc_price_band
         ,cc_good_better_best
         ,cccolor
         ,cccolorfamily
         ,total_brand_name
         ,division_name
         ,group_name
         ,department_name
         ,class_name
         ,subclass_name
         ,cc_s5_adopted
         ,cccolorid
         ,cc_patterned_after
         ,stylecolor_name
         ,style_name
        )
SELECT final_stylecolor_id as product
               , null as cc_item_diff_1
         , b.cc_unit_retail
         , b.cc_unit_retail_cad
               , null as cc_pattern
               , null as cc_graphic
               , null as cc_fashion_basic
               , null as cc_holiday
               , null as cc_property_type
               , null as cc_internet_exclusive
         , a.color_description
               , null as cc_export_hts
               , null as cc_commercial_invoice_description
               , null as cc_season_code
               , null as cc_dtr
          , a.cccolorfamily as cc_dw_color_family
               , null as cc_channel_reorder
               , null as cc_ticket_season_code
               , null as cc_sub_programs
               , null as cc_music_genre
               , null as cc_clearance_str_product
               , null as cc_po_supplier
               , null as cc_origin_country_id
               , null as cc_country_of_sourcing
               , null as cc_country_of_manufacturing
               , null as cc_unit_cost
               , null as cc_freight
               , null as cc_royalty
               , null as cc_duty
               , null as cc_ship_method
               , null as cc_lading_port
               , null as cc_hts
               , null as cc_primary_supplier
          , b.cc_sub_brand
               , null as cc_pattern_type
               , null as cc_pop_print_neutral
               , null as cc_debut_season_code
               , null as cc_matchback
               , null as cc_primary_collection
               , null as cc_secondary_collection
               , null as cc_vpn_color
          , b.cc_orig_unit_retail
          , b.cc_orig_unit_retail_cad
               , null as cc_first_rec_week
               , null as cc_first_inv_week
               , null as cc_first_sale_week
               , null as cc_first_md_week
               , null as cc_last_md_week
               , null as cc_last_rec_week
               , null as cc_store_price_status
               , null as cc_ifc_price_status
               , null as cc_omni_price_type
               , null as ccstylecolorcreatedate
          , b.cc_price_band
          , b.cc_good_better_best
          , a.cccolor
          , a.cccolorfamily

         , b.total_brand_name
         , b.division_name
         , b.group_name
         , b.department_name
         , b.class_name
         , b.subclass_name
         , ''Y'' as cc_s5_adopted
         , a.cccolorid
         , a.incoming_stylecolor_id
         , a.stylecolor_name
         , a.style_name

from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily,cccolorid,color_description, stylecolor_name, style_name  from '||table_cart_master_temp||') a, trd_ma_stylecolorattributes b
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''similar''
';


s28_X := '
Update trd_ma_stylecolorattributes b
set isassortment = ''true'', cc_is_locked = ''Y'', cc_s5_adopted = ''Y''
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily  from '||table_cart_master_temp||') a
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''existing''
';

s28_X1 := '
Update trd_ma_stylecolorattributes b
set cc_price_band = a.price_band
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, usd_ticket_price, price_band  from '||table_cart_master_temp||' x, trd_h_prodstd z, trd_l_ticketprice y where x.final_stylecolor_id = z.id and z.ancestor3 = y.product) a
where a.final_stylecolor_id=b.product
and b.cc_orig_unit_retail = a.usd_ticket_price
and a.stylecolor_type=''similar''
';

s28_X2 := '
Update trd_ma_stylecolorattributes b
set cc_good_better_best = a.price_band
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, subclass_id, ticket_price_min, ticket_price_max, price_band  from '||table_cart_master_temp||' x, trd_l_pricebandlookup y where x.subclass_id = y.product) a
where a.final_stylecolor_id=b.product
and b.cc_orig_unit_retail > ticket_price_min and b.cc_orig_unit_retail <= ticket_price_max
and a.stylecolor_type=''similar''
';


-- IMAGE ATTRIBUTES START

s29 := 'drop table if exists '||table_ma_imgattr||'';

s29_1 := '
create temporary table '||table_spec_img||' as
select
 distinct si.product, si.img, sa.product as stylecolor_id
from trd_specimages si
 inner join
trd_ma_stylecolorattributes sa
 on sa.product = si.product
where sa.product in (select final_stylecolor_id from '||table_cart_master_temp||' where jsessionid in (select jsid from '||table_input_t1||'));
';

s30 := '
create temporary table '||table_ma_imgattr||' as
select
    c.jsessionid
  , c.final_stylecolor_id as product
  , b.img as orig_image
  , c.img as cart_image
  , d.img as spec_image
FROM
  (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id, img from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')) c
 LEFT JOIN
  (select distinct product, img from trd_ma_imgattributes where product in (select distinct incoming_stylecolor_id from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||'))) b
ON
b.product=c.incoming_stylecolor_id
  LEFT JOIN
  (select distinct product, img, stylecolor_id from '||table_spec_img||') d
on
d.stylecolor_id = c.final_stylecolor_id;

'
;


s31 := '
delete from trd_ma_imgattributes where product in (
    select distinct final_stylecolor_id from  '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')
)
'
;

s32 := '
insert into trd_ma_imgattributes (product, img)
select product, coalesce(cart_image,orig_image,spec_image) from '||table_ma_imgattr||'
';




-- IMAGE ATTRIBUTES END

-- SIZE ATTRIBUTES

s33 := '
delete from trd_ma_sizeattributes where product in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))
';



s34 := '
insert into trd_ma_sizeattributes
    (product,
    parent_id,
    item_diff_2,
    item_diff_3,
    sizeattribute,
    isvalid
    )
SELECT
    distinct final_stylecolorsize_id,
    final_stylecolor_id,
    item_diff_2,
    item_diff_3,
    size_name,
    isvalid
FROM
    '||table_cart_stylecolorsize||'
WHERE stylecolor_type = ''similar''
';

PERFORM get_default_params(''||$1||'',''||$2||'',''||$3||'',''||$4||'',''||$5||'');

-- STYLECOLOR CHANNEL ATTRIBUTES

s35 := '
create temporary  table '||table_default_cart_params||' as
select
    a.jsessionid
  , a.scope_product
  , a.scope_location
  , a.initrcptwk  as default_initrcptwk
  , a.dbt_wk as default_dbt_wk
  , a.too as default_too
  , a.mkdnwks as default_mkdnwks
  , a.last_inv_wk as default_last_inv_wk
  , a.lstfpwk as default_lstfpwk
  , a.last_rcpt_wk as default_last_rcpt_wk
  , a.erlstmkdnwk as default_erlstmkdnwk
  , a.exitdate as default_exitdate
  , a.ccmdstrategy as default_ccmdstrategy
  , a.presmin as default_presmin
  , a.presmin_weeks as default_presmin_weeks
  , a.retpct_str as default_retpct_str
  , a.retpct_ecomm as default_retpct_ecom
  , a.retpct_cross as default_retpct_cross
  , a.ccrcptint as default_ccrcptint
  , a.ccordermultiple as default_ccordermultiple
  , a.ccordpolicy as default_ccordpolicy
  , a.slsrnk_store
  , a.slsrnk_ecom
  , a.planned_sell_down_week
  , c.default_ccdiscountpct
  , c.default_lead_time
  , a.cc_cluster_group

-- CA MOD 08.14.2025
  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank
  , a.use_valid_sizes_from as use_valid_sizes_from
  , a.apply_size_mins_to as apply_size_mins_to
  , a.cc_addoff_store as cc_addoff_store
  , a.cc_addoff_ecom as cc_addoff_ecom

from (select distinct * from cart_params) a, trd_ma_dptflrsetattributes c, '||table_input_t1||' b
where a.jsessionid = b.jsid
and a.scope_product = b.scope_product
and a.scope_location = b.scope_location
and a.scope_start = b.scope_start
and a.scope_product = c.product
and a.scope_floorset = c.time
'
;


s36 := '
create  temporary table '||table_temp_sclr_chnl_attr||' as
select
    a.jsessionid
  , final_stylecolor_id as product
  , a.scope_location as location
  , default_initrcptwk as initrcptwk
  , default_dbt_wk as dbt_wk
  , default_too as too
  , default_mkdnwks as mkdnwks
  , default_last_inv_wk as last_inv_wk
  , default_lstfpwk as lstfpwk
  , default_last_rcpt_wk as last_rcpt_wk
  , default_erlstmkdnwk as erlstmkdnwk
  , default_exitdate as exitdate

  , coalesce(default_ccmdstrategy, ccmdstrategy) ccmdstrategy
  , ccrangecode
  , case when (ssnprf is null or ssnprf ='''') then ''class_default'' else ssnprf end
  , cc_validsizes_store
  , cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
    , coalesce(default_ccordermultiple::int, cc_ordermultiple::int) cc_ordermultiple
  , null::real as cc_systemcost

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

   , CASE
      WHEN a.use_act_aps_or_act_rank = ''Use Cart Rating'' THEN a.slsrnk_store
      ELSE COALESCE(b.act_slsrnk_store, b.slsrnk_store)
    END AS slsrnk_store

  , COALESCE(b.act_aps_mult_adj_store, 1) as act_aps_mult_adj_store

  , CASE
      WHEN a.use_act_aps_or_act_rank = ''Use Cart Rating'' THEN a.slsrnk_ecom
      ELSE COALESCE(b.act_slsrnk_ecom, b.slsrnk_ecom)
    END AS slsrnk_ecom
  , COALESCE(b.act_aps_mult_adj_ecom, 1) as act_aps_mult_adj_ecom

  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  , a.use_valid_sizes_from
  , a.apply_size_mins_to
  , a.cc_addoff_store
  , a.cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================


  , default_retpct_str as cc_return_u_pct_store
  , default_retpct_ecom as cc_return_u_pct_ecom
  , default_retpct_cross as cc_return_u_pct_cross

  -- MODIFIED BY CA on 03.29.2025
  -- , coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost ) as cc_plan_cost
  -- , coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost ) as cc_final_cost

  , case      when coalesce(b.cc_systemcost, 0.0) > 0.0 then b.cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end as cc_plan_cost

  , case      when coalesce(b.cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end as cc_final_cost

  , a.planned_sell_down_week
  , b.ccticketpricechannel
  , a.default_ccdiscountpct
  -- , coalesce(round(((b.ccticketpricechannel-(coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost)))/b.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 

  , coalesce(round(((b.ccticketpricechannel-(case  when coalesce(b.cc_systemcost, 0.0) > 0.0 then b.cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end))/b.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 
  , a.default_lead_time as cc_lead_time
  , a.cc_cluster_group




FROM
'||table_default_cart_params||' a, trd_ma_stylecolorchannelattributes b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||' where style_type = ''similar'') c,
 trd_ma_stylecolorattributes d, trd_ma_stylecolorattributes e
where b.product=c.incoming_stylecolor_id and a.jsessionid=c.jsessionid and a.scope_location=b.location and c.final_stylecolor_id = d.product
and e.product=c.incoming_stylecolor_id
';


s36_1 := '
insert into '||table_temp_sclr_chnl_attr||'
select
    a.jsessionid
  , final_stylecolor_id as product
  , a.scope_location as location
  , default_initrcptwk as initrcptwk
  , default_dbt_wk as dbt_wk
  , default_too as too
  , default_mkdnwks as mkdnwks
  , default_last_inv_wk as last_inv_wk
  , default_lstfpwk as lstfpwk
  , default_last_rcpt_wk as last_rcpt_wk
  , default_erlstmkdnwk as erlstmkdnwk
  , default_exitdate as exitdate

  , coalesce(default_ccmdstrategy, ccmdstrategy) ccmdstrategy
  , ccrangecode
  , case when (ssnprf is null or ssnprf ='''') then ''class_default'' else ssnprf end
  , cc_validsizes_store
  , cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
  , coalesce(default_ccordermultiple::int, cc_ordermultiple::int) cc_ordermultiple
  , cc_systemcost

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , COALESCE(e.act_slsrnk_store, e.slsrnk_store) as slsrnk_store
  , COALESCE(e.act_aps_mult_adj_store, 1) as act_aps_mult_adj_store

  , COALESCE(e.act_slsrnk_ecom, e.slsrnk_ecom) as slsrnk_ecom
  , COALESCE(e.act_aps_mult_adj_ecom, 1) as act_aps_mult_adj_ecom

  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  , a.use_valid_sizes_from
  , a.apply_size_mins_to
  , a.cc_addoff_store
  , a.cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================

  , default_retpct_str as cc_return_u_pct_store
  , default_retpct_ecom as cc_return_u_pct_ecom
  , default_retpct_cross as cc_return_u_pct_cross
  , cc_plan_cost

    , case    when coalesce(cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(d.cc_unit_cost, 0.0) > 0.0 then d.cc_unit_cost
              else cc_plan_cost
      end as cc_final_cost
  -- , case when cc_systemcost is not null then cc_systemcost when d.cc_unit_cost is not null then d.cc_unit_cost else cc_plan_cost end as cc_final_cost
  
  , a.planned_sell_down_week
  , e.ccticketpricechannel
  , a.default_ccdiscountpct
 -- , coalesce(round(((e.ccticketpricechannel-(case when cc_systemcost is not null then cc_systemcost when d.cc_unit_cost is not null then d.cc_unit_cost else cc_plan_cost end))/e.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct
  , coalesce(round(((e.ccticketpricechannel-(case  when coalesce(cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(d.cc_unit_cost, 0.0) > 0.0 then d.cc_unit_cost
              else cc_plan_cost
      end))/e.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 

  , a.default_lead_time as cc_lead_time
  , a.cc_cluster_group
FROM
'||table_default_cart_params||' a, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id, class_id, style_type from '||table_cart_master_temp||' where style_type = ''existing'') b,
trd_ma_styleattributes c, 
trd_ma_stylecolorattributes d,
trd_ma_stylecolorchannelattributes e
--(select array_agg(target_value) as validsizes, lookup_value as sty_size_run_name from trd_l_dependencylookup where lookup_id = ''size_range'' group by lookup_value) e
where a.jsessionid=b.jsessionid 
and b.final_style_id = c.product 
and b.final_stylecolor_id = d.product 
and b.incoming_stylecolor_id = e.product
and a.scope_location = e.location
--and c.sty_size_range = e.sty_size_run_name 
'
;



s37 := '
delete from trd_ma_stylecolorchannelattributes where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
';



s38 := '
INSERT  into trd_ma_stylecolorchannelattributes (
  product
, location
, initrcptwk
, dbt_wk
, too
, mkdnwks
, last_inv_wk
, lstfpwk
, last_rcpt_wk
, erlstmkdnwk
, exitdate
, ccmdstrategy
, ccrangecode
, ssnprf
, validsizes
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_imupct
, cc_systemcost
-- , slsrnk_store
-- , slsrnk_ecom
, ccticketpricechannel
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_return_u_pct_cross
, cc_plan_cost
, cc_final_cost
, planned_sell_down_week
, cc_discount_pct
, cc_lead_time
, irw_debut_offset
, cc_cluster_group

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , slsrnk_store
  , act_aps_mult_adj_store
  , slsrnk_ecom
  , act_aps_mult_adj_ecom

  , use_act_aps_or_act_rank

  , use_valid_sizes_from
  , apply_size_mins_to
  , cc_addoff_store
  , cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================

)
select
  product
, location
, initrcptwk
, dbt_wk
, too
, mkdnwks
, last_inv_wk
, lstfpwk
, last_rcpt_wk
, erlstmkdnwk
, exitdate
, ccmdstrategy
, ccrangecode
, ssnprf
, ''{}''::text[]
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_imupct
, cc_systemcost
-- , slsrnk_store
-- , slsrnk_ecom
, ccticketpricechannel
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_return_u_pct_cross
, cc_plan_cost
, cc_final_cost
, planned_sell_down_week
, default_ccdiscountpct
, cc_lead_time
, b.irw_debut_offset
, a.cc_cluster_group

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , slsrnk_store
  , act_aps_mult_adj_store
  , slsrnk_ecom
  , act_aps_mult_adj_ecom
  
  , use_act_aps_or_act_rank

  , use_valid_sizes_from
  , apply_size_mins_to
  , cc_addoff_store
  , cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================
FROM
 '||table_temp_sclr_chnl_attr||' a, 
(select b.id, ap_start, ap_end, irw_debut_offset
      from trd_ma_dptflrsetattributes a, trd_h_prodstd b
      where b.ancestor3 = a.product and b.id in (select product from '||table_temp_sclr_chnl_attr||')
     ) b
where a.product = b.id
and a.dbt_wk between ap_start and ap_end;
 ';




-- ASSORTMENT MODEL

s51 := '
update trd_ma_stylecolorchannelattributes a
set plan_current = v_plan_current,
    ccticketpricechannel = cc_orig_unit_retail,
    cc_imupct = coalesce(round(((cc_orig_unit_retail-cc_final_cost)/cc_orig_unit_retail)::numeric, 2),0.0),
    ccrangecode = d.ccrangecode,
    use_valid_sizes_from = d.use_valid_sizes_from
from (select value as v_plan_current from trd_serviceparams where id=''plan_current'') b,
     trd_ma_stylecolorattributes c, (select product, ccrangecode, use_valid_sizes_from from '||table_temp_sclr_chnl_attr||') d
where (a.product, a.location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
and a.product = c.product
and a.product = d.product
';

/*
-- When adding a color to an exsting style, we will take the max of various attributes and cost for the parent style and apply them to the newly added stylecolor
s51_1 := '
update trd_ma_stylecolorchannelattributes a
set
  ccrangecode = rangecode
 ,cc_validsizes_store = cc_validsizes_store_existing
 ,cc_validsizes_ecom = cc_validsizes_ecom_existing
 ,ccticketpricechannel = cast(coalesce(cc_msrp::real, .01) as real)
 ,cc_ordpolicy = cc_ordpolicy_existing
 ,cc_ordermultiple = cc_ordermultiple_existing
 ,cc_existingwac = cast(coalesce(cc_existingwac_existing::real,0.0) as real)
 ,cc_systemcost = cast(coalesce(cc_systemcost_existing::real,0.0) as real)
 ,cc_plan_cost = cast(coalesce(cc_plan_cost_existing::real,0.0) as real)
 ,cc_landed_cost = cast(coalesce(cc_landed_cost_existing::real,0.0) as real)
 ,cc_target_cost = cast(coalesce(cc_target_cost_existing::real,0.0) as real)
 --,cc_imupct = coalesce(round((((cc_msrp::real-coalesce(cc_actual_cost,cc_estimated_cost)::real)/cc_msrp::real)::numeric), 2)::real,0.0)::real
from 
(
  select x.sty_size_range || '' - '' || y.ancestor2 as rangecode, a.cc_validsizes_store_existing, a.cc_validsizes_ecom_existing, style_type, cc_msrp, cc_unit_retail, a.cc_ordpolicy_existing, a.cc_ordermultiple_existing, a.cc_existingwac_existing, 
        a.cc_systemcost_existing, a.cc_plan_cost_existing,a.cc_landed_cost_existing, a.cc_target_cost_existing
  from 
    trd_ma_styleattributes x, 
    trd_h_prodstd y, 
    trd_ma_stylecolorattributes d,
    (
      select distinct final_stylecolor_id, final_style_id, style_type 
      from  '||table_cart_master_temp||' 
      where jsessionid in (select jsid from  '||table_input_t1||') and style_type = ''existing''
    ) z,
    (
      select a.ancestor0, max(b.cc_validsizes_store) as cc_validsizes_store_existing, max(b.cc_validsizes_ecom) as cc_validsizes_ecom_existing, max(b.cc_ordpolicy) as cc_ordpolicy_existing, 
             max(b.cc_ordermultiple) as cc_ordermultiple_existing, max(b.cc_existingwac) as cc_existingwac_existing, max(b.cc_systemcost) as cc_systemcost_existing, max(b.cc_plan_cost) as cc_plan_cost_existing, 
             max(b.cc_landed_cost) as cc_landed_cost_existing, max(b.cc_target_cost) as cc_target_cost_existing
      from trd_h_prodstd a
      join trd_ma_stylecolorchannelattributes b
      on a.id = b.product
      where a.ancestor0 in (select distinct final_style_id from  '||table_cart_master_temp||')
      group by a.ancestor0 
    ) a
    where x.product = z.final_style_id 
    and y.id = z.final_stylecolor_id 
    and d.product = z.final_stylecolor_id
    and x.product = a.ancestor0
) b
where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
';
*/


s39 := '
    create temporary table '||table_temp_assort||' AS
    SELECT
        final_stylecolor_id as product
        , a.scope_location as location
        , a.scope_floorset as "time"
        , cast(str_grade as text[]) as str_grade
        , cast(str_store_climate as text[]) as str_store_climate
        , cast(str_capacity as text[]) as str_capacity
        , cast(str_store_banner as text[]) as str_store_banner
        , cast(str_geo_region as text[]) as str_geo_region
        , cast(str_hazmat as text[]) as str_hazmat
      --, cast(str_grade_or as text[]) as str_grade_or
      --, cast(str_store_climate_or as text[]) as str_store_climate_or
      --, cast(str_capacity_or as text[]) as str_capacity_or
      --, cast(str_store_banner_or as text[]) as str_store_banner_or
      --, cast(str_geo_region_or as text[]) as str_geo_region_or
      --, cast(str_hazmat_or as text[]) as str_hazmat_or
        , cast(ssg as text[]) as ssg
        , cast(flnrange as text[]) as flnrange
        , ''plan'' as plan_type
        , isfunded
        , final_style_id as style
        , store_count
    FROM
    (select distinct * from cart_ranging) a, '||table_input_t1||' b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||') c,
    trd_ma_stylecolorattributes d
    where a.jsessionid=c.jsessionid
    and a.jsessionid = b.jsid
    and a.scope_product = b.scope_product
    and a.scope_location = b.scope_location
    and a.scope_start = b.scope_start
    and c.final_stylecolor_id = d.product
    '
    ;

s39_test := 'insert into jrtest_S5391 select * from ' || table_temp_assort;

s40 := '
delete from trd_a_assortment where (product, location) in (select product,location from '||table_temp_assort||') and plan_type=''plan''
';

s41 := '

    insert into trd_a_assortment (
          product
        , location
        , "time"
        , str_grade
        , str_store_climate
        , str_capacity
        , str_store_banner
        , str_geo_region
        , str_hazmat
      --, str_grade_or
      --, str_store_climate_or
      --, str_capacity_or
      --, str_store_banner_or
      --, str_geo_region_or
      --, str_hazmat_or
        , ssg
        , flnrange
        , plan_type
        , isfunded
        , store_count
        , style)
    SELECT
          product
        , location
        , "time"
        , str_grade
        , str_store_climate
        , str_capacity
        , str_store_banner
        , str_geo_region
        , str_hazmat
      --, str_grade_or
      --, str_store_climate_or
      --, str_capacity_or
      --, str_store_banner_or
      --, str_geo_region_or
      --, str_hazmat_or
        , ssg
        , flnrange
        , plan_type
        , isfunded
        , store_count
        , style
    FROM
       '||table_temp_assort||'
';



RAISE NOTICE 'END Assortment Model:%', 'START:'|| now();

s42 := '
create temporary table '||table_final_list||' AS
select distinct a.product, a.location
from
(select distinct product,location  from trd_ma_stylecolorchannelattributes where (product, location) in (select distinct final_stylecolor_id,'''||$3||''' as prod_loc from '||table_cart_master_temp||')) a,
(select distinct product,location  from trd_a_assortment where (product, location) in (select distinct final_stylecolor_id, '''||$3||''' as prod_loc from '||table_cart_master_temp||')) b
where
a.product=b.product
and a.location=b.location
';



s43 := '
insert into plan_queue (product, location, initiator, initiated_at)
select final_stylecolor_id, '''||$3||''', initiator :: uuid, now() from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')
and (final_stylecolor_id, '''||$3||''') in (select product, location from '||table_final_list||')
';

s43_1 := 'select final_stylecolor_id product from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')
    and (final_stylecolor_id, '''||$3||''') in (select product, location from '||table_final_list||')';



s44 := 'update cart_master set isProcessed=1 where jsessionid in (select jsid from  '||table_input_t1||')';

s45 := 'insert into cart_master_archive select * from cart_master  where jsessionid in (select jsid from  '||table_input_t1||')';
s46 := 'insert into cart_params_archive select * from cart_params  where jsessionid in (select jsid from  '||table_input_t1||')';
s47 := 'insert into cart_ranging_archive select * from cart_ranging  where jsessionid in (select jsid from  '||table_input_t1||')';

s48 := 'delete from cart_master where jsessionid in (select jsid from  '||table_input_t1||')';
s49 := 'delete from cart_params where jsessionid in (select jsid from  '||table_input_t1||')';
s50 := 'delete from cart_ranging where jsessionid in (select jsid from  '||table_input_t1||')';
insert into debug_stats_ts values ('s1',s1,now());


s100 := 'CREATE TEMPORARY TABLE '||tst_df_temp||' AS
          SELECT
              product,
              COALESCE(relaunchweek,dbt_wk) as dbt_wk,
              last_rcpt_wk,
              erlstmkdnwk,
              exitdate,
              ccmdstrategy,
              cc_discount_pct,
              in_season_flag,
              id AS time,
              case when id < erlstmkdnwk then ''FP'' else ''MD'' end as price_status
          FROM trd_ma_stylecolorchannelattributes AS a
          , trd_d_time AS b
          WHERE (id >= COALESCE(relaunchweek,dbt_wk)) AND (id <= exitdate) AND product in (select product from '||table_temp_sclr_chnl_attr||')
          ORDER BY
              product ASC,
              id ASC
          ';

s101 := 'CREATE TEMPORARY TABLE '||tst_md_seq||' AS
          SELECT
              *,
              row_number() OVER (PARTITION BY product ORDER BY time ASC) AS seq
          FROM '||tst_df_temp||'
          WHERE price_status = ''MD''
          ';

s102 := 'CREATE TEMPORARY TABLE '||tst_df||' AS
          SELECT *
          FROM
          (
              SELECT
                  product,
                  dbt_wk,
                  last_rcpt_wk,
                  erlstmkdnwk,
                  exitdate,
                  time,
                  price_status,
                  0 AS seq,
                  ccmdstrategy,
                  cc_discount_pct,
                  in_season_flag
              FROM '||tst_df_temp||' AS a
              WHERE price_status = ''FP''
              UNION ALL
              SELECT
                  product,
                  dbt_wk,
                  last_rcpt_wk,
                  erlstmkdnwk,
                  exitdate,
                  time,
                  price_status,
                  seq,
                  ccmdstrategy,
                  cc_discount_pct,
                  in_season_flag
              FROM '||tst_md_seq||' AS b
              WHERE price_status = ''MD''
          ) AS x
          ORDER BY
              product ASC,
              time ASC,
              seq ASC
    ';

s103 := 'CREATE TEMPORARY TABLE '||tst_df_with_style||' AS
          SELECT
              a.*,
              b.ancestor0 AS style,
              ancestor1 AS subclass,
              ancestor3 as department
          FROM '||tst_df||' AS a
          ,
          (
              SELECT
                  id,
                  ancestor0,
                  ancestor1,
                  ancestor3
              FROM trd_h_prodstd
              WHERE id IN
              (
                  SELECT product
                  FROM '||tst_df||'
              )
          ) AS b
          WHERE a.product = b.id
          ';


s104 := 'CREATE TEMPORARY TABLE '||tst_md_tktp_md||' as
            select x.*
            , 0::real as ccticketprice
            , 0::real as md_disc
            , 0::real corpaddoff
            , 0::real corpexcl
            , 0::real addoff
            , null::real expressed_aur
            , 0::real curp
            , 0::real selling_price
            , 0::real v_A
            , 0::real v_B
            , null::text weekdate
            FROM
            (select a.* from '||tst_df_with_style||' a, trd_ma_styleattributes b where a.style=b.product) x
            ';

s104_a := 'update '||tst_md_tktp_md||' a
            set ccticketprice=b.cc_unit_retail::real, curp=cc_unit_retail::real
          from trd_ma_stylecolorattributes b
          where a.product = b.product
          ';

s105 := 'update '||tst_md_tktp_md||' a
            set md_disc=b.md_disc, curp=ccticketprice * (1 - b.md_disc)
          from md_strategy b
          where a.seq=b.seq and a.ccmdstrategy=b.mdstrategy
          and a.seq > 0
          ';

s106 := 'update '||tst_md_tktp_md||' a
            set corpaddoff=b.corpaddoff, corpexcl=b.corpexcl
          from trd_corpdisc b
          where a.subclass=b.product and a.time=b.time
          ';

s107 := 'update '||tst_md_tktp_md||' a
            set expressed_aur=b.eff_aur, addoff=b.addoff
          from trd_p_itemprice b
          where a.product=b.product and a.time=b.time
        ';

s108 := 'update '||tst_md_tktp_md||' a
            set v_A=b.v_A
          FROM
            (select product, time, seq, case when seq=0 then ccticketprice * (1-COALESCE(corpexcl,0)) else curp end as v_A from '||tst_md_tktp_md||') b
          WHERE a.product=b.product and a.time=b.time
          ';

s109 := 'update '||tst_md_tktp_md||' a
            set v_B=b.v_B
          FROM
            (select product, time, seq, addoff, corpaddoff
              , case when seq=0 then
                  (case when expressed_aur > 0 then expressed_aur else ccticketprice end) * (1 - coalesce(addoff,0)) * (1 - coalesce(corpaddoff,0))
               else curp end as v_B
               from '||tst_md_tktp_md||'
            ) b
          WHERE a.product=b.product and a.time=b.time
          ';

S_PRE_110_1 := 'CREATE TEMPORARY TABLE '||table_xt_flag||' AS
              select product, dbt_wk, last_rcpt_wk, b.indx as dbt_wk_indx, c.indx as last_rcpt_wk_indx from ( select distinct product, dbt_wk, last_rcpt_wk from '||tst_md_tktp_md||' ) a, trd_d_time b, trd_d_time c
              where a.dbt_wk=b.id and a.last_rcpt_wk=c.id
              ';


s110   := 'update '||tst_md_tktp_md||'    set selling_price=(least(v_A,v_B) * (1 - cc_discount_pct))::NUMERIC(16,2)';
s110_1 := 'update '||tst_md_tktp_md||'  a set dbt_wk=b.start_date from trd_ma_weekattributes b where a.dbt_wk=b.time';
s110_2 := 'update '||tst_md_tktp_md||'  a set last_rcpt_wk=b.start_date from trd_ma_weekattributes b where a.last_rcpt_wk=b.time';
s110_3 := 'update '||tst_md_tktp_md||'  a set erlstmkdnwk=b.start_date from trd_ma_weekattributes b where a.erlstmkdnwk=b.time';
s110_4 := 'update '||tst_md_tktp_md||'  a set exitdate=b.start_date from trd_ma_weekattributes b where a.exitdate=b.time';
s110_5 := 'update '||tst_md_tktp_md||'  a set weekdate=b.start_date from trd_ma_weekattributes b where a.time=b.time';


s111 := 'CREATE TEMPORARY TABLE '||table_xt||' AS
        select *,
            case when ''ECOM''=ANY(str_grade) then ''ECOM'' else ''STORE'' END as selling_channel
        FROM
        (
          SELECT
              x.*,
              y.id,
              y.indx
          FROM
          (
              SELECT
                  product,
                  location,
                  time AS floorset,
                  store_count,
                  str_grade,
                  isfunded,
                  ancestor3 AS department
              FROM (select * from trd_a_assortment where product in (select product from '||tst_md_tktp_md||')) AS a
              ,
              (
                  SELECT
                      id,
                      ancestor3
                  FROM trd_h_prodstd where id in (select product from '||tst_md_tktp_md||')
              ) AS b
              WHERE (a.product = b.id)
          ) AS x
          ,
          (
              SELECT
                  product AS department,
                  a.time AS floorset,
                  b.id,
                  b.indx
              FROM trd_ma_dptflrsetattributes AS a
              , trd_d_time AS b
              WHERE (b.id >= a.ap_start) AND (b.id <= a.ap_end)
          ) AS y
          WHERE (x.department = y.department) AND (x.floorset = y.floorset)
        ) z
        ';
/*
s112 := 'CREATE TEMPORARY TABLE '||table_yt||' AS
          select
          product
          , location
          , case when ch02 is null then 0 else 1 end as store_count
          , isfunded
          , id as time
          , indx
          , ch02 as selling_channel
          from '||table_xt||' where ch02 = ''CH-02''
          UNION ALL
          select
          product
          , location
          , case when ch01 is null then 0 else case when ch02 is null then store_count else store_count - 1 end end as store_count
          , isfunded
          , id as time
          , indx
          , ch01 as selling_channel
          from '||table_xt||' where ch01 = ''CH-01''
          UNION ALL
          select
          product
          , location
          , store_count
          , isfunded
          , id as time
          , indx
          , ch03 as selling_channel
          from '||table_xt||' where ch03 = ''CH-03''
        ';
*/
s113 := 'CREATE TEMPORARY TABLE '||table_zt_pre||' AS
          SELECT *
          FROM
          (
              SELECT
                  a.product,
                  a.location AS channel,
                  a.id as time,
                  a.indx,
                  a.selling_channel,
                  a.isfunded,
                  a.store_count,
                  b.in_season_flag,
                  b.dbt_wk,
                  b.last_rcpt_wk,
                  b.erlstmkdnwk,
                  b.exitdate,
                  b.weekdate,
                  b.price_status,
                  b.seq,
                  b.ccticketprice,
                  b.curp,
                  b.selling_price,
                  b.expressed_aur,
                  b.corpexcl,
                  b.addoff,
                  b.corpaddoff,
                  b.v_A,
                  b.v_B,
                  b.cc_discount_pct
              FROM '||table_xt||' AS a
              , '||tst_md_tktp_md||' AS b
              WHERE (a.product = b.product) AND (a.id = b.time)
          ) AS x
          WHERE time >= (select value from trd_serviceparams where id=''plan_current'')
          AND time <= (select value from trd_serviceparams where id=''plan_end'')
        ';

s113_1 := 'CREATE TEMPORARY TABLE '||table_zt_flow_flag||'
              AS
              SELECT a.product, a.selling_channel, a.time, a.indx, dbt_wk_indx, last_rcpt_wk_indx
              , CASE when (indx >= dbt_wk_indx and indx < (dbt_wk_indx + 4)) then ''NEW''
                  ELSE
                    CASE when (indx >= (dbt_wk_indx + 4) AND indx < (last_rcpt_wk_indx + 4)) then ''FLOW''
                      ELSE ''LOF''
                    END
                END as flow_flag
              from '||table_zt_pre||' a, '||table_xt_flag||' b
              WHERE a.product=b.product
              ';

s113_2 := 'CREATE TEMPORARY TABLE '||table_zt||'
           AS
           select a.*, flow_flag from '||table_zt_pre||' a, '||table_zt_flow_flag||' b
           WHERE a.product=b.product and a.selling_channel=b.selling_channel and a.time=b.time
           ';


s114 := 'delete from trd_an_price_storecount_info where (product,channel) in (select product, channel from '||table_zt||')';
s115 := 'insert into trd_an_price_storecount_info
          select
            product
            , channel
            , time
            , selling_channel
            , isfunded
            , store_count
            , in_season_flag
            , dbt_wk
            , last_rcpt_wk
            , erlstmkdnwk
            , exitdate
            , weekdate
            , price_status
            , seq
            , ccticketprice
            , curp
            , selling_price
            , expressed_aur
            , corpexcl
            , addoff
            , corpaddoff
            , v_A
            , v_B
            , cc_discount_pct
            , flow_flag
          from
          '||table_zt||'
          ';

/*
RAISE NOTICE 'INPUT:%', 'START:'|| now();
RAISE NOTICE 's1:%', s1;
RAISE NOTICE 's2:%', s2;
RAISE NOTICE 's3:%', s3;
RAISE NOTICE 's4_1:%', s4_1;
RAISE NOTICE 's5:%', s5;
RAISE NOTICE 's6:%', s6;
RAISE NOTICE 's7:%', s7;
RAISE NOTICE 's7_1:%', s7_1;


RAISE NOTICE 'Start Member Create:%', 'START:'|| now();

RAISE NOTICE 's8:%', s8;
RAISE NOTICE 's9: %', s9;
RAISE NOTICE 's10: %', s10;
RAISE NOTICE 's11: %', s11;
RAISE NOTICE 's12: %', s12;
RAISE NOTICE 's13: %', s13;
RAISE NOTICE 's14: %', s14;
RAISE NOTICE 's15: %', s15;
RAISE NOTICE 's16: %', s16;
RAISE NOTICE 's17: %', s17;
RAISE NOTICE 's18: %', s18;
RAISE NOTICE 's19: %', s19;


RAISE NOTICE 'Start Attribute Create:%', 'START:'|| now();
RAISE NOTICE 's20: %', s20;
RAISE NOTICE 's21: %', s21;
RAISE NOTICE 's21_x: %', s21_x;
RAISE NOTICE 's21_y: %', s21_y;
RAISE NOTICE 's22: %', s22;
RAISE NOTICE 's23: %', s23;
RAISE NOTICE 's24: %', s24;
RAISE NOTICE 's25: %', s25;
RAISE NOTICE 's26: %', s26;
RAISE NOTICE 's26_X: %', s26_X;
RAISE NOTICE 's27: %', s27;
RAISE NOTICE 's28: %', s28;
RAISE NOTICE 's28_X: %', s28_X;
RAISE NOTICE 's28_X1: %', s28_X1;
RAISE NOTICE 's28_X2: %', s28_X2;
RAISE NOTICE 's29: %', s29;
RAISE NOTICE 's29_1: %', s29_1;
RAISE NOTICE 's30: %', s30;
RAISE NOTICE 's31: %', s31;
RAISE NOTICE 's32: %', s32;
RAISE NOTICE 's33: %', s33;
RAISE NOTICE 's34: %', s34;
RAISE NOTICE 'Start Channel Attribute:%', 'START:'|| now();
RAISE NOTICE 's35: %', s35;
RAISE NOTICE 's36: %', s36;
RAISE NOTICE 's36_1: %', s36_1;
RAISE NOTICE 's37: %', s37;
RAISE NOTICE 's38: %', s38;

RAISE NOTICE 'Start Assortment Model:%', 'START:'|| now();
RAISE NOTICE 's51: %', s51;
RAISE NOTICE 's51_1: %', s51_1;
RAISE NOTICE 's39: %', s39;
RAISE NOTICE 's40: %', s40;
RAISE NOTICE 's41: %', s41;

RAISE NOTICE 'END Assortment Model:%', 'START:'|| now();
RAISE NOTICE 's42: %', s42;
RAISE NOTICE 's43: %', s43;
RAISE NOTICE 's44: %', s44;
RAISE NOTICE 's45: %', s45;
RAISE NOTICE 's46: %', s46;
RAISE NOTICE 's47: %', s47;
RAISE NOTICE 's48: %', s48;
RAISE NOTICE 's49: %', s49;
RAISE NOTICE 's50: %', s50;
*/

-- s110_6 :=  'drop table if exists tst_md_tktp_md';
-- s110_7 :=  'create table tst_md_tktp_md as select * from '||tst_md_tktp_md||'';
-- s110_8 :=  'drop table if exists table_zt';
-- s110_9 :=  'create table table_zt as select * from '||table_zt||'';
-- insert into trigger_test_delete_me values ('s0:', clock_timestamp());
EXECUTE s8;
-- insert into trigger_test_delete_me values ('s8:', clock_timestamp());
EXECUTE s9;
-- insert into trigger_test_delete_me values ('s9:', clock_timestamp());
EXECUTE s10;
-- insert into trigger_test_delete_me values ('s10:', clock_timestamp());
EXECUTE s11;
-- insert into trigger_test_delete_me values ('s11:', clock_timestamp());
EXECUTE s13;
-- insert into trigger_test_delete_me values ('s13:', clock_timestamp());
EXECUTE s14;
-- insert into trigger_test_delete_me values ('s14:', clock_timestamp());
EXECUTE s15;
-- insert into trigger_test_delete_me values ('s15:', clock_timestamp());
EXECUTE s16;
-- insert into trigger_test_delete_me values ('s16:', clock_timestamp());
EXECUTE s17;
-- insert into trigger_test_delete_me values ('s17:', clock_timestamp());
EXECUTE s19;
-- insert into trigger_test_delete_me values ('s19:', clock_timestamp());
EXECUTE s20;
-- insert into trigger_test_delete_me values ('s20:', clock_timestamp());
EXECUTE s21;
-- insert into trigger_test_delete_me values ('s21:', clock_timestamp());
EXECUTE s21_x;
-- insert into trigger_test_delete_me values ('s21_x:', clock_timestamp());
EXECUTE s21_y;
-- insert into trigger_test_delete_me values ('s21_y:', clock_timestamp());
EXECUTE s22;
-- insert into trigger_test_delete_me values ('s22:', clock_timestamp());
EXECUTE s23;
-- insert into trigger_test_delete_me values ('s23:', clock_timestamp());
EXECUTE s24;
-- insert into trigger_test_delete_me values ('s24:', clock_timestamp());
EXECUTE s25;
-- insert into trigger_test_delete_me values ('s25:', clock_timestamp());
EXECUTE s26;
-- insert into trigger_test_delete_me values ('s26:', clock_timestamp());
EXECUTE s26_X;
-- insert into trigger_test_delete_me values ('s26_X:', clock_timestamp());
EXECUTE s27;
-- insert into trigger_test_delete_me values ('s27:', clock_timestamp());
EXECUTE s28;
-- insert into trigger_test_delete_me values ('s28:', clock_timestamp());
EXECUTE s28_X;
-- insert into trigger_test_delete_me values ('s28_X:', clock_timestamp());
EXECUTE s28_X1;
-- insert into trigger_test_delete_me values ('s28_X1:', clock_timestamp());
EXECUTE s28_X2;
-- insert into trigger_test_delete_me values ('s28_X2:', clock_timestamp());
EXECUTE s29;
-- insert into trigger_test_delete_me values ('s29:', clock_timestamp());
EXECUTE s29_1;
-- insert into trigger_test_delete_me values ('s29_1:', clock_timestamp());
EXECUTE s30;
-- insert into trigger_test_delete_me values ('s30:', clock_timestamp());
EXECUTE s31;
-- insert into trigger_test_delete_me values ('s31:', clock_timestamp());
EXECUTE s32;
-- insert into trigger_test_delete_me values ('s32:', clock_timestamp());
EXECUTE s33;
-- insert into trigger_test_delete_me values ('s33:', clock_timestamp());
EXECUTE s34;
-- insert into trigger_test_delete_me values ('s34:', clock_timestamp());
EXECUTE s35;
-- insert into trigger_test_delete_me values ('s35:', clock_timestamp());
EXECUTE s36;
-- insert into trigger_test_delete_me values ('s36:', clock_timestamp());
EXECUTE s36_1;
-- insert into trigger_test_delete_me values ('s36_1:', clock_timestamp());
EXECUTE s37;
-- insert into trigger_test_delete_me values ('s37:', clock_timestamp());
EXECUTE s38;
-- insert into trigger_test_delete_me values ('s38:', clock_timestamp());
EXECUTE s51;
-- insert into trigger_test_delete_me values ('s51:', clock_timestamp());
--EXECUTE s51_1;
-- insert into trigger_test_delete_me values ('s51_1:', clock_timestamp());
EXECUTE s39;
-- insert into trigger_test_delete_me values ('s39:', clock_timestamp());
--EXECUTE s39_test;
-- insert into trigger_test_delete_me values ('s39_test:', clock_timestamp());
EXECUTE s40;
-- insert into trigger_test_delete_me values ('s40:', clock_timestamp());
EXECUTE s41;
-- insert into trigger_test_delete_me values ('s41:', clock_timestamp());
EXECUTE s42;
-- insert into trigger_test_delete_me values ('s42:', clock_timestamp());
EXECUTE s43;
-- insert into trigger_test_delete_me values ('s43:', clock_timestamp());
EXECUTE s44;
-- insert into trigger_test_delete_me values ('s44:', clock_timestamp());
EXECUTE s45;
-- insert into trigger_test_delete_me values ('s45:', clock_timestamp());
EXECUTE s46;
-- insert into trigger_test_delete_me values ('s46:', clock_timestamp());
EXECUTE s47;
-- insert into trigger_test_delete_me values ('s47:', clock_timestamp());
EXECUTE s48;
-- insert into trigger_test_delete_me values ('s48:', clock_timestamp());
EXECUTE s49;
-- insert into trigger_test_delete_me values ('s49:', clock_timestamp());
EXECUTE s50;
-- insert into trigger_test_delete_me values ('s50:', clock_timestamp());
EXECUTE s100 ;
-- insert into trigger_test_delete_me values ('s100:', clock_timestamp());
EXECUTE s101 ;
-- insert into trigger_test_delete_me values ('s101:', clock_timestamp());
EXECUTE s102 ;
-- insert into trigger_test_delete_me values ('s102:', clock_timestamp());
EXECUTE s103 ;
-- insert into trigger_test_delete_me values ('s103:', clock_timestamp());
EXECUTE s104 ;
-- insert into trigger_test_delete_me values ('s104:', clock_timestamp());
EXECUTE s104_a ;
-- insert into trigger_test_delete_me values ('s104_a:', clock_timestamp());
EXECUTE s105 ;
-- insert into trigger_test_delete_me values ('s105:', clock_timestamp());
EXECUTE s106 ;
-- insert into trigger_test_delete_me values ('s106:', clock_timestamp());
EXECUTE s107 ;
-- insert into trigger_test_delete_me values ('s107:', clock_timestamp());
EXECUTE s108 ;
-- insert into trigger_test_delete_me values ('s108:', clock_timestamp());
EXECUTE s109 ;
-- insert into trigger_test_delete_me values ('s109:', clock_timestamp());
EXECUTE s_pre_110_1;
-- insert into trigger_test_delete_me values ('s_pre_110_1:', clock_timestamp());
EXECUTE s110 ;
-- insert into trigger_test_delete_me values ('s110:', clock_timestamp());
EXECUTE s110_1;
-- insert into trigger_test_delete_me values ('s110_1:', clock_timestamp());
EXECUTE s110_2;
-- insert into trigger_test_delete_me values ('s110_2:', clock_timestamp());
EXECUTE s110_3;
-- insert into trigger_test_delete_me values ('s110_3:', clock_timestamp());
EXECUTE s110_4;
-- insert into trigger_test_delete_me values ('s110_4:', clock_timestamp());
EXECUTE s110_5;
-- insert into trigger_test_delete_me values ('s110_5:', clock_timestamp());
EXECUTE s111 ;
-- insert into trigger_test_delete_me values ('s111:', clock_timestamp());
--EXECUTE s112 ;
-- insert into trigger_test_delete_me values ('s112:', clock_timestamp());
EXECUTE s113 ;
-- insert into trigger_test_delete_me values ('s113:', clock_timestamp());
EXECUTE s113_1 ;
-- insert into trigger_test_delete_me values ('s113_1:', clock_timestamp());
EXECUTE s113_2 ;
-- insert into trigger_test_delete_me values ('s113_2:', clock_timestamp());
EXECUTE s114 ;
-- insert into trigger_test_delete_me values ('s114:', clock_timestamp());
EXECUTE s115 ;
-- insert into trigger_test_delete_me values ('s115:', clock_timestamp());
OPEN added_prods FOR EXECUTE s43_1;

RAISE NOTICE 'Marked Cart as isProcessed:%', 'START:'|| now();


 RETURN added_prods;

END;
$_$;


--
-- Name: after_add_to_assortment(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.after_add_to_assortment(input_jsessionid text, scope_product text, scope_location text, scope_start text, scope_floorset text) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
r refcursor;
BEGIN
  OPEN r FOR SELECT "jobid FROM plan_queue LIMIT 1";
 RETURN r;

END;
$$;


--
-- Name: ata_add_to_assortment(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.ata_add_to_assortment(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
v_session_id    TEXT := p_session_id;
v_pivot_user_id TEXT := p_pivot_user_id;
v_jsessionid text;
v_scope_product text;
v_scope_location text;
v_scope_start text;
v_scope_floorset text;
s1 text;
s2 text;
s3 text;
s4_1 text;
s4_2 text;
s4_3 text;
s4_4 text;
s5 text;
s6 text;
s7 text;
s7_1 text;
s8 text;
s9 text;
s10 text;
s11 text;
s12 text;
s13 text;
s14 text;
s15 text;
s16 text;
s17 text;
s18 text;
s19 text;
s20 text;
s21 text;
s21_x text;
s21_y text;
s22 text;
s23 text;
s24 text;
s25 text;
s26 text;
s26_X text;
s27 text;
s28 text;
s28_1 text;
s28_X text;
s28_X1 text;
s28_X2 text;
s28_Y text;
s29 text;
s29_1 text;
s30 text;
s31 text;
s32 text;
s33 text;
s34 text;
s35 text;
s36 text;
s36_1 text;
s37 text;
s38 text;
s39 text;
s39_test text;
s40 text;
s41 text;
s41_1 text;
s42 text;
s43 text;
s43_1 text;
s44 text;
s45 text;
s46 text;
s47 text;
s48 text;
s49 text;
s50 text;
s51 text;
s51_1 text;
added_prods refcursor;

v_uuid_temp text;
v_uuid text;
table_input_t1 text;
table_cart_master_temp text;
table_cart_style text;
table_cart_stylecolorsize text;
table_cart_stylecolor text;
table_default_cart_params text;
table_temp_sclr_chnl_attr text;
table_ma_imgattr text;
table_temp_assort text;
table_final_list text;
table_spec_img text;

s100 text;
s101 text;
s102 text;
s103 text;
s104 text;
s104_a text;
s105 text;
s106 text;
s107 text;
s108 text;
s109 text;
s110 text;
s111 text;
s112 text;
s113 text;
s114 text;
s115 text;
s110_1 text;
s110_2 text;
s110_3 text;
s110_4 text;
s110_5 text;

s113_1 text;
s113_2 text;

tst_df_temp text;
tst_md_seq text;
tst_df text;
tst_df_with_style text;
tst_md_tktp_md text;

table_xt text;
table_yt text;
table_zt text;

table_xt_flag text;
table_zt_flow_flag text;
table_zt_pre text;
s_pre_110_1 text;
s113_post text;

s001_x text;
s002_x text;
s003_x text;
s004_x text;
s005_x text;
s006_x text;
s007_x text;
s008_x text;
s009_x text;
s010_x text;
v_already_ata integer;

BEGIN



EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;

table_input_t1 := 'input_t1'||v_uuid;
table_cart_master_temp := 'cart_master_temp'||v_uuid;
table_cart_style := 'cart_style'||v_uuid;
table_cart_stylecolorsize := 'cart_stylecolorsize'||v_uuid;
table_cart_stylecolor := 'cart_stylecolor'||v_uuid;
table_default_cart_params := 'default_cart_params'||v_uuid;
table_temp_sclr_chnl_attr := 'temp_sclr_chnl_attr'||v_uuid;
table_spec_img := 'temp_space_img'||v_uuid;
table_ma_imgattr := 'table_ma_imgattr'||v_uuid;
table_temp_assort := 'table_temp_assort'||v_uuid;
table_final_list := 'table_final_list'||v_uuid;


tst_df_temp := 'tst_df_temp'||v_uuid;
tst_md_seq := 'tst_md_seq'||v_uuid;
tst_df := 'tst_df'||v_uuid;
tst_df_with_style := 'tst_df_with_style'||v_uuid;
tst_md_tktp_md := 'tst_md_tktp_md'||v_uuid;

table_xt := 'table_xt'||v_uuid;
table_yt := 'table_yt'||v_uuid;
table_zt := 'table_zt'||v_uuid;

table_xt_flag := 'table_xt_flag'||v_uuid;
table_zt_flow_flag := 'table_zt_flow_flag'||v_uuid;
table_zt_pre  := 'table_zt_pre'||v_uuid;

RAISE NOTICE 'v_session_id:%', v_session_id;
RAISE NOTICE 'v_pivot_user_id:%', v_pivot_user_id;

s1 := 'create temporary table '||table_input_t1||' as 
select a.*, b.*,
department as scope_product,''CH-2'' as scope_location ,ap_start as scope_start
from ata_cart_master a, trd_ma_dptflrsetattributes b
where jsessionid = '''||v_session_id||''' and  initiator = '''||v_pivot_user_id||'''
and department = b.product and scope_floorset = b.time
';

RAISE NOTICE 's1:%', s1;
-- delete from debug_stats_ts where stat_id='s1';

s2 := '
    create temporary table '||table_cart_master_temp||' as
    select
    distinct
    jsessionid
    ,  style_sequence
    ,  style_id as incoming_style_id
    ,  style_name
    ,  style_description
    ,  style_type
    ,  cccolor
    ,  stylecolor_id as incoming_stylecolor_id
    ,  stylecolor_type
    ,  stylecolor_name
    ,  stylecolor_description
    ,  null::text final_style_id
    ,  new_stylecolor_id final_stylecolor_id
    ,  initiator
    ,  null::text as cccolorfamily
    ,  null::text as cccolorid
    ,  null::text as color_description
    ,  img
    ,  job_priority
    ,  null::text class_id
    ,  null::text subclass_id
    ,  null::text class_name
    ,  null::text subclass_name
    from ata_cart_master
    where
    jsessionid in (select jsessionid from '||table_input_t1||')
    and isProcessed=0
    '
    ;

s3 := '
    create temporary table '||table_cart_style||' as
    select distinct jsessionid
    , style_sequence
    , uuid_generate_v4()::text as final_style_id
    , incoming_style_id
    , style_type
    , style_name  as displayed_style_name
    , style_description  as displayed_style_description
    from
    (
    select distinct jsessionid, style_sequence, style_type, incoming_style_id, style_name, style_description, final_style_id from '||table_cart_master_temp||'
    where jsessionid in (select jsessionid from '||table_input_t1||')
    ) x
    ';


s4_1 := '
    Update '||table_cart_master_temp||' a
    set final_style_id = b.final_style_id
    from '||table_cart_style||' b
    where
    a.incoming_style_id=b.incoming_style_id
    and a.style_type=b.style_type
    and a.jsessionid=b.jsessionid
    and a.style_sequence=b.style_sequence
    and a.jsessionid in (select jsessionid from '||table_input_t1||')
    ';



s4_2 := '
    Update '||table_cart_master_temp||' a
    set class_id = b.ancestor1,
        subclass_id = b.ancestor0
    from trd_h_prodstd b
    where
    b.id = a.incoming_style_id
    ';



s4_3 := '
    Update '||table_cart_master_temp||' a
    set class_name = b.name
    from trd_d_product b
    where
    b.id = a.class_id
    ';



s4_4 := '
    Update '||table_cart_master_temp||' a
    set subclass_name = b.name
    from trd_d_product b
    where
    b.id = a.subclass_id
    ';



s5 := '
    create temporary table '||table_cart_stylecolor||' as
    select distinct
      jsessionid
    , style_sequence
    , final_stylecolor_id
    , incoming_stylecolor_id
    , stylecolor_type
    , case when stylecolor_type = ''similar'' then style_name||'' ''||color_description else stylecolor_name end as displayed_stylecolor_name
    , case when stylecolor_type = ''similar'' then style_description ||'' ''||color_description else stylecolor_description end as displayed_stylecolor_description
    , incoming_style_id
    , style_type
    , cccolor
    from
    (
    select distinct jsessionid,style_sequence, incoming_style_id,final_style_id, style_type,incoming_stylecolor_id, stylecolor_type, a.cccolor
    , style_name, style_description, stylecolor_name, stylecolor_description, b.color_description, final_stylecolor_id
    from '||table_cart_master_temp||' a, (select lookup_value as cccolor, target_value color_description from trd_l_dependencylookup where target_id = ''color_description'' and lookup_id = ''cccolor'') b
    where jsessionid in (select jsessionid from '||table_input_t1||') and a.cccolor = b.cccolor
    ) x
    '
    ;


s6 := '
    Update '||table_cart_master_temp||' a set
    final_stylecolor_id = b.final_stylecolor_id
    , stylecolor_name = displayed_stylecolor_name
    , stylecolor_description = displayed_stylecolor_description
    from '||table_cart_stylecolor||' b
    where
    a.incoming_stylecolor_id=b.incoming_stylecolor_id
    and a.cccolor = b.cccolor
    and a.incoming_style_id=b.incoming_style_id
    and a.style_type=b.style_type
    and a.stylecolor_type=b.stylecolor_type
    and a.jsessionid=b.jsessionid
    and a.style_sequence=b.style_sequence
    and a.jsessionid in (select jsessionid from '||table_input_t1||')
    '
    ;



s7 := '
    CREATE temporary TABLE '||table_cart_stylecolorsize||' AS
    SELECT
           case when stylecolor_type=''similar'' then uuid_generate_v4()::text else stylecolorsize_id end AS final_stylecolorsize_id
         , sizeattribute    AS size_name
         , sizeattribute    AS size_description
         , incoming_stylecolor_id
         , incoming_style_id
         , final_style_id
         , final_stylecolor_id
         , stylecolor_type
         , jsessionid
         , item_diff_2
         , item_diff_3
         , isvalid
    FROM   (SELECT
           a.incoming_stylecolor_id
           , a.incoming_style_id
           , uuid_generate_v4()::text stylecolorsize_id
           , parent_size as item_diff_2
           , size_id as item_diff_3
           , target_value as sizeattribute
           , 1 as isvalid
           , a.jsessionid
           , a.style_type
           , a.stylecolor_type
           , a.final_style_id
           , a.final_stylecolor_id
          FROM   '||table_cart_master_temp||' a
                 , trd_ma_styleattributes c
                 , trd_l_dependencylookup d
                 , trd_size_range_mapping e
          WHERE  c.product = a.incoming_style_id
            and d.lookup_value = e.size_range and d.target_value = e.size_desc
            and lookup_id = ''size_range'' and lookup_value = c.sty_size_range
            and stylecolor_type=''similar''
          )x
          '
          ;

s7_1 := '
    insert into '||table_cart_stylecolorsize||'
    SELECT
           case when stylecolor_type=''similar'' then uuid_generate_v4()::text else stylecolorsize_id end AS final_stylecolorsize_id
         , sizeattribute    AS size_name
         , sizeattribute    AS size_description
         , incoming_stylecolor_id
         , incoming_style_id
         , final_style_id
         , final_stylecolor_id
         , stylecolor_type
         , jsessionid
         , item_diff_2
         , item_diff_3
         , isvalid
    FROM   (SELECT
           a.incoming_stylecolor_id
           , a.incoming_style_id
           , b.product stylecolorsize_id
           , b.parent_id
           , item_diff_2
           , item_diff_3
           , b.sizeattribute
           , b.isvalid
           , a.jsessionid
           , a.style_type
           , a.stylecolor_type
           , a.final_style_id
           , a.final_stylecolor_id
          FROM   '||table_cart_master_temp||' a
                 , trd_ma_sizeattributes b
          WHERE  a.incoming_stylecolor_id = b.parent_id
          and stylecolor_type=''existing''
          )x
          '
          ;

EXECUTE s1;
-- insert into trigger_test_delete_me values ('s1:', clock_timestamp());
EXECUTE s2;
-- insert into trigger_test_delete_me values ('s2:', clock_timestamp());
EXECUTE s3;
-- insert into trigger_test_delete_me values ('s3:', clock_timestamp());
EXECUTE s4_1;
-- insert into trigger_test_delete_me values ('s4_1:', clock_timestamp());
EXECUTE s5;
-- insert into trigger_test_delete_me values ('s5:', clock_timestamp());
EXECUTE s6;
-- insert into trigger_test_delete_me values ('s6:', clock_timestamp());
EXECUTE s7;
-- insert into trigger_test_delete_me values ('s7:', clock_timestamp());
EXECUTE s7_1;
-- insert into trigger_test_delete_me values ('s7_1:', clock_timestamp());

-- Check if the product is already in assortment. If yes then return

execute '
select count(*)
from (
select distinct a.product, a.location
from
(select distinct product,location  from trd_ma_stylecolorchannelattributes where record_state = 0 and (product, location) in (select distinct final_stylecolor_id,''CH-2'' as prod_loc from '||table_cart_master_temp||')) a,
(select distinct product,location  from trd_a_assortment where (product, location) in (select distinct final_stylecolor_id, ''CH-2'' as prod_loc from '||table_cart_master_temp||')) b
where
a.product=b.product
and a.location=b.location
)x
' into v_already_ata;

if v_already_ata > 0 then
  s002_x := '
  insert into plan_queue (product, location, initiator, initiated_at)
  select final_stylecolor_id, ''CH-2'', initiator :: uuid, now() from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')
  ';
  EXECUTE s002_x;
  s003_x := 'select final_stylecolor_id product from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')';
  
  s004_x := 'update ata_cart_master set isProcessed=1 where jsessionid in (select jsessionid from  '||table_input_t1||')';
  EXECUTE s004_x;
  s005_x := 'insert into ata_cart_master_archive select *, now() from ata_cart_master  where jsessionid in (select jsessionid from  '||table_input_t1||')';
  --s006_x := 'insert into ata_cart_params_archive select *, now() from ata_cart_params  where jsessionid in (select jsessionid from  '||table_input_t1||')';
  --s007_x := 'insert into ata_cart_ranging_archive select *, now() from ata_cart_ranging  where jsessionid in (select jsessionid from  '||table_input_t1||')';
  EXECUTE s005_x;
  --EXECUTE s006_x;
  --EXECUTE s007_x;
  s008_x := 'delete from ata_cart_master where jsessionid in (select jsessionid from  '||table_input_t1||')';
  --s009_x := 'delete from ata_cart_params where jsessionid in (select jsessionid from  '||table_input_t1||')';
  --s010_x := 'delete from ata_cart_ranging where jsessionid in (select jsessionid from  '||table_input_t1||')';
  EXECUTE s008_x;
  --EXECUTE s009_x;
  --EXECUTE s010_x;
  
  RAISE NOTICE 'Marked Cart as isProcessed:%', 'START:'|| now();

end if;

execute '
select distinct jsessionid, scope_product,scope_location ,scope_start,scope_floorset
from '||table_input_t1||'
'
into v_jsessionid, v_scope_product, v_scope_location, v_scope_start, v_scope_floorset;

PERFORM ata_get_default_params(v_jsessionid, v_scope_product, v_scope_location, v_scope_start, v_scope_floorset);


s8 := 'delete from trd_d_product where id in (select final_style_id from '||table_cart_style||' WHERE style_type=''similar'' and jsessionid in (select jsessionid from '||table_input_t1||'))';


s9 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_style_id AS id
       , displayed_style_name AS NAME
       , displayed_style_description AS description
       , ''style'' AS levelid
    FROM   '||table_cart_style||'
    WHERE style_type=''similar''
    ';



s10 := '
delete from trd_d_product where id in (select distinct final_stylecolor_id from '||table_cart_stylecolor||' WHERE stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';


s11 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_stylecolor_id              AS id
           , displayed_stylecolor_name        AS NAME
           , displayed_stylecolor_description AS description
           , ''stylecolor''             AS levelid
    FROM '||table_cart_stylecolor||'
    WHERE stylecolor_type=''similar''
    '
    ;




s12 := '
delete from trd_d_product where id in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' WHERE stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

s13 := '
    INSERT INTO trd_d_product
            (id
             , NAME
             , description
             , levelid)
    SELECT final_stylecolorsize_id            AS id
           , size_name        AS NAME
           , size_description AS description
           , ''stylecolorsize'' AS levelid
    FROM   '||table_cart_stylecolorsize||'
    WHERE stylecolor_type=''similar''
    '
    ;



-- CREATING HIERARCHY

s14 := '
delete from trd_h_prodstd where id in (select distinct final_style_id from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

s15 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_style_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
                , ancestor7
FROM   '||table_cart_master_temp||' a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 , ancestor7 from trd_h_prodstd) b
WHERE style_type=''similar''
and a.incoming_style_id = b.id
'
;



s16 := '
delete from trd_h_prodstd where id in (select distinct final_stylecolor_id from '||table_cart_master_temp||'  where stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

s17 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_stylecolor_id
                , final_style_id
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
                , ancestor7
FROM   '||table_cart_master_temp||'   a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 , ancestor7 from trd_h_prodstd) b
WHERE stylecolor_type=''similar''
and a.incoming_stylecolor_id = b.id
'
;



s18 := '
delete from trd_h_prodstd where id in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' where stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

s19 := '
INSERT INTO trd_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6
             , ancestor7)
SELECT DISTINCT
                  final_stylecolorsize_id
                , final_stylecolor_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
FROM    '||table_cart_stylecolorsize||'  a,
trd_h_prodstd b
WHERE stylecolor_type=''similar''
and a.final_stylecolor_id = b.id
'
;

s20 := '
delete from trd_ma_styleattributes where product in (select distinct final_style_id from '||table_cart_master_temp||' WHERE style_type = ''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

-- updating cccolor and cccolorfamily

s21 := '
update '||table_cart_master_temp||' a set cccolorfamily = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''cccolorfamily'' and lookup_value=a.cccolor
';

s21_x := '
update '||table_cart_master_temp||' a set cccolorid = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''color_code'' and lookup_value=a.cccolor
';

s21_y := '
update '||table_cart_master_temp||' a set color_description = b.target_value from trd_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''color_description'' and lookup_value=a.cccolor
';


s22 := '
delete from trd_l_dependencylookup where target_id=''patternedtostyle'' and target_value in (select distinct final_style_id from  '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';

s23 := '
delete from trd_l_dependencylookup where target_id=''patternedtostylecolor'' and target_value in (select distinct final_stylecolor_id from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';





s24 := '
insert into trd_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''style'' as lookup_id, incoming_style_id as lookup_value, ''patternedtostyle'' target_id, final_style_id as target_value
from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||')
';


s25 := '
insert into trd_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''stylecolor'' as lookup_id, incoming_stylecolor_id as lookup_value, ''patternedtostylecolor'' target_id, final_stylecolor_id as target_value
from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||')
';


-- STYLE ATTRIBUTES

S26 := '
INSERT INTO trd_ma_styleattributes
            (product      
            ,sty_knit_or_woven
            ,sty_fabrication
            ,sty_sleeve_length
            ,sty_leg_opening
            ,sty_brand
            ,sty_body_style_silhouette
            ,sty_occasion_usage
            ,sty_detail
            ,sty_finish_style
            ,sty_private_label
            ,sty_license
            ,sty_license_vs_non_licensed
            ,sty_hazmat_code
            ,sty_prop_65_warning
            ,sty_material_content
            ,sty_item_type
            ,sty_dwrise
            ,sty_length
            ,sty_neckline
            ,sty_toeshape
            ,sty_heel_height
            ,sty_bottom_length
            ,sty_v_360_smoothing
            ,sty_franchise
            ,sty_key_item
            ,sty_single_vs_multi_pack
            ,sty_ticket_type
            ,sty_vpn
            ,sty_size_range
            ,ccstylecreatedate
            ,sty_is_locked
            ,sty_s5_adopted
            ,sty_patterned_after 
        ,sty_knit_fit -- Added by CA ON 03.18.2025
            )
SELECT final_style_id as product
        ,sty_knit_or_woven
            , null as sty_fabrication
        ,sty_sleeve_length
        ,sty_leg_opening
        ,sty_brand
        ,sty_body_style_silhouette
            , null as sty_occasion_usage
            , null as sty_detail
            , null as sty_finish_style
        ,sty_private_label
            , null as sty_license
        ,sty_license_vs_non_licensed
            , null as sty_hazmat_code
            , null as sty_prop_65_warning
            , null as sty_material_content
            , null as sty_item_type
        ,sty_dwrise
        ,sty_length
        ,sty_neckline
            , null as sty_toeshape
        ,sty_heel_height
            , null as sty_bottom_length
            , null as sty_v_360_smoothing
            , null as sty_franchise
            , null as sty_key_item
        ,sty_single_vs_multi_pack
            , null as sty_ticket_type
            , null as sty_vpn
        ,sty_size_range
            , null as ccstylecreatedate
            , null as sty_is_locked
            ,''Y''
            , a.incoming_style_id

        -- new add on 03.18.2025 CA
        , sty_knit_fit
from (select distinct final_style_id, style_type, incoming_style_id, class_id, subclass_id, class_name, subclass_name from '||table_cart_master_temp||') a, trd_ma_styleattributes b
where a.incoming_style_id=b.product
and a.style_type=''similar''
';


s26_X := '
Update trd_ma_styleattributes b
set plm_size_range = sty_size_range, sty_is_locked = ''Y'', sty_s5_adopted = ''Y''
from (select distinct final_style_id, style_type, stylecolor_type, incoming_style_id  from '||table_cart_master_temp||') a
where a.incoming_style_id=b.product
and a.style_type=''existing'' and a.stylecolor_type=''existing''
';


-- STYLECOLOR ATTRIBUTES

s27 := '
delete from trd_ma_stylecolorattributes where product in (select distinct final_stylecolor_id from '||table_cart_master_temp||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))';



s28 := '
INSERT INTO trd_ma_stylecolorattributes
        (product
         ,cc_item_diff_1
         ,cc_unit_retail
         ,cc_unit_retail_cad
         ,cc_pattern
         ,cc_graphic
         ,cc_fashion_basic
         ,cc_holiday
         ,cc_property_type
         ,cc_internet_exclusive
         ,cc_web_color_discription
         ,cc_export_hts
         ,cc_commercial_invoice_description
         ,cc_season_code
         ,cc_dtr
         ,cc_dw_color_family
         ,cc_channel_reorder
         ,cc_ticket_season_code
         ,cc_sub_programs
         ,cc_music_genre
         ,cc_clearance_str_product
         ,cc_po_supplier
         ,cc_origin_country_id
         ,cc_country_of_sourcing
         ,cc_country_of_manufacturing
         ,cc_unit_cost
         ,cc_freight
         ,cc_royalty
         ,cc_duty
         ,cc_ship_method
         ,cc_lading_port
         ,cc_hts
         ,cc_primary_supplier
         ,cc_sub_brand
         ,cc_pattern_type
         ,cc_pop_print_neutral
         ,cc_debut_season_code
         ,cc_matchback
         ,cc_primary_collection
         ,cc_secondary_collection
         ,cc_vpn_color
                  ,cc_orig_unit_retail
         ,cc_orig_unit_retail_cad
         ,cc_first_rec_week
         ,cc_first_inv_week
         ,cc_first_sale_week
         ,cc_first_md_week
         ,cc_last_md_week
         ,cc_last_rec_week
         ,cc_store_price_status
         ,cc_ifc_price_status
         ,cc_omni_price_type
         ,ccstylecolorcreatedate
         ,cc_price_band
         ,cc_good_better_best
         ,cccolor
         ,cccolorfamily
         ,total_brand_name
         ,division_name
         ,group_name
         ,department_name
         ,class_name
         ,subclass_name
         ,cc_s5_adopted
         ,cccolorid
         ,cc_patterned_after
         ,stylecolor_name
         ,style_name
        )
SELECT final_stylecolor_id as product
               , null as cc_item_diff_1
         , b.cc_unit_retail
         , b.cc_unit_retail_cad
               , null as cc_pattern
               , null as cc_graphic
               , null as cc_fashion_basic
               , null as cc_holiday
               , null as cc_property_type
               , null as cc_internet_exclusive
         , a.color_description
               , null as cc_export_hts
               , null as cc_commercial_invoice_description
               , null as cc_season_code
               , null as cc_dtr
          , a.cccolorfamily as cc_dw_color_family
               , null as cc_channel_reorder
               , null as cc_ticket_season_code
               , null as cc_sub_programs
               , null as cc_music_genre
               , null as cc_clearance_str_product
               , null as cc_po_supplier
               , null as cc_origin_country_id
               , null as cc_country_of_sourcing
               , null as cc_country_of_manufacturing
               , null as cc_unit_cost
               , null as cc_freight
               , null as cc_royalty
               , null as cc_duty
               , null as cc_ship_method
               , null as cc_lading_port
               , null as cc_hts
               , null as cc_primary_supplier
          , b.cc_sub_brand
               , null as cc_pattern_type
               , null as cc_pop_print_neutral
               , null as cc_debut_season_code
               , null as cc_matchback
               , null as cc_primary_collection
               , null as cc_secondary_collection
               , null as cc_vpn_color
          , b.cc_orig_unit_retail
          , b.cc_orig_unit_retail_cad
               , null as cc_first_rec_week
               , null as cc_first_inv_week
               , null as cc_first_sale_week
               , null as cc_first_md_week
               , null as cc_last_md_week
               , null as cc_last_rec_week
               , null as cc_store_price_status
               , null as cc_ifc_price_status
               , null as cc_omni_price_type
               , null as ccstylecolorcreatedate
          , b.cc_price_band
          , b.cc_good_better_best
          , a.cccolor
          , a.cccolorfamily

         , b.total_brand_name
         , b.division_name
         , b.group_name
         , b.department_name
         , b.class_name
         , b.subclass_name
         , ''Y'' as cc_s5_adopted
         , a.cccolorid
         , a.incoming_stylecolor_id
         , a.stylecolor_name
         , a.style_name

from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily,cccolorid,color_description, stylecolor_name, style_name  from '||table_cart_master_temp||') a, trd_ma_stylecolorattributes b
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''similar''
';


s28_X := '
Update trd_ma_stylecolorattributes b
set isassortment = ''true'', cc_is_locked = ''Y'', cc_s5_adopted = ''Y''
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily  from '||table_cart_master_temp||') a
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''existing''
';

s28_X1 := '
Update trd_ma_stylecolorattributes b
set cc_price_band = a.price_band
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, usd_ticket_price, price_band  from '||table_cart_master_temp||' x, trd_h_prodstd z, trd_l_ticketprice y where x.final_stylecolor_id = z.id and z.ancestor3 = y.product) a
where a.final_stylecolor_id=b.product
and b.cc_orig_unit_retail = a.usd_ticket_price
and a.stylecolor_type=''similar''
';

s28_X2 := '
Update trd_ma_stylecolorattributes b
set cc_good_better_best = a.price_band
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, subclass_id, ticket_price_min, ticket_price_max, price_band  from '||table_cart_master_temp||' x, trd_l_pricebandlookup y where x.subclass_id = y.product) a
where a.final_stylecolor_id=b.product
and b.cc_orig_unit_retail > ticket_price_min and b.cc_orig_unit_retail <= ticket_price_max
and a.stylecolor_type=''similar''
';


-- IMAGE ATTRIBUTES START

s29 := 'drop table if exists '||table_ma_imgattr||'';

s29_1 := '
create temporary table '||table_spec_img||' as
select
 distinct si.product, si.img, sa.product as stylecolor_id
from trd_specimages si
 inner join
trd_ma_stylecolorattributes sa
 on sa.product = si.product
where sa.product in (select final_stylecolor_id from '||table_cart_master_temp||' where jsessionid in (select jsessionid from '||table_input_t1||'));
';

s30 := '
create temporary table '||table_ma_imgattr||' as
select
    c.jsessionid
  , c.final_stylecolor_id as product
  , b.img as orig_image
  , c.img as cart_image
  , d.img as spec_image
FROM
  (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id, img from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')) c
 LEFT JOIN
  (select distinct product, img from trd_ma_imgattributes where product in (select distinct incoming_stylecolor_id from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||'))) b
ON
b.product=c.incoming_stylecolor_id
  LEFT JOIN
  (select distinct product, img, stylecolor_id from '||table_spec_img||') d
on
d.stylecolor_id = c.final_stylecolor_id;

'
;


s31 := '
delete from trd_ma_imgattributes where product in (
    select distinct final_stylecolor_id from  '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')
)
'
;

s32 := '
insert into trd_ma_imgattributes (product, img)
select product, coalesce(cart_image,orig_image,spec_image) from '||table_ma_imgattr||'
';




-- IMAGE ATTRIBUTES END

-- SIZE ATTRIBUTES

s33 := '
delete from trd_ma_sizeattributes where product in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsessionid from  '||table_input_t1||'))
';



s34 := '
insert into trd_ma_sizeattributes
    (product,
    parent_id,
    item_diff_2,
    item_diff_3,
    sizeattribute,
    isvalid
    )
SELECT
    distinct final_stylecolorsize_id,
    final_stylecolor_id,
    item_diff_2,
    item_diff_3,
    size_name,
    isvalid
FROM
    '||table_cart_stylecolorsize||'
WHERE stylecolor_type = ''similar''
';

-- STYLECOLOR CHANNEL ATTRIBUTES

s35 := '
create temporary  table '||table_default_cart_params||' as
select distinct
    a.jsessionid
  , a.scope_product
  , a.scope_location
  , a.initrcptwk  as default_initrcptwk
  , a.dbt_wk as default_dbt_wk
  , a.too as default_too
  , a.mkdnwks as default_mkdnwks
  , a.last_inv_wk as default_last_inv_wk
  , a.lstfpwk as default_lstfpwk
  , a.last_rcpt_wk as default_last_rcpt_wk
  , a.erlstmkdnwk as default_erlstmkdnwk
  , a.exitdate as default_exitdate
  , a.ccmdstrategy as default_ccmdstrategy
  , a.presmin as default_presmin
  , a.presmin_weeks as default_presmin_weeks
  , a.retpct_str as default_retpct_str
  , a.retpct_ecomm as default_retpct_ecom
  , a.retpct_cross as default_retpct_cross
  , a.ccrcptint as default_ccrcptint
  , a.ccordermultiple as default_ccordermultiple
  , a.ccordpolicy as default_ccordpolicy
  , a.slsrnk_store
  , a.slsrnk_ecom
  , a.planned_sell_down_week
  , c.default_ccdiscountpct
  , c.default_lead_time
  , a.cc_cluster_group

-- CA MOD 08.14.2025
  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank
  , a.use_valid_sizes_from as use_valid_sizes_from
  , a.apply_size_mins_to as apply_size_mins_to
  , a.cc_addoff_store as cc_addoff_store
  , a.cc_addoff_ecom as cc_addoff_ecom

from (select distinct * from ata_cart_params) a, trd_ma_dptflrsetattributes c, '||table_input_t1||' b
where a.jsessionid = b.jsessionid
and a.scope_product = b.scope_product
and a.scope_location = b.scope_location
and a.scope_start = b.scope_start
and a.scope_product = c.product
and a.scope_floorset = c.time
'
;


s36 := '
create  temporary table '||table_temp_sclr_chnl_attr||' as
select
    a.jsessionid
  , final_stylecolor_id as product
  , a.scope_location as location
  , default_initrcptwk as initrcptwk
  , default_dbt_wk as dbt_wk
  , default_too as too
  , default_mkdnwks as mkdnwks
  , default_last_inv_wk as last_inv_wk
  , default_lstfpwk as lstfpwk
  , default_last_rcpt_wk as last_rcpt_wk
  , default_erlstmkdnwk as erlstmkdnwk
  , default_exitdate as exitdate

  , coalesce(default_ccmdstrategy, ccmdstrategy) ccmdstrategy
  , ccrangecode
  , case when (ssnprf is null or ssnprf ='''') then ''class_default'' else ssnprf end
  , cc_validsizes_store
  , cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
    , coalesce(default_ccordermultiple::int, cc_ordermultiple::int) cc_ordermultiple
  , null::real as cc_systemcost

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

   , CASE
      WHEN a.use_act_aps_or_act_rank = ''Use Cart Rating'' THEN a.slsrnk_store
      ELSE COALESCE(b.act_slsrnk_store, b.slsrnk_store)
    END AS slsrnk_store

  , COALESCE(b.act_aps_mult_adj_store, 1) as act_aps_mult_adj_store

  , CASE
      WHEN a.use_act_aps_or_act_rank = ''Use Cart Rating'' THEN a.slsrnk_ecom
      ELSE COALESCE(b.act_slsrnk_ecom, b.slsrnk_ecom)
    END AS slsrnk_ecom
  , COALESCE(b.act_aps_mult_adj_ecom, 1) as act_aps_mult_adj_ecom

  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  , a.use_valid_sizes_from
  , a.apply_size_mins_to
  , a.cc_addoff_store
  , a.cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================


  , default_retpct_str as cc_return_u_pct_store
  , default_retpct_ecom as cc_return_u_pct_ecom
  , default_retpct_cross as cc_return_u_pct_cross

  -- MODIFIED BY CA on 03.29.2025
  -- , coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost ) as cc_plan_cost
  -- , coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost ) as cc_final_cost

  , case      when coalesce(b.cc_systemcost, 0.0) > 0.0 then b.cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end as cc_plan_cost

  , case      when coalesce(b.cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end as cc_final_cost

  , a.planned_sell_down_week
  , b.ccticketpricechannel
  , a.default_ccdiscountpct
  -- , coalesce(round(((b.ccticketpricechannel-(coalesce(b.cc_systemcost, e.cc_unit_cost, b.cc_plan_cost)))/b.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 

  , coalesce(round(((b.ccticketpricechannel-(case  when coalesce(b.cc_systemcost, 0.0) > 0.0 then b.cc_systemcost
              when coalesce(e.cc_unit_cost, 0.0) > 0.0 then e.cc_unit_cost
              else b.cc_plan_cost
      end))/b.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 
  , a.default_lead_time as cc_lead_time
  , a.cc_cluster_group




FROM
'||table_default_cart_params||' a, trd_ma_stylecolorchannelattributes b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||' where style_type = ''similar'') c,
 trd_ma_stylecolorattributes d, trd_ma_stylecolorattributes e
where b.product=c.incoming_stylecolor_id and a.jsessionid=c.jsessionid and a.scope_location=b.location and c.final_stylecolor_id = d.product
and e.product=c.incoming_stylecolor_id
';


s36_1 := '
insert into '||table_temp_sclr_chnl_attr||'
select
    a.jsessionid
  , final_stylecolor_id as product
  , a.scope_location as location
  , default_initrcptwk as initrcptwk
  , default_dbt_wk as dbt_wk
  , default_too as too
  , default_mkdnwks as mkdnwks
  , default_last_inv_wk as last_inv_wk
  , default_lstfpwk as lstfpwk
  , default_last_rcpt_wk as last_rcpt_wk
  , default_erlstmkdnwk as erlstmkdnwk
  , default_exitdate as exitdate

  , coalesce(default_ccmdstrategy, ccmdstrategy) ccmdstrategy
  , ccrangecode
  , case when (ssnprf is null or ssnprf ='''') then ''class_default'' else ssnprf end
  , cc_validsizes_store
  , cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
  , coalesce(default_ccordermultiple::int, cc_ordermultiple::int) cc_ordermultiple
  , cc_systemcost

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , COALESCE(e.act_slsrnk_store, e.slsrnk_store) as slsrnk_store
  , COALESCE(e.act_aps_mult_adj_store, 1) as act_aps_mult_adj_store

  , COALESCE(e.act_slsrnk_ecom, e.slsrnk_ecom) as slsrnk_ecom
  , COALESCE(e.act_aps_mult_adj_ecom, 1) as act_aps_mult_adj_ecom

  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  , a.use_valid_sizes_from
  , a.apply_size_mins_to
  , a.cc_addoff_store
  , a.cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================

  , default_retpct_str as cc_return_u_pct_store
  , default_retpct_ecom as cc_return_u_pct_ecom
  , default_retpct_cross as cc_return_u_pct_cross
  , cc_plan_cost

    , case    when coalesce(cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(d.cc_unit_cost, 0.0) > 0.0 then d.cc_unit_cost
              else cc_plan_cost
      end as cc_final_cost
  -- , case when cc_systemcost is not null then cc_systemcost when d.cc_unit_cost is not null then d.cc_unit_cost else cc_plan_cost end as cc_final_cost
  
  , a.planned_sell_down_week
  , e.ccticketpricechannel
  , a.default_ccdiscountpct
 -- , coalesce(round(((e.ccticketpricechannel-(case when cc_systemcost is not null then cc_systemcost when d.cc_unit_cost is not null then d.cc_unit_cost else cc_plan_cost end))/e.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct
  , coalesce(round(((e.ccticketpricechannel-(case  when coalesce(cc_systemcost, 0.0) > 0.0 then cc_systemcost
              when coalesce(d.cc_unit_cost, 0.0) > 0.0 then d.cc_unit_cost
              else cc_plan_cost
      end))/e.ccticketpricechannel)::numeric, 2),0.0) as cc_imupct 

  , a.default_lead_time as cc_lead_time
  , a.cc_cluster_group
FROM
'||table_default_cart_params||' a, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id, class_id, style_type from '||table_cart_master_temp||' where style_type = ''existing'') b,
trd_ma_styleattributes c, 
trd_ma_stylecolorattributes d,
trd_ma_stylecolorchannelattributes e
--(select array_agg(target_value) as validsizes, lookup_value as sty_size_run_name from trd_l_dependencylookup where lookup_id = ''size_range'' group by lookup_value) e
where a.jsessionid=b.jsessionid 
and b.final_style_id = c.product 
and b.final_stylecolor_id = d.product 
and b.incoming_stylecolor_id = e.product
and a.scope_location = e.location
--and c.sty_size_range = e.sty_size_run_name 
'
;



s37 := '
delete from trd_ma_stylecolorchannelattributes where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsessionid from  '||table_input_t1||'))
';



s38 := '
INSERT  into trd_ma_stylecolorchannelattributes (
  product
, location
, initrcptwk
, dbt_wk
, too
, mkdnwks
, last_inv_wk
, lstfpwk
, last_rcpt_wk
, erlstmkdnwk
, exitdate
, ccmdstrategy
, ccrangecode
, ssnprf
, validsizes
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_imupct
, cc_systemcost
-- , slsrnk_store
-- , slsrnk_ecom
, ccticketpricechannel
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_return_u_pct_cross
, cc_plan_cost
, cc_final_cost
, planned_sell_down_week
, cc_discount_pct
, cc_lead_time
, irw_debut_offset
, cc_cluster_group

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , slsrnk_store
  , act_aps_mult_adj_store
  , slsrnk_ecom
  , act_aps_mult_adj_ecom

  , use_act_aps_or_act_rank

  , use_valid_sizes_from
  , apply_size_mins_to
  , cc_addoff_store
  , cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================
  , record_state
)
select
  product
, location
, initrcptwk
, dbt_wk
, too
, mkdnwks
, last_inv_wk
, lstfpwk
, last_rcpt_wk
, erlstmkdnwk
, exitdate
, ccmdstrategy
, ccrangecode
, ssnprf
, ''{}''::text[]
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_imupct
, cc_systemcost
-- , slsrnk_store
-- , slsrnk_ecom
, ccticketpricechannel
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_return_u_pct_cross
, cc_plan_cost
, cc_final_cost
, planned_sell_down_week
, default_ccdiscountpct
, cc_lead_time
, b.irw_debut_offset
, a.cc_cluster_group

  -- =================================
  -- CA MOD 08.12.2025 START

              -- , a.slsrnk_store
              -- , a.slsrnk_ecom

  , slsrnk_store
  , act_aps_mult_adj_store
  , slsrnk_ecom
  , act_aps_mult_adj_ecom
  
  , use_act_aps_or_act_rank

  , use_valid_sizes_from
  , apply_size_mins_to
  , cc_addoff_store
  , cc_addoff_ecom

   -- CA MOD 08.12.2025 END
  -- =================================
  , 1
FROM
 '||table_temp_sclr_chnl_attr||' a, 
(select b.id, ap_start, ap_end, irw_debut_offset
      from trd_ma_dptflrsetattributes a, trd_h_prodstd b
      where b.ancestor3 = a.product and b.id in (select product from '||table_temp_sclr_chnl_attr||')
     ) b
where a.product = b.id
and a.dbt_wk between ap_start and ap_end;
 ';




-- ASSORTMENT MODEL

s51 := '
update trd_ma_stylecolorchannelattributes a
set plan_current = v_plan_current,
    ccticketpricechannel = cc_orig_unit_retail,
    cc_imupct = coalesce(round(((cc_orig_unit_retail-cc_final_cost)/cc_orig_unit_retail)::numeric, 2),0.0),
    ccrangecode = d.ccrangecode,
    use_valid_sizes_from = d.use_valid_sizes_from
from (select value as v_plan_current from trd_serviceparams where id=''plan_current'') b,
     trd_ma_stylecolorattributes c, (select product, ccrangecode, use_valid_sizes_from from '||table_temp_sclr_chnl_attr||') d
where (a.product, a.location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsessionid from  '||table_input_t1||'))
and a.product = c.product
and a.product = d.product
';

/*
-- When adding a color to an exsting style, we will take the max of various attributes and cost for the parent style and apply them to the newly added stylecolor
s51_1 := '
update trd_ma_stylecolorchannelattributes a
set
  ccrangecode = rangecode
 ,cc_validsizes_store = cc_validsizes_store_existing
 ,cc_validsizes_ecom = cc_validsizes_ecom_existing
 ,ccticketpricechannel = cast(coalesce(cc_msrp::real, .01) as real)
 ,cc_ordpolicy = cc_ordpolicy_existing
 ,cc_ordermultiple = cc_ordermultiple_existing
 ,cc_existingwac = cast(coalesce(cc_existingwac_existing::real,0.0) as real)
 ,cc_systemcost = cast(coalesce(cc_systemcost_existing::real,0.0) as real)
 ,cc_plan_cost = cast(coalesce(cc_plan_cost_existing::real,0.0) as real)
 ,cc_landed_cost = cast(coalesce(cc_landed_cost_existing::real,0.0) as real)
 ,cc_target_cost = cast(coalesce(cc_target_cost_existing::real,0.0) as real)
 --,cc_imupct = coalesce(round((((cc_msrp::real-coalesce(cc_actual_cost,cc_estimated_cost)::real)/cc_msrp::real)::numeric), 2)::real,0.0)::real
from 
(
  select x.sty_size_range || '' - '' || y.ancestor2 as rangecode, a.cc_validsizes_store_existing, a.cc_validsizes_ecom_existing, style_type, cc_msrp, cc_unit_retail, a.cc_ordpolicy_existing, a.cc_ordermultiple_existing, a.cc_existingwac_existing, 
        a.cc_systemcost_existing, a.cc_plan_cost_existing,a.cc_landed_cost_existing, a.cc_target_cost_existing
  from 
    trd_ma_styleattributes x, 
    trd_h_prodstd y, 
    trd_ma_stylecolorattributes d,
    (
      select distinct final_stylecolor_id, final_style_id, style_type 
      from  '||table_cart_master_temp||' 
      where jsessionid in (select jsessionid from  '||table_input_t1||') and style_type = ''existing''
    ) z,
    (
      select a.ancestor0, max(b.cc_validsizes_store) as cc_validsizes_store_existing, max(b.cc_validsizes_ecom) as cc_validsizes_ecom_existing, max(b.cc_ordpolicy) as cc_ordpolicy_existing, 
             max(b.cc_ordermultiple) as cc_ordermultiple_existing, max(b.cc_existingwac) as cc_existingwac_existing, max(b.cc_systemcost) as cc_systemcost_existing, max(b.cc_plan_cost) as cc_plan_cost_existing, 
             max(b.cc_landed_cost) as cc_landed_cost_existing, max(b.cc_target_cost) as cc_target_cost_existing
      from trd_h_prodstd a
      join trd_ma_stylecolorchannelattributes b
      on a.id = b.product
      where a.ancestor0 in (select distinct final_style_id from  '||table_cart_master_temp||')
      group by a.ancestor0 
    ) a
    where x.product = z.final_style_id 
    and y.id = z.final_stylecolor_id 
    and d.product = z.final_stylecolor_id
    and x.product = a.ancestor0
) b
where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsessionid from  '||table_input_t1||'))
';
*/


s39 := '
    create temporary table '||table_temp_assort||' AS
    SELECT distinct
        final_stylecolor_id as product
        , a.scope_location as location
        , a.scope_floorset as "time"
        , cast(str_grade as text[]) as str_grade
        , cast(str_store_climate as text[]) as str_store_climate
        , cast(str_capacity as text[]) as str_capacity
        , cast(str_store_banner as text[]) as str_store_banner
        , cast(str_geo_region as text[]) as str_geo_region
        , cast(str_hazmat as text[]) as str_hazmat
      --, cast(str_grade_or as text[]) as str_grade_or
      --, cast(str_store_climate_or as text[]) as str_store_climate_or
      --, cast(str_capacity_or as text[]) as str_capacity_or
      --, cast(str_store_banner_or as text[]) as str_store_banner_or
      --, cast(str_geo_region_or as text[]) as str_geo_region_or
      --, cast(str_hazmat_or as text[]) as str_hazmat_or
        , cast(ssg as text[]) as ssg
        , cast(flnrange as text[]) as flnrange
        , ''plan'' as plan_type
        , isfunded
        , final_style_id as style
        , store_count
    FROM
    (select distinct * from ata_cart_ranging) a, '||table_input_t1||' b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||') c,
    trd_ma_stylecolorattributes d
    where a.jsessionid=c.jsessionid
    and a.jsessionid = b.jsessionid
    and a.scope_product = b.scope_product
    and a.scope_location = b.scope_location
    and a.scope_start = b.scope_start
    and c.final_stylecolor_id = d.product
    '
    ;

s39_test := 'insert into jrtest_S5391 select * from ' || table_temp_assort;

s40 := '
delete from trd_a_assortment where (product, location) in (select product,location from '||table_temp_assort||') and plan_type=''plan''
';

s41 := '

    insert into trd_a_assortment (
          product
        , location
        , "time"
        , str_grade
        , str_store_climate
        , str_capacity
        , str_store_banner
        , str_geo_region
        , str_hazmat
      --, str_grade_or
      --, str_store_climate_or
      --, str_capacity_or
      --, str_store_banner_or
      --, str_geo_region_or
      --, str_hazmat_or
        , ssg
        , flnrange
        , plan_type
        , isfunded
        , store_count
        , style)
    SELECT
          product
        , location
        , "time"
        , str_grade
        , str_store_climate
        , str_capacity
        , str_store_banner
        , str_geo_region
        , str_hazmat
      --, str_grade_or
      --, str_store_climate_or
      --, str_capacity_or
      --, str_store_banner_or
      --, str_geo_region_or
      --, str_hazmat_or
        , ssg
        , flnrange
        , plan_type
        , isfunded
        , store_count
        , style
    FROM
       '||table_temp_assort||'
';



RAISE NOTICE 'END Assortment Model:%', 'START:'|| now();

s42 := '
create temporary table '||table_final_list||' AS
select distinct a.product, a.location
from
(select distinct product,location  from trd_ma_stylecolorchannelattributes where (product, location) in (select distinct final_stylecolor_id,''CH-2'' as prod_loc from '||table_cart_master_temp||')) a,
(select distinct product,location  from trd_a_assortment where (product, location) in (select distinct final_stylecolor_id, ''CH-2'' as prod_loc from '||table_cart_master_temp||')) b
where
a.product=b.product
and a.location=b.location
';


/*
s43 := '
insert into plan_queue (product, location, initiator, initiated_at)
select final_stylecolor_id, ''CH-2'', initiator :: uuid, now() from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')
and (final_stylecolor_id, ''CH-2'') in (select product, location from '||table_final_list||')
';

s43_1 := 'select final_stylecolor_id product from '||table_cart_master_temp||' where jsessionid in (select jsessionid from  '||table_input_t1||')
    and (final_stylecolor_id, ''CH-2'') in (select product, location from '||table_final_list||')';



s44 := 'update ata_cart_master set isProcessed=1 where jsessionid in (select jsessionid from  '||table_input_t1||')';

s45 := 'insert into ata_cart_master_archive select *, now() from ata_cart_master  where jsessionid in (select jsessionid from  '||table_input_t1||')';
s46 := 'insert into ata_cart_params_archive select *, now() from ata_cart_params  where jsessionid in (select jsessionid from  '||table_input_t1||')';
s47 := 'insert into ata_cart_ranging_archive select *, now() from ata_cart_ranging  where jsessionid in (select jsessionid from  '||table_input_t1||')';

s48 := 'delete from ata_cart_master where jsessionid in (select jsessionid from  '||table_input_t1||')';
s49 := 'delete from ata_cart_params where jsessionid in (select jsessionid from  '||table_input_t1||')';
s50 := 'delete from ata_cart_ranging where jsessionid in (select jsessionid from  '||table_input_t1||')';

*/
insert into debug_stats_ts values ('s1',s1,now());


s100 := 'CREATE TEMPORARY TABLE '||tst_df_temp||' AS
          SELECT
              product,
              COALESCE(relaunchweek,dbt_wk) as dbt_wk,
              last_rcpt_wk,
              erlstmkdnwk,
              exitdate,
              ccmdstrategy,
              cc_discount_pct,
              in_season_flag,
              id AS time,
              case when id < erlstmkdnwk then ''FP'' else ''MD'' end as price_status
          FROM trd_ma_stylecolorchannelattributes AS a
          , trd_d_time AS b
          WHERE (id >= COALESCE(relaunchweek,dbt_wk)) AND (id <= exitdate) AND product in (select product from '||table_temp_sclr_chnl_attr||')
          ORDER BY
              product ASC,
              id ASC
          ';

s101 := 'CREATE TEMPORARY TABLE '||tst_md_seq||' AS
          SELECT
              *,
              row_number() OVER (PARTITION BY product ORDER BY time ASC) AS seq
          FROM '||tst_df_temp||'
          WHERE price_status = ''MD''
          ';

s102 := 'CREATE TEMPORARY TABLE '||tst_df||' AS
          SELECT *
          FROM
          (
              SELECT
                  product,
                  dbt_wk,
                  last_rcpt_wk,
                  erlstmkdnwk,
                  exitdate,
                  time,
                  price_status,
                  0 AS seq,
                  ccmdstrategy,
                  cc_discount_pct,
                  in_season_flag
              FROM '||tst_df_temp||' AS a
              WHERE price_status = ''FP''
              UNION ALL
              SELECT
                  product,
                  dbt_wk,
                  last_rcpt_wk,
                  erlstmkdnwk,
                  exitdate,
                  time,
                  price_status,
                  seq,
                  ccmdstrategy,
                  cc_discount_pct,
                  in_season_flag
              FROM '||tst_md_seq||' AS b
              WHERE price_status = ''MD''
          ) AS x
          ORDER BY
              product ASC,
              time ASC,
              seq ASC
    ';

s103 := 'CREATE TEMPORARY TABLE '||tst_df_with_style||' AS
          SELECT
              a.*,
              b.ancestor0 AS style,
              ancestor1 AS subclass,
              ancestor3 as department
          FROM '||tst_df||' AS a
          ,
          (
              SELECT
                  id,
                  ancestor0,
                  ancestor1,
                  ancestor3
              FROM trd_h_prodstd
              WHERE id IN
              (
                  SELECT product
                  FROM '||tst_df||'
              )
          ) AS b
          WHERE a.product = b.id
          ';


s104 := 'CREATE TEMPORARY TABLE '||tst_md_tktp_md||' as
            select x.*
            , 0::real as ccticketprice
            , 0::real as md_disc
            , 0::real corpaddoff
            , 0::real corpexcl
            , 0::real addoff
            , null::real expressed_aur
            , 0::real curp
            , 0::real selling_price
            , 0::real v_A
            , 0::real v_B
            , null::text weekdate
            FROM
            (select a.* from '||tst_df_with_style||' a, trd_ma_styleattributes b where a.style=b.product) x
            ';

s104_a := 'update '||tst_md_tktp_md||' a
            set ccticketprice=b.cc_unit_retail::real, curp=cc_unit_retail::real
          from trd_ma_stylecolorattributes b
          where a.product = b.product
          ';

s105 := 'update '||tst_md_tktp_md||' a
            set md_disc=b.md_disc, curp=ccticketprice * (1 - b.md_disc)
          from md_strategy b
          where a.seq=b.seq and a.ccmdstrategy=b.mdstrategy
          and a.seq > 0
          ';

s106 := 'update '||tst_md_tktp_md||' a
            set corpaddoff=b.corpaddoff, corpexcl=b.corpexcl
          from trd_corpdisc b
          where a.subclass=b.product and a.time=b.time
          ';

s107 := 'update '||tst_md_tktp_md||' a
            set expressed_aur=b.eff_aur, addoff=b.addoff
          from trd_p_itemprice b
          where a.product=b.product and a.time=b.time
        ';

s108 := 'update '||tst_md_tktp_md||' a
            set v_A=b.v_A
          FROM
            (select product, time, seq, case when seq=0 then ccticketprice * (1-COALESCE(corpexcl,0)) else curp end as v_A from '||tst_md_tktp_md||') b
          WHERE a.product=b.product and a.time=b.time
          ';

s109 := 'update '||tst_md_tktp_md||' a
            set v_B=b.v_B
          FROM
            (select product, time, seq, addoff, corpaddoff
              , case when seq=0 then
                  (case when expressed_aur > 0 then expressed_aur else ccticketprice end) * (1 - coalesce(addoff,0)) * (1 - coalesce(corpaddoff,0))
               else curp end as v_B
               from '||tst_md_tktp_md||'
            ) b
          WHERE a.product=b.product and a.time=b.time
          ';

S_PRE_110_1 := 'CREATE TEMPORARY TABLE '||table_xt_flag||' AS
              select product, dbt_wk, last_rcpt_wk, b.indx as dbt_wk_indx, c.indx as last_rcpt_wk_indx from ( select distinct product, dbt_wk, last_rcpt_wk from '||tst_md_tktp_md||' ) a, trd_d_time b, trd_d_time c
              where a.dbt_wk=b.id and a.last_rcpt_wk=c.id
              ';


s110   := 'update '||tst_md_tktp_md||'    set selling_price=(least(v_A,v_B) * (1 - cc_discount_pct))::NUMERIC(16,2)';
s110_1 := 'update '||tst_md_tktp_md||'  a set dbt_wk=b.start_date from trd_ma_weekattributes b where a.dbt_wk=b.time';
s110_2 := 'update '||tst_md_tktp_md||'  a set last_rcpt_wk=b.start_date from trd_ma_weekattributes b where a.last_rcpt_wk=b.time';
s110_3 := 'update '||tst_md_tktp_md||'  a set erlstmkdnwk=b.start_date from trd_ma_weekattributes b where a.erlstmkdnwk=b.time';
s110_4 := 'update '||tst_md_tktp_md||'  a set exitdate=b.start_date from trd_ma_weekattributes b where a.exitdate=b.time';
s110_5 := 'update '||tst_md_tktp_md||'  a set weekdate=b.start_date from trd_ma_weekattributes b where a.time=b.time';


s111 := 'CREATE TEMPORARY TABLE '||table_xt||' AS
        select *,
            case when ''ECOM''=ANY(str_grade) then ''ECOM'' else ''STORE'' END as selling_channel
        FROM
        (
          SELECT
              x.*,
              y.id,
              y.indx
          FROM
          (
              SELECT
                  product,
                  location,
                  time AS floorset,
                  store_count,
                  str_grade,
                  isfunded,
                  ancestor3 AS department
              FROM (select * from trd_a_assortment where product in (select product from '||tst_md_tktp_md||')) AS a
              ,
              (
                  SELECT
                      id,
                      ancestor3
                  FROM trd_h_prodstd where id in (select product from '||tst_md_tktp_md||')
              ) AS b
              WHERE (a.product = b.id)
          ) AS x
          ,
          (
              SELECT
                  product AS department,
                  a.time AS floorset,
                  b.id,
                  b.indx
              FROM trd_ma_dptflrsetattributes AS a
              , trd_d_time AS b
              WHERE (b.id >= a.ap_start) AND (b.id <= a.ap_end)
          ) AS y
          WHERE (x.department = y.department) AND (x.floorset = y.floorset)
        ) z
        ';
/*
s112 := 'CREATE TEMPORARY TABLE '||table_yt||' AS
          select
          product
          , location
          , case when ch02 is null then 0 else 1 end as store_count
          , isfunded
          , id as time
          , indx
          , ch02 as selling_channel
          from '||table_xt||' where ch02 = ''CH-02''
          UNION ALL
          select
          product
          , location
          , case when ch01 is null then 0 else case when ch02 is null then store_count else store_count - 1 end end as store_count
          , isfunded
          , id as time
          , indx
          , ch01 as selling_channel
          from '||table_xt||' where ch01 = ''CH-01''
          UNION ALL
          select
          product
          , location
          , store_count
          , isfunded
          , id as time
          , indx
          , ch03 as selling_channel
          from '||table_xt||' where ch03 = ''CH-03''
        ';
*/
s113 := 'CREATE TEMPORARY TABLE '||table_zt_pre||' AS
          SELECT *
          FROM
          (
              SELECT
                  a.product,
                  a.location AS channel,
                  a.id as time,
                  a.indx,
                  a.selling_channel,
                  a.isfunded,
                  a.store_count,
                  b.in_season_flag,
                  b.dbt_wk,
                  b.last_rcpt_wk,
                  b.erlstmkdnwk,
                  b.exitdate,
                  b.weekdate,
                  b.price_status,
                  b.seq,
                  b.ccticketprice,
                  b.curp,
                  b.selling_price,
                  b.expressed_aur,
                  b.corpexcl,
                  b.addoff,
                  b.corpaddoff,
                  b.v_A,
                  b.v_B,
                  b.cc_discount_pct
              FROM '||table_xt||' AS a
              , '||tst_md_tktp_md||' AS b
              WHERE (a.product = b.product) AND (a.id = b.time)
          ) AS x
          WHERE time >= (select value from trd_serviceparams where id=''plan_current'')
          AND time <= (select value from trd_serviceparams where id=''plan_end'')
        ';

s113_1 := 'CREATE TEMPORARY TABLE '||table_zt_flow_flag||'
              AS
              SELECT a.product, a.selling_channel, a.time, a.indx, dbt_wk_indx, last_rcpt_wk_indx
              , CASE when (indx >= dbt_wk_indx and indx < (dbt_wk_indx + 4)) then ''NEW''
                  ELSE
                    CASE when (indx >= (dbt_wk_indx + 4) AND indx < (last_rcpt_wk_indx + 4)) then ''FLOW''
                      ELSE ''LOF''
                    END
                END as flow_flag
              from '||table_zt_pre||' a, '||table_xt_flag||' b
              WHERE a.product=b.product
              ';

s113_2 := 'CREATE TEMPORARY TABLE '||table_zt||'
           AS
           select a.*, flow_flag from '||table_zt_pre||' a, '||table_zt_flow_flag||' b
           WHERE a.product=b.product and a.selling_channel=b.selling_channel and a.time=b.time
           ';


s114 := 'delete from trd_an_price_storecount_info where (product,channel) in (select product, channel from '||table_zt||')';
s115 := 'insert into trd_an_price_storecount_info
          select
            product
            , channel
            , time
            , selling_channel
            , isfunded
            , store_count
            , in_season_flag
            , dbt_wk
            , last_rcpt_wk
            , erlstmkdnwk
            , exitdate
            , weekdate
            , price_status
            , seq
            , ccticketprice
            , curp
            , selling_price
            , expressed_aur
            , corpexcl
            , addoff
            , corpaddoff
            , v_A
            , v_B
            , cc_discount_pct
            , flow_flag
          from
          '||table_zt||'
          ';

/*
RAISE NOTICE 'INPUT:%', 'START:'|| now();
RAISE NOTICE 's1:%', s1;
RAISE NOTICE 's2:%', s2;
RAISE NOTICE 's3:%', s3;
RAISE NOTICE 's4_1:%', s4_1;
RAISE NOTICE 's5:%', s5;
RAISE NOTICE 's6:%', s6;
RAISE NOTICE 's7:%', s7;
RAISE NOTICE 's7_1:%', s7_1;


RAISE NOTICE 'Start Member Create:%', 'START:'|| now();

RAISE NOTICE 's8:%', s8;
RAISE NOTICE 's9: %', s9;
RAISE NOTICE 's10: %', s10;
RAISE NOTICE 's11: %', s11;
RAISE NOTICE 's12: %', s12;
RAISE NOTICE 's13: %', s13;
RAISE NOTICE 's14: %', s14;
RAISE NOTICE 's15: %', s15;
RAISE NOTICE 's16: %', s16;
RAISE NOTICE 's17: %', s17;
RAISE NOTICE 's18: %', s18;
RAISE NOTICE 's19: %', s19;


RAISE NOTICE 'Start Attribute Create:%', 'START:'|| now();
RAISE NOTICE 's20: %', s20;
RAISE NOTICE 's21: %', s21;
RAISE NOTICE 's21_x: %', s21_x;
RAISE NOTICE 's21_y: %', s21_y;
RAISE NOTICE 's22: %', s22;
RAISE NOTICE 's23: %', s23;
RAISE NOTICE 's24: %', s24;
RAISE NOTICE 's25: %', s25;
RAISE NOTICE 's26: %', s26;
RAISE NOTICE 's26_X: %', s26_X;
RAISE NOTICE 's27: %', s27;
RAISE NOTICE 's28: %', s28;
RAISE NOTICE 's28_X: %', s28_X;
RAISE NOTICE 's28_X1: %', s28_X1;
RAISE NOTICE 's28_X2: %', s28_X2;
RAISE NOTICE 's29: %', s29;
RAISE NOTICE 's29_1: %', s29_1;
RAISE NOTICE 's30: %', s30;
RAISE NOTICE 's31: %', s31;
RAISE NOTICE 's32: %', s32;
RAISE NOTICE 's33: %', s33;
RAISE NOTICE 's34: %', s34;
RAISE NOTICE 'Start Channel Attribute:%', 'START:'|| now();
RAISE NOTICE 's35: %', s35;
RAISE NOTICE 's36: %', s36;
RAISE NOTICE 's36_1: %', s36_1;
RAISE NOTICE 's37: %', s37;
RAISE NOTICE 's38: %', s38;

RAISE NOTICE 'Start Assortment Model:%', 'START:'|| now();
RAISE NOTICE 's51: %', s51;
RAISE NOTICE 's51_1: %', s51_1;
RAISE NOTICE 's39: %', s39;
RAISE NOTICE 's40: %', s40;
RAISE NOTICE 's41: %', s41;

RAISE NOTICE 'END Assortment Model:%', 'START:'|| now();
RAISE NOTICE 's42: %', s42;
RAISE NOTICE 's43: %', s43;
RAISE NOTICE 's44: %', s44;
RAISE NOTICE 's45: %', s45;
RAISE NOTICE 's46: %', s46;
RAISE NOTICE 's47: %', s47;
RAISE NOTICE 's48: %', s48;
RAISE NOTICE 's49: %', s49;
RAISE NOTICE 's50: %', s50;
*/

-- s110_6 :=  'drop table if exists tst_md_tktp_md';
-- s110_7 :=  'create table tst_md_tktp_md as select * from '||tst_md_tktp_md||'';
-- s110_8 :=  'drop table if exists table_zt';
-- s110_9 :=  'create table table_zt as select * from '||table_zt||'';
-- insert into trigger_test_delete_me values ('s0:', clock_timestamp());
EXECUTE s8;
-- insert into trigger_test_delete_me values ('s8:', clock_timestamp());
EXECUTE s9;
-- insert into trigger_test_delete_me values ('s9:', clock_timestamp());
EXECUTE s10;
-- insert into trigger_test_delete_me values ('s10:', clock_timestamp());
EXECUTE s11;
-- insert into trigger_test_delete_me values ('s11:', clock_timestamp());
EXECUTE s13;
-- insert into trigger_test_delete_me values ('s13:', clock_timestamp());
EXECUTE s14;
-- insert into trigger_test_delete_me values ('s14:', clock_timestamp());
EXECUTE s15;
-- insert into trigger_test_delete_me values ('s15:', clock_timestamp());
EXECUTE s16;
-- insert into trigger_test_delete_me values ('s16:', clock_timestamp());
EXECUTE s17;
-- insert into trigger_test_delete_me values ('s17:', clock_timestamp());
EXECUTE s19;
-- insert into trigger_test_delete_me values ('s19:', clock_timestamp());
EXECUTE s20;
-- insert into trigger_test_delete_me values ('s20:', clock_timestamp());
EXECUTE s21;
-- insert into trigger_test_delete_me values ('s21:', clock_timestamp());
EXECUTE s21_x;
-- insert into trigger_test_delete_me values ('s21_x:', clock_timestamp());
EXECUTE s21_y;
-- insert into trigger_test_delete_me values ('s21_y:', clock_timestamp());
EXECUTE s22;
-- insert into trigger_test_delete_me values ('s22:', clock_timestamp());
EXECUTE s23;
-- insert into trigger_test_delete_me values ('s23:', clock_timestamp());
EXECUTE s24;
-- insert into trigger_test_delete_me values ('s24:', clock_timestamp());
EXECUTE s25;
-- insert into trigger_test_delete_me values ('s25:', clock_timestamp());
EXECUTE s26;
-- insert into trigger_test_delete_me values ('s26:', clock_timestamp());
EXECUTE s26_X;
-- insert into trigger_test_delete_me values ('s26_X:', clock_timestamp());
EXECUTE s27;
-- insert into trigger_test_delete_me values ('s27:', clock_timestamp());
EXECUTE s28;
-- insert into trigger_test_delete_me values ('s28:', clock_timestamp());
EXECUTE s28_X;
-- insert into trigger_test_delete_me values ('s28_X:', clock_timestamp());
EXECUTE s28_X1;
-- insert into trigger_test_delete_me values ('s28_X1:', clock_timestamp());
EXECUTE s28_X2;
-- insert into trigger_test_delete_me values ('s28_X2:', clock_timestamp());
EXECUTE s29;
-- insert into trigger_test_delete_me values ('s29:', clock_timestamp());
EXECUTE s29_1;
-- insert into trigger_test_delete_me values ('s29_1:', clock_timestamp());
EXECUTE s30;
-- insert into trigger_test_delete_me values ('s30:', clock_timestamp());
EXECUTE s31;
-- insert into trigger_test_delete_me values ('s31:', clock_timestamp());
EXECUTE s32;
-- insert into trigger_test_delete_me values ('s32:', clock_timestamp());
EXECUTE s33;
-- insert into trigger_test_delete_me values ('s33:', clock_timestamp());
EXECUTE s34;
-- insert into trigger_test_delete_me values ('s34:', clock_timestamp());
EXECUTE s35;
-- insert into trigger_test_delete_me values ('s35:', clock_timestamp());
EXECUTE s36;
-- insert into trigger_test_delete_me values ('s36:', clock_timestamp());
EXECUTE s36_1;
-- insert into trigger_test_delete_me values ('s36_1:', clock_timestamp());
EXECUTE s37;
-- insert into trigger_test_delete_me values ('s37:', clock_timestamp());
EXECUTE s38;
-- insert into trigger_test_delete_me values ('s38:', clock_timestamp());
EXECUTE s51;
-- insert into trigger_test_delete_me values ('s51:', clock_timestamp());
--EXECUTE s51_1;
-- insert into trigger_test_delete_me values ('s51_1:', clock_timestamp());
EXECUTE s39;
-- insert into trigger_test_delete_me values ('s39:', clock_timestamp());
--EXECUTE s39_test;
-- insert into trigger_test_delete_me values ('s39_test:', clock_timestamp());
EXECUTE s40;
-- insert into trigger_test_delete_me values ('s40:', clock_timestamp());
EXECUTE s41;
-- insert into trigger_test_delete_me values ('s41:', clock_timestamp());
EXECUTE s42;
-- insert into trigger_test_delete_me values ('s42:', clock_timestamp());
/*
EXECUTE s43;
-- insert into trigger_test_delete_me values ('s43:', clock_timestamp());
EXECUTE s44;
-- insert into trigger_test_delete_me values ('s44:', clock_timestamp());
EXECUTE s45;
-- insert into trigger_test_delete_me values ('s45:', clock_timestamp());
EXECUTE s46;
-- insert into trigger_test_delete_me values ('s46:', clock_timestamp());
EXECUTE s47;
-- insert into trigger_test_delete_me values ('s47:', clock_timestamp());
EXECUTE s48;
-- insert into trigger_test_delete_me values ('s48:', clock_timestamp());
EXECUTE s49;
-- insert into trigger_test_delete_me values ('s49:', clock_timestamp());
EXECUTE s50;
-- insert into trigger_test_delete_me values ('s50:', clock_timestamp());
*/
EXECUTE s100 ;
-- insert into trigger_test_delete_me values ('s100:', clock_timestamp());
EXECUTE s101 ;
-- insert into trigger_test_delete_me values ('s101:', clock_timestamp());
EXECUTE s102 ;
-- insert into trigger_test_delete_me values ('s102:', clock_timestamp());
EXECUTE s103 ;
-- insert into trigger_test_delete_me values ('s103:', clock_timestamp());
EXECUTE s104 ;
-- insert into trigger_test_delete_me values ('s104:', clock_timestamp());
EXECUTE s104_a ;
-- insert into trigger_test_delete_me values ('s104_a:', clock_timestamp());
EXECUTE s105 ;
-- insert into trigger_test_delete_me values ('s105:', clock_timestamp());
EXECUTE s106 ;
-- insert into trigger_test_delete_me values ('s106:', clock_timestamp());
EXECUTE s107 ;
-- insert into trigger_test_delete_me values ('s107:', clock_timestamp());
EXECUTE s108 ;
-- insert into trigger_test_delete_me values ('s108:', clock_timestamp());
EXECUTE s109 ;
-- insert into trigger_test_delete_me values ('s109:', clock_timestamp());
EXECUTE s_pre_110_1;
-- insert into trigger_test_delete_me values ('s_pre_110_1:', clock_timestamp());
EXECUTE s110 ;
-- insert into trigger_test_delete_me values ('s110:', clock_timestamp());
EXECUTE s110_1;
-- insert into trigger_test_delete_me values ('s110_1:', clock_timestamp());
EXECUTE s110_2;
-- insert into trigger_test_delete_me values ('s110_2:', clock_timestamp());
EXECUTE s110_3;
-- insert into trigger_test_delete_me values ('s110_3:', clock_timestamp());
EXECUTE s110_4;
-- insert into trigger_test_delete_me values ('s110_4:', clock_timestamp());
EXECUTE s110_5;
-- insert into trigger_test_delete_me values ('s110_5:', clock_timestamp());
EXECUTE s111 ;
-- insert into trigger_test_delete_me values ('s111:', clock_timestamp());
--EXECUTE s112 ;
-- insert into trigger_test_delete_me values ('s112:', clock_timestamp());
EXECUTE s113 ;
-- insert into trigger_test_delete_me values ('s113:', clock_timestamp());
EXECUTE s113_1 ;
-- insert into trigger_test_delete_me values ('s113_1:', clock_timestamp());
EXECUTE s113_2 ;
-- insert into trigger_test_delete_me values ('s113_2:', clock_timestamp());
EXECUTE s114 ;
-- insert into trigger_test_delete_me values ('s114:', clock_timestamp());
EXECUTE s115 ;
-- insert into trigger_test_delete_me values ('s115:', clock_timestamp());

RAISE NOTICE 'Marked Cart as isProcessed:%', 'START:'|| now();

END;
$$;


--
-- Name: ata_get_default_params(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ata_get_default_params(input_jsessionid text, scope_department text, scope_location text, scope_start text, scope_floorset text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
v_exists integer;
insert_s2 text;
delete_s3 text;
insert_s4 text;
BEGIN
  EXECUTE '(select count(*) from ata_cart_params where 
          jsessionid = '''||$1||'''  
          and scope_product =  '''||$2||'''  
          and scope_location = '''||$3||'''  
    and scope_start = '''||$4||''' 
          )' into v_exists;
  insert_s2 := '
        INSERT INTO ata_cart_params
        (
            jsessionid, scope_product, scope_location, scope_start, scope_floorset
          , initrcptwk
          , dbt_wk
          , planned_sell_down_week
          , too
          , mkdnwks
          , last_rcpt_wk
          , erlstmkdnwk
          , exitdate
          , ccmdstrategy
          , presmin
          , presmin_weeks
          , retpct_str
          , retpct_ecomm
          , retpct_cross
          , ccrcptint
          , ccordermultiple
          , slsrnk_store
          , slsrnk_ecom
		      , irw_debut_offset --Added On 2025_05_13 for ticket SUP-2395

          -- CA MOD 08.14.2025
          , use_act_aps_or_act_rank
          , use_valid_sizes_from
          , apply_size_mins_to
          , cc_addoff_store
          , cc_addoff_ecom
        )
        SELECT distinct
            '''||$1||''','''||$2||''','''||$3||''','''||$4||''','''||$5||'''
          , e.id
          , ap_start
          , default_planned_sell_down_week
          , weeks_at_fp::real
          , c.indx - b.indx as mkdnwks
          , f.id as last_rcpt_wk
          , markdown_week
          , exit_week
          , default_ccmdstrategy
          , default_presmin
          , default_presmin_weeks
          , default_retpct_str
          , default_retpct_ecom
          , default_crosschannel_retpct_ecom
          , default_ccrcptint
          , default_ccordermultiple_uom
          , default_slsrnk_store
          , default_slsrnk_ecom
		  , irw_debut_offset

           -- CA MOD 08.14.2025
           -- UNCOMMENT if those defaults are available in ma_dptflrsetattributes

          , ''Copy Rating''                 -- use_act_aps_or_act_rank
          , ''Defaults – All Valid Sizes''  -- use_valid_sizes_from
          , ''Core Sizes Only''             -- apply_size_mins_to
          , 0.1::real                             -- cc_addoff_store
          , 0.1::real                             -- cc_addoff_ecom

        FROM 
          trd_ma_dptflrsetattributes a, 
          trd_d_time b,
          trd_d_time c,
          trd_d_time d,
          trd_d_time e,
          trd_d_time f
        WHERE 
          product = '''||$2||'''
          and time = '''||$5||'''
          and a.markdown_week = b.id
          and a.exit_week = c.id
          and a.ap_start = d.id
          and d.indx = e.indx + a.irw_debut_offset
          and f.indx = b.indx - 4
          ';
  delete_s3 := ' 
     delete from ata_cart_ranging where jsessionid = '''||$1||''' and scope_product='''||$2||''' 
     and scope_start = '''||$4||''' and scope_floorset = '''||$5||'''  
             ';
  insert_s4 := '
  insert into ata_cart_ranging 
(jsessionid,scope_product,scope_location,scope_start,scope_floorset
   ,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,isfunded, indx, store_count)
select 
  '''||$1||''',product,'''||$3||''','''||$4||''',time, 
    case when cardinality(default_store_vol_grade) = 0 then ''{ECOM,AA,A,B,C,D,E}'' else  default_store_vol_grade end as default_store_vol_grade
  , case when cardinality(default_store_climate) = 0 then ''{"Extreme Cold",Cold,Moderate,Warm,"Very Warm",Hot}'' else  default_store_climate end as default_store_climate
  , case when cardinality(default_store_capacity) = 0 then ''{Alaska,Canada,Hawaii,"Mid Atlantic",Midwest,"Nor Cal",Northeast,"Pac Nwest",Plains,"Puerto Rico","Rocky Mtn","So Cal",Southeast,Southwest,Texas,N}'' else  default_store_capacity end as default_store_capacity
  , case when cardinality(default_store_banner) = 0 then ''{Torrid,Curve}'' else  default_store_banner end as default_store_banner
  , case when cardinality(default_store_geo_region) = 0 then ''{"Very High",High,Average,Low,"Very Low",N}'' else  default_store_geo_region end as default_store_geo_region
  , case when cardinality(default_store_hazmat) = 0 then ''{No,Yes}'' else  default_store_hazmat end as default_store_hazmat
  , isfunded
  , indx
  , store_count
  FROM (
  select product, time,default_store_vol_grade,default_store_climate,default_store_capacity,default_store_banner,default_store_geo_region,default_store_hazmat
   ,1 as isfunded, a.indx, 
   get_store_count('''||$4||''', 
                   case when cardinality(default_store_vol_grade) = 0 then ''{ECOM,AA,A,B,C,D,E}'' else  default_store_vol_grade end,
                   case when cardinality(default_store_climate) = 0 then ''{"Extreme Cold",Cold,Moderate,Warm,"Very Warm",Hot}'' else  default_store_climate end,
                   case when cardinality(default_store_capacity) = 0 then ''{Alaska,Canada,Hawaii,"Mid Atlantic",Midwest,"Nor Cal",Northeast,"Pac Nwest",Plains,"Puerto Rico","Rocky Mtn","So Cal",Southeast,Southwest,Texas,N}'' else  default_store_capacity end,
                   case when cardinality(default_store_banner) = 0 then ''{Torrid,Curve}'' else  default_store_banner end,
                   case when cardinality(default_store_geo_region) = 0 then ''{"Very High",High,Average,Low,"Very Low",N}'' else  default_store_geo_region end,
                   case when cardinality(default_store_hazmat) = 0 then ''{No,Yes}'' else  default_store_hazmat end, 
                   product
                  ) as store_count
  FROM trd_ma_dptflrsetattributes a, ata_cart_params b,
   (select value as plan_current from trd_serviceparams where id=''plan_current'') c,
   (select value as plan_end from trd_serviceparams where id=''plan_end'') d
  where 
  b.jsessionid = '''||$1||'''
  and b.scope_product = '''||$2||'''
  and b.scope_location = '''||$3||'''
  and a.product = b.scope_product
     and a.ap_start <= least(d.plan_end,b.exitdate) and a.ap_end > greatest(b.dbt_wk,c.plan_current)
  )X
        ';
  IF  v_exists = 0
  THEN
  EXECUTE insert_s2;
  EXECUTE delete_s3;  
  EXECUTE insert_s4;
  END IF;
 RETURN;
END;
$_$;


--
-- Name: ata_plan_these_style_stylecolors_proc(text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.ata_plan_these_style_stylecolors_proc(IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN


    -- ----------------------------------
    -- UPDATE picked_for_planning FLAG
    -- ----------------------------------

    -- Freeze this user's unpicked selection to avoid races
    CREATE TEMPORARY TABLE tmp_selected
    AS
    SELECT style, stylecolor, session_id, updated_by, picked_for_planning
    FROM ata_plan_these_style_stylecolors
    WHERE updated_by = v_pivot_user_id
      AND picked_for_planning = 0
    ;


    -- ----------------------------------
    -- MARK FOR DELETION UNUSED PRODUCTS 
    -- ----------------------------------


    CREATE TEMPORARY TABLE all_un_used_products
    AS  
    SELECT 
        DISTINCT new_stylecolor_id AS product, 'stylecolor' AS levelid 
    FROM 
        ata_cart_master s
    WHERE s.initiator = v_pivot_user_id
      AND NOT EXISTS (
            SELECT 1 FROM tmp_selected t
            WHERE t.stylecolor = s.new_stylecolor_id AND t.session_id = s.jsessionid
      )
    ;

    -- --------------------------------------------------------------------------------------------------------
    -- CLEAN UP BYPASSING DELETES FOR NOW, SIMULATING REMOVE FROM ASSORTMENT, LIKELY DATA EXISTS IN CLICKHOUSE
    -- --------------------------------------------------------------------------------------------------------
    DELETE FROM trd_a_assortment 
    WHERE product IN (SELECT DISTINCT product FROM all_un_used_products);

    UPDATE trd_ma_stylecolorchannelattributes
    SET record_state = 1
    WHERE product IN (SELECT DISTINCT product FROM all_un_used_products WHERE levelid = 'stylecolor')
    ;

    UPDATE trd_ma_stylecolorchannelattributes
    SET record_state = 0
    WHERE product IN (select distinct stylecolor from tmp_selected)
    ;

    ------------------------------------
    -- INSERT IN PLAN QUEUE FOR PLANNING
    ------------------------------------

    INSERT INTO plan_queue (product, location, initiator, initiated_at, queued)
    SELECT 
        DISTINCT stylecolor, 'CH-2' AS location, v_pivot_user_id, now(), now()
    FROM 
        tmp_selected
    ;


    ------------------------------------
    -- UPDATE picked_for_planning FLAG
    -- ------------------------------------
    UPDATE 
        ata_plan_these_style_stylecolors 
    SET 
        picked_for_planning = 1 
    WHERE 
        updated_by = v_pivot_user_id 
        AND picked_for_planning = 0
        AND (stylecolor, session_id) IN (SELECT stylecolor, session_id FROM tmp_selected)
    ;

    update ata_cart_master set isProcessed=1 where jsessionid in (select session_id from  tmp_selected);

    insert into ata_cart_master_archive select *, now() from ata_cart_master  where jsessionid in (select session_id from  tmp_selected);
    insert into ata_cart_params_archive select *, now() from ata_cart_params  where jsessionid in (select session_id from  tmp_selected);
    insert into ata_cart_ranging_archive select *, now() from ata_cart_ranging  where jsessionid in (select session_id from  tmp_selected);
    delete from ata_cart_master where jsessionid in (select session_id from tmp_selected);
    delete from ata_cart_params where jsessionid in (select session_id from tmp_selected);
    delete from ata_cart_ranging where jsessionid in (select session_id from tmp_selected);

DROP TABLE IF EXISTS all_un_used_products;
DROP TABLE IF EXISTS tmp_selected;

END;
$$;


--
-- Name: calc_store_count_ranging(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calc_store_count_ranging() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  ssg_array text[] := string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.ssg)), ',');
BEGIN
  IF (ssg_array IS NULL OR array_length(ssg_array, 1) IS NULL OR array_length(ssg_array, 1) = 0) then
   raise notice 'Received edit with no ssg.';
    new.store_count := get_store_count(
      (select slsstart from trd_ma_dptflrsetattributes where time=new.scope_floorset and product=new.scope_product),
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.grade)), ','), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.str_store_climate)), ','), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.str_capacity)), ','), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.str_store_banner)), ','), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.str_geo_region)), ','), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.str_hazmat)), ','),
      new.scope_product);
  else
   raise notice 'Received edit with an ssg.';
    new.store_count := (select array_length(stores, 1) FROM trd_l_ssglookup
      WHERE ssg_id =ANY(ssg_array) AND product = new.scope_product AND location = new.scope_location);
  END IF;
 RETURN new;
END;
$$;


--
-- Name: can_remove_from_assortment(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.can_remove_from_assortment(stylecolorid text, channelid text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
 declare
  scWeekCount INT;
  sizeWeekCount INT;
  scWeekCount_pub INT;
  scWeekCount_eoh INT;
 BEGIN
  scWeekCount_pub = (select COUNT(*) from trd_p_dc_adj 
   where product = stylecolorId 
   and location = (select dc from trd_l_dclookup where channel = channelId)
   and (dc_publish > 0));
  scWeekCount_eoh = (select COUNT(*) from trd_eohdata_stylecolor 
   where product = stylecolorId 
   and channel = channelId
   and (eohu > 0));
  scWeekCount = scWeekCount_pub + scWeekCount_eoh;
  sizeWeekCount = (select COUNT(*) from trd_p_dc_adj_size
   where product in (select id from trd_h_prodstd where ancestor0 = stylecolorId)
   and location = (select dc from trd_l_dclookup where channel = channelId)
   and (dc_onorder > 0 or dc_onorder_ecom > 0));
  return scWeekCount <= 0 and sizeWeekCount <= 0;
 END;
$$;


--
-- Name: check_isprepublishable(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_isprepublishable(stylecolorid text) RETURNS text
    LANGUAGE plpgsql
    AS $$
 declare
 v_isprepublishable text;
 BEGIN
 v_isprepublishable:=1;
 /*
  select
  CASE
          WHEN (
                 COALESCE(length(btrim("substring"(a.erp_stylecolor_id, 1, 1))), 0) 
               ) = 1 
               AND (cc_pim_status is null or cc_pim_status = '' or upper(cc_pim_status) <> 'DROPPED')
               AND (cardinality(c.cc_validsizes_store) > 0 or cardinality(c.cc_validsizes_ecom) > 0)
               AND sty_size_run_name = pim_size_run_name
          THEN '1'::text
          ELSE '0'::text
      END AS isprepublishable
      into v_isprepublishable
  FROM trd_ma_stylecolorattributes a
  JOIN trd_h_prodstd b ON a.product = b.id
  JOIN trd_ma_styleattributes d ON d.product = b.ancestor0
  LEFT OUTER JOIN (select distinct product, cc_validsizes_store, cc_validsizes_ecom
                   from trd_ma_stylecolorchannelattributes
                  ) c ON a.product = c.product
  where a.product = stylecolorid
  ;
*/
  return v_isprepublishable;
 END;
$$;


--
-- Name: check_ispublishable(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_ispublishable(stylecolorid text) RETURNS text
    LANGUAGE plpgsql
    AS $$
 declare
 v_ispublishable text;
 BEGIN
 v_ispublishable:=1;
 /*
  select
  CASE
          WHEN (
                 COALESCE(length(btrim("substring"(a.erp_stylecolor_id, 1, 1))), 0)
               ) = 1 
               AND (cc_pim_status is null or cc_pim_status = '' or upper(cc_pim_status) <> 'DROPPED')
               AND (cardinality(c.cc_validsizes_store) > 0 or cardinality(c.cc_validsizes_ecom) > 0)
               AND sty_size_run_name = pim_size_run_name
          THEN '1'::text
          ELSE '0'::text
      END AS ispublishable
      into v_ispublishable
  FROM trd_ma_stylecolorattributes a
  JOIN trd_h_prodstd b ON a.product = b.id
  JOIN trd_ma_styleattributes d ON d.product = b.ancestor0
  LEFT OUTER JOIN (select distinct product, cc_validsizes_store, cc_validsizes_ecom
                   from trd_ma_stylecolorchannelattributes
                  ) c ON a.product = c.product
  where a.product = stylecolorid
  ;
*/

  return v_ispublishable;
 END;
$$;


--
-- Name: dbt_after_md_trigger_on_update_validity_check(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dbt_after_md_trigger_on_update_validity_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
          UPDATE trd_ma_stylecolorchannelattributes a set dbt_wk = OLD.dbt_wk
          WHERE product=NEW.product
          ;
RETURN NEW;
END;
$$;


--
-- Name: delete_duplicate_invalids(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_duplicate_invalids() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM plan_queue WHERE (product,location) in (select product,location from trd_ma_stylecolorchannelattributes where product = NEW.product
    and location = NEW.location and record_state=1);
  RETURN NEW;
END;
$$;


--
-- Name: delete_records(text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.delete_records(IN v_uid text)
    LANGUAGE plpgsql
    AS $$
DECLARE

v_template_id  text;
v__txid text;
input_uid text;

BEGIN


delete from trd_ma_stylecolorattributes where product in (v_uid);
delete from trd_ma_stylecolorchannelattributes where product in (v_uid);
delete from trd_a_assortment where product in (v_uid);
delete from trd_ma_sizeattributes where product in (Select id from trd_h_prodstd where ancestor0 in (v_uid));
delete from trd_p_dc_adj where product in (v_uid);
delete from trd_p_dc_adj_size where product in (Select id from trd_h_prodstd where ancestor0 in (v_uid));
delete from trd_p_itemprice where product in (v_uid);
delete from trd_p_channeloverride where product in (v_uid);


delete from trd_d_product where id in (v_uid);
delete from trd_d_product where id in (Select ancestor0 from trd_h_prodstd where id in (v_uid));
delete from trd_h_prodstd where id in (v_uid);
delete from trd_h_prodstd where ancestor0 in (v_uid);


END;
$$;


--
-- Name: eval(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eval(expression text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
  result integer;
begin
  execute expression into result;
  return result;
end;
$$;


--
-- Name: exit_trigger_on_update_validity_check(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.exit_trigger_on_update_validity_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE trd_ma_stylecolorchannelattributes a set exitdate = OLD.exitdate
  WHERE product=NEW.product
  ;
  RETURN NEW;
END;
$$;


--
-- Name: fetch_store_count(text, text, text[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_store_count(productid text, floorsetid text, str_grade text[], str_store_climate text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 DECLARE
  sls_start     text;
  dept_var      text;
 BEGIN

 select ancestor3 into dept_var
 from trd_h_prodstd where id = productId;

 select a.slsstart into sls_start
 from trd_ma_dptflrsetattributes a
 where time = floorsetId and product = dept_var;

RETURN(
  SELECT
  count(*)
FROM
  (
    (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as a
    ) as gr
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_store_climate'
            AND value = ANY( str_store_climate )
        ) as a
    ) as ssc USING (store)
  )
 );
 END;
$$;


--
-- Name: fetch_store_count(text, text, text[], text[], text[], text[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_store_count(productid text, floorsetid text, str_grade text[], str_store_climate text[], str_capacity text[], str_store_banner text[], str_geo_region text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 DECLARE
  sls_start     text;
  dept_var      text;
 BEGIN

 select ancestor3 into dept_var
 from trd_h_prodstd where id = productId;

 select a.slsstart into sls_start
 from trd_ma_dptflrsetattributes a
 where time = floorsetId and product = dept_var;

RETURN(
  SELECT
  count(*)
FROM
  (
    (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as a
    ) as gr
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_store_climate'
            AND value = ANY( str_store_climate )
        ) as a
    ) as ssc USING (store)
    INNER JOIN (
            SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_capacity'
            AND value = ANY( str_capacity )
        ) as a
    ) as sc USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_store_banner'
            AND value = ANY( str_store_banner )
        ) as a
    ) as ssb USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
         unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_geo_region'
            AND value = ANY( str_geo_region )
        ) as a
    ) as sgr USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_hazmat'
            AND value = ANY( str_hazmat )
        ) as a
    ) as sh USING (store)
  )
 );
 END;
$$;


--
-- Name: fetch_store_count(text, text, text[], text[], text[], text[], text[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_store_count(productid text, floorsetid text, str_grade text[], str_store_climate text[], str_capacity text[], str_store_banner text[], str_geo_region text[], str_hazmat text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 DECLARE
  sls_start     text;
  dept_var      text;
 BEGIN

 select ancestor3 into dept_var
 from trd_h_prodstd where id = productId;

 select a.slsstart into sls_start
 from trd_ma_dptflrsetattributes a
 where time = floorsetId and product = dept_var;

RETURN(
  SELECT
  count(*)
FROM
  (
    (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as a
    ) as gr
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_store_climate'
            AND value = ANY( str_store_climate )
        ) as a
    ) as ssc USING (store)
    INNER JOIN (
            SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_capacity'
            AND value = ANY( str_capacity )
        ) as a
    ) as sc USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_store_banner'
            AND value = ANY( str_store_banner )
        ) as a
    ) as ssb USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
         unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_geo_region'
            AND value = ANY( str_geo_region )
        ) as a
    ) as sgr USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_hazmat'
            AND value = ANY( str_hazmat )
        ) as a
    ) as sh USING (store)
  )
 );
 END;
$$;


--
-- Name: get_default_params(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_default_params(input_jsessionid text, scope_department text, scope_location text, scope_start text, scope_floorset text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
v_exists integer;
insert_s2 text;
delete_s3 text;
insert_s4 text;
BEGIN
  EXECUTE '(select count(*) from cart_params where 
          jsessionid = '''||$1||'''  
          and scope_product =  '''||$2||'''  
          and scope_location = '''||$3||'''  
    and scope_start = '''||$4||''' 
          )' into v_exists;
  insert_s2 := '
        INSERT INTO cart_params
        (
            jsessionid, scope_product, scope_location, scope_start, scope_floorset
          , initrcptwk
          , dbt_wk
          , planned_sell_down_week
          , too
          , mkdnwks
          , last_rcpt_wk
          , erlstmkdnwk
          , exitdate
          , ccmdstrategy
          , presmin
          , presmin_weeks
          , retpct_str
          , retpct_ecomm
          , retpct_cross
          , ccrcptint
          , ccordermultiple
          , slsrnk_store
          , slsrnk_ecom
		      , irw_debut_offset --Added On 2025_05_13 for ticket SUP-2395

          -- CA MOD 08.14.2025
          , use_act_aps_or_act_rank
          , use_valid_sizes_from
          , apply_size_mins_to
          , cc_addoff_store
          , cc_addoff_ecom
        )
        SELECT distinct
            '''||$1||''','''||$2||''','''||$3||''','''||$4||''','''||$5||'''
          , e.id
          , ap_start
          , default_planned_sell_down_week
          , weeks_at_fp::real
          , c.indx - b.indx as mkdnwks
          , f.id as last_rcpt_wk
          , markdown_week
          , exit_week
          , default_ccmdstrategy
          , default_presmin
          , default_presmin_weeks
          , default_retpct_str
          , default_retpct_ecom
          , default_crosschannel_retpct_ecom
          , default_ccrcptint
          , default_ccordermultiple_uom
          , default_slsrnk_store
          , default_slsrnk_ecom
		  , irw_debut_offset

           -- CA MOD 08.14.2025
           -- UNCOMMENT if those defaults are available in ma_dptflrsetattributes

          , ''Copy Rating''                 -- use_act_aps_or_act_rank
          , ''Defaults – All Valid Sizes''  -- use_valid_sizes_from
          , ''Core Sizes Only''             -- apply_size_mins_to
          , 0.1::real                             -- cc_addoff_store
          , 0.1::real                             -- cc_addoff_ecom

        FROM 
          trd_ma_dptflrsetattributes a, 
          trd_d_time b,
          trd_d_time c,
          trd_d_time d,
          trd_d_time e,
          trd_d_time f
        WHERE 
          product = '''||$2||'''
          and time = '''||$5||'''
          and a.markdown_week = b.id
          and a.exit_week = c.id
          and a.ap_start = d.id
          and d.indx = e.indx + a.irw_debut_offset
          and f.indx = b.indx - 4
          ';
  delete_s3 := ' 
     delete from cart_ranging where jsessionid = '''||$1||''' and scope_product='''||$2||''' 
     and scope_start = '''||$4||''' and scope_floorset = '''||$5||'''  
             ';
  insert_s4 := '
  insert into cart_ranging 
(jsessionid,scope_product,scope_location,scope_start,scope_floorset
   ,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,isfunded, indx, store_count)
select 
  '''||$1||''',product,'''||$3||''','''||$4||''',time, 
    case when cardinality(default_store_vol_grade) = 0 then ''{ECOM,AA,A,B,C,D,E}'' else  default_store_vol_grade end as default_store_vol_grade
  , case when cardinality(default_store_climate) = 0 then ''{"Extreme Cold",Cold,Moderate,Warm,"Very Warm",Hot}'' else  default_store_climate end as default_store_climate
  , case when cardinality(default_store_capacity) = 0 then ''{Alaska,Canada,Hawaii,"Mid Atlantic",Midwest,"Nor Cal",Northeast,"Pac Nwest",Plains,"Puerto Rico","Rocky Mtn","So Cal",Southeast,Southwest,Texas,N}'' else  default_store_capacity end as default_store_capacity
  , case when cardinality(default_store_banner) = 0 then ''{Torrid,Curve}'' else  default_store_banner end as default_store_banner
  , case when cardinality(default_store_geo_region) = 0 then ''{"Very High",High,Average,Low,"Very Low",N}'' else  default_store_geo_region end as default_store_geo_region
  , case when cardinality(default_store_hazmat) = 0 then ''{No,Yes}'' else  default_store_hazmat end as default_store_hazmat
  , isfunded
  , indx
  , store_count
  FROM (
  select product, time,default_store_vol_grade,default_store_climate,default_store_capacity,default_store_banner,default_store_geo_region,default_store_hazmat
   ,1 as isfunded, a.indx, 
   get_store_count('''||$4||''', 
                   case when cardinality(default_store_vol_grade) = 0 then ''{ECOM,AA,A,B,C,D,E}'' else  default_store_vol_grade end,
                   case when cardinality(default_store_climate) = 0 then ''{"Extreme Cold",Cold,Moderate,Warm,"Very Warm",Hot}'' else  default_store_climate end,
                   case when cardinality(default_store_capacity) = 0 then ''{Alaska,Canada,Hawaii,"Mid Atlantic",Midwest,"Nor Cal",Northeast,"Pac Nwest",Plains,"Puerto Rico","Rocky Mtn","So Cal",Southeast,Southwest,Texas,N}'' else  default_store_capacity end,
                   case when cardinality(default_store_banner) = 0 then ''{Torrid,Curve}'' else  default_store_banner end,
                   case when cardinality(default_store_geo_region) = 0 then ''{"Very High",High,Average,Low,"Very Low",N}'' else  default_store_geo_region end,
                   case when cardinality(default_store_hazmat) = 0 then ''{No,Yes}'' else  default_store_hazmat end, 
                   product
                  ) as store_count
  FROM trd_ma_dptflrsetattributes a, cart_params b,
   (select value as plan_current from trd_serviceparams where id=''plan_current'') c,
   (select value as plan_end from trd_serviceparams where id=''plan_end'') d
  where 
  b.jsessionid = '''||$1||'''
  and b.scope_product = '''||$2||'''
  and b.scope_location = '''||$3||'''
  and a.product = b.scope_product
     and a.ap_start <= least(d.plan_end,b.exitdate) and a.ap_end > greatest(b.dbt_wk,c.plan_current)
  )X
        ';
  IF  v_exists = 0
  THEN
  EXECUTE insert_s2;
  EXECUTE delete_s3;  
  EXECUTE insert_s4;
  END IF;
 RETURN;
END;
$_$;


--
-- Name: get_store_count(text, text[], text[], text[], text[], text[], text[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_store_count(week text, str_grade text[], str_store_climate text[], str_capacity text[], str_store_banner text[], str_geo_region text[], str_hazmat text[], productval text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 BEGIN
RETURN(
  SELECT
  count(*)
FROM
  (
    (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as a
    ) as gr
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_store_climate'
            AND value = ANY( str_store_climate )
        ) as a
    ) as ssc USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_capacity'
            AND value = ANY( str_capacity )
        ) as a
    ) as sc USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_store_banner'
            AND value = ANY( str_store_banner )
        ) as a
    ) as ssb USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_geo_region'
            AND value = ANY( str_geo_region )
        ) as a
    ) as sgr USING (store)
    INNER JOIN (
      SELECT
        distinct(a.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            trd_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_hazmat'
            AND value = ANY( str_hazmat )
        ) as a
    ) as sh USING (store)
  )
 );
 END;
$$;


--
-- Name: itemprice_fetchdepartment(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.itemprice_fetchdepartment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    department text;
BEGIN
    select ancestor3 into department from trd_h_prodstd where id = NEW.product;
    NEW.department = department;
    return NEW;
END;
$$;


--
-- Name: lifecycle_plan_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.lifecycle_plan_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

update trd_p_dc_adj
set
  dc_uservrp = null,
  dc_useradj = null
WHERE
product = NEW.product
and time >= NEW.erlstmkdnwk;

update trd_p_dc_adj_size
set
  dc_uservrp = null,
  dc_useradj = null
WHERE
product in (select id from trd_h_prodstd where ancestor0 = NEW.product)
and time >= NEW.erlstmkdnwk;

RETURN NEW;
END;
$$;


--
-- Name: md_trigger_on_update_validity_check(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.md_trigger_on_update_validity_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE trd_ma_stylecolorchannelattributes a set erlstmkdnwk = OLD.erlstmkdnwk
  WHERE product=NEW.product
  ;
  RETURN NEW;
END;
$$;


--
-- Name: notify_pivot_execution_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_pivot_execution_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN EXECUTE 'NOTIFY pivot_execution_change';
            RETURN NEW; END; $$;


--
-- Name: notify_plan_queue_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_plan_queue_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  EXECUTE 'NOTIFY plan_queue_change';
  RETURN NEW;
END;
$$;


--
-- Name: on_publish_remove_from_worklist(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.on_publish_remove_from_worklist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  DELETE FROM user_worklist WHERE user_id = NEW.updated_by and product=NEW.worklist_id;
  RETURN NEW;
  
END;
$$;


--
-- Name: on_unpublish_remove_from_worklist(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.on_unpublish_remove_from_worklist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  DELETE FROM user_worklist WHERE user_id = NEW.updated_by and (product=NEW.worklist_id OR product in (select worklist_id from worklist_map where product=NEW.product));
  INSERT INTO user_worklist (user_id, product) select updated_by, worklist_id from trd_p_stylecolor_worklist
  where updated_by=NEW.updated_by and worklist_id=NEW.worklist_id ; 
  RETURN NEW;
  
END;
$$;


--
-- Name: plan_eligible(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.plan_eligible(products text[]) RETURNS TABLE(product text, location text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT scca.product, scca.location
            FROM trd_ma_stylecolorchannelattributes scca INNER JOIN UNNEST(products) arg
            ON scca.product=arg
            WHERE scca.record_state=0;
        END
        $$;


--
-- Name: propagate_assortment_to_floorsets(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.propagate_assortment_to_floorsets() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
sls_start     text;
dept_var      text;
BEGIN

  select ancestor3 into dept_var
  from trd_h_prodstd where id = NEW.product;

  select a.slsstart into sls_start 
  from trd_ma_dptflrsetattributes a
  where time = NEW.time and product = dept_var;

  -- 
  if (cardinality(OLD.SSG) > 0 or OLD.SSG is not null) 
    and (cardinality(OLD.str_grade)         = 0 and
         cardinality(OLD.str_store_climate) = 0 and
         cardinality(OLD.str_capacity)      = 0 and
         cardinality(OLD.str_store_banner)  = 0 and
         cardinality(OLD.str_geo_region)    = 0 and
         cardinality(OLD.str_hazmat)        = 0 
        ) 
    and (cardinality(NEW.str_grade) > 0 or
         cardinality(NEW.str_store_climate) > 0 or
         cardinality(NEW.str_capacity) > 0 or
         cardinality(NEW.str_store_banner) > 0 or
         cardinality(NEW.str_geo_region) > 0 or
         cardinality(NEW.str_hazmat) > 0
        ) 
  then
      NEW.SSG := '{}'::text[];

      if cardinality(NEW.str_grade) = 0 then 
        select default_store_vol_grade into NEW.str_grade from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
      if cardinality(NEW.str_store_climate) = 0 then
        select default_store_climate into NEW.str_store_climate from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
      if cardinality(NEW.str_capacity) = 0 then
        select default_store_capacity into NEW.str_capacity from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
      if cardinality(NEW.str_store_banner) = 0 then
        select default_store_banner into NEW.str_store_banner from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
      if cardinality(NEW.str_geo_region) = 0 then
        select default_store_geo_region into NEW.str_geo_region from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
      if cardinality(NEW.str_hazmat) = 0 then
        select default_store_hazmat into NEW.str_hazmat from trd_ma_dptflrsetattributes where time = NEW.time and product = dept_var;
      end if;
  elsif (cardinality(OLD.SSG) = 0 or OLD.SSG is null) 
    and (cardinality(OLD.str_grade)         > 0 or
         cardinality(OLD.str_store_climate) > 0 or
         cardinality(OLD.str_capacity)      > 0 or
         cardinality(OLD.str_store_banner)  > 0 or
         cardinality(OLD.str_geo_region)    > 0 or
         cardinality(OLD.str_hazmat)        > 0
        ) 
    and cardinality(NEW.ssg) > 0
   then
      NEW.str_grade              :=  '{}'::text[];
      NEW.str_store_climate      :=  '{}'::text[];
      NEW.str_capacity           :=  '{}'::text[];
      NEW.str_store_banner       :=  '{}'::text[];
      NEW.str_geo_region         :=  '{}'::text[];
      NEW.str_hazmat             :=  '{}'::text[];
         
  end if;

  if cardinality(NEW.SSG) = 0 or NEW.SSG is null then 
  
      NEW.store_count := get_store_count(
                                           sls_start
                                          ,NEW.str_grade
                                          ,NEW.str_store_climate
                                          ,NEW.str_capacity
                                          ,NEW.str_store_banner
                                          ,NEW.str_geo_region
                                          ,NEW.str_hazmat
                                          ,dept_var
                                        );
  else 
      select cardinality(stores) into NEW.store_count
      from trd_l_ssglookup 
      where ssg_id = array_to_string(NEW.SSG, ',')
        and product = dept_var;

  end if;

  update trd_a_assortment a
  set str_grade = NEW.str_grade
     ,str_store_climate = NEW.str_store_climate
     ,str_capacity = NEW.str_capacity
     ,str_store_banner = NEW.str_store_banner
     ,str_geo_region = NEW.str_geo_region
     ,str_hazmat = NEW.str_hazmat
     ,str_grade_or = NEW.str_grade_or
     ,str_store_climate_or = NEW.str_store_climate_or
     ,str_capacity_or = NEW.str_capacity_or
     ,str_store_banner_or = NEW.str_store_banner_or
     ,str_geo_region_or = NEW.str_geo_region_or
     ,str_hazmat_or = NEW.str_hazmat_or
     ,ssg = NEW.ssg
     ,store_count = NEW.store_count
  where product = NEW.product
    and location = NEW.location
    and time in (select id from trd_d_time where indx >= (select indx from trd_d_time where id = NEW.time) and time in (select time from trd_a_assortment where product = NEW.product and location = NEW.location))
  ;

  RETURN NEW;

END;
$$;


--
-- Name: remove_from_assortment(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.remove_from_assortment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_count integer;
v_specstyleid text;
v_specstylecolorid text;
v_index text;
v_subclass text;
BEGIN

IF NEW.cloned_at IS NOT NULL THEN
  RETURN NEW;
END IF;

  select sty_vpn into v_specstyleid 
  from trd_ma_styleattributes where product = (select ancestor0 from trd_h_prodstd where id = NEW.product) ;

  select cc_vpn_color into v_specstylecolorid
  from trd_ma_stylecolorattributes where product = NEW.product;

  select ancestor1 into v_subclass from trd_h_prodstd where id = NEW.product;

  if v_specstylecolorid is not null then
    update trd_ma_stylecolorattributes a
    set cc_vpn_color = null
    where product = NEW.product;

    select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from trd_l_dependencylookup;

    insert into trd_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
    values('specstyle_id', v_specstyleid, 'specstylecolor_id', v_specstylecolorid, v_index);
  end if;

  select count(*) into rec_count
  from trd_ma_stylecolorchannelattributes 
  where record_state = 0
  and product in (select id from trd_h_prodstd where ancestor0 in (select ancestor0 from trd_h_prodstd where id = NEW.product));

  if rec_count = 0 and v_specstyleid is not null then
    update trd_ma_styleattributes set sty_vpn = null
    where product in (select ancestor0 from trd_h_prodstd where id = NEW.product);
    --if v_specstyleid is not null then
    --  select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from trd_l_dependencylookup;
    --
    --  insert into trd_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
    --  values('subclass', v_subclass, 'specstyle_id', v_specstyleid, v_index);
    --end if;
  end if;

  RETURN NEW;
END;
$$;


--
-- Name: reset_to_prev_if_approved(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_to_prev_if_approved() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_clustering_status real;
BEGIN
    -- Fetch clustering status for the current store_cluster_id
    SELECT clustering_status 
    INTO v_clustering_status
    FROM trd_p_approvedclusters 
    WHERE cluster_id = NEW.store_cluster_id;

    -- Update reassigned_cluster based on the clustering status
    UPDATE trd_p_reassigncluster 
    SET reassigned_cluster = CASE 
                                WHEN v_clustering_status = 1 THEN OLD.reassigned_cluster 
                                ELSE NEW.reassigned_cluster 
                             END
    WHERE 
        store_cluster_id = NEW.store_cluster_id
    and product = NEW.product 
    and location = NEW.location 
    and time = NEW.time
    ;

    -- Return the NEW record
    RETURN NEW;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case where no cluster_id is found in trd_p_approvedclusters
        RAISE NOTICE 'No clustering status found for store_cluster_id %', NEW.store_cluster_id;
        RETURN NEW;
    WHEN OTHERS THEN
        -- Handle other exceptions
        RAISE NOTICE 'An error occurred: %', SQLERRM;
        RETURN NEW;
END;
$$;


--
-- Name: revert_to_original(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.revert_to_original() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

  RETURN NULL;
END;
$$;


--
-- Name: set_floorset_fields_on_initrcptwk_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_floorset_fields_on_initrcptwk_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_dept              text;  -- ancestor3
  v_superset_id       text;
  v_superset_name     text;
  v_time              text;
  v_floorset_uda      text;
  v_floorset_uda_name text;
BEGIN
  IF TG_OP = 'INSERT'
     OR (TG_OP = 'UPDATE' AND NEW.initrcptwk IS DISTINCT FROM OLD.initrcptwk) THEN

    IF NEW.initrcptwk IS NULL THEN
      RETURN NEW;
    END IF;

    -- product -> ancestor3 (department)
    SELECT h.ancestor3
      INTO v_dept
    FROM trd_h_prodstd h
    WHERE h.id = NEW.product
    LIMIT 1;

    IF v_dept IS NOT NULL THEN
      -- pick the floorset row whose receipt window contains NEW.initrcptwk
      SELECT
          d.superset_id::text,
          d.superset_name::text,
          d."time"::text,
          d.floorset_uda::text,
          substr(d.floorset_uda, 4)   -- adjust if your naming isn’t prefix-based
      INTO v_superset_id, v_superset_name, v_time, v_floorset_uda, v_floorset_uda_name
      FROM trd_ma_dptflrsetattributes d
      WHERE d.product = v_dept
        AND NEW.initrcptwk >= d.rcptstart
        AND NEW.initrcptwk <= d.rcptend
      ORDER BY d.rcptstart DESC
      LIMIT 1;

      -- write back only when found
      IF v_superset_id IS NOT NULL THEN
        NEW.irw_superset := v_superset_id;
      END IF;

      IF v_superset_name IS NOT NULL THEN
        NEW.irw_superset_display := v_superset_name;
      END IF;

      IF v_time IS NOT NULL THEN
        NEW.irw_floorset_id := v_time;
      END IF;

      IF v_floorset_uda IS NOT NULL THEN
        NEW.irw_floorset := v_floorset_uda;
      END IF;

      IF v_floorset_uda_name IS NOT NULL THEN
        NEW.irw_floorset_display := v_floorset_uda_name;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: set_sty_vpn_desc_on_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_sty_vpn_desc_on_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_key  text;
  v_desc text;
BEGIN
  IF NEW.sty_vpn IS DISTINCT FROM OLD.sty_vpn THEN
    v_key := NULLIF(btrim(NEW.sty_vpn), '');
    IF v_key IS NULL THEN
      NEW.sty_vpn_desc := NULL;
      RETURN NEW;
    END IF;

    SELECT v_key || ' : ' || s.vpn_description
      INTO v_desc
    FROM trd_ma_specstylecolorattributes s
    WHERE s.vpn_vsn = v_key
    LIMIT 1;

    NEW.sty_vpn_desc := v_desc;  -- NULL if no match
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: set_vpn_color_desc_on_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_vpn_color_desc_on_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_key  text;
  v_desc text;
BEGIN
  IF NEW.cc_vpn_color IS DISTINCT FROM OLD.cc_vpn_color THEN
    v_key := NULLIF(btrim(NEW.cc_vpn_color), '');
    IF v_key IS NULL THEN
      NEW.vpn_color_desc := NULL;
      RETURN NEW;
    END IF;

    SELECT s.vpn_color_description
      INTO v_desc
    FROM trd_ma_specstylecolorattributes s
    WHERE s.vpn_color = v_key
    LIMIT 1;

    NEW.vpn_color_desc := v_desc;  -- NULL if no match
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: sizerangecode_isvalid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sizerangecode_isvalid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    s1 text;
    s2 text;
    s3 text;

    table_temp_isvalid_master text;
    v_uuid_temp text;
    v_uuid text;
 v_product text;
 v_location text;
BEGIN
EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;
table_temp_isvalid_master:= 'temp_isvalid_master'||v_uuid;
v_product=NEW.product;
v_location=NEW.location;
s1 := 'create temporary table '||table_temp_isvalid_master||' as 
  select distinct '''||v_product||''' as product,  '''||v_location||''' as location, unnest(validsizes) validsizes, 1 as isvalid from trd_ma_stylecolorchannelattributes
  where 
  product= '''||v_product||'''
  and location= '''||v_location||'''
    ';
EXECUTE s1;
s2 := '
  update trd_ma_sizeattributes 
  set isvalid=0
  where parent_id='''||v_product||'''
  ';
EXECUTE s2;
s3 := '
  update trd_ma_sizeattributes a
  set isvalid=b.isvalid
  from '||table_temp_isvalid_master||' b
  where a.parent_id=b.product
  and a.sizeattribute=b.validsizes
  ';
EXECUTE s3;
  RETURN NEW;
END;
$$;


--
-- Name: sizerangecode_validsizes_members(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sizerangecode_validsizes_members() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  table_temp_rangecode_master text;
  v_uuid text;
  v_product text := NEW.product;
  v_location text := NEW.location;
  v_ccrangecode text := NEW.ccrangecode;
  v_sty_size_range text;
BEGIN
  -- Parse size range safely
  v_sty_size_range := split_part(v_ccrangecode, ' - CL-', 1);

  -- Temp table name
  SELECT replace(uuid_generate_v4()::text, '-', '_') INTO v_uuid;
  table_temp_rangecode_master := format('table_temp_rangecode_master_%s', v_uuid);

  -- Build work table
  EXECUTE format('DROP TABLE IF EXISTS %I', table_temp_rangecode_master);
  EXECUTE format(
    'CREATE TEMP TABLE %I ON COMMIT DROP AS
       SELECT DISTINCT $1::text AS product,
                        $2::text AS location,
                        lookup_value AS ccrangecode,
                        target_value AS master_size_attr,
                        uuid_generate_v4()::text AS memberid,
                        0::int AS member_exists,
                        b.parent_size AS item_diff_2,
                        b.size_id     AS item_diff_3
         FROM trd_l_dependencylookup a
         JOIN trd_size_range_mapping b
           ON a.lookup_value = b.size_range AND a.target_value = b.size_desc
        WHERE a.lookup_id = ''size_range''
          AND a.lookup_value = $3::text', table_temp_rangecode_master)
  USING v_product, v_location, v_sty_size_range;

  -- Tag existing members
  EXECUTE format(
    'UPDATE %I a
        SET memberid = b.product, member_exists = 1
       FROM trd_ma_sizeattributes b
      WHERE a.product = b.parent_id AND a.master_size_attr = b.sizeattribute',
    table_temp_rangecode_master);

  -- Invalidate current children
  UPDATE trd_ma_sizeattributes
     SET isvalid = 0
   WHERE parent_id = v_product;

  -- Remove dup rows about to refresh
  EXECUTE format(
    'DELETE FROM trd_ma_sizeattributes
      WHERE product IN (SELECT memberid FROM %I)', table_temp_rangecode_master);

  -- Insert/refresh members
  EXECUTE format(
    'INSERT INTO trd_ma_sizeattributes (product, sizeattribute, parent_id, isvalid, item_diff_2, item_diff_3)
     SELECT  memberid, master_size_attr, product, 1 as isvalid, item_diff_2, item_diff_3 FROM %I',
    table_temp_rangecode_master);

  -- Ensure dim rows exist for new members
  EXECUTE format(
    'DELETE FROM trd_d_product WHERE id IN (SELECT memberid FROM %I WHERE member_exists=0);',
    table_temp_rangecode_master);
  EXECUTE format(
    'INSERT INTO trd_d_product (id, name, description, levelid)
     SELECT memberid, product||''-''||master_size_attr, product||''-''||master_size_attr, ''stylecolorsize''
       FROM %I WHERE member_exists=0;',
    table_temp_rangecode_master);

  -- Copy hierarchy for new members
  EXECUTE format(
    'DELETE FROM trd_h_prodstd WHERE id IN (SELECT memberid FROM %I WHERE member_exists=0);',
    table_temp_rangecode_master);
  EXECUTE format(
    'INSERT INTO trd_h_prodstd
           (id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4, ancestor5, version_id, created_at, created_by, updated_at, updated_by, record_state)
     SELECT memberid  ,id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4, version_id, created_at, created_by, updated_at, updated_by,record_state
       FROM trd_h_prodstd h
       JOIN (SELECT memberid, product FROM %I WHERE member_exists=0) t
         ON h.id = t.product;',
    table_temp_rangecode_master);

  -- Clear DC user adj for invalidated sizes
  UPDATE trd_p_dc_adj_size a
     SET dc_useradj = NULL
   WHERE product IN (
         SELECT product
           FROM trd_ma_sizeattributes
          WHERE isvalid = 0 AND parent_id = v_product
       );

  RETURN NEW;
END;
$_$;


--
-- Name: store_eligibility_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.store_eligibility_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_relaunchweek text;
BEGIN
    --RAISE NOTICE 'OLD.dbt_wk: %', OLD.dbt_wk;
    --RAISE NOTICE 'OLD.relaunchweek: %', OLD.relaunchweek;
    --RAISE NOTICE 'OLD.exitdate: %', OLD.exitdate;
    --RAISE NOTICE 'NEW.dbt_wk: %', NEW.dbt_wk;
    --RAISE NOTICE 'NEW.relaunchweek: %', NEW.relaunchweek;
    --RAISE NOTICE 'NEW.exitdate: %', NEW.exitdate;
    v_relaunchweek := Case When NEW.relaunchweek = '' THEN null Else NEW.relaunchweek END;
    drop table if exists temp_new;
    drop table if exists temp_old;
    create temporary table temp_new as 
    select b.product,b.location,a.indx,a.time from trd_ma_dptflrsetattributes a, trd_ma_stylecolorchannelattributes b
    where 
    a.product in (select ancestor3 from trd_h_prodstd where id=NEW.product)
    and b.product = NEW.product
    and b.location = NEW.location
    and ap_start <= NEW.exitdate and ap_end >= COALESCE(v_relaunchweek, NEW.dbt_wk)
    order by indx;
    create temporary table temp_old as 
    select a.product,a.location,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style,indx, isfunded, store_count
    from trd_a_assortment a, trd_ma_dptflrsetattributes b
    where b.product in (select ancestor3 from trd_h_prodstd where id=NEW.product)
    and a.product= NEW.product
    and a.location= NEW.location
    and a.time=b.time;
    delete from trd_a_assortment where product = NEW.product and location = NEW.location and plan_type='plan' and EXISTS (select 1 from temp_new) ;
        insert into trd_a_assortment 
        (product,location,time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style, isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||min(indx) from temp_old group by product, location)
        and c.indx < a.indx;

        insert into trd_a_assortment 
        (product,location,time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style, isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||max(indx) from temp_old group by product, location)
        and c.indx > a.indx  
        order by c.indx ;

        insert into trd_a_assortment 
        (product,location,time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,plan_type, style,isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and c.indx = a.indx;

    drop table temp_new;
    drop table temp_old;
    -- Make first floorset funded
    update trd_a_assortment 
    set isfunded = 1 
    from 
        (select d.time, c.product, COALESCE(c.relaunchweek, c.dbt_wk) as dbt_wk, d.ap_start, d.ap_end  from trd_ma_stylecolorchannelattributes as c 
          join (select distinct a.time, a.product, b.ap_start,b.ap_end from trd_a_assortment a 
          join (select c.time,ap_start,ap_end from trd_ma_dptflrsetattributes c) as b 
        on (a.time=b.time) where a.product=new.product) as d 
    on (c.product=d.product) 
    where c.dbt_wk >= d.ap_start 
    and c.dbt_wk <= d.ap_end) filtered 
    where trd_a_assortment.time=filtered.time and trd_a_assortment.product=filtered.product;
 RETURN NEW;
END;
$$;


--
-- Name: trd_no_style_clone_stylecolor_size_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_no_style_clone_stylecolor_size_proc(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_session_id    TEXT := p_session_id;
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN

    

    --------------------------------------------------------------------
    -- Build temp flat_map for this session
    --------------------------------------------------------------------
    CREATE TEMPORARY TABLE trd_style_clone_flat_map_temp AS
    SELECT * 
    FROM (
        /*
        SELECT DISTINCT
            from_style        AS from_id,
            to_new_style      AS to_id,
            'style'           AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , to_new_style_name as to_name
            , to_new_style_desc as to_desc
            , '' as cccolor
            , '' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_style IS NOT NULL AND from_style <> ''
          AND session_id = v_session_id

        UNION ALL
        */        
        SELECT DISTINCT
            from_stylecolor   AS from_id,
            to_new_stylecolor AS to_id,
            'stylecolor'      AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , to_new_stylecolor_name as to_name
            , to_new_stylecolor_desc as to_desc
            , RIGHT(to_new_stylecolor_name, 8) as cccolor
            , 'TBD' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_stylecolor IS NOT NULL AND from_stylecolor <> ''
          AND session_id = v_session_id

        UNION ALL
        SELECT DISTINCT
            from_stylecolorsize   AS from_id,
            to_new_stylecolorsize AS to_id,
            'stylecolorsize'      AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , '' as to_name 
            , '' as to_desc
            , '' as cccolor
            , '' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_stylecolorsize IS NOT NULL AND from_stylecolorsize <> ''
          AND session_id = v_session_id
    ) x;


    --------------------------------------------------------------------
    -- d_product insert
    --------------------------------------------------------------------
        INSERT INTO trd_d_product (
            id,client_id,name,description,levelid,indx,eventdate,version_id,created_at,created_by,updated_at,updated_by,record_state
        )
        SELECT DISTINCT 
              to_id
            , null as client_id
            , CASE WHEN a.levelid='stylecolorsize' THEN name ELSE to_name END
            , CASE WHEN a.levelid='stylecolorsize' THEN description ELSE to_desc END 
            , a.levelid
            , indx
            
            , now()::date
            , version_id
            , now()
            , v_pivot_user_id
            , now()
            , v_pivot_user_id
            , record_state
        FROM trd_style_clone_flat_map_temp a,
             trd_d_product b
        WHERE a.from_id = b.id
        ;

/*
    --------------------------------------------------------------------
    -- STYLE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_style,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_style = b.id
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

*/
    --------------------------------------------------------------------
    -- STYLECOLOR insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_stylecolor,
            to_new_style,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_stylecolor = b.id
          AND from_style = b.ancestor0
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;


    --------------------------------------------------------------------
    -- STYLECOLORSIZE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_stylecolorsize,
            to_new_stylecolor,
            to_new_style,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_stylecolorsize = b.id
          AND a.from_stylecolor = b.ancestor0
          AND from_style = b.ancestor1
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

/*
    --------------------------------------------------------------------
    -- STYLEATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_styleattributes (
            product,
            sty_knit_or_woven,
            sty_fabrication,
            sty_sleeve_length,
            sty_leg_opening,
            sty_brand,
            sty_body_style_silhouette,
            sty_occasion_usage,
            sty_detail,
            sty_finish_style,
            sty_private_label,
            sty_license,
            sty_license_vs_non_licensed,
            sty_hazmat_code,
            sty_prop_65_warning,
            sty_material_content,
            sty_item_type,
            sty_dwrise,
            sty_length,
            sty_neckline,
            sty_toeshape,
            sty_heel_height,
            sty_bottom_length,
            sty_v_360_smoothing,
            sty_franchise,
            sty_key_item,
            sty_single_vs_multi_pack,
            sty_ticket_type,
            sty_vpn,
            sty_size_range,
            ccstylecreatedate,
            sty_is_locked,
            sty_s5_adopted,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            plm_size_range,
            sty_knit_fit,
            sty_patterned_after,
            sty_vpn_desc
        )
        SELECT
            to_id,
            sty_knit_or_woven,
            sty_fabrication,
            sty_sleeve_length,
            sty_leg_opening,
            sty_brand,
            sty_body_style_silhouette,
            sty_occasion_usage,
            sty_detail,
            sty_finish_style,
            sty_private_label,
            sty_license,
            sty_license_vs_non_licensed,
                null as sty_hazmat_code,
                null as sty_prop_65_warning,
            sty_material_content,
            sty_item_type,
            sty_dwrise,
            sty_length,
            sty_neckline,
            sty_toeshape,
            sty_heel_height,
            sty_bottom_length,
            sty_v_360_smoothing,
            sty_franchise,
            sty_key_item,
            sty_single_vs_multi_pack,
                null as sty_ticket_type,
                null as sty_vpn,
            sty_size_range,
                null as ccstylecreatedate,
                null as sty_is_locked,
                null as sty_s5_adopted,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
                null as plm_size_range,
                sty_knit_fit,
                sty_patterned_after,
                null as sty_vpn_desc
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_styleattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'style'
            ON CONFLICT (product) DO NOTHING
    ;
    
*/   
    --------------------------------------------------------------------
    -- STYLECOLORATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_stylecolorattributes (
            product,
            cc_item_diff_1,
            cc_unit_retail,
            cc_unit_retail_cad,
            cc_pattern,
            cc_graphic,
            cc_fashion_basic,
            cc_holiday,
            cc_property_type,
            cc_internet_exclusive,
            cc_web_color_discription,
            cc_export_hts,
            cc_commercial_invoice_description,
            cc_season_code,
            cc_dtr,
            cc_dw_color_family,
            cc_channel_reorder,
            cc_ticket_season_code,
            cc_sub_programs,
            cc_music_genre,
            cc_clearance_str_product,
            cc_po_supplier,
            cc_origin_country_id,
            cc_country_of_sourcing,
            cc_country_of_manufacturing,
            cc_unit_cost,
            cc_freight,
            cc_royalty,
            cc_duty,
            cc_ship_method,
            cc_lading_port,
            cc_hts,
            cc_primary_supplier,
            cc_sub_brand,
            cc_pattern_type,
            cc_pop_print_neutral,
            cc_debut_season_code,
            cc_matchback,
            cc_primary_collection,
            cc_secondary_collection,
            cc_vpn_color,
            cc_orig_unit_retail,
            cc_orig_unit_retail_cad,
            cc_first_rec_week,
            cc_first_inv_week,
            cc_first_sale_week,
            cc_first_md_week,
            cc_last_md_week,
            cc_last_rec_week,
            cc_store_price_status,
            cc_ifc_price_status,
            cc_omni_price_type,
            ccstylecolorcreatedate,
            cc_price_band,
            cc_good_better_best,
                cccolor,
                cccolorfamily,
            total_brand_name,
            division_name,
            group_name,
            department_name,
            class_name,
            subclass_name,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            isassortment,
            merch_comments,
            plan_comments,
            cc_is_locked,
            cc_s5_adopted,
            cc_prepublish,
            cc_prepublished_at,
            allocator_comments,
            cccolorid,
            cc_specstylecolor_status,
            cc_agent_fee,
            cc_port,
            cc_factory,
            cc_floorset,
            cc_use_sys_floorset,
            cc_supp_cost,
            cc_finish,
            cc_license,
            cc_channel_availability,
            cc_extended_size,
            cc_op_markdown_week,
            cc_motif,
            cc_rp_revised_markdown_week,
            cc_web_current_retail,
            cc_parent_season_code,
            cc_art_code,
            cc_patterned_after,
            cc_material_content,
            cc_fabrication,
            style_name,
            stylecolor_name,
            buyer_email,
            cc_buyer,
            cc_patterned_after_name,
            vpn_color_desc
        )
        SELECT
            to_id,
            cc_item_diff_1,
            --SUP-3351 cc_unit_retail and cc_unit_retail_cad need to be copied from like item
            cc_unit_retail,
            cc_unit_retail_cad,
            cc_pattern,
            cc_graphic,
            cc_fashion_basic,
            cc_holiday,
            cc_property_type,
            cc_internet_exclusive,
            cc_web_color_discription,
                null as cc_export_hts,
                null as cc_commercial_invoice_description,
            cc_season_code,
            cc_dtr,
            cc_dw_color_family,
            cc_channel_reorder,
                null as cc_ticket_season_code,
            cc_sub_programs,
            cc_music_genre,
            cc_clearance_str_product,
                null as cc_po_supplier,
                null as cc_origin_country_id,
                null as cc_country_of_sourcing,
                null as cc_country_of_manufacturing,
                null as cc_unit_cost,
                null as cc_freight,
                null as cc_royalty,
                null as cc_duty,
                null as cc_ship_method,
                null as cc_lading_port,
                null as cc_hts,
                null as cc_primary_supplier,
            cc_sub_brand,
            cc_pattern_type,
            cc_pop_print_neutral,
            cc_debut_season_code,
            cc_matchback,
            cc_primary_collection,
            cc_secondary_collection,
                null as cc_vpn_color,
            cc_orig_unit_retail,
            cc_orig_unit_retail_cad,
                null as cc_first_rec_week,
                null as cc_first_inv_week,
                null as cc_first_sale_week,
                null as cc_first_md_week,
                null as cc_last_md_week,
                null as cc_last_rec_week,
            cc_store_price_status,
            cc_ifc_price_status,
            cc_omni_price_type,
                null as ccstylecolorcreatedate,
            cc_price_band,
            cc_good_better_best,
                a.cccolor,
                a.cccolorfamily,
            total_brand_name,
            division_name,
            group_name,
            department_name,
            class_name,
            subclass_name,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            isassortment,
                null as merch_comments,
                null as plan_comments,
                null as cc_is_locked,
                null as cc_s5_adopted,
                null as cc_prepublish,
                null as cc_prepublished_at,
                null as allocator_comments,
                a.cccolor,
            cc_specstylecolor_status,
                null as cc_agent_fee,
                null as cc_port,
                null as cc_factory,
            cc_floorset,
            cc_use_sys_floorset,
                null as cc_supp_cost,
            cc_finish,
            cc_license,
            cc_channel_availability,
            cc_extended_size,
                null as cc_op_markdown_week,
            cc_motif,
            cc_rp_revised_markdown_week,
                null as cc_web_current_retail,
            cc_parent_season_code,
            cc_art_code,
                cc_patterned_after,
                null as cc_material_content,
            cc_fabrication,
                style_name,
                stylecolor_name,
            buyer_email,
            cc_buyer,
                cc_patterned_after_name,
                null as vpn_color_desc
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_stylecolorattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- SIZEATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_sizeattributes (
            product,
            parent_id,
            item_diff_2,
            item_diff_3,
            sizeattribute,
            isvalid,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            ccctylecolorsizecreatedate
        )
        SELECT
            to_new_stylecolorsize,
            to_new_stylecolor,
            item_diff_2,
            item_diff_3,
            sizeattribute,
            isvalid,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            NULL
        FROM trd_style_clone_stylecolor_size a,
             trd_ma_sizeattributes b
        WHERE a.from_stylecolorsize = b.product
          AND a.from_stylecolor = b.parent_id
          AND a.session_id = v_session_id
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- STYLECOLORCHANNELATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_stylecolorchannelattributes (
            product,
            location,
            dbt_wk,
            relaunchweek,
            erlstmkdnwk,
            exitdate,
            initrcptwk,
            too,
            mkdnwks,
            last_inv_wk,
            lstfpwk,
            last_rcpt_wk,
            lastdcorder,
            act_initrcptwk,
            act_dbt_wk,
            irw_indx,
            dbtwk_indx,
            relaunchwk_indx,
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            preview_wks,
            preview_qty,
            plannedselldnwk,
            ccmdstrategy,
            slsrnk_store,
            slsrnk_ecom,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            cc_presmin,
            cc_presmin_weeks,
            cc_rcptint,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            cc_return_u_pct_cross,
            cc_ordermultiple,
            cc_ordermin,
            cc_buy_aps_letter,
            ccticketpricechannel,
            ccticketpricechannel_override,
            cc_imupct,
            cc_discount_pct,
            cc_existingwac,
            cc_systemcost,
            cc_plan_cost,
            ssnprf,
            adjaps_store,
            adjaps_ecom,
            smoothing_strategy,
            in_season_flag,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            cc_lead_time,
            cc_service_level,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            cc_store_min_multiple,
            planned_sell_down_week,
            cc_selected_clusters,
            cc_cluster_group,
            keep_initial_range_plan,
            cc_sizeelig_rangecode,
            cc_presmin_stylecolor,
            cc_presmin_weeks_stylecolor,
            cc_final_cost,
            cc_discount_pct_store,
            cc_discount_pct_ecom,
            irw_debut_offset,
            cc_service_level_ecom,
            cc_first_publish_date,
            cc_first_publish_snapshot_op,
            sclr_alloc_max,
            sclr_presmin,
            sclr_alloc_min,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_fringe_flag,
            act_slsrnk_store,
            act_aps_store,
            act_aps_mult_adj_store,
            act_slsrnk_ecom,
            act_aps_ecom,
            act_aps_mult_adj_ecom,
            use_act_aps_or_act_rank,
            use_valid_sizes_from,
            apply_size_mins_to,
            cc_addoff_store,
            cc_addoff_ecom,
            irw_floorset,
            irw_superset,
            irw_floorset_display,
            irw_superset_display,
            irw_floorset_id,
            cc_size_eligibility_profile,
                cloned_at
        )
        SELECT
            to_id,
            location,
            dbt_wk,
            relaunchweek,
            erlstmkdnwk,
            exitdate,
            initrcptwk,
            too,
            mkdnwks,
            last_inv_wk,
            lstfpwk,
            last_rcpt_wk,
            lastdcorder,
            act_initrcptwk,
            act_dbt_wk,
            irw_indx,
            dbtwk_indx,
            relaunchwk_indx,
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            preview_wks,
            preview_qty,
            plannedselldnwk,
            ccmdstrategy,
            slsrnk_store,
            slsrnk_ecom,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            cc_presmin,
            cc_presmin_weeks,
            cc_rcptint,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            cc_return_u_pct_cross,
            cc_ordermultiple,
            cc_ordermin,
            cc_buy_aps_letter,
            ccticketpricechannel,
            ccticketpricechannel_override,
            cc_imupct,
            cc_discount_pct,
            cc_existingwac,
            null as cc_systemcost,
            cc_plan_cost,
            ssnprf,
            adjaps_store,
            adjaps_ecom,
            smoothing_strategy,
            in_season_flag,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            cc_lead_time,
            cc_service_level,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            1 as record_state,
            cc_store_min_multiple,
            planned_sell_down_week,
            cc_selected_clusters,
            cc_cluster_group,
            keep_initial_range_plan,
            cc_sizeelig_rangecode,
            cc_presmin_stylecolor,
            cc_presmin_weeks_stylecolor,
            cc_final_cost,
            cc_discount_pct_store,
            cc_discount_pct_ecom,
            irw_debut_offset,
            cc_service_level_ecom,
            cc_first_publish_date,
            cc_first_publish_snapshot_op,
            sclr_alloc_max,
            sclr_presmin,
            sclr_alloc_min,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_fringe_flag,
            act_slsrnk_store,
            act_aps_store,
            act_aps_mult_adj_store,
            act_slsrnk_ecom,
            act_aps_ecom,
            act_aps_mult_adj_ecom,
            use_act_aps_or_act_rank,
            use_valid_sizes_from,
            apply_size_mins_to,
            cc_addoff_store,
            cc_addoff_ecom,
            irw_floorset,
            irw_superset,
            irw_floorset_display,
            irw_superset_display,
            irw_floorset_id,
            cc_size_eligibility_profile,
                now()
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_stylecolorchannelattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- IMGATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_imgattributes (
            indx,
            product,
            img,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            indx,
            to_id,
            img,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_imgattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- ITEMPRICE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_itemprice (
            product,
            location,
            time,
            addoff,
            eo,
            eff_aur,
            department,
            event,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            excl_discount_pct,
            addoff_ecom,
            addoff_store
        )
        SELECT
            to_id,
            location,
            time,
            addoff,
            eo,
            eff_aur,
            department,
            event,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            excl_discount_pct,
            addoff_ecom,
            addoff_store
        FROM trd_style_clone_flat_map_temp a,
             trd_p_itemprice b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- CHANNELOVERRIDE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_channeloverride (
            product,
            location,
            time,
            weekadjaps,
            weekadjaps_ecom,
            weekadjslsu,
            weekadjslsu_ecom,
            comments,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            testpo,
            floorsetpo
        )
        SELECT
            to_id,
            location,
            time,
            weekadjaps,
            weekadjaps_ecom,
            weekadjslsu,
            weekadjslsu_ecom,
            comments,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            testpo,
            floorsetpo
        FROM trd_style_clone_flat_map_temp a,
             trd_p_channeloverride b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- ASSORTMENT insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_a_assortment (
            product,
            location,
            time,
            style,
            str_grade,
            str_store_climate,
            str_capacity,
            str_store_banner,
            str_geo_region,
            str_hazmat,
            ssg,
            flnrange,
            plan_type,
            isfunded,
            store_count,
            propagate_ranging,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            str_grade_or,
            str_store_climate_or,
            str_capacity_or,
            str_store_banner_or,
            str_geo_region_or,
            str_hazmat_or
        )
        SELECT
            to_id,
            location,
            time,
            style,
            str_grade,
            str_store_climate,
            str_capacity,
            str_store_banner,
            str_geo_region,
            str_hazmat,
            ssg,
            flnrange,
            plan_type,
            isfunded,
            store_count,
            propagate_ranging,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            str_grade_or,
            str_store_climate_or,
            str_capacity_or,
            str_store_banner_or,
            str_geo_region_or,
            str_hazmat_or
        FROM trd_style_clone_flat_map_temp a,
             trd_a_assortment b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", location, plan_type) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- DC_ADJ insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_dc_adj (
            product,
            location,
            time,
            dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_isedited,
            dc_syscost,
            dc_lndcst,
            dc_sysvrp,
            dc_sc_useradj,
            dc_sc_finrev,
            po_indicator,
            po_shipmode,
            air_trigger,
            cut,
            published_at,
            is_prepublished,
            prepublished_at,
            last_prepublished,
            po_arr,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_finrev_ecom,
            dc_publish_ecom,
            po_indicator_ecom,
            po_shipmode_ecom,
            air_trigger_ecom,
            cut_ecom,
            published_at_ecom,
            is_prepublished_ecom,
            prepublished_at_ecom,
            last_prepublished_ecom,
            reason_code,
            reason_code_ecom,
            pack_ind_flag,
            pack_ind_flag_ecom,
            show_in_pack,
            show_in_pack_ecom,
            prepack_pct,
            prepack_pct_ecom,
            default_fringe_indicator,
            default_fringe_indicator_ecom,
            email_to
        )
        SELECT
            to_id,
            location,
            time,
                null as dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_isedited,
            dc_syscost,
            dc_lndcst,
            dc_sysvrp,
            dc_sc_useradj,
            dc_sc_finrev,
            po_indicator,
            po_shipmode,
            air_trigger,
            cut,
                null as published_at,
                null as is_prepublished,
                null as prepublished_at,
                null as last_prepublished,
                null as po_arr,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_finrev_ecom,
                null as dc_publish_ecom,
                null as po_indicator_ecom,
                null as po_shipmode_ecom,
                null as air_trigger_ecom,
                null as cut_ecom,
                null as published_at_ecom,
                null as is_prepublished_ecom,
                null as prepublished_at_ecom,
                null as last_prepublished_ecom,
            reason_code,
            reason_code_ecom,
            pack_ind_flag,
            pack_ind_flag_ecom,
            show_in_pack,
            show_in_pack_ecom,
            prepack_pct,
            prepack_pct_ecom,
            default_fringe_indicator,
            default_fringe_indicator_ecom,
            email_to
        FROM trd_style_clone_flat_map_temp a,
             trd_p_dc_adj b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- DC_ADJ_SIZE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_dc_adj_size (
            product,
            location,
            time,
            dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_scadj,
            dc_ttluseradj,
            dc_scfinrev,
            dc_ttlfinrev,
            dc_isedited,
            dc_onorder_v,
            dc_onorder_c,
            current_week,
            dc_last_pub_u,
            dc_last_pub,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_onorder_v_ecom,
            dc_onorder_c_ecom,
            dc_finrev_ecom,
            dc_publish_ecom,
            dc_last_pub_u_ecom,
            dc_last_pub_ecom
        )
        SELECT
            from_stylecolorsize,
            location,
            time,
                null as dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
                null as dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_scadj,
            dc_ttluseradj,
            dc_scfinrev,
            dc_ttlfinrev,
            dc_isedited,
                null as dc_onorder_v,
                null as dc_onorder_c,
            current_week,
                null as dc_last_pub_u,
                null as dc_last_pub,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            dc_useradj_ecom,
            null as dc_onorder_ecom,
            null as dc_onorder_v_ecom,
            null as dc_onorder_c_ecom,
            null as dc_finrev_ecom,
            null as dc_publish_ecom,
            null as dc_last_pub_u_ecom,
            null as dc_last_pub_ecom
        FROM trd_style_clone_stylecolor_size a,
             trd_p_dc_adj_size b
        WHERE a.from_stylecolorsize = b.product
          AND a.session_id = v_session_id
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- AN_PRICE_STORECOUNT_INFO insert
    --------------------------------------------------------------------
    INSERT INTO trd_an_price_storecount_info (
            product,
            channel,
            time,
            selling_channel,
            isfunded,
            store_count,
            in_season_flag,
            dbt_wk_date,
            last_rcpt_wk_date,
            erlstmkdnwk_date,
            exitdate_date,
            weekdate,
            price_status,
            seq,
            ccticketprice,
            curp,
            selling_price,
            expressed_aur,
            corpexcl,
            addoff,
            corpaddoff,
            v_a,
            v_b,
            ccdiscountpct,
            flow_flag
        )
        SELECT
            to_id,
            channel,
            time,
            selling_channel,
            isfunded,
            store_count,
            in_season_flag,
            dbt_wk_date,
            last_rcpt_wk_date,
            erlstmkdnwk_date,
            exitdate_date,
            weekdate,
            price_status,
            seq,
            ccticketprice,
            curp,
            selling_price,
            expressed_aur,
            corpexcl,
            addoff,
            corpaddoff,
            v_a,
            v_b,
            ccdiscountpct,
            flow_flag
        FROM trd_style_clone_flat_map_temp a,
             trd_an_price_storecount_info b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", channel, selling_channel) DO NOTHING
        ;


    --------------------------------------------------------------------
    -- DEPENDENCYLOOKUP inserts
    --------------------------------------------------------------------
/*
        INSERT INTO trd_l_dependencylookup (
            lookup_id,
            lookup_value,
            target_id,
            target_value
        )
        SELECT DISTINCT
            'style'    AS lookup_id,
            from_id    AS lookup_value,
            'patternedtostyle' AS target_id,
            to_id      AS target_value
        FROM trd_style_clone_flat_map_temp a
        WHERE a.levelid = 'style';
*/

        INSERT INTO trd_l_dependencylookup (
            lookup_id,
            lookup_value,
            target_id,
            target_value
        )
        SELECT DISTINCT
            'stylecolor' AS lookup_id,
            from_id      AS lookup_value,
            'patternedtostylecolor' AS target_id,
            to_id        AS target_value
        FROM trd_style_clone_flat_map_temp a
        WHERE a.levelid = 'stylecolor';


-- DROP THE TEMPORARY TABLE
DROP TABLE IF EXISTS trd_style_clone_flat_map_temp;

END;
$$;


--
-- Name: trd_plan_these_cloned_style_stylecolors_proc(text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_plan_these_cloned_style_stylecolors_proc(IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN


    -- ----------------------------------
    -- UPDATE picked_for_planning FLAG
    -- ----------------------------------

    -- Freeze this user's unpicked selection to avoid races
    CREATE TEMPORARY TABLE tmp_selected
    AS
    SELECT style, stylecolor, session_id, updated_by, picked_for_planning
    FROM trd_plan_these_cloned_style_stylecolors
    WHERE updated_by = v_pivot_user_id
      AND picked_for_planning = 0
    ;

    UPDATE
        trd_style_clone_stylecolor_size
    SET 
        picked_for_planning = 1 
    WHERE 
        (to_new_stylecolor, session_id) IN (SELECT stylecolor, session_id FROM tmp_selected)
        AND updated_by = v_pivot_user_id
    ;


    -- ----------------------------------
    -- MARK FOR DELETION UNUSED PRODUCTS 
    -- ----------------------------------


    CREATE TEMPORARY TABLE all_un_used_products
    AS  
    SELECT 
        DISTINCT to_new_style AS product, 'style' AS levelid 
    FROM 
        trd_style_clone_stylecolor_size s
    WHERE s.updated_by = v_pivot_user_id
      AND s.picked_for_planning = 0
      AND NOT EXISTS (
            SELECT 1 FROM tmp_selected t
            WHERE t.style = s.to_new_style AND t.session_id = s.session_id
      )

    UNION ALL 

    SELECT 
        DISTINCT to_new_stylecolor AS product, 'stylecolor' AS levelid 
    FROM 
        trd_style_clone_stylecolor_size s
    WHERE s.updated_by = v_pivot_user_id
      AND s.picked_for_planning = 0
      AND NOT EXISTS (
            SELECT 1 FROM tmp_selected t
            WHERE t.stylecolor = s.to_new_stylecolor AND t.session_id = s.session_id
      )

    UNION ALL 

    -- If you truly have a to_new_stylecolorsize column, keep this block; otherwise remove it.
    SELECT 
        DISTINCT to_new_stylecolorsize AS product, 'stylecolorsize' AS levelid 
    FROM 
        trd_style_clone_stylecolor_size s
    WHERE s.updated_by = v_pivot_user_id
      AND s.picked_for_planning = 0
      AND NOT EXISTS (
            SELECT 1 FROM tmp_selected t
            WHERE t.stylecolor = s.to_new_stylecolor AND t.session_id = s.session_id
      )
    ;

    -- ------------------------------------
    -- PRUNE UNUSED ROWS FROM CLONE STAGING
    -- ------------------------------------
    DELETE FROM trd_style_clone_stylecolor_size a 
    WHERE 
        a.updated_by = v_pivot_user_id
        AND a.session_id IN (SELECT DISTINCT session_id FROM tmp_selected)
        AND 
        (
            a.to_new_style IN (
                SELECT product FROM all_un_used_products WHERE levelid = 'style'
            )
        OR
            a.to_new_stylecolor IN (
                SELECT product FROM all_un_used_products WHERE levelid = 'stylecolor'
            )
        OR
            a.to_new_stylecolorsize IN (
                SELECT product FROM all_un_used_products WHERE levelid = 'stylecolorsize'
            )
        )
    ;

    -- ------------------------------------
    -- CLEAN UP BYPASSING DELETES FOR NOW
    -- ------------------------------------
    /*
    delete from trd_d_product where id in (select distinct product from all_un_used_products);

    delete from trd_h_prodstd where id in (select distinct product from all_un_used_products);
   
    delete from trd_a_assortment where product in (select distinct product from all_un_used_products);

    delete from trd_ma_styleattributes where product in (select distinct product from all_un_used_products);

    delete from trd_ma_stylecolorattributes where product in (select distinct product from all_un_used_products);

    delete from trd_ma_sizeattributes where product in (select distinct product from all_un_used_products);

    delete from trd_ma_imgattributes where product in (select distinct product from all_un_used_products);

    delete from trd_p_dc_adj where product in (select distinct product from all_un_used_products);

    delete from trd_p_dc_adj_size where product in (select distinct product from all_un_used_products);

    delete from trd_p_itemprice where product in (select distinct product from all_un_used_products);

    delete from trd_p_channeloverride where product in (select distinct product from all_un_used_products);

    delete from trd_an_price_storecount_info where product in (select distinct product from all_un_used_products);
    */


    -- --------------------------------------------------------------------------------------------------------
    -- CLEAN UP BYPASSING DELETES FOR NOW, SIMULATING REMOVE FROM ASSORTMENT, LIKELY DATA EXISTS IN CLICKHOUSE
    -- --------------------------------------------------------------------------------------------------------
    DELETE FROM trd_a_assortment 
    WHERE product IN (SELECT DISTINCT product FROM all_un_used_products);

    UPDATE trd_ma_stylecolorchannelattributes
    SET record_state = 1
    WHERE product IN (SELECT DISTINCT product FROM all_un_used_products WHERE levelid = 'stylecolor')
    ;

    UPDATE trd_ma_stylecolorchannelattributes
    SET record_state = 0
    WHERE product IN (select distinct stylecolor from tmp_selected)
    ;

    ------------------------------------
    -- INSERT IN PLAN QUEUE FOR PLANNING
    ------------------------------------

    INSERT INTO plan_queue (product, location, initiator, initiated_at, queued)
    SELECT 
        DISTINCT stylecolor, 'CH-2' AS location, v_pivot_user_id, now(), now()
    FROM 
        tmp_selected
    ;


    ------------------------------------
    -- UPDATE picked_for_planning FLAG
    -- ------------------------------------
    UPDATE 
        trd_plan_these_cloned_style_stylecolors 
    SET 
        picked_for_planning = 1 
    WHERE 
        updated_by = v_pivot_user_id 
        AND picked_for_planning = 0
        AND (stylecolor, session_id) IN (SELECT stylecolor, session_id FROM tmp_selected)
    ;

DROP TABLE IF EXISTS all_un_used_products;
DROP TABLE IF EXISTS tmp_selected;

END;
$$;


--
-- Name: trd_prefill_split_attrs_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_prefill_split_attrs_proc(IN p_session_id text, IN p_user_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- No-op if nothing staged.
    IF NOT EXISTS (
        SELECT 1 FROM trd_split_attrs_prefill
        WHERE session_id = p_session_id
    ) THEN
        RETURN;
    END IF;

    -- (0) INSERT seed rows for any source stylecolor that doesn't yet
    --     have an attribute row in trd_ma_stylecolorattributes. Without
    --     this, UPDATE below matches nothing for never-touched stylecolors
    --     and the breadcrumb cells stay blank for them.
    --
    --     Minimal column set: product (the FK), the two scratchpads,
    --     plus version_id + record_state with safe defaults. If the
    --     PG schema has additional NOT NULL columns we'll hit them and
    --     extend this list.
    INSERT INTO trd_ma_stylecolorattributes (
        product,
        split_new_style_name,
        new_stylecolor_name,
        version_id,
        record_state,
        updated_at,
        updated_by
    )
    SELECT
        s.stylecolor,
        nullif(s.current_style_name, ''),
        nullif(s.current_stylecolor_name, ''),
        1,                  -- version_id
        0,                  -- record_state (active)
        now(),
        p_user_id
      FROM trd_split_attrs_prefill s
     WHERE s.session_id = p_session_id
       AND NOT EXISTS (
           SELECT 1 FROM trd_ma_stylecolorattributes
           WHERE product = s.stylecolor
       );

    -- (1) Fill new_stylecolor_name on existing rows where currently
    --     NULL/empty. Preserves any user edits.
    UPDATE trd_ma_stylecolorattributes a
       SET new_stylecolor_name = s.current_stylecolor_name,
           updated_at          = now(),
           updated_by          = p_user_id
      FROM trd_split_attrs_prefill s
     WHERE s.session_id = p_session_id
       AND a.product    = s.stylecolor
       AND s.current_stylecolor_name IS NOT NULL
       AND s.current_stylecolor_name <> ''
       AND (a.new_stylecolor_name IS NULL OR a.new_stylecolor_name = '');

    -- (2) Fill split_new_style_name on existing rows where currently
    --     NULL/empty.
    UPDATE trd_ma_stylecolorattributes a
       SET split_new_style_name = s.current_style_name,
           updated_at            = now(),
           updated_by            = p_user_id
      FROM trd_split_attrs_prefill s
     WHERE s.session_id = p_session_id
       AND a.product    = s.stylecolor
       AND s.current_style_name IS NOT NULL
       AND s.current_style_name <> ''
       AND (a.split_new_style_name IS NULL OR a.split_new_style_name = '');

    -- (3) Cleanup the staging rows for this session.
    DELETE FROM trd_split_attrs_prefill
     WHERE session_id = p_session_id;
END;
$$;


--
-- Name: trd_prefill_stylecolor_names_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_prefill_stylecolor_names_proc(IN p_session_id text, IN p_user_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Quietly no-op if nothing staged.
    IF NOT EXISTS (
        SELECT 1 FROM trd_stylecolor_name_prefill
        WHERE session_id = p_session_id
    ) THEN
        RETURN;
    END IF;

    -- Fill NULL/empty new_stylecolor_name with the current display name.
    -- Existing non-NULL values are preserved (user already typed something).
    UPDATE trd_ma_stylecolorattributes a
       SET new_stylecolor_name = s.current_name,
           updated_at          = now(),
           updated_by          = p_user_id
      FROM trd_stylecolor_name_prefill s
     WHERE s.session_id = p_session_id
       AND a.product    = s.stylecolor
       AND (a.new_stylecolor_name IS NULL OR a.new_stylecolor_name = '');

    -- Cleanup the staging rows for this session.
    DELETE FROM trd_stylecolor_name_prefill
     WHERE session_id = p_session_id;
END;
$$;


--
-- Name: trd_style_clone_stylecolor_size_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_style_clone_stylecolor_size_proc(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_session_id    TEXT := p_session_id;
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN

    

    --------------------------------------------------------------------
    -- Build temp flat_map for this session
    --------------------------------------------------------------------
    CREATE TEMPORARY TABLE trd_style_clone_flat_map_temp AS
    SELECT * 
    FROM (
        SELECT DISTINCT
            from_style        AS from_id,
            to_new_style      AS to_id,
            'style'           AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , to_new_style_name as to_name
            , to_new_style_desc as to_desc
            , '' as cccolor
            , '' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_style IS NOT NULL AND from_style <> ''
          AND session_id = v_session_id

        UNION ALL
        SELECT DISTINCT
            from_stylecolor   AS from_id,
            to_new_stylecolor AS to_id,
            'stylecolor'      AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , to_new_stylecolor_name as to_name
            , to_new_stylecolor_desc as to_desc
            , RIGHT(to_new_stylecolor_name, 8) as cccolor
            , 'TBD' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_stylecolor IS NOT NULL AND from_stylecolor <> ''
          AND session_id = v_session_id

        UNION ALL
        SELECT DISTINCT
            from_stylecolorsize   AS from_id,
            to_new_stylecolorsize AS to_id,
            'stylecolorsize'      AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , '' as to_name 
            , '' as to_desc
            , '' as cccolor
            , '' as cccolorfamily
        FROM trd_style_clone_stylecolor_size
        WHERE from_stylecolorsize IS NOT NULL AND from_stylecolorsize <> ''
          AND session_id = v_session_id
    ) x;


    --------------------------------------------------------------------
    -- d_product insert
    --------------------------------------------------------------------
        INSERT INTO trd_d_product (
            id,client_id,name,description,levelid,indx,eventdate,version_id,created_at,created_by,updated_at,updated_by,record_state
        )
        SELECT DISTINCT 
              to_id
            , null as client_id
            , CASE WHEN a.levelid='stylecolorsize' THEN name ELSE to_name END
            , CASE WHEN a.levelid='stylecolorsize' THEN description ELSE to_desc END 
            , a.levelid
            , indx
            
            , now()::date
            , version_id
            , now()
            , v_pivot_user_id
            , now()
            , v_pivot_user_id
            , record_state
        FROM trd_style_clone_flat_map_temp a,
             trd_d_product b
        WHERE a.from_id = b.id
        ;


    --------------------------------------------------------------------
    -- STYLE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_style,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_style = b.id
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;


    --------------------------------------------------------------------
    -- STYLECOLOR insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_stylecolor,
            to_new_style,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_stylecolor = b.id
          AND from_style = b.ancestor0
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;


    --------------------------------------------------------------------
    -- STYLECOLORSIZE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT DISTINCT
            to_new_stylecolorsize,
            to_new_stylecolor,
            to_new_style,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
            ancestor7,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_stylecolor_size a,
             trd_h_prodstd b
        WHERE a.from_stylecolorsize = b.id
          AND a.from_stylecolor = b.ancestor0
          AND from_style = b.ancestor1
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;


    --------------------------------------------------------------------
    -- STYLEATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_styleattributes (
            product,
            sty_knit_or_woven,
            sty_fabrication,
            sty_sleeve_length,
            sty_leg_opening,
            sty_brand,
            sty_body_style_silhouette,
            sty_occasion_usage,
            sty_detail,
            sty_finish_style,
            sty_private_label,
            sty_license,
            sty_license_vs_non_licensed,
            sty_hazmat_code,
            sty_prop_65_warning,
            sty_material_content,
            sty_item_type,
            sty_dwrise,
            sty_length,
            sty_neckline,
            sty_toeshape,
            sty_heel_height,
            sty_bottom_length,
            sty_v_360_smoothing,
            sty_franchise,
            sty_key_item,
            sty_single_vs_multi_pack,
            sty_ticket_type,
            sty_vpn,
            sty_size_range,
            ccstylecreatedate,
            sty_is_locked,
            sty_s5_adopted,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            plm_size_range,
            sty_knit_fit,
            sty_patterned_after,
            sty_vpn_desc
        )
        SELECT
            to_id,
            sty_knit_or_woven,
            sty_fabrication,
            sty_sleeve_length,
            sty_leg_opening,
            sty_brand,
            sty_body_style_silhouette,
            sty_occasion_usage,
            sty_detail,
            sty_finish_style,
            sty_private_label,
            sty_license,
            sty_license_vs_non_licensed,
                null as sty_hazmat_code,
                null as sty_prop_65_warning,
            sty_material_content,
            sty_item_type,
            sty_dwrise,
            sty_length,
            sty_neckline,
            sty_toeshape,
            sty_heel_height,
            sty_bottom_length,
            sty_v_360_smoothing,
            sty_franchise,
            sty_key_item,
            sty_single_vs_multi_pack,
                null as sty_ticket_type,
                null as sty_vpn,
            sty_size_range,
                null as ccstylecreatedate,
                null as sty_is_locked,
                null as sty_s5_adopted,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
                null as plm_size_range,
                sty_knit_fit,
                sty_patterned_after,
                null as sty_vpn_desc
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_styleattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'style'
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- STYLECOLORATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_stylecolorattributes (
            product,
            cc_item_diff_1,
            cc_unit_retail,
            cc_unit_retail_cad,
            cc_pattern,
            cc_graphic,
            cc_fashion_basic,
            cc_holiday,
            cc_property_type,
            cc_internet_exclusive,
            cc_web_color_discription,
            cc_export_hts,
            cc_commercial_invoice_description,
            cc_season_code,
            cc_dtr,
            cc_dw_color_family,
            cc_channel_reorder,
            cc_ticket_season_code,
            cc_sub_programs,
            cc_music_genre,
            cc_clearance_str_product,
            cc_po_supplier,
            cc_origin_country_id,
            cc_country_of_sourcing,
            cc_country_of_manufacturing,
            cc_unit_cost,
            cc_freight,
            cc_royalty,
            cc_duty,
            cc_ship_method,
            cc_lading_port,
            cc_hts,
            cc_primary_supplier,
            cc_sub_brand,
            cc_pattern_type,
            cc_pop_print_neutral,
            cc_debut_season_code,
            cc_matchback,
            cc_primary_collection,
            cc_secondary_collection,
            cc_vpn_color,
            cc_orig_unit_retail,
            cc_orig_unit_retail_cad,
            cc_first_rec_week,
            cc_first_inv_week,
            cc_first_sale_week,
            cc_first_md_week,
            cc_last_md_week,
            cc_last_rec_week,
            cc_store_price_status,
            cc_ifc_price_status,
            cc_omni_price_type,
            ccstylecolorcreatedate,
            cc_price_band,
            cc_good_better_best,
                cccolor,
                cccolorfamily,
            total_brand_name,
            division_name,
            group_name,
            department_name,
            class_name,
            subclass_name,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            isassortment,
            merch_comments,
            plan_comments,
            cc_is_locked,
            cc_s5_adopted,
            cc_prepublish,
            cc_prepublished_at,
            allocator_comments,
            cccolorid,
            cc_specstylecolor_status,
            cc_agent_fee,
            cc_port,
            cc_factory,
            cc_floorset,
            cc_use_sys_floorset,
            cc_supp_cost,
            cc_finish,
            cc_license,
            cc_channel_availability,
            cc_extended_size,
            cc_op_markdown_week,
            cc_motif,
            cc_rp_revised_markdown_week,
            cc_web_current_retail,
            cc_parent_season_code,
            cc_art_code,
            cc_patterned_after,
            cc_material_content,
            cc_fabrication,
            style_name,
            stylecolor_name,
            buyer_email,
            cc_buyer,
            cc_patterned_after_name,
            vpn_color_desc
        )
        SELECT
            to_id,
            cc_item_diff_1,
            --SUP-3351 cc_unit_retail and cc_unit_retail_cad need to be copied from like item
            cc_unit_retail,
            cc_unit_retail_cad,
            cc_pattern,
            cc_graphic,
            cc_fashion_basic,
            cc_holiday,
            cc_property_type,
            cc_internet_exclusive,
            cc_web_color_discription,
                null as cc_export_hts,
                null as cc_commercial_invoice_description,
            cc_season_code,
            cc_dtr,
            cc_dw_color_family,
            cc_channel_reorder,
                null as cc_ticket_season_code,
            cc_sub_programs,
            cc_music_genre,
            cc_clearance_str_product,
                null as cc_po_supplier,
                null as cc_origin_country_id,
                null as cc_country_of_sourcing,
                null as cc_country_of_manufacturing,
                null as cc_unit_cost,
                null as cc_freight,
                null as cc_royalty,
                null as cc_duty,
                null as cc_ship_method,
                null as cc_lading_port,
                null as cc_hts,
                null as cc_primary_supplier,
            cc_sub_brand,
            cc_pattern_type,
            cc_pop_print_neutral,
            cc_debut_season_code,
            cc_matchback,
            cc_primary_collection,
            cc_secondary_collection,
                null as cc_vpn_color,
            cc_orig_unit_retail,
            cc_orig_unit_retail_cad,
                null as cc_first_rec_week,
                null as cc_first_inv_week,
                null as cc_first_sale_week,
                null as cc_first_md_week,
                null as cc_last_md_week,
                null as cc_last_rec_week,
            cc_store_price_status,
            cc_ifc_price_status,
            cc_omni_price_type,
                null as ccstylecolorcreatedate,
            cc_price_band,
            cc_good_better_best,
                a.cccolor,
                a.cccolorfamily,
            total_brand_name,
            division_name,
            group_name,
            department_name,
            class_name,
            subclass_name,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            isassortment,
                null as merch_comments,
                null as plan_comments,
                null as cc_is_locked,
                null as cc_s5_adopted,
                null as cc_prepublish,
                null as cc_prepublished_at,
                null as allocator_comments,
                a.cccolor,
            cc_specstylecolor_status,
                null as cc_agent_fee,
                null as cc_port,
                null as cc_factory,
            cc_floorset,
            cc_use_sys_floorset,
                null as cc_supp_cost,
            cc_finish,
            cc_license,
            cc_channel_availability,
            cc_extended_size,
                null as cc_op_markdown_week,
            cc_motif,
            cc_rp_revised_markdown_week,
                null as cc_web_current_retail,
            cc_parent_season_code,
            cc_art_code,
                cc_patterned_after,
                null as cc_material_content,
            cc_fabrication,
                style_name,
                stylecolor_name,
            buyer_email,
            cc_buyer,
                cc_patterned_after_name,
                null as vpn_color_desc
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_stylecolorattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- SIZEATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_sizeattributes (
            product,
            parent_id,
            item_diff_2,
            item_diff_3,
            sizeattribute,
            isvalid,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            ccctylecolorsizecreatedate
        )
        SELECT
            to_new_stylecolorsize,
            to_new_stylecolor,
            item_diff_2,
            item_diff_3,
            sizeattribute,
            isvalid,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            NULL
        FROM trd_style_clone_stylecolor_size a,
             trd_ma_sizeattributes b
        WHERE a.from_stylecolorsize = b.product
          AND a.from_stylecolor = b.parent_id
          AND a.session_id = v_session_id
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- STYLECOLORCHANNELATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_stylecolorchannelattributes (
            product,
            location,
            dbt_wk,
            relaunchweek,
            erlstmkdnwk,
            exitdate,
            initrcptwk,
            too,
            mkdnwks,
            last_inv_wk,
            lstfpwk,
            last_rcpt_wk,
            lastdcorder,
            act_initrcptwk,
            act_dbt_wk,
            irw_indx,
            dbtwk_indx,
            relaunchwk_indx,
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            preview_wks,
            preview_qty,
            plannedselldnwk,
            ccmdstrategy,
            slsrnk_store,
            slsrnk_ecom,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            cc_presmin,
            cc_presmin_weeks,
            cc_rcptint,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            cc_return_u_pct_cross,
            cc_ordermultiple,
            cc_ordermin,
            cc_buy_aps_letter,
            ccticketpricechannel,
            ccticketpricechannel_override,
            cc_imupct,
            cc_discount_pct,
            cc_existingwac,
            cc_systemcost,
            cc_plan_cost,
            ssnprf,
            adjaps_store,
            adjaps_ecom,
            smoothing_strategy,
            in_season_flag,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            cc_lead_time,
            cc_service_level,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            cc_store_min_multiple,
            planned_sell_down_week,
            cc_selected_clusters,
            cc_cluster_group,
            keep_initial_range_plan,
            cc_sizeelig_rangecode,
            cc_presmin_stylecolor,
            cc_presmin_weeks_stylecolor,
            cc_final_cost,
            cc_discount_pct_store,
            cc_discount_pct_ecom,
            irw_debut_offset,
            cc_service_level_ecom,
            cc_first_publish_date,
            cc_first_publish_snapshot_op,
            sclr_alloc_max,
            sclr_presmin,
            sclr_alloc_min,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_fringe_flag,
            act_slsrnk_store,
            act_aps_store,
            act_aps_mult_adj_store,
            act_slsrnk_ecom,
            act_aps_ecom,
            act_aps_mult_adj_ecom,
            use_act_aps_or_act_rank,
            use_valid_sizes_from,
            apply_size_mins_to,
            cc_addoff_store,
            cc_addoff_ecom,
            irw_floorset,
            irw_superset,
            irw_floorset_display,
            irw_superset_display,
            irw_floorset_id,
            cc_size_eligibility_profile,
                cloned_at
        )
        SELECT
            to_id,
            location,
            dbt_wk,
            relaunchweek,
            erlstmkdnwk,
            exitdate,
            initrcptwk,
            too,
            mkdnwks,
            last_inv_wk,
            lstfpwk,
            last_rcpt_wk,
            lastdcorder,
            act_initrcptwk,
            act_dbt_wk,
            irw_indx,
            dbtwk_indx,
            relaunchwk_indx,
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            preview_wks,
            preview_qty,
            plannedselldnwk,
            ccmdstrategy,
            slsrnk_store,
            slsrnk_ecom,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            cc_presmin,
            cc_presmin_weeks,
            cc_rcptint,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            cc_return_u_pct_cross,
            cc_ordermultiple,
            cc_ordermin,
            cc_buy_aps_letter,
            ccticketpricechannel,
            ccticketpricechannel_override,
            cc_imupct,
            cc_discount_pct,
            cc_existingwac,
            null as cc_systemcost,
            cc_plan_cost,
            ssnprf,
            adjaps_store,
            adjaps_ecom,
            smoothing_strategy,
            in_season_flag,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            cc_lead_time,
            cc_service_level,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            1 as record_state,
            cc_store_min_multiple,
            planned_sell_down_week,
            cc_selected_clusters,
            cc_cluster_group,
            keep_initial_range_plan,
            cc_sizeelig_rangecode,
            cc_presmin_stylecolor,
            cc_presmin_weeks_stylecolor,
            cc_final_cost,
            cc_discount_pct_store,
            cc_discount_pct_ecom,
            irw_debut_offset,
            cc_service_level_ecom,
            cc_first_publish_date,
            cc_first_publish_snapshot_op,
            sclr_alloc_max,
            sclr_presmin,
            sclr_alloc_min,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_fringe_flag,
            act_slsrnk_store,
            act_aps_store,
            act_aps_mult_adj_store,
            act_slsrnk_ecom,
            act_aps_ecom,
            act_aps_mult_adj_ecom,
            use_act_aps_or_act_rank,
            use_valid_sizes_from,
            apply_size_mins_to,
            cc_addoff_store,
            cc_addoff_ecom,
            irw_floorset,
            irw_superset,
            irw_floorset_display,
            irw_superset_display,
            irw_floorset_id,
            cc_size_eligibility_profile,
                now()
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_stylecolorchannelattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- IMGATTRIBUTES insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_ma_imgattributes (
            indx,
            product,
            img,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            indx,
            to_id,
            img,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM trd_style_clone_flat_map_temp a,
             trd_ma_imgattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- ITEMPRICE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_itemprice (
            product,
            location,
            time,
            addoff,
            eo,
            eff_aur,
            department,
            event,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            excl_discount_pct,
            addoff_ecom,
            addoff_store
        )
        SELECT
            to_id,
            location,
            time,
            addoff,
            eo,
            eff_aur,
            department,
            event,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            excl_discount_pct,
            addoff_ecom,
            addoff_store
        FROM trd_style_clone_flat_map_temp a,
             trd_p_itemprice b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- CHANNELOVERRIDE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_channeloverride (
            product,
            location,
            time,
            weekadjaps,
            weekadjaps_ecom,
            weekadjslsu,
            weekadjslsu_ecom,
            comments,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            testpo,
            floorsetpo
        )
        SELECT
            to_id,
            location,
            time,
            weekadjaps,
            weekadjaps_ecom,
            weekadjslsu,
            weekadjslsu_ecom,
            comments,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            testpo,
            floorsetpo
        FROM trd_style_clone_flat_map_temp a,
             trd_p_channeloverride b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- ASSORTMENT insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_a_assortment (
            product,
            location,
            time,
            style,
            str_grade,
            str_store_climate,
            str_capacity,
            str_store_banner,
            str_geo_region,
            str_hazmat,
            ssg,
            flnrange,
            plan_type,
            isfunded,
            store_count,
            propagate_ranging,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            str_grade_or,
            str_store_climate_or,
            str_capacity_or,
            str_store_banner_or,
            str_geo_region_or,
            str_hazmat_or
        )
        SELECT
            to_id,
            location,
            time,
            style,
            str_grade,
            str_store_climate,
            str_capacity,
            str_store_banner,
            str_geo_region,
            str_hazmat,
            ssg,
            flnrange,
            plan_type,
            isfunded,
            store_count,
            propagate_ranging,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            str_grade_or,
            str_store_climate_or,
            str_capacity_or,
            str_store_banner_or,
            str_geo_region_or,
            str_hazmat_or
        FROM trd_style_clone_flat_map_temp a,
             trd_a_assortment b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", location, plan_type) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- DC_ADJ insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_dc_adj (
            product,
            location,
            time,
            dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_isedited,
            dc_syscost,
            dc_lndcst,
            dc_sysvrp,
            dc_sc_useradj,
            dc_sc_finrev,
            po_indicator,
            po_shipmode,
            air_trigger,
            cut,
            published_at,
            is_prepublished,
            prepublished_at,
            last_prepublished,
            po_arr,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_finrev_ecom,
            dc_publish_ecom,
            po_indicator_ecom,
            po_shipmode_ecom,
            air_trigger_ecom,
            cut_ecom,
            published_at_ecom,
            is_prepublished_ecom,
            prepublished_at_ecom,
            last_prepublished_ecom,
            reason_code,
            reason_code_ecom,
            pack_ind_flag,
            pack_ind_flag_ecom,
            show_in_pack,
            show_in_pack_ecom,
            prepack_pct,
            prepack_pct_ecom,
            default_fringe_indicator,
            default_fringe_indicator_ecom,
            email_to
        )
        SELECT
            to_id,
            location,
            time,
                null as dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_isedited,
            dc_syscost,
            dc_lndcst,
            dc_sysvrp,
            dc_sc_useradj,
            dc_sc_finrev,
            po_indicator,
            po_shipmode,
            air_trigger,
            cut,
                null as published_at,
                null as is_prepublished,
                null as prepublished_at,
                null as last_prepublished,
                null as po_arr,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_finrev_ecom,
                null as dc_publish_ecom,
                null as po_indicator_ecom,
                null as po_shipmode_ecom,
                null as air_trigger_ecom,
                null as cut_ecom,
                null as published_at_ecom,
                null as is_prepublished_ecom,
                null as prepublished_at_ecom,
                null as last_prepublished_ecom,
            reason_code,
            reason_code_ecom,
            pack_ind_flag,
            pack_ind_flag_ecom,
            show_in_pack,
            show_in_pack_ecom,
            prepack_pct,
            prepack_pct_ecom,
            default_fringe_indicator,
            default_fringe_indicator_ecom,
            email_to
        FROM trd_style_clone_flat_map_temp a,
             trd_p_dc_adj b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- DC_ADJ_SIZE insert
    --------------------------------------------------------------------
    
        INSERT INTO trd_p_dc_adj_size (
            product,
            location,
            time,
            dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
            dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_scadj,
            dc_ttluseradj,
            dc_scfinrev,
            dc_ttlfinrev,
            dc_isedited,
            dc_onorder_v,
            dc_onorder_c,
            current_week,
            dc_last_pub_u,
            dc_last_pub,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            dc_useradj_ecom,
            dc_onorder_ecom,
            dc_onorder_v_ecom,
            dc_onorder_c_ecom,
            dc_finrev_ecom,
            dc_publish_ecom,
            dc_last_pub_u_ecom,
            dc_last_pub_ecom
        )
        SELECT
            from_stylecolorsize,
            location,
            time,
                null as dc_publish,
            is_locked,
            dc_uservrp,
            dc_lockedqty,
            dc_useradj,
                null as dc_onorder,
            dc_finrev,
            dc_validwk,
            dc_finalqty,
            dc_adjcost,
            const_y_n,
            sbkt,
            dc_scadj,
            dc_ttluseradj,
            dc_scfinrev,
            dc_ttlfinrev,
            dc_isedited,
                null as dc_onorder_v,
                null as dc_onorder_c,
            current_week,
                null as dc_last_pub_u,
                null as dc_last_pub,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            dc_useradj_ecom,
            null as dc_onorder_ecom,
            null as dc_onorder_v_ecom,
            null as dc_onorder_c_ecom,
            null as dc_finrev_ecom,
            null as dc_publish_ecom,
            null as dc_last_pub_u_ecom,
            null as dc_last_pub_ecom
        FROM trd_style_clone_stylecolor_size a,
             trd_p_dc_adj_size b
        WHERE a.from_stylecolorsize = b.product
          AND a.session_id = v_session_id
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- AN_PRICE_STORECOUNT_INFO insert
    --------------------------------------------------------------------
    INSERT INTO trd_an_price_storecount_info (
            product,
            channel,
            time,
            selling_channel,
            isfunded,
            store_count,
            in_season_flag,
            dbt_wk_date,
            last_rcpt_wk_date,
            erlstmkdnwk_date,
            exitdate_date,
            weekdate,
            price_status,
            seq,
            ccticketprice,
            curp,
            selling_price,
            expressed_aur,
            corpexcl,
            addoff,
            corpaddoff,
            v_a,
            v_b,
            ccdiscountpct,
            flow_flag
        )
        SELECT
            to_id,
            channel,
            time,
            selling_channel,
            isfunded,
            store_count,
            in_season_flag,
            dbt_wk_date,
            last_rcpt_wk_date,
            erlstmkdnwk_date,
            exitdate_date,
            weekdate,
            price_status,
            seq,
            ccticketprice,
            curp,
            selling_price,
            expressed_aur,
            corpexcl,
            addoff,
            corpaddoff,
            v_a,
            v_b,
            ccdiscountpct,
            flow_flag
        FROM trd_style_clone_flat_map_temp a,
             trd_an_price_storecount_info b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", channel, selling_channel) DO NOTHING
        ;



    --------------------------------------------------------------------
    -- DEPENDENCYLOOKUP inserts
    --------------------------------------------------------------------
        INSERT INTO trd_l_dependencylookup (
            lookup_id,
            lookup_value,
            target_id,
            target_value
        )
        SELECT DISTINCT
            'style'    AS lookup_id,
            from_id    AS lookup_value,
            'patternedtostyle' AS target_id,
            to_id      AS target_value
        FROM trd_style_clone_flat_map_temp a
        WHERE a.levelid = 'style';


        INSERT INTO trd_l_dependencylookup (
            lookup_id,
            lookup_value,
            target_id,
            target_value
        )
        SELECT DISTINCT
            'stylecolor' AS lookup_id,
            from_id      AS lookup_value,
            'patternedtostylecolor' AS target_id,
            to_id        AS target_value
        FROM trd_style_clone_flat_map_temp a
        WHERE a.levelid = 'stylecolor';


-- DROP THE TEMPORARY TABLE
DROP TABLE IF EXISTS trd_style_clone_flat_map_temp;

END;
$$;


--
-- Name: trd_style_clone_stylecolor_size_proc_dummy(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_style_clone_stylecolor_size_proc_dummy(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- just return the input params
    RAISE NOTICE 'Session ID: %, Pivot User ID: %', p_session_id, p_pivot_user_id;

    -- if you want an actual SELECT result
    -- you can use PERFORM inside procedure
    -- but in Postgres procedures (as opposed to functions)
    -- SELECT output is not directly returned
    -- use RAISE NOTICE or OUT params
END;
$$;


--
-- Name: trd_style_merge_reparent_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_style_merge_reparent_proc(IN p_session_id text, IN p_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_target_style_id text;
    v_t_id  text;
    v_t_a0  text;
    v_t_a1  text;
    v_t_a2  text;
    v_t_a3  text;
    v_t_a4  text;
    v_t_a5  text;
    v_t_a6  text;
    v_t_a7  text;
BEGIN
    -- Nothing staged for this session? Quietly return.
    IF NOT EXISTS (
        SELECT 1 FROM trd_style_merge_reparent
        WHERE session_id = p_session_id
    ) THEN
        RAISE NOTICE 'trd_style_merge_reparent_proc: no staged rows for session %', p_session_id;
        RETURN;
    END IF;

    -- The pivot stages target_style_id='' because there's no CH mirror of
    -- trd_ma_stylecolorattributes. The header dropdown's mass-edit wrote
    -- merge_target_style to PG for every source row (same value on each).
    -- Read it here. All staged rows share the same target.
    SELECT a.merge_target_style
      INTO v_target_style_id
      FROM trd_style_merge_reparent r
      JOIN trd_ma_stylecolorattributes a ON a.product = r.source_stylecolor_id
     WHERE r.session_id          = p_session_id
       AND a.merge_target_style IS NOT NULL
       AND a.merge_target_style <> ''
     LIMIT 1;

    IF v_target_style_id IS NULL OR v_target_style_id = '' THEN
        RAISE NOTICE 'trd_style_merge_reparent_proc: no merge_target_style set for any source in session %', p_session_id;
        DELETE FROM trd_style_merge_reparent WHERE session_id = p_session_id;
        RETURN;
    END IF;

    -- Populate target_style_id and action on the staging rows.
    --   NOOP     -> source_style_id = target (already there)
    --   RETIRE   -> source's cccolor already exists under the target style
    --   REPARENT -> otherwise (the common case)
    UPDATE trd_style_merge_reparent r
       SET target_style_id = v_target_style_id,
           action = CASE
             WHEN r.source_style_id = v_target_style_id THEN 'NOOP'
             WHEN EXISTS (
                 SELECT 1
                   FROM trd_h_prodstd ch
                   JOIN trd_ma_stylecolorattributes ca ON ca.product = ch.id
                  WHERE ch.ancestor0          = v_target_style_id
                    AND coalesce(ch.record_state, 0) = 0
                    AND ca.cccolor            = r.cccolor
             ) THEN 'RETIRE'
             ELSE 'REPARENT'
           END
     WHERE r.session_id = p_session_id;

    -- Discard NOOP rows.
    DELETE FROM trd_style_merge_reparent
     WHERE session_id = p_session_id
       AND action     = 'NOOP';

    -- Pull the target style's hierarchy row. We need its id and
    -- ancestor0..7 to copy onto the re-parented source rows.
    SELECT id, ancestor0, ancestor1, ancestor2, ancestor3,
                ancestor4, ancestor5, ancestor6, ancestor7
      INTO v_t_id, v_t_a0, v_t_a1, v_t_a2, v_t_a3,
                   v_t_a4, v_t_a5, v_t_a6, v_t_a7
      FROM trd_h_prodstd
     WHERE id = v_target_style_id;

    IF v_t_id IS NULL THEN
        RAISE EXCEPTION 'trd_style_merge_reparent_proc: target style % not found in trd_h_prodstd (session %)',
            v_target_style_id, p_session_id;
    END IF;

    -- (1) REPARENT: update source stylecolor rows' ancestry to point
    --     at the target style. A stylecolor row's ancestor0 IS its
    --     style, so ancestor0 becomes the target style id; ancestor1..7
    --     get the target style's own ancestor0..6 shifted up.
    UPDATE trd_h_prodstd sc
       SET ancestor0  = v_t_id,
           ancestor1  = v_t_a0,
           ancestor2  = v_t_a1,
           ancestor3  = v_t_a2,
           ancestor4  = v_t_a3,
           ancestor5  = v_t_a4,
           ancestor6  = v_t_a5,
           ancestor7  = v_t_a6,
           updated_at = now(),
           updated_by = p_user_id
     WHERE sc.id IN (
        SELECT source_stylecolor_id
          FROM trd_style_merge_reparent
         WHERE session_id = p_session_id
           AND action     = 'REPARENT'
     );

    -- (2) REPARENT cascade: stylecolorsize children of the re-parented
    --     stylecolors. For a stylecolorsize, ancestor0 = stylecolor
    --     (unchanged), ancestor1 = style. Shift up by one slot relative
    --     to the stylecolor update above.
    UPDATE trd_h_prodstd scs
       SET ancestor1  = v_t_id,
           ancestor2  = v_t_a0,
           ancestor3  = v_t_a1,
           ancestor4  = v_t_a2,
           ancestor5  = v_t_a3,
           ancestor6  = v_t_a4,
           ancestor7  = v_t_a5,
           updated_at = now(),
           updated_by = p_user_id
     WHERE scs.ancestor0 IN (
        SELECT source_stylecolor_id
          FROM trd_style_merge_reparent
         WHERE session_id = p_session_id
           AND action     = 'REPARENT'
     );

    -- (3) RETIRE: target-wins color collisions. Flip record_state on the
    --     source stylecolor so it goes inactive. Hierarchy not touched.
    UPDATE trd_h_prodstd sc
       SET record_state = 1,
           updated_at   = now(),
           updated_by   = p_user_id
     WHERE sc.id IN (
        SELECT source_stylecolor_id
          FROM trd_style_merge_reparent
         WHERE session_id = p_session_id
           AND action     = 'RETIRE'
     );

    -- (4) Archive: one durable row per action row (REPARENT + RETIRE).
    INSERT INTO trd_style_merge_archives_tbl (
        source_style_id, target_style_id, source_stylecolor_id,
        session_id, updated_by, updated_at
    )
    SELECT source_style_id, target_style_id, source_stylecolor_id,
           session_id, updated_by, now()
      FROM trd_style_merge_reparent
     WHERE session_id = p_session_id;

    -- (5) Conditionally retire source styles that now have zero active
    --     stylecolor children. Never retire the target style itself.
    --     A style row's children are stylecolor rows whose ancestor0 =
    --     the style id.
    UPDATE trd_h_prodstd s
       SET record_state = 1,
           updated_at   = now(),
           updated_by   = p_user_id
     WHERE s.id IN (
        SELECT DISTINCT source_style_id
          FROM trd_style_merge_reparent
         WHERE session_id = p_session_id
     )
       AND s.id <> v_target_style_id
       AND NOT EXISTS (
        SELECT 1
          FROM trd_h_prodstd ch
         WHERE ch.ancestor0           = s.id
           AND coalesce(ch.record_state, 0) = 0
     );

    -- (6) Apply per-stylecolor rename. The user typed new display labels
    --     into the attribute scratchpad new_stylecolor_name (a free-text
    --     attribute persisted to trd_ma_stylecolorattributes via mass-edit).
    --     Apply those to BOTH trd_d_product.name AND .description for the
    --     source stylecolor row. The main grid surfaces .name; .description
    --     is what the prefill mini-proc and the breadcrumb display read.
    --     Keeping them in sync avoids visual divergence between views.
    --
    --     Skip if both columns already match the typed value (no-op rename).
    UPDATE trd_d_product p
       SET name        = a.new_stylecolor_name,
           description = a.new_stylecolor_name,
           updated_at  = now(),
           updated_by  = p_user_id
      FROM trd_ma_stylecolorattributes a,
           trd_style_merge_reparent r
     WHERE r.session_id      = p_session_id
       AND a.product         = r.source_stylecolor_id
       AND p.id              = r.source_stylecolor_id
       AND a.new_stylecolor_name IS NOT NULL
       AND a.new_stylecolor_name <> ''
       AND (coalesce(p.name, '')        <> a.new_stylecolor_name
         OR coalesce(p.description, '') <> a.new_stylecolor_name);

    -- (7) Clear the scratchpad so the next merge run starts clean.
    UPDATE trd_ma_stylecolorattributes
       SET new_stylecolor_name = NULL,
           merge_target_style  = NULL,
           updated_at          = now(),
           updated_by          = p_user_id
     WHERE product IN (
         SELECT source_stylecolor_id
           FROM trd_style_merge_reparent
          WHERE session_id = p_session_id
     )
       AND (new_stylecolor_name IS NOT NULL OR merge_target_style IS NOT NULL);

    -- (8) Cleanup: drop the session's staging rows.
    DELETE FROM trd_style_merge_reparent
     WHERE session_id = p_session_id;

END;
$$;


--
-- Name: trd_style_split_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.trd_style_split_proc(IN p_session_id text, IN p_user_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Quietly return if no staged rows (validation failed in the pivot
    -- or no commit fired).
    IF NOT EXISTS (
        SELECT 1 FROM trd_style_split_stage
        WHERE session_id = p_session_id
    ) THEN
        RAISE NOTICE 'trd_style_split_proc: no staged rows for session %', p_session_id;
        RETURN;
    END IF;

    -- (1) Create the new styles' dimension rows. name/description from
    --     the pivot's staging (auto-generated). levelid + indx from
    --     the source style's existing dimension row.
    INSERT INTO trd_d_product (
        id, name, description, levelid, indx,
        version_id, record_state,
        updated_at, updated_by
    )
    SELECT
        stage.new_style_id,
        stage.new_style_name,
        stage.new_style_desc,
        src_d.levelid,
        src_d.indx,
        1,                      -- version_id
        0,                      -- record_state (active)
        now(),
        stage.updated_by
      FROM trd_style_split_stage stage
      JOIN trd_d_product           src_d  ON src_d.id = stage.source_style_id
     WHERE stage.session_id = p_session_id
       ON CONFLICT (id) DO NOTHING;

    -- (2) Create the new styles' hierarchy rows. ancestor0..7 copied
    --     from the source style so the new style sits in the same
    --     subclass / class / department / etc.
    INSERT INTO trd_h_prodstd (
        id,
        ancestor0, ancestor1, ancestor2, ancestor3,
        ancestor4, ancestor5, ancestor6, ancestor7,
        version_id, record_state,
        updated_at, updated_by
    )
    SELECT
        stage.new_style_id,
        src_h.ancestor0, src_h.ancestor1, src_h.ancestor2, src_h.ancestor3,
        src_h.ancestor4, src_h.ancestor5, src_h.ancestor6, src_h.ancestor7,
        1,                      -- version_id
        0,                      -- record_state (active)
        now(),
        stage.updated_by
      FROM trd_style_split_stage stage
      JOIN trd_h_prodstd           src_h  ON src_h.id = stage.source_style_id
     WHERE stage.session_id = p_session_id
       ON CONFLICT (id) DO NOTHING;

    -- (2b) Create the new styles' attribute rows in trd_ma_styleattributes.
    --      Copy from source style. Without this, the new style has no
    --      attribute backing and the main grid filters it out.
    INSERT INTO trd_ma_styleattributes (
        product,
        sty_knit_or_woven,
        sty_fabrication,
        sty_sleeve_length,
        sty_leg_opening,
        sty_brand,
        sty_body_style_silhouette,
        sty_occasion_usage,
        sty_detail,
        sty_finish_style,
        sty_private_label,
        sty_license,
        sty_license_vs_non_licensed,
        sty_material_content,
        sty_item_type,
        sty_dwrise,
        sty_length,
        sty_neckline,
        sty_toeshape,
        sty_heel_height,
        sty_bottom_length,
        sty_v_360_smoothing,
        sty_franchise,
        sty_key_item,
        sty_single_vs_multi_pack,
        sty_size_range,
        eventdate,
        version_id,
        created_at, created_by,
        updated_at, updated_by,
        record_state,
        sty_knit_fit,
        sty_patterned_after
    )
    SELECT
        stage.new_style_id,
        src_a.sty_knit_or_woven,
        src_a.sty_fabrication,
        src_a.sty_sleeve_length,
        src_a.sty_leg_opening,
        src_a.sty_brand,
        src_a.sty_body_style_silhouette,
        src_a.sty_occasion_usage,
        src_a.sty_detail,
        src_a.sty_finish_style,
        src_a.sty_private_label,
        src_a.sty_license,
        src_a.sty_license_vs_non_licensed,
        src_a.sty_material_content,
        src_a.sty_item_type,
        src_a.sty_dwrise,
        src_a.sty_length,
        src_a.sty_neckline,
        src_a.sty_toeshape,
        src_a.sty_heel_height,
        src_a.sty_bottom_length,
        src_a.sty_v_360_smoothing,
        src_a.sty_franchise,
        src_a.sty_key_item,
        src_a.sty_single_vs_multi_pack,
        src_a.sty_size_range,
        now()::date,
        1,                      -- version_id
        now(), p_user_id,
        now(), p_user_id,
        0,                      -- record_state (active)
        src_a.sty_knit_fit,
        src_a.sty_patterned_after
      FROM trd_style_split_stage stage
      JOIN trd_ma_styleattributes  src_a ON src_a.product = stage.source_style_id
     WHERE stage.session_id = p_session_id
       ON CONFLICT (product) DO NOTHING;

    -- (3) Re-parent source stylecolors. ancestor0 flips to new style id.
    UPDATE trd_h_prodstd sc
       SET ancestor0  = stage.new_style_id,
           updated_at = now(),
           updated_by = p_user_id
      FROM trd_style_split_stage stage
     WHERE stage.session_id = p_session_id
       AND sc.id             = stage.source_stylecolor_id;

    -- (3b) Also flip assortment.style for reparented stylecolors. Main
    --      grid groups stylecolors under their assortment.style.
    UPDATE trd_a_assortment ax
       SET style      = stage.new_style_id,
           updated_at = now(),
           updated_by = p_user_id
      FROM trd_style_split_stage stage
     WHERE stage.session_id = p_session_id
       AND ax.product       = stage.source_stylecolor_id;

    -- (4) Cascade stylecolorsize children's ancestor1 to new style id.
    UPDATE trd_h_prodstd scs
       SET ancestor1  = stage.new_style_id,
           updated_at = now(),
           updated_by = p_user_id
      FROM trd_style_split_stage stage
     WHERE stage.session_id = p_session_id
       AND scs.ancestor0    = stage.source_stylecolor_id;

    -- (4b) Auto-rename source stylecolors: replace the source style name
    --      prefix in the stylecolor name/description with the new style
    --      name. e.g., "44920723 MORA STRIPE BLUE" -> "44920723_SPLIT_
    --      <ts>_1 MORA STRIPE BLUE". Preserves the human-readable color
    --      descriptor while making the stylecolor's name reflect its new
    --      parent.
    --
    --      If the source style name isn't found in the stylecolor name
    --      (unusual), replace() returns the original string unchanged --
    --      safe no-op. CASE guards against NULL description.
    UPDATE trd_d_product p
       SET name        = replace(p.name, src_st.name, stage.new_style_name),
           description = CASE
                            WHEN p.description IS NULL THEN NULL
                            ELSE replace(p.description, src_st.name, stage.new_style_name)
                         END,
           updated_at  = now(),
           updated_by  = p_user_id
      FROM trd_style_split_stage stage
      JOIN trd_d_product           src_st ON src_st.id = stage.source_style_id
     WHERE stage.session_id    = p_session_id
       AND p.id                = stage.source_stylecolor_id
       AND src_st.name IS NOT NULL
       AND src_st.name        <> '';

    -- (5) Archive: one durable row per split action.
    INSERT INTO trd_style_split_archives_tbl (
        source_stylecolor_id, source_style_id,
        new_style_id, new_style_name, new_style_desc,
        cccolor, session_id, updated_by, updated_at
    )
    SELECT source_stylecolor_id, source_style_id,
           new_style_id, new_style_name, new_style_desc,
           cccolor, session_id, updated_by, now()
      FROM trd_style_split_stage
     WHERE session_id = p_session_id;

    -- (6) Cleanup: drop the session's staging rows.
    DELETE FROM trd_style_split_stage
     WHERE session_id = p_session_id;

END;
$$;


--
-- Name: trg_allow_scaling_set_overflow_ok(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_allow_scaling_set_overflow_ok() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Only act if allow_scaling was false and is now being set to true
  IF OLD.allow_scaling IS DISTINCT FROM TRUE AND NEW.allow_scaling = TRUE THEN
    -- Only override overflow_ok if the user hasn't explicitly set it to false
    IF NEW.overflow_ok IS DISTINCT FROM TRUE THEN
      NEW.overflow_ok := TRUE;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: trg_ins_stylecolor_alloc_attrs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_ins_stylecolor_alloc_attrs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO trd_ma_stylecolor_alloc_attributes (product)
    VALUES (NEW.product)
    ON CONFLICT (product) DO NOTHING;      -- avoids duplicate-key errors
    RETURN NEW;                            -- preserve normal insert behaviour
END;
$$;


--
-- Name: trg_sclr_allow_scaling_set_overflow_ok(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_sclr_allow_scaling_set_overflow_ok() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Only act if sclr_allow_scaling was not 1.0 before and is now being set to 1.0
  IF OLD.sclr_allow_scaling IS DISTINCT FROM 1.0 AND NEW.sclr_allow_scaling = 1.0 THEN
    -- Only override overflow_ok if it's not already 1.0
    IF NEW.sclr_overflow_ok IS DISTINCT FROM 1.0 THEN
      NEW.sclr_overflow_ok := 1.0;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: trg_set_apply_targets_to_plan(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_set_apply_targets_to_plan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.floorset_uda ILIKE '%Carryover%' OR NEW.floorset_uda ILIKE '%Future%' THEN
        NEW.apply_targets_to_plan := NULL;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: trg_sum_override_array(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_sum_override_array() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.sclr_loc_wrk_size_user_override IS NOT NULL THEN
    -- Filter out NULLs and sum remaining values
    SELECT SUM(x)::int
    INTO NEW.sclr_loc_wrk_alloc_sclr_qty
    FROM unnest(NEW.sclr_loc_wrk_size_user_override) AS x
    WHERE x IS NOT NULL and x > 0;
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trg_sync_alloc_and_override(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_sync_alloc_and_override() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Case 1: If NEW override array is present, sum into alloc qty
  IF NEW.sclr_loc_wrk_size_user_override IS NOT NULL THEN
    SELECT SUM(x)::int
    INTO NEW.sclr_loc_wrk_alloc_sclr_qty
    FROM unnest(NEW.sclr_loc_wrk_size_user_override) AS x
    WHERE x IS NOT NULL and x >= 0;

  -- Case 2: If alloc qty is provided, and override is NOT being set
  ELSIF NEW.sclr_loc_wrk_alloc_sclr_qty IS NOT NULL
     AND (
       OLD.sclr_loc_wrk_size_user_override IS NULL OR
       array_length(OLD.sclr_loc_wrk_size_user_override, 1) IS NULL
     )
  THEN
    NEW.sclr_loc_wrk_size_user_override := NULL;
    NEW.sclr_loc_alloc_sizeattr_for_size_override := NULL;
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trigger_final_cost(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_final_cost() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_final_cost real;
BEGIN

  update trd_ma_stylecolorchannelattributes a
  set cc_final_cost =  case when coalesce(NEW.cc_systemcost, 0.0) > 0.0 then NEW.cc_systemcost
                            when coalesce(b.cc_unit_cost, 0.0) > 0.0 then b.cc_unit_cost
                            else NEW.cc_plan_cost
                            end
  from trd_ma_stylecolorattributes b
  where a.product = b.product and a.product = NEW.product;

  select cc_final_cost into v_final_cost
  from trd_ma_stylecolorchannelattributes where product = NEW.product;

  update trd_ma_stylecolorchannelattributes 
  set cc_imupct = coalesce(round(((NEW.ccticketpricechannel-v_final_cost)/NEW.ccticketpricechannel)::numeric, 2),0.0)
  where product = NEW.product;

  RETURN NEW;
END;
$$;


--
-- Name: trigger_set_cp_publish_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_cp_publish_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_dc_publish real; 
BEGIN
  select dc_publish into v_dc_publish from trd_p_dc_adj where product = NEW.product and time = NEW.time and location = NEW.location;

 IF NEW.po_status = 1
 THEN
   NEW.created_at = NOW()::timestamp(0);
   NEW.created_by = 'user_published';

  IF v_dc_publish = 1
  THEN
    insert into sync_outbound_dataqueue (product,time,publish_type)
    select NEW.product, NEW.time, 'PO' as publish_type;
  END IF;

  IF v_dc_publish is null OR v_dc_publish != 1
  THEN
    NEW.po_status := 0;
  END IF;

 END IF; 
 RETURN NEW;
END;
$$;


--
-- Name: trigger_set_dc_ttl_useradj(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_dc_ttl_useradj() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
NEW.dc_ttluseradj = NEW.dc_useradj + NEW.dc_useradj_ecom;
RETURN NEW;
END;
$$;


--
-- Name: trigger_set_indx_valid_values(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_indx_valid_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare maxIndx integer;
BEGIN
IF (NEW.indx is null)
then
 select max(indx) into maxIndx from trd_v_memberbasedvalidvalues;
 new.indx = maxIndx + 1;
END IF;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_set_pack_ind_flag(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_pack_ind_flag() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

 IF NEW.reason_code = 'Initial'
 THEN

  NEW.pack_ind_flag := 'TRUE';

 END IF; 
 RETURN NEW;
END;
$$;


--
-- Name: trigger_set_publish_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_publish_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF NEW.dc_publish = 1
 THEN
   NEW.created_at = NOW()::timestamp(0);
   NEW.published_at = NOW()::timestamp(0);
   NEW.published_by = NEW.updated_by;

   insert into sync_outbound_dataqueue (product,time,publish_type)
   select NEW.product, NEW.time, 'RDY4PO' as publish_type
   ;

 END IF;
 RETURN NEW;
END;
$$;


--
-- Name: trigger_set_size_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_size_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare curSizeId integer;
BEGIN
IF (NEW.size_id is null or new.size_id = '99999')
then
    select size_id into curSizeId from size_ids si where si.size_name = new.sizeattribute;
    new.size_id = curSizeId;
END IF;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW()::timestamp(0);
  RETURN NEW;
END;
$$;


--
-- Name: update_cc_use_sys_floorset(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_use_sys_floorset() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.cc_floorset IS NOT NULL AND NEW.cc_floorset <> '' THEN
        NEW.cc_use_sys_floorset := FALSE;
    ELSIF (NEW.cc_floorset IS NULL OR NEW.cc_floorset = '')
       AND (OLD.cc_floorset IS NOT NULL AND OLD.cc_floorset <> '') THEN
        NEW.cc_use_sys_floorset := TRUE;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: update_cc_validsizes_on_ccrangecode(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_validsizes_on_ccrangecode() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_store  text[];
  v_ecom   text[];
  v_cc_size_eligibility_profile text;
BEGIN
  -- 1) Model – All Valid Sizes → clear profile and bypass
  IF NEW.use_valid_sizes_from = 'Model – All Valid Sizes' THEN
    NEW.cc_size_eligibility_profile := NULL;
    RETURN NEW;
  END IF;

  -- 2) Profile change → rebuild using the named profile (if provided)
  IF TG_OP = 'UPDATE'
     AND NEW.cc_size_eligibility_profile IS DISTINCT FROM OLD.cc_size_eligibility_profile
     AND NEW.cc_size_eligibility_profile IS NOT NULL
  THEN
    -- Bail if nothing matches this profile
    IF NOT EXISTS (
      SELECT 1
      FROM trd_l_sizeeligibility_with_ccrangecode e
      WHERE e.ccrangecode = NEW.ccrangecode
        AND e.size_eligibility_default_display_name = NEW.cc_size_eligibility_profile
        AND (e.store_ineligible = 0 OR e.web_ineligible = 0)
    ) THEN
      RETURN NEW;
    END IF;

    SELECT
      ARRAY_AGG(DISTINCT e.size_member_id::text ORDER BY e.size_member_id::text)
        FILTER (WHERE e.store_ineligible = 0),
      ARRAY_AGG(DISTINCT e.size_member_id::text ORDER BY e.size_member_id::text)
        FILTER (WHERE e.web_ineligible = 0)
    INTO v_store, v_ecom
    FROM trd_l_sizeeligibility_with_ccrangecode e
    WHERE e.ccrangecode = NEW.ccrangecode
      AND e.size_eligibility_default_display_name = NEW.cc_size_eligibility_profile;

    NEW.cc_validsizes_store := COALESCE(v_store, '{}'::text[]);
    NEW.cc_validsizes_ecom  := COALESCE(v_ecom,  '{}'::text[]);
    RETURN NEW;
  END IF;

  -- 3) Defaults – All Valid Sizes OR ccrangecode changed → rebuild using default set
  IF NEW.use_valid_sizes_from = 'Defaults – All Valid Sizes'
     -- OR (TG_OP = 'UPDATE' AND NEW.ccrangecode IS DISTINCT FROM OLD.ccrangecode)
  THEN
    -- Bail if no default rows exist
    IF NOT EXISTS (
      SELECT 1
      FROM trd_l_sizeeligibility_with_ccrangecode e
      WHERE e.ccrangecode = NEW.ccrangecode
        AND e.is_default = 1
        AND (e.store_ineligible = 0 OR e.web_ineligible = 0)
    ) THEN
    	NEW.cc_size_eligibility_profile := NULL;
      RETURN NEW;
    END IF;

	SELECT
	  ARRAY_AGG(DISTINCT e.size_member_id::text ORDER BY e.size_member_id::text)
	    FILTER (WHERE e.store_ineligible = 0),
	  ARRAY_AGG(DISTINCT e.size_member_id::text ORDER BY e.size_member_id::text)
	    FILTER (WHERE e.web_ineligible = 0),
	  MIN(e.size_eligibility_default_display_name)::text
	INTO v_store, v_ecom, v_cc_size_eligibility_profile
	FROM trd_l_sizeeligibility_with_ccrangecode e
	WHERE e.ccrangecode = NEW.ccrangecode
	  AND e.is_default = 1;

	NEW.cc_validsizes_store := COALESCE(v_store, '{}'::text[]);
	NEW.cc_validsizes_ecom  := COALESCE(v_ecom,  '{}'::text[]);
	NEW.cc_size_eligibility_profile := v_cc_size_eligibility_profile;
	RETURN NEW;
  END IF;

  -- 4) Anything else → no change
  RETURN NEW;
END;
$$;


--
-- Name: update_ccrangecode_on_class_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_ccrangecode_on_class_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_size_range  text;
  v_new_ccrange text;
BEGIN
  -- Get the parent product’s size range (to build the code)
  SELECT sa.sty_size_range
  INTO v_size_range
  FROM trd_ma_styleattributes sa
  WHERE sa.product = NEW.id
  LIMIT 1;

  IF v_size_range IS NULL OR NEW.ancestor1 IS NULL THEN
    RETURN NEW;
  END IF;

  v_new_ccrange := btrim(v_size_range) || ' - ' || btrim(NEW.ancestor1);

  -- Update only children: all rows in trd_h_prodstd with ancestor0 = NEW.id
  UPDATE trd_ma_stylecolorchannelattributes s
  SET ccrangecode = v_new_ccrange
  FROM (
    SELECT id
    FROM trd_h_prodstd
    WHERE ancestor0 = NEW.id
  ) ch
  WHERE s.product = ch.id
    AND s.ccrangecode IS DISTINCT FROM v_new_ccrange;

  RETURN NEW; -- AFTER trigger
END;
$$;


--
-- Name: update_color_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_color_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

  v_style_description trd_d_product.description%type;
  v_style_name trd_d_product.name%type;

BEGIN

  select name, description into v_style_name, v_style_description 
  from trd_d_product where id = (select ancestor0 from trd_h_prodstd where id = NEW.product);
  
  NEW.cc_item_diff_1 := NEW.cccolor;

  select target_value into NEW.cccolorid
  from trd_l_dependencylookup
  where lookup_id = 'cccolor' and target_id = 'color_code' and lookup_value = NEW.cccolor;
 
  select target_value into NEW.cccolorfamily
  from trd_l_dependencylookup 
  where lookup_id = 'cccolor' and target_id = 'cccolorfamily' and lookup_value = NEW.cccolor;

  select target_value into NEW.cc_web_color_discription
  from trd_l_dependencylookup 
  where lookup_id = 'cccolor' and target_id = 'color_description' and lookup_value = NEW.cccolor;

  if NEW.cccolor is not null and NEW.cccolor <> '' then
    
  update trd_ma_stylecolorattributes
    set cccolorid = NEW.cccolorid
       ,cc_item_diff_1 = NEW.cc_item_diff_1
       ,cccolorfamily = NEW.cccolorfamily
       ,cc_dw_color_family = NEW.cccolorfamily
       ,cc_web_color_discription = NEW.cc_web_color_discription
  where product = new.product;
  
    update trd_d_product 
    set description = v_style_description || ' ' || NEW.cccolor,
        name = v_style_name || ' ' || NEW.cccolor
    where id = NEW.product;

  end if;
 
 if NEW.cccolor is null or NEW.cccolor = '' then
 update trd_d_product 
    set description = v_style_description || ' No Color',
    name = v_style_name || ' NoColor'
    where id = NEW.product;

   update trd_ma_stylecolorattributes 
   set cccolorfamily = null
      ,cccolorid = null
      ,cc_item_diff_1 = null
      ,cc_dw_color_family = null
      ,cc_web_color_discription = null
   where product = new.product;
 
 end if;
   
  RETURN NEW;
END;
$$;


--
-- Name: update_eff_aur(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_eff_aur() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
s0 text;
s1 text;
s2 text;
s3 text;
s4 text;
v_addoff real;
v_event text;
v_eo real;
v_ccpriceevent text;
v_expression text;
v_ccdiscount real;
v_cccurp real;
v_mdstrategy text;
v_val real;
fep real;
final_eff_aur real;
v_val2 real;
v_uuid_temp text;
v_uuid text;
table_input_t1 text;
addofnull real;
ccdiscountnull real;
v_ticketprice real;
v_mdstart_indx int2;
v_newtime_indx int2;
v_mdpct float4;
v_erlstmkdnwk text;
BEGIN
RAISE NOTICE 'product:%', NEW.product ;
RAISE NOTICE 'time:%', NEW.time ;
select cast(addoff as real), cast(event as text), cast(eo as real) into v_addoff, v_event, v_eo
 from trd_p_itemprice 
 where product=NEW.product and location=NEW.location and time=NEW.time;

select ccpriceevent, replace(expression,'cccurp','v_cccurp') into v_ccpriceevent, v_expression 
 from trd_l_priceeventlookup 
 where product=NEW.department and location=NEW.location and ccpriceevent=NEW.event;

select cc_discount_pct::real, ccticketpricechannel::real into v_ccdiscount, v_cccurp
 from trd_ma_stylecolorchannelattributes 
 where product=NEW.product and location=NEW.location;
/*
select cc_current_price::real into v_ticketprice 
 from trd_ma_stylecolorattributes 
 where product =NEW.product;


RAISE NOTICE 'INPUT:%', 'add off:'|| v_addoff;
RAISE NOTICE 'INPUT:%', 'event:'|| v_event;
RAISE NOTICE 'INPUT:%', 'eo:'|| v_eo;
RAISE NOTICE 'INPUT:%', 'priceevent:'|| v_ccpriceevent;
RAISE NOTICE 'INPUT:%', 'expression:'|| v_expression;
*/
/*CREATE SEQ TBL*/
EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;
table_input_t1 := 'input_t1'||v_uuid;
s1 := 'drop table if exists '||table_input_t1||'';
EXECUTE s1;
--RAISE NOTICE 'INPUT:%', 's1:'|| s1; 
s2 := 'create temporary table '||table_input_t1||' as select * from pricing_table where 1=2';
EXECUTE s2;
--RAISE NOTICE 'INPUT:%', 's2:'|| s2; 
/* END SEQ TBL CREATE */
IF v_cccurp > 0 
then 
v_cccurp := v_cccurp;
else 
v_cccurp := v_ticketprice;
end if;
/*
RAISE NOTICE 'INPUT:%', 'v_mdpct:'|| v_mdpct; 
IF NEW.time >= v_erlstmkdnwk 
then 
v_cccurp := v_cccurp * v_mdpct;
else 
v_cccurp := v_cccurp;
end if;
RAISE NOTICE 'INPUT:%', 'Before v_expression:'|| v_expression;

RAISE NOTICE 'INPUT:%', 'Before v_cccurp:'|| v_cccurp;
*/
--raise notice 'ccurp: %', v_cccurp;
IF v_expression is not null
THEN
--RAISE NOTICE 's3:%','Before S3';
s3 :=  'insert into '||table_input_t1||' (t_expression,v_cccurp) values('''||v_expression||''', '||v_cccurp||')';
RAISE NOTICE 's3:%', s3; 
EXECUTE s3;
execute 'select '||v_expression||' from '||table_input_t1||'' into v_val;
RAISE NOTICE 'INPUT:%', 'VVAL:'|| v_val;
fep := coalesce(v_eo,v_val,v_cccurp);
ELSE 
fep := coalesce(v_eo,v_cccurp);
END IF;
--RAISE NOTICE 'table_input_DEBUT_t1%', table_input_t1;
--addofnull := coalesce(v_addoff,0);
--ccdiscountnull := coalesce(v_ccdiscount,0);
--RAISE NOTICE 'addofnull:%, ccdiscountnull:%', addofnull, ccdiscountnull;
s4 := 'select '||fep||'';
--RAISE NOTICE 'INPUT:%', 'VAL:'|| s4;
EXECUTE s4  into final_eff_aur;
update trd_p_itemprice a set eff_aur=final_eff_aur where product=NEW.product and location=NEW.location and time=NEW.time;

-- update trd_an_price_storecount_info set expressed_aur=final_eff_aur where product=NEW.product and channel=NEW.location and time=NEW.time
--   ;
-- 
-- update trd_an_price_storecount_info a
--   set v_A=b.v_A
-- FROM
--   (select product, time, seq, case when seq=0 then ccticketprice * (1-COALESCE(corpexcl,0)) else curp end as v_A from trd_an_price_storecount_info a
--        WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time) b
-- WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
-- ;
-- 
--   update trd_an_price_storecount_info a
--     set v_B=b.v_B
--   FROM
--     (select product, time, seq, addoff, corpaddoff
--       , case when seq=0 then
--           (case when final_eff_aur > 0 then final_eff_aur else ccticketprice end) * (1 - coalesce(addoff,0)) * (1 - coalesce(corpaddoff,0))
--        else curp end as v_B
--        from trd_an_price_storecount_info a 
--        WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
--     ) b
--   WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
--   ;
-- 
-- update trd_an_price_storecount_info set selling_price=(least(v_A,v_B) * (1 - ccdiscountpct))::NUMERIC(16,2)
--   WHERE product=NEW.product and channel=NEW.location and time=NEW.time;

RETURN NEW;
END;
$$;


--
-- Name: update_eligibility_from_null_to_zero(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_eligibility_from_null_to_zero() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
      -- Clear the selected clusters for the product in blk_ma_stylecolorchannelattributes table
      UPDATE trd_p_stylecolor_store_eligibility
      SET sclr_str_eligibility = 0
      WHERE sclr_str_eligibility is null and product = NEW.product and location = NEW.location;

      RETURN NEW;
  END;
  $$;


--
-- Name: update_name_description(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_name_description() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN


  if NEW.name <> OLD.name or NEW.description <> OLD.description then
    update trd_d_product x
    set description = NEW.description || ' ' || y.cccolor,
        name = NEW.name || ' ' || y.cccolor
    from (select a.id, b.cc_web_color_discription as cccolor from trd_h_prodstd a, trd_ma_stylecolorattributes b where a.id = b.product and a.ancestor0 = NEW.id) y
    where x.id = y.id;

     update trd_ma_stylecolorattributes n
    set stylecolor_name = NEW.name || ' ' || m.cccolor,
        style_name = NEW.name
    from (select a.id, b.cc_web_color_discription as cccolor from trd_h_prodstd a, trd_ma_stylecolorattributes b where a.id = b.product and a.ancestor0 = NEW.id) m
    where n.product = m.id;

  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_specstyle_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_specstyle_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_subclass text;
  v_index text;
  specImg text;
  v_count integer;
BEGIN

  select ancestor0 into v_subclass from trd_h_prodstd where id = NEW.product;
  select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from trd_l_dependencylookup;
  select count(*) into v_count
  from trd_ma_styleattributes where product <> NEW.product and sty_vpn = NEW.sty_vpn and coalesce(NEW.sty_vpn, '') <> '';

  if v_count > 0 then 
    --RAISE NOTICE 'Inside revert logic';
    NEW.sty_vpn := OLD.sty_vpn;
  else 
    --RAISE NOTICE 'Inside Else 1';
    if COALESCE(OLD.sty_vpn,'0') <> COALESCE(NEW.sty_vpn,'0')
    then
      --RAISE NOTICE 'Inside Else Else 1';
      update trd_ma_stylecolorattributes set cc_vpn_color = null 
      where product in (select id from trd_h_prodstd where ancestor0 = NEW.product);
  
      if OLD.sty_vpn is not null and OLD.sty_vpn <> ''
      then
        --RAISE NOTICE 'Inside Else Else If 1';
        insert into trd_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
        select 'subclass', subclass_id, 'specstyle_id', OLD.sty_vpn, nextval('trd_l_dependencylookup_seq')
        from trd_ma_specstyleattributes where vpn_vsn = OLD.sty_vpn;

      end if;
  
      if NEW.sty_vpn is not null and NEW.sty_vpn <> ''
      then
        --RAISE NOTICE 'Inside Else Else If 2';
        delete from trd_l_dependencylookup 
        where lookup_id = 'subclass' and lookup_value = v_subclass 
          and target_id = 'specstyle_id' and target_value = NEW.sty_vpn;
  
        select size_range,ticket_type,knit_or_woven,sleeve_length,leg_opening,brand,license_vs_non_licensed,
               hazmat_code,prop_65_warning,material_content,dwrise,v_length,neckline,toeshape,
               heel_height,bottom_length,v_360_smoothing
        into NEW.plm_size_range,NEW.sty_ticket_type,NEW.sty_knit_or_woven,NEW.sty_sleeve_length,NEW.sty_leg_opening,NEW.sty_brand,NEW.sty_license_vs_non_licensed,
             NEW.sty_hazmat_code,NEW.sty_prop_65_warning,NEW.sty_material_content,NEW.sty_dwrise,NEW.sty_length,NEW.sty_neckline,NEW.sty_toeshape,
             NEW.sty_heel_height,NEW.sty_bottom_length,NEW.sty_v_360_smoothing,NEW.sty_vpn_desc
        from trd_ma_specstyleattributes
        where vpn_vsn = NEW.sty_vpn;
        
      end if;
    end if;
  end if;

  return NEW;
END;
$$;


--
-- Name: update_specstylecolor_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_specstylecolor_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_specstyleid text;
  v_index text;
  v_count integer;
  specImg text;
BEGIN

  select sty_vpn into v_specstyleid from (select sty_vpn from trd_ma_styleattributes where product = (select ancestor0 from trd_h_prodstd where id = NEW.product)) x;
  select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from trd_l_dependencylookup;

  select count(*) into v_count
  from trd_ma_stylecolorattributes where product <> NEW.product and cc_vpn_color = NEW.cc_vpn_color and coalesce(NEW.cc_vpn_color, '') <> '';

  if v_count > 0 then 
    --RAISE NOTICE 'Inside revert logic';
    update trd_ma_stylecolorattributes set cc_vpn_color = OLD.cc_vpn_color where product = NEW.product;
  else
    if COALESCE(OLD.cc_vpn_color,'0') <> COALESCE(NEW.cc_vpn_color, '0')
    then

      if COALESCE(OLD.cc_vpn_color, '') <> '' 
      then
        insert into trd_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
        values('specstyle_id', v_specstyleid, 'specstylecolor_id', OLD.cc_vpn_color, v_index);
      end if;

      if COALESCE(NEW.cc_vpn_color,'') <> ''
      then
        delete from trd_l_dependencylookup 
        where lookup_id = 'specstyle_id' and lookup_value = v_specstyleid 
          and target_id = 'specstylecolor_id' and target_value = NEW.cc_vpn_color;

        update trd_ma_stylecolorchannelattributes a
        set cc_systemcost = b.unit_cost::float+b.freight::float+b.duty::float --Total Cost Currently is not part of the soecstylecolorattributes, torrid is aware and looking into it
        from trd_ma_specstylecolorattributes b
        where a.product = NEW.product
        and b.vpn_vsn = v_specstyleid and b.vpn_color = NEW.cc_vpn_color;

        update trd_ma_stylecolorattributes a
        set cc_specstylecolor_status = b.design_stylecolor_status,
            cc_origin_country_id = b.origin_country_id,
            cc_country_of_sourcing = b.country_of_sourcing,
            cc_country_of_manufacturing = b.country_of_manufacturing,
            cc_freight = b.freight,
            cc_agent_fee = b.agent_fee,
            cc_duty = b.duty,
            cc_port = b.port,
            cc_ship_method = b.ship_method,
            cc_lading_port = b.lading_port,
            cc_commercial_invoice_description = b.commercial_invoice_description,
            cc_hts = b.hts,
            cc_factory = b.factory,
            cc_po_supplier = b.po_supplier,
            cc_export_hts = b.export_hts,
            cc_primary_supplier = b.primary_supplier,
            cc_sub_brand = b.sub_brand,
            cc_unit_cost = b.unit_cost,
            --1.1.1.2 Bullet 5
            /*
              •	Upon linking of a Style Color, the Place holder Color needs to be changed to match the Spec Color if Spec Color and Place holder Colors are different.
              Update of cccolor will trigger trig_upd_on_color_change executing FUNCTION update_color_change(). This will accomplish the above
            */
            cccolor = b.item_diff_1,
            cc_art_code = b.art_code,
            cc_material_content = b.cc_material_content,
            cc_supp_cost = b.supp_cost,
            cc_spec_division = b.division,
            cc_spec_group = b.group_id,
            cc_development_season = b.development_season,
            cc_delivery_season = b.DELIVERY_SEASON,
            cc_po_due_date = b.PO_DUE_DATE,
            cc_pd_ndc_week = b.PD_NDC_WEEK,
            cc_additional_tariff = b.ADDITIONAL_TARIFF,
            cc_design_notes = b.DESIGN_NOTES,
            cc_pd_notes = b.PD_NOTES,
            cc_compliance_notes = b.compliance_notes
        from trd_ma_specstylecolorattributes b
        where a.product = NEW.product
        and b.vpn_vsn = v_specstyleid and b.vpn_color = NEW.cc_vpn_color;

        select img into specImg from trd_specimages where product = new.cc_vpn_color;
        if (specImg is not null)
        then
          -- backup previous version of images before overwriting
          insert into trd_ma_imgattributes_archive SELECT *, now() from trd_ma_imgattributes where product = NEW.product;
          insert into trd_ma_imgattributes(product, img)
          values(NEW.product, specImg)
          on conflict (product) do update 
          set img = specImg;
        end if;


      end if;
    end if;
  end if;

  return NEW;
END;
$$;


--
-- Name: update_stylecolorchannelattributes_ccrangecode(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_stylecolorchannelattributes_ccrangecode() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Act only when the style’s size range actually changed (NULL-safe)
  IF TG_OP = 'UPDATE' AND NEW.sty_size_range IS DISTINCT FROM OLD.sty_size_range THEN
    /*
      For every stylecolor (ancestor0 = this style), do all in one set-based UPDATE:
        - ccrangecode := "<new size range> - <class>"  (ancestor1, per version B)
        - cc_validsizes_store/ecom := lookup-driven array for that size range
          (ordered, distinct; same array for store & ecom as in B)
    */
    UPDATE trd_ma_stylecolorchannelattributes AS a
    SET
      ccrangecode          = NEW.sty_size_range || ' - ' || h.ancestor2, -- matching on stylecolor and class is ancestor2
      cc_validsizes_store  = COALESCE(l.validsizes, '{}'::text[]),
      cc_validsizes_ecom   = COALESCE(l.validsizes, '{}'::text[])
    FROM trd_h_prodstd AS h
    -- size-range lookup once, applied to all rows (same size range for this style)
    LEFT JOIN (
      SELECT ARRAY_AGG(DISTINCT target_value ORDER BY target_value)::text[] AS validsizes
      FROM trd_l_dependencylookup
      WHERE lookup_id = 'size_range'
        AND lookup_value = NEW.sty_size_range
    ) AS l ON TRUE
    WHERE a.product = h.id
      AND h.ancestor0 = NEW.product
      AND (
           a.ccrangecode IS DISTINCT FROM NEW.sty_size_range || ' - ' || h.ancestor1
        OR a.cc_validsizes_store IS DISTINCT FROM COALESCE(l.validsizes, '{}'::text[])
        OR a.cc_validsizes_ecom  IS DISTINCT FROM COALESCE(l.validsizes, '{}'::text[])
      );
    -- If you also have a separate trigger on trd_ma_stylecolorchannelattributes that recomputes
    -- valid sizes on ccrangecode change, it will fire here. Keep it if you want that logic to win;
    -- disable it if you want these lookup-based arrays to be the source of truth.
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: update_ticket_price(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_ticket_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
  if coalesce(NEW.cc_orig_unit_retail,0) <> coalesce(OLD.cc_orig_unit_retail,0) then
    update trd_ma_stylecolorchannelattributes
    set ccticketpricechannel = NEW.cc_orig_unit_retail 
    where product = NEW.product;

    select cad_ticket_price, price_band
    into NEW.cc_orig_unit_retail_cad, NEW.cc_price_band
    from trd_l_ticketprice where product = (select ancestor3 from trd_h_prodstd where id = NEW.product)
    and usd_ticket_price = NEW.cc_orig_unit_retail;

    select price_band
    into NEW.cc_good_better_best
    from trd_l_pricebandlookup where product = (select ancestor1 from trd_h_prodstd where id = NEW.product)
    and NEW.cc_orig_unit_retail > ticket_price_min and NEW.cc_orig_unit_retail <= ticket_price_max;
  
    update trd_ma_stylecolorchannelattributes 
    set cc_imupct = coalesce(round(((NEW.cc_orig_unit_retail-cc_final_cost)/NEW.cc_orig_unit_retail)::numeric, 2),0.0)
    where product = NEW.product;

	--SUP-2549: update p_itemprice and set product as itself. This will fire trigger trigger_eff_aur which will update the eff_aur.
	update trd_p_itemprice 
	set product = product 
	where product = NEW.product;

  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_trigger_cartparams_irw_debut_offset(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_trigger_cartparams_irw_debut_offset() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.dbt_wk IS DISTINCT FROM OLD.dbt_wk THEN
    SELECT irw_offset.id
    INTO NEW.initrcptwk
    FROM trd_d_time current
    INNER JOIN trd_d_time irw_offset
      ON current.indx - NEW.irw_debut_offset = irw_offset.indx
    WHERE current.levelid = 'week'
      AND current.id = NEW.dbt_wk;
  END IF;

    -- Notify the user running the UPDATE
    RAISE NOTICE 'initrcptwk set to % for dbt_wk = % (updated by %)', 
                 NEW.initrcptwk, NEW.dbt_wk, session_user;

  RETURN NEW;
END;
$$;


--
-- Name: update_trigger_cartparams_ranging(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_trigger_cartparams_ranging() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    drop table if exists temp_new;
    drop table if exists temp_old;
    drop table if exists cart_params_temp;

    create temporary table cart_params_temp AS
    select jsessionid, scope_product as product, scope_location as location, initrcptwk, dbt_wk, exitdate 
    from cart_params where 
    jsessionid = NEW.jsessionid 
    and scope_product= NEW.scope_product 
    and scope_location = NEW.scope_location
    and scope_start = NEW.scope_start
    and scope_floorset = NEW.scope_floorset;

    create temporary table temp_new as 
    select b.product,b.location,a.indx,a.time from trd_ma_dptflrsetattributes a, cart_params_temp b, 
    (select value as plan_current from trd_serviceparams where id='plan_current') c,
    (select value as plan_end from trd_serviceparams where id='plan_end') d
    where 
    a.product=b.product
    and b.product = NEW.scope_product
    and b.location = NEW.scope_location
    and ap_start <= least(plan_end,exitdate) and ap_end >= greatest(dbt_wk,plan_current)
    order by indx;

    create temporary table temp_old as 
    select * 
    from cart_ranging a WHERE 
    jsessionid = NEW.jsessionid 
    and scope_product = NEW.scope_product 
    and scope_location = NEW.scope_location
    --and scope_start = NEW.scope_start
    ;

    delete from cart_ranging where 
    jsessionid = NEW.jsessionid 
    and scope_product = NEW.scope_product 
    and scope_location = NEW.scope_location
    --and scope_start = NEW.scope_start
    ;

    insert into cart_ranging
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, c.indx from 
    temp_old a, temp_new c
    where a.scope_product=c.product and a.scope_location=c.location
    and a.scope_product||a.scope_location||a.indx in (select scope_product||scope_location||min(indx) from temp_old group by scope_product, scope_location)
    and c.indx < a.indx ;

    insert into cart_ranging
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, c.indx from 
    temp_old a, temp_new c
    where a.scope_product=c.product and a.scope_location=c.location
    and a.scope_product||a.scope_location||a.indx in (select scope_product||scope_location||max(indx) from temp_old group by scope_product, scope_location)
    and c.indx > a.indx ;

    insert into cart_ranging
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_grade,str_store_climate,str_capacity,str_store_banner,str_geo_region,str_hazmat,ssg,str_grade_or,str_store_climate_or,str_capacity_or,str_store_banner_or,str_geo_region_or,str_hazmat_or,flnrange,isfunded, c.indx from 
    temp_old a, temp_new c
    where a.scope_product=c.product and a.scope_location=c.location
    and c.indx = a.indx ;

    drop table temp_new;
    drop table temp_old;
 RETURN NEW;
END;
$$;


--
-- Name: update_week_indxes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_week_indxes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
v_irw_indx int;
v_dbtwk_indx int;
v_relaunchwk_indx int;
v_mdstart_indx int;
v_lastdcorder_indx int;
v_exitdate_indx int;
v_initrcptwk text;
v_lastdcorder text;
v_relaunchweek text;

v_lastdcorder_indx_auto_roll int;
v_lastdcorder_auto_roll text;

BEGIN
v_relaunchweek := Case When NEW.relaunchweek = '' THEN null Else NEW.relaunchweek END;
--v_irw_indx := (select indx from trd_d_time where id =''||NEW.initrcptwk||'');
v_dbtwk_indx := (select indx from trd_d_time where id = COALESCE(''||v_relaunchweek||'',''||NEW.dbt_wk||''));
v_relaunchwk_indx := (select indx from trd_d_time where id = ''||v_relaunchweek||'');
v_mdstart_indx := (select indx  from trd_d_time where id = ''||NEW.erlstmkdnwk||'');
--v_lastdcorder_indx := (select indx from trd_d_time where id =''||NEW.lastdcorder||'');
v_exitdate_indx := (select indx  from trd_d_time where id = ''||NEW.exitdate||'');

select min(v_dbtwk_indx - irw_debut_offset)
into v_irw_indx
from trd_ma_dptflrsetattributes a, trd_h_prodstd b
where b.id = NEW.product
and b.ancestor3 = a.product and NEW.dbt_wk between ap_start and ap_end
;

--v_irw_indx := v_dbtwk_indx - 1;
v_initrcptwk := (select id from trd_d_time where indx= v_irw_indx);
v_lastdcorder_indx := v_mdstart_indx - 4;
v_lastdcorder := (select id from trd_d_time where indx= v_lastdcorder_indx);


-- NEW FOR ROLL FORWARD
v_lastdcorder_indx_auto_roll := v_mdstart_indx - 1;
v_lastdcorder_auto_roll := (select id from trd_d_time where indx= v_lastdcorder_indx_auto_roll);


if (NEW.dbt_wk != OLD.dbt_wk AND OLD.dbt_wk = OLD.act_dbt_wk and new.dbt_wk < new.erlstmkdnwk) then
    
    UPDATE trd_ma_stylecolorchannelattributes
    SET act_dbt_wk = NEW.dbt_wk
    WHERE
    product = NEW.product
    and location = NEW.location;

end if;

if (new.dbt_wk < new.erlstmkdnwk AND new.erlstmkdnwk < new.exitdate AND new.exitdate > new.erlstmkdnwk)
then
  if new.auto_rollforward = FALSE
  then
      update trd_ma_stylecolorchannelattributes
      set 
      irw_indx = v_irw_indx,
      dbtwk_indx = v_dbtwk_indx,
      relaunchwk_indx = v_relaunchwk_indx,
      mdstart_indx = v_mdstart_indx, 
      lastdcorder_indx = v_lastdcorder_indx,
      exitdate_indx = v_exitdate_indx,
      too = v_mdstart_indx - v_dbtwk_indx,
      mkdnwks = v_exitdate_indx - v_mdstart_indx,
      initrcptwk = v_initrcptwk,

      last_rcpt_wk = v_lastdcorder,
      lastdcorder = v_lastdcorder
      WHERE 
      product = NEW.product
      and location = NEW.location;
  else 
      update trd_ma_stylecolorchannelattributes
      set 
      irw_indx = v_irw_indx,
      dbtwk_indx = v_dbtwk_indx,
      relaunchwk_indx = v_relaunchwk_indx,
      mdstart_indx = v_mdstart_indx, 
      lastdcorder_indx = v_lastdcorder_indx,
      exitdate_indx = v_exitdate_indx,
      too = v_mdstart_indx - v_dbtwk_indx,
      mkdnwks = v_exitdate_indx - v_mdstart_indx,
      initrcptwk = v_initrcptwk,

      -- modified
      last_rcpt_wk = v_lastdcorder_auto_roll,
      lastdcorder = v_lastdcorder_auto_roll,
      planned_sell_down_week = v_lastdcorder_auto_roll
      WHERE 
      product = NEW.product
      and location = NEW.location;

  end if;

end if;



RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actuals_stage_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_stage_wide (
    id text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL
);


--
-- Name: actuals_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide (
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL
);


--
-- Name: dimensions; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions (
    dimension text NOT NULL,
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    levelid text NOT NULL,
    indx integer
);


--
-- Name: hierarchies; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies (
    dimension text NOT NULL,
    hierarchy text NOT NULL,
    id text NOT NULL,
    ancestor text NOT NULL
);


--
-- Name: location_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.location_denorm AS
 SELECT channel.id AS channel,
    selling_channel.id AS selling_channel
   FROM (( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'location'::text) AND (dimensions.levelid = 'selling_channel'::text))) selling_channel
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = selling_channel.id) AND (hierarchies.hierarchy = 'locstd'::text))) channel ON (true));


--
-- Name: prodlife_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.prodlife_denorm AS
 SELECT prodliferootlevel.id AS prodliferootlevel,
    merchcat.id AS merchcat
   FROM (( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'prodlife'::text) AND (dimensions.levelid = 'merchcat'::text))) merchcat
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = merchcat.id) AND (hierarchies.hierarchy = 'prodlifestd'::text))) prodliferootlevel ON (true));


--
-- Name: product_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.product_denorm AS
 SELECT total_brand.id AS total_brand,
    division.id AS division,
    "group".id AS "group",
    department.id AS department,
    class.id AS class
   FROM ((((( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'product'::text) AND (dimensions.levelid = 'class'::text))) class
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = class.id) AND (hierarchies.hierarchy = 'prodstd'::text))) department ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = department.id) AND (hierarchies.hierarchy = 'prodstd'::text))) "group" ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = "group".id) AND (hierarchies.hierarchy = 'prodstd'::text))) division ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = division.id) AND (hierarchies.hierarchy = 'prodstd'::text))) total_brand ON (true));


--
-- Name: time_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.time_denorm AS
 SELECT year.id AS year,
    season.id AS season,
    quarter.id AS quarter,
    month.id AS month,
    week.id AS week
   FROM ((((( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'time'::text) AND (dimensions.levelid = 'week'::text))) week
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = week.id) AND (hierarchies.hierarchy = 'timestd'::text))) month ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = month.id) AND (hierarchies.hierarchy = 'timestd'::text))) quarter ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = quarter.id) AND (hierarchies.hierarchy = 'timestd'::text))) season ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = season.id) AND (hierarchies.hierarchy = 'timestd'::text))) year ON (true));


--
-- Name: actuals_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp; Owner: -
--

CREATE MATERIALIZED VIEW mfp.actuals_wide_denorm AS
 SELECT DISTINCT ON (wide."time", wide.product, wide.location, wide.prodlife) "time".week AS time_week,
    "time".year AS time_year,
    product.class AS product_class,
    product.department AS product_department,
    product.total_brand AS product_total_brand,
    location.selling_channel AS location_selling_channel,
    location.channel AS location_channel,
    prodlife.merchcat AS prodlife_merchcat,
    prodlife.prodliferootlevel AS prodlife_prodliferootlevel,
    wide."time",
    wide.product,
    wide.location,
    wide.prodlife,
    wide.storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_r_adj,
    wide.net_sls_c,
    wide.net_sls_c_adj,
    wide.pos_md_r,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.committed_u,
    wide.committed_c,
    wide.committed_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.inv_adjustment_u,
    wide.inv_adjustment_r,
    wide.inv_adjustment_c,
    wide.mos_u,
    wide.mos_r,
    wide.mos_c,
    wide.shrink_u,
    wide.shrink_r,
    wide.shrink_r_adj,
    wide.shrink_c,
    wide.shrink_c_adj,
    wide.net_dc_xfer_u,
    wide.net_dc_xfer_r,
    wide.net_dc_xfer_c,
    wide.perm_md_r,
    wide.perm_md_c,
    wide.perm_md_move_inv_u,
    wide.perm_md_inv_r_csp,
    wide.perm_md_inv_u_edit,
    wide.perm_md_inv_r_at_new_aur_edit,
    wide.perm_md_inv_c_edit
   FROM ((((mfp.actuals_wide wide
     JOIN ( SELECT time_denorm.week,
            time_denorm.year
           FROM mfp.time_denorm) "time" ON (("time".week = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department,
            product_denorm.total_brand
           FROM mfp.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.selling_channel,
            location_denorm.channel
           FROM mfp.location_denorm) location ON ((location.selling_channel = wide.location)))
     JOIN ( SELECT prodlife_denorm.merchcat,
            prodlife_denorm.prodliferootlevel
           FROM mfp.prodlife_denorm) prodlife ON ((prodlife.merchcat = wide.prodlife)))
  WITH NO DATA;


--
-- Name: comments; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.comments (
    comment_id uuid NOT NULL,
    author text NOT NULL,
    plan_id integer NOT NULL,
    view_context text NOT NULL,
    view_template_id text NOT NULL,
    content text NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: currency_exchange_rates; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.currency_exchange_rates (
    "time" text NOT NULL,
    location text NOT NULL,
    exchange_ratio double precision NOT NULL,
    currency_id text DEFAULT 'MISSING'::text NOT NULL
);


--
-- Name: dimensions_backup_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_backup_2025_09_28 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_backup_refresh; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_backup_refresh (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_temp_update; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_temp_update (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_to_be_loaded; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_to_be_loaded (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_to_be_loaded_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_to_be_loaded_2025_09_28 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies_backup_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_backup_2025_09_28 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_backup_refresh; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_backup_refresh (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_to_be_loaded; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_to_be_loaded (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_to_be_loaded_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_to_be_loaded_2025_09_28 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: metadata; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.metadata (
    key text NOT NULL,
    as_int bigint,
    as_string text,
    as_member_id text,
    as_timestamp timestamp with time zone,
    as_member_id_arr text[]
);


--
-- Name: paired_dimension_links; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.paired_dimension_links (
    source_dimension text NOT NULL,
    target_dimension text NOT NULL,
    source_id text NOT NULL,
    target_id text NOT NULL
);


--
-- Name: plan_archives; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_archives (
    id integer NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL
);


--
-- Name: plan_audit_log; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_audit_log (
    plan text NOT NULL,
    action text NOT NULL,
    action_by text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: plan_data_export; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_export (
    id integer,
    product text,
    location text,
    prodlife text,
    "time" text,
    version text,
    avg_str_inv_c double precision,
    avg_str_sls_c double precision,
    avg_str_inv_r double precision,
    avg_str_sls_r double precision,
    avg_str_inv_u double precision,
    avg_str_sls_u double precision,
    avg_str_rec_c double precision,
    avg_str_rec_r double precision,
    avg_str_rec_u double precision,
    avg_wk_sls_c double precision,
    avg_wk_inv_c double precision,
    avg_wk_inv_r double precision,
    avg_wk_inv_u double precision,
    avg_wk_sls_r double precision,
    avg_wk_sls_u double precision,
    perm_md_c double precision,
    perm_md_inv_r_csp double precision,
    perm_md_move_inv_u double precision,
    boh_auc double precision,
    boh_aur double precision,
    boh_c double precision,
    eoh_c double precision,
    eoh_c_computed double precision,
    eoh_c_adj double precision,
    inv_adjustment_c double precision,
    mos_c double precision,
    net_dc_xfer_c double precision,
    on_order_c double precision,
    rec_c double precision,
    shrink_c double precision,
    net_sls_c double precision,
    turn_c double precision,
    stk_sls_c double precision,
    eoh_auc double precision,
    eoh_aur double precision,
    net_sls_margin_pct double precision,
    net_sls_margin_r double precision,
    gafs_auc double precision,
    gafs_aur double precision,
    gafs_c double precision,
    gafs_mmu double precision,
    gafs_r double precision,
    gafs_u double precision,
    gmroi double precision,
    inv_adjustment_auc double precision,
    inv_adjustment_aur double precision,
    inv_adjustment_mmu double precision,
    mos_auc double precision,
    mos_aur double precision,
    mos_mmu double precision,
    net_dc_xfer_auc double precision,
    net_dc_xfer_aur double precision,
    net_dc_xfer_mmu double precision,
    pos_disc_pct double precision,
    pos_md_r double precision,
    owned_markup_pct double precision,
    on_order_auc double precision,
    on_order_aur double precision,
    on_order_imu double precision,
    perm_md_pct_off double precision,
    perm_md_r double precision,
    perm_md_inv_auc_edit double precision,
    perm_md_inv_c_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_post_mmu double precision,
    perm_md_previous_mmu double precision,
    perm_md_previous_aur double precision,
    perm_md_inv_u_edit double precision,
    perm_md_new_aur_edit double precision,
    boh_r double precision,
    eoh_r double precision,
    eoh_r_computed double precision,
    eoh_r_adj double precision,
    inv_adjustment_r double precision,
    mos_r double precision,
    net_dc_xfer_r double precision,
    on_order_r double precision,
    rec_r double precision,
    net_sls_r double precision,
    shrink_r double precision,
    rec_auc double precision,
    rec_aur double precision,
    rec_imu double precision,
    net_sls_aut double precision,
    net_sls_auc double precision,
    net_sls_aur double precision,
    shrink_c_pct double precision,
    shrink_auc double precision,
    shrink_aur double precision,
    storecount double precision,
    committed_auc double precision,
    committed_aur double precision,
    committed_imu double precision,
    committed_c double precision,
    committed_r double precision,
    committed_u double precision,
    boh_u double precision,
    eoh_u double precision,
    eoh_u_computed double precision,
    eoh_u_adj double precision,
    inv_adjustment_u double precision,
    mos_u double precision,
    net_dc_xfer_u double precision,
    on_order_u double precision,
    rec_u double precision,
    net_sls_u double precision,
    shrink_u double precision,
    sell_thru_pct double precision,
    turn_u double precision,
    stk_sls_u double precision
);


--
-- Name: plan_data_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL
);


--
-- Name: plan_data_wide_archives; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_archives (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL
);


--
-- Name: plan_data_wide_backup_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_backup_2025_09_28 (
    id integer,
    "time" text,
    product text,
    location text,
    prodlife text,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision
);


--
-- Name: plan_data_wide_backup_refresh; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_backup_refresh (
    id integer,
    "time" text,
    product text,
    location text,
    prodlife text,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision
);


--
-- Name: plan_id_ticker; Type: SEQUENCE; Schema: mfp; Owner: -
--

CREATE SEQUENCE mfp.plan_id_ticker
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_init_status; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_init_status (
    id integer NOT NULL,
    seeded_at timestamp with time zone,
    balanced_at timestamp with time zone
);


--
-- Name: plans; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plans (
    id integer DEFAULT nextval('mfp.plan_id_ticker'::regclass) NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    module text NOT NULL
);


--
-- Name: sys_gen_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.sys_gen_wide (
    sys_version text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision
);


--
-- Name: sys_gen_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp; Owner: -
--

CREATE MATERIALIZED VIEW mfp.sys_gen_wide_denorm AS
 SELECT wide.sys_version,
    "time".week AS time_week,
    "time".year AS time_year,
    product.class AS product_class,
    product.department AS product_department,
    product.total_brand AS product_total_brand,
    location.selling_channel AS location_selling_channel,
    location.channel AS location_channel,
    prodlife.merchcat AS prodlife_merchcat,
    prodlife.prodliferootlevel AS prodlife_prodliferootlevel,
    wide."time",
    wide.product,
    wide.location,
    wide.prodlife,
    wide.storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_r_adj,
    wide.net_sls_c,
    wide.net_sls_c_adj,
    wide.pos_md_r,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.committed_u,
    wide.committed_c,
    wide.committed_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.inv_adjustment_u,
    wide.inv_adjustment_r,
    wide.inv_adjustment_c,
    wide.mos_u,
    wide.mos_r,
    wide.mos_c,
    wide.shrink_u,
    wide.shrink_r,
    wide.shrink_r_adj,
    wide.shrink_c,
    wide.shrink_c_adj,
    wide.net_dc_xfer_u,
    wide.net_dc_xfer_r,
    wide.net_dc_xfer_c,
    wide.perm_md_r,
    wide.perm_md_c,
    wide.perm_md_move_inv_u,
    wide.perm_md_inv_r_csp,
    wide.perm_md_inv_u_edit,
    wide.perm_md_inv_r_at_new_aur_edit,
    wide.perm_md_inv_c_edit
   FROM ((((mfp.sys_gen_wide wide
     JOIN ( SELECT time_denorm.week,
            time_denorm.year
           FROM mfp.time_denorm) "time" ON (("time".week = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department,
            product_denorm.total_brand
           FROM mfp.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.selling_channel,
            location_denorm.channel
           FROM mfp.location_denorm) location ON ((location.selling_channel = wide.location)))
     JOIN ( SELECT prodlife_denorm.merchcat,
            prodlife_denorm.prodliferootlevel
           FROM mfp.prodlife_denorm) prodlife ON ((prodlife.merchcat = wide.prodlife)))
  WITH NO DATA;


--
-- Name: tyly; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly (
    ty text NOT NULL,
    ly text NOT NULL
);


--
-- Name: tyly_backup_2025_09_28; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly_backup_2025_09_28 (
    ty text,
    ly text
);


--
-- Name: tyly_backup_refresh; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly_backup_refresh (
    ty text,
    ly text
);


--
-- Name: user_kv_store; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.user_kv_store (
    uid text NOT NULL,
    key text NOT NULL,
    value text
);


--
-- Name: actuals_stage_wide; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.actuals_stage_wide (
    id text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL,
    mm_r double precision NOT NULL,
    margin_r double precision NOT NULL,
    avg_inv_c double precision NOT NULL
);


--
-- Name: actuals_wide; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.actuals_wide (
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL,
    mm_r double precision NOT NULL,
    margin_r double precision NOT NULL,
    avg_inv_c double precision NOT NULL
);


--
-- Name: dimensions; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions (
    dimension text NOT NULL,
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    levelid text NOT NULL,
    indx integer
);


--
-- Name: hierarchies; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.hierarchies (
    dimension text NOT NULL,
    hierarchy text NOT NULL,
    id text NOT NULL,
    ancestor text NOT NULL
);


--
-- Name: location_denorm; Type: VIEW; Schema: mfp_td; Owner: -
--

CREATE VIEW mfp_td.location_denorm AS
 SELECT channel.id AS channel,
    selling_channel.id AS selling_channel
   FROM (( SELECT dimensions.id
           FROM mfp_td.dimensions
          WHERE ((dimensions.dimension = 'location'::text) AND (dimensions.levelid = 'selling_channel'::text))) selling_channel
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = selling_channel.id) AND (hierarchies.hierarchy = 'locstd'::text))) channel ON (true));


--
-- Name: prodlife_denorm; Type: VIEW; Schema: mfp_td; Owner: -
--

CREATE VIEW mfp_td.prodlife_denorm AS
 SELECT prodliferootlevel.id AS prodliferootlevel,
    merchcat.id AS merchcat
   FROM (( SELECT dimensions.id
           FROM mfp_td.dimensions
          WHERE ((dimensions.dimension = 'prodlife'::text) AND (dimensions.levelid = 'merchcat'::text))) merchcat
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = merchcat.id) AND (hierarchies.hierarchy = 'prodlifestd'::text))) prodliferootlevel ON (true));


--
-- Name: product_denorm; Type: VIEW; Schema: mfp_td; Owner: -
--

CREATE VIEW mfp_td.product_denorm AS
 SELECT total_brand.id AS total_brand,
    division.id AS division,
    "group".id AS "group",
    department.id AS department,
    class.id AS class
   FROM ((((( SELECT dimensions.id
           FROM mfp_td.dimensions
          WHERE ((dimensions.dimension = 'product'::text) AND (dimensions.levelid = 'class'::text))) class
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = class.id) AND (hierarchies.hierarchy = 'prodstd'::text))) department ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = department.id) AND (hierarchies.hierarchy = 'prodstd'::text))) "group" ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = "group".id) AND (hierarchies.hierarchy = 'prodstd'::text))) division ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = division.id) AND (hierarchies.hierarchy = 'prodstd'::text))) total_brand ON (true));


--
-- Name: time_denorm; Type: VIEW; Schema: mfp_td; Owner: -
--

CREATE VIEW mfp_td.time_denorm AS
 SELECT year.id AS year,
    season.id AS season,
    quarter.id AS quarter,
    month.id AS month,
    week.id AS week
   FROM ((((( SELECT dimensions.id
           FROM mfp_td.dimensions
          WHERE ((dimensions.dimension = 'time'::text) AND (dimensions.levelid = 'week'::text))) week
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = week.id) AND (hierarchies.hierarchy = 'timestd'::text))) month ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = month.id) AND (hierarchies.hierarchy = 'timestd'::text))) quarter ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = quarter.id) AND (hierarchies.hierarchy = 'timestd'::text))) season ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp_td.hierarchies
          WHERE ((hierarchies.id = season.id) AND (hierarchies.hierarchy = 'timestd'::text))) year ON (true));


--
-- Name: actuals_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp_td; Owner: -
--

CREATE MATERIALIZED VIEW mfp_td.actuals_wide_denorm AS
 SELECT DISTINCT ON (wide."time", wide.product, wide.location, wide.prodlife) "time".week AS time_week,
    "time".year AS time_year,
    product.class AS product_class,
    product.total_brand AS product_total_brand,
    location.selling_channel AS location_selling_channel,
    location.channel AS location_channel,
    prodlife.merchcat AS prodlife_merchcat,
    prodlife.prodliferootlevel AS prodlife_prodliferootlevel,
    wide."time",
    wide.product,
    wide.location,
    wide.prodlife,
    wide.storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_r_adj,
    wide.net_sls_c,
    wide.net_sls_c_adj,
    wide.pos_md_r,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.committed_u,
    wide.committed_c,
    wide.committed_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.inv_adjustment_u,
    wide.inv_adjustment_r,
    wide.inv_adjustment_c,
    wide.mos_u,
    wide.mos_r,
    wide.mos_c,
    wide.shrink_u,
    wide.shrink_r,
    wide.shrink_r_adj,
    wide.shrink_c,
    wide.shrink_c_adj,
    wide.net_dc_xfer_u,
    wide.net_dc_xfer_r,
    wide.net_dc_xfer_c,
    wide.perm_md_r,
    wide.perm_md_c,
    wide.perm_md_move_inv_u,
    wide.perm_md_inv_r_csp,
    wide.perm_md_inv_u_edit,
    wide.perm_md_inv_r_at_new_aur_edit,
    wide.perm_md_inv_c_edit,
    wide.mm_r,
    wide.margin_r,
    wide.avg_inv_c
   FROM ((((mfp_td.actuals_wide wide
     JOIN ( SELECT time_denorm.week,
            time_denorm.year
           FROM mfp_td.time_denorm) "time" ON (("time".week = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.total_brand
           FROM mfp_td.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.selling_channel,
            location_denorm.channel
           FROM mfp_td.location_denorm) location ON ((location.selling_channel = wide.location)))
     JOIN ( SELECT prodlife_denorm.merchcat,
            prodlife_denorm.prodliferootlevel
           FROM mfp_td.prodlife_denorm) prodlife ON ((prodlife.merchcat = wide.prodlife)))
  WITH NO DATA;


--
-- Name: comments; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.comments (
    comment_id uuid NOT NULL,
    author text NOT NULL,
    plan_id integer NOT NULL,
    view_context text NOT NULL,
    view_template_id text NOT NULL,
    content text NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: currency_exchange_rates; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.currency_exchange_rates (
    "time" text NOT NULL,
    location text NOT NULL,
    exchange_ratio double precision NOT NULL,
    currency_id text DEFAULT 'MISSING'::text NOT NULL
);


--
-- Name: dimensions_backup_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions_backup_2025_09_28 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_backup_refresh; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions_backup_refresh (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_temp_update; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions_temp_update (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_to_be_loaded; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions_to_be_loaded (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_to_be_loaded_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.dimensions_to_be_loaded_2025_09_28 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies_backup_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.hierarchies_backup_2025_09_28 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_backup_refresh; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.hierarchies_backup_refresh (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_to_be_loaded; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.hierarchies_to_be_loaded (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_to_be_loaded_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.hierarchies_to_be_loaded_2025_09_28 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: metadata; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.metadata (
    key text NOT NULL,
    as_int bigint,
    as_string text,
    as_member_id text,
    as_timestamp timestamp with time zone,
    as_member_id_arr text[]
);


--
-- Name: paired_dimension_links; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.paired_dimension_links (
    source_dimension text NOT NULL,
    target_dimension text NOT NULL,
    source_id text NOT NULL,
    target_id text NOT NULL
);


--
-- Name: plan_archives; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_archives (
    id integer NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL
);


--
-- Name: plan_audit_log; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_audit_log (
    plan text NOT NULL,
    action text NOT NULL,
    action_by text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: plan_data_wide; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_data_wide (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL,
    mm_r double precision NOT NULL,
    margin_r double precision NOT NULL,
    avg_inv_c double precision NOT NULL
);


--
-- Name: plan_data_wide_archives; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_data_wide_archives (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_r_adj double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    net_sls_c_adj double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    committed_u double precision NOT NULL,
    committed_c double precision NOT NULL,
    committed_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    inv_adjustment_u double precision NOT NULL,
    inv_adjustment_r double precision NOT NULL,
    inv_adjustment_c double precision NOT NULL,
    mos_u double precision NOT NULL,
    mos_r double precision NOT NULL,
    mos_c double precision NOT NULL,
    shrink_u double precision NOT NULL,
    shrink_r double precision NOT NULL,
    shrink_r_adj double precision NOT NULL,
    shrink_c double precision NOT NULL,
    shrink_c_adj double precision NOT NULL,
    net_dc_xfer_u double precision NOT NULL,
    net_dc_xfer_r double precision NOT NULL,
    net_dc_xfer_c double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    perm_md_c double precision NOT NULL,
    perm_md_move_inv_u double precision NOT NULL,
    perm_md_inv_r_csp double precision NOT NULL,
    perm_md_inv_u_edit double precision NOT NULL,
    perm_md_inv_r_at_new_aur_edit double precision NOT NULL,
    perm_md_inv_c_edit double precision NOT NULL,
    mm_r double precision NOT NULL,
    margin_r double precision NOT NULL,
    avg_inv_c double precision NOT NULL
);


--
-- Name: plan_data_wide_backup_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_data_wide_backup_2025_09_28 (
    id integer,
    "time" text,
    product text,
    location text,
    prodlife text,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision,
    mm_r double precision,
    margin_r double precision,
    avg_inv_c double precision
);


--
-- Name: plan_data_wide_backup_refresh; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_data_wide_backup_refresh (
    id integer,
    "time" text,
    product text,
    location text,
    prodlife text,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision,
    mm_r double precision,
    margin_r double precision,
    avg_inv_c double precision
);


--
-- Name: plan_id_ticker; Type: SEQUENCE; Schema: mfp_td; Owner: -
--

CREATE SEQUENCE mfp_td.plan_id_ticker
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_init_status; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plan_init_status (
    id integer NOT NULL,
    seeded_at timestamp with time zone,
    balanced_at timestamp with time zone
);


--
-- Name: plans; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.plans (
    id integer DEFAULT nextval('mfp_td.plan_id_ticker'::regclass) NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    module text NOT NULL
);


--
-- Name: sys_gen_wide; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.sys_gen_wide (
    sys_version text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    prodlife text NOT NULL,
    storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_r_adj double precision,
    net_sls_c double precision,
    net_sls_c_adj double precision,
    pos_md_r double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    committed_u double precision,
    committed_c double precision,
    committed_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    inv_adjustment_u double precision,
    inv_adjustment_r double precision,
    inv_adjustment_c double precision,
    mos_u double precision,
    mos_r double precision,
    mos_c double precision,
    shrink_u double precision,
    shrink_r double precision,
    shrink_r_adj double precision,
    shrink_c double precision,
    shrink_c_adj double precision,
    net_dc_xfer_u double precision,
    net_dc_xfer_r double precision,
    net_dc_xfer_c double precision,
    perm_md_r double precision,
    perm_md_c double precision,
    perm_md_move_inv_u double precision,
    perm_md_inv_r_csp double precision,
    perm_md_inv_u_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_inv_c_edit double precision,
    mm_r double precision,
    margin_r double precision,
    avg_inv_c double precision
);


--
-- Name: sys_gen_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp_td; Owner: -
--

CREATE MATERIALIZED VIEW mfp_td.sys_gen_wide_denorm AS
 SELECT wide.sys_version,
    "time".week AS time_week,
    "time".year AS time_year,
    product.class AS product_class,
    product.total_brand AS product_total_brand,
    location.selling_channel AS location_selling_channel,
    location.channel AS location_channel,
    prodlife.merchcat AS prodlife_merchcat,
    prodlife.prodliferootlevel AS prodlife_prodliferootlevel,
    wide."time",
    wide.product,
    wide.location,
    wide.prodlife,
    wide.storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_r_adj,
    wide.net_sls_c,
    wide.net_sls_c_adj,
    wide.pos_md_r,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.committed_u,
    wide.committed_c,
    wide.committed_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.inv_adjustment_u,
    wide.inv_adjustment_r,
    wide.inv_adjustment_c,
    wide.mos_u,
    wide.mos_r,
    wide.mos_c,
    wide.shrink_u,
    wide.shrink_r,
    wide.shrink_r_adj,
    wide.shrink_c,
    wide.shrink_c_adj,
    wide.net_dc_xfer_u,
    wide.net_dc_xfer_r,
    wide.net_dc_xfer_c,
    wide.perm_md_r,
    wide.perm_md_c,
    wide.perm_md_move_inv_u,
    wide.perm_md_inv_r_csp,
    wide.perm_md_inv_u_edit,
    wide.perm_md_inv_r_at_new_aur_edit,
    wide.perm_md_inv_c_edit,
    wide.mm_r,
    wide.margin_r,
    wide.avg_inv_c
   FROM ((((mfp_td.sys_gen_wide wide
     JOIN ( SELECT time_denorm.week,
            time_denorm.year
           FROM mfp_td.time_denorm) "time" ON (("time".week = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.total_brand
           FROM mfp_td.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.selling_channel,
            location_denorm.channel
           FROM mfp_td.location_denorm) location ON ((location.selling_channel = wide.location)))
     JOIN ( SELECT prodlife_denorm.merchcat,
            prodlife_denorm.prodliferootlevel
           FROM mfp_td.prodlife_denorm) prodlife ON ((prodlife.merchcat = wide.prodlife)))
  WITH NO DATA;


--
-- Name: tyly; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.tyly (
    ty text NOT NULL,
    ly text NOT NULL
);


--
-- Name: tyly_backup_2025_09_28; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.tyly_backup_2025_09_28 (
    ty text,
    ly text
);


--
-- Name: tyly_backup_refresh; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.tyly_backup_refresh (
    ty text,
    ly text
);


--
-- Name: user_kv_store; Type: TABLE; Schema: mfp_td; Owner: -
--

CREATE TABLE mfp_td.user_kv_store (
    uid text NOT NULL,
    key text NOT NULL,
    value text
);


--
-- Name: agent_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_conversations (
    conversation_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agent_conversations_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_conversations_log (
    conversation_id uuid NOT NULL,
    message_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_sender public.agent_sender NOT NULL,
    message_content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: allocation_plan_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.allocation_plan_queue (
    jobid uuid NOT NULL,
    initiator text NOT NULL,
    model_defn_path text NOT NULL,
    scope json NOT NULL,
    state public.queue_state,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    error text,
    instance_id text
);


--
-- Name: allocation_plan_queue_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.allocation_plan_queue_items (
    jobid uuid,
    user_id text NOT NULL,
    product text NOT NULL,
    type text NOT NULL,
    name text DEFAULT '⚠️❓❓'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: trd_d_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product (
    id text NOT NULL,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_h_prodstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_styleattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_styleattributes (
    product text NOT NULL,
    sty_knit_or_woven text,
    sty_fabrication text,
    sty_sleeve_length text,
    sty_leg_opening text,
    sty_brand text,
    sty_body_style_silhouette text,
    sty_occasion_usage text,
    sty_detail text,
    sty_finish_style text,
    sty_private_label text,
    sty_license text,
    sty_license_vs_non_licensed text,
    sty_hazmat_code text,
    sty_prop_65_warning text,
    sty_material_content text,
    sty_item_type text,
    sty_dwrise text,
    sty_length text,
    sty_neckline text,
    sty_toeshape text,
    sty_heel_height text,
    sty_bottom_length text,
    sty_v_360_smoothing text,
    sty_franchise text,
    sty_key_item text,
    sty_single_vs_multi_pack text,
    sty_ticket_type text,
    sty_vpn text,
    sty_size_range text,
    ccstylecreatedate text,
    sty_is_locked text,
    sty_s5_adopted text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    plm_size_range text,
    sty_knit_fit text,
    sty_patterned_after text,
    sty_vpn_desc text,
    sty_num_clones_s5 real,
    sty_num_times_cloned_s5 real
);


--
-- Name: trd_ma_stylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorattributes (
    product text NOT NULL,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost real,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    cccolor text,
    cccolorfamily text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone,
    allocator_comments text,
    cccolorid text,
    cc_specstylecolor_status text,
    cc_agent_fee text,
    cc_port text,
    cc_factory text,
    cc_floorset text,
    cc_use_sys_floorset boolean DEFAULT true,
    cc_supp_cost real,
    cc_finish text,
    cc_license text,
    cc_channel_availability text,
    cc_extended_size text,
    cc_op_markdown_week text,
    cc_motif text,
    cc_rp_revised_markdown_week text,
    cc_web_current_retail real,
    cc_parent_season_code text,
    cc_art_code text,
    cc_patterned_after text,
    cc_material_content text,
    cc_fabrication text,
    style_name text,
    stylecolor_name text,
    buyer_email text,
    cc_buyer text,
    cc_patterned_after_name text,
    vpn_color_desc text,
    cc_num_clones_s5 real,
    cc_num_times_cloned_s5 real,
    cc_spec_division text,
    cc_spec_group text,
    cc_development_season text,
    cc_delivery_season text,
    cc_po_due_date text,
    cc_pd_ndc_week text,
    cc_additional_tariff text,
    cc_design_notes text,
    cc_pd_notes text,
    cc_compliance_notes text,
    merge_target_style text,
    new_stylecolor_name text,
    split_new_style_name text
);


--
-- Name: trd_ma_stylecolorchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorchannelattributes (
    product text NOT NULL,
    location text NOT NULL,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real DEFAULT 3,
    slsrnk_ecom real DEFAULT 3,
    validsizes text[] DEFAULT ARRAY[]::text[],
    cc_validsizes_store text[] DEFAULT ARRAY[]::text[],
    cc_validsizes_ecom text[] DEFAULT ARRAY[]::text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real DEFAULT '0.01'::real,
    ccticketpricechannel_override real,
    cc_imupct real DEFAULT 0.0,
    cc_discount_pct real DEFAULT 0.0,
    cc_existingwac real DEFAULT 0.0,
    cc_systemcost real DEFAULT 0.0,
    cc_plan_cost real DEFAULT 0.0,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text DEFAULT 'No'::text,
    auto_rollforward boolean DEFAULT false,
    irr_mode text DEFAULT 'Normal'::text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real DEFAULT 0.7,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real DEFAULT 0.0,
    cc_discount_pct_ecom real DEFAULT 0.0,
    irw_debut_offset integer,
    cc_service_level_ecom real DEFAULT 0.95,
    cc_first_publish_date timestamp without time zone,
    cc_first_publish_snapshot_op integer,
    sclr_alloc_max real,
    sclr_presmin real,
    sclr_alloc_min real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real DEFAULT 4,
    sclr_fringe_flag real DEFAULT 1,
    act_slsrnk_store real,
    act_aps_store real,
    act_aps_mult_adj_store real,
    act_slsrnk_ecom real,
    act_aps_ecom real,
    act_aps_mult_adj_ecom real,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    use_valid_sizes_from text DEFAULT 'Defaults – All Valid Sizes'::text,
    apply_size_mins_to text DEFAULT 'Core Sizes Only'::text,
    cc_addoff_store real,
    cc_addoff_ecom real,
    irw_floorset text,
    irw_superset text,
    irw_floorset_display text,
    irw_superset_display text,
    irw_floorset_id text,
    cc_size_eligibility_profile text,
    cloned_at timestamp(0) without time zone
);


--
-- Name: alt_trd_stylecolor_hier_attr; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.alt_trd_stylecolor_hier_attr AS
 SELECT a.product,
    a.cc_item_diff_1,
    a.cc_unit_retail,
    a.cc_unit_retail_cad,
    a.cc_pattern,
    a.cc_graphic,
    a.cc_fashion_basic,
    a.cc_holiday,
    a.cc_property_type,
    a.cc_internet_exclusive,
    a.cc_web_color_discription,
    a.cc_export_hts,
    a.cc_commercial_invoice_description,
    a.cc_season_code,
    a.cc_dtr,
    a.cc_dw_color_family,
    a.cc_channel_reorder,
    a.cc_ticket_season_code,
    a.cc_sub_programs,
    a.cc_music_genre,
    a.cc_clearance_str_product,
    a.cc_po_supplier,
    a.cc_origin_country_id,
    a.cc_country_of_sourcing,
    a.cc_country_of_manufacturing,
    a.cc_unit_cost,
    a.cc_freight,
    a.cc_royalty,
    a.cc_duty,
    a.cc_ship_method,
    a.cc_lading_port,
    a.cc_hts,
    a.cc_primary_supplier,
    a.cc_sub_brand,
    a.cc_pattern_type,
    a.cc_pop_print_neutral,
    a.cc_debut_season_code,
    a.cc_matchback,
    a.cc_primary_collection,
    a.cc_secondary_collection,
    a.cc_vpn_color,
    a.cc_orig_unit_retail,
    a.cc_orig_unit_retail_cad,
    a.cc_first_rec_week,
    a.cc_first_inv_week,
    a.cc_first_sale_week,
    a.cc_first_md_week,
    a.cc_last_md_week,
    a.cc_last_rec_week,
    a.cc_store_price_status,
    a.cc_ifc_price_status,
    a.cc_omni_price_type,
    a.cc_agent_fee,
    a.cc_factory,
    a.ccstylecolorcreatedate,
    a.cc_price_band,
    a.cc_good_better_best,
    a.cc_port,
    a.cccolor,
    a.cccolorfamily,
    a.cccolorid,
    a.isassortment,
    a.merch_comments,
    a.plan_comments,
    a.allocator_comments,
    a.cc_is_locked,
    a.cc_s5_adopted,
    a.cc_prepublish,
    a.cc_prepublished_at,
    c.sty_knit_or_woven,
    c.sty_fabrication,
    c.sty_sleeve_length,
    c.sty_leg_opening,
    c.sty_brand,
    c.sty_body_style_silhouette,
    c.sty_occasion_usage,
    c.sty_detail,
    c.sty_finish_style,
    c.sty_private_label,
    c.sty_license,
    c.sty_license_vs_non_licensed,
    c.sty_hazmat_code,
    c.sty_prop_65_warning,
    c.sty_material_content,
    c.sty_item_type,
    c.sty_dwrise,
    c.sty_length,
    c.sty_neckline,
    c.sty_toeshape,
    c.sty_heel_height,
    c.sty_bottom_length,
    c.sty_v_360_smoothing,
    c.sty_franchise,
    c.sty_key_item,
    c.sty_single_vs_multi_pack,
    c.sty_ticket_type,
    c.sty_vpn,
    c.sty_size_range,
    c.ccstylecreatedate AS ccstylecreatedate2,
    c.sty_is_locked,
    c.sty_s5_adopted,
    c.plm_size_range,
    b.id AS stylecolor,
    b.ancestor0 AS style,
    b.ancestor1 AS subclass,
    b.ancestor2 AS class,
    b.ancestor3 AS department,
    b.ancestor4 AS group_id,
    b.ancestor5 AS division,
    b.ancestor6 AS total_brand,
    d.stylecolor_name,
    d.stylecolor_desc,
    e.style_name,
    e.style_desc,
    f.subclass_name,
    f.subclass_desc,
    g.class_name,
    g.class_desc,
    h.department_name,
    h.department_desc,
    i.group_name,
    i.group_desc,
    j.division_name,
    j.division_desc,
    k.total_brand_name,
    k.total_brand_desc,
    a.eventdate,
    a.version_id,
    a.created_at,
    a.created_by,
    GREATEST(a.updated_at, c.updated_at) AS updated_at,
    a.updated_by,
    a.record_state,
    a.cc_floorset,
        CASE
            WHEN (a.cc_use_sys_floorset = false) THEN 0
            ELSE 1
        END AS cc_use_sys_floorset,
    c.sty_knit_fit,
    a.cc_supp_cost,
    a.cc_finish,
    a.cc_license,
    a.cc_channel_availability,
    a.cc_extended_size,
    a.cc_op_markdown_week,
    a.cc_motif,
    a.cc_rp_revised_markdown_week,
    a.cc_web_current_retail,
    a.cc_parent_season_code,
    a.cc_art_code,
    c.sty_patterned_after,
    a.cc_patterned_after,
    a.cc_specstylecolor_status,
    a.cc_material_content,
    a.cc_fabrication,
    a.buyer_email,
    a.cc_buyer,
    ch.irw_floorset,
    ch.irw_superset,
    ch.irw_floorset_display,
    ch.irw_superset_display
   FROM public.trd_ma_stylecolorattributes a,
    public.trd_h_prodstd b,
    public.trd_ma_styleattributes c,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS stylecolor_name,
            trd_d_product.description AS stylecolor_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'stylecolor'::text)) d,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS style_name,
            trd_d_product.description AS style_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'style'::text)) e,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS subclass_name,
            trd_d_product.description AS subclass_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'subclass'::text)) f,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS class_name,
            trd_d_product.description AS class_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'class'::text)) g,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS department_name,
            trd_d_product.description AS department_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'department'::text)) h,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS group_name,
            trd_d_product.description AS group_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'group_id'::text)) i,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS division_name,
            trd_d_product.description AS division_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'division'::text)) j,
    (( SELECT trd_d_product.id,
            trd_d_product.name AS total_brand_name,
            trd_d_product.description AS total_brand_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'total_brand'::text)) k
     LEFT JOIN LATERAL ( SELECT t.irw_floorset,
            t.irw_superset,
            t.irw_floorset_display,
            t.irw_superset_display
           FROM public.trd_ma_stylecolorchannelattributes t
          WHERE (t.product = a.product)) ch ON (true))
  WHERE ((a.product = b.id) AND (b.ancestor0 = c.product) AND (a.product = d.id) AND (b.ancestor0 = e.id) AND (b.ancestor1 = f.id) AND (b.ancestor2 = g.id) AND (b.ancestor3 = h.id) AND (b.ancestor4 = i.id) AND (b.ancestor5 = j.id) AND (b.ancestor6 = k.id))
  ORDER BY b.id;


--
-- Name: arf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.arf (
    product text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    next text
);


--
-- Name: assort_period_from_dpt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assort_period_from_dpt (
    department text NOT NULL,
    "time" text NOT NULL,
    floorset text
);


--
-- Name: ata_cart_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_master (
    jsessionid text,
    style_sequence text,
    style_id text,
    style_name text,
    style_description text,
    style_type text,
    cccolor text,
    stylecolor_id text,
    stylecolor_type text,
    stylecolor_name text,
    stylecolor_description text,
    isprocessed integer,
    initiator text,
    img text,
    job_priority integer,
    new_stylecolor_id text,
    scope_floorset text,
    department text
);


--
-- Name: ata_cart_master_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_master_archive (
    jsessionid text,
    style_sequence text,
    style_id text,
    style_name text,
    style_description text,
    style_type text,
    cccolor text,
    stylecolor_id text,
    stylecolor_type text,
    stylecolor_name text,
    stylecolor_description text,
    isprocessed integer,
    initiator text,
    img text,
    job_priority integer,
    new_stylecolor_id text,
    scope_floorset text,
    department text,
    updated_at date
);


--
-- Name: ata_cart_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_params (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
    planned_sell_down_week text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    erlstmkdnwk text,
    exitdate text,
    ccmdstrategy text,
    presmin integer,
    presmin_weeks integer,
    retpct_str real,
    retpct_ecomm real,
    retpct_cross real,
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk_store real,
    slsrnk_ecom real,
    auto_rollforward boolean,
    sty_size_type text,
    sty_size_range text,
    class text,
    subclass text,
    cc_cluster_group text,
    irw_debut_offset integer,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    use_valid_sizes_from text DEFAULT 'Defaults – All Valid Sizes'::text,
    apply_size_mins_to text DEFAULT 'Core Sizes Only'::text,
    cc_addoff_store real,
    cc_addoff_ecom real
);


--
-- Name: ata_cart_params_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_params_archive (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
    planned_sell_down_week text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    erlstmkdnwk text,
    exitdate text,
    ccmdstrategy text,
    presmin integer,
    presmin_weeks integer,
    retpct_str real,
    retpct_ecomm real,
    retpct_cross real,
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk_store real,
    slsrnk_ecom real,
    auto_rollforward boolean,
    sty_size_type text,
    sty_size_range text,
    class text,
    subclass text,
    cc_cluster_group text,
    irw_debut_offset integer,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    use_valid_sizes_from text DEFAULT 'Defaults – All Valid Sizes'::text,
    apply_size_mins_to text DEFAULT 'Core Sizes Only'::text,
    cc_addoff_store real,
    cc_addoff_ecom real,
    updated_at date
);


--
-- Name: ata_cart_ranging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_ranging (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text,
    isfunded integer,
    indx integer,
    store_count integer,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: ata_cart_ranging_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_cart_ranging_archive (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text,
    isfunded integer,
    indx integer,
    store_count integer,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[],
    updated_at date
);


--
-- Name: ata_plan_these_style_stylecolors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_plan_these_style_stylecolors (
    style text,
    stylecolor text,
    session_id text,
    updated_by text,
    picked_for_planning integer
);


--
-- Name: bi_assortmentbyfloorset_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bi_assortmentbyfloorset_staging (
    run_id integer,
    row_id integer,
    stylecolor_id text,
    stylecolor_name text,
    stylecolor_description text,
    floorset text,
    channel text,
    color_name text,
    pricing_tier text,
    editable_plan_cost real,
    wac real,
    status text,
    editable_preseason_sales_rating real,
    initial_rec_week text,
    editable_debut_week text,
    relaunch_week text,
    editable_markdown_week text,
    editable_exit_week text,
    last_dc_order_week text,
    editable_markdown_strategy text,
    editable_debut_floorset text,
    store_count_average integer,
    editable_store_vol_tier_dept text[],
    editable_climate text[],
    editable_capacity_mens text[],
    editable_capacity_womens text[],
    editable_ssg integer,
    editable_is_funded text,
    ticket_price real,
    unconstrained_sales_u integer,
    sales_u_override integer,
    final_sales_u integer,
    final_aps_u real,
    final_sales_r real,
    final_sales_c real,
    system_rec_u integer,
    rec_u_override integer,
    on_order_u integer,
    on_order_u_override integer,
    final_rec_u integer,
    dc_receipt_c real,
    boh_u integer,
    eoh_u integer,
    total_stock_to_sales real,
    margin_r real,
    margin_percent real
);


--
-- Name: bi_assortmentbyfloorset_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bi_assortmentbyfloorset_summary (
    run_id integer,
    row_id integer,
    stylecolor_id text,
    stylecolor_name text,
    stylecolor_description text,
    floorset text,
    channel text,
    color_name text,
    pricing_tier text,
    editable_plan_cost real,
    wac real,
    status text,
    editable_preseason_sales_rating real,
    initial_rec_week text,
    editable_debut_week text,
    relaunch_week text,
    editable_markdown_week text,
    editable_exit_week text,
    last_dc_order_week text,
    editable_markdown_strategy text,
    editable_debut_floorset text,
    store_count_average integer,
    editable_store_vol_tier_dept text[],
    editable_climate text[],
    editable_capacity_mens text[],
    editable_capacity_womens text[],
    editable_ssg integer,
    editable_is_funded text,
    ticket_price real,
    unconstrained_sales_u integer,
    sales_u_override integer,
    final_sales_u integer,
    final_aps_u real,
    final_sales_r real,
    final_sales_c real,
    system_rec_u integer,
    rec_u_override integer,
    on_order_u integer,
    on_order_u_override integer,
    final_rec_u integer,
    dc_receipt_c real,
    boh_u integer,
    eoh_u integer,
    total_stock_to_sales real,
    margin_r real,
    margin_percent real,
    validation_status text,
    reason text[]
);


--
-- Name: bulk_import_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_import_audit (
    run_id integer NOT NULL,
    principle text NOT NULL,
    run_time timestamp with time zone NOT NULL,
    bulk_import_id text NOT NULL
);


--
-- Name: bulk_import_refs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_import_refs (
    user_id text NOT NULL,
    import_id text NOT NULL,
    transaction_id text NOT NULL,
    storage_path text
);


--
-- Name: bulk_import_run_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_import_run_params (
    run_id integer NOT NULL,
    param text NOT NULL,
    str_value text
);


--
-- Name: bulk_run_id_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_run_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_master (
    jsessionid text,
    style_sequence text,
    style_id text,
    style_name text,
    style_description text,
    style_type text,
    cccolor text,
    stylecolor_id text,
    stylecolor_type text,
    stylecolor_name text,
    stylecolor_description text,
    isprocessed integer DEFAULT 0,
    initiator text,
    img text,
    job_priority integer DEFAULT 2
);


--
-- Name: cart_master_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_master_archive (
    jsessionid text,
    style_sequence text,
    style_id text,
    style_name text,
    style_description text,
    style_type text,
    cccolor text,
    stylecolor_id text,
    stylecolor_type text,
    stylecolor_name text,
    stylecolor_description text,
    isprocessed integer DEFAULT 0,
    initiator text,
    img text,
    job_priority integer DEFAULT 2
);


--
-- Name: cart_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_params (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
    planned_sell_down_week text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    erlstmkdnwk text,
    exitdate text,
    ccmdstrategy text,
    presmin integer,
    presmin_weeks integer,
    retpct_str real,
    retpct_ecomm real,
    retpct_cross real,
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk_store real,
    slsrnk_ecom real,
    auto_rollforward boolean,
    sty_size_type text,
    sty_size_range text,
    class text,
    subclass text,
    cc_cluster_group text,
    irw_debut_offset integer,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    use_valid_sizes_from text DEFAULT 'Defaults – All Valid Sizes'::text,
    apply_size_mins_to text DEFAULT 'Core Sizes Only'::text,
    cc_addoff_store real,
    cc_addoff_ecom real
);


--
-- Name: cart_params_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_params_archive (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
    planned_sell_down_week text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    erlstmkdnwk text,
    exitdate text,
    ccmdstrategy text,
    presmin integer,
    presmin_weeks integer,
    retpct_str real,
    retpct_ecomm real,
    retpct_cross real,
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk_store real,
    slsrnk_ecom real,
    auto_rollforward boolean,
    sty_size_type text,
    sty_size_range text,
    class text,
    subclass text,
    cc_cluster_group text,
    irw_debut_offset integer,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    use_valid_sizes_from text DEFAULT 'Defaults – All Valid Sizes'::text,
    apply_size_mins_to text DEFAULT 'Core Sizes Only'::text,
    cc_addoff_store real,
    cc_addoff_ecom real
);


--
-- Name: cart_params_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_params_bkp (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
    planned_sell_down_week text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    erlstmkdnwk text,
    exitdate text,
    ccmdstrategy text,
    presmin integer,
    presmin_weeks integer,
    retpct_str real,
    retpct_ecomm real,
    retpct_cross real,
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk_store real,
    slsrnk_ecom real,
    auto_rollforward boolean,
    sty_size_type text,
    sty_size_range text,
    class text,
    subclass text,
    cc_cluster_group text
);


--
-- Name: cart_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_queue (
    cart_id text NOT NULL,
    user_id text NOT NULL,
    scope_id uuid NOT NULL,
    state public.queue_state NOT NULL,
    error_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    instance_id text
);


--
-- Name: cart_ranging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_ranging (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text,
    isfunded integer,
    indx integer,
    store_count integer,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: cart_ranging_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_ranging_archive (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text,
    flnrange text,
    isfunded integer,
    indx integer,
    store_count integer,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: culprits_0223; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.culprits_0223 (
    product text
);


--
-- Name: culprits_0302; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.culprits_0302 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: culprits_0323; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.culprits_0323 (
    product text
);


--
-- Name: curr_prod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.curr_prod (
    product text
);


--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


--
-- Name: debug_stats_ts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debug_stats_ts (
    stat_id text,
    stat text,
    ts timestamp with time zone
);


--
-- Name: default_disc_md; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_disc_md (
    department text,
    default_discount real
);


--
-- Name: delete_me_user_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_me_user_worklist (
    user_id text,
    product text,
    type text,
    updated_at timestamp without time zone,
    name text
);


--
-- Name: deleteme_20250928_planning_failures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_20250928_planning_failures (
    department text,
    class text,
    subclass text,
    product text,
    name text,
    dbt_wk text,
    initrcptwk text,
    erlstmkdnwk text,
    exitdate text,
    cc_cluster_group text
);


--
-- Name: deleteme_44231008_richblack_d_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_44231008_richblack_d_product (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_44231008_richblack_h_prodstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_44231008_richblack_h_prodstd (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_44231008_richblack_sizeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_44231008_richblack_sizeattributes (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: deleteme_failed_items_20250327; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_failed_items_20250327 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: deleteme_failed_items_20250328; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_failed_items_20250328 (
    product text,
    notes text
);


--
-- Name: deleteme_fix_floorsets_after_reclass; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_fix_floorsets_after_reclass (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[],
    department text,
    dbt_wk text,
    exitdate text
);


--
-- Name: deleteme_fix_floorsets_after_reclass_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_fix_floorsets_after_reclass_assortment (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[]
);


--
-- Name: deleteme_fix_floorsets_after_reclass_assortmentssg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_fix_floorsets_after_reclass_assortmentssg (
    product text,
    location text,
    "time" text,
    style text,
    ssg text[]
);


--
-- Name: deleteme_fix_str_grade; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_fix_str_grade (
    product text,
    "time" text,
    str_grade text[],
    new_str_grade text[]
);


--
-- Name: deleteme_itmes_44231008_richblack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_itmes_44231008_richblack (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: deleteme_itmes_deplicates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_itmes_deplicates (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: deleteme_itmes_deplicates_d_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_itmes_deplicates_d_product (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_itmes_deplicates_h_prodstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_itmes_deplicates_h_prodstd (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_itmes_deplicates_sizeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_itmes_deplicates_sizeattributes (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: deleteme_new_mdstrategy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_new_mdstrategy (
    product text,
    ccmdstrategy text,
    ancestor3 text,
    new_ccmdstrategy text
);


--
-- Name: deleteme_plan_queue_20250201; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_plan_queue_20250201 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: deleteme_plan_queue_20250201_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_plan_queue_20250201_01 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: deleteme_plan_queue_20250202_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_plan_queue_20250202_02 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: deleteme_trd_a_assortment_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_a_assortment_20251028 (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: deleteme_trd_all_sizes_possible; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_all_sizes_possible (
    style text,
    stylecolor text,
    sty_size_range text,
    size_id text,
    size_desc text,
    parent_size text
);


--
-- Name: deleteme_trd_d_product_20250422; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_d_product_20250422 (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_trd_d_product_20250425; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_d_product_20250425 (
    id text
);


--
-- Name: deleteme_trd_d_product_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_d_product_20251028 (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_trd_fix_ccticketpricechannel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_fix_ccticketpricechannel (
    product text,
    cc_orig_unit_retail real,
    ccticketpricechannel real
);


--
-- Name: deleteme_trd_fix_unit_retail_cloning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_fix_unit_retail_cloning (
    product text,
    name text,
    cc_unit_retail real,
    cc_orig_unit_retail real,
    cc_unit_retail_cad real,
    cc_orig_unit_retail_cad real
);


--
-- Name: deleteme_trd_h_prodstd_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_h_prodstd_20251028 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_trd_in_prd_attrstyle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_in_prd_attrstyle (
    product text,
    sty_knit_or_woven text,
    sty_fabrication text,
    sty_sleeve_length text,
    sty_leg_opening text,
    sty_brand text,
    sty_body_style_silhouette text,
    sty_occasion_usage text,
    sty_detail text,
    sty_finish_style text,
    sty_private_label text,
    sty_license text,
    sty_license_vs_non_licensed text,
    sty_hazmat_code text,
    sty_prop_65_warning text,
    sty_material_content text,
    sty_item_type text,
    sty_dwrise text,
    sty_length text,
    sty_neckline text,
    sty_toeshape text,
    sty_heel_height text,
    sty_bottom_length text,
    sty_v_360_smoothing text,
    sty_franchise text,
    sty_key_item text,
    sty_single_vs_multi_pack text,
    sty_ticket_type text,
    sty_vpn text,
    sty_size_range text,
    ccstylecreatedate text,
    style_attribute_1 text,
    style_attribute_2 text,
    style_attribute_3 text,
    style_attribute_4 text,
    style_attribute_5 text,
    style_attribute_6 text,
    style_attribute_7 text,
    style_attribute_8 text
);


--
-- Name: deleteme_trd_l_dependencylookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_l_dependencylookup (
    lookup_id text,
    lookup_value text,
    target_id text,
    target_value text,
    index text,
    rnk bigint
);


--
-- Name: deleteme_trd_ma_dptflrsetattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_dptflrsetattributes (
    indx integer,
    product text,
    "time" text,
    floorset_name text,
    dept_name text,
    superset_id text,
    superset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    weeks_at_fp text,
    markdown_week text,
    exit_week text,
    ly_rcptstart text,
    ly_rcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_planned_sell_down_week text,
    floorset_uda text,
    ly_floorset_uda text,
    default_slsrnk_store real,
    default_slsrnk_ecom real,
    default_store_vol_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_retpct_str real,
    default_retpct_ecom real,
    default_crosschannel_retpct_ecom real,
    default_ccordermultiple_uom integer,
    default_ccmdstrategy text,
    default_lead_time integer,
    default_ccdiscountpct real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_trd_ma_dptflrsetattributes_ccmdstrategy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_dptflrsetattributes_ccmdstrategy (
    default_ccmdstrategy text,
    new_default_ccmdstrategy text
);


--
-- Name: deleteme_trd_ma_imgattributes_fixed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_imgattributes_fixed (
    product text,
    img text
);


--
-- Name: deleteme_trd_ma_imgattributes_jr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_imgattributes_jr (
    indx integer,
    product text,
    img text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_trd_ma_sizeattributes_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_sizeattributes_20251028 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: deleteme_trd_ma_sizeattributes_20260319; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_sizeattributes_20260319 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text,
    sort_order text
);


--
-- Name: deleteme_trd_ma_sizeattributes_new_sizes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_sizeattributes_new_sizes (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: deleteme_trd_ma_styleattributes_20250331; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_styleattributes_20250331 (
    product text,
    sty_knit_or_woven text,
    sty_fabrication text,
    sty_sleeve_length text,
    sty_leg_opening text,
    sty_brand text,
    sty_body_style_silhouette text,
    sty_occasion_usage text,
    sty_detail text,
    sty_finish_style text,
    sty_private_label text,
    sty_license text,
    sty_license_vs_non_licensed text,
    sty_hazmat_code text,
    sty_prop_65_warning text,
    sty_material_content text,
    sty_item_type text,
    sty_dwrise text,
    sty_length text,
    sty_neckline text,
    sty_toeshape text,
    sty_heel_height text,
    sty_bottom_length text,
    sty_v_360_smoothing text,
    sty_franchise text,
    sty_key_item text,
    sty_single_vs_multi_pack text,
    sty_ticket_type text,
    sty_vpn text,
    sty_size_range text,
    ccstylecreatedate text,
    sty_is_locked text,
    sty_s5_adopted text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    plm_size_range text,
    sty_knit_fit text,
    sty_patterned_after text
);


--
-- Name: deleteme_trd_ma_stylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_stylecolorattributes (
    product text,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost text,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone
);


--
-- Name: deleteme_trd_ma_stylecolorattributes_20250331; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_stylecolorattributes_20250331 (
    product text,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost real,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    cccolor text,
    cccolorfamily text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone,
    allocator_comments text,
    cccolorid text,
    cc_specstylecolor_status text,
    cc_agent_fee text,
    cc_port text,
    cc_factory text,
    cc_floorset text,
    cc_use_sys_floorset boolean,
    cc_supp_cost real,
    cc_finish text,
    cc_license text,
    cc_channel_availability text,
    cc_extended_size text,
    cc_op_markdown_week text,
    cc_motif text,
    cc_rp_revised_markdown_week text,
    cc_web_current_retail real,
    cc_parent_season_code text,
    cc_art_code text,
    cc_patterned_after text,
    cc_material_content text,
    cc_fabrication text,
    style_name text,
    stylecolor_name text,
    buyer_email text,
    cc_buyer text
);


--
-- Name: deleteme_trd_ma_stylecolorattributes_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_stylecolorattributes_20251028 (
    product text,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost real,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    cccolor text,
    cccolorfamily text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone,
    allocator_comments text,
    cccolorid text,
    cc_specstylecolor_status text,
    cc_agent_fee text,
    cc_port text,
    cc_factory text,
    cc_floorset text,
    cc_use_sys_floorset boolean,
    cc_supp_cost real,
    cc_finish text,
    cc_license text,
    cc_channel_availability text,
    cc_extended_size text,
    cc_op_markdown_week text,
    cc_motif text,
    cc_rp_revised_markdown_week text,
    cc_web_current_retail real,
    cc_parent_season_code text,
    cc_art_code text,
    cc_patterned_after text,
    cc_material_content text,
    cc_fabrication text,
    style_name text,
    stylecolor_name text,
    buyer_email text,
    cc_buyer text,
    cc_patterned_after_name text,
    vpn_color_desc text,
    cc_num_clones_s5 real,
    cc_num_times_cloned_s5 real
);


--
-- Name: deleteme_trd_ma_stylecolorchannelattributes_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_ma_stylecolorchannelattributes_20251028 (
    product text,
    location text,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real,
    slsrnk_ecom real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real,
    ccticketpricechannel_override real,
    cc_imupct real,
    cc_discount_pct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_plan_cost real,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real,
    cc_discount_pct_ecom real,
    irw_debut_offset integer,
    cc_service_level_ecom real,
    cc_first_publish_date timestamp without time zone,
    cc_first_publish_snapshot_op integer,
    sclr_alloc_max real,
    sclr_presmin real,
    sclr_alloc_min real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_fringe_flag real,
    act_slsrnk_store real,
    act_aps_store real,
    act_aps_mult_adj_store real,
    act_slsrnk_ecom real,
    act_aps_ecom real,
    act_aps_mult_adj_ecom real,
    use_act_aps_or_act_rank text,
    use_valid_sizes_from text,
    apply_size_mins_to text,
    cc_addoff_store real,
    cc_addoff_ecom real,
    irw_floorset text,
    irw_superset text,
    irw_floorset_display text,
    irw_superset_display text,
    irw_floorset_id text,
    cc_size_eligibility_profile text,
    cloned_at timestamp(0) without time zone
);


--
-- Name: deleteme_trd_new_sizes_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_new_sizes_list (
    size_range text,
    size_id text,
    size_desc text,
    parent_size text
);


--
-- Name: deleteme_trd_p_channeloverride_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_p_channeloverride_20251028 (
    product text,
    location text,
    "time" text,
    weekadjaps real,
    weekadjaps_ecom real,
    weekadjslsu real,
    weekadjslsu_ecom real,
    comments text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    testpo text,
    floorsetpo text
);


--
-- Name: deleteme_trd_p_dc_adj_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_p_dc_adj_20251028 (
    product text,
    location text,
    "time" text,
    dc_publish real,
    is_locked real,
    dc_uservrp real,
    dc_lockedqty real,
    dc_useradj real,
    dc_onorder real,
    dc_finrev real,
    dc_validwk real,
    dc_finalqty real,
    dc_adjcost real,
    const_y_n real,
    sbkt real,
    dc_isedited real,
    dc_syscost real,
    dc_lndcst real,
    dc_sysvrp real,
    dc_sc_useradj real,
    dc_sc_finrev real,
    po_indicator text,
    po_shipmode text,
    air_trigger text,
    cut text,
    published_at timestamp(0) without time zone,
    is_prepublished real,
    prepublished_at timestamp(0) without time zone,
    last_prepublished real,
    po_arr text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    dc_useradj_ecom real,
    dc_onorder_ecom real,
    dc_finrev_ecom real,
    dc_publish_ecom real,
    po_indicator_ecom text,
    po_shipmode_ecom text,
    air_trigger_ecom text,
    cut_ecom text,
    published_at_ecom timestamp(0) without time zone,
    is_prepublished_ecom real,
    prepublished_at_ecom timestamp(0) without time zone,
    last_prepublished_ecom real,
    reason_code text,
    reason_code_ecom text,
    pack_ind_flag text,
    pack_ind_flag_ecom text,
    show_in_pack text,
    show_in_pack_ecom text,
    prepack_pct real,
    prepack_pct_ecom real,
    default_fringe_indicator text,
    default_fringe_indicator_ecom text,
    email_to text
);


--
-- Name: deleteme_trd_p_dc_adj_size_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_p_dc_adj_size_20251028 (
    product text,
    location text,
    "time" text,
    dc_publish real,
    is_locked real,
    dc_uservrp real,
    dc_lockedqty real,
    dc_useradj real,
    dc_onorder real,
    dc_finrev real,
    dc_validwk real,
    dc_finalqty real,
    dc_adjcost real,
    const_y_n real,
    sbkt real,
    dc_scadj real,
    dc_ttluseradj real,
    dc_scfinrev real,
    dc_ttlfinrev real,
    dc_isedited real,
    dc_onorder_v real,
    dc_onorder_c real,
    current_week text,
    dc_last_pub_u real,
    dc_last_pub timestamp without time zone,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    dc_useradj_ecom real,
    dc_onorder_ecom real,
    dc_onorder_v_ecom real,
    dc_onorder_c_ecom real,
    dc_finrev_ecom real,
    dc_publish_ecom real,
    dc_last_pub_u_ecom real,
    dc_last_pub_ecom timestamp without time zone
);


--
-- Name: deleteme_trd_p_itemprice_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_p_itemprice_20251028 (
    product text,
    location text,
    "time" text,
    addoff real,
    eo real,
    eff_aur real,
    department text,
    event text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    excl_discount_pct real,
    addoff_ecom real,
    addoff_store real
);


--
-- Name: deleteme_trd_specimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_specimages (
    product text,
    img text
);


--
-- Name: deleteme_trd_specimages_fixed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_specimages_fixed (
    product text,
    img text
);


--
-- Name: deleteme_trd_update_floorsets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_update_floorsets (
    dept text,
    old_floorset text,
    new_floorset text
);


--
-- Name: deleteme_trd_v_memberbasedvalidvalues_2025_03_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_trd_v_memberbasedvalidvalues_2025_03_29 (
    attributeid text,
    membertie text,
    attributekey text,
    attributevalue text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_ttrd_a_assortment_20251028; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_ttrd_a_assortment_20251028 (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: deleteme_update_images_existing_202050828; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_update_images_existing_202050828 (
    indx integer,
    product text,
    img text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_update_images_step1_202050828; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_update_images_step1_202050828 (
    product text,
    member_id text,
    url text,
    final_img text
);


--
-- Name: deleteme_update_price_bands_20240331; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_update_price_bands_20240331 (
    product text,
    cad_ticket_price real,
    cc_price_band text,
    new_price_band text
);


--
-- Name: dept_plan_item_conversion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_item_conversion (
    product text,
    location text,
    department text
);


--
-- Name: dept_plan_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items (
    product text,
    location text,
    department text
);


--
-- Name: dept_plan_items_active; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items_active (
    product text,
    location text,
    department text
);


--
-- Name: dept_plan_items_daily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items_daily (
    product text,
    location text,
    department text
);


--
-- Name: dept_plan_items_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items_temp (
    product text,
    location text,
    department text
);


--
-- Name: dev_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dev_session (
    session_id text NOT NULL,
    user_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    alive_at timestamp with time zone DEFAULT now() NOT NULL,
    target_user_id text
);


--
-- Name: duplicate_sizes_sup3663; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.duplicate_sizes_sup3663 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text,
    status text
);


--
-- Name: failed_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_items (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: failed_items_20240925; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_items_20240925 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: failed_items_20250404; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_items_20250404 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: failed_items_20250511; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_items_20250511 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: failed_items_20250601; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_items_20250601 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    key text NOT NULL,
    user_id text NOT NULL,
    module text NOT NULL,
    favorite_name text NOT NULL,
    version integer NOT NULL,
    json_blob json NOT NULL,
    active boolean
);


--
-- Name: fcstable_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fcstable_product (
    product text
);


--
-- Name: flrset_hierarchy_prep; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flrset_hierarchy_prep (
    product text,
    floorset text,
    superset text,
    year text,
    min_rcptstart text,
    prev_flrset character varying(100),
    next_flrset character varying(100),
    prev_superset character varying(100),
    next_superset character varying(100),
    indx bigint,
    floorset_name text,
    superset_name text
);


--
-- Name: from_torrid_department_default_for_flrset_merge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.from_torrid_department_default_for_flrset_merge (
    department character varying(50) NOT NULL,
    default_sales_rank_store integer,
    default_sales_rank_ecom integer,
    default_store_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    size_min integer,
    size_min_weeks integer,
    receipt_interval integer,
    return_rate_stores numeric(5,4),
    return_rate_ecom numeric(5,4),
    cross_channel_return_rate_ecom numeric(5,4),
    order_multiple_uom integer,
    default_md_strategy character varying(100),
    lead_time_default integer,
    default_discount_pct numeric(5,4)
);


--
-- Name: from_torrid_department_flrset_and_default_merged; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.from_torrid_department_flrset_and_default_merged (
    product character varying(50),
    department character varying(50),
    dept_name character varying(100),
    superset_id character varying(50),
    superset_name character varying(100),
    floorset_id character varying(50),
    floorset_name character varying(100),
    initialrcptwk character varying(20),
    rcptstart character varying(20),
    rcptend character varying(20),
    slsstart character varying(20),
    slsend character varying(20),
    weeks_at_fp integer,
    markdown_week character varying(20),
    exit_week character varying(20),
    ly_rcptstart character varying(20),
    ly_rcptend character varying(20),
    ly_slsstart character varying(20),
    ly_slsend character varying(20),
    ap_start character varying(20),
    ap_end character varying(20),
    planned_sell_down_week character varying(20),
    floorset_uda character varying(100),
    ly_floorset_uda character varying(100),
    default_sales_rank_store integer,
    default_sales_rank_ecom integer,
    default_store_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    size_min integer,
    size_min_weeks integer,
    receipt_interval integer,
    return_rate_stores numeric(5,4),
    return_rate_ecom numeric(5,4),
    cross_channel_return_rate_ecom numeric(5,4),
    order_multiple_uom integer,
    default_md_strategy character varying(100),
    lead_time_default integer,
    default_discount_pct numeric(5,4)
);


--
-- Name: from_torrid_department_flrset_default_for_flrset_merge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.from_torrid_department_flrset_default_for_flrset_merge (
    dept_id character varying(50),
    dept_name character varying(100),
    superset_id character varying(50),
    superset_name character varying(100),
    floorset_id character varying(50) NOT NULL,
    floorset_name character varying(100),
    initialrcptwk character varying(20),
    rcptstart character varying(20),
    rcptend character varying(20),
    slsstart character varying(20),
    slsend character varying(20),
    weeks_at_fp integer,
    markdown_week character varying(20),
    exit_week character varying(20),
    ly_rcptstart character varying(20),
    ly_rcptend character varying(20),
    ly_slsstart character varying(20),
    ly_slsend character varying(20),
    ap_start character varying(20),
    ap_end character varying(20),
    planned_sell_down_week character varying(20),
    floorset_uda character varying(100),
    ly_floorset_uda character varying(100)
);


--
-- Name: mark_plan_queue_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mark_plan_queue_temp (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: md_strategy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.md_strategy (
    mdstrategy text,
    seq smallint,
    md_disc real,
    factor real,
    eventdate date
);


--
-- Name: missed_planning_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missed_planning_delete_me (
    product text
);


--
-- Name: missing_from_plan_1029_1016; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_plan_1029_1016 (
    product text
);


--
-- Name: missing_from_plan_1029_1016_with_dept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_plan_1029_1016_with_dept (
    product text,
    department text,
    style text
);


--
-- Name: missing_from_plan_1029_1016_with_dept_sca; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_plan_1029_1016_with_dept_sca (
    product text,
    department text,
    style text,
    exitdate text,
    ccrangecode text
);


--
-- Name: missing_from_plan_1029_1016_with_dept_sca_sizerange; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missing_from_plan_1029_1016_with_dept_sca_sizerange (
    product text,
    department text,
    style text,
    exitdate text,
    ccrangecode text,
    sty_size_range text,
    is_valid integer
);


--
-- Name: nov18_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nov18_products (
    product text
);


--
-- Name: trd_d_time; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_time (
    id text NOT NULL,
    name text,
    description text,
    levelid text,
    prev text,
    next text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_dptflrsetattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_dptflrsetattributes (
    indx integer NOT NULL,
    product text,
    "time" text,
    floorset_name text,
    dept_name text,
    superset_id text,
    superset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    weeks_at_fp text,
    markdown_week text,
    exit_week text,
    ly_rcptstart text,
    ly_rcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_planned_sell_down_week text,
    floorset_uda text,
    ly_floorset_uda text,
    default_slsrnk_store real,
    default_slsrnk_ecom real,
    default_store_vol_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_retpct_str real,
    default_retpct_ecom real,
    default_crosschannel_retpct_ecom real,
    default_ccordermultiple_uom integer,
    default_ccmdstrategy text,
    default_lead_time integer,
    default_ccdiscountpct real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    prepack_pct_default real,
    override_fringe_indicator text
);


--
-- Name: perf_assortperiod_week; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.perf_assortperiod_week AS
 SELECT a.product,
    a."time",
    b.id AS week,
    b.indx AS week_indx
   FROM ( SELECT trd_ma_dptflrsetattributes.product,
            trd_ma_dptflrsetattributes."time",
            trd_ma_dptflrsetattributes.rcptstart,
            trd_ma_dptflrsetattributes.rcptend
           FROM public.trd_ma_dptflrsetattributes) a,
    public.trd_d_time b
  WHERE ((b.levelid = ('week'::character varying(4))::text) AND (b.id >= a.rcptstart) AND (b.id <= a.rcptend));


--
-- Name: pivot_clean_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pivot_clean_session (
    session_id text NOT NULL,
    created timestamp with time zone NOT NULL,
    live timestamp with time zone NOT NULL,
    finished timestamp with time zone
);


--
-- Name: pivot_execution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pivot_execution (
    pivot_session_id text NOT NULL,
    user_id text NOT NULL,
    scope_id uuid NOT NULL,
    app_name text,
    defn_id text NOT NULL,
    agg_by text,
    history_start text,
    history_end text,
    sales_start text,
    sales_end text,
    sort_by text,
    flow_status text,
    top_members text,
    nest_data boolean NOT NULL,
    ignore_ancestors boolean NOT NULL,
    ignore_agg_by_params boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pivot_tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pivot_tables (
    user_id text NOT NULL,
    session_id text NOT NULL,
    table_name text NOT NULL,
    approx_create_time timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: plan_data_export; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_data_export (
    id integer,
    product text,
    location text,
    prodlife text,
    "time" text,
    version text,
    avg_str_inv_c double precision,
    avg_str_sls_c double precision,
    avg_str_inv_r double precision,
    avg_str_sls_r double precision,
    avg_str_inv_u double precision,
    avg_str_sls_u double precision,
    avg_str_rec_c double precision,
    avg_str_rec_r double precision,
    avg_str_rec_u double precision,
    avg_wk_sls_c double precision,
    avg_wk_inv_c double precision,
    avg_wk_inv_r double precision,
    avg_wk_inv_u double precision,
    avg_wk_sls_r double precision,
    avg_wk_sls_u double precision,
    perm_md_c double precision,
    perm_md_inv_r_csp double precision,
    perm_md_move_inv_u double precision,
    boh_auc double precision,
    boh_aur double precision,
    boh_c double precision,
    eoh_c double precision,
    eoh_c_computed double precision,
    eoh_c_adj double precision,
    inv_adjustment_c double precision,
    mos_c double precision,
    net_dc_xfer_c double precision,
    on_order_c double precision,
    rec_c double precision,
    shrink_c double precision,
    net_sls_c double precision,
    turn_c double precision,
    stk_sls_c double precision,
    eoh_auc double precision,
    eoh_aur double precision,
    net_sls_margin_pct double precision,
    net_sls_margin_r double precision,
    gafs_auc double precision,
    gafs_aur double precision,
    gafs_c double precision,
    gafs_mmu double precision,
    gafs_r double precision,
    gafs_u double precision,
    gmroi double precision,
    inv_adjustment_auc double precision,
    inv_adjustment_aur double precision,
    inv_adjustment_mmu double precision,
    mos_auc double precision,
    mos_aur double precision,
    mos_mmu double precision,
    net_dc_xfer_auc double precision,
    net_dc_xfer_aur double precision,
    net_dc_xfer_mmu double precision,
    pos_disc_pct double precision,
    pos_md_r double precision,
    owned_markup_pct double precision,
    on_order_auc double precision,
    on_order_aur double precision,
    on_order_imu double precision,
    perm_md_pct_off double precision,
    perm_md_r double precision,
    perm_md_inv_auc_edit double precision,
    perm_md_inv_c_edit double precision,
    perm_md_inv_r_at_new_aur_edit double precision,
    perm_md_post_mmu double precision,
    perm_md_previous_mmu double precision,
    perm_md_previous_aur double precision,
    perm_md_inv_u_edit double precision,
    perm_md_new_aur_edit double precision,
    boh_r double precision,
    eoh_r double precision,
    eoh_r_computed double precision,
    eoh_r_adj double precision,
    inv_adjustment_r double precision,
    mos_r double precision,
    net_dc_xfer_r double precision,
    on_order_r double precision,
    rec_r double precision,
    net_sls_r double precision,
    shrink_r double precision,
    rec_auc double precision,
    rec_aur double precision,
    rec_imu double precision,
    net_sls_aut double precision,
    net_sls_auc double precision,
    net_sls_aur double precision,
    shrink_c_pct double precision,
    shrink_auc double precision,
    shrink_aur double precision,
    storecount double precision,
    committed_auc double precision,
    committed_aur double precision,
    committed_imu double precision,
    committed_c double precision,
    committed_r double precision,
    committed_u double precision,
    boh_u double precision,
    eoh_u double precision,
    eoh_u_computed double precision,
    eoh_u_adj double precision,
    inv_adjustment_u double precision,
    mos_u double precision,
    net_dc_xfer_u double precision,
    on_order_u double precision,
    rec_u double precision,
    net_sls_u double precision,
    shrink_u double precision,
    sell_thru_pct double precision,
    turn_u double precision,
    stk_sls_u double precision
);


--
-- Name: plan_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue (
    jobid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    initiator text NOT NULL,
    initiated_at timestamp with time zone DEFAULT now() NOT NULL,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    instance_id text
);


--
-- Name: plan_queue_bk_20240922; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_bk_20240922 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_queue_bk_20250103; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_bk_20250103 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_queue_bkp_11112024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_bkp_11112024 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_queue_bkp_1227; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_bkp_1227 (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_queue_fails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_fails (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_queue_last_run; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_last_run (
    jobid uuid,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer
);


--
-- Name: plan_status; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.plan_status AS
 SELECT plan_queue.jobid,
    plan_queue.product,
    plan_queue.location,
    plan_queue.initiator,
        CASE
            WHEN (plan_queue.completed IS NOT NULL) THEN
            CASE
                WHEN (plan_queue.error IS NOT NULL) THEN 'FAILED'::text
                ELSE 'COMPLETED'::text
            END
            WHEN (plan_queue.processing IS NOT NULL) THEN 'PROCESSING'::text
            WHEN (plan_queue.queued IS NOT NULL) THEN 'PENDING'::text
            ELSE 'STALLED'::text
        END AS status
   FROM public.plan_queue;


--
-- Name: pre_12062026_p_stylecolor_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pre_12062026_p_stylecolor_worklist (
    product text,
    "time" text,
    location text,
    worklist_id text,
    sclr_wrk_auto_allocation text,
    sclr_wrk_alloc_rule text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    in_worklist real,
    sclr_wrk_prepack_holdback real,
    sclr_wrk_prepack_transfer real,
    sclr_wrk_approved real,
    sclr_wrk_released real,
    sclr_wrk_status real
);


--
-- Name: prev_next_flrset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_next_flrset (
    product text,
    floorset text,
    min_rcptstart text,
    rn bigint,
    prev character varying(100),
    next character varying(100)
);


--
-- Name: prev_next_superset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_next_superset (
    product text,
    superset text,
    min_rcptstart text,
    rn bigint,
    prev character varying(100),
    next character varying(100)
);


--
-- Name: prev_trd_ma_departmentquarter_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_ma_departmentquarter_attributes (
    product text,
    "time" text,
    dq_clustering_level text,
    dq_include_vendors boolean,
    dq_enum_vendors_cutoff boolean,
    dq_clustering_prefix text,
    dq_num_clusters text,
    dq_clustering_type text,
    dq_ecom_separate boolean,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    dq_cluster_group boolean,
    dq_metric_1 text,
    dq_metric_2 text
);


--
-- Name: prev_trd_p_strategy_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_strategy_params (
    product text,
    location text,
    floorset_uda text,
    ly_floorset text,
    lly_floorset text,
    quarter_start text,
    target_sales_start text,
    target_sales_end text,
    target_receipt_start text,
    target_receipt_end text,
    ly_sales_start text,
    ly_sales_end text,
    ly_receipt_start text,
    ly_receipt_end text,
    lly_sales_start text,
    lly_sales_end text,
    lly_receipt_start text,
    lly_receipt_end text,
    rec_magnitude integer,
    ref_avg_cc_count text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    apply_targets_to_plan integer
);


--
-- Name: prev_trd_p_stylecolor_channel_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolor_channel_alloc_params (
    product text,
    location text,
    sclr_def_alloc_sizeattr text[],
    sclr_def_presmin real,
    sclr_def_presmin_weeks real,
    sclr_def_fringe_flag real,
    sclr_def_target_fwoc_override real,
    sclr_def_service_level real,
    sclr_def_alloc_min real,
    sclr_def_alloc_max real,
    sclr_def_size_eligibility integer[],
    sclr_def_size_min_by_size_override integer[],
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: prev_trd_p_stylecolor_store_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolor_store_alloc_params (
    product text,
    location text,
    sclr_loc_eligibility integer,
    sclr_loc_tgt_fp_st_pct real,
    sclr_loc_alloc_sizeattr text[],
    sclr_loc_presmin real,
    sclr_loc_presmin_weeks real,
    sclr_loc_target_fwoc_override real,
    sclr_loc_service_level real,
    sclr_loc_alloc_min real,
    sclr_loc_alloc_max real,
    sclr_loc_size_eligibility integer[],
    sclr_loc_size_min_by_size_override integer[],
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    sclr_loc_fringe_flag real,
    sclr_loc_alloc_sizeattr_for_size_min text[]
);


--
-- Name: prev_trd_p_stylecolor_store_eligibility; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolor_store_eligibility (
    product text,
    location text,
    sclr_str_eligibility integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: prev_trd_p_stylecolor_store_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolor_store_worklist (
    product text,
    "time" text,
    location text,
    worklist_id text,
    sclr_loc_wrk_alloc_sclr_qty real,
    sclr_loc_wrk_alloc_size_qty integer[],
    sclr_loc_wrk_alloc_sizeattr text[],
    sclr_loc_wrk_presmin real,
    sclr_loc_wrk_presmin_weeks real,
    sclr_loc_wrk_target_fwoc_override real,
    sclr_loc_wrk_service_level real,
    sclr_loc_wrk_alloc_min real,
    sclr_loc_wrk_alloc_max real,
    sclr_loc_wrk_size_eligibility integer[],
    sclr_loc_wrk_size_min_by_size_override integer[],
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by character varying,
    updated_at timestamp without time zone,
    updated_by character varying,
    record_state smallint,
    sclr_loc_wrk_fringe_flag real,
    sclr_loc_wrk_size_user_override integer[],
    sclr_loc_alloc_sizeattr_for_size_override text[]
);


--
-- Name: prev_trd_p_stylecolor_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolor_worklist (
    product text,
    "time" text,
    location text,
    worklist_id text,
    sclr_wrk_auto_allocation text,
    sclr_wrk_alloc_rule text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    in_worklist real,
    sclr_wrk_prepack_holdback real,
    sclr_wrk_prepack_transfer real,
    sclr_wrk_approved real,
    sclr_wrk_released real,
    sclr_wrk_status real
);


--
-- Name: prev_trd_p_stylecolorsize_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_trd_p_stylecolorsize_worklist (
    product text,
    "time" text,
    location text,
    worklist_id text,
    sz_wrk_holdback real,
    sz_wrk_ecomm_reserve real,
    sz_wrk_stores_reserve real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    sz_wrk_loose_holdback real,
    sz_wrk_loose_transfer real
);


--
-- Name: prev_user_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prev_user_worklist (
    user_id text,
    product text,
    type text,
    updated_at timestamp without time zone,
    name text
);


--
-- Name: pricing_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricing_table (
    t_expression text,
    v_cccurp real
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    product text
);


--
-- Name: products_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products_delete_me (
    product text
);


--
-- Name: rerun_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rerun_temp (
    product text,
    location text
);


--
-- Name: rerun_temp_valid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rerun_temp_valid (
    product text,
    location text
);


--
-- Name: s5_actual_initrcptwk_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_actual_initrcptwk_archives (
    product text,
    initrcptwk text,
    actual_initrcptwk text,
    updated_at timestamp with time zone
);


--
-- Name: s5_actual_initrcptwk_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_actual_initrcptwk_update (
    product text,
    actual_initrcptwk text
);


--
-- Name: s5_analytics_inseason_sls_rnk_transposed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_analytics_inseason_sls_rnk_transposed (
    stylecolor text,
    act_slsrnk_store real,
    act_slsrnk_ecom real,
    act_aps_store real,
    act_aps_ecom real,
    act_aps_mult_adj_store real,
    act_aps_mult_adj_ecom real
);


--
-- Name: s5_profile_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_profile_master (
    size_range_class text,
    class text,
    sub_size_range text,
    profile_id text,
    size_id text,
    size_desc text,
    interim_prof text
);


--
-- Name: s5_tunableparams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_tunableparams (
    paramid text NOT NULL,
    intvalue integer,
    stringvalue text
);


--
-- Name: scope; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scope (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_name text NOT NULL,
    user_id text NOT NULL,
    params json NOT NULL,
    filter_conditions json DEFAULT '{"filterConditions": []}'::json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: seq_area; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_area
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_district; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_district
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_region; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_region
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_sellingchannel; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_sellingchannel
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seq_store; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_store
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: size_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.size_ids (
    size_name text,
    size_id text
);


--
-- Name: style_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.style_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stylecolor_sizerange_size_master_with_existing_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stylecolor_sizerange_size_master_with_existing_products (
    stylecolor text,
    sty_size_range text,
    sizeattribute text,
    stylecolorsize text,
    new_product text,
    missing_key integer,
    stylecolor_name text
);


--
-- Name: sync_outbound_dataqueue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_outbound_dataqueue (
    product text NOT NULL,
    "time" text NOT NULL,
    publish_type text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP)
);


--
-- Name: temp1_trd_c_week1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp1_trd_c_week1 (
    week text,
    week_minus_1 text
);


--
-- Name: temp1_trd_c_week4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp1_trd_c_week4 (
    week text,
    week_minus_4 text
);


--
-- Name: temp_corpdisc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_corpdisc (
    brand text NOT NULL,
    product text NOT NULL,
    prodlife text NOT NULL,
    "time" text NOT NULL,
    corpaddoff real DEFAULT 0.0,
    corpexcl real DEFAULT 0.0,
    comments text
);


--
-- Name: temp_failed_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_failed_items (
    jobid text,
    product text,
    location text,
    initiator text,
    initiated_at timestamp without time zone,
    queued timestamp without time zone,
    processing timestamp without time zone,
    completed timestamp without time zone,
    error text,
    updated_at timestamp without time zone,
    priority text
);


--
-- Name: tmp_trd_l_dependencylookup_20241002; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_trd_l_dependencylookup_20241002 (
    lookup_id text,
    lookup_value text,
    target_id text,
    target_value text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    index text
);


--
-- Name: tmp_trd_v_memberbasedvalidvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_trd_v_memberbasedvalidvalues (
    attributeid text,
    membertie text,
    attributekey text,
    attributevalue text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_a_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_a_assortment (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text DEFAULT 'plan'::text NOT NULL,
    isfunded integer DEFAULT 1,
    store_count integer DEFAULT 0,
    propagate_ranging integer DEFAULT 1,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[],
    is_sclr_flrset_locked text
);


--
-- Name: trd_a_assortment_43515774_black; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_a_assortment_43515774_black (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: trd_a_assortment_bk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_a_assortment_bk (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: trd_a_assortment_bk_20240922; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_a_assortment_bk_20240922 (
    product text,
    location text,
    "time" text,
    style text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    isfunded integer,
    store_count integer,
    propagate_ranging integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    str_grade_or text[],
    str_store_climate_or text[],
    str_capacity_or text[],
    str_store_banner_or text[],
    str_geo_region_or text[],
    str_hazmat_or text[]
);


--
-- Name: trd_a_assortment_storecount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_a_assortment_storecount (
    product text,
    "time" text,
    location text,
    str_grade text[],
    str_store_climate text[],
    str_capacity text[],
    str_store_banner text[],
    str_geo_region text[],
    str_hazmat text[],
    ssg text[],
    department text,
    store_count integer
);


--
-- Name: trd_an_price_storecount_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_an_price_storecount_info (
    product text NOT NULL,
    channel text NOT NULL,
    "time" text NOT NULL,
    selling_channel text NOT NULL,
    isfunded integer,
    store_count integer,
    in_season_flag text,
    dbt_wk_date text,
    last_rcpt_wk_date text,
    erlstmkdnwk_date text,
    exitdate_date text,
    weekdate text,
    price_status text,
    seq bigint,
    ccticketprice double precision,
    curp real,
    selling_price real,
    expressed_aur real,
    corpexcl real,
    addoff real,
    corpaddoff real,
    v_a real,
    v_b real,
    ccdiscountpct real,
    flow_flag text
);


--
-- Name: trd_authorization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_authorization (
    tenantid text,
    roleid text NOT NULL,
    authid text NOT NULL,
    access text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_c_conversion_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_file (
    floorset_code text,
    department_id text,
    class_id text,
    subclass_id text,
    style_id text,
    style_color_id text,
    style_color_desc text,
    ticket_price real,
    cost real,
    default_disc real,
    debut_week text,
    md_week text,
    exit_week text,
    auto_roll_forward boolean,
    planned_sell_down_wk text,
    md_strategy text,
    store_vol_grade text,
    store_climate text,
    store_capacity text,
    store_banner text,
    store_region text,
    store_hazmat text,
    ssg text,
    size_range text,
    valid_sizes_stores text,
    valid_sizes_ecom text,
    size_min real,
    size_min_weeks real,
    pre_ssn_rating_strs real,
    pre_ssn_rating_ecom real,
    receipt_interval real,
    return_rate_strs real,
    return_rate_ecom real,
    cross_channel_ret_rate real,
    order_min real,
    order_multiple real,
    lead_time_default real,
    irw_debut_offset real
);


--
-- Name: trd_c_conversion_file_bk_20240922; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_file_bk_20240922 (
    floorset_code text,
    department_id text,
    class_id text,
    subclass_id text,
    style_id text,
    style_color_id text,
    style_color_desc text,
    ticket_price real,
    cost real,
    default_disc real,
    debut_week text,
    md_week text,
    exit_week text,
    auto_roll_forward boolean,
    planned_sell_down_wk text,
    md_strategy text,
    store_vol_grade text,
    store_climate text,
    store_capacity text,
    store_banner text,
    store_region text,
    store_hazmat text,
    ssg text,
    size_range text,
    valid_sizes_stores text,
    valid_sizes_ecom text,
    size_min real,
    size_min_weeks real,
    pre_ssn_rating_strs real,
    pre_ssn_rating_ecom real,
    receipt_interval real,
    return_rate_strs real,
    return_rate_ecom real,
    cross_channel_ret_rate real,
    order_min real,
    order_multiple real,
    irw_debut_offset real
);


--
-- Name: trd_c_conversion_file_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_file_issues (
    floorset_code text,
    department_id text,
    class_id text,
    subclass_id text,
    style_id text,
    style_color_id text,
    style_color_desc text,
    ticket_price real,
    cost real,
    default_disc real,
    debut_week text,
    md_week text,
    exit_week text,
    auto_roll_forward boolean,
    planned_sell_down_wk text,
    md_strategy text,
    store_vol_grade text,
    store_climate text,
    store_capacity text,
    store_banner text,
    store_region text,
    store_hazmat text,
    ssg text,
    size_range text,
    valid_sizes_stores text,
    valid_sizes_ecom text,
    size_min real,
    size_min_weeks real,
    pre_ssn_rating_strs real,
    pre_ssn_rating_ecom real,
    receipt_interval real,
    return_rate_strs real,
    return_rate_ecom real,
    cross_channel_ret_rate real,
    order_min real,
    order_multiple real,
    lead_time_default real,
    irw_debut_offset real,
    issue_reason text
);


--
-- Name: trd_c_conversion_file_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_file_lifecycle (
    floorset_code text,
    department_id text,
    class_id text,
    subclass_id text,
    style_id text,
    style_color_id text,
    style_color_desc text,
    ticket_price real,
    cost real,
    default_disc real,
    debut_week text,
    md_week text,
    exit_week text,
    auto_roll_forward boolean,
    planned_sell_down_wk text,
    md_strategy text,
    store_vol_grade text,
    store_climate text,
    store_capacity text,
    store_banner text,
    store_region text,
    store_hazmat text,
    ssg text,
    size_range text,
    valid_sizes_stores text,
    valid_sizes_ecom text,
    size_min real,
    size_min_weeks real,
    pre_ssn_rating_strs real,
    pre_ssn_rating_ecom real,
    receipt_interval real,
    return_rate_strs real,
    return_rate_ecom real,
    cross_channel_ret_rate real,
    order_min real,
    order_multiple real,
    lead_time_default real,
    irw_debut_offset real,
    irw text,
    initrcptwk text,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    style text,
    subclass text,
    class text,
    department text
);


--
-- Name: trd_c_conversion_history_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_history_lifecycle (
    product text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    wac real,
    validsizes text[],
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    style text,
    subclass text,
    class text,
    department text,
    sty_size_range text
);


--
-- Name: trd_c_conversion_history_stylecolorchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_history_stylecolorchannelattributes (
    product text,
    location text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too integer,
    mkdnwks integer,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    ccmdstrategy text,
    slsrnk_store integer,
    slsrnk_ecom integer,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store numeric,
    cc_return_u_pct_ecom numeric,
    cc_return_u_pct_cross numeric,
    cc_ordermultiple integer,
    cc_ordermin integer,
    ccticketpricechannel real,
    cc_imupct real,
    cc_discount_pct numeric,
    cc_plan_cost real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text
);


--
-- Name: trd_c_conversion_history_validsizes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_conversion_history_validsizes (
    product text,
    valid_sizes text
);


--
-- Name: trd_c_cutover_prep_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_c_cutover_prep_history (
    product text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    wac real,
    validsizes text[]
);


--
-- Name: trd_p_approvedclusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_approvedclusters (
    product text NOT NULL,
    "time" text NOT NULL,
    cluster_id text NOT NULL,
    clustering_status real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_serviceparams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_serviceparams (
    id text,
    type text,
    value text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_clustering_needs_attention; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.trd_clustering_needs_attention AS
 SELECT aa.plannable_dept,
    aa.plannable_class,
    aa.plannable_time,
    aa.cluster_id,
    aa.current_cluster_dept,
    aa.current_cluster_class,
    aa.current_cluster_time,
    aa.clustering_status,
    aa.cluster_issue
   FROM ( WITH plannable AS (
                 SELECT DISTINCT b.ancestor3 AS plannable_dept,
                    b.ancestor2 AS plannable_class,
                    c."time" AS plannable_time
                   FROM ((public.trd_ma_stylecolorchannelattributes a
                     JOIN public.trd_h_prodstd b ON ((a.product = b.id)))
                     JOIN ( SELECT DISTINCT trd_p_approvedclusters."time"
                           FROM public.trd_p_approvedclusters) c ON ((1 = 1)))
                  WHERE (((array_length(a.cc_validsizes_store, 1) IS NOT NULL) OR (array_length(a.cc_validsizes_ecom, 1) IS NOT NULL)) AND (a.record_state = 0) AND (a.exitdate > ( SELECT trd_serviceparams.value
                           FROM public.trd_serviceparams
                          WHERE (trd_serviceparams.id = 'plan_current'::text))))
                ), current_clusters AS (
                 SELECT DISTINCT trd_p_approvedclusters.product AS current_cluster_dept,
                        CASE
                            WHEN (trd_p_approvedclusters.cluster_id ~~ '%-department-class-%'::text) THEN "right"(trd_p_approvedclusters.cluster_id, 7)
                            ELSE NULL::text
                        END AS current_cluster_class,
                    trd_p_approvedclusters."time" AS current_cluster_time,
                    trd_p_approvedclusters.cluster_id,
                        CASE
                            WHEN (trd_p_approvedclusters.clustering_status = '1'::real) THEN 'APPROVED'::text
                            ELSE 'NOT APPROVED'::text
                        END AS clustering_status
                   FROM public.trd_p_approvedclusters
                )
         SELECT x.plannable_dept,
            x.plannable_class,
            x.plannable_time,
            y.cluster_id,
            y.current_cluster_dept,
            y.current_cluster_class,
            y.current_cluster_time,
            y.clustering_status,
                CASE
                    WHEN (y.current_cluster_time IS NULL) THEN 'CLUSTER IS MISSING'::text
                    WHEN (y.clustering_status = 'NOT APPROVED'::text) THEN 'CLUSTER NOT APPROVED'::text
                    ELSE NULL::text
                END AS cluster_issue
           FROM (plannable x
             LEFT JOIN current_clusters y ON (((x.plannable_dept = y.current_cluster_dept) AND (x.plannable_class = y.current_cluster_class) AND (x.plannable_time = y.current_cluster_time))))) aa
  WHERE (aa.cluster_issue IS NOT NULL)
  ORDER BY aa.plannable_dept, aa.plannable_time;


--
-- Name: trd_corpdisc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_corpdisc (
    department text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    prodlife text NOT NULL,
    corpaddoff real DEFAULT 0.0,
    corpexcl real DEFAULT 0.0,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    corpexcl_ecom real
);


--
-- Name: trd_corpdisc_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_corpdisc_backup (
    department text,
    product text,
    location text,
    "time" text,
    prodlife text,
    corpaddoff real,
    corpexcl real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    corpexcl_ecom real
);


--
-- Name: trd_corpdisc_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_corpdisc_temp (
    department text,
    product text,
    "time" text,
    corpaddoff real,
    corpexcl_ecom real,
    corpexcl real
);


--
-- Name: trd_d_cluster; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_cluster (
    id text NOT NULL,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_d_cluster_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_cluster_delete_me (
    id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_location (
    id text NOT NULL,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_d_prodlife; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_prodlife (
    id text NOT NULL,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_d_prodlife_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_prodlife_delete_me (
    id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_product_backup_2025_04_24; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product_backup_2025_04_24 (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_product_bk20241107; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product_bk20241107 (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_product_bk_sup_3663; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product_bk_sup_3663 (
    id text,
    client_id text,
    name text,
    description text,
    levelid text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_product_for_stylecolorsize_missing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product_for_stylecolorsize_missing (
    new_product text,
    name text,
    description text,
    levelid text,
    indx bigint,
    stylecolor text
);


--
-- Name: trd_d_product_mock_sup3663; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_product_mock_sup3663 (
    id text,
    client_id text,
    name text,
    description text
);


--
-- Name: trd_d_time_bk_20250928; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_time_bk_20250928 (
    id text,
    name text,
    description text,
    levelid text,
    prev text,
    next text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_time_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_time_bkp (
    id text,
    name text,
    description text,
    levelid text,
    prev text,
    next text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_time_bkp_08172024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_time_bkp_08172024 (
    id text,
    name text,
    description text,
    levelid text,
    prev text,
    next text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_d_time_new_11102024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_d_time_new_11102024 (
    id text,
    name text,
    description text,
    levelid text,
    prev text,
    next text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_designimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_designimages (
    product text,
    img text
);


--
-- Name: trd_eohdata_stylecolor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_eohdata_stylecolor (
    product text NOT NULL,
    channel text,
    eohu real
);


--
-- Name: trd_h_timeflrset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_for_tgt_flrset_hier; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.trd_for_tgt_flrset_hier AS
 SELECT a.id,
    a.indx,
    b.ancestor0 AS superset,
    b.ancestor1 AS fiscal_year,
    (now())::timestamp(0) without time zone AS updated_at
   FROM public.trd_d_time a,
    public.trd_h_timeflrset b
  WHERE ((a.levelid = 'floorset'::text) AND (a.id = b.id));


--
-- Name: trd_h_clusterstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_clusterstd (
    id text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_h_locdc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_locdc (
    id text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_h_locdcstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_locdcstd (
    id text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    ancestor0 text
);


--
-- Name: trd_h_locstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_locstd (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_h_prodlifestd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodlifestd (
    id text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_h_prodlifestd_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodlifestd_delete_me (
    id text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_backup_2025_04_24; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_backup_2025_04_24 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_bk2024010302; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_bk2024010302 (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_bk20241107; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_bk20241107 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_bk2025010302; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_bk2025010302 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_bk_sup_3663; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_bk_sup_3663 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_prodstd_for_stylecolorsize_missing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_for_stylecolorsize_missing (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text
);


--
-- Name: trd_h_prodstd_sup3311; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_prodstd_sup3311 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    ancestor7 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timeflrset_bk_20250928; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset_bk_20250928 (
    id text,
    ancestor0 text,
    ancestor1 text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timeflrset_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset_bkp (
    id text,
    ancestor0 text,
    ancestor1 text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timeflrset_bkp_08162024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset_bkp_08162024 (
    id text,
    ancestor0 text,
    ancestor1 text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timeflrset_new; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset_new (
    id text,
    ancestor0 text,
    ancestor1 text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timeflrset_new_11102024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timeflrset_new_11102024 (
    id text,
    ancestor0 text,
    ancestor1 text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_h_timestd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_h_timestd (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_in_bus_sizerange_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_in_bus_sizerange_mapping (
    size_range text,
    size_id text,
    size_desc text,
    sort_order integer,
    parent_size text,
    fringe_size_ind integer,
    now date DEFAULT (now())::date,
    index integer
);


--
-- Name: trd_in_prd_attrsku; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_in_prd_attrsku (
    item text,
    item_diff_2 text,
    item_diff_3 text,
    stylecolorsize_create_date text,
    size_attr_id text
);


--
-- Name: trd_in_prd_attrstyle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_in_prd_attrstyle (
    member_id character varying(500),
    knit_or_woven character varying(500),
    fabrication character varying(500),
    sleeve_length character varying(500),
    leg_opening character varying(500),
    brand character varying(500),
    body_style_silhouette character varying(500),
    occasion_usage character varying(500),
    detail character varying(500),
    finish_style character varying(500),
    private_label character varying(500),
    license character varying(500),
    license_vs_non_licensed character varying(500),
    hazmat_code character varying(500),
    prop_65_warning character varying(500),
    material_content character varying(500),
    item_type character varying(500),
    dwrise character varying(500),
    length character varying(500),
    neckline character varying(500),
    toeshape character varying(500),
    heel_height character varying(500),
    bottom_length character varying(500),
    v_360_smoothing character varying(500),
    franchise character varying(500),
    key_item character varying(500),
    single_vs_multi_pack character varying(500),
    ticket_type character varying(500),
    vpn character varying(500),
    size_range character varying(500),
    rms_stylecolor_create_date character varying(500),
    style_attribute_1 character varying(500),
    style_attribute_2 character varying(500),
    style_attribute_3 character varying(500),
    style_attribute_4 character varying(500),
    style_attribute_5 character varying(500),
    style_attribute_6 character varying(500),
    style_attribute_7 character varying(500),
    style_attribute_8 character varying(500)
);


--
-- Name: trd_l_dclookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_dclookup (
    channel text NOT NULL,
    dc text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_dependencylookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_dependencylookup (
    lookup_id text,
    lookup_value text DEFAULT 'Undefined'::text,
    target_id text,
    target_value text DEFAULT 'Undefined'::text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    index text
);


--
-- Name: trd_l_dependencylookup_mdstrategy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_dependencylookup_mdstrategy (
    lookup_id text,
    lookup_value text,
    target_id text,
    target_value text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    index text
);


--
-- Name: trd_l_dependencylookup_refresh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_dependencylookup_refresh (
    lookup_id text,
    lookup_value text,
    target_id text,
    target_value text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    index text
);


--
-- Name: trd_l_dependencylookup_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trd_l_dependencylookup_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trd_l_pricebandlookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_pricebandlookup (
    product text,
    ticket_price_min real,
    ticket_price_max real,
    price_band text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_priceeventlookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_priceeventlookup (
    product text NOT NULL,
    location text NOT NULL,
    ccpriceevent text DEFAULT ''::text NOT NULL,
    expression text DEFAULT ''::text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_sizeeligibility; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_sizeeligibility (
    department text,
    size_range_id text,
    size_eligibility_default_display_name text,
    size_member_id text,
    store_ineligible integer,
    web_ineligible integer,
    is_default integer
);


--
-- Name: trd_l_sizeeligibility_with_ccrangecode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_sizeeligibility_with_ccrangecode (
    department text,
    size_range_id text,
    size_eligibility_default_display_name text,
    size_member_id text,
    store_ineligible integer,
    web_ineligible integer,
    is_default integer,
    class text,
    ccrangecode text
);


--
-- Name: trd_l_ssglookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_ssglookup (
    product text NOT NULL,
    location text NOT NULL,
    ssg_id text DEFAULT ''::text NOT NULL,
    ssg_name text DEFAULT ''::text,
    stores text[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_storedclookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_storedclookup (
    store text NOT NULL,
    channel text NOT NULL,
    dc text NOT NULL,
    priority bigint NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_storelookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_storelookup (
    "time" text NOT NULL,
    product text NOT NULL,
    id text DEFAULT ''::text NOT NULL,
    value text DEFAULT ''::text NOT NULL,
    stores text[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_l_ticketprice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_l_ticketprice (
    product text,
    usd_ticket_price real,
    cad_ticket_price real,
    price_band text
);


--
-- Name: trd_location_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_location_attributes (
    id text,
    name text,
    description text,
    levelid text,
    latitude text,
    longitude text
);


--
-- Name: trd_ma_areaattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_areaattributes (
    indx integer,
    location text,
    area_latitude text,
    area_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_departmentalloc_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_departmentalloc_attributes (
    product text NOT NULL,
    alloc_rule_fair_share boolean DEFAULT false,
    alloc_rule_layered boolean DEFAULT true,
    alloc_rule_curr_oh boolean DEFAULT true,
    alloc_fcst_asst_plan boolean DEFAULT true,
    alloc_fcst_recalib boolean DEFAULT false,
    alloc_rule_adjust_dbt boolean DEFAULT true,
    alloc_rule_adjust_md boolean DEFAULT true,
    eventdate date DEFAULT (now())::date,
    version_id bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    created_by text,
    updated_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    updated_by text,
    record_state smallint DEFAULT 0,
    alloc_ecom_rsv_alloc_min boolean DEFAULT false,
    alloc_ecom_rsv_alloc_exact boolean DEFAULT true,
    alloc_aps_index boolean DEFAULT true,
    alloc_sales_index boolean DEFAULT false,
    alloc_blended_index boolean DEFAULT false,
    min_shortfall_policy boolean DEFAULT true,
    overflow_ok boolean DEFAULT true,
    round_robin_excess_global boolean DEFAULT true,
    treat_alloc_min_as_minorder boolean DEFAULT true,
    ecomm_need_as_moq boolean DEFAULT true,
    have_max_num_stores_with_packs boolean DEFAULT true,
    assign_pack_to_zero_ideal boolean DEFAULT true,
    allow_scaling boolean DEFAULT true,
    default_allocation_basis text DEFAULT 'Assortment'::text,
    apply_projected_trend boolean DEFAULT true
);


--
-- Name: trd_ma_departmentquarter_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_departmentquarter_attributes (
    product text NOT NULL,
    "time" text NOT NULL,
    dq_clustering_level text DEFAULT 'Class'::text,
    dq_include_vendors boolean DEFAULT false,
    dq_enum_vendors_cutoff boolean DEFAULT true,
    dq_clustering_prefix text DEFAULT 'TIER'::text,
    dq_num_clusters text DEFAULT '6'::text,
    dq_clustering_type text DEFAULT 'ML Basis'::text,
    dq_ecom_separate boolean DEFAULT true,
    eventdate date DEFAULT (now())::date,
    version_id bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    created_by text,
    updated_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    updated_by text,
    record_state smallint DEFAULT 0,
    dq_cluster_group boolean DEFAULT true,
    dq_metric_1 text DEFAULT 'FP Gross R$ Sales'::text,
    dq_metric_2 text DEFAULT 'FP Gross FGM $'::text
);


--
-- Name: trd_ma_departmentquarter_attributes_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_departmentquarter_attributes_bkp (
    product text,
    "time" text,
    dq_clustering_level text,
    dq_include_vendors boolean,
    dq_enum_vendors_cutoff boolean,
    dq_clustering_prefix text,
    dq_num_clusters text,
    dq_clustering_type text,
    dq_ecom_separate boolean,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    dq_cluster_group boolean,
    dq_metric_1 text,
    dq_metric_2 text
);


--
-- Name: trd_ma_departmentquarter_attributes_temporary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_departmentquarter_attributes_temporary (
    product text NOT NULL,
    "time" text NOT NULL,
    dq_clustering_level text DEFAULT 'Class'::text,
    dq_include_vendors boolean DEFAULT false,
    dq_enum_vendors_cutoff boolean DEFAULT true,
    dq_clustering_prefix text DEFAULT 'TIER'::text,
    dq_num_clusters text DEFAULT '6'::text,
    dq_clustering_type text DEFAULT 'ML Basis'::text,
    dq_ecom_separate boolean DEFAULT true,
    eventdate date DEFAULT (now())::date,
    version_id bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    created_by text,
    updated_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    updated_by text,
    record_state smallint DEFAULT 0,
    dq_cluster_group boolean DEFAULT true,
    dq_metric_1 text DEFAULT 'FP Gross R$ Sales'::text,
    dq_metric_2 text DEFAULT 'FP Gross FGM $'::text
);


--
-- Name: trd_ma_districtattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_districtattributes (
    indx integer,
    location text,
    district_latitude text,
    district_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_dptflrsetattributes_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_dptflrsetattributes_bkp (
    indx integer,
    product text,
    "time" text,
    floorset_name text,
    dept_name text,
    superset_id text,
    superset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    weeks_at_fp text,
    markdown_week text,
    exit_week text,
    ly_rcptstart text,
    ly_rcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_planned_sell_down_week text,
    floorset_uda text,
    ly_floorset_uda text,
    default_slsrnk_store real,
    default_slsrnk_ecom real,
    default_store_vol_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_retpct_str real,
    default_retpct_ecom real,
    default_crosschannel_retpct_ecom real,
    default_ccordermultiple_uom integer,
    default_ccmdstrategy text,
    default_lead_time integer,
    default_ccdiscountpct real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_ma_dptflrsetattributes_bkp_12212024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_dptflrsetattributes_bkp_12212024 (
    indx integer,
    product text,
    "time" text,
    floorset_name text,
    dept_name text,
    superset_id text,
    superset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    weeks_at_fp text,
    markdown_week text,
    exit_week text,
    ly_rcptstart text,
    ly_rcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_planned_sell_down_week text,
    floorset_uda text,
    ly_floorset_uda text,
    default_slsrnk_store real,
    default_slsrnk_ecom real,
    default_store_vol_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_retpct_str real,
    default_retpct_ecom real,
    default_crosschannel_retpct_ecom real,
    default_ccordermultiple_uom integer,
    default_ccmdstrategy text,
    default_lead_time integer,
    default_ccdiscountpct real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_ma_dptflrsetattributes_new_11102024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_dptflrsetattributes_new_11102024 (
    indx integer,
    product text,
    "time" text,
    floorset_name text,
    dept_name text,
    superset_id text,
    superset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    weeks_at_fp text,
    markdown_week text,
    exit_week text,
    ly_rcptstart text,
    ly_rcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_planned_sell_down_week text,
    floorset_uda text,
    ly_floorset_uda text,
    default_slsrnk_store real,
    default_slsrnk_ecom real,
    default_store_vol_grade text[],
    default_store_climate text[],
    default_store_capacity text[],
    default_store_banner text[],
    default_store_geo_region text[],
    default_store_hazmat text[],
    irw_debut_offset integer,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_retpct_str real,
    default_retpct_ecom real,
    default_crosschannel_retpct_ecom real,
    default_ccordermultiple_uom integer,
    default_ccmdstrategy text,
    default_lead_time integer,
    default_ccdiscountpct real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_ma_dptflrsetattributes_view_verification; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.trd_ma_dptflrsetattributes_view_verification AS
 SELECT a.product AS department,
    b.id AS "time",
    a."time" AS floorset
   FROM public.trd_ma_dptflrsetattributes a,
    public.trd_d_time b
  WHERE ((b.id >= a.rcptstart) AND (b.id <= a.rcptend) AND (a.rcptend >= ( SELECT trd_serviceparams.value
           FROM public.trd_serviceparams
          WHERE (trd_serviceparams.id = 'plan_current'::text))));


--
-- Name: trd_ma_imgattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_imgattributes (
    indx integer,
    product text NOT NULL,
    img text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_imgattributes_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_imgattributes_archive (
    indx integer,
    product text,
    img text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    sync_date timestamp(0) without time zone DEFAULT CURRENT_DATE
);


--
-- Name: trd_ma_regionattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_regionattributes (
    indx integer,
    location text,
    region_latitude text,
    region_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_scr_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_scr_temp (
    product text,
    ccrangecode text,
    cc_validsizes_store text[],
    cc_validsizes_ecom text[]
);


--
-- Name: trd_ma_scr_temp_removed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_scr_temp_removed (
    product text,
    ccrangecode text,
    cc_validsizes_store text[],
    cc_validsizes_ecom text[]
);


--
-- Name: trd_ma_sellingchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sellingchannelattributes (
    indx integer,
    location text,
    sellch_latitude text,
    sellch_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_sizeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes (
    product text NOT NULL,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer DEFAULT 1 NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    ccctylecolorsizecreatedate text
);


--
-- Name: trd_ma_sizeattributes_20250328; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes_20250328 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: trd_ma_sizeattributes_bk20241107; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes_bk20241107 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: trd_ma_sizeattributes_bk_20261015; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes_bk_20261015 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: trd_ma_sizeattributes_bk_sup_3663; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes_bk_sup_3663 (
    product text,
    parent_id text,
    item_diff_2 text,
    item_diff_3 text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    ccctylecolorsizecreatedate text
);


--
-- Name: trd_ma_sizeattributes_for_stylecolorsize_missing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_sizeattributes_for_stylecolorsize_missing (
    product text,
    parent_id text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: trd_ma_specstyleattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstyleattributes (
    vpn_vsn text,
    vpn_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    ticket_type text,
    knit_or_woven text,
    sleeve_length text,
    leg_opening text,
    brand text,
    license_vs_non_licensed text,
    hazmat_code text,
    prop_65_warning text,
    material_content text,
    dwrise text,
    v_length text,
    neckline text,
    toeshape text,
    heel_height text,
    bottom_length text,
    v_360_smoothing text,
    knit_fit text,
    design_style_status text,
    size_range text,
    spec_style_open1 text,
    spec_style_open2 text,
    spec_style_open3 text,
    spec_style_open4 text,
    spec_style_open5 text,
    spec_style_open6 text,
    spec_style_open7 text,
    spec_style_open8 text
);


--
-- Name: trd_ma_specstyleattributes_backup_2024_12_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstyleattributes_backup_2024_12_23 (
    vpn_vsn text,
    vpn_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    ticket_type text,
    knit_or_woven text,
    sleeve_length text,
    leg_opening text,
    brand text,
    license_vs_non_licensed text,
    hazmat_code text,
    prop_65_warning text,
    material_content text,
    dwrise text,
    v_length text,
    neckline text,
    toeshape text,
    heel_height text,
    bottom_length text,
    v_360_smoothing text,
    design_style_status text,
    size_range text,
    spec_style_open1 text,
    spec_style_open2 text,
    spec_style_open3 text,
    spec_style_open4 text,
    spec_style_open5 text,
    spec_style_open6 text,
    spec_style_open7 text,
    spec_style_open8 text
);


--
-- Name: trd_ma_specstyleattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstyleattributes_intraday (
    vpn_vsn text,
    vpn_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    ticket_type text,
    knit_or_woven text,
    sleeve_length text,
    leg_opening text,
    brand text,
    license_vs_non_licensed text,
    hazmat_code text,
    prop_65_warning text,
    material_content text,
    dwrise text,
    v_length text,
    neckline text,
    toeshape text,
    heel_height text,
    bottom_length text,
    v_360_smoothing text,
    knit_fit text,
    design_style_status text,
    size_range text,
    spec_style_open1 text,
    spec_style_open2 text,
    spec_style_open3 text,
    spec_style_open4 text,
    spec_style_open5 text,
    spec_style_open6 text,
    spec_style_open7 text,
    spec_style_open8 text
);


--
-- Name: trd_ma_specstylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstylecolorattributes (
    vpn_vsn text,
    vpn_description text,
    vpn_color text,
    vpn_color_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    item_diff_1 text,
    export_hts text,
    commercial_invoice_description text,
    dw_color_family text,
    origin_country_id text,
    country_of_sourcing text,
    country_of_manufacturing text,
    unit_cost real,
    freight text,
    agent_fee text,
    duty text,
    port text,
    ship_method text,
    lading_port text,
    hts text,
    factory text,
    po_supplier text,
    sub_brand text,
    design_stylecolor_status text,
    primary_supplier text,
    supp_cost real,
    art_code text,
    cc_material_content text,
    division text,
    group_id text,
    development_season text,
    delivery_season text,
    po_due_date text,
    pd_ndc_week text,
    additional_tariff text,
    design_notes text,
    pd_notes text,
    compliance_notes text,
    spec_stylecolor_open1 text,
    spec_stylecolor_open2 text,
    spec_stylecolor_open3 text,
    spec_stylecolor_open4 text,
    spec_stylecolor_open5 text,
    spec_stylecolor_open6 text,
    spec_stylecolor_open7 text,
    spec_stylecolor_open8 text,
    spec_stylecolor_open9 text,
    spec_stylecolor_open10 text,
    spec_stylecolor_open11 text,
    spec_stylecolor_open12 text
);


--
-- Name: trd_ma_specstylecolorattributes_backup_2024_12_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstylecolorattributes_backup_2024_12_23 (
    vpn_vsn text,
    vpn_description text,
    vpn_color text,
    vpn_color_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    item_diff_1 text,
    export_hts text,
    commercial_invoice_description text,
    dw_color_family text,
    origin_country_id text,
    country_of_sourcing text,
    country_of_manufacturing text,
    unit_cost real,
    freight text,
    agent_fee text,
    duty text,
    port text,
    ship_method text,
    lading_port text,
    hts text,
    factory text,
    po_supplier text,
    sub_brand text,
    design_stylecolor_status text,
    primary_supplier text,
    spec_stylecolor_open1 text,
    spec_stylecolor_open2 text,
    spec_stylecolor_open3 text,
    spec_stylecolor_open4 text,
    spec_stylecolor_open5 text,
    spec_stylecolor_open6 text,
    spec_stylecolor_open7 text,
    spec_stylecolor_open8 text,
    spec_stylecolor_open9 text,
    spec_stylecolor_open10 text,
    spec_stylecolor_open11 text,
    spec_stylecolor_open12 text,
    supp_cost real,
    art_code text
);


--
-- Name: trd_ma_specstylecolorattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_specstylecolorattributes_intraday (
    vpn_vsn text,
    vpn_description text,
    vpn_color text,
    vpn_color_description text,
    dept_id text,
    class_id text,
    subclass_id text,
    item_diff_1 text,
    export_hts text,
    commercial_invoice_description text,
    dw_color_family text,
    origin_country_id text,
    country_of_sourcing text,
    country_of_manufacturing text,
    unit_cost real,
    freight text,
    agent_fee text,
    duty text,
    port text,
    ship_method text,
    lading_port text,
    hts text,
    factory text,
    po_supplier text,
    sub_brand text,
    design_stylecolor_status text,
    primary_supplier text,
    supp_cost real,
    art_code text,
    cc_material_content text,
    division text,
    group_id text,
    development_season text,
    delivery_season text,
    po_due_date text,
    pd_ndc_week text,
    additional_tariff text,
    design_notes text,
    pd_notes text,
    compliance_notes text,
    spec_stylecolor_open1 text,
    spec_stylecolor_open2 text,
    spec_stylecolor_open3 text,
    spec_stylecolor_open4 text,
    spec_stylecolor_open5 text,
    spec_stylecolor_open6 text,
    spec_stylecolor_open7 text,
    spec_stylecolor_open8 text,
    spec_stylecolor_open9 text,
    spec_stylecolor_open10 text,
    spec_stylecolor_open11 text,
    spec_stylecolor_open12 text
);


--
-- Name: trd_ma_storeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_storeattributes (
    location text NOT NULL,
    strname text,
    str_store_peer text,
    str_mall_type text,
    str_volume_range text,
    str_active_sales text,
    str_active_alloc text,
    str_active_bopis text,
    str_active_sfs text,
    str_competition_1 text,
    str_competition_2 text,
    str_competition_3 text,
    str_date_opened text,
    str_date_closed text,
    str_date_remodeled text,
    str_dc_current text,
    str_dc_final text,
    str_dc_transit text,
    str_fxt_cashwrap_type text,
    str_fxt_casual_3 text,
    str_fxt_panty_tables text,
    str_fxt_bra_cabinets text,
    str_fxt_open_1 text,
    str_fxt_open_2 text,
    str_fxt_open_3 text,
    str_fxt_open_4 text,
    str_fxt_open_5 text,
    str_fxt_open_6 text,
    str_fxt_open_7 text,
    str_fxt_open_8 text,
    str_fxt_open_9 text,
    str_fxt_open_10 text,
    str_fxt_open_11 text,
    str_fxt_open_12 text,
    str_fxt_open_13 text,
    str_fxt_open_14 text,
    str_fxt_open_15 text,
    str_geo_timezone text,
    str_geo_region text,
    str_mkt_border text,
    str_mkt_coastal text,
    str_mkt_urban text,
    str_mkt_tourist text,
    str_mkt_college_1 text,
    str_mkt_college_2 text,
    str_mkt_sports_baseball text,
    str_mkt_sports_football text,
    str_mkt_sports_basketball text,
    str_mkt_sports_hockey text,
    str_size_1_ttl_str text,
    str_size_2_sls_flr text,
    str_size_3_merch_flr text,
    str_size_4_stk_rm text,
    str_size_5_oth text,
    str_size_6_offsite text,
    str_real_est_proforma text,
    str_real_est_rank text,
    str_corp_rank text,
    str_sp_vol_alpha text,
    str_sp_vol_proforma text,
    str_days_from_wh text,
    str_dc_or_store text,
    str_selling_channel text,
    str_store_banner text,
    str_store_climate text,
    str_hazmat text,
    str_capacity text,
    str_capacity_volume text,
    str_latitude text,
    str_longitude text,
    str_area_id text,
    str_loc_attr_1 text,
    str_loc_attr_2 text,
    str_loc_attr_3 text,
    str_loc_attr_4 text,
    str_loc_attr_5 text,
    str_loc_attr_6 text,
    str_loc_attr_7 text,
    str_loc_attr_8 text,
    str_loc_attr_9 text,
    str_loc_attr_10 text,
    str_loc_attr_11 text,
    str_loc_attr_12 text,
    str_loc_attr_13 text,
    str_loc_attr_14 text,
    str_loc_attr_15 text,
    str_city text,
    str_zipcode text,
    str_clearance_store text,
    district_name text,
    district_desc text,
    region_name text,
    region_desc text,
    area_name text,
    area_desc text,
    selling_channel_name text,
    selling_channel_desc text,
    channel_name text,
    channel_desc text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    str_grade text
);


--
-- Name: trd_ma_storeattributes_lat_long; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_storeattributes_lat_long (
    indx integer,
    location text,
    strlatlong_latitude text,
    strlatlong_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_ma_styleattributes_20251010; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_styleattributes_20251010 (
    product text,
    sty_knit_or_woven text,
    sty_fabrication text,
    sty_sleeve_length text,
    sty_leg_opening text,
    sty_brand text,
    sty_body_style_silhouette text,
    sty_occasion_usage text,
    sty_detail text,
    sty_finish_style text,
    sty_private_label text,
    sty_license text,
    sty_license_vs_non_licensed text,
    sty_hazmat_code text,
    sty_prop_65_warning text,
    sty_material_content text,
    sty_item_type text,
    sty_dwrise text,
    sty_length text,
    sty_neckline text,
    sty_toeshape text,
    sty_heel_height text,
    sty_bottom_length text,
    sty_v_360_smoothing text,
    sty_franchise text,
    sty_key_item text,
    sty_single_vs_multi_pack text,
    sty_ticket_type text,
    sty_vpn text,
    sty_size_range text,
    ccstylecreatedate text,
    sty_is_locked text,
    sty_s5_adopted text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    plm_size_range text,
    sty_knit_fit text,
    sty_patterned_after text
);


--
-- Name: trd_ma_styleattributes_bkp_12212024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_styleattributes_bkp_12212024 (
    product text,
    sty_knit_or_woven text,
    sty_fabrication text,
    sty_sleeve_length text,
    sty_leg_opening text,
    sty_brand text,
    sty_body_style_silhouette text,
    sty_occasion_usage text,
    sty_detail text,
    sty_finish_style text,
    sty_private_label text,
    sty_license text,
    sty_license_vs_non_licensed text,
    sty_hazmat_code text,
    sty_prop_65_warning text,
    sty_material_content text,
    sty_item_type text,
    sty_dwrise text,
    sty_length text,
    sty_neckline text,
    sty_toeshape text,
    sty_heel_height text,
    sty_bottom_length text,
    sty_v_360_smoothing text,
    sty_franchise text,
    sty_key_item text,
    sty_single_vs_multi_pack text,
    sty_ticket_type text,
    sty_vpn text,
    sty_size_range text,
    ccstylecreatedate text,
    sty_is_locked text,
    sty_s5_adopted text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    plm_size_range text,
    sty_knit_fit text,
    sty_patterned_after text
);


--
-- Name: trd_ma_stylecolor_alloc_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolor_alloc_attributes (
    product text NOT NULL,
    sclr_alloc_rule_fair_share real,
    sclr_alloc_rule_layered real,
    sclr_alloc_rule_curr_oh real,
    sclr_alloc_fcst_asst_plan real,
    sclr_alloc_fcst_recalib real,
    sclr_alloc_rule_adjust_dbt real,
    sclr_alloc_rule_adjust_md real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    created_by text,
    updated_at timestamp without time zone DEFAULT (now())::timestamp(0) without time zone,
    updated_by text,
    record_state smallint DEFAULT 0,
    sclr_alloc_ecom_rsv_alloc_min real,
    sclr_alloc_ecom_rsv_alloc_exact real,
    sclr_alloc_aps_index real,
    sclr_alloc_sales_index real,
    sclr_alloc_blended_index real,
    sclr_min_shortfall_policy real,
    sclr_overflow_ok real,
    sclr_round_robin_excess_global real,
    sclr_treat_alloc_min_as_minorder real,
    sclr_ecomm_need_as_moq real,
    sclr_have_max_num_stores_with_packs real,
    sclr_assign_pack_to_zero_ideal real,
    sclr_allow_scaling real,
    sclr_default_allocation_basis text,
    excess_eligible_stores text[] DEFAULT '{AA,A,B,C,D,E}'::text[],
    weight_need text DEFAULT 'Medium'::text,
    worklist text,
    sclr_apply_projected_trend real
);


--
-- Name: trd_ma_stylecolorattributes_20251010; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorattributes_20251010 (
    product text,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost real,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    cccolor text,
    cccolorfamily text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone,
    allocator_comments text,
    cccolorid text,
    cc_specstylecolor_status text,
    cc_agent_fee text,
    cc_port text,
    cc_factory text,
    cc_floorset text,
    cc_use_sys_floorset boolean,
    cc_supp_cost real,
    cc_finish text,
    cc_license text,
    cc_channel_availability text,
    cc_extended_size text,
    cc_op_markdown_week text,
    cc_motif text,
    cc_rp_revised_markdown_week text,
    cc_web_current_retail real,
    cc_parent_season_code text,
    cc_art_code text,
    cc_patterned_after text,
    cc_material_content text,
    cc_fabrication text,
    style_name text,
    stylecolor_name text,
    buyer_email text,
    cc_buyer text
);


--
-- Name: trd_ma_stylecolorattributes_bkp_12212024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorattributes_bkp_12212024 (
    product text,
    cc_item_diff_1 text,
    cc_unit_retail real,
    cc_unit_retail_cad real,
    cc_pattern text,
    cc_graphic text,
    cc_fashion_basic text,
    cc_holiday text,
    cc_property_type text,
    cc_internet_exclusive text,
    cc_web_color_discription text,
    cc_export_hts text,
    cc_commercial_invoice_description text,
    cc_season_code text,
    cc_dtr text,
    cc_dw_color_family text,
    cc_channel_reorder text,
    cc_ticket_season_code text,
    cc_sub_programs text,
    cc_music_genre text,
    cc_clearance_str_product text,
    cc_po_supplier text,
    cc_origin_country_id text,
    cc_country_of_sourcing text,
    cc_country_of_manufacturing text,
    cc_unit_cost real,
    cc_freight text,
    cc_royalty text,
    cc_duty text,
    cc_ship_method text,
    cc_lading_port text,
    cc_hts text,
    cc_primary_supplier text,
    cc_sub_brand text,
    cc_pattern_type text,
    cc_pop_print_neutral text,
    cc_debut_season_code text,
    cc_matchback text,
    cc_primary_collection text,
    cc_secondary_collection text,
    cc_vpn_color text,
    cc_orig_unit_retail real,
    cc_orig_unit_retail_cad real,
    cc_first_rec_week text,
    cc_first_inv_week text,
    cc_first_sale_week text,
    cc_first_md_week text,
    cc_last_md_week text,
    cc_last_rec_week text,
    cc_store_price_status text,
    cc_ifc_price_status text,
    cc_omni_price_type text,
    ccstylecolorcreatedate text,
    cc_price_band text,
    cc_good_better_best text,
    cccolor text,
    cccolorfamily text,
    total_brand_name text,
    division_name text,
    group_name text,
    department_name text,
    class_name text,
    subclass_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    isassortment text,
    merch_comments text,
    plan_comments text,
    cc_is_locked text,
    cc_s5_adopted text,
    cc_prepublish integer,
    cc_prepublished_at timestamp without time zone,
    allocator_comments text,
    cccolorid text,
    cc_specstylecolor_status text,
    cc_agent_fee text,
    cc_port text,
    cc_factory text,
    cc_floorset text,
    cc_use_sys_floorset boolean,
    cc_supp_cost real,
    cc_finish text,
    cc_license text,
    cc_channel_availability text,
    cc_extended_size text,
    cc_op_markdown_week text,
    cc_motif text,
    cc_rp_revised_markdown_week text,
    cc_web_current_retail real,
    cc_parent_season_code text,
    cc_art_code text,
    cc_patterned_after text
);


--
-- Name: trd_ma_stylecolorchannelattributes_20250328; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorchannelattributes_20250328 (
    product text,
    location text,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real,
    slsrnk_ecom real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real,
    ccticketpricechannel_override real,
    cc_imupct real,
    cc_discount_pct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_plan_cost real,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real,
    cc_discount_pct_ecom real,
    irw_debut_offset integer,
    cc_service_level_ecom real,
    cc_first_publish_date timestamp without time zone,
    cc_first_publish_snapshot_op integer
);


--
-- Name: trd_ma_stylecolorchannelattributes_20251010; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorchannelattributes_20251010 (
    product text,
    location text,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real,
    slsrnk_ecom real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real,
    ccticketpricechannel_override real,
    cc_imupct real,
    cc_discount_pct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_plan_cost real,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real,
    cc_discount_pct_ecom real,
    irw_debut_offset integer,
    cc_service_level_ecom real,
    cc_first_publish_date timestamp without time zone,
    cc_first_publish_snapshot_op integer,
    sclr_alloc_max real,
    sclr_presmin real,
    sclr_alloc_min real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_fringe_flag real
);


--
-- Name: trd_ma_stylecolorchannelattributes_bk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorchannelattributes_bk (
    product text,
    location text,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real,
    slsrnk_ecom real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real,
    ccticketpricechannel_override real,
    cc_imupct real,
    cc_discount_pct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_plan_cost real,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real,
    cc_discount_pct_ecom real,
    irw_debut_offset integer,
    cc_service_level_ecom real,
    cc_first_publish_date timestamp without time zone,
    cc_first_publish_snapshot_op integer
);


--
-- Name: trd_ma_stylecolorchannelattributes_bk_20240922; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_stylecolorchannelattributes_bk_20240922 (
    product text,
    location text,
    dbt_wk text,
    relaunchweek text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    too smallint,
    mkdnwks smallint,
    last_inv_wk text,
    lstfpwk text,
    last_rcpt_wk text,
    lastdcorder text,
    act_initrcptwk text,
    act_dbt_wk text,
    irw_indx integer,
    dbtwk_indx integer,
    relaunchwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    preview_wks smallint,
    preview_qty smallint,
    plannedselldnwk text,
    ccmdstrategy text,
    slsrnk_store real,
    slsrnk_ecom real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_rcptint integer,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    cc_return_u_pct_cross real,
    cc_ordermultiple integer,
    cc_ordermin integer,
    cc_buy_aps_letter text,
    ccticketpricechannel real,
    ccticketpricechannel_override real,
    cc_imupct real,
    cc_discount_pct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_plan_cost real,
    ssnprf text,
    adjaps_store real,
    adjaps_ecom real,
    smoothing_strategy text,
    in_season_flag text,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    cc_lead_time integer,
    cc_service_level real,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    cc_store_min_multiple integer,
    planned_sell_down_week text,
    cc_selected_clusters text[],
    cc_cluster_group text,
    keep_initial_range_plan integer,
    cc_sizeelig_rangecode text,
    cc_presmin_stylecolor integer,
    cc_presmin_weeks_stylecolor integer,
    cc_final_cost real,
    cc_discount_pct_store real,
    cc_discount_pct_ecom real
);


--
-- Name: trd_ma_weekattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_ma_weekattributes (
    "time" text NOT NULL,
    start_date text,
    end_date text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_casepack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_casepack (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    case_pack_id text NOT NULL,
    po_pack_pct real,
    po_pack_config_min real,
    po_pack_config_max real,
    po_pack_qty_min real,
    po_pack_qty_max real,
    po_pack_sku_min real,
    po_pack_sku_max real,
    po_min_packs_per_store real,
    po_max_packs_per_store real,
    po_fringe_included text,
    po_threshold_var_plan_pct real,
    po_status real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_channeloverride; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_channeloverride (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    weekadjaps real,
    weekadjaps_ecom real,
    weekadjslsu real,
    weekadjslsu_ecom real,
    comments text DEFAULT ''::text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    testpo text,
    floorsetpo text
);


--
-- Name: trd_p_dc_adj; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_dc_adj (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    dc_publish real,
    is_locked real,
    dc_uservrp real,
    dc_lockedqty real,
    dc_useradj real,
    dc_onorder real,
    dc_finrev real,
    dc_validwk real,
    dc_finalqty real,
    dc_adjcost real,
    const_y_n real,
    sbkt real,
    dc_isedited real,
    dc_syscost real,
    dc_lndcst real,
    dc_sysvrp real,
    dc_sc_useradj real,
    dc_sc_finrev real,
    po_indicator text,
    po_shipmode text,
    air_trigger text,
    cut text,
    published_at timestamp(0) without time zone,
    is_prepublished real,
    prepublished_at timestamp(0) without time zone,
    last_prepublished real,
    po_arr text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    dc_useradj_ecom real,
    dc_onorder_ecom real,
    dc_finrev_ecom real,
    dc_publish_ecom real,
    po_indicator_ecom text,
    po_shipmode_ecom text,
    air_trigger_ecom text,
    cut_ecom text,
    published_at_ecom timestamp(0) without time zone,
    is_prepublished_ecom real,
    prepublished_at_ecom timestamp(0) without time zone,
    last_prepublished_ecom real,
    reason_code text,
    reason_code_ecom text,
    pack_ind_flag text DEFAULT 'N'::text NOT NULL,
    pack_ind_flag_ecom text DEFAULT 'N'::text NOT NULL,
    show_in_pack text,
    show_in_pack_ecom text,
    prepack_pct real,
    prepack_pct_ecom real,
    default_fringe_indicator text DEFAULT 'N'::text NOT NULL,
    default_fringe_indicator_ecom text DEFAULT 'N'::text NOT NULL,
    email_to text,
    published_by text
);


--
-- Name: trd_p_dc_adj_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_dc_adj_size (
    product text,
    location text,
    "time" text,
    dc_publish real,
    is_locked real,
    dc_uservrp real,
    dc_lockedqty real,
    dc_useradj real,
    dc_onorder real,
    dc_finrev real,
    dc_validwk real,
    dc_finalqty real,
    dc_adjcost real,
    const_y_n real,
    sbkt real,
    dc_scadj real,
    dc_ttluseradj real,
    dc_scfinrev real,
    dc_ttlfinrev real,
    dc_isedited real,
    dc_onorder_v real,
    dc_onorder_c real,
    current_week text,
    dc_last_pub_u real,
    dc_last_pub timestamp without time zone,
    eventdate date DEFAULT (now())::date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text,
    record_state smallint,
    dc_useradj_ecom real,
    dc_onorder_ecom real,
    dc_onorder_v_ecom real,
    dc_onorder_c_ecom real,
    dc_finrev_ecom real,
    dc_publish_ecom real,
    dc_last_pub_u_ecom real,
    dc_last_pub_ecom timestamp without time zone
);


--
-- Name: trd_p_dept_store_attr_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_dept_store_attr_plan (
    product text NOT NULL,
    location text NOT NULL,
    dept_str_open_week text,
    dept_str_close_week text,
    dept_str_like_store text,
    dept_str_like_store_valid_from text,
    dept_str_like_store_valid_upto text,
    dept_str_like_store_perf_factor real,
    dept_str_is_valid real,
    dept_str_priority real,
    dept_str_like_store_ty_shp_r real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_itemprice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_itemprice (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    addoff real,
    eo real,
    eff_aur real,
    department text NOT NULL,
    event text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    excl_discount_pct real,
    addoff_ecom real,
    addoff_store real
);


--
-- Name: trd_p_itemprice_20251013; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_itemprice_20251013 (
    product text,
    location text,
    "time" text,
    addoff real,
    eo real,
    eff_aur real,
    department text,
    event text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    excl_discount_pct real,
    addoff_ecom real,
    addoff_store real
);


--
-- Name: trd_p_reassigncluster; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_reassigncluster (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    store_cluster_id text NOT NULL,
    reassigned_cluster text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_receditclusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_receditclusters (
    product text NOT NULL,
    "time" text NOT NULL,
    po_id_for_clusters text NOT NULL,
    cl_00 real,
    cl_01 real,
    cl_02 real,
    cl_03 real,
    cl_04 real,
    cl_05 real,
    cl_06 real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_receditstores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_receditstores (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    po_id_for_stores text NOT NULL,
    store_rec_edit real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_specstylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_specstylecolorattributes (
    cc_spec_vpn_vsn text NOT NULL,
    cc_spec_vpn_description text,
    cc_spec_vpn_color text NOT NULL,
    cc_spec_vpn_color_description text,
    cc_spec_dept_id text,
    cc_spec_class_id text,
    cc_spec_subclass_id text,
    cc_spec_item_diff_1 text,
    cc_spec_export_hts text,
    cc_spec_commercial_invoice_description text,
    cc_spec_dw_color_family text,
    cc_spec_origin_country_id text,
    cc_spec_country_of_sourcing text,
    cc_spec_country_of_manufacturing text,
    cc_spec_unit_cost real,
    cc_spec_freight text,
    cc_spec_agent_fee text,
    cc_spec_duty text,
    cc_spec_port text,
    cc_spec_ship_method text,
    cc_spec_lading_port text,
    cc_spec_hts text,
    cc_spec_factory text,
    cc_spec_po_supplier text,
    cc_spec_sub_brand text,
    cc_spec_design_stylecolor_status text,
    cc_spec_primary_supplier text,
    cc_spec_supp_cost real,
    cc_spec_art_code text,
    cc_spec_cc_material_content text,
    cc_spec_division text,
    cc_spec_group text,
    cc_spec_development_season text,
    cc_spec_delivery_season text,
    cc_spec_po_due_date text,
    cc_spec_pd_ndc_week text,
    cc_spec_additional_tariff text,
    cc_spec_design_notes text,
    cc_spec_pd_notes text,
    cc_spec_compliance_notes text,
    cc_spec_merchant_notes text,
    location text NOT NULL,
    product text NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_store_attr_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_store_attr_plan (
    location text NOT NULL,
    str_open_week text,
    str_close_week text,
    str_like_store text,
    str_like_store_valid_from text,
    str_like_store_valid_upto text,
    str_like_store_perf_factor real,
    str_is_valid real,
    str_priority real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_strategy_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_strategy_params (
    product text NOT NULL,
    location text NOT NULL,
    floorset_uda text NOT NULL,
    ly_floorset text,
    lly_floorset text,
    quarter_start text,
    target_sales_start text,
    target_sales_end text,
    target_receipt_start text,
    target_receipt_end text,
    ly_sales_start text,
    ly_sales_end text,
    ly_receipt_start text,
    ly_receipt_end text,
    lly_sales_start text,
    lly_sales_end text,
    lly_receipt_start text,
    lly_receipt_end text,
    rec_magnitude integer DEFAULT 0,
    ref_avg_cc_count text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    apply_targets_to_plan integer
);


--
-- Name: trd_p_strategy_params_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_strategy_params_bkp (
    product text,
    location text,
    floorset_uda text,
    ly_floorset text,
    lly_floorset text,
    quarter_start text,
    target_sales_start text,
    target_sales_end text,
    target_receipt_start text,
    target_receipt_end text,
    ly_sales_start text,
    ly_sales_end text,
    ly_receipt_start text,
    ly_receipt_end text,
    lly_sales_start text,
    lly_sales_end text,
    lly_receipt_start text,
    lly_receipt_end text,
    rec_magnitude integer,
    ref_avg_cc_count text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    apply_targets_to_plan integer
);


--
-- Name: trd_p_stylecolor_channel_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_channel_alloc_params (
    product text NOT NULL,
    location text NOT NULL,
    sclr_def_alloc_sizeattr text[],
    sclr_def_presmin real,
    sclr_def_presmin_weeks real,
    sclr_def_fringe_flag real DEFAULT 1,
    sclr_def_target_fwoc_override real,
    sclr_def_service_level real,
    sclr_def_alloc_min real,
    sclr_def_alloc_max real,
    sclr_def_size_eligibility integer[],
    sclr_def_size_min_by_size_override integer[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_stylecolor_store_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_store_alloc_params (
    product text NOT NULL,
    location text NOT NULL,
    sclr_loc_eligibility integer,
    sclr_loc_tgt_fp_st_pct real,
    sclr_loc_alloc_sizeattr text[],
    sclr_loc_presmin real,
    sclr_loc_presmin_weeks real,
    sclr_loc_target_fwoc_override real,
    sclr_loc_service_level real,
    sclr_loc_alloc_min real,
    sclr_loc_alloc_max real,
    sclr_loc_size_eligibility integer[],
    sclr_loc_size_min_by_size_override integer[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    sclr_loc_fringe_flag real DEFAULT 1,
    sclr_loc_alloc_sizeattr_for_size_min text[]
);


--
-- Name: trd_p_stylecolor_store_eligibility; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_store_eligibility (
    product text NOT NULL,
    location text NOT NULL,
    sclr_str_eligibility integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_p_stylecolor_store_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_store_worklist (
    product text NOT NULL,
    "time" text NOT NULL,
    location text NOT NULL,
    worklist_id text NOT NULL,
    sclr_loc_wrk_alloc_sclr_qty real,
    sclr_loc_wrk_alloc_size_qty integer[],
    sclr_loc_wrk_alloc_sizeattr text[],
    sclr_loc_wrk_presmin real,
    sclr_loc_wrk_presmin_weeks real,
    sclr_loc_wrk_target_fwoc_override real,
    sclr_loc_wrk_service_level real,
    sclr_loc_wrk_alloc_min real,
    sclr_loc_wrk_alloc_max real,
    sclr_loc_wrk_size_eligibility integer[],
    sclr_loc_wrk_size_min_by_size_override integer[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying DEFAULT 'system'::character varying,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying DEFAULT 'system'::character varying,
    record_state smallint DEFAULT 0,
    sclr_loc_wrk_fringe_flag real DEFAULT 1,
    sclr_loc_wrk_size_user_override integer[],
    sclr_loc_alloc_sizeattr_for_size_override text[]
);


--
-- Name: trd_p_stylecolor_sysmanaged_attr_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_sysmanaged_attr_plan (
    product text NOT NULL,
    location text NOT NULL,
    cc_floorset_override_plan text,
    cc_use_sys_floorset_override_plan integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_p_stylecolor_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_worklist (
    product text NOT NULL,
    "time" text NOT NULL,
    location text NOT NULL,
    worklist_id text NOT NULL,
    sclr_wrk_auto_allocation text,
    sclr_wrk_alloc_rule text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    in_worklist real,
    sclr_wrk_prepack_holdback real,
    sclr_wrk_prepack_transfer real,
    sclr_wrk_approved real,
    sclr_wrk_released real,
    sclr_wrk_status real
);


--
-- Name: trd_p_stylecolor_worklist_tbl_approved_but_removed_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolor_worklist_tbl_approved_but_removed_archives (
    product text,
    "time" text,
    location text,
    worklist_id text,
    sclr_wrk_auto_allocation text,
    sclr_wrk_alloc_rule text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    in_worklist real,
    sclr_wrk_prepack_holdback real,
    sclr_wrk_prepack_transfer real,
    sclr_wrk_approved real,
    sclr_wrk_released real,
    sclr_wrk_status real,
    archived_on timestamp with time zone
);


--
-- Name: trd_p_stylecolorsize_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_stylecolorsize_worklist (
    product text NOT NULL,
    "time" text NOT NULL,
    location text NOT NULL,
    worklist_id text NOT NULL,
    sz_wrk_holdback real,
    sz_wrk_ecomm_reserve real,
    sz_wrk_stores_reserve real,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    sz_wrk_loose_holdback real,
    sz_wrk_loose_transfer real
);


--
-- Name: trd_p_target_include_exclude; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_p_target_include_exclude (
    product text NOT NULL,
    "time" text NOT NULL,
    ly_lly_key text NOT NULL,
    include_in_target_for_checkbox integer,
    include_in_target integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_pg_batch_validation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_pg_batch_validation (
    id text,
    stage text,
    source_table text,
    validation_description text,
    validation_condition text,
    current_value text,
    previous1_value text,
    previous2_value text,
    previous3_value text,
    previous4_value text,
    curr_prev_percentage_diff text,
    diff_percentage_threshold text,
    check_percentage_diff text,
    check_zero_value text,
    check_curr_prev_diff text,
    int_sequence integer,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP)
);


--
-- Name: trd_pg_batch_validation_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_pg_batch_validation_archive (
    id text,
    stage text,
    source_table text,
    validation_description text,
    validation_condition text,
    current_value text,
    previous1_value text,
    previous2_value text,
    previous3_value text,
    previous4_value text,
    curr_prev_percentage_diff text,
    diff_percentage_threshold text,
    check_percentage_diff text,
    check_zero_value text,
    check_curr_prev_diff text,
    int_sequence integer,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP)
);


--
-- Name: trd_pg_batch_validation_failure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_pg_batch_validation_failure (
    failure_message text,
    id text,
    stage text,
    source_table text,
    validation_description text,
    validation_condition text,
    current_value text,
    previous1_value text,
    previous2_value text,
    previous3_value text,
    previous4_value text,
    curr_prev_percentage_diff text,
    diff_percentage_threshold text,
    check_percentage_diff text,
    check_zero_value text,
    check_curr_prev_diff text,
    int_sequence integer,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP)
);


--
-- Name: trd_pg_batch_validation_previous; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_pg_batch_validation_previous (
    id text,
    stage text,
    source_table text,
    validation_description text,
    validation_condition text,
    current_value text,
    previous1_value text,
    previous2_value text,
    previous3_value text,
    previous4_value text,
    curr_prev_percentage_diff text,
    diff_percentage_threshold text,
    check_percentage_diff text,
    check_zero_value text,
    check_curr_prev_diff text,
    int_sequence integer,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP)
);


--
-- Name: trd_plan_these_cloned_style_stylecolors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_plan_these_cloned_style_stylecolors (
    style text NOT NULL,
    stylecolor text NOT NULL,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    picked_for_planning integer
);


--
-- Name: trd_replan_again; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_replan_again (
    product text
);


--
-- Name: trd_replannable_choices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_replannable_choices (
    product text
);


--
-- Name: trd_roledimension; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_roledimension (
    tenantid text NOT NULL,
    roleid text NOT NULL,
    dimensionid text NOT NULL,
    levelids text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_servicedefn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_servicedefn (
    service text,
    authlevels text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_size_range_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_size_range_mapping (
    size_range character varying(500),
    size_id character varying(500),
    size_desc character varying(500),
    sort_order integer,
    parent_size character varying(500),
    fringe_size_ind integer
);


--
-- Name: trd_sizinglookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_sizinglookup (
    sizerange text NOT NULL,
    size text NOT NULL,
    nsp real,
    multiplier real,
    groupsum real,
    strselling_channel text
);


--
-- Name: trd_specimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_specimages (
    product text NOT NULL,
    img text
);


--
-- Name: trd_specimages_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_specimages_intraday (
    product text NOT NULL,
    img text
);


--
-- Name: trd_split_attrs_prefill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_split_attrs_prefill (
    stylecolor text,
    current_stylecolor_name text,
    current_style_name text,
    session_id text
);


--
-- Name: trd_store_hier_attr; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.trd_store_hier_attr AS
 SELECT a.location,
    a.strname,
    a.str_store_peer,
    a.str_mall_type,
    a.str_volume_range,
    a.str_active_sales,
    a.str_active_alloc,
    a.str_active_bopis,
    a.str_active_sfs,
    a.str_competition_1,
    a.str_competition_2,
    a.str_competition_3,
    a.str_date_opened,
    a.str_date_closed,
    a.str_date_remodeled,
    a.str_dc_current,
    a.str_dc_final,
    a.str_dc_transit,
    a.str_fxt_cashwrap_type,
    a.str_fxt_casual_3,
    a.str_fxt_panty_tables,
    a.str_fxt_bra_cabinets,
    a.str_fxt_open_1,
    a.str_fxt_open_2,
    a.str_fxt_open_3,
    a.str_fxt_open_4,
    a.str_fxt_open_5,
    a.str_fxt_open_6,
    a.str_fxt_open_7,
    a.str_fxt_open_8,
    a.str_fxt_open_9,
    a.str_fxt_open_10,
    a.str_fxt_open_11,
    a.str_fxt_open_12,
    a.str_fxt_open_13,
    a.str_fxt_open_14,
    a.str_fxt_open_15,
    a.str_geo_timezone,
    a.str_geo_region,
    a.str_mkt_border,
    a.str_mkt_coastal,
    a.str_mkt_urban,
    a.str_mkt_tourist,
    a.str_mkt_college_1,
    a.str_mkt_college_2,
    a.str_mkt_sports_baseball,
    a.str_mkt_sports_football,
    a.str_mkt_sports_basketball,
    a.str_mkt_sports_hockey,
    a.str_size_1_ttl_str,
    a.str_size_2_sls_flr,
    a.str_size_3_merch_flr,
    a.str_size_4_stk_rm,
    a.str_size_5_oth,
    a.str_size_6_offsite,
    a.str_real_est_proforma,
    a.str_real_est_rank,
    a.str_corp_rank,
    a.str_sp_vol_alpha,
    a.str_sp_vol_proforma,
    a.str_days_from_wh,
    a.str_dc_or_store,
    a.str_selling_channel,
    a.str_store_banner,
    a.str_store_climate,
    a.str_hazmat,
    a.str_capacity,
    a.str_capacity_volume,
    a.str_latitude,
    a.str_longitude,
    a.str_area_id,
    a.str_loc_attr_1,
    a.str_loc_attr_2,
    a.str_loc_attr_3,
    a.str_loc_attr_4,
    a.str_loc_attr_5,
    a.str_loc_attr_6,
    a.str_loc_attr_7,
    a.str_loc_attr_8,
    a.str_loc_attr_9,
    a.str_loc_attr_10,
    a.str_loc_attr_11,
    a.str_loc_attr_12,
    a.str_loc_attr_13,
    a.str_loc_attr_14,
    a.str_loc_attr_15,
    a.str_city,
    a.str_zipcode,
    a.str_clearance_store,
    a.location AS store,
    b.ancestor0 AS district,
    a.district_name,
    a.district_desc,
    b.ancestor1 AS region,
    a.region_name,
    a.region_desc,
    b.ancestor2 AS area,
    a.area_name,
    a.area_desc,
    b.ancestor3 AS selling_channel,
    a.selling_channel_name,
    a.selling_channel_desc,
    b.ancestor4 AS channel,
    a.channel_name,
    a.channel_desc,
    a.eventdate,
    a.version_id,
    a.created_at,
    a.created_by,
    a.updated_at,
    a.updated_by,
    a.record_state
   FROM (public.trd_ma_storeattributes a
     LEFT JOIN public.trd_h_locstd b ON ((a.location = b.id)))
  ORDER BY a.location;


--
-- Name: trd_style_clone_stylecolor_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_style_clone_stylecolor_size (
    from_style text,
    to_new_style text NOT NULL,
    from_stylecolor text NOT NULL,
    to_new_stylecolor text NOT NULL,
    from_stylecolorsize text NOT NULL,
    to_new_stylecolorsize text NOT NULL,
    updated_by text NOT NULL,
    session_id text NOT NULL,
    picked_for_planning integer,
    clone_ordinal integer,
    to_new_style_name text,
    to_new_style_desc text,
    to_new_stylecolor_name text,
    to_new_stylecolor_desc text
);


--
-- Name: trd_style_merge_archives_tbl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_style_merge_archives_tbl (
    source_style_id text NOT NULL,
    target_style_id text NOT NULL,
    source_stylecolor_id text NOT NULL,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: trd_style_merge_reparent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_style_merge_reparent (
    source_stylecolor_id text NOT NULL,
    source_style_id text NOT NULL,
    target_style_id text NOT NULL,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    cccolor text,
    action text
);


--
-- Name: trd_style_split_archives_tbl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_style_split_archives_tbl (
    source_stylecolor_id text NOT NULL,
    source_style_id text NOT NULL,
    new_style_id text NOT NULL,
    new_style_name text NOT NULL,
    new_style_desc text NOT NULL,
    cccolor text,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: trd_style_split_stage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_style_split_stage (
    source_stylecolor_id text NOT NULL,
    source_style_id text NOT NULL,
    new_style_id text NOT NULL,
    new_style_name text NOT NULL,
    new_style_desc text NOT NULL,
    cccolor text,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: trd_stylecolor_hier_attr; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.trd_stylecolor_hier_attr AS
 SELECT a.product,
    a.cc_item_diff_1,
    a.cc_unit_retail,
    a.cc_unit_retail_cad,
    a.cc_pattern,
    a.cc_graphic,
    a.cc_fashion_basic,
    a.cc_holiday,
    a.cc_property_type,
    a.cc_internet_exclusive,
    a.cc_web_color_discription,
    a.cc_export_hts,
    a.cc_commercial_invoice_description,
    a.cc_season_code,
    a.cc_dtr,
    a.cc_dw_color_family,
    a.cc_channel_reorder,
    a.cc_ticket_season_code,
    a.cc_sub_programs,
    a.cc_music_genre,
    a.cc_clearance_str_product,
    a.cc_po_supplier,
    a.cc_origin_country_id,
    a.cc_country_of_sourcing,
    a.cc_country_of_manufacturing,
    a.cc_unit_cost,
    a.cc_freight,
    a.cc_royalty,
    a.cc_duty,
    a.cc_ship_method,
    a.cc_lading_port,
    a.cc_hts,
    a.cc_primary_supplier,
    a.cc_sub_brand,
    a.cc_pattern_type,
    a.cc_pop_print_neutral,
    a.cc_debut_season_code,
    a.cc_matchback,
    a.cc_primary_collection,
    a.cc_secondary_collection,
    a.cc_vpn_color,
    a.cc_orig_unit_retail,
    a.cc_orig_unit_retail_cad,
    a.cc_first_rec_week,
    a.cc_first_inv_week,
    a.cc_first_sale_week,
    a.cc_first_md_week,
    a.cc_last_md_week,
    a.cc_last_rec_week,
    a.cc_store_price_status,
    a.cc_ifc_price_status,
    a.cc_omni_price_type,
    a.cc_agent_fee,
    a.cc_factory,
    a.ccstylecolorcreatedate,
    a.cc_price_band,
    a.cc_good_better_best,
    a.cc_port,
    a.cccolor,
    a.cccolorfamily,
    a.cccolorid,
    a.isassortment,
    a.merch_comments,
    a.plan_comments,
    a.allocator_comments,
    a.cc_is_locked,
    a.cc_s5_adopted,
    a.cc_prepublish,
    a.cc_prepublished_at,
    c.sty_knit_or_woven,
    c.sty_fabrication,
    c.sty_sleeve_length,
    c.sty_leg_opening,
    c.sty_brand,
    c.sty_body_style_silhouette,
    c.sty_occasion_usage,
    c.sty_detail,
    c.sty_finish_style,
    c.sty_private_label,
    c.sty_license,
    c.sty_license_vs_non_licensed,
    c.sty_hazmat_code,
    c.sty_prop_65_warning,
    c.sty_material_content,
    c.sty_item_type,
    c.sty_dwrise,
    c.sty_length,
    c.sty_neckline,
    c.sty_toeshape,
    c.sty_heel_height,
    c.sty_bottom_length,
    c.sty_v_360_smoothing,
    c.sty_franchise,
    c.sty_key_item,
    c.sty_single_vs_multi_pack,
    c.sty_ticket_type,
    c.sty_vpn,
    c.sty_size_range,
    c.ccstylecreatedate,
    c.sty_is_locked,
    c.sty_s5_adopted,
    c.plm_size_range,
    b.id AS stylecolor,
    b.ancestor0 AS style,
    b.ancestor1 AS subclass,
    b.ancestor2 AS class,
    b.ancestor3 AS department,
    b.ancestor4 AS group_id,
    b.ancestor5 AS division,
    b.ancestor6 AS total_brand,
    d.stylecolor_name,
    d.stylecolor_desc,
    e.style_name,
    e.style_desc,
    f.subclass_name,
    f.subclass_desc,
    g.class_name,
    g.class_desc,
    h.department_name,
    h.department_desc,
    i.group_name,
    i.group_desc,
    j.division_name,
    j.division_desc,
    k.total_brand_name,
    k.total_brand_desc,
    a.eventdate,
    a.version_id,
    date_trunc('sec'::text, a.created_at) AS created_at,
    a.created_by,
    GREATEST(date_trunc('sec'::text, a.updated_at), date_trunc('sec'::text, c.updated_at)) AS updated_at,
    a.updated_by,
    a.record_state,
    a.cc_floorset,
        CASE
            WHEN (a.cc_use_sys_floorset = true) THEN 1
            ELSE 0
        END AS cc_use_sys_floorset,
    c.sty_knit_fit,
    a.cc_supp_cost,
    a.cc_finish,
    a.cc_license,
    a.cc_channel_availability,
    a.cc_extended_size,
    a.cc_op_markdown_week,
    a.cc_motif,
    a.cc_rp_revised_markdown_week,
    a.cc_web_current_retail,
    a.cc_parent_season_code,
    a.cc_art_code,
    c.sty_patterned_after,
    a.cc_patterned_after,
    a.cc_specstylecolor_status,
    a.cc_material_content,
    a.cc_fabrication,
    a.buyer_email,
    a.cc_buyer,
    ch.irw_floorset_id,
        CASE
            WHEN (a.cc_fashion_basic = 'BASIC'::text) THEN 'BASIC'::text
            ELSE
            CASE
                WHEN (ch.irw_floorset IS NULL) THEN 'NOT AVAILABLE'::text
                ELSE ch.irw_floorset
            END
        END AS irw_floorset,
        CASE
            WHEN (a.cc_fashion_basic = 'BASIC'::text) THEN 'BASIC'::text
            ELSE
            CASE
                WHEN (ch.irw_superset IS NULL) THEN 'NOT AVAILABLE'::text
                ELSE ch.irw_superset
            END
        END AS irw_superset,
        CASE
            WHEN (a.cc_fashion_basic = 'BASIC'::text) THEN 'BASIC'::text
            ELSE
            CASE
                WHEN (ch.irw_floorset_display IS NULL) THEN 'NOT AVAILABLE'::text
                ELSE ch.irw_floorset_display
            END
        END AS irw_floorset_display,
        CASE
            WHEN (a.cc_fashion_basic = 'BASIC'::text) THEN 'BASIC'::text
            ELSE
            CASE
                WHEN (ch.irw_superset_display IS NULL) THEN 'NOT AVAILABLE'::text
                ELSE ch.irw_superset_display
            END
        END AS irw_superset_display,
    a.vpn_color_desc,
    c.sty_vpn_desc,
    c.sty_num_clones_s5,
    c.sty_num_times_cloned_s5,
    a.cc_num_clones_s5,
    a.cc_num_times_cloned_s5,
    a.cc_spec_division,
    a.cc_spec_group,
    a.cc_development_season,
    a.cc_delivery_season,
    a.cc_po_due_date,
    a.cc_pd_ndc_week,
    a.cc_additional_tariff,
    a.cc_design_notes,
    a.cc_pd_notes,
    a.cc_compliance_notes
   FROM public.trd_ma_stylecolorattributes a,
    public.trd_h_prodstd b,
    public.trd_ma_styleattributes c,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS stylecolor_name,
            trd_d_product.description AS stylecolor_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'stylecolor'::text)) d,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS style_name,
            trd_d_product.description AS style_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'style'::text)) e,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS subclass_name,
            trd_d_product.description AS subclass_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'subclass'::text)) f,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS class_name,
            trd_d_product.description AS class_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'class'::text)) g,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS department_name,
            trd_d_product.description AS department_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'department'::text)) h,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS group_name,
            trd_d_product.description AS group_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'group_id'::text)) i,
    ( SELECT trd_d_product.id,
            trd_d_product.name AS division_name,
            trd_d_product.description AS division_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'division'::text)) j,
    (( SELECT trd_d_product.id,
            trd_d_product.name AS total_brand_name,
            trd_d_product.description AS total_brand_desc
           FROM public.trd_d_product
          WHERE (trd_d_product.levelid = 'total_brand'::text)) k
     LEFT JOIN LATERAL ( SELECT t.irw_floorset_id,
            t.irw_floorset,
            t.irw_superset,
            t.irw_floorset_display,
            t.irw_superset_display
           FROM public.trd_ma_stylecolorchannelattributes t
          WHERE (t.product = a.product)) ch ON (true))
  WHERE ((a.product = b.id) AND (b.ancestor0 = c.product) AND (a.product = d.id) AND (b.ancestor0 = e.id) AND (b.ancestor1 = f.id) AND (b.ancestor2 = g.id) AND (b.ancestor3 = h.id) AND (b.ancestor4 = i.id) AND (b.ancestor5 = j.id) AND (b.ancestor6 = k.id))
  ORDER BY b.id;


--
-- Name: trd_stylecolor_name_prefill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_stylecolor_name_prefill (
    stylecolor text,
    current_name text,
    session_id text
);


--
-- Name: trd_swatches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_swatches (
    attributeid text,
    validvalue text,
    datastr text,
    strtype text,
    type text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_v_memberbasedvalidvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_v_memberbasedvalidvalues (
    attributeid text,
    membertie text,
    attributekey text,
    attributevalue text,
    indx integer,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: trd_v_memberbasedvalidvalues_bkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_v_memberbasedvalidvalues_bkp (
    attributeid text,
    membertie text,
    attributekey text,
    attributevalue text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: trd_v_memberbasedvalidvalues_bkp_03292025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trd_v_memberbasedvalidvalues_bkp_03292025 (
    attributeid text,
    membertie text,
    attributekey text,
    attributevalue text,
    indx integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: tyly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tyly (
    ty text,
    ly text
);


--
-- Name: tyly_backup_refresh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tyly_backup_refresh (
    ty text,
    ly text
);


--
-- Name: undo_display; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.undo_display (
    undo_id uuid NOT NULL,
    modification_description text[] NOT NULL
);


--
-- Name: undo_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.undo_log (
    undo_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    department text NOT NULL,
    channel text NOT NULL,
    plan_measure text[] NOT NULL,
    level_tie text[] NOT NULL,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text,
    updated_at timestamp with time zone,
    undone boolean DEFAULT false NOT NULL
);


--
-- Name: undo_modifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.undo_modifications (
    undo_id uuid NOT NULL,
    key json NOT NULL,
    plan_defn text NOT NULL,
    measure text NOT NULL,
    old_value_numeric real,
    new_value_numeric real,
    old_value_text text,
    new_value_text text
);


--
-- Name: user_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_metadata (
    uid text NOT NULL,
    email text,
    name text
);


--
-- Name: user_metadata_get_api; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_metadata_get_api (
    uid text,
    email text
);


--
-- Name: user_tbl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tbl (
    tenantid text NOT NULL,
    id text NOT NULL,
    description text,
    name text,
    password text,
    roles text[],
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: user_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_worklist (
    user_id text NOT NULL,
    product text NOT NULL,
    type text DEFAULT 'active'::text NOT NULL,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    name text DEFAULT '⚠️❓❓'::text NOT NULL
);


--
-- Name: user_worklist_bkp_11172025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_worklist_bkp_11172025 (
    user_id text,
    product text,
    type text,
    updated_at timestamp without time zone,
    name text
);


--
-- Name: w38; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w38 (
    product text
);


--
-- Name: w41; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w41 (
    product text
);


--
-- Name: w42; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.w42 (
    product text
);


--
-- Name: worklist_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worklist_map (
    product text,
    worklist_id text NOT NULL
);


--
-- Name: xt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xt (
    product text,
    location text,
    initiator text
);


--
-- Name: yt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.yt (
    product text,
    location text,
    initiator text
);


--
-- Name: actuals_stage_wide; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.actuals_stage_wide (
    id text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_cc_count double precision NOT NULL,
    strcntwk double precision NOT NULL,
    sales_start_boh_u double precision NOT NULL,
    receipt_start_boh_u double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_r double precision NOT NULL,
    rec_c double precision NOT NULL,
    gross_sales_u double precision NOT NULL,
    gross_sales_tktp double precision NOT NULL,
    gross_sales_r double precision NOT NULL,
    funded_cc_count double precision NOT NULL,
    ref_store_count double precision NOT NULL,
    ref_avg_cc_count double precision NOT NULL,
    ref_max_cc_count double precision NOT NULL,
    ref_min_cc_count double precision NOT NULL,
    ref_strcntwk double precision NOT NULL,
    ref_distinct_cc_count double precision NOT NULL,
    ref_funded_receipt_start_boh_u double precision NOT NULL,
    ref_funded_sales_start_boh_u double precision NOT NULL,
    ref_funded_receipt_start_rec_u double precision NOT NULL,
    ref_receipt_start_sls_u double precision NOT NULL,
    ref_ttl_store_count double precision NOT NULL,
    weekcount double precision NOT NULL
);


--
-- Name: actuals_wide; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.actuals_wide (
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_cc_count double precision NOT NULL,
    strcntwk double precision NOT NULL,
    sales_start_boh_u double precision NOT NULL,
    receipt_start_boh_u double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_r double precision NOT NULL,
    rec_c double precision NOT NULL,
    gross_sales_u double precision NOT NULL,
    gross_sales_tktp double precision NOT NULL,
    gross_sales_r double precision NOT NULL,
    funded_cc_count double precision NOT NULL,
    ref_store_count double precision NOT NULL,
    ref_avg_cc_count double precision NOT NULL,
    ref_max_cc_count double precision NOT NULL,
    ref_min_cc_count double precision NOT NULL,
    ref_strcntwk double precision NOT NULL,
    ref_distinct_cc_count double precision NOT NULL,
    ref_funded_receipt_start_boh_u double precision NOT NULL,
    ref_funded_sales_start_boh_u double precision NOT NULL,
    ref_funded_receipt_start_rec_u double precision NOT NULL,
    ref_receipt_start_sls_u double precision NOT NULL,
    ref_ttl_store_count double precision NOT NULL,
    weekcount double precision NOT NULL
);


--
-- Name: dimensions; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.dimensions (
    dimension text NOT NULL,
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    levelid text NOT NULL,
    indx integer
);


--
-- Name: hierarchies; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.hierarchies (
    dimension text NOT NULL,
    hierarchy text NOT NULL,
    id text NOT NULL,
    ancestor text NOT NULL
);


--
-- Name: location_denorm; Type: VIEW; Schema: target_setting; Owner: -
--

CREATE VIEW target_setting.location_denorm AS
 SELECT channel.id AS channel,
    selling_channel.id AS selling_channel,
    grade.id AS grade
   FROM ((( SELECT dimensions.id
           FROM target_setting.dimensions
          WHERE ((dimensions.dimension = 'location'::text) AND (dimensions.levelid = 'grade'::text))) grade
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = grade.id) AND (hierarchies.hierarchy = 'locstd'::text))) selling_channel ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = selling_channel.id) AND (hierarchies.hierarchy = 'locstd'::text))) channel ON (true));


--
-- Name: product_denorm; Type: VIEW; Schema: target_setting; Owner: -
--

CREATE VIEW target_setting.product_denorm AS
 SELECT prodrootlevel.id AS prodrootlevel,
    division.id AS division,
    department.id AS department,
    class.id AS class
   FROM (((( SELECT dimensions.id
           FROM target_setting.dimensions
          WHERE ((dimensions.dimension = 'product'::text) AND (dimensions.levelid = 'class'::text))) class
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = class.id) AND (hierarchies.hierarchy = 'prodstd'::text))) department ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = department.id) AND (hierarchies.hierarchy = 'prodstd'::text))) division ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = division.id) AND (hierarchies.hierarchy = 'prodstd'::text))) prodrootlevel ON (true));


--
-- Name: time_denorm; Type: VIEW; Schema: target_setting; Owner: -
--

CREATE VIEW target_setting.time_denorm AS
 SELECT timerootlevel.id AS timerootlevel,
    fiscal_year.id AS fiscal_year,
    quarter.id AS quarter,
    floorset_uda.id AS floorset_uda
   FROM (((( SELECT dimensions.id
           FROM target_setting.dimensions
          WHERE ((dimensions.dimension = 'time'::text) AND (dimensions.levelid = 'floorset_uda'::text))) floorset_uda
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = floorset_uda.id) AND (hierarchies.hierarchy = 'timestd'::text))) quarter ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = quarter.id) AND (hierarchies.hierarchy = 'timestd'::text))) fiscal_year ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = fiscal_year.id) AND (hierarchies.hierarchy = 'timestd'::text))) timerootlevel ON (true));


--
-- Name: actuals_wide_denorm; Type: MATERIALIZED VIEW; Schema: target_setting; Owner: -
--

CREATE MATERIALIZED VIEW target_setting.actuals_wide_denorm AS
 SELECT DISTINCT ON (wide."time", wide.product, wide.location) "time".floorset_uda AS time_floorset_uda,
    "time".quarter AS time_quarter,
    product.class AS product_class,
    product.department AS product_department,
    location.grade AS location_grade,
    location.channel AS location_channel,
    wide."time",
    wide.product,
    wide.location,
    wide.ttl_cc_count,
    wide.strcntwk,
    wide.sales_start_boh_u,
    wide.receipt_start_boh_u,
    wide.rec_u,
    wide.rec_r,
    wide.rec_c,
    wide.gross_sales_u,
    wide.gross_sales_tktp,
    wide.gross_sales_r,
    wide.funded_cc_count,
    wide.ref_store_count,
    wide.ref_avg_cc_count,
    wide.ref_max_cc_count,
    wide.ref_min_cc_count,
    wide.ref_strcntwk,
    wide.ref_distinct_cc_count,
    wide.ref_funded_receipt_start_boh_u,
    wide.ref_funded_sales_start_boh_u,
    wide.ref_funded_receipt_start_rec_u,
    wide.ref_receipt_start_sls_u,
    wide.ref_ttl_store_count,
    wide.weekcount
   FROM (((target_setting.actuals_wide wide
     JOIN ( SELECT time_denorm.floorset_uda,
            time_denorm.quarter
           FROM target_setting.time_denorm) "time" ON (("time".floorset_uda = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department
           FROM target_setting.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.grade,
            location_denorm.channel
           FROM target_setting.location_denorm) location ON ((location.grade = wide.location)))
  WITH NO DATA;


--
-- Name: comments; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.comments (
    comment_id uuid NOT NULL,
    author text NOT NULL,
    plan_id integer NOT NULL,
    view_context text NOT NULL,
    view_template_id text NOT NULL,
    content text NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: currency_exchange_rates; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.currency_exchange_rates (
    "time" text NOT NULL,
    location text NOT NULL,
    exchange_ratio double precision NOT NULL,
    currency_id text DEFAULT 'MISSING'::text NOT NULL
);


--
-- Name: dimensions_done_prev; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.dimensions_done_prev (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies_done_prev; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.hierarchies_done_prev (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: metadata; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.metadata (
    key text NOT NULL,
    as_int bigint,
    as_string text,
    as_member_id text,
    as_timestamp timestamp with time zone,
    as_member_id_arr text[]
);


--
-- Name: paired_dimension_links; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.paired_dimension_links (
    source_dimension text NOT NULL,
    target_dimension text NOT NULL,
    source_id text NOT NULL,
    target_id text NOT NULL
);


--
-- Name: plan_archives; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plan_archives (
    id integer NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    archived_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL
);


--
-- Name: plan_audit_log; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plan_audit_log (
    plan text NOT NULL,
    action text NOT NULL,
    action_by text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: plan_data_wide; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plan_data_wide (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_cc_count double precision NOT NULL,
    strcntwk double precision NOT NULL,
    sales_start_boh_u double precision NOT NULL,
    receipt_start_boh_u double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_r double precision NOT NULL,
    rec_c double precision NOT NULL,
    gross_sales_u double precision NOT NULL,
    gross_sales_tktp double precision NOT NULL,
    gross_sales_r double precision NOT NULL,
    funded_cc_count double precision NOT NULL,
    ref_store_count double precision NOT NULL,
    ref_avg_cc_count double precision NOT NULL,
    ref_max_cc_count double precision NOT NULL,
    ref_min_cc_count double precision NOT NULL,
    ref_strcntwk double precision NOT NULL,
    ref_distinct_cc_count double precision NOT NULL,
    ref_funded_receipt_start_boh_u double precision NOT NULL,
    ref_funded_sales_start_boh_u double precision NOT NULL,
    ref_funded_receipt_start_rec_u double precision NOT NULL,
    ref_receipt_start_sls_u double precision NOT NULL,
    ref_ttl_store_count double precision NOT NULL,
    weekcount double precision NOT NULL
);


--
-- Name: plan_data_wide_archives; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plan_data_wide_archives (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_cc_count double precision NOT NULL,
    strcntwk double precision NOT NULL,
    sales_start_boh_u double precision NOT NULL,
    receipt_start_boh_u double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_r double precision NOT NULL,
    rec_c double precision NOT NULL,
    gross_sales_u double precision NOT NULL,
    gross_sales_tktp double precision NOT NULL,
    gross_sales_r double precision NOT NULL,
    funded_cc_count double precision NOT NULL,
    ref_store_count double precision NOT NULL,
    ref_avg_cc_count double precision NOT NULL,
    ref_max_cc_count double precision NOT NULL,
    ref_min_cc_count double precision NOT NULL,
    ref_strcntwk double precision NOT NULL,
    ref_distinct_cc_count double precision NOT NULL,
    ref_funded_receipt_start_boh_u double precision NOT NULL,
    ref_funded_sales_start_boh_u double precision NOT NULL,
    ref_funded_receipt_start_rec_u double precision NOT NULL,
    ref_receipt_start_sls_u double precision NOT NULL,
    ref_ttl_store_count double precision NOT NULL,
    weekcount double precision NOT NULL
);


--
-- Name: plan_id_ticker; Type: SEQUENCE; Schema: target_setting; Owner: -
--

CREATE SEQUENCE target_setting.plan_id_ticker
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plan_init_status; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plan_init_status (
    id integer NOT NULL,
    seeded_at timestamp with time zone,
    balanced_at timestamp with time zone
);


--
-- Name: plans; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.plans (
    id integer DEFAULT nextval('target_setting.plan_id_ticker'::regclass) NOT NULL,
    name text DEFAULT 'unnamed'::text NOT NULL,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    owned_by text DEFAULT 'system'::text NOT NULL,
    authored_by text NOT NULL,
    modified_by text,
    created_from integer,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    module text NOT NULL
);


--
-- Name: prev_dimensions; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.prev_dimensions (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: prev_hierarchies; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.prev_hierarchies (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: prev_tyly; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.prev_tyly (
    ty text,
    ly text
);


--
-- Name: sys_gen_wide; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.sys_gen_wide (
    sys_version text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_cc_count double precision,
    strcntwk double precision,
    sales_start_boh_u double precision,
    receipt_start_boh_u double precision,
    rec_u double precision,
    rec_r double precision,
    rec_c double precision,
    gross_sales_u double precision,
    gross_sales_tktp double precision,
    gross_sales_r double precision,
    funded_cc_count double precision,
    ref_store_count double precision,
    ref_avg_cc_count double precision,
    ref_max_cc_count double precision,
    ref_min_cc_count double precision,
    ref_strcntwk double precision,
    ref_distinct_cc_count double precision,
    ref_funded_receipt_start_boh_u double precision,
    ref_funded_sales_start_boh_u double precision,
    ref_funded_receipt_start_rec_u double precision,
    ref_receipt_start_sls_u double precision,
    ref_ttl_store_count double precision,
    weekcount double precision
);


--
-- Name: sys_gen_wide_denorm; Type: MATERIALIZED VIEW; Schema: target_setting; Owner: -
--

CREATE MATERIALIZED VIEW target_setting.sys_gen_wide_denorm AS
 SELECT wide.sys_version,
    "time".floorset_uda AS time_floorset_uda,
    "time".quarter AS time_quarter,
    product.class AS product_class,
    product.department AS product_department,
    location.grade AS location_grade,
    location.channel AS location_channel,
    wide."time",
    wide.product,
    wide.location,
    wide.ttl_cc_count,
    wide.strcntwk,
    wide.sales_start_boh_u,
    wide.receipt_start_boh_u,
    wide.rec_u,
    wide.rec_r,
    wide.rec_c,
    wide.gross_sales_u,
    wide.gross_sales_tktp,
    wide.gross_sales_r,
    wide.funded_cc_count,
    wide.ref_store_count,
    wide.ref_avg_cc_count,
    wide.ref_max_cc_count,
    wide.ref_min_cc_count,
    wide.ref_strcntwk,
    wide.ref_distinct_cc_count,
    wide.ref_funded_receipt_start_boh_u,
    wide.ref_funded_sales_start_boh_u,
    wide.ref_funded_receipt_start_rec_u,
    wide.ref_receipt_start_sls_u,
    wide.ref_ttl_store_count,
    wide.weekcount
   FROM (((target_setting.sys_gen_wide wide
     JOIN ( SELECT time_denorm.floorset_uda,
            time_denorm.quarter
           FROM target_setting.time_denorm) "time" ON (("time".floorset_uda = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department
           FROM target_setting.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.grade,
            location_denorm.channel
           FROM target_setting.location_denorm) location ON ((location.grade = wide.location)))
  WITH NO DATA;


--
-- Name: tyly; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.tyly (
    ty text NOT NULL,
    ly text NOT NULL
);


--
-- Name: tyly_done_prev; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.tyly_done_prev (
    ty text,
    ly text
);


--
-- Name: user_kv_store; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.user_kv_store (
    uid text NOT NULL,
    key text NOT NULL,
    value text
);


--
-- Name: view_target_plan_wide; Type: VIEW; Schema: target_setting; Owner: -
--

CREATE VIEW target_setting.view_target_plan_wide AS
 WITH latest_plans AS (
         SELECT t.id,
            t.product,
            t."time"
           FROM ( SELECT plans.id,
                    plans.product,
                    plans."time",
                    plans.version,
                    plans.created_at,
                    row_number() OVER (PARTITION BY plans.version, plans."time" ORDER BY plans.created_at DESC) AS rn
                   FROM target_setting.plans
                  WHERE (plans.version = ANY (ARRAY['op'::text, 'rp'::text]))) t
          WHERE (t.rn = 1)
        )
 SELECT d.product,
    d.product AS tgt_product,
    d."time" AS tgt_time,
    d.location AS final_cluster,
    d.strcntwk,
    d.gross_sales_u,
    d.gross_sales_tktp,
    d.gross_sales_r,
    d.funded_cc_count,
    d.rec_u,
    d.rec_r,
    d.rec_c,
    d.receipt_start_boh_u,
    d.sales_start_boh_u,
    d.ref_receipt_start_sls_u,
    d.weekcount,
    lp.product AS department,
    lp."time" AS superset
   FROM (target_setting.plan_data_wide d
     JOIN latest_plans lp ON ((d.id = lp.id)));


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (comment_id);


--
-- Name: dimensions dimension_levelid_indx_unique; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.dimensions
    ADD CONSTRAINT dimension_levelid_indx_unique UNIQUE (dimension, levelid, indx);


--
-- Name: dimensions dimensions_pk; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.dimensions
    ADD CONSTRAINT dimensions_pk PRIMARY KEY (id);


--
-- Name: hierarchies hierarchies_unq; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.hierarchies
    ADD CONSTRAINT hierarchies_unq UNIQUE (dimension, hierarchy, id, ancestor);


--
-- Name: metadata metadata_pk; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.metadata
    ADD CONSTRAINT metadata_pk PRIMARY KEY (key);


--
-- Name: plan_init_status plan_init_status_pkey; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.plan_init_status
    ADD CONSTRAINT plan_init_status_pkey PRIMARY KEY (id);


--
-- Name: plans plans_unique; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.plans
    ADD CONSTRAINT plans_unique UNIQUE (name, module, version, owned_by, "time", product, location, prodlife);


--
-- Name: plans plans_unique_id; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.plans
    ADD CONSTRAINT plans_unique_id UNIQUE (id);


--
-- Name: tyly tyly_uniq; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.tyly
    ADD CONSTRAINT tyly_uniq UNIQUE (ty, ly);


--
-- Name: user_kv_store user_kv_store_pkey; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.user_kv_store
    ADD CONSTRAINT user_kv_store_pkey PRIMARY KEY (uid, key);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (comment_id);


--
-- Name: dimensions dimension_levelid_indx_unique; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.dimensions
    ADD CONSTRAINT dimension_levelid_indx_unique UNIQUE (dimension, levelid, indx);


--
-- Name: dimensions dimensions_pk; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.dimensions
    ADD CONSTRAINT dimensions_pk PRIMARY KEY (id);


--
-- Name: hierarchies hierarchies_unq; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.hierarchies
    ADD CONSTRAINT hierarchies_unq UNIQUE (dimension, hierarchy, id, ancestor);


--
-- Name: metadata metadata_pk; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.metadata
    ADD CONSTRAINT metadata_pk PRIMARY KEY (key);


--
-- Name: plan_init_status plan_init_status_pkey; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.plan_init_status
    ADD CONSTRAINT plan_init_status_pkey PRIMARY KEY (id);


--
-- Name: plans plans_unique; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.plans
    ADD CONSTRAINT plans_unique UNIQUE (name, module, version, owned_by, "time", product, location, prodlife);


--
-- Name: plans plans_unique_id; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.plans
    ADD CONSTRAINT plans_unique_id UNIQUE (id);


--
-- Name: tyly tyly_uniq; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.tyly
    ADD CONSTRAINT tyly_uniq UNIQUE (ty, ly);


--
-- Name: user_kv_store user_kv_store_pkey; Type: CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.user_kv_store
    ADD CONSTRAINT user_kv_store_pkey PRIMARY KEY (uid, key);


--
-- Name: agent_conversations_log agent_conversations_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations_log
    ADD CONSTRAINT agent_conversations_log_pkey PRIMARY KEY (message_id);


--
-- Name: agent_conversations agent_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_pkey PRIMARY KEY (conversation_id);


--
-- Name: allocation_plan_queue allocation_plan_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allocation_plan_queue
    ADD CONSTRAINT allocation_plan_queue_pkey PRIMARY KEY (jobid);


--
-- Name: assort_period_from_dpt assort_period_from_dpt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assort_period_from_dpt
    ADD CONSTRAINT assort_period_from_dpt_pkey PRIMARY KEY (department, "time");


--
-- Name: cart_queue cart_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_queue
    ADD CONSTRAINT cart_queue_pkey PRIMARY KEY (cart_id);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: dev_session dev_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dev_session
    ADD CONSTRAINT dev_session_pkey PRIMARY KEY (session_id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (key);


--
-- Name: from_torrid_department_default_for_flrset_merge from_torrid_department_default_for_flrset_merge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.from_torrid_department_default_for_flrset_merge
    ADD CONSTRAINT from_torrid_department_default_for_flrset_merge_pkey PRIMARY KEY (department);


--
-- Name: from_torrid_department_flrset_default_for_flrset_merge from_torrid_department_flrset_default_for_flrset_merge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.from_torrid_department_flrset_default_for_flrset_merge
    ADD CONSTRAINT from_torrid_department_flrset_default_for_flrset_merge_pkey PRIMARY KEY (floorset_id);


--
-- Name: pivot_execution pivot_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pivot_execution
    ADD CONSTRAINT pivot_execution_pkey PRIMARY KEY (pivot_session_id);


--
-- Name: trd_p_stylecolor_sysmanaged_attr_plan pk_stylecolor_sysmanaged_attr_plan; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_sysmanaged_attr_plan
    ADD CONSTRAINT pk_stylecolor_sysmanaged_attr_plan PRIMARY KEY (product, location);


--
-- Name: plan_queue plan_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_queue
    ADD CONSTRAINT plan_queue_pkey PRIMARY KEY (jobid);


--
-- Name: s5_tunableparams s5_tunableparams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s5_tunableparams
    ADD CONSTRAINT s5_tunableparams_pkey PRIMARY KEY (paramid);


--
-- Name: scope scope_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope
    ADD CONSTRAINT scope_pkey PRIMARY KEY (id);


--
-- Name: trd_p_strategy_params strategy_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_strategy_params
    ADD CONSTRAINT strategy_params_pkey PRIMARY KEY (product, location, floorset_uda);


--
-- Name: trd_a_assortment trd_a_assortment_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_a_assortment
    ADD CONSTRAINT trd_a_assortment_2_pkey PRIMARY KEY (product, "time", location, plan_type);


--
-- Name: trd_an_price_storecount_info trd_an_price_storecount_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_an_price_storecount_info
    ADD CONSTRAINT trd_an_price_storecount_info_pkey PRIMARY KEY (product, "time", channel, selling_channel);


--
-- Name: trd_authorization trd_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_authorization
    ADD CONSTRAINT trd_authorization_pkey PRIMARY KEY (roleid, authid);


--
-- Name: trd_d_cluster trd_d_cluster_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_d_cluster
    ADD CONSTRAINT trd_d_cluster_pkey PRIMARY KEY (id);


--
-- Name: trd_d_location trd_d_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_d_location
    ADD CONSTRAINT trd_d_location_pkey PRIMARY KEY (id);


--
-- Name: trd_d_prodlife trd_d_prodlife_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_d_prodlife
    ADD CONSTRAINT trd_d_prodlife_pkey PRIMARY KEY (id);


--
-- Name: trd_d_product trd_d_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_d_product
    ADD CONSTRAINT trd_d_product_pkey PRIMARY KEY (id);


--
-- Name: trd_d_time trd_d_time_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_d_time
    ADD CONSTRAINT trd_d_time_pkey PRIMARY KEY (id);


--
-- Name: trd_eohdata_stylecolor trd_eohdata_stylecolor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_eohdata_stylecolor
    ADD CONSTRAINT trd_eohdata_stylecolor_pkey PRIMARY KEY (product);


--
-- Name: trd_h_clusterstd trd_h_clusterstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_clusterstd
    ADD CONSTRAINT trd_h_clusterstd_pkey PRIMARY KEY (id);


--
-- Name: trd_h_locdc trd_h_locdc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_locdc
    ADD CONSTRAINT trd_h_locdc_pkey PRIMARY KEY (id);


--
-- Name: trd_h_locdcstd trd_h_locdcstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_locdcstd
    ADD CONSTRAINT trd_h_locdcstd_pkey PRIMARY KEY (id);


--
-- Name: trd_h_locstd trd_h_locstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_locstd
    ADD CONSTRAINT trd_h_locstd_pkey PRIMARY KEY (id);


--
-- Name: trd_h_prodlifestd trd_h_prodlifestd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_prodlifestd
    ADD CONSTRAINT trd_h_prodlifestd_pkey PRIMARY KEY (id);


--
-- Name: trd_h_prodstd_bk2024010302 trd_h_prodstd_bk2024010302_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_prodstd_bk2024010302
    ADD CONSTRAINT trd_h_prodstd_bk2024010302_pkey PRIMARY KEY (id);


--
-- Name: trd_h_prodstd trd_h_prodstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_prodstd
    ADD CONSTRAINT trd_h_prodstd_pkey PRIMARY KEY (id);


--
-- Name: trd_h_timeflrset trd_h_timeflrset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_timeflrset
    ADD CONSTRAINT trd_h_timeflrset_pkey PRIMARY KEY (id);


--
-- Name: trd_h_timestd trd_h_timestd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_h_timestd
    ADD CONSTRAINT trd_h_timestd_pkey PRIMARY KEY (id);


--
-- Name: trd_corpdisc trd_l_corpdisc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_corpdisc
    ADD CONSTRAINT trd_l_corpdisc_pkey PRIMARY KEY (department, product, location, "time", prodlife);


--
-- Name: trd_l_dclookup trd_l_dclookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_l_dclookup
    ADD CONSTRAINT trd_l_dclookup_pkey PRIMARY KEY (channel, dc);


--
-- Name: trd_l_priceeventlookup trd_l_priceeventlookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_l_priceeventlookup
    ADD CONSTRAINT trd_l_priceeventlookup_pkey PRIMARY KEY (product, location, ccpriceevent);


--
-- Name: trd_sizinglookup trd_l_sizinglookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_sizinglookup
    ADD CONSTRAINT trd_l_sizinglookup_pkey UNIQUE (sizerange, size, strselling_channel);


--
-- Name: trd_l_ssglookup trd_l_ssglookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_l_ssglookup
    ADD CONSTRAINT trd_l_ssglookup_pkey PRIMARY KEY (product, location, ssg_id);


--
-- Name: trd_l_storedclookup trd_l_storedclookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_l_storedclookup
    ADD CONSTRAINT trd_l_storedclookup_pkey PRIMARY KEY (store, dc, priority);


--
-- Name: trd_l_storelookup trd_l_storelookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_l_storelookup
    ADD CONSTRAINT trd_l_storelookup_pkey PRIMARY KEY ("time", product, id, value);


--
-- Name: trd_ma_departmentalloc_attributes trd_ma_departmentalloc_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_departmentalloc_attributes
    ADD CONSTRAINT trd_ma_departmentalloc_attributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_departmentquarter_attributes trd_ma_departmentquarter_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_departmentquarter_attributes
    ADD CONSTRAINT trd_ma_departmentquarter_attributes_pkey PRIMARY KEY (product, "time");


--
-- Name: trd_ma_departmentquarter_attributes_temporary trd_ma_departmentquarter_attributes_temporary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_departmentquarter_attributes_temporary
    ADD CONSTRAINT trd_ma_departmentquarter_attributes_temporary_pkey PRIMARY KEY (product, "time");


--
-- Name: trd_ma_dptflrsetattributes trd_ma_dptflrsetattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_dptflrsetattributes
    ADD CONSTRAINT trd_ma_dptflrsetattributes_pkey PRIMARY KEY (indx);


--
-- Name: trd_ma_imgattributes trd_ma_imgattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_imgattributes
    ADD CONSTRAINT trd_ma_imgattributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_sizeattributes trd_ma_sizeattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_sizeattributes
    ADD CONSTRAINT trd_ma_sizeattributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_specstyleattributes trd_ma_specstyleattributes_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_specstyleattributes
    ADD CONSTRAINT trd_ma_specstyleattributes_pk UNIQUE (vpn_vsn);


--
-- Name: trd_ma_specstylecolorattributes trd_ma_specstylecolorattributes_primary_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_specstylecolorattributes
    ADD CONSTRAINT trd_ma_specstylecolorattributes_primary_key UNIQUE (vpn_vsn, vpn_color);


--
-- Name: trd_ma_storeattributes trd_ma_storeattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_storeattributes
    ADD CONSTRAINT trd_ma_storeattributes_pkey PRIMARY KEY (location);


--
-- Name: trd_ma_styleattributes trd_ma_styleattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_styleattributes
    ADD CONSTRAINT trd_ma_styleattributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_stylecolor_alloc_attributes trd_ma_stylecolor_alloc_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_stylecolor_alloc_attributes
    ADD CONSTRAINT trd_ma_stylecolor_alloc_attributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_stylecolorattributes trd_ma_stylecolorattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_stylecolorattributes
    ADD CONSTRAINT trd_ma_stylecolorattributes_pkey PRIMARY KEY (product);


--
-- Name: trd_ma_stylecolorchannelattributes trd_ma_stylecolorchannelattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_stylecolorchannelattributes
    ADD CONSTRAINT trd_ma_stylecolorchannelattributes_pkey PRIMARY KEY (product, location);


--
-- Name: trd_ma_weekattributes trd_ma_weekattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_ma_weekattributes
    ADD CONSTRAINT trd_ma_weekattributes_pkey PRIMARY KEY ("time");


--
-- Name: trd_p_approvedclusters trd_p_approvedclusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_approvedclusters
    ADD CONSTRAINT trd_p_approvedclusters_pkey PRIMARY KEY (product, "time", cluster_id);


--
-- Name: trd_p_casepack trd_p_casepack_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_casepack
    ADD CONSTRAINT trd_p_casepack_pkey PRIMARY KEY (product, location, "time", case_pack_id);


--
-- Name: trd_p_channeloverride trd_p_channeloverride_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_channeloverride
    ADD CONSTRAINT trd_p_channeloverride_pkey1 PRIMARY KEY (product, location, "time");


--
-- Name: trd_p_dc_adj trd_p_dc_adj_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_dc_adj
    ADD CONSTRAINT trd_p_dc_adj_pkey PRIMARY KEY (product, location, "time");


--
-- Name: trd_p_dc_adj_size trd_p_dc_adj_size_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_dc_adj_size
    ADD CONSTRAINT trd_p_dc_adj_size_pk UNIQUE (product, location, "time");


--
-- Name: trd_p_dept_store_attr_plan trd_p_dept_store_attr_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_dept_store_attr_plan
    ADD CONSTRAINT trd_p_dept_store_attr_plan_pkey PRIMARY KEY (product, location);


--
-- Name: trd_p_itemprice trd_p_itemprice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_itemprice
    ADD CONSTRAINT trd_p_itemprice_pkey PRIMARY KEY (product, location, "time");


--
-- Name: trd_p_reassigncluster trd_p_reassigncluster_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_reassigncluster
    ADD CONSTRAINT trd_p_reassigncluster_pkey PRIMARY KEY (product, location, "time", store_cluster_id);


--
-- Name: trd_p_receditclusters trd_p_receditclusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_receditclusters
    ADD CONSTRAINT trd_p_receditclusters_pkey PRIMARY KEY (product, "time", po_id_for_clusters);


--
-- Name: trd_p_receditstores trd_p_receditstores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_receditstores
    ADD CONSTRAINT trd_p_receditstores_pkey PRIMARY KEY (product, location, "time", po_id_for_stores);


--
-- Name: trd_p_specstylecolorattributes trd_p_specstylecolorattributes_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_specstylecolorattributes
    ADD CONSTRAINT trd_p_specstylecolorattributes_pk PRIMARY KEY (product, location, cc_spec_vpn_vsn, cc_spec_vpn_color);


--
-- Name: trd_p_specstylecolorattributes trd_p_specstylecolorattributes_primary_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_specstylecolorattributes
    ADD CONSTRAINT trd_p_specstylecolorattributes_primary_key UNIQUE (cc_spec_vpn_vsn, cc_spec_vpn_color);


--
-- Name: trd_p_store_attr_plan trd_p_store_attr_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_store_attr_plan
    ADD CONSTRAINT trd_p_store_attr_plan_pkey PRIMARY KEY (location);


--
-- Name: trd_p_stylecolor_channel_alloc_params trd_p_stylecolor_channel_alloc_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_channel_alloc_params
    ADD CONSTRAINT trd_p_stylecolor_channel_alloc_params_pkey PRIMARY KEY (product, location);


--
-- Name: trd_p_stylecolor_store_alloc_params trd_p_stylecolor_store_alloc_params_okey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_store_alloc_params
    ADD CONSTRAINT trd_p_stylecolor_store_alloc_params_okey PRIMARY KEY (product, location);


--
-- Name: trd_p_stylecolor_store_eligibility trd_p_stylecolor_store_eligibility_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_store_eligibility
    ADD CONSTRAINT trd_p_stylecolor_store_eligibility_pkey PRIMARY KEY (product, location);


--
-- Name: trd_p_stylecolor_store_worklist trd_p_stylecolor_store_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_store_worklist
    ADD CONSTRAINT trd_p_stylecolor_store_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: trd_p_stylecolor_worklist trd_p_stylecolor_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolor_worklist
    ADD CONSTRAINT trd_p_stylecolor_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: trd_p_stylecolorsize_worklist trd_p_stylecolorsize_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_stylecolorsize_worklist
    ADD CONSTRAINT trd_p_stylecolorsize_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: trd_p_target_include_exclude trd_p_target_include_exclude_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_p_target_include_exclude
    ADD CONSTRAINT trd_p_target_include_exclude_pkey PRIMARY KEY (product, "time", ly_lly_key);


--
-- Name: trd_roledimension trd_roledimension_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_roledimension
    ADD CONSTRAINT trd_roledimension_pkey PRIMARY KEY (tenantid, roleid, dimensionid);


--
-- Name: trd_specimages trd_specimages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trd_specimages
    ADD CONSTRAINT trd_specimages_pkey PRIMARY KEY (product);


--
-- Name: favorites triplet; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT triplet UNIQUE (user_id, module, favorite_name);


--
-- Name: undo_log undo_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_log
    ADD CONSTRAINT undo_log_pkey PRIMARY KEY (undo_id);


--
-- Name: user_metadata user_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_metadata
    ADD CONSTRAINT user_metadata_pkey PRIMARY KEY (uid);


--
-- Name: user_tbl user_tbl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tbl
    ADD CONSTRAINT user_tbl_pkey PRIMARY KEY (tenantid, id);


--
-- Name: user_worklist user_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_worklist
    ADD CONSTRAINT user_worklist_pkey PRIMARY KEY (user_id, product);


--
-- Name: worklist_map worklist_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_map
    ADD CONSTRAINT worklist_map_pkey PRIMARY KEY (worklist_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (comment_id);


--
-- Name: dimensions dimension_levelid_indx_unique; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.dimensions
    ADD CONSTRAINT dimension_levelid_indx_unique UNIQUE (dimension, levelid, indx);


--
-- Name: dimensions dimensions_pk; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.dimensions
    ADD CONSTRAINT dimensions_pk PRIMARY KEY (id);


--
-- Name: hierarchies hierarchies_unq; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.hierarchies
    ADD CONSTRAINT hierarchies_unq UNIQUE (dimension, hierarchy, id, ancestor);


--
-- Name: metadata metadata_pk; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.metadata
    ADD CONSTRAINT metadata_pk PRIMARY KEY (key);


--
-- Name: plan_init_status plan_init_status_pkey; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.plan_init_status
    ADD CONSTRAINT plan_init_status_pkey PRIMARY KEY (id);


--
-- Name: plans plans_unique; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.plans
    ADD CONSTRAINT plans_unique UNIQUE (name, module, version, owned_by, "time", product, location);


--
-- Name: plans plans_unique_id; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.plans
    ADD CONSTRAINT plans_unique_id UNIQUE (id);


--
-- Name: tyly tyly_uniq; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.tyly
    ADD CONSTRAINT tyly_uniq UNIQUE (ty, ly);


--
-- Name: user_kv_store user_kv_store_pkey; Type: CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.user_kv_store
    ADD CONSTRAINT user_kv_store_pkey PRIMARY KEY (uid, key);


--
-- Name: actuals_wide_denorm_bottom_up; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX actuals_wide_denorm_bottom_up ON mfp.actuals_wide_denorm USING btree (time_year, product_department, location_channel, prodlife_prodliferootlevel);


--
-- Name: actuals_wide_denorm_middle_out; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX actuals_wide_denorm_middle_out ON mfp.actuals_wide_denorm USING btree (time_year, product_total_brand, location_channel, prodlife_prodliferootlevel);


--
-- Name: actuals_wide_denorm_unique_concurrent; Type: INDEX; Schema: mfp; Owner: -
--

CREATE UNIQUE INDEX actuals_wide_denorm_unique_concurrent ON mfp.actuals_wide_denorm USING btree ("time", product, location, prodlife);


--
-- Name: actuals_wide_dimensions_idx; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX actuals_wide_dimensions_idx ON mfp.actuals_wide USING btree ("time", product, location, prodlife);


--
-- Name: plan_data_wide_id_idx; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX plan_data_wide_id_idx ON mfp.plan_data_wide USING hash (id);


--
-- Name: sys_gen_wide_denorm_bottom_up; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_bottom_up ON mfp.sys_gen_wide_denorm USING btree (time_year, product_department, location_channel, prodlife_prodliferootlevel);


--
-- Name: sys_gen_wide_denorm_middle_out; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_middle_out ON mfp.sys_gen_wide_denorm USING btree (time_year, product_total_brand, location_channel, prodlife_prodliferootlevel);


--
-- Name: actuals_wide_denorm_top_down; Type: INDEX; Schema: mfp_td; Owner: -
--

CREATE INDEX actuals_wide_denorm_top_down ON mfp_td.actuals_wide_denorm USING btree (time_year, product_total_brand, location_channel, prodlife_prodliferootlevel);


--
-- Name: actuals_wide_denorm_unique_concurrent; Type: INDEX; Schema: mfp_td; Owner: -
--

CREATE UNIQUE INDEX actuals_wide_denorm_unique_concurrent ON mfp_td.actuals_wide_denorm USING btree ("time", product, location, prodlife);


--
-- Name: actuals_wide_dimensions_idx; Type: INDEX; Schema: mfp_td; Owner: -
--

CREATE INDEX actuals_wide_dimensions_idx ON mfp_td.actuals_wide USING btree ("time", product, location, prodlife);


--
-- Name: plan_data_wide_id_idx; Type: INDEX; Schema: mfp_td; Owner: -
--

CREATE INDEX plan_data_wide_id_idx ON mfp_td.plan_data_wide USING hash (id);


--
-- Name: sys_gen_wide_denorm_top_down; Type: INDEX; Schema: mfp_td; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_top_down ON mfp_td.sys_gen_wide_denorm USING btree (time_year, product_total_brand, location_channel, prodlife_prodliferootlevel);


--
-- Name: idx_s5_actual_initrcptwk_archives_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_s5_actual_initrcptwk_archives_product ON public.s5_actual_initrcptwk_archives USING btree (product);


--
-- Name: idx_s5_actual_initrcptwk_archives_product_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_s5_actual_initrcptwk_archives_product_updated_at ON public.s5_actual_initrcptwk_archives USING btree (product, updated_at);


--
-- Name: idx_s5_actual_initrcptwk_update_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_s5_actual_initrcptwk_update_product ON public.s5_actual_initrcptwk_update USING btree (product);


--
-- Name: idx_sizeeligibility_range_member_store; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sizeeligibility_range_member_store ON public.trd_l_sizeeligibility_with_ccrangecode USING btree (size_range_id, size_member_id) WHERE (store_ineligible = 1);


--
-- Name: idx_sizeeligibility_range_member_web; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sizeeligibility_range_member_web ON public.trd_l_sizeeligibility_with_ccrangecode USING btree (size_range_id, size_member_id) WHERE (web_ineligible = 1);


--
-- Name: idx_trd_l_sizeeligibility_ccrangecode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trd_l_sizeeligibility_ccrangecode ON public.trd_l_sizeeligibility_with_ccrangecode USING btree (ccrangecode);


--
-- Name: idx_trd_style_merge_reparent_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trd_style_merge_reparent_session ON public.trd_style_merge_reparent USING btree (session_id);


--
-- Name: idx_trd_style_split_archives_tbl_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trd_style_split_archives_tbl_session ON public.trd_style_split_archives_tbl USING btree (session_id);


--
-- Name: idx_trd_style_split_stage_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trd_style_split_stage_session ON public.trd_style_split_stage USING btree (session_id);


--
-- Name: ldl_lookuptarget; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ldl_lookuptarget ON public.trd_l_dependencylookup USING btree (lookup_id, lookup_value, target_id);


--
-- Name: trd_locstd_ances0_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_locstd_ances0_str_indx ON public.trd_h_locstd USING btree (ancestor0);


--
-- Name: trd_locstd_ances1_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_locstd_ances1_str_indx ON public.trd_h_locstd USING btree (ancestor1);


--
-- Name: trd_locstd_ances2_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_locstd_ances2_str_indx ON public.trd_h_locstd USING btree (ancestor2);


--
-- Name: trd_locstd_ances3_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_locstd_ances3_str_indx ON public.trd_h_locstd USING btree (ancestor3);


--
-- Name: trd_plan_these_cloned_style_stylecolors_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_plan_these_cloned_style_stylecolors_session_id_idx ON public.trd_plan_these_cloned_style_stylecolors USING btree (session_id);


--
-- Name: trd_prodstd_ances0_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances0_indx ON public.trd_h_prodstd USING btree (ancestor0);


--
-- Name: trd_prodstd_ances1_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances1_indx ON public.trd_h_prodstd USING btree (ancestor1);


--
-- Name: trd_prodstd_ances2_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances2_indx ON public.trd_h_prodstd USING btree (ancestor2);


--
-- Name: trd_prodstd_ances3_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances3_indx ON public.trd_h_prodstd USING btree (ancestor3);


--
-- Name: trd_prodstd_ances4_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances4_indx ON public.trd_h_prodstd USING btree (ancestor4);


--
-- Name: trd_prodstd_ances5_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances5_indx ON public.trd_h_prodstd USING btree (ancestor5);


--
-- Name: trd_prodstd_ances6_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_prodstd_ances6_indx ON public.trd_h_prodstd USING btree (ancestor6);


--
-- Name: trd_product_levelid_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_product_levelid_indx ON public.trd_d_product USING btree (levelid);


--
-- Name: trd_style_clone_stylecolor_size_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trd_style_clone_stylecolor_size_session_id_idx ON public.trd_style_clone_stylecolor_size USING btree (session_id);


--
-- Name: triplet_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX triplet_index ON public.favorites USING btree (user_id, module, favorite_name);


--
-- Name: tyly_ty; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tyly_ty ON public.tyly USING btree (ty);


--
-- Name: actuals_wide_denorm_target_setting; Type: INDEX; Schema: target_setting; Owner: -
--

CREATE INDEX actuals_wide_denorm_target_setting ON target_setting.actuals_wide_denorm USING btree (time_quarter, product_department, location_channel);


--
-- Name: actuals_wide_denorm_unique_concurrent; Type: INDEX; Schema: target_setting; Owner: -
--

CREATE UNIQUE INDEX actuals_wide_denorm_unique_concurrent ON target_setting.actuals_wide_denorm USING btree ("time", product, location);


--
-- Name: actuals_wide_dimensions_idx; Type: INDEX; Schema: target_setting; Owner: -
--

CREATE INDEX actuals_wide_dimensions_idx ON target_setting.actuals_wide USING btree ("time", product, location);


--
-- Name: plan_data_wide_id_idx; Type: INDEX; Schema: target_setting; Owner: -
--

CREATE INDEX plan_data_wide_id_idx ON target_setting.plan_data_wide USING hash (id);


--
-- Name: sys_gen_wide_denorm_target_setting; Type: INDEX; Schema: target_setting; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_target_setting ON target_setting.sys_gen_wide_denorm USING btree (time_quarter, product_department, location_channel);


--
-- Name: trd_ma_stylecolorchannelattributes ca_1_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ca_1_trigger_on_update AFTER UPDATE OF dbt_wk, relaunchweek, exitdate ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((COALESCE(new.relaunchweek, new.dbt_wk) < new.erlstmkdnwk) AND (new.erlstmkdnwk < new.exitdate) AND (new.exitdate > new.erlstmkdnwk) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.store_eligibility_trigger();


--
-- Name: trd_ma_stylecolorchannelattributes dbt_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dbt_trigger_on_update AFTER UPDATE OF dbt_wk ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((new.dbt_wk >= new.erlstmkdnwk) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.dbt_after_md_trigger_on_update_validity_check();


--
-- Name: trd_ma_stylecolorchannelattributes exit_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER exit_trigger_on_update AFTER UPDATE OF exitdate ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((((new.relaunchweek IS NULL) AND (new.exitdate <= new.erlstmkdnwk)) OR ((new.relaunchweek IS NOT NULL) AND (new.exitdate <= new.erlstmkdnwk))) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.exit_trigger_on_update_validity_check();


--
-- Name: trd_ma_stylecolorchannelattributes md_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER md_trigger_on_update AFTER UPDATE OF erlstmkdnwk ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((((new.relaunchweek IS NULL) AND ((new.erlstmkdnwk <= new.dbt_wk) OR (new.exitdate <= new.erlstmkdnwk))) OR ((new.relaunchweek IS NOT NULL) AND ((new.erlstmkdnwk <= new.relaunchweek) OR (new.exitdate <= new.erlstmkdnwk)))) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.md_trigger_on_update_validity_check();


--
-- Name: pivot_execution on_pivot_execution_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_pivot_execution_change AFTER INSERT OR DELETE OR UPDATE ON public.pivot_execution FOR EACH STATEMENT EXECUTE FUNCTION public.notify_pivot_execution_change();


--
-- Name: plan_queue on_plan_queue_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_plan_queue_change AFTER INSERT OR DELETE OR UPDATE ON public.plan_queue FOR EACH STATEMENT EXECUTE FUNCTION public.notify_plan_queue_change();


--
-- Name: trd_p_stylecolor_worklist on_publish_remove_from_worklist_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_publish_remove_from_worklist_trigger AFTER UPDATE ON public.trd_p_stylecolor_worklist FOR EACH ROW WHEN (((new.in_worklist = (1)::double precision) AND (old.in_worklist = (0)::double precision))) EXECUTE FUNCTION public.on_publish_remove_from_worklist();

ALTER TABLE public.trd_p_stylecolor_worklist DISABLE TRIGGER on_publish_remove_from_worklist_trigger;


--
-- Name: trd_p_stylecolor_worklist on_publish_remove_from_worklist_trigger_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_publish_remove_from_worklist_trigger_insert AFTER INSERT ON public.trd_p_stylecolor_worklist FOR EACH ROW WHEN ((new.in_worklist = (1)::double precision)) EXECUTE FUNCTION public.on_publish_remove_from_worklist();

ALTER TABLE public.trd_p_stylecolor_worklist DISABLE TRIGGER on_publish_remove_from_worklist_trigger_insert;


--
-- Name: trd_p_stylecolor_worklist on_unpublish_remove_from_worklist_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_unpublish_remove_from_worklist_trigger AFTER UPDATE ON public.trd_p_stylecolor_worklist FOR EACH ROW WHEN (((new.in_worklist = (0)::double precision) AND (old.in_worklist = (1)::double precision))) EXECUTE FUNCTION public.on_unpublish_remove_from_worklist();

ALTER TABLE public.trd_p_stylecolor_worklist DISABLE TRIGGER on_unpublish_remove_from_worklist_trigger;


--
-- Name: trd_p_dc_adj_size set_dc_ttluseradj_p_dc_adj_size; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_dc_ttluseradj_p_dc_adj_size BEFORE INSERT OR UPDATE ON public.trd_p_dc_adj_size FOR EACH ROW EXECUTE FUNCTION public.trigger_set_dc_ttl_useradj();


--
-- Name: trd_v_memberbasedvalidvalues set_mvv_indx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_mvv_indx BEFORE INSERT ON public.trd_v_memberbasedvalidvalues FOR EACH ROW EXECUTE FUNCTION public.trigger_set_indx_valid_values();


--
-- Name: trd_p_dc_adj set_pack_ind_flag; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_pack_ind_flag BEFORE INSERT OR UPDATE OF reason_code ON public.trd_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_pack_ind_flag();


--
-- Name: trd_a_assortment set_timestamp_a_assortment; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_a_assortment BEFORE UPDATE ON public.trd_a_assortment FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_p_casepack set_timestamp_cp_publish; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_cp_publish BEFORE UPDATE OF po_status ON public.trd_p_casepack FOR EACH ROW EXECUTE FUNCTION public.trigger_set_cp_publish_timestamp();


--
-- Name: trd_p_casepack set_timestamp_cp_publish_ins; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_cp_publish_ins BEFORE INSERT ON public.trd_p_casepack FOR EACH ROW EXECUTE FUNCTION public.trigger_set_cp_publish_timestamp();


--
-- Name: trd_p_channeloverride set_timestamp_p_channeloverride; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_channeloverride BEFORE UPDATE ON public.trd_p_channeloverride FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_p_dc_adj set_timestamp_p_dc_adj; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_adj BEFORE UPDATE ON public.trd_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_p_dc_adj_size set_timestamp_p_dc_adj_size; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_adj_size BEFORE UPDATE ON public.trd_p_dc_adj_size FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_p_dc_adj set_timestamp_p_dc_publish_adj; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_publish_adj BEFORE UPDATE OF dc_publish ON public.trd_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_publish_timestamp();


--
-- Name: trd_p_dc_adj set_timestamp_p_dc_publish_adj_ins; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_publish_adj_ins BEFORE INSERT ON public.trd_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_publish_timestamp();


--
-- Name: trd_ma_sizeattributes set_timestamp_sizeattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_sizeattr BEFORE UPDATE ON public.trd_ma_sizeattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_ma_styleattributes set_timestamp_styleattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_styleattr BEFORE UPDATE ON public.trd_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_ma_stylecolorchannelattributes set_timestamp_styleclrchannel; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_styleclrchannel BEFORE UPDATE ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: trd_ma_stylecolorattributes set_timestamp_stylecolorattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_stylecolorattr BEFORE UPDATE ON public.trd_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: worklist_map trg_ai_worklist_map; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_worklist_map AFTER INSERT ON public.worklist_map FOR EACH ROW EXECUTE FUNCTION public.trg_ins_stylecolor_alloc_attrs();


--
-- Name: trd_ma_stylecolorchannelattributes trg_cc_validsizes_on_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_cc_validsizes_on_change BEFORE UPDATE OF ccrangecode, use_valid_sizes_from, cc_size_eligibility_profile ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((pg_trigger_depth() < 2)) EXECUTE FUNCTION public.update_cc_validsizes_on_ccrangecode();


--
-- Name: trd_p_strategy_params trg_p_strategy_params_set_apply_targets; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_p_strategy_params_set_apply_targets BEFORE INSERT OR UPDATE ON public.trd_p_strategy_params FOR EACH ROW EXECUTE FUNCTION public.trg_set_apply_targets_to_plan();


--
-- Name: trd_ma_stylecolorchannelattributes trg_set_floorset_fields_on_initrcptwk_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_floorset_fields_on_initrcptwk_change BEFORE INSERT OR UPDATE OF initrcptwk ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION public.set_floorset_fields_on_initrcptwk_change();


--
-- Name: trd_ma_departmentalloc_attributes trg_set_overflow_ok_when_scaling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_overflow_ok_when_scaling BEFORE UPDATE ON public.trd_ma_departmentalloc_attributes FOR EACH ROW EXECUTE FUNCTION public.trg_allow_scaling_set_overflow_ok();


--
-- Name: trd_ma_stylecolor_alloc_attributes trg_set_sclr_overflow_ok_when_scaling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_sclr_overflow_ok_when_scaling BEFORE UPDATE ON public.trd_ma_stylecolor_alloc_attributes FOR EACH ROW EXECUTE FUNCTION public.trg_sclr_allow_scaling_set_overflow_ok();


--
-- Name: trd_p_stylecolor_store_worklist trg_sync_alloc_and_override_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_sync_alloc_and_override_trigger BEFORE INSERT OR UPDATE ON public.trd_p_stylecolor_store_worklist FOR EACH ROW EXECUTE FUNCTION public.trg_sync_alloc_and_override();

ALTER TABLE public.trd_p_stylecolor_store_worklist DISABLE TRIGGER trg_sync_alloc_and_override_trigger;


--
-- Name: trd_a_assortment trg_upd_assortment_ranging; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_assortment_ranging AFTER UPDATE OF str_grade, str_store_climate, str_capacity, str_store_banner, str_geo_region, str_hazmat, ssg, str_grade_or, str_store_climate_or, str_capacity_or, str_store_banner_or, str_geo_region_or, str_hazmat_or ON public.trd_a_assortment FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION public.propagate_assortment_to_floorsets();


--
-- Name: trd_ma_stylecolorattributes trg_upd_specstylecolor; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_specstylecolor AFTER UPDATE OF cc_vpn_color ON public.trd_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_specstylecolor_id();


--
-- Name: trd_ma_styleattributes trg_upd_specstyleid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_specstyleid BEFORE UPDATE OF sty_vpn ON public.trd_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_specstyle_id();


--
-- Name: trd_p_stylecolor_store_worklist trg_update_alloc_qty; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_alloc_qty BEFORE INSERT OR UPDATE ON public.trd_p_stylecolor_store_worklist FOR EACH ROW EXECUTE FUNCTION public.trg_sum_override_array();

ALTER TABLE public.trd_p_stylecolor_store_worklist DISABLE TRIGGER trg_update_alloc_qty;


--
-- Name: trd_ma_stylecolorattributes trg_update_cc_floorset; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_cc_floorset BEFORE UPDATE OF cc_floorset ON public.trd_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_cc_use_sys_floorset();


--
-- Name: trd_p_stylecolor_store_eligibility trg_update_eligibility_from_null_to_zero; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_eligibility_from_null_to_zero AFTER UPDATE OF sclr_str_eligibility ON public.trd_p_stylecolor_store_eligibility FOR EACH ROW WHEN (((new.sclr_str_eligibility IS NULL) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.update_eligibility_from_null_to_zero();


--
-- Name: trd_ma_stylecolorattributes trig_upd_on_color_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_upd_on_color_change AFTER UPDATE OF cccolor ON public.trd_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_color_change();


--
-- Name: trd_ma_stylecolorattributes trig_upd_on_ticketprice; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_upd_on_ticketprice BEFORE UPDATE OF cc_orig_unit_retail ON public.trd_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_ticket_price();


--
-- Name: cart_params trigger_cartparams_irw_debut_offset; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_cartparams_irw_debut_offset BEFORE UPDATE OF dbt_wk ON public.cart_params FOR EACH ROW EXECUTE FUNCTION public.update_trigger_cartparams_irw_debut_offset();


--
-- Name: cart_params trigger_cartparams_ranging; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_cartparams_ranging AFTER UPDATE OF dbt_wk, exitdate ON public.cart_params FOR EACH ROW EXECUTE FUNCTION public.update_trigger_cartparams_ranging();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_cost; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_cost AFTER UPDATE OF cc_plan_cost, cc_systemcost ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_final_cost();


--
-- Name: trd_p_itemprice trigger_eff_aur; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_eff_aur AFTER INSERT OR UPDATE ON public.trd_p_itemprice FOR EACH ROW WHEN ((pg_trigger_depth() <= 1)) EXECUTE FUNCTION public.update_eff_aur();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_for_time_indx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_for_time_indx AFTER INSERT OR UPDATE OF dbt_wk, relaunchweek, erlstmkdnwk, exitdate ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.update_week_indxes();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_for_time_indx_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_for_time_indx_insert AFTER INSERT ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.update_week_indxes();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_for_time_indx_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_for_time_indx_update AFTER UPDATE OF dbt_wk, relaunchweek, erlstmkdnwk, exitdate ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((COALESCE(new.relaunchweek, new.dbt_wk) < new.erlstmkdnwk) AND (new.erlstmkdnwk < new.exitdate) AND (new.exitdate > new.erlstmkdnwk))) EXECUTE FUNCTION public.update_week_indxes();


--
-- Name: trd_p_itemprice trigger_itemprice_fetchdepartment; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_itemprice_fetchdepartment BEFORE INSERT ON public.trd_p_itemprice FOR EACH ROW EXECUTE FUNCTION public.itemprice_fetchdepartment();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_lifecycle_plan_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_lifecycle_plan_update AFTER UPDATE OF erlstmkdnwk ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.lifecycle_plan_update();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_remove_from_assortment; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_remove_from_assortment AFTER UPDATE OF record_state ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((new.record_state = 1)) EXECUTE FUNCTION public.remove_from_assortment();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_sizerangecode_isvalid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_sizerangecode_isvalid AFTER UPDATE OF validsizes ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.sizerangecode_isvalid();


--
-- Name: trd_ma_stylecolorchannelattributes trigger_sizerangecode_validsizes_members; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_sizerangecode_validsizes_members AFTER UPDATE OF ccrangecode ON public.trd_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.sizerangecode_validsizes_members();


--
-- Name: trd_d_product trigger_upd_name_description; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_name_description AFTER UPDATE OF name, description ON public.trd_d_product FOR EACH ROW WHEN ((new.levelid = 'style'::text)) EXECUTE FUNCTION public.update_name_description();


--
-- Name: trd_ma_styleattributes update_ccrangecode; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ccrangecode AFTER UPDATE OF sty_size_range ON public.trd_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_stylecolorchannelattributes_ccrangecode();


--
-- Name: trd_h_prodstd update_ccsizerange_after_class_change_ancestor1; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ccsizerange_after_class_change_ancestor1 AFTER UPDATE OF ancestor1 ON public.trd_h_prodstd FOR EACH ROW WHEN (((new.ancestor1 ~~ 'CL-%'::text) AND (new.ancestor1 IS DISTINCT FROM old.ancestor1))) EXECUTE FUNCTION public.update_ccrangecode_on_class_change();


--
-- Name: hierarchies hierarchies_ancestor_fk; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.hierarchies
    ADD CONSTRAINT hierarchies_ancestor_fk FOREIGN KEY (ancestor) REFERENCES mfp.dimensions(id);


--
-- Name: hierarchies hierarchies_id_fk; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.hierarchies
    ADD CONSTRAINT hierarchies_id_fk FOREIGN KEY (id) REFERENCES mfp.dimensions(id);


--
-- Name: tyly ly_dimension_fkey; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.tyly
    ADD CONSTRAINT ly_dimension_fkey FOREIGN KEY (ly) REFERENCES mfp.dimensions(id);


--
-- Name: comments plan_id_fkey; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.comments
    ADD CONSTRAINT plan_id_fkey FOREIGN KEY (plan_id) REFERENCES mfp.plans(id) ON DELETE CASCADE;


--
-- Name: plan_init_status plan_init_status_id_fkey; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.plan_init_status
    ADD CONSTRAINT plan_init_status_id_fkey FOREIGN KEY (id) REFERENCES mfp.plans(id);


--
-- Name: tyly ty_dimension_fkey; Type: FK CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.tyly
    ADD CONSTRAINT ty_dimension_fkey FOREIGN KEY (ty) REFERENCES mfp.dimensions(id);


--
-- Name: hierarchies hierarchies_ancestor_fk; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.hierarchies
    ADD CONSTRAINT hierarchies_ancestor_fk FOREIGN KEY (ancestor) REFERENCES mfp_td.dimensions(id);


--
-- Name: hierarchies hierarchies_id_fk; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.hierarchies
    ADD CONSTRAINT hierarchies_id_fk FOREIGN KEY (id) REFERENCES mfp_td.dimensions(id);


--
-- Name: tyly ly_dimension_fkey; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.tyly
    ADD CONSTRAINT ly_dimension_fkey FOREIGN KEY (ly) REFERENCES mfp_td.dimensions(id);


--
-- Name: comments plan_id_fkey; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.comments
    ADD CONSTRAINT plan_id_fkey FOREIGN KEY (plan_id) REFERENCES mfp_td.plans(id) ON DELETE CASCADE;


--
-- Name: plan_init_status plan_init_status_id_fkey; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.plan_init_status
    ADD CONSTRAINT plan_init_status_id_fkey FOREIGN KEY (id) REFERENCES mfp_td.plans(id);


--
-- Name: tyly ty_dimension_fkey; Type: FK CONSTRAINT; Schema: mfp_td; Owner: -
--

ALTER TABLE ONLY mfp_td.tyly
    ADD CONSTRAINT ty_dimension_fkey FOREIGN KEY (ty) REFERENCES mfp_td.dimensions(id);


--
-- Name: cart_master cart_queue_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_master
    ADD CONSTRAINT cart_queue_fkey FOREIGN KEY (jsessionid) REFERENCES public.cart_queue(cart_id);


--
-- Name: cart_params cart_queue_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_params
    ADD CONSTRAINT cart_queue_fkey FOREIGN KEY (jsessionid) REFERENCES public.cart_queue(cart_id);


--
-- Name: cart_ranging cart_queue_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_ranging
    ADD CONSTRAINT cart_queue_fkey FOREIGN KEY (jsessionid) REFERENCES public.cart_queue(cart_id);


--
-- Name: agent_conversations_log fk_agent_conversations_log_conversation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations_log
    ADD CONSTRAINT fk_agent_conversations_log_conversation_id FOREIGN KEY (conversation_id) REFERENCES public.agent_conversations(conversation_id);


--
-- Name: allocation_plan_queue_items fk_allocation_plan_queue_items_allocation_plan_queue; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allocation_plan_queue_items
    ADD CONSTRAINT fk_allocation_plan_queue_items_allocation_plan_queue FOREIGN KEY (jobid) REFERENCES public.allocation_plan_queue(jobid);


--
-- Name: undo_display fk_undo_display_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_display
    ADD CONSTRAINT fk_undo_display_id FOREIGN KEY (undo_id) REFERENCES public.undo_log(undo_id) ON DELETE CASCADE;


--
-- Name: undo_modifications fk_undo_modification_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undo_modifications
    ADD CONSTRAINT fk_undo_modification_id FOREIGN KEY (undo_id) REFERENCES public.undo_log(undo_id) ON DELETE CASCADE;


--
-- Name: cart_queue scope_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_queue
    ADD CONSTRAINT scope_id_fkey FOREIGN KEY (scope_id) REFERENCES public.scope(id);


--
-- Name: pivot_execution scope_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pivot_execution
    ADD CONSTRAINT scope_id_fkey FOREIGN KEY (scope_id) REFERENCES public.scope(id);


--
-- Name: dev_session target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dev_session
    ADD CONSTRAINT target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.user_metadata(uid);


--
-- Name: hierarchies hierarchies_ancestor_fk; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.hierarchies
    ADD CONSTRAINT hierarchies_ancestor_fk FOREIGN KEY (ancestor) REFERENCES target_setting.dimensions(id);


--
-- Name: hierarchies hierarchies_id_fk; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.hierarchies
    ADD CONSTRAINT hierarchies_id_fk FOREIGN KEY (id) REFERENCES target_setting.dimensions(id);


--
-- Name: tyly ly_dimension_fkey; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.tyly
    ADD CONSTRAINT ly_dimension_fkey FOREIGN KEY (ly) REFERENCES target_setting.dimensions(id);


--
-- Name: comments plan_id_fkey; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.comments
    ADD CONSTRAINT plan_id_fkey FOREIGN KEY (plan_id) REFERENCES target_setting.plans(id) ON DELETE CASCADE;


--
-- Name: plan_init_status plan_init_status_id_fkey; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.plan_init_status
    ADD CONSTRAINT plan_init_status_id_fkey FOREIGN KEY (id) REFERENCES target_setting.plans(id);


--
-- Name: tyly ty_dimension_fkey; Type: FK CONSTRAINT; Schema: target_setting; Owner: -
--

ALTER TABLE ONLY target_setting.tyly
    ADD CONSTRAINT ty_dimension_fkey FOREIGN KEY (ty) REFERENCES target_setting.dimensions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 1giFFTCBgsWr7eOJZkO4Gb6H3o2cHQOuq5eW9cwDaxJ2xFHJgxcU4RGdtfhug2m

