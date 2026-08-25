--
-- PostgreSQL database dump
--

\restrict ztIqJLWfQS5ccWS7DoiwNtg4zvm0cQpD7Bb1fanYG30fDAo6VxpCeDZwPFEF74k

-- Dumped from database version 14.22
-- Dumped by pg_dump version 14.24 (Ubuntu 14.24-0ubuntu0.22.04.1)

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
-- Name: debug; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA debug;


--
-- Name: mfp; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mfp;


--
-- Name: migrate; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA migrate;


--
-- Name: safe_to_delete; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA safe_to_delete;


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
s51_1a text;
s51_2 text;
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
    ,  null::text cccolorfamily
    ,  initiator
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
    from eve_h_prodstd b
    where
    b.id = a.incoming_style_id
    ';



s4_3 := '
    Update '||table_cart_master_temp||' a
    set class_name = b.name
    from eve_d_product b
    where
    b.id = a.class_id
    ';



s4_4 := '
    Update '||table_cart_master_temp||' a
    set subclass_name = b.name
    from eve_d_product b
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
    , case when stylecolor_type = ''similar'' then style_name||'':''||cccolor else stylecolor_name end as displayed_stylecolor_name
    , case when stylecolor_type = ''similar'' then style_description ||'':''||cccolor else stylecolor_description end as displayed_stylecolor_description
    , incoming_style_id
    , style_type
    , cccolor
    from
    (
    select distinct jsessionid,style_sequence, incoming_style_id,final_style_id, style_type,incoming_stylecolor_id, stylecolor_type, cccolor,
    case when strpos(cccolor, '' '') > 0 then (SUBSTR(cccolor, 1, strpos(cccolor, '' '') - 1)) else cccolor end
    as color_id
    , style_name, style_description, stylecolor_name, stylecolor_description
    from '||table_cart_master_temp||'
    where jsessionid in (select jsid from '||table_input_t1||')
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
    and a.cccolor=b.cccolor
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
    FROM   (SELECT
           a.incoming_stylecolor_id
                 , a.incoming_style_id
                 , b.product stylecolorsize_id
                 , b.sizeattribute
                 , b.parent_id
                 , a.jsessionid
                 , a.style_type
                 , a.stylecolor_type
                 , a.final_style_id
                 , a.final_stylecolor_id
          FROM   '||table_cart_master_temp||' a
                 , eve_ma_sizeattributes b
          WHERE  a.incoming_stylecolor_id = b.parent_id
          )x
          '
          ;




s8 := 'delete from eve_d_product where id in (select final_style_id from '||table_cart_style||' WHERE style_type=''similar'' and jsessionid in (select jsid from '||table_input_t1||'))';


s9 := '
    INSERT INTO eve_d_product
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
delete from eve_d_product where id in (select distinct final_stylecolor_id from '||table_cart_stylecolor||' WHERE stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';


s11 := '
    INSERT INTO eve_d_product
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
delete from eve_d_product where id in (select distinct final_stylecolorsize_id from chetan_cart_stylecolorsize WHERE stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s13 := '
    INSERT INTO eve_d_product
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
delete from eve_h_prodstd where id in (select distinct final_style_id from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';


s15 := '
INSERT INTO eve_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6)
SELECT DISTINCT
                  final_style_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
FROM   '||table_cart_master_temp||' a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 from eve_h_prodstd) b
WHERE style_type=''similar''
and a.incoming_style_id = b.id
'
;



s16 := '
delete from eve_h_prodstd where id in (select distinct final_stylecolor_id from '||table_cart_master_temp||'  where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s17 := '
INSERT INTO eve_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6)
SELECT DISTINCT
                  final_stylecolor_id
                , final_style_id
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
                , ancestor6
FROM   '||table_cart_master_temp||'   a,
(select id, ancestor0, ancestor1, ancestor2, ancestor3, ancestor4 , ancestor5 , ancestor6 from eve_h_prodstd) b
WHERE stylecolor_type=''similar''
and a.incoming_stylecolor_id = b.id
'
;



s18 := '
delete from eve_h_prodstd where id in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s19 := '
INSERT INTO eve_h_prodstd
            (id
             , ancestor0
             , ancestor1
             , ancestor2
             , ancestor3
             , ancestor4
             , ancestor5
             , ancestor6)
SELECT DISTINCT
                  final_stylecolorsize_id
                , final_stylecolor_id
                , ancestor0
                , ancestor1
                , ancestor2
                , ancestor3
                , ancestor4
                , ancestor5
FROM    '||table_cart_stylecolorsize||'  a,
eve_h_prodstd b
WHERE stylecolor_type=''similar''
and a.final_stylecolor_id = b.id
'
;

s20 := '
delete from eve_ma_styleattributes where product in (select distinct final_style_id from '||table_cart_master_temp||' WHERE style_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

-- updating cccolor and cccolorfamily

s21 := '
update '||table_cart_master_temp||' a set cccolorfamily = b.target_value from eve_l_dependencylookup b where b.lookup_id = ''cccolor'' and b.target_id=''cccolorfamily'' and lookup_value=a.cccolor
';

s22 := '
delete from eve_l_dependencylookup where target_id=''patternedtostyle'' and target_value in (select distinct final_style_id from  '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';

s23 := '
delete from eve_l_dependencylookup where target_id=''patternedtostylecolor'' and target_value in (select distinct final_stylecolor_id from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';






s24 := '
insert into eve_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''style'' as lookup_id, incoming_style_id as lookup_value, ''patternedtostyle'' target_id, final_style_id as target_value
from '||table_cart_master_temp||' where style_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||')
';


s25 := '
insert into eve_l_dependencylookup (lookup_id,lookup_value,target_id,target_value)
select distinct ''stylecolor'' as lookup_id, incoming_stylecolor_id as lookup_value, ''patternedtostylecolor'' target_id, final_stylecolor_id as target_value
from '||table_cart_master_temp||' where stylecolor_type=''similar'' and jsessionid in (select jsid from  '||table_input_t1||')
';



-- STYLE ATTRIBUTES

S26 := '
INSERT INTO eve_ma_styleattributes
            (product
            ,sty_source
            ,sty_size_run_name
            ,sty_size_run_id
            ,sty_s5_adopted
            ,sty_subclass_display
            )
SELECT final_style_id as product
            ,b.sty_source
            ,b.sty_size_run_name
            ,b.sty_size_run_id
            ,''Y''
            ,b.sty_subclass_display
from (select distinct final_style_id, style_type, incoming_style_id, class_id, subclass_id, class_name, subclass_name from '||table_cart_master_temp||') a, eve_ma_styleattributes b
where a.incoming_style_id=b.product
and a.style_type=''similar''
';

s26_X := '
Update eve_ma_styleattributes b
set pim_size_run_id = sty_size_run_id, pim_size_run_name = sty_size_run_name, sty_is_locked = ''Y'', sty_s5_adopted = ''Y''
from (select distinct final_style_id, style_type, incoming_style_id  from '||table_cart_master_temp||') a
where a.incoming_style_id=b.product
and a.style_type=''existing''
and a.incoming_style_id in (select distinct incoming_style_id from '||table_cart_master_temp||' where stylecolor_type = ''existing'')
';



-- STYLECOLOR ATTRIBUTES

s27 := '
delete from eve_ma_stylecolorattributes where product in (select distinct final_stylecolor_id from '||table_cart_master_temp||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))';



s28 := '
INSERT INTO eve_ma_stylecolorattributes
        (product
         ,cccolor
         ,cccolorfamily
         ,cc_color_code
         ,division_name
         ,department_name
         ,class_name
         ,subclass_name
         ,cc_s5_adopted
         ,cc_msrp
         ,cc_pricing_tier
         --,cc_current_price
         --,cc_estimated_cost
         --,cc_actual_cost
         ,cc_vendor_cost
         ,cc_rtv
        )
SELECT final_stylecolor_id as product
         ,a.cccolor
         ,a.cccolorfamily
         ,b.cc_color_code
         ,b.division_name
         ,b.department_name
         ,b.class_name
         ,b.subclass_name
         ,''Y''
         ,b.cc_msrp
         ,b.cc_pricing_tier
         --,b.cc_current_price
         --,b.cc_estimated_cost
         --,b.cc_actual_cost
         ,''0''
         ,''N''
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, case when strpos(cccolor, '' '') > 0 then ( SUBSTR(cccolor, 1, strpos(cccolor, '' '') - 1) ) else cccolor end as cccolorid  from '||table_cart_master_temp||') a, eve_ma_stylecolorattributes b
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''similar''
';



s28_X := '
Update eve_ma_stylecolorattributes b
set isassortment = ''true'', cc_is_locked = ''Y'', cc_s5_adopted = ''Y''
from (select distinct final_stylecolor_id, stylecolor_type, incoming_stylecolor_id, cccolor,cccolorfamily, case when strpos(cccolor, '' '') > 0 then ( SUBSTR(cccolor, 1, strpos(cccolor, '' '') - 1) ) else cccolor end as cccolorid  from '||table_cart_master_temp||') a
where a.incoming_stylecolor_id=b.product
and a.stylecolor_type=''existing''
';

--SUP-3237 update msrp using l_dependencylookup
s28_Y := '
Update eve_ma_stylecolorattributes a
--set cc_msrp = coalesce(target_value, cc_msrp) -- 20251003 reverting to original as users asked for it
set cc_msrp = cc_msrp
from (select distinct e.final_stylecolor_id, e.stylecolor_type, target_value::real as target_value
      from '||table_cart_master_temp||' e, eve_h_prodstd f, eve_l_dependencylookup g, eve_ma_styleattributes h 
      where e.final_stylecolor_id = f.id and f.ancestor1 = g.lookup_value and f.ancestor0 = h.product and h.sty_source = g.target_id
      and g.lookup_id = ''msrp''
     ) b
where a.product=b.final_stylecolor_id
and b.stylecolor_type=''similar''
';



-- IMAGE ATTRIBUTES START

s29 := 'drop table if exists '||table_ma_imgattr||'';

s29_1 := '
create temporary table '||table_spec_img||' as
select
 distinct si.product, si.img, sa.product as style_id
from eve_specimages si
 inner join
eve_ma_styleattributes sa
 on sa.pim_style_id = si.product
where sa.product in (select final_style_id from '||table_cart_master_temp||' where jsessionid in (select jsid from '||table_input_t1||'));
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
  (select distinct product, img from eve_ma_imgattributes where product in (select distinct incoming_stylecolor_id from '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||'))) b
ON
b.product=c.incoming_stylecolor_id
  LEFT JOIN
  (select distinct product, img, style_id from '||table_spec_img||') d
on
d.style_id = c.final_style_id;

'
;





s31 := '
delete from eve_ma_imgattributes where product in (
    select distinct final_stylecolor_id from  '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')
)
'
;

s32 := '
insert into eve_ma_imgattributes (product, img)
select product, coalesce(cart_image,orig_image,spec_image) from '||table_ma_imgattr||'
';




-- IMAGE ATTRIBUTES END

-- SIZE ATTRIBUTES

s33 := '
delete from eve_ma_sizeattributes where product in (select distinct final_stylecolorsize_id from '||table_cart_stylecolorsize||' WHERE stylecolor_type = ''similar'' and jsessionid in (select jsid from  '||table_input_t1||'))
';



s34 := '
insert into eve_ma_sizeattributes
    (product,
    sizeattribute,
    parent_id
    )
SELECT
    distinct final_stylecolorsize_id,
    size_name,
    final_stylecolor_id
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
  , a.ccrcptint as default_ccrcptint
  , a.ccordermultiple as default_ccordermultiple
  , a.ccordpolicy as default_ccordpolicy
  , a.slsrnk
  , default_retpct_str
  , default_retpct_ecomm

  -- CA MOD 06.15.2025
  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

from (select distinct * from cart_params) a, eve_ma_dptflrsetattributes c, '||table_input_t1||' b
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

  , coalesce(ccmdstrategy, default_ccmdstrategy) ccmdstrategy
  , coalesce(cc_ordpolicy, default_ccordpolicy) cc_ordpolicy
  , ccrangecode
  , case when (ssnprf is null or ssnprf ='''') then ''class_default'' else ssnprf end
  , cc_validsizes_store
  , cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
  , coalesce(cc_ordermultiple::int,default_ccordermultiple::int) cc_ordermultiple
  , cc_existingwac
  , cc_systemcost
  , cc_landed_cost -- needs to go into cc_target_cost

  -- CA MOD 06.15.2025 START

  -- , a.slsrnk
  , COALESCE(b.act_slsrnk, a.slsrnk) as slsrnk
  , b.act_aps_mult_adj as act_aps_mult_adj
  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  -- CA MOD 06.15.2025 END

  , null::real as cc_imupct
  , a.default_retpct_str as cc_return_u_pct_store
  , a.default_retpct_ecomm as cc_return_u_pct_ecom
  , d.cc_actual_cost::real as cc_target_cost
FROM
'||table_default_cart_params||' a, eve_ma_stylecolorchannelattributes b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||' where style_type = ''similar'') c, eve_ma_stylecolorattributes d
where b.product=c.incoming_stylecolor_id and a.jsessionid=c.jsessionid and a.scope_location=b.location and c.incoming_stylecolor_id=d.product
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

  , default_ccmdstrategy as ccmdstrategy
  , default_ccordpolicy as cc_ordpolicy
  , c.sty_size_run_name || '' - '' || class_id as ccrangecode
  , ''class_default'' ssnprf
  , e.validsizes as cc_validsizes_store
  , e.validsizes as cc_validsizes_ecom
  , default_presmin as cc_presmin
  , default_presmin_weeks as cc_presmin_weeks
  , default_ccrcptint as cc_rcptint
  , default_ccordermultiple cc_ordermultiple
  , d.cc_actual_cost::real as cc_existingwac
  , d.cc_estimated_cost::real as cc_systemcost
  , d.cc_actual_cost::real as cc_landed_cost

  -- CA MOD 06.15.2025 START

  -- , a.slsrnk
  , COALESCE(f.act_slsrnk, f.slsrnk) as slsrnk
  , f.act_aps_mult_adj as act_aps_mult_adj
  , a.use_act_aps_or_act_rank as use_act_aps_or_act_rank

  -- CA MOD 06.15.2025 END

  , round((((cc_msrp::real-coalesce(cc_actual_cost,cc_estimated_cost)::real)/cc_msrp::real)::numeric), 2)::real as cc_imupct
  , a.default_retpct_str as cc_return_u_pct_store
  , a.default_retpct_ecomm as cc_return_u_pct_ecom
  , COALESCE(d.cc_actual_cost::real, f.cc_target_cost::real)::real as cc_target_cost
FROM
'||table_default_cart_params||' a, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id, class_id, style_type from '||table_cart_master_temp||' where style_type = ''existing'') b,
eve_ma_styleattributes c,
eve_ma_stylecolorattributes d,
(select array_agg(target_value) as validsizes, lookup_value as sty_size_run_name from eve_l_dependencylookup where lookup_id = ''size_range'' group by lookup_value) e,
eve_ma_stylecolorchannelattributes f
where a.jsessionid=b.jsessionid and b.final_style_id = c.product and b.final_stylecolor_id = d.product and c.sty_size_run_name = e.sty_size_run_name
and b.incoming_stylecolor_id = f.product
'
;



s37 := '
delete from eve_ma_stylecolorchannelattributes where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
';



s38 := '
INSERT  into eve_ma_stylecolorchannelattributes (
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
, cc_ordpolicy
, ccrangecode
, ssnprf
, validsizes
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_existingwac
, cc_systemcost
, cc_landed_cost
, slsrnk
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_target_cost

-- CA MOD 06.15.2025
, act_aps_mult_adj
, use_act_aps_or_act_rank
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
, cc_ordpolicy
, ccrangecode
, ssnprf
, ''{}''::text[]
, cc_validsizes_store
, cc_validsizes_ecom
, cc_presmin
, cc_presmin_weeks
, cc_rcptint
, cc_ordermultiple
, cc_existingwac
, cc_systemcost
, cc_landed_cost
, slsrnk
, cc_return_u_pct_store
, cc_return_u_pct_ecom
, cc_target_cost

-- CA MOD 06.15.2025
, act_aps_mult_adj
, use_act_aps_or_act_rank
FROM
 '||table_temp_sclr_chnl_attr||'
 ';




-- ASSORTMENT MODEL

s51 := '
update eve_ma_stylecolorchannelattributes a
set
  cc_discount_pct = default_discount
, ccmdstrategy = default_md
, plan_current = v_plan_current
from (select id, ancestor3, default_discount, default_md, v_plan_current from eve_h_prodstd a, default_disc_md b, (select value as v_plan_current from eve_serviceparams where id=''plan_current'') c  where a.ancestor3=b.department) b
where (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
and a.product=b.id
';

s51_1 := '
update eve_ma_stylecolorchannelattributes a
set
  ccticketpricechannel = cast(coalesce(cc_msrp::real, .01) as real)
 ,cc_existingwac = cast(coalesce(cc_actual_cost::real,0.0) as real)
 ,cc_systemcost = cast(coalesce(cc_estimated_cost::real,0.0) as real)
 ,cc_landed_cost = cast(coalesce(cc_actual_cost::real,0.0) as real)
 --,cc_imupct = coalesce(round((((cc_msrp::real-coalesce(cc_actual_cost,cc_estimated_cost)::real)/cc_msrp::real)::numeric), 2)::real,0.0)::real
from (select final_stylecolor_id, x.sty_size_run_name || '' - '' || y.ancestor2 as rangecode, style_type, cc_msrp, cc_actual_cost, cc_estimated_cost
      from eve_ma_styleattributes x, eve_h_prodstd y, eve_ma_stylecolorattributes d,
           (select distinct final_stylecolor_id, final_style_id, style_type from  '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')) z
      where x.product = z.final_style_id and y.id = z.final_stylecolor_id and d.product = z.final_stylecolor_id
     ) b
where a.product = b.final_stylecolor_id and (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
';

-- ccrangecode split out of s51_1 and guarded.
--   trigger_sizerangecode_validsizes_members is AFTER UPDATE OF ccrangecode and
--   fires even when the value is unchanged. For a newly created (similar)
--   stylecolor the inherited code already equals the recomputed one, so the
--   no-op write fired a full size-run rebuild that reset cc_validsizes_store/
--   _ecom from 3 inherited sizes to all 7 in the size range.
--   IS DISTINCT FROM keeps the trigger for genuine size-run changes.
s51_1a := '
update eve_ma_stylecolorchannelattributes a
set
  ccrangecode = rangecode
from (select final_stylecolor_id, x.sty_size_run_name || '' - '' || y.ancestor2 as rangecode
      from eve_ma_styleattributes x, eve_h_prodstd y,
           (select distinct final_stylecolor_id, final_style_id from  '||table_cart_master_temp||' where jsessionid in (select jsid from  '||table_input_t1||')) z
      where x.product = z.final_style_id and y.id = z.final_stylecolor_id
     ) b
where a.product = b.final_stylecolor_id
and a.ccrangecode is distinct from b.rangecode
and (product, location) in (select distinct product, location from '||table_temp_sclr_chnl_attr||' where  jsessionid in (select jsid from  '||table_input_t1||'))
';

--SUP-3237 update target_cost using l_dependencylookup
s51_2 := '
Update eve_ma_stylecolorchannelattributes a
-- set cc_target_cost = coalesce(target_value, cc_target_cost) -- 20251003 JR Reverting to original as users asked for it
set cc_target_cost = cc_target_cost
from (select distinct e.final_stylecolor_id, e.stylecolor_type, target_value::real as target_value
      from '||table_cart_master_temp||' e, eve_h_prodstd f, eve_l_dependencylookup g, eve_ma_styleattributes h 
      where e.final_stylecolor_id = f.id and f.ancestor1 = g.lookup_value and f.ancestor0 = h.product and h.sty_source = g.target_id
      and g.lookup_id = ''target_cost''
     ) b
where a.product=b.final_stylecolor_id
and b.stylecolor_type=''similar''
';


s39 := '
    create temporary table '||table_temp_assort||' AS
    SELECT
        final_stylecolor_id as product
        , a.scope_location as location
        , a.scope_floorset as "time"
        , cast(case when cardinality(str_climate)= 0 then ''{N,Y}'' else str_climate end as text[]) as str_climate
        , cast(str_grade as text[]) as str_grade
        , cast(ssg as text[]) as ssg
        , cast(flnrange as text[]) as flnrange
        , ''plan'' as plan_type
        , isfunded
        , final_style_id as style
        , store_count
    FROM
    (select distinct * from cart_ranging) a, '||table_input_t1||' b, (select distinct jsessionid, final_stylecolor_id, incoming_stylecolor_id, final_style_id from '||table_cart_master_temp||') c
    where a.jsessionid=c.jsessionid
  and a.jsessionid = b.jsid
  and a.scope_product = b.scope_product
  and a.scope_location = b.scope_location
  and a.scope_start = b.scope_start
    '
    ;



s40 := '
delete from eve_a_assortment where (product, location) in (select product,location from '||table_temp_assort||') and plan_type=''plan''
';



s41 := '

    insert into eve_a_assortment (
          product
        , location
        , "time"
        , str_climate
        , str_grade
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
        , str_climate
        , str_grade
        , ssg
        , flnrange
        , plan_type
        , isfunded
        , store_count
  , style
    FROM
       '||table_temp_assort||'
';
/*
s41_1 := '
update eve_ma_stylecolorattributes a
set
  cc_floorset = floorset,
  cc_fulfillment = right(floorset, 6)
from (select min(time) as floorset from '||table_temp_assort||') b
where a.product in (select distinct final_stylecolor_id from '||table_cart_master_temp||')
';
*/
s41_1 := '
update eve_ma_stylecolorattributes a
set
  cc_floorset = floorset,
  cc_fulfillment = right(floorset, 6)
from 
(
    select x.product, y.target_value as floorset 
    from '||table_temp_sclr_chnl_attr||' x
    join eve_l_dependencylookup y
    on x.dbt_wk = y.lookup_value
    where y.lookup_id = ''dbt_wk''
    and y.target_id = ''cc_floorset''
) b
where a.product = b.product
and a.product in (select distinct final_stylecolor_id from '||table_cart_master_temp||')
';


RAISE NOTICE 'END Assortment Model:%', 'START:'|| now();

s42 := '
create temporary table '||table_final_list||' AS
select distinct a.product, a.location
from
(select distinct product,location  from eve_ma_stylecolorchannelattributes where (product, location) in (select distinct final_stylecolor_id,'''||$3||''' as prod_loc from '||table_cart_master_temp||')) a,
(select distinct product,location  from eve_a_assortment where (product, location) in (select distinct final_stylecolor_id, '''||$3||''' as prod_loc from '||table_cart_master_temp||')) b
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
          FROM eve_ma_stylecolorchannelattributes AS a
          , eve_d_time AS b
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
              FROM eve_h_prodstd
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
            (select a.* from '||tst_df_with_style||' a, eve_ma_styleattributes b where a.style=b.product) x
            ';

s104_a := 'update '||tst_md_tktp_md||' a
            set ccticketprice=b.cc_current_price::real, curp=cc_current_price::real
          from eve_ma_stylecolorattributes b
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
          from eve_corpdisc b
          where a.subclass=b.product and a.time=b.time
          ';

s107 := 'update '||tst_md_tktp_md||' a
            set expressed_aur=b.eff_aur, addoff=b.addoff
          from eve_p_itemprice b
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
              select product, dbt_wk, last_rcpt_wk, b.indx as dbt_wk_indx, c.indx as last_rcpt_wk_indx from ( select distinct product, dbt_wk, last_rcpt_wk from '||tst_md_tktp_md||' ) a, eve_d_time b, eve_d_time c
              where a.dbt_wk=b.id and a.last_rcpt_wk=c.id
              ';


s110   := 'update '||tst_md_tktp_md||'    set selling_price=(least(v_A,v_B) * (1 - cc_discount_pct))::NUMERIC(16,2)';
s110_1 := 'update '||tst_md_tktp_md||'  a set dbt_wk=b.start_date from eve_ma_weekattributes b where a.dbt_wk=b.time';
s110_2 := 'update '||tst_md_tktp_md||'  a set last_rcpt_wk=b.start_date from eve_ma_weekattributes b where a.last_rcpt_wk=b.time';
s110_3 := 'update '||tst_md_tktp_md||'  a set erlstmkdnwk=b.start_date from eve_ma_weekattributes b where a.erlstmkdnwk=b.time';
s110_4 := 'update '||tst_md_tktp_md||'  a set exitdate=b.start_date from eve_ma_weekattributes b where a.exitdate=b.time';
s110_5 := 'update '||tst_md_tktp_md||'  a set weekdate=b.start_date from eve_ma_weekattributes b where a.time=b.time';



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
              FROM (select * from eve_a_assortment where product in (select product from '||tst_md_tktp_md||')) AS a
              ,
              (
                  SELECT
                      id,
                      ancestor3
                  FROM eve_h_prodstd where id in (select product from '||tst_md_tktp_md||')
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
              FROM eve_ma_dptflrsetattributes AS a
              , eve_d_time AS b
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
          WHERE time >= (select value from eve_serviceparams where id=''plan_current'')
          AND time <= (select value from eve_serviceparams where id=''plan_end'')
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


s114 := 'delete from eve_an_price_storecount_info where (product,channel) in (select product, channel from '||table_zt||')';
s115 := 'insert into eve_an_price_storecount_info
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
RAISE NOTICE 's22: %', s22;
RAISE NOTICE 's23: %', s23;
RAISE NOTICE 's24: %', s24;
RAISE NOTICE 's25: %', s25;
RAISE NOTICE 's26: %', s26;
RAISE NOTICE 's26_X: %', s26_X;
RAISE NOTICE 's27: %', s27;
RAISE NOTICE 's28: %', s28;
RAISE NOTICE 's28_X: %', s28_X;
RAISE NOTICE 's28_Y: %', s28_Y;
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
RAISE NOTICE 's51_2: %', s51_2;
RAISE NOTICE 's39: %', s39;
RAISE NOTICE 's40: %', s40;
RAISE NOTICE 's41: %', s41;
RAISE NOTICE 's41_1: %', s41_1;

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
EXECUTE s28_Y;
-- insert into trigger_test_delete_me values ('s28_Y:', clock_timestamp());
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
EXECUTE s51_1;
EXECUTE s51_1a;
-- insert into trigger_test_delete_me values ('s51_1:', clock_timestamp());
EXECUTE s51_2;
-- insert into trigger_test_delete_me values ('s51_2:', clock_timestamp());
EXECUTE s39;
-- insert into trigger_test_delete_me values ('s39:', clock_timestamp());
EXECUTE s40;
-- insert into trigger_test_delete_me values ('s40:', clock_timestamp());
EXECUTE s41;
-- insert into trigger_test_delete_me values ('s41:', clock_timestamp());
EXECUTE s41_1;
-- insert into trigger_test_delete_me values ('s41_1:', clock_timestamp());
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

CREATE FUNCTION public.after_add_to_assortment(input_jsessionid text, scope_product text, scope_location text, scope_start text, scope_floorset text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN;

END;
$$;


--
-- Name: ata_exec(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ata_exec(p_run_id text, p_step text, p_sql text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    t0   timestamptz := clock_timestamp();
    t1   timestamptz;
    n    bigint;
    v_seq int := nextval('ata_trace_seq');
BEGIN
    -- non-transactional breadcrumb: survives a rollback, lands in the server log
    RAISE LOG 'ATA[%] % BEGIN %', p_run_id, p_step, p_sql;

    EXECUTE p_sql;
    GET DIAGNOSTICS n = ROW_COUNT;
    t1 := clock_timestamp();

    INSERT INTO ata_trace(run_id, seq, step, sql_text, started_at, finished_at,
                          duration_ms, rows_affected)
    VALUES (p_run_id, v_seq, p_step, p_sql, t0, t1,
            round(extract(epoch FROM (t1 - t0)) * 1000, 1), n);

    RAISE LOG 'ATA[%] % OK rows=% ms=%', p_run_id, p_step, n,
              round(extract(epoch FROM (t1 - t0)) * 1000, 1);
EXCEPTION WHEN OTHERS THEN
    -- the table insert below will roll back with the aborted tx; the LOG line won't
    RAISE LOG 'ATA[%] % FAILED % / % | SQL: %', p_run_id, p_step, SQLSTATE, SQLERRM, p_sql;
    RAISE NOTICE 'ATA step % FAILED: % / %', p_step, SQLSTATE, SQLERRM;
    RAISE NOTICE 'ATA failing SQL >>>%<<<', p_sql;
    RAISE EXCEPTION '% failed at step %: %', 'add_to_assortment', p_step, SQLERRM
        USING ERRCODE = SQLSTATE;
END;
$$;


--
-- Name: ata_snapshot(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ata_snapshot(p_run_id text, p_step text, p_table text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO ata_debug(run_id, step, payload) SELECT %L, %L, to_jsonb(t) FROM %I t',
        p_run_id, p_step, p_table);
EXCEPTION WHEN OTHERS THEN
    -- never let debug logging break the real run
    INSERT INTO ata_debug(run_id, step, payload)
    VALUES (p_run_id, p_step || '__SNAPSHOT_ERROR',
            jsonb_build_object('sqlstate', SQLSTATE, 'message', SQLERRM, 'table', p_table));
END;
$$;


--
-- Name: ata_snapshot_q(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ata_snapshot_q(p_run_id text, p_step text, p_sql text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO ata_debug(run_id, step, payload) SELECT %L, %L, to_jsonb(t) FROM (%s) t',
        p_run_id, p_step, p_sql);
EXCEPTION WHEN OTHERS THEN
    INSERT INTO ata_debug(run_id, step, payload)
    VALUES (p_run_id, p_step || '__SNAPSHOT_ERROR',
            jsonb_build_object('sqlstate', SQLSTATE, 'message', SQLERRM, 'sql', p_sql));
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
      (select slsstart from eve_ma_dptflrsetattributes where time=new.scope_floorset and product=new.scope_product), 
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.strclimate)), ','),
      string_to_array(TRIM( BOTH '{' FROM TRIM(BOTH '}' FROM new.grade)), ','),
      new.scope_product);
  else
   raise notice 'Received edit with an ssg.';
    new.store_count := (select array_length(stores, 1) FROM eve_l_ssglookup
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
  scWeekCount_pub = (select COUNT(*) from eve_p_dc_adj 
   where product = stylecolorId 
   and location = (select dc from eve_l_dclookup where channel = channelId)
   and (dc_publish > 0));
  scWeekCount_eoh = (select COUNT(*) from eve_eohdata_stylecolor 
   where product = stylecolorId 
   and channel = channelId
   and (eohu > 0));
  scWeekCount = scWeekCount_pub + scWeekCount_eoh;
  sizeWeekCount = (select COUNT(*) from eve_p_dc_adj_size
   where product in (select id from eve_h_prodstd where ancestor0 = stylecolorId)
   and location = (select dc from eve_l_dclookup where channel = channelId)
   and (dc_onorder > 0));
  return scWeekCount <= 0 and sizeWeekCount <= 0;
 END;
$$;


--
-- Name: change_product_to_worklist_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.change_product_to_worklist_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN



    IF EXISTS (
                SELECT 1 FROM user_worklist a, worklist_map b
                WHERE a.product=b.worklist_id AND b.product = NEW.product AND a.user_id = NEW.user_id
              ) THEN

        -- Delete the newly inserted row
        DELETE FROM user_worklist
        WHERE product = NEW.product
        AND user_id = NEW.user_id;

        -- Optionally, return NULL to indicate the row has been deleted
        RETURN NULL;

    ELSE

      UPDATE user_worklist a set product=b.worklist_id from worklist_map b
      where a.product=b.product and b.product=NEW.product
      and a.user_id=NEW.user_id
      and a.product != b.worklist_id;

    END IF;

  RETURN NEW;
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
  FROM eve_ma_stylecolorattributes a
  JOIN eve_h_prodstd b ON a.product = b.id
  JOIN eve_ma_styleattributes d ON d.product = b.ancestor0
  LEFT OUTER JOIN (select distinct product, cc_validsizes_store, cc_validsizes_ecom
                   from eve_ma_stylecolorchannelattributes
                  ) c ON a.product = c.product
  where a.product = stylecolorid
  ;

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
  FROM eve_ma_stylecolorattributes a
  JOIN eve_h_prodstd b ON a.product = b.id
  JOIN eve_ma_styleattributes d ON d.product = b.ancestor0
  LEFT OUTER JOIN (select distinct product, cc_validsizes_store, cc_validsizes_ecom
                   from eve_ma_stylecolorchannelattributes
                  ) c ON a.product = c.product
  where a.product = stylecolorid
  ;


  return v_ispublishable;
 END;
$$;


--
-- Name: cleanup_failed_jobs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cleanup_failed_jobs() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Move records to plan_queue_failed and delete them from plan_queue
    WITH moved AS (
        DELETE FROM plan_queue
        WHERE ready_for_cleanup = TRUE
          AND completed <= NOW() - INTERVAL '5 minutes'
        RETURNING *
    )
    INSERT INTO plan_queue_failed SELECT * FROM moved;
END;
$$;


--
-- Name: clear_pim_style_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.clear_pim_style_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_subclass text;
    v_pim_style_id text;
    v_remainingcc int;
    v_index text;
BEGIN
  
  IF (NEW.record_state=1 and OLD.record_state=0)
  THEN
  
      select pim_style_id into v_pim_style_id
      from eve_ma_styleattributes
      where product = (select ancestor0 from eve_h_prodstd where id = NEW.product)
      ;

      select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from eve_l_dependencylookup;
      
      select ancestor1 into v_subclass from eve_h_prodstd where id = NEW.product;

      select count(*) into v_remainingcc
      from eve_ma_stylecolorchannelattributes a
      where product in (select id from eve_h_prodstd where ancestor0 in (select ancestor0 from eve_h_prodstd where id = NEW.product))
        and product != NEW.product
        and record_state = 0;

      IF (v_remainingcc = 0 and COALESCE(v_pim_style_id,'') != '')
      THEN
        update eve_ma_styleattributes
        set pim_style_id = ''
        where product = (select ancestor0 from eve_h_prodstd where id = NEW.product);
      END IF;


  END IF;

  RETURN NEW;

END;
$$;


--
-- Name: create_hidden_class_ccsizerange_mod(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_hidden_class_ccsizerange_mod() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

v_style text;
v_sty_size_run_name text;

BEGIN

select id into v_style from eve_d_product where levelid='style' and id=NEW.id;

update eve_ma_stylecolorchannelattributes a
set ccrangecode = v_new_ccrangecode
from
(
select z.product, sty_size_run_name||' - '||NEW.ancestor1 as v_new_ccrangecode
from eve_ma_styleattributes x, eve_h_prodstd y, eve_ma_stylecolorchannelattributes z
where ancestor0=v_style and x.product = v_style and y.id = z.product
) b
where a.product = b.product;

RETURN NEW;

END;
$$;


--
-- Name: dbt_after_md_trigger_on_update_validity_check(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.dbt_after_md_trigger_on_update_validity_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
          UPDATE eve_ma_stylecolorchannelattributes a set dbt_wk = OLD.dbt_wk
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
  DELETE FROM plan_queue WHERE (product,location) in (select product,location from eve_ma_stylecolorchannelattributes where product = NEW.product
    and location = NEW.location and record_state=1);
  RETURN NEW;
END;
$$;


--
-- Name: enforce_cc_override_logic(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_cc_override_logic() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if cc_floorset_override is NOT NULL and cc_use_sys_floorset_override is TRUE
    IF NEW.cc_floorset_override IS NOT NULL AND NEW.cc_floorset_override !='' AND NEW.cc_use_sys_floorset_override IS TRUE THEN
        -- Set cc_use_sys_floorset_override to FALSE
        NEW.cc_use_sys_floorset_override = FALSE;
    END IF;

    RETURN NEW; -- Return the modified record
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
-- Name: eve_no_style_clone_stylecolor_size_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.eve_no_style_clone_stylecolor_size_proc(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_session_id    TEXT := p_session_id;
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN

    --------------------------------------------------------------------
    -- Build temp flat_map for this session
    --------------------------------------------------------------------
    CREATE TEMPORARY TABLE eve_style_clone_flat_map_temp AS
    SELECT * 
    FROM (
        SELECT DISTINCT
            from_stylecolor   AS from_id,
            to_new_stylecolor AS to_id,
            'stylecolor'      AS levelid,
            updated_by, session_id, clone_ordinal::text as clone_ordinal
            , to_new_stylecolor_name as to_name
            , to_new_stylecolor_desc as to_desc
            , RIGHT(to_new_stylecolor_name, 8) as cccolor
            , 'TBD' as cccolorfamily
        FROM eve_style_clone_stylecolor_size
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
        FROM eve_style_clone_stylecolor_size
        WHERE from_stylecolorsize IS NOT NULL AND from_stylecolorsize <> ''
          AND session_id = v_session_id
    ) x;


    --------------------------------------------------------------------
    -- d_product insert
    --------------------------------------------------------------------
        INSERT INTO eve_d_product (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_d_product b
        WHERE a.from_id = b.id
        ;

    --------------------------------------------------------------------
    -- STYLECOLOR insert
    --------------------------------------------------------------------
        INSERT INTO eve_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
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
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_h_prodstd b
        WHERE a.from_stylecolor = b.id
          AND from_style = b.ancestor0
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;


    --------------------------------------------------------------------
    -- STYLECOLORSIZE insert
    --------------------------------------------------------------------
        INSERT INTO eve_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
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
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_h_prodstd b
        WHERE a.from_stylecolorsize = b.id
          AND a.from_stylecolor = b.ancestor0
          AND from_style = b.ancestor1
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

 
    --------------------------------------------------------------------
    -- STYLECOLORATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_stylecolorattributes (
            product,
            pim_stylecolor_id,
            erp_stylecolor_id,
            ccstylecolorcreatedate,
            cc_marketing,
            cc_floorset,
            cc_pim_status,
            cc_pim_first_available_date,
            cc_pim_discontinue_date,
            cc_first_inv_date,
            cc_last_rec_date,
            cc_weighted_rec_date,
            cc_first_md_date,
            cc_last_md_date,
            cc_pricing_tier,
            cc_image_url,
            cc_description,
            cc_c_mh_ss,
            cc_exclusive,
            cc_print_pattern,
            cc_denim_wash,
            cccolor,
            cccolorfamily,
            cc_color_code,
            cc_msrp,
            cc_current_price,
            cc_estimated_cost,
            cc_actual_cost,
            cc_style_group,
            cc_rtv,
            cc_fulfillment,
            cc_cc_plan,
            cc_flow,
            division_name,
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
            cc_use_sys_floorset,
            cc_vendor_color,
            allocator_comments,
            cc_vendor_cost,
            cc_cancel_date,
            cc_trend,
            marketing_comments,
            cc_merch_status,
            cc_lineplan_notes,
            cc_styleout_notes,
            cc_placeholder_notes,
            cc_open1_notes,
            cc_open2_notes,
            cc_num_clones_s5,
            cc_num_times_cloned_s5
        )
        SELECT
            to_id,
            null as pim_stylecolor_id,
            null as erp_stylecolor_id,
            null as ccstylecolorcreatedate,
            cc_marketing,
            cc_floorset,
            null as cc_pim_status,
            null as cc_pim_first_available_date,
            null as cc_pim_discontinue_date,
            null as cc_first_inv_date,
            null as cc_last_rec_date,
            null as cc_weighted_rec_date,
            null as cc_first_md_date,
            null as cc_last_md_date,
            cc_pricing_tier,
            cc_image_url,
            null as cc_description,
            cc_c_mh_ss,
            cc_exclusive,
            cc_print_pattern,
            cc_denim_wash,
            a.cccolor,
            a.cccolorfamily,
            cc_color_code,
            cc_msrp,
            cc_current_price,
            null as cc_estimated_cost,
            null as cc_actual_cost,
            cc_style_group,
            cc_rtv,
            cc_fulfillment,
            cc_cc_plan,
            cc_flow,
            division_name,
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
            'Y' as cc_s5_adopted,
            null as cc_prepublish,
            null as cc_prepublished_at,
            cc_use_sys_floorset,
            cc_vendor_color,
            null as allocator_comments,
            cc_vendor_cost,
            cc_cancel_date,
            cc_trend,
            null as marketing_comments,
            cc_merch_status,
            null as cc_lineplan_notes,
            null as cc_styleout_notes,
            null as cc_placeholder_notes,
            null as cc_open1_notes,
            null as cc_open2_notes,
            null as cc_num_clones_s5,
            null as cc_num_times_cloned_s5
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_stylecolorattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- SIZEATTRIBUTES insert
    -------------------------------------------------------------------- 
        INSERT INTO eve_ma_sizeattributes (
            product,
            parent_id,
            pim_sku_id,
            erp_sku_id,
            sizeattribute,
            isvalid,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            to_new_stylecolorsize,
            to_new_stylecolor,
            null as pim_sku_id,
            null as erp_sku_id,
            sizeattribute,
            isvalid,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_ma_sizeattributes b
        WHERE a.from_stylecolorsize = b.product
          AND a.from_stylecolor = b.parent_id
          AND a.session_id = v_session_id
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- STYLECOLORCHANNELATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_stylecolorchannelattributes (
            product,
            location,
            dbt_wk,
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
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            slsrnk,
            ccticketpricechannel,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            ccmdstrategy,
            cc_presmin_weeks,
            cc_presmin,
            cc_ordpolicy,
            cc_rcptint,
            cc_ordermultiple,
            cc_discount_pct,
            cc_imupct,
            cc_existingwac,
            cc_systemcost,
            ssnprf,
            adjaps,
            relaunchweek,
            cc_plan_cost,
            cc_landed_cost,
            cc_target_cost,
            cc_flrset,
            cc_season,
            inseason_adjaps,
            smoothing_strategy,
            in_season_flag,
            lifecycle_applied,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            hasbeenpatternedafter,
            cc_override_service_level,
            cc_override_fp_st_pct,
            act_slsrnk,
            sclr_presmin,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_alloc_min,
            sclr_alloc_max,
            cc_override_service_level_ecom,
            cc_override_fp_st_pct_ecom,
            act_aps,
            act_aps_mult_adj,
            use_act_aps_or_act_rank,
            cloned_at
        )
        SELECT
            to_id,
            location,
            dbt_wk,
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
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            slsrnk,
            ccticketpricechannel,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            ccmdstrategy,
            cc_presmin_weeks,
            cc_presmin,
            cc_ordpolicy,
            cc_rcptint,
            cc_ordermultiple,
            cc_discount_pct,
            cc_imupct,
            cc_existingwac,
            cc_systemcost,
            ssnprf,
            adjaps,
            relaunchweek,
            cc_plan_cost,
            cc_landed_cost,
            cc_target_cost,
            cc_flrset,
            cc_season,
            inseason_adjaps,
            smoothing_strategy,
            in_season_flag,
            lifecycle_applied,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            hasbeenpatternedafter,
            cc_override_service_level,
            cc_override_fp_st_pct,
            act_slsrnk,
            sclr_presmin,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_alloc_min,
            sclr_alloc_max,
            cc_override_service_level_ecom,
            cc_override_fp_st_pct_ecom,
            act_aps,
            act_aps_mult_adj,
            use_act_aps_or_act_rank,
            --null as cloned_at
            date_trunc('sec'::text, CURRENT_TIMESTAMP) as cloned_at
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_stylecolorchannelattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- IMGATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_imgattributes (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_imgattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- ITEMPRICE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_itemprice (
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
            record_state
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_itemprice b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- CHANNELOVERRIDE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_channeloverride (
            product,
            location,
            time,
            weekadjaps,
            weekadjslsu,
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
            weekadjslsu,
            null as comments,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            testpo,
            floorsetpo
        FROM eve_style_clone_flat_map_temp a,
             eve_p_channeloverride b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- ASSORTMENT insert
    --------------------------------------------------------------------
        INSERT INTO eve_a_assortment (
            product,
            location,
            time,
            style,
            str_climate,
            str_grade,
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
            record_state
        )
        SELECT
            to_id,
            location,
            time,
            to_new_style,
            str_climate,
            str_grade,
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_a_assortment b,
             eve_style_clone_stylecolor_size c
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
          AND c.session_id = v_session_id
          AND a.to_id = c.to_new_stylecolor
            ON CONFLICT (product, "time", location, plan_type) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- DC_ADJ insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_dc_adj (
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
            record_state
        )
        SELECT
            to_id,
            location,
            time,
            null as dc_publish,
            null as is_locked,  --SUP-3930
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_dc_adj b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- DC_ADJ_SIZE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_dc_adj_size (
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
            record_state
        )
        SELECT
            from_stylecolorsize,
            location,
            time,
            null as dc_publish,
            null as is_locked,  --SUP-3930
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
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_p_dc_adj_size b
        WHERE a.from_stylecolorsize = b.product
          AND a.session_id = v_session_id
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- AN_PRICE_STORECOUNT_INFO insert
    --------------------------------------------------------------------
    INSERT INTO eve_an_price_storecount_info (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_an_price_storecount_info b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", channel, selling_channel) DO NOTHING
        ;

    --------------------------------------------------------------------
    -- EVE_P_STYLECOLOR_STORE_ALLOC_PARAMS insert
    --------------------------------------------------------------------
    INSERT INTO eve_p_stylecolor_store_alloc_params (
            product,
            location,
            sclr_loc_eligibility,
            sclr_loc_tgt_fp_st_pct,
            sclr_loc_alloc_sizeattr,
            sclr_loc_presmin,
            sclr_loc_presmin_weeks,
            sclr_loc_fringe_flag,
            sclr_loc_target_fwoc_override,
            sclr_loc_service_level,
            sclr_loc_alloc_min,
            sclr_loc_alloc_max,
            sclr_loc_size_eligibility,
            sclr_loc_size_min_by_size_override,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            to_id,
            location,
            sclr_loc_eligibility,
            sclr_loc_tgt_fp_st_pct,
            sclr_loc_alloc_sizeattr,
            sclr_loc_presmin,
            sclr_loc_presmin_weeks,
            sclr_loc_fringe_flag,
            sclr_loc_target_fwoc_override,
            sclr_loc_service_level,
            sclr_loc_alloc_min,
            sclr_loc_alloc_max,
            sclr_loc_size_eligibility,
            sclr_loc_size_min_by_size_override,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_stylecolor_store_alloc_params b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
        ;

    --------------------------------------------------------------------
    -- DEPENDENCYLOOKUP inserts
    --------------------------------------------------------------------
        INSERT INTO eve_l_dependencylookup (
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
        FROM eve_style_clone_flat_map_temp a
        WHERE a.levelid = 'stylecolor';


-- DROP THE TEMPORARY TABLE
DROP TABLE IF EXISTS eve_style_clone_flat_map_temp;

END;
$$;


--
-- Name: eve_plan_these_cloned_style_stylecolors_proc(text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.eve_plan_these_cloned_style_stylecolors_proc(IN p_pivot_user_id text)
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
    FROM eve_plan_these_cloned_style_stylecolors
    WHERE updated_by = v_pivot_user_id
      AND picked_for_planning = 0
    ;

    UPDATE
        eve_style_clone_stylecolor_size
    SET 
        picked_for_planning = 1 
    WHERE 
        (to_new_stylecolor, session_id) IN (select stylecolor, session_id from eve_plan_these_cloned_style_stylecolors where updated_by = v_pivot_user_id)
    ;


    -- ----------------------------------
    -- MARK FOR DELETION UNUSED PRODUCTS 
    -- ----------------------------------

    CREATE TEMPORARY TABLE all_un_used_products
    AS  
    SELECT 
        DISTINCT to_new_style AS product, 'style' AS levelid 
    FROM 
        eve_style_clone_stylecolor_size s
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
        eve_style_clone_stylecolor_size s
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
        eve_style_clone_stylecolor_size s
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
    DELETE FROM eve_style_clone_stylecolor_size a 
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
    delete from eve_d_product where id in (select distinct product from all_un_used_products);
    delete from eve_h_prodstd where id in (select distinct product from all_un_used_products);
    delete from eve_a_assortment where product in (select distinct product from all_un_used_products);
    delete from eve_ma_styleattributes where product in (select distinct product from all_un_used_products);
    delete from eve_ma_stylecolorattributes where product in (select distinct product from all_un_used_products);
    delete from eve_ma_sizeattributes where product in (select distinct product from all_un_used_products);
    delete from eve_ma_imgattributes where product in (select distinct product from all_un_used_products);
    delete from eve_p_dc_adj where product in (select distinct product from all_un_used_products);
    delete from eve_p_dc_adj_size where product in (select distinct product from all_un_used_products);
    delete from eve_p_itemprice where product in (select distinct product from all_un_used_products);
    delete from eve_p_channeloverride where product in (select distinct product from all_un_used_products);
    delete from eve_an_price_storecount_info where product in (select distinct product from all_un_used_products);
    */

    -- --------------------------------------------------------------------------------------------------------
    -- CLEAN UP BYPASSING DELETES FOR NOW, SIMULATING REMOVE FROM ASSORTMENT, LIKELY DATA EXISTS IN CLICKHOUSE
    -- --------------------------------------------------------------------------------------------------------
    delete from eve_a_assortment 
    where product in (select distinct product from all_un_used_products);

    update eve_ma_stylecolorchannelattributes 
    set record_state=1 
    where product in (select distinct product from all_un_used_products);

    update eve_ma_stylecolorchannelattributes 
    set record_state=0
    where product in (select distinct stylecolor from tmp_selected);

    ------------------------------------
    -- INSERT IN PLAN QUEUE FOR PLANNING
    ------------------------------------

    INSERT INTO plan_queue (product, location, initiator, initiated_at, queued)
    select 
        distinct stylecolor, 'total_location' as location, updated_by, now(), now() 
    FROM 
        tmp_selected
    ;

    ------------------------------------
    -- UPDATE picked_for_planning FLAG
    ------------------------------------
    UPDATE 
        eve_plan_these_cloned_style_stylecolors 
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
-- Name: eve_style_clone_stylecolor_size_proc(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.eve_style_clone_stylecolor_size_proc(IN p_session_id text, IN p_pivot_user_id text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_session_id    TEXT := p_session_id;
    v_pivot_user_id TEXT := p_pivot_user_id;
BEGIN

    --------------------------------------------------------------------
    -- Build temp flat_map for this session
    --------------------------------------------------------------------
    CREATE TEMPORARY TABLE eve_style_clone_flat_map_temp AS
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
        FROM eve_style_clone_stylecolor_size
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
        FROM eve_style_clone_stylecolor_size
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
        FROM eve_style_clone_stylecolor_size
        WHERE from_stylecolorsize IS NOT NULL AND from_stylecolorsize <> ''
          AND session_id = v_session_id
    ) x;

    --------------------------------------------------------------------
    -- d_product insert
    --------------------------------------------------------------------
        INSERT INTO eve_d_product (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_d_product b
        WHERE a.from_id = b.id
        ;

    --------------------------------------------------------------------
    -- STYLE insert
    --------------------------------------------------------------------
        INSERT INTO eve_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
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
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_h_prodstd b
        WHERE a.from_style = b.id
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

    --------------------------------------------------------------------
    -- STYLECOLOR insert
    --------------------------------------------------------------------
        INSERT INTO eve_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
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
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_h_prodstd b
        WHERE a.from_stylecolor = b.id
          AND from_style = b.ancestor0
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

    --------------------------------------------------------------------
    -- STYLECOLORSIZE insert
    --------------------------------------------------------------------
    
        INSERT INTO eve_h_prodstd (
            id,
            ancestor0,
            ancestor1,
            ancestor2,
            ancestor3,
            ancestor4,
            ancestor5,
            ancestor6,
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
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_h_prodstd b
        WHERE a.from_stylecolorsize = b.id
          AND a.from_stylecolor = b.ancestor0
          AND from_style = b.ancestor1
          AND a.session_id = v_session_id
            ON CONFLICT (id) DO NOTHING
    ;

    --------------------------------------------------------------------
    -- STYLEATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_styleattributes (
            product,
            pim_style_id,
            erp_style_id,
            sty_dept,
            sty_typ,
            sty_subtyp_1,
            sty_style_description,
            sty_vendor_id,
            sty_vendor_name,
            sty_brand_id,
            sty_brand_name,
            sty_source,
            sty_length_height,
            sty_neckline,
            sty_end_use,
            sty_size_run_name,
            sty_size_run_id,
            sty_knit_woven,
            sty_development_path,
            sty_product_type,
            sty_fabric_material,
            ccstylecreatedate,
            sty_closure,
            sty_hem_finish,
            sty_waist_rise,
            sty_is_locked,
            sty_s5_adopted,
            pim_size_run_id,
            pim_size_run_name,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            sty_sleeve_length,
            sty_subclass_display,
            sty_num_clones_s5,
            sty_num_times_cloned_s5
        )
        SELECT
            to_id,
            null as pim_style_id,
            null as erp_style_id,
            sty_dept,
            sty_typ,
            sty_subtyp_1,
            sty_style_description,
            sty_vendor_id,
            sty_vendor_name,
            sty_brand_id,
            sty_brand_name,
            sty_source,
            sty_length_height,
            sty_neckline,
            sty_end_use,
            sty_size_run_name,
            sty_size_run_id,
            sty_knit_woven,
            sty_development_path,
            sty_product_type,
            sty_fabric_material,
            null as ccstylecreatedate,
            sty_closure,
            sty_hem_finish,
            sty_waist_rise,
            null as sty_is_locked,
            'Y' as sty_s5_adopted,
            null as pim_size_run_id,
            null as pim_size_run_name,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            sty_sleeve_length,
            sty_subclass_display,
            null as sty_num_clones_s5,
            null as sty_num_times_cloned_s5
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_styleattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'style'
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- STYLECOLORATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_stylecolorattributes (
            product,
            pim_stylecolor_id,
            erp_stylecolor_id,
            ccstylecolorcreatedate,
            cc_marketing,
            cc_floorset,
            cc_pim_status,
            cc_pim_first_available_date,
            cc_pim_discontinue_date,
            cc_first_inv_date,
            cc_last_rec_date,
            cc_weighted_rec_date,
            cc_first_md_date,
            cc_last_md_date,
            cc_pricing_tier,
            cc_image_url,
            cc_description,
            cc_c_mh_ss,
            cc_exclusive,
            cc_print_pattern,
            cc_denim_wash,
            cccolor,
            cccolorfamily,
            cc_color_code,
            cc_msrp,
            cc_current_price,
            cc_estimated_cost,
            cc_actual_cost,
            cc_style_group,
            cc_rtv,
            cc_fulfillment,
            cc_cc_plan,
            cc_flow,
            division_name,
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
            cc_use_sys_floorset,
            cc_vendor_color,
            allocator_comments,
            cc_vendor_cost,
            cc_cancel_date,
            cc_trend,
            marketing_comments,
            cc_merch_status,
            cc_lineplan_notes,
            cc_styleout_notes,
            cc_placeholder_notes,
            cc_open1_notes,
            cc_open2_notes,
            cc_num_clones_s5,
            cc_num_times_cloned_s5
        )
        SELECT
            to_id,
            null as pim_stylecolor_id,
            null as erp_stylecolor_id,
            null as ccstylecolorcreatedate,
            cc_marketing,
            cc_floorset,
            null as cc_pim_status,
            null as cc_pim_first_available_date,
            null as cc_pim_discontinue_date,
            null as cc_first_inv_date,
            null as cc_last_rec_date,
            null as cc_weighted_rec_date,
            null as cc_first_md_date,
            null as cc_last_md_date,
            cc_pricing_tier,
            cc_image_url,
            null as cc_description,
            cc_c_mh_ss,
            cc_exclusive,
            cc_print_pattern,
            cc_denim_wash,
            a.cccolor,
            a.cccolorfamily,
            cc_color_code,
            cc_msrp,
            cc_current_price,
            null as cc_estimated_cost,
            null as cc_actual_cost,
            cc_style_group,
            cc_rtv,
            cc_fulfillment,
            cc_cc_plan,
            cc_flow,
            division_name,
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
            'Y' as cc_s5_adopted,
            null as cc_prepublish,
            null as cc_prepublished_at,
            cc_use_sys_floorset,
            cc_vendor_color,
            null as allocator_comments,
            cc_vendor_cost,
            cc_cancel_date,
            cc_trend,
            null as marketing_comments,
            cc_merch_status,
            null as cc_lineplan_notes,
            null as cc_styleout_notes,
            null as cc_placeholder_notes,
            null as cc_open1_notes,
            null as cc_open2_notes,
            null as cc_num_clones_s5,
            null as cc_num_times_cloned_s5
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_stylecolorattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- SIZEATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_sizeattributes (
            product,
            parent_id,
            pim_sku_id,
            erp_sku_id,
            sizeattribute,
            isvalid,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            to_new_stylecolorsize,
            to_new_stylecolor,
            null as pim_sku_id,
            null as erp_sku_id,
            sizeattribute,
            isvalid,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_ma_sizeattributes b
        WHERE a.from_stylecolorsize = b.product
          AND a.from_stylecolor = b.parent_id
          AND a.session_id = v_session_id
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- STYLECOLORCHANNELATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_stylecolorchannelattributes (
            product,
            location,
            dbt_wk,
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
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            slsrnk,
            ccticketpricechannel,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            ccmdstrategy,
            cc_presmin_weeks,
            cc_presmin,
            cc_ordpolicy,
            cc_rcptint,
            cc_ordermultiple,
            cc_discount_pct,
            cc_imupct,
            cc_existingwac,
            cc_systemcost,
            ssnprf,
            adjaps,
            relaunchweek,
            cc_plan_cost,
            cc_landed_cost,
            cc_target_cost,
            cc_flrset,
            cc_season,
            inseason_adjaps,
            smoothing_strategy,
            in_season_flag,
            lifecycle_applied,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state,
            hasbeenpatternedafter,
            cc_override_service_level,
            cc_override_fp_st_pct,
            act_slsrnk,
            sclr_presmin,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_alloc_min,
            sclr_alloc_max,
            cc_override_service_level_ecom,
            cc_override_fp_st_pct_ecom,
            act_aps,
            act_aps_mult_adj,
            use_act_aps_or_act_rank,
            cloned_at
        )
        SELECT
            to_id,
            location,
            dbt_wk,
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
            mdstart_indx,
            lastdcorder_indx,
            exitdate_indx,
            slsrnk,
            ccticketpricechannel,
            validsizes,
            cc_validsizes_store,
            cc_validsizes_ecom,
            ccrangecode,
            ccmdstrategy,
            cc_presmin_weeks,
            cc_presmin,
            cc_ordpolicy,
            cc_rcptint,
            cc_ordermultiple,
            cc_discount_pct,
            cc_imupct,
            cc_existingwac,
            cc_systemcost,
            ssnprf,
            adjaps,
            relaunchweek,
            cc_plan_cost,
            cc_landed_cost,
            cc_target_cost,
            cc_flrset,
            cc_season,
            inseason_adjaps,
            smoothing_strategy,
            in_season_flag,
            lifecycle_applied,
            cc_return_u_pct_store,
            cc_return_u_pct_ecom,
            auto_rollforward,
            irr_mode,
            plan_current,
            lock_agg_edit,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            hasbeenpatternedafter,
            cc_override_service_level,
            cc_override_fp_st_pct,
            act_slsrnk,
            sclr_presmin,
            sclr_presmin_weeks,
            sclr_tgt_fwoc,
            sclr_alloc_min,
            sclr_alloc_max,
            cc_override_service_level_ecom,
            cc_override_fp_st_pct_ecom,
            act_aps,
            act_aps_mult_adj,
            use_act_aps_or_act_rank,
            --null as cloned_at
            date_trunc('sec'::text, CURRENT_TIMESTAMP) as cloned_at
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_stylecolorchannelattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- IMGATTRIBUTES insert
    --------------------------------------------------------------------
        INSERT INTO eve_ma_imgattributes (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_ma_imgattributes b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- ITEMPRICE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_itemprice (
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
            record_state
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_itemprice b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- CHANNELOVERRIDE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_channeloverride (
            product,
            location,
            time,
            weekadjaps,
            weekadjslsu,
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
            weekadjslsu,
            null as comments,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state,
            testpo,
            floorsetpo
        FROM eve_style_clone_flat_map_temp a,
             eve_p_channeloverride b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, time) DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- ASSORTMENT insert
    --------------------------------------------------------------------
        INSERT INTO eve_a_assortment (
            product,
            location,
            time,
            style,
            str_climate,
            str_grade,
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
            record_state
        )
        SELECT
            to_id,
            location,
            time,
            to_new_style,
            str_climate,
            str_grade,
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_a_assortment b,
             eve_style_clone_stylecolor_size c
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
          AND c.session_id = v_session_id
          AND a.to_id = c.to_new_stylecolor
            ON CONFLICT (product, "time", location, plan_type) DO NOTHING
    ;
    
    
    --------------------------------------------------------------------
    -- DC_ADJ insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_dc_adj (
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
            record_state
        )
        SELECT
            to_id,
            location,
            time,
            null as dc_publish,
            null as is_locked,  --SUP-3930
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
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_dc_adj b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- DC_ADJ_SIZE insert
    --------------------------------------------------------------------
        INSERT INTO eve_p_dc_adj_size (
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
            record_state
        )
        SELECT
            from_stylecolorsize,
            location,
            time,
            null as dc_publish,
            null as is_locked,  --SUP-3930
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
            record_state
        FROM eve_style_clone_stylecolor_size a,
             eve_p_dc_adj_size b
        WHERE a.from_stylecolorsize = b.product
          AND a.session_id = v_session_id
            ON CONFLICT (product, location, "time") DO NOTHING
    ;
    
    --------------------------------------------------------------------
    -- AN_PRICE_STORECOUNT_INFO insert
    --------------------------------------------------------------------
    INSERT INTO eve_an_price_storecount_info (
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
        FROM eve_style_clone_flat_map_temp a,
             eve_an_price_storecount_info b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, "time", channel, selling_channel) DO NOTHING
        ;

    --------------------------------------------------------------------
    -- EVE_P_STYLECOLOR_STORE_ALLOC_PARAMS insert
    --------------------------------------------------------------------
    INSERT INTO eve_p_stylecolor_store_alloc_params (
            product,
            location,
            sclr_loc_eligibility,
            sclr_loc_tgt_fp_st_pct,
            sclr_loc_alloc_sizeattr,
            sclr_loc_presmin,
            sclr_loc_presmin_weeks,
            sclr_loc_fringe_flag,
            sclr_loc_target_fwoc_override,
            sclr_loc_service_level,
            sclr_loc_alloc_min,
            sclr_loc_alloc_max,
            sclr_loc_size_eligibility,
            sclr_loc_size_min_by_size_override,
            eventdate,
            version_id,
            created_at,
            created_by,
            updated_at,
            updated_by,
            record_state
        )
        SELECT
            to_id,
            location,
            sclr_loc_eligibility,
            sclr_loc_tgt_fp_st_pct,
            sclr_loc_alloc_sizeattr,
            sclr_loc_presmin,
            sclr_loc_presmin_weeks,
            sclr_loc_fringe_flag,
            sclr_loc_target_fwoc_override,
            sclr_loc_service_level,
            sclr_loc_alloc_min,
            sclr_loc_alloc_max,
            sclr_loc_size_eligibility,
            sclr_loc_size_min_by_size_override,
            now()::date,
            version_id,
            now(),
            v_pivot_user_id,
            now(),
            v_pivot_user_id,
            record_state
        FROM eve_style_clone_flat_map_temp a,
             eve_p_stylecolor_store_alloc_params b
        WHERE a.from_id = b.product
          AND a.levelid = 'stylecolor'
            ON CONFLICT (product, location) DO NOTHING
        ;

    --------------------------------------------------------------------
    -- DEPENDENCYLOOKUP inserts
    --------------------------------------------------------------------
        INSERT INTO eve_l_dependencylookup (
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
        FROM eve_style_clone_flat_map_temp a
        WHERE a.levelid = 'style';


        INSERT INTO eve_l_dependencylookup (
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
        FROM eve_style_clone_flat_map_temp a
        WHERE a.levelid = 'stylecolor';

-- DROP THE TEMPORARY TABLE
DROP TABLE IF EXISTS eve_style_clone_flat_map_temp;

END;
$$;


--
-- Name: eve_style_clone_stylecolor_size_proc_dummy(text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.eve_style_clone_stylecolor_size_proc_dummy(IN p_session_id text, IN p_pivot_user_id text)
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
-- Name: exit_trigger_on_update_validity_check(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.exit_trigger_on_update_validity_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE eve_ma_stylecolorchannelattributes a set exitdate = OLD.exitdate
  WHERE product=NEW.product
  ;
  RETURN NEW;
END;
$$;


--
-- Name: fetch_store_count(text, text, text[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_store_count(productid text, floorsetid text, str_grade text[], str_climate text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
 DECLARE
  sls_start     text;
  dept_var      text;
 BEGIN

 select ancestor3 into dept_var
 from eve_h_prodstd where id = productId;

 select a.slsstart into sls_start
 from eve_ma_dptflrsetattributes a
 where time = floorsetId and product = dept_var;

RETURN(
  SELECT
  count(*)
FROM
  (
    (
      SELECT
        distinct(sc.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            eve_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_climate'
            AND value = ANY( str_climate )
        ) as sc
    ) as sc
    INNER JOIN (
      SELECT
        distinct(gr.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            eve_l_storelookup
          WHERE
            time = sls_start
            AND product = dept_var
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as gr
    ) as gr USING (store)
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
          , too
          , mkdnwks
          , last_inv_wk
          , lstfpwk
          , last_rcpt_wk
          , erlstmkdnwk
          , exitdate
          , ccmdstrategy
          , presmin
          , presmin_weeks
          , ccrcptint
          , ccordermultiple
          , ccordpolicy
          , slsrnk
          -- CA MOD 06.15.2025
          , use_act_aps_or_act_rank
        )
        SELECT
            '''||$1||''','''||$2||''','''||$3||''','''||$4||''','''||$5||'''
          , default_initrcptwk
          , default_dbt_wk
          , default_too
          , default_mkdnwks
          , default_last_inv_wk
          , default_lstfpwk
          , default_last_rcpt_wk
          , default_erlstmkdnwk
          , default_exitdate
          , default_ccmdstrategy
          , default_presmin
          , default_presmin_weeks
          , default_ccrcptint
          , default_ccordermultiple
          , default_ccordpolicy
          , 3
          , ''Copy Rating''
        FROM
          eve_ma_dptflrsetattributes
        WHERE
          product = '''||$2||'''
          and time = '''||$5||'''
          ';
  delete_s3 := '
     delete from cart_ranging where jsessionid = '''||$1||''' and scope_product='''||$2||'''
     and scope_start = '''||$4||''' and scope_floorset = '''||$5||'''
             ';
  insert_s4 := '
  insert into cart_ranging
(jsessionid,scope_product,scope_location,scope_start,scope_floorset
   ,str_climate,str_grade,ssg,flnrange,isfunded, indx, store_count)
select
  '''||$1||''',product,'''||$3||''','''||$4||''',time,
    case when cardinality(default_strclimate) = 0 then ''{Standard,Hot,Warm,Ecomm}'' else  cast(default_strclimate as text[]) end as default_strclimate
  , cast(default_grade as text[]) as default_grade
  , default_ssg
  , default_flnrange
  , isfunded
  , indx
        , store_count
  FROM (
  select product, time,default_strclimate,default_grade,default_ssg,default_flnrange
   ,1 as isfunded, a.indx, get_store_count('''||$4||''', case when cardinality(default_strclimate) = 0 then ''{Standard,Hot,Warm,Ecomm}'' else default_strclimate end, default_grade, product) as store_count
  FROM eve_ma_dptflrsetattributes a, cart_params b,
   (select value as plan_current from eve_serviceparams where id=''plan_current'') c,
   (select value as plan_end from eve_serviceparams where id=''plan_end'') d
  where
  b.jsessionid = '''||$1||'''
  and b.scope_product = '''||$2||'''
  and b.scope_location = '''||$3||'''
  and a.product = b.scope_product
     and a.slsstart <= least(d.plan_end,b.exitdate) and a.slsend > greatest(b.dbt_wk,c.plan_current)
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
-- Name: get_store_count(text, text[], text[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_store_count(week text, str_climate text[], str_grade text[], productval text) RETURNS integer
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
        distinct(sc.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            eve_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_climate'
            AND value = ANY( str_climate )
        ) as sc
    ) as sc
    INNER JOIN (
      SELECT
        distinct(gr.unnest) as store
      FROM
        (
          SELECT
            unnest(stores)
          FROM
            eve_l_storelookup
          WHERE
            time = week
            AND product = productVal
            AND id = 'str_grade'
            AND value = ANY( str_grade )
        ) as gr
    ) as gr USING (store)
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
    select ancestor3 into department from eve_h_prodstd where id = NEW.product;
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

update eve_p_dc_adj
set
  dc_uservrp = null,
  dc_useradj = null
WHERE
product = NEW.product
and time >= NEW.erlstmkdnwk;

update eve_p_dc_adj_size
set
  dc_uservrp = null,
  dc_useradj = null
WHERE
product in (select id from eve_h_prodstd where ancestor0 = NEW.product)
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
  UPDATE eve_ma_stylecolorchannelattributes a set erlstmkdnwk = OLD.erlstmkdnwk
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
-- Name: null_value_vendor_cost(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.null_value_vendor_cost() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

    IF NEW.cc_vendor_cost = '' THEN NEW.cc_vendor_cost := NULL;
  END IF;

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
  INSERT INTO user_worklist (user_id, product) select updated_by, worklist_id from eve_p_stylecolor_worklist
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
            FROM eve_ma_stylecolorchannelattributes scca INNER JOIN UNNEST(products) arg
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
         from eve_h_prodstd where id = NEW.product;
       
        select a.slsstart into sls_start 
        from eve_ma_dptflrsetattributes a
        where time = NEW.time and product = dept_var;
      
        if (cardinality(OLD.SSG) > 0 or OLD.SSG is not null)
     and (cardinality(OLD.str_grade)     = 0 and
        cardinality(OLD.str_climate) = 0 
       ) 
     and (cardinality(NEW.str_grade) > 0 or
       cardinality(NEW.str_climate) > 0 
       ) 
    then
      NEW.SSG := '{}'::text[];
    
      if cardinality(NEW.str_grade) = 0 then 
       select array_agg(attributevalue) into NEW.str_grade from eve_v_memberbasedvalidvalues where attributeid = 'str_grade';
      end if;
      if cardinality(NEW.str_climate) = 0 then
       select array_agg(attributevalue) into NEW.str_climate from eve_v_memberbasedvalidvalues where attributeid = 'str_climate';
      end if;
    elsif (cardinality(OLD.SSG) = 0 or OLD.SSG is null) 
     and (cardinality(OLD.str_grade)     > 0 or
       cardinality(OLD.str_climate)    > 0 
       ) 
     and cardinality(NEW.ssg) > 0
     then
      NEW.str_grade       := '{}'::text[];
      NEW.str_climate      := '{}'::text[];
        
    end if;
    
    if cardinality(NEW.SSG) = 0 or NEW.SSG is null then 
     
      NEW.store_count := get_store_count(
                         sls_start
                        ,NEW.str_climate
                        ,NEW.str_grade
                        ,dept_var
                       );
    
      NEW.SSG = '{}'::text[];
    
    else 
      select cardinality(stores) into NEW.store_count
      from eve_l_ssglookup 
      where ssg_id = array_to_string(NEW.SSG, ',')
       and product = dept_var;
    
    end if;
    
    update eve_a_assortment a
    set str_grade = NEW.str_grade
      ,str_climate = NEW.str_climate
      ,ssg = NEW.ssg
      ,store_count = NEW.store_count
    from (select id, indx from eve_d_time where levelid = 'floorset') d
    where product = NEW.product
     and location = NEW.location
     and d.id = NEW.time
     and a.time in (select id from eve_d_time where levelid = 'floorset' and indx >= d.indx)
    ;
    
    RETURN NEW;
    
   END;
   $$;


--
-- Name: replicate_and_cleanup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replicate_and_cleanup() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Replicate the inserted record to plan_queue_post_run
        INSERT INTO plan_queue_post_run
        SELECT NEW.*;

    ELSIF TG_OP = 'UPDATE' THEN
        -- Replicate the updated record to plan_queue_post_run
        UPDATE plan_queue_post_run
        SET 
            product = NEW.product,
            location = NEW.location,
            initiator = NEW.initiator,
            initiated_at = NEW.initiated_at,
            queued = NEW.queued,
            processing = NEW.processing,
            completed = NEW.completed,
            error = NEW.error,
            updated_at = NEW.updated_at,
            priority = NEW.priority
        WHERE jobid = NEW.jobid;

        -- Delete the record from plan_queue if completed IS NOT NULL
        IF NEW.completed IS NOT NULL THEN
            DELETE FROM plan_queue WHERE jobid = NEW.jobid;
        END IF;
    END IF;

    RETURN NULL; -- No need to return a value for AFTER triggers
END;
$$;


--
-- Name: replicate_to_post_run(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replicate_to_post_run() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Replicate the inserted record to plan_queue_post_run
        INSERT INTO plan_queue_post_run
        SELECT NEW.*;

    ELSIF TG_OP = 'UPDATE' THEN
        -- Replicate the updated record to plan_queue_post_run
        UPDATE plan_queue_post_run
        SET
            product = NEW.product,
            location = NEW.location,
            initiator = NEW.initiator,
            initiated_at = NEW.initiated_at,
            queued = NEW.queued,
            processing = NEW.processing,
            completed = NEW.completed,
            error = NEW.error,
            updated_at = NEW.updated_at,
            priority = NEW.priority
        WHERE jobid = NEW.jobid;

        -- Delete the record from plan_queue if completed IS NOT NULL
        -- IF NEW.completed IS NOT NULL THEN
        --     DELETE FROM plan_queue WHERE jobid = NEW.jobid;
        -- END IF;
    END IF;

    RETURN NULL; -- No need to return a value for AFTER triggers
END;
$$;


--
-- Name: reset_plan_type_to_plan(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_plan_type_to_plan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 
 BEGIN
 
  update 
   eve_a_assortment set plan_type='plan' 
  where 
   product = NEW.product
   and location = NEW.location
   and time >= NEW.time
  ;
 
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
-- Name: set_prepublished_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_prepublished_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.cc_prepublish is true and OLD.cc_prepublished_at is null then
    NEW.cc_prepublished_at = NOW()::timestamp(0);
  END IF;
  IF NEW.cc_prepublish is not true then
    NEW.cc_prepublish = null;
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
  select distinct '''||v_product||''' as product,  '''||v_location||''' as location, unnest(validsizes) validsizes, 1 as isvalid from eve_ma_stylecolorchannelattributes
  where 
  product= '''||v_product||'''
  and location= '''||v_location||'''
    ';
EXECUTE s1;
s2 := '
  update eve_ma_sizeattributes 
  set isvalid=0
  where parent_id='''||v_product||'''
  ';
EXECUTE s2;
s3 := '
  update eve_ma_sizeattributes a
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
    AS $$
DECLARE
  s0 text;
  s1 text;
  s2 text;
  s3 text;
  s4 text;
  s5 text;
  s6 text;
  s6x text;
  s7 text;
  s8 text;
  s9 text;
    
  table_temp_rangecode_master text;
  v_uuid_temp text;
  v_uuid text;
  v_product text;
  v_location text;
  v_ccrangecode text;
  v_sty_size_range text;
  
    
BEGIN

EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;

table_temp_rangecode_master:= 'table_temp_rangecode_master'||v_uuid;

v_product=NEW.product;
v_location=NEW.location;
v_ccrangecode=NEW.ccrangecode;

select substring(v_ccrangecode, 1, position(' - CL-' in v_ccrangecode) -1) into v_sty_size_range;
/*
RAISE NOTICE 'v_product: %', v_product;
RAISE NOTICE 'v_location: %', v_location;
RAISE NOTICE 'v_ccrangecode: %', v_ccrangecode;
RAISE NOTICE 'v_sty_size_range: %', v_sty_size_range;
*/
s0 := 'drop table if exists '||table_temp_rangecode_master||' 
  ';

s1 := 'create temporary table '||table_temp_rangecode_master||' as 
  select distinct '''||v_product||''' as product,  '''||v_location||''' as location
  , lookup_value as ccrangecode,target_value as master_size_attr, uuid_generate_v4()::text as memberid, 0::int as member_exists
  from eve_l_dependencylookup a
  inner join s5_eve_sizerange_master b on a.lookup_value = b.size_run_name and a.target_value = b.size_attribute
  where 
  lookup_id=''size_range''
  and lookup_value= '''||v_sty_size_range||'''
  ';

s2 := '
  update '||table_temp_rangecode_master||' a set memberid = b.product, member_exists=1 from eve_ma_sizeattributes b 
  where a.product=b.parent_id and a.master_size_attr=b.sizeattribute
  ';

s3 := '
  update eve_ma_sizeattributes set isvalid=0 where parent_id='''||v_product||'''
  ';

s4 := '
  delete from eve_ma_sizeattributes where product in (select memberid from '||table_temp_rangecode_master||')
  ';
 
s5 := ' 
  insert into eve_ma_sizeattributes (product, sizeattribute, parent_id, isvalid)
  select memberid, master_size_attr, product, 1 as isvalid from '||table_temp_rangecode_master||' 
  ';

s6 := '
  delete from eve_d_product where id in (select memberid from '||table_temp_rangecode_master||' where member_exists=0)
  ';
  
s6x := '
  insert into eve_d_product (id, name, description, levelid) select memberid, product||''-''||master_size_attr, product||''-''||master_size_attr, ''stylecolorsize'' 
  from  '||table_temp_rangecode_master||' 
  where member_exists=0
  ';

s7 := '
  delete from eve_h_prodstd where id in (select memberid from '||table_temp_rangecode_master||' where member_exists=0);
  insert into eve_h_prodstd 
  (id,ancestor0,ancestor1,ancestor2,ancestor3,ancestor4,ancestor5,version_id,created_at,created_by,updated_at,updated_by,record_state) 
  select 
  memberid,id,ancestor0,ancestor1,ancestor2,ancestor3,ancestor4,version_id,created_at,created_by,updated_at,updated_by,record_state
  from eve_h_prodstd a, (select memberid,product from  '||table_temp_rangecode_master||'  where member_exists=0) b
  where a.id=b.product
  ';


s8 := '
  update eve_p_dc_adj_size a
  set dc_useradj=null
  where product in (select product from eve_ma_sizeattributes where isvalid = 0 and parent_id='''||v_product||''')
  ';
  
s9 := '
  update eve_ma_stylecolorchannelattributes a
  set cc_validsizes_store = b.master_size_attr_arr
  , cc_validsizes_ecom = b.master_size_attr_arr
  from (select product, array_agg(master_size_attr) as master_size_attr_arr from '||table_temp_rangecode_master||' group by product) b
  where a.product = b.product
  ';
/*
RAISE NOTICE 'INPUT s0:%', 'START:'|| s0;
RAISE NOTICE 'INPUT s1:%', 'START:'|| s1;
RAISE NOTICE 'INPUT s2:%', 'START:'|| s2;
RAISE NOTICE 'INPUT s3:%', 'START:'|| s3;
RAISE NOTICE 'INPUT s4:%', 'START:'|| s4;
RAISE NOTICE 'INPUT s5:%', 'START:'|| s5;
RAISE NOTICE 'INPUT s6:%', 'START:'|| s6;
RAISE NOTICE 'INPUT s7:%', 'START:'|| s7;
RAISE NOTICE 'INPUT s8:%', 'START:'|| s8;
RAISE NOTICE 'INPUT s9:%', 'START:'|| s9;
*/
EXECUTE s0;
EXECUTE s1;
EXECUTE s2;
EXECUTE s3;
EXECUTE s4;
EXECUTE s5;
EXECUTE s6;
EXECUTE s6x;
EXECUTE s7;
EXECUTE s8;
EXECUTE s9;
 
  RETURN NEW;
  END;
$$;


--
-- Name: store_eligibility_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.store_eligibility_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    drop table if exists temp_new;
    drop table if exists temp_old;
    create temporary table temp_new as 
    select b.product,b.location,a.indx,a.time from eve_ma_dptflrsetattributes a, eve_ma_stylecolorchannelattributes b
    where 
    a.product in (select ancestor3 from eve_h_prodstd where id=NEW.product)
    and b.product = NEW.product
    and b.location = NEW.location
    and slsstart <= NEW.exitdate and slsend >= NEW.dbt_wk
    order by indx;
    create temporary table temp_old as 
    select a.product,a.location,str_climate,str_grade,ssg,flnrange,plan_type, style,indx, isfunded, store_count
    from eve_a_assortment a, eve_ma_dptflrsetattributes b
    where b.product in (select ancestor3 from eve_h_prodstd where id=NEW.product)
    and a.product= NEW.product
    and a.location= NEW.location
    and a.time=b.time;
    delete from eve_a_assortment where product = NEW.product and location = NEW.location and plan_type='plan' and EXISTS (select 1 from temp_new) ;
        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||min(indx) from temp_old group by product, location)
        and c.indx < a.indx;

        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||max(indx) from temp_old group by product, location)
        and c.indx > a.indx  
        order by c.indx ;

        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style,isfunded, store_count from 
        temp_old a, 
        temp_new c
        where a.product=c.product and a.location=c.location
        and c.indx = a.indx;

    drop table temp_new;
    drop table temp_old;
    -- Make first floorset funded
    update eve_a_assortment 
    set isfunded = 1 
    from 
        (select d.time, c.product, c.dbt_wk, d.slsstart, d.slsend  from eve_ma_stylecolorchannelattributes as c 
          join (select distinct a.time, a.product, b.slsstart,b.slsend from eve_a_assortment a 
          join (select c.time,slsstart,slsend from eve_ma_dptflrsetattributes c) as b 
        on (a.time=b.time) where a.product=new.product) as d 
    on (c.product=d.product) 
    where c.dbt_wk >= d.slsstart 
    and c.dbt_wk <= d.slsend) filtered 
    where eve_a_assortment.time=filtered.time and eve_a_assortment.product=filtered.product;
 RETURN NEW;
END;
$$;


--
-- Name: store_eligibility_trigger2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.store_eligibility_trigger2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    truncate table tmp_new;
    truncate table tmp_old;

    insert into tmp_new 
    select b.product,b.location,a.indx,a.time from eve_ma_dptflrsetattributes a, eve_ma_stylecolorchannelattributes b
    where 
    a.product in (select ancestor3 from eve_h_prodstd where id=NEW.product)
    and b.product = NEW.product
    and b.location = NEW.location
    and slsstart <= NEW.exitdate and slsend >= NEW.dbt_wk
    order by indx;

    insert into tmp_old
    select a.product,a.location,str_climate,str_grade,ssg,flnrange,plan_type, style,indx, isfunded, store_count
    from eve_a_assortment a, eve_ma_dptflrsetattributes b
    where b.product in (select ancestor3 from eve_h_prodstd where id=NEW.product)
    and a.product= NEW.product
    and a.location= NEW.location
    and a.time=b.time;

    delete from eve_a_assortment where product = NEW.product and location = NEW.location and plan_type='plan' and EXISTS (select 1 from tmp_new) ;
        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count from 
        tmp_old a, 
        tmp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||min(indx) from tmp_old group by product, location)
        and c.indx < a.indx;

        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count from 
        tmp_old a, 
        tmp_new c
        where a.product=c.product and a.location=c.location
        and a.product||a.location||a.indx in (select product||location||max(indx) from tmp_old group by product, location)
        and c.indx > a.indx  
        order by c.indx ;

        insert into eve_a_assortment 
        (product,location,time,str_climate,str_grade,ssg,flnrange,plan_type, style, isfunded, store_count)
        select a.product,a.location,c.time,str_climate,str_grade,ssg,flnrange,plan_type, style,isfunded, store_count from 
        tmp_old a, 
        tmp_new c
        where a.product=c.product and a.location=c.location
        and c.indx = a.indx;

    truncate table tmp_new;
    truncate table tmp_old;
    
    -- Make first floorset funded
    update eve_a_assortment 
    set isfunded = 1 
    from 
        (select d.time, c.product, c.dbt_wk, d.slsstart, d.slsend  from eve_ma_stylecolorchannelattributes as c 
          join (select distinct a.time, a.product, b.slsstart,b.slsend from eve_a_assortment a 
          join (select c.time,slsstart,slsend from eve_ma_dptflrsetattributes c) as b 
        on (a.time=b.time) where a.product=new.product) as d 
    on (c.product=d.product) 
    where c.dbt_wk >= d.slsstart 
    and c.dbt_wk <= d.slsend) filtered 
    where eve_a_assortment.time=filtered.time and eve_a_assortment.product=filtered.product;
 RETURN NEW;
END;
$$;


--
-- Name: strip_dollar_sign_msrp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.strip_dollar_sign_msrp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
  
	NEW.cc_msrp := regexp_replace(NEW.cc_msrp, '[^0-9.]+', '', 'g');

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
    INSERT INTO eve_ma_stylecolor_alloc_attributes (product)
    VALUES (NEW.product)
    ON CONFLICT (product) DO NOTHING;      -- avoids duplicate-key errors
    RETURN NEW;                            -- preserve normal insert behaviour
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
 select max(indx) into maxIndx from eve_v_memberbasedvalidvalues;
 new.indx = maxIndx + 1;
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
    select size_id into curSizeId from size_ids si where si.size_naem = new.sizeattribute;
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
-- Name: update_class_after_subclass(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_class_after_subclass() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
v_subclass text;
v_class text;

BEGIN

select left(sty_subclass_display, 6)
into v_subclass
from eve_ma_styleattributes
where product = new.product
;

select target_value
into v_class
from eve_l_dependencylookup
where lookup_id = 'sty_subclass_display'
and lookup_value = new.sty_subclass_display
;

--RAISE NOTICE 'v_subclass = %', v_subclass;
--RAISE NOTICE 'v_class = %', v_class;
--RAISE NOTICE 'product = %', new.product;

--update style
update eve_h_prodstd
set ancestor0 = v_subclass,
ancestor1 = v_class
where id = new.product
;

--update stylecolor
update eve_h_prodstd
set ancestor1 = v_subclass,
ancestor2 = v_class
where ancestor0 = new.product
;

--update stylecolorsize
update eve_h_prodstd
set ancestor2 = v_subclass,
ancestor3 = v_class
where ancestor1 = new.product
;

RETURN NEW;
END;
$$;


--
-- Name: update_color_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_color_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

  v_style_description eve_d_product.description%type;
  v_style_name eve_d_product.name%type;

BEGIN

  select name, description into v_style_name, v_style_description 
  from eve_d_product where id = (select ancestor0 from eve_h_prodstd where id = NEW.product);

  if NEW.cccolor <> OLD.cccolor then
    update eve_d_product 
    set description = v_style_description || ':' || NEW.cccolor,
        name = v_style_name || ':' || substring(NEW.cccolor from '[^ ]+')
    where id = NEW.product;

    update eve_ma_stylecolorattributes a
    set cccolorfamily = (select target_value from eve_l_dependencylookup 
                         where lookup_id = 'cccolor' and target_id = 'cccolorfamily' and lookup_value = NEW.cccolor
                        )
    where product = NEW.product;
  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_description_style(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_description_style() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

  if NEW.description <> OLD.description then
    update eve_d_product x
    set description = NEW.description
    from 
    (
    	select distinct b.ancestor0
    	from eve_d_product a
		join eve_h_prodstd b
		on a.id = b.id 
		where b.id = NEW.id
	) y
    where x.id = y.ancestor0;

	update eve_d_product x
    set description = sty_desc || ':' || y.cccolor
	from 
	(
		select a.id, c.name as sty_name, c.description as sty_desc, b.cccolor
		from eve_h_prodstd a
		join eve_ma_stylecolorattributes b
		on a.id = b.product 
		join eve_d_product c 
		on a.ancestor0 = c.id
		where a.ancestor0 IN (select distinct ancestor0 from eve_h_prodstd where id = NEW.id)
	) y
    where x.id = y.id;


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
 from eve_p_itemprice 
 where product=NEW.product and location=NEW.location and time=NEW.time;

select ccpriceevent, replace(expression,'cccurp','v_cccurp') into v_ccpriceevent, v_expression 
 from eve_l_priceeventlookup 
 where product=NEW.department and location=NEW.location and ccpriceevent=NEW.event;

select cc_discount_pct::real, ccticketpricechannel::real into v_ccdiscount, v_cccurp
 from eve_ma_stylecolorchannelattributes 
 where product=NEW.product and location=NEW.location;

select cc_current_price::real into v_ticketprice 
 from eve_ma_stylecolorattributes 
 where product =NEW.product;

/*
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
update eve_p_itemprice a set eff_aur=final_eff_aur where product=NEW.product and location=NEW.location and time=NEW.time;

-- update eve_an_price_storecount_info set expressed_aur=final_eff_aur where product=NEW.product and channel=NEW.location and time=NEW.time
--   ;
-- 
-- update eve_an_price_storecount_info a
--   set v_A=b.v_A
-- FROM
--   (select product, time, seq, case when seq=0 then ccticketprice * (1-COALESCE(corpexcl,0)) else curp end as v_A from eve_an_price_storecount_info a
--        WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time) b
-- WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
-- ;
-- 
--   update eve_an_price_storecount_info a
--     set v_B=b.v_B
--   FROM
--     (select product, time, seq, addoff, corpaddoff
--       , case when seq=0 then
--           (case when final_eff_aur > 0 then final_eff_aur else ccticketprice end) * (1 - coalesce(addoff,0)) * (1 - coalesce(corpaddoff,0))
--        else curp end as v_B
--        from eve_an_price_storecount_info a 
--        WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
--     ) b
--   WHERE a.product=NEW.product and a.channel=NEW.location and a.time=NEW.time
--   ;
-- 
-- update eve_an_price_storecount_info set selling_price=(least(v_A,v_B) * (1 - ccdiscountpct))::NUMERIC(16,2)
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
      UPDATE eve_p_stylecolor_store_eligibility
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
    update eve_d_product x
    set description = NEW.description || ':' || y.cccolor,
        name = NEW.name || ':' || y.cccolor
    from (select a.id, b.cccolor from eve_h_prodstd a, eve_ma_stylecolorattributes b where a.id = b.product and a.ancestor0 = NEW.id) y
    where x.id = y.id;

  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_name_style(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_name_style() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

  if NEW.name <> OLD.name then
    update eve_d_product x
    set name = NEW.name
    from 
    (
    	select distinct b.ancestor0
    	from eve_d_product a
		join eve_h_prodstd b
		on a.id = b.id 
		where b.id = NEW.id
	) y
    where x.id = y.ancestor0;

	update eve_d_product x
    set name = sty_name || ':' || y.cccolor
	from 
	(
		select a.id, c.name as sty_name, c.description as sty_desc, b.cccolor
		from eve_h_prodstd a
		join eve_ma_stylecolorattributes b
		on a.id = b.product 
		join eve_d_product c 
		on a.ancestor0 = c.id
		where a.ancestor0 IN (select distinct ancestor0 from eve_h_prodstd where id = NEW.id)
	) y
    where x.id = y.id;


  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_pim_style_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_pim_style_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_dept text;
  v_class text;
  v_subclass text;
  v_index text;
  v_count integer;
BEGIN

  select distinct ancestor2 into v_dept from eve_h_prodstd where id in (NEW.pim_style_id, NEW.product); --Use PIM and product in case new PIM ID is blank. Department will always be the same no matter what;
  select ancestor1 into v_class from eve_h_prodstd where id = NEW.pim_style_id;
  select ancestor0 into v_subclass from eve_h_prodstd where id = NEW.pim_style_id;
  select CAST((max(CAST(index AS integer)) + 1) AS text) into v_index from eve_l_dependencylookup;

  select count(*) into v_count
  from eve_ma_styleattributes where NEW.pim_style_id != '' and product <> pim_style_id and product <> NEW.product and pim_style_id = NEW.pim_style_id;

  if v_count > 0 then 
    NEW.pim_style_id := OLD.pim_style_id;
  else 
    if (OLD.pim_style_id is null and NEW.pim_style_id is not null) or OLD.pim_style_id <> NEW.pim_style_id
    then
      update eve_ma_stylecolorattributes set pim_stylecolor_id = null 
      where product in (select id from eve_h_prodstd where ancestor0 = NEW.product);
  
      if OLD.pim_style_id is not null and OLD.pim_style_id <> ''  -- Prevent target_value of blank from getting inserted
      then
        insert into eve_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
        values('department', v_dept, 'pim_style_id', OLD.pim_style_id, v_index);
      end if;
  
    end if;
  
    if NEW.pim_style_id is not null and NEW.pim_style_id <> ''  -- Prevent class and subclass from being null if new pim id is blank
    then
      delete from eve_l_dependencylookup 
      where lookup_id = 'department' and lookup_value = v_dept 
        and target_id = 'pim_style_id' and target_value = NEW.pim_style_id; 
  
      -- Update class and subclass of the placeholder to match that of the PIM Style ID
        
        --When id is style
        update eve_h_prodstd
        set ancestor1 = v_class
          , ancestor0 = v_subclass
        where id = NEW.product
        ;

        --When ancestor0 is style
        update eve_h_prodstd
        set ancestor2 = v_class
          , ancestor1 = v_subclass
        where ancestor0 = NEW.product
        ;

        --When ancestor1 is style
        update eve_h_prodstd
        set ancestor3 = v_class
          , ancestor2 = v_subclass
        where ancestor1 = NEW.product
        ;

      -- SUP-2261: Update style name and description to that of the PIM ID
        update eve_d_product a
        set name = b.pim_name,
          description = b.pim_description
        from (select id, name as pim_name, description as pim_description from eve_d_product where id = NEW.pim_style_id) b
        where a.id = NEW.product
        ;
		
		
      select a.sty_dept,a.sty_typ,a.sty_subtyp_1,a.sty_style_description,a.sty_vendor_id,a.sty_vendor_name,a.sty_brand_id,a.sty_brand_name,a.sty_source,a.sty_length_height,a.sty_neckline,a.sty_end_use,a.sty_knit_woven,a.sty_development_path,a.sty_product_type,a.sty_fabric_material,a.ccstylecreatedate,a.sty_closure,a.sty_hem_finish,a.sty_waist_rise,a.sty_size_run_name,a.sty_size_run_id, a.erp_style_id
      into NEW.sty_dept,NEW.sty_typ,NEW.sty_subtyp_1,NEW.sty_style_description,NEW.sty_vendor_id,NEW.sty_vendor_name,NEW.sty_brand_id,NEW.sty_brand_name,NEW.sty_source,NEW.sty_length_height,NEW.sty_neckline,NEW.sty_end_use,NEW.sty_knit_woven,NEW.sty_development_path,NEW.sty_product_type,NEW.sty_fabric_material,NEW.ccstylecreatedate,NEW.sty_closure,NEW.sty_hem_finish,NEW.sty_waist_rise,NEW.pim_size_run_name,NEW.pim_size_run_id,NEW.erp_style_id
      from eve_ma_styleattributes a
      where a.product = NEW.pim_style_id;
    end if;
  
    if NEW.sty_size_run_name = NEW.pim_size_run_name and NEW.erp_style_id is not null
    then
        NEW.sty_is_locked = 'Y';
    else
        NEW.sty_is_locked = null;
    end if;
  end if;

	-- SUP-2261: If user assigns a PIM ID then blanks it out, unlock the Style so a new PIM can be assigned
              -- Note that this can only happen before they replan
	if (NEW.pim_style_id = '' or NEW.pim_style_id is null) and (NEW.sty_is_locked = 'Y' or NEW.erp_style_id is not null)
	then
		NEW.sty_is_locked = null;
		NEW.erp_style_id = null;
	end if;
		

  return NEW;
END;
$$;


--
-- Name: update_pim_stylecolor_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_pim_stylecolor_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_sty_size_run_name text;
  v_pim_size_run_name text;
  v_pim_style_id      text;
  v_index             text;
  v_count             integer;
BEGIN

  select sty_size_run_name, pim_size_run_name
    into v_sty_size_run_name, v_pim_size_run_name
  from eve_ma_styleattributes a, eve_h_prodstd b
  where a.product = b.ancestor0 and b.id = NEW.product;

  select pim_style_id 
  into v_pim_style_id 
  from eve_ma_styleattributes
  where product = (select distinct ancestor0 from eve_h_prodstd where id = NEW.product);

  RAISE NOTICE 'v_pim_style_id: %', v_pim_style_id;

  select CAST((max(CAST(index AS integer)) + 1) AS text) 
  into v_index 
  from eve_l_dependencylookup;

  select count(*) 
  into v_count
  from eve_ma_stylecolorattributes 
  where NEW.pim_stylecolor_id != '' 
  and product <> pim_stylecolor_id 
  and product <> NEW.product 
  and pim_stylecolor_id = NEW.pim_stylecolor_id;

  RAISE NOTICE 'v_count: %', v_count;

  if v_count > 0 then 
    NEW.pim_stylecolor_id := OLD.pim_stylecolor_id;
  else 
      if OLD.pim_stylecolor_id is not null 
      then
        insert into eve_l_dependencylookup(lookup_id, lookup_value, target_id, target_value, index)
        values('pim_style_id', v_pim_style_id, 'pim_stylecolor_id', OLD.pim_stylecolor_id, v_index);
      end if;
  
      if NEW.pim_stylecolor_id is not null
      then
        delete from eve_l_dependencylookup 
        where lookup_id = 'pim_style_id' and lookup_value = v_pim_style_id 
          and target_id = 'pim_stylecolor_id' and target_value = NEW.pim_stylecolor_id; 
      end if;
  end if;

  if ((OLD.pim_stylecolor_id is null and NEW.pim_stylecolor_id is not null) or (OLD.pim_stylecolor_id <> NEW.pim_stylecolor_id and NEW.pim_stylecolor_id is not null and NEW.pim_stylecolor_id <> ''))
  then
      select a.erp_stylecolor_id,a.ccstylecolorcreatedate,a.cc_marketing,a.cc_floorset,a.cc_pim_status,a.cc_pim_first_available_date,a.cc_pim_discontinue_date,a.cc_first_inv_date,a.cc_last_rec_date,a.cc_weighted_rec_date,a.cc_first_md_date,a.cc_last_md_date,a.cc_pricing_tier,a.cc_image_url,a.cc_description,a.cc_c_mh_ss,a.cc_exclusive,a.cc_print_pattern,a.cc_denim_wash,a.cccolor,a.cccolorfamily,a.cc_color_code,a.cc_msrp,a.cc_current_price,a.cc_estimated_cost,a.cc_actual_cost,a.cc_style_group,a.cc_rtv,a.cc_fulfillment,a.cc_cc_plan
      into NEW.erp_stylecolor_id,NEW.ccstylecolorcreatedate,NEW.cc_marketing,NEW.cc_floorset,NEW.cc_pim_status,NEW.cc_pim_first_available_date,NEW.cc_pim_discontinue_date,NEW.cc_first_inv_date,NEW.cc_last_rec_date,NEW.cc_weighted_rec_date,NEW.cc_first_md_date,NEW.cc_last_md_date,NEW.cc_pricing_tier,NEW.cc_image_url,NEW.cc_description,NEW.cc_c_mh_ss,NEW.cc_exclusive,NEW.cc_print_pattern,NEW.cc_denim_wash,NEW.cccolor,NEW.cccolorfamily,NEW.cc_color_code,NEW.cc_msrp,NEW.cc_current_price,NEW.cc_estimated_cost,NEW.cc_actual_cost,NEW.cc_style_group,NEW.cc_rtv,NEW.cc_fulfillment,NEW.cc_cc_plan
      from eve_ma_stylecolorattributes a
      where a.product = NEW.pim_stylecolor_id;
  end if;

  if NEW.erp_stylecolor_id is not null and v_sty_size_run_name = v_pim_size_run_name
  then
      NEW.cc_is_locked = 'Y';
  else
      NEW.cc_is_locked = null;
  end if;

  return NEW;
END;
$$;


--
-- Name: update_sty_brand_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_sty_brand_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_brand_source text;
BEGIN

  select target_value into v_brand_source
  from eve_l_dependencylookup
  where lookup_id = 'brand_name' and target_id = 'brand_source'
  and upper(lookup_value) = upper(NEW.sty_brand_name);
  --We find a record in default_eve_l_dependencylookup for owned brand if s0 is not null. Currently only Evereve and SOLSET
  if v_brand_source is not null then
    NEW.sty_source = v_brand_source;
  else
    NEW.sty_source = 'Branded';
  end if;

  RETURN NEW;
END;
$$;


--
-- Name: update_sty_vendor_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_sty_vendor_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

s1 text;

BEGIN

NEW.sty_development_path = null;

select target_value into NEW.sty_development_path
from eve_l_dependencylookup
where lookup_id = 'vendor_name' and target_id = 'direct_import'
and upper(lookup_value) = upper(NEW.sty_vendor_name)
;

  return NEW;

END;
$$;


--
-- Name: update_stylecolorattr_class_suclass_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_stylecolorattr_class_suclass_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_class_name_new    text;
	v_subclass_name_new text;
BEGIN

--RAISE NOTICE 'new.id: %', new.id;
--RAISE NOTICE 'old.ancestor1: %', old.ancestor1;
--RAISE NOTICE 'new.ancestor1: %', new.ancestor1;

  select cls.name
  into v_class_name_new
  from eve_h_prodstd a
  join eve_d_product cls
  on a.ancestor1 = cls.id
  where a.id = new.id;

  select subcls.name
  into v_subclass_name_new
  from eve_h_prodstd a
  join eve_d_product subcls
  on a.ancestor0 = subcls.id
  where a.id = new.id;

--RAISE NOTICE 'v_class_name_new: %', v_class_name_new;
--RAISE NOTICE 'v_subclass_name_new: %', v_subclass_name_new;
 
  update eve_ma_stylecolorattributes
  set class_name    = v_class_name_new,
      subclass_name = v_subclass_name_new
  where product in (select id from eve_h_prodstd where ancestor0 = new.id);

  RETURN NEW;
END;
$$;


--
-- Name: update_stylecolorchannelattributes_ccrangecode(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_stylecolorchannelattributes_ccrangecode() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

s0 text;
s1 text;

v_uuid_temp text;
v_uuid text;

table_temp_sub_exists text;
table_temp_sub_not_exists text;

v_style text;
v_new_ccrangecode text;
v_old_sty_size_run_name text;
v_new_sty_size_run_name text;


BEGIN

-- this part is specific to style attribute sty_size_run_name changing
-- need to make another rendition of this for class changing

--RAISE NOTICE 'product: %', NEW.product;

if NEW.sty_size_run_name <> OLD.sty_size_run_name and OLD.sty_is_locked is null then

  select id into v_style from eve_d_product where levelid='style' and id=NEW.product;
  select  OLD.sty_size_run_name into v_old_sty_size_run_name;

  select NEW.sty_size_run_name into v_new_sty_size_run_name;
  
  select NEW.sty_size_run_name||' - '||ancestor1 into v_new_ccrangecode
  from
      eve_h_prodstd
  where
      id=v_style
  limit 1;

  
  EXECUTE '(select uuid_generate_v4()::text)' into v_uuid_temp;
  EXECUTE '(select replace('''||v_uuid_temp||''',''-'',''_'')::text)' into v_uuid;
  
  table_temp_sub_exists:= 'table_temp_sub_exists'||v_uuid;
  table_temp_sub_not_exists:= 'table_temp_sub_not_exists'||v_uuid;
  
  -- update ccsizerange based on updated express_size_range and or class info
  
  s0 := 'create temporary table '||table_temp_sub_exists||' as
      select a.product, a.ccrangecode as old_ccrangecode, '''||v_new_ccrangecode||''' new_ccrangecode
      from eve_ma_stylecolorchannelattributes a
      where product in (select id from eve_h_prodstd where ancestor0='''||v_style||''')
      ';
   --RAISE NOTICE 'S0:%', 'START:'|| s0;
  
  
  s1 := 'UPDATE eve_ma_stylecolorchannelattributes a
  set ccrangecode=b.new_ccrangecode
     ,cc_validsizes_store=c.validsizes
     ,cc_validsizes_ecom=c.validsizes
  from '||table_temp_sub_exists||' b, (select array_agg(target_value) as validsizes, lookup_value as sty_size_run_name from eve_l_dependencylookup where lookup_value = '''||v_new_sty_size_run_name||''' and lookup_id = ''size_range'' group by lookup_value) c
  where a.product=b.product
  and b.new_ccrangecode is not null
  and a.product in (select product from '||table_temp_sub_exists||' where new_ccrangecode is not null)
  ';

  
   --RAISE NOTICE 'S1:%', 'START:'|| s1;
  
  
  EXECUTE s0;
  EXECUTE s1;

ELSE

  update eve_ma_styleattributes set sty_size_run_name = OLD.sty_size_run_name where product = NEW.product;

end if;

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
  if NEW.cc_msrp <> OLD.cc_msrp then
    update eve_ma_stylecolorchannelattributes
    set ccticketpricechannel = cast(NEW.cc_msrp as real)
    where product = NEW.product;

  end if;

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
    select b.product,b.location,a.indx,a.time from eve_ma_dptflrsetattributes a, cart_params_temp b, 
    (select value as plan_current from eve_serviceparams where id='plan_current') c,
    (select value as plan_end from eve_serviceparams where id='plan_end') d
    where 
    a.product=b.product
    and b.product = NEW.scope_product
    and b.location = NEW.scope_location
    and slsstart <= least(plan_end,exitdate) and slsend > greatest(dbt_wk,plan_current)
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
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_climate,str_grade,ssg,flnrange,isfunded,store_count, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_climate,str_grade,ssg,flnrange,isfunded,store_count, c.indx from 
    temp_old a, temp_new c
    where a.scope_product=c.product and a.scope_location=c.location
    and a.scope_product||a.scope_location||a.indx in (select scope_product||scope_location||min(indx) from temp_old group by scope_product, scope_location)
    and c.indx < a.indx ;

    insert into cart_ranging
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_climate,str_grade,ssg,flnrange,isfunded,store_count, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_climate,str_grade,ssg,flnrange,isfunded,store_count, c.indx from 
    temp_old a, temp_new c
    where a.scope_product=c.product and a.scope_location=c.location
    and a.scope_product||a.scope_location||a.indx in (select scope_product||scope_location||max(indx) from temp_old group by scope_product, scope_location)
    and c.indx > a.indx ;

    insert into cart_ranging
    (jsessionid,scope_product,scope_location,scope_start,scope_floorset,str_climate,str_grade,ssg,flnrange,isfunded,store_count, indx)
    select a.jsessionid,scope_product,scope_location,scope_start,c.time,str_climate,str_grade,ssg,flnrange,isfunded,store_count, c.indx from 
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
v_mdstart_indx int;
v_lastdcorder_indx int;
v_exitdate_indx int;
v_initrcptwk text;
v_lastdcorder text;
v_floorset text;
v_foorset_month text;

BEGIN
--v_irw_indx := (select indx from eve_d_time where id =''||NEW.initrcptwk||'');
v_dbtwk_indx := (select indx from eve_d_time where id = ''||NEW.dbt_wk||'');
v_mdstart_indx := (select indx  from eve_d_time where id = ''||NEW.erlstmkdnwk||'');
--v_lastdcorder_indx := (select indx from eve_d_time where id =''||NEW.lastdcorder||'');
v_exitdate_indx := (select indx  from eve_d_time where id = ''||NEW.exitdate||'');

v_irw_indx := v_dbtwk_indx;
v_initrcptwk := (select id from eve_d_time where indx= v_irw_indx);
v_lastdcorder_indx := v_mdstart_indx - 6;
v_lastdcorder := (select id from eve_d_time where indx= v_lastdcorder_indx);

select target_value 
into v_floorset
from eve_l_dependencylookup 
where lookup_id = 'dbt_wk' 
and lookup_value = NEW.dbt_wk
;

--RAISE NOTICE 'v_floorset = %', v_floorset;

select target_value 
into v_foorset_month
from eve_l_dependencylookup 
where lookup_id = 'cc_floorset' 
and lookup_value = v_floorset
;

--RAISE NOTICE 'v_foorset_month = %', v_foorset_month ;

if (NEW.dbt_wk != OLD.dbt_wk AND OLD.dbt_wk = OLD.act_dbt_wk and new.dbt_wk < new.erlstmkdnwk and old.dbt_wk >= old.plan_current) then
    
    UPDATE eve_ma_stylecolorchannelattributes
    SET act_dbt_wk = NEW.dbt_wk
    WHERE
    product = NEW.product
    and location = NEW.location;

end if;

if (new.dbt_wk < new.erlstmkdnwk AND new.erlstmkdnwk < new.exitdate AND (old.dbt_wk > old.plan_current OR old.exitdate > old.plan_current) AND new.exitdate > new.erlstmkdnwk)
then
  update eve_ma_stylecolorchannelattributes
  set 
  irw_indx = v_irw_indx,
  dbtwk_indx = v_dbtwk_indx,
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

  update eve_ma_stylecolorattributes
  set 
	cc_floorset = v_floorset,
	cc_fulfillment = v_foorset_month
  WHERE 
  product = NEW.product
  ;

end if;

RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dimensions; Type: TABLE; Schema: debug; Owner: -
--

CREATE TABLE debug.dimensions (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies; Type: TABLE; Schema: debug; Owner: -
--

CREATE TABLE debug.hierarchies (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: actuals_stage_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_stage_wide (
    id text NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    invadj_u double precision NOT NULL,
    invadj_r double precision NOT NULL,
    invadj_c double precision NOT NULL,
    donations_u double precision NOT NULL,
    donations_r double precision NOT NULL,
    donations_c double precision NOT NULL
);


--
-- Name: actuals_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide (
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    invadj_u double precision NOT NULL,
    invadj_r double precision NOT NULL,
    invadj_c double precision NOT NULL,
    donations_u double precision NOT NULL,
    donations_r double precision NOT NULL,
    donations_c double precision NOT NULL,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: actuals_wide_bk; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_bk (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: actuals_wide_bk20240506; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_bk20240506 (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision
);


--
-- Name: actuals_wide_bk20250707; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_bk20250707 (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: actuals_wide_bkp_20240312; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_bkp_20240312 (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
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
 SELECT channel.id AS channel
   FROM ( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'location'::text) AND (dimensions.levelid = 'channel'::text))) channel;


--
-- Name: product_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.product_denorm AS
 SELECT total_product.id AS total_product,
    division.id AS division,
    department.id AS department,
    class.id AS class
   FROM (((( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'product'::text) AND (dimensions.levelid = 'class'::text))) class
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = class.id) AND (hierarchies.hierarchy = 'prodstd'::text))) department ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = department.id) AND (hierarchies.hierarchy = 'prodstd'::text))) division ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = division.id) AND (hierarchies.hierarchy = 'prodstd'::text))) total_product ON (true));


--
-- Name: time_denorm; Type: VIEW; Schema: mfp; Owner: -
--

CREATE VIEW mfp.time_denorm AS
 SELECT season.id AS season,
    quarter.id AS quarter,
    month.id AS month
   FROM ((( SELECT dimensions.id
           FROM mfp.dimensions
          WHERE ((dimensions.dimension = 'time'::text) AND (dimensions.levelid = 'month'::text))) month
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = month.id) AND (hierarchies.hierarchy = 'timestd'::text))) quarter ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM mfp.hierarchies
          WHERE ((hierarchies.id = quarter.id) AND (hierarchies.hierarchy = 'timestd'::text))) season ON (true));


--
-- Name: actuals_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp; Owner: -
--

CREATE MATERIALIZED VIEW mfp.actuals_wide_denorm AS
 SELECT DISTINCT ON (wide."time", wide.product, wide.location) "time".month AS time_month,
    "time".season AS time_season,
    product.class AS product_class,
    product.department AS product_department,
    product.total_product AS product_total_product,
    location.channel AS location_channel,
    wide."time",
    wide.product,
    wide.location,
    wide.ttl_storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_c,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.pos_md_r,
    wide.perm_md_r,
    wide.invadj_u,
    wide.invadj_r,
    wide.invadj_c,
    wide.donations_u,
    wide.donations_r,
    wide.donations_c,
    wide.balance_internal_r,
    wide.balance_internal_u,
    wide.balance_internal_c
   FROM (((mfp.actuals_wide wide
     JOIN ( SELECT time_denorm.month,
            time_denorm.season
           FROM mfp.time_denorm) "time" ON (("time".month = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department,
            product_denorm.total_product
           FROM mfp.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.channel
           FROM mfp.location_denorm) location ON ((location.channel = wide.location)))
  WITH NO DATA;


--
-- Name: actuals_wide_next; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_next (
    product text,
    location text,
    "time" text,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision,
    boh_r_next double precision,
    boh_u_next double precision,
    boh_c_next double precision
);


--
-- Name: actuals_wide_pre_cal_change; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_pre_cal_change (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: actuals_wide_xfer; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.actuals_wide_xfer (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision
);


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
-- Name: delete_me_plan_data_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.delete_me_plan_data_wide (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    invadj_u double precision NOT NULL,
    invadj_r double precision NOT NULL,
    invadj_c double precision NOT NULL,
    donations_u double precision NOT NULL,
    donations_r double precision NOT NULL,
    donations_c double precision NOT NULL,
    eventdate date,
    updated_at timestamp without time zone
);


--
-- Name: deleteme2_plan_data_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.deleteme2_plan_data_wide (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_good_plan_data_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.deleteme_good_plan_data_wide (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: dimensions_bk20240402; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_bk20240402 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_bk20240506; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_bk20240506 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_bk20250707; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_bk20250707 (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_pre_cal_change; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_pre_cal_change (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: dimensions_xfer; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.dimensions_xfer (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies_bk20240402; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_bk20240402 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_bk20240506; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_bk20240506 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_bk20250707; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_bk20250707 (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_pre_cal_change; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_pre_cal_change (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_temp; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_temp (
    dimension text,
    hierarchy text,
    id text,
    ancestor text
);


--
-- Name: hierarchies_xfer; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.hierarchies_xfer (
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
    location text NOT NULL
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
-- Name: plan_data_wide; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    invadj_u double precision NOT NULL,
    invadj_r double precision NOT NULL,
    invadj_c double precision NOT NULL,
    donations_u double precision NOT NULL,
    donations_r double precision NOT NULL,
    donations_c double precision NOT NULL,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: plan_data_wide_archives; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_archives (
    id integer NOT NULL,
    "time" text NOT NULL,
    product text NOT NULL,
    location text NOT NULL,
    ttl_storecount double precision NOT NULL,
    net_sls_u double precision NOT NULL,
    net_sls_r double precision NOT NULL,
    net_sls_c double precision NOT NULL,
    boh_r double precision NOT NULL,
    boh_u double precision NOT NULL,
    boh_c double precision NOT NULL,
    eoh_u double precision NOT NULL,
    eoh_r double precision NOT NULL,
    eoh_c double precision NOT NULL,
    rec_u double precision NOT NULL,
    rec_c double precision NOT NULL,
    rec_r double precision NOT NULL,
    on_order_u double precision NOT NULL,
    on_order_c double precision NOT NULL,
    on_order_r double precision NOT NULL,
    pos_md_r double precision NOT NULL,
    perm_md_r double precision NOT NULL,
    invadj_u double precision NOT NULL,
    invadj_r double precision NOT NULL,
    invadj_c double precision NOT NULL,
    donations_u double precision NOT NULL,
    donations_r double precision NOT NULL,
    donations_c double precision NOT NULL,
    balance_internal_r double precision NOT NULL,
    balance_internal_u double precision NOT NULL,
    balance_internal_c double precision NOT NULL
);


--
-- Name: plan_data_wide_bk20240506; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_bk20240506 (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision
);


--
-- Name: plan_data_wide_pre_cal_change; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_pre_cal_change (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: plan_data_wide_xfer; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.plan_data_wide_xfer (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision
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
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: sys_gen_wide_denorm; Type: MATERIALIZED VIEW; Schema: mfp; Owner: -
--

CREATE MATERIALIZED VIEW mfp.sys_gen_wide_denorm AS
 SELECT wide.sys_version,
    "time".month AS time_month,
    "time".season AS time_season,
    product.class AS product_class,
    product.department AS product_department,
    product.total_product AS product_total_product,
    location.channel AS location_channel,
    wide."time",
    wide.product,
    wide.location,
    wide.ttl_storecount,
    wide.net_sls_u,
    wide.net_sls_r,
    wide.net_sls_c,
    wide.boh_r,
    wide.boh_u,
    wide.boh_c,
    wide.eoh_u,
    wide.eoh_r,
    wide.eoh_c,
    wide.rec_u,
    wide.rec_c,
    wide.rec_r,
    wide.on_order_u,
    wide.on_order_c,
    wide.on_order_r,
    wide.pos_md_r,
    wide.perm_md_r,
    wide.invadj_u,
    wide.invadj_r,
    wide.invadj_c,
    wide.donations_u,
    wide.donations_r,
    wide.donations_c,
    wide.balance_internal_r,
    wide.balance_internal_u,
    wide.balance_internal_c
   FROM (((mfp.sys_gen_wide wide
     JOIN ( SELECT time_denorm.month,
            time_denorm.season
           FROM mfp.time_denorm) "time" ON (("time".month = wide."time")))
     JOIN ( SELECT product_denorm.class,
            product_denorm.department,
            product_denorm.total_product
           FROM mfp.product_denorm) product ON ((product.class = wide.product)))
     JOIN ( SELECT location_denorm.channel
           FROM mfp.location_denorm) location ON ((location.channel = wide.location)))
  WITH NO DATA;


--
-- Name: temp_tyly; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.temp_tyly (
    ty text,
    ly text
);


--
-- Name: tyly; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly (
    ty text NOT NULL,
    ly text NOT NULL
);


--
-- Name: tyly_bk20240506; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly_bk20240506 (
    ty text,
    ly text
);


--
-- Name: tyly_bk20250707; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly_bk20250707 (
    ty text,
    ly text
);


--
-- Name: tyly_pre_cal_change; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.tyly_pre_cal_change (
    ty text,
    ly text
);


--
-- Name: user_kv_store; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.user_kv_store (
    key text NOT NULL,
    uid text NOT NULL,
    value text NOT NULL
);


--
-- Name: user_metadata; Type: TABLE; Schema: mfp; Owner: -
--

CREATE TABLE mfp.user_metadata (
    uid text NOT NULL,
    name text,
    email text,
    updated_at timestamp with time zone
);


--
-- Name: comments; Type: TABLE; Schema: migrate; Owner: -
--

CREATE TABLE migrate.comments (
    comment_id uuid,
    author text,
    plan_id integer,
    view_context text,
    view_template_id text,
    content text,
    modified_at timestamp with time zone
);


--
-- Name: plan_data_wide; Type: TABLE; Schema: migrate; Owner: -
--

CREATE TABLE migrate.plan_data_wide (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: plan_init_status; Type: TABLE; Schema: migrate; Owner: -
--

CREATE TABLE migrate.plan_init_status (
    id integer,
    seeded_at timestamp with time zone,
    balanced_at timestamp with time zone
);


--
-- Name: plans; Type: TABLE; Schema: migrate; Owner: -
--

CREATE TABLE migrate.plans (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: tyly; Type: TABLE; Schema: migrate; Owner: -
--

CREATE TABLE migrate.tyly (
    ty text,
    ly text
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
-- Name: assort_period_from_dpt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assort_period_from_dpt (
    department text NOT NULL,
    "time" text NOT NULL,
    floorset text
);


--
-- Name: ata_debug; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_debug (
    run_id text,
    step text,
    captured_at timestamp with time zone DEFAULT clock_timestamp(),
    payload jsonb
);


--
-- Name: ata_trace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ata_trace (
    run_id text,
    seq integer,
    step text,
    sql_text text,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    duration_ms numeric,
    rows_affected bigint,
    sqlstate text,
    err_msg text,
    err_detail text
);


--
-- Name: ata_trace_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ata_trace_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


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
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk real,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text
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
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk real,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text
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
    str_climate text[],
    str_grade text[],
    ssg text[],
    flnrange text[],
    isfunded integer,
    indx integer,
    store_count integer
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
    str_climate text[],
    str_grade text[],
    ssg text[],
    flnrange text[],
    isfunded integer,
    indx integer,
    store_count integer
);


--
-- Name: culprit2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.culprit2 (
    product text
);


--
-- Name: culprits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.culprits (
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
-- Name: default_cart_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_cart_params (
    jsessionid text,
    default_initrcptwk text,
    default_dbt_wk text,
    default_too smallint,
    default_mkdnwks smallint,
    default_last_inv_wk text,
    default_lstfpwk text,
    default_last_rcpt_wk text,
    default_erlstmkdnwk text,
    default_exitdate text,
    strclimate text[],
    grade text[],
    ssg text[],
    flnrange text[],
    default_ccmdstrategy text,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint text,
    default_ccordermultiple text,
    default_ccordpolicy text,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text
);


--
-- Name: default_disc_md; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_disc_md (
    department text,
    default_discount numeric(16,4),
    default_md text
);


--
-- Name: delete_eve_a_assortment_null_ssg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_eve_a_assortment_null_ssg (
    product text,
    "time" text,
    str_climate text[],
    str_grade text[],
    ssg text[]
);


--
-- Name: delete_eve_h_prodstd_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_eve_h_prodstd_20240712 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: delete_eve_ma_stylecolorchannelattributes_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_eve_ma_stylecolorchannelattributes_20240712 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real
);


--
-- Name: delete_eve_ma_stylecolorchannelattributes_bk_20240707; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_eve_ma_stylecolorchannelattributes_bk_20240707 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real
);


--
-- Name: delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delete_me (
    s5_id text,
    client_pim_id text
);


--
-- Name: deleteme_bad_choices_to_be_planned; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_bad_choices_to_be_planned (
    product text
);


--
-- Name: deleteme_cart_master_20240730; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_master_20240730 (
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
    job_priority integer
);


--
-- Name: deleteme_cart_master_jr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_master_jr (
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
    job_priority integer
);


--
-- Name: deleteme_cart_param_jr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_param_jr (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
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
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk real
);


--
-- Name: deleteme_cart_params_20240730; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_params_20240730 (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    initrcptwk text,
    dbt_wk text,
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
    ccrcptint integer,
    ccordermultiple integer,
    ccordpolicy text,
    slsrnk real
);


--
-- Name: deleteme_cart_ranging_20240730; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_ranging_20240730 (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_climate text[],
    str_grade text[],
    ssg text[],
    flnrange text[],
    isfunded integer,
    indx integer,
    store_count integer
);


--
-- Name: deleteme_cart_ranging_jr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_cart_ranging_jr (
    jsessionid text,
    scope_product text,
    scope_location text,
    scope_start text,
    scope_floorset text,
    str_climate text[],
    str_grade text[],
    ssg text[],
    flnrange text[],
    isfunded integer,
    indx integer,
    store_count integer
);


--
-- Name: deleteme_conversion_dec2025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_conversion_dec2025 (
    product text,
    pim_stylecolor_id text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    record_state smallint,
    plan_current text,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text
);


--
-- Name: deleteme_eve_d_product_bk_20260304; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_d_product_bk_20260304 (
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
-- Name: deleteme_eve_h_prodstd_bk_20260304; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_h_prodstd_bk_20260304 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_eve_ma_sizeattributes_20240723; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_sizeattributes_20240723 (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_eve_ma_sizeattributes_bk_20260304; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_sizeattributes_bk_20260304 (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_eve_ma_sizeattributes_validsizes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_sizeattributes_validsizes (
    parent_id text,
    valid_size_attributes text
);


--
-- Name: deleteme_eve_ma_styleattributes_bk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_styleattributes_bk (
    product text,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: deleteme_eve_ma_stylecolorattributes_sup2981; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_stylecolorattributes_sup2981 (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp text,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost text,
    cc_cancel_date text,
    cc_trend text,
    marketing_comments text
);


--
-- Name: deleteme_eve_ma_stylecolorchannelattributes_20251007; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_stylecolorchannelattributes_20251007 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text
);


--
-- Name: deleteme_eve_ma_stylecolorchannelattributes_20251208; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_eve_ma_stylecolorchannelattributes_20251208 (
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
    irw_indx integer,
    dbtwk_indx integer,
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_landed_cost real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    sclr_presmin real
);


--
-- Name: deleteme_fix_validsizes_conversion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_fix_validsizes_conversion (
    stylecolor text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    size_attributes text,
    invalid_sizes text,
    new_valid_sizes_store_ecom text
);


--
-- Name: deleteme_invalidsizes_in_validsizes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_invalidsizes_in_validsizes (
    stylecolor text,
    validsizes text
);


--
-- Name: deleteme_jrtest_intraday_deptplanitems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_jrtest_intraday_deptplanitems (
    product text
);


--
-- Name: deleteme_mfp_plan_data_wide_20250619; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plan_data_wide_20250619 (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_mfp_plan_data_wide_20250619_opbackup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plan_data_wide_20250619_opbackup (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_mfp_plan_data_wide_20250707; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plan_data_wide_20250707 (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_mfp_plan_data_wide_20250707_opbackup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plan_data_wide_20250707_opbackup (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_mfp_plan_data_wide_20250708; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plan_data_wide_20250708 (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: deleteme_mfp_plans_20250619; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plans_20250619 (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: deleteme_mfp_plans_20250619_opbackup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plans_20250619_opbackup (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: deleteme_mfp_plans_20250707; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plans_20250707 (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: deleteme_mfp_plans_20250707_opbackup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plans_20250707_opbackup (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: deleteme_mfp_plans_20250708; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_mfp_plans_20250708 (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: deleteme_newvalidsizes_for_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_newvalidsizes_for_issues (
    stylecolor text,
    validsizes text
);


--
-- Name: deleteme_replannable_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_replannable_items (
    product text,
    location text
);


--
-- Name: deleteme_sup_3917_fix_a_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_sup_3917_fix_a_assortment (
    id text,
    ancestor0 text,
    product text,
    style text
);


--
-- Name: deleteme_tmp_eve_l_dependencylookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_tmp_eve_l_dependencylookup (
    lookup_id text,
    lookup_value text,
    target_id text,
    target_value text,
    rnk bigint
);


--
-- Name: deleteme_tmp_eve_v_memberbasedvalidvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleteme_tmp_eve_v_memberbasedvalidvalues (
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
-- Name: dept_plan_items_adhoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items_adhoc (
    product text,
    location text,
    department text
);


--
-- Name: dept_plan_items_bk_20250130; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dept_plan_items_bk_20250130 (
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
-- Name: eve_a_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    style text,
    str_climate text[],
    str_grade text[],
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
    is_sclr_flrset_locked text
);


--
-- Name: eve_a_assortment_20240412; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment_20240412 (
    product text,
    location text,
    "time" text,
    style text,
    str_climate text[],
    str_grade text[],
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
    record_state smallint
);


--
-- Name: eve_a_assortment_bk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment_bk (
    product text,
    location text,
    "time" text,
    style text,
    str_climate text[],
    str_grade text[],
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
    record_state smallint
);


--
-- Name: eve_a_assortment_bk_20251208; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment_bk_20251208 (
    product text,
    location text,
    "time" text,
    style text,
    str_climate text[],
    str_grade text[],
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
    record_state smallint
);


--
-- Name: eve_a_assortment_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment_pre_cal_change (
    product text,
    location text,
    "time" text,
    style text,
    str_climate text[],
    str_grade text[],
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
    record_state smallint
);


--
-- Name: eve_a_assortment_storecount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_a_assortment_storecount (
    product text,
    "time" text,
    location text,
    str_grade text[],
    str_climate text[],
    ssg text[],
    department text,
    store_count integer
);


--
-- Name: eve_all_sizes_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_all_sizes_sup_2656 (
    style text,
    stylecolor text,
    stylecolorsize text,
    sty_size_run_name text,
    valid_sizes text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: eve_an_price_storecount_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_an_price_storecount_info (
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
-- Name: eve_authorization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_authorization (
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
-- Name: eve_c_conversion_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct integer,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr integer,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean
);


--
-- Name: eve_c_conversion_file_delta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file_delta (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct real,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr real,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean,
    sclr_presmin real
);


--
-- Name: eve_c_conversion_file_delta_20251208; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file_delta_20251208 (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct real,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr real,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean,
    sclr_presmin real
);


--
-- Name: eve_c_conversion_file_delta_20251208_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file_delta_20251208_lifecycle (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct real,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr real,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean,
    sclr_presmin real,
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
-- Name: eve_c_conversion_file_delta_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file_delta_lifecycle (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct real,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr real,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean,
    sclr_presmin real,
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
-- Name: eve_c_conversion_file_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_file_lifecycle (
    stylecolorpim_id text,
    stylecolor_name text,
    subclass_id text,
    class_id text,
    department_id text,
    brand_name text,
    cc_store_vol_grade text[],
    cc_store_climate text,
    ssg text,
    cc_size_run_name text,
    cc_valid_sub_size_range text,
    cc_valid_size_store_id text[],
    cc_valid_size_ecom_id text[],
    cc_discount_pct integer,
    cc_presmin integer,
    cc_presmin_weeks integer,
    cc_pssr integer,
    cc_dbt_wk text,
    cc_md_week text,
    cc_exitdate text,
    cc_md_strategy text,
    cc_receipt_interval integer,
    auto_roll_forward boolean,
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
-- Name: eve_c_conversion_history_lifecycle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_history_lifecycle (
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
    sty_size_run_name text
);


--
-- Name: eve_c_conversion_history_stylecolorchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_history_stylecolorchannelattributes (
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
    slsrnk integer,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct numeric,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    cc_landed_cost real,
    irr_mode text,
    plan_current text
);


--
-- Name: eve_c_conversion_history_validsizes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_conversion_history_validsizes (
    product text,
    valid_sizes text
);


--
-- Name: eve_c_cutover_history_a_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_cutover_history_a_assortment (
    product text,
    location text,
    "time" text,
    style text,
    str_climate text[],
    str_grade text[],
    ssg text[],
    store_count integer
);


--
-- Name: eve_c_cutover_prep_actuals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_cutover_prep_actuals (
    product text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    wac real,
    validsizes text[]
);


--
-- Name: eve_c_cutover_prep_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_c_cutover_prep_history (
    product text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    initrcptwk text,
    wac real,
    validsizes text[]
);


--
-- Name: eve_corpdisc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_corpdisc (
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_corpdisc_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_corpdisc_backup (
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
    record_state smallint
);


--
-- Name: eve_d_cluster; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_cluster (
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
-- Name: eve_d_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_location (
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
-- Name: eve_d_prodlife; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_prodlife (
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
-- Name: eve_d_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_product (
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
-- Name: eve_d_product_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_product_20240712 (
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
-- Name: eve_d_product_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_product_intraday (
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
-- Name: eve_d_time; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_d_time (
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
-- Name: eve_designimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_designimages (
    product text,
    img text
);


--
-- Name: eve_eohdata_stylecolor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_eohdata_stylecolor (
    product text,
    channel text,
    eohu real
);


--
-- Name: eve_h_clusterstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_clusterstd (
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
-- Name: eve_h_locdc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_locdc (
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
-- Name: eve_h_locdcstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_locdcstd (
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
-- Name: eve_h_locstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_locstd (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_h_prodlifestd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodlifestd (
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
-- Name: eve_h_prodstd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodstd (
    id text NOT NULL,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_h_prodstd_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodstd_20240712 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_h_prodstd_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodstd_intraday (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_h_prodstd_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodstd_sup_2656 (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_h_prodstd_sup_2656_pre_delete; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_prodstd_sup_2656_pre_delete (
    id text,
    ancestor0 text,
    ancestor1 text,
    ancestor2 text,
    ancestor3 text,
    ancestor4 text,
    ancestor5 text,
    ancestor6 text,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_h_timeflrset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_timeflrset (
    id text NOT NULL,
    ancestor0 text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_h_timestd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_h_timestd (
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
-- Name: eve_invalid_sizes_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_invalid_sizes_sup_2656 (
    style text,
    stylecolor text,
    stylecolorsize text,
    sty_size_run_name text,
    valid_sizes text,
    sizeattribute text,
    isvalid integer
);


--
-- Name: eve_l_dclookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_dclookup (
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
-- Name: eve_l_dependencylookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_dependencylookup (
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
-- Name: eve_l_dependencylookup_bkp_03012025_size_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_dependencylookup_bkp_03012025_size_range (
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
-- Name: eve_l_priceeventlookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_priceeventlookup (
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
-- Name: eve_l_ssglookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_ssglookup (
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
-- Name: eve_l_storedclookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_storedclookup (
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
-- Name: eve_l_storelookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_l_storelookup (
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
-- Name: eve_ma_departmentalloc_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_departmentalloc_attributes (
    product text NOT NULL,
    alloc_rule_fair_share boolean DEFAULT false,
    alloc_rule_layered boolean DEFAULT true,
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
    alloc_rule_curr_oh boolean DEFAULT false,
    min_shortfall_policy boolean DEFAULT true,
    overflow_ok boolean DEFAULT true,
    round_robin_excess_global boolean DEFAULT true,
    treat_alloc_min_as_minorder boolean DEFAULT false,
    ecomm_need_as_moq boolean DEFAULT true,
    have_max_num_stores_with_packs boolean DEFAULT true,
    assign_pack_to_zero_ideal boolean DEFAULT true,
    allow_scaling boolean DEFAULT true,
    default_allocation_basis text DEFAULT 'Assortment'::text
);


--
-- Name: eve_ma_departmentalloc_attributes_bkp_02112025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_departmentalloc_attributes_bkp_02112025 (
    product text,
    alloc_rule_fair_share boolean,
    alloc_rule_layered boolean,
    alloc_rule_curr_oh boolean,
    alloc_fcst_asst_plan boolean,
    alloc_fcst_recalib boolean,
    alloc_rule_adjust_dbt boolean,
    alloc_rule_adjust_md boolean,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    alloc_ecom_rsv_alloc_min boolean,
    alloc_ecom_rsv_alloc_exact boolean,
    alloc_aps_index boolean,
    alloc_sales_index boolean,
    alloc_blended_index boolean
);


--
-- Name: eve_ma_dptflrsetattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_dptflrsetattributes (
    indx integer NOT NULL,
    product text,
    "time" text,
    floorset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    too integer,
    lyrcptstart text,
    lyrcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_initrcptwk text,
    default_dbt_wk text,
    default_too integer,
    default_mkdnwks integer,
    default_last_inv_wk text,
    default_lstfpwk text,
    default_last_rcpt_wk text,
    default_erlstmkdnwk text,
    default_exitdate text,
    default_ccmdstrategy text,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_ccordermultiple integer,
    default_ccordpolicy text,
    default_strclimate text[],
    default_grade text[],
    default_ssg text[],
    default_flnrange text[],
    default_discountpct real,
    default_retpct_str real,
    default_retpct_ecomm real,
    default_imupct real,
    floorset_attribute text,
    ly_floorset_attribute text,
    lly_floorset_attribute text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_dptflrsetattributes_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_dptflrsetattributes_pre_cal_change (
    indx integer,
    product text,
    "time" text,
    floorset_name text,
    initialrcptwk text,
    rcptstart text,
    rcptend text,
    slsstart text,
    slsend text,
    too integer,
    lyrcptstart text,
    lyrcptend text,
    lyslsstart text,
    lyslsend text,
    ap_start text,
    ap_end text,
    default_initrcptwk text,
    default_dbt_wk text,
    default_too integer,
    default_mkdnwks integer,
    default_last_inv_wk text,
    default_lstfpwk text,
    default_last_rcpt_wk text,
    default_erlstmkdnwk text,
    default_exitdate text,
    default_ccmdstrategy text,
    default_presmin integer,
    default_presmin_weeks integer,
    default_ccrcptint integer,
    default_ccordermultiple integer,
    default_ccordpolicy text,
    default_strclimate text[],
    default_grade text[],
    default_ssg text[],
    default_flnrange text[],
    default_discountpct real,
    default_retpct_str real,
    default_retpct_ecomm real,
    default_imupct real,
    floorset_attribute text,
    ly_floorset_attribute text,
    lly_floorset_attribute text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_imgattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_imgattributes (
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
-- Name: eve_ma_regionattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_regionattributes (
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
-- Name: eve_ma_sellingchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sellingchannelattributes (
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
-- Name: eve_ma_sizeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes (
    product text NOT NULL,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer DEFAULT 1 NOT NULL,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_sizeattributes_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_20240712 (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_sizeattributes_bk_sup2937; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_bk_sup2937 (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_sizeattributes_existing_dupe_sup2937; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_existing_dupe_sup2937 (
    notes text,
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_sizeattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_intraday (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_sizeattributes_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_sup_2656 (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_sizeattributes_sup_2656_pre_delete; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sizeattributes_sup_2656_pre_delete (
    product text,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    sizeattribute text,
    isvalid integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_skuattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_skuattributes (
    product text NOT NULL,
    parent_id text,
    pim_sku_id text,
    erp_sku_id text,
    size_attribute text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_stateattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stateattributes (
    indx integer,
    location text,
    state_latitude text,
    state_longitude text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_storeattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_storeattributes (
    location text NOT NULL,
    strname text,
    str_open_status text,
    str_combo_name text,
    str_street_address text,
    str_city text,
    str_state text,
    str_zip text,
    str_shopping_center text,
    str_phone text,
    str_extension text,
    str_region text,
    str_square_footage text,
    str_timezone text,
    str_opening_date text,
    str_close_date text,
    str_climate text,
    str_latitude text,
    str_longitude text,
    str_remodel_date text,
    str_start_order_date text,
    str_stop_order_date text,
    str_grade text,
    region_name text,
    region_desc text,
    state_name text,
    state_desc text,
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_storeattributes_lat_long; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_storeattributes_lat_long (
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
-- Name: eve_ma_styleattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_styleattributes (
    product text NOT NULL,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    pim_size_run_id text,
    pim_size_run_name text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    sty_sleeve_length text,
    sty_subclass_display text,
    sty_num_clones_s5 real,
    sty_num_times_cloned_s5 real
);


--
-- Name: eve_ma_styleattributes_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_styleattributes_20240712 (
    product text,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    pim_size_run_id text,
    pim_size_run_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_ma_styleattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_styleattributes_intraday (
    product text,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    pim_size_run_id text,
    pim_size_run_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    sty_sleeve_length text,
    sty_subclass_display text,
    sty_num_clones_s5 real,
    sty_num_times_cloned_s5 real
);


--
-- Name: eve_ma_styleattributes_sup3233; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_styleattributes_sup3233 (
    product text,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    pim_size_run_id text,
    pim_size_run_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    sty_sleeve_length text
);


--
-- Name: eve_ma_styleattributes_sup3322; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_styleattributes_sup3322 (
    product text,
    pim_style_id text,
    erp_style_id text,
    sty_dept text,
    sty_typ text,
    sty_subtyp_1 text,
    sty_style_description text,
    sty_vendor_id text,
    sty_vendor_name text,
    sty_brand_id text,
    sty_brand_name text,
    sty_source text,
    sty_length_height text,
    sty_neckline text,
    sty_end_use text,
    sty_size_run_name text,
    sty_size_run_id text,
    sty_knit_woven text,
    sty_development_path text,
    sty_product_type text,
    sty_fabric_material text,
    ccstylecreatedate text,
    sty_closure text,
    sty_hem_finish text,
    sty_waist_rise text,
    sty_is_locked text,
    sty_s5_adopted text,
    pim_size_run_id text,
    pim_size_run_name text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    sty_sleeve_length text,
    sty_subclass_display text
);


--
-- Name: eve_ma_stylecolor_alloc_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolor_alloc_attributes (
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
    weight_need text DEFAULT 'Medium'::text,
    excess_eligible_stores text[] DEFAULT '{ECOMM,A,B,C,D}'::text[]
);


--
-- Name: eve_ma_stylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes (
    product text NOT NULL,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp real,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean DEFAULT true,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost real,
    cc_cancel_date text,
    cc_trend text,
    marketing_comments text,
    cc_merch_status text,
    cc_lineplan_notes text,
    cc_styleout_notes text,
    cc_placeholder_notes text,
    cc_open1_notes text,
    cc_open2_notes text,
    cc_num_clones_s5 real,
    cc_num_times_cloned_s5 real
);


--
-- Name: eve_ma_stylecolorattributes_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_20240712 (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp text,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone
);


--
-- Name: eve_ma_stylecolorattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_intraday (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp real,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost real,
    cc_cancel_date text,
    cc_trend text,
    marketing_comments text,
    cc_merch_status text,
    cc_lineplan_notes text,
    cc_styleout_notes text,
    cc_placeholder_notes text,
    cc_open1_notes text,
    cc_open2_notes text,
    cc_num_clones_s5 real,
    cc_num_times_cloned_s5 real
);


--
-- Name: eve_ma_stylecolorattributes_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_pre_cal_change (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp text,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost text
);


--
-- Name: eve_ma_stylecolorattributes_sup3122; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_sup3122 (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp text,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost text,
    cc_cancel_date text,
    cc_trend text,
    marketing_comments text,
    cc_merch_status text,
    cc_lineplan_notes text,
    cc_styleout_notes text,
    cc_placeholder_notes text,
    cc_open1_notes text,
    cc_open2_notes text
);


--
-- Name: eve_ma_stylecolorattributes_sup3322; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_sup3322 (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp real,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost real,
    cc_cancel_date text,
    cc_trend text,
    marketing_comments text,
    cc_merch_status text,
    cc_lineplan_notes text,
    cc_styleout_notes text,
    cc_placeholder_notes text,
    cc_open1_notes text,
    cc_open2_notes text
);


--
-- Name: eve_ma_stylecolorattributes_sup_2641; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorattributes_sup_2641 (
    product text,
    pim_stylecolor_id text,
    erp_stylecolor_id text,
    ccstylecolorcreatedate text,
    cc_marketing text,
    cc_floorset text,
    cc_pim_status text,
    cc_pim_first_available_date text,
    cc_pim_discontinue_date text,
    cc_first_inv_date text,
    cc_last_rec_date text,
    cc_weighted_rec_date text,
    cc_first_md_date text,
    cc_last_md_date text,
    cc_pricing_tier text,
    cc_image_url text,
    cc_description text,
    cc_c_mh_ss text,
    cc_exclusive text,
    cc_print_pattern text,
    cc_denim_wash text,
    cccolor text,
    cccolorfamily text,
    cc_color_code text,
    cc_msrp text,
    cc_current_price text,
    cc_estimated_cost text,
    cc_actual_cost text,
    cc_style_group text,
    cc_rtv text,
    cc_fulfillment text,
    cc_cc_plan text,
    cc_flow text,
    division_name text,
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
    cc_prepublish boolean,
    cc_prepublished_at timestamp without time zone,
    cc_use_sys_floorset boolean,
    cc_vendor_color text,
    allocator_comments text,
    cc_vendor_cost text,
    cc_cancel_date text
);


--
-- Name: eve_ma_stylecolorchannelattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes (
    product text NOT NULL,
    location text NOT NULL,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real DEFAULT 3,
    ccticketpricechannel real DEFAULT '0.01'::real,
    validsizes text[] DEFAULT ARRAY[]::text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real DEFAULT 0.0,
    cc_imupct real DEFAULT 0.00,
    cc_existingwac real DEFAULT 0.00,
    cc_systemcost real DEFAULT 0.0,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text DEFAULT 'No'::text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean DEFAULT false,
    irr_mode text DEFAULT 'Normal'::text,
    plan_current text,
    lock_agg_edit text,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0,
    hasbeenpatternedafter text,
    cc_override_service_level real DEFAULT 0.9,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real DEFAULT 4,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real DEFAULT 0.99,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    cloned_at timestamp(0) without time zone,
    force_size_min_for_replen real DEFAULT 0,
    sclr_fringe_flag real DEFAULT 1
);


--
-- Name: eve_ma_stylecolorchannelattributes_20240712; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_20240712 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real
);


--
-- Name: eve_ma_stylecolorchannelattributes_bk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_bk (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text
);


--
-- Name: eve_ma_stylecolorchannelattributes_bk_20251208; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_bk_20251208 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text,
    cloned_at timestamp(0) without time zone
);


--
-- Name: eve_ma_stylecolorchannelattributes_bkp_20260818; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_bkp_20260818 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text,
    cloned_at timestamp(0) without time zone,
    force_size_min_for_replen real,
    sclr_fringe_flag real
);


--
-- Name: eve_ma_stylecolorchannelattributes_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_intraday (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text DEFAULT 'Copy Rating'::text,
    cloned_at timestamp(0) without time zone,
    force_size_min_for_replen real DEFAULT 1,
    sclr_fringe_flag real DEFAULT 1
);


--
-- Name: eve_ma_stylecolorchannelattributes_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_pre_cal_change (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real
);


--
-- Name: eve_ma_stylecolorchannelattributes_sup3322; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_stylecolorchannelattributes_sup3322 (
    product text,
    location text,
    dbt_wk text,
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
    mdstart_indx integer,
    lastdcorder_indx integer,
    exitdate_indx integer,
    slsrnk real,
    ccticketpricechannel real,
    validsizes text[],
    cc_validsizes_store text[],
    cc_validsizes_ecom text[],
    ccrangecode text,
    ccmdstrategy text,
    cc_presmin_weeks integer,
    cc_presmin integer,
    cc_ordpolicy text,
    cc_rcptint integer,
    cc_ordermultiple integer,
    cc_discount_pct real,
    cc_imupct real,
    cc_existingwac real,
    cc_systemcost real,
    ssnprf text,
    adjaps real,
    relaunchweek text,
    cc_plan_cost real,
    cc_landed_cost real,
    cc_target_cost real,
    cc_flrset text,
    cc_season text,
    inseason_adjaps real,
    smoothing_strategy text,
    in_season_flag text,
    lifecycle_applied text,
    cc_return_u_pct_store real,
    cc_return_u_pct_ecom real,
    auto_rollforward boolean,
    irr_mode text,
    plan_current text,
    lock_agg_edit text,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint,
    hasbeenpatternedafter text,
    cc_override_service_level real,
    cc_override_fp_st_pct real,
    act_slsrnk real,
    sclr_presmin real,
    sclr_presmin_weeks real,
    sclr_tgt_fwoc real,
    sclr_alloc_min real,
    sclr_alloc_max real,
    cc_override_service_level_ecom real,
    cc_override_fp_st_pct_ecom real,
    act_aps real,
    act_aps_mult_adj real,
    use_act_aps_or_act_rank text
);


--
-- Name: eve_ma_sys_managed_stylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sys_managed_stylecolorattributes (
    product text NOT NULL,
    location text NOT NULL,
    cc_floorset_override text,
    cc_use_sys_floorset_override boolean DEFAULT true,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_sys_stylecolorattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_sys_stylecolorattributes (
    product text NOT NULL,
    cc_floorset_override text,
    cc_use_sys_floorset_override boolean DEFAULT true,
    eventdate date DEFAULT CURRENT_DATE,
    version_id bigint DEFAULT 1,
    created_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    created_by text DEFAULT 'system'::text,
    updated_at timestamp without time zone DEFAULT date_trunc('sec'::text, CURRENT_TIMESTAMP),
    updated_by text DEFAULT 'system'::text,
    record_state smallint DEFAULT 0
);


--
-- Name: eve_ma_weekattributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_ma_weekattributes (
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
-- Name: eve_p_channeloverride; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_channeloverride (
    product text NOT NULL,
    location text NOT NULL,
    "time" text NOT NULL,
    weekadjaps real,
    weekadjslsu real,
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
-- Name: eve_p_channeloverride_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_channeloverride_pre_cal_change (
    product text,
    location text,
    "time" text,
    weekadjaps real,
    weekadjslsu real,
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
-- Name: eve_p_dc_adj; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj (
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_dc_adj_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_intraday (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_pre_cal_change (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_size (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_size_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_size_intraday (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_size_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_size_pre_cal_change (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_size_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_size_sup_2656 (
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
    record_state smallint
);


--
-- Name: eve_p_dc_adj_size_sup_2656_pre_delete; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_dc_adj_size_sup_2656_pre_delete (
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
    record_state smallint
);


--
-- Name: eve_p_itemprice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_itemprice (
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_itemprice_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_itemprice_pre_cal_change (
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
    record_state smallint
);


--
-- Name: eve_p_replannable_choices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_replannable_choices (
    product text
);


--
-- Name: eve_p_strategy_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_strategy_params (
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_strategy_params_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_strategy_params_pre_cal_change (
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
    record_state smallint
);


--
-- Name: eve_p_stylecolor_channel_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_channel_alloc_params (
    product text NOT NULL,
    location text NOT NULL,
    sclr_def_alloc_sizeattr text[],
    sclr_def_presmin real,
    sclr_def_presmin_weeks real,
    sclr_def_fringe_flag text,
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
-- Name: eve_p_stylecolor_store_alloc_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_store_alloc_params (
    product text NOT NULL,
    location text NOT NULL,
    sclr_loc_eligibility integer,
    sclr_loc_tgt_fp_st_pct real,
    sclr_loc_alloc_sizeattr text[],
    sclr_loc_presmin real,
    sclr_loc_presmin_weeks real,
    sclr_loc_fringe_flag text,
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_stylecolor_store_eligibility; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_store_eligibility (
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
-- Name: eve_p_stylecolor_store_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_store_worklist (
    product text NOT NULL,
    "time" text NOT NULL,
    location text NOT NULL,
    worklist_id text NOT NULL,
    sclr_loc_wrk_alloc_sclr_qty real,
    sclr_loc_wrk_alloc_size_qty integer[],
    sclr_loc_wrk_alloc_sizeattr text[],
    sclr_loc_wrk_presmin real,
    sclr_loc_wrk_presmin_weeks real,
    sclr_loc_wrk_fringe_flag text,
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_stylecolor_sysmanaged_attr_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_sysmanaged_attr_plan (
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
-- Name: eve_p_stylecolor_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolor_worklist (
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
    in_worklist real
);


--
-- Name: eve_p_stylecolorsize_worklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_stylecolorsize_worklist (
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
    record_state smallint DEFAULT 0
);


--
-- Name: eve_p_target_include_exclude; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_target_include_exclude (
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
-- Name: eve_p_target_include_exclude_pre_cal_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_p_target_include_exclude_pre_cal_change (
    product text,
    "time" text,
    ly_lly_key text,
    include_in_target_for_checkbox integer,
    include_in_target integer,
    eventdate date,
    version_id bigint,
    created_at timestamp without time zone,
    created_by text,
    updated_at timestamp without time zone,
    updated_by text,
    record_state smallint
);


--
-- Name: eve_perf_assortperiod_week; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.eve_perf_assortperiod_week AS
 SELECT a.product,
    a."time",
    b.id AS week,
    b.indx AS week_indx
   FROM ( SELECT eve_ma_dptflrsetattributes.product,
            eve_ma_dptflrsetattributes."time",
            eve_ma_dptflrsetattributes.slsstart,
            eve_ma_dptflrsetattributes.slsend
           FROM public.eve_ma_dptflrsetattributes) a,
    public.eve_d_time b
  WHERE ((b.levelid = 'week'::text) AND (b.id >= a.slsstart) AND (b.id <= a.slsend));


--
-- Name: eve_pg_batch_validation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_pg_batch_validation (
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
-- Name: eve_pg_batch_validation_archive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_pg_batch_validation_archive (
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
-- Name: eve_pg_batch_validation_failure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_pg_batch_validation_failure (
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
-- Name: eve_pg_batch_validation_previous; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_pg_batch_validation_previous (
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
-- Name: eve_plan_these_cloned_style_stylecolors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_plan_these_cloned_style_stylecolors (
    style text NOT NULL,
    stylecolor text NOT NULL,
    session_id text NOT NULL,
    updated_by text NOT NULL,
    picked_for_planning integer
);


--
-- Name: eve_roledimension; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_roledimension (
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
-- Name: eve_servicedefn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_servicedefn (
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
-- Name: eve_serviceparams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_serviceparams (
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
-- Name: eve_sizinglookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_sizinglookup (
    sizerange text NOT NULL,
    size text NOT NULL,
    nsp real,
    multiplier real,
    groupsum real,
    strselling_channel text
);


--
-- Name: eve_specimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_specimages (
    product text NOT NULL,
    img text
);


--
-- Name: eve_store_hier_attr; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.eve_store_hier_attr AS
 SELECT a.location,
    a.strname,
    a.str_open_status,
    a.str_combo_name,
    a.str_street_address,
    a.str_city,
    a.str_state,
    a.str_zip,
    a.str_shopping_center,
    a.str_phone,
    a.str_extension,
    a.str_region,
    a.str_square_footage,
    a.str_timezone,
    a.str_opening_date,
    a.str_close_date,
    a.str_climate,
    a.str_latitude,
    a.str_longitude,
    a.str_remodel_date,
    a.str_start_order_date,
    a.str_stop_order_date,
    a.str_grade,
    a.location AS store,
    b.ancestor0 AS state,
    a.state_name,
    a.state_desc,
    b.ancestor1 AS region,
    a.region_name,
    a.region_desc,
    b.ancestor2 AS selling_channel,
    a.selling_channel_name,
    a.selling_channel_desc,
    b.ancestor3 AS channel,
    a.channel_name,
    a.channel_desc,
    a.eventdate,
    a.version_id,
    a.created_at,
    a.created_by,
    a.updated_at,
    a.updated_by,
    a.record_state
   FROM (public.eve_ma_storeattributes a
     LEFT JOIN public.eve_h_locstd b ON ((a.location = b.id)))
  ORDER BY a.location;


--
-- Name: eve_style_clone_stylecolor_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_style_clone_stylecolor_size (
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
-- Name: eve_stylecolor_hier_attr; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.eve_stylecolor_hier_attr AS
 SELECT a.product,
    a.pim_stylecolor_id,
    a.erp_stylecolor_id,
    a.ccstylecolorcreatedate,
    a.cc_marketing,
    a.cc_floorset,
    a.cc_pim_status,
    a.cc_pim_first_available_date,
    a.cc_pim_discontinue_date,
    a.cc_first_inv_date,
    a.cc_last_rec_date,
    a.cc_weighted_rec_date,
    a.cc_first_md_date,
    a.cc_last_md_date,
    a.cc_pricing_tier,
    a.cc_image_url,
    a.cc_description,
    a.cc_c_mh_ss,
    a.cc_exclusive,
    a.cc_print_pattern,
    a.cc_denim_wash,
    a.cccolor,
    a.cccolorfamily,
    a.cc_color_code,
    a.cc_msrp,
    a.cc_current_price,
    a.cc_estimated_cost,
    a.cc_actual_cost,
    a.cc_style_group,
    a.cc_rtv,
    a.cc_fulfillment,
    a.cc_cc_plan,
    a.cc_flow,
    a.isassortment,
    a.merch_comments,
    a.plan_comments,
    a.cc_is_locked,
    a.cc_s5_adopted,
        CASE
            WHEN (a.cc_prepublish = true) THEN 1
            ELSE 0
        END AS cc_prepublish,
    a.cc_prepublished_at,
    a.cc_trend,
    a.marketing_comments,
    c.pim_style_id,
    c.erp_style_id,
    c.sty_dept,
    c.sty_typ,
    c.sty_subtyp_1,
    c.sty_style_description,
    c.sty_vendor_id,
    c.sty_vendor_name,
    c.sty_brand_id,
    c.sty_brand_name,
    c.sty_source,
    c.sty_length_height,
    c.sty_neckline,
    c.sty_end_use,
    c.sty_size_run_name,
    c.sty_size_run_id,
    c.sty_knit_woven,
    c.sty_development_path,
    c.sty_product_type,
    c.sty_fabric_material,
    c.ccstylecreatedate,
    c.sty_closure,
    c.sty_hem_finish,
    c.sty_waist_rise,
    c.sty_is_locked,
    c.sty_s5_adopted,
    c.sty_sleeve_length,
    c.pim_size_run_id,
    c.pim_size_run_name,
    b.id AS stylecolor,
    b.ancestor0 AS style,
    b.ancestor1 AS subclass,
    b.ancestor2 AS class,
    b.ancestor3 AS department,
    b.ancestor4 AS division,
    b.ancestor5 AS total_product,
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
    i.division_name,
    i.division_desc,
    j.total_product_name,
    j.total_product_desc,
    public.check_ispublishable(a.product) AS ispublishable,
    public.check_isprepublishable(a.product) AS isprepublishable,
    a.eventdate,
    a.version_id,
    a.created_at,
    a.created_by,
    (GREATEST(a.updated_at, c.updated_at))::timestamp(0) without time zone AS updated_at,
    a.updated_by,
    a.record_state,
        CASE
            WHEN (a.cc_use_sys_floorset = true) THEN 1
            ELSE 0
        END AS cc_use_sys_floorset,
    a.cc_vendor_color,
    a.allocator_comments,
    a.cc_vendor_cost,
    a.cc_cancel_date,
    a.cc_merch_status,
    a.cc_lineplan_notes,
    a.cc_styleout_notes,
    a.cc_placeholder_notes,
    a.cc_open1_notes,
    a.cc_open2_notes,
    c.sty_subclass_display,
    c.sty_num_clones_s5,
    c.sty_num_times_cloned_s5,
    a.cc_num_clones_s5,
    a.cc_num_times_cloned_s5
   FROM public.eve_ma_stylecolorattributes a,
    public.eve_h_prodstd b,
    public.eve_ma_styleattributes c,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS stylecolor_name,
            eve_d_product.description AS stylecolor_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'stylecolor'::text)) d,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS style_name,
            eve_d_product.description AS style_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'style'::text)) e,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS subclass_name,
            eve_d_product.description AS subclass_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'subclass'::text)) f,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS class_name,
            eve_d_product.description AS class_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'class'::text)) g,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS department_name,
            eve_d_product.description AS department_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'department'::text)) h,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS division_name,
            eve_d_product.description AS division_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'division'::text)) i,
    ( SELECT eve_d_product.id,
            eve_d_product.name AS total_product_name,
            eve_d_product.description AS total_product_desc
           FROM public.eve_d_product
          WHERE (eve_d_product.levelid = 'total_product'::text)) j
  WHERE ((a.product = b.id) AND (b.ancestor0 = c.product) AND (a.product = d.id) AND (b.ancestor0 = e.id) AND (b.ancestor1 = f.id) AND (b.ancestor2 = g.id) AND (b.ancestor3 = h.id) AND (b.ancestor4 = i.id) AND (b.ancestor5 = j.id))
  ORDER BY b.id;


--
-- Name: eve_swatches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_swatches (
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
-- Name: eve_v_memberbasedvalidvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_v_memberbasedvalidvalues (
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
-- Name: eve_week_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eve_week_mapping (
    old_week_id text,
    new_week_id text
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
-- Name: plan_fails_20260220; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_fails_20260220 (
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
-- Name: plan_queue_bkp_jul5_2024_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_bkp_jul5_2024_delete_me (
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
-- Name: plan_queue_failed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_failed (
    jobid uuid NOT NULL,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer,
    ready_for_cleanup boolean
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
-- Name: plan_queue_fails_20251031; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_fails_20251031 (
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
-- Name: plan_queue_post_run; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_queue_post_run (
    jobid uuid NOT NULL,
    product text,
    location text,
    initiator text,
    initiated_at timestamp with time zone,
    queued timestamp with time zone,
    processing timestamp with time zone,
    completed timestamp with time zone,
    error text,
    updated_at timestamp with time zone,
    priority integer,
    instance_id text
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
-- Name: pricing_table; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricing_table (
    t_expression text,
    v_cccurp real
);


--
-- Name: prod_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prod_map (
    old_id text,
    new_id text
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
-- Name: s5_analytics_inseason_sls_rnk_transposed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_analytics_inseason_sls_rnk_transposed (
    stylecolor text,
    act_aps real,
    act_slsrnk real,
    act_aps_mult_adj real
);


--
-- Name: s5_eve_sizerange_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_eve_sizerange_master (
    size_run_id text,
    size_run_name text,
    size_id real,
    size_attribute text,
    eventdate timestamp(0) without time zone
);


--
-- Name: s5_eve_sizerange_master_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s5_eve_sizerange_master_sup_2656 (
    size_run_id text,
    size_run_name text,
    size_id real,
    size_attribute text
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
-- Name: sca_stylecolors_with_size_issues; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sca_stylecolors_with_size_issues AS
 WITH valid_sizes_defined AS (
         SELECT eve_ma_stylecolorchannelattributes.product AS stylecolor,
            unnest(array_cat(eve_ma_stylecolorchannelattributes.cc_validsizes_ecom, eve_ma_stylecolorchannelattributes.cc_validsizes_store)) AS validsizes
           FROM public.eve_ma_stylecolorchannelattributes
        ), valid_sizes_defined_grouped AS (
         SELECT valid_sizes_defined.stylecolor,
            string_agg(DISTINCT valid_sizes_defined.validsizes, ', '::text) AS validsizes_defined
           FROM valid_sizes_defined
          GROUP BY valid_sizes_defined.stylecolor
        ), valid_sizes_available AS (
         SELECT eve_ma_sizeattributes.parent_id AS stylecolor,
            eve_ma_sizeattributes.sizeattribute
           FROM public.eve_ma_sizeattributes
        ), valid_sizes_available_grouped AS (
         SELECT valid_sizes_available.stylecolor,
            string_agg(DISTINCT valid_sizes_available.sizeattribute, ', '::text) AS validsizes_available
           FROM valid_sizes_available
          GROUP BY valid_sizes_available.stylecolor
        )
 SELECT d.stylecolor,
    d.validsizes_defined,
    COALESCE(a.validsizes_available, ''::text) AS validsizes_available
   FROM (valid_sizes_defined_grouped d
     LEFT JOIN valid_sizes_available_grouped a ON ((d.stylecolor = a.stylecolor)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM valid_sizes_available b
          WHERE ((d.stylecolor = b.stylecolor) AND (d.validsizes_defined ~~ (('%'::text || b.sizeattribute) || '%'::text))))));


--
-- Name: sca_valid_sizes_mismatch; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sca_valid_sizes_mismatch AS
 WITH valid_sizes_defined_2 AS (
         SELECT DISTINCT eve_ma_stylecolorchannelattributes.product AS stylecolor,
            unnest(array_cat(eve_ma_stylecolorchannelattributes.cc_validsizes_ecom, eve_ma_stylecolorchannelattributes.cc_validsizes_store)) AS validsizes
           FROM public.eve_ma_stylecolorchannelattributes
        ), valid_sizes_available_2 AS (
         SELECT eve_ma_sizeattributes.parent_id AS stylecolor,
            eve_ma_sizeattributes.sizeattribute
           FROM public.eve_ma_sizeattributes
        ), erroneous_sclrs AS (
         SELECT DISTINCT a_1.stylecolor
           FROM valid_sizes_defined_2 a_1
          WHERE (NOT (EXISTS ( SELECT 1
                   FROM valid_sizes_available_2 b_1
                  WHERE ((a_1.stylecolor = b_1.stylecolor) AND (a_1.validsizes = b_1.sizeattribute)))))
        )
 SELECT a.stylecolor,
    a.validsizes AS validsizes_defined,
    COALESCE(b.sizeattribute, 'N/A'::text) AS validsizes_available
   FROM (valid_sizes_defined_2 a
     LEFT JOIN valid_sizes_available_2 b ON (((a.stylecolor = b.stylecolor) AND (a.validsizes = b.sizeattribute))))
  WHERE (a.stylecolor IN ( SELECT erroneous_sclrs.stylecolor
           FROM erroneous_sclrs));


--
-- Name: sca_valid_sizes_not_in_sizeattributes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sca_valid_sizes_not_in_sizeattributes AS
 WITH valid_sizes_defined AS (
         SELECT DISTINCT x.stylecolor,
            x.validsizes
           FROM ( SELECT eve_ma_stylecolorchannelattributes.product AS stylecolor,
                    unnest(array_cat(eve_ma_stylecolorchannelattributes.cc_validsizes_ecom, eve_ma_stylecolorchannelattributes.cc_validsizes_store)) AS validsizes
                   FROM public.eve_ma_stylecolorchannelattributes) x
        ), valid_sizes_available AS (
         SELECT eve_ma_sizeattributes.parent_id AS stylecolor,
            eve_ma_sizeattributes.sizeattribute
           FROM public.eve_ma_sizeattributes
        )
 SELECT a.stylecolor,
    a.validsizes
   FROM valid_sizes_defined a
  WHERE (NOT (EXISTS ( SELECT 1
           FROM valid_sizes_available b
          WHERE ((a.stylecolor = b.stylecolor) AND (a.validsizes = b.sizeattribute)))));


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
-- Name: size_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.size_ids (
    size_name text,
    size_id text
);


--
-- Name: size_ids_sup_2656; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.size_ids_sup_2656 (
    size_name text,
    size_id text
);


--
-- Name: ssg_for_ch_unnested; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ssg_for_ch_unnested AS
 SELECT x.ssg_id,
    x.ssg_name,
    replace(replace(replace(rtrim(ltrim(unnest(x.stores))), '{'::text, ''::text), '}'::text, ''::text), '"'::text, ''::text) AS valid_stores
   FROM ( SELECT DISTINCT eve_l_ssglookup.ssg_id,
            eve_l_ssglookup.ssg_name,
            eve_l_ssglookup.stores
           FROM public.eve_l_ssglookup) x;


--
-- Name: ssg_for_ch_unnested_by_dept; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ssg_for_ch_unnested_by_dept AS
 SELECT x.product AS department,
    x.ssg_id,
    x.ssg_name,
    replace(replace(replace(rtrim(ltrim(unnest(x.stores))), '{'::text, ''::text), '}'::text, ''::text), '"'::text, ''::text) AS valid_stores
   FROM ( SELECT DISTINCT eve_l_ssglookup.product,
            eve_l_ssglookup.ssg_id,
            eve_l_ssglookup.ssg_name,
            eve_l_ssglookup.stores
           FROM public.eve_l_ssglookup) x;


--
-- Name: store_name_updat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_name_updat (
    id text,
    name text
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
-- Name: stylecolor_band; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stylecolor_band (
    stylecolor text,
    final_rnk real
);


--
-- Name: stylecolor_size_predict_attrs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.stylecolor_size_predict_attrs AS
 SELECT a.cc_description,
    a.cc_exclusive,
    a.cc_floorset,
    a.cc_marketing,
    a.cc_pricing_tier,
    a.cc_style_group,
    a.cccolor,
    a.cccolorfamily,
    b.ancestor2 AS class,
    b.ancestor3 AS department,
    b.ancestor4 AS division,
    a.product,
    e.id AS selling_channel,
    c.sty_size_run_name AS sizerange,
    c.sty_brand_name,
    c.sty_dept,
    c.sty_fabric_material,
    c.sty_knit_woven,
    c.sty_length_height,
    c.sty_neckline,
    c.sty_product_type,
    c.sty_size_run_name,
    c.sty_typ,
    c.sty_waist_rise,
    b.ancestor1 AS subclass
   FROM ((((public.eve_ma_stylecolorattributes a
     JOIN public.eve_h_prodstd b ON ((a.product = b.id)))
     JOIN public.eve_ma_styleattributes c ON ((b.ancestor0 = c.product)))
     JOIN public.eve_ma_stylecolorchannelattributes d ON ((a.product = d.product)))
     JOIN ( SELECT eve_h_locstd.id,
            eve_h_locstd.ancestor0
           FROM public.eve_h_locstd) e ON ((d.location = e.ancestor0)));


--
-- Name: sup3740_research; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sup3740_research (
    department_name text,
    style text,
    style_name text,
    product text,
    stylecolor_name text,
    dbt_wk text,
    erlstmkdnwk text,
    exitdate text,
    plan_current text,
    record_state smallint,
    status text
);


--
-- Name: sup_3917_fix_style_a_assortment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sup_3917_fix_style_a_assortment (
    product text,
    original_style text
);


--
-- Name: temp1_eve_c_week1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp1_eve_c_week1 (
    week text,
    week_minus_1 text
);


--
-- Name: temp1_eve_c_week4; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp1_eve_c_week4 (
    week text,
    week_minus_4 text
);


--
-- Name: temp_corpdisc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_corpdisc (
    product text NOT NULL,
    "time" text NOT NULL,
    prodlife text NOT NULL,
    corpaddoff real DEFAULT 0.0,
    corpexcl real DEFAULT 0.0
);


--
-- Name: temp_eve_corpdisc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_eve_corpdisc (
    department text,
    product text,
    location text,
    "time" text,
    prodlife text,
    corpaddoff real,
    corpexcl real
);


--
-- Name: tmp_eve_l_dependencylookup_intraday; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_eve_l_dependencylookup_intraday (
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
-- Name: tmp_eve_l_ssglookup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_eve_l_ssglookup (
    ssg_id text,
    location text,
    ssg_name text,
    ssg_store text[]
);


--
-- Name: tmp_eve_v_memberbasedvalidvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_eve_v_memberbasedvalidvalues (
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
-- Name: tmp_new; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_new (
    product text,
    location text,
    indx integer,
    "time" text
);


--
-- Name: tmp_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_old (
    product text,
    location text,
    str_climate text[],
    str_grade text[],
    ssg text[],
    flnrange text[],
    plan_type text,
    style text,
    indx integer,
    isfunded integer,
    store_count integer
);


--
-- Name: tmp_record_state_backfill_scope; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_record_state_backfill_scope (
    product text,
    location text,
    exitdate text,
    dbt_wk text,
    record_state smallint
);


--
-- Name: trigger_test_delete_me; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trigger_test_delete_me (
    stat_id text,
    ts timestamp with time zone
);


--
-- Name: tyly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tyly (
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
-- Name: user_kv_store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_kv_store (
    uid text NOT NULL,
    key text NOT NULL,
    value text
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
-- Name: user_worklist_bkp_10042025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_worklist_bkp_10042025 (
    user_id text,
    product text,
    type text,
    updated_at timestamp without time zone,
    name text
);


--
-- Name: v_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.v_index (
    text text
);


--
-- Name: worklist_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worklist_map (
    product text,
    worklist_id text NOT NULL
);


--
-- Name: actuals_wide; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.actuals_wide (
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: comments; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.comments (
    comment_id uuid,
    author text,
    plan_id integer,
    view_context text,
    view_template_id text,
    content text,
    modified_at timestamp with time zone
);


--
-- Name: plan_data_wide; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.plan_data_wide (
    id integer,
    "time" text,
    product text,
    location text,
    ttl_storecount double precision,
    net_sls_u double precision,
    net_sls_r double precision,
    net_sls_c double precision,
    boh_r double precision,
    boh_u double precision,
    boh_c double precision,
    eoh_u double precision,
    eoh_r double precision,
    eoh_c double precision,
    rec_u double precision,
    rec_c double precision,
    rec_r double precision,
    on_order_u double precision,
    on_order_c double precision,
    on_order_r double precision,
    pos_md_r double precision,
    perm_md_r double precision,
    invadj_u double precision,
    invadj_r double precision,
    invadj_c double precision,
    donations_u double precision,
    donations_r double precision,
    donations_c double precision,
    balance_internal_r double precision,
    balance_internal_u double precision,
    balance_internal_c double precision
);


--
-- Name: plan_init_status; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.plan_init_status (
    id integer,
    seeded_at timestamp with time zone,
    balanced_at timestamp with time zone
);


--
-- Name: plans; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.plans (
    id integer,
    name text,
    version text,
    created_at timestamp with time zone,
    owned_by text,
    authored_by text,
    modified_by text,
    created_from integer,
    "time" text,
    product text,
    location text,
    module text
);


--
-- Name: tyly; Type: TABLE; Schema: safe_to_delete; Owner: -
--

CREATE TABLE safe_to_delete.tyly (
    ty text,
    ly text
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
    class.id AS class,
    class_subclass.id AS class_subclass,
    subclass.id AS subclass
   FROM (((((( SELECT dimensions.id
           FROM target_setting.dimensions
          WHERE ((dimensions.dimension = 'product'::text) AND (dimensions.levelid = 'subclass'::text))) subclass
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = subclass.id) AND (hierarchies.hierarchy = 'prodstd'::text))) class_subclass ON (true))
     JOIN LATERAL ( SELECT hierarchies.ancestor AS id
           FROM target_setting.hierarchies
          WHERE ((hierarchies.id = class_subclass.id) AND (hierarchies.hierarchy = 'prodstd'::text))) class ON (true))
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
    product.subclass AS product_subclass,
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
     JOIN ( SELECT product_denorm.subclass,
            product_denorm.department
           FROM target_setting.product_denorm) product ON ((product.subclass = wide.product)))
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
-- Name: dimensions_pre_cal_change; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.dimensions_pre_cal_change (
    dimension text,
    id text,
    name text,
    description text,
    levelid text,
    indx integer
);


--
-- Name: hierarchies_pre_cal_change; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.hierarchies_pre_cal_change (
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
    product.subclass AS product_subclass,
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
     JOIN ( SELECT product_denorm.subclass,
            product_denorm.department
           FROM target_setting.product_denorm) product ON ((product.subclass = wide.product)))
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
-- Name: tyly_pre_cal_change; Type: TABLE; Schema: target_setting; Owner: -
--

CREATE TABLE target_setting.tyly_pre_cal_change (
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
    ADD CONSTRAINT plans_unique UNIQUE (name, module, version, owned_by, "time", product, location);


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
    ADD CONSTRAINT user_kv_store_pkey PRIMARY KEY (key, uid);


--
-- Name: user_metadata user_metadata_pkey; Type: CONSTRAINT; Schema: mfp; Owner: -
--

ALTER TABLE ONLY mfp.user_metadata
    ADD CONSTRAINT user_metadata_pkey PRIMARY KEY (uid);


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
-- Name: eve_a_assortment eve_a_assortment_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_a_assortment
    ADD CONSTRAINT eve_a_assortment_2_pkey PRIMARY KEY (product, "time", location, plan_type);


--
-- Name: eve_an_price_storecount_info eve_an_price_storecount_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_an_price_storecount_info
    ADD CONSTRAINT eve_an_price_storecount_info_pkey PRIMARY KEY (product, "time", channel, selling_channel);


--
-- Name: eve_authorization eve_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_authorization
    ADD CONSTRAINT eve_authorization_pkey PRIMARY KEY (roleid, authid);


--
-- Name: eve_d_cluster eve_d_cluster_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_d_cluster
    ADD CONSTRAINT eve_d_cluster_pkey PRIMARY KEY (id);


--
-- Name: eve_d_location eve_d_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_d_location
    ADD CONSTRAINT eve_d_location_pkey PRIMARY KEY (id);


--
-- Name: eve_d_prodlife eve_d_prodlife_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_d_prodlife
    ADD CONSTRAINT eve_d_prodlife_pkey PRIMARY KEY (id);


--
-- Name: eve_d_product eve_d_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_d_product
    ADD CONSTRAINT eve_d_product_pkey PRIMARY KEY (id);


--
-- Name: eve_d_time eve_d_time_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_d_time
    ADD CONSTRAINT eve_d_time_pkey PRIMARY KEY (id);


--
-- Name: eve_h_clusterstd eve_h_clusterstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_clusterstd
    ADD CONSTRAINT eve_h_clusterstd_pkey PRIMARY KEY (id);


--
-- Name: eve_h_locdc eve_h_locdc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_locdc
    ADD CONSTRAINT eve_h_locdc_pkey PRIMARY KEY (id);


--
-- Name: eve_h_locdcstd eve_h_locdcstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_locdcstd
    ADD CONSTRAINT eve_h_locdcstd_pkey PRIMARY KEY (id);


--
-- Name: eve_h_locstd eve_h_locstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_locstd
    ADD CONSTRAINT eve_h_locstd_pkey PRIMARY KEY (id);


--
-- Name: eve_h_prodlifestd eve_h_prodlifestd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_prodlifestd
    ADD CONSTRAINT eve_h_prodlifestd_pkey PRIMARY KEY (id);


--
-- Name: eve_h_prodstd eve_h_prodstd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_prodstd
    ADD CONSTRAINT eve_h_prodstd_pkey PRIMARY KEY (id);


--
-- Name: eve_h_timeflrset eve_h_timeflrset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_timeflrset
    ADD CONSTRAINT eve_h_timeflrset_pkey PRIMARY KEY (id);


--
-- Name: eve_h_timestd eve_h_timestd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_h_timestd
    ADD CONSTRAINT eve_h_timestd_pkey PRIMARY KEY (id);


--
-- Name: eve_corpdisc eve_l_corpdisc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_corpdisc
    ADD CONSTRAINT eve_l_corpdisc_pkey PRIMARY KEY (department, product, location, "time", prodlife);


--
-- Name: eve_l_dclookup eve_l_dclookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_l_dclookup
    ADD CONSTRAINT eve_l_dclookup_pkey PRIMARY KEY (channel, dc);


--
-- Name: eve_l_priceeventlookup eve_l_priceeventlookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_l_priceeventlookup
    ADD CONSTRAINT eve_l_priceeventlookup_pkey PRIMARY KEY (product, location, ccpriceevent);


--
-- Name: eve_sizinglookup eve_l_sizinglookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_sizinglookup
    ADD CONSTRAINT eve_l_sizinglookup_pkey UNIQUE (sizerange, size, strselling_channel);


--
-- Name: eve_l_ssglookup eve_l_ssglookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_l_ssglookup
    ADD CONSTRAINT eve_l_ssglookup_pkey PRIMARY KEY (product, location, ssg_id);


--
-- Name: eve_l_storedclookup eve_l_storedclookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_l_storedclookup
    ADD CONSTRAINT eve_l_storedclookup_pkey PRIMARY KEY (store, dc, priority);


--
-- Name: eve_l_storelookup eve_l_storelookup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_l_storelookup
    ADD CONSTRAINT eve_l_storelookup_pkey PRIMARY KEY ("time", product, id, value);


--
-- Name: eve_ma_departmentalloc_attributes eve_ma_departmentalloc_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_departmentalloc_attributes
    ADD CONSTRAINT eve_ma_departmentalloc_attributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_dptflrsetattributes eve_ma_dptflrsetattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_dptflrsetattributes
    ADD CONSTRAINT eve_ma_dptflrsetattributes_pkey PRIMARY KEY (indx);


--
-- Name: eve_ma_imgattributes eve_ma_imgattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_imgattributes
    ADD CONSTRAINT eve_ma_imgattributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_sizeattributes eve_ma_sizeattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_sizeattributes
    ADD CONSTRAINT eve_ma_sizeattributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_skuattributes eve_ma_skuattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_skuattributes
    ADD CONSTRAINT eve_ma_skuattributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_storeattributes eve_ma_storeattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_storeattributes
    ADD CONSTRAINT eve_ma_storeattributes_pkey PRIMARY KEY (location);


--
-- Name: eve_ma_styleattributes eve_ma_styleattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_styleattributes
    ADD CONSTRAINT eve_ma_styleattributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_stylecolor_alloc_attributes eve_ma_stylecolor_alloc_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_stylecolor_alloc_attributes
    ADD CONSTRAINT eve_ma_stylecolor_alloc_attributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_stylecolorattributes eve_ma_stylecolorattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_stylecolorattributes
    ADD CONSTRAINT eve_ma_stylecolorattributes_pkey PRIMARY KEY (product);


--
-- Name: eve_ma_stylecolorchannelattributes eve_ma_stylecolorchannelattributes_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_stylecolorchannelattributes
    ADD CONSTRAINT eve_ma_stylecolorchannelattributes_2_pkey PRIMARY KEY (product, location);


--
-- Name: eve_ma_weekattributes eve_ma_weekattributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_weekattributes
    ADD CONSTRAINT eve_ma_weekattributes_pkey PRIMARY KEY ("time");


--
-- Name: eve_p_channeloverride eve_p_channeloverride_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_channeloverride
    ADD CONSTRAINT eve_p_channeloverride_pkey1 PRIMARY KEY (product, location, "time");


--
-- Name: eve_p_dc_adj eve_p_dc_adj_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_dc_adj
    ADD CONSTRAINT eve_p_dc_adj_pkey PRIMARY KEY (product, location, "time");


--
-- Name: eve_p_dc_adj_size eve_p_dc_adj_size_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_dc_adj_size
    ADD CONSTRAINT eve_p_dc_adj_size_pk UNIQUE (product, location, "time");


--
-- Name: eve_p_itemprice eve_p_itemprice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_itemprice
    ADD CONSTRAINT eve_p_itemprice_pkey PRIMARY KEY (product, location, "time");


--
-- Name: eve_p_stylecolor_channel_alloc_params eve_p_stylecolor_channel_alloc_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_channel_alloc_params
    ADD CONSTRAINT eve_p_stylecolor_channel_alloc_params_pkey PRIMARY KEY (product, location);


--
-- Name: eve_p_stylecolor_store_alloc_params eve_p_stylecolor_store_alloc_params_okey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_store_alloc_params
    ADD CONSTRAINT eve_p_stylecolor_store_alloc_params_okey PRIMARY KEY (product, location);


--
-- Name: eve_p_stylecolor_store_eligibility eve_p_stylecolor_store_eligibility_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_store_eligibility
    ADD CONSTRAINT eve_p_stylecolor_store_eligibility_pkey PRIMARY KEY (product, location);


--
-- Name: eve_p_stylecolor_store_worklist eve_p_stylecolor_store_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_store_worklist
    ADD CONSTRAINT eve_p_stylecolor_store_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: eve_p_stylecolor_worklist eve_p_stylecolor_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_worklist
    ADD CONSTRAINT eve_p_stylecolor_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: eve_p_stylecolorsize_worklist eve_p_stylecolorsize_worklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolorsize_worklist
    ADD CONSTRAINT eve_p_stylecolorsize_worklist_pkey PRIMARY KEY (product, "time", location, worklist_id);


--
-- Name: eve_p_target_include_exclude eve_p_target_include_exclude_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_target_include_exclude
    ADD CONSTRAINT eve_p_target_include_exclude_pkey PRIMARY KEY (product, "time", ly_lly_key);


--
-- Name: eve_roledimension eve_roledimension_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_roledimension
    ADD CONSTRAINT eve_roledimension_pkey PRIMARY KEY (tenantid, roleid, dimensionid);


--
-- Name: eve_specimages eve_specimages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_specimages
    ADD CONSTRAINT eve_specimages_pkey PRIMARY KEY (product);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (key);


--
-- Name: pivot_execution pivot_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pivot_execution
    ADD CONSTRAINT pivot_execution_pkey PRIMARY KEY (pivot_session_id);


--
-- Name: eve_ma_sys_stylecolorattributes pk_eve_ma_sys_stylecolorattributes; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_sys_stylecolorattributes
    ADD CONSTRAINT pk_eve_ma_sys_stylecolorattributes PRIMARY KEY (product);


--
-- Name: plan_queue_failed pk_plan_queue_failed; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_queue_failed
    ADD CONSTRAINT pk_plan_queue_failed PRIMARY KEY (jobid);


--
-- Name: plan_queue_post_run pk_plan_queue_post_run; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_queue_post_run
    ADD CONSTRAINT pk_plan_queue_post_run PRIMARY KEY (jobid);


--
-- Name: eve_p_stylecolor_sysmanaged_attr_plan pk_stylecolor_sysmanaged_attr_plan; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_stylecolor_sysmanaged_attr_plan
    ADD CONSTRAINT pk_stylecolor_sysmanaged_attr_plan PRIMARY KEY (product, location);


--
-- Name: eve_ma_sys_managed_stylecolorattributes pk_sys_managed_stylecolorattributes; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_ma_sys_managed_stylecolorattributes
    ADD CONSTRAINT pk_sys_managed_stylecolorattributes PRIMARY KEY (product, location);


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
-- Name: eve_p_strategy_params strategy_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eve_p_strategy_params
    ADD CONSTRAINT strategy_params_pkey PRIMARY KEY (product, location, floorset_uda);


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
-- Name: user_kv_store user_kv_store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_kv_store
    ADD CONSTRAINT user_kv_store_pkey PRIMARY KEY (uid, key);


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

CREATE INDEX actuals_wide_denorm_bottom_up ON mfp.actuals_wide_denorm USING btree (time_season, product_department, location_channel);


--
-- Name: actuals_wide_denorm_top_down; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX actuals_wide_denorm_top_down ON mfp.actuals_wide_denorm USING btree (time_season, product_total_product, location_channel);


--
-- Name: actuals_wide_denorm_unique_concurrent; Type: INDEX; Schema: mfp; Owner: -
--

CREATE UNIQUE INDEX actuals_wide_denorm_unique_concurrent ON mfp.actuals_wide_denorm USING btree ("time", product, location);


--
-- Name: actuals_wide_dimensions_idx; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX actuals_wide_dimensions_idx ON mfp.actuals_wide USING btree ("time", product, location);


--
-- Name: plan_data_wide_id_idx; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX plan_data_wide_id_idx ON mfp.plan_data_wide USING hash (id);


--
-- Name: sys_gen_wide_denorm_bottom_up; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_bottom_up ON mfp.sys_gen_wide_denorm USING btree (time_season, product_department, location_channel);


--
-- Name: sys_gen_wide_denorm_top_down; Type: INDEX; Schema: mfp; Owner: -
--

CREATE INDEX sys_gen_wide_denorm_top_down ON mfp.sys_gen_wide_denorm USING btree (time_season, product_total_product, location_channel);


--
-- Name: ata_debug_run_step_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ata_debug_run_step_idx ON public.ata_debug USING btree (run_id, step);


--
-- Name: ata_trace_run_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ata_trace_run_idx ON public.ata_trace USING btree (run_id, seq);


--
-- Name: eve_eohdata_stylecolor_product_channel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX eve_eohdata_stylecolor_product_channel_idx ON public.eve_eohdata_stylecolor USING btree (product, channel);


--
-- Name: eve_locstd_ances0_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_locstd_ances0_str_indx ON public.eve_h_prodstd USING btree (ancestor0);


--
-- Name: eve_locstd_ances1_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_locstd_ances1_str_indx ON public.eve_h_prodstd USING btree (ancestor1);


--
-- Name: eve_locstd_ances2_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_locstd_ances2_str_indx ON public.eve_h_prodstd USING btree (ancestor2);


--
-- Name: eve_locstd_ances3_str_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_locstd_ances3_str_indx ON public.eve_h_prodstd USING btree (ancestor3);


--
-- Name: eve_plan_these_cloned_style_stylecolors_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_plan_these_cloned_style_stylecolors_session_id_idx ON public.eve_plan_these_cloned_style_stylecolors USING btree (session_id);


--
-- Name: eve_prodstd_ances0_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances0_indx ON public.eve_h_prodstd USING btree (ancestor0);


--
-- Name: eve_prodstd_ances1_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances1_indx ON public.eve_h_prodstd USING btree (ancestor1);


--
-- Name: eve_prodstd_ances2_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances2_indx ON public.eve_h_prodstd USING btree (ancestor2);


--
-- Name: eve_prodstd_ances3_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances3_indx ON public.eve_h_prodstd USING btree (ancestor3);


--
-- Name: eve_prodstd_ances4_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances4_indx ON public.eve_h_prodstd USING btree (ancestor4);


--
-- Name: eve_prodstd_ances5_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances5_indx ON public.eve_h_prodstd USING btree (ancestor5);


--
-- Name: eve_prodstd_ances6_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_prodstd_ances6_indx ON public.eve_h_prodstd USING btree (ancestor6);


--
-- Name: eve_product_levelid_indx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_product_levelid_indx ON public.eve_d_product USING btree (levelid);


--
-- Name: eve_style_clone_stylecolor_size_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eve_style_clone_stylecolor_size_session_id_idx ON public.eve_style_clone_stylecolor_size USING btree (session_id);


--
-- Name: ldl_lookuptarget; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ldl_lookuptarget ON public.eve_l_dependencylookup USING btree (lookup_id, lookup_value, target_id);


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
-- Name: eve_ma_stylecolorattributes aa_trig_cc_update_revert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aa_trig_cc_update_revert BEFORE UPDATE OF cc_marketing, cc_pricing_tier, cc_description, cc_c_mh_ss, cc_exclusive, cc_print_pattern, cc_denim_wash, cccolor, cccolorfamily, cc_color_code, cc_style_group, cc_rtv, cc_flow, cc_cc_plan ON public.eve_ma_stylecolorattributes FOR EACH ROW WHEN ((old.cc_is_locked = 'Y'::text)) EXECUTE FUNCTION public.revert_to_original();


--
-- Name: eve_ma_styleattributes aa_trig_sty_update_revert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER aa_trig_sty_update_revert BEFORE UPDATE OF sty_dept, sty_typ, sty_subtyp_1, sty_style_description, sty_vendor_id, sty_vendor_name, sty_brand_id, sty_brand_name, sty_source, sty_length_height, sty_neckline, sty_end_use, sty_size_run_name, sty_size_run_id, sty_knit_woven, sty_development_path, sty_product_type, sty_fabric_material, sty_closure, sty_hem_finish, sty_waist_rise ON public.eve_ma_styleattributes FOR EACH ROW WHEN ((old.sty_is_locked = 'Y'::text)) EXECUTE FUNCTION public.revert_to_original();


--
-- Name: eve_ma_stylecolorchannelattributes ca_1_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ca_1_trigger_on_update AFTER UPDATE OF dbt_wk, relaunchweek, exitdate ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((COALESCE(new.relaunchweek, new.dbt_wk) < new.erlstmkdnwk) AND (new.erlstmkdnwk < new.exitdate) AND ((old.cloned_at IS NOT NULL) OR ((old.dbt_wk > old.plan_current) OR (old.exitdate > old.plan_current))) AND (new.exitdate > new.erlstmkdnwk) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.store_eligibility_trigger();


--
-- Name: eve_ma_stylecolorchannelattributes ca_1_trigger_on_update2; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ca_1_trigger_on_update2 AFTER UPDATE OF dbt_wk, exitdate ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((new.dbt_wk < new.erlstmkdnwk) AND (new.erlstmkdnwk < new.exitdate) AND ((old.dbt_wk > old.plan_current) OR (old.exitdate > old.plan_current)) AND (new.exitdate > new.erlstmkdnwk) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.store_eligibility_trigger2();


--
-- Name: eve_ma_stylecolorchannelattributes clear_pim_style_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER clear_pim_style_id AFTER UPDATE OF record_state ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.clear_pim_style_id();


--
-- Name: eve_ma_stylecolorchannelattributes dbt_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dbt_trigger_on_update AFTER UPDATE OF dbt_wk ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((((new.dbt_wk >= new.erlstmkdnwk) OR ((old.cloned_at IS NULL) AND (old.dbt_wk < old.plan_current))) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.dbt_after_md_trigger_on_update_validity_check();


--
-- Name: eve_ma_sys_stylecolorattributes enforce_cc_override_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER enforce_cc_override_trigger BEFORE INSERT OR UPDATE ON public.eve_ma_sys_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.enforce_cc_override_logic();

ALTER TABLE public.eve_ma_sys_stylecolorattributes DISABLE TRIGGER enforce_cc_override_trigger;


--
-- Name: eve_ma_stylecolorchannelattributes exit_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER exit_trigger_on_update AFTER UPDATE OF exitdate ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((((new.relaunchweek IS NULL) AND ((new.exitdate <= new.erlstmkdnwk) OR ((old.cloned_at IS NULL) AND (old.exitdate < old.plan_current)))) OR ((new.relaunchweek IS NOT NULL) AND ((new.exitdate <= new.erlstmkdnwk) OR ((old.cloned_at IS NULL) AND (new.exitdate < old.plan_current))) AND (pg_trigger_depth() = 0)))) EXECUTE FUNCTION public.exit_trigger_on_update_validity_check();


--
-- Name: eve_ma_stylecolorchannelattributes md_trigger_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER md_trigger_on_update AFTER UPDATE OF erlstmkdnwk ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN ((((new.relaunchweek IS NULL) AND ((new.erlstmkdnwk <= new.dbt_wk) OR ((old.cloned_at IS NULL) AND (old.erlstmkdnwk < old.plan_current)) OR (new.exitdate <= new.erlstmkdnwk)) AND (pg_trigger_depth() = 0)) OR ((new.relaunchweek IS NOT NULL) AND ((new.erlstmkdnwk <= new.relaunchweek) OR ((old.cloned_at IS NULL) AND (new.erlstmkdnwk < old.plan_current)) OR (new.exitdate <= new.erlstmkdnwk)) AND (pg_trigger_depth() = 0)))) EXECUTE FUNCTION public.md_trigger_on_update_validity_check();


--
-- Name: pivot_execution on_pivot_execution_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_pivot_execution_change AFTER INSERT OR DELETE OR UPDATE ON public.pivot_execution FOR EACH STATEMENT EXECUTE FUNCTION public.notify_pivot_execution_change();


--
-- Name: plan_queue on_plan_queue_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_plan_queue_change AFTER INSERT OR DELETE OR UPDATE ON public.plan_queue FOR EACH STATEMENT EXECUTE FUNCTION public.notify_plan_queue_change();


--
-- Name: eve_p_stylecolor_worklist on_publish_remove_from_worklist_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_publish_remove_from_worklist_trigger AFTER UPDATE ON public.eve_p_stylecolor_worklist FOR EACH ROW WHEN (((new.in_worklist = (1)::double precision) AND (old.in_worklist = (0)::double precision))) EXECUTE FUNCTION public.on_publish_remove_from_worklist();


--
-- Name: eve_p_stylecolor_worklist on_publish_remove_from_worklist_trigger_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_publish_remove_from_worklist_trigger_insert AFTER INSERT ON public.eve_p_stylecolor_worklist FOR EACH ROW WHEN ((new.in_worklist = (1)::double precision)) EXECUTE FUNCTION public.on_publish_remove_from_worklist();


--
-- Name: eve_p_stylecolor_worklist on_unpublish_remove_from_worklist_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_unpublish_remove_from_worklist_trigger AFTER UPDATE ON public.eve_p_stylecolor_worklist FOR EACH ROW WHEN (((new.in_worklist = (0)::double precision) AND (old.in_worklist = (1)::double precision))) EXECUTE FUNCTION public.on_unpublish_remove_from_worklist();


--
-- Name: plan_queue replicate_to_post_run_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER replicate_to_post_run_trigger AFTER INSERT OR UPDATE ON public.plan_queue FOR EACH ROW EXECUTE FUNCTION public.replicate_to_post_run();


--
-- Name: eve_v_memberbasedvalidvalues set_mvv_indx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_mvv_indx BEFORE INSERT ON public.eve_v_memberbasedvalidvalues FOR EACH ROW EXECUTE FUNCTION public.trigger_set_indx_valid_values();


--
-- Name: eve_ma_sizeattributes set_size_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_size_id BEFORE INSERT ON public.eve_ma_sizeattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_size_id();

ALTER TABLE public.eve_ma_sizeattributes DISABLE TRIGGER set_size_id;


--
-- Name: eve_a_assortment set_timestamp_a_assortment; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_a_assortment BEFORE UPDATE ON public.eve_a_assortment FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_d_product set_timestamp_d_product; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_d_product BEFORE UPDATE ON public.eve_d_product FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_h_prodstd set_timestamp_h_prodstd; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_h_prodstd BEFORE UPDATE ON public.eve_h_prodstd FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_p_channeloverride set_timestamp_p_channeloverride; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_channeloverride BEFORE UPDATE ON public.eve_p_channeloverride FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_p_dc_adj set_timestamp_p_dc_adj; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_adj BEFORE UPDATE ON public.eve_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_p_dc_adj_size set_timestamp_p_dc_adj_size; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_adj_size BEFORE UPDATE ON public.eve_p_dc_adj_size FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_p_dc_adj set_timestamp_p_dc_publish_adj; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_p_dc_publish_adj BEFORE UPDATE OF dc_publish ON public.eve_p_dc_adj FOR EACH ROW EXECUTE FUNCTION public.trigger_set_publish_timestamp();


--
-- Name: eve_ma_sizeattributes set_timestamp_sizeattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_sizeattr BEFORE UPDATE ON public.eve_ma_sizeattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_ma_styleattributes set_timestamp_styleattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_styleattr BEFORE UPDATE ON public.eve_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_ma_stylecolorchannelattributes set_timestamp_styleclrchannel; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_styleclrchannel BEFORE UPDATE ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: eve_ma_stylecolorattributes set_timestamp_stylecolorattr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_timestamp_stylecolorattr BEFORE UPDATE ON public.eve_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: worklist_map trg_ai_worklist_map; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_worklist_map AFTER INSERT ON public.worklist_map FOR EACH ROW EXECUTE FUNCTION public.trg_ins_stylecolor_alloc_attrs();


--
-- Name: user_worklist trg_change_product_to_worklist_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_change_product_to_worklist_id AFTER INSERT OR UPDATE ON public.user_worklist FOR EACH ROW EXECUTE FUNCTION public.change_product_to_worklist_id();


--
-- Name: eve_a_assortment trg_to_update_source_of_ranging_edit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_to_update_source_of_ranging_edit AFTER UPDATE OF plan_type ON public.eve_a_assortment FOR EACH ROW WHEN (((new.plan_type = 'ranging'::text) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.reset_plan_type_to_plan();


--
-- Name: eve_a_assortment trg_upd_assortment_ranging; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_assortment_ranging AFTER UPDATE OF str_climate, str_grade, ssg ON public.eve_a_assortment FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION public.propagate_assortment_to_floorsets();


--
-- Name: eve_ma_stylecolorattributes trg_upd_cc_prepublish; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_cc_prepublish BEFORE UPDATE OF cc_prepublish ON public.eve_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.set_prepublished_at();


--
-- Name: eve_ma_styleattributes trg_upd_pim_style_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_pim_style_id BEFORE UPDATE OF pim_style_id ON public.eve_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_pim_style_id();


--
-- Name: eve_ma_stylecolorattributes trg_upd_pim_stylecolor_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_pim_stylecolor_id BEFORE UPDATE OF pim_stylecolor_id ON public.eve_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_pim_stylecolor_id();


--
-- Name: eve_ma_styleattributes trg_upd_vendor_name; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_upd_vendor_name BEFORE UPDATE OF sty_vendor_name ON public.eve_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_sty_vendor_name();


--
-- Name: eve_p_stylecolor_store_eligibility trg_update_eligibility_from_null_to_zero; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_eligibility_from_null_to_zero AFTER UPDATE OF sclr_str_eligibility ON public.eve_p_stylecolor_store_eligibility FOR EACH ROW WHEN (((new.sclr_str_eligibility IS NULL) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.update_eligibility_from_null_to_zero();


--
-- Name: eve_h_prodstd trg_update_stylecolorattr_class_suclass_name; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_stylecolorattr_class_suclass_name AFTER UPDATE OF ancestor0, ancestor1 ON public.eve_h_prodstd FOR EACH ROW EXECUTE FUNCTION public.update_stylecolorattr_class_suclass_name();


--
-- Name: eve_ma_stylecolorattributes trig_upd_on_color_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_upd_on_color_change AFTER UPDATE OF cccolor ON public.eve_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_color_change();


--
-- Name: eve_ma_stylecolorattributes trig_upd_on_ticketprice; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_upd_on_ticketprice AFTER UPDATE OF cc_msrp ON public.eve_ma_stylecolorattributes FOR EACH ROW EXECUTE FUNCTION public.update_ticket_price();


--
-- Name: cart_params trigger_cartparams_ranging; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_cartparams_ranging AFTER UPDATE OF dbt_wk, exitdate ON public.cart_params FOR EACH ROW EXECUTE FUNCTION public.update_trigger_cartparams_ranging();


--
-- Name: eve_p_itemprice trigger_eff_aur; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_eff_aur AFTER INSERT OR UPDATE ON public.eve_p_itemprice FOR EACH ROW WHEN ((pg_trigger_depth() <= 1)) EXECUTE FUNCTION public.update_eff_aur();


--
-- Name: eve_ma_stylecolorchannelattributes trigger_for_time_indx; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_for_time_indx AFTER INSERT OR UPDATE OF dbt_wk, relaunchweek, erlstmkdnwk, exitdate ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.update_week_indxes();


--
-- Name: eve_ma_stylecolorchannelattributes trigger_for_time_indx_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_for_time_indx_update AFTER UPDATE OF dbt_wk, relaunchweek, erlstmkdnwk, exitdate ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW WHEN (((COALESCE(new.relaunchweek, new.dbt_wk) < new.erlstmkdnwk) AND (new.erlstmkdnwk < new.exitdate) AND ((old.cloned_at IS NOT NULL) OR ((old.dbt_wk > old.plan_current) OR (old.exitdate > old.plan_current))) AND (new.exitdate > new.erlstmkdnwk))) EXECUTE FUNCTION public.update_week_indxes();


--
-- Name: eve_p_itemprice trigger_itemprice_fetchdepartment; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_itemprice_fetchdepartment BEFORE INSERT ON public.eve_p_itemprice FOR EACH ROW EXECUTE FUNCTION public.itemprice_fetchdepartment();


--
-- Name: eve_ma_stylecolorchannelattributes trigger_lifecycle_plan_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_lifecycle_plan_update AFTER UPDATE OF erlstmkdnwk ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.lifecycle_plan_update();


--
-- Name: eve_ma_stylecolorchannelattributes trigger_sizerangecode_validsizes_members; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_sizerangecode_validsizes_members AFTER UPDATE OF ccrangecode ON public.eve_ma_stylecolorchannelattributes FOR EACH ROW EXECUTE FUNCTION public.sizerangecode_validsizes_members();


--
-- Name: eve_d_product trigger_upd_description_style; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_description_style AFTER UPDATE OF description ON public.eve_d_product FOR EACH ROW WHEN (((new.levelid = 'stylecolor'::text) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.update_description_style();


--
-- Name: eve_d_product trigger_upd_name_description; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_name_description AFTER UPDATE OF name, description ON public.eve_d_product FOR EACH ROW WHEN ((new.levelid = 'style'::text)) EXECUTE FUNCTION public.update_name_description();


--
-- Name: eve_d_product trigger_upd_name_style; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_name_style AFTER UPDATE OF name ON public.eve_d_product FOR EACH ROW WHEN (((new.levelid = 'stylecolor'::text) AND (pg_trigger_depth() = 0))) EXECUTE FUNCTION public.update_name_style();


--
-- Name: eve_ma_styleattributes trigger_update_class_after_subclass; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_class_after_subclass AFTER UPDATE OF sty_subclass_display ON public.eve_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_class_after_subclass();


--
-- Name: eve_ma_styleattributes trigger_update_sty_brand_name; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_sty_brand_name BEFORE UPDATE OF sty_brand_name ON public.eve_ma_styleattributes FOR EACH ROW EXECUTE FUNCTION public.update_sty_brand_name();


--
-- Name: eve_ma_styleattributes update_ccrangecode; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ccrangecode AFTER UPDATE OF sty_size_run_name ON public.eve_ma_styleattributes FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION public.update_stylecolorchannelattributes_ccrangecode();


--
-- Name: eve_h_prodstd update_ccsizerange_after_class_change_ancestor1; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ccsizerange_after_class_change_ancestor1 AFTER UPDATE OF ancestor1 ON public.eve_h_prodstd FOR EACH ROW WHEN ((new.ancestor1 IS DISTINCT FROM old.ancestor1)) EXECUTE FUNCTION public.create_hidden_class_ccsizerange_mod();


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

\unrestrict ztIqJLWfQS5ccWS7DoiwNtg4zvm0cQpD7Bb1fanYG30fDAo6VxpCeDZwPFEF74k

