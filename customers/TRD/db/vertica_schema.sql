-- ENV: qa | DB: trd | engine: Vertica | dumped: 2026-08-07

CREATE SEQUENCE public.TRD_loc_indexes  MINVALUE   0 ;
CREATE SEQUENCE public.trd_time_indexes  MINVALUE   0 ;
CREATE SEQUENCE public.TRD_FLOORSET_INDEXES  MINVALUE   0 ;
CREATE SEQUENCE public.TRD_prodlife_indexes  MINVALUE   0 ;
CREATE SEQUENCE public.TRD_cluster_indexes  MINVALUE   0 ;
CREATE SEQUENCE public.TRD_prod_indexes  MINVALUE   0 ;

CREATE TABLE public.TRD_IN_TIMESTAMP
(
    TIME_STAMP varchar(50)
);


CREATE TABLE public.TRD_IN_RDYFILE
(
    FILENAME varchar(200),
    RECORD_COUNT int
);


CREATE TABLE public.TRD_IN_PRD_MASTER
(
    MEMBER_ID varchar(200),
    S5_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    PRODUCT_LEVEL varchar(200)
);


CREATE TABLE public.TRD_IN_PRD_HIER
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    ANCESTOR5 varchar(500),
    ANCESTOR6 varchar(500),
    ANCESTOR7 varchar(500)
);


CREATE TABLE public.TRD_IN_LOC_MASTER
(
    MEMBER_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    LOC_LEVEL varchar(200)
);


CREATE TABLE public.TRD_IN_LOC_HIER
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500)
);


CREATE TABLE public.TRD_IN_INTERN_SERVICEPARAMS
(
    id varchar(50) NOT NULL,
    type varchar(50),
    value varchar(50)
);


CREATE TABLE public.TRD_INTERFACE_MASTER
(
    ID varchar(50),
    TYPE varchar(20),
    SOURCE varchar(20),
    TARGET varchar(20),
    FREQUENCY varchar(20),
    INBOUND_FILE varchar(50),
    INBOUND_TABLE varchar(50),
    OUTBOUND_TABLE varchar(50),
    TARGET_TABLE varchar(50),
    CURRENT_RECORD_COUNT int,
    PREVIOUS_RECORD_COUNT int,
    CURR_PREV_PERCENTAGE_DIFF numeric(10,4),
    COUNT_DIFF_PERCENTAGE_THRESHOLD int,
    CHECK_PERCENTAGE_DIFF varchar(1),
    CHECK_ZERO_COUNT varchar(1),
    CURRENT_REJECT_COUNT int
);


CREATE TABLE public.TRD_INTERFACE_COUNTS
(
    INTERFACE_ID varchar(50),
    CURRENT_RECORD_COUNT int,
    TIME_STAMP varchar(20),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INTERFACE_VALIDATION_FAILURES
(
    FAILURE_MESSAGE varchar(500),
    INTERFACE_ID varchar(50),
    TIME_STAMP varchar(20),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INTERFACE_REJECT_COUNTS
(
    INTERFACE_ID varchar(50),
    REJECT_MESSAGE varchar(500),
    REJECT_COUNT int,
    TIME_STAMP varchar(20),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INTERFACE_OUTBOUND_SUMMARY
(
    INTERFACE_ID varchar(50),
    CURRENT_RECORD_COUNT int,
    PREVIOUS_RECORD_COUNT int,
    CURRENT_REJECT_COUNT int,
    TIME_STAMP varchar(50)
);


CREATE TABLE public.TRD_INTERFACE_OUTBOUND_REJECTS
(
    INTERFACE_ID varchar(50),
    REJECT_MESSAGE varchar(500),
    REJECT_COUNT int,
    TIME_STAMP varchar(20)
);


CREATE TABLE public.TRD_IN_CLUSTER
(
    id varchar(200),
    name varchar(206),
    description varchar(206),
    levelid varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_IN_CLUSTER_STD
(
    id varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_IN_PRODLIFE
(
    id varchar(20),
    name varchar(20),
    description varchar(20),
    levelid varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_IN_PRODLIFE_STD
(
    id varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_NAME varchar(200),
    SEQ_NO varchar(200),
    DEPT varchar(200),
    CLASS varchar(200),
    SUBCLASS varchar(200),
    REQUIRED_IND varchar(200)
);


CREATE TABLE public.TRD_IN_VV_ATTRVALIDVALUES
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_DESC varchar(200),
    ATTRIBUTE_VALUE varchar(200),
    ATTRIBUTE_VALUE_DESC varchar(200)
);


CREATE TABLE public.TRD_IN_VV_COLORMAPPING
(
    COLOR_ID varchar(200),
    COLOR_DESCRIPTION varchar(200),
    COLOR_CODE varchar(200),
    DW_COLOR_FAMILY varchar(200)
);


CREATE TABLE public.TRD_IN_IMG_URL
(
    MEMBER_ID varchar(500),
    URL varchar(500)
);


CREATE TABLE public.TRD_REJ_PRD_MASTER
(
    MEMBER_ID varchar(200),
    S5_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    PRODUCT_LEVEL varchar(200),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_PRD_HIER
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    ANCESTOR5 varchar(500),
    ANCESTOR6 varchar(500),
    ANCESTOR7 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_IMG_URL
(
    MEMBER_ID varchar(500),
    URL varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_VV_ATTRVALIDVALUESASSOCIATION
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_NAME varchar(200),
    SEQ_NO varchar(200),
    DEPT varchar(200),
    CLASS varchar(200),
    SUBCLASS varchar(200),
    REQUIRED_IND varchar(200),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_VV_ATTRVALIDVALUES
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_DESC varchar(200),
    ATTRIBUTE_VALUE varchar(200),
    ATTRIBUTE_VALUE_DESC varchar(200),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_VV_COLORMAPPING
(
    COLOR_ID varchar(200),
    COLOR_DESCRIPTION varchar(200),
    COLOR_CODE varchar(200),
    DW_COLOR_FAMILY varchar(200),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_LOC_MASTER
(
    MEMBER_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    LOC_LEVEL varchar(200),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_LOC_HIER
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_ACT_ONORDER
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    FLOW_ID varchar(500),
    WEEK_ID varchar(500),
    PRICE_STATUS varchar(500),
    NDC_DATE varchar(500),
    START_SHIP_DATE varchar(500),
    PO_CANCEL_DATE varchar(500),
    PO_ID varchar(500),
    TOTAL_UNITS numeric(16,4),
    TOTAL_COST numeric(16,4),
    TOTAL_RETAIL numeric(16,4),
    P_NBR_PACKS varchar(500),
    P_PACK_ID varchar(500),
    P_QTY_PER_PACK varchar(500),
    P_PO_TYPE varchar(500),
    P_VENDOR_NBR varchar(500),
    P_PO_VENDOR_NBR varchar(500),
    P_VENDOR_DESC varchar(500),
    PO_LN_SEQ_NUM varchar(500)
);


CREATE TABLE public.TRD_REJ_ACT_ONORDER
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    FLOW_ID varchar(500),
    WEEK_ID varchar(500),
    PRICE_STATUS varchar(500),
    NDC_DATE varchar(500),
    START_SHIP_DATE varchar(500),
    PO_CANCEL_DATE varchar(500),
    PO_ID varchar(500),
    TOTAL_UNITS numeric(16,4),
    TOTAL_COST numeric(16,4),
    TOTAL_RETAIL numeric(16,4),
    P_NBR_PACKS varchar(500),
    P_PACK_ID varchar(500),
    P_QTY_PER_PACK varchar(500),
    P_PO_TYPE varchar(500),
    P_VENDOR_NBR varchar(500),
    P_PO_VENDOR_NBR varchar(500),
    P_VENDOR_DESC varchar(500),
    PO_LN_SEQ_NUM varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_VV_COLORSWATCHES
(
    COLOR_ID varchar(200),
    STRTYPE varchar(200),
    DATASTR varchar(200)
);


CREATE TABLE public.TRD_REJ_VV_COLORSWATCHES
(
    COLOR_ID varchar(200),
    STRTYPE varchar(200),
    DATASTR varchar(200)
);


CREATE TABLE public.TRD_IN_TIME_HIER
(
    DATE_ID varchar(200),
    WEEK_ID varchar(200),
    MONTH_ID varchar(200),
    QUARTER_ID varchar(200),
    SEASON_ID varchar(200),
    YEAR_ID varchar(200)
);


CREATE TABLE public.TRD_INT_ACT_WEEKLYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    "TIME" varchar(500),
    VND_TO_DC_RCT_R numeric(16,4),
    VND_TO_DC_RCT_U numeric(16,4),
    VND_TO_DC_RCT_C numeric(16,4),
    DC_TO_STR_RCT_R numeric(16,4),
    DC_TO_STR_RCT_U numeric(16,4),
    DC_TO_STR_RCT_C numeric(16,4),
    INV_ADJUSTMENT_R numeric(16,4),
    INV_ADJUSTMENT_U numeric(16,4),
    INV_ADJUSTMENT_C numeric(16,4),
    MOS_R numeric(16,4),
    MOS_U numeric(16,4),
    MOS_C numeric(16,4),
    SHRINK_R numeric(16,4),
    SHRINK_U numeric(16,4),
    SHRINK_C numeric(16,4),
    XFER_IN_R numeric(16,4),
    XFER_IN_U numeric(16,4),
    XFER_IN_C numeric(16,4),
    XFER_OUT_R numeric(16,4),
    XFER_OUT_U numeric(16,4),
    XFER_OUT_C numeric(16,4),
    STORE_TO_WEB_R numeric(16,4),
    STORE_TO_WEB_U numeric(16,4),
    STORE_TO_WEB_C numeric(16,4),
    WEB_TO_STORE_R numeric(16,4),
    WEB_TO_STORE_U numeric(16,4),
    WEB_TO_STORE_C numeric(16,4),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INT_ACT_DAILYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INT_ACT_SALES_TRANSACTIONS
(
    TRANSACTION_ID varchar(500),
    CUSTOMER_ID varchar(500),
    MEMBER_ID varchar(500),
    CLIENT_MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    BOPIS_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R_CSP numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_INT_ACT_DEMAND_SALES
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4),
    CREATED_AT timestamp
);


CREATE TABLE public.TRD_IN_IMG_URL_20240408
(
    MEMBER_ID varchar(500),
    URL varchar(500)
);


CREATE TABLE public.TRD_IN_LOC_HIER_20240408
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500)
);


CREATE TABLE public.TRD_IN_LOC_MASTER_20240408
(
    MEMBER_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    LOC_LEVEL varchar(200)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSKU_20240408
(
    ITEM varchar(500),
    ITEM_DIFF_2 varchar(500),
    ITEM_DIFF_3 varchar(500),
    STYLECOLORSIZE_CREATE_DATE varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSTYLE_20240408
(
    MEMBER_ID varchar(500),
    KNIT_OR_WOVEN varchar(500),
    FABRICATION varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    BODY_STYLE_SILHOUETTE varchar(500),
    OCCASION_USAGE varchar(500),
    DETAIL varchar(500),
    FINISH_STYLE varchar(500),
    PRIVATE_LABEL varchar(500),
    LICENSE varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    ITEM_TYPE varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    V_360_SMOOTHING varchar(500),
    FRANCHISE varchar(500),
    KEY_ITEM varchar(500),
    SINGLE_VS_MULTI_PACK varchar(500),
    TICKET_TYPE varchar(500),
    VPN varchar(500),
    SIZE_RANGE varchar(500),
    RMS_STYLECOLOR_CREATE_DATE varchar(500),
    STYLE_ATTRIBUTE_1 varchar(500),
    STYLE_ATTRIBUTE_2 varchar(500),
    STYLE_ATTRIBUTE_3 varchar(500),
    STYLE_ATTRIBUTE_4 varchar(500),
    STYLE_ATTRIBUTE_5 varchar(500),
    STYLE_ATTRIBUTE_6 varchar(500),
    STYLE_ATTRIBUTE_7 varchar(500),
    STYLE_ATTRIBUTE_8 varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSTYLECLR_20240408
(
    MEMBER_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    UNIT_RETAIL varchar(500),
    UNIT_RETAIL_CAD varchar(500),
    PATTERN varchar(500),
    GRAPHIC varchar(500),
    FASHION_BASIC varchar(500),
    HOLIDAY varchar(500),
    PROPERTY_TYPE varchar(500),
    INTERNET_EXCLUSIVE varchar(500),
    WEB_COLOR_DISCRIPTION varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    SEASON_CODE varchar(500),
    DTR varchar(500),
    DW_COLOR_FAMILY varchar(500),
    CHANNEL_REORDER varchar(500),
    TICKET_SEASON_CODE varchar(500),
    SUB_PROGRAMS varchar(500),
    MUSIC_GENRE varchar(500),
    CLEARANCE_STR_PRODUCT varchar(500),
    PO_SUPPLIER varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST varchar(500),
    FREIGHT varchar(500),
    ROYALTY varchar(500),
    DUTY varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    PATTERN_TYPE varchar(500),
    POP_PRINT_NEUTRAL varchar(500),
    DEBUT_SEASON_CODE varchar(500),
    MATCHBACK varchar(500),
    PRIMARY_COLLECTION varchar(500),
    SECONDARY_COLLECTION varchar(500),
    VPN_COLOR varchar(500),
    ORIG_UNIT_RETAIL varchar(500),
    ORIG_UNIT_RETAIL_CAD varchar(500),
    FIRST_REC_WEEK varchar(500),
    FIRST_INV_WEEK varchar(500),
    FIRST_SALE_WEEK varchar(500),
    FIRST_MD_WEEK varchar(500),
    LAST_MD_WEEK varchar(500),
    LAST_REC_WEEK varchar(500),
    STORE_PRICE_STATUS varchar(500),
    IFC_PRICE_STATUS varchar(500),
    OMNI_PRICE_TYPE varchar(500),
    STYLECOLOR_CREATE_DATE varchar(500),
    PRICE_BAND varchar(500),
    GOOD_BETTER_BEST varchar(500),
    STYLECOLOR_ATTRIBUTE_1 varchar(500),
    STYLECOLOR_ATTRIBUTE_2 varchar(500),
    STYLECOLOR_ATTRIBUTE_3 varchar(500),
    STYLECOLOR_ATTRIBUTE_4 varchar(500),
    STYLECOLOR_ATTRIBUTE_5 varchar(500),
    STYLECOLOR_ATTRIBUTE_6 varchar(500),
    STYLECOLOR_ATTRIBUTE_7 varchar(500),
    STYLECOLOR_ATTRIBUTE_8 varchar(500),
    STYLECOLOR_ATTRIBUTE_9 varchar(500),
    STYLECOLOR_ATTRIBUTE_10 varchar(500),
    STYLECOLOR_ATTRIBUTE_11 varchar(500),
    STYLECOLOR_ATTRIBUTE_12 varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_HIER_20240408
(
    MEMBER_ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    ANCESTOR5 varchar(500),
    ANCESTOR6 varchar(500),
    ANCESTOR7 varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_MASTER_20240408
(
    MEMBER_ID varchar(200),
    S5_ID varchar(200),
    MEMBER_NAME varchar(200),
    MEMBER_DESC varchar(200),
    PRODUCT_LEVEL varchar(200)
);


CREATE TABLE public.TRD_IN_VV_ATTRVALIDVALUES_20240408
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_DESC varchar(200),
    ATTRIBUTE_VALUE varchar(200),
    ATTRIBUTE_VALUE_DESC varchar(200)
);


CREATE TABLE public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408
(
    ATTRIBUTE_ID varchar(200),
    ATTRIBUTE_NAME varchar(200),
    SEQ_NO varchar(200),
    DEPT varchar(200),
    CLASS varchar(200),
    SUBCLASS varchar(200),
    REQUIRED_IND varchar(200)
);


CREATE TABLE public.TRD_IN_VV_COLORMAPPING_20240408
(
    COLOR_ID varchar(200),
    COLOR_DESCRIPTION varchar(200),
    COLOR_CODE varchar(200),
    DW_COLOR_FAMILY varchar(200)
);


CREATE TABLE public.TRD_IN_VV_COLORSWATCHES_20240408
(
    COLOR_ID varchar(200),
    STRTYPE varchar(200),
    DATASTR varchar(200)
);


CREATE TABLE public.trd_int_p_history_inv_funded
(
    product varchar(500),
    location varchar(500),
    skuloc_first_funded_week varchar(500)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_WEEKLYINVENTORY_DAILY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    VND_TO_DC_RCT_R numeric(16,4),
    VND_TO_DC_RCT_U numeric(16,4),
    VND_TO_DC_RCT_C numeric(16,4),
    DC_TO_STR_RCT_R numeric(16,4),
    DC_TO_STR_RCT_U numeric(16,4),
    DC_TO_STR_RCT_C numeric(16,4),
    INV_ADJUSTMENT_R numeric(16,4),
    INV_ADJUSTMENT_U numeric(16,4),
    INV_ADJUSTMENT_C numeric(16,4),
    MOS_R numeric(16,4),
    MOS_U numeric(16,4),
    MOS_C numeric(16,4),
    SHRINK_R numeric(16,4),
    SHRINK_U numeric(16,4),
    SHRINK_C numeric(16,4),
    XFER_IN_R numeric(16,4),
    XFER_IN_U numeric(16,4),
    XFER_IN_C numeric(16,4),
    XFER_OUT_R numeric(16,4),
    XFER_OUT_U numeric(16,4),
    XFER_OUT_C numeric(16,4),
    STORE_TO_WEB_R numeric(16,4),
    STORE_TO_WEB_U numeric(16,4),
    STORE_TO_WEB_C numeric(16,4),
    WEB_TO_STORE_R numeric(16,4),
    WEB_TO_STORE_U numeric(16,4),
    WEB_TO_STORE_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_PERF_ACT_SLSWEEK
(
    DAY_ID varchar(500)
);


CREATE TABLE public.TRD_PERF_ACT_DMDWEEK
(
    DAY_ID varchar(500)
);


CREATE TABLE public.trd_p_history_sku_new_strcntwk
(
    product varchar(500),
    location varchar(500),
    "time" varchar(514),
    prodlife varchar(2),
    cluster varchar(50),
    stylecolor varchar(500),
    strcntwk numeric(18,4),
    new_strcntwk numeric(40,22),
    strcntwk_funded int,
    in_stock_crit numeric(18,4)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_REJ_ACT_SALES_TRANSACTIONS
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_REJ_ACT_DAILYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_DAILY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_DAILY
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_REJ_ACT_DEMAND_SALES
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.trd_int_p_history_inv_funded_bk
(
    product varchar(500),
    location varchar(500),
    skuloc_first_funded_week varchar(500)
);


CREATE TABLE public.TRD_PERF_ACT_INVWEEK
(
    "TIME" varchar(500)
);


CREATE TABLE public.TRD_PERF_ACT_DAILYINVWEEK
(
    "TIME" varchar(500)
);


CREATE TABLE public.trd_p_history_inv
(
    product varchar(500),
    location varchar(500),
    "time" varchar(511),
    cctytime varchar(20),
    prodlife varchar(2),
    cluster varchar(50),
    stylecolor varchar(500),
    boh_r numeric(22,4),
    boh_u numeric(22,4),
    boh_c numeric(22,4),
    bop_intransit_r numeric(22,4),
    bop_intransit_u numeric(22,4),
    bop_intransit_c numeric(22,4),
    eoh_r numeric(34,4),
    eoh_u numeric(34,4),
    eoh_c numeric(34,4),
    eop_intransit_r numeric(34,4),
    eop_intransit_u numeric(34,4),
    eop_intransit_c numeric(34,4),
    avg_unit_cost numeric(22,4),
    original_ticket_price numeric(22,4),
    current_ticket_price numeric(22,4),
    perm_md_r numeric(22,4),
    perm_md_c numeric(22,4),
    perm_md_u numeric(22,4),
    perm_md_r_csp numeric(22,4),
    rec_r numeric(22,4),
    rec_u numeric(22,4),
    rec_c numeric(22,4),
    dc_to_str_rct_r numeric(22,4),
    dc_to_str_rct_u numeric(22,4),
    dc_to_str_rct_c numeric(22,4),
    inv_adjustment_r numeric(22,4),
    inv_adjustment_u numeric(22,4),
    inv_adjustment_c numeric(22,4),
    mos_r numeric(22,4),
    mos_u numeric(22,4),
    mos_c numeric(22,4),
    shrink_r numeric(22,4),
    shrink_u numeric(22,4),
    shrink_c numeric(22,4),
    xfer_in_r numeric(22,4),
    xfer_in_u numeric(22,4),
    xfer_in_c numeric(22,4),
    xfer_out_r numeric(22,4),
    xfer_out_u numeric(22,4),
    xfer_out_c numeric(22,4),
    store_to_web_r numeric(22,4),
    store_to_web_u numeric(22,4),
    store_to_web_c numeric(22,4),
    web_to_store_r numeric(22,4),
    web_to_store_u numeric(22,4),
    web_to_store_c numeric(22,4),
    strcntwk int,
    skuloc_first_funded_week varchar(500)
);


CREATE TABLE public.TRD_IN_ACT_WEEKLYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    VND_TO_DC_RCT_R numeric(16,4),
    VND_TO_DC_RCT_U numeric(16,4),
    VND_TO_DC_RCT_C numeric(16,4),
    DC_TO_STR_RCT_R numeric(16,4),
    DC_TO_STR_RCT_U numeric(16,4),
    DC_TO_STR_RCT_C numeric(16,4),
    INV_ADJUSTMENT_R numeric(16,4),
    INV_ADJUSTMENT_U numeric(16,4),
    INV_ADJUSTMENT_C numeric(16,4),
    MOS_R numeric(16,4),
    MOS_U numeric(16,4),
    MOS_C numeric(16,4),
    SHRINK_R numeric(16,4),
    SHRINK_U numeric(16,4),
    SHRINK_C numeric(16,4),
    XFER_IN_R numeric(16,4),
    XFER_IN_U numeric(16,4),
    XFER_IN_C numeric(16,4),
    XFER_OUT_R numeric(16,4),
    XFER_OUT_U numeric(16,4),
    XFER_OUT_C numeric(16,4),
    STORE_TO_WEB_R numeric(16,4),
    STORE_TO_WEB_U numeric(16,4),
    STORE_TO_WEB_C numeric(16,4),
    WEB_TO_STORE_R numeric(16,4),
    WEB_TO_STORE_U numeric(16,4),
    WEB_TO_STORE_C numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_WEEKLYINVENTORY_ARCHIVE
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    VND_TO_DC_RCT_R numeric(16,4),
    VND_TO_DC_RCT_U numeric(16,4),
    VND_TO_DC_RCT_C numeric(16,4),
    DC_TO_STR_RCT_R numeric(16,4),
    DC_TO_STR_RCT_U numeric(16,4),
    DC_TO_STR_RCT_C numeric(16,4),
    INV_ADJUSTMENT_R numeric(16,4),
    INV_ADJUSTMENT_U numeric(16,4),
    INV_ADJUSTMENT_C numeric(16,4),
    MOS_R numeric(16,4),
    MOS_U numeric(16,4),
    MOS_C numeric(16,4),
    SHRINK_R numeric(16,4),
    SHRINK_U numeric(16,4),
    SHRINK_C numeric(16,4),
    XFER_IN_R numeric(16,4),
    XFER_IN_U numeric(16,4),
    XFER_IN_C numeric(16,4),
    XFER_OUT_R numeric(16,4),
    XFER_OUT_U numeric(16,4),
    XFER_OUT_C numeric(16,4),
    STORE_TO_WEB_R numeric(16,4),
    STORE_TO_WEB_U numeric(16,4),
    STORE_TO_WEB_C numeric(16,4),
    WEB_TO_STORE_R numeric(16,4),
    WEB_TO_STORE_U numeric(16,4),
    WEB_TO_STORE_C numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_REJ_ACT_WEEKLYINVENTORY
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    VND_TO_DC_RCT_R numeric(16,4),
    VND_TO_DC_RCT_U numeric(16,4),
    VND_TO_DC_RCT_C numeric(16,4),
    DC_TO_STR_RCT_R numeric(16,4),
    DC_TO_STR_RCT_U numeric(16,4),
    DC_TO_STR_RCT_C numeric(16,4),
    INV_ADJUSTMENT_R numeric(16,4),
    INV_ADJUSTMENT_U numeric(16,4),
    INV_ADJUSTMENT_C numeric(16,4),
    MOS_R numeric(16,4),
    MOS_U numeric(16,4),
    MOS_C numeric(16,4),
    SHRINK_R numeric(16,4),
    SHRINK_U numeric(16,4),
    SHRINK_C numeric(16,4),
    XFER_IN_R numeric(16,4),
    XFER_IN_U numeric(16,4),
    XFER_IN_C numeric(16,4),
    XFER_OUT_R numeric(16,4),
    XFER_OUT_U numeric(16,4),
    XFER_OUT_C numeric(16,4),
    STORE_TO_WEB_R numeric(16,4),
    STORE_TO_WEB_U numeric(16,4),
    STORE_TO_WEB_C numeric(16,4),
    WEB_TO_STORE_R numeric(16,4),
    WEB_TO_STORE_U numeric(16,4),
    WEB_TO_STORE_C numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_R_CSP numeric(16,4),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_PRD_SPECSTYLECOLORIMAGES
(
    VPN_COLOR varchar(500),
    JPG varchar(500)
);


CREATE TABLE public.deleteme_trd_in_prd_atTRStyle
(
    MEMBER_ID varchar(500),
    KNIT_OR_WOVEN varchar(500),
    FABRICATION varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    BODY_STYLE_SILHOUETTE varchar(500),
    OCCASION_USAGE varchar(500),
    DETAIL varchar(500),
    FINISH_STYLE varchar(500),
    PRIVATE_LABEL varchar(500),
    LICENSE varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    ITEM_TYPE varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    V_360_SMOOTHING varchar(500),
    FRANCHISE varchar(500),
    KEY_ITEM varchar(500),
    SINGLE_VS_MULTI_PACK varchar(500),
    TICKET_TYPE varchar(500),
    VPN varchar(500),
    SIZE_RANGE varchar(500),
    RMS_STYLECOLOR_CREATE_DATE varchar(500),
    STYLE_ATTRIBUTE_1 varchar(500),
    STYLE_ATTRIBUTE_2 varchar(500),
    STYLE_ATTRIBUTE_3 varchar(500),
    STYLE_ATTRIBUTE_4 varchar(500),
    STYLE_ATTRIBUTE_5 varchar(500),
    STYLE_ATTRIBUTE_6 varchar(500),
    STYLE_ATTRIBUTE_7 varchar(500),
    STYLE_ATTRIBUTE_8 varchar(500)
);


CREATE TABLE public.trd_int_store_tier_dept_week_bk
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50),
    cluster varchar(50)
);


CREATE TABLE public.DELETEME_TRD_CORRECT_FLOORSET_MAPPING
(
    DEPT_ID varchar(200),
    BAD_FLOORSET_ID varchar(200),
    CORRECT_FLOORSET_ID varchar(200),
    CORRECT_FLOORSET_ID_WITHOUT_PREFIX varchar(200)
);


CREATE TABLE public.trd_l_dependencylookup_bk
(
    lookup_id varchar(500),
    lookup_value varchar(500),
    target_id varchar(500),
    target_value varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    index int
);


CREATE TABLE public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk
(
    VPN_VSN varchar(500),
    VPN_DESCRIPTION varchar(500),
    VPN_COLOR varchar(500),
    VPN_COLOR_DESCRIPTION varchar(500),
    DEPT_ID varchar(500),
    CLASS_ID varchar(500),
    SUBCLASS_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    DW_COLOR_FAMILY varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST varchar(500),
    FREIGHT varchar(500),
    AGENT_FEE varchar(500),
    DUTY varchar(500),
    PORT varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    FACTORY varchar(500),
    PO_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    DESIGN_STYLECOLOR_STATUS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SPEC_STYLECOLOR_OPEN1 varchar(500),
    SPEC_STYLECOLOR_OPEN2 varchar(500),
    SPEC_STYLECOLOR_OPEN3 varchar(500),
    SPEC_STYLECOLOR_OPEN4 varchar(500),
    SPEC_STYLECOLOR_OPEN5 varchar(500),
    SPEC_STYLECOLOR_OPEN6 varchar(500),
    SPEC_STYLECOLOR_OPEN7 varchar(500),
    SPEC_STYLECOLOR_OPEN8 varchar(500),
    SPEC_STYLECOLOR_OPEN9 varchar(500),
    SPEC_STYLECOLOR_OPEN10 varchar(500),
    SPEC_STYLECOLOR_OPEN11 varchar(500),
    SPEC_STYLECOLOR_OPEN12 varchar(500)
);


CREATE TABLE public.trd_ma_dptflrsetattributes_test
(
    indx int,
    product varchar(200),
    "time" varchar(200),
    floorset_name varchar(200),
    dept_name varchar(200),
    superset_id varchar(200),
    superset_name varchar(200),
    initialrcptwk varchar(200),
    rcptstart varchar(200),
    rcptend varchar(200),
    slsstart varchar(200),
    slsend varchar(200),
    weeks_at_fp varchar(200),
    markdown_week varchar(200),
    exit_week varchar(200),
    ly_rcptstart varchar(200),
    ly_rcptend varchar(200),
    ly_slsstart varchar(200),
    ly_slsend varchar(200),
    ap_start varchar(200),
    ap_end varchar(200),
    planned_sell_down_week varchar(200),
    floorset_uda varchar(200),
    ly_floorset_uda varchar(200),
    default_slsrnk_store numeric(16,4),
    default_slsrnk_ecom numeric(16,4),
    default_store_vol_grade varchar(5000),
    default_store_climate varchar(5000),
    default_store_capacity varchar(5000),
    default_store_banner varchar(5000),
    default_store_geo_region varchar(5000),
    default_store_hazmat varchar(5000),
    irw_debut_offset int,
    default_presmin int,
    default_presmin_weeks int,
    default_ccrcptint int,
    default_retpct_str numeric(16,4),
    default_retpct_ecom numeric(16,4),
    default_crosschannel_retpct_ecom numeric(16,4),
    default_ccordermultiple_uom int,
    default_ccmdstrategy varchar(200),
    default_lead_time int,
    default_ccdiscountpct float,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_int_store_tier_dept_week_bk_20240810
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50),
    cluster varchar(50)
);


CREATE TABLE public.trd_ref_store_tier_class_min_week
(
    class_id varchar(200),
    min_week varchar(50)
);


CREATE TABLE public.temp_md_seq
(
    seq_indx int
);


CREATE TABLE public.temp_md_clean_x
(
    department varchar(200),
    mdstrategy varchar(200),
    seq int,
    duration int,
    end_seq int,
    start_seq int,
    md_disc numeric(16,4),
    factor numeric(3,3)
);


CREATE TABLE public.temp_md_clean
(
    department varchar(200),
    mdstrategy varchar(200),
    seq int,
    duration int,
    end_seq int,
    start_seq int,
    md_disc numeric(16,4),
    factor numeric(3,3)
);


CREATE TABLE public.trd_BUS_MD_STRATEGY_TEMP
(
    department varchar(200),
    max_seq int
);


CREATE TABLE public.trd_BUS_MD_STRATEGY_PREP
(
    department varchar(200),
    max_seq int,
    seq int,
    mdstrategy varchar(200),
    md_disc numeric(16,4),
    factor numeric(3,3)
);


CREATE TABLE public.deleteme_possible_tier_weeks
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50)
);


CREATE TABLE public.trd_c_conversion_file_backup_20240919
(
    FLOORSET_CODE varchar(200),
    DEPARTMENT_ID varchar(200),
    CLASS_ID varchar(200),
    SUBCLASS_ID varchar(200),
    STYLE_ID varchar(200),
    STYLE_COLOR_ID varchar(200),
    STYLE_COLOR_DESC varchar(200),
    TICKET_PRICE numeric(16,2),
    COST numeric(16,2),
    DEFAULT_DISC numeric(16,2),
    DEBUT_WEEK varchar(200),
    MD_WEEK varchar(200),
    EXIT_WEEK varchar(200),
    AUTO_ROLL_FORWARD boolean,
    PLANNED_SELL_DOWN_WK varchar(200),
    MD_STRATEGY varchar(200),
    STORE_VOL_GRADE varchar(2000),
    STORE_CLIMATE varchar(2000),
    STORE_CAPACITY varchar(2000),
    STORE_BANNER varchar(2000),
    STORE_REGION varchar(2000),
    STORE_HAZMAT varchar(2000),
    SSG varchar(200),
    SIZE_RANGE varchar(200),
    VALID_SIZES_STORES varchar(20000),
    VALID_SIZES_ECOM varchar(20000),
    SIZE_MIN int,
    SIZE_MIN_WEEKS int,
    PRE_SSN_RATING_STRS numeric(16,1),
    PRE_SSN_RATING_ECOM numeric(16,1),
    RECEIPT_INTERVAL int,
    RETURN_RATE_STRS numeric(16,2),
    RETURN_RATE_ECOM numeric(16,2),
    CROSS_CHANNEL_RET_RATE numeric(16,2),
    ORDER_MIN int,
    ORDER_MULTIPLE int
);


CREATE TABLE public.TRD_IN_BUS_SSG_bk_20240919
(
    SSG_ID varchar(200),
    LOCATION varchar(200),
    SSG_NAME varchar(200),
    SSG_STORE varchar(5000)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSKU_JR
(
    ITEM varchar(500),
    ITEM_DIFF_2 varchar(500),
    ITEM_DIFF_3 varchar(500),
    STYLECOLORSIZE_CREATE_DATE varchar(500),
    SIZE_ATTR_ID varchar(500)
);


CREATE TABLE public.trd_ma_sizeattributes_existing_bk
(
    product varchar(200),
    parent_id varchar(200),
    item_diff_2 varchar(200),
    sizeattribute varchar(500),
    isvalid int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.TRD_IN_PRD_ATTRSKU
(
    ITEM varchar(500),
    ITEM_DIFF_2 varchar(500),
    ITEM_DIFF_3 varchar(500),
    STYLECOLORSIZE_CREATE_DATE varchar(500),
    SIZE_ATTR_ID varchar(500)
);


CREATE TABLE public.trd_l_dependencylookup_bk_20240922
(
    lookup_id varchar(500),
    lookup_value varchar(500),
    target_id varchar(500),
    target_value varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    index int
);


CREATE TABLE public.trd_v_memberbasedvalidvalues_bk_20240922
(
    attributeid varchar(200),
    membertie varchar(200),
    attributekey varchar(200),
    attributevalue varchar(200),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_eohdata_stylecolor
(
    product varchar(500),
    channel varchar(500),
    eohu numeric(34,4)
);


CREATE TEMPORARY TABLE public.temp_dependencylkp_na
(
    lookup_id varchar(500),
    lookup_value varchar(500),
    target_id varchar(500),
    target_value varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    index int
) NO PROJECTION;


CREATE TABLE public.trd_l_pricebandlookup_bk
(
    product varchar(200),
    ticket_price_min float,
    ticket_price_max float,
    price_band varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.TRD_REJ_PRD_ATTRSKU
(
    ITEM varchar(500),
    ITEM_DIFF_2 varchar(500),
    ITEM_DIFF_3 varchar(500),
    STYLECOLORSIZE_CREATE_DATE varchar(500),
    SIZE_ATTR_ID varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.temp_last_elapsed_month
(
    lastElapsedMonth varchar(50)
);


CREATE TABLE public.temp_last_elapsed_quarter
(
    lastElapsedQuarter varchar(50)
);


CREATE TABLE public.temp_s5_tgt_master_week
(
    "time" varchar(50),
    month varchar(50),
    quarter varchar(50),
    season varchar(50),
    year varchar(50)
);


CREATE TABLE public.TRD_IN_PRD_REPLANNABLE_STYLECOLORS
(
    STYLECOLOR_ID varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_REPLANNABLE_SPECSTYLECOLORS
(
    SPECSTYLE_ID varchar(500),
    SPECSTYLECOLOR_ID varchar(500)
);


CREATE TABLE public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024
(
    DEPT_ID varchar(200),
    NEW_FLOORSET_ID varchar(200),
    FLOORSET_ID varchar(200)
);


CREATE TABLE public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD
(
    LOCATION_ID varchar(200),
    FLOORSET_ID varchar(200),
    CLASS_ID varchar(200),
    TIER varchar(50),
    DEPT_ID varchar(100)
);


CREATE TABLE public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS
(
    FLOORSET_ID varchar(200),
    DEPT_ID varchar(200),
    CORRECT_FLOORSET_ID varchar(200)
);


CREATE TABLE public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS
(
    FLOORSET_ID varchar(200),
    DEPT_ID varchar(200),
    CORRECT_FLOORSET_ID varchar(200),
    CLASS_ID varchar(500)
);


CREATE TABLE public.deleteme_trd_v_memberbasedvalidvalues_pg
(
    attributeid varchar(200),
    membertie varchar(200),
    attributekey varchar(200),
    attributevalue varchar(200),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.deleteme_trd_l_dependencylookup_pg
(
    lookup_id varchar(500),
    lookup_value varchar(500),
    target_id varchar(500),
    target_value varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    index int
);


CREATE TABLE public.trd_int_ma_dptflrsetattributes
(
    DEPT_ID varchar(50),
    DEPT_NAME varchar(50),
    SUPERSET_ID varchar(50),
    SUPERSET_NAME varchar(50),
    FLOORSET_ID varchar(50),
    FLOORSET_NAME varchar(50),
    INITIALRCPTWK varchar(50),
    RCPTSTART varchar(50),
    RCPTEND varchar(50),
    SLSSTART varchar(50),
    SLSEND varchar(50),
    WEEKS_AT_FP varchar(50),
    MARKDOWN_WEEK varchar(50),
    EXIT_WEEK varchar(50),
    LY_RCPTSTART varchar(50),
    LY_RCPTEND varchar(50),
    LY_SLSSTART varchar(50),
    LY_SLSEND varchar(50),
    AP_START varchar(50),
    AP_END varchar(50),
    PLANNED_SELL_DOWN_WEEK varchar(50),
    FLOORSET_UDA varchar(50),
    LY_FLOORSET_UDA varchar(50),
    PRESSN_RATING_STORES numeric(16,4),
    PRESSN_RATING_ECOM numeric(16,4),
    DEFAULT_STORE_VOL_GRADE varchar(5000),
    DEFAULT_STORE_CLIMATE varchar(5000),
    DEFAULT_STORE_CAPACITY varchar(5000),
    DEFAULT_STORE_BANNER varchar(5000),
    DEFAULT_STORE_GEO_REGION varchar(5000),
    DEFAULT_STORE_HAZMAT varchar(5000),
    IRW_Debut_Offset int
);


CREATE TABLE public.trd_h_prodstd_backup_20241216
(
    ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    ANCESTOR5 varchar(500),
    ANCESTOR6 varchar(500),
    ANCESTOR7 varchar(500),
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.deleteme_TRD_REF_S5_CLIENT_ID_MAPPING
(
    s5_id varchar(100),
    client_erp_id varchar(100),
    levelid varchar(20)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSTYLE
(
    MEMBER_ID varchar(500),
    KNIT_OR_WOVEN varchar(500),
    FABRICATION varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    BODY_STYLE_SILHOUETTE varchar(500),
    OCCASION_USAGE varchar(500),
    DETAIL varchar(500),
    FINISH_STYLE varchar(500),
    PRIVATE_LABEL varchar(500),
    LICENSE varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    ITEM_TYPE varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    V_360_SMOOTHING varchar(500),
    FRANCHISE varchar(500),
    KEY_ITEM varchar(500),
    SINGLE_VS_MULTI_PACK varchar(500),
    TICKET_TYPE varchar(500),
    VPN varchar(500),
    SIZE_RANGE varchar(500),
    RMS_STYLECOLOR_CREATE_DATE varchar(500),
    KNIT_FIT varchar(500),
    STYLE_ATTRIBUTE_1 varchar(500),
    STYLE_ATTRIBUTE_2 varchar(500),
    STYLE_ATTRIBUTE_3 varchar(500),
    STYLE_ATTRIBUTE_4 varchar(500),
    STYLE_ATTRIBUTE_5 varchar(500),
    STYLE_ATTRIBUTE_6 varchar(500),
    STYLE_ATTRIBUTE_7 varchar(500),
    STYLE_ATTRIBUTE_8 varchar(500)
);


CREATE TABLE public.TRD_IN_PRD_ATTRSTYLECLR
(
    MEMBER_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    UNIT_RETAIL varchar(500),
    UNIT_RETAIL_CAD varchar(500),
    PATTERN varchar(500),
    GRAPHIC varchar(500),
    FASHION_BASIC varchar(500),
    HOLIDAY varchar(500),
    PROPERTY_TYPE varchar(500),
    INTERNET_EXCLUSIVE varchar(500),
    WEB_COLOR_DISCRIPTION varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    SEASON_CODE varchar(500),
    DTR varchar(500),
    DW_COLOR_FAMILY varchar(500),
    CHANNEL_REORDER varchar(500),
    TICKET_SEASON_CODE varchar(500),
    SUB_PROGRAMS varchar(500),
    MUSIC_GENRE varchar(500),
    CLEARANCE_STR_PRODUCT varchar(500),
    PO_SUPPLIER varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST varchar(500),
    FREIGHT varchar(500),
    ROYALTY varchar(500),
    DUTY varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    PATTERN_TYPE varchar(500),
    POP_PRINT_NEUTRAL varchar(500),
    DEBUT_SEASON_CODE varchar(500),
    MATCHBACK varchar(500),
    PRIMARY_COLLECTION varchar(500),
    SECONDARY_COLLECTION varchar(500),
    VPN_COLOR varchar(500),
    ORIG_UNIT_RETAIL varchar(500),
    ORIG_UNIT_RETAIL_CAD varchar(500),
    FIRST_REC_WEEK varchar(500),
    FIRST_INV_WEEK varchar(500),
    FIRST_SALE_WEEK varchar(500),
    FIRST_MD_WEEK varchar(500),
    LAST_MD_WEEK varchar(500),
    LAST_REC_WEEK varchar(500),
    STORE_PRICE_STATUS varchar(500),
    IFC_PRICE_STATUS varchar(500),
    OMNI_PRICE_TYPE varchar(500),
    STYLECOLOR_CREATE_DATE varchar(500),
    PRICE_BAND varchar(500),
    GOOD_BETTER_BEST varchar(500),
    SUPP_COST varchar(500),
    FINISH varchar(500),
    LICENSE varchar(500),
    CHANNEL_AVAILABILITY varchar(500),
    EXTENDED_SIZE varchar(500),
    OP_MARKDOWN_WEEK varchar(500),
    MOTIF varchar(500),
    RP_REVISED_MARKDOWN_WEEK varchar(500),
    WEB_CURRENT_RETAIL varchar(500),
    PARENT_SEASON_CODE varchar(500),
    ART_CODE varchar(500),
    MATERIAL_CONTENT varchar(500),
    FABRICATION varchar(500),
    STYLECOLOR_ATTRIBUTE_1 varchar(500),
    STYLECOLOR_ATTRIBUTE_2 varchar(500),
    STYLECOLOR_ATTRIBUTE_3 varchar(500),
    STYLECOLOR_ATTRIBUTE_4 varchar(500),
    STYLECOLOR_ATTRIBUTE_5 varchar(500),
    STYLECOLOR_ATTRIBUTE_6 varchar(500),
    STYLECOLOR_ATTRIBUTE_7 varchar(500),
    STYLECOLOR_ATTRIBUTE_8 varchar(500),
    STYLECOLOR_ATTRIBUTE_9 varchar(500),
    STYLECOLOR_ATTRIBUTE_10 varchar(500),
    STYLECOLOR_ATTRIBUTE_11 varchar(500),
    STYLECOLOR_ATTRIBUTE_12 varchar(500)
);


CREATE TABLE public.TRD_REJ_PRD_ATTRSTYLE
(
    MEMBER_ID varchar(500),
    KNIT_OR_WOVEN varchar(500),
    FABRICATION varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    BODY_STYLE_SILHOUETTE varchar(500),
    OCCASION_USAGE varchar(500),
    DETAIL varchar(500),
    FINISH_STYLE varchar(500),
    PRIVATE_LABEL varchar(500),
    LICENSE varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    ITEM_TYPE varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    V_360_SMOOTHING varchar(500),
    FRANCHISE varchar(500),
    KEY_ITEM varchar(500),
    SINGLE_VS_MULTI_PACK varchar(500),
    TICKET_TYPE varchar(500),
    VPN varchar(500),
    SIZE_RANGE varchar(500),
    RMS_STYLECOLOR_CREATE_DATE varchar(500),
    KNIT_FIT varchar(500),
    STYLE_ATTRIBUTE_1 varchar(500),
    STYLE_ATTRIBUTE_2 varchar(500),
    STYLE_ATTRIBUTE_3 varchar(500),
    STYLE_ATTRIBUTE_4 varchar(500),
    STYLE_ATTRIBUTE_5 varchar(500),
    STYLE_ATTRIBUTE_6 varchar(500),
    STYLE_ATTRIBUTE_7 varchar(500),
    STYLE_ATTRIBUTE_8 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_PRD_ATTRSTYLECLR
(
    MEMBER_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    UNIT_RETAIL varchar(500),
    UNIT_RETAIL_CAD varchar(500),
    PATTERN varchar(500),
    GRAPHIC varchar(500),
    FASHION_BASIC varchar(500),
    HOLIDAY varchar(500),
    PROPERTY_TYPE varchar(500),
    INTERNET_EXCLUSIVE varchar(500),
    WEB_COLOR_DISCRIPTION varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    SEASON_CODE varchar(500),
    DTR varchar(500),
    DW_COLOR_FAMILY varchar(500),
    CHANNEL_REORDER varchar(500),
    TICKET_SEASON_CODE varchar(500),
    SUB_PROGRAMS varchar(500),
    MUSIC_GENRE varchar(500),
    CLEARANCE_STR_PRODUCT varchar(500),
    PO_SUPPLIER varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST varchar(500),
    FREIGHT varchar(500),
    ROYALTY varchar(500),
    DUTY varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    PATTERN_TYPE varchar(500),
    POP_PRINT_NEUTRAL varchar(500),
    DEBUT_SEASON_CODE varchar(500),
    MATCHBACK varchar(500),
    PRIMARY_COLLECTION varchar(500),
    SECONDARY_COLLECTION varchar(500),
    VPN_COLOR varchar(500),
    ORIG_UNIT_RETAIL varchar(500),
    ORIG_UNIT_RETAIL_CAD varchar(500),
    FIRST_REC_WEEK varchar(500),
    FIRST_INV_WEEK varchar(500),
    FIRST_SALE_WEEK varchar(500),
    FIRST_MD_WEEK varchar(500),
    LAST_MD_WEEK varchar(500),
    LAST_REC_WEEK varchar(500),
    STORE_PRICE_STATUS varchar(500),
    IFC_PRICE_STATUS varchar(500),
    OMNI_PRICE_TYPE varchar(500),
    STYLECOLOR_CREATE_DATE varchar(500),
    PRICE_BAND varchar(500),
    GOOD_BETTER_BEST varchar(500),
    SUPP_COST varchar(500),
    FINISH varchar(500),
    LICENSE varchar(500),
    CHANNEL_AVAILABILITY varchar(500),
    EXTENDED_SIZE varchar(500),
    OP_MARKDOWN_WEEK varchar(500),
    MOTIF varchar(500),
    RP_REVISED_MARKDOWN_WEEK varchar(500),
    WEB_CURRENT_RETAIL varchar(500),
    PARENT_SEASON_CODE varchar(500),
    ART_CODE varchar(500),
    MATERIAL_CONTENT varchar(500),
    FABRICATION varchar(500),
    STYLECOLOR_ATTRIBUTE_1 varchar(500),
    STYLECOLOR_ATTRIBUTE_2 varchar(500),
    STYLECOLOR_ATTRIBUTE_3 varchar(500),
    STYLECOLOR_ATTRIBUTE_4 varchar(500),
    STYLECOLOR_ATTRIBUTE_5 varchar(500),
    STYLECOLOR_ATTRIBUTE_6 varchar(500),
    STYLECOLOR_ATTRIBUTE_7 varchar(500),
    STYLECOLOR_ATTRIBUTE_8 varchar(500),
    STYLECOLOR_ATTRIBUTE_9 varchar(500),
    STYLECOLOR_ATTRIBUTE_10 varchar(500),
    STYLECOLOR_ATTRIBUTE_11 varchar(500),
    STYLECOLOR_ATTRIBUTE_12 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_IN_PRD_SPECSTYLEATTRIBUTES
(
    VPN_VSN varchar(500),
    VPN_DESCRIPTION varchar(500),
    DEPT_ID varchar(500),
    CLASS_ID varchar(500),
    SUBCLASS_ID varchar(500),
    TICKET_TYPE varchar(500),
    KNIT_OR_WOVEN varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    v_360_SMOOTHING varchar(500),
    KNIT_FIT varchar(500),
    DESIGN_STYLE_STATUS varchar(500),
    SIZE_RANGE varchar(500),
    SPEC_STYLE_OPEN1 varchar(500),
    SPEC_STYLE_OPEN2 varchar(500),
    SPEC_STYLE_OPEN3 varchar(500),
    SPEC_STYLE_OPEN4 varchar(500),
    SPEC_STYLE_OPEN5 varchar(500),
    SPEC_STYLE_OPEN6 varchar(500),
    SPEC_STYLE_OPEN7 varchar(500),
    SPEC_STYLE_OPEN8 varchar(500)
);


CREATE TABLE public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING
(
    DEPT_ID varchar(200),
    NEW_FLOORSET_ID varchar(200),
    FLOORSET_ID varchar(200)
);


CREATE TABLE public.trd_dptflrset_verification
(
    Product_Dept_ID varchar(200),
    Dept_Name varchar(200),
    Superset_ID varchar(200),
    Superset_Name varchar(200),
    Floorset_ID varchar(200),
    Floorset_Name varchar(200),
    Initialrcptwk varchar(200),
    Rcptstart varchar(200),
    Rcptend varchar(200),
    Slsstart varchar(200),
    Slsend varchar(200),
    Weeks_At_FP varchar(200),
    Markdown_Week varchar(200),
    Exit_Week varchar(200),
    LY_Rcptstart varchar(200),
    LY_Rcptend varchar(200),
    LY_Slsstart varchar(200),
    LY_Slsend varchar(200),
    AP_Start varchar(200),
    AP_End varchar(200),
    Planned_Sell_Down_Week varchar(200),
    Floorset_UDA varchar(200),
    LY_Floorset_UDA varchar(200)
);


CREATE TABLE public.prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE
(
    "time" varchar(100),
    start_date varchar(100),
    end_date varchar(100),
    trd_time varchar(200)
);


CREATE TABLE public.prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME
(
    Event varchar(100),
    Week varchar(100),
    WeekIndx int,
    MonthIndx int,
    year int,
    trd_time varchar(200),
    trd_month varchar(200),
    trd_WeekIndx int,
    trd_MonthIndx int
);


CREATE TABLE public.deleteme_trd_ma_stylecolorattributes_existing
(
    product varchar(500),
    cc_item_diff_1 varchar(500),
    cc_unit_retail float,
    cc_unit_retail_cad float,
    cc_pattern varchar(500),
    cc_graphic varchar(500),
    cc_fashion_basic varchar(500),
    cc_holiday varchar(500),
    cc_property_type varchar(500),
    cc_internet_exclusive varchar(500),
    cc_web_color_discription varchar(500),
    cc_export_hts varchar(500),
    cc_commercial_invoice_description varchar(500),
    cc_season_code varchar(500),
    cc_dtr varchar(500),
    cc_dw_color_family varchar(500),
    cc_channel_reorder varchar(500),
    cc_ticket_season_code varchar(500),
    cc_sub_programs varchar(500),
    cc_music_genre varchar(500),
    cc_clearance_str_product varchar(500),
    cc_po_supplier varchar(500),
    cc_origin_country_id varchar(500),
    cc_country_of_sourcing varchar(500),
    cc_country_of_manufacturing varchar(500),
    cc_unit_cost float,
    cc_freight varchar(500),
    cc_royalty varchar(500),
    cc_duty varchar(500),
    cc_ship_method varchar(500),
    cc_lading_port varchar(500),
    cc_hts varchar(500),
    cc_primary_supplier varchar(500),
    cc_sub_brand varchar(500),
    cc_pattern_type varchar(500),
    cc_pop_print_neutral varchar(500),
    cc_debut_season_code varchar(500),
    cc_matchback varchar(500),
    cc_primary_collection varchar(500),
    cc_secondary_collection varchar(500),
    cc_vpn_color varchar(500),
    cc_orig_unit_retail float,
    cc_orig_unit_retail_cad float,
    cc_first_rec_week varchar(500),
    cc_first_inv_week varchar(500),
    cc_first_sale_week varchar(500),
    cc_first_md_week varchar(500),
    cc_last_md_week varchar(500),
    cc_last_rec_week varchar(500),
    cc_store_price_status varchar(500),
    cc_ifc_price_status varchar(500),
    cc_omni_price_type varchar(500),
    ccstylecolorcreatedate varchar(500),
    cc_price_band varchar(500),
    cc_good_better_best varchar(500),
    cccolor varchar(500),
    cccolorfamily varchar(500),
    total_brand_name varchar(500),
    division_name varchar(500),
    group_name varchar(500),
    department_name varchar(500),
    class_name varchar(500),
    subclass_name varchar(500),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    isassortment varchar(500),
    merch_comments varchar(500),
    plan_comments varchar(500),
    cc_is_locked varchar(500),
    cc_s5_adopted varchar(500),
    cc_prepublish boolean,
    cc_prepublished_at timestamp,
    allocator_comments varchar(500),
    cccolorid varchar(500),
    cc_specstylecolor_status varchar(500),
    cc_agent_fee varchar(500),
    cc_port varchar(500),
    cc_factory varchar(500),
    cc_floorset varchar(500),
    cc_use_sys_floorset boolean,
    cc_supp_cost varchar(500),
    cc_finish varchar(500),
    cc_license varchar(500),
    cc_channel_availability varchar(500),
    cc_extended_size varchar(500),
    cc_op_markdown_week varchar(500),
    cc_motif varchar(500),
    cc_rp_revised_markdown_week varchar(500),
    cc_web_current_retail float,
    cc_parent_season_code varchar(500),
    cc_art_code varchar(500),
    cc_patterned_after varchar(500),
    cc_material_content varchar(500),
    cc_fabrication varchar(500),
    stylecolor_name varchar(500),
    style_name varchar(500),
    buyer_email varchar(500)
);


CREATE TABLE public.trd_c_conversion_file
(
    FLOORSET_CODE varchar(200),
    DEPARTMENT_ID varchar(200),
    CLASS_ID varchar(200),
    SUBCLASS_ID varchar(200),
    STYLE_ID varchar(200),
    STYLE_COLOR_ID varchar(200),
    STYLE_COLOR_DESC varchar(200),
    TICKET_PRICE numeric(16,2),
    COST numeric(16,2),
    DEFAULT_DISC numeric(16,2),
    DEBUT_WEEK varchar(200),
    MD_WEEK varchar(200),
    EXIT_WEEK varchar(200),
    AUTO_ROLL_FORWARD boolean,
    PLANNED_SELL_DOWN_WK varchar(200),
    MD_STRATEGY varchar(200),
    STORE_VOL_GRADE varchar(2000),
    STORE_CLIMATE varchar(2000),
    STORE_CAPACITY varchar(2000),
    STORE_BANNER varchar(2000),
    STORE_REGION varchar(2000),
    STORE_HAZMAT varchar(2000),
    SSG varchar(200),
    SIZE_RANGE varchar(200),
    VALID_SIZES_STORES varchar(20000),
    VALID_SIZES_ECOM varchar(20000),
    SIZE_MIN int,
    SIZE_MIN_WEEKS int,
    PRE_SSN_RATING_STRS numeric(16,1),
    PRE_SSN_RATING_ECOM numeric(16,1),
    RECEIPT_INTERVAL int,
    RETURN_RATE_STRS numeric(16,2),
    RETURN_RATE_ECOM numeric(16,2),
    CROSS_CHANNEL_RET_RATE numeric(16,2),
    ORDER_MIN int,
    ORDER_MULTIPLE int,
    LEAD_TIME_DEFAULT int
);


CREATE TABLE public.trd_c_conversion_file_validcc
(
    FLOORSET_CODE varchar(200),
    DEPARTMENT_ID varchar(200),
    CLASS_ID varchar(200),
    SUBCLASS_ID varchar(200),
    STYLE_ID varchar(200),
    STYLE_COLOR_ID varchar(200),
    STYLE_COLOR_DESC varchar(200),
    TICKET_PRICE numeric(16,2),
    COST numeric(16,2),
    DEFAULT_DISC numeric(16,2),
    DEBUT_WEEK varchar(200),
    MD_WEEK varchar(200),
    EXIT_WEEK varchar(200),
    AUTO_ROLL_FORWARD boolean,
    PLANNED_SELL_DOWN_WK varchar(200),
    MD_STRATEGY varchar(200),
    STORE_VOL_GRADE varchar(2000),
    STORE_CLIMATE varchar(2000),
    STORE_CAPACITY varchar(2000),
    STORE_BANNER varchar(2000),
    STORE_REGION varchar(2000),
    STORE_HAZMAT varchar(2000),
    SSG varchar(200),
    SIZE_RANGE varchar(200),
    VALID_SIZES_STORES varchar(20000),
    VALID_SIZES_ECOM varchar(20000),
    SIZE_MIN int,
    SIZE_MIN_WEEKS int,
    PRE_SSN_RATING_STRS numeric(16,1),
    PRE_SSN_RATING_ECOM numeric(16,1),
    RECEIPT_INTERVAL int,
    RETURN_RATE_STRS numeric(16,2),
    RETURN_RATE_ECOM numeric(16,2),
    CROSS_CHANNEL_RET_RATE numeric(16,2),
    ORDER_MIN int,
    ORDER_MULTIPLE int,
    LEAD_TIME_DEFAULT int
);


CREATE TABLE public.trd_c_conversion_file_irw_offset
(
    FLOORSET_CODE varchar(200),
    DEPARTMENT_ID varchar(200),
    CLASS_ID varchar(200),
    SUBCLASS_ID varchar(200),
    STYLE_ID varchar(200),
    STYLE_COLOR_ID varchar(200),
    STYLE_COLOR_DESC varchar(200),
    TICKET_PRICE numeric(16,2),
    COST numeric(16,2),
    DEFAULT_DISC numeric(16,2),
    DEBUT_WEEK varchar(200),
    MD_WEEK varchar(200),
    EXIT_WEEK varchar(200),
    AUTO_ROLL_FORWARD boolean,
    PLANNED_SELL_DOWN_WK varchar(200),
    MD_STRATEGY varchar(200),
    STORE_VOL_GRADE varchar(2000),
    STORE_CLIMATE varchar(2000),
    STORE_CAPACITY varchar(2000),
    STORE_BANNER varchar(2000),
    STORE_REGION varchar(2000),
    STORE_HAZMAT varchar(2000),
    SSG varchar(200),
    SIZE_RANGE varchar(200),
    VALID_SIZES_STORES varchar(20000),
    VALID_SIZES_ECOM varchar(20000),
    SIZE_MIN int,
    SIZE_MIN_WEEKS int,
    PRE_SSN_RATING_STRS numeric(16,1),
    PRE_SSN_RATING_ECOM numeric(16,1),
    RECEIPT_INTERVAL int,
    RETURN_RATE_STRS numeric(16,2),
    RETURN_RATE_ECOM numeric(16,2),
    CROSS_CHANNEL_RET_RATE numeric(16,2),
    ORDER_MIN int,
    ORDER_MULTIPLE int,
    LEAD_TIME_DEFAULT int,
    irw_debut_offset int
);


CREATE TABLE public.deleteme_failed_items_20250328
(
    product varchar(500)
);


CREATE TABLE public.deleteme_failed_items_20250328_with_missing_size_attr
(
    member_id varchar(500),
    stylecolor varchar(500),
    ITEM varchar(500),
    ITEM_DIFF_2 varchar(500),
    ITEM_DIFF_3 varchar(500),
    STYLECOLORSIZE_CREATE_DATE varchar(500),
    SIZE_ATTR_ID varchar(500)
);


CREATE TABLE public.TRD_REJ_SPECSTYLECOLORIMAGES
(
    VPN_COLOR varchar(500),
    JPG varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.deleteme_trd_d_product_20250422
(
    id varchar(200),
    client_id varchar(200),
    name varchar(200),
    description varchar(200),
    levelid varchar(400),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_IN_ACT_DAILYPORECEIPTS
(
    PO_ID varchar(500),
    SKU_ID varchar(500),
    FLOW_ID varchar(500),
    NDC_WEEK varchar(500),
    ACTUAL_RECEIPT_DATE varchar(500),
    QTY numeric(16,4)
);


CREATE TABLE public.TRD_REJ_ACT_DAILYPORECEIPTS
(
    PO_ID varchar(500),
    SKU_ID varchar(500),
    FLOW_ID varchar(500),
    NDC_WEEK varchar(500),
    ACTUAL_RECEIPT_DATE varchar(500),
    QTY numeric(16,4),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.TRD_REJ_SPECSTYLEATTRIBUTES
(
    VPN_VSN varchar(500),
    VPN_DESCRIPTION varchar(500),
    DEPT_ID varchar(500),
    CLASS_ID varchar(500),
    SUBCLASS_ID varchar(500),
    TICKET_TYPE varchar(500),
    KNIT_OR_WOVEN varchar(500),
    SLEEVE_LENGTH varchar(500),
    LEG_OPENING varchar(500),
    BRAND varchar(500),
    LICENSE_VS_NON_LICENSED varchar(500),
    HAZMAT_CODE varchar(500),
    PROP_65_WARNING varchar(500),
    MATERIAL_CONTENT varchar(500),
    DWRISE varchar(500),
    LENGTH varchar(500),
    NECKLINE varchar(500),
    TOESHAPE varchar(500),
    HEEL_HEIGHT varchar(500),
    BOTTOM_LENGTH varchar(500),
    v_360_SMOOTHING varchar(500),
    KNIT_FIT varchar(500),
    DESIGN_STYLE_STATUS varchar(500),
    SIZE_RANGE varchar(500),
    SPEC_STYLE_OPEN1 varchar(500),
    SPEC_STYLE_OPEN2 varchar(500),
    SPEC_STYLE_OPEN3 varchar(500),
    SPEC_STYLE_OPEN4 varchar(500),
    SPEC_STYLE_OPEN5 varchar(500),
    SPEC_STYLE_OPEN6 varchar(500),
    SPEC_STYLE_OPEN7 varchar(500),
    SPEC_STYLE_OPEN8 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.trd_p_dc_adj_stylecolor_test
(
    stylecolor varchar(500),
    store varchar(9),
    WEEK_ID varchar(511),
    ON_ORDER_V numeric(22,4),
    ON_ORDER_U numeric(22,4),
    ON_ORDER_C numeric(22,4),
    ON_ORDER_V_ECOM numeric(22,4),
    ON_ORDER_U_ECOM numeric(22,4),
    ON_ORDER_C_ECOM numeric(22,4),
    adj_cost numeric(20,2)
);


CREATE TABLE public.trd_p_dc_adj_existing_test
(
    product varchar(500),
    location varchar(500),
    "time" varchar(500),
    dc_publish float,
    is_locked float,
    dc_uservrp float,
    dc_lockedqty float,
    dc_useradj float,
    dc_onorder float,
    dc_finrev float,
    dc_validwk float,
    dc_finalqty float,
    dc_adjcost float,
    const_y_n float,
    sbkt float,
    dc_isedited float,
    dc_syscost float,
    dc_lndcst float,
    dc_sysvrp float,
    dc_sc_useradj float,
    dc_sc_finrev float,
    po_indicator varchar(500),
    po_shipmode varchar(500),
    air_trigger varchar(500),
    cut varchar(500),
    published_at timestamp(0),
    is_prepublished float,
    prepublished_at timestamp(0),
    last_prepublished float,
    po_arr varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int,
    dc_useradj_ecom float,
    dc_onorder_ecom float,
    dc_finrev_ecom float,
    dc_publish_ecom float,
    po_indicator_ecom varchar(500),
    po_shipmode_ecom varchar(500),
    air_trigger_ecom varchar(500),
    cut_ecom varchar(500),
    published_at_ecom timestamp,
    is_prepublished_ecom float,
    prepublished_at_ecom timestamp,
    last_prepublished_ecom float,
    reason_code varchar(500),
    reason_code_ecom varchar(500),
    pack_ind_flag varchar(500),
    pack_ind_flag_ecom varchar(500),
    show_in_pack varchar(500),
    show_in_pack_ecom varchar(500),
    prepack_pct float,
    prepack_pct_ecom float,
    default_fringe_indicator varchar(500),
    default_fringe_indicator_ecom varchar(500),
    email_to varchar(500)
);


CREATE TABLE public.trd_p_onorder_by_po_tbl_20250722
(
    sku varchar(500),
    parent_id varchar(500),
    location_id varchar(500),
    flow_id varchar(500),
    week_id varchar(511),
    price_status varchar(2),
    ndc_date varchar(500),
    start_ship_date varchar(500),
    po_cancel_date varchar(500),
    po_id varchar(500),
    total_units numeric(16,4),
    total_cost numeric(16,4),
    total_retail numeric(16,4),
    p_nbr_packs varchar(500),
    p_pack_id varchar(500),
    p_qty_per_pack varchar(500),
    p_po_type varchar(500),
    p_vendor_nbr varchar(500),
    p_po_vendor_nbr varchar(500),
    p_vendor_desc varchar(500),
    po_ln_seq_num varchar(500),
    eventdate date,
    updated_at timestamp
);


CREATE TABLE public.trd_p_onorder_tbl_20250722
(
    product varchar(500),
    stylecolor varchar(500),
    location varchar(500),
    prodlife varchar(2),
    cluster varchar(2),
    on_order_r numeric(16,4),
    on_order_u numeric(16,4),
    on_order_c numeric(16,4),
    on_order_r_4wk int,
    on_order_u_4wk int,
    on_order_c_4wk int,
    on_order_r_13wk int,
    on_order_u_13wk int,
    on_order_c_13wk int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_p_onorder_by_po_tbl_20250720
(
    sku varchar(500),
    parent_id varchar(500),
    location_id varchar(500),
    flow_id varchar(500),
    week_id varchar(511),
    price_status varchar(2),
    ndc_date varchar(500),
    start_ship_date varchar(500),
    po_cancel_date varchar(500),
    po_id varchar(500),
    total_units numeric(16,4),
    total_cost numeric(16,4),
    total_retail numeric(16,4),
    p_nbr_packs varchar(500),
    p_pack_id varchar(500),
    p_qty_per_pack varchar(500),
    p_po_type varchar(500),
    p_vendor_nbr varchar(500),
    p_po_vendor_nbr varchar(500),
    p_vendor_desc varchar(500),
    po_ln_seq_num varchar(500),
    eventdate date,
    updated_at timestamp
);


CREATE TABLE public.trd_p_onorder_tbl_20250720
(
    product varchar(500),
    stylecolor varchar(500),
    location varchar(500),
    prodlife varchar(2),
    cluster varchar(2),
    on_order_r numeric(16,4),
    on_order_u numeric(16,4),
    on_order_c numeric(16,4),
    on_order_r_4wk int,
    on_order_u_4wk int,
    on_order_c_4wk int,
    on_order_r_13wk int,
    on_order_u_13wk int,
    on_order_c_13wk int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_IN_ACT_ONORDER_20250720
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    FLOW_ID varchar(500),
    WEEK_ID varchar(500),
    PRICE_STATUS varchar(500),
    NDC_DATE varchar(500),
    START_SHIP_DATE varchar(500),
    PO_CANCEL_DATE varchar(500),
    PO_ID varchar(500),
    TOTAL_UNITS numeric(16,4),
    TOTAL_COST numeric(16,4),
    TOTAL_RETAIL numeric(16,4),
    P_NBR_PACKS varchar(500),
    P_PACK_ID varchar(500),
    P_QTY_PER_PACK varchar(500),
    P_PO_TYPE varchar(500),
    P_VENDOR_NBR varchar(500),
    P_PO_VENDOR_NBR varchar(500),
    P_VENDOR_DESC varchar(500),
    PO_LN_SEQ_NUM varchar(500)
);


CREATE TABLE public.TRD_IN_ACT_DAILYPORECEIPTS_20250720
(
    PO_ID varchar(500),
    SKU_ID varchar(500),
    FLOW_ID varchar(500),
    NDC_WEEK varchar(500),
    ACTUAL_RECEIPT_DATE varchar(500),
    QTY numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_ONORDER_20250721
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    FLOW_ID varchar(500),
    WEEK_ID varchar(500),
    PRICE_STATUS varchar(500),
    NDC_DATE varchar(500),
    START_SHIP_DATE varchar(500),
    PO_CANCEL_DATE varchar(500),
    PO_ID varchar(500),
    TOTAL_UNITS numeric(16,4),
    TOTAL_COST numeric(16,4),
    TOTAL_RETAIL numeric(16,4),
    P_NBR_PACKS varchar(500),
    P_PACK_ID varchar(500),
    P_QTY_PER_PACK varchar(500),
    P_PO_TYPE varchar(500),
    P_VENDOR_NBR varchar(500),
    P_PO_VENDOR_NBR varchar(500),
    P_VENDOR_DESC varchar(500),
    PO_LN_SEQ_NUM varchar(500)
);


CREATE TABLE public.TRD_IN_ACT_DAILYPORECEIPTS_20250721
(
    PO_ID varchar(500),
    SKU_ID varchar(500),
    FLOW_ID varchar(500),
    NDC_WEEK varchar(500),
    ACTUAL_RECEIPT_DATE varchar(500),
    QTY numeric(16,4)
);


CREATE TABLE public.deleteme_update_images_JPG_202050828
(
    product varchar(500),
    JPG varchar(500)
);


CREATE TABLE public.deleteme_update_images_products_202050828
(
    product varchar(500)
);


CREATE TABLE public.deleteme_update_images_URL_202050828
(
    product varchar(500),
    URL varchar(500)
);


CREATE TABLE public.deleteme_update_images_step1_202050828
(
    product varchar(100),
    member_id varchar(500),
    URL varchar(500),
    FINAL_IMG varchar(500)
);


CREATE TABLE public.trd_ma_styleattributes_existing_bk_20250926
(
    product varchar(500),
    sty_knit_or_woven varchar(500),
    sty_fabrication varchar(500),
    sty_sleeve_length varchar(500),
    sty_leg_opening varchar(500),
    sty_brand varchar(500),
    sty_body_style_silhouette varchar(500),
    sty_occasion_usage varchar(500),
    sty_detail varchar(500),
    sty_finish_style varchar(500),
    sty_private_label varchar(500),
    sty_license varchar(500),
    sty_license_vs_non_licensed varchar(500),
    sty_hazmat_code varchar(500),
    sty_prop_65_warning varchar(500),
    sty_material_content varchar(500),
    sty_item_type varchar(500),
    sty_dwrise varchar(500),
    sty_length varchar(500),
    sty_neckline varchar(500),
    sty_toeshape varchar(500),
    sty_heel_height varchar(500),
    sty_bottom_length varchar(500),
    sty_v_360_smoothing varchar(500),
    sty_franchise varchar(500),
    sty_key_item varchar(500),
    sty_single_vs_multi_pack varchar(500),
    sty_ticket_type varchar(500),
    sty_vpn varchar(500),
    sty_size_range varchar(500),
    ccstylecreatedate varchar(500),
    sty_is_locked varchar(500),
    sty_s5_adopted varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int,
    plm_size_range varchar(500),
    sty_knit_fit varchar(500),
    sty_patterned_after varchar(500)
);


CREATE TABLE public.trd_d_time_bk_20250928
(
    id varchar(50),
    name varchar(50),
    description varchar(50),
    levelid varchar(50),
    prev varchar(50),
    next varchar(50),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.deleteme_trd_h_prodstd_existing
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_h_prodstd_existing_testing_sup3311
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_ma_stylecolorchannelattributes_existing_bkp
(
    product varchar(500),
    location varchar(500),
    dbt_wk varchar(500),
    relaunchweek varchar(500),
    erlstmkdnwk varchar(500),
    exitdate varchar(500),
    initrcptwk varchar(500),
    too int,
    mkdnwks int,
    last_inv_wk varchar(500),
    lstfpwk varchar(500),
    last_rcpt_wk varchar(500),
    lastdcorder varchar(500),
    act_initrcptwk varchar(500),
    act_dbt_wk varchar(500),
    irw_indx int,
    dbtwk_indx int,
    relaunchwk_indx int,
    mdstart_indx int,
    lastdcorder_indx int,
    exitdate_indx int,
    preview_wks int,
    preview_qty int,
    plannedselldnwk varchar(500),
    ccmdstrategy varchar(500),
    slsrnk_store float DEFAULT 3,
    slsrnk_ecom float DEFAULT 3,
    validsizes varchar(5000),
    cc_validsizes_store varchar(5000),
    cc_validsizes_ecom varchar(5000),
    ccrangecode varchar(500),
    cc_presmin int,
    cc_presmin_weeks int,
    cc_rcptint int,
    cc_return_u_pct_store float,
    cc_return_u_pct_ecom float,
    cc_return_u_pct_cross float,
    cc_ordermultiple int,
    cc_ordermin int,
    cc_buy_aps_letter varchar(500),
    ccticketpricechannel float DEFAULT 0.01,
    ccticketpricechannel_override float,
    cc_imupct float DEFAULT 0.0,
    cc_discount_pct float DEFAULT 0.0,
    cc_existingwac float DEFAULT 0.0,
    cc_systemcost float DEFAULT 0.0,
    cc_plan_cost float DEFAULT 0.0,
    ssnprf varchar(500),
    adjaps_store float,
    adjaps_ecom float,
    smoothing_strategy varchar(500),
    in_season_flag varchar(500) DEFAULT 'No',
    auto_rollforward boolean DEFAULT false,
    irr_mode varchar(500) DEFAULT 'Normal',
    plan_current varchar(500),
    lock_agg_edit varchar(500),
    cc_lead_time int,
    cc_service_level float,
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    cc_store_min_multiple int,
    planned_sell_down_week varchar(500),
    cc_selected_clusters varchar(5000),
    cc_cluster_group varchar(500),
    keep_initial_range_plan int,
    cc_sizeelig_rangecode varchar(500),
    cc_presmin_stylecolor int,
    cc_presmin_weeks_stylecolor int,
    cc_final_cost float,
    cc_discount_pct_store float DEFAULT 0.0,
    cc_discount_pct_ecom float DEFAULT 0.0,
    irw_debut_offset int,
    cc_service_level_ecom float,
    cc_first_publish_date timestamp,
    cc_first_publish_snapshot_op int,
    sclr_alloc_max float,
    sclr_presmin float,
    sclr_alloc_min float,
    sclr_presmin_weeks float,
    sclr_tgt_fwoc float DEFAULT 4,
    sclr_fringe_flag float DEFAULT 1,
    act_slsrnk_store float,
    act_aps_store float,
    act_aps_mult_adj_store float,
    act_slsrnk_ecom float,
    act_aps_ecom float,
    act_aps_mult_adj_ecom float,
    use_act_aps_or_act_rank varchar(500) DEFAULT 'Copy Rating',
    use_valid_sizes_from varchar(500) DEFAULT 'Defaults – All Valid Sizes',
    apply_size_mins_to varchar(500) DEFAULT 'Core Sizes Only',
    cc_addoff_store float,
    cc_addoff_ecom float,
    irw_floorset varchar(500),
    irw_superset varchar(500),
    irw_floorset_display varchar(500),
    irw_superset_display varchar(500),
    irw_floorset_id varchar(500),
    cc_size_eligibility_profile varchar(500),
    cloned_at timestamp
);


CREATE TABLE public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES
(
    VPN_VSN varchar(500),
    VPN_DESCRIPTION varchar(500),
    VPN_COLOR varchar(500),
    VPN_COLOR_DESCRIPTION varchar(500),
    DEPT_ID varchar(500),
    CLASS_ID varchar(500),
    SUBCLASS_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    DW_COLOR_FAMILY varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST float,
    FREIGHT varchar(500),
    AGENT_FEE varchar(500),
    DUTY varchar(500),
    PORT varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    FACTORY varchar(500),
    PO_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    DESIGN_STYLECOLOR_STATUS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SUPP_COST float,
    ART_CODE varchar(500),
    MATERIAL_CONTENT varchar(500),
    DIVISION varchar(500),
    GROUP_ID varchar(500),
    DEVELOPMENT_SEASON varchar(500),
    DELIVERY_SEASON varchar(500),
    PO_DUE_DATE varchar(500),
    PD_NDC_WEEK varchar(500),
    ADDITIONAL_TARIFF varchar(500),
    DESIGN_NOTES varchar(500),
    PD_NOTES varchar(500),
    COMPLIANCE_NOTES varchar(500),
    SPEC_STYLECOLOR_OPEN1 varchar(500),
    SPEC_STYLECOLOR_OPEN2 varchar(500),
    SPEC_STYLECOLOR_OPEN3 varchar(500),
    SPEC_STYLECOLOR_OPEN4 varchar(500),
    SPEC_STYLECOLOR_OPEN5 varchar(500),
    SPEC_STYLECOLOR_OPEN6 varchar(500),
    SPEC_STYLECOLOR_OPEN7 varchar(500),
    SPEC_STYLECOLOR_OPEN8 varchar(500),
    SPEC_STYLECOLOR_OPEN9 varchar(500),
    SPEC_STYLECOLOR_OPEN10 varchar(500),
    SPEC_STYLECOLOR_OPEN11 varchar(500),
    SPEC_STYLECOLOR_OPEN12 varchar(500)
);


CREATE TABLE public.TRD_REJ_SPECSTYLECOLORATTRIBUTES
(
    VPN_VSN varchar(500),
    VPN_DESCRIPTION varchar(500),
    VPN_COLOR varchar(500),
    VPN_COLOR_DESCRIPTION varchar(500),
    DEPT_ID varchar(500),
    CLASS_ID varchar(500),
    SUBCLASS_ID varchar(500),
    ITEM_DIFF_1 varchar(500),
    EXPORT_HTS varchar(500),
    COMMERCIAL_INVOICE_DESCRIPTION varchar(500),
    DW_COLOR_FAMILY varchar(500),
    ORIGIN_COUNTRY_ID varchar(500),
    COUNTRY_OF_SOURCING varchar(500),
    COUNTRY_OF_MANUFACTURING varchar(500),
    UNIT_COST float,
    FREIGHT varchar(500),
    AGENT_FEE varchar(500),
    DUTY varchar(500),
    PORT varchar(500),
    SHIP_METHOD varchar(500),
    LADING_PORT varchar(500),
    HTS varchar(500),
    FACTORY varchar(500),
    PO_SUPPLIER varchar(500),
    SUB_BRAND varchar(500),
    DESIGN_STYLECOLOR_STATUS varchar(500),
    PRIMARY_SUPPLIER varchar(500),
    SUPP_COST float,
    ART_CODE varchar(500),
    MATERIAL_CONTENT varchar(500),
    DIVISION varchar(500),
    GROUP_ID varchar(500),
    DEVELOPMENT_SEASON varchar(500),
    DELIVERY_SEASON varchar(500),
    PO_DUE_DATE varchar(500),
    PD_NDC_WEEK varchar(500),
    ADDITIONAL_TARIFF varchar(500),
    DESIGN_NOTES varchar(500),
    PD_NOTES varchar(500),
    COMPILANCE_NOTES varchar(500),
    SPEC_STYLECOLOR_OPEN1 varchar(500),
    SPEC_STYLECOLOR_OPEN2 varchar(500),
    SPEC_STYLECOLOR_OPEN3 varchar(500),
    SPEC_STYLECOLOR_OPEN4 varchar(500),
    SPEC_STYLECOLOR_OPEN5 varchar(500),
    SPEC_STYLECOLOR_OPEN6 varchar(500),
    SPEC_STYLECOLOR_OPEN7 varchar(500),
    SPEC_STYLECOLOR_OPEN8 varchar(500),
    SPEC_STYLECOLOR_OPEN9 varchar(500),
    SPEC_STYLECOLOR_OPEN10 varchar(500),
    SPEC_STYLECOLOR_OPEN11 varchar(500),
    SPEC_STYLECOLOR_OPEN12 varchar(500),
    REJECT_REASON varchar(200)
);


CREATE TABLE public.deleteme_TRD_IN_BUS_SIZERANGE_MAPPING
(
    size_range varchar(500),
    size_id varchar(500),
    size_desc varchar(500),
    sort_order int,
    parent_size varchar(500),
    fringe_size_ind int
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_20250202_bk
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_20250202_bk
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.trd_ma_sizeattributes_existing_bk_sup_3663
(
    product varchar(200),
    parent_id varchar(200),
    item_diff_2 varchar(200),
    item_diff_3 varchar(200),
    sizeattribute varchar(500),
    isvalid int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int,
    ccctylecolorsizecreatedate varchar(500)
);


CREATE TABLE public.trd_d_product_existing_bk_sup_3663
(
    id varchar(200),
    client_id varchar(200),
    name varchar(500),
    description varchar(500),
    levelid varchar(50),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_h_prodstd_existing_bk_sup_3663
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.duplicate_sizes_sup3663
(
    product varchar(200),
    parent_id varchar(200),
    item_diff_2 varchar(200),
    item_diff_3 varchar(200),
    sizeattribute varchar(500),
    isvalid int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int,
    ccctylecolorsizecreatedate varchar(500),
    status varchar(100)
);


CREATE TABLE public.trd_d_product_mock_sup3663
(
    id varchar(200),
    client_id varchar(200),
    name varchar(200),
    description varchar(200)
);


CREATE TABLE public.delete_me
(
    product varchar(500),
    class varchar(200),
    location varchar(200),
    week varchar(50),
    floorset varchar(80),
    str_grade varchar(50),
    eventdate date
);


CREATE TABLE public.NRF_ANALYTICS_EVENT_MAPPING
(
    Event varchar(100),
    Week varchar(100),
    WeekIndx int,
    MonthIndx int,
    year int
);


CREATE TABLE public.NRF_WEEK_ATTRIBUTES
(
    "time" varchar(100),
    start_date varchar(100),
    end_date varchar(100)
);


CREATE TABLE public.NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE
(
    "time" varchar(100),
    start_date varchar(100),
    end_date varchar(100),
    trd_time varchar(200)
);


CREATE TABLE public.NRF_ANALYTICS_EVENT_MAPPING_trd_TIME
(
    Event varchar(100),
    Week varchar(100),
    WeekIndx int,
    MonthIndx int,
    year int,
    trd_time varchar(200),
    trd_month varchar(200),
    trd_WeekIndx int,
    trd_MonthIndx int
);


CREATE TABLE public.trd_ANALYTICS_EVENT_MAPPING
(
    Event varchar(100),
    "time" varchar(200),
    month varchar(200),
    WeekIndx int,
    MonthIndx int
);


CREATE TABLE public.MONTH_MAX_WEEK
(
    month varchar(50),
    "time" varchar(50)
);


CREATE TABLE public.MAX_ELAPSED
(
    max_time varchar(50)
);


CREATE TABLE public.MIN_START_FROM_ELAPSED
(
    min_start varchar(50)
);


CREATE TABLE public.MORPHED_TIME_MAP
(
    c_week varchar(50),
    c_month varchar(50),
    c_qtr varchar(50),
    c_season varchar(50),
    c_year varchar(50),
    rn int,
    s5_week varchar(100),
    s5_month varchar(100),
    s5_qtr varchar(100),
    s5_season varchar(100),
    s5_year varchar(100)
);


CREATE TABLE public.MORPHED_TIME_MAP_HISTORY
(
    c_week varchar(50),
    c_month varchar(50),
    c_qtr varchar(50),
    c_season varchar(50),
    c_year varchar(50),
    rn int,
    s5_week varchar(100),
    s5_month varchar(100),
    s5_qtr varchar(100),
    s5_season varchar(100),
    s5_year varchar(100)
);


CREATE TABLE public.MORPHED_TIME_MAP_FUTURE
(
    c_week varchar(50),
    c_month varchar(50),
    c_qtr varchar(50),
    c_season varchar(50),
    c_year varchar(50),
    rn int,
    s5_week varchar(100),
    s5_month varchar(100),
    s5_qtr varchar(100),
    s5_season varchar(100),
    s5_year varchar(100)
);


CREATE TABLE public.S5_ANALYTICS_MORPHED_TIME
(
    rn int,
    s5_week varchar(100),
    s5_month varchar(100),
    s5_qtr varchar(100),
    s5_season varchar(100),
    s5_year varchar(100)
);


CREATE TABLE public.MORPH_EVENT_MAPPING
(
    Event varchar(100),
    c_week varchar(200),
    c_month varchar(200),
    c_windx int,
    c_mindx int,
    "time" varchar(100),
    month varchar(100),
    windx int,
    mindx int,
    year varchar(100)
);


CREATE TABLE public.trd_d_product_existing_20260517
(
    id varchar(200),
    client_id varchar(200),
    name varchar(500),
    description varchar(500),
    levelid varchar(50),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_h_prodstd_existing_20260517
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_ma_sizeattributes_existing_20260517
(
    product varchar(200),
    parent_id varchar(200),
    item_diff_2 varchar(200),
    item_diff_3 varchar(200),
    sizeattribute varchar(500),
    isvalid int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int,
    ccctylecolorsizecreatedate varchar(500)
);


CREATE TABLE public.TRD_REF_S5_CLIENT_ID_MAPPING_20260517
(
    s5_id varchar(100),
    client_erp_id varchar(100),
    levelid varchar(20)
);


CREATE TABLE public.TRD_REF_CC_SKU_MAPPING_20260517
(
    STYLECOLORSIZE varchar(500),
    STYLECOLOR varchar(500),
    STYLE varchar(500),
    SUBCLASS varchar(500),
    CLASS varchar(500),
    DEPARTMENT varchar(500),
    "GROUP" varchar(500),
    DIVISION varchar(500),
    TOTAL_BRAND varchar(500)
);


CREATE TABLE public.trd_d_product_existing_20260517_2
(
    id varchar(200),
    client_id varchar(200),
    name varchar(500),
    description varchar(500),
    levelid varchar(50),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_h_prodstd_existing_20260517_2
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_BK_MON
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_BK_MON
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    COMP_STATUS varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    SHIPPED_SALES_R_CSP numeric(16,4),
    SHIPPED_SALES_R numeric(16,4),
    SHIPPED_SALES_U numeric(16,4),
    SHIPPED_SALES_C numeric(16,4),
    RETURN_SALES_R numeric(16,4),
    RETURN_SALES_U numeric(16,4),
    RETURN_SALES_C numeric(16,4),
    RETURN_SALES_R_CSP numeric(16,4),
    BOPIS_SALES_R numeric(16,4),
    BOPIS_SALES_U numeric(16,4),
    BOPIS_SALES_C numeric(16,4),
    SFS_SALES_R numeric(16,4),
    SFS_SALES_U numeric(16,4),
    SFS_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK
(
    TRANSACTION_ID varchar(500),
    MEMBER_ID varchar(500),
    DAY_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    DEMAND_SALES_R_CSP numeric(16,4),
    DEMAND_SALES_R numeric(16,4),
    DEMAND_SALES_U numeric(16,4),
    DEMAND_SALES_C numeric(16,4)
);


CREATE TABLE public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    PRICE_STATUS varchar(500),
    COMP_STATUS varchar(500),
    "TIME" varchar(500),
    EOH_R numeric(16,4),
    EOH_U numeric(16,4),
    EOH_C numeric(16,4),
    EOP_INTRANSIT_R numeric(16,4),
    EOP_INTRANSIT_U numeric(16,4),
    EOP_INTRANSIT_C numeric(16,4),
    AVG_UNIT_COST numeric(16,4),
    ORIGINAL_TICKET_PRICE numeric(16,4),
    CURRENT_TICKET_PRICE numeric(16,4),
    PERM_MD_R numeric(16,4),
    PERM_MD_C numeric(16,4),
    PERM_MD_U numeric(16,4),
    PERM_MD_R_CSP numeric(16,4)
);


CREATE TABLE public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET
(
    LOCATION_ID varchar(200),
    FLOORSET_ID varchar(200),
    CLASS_ID varchar(200),
    TIER varchar(50)
);


CREATE TABLE public.TRD_IN_BUS_SIZERANGE_MAPPING
(
    size_range varchar(500),
    size_id varchar(500),
    size_desc varchar(500),
    sort_order int,
    parent_size varchar(500),
    fringe_size_ind int
);


CREATE TABLE public.TRD_IN_BUS_SIZE_ELIGIBILITY
(
    department varchar(500),
    size_range_id varchar(500),
    size_eligibility_default_display_name varchar(500),
    size_member_id varchar(500),
    store_ineligible int,
    web_ineligible int,
    is_default int
);


CREATE TABLE public.TRD_IN_BUS_CAD_TICKET_PRICE
(
    product varchar(500),
    usd_ticket_price numeric(16,2),
    cad_ticket_price numeric(16,2),
    price_band varchar(500)
);


CREATE TABLE public.TRD_IN_BUS_CORP_DISCOUNT
(
    department varchar(200),
    product varchar(200),
    "time" varchar(200),
    corpaddoff numeric(16,4),
    corpexcl_ecom numeric(16,4),
    corpexcl_stores numeric(16,4)
);


CREATE TABLE public.TRD_IN_BUS_DEPARTMENT_DEFAULTS
(
    product varchar(200),
    default_presmin int,
    default_presmin_weeks int,
    default_ccrcptint int,
    default_retpct_str numeric(16,4),
    default_retpct_ecom numeric(16,4),
    default_crosschannel_retpct_ecom numeric(16,4),
    default_ccordermultiple_uom int,
    default_ccmdstrategy varchar(200),
    default_lead_time int,
    default_ccdiscountpct numeric(16,4)
);


CREATE TABLE public.TRD_IN_BUS_DEFAULT_DISCOUNT_PCT
(
    DEPT_ID varchar(200),
    DEFAULT_DISCOUNT numeric(16,4)
);


CREATE TABLE public.TRD_IN_BUS_PRICE_BAND_LOOKUP
(
    PRICE_BAND_VALUE varchar(200),
    SUBCLASS varchar(200),
    CEILING_VALUE varchar(200)
);


CREATE TABLE public.TRD_IN_BUS_HOLIDAY_SHIFTS
(
    "time" varchar(200),
    lytime varchar(200),
    llytime varchar(200),
    holiday_name varchar(500)
);


CREATE TABLE public.TRD_IN_BUS_MD_STRATEGY
(
    department varchar(200),
    mdstrategy varchar(200),
    seq int,
    weeks int,
    md numeric(16,4)
);


CREATE TABLE public.TRD_IN_BUS_SSG
(
    SSG_ID varchar(200),
    LOCATION varchar(200),
    SSG_NAME varchar(200),
    SSG_STORE varchar(5000)
);


CREATE TABLE public.TRD_REF_LOC_MEMBERMASTER
(
    member_id varchar(200),
    loc_level varchar(200)
);


CREATE TABLE public.trd_d_location
(
    id varchar(200),
    name varchar(200),
    description varchar(200),
    levelid varchar(200),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_h_locstd
(
    id varchar(500),
    ancestor0 varchar(500),
    ancestor1 varchar(500),
    ancestor2 varchar(500),
    ancestor3 varchar(500),
    ancestor4 varchar(500),
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_storeattributes
(
    store varchar(200),
    store_name varchar(200),
    mall_type varchar(200),
    geo_region varchar(200),
    city varchar(200),
    zipcode varchar(200),
    corp_rank varchar(200),
    dc_or_store varchar(200),
    selling_channel varchar(200),
    casual_3_space varchar(200),
    clearance_store varchar(200),
    store_banner varchar(200),
    store_climate varchar(200),
    capacity varchar(200),
    capacity_volume varchar(200),
    hazmat varchar(200)
);


CREATE TABLE public.trd_ma_storeattributes
(
    location varchar(200),
    strname varchar(200),
    str_store_peer varchar(500),
    str_mall_type varchar(200),
    str_volume_range varchar(500),
    str_active_sales varchar(500),
    str_active_alloc varchar(500),
    str_active_bopis varchar(500),
    str_active_sfs varchar(500),
    str_competition_1 varchar(500),
    str_competition_2 varchar(500),
    str_competition_3 varchar(500),
    str_date_opened varchar(500),
    str_date_closed varchar(500),
    str_date_remodeled varchar(500),
    str_dc_current varchar(500),
    str_dc_final varchar(500),
    str_dc_transit varchar(500),
    str_fxt_cashwrap_type varchar(500),
    str_fxt_casual_3 varchar(200),
    str_fxt_panty_tables varchar(500),
    str_fxt_bra_cabinets varchar(500),
    str_fxt_open_1 varchar(500),
    str_fxt_open_2 varchar(500),
    str_fxt_open_3 varchar(500),
    str_fxt_open_4 varchar(500),
    str_fxt_open_5 varchar(500),
    str_fxt_open_6 varchar(500),
    str_fxt_open_7 varchar(500),
    str_fxt_open_8 varchar(500),
    str_fxt_open_9 varchar(500),
    str_fxt_open_10 varchar(500),
    str_fxt_open_11 varchar(500),
    str_fxt_open_12 varchar(500),
    str_fxt_open_13 varchar(500),
    str_fxt_open_14 varchar(500),
    str_fxt_open_15 varchar(500),
    str_geo_timezone varchar(500),
    str_geo_region varchar(200),
    str_mkt_border varchar(500),
    str_mkt_coastal varchar(500),
    str_mkt_urban varchar(500),
    str_mkt_tourist varchar(500),
    str_mkt_college_1 varchar(500),
    str_mkt_college_2 varchar(500),
    str_mkt_sports_baseball varchar(500),
    str_mkt_sports_football varchar(500),
    str_mkt_sports_basketball varchar(500),
    str_mkt_sports_hockey varchar(500),
    str_size_1_ttl_str varchar(500),
    str_size_2_sls_flr varchar(500),
    str_size_3_merch_flr varchar(500),
    str_size_4_stk_rm varchar(500),
    str_size_5_oth varchar(500),
    str_size_6_offsite varchar(500),
    str_real_est_proforma varchar(500),
    str_real_est_rank varchar(500),
    str_corp_rank varchar(200),
    str_sp_vol_alpha varchar(500),
    str_sp_vol_proforma varchar(500),
    str_days_from_wh varchar(500),
    str_dc_or_store varchar(200),
    str_selling_channel varchar(200),
    str_store_banner varchar(200),
    str_store_climate varchar(200),
    str_hazmat varchar(200),
    str_capacity varchar(200),
    str_capacity_volume varchar(200),
    str_latitude varchar(500),
    str_longitude varchar(500),
    str_area_id varchar(500),
    str_loc_attr_1 varchar(500),
    str_loc_attr_2 varchar(500),
    str_loc_attr_3 varchar(500),
    str_loc_attr_4 varchar(500),
    str_loc_attr_5 varchar(500),
    str_loc_attr_6 varchar(500),
    str_loc_attr_7 varchar(500),
    str_loc_attr_8 varchar(500),
    str_loc_attr_9 varchar(500),
    str_loc_attr_10 varchar(500),
    str_loc_attr_11 varchar(500),
    str_loc_attr_12 varchar(500),
    str_loc_attr_13 varchar(500),
    str_loc_attr_14 varchar(500),
    str_loc_attr_15 varchar(500),
    str_city varchar(200),
    str_zipcode varchar(200),
    str_clearance_store varchar(200),
    district_name varchar(500),
    district_desc varchar(500),
    region_name varchar(500),
    region_desc varchar(500),
    area_name varchar(500),
    area_desc varchar(500),
    selling_channel_name varchar(500),
    selling_channel_desc varchar(500),
    channel_name varchar(500),
    channel_desc varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int,
    str_grade varchar(500)
);


CREATE TABLE public.trd_l_dclookup
(
    channel varchar(50),
    dc varchar(50),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('second', (now())::timestamp),
    created_by varchar(20) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('second', (now())::timestamp),
    updated_by varchar(20) DEFAULT 'system',
    record_state int DEFAULT 0
);


CREATE TABLE public.trd_stocking_locations_tbl
(
    stocking_location varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_d_time
(
    id varchar(50),
    name varchar(50),
    description varchar(50),
    levelid varchar(50),
    prev varchar(50),
    next varchar(50),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_h_timestd
(
    id varchar(50),
    ancestor0 varchar(50),
    ancestor1 varchar(50),
    ancestor2 varchar(50),
    ancestor3 varchar(50),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_h_timeflrset
(
    id varchar(50),
    ancestor0 varchar(50),
    ancestor1 varchar(50),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_ma_weekattributes
(
    "TIME" varchar(50),
    START_DATE varchar(50),
    END_DATE varchar(50),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.TRD_IN_TYLY_MAPPING
(
    "time" varchar(20),
    cctytime varchar(20)
);


CREATE TABLE public.trd_ma_dptflrsetattributes
(
    indx int,
    product varchar(200),
    "time" varchar(200),
    floorset_name varchar(200),
    dept_name varchar(200),
    superset_id varchar(200),
    superset_name varchar(200),
    initialrcptwk varchar(200),
    rcptstart varchar(200),
    rcptend varchar(200),
    slsstart varchar(200),
    slsend varchar(200),
    weeks_at_fp varchar(200),
    markdown_week varchar(200),
    exit_week varchar(200),
    ly_rcptstart varchar(200),
    ly_rcptend varchar(200),
    lyslsstart varchar(200),
    lyslsend varchar(200),
    ap_start varchar(200),
    ap_end varchar(200),
    planned_sell_down_week varchar(200),
    floorset_uda varchar(200),
    ly_floorset_uda varchar(200),
    default_slsrnk_store numeric(16,4),
    default_slsrnk_ecom numeric(16,4),
    default_store_vol_grade varchar(5000),
    default_store_climate varchar(5000),
    default_store_capacity varchar(5000),
    default_store_banner varchar(5000),
    default_store_geo_region varchar(5000),
    default_store_hazmat varchar(5000),
    irw_debut_offset int,
    default_presmin int,
    default_presmin_weeks int,
    default_ccrcptint int,
    default_retpct_str numeric(16,4),
    default_retpct_ecom numeric(16,4),
    default_crosschannel_retpct_ecom numeric(16,4),
    default_ccordermultiple_uom int,
    default_ccmdstrategy varchar(200),
    default_lead_time int,
    default_ccdiscountpct float,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    prepack_pct_default numeric(16,4),
    override_fringe_indicator varchar(50)
);


CREATE TABLE public.trd_time_attributes_tbl
(
    week varchar(200),
    month varchar(200),
    quarter varchar(200),
    season varchar(200),
    year varchar(200),
    cctytime varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_floorset_week_attributes_tbl
(
    floorset varchar(200),
    month varchar(50),
    week varchar(50),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.TRD_REF_TIME_BOH_EOH
(
    WEEK_ID varchar(200),
    DATE_ID varchar(200),
    PREV_WEEK_ID varchar(50),
    PREV_WEEK_LAST_DAY varchar(200),
    BOH_MULTIPLE int,
    EOH_MULTIPLE int
);


CREATE TABLE public.trd_d_prodlife
(
    id varchar(20),
    name varchar(20),
    description varchar(20),
    levelid varchar(20),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_h_prodlifestd
(
    id varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_prodlife_view_tbl
(
    merchcat varchar(20),
    prodlife varchar(20),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_d_cluster
(
    id varchar(200),
    name varchar(206),
    description varchar(206),
    levelid varchar(20),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_h_clusterstd
(
    id varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_cluster_view_tbl
(
    grade varchar(200),
    cluster varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_int_store_tier_dept_week
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50),
    cluster varchar(50)
);


CREATE TABLE public.trd_ref_store_tier_class_max_week
(
    class_id varchar(200),
    location_id varchar(200),
    max_week varchar(50),
    min_week varchar(50)
);


CREATE TABLE public.trd_ref_store_tier_possible_tier_weeks
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50)
);


CREATE TABLE public.temp_trd_int_store_tier_dept_week
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50),
    cluster varchar(50)
);


CREATE TABLE public.temp_trd_int_store_tier_dept_week_2
(
    location_id varchar(200),
    class_id varchar(200),
    week varchar(50),
    cluster varchar(50)
);


CREATE TABLE public.TRD_PERF_INTERN_ACTWEEK
(
    WEEK_ID varchar(511)
);


CREATE TABLE public.trd_serviceparams
(
    id varchar(50),
    type varchar(50),
    value varchar(50),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_ytd_qtd_mtd_mapping_tbl
(
    week varchar(50),
    month varchar(50),
    qtr varchar(50),
    season varchar(50),
    year varchar(50),
    ytd int,
    std int,
    qtd int,
    mtd int,
    lw int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_d_product_existing
(
    id varchar(200),
    client_id varchar(200),
    name varchar(500),
    description varchar(500),
    levelid varchar(50),
    indx int DEFAULT 1,
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0
);


CREATE TABLE public.trd_h_prodstd_existing
(
    id varchar(200),
    ancestor0 varchar(200),
    ancestor1 varchar(200),
    ancestor2 varchar(200),
    ancestor3 varchar(200),
    ancestor4 varchar(200),
    ancestor5 varchar(200),
    ancestor6 varchar(200),
    ancestor7 varchar(200),
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0
);


CREATE TABLE public.trd_ma_sizeattributes_existing
(
    product varchar(200),
    parent_id varchar(200),
    item_diff_2 varchar(200),
    item_diff_3 varchar(200),
    sizeattribute varchar(500) NOT NULL,
    isvalid int DEFAULT 1,
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    ccctylecolorsizecreatedate varchar(500)
);


CREATE TABLE public.trd_ma_styleattributes_existing
(
    product varchar(500),
    sty_knit_or_woven varchar(500),
    sty_fabrication varchar(500),
    sty_sleeve_length varchar(500),
    sty_leg_opening varchar(500),
    sty_brand varchar(500),
    sty_body_style_silhouette varchar(500),
    sty_occasion_usage varchar(500),
    sty_detail varchar(500),
    sty_finish_style varchar(500),
    sty_private_label varchar(500),
    sty_license varchar(500),
    sty_license_vs_non_licensed varchar(500),
    sty_hazmat_code varchar(500),
    sty_prop_65_warning varchar(500),
    sty_material_content varchar(500),
    sty_item_type varchar(500),
    sty_dwrise varchar(500),
    sty_length varchar(500),
    sty_neckline varchar(500),
    sty_toeshape varchar(500),
    sty_heel_height varchar(500),
    sty_bottom_length varchar(500),
    sty_v_360_smoothing varchar(500),
    sty_franchise varchar(500),
    sty_key_item varchar(500),
    sty_single_vs_multi_pack varchar(500),
    sty_ticket_type varchar(500),
    sty_vpn varchar(500),
    sty_size_range varchar(500),
    ccstylecreatedate varchar(500),
    sty_is_locked varchar(500),
    sty_s5_adopted varchar(500),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    plm_size_range varchar(500),
    sty_knit_fit varchar(500),
    sty_patterned_after varchar(500),
    sty_vpn_desc varchar(500),
    sty_num_clones_s5 float,
    sty_num_times_cloned_s5 float
);


CREATE TABLE public.trd_ma_stylecolorattributes_existing
(
    product varchar(500),
    cc_item_diff_1 varchar(500),
    cc_unit_retail float,
    cc_unit_retail_cad float,
    cc_pattern varchar(500),
    cc_graphic varchar(500),
    cc_fashion_basic varchar(500),
    cc_holiday varchar(500),
    cc_property_type varchar(500),
    cc_internet_exclusive varchar(500),
    cc_web_color_discription varchar(500),
    cc_export_hts varchar(500),
    cc_commercial_invoice_description varchar(500),
    cc_season_code varchar(500),
    cc_dtr varchar(500),
    cc_dw_color_family varchar(500),
    cc_channel_reorder varchar(500),
    cc_ticket_season_code varchar(500),
    cc_sub_programs varchar(500),
    cc_music_genre varchar(500),
    cc_clearance_str_product varchar(500),
    cc_po_supplier varchar(500),
    cc_origin_country_id varchar(500),
    cc_country_of_sourcing varchar(500),
    cc_country_of_manufacturing varchar(500),
    cc_unit_cost float,
    cc_freight varchar(500),
    cc_royalty varchar(500),
    cc_duty varchar(500),
    cc_ship_method varchar(500),
    cc_lading_port varchar(500),
    cc_hts varchar(500),
    cc_primary_supplier varchar(500),
    cc_sub_brand varchar(500),
    cc_pattern_type varchar(500),
    cc_pop_print_neutral varchar(500),
    cc_debut_season_code varchar(500),
    cc_matchback varchar(500),
    cc_primary_collection varchar(500),
    cc_secondary_collection varchar(500),
    cc_vpn_color varchar(500),
    cc_orig_unit_retail float,
    cc_orig_unit_retail_cad float,
    cc_first_rec_week varchar(500),
    cc_first_inv_week varchar(500),
    cc_first_sale_week varchar(500),
    cc_first_md_week varchar(500),
    cc_last_md_week varchar(500),
    cc_last_rec_week varchar(500),
    cc_store_price_status varchar(500),
    cc_ifc_price_status varchar(500),
    cc_omni_price_type varchar(500),
    ccstylecolorcreatedate varchar(500),
    cc_price_band varchar(500),
    cc_good_better_best varchar(500),
    cccolor varchar(500),
    cccolorfamily varchar(500),
    total_brand_name varchar(500),
    division_name varchar(500),
    group_name varchar(500),
    department_name varchar(500),
    class_name varchar(500),
    subclass_name varchar(500),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    isassortment varchar(500),
    merch_comments varchar(500),
    plan_comments varchar(500),
    cc_is_locked varchar(500),
    cc_s5_adopted varchar(500),
    cc_prepublish boolean,
    cc_prepublished_at timestamp,
    allocator_comments varchar(500),
    cccolorid varchar(500),
    cc_specstylecolor_status varchar(500),
    cc_agent_fee varchar(500),
    cc_port varchar(500),
    cc_factory varchar(500),
    cc_floorset varchar(500),
    cc_use_sys_floorset boolean,
    cc_supp_cost varchar(500),
    cc_finish varchar(500),
    cc_license varchar(500),
    cc_channel_availability varchar(500),
    cc_extended_size varchar(500),
    cc_op_markdown_week varchar(500),
    cc_motif varchar(500),
    cc_rp_revised_markdown_week varchar(500),
    cc_web_current_retail float,
    cc_parent_season_code varchar(500),
    cc_art_code varchar(500),
    cc_patterned_after varchar(500),
    cc_material_content varchar(500),
    cc_fabrication varchar(500),
    stylecolor_name varchar(500),
    style_name varchar(500),
    buyer_email varchar(500),
    cc_buyer varchar(500),
    cc_patterned_after_name varchar(500),
    vpn_color_desc varchar(500),
    cc_num_clones_s5 float,
    cc_num_times_cloned_s5 float,
    cc_spec_division varchar(500),
    cc_spec_group varchar(500),
    cc_development_season varchar(500),
    cc_delivery_season varchar(500),
    cc_po_due_date varchar(500),
    cc_pd_ndc_week varchar(500),
    cc_additional_tariff varchar(500),
    cc_design_notes varchar(500),
    cc_pd_notes varchar(500),
    cc_compliance_notes varchar(500),
    cc_orig_unit_retail_char varchar(500)
);


CREATE TABLE public.trd_p_dc_adj_existing
(
    product varchar(500) NOT NULL,
    location varchar(500) NOT NULL,
    "time" varchar(500) NOT NULL,
    dc_publish float,
    is_locked float,
    dc_uservrp float,
    dc_lockedqty float,
    dc_useradj float,
    dc_onorder float,
    dc_finrev float,
    dc_validwk float,
    dc_finalqty float,
    dc_adjcost float,
    const_y_n float,
    sbkt float,
    dc_isedited float,
    dc_syscost float,
    dc_lndcst float,
    dc_sysvrp float,
    dc_sc_useradj float,
    dc_sc_finrev float,
    po_indicator varchar(500),
    po_shipmode varchar(500),
    air_trigger varchar(500),
    cut varchar(500),
    published_at timestamp(0),
    is_prepublished float,
    prepublished_at timestamp(0),
    last_prepublished float,
    po_arr varchar(500),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    dc_useradj_ecom float,
    dc_onorder_ecom float,
    dc_finrev_ecom float,
    dc_publish_ecom float,
    po_indicator_ecom varchar(500),
    po_shipmode_ecom varchar(500),
    air_trigger_ecom varchar(500),
    cut_ecom varchar(500),
    published_at_ecom timestamp,
    is_prepublished_ecom float,
    prepublished_at_ecom timestamp,
    last_prepublished_ecom float,
    reason_code varchar(500),
    reason_code_ecom varchar(500),
    pack_ind_flag varchar(500) NOT NULL DEFAULT 'N',
    pack_ind_flag_ecom varchar(500) NOT NULL DEFAULT 'N',
    show_in_pack varchar(500),
    show_in_pack_ecom varchar(500),
    prepack_pct float,
    prepack_pct_ecom float,
    default_fringe_indicator varchar(500) NOT NULL DEFAULT 'N',
    default_fringe_indicator_ecom varchar(500) NOT NULL DEFAULT 'N',
    email_to varchar(500)
);


CREATE TABLE public.trd_p_dc_adj_size_existing
(
    product varchar(500),
    location varchar(500),
    "time" varchar(500),
    dc_publish float,
    is_locked float,
    dc_uservrp float,
    dc_lockedqty float,
    dc_useradj float,
    dc_onorder float,
    dc_finrev float,
    dc_validwk float,
    dc_finalqty float,
    dc_adjcost float,
    const_y_n float,
    sbkt float,
    dc_scadj float,
    dc_ttluseradj float,
    dc_scfinrev float,
    dc_ttlfinrev float,
    dc_isedited float,
    dc_onorder_v float,
    dc_onorder_c float,
    current_week varchar(500),
    dc_last_pub_u float,
    dc_last_pub timestamp,
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    dc_useradj_ecom float,
    dc_onorder_ecom float,
    dc_onorder_v_ecom float,
    dc_onorder_c_ecom float,
    dc_finrev_ecom float,
    dc_publish_ecom float,
    dc_last_pub_u_ecom float,
    dc_last_pub_ecom timestamp
);


CREATE TABLE public.trd_ma_stylecolorchannelattributes_existing
(
    product varchar(500),
    location varchar(500),
    dbt_wk varchar(500),
    relaunchweek varchar(500),
    erlstmkdnwk varchar(500),
    exitdate varchar(500),
    initrcptwk varchar(500),
    too int,
    mkdnwks int,
    last_inv_wk varchar(500),
    lstfpwk varchar(500),
    last_rcpt_wk varchar(500),
    lastdcorder varchar(500),
    act_initrcptwk varchar(500),
    act_dbt_wk varchar(500),
    irw_indx int,
    dbtwk_indx int,
    relaunchwk_indx int,
    mdstart_indx int,
    lastdcorder_indx int,
    exitdate_indx int,
    preview_wks int,
    preview_qty int,
    plannedselldnwk varchar(500),
    ccmdstrategy varchar(500),
    slsrnk_store float DEFAULT 3,
    slsrnk_ecom float DEFAULT 3,
    validsizes varchar(5000),
    cc_validsizes_store varchar(5000),
    cc_validsizes_ecom varchar(5000),
    ccrangecode varchar(500),
    cc_presmin int,
    cc_presmin_weeks int,
    cc_rcptint int,
    cc_return_u_pct_store float,
    cc_return_u_pct_ecom float,
    cc_return_u_pct_cross float,
    cc_ordermultiple int,
    cc_ordermin int,
    cc_buy_aps_letter varchar(500),
    ccticketpricechannel float DEFAULT 0.01,
    ccticketpricechannel_override float,
    cc_imupct float DEFAULT 0.0,
    cc_discount_pct float DEFAULT 0.0,
    cc_existingwac float DEFAULT 0.0,
    cc_systemcost float DEFAULT 0.0,
    cc_plan_cost float DEFAULT 0.0,
    ssnprf varchar(500),
    adjaps_store float,
    adjaps_ecom float,
    smoothing_strategy varchar(500),
    in_season_flag varchar(500) DEFAULT 'No',
    auto_rollforward boolean DEFAULT false,
    irr_mode varchar(500) DEFAULT 'Normal',
    plan_current varchar(500),
    lock_agg_edit varchar(500),
    cc_lead_time int,
    cc_service_level float,
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0,
    cc_store_min_multiple int,
    planned_sell_down_week varchar(500),
    cc_selected_clusters varchar(5000),
    cc_cluster_group varchar(500),
    keep_initial_range_plan int,
    cc_sizeelig_rangecode varchar(500),
    cc_presmin_stylecolor int,
    cc_presmin_weeks_stylecolor int,
    cc_final_cost float,
    cc_discount_pct_store float DEFAULT 0.0,
    cc_discount_pct_ecom float DEFAULT 0.0,
    irw_debut_offset int,
    cc_service_level_ecom float,
    cc_first_publish_date timestamp,
    cc_first_publish_snapshot_op int,
    sclr_alloc_max float,
    sclr_presmin float,
    sclr_alloc_min float,
    sclr_presmin_weeks float,
    sclr_tgt_fwoc float DEFAULT 4,
    sclr_fringe_flag float DEFAULT 1,
    act_slsrnk_store float,
    act_aps_store float,
    act_aps_mult_adj_store float,
    act_slsrnk_ecom float,
    act_aps_ecom float,
    act_aps_mult_adj_ecom float,
    use_act_aps_or_act_rank varchar(500) DEFAULT 'Copy Rating',
    use_valid_sizes_from varchar(500) DEFAULT 'Defaults – All Valid Sizes',
    apply_size_mins_to varchar(500) DEFAULT 'Core Sizes Only',
    cc_addoff_store float,
    cc_addoff_ecom float,
    irw_floorset varchar(500),
    irw_superset varchar(500),
    irw_floorset_display varchar(500),
    irw_superset_display varchar(500),
    irw_floorset_id varchar(500),
    cc_size_eligibility_profile varchar(500),
    cloned_at timestamp
);


CREATE TABLE public.trd_ma_imgattributes_existing
(
    indx int,
    product varchar(500),
    img varchar(2000),
    eventdate date DEFAULT (now())::date,
    version_id int DEFAULT 1,
    created_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    created_by varchar(500) DEFAULT 'system',
    updated_at timestamp DEFAULT date_trunc('sec', (now())::timestamptz(6)),
    updated_by varchar(500) DEFAULT 'system',
    record_state int DEFAULT 0
);


CREATE TABLE public.TRD_REF_PRD_MEMBERMASTER
(
    member_id varchar(200),
    product_level varchar(200)
);


CREATE TABLE public.TRD_REF_S5_CLIENT_ID_MAPPING
(
    s5_id varchar(100),
    client_erp_id varchar(100),
    levelid varchar(20)
);


CREATE TABLE public.trd_d_product
(
    id varchar(200),
    client_id varchar(200),
    name varchar(200),
    description varchar(200),
    levelid varchar(400),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_h_prodstd
(
    ID varchar(500),
    ANCESTOR0 varchar(500),
    ANCESTOR1 varchar(500),
    ANCESTOR2 varchar(500),
    ANCESTOR3 varchar(500),
    ANCESTOR4 varchar(500),
    ANCESTOR5 varchar(500),
    ANCESTOR6 varchar(500),
    ANCESTOR7 varchar(500),
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_ma_styleattributes
(
    product varchar(500),
    sty_knit_or_woven varchar(500),
    sty_fabrication varchar(500),
    sty_sleeve_length varchar(500),
    sty_leg_opening varchar(500),
    sty_brand varchar(500),
    sty_body_style_silhouette varchar(500),
    sty_occasion_usage varchar(500),
    sty_detail varchar(500),
    sty_finish_style varchar(500),
    sty_private_label varchar(500),
    sty_license varchar(500),
    sty_license_vs_non_licensed varchar(500),
    sty_hazmat_code varchar(500),
    sty_prop_65_warning varchar(500),
    sty_material_content varchar(500),
    sty_item_type varchar(500),
    sty_dwrise varchar(500),
    sty_length varchar(500),
    sty_neckline varchar(500),
    sty_toeshape varchar(500),
    sty_heel_height varchar(500),
    sty_bottom_length varchar(500),
    sty_v_360_smoothing varchar(500),
    sty_franchise varchar(500),
    sty_key_item varchar(500),
    sty_single_vs_multi_pack varchar(500),
    sty_ticket_type varchar(500),
    sty_vpn varchar(500),
    sty_size_range varchar(500),
    ccstylecreatedate varchar(500),
    sty_is_locked varchar(10),
    sty_s5_adopted varchar(10),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int,
    sty_knit_fit varchar(500)
);


CREATE TABLE public.trd_ma_stylecolorattributes
(
    product varchar(500),
    cc_item_diff_1 varchar(500),
    cc_unit_retail numeric(16,4),
    cc_unit_retail_cad numeric(16,4),
    cc_pattern varchar(500),
    cc_graphic varchar(500),
    cc_fashion_basic varchar(500),
    cc_holiday varchar(500),
    cc_property_type varchar(500),
    cc_internet_exclusive varchar(500),
    cc_web_color_discription varchar(500),
    cc_export_hts varchar(500),
    cc_commercial_invoice_description varchar(500),
    cc_season_code varchar(500),
    cc_dtr varchar(500),
    cc_dw_color_family varchar(500),
    cc_channel_reorder varchar(500),
    cc_ticket_season_code varchar(500),
    cc_sub_programs varchar(500),
    cc_music_genre varchar(500),
    cc_clearance_str_product varchar(500),
    cc_po_supplier varchar(500),
    cc_origin_country_id varchar(500),
    cc_country_of_sourcing varchar(500),
    cc_country_of_manufacturing varchar(500),
    cc_unit_cost numeric(16,4),
    cc_freight varchar(500),
    cc_royalty varchar(500),
    cc_duty varchar(500),
    cc_ship_method varchar(500),
    cc_lading_port varchar(500),
    cc_hts varchar(500),
    cc_primary_supplier varchar(500),
    cc_sub_brand varchar(500),
    cc_pattern_type varchar(500),
    cc_pop_print_neutral varchar(500),
    cc_debut_season_code varchar(500),
    cc_matchback varchar(500),
    cc_primary_collection varchar(500),
    cc_secondary_collection varchar(500),
    cc_vpn_color varchar(500),
    cc_orig_unit_retail numeric(16,4),
    cc_orig_unit_retail_cad numeric(16,4),
    cc_first_rec_week varchar(511),
    cc_first_inv_week varchar(511),
    cc_first_sale_week varchar(511),
    cc_first_md_week varchar(511),
    cc_last_md_week varchar(511),
    cc_last_rec_week varchar(511),
    cc_store_price_status varchar(500),
    cc_ifc_price_status varchar(500),
    cc_omni_price_type varchar(500),
    ccstylecolorcreatedate varchar(500),
    cc_price_band varchar(500),
    cc_good_better_best varchar(500),
    cccolor varchar(500),
    cccolorfamily varchar(500),
    total_brand_name varchar(500),
    division_name varchar(500),
    group_name varchar(500),
    department_name varchar(500),
    class_name varchar(500),
    subclass_name varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int,
    isassortment varchar(500),
    merch_comments varchar(500),
    plan_comments varchar(500),
    cc_is_locked varchar(10),
    cc_s5_adopted varchar(10),
    cc_prepublish boolean,
    cc_prepublished_at timestamp,
    allocator_comments varchar(500),
    cccolorid varchar(500),
    cc_specstylecolor_status varchar(500),
    cc_supp_cost varchar(500),
    cc_finish varchar(500),
    cc_license varchar(500),
    cc_channel_availability varchar(500),
    cc_extended_size varchar(500),
    cc_op_markdown_week varchar(500),
    cc_motif varchar(500),
    cc_rp_revised_markdown_week varchar(500),
    cc_web_current_retail numeric(16,4),
    cc_parent_season_code varchar(500),
    cc_art_code varchar(500),
    cc_material_content varchar(500),
    cc_fabrication varchar(500),
    stylecolor_name varchar(500),
    style_name varchar(500),
    cc_spec_division varchar(500),
    cc_spec_group varchar(500),
    cc_development_season varchar(500),
    cc_delivery_season varchar(500),
    cc_po_due_date varchar(500),
    cc_pd_ndc_week varchar(500),
    cc_additional_tariff varchar(500),
    cc_design_notes varchar(500),
    cc_pd_notes varchar(500),
    cc_compliance_notes varchar(500)
);


CREATE TABLE public.trd_ma_sizeattributes
(
    product varchar(500),
    parent_id varchar(200),
    item_diff_2 varchar(500),
    item_diff_3 varchar(500),
    sizeattribute varchar(500),
    isvalid int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int,
    ccctylecolorsizecreatedate varchar(500)
);


CREATE TABLE public.TRD_REF_CC_SKU_MAPPING
(
    STYLECOLORSIZE varchar(500),
    STYLECOLOR varchar(500),
    STYLE varchar(500),
    SUBCLASS varchar(500),
    CLASS varchar(500),
    DEPARTMENT varchar(500),
    "GROUP" varchar(500),
    DIVISION varchar(500),
    TOTAL_BRAND varchar(500)
);


CREATE TABLE public.TRD_REF_CC_STYLE_MAPPING
(
    STYLECOLOR varchar(500),
    STYLE varchar(500)
);


CREATE TABLE public.size_ids
(
    size_name varchar(500),
    size_id varchar(500)
);


CREATE TABLE public.trd_ma_imgattributes
(
    indx int,
    product varchar(500),
    img varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_swatches
(
    attributeid varchar(7),
    validvalue varchar(200),
    datastr varchar(200),
    strtype varchar(3),
    type varchar(1),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_l_dependencylookup
(
    lookup_id varchar(500),
    lookup_value varchar(500),
    target_id varchar(500),
    target_value varchar(500),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int,
    index int
);


CREATE TABLE public.temp_locgrade
(
    "time" varchar(50),
    product varchar(200),
    id varchar(9),
    value varchar(50),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_locgrade_nograde
(
    "time" varchar(50),
    product varchar(200),
    id varchar(9),
    value varchar(8),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_locclimate
(
    "time" varchar(50),
    product varchar(200),
    id varchar(17),
    value varchar(200),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_loccapacity
(
    "time" varchar(50),
    product varchar(200),
    id varchar(12),
    value varchar(200),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_locbanner
(
    "time" varchar(50),
    product varchar(200),
    id varchar(16),
    value varchar(200),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_locregion
(
    "time" varchar(50),
    product varchar(200),
    id varchar(14),
    value varchar(200),
    stores long varchar(1000002)
);


CREATE TABLE public.temp_lochazmat
(
    "time" varchar(50),
    product varchar(200),
    id varchar(10),
    value varchar(200),
    stores long varchar(1000002)
);


CREATE TABLE public.trd_l_storelookup
(
    "time" varchar(50),
    product varchar(200),
    id varchar(17),
    value varchar(200),
    stores long varchar(1000002),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_v_memberbasedvalidvalues
(
    attributeid varchar(200),
    membertie varchar(200),
    attributekey varchar(200),
    attributevalue varchar(200),
    indx int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_l_ssglookup
(
    product varchar(200),
    location varchar(200),
    ssg_id varchar(200),
    ssg_name varchar(200),
    stores varchar(5000),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.trd_l_pricebandlookup
(
    product varchar(200),
    ticket_price_min float,
    ticket_price_max float,
    price_band varchar(200),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(20),
    updated_at timestamp,
    updated_by varchar(20),
    record_state int
);


CREATE TABLE public.TRD_INT_ACT_ONORDER
(
    MEMBER_ID varchar(500),
    LOCATION_ID varchar(500),
    FLOW_ID varchar(500),
    WEEK_ID varchar(500),
    PRICE_STATUS varchar(500),
    NDC_DATE varchar(500),
    START_SHIP_DATE varchar(500),
    PO_CANCEL_DATE varchar(500),
    PO_ID varchar(500),
    TOTAL_UNITS numeric(16,4),
    TOTAL_COST numeric(16,4),
    TOTAL_RETAIL numeric(16,4),
    P_NBR_PACKS varchar(500),
    P_PACK_ID varchar(500),
    P_QTY_PER_PACK varchar(500),
    P_PO_TYPE varchar(500),
    P_VENDOR_NBR varchar(500),
    P_PO_VENDOR_NBR varchar(500),
    P_VENDOR_DESC varchar(500),
    PO_LN_SEQ_NUM varchar(500)
);


CREATE TABLE public.TRD_REF_TIMEMAPPING_WEEK_INDX
(
    week_id varchar(50),
    indx int
);


CREATE TABLE public.TRD_PERF_ACT_OO_WEEKS
(
    week_id varchar(50)
);


CREATE TABLE public.TRD_PERF_ACT_OO_13WEEKS
(
    week_id varchar(50)
);


CREATE TABLE public.trd_PERF_ACT_ONORDER_SKU
(
    STYLECOLORSIZE varchar(500),
    STYLECOLOR varchar(500),
    LOCATION_ID varchar(500),
    on_order_r numeric(16,4),
    on_order_u numeric(16,4),
    on_order_c numeric(16,4)
);


CREATE TABLE public.TRD_PERF_ACT_ONORDER_SKU_4WKS
(
    STYLECOLORSIZE varchar(500),
    STYLECOLOR varchar(500),
    LOCATION_ID varchar(500),
    on_order_r_4wk numeric(16,4),
    on_order_u_4wk numeric(16,4),
    on_order_c_4wk numeric(16,4)
);


CREATE TABLE public.TRD_PERF_ACT_ONORDER_SKU_13WKS
(
    STYLECOLORSIZE varchar(500),
    STYLECOLOR varchar(500),
    LOCATION_ID varchar(500),
    on_order_r_13wk numeric(16,4),
    on_order_u_13wk numeric(16,4),
    on_order_c_13wk numeric(16,4)
);


CREATE TABLE public.trd_p_onorder_tbl
(
    product varchar(500),
    stylecolor varchar(500),
    location varchar(500),
    prodlife varchar(2),
    cluster varchar(2),
    on_order_r numeric(16,4),
    on_order_u numeric(16,4),
    on_order_c numeric(16,4),
    on_order_r_4wk int,
    on_order_u_4wk int,
    on_order_c_4wk int,
    on_order_r_13wk int,
    on_order_u_13wk int,
    on_order_c_13wk int,
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(6),
    updated_at timestamp,
    updated_by varchar(6),
    record_state int
);


CREATE TABLE public.trd_p_onorder_by_po_tbl
(
    sku varchar(500),
    parent_id varchar(500),
    location_id varchar(500),
    flow_id varchar(500),
    week_id varchar(511),
    price_status varchar(2),
    ndc_date varchar(500),
    start_ship_date varchar(500),
    po_cancel_date varchar(500),
    po_id varchar(500),
    total_units numeric(16,4),
    total_cost numeric(16,4),
    total_retail numeric(16,4),
    p_nbr_packs varchar(500),
    p_pack_id varchar(500),
    p_qty_per_pack varchar(500),
    p_po_type varchar(500),
    p_vendor_nbr varchar(500),
    p_po_vendor_nbr varchar(500),
    p_vendor_desc varchar(500),
    po_ln_seq_num varchar(500),
    eventdate date,
    updated_at timestamp
);


CREATE TABLE public.trd_p_dc_adj_stylecolor
(
    stylecolor varchar(500),
    store varchar(9),
    WEEK_ID varchar(511),
    ON_ORDER_V numeric(22,4),
    ON_ORDER_U numeric(22,4),
    ON_ORDER_C numeric(22,4),
    ON_ORDER_V_ECOM numeric(22,4),
    ON_ORDER_U_ECOM numeric(22,4),
    ON_ORDER_C_ECOM numeric(22,4),
    adj_cost numeric(20,2)
);


CREATE TABLE public.trd_p_dc_adj_stylecolorsize
(
    stylecolorsize varchar(500),
    store varchar(9),
    WEEK_ID varchar(511),
    ON_ORDER_V numeric(22,4),
    ON_ORDER_U numeric(22,4),
    ON_ORDER_C numeric(22,4),
    ON_ORDER_V_ECOM numeric(22,4),
    ON_ORDER_U_ECOM numeric(22,4),
    ON_ORDER_C_ECOM numeric(22,4),
    adj_cost numeric(20,2)
);


CREATE TABLE public.fix_stylecolor_hier
(
    cc_hier_id varchar(200),
    cc_hier_anc0 varchar(200),
    cc_hier_anc2 varchar(200),
    cc_hier_anc3 varchar(200),
    cc_hier_anc4 varchar(200),
    cc_hier_anc5 varchar(200),
    cc_hier_anc6 varchar(200),
    cc_hier_anc7 varchar(200),
    style_hier_id varchar(200),
    style_hier_anc1 varchar(200),
    style_hier_anc2 varchar(200),
    style_hier_anc3 varchar(200),
    style_hier_anc4 varchar(200),
    style_hier_anc5 varchar(200),
    style_hier_anc6 varchar(200)
);


CREATE TABLE public.fix_sku_hier
(
    sku_hier_id varchar(200),
    sku_hier_anc0 varchar(200),
    sku_hier_anc2 varchar(200),
    sku_hier_anc3 varchar(200),
    sku_hier_anc4 varchar(200),
    sku_hier_anc5 varchar(200),
    sku_hier_anc6 varchar(200),
    sku_hier_anc7 varchar(200),
    styclr_hier_id varchar(200),
    styclr_hier_anc1 varchar(200),
    styclr_hier_anc2 varchar(200),
    styclr_hier_anc3 varchar(200),
    styclr_hier_anc4 varchar(200),
    styclr_hier_anc5 varchar(200),
    styclr_hier_anc6 varchar(200)
);


CREATE TABLE public.trd_h_prodstd_mismatch
(
    brand_master varchar(200),
    ancestor7 varchar(200),
    division_master varchar(200),
    ancestor6 varchar(200),
    group_master varchar(200),
    ancestor5 varchar(200),
    dept_master varchar(200),
    ancestor4 varchar(200),
    class_master varchar(200),
    ancestor3 varchar(200),
    subclass_master varchar(200),
    ancestor2 varchar(200),
    stylecolor varchar(200),
    sku_id varchar(200)
);


CREATE TABLE public.trd_ma_imgattributes_existing_temp
(
    indx int,
    product varchar(500),
    img varchar(2000),
    eventdate date,
    version_id int,
    created_at timestamp,
    created_by varchar(500),
    updated_at timestamp,
    updated_by varchar(500),
    record_state int
);


CREATE TABLE public.trd_replannable_choices
(
    stylecolor_id varchar(500)
);


CREATE PROJECTION public.TRD_IN_PRD_MASTER_super /*+basename(TRD_IN_PRD_MASTER),createtype(L)*/ 
(
 MEMBER_ID,
 S5_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 PRODUCT_LEVEL
)
AS
 SELECT TRD_IN_PRD_MASTER.MEMBER_ID,
        TRD_IN_PRD_MASTER.S5_ID,
        TRD_IN_PRD_MASTER.MEMBER_NAME,
        TRD_IN_PRD_MASTER.MEMBER_DESC,
        TRD_IN_PRD_MASTER.PRODUCT_LEVEL
 FROM public.TRD_IN_PRD_MASTER
 ORDER BY TRD_IN_PRD_MASTER.MEMBER_ID,
          TRD_IN_PRD_MASTER.S5_ID,
          TRD_IN_PRD_MASTER.MEMBER_NAME,
          TRD_IN_PRD_MASTER.MEMBER_DESC,
          TRD_IN_PRD_MASTER.PRODUCT_LEVEL
SEGMENTED BY hash(TRD_IN_PRD_MASTER.MEMBER_ID, TRD_IN_PRD_MASTER.S5_ID, TRD_IN_PRD_MASTER.MEMBER_NAME, TRD_IN_PRD_MASTER.MEMBER_DESC, TRD_IN_PRD_MASTER.PRODUCT_LEVEL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_HIER_super /*+basename(TRD_IN_PRD_HIER),createtype(L)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 ANCESTOR5,
 ANCESTOR6,
 ANCESTOR7
)
AS
 SELECT TRD_IN_PRD_HIER.MEMBER_ID,
        TRD_IN_PRD_HIER.ANCESTOR0,
        TRD_IN_PRD_HIER.ANCESTOR1,
        TRD_IN_PRD_HIER.ANCESTOR2,
        TRD_IN_PRD_HIER.ANCESTOR3,
        TRD_IN_PRD_HIER.ANCESTOR4,
        TRD_IN_PRD_HIER.ANCESTOR5,
        TRD_IN_PRD_HIER.ANCESTOR6,
        TRD_IN_PRD_HIER.ANCESTOR7
 FROM public.TRD_IN_PRD_HIER
 ORDER BY TRD_IN_PRD_HIER.MEMBER_ID,
          TRD_IN_PRD_HIER.ANCESTOR0,
          TRD_IN_PRD_HIER.ANCESTOR1,
          TRD_IN_PRD_HIER.ANCESTOR2,
          TRD_IN_PRD_HIER.ANCESTOR3,
          TRD_IN_PRD_HIER.ANCESTOR4,
          TRD_IN_PRD_HIER.ANCESTOR5,
          TRD_IN_PRD_HIER.ANCESTOR6
SEGMENTED BY hash(TRD_IN_PRD_HIER.MEMBER_ID, TRD_IN_PRD_HIER.ANCESTOR0, TRD_IN_PRD_HIER.ANCESTOR1, TRD_IN_PRD_HIER.ANCESTOR2, TRD_IN_PRD_HIER.ANCESTOR3, TRD_IN_PRD_HIER.ANCESTOR4, TRD_IN_PRD_HIER.ANCESTOR5, TRD_IN_PRD_HIER.ANCESTOR6) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_LOC_MASTER_super /*+basename(TRD_IN_LOC_MASTER),createtype(L)*/ 
(
 MEMBER_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 LOC_LEVEL
)
AS
 SELECT TRD_IN_LOC_MASTER.MEMBER_ID,
        TRD_IN_LOC_MASTER.MEMBER_NAME,
        TRD_IN_LOC_MASTER.MEMBER_DESC,
        TRD_IN_LOC_MASTER.LOC_LEVEL
 FROM public.TRD_IN_LOC_MASTER
 ORDER BY TRD_IN_LOC_MASTER.MEMBER_ID,
          TRD_IN_LOC_MASTER.MEMBER_NAME,
          TRD_IN_LOC_MASTER.MEMBER_DESC,
          TRD_IN_LOC_MASTER.LOC_LEVEL
SEGMENTED BY hash(TRD_IN_LOC_MASTER.MEMBER_ID, TRD_IN_LOC_MASTER.MEMBER_NAME, TRD_IN_LOC_MASTER.MEMBER_DESC, TRD_IN_LOC_MASTER.LOC_LEVEL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_LOC_HIER_super /*+basename(TRD_IN_LOC_HIER),createtype(L)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4
)
AS
 SELECT TRD_IN_LOC_HIER.MEMBER_ID,
        TRD_IN_LOC_HIER.ANCESTOR0,
        TRD_IN_LOC_HIER.ANCESTOR1,
        TRD_IN_LOC_HIER.ANCESTOR2,
        TRD_IN_LOC_HIER.ANCESTOR3,
        TRD_IN_LOC_HIER.ANCESTOR4
 FROM public.TRD_IN_LOC_HIER
 ORDER BY TRD_IN_LOC_HIER.MEMBER_ID,
          TRD_IN_LOC_HIER.ANCESTOR0,
          TRD_IN_LOC_HIER.ANCESTOR1,
          TRD_IN_LOC_HIER.ANCESTOR2,
          TRD_IN_LOC_HIER.ANCESTOR3,
          TRD_IN_LOC_HIER.ANCESTOR4
SEGMENTED BY hash(TRD_IN_LOC_HIER.MEMBER_ID, TRD_IN_LOC_HIER.ANCESTOR0, TRD_IN_LOC_HIER.ANCESTOR1, TRD_IN_LOC_HIER.ANCESTOR2, TRD_IN_LOC_HIER.ANCESTOR3, TRD_IN_LOC_HIER.ANCESTOR4) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_MASTER_super /*+basename(TRD_INTERFACE_MASTER),createtype(L)*/ 
(
 ID,
 TYPE,
 SOURCE,
 TARGET,
 FREQUENCY,
 INBOUND_FILE,
 INBOUND_TABLE,
 OUTBOUND_TABLE,
 TARGET_TABLE,
 CURRENT_RECORD_COUNT,
 PREVIOUS_RECORD_COUNT,
 CURR_PREV_PERCENTAGE_DIFF,
 COUNT_DIFF_PERCENTAGE_THRESHOLD,
 CHECK_PERCENTAGE_DIFF,
 CHECK_ZERO_COUNT,
 CURRENT_REJECT_COUNT
)
AS
 SELECT TRD_INTERFACE_MASTER.ID,
        TRD_INTERFACE_MASTER.TYPE,
        TRD_INTERFACE_MASTER.SOURCE,
        TRD_INTERFACE_MASTER.TARGET,
        TRD_INTERFACE_MASTER.FREQUENCY,
        TRD_INTERFACE_MASTER.INBOUND_FILE,
        TRD_INTERFACE_MASTER.INBOUND_TABLE,
        TRD_INTERFACE_MASTER.OUTBOUND_TABLE,
        TRD_INTERFACE_MASTER.TARGET_TABLE,
        TRD_INTERFACE_MASTER.CURRENT_RECORD_COUNT,
        TRD_INTERFACE_MASTER.PREVIOUS_RECORD_COUNT,
        TRD_INTERFACE_MASTER.CURR_PREV_PERCENTAGE_DIFF,
        TRD_INTERFACE_MASTER.COUNT_DIFF_PERCENTAGE_THRESHOLD,
        TRD_INTERFACE_MASTER.CHECK_PERCENTAGE_DIFF,
        TRD_INTERFACE_MASTER.CHECK_ZERO_COUNT,
        TRD_INTERFACE_MASTER.CURRENT_REJECT_COUNT
 FROM public.TRD_INTERFACE_MASTER
 ORDER BY TRD_INTERFACE_MASTER.ID,
          TRD_INTERFACE_MASTER.TYPE,
          TRD_INTERFACE_MASTER.SOURCE,
          TRD_INTERFACE_MASTER.TARGET,
          TRD_INTERFACE_MASTER.FREQUENCY,
          TRD_INTERFACE_MASTER.INBOUND_FILE,
          TRD_INTERFACE_MASTER.INBOUND_TABLE,
          TRD_INTERFACE_MASTER.OUTBOUND_TABLE
SEGMENTED BY hash(TRD_INTERFACE_MASTER.CURRENT_RECORD_COUNT, TRD_INTERFACE_MASTER.PREVIOUS_RECORD_COUNT, TRD_INTERFACE_MASTER.CURR_PREV_PERCENTAGE_DIFF, TRD_INTERFACE_MASTER.COUNT_DIFF_PERCENTAGE_THRESHOLD, TRD_INTERFACE_MASTER.CHECK_PERCENTAGE_DIFF, TRD_INTERFACE_MASTER.CHECK_ZERO_COUNT, TRD_INTERFACE_MASTER.CURRENT_REJECT_COUNT, TRD_INTERFACE_MASTER.TYPE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_COUNTS_super /*+basename(TRD_INTERFACE_COUNTS),createtype(L)*/ 
(
 INTERFACE_ID,
 CURRENT_RECORD_COUNT,
 TIME_STAMP,
 CREATED_AT
)
AS
 SELECT TRD_INTERFACE_COUNTS.INTERFACE_ID,
        TRD_INTERFACE_COUNTS.CURRENT_RECORD_COUNT,
        TRD_INTERFACE_COUNTS.TIME_STAMP,
        TRD_INTERFACE_COUNTS.CREATED_AT
 FROM public.TRD_INTERFACE_COUNTS
 ORDER BY TRD_INTERFACE_COUNTS.INTERFACE_ID,
          TRD_INTERFACE_COUNTS.CURRENT_RECORD_COUNT,
          TRD_INTERFACE_COUNTS.TIME_STAMP,
          TRD_INTERFACE_COUNTS.CREATED_AT
SEGMENTED BY hash(TRD_INTERFACE_COUNTS.CURRENT_RECORD_COUNT, TRD_INTERFACE_COUNTS.CREATED_AT, TRD_INTERFACE_COUNTS.TIME_STAMP, TRD_INTERFACE_COUNTS.INTERFACE_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_TIMESTAMP_super /*+basename(TRD_IN_TIMESTAMP),createtype(L)*/ 
(
 TIME_STAMP
)
AS
 SELECT TRD_IN_TIMESTAMP.TIME_STAMP
 FROM public.TRD_IN_TIMESTAMP
 ORDER BY TRD_IN_TIMESTAMP.TIME_STAMP
SEGMENTED BY hash(TRD_IN_TIMESTAMP.TIME_STAMP) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_super /*+basename(TRD_IN_VV_ATTRVALIDVALUESASSOCIATION),createtype(L)*/ 
(
 ATTRIBUTE_ID,
 ATTRIBUTE_NAME,
 SEQ_NO,
 DEPT,
 CLASS,
 SUBCLASS,
 REQUIRED_IND
)
AS
 SELECT TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_ID,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_NAME,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SEQ_NO,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.DEPT,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.CLASS,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SUBCLASS,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.REQUIRED_IND
 FROM public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION
 ORDER BY TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_ID,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_NAME,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SEQ_NO,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.DEPT,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.CLASS,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SUBCLASS,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.REQUIRED_IND
SEGMENTED BY hash(TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_ID, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.ATTRIBUTE_NAME, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SEQ_NO, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.DEPT, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.CLASS, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.SUBCLASS, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION.REQUIRED_IND) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_ATTRVALIDVALUES_super /*+basename(TRD_IN_VV_ATTRVALIDVALUES),createtype(L)*/ 
(
 ATTRIBUTE_ID,
 ATTRIBUTE_DESC,
 ATTRIBUTE_VALUE,
 ATTRIBUTE_VALUE_DESC
)
AS
 SELECT TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_ID,
        TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_DESC,
        TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE,
        TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE_DESC
 FROM public.TRD_IN_VV_ATTRVALIDVALUES
 ORDER BY TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_ID,
          TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_DESC,
          TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE,
          TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE_DESC
SEGMENTED BY hash(TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_ID, TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_DESC, TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE, TRD_IN_VV_ATTRVALIDVALUES.ATTRIBUTE_VALUE_DESC) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_COLORMAPPING_super /*+basename(TRD_IN_VV_COLORMAPPING),createtype(L)*/ 
(
 COLOR_ID,
 COLOR_DESCRIPTION,
 COLOR_CODE,
 DW_COLOR_FAMILY
)
AS
 SELECT TRD_IN_VV_COLORMAPPING.COLOR_ID,
        TRD_IN_VV_COLORMAPPING.COLOR_DESCRIPTION,
        TRD_IN_VV_COLORMAPPING.COLOR_CODE,
        TRD_IN_VV_COLORMAPPING.DW_COLOR_FAMILY
 FROM public.TRD_IN_VV_COLORMAPPING
 ORDER BY TRD_IN_VV_COLORMAPPING.COLOR_ID,
          TRD_IN_VV_COLORMAPPING.COLOR_DESCRIPTION,
          TRD_IN_VV_COLORMAPPING.COLOR_CODE,
          TRD_IN_VV_COLORMAPPING.DW_COLOR_FAMILY
SEGMENTED BY hash(TRD_IN_VV_COLORMAPPING.COLOR_ID, TRD_IN_VV_COLORMAPPING.COLOR_DESCRIPTION, TRD_IN_VV_COLORMAPPING.COLOR_CODE, TRD_IN_VV_COLORMAPPING.DW_COLOR_FAMILY) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_IMG_URL_super /*+basename(TRD_IN_IMG_URL),createtype(L)*/ 
(
 MEMBER_ID,
 URL
)
AS
 SELECT TRD_IN_IMG_URL.MEMBER_ID,
        TRD_IN_IMG_URL.URL
 FROM public.TRD_IN_IMG_URL
 ORDER BY TRD_IN_IMG_URL.MEMBER_ID,
          TRD_IN_IMG_URL.URL
SEGMENTED BY hash(TRD_IN_IMG_URL.MEMBER_ID, TRD_IN_IMG_URL.URL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_PRD_MASTER_super /*+basename(TRD_REJ_PRD_MASTER),createtype(L)*/ 
(
 MEMBER_ID,
 S5_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 PRODUCT_LEVEL,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_PRD_MASTER.MEMBER_ID,
        TRD_REJ_PRD_MASTER.S5_ID,
        TRD_REJ_PRD_MASTER.MEMBER_NAME,
        TRD_REJ_PRD_MASTER.MEMBER_DESC,
        TRD_REJ_PRD_MASTER.PRODUCT_LEVEL,
        TRD_REJ_PRD_MASTER.REJECT_REASON
 FROM public.TRD_REJ_PRD_MASTER
 ORDER BY TRD_REJ_PRD_MASTER.MEMBER_ID,
          TRD_REJ_PRD_MASTER.S5_ID,
          TRD_REJ_PRD_MASTER.MEMBER_NAME,
          TRD_REJ_PRD_MASTER.MEMBER_DESC,
          TRD_REJ_PRD_MASTER.PRODUCT_LEVEL,
          TRD_REJ_PRD_MASTER.REJECT_REASON
SEGMENTED BY hash(TRD_REJ_PRD_MASTER.MEMBER_ID, TRD_REJ_PRD_MASTER.S5_ID, TRD_REJ_PRD_MASTER.MEMBER_NAME, TRD_REJ_PRD_MASTER.MEMBER_DESC, TRD_REJ_PRD_MASTER.PRODUCT_LEVEL, TRD_REJ_PRD_MASTER.REJECT_REASON) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_PRD_HIER_super /*+basename(TRD_REJ_PRD_HIER),createtype(L)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 ANCESTOR5,
 ANCESTOR6,
 ANCESTOR7,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_PRD_HIER.MEMBER_ID,
        TRD_REJ_PRD_HIER.ANCESTOR0,
        TRD_REJ_PRD_HIER.ANCESTOR1,
        TRD_REJ_PRD_HIER.ANCESTOR2,
        TRD_REJ_PRD_HIER.ANCESTOR3,
        TRD_REJ_PRD_HIER.ANCESTOR4,
        TRD_REJ_PRD_HIER.ANCESTOR5,
        TRD_REJ_PRD_HIER.ANCESTOR6,
        TRD_REJ_PRD_HIER.ANCESTOR7,
        TRD_REJ_PRD_HIER.REJECT_REASON
 FROM public.TRD_REJ_PRD_HIER
 ORDER BY TRD_REJ_PRD_HIER.MEMBER_ID,
          TRD_REJ_PRD_HIER.ANCESTOR0,
          TRD_REJ_PRD_HIER.ANCESTOR1,
          TRD_REJ_PRD_HIER.ANCESTOR2,
          TRD_REJ_PRD_HIER.ANCESTOR3,
          TRD_REJ_PRD_HIER.ANCESTOR4,
          TRD_REJ_PRD_HIER.ANCESTOR5,
          TRD_REJ_PRD_HIER.ANCESTOR6
SEGMENTED BY hash(TRD_REJ_PRD_HIER.REJECT_REASON, TRD_REJ_PRD_HIER.MEMBER_ID, TRD_REJ_PRD_HIER.ANCESTOR0, TRD_REJ_PRD_HIER.ANCESTOR1, TRD_REJ_PRD_HIER.ANCESTOR2, TRD_REJ_PRD_HIER.ANCESTOR3, TRD_REJ_PRD_HIER.ANCESTOR4, TRD_REJ_PRD_HIER.ANCESTOR5) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_LOC_MASTER_super /*+basename(TRD_REJ_LOC_MASTER),createtype(L)*/ 
(
 MEMBER_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 LOC_LEVEL,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_LOC_MASTER.MEMBER_ID,
        TRD_REJ_LOC_MASTER.MEMBER_NAME,
        TRD_REJ_LOC_MASTER.MEMBER_DESC,
        TRD_REJ_LOC_MASTER.LOC_LEVEL,
        TRD_REJ_LOC_MASTER.REJECT_REASON
 FROM public.TRD_REJ_LOC_MASTER
 ORDER BY TRD_REJ_LOC_MASTER.MEMBER_ID,
          TRD_REJ_LOC_MASTER.MEMBER_NAME,
          TRD_REJ_LOC_MASTER.MEMBER_DESC,
          TRD_REJ_LOC_MASTER.LOC_LEVEL,
          TRD_REJ_LOC_MASTER.REJECT_REASON
SEGMENTED BY hash(TRD_REJ_LOC_MASTER.MEMBER_ID, TRD_REJ_LOC_MASTER.MEMBER_NAME, TRD_REJ_LOC_MASTER.MEMBER_DESC, TRD_REJ_LOC_MASTER.LOC_LEVEL, TRD_REJ_LOC_MASTER.REJECT_REASON) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_LOC_HIER_super /*+basename(TRD_REJ_LOC_HIER),createtype(L)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_LOC_HIER.MEMBER_ID,
        TRD_REJ_LOC_HIER.ANCESTOR0,
        TRD_REJ_LOC_HIER.ANCESTOR1,
        TRD_REJ_LOC_HIER.ANCESTOR2,
        TRD_REJ_LOC_HIER.ANCESTOR3,
        TRD_REJ_LOC_HIER.ANCESTOR4,
        TRD_REJ_LOC_HIER.REJECT_REASON
 FROM public.TRD_REJ_LOC_HIER
 ORDER BY TRD_REJ_LOC_HIER.MEMBER_ID,
          TRD_REJ_LOC_HIER.ANCESTOR0,
          TRD_REJ_LOC_HIER.ANCESTOR1,
          TRD_REJ_LOC_HIER.ANCESTOR2,
          TRD_REJ_LOC_HIER.ANCESTOR3,
          TRD_REJ_LOC_HIER.ANCESTOR4,
          TRD_REJ_LOC_HIER.REJECT_REASON
SEGMENTED BY hash(TRD_REJ_LOC_HIER.REJECT_REASON, TRD_REJ_LOC_HIER.MEMBER_ID, TRD_REJ_LOC_HIER.ANCESTOR0, TRD_REJ_LOC_HIER.ANCESTOR1, TRD_REJ_LOC_HIER.ANCESTOR2, TRD_REJ_LOC_HIER.ANCESTOR3, TRD_REJ_LOC_HIER.ANCESTOR4) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_IMG_URL_super /*+basename(TRD_REJ_IMG_URL),createtype(L)*/ 
(
 MEMBER_ID,
 URL,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_IMG_URL.MEMBER_ID,
        TRD_REJ_IMG_URL.URL,
        TRD_REJ_IMG_URL.REJECT_REASON
 FROM public.TRD_REJ_IMG_URL
 ORDER BY TRD_REJ_IMG_URL.MEMBER_ID,
          TRD_REJ_IMG_URL.URL,
          TRD_REJ_IMG_URL.REJECT_REASON
SEGMENTED BY hash(TRD_REJ_IMG_URL.REJECT_REASON, TRD_REJ_IMG_URL.MEMBER_ID, TRD_REJ_IMG_URL.URL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_ONORDER_super /*+basename(TRD_IN_ACT_ONORDER),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 FLOW_ID,
 WEEK_ID,
 PRICE_STATUS,
 NDC_DATE,
 START_SHIP_DATE,
 PO_CANCEL_DATE,
 PO_ID,
 TOTAL_UNITS,
 TOTAL_COST,
 TOTAL_RETAIL,
 P_NBR_PACKS,
 P_PACK_ID,
 P_QTY_PER_PACK,
 P_PO_TYPE,
 P_VENDOR_NBR,
 P_PO_VENDOR_NBR,
 P_VENDOR_DESC,
 PO_LN_SEQ_NUM
)
AS
 SELECT TRD_IN_ACT_ONORDER.MEMBER_ID,
        TRD_IN_ACT_ONORDER.LOCATION_ID,
        TRD_IN_ACT_ONORDER.FLOW_ID,
        TRD_IN_ACT_ONORDER.WEEK_ID,
        TRD_IN_ACT_ONORDER.PRICE_STATUS,
        TRD_IN_ACT_ONORDER.NDC_DATE,
        TRD_IN_ACT_ONORDER.START_SHIP_DATE,
        TRD_IN_ACT_ONORDER.PO_CANCEL_DATE,
        TRD_IN_ACT_ONORDER.PO_ID,
        TRD_IN_ACT_ONORDER.TOTAL_UNITS,
        TRD_IN_ACT_ONORDER.TOTAL_COST,
        TRD_IN_ACT_ONORDER.TOTAL_RETAIL,
        TRD_IN_ACT_ONORDER.P_NBR_PACKS,
        TRD_IN_ACT_ONORDER.P_PACK_ID,
        TRD_IN_ACT_ONORDER.P_QTY_PER_PACK,
        TRD_IN_ACT_ONORDER.P_PO_TYPE,
        TRD_IN_ACT_ONORDER.P_VENDOR_NBR,
        TRD_IN_ACT_ONORDER.P_PO_VENDOR_NBR,
        TRD_IN_ACT_ONORDER.P_VENDOR_DESC,
        TRD_IN_ACT_ONORDER.PO_LN_SEQ_NUM
 FROM public.TRD_IN_ACT_ONORDER
 ORDER BY TRD_IN_ACT_ONORDER.MEMBER_ID,
          TRD_IN_ACT_ONORDER.LOCATION_ID,
          TRD_IN_ACT_ONORDER.FLOW_ID,
          TRD_IN_ACT_ONORDER.WEEK_ID,
          TRD_IN_ACT_ONORDER.PRICE_STATUS,
          TRD_IN_ACT_ONORDER.NDC_DATE,
          TRD_IN_ACT_ONORDER.START_SHIP_DATE,
          TRD_IN_ACT_ONORDER.PO_CANCEL_DATE
SEGMENTED BY hash(TRD_IN_ACT_ONORDER.TOTAL_UNITS, TRD_IN_ACT_ONORDER.TOTAL_COST, TRD_IN_ACT_ONORDER.TOTAL_RETAIL, TRD_IN_ACT_ONORDER.MEMBER_ID, TRD_IN_ACT_ONORDER.LOCATION_ID, TRD_IN_ACT_ONORDER.FLOW_ID, TRD_IN_ACT_ONORDER.WEEK_ID, TRD_IN_ACT_ONORDER.PRICE_STATUS) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_ACT_ONORDER_super /*+basename(TRD_REJ_ACT_ONORDER),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 FLOW_ID,
 WEEK_ID,
 PRICE_STATUS,
 NDC_DATE,
 START_SHIP_DATE,
 PO_CANCEL_DATE,
 PO_ID,
 TOTAL_UNITS,
 TOTAL_COST,
 TOTAL_RETAIL,
 P_NBR_PACKS,
 P_PACK_ID,
 P_QTY_PER_PACK,
 P_PO_TYPE,
 P_VENDOR_NBR,
 P_PO_VENDOR_NBR,
 P_VENDOR_DESC,
 PO_LN_SEQ_NUM,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_ACT_ONORDER.MEMBER_ID,
        TRD_REJ_ACT_ONORDER.LOCATION_ID,
        TRD_REJ_ACT_ONORDER.FLOW_ID,
        TRD_REJ_ACT_ONORDER.WEEK_ID,
        TRD_REJ_ACT_ONORDER.PRICE_STATUS,
        TRD_REJ_ACT_ONORDER.NDC_DATE,
        TRD_REJ_ACT_ONORDER.START_SHIP_DATE,
        TRD_REJ_ACT_ONORDER.PO_CANCEL_DATE,
        TRD_REJ_ACT_ONORDER.PO_ID,
        TRD_REJ_ACT_ONORDER.TOTAL_UNITS,
        TRD_REJ_ACT_ONORDER.TOTAL_COST,
        TRD_REJ_ACT_ONORDER.TOTAL_RETAIL,
        TRD_REJ_ACT_ONORDER.P_NBR_PACKS,
        TRD_REJ_ACT_ONORDER.P_PACK_ID,
        TRD_REJ_ACT_ONORDER.P_QTY_PER_PACK,
        TRD_REJ_ACT_ONORDER.P_PO_TYPE,
        TRD_REJ_ACT_ONORDER.P_VENDOR_NBR,
        TRD_REJ_ACT_ONORDER.P_PO_VENDOR_NBR,
        TRD_REJ_ACT_ONORDER.P_VENDOR_DESC,
        TRD_REJ_ACT_ONORDER.PO_LN_SEQ_NUM,
        TRD_REJ_ACT_ONORDER.REJECT_REASON
 FROM public.TRD_REJ_ACT_ONORDER
 ORDER BY TRD_REJ_ACT_ONORDER.MEMBER_ID,
          TRD_REJ_ACT_ONORDER.LOCATION_ID,
          TRD_REJ_ACT_ONORDER.FLOW_ID,
          TRD_REJ_ACT_ONORDER.WEEK_ID,
          TRD_REJ_ACT_ONORDER.PRICE_STATUS,
          TRD_REJ_ACT_ONORDER.NDC_DATE,
          TRD_REJ_ACT_ONORDER.START_SHIP_DATE,
          TRD_REJ_ACT_ONORDER.PO_CANCEL_DATE
SEGMENTED BY hash(TRD_REJ_ACT_ONORDER.TOTAL_UNITS, TRD_REJ_ACT_ONORDER.TOTAL_COST, TRD_REJ_ACT_ONORDER.TOTAL_RETAIL, TRD_REJ_ACT_ONORDER.REJECT_REASON, TRD_REJ_ACT_ONORDER.MEMBER_ID, TRD_REJ_ACT_ONORDER.LOCATION_ID, TRD_REJ_ACT_ONORDER.FLOW_ID, TRD_REJ_ACT_ONORDER.WEEK_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_REJECT_COUNTS_super /*+basename(TRD_INTERFACE_REJECT_COUNTS),createtype(L)*/ 
(
 INTERFACE_ID,
 REJECT_MESSAGE,
 REJECT_COUNT,
 TIME_STAMP,
 CREATED_AT
)
AS
 SELECT TRD_INTERFACE_REJECT_COUNTS.INTERFACE_ID,
        TRD_INTERFACE_REJECT_COUNTS.REJECT_MESSAGE,
        TRD_INTERFACE_REJECT_COUNTS.REJECT_COUNT,
        TRD_INTERFACE_REJECT_COUNTS.TIME_STAMP,
        TRD_INTERFACE_REJECT_COUNTS.CREATED_AT
 FROM public.TRD_INTERFACE_REJECT_COUNTS
 ORDER BY TRD_INTERFACE_REJECT_COUNTS.INTERFACE_ID,
          TRD_INTERFACE_REJECT_COUNTS.REJECT_MESSAGE,
          TRD_INTERFACE_REJECT_COUNTS.REJECT_COUNT,
          TRD_INTERFACE_REJECT_COUNTS.TIME_STAMP,
          TRD_INTERFACE_REJECT_COUNTS.CREATED_AT
SEGMENTED BY hash(TRD_INTERFACE_REJECT_COUNTS.REJECT_COUNT, TRD_INTERFACE_REJECT_COUNTS.CREATED_AT, TRD_INTERFACE_REJECT_COUNTS.TIME_STAMP, TRD_INTERFACE_REJECT_COUNTS.INTERFACE_ID, TRD_INTERFACE_REJECT_COUNTS.REJECT_MESSAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_OUTBOUND_REJECTS_super /*+basename(TRD_INTERFACE_OUTBOUND_REJECTS),createtype(L)*/ 
(
 INTERFACE_ID,
 REJECT_MESSAGE,
 REJECT_COUNT,
 TIME_STAMP
)
AS
 SELECT TRD_INTERFACE_OUTBOUND_REJECTS.INTERFACE_ID,
        TRD_INTERFACE_OUTBOUND_REJECTS.REJECT_MESSAGE,
        TRD_INTERFACE_OUTBOUND_REJECTS.REJECT_COUNT,
        TRD_INTERFACE_OUTBOUND_REJECTS.TIME_STAMP
 FROM public.TRD_INTERFACE_OUTBOUND_REJECTS
 ORDER BY TRD_INTERFACE_OUTBOUND_REJECTS.INTERFACE_ID
SEGMENTED BY hash(TRD_INTERFACE_OUTBOUND_REJECTS.REJECT_COUNT, TRD_INTERFACE_OUTBOUND_REJECTS.TIME_STAMP, TRD_INTERFACE_OUTBOUND_REJECTS.INTERFACE_ID, TRD_INTERFACE_OUTBOUND_REJECTS.REJECT_MESSAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_OUTBOUND_SUMMARY_super /*+basename(TRD_INTERFACE_OUTBOUND_SUMMARY),createtype(L)*/ 
(
 INTERFACE_ID,
 CURRENT_RECORD_COUNT,
 PREVIOUS_RECORD_COUNT,
 CURRENT_REJECT_COUNT,
 TIME_STAMP
)
AS
 SELECT TRD_INTERFACE_OUTBOUND_SUMMARY.INTERFACE_ID,
        TRD_INTERFACE_OUTBOUND_SUMMARY.CURRENT_RECORD_COUNT,
        TRD_INTERFACE_OUTBOUND_SUMMARY.PREVIOUS_RECORD_COUNT,
        TRD_INTERFACE_OUTBOUND_SUMMARY.CURRENT_REJECT_COUNT,
        TRD_INTERFACE_OUTBOUND_SUMMARY.TIME_STAMP
 FROM public.TRD_INTERFACE_OUTBOUND_SUMMARY
 ORDER BY TRD_INTERFACE_OUTBOUND_SUMMARY.INTERFACE_ID,
          TRD_INTERFACE_OUTBOUND_SUMMARY.CURRENT_RECORD_COUNT,
          TRD_INTERFACE_OUTBOUND_SUMMARY.PREVIOUS_RECORD_COUNT,
          TRD_INTERFACE_OUTBOUND_SUMMARY.CURRENT_REJECT_COUNT,
          TRD_INTERFACE_OUTBOUND_SUMMARY.TIME_STAMP
SEGMENTED BY hash(TRD_INTERFACE_OUTBOUND_SUMMARY.TIME_STAMP) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_COLORSWATCHES_super /*+basename(TRD_IN_VV_COLORSWATCHES),createtype(L)*/ 
(
 COLOR_ID,
 STRTYPE,
 DATASTR
)
AS
 SELECT TRD_IN_VV_COLORSWATCHES.COLOR_ID,
        TRD_IN_VV_COLORSWATCHES.STRTYPE,
        TRD_IN_VV_COLORSWATCHES.DATASTR
 FROM public.TRD_IN_VV_COLORSWATCHES
 ORDER BY TRD_IN_VV_COLORSWATCHES.COLOR_ID,
          TRD_IN_VV_COLORSWATCHES.STRTYPE,
          TRD_IN_VV_COLORSWATCHES.DATASTR
SEGMENTED BY hash(TRD_IN_VV_COLORSWATCHES.COLOR_ID, TRD_IN_VV_COLORSWATCHES.STRTYPE, TRD_IN_VV_COLORSWATCHES.DATASTR) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_TIME_HIER_super /*+basename(TRD_IN_TIME_HIER),createtype(L)*/ 
(
 DATE_ID,
 WEEK_ID,
 MONTH_ID,
 QUARTER_ID,
 SEASON_ID,
 YEAR_ID
)
AS
 SELECT TRD_IN_TIME_HIER.DATE_ID,
        TRD_IN_TIME_HIER.WEEK_ID,
        TRD_IN_TIME_HIER.MONTH_ID,
        TRD_IN_TIME_HIER.QUARTER_ID,
        TRD_IN_TIME_HIER.SEASON_ID,
        TRD_IN_TIME_HIER.YEAR_ID
 FROM public.TRD_IN_TIME_HIER
 ORDER BY TRD_IN_TIME_HIER.DATE_ID,
          TRD_IN_TIME_HIER.WEEK_ID,
          TRD_IN_TIME_HIER.MONTH_ID,
          TRD_IN_TIME_HIER.QUARTER_ID,
          TRD_IN_TIME_HIER.SEASON_ID,
          TRD_IN_TIME_HIER.YEAR_ID
SEGMENTED BY hash(TRD_IN_TIME_HIER.DATE_ID, TRD_IN_TIME_HIER.WEEK_ID, TRD_IN_TIME_HIER.MONTH_ID, TRD_IN_TIME_HIER.QUARTER_ID, TRD_IN_TIME_HIER.SEASON_ID, TRD_IN_TIME_HIER.YEAR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRODLIFE_super /*+basename(TRD_IN_PRODLIFE),createtype(L)*/ 
(
 id,
 name,
 description,
 levelid,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT TRD_IN_PRODLIFE.id,
        TRD_IN_PRODLIFE.name,
        TRD_IN_PRODLIFE.description,
        TRD_IN_PRODLIFE.levelid,
        TRD_IN_PRODLIFE.eventdate,
        TRD_IN_PRODLIFE.version_id,
        TRD_IN_PRODLIFE.created_at,
        TRD_IN_PRODLIFE.created_by,
        TRD_IN_PRODLIFE.updated_at,
        TRD_IN_PRODLIFE.updated_by,
        TRD_IN_PRODLIFE.record_state
 FROM public.TRD_IN_PRODLIFE
 ORDER BY TRD_IN_PRODLIFE.id,
          TRD_IN_PRODLIFE.name,
          TRD_IN_PRODLIFE.description,
          TRD_IN_PRODLIFE.levelid,
          TRD_IN_PRODLIFE.eventdate,
          TRD_IN_PRODLIFE.version_id,
          TRD_IN_PRODLIFE.created_at,
          TRD_IN_PRODLIFE.created_by
SEGMENTED BY hash(TRD_IN_PRODLIFE.eventdate, TRD_IN_PRODLIFE.version_id, TRD_IN_PRODLIFE.created_at, TRD_IN_PRODLIFE.created_by, TRD_IN_PRODLIFE.updated_at, TRD_IN_PRODLIFE.updated_by, TRD_IN_PRODLIFE.record_state, TRD_IN_PRODLIFE.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRODLIFE_STD_super /*+basename(TRD_IN_PRODLIFE_STD),createtype(L)*/ 
(
 id,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT TRD_IN_PRODLIFE_STD.id,
        TRD_IN_PRODLIFE_STD.eventdate,
        TRD_IN_PRODLIFE_STD.version_id,
        TRD_IN_PRODLIFE_STD.created_at,
        TRD_IN_PRODLIFE_STD.created_by,
        TRD_IN_PRODLIFE_STD.updated_at,
        TRD_IN_PRODLIFE_STD.updated_by,
        TRD_IN_PRODLIFE_STD.record_state
 FROM public.TRD_IN_PRODLIFE_STD
 ORDER BY TRD_IN_PRODLIFE_STD.id,
          TRD_IN_PRODLIFE_STD.eventdate,
          TRD_IN_PRODLIFE_STD.version_id,
          TRD_IN_PRODLIFE_STD.created_at,
          TRD_IN_PRODLIFE_STD.created_by,
          TRD_IN_PRODLIFE_STD.updated_at,
          TRD_IN_PRODLIFE_STD.updated_by,
          TRD_IN_PRODLIFE_STD.record_state
SEGMENTED BY hash(TRD_IN_PRODLIFE_STD.eventdate, TRD_IN_PRODLIFE_STD.version_id, TRD_IN_PRODLIFE_STD.created_at, TRD_IN_PRODLIFE_STD.updated_at, TRD_IN_PRODLIFE_STD.record_state, TRD_IN_PRODLIFE_STD.id, TRD_IN_PRODLIFE_STD.created_by, TRD_IN_PRODLIFE_STD.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_CLUSTER_super /*+basename(TRD_IN_CLUSTER),createtype(L)*/ 
(
 id,
 name,
 description,
 levelid,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT TRD_IN_CLUSTER.id,
        TRD_IN_CLUSTER.name,
        TRD_IN_CLUSTER.description,
        TRD_IN_CLUSTER.levelid,
        TRD_IN_CLUSTER.eventdate,
        TRD_IN_CLUSTER.version_id,
        TRD_IN_CLUSTER.created_at,
        TRD_IN_CLUSTER.created_by,
        TRD_IN_CLUSTER.updated_at,
        TRD_IN_CLUSTER.updated_by,
        TRD_IN_CLUSTER.record_state
 FROM public.TRD_IN_CLUSTER
 ORDER BY TRD_IN_CLUSTER.id,
          TRD_IN_CLUSTER.name,
          TRD_IN_CLUSTER.description,
          TRD_IN_CLUSTER.levelid,
          TRD_IN_CLUSTER.eventdate,
          TRD_IN_CLUSTER.version_id,
          TRD_IN_CLUSTER.created_at,
          TRD_IN_CLUSTER.created_by
SEGMENTED BY hash(TRD_IN_CLUSTER.eventdate, TRD_IN_CLUSTER.version_id, TRD_IN_CLUSTER.created_at, TRD_IN_CLUSTER.created_by, TRD_IN_CLUSTER.updated_at, TRD_IN_CLUSTER.updated_by, TRD_IN_CLUSTER.record_state, TRD_IN_CLUSTER.levelid) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_CLUSTER_STD_super /*+basename(TRD_IN_CLUSTER_STD),createtype(L)*/ 
(
 id,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT TRD_IN_CLUSTER_STD.id,
        TRD_IN_CLUSTER_STD.eventdate,
        TRD_IN_CLUSTER_STD.version_id,
        TRD_IN_CLUSTER_STD.created_at,
        TRD_IN_CLUSTER_STD.created_by,
        TRD_IN_CLUSTER_STD.updated_at,
        TRD_IN_CLUSTER_STD.updated_by,
        TRD_IN_CLUSTER_STD.record_state
 FROM public.TRD_IN_CLUSTER_STD
 ORDER BY TRD_IN_CLUSTER_STD.id,
          TRD_IN_CLUSTER_STD.eventdate,
          TRD_IN_CLUSTER_STD.version_id,
          TRD_IN_CLUSTER_STD.created_at,
          TRD_IN_CLUSTER_STD.created_by,
          TRD_IN_CLUSTER_STD.updated_at,
          TRD_IN_CLUSTER_STD.updated_by,
          TRD_IN_CLUSTER_STD.record_state
SEGMENTED BY hash(TRD_IN_CLUSTER_STD.eventdate, TRD_IN_CLUSTER_STD.version_id, TRD_IN_CLUSTER_STD.created_at, TRD_IN_CLUSTER_STD.created_by, TRD_IN_CLUSTER_STD.updated_at, TRD_IN_CLUSTER_STD.updated_by, TRD_IN_CLUSTER_STD.record_state, TRD_IN_CLUSTER_STD.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INT_ACT_WEEKLYINVENTORY_super /*+basename(TRD_INT_ACT_WEEKLYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 "TIME",
 VND_TO_DC_RCT_R,
 VND_TO_DC_RCT_U,
 VND_TO_DC_RCT_C,
 DC_TO_STR_RCT_R,
 DC_TO_STR_RCT_U,
 DC_TO_STR_RCT_C,
 INV_ADJUSTMENT_R,
 INV_ADJUSTMENT_U,
 INV_ADJUSTMENT_C,
 MOS_R,
 MOS_U,
 MOS_C,
 SHRINK_R,
 SHRINK_U,
 SHRINK_C,
 XFER_IN_R,
 XFER_IN_U,
 XFER_IN_C,
 XFER_OUT_R,
 XFER_OUT_U,
 XFER_OUT_C,
 STORE_TO_WEB_R,
 STORE_TO_WEB_U,
 STORE_TO_WEB_C,
 WEB_TO_STORE_R,
 WEB_TO_STORE_U,
 WEB_TO_STORE_C,
 CREATED_AT
)
AS
 SELECT TRD_INT_ACT_WEEKLYINVENTORY.MEMBER_ID,
        TRD_INT_ACT_WEEKLYINVENTORY.LOCATION_ID,
        TRD_INT_ACT_WEEKLYINVENTORY.PRICE_STATUS,
        TRD_INT_ACT_WEEKLYINVENTORY."TIME",
        TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R,
        TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U,
        TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C,
        TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R,
        TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U,
        TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C,
        TRD_INT_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R,
        TRD_INT_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U,
        TRD_INT_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_C,
        TRD_INT_ACT_WEEKLYINVENTORY.MOS_R,
        TRD_INT_ACT_WEEKLYINVENTORY.MOS_U,
        TRD_INT_ACT_WEEKLYINVENTORY.MOS_C,
        TRD_INT_ACT_WEEKLYINVENTORY.SHRINK_R,
        TRD_INT_ACT_WEEKLYINVENTORY.SHRINK_U,
        TRD_INT_ACT_WEEKLYINVENTORY.SHRINK_C,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_IN_R,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_IN_U,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_IN_C,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_OUT_R,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_OUT_U,
        TRD_INT_ACT_WEEKLYINVENTORY.XFER_OUT_C,
        TRD_INT_ACT_WEEKLYINVENTORY.STORE_TO_WEB_R,
        TRD_INT_ACT_WEEKLYINVENTORY.STORE_TO_WEB_U,
        TRD_INT_ACT_WEEKLYINVENTORY.STORE_TO_WEB_C,
        TRD_INT_ACT_WEEKLYINVENTORY.WEB_TO_STORE_R,
        TRD_INT_ACT_WEEKLYINVENTORY.WEB_TO_STORE_U,
        TRD_INT_ACT_WEEKLYINVENTORY.WEB_TO_STORE_C,
        TRD_INT_ACT_WEEKLYINVENTORY.CREATED_AT
 FROM public.TRD_INT_ACT_WEEKLYINVENTORY
 ORDER BY TRD_INT_ACT_WEEKLYINVENTORY.MEMBER_ID
SEGMENTED BY hash(TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R, TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U, TRD_INT_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C, TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R, TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U, TRD_INT_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C, TRD_INT_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R, TRD_INT_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INT_ACT_DAILYINVENTORY_super /*+basename(TRD_INT_ACT_DAILYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP,
 CREATED_AT
)
AS
 SELECT TRD_INT_ACT_DAILYINVENTORY.MEMBER_ID,
        TRD_INT_ACT_DAILYINVENTORY.LOCATION_ID,
        TRD_INT_ACT_DAILYINVENTORY.PRICE_STATUS,
        TRD_INT_ACT_DAILYINVENTORY.COMP_STATUS,
        TRD_INT_ACT_DAILYINVENTORY."TIME",
        TRD_INT_ACT_DAILYINVENTORY.EOH_R,
        TRD_INT_ACT_DAILYINVENTORY.EOH_U,
        TRD_INT_ACT_DAILYINVENTORY.EOH_C,
        TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_R,
        TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_U,
        TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_C,
        TRD_INT_ACT_DAILYINVENTORY.AVG_UNIT_COST,
        TRD_INT_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE,
        TRD_INT_ACT_DAILYINVENTORY.CURRENT_TICKET_PRICE,
        TRD_INT_ACT_DAILYINVENTORY.PERM_MD_R,
        TRD_INT_ACT_DAILYINVENTORY.PERM_MD_C,
        TRD_INT_ACT_DAILYINVENTORY.PERM_MD_U,
        TRD_INT_ACT_DAILYINVENTORY.PERM_MD_R_CSP,
        TRD_INT_ACT_DAILYINVENTORY.CREATED_AT
 FROM public.TRD_INT_ACT_DAILYINVENTORY
 ORDER BY TRD_INT_ACT_DAILYINVENTORY.MEMBER_ID,
          TRD_INT_ACT_DAILYINVENTORY.LOCATION_ID,
          TRD_INT_ACT_DAILYINVENTORY.PRICE_STATUS,
          TRD_INT_ACT_DAILYINVENTORY."TIME",
          TRD_INT_ACT_DAILYINVENTORY.EOH_R,
          TRD_INT_ACT_DAILYINVENTORY.EOH_U,
          TRD_INT_ACT_DAILYINVENTORY.EOH_C,
          TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_R
SEGMENTED BY hash(TRD_INT_ACT_DAILYINVENTORY.EOH_R, TRD_INT_ACT_DAILYINVENTORY.EOH_U, TRD_INT_ACT_DAILYINVENTORY.EOH_C, TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_R, TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_U, TRD_INT_ACT_DAILYINVENTORY.EOP_INTRANSIT_C, TRD_INT_ACT_DAILYINVENTORY.AVG_UNIT_COST, TRD_INT_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INT_ACT_SALES_TRANSACTIONS_super /*+basename(TRD_INT_ACT_SALES_TRANSACTIONS),createtype(L)*/ 
(
 TRANSACTION_ID,
 CUSTOMER_ID,
 MEMBER_ID,
 CLIENT_MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R_CSP,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 BOPIS_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R_CSP,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C,
 CREATED_AT
)
AS
 SELECT TRD_INT_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.CUSTOMER_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.MEMBER_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.CLIENT_MEMBER_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.DAY_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.LOCATION_ID,
        TRD_INT_ACT_SALES_TRANSACTIONS.COMP_STATUS,
        TRD_INT_ACT_SALES_TRANSACTIONS.PRICE_STATUS,
        TRD_INT_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE,
        TRD_INT_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE,
        TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP,
        TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R,
        TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U,
        TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C,
        TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_R_CSP,
        TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_R,
        TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_U,
        TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_C,
        TRD_INT_ACT_SALES_TRANSACTIONS.BOPIS_SALES_R_CSP,
        TRD_INT_ACT_SALES_TRANSACTIONS.BOPIS_SALES_R,
        TRD_INT_ACT_SALES_TRANSACTIONS.BOPIS_SALES_U,
        TRD_INT_ACT_SALES_TRANSACTIONS.BOPIS_SALES_C,
        TRD_INT_ACT_SALES_TRANSACTIONS.SFS_SALES_R_CSP,
        TRD_INT_ACT_SALES_TRANSACTIONS.SFS_SALES_R,
        TRD_INT_ACT_SALES_TRANSACTIONS.SFS_SALES_U,
        TRD_INT_ACT_SALES_TRANSACTIONS.SFS_SALES_C,
        TRD_INT_ACT_SALES_TRANSACTIONS.CREATED_AT
 FROM public.TRD_INT_ACT_SALES_TRANSACTIONS
 ORDER BY TRD_INT_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.CUSTOMER_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.MEMBER_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.CLIENT_MEMBER_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.DAY_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.LOCATION_ID,
          TRD_INT_ACT_SALES_TRANSACTIONS.COMP_STATUS,
          TRD_INT_ACT_SALES_TRANSACTIONS.PRICE_STATUS
SEGMENTED BY hash(TRD_INT_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE, TRD_INT_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE, TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP, TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R, TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U, TRD_INT_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C, TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_R_CSP, TRD_INT_ACT_SALES_TRANSACTIONS.RETURN_SALES_R) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_INTERN_SERVICEPARAMS_super /*+basename(TRD_IN_INTERN_SERVICEPARAMS),createtype(L)*/ 
(
 id,
 type,
 value
)
AS
 SELECT TRD_IN_INTERN_SERVICEPARAMS.id,
        TRD_IN_INTERN_SERVICEPARAMS.type,
        TRD_IN_INTERN_SERVICEPARAMS.value
 FROM public.TRD_IN_INTERN_SERVICEPARAMS
 ORDER BY TRD_IN_INTERN_SERVICEPARAMS.id,
          TRD_IN_INTERN_SERVICEPARAMS.type,
          TRD_IN_INTERN_SERVICEPARAMS.value
SEGMENTED BY hash(TRD_IN_INTERN_SERVICEPARAMS.id, TRD_IN_INTERN_SERVICEPARAMS.type, TRD_IN_INTERN_SERVICEPARAMS.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INTERFACE_VALIDATION_FAILURES_super /*+basename(TRD_INTERFACE_VALIDATION_FAILURES),createtype(L)*/ 
(
 FAILURE_MESSAGE,
 INTERFACE_ID,
 TIME_STAMP,
 CREATED_AT
)
AS
 SELECT TRD_INTERFACE_VALIDATION_FAILURES.FAILURE_MESSAGE,
        TRD_INTERFACE_VALIDATION_FAILURES.INTERFACE_ID,
        TRD_INTERFACE_VALIDATION_FAILURES.TIME_STAMP,
        TRD_INTERFACE_VALIDATION_FAILURES.CREATED_AT
 FROM public.TRD_INTERFACE_VALIDATION_FAILURES
 ORDER BY TRD_INTERFACE_VALIDATION_FAILURES.INTERFACE_ID
SEGMENTED BY hash(TRD_INTERFACE_VALIDATION_FAILURES.CREATED_AT, TRD_INTERFACE_VALIDATION_FAILURES.TIME_STAMP, TRD_INTERFACE_VALIDATION_FAILURES.INTERFACE_ID, TRD_INTERFACE_VALIDATION_FAILURES.FAILURE_MESSAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_IMG_URL_20240408_super /*+basename(TRD_IN_IMG_URL_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 URL
)
AS
 SELECT TRD_IN_IMG_URL_20240408.MEMBER_ID,
        TRD_IN_IMG_URL_20240408.URL
 FROM public.TRD_IN_IMG_URL_20240408
 ORDER BY TRD_IN_IMG_URL_20240408.MEMBER_ID,
          TRD_IN_IMG_URL_20240408.URL
SEGMENTED BY hash(TRD_IN_IMG_URL_20240408.MEMBER_ID, TRD_IN_IMG_URL_20240408.URL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_LOC_HIER_20240408_super /*+basename(TRD_IN_LOC_HIER_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4
)
AS
 SELECT TRD_IN_LOC_HIER_20240408.MEMBER_ID,
        TRD_IN_LOC_HIER_20240408.ANCESTOR0,
        TRD_IN_LOC_HIER_20240408.ANCESTOR1,
        TRD_IN_LOC_HIER_20240408.ANCESTOR2,
        TRD_IN_LOC_HIER_20240408.ANCESTOR3,
        TRD_IN_LOC_HIER_20240408.ANCESTOR4
 FROM public.TRD_IN_LOC_HIER_20240408
 ORDER BY TRD_IN_LOC_HIER_20240408.MEMBER_ID,
          TRD_IN_LOC_HIER_20240408.ANCESTOR0,
          TRD_IN_LOC_HIER_20240408.ANCESTOR1,
          TRD_IN_LOC_HIER_20240408.ANCESTOR2,
          TRD_IN_LOC_HIER_20240408.ANCESTOR3,
          TRD_IN_LOC_HIER_20240408.ANCESTOR4
SEGMENTED BY hash(TRD_IN_LOC_HIER_20240408.MEMBER_ID, TRD_IN_LOC_HIER_20240408.ANCESTOR0, TRD_IN_LOC_HIER_20240408.ANCESTOR1, TRD_IN_LOC_HIER_20240408.ANCESTOR2, TRD_IN_LOC_HIER_20240408.ANCESTOR3, TRD_IN_LOC_HIER_20240408.ANCESTOR4) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_LOC_MASTER_20240408_super /*+basename(TRD_IN_LOC_MASTER_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 LOC_LEVEL
)
AS
 SELECT TRD_IN_LOC_MASTER_20240408.MEMBER_ID,
        TRD_IN_LOC_MASTER_20240408.MEMBER_NAME,
        TRD_IN_LOC_MASTER_20240408.MEMBER_DESC,
        TRD_IN_LOC_MASTER_20240408.LOC_LEVEL
 FROM public.TRD_IN_LOC_MASTER_20240408
 ORDER BY TRD_IN_LOC_MASTER_20240408.MEMBER_ID,
          TRD_IN_LOC_MASTER_20240408.MEMBER_NAME,
          TRD_IN_LOC_MASTER_20240408.MEMBER_DESC,
          TRD_IN_LOC_MASTER_20240408.LOC_LEVEL
SEGMENTED BY hash(TRD_IN_LOC_MASTER_20240408.MEMBER_ID, TRD_IN_LOC_MASTER_20240408.MEMBER_NAME, TRD_IN_LOC_MASTER_20240408.MEMBER_DESC, TRD_IN_LOC_MASTER_20240408.LOC_LEVEL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSKU_20240408_super /*+basename(TRD_IN_PRD_ATTRSKU_20240408),createtype(A)*/ 
(
 ITEM,
 ITEM_DIFF_2,
 ITEM_DIFF_3,
 STYLECOLORSIZE_CREATE_DATE
)
AS
 SELECT TRD_IN_PRD_ATTRSKU_20240408.ITEM,
        TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_2,
        TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_3,
        TRD_IN_PRD_ATTRSKU_20240408.STYLECOLORSIZE_CREATE_DATE
 FROM public.TRD_IN_PRD_ATTRSKU_20240408
 ORDER BY TRD_IN_PRD_ATTRSKU_20240408.ITEM,
          TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_2,
          TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_3,
          TRD_IN_PRD_ATTRSKU_20240408.STYLECOLORSIZE_CREATE_DATE
SEGMENTED BY hash(TRD_IN_PRD_ATTRSKU_20240408.ITEM, TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_2, TRD_IN_PRD_ATTRSKU_20240408.ITEM_DIFF_3, TRD_IN_PRD_ATTRSKU_20240408.STYLECOLORSIZE_CREATE_DATE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSTYLE_20240408_super /*+basename(TRD_IN_PRD_ATTRSTYLE_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 KNIT_OR_WOVEN,
 FABRICATION,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 BODY_STYLE_SILHOUETTE,
 OCCASION_USAGE,
 DETAIL,
 FINISH_STYLE,
 PRIVATE_LABEL,
 LICENSE,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 ITEM_TYPE,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 V_360_SMOOTHING,
 FRANCHISE,
 KEY_ITEM,
 SINGLE_VS_MULTI_PACK,
 TICKET_TYPE,
 VPN,
 SIZE_RANGE,
 RMS_STYLECOLOR_CREATE_DATE,
 STYLE_ATTRIBUTE_1,
 STYLE_ATTRIBUTE_2,
 STYLE_ATTRIBUTE_3,
 STYLE_ATTRIBUTE_4,
 STYLE_ATTRIBUTE_5,
 STYLE_ATTRIBUTE_6,
 STYLE_ATTRIBUTE_7,
 STYLE_ATTRIBUTE_8
)
AS
 SELECT TRD_IN_PRD_ATTRSTYLE_20240408.MEMBER_ID,
        TRD_IN_PRD_ATTRSTYLE_20240408.KNIT_OR_WOVEN,
        TRD_IN_PRD_ATTRSTYLE_20240408.FABRICATION,
        TRD_IN_PRD_ATTRSTYLE_20240408.SLEEVE_LENGTH,
        TRD_IN_PRD_ATTRSTYLE_20240408.LEG_OPENING,
        TRD_IN_PRD_ATTRSTYLE_20240408.BRAND,
        TRD_IN_PRD_ATTRSTYLE_20240408.BODY_STYLE_SILHOUETTE,
        TRD_IN_PRD_ATTRSTYLE_20240408.OCCASION_USAGE,
        TRD_IN_PRD_ATTRSTYLE_20240408.DETAIL,
        TRD_IN_PRD_ATTRSTYLE_20240408.FINISH_STYLE,
        TRD_IN_PRD_ATTRSTYLE_20240408.PRIVATE_LABEL,
        TRD_IN_PRD_ATTRSTYLE_20240408.LICENSE,
        TRD_IN_PRD_ATTRSTYLE_20240408.LICENSE_VS_NON_LICENSED,
        TRD_IN_PRD_ATTRSTYLE_20240408.HAZMAT_CODE,
        TRD_IN_PRD_ATTRSTYLE_20240408.PROP_65_WARNING,
        TRD_IN_PRD_ATTRSTYLE_20240408.MATERIAL_CONTENT,
        TRD_IN_PRD_ATTRSTYLE_20240408.ITEM_TYPE,
        TRD_IN_PRD_ATTRSTYLE_20240408.DWRISE,
        TRD_IN_PRD_ATTRSTYLE_20240408.LENGTH,
        TRD_IN_PRD_ATTRSTYLE_20240408.NECKLINE,
        TRD_IN_PRD_ATTRSTYLE_20240408.TOESHAPE,
        TRD_IN_PRD_ATTRSTYLE_20240408.HEEL_HEIGHT,
        TRD_IN_PRD_ATTRSTYLE_20240408.BOTTOM_LENGTH,
        TRD_IN_PRD_ATTRSTYLE_20240408.V_360_SMOOTHING,
        TRD_IN_PRD_ATTRSTYLE_20240408.FRANCHISE,
        TRD_IN_PRD_ATTRSTYLE_20240408.KEY_ITEM,
        TRD_IN_PRD_ATTRSTYLE_20240408.SINGLE_VS_MULTI_PACK,
        TRD_IN_PRD_ATTRSTYLE_20240408.TICKET_TYPE,
        TRD_IN_PRD_ATTRSTYLE_20240408.VPN,
        TRD_IN_PRD_ATTRSTYLE_20240408.SIZE_RANGE,
        TRD_IN_PRD_ATTRSTYLE_20240408.RMS_STYLECOLOR_CREATE_DATE,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_1,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_2,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_3,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_4,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_5,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_6,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_7,
        TRD_IN_PRD_ATTRSTYLE_20240408.STYLE_ATTRIBUTE_8
 FROM public.TRD_IN_PRD_ATTRSTYLE_20240408
 ORDER BY TRD_IN_PRD_ATTRSTYLE_20240408.MEMBER_ID,
          TRD_IN_PRD_ATTRSTYLE_20240408.KNIT_OR_WOVEN,
          TRD_IN_PRD_ATTRSTYLE_20240408.FABRICATION,
          TRD_IN_PRD_ATTRSTYLE_20240408.SLEEVE_LENGTH,
          TRD_IN_PRD_ATTRSTYLE_20240408.LEG_OPENING,
          TRD_IN_PRD_ATTRSTYLE_20240408.BRAND,
          TRD_IN_PRD_ATTRSTYLE_20240408.BODY_STYLE_SILHOUETTE,
          TRD_IN_PRD_ATTRSTYLE_20240408.OCCASION_USAGE
SEGMENTED BY hash(TRD_IN_PRD_ATTRSTYLE_20240408.MEMBER_ID, TRD_IN_PRD_ATTRSTYLE_20240408.KNIT_OR_WOVEN, TRD_IN_PRD_ATTRSTYLE_20240408.FABRICATION, TRD_IN_PRD_ATTRSTYLE_20240408.SLEEVE_LENGTH, TRD_IN_PRD_ATTRSTYLE_20240408.LEG_OPENING, TRD_IN_PRD_ATTRSTYLE_20240408.BRAND, TRD_IN_PRD_ATTRSTYLE_20240408.BODY_STYLE_SILHOUETTE, TRD_IN_PRD_ATTRSTYLE_20240408.OCCASION_USAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSTYLECLR_20240408_super /*+basename(TRD_IN_PRD_ATTRSTYLECLR_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 ITEM_DIFF_1,
 UNIT_RETAIL,
 UNIT_RETAIL_CAD,
 PATTERN,
 GRAPHIC,
 FASHION_BASIC,
 HOLIDAY,
 PROPERTY_TYPE,
 INTERNET_EXCLUSIVE,
 WEB_COLOR_DISCRIPTION,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 SEASON_CODE,
 DTR,
 DW_COLOR_FAMILY,
 CHANNEL_REORDER,
 TICKET_SEASON_CODE,
 SUB_PROGRAMS,
 MUSIC_GENRE,
 CLEARANCE_STR_PRODUCT,
 PO_SUPPLIER,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 ROYALTY,
 DUTY,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 PRIMARY_SUPPLIER,
 SUB_BRAND,
 PATTERN_TYPE,
 POP_PRINT_NEUTRAL,
 DEBUT_SEASON_CODE,
 MATCHBACK,
 PRIMARY_COLLECTION,
 SECONDARY_COLLECTION,
 VPN_COLOR,
 ORIG_UNIT_RETAIL,
 ORIG_UNIT_RETAIL_CAD,
 FIRST_REC_WEEK,
 FIRST_INV_WEEK,
 FIRST_SALE_WEEK,
 FIRST_MD_WEEK,
 LAST_MD_WEEK,
 LAST_REC_WEEK,
 STORE_PRICE_STATUS,
 IFC_PRICE_STATUS,
 OMNI_PRICE_TYPE,
 STYLECOLOR_CREATE_DATE,
 PRICE_BAND,
 GOOD_BETTER_BEST,
 STYLECOLOR_ATTRIBUTE_1,
 STYLECOLOR_ATTRIBUTE_2,
 STYLECOLOR_ATTRIBUTE_3,
 STYLECOLOR_ATTRIBUTE_4,
 STYLECOLOR_ATTRIBUTE_5,
 STYLECOLOR_ATTRIBUTE_6,
 STYLECOLOR_ATTRIBUTE_7,
 STYLECOLOR_ATTRIBUTE_8,
 STYLECOLOR_ATTRIBUTE_9,
 STYLECOLOR_ATTRIBUTE_10,
 STYLECOLOR_ATTRIBUTE_11,
 STYLECOLOR_ATTRIBUTE_12
)
AS
 SELECT TRD_IN_PRD_ATTRSTYLECLR_20240408.MEMBER_ID,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.ITEM_DIFF_1,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL_CAD,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PATTERN,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.GRAPHIC,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FASHION_BASIC,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.HOLIDAY,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PROPERTY_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.INTERNET_EXCLUSIVE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.WEB_COLOR_DISCRIPTION,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.EXPORT_HTS,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.DTR,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.DW_COLOR_FAMILY,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.CHANNEL_REORDER,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.TICKET_SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.SUB_PROGRAMS,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.MUSIC_GENRE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.CLEARANCE_STR_PRODUCT,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PO_SUPPLIER,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.ORIGIN_COUNTRY_ID,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.COUNTRY_OF_SOURCING,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.COUNTRY_OF_MANUFACTURING,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_COST,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FREIGHT,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.ROYALTY,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.DUTY,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.SHIP_METHOD,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.LADING_PORT,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.HTS,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PRIMARY_SUPPLIER,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.SUB_BRAND,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PATTERN_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.POP_PRINT_NEUTRAL,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.DEBUT_SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.MATCHBACK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PRIMARY_COLLECTION,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.SECONDARY_COLLECTION,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.VPN_COLOR,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.ORIG_UNIT_RETAIL,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.ORIG_UNIT_RETAIL_CAD,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FIRST_REC_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FIRST_INV_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FIRST_SALE_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.FIRST_MD_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.LAST_MD_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.LAST_REC_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STORE_PRICE_STATUS,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.IFC_PRICE_STATUS,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.OMNI_PRICE_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_CREATE_DATE,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.PRICE_BAND,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.GOOD_BETTER_BEST,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_1,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_2,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_3,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_4,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_5,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_6,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_7,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_8,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_9,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_10,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_11,
        TRD_IN_PRD_ATTRSTYLECLR_20240408.STYLECOLOR_ATTRIBUTE_12
 FROM public.TRD_IN_PRD_ATTRSTYLECLR_20240408
 ORDER BY TRD_IN_PRD_ATTRSTYLECLR_20240408.MEMBER_ID,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.ITEM_DIFF_1,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL_CAD,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.PATTERN,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.GRAPHIC,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.FASHION_BASIC,
          TRD_IN_PRD_ATTRSTYLECLR_20240408.HOLIDAY
SEGMENTED BY hash(TRD_IN_PRD_ATTRSTYLECLR_20240408.MEMBER_ID, TRD_IN_PRD_ATTRSTYLECLR_20240408.ITEM_DIFF_1, TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL, TRD_IN_PRD_ATTRSTYLECLR_20240408.UNIT_RETAIL_CAD, TRD_IN_PRD_ATTRSTYLECLR_20240408.PATTERN, TRD_IN_PRD_ATTRSTYLECLR_20240408.GRAPHIC, TRD_IN_PRD_ATTRSTYLECLR_20240408.FASHION_BASIC, TRD_IN_PRD_ATTRSTYLECLR_20240408.HOLIDAY) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_HIER_20240408_super /*+basename(TRD_IN_PRD_HIER_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 ANCESTOR5,
 ANCESTOR6,
 ANCESTOR7
)
AS
 SELECT TRD_IN_PRD_HIER_20240408.MEMBER_ID,
        TRD_IN_PRD_HIER_20240408.ANCESTOR0,
        TRD_IN_PRD_HIER_20240408.ANCESTOR1,
        TRD_IN_PRD_HIER_20240408.ANCESTOR2,
        TRD_IN_PRD_HIER_20240408.ANCESTOR3,
        TRD_IN_PRD_HIER_20240408.ANCESTOR4,
        TRD_IN_PRD_HIER_20240408.ANCESTOR5,
        TRD_IN_PRD_HIER_20240408.ANCESTOR6,
        TRD_IN_PRD_HIER_20240408.ANCESTOR7
 FROM public.TRD_IN_PRD_HIER_20240408
 ORDER BY TRD_IN_PRD_HIER_20240408.MEMBER_ID,
          TRD_IN_PRD_HIER_20240408.ANCESTOR0,
          TRD_IN_PRD_HIER_20240408.ANCESTOR1,
          TRD_IN_PRD_HIER_20240408.ANCESTOR2,
          TRD_IN_PRD_HIER_20240408.ANCESTOR3,
          TRD_IN_PRD_HIER_20240408.ANCESTOR4,
          TRD_IN_PRD_HIER_20240408.ANCESTOR5,
          TRD_IN_PRD_HIER_20240408.ANCESTOR6
SEGMENTED BY hash(TRD_IN_PRD_HIER_20240408.MEMBER_ID, TRD_IN_PRD_HIER_20240408.ANCESTOR0, TRD_IN_PRD_HIER_20240408.ANCESTOR1, TRD_IN_PRD_HIER_20240408.ANCESTOR2, TRD_IN_PRD_HIER_20240408.ANCESTOR3, TRD_IN_PRD_HIER_20240408.ANCESTOR4, TRD_IN_PRD_HIER_20240408.ANCESTOR5, TRD_IN_PRD_HIER_20240408.ANCESTOR6) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_MASTER_20240408_super /*+basename(TRD_IN_PRD_MASTER_20240408),createtype(A)*/ 
(
 MEMBER_ID,
 S5_ID,
 MEMBER_NAME,
 MEMBER_DESC,
 PRODUCT_LEVEL
)
AS
 SELECT TRD_IN_PRD_MASTER_20240408.MEMBER_ID,
        TRD_IN_PRD_MASTER_20240408.S5_ID,
        TRD_IN_PRD_MASTER_20240408.MEMBER_NAME,
        TRD_IN_PRD_MASTER_20240408.MEMBER_DESC,
        TRD_IN_PRD_MASTER_20240408.PRODUCT_LEVEL
 FROM public.TRD_IN_PRD_MASTER_20240408
 ORDER BY TRD_IN_PRD_MASTER_20240408.MEMBER_ID,
          TRD_IN_PRD_MASTER_20240408.S5_ID,
          TRD_IN_PRD_MASTER_20240408.MEMBER_NAME,
          TRD_IN_PRD_MASTER_20240408.MEMBER_DESC,
          TRD_IN_PRD_MASTER_20240408.PRODUCT_LEVEL
SEGMENTED BY hash(TRD_IN_PRD_MASTER_20240408.MEMBER_ID, TRD_IN_PRD_MASTER_20240408.S5_ID, TRD_IN_PRD_MASTER_20240408.MEMBER_NAME, TRD_IN_PRD_MASTER_20240408.MEMBER_DESC, TRD_IN_PRD_MASTER_20240408.PRODUCT_LEVEL) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_ATTRVALIDVALUES_20240408_super /*+basename(TRD_IN_VV_ATTRVALIDVALUES_20240408),createtype(A)*/ 
(
 ATTRIBUTE_ID,
 ATTRIBUTE_DESC,
 ATTRIBUTE_VALUE,
 ATTRIBUTE_VALUE_DESC
)
AS
 SELECT TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_ID,
        TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_DESC,
        TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE,
        TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE_DESC
 FROM public.TRD_IN_VV_ATTRVALIDVALUES_20240408
 ORDER BY TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_ID,
          TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_DESC,
          TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE,
          TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE_DESC
SEGMENTED BY hash(TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_ID, TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_DESC, TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE, TRD_IN_VV_ATTRVALIDVALUES_20240408.ATTRIBUTE_VALUE_DESC) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408_super /*+basename(TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408),createtype(A)*/ 
(
 ATTRIBUTE_ID,
 ATTRIBUTE_NAME,
 SEQ_NO,
 DEPT,
 CLASS,
 SUBCLASS,
 REQUIRED_IND
)
AS
 SELECT TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_ID,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_NAME,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SEQ_NO,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.DEPT,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.CLASS,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SUBCLASS,
        TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.REQUIRED_IND
 FROM public.TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408
 ORDER BY TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_ID,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_NAME,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SEQ_NO,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.DEPT,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.CLASS,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SUBCLASS,
          TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.REQUIRED_IND
SEGMENTED BY hash(TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_ID, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.ATTRIBUTE_NAME, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SEQ_NO, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.DEPT, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.CLASS, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.SUBCLASS, TRD_IN_VV_ATTRVALIDVALUESASSOCIATION_20240408.REQUIRED_IND) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_COLORMAPPING_20240408_super /*+basename(TRD_IN_VV_COLORMAPPING_20240408),createtype(A)*/ 
(
 COLOR_ID,
 COLOR_DESCRIPTION,
 COLOR_CODE,
 DW_COLOR_FAMILY
)
AS
 SELECT TRD_IN_VV_COLORMAPPING_20240408.COLOR_ID,
        TRD_IN_VV_COLORMAPPING_20240408.COLOR_DESCRIPTION,
        TRD_IN_VV_COLORMAPPING_20240408.COLOR_CODE,
        TRD_IN_VV_COLORMAPPING_20240408.DW_COLOR_FAMILY
 FROM public.TRD_IN_VV_COLORMAPPING_20240408
 ORDER BY TRD_IN_VV_COLORMAPPING_20240408.COLOR_ID,
          TRD_IN_VV_COLORMAPPING_20240408.COLOR_DESCRIPTION,
          TRD_IN_VV_COLORMAPPING_20240408.COLOR_CODE,
          TRD_IN_VV_COLORMAPPING_20240408.DW_COLOR_FAMILY
SEGMENTED BY hash(TRD_IN_VV_COLORMAPPING_20240408.COLOR_ID, TRD_IN_VV_COLORMAPPING_20240408.COLOR_DESCRIPTION, TRD_IN_VV_COLORMAPPING_20240408.COLOR_CODE, TRD_IN_VV_COLORMAPPING_20240408.DW_COLOR_FAMILY) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_VV_COLORSWATCHES_20240408_super /*+basename(TRD_IN_VV_COLORSWATCHES_20240408),createtype(A)*/ 
(
 COLOR_ID,
 STRTYPE,
 DATASTR
)
AS
 SELECT TRD_IN_VV_COLORSWATCHES_20240408.COLOR_ID,
        TRD_IN_VV_COLORSWATCHES_20240408.STRTYPE,
        TRD_IN_VV_COLORSWATCHES_20240408.DATASTR
 FROM public.TRD_IN_VV_COLORSWATCHES_20240408
 ORDER BY TRD_IN_VV_COLORSWATCHES_20240408.COLOR_ID,
          TRD_IN_VV_COLORSWATCHES_20240408.STRTYPE,
          TRD_IN_VV_COLORSWATCHES_20240408.DATASTR
SEGMENTED BY hash(TRD_IN_VV_COLORSWATCHES_20240408.COLOR_ID, TRD_IN_VV_COLORSWATCHES_20240408.STRTYPE, TRD_IN_VV_COLORSWATCHES_20240408.DATASTR) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_p_history_inv_funded_super /*+basename(trd_int_p_history_inv_funded),createtype(L)*/ 
(
 product,
 location,
 skuloc_first_funded_week
)
AS
 SELECT trd_int_p_history_inv_funded.product,
        trd_int_p_history_inv_funded.location,
        trd_int_p_history_inv_funded.skuloc_first_funded_week
 FROM public.trd_int_p_history_inv_funded
 ORDER BY trd_int_p_history_inv_funded.product,
          trd_int_p_history_inv_funded.location,
          trd_int_p_history_inv_funded.skuloc_first_funded_week
SEGMENTED BY hash(trd_int_p_history_inv_funded.product, trd_int_p_history_inv_funded.location, trd_int_p_history_inv_funded.skuloc_first_funded_week) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_SLSWEEK_super /*+basename(TRD_PERF_ACT_SLSWEEK),createtype(A)*/ 
(
 DAY_ID
)
AS
 SELECT TRD_PERF_ACT_SLSWEEK.DAY_ID
 FROM public.TRD_PERF_ACT_SLSWEEK
 ORDER BY TRD_PERF_ACT_SLSWEEK.DAY_ID
SEGMENTED BY hash(TRD_PERF_ACT_SLSWEEK.DAY_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_DMDWEEK_super /*+basename(TRD_PERF_ACT_DMDWEEK),createtype(A)*/ 
(
 DAY_ID
)
AS
 SELECT TRD_PERF_ACT_DMDWEEK.DAY_ID
 FROM public.TRD_PERF_ACT_DMDWEEK
 ORDER BY TRD_PERF_ACT_DMDWEEK.DAY_ID
SEGMENTED BY hash(TRD_PERF_ACT_DMDWEEK.DAY_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_history_sku_new_strcntwk_super /*+basename(trd_p_history_sku_new_strcntwk),createtype(A)*/ 
(
 product,
 location,
 "time",
 prodlife,
 cluster,
 stylecolor,
 strcntwk,
 new_strcntwk,
 strcntwk_funded,
 in_stock_crit
)
AS
 SELECT trd_p_history_sku_new_strcntwk.product,
        trd_p_history_sku_new_strcntwk.location,
        trd_p_history_sku_new_strcntwk."time",
        trd_p_history_sku_new_strcntwk.prodlife,
        trd_p_history_sku_new_strcntwk.cluster,
        trd_p_history_sku_new_strcntwk.stylecolor,
        trd_p_history_sku_new_strcntwk.strcntwk,
        trd_p_history_sku_new_strcntwk.new_strcntwk,
        trd_p_history_sku_new_strcntwk.strcntwk_funded,
        trd_p_history_sku_new_strcntwk.in_stock_crit
 FROM public.trd_p_history_sku_new_strcntwk
 ORDER BY trd_p_history_sku_new_strcntwk.product,
          trd_p_history_sku_new_strcntwk.location,
          trd_p_history_sku_new_strcntwk."time"
SEGMENTED BY hash(trd_p_history_sku_new_strcntwk.prodlife, trd_p_history_sku_new_strcntwk.strcntwk, trd_p_history_sku_new_strcntwk.strcntwk_funded, trd_p_history_sku_new_strcntwk.in_stock_crit, trd_p_history_sku_new_strcntwk.new_strcntwk, trd_p_history_sku_new_strcntwk.cluster, trd_p_history_sku_new_strcntwk.product, trd_p_history_sku_new_strcntwk.location) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_DAILY_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_DAILY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_DAILY.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_DAILY."TIME",
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_DAILY
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_DAILY.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_DAILY.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_DAILY.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_DAILY.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_DAILY."TIME",
          TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_R, TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_U, TRD_IN_ACT_DAILYINVENTORY_DAILY.EOH_C, TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_DAILY.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_DAILY.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_DAILY.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_DAILY),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_ACT_DAILYINVENTORY_super /*+basename(TRD_REJ_ACT_DAILYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_ACT_DAILYINVENTORY.MEMBER_ID,
        TRD_REJ_ACT_DAILYINVENTORY.LOCATION_ID,
        TRD_REJ_ACT_DAILYINVENTORY.PRICE_STATUS,
        TRD_REJ_ACT_DAILYINVENTORY.COMP_STATUS,
        TRD_REJ_ACT_DAILYINVENTORY."TIME",
        TRD_REJ_ACT_DAILYINVENTORY.EOH_R,
        TRD_REJ_ACT_DAILYINVENTORY.EOH_U,
        TRD_REJ_ACT_DAILYINVENTORY.EOH_C,
        TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_R,
        TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_U,
        TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_C,
        TRD_REJ_ACT_DAILYINVENTORY.AVG_UNIT_COST,
        TRD_REJ_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE,
        TRD_REJ_ACT_DAILYINVENTORY.CURRENT_TICKET_PRICE,
        TRD_REJ_ACT_DAILYINVENTORY.PERM_MD_R,
        TRD_REJ_ACT_DAILYINVENTORY.PERM_MD_C,
        TRD_REJ_ACT_DAILYINVENTORY.PERM_MD_U,
        TRD_REJ_ACT_DAILYINVENTORY.PERM_MD_R_CSP,
        TRD_REJ_ACT_DAILYINVENTORY.REJECT_REASON
 FROM public.TRD_REJ_ACT_DAILYINVENTORY
 ORDER BY TRD_REJ_ACT_DAILYINVENTORY.MEMBER_ID,
          TRD_REJ_ACT_DAILYINVENTORY.LOCATION_ID,
          TRD_REJ_ACT_DAILYINVENTORY.PRICE_STATUS,
          TRD_REJ_ACT_DAILYINVENTORY.COMP_STATUS,
          TRD_REJ_ACT_DAILYINVENTORY."TIME",
          TRD_REJ_ACT_DAILYINVENTORY.EOH_R,
          TRD_REJ_ACT_DAILYINVENTORY.EOH_U,
          TRD_REJ_ACT_DAILYINVENTORY.EOH_C
SEGMENTED BY hash(TRD_REJ_ACT_DAILYINVENTORY.EOH_R, TRD_REJ_ACT_DAILYINVENTORY.EOH_U, TRD_REJ_ACT_DAILYINVENTORY.EOH_C, TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_R, TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_U, TRD_REJ_ACT_DAILYINVENTORY.EOP_INTRANSIT_C, TRD_REJ_ACT_DAILYINVENTORY.AVG_UNIT_COST, TRD_REJ_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_ACT_SALES_TRANSACTIONS_super /*+basename(TRD_REJ_ACT_SALES_TRANSACTIONS),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
        TRD_REJ_ACT_SALES_TRANSACTIONS.MEMBER_ID,
        TRD_REJ_ACT_SALES_TRANSACTIONS.DAY_ID,
        TRD_REJ_ACT_SALES_TRANSACTIONS.LOCATION_ID,
        TRD_REJ_ACT_SALES_TRANSACTIONS.COMP_STATUS,
        TRD_REJ_ACT_SALES_TRANSACTIONS.PRICE_STATUS,
        TRD_REJ_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE,
        TRD_REJ_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C,
        TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_R,
        TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_U,
        TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_C,
        TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_R_CSP,
        TRD_REJ_ACT_SALES_TRANSACTIONS.BOPIS_SALES_R,
        TRD_REJ_ACT_SALES_TRANSACTIONS.BOPIS_SALES_U,
        TRD_REJ_ACT_SALES_TRANSACTIONS.BOPIS_SALES_C,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SFS_SALES_R,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SFS_SALES_U,
        TRD_REJ_ACT_SALES_TRANSACTIONS.SFS_SALES_C,
        TRD_REJ_ACT_SALES_TRANSACTIONS.REJECT_REASON
 FROM public.TRD_REJ_ACT_SALES_TRANSACTIONS
 ORDER BY TRD_REJ_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
          TRD_REJ_ACT_SALES_TRANSACTIONS.MEMBER_ID,
          TRD_REJ_ACT_SALES_TRANSACTIONS.DAY_ID,
          TRD_REJ_ACT_SALES_TRANSACTIONS.LOCATION_ID,
          TRD_REJ_ACT_SALES_TRANSACTIONS.COMP_STATUS,
          TRD_REJ_ACT_SALES_TRANSACTIONS.PRICE_STATUS,
          TRD_REJ_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE,
          TRD_REJ_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_REJ_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE, TRD_REJ_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE, TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP, TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R, TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U, TRD_REJ_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C, TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_R, TRD_REJ_ACT_SALES_TRANSACTIONS.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_DAILY_super /*+basename(TRD_IN_ACT_DEMAND_SALES_DAILY),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_DAILY.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_DAILY.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_DAILY.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_DAILY
 ORDER BY TRD_IN_ACT_DEMAND_SALES_DAILY.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_DAILY.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_DAILY.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_DAILY.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_DAILY.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_DAILY.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_DAILY.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_DAILY.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_ACT_DEMAND_SALES_super /*+basename(TRD_REJ_ACT_DEMAND_SALES),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_ACT_DEMAND_SALES.TRANSACTION_ID,
        TRD_REJ_ACT_DEMAND_SALES.MEMBER_ID,
        TRD_REJ_ACT_DEMAND_SALES.DAY_ID,
        TRD_REJ_ACT_DEMAND_SALES.LOCATION_ID,
        TRD_REJ_ACT_DEMAND_SALES.PRICE_STATUS,
        TRD_REJ_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE,
        TRD_REJ_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE,
        TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP,
        TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_R,
        TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_U,
        TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_C,
        TRD_REJ_ACT_DEMAND_SALES.REJECT_REASON
 FROM public.TRD_REJ_ACT_DEMAND_SALES
 ORDER BY TRD_REJ_ACT_DEMAND_SALES.TRANSACTION_ID,
          TRD_REJ_ACT_DEMAND_SALES.MEMBER_ID,
          TRD_REJ_ACT_DEMAND_SALES.DAY_ID,
          TRD_REJ_ACT_DEMAND_SALES.LOCATION_ID,
          TRD_REJ_ACT_DEMAND_SALES.PRICE_STATUS,
          TRD_REJ_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE,
          TRD_REJ_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE,
          TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_REJ_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE, TRD_REJ_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE, TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP, TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_R, TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_U, TRD_REJ_ACT_DEMAND_SALES.DEMAND_SALES_C, TRD_REJ_ACT_DEMAND_SALES.REJECT_REASON, TRD_REJ_ACT_DEMAND_SALES.TRANSACTION_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_super /*+basename(TRD_IN_ACT_DEMAND_SALES),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES
 ORDER BY TRD_IN_ACT_DEMAND_SALES.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_super /*+basename(TRD_IN_ACT_DAILYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY."TIME",
        TRD_IN_ACT_DAILYINVENTORY.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY
 ORDER BY TRD_IN_ACT_DAILYINVENTORY.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY."TIME",
          TRD_IN_ACT_DAILYINVENTORY.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY.EOH_R, TRD_IN_ACT_DAILYINVENTORY.EOH_U, TRD_IN_ACT_DAILYINVENTORY.EOH_C, TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE_super /*+basename(TRD_IN_ACT_DEMAND_SALES_ARCHIVE),createtype(L)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_ARCHIVE.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE
 ORDER BY TRD_IN_ACT_DEMAND_SALES_ARCHIVE.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_ARCHIVE.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_ARCHIVE.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_ARCHIVE),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE."TIME",
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE."TIME",
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_R, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_U, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOH_C, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507_super /*+basename(deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.MEMBER_ID,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.LOCATION_ID,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PRICE_STATUS,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.COMP_STATUS,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507."TIME",
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_R,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_U,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_C,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_R,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_U,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_C,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.AVG_UNIT_COST,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.ORIGINAL_TICKET_PRICE,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.CURRENT_TICKET_PRICE,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PERM_MD_R,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PERM_MD_C,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PERM_MD_U,
        deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PERM_MD_R_CSP
 FROM public.deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507
 ORDER BY deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.MEMBER_ID,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.LOCATION_ID,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.PRICE_STATUS,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.COMP_STATUS,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507."TIME",
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_R,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_U,
          deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_C
SEGMENTED BY hash(deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_R, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_U, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOH_C, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_R, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_U, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.EOP_INTRANSIT_C, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.AVG_UNIT_COST, deleteme_TRD_IN_ACT_DAILYINVENTORY_20240507.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_p_history_inv_funded_bk_super /*+basename(trd_int_p_history_inv_funded_bk),createtype(A)*/ 
(
 product,
 location,
 skuloc_first_funded_week
)
AS
 SELECT trd_int_p_history_inv_funded_bk.product,
        trd_int_p_history_inv_funded_bk.location,
        trd_int_p_history_inv_funded_bk.skuloc_first_funded_week
 FROM public.trd_int_p_history_inv_funded_bk
 ORDER BY trd_int_p_history_inv_funded_bk.product,
          trd_int_p_history_inv_funded_bk.location,
          trd_int_p_history_inv_funded_bk.skuloc_first_funded_week
SEGMENTED BY hash(trd_int_p_history_inv_funded_bk.product, trd_int_p_history_inv_funded_bk.location, trd_int_p_history_inv_funded_bk.skuloc_first_funded_week) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_INVWEEK_super /*+basename(TRD_PERF_ACT_INVWEEK),createtype(A)*/ 
(
 "TIME"
)
AS
 SELECT TRD_PERF_ACT_INVWEEK."TIME"
 FROM public.TRD_PERF_ACT_INVWEEK
 ORDER BY TRD_PERF_ACT_INVWEEK."TIME"
SEGMENTED BY hash(TRD_PERF_ACT_INVWEEK."TIME") ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_DAILYINVWEEK_super /*+basename(TRD_PERF_ACT_DAILYINVWEEK),createtype(A)*/ 
(
 "TIME"
)
AS
 SELECT TRD_PERF_ACT_DAILYINVWEEK."TIME"
 FROM public.TRD_PERF_ACT_DAILYINVWEEK
 ORDER BY TRD_PERF_ACT_DAILYINVWEEK."TIME"
SEGMENTED BY hash(TRD_PERF_ACT_DAILYINVWEEK."TIME") ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_history_inv_super /*+basename(trd_p_history_inv),createtype(A)*/ 
(
 product,
 location,
 "time",
 cctytime,
 prodlife,
 cluster,
 stylecolor,
 boh_r,
 boh_u,
 boh_c,
 bop_intransit_r,
 bop_intransit_u,
 bop_intransit_c,
 eoh_r,
 eoh_u,
 eoh_c,
 eop_intransit_r,
 eop_intransit_u,
 eop_intransit_c,
 avg_unit_cost,
 original_ticket_price,
 current_ticket_price,
 perm_md_r,
 perm_md_c,
 perm_md_u,
 perm_md_r_csp,
 rec_r,
 rec_u,
 rec_c,
 dc_to_str_rct_r,
 dc_to_str_rct_u,
 dc_to_str_rct_c,
 inv_adjustment_r,
 inv_adjustment_u,
 inv_adjustment_c,
 mos_r,
 mos_u,
 mos_c,
 shrink_r,
 shrink_u,
 shrink_c,
 xfer_in_r,
 xfer_in_u,
 xfer_in_c,
 xfer_out_r,
 xfer_out_u,
 xfer_out_c,
 store_to_web_r,
 store_to_web_u,
 store_to_web_c,
 web_to_store_r,
 web_to_store_u,
 web_to_store_c,
 strcntwk,
 skuloc_first_funded_week
)
AS
 SELECT trd_p_history_inv.product,
        trd_p_history_inv.location,
        trd_p_history_inv."time",
        trd_p_history_inv.cctytime,
        trd_p_history_inv.prodlife,
        trd_p_history_inv.cluster,
        trd_p_history_inv.stylecolor,
        trd_p_history_inv.boh_r,
        trd_p_history_inv.boh_u,
        trd_p_history_inv.boh_c,
        trd_p_history_inv.bop_intransit_r,
        trd_p_history_inv.bop_intransit_u,
        trd_p_history_inv.bop_intransit_c,
        trd_p_history_inv.eoh_r,
        trd_p_history_inv.eoh_u,
        trd_p_history_inv.eoh_c,
        trd_p_history_inv.eop_intransit_r,
        trd_p_history_inv.eop_intransit_u,
        trd_p_history_inv.eop_intransit_c,
        trd_p_history_inv.avg_unit_cost,
        trd_p_history_inv.original_ticket_price,
        trd_p_history_inv.current_ticket_price,
        trd_p_history_inv.perm_md_r,
        trd_p_history_inv.perm_md_c,
        trd_p_history_inv.perm_md_u,
        trd_p_history_inv.perm_md_r_csp,
        trd_p_history_inv.rec_r,
        trd_p_history_inv.rec_u,
        trd_p_history_inv.rec_c,
        trd_p_history_inv.dc_to_str_rct_r,
        trd_p_history_inv.dc_to_str_rct_u,
        trd_p_history_inv.dc_to_str_rct_c,
        trd_p_history_inv.inv_adjustment_r,
        trd_p_history_inv.inv_adjustment_u,
        trd_p_history_inv.inv_adjustment_c,
        trd_p_history_inv.mos_r,
        trd_p_history_inv.mos_u,
        trd_p_history_inv.mos_c,
        trd_p_history_inv.shrink_r,
        trd_p_history_inv.shrink_u,
        trd_p_history_inv.shrink_c,
        trd_p_history_inv.xfer_in_r,
        trd_p_history_inv.xfer_in_u,
        trd_p_history_inv.xfer_in_c,
        trd_p_history_inv.xfer_out_r,
        trd_p_history_inv.xfer_out_u,
        trd_p_history_inv.xfer_out_c,
        trd_p_history_inv.store_to_web_r,
        trd_p_history_inv.store_to_web_u,
        trd_p_history_inv.store_to_web_c,
        trd_p_history_inv.web_to_store_r,
        trd_p_history_inv.web_to_store_u,
        trd_p_history_inv.web_to_store_c,
        trd_p_history_inv.strcntwk,
        trd_p_history_inv.skuloc_first_funded_week
 FROM public.trd_p_history_inv
 ORDER BY trd_p_history_inv.product,
          trd_p_history_inv.location,
          trd_p_history_inv."time",
          trd_p_history_inv.cctytime,
          trd_p_history_inv.prodlife,
          trd_p_history_inv.cluster,
          trd_p_history_inv.stylecolor,
          trd_p_history_inv.boh_r
SEGMENTED BY hash(trd_p_history_inv.prodlife, trd_p_history_inv.strcntwk, trd_p_history_inv.boh_r, trd_p_history_inv.boh_u, trd_p_history_inv.boh_c, trd_p_history_inv.bop_intransit_r, trd_p_history_inv.bop_intransit_u, trd_p_history_inv.bop_intransit_c) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_WEEKLYINVENTORY_super /*+basename(TRD_IN_ACT_WEEKLYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 VND_TO_DC_RCT_R,
 VND_TO_DC_RCT_U,
 VND_TO_DC_RCT_C,
 DC_TO_STR_RCT_R,
 DC_TO_STR_RCT_U,
 DC_TO_STR_RCT_C,
 INV_ADJUSTMENT_R,
 INV_ADJUSTMENT_U,
 INV_ADJUSTMENT_C,
 MOS_R,
 MOS_U,
 MOS_C,
 SHRINK_R,
 SHRINK_U,
 SHRINK_C,
 XFER_IN_R,
 XFER_IN_U,
 XFER_IN_C,
 XFER_OUT_R,
 XFER_OUT_U,
 XFER_OUT_C,
 STORE_TO_WEB_R,
 STORE_TO_WEB_U,
 STORE_TO_WEB_C,
 WEB_TO_STORE_R,
 WEB_TO_STORE_U,
 WEB_TO_STORE_C,
 PERM_MD_R,
 PERM_MD_U,
 PERM_MD_C,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_WEEKLYINVENTORY.MEMBER_ID,
        TRD_IN_ACT_WEEKLYINVENTORY.LOCATION_ID,
        TRD_IN_ACT_WEEKLYINVENTORY.PRICE_STATUS,
        TRD_IN_ACT_WEEKLYINVENTORY.COMP_STATUS,
        TRD_IN_ACT_WEEKLYINVENTORY."TIME",
        TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R,
        TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U,
        TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C,
        TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R,
        TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U,
        TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C,
        TRD_IN_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R,
        TRD_IN_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U,
        TRD_IN_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_C,
        TRD_IN_ACT_WEEKLYINVENTORY.MOS_R,
        TRD_IN_ACT_WEEKLYINVENTORY.MOS_U,
        TRD_IN_ACT_WEEKLYINVENTORY.MOS_C,
        TRD_IN_ACT_WEEKLYINVENTORY.SHRINK_R,
        TRD_IN_ACT_WEEKLYINVENTORY.SHRINK_U,
        TRD_IN_ACT_WEEKLYINVENTORY.SHRINK_C,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_IN_R,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_IN_U,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_IN_C,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_OUT_R,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_OUT_U,
        TRD_IN_ACT_WEEKLYINVENTORY.XFER_OUT_C,
        TRD_IN_ACT_WEEKLYINVENTORY.STORE_TO_WEB_R,
        TRD_IN_ACT_WEEKLYINVENTORY.STORE_TO_WEB_U,
        TRD_IN_ACT_WEEKLYINVENTORY.STORE_TO_WEB_C,
        TRD_IN_ACT_WEEKLYINVENTORY.WEB_TO_STORE_R,
        TRD_IN_ACT_WEEKLYINVENTORY.WEB_TO_STORE_U,
        TRD_IN_ACT_WEEKLYINVENTORY.WEB_TO_STORE_C,
        TRD_IN_ACT_WEEKLYINVENTORY.PERM_MD_R,
        TRD_IN_ACT_WEEKLYINVENTORY.PERM_MD_U,
        TRD_IN_ACT_WEEKLYINVENTORY.PERM_MD_C,
        TRD_IN_ACT_WEEKLYINVENTORY.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_WEEKLYINVENTORY
 ORDER BY TRD_IN_ACT_WEEKLYINVENTORY.MEMBER_ID,
          TRD_IN_ACT_WEEKLYINVENTORY.LOCATION_ID,
          TRD_IN_ACT_WEEKLYINVENTORY.PRICE_STATUS,
          TRD_IN_ACT_WEEKLYINVENTORY.COMP_STATUS,
          TRD_IN_ACT_WEEKLYINVENTORY."TIME",
          TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R,
          TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U,
          TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C
SEGMENTED BY hash(TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R, TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U, TRD_IN_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C, TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R, TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U, TRD_IN_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C, TRD_IN_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R, TRD_IN_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_ACT_WEEKLYINVENTORY_super /*+basename(TRD_REJ_ACT_WEEKLYINVENTORY),createtype(L)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 VND_TO_DC_RCT_R,
 VND_TO_DC_RCT_U,
 VND_TO_DC_RCT_C,
 DC_TO_STR_RCT_R,
 DC_TO_STR_RCT_U,
 DC_TO_STR_RCT_C,
 INV_ADJUSTMENT_R,
 INV_ADJUSTMENT_U,
 INV_ADJUSTMENT_C,
 MOS_R,
 MOS_U,
 MOS_C,
 SHRINK_R,
 SHRINK_U,
 SHRINK_C,
 XFER_IN_R,
 XFER_IN_U,
 XFER_IN_C,
 XFER_OUT_R,
 XFER_OUT_U,
 XFER_OUT_C,
 STORE_TO_WEB_R,
 STORE_TO_WEB_U,
 STORE_TO_WEB_C,
 WEB_TO_STORE_R,
 WEB_TO_STORE_U,
 WEB_TO_STORE_C,
 PERM_MD_R,
 PERM_MD_U,
 PERM_MD_C,
 PERM_MD_R_CSP,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_ACT_WEEKLYINVENTORY.MEMBER_ID,
        TRD_REJ_ACT_WEEKLYINVENTORY.LOCATION_ID,
        TRD_REJ_ACT_WEEKLYINVENTORY.PRICE_STATUS,
        TRD_REJ_ACT_WEEKLYINVENTORY.COMP_STATUS,
        TRD_REJ_ACT_WEEKLYINVENTORY."TIME",
        TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.MOS_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.MOS_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.MOS_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.SHRINK_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.SHRINK_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.SHRINK_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_IN_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_IN_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_IN_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_OUT_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_OUT_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.XFER_OUT_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.STORE_TO_WEB_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.STORE_TO_WEB_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.STORE_TO_WEB_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.WEB_TO_STORE_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.WEB_TO_STORE_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.WEB_TO_STORE_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.PERM_MD_R,
        TRD_REJ_ACT_WEEKLYINVENTORY.PERM_MD_U,
        TRD_REJ_ACT_WEEKLYINVENTORY.PERM_MD_C,
        TRD_REJ_ACT_WEEKLYINVENTORY.PERM_MD_R_CSP,
        TRD_REJ_ACT_WEEKLYINVENTORY.REJECT_REASON
 FROM public.TRD_REJ_ACT_WEEKLYINVENTORY
 ORDER BY TRD_REJ_ACT_WEEKLYINVENTORY.MEMBER_ID,
          TRD_REJ_ACT_WEEKLYINVENTORY.LOCATION_ID,
          TRD_REJ_ACT_WEEKLYINVENTORY.PRICE_STATUS,
          TRD_REJ_ACT_WEEKLYINVENTORY.COMP_STATUS,
          TRD_REJ_ACT_WEEKLYINVENTORY."TIME",
          TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R,
          TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U,
          TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C
SEGMENTED BY hash(TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_R, TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_U, TRD_REJ_ACT_WEEKLYINVENTORY.VND_TO_DC_RCT_C, TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_R, TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_U, TRD_REJ_ACT_WEEKLYINVENTORY.DC_TO_STR_RCT_C, TRD_REJ_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_R, TRD_REJ_ACT_WEEKLYINVENTORY.INV_ADJUSTMENT_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_SPECSTYLECOLORIMAGES_super /*+basename(TRD_IN_PRD_SPECSTYLECOLORIMAGES),createtype(L)*/ 
(
 VPN_COLOR,
 JPG
)
AS
 SELECT TRD_IN_PRD_SPECSTYLECOLORIMAGES.VPN_COLOR,
        TRD_IN_PRD_SPECSTYLECOLORIMAGES.JPG
 FROM public.TRD_IN_PRD_SPECSTYLECOLORIMAGES
 ORDER BY TRD_IN_PRD_SPECSTYLECOLORIMAGES.VPN_COLOR,
          TRD_IN_PRD_SPECSTYLECOLORIMAGES.JPG
SEGMENTED BY hash(TRD_IN_PRD_SPECSTYLECOLORIMAGES.VPN_COLOR, TRD_IN_PRD_SPECSTYLECOLORIMAGES.JPG) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_in_prd_atTRStyle_super /*+basename(deleteme_trd_in_prd_atTRStyle),createtype(A)*/ 
(
 MEMBER_ID,
 KNIT_OR_WOVEN,
 FABRICATION,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 BODY_STYLE_SILHOUETTE,
 OCCASION_USAGE,
 DETAIL,
 FINISH_STYLE,
 PRIVATE_LABEL,
 LICENSE,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 ITEM_TYPE,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 V_360_SMOOTHING,
 FRANCHISE,
 KEY_ITEM,
 SINGLE_VS_MULTI_PACK,
 TICKET_TYPE,
 VPN,
 SIZE_RANGE,
 RMS_STYLECOLOR_CREATE_DATE,
 STYLE_ATTRIBUTE_1,
 STYLE_ATTRIBUTE_2,
 STYLE_ATTRIBUTE_3,
 STYLE_ATTRIBUTE_4,
 STYLE_ATTRIBUTE_5,
 STYLE_ATTRIBUTE_6,
 STYLE_ATTRIBUTE_7,
 STYLE_ATTRIBUTE_8
)
AS
 SELECT deleteme_trd_in_prd_atTRStyle.MEMBER_ID,
        deleteme_trd_in_prd_atTRStyle.KNIT_OR_WOVEN,
        deleteme_trd_in_prd_atTRStyle.FABRICATION,
        deleteme_trd_in_prd_atTRStyle.SLEEVE_LENGTH,
        deleteme_trd_in_prd_atTRStyle.LEG_OPENING,
        deleteme_trd_in_prd_atTRStyle.BRAND,
        deleteme_trd_in_prd_atTRStyle.BODY_STYLE_SILHOUETTE,
        deleteme_trd_in_prd_atTRStyle.OCCASION_USAGE,
        deleteme_trd_in_prd_atTRStyle.DETAIL,
        deleteme_trd_in_prd_atTRStyle.FINISH_STYLE,
        deleteme_trd_in_prd_atTRStyle.PRIVATE_LABEL,
        deleteme_trd_in_prd_atTRStyle.LICENSE,
        deleteme_trd_in_prd_atTRStyle.LICENSE_VS_NON_LICENSED,
        deleteme_trd_in_prd_atTRStyle.HAZMAT_CODE,
        deleteme_trd_in_prd_atTRStyle.PROP_65_WARNING,
        deleteme_trd_in_prd_atTRStyle.MATERIAL_CONTENT,
        deleteme_trd_in_prd_atTRStyle.ITEM_TYPE,
        deleteme_trd_in_prd_atTRStyle.DWRISE,
        deleteme_trd_in_prd_atTRStyle.LENGTH,
        deleteme_trd_in_prd_atTRStyle.NECKLINE,
        deleteme_trd_in_prd_atTRStyle.TOESHAPE,
        deleteme_trd_in_prd_atTRStyle.HEEL_HEIGHT,
        deleteme_trd_in_prd_atTRStyle.BOTTOM_LENGTH,
        deleteme_trd_in_prd_atTRStyle.V_360_SMOOTHING,
        deleteme_trd_in_prd_atTRStyle.FRANCHISE,
        deleteme_trd_in_prd_atTRStyle.KEY_ITEM,
        deleteme_trd_in_prd_atTRStyle.SINGLE_VS_MULTI_PACK,
        deleteme_trd_in_prd_atTRStyle.TICKET_TYPE,
        deleteme_trd_in_prd_atTRStyle.VPN,
        deleteme_trd_in_prd_atTRStyle.SIZE_RANGE,
        deleteme_trd_in_prd_atTRStyle.RMS_STYLECOLOR_CREATE_DATE,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_1,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_2,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_3,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_4,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_5,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_6,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_7,
        deleteme_trd_in_prd_atTRStyle.STYLE_ATTRIBUTE_8
 FROM public.deleteme_trd_in_prd_atTRStyle
 ORDER BY deleteme_trd_in_prd_atTRStyle.MEMBER_ID,
          deleteme_trd_in_prd_atTRStyle.KNIT_OR_WOVEN,
          deleteme_trd_in_prd_atTRStyle.FABRICATION,
          deleteme_trd_in_prd_atTRStyle.SLEEVE_LENGTH,
          deleteme_trd_in_prd_atTRStyle.LEG_OPENING,
          deleteme_trd_in_prd_atTRStyle.BRAND,
          deleteme_trd_in_prd_atTRStyle.BODY_STYLE_SILHOUETTE,
          deleteme_trd_in_prd_atTRStyle.OCCASION_USAGE
SEGMENTED BY hash(deleteme_trd_in_prd_atTRStyle.MEMBER_ID, deleteme_trd_in_prd_atTRStyle.KNIT_OR_WOVEN, deleteme_trd_in_prd_atTRStyle.FABRICATION, deleteme_trd_in_prd_atTRStyle.SLEEVE_LENGTH, deleteme_trd_in_prd_atTRStyle.LEG_OPENING, deleteme_trd_in_prd_atTRStyle.BRAND, deleteme_trd_in_prd_atTRStyle.BODY_STYLE_SILHOUETTE, deleteme_trd_in_prd_atTRStyle.OCCASION_USAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_store_tier_dept_week_bk_super /*+basename(trd_int_store_tier_dept_week_bk),createtype(A)*/ 
(
 location_id,
 class_id,
 week,
 cluster
)
AS
 SELECT trd_int_store_tier_dept_week_bk.location_id,
        trd_int_store_tier_dept_week_bk.class_id,
        trd_int_store_tier_dept_week_bk.week,
        trd_int_store_tier_dept_week_bk.cluster
 FROM public.trd_int_store_tier_dept_week_bk
 ORDER BY trd_int_store_tier_dept_week_bk.location_id,
          trd_int_store_tier_dept_week_bk.class_id,
          trd_int_store_tier_dept_week_bk.week,
          trd_int_store_tier_dept_week_bk.cluster
SEGMENTED BY hash(trd_int_store_tier_dept_week_bk.week, trd_int_store_tier_dept_week_bk.cluster, trd_int_store_tier_dept_week_bk.location_id, trd_int_store_tier_dept_week_bk.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.DELETEME_TRD_CORRECT_FLOORSET_MAPPING_super /*+basename(DELETEME_TRD_CORRECT_FLOORSET_MAPPING),createtype(L)*/ 
(
 DEPT_ID,
 BAD_FLOORSET_ID,
 CORRECT_FLOORSET_ID,
 CORRECT_FLOORSET_ID_WITHOUT_PREFIX
)
AS
 SELECT DELETEME_TRD_CORRECT_FLOORSET_MAPPING.DEPT_ID,
        DELETEME_TRD_CORRECT_FLOORSET_MAPPING.BAD_FLOORSET_ID,
        DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID,
        DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID_WITHOUT_PREFIX
 FROM public.DELETEME_TRD_CORRECT_FLOORSET_MAPPING
 ORDER BY DELETEME_TRD_CORRECT_FLOORSET_MAPPING.DEPT_ID,
          DELETEME_TRD_CORRECT_FLOORSET_MAPPING.BAD_FLOORSET_ID,
          DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID,
          DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID_WITHOUT_PREFIX
SEGMENTED BY hash(DELETEME_TRD_CORRECT_FLOORSET_MAPPING.DEPT_ID, DELETEME_TRD_CORRECT_FLOORSET_MAPPING.BAD_FLOORSET_ID, DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID, DELETEME_TRD_CORRECT_FLOORSET_MAPPING.CORRECT_FLOORSET_ID_WITHOUT_PREFIX) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_dependencylookup_bk_super /*+basename(trd_l_dependencylookup_bk),createtype(A)*/ 
(
 lookup_id,
 lookup_value,
 target_id,
 target_value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 index
)
AS
 SELECT trd_l_dependencylookup_bk.lookup_id,
        trd_l_dependencylookup_bk.lookup_value,
        trd_l_dependencylookup_bk.target_id,
        trd_l_dependencylookup_bk.target_value,
        trd_l_dependencylookup_bk.eventdate,
        trd_l_dependencylookup_bk.version_id,
        trd_l_dependencylookup_bk.created_at,
        trd_l_dependencylookup_bk.created_by,
        trd_l_dependencylookup_bk.updated_at,
        trd_l_dependencylookup_bk.updated_by,
        trd_l_dependencylookup_bk.record_state,
        trd_l_dependencylookup_bk.index
 FROM public.trd_l_dependencylookup_bk
 ORDER BY trd_l_dependencylookup_bk.lookup_id,
          trd_l_dependencylookup_bk.lookup_value,
          trd_l_dependencylookup_bk.target_id,
          trd_l_dependencylookup_bk.target_value,
          trd_l_dependencylookup_bk.eventdate,
          trd_l_dependencylookup_bk.version_id,
          trd_l_dependencylookup_bk.created_at,
          trd_l_dependencylookup_bk.created_by
SEGMENTED BY hash(trd_l_dependencylookup_bk.eventdate, trd_l_dependencylookup_bk.version_id, trd_l_dependencylookup_bk.created_at, trd_l_dependencylookup_bk.updated_at, trd_l_dependencylookup_bk.record_state, trd_l_dependencylookup_bk.index, trd_l_dependencylookup_bk.created_by, trd_l_dependencylookup_bk.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk_super /*+basename(TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk),createtype(A)*/ 
(
 VPN_VSN,
 VPN_DESCRIPTION,
 VPN_COLOR,
 VPN_COLOR_DESCRIPTION,
 DEPT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 ITEM_DIFF_1,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 DW_COLOR_FAMILY,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 AGENT_FEE,
 DUTY,
 PORT,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 FACTORY,
 PO_SUPPLIER,
 SUB_BRAND,
 DESIGN_STYLECOLOR_STATUS,
 PRIMARY_SUPPLIER,
 SPEC_STYLECOLOR_OPEN1,
 SPEC_STYLECOLOR_OPEN2,
 SPEC_STYLECOLOR_OPEN3,
 SPEC_STYLECOLOR_OPEN4,
 SPEC_STYLECOLOR_OPEN5,
 SPEC_STYLECOLOR_OPEN6,
 SPEC_STYLECOLOR_OPEN7,
 SPEC_STYLECOLOR_OPEN8,
 SPEC_STYLECOLOR_OPEN9,
 SPEC_STYLECOLOR_OPEN10,
 SPEC_STYLECOLOR_OPEN11,
 SPEC_STYLECOLOR_OPEN12
)
AS
 SELECT TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_VSN,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DEPT_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.CLASS_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SUBCLASS_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.ITEM_DIFF_1,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.EXPORT_HTS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DW_COLOR_FAMILY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.ORIGIN_COUNTRY_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.COUNTRY_OF_SOURCING,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.COUNTRY_OF_MANUFACTURING,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.UNIT_COST,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.FREIGHT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.AGENT_FEE,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DUTY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.PORT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SHIP_METHOD,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.LADING_PORT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.HTS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.FACTORY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.PO_SUPPLIER,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SUB_BRAND,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DESIGN_STYLECOLOR_STATUS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.PRIMARY_SUPPLIER,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN1,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN2,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN3,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN4,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN5,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN6,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN7,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN8,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN9,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN10,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN11,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SPEC_STYLECOLOR_OPEN12
 FROM public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk
 ORDER BY TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_VSN,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_DESCRIPTION,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR_DESCRIPTION,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DEPT_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.CLASS_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SUBCLASS_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.ITEM_DIFF_1
SEGMENTED BY hash(TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_VSN, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_DESCRIPTION, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.VPN_COLOR_DESCRIPTION, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.DEPT_ID, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.CLASS_ID, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.SUBCLASS_ID, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_bk.ITEM_DIFF_1) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_dptflrsetattributes_test_super /*+basename(trd_ma_dptflrsetattributes_test),createtype(A)*/ 
(
 indx,
 product,
 "time",
 floorset_name,
 dept_name,
 superset_id,
 superset_name,
 initialrcptwk,
 rcptstart,
 rcptend,
 slsstart,
 slsend,
 weeks_at_fp,
 markdown_week,
 exit_week,
 ly_rcptstart,
 ly_rcptend,
 ly_slsstart,
 ly_slsend,
 ap_start,
 ap_end,
 planned_sell_down_week,
 floorset_uda,
 ly_floorset_uda,
 default_slsrnk_store,
 default_slsrnk_ecom,
 default_store_vol_grade,
 default_store_climate,
 default_store_capacity,
 default_store_banner,
 default_store_geo_region,
 default_store_hazmat,
 irw_debut_offset,
 default_presmin,
 default_presmin_weeks,
 default_ccrcptint,
 default_retpct_str,
 default_retpct_ecom,
 default_crosschannel_retpct_ecom,
 default_ccordermultiple_uom,
 default_ccmdstrategy,
 default_lead_time,
 default_ccdiscountpct,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_ma_dptflrsetattributes_test.indx,
        trd_ma_dptflrsetattributes_test.product,
        trd_ma_dptflrsetattributes_test."time",
        trd_ma_dptflrsetattributes_test.floorset_name,
        trd_ma_dptflrsetattributes_test.dept_name,
        trd_ma_dptflrsetattributes_test.superset_id,
        trd_ma_dptflrsetattributes_test.superset_name,
        trd_ma_dptflrsetattributes_test.initialrcptwk,
        trd_ma_dptflrsetattributes_test.rcptstart,
        trd_ma_dptflrsetattributes_test.rcptend,
        trd_ma_dptflrsetattributes_test.slsstart,
        trd_ma_dptflrsetattributes_test.slsend,
        trd_ma_dptflrsetattributes_test.weeks_at_fp,
        trd_ma_dptflrsetattributes_test.markdown_week,
        trd_ma_dptflrsetattributes_test.exit_week,
        trd_ma_dptflrsetattributes_test.ly_rcptstart,
        trd_ma_dptflrsetattributes_test.ly_rcptend,
        trd_ma_dptflrsetattributes_test.ly_slsstart,
        trd_ma_dptflrsetattributes_test.ly_slsend,
        trd_ma_dptflrsetattributes_test.ap_start,
        trd_ma_dptflrsetattributes_test.ap_end,
        trd_ma_dptflrsetattributes_test.planned_sell_down_week,
        trd_ma_dptflrsetattributes_test.floorset_uda,
        trd_ma_dptflrsetattributes_test.ly_floorset_uda,
        trd_ma_dptflrsetattributes_test.default_slsrnk_store,
        trd_ma_dptflrsetattributes_test.default_slsrnk_ecom,
        trd_ma_dptflrsetattributes_test.default_store_vol_grade,
        trd_ma_dptflrsetattributes_test.default_store_climate,
        trd_ma_dptflrsetattributes_test.default_store_capacity,
        trd_ma_dptflrsetattributes_test.default_store_banner,
        trd_ma_dptflrsetattributes_test.default_store_geo_region,
        trd_ma_dptflrsetattributes_test.default_store_hazmat,
        trd_ma_dptflrsetattributes_test.irw_debut_offset,
        trd_ma_dptflrsetattributes_test.default_presmin,
        trd_ma_dptflrsetattributes_test.default_presmin_weeks,
        trd_ma_dptflrsetattributes_test.default_ccrcptint,
        trd_ma_dptflrsetattributes_test.default_retpct_str,
        trd_ma_dptflrsetattributes_test.default_retpct_ecom,
        trd_ma_dptflrsetattributes_test.default_crosschannel_retpct_ecom,
        trd_ma_dptflrsetattributes_test.default_ccordermultiple_uom,
        trd_ma_dptflrsetattributes_test.default_ccmdstrategy,
        trd_ma_dptflrsetattributes_test.default_lead_time,
        trd_ma_dptflrsetattributes_test.default_ccdiscountpct,
        trd_ma_dptflrsetattributes_test.eventdate,
        trd_ma_dptflrsetattributes_test.version_id,
        trd_ma_dptflrsetattributes_test.created_at,
        trd_ma_dptflrsetattributes_test.created_by,
        trd_ma_dptflrsetattributes_test.updated_at,
        trd_ma_dptflrsetattributes_test.updated_by,
        trd_ma_dptflrsetattributes_test.record_state
 FROM public.trd_ma_dptflrsetattributes_test
 ORDER BY trd_ma_dptflrsetattributes_test.indx,
          trd_ma_dptflrsetattributes_test.product,
          trd_ma_dptflrsetattributes_test."time",
          trd_ma_dptflrsetattributes_test.floorset_name,
          trd_ma_dptflrsetattributes_test.dept_name,
          trd_ma_dptflrsetattributes_test.superset_id,
          trd_ma_dptflrsetattributes_test.superset_name,
          trd_ma_dptflrsetattributes_test.initialrcptwk
SEGMENTED BY hash(trd_ma_dptflrsetattributes_test.indx, trd_ma_dptflrsetattributes_test.default_slsrnk_store, trd_ma_dptflrsetattributes_test.default_slsrnk_ecom, trd_ma_dptflrsetattributes_test.irw_debut_offset, trd_ma_dptflrsetattributes_test.default_presmin, trd_ma_dptflrsetattributes_test.default_presmin_weeks, trd_ma_dptflrsetattributes_test.default_ccrcptint, trd_ma_dptflrsetattributes_test.default_retpct_str) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_store_tier_dept_week_bk_20240810_super /*+basename(trd_int_store_tier_dept_week_bk_20240810),createtype(A)*/ 
(
 location_id,
 class_id,
 week,
 cluster
)
AS
 SELECT trd_int_store_tier_dept_week_bk_20240810.location_id,
        trd_int_store_tier_dept_week_bk_20240810.class_id,
        trd_int_store_tier_dept_week_bk_20240810.week,
        trd_int_store_tier_dept_week_bk_20240810.cluster
 FROM public.trd_int_store_tier_dept_week_bk_20240810
 ORDER BY trd_int_store_tier_dept_week_bk_20240810.location_id,
          trd_int_store_tier_dept_week_bk_20240810.class_id,
          trd_int_store_tier_dept_week_bk_20240810.week,
          trd_int_store_tier_dept_week_bk_20240810.cluster
SEGMENTED BY hash(trd_int_store_tier_dept_week_bk_20240810.week, trd_int_store_tier_dept_week_bk_20240810.cluster, trd_int_store_tier_dept_week_bk_20240810.location_id, trd_int_store_tier_dept_week_bk_20240810.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ref_store_tier_class_min_week_super /*+basename(trd_ref_store_tier_class_min_week),createtype(A)*/ 
(
 class_id,
 min_week
)
AS
 SELECT trd_ref_store_tier_class_min_week.class_id,
        trd_ref_store_tier_class_min_week.min_week
 FROM public.trd_ref_store_tier_class_min_week
 ORDER BY trd_ref_store_tier_class_min_week.class_id
SEGMENTED BY hash(trd_ref_store_tier_class_min_week.min_week, trd_ref_store_tier_class_min_week.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_md_seq_super /*+basename(temp_md_seq),createtype(A)*/ 
(
 seq_indx
)
AS
 SELECT temp_md_seq.seq_indx
 FROM public.temp_md_seq
 ORDER BY temp_md_seq.seq_indx
SEGMENTED BY hash(temp_md_seq.seq_indx) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_md_clean_x_super /*+basename(temp_md_clean_x),createtype(A)*/ 
(
 department,
 mdstrategy,
 seq,
 duration,
 end_seq,
 start_seq,
 md_disc,
 factor
)
AS
 SELECT temp_md_clean_x.department,
        temp_md_clean_x.mdstrategy,
        temp_md_clean_x.seq,
        temp_md_clean_x.duration,
        temp_md_clean_x.end_seq,
        temp_md_clean_x.start_seq,
        temp_md_clean_x.md_disc,
        temp_md_clean_x.factor
 FROM public.temp_md_clean_x
 ORDER BY temp_md_clean_x.department,
          temp_md_clean_x.mdstrategy,
          temp_md_clean_x.seq
SEGMENTED BY hash(temp_md_clean_x.seq, temp_md_clean_x.duration, temp_md_clean_x.md_disc, temp_md_clean_x.department, temp_md_clean_x.mdstrategy) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_md_clean_super /*+basename(temp_md_clean),createtype(A)*/ 
(
 department,
 mdstrategy,
 seq,
 duration,
 end_seq,
 start_seq,
 md_disc,
 factor
)
AS
 SELECT temp_md_clean.department,
        temp_md_clean.mdstrategy,
        temp_md_clean.seq,
        temp_md_clean.duration,
        temp_md_clean.end_seq,
        temp_md_clean.start_seq,
        temp_md_clean.md_disc,
        temp_md_clean.factor
 FROM public.temp_md_clean
 ORDER BY temp_md_clean.department,
          temp_md_clean.mdstrategy,
          temp_md_clean.seq
SEGMENTED BY hash(temp_md_clean.seq, temp_md_clean.duration, temp_md_clean.md_disc, temp_md_clean.department, temp_md_clean.mdstrategy) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_BUS_MD_STRATEGY_TEMP_super /*+basename(trd_BUS_MD_STRATEGY_TEMP),createtype(A)*/ 
(
 department,
 max_seq
)
AS
 SELECT trd_BUS_MD_STRATEGY_TEMP.department,
        trd_BUS_MD_STRATEGY_TEMP.max_seq
 FROM public.trd_BUS_MD_STRATEGY_TEMP
 ORDER BY trd_BUS_MD_STRATEGY_TEMP.department
SEGMENTED BY hash(trd_BUS_MD_STRATEGY_TEMP.max_seq, trd_BUS_MD_STRATEGY_TEMP.department) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_BUS_MD_STRATEGY_PREP_super /*+basename(trd_BUS_MD_STRATEGY_PREP),createtype(A)*/ 
(
 department,
 max_seq,
 seq,
 mdstrategy,
 md_disc,
 factor
)
AS
 SELECT trd_BUS_MD_STRATEGY_PREP.department,
        trd_BUS_MD_STRATEGY_PREP.max_seq,
        trd_BUS_MD_STRATEGY_PREP.seq,
        trd_BUS_MD_STRATEGY_PREP.mdstrategy,
        trd_BUS_MD_STRATEGY_PREP.md_disc,
        trd_BUS_MD_STRATEGY_PREP.factor
 FROM public.trd_BUS_MD_STRATEGY_PREP
 ORDER BY trd_BUS_MD_STRATEGY_PREP.department,
          trd_BUS_MD_STRATEGY_PREP.mdstrategy
SEGMENTED BY hash(trd_BUS_MD_STRATEGY_PREP.max_seq, trd_BUS_MD_STRATEGY_PREP.department) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_possible_tier_weeks_super /*+basename(deleteme_possible_tier_weeks),createtype(A)*/ 
(
 location_id,
 class_id,
 week
)
AS
 SELECT deleteme_possible_tier_weeks.location_id,
        deleteme_possible_tier_weeks.class_id,
        deleteme_possible_tier_weeks.week
 FROM public.deleteme_possible_tier_weeks
 ORDER BY deleteme_possible_tier_weeks.location_id,
          deleteme_possible_tier_weeks.class_id,
          deleteme_possible_tier_weeks.week
SEGMENTED BY hash(deleteme_possible_tier_weeks.week, deleteme_possible_tier_weeks.location_id, deleteme_possible_tier_weeks.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_c_conversion_file_backup_20240919_super /*+basename(trd_c_conversion_file_backup_20240919),createtype(A)*/ 
(
 FLOORSET_CODE,
 DEPARTMENT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 STYLE_ID,
 STYLE_COLOR_ID,
 STYLE_COLOR_DESC,
 TICKET_PRICE,
 COST,
 DEFAULT_DISC,
 DEBUT_WEEK,
 MD_WEEK,
 EXIT_WEEK,
 AUTO_ROLL_FORWARD,
 PLANNED_SELL_DOWN_WK,
 MD_STRATEGY,
 STORE_VOL_GRADE,
 STORE_CLIMATE,
 STORE_CAPACITY,
 STORE_BANNER,
 STORE_REGION,
 STORE_HAZMAT,
 SSG,
 SIZE_RANGE,
 VALID_SIZES_STORES,
 VALID_SIZES_ECOM,
 SIZE_MIN,
 SIZE_MIN_WEEKS,
 PRE_SSN_RATING_STRS,
 PRE_SSN_RATING_ECOM,
 RECEIPT_INTERVAL,
 RETURN_RATE_STRS,
 RETURN_RATE_ECOM,
 CROSS_CHANNEL_RET_RATE,
 ORDER_MIN,
 ORDER_MULTIPLE
)
AS
 SELECT trd_c_conversion_file_backup_20240919.FLOORSET_CODE,
        trd_c_conversion_file_backup_20240919.DEPARTMENT_ID,
        trd_c_conversion_file_backup_20240919.CLASS_ID,
        trd_c_conversion_file_backup_20240919.SUBCLASS_ID,
        trd_c_conversion_file_backup_20240919.STYLE_ID,
        trd_c_conversion_file_backup_20240919.STYLE_COLOR_ID,
        trd_c_conversion_file_backup_20240919.STYLE_COLOR_DESC,
        trd_c_conversion_file_backup_20240919.TICKET_PRICE,
        trd_c_conversion_file_backup_20240919.COST,
        trd_c_conversion_file_backup_20240919.DEFAULT_DISC,
        trd_c_conversion_file_backup_20240919.DEBUT_WEEK,
        trd_c_conversion_file_backup_20240919.MD_WEEK,
        trd_c_conversion_file_backup_20240919.EXIT_WEEK,
        trd_c_conversion_file_backup_20240919.AUTO_ROLL_FORWARD,
        trd_c_conversion_file_backup_20240919.PLANNED_SELL_DOWN_WK,
        trd_c_conversion_file_backup_20240919.MD_STRATEGY,
        trd_c_conversion_file_backup_20240919.STORE_VOL_GRADE,
        trd_c_conversion_file_backup_20240919.STORE_CLIMATE,
        trd_c_conversion_file_backup_20240919.STORE_CAPACITY,
        trd_c_conversion_file_backup_20240919.STORE_BANNER,
        trd_c_conversion_file_backup_20240919.STORE_REGION,
        trd_c_conversion_file_backup_20240919.STORE_HAZMAT,
        trd_c_conversion_file_backup_20240919.SSG,
        trd_c_conversion_file_backup_20240919.SIZE_RANGE,
        trd_c_conversion_file_backup_20240919.VALID_SIZES_STORES,
        trd_c_conversion_file_backup_20240919.VALID_SIZES_ECOM,
        trd_c_conversion_file_backup_20240919.SIZE_MIN,
        trd_c_conversion_file_backup_20240919.SIZE_MIN_WEEKS,
        trd_c_conversion_file_backup_20240919.PRE_SSN_RATING_STRS,
        trd_c_conversion_file_backup_20240919.PRE_SSN_RATING_ECOM,
        trd_c_conversion_file_backup_20240919.RECEIPT_INTERVAL,
        trd_c_conversion_file_backup_20240919.RETURN_RATE_STRS,
        trd_c_conversion_file_backup_20240919.RETURN_RATE_ECOM,
        trd_c_conversion_file_backup_20240919.CROSS_CHANNEL_RET_RATE,
        trd_c_conversion_file_backup_20240919.ORDER_MIN,
        trd_c_conversion_file_backup_20240919.ORDER_MULTIPLE
 FROM public.trd_c_conversion_file_backup_20240919
 ORDER BY trd_c_conversion_file_backup_20240919.FLOORSET_CODE,
          trd_c_conversion_file_backup_20240919.DEPARTMENT_ID,
          trd_c_conversion_file_backup_20240919.CLASS_ID,
          trd_c_conversion_file_backup_20240919.SUBCLASS_ID,
          trd_c_conversion_file_backup_20240919.STYLE_ID,
          trd_c_conversion_file_backup_20240919.STYLE_COLOR_ID,
          trd_c_conversion_file_backup_20240919.STYLE_COLOR_DESC,
          trd_c_conversion_file_backup_20240919.TICKET_PRICE
SEGMENTED BY hash(trd_c_conversion_file_backup_20240919.TICKET_PRICE, trd_c_conversion_file_backup_20240919.COST, trd_c_conversion_file_backup_20240919.DEFAULT_DISC, trd_c_conversion_file_backup_20240919.AUTO_ROLL_FORWARD, trd_c_conversion_file_backup_20240919.SIZE_MIN, trd_c_conversion_file_backup_20240919.SIZE_MIN_WEEKS, trd_c_conversion_file_backup_20240919.PRE_SSN_RATING_STRS, trd_c_conversion_file_backup_20240919.PRE_SSN_RATING_ECOM) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_SSG_bk_20240919_super /*+basename(TRD_IN_BUS_SSG_bk_20240919),createtype(A)*/ 
(
 SSG_ID,
 LOCATION,
 SSG_NAME,
 SSG_STORE
)
AS
 SELECT TRD_IN_BUS_SSG_bk_20240919.SSG_ID,
        TRD_IN_BUS_SSG_bk_20240919.LOCATION,
        TRD_IN_BUS_SSG_bk_20240919.SSG_NAME,
        TRD_IN_BUS_SSG_bk_20240919.SSG_STORE
 FROM public.TRD_IN_BUS_SSG_bk_20240919
 ORDER BY TRD_IN_BUS_SSG_bk_20240919.SSG_ID,
          TRD_IN_BUS_SSG_bk_20240919.LOCATION,
          TRD_IN_BUS_SSG_bk_20240919.SSG_NAME,
          TRD_IN_BUS_SSG_bk_20240919.SSG_STORE
SEGMENTED BY hash(TRD_IN_BUS_SSG_bk_20240919.SSG_ID, TRD_IN_BUS_SSG_bk_20240919.LOCATION, TRD_IN_BUS_SSG_bk_20240919.SSG_NAME, TRD_IN_BUS_SSG_bk_20240919.SSG_STORE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSKU_JR_super /*+basename(TRD_IN_PRD_ATTRSKU_JR),createtype(L)*/ 
(
 ITEM,
 ITEM_DIFF_2,
 ITEM_DIFF_3,
 STYLECOLORSIZE_CREATE_DATE,
 SIZE_ATTR_ID
)
AS
 SELECT TRD_IN_PRD_ATTRSKU_JR.ITEM,
        TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_2,
        TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_3,
        TRD_IN_PRD_ATTRSKU_JR.STYLECOLORSIZE_CREATE_DATE,
        TRD_IN_PRD_ATTRSKU_JR.SIZE_ATTR_ID
 FROM public.TRD_IN_PRD_ATTRSKU_JR
 ORDER BY TRD_IN_PRD_ATTRSKU_JR.ITEM,
          TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_2,
          TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_3,
          TRD_IN_PRD_ATTRSKU_JR.STYLECOLORSIZE_CREATE_DATE,
          TRD_IN_PRD_ATTRSKU_JR.SIZE_ATTR_ID
SEGMENTED BY hash(TRD_IN_PRD_ATTRSKU_JR.ITEM, TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_2, TRD_IN_PRD_ATTRSKU_JR.ITEM_DIFF_3, TRD_IN_PRD_ATTRSKU_JR.STYLECOLORSIZE_CREATE_DATE, TRD_IN_PRD_ATTRSKU_JR.SIZE_ATTR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_sizeattributes_existing_bk_super /*+basename(trd_ma_sizeattributes_existing_bk),createtype(A)*/ 
(
 product,
 parent_id,
 item_diff_2,
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
AS
 SELECT trd_ma_sizeattributes_existing_bk.product,
        trd_ma_sizeattributes_existing_bk.parent_id,
        trd_ma_sizeattributes_existing_bk.item_diff_2,
        trd_ma_sizeattributes_existing_bk.sizeattribute,
        trd_ma_sizeattributes_existing_bk.isvalid,
        trd_ma_sizeattributes_existing_bk.eventdate,
        trd_ma_sizeattributes_existing_bk.version_id,
        trd_ma_sizeattributes_existing_bk.created_at,
        trd_ma_sizeattributes_existing_bk.created_by,
        trd_ma_sizeattributes_existing_bk.updated_at,
        trd_ma_sizeattributes_existing_bk.updated_by,
        trd_ma_sizeattributes_existing_bk.record_state
 FROM public.trd_ma_sizeattributes_existing_bk
 ORDER BY trd_ma_sizeattributes_existing_bk.product,
          trd_ma_sizeattributes_existing_bk.parent_id,
          trd_ma_sizeattributes_existing_bk.item_diff_2,
          trd_ma_sizeattributes_existing_bk.sizeattribute,
          trd_ma_sizeattributes_existing_bk.isvalid,
          trd_ma_sizeattributes_existing_bk.eventdate,
          trd_ma_sizeattributes_existing_bk.version_id,
          trd_ma_sizeattributes_existing_bk.created_at
SEGMENTED BY hash(trd_ma_sizeattributes_existing_bk.isvalid, trd_ma_sizeattributes_existing_bk.eventdate, trd_ma_sizeattributes_existing_bk.version_id, trd_ma_sizeattributes_existing_bk.created_at, trd_ma_sizeattributes_existing_bk.updated_at, trd_ma_sizeattributes_existing_bk.record_state, trd_ma_sizeattributes_existing_bk.product, trd_ma_sizeattributes_existing_bk.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSKU_super /*+basename(TRD_IN_PRD_ATTRSKU),createtype(L)*/ 
(
 ITEM,
 ITEM_DIFF_2,
 ITEM_DIFF_3,
 STYLECOLORSIZE_CREATE_DATE,
 SIZE_ATTR_ID
)
AS
 SELECT TRD_IN_PRD_ATTRSKU.ITEM,
        TRD_IN_PRD_ATTRSKU.ITEM_DIFF_2,
        TRD_IN_PRD_ATTRSKU.ITEM_DIFF_3,
        TRD_IN_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE,
        TRD_IN_PRD_ATTRSKU.SIZE_ATTR_ID
 FROM public.TRD_IN_PRD_ATTRSKU
 ORDER BY TRD_IN_PRD_ATTRSKU.ITEM,
          TRD_IN_PRD_ATTRSKU.ITEM_DIFF_2,
          TRD_IN_PRD_ATTRSKU.ITEM_DIFF_3,
          TRD_IN_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE,
          TRD_IN_PRD_ATTRSKU.SIZE_ATTR_ID
SEGMENTED BY hash(TRD_IN_PRD_ATTRSKU.ITEM, TRD_IN_PRD_ATTRSKU.ITEM_DIFF_2, TRD_IN_PRD_ATTRSKU.ITEM_DIFF_3, TRD_IN_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE, TRD_IN_PRD_ATTRSKU.SIZE_ATTR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_dependencylookup_bk_20240922_super /*+basename(trd_l_dependencylookup_bk_20240922),createtype(A)*/ 
(
 lookup_id,
 lookup_value,
 target_id,
 target_value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 index
)
AS
 SELECT trd_l_dependencylookup_bk_20240922.lookup_id,
        trd_l_dependencylookup_bk_20240922.lookup_value,
        trd_l_dependencylookup_bk_20240922.target_id,
        trd_l_dependencylookup_bk_20240922.target_value,
        trd_l_dependencylookup_bk_20240922.eventdate,
        trd_l_dependencylookup_bk_20240922.version_id,
        trd_l_dependencylookup_bk_20240922.created_at,
        trd_l_dependencylookup_bk_20240922.created_by,
        trd_l_dependencylookup_bk_20240922.updated_at,
        trd_l_dependencylookup_bk_20240922.updated_by,
        trd_l_dependencylookup_bk_20240922.record_state,
        trd_l_dependencylookup_bk_20240922.index
 FROM public.trd_l_dependencylookup_bk_20240922
 ORDER BY trd_l_dependencylookup_bk_20240922.lookup_id,
          trd_l_dependencylookup_bk_20240922.lookup_value,
          trd_l_dependencylookup_bk_20240922.target_id,
          trd_l_dependencylookup_bk_20240922.target_value,
          trd_l_dependencylookup_bk_20240922.eventdate,
          trd_l_dependencylookup_bk_20240922.version_id,
          trd_l_dependencylookup_bk_20240922.created_at,
          trd_l_dependencylookup_bk_20240922.created_by
SEGMENTED BY hash(trd_l_dependencylookup_bk_20240922.eventdate, trd_l_dependencylookup_bk_20240922.version_id, trd_l_dependencylookup_bk_20240922.created_at, trd_l_dependencylookup_bk_20240922.updated_at, trd_l_dependencylookup_bk_20240922.record_state, trd_l_dependencylookup_bk_20240922.index, trd_l_dependencylookup_bk_20240922.created_by, trd_l_dependencylookup_bk_20240922.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_v_memberbasedvalidvalues_bk_20240922_super /*+basename(trd_v_memberbasedvalidvalues_bk_20240922),createtype(A)*/ 
(
 attributeid,
 membertie,
 attributekey,
 attributevalue,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_v_memberbasedvalidvalues_bk_20240922.attributeid,
        trd_v_memberbasedvalidvalues_bk_20240922.membertie,
        trd_v_memberbasedvalidvalues_bk_20240922.attributekey,
        trd_v_memberbasedvalidvalues_bk_20240922.attributevalue,
        trd_v_memberbasedvalidvalues_bk_20240922.indx,
        trd_v_memberbasedvalidvalues_bk_20240922.eventdate,
        trd_v_memberbasedvalidvalues_bk_20240922.version_id,
        trd_v_memberbasedvalidvalues_bk_20240922.created_at,
        trd_v_memberbasedvalidvalues_bk_20240922.created_by,
        trd_v_memberbasedvalidvalues_bk_20240922.updated_at,
        trd_v_memberbasedvalidvalues_bk_20240922.updated_by,
        trd_v_memberbasedvalidvalues_bk_20240922.record_state
 FROM public.trd_v_memberbasedvalidvalues_bk_20240922
 ORDER BY trd_v_memberbasedvalidvalues_bk_20240922.attributekey
SEGMENTED BY hash(trd_v_memberbasedvalidvalues_bk_20240922.indx, trd_v_memberbasedvalidvalues_bk_20240922.eventdate, trd_v_memberbasedvalidvalues_bk_20240922.version_id, trd_v_memberbasedvalidvalues_bk_20240922.created_at, trd_v_memberbasedvalidvalues_bk_20240922.updated_at, trd_v_memberbasedvalidvalues_bk_20240922.record_state, trd_v_memberbasedvalidvalues_bk_20240922.created_by, trd_v_memberbasedvalidvalues_bk_20240922.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_eohdata_stylecolor_super /*+basename(trd_eohdata_stylecolor),createtype(A)*/ 
(
 product,
 channel,
 eohu
)
AS
 SELECT trd_eohdata_stylecolor.product,
        trd_eohdata_stylecolor.channel,
        trd_eohdata_stylecolor.eohu
 FROM public.trd_eohdata_stylecolor
 ORDER BY trd_eohdata_stylecolor.product,
          trd_eohdata_stylecolor.channel
SEGMENTED BY hash(trd_eohdata_stylecolor.eohu, trd_eohdata_stylecolor.product, trd_eohdata_stylecolor.channel) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_dependencylkp_na_super /*+basename(temp_dependencylkp_na),createtype(A)*/ 
(
 lookup_id,
 lookup_value,
 target_id,
 target_value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 index
)
AS
 SELECT temp_dependencylkp_na.lookup_id,
        temp_dependencylkp_na.lookup_value,
        temp_dependencylkp_na.target_id,
        temp_dependencylkp_na.target_value,
        temp_dependencylkp_na.eventdate,
        temp_dependencylkp_na.version_id,
        temp_dependencylkp_na.created_at,
        temp_dependencylkp_na.created_by,
        temp_dependencylkp_na.updated_at,
        temp_dependencylkp_na.updated_by,
        temp_dependencylkp_na.record_state,
        temp_dependencylkp_na.index
 FROM public.temp_dependencylkp_na
 ORDER BY temp_dependencylkp_na.lookup_id,
          temp_dependencylkp_na.lookup_value,
          temp_dependencylkp_na.target_id,
          temp_dependencylkp_na.target_value,
          temp_dependencylkp_na.eventdate,
          temp_dependencylkp_na.version_id,
          temp_dependencylkp_na.created_at,
          temp_dependencylkp_na.created_by
SEGMENTED BY hash(temp_dependencylkp_na.eventdate, temp_dependencylkp_na.version_id, temp_dependencylkp_na.created_at, temp_dependencylkp_na.updated_at, temp_dependencylkp_na.record_state, temp_dependencylkp_na.index, temp_dependencylkp_na.created_by, temp_dependencylkp_na.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_pricebandlookup_bk_super /*+basename(trd_l_pricebandlookup_bk),createtype(A)*/ 
(
 product,
 ticket_price_min,
 ticket_price_max,
 price_band,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_l_pricebandlookup_bk.product,
        trd_l_pricebandlookup_bk.ticket_price_min,
        trd_l_pricebandlookup_bk.ticket_price_max,
        trd_l_pricebandlookup_bk.price_band,
        trd_l_pricebandlookup_bk.eventdate,
        trd_l_pricebandlookup_bk.version_id,
        trd_l_pricebandlookup_bk.created_at,
        trd_l_pricebandlookup_bk.created_by,
        trd_l_pricebandlookup_bk.updated_at,
        trd_l_pricebandlookup_bk.updated_by,
        trd_l_pricebandlookup_bk.record_state
 FROM public.trd_l_pricebandlookup_bk
 ORDER BY trd_l_pricebandlookup_bk.product
SEGMENTED BY hash(trd_l_pricebandlookup_bk.ticket_price_min, trd_l_pricebandlookup_bk.ticket_price_max, trd_l_pricebandlookup_bk.eventdate, trd_l_pricebandlookup_bk.version_id, trd_l_pricebandlookup_bk.created_at, trd_l_pricebandlookup_bk.updated_at, trd_l_pricebandlookup_bk.record_state, trd_l_pricebandlookup_bk.created_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_PRD_ATTRSKU_super /*+basename(TRD_REJ_PRD_ATTRSKU),createtype(L)*/ 
(
 ITEM,
 ITEM_DIFF_2,
 ITEM_DIFF_3,
 STYLECOLORSIZE_CREATE_DATE,
 SIZE_ATTR_ID,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_PRD_ATTRSKU.ITEM,
        TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_2,
        TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_3,
        TRD_REJ_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE,
        TRD_REJ_PRD_ATTRSKU.SIZE_ATTR_ID,
        TRD_REJ_PRD_ATTRSKU.REJECT_REASON
 FROM public.TRD_REJ_PRD_ATTRSKU
 ORDER BY TRD_REJ_PRD_ATTRSKU.ITEM,
          TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_2,
          TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_3,
          TRD_REJ_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE,
          TRD_REJ_PRD_ATTRSKU.SIZE_ATTR_ID,
          TRD_REJ_PRD_ATTRSKU.REJECT_REASON
SEGMENTED BY hash(TRD_REJ_PRD_ATTRSKU.REJECT_REASON, TRD_REJ_PRD_ATTRSKU.ITEM, TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_2, TRD_REJ_PRD_ATTRSKU.ITEM_DIFF_3, TRD_REJ_PRD_ATTRSKU.STYLECOLORSIZE_CREATE_DATE, TRD_REJ_PRD_ATTRSKU.SIZE_ATTR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_last_elapsed_month_super /*+basename(temp_last_elapsed_month),createtype(A)*/ 
(
 lastElapsedMonth
)
AS
 SELECT temp_last_elapsed_month.lastElapsedMonth
 FROM public.temp_last_elapsed_month
 ORDER BY temp_last_elapsed_month.lastElapsedMonth
SEGMENTED BY hash(temp_last_elapsed_month.lastElapsedMonth) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_last_elapsed_quarter_super /*+basename(temp_last_elapsed_quarter),createtype(A)*/ 
(
 lastElapsedQuarter
)
AS
 SELECT temp_last_elapsed_quarter.lastElapsedQuarter
 FROM public.temp_last_elapsed_quarter
 ORDER BY temp_last_elapsed_quarter.lastElapsedQuarter
SEGMENTED BY hash(temp_last_elapsed_quarter.lastElapsedQuarter) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_s5_tgt_master_week_super /*+basename(temp_s5_tgt_master_week),createtype(A)*/ 
(
 "time",
 month,
 quarter,
 season,
 year
)
AS
 SELECT temp_s5_tgt_master_week."time",
        temp_s5_tgt_master_week.month,
        temp_s5_tgt_master_week.quarter,
        temp_s5_tgt_master_week.season,
        temp_s5_tgt_master_week.year
 FROM public.temp_s5_tgt_master_week
 ORDER BY temp_s5_tgt_master_week."time",
          temp_s5_tgt_master_week.month,
          temp_s5_tgt_master_week.quarter,
          temp_s5_tgt_master_week.season,
          temp_s5_tgt_master_week.year
SEGMENTED BY hash(temp_s5_tgt_master_week."time", temp_s5_tgt_master_week.month, temp_s5_tgt_master_week.quarter, temp_s5_tgt_master_week.season, temp_s5_tgt_master_week.year) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024_super /*+basename(TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024),createtype(A)*/ 
(
 DEPT_ID,
 NEW_FLOORSET_ID,
 FLOORSET_ID
)
AS
 SELECT TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.DEPT_ID,
        TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.NEW_FLOORSET_ID,
        TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.FLOORSET_ID
 FROM public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024
 ORDER BY TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.DEPT_ID,
          TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.NEW_FLOORSET_ID,
          TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.FLOORSET_ID
SEGMENTED BY hash(TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.DEPT_ID, TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.NEW_FLOORSET_ID, TRD_IN_BUS_DEPT_FLOORSET_MAPPING_PRE_11102024.FLOORSET_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD_super /*+basename(TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD),createtype(A)*/ 
(
 LOCATION_ID,
 FLOORSET_ID,
 CLASS_ID,
 TIER,
 DEPT_ID
)
AS
 SELECT TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.LOCATION_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.FLOORSET_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.CLASS_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.TIER,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.DEPT_ID
 FROM public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD
 ORDER BY TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.LOCATION_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.FLOORSET_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.CLASS_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.TIER
SEGMENTED BY hash(TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.TIER, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.LOCATION_ID, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.FLOORSET_ID, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_CA_MOD.CLASS_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_super /*+basename(TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS),createtype(L)*/ 
(
 FLOORSET_ID,
 DEPT_ID,
 CORRECT_FLOORSET_ID
)
AS
 SELECT TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.FLOORSET_ID,
        TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.DEPT_ID,
        TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.CORRECT_FLOORSET_ID
 FROM public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS
 ORDER BY TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.FLOORSET_ID,
          TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.DEPT_ID,
          TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.CORRECT_FLOORSET_ID
SEGMENTED BY hash(TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.FLOORSET_ID, TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.DEPT_ID, TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS.CORRECT_FLOORSET_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS_super /*+basename(TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS),createtype(A)*/ 
(
 FLOORSET_ID,
 DEPT_ID,
 CORRECT_FLOORSET_ID,
 CLASS_ID
)
AS
 SELECT TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.FLOORSET_ID,
        TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.DEPT_ID,
        TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.CORRECT_FLOORSET_ID,
        TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.CLASS_ID
 FROM public.TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS
 ORDER BY TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.CLASS_ID,
          TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.DEPT_ID
SEGMENTED BY hash(TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.FLOORSET_ID, TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.DEPT_ID, TRD_IN_CORRECTIONS_TO_USER_RANDOMNESS_WITH_CLASS.CORRECT_FLOORSET_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_v_memberbasedvalidvalues_pg_super /*+basename(deleteme_trd_v_memberbasedvalidvalues_pg),createtype(A)*/ 
(
 attributeid,
 membertie,
 attributekey,
 attributevalue,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT deleteme_trd_v_memberbasedvalidvalues_pg.attributeid,
        deleteme_trd_v_memberbasedvalidvalues_pg.membertie,
        deleteme_trd_v_memberbasedvalidvalues_pg.attributekey,
        deleteme_trd_v_memberbasedvalidvalues_pg.attributevalue,
        deleteme_trd_v_memberbasedvalidvalues_pg.indx,
        deleteme_trd_v_memberbasedvalidvalues_pg.eventdate,
        deleteme_trd_v_memberbasedvalidvalues_pg.version_id,
        deleteme_trd_v_memberbasedvalidvalues_pg.created_at,
        deleteme_trd_v_memberbasedvalidvalues_pg.created_by,
        deleteme_trd_v_memberbasedvalidvalues_pg.updated_at,
        deleteme_trd_v_memberbasedvalidvalues_pg.updated_by,
        deleteme_trd_v_memberbasedvalidvalues_pg.record_state
 FROM public.deleteme_trd_v_memberbasedvalidvalues_pg
 ORDER BY deleteme_trd_v_memberbasedvalidvalues_pg.attributeid,
          deleteme_trd_v_memberbasedvalidvalues_pg.membertie,
          deleteme_trd_v_memberbasedvalidvalues_pg.attributekey,
          deleteme_trd_v_memberbasedvalidvalues_pg.attributevalue,
          deleteme_trd_v_memberbasedvalidvalues_pg.indx,
          deleteme_trd_v_memberbasedvalidvalues_pg.eventdate,
          deleteme_trd_v_memberbasedvalidvalues_pg.version_id,
          deleteme_trd_v_memberbasedvalidvalues_pg.created_at
SEGMENTED BY hash(deleteme_trd_v_memberbasedvalidvalues_pg.indx, deleteme_trd_v_memberbasedvalidvalues_pg.eventdate, deleteme_trd_v_memberbasedvalidvalues_pg.version_id, deleteme_trd_v_memberbasedvalidvalues_pg.created_at, deleteme_trd_v_memberbasedvalidvalues_pg.updated_at, deleteme_trd_v_memberbasedvalidvalues_pg.record_state, deleteme_trd_v_memberbasedvalidvalues_pg.created_by, deleteme_trd_v_memberbasedvalidvalues_pg.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_l_dependencylookup_pg_super /*+basename(deleteme_trd_l_dependencylookup_pg),createtype(A)*/ 
(
 lookup_id,
 lookup_value,
 target_id,
 target_value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 index
)
AS
 SELECT deleteme_trd_l_dependencylookup_pg.lookup_id,
        deleteme_trd_l_dependencylookup_pg.lookup_value,
        deleteme_trd_l_dependencylookup_pg.target_id,
        deleteme_trd_l_dependencylookup_pg.target_value,
        deleteme_trd_l_dependencylookup_pg.eventdate,
        deleteme_trd_l_dependencylookup_pg.version_id,
        deleteme_trd_l_dependencylookup_pg.created_at,
        deleteme_trd_l_dependencylookup_pg.created_by,
        deleteme_trd_l_dependencylookup_pg.updated_at,
        deleteme_trd_l_dependencylookup_pg.updated_by,
        deleteme_trd_l_dependencylookup_pg.record_state,
        deleteme_trd_l_dependencylookup_pg.index
 FROM public.deleteme_trd_l_dependencylookup_pg
 ORDER BY deleteme_trd_l_dependencylookup_pg.lookup_id,
          deleteme_trd_l_dependencylookup_pg.lookup_value,
          deleteme_trd_l_dependencylookup_pg.target_id,
          deleteme_trd_l_dependencylookup_pg.target_value,
          deleteme_trd_l_dependencylookup_pg.eventdate,
          deleteme_trd_l_dependencylookup_pg.version_id,
          deleteme_trd_l_dependencylookup_pg.created_at,
          deleteme_trd_l_dependencylookup_pg.created_by
SEGMENTED BY hash(deleteme_trd_l_dependencylookup_pg.eventdate, deleteme_trd_l_dependencylookup_pg.version_id, deleteme_trd_l_dependencylookup_pg.created_at, deleteme_trd_l_dependencylookup_pg.updated_at, deleteme_trd_l_dependencylookup_pg.record_state, deleteme_trd_l_dependencylookup_pg.index, deleteme_trd_l_dependencylookup_pg.created_by, deleteme_trd_l_dependencylookup_pg.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_ma_dptflrsetattributes_super /*+basename(trd_int_ma_dptflrsetattributes),createtype(L)*/ 
(
 DEPT_ID,
 DEPT_NAME,
 SUPERSET_ID,
 SUPERSET_NAME,
 FLOORSET_ID,
 FLOORSET_NAME,
 INITIALRCPTWK,
 RCPTSTART,
 RCPTEND,
 SLSSTART,
 SLSEND,
 WEEKS_AT_FP,
 MARKDOWN_WEEK,
 EXIT_WEEK,
 LY_RCPTSTART,
 LY_RCPTEND,
 LY_SLSSTART,
 LY_SLSEND,
 AP_START,
 AP_END,
 PLANNED_SELL_DOWN_WEEK,
 FLOORSET_UDA,
 LY_FLOORSET_UDA,
 PRESSN_RATING_STORES,
 PRESSN_RATING_ECOM,
 DEFAULT_STORE_VOL_GRADE,
 DEFAULT_STORE_CLIMATE,
 DEFAULT_STORE_CAPACITY,
 DEFAULT_STORE_BANNER,
 DEFAULT_STORE_GEO_REGION,
 DEFAULT_STORE_HAZMAT,
 IRW_Debut_Offset
)
AS
 SELECT trd_int_ma_dptflrsetattributes.DEPT_ID,
        trd_int_ma_dptflrsetattributes.DEPT_NAME,
        trd_int_ma_dptflrsetattributes.SUPERSET_ID,
        trd_int_ma_dptflrsetattributes.SUPERSET_NAME,
        trd_int_ma_dptflrsetattributes.FLOORSET_ID,
        trd_int_ma_dptflrsetattributes.FLOORSET_NAME,
        trd_int_ma_dptflrsetattributes.INITIALRCPTWK,
        trd_int_ma_dptflrsetattributes.RCPTSTART,
        trd_int_ma_dptflrsetattributes.RCPTEND,
        trd_int_ma_dptflrsetattributes.SLSSTART,
        trd_int_ma_dptflrsetattributes.SLSEND,
        trd_int_ma_dptflrsetattributes.WEEKS_AT_FP,
        trd_int_ma_dptflrsetattributes.MARKDOWN_WEEK,
        trd_int_ma_dptflrsetattributes.EXIT_WEEK,
        trd_int_ma_dptflrsetattributes.LY_RCPTSTART,
        trd_int_ma_dptflrsetattributes.LY_RCPTEND,
        trd_int_ma_dptflrsetattributes.LY_SLSSTART,
        trd_int_ma_dptflrsetattributes.LY_SLSEND,
        trd_int_ma_dptflrsetattributes.AP_START,
        trd_int_ma_dptflrsetattributes.AP_END,
        trd_int_ma_dptflrsetattributes.PLANNED_SELL_DOWN_WEEK,
        trd_int_ma_dptflrsetattributes.FLOORSET_UDA,
        trd_int_ma_dptflrsetattributes.LY_FLOORSET_UDA,
        trd_int_ma_dptflrsetattributes.PRESSN_RATING_STORES,
        trd_int_ma_dptflrsetattributes.PRESSN_RATING_ECOM,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_VOL_GRADE,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_CLIMATE,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_CAPACITY,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_BANNER,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_GEO_REGION,
        trd_int_ma_dptflrsetattributes.DEFAULT_STORE_HAZMAT,
        trd_int_ma_dptflrsetattributes.IRW_Debut_Offset
 FROM public.trd_int_ma_dptflrsetattributes
 ORDER BY trd_int_ma_dptflrsetattributes.DEPT_ID,
          trd_int_ma_dptflrsetattributes.DEPT_NAME,
          trd_int_ma_dptflrsetattributes.SUPERSET_ID,
          trd_int_ma_dptflrsetattributes.SUPERSET_NAME,
          trd_int_ma_dptflrsetattributes.FLOORSET_ID,
          trd_int_ma_dptflrsetattributes.FLOORSET_NAME,
          trd_int_ma_dptflrsetattributes.INITIALRCPTWK,
          trd_int_ma_dptflrsetattributes.RCPTSTART
SEGMENTED BY hash(trd_int_ma_dptflrsetattributes.PRESSN_RATING_STORES, trd_int_ma_dptflrsetattributes.PRESSN_RATING_ECOM, trd_int_ma_dptflrsetattributes.IRW_Debut_Offset, trd_int_ma_dptflrsetattributes.DEPT_ID, trd_int_ma_dptflrsetattributes.DEPT_NAME, trd_int_ma_dptflrsetattributes.SUPERSET_ID, trd_int_ma_dptflrsetattributes.SUPERSET_NAME, trd_int_ma_dptflrsetattributes.FLOORSET_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_backup_20241216_super /*+basename(trd_h_prodstd_backup_20241216),createtype(A)*/ 
(
 ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 ANCESTOR5,
 ANCESTOR6,
 ANCESTOR7,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_prodstd_backup_20241216.ID,
        trd_h_prodstd_backup_20241216.ANCESTOR0,
        trd_h_prodstd_backup_20241216.ANCESTOR1,
        trd_h_prodstd_backup_20241216.ANCESTOR2,
        trd_h_prodstd_backup_20241216.ANCESTOR3,
        trd_h_prodstd_backup_20241216.ANCESTOR4,
        trd_h_prodstd_backup_20241216.ANCESTOR5,
        trd_h_prodstd_backup_20241216.ANCESTOR6,
        trd_h_prodstd_backup_20241216.ANCESTOR7,
        trd_h_prodstd_backup_20241216.version_id,
        trd_h_prodstd_backup_20241216.created_at,
        trd_h_prodstd_backup_20241216.created_by,
        trd_h_prodstd_backup_20241216.updated_at,
        trd_h_prodstd_backup_20241216.updated_by,
        trd_h_prodstd_backup_20241216.record_state
 FROM public.trd_h_prodstd_backup_20241216
 ORDER BY trd_h_prodstd_backup_20241216.ID,
          trd_h_prodstd_backup_20241216.ANCESTOR0,
          trd_h_prodstd_backup_20241216.ANCESTOR1,
          trd_h_prodstd_backup_20241216.ANCESTOR2,
          trd_h_prodstd_backup_20241216.ANCESTOR3,
          trd_h_prodstd_backup_20241216.ANCESTOR4,
          trd_h_prodstd_backup_20241216.ANCESTOR5,
          trd_h_prodstd_backup_20241216.ANCESTOR6
SEGMENTED BY hash(trd_h_prodstd_backup_20241216.ID, trd_h_prodstd_backup_20241216.ANCESTOR0, trd_h_prodstd_backup_20241216.ANCESTOR1, trd_h_prodstd_backup_20241216.ANCESTOR2, trd_h_prodstd_backup_20241216.ANCESTOR3, trd_h_prodstd_backup_20241216.ANCESTOR4, trd_h_prodstd_backup_20241216.ANCESTOR5, trd_h_prodstd_backup_20241216.ANCESTOR6) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_TRD_REF_S5_CLIENT_ID_MAPPING_super /*+basename(deleteme_TRD_REF_S5_CLIENT_ID_MAPPING),createtype(A)*/ 
(
 s5_id,
 client_erp_id,
 levelid
)
AS
 SELECT deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.s5_id,
        deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id,
        deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.levelid
 FROM public.deleteme_TRD_REF_S5_CLIENT_ID_MAPPING
 ORDER BY deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.s5_id,
          deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id,
          deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.levelid
SEGMENTED BY hash(deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.levelid, deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.s5_id, deleteme_TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSTYLE_super /*+basename(TRD_IN_PRD_ATTRSTYLE),createtype(L)*/ 
(
 MEMBER_ID,
 KNIT_OR_WOVEN,
 FABRICATION,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 BODY_STYLE_SILHOUETTE,
 OCCASION_USAGE,
 DETAIL,
 FINISH_STYLE,
 PRIVATE_LABEL,
 LICENSE,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 ITEM_TYPE,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 V_360_SMOOTHING,
 FRANCHISE,
 KEY_ITEM,
 SINGLE_VS_MULTI_PACK,
 TICKET_TYPE,
 VPN,
 SIZE_RANGE,
 RMS_STYLECOLOR_CREATE_DATE,
 KNIT_FIT,
 STYLE_ATTRIBUTE_1,
 STYLE_ATTRIBUTE_2,
 STYLE_ATTRIBUTE_3,
 STYLE_ATTRIBUTE_4,
 STYLE_ATTRIBUTE_5,
 STYLE_ATTRIBUTE_6,
 STYLE_ATTRIBUTE_7,
 STYLE_ATTRIBUTE_8
)
AS
 SELECT TRD_IN_PRD_ATTRSTYLE.MEMBER_ID,
        TRD_IN_PRD_ATTRSTYLE.KNIT_OR_WOVEN,
        TRD_IN_PRD_ATTRSTYLE.FABRICATION,
        TRD_IN_PRD_ATTRSTYLE.SLEEVE_LENGTH,
        TRD_IN_PRD_ATTRSTYLE.LEG_OPENING,
        TRD_IN_PRD_ATTRSTYLE.BRAND,
        TRD_IN_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE,
        TRD_IN_PRD_ATTRSTYLE.OCCASION_USAGE,
        TRD_IN_PRD_ATTRSTYLE.DETAIL,
        TRD_IN_PRD_ATTRSTYLE.FINISH_STYLE,
        TRD_IN_PRD_ATTRSTYLE.PRIVATE_LABEL,
        TRD_IN_PRD_ATTRSTYLE.LICENSE,
        TRD_IN_PRD_ATTRSTYLE.LICENSE_VS_NON_LICENSED,
        TRD_IN_PRD_ATTRSTYLE.HAZMAT_CODE,
        TRD_IN_PRD_ATTRSTYLE.PROP_65_WARNING,
        TRD_IN_PRD_ATTRSTYLE.MATERIAL_CONTENT,
        TRD_IN_PRD_ATTRSTYLE.ITEM_TYPE,
        TRD_IN_PRD_ATTRSTYLE.DWRISE,
        TRD_IN_PRD_ATTRSTYLE.LENGTH,
        TRD_IN_PRD_ATTRSTYLE.NECKLINE,
        TRD_IN_PRD_ATTRSTYLE.TOESHAPE,
        TRD_IN_PRD_ATTRSTYLE.HEEL_HEIGHT,
        TRD_IN_PRD_ATTRSTYLE.BOTTOM_LENGTH,
        TRD_IN_PRD_ATTRSTYLE.V_360_SMOOTHING,
        TRD_IN_PRD_ATTRSTYLE.FRANCHISE,
        TRD_IN_PRD_ATTRSTYLE.KEY_ITEM,
        TRD_IN_PRD_ATTRSTYLE.SINGLE_VS_MULTI_PACK,
        TRD_IN_PRD_ATTRSTYLE.TICKET_TYPE,
        TRD_IN_PRD_ATTRSTYLE.VPN,
        TRD_IN_PRD_ATTRSTYLE.SIZE_RANGE,
        TRD_IN_PRD_ATTRSTYLE.RMS_STYLECOLOR_CREATE_DATE,
        TRD_IN_PRD_ATTRSTYLE.KNIT_FIT,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_1,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_2,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_3,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_4,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_5,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_6,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_7,
        TRD_IN_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_8
 FROM public.TRD_IN_PRD_ATTRSTYLE
 ORDER BY TRD_IN_PRD_ATTRSTYLE.MEMBER_ID,
          TRD_IN_PRD_ATTRSTYLE.KNIT_OR_WOVEN,
          TRD_IN_PRD_ATTRSTYLE.FABRICATION,
          TRD_IN_PRD_ATTRSTYLE.SLEEVE_LENGTH,
          TRD_IN_PRD_ATTRSTYLE.LEG_OPENING,
          TRD_IN_PRD_ATTRSTYLE.BRAND,
          TRD_IN_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE,
          TRD_IN_PRD_ATTRSTYLE.OCCASION_USAGE
SEGMENTED BY hash(TRD_IN_PRD_ATTRSTYLE.MEMBER_ID, TRD_IN_PRD_ATTRSTYLE.KNIT_OR_WOVEN, TRD_IN_PRD_ATTRSTYLE.FABRICATION, TRD_IN_PRD_ATTRSTYLE.SLEEVE_LENGTH, TRD_IN_PRD_ATTRSTYLE.LEG_OPENING, TRD_IN_PRD_ATTRSTYLE.BRAND, TRD_IN_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE, TRD_IN_PRD_ATTRSTYLE.OCCASION_USAGE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_ATTRSTYLECLR_super /*+basename(TRD_IN_PRD_ATTRSTYLECLR),createtype(L)*/ 
(
 MEMBER_ID,
 ITEM_DIFF_1,
 UNIT_RETAIL,
 UNIT_RETAIL_CAD,
 PATTERN,
 GRAPHIC,
 FASHION_BASIC,
 HOLIDAY,
 PROPERTY_TYPE,
 INTERNET_EXCLUSIVE,
 WEB_COLOR_DISCRIPTION,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 SEASON_CODE,
 DTR,
 DW_COLOR_FAMILY,
 CHANNEL_REORDER,
 TICKET_SEASON_CODE,
 SUB_PROGRAMS,
 MUSIC_GENRE,
 CLEARANCE_STR_PRODUCT,
 PO_SUPPLIER,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 ROYALTY,
 DUTY,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 PRIMARY_SUPPLIER,
 SUB_BRAND,
 PATTERN_TYPE,
 POP_PRINT_NEUTRAL,
 DEBUT_SEASON_CODE,
 MATCHBACK,
 PRIMARY_COLLECTION,
 SECONDARY_COLLECTION,
 VPN_COLOR,
 ORIG_UNIT_RETAIL,
 ORIG_UNIT_RETAIL_CAD,
 FIRST_REC_WEEK,
 FIRST_INV_WEEK,
 FIRST_SALE_WEEK,
 FIRST_MD_WEEK,
 LAST_MD_WEEK,
 LAST_REC_WEEK,
 STORE_PRICE_STATUS,
 IFC_PRICE_STATUS,
 OMNI_PRICE_TYPE,
 STYLECOLOR_CREATE_DATE,
 PRICE_BAND,
 GOOD_BETTER_BEST,
 SUPP_COST,
 FINISH,
 LICENSE,
 CHANNEL_AVAILABILITY,
 EXTENDED_SIZE,
 OP_MARKDOWN_WEEK,
 MOTIF,
 RP_REVISED_MARKDOWN_WEEK,
 WEB_CURRENT_RETAIL,
 PARENT_SEASON_CODE,
 ART_CODE,
 MATERIAL_CONTENT,
 FABRICATION,
 STYLECOLOR_ATTRIBUTE_1,
 STYLECOLOR_ATTRIBUTE_2,
 STYLECOLOR_ATTRIBUTE_3,
 STYLECOLOR_ATTRIBUTE_4,
 STYLECOLOR_ATTRIBUTE_5,
 STYLECOLOR_ATTRIBUTE_6,
 STYLECOLOR_ATTRIBUTE_7,
 STYLECOLOR_ATTRIBUTE_8,
 STYLECOLOR_ATTRIBUTE_9,
 STYLECOLOR_ATTRIBUTE_10,
 STYLECOLOR_ATTRIBUTE_11,
 STYLECOLOR_ATTRIBUTE_12
)
AS
 SELECT TRD_IN_PRD_ATTRSTYLECLR.MEMBER_ID,
        TRD_IN_PRD_ATTRSTYLECLR.ITEM_DIFF_1,
        TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL,
        TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD,
        TRD_IN_PRD_ATTRSTYLECLR.PATTERN,
        TRD_IN_PRD_ATTRSTYLECLR.GRAPHIC,
        TRD_IN_PRD_ATTRSTYLECLR.FASHION_BASIC,
        TRD_IN_PRD_ATTRSTYLECLR.HOLIDAY,
        TRD_IN_PRD_ATTRSTYLECLR.PROPERTY_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR.INTERNET_EXCLUSIVE,
        TRD_IN_PRD_ATTRSTYLECLR.WEB_COLOR_DISCRIPTION,
        TRD_IN_PRD_ATTRSTYLECLR.EXPORT_HTS,
        TRD_IN_PRD_ATTRSTYLECLR.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_IN_PRD_ATTRSTYLECLR.SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR.DTR,
        TRD_IN_PRD_ATTRSTYLECLR.DW_COLOR_FAMILY,
        TRD_IN_PRD_ATTRSTYLECLR.CHANNEL_REORDER,
        TRD_IN_PRD_ATTRSTYLECLR.TICKET_SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR.SUB_PROGRAMS,
        TRD_IN_PRD_ATTRSTYLECLR.MUSIC_GENRE,
        TRD_IN_PRD_ATTRSTYLECLR.CLEARANCE_STR_PRODUCT,
        TRD_IN_PRD_ATTRSTYLECLR.PO_SUPPLIER,
        TRD_IN_PRD_ATTRSTYLECLR.ORIGIN_COUNTRY_ID,
        TRD_IN_PRD_ATTRSTYLECLR.COUNTRY_OF_SOURCING,
        TRD_IN_PRD_ATTRSTYLECLR.COUNTRY_OF_MANUFACTURING,
        TRD_IN_PRD_ATTRSTYLECLR.UNIT_COST,
        TRD_IN_PRD_ATTRSTYLECLR.FREIGHT,
        TRD_IN_PRD_ATTRSTYLECLR.ROYALTY,
        TRD_IN_PRD_ATTRSTYLECLR.DUTY,
        TRD_IN_PRD_ATTRSTYLECLR.SHIP_METHOD,
        TRD_IN_PRD_ATTRSTYLECLR.LADING_PORT,
        TRD_IN_PRD_ATTRSTYLECLR.HTS,
        TRD_IN_PRD_ATTRSTYLECLR.PRIMARY_SUPPLIER,
        TRD_IN_PRD_ATTRSTYLECLR.SUB_BRAND,
        TRD_IN_PRD_ATTRSTYLECLR.PATTERN_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR.POP_PRINT_NEUTRAL,
        TRD_IN_PRD_ATTRSTYLECLR.DEBUT_SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR.MATCHBACK,
        TRD_IN_PRD_ATTRSTYLECLR.PRIMARY_COLLECTION,
        TRD_IN_PRD_ATTRSTYLECLR.SECONDARY_COLLECTION,
        TRD_IN_PRD_ATTRSTYLECLR.VPN_COLOR,
        TRD_IN_PRD_ATTRSTYLECLR.ORIG_UNIT_RETAIL,
        TRD_IN_PRD_ATTRSTYLECLR.ORIG_UNIT_RETAIL_CAD,
        TRD_IN_PRD_ATTRSTYLECLR.FIRST_REC_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.FIRST_INV_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.FIRST_SALE_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.FIRST_MD_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.LAST_MD_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.LAST_REC_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.STORE_PRICE_STATUS,
        TRD_IN_PRD_ATTRSTYLECLR.IFC_PRICE_STATUS,
        TRD_IN_PRD_ATTRSTYLECLR.OMNI_PRICE_TYPE,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_CREATE_DATE,
        TRD_IN_PRD_ATTRSTYLECLR.PRICE_BAND,
        TRD_IN_PRD_ATTRSTYLECLR.GOOD_BETTER_BEST,
        TRD_IN_PRD_ATTRSTYLECLR.SUPP_COST,
        TRD_IN_PRD_ATTRSTYLECLR.FINISH,
        TRD_IN_PRD_ATTRSTYLECLR.LICENSE,
        TRD_IN_PRD_ATTRSTYLECLR.CHANNEL_AVAILABILITY,
        TRD_IN_PRD_ATTRSTYLECLR.EXTENDED_SIZE,
        TRD_IN_PRD_ATTRSTYLECLR.OP_MARKDOWN_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.MOTIF,
        TRD_IN_PRD_ATTRSTYLECLR.RP_REVISED_MARKDOWN_WEEK,
        TRD_IN_PRD_ATTRSTYLECLR.WEB_CURRENT_RETAIL,
        TRD_IN_PRD_ATTRSTYLECLR.PARENT_SEASON_CODE,
        TRD_IN_PRD_ATTRSTYLECLR.ART_CODE,
        TRD_IN_PRD_ATTRSTYLECLR.MATERIAL_CONTENT,
        TRD_IN_PRD_ATTRSTYLECLR.FABRICATION,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_1,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_2,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_3,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_4,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_5,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_6,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_7,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_8,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_9,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_10,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_11,
        TRD_IN_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_12
 FROM public.TRD_IN_PRD_ATTRSTYLECLR
 ORDER BY TRD_IN_PRD_ATTRSTYLECLR.MEMBER_ID,
          TRD_IN_PRD_ATTRSTYLECLR.ITEM_DIFF_1,
          TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL,
          TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD,
          TRD_IN_PRD_ATTRSTYLECLR.PATTERN,
          TRD_IN_PRD_ATTRSTYLECLR.GRAPHIC,
          TRD_IN_PRD_ATTRSTYLECLR.FASHION_BASIC,
          TRD_IN_PRD_ATTRSTYLECLR.HOLIDAY
SEGMENTED BY hash(TRD_IN_PRD_ATTRSTYLECLR.MEMBER_ID, TRD_IN_PRD_ATTRSTYLECLR.ITEM_DIFF_1, TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL, TRD_IN_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD, TRD_IN_PRD_ATTRSTYLECLR.PATTERN, TRD_IN_PRD_ATTRSTYLECLR.GRAPHIC, TRD_IN_PRD_ATTRSTYLECLR.FASHION_BASIC, TRD_IN_PRD_ATTRSTYLECLR.HOLIDAY) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_SPECSTYLEATTRIBUTES_super /*+basename(TRD_IN_PRD_SPECSTYLEATTRIBUTES),createtype(L)*/ 
(
 VPN_VSN,
 VPN_DESCRIPTION,
 DEPT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 TICKET_TYPE,
 KNIT_OR_WOVEN,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 v_360_SMOOTHING,
 KNIT_FIT,
 DESIGN_STYLE_STATUS,
 SIZE_RANGE,
 SPEC_STYLE_OPEN1,
 SPEC_STYLE_OPEN2,
 SPEC_STYLE_OPEN3,
 SPEC_STYLE_OPEN4,
 SPEC_STYLE_OPEN5,
 SPEC_STYLE_OPEN6,
 SPEC_STYLE_OPEN7,
 SPEC_STYLE_OPEN8
)
AS
 SELECT TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_VSN,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.DEPT_ID,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.CLASS_ID,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SUBCLASS_ID,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.TICKET_TYPE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.LEG_OPENING,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.BRAND,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.LICENSE_VS_NON_LICENSED,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.HAZMAT_CODE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.PROP_65_WARNING,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.MATERIAL_CONTENT,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.DWRISE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.LENGTH,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.NECKLINE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.TOESHAPE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.HEEL_HEIGHT,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.BOTTOM_LENGTH,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.v_360_SMOOTHING,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.KNIT_FIT,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.DESIGN_STYLE_STATUS,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SIZE_RANGE,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN1,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN2,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN3,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN4,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN5,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN6,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN7,
        TRD_IN_PRD_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN8
 FROM public.TRD_IN_PRD_SPECSTYLEATTRIBUTES
 ORDER BY TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_VSN,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.DEPT_ID,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.CLASS_ID,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.SUBCLASS_ID,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.TICKET_TYPE,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN,
          TRD_IN_PRD_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH
SEGMENTED BY hash(TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_VSN, TRD_IN_PRD_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION, TRD_IN_PRD_SPECSTYLEATTRIBUTES.DEPT_ID, TRD_IN_PRD_SPECSTYLEATTRIBUTES.CLASS_ID, TRD_IN_PRD_SPECSTYLEATTRIBUTES.SUBCLASS_ID, TRD_IN_PRD_SPECSTYLEATTRIBUTES.TICKET_TYPE, TRD_IN_PRD_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN, TRD_IN_PRD_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_PRD_ATTRSTYLE_super /*+basename(TRD_REJ_PRD_ATTRSTYLE),createtype(L)*/ 
(
 MEMBER_ID,
 KNIT_OR_WOVEN,
 FABRICATION,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 BODY_STYLE_SILHOUETTE,
 OCCASION_USAGE,
 DETAIL,
 FINISH_STYLE,
 PRIVATE_LABEL,
 LICENSE,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 ITEM_TYPE,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 V_360_SMOOTHING,
 FRANCHISE,
 KEY_ITEM,
 SINGLE_VS_MULTI_PACK,
 TICKET_TYPE,
 VPN,
 SIZE_RANGE,
 RMS_STYLECOLOR_CREATE_DATE,
 KNIT_FIT,
 STYLE_ATTRIBUTE_1,
 STYLE_ATTRIBUTE_2,
 STYLE_ATTRIBUTE_3,
 STYLE_ATTRIBUTE_4,
 STYLE_ATTRIBUTE_5,
 STYLE_ATTRIBUTE_6,
 STYLE_ATTRIBUTE_7,
 STYLE_ATTRIBUTE_8,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_PRD_ATTRSTYLE.MEMBER_ID,
        TRD_REJ_PRD_ATTRSTYLE.KNIT_OR_WOVEN,
        TRD_REJ_PRD_ATTRSTYLE.FABRICATION,
        TRD_REJ_PRD_ATTRSTYLE.SLEEVE_LENGTH,
        TRD_REJ_PRD_ATTRSTYLE.LEG_OPENING,
        TRD_REJ_PRD_ATTRSTYLE.BRAND,
        TRD_REJ_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE,
        TRD_REJ_PRD_ATTRSTYLE.OCCASION_USAGE,
        TRD_REJ_PRD_ATTRSTYLE.DETAIL,
        TRD_REJ_PRD_ATTRSTYLE.FINISH_STYLE,
        TRD_REJ_PRD_ATTRSTYLE.PRIVATE_LABEL,
        TRD_REJ_PRD_ATTRSTYLE.LICENSE,
        TRD_REJ_PRD_ATTRSTYLE.LICENSE_VS_NON_LICENSED,
        TRD_REJ_PRD_ATTRSTYLE.HAZMAT_CODE,
        TRD_REJ_PRD_ATTRSTYLE.PROP_65_WARNING,
        TRD_REJ_PRD_ATTRSTYLE.MATERIAL_CONTENT,
        TRD_REJ_PRD_ATTRSTYLE.ITEM_TYPE,
        TRD_REJ_PRD_ATTRSTYLE.DWRISE,
        TRD_REJ_PRD_ATTRSTYLE.LENGTH,
        TRD_REJ_PRD_ATTRSTYLE.NECKLINE,
        TRD_REJ_PRD_ATTRSTYLE.TOESHAPE,
        TRD_REJ_PRD_ATTRSTYLE.HEEL_HEIGHT,
        TRD_REJ_PRD_ATTRSTYLE.BOTTOM_LENGTH,
        TRD_REJ_PRD_ATTRSTYLE.V_360_SMOOTHING,
        TRD_REJ_PRD_ATTRSTYLE.FRANCHISE,
        TRD_REJ_PRD_ATTRSTYLE.KEY_ITEM,
        TRD_REJ_PRD_ATTRSTYLE.SINGLE_VS_MULTI_PACK,
        TRD_REJ_PRD_ATTRSTYLE.TICKET_TYPE,
        TRD_REJ_PRD_ATTRSTYLE.VPN,
        TRD_REJ_PRD_ATTRSTYLE.SIZE_RANGE,
        TRD_REJ_PRD_ATTRSTYLE.RMS_STYLECOLOR_CREATE_DATE,
        TRD_REJ_PRD_ATTRSTYLE.KNIT_FIT,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_1,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_2,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_3,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_4,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_5,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_6,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_7,
        TRD_REJ_PRD_ATTRSTYLE.STYLE_ATTRIBUTE_8,
        TRD_REJ_PRD_ATTRSTYLE.REJECT_REASON
 FROM public.TRD_REJ_PRD_ATTRSTYLE
 ORDER BY TRD_REJ_PRD_ATTRSTYLE.MEMBER_ID,
          TRD_REJ_PRD_ATTRSTYLE.KNIT_OR_WOVEN,
          TRD_REJ_PRD_ATTRSTYLE.FABRICATION,
          TRD_REJ_PRD_ATTRSTYLE.SLEEVE_LENGTH,
          TRD_REJ_PRD_ATTRSTYLE.LEG_OPENING,
          TRD_REJ_PRD_ATTRSTYLE.BRAND,
          TRD_REJ_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE,
          TRD_REJ_PRD_ATTRSTYLE.OCCASION_USAGE
SEGMENTED BY hash(TRD_REJ_PRD_ATTRSTYLE.REJECT_REASON, TRD_REJ_PRD_ATTRSTYLE.MEMBER_ID, TRD_REJ_PRD_ATTRSTYLE.KNIT_OR_WOVEN, TRD_REJ_PRD_ATTRSTYLE.FABRICATION, TRD_REJ_PRD_ATTRSTYLE.SLEEVE_LENGTH, TRD_REJ_PRD_ATTRSTYLE.LEG_OPENING, TRD_REJ_PRD_ATTRSTYLE.BRAND, TRD_REJ_PRD_ATTRSTYLE.BODY_STYLE_SILHOUETTE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_PRD_ATTRSTYLECLR_super /*+basename(TRD_REJ_PRD_ATTRSTYLECLR),createtype(L)*/ 
(
 MEMBER_ID,
 ITEM_DIFF_1,
 UNIT_RETAIL,
 UNIT_RETAIL_CAD,
 PATTERN,
 GRAPHIC,
 FASHION_BASIC,
 HOLIDAY,
 PROPERTY_TYPE,
 INTERNET_EXCLUSIVE,
 WEB_COLOR_DISCRIPTION,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 SEASON_CODE,
 DTR,
 DW_COLOR_FAMILY,
 CHANNEL_REORDER,
 TICKET_SEASON_CODE,
 SUB_PROGRAMS,
 MUSIC_GENRE,
 CLEARANCE_STR_PRODUCT,
 PO_SUPPLIER,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 ROYALTY,
 DUTY,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 PRIMARY_SUPPLIER,
 SUB_BRAND,
 PATTERN_TYPE,
 POP_PRINT_NEUTRAL,
 DEBUT_SEASON_CODE,
 MATCHBACK,
 PRIMARY_COLLECTION,
 SECONDARY_COLLECTION,
 VPN_COLOR,
 ORIG_UNIT_RETAIL,
 ORIG_UNIT_RETAIL_CAD,
 FIRST_REC_WEEK,
 FIRST_INV_WEEK,
 FIRST_SALE_WEEK,
 FIRST_MD_WEEK,
 LAST_MD_WEEK,
 LAST_REC_WEEK,
 STORE_PRICE_STATUS,
 IFC_PRICE_STATUS,
 OMNI_PRICE_TYPE,
 STYLECOLOR_CREATE_DATE,
 PRICE_BAND,
 GOOD_BETTER_BEST,
 SUPP_COST,
 FINISH,
 LICENSE,
 CHANNEL_AVAILABILITY,
 EXTENDED_SIZE,
 OP_MARKDOWN_WEEK,
 MOTIF,
 RP_REVISED_MARKDOWN_WEEK,
 WEB_CURRENT_RETAIL,
 PARENT_SEASON_CODE,
 ART_CODE,
 MATERIAL_CONTENT,
 FABRICATION,
 STYLECOLOR_ATTRIBUTE_1,
 STYLECOLOR_ATTRIBUTE_2,
 STYLECOLOR_ATTRIBUTE_3,
 STYLECOLOR_ATTRIBUTE_4,
 STYLECOLOR_ATTRIBUTE_5,
 STYLECOLOR_ATTRIBUTE_6,
 STYLECOLOR_ATTRIBUTE_7,
 STYLECOLOR_ATTRIBUTE_8,
 STYLECOLOR_ATTRIBUTE_9,
 STYLECOLOR_ATTRIBUTE_10,
 STYLECOLOR_ATTRIBUTE_11,
 STYLECOLOR_ATTRIBUTE_12,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_PRD_ATTRSTYLECLR.MEMBER_ID,
        TRD_REJ_PRD_ATTRSTYLECLR.ITEM_DIFF_1,
        TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL,
        TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD,
        TRD_REJ_PRD_ATTRSTYLECLR.PATTERN,
        TRD_REJ_PRD_ATTRSTYLECLR.GRAPHIC,
        TRD_REJ_PRD_ATTRSTYLECLR.FASHION_BASIC,
        TRD_REJ_PRD_ATTRSTYLECLR.HOLIDAY,
        TRD_REJ_PRD_ATTRSTYLECLR.PROPERTY_TYPE,
        TRD_REJ_PRD_ATTRSTYLECLR.INTERNET_EXCLUSIVE,
        TRD_REJ_PRD_ATTRSTYLECLR.WEB_COLOR_DISCRIPTION,
        TRD_REJ_PRD_ATTRSTYLECLR.EXPORT_HTS,
        TRD_REJ_PRD_ATTRSTYLECLR.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_REJ_PRD_ATTRSTYLECLR.SEASON_CODE,
        TRD_REJ_PRD_ATTRSTYLECLR.DTR,
        TRD_REJ_PRD_ATTRSTYLECLR.DW_COLOR_FAMILY,
        TRD_REJ_PRD_ATTRSTYLECLR.CHANNEL_REORDER,
        TRD_REJ_PRD_ATTRSTYLECLR.TICKET_SEASON_CODE,
        TRD_REJ_PRD_ATTRSTYLECLR.SUB_PROGRAMS,
        TRD_REJ_PRD_ATTRSTYLECLR.MUSIC_GENRE,
        TRD_REJ_PRD_ATTRSTYLECLR.CLEARANCE_STR_PRODUCT,
        TRD_REJ_PRD_ATTRSTYLECLR.PO_SUPPLIER,
        TRD_REJ_PRD_ATTRSTYLECLR.ORIGIN_COUNTRY_ID,
        TRD_REJ_PRD_ATTRSTYLECLR.COUNTRY_OF_SOURCING,
        TRD_REJ_PRD_ATTRSTYLECLR.COUNTRY_OF_MANUFACTURING,
        TRD_REJ_PRD_ATTRSTYLECLR.UNIT_COST,
        TRD_REJ_PRD_ATTRSTYLECLR.FREIGHT,
        TRD_REJ_PRD_ATTRSTYLECLR.ROYALTY,
        TRD_REJ_PRD_ATTRSTYLECLR.DUTY,
        TRD_REJ_PRD_ATTRSTYLECLR.SHIP_METHOD,
        TRD_REJ_PRD_ATTRSTYLECLR.LADING_PORT,
        TRD_REJ_PRD_ATTRSTYLECLR.HTS,
        TRD_REJ_PRD_ATTRSTYLECLR.PRIMARY_SUPPLIER,
        TRD_REJ_PRD_ATTRSTYLECLR.SUB_BRAND,
        TRD_REJ_PRD_ATTRSTYLECLR.PATTERN_TYPE,
        TRD_REJ_PRD_ATTRSTYLECLR.POP_PRINT_NEUTRAL,
        TRD_REJ_PRD_ATTRSTYLECLR.DEBUT_SEASON_CODE,
        TRD_REJ_PRD_ATTRSTYLECLR.MATCHBACK,
        TRD_REJ_PRD_ATTRSTYLECLR.PRIMARY_COLLECTION,
        TRD_REJ_PRD_ATTRSTYLECLR.SECONDARY_COLLECTION,
        TRD_REJ_PRD_ATTRSTYLECLR.VPN_COLOR,
        TRD_REJ_PRD_ATTRSTYLECLR.ORIG_UNIT_RETAIL,
        TRD_REJ_PRD_ATTRSTYLECLR.ORIG_UNIT_RETAIL_CAD,
        TRD_REJ_PRD_ATTRSTYLECLR.FIRST_REC_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.FIRST_INV_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.FIRST_SALE_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.FIRST_MD_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.LAST_MD_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.LAST_REC_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.STORE_PRICE_STATUS,
        TRD_REJ_PRD_ATTRSTYLECLR.IFC_PRICE_STATUS,
        TRD_REJ_PRD_ATTRSTYLECLR.OMNI_PRICE_TYPE,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_CREATE_DATE,
        TRD_REJ_PRD_ATTRSTYLECLR.PRICE_BAND,
        TRD_REJ_PRD_ATTRSTYLECLR.GOOD_BETTER_BEST,
        TRD_REJ_PRD_ATTRSTYLECLR.SUPP_COST,
        TRD_REJ_PRD_ATTRSTYLECLR.FINISH,
        TRD_REJ_PRD_ATTRSTYLECLR.LICENSE,
        TRD_REJ_PRD_ATTRSTYLECLR.CHANNEL_AVAILABILITY,
        TRD_REJ_PRD_ATTRSTYLECLR.EXTENDED_SIZE,
        TRD_REJ_PRD_ATTRSTYLECLR.OP_MARKDOWN_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.MOTIF,
        TRD_REJ_PRD_ATTRSTYLECLR.RP_REVISED_MARKDOWN_WEEK,
        TRD_REJ_PRD_ATTRSTYLECLR.WEB_CURRENT_RETAIL,
        TRD_REJ_PRD_ATTRSTYLECLR.PARENT_SEASON_CODE,
        TRD_REJ_PRD_ATTRSTYLECLR.ART_CODE,
        TRD_REJ_PRD_ATTRSTYLECLR.MATERIAL_CONTENT,
        TRD_REJ_PRD_ATTRSTYLECLR.FABRICATION,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_1,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_2,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_3,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_4,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_5,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_6,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_7,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_8,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_9,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_10,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_11,
        TRD_REJ_PRD_ATTRSTYLECLR.STYLECOLOR_ATTRIBUTE_12,
        TRD_REJ_PRD_ATTRSTYLECLR.REJECT_REASON
 FROM public.TRD_REJ_PRD_ATTRSTYLECLR
 ORDER BY TRD_REJ_PRD_ATTRSTYLECLR.MEMBER_ID,
          TRD_REJ_PRD_ATTRSTYLECLR.ITEM_DIFF_1,
          TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL,
          TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD,
          TRD_REJ_PRD_ATTRSTYLECLR.PATTERN,
          TRD_REJ_PRD_ATTRSTYLECLR.GRAPHIC,
          TRD_REJ_PRD_ATTRSTYLECLR.FASHION_BASIC,
          TRD_REJ_PRD_ATTRSTYLECLR.HOLIDAY
SEGMENTED BY hash(TRD_REJ_PRD_ATTRSTYLECLR.REJECT_REASON, TRD_REJ_PRD_ATTRSTYLECLR.MEMBER_ID, TRD_REJ_PRD_ATTRSTYLECLR.ITEM_DIFF_1, TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL, TRD_REJ_PRD_ATTRSTYLECLR.UNIT_RETAIL_CAD, TRD_REJ_PRD_ATTRSTYLECLR.PATTERN, TRD_REJ_PRD_ATTRSTYLECLR.GRAPHIC, TRD_REJ_PRD_ATTRSTYLECLR.FASHION_BASIC) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING_super /*+basename(TRD_IN_BUS_DEPT_FLOORSET_MAPPING),createtype(L)*/ 
(
 DEPT_ID,
 NEW_FLOORSET_ID,
 FLOORSET_ID
)
AS
 SELECT TRD_IN_BUS_DEPT_FLOORSET_MAPPING.DEPT_ID,
        TRD_IN_BUS_DEPT_FLOORSET_MAPPING.NEW_FLOORSET_ID,
        TRD_IN_BUS_DEPT_FLOORSET_MAPPING.FLOORSET_ID
 FROM public.TRD_IN_BUS_DEPT_FLOORSET_MAPPING
 ORDER BY TRD_IN_BUS_DEPT_FLOORSET_MAPPING.DEPT_ID,
          TRD_IN_BUS_DEPT_FLOORSET_MAPPING.NEW_FLOORSET_ID,
          TRD_IN_BUS_DEPT_FLOORSET_MAPPING.FLOORSET_ID
SEGMENTED BY hash(TRD_IN_BUS_DEPT_FLOORSET_MAPPING.DEPT_ID, TRD_IN_BUS_DEPT_FLOORSET_MAPPING.NEW_FLOORSET_ID, TRD_IN_BUS_DEPT_FLOORSET_MAPPING.FLOORSET_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_dptflrset_verification_super /*+basename(trd_dptflrset_verification),createtype(L)*/ 
(
 Product_Dept_ID,
 Dept_Name,
 Superset_ID,
 Superset_Name,
 Floorset_ID,
 Floorset_Name,
 Initialrcptwk,
 Rcptstart,
 Rcptend,
 Slsstart,
 Slsend,
 Weeks_At_FP,
 Markdown_Week,
 Exit_Week,
 LY_Rcptstart,
 LY_Rcptend,
 LY_Slsstart,
 LY_Slsend,
 AP_Start,
 AP_End,
 Planned_Sell_Down_Week,
 Floorset_UDA,
 LY_Floorset_UDA
)
AS
 SELECT trd_dptflrset_verification.Product_Dept_ID,
        trd_dptflrset_verification.Dept_Name,
        trd_dptflrset_verification.Superset_ID,
        trd_dptflrset_verification.Superset_Name,
        trd_dptflrset_verification.Floorset_ID,
        trd_dptflrset_verification.Floorset_Name,
        trd_dptflrset_verification.Initialrcptwk,
        trd_dptflrset_verification.Rcptstart,
        trd_dptflrset_verification.Rcptend,
        trd_dptflrset_verification.Slsstart,
        trd_dptflrset_verification.Slsend,
        trd_dptflrset_verification.Weeks_At_FP,
        trd_dptflrset_verification.Markdown_Week,
        trd_dptflrset_verification.Exit_Week,
        trd_dptflrset_verification.LY_Rcptstart,
        trd_dptflrset_verification.LY_Rcptend,
        trd_dptflrset_verification.LY_Slsstart,
        trd_dptflrset_verification.LY_Slsend,
        trd_dptflrset_verification.AP_Start,
        trd_dptflrset_verification.AP_End,
        trd_dptflrset_verification.Planned_Sell_Down_Week,
        trd_dptflrset_verification.Floorset_UDA,
        trd_dptflrset_verification.LY_Floorset_UDA
 FROM public.trd_dptflrset_verification
 ORDER BY trd_dptflrset_verification.Product_Dept_ID,
          trd_dptflrset_verification.Dept_Name,
          trd_dptflrset_verification.Superset_ID,
          trd_dptflrset_verification.Superset_Name,
          trd_dptflrset_verification.Floorset_ID,
          trd_dptflrset_verification.Floorset_Name,
          trd_dptflrset_verification.Initialrcptwk,
          trd_dptflrset_verification.Rcptstart
SEGMENTED BY hash(trd_dptflrset_verification.Product_Dept_ID, trd_dptflrset_verification.Dept_Name, trd_dptflrset_verification.Superset_ID, trd_dptflrset_verification.Superset_Name, trd_dptflrset_verification.Floorset_ID, trd_dptflrset_verification.Floorset_Name, trd_dptflrset_verification.Initialrcptwk, trd_dptflrset_verification.Rcptstart) ALL NODES OFFSET 0;

CREATE PROJECTION public.prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE_super /*+basename(prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE),createtype(A)*/ 
(
 "time",
 start_date,
 end_date,
 trd_time
)
AS
 SELECT prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE."time",
        prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.start_date,
        prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.end_date,
        prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.trd_time
 FROM public.prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE
 ORDER BY prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE."time",
          prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.start_date,
          prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.end_date
SEGMENTED BY hash(prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE."time", prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.start_date, prev_NRF_WEEK_ATTRIBUTES_WITH_TRD_WEEKDATE.end_date) ALL NODES OFFSET 0;

CREATE PROJECTION public.prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME_super /*+basename(prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME),createtype(A)*/ 
(
 Event,
 Week,
 WeekIndx,
 MonthIndx,
 year,
 trd_time,
 trd_month,
 trd_WeekIndx,
 trd_MonthIndx
)
AS
 SELECT prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.Event,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.Week,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.WeekIndx,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.MonthIndx,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.year,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.trd_time,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.trd_month,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.trd_WeekIndx,
        prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.trd_MonthIndx
 FROM public.prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME
 ORDER BY prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.Week
SEGMENTED BY hash(prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.WeekIndx, prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.MonthIndx, prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.year, prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.Event, prev_NRF_ANALYTICS_EVENT_MAPPING_TRD_TIME.Week) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_ma_stylecolorattributes_existing_super /*+basename(deleteme_trd_ma_stylecolorattributes_existing),createtype(L)*/ 
(
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
 stylecolor_name,
 style_name,
 buyer_email
)
AS
 SELECT deleteme_trd_ma_stylecolorattributes_existing.product,
        deleteme_trd_ma_stylecolorattributes_existing.cc_item_diff_1,
        deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail,
        deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail_cad,
        deleteme_trd_ma_stylecolorattributes_existing.cc_pattern,
        deleteme_trd_ma_stylecolorattributes_existing.cc_graphic,
        deleteme_trd_ma_stylecolorattributes_existing.cc_fashion_basic,
        deleteme_trd_ma_stylecolorattributes_existing.cc_holiday,
        deleteme_trd_ma_stylecolorattributes_existing.cc_property_type,
        deleteme_trd_ma_stylecolorattributes_existing.cc_internet_exclusive,
        deleteme_trd_ma_stylecolorattributes_existing.cc_web_color_discription,
        deleteme_trd_ma_stylecolorattributes_existing.cc_export_hts,
        deleteme_trd_ma_stylecolorattributes_existing.cc_commercial_invoice_description,
        deleteme_trd_ma_stylecolorattributes_existing.cc_season_code,
        deleteme_trd_ma_stylecolorattributes_existing.cc_dtr,
        deleteme_trd_ma_stylecolorattributes_existing.cc_dw_color_family,
        deleteme_trd_ma_stylecolorattributes_existing.cc_channel_reorder,
        deleteme_trd_ma_stylecolorattributes_existing.cc_ticket_season_code,
        deleteme_trd_ma_stylecolorattributes_existing.cc_sub_programs,
        deleteme_trd_ma_stylecolorattributes_existing.cc_music_genre,
        deleteme_trd_ma_stylecolorattributes_existing.cc_clearance_str_product,
        deleteme_trd_ma_stylecolorattributes_existing.cc_po_supplier,
        deleteme_trd_ma_stylecolorattributes_existing.cc_origin_country_id,
        deleteme_trd_ma_stylecolorattributes_existing.cc_country_of_sourcing,
        deleteme_trd_ma_stylecolorattributes_existing.cc_country_of_manufacturing,
        deleteme_trd_ma_stylecolorattributes_existing.cc_unit_cost,
        deleteme_trd_ma_stylecolorattributes_existing.cc_freight,
        deleteme_trd_ma_stylecolorattributes_existing.cc_royalty,
        deleteme_trd_ma_stylecolorattributes_existing.cc_duty,
        deleteme_trd_ma_stylecolorattributes_existing.cc_ship_method,
        deleteme_trd_ma_stylecolorattributes_existing.cc_lading_port,
        deleteme_trd_ma_stylecolorattributes_existing.cc_hts,
        deleteme_trd_ma_stylecolorattributes_existing.cc_primary_supplier,
        deleteme_trd_ma_stylecolorattributes_existing.cc_sub_brand,
        deleteme_trd_ma_stylecolorattributes_existing.cc_pattern_type,
        deleteme_trd_ma_stylecolorattributes_existing.cc_pop_print_neutral,
        deleteme_trd_ma_stylecolorattributes_existing.cc_debut_season_code,
        deleteme_trd_ma_stylecolorattributes_existing.cc_matchback,
        deleteme_trd_ma_stylecolorattributes_existing.cc_primary_collection,
        deleteme_trd_ma_stylecolorattributes_existing.cc_secondary_collection,
        deleteme_trd_ma_stylecolorattributes_existing.cc_vpn_color,
        deleteme_trd_ma_stylecolorattributes_existing.cc_orig_unit_retail,
        deleteme_trd_ma_stylecolorattributes_existing.cc_orig_unit_retail_cad,
        deleteme_trd_ma_stylecolorattributes_existing.cc_first_rec_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_first_inv_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_first_sale_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_first_md_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_last_md_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_last_rec_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_store_price_status,
        deleteme_trd_ma_stylecolorattributes_existing.cc_ifc_price_status,
        deleteme_trd_ma_stylecolorattributes_existing.cc_omni_price_type,
        deleteme_trd_ma_stylecolorattributes_existing.ccstylecolorcreatedate,
        deleteme_trd_ma_stylecolorattributes_existing.cc_price_band,
        deleteme_trd_ma_stylecolorattributes_existing.cc_good_better_best,
        deleteme_trd_ma_stylecolorattributes_existing.cccolor,
        deleteme_trd_ma_stylecolorattributes_existing.cccolorfamily,
        deleteme_trd_ma_stylecolorattributes_existing.total_brand_name,
        deleteme_trd_ma_stylecolorattributes_existing.division_name,
        deleteme_trd_ma_stylecolorattributes_existing.group_name,
        deleteme_trd_ma_stylecolorattributes_existing.department_name,
        deleteme_trd_ma_stylecolorattributes_existing.class_name,
        deleteme_trd_ma_stylecolorattributes_existing.subclass_name,
        deleteme_trd_ma_stylecolorattributes_existing.eventdate,
        deleteme_trd_ma_stylecolorattributes_existing.version_id,
        deleteme_trd_ma_stylecolorattributes_existing.created_at,
        deleteme_trd_ma_stylecolorattributes_existing.created_by,
        deleteme_trd_ma_stylecolorattributes_existing.updated_at,
        deleteme_trd_ma_stylecolorattributes_existing.updated_by,
        deleteme_trd_ma_stylecolorattributes_existing.record_state,
        deleteme_trd_ma_stylecolorattributes_existing.isassortment,
        deleteme_trd_ma_stylecolorattributes_existing.merch_comments,
        deleteme_trd_ma_stylecolorattributes_existing.plan_comments,
        deleteme_trd_ma_stylecolorattributes_existing.cc_is_locked,
        deleteme_trd_ma_stylecolorattributes_existing.cc_s5_adopted,
        deleteme_trd_ma_stylecolorattributes_existing.cc_prepublish,
        deleteme_trd_ma_stylecolorattributes_existing.cc_prepublished_at,
        deleteme_trd_ma_stylecolorattributes_existing.allocator_comments,
        deleteme_trd_ma_stylecolorattributes_existing.cccolorid,
        deleteme_trd_ma_stylecolorattributes_existing.cc_specstylecolor_status,
        deleteme_trd_ma_stylecolorattributes_existing.cc_agent_fee,
        deleteme_trd_ma_stylecolorattributes_existing.cc_port,
        deleteme_trd_ma_stylecolorattributes_existing.cc_factory,
        deleteme_trd_ma_stylecolorattributes_existing.cc_floorset,
        deleteme_trd_ma_stylecolorattributes_existing.cc_use_sys_floorset,
        deleteme_trd_ma_stylecolorattributes_existing.cc_supp_cost,
        deleteme_trd_ma_stylecolorattributes_existing.cc_finish,
        deleteme_trd_ma_stylecolorattributes_existing.cc_license,
        deleteme_trd_ma_stylecolorattributes_existing.cc_channel_availability,
        deleteme_trd_ma_stylecolorattributes_existing.cc_extended_size,
        deleteme_trd_ma_stylecolorattributes_existing.cc_op_markdown_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_motif,
        deleteme_trd_ma_stylecolorattributes_existing.cc_rp_revised_markdown_week,
        deleteme_trd_ma_stylecolorattributes_existing.cc_web_current_retail,
        deleteme_trd_ma_stylecolorattributes_existing.cc_parent_season_code,
        deleteme_trd_ma_stylecolorattributes_existing.cc_art_code,
        deleteme_trd_ma_stylecolorattributes_existing.cc_patterned_after,
        deleteme_trd_ma_stylecolorattributes_existing.cc_material_content,
        deleteme_trd_ma_stylecolorattributes_existing.cc_fabrication,
        deleteme_trd_ma_stylecolorattributes_existing.stylecolor_name,
        deleteme_trd_ma_stylecolorattributes_existing.style_name,
        deleteme_trd_ma_stylecolorattributes_existing.buyer_email
 FROM public.deleteme_trd_ma_stylecolorattributes_existing
 ORDER BY deleteme_trd_ma_stylecolorattributes_existing.product,
          deleteme_trd_ma_stylecolorattributes_existing.cc_item_diff_1,
          deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail,
          deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail_cad,
          deleteme_trd_ma_stylecolorattributes_existing.cc_pattern,
          deleteme_trd_ma_stylecolorattributes_existing.cc_graphic,
          deleteme_trd_ma_stylecolorattributes_existing.cc_fashion_basic,
          deleteme_trd_ma_stylecolorattributes_existing.cc_holiday
SEGMENTED BY hash(deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail, deleteme_trd_ma_stylecolorattributes_existing.cc_unit_retail_cad, deleteme_trd_ma_stylecolorattributes_existing.cc_unit_cost, deleteme_trd_ma_stylecolorattributes_existing.cc_orig_unit_retail, deleteme_trd_ma_stylecolorattributes_existing.cc_orig_unit_retail_cad, deleteme_trd_ma_stylecolorattributes_existing.eventdate, deleteme_trd_ma_stylecolorattributes_existing.version_id, deleteme_trd_ma_stylecolorattributes_existing.created_at) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_REPLANNABLE_STYLECOLORS_super /*+basename(TRD_IN_PRD_REPLANNABLE_STYLECOLORS),createtype(L)*/ 
(
 STYLECOLOR_ID
)
AS
 SELECT TRD_IN_PRD_REPLANNABLE_STYLECOLORS.STYLECOLOR_ID
 FROM public.TRD_IN_PRD_REPLANNABLE_STYLECOLORS
 ORDER BY TRD_IN_PRD_REPLANNABLE_STYLECOLORS.STYLECOLOR_ID
SEGMENTED BY hash(TRD_IN_PRD_REPLANNABLE_STYLECOLORS.STYLECOLOR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_c_conversion_file_super /*+basename(trd_c_conversion_file),createtype(L)*/ 
(
 FLOORSET_CODE,
 DEPARTMENT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 STYLE_ID,
 STYLE_COLOR_ID,
 STYLE_COLOR_DESC,
 TICKET_PRICE,
 COST,
 DEFAULT_DISC,
 DEBUT_WEEK,
 MD_WEEK,
 EXIT_WEEK,
 AUTO_ROLL_FORWARD,
 PLANNED_SELL_DOWN_WK,
 MD_STRATEGY,
 STORE_VOL_GRADE,
 STORE_CLIMATE,
 STORE_CAPACITY,
 STORE_BANNER,
 STORE_REGION,
 STORE_HAZMAT,
 SSG,
 SIZE_RANGE,
 VALID_SIZES_STORES,
 VALID_SIZES_ECOM,
 SIZE_MIN,
 SIZE_MIN_WEEKS,
 PRE_SSN_RATING_STRS,
 PRE_SSN_RATING_ECOM,
 RECEIPT_INTERVAL,
 RETURN_RATE_STRS,
 RETURN_RATE_ECOM,
 CROSS_CHANNEL_RET_RATE,
 ORDER_MIN,
 ORDER_MULTIPLE,
 LEAD_TIME_DEFAULT
)
AS
 SELECT trd_c_conversion_file.FLOORSET_CODE,
        trd_c_conversion_file.DEPARTMENT_ID,
        trd_c_conversion_file.CLASS_ID,
        trd_c_conversion_file.SUBCLASS_ID,
        trd_c_conversion_file.STYLE_ID,
        trd_c_conversion_file.STYLE_COLOR_ID,
        trd_c_conversion_file.STYLE_COLOR_DESC,
        trd_c_conversion_file.TICKET_PRICE,
        trd_c_conversion_file.COST,
        trd_c_conversion_file.DEFAULT_DISC,
        trd_c_conversion_file.DEBUT_WEEK,
        trd_c_conversion_file.MD_WEEK,
        trd_c_conversion_file.EXIT_WEEK,
        trd_c_conversion_file.AUTO_ROLL_FORWARD,
        trd_c_conversion_file.PLANNED_SELL_DOWN_WK,
        trd_c_conversion_file.MD_STRATEGY,
        trd_c_conversion_file.STORE_VOL_GRADE,
        trd_c_conversion_file.STORE_CLIMATE,
        trd_c_conversion_file.STORE_CAPACITY,
        trd_c_conversion_file.STORE_BANNER,
        trd_c_conversion_file.STORE_REGION,
        trd_c_conversion_file.STORE_HAZMAT,
        trd_c_conversion_file.SSG,
        trd_c_conversion_file.SIZE_RANGE,
        trd_c_conversion_file.VALID_SIZES_STORES,
        trd_c_conversion_file.VALID_SIZES_ECOM,
        trd_c_conversion_file.SIZE_MIN,
        trd_c_conversion_file.SIZE_MIN_WEEKS,
        trd_c_conversion_file.PRE_SSN_RATING_STRS,
        trd_c_conversion_file.PRE_SSN_RATING_ECOM,
        trd_c_conversion_file.RECEIPT_INTERVAL,
        trd_c_conversion_file.RETURN_RATE_STRS,
        trd_c_conversion_file.RETURN_RATE_ECOM,
        trd_c_conversion_file.CROSS_CHANNEL_RET_RATE,
        trd_c_conversion_file.ORDER_MIN,
        trd_c_conversion_file.ORDER_MULTIPLE,
        trd_c_conversion_file.LEAD_TIME_DEFAULT
 FROM public.trd_c_conversion_file
 ORDER BY trd_c_conversion_file.FLOORSET_CODE,
          trd_c_conversion_file.DEPARTMENT_ID,
          trd_c_conversion_file.CLASS_ID,
          trd_c_conversion_file.SUBCLASS_ID,
          trd_c_conversion_file.STYLE_ID,
          trd_c_conversion_file.STYLE_COLOR_ID,
          trd_c_conversion_file.STYLE_COLOR_DESC,
          trd_c_conversion_file.TICKET_PRICE
SEGMENTED BY hash(trd_c_conversion_file.TICKET_PRICE, trd_c_conversion_file.COST, trd_c_conversion_file.DEFAULT_DISC, trd_c_conversion_file.AUTO_ROLL_FORWARD, trd_c_conversion_file.SIZE_MIN, trd_c_conversion_file.SIZE_MIN_WEEKS, trd_c_conversion_file.PRE_SSN_RATING_STRS, trd_c_conversion_file.PRE_SSN_RATING_ECOM) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_c_conversion_file_validcc_super /*+basename(trd_c_conversion_file_validcc),createtype(A)*/ 
(
 FLOORSET_CODE,
 DEPARTMENT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 STYLE_ID,
 STYLE_COLOR_ID,
 STYLE_COLOR_DESC,
 TICKET_PRICE,
 COST,
 DEFAULT_DISC,
 DEBUT_WEEK,
 MD_WEEK,
 EXIT_WEEK,
 AUTO_ROLL_FORWARD,
 PLANNED_SELL_DOWN_WK,
 MD_STRATEGY,
 STORE_VOL_GRADE,
 STORE_CLIMATE,
 STORE_CAPACITY,
 STORE_BANNER,
 STORE_REGION,
 STORE_HAZMAT,
 SSG,
 SIZE_RANGE,
 VALID_SIZES_STORES,
 VALID_SIZES_ECOM,
 SIZE_MIN,
 SIZE_MIN_WEEKS,
 PRE_SSN_RATING_STRS,
 PRE_SSN_RATING_ECOM,
 RECEIPT_INTERVAL,
 RETURN_RATE_STRS,
 RETURN_RATE_ECOM,
 CROSS_CHANNEL_RET_RATE,
 ORDER_MIN,
 ORDER_MULTIPLE,
 LEAD_TIME_DEFAULT
)
AS
 SELECT trd_c_conversion_file_validcc.FLOORSET_CODE,
        trd_c_conversion_file_validcc.DEPARTMENT_ID,
        trd_c_conversion_file_validcc.CLASS_ID,
        trd_c_conversion_file_validcc.SUBCLASS_ID,
        trd_c_conversion_file_validcc.STYLE_ID,
        trd_c_conversion_file_validcc.STYLE_COLOR_ID,
        trd_c_conversion_file_validcc.STYLE_COLOR_DESC,
        trd_c_conversion_file_validcc.TICKET_PRICE,
        trd_c_conversion_file_validcc.COST,
        trd_c_conversion_file_validcc.DEFAULT_DISC,
        trd_c_conversion_file_validcc.DEBUT_WEEK,
        trd_c_conversion_file_validcc.MD_WEEK,
        trd_c_conversion_file_validcc.EXIT_WEEK,
        trd_c_conversion_file_validcc.AUTO_ROLL_FORWARD,
        trd_c_conversion_file_validcc.PLANNED_SELL_DOWN_WK,
        trd_c_conversion_file_validcc.MD_STRATEGY,
        trd_c_conversion_file_validcc.STORE_VOL_GRADE,
        trd_c_conversion_file_validcc.STORE_CLIMATE,
        trd_c_conversion_file_validcc.STORE_CAPACITY,
        trd_c_conversion_file_validcc.STORE_BANNER,
        trd_c_conversion_file_validcc.STORE_REGION,
        trd_c_conversion_file_validcc.STORE_HAZMAT,
        trd_c_conversion_file_validcc.SSG,
        trd_c_conversion_file_validcc.SIZE_RANGE,
        trd_c_conversion_file_validcc.VALID_SIZES_STORES,
        trd_c_conversion_file_validcc.VALID_SIZES_ECOM,
        trd_c_conversion_file_validcc.SIZE_MIN,
        trd_c_conversion_file_validcc.SIZE_MIN_WEEKS,
        trd_c_conversion_file_validcc.PRE_SSN_RATING_STRS,
        trd_c_conversion_file_validcc.PRE_SSN_RATING_ECOM,
        trd_c_conversion_file_validcc.RECEIPT_INTERVAL,
        trd_c_conversion_file_validcc.RETURN_RATE_STRS,
        trd_c_conversion_file_validcc.RETURN_RATE_ECOM,
        trd_c_conversion_file_validcc.CROSS_CHANNEL_RET_RATE,
        trd_c_conversion_file_validcc.ORDER_MIN,
        trd_c_conversion_file_validcc.ORDER_MULTIPLE,
        trd_c_conversion_file_validcc.LEAD_TIME_DEFAULT
 FROM public.trd_c_conversion_file_validcc
 ORDER BY trd_c_conversion_file_validcc.FLOORSET_CODE,
          trd_c_conversion_file_validcc.DEPARTMENT_ID,
          trd_c_conversion_file_validcc.CLASS_ID,
          trd_c_conversion_file_validcc.SUBCLASS_ID,
          trd_c_conversion_file_validcc.STYLE_ID,
          trd_c_conversion_file_validcc.STYLE_COLOR_ID,
          trd_c_conversion_file_validcc.STYLE_COLOR_DESC,
          trd_c_conversion_file_validcc.TICKET_PRICE
SEGMENTED BY hash(trd_c_conversion_file_validcc.TICKET_PRICE, trd_c_conversion_file_validcc.COST, trd_c_conversion_file_validcc.DEFAULT_DISC, trd_c_conversion_file_validcc.AUTO_ROLL_FORWARD, trd_c_conversion_file_validcc.SIZE_MIN, trd_c_conversion_file_validcc.SIZE_MIN_WEEKS, trd_c_conversion_file_validcc.PRE_SSN_RATING_STRS, trd_c_conversion_file_validcc.PRE_SSN_RATING_ECOM) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_c_conversion_file_irw_offset_super /*+basename(trd_c_conversion_file_irw_offset),createtype(A)*/ 
(
 FLOORSET_CODE,
 DEPARTMENT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 STYLE_ID,
 STYLE_COLOR_ID,
 STYLE_COLOR_DESC,
 TICKET_PRICE,
 COST,
 DEFAULT_DISC,
 DEBUT_WEEK,
 MD_WEEK,
 EXIT_WEEK,
 AUTO_ROLL_FORWARD,
 PLANNED_SELL_DOWN_WK,
 MD_STRATEGY,
 STORE_VOL_GRADE,
 STORE_CLIMATE,
 STORE_CAPACITY,
 STORE_BANNER,
 STORE_REGION,
 STORE_HAZMAT,
 SSG,
 SIZE_RANGE,
 VALID_SIZES_STORES,
 VALID_SIZES_ECOM,
 SIZE_MIN,
 SIZE_MIN_WEEKS,
 PRE_SSN_RATING_STRS,
 PRE_SSN_RATING_ECOM,
 RECEIPT_INTERVAL,
 RETURN_RATE_STRS,
 RETURN_RATE_ECOM,
 CROSS_CHANNEL_RET_RATE,
 ORDER_MIN,
 ORDER_MULTIPLE,
 LEAD_TIME_DEFAULT,
 irw_debut_offset
)
AS
 SELECT trd_c_conversion_file_irw_offset.FLOORSET_CODE,
        trd_c_conversion_file_irw_offset.DEPARTMENT_ID,
        trd_c_conversion_file_irw_offset.CLASS_ID,
        trd_c_conversion_file_irw_offset.SUBCLASS_ID,
        trd_c_conversion_file_irw_offset.STYLE_ID,
        trd_c_conversion_file_irw_offset.STYLE_COLOR_ID,
        trd_c_conversion_file_irw_offset.STYLE_COLOR_DESC,
        trd_c_conversion_file_irw_offset.TICKET_PRICE,
        trd_c_conversion_file_irw_offset.COST,
        trd_c_conversion_file_irw_offset.DEFAULT_DISC,
        trd_c_conversion_file_irw_offset.DEBUT_WEEK,
        trd_c_conversion_file_irw_offset.MD_WEEK,
        trd_c_conversion_file_irw_offset.EXIT_WEEK,
        trd_c_conversion_file_irw_offset.AUTO_ROLL_FORWARD,
        trd_c_conversion_file_irw_offset.PLANNED_SELL_DOWN_WK,
        trd_c_conversion_file_irw_offset.MD_STRATEGY,
        trd_c_conversion_file_irw_offset.STORE_VOL_GRADE,
        trd_c_conversion_file_irw_offset.STORE_CLIMATE,
        trd_c_conversion_file_irw_offset.STORE_CAPACITY,
        trd_c_conversion_file_irw_offset.STORE_BANNER,
        trd_c_conversion_file_irw_offset.STORE_REGION,
        trd_c_conversion_file_irw_offset.STORE_HAZMAT,
        trd_c_conversion_file_irw_offset.SSG,
        trd_c_conversion_file_irw_offset.SIZE_RANGE,
        trd_c_conversion_file_irw_offset.VALID_SIZES_STORES,
        trd_c_conversion_file_irw_offset.VALID_SIZES_ECOM,
        trd_c_conversion_file_irw_offset.SIZE_MIN,
        trd_c_conversion_file_irw_offset.SIZE_MIN_WEEKS,
        trd_c_conversion_file_irw_offset.PRE_SSN_RATING_STRS,
        trd_c_conversion_file_irw_offset.PRE_SSN_RATING_ECOM,
        trd_c_conversion_file_irw_offset.RECEIPT_INTERVAL,
        trd_c_conversion_file_irw_offset.RETURN_RATE_STRS,
        trd_c_conversion_file_irw_offset.RETURN_RATE_ECOM,
        trd_c_conversion_file_irw_offset.CROSS_CHANNEL_RET_RATE,
        trd_c_conversion_file_irw_offset.ORDER_MIN,
        trd_c_conversion_file_irw_offset.ORDER_MULTIPLE,
        trd_c_conversion_file_irw_offset.LEAD_TIME_DEFAULT,
        trd_c_conversion_file_irw_offset.irw_debut_offset
 FROM public.trd_c_conversion_file_irw_offset
 ORDER BY trd_c_conversion_file_irw_offset.FLOORSET_CODE,
          trd_c_conversion_file_irw_offset.DEPARTMENT_ID,
          trd_c_conversion_file_irw_offset.CLASS_ID,
          trd_c_conversion_file_irw_offset.SUBCLASS_ID,
          trd_c_conversion_file_irw_offset.STYLE_ID,
          trd_c_conversion_file_irw_offset.STYLE_COLOR_ID,
          trd_c_conversion_file_irw_offset.STYLE_COLOR_DESC,
          trd_c_conversion_file_irw_offset.TICKET_PRICE
SEGMENTED BY hash(trd_c_conversion_file_irw_offset.TICKET_PRICE, trd_c_conversion_file_irw_offset.COST, trd_c_conversion_file_irw_offset.DEFAULT_DISC, trd_c_conversion_file_irw_offset.AUTO_ROLL_FORWARD, trd_c_conversion_file_irw_offset.SIZE_MIN, trd_c_conversion_file_irw_offset.SIZE_MIN_WEEKS, trd_c_conversion_file_irw_offset.PRE_SSN_RATING_STRS, trd_c_conversion_file_irw_offset.PRE_SSN_RATING_ECOM) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_failed_items_20250328_super /*+basename(deleteme_failed_items_20250328),createtype(L)*/ 
(
 product
)
AS
 SELECT deleteme_failed_items_20250328.product
 FROM public.deleteme_failed_items_20250328
 ORDER BY deleteme_failed_items_20250328.product
SEGMENTED BY hash(deleteme_failed_items_20250328.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_failed_items_20250328_with_missing_size_attr_super /*+basename(deleteme_failed_items_20250328_with_missing_size_attr),createtype(A)*/ 
(
 member_id,
 stylecolor,
 ITEM,
 ITEM_DIFF_2,
 ITEM_DIFF_3,
 STYLECOLORSIZE_CREATE_DATE,
 SIZE_ATTR_ID
)
AS
 SELECT deleteme_failed_items_20250328_with_missing_size_attr.member_id,
        deleteme_failed_items_20250328_with_missing_size_attr.stylecolor,
        deleteme_failed_items_20250328_with_missing_size_attr.ITEM,
        deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_2,
        deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_3,
        deleteme_failed_items_20250328_with_missing_size_attr.STYLECOLORSIZE_CREATE_DATE,
        deleteme_failed_items_20250328_with_missing_size_attr.SIZE_ATTR_ID
 FROM public.deleteme_failed_items_20250328_with_missing_size_attr
 ORDER BY deleteme_failed_items_20250328_with_missing_size_attr.ITEM,
          deleteme_failed_items_20250328_with_missing_size_attr.member_id,
          deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_2,
          deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_3,
          deleteme_failed_items_20250328_with_missing_size_attr.STYLECOLORSIZE_CREATE_DATE,
          deleteme_failed_items_20250328_with_missing_size_attr.SIZE_ATTR_ID
SEGMENTED BY hash(deleteme_failed_items_20250328_with_missing_size_attr.ITEM, deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_2, deleteme_failed_items_20250328_with_missing_size_attr.ITEM_DIFF_3, deleteme_failed_items_20250328_with_missing_size_attr.STYLECOLORSIZE_CREATE_DATE, deleteme_failed_items_20250328_with_missing_size_attr.SIZE_ATTR_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_SPECSTYLECOLORIMAGES_super /*+basename(TRD_REJ_SPECSTYLECOLORIMAGES),createtype(L)*/ 
(
 VPN_COLOR,
 JPG,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_SPECSTYLECOLORIMAGES.VPN_COLOR,
        TRD_REJ_SPECSTYLECOLORIMAGES.JPG,
        TRD_REJ_SPECSTYLECOLORIMAGES.REJECT_REASON
 FROM public.TRD_REJ_SPECSTYLECOLORIMAGES
 ORDER BY TRD_REJ_SPECSTYLECOLORIMAGES.VPN_COLOR,
          TRD_REJ_SPECSTYLECOLORIMAGES.JPG
SEGMENTED BY hash(TRD_REJ_SPECSTYLECOLORIMAGES.VPN_COLOR, TRD_REJ_SPECSTYLECOLORIMAGES.JPG) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_d_product_20250422_super /*+basename(deleteme_trd_d_product_20250422),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT deleteme_trd_d_product_20250422.id,
        deleteme_trd_d_product_20250422.client_id,
        deleteme_trd_d_product_20250422.name,
        deleteme_trd_d_product_20250422.description,
        deleteme_trd_d_product_20250422.levelid,
        deleteme_trd_d_product_20250422.indx,
        deleteme_trd_d_product_20250422.eventdate,
        deleteme_trd_d_product_20250422.version_id,
        deleteme_trd_d_product_20250422.created_at,
        deleteme_trd_d_product_20250422.created_by,
        deleteme_trd_d_product_20250422.updated_at,
        deleteme_trd_d_product_20250422.updated_by,
        deleteme_trd_d_product_20250422.record_state
 FROM public.deleteme_trd_d_product_20250422
 ORDER BY deleteme_trd_d_product_20250422.id,
          deleteme_trd_d_product_20250422.client_id,
          deleteme_trd_d_product_20250422.name,
          deleteme_trd_d_product_20250422.description,
          deleteme_trd_d_product_20250422.levelid,
          deleteme_trd_d_product_20250422.indx,
          deleteme_trd_d_product_20250422.eventdate,
          deleteme_trd_d_product_20250422.version_id
SEGMENTED BY hash(deleteme_trd_d_product_20250422.indx, deleteme_trd_d_product_20250422.eventdate, deleteme_trd_d_product_20250422.version_id, deleteme_trd_d_product_20250422.created_at, deleteme_trd_d_product_20250422.created_by, deleteme_trd_d_product_20250422.updated_at, deleteme_trd_d_product_20250422.updated_by, deleteme_trd_d_product_20250422.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYPORECEIPTS_super /*+basename(TRD_IN_ACT_DAILYPORECEIPTS),createtype(L)*/ 
(
 PO_ID,
 SKU_ID,
 FLOW_ID,
 NDC_WEEK,
 ACTUAL_RECEIPT_DATE,
 QTY
)
AS
 SELECT TRD_IN_ACT_DAILYPORECEIPTS.PO_ID,
        TRD_IN_ACT_DAILYPORECEIPTS.SKU_ID,
        TRD_IN_ACT_DAILYPORECEIPTS.FLOW_ID,
        TRD_IN_ACT_DAILYPORECEIPTS.NDC_WEEK,
        TRD_IN_ACT_DAILYPORECEIPTS.ACTUAL_RECEIPT_DATE,
        TRD_IN_ACT_DAILYPORECEIPTS.QTY
 FROM public.TRD_IN_ACT_DAILYPORECEIPTS
 ORDER BY TRD_IN_ACT_DAILYPORECEIPTS.PO_ID,
          TRD_IN_ACT_DAILYPORECEIPTS.SKU_ID,
          TRD_IN_ACT_DAILYPORECEIPTS.FLOW_ID,
          TRD_IN_ACT_DAILYPORECEIPTS.NDC_WEEK,
          TRD_IN_ACT_DAILYPORECEIPTS.ACTUAL_RECEIPT_DATE,
          TRD_IN_ACT_DAILYPORECEIPTS.QTY
SEGMENTED BY hash(TRD_IN_ACT_DAILYPORECEIPTS.QTY, TRD_IN_ACT_DAILYPORECEIPTS.PO_ID, TRD_IN_ACT_DAILYPORECEIPTS.SKU_ID, TRD_IN_ACT_DAILYPORECEIPTS.FLOW_ID, TRD_IN_ACT_DAILYPORECEIPTS.NDC_WEEK, TRD_IN_ACT_DAILYPORECEIPTS.ACTUAL_RECEIPT_DATE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_SPECSTYLEATTRIBUTES_super /*+basename(TRD_REJ_SPECSTYLEATTRIBUTES),createtype(L)*/ 
(
 VPN_VSN,
 VPN_DESCRIPTION,
 DEPT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 TICKET_TYPE,
 KNIT_OR_WOVEN,
 SLEEVE_LENGTH,
 LEG_OPENING,
 BRAND,
 LICENSE_VS_NON_LICENSED,
 HAZMAT_CODE,
 PROP_65_WARNING,
 MATERIAL_CONTENT,
 DWRISE,
 LENGTH,
 NECKLINE,
 TOESHAPE,
 HEEL_HEIGHT,
 BOTTOM_LENGTH,
 v_360_SMOOTHING,
 KNIT_FIT,
 DESIGN_STYLE_STATUS,
 SIZE_RANGE,
 SPEC_STYLE_OPEN1,
 SPEC_STYLE_OPEN2,
 SPEC_STYLE_OPEN3,
 SPEC_STYLE_OPEN4,
 SPEC_STYLE_OPEN5,
 SPEC_STYLE_OPEN6,
 SPEC_STYLE_OPEN7,
 SPEC_STYLE_OPEN8,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_SPECSTYLEATTRIBUTES.VPN_VSN,
        TRD_REJ_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION,
        TRD_REJ_SPECSTYLEATTRIBUTES.DEPT_ID,
        TRD_REJ_SPECSTYLEATTRIBUTES.CLASS_ID,
        TRD_REJ_SPECSTYLEATTRIBUTES.SUBCLASS_ID,
        TRD_REJ_SPECSTYLEATTRIBUTES.TICKET_TYPE,
        TRD_REJ_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN,
        TRD_REJ_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH,
        TRD_REJ_SPECSTYLEATTRIBUTES.LEG_OPENING,
        TRD_REJ_SPECSTYLEATTRIBUTES.BRAND,
        TRD_REJ_SPECSTYLEATTRIBUTES.LICENSE_VS_NON_LICENSED,
        TRD_REJ_SPECSTYLEATTRIBUTES.HAZMAT_CODE,
        TRD_REJ_SPECSTYLEATTRIBUTES.PROP_65_WARNING,
        TRD_REJ_SPECSTYLEATTRIBUTES.MATERIAL_CONTENT,
        TRD_REJ_SPECSTYLEATTRIBUTES.DWRISE,
        TRD_REJ_SPECSTYLEATTRIBUTES.LENGTH,
        TRD_REJ_SPECSTYLEATTRIBUTES.NECKLINE,
        TRD_REJ_SPECSTYLEATTRIBUTES.TOESHAPE,
        TRD_REJ_SPECSTYLEATTRIBUTES.HEEL_HEIGHT,
        TRD_REJ_SPECSTYLEATTRIBUTES.BOTTOM_LENGTH,
        TRD_REJ_SPECSTYLEATTRIBUTES.v_360_SMOOTHING,
        TRD_REJ_SPECSTYLEATTRIBUTES.KNIT_FIT,
        TRD_REJ_SPECSTYLEATTRIBUTES.DESIGN_STYLE_STATUS,
        TRD_REJ_SPECSTYLEATTRIBUTES.SIZE_RANGE,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN1,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN2,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN3,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN4,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN5,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN6,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN7,
        TRD_REJ_SPECSTYLEATTRIBUTES.SPEC_STYLE_OPEN8,
        TRD_REJ_SPECSTYLEATTRIBUTES.REJECT_REASON
 FROM public.TRD_REJ_SPECSTYLEATTRIBUTES
 ORDER BY TRD_REJ_SPECSTYLEATTRIBUTES.VPN_VSN,
          TRD_REJ_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION,
          TRD_REJ_SPECSTYLEATTRIBUTES.DEPT_ID,
          TRD_REJ_SPECSTYLEATTRIBUTES.CLASS_ID,
          TRD_REJ_SPECSTYLEATTRIBUTES.SUBCLASS_ID,
          TRD_REJ_SPECSTYLEATTRIBUTES.TICKET_TYPE,
          TRD_REJ_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN,
          TRD_REJ_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH
SEGMENTED BY hash(TRD_REJ_SPECSTYLEATTRIBUTES.VPN_VSN, TRD_REJ_SPECSTYLEATTRIBUTES.VPN_DESCRIPTION, TRD_REJ_SPECSTYLEATTRIBUTES.DEPT_ID, TRD_REJ_SPECSTYLEATTRIBUTES.CLASS_ID, TRD_REJ_SPECSTYLEATTRIBUTES.SUBCLASS_ID, TRD_REJ_SPECSTYLEATTRIBUTES.TICKET_TYPE, TRD_REJ_SPECSTYLEATTRIBUTES.KNIT_OR_WOVEN, TRD_REJ_SPECSTYLEATTRIBUTES.SLEEVE_LENGTH) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_stylecolor_test_super /*+basename(trd_p_dc_adj_stylecolor_test),createtype(A)*/ 
(
 stylecolor,
 store,
 WEEK_ID,
 ON_ORDER_V,
 ON_ORDER_U,
 ON_ORDER_C,
 ON_ORDER_V_ECOM,
 ON_ORDER_U_ECOM,
 ON_ORDER_C_ECOM,
 adj_cost
)
AS
 SELECT trd_p_dc_adj_stylecolor_test.stylecolor,
        trd_p_dc_adj_stylecolor_test.store,
        trd_p_dc_adj_stylecolor_test.WEEK_ID,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_V,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_U,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_C,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_V_ECOM,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_U_ECOM,
        trd_p_dc_adj_stylecolor_test.ON_ORDER_C_ECOM,
        trd_p_dc_adj_stylecolor_test.adj_cost
 FROM public.trd_p_dc_adj_stylecolor_test
 ORDER BY trd_p_dc_adj_stylecolor_test.WEEK_ID
SEGMENTED BY hash(trd_p_dc_adj_stylecolor_test.store, trd_p_dc_adj_stylecolor_test.ON_ORDER_V, trd_p_dc_adj_stylecolor_test.ON_ORDER_U, trd_p_dc_adj_stylecolor_test.ON_ORDER_C, trd_p_dc_adj_stylecolor_test.ON_ORDER_V_ECOM, trd_p_dc_adj_stylecolor_test.ON_ORDER_U_ECOM, trd_p_dc_adj_stylecolor_test.ON_ORDER_C_ECOM, trd_p_dc_adj_stylecolor_test.adj_cost) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_existing_test_super /*+basename(trd_p_dc_adj_existing_test),createtype(A)*/ 
(
 product,
 location,
 "time",
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
AS
 SELECT trd_p_dc_adj_existing_test.product,
        trd_p_dc_adj_existing_test.location,
        trd_p_dc_adj_existing_test."time",
        trd_p_dc_adj_existing_test.dc_publish,
        trd_p_dc_adj_existing_test.is_locked,
        trd_p_dc_adj_existing_test.dc_uservrp,
        trd_p_dc_adj_existing_test.dc_lockedqty,
        trd_p_dc_adj_existing_test.dc_useradj,
        trd_p_dc_adj_existing_test.dc_onorder,
        trd_p_dc_adj_existing_test.dc_finrev,
        trd_p_dc_adj_existing_test.dc_validwk,
        trd_p_dc_adj_existing_test.dc_finalqty,
        trd_p_dc_adj_existing_test.dc_adjcost,
        trd_p_dc_adj_existing_test.const_y_n,
        trd_p_dc_adj_existing_test.sbkt,
        trd_p_dc_adj_existing_test.dc_isedited,
        trd_p_dc_adj_existing_test.dc_syscost,
        trd_p_dc_adj_existing_test.dc_lndcst,
        trd_p_dc_adj_existing_test.dc_sysvrp,
        trd_p_dc_adj_existing_test.dc_sc_useradj,
        trd_p_dc_adj_existing_test.dc_sc_finrev,
        trd_p_dc_adj_existing_test.po_indicator,
        trd_p_dc_adj_existing_test.po_shipmode,
        trd_p_dc_adj_existing_test.air_trigger,
        trd_p_dc_adj_existing_test.cut,
        trd_p_dc_adj_existing_test.published_at,
        trd_p_dc_adj_existing_test.is_prepublished,
        trd_p_dc_adj_existing_test.prepublished_at,
        trd_p_dc_adj_existing_test.last_prepublished,
        trd_p_dc_adj_existing_test.po_arr,
        trd_p_dc_adj_existing_test.eventdate,
        trd_p_dc_adj_existing_test.version_id,
        trd_p_dc_adj_existing_test.created_at,
        trd_p_dc_adj_existing_test.created_by,
        trd_p_dc_adj_existing_test.updated_at,
        trd_p_dc_adj_existing_test.updated_by,
        trd_p_dc_adj_existing_test.record_state,
        trd_p_dc_adj_existing_test.dc_useradj_ecom,
        trd_p_dc_adj_existing_test.dc_onorder_ecom,
        trd_p_dc_adj_existing_test.dc_finrev_ecom,
        trd_p_dc_adj_existing_test.dc_publish_ecom,
        trd_p_dc_adj_existing_test.po_indicator_ecom,
        trd_p_dc_adj_existing_test.po_shipmode_ecom,
        trd_p_dc_adj_existing_test.air_trigger_ecom,
        trd_p_dc_adj_existing_test.cut_ecom,
        trd_p_dc_adj_existing_test.published_at_ecom,
        trd_p_dc_adj_existing_test.is_prepublished_ecom,
        trd_p_dc_adj_existing_test.prepublished_at_ecom,
        trd_p_dc_adj_existing_test.last_prepublished_ecom,
        trd_p_dc_adj_existing_test.reason_code,
        trd_p_dc_adj_existing_test.reason_code_ecom,
        trd_p_dc_adj_existing_test.pack_ind_flag,
        trd_p_dc_adj_existing_test.pack_ind_flag_ecom,
        trd_p_dc_adj_existing_test.show_in_pack,
        trd_p_dc_adj_existing_test.show_in_pack_ecom,
        trd_p_dc_adj_existing_test.prepack_pct,
        trd_p_dc_adj_existing_test.prepack_pct_ecom,
        trd_p_dc_adj_existing_test.default_fringe_indicator,
        trd_p_dc_adj_existing_test.default_fringe_indicator_ecom,
        trd_p_dc_adj_existing_test.email_to
 FROM public.trd_p_dc_adj_existing_test
 ORDER BY trd_p_dc_adj_existing_test.location,
          trd_p_dc_adj_existing_test."time",
          trd_p_dc_adj_existing_test.dc_publish,
          trd_p_dc_adj_existing_test.is_locked,
          trd_p_dc_adj_existing_test.dc_uservrp,
          trd_p_dc_adj_existing_test.dc_lockedqty,
          trd_p_dc_adj_existing_test.dc_useradj
SEGMENTED BY hash(trd_p_dc_adj_existing_test.dc_publish, trd_p_dc_adj_existing_test.is_locked, trd_p_dc_adj_existing_test.dc_uservrp, trd_p_dc_adj_existing_test.dc_lockedqty, trd_p_dc_adj_existing_test.dc_useradj, trd_p_dc_adj_existing_test.dc_onorder, trd_p_dc_adj_existing_test.dc_finrev, trd_p_dc_adj_existing_test.dc_validwk) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_by_po_tbl_20250722_super /*+basename(trd_p_onorder_by_po_tbl_20250722),createtype(A)*/ 
(
 sku,
 parent_id,
 location_id,
 flow_id,
 week_id,
 price_status,
 ndc_date,
 start_ship_date,
 po_cancel_date,
 po_id,
 total_units,
 total_cost,
 total_retail,
 p_nbr_packs,
 p_pack_id,
 p_qty_per_pack,
 p_po_type,
 p_vendor_nbr,
 p_po_vendor_nbr,
 p_vendor_desc,
 po_ln_seq_num,
 eventdate,
 updated_at
)
AS
 SELECT trd_p_onorder_by_po_tbl_20250722.sku,
        trd_p_onorder_by_po_tbl_20250722.parent_id,
        trd_p_onorder_by_po_tbl_20250722.location_id,
        trd_p_onorder_by_po_tbl_20250722.flow_id,
        trd_p_onorder_by_po_tbl_20250722.week_id,
        trd_p_onorder_by_po_tbl_20250722.price_status,
        trd_p_onorder_by_po_tbl_20250722.ndc_date,
        trd_p_onorder_by_po_tbl_20250722.start_ship_date,
        trd_p_onorder_by_po_tbl_20250722.po_cancel_date,
        trd_p_onorder_by_po_tbl_20250722.po_id,
        trd_p_onorder_by_po_tbl_20250722.total_units,
        trd_p_onorder_by_po_tbl_20250722.total_cost,
        trd_p_onorder_by_po_tbl_20250722.total_retail,
        trd_p_onorder_by_po_tbl_20250722.p_nbr_packs,
        trd_p_onorder_by_po_tbl_20250722.p_pack_id,
        trd_p_onorder_by_po_tbl_20250722.p_qty_per_pack,
        trd_p_onorder_by_po_tbl_20250722.p_po_type,
        trd_p_onorder_by_po_tbl_20250722.p_vendor_nbr,
        trd_p_onorder_by_po_tbl_20250722.p_po_vendor_nbr,
        trd_p_onorder_by_po_tbl_20250722.p_vendor_desc,
        trd_p_onorder_by_po_tbl_20250722.po_ln_seq_num,
        trd_p_onorder_by_po_tbl_20250722.eventdate,
        trd_p_onorder_by_po_tbl_20250722.updated_at
 FROM public.trd_p_onorder_by_po_tbl_20250722
 ORDER BY trd_p_onorder_by_po_tbl_20250722.sku,
          trd_p_onorder_by_po_tbl_20250722.parent_id,
          trd_p_onorder_by_po_tbl_20250722.location_id,
          trd_p_onorder_by_po_tbl_20250722.flow_id,
          trd_p_onorder_by_po_tbl_20250722.week_id,
          trd_p_onorder_by_po_tbl_20250722.price_status,
          trd_p_onorder_by_po_tbl_20250722.ndc_date,
          trd_p_onorder_by_po_tbl_20250722.start_ship_date
SEGMENTED BY hash(trd_p_onorder_by_po_tbl_20250722.price_status, trd_p_onorder_by_po_tbl_20250722.total_units, trd_p_onorder_by_po_tbl_20250722.total_cost, trd_p_onorder_by_po_tbl_20250722.total_retail, trd_p_onorder_by_po_tbl_20250722.eventdate, trd_p_onorder_by_po_tbl_20250722.updated_at, trd_p_onorder_by_po_tbl_20250722.sku, trd_p_onorder_by_po_tbl_20250722.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_tbl_20250722_super /*+basename(trd_p_onorder_tbl_20250722),createtype(A)*/ 
(
 product,
 stylecolor,
 location,
 prodlife,
 cluster,
 on_order_r,
 on_order_u,
 on_order_c,
 on_order_r_4wk,
 on_order_u_4wk,
 on_order_c_4wk,
 on_order_r_13wk,
 on_order_u_13wk,
 on_order_c_13wk,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_p_onorder_tbl_20250722.product,
        trd_p_onorder_tbl_20250722.stylecolor,
        trd_p_onorder_tbl_20250722.location,
        trd_p_onorder_tbl_20250722.prodlife,
        trd_p_onorder_tbl_20250722.cluster,
        trd_p_onorder_tbl_20250722.on_order_r,
        trd_p_onorder_tbl_20250722.on_order_u,
        trd_p_onorder_tbl_20250722.on_order_c,
        trd_p_onorder_tbl_20250722.on_order_r_4wk,
        trd_p_onorder_tbl_20250722.on_order_u_4wk,
        trd_p_onorder_tbl_20250722.on_order_c_4wk,
        trd_p_onorder_tbl_20250722.on_order_r_13wk,
        trd_p_onorder_tbl_20250722.on_order_u_13wk,
        trd_p_onorder_tbl_20250722.on_order_c_13wk,
        trd_p_onorder_tbl_20250722.eventdate,
        trd_p_onorder_tbl_20250722.version_id,
        trd_p_onorder_tbl_20250722.created_at,
        trd_p_onorder_tbl_20250722.created_by,
        trd_p_onorder_tbl_20250722.updated_at,
        trd_p_onorder_tbl_20250722.updated_by,
        trd_p_onorder_tbl_20250722.record_state
 FROM public.trd_p_onorder_tbl_20250722
 ORDER BY trd_p_onorder_tbl_20250722.product,
          trd_p_onorder_tbl_20250722.stylecolor,
          trd_p_onorder_tbl_20250722.location,
          trd_p_onorder_tbl_20250722.prodlife,
          trd_p_onorder_tbl_20250722.cluster,
          trd_p_onorder_tbl_20250722.on_order_r,
          trd_p_onorder_tbl_20250722.on_order_u,
          trd_p_onorder_tbl_20250722.on_order_c
SEGMENTED BY hash(trd_p_onorder_tbl_20250722.prodlife, trd_p_onorder_tbl_20250722.cluster, trd_p_onorder_tbl_20250722.on_order_r, trd_p_onorder_tbl_20250722.on_order_u, trd_p_onorder_tbl_20250722.on_order_c, trd_p_onorder_tbl_20250722.on_order_r_4wk, trd_p_onorder_tbl_20250722.on_order_u_4wk, trd_p_onorder_tbl_20250722.on_order_c_4wk) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_by_po_tbl_20250720_super /*+basename(trd_p_onorder_by_po_tbl_20250720),createtype(A)*/ 
(
 sku,
 parent_id,
 location_id,
 flow_id,
 week_id,
 price_status,
 ndc_date,
 start_ship_date,
 po_cancel_date,
 po_id,
 total_units,
 total_cost,
 total_retail,
 p_nbr_packs,
 p_pack_id,
 p_qty_per_pack,
 p_po_type,
 p_vendor_nbr,
 p_po_vendor_nbr,
 p_vendor_desc,
 po_ln_seq_num,
 eventdate,
 updated_at
)
AS
 SELECT trd_p_onorder_by_po_tbl_20250720.sku,
        trd_p_onorder_by_po_tbl_20250720.parent_id,
        trd_p_onorder_by_po_tbl_20250720.location_id,
        trd_p_onorder_by_po_tbl_20250720.flow_id,
        trd_p_onorder_by_po_tbl_20250720.week_id,
        trd_p_onorder_by_po_tbl_20250720.price_status,
        trd_p_onorder_by_po_tbl_20250720.ndc_date,
        trd_p_onorder_by_po_tbl_20250720.start_ship_date,
        trd_p_onorder_by_po_tbl_20250720.po_cancel_date,
        trd_p_onorder_by_po_tbl_20250720.po_id,
        trd_p_onorder_by_po_tbl_20250720.total_units,
        trd_p_onorder_by_po_tbl_20250720.total_cost,
        trd_p_onorder_by_po_tbl_20250720.total_retail,
        trd_p_onorder_by_po_tbl_20250720.p_nbr_packs,
        trd_p_onorder_by_po_tbl_20250720.p_pack_id,
        trd_p_onorder_by_po_tbl_20250720.p_qty_per_pack,
        trd_p_onorder_by_po_tbl_20250720.p_po_type,
        trd_p_onorder_by_po_tbl_20250720.p_vendor_nbr,
        trd_p_onorder_by_po_tbl_20250720.p_po_vendor_nbr,
        trd_p_onorder_by_po_tbl_20250720.p_vendor_desc,
        trd_p_onorder_by_po_tbl_20250720.po_ln_seq_num,
        trd_p_onorder_by_po_tbl_20250720.eventdate,
        trd_p_onorder_by_po_tbl_20250720.updated_at
 FROM public.trd_p_onorder_by_po_tbl_20250720
 ORDER BY trd_p_onorder_by_po_tbl_20250720.sku,
          trd_p_onorder_by_po_tbl_20250720.parent_id,
          trd_p_onorder_by_po_tbl_20250720.location_id,
          trd_p_onorder_by_po_tbl_20250720.flow_id,
          trd_p_onorder_by_po_tbl_20250720.week_id,
          trd_p_onorder_by_po_tbl_20250720.price_status,
          trd_p_onorder_by_po_tbl_20250720.ndc_date,
          trd_p_onorder_by_po_tbl_20250720.start_ship_date
SEGMENTED BY hash(trd_p_onorder_by_po_tbl_20250720.price_status, trd_p_onorder_by_po_tbl_20250720.total_units, trd_p_onorder_by_po_tbl_20250720.total_cost, trd_p_onorder_by_po_tbl_20250720.total_retail, trd_p_onorder_by_po_tbl_20250720.eventdate, trd_p_onorder_by_po_tbl_20250720.updated_at, trd_p_onorder_by_po_tbl_20250720.sku, trd_p_onorder_by_po_tbl_20250720.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_tbl_20250720_super /*+basename(trd_p_onorder_tbl_20250720),createtype(A)*/ 
(
 product,
 stylecolor,
 location,
 prodlife,
 cluster,
 on_order_r,
 on_order_u,
 on_order_c,
 on_order_r_4wk,
 on_order_u_4wk,
 on_order_c_4wk,
 on_order_r_13wk,
 on_order_u_13wk,
 on_order_c_13wk,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_p_onorder_tbl_20250720.product,
        trd_p_onorder_tbl_20250720.stylecolor,
        trd_p_onorder_tbl_20250720.location,
        trd_p_onorder_tbl_20250720.prodlife,
        trd_p_onorder_tbl_20250720.cluster,
        trd_p_onorder_tbl_20250720.on_order_r,
        trd_p_onorder_tbl_20250720.on_order_u,
        trd_p_onorder_tbl_20250720.on_order_c,
        trd_p_onorder_tbl_20250720.on_order_r_4wk,
        trd_p_onorder_tbl_20250720.on_order_u_4wk,
        trd_p_onorder_tbl_20250720.on_order_c_4wk,
        trd_p_onorder_tbl_20250720.on_order_r_13wk,
        trd_p_onorder_tbl_20250720.on_order_u_13wk,
        trd_p_onorder_tbl_20250720.on_order_c_13wk,
        trd_p_onorder_tbl_20250720.eventdate,
        trd_p_onorder_tbl_20250720.version_id,
        trd_p_onorder_tbl_20250720.created_at,
        trd_p_onorder_tbl_20250720.created_by,
        trd_p_onorder_tbl_20250720.updated_at,
        trd_p_onorder_tbl_20250720.updated_by,
        trd_p_onorder_tbl_20250720.record_state
 FROM public.trd_p_onorder_tbl_20250720
 ORDER BY trd_p_onorder_tbl_20250720.product,
          trd_p_onorder_tbl_20250720.stylecolor,
          trd_p_onorder_tbl_20250720.location,
          trd_p_onorder_tbl_20250720.prodlife,
          trd_p_onorder_tbl_20250720.cluster,
          trd_p_onorder_tbl_20250720.on_order_r,
          trd_p_onorder_tbl_20250720.on_order_u,
          trd_p_onorder_tbl_20250720.on_order_c
SEGMENTED BY hash(trd_p_onorder_tbl_20250720.prodlife, trd_p_onorder_tbl_20250720.cluster, trd_p_onorder_tbl_20250720.on_order_r, trd_p_onorder_tbl_20250720.on_order_u, trd_p_onorder_tbl_20250720.on_order_c, trd_p_onorder_tbl_20250720.on_order_r_4wk, trd_p_onorder_tbl_20250720.on_order_u_4wk, trd_p_onorder_tbl_20250720.on_order_c_4wk) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_ONORDER_20250720_super /*+basename(TRD_IN_ACT_ONORDER_20250720),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 FLOW_ID,
 WEEK_ID,
 PRICE_STATUS,
 NDC_DATE,
 START_SHIP_DATE,
 PO_CANCEL_DATE,
 PO_ID,
 TOTAL_UNITS,
 TOTAL_COST,
 TOTAL_RETAIL,
 P_NBR_PACKS,
 P_PACK_ID,
 P_QTY_PER_PACK,
 P_PO_TYPE,
 P_VENDOR_NBR,
 P_PO_VENDOR_NBR,
 P_VENDOR_DESC,
 PO_LN_SEQ_NUM
)
AS
 SELECT TRD_IN_ACT_ONORDER_20250720.MEMBER_ID,
        TRD_IN_ACT_ONORDER_20250720.LOCATION_ID,
        TRD_IN_ACT_ONORDER_20250720.FLOW_ID,
        TRD_IN_ACT_ONORDER_20250720.WEEK_ID,
        TRD_IN_ACT_ONORDER_20250720.PRICE_STATUS,
        TRD_IN_ACT_ONORDER_20250720.NDC_DATE,
        TRD_IN_ACT_ONORDER_20250720.START_SHIP_DATE,
        TRD_IN_ACT_ONORDER_20250720.PO_CANCEL_DATE,
        TRD_IN_ACT_ONORDER_20250720.PO_ID,
        TRD_IN_ACT_ONORDER_20250720.TOTAL_UNITS,
        TRD_IN_ACT_ONORDER_20250720.TOTAL_COST,
        TRD_IN_ACT_ONORDER_20250720.TOTAL_RETAIL,
        TRD_IN_ACT_ONORDER_20250720.P_NBR_PACKS,
        TRD_IN_ACT_ONORDER_20250720.P_PACK_ID,
        TRD_IN_ACT_ONORDER_20250720.P_QTY_PER_PACK,
        TRD_IN_ACT_ONORDER_20250720.P_PO_TYPE,
        TRD_IN_ACT_ONORDER_20250720.P_VENDOR_NBR,
        TRD_IN_ACT_ONORDER_20250720.P_PO_VENDOR_NBR,
        TRD_IN_ACT_ONORDER_20250720.P_VENDOR_DESC,
        TRD_IN_ACT_ONORDER_20250720.PO_LN_SEQ_NUM
 FROM public.TRD_IN_ACT_ONORDER_20250720
 ORDER BY TRD_IN_ACT_ONORDER_20250720.MEMBER_ID,
          TRD_IN_ACT_ONORDER_20250720.LOCATION_ID,
          TRD_IN_ACT_ONORDER_20250720.FLOW_ID,
          TRD_IN_ACT_ONORDER_20250720.WEEK_ID,
          TRD_IN_ACT_ONORDER_20250720.PRICE_STATUS,
          TRD_IN_ACT_ONORDER_20250720.NDC_DATE,
          TRD_IN_ACT_ONORDER_20250720.START_SHIP_DATE,
          TRD_IN_ACT_ONORDER_20250720.PO_CANCEL_DATE
SEGMENTED BY hash(TRD_IN_ACT_ONORDER_20250720.TOTAL_UNITS, TRD_IN_ACT_ONORDER_20250720.TOTAL_COST, TRD_IN_ACT_ONORDER_20250720.TOTAL_RETAIL, TRD_IN_ACT_ONORDER_20250720.MEMBER_ID, TRD_IN_ACT_ONORDER_20250720.LOCATION_ID, TRD_IN_ACT_ONORDER_20250720.FLOW_ID, TRD_IN_ACT_ONORDER_20250720.WEEK_ID, TRD_IN_ACT_ONORDER_20250720.PRICE_STATUS) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYPORECEIPTS_20250720_super /*+basename(TRD_IN_ACT_DAILYPORECEIPTS_20250720),createtype(A)*/ 
(
 PO_ID,
 SKU_ID,
 FLOW_ID,
 NDC_WEEK,
 ACTUAL_RECEIPT_DATE,
 QTY
)
AS
 SELECT TRD_IN_ACT_DAILYPORECEIPTS_20250720.PO_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250720.SKU_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250720.FLOW_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250720.NDC_WEEK,
        TRD_IN_ACT_DAILYPORECEIPTS_20250720.ACTUAL_RECEIPT_DATE,
        TRD_IN_ACT_DAILYPORECEIPTS_20250720.QTY
 FROM public.TRD_IN_ACT_DAILYPORECEIPTS_20250720
 ORDER BY TRD_IN_ACT_DAILYPORECEIPTS_20250720.PO_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250720.SKU_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250720.FLOW_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250720.NDC_WEEK,
          TRD_IN_ACT_DAILYPORECEIPTS_20250720.ACTUAL_RECEIPT_DATE,
          TRD_IN_ACT_DAILYPORECEIPTS_20250720.QTY
SEGMENTED BY hash(TRD_IN_ACT_DAILYPORECEIPTS_20250720.QTY, TRD_IN_ACT_DAILYPORECEIPTS_20250720.PO_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250720.SKU_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250720.FLOW_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250720.NDC_WEEK, TRD_IN_ACT_DAILYPORECEIPTS_20250720.ACTUAL_RECEIPT_DATE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_ONORDER_20250721_super /*+basename(TRD_IN_ACT_ONORDER_20250721),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 FLOW_ID,
 WEEK_ID,
 PRICE_STATUS,
 NDC_DATE,
 START_SHIP_DATE,
 PO_CANCEL_DATE,
 PO_ID,
 TOTAL_UNITS,
 TOTAL_COST,
 TOTAL_RETAIL,
 P_NBR_PACKS,
 P_PACK_ID,
 P_QTY_PER_PACK,
 P_PO_TYPE,
 P_VENDOR_NBR,
 P_PO_VENDOR_NBR,
 P_VENDOR_DESC,
 PO_LN_SEQ_NUM
)
AS
 SELECT TRD_IN_ACT_ONORDER_20250721.MEMBER_ID,
        TRD_IN_ACT_ONORDER_20250721.LOCATION_ID,
        TRD_IN_ACT_ONORDER_20250721.FLOW_ID,
        TRD_IN_ACT_ONORDER_20250721.WEEK_ID,
        TRD_IN_ACT_ONORDER_20250721.PRICE_STATUS,
        TRD_IN_ACT_ONORDER_20250721.NDC_DATE,
        TRD_IN_ACT_ONORDER_20250721.START_SHIP_DATE,
        TRD_IN_ACT_ONORDER_20250721.PO_CANCEL_DATE,
        TRD_IN_ACT_ONORDER_20250721.PO_ID,
        TRD_IN_ACT_ONORDER_20250721.TOTAL_UNITS,
        TRD_IN_ACT_ONORDER_20250721.TOTAL_COST,
        TRD_IN_ACT_ONORDER_20250721.TOTAL_RETAIL,
        TRD_IN_ACT_ONORDER_20250721.P_NBR_PACKS,
        TRD_IN_ACT_ONORDER_20250721.P_PACK_ID,
        TRD_IN_ACT_ONORDER_20250721.P_QTY_PER_PACK,
        TRD_IN_ACT_ONORDER_20250721.P_PO_TYPE,
        TRD_IN_ACT_ONORDER_20250721.P_VENDOR_NBR,
        TRD_IN_ACT_ONORDER_20250721.P_PO_VENDOR_NBR,
        TRD_IN_ACT_ONORDER_20250721.P_VENDOR_DESC,
        TRD_IN_ACT_ONORDER_20250721.PO_LN_SEQ_NUM
 FROM public.TRD_IN_ACT_ONORDER_20250721
 ORDER BY TRD_IN_ACT_ONORDER_20250721.MEMBER_ID,
          TRD_IN_ACT_ONORDER_20250721.LOCATION_ID,
          TRD_IN_ACT_ONORDER_20250721.FLOW_ID,
          TRD_IN_ACT_ONORDER_20250721.WEEK_ID,
          TRD_IN_ACT_ONORDER_20250721.PRICE_STATUS,
          TRD_IN_ACT_ONORDER_20250721.NDC_DATE,
          TRD_IN_ACT_ONORDER_20250721.START_SHIP_DATE,
          TRD_IN_ACT_ONORDER_20250721.PO_CANCEL_DATE
SEGMENTED BY hash(TRD_IN_ACT_ONORDER_20250721.TOTAL_UNITS, TRD_IN_ACT_ONORDER_20250721.TOTAL_COST, TRD_IN_ACT_ONORDER_20250721.TOTAL_RETAIL, TRD_IN_ACT_ONORDER_20250721.MEMBER_ID, TRD_IN_ACT_ONORDER_20250721.LOCATION_ID, TRD_IN_ACT_ONORDER_20250721.FLOW_ID, TRD_IN_ACT_ONORDER_20250721.WEEK_ID, TRD_IN_ACT_ONORDER_20250721.PRICE_STATUS) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYPORECEIPTS_20250721_super /*+basename(TRD_IN_ACT_DAILYPORECEIPTS_20250721),createtype(A)*/ 
(
 PO_ID,
 SKU_ID,
 FLOW_ID,
 NDC_WEEK,
 ACTUAL_RECEIPT_DATE,
 QTY
)
AS
 SELECT TRD_IN_ACT_DAILYPORECEIPTS_20250721.PO_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250721.SKU_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250721.FLOW_ID,
        TRD_IN_ACT_DAILYPORECEIPTS_20250721.NDC_WEEK,
        TRD_IN_ACT_DAILYPORECEIPTS_20250721.ACTUAL_RECEIPT_DATE,
        TRD_IN_ACT_DAILYPORECEIPTS_20250721.QTY
 FROM public.TRD_IN_ACT_DAILYPORECEIPTS_20250721
 ORDER BY TRD_IN_ACT_DAILYPORECEIPTS_20250721.PO_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250721.SKU_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250721.FLOW_ID,
          TRD_IN_ACT_DAILYPORECEIPTS_20250721.NDC_WEEK,
          TRD_IN_ACT_DAILYPORECEIPTS_20250721.ACTUAL_RECEIPT_DATE,
          TRD_IN_ACT_DAILYPORECEIPTS_20250721.QTY
SEGMENTED BY hash(TRD_IN_ACT_DAILYPORECEIPTS_20250721.QTY, TRD_IN_ACT_DAILYPORECEIPTS_20250721.PO_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250721.SKU_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250721.FLOW_ID, TRD_IN_ACT_DAILYPORECEIPTS_20250721.NDC_WEEK, TRD_IN_ACT_DAILYPORECEIPTS_20250721.ACTUAL_RECEIPT_DATE) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_update_images_JPG_202050828_super /*+basename(deleteme_update_images_JPG_202050828),createtype(L)*/ 
(
 product,
 JPG
)
AS
 SELECT deleteme_update_images_JPG_202050828.product,
        deleteme_update_images_JPG_202050828.JPG
 FROM public.deleteme_update_images_JPG_202050828
 ORDER BY deleteme_update_images_JPG_202050828.product,
          deleteme_update_images_JPG_202050828.JPG
SEGMENTED BY hash(deleteme_update_images_JPG_202050828.product, deleteme_update_images_JPG_202050828.JPG) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_update_images_products_202050828_super /*+basename(deleteme_update_images_products_202050828),createtype(L)*/ 
(
 product
)
AS
 SELECT deleteme_update_images_products_202050828.product
 FROM public.deleteme_update_images_products_202050828
 ORDER BY deleteme_update_images_products_202050828.product
SEGMENTED BY hash(deleteme_update_images_products_202050828.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_update_images_URL_202050828_super /*+basename(deleteme_update_images_URL_202050828),createtype(L)*/ 
(
 product,
 URL
)
AS
 SELECT deleteme_update_images_URL_202050828.product,
        deleteme_update_images_URL_202050828.URL
 FROM public.deleteme_update_images_URL_202050828
 ORDER BY deleteme_update_images_URL_202050828.product,
          deleteme_update_images_URL_202050828.URL
SEGMENTED BY hash(deleteme_update_images_URL_202050828.product, deleteme_update_images_URL_202050828.URL) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_update_images_step1_202050828_super /*+basename(deleteme_update_images_step1_202050828),createtype(A)*/ 
(
 product,
 member_id,
 URL,
 FINAL_IMG
)
AS
 SELECT deleteme_update_images_step1_202050828.product,
        deleteme_update_images_step1_202050828.member_id,
        deleteme_update_images_step1_202050828.URL,
        deleteme_update_images_step1_202050828.FINAL_IMG
 FROM public.deleteme_update_images_step1_202050828
 ORDER BY deleteme_update_images_step1_202050828.product,
          deleteme_update_images_step1_202050828.member_id
SEGMENTED BY hash(deleteme_update_images_step1_202050828.member_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_styleattributes_existing_bk_20250926_super /*+basename(trd_ma_styleattributes_existing_bk_20250926),createtype(A)*/ 
(
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
 sty_patterned_after
)
AS
 SELECT trd_ma_styleattributes_existing_bk_20250926.product,
        trd_ma_styleattributes_existing_bk_20250926.sty_knit_or_woven,
        trd_ma_styleattributes_existing_bk_20250926.sty_fabrication,
        trd_ma_styleattributes_existing_bk_20250926.sty_sleeve_length,
        trd_ma_styleattributes_existing_bk_20250926.sty_leg_opening,
        trd_ma_styleattributes_existing_bk_20250926.sty_brand,
        trd_ma_styleattributes_existing_bk_20250926.sty_body_style_silhouette,
        trd_ma_styleattributes_existing_bk_20250926.sty_occasion_usage,
        trd_ma_styleattributes_existing_bk_20250926.sty_detail,
        trd_ma_styleattributes_existing_bk_20250926.sty_finish_style,
        trd_ma_styleattributes_existing_bk_20250926.sty_private_label,
        trd_ma_styleattributes_existing_bk_20250926.sty_license,
        trd_ma_styleattributes_existing_bk_20250926.sty_license_vs_non_licensed,
        trd_ma_styleattributes_existing_bk_20250926.sty_hazmat_code,
        trd_ma_styleattributes_existing_bk_20250926.sty_prop_65_warning,
        trd_ma_styleattributes_existing_bk_20250926.sty_material_content,
        trd_ma_styleattributes_existing_bk_20250926.sty_item_type,
        trd_ma_styleattributes_existing_bk_20250926.sty_dwrise,
        trd_ma_styleattributes_existing_bk_20250926.sty_length,
        trd_ma_styleattributes_existing_bk_20250926.sty_neckline,
        trd_ma_styleattributes_existing_bk_20250926.sty_toeshape,
        trd_ma_styleattributes_existing_bk_20250926.sty_heel_height,
        trd_ma_styleattributes_existing_bk_20250926.sty_bottom_length,
        trd_ma_styleattributes_existing_bk_20250926.sty_v_360_smoothing,
        trd_ma_styleattributes_existing_bk_20250926.sty_franchise,
        trd_ma_styleattributes_existing_bk_20250926.sty_key_item,
        trd_ma_styleattributes_existing_bk_20250926.sty_single_vs_multi_pack,
        trd_ma_styleattributes_existing_bk_20250926.sty_ticket_type,
        trd_ma_styleattributes_existing_bk_20250926.sty_vpn,
        trd_ma_styleattributes_existing_bk_20250926.sty_size_range,
        trd_ma_styleattributes_existing_bk_20250926.ccstylecreatedate,
        trd_ma_styleattributes_existing_bk_20250926.sty_is_locked,
        trd_ma_styleattributes_existing_bk_20250926.sty_s5_adopted,
        trd_ma_styleattributes_existing_bk_20250926.eventdate,
        trd_ma_styleattributes_existing_bk_20250926.version_id,
        trd_ma_styleattributes_existing_bk_20250926.created_at,
        trd_ma_styleattributes_existing_bk_20250926.created_by,
        trd_ma_styleattributes_existing_bk_20250926.updated_at,
        trd_ma_styleattributes_existing_bk_20250926.updated_by,
        trd_ma_styleattributes_existing_bk_20250926.record_state,
        trd_ma_styleattributes_existing_bk_20250926.plm_size_range,
        trd_ma_styleattributes_existing_bk_20250926.sty_knit_fit,
        trd_ma_styleattributes_existing_bk_20250926.sty_patterned_after
 FROM public.trd_ma_styleattributes_existing_bk_20250926
 ORDER BY trd_ma_styleattributes_existing_bk_20250926.product,
          trd_ma_styleattributes_existing_bk_20250926.sty_knit_or_woven,
          trd_ma_styleattributes_existing_bk_20250926.sty_fabrication,
          trd_ma_styleattributes_existing_bk_20250926.sty_sleeve_length,
          trd_ma_styleattributes_existing_bk_20250926.sty_leg_opening,
          trd_ma_styleattributes_existing_bk_20250926.sty_brand,
          trd_ma_styleattributes_existing_bk_20250926.sty_body_style_silhouette,
          trd_ma_styleattributes_existing_bk_20250926.sty_occasion_usage
SEGMENTED BY hash(trd_ma_styleattributes_existing_bk_20250926.eventdate, trd_ma_styleattributes_existing_bk_20250926.version_id, trd_ma_styleattributes_existing_bk_20250926.created_at, trd_ma_styleattributes_existing_bk_20250926.updated_at, trd_ma_styleattributes_existing_bk_20250926.record_state, trd_ma_styleattributes_existing_bk_20250926.product, trd_ma_styleattributes_existing_bk_20250926.sty_knit_or_woven, trd_ma_styleattributes_existing_bk_20250926.sty_fabrication) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_time_bk_20250928_super /*+basename(trd_d_time_bk_20250928),createtype(A)*/ 
(
 id,
 name,
 description,
 levelid,
 prev,
 next,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_time_bk_20250928.id,
        trd_d_time_bk_20250928.name,
        trd_d_time_bk_20250928.description,
        trd_d_time_bk_20250928.levelid,
        trd_d_time_bk_20250928.prev,
        trd_d_time_bk_20250928.next,
        trd_d_time_bk_20250928.indx,
        trd_d_time_bk_20250928.eventdate,
        trd_d_time_bk_20250928.version_id,
        trd_d_time_bk_20250928.created_at,
        trd_d_time_bk_20250928.created_by,
        trd_d_time_bk_20250928.updated_at,
        trd_d_time_bk_20250928.updated_by,
        trd_d_time_bk_20250928.record_state
 FROM public.trd_d_time_bk_20250928
 ORDER BY trd_d_time_bk_20250928.id,
          trd_d_time_bk_20250928.name,
          trd_d_time_bk_20250928.description,
          trd_d_time_bk_20250928.levelid,
          trd_d_time_bk_20250928.prev,
          trd_d_time_bk_20250928.next,
          trd_d_time_bk_20250928.indx,
          trd_d_time_bk_20250928.eventdate
SEGMENTED BY hash(trd_d_time_bk_20250928.indx, trd_d_time_bk_20250928.eventdate, trd_d_time_bk_20250928.version_id, trd_d_time_bk_20250928.created_at, trd_d_time_bk_20250928.updated_at, trd_d_time_bk_20250928.record_state, trd_d_time_bk_20250928.created_by, trd_d_time_bk_20250928.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_trd_h_prodstd_existing_super /*+basename(deleteme_trd_h_prodstd_existing),createtype(A)*/ 
(
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
AS
 SELECT deleteme_trd_h_prodstd_existing.id,
        deleteme_trd_h_prodstd_existing.ancestor0,
        deleteme_trd_h_prodstd_existing.ancestor1,
        deleteme_trd_h_prodstd_existing.ancestor2,
        deleteme_trd_h_prodstd_existing.ancestor3,
        deleteme_trd_h_prodstd_existing.ancestor4,
        deleteme_trd_h_prodstd_existing.ancestor5,
        deleteme_trd_h_prodstd_existing.ancestor6,
        deleteme_trd_h_prodstd_existing.ancestor7,
        deleteme_trd_h_prodstd_existing.version_id,
        deleteme_trd_h_prodstd_existing.created_at,
        deleteme_trd_h_prodstd_existing.created_by,
        deleteme_trd_h_prodstd_existing.updated_at,
        deleteme_trd_h_prodstd_existing.updated_by,
        deleteme_trd_h_prodstd_existing.record_state
 FROM public.deleteme_trd_h_prodstd_existing
 ORDER BY deleteme_trd_h_prodstd_existing.id,
          deleteme_trd_h_prodstd_existing.ancestor0,
          deleteme_trd_h_prodstd_existing.ancestor1,
          deleteme_trd_h_prodstd_existing.ancestor2,
          deleteme_trd_h_prodstd_existing.ancestor3,
          deleteme_trd_h_prodstd_existing.ancestor4,
          deleteme_trd_h_prodstd_existing.ancestor5,
          deleteme_trd_h_prodstd_existing.ancestor6
SEGMENTED BY hash(deleteme_trd_h_prodstd_existing.version_id, deleteme_trd_h_prodstd_existing.created_at, deleteme_trd_h_prodstd_existing.updated_at, deleteme_trd_h_prodstd_existing.record_state, deleteme_trd_h_prodstd_existing.id, deleteme_trd_h_prodstd_existing.ancestor0, deleteme_trd_h_prodstd_existing.ancestor1, deleteme_trd_h_prodstd_existing.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_existing_testing_sup3311_super /*+basename(trd_h_prodstd_existing_testing_sup3311),createtype(A)*/ 
(
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
AS
 SELECT trd_h_prodstd_existing_testing_sup3311.id,
        trd_h_prodstd_existing_testing_sup3311.ancestor0,
        trd_h_prodstd_existing_testing_sup3311.ancestor1,
        trd_h_prodstd_existing_testing_sup3311.ancestor2,
        trd_h_prodstd_existing_testing_sup3311.ancestor3,
        trd_h_prodstd_existing_testing_sup3311.ancestor4,
        trd_h_prodstd_existing_testing_sup3311.ancestor5,
        trd_h_prodstd_existing_testing_sup3311.ancestor6,
        trd_h_prodstd_existing_testing_sup3311.ancestor7,
        trd_h_prodstd_existing_testing_sup3311.version_id,
        trd_h_prodstd_existing_testing_sup3311.created_at,
        trd_h_prodstd_existing_testing_sup3311.created_by,
        trd_h_prodstd_existing_testing_sup3311.updated_at,
        trd_h_prodstd_existing_testing_sup3311.updated_by,
        trd_h_prodstd_existing_testing_sup3311.record_state
 FROM public.trd_h_prodstd_existing_testing_sup3311
 ORDER BY trd_h_prodstd_existing_testing_sup3311.id,
          trd_h_prodstd_existing_testing_sup3311.ancestor0,
          trd_h_prodstd_existing_testing_sup3311.ancestor1,
          trd_h_prodstd_existing_testing_sup3311.ancestor2,
          trd_h_prodstd_existing_testing_sup3311.ancestor3,
          trd_h_prodstd_existing_testing_sup3311.ancestor4,
          trd_h_prodstd_existing_testing_sup3311.ancestor5,
          trd_h_prodstd_existing_testing_sup3311.ancestor6
SEGMENTED BY hash(trd_h_prodstd_existing_testing_sup3311.version_id, trd_h_prodstd_existing_testing_sup3311.created_at, trd_h_prodstd_existing_testing_sup3311.updated_at, trd_h_prodstd_existing_testing_sup3311.record_state, trd_h_prodstd_existing_testing_sup3311.id, trd_h_prodstd_existing_testing_sup3311.ancestor0, trd_h_prodstd_existing_testing_sup3311.ancestor1, trd_h_prodstd_existing_testing_sup3311.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_stylecolorchannelattributes_existing_bkp_super /*+basename(trd_ma_stylecolorchannelattributes_existing_bkp),createtype(L)*/ 
(
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
AS
 SELECT trd_ma_stylecolorchannelattributes_existing_bkp.product,
        trd_ma_stylecolorchannelattributes_existing_bkp.location,
        trd_ma_stylecolorchannelattributes_existing_bkp.dbt_wk,
        trd_ma_stylecolorchannelattributes_existing_bkp.relaunchweek,
        trd_ma_stylecolorchannelattributes_existing_bkp.erlstmkdnwk,
        trd_ma_stylecolorchannelattributes_existing_bkp.exitdate,
        trd_ma_stylecolorchannelattributes_existing_bkp.initrcptwk,
        trd_ma_stylecolorchannelattributes_existing_bkp.too,
        trd_ma_stylecolorchannelattributes_existing_bkp.mkdnwks,
        trd_ma_stylecolorchannelattributes_existing_bkp.last_inv_wk,
        trd_ma_stylecolorchannelattributes_existing_bkp.lstfpwk,
        trd_ma_stylecolorchannelattributes_existing_bkp.last_rcpt_wk,
        trd_ma_stylecolorchannelattributes_existing_bkp.lastdcorder,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_initrcptwk,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_dbt_wk,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.dbtwk_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.relaunchwk_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.mdstart_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.lastdcorder_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.exitdate_indx,
        trd_ma_stylecolorchannelattributes_existing_bkp.preview_wks,
        trd_ma_stylecolorchannelattributes_existing_bkp.preview_qty,
        trd_ma_stylecolorchannelattributes_existing_bkp.plannedselldnwk,
        trd_ma_stylecolorchannelattributes_existing_bkp.ccmdstrategy,
        trd_ma_stylecolorchannelattributes_existing_bkp.slsrnk_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.slsrnk_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.validsizes,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_validsizes_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_validsizes_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.ccrangecode,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_presmin,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_presmin_weeks,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_rcptint,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_return_u_pct_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_return_u_pct_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_return_u_pct_cross,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_ordermultiple,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_ordermin,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_buy_aps_letter,
        trd_ma_stylecolorchannelattributes_existing_bkp.ccticketpricechannel,
        trd_ma_stylecolorchannelattributes_existing_bkp.ccticketpricechannel_override,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_imupct,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_discount_pct,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_existingwac,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_systemcost,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_plan_cost,
        trd_ma_stylecolorchannelattributes_existing_bkp.ssnprf,
        trd_ma_stylecolorchannelattributes_existing_bkp.adjaps_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.adjaps_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.smoothing_strategy,
        trd_ma_stylecolorchannelattributes_existing_bkp.in_season_flag,
        trd_ma_stylecolorchannelattributes_existing_bkp.auto_rollforward,
        trd_ma_stylecolorchannelattributes_existing_bkp.irr_mode,
        trd_ma_stylecolorchannelattributes_existing_bkp.plan_current,
        trd_ma_stylecolorchannelattributes_existing_bkp.lock_agg_edit,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_lead_time,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_service_level,
        trd_ma_stylecolorchannelattributes_existing_bkp.eventdate,
        trd_ma_stylecolorchannelattributes_existing_bkp.version_id,
        trd_ma_stylecolorchannelattributes_existing_bkp.created_at,
        trd_ma_stylecolorchannelattributes_existing_bkp.created_by,
        trd_ma_stylecolorchannelattributes_existing_bkp.updated_at,
        trd_ma_stylecolorchannelattributes_existing_bkp.updated_by,
        trd_ma_stylecolorchannelattributes_existing_bkp.record_state,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_store_min_multiple,
        trd_ma_stylecolorchannelattributes_existing_bkp.planned_sell_down_week,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_selected_clusters,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_cluster_group,
        trd_ma_stylecolorchannelattributes_existing_bkp.keep_initial_range_plan,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_sizeelig_rangecode,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_presmin_stylecolor,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_presmin_weeks_stylecolor,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_final_cost,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_discount_pct_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_discount_pct_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_debut_offset,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_service_level_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_first_publish_date,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_first_publish_snapshot_op,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_alloc_max,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_presmin,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_alloc_min,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_presmin_weeks,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_tgt_fwoc,
        trd_ma_stylecolorchannelattributes_existing_bkp.sclr_fringe_flag,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_slsrnk_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_aps_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_aps_mult_adj_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_slsrnk_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_aps_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.act_aps_mult_adj_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.use_act_aps_or_act_rank,
        trd_ma_stylecolorchannelattributes_existing_bkp.use_valid_sizes_from,
        trd_ma_stylecolorchannelattributes_existing_bkp.apply_size_mins_to,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_addoff_store,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_addoff_ecom,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_floorset,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_superset,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_floorset_display,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_superset_display,
        trd_ma_stylecolorchannelattributes_existing_bkp.irw_floorset_id,
        trd_ma_stylecolorchannelattributes_existing_bkp.cc_size_eligibility_profile,
        trd_ma_stylecolorchannelattributes_existing_bkp.cloned_at
 FROM public.trd_ma_stylecolorchannelattributes_existing_bkp
 ORDER BY trd_ma_stylecolorchannelattributes_existing_bkp.product,
          trd_ma_stylecolorchannelattributes_existing_bkp.location,
          trd_ma_stylecolorchannelattributes_existing_bkp.dbt_wk,
          trd_ma_stylecolorchannelattributes_existing_bkp.relaunchweek,
          trd_ma_stylecolorchannelattributes_existing_bkp.erlstmkdnwk,
          trd_ma_stylecolorchannelattributes_existing_bkp.exitdate,
          trd_ma_stylecolorchannelattributes_existing_bkp.initrcptwk,
          trd_ma_stylecolorchannelattributes_existing_bkp.too
SEGMENTED BY hash(trd_ma_stylecolorchannelattributes_existing_bkp.too, trd_ma_stylecolorchannelattributes_existing_bkp.mkdnwks, trd_ma_stylecolorchannelattributes_existing_bkp.irw_indx, trd_ma_stylecolorchannelattributes_existing_bkp.dbtwk_indx, trd_ma_stylecolorchannelattributes_existing_bkp.relaunchwk_indx, trd_ma_stylecolorchannelattributes_existing_bkp.mdstart_indx, trd_ma_stylecolorchannelattributes_existing_bkp.lastdcorder_indx, trd_ma_stylecolorchannelattributes_existing_bkp.exitdate_indx) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES_super /*+basename(TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES),createtype(L)*/ 
(
 VPN_VSN,
 VPN_DESCRIPTION,
 VPN_COLOR,
 VPN_COLOR_DESCRIPTION,
 DEPT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 ITEM_DIFF_1,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 DW_COLOR_FAMILY,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 AGENT_FEE,
 DUTY,
 PORT,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 FACTORY,
 PO_SUPPLIER,
 SUB_BRAND,
 DESIGN_STYLECOLOR_STATUS,
 PRIMARY_SUPPLIER,
 SUPP_COST,
 ART_CODE,
 MATERIAL_CONTENT,
 DIVISION,
 GROUP_ID,
 DEVELOPMENT_SEASON,
 DELIVERY_SEASON,
 PO_DUE_DATE,
 PD_NDC_WEEK,
 ADDITIONAL_TARIFF,
 DESIGN_NOTES,
 PD_NOTES,
 COMPLIANCE_NOTES,
 SPEC_STYLECOLOR_OPEN1,
 SPEC_STYLECOLOR_OPEN2,
 SPEC_STYLECOLOR_OPEN3,
 SPEC_STYLECOLOR_OPEN4,
 SPEC_STYLECOLOR_OPEN5,
 SPEC_STYLECOLOR_OPEN6,
 SPEC_STYLECOLOR_OPEN7,
 SPEC_STYLECOLOR_OPEN8,
 SPEC_STYLECOLOR_OPEN9,
 SPEC_STYLECOLOR_OPEN10,
 SPEC_STYLECOLOR_OPEN11,
 SPEC_STYLECOLOR_OPEN12
)
AS
 SELECT TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_VSN,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DEPT_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.CLASS_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SUBCLASS_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.ITEM_DIFF_1,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.EXPORT_HTS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DW_COLOR_FAMILY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.ORIGIN_COUNTRY_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.COUNTRY_OF_SOURCING,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.COUNTRY_OF_MANUFACTURING,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.UNIT_COST,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.FREIGHT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.AGENT_FEE,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DUTY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PORT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SHIP_METHOD,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.LADING_PORT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.HTS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.FACTORY,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PO_SUPPLIER,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SUB_BRAND,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DESIGN_STYLECOLOR_STATUS,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PRIMARY_SUPPLIER,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SUPP_COST,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.ART_CODE,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.MATERIAL_CONTENT,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DIVISION,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.GROUP_ID,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DEVELOPMENT_SEASON,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DELIVERY_SEASON,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PO_DUE_DATE,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PD_NDC_WEEK,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.ADDITIONAL_TARIFF,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DESIGN_NOTES,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.PD_NOTES,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.COMPLIANCE_NOTES,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN1,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN2,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN3,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN4,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN5,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN6,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN7,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN8,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN9,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN10,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN11,
        TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN12
 FROM public.TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES
 ORDER BY TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_VSN,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DEPT_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.CLASS_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SUBCLASS_ID,
          TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.ITEM_DIFF_1
SEGMENTED BY hash(TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.UNIT_COST, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.SUPP_COST, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_VSN, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.DEPT_ID, TRD_IN_PRD_SPECSTYLECOLORATTRIBUTES.CLASS_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REJ_SPECSTYLECOLORATTRIBUTES_super /*+basename(TRD_REJ_SPECSTYLECOLORATTRIBUTES),createtype(L)*/ 
(
 VPN_VSN,
 VPN_DESCRIPTION,
 VPN_COLOR,
 VPN_COLOR_DESCRIPTION,
 DEPT_ID,
 CLASS_ID,
 SUBCLASS_ID,
 ITEM_DIFF_1,
 EXPORT_HTS,
 COMMERCIAL_INVOICE_DESCRIPTION,
 DW_COLOR_FAMILY,
 ORIGIN_COUNTRY_ID,
 COUNTRY_OF_SOURCING,
 COUNTRY_OF_MANUFACTURING,
 UNIT_COST,
 FREIGHT,
 AGENT_FEE,
 DUTY,
 PORT,
 SHIP_METHOD,
 LADING_PORT,
 HTS,
 FACTORY,
 PO_SUPPLIER,
 SUB_BRAND,
 DESIGN_STYLECOLOR_STATUS,
 PRIMARY_SUPPLIER,
 SUPP_COST,
 ART_CODE,
 MATERIAL_CONTENT,
 DIVISION,
 GROUP_ID,
 DEVELOPMENT_SEASON,
 DELIVERY_SEASON,
 PO_DUE_DATE,
 PD_NDC_WEEK,
 ADDITIONAL_TARIFF,
 DESIGN_NOTES,
 PD_NOTES,
 COMPILANCE_NOTES,
 SPEC_STYLECOLOR_OPEN1,
 SPEC_STYLECOLOR_OPEN2,
 SPEC_STYLECOLOR_OPEN3,
 SPEC_STYLECOLOR_OPEN4,
 SPEC_STYLECOLOR_OPEN5,
 SPEC_STYLECOLOR_OPEN6,
 SPEC_STYLECOLOR_OPEN7,
 SPEC_STYLECOLOR_OPEN8,
 SPEC_STYLECOLOR_OPEN9,
 SPEC_STYLECOLOR_OPEN10,
 SPEC_STYLECOLOR_OPEN11,
 SPEC_STYLECOLOR_OPEN12,
 REJECT_REASON
)
AS
 SELECT TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_VSN,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DEPT_ID,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.CLASS_ID,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SUBCLASS_ID,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.ITEM_DIFF_1,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.EXPORT_HTS,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.COMMERCIAL_INVOICE_DESCRIPTION,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DW_COLOR_FAMILY,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.ORIGIN_COUNTRY_ID,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.COUNTRY_OF_SOURCING,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.COUNTRY_OF_MANUFACTURING,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.UNIT_COST,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.FREIGHT,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.AGENT_FEE,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DUTY,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PORT,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SHIP_METHOD,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.LADING_PORT,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.HTS,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.FACTORY,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PO_SUPPLIER,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SUB_BRAND,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DESIGN_STYLECOLOR_STATUS,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PRIMARY_SUPPLIER,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SUPP_COST,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.ART_CODE,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.MATERIAL_CONTENT,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DIVISION,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.GROUP_ID,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DEVELOPMENT_SEASON,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DELIVERY_SEASON,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PO_DUE_DATE,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PD_NDC_WEEK,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.ADDITIONAL_TARIFF,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.DESIGN_NOTES,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.PD_NOTES,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.COMPILANCE_NOTES,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN1,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN2,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN3,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN4,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN5,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN6,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN7,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN8,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN9,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN10,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN11,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.SPEC_STYLECOLOR_OPEN12,
        TRD_REJ_SPECSTYLECOLORATTRIBUTES.REJECT_REASON
 FROM public.TRD_REJ_SPECSTYLECOLORATTRIBUTES
 ORDER BY TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_VSN,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.DEPT_ID,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.CLASS_ID,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.SUBCLASS_ID,
          TRD_REJ_SPECSTYLECOLORATTRIBUTES.ITEM_DIFF_1
SEGMENTED BY hash(TRD_REJ_SPECSTYLECOLORATTRIBUTES.UNIT_COST, TRD_REJ_SPECSTYLECOLORATTRIBUTES.SUPP_COST, TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_VSN, TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_DESCRIPTION, TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR, TRD_REJ_SPECSTYLECOLORATTRIBUTES.VPN_COLOR_DESCRIPTION, TRD_REJ_SPECSTYLECOLORATTRIBUTES.DEPT_ID, TRD_REJ_SPECSTYLECOLORATTRIBUTES.CLASS_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.deleteme_TRD_IN_BUS_SIZERANGE_MAPPING_super /*+basename(deleteme_TRD_IN_BUS_SIZERANGE_MAPPING),createtype(A)*/ 
(
 size_range,
 size_id,
 size_desc,
 sort_order,
 parent_size,
 fringe_size_ind
)
AS
 SELECT deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_range,
        deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_id,
        deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_desc,
        deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.sort_order,
        deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.parent_size,
        deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind
 FROM public.deleteme_TRD_IN_BUS_SIZERANGE_MAPPING
 ORDER BY deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_range,
          deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_id,
          deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_desc,
          deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.sort_order,
          deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.parent_size,
          deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind
SEGMENTED BY hash(deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.sort_order, deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind, deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_range, deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_id, deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.size_desc, deleteme_TRD_IN_BUS_SIZERANGE_MAPPING.parent_size) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST_super /*+basename(TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST
 ORDER BY TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_DAILY_JRTEST.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST."TIME",
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST."TIME",
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_R, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_U, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOH_C, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_DAILY_JRTEST.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_DAILY_JRTEST.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_20250202_bk_super /*+basename(TRD_IN_ACT_DEMAND_SALES_20250202_bk),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_20250202_bk.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_20250202_bk
 ORDER BY TRD_IN_ACT_DEMAND_SALES_20250202_bk.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_20250202_bk.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_20250202_bk.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_20250202_bk.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_20250202_bk.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_20250202_bk.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_20250202_bk.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_20250202_bk_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_20250202_bk),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_20250202_bk.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk."TIME",
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_20250202_bk
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_20250202_bk.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk."TIME",
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_R, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_U, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOH_C, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_20250202_bk.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_sizeattributes_existing_bk_sup_3663_super /*+basename(trd_ma_sizeattributes_existing_bk_sup_3663),createtype(A)*/ 
(
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
AS
 SELECT trd_ma_sizeattributes_existing_bk_sup_3663.product,
        trd_ma_sizeattributes_existing_bk_sup_3663.parent_id,
        trd_ma_sizeattributes_existing_bk_sup_3663.item_diff_2,
        trd_ma_sizeattributes_existing_bk_sup_3663.item_diff_3,
        trd_ma_sizeattributes_existing_bk_sup_3663.sizeattribute,
        trd_ma_sizeattributes_existing_bk_sup_3663.isvalid,
        trd_ma_sizeattributes_existing_bk_sup_3663.eventdate,
        trd_ma_sizeattributes_existing_bk_sup_3663.version_id,
        trd_ma_sizeattributes_existing_bk_sup_3663.created_at,
        trd_ma_sizeattributes_existing_bk_sup_3663.created_by,
        trd_ma_sizeattributes_existing_bk_sup_3663.updated_at,
        trd_ma_sizeattributes_existing_bk_sup_3663.updated_by,
        trd_ma_sizeattributes_existing_bk_sup_3663.record_state,
        trd_ma_sizeattributes_existing_bk_sup_3663.ccctylecolorsizecreatedate
 FROM public.trd_ma_sizeattributes_existing_bk_sup_3663
 ORDER BY trd_ma_sizeattributes_existing_bk_sup_3663.product,
          trd_ma_sizeattributes_existing_bk_sup_3663.parent_id,
          trd_ma_sizeattributes_existing_bk_sup_3663.item_diff_2,
          trd_ma_sizeattributes_existing_bk_sup_3663.item_diff_3,
          trd_ma_sizeattributes_existing_bk_sup_3663.sizeattribute,
          trd_ma_sizeattributes_existing_bk_sup_3663.isvalid,
          trd_ma_sizeattributes_existing_bk_sup_3663.eventdate,
          trd_ma_sizeattributes_existing_bk_sup_3663.version_id
SEGMENTED BY hash(trd_ma_sizeattributes_existing_bk_sup_3663.isvalid, trd_ma_sizeattributes_existing_bk_sup_3663.eventdate, trd_ma_sizeattributes_existing_bk_sup_3663.version_id, trd_ma_sizeattributes_existing_bk_sup_3663.created_at, trd_ma_sizeattributes_existing_bk_sup_3663.updated_at, trd_ma_sizeattributes_existing_bk_sup_3663.record_state, trd_ma_sizeattributes_existing_bk_sup_3663.product, trd_ma_sizeattributes_existing_bk_sup_3663.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_existing_bk_sup_3663_super /*+basename(trd_d_product_existing_bk_sup_3663),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_product_existing_bk_sup_3663.id,
        trd_d_product_existing_bk_sup_3663.client_id,
        trd_d_product_existing_bk_sup_3663.name,
        trd_d_product_existing_bk_sup_3663.description,
        trd_d_product_existing_bk_sup_3663.levelid,
        trd_d_product_existing_bk_sup_3663.indx,
        trd_d_product_existing_bk_sup_3663.eventdate,
        trd_d_product_existing_bk_sup_3663.version_id,
        trd_d_product_existing_bk_sup_3663.created_at,
        trd_d_product_existing_bk_sup_3663.created_by,
        trd_d_product_existing_bk_sup_3663.updated_at,
        trd_d_product_existing_bk_sup_3663.updated_by,
        trd_d_product_existing_bk_sup_3663.record_state
 FROM public.trd_d_product_existing_bk_sup_3663
 ORDER BY trd_d_product_existing_bk_sup_3663.id,
          trd_d_product_existing_bk_sup_3663.client_id,
          trd_d_product_existing_bk_sup_3663.name,
          trd_d_product_existing_bk_sup_3663.description,
          trd_d_product_existing_bk_sup_3663.levelid,
          trd_d_product_existing_bk_sup_3663.indx,
          trd_d_product_existing_bk_sup_3663.eventdate,
          trd_d_product_existing_bk_sup_3663.version_id
SEGMENTED BY hash(trd_d_product_existing_bk_sup_3663.indx, trd_d_product_existing_bk_sup_3663.eventdate, trd_d_product_existing_bk_sup_3663.version_id, trd_d_product_existing_bk_sup_3663.created_at, trd_d_product_existing_bk_sup_3663.updated_at, trd_d_product_existing_bk_sup_3663.record_state, trd_d_product_existing_bk_sup_3663.levelid, trd_d_product_existing_bk_sup_3663.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_existing_bk_sup_3663_super /*+basename(trd_h_prodstd_existing_bk_sup_3663),createtype(A)*/ 
(
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
AS
 SELECT trd_h_prodstd_existing_bk_sup_3663.id,
        trd_h_prodstd_existing_bk_sup_3663.ancestor0,
        trd_h_prodstd_existing_bk_sup_3663.ancestor1,
        trd_h_prodstd_existing_bk_sup_3663.ancestor2,
        trd_h_prodstd_existing_bk_sup_3663.ancestor3,
        trd_h_prodstd_existing_bk_sup_3663.ancestor4,
        trd_h_prodstd_existing_bk_sup_3663.ancestor5,
        trd_h_prodstd_existing_bk_sup_3663.ancestor6,
        trd_h_prodstd_existing_bk_sup_3663.ancestor7,
        trd_h_prodstd_existing_bk_sup_3663.version_id,
        trd_h_prodstd_existing_bk_sup_3663.created_at,
        trd_h_prodstd_existing_bk_sup_3663.created_by,
        trd_h_prodstd_existing_bk_sup_3663.updated_at,
        trd_h_prodstd_existing_bk_sup_3663.updated_by,
        trd_h_prodstd_existing_bk_sup_3663.record_state
 FROM public.trd_h_prodstd_existing_bk_sup_3663
 ORDER BY trd_h_prodstd_existing_bk_sup_3663.id,
          trd_h_prodstd_existing_bk_sup_3663.ancestor0,
          trd_h_prodstd_existing_bk_sup_3663.ancestor1,
          trd_h_prodstd_existing_bk_sup_3663.ancestor2,
          trd_h_prodstd_existing_bk_sup_3663.ancestor3,
          trd_h_prodstd_existing_bk_sup_3663.ancestor4,
          trd_h_prodstd_existing_bk_sup_3663.ancestor5,
          trd_h_prodstd_existing_bk_sup_3663.ancestor6
SEGMENTED BY hash(trd_h_prodstd_existing_bk_sup_3663.version_id, trd_h_prodstd_existing_bk_sup_3663.created_at, trd_h_prodstd_existing_bk_sup_3663.updated_at, trd_h_prodstd_existing_bk_sup_3663.record_state, trd_h_prodstd_existing_bk_sup_3663.id, trd_h_prodstd_existing_bk_sup_3663.ancestor0, trd_h_prodstd_existing_bk_sup_3663.ancestor1, trd_h_prodstd_existing_bk_sup_3663.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.duplicate_sizes_sup3663_super /*+basename(duplicate_sizes_sup3663),createtype(A)*/ 
(
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
 ccctylecolorsizecreatedate,
 status
)
AS
 SELECT duplicate_sizes_sup3663.product,
        duplicate_sizes_sup3663.parent_id,
        duplicate_sizes_sup3663.item_diff_2,
        duplicate_sizes_sup3663.item_diff_3,
        duplicate_sizes_sup3663.sizeattribute,
        duplicate_sizes_sup3663.isvalid,
        duplicate_sizes_sup3663.eventdate,
        duplicate_sizes_sup3663.version_id,
        duplicate_sizes_sup3663.created_at,
        duplicate_sizes_sup3663.created_by,
        duplicate_sizes_sup3663.updated_at,
        duplicate_sizes_sup3663.updated_by,
        duplicate_sizes_sup3663.record_state,
        duplicate_sizes_sup3663.ccctylecolorsizecreatedate,
        duplicate_sizes_sup3663.status
 FROM public.duplicate_sizes_sup3663
 ORDER BY duplicate_sizes_sup3663.product,
          duplicate_sizes_sup3663.parent_id,
          duplicate_sizes_sup3663.item_diff_2,
          duplicate_sizes_sup3663.item_diff_3,
          duplicate_sizes_sup3663.sizeattribute,
          duplicate_sizes_sup3663.isvalid,
          duplicate_sizes_sup3663.eventdate,
          duplicate_sizes_sup3663.version_id
SEGMENTED BY hash(duplicate_sizes_sup3663.isvalid, duplicate_sizes_sup3663.eventdate, duplicate_sizes_sup3663.version_id, duplicate_sizes_sup3663.created_at, duplicate_sizes_sup3663.updated_at, duplicate_sizes_sup3663.record_state, duplicate_sizes_sup3663.product, duplicate_sizes_sup3663.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_mock_sup3663_super /*+basename(trd_d_product_mock_sup3663),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description
)
AS
 SELECT trd_d_product_mock_sup3663.id,
        trd_d_product_mock_sup3663.client_id,
        trd_d_product_mock_sup3663.name,
        trd_d_product_mock_sup3663.description
 FROM public.trd_d_product_mock_sup3663
 ORDER BY trd_d_product_mock_sup3663.id,
          trd_d_product_mock_sup3663.client_id,
          trd_d_product_mock_sup3663.name,
          trd_d_product_mock_sup3663.description
SEGMENTED BY hash(trd_d_product_mock_sup3663.id, trd_d_product_mock_sup3663.client_id, trd_d_product_mock_sup3663.name, trd_d_product_mock_sup3663.description) ALL NODES OFFSET 0;

CREATE PROJECTION public.delete_me_super /*+basename(delete_me),createtype(A)*/ 
(
 product,
 class,
 location,
 week,
 floorset,
 str_grade,
 eventdate
)
AS
 SELECT delete_me.product,
        delete_me.class,
        delete_me.location,
        delete_me.week,
        delete_me.floorset,
        delete_me.str_grade,
        delete_me.eventdate
 FROM public.delete_me
 ORDER BY delete_me.location,
          delete_me.class,
          delete_me.week,
          delete_me.str_grade
SEGMENTED BY hash(delete_me.week, delete_me.str_grade, delete_me.location, delete_me.class) ALL NODES OFFSET 0;

CREATE PROJECTION public.NRF_ANALYTICS_EVENT_MAPPING_super /*+basename(NRF_ANALYTICS_EVENT_MAPPING),createtype(L)*/ 
(
 Event,
 Week,
 WeekIndx,
 MonthIndx,
 year
)
AS
 SELECT NRF_ANALYTICS_EVENT_MAPPING.Event,
        NRF_ANALYTICS_EVENT_MAPPING.Week,
        NRF_ANALYTICS_EVENT_MAPPING.WeekIndx,
        NRF_ANALYTICS_EVENT_MAPPING.MonthIndx,
        NRF_ANALYTICS_EVENT_MAPPING.year
 FROM public.NRF_ANALYTICS_EVENT_MAPPING
 ORDER BY NRF_ANALYTICS_EVENT_MAPPING.Event,
          NRF_ANALYTICS_EVENT_MAPPING.Week,
          NRF_ANALYTICS_EVENT_MAPPING.WeekIndx,
          NRF_ANALYTICS_EVENT_MAPPING.MonthIndx,
          NRF_ANALYTICS_EVENT_MAPPING.year
SEGMENTED BY hash(NRF_ANALYTICS_EVENT_MAPPING.WeekIndx, NRF_ANALYTICS_EVENT_MAPPING.MonthIndx, NRF_ANALYTICS_EVENT_MAPPING.year, NRF_ANALYTICS_EVENT_MAPPING.Event, NRF_ANALYTICS_EVENT_MAPPING.Week) ALL NODES OFFSET 0;

CREATE PROJECTION public.NRF_WEEK_ATTRIBUTES_super /*+basename(NRF_WEEK_ATTRIBUTES),createtype(L)*/ 
(
 "time",
 start_date,
 end_date
)
AS
 SELECT NRF_WEEK_ATTRIBUTES."time",
        NRF_WEEK_ATTRIBUTES.start_date,
        NRF_WEEK_ATTRIBUTES.end_date
 FROM public.NRF_WEEK_ATTRIBUTES
 ORDER BY NRF_WEEK_ATTRIBUTES."time",
          NRF_WEEK_ATTRIBUTES.start_date,
          NRF_WEEK_ATTRIBUTES.end_date
SEGMENTED BY hash(NRF_WEEK_ATTRIBUTES."time", NRF_WEEK_ATTRIBUTES.start_date, NRF_WEEK_ATTRIBUTES.end_date) ALL NODES OFFSET 0;

CREATE PROJECTION public.NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE_super /*+basename(NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE),createtype(A)*/ 
(
 "time",
 start_date,
 end_date,
 trd_time
)
AS
 SELECT NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE."time",
        NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.start_date,
        NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.end_date,
        NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.trd_time
 FROM public.NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE
 ORDER BY NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE."time",
          NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.start_date,
          NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.end_date
SEGMENTED BY hash(NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE."time", NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.start_date, NRF_WEEK_ATTRIBUTES_WITH_trd_WEEKDATE.end_date) ALL NODES OFFSET 0;

CREATE PROJECTION public.NRF_ANALYTICS_EVENT_MAPPING_trd_TIME_super /*+basename(NRF_ANALYTICS_EVENT_MAPPING_trd_TIME),createtype(A)*/ 
(
 Event,
 Week,
 WeekIndx,
 MonthIndx,
 year,
 trd_time,
 trd_month,
 trd_WeekIndx,
 trd_MonthIndx
)
AS
 SELECT NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.Event,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.Week,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.WeekIndx,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.MonthIndx,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.year,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.trd_time,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.trd_month,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.trd_WeekIndx,
        NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.trd_MonthIndx
 FROM public.NRF_ANALYTICS_EVENT_MAPPING_trd_TIME
 ORDER BY NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.Week
SEGMENTED BY hash(NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.WeekIndx, NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.MonthIndx, NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.year, NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.Event, NRF_ANALYTICS_EVENT_MAPPING_trd_TIME.Week) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ANALYTICS_EVENT_MAPPING_super /*+basename(trd_ANALYTICS_EVENT_MAPPING),createtype(A)*/ 
(
 Event,
 "time",
 month,
 WeekIndx,
 MonthIndx
)
AS
 SELECT trd_ANALYTICS_EVENT_MAPPING.Event,
        trd_ANALYTICS_EVENT_MAPPING."time",
        trd_ANALYTICS_EVENT_MAPPING.month,
        trd_ANALYTICS_EVENT_MAPPING.WeekIndx,
        trd_ANALYTICS_EVENT_MAPPING.MonthIndx
 FROM public.trd_ANALYTICS_EVENT_MAPPING
 ORDER BY trd_ANALYTICS_EVENT_MAPPING.Event,
          trd_ANALYTICS_EVENT_MAPPING."time",
          trd_ANALYTICS_EVENT_MAPPING.month,
          trd_ANALYTICS_EVENT_MAPPING.WeekIndx,
          trd_ANALYTICS_EVENT_MAPPING.MonthIndx
SEGMENTED BY hash(trd_ANALYTICS_EVENT_MAPPING.WeekIndx, trd_ANALYTICS_EVENT_MAPPING.MonthIndx, trd_ANALYTICS_EVENT_MAPPING.Event, trd_ANALYTICS_EVENT_MAPPING."time", trd_ANALYTICS_EVENT_MAPPING.month) ALL NODES OFFSET 0;

CREATE PROJECTION public.MONTH_MAX_WEEK_super /*+basename(MONTH_MAX_WEEK),createtype(A)*/ 
(
 month,
 "time"
)
AS
 SELECT MONTH_MAX_WEEK.month,
        MONTH_MAX_WEEK."time"
 FROM public.MONTH_MAX_WEEK
 ORDER BY MONTH_MAX_WEEK.month
SEGMENTED BY hash(MONTH_MAX_WEEK.month, MONTH_MAX_WEEK."time") ALL NODES OFFSET 0;

CREATE PROJECTION public.MAX_ELAPSED_super /*+basename(MAX_ELAPSED),createtype(A)*/ 
(
 max_time
)
AS
 SELECT MAX_ELAPSED.max_time
 FROM public.MAX_ELAPSED
 ORDER BY MAX_ELAPSED.max_time
SEGMENTED BY hash(MAX_ELAPSED.max_time) ALL NODES OFFSET 0;

CREATE PROJECTION public.MIN_START_FROM_ELAPSED_super /*+basename(MIN_START_FROM_ELAPSED),createtype(A)*/ 
(
 min_start
)
AS
 SELECT MIN_START_FROM_ELAPSED.min_start
 FROM public.MIN_START_FROM_ELAPSED
 ORDER BY MIN_START_FROM_ELAPSED.min_start
SEGMENTED BY hash(MIN_START_FROM_ELAPSED.min_start) ALL NODES OFFSET 0;

CREATE PROJECTION public.MORPHED_TIME_MAP_super /*+basename(MORPHED_TIME_MAP),createtype(A)*/ 
(
 c_week,
 c_month,
 c_qtr,
 c_season,
 c_year,
 rn,
 s5_week,
 s5_month,
 s5_qtr,
 s5_season,
 s5_year
)
AS
 SELECT MORPHED_TIME_MAP.c_week,
        MORPHED_TIME_MAP.c_month,
        MORPHED_TIME_MAP.c_qtr,
        MORPHED_TIME_MAP.c_season,
        MORPHED_TIME_MAP.c_year,
        MORPHED_TIME_MAP.rn,
        MORPHED_TIME_MAP.s5_week,
        MORPHED_TIME_MAP.s5_month,
        MORPHED_TIME_MAP.s5_qtr,
        MORPHED_TIME_MAP.s5_season,
        MORPHED_TIME_MAP.s5_year
 FROM public.MORPHED_TIME_MAP
 ORDER BY MORPHED_TIME_MAP.c_week,
          MORPHED_TIME_MAP.c_month,
          MORPHED_TIME_MAP.c_qtr,
          MORPHED_TIME_MAP.c_season,
          MORPHED_TIME_MAP.c_year
SEGMENTED BY hash(MORPHED_TIME_MAP.rn, MORPHED_TIME_MAP.c_week, MORPHED_TIME_MAP.c_month, MORPHED_TIME_MAP.c_qtr, MORPHED_TIME_MAP.c_season, MORPHED_TIME_MAP.c_year, MORPHED_TIME_MAP.s5_week, MORPHED_TIME_MAP.s5_month) ALL NODES OFFSET 0;

CREATE PROJECTION public.MORPHED_TIME_MAP_HISTORY_super /*+basename(MORPHED_TIME_MAP_HISTORY),createtype(A)*/ 
(
 c_week,
 c_month,
 c_qtr,
 c_season,
 c_year,
 rn,
 s5_week,
 s5_month,
 s5_qtr,
 s5_season,
 s5_year
)
AS
 SELECT MORPHED_TIME_MAP_HISTORY.c_week,
        MORPHED_TIME_MAP_HISTORY.c_month,
        MORPHED_TIME_MAP_HISTORY.c_qtr,
        MORPHED_TIME_MAP_HISTORY.c_season,
        MORPHED_TIME_MAP_HISTORY.c_year,
        MORPHED_TIME_MAP_HISTORY.rn,
        MORPHED_TIME_MAP_HISTORY.s5_week,
        MORPHED_TIME_MAP_HISTORY.s5_month,
        MORPHED_TIME_MAP_HISTORY.s5_qtr,
        MORPHED_TIME_MAP_HISTORY.s5_season,
        MORPHED_TIME_MAP_HISTORY.s5_year
 FROM public.MORPHED_TIME_MAP_HISTORY
 ORDER BY MORPHED_TIME_MAP_HISTORY.c_week,
          MORPHED_TIME_MAP_HISTORY.c_month,
          MORPHED_TIME_MAP_HISTORY.c_qtr,
          MORPHED_TIME_MAP_HISTORY.c_season,
          MORPHED_TIME_MAP_HISTORY.c_year
SEGMENTED BY hash(MORPHED_TIME_MAP_HISTORY.rn, MORPHED_TIME_MAP_HISTORY.c_week, MORPHED_TIME_MAP_HISTORY.c_month, MORPHED_TIME_MAP_HISTORY.c_qtr, MORPHED_TIME_MAP_HISTORY.c_season, MORPHED_TIME_MAP_HISTORY.c_year, MORPHED_TIME_MAP_HISTORY.s5_week, MORPHED_TIME_MAP_HISTORY.s5_month) ALL NODES OFFSET 0;

CREATE PROJECTION public.MORPHED_TIME_MAP_FUTURE_super /*+basename(MORPHED_TIME_MAP_FUTURE),createtype(A)*/ 
(
 c_week,
 c_month,
 c_qtr,
 c_season,
 c_year,
 rn,
 s5_week,
 s5_month,
 s5_qtr,
 s5_season,
 s5_year
)
AS
 SELECT MORPHED_TIME_MAP_FUTURE.c_week,
        MORPHED_TIME_MAP_FUTURE.c_month,
        MORPHED_TIME_MAP_FUTURE.c_qtr,
        MORPHED_TIME_MAP_FUTURE.c_season,
        MORPHED_TIME_MAP_FUTURE.c_year,
        MORPHED_TIME_MAP_FUTURE.rn,
        MORPHED_TIME_MAP_FUTURE.s5_week,
        MORPHED_TIME_MAP_FUTURE.s5_month,
        MORPHED_TIME_MAP_FUTURE.s5_qtr,
        MORPHED_TIME_MAP_FUTURE.s5_season,
        MORPHED_TIME_MAP_FUTURE.s5_year
 FROM public.MORPHED_TIME_MAP_FUTURE
 ORDER BY MORPHED_TIME_MAP_FUTURE.c_week,
          MORPHED_TIME_MAP_FUTURE.c_month,
          MORPHED_TIME_MAP_FUTURE.c_qtr,
          MORPHED_TIME_MAP_FUTURE.c_season,
          MORPHED_TIME_MAP_FUTURE.c_year
SEGMENTED BY hash(MORPHED_TIME_MAP_FUTURE.rn, MORPHED_TIME_MAP_FUTURE.c_week, MORPHED_TIME_MAP_FUTURE.c_month, MORPHED_TIME_MAP_FUTURE.c_qtr, MORPHED_TIME_MAP_FUTURE.c_season, MORPHED_TIME_MAP_FUTURE.c_year, MORPHED_TIME_MAP_FUTURE.s5_week, MORPHED_TIME_MAP_FUTURE.s5_month) ALL NODES OFFSET 0;

CREATE PROJECTION public.S5_ANALYTICS_MORPHED_TIME_super /*+basename(S5_ANALYTICS_MORPHED_TIME),createtype(A)*/ 
(
 rn,
 s5_week,
 s5_month,
 s5_qtr,
 s5_season,
 s5_year
)
AS
 SELECT S5_ANALYTICS_MORPHED_TIME.rn,
        S5_ANALYTICS_MORPHED_TIME.s5_week,
        S5_ANALYTICS_MORPHED_TIME.s5_month,
        S5_ANALYTICS_MORPHED_TIME.s5_qtr,
        S5_ANALYTICS_MORPHED_TIME.s5_season,
        S5_ANALYTICS_MORPHED_TIME.s5_year
 FROM public.S5_ANALYTICS_MORPHED_TIME
 ORDER BY S5_ANALYTICS_MORPHED_TIME.rn,
          S5_ANALYTICS_MORPHED_TIME.s5_week,
          S5_ANALYTICS_MORPHED_TIME.s5_month,
          S5_ANALYTICS_MORPHED_TIME.s5_qtr,
          S5_ANALYTICS_MORPHED_TIME.s5_season,
          S5_ANALYTICS_MORPHED_TIME.s5_year
SEGMENTED BY hash(S5_ANALYTICS_MORPHED_TIME.rn, S5_ANALYTICS_MORPHED_TIME.s5_week, S5_ANALYTICS_MORPHED_TIME.s5_month, S5_ANALYTICS_MORPHED_TIME.s5_qtr, S5_ANALYTICS_MORPHED_TIME.s5_season, S5_ANALYTICS_MORPHED_TIME.s5_year) ALL NODES OFFSET 0;

CREATE PROJECTION public.MORPH_EVENT_MAPPING_super /*+basename(MORPH_EVENT_MAPPING),createtype(A)*/ 
(
 Event,
 c_week,
 c_month,
 c_windx,
 c_mindx,
 "time",
 month,
 windx,
 mindx,
 year
)
AS
 SELECT MORPH_EVENT_MAPPING.Event,
        MORPH_EVENT_MAPPING.c_week,
        MORPH_EVENT_MAPPING.c_month,
        MORPH_EVENT_MAPPING.c_windx,
        MORPH_EVENT_MAPPING.c_mindx,
        MORPH_EVENT_MAPPING."time",
        MORPH_EVENT_MAPPING.month,
        MORPH_EVENT_MAPPING.windx,
        MORPH_EVENT_MAPPING.mindx,
        MORPH_EVENT_MAPPING.year
 FROM public.MORPH_EVENT_MAPPING
 ORDER BY MORPH_EVENT_MAPPING.Event,
          MORPH_EVENT_MAPPING.c_week,
          MORPH_EVENT_MAPPING.c_month,
          MORPH_EVENT_MAPPING.c_windx,
          MORPH_EVENT_MAPPING.c_mindx
SEGMENTED BY hash(MORPH_EVENT_MAPPING.c_windx, MORPH_EVENT_MAPPING.c_mindx, MORPH_EVENT_MAPPING.Event, MORPH_EVENT_MAPPING.c_week, MORPH_EVENT_MAPPING.c_month) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_existing_20260517_super /*+basename(trd_d_product_existing_20260517),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_product_existing_20260517.id,
        trd_d_product_existing_20260517.client_id,
        trd_d_product_existing_20260517.name,
        trd_d_product_existing_20260517.description,
        trd_d_product_existing_20260517.levelid,
        trd_d_product_existing_20260517.indx,
        trd_d_product_existing_20260517.eventdate,
        trd_d_product_existing_20260517.version_id,
        trd_d_product_existing_20260517.created_at,
        trd_d_product_existing_20260517.created_by,
        trd_d_product_existing_20260517.updated_at,
        trd_d_product_existing_20260517.updated_by,
        trd_d_product_existing_20260517.record_state
 FROM public.trd_d_product_existing_20260517
 ORDER BY trd_d_product_existing_20260517.id,
          trd_d_product_existing_20260517.client_id,
          trd_d_product_existing_20260517.name,
          trd_d_product_existing_20260517.description,
          trd_d_product_existing_20260517.levelid,
          trd_d_product_existing_20260517.indx,
          trd_d_product_existing_20260517.eventdate,
          trd_d_product_existing_20260517.version_id
SEGMENTED BY hash(trd_d_product_existing_20260517.indx, trd_d_product_existing_20260517.eventdate, trd_d_product_existing_20260517.version_id, trd_d_product_existing_20260517.created_at, trd_d_product_existing_20260517.updated_at, trd_d_product_existing_20260517.record_state, trd_d_product_existing_20260517.levelid, trd_d_product_existing_20260517.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_existing_20260517_super /*+basename(trd_h_prodstd_existing_20260517),createtype(A)*/ 
(
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
AS
 SELECT trd_h_prodstd_existing_20260517.id,
        trd_h_prodstd_existing_20260517.ancestor0,
        trd_h_prodstd_existing_20260517.ancestor1,
        trd_h_prodstd_existing_20260517.ancestor2,
        trd_h_prodstd_existing_20260517.ancestor3,
        trd_h_prodstd_existing_20260517.ancestor4,
        trd_h_prodstd_existing_20260517.ancestor5,
        trd_h_prodstd_existing_20260517.ancestor6,
        trd_h_prodstd_existing_20260517.ancestor7,
        trd_h_prodstd_existing_20260517.version_id,
        trd_h_prodstd_existing_20260517.created_at,
        trd_h_prodstd_existing_20260517.created_by,
        trd_h_prodstd_existing_20260517.updated_at,
        trd_h_prodstd_existing_20260517.updated_by,
        trd_h_prodstd_existing_20260517.record_state
 FROM public.trd_h_prodstd_existing_20260517
 ORDER BY trd_h_prodstd_existing_20260517.id,
          trd_h_prodstd_existing_20260517.ancestor0,
          trd_h_prodstd_existing_20260517.ancestor1,
          trd_h_prodstd_existing_20260517.ancestor2,
          trd_h_prodstd_existing_20260517.ancestor3,
          trd_h_prodstd_existing_20260517.ancestor4,
          trd_h_prodstd_existing_20260517.ancestor5,
          trd_h_prodstd_existing_20260517.ancestor6
SEGMENTED BY hash(trd_h_prodstd_existing_20260517.version_id, trd_h_prodstd_existing_20260517.created_at, trd_h_prodstd_existing_20260517.updated_at, trd_h_prodstd_existing_20260517.record_state, trd_h_prodstd_existing_20260517.id, trd_h_prodstd_existing_20260517.ancestor0, trd_h_prodstd_existing_20260517.ancestor1, trd_h_prodstd_existing_20260517.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_sizeattributes_existing_20260517_super /*+basename(trd_ma_sizeattributes_existing_20260517),createtype(A)*/ 
(
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
AS
 SELECT trd_ma_sizeattributes_existing_20260517.product,
        trd_ma_sizeattributes_existing_20260517.parent_id,
        trd_ma_sizeattributes_existing_20260517.item_diff_2,
        trd_ma_sizeattributes_existing_20260517.item_diff_3,
        trd_ma_sizeattributes_existing_20260517.sizeattribute,
        trd_ma_sizeattributes_existing_20260517.isvalid,
        trd_ma_sizeattributes_existing_20260517.eventdate,
        trd_ma_sizeattributes_existing_20260517.version_id,
        trd_ma_sizeattributes_existing_20260517.created_at,
        trd_ma_sizeattributes_existing_20260517.created_by,
        trd_ma_sizeattributes_existing_20260517.updated_at,
        trd_ma_sizeattributes_existing_20260517.updated_by,
        trd_ma_sizeattributes_existing_20260517.record_state,
        trd_ma_sizeattributes_existing_20260517.ccctylecolorsizecreatedate
 FROM public.trd_ma_sizeattributes_existing_20260517
 ORDER BY trd_ma_sizeattributes_existing_20260517.product,
          trd_ma_sizeattributes_existing_20260517.item_diff_2,
          trd_ma_sizeattributes_existing_20260517.item_diff_3,
          trd_ma_sizeattributes_existing_20260517.sizeattribute,
          trd_ma_sizeattributes_existing_20260517.isvalid,
          trd_ma_sizeattributes_existing_20260517.eventdate,
          trd_ma_sizeattributes_existing_20260517.version_id
SEGMENTED BY hash(trd_ma_sizeattributes_existing_20260517.isvalid, trd_ma_sizeattributes_existing_20260517.eventdate, trd_ma_sizeattributes_existing_20260517.version_id, trd_ma_sizeattributes_existing_20260517.created_at, trd_ma_sizeattributes_existing_20260517.updated_at, trd_ma_sizeattributes_existing_20260517.record_state, trd_ma_sizeattributes_existing_20260517.product, trd_ma_sizeattributes_existing_20260517.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_S5_CLIENT_ID_MAPPING_20260517_super /*+basename(TRD_REF_S5_CLIENT_ID_MAPPING_20260517),createtype(A)*/ 
(
 s5_id,
 client_erp_id,
 levelid
)
AS
 SELECT TRD_REF_S5_CLIENT_ID_MAPPING_20260517.s5_id,
        TRD_REF_S5_CLIENT_ID_MAPPING_20260517.client_erp_id,
        TRD_REF_S5_CLIENT_ID_MAPPING_20260517.levelid
 FROM public.TRD_REF_S5_CLIENT_ID_MAPPING_20260517
 ORDER BY TRD_REF_S5_CLIENT_ID_MAPPING_20260517.s5_id,
          TRD_REF_S5_CLIENT_ID_MAPPING_20260517.client_erp_id,
          TRD_REF_S5_CLIENT_ID_MAPPING_20260517.levelid
SEGMENTED BY hash(TRD_REF_S5_CLIENT_ID_MAPPING_20260517.levelid, TRD_REF_S5_CLIENT_ID_MAPPING_20260517.s5_id, TRD_REF_S5_CLIENT_ID_MAPPING_20260517.client_erp_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_CC_SKU_MAPPING_20260517_super /*+basename(TRD_REF_CC_SKU_MAPPING_20260517),createtype(A)*/ 
(
 STYLECOLORSIZE,
 STYLECOLOR,
 STYLE,
 SUBCLASS,
 CLASS,
 DEPARTMENT,
 "GROUP",
 DIVISION,
 TOTAL_BRAND
)
AS
 SELECT TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLORSIZE,
        TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLOR,
        TRD_REF_CC_SKU_MAPPING_20260517.STYLE,
        TRD_REF_CC_SKU_MAPPING_20260517.SUBCLASS,
        TRD_REF_CC_SKU_MAPPING_20260517.CLASS,
        TRD_REF_CC_SKU_MAPPING_20260517.DEPARTMENT,
        TRD_REF_CC_SKU_MAPPING_20260517."GROUP",
        TRD_REF_CC_SKU_MAPPING_20260517.DIVISION,
        TRD_REF_CC_SKU_MAPPING_20260517.TOTAL_BRAND
 FROM public.TRD_REF_CC_SKU_MAPPING_20260517
 ORDER BY TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLORSIZE,
          TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLOR,
          TRD_REF_CC_SKU_MAPPING_20260517.STYLE,
          TRD_REF_CC_SKU_MAPPING_20260517.SUBCLASS,
          TRD_REF_CC_SKU_MAPPING_20260517.CLASS,
          TRD_REF_CC_SKU_MAPPING_20260517.DEPARTMENT,
          TRD_REF_CC_SKU_MAPPING_20260517."GROUP",
          TRD_REF_CC_SKU_MAPPING_20260517.DIVISION
SEGMENTED BY hash(TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLORSIZE, TRD_REF_CC_SKU_MAPPING_20260517.STYLECOLOR, TRD_REF_CC_SKU_MAPPING_20260517.STYLE, TRD_REF_CC_SKU_MAPPING_20260517.SUBCLASS, TRD_REF_CC_SKU_MAPPING_20260517.CLASS, TRD_REF_CC_SKU_MAPPING_20260517.DEPARTMENT, TRD_REF_CC_SKU_MAPPING_20260517."GROUP", TRD_REF_CC_SKU_MAPPING_20260517.DIVISION) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_existing_20260517_2_super /*+basename(trd_d_product_existing_20260517_2),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_product_existing_20260517_2.id,
        trd_d_product_existing_20260517_2.client_id,
        trd_d_product_existing_20260517_2.name,
        trd_d_product_existing_20260517_2.description,
        trd_d_product_existing_20260517_2.levelid,
        trd_d_product_existing_20260517_2.indx,
        trd_d_product_existing_20260517_2.eventdate,
        trd_d_product_existing_20260517_2.version_id,
        trd_d_product_existing_20260517_2.created_at,
        trd_d_product_existing_20260517_2.created_by,
        trd_d_product_existing_20260517_2.updated_at,
        trd_d_product_existing_20260517_2.updated_by,
        trd_d_product_existing_20260517_2.record_state
 FROM public.trd_d_product_existing_20260517_2
 ORDER BY trd_d_product_existing_20260517_2.id,
          trd_d_product_existing_20260517_2.client_id,
          trd_d_product_existing_20260517_2.name,
          trd_d_product_existing_20260517_2.description,
          trd_d_product_existing_20260517_2.levelid,
          trd_d_product_existing_20260517_2.indx,
          trd_d_product_existing_20260517_2.eventdate,
          trd_d_product_existing_20260517_2.version_id
SEGMENTED BY hash(trd_d_product_existing_20260517_2.indx, trd_d_product_existing_20260517_2.eventdate, trd_d_product_existing_20260517_2.version_id, trd_d_product_existing_20260517_2.created_at, trd_d_product_existing_20260517_2.updated_at, trd_d_product_existing_20260517_2.record_state, trd_d_product_existing_20260517_2.levelid, trd_d_product_existing_20260517_2.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_existing_20260517_2_super /*+basename(trd_h_prodstd_existing_20260517_2),createtype(A)*/ 
(
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
AS
 SELECT trd_h_prodstd_existing_20260517_2.id,
        trd_h_prodstd_existing_20260517_2.ancestor0,
        trd_h_prodstd_existing_20260517_2.ancestor1,
        trd_h_prodstd_existing_20260517_2.ancestor2,
        trd_h_prodstd_existing_20260517_2.ancestor3,
        trd_h_prodstd_existing_20260517_2.ancestor4,
        trd_h_prodstd_existing_20260517_2.ancestor5,
        trd_h_prodstd_existing_20260517_2.ancestor6,
        trd_h_prodstd_existing_20260517_2.ancestor7,
        trd_h_prodstd_existing_20260517_2.version_id,
        trd_h_prodstd_existing_20260517_2.created_at,
        trd_h_prodstd_existing_20260517_2.created_by,
        trd_h_prodstd_existing_20260517_2.updated_at,
        trd_h_prodstd_existing_20260517_2.updated_by,
        trd_h_prodstd_existing_20260517_2.record_state
 FROM public.trd_h_prodstd_existing_20260517_2
 ORDER BY trd_h_prodstd_existing_20260517_2.id,
          trd_h_prodstd_existing_20260517_2.ancestor0,
          trd_h_prodstd_existing_20260517_2.ancestor1,
          trd_h_prodstd_existing_20260517_2.ancestor2,
          trd_h_prodstd_existing_20260517_2.ancestor3,
          trd_h_prodstd_existing_20260517_2.ancestor4,
          trd_h_prodstd_existing_20260517_2.ancestor5,
          trd_h_prodstd_existing_20260517_2.ancestor6
SEGMENTED BY hash(trd_h_prodstd_existing_20260517_2.version_id, trd_h_prodstd_existing_20260517_2.created_at, trd_h_prodstd_existing_20260517_2.updated_at, trd_h_prodstd_existing_20260517_2.record_state, trd_h_prodstd_existing_20260517_2.id, trd_h_prodstd_existing_20260517_2.ancestor0, trd_h_prodstd_existing_20260517_2.ancestor1, trd_h_prodstd_existing_20260517_2.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_BK_MON.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_BK_MON_super /*+basename(TRD_IN_ACT_DEMAND_SALES_BK_MON),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_BK_MON.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_BK_MON
 ORDER BY TRD_IN_ACT_DEMAND_SALES_BK_MON.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_BK_MON.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_BK_MON.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_BK_MON.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_BK_MON.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_BK_MON.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_BK_MON_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_BK_MON),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_BK_MON.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON."TIME",
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_BK_MON.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_BK_MON
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_BK_MON.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON."TIME",
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_R, TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_U, TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOH_C, TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_BK_MON.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_BK_MON.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_BK_MON.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK_super /*+basename(TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 COMP_STATUS,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 SHIPPED_SALES_R_CSP,
 SHIPPED_SALES_R,
 SHIPPED_SALES_U,
 SHIPPED_SALES_C,
 RETURN_SALES_R,
 RETURN_SALES_U,
 RETURN_SALES_C,
 RETURN_SALES_R_CSP,
 BOPIS_SALES_R,
 BOPIS_SALES_U,
 BOPIS_SALES_C,
 SFS_SALES_R,
 SFS_SALES_U,
 SFS_SALES_C
)
AS
 SELECT TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.TRANSACTION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.MEMBER_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.DAY_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.LOCATION_ID,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.COMP_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.PRICE_STATUS,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_R_CSP,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.BOPIS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.BOPIS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.BOPIS_SALES_C,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SFS_SALES_R,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SFS_SALES_U,
        TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SFS_SALES_C
 FROM public.TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK
 ORDER BY TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.TRANSACTION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.MEMBER_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.DAY_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.LOCATION_ID,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.COMP_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.PRICE_STATUS,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.CURRENT_TICKET_PRICE
SEGMENTED BY hash(TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.CURRENT_TICKET_PRICE, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_R_CSP, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_U, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.SHIPPED_SALES_C, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_R, TRD_IN_ACT_SALES_TRANSACTIONS_ARCHIVE_BK.RETURN_SALES_U) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK_super /*+basename(TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK),createtype(A)*/ 
(
 TRANSACTION_ID,
 MEMBER_ID,
 DAY_ID,
 LOCATION_ID,
 PRICE_STATUS,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 DEMAND_SALES_R_CSP,
 DEMAND_SALES_R,
 DEMAND_SALES_U,
 DEMAND_SALES_C
)
AS
 SELECT TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.TRANSACTION_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.MEMBER_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DAY_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.LOCATION_ID,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.PRICE_STATUS,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_R_CSP,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_R,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_U,
        TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_C
 FROM public.TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK
 ORDER BY TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.TRANSACTION_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.MEMBER_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DAY_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.LOCATION_ID,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.PRICE_STATUS,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.ORIGINAL_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.CURRENT_TICKET_PRICE,
          TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_R_CSP
SEGMENTED BY hash(TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.ORIGINAL_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.CURRENT_TICKET_PRICE, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_R_CSP, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_R, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_U, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.DEMAND_SALES_C, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.TRANSACTION_ID, TRD_IN_ACT_DEMAND_SALES_ARCHIVE_BK.MEMBER_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK_super /*+basename(TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 PRICE_STATUS,
 COMP_STATUS,
 "TIME",
 EOH_R,
 EOH_U,
 EOH_C,
 EOP_INTRANSIT_R,
 EOP_INTRANSIT_U,
 EOP_INTRANSIT_C,
 AVG_UNIT_COST,
 ORIGINAL_TICKET_PRICE,
 CURRENT_TICKET_PRICE,
 PERM_MD_R,
 PERM_MD_C,
 PERM_MD_U,
 PERM_MD_R_CSP
)
AS
 SELECT TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.MEMBER_ID,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.LOCATION_ID,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PRICE_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.COMP_STATUS,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK."TIME",
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.AVG_UNIT_COST,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.ORIGINAL_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.CURRENT_TICKET_PRICE,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PERM_MD_R,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PERM_MD_C,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PERM_MD_U,
        TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PERM_MD_R_CSP
 FROM public.TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK
 ORDER BY TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.MEMBER_ID,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.LOCATION_ID,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.PRICE_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.COMP_STATUS,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK."TIME",
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_R,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_U,
          TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_C
SEGMENTED BY hash(TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_R, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_U, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOH_C, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_R, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_U, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.EOP_INTRANSIT_C, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.AVG_UNIT_COST, TRD_IN_ACT_DAILYINVENTORY_ARCHIVE_BK.ORIGINAL_TICKET_PRICE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET_super /*+basename(TRD_IN_BUS_STR_TIER_CLASS_FLOORSET),createtype(L)*/ 
(
 LOCATION_ID,
 FLOORSET_ID,
 CLASS_ID,
 TIER
)
AS
 SELECT TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.LOCATION_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.FLOORSET_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.CLASS_ID,
        TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.TIER
 FROM public.TRD_IN_BUS_STR_TIER_CLASS_FLOORSET
 ORDER BY TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.LOCATION_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.FLOORSET_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.CLASS_ID,
          TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.TIER
SEGMENTED BY hash(TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.TIER, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.LOCATION_ID, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.FLOORSET_ID, TRD_IN_BUS_STR_TIER_CLASS_FLOORSET.CLASS_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_SIZERANGE_MAPPING_super /*+basename(TRD_IN_BUS_SIZERANGE_MAPPING),createtype(L)*/ 
(
 size_range,
 size_id,
 size_desc,
 sort_order,
 parent_size,
 fringe_size_ind
)
AS
 SELECT TRD_IN_BUS_SIZERANGE_MAPPING.size_range,
        TRD_IN_BUS_SIZERANGE_MAPPING.size_id,
        TRD_IN_BUS_SIZERANGE_MAPPING.size_desc,
        TRD_IN_BUS_SIZERANGE_MAPPING.sort_order,
        TRD_IN_BUS_SIZERANGE_MAPPING.parent_size,
        TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind
 FROM public.TRD_IN_BUS_SIZERANGE_MAPPING
 ORDER BY TRD_IN_BUS_SIZERANGE_MAPPING.size_range,
          TRD_IN_BUS_SIZERANGE_MAPPING.size_id,
          TRD_IN_BUS_SIZERANGE_MAPPING.size_desc,
          TRD_IN_BUS_SIZERANGE_MAPPING.sort_order,
          TRD_IN_BUS_SIZERANGE_MAPPING.parent_size,
          TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind
SEGMENTED BY hash(TRD_IN_BUS_SIZERANGE_MAPPING.sort_order, TRD_IN_BUS_SIZERANGE_MAPPING.fringe_size_ind, TRD_IN_BUS_SIZERANGE_MAPPING.size_range, TRD_IN_BUS_SIZERANGE_MAPPING.size_id, TRD_IN_BUS_SIZERANGE_MAPPING.size_desc, TRD_IN_BUS_SIZERANGE_MAPPING.parent_size) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_SIZE_ELIGIBILITY_super /*+basename(TRD_IN_BUS_SIZE_ELIGIBILITY),createtype(L)*/ 
(
 department,
 size_range_id,
 size_eligibility_default_display_name,
 size_member_id,
 store_ineligible,
 web_ineligible,
 is_default
)
AS
 SELECT TRD_IN_BUS_SIZE_ELIGIBILITY.department,
        TRD_IN_BUS_SIZE_ELIGIBILITY.size_range_id,
        TRD_IN_BUS_SIZE_ELIGIBILITY.size_eligibility_default_display_name,
        TRD_IN_BUS_SIZE_ELIGIBILITY.size_member_id,
        TRD_IN_BUS_SIZE_ELIGIBILITY.store_ineligible,
        TRD_IN_BUS_SIZE_ELIGIBILITY.web_ineligible,
        TRD_IN_BUS_SIZE_ELIGIBILITY.is_default
 FROM public.TRD_IN_BUS_SIZE_ELIGIBILITY
 ORDER BY TRD_IN_BUS_SIZE_ELIGIBILITY.department,
          TRD_IN_BUS_SIZE_ELIGIBILITY.size_range_id,
          TRD_IN_BUS_SIZE_ELIGIBILITY.size_eligibility_default_display_name,
          TRD_IN_BUS_SIZE_ELIGIBILITY.size_member_id,
          TRD_IN_BUS_SIZE_ELIGIBILITY.store_ineligible,
          TRD_IN_BUS_SIZE_ELIGIBILITY.web_ineligible,
          TRD_IN_BUS_SIZE_ELIGIBILITY.is_default
SEGMENTED BY hash(TRD_IN_BUS_SIZE_ELIGIBILITY.store_ineligible, TRD_IN_BUS_SIZE_ELIGIBILITY.web_ineligible, TRD_IN_BUS_SIZE_ELIGIBILITY.is_default, TRD_IN_BUS_SIZE_ELIGIBILITY.department, TRD_IN_BUS_SIZE_ELIGIBILITY.size_range_id, TRD_IN_BUS_SIZE_ELIGIBILITY.size_eligibility_default_display_name, TRD_IN_BUS_SIZE_ELIGIBILITY.size_member_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_CAD_TICKET_PRICE_super /*+basename(TRD_IN_BUS_CAD_TICKET_PRICE),createtype(L)*/ 
(
 product,
 usd_ticket_price,
 cad_ticket_price,
 price_band
)
AS
 SELECT TRD_IN_BUS_CAD_TICKET_PRICE.product,
        TRD_IN_BUS_CAD_TICKET_PRICE.usd_ticket_price,
        TRD_IN_BUS_CAD_TICKET_PRICE.cad_ticket_price,
        TRD_IN_BUS_CAD_TICKET_PRICE.price_band
 FROM public.TRD_IN_BUS_CAD_TICKET_PRICE
 ORDER BY TRD_IN_BUS_CAD_TICKET_PRICE.product,
          TRD_IN_BUS_CAD_TICKET_PRICE.usd_ticket_price,
          TRD_IN_BUS_CAD_TICKET_PRICE.cad_ticket_price,
          TRD_IN_BUS_CAD_TICKET_PRICE.price_band
SEGMENTED BY hash(TRD_IN_BUS_CAD_TICKET_PRICE.usd_ticket_price, TRD_IN_BUS_CAD_TICKET_PRICE.cad_ticket_price, TRD_IN_BUS_CAD_TICKET_PRICE.product, TRD_IN_BUS_CAD_TICKET_PRICE.price_band) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_CORP_DISCOUNT_super /*+basename(TRD_IN_BUS_CORP_DISCOUNT),createtype(L)*/ 
(
 department,
 product,
 "time",
 corpaddoff,
 corpexcl_ecom,
 corpexcl_stores
)
AS
 SELECT TRD_IN_BUS_CORP_DISCOUNT.department,
        TRD_IN_BUS_CORP_DISCOUNT.product,
        TRD_IN_BUS_CORP_DISCOUNT."time",
        TRD_IN_BUS_CORP_DISCOUNT.corpaddoff,
        TRD_IN_BUS_CORP_DISCOUNT.corpexcl_ecom,
        TRD_IN_BUS_CORP_DISCOUNT.corpexcl_stores
 FROM public.TRD_IN_BUS_CORP_DISCOUNT
 ORDER BY TRD_IN_BUS_CORP_DISCOUNT.department,
          TRD_IN_BUS_CORP_DISCOUNT.product,
          TRD_IN_BUS_CORP_DISCOUNT."time",
          TRD_IN_BUS_CORP_DISCOUNT.corpaddoff,
          TRD_IN_BUS_CORP_DISCOUNT.corpexcl_ecom,
          TRD_IN_BUS_CORP_DISCOUNT.corpexcl_stores
SEGMENTED BY hash(TRD_IN_BUS_CORP_DISCOUNT.corpaddoff, TRD_IN_BUS_CORP_DISCOUNT.corpexcl_ecom, TRD_IN_BUS_CORP_DISCOUNT.corpexcl_stores, TRD_IN_BUS_CORP_DISCOUNT.department, TRD_IN_BUS_CORP_DISCOUNT.product, TRD_IN_BUS_CORP_DISCOUNT."time") ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_DEPARTMENT_DEFAULTS_super /*+basename(TRD_IN_BUS_DEPARTMENT_DEFAULTS),createtype(L)*/ 
(
 product,
 default_presmin,
 default_presmin_weeks,
 default_ccrcptint,
 default_retpct_str,
 default_retpct_ecom,
 default_crosschannel_retpct_ecom,
 default_ccordermultiple_uom,
 default_ccmdstrategy,
 default_lead_time,
 default_ccdiscountpct
)
AS
 SELECT TRD_IN_BUS_DEPARTMENT_DEFAULTS.product,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin_weeks,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccrcptint,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_str,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_ecom,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_crosschannel_retpct_ecom,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccordermultiple_uom,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccmdstrategy,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_lead_time,
        TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccdiscountpct
 FROM public.TRD_IN_BUS_DEPARTMENT_DEFAULTS
 ORDER BY TRD_IN_BUS_DEPARTMENT_DEFAULTS.product,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin_weeks,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccrcptint,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_str,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_ecom,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_crosschannel_retpct_ecom,
          TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccordermultiple_uom
SEGMENTED BY hash(TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_presmin_weeks, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccrcptint, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_str, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_retpct_ecom, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_crosschannel_retpct_ecom, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_ccordermultiple_uom, TRD_IN_BUS_DEPARTMENT_DEFAULTS.default_lead_time) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_DEFAULT_DISCOUNT_PCT_super /*+basename(TRD_IN_BUS_DEFAULT_DISCOUNT_PCT),createtype(L)*/ 
(
 DEPT_ID,
 DEFAULT_DISCOUNT
)
AS
 SELECT TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEPT_ID,
        TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEFAULT_DISCOUNT
 FROM public.TRD_IN_BUS_DEFAULT_DISCOUNT_PCT
 ORDER BY TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEPT_ID,
          TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEFAULT_DISCOUNT
SEGMENTED BY hash(TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEFAULT_DISCOUNT, TRD_IN_BUS_DEFAULT_DISCOUNT_PCT.DEPT_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_PRICE_BAND_LOOKUP_super /*+basename(TRD_IN_BUS_PRICE_BAND_LOOKUP),createtype(L)*/ 
(
 PRICE_BAND_VALUE,
 SUBCLASS,
 CEILING_VALUE
)
AS
 SELECT TRD_IN_BUS_PRICE_BAND_LOOKUP.PRICE_BAND_VALUE,
        TRD_IN_BUS_PRICE_BAND_LOOKUP.SUBCLASS,
        TRD_IN_BUS_PRICE_BAND_LOOKUP.CEILING_VALUE
 FROM public.TRD_IN_BUS_PRICE_BAND_LOOKUP
 ORDER BY TRD_IN_BUS_PRICE_BAND_LOOKUP.PRICE_BAND_VALUE,
          TRD_IN_BUS_PRICE_BAND_LOOKUP.SUBCLASS,
          TRD_IN_BUS_PRICE_BAND_LOOKUP.CEILING_VALUE
SEGMENTED BY hash(TRD_IN_BUS_PRICE_BAND_LOOKUP.PRICE_BAND_VALUE, TRD_IN_BUS_PRICE_BAND_LOOKUP.SUBCLASS, TRD_IN_BUS_PRICE_BAND_LOOKUP.CEILING_VALUE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_HOLIDAY_SHIFTS_super /*+basename(TRD_IN_BUS_HOLIDAY_SHIFTS),createtype(L)*/ 
(
 "time",
 lytime,
 llytime,
 holiday_name
)
AS
 SELECT TRD_IN_BUS_HOLIDAY_SHIFTS."time",
        TRD_IN_BUS_HOLIDAY_SHIFTS.lytime,
        TRD_IN_BUS_HOLIDAY_SHIFTS.llytime,
        TRD_IN_BUS_HOLIDAY_SHIFTS.holiday_name
 FROM public.TRD_IN_BUS_HOLIDAY_SHIFTS
 ORDER BY TRD_IN_BUS_HOLIDAY_SHIFTS."time",
          TRD_IN_BUS_HOLIDAY_SHIFTS.lytime,
          TRD_IN_BUS_HOLIDAY_SHIFTS.llytime,
          TRD_IN_BUS_HOLIDAY_SHIFTS.holiday_name
SEGMENTED BY hash(TRD_IN_BUS_HOLIDAY_SHIFTS."time", TRD_IN_BUS_HOLIDAY_SHIFTS.lytime, TRD_IN_BUS_HOLIDAY_SHIFTS.llytime, TRD_IN_BUS_HOLIDAY_SHIFTS.holiday_name) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_MD_STRATEGY_super /*+basename(TRD_IN_BUS_MD_STRATEGY),createtype(L)*/ 
(
 department,
 mdstrategy,
 seq,
 weeks,
 md
)
AS
 SELECT TRD_IN_BUS_MD_STRATEGY.department,
        TRD_IN_BUS_MD_STRATEGY.mdstrategy,
        TRD_IN_BUS_MD_STRATEGY.seq,
        TRD_IN_BUS_MD_STRATEGY.weeks,
        TRD_IN_BUS_MD_STRATEGY.md
 FROM public.TRD_IN_BUS_MD_STRATEGY
 ORDER BY TRD_IN_BUS_MD_STRATEGY.department,
          TRD_IN_BUS_MD_STRATEGY.mdstrategy,
          TRD_IN_BUS_MD_STRATEGY.seq,
          TRD_IN_BUS_MD_STRATEGY.weeks,
          TRD_IN_BUS_MD_STRATEGY.md
SEGMENTED BY hash(TRD_IN_BUS_MD_STRATEGY.seq, TRD_IN_BUS_MD_STRATEGY.weeks, TRD_IN_BUS_MD_STRATEGY.md, TRD_IN_BUS_MD_STRATEGY.department, TRD_IN_BUS_MD_STRATEGY.mdstrategy) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_BUS_SSG_super /*+basename(TRD_IN_BUS_SSG),createtype(L)*/ 
(
 SSG_ID,
 LOCATION,
 SSG_NAME,
 SSG_STORE
)
AS
 SELECT TRD_IN_BUS_SSG.SSG_ID,
        TRD_IN_BUS_SSG.LOCATION,
        TRD_IN_BUS_SSG.SSG_NAME,
        TRD_IN_BUS_SSG.SSG_STORE
 FROM public.TRD_IN_BUS_SSG
 ORDER BY TRD_IN_BUS_SSG.SSG_ID,
          TRD_IN_BUS_SSG.LOCATION,
          TRD_IN_BUS_SSG.SSG_NAME,
          TRD_IN_BUS_SSG.SSG_STORE
SEGMENTED BY hash(TRD_IN_BUS_SSG.SSG_ID, TRD_IN_BUS_SSG.LOCATION, TRD_IN_BUS_SSG.SSG_NAME, TRD_IN_BUS_SSG.SSG_STORE) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_LOC_MEMBERMASTER_super /*+basename(TRD_REF_LOC_MEMBERMASTER),createtype(A)*/ 
(
 member_id,
 loc_level
)
AS
 SELECT TRD_REF_LOC_MEMBERMASTER.member_id,
        TRD_REF_LOC_MEMBERMASTER.loc_level
 FROM public.TRD_REF_LOC_MEMBERMASTER
 ORDER BY TRD_REF_LOC_MEMBERMASTER.member_id,
          TRD_REF_LOC_MEMBERMASTER.loc_level
SEGMENTED BY hash(TRD_REF_LOC_MEMBERMASTER.member_id, TRD_REF_LOC_MEMBERMASTER.loc_level) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_location_super /*+basename(trd_d_location),createtype(A)*/ 
(
 id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_location.id,
        trd_d_location.name,
        trd_d_location.description,
        trd_d_location.levelid,
        trd_d_location.indx,
        trd_d_location.eventdate,
        trd_d_location.version_id,
        trd_d_location.created_at,
        trd_d_location.created_by,
        trd_d_location.updated_at,
        trd_d_location.updated_by,
        trd_d_location.record_state
 FROM public.trd_d_location
 ORDER BY trd_d_location.id,
          trd_d_location.name,
          trd_d_location.description,
          trd_d_location.levelid,
          trd_d_location.indx,
          trd_d_location.eventdate,
          trd_d_location.version_id,
          trd_d_location.created_at
SEGMENTED BY hash(trd_d_location.indx, trd_d_location.eventdate, trd_d_location.version_id, trd_d_location.created_at, trd_d_location.created_by, trd_d_location.updated_at, trd_d_location.updated_by, trd_d_location.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_locstd_super /*+basename(trd_h_locstd),createtype(A)*/ 
(
 id,
 ancestor0,
 ancestor1,
 ancestor2,
 ancestor3,
 ancestor4,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_locstd.id,
        trd_h_locstd.ancestor0,
        trd_h_locstd.ancestor1,
        trd_h_locstd.ancestor2,
        trd_h_locstd.ancestor3,
        trd_h_locstd.ancestor4,
        trd_h_locstd.version_id,
        trd_h_locstd.created_at,
        trd_h_locstd.created_by,
        trd_h_locstd.updated_at,
        trd_h_locstd.updated_by,
        trd_h_locstd.record_state
 FROM public.trd_h_locstd
 ORDER BY trd_h_locstd.id,
          trd_h_locstd.ancestor0,
          trd_h_locstd.ancestor1,
          trd_h_locstd.ancestor2,
          trd_h_locstd.ancestor3,
          trd_h_locstd.ancestor4
SEGMENTED BY hash(trd_h_locstd.id, trd_h_locstd.ancestor0, trd_h_locstd.ancestor1, trd_h_locstd.ancestor2, trd_h_locstd.ancestor3, trd_h_locstd.ancestor4) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_storeattributes_super /*+basename(trd_storeattributes),createtype(L)*/ 
(
 store,
 store_name,
 mall_type,
 geo_region,
 city,
 zipcode,
 corp_rank,
 dc_or_store,
 selling_channel,
 casual_3_space,
 clearance_store,
 store_banner,
 store_climate,
 capacity,
 capacity_volume,
 hazmat
)
AS
 SELECT trd_storeattributes.store,
        trd_storeattributes.store_name,
        trd_storeattributes.mall_type,
        trd_storeattributes.geo_region,
        trd_storeattributes.city,
        trd_storeattributes.zipcode,
        trd_storeattributes.corp_rank,
        trd_storeattributes.dc_or_store,
        trd_storeattributes.selling_channel,
        trd_storeattributes.casual_3_space,
        trd_storeattributes.clearance_store,
        trd_storeattributes.store_banner,
        trd_storeattributes.store_climate,
        trd_storeattributes.capacity,
        trd_storeattributes.capacity_volume,
        trd_storeattributes.hazmat
 FROM public.trd_storeattributes
 ORDER BY trd_storeattributes.store,
          trd_storeattributes.store_name,
          trd_storeattributes.mall_type,
          trd_storeattributes.geo_region,
          trd_storeattributes.city,
          trd_storeattributes.zipcode,
          trd_storeattributes.corp_rank,
          trd_storeattributes.dc_or_store
SEGMENTED BY hash(trd_storeattributes.store, trd_storeattributes.store_name, trd_storeattributes.mall_type, trd_storeattributes.geo_region, trd_storeattributes.city, trd_storeattributes.zipcode, trd_storeattributes.corp_rank, trd_storeattributes.dc_or_store) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_storeattributes_super /*+basename(trd_ma_storeattributes),createtype(A)*/ 
(
 location,
 strname,
 str_store_peer,
 str_mall_type,
 str_volume_range,
 str_active_sales,
 str_active_alloc,
 str_active_bopis,
 str_active_sfs,
 str_competition_1,
 str_competition_2,
 str_competition_3,
 str_date_opened,
 str_date_closed,
 str_date_remodeled,
 str_dc_current,
 str_dc_final,
 str_dc_transit,
 str_fxt_cashwrap_type,
 str_fxt_casual_3,
 str_fxt_panty_tables,
 str_fxt_bra_cabinets,
 str_fxt_open_1,
 str_fxt_open_2,
 str_fxt_open_3,
 str_fxt_open_4,
 str_fxt_open_5,
 str_fxt_open_6,
 str_fxt_open_7,
 str_fxt_open_8,
 str_fxt_open_9,
 str_fxt_open_10,
 str_fxt_open_11,
 str_fxt_open_12,
 str_fxt_open_13,
 str_fxt_open_14,
 str_fxt_open_15,
 str_geo_timezone,
 str_geo_region,
 str_mkt_border,
 str_mkt_coastal,
 str_mkt_urban,
 str_mkt_tourist,
 str_mkt_college_1,
 str_mkt_college_2,
 str_mkt_sports_baseball,
 str_mkt_sports_football,
 str_mkt_sports_basketball,
 str_mkt_sports_hockey,
 str_size_1_ttl_str,
 str_size_2_sls_flr,
 str_size_3_merch_flr,
 str_size_4_stk_rm,
 str_size_5_oth,
 str_size_6_offsite,
 str_real_est_proforma,
 str_real_est_rank,
 str_corp_rank,
 str_sp_vol_alpha,
 str_sp_vol_proforma,
 str_days_from_wh,
 str_dc_or_store,
 str_selling_channel,
 str_store_banner,
 str_store_climate,
 str_hazmat,
 str_capacity,
 str_capacity_volume,
 str_latitude,
 str_longitude,
 str_area_id,
 str_loc_attr_1,
 str_loc_attr_2,
 str_loc_attr_3,
 str_loc_attr_4,
 str_loc_attr_5,
 str_loc_attr_6,
 str_loc_attr_7,
 str_loc_attr_8,
 str_loc_attr_9,
 str_loc_attr_10,
 str_loc_attr_11,
 str_loc_attr_12,
 str_loc_attr_13,
 str_loc_attr_14,
 str_loc_attr_15,
 str_city,
 str_zipcode,
 str_clearance_store,
 district_name,
 district_desc,
 region_name,
 region_desc,
 area_name,
 area_desc,
 selling_channel_name,
 selling_channel_desc,
 channel_name,
 channel_desc,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 str_grade
)
AS
 SELECT trd_ma_storeattributes.location,
        trd_ma_storeattributes.strname,
        trd_ma_storeattributes.str_store_peer,
        trd_ma_storeattributes.str_mall_type,
        trd_ma_storeattributes.str_volume_range,
        trd_ma_storeattributes.str_active_sales,
        trd_ma_storeattributes.str_active_alloc,
        trd_ma_storeattributes.str_active_bopis,
        trd_ma_storeattributes.str_active_sfs,
        trd_ma_storeattributes.str_competition_1,
        trd_ma_storeattributes.str_competition_2,
        trd_ma_storeattributes.str_competition_3,
        trd_ma_storeattributes.str_date_opened,
        trd_ma_storeattributes.str_date_closed,
        trd_ma_storeattributes.str_date_remodeled,
        trd_ma_storeattributes.str_dc_current,
        trd_ma_storeattributes.str_dc_final,
        trd_ma_storeattributes.str_dc_transit,
        trd_ma_storeattributes.str_fxt_cashwrap_type,
        trd_ma_storeattributes.str_fxt_casual_3,
        trd_ma_storeattributes.str_fxt_panty_tables,
        trd_ma_storeattributes.str_fxt_bra_cabinets,
        trd_ma_storeattributes.str_fxt_open_1,
        trd_ma_storeattributes.str_fxt_open_2,
        trd_ma_storeattributes.str_fxt_open_3,
        trd_ma_storeattributes.str_fxt_open_4,
        trd_ma_storeattributes.str_fxt_open_5,
        trd_ma_storeattributes.str_fxt_open_6,
        trd_ma_storeattributes.str_fxt_open_7,
        trd_ma_storeattributes.str_fxt_open_8,
        trd_ma_storeattributes.str_fxt_open_9,
        trd_ma_storeattributes.str_fxt_open_10,
        trd_ma_storeattributes.str_fxt_open_11,
        trd_ma_storeattributes.str_fxt_open_12,
        trd_ma_storeattributes.str_fxt_open_13,
        trd_ma_storeattributes.str_fxt_open_14,
        trd_ma_storeattributes.str_fxt_open_15,
        trd_ma_storeattributes.str_geo_timezone,
        trd_ma_storeattributes.str_geo_region,
        trd_ma_storeattributes.str_mkt_border,
        trd_ma_storeattributes.str_mkt_coastal,
        trd_ma_storeattributes.str_mkt_urban,
        trd_ma_storeattributes.str_mkt_tourist,
        trd_ma_storeattributes.str_mkt_college_1,
        trd_ma_storeattributes.str_mkt_college_2,
        trd_ma_storeattributes.str_mkt_sports_baseball,
        trd_ma_storeattributes.str_mkt_sports_football,
        trd_ma_storeattributes.str_mkt_sports_basketball,
        trd_ma_storeattributes.str_mkt_sports_hockey,
        trd_ma_storeattributes.str_size_1_ttl_str,
        trd_ma_storeattributes.str_size_2_sls_flr,
        trd_ma_storeattributes.str_size_3_merch_flr,
        trd_ma_storeattributes.str_size_4_stk_rm,
        trd_ma_storeattributes.str_size_5_oth,
        trd_ma_storeattributes.str_size_6_offsite,
        trd_ma_storeattributes.str_real_est_proforma,
        trd_ma_storeattributes.str_real_est_rank,
        trd_ma_storeattributes.str_corp_rank,
        trd_ma_storeattributes.str_sp_vol_alpha,
        trd_ma_storeattributes.str_sp_vol_proforma,
        trd_ma_storeattributes.str_days_from_wh,
        trd_ma_storeattributes.str_dc_or_store,
        trd_ma_storeattributes.str_selling_channel,
        trd_ma_storeattributes.str_store_banner,
        trd_ma_storeattributes.str_store_climate,
        trd_ma_storeattributes.str_hazmat,
        trd_ma_storeattributes.str_capacity,
        trd_ma_storeattributes.str_capacity_volume,
        trd_ma_storeattributes.str_latitude,
        trd_ma_storeattributes.str_longitude,
        trd_ma_storeattributes.str_area_id,
        trd_ma_storeattributes.str_loc_attr_1,
        trd_ma_storeattributes.str_loc_attr_2,
        trd_ma_storeattributes.str_loc_attr_3,
        trd_ma_storeattributes.str_loc_attr_4,
        trd_ma_storeattributes.str_loc_attr_5,
        trd_ma_storeattributes.str_loc_attr_6,
        trd_ma_storeattributes.str_loc_attr_7,
        trd_ma_storeattributes.str_loc_attr_8,
        trd_ma_storeattributes.str_loc_attr_9,
        trd_ma_storeattributes.str_loc_attr_10,
        trd_ma_storeattributes.str_loc_attr_11,
        trd_ma_storeattributes.str_loc_attr_12,
        trd_ma_storeattributes.str_loc_attr_13,
        trd_ma_storeattributes.str_loc_attr_14,
        trd_ma_storeattributes.str_loc_attr_15,
        trd_ma_storeattributes.str_city,
        trd_ma_storeattributes.str_zipcode,
        trd_ma_storeattributes.str_clearance_store,
        trd_ma_storeattributes.district_name,
        trd_ma_storeattributes.district_desc,
        trd_ma_storeattributes.region_name,
        trd_ma_storeattributes.region_desc,
        trd_ma_storeattributes.area_name,
        trd_ma_storeattributes.area_desc,
        trd_ma_storeattributes.selling_channel_name,
        trd_ma_storeattributes.selling_channel_desc,
        trd_ma_storeattributes.channel_name,
        trd_ma_storeattributes.channel_desc,
        trd_ma_storeattributes.eventdate,
        trd_ma_storeattributes.version_id,
        trd_ma_storeattributes.created_at,
        trd_ma_storeattributes.created_by,
        trd_ma_storeattributes.updated_at,
        trd_ma_storeattributes.updated_by,
        trd_ma_storeattributes.record_state,
        trd_ma_storeattributes.str_grade
 FROM public.trd_ma_storeattributes
 ORDER BY trd_ma_storeattributes.location,
          trd_ma_storeattributes.strname,
          trd_ma_storeattributes.str_store_peer,
          trd_ma_storeattributes.str_mall_type,
          trd_ma_storeattributes.str_volume_range,
          trd_ma_storeattributes.str_active_sales,
          trd_ma_storeattributes.str_active_alloc,
          trd_ma_storeattributes.str_active_bopis
SEGMENTED BY hash(trd_ma_storeattributes.eventdate, trd_ma_storeattributes.version_id, trd_ma_storeattributes.created_at, trd_ma_storeattributes.created_by, trd_ma_storeattributes.updated_at, trd_ma_storeattributes.updated_by, trd_ma_storeattributes.record_state, trd_ma_storeattributes.location) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_dclookup_super /*+basename(trd_l_dclookup),createtype(L)*/ 
(
 channel,
 dc,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_l_dclookup.channel,
        trd_l_dclookup.dc,
        trd_l_dclookup.eventdate,
        trd_l_dclookup.version_id,
        trd_l_dclookup.created_at,
        trd_l_dclookup.created_by,
        trd_l_dclookup.updated_at,
        trd_l_dclookup.updated_by,
        trd_l_dclookup.record_state
 FROM public.trd_l_dclookup
 ORDER BY trd_l_dclookup.channel,
          trd_l_dclookup.dc,
          trd_l_dclookup.eventdate,
          trd_l_dclookup.version_id,
          trd_l_dclookup.created_at,
          trd_l_dclookup.created_by,
          trd_l_dclookup.updated_at,
          trd_l_dclookup.updated_by
SEGMENTED BY hash(trd_l_dclookup.eventdate, trd_l_dclookup.version_id, trd_l_dclookup.created_at, trd_l_dclookup.updated_at, trd_l_dclookup.record_state, trd_l_dclookup.created_by, trd_l_dclookup.updated_by, trd_l_dclookup.channel) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_stocking_locations_tbl_super /*+basename(trd_stocking_locations_tbl),createtype(A)*/ 
(
 stocking_location,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_stocking_locations_tbl.stocking_location,
        trd_stocking_locations_tbl.eventdate,
        trd_stocking_locations_tbl.version_id,
        trd_stocking_locations_tbl.created_at,
        trd_stocking_locations_tbl.created_by,
        trd_stocking_locations_tbl.updated_at,
        trd_stocking_locations_tbl.updated_by,
        trd_stocking_locations_tbl.record_state
 FROM public.trd_stocking_locations_tbl
 ORDER BY trd_stocking_locations_tbl.stocking_location
SEGMENTED BY hash(trd_stocking_locations_tbl.eventdate, trd_stocking_locations_tbl.version_id, trd_stocking_locations_tbl.created_at, trd_stocking_locations_tbl.created_by, trd_stocking_locations_tbl.updated_at, trd_stocking_locations_tbl.updated_by, trd_stocking_locations_tbl.record_state, trd_stocking_locations_tbl.stocking_location) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_time_super /*+basename(trd_d_time),createtype(L)*/ 
(
 id,
 name,
 description,
 levelid,
 prev,
 next,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_time.id,
        trd_d_time.name,
        trd_d_time.description,
        trd_d_time.levelid,
        trd_d_time.prev,
        trd_d_time.next,
        trd_d_time.indx,
        trd_d_time.eventdate,
        trd_d_time.version_id,
        trd_d_time.created_at,
        trd_d_time.created_by,
        trd_d_time.updated_at,
        trd_d_time.updated_by,
        trd_d_time.record_state
 FROM public.trd_d_time
 ORDER BY trd_d_time.id,
          trd_d_time.name,
          trd_d_time.description,
          trd_d_time.levelid,
          trd_d_time.prev,
          trd_d_time.next,
          trd_d_time.indx,
          trd_d_time.eventdate
SEGMENTED BY hash(trd_d_time.indx, trd_d_time.eventdate, trd_d_time.version_id, trd_d_time.created_at, trd_d_time.updated_at, trd_d_time.record_state, trd_d_time.created_by, trd_d_time.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_timestd_super /*+basename(trd_h_timestd),createtype(L)*/ 
(
 id,
 ancestor0,
 ancestor1,
 ancestor2,
 ancestor3,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_timestd.id,
        trd_h_timestd.ancestor0,
        trd_h_timestd.ancestor1,
        trd_h_timestd.ancestor2,
        trd_h_timestd.ancestor3,
        trd_h_timestd.eventdate,
        trd_h_timestd.version_id,
        trd_h_timestd.created_at,
        trd_h_timestd.created_by,
        trd_h_timestd.updated_at,
        trd_h_timestd.updated_by,
        trd_h_timestd.record_state
 FROM public.trd_h_timestd
 ORDER BY trd_h_timestd.id,
          trd_h_timestd.ancestor0,
          trd_h_timestd.ancestor1,
          trd_h_timestd.ancestor2,
          trd_h_timestd.ancestor3,
          trd_h_timestd.eventdate,
          trd_h_timestd.version_id,
          trd_h_timestd.created_at
SEGMENTED BY hash(trd_h_timestd.eventdate, trd_h_timestd.version_id, trd_h_timestd.created_at, trd_h_timestd.updated_at, trd_h_timestd.record_state, trd_h_timestd.created_by, trd_h_timestd.updated_by, trd_h_timestd.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_timeflrset_super /*+basename(trd_h_timeflrset),createtype(L)*/ 
(
 id,
 ancestor0,
 ancestor1,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_timeflrset.id,
        trd_h_timeflrset.ancestor0,
        trd_h_timeflrset.ancestor1,
        trd_h_timeflrset.eventdate,
        trd_h_timeflrset.version_id,
        trd_h_timeflrset.created_at,
        trd_h_timeflrset.created_by,
        trd_h_timeflrset.updated_at,
        trd_h_timeflrset.updated_by,
        trd_h_timeflrset.record_state
 FROM public.trd_h_timeflrset
 ORDER BY trd_h_timeflrset.id,
          trd_h_timeflrset.ancestor0,
          trd_h_timeflrset.ancestor1,
          trd_h_timeflrset.eventdate,
          trd_h_timeflrset.version_id,
          trd_h_timeflrset.created_at,
          trd_h_timeflrset.created_by,
          trd_h_timeflrset.updated_at
SEGMENTED BY hash(trd_h_timeflrset.eventdate, trd_h_timeflrset.version_id, trd_h_timeflrset.created_at, trd_h_timeflrset.updated_at, trd_h_timeflrset.record_state, trd_h_timeflrset.created_by, trd_h_timeflrset.updated_by, trd_h_timeflrset.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_weekattributes_super /*+basename(trd_ma_weekattributes),createtype(L)*/ 
(
 "TIME",
 START_DATE,
 END_DATE,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_ma_weekattributes."TIME",
        trd_ma_weekattributes.START_DATE,
        trd_ma_weekattributes.END_DATE,
        trd_ma_weekattributes.eventdate,
        trd_ma_weekattributes.version_id,
        trd_ma_weekattributes.created_at,
        trd_ma_weekattributes.created_by,
        trd_ma_weekattributes.updated_at,
        trd_ma_weekattributes.updated_by,
        trd_ma_weekattributes.record_state
 FROM public.trd_ma_weekattributes
 ORDER BY trd_ma_weekattributes."TIME"
SEGMENTED BY hash(trd_ma_weekattributes.eventdate, trd_ma_weekattributes.version_id, trd_ma_weekattributes.created_at, trd_ma_weekattributes.updated_at, trd_ma_weekattributes.record_state, trd_ma_weekattributes.created_by, trd_ma_weekattributes.updated_by, trd_ma_weekattributes."TIME") ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_IN_TYLY_MAPPING_super /*+basename(TRD_IN_TYLY_MAPPING),createtype(L)*/ 
(
 "time",
 cctytime
)
AS
 SELECT TRD_IN_TYLY_MAPPING."time",
        TRD_IN_TYLY_MAPPING.cctytime
 FROM public.TRD_IN_TYLY_MAPPING
 ORDER BY TRD_IN_TYLY_MAPPING."time",
          TRD_IN_TYLY_MAPPING.cctytime
SEGMENTED BY hash(TRD_IN_TYLY_MAPPING."time", TRD_IN_TYLY_MAPPING.cctytime) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_dptflrsetattributes_super /*+basename(trd_ma_dptflrsetattributes),createtype(L)*/ 
(
 indx,
 product,
 "time",
 floorset_name,
 dept_name,
 superset_id,
 superset_name,
 initialrcptwk,
 rcptstart,
 rcptend,
 slsstart,
 slsend,
 weeks_at_fp,
 markdown_week,
 exit_week,
 ly_rcptstart,
 ly_rcptend,
 lyslsstart,
 lyslsend,
 ap_start,
 ap_end,
 planned_sell_down_week,
 floorset_uda,
 ly_floorset_uda,
 default_slsrnk_store,
 default_slsrnk_ecom,
 default_store_vol_grade,
 default_store_climate,
 default_store_capacity,
 default_store_banner,
 default_store_geo_region,
 default_store_hazmat,
 irw_debut_offset,
 default_presmin,
 default_presmin_weeks,
 default_ccrcptint,
 default_retpct_str,
 default_retpct_ecom,
 default_crosschannel_retpct_ecom,
 default_ccordermultiple_uom,
 default_ccmdstrategy,
 default_lead_time,
 default_ccdiscountpct,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 prepack_pct_default,
 override_fringe_indicator
)
AS
 SELECT trd_ma_dptflrsetattributes.indx,
        trd_ma_dptflrsetattributes.product,
        trd_ma_dptflrsetattributes."time",
        trd_ma_dptflrsetattributes.floorset_name,
        trd_ma_dptflrsetattributes.dept_name,
        trd_ma_dptflrsetattributes.superset_id,
        trd_ma_dptflrsetattributes.superset_name,
        trd_ma_dptflrsetattributes.initialrcptwk,
        trd_ma_dptflrsetattributes.rcptstart,
        trd_ma_dptflrsetattributes.rcptend,
        trd_ma_dptflrsetattributes.slsstart,
        trd_ma_dptflrsetattributes.slsend,
        trd_ma_dptflrsetattributes.weeks_at_fp,
        trd_ma_dptflrsetattributes.markdown_week,
        trd_ma_dptflrsetattributes.exit_week,
        trd_ma_dptflrsetattributes.ly_rcptstart,
        trd_ma_dptflrsetattributes.ly_rcptend,
        trd_ma_dptflrsetattributes.lyslsstart,
        trd_ma_dptflrsetattributes.lyslsend,
        trd_ma_dptflrsetattributes.ap_start,
        trd_ma_dptflrsetattributes.ap_end,
        trd_ma_dptflrsetattributes.planned_sell_down_week,
        trd_ma_dptflrsetattributes.floorset_uda,
        trd_ma_dptflrsetattributes.ly_floorset_uda,
        trd_ma_dptflrsetattributes.default_slsrnk_store,
        trd_ma_dptflrsetattributes.default_slsrnk_ecom,
        trd_ma_dptflrsetattributes.default_store_vol_grade,
        trd_ma_dptflrsetattributes.default_store_climate,
        trd_ma_dptflrsetattributes.default_store_capacity,
        trd_ma_dptflrsetattributes.default_store_banner,
        trd_ma_dptflrsetattributes.default_store_geo_region,
        trd_ma_dptflrsetattributes.default_store_hazmat,
        trd_ma_dptflrsetattributes.irw_debut_offset,
        trd_ma_dptflrsetattributes.default_presmin,
        trd_ma_dptflrsetattributes.default_presmin_weeks,
        trd_ma_dptflrsetattributes.default_ccrcptint,
        trd_ma_dptflrsetattributes.default_retpct_str,
        trd_ma_dptflrsetattributes.default_retpct_ecom,
        trd_ma_dptflrsetattributes.default_crosschannel_retpct_ecom,
        trd_ma_dptflrsetattributes.default_ccordermultiple_uom,
        trd_ma_dptflrsetattributes.default_ccmdstrategy,
        trd_ma_dptflrsetattributes.default_lead_time,
        trd_ma_dptflrsetattributes.default_ccdiscountpct,
        trd_ma_dptflrsetattributes.eventdate,
        trd_ma_dptflrsetattributes.version_id,
        trd_ma_dptflrsetattributes.created_at,
        trd_ma_dptflrsetattributes.created_by,
        trd_ma_dptflrsetattributes.updated_at,
        trd_ma_dptflrsetattributes.updated_by,
        trd_ma_dptflrsetattributes.record_state,
        trd_ma_dptflrsetattributes.prepack_pct_default,
        trd_ma_dptflrsetattributes.override_fringe_indicator
 FROM public.trd_ma_dptflrsetattributes
 ORDER BY trd_ma_dptflrsetattributes.indx,
          trd_ma_dptflrsetattributes.product,
          trd_ma_dptflrsetattributes."time",
          trd_ma_dptflrsetattributes.floorset_name,
          trd_ma_dptflrsetattributes.dept_name,
          trd_ma_dptflrsetattributes.superset_id,
          trd_ma_dptflrsetattributes.superset_name,
          trd_ma_dptflrsetattributes.initialrcptwk
SEGMENTED BY hash(trd_ma_dptflrsetattributes.indx, trd_ma_dptflrsetattributes.default_slsrnk_store, trd_ma_dptflrsetattributes.default_slsrnk_ecom, trd_ma_dptflrsetattributes.irw_debut_offset, trd_ma_dptflrsetattributes.default_presmin, trd_ma_dptflrsetattributes.default_presmin_weeks, trd_ma_dptflrsetattributes.default_ccrcptint, trd_ma_dptflrsetattributes.default_retpct_str) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_time_attributes_tbl_super /*+basename(trd_time_attributes_tbl),createtype(A)*/ 
(
 week,
 month,
 quarter,
 season,
 year,
 cctytime,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_time_attributes_tbl.week,
        trd_time_attributes_tbl.month,
        trd_time_attributes_tbl.quarter,
        trd_time_attributes_tbl.season,
        trd_time_attributes_tbl.year,
        trd_time_attributes_tbl.cctytime,
        trd_time_attributes_tbl.eventdate,
        trd_time_attributes_tbl.version_id,
        trd_time_attributes_tbl.created_at,
        trd_time_attributes_tbl.created_by,
        trd_time_attributes_tbl.updated_at,
        trd_time_attributes_tbl.updated_by,
        trd_time_attributes_tbl.record_state
 FROM public.trd_time_attributes_tbl
 ORDER BY trd_time_attributes_tbl.week,
          trd_time_attributes_tbl.month,
          trd_time_attributes_tbl.quarter,
          trd_time_attributes_tbl.season,
          trd_time_attributes_tbl.year,
          trd_time_attributes_tbl.cctytime
SEGMENTED BY hash(trd_time_attributes_tbl.eventdate, trd_time_attributes_tbl.version_id, trd_time_attributes_tbl.created_at, trd_time_attributes_tbl.created_by, trd_time_attributes_tbl.updated_at, trd_time_attributes_tbl.updated_by, trd_time_attributes_tbl.record_state, trd_time_attributes_tbl.cctytime) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_floorset_week_attributes_tbl_super /*+basename(trd_floorset_week_attributes_tbl),createtype(A)*/ 
(
 floorset,
 month,
 week,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_floorset_week_attributes_tbl.floorset,
        trd_floorset_week_attributes_tbl.month,
        trd_floorset_week_attributes_tbl.week,
        trd_floorset_week_attributes_tbl.eventdate,
        trd_floorset_week_attributes_tbl.version_id,
        trd_floorset_week_attributes_tbl.created_at,
        trd_floorset_week_attributes_tbl.created_by,
        trd_floorset_week_attributes_tbl.updated_at,
        trd_floorset_week_attributes_tbl.updated_by,
        trd_floorset_week_attributes_tbl.record_state
 FROM public.trd_floorset_week_attributes_tbl
 ORDER BY trd_floorset_week_attributes_tbl.floorset,
          trd_floorset_week_attributes_tbl.month,
          trd_floorset_week_attributes_tbl.week
SEGMENTED BY hash(trd_floorset_week_attributes_tbl.eventdate, trd_floorset_week_attributes_tbl.version_id, trd_floorset_week_attributes_tbl.created_at, trd_floorset_week_attributes_tbl.created_by, trd_floorset_week_attributes_tbl.updated_at, trd_floorset_week_attributes_tbl.updated_by, trd_floorset_week_attributes_tbl.record_state, trd_floorset_week_attributes_tbl.month) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_TIME_BOH_EOH_super /*+basename(TRD_REF_TIME_BOH_EOH),createtype(A)*/ 
(
 WEEK_ID,
 DATE_ID,
 PREV_WEEK_ID,
 PREV_WEEK_LAST_DAY,
 BOH_MULTIPLE,
 EOH_MULTIPLE
)
AS
 SELECT TRD_REF_TIME_BOH_EOH.WEEK_ID,
        TRD_REF_TIME_BOH_EOH.DATE_ID,
        TRD_REF_TIME_BOH_EOH.PREV_WEEK_ID,
        TRD_REF_TIME_BOH_EOH.PREV_WEEK_LAST_DAY,
        TRD_REF_TIME_BOH_EOH.BOH_MULTIPLE,
        TRD_REF_TIME_BOH_EOH.EOH_MULTIPLE
 FROM public.TRD_REF_TIME_BOH_EOH
 ORDER BY TRD_REF_TIME_BOH_EOH.WEEK_ID,
          TRD_REF_TIME_BOH_EOH.DATE_ID,
          TRD_REF_TIME_BOH_EOH.PREV_WEEK_ID,
          TRD_REF_TIME_BOH_EOH.PREV_WEEK_LAST_DAY,
          TRD_REF_TIME_BOH_EOH.BOH_MULTIPLE,
          TRD_REF_TIME_BOH_EOH.EOH_MULTIPLE
SEGMENTED BY hash(TRD_REF_TIME_BOH_EOH.BOH_MULTIPLE, TRD_REF_TIME_BOH_EOH.EOH_MULTIPLE, TRD_REF_TIME_BOH_EOH.PREV_WEEK_ID, TRD_REF_TIME_BOH_EOH.WEEK_ID, TRD_REF_TIME_BOH_EOH.DATE_ID, TRD_REF_TIME_BOH_EOH.PREV_WEEK_LAST_DAY) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_prodlife_super /*+basename(trd_d_prodlife),createtype(A)*/ 
(
 id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_prodlife.id,
        trd_d_prodlife.name,
        trd_d_prodlife.description,
        trd_d_prodlife.levelid,
        trd_d_prodlife.indx,
        trd_d_prodlife.eventdate,
        trd_d_prodlife.version_id,
        trd_d_prodlife.created_at,
        trd_d_prodlife.created_by,
        trd_d_prodlife.updated_at,
        trd_d_prodlife.updated_by,
        trd_d_prodlife.record_state
 FROM public.trd_d_prodlife
 ORDER BY trd_d_prodlife.id,
          trd_d_prodlife.name,
          trd_d_prodlife.description,
          trd_d_prodlife.levelid
SEGMENTED BY hash(trd_d_prodlife.indx, trd_d_prodlife.eventdate, trd_d_prodlife.version_id, trd_d_prodlife.created_at, trd_d_prodlife.created_by, trd_d_prodlife.updated_at, trd_d_prodlife.updated_by, trd_d_prodlife.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodlifestd_super /*+basename(trd_h_prodlifestd),createtype(A)*/ 
(
 id,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_prodlifestd.id,
        trd_h_prodlifestd.eventdate,
        trd_h_prodlifestd.version_id,
        trd_h_prodlifestd.created_at,
        trd_h_prodlifestd.created_by,
        trd_h_prodlifestd.updated_at,
        trd_h_prodlifestd.updated_by,
        trd_h_prodlifestd.record_state
 FROM public.trd_h_prodlifestd
 ORDER BY trd_h_prodlifestd.id
SEGMENTED BY hash(trd_h_prodlifestd.eventdate, trd_h_prodlifestd.version_id, trd_h_prodlifestd.created_at, trd_h_prodlifestd.created_by, trd_h_prodlifestd.updated_at, trd_h_prodlifestd.updated_by, trd_h_prodlifestd.record_state, trd_h_prodlifestd.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_prodlife_view_tbl_super /*+basename(trd_prodlife_view_tbl),createtype(A)*/ 
(
 merchcat,
 prodlife,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_prodlife_view_tbl.merchcat,
        trd_prodlife_view_tbl.prodlife,
        trd_prodlife_view_tbl.eventdate,
        trd_prodlife_view_tbl.version_id,
        trd_prodlife_view_tbl.created_at,
        trd_prodlife_view_tbl.created_by,
        trd_prodlife_view_tbl.updated_at,
        trd_prodlife_view_tbl.updated_by,
        trd_prodlife_view_tbl.record_state
 FROM public.trd_prodlife_view_tbl
 ORDER BY trd_prodlife_view_tbl.merchcat
SEGMENTED BY hash(trd_prodlife_view_tbl.eventdate, trd_prodlife_view_tbl.version_id, trd_prodlife_view_tbl.created_at, trd_prodlife_view_tbl.created_by, trd_prodlife_view_tbl.updated_at, trd_prodlife_view_tbl.updated_by, trd_prodlife_view_tbl.record_state, trd_prodlife_view_tbl.merchcat) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_cluster_super /*+basename(trd_d_cluster),createtype(A)*/ 
(
 id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_cluster.id,
        trd_d_cluster.name,
        trd_d_cluster.description,
        trd_d_cluster.levelid,
        trd_d_cluster.indx,
        trd_d_cluster.eventdate,
        trd_d_cluster.version_id,
        trd_d_cluster.created_at,
        trd_d_cluster.created_by,
        trd_d_cluster.updated_at,
        trd_d_cluster.updated_by,
        trd_d_cluster.record_state
 FROM public.trd_d_cluster
 ORDER BY trd_d_cluster.id,
          trd_d_cluster.name,
          trd_d_cluster.description,
          trd_d_cluster.levelid
SEGMENTED BY hash(trd_d_cluster.indx, trd_d_cluster.eventdate, trd_d_cluster.version_id, trd_d_cluster.created_at, trd_d_cluster.created_by, trd_d_cluster.updated_at, trd_d_cluster.updated_by, trd_d_cluster.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_clusterstd_super /*+basename(trd_h_clusterstd),createtype(A)*/ 
(
 id,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_clusterstd.id,
        trd_h_clusterstd.eventdate,
        trd_h_clusterstd.version_id,
        trd_h_clusterstd.created_at,
        trd_h_clusterstd.created_by,
        trd_h_clusterstd.updated_at,
        trd_h_clusterstd.updated_by,
        trd_h_clusterstd.record_state
 FROM public.trd_h_clusterstd
 ORDER BY trd_h_clusterstd.id
SEGMENTED BY hash(trd_h_clusterstd.eventdate, trd_h_clusterstd.version_id, trd_h_clusterstd.created_at, trd_h_clusterstd.created_by, trd_h_clusterstd.updated_at, trd_h_clusterstd.updated_by, trd_h_clusterstd.record_state, trd_h_clusterstd.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_cluster_view_tbl_super /*+basename(trd_cluster_view_tbl),createtype(A)*/ 
(
 grade,
 cluster,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_cluster_view_tbl.grade,
        trd_cluster_view_tbl.cluster,
        trd_cluster_view_tbl.eventdate,
        trd_cluster_view_tbl.version_id,
        trd_cluster_view_tbl.created_at,
        trd_cluster_view_tbl.created_by,
        trd_cluster_view_tbl.updated_at,
        trd_cluster_view_tbl.updated_by,
        trd_cluster_view_tbl.record_state
 FROM public.trd_cluster_view_tbl
 ORDER BY trd_cluster_view_tbl.grade
SEGMENTED BY hash(trd_cluster_view_tbl.eventdate, trd_cluster_view_tbl.version_id, trd_cluster_view_tbl.created_at, trd_cluster_view_tbl.created_by, trd_cluster_view_tbl.updated_at, trd_cluster_view_tbl.updated_by, trd_cluster_view_tbl.record_state, trd_cluster_view_tbl.grade) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_int_store_tier_dept_week_super /*+basename(trd_int_store_tier_dept_week),createtype(A)*/ 
(
 location_id,
 class_id,
 week,
 cluster
)
AS
 SELECT trd_int_store_tier_dept_week.location_id,
        trd_int_store_tier_dept_week.class_id,
        trd_int_store_tier_dept_week.week,
        trd_int_store_tier_dept_week.cluster
 FROM public.trd_int_store_tier_dept_week
 ORDER BY trd_int_store_tier_dept_week.location_id,
          trd_int_store_tier_dept_week.class_id,
          trd_int_store_tier_dept_week.week,
          trd_int_store_tier_dept_week.cluster
SEGMENTED BY hash(trd_int_store_tier_dept_week.week, trd_int_store_tier_dept_week.cluster, trd_int_store_tier_dept_week.location_id, trd_int_store_tier_dept_week.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ref_store_tier_class_max_week_super /*+basename(trd_ref_store_tier_class_max_week),createtype(A)*/ 
(
 class_id,
 location_id,
 max_week,
 min_week
)
AS
 SELECT trd_ref_store_tier_class_max_week.class_id,
        trd_ref_store_tier_class_max_week.location_id,
        trd_ref_store_tier_class_max_week.max_week,
        trd_ref_store_tier_class_max_week.min_week
 FROM public.trd_ref_store_tier_class_max_week
 ORDER BY trd_ref_store_tier_class_max_week.location_id,
          trd_ref_store_tier_class_max_week.class_id
SEGMENTED BY hash(trd_ref_store_tier_class_max_week.max_week, trd_ref_store_tier_class_max_week.min_week, trd_ref_store_tier_class_max_week.class_id, trd_ref_store_tier_class_max_week.location_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ref_store_tier_possible_tier_weeks_super /*+basename(trd_ref_store_tier_possible_tier_weeks),createtype(A)*/ 
(
 location_id,
 class_id,
 week
)
AS
 SELECT trd_ref_store_tier_possible_tier_weeks.location_id,
        trd_ref_store_tier_possible_tier_weeks.class_id,
        trd_ref_store_tier_possible_tier_weeks.week
 FROM public.trd_ref_store_tier_possible_tier_weeks
 ORDER BY trd_ref_store_tier_possible_tier_weeks.location_id,
          trd_ref_store_tier_possible_tier_weeks.class_id,
          trd_ref_store_tier_possible_tier_weeks.week
SEGMENTED BY hash(trd_ref_store_tier_possible_tier_weeks.week, trd_ref_store_tier_possible_tier_weeks.location_id, trd_ref_store_tier_possible_tier_weeks.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_trd_int_store_tier_dept_week_super /*+basename(temp_trd_int_store_tier_dept_week),createtype(A)*/ 
(
 location_id,
 class_id,
 week,
 cluster
)
AS
 SELECT temp_trd_int_store_tier_dept_week.location_id,
        temp_trd_int_store_tier_dept_week.class_id,
        temp_trd_int_store_tier_dept_week.week,
        temp_trd_int_store_tier_dept_week.cluster
 FROM public.temp_trd_int_store_tier_dept_week
 ORDER BY temp_trd_int_store_tier_dept_week.location_id,
          temp_trd_int_store_tier_dept_week.class_id,
          temp_trd_int_store_tier_dept_week.week,
          temp_trd_int_store_tier_dept_week.cluster
SEGMENTED BY hash(temp_trd_int_store_tier_dept_week.week, temp_trd_int_store_tier_dept_week.cluster, temp_trd_int_store_tier_dept_week.location_id, temp_trd_int_store_tier_dept_week.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_trd_int_store_tier_dept_week_2_super /*+basename(temp_trd_int_store_tier_dept_week_2),createtype(A)*/ 
(
 location_id,
 class_id,
 week,
 cluster
)
AS
 SELECT temp_trd_int_store_tier_dept_week_2.location_id,
        temp_trd_int_store_tier_dept_week_2.class_id,
        temp_trd_int_store_tier_dept_week_2.week,
        temp_trd_int_store_tier_dept_week_2.cluster
 FROM public.temp_trd_int_store_tier_dept_week_2
 ORDER BY temp_trd_int_store_tier_dept_week_2.location_id,
          temp_trd_int_store_tier_dept_week_2.class_id,
          temp_trd_int_store_tier_dept_week_2.week,
          temp_trd_int_store_tier_dept_week_2.cluster
SEGMENTED BY hash(temp_trd_int_store_tier_dept_week_2.week, temp_trd_int_store_tier_dept_week_2.cluster, temp_trd_int_store_tier_dept_week_2.location_id, temp_trd_int_store_tier_dept_week_2.class_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_INTERN_ACTWEEK_super /*+basename(TRD_PERF_INTERN_ACTWEEK),createtype(A)*/ 
(
 WEEK_ID
)
AS
 SELECT TRD_PERF_INTERN_ACTWEEK.WEEK_ID
 FROM public.TRD_PERF_INTERN_ACTWEEK
 ORDER BY TRD_PERF_INTERN_ACTWEEK.WEEK_ID
SEGMENTED BY hash(TRD_PERF_INTERN_ACTWEEK.WEEK_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_serviceparams_super /*+basename(trd_serviceparams),createtype(A)*/ 
(
 id,
 type,
 value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_serviceparams.id,
        trd_serviceparams.type,
        trd_serviceparams.value,
        trd_serviceparams.eventdate,
        trd_serviceparams.version_id,
        trd_serviceparams.created_at,
        trd_serviceparams.created_by,
        trd_serviceparams.updated_at,
        trd_serviceparams.updated_by,
        trd_serviceparams.record_state
 FROM public.trd_serviceparams
 ORDER BY trd_serviceparams.id,
          trd_serviceparams.type,
          trd_serviceparams.value
SEGMENTED BY hash(trd_serviceparams.id, trd_serviceparams.type, trd_serviceparams.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ytd_qtd_mtd_mapping_tbl_super /*+basename(trd_ytd_qtd_mtd_mapping_tbl),createtype(A)*/ 
(
 week,
 month,
 qtr,
 season,
 year,
 ytd,
 std,
 qtd,
 mtd,
 lw,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_ytd_qtd_mtd_mapping_tbl.week,
        trd_ytd_qtd_mtd_mapping_tbl.month,
        trd_ytd_qtd_mtd_mapping_tbl.qtr,
        trd_ytd_qtd_mtd_mapping_tbl.season,
        trd_ytd_qtd_mtd_mapping_tbl.year,
        trd_ytd_qtd_mtd_mapping_tbl.ytd,
        trd_ytd_qtd_mtd_mapping_tbl.std,
        trd_ytd_qtd_mtd_mapping_tbl.qtd,
        trd_ytd_qtd_mtd_mapping_tbl.mtd,
        trd_ytd_qtd_mtd_mapping_tbl.lw,
        trd_ytd_qtd_mtd_mapping_tbl.eventdate,
        trd_ytd_qtd_mtd_mapping_tbl.version_id,
        trd_ytd_qtd_mtd_mapping_tbl.created_at,
        trd_ytd_qtd_mtd_mapping_tbl.created_by,
        trd_ytd_qtd_mtd_mapping_tbl.updated_at,
        trd_ytd_qtd_mtd_mapping_tbl.updated_by,
        trd_ytd_qtd_mtd_mapping_tbl.record_state
 FROM public.trd_ytd_qtd_mtd_mapping_tbl
 ORDER BY trd_ytd_qtd_mtd_mapping_tbl.week,
          trd_ytd_qtd_mtd_mapping_tbl.month,
          trd_ytd_qtd_mtd_mapping_tbl.qtr,
          trd_ytd_qtd_mtd_mapping_tbl.season,
          trd_ytd_qtd_mtd_mapping_tbl.year
SEGMENTED BY hash(trd_ytd_qtd_mtd_mapping_tbl.ytd, trd_ytd_qtd_mtd_mapping_tbl.std, trd_ytd_qtd_mtd_mapping_tbl.qtd, trd_ytd_qtd_mtd_mapping_tbl.mtd, trd_ytd_qtd_mtd_mapping_tbl.lw, trd_ytd_qtd_mtd_mapping_tbl.eventdate, trd_ytd_qtd_mtd_mapping_tbl.version_id, trd_ytd_qtd_mtd_mapping_tbl.created_at) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_existing_super /*+basename(trd_d_product_existing),createtype(L)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_product_existing.id,
        trd_d_product_existing.client_id,
        trd_d_product_existing.name,
        trd_d_product_existing.description,
        trd_d_product_existing.levelid,
        trd_d_product_existing.indx,
        trd_d_product_existing.eventdate,
        trd_d_product_existing.version_id,
        trd_d_product_existing.created_at,
        trd_d_product_existing.created_by,
        trd_d_product_existing.updated_at,
        trd_d_product_existing.updated_by,
        trd_d_product_existing.record_state
 FROM public.trd_d_product_existing
 ORDER BY trd_d_product_existing.id,
          trd_d_product_existing.client_id,
          trd_d_product_existing.name,
          trd_d_product_existing.description,
          trd_d_product_existing.levelid,
          trd_d_product_existing.indx,
          trd_d_product_existing.eventdate,
          trd_d_product_existing.version_id
SEGMENTED BY hash(trd_d_product_existing.indx, trd_d_product_existing.eventdate, trd_d_product_existing.version_id, trd_d_product_existing.created_at, trd_d_product_existing.updated_at, trd_d_product_existing.record_state, trd_d_product_existing.levelid, trd_d_product_existing.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_existing_super /*+basename(trd_h_prodstd_existing),createtype(L)*/ 
(
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
AS
 SELECT trd_h_prodstd_existing.id,
        trd_h_prodstd_existing.ancestor0,
        trd_h_prodstd_existing.ancestor1,
        trd_h_prodstd_existing.ancestor2,
        trd_h_prodstd_existing.ancestor3,
        trd_h_prodstd_existing.ancestor4,
        trd_h_prodstd_existing.ancestor5,
        trd_h_prodstd_existing.ancestor6,
        trd_h_prodstd_existing.ancestor7,
        trd_h_prodstd_existing.version_id,
        trd_h_prodstd_existing.created_at,
        trd_h_prodstd_existing.created_by,
        trd_h_prodstd_existing.updated_at,
        trd_h_prodstd_existing.updated_by,
        trd_h_prodstd_existing.record_state
 FROM public.trd_h_prodstd_existing
 ORDER BY trd_h_prodstd_existing.id,
          trd_h_prodstd_existing.ancestor0,
          trd_h_prodstd_existing.ancestor1,
          trd_h_prodstd_existing.ancestor2,
          trd_h_prodstd_existing.ancestor3,
          trd_h_prodstd_existing.ancestor4,
          trd_h_prodstd_existing.ancestor5,
          trd_h_prodstd_existing.ancestor6
SEGMENTED BY hash(trd_h_prodstd_existing.version_id, trd_h_prodstd_existing.created_at, trd_h_prodstd_existing.updated_at, trd_h_prodstd_existing.record_state, trd_h_prodstd_existing.id, trd_h_prodstd_existing.ancestor0, trd_h_prodstd_existing.ancestor1, trd_h_prodstd_existing.ancestor2) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_sizeattributes_existing_super /*+basename(trd_ma_sizeattributes_existing),createtype(L)*/ 
(
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
AS
 SELECT trd_ma_sizeattributes_existing.product,
        trd_ma_sizeattributes_existing.parent_id,
        trd_ma_sizeattributes_existing.item_diff_2,
        trd_ma_sizeattributes_existing.item_diff_3,
        trd_ma_sizeattributes_existing.sizeattribute,
        trd_ma_sizeattributes_existing.isvalid,
        trd_ma_sizeattributes_existing.eventdate,
        trd_ma_sizeattributes_existing.version_id,
        trd_ma_sizeattributes_existing.created_at,
        trd_ma_sizeattributes_existing.created_by,
        trd_ma_sizeattributes_existing.updated_at,
        trd_ma_sizeattributes_existing.updated_by,
        trd_ma_sizeattributes_existing.record_state,
        trd_ma_sizeattributes_existing.ccctylecolorsizecreatedate
 FROM public.trd_ma_sizeattributes_existing
 ORDER BY trd_ma_sizeattributes_existing.product,
          trd_ma_sizeattributes_existing.parent_id,
          trd_ma_sizeattributes_existing.item_diff_2,
          trd_ma_sizeattributes_existing.item_diff_3,
          trd_ma_sizeattributes_existing.sizeattribute,
          trd_ma_sizeattributes_existing.isvalid,
          trd_ma_sizeattributes_existing.eventdate,
          trd_ma_sizeattributes_existing.version_id
SEGMENTED BY hash(trd_ma_sizeattributes_existing.isvalid, trd_ma_sizeattributes_existing.eventdate, trd_ma_sizeattributes_existing.version_id, trd_ma_sizeattributes_existing.created_at, trd_ma_sizeattributes_existing.updated_at, trd_ma_sizeattributes_existing.record_state, trd_ma_sizeattributes_existing.product, trd_ma_sizeattributes_existing.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_styleattributes_existing_super /*+basename(trd_ma_styleattributes_existing),createtype(L)*/ 
(
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
 sty_vpn_desc,
 sty_num_clones_s5,
 sty_num_times_cloned_s5
)
AS
 SELECT trd_ma_styleattributes_existing.product,
        trd_ma_styleattributes_existing.sty_knit_or_woven,
        trd_ma_styleattributes_existing.sty_fabrication,
        trd_ma_styleattributes_existing.sty_sleeve_length,
        trd_ma_styleattributes_existing.sty_leg_opening,
        trd_ma_styleattributes_existing.sty_brand,
        trd_ma_styleattributes_existing.sty_body_style_silhouette,
        trd_ma_styleattributes_existing.sty_occasion_usage,
        trd_ma_styleattributes_existing.sty_detail,
        trd_ma_styleattributes_existing.sty_finish_style,
        trd_ma_styleattributes_existing.sty_private_label,
        trd_ma_styleattributes_existing.sty_license,
        trd_ma_styleattributes_existing.sty_license_vs_non_licensed,
        trd_ma_styleattributes_existing.sty_hazmat_code,
        trd_ma_styleattributes_existing.sty_prop_65_warning,
        trd_ma_styleattributes_existing.sty_material_content,
        trd_ma_styleattributes_existing.sty_item_type,
        trd_ma_styleattributes_existing.sty_dwrise,
        trd_ma_styleattributes_existing.sty_length,
        trd_ma_styleattributes_existing.sty_neckline,
        trd_ma_styleattributes_existing.sty_toeshape,
        trd_ma_styleattributes_existing.sty_heel_height,
        trd_ma_styleattributes_existing.sty_bottom_length,
        trd_ma_styleattributes_existing.sty_v_360_smoothing,
        trd_ma_styleattributes_existing.sty_franchise,
        trd_ma_styleattributes_existing.sty_key_item,
        trd_ma_styleattributes_existing.sty_single_vs_multi_pack,
        trd_ma_styleattributes_existing.sty_ticket_type,
        trd_ma_styleattributes_existing.sty_vpn,
        trd_ma_styleattributes_existing.sty_size_range,
        trd_ma_styleattributes_existing.ccstylecreatedate,
        trd_ma_styleattributes_existing.sty_is_locked,
        trd_ma_styleattributes_existing.sty_s5_adopted,
        trd_ma_styleattributes_existing.eventdate,
        trd_ma_styleattributes_existing.version_id,
        trd_ma_styleattributes_existing.created_at,
        trd_ma_styleattributes_existing.created_by,
        trd_ma_styleattributes_existing.updated_at,
        trd_ma_styleattributes_existing.updated_by,
        trd_ma_styleattributes_existing.record_state,
        trd_ma_styleattributes_existing.plm_size_range,
        trd_ma_styleattributes_existing.sty_knit_fit,
        trd_ma_styleattributes_existing.sty_patterned_after,
        trd_ma_styleattributes_existing.sty_vpn_desc,
        trd_ma_styleattributes_existing.sty_num_clones_s5,
        trd_ma_styleattributes_existing.sty_num_times_cloned_s5
 FROM public.trd_ma_styleattributes_existing
 ORDER BY trd_ma_styleattributes_existing.product,
          trd_ma_styleattributes_existing.sty_knit_or_woven,
          trd_ma_styleattributes_existing.sty_fabrication,
          trd_ma_styleattributes_existing.sty_sleeve_length,
          trd_ma_styleattributes_existing.sty_leg_opening,
          trd_ma_styleattributes_existing.sty_brand,
          trd_ma_styleattributes_existing.sty_body_style_silhouette,
          trd_ma_styleattributes_existing.sty_occasion_usage
SEGMENTED BY hash(trd_ma_styleattributes_existing.eventdate, trd_ma_styleattributes_existing.version_id, trd_ma_styleattributes_existing.created_at, trd_ma_styleattributes_existing.updated_at, trd_ma_styleattributes_existing.record_state, trd_ma_styleattributes_existing.sty_num_clones_s5, trd_ma_styleattributes_existing.sty_num_times_cloned_s5, trd_ma_styleattributes_existing.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_stylecolorattributes_existing_super /*+basename(trd_ma_stylecolorattributes_existing),createtype(L)*/ 
(
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
 stylecolor_name,
 style_name,
 buyer_email,
 cc_buyer,
 cc_patterned_after_name,
 vpn_color_desc,
 cc_num_clones_s5,
 cc_num_times_cloned_s5,
 cc_spec_division,
 cc_spec_group,
 cc_development_season,
 cc_delivery_season,
 cc_po_due_date,
 cc_pd_ndc_week,
 cc_additional_tariff,
 cc_design_notes,
 cc_pd_notes,
 cc_compliance_notes,
 cc_orig_unit_retail_char
)
AS
 SELECT trd_ma_stylecolorattributes_existing.product,
        trd_ma_stylecolorattributes_existing.cc_item_diff_1,
        trd_ma_stylecolorattributes_existing.cc_unit_retail,
        trd_ma_stylecolorattributes_existing.cc_unit_retail_cad,
        trd_ma_stylecolorattributes_existing.cc_pattern,
        trd_ma_stylecolorattributes_existing.cc_graphic,
        trd_ma_stylecolorattributes_existing.cc_fashion_basic,
        trd_ma_stylecolorattributes_existing.cc_holiday,
        trd_ma_stylecolorattributes_existing.cc_property_type,
        trd_ma_stylecolorattributes_existing.cc_internet_exclusive,
        trd_ma_stylecolorattributes_existing.cc_web_color_discription,
        trd_ma_stylecolorattributes_existing.cc_export_hts,
        trd_ma_stylecolorattributes_existing.cc_commercial_invoice_description,
        trd_ma_stylecolorattributes_existing.cc_season_code,
        trd_ma_stylecolorattributes_existing.cc_dtr,
        trd_ma_stylecolorattributes_existing.cc_dw_color_family,
        trd_ma_stylecolorattributes_existing.cc_channel_reorder,
        trd_ma_stylecolorattributes_existing.cc_ticket_season_code,
        trd_ma_stylecolorattributes_existing.cc_sub_programs,
        trd_ma_stylecolorattributes_existing.cc_music_genre,
        trd_ma_stylecolorattributes_existing.cc_clearance_str_product,
        trd_ma_stylecolorattributes_existing.cc_po_supplier,
        trd_ma_stylecolorattributes_existing.cc_origin_country_id,
        trd_ma_stylecolorattributes_existing.cc_country_of_sourcing,
        trd_ma_stylecolorattributes_existing.cc_country_of_manufacturing,
        trd_ma_stylecolorattributes_existing.cc_unit_cost,
        trd_ma_stylecolorattributes_existing.cc_freight,
        trd_ma_stylecolorattributes_existing.cc_royalty,
        trd_ma_stylecolorattributes_existing.cc_duty,
        trd_ma_stylecolorattributes_existing.cc_ship_method,
        trd_ma_stylecolorattributes_existing.cc_lading_port,
        trd_ma_stylecolorattributes_existing.cc_hts,
        trd_ma_stylecolorattributes_existing.cc_primary_supplier,
        trd_ma_stylecolorattributes_existing.cc_sub_brand,
        trd_ma_stylecolorattributes_existing.cc_pattern_type,
        trd_ma_stylecolorattributes_existing.cc_pop_print_neutral,
        trd_ma_stylecolorattributes_existing.cc_debut_season_code,
        trd_ma_stylecolorattributes_existing.cc_matchback,
        trd_ma_stylecolorattributes_existing.cc_primary_collection,
        trd_ma_stylecolorattributes_existing.cc_secondary_collection,
        trd_ma_stylecolorattributes_existing.cc_vpn_color,
        trd_ma_stylecolorattributes_existing.cc_orig_unit_retail,
        trd_ma_stylecolorattributes_existing.cc_orig_unit_retail_cad,
        trd_ma_stylecolorattributes_existing.cc_first_rec_week,
        trd_ma_stylecolorattributes_existing.cc_first_inv_week,
        trd_ma_stylecolorattributes_existing.cc_first_sale_week,
        trd_ma_stylecolorattributes_existing.cc_first_md_week,
        trd_ma_stylecolorattributes_existing.cc_last_md_week,
        trd_ma_stylecolorattributes_existing.cc_last_rec_week,
        trd_ma_stylecolorattributes_existing.cc_store_price_status,
        trd_ma_stylecolorattributes_existing.cc_ifc_price_status,
        trd_ma_stylecolorattributes_existing.cc_omni_price_type,
        trd_ma_stylecolorattributes_existing.ccstylecolorcreatedate,
        trd_ma_stylecolorattributes_existing.cc_price_band,
        trd_ma_stylecolorattributes_existing.cc_good_better_best,
        trd_ma_stylecolorattributes_existing.cccolor,
        trd_ma_stylecolorattributes_existing.cccolorfamily,
        trd_ma_stylecolorattributes_existing.total_brand_name,
        trd_ma_stylecolorattributes_existing.division_name,
        trd_ma_stylecolorattributes_existing.group_name,
        trd_ma_stylecolorattributes_existing.department_name,
        trd_ma_stylecolorattributes_existing.class_name,
        trd_ma_stylecolorattributes_existing.subclass_name,
        trd_ma_stylecolorattributes_existing.eventdate,
        trd_ma_stylecolorattributes_existing.version_id,
        trd_ma_stylecolorattributes_existing.created_at,
        trd_ma_stylecolorattributes_existing.created_by,
        trd_ma_stylecolorattributes_existing.updated_at,
        trd_ma_stylecolorattributes_existing.updated_by,
        trd_ma_stylecolorattributes_existing.record_state,
        trd_ma_stylecolorattributes_existing.isassortment,
        trd_ma_stylecolorattributes_existing.merch_comments,
        trd_ma_stylecolorattributes_existing.plan_comments,
        trd_ma_stylecolorattributes_existing.cc_is_locked,
        trd_ma_stylecolorattributes_existing.cc_s5_adopted,
        trd_ma_stylecolorattributes_existing.cc_prepublish,
        trd_ma_stylecolorattributes_existing.cc_prepublished_at,
        trd_ma_stylecolorattributes_existing.allocator_comments,
        trd_ma_stylecolorattributes_existing.cccolorid,
        trd_ma_stylecolorattributes_existing.cc_specstylecolor_status,
        trd_ma_stylecolorattributes_existing.cc_agent_fee,
        trd_ma_stylecolorattributes_existing.cc_port,
        trd_ma_stylecolorattributes_existing.cc_factory,
        trd_ma_stylecolorattributes_existing.cc_floorset,
        trd_ma_stylecolorattributes_existing.cc_use_sys_floorset,
        trd_ma_stylecolorattributes_existing.cc_supp_cost,
        trd_ma_stylecolorattributes_existing.cc_finish,
        trd_ma_stylecolorattributes_existing.cc_license,
        trd_ma_stylecolorattributes_existing.cc_channel_availability,
        trd_ma_stylecolorattributes_existing.cc_extended_size,
        trd_ma_stylecolorattributes_existing.cc_op_markdown_week,
        trd_ma_stylecolorattributes_existing.cc_motif,
        trd_ma_stylecolorattributes_existing.cc_rp_revised_markdown_week,
        trd_ma_stylecolorattributes_existing.cc_web_current_retail,
        trd_ma_stylecolorattributes_existing.cc_parent_season_code,
        trd_ma_stylecolorattributes_existing.cc_art_code,
        trd_ma_stylecolorattributes_existing.cc_patterned_after,
        trd_ma_stylecolorattributes_existing.cc_material_content,
        trd_ma_stylecolorattributes_existing.cc_fabrication,
        trd_ma_stylecolorattributes_existing.stylecolor_name,
        trd_ma_stylecolorattributes_existing.style_name,
        trd_ma_stylecolorattributes_existing.buyer_email,
        trd_ma_stylecolorattributes_existing.cc_buyer,
        trd_ma_stylecolorattributes_existing.cc_patterned_after_name,
        trd_ma_stylecolorattributes_existing.vpn_color_desc,
        trd_ma_stylecolorattributes_existing.cc_num_clones_s5,
        trd_ma_stylecolorattributes_existing.cc_num_times_cloned_s5,
        trd_ma_stylecolorattributes_existing.cc_spec_division,
        trd_ma_stylecolorattributes_existing.cc_spec_group,
        trd_ma_stylecolorattributes_existing.cc_development_season,
        trd_ma_stylecolorattributes_existing.cc_delivery_season,
        trd_ma_stylecolorattributes_existing.cc_po_due_date,
        trd_ma_stylecolorattributes_existing.cc_pd_ndc_week,
        trd_ma_stylecolorattributes_existing.cc_additional_tariff,
        trd_ma_stylecolorattributes_existing.cc_design_notes,
        trd_ma_stylecolorattributes_existing.cc_pd_notes,
        trd_ma_stylecolorattributes_existing.cc_compliance_notes,
        trd_ma_stylecolorattributes_existing.cc_orig_unit_retail_char
 FROM public.trd_ma_stylecolorattributes_existing
 ORDER BY trd_ma_stylecolorattributes_existing.product,
          trd_ma_stylecolorattributes_existing.cc_item_diff_1,
          trd_ma_stylecolorattributes_existing.cc_unit_retail,
          trd_ma_stylecolorattributes_existing.cc_unit_retail_cad,
          trd_ma_stylecolorattributes_existing.cc_pattern,
          trd_ma_stylecolorattributes_existing.cc_graphic,
          trd_ma_stylecolorattributes_existing.cc_fashion_basic,
          trd_ma_stylecolorattributes_existing.cc_holiday
SEGMENTED BY hash(trd_ma_stylecolorattributes_existing.cc_unit_retail, trd_ma_stylecolorattributes_existing.cc_unit_retail_cad, trd_ma_stylecolorattributes_existing.cc_unit_cost, trd_ma_stylecolorattributes_existing.cc_orig_unit_retail, trd_ma_stylecolorattributes_existing.cc_orig_unit_retail_cad, trd_ma_stylecolorattributes_existing.eventdate, trd_ma_stylecolorattributes_existing.version_id, trd_ma_stylecolorattributes_existing.created_at) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_existing_super /*+basename(trd_p_dc_adj_existing),createtype(L)*/ 
(
 product,
 location,
 "time",
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
AS
 SELECT trd_p_dc_adj_existing.product,
        trd_p_dc_adj_existing.location,
        trd_p_dc_adj_existing."time",
        trd_p_dc_adj_existing.dc_publish,
        trd_p_dc_adj_existing.is_locked,
        trd_p_dc_adj_existing.dc_uservrp,
        trd_p_dc_adj_existing.dc_lockedqty,
        trd_p_dc_adj_existing.dc_useradj,
        trd_p_dc_adj_existing.dc_onorder,
        trd_p_dc_adj_existing.dc_finrev,
        trd_p_dc_adj_existing.dc_validwk,
        trd_p_dc_adj_existing.dc_finalqty,
        trd_p_dc_adj_existing.dc_adjcost,
        trd_p_dc_adj_existing.const_y_n,
        trd_p_dc_adj_existing.sbkt,
        trd_p_dc_adj_existing.dc_isedited,
        trd_p_dc_adj_existing.dc_syscost,
        trd_p_dc_adj_existing.dc_lndcst,
        trd_p_dc_adj_existing.dc_sysvrp,
        trd_p_dc_adj_existing.dc_sc_useradj,
        trd_p_dc_adj_existing.dc_sc_finrev,
        trd_p_dc_adj_existing.po_indicator,
        trd_p_dc_adj_existing.po_shipmode,
        trd_p_dc_adj_existing.air_trigger,
        trd_p_dc_adj_existing.cut,
        trd_p_dc_adj_existing.published_at,
        trd_p_dc_adj_existing.is_prepublished,
        trd_p_dc_adj_existing.prepublished_at,
        trd_p_dc_adj_existing.last_prepublished,
        trd_p_dc_adj_existing.po_arr,
        trd_p_dc_adj_existing.eventdate,
        trd_p_dc_adj_existing.version_id,
        trd_p_dc_adj_existing.created_at,
        trd_p_dc_adj_existing.created_by,
        trd_p_dc_adj_existing.updated_at,
        trd_p_dc_adj_existing.updated_by,
        trd_p_dc_adj_existing.record_state,
        trd_p_dc_adj_existing.dc_useradj_ecom,
        trd_p_dc_adj_existing.dc_onorder_ecom,
        trd_p_dc_adj_existing.dc_finrev_ecom,
        trd_p_dc_adj_existing.dc_publish_ecom,
        trd_p_dc_adj_existing.po_indicator_ecom,
        trd_p_dc_adj_existing.po_shipmode_ecom,
        trd_p_dc_adj_existing.air_trigger_ecom,
        trd_p_dc_adj_existing.cut_ecom,
        trd_p_dc_adj_existing.published_at_ecom,
        trd_p_dc_adj_existing.is_prepublished_ecom,
        trd_p_dc_adj_existing.prepublished_at_ecom,
        trd_p_dc_adj_existing.last_prepublished_ecom,
        trd_p_dc_adj_existing.reason_code,
        trd_p_dc_adj_existing.reason_code_ecom,
        trd_p_dc_adj_existing.pack_ind_flag,
        trd_p_dc_adj_existing.pack_ind_flag_ecom,
        trd_p_dc_adj_existing.show_in_pack,
        trd_p_dc_adj_existing.show_in_pack_ecom,
        trd_p_dc_adj_existing.prepack_pct,
        trd_p_dc_adj_existing.prepack_pct_ecom,
        trd_p_dc_adj_existing.default_fringe_indicator,
        trd_p_dc_adj_existing.default_fringe_indicator_ecom,
        trd_p_dc_adj_existing.email_to
 FROM public.trd_p_dc_adj_existing
 ORDER BY trd_p_dc_adj_existing.product,
          trd_p_dc_adj_existing.location,
          trd_p_dc_adj_existing."time",
          trd_p_dc_adj_existing.dc_publish,
          trd_p_dc_adj_existing.is_locked,
          trd_p_dc_adj_existing.dc_uservrp,
          trd_p_dc_adj_existing.dc_lockedqty,
          trd_p_dc_adj_existing.dc_useradj
SEGMENTED BY hash(trd_p_dc_adj_existing.dc_publish, trd_p_dc_adj_existing.is_locked, trd_p_dc_adj_existing.dc_uservrp, trd_p_dc_adj_existing.dc_lockedqty, trd_p_dc_adj_existing.dc_useradj, trd_p_dc_adj_existing.dc_onorder, trd_p_dc_adj_existing.dc_finrev, trd_p_dc_adj_existing.dc_validwk) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_size_existing_super /*+basename(trd_p_dc_adj_size_existing),createtype(L)*/ 
(
 product,
 location,
 "time",
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
AS
 SELECT trd_p_dc_adj_size_existing.product,
        trd_p_dc_adj_size_existing.location,
        trd_p_dc_adj_size_existing."time",
        trd_p_dc_adj_size_existing.dc_publish,
        trd_p_dc_adj_size_existing.is_locked,
        trd_p_dc_adj_size_existing.dc_uservrp,
        trd_p_dc_adj_size_existing.dc_lockedqty,
        trd_p_dc_adj_size_existing.dc_useradj,
        trd_p_dc_adj_size_existing.dc_onorder,
        trd_p_dc_adj_size_existing.dc_finrev,
        trd_p_dc_adj_size_existing.dc_validwk,
        trd_p_dc_adj_size_existing.dc_finalqty,
        trd_p_dc_adj_size_existing.dc_adjcost,
        trd_p_dc_adj_size_existing.const_y_n,
        trd_p_dc_adj_size_existing.sbkt,
        trd_p_dc_adj_size_existing.dc_scadj,
        trd_p_dc_adj_size_existing.dc_ttluseradj,
        trd_p_dc_adj_size_existing.dc_scfinrev,
        trd_p_dc_adj_size_existing.dc_ttlfinrev,
        trd_p_dc_adj_size_existing.dc_isedited,
        trd_p_dc_adj_size_existing.dc_onorder_v,
        trd_p_dc_adj_size_existing.dc_onorder_c,
        trd_p_dc_adj_size_existing.current_week,
        trd_p_dc_adj_size_existing.dc_last_pub_u,
        trd_p_dc_adj_size_existing.dc_last_pub,
        trd_p_dc_adj_size_existing.eventdate,
        trd_p_dc_adj_size_existing.version_id,
        trd_p_dc_adj_size_existing.created_at,
        trd_p_dc_adj_size_existing.created_by,
        trd_p_dc_adj_size_existing.updated_at,
        trd_p_dc_adj_size_existing.updated_by,
        trd_p_dc_adj_size_existing.record_state,
        trd_p_dc_adj_size_existing.dc_useradj_ecom,
        trd_p_dc_adj_size_existing.dc_onorder_ecom,
        trd_p_dc_adj_size_existing.dc_onorder_v_ecom,
        trd_p_dc_adj_size_existing.dc_onorder_c_ecom,
        trd_p_dc_adj_size_existing.dc_finrev_ecom,
        trd_p_dc_adj_size_existing.dc_publish_ecom,
        trd_p_dc_adj_size_existing.dc_last_pub_u_ecom,
        trd_p_dc_adj_size_existing.dc_last_pub_ecom
 FROM public.trd_p_dc_adj_size_existing
 ORDER BY trd_p_dc_adj_size_existing.product,
          trd_p_dc_adj_size_existing.location,
          trd_p_dc_adj_size_existing."time",
          trd_p_dc_adj_size_existing.dc_publish,
          trd_p_dc_adj_size_existing.is_locked,
          trd_p_dc_adj_size_existing.dc_uservrp,
          trd_p_dc_adj_size_existing.dc_lockedqty,
          trd_p_dc_adj_size_existing.dc_useradj
SEGMENTED BY hash(trd_p_dc_adj_size_existing.dc_publish, trd_p_dc_adj_size_existing.is_locked, trd_p_dc_adj_size_existing.dc_uservrp, trd_p_dc_adj_size_existing.dc_lockedqty, trd_p_dc_adj_size_existing.dc_useradj, trd_p_dc_adj_size_existing.dc_onorder, trd_p_dc_adj_size_existing.dc_finrev, trd_p_dc_adj_size_existing.dc_validwk) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_stylecolorchannelattributes_existing_super /*+basename(trd_ma_stylecolorchannelattributes_existing),createtype(L)*/ 
(
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
AS
 SELECT trd_ma_stylecolorchannelattributes_existing.product,
        trd_ma_stylecolorchannelattributes_existing.location,
        trd_ma_stylecolorchannelattributes_existing.dbt_wk,
        trd_ma_stylecolorchannelattributes_existing.relaunchweek,
        trd_ma_stylecolorchannelattributes_existing.erlstmkdnwk,
        trd_ma_stylecolorchannelattributes_existing.exitdate,
        trd_ma_stylecolorchannelattributes_existing.initrcptwk,
        trd_ma_stylecolorchannelattributes_existing.too,
        trd_ma_stylecolorchannelattributes_existing.mkdnwks,
        trd_ma_stylecolorchannelattributes_existing.last_inv_wk,
        trd_ma_stylecolorchannelattributes_existing.lstfpwk,
        trd_ma_stylecolorchannelattributes_existing.last_rcpt_wk,
        trd_ma_stylecolorchannelattributes_existing.lastdcorder,
        trd_ma_stylecolorchannelattributes_existing.act_initrcptwk,
        trd_ma_stylecolorchannelattributes_existing.act_dbt_wk,
        trd_ma_stylecolorchannelattributes_existing.irw_indx,
        trd_ma_stylecolorchannelattributes_existing.dbtwk_indx,
        trd_ma_stylecolorchannelattributes_existing.relaunchwk_indx,
        trd_ma_stylecolorchannelattributes_existing.mdstart_indx,
        trd_ma_stylecolorchannelattributes_existing.lastdcorder_indx,
        trd_ma_stylecolorchannelattributes_existing.exitdate_indx,
        trd_ma_stylecolorchannelattributes_existing.preview_wks,
        trd_ma_stylecolorchannelattributes_existing.preview_qty,
        trd_ma_stylecolorchannelattributes_existing.plannedselldnwk,
        trd_ma_stylecolorchannelattributes_existing.ccmdstrategy,
        trd_ma_stylecolorchannelattributes_existing.slsrnk_store,
        trd_ma_stylecolorchannelattributes_existing.slsrnk_ecom,
        trd_ma_stylecolorchannelattributes_existing.validsizes,
        trd_ma_stylecolorchannelattributes_existing.cc_validsizes_store,
        trd_ma_stylecolorchannelattributes_existing.cc_validsizes_ecom,
        trd_ma_stylecolorchannelattributes_existing.ccrangecode,
        trd_ma_stylecolorchannelattributes_existing.cc_presmin,
        trd_ma_stylecolorchannelattributes_existing.cc_presmin_weeks,
        trd_ma_stylecolorchannelattributes_existing.cc_rcptint,
        trd_ma_stylecolorchannelattributes_existing.cc_return_u_pct_store,
        trd_ma_stylecolorchannelattributes_existing.cc_return_u_pct_ecom,
        trd_ma_stylecolorchannelattributes_existing.cc_return_u_pct_cross,
        trd_ma_stylecolorchannelattributes_existing.cc_ordermultiple,
        trd_ma_stylecolorchannelattributes_existing.cc_ordermin,
        trd_ma_stylecolorchannelattributes_existing.cc_buy_aps_letter,
        trd_ma_stylecolorchannelattributes_existing.ccticketpricechannel,
        trd_ma_stylecolorchannelattributes_existing.ccticketpricechannel_override,
        trd_ma_stylecolorchannelattributes_existing.cc_imupct,
        trd_ma_stylecolorchannelattributes_existing.cc_discount_pct,
        trd_ma_stylecolorchannelattributes_existing.cc_existingwac,
        trd_ma_stylecolorchannelattributes_existing.cc_systemcost,
        trd_ma_stylecolorchannelattributes_existing.cc_plan_cost,
        trd_ma_stylecolorchannelattributes_existing.ssnprf,
        trd_ma_stylecolorchannelattributes_existing.adjaps_store,
        trd_ma_stylecolorchannelattributes_existing.adjaps_ecom,
        trd_ma_stylecolorchannelattributes_existing.smoothing_strategy,
        trd_ma_stylecolorchannelattributes_existing.in_season_flag,
        trd_ma_stylecolorchannelattributes_existing.auto_rollforward,
        trd_ma_stylecolorchannelattributes_existing.irr_mode,
        trd_ma_stylecolorchannelattributes_existing.plan_current,
        trd_ma_stylecolorchannelattributes_existing.lock_agg_edit,
        trd_ma_stylecolorchannelattributes_existing.cc_lead_time,
        trd_ma_stylecolorchannelattributes_existing.cc_service_level,
        trd_ma_stylecolorchannelattributes_existing.eventdate,
        trd_ma_stylecolorchannelattributes_existing.version_id,
        trd_ma_stylecolorchannelattributes_existing.created_at,
        trd_ma_stylecolorchannelattributes_existing.created_by,
        trd_ma_stylecolorchannelattributes_existing.updated_at,
        trd_ma_stylecolorchannelattributes_existing.updated_by,
        trd_ma_stylecolorchannelattributes_existing.record_state,
        trd_ma_stylecolorchannelattributes_existing.cc_store_min_multiple,
        trd_ma_stylecolorchannelattributes_existing.planned_sell_down_week,
        trd_ma_stylecolorchannelattributes_existing.cc_selected_clusters,
        trd_ma_stylecolorchannelattributes_existing.cc_cluster_group,
        trd_ma_stylecolorchannelattributes_existing.keep_initial_range_plan,
        trd_ma_stylecolorchannelattributes_existing.cc_sizeelig_rangecode,
        trd_ma_stylecolorchannelattributes_existing.cc_presmin_stylecolor,
        trd_ma_stylecolorchannelattributes_existing.cc_presmin_weeks_stylecolor,
        trd_ma_stylecolorchannelattributes_existing.cc_final_cost,
        trd_ma_stylecolorchannelattributes_existing.cc_discount_pct_store,
        trd_ma_stylecolorchannelattributes_existing.cc_discount_pct_ecom,
        trd_ma_stylecolorchannelattributes_existing.irw_debut_offset,
        trd_ma_stylecolorchannelattributes_existing.cc_service_level_ecom,
        trd_ma_stylecolorchannelattributes_existing.cc_first_publish_date,
        trd_ma_stylecolorchannelattributes_existing.cc_first_publish_snapshot_op,
        trd_ma_stylecolorchannelattributes_existing.sclr_alloc_max,
        trd_ma_stylecolorchannelattributes_existing.sclr_presmin,
        trd_ma_stylecolorchannelattributes_existing.sclr_alloc_min,
        trd_ma_stylecolorchannelattributes_existing.sclr_presmin_weeks,
        trd_ma_stylecolorchannelattributes_existing.sclr_tgt_fwoc,
        trd_ma_stylecolorchannelattributes_existing.sclr_fringe_flag,
        trd_ma_stylecolorchannelattributes_existing.act_slsrnk_store,
        trd_ma_stylecolorchannelattributes_existing.act_aps_store,
        trd_ma_stylecolorchannelattributes_existing.act_aps_mult_adj_store,
        trd_ma_stylecolorchannelattributes_existing.act_slsrnk_ecom,
        trd_ma_stylecolorchannelattributes_existing.act_aps_ecom,
        trd_ma_stylecolorchannelattributes_existing.act_aps_mult_adj_ecom,
        trd_ma_stylecolorchannelattributes_existing.use_act_aps_or_act_rank,
        trd_ma_stylecolorchannelattributes_existing.use_valid_sizes_from,
        trd_ma_stylecolorchannelattributes_existing.apply_size_mins_to,
        trd_ma_stylecolorchannelattributes_existing.cc_addoff_store,
        trd_ma_stylecolorchannelattributes_existing.cc_addoff_ecom,
        trd_ma_stylecolorchannelattributes_existing.irw_floorset,
        trd_ma_stylecolorchannelattributes_existing.irw_superset,
        trd_ma_stylecolorchannelattributes_existing.irw_floorset_display,
        trd_ma_stylecolorchannelattributes_existing.irw_superset_display,
        trd_ma_stylecolorchannelattributes_existing.irw_floorset_id,
        trd_ma_stylecolorchannelattributes_existing.cc_size_eligibility_profile,
        trd_ma_stylecolorchannelattributes_existing.cloned_at
 FROM public.trd_ma_stylecolorchannelattributes_existing
 ORDER BY trd_ma_stylecolorchannelattributes_existing.product,
          trd_ma_stylecolorchannelattributes_existing.location,
          trd_ma_stylecolorchannelattributes_existing.dbt_wk,
          trd_ma_stylecolorchannelattributes_existing.relaunchweek,
          trd_ma_stylecolorchannelattributes_existing.erlstmkdnwk,
          trd_ma_stylecolorchannelattributes_existing.exitdate,
          trd_ma_stylecolorchannelattributes_existing.initrcptwk,
          trd_ma_stylecolorchannelattributes_existing.too
SEGMENTED BY hash(trd_ma_stylecolorchannelattributes_existing.too, trd_ma_stylecolorchannelattributes_existing.mkdnwks, trd_ma_stylecolorchannelattributes_existing.irw_indx, trd_ma_stylecolorchannelattributes_existing.dbtwk_indx, trd_ma_stylecolorchannelattributes_existing.relaunchwk_indx, trd_ma_stylecolorchannelattributes_existing.mdstart_indx, trd_ma_stylecolorchannelattributes_existing.lastdcorder_indx, trd_ma_stylecolorchannelattributes_existing.exitdate_indx) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_imgattributes_existing_super /*+basename(trd_ma_imgattributes_existing),createtype(L)*/ 
(
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
AS
 SELECT trd_ma_imgattributes_existing.indx,
        trd_ma_imgattributes_existing.product,
        trd_ma_imgattributes_existing.img,
        trd_ma_imgattributes_existing.eventdate,
        trd_ma_imgattributes_existing.version_id,
        trd_ma_imgattributes_existing.created_at,
        trd_ma_imgattributes_existing.created_by,
        trd_ma_imgattributes_existing.updated_at,
        trd_ma_imgattributes_existing.updated_by,
        trd_ma_imgattributes_existing.record_state
 FROM public.trd_ma_imgattributes_existing
 ORDER BY trd_ma_imgattributes_existing.indx,
          trd_ma_imgattributes_existing.product,
          trd_ma_imgattributes_existing.img,
          trd_ma_imgattributes_existing.eventdate,
          trd_ma_imgattributes_existing.version_id,
          trd_ma_imgattributes_existing.created_at,
          trd_ma_imgattributes_existing.created_by,
          trd_ma_imgattributes_existing.updated_at
SEGMENTED BY hash(trd_ma_imgattributes_existing.indx, trd_ma_imgattributes_existing.eventdate, trd_ma_imgattributes_existing.version_id, trd_ma_imgattributes_existing.created_at, trd_ma_imgattributes_existing.updated_at, trd_ma_imgattributes_existing.record_state, trd_ma_imgattributes_existing.product, trd_ma_imgattributes_existing.created_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_PRD_MEMBERMASTER_super /*+basename(TRD_REF_PRD_MEMBERMASTER),createtype(A)*/ 
(
 member_id,
 product_level
)
AS
 SELECT TRD_REF_PRD_MEMBERMASTER.member_id,
        TRD_REF_PRD_MEMBERMASTER.product_level
 FROM public.TRD_REF_PRD_MEMBERMASTER
 ORDER BY TRD_REF_PRD_MEMBERMASTER.member_id,
          TRD_REF_PRD_MEMBERMASTER.product_level
SEGMENTED BY hash(TRD_REF_PRD_MEMBERMASTER.member_id, TRD_REF_PRD_MEMBERMASTER.product_level) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_S5_CLIENT_ID_MAPPING_super /*+basename(TRD_REF_S5_CLIENT_ID_MAPPING),createtype(L)*/ 
(
 s5_id,
 client_erp_id,
 levelid
)
AS
 SELECT TRD_REF_S5_CLIENT_ID_MAPPING.s5_id,
        TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id,
        TRD_REF_S5_CLIENT_ID_MAPPING.levelid
 FROM public.TRD_REF_S5_CLIENT_ID_MAPPING
 ORDER BY TRD_REF_S5_CLIENT_ID_MAPPING.s5_id,
          TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id,
          TRD_REF_S5_CLIENT_ID_MAPPING.levelid
SEGMENTED BY hash(TRD_REF_S5_CLIENT_ID_MAPPING.levelid, TRD_REF_S5_CLIENT_ID_MAPPING.s5_id, TRD_REF_S5_CLIENT_ID_MAPPING.client_erp_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_d_product_super /*+basename(trd_d_product),createtype(A)*/ 
(
 id,
 client_id,
 name,
 description,
 levelid,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_d_product.id,
        trd_d_product.client_id,
        trd_d_product.name,
        trd_d_product.description,
        trd_d_product.levelid,
        trd_d_product.indx,
        trd_d_product.eventdate,
        trd_d_product.version_id,
        trd_d_product.created_at,
        trd_d_product.created_by,
        trd_d_product.updated_at,
        trd_d_product.updated_by,
        trd_d_product.record_state
 FROM public.trd_d_product
 ORDER BY trd_d_product.id,
          trd_d_product.client_id,
          trd_d_product.name,
          trd_d_product.description,
          trd_d_product.levelid,
          trd_d_product.indx,
          trd_d_product.eventdate,
          trd_d_product.version_id
SEGMENTED BY hash(trd_d_product.indx, trd_d_product.eventdate, trd_d_product.version_id, trd_d_product.created_at, trd_d_product.created_by, trd_d_product.updated_at, trd_d_product.updated_by, trd_d_product.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_super /*+basename(trd_h_prodstd),createtype(A)*/ 
(
 ID,
 ANCESTOR0,
 ANCESTOR1,
 ANCESTOR2,
 ANCESTOR3,
 ANCESTOR4,
 ANCESTOR5,
 ANCESTOR6,
 ANCESTOR7,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_h_prodstd.ID,
        trd_h_prodstd.ANCESTOR0,
        trd_h_prodstd.ANCESTOR1,
        trd_h_prodstd.ANCESTOR2,
        trd_h_prodstd.ANCESTOR3,
        trd_h_prodstd.ANCESTOR4,
        trd_h_prodstd.ANCESTOR5,
        trd_h_prodstd.ANCESTOR6,
        trd_h_prodstd.ANCESTOR7,
        trd_h_prodstd.version_id,
        trd_h_prodstd.created_at,
        trd_h_prodstd.created_by,
        trd_h_prodstd.updated_at,
        trd_h_prodstd.updated_by,
        trd_h_prodstd.record_state
 FROM public.trd_h_prodstd
 ORDER BY trd_h_prodstd.ID,
          trd_h_prodstd.ANCESTOR0,
          trd_h_prodstd.ANCESTOR1,
          trd_h_prodstd.ANCESTOR2,
          trd_h_prodstd.ANCESTOR3,
          trd_h_prodstd.ANCESTOR4,
          trd_h_prodstd.ANCESTOR5,
          trd_h_prodstd.ANCESTOR6
SEGMENTED BY hash(trd_h_prodstd.ID, trd_h_prodstd.ANCESTOR0, trd_h_prodstd.ANCESTOR1, trd_h_prodstd.ANCESTOR2, trd_h_prodstd.ANCESTOR3, trd_h_prodstd.ANCESTOR4, trd_h_prodstd.ANCESTOR5, trd_h_prodstd.ANCESTOR6) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_styleattributes_super /*+basename(trd_ma_styleattributes),createtype(A)*/ 
(
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
 sty_knit_fit
)
AS
 SELECT trd_ma_styleattributes.product,
        trd_ma_styleattributes.sty_knit_or_woven,
        trd_ma_styleattributes.sty_fabrication,
        trd_ma_styleattributes.sty_sleeve_length,
        trd_ma_styleattributes.sty_leg_opening,
        trd_ma_styleattributes.sty_brand,
        trd_ma_styleattributes.sty_body_style_silhouette,
        trd_ma_styleattributes.sty_occasion_usage,
        trd_ma_styleattributes.sty_detail,
        trd_ma_styleattributes.sty_finish_style,
        trd_ma_styleattributes.sty_private_label,
        trd_ma_styleattributes.sty_license,
        trd_ma_styleattributes.sty_license_vs_non_licensed,
        trd_ma_styleattributes.sty_hazmat_code,
        trd_ma_styleattributes.sty_prop_65_warning,
        trd_ma_styleattributes.sty_material_content,
        trd_ma_styleattributes.sty_item_type,
        trd_ma_styleattributes.sty_dwrise,
        trd_ma_styleattributes.sty_length,
        trd_ma_styleattributes.sty_neckline,
        trd_ma_styleattributes.sty_toeshape,
        trd_ma_styleattributes.sty_heel_height,
        trd_ma_styleattributes.sty_bottom_length,
        trd_ma_styleattributes.sty_v_360_smoothing,
        trd_ma_styleattributes.sty_franchise,
        trd_ma_styleattributes.sty_key_item,
        trd_ma_styleattributes.sty_single_vs_multi_pack,
        trd_ma_styleattributes.sty_ticket_type,
        trd_ma_styleattributes.sty_vpn,
        trd_ma_styleattributes.sty_size_range,
        trd_ma_styleattributes.ccstylecreatedate,
        trd_ma_styleattributes.sty_is_locked,
        trd_ma_styleattributes.sty_s5_adopted,
        trd_ma_styleattributes.eventdate,
        trd_ma_styleattributes.version_id,
        trd_ma_styleattributes.created_at,
        trd_ma_styleattributes.created_by,
        trd_ma_styleattributes.updated_at,
        trd_ma_styleattributes.updated_by,
        trd_ma_styleattributes.record_state,
        trd_ma_styleattributes.sty_knit_fit
 FROM public.trd_ma_styleattributes
 ORDER BY trd_ma_styleattributes.product,
          trd_ma_styleattributes.sty_knit_or_woven,
          trd_ma_styleattributes.sty_fabrication,
          trd_ma_styleattributes.sty_sleeve_length,
          trd_ma_styleattributes.sty_leg_opening,
          trd_ma_styleattributes.sty_brand,
          trd_ma_styleattributes.sty_body_style_silhouette,
          trd_ma_styleattributes.sty_occasion_usage
SEGMENTED BY hash(trd_ma_styleattributes.eventdate, trd_ma_styleattributes.version_id, trd_ma_styleattributes.created_at, trd_ma_styleattributes.created_by, trd_ma_styleattributes.updated_at, trd_ma_styleattributes.updated_by, trd_ma_styleattributes.record_state, trd_ma_styleattributes.sty_is_locked) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_stylecolorattributes_super /*+basename(trd_ma_stylecolorattributes),createtype(A)*/ 
(
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
 cc_material_content,
 cc_fabrication,
 stylecolor_name,
 style_name,
 cc_spec_division,
 cc_spec_group,
 cc_development_season,
 cc_delivery_season,
 cc_po_due_date,
 cc_pd_ndc_week,
 cc_additional_tariff,
 cc_design_notes,
 cc_pd_notes,
 cc_compliance_notes
)
AS
 SELECT trd_ma_stylecolorattributes.product,
        trd_ma_stylecolorattributes.cc_item_diff_1,
        trd_ma_stylecolorattributes.cc_unit_retail,
        trd_ma_stylecolorattributes.cc_unit_retail_cad,
        trd_ma_stylecolorattributes.cc_pattern,
        trd_ma_stylecolorattributes.cc_graphic,
        trd_ma_stylecolorattributes.cc_fashion_basic,
        trd_ma_stylecolorattributes.cc_holiday,
        trd_ma_stylecolorattributes.cc_property_type,
        trd_ma_stylecolorattributes.cc_internet_exclusive,
        trd_ma_stylecolorattributes.cc_web_color_discription,
        trd_ma_stylecolorattributes.cc_export_hts,
        trd_ma_stylecolorattributes.cc_commercial_invoice_description,
        trd_ma_stylecolorattributes.cc_season_code,
        trd_ma_stylecolorattributes.cc_dtr,
        trd_ma_stylecolorattributes.cc_dw_color_family,
        trd_ma_stylecolorattributes.cc_channel_reorder,
        trd_ma_stylecolorattributes.cc_ticket_season_code,
        trd_ma_stylecolorattributes.cc_sub_programs,
        trd_ma_stylecolorattributes.cc_music_genre,
        trd_ma_stylecolorattributes.cc_clearance_str_product,
        trd_ma_stylecolorattributes.cc_po_supplier,
        trd_ma_stylecolorattributes.cc_origin_country_id,
        trd_ma_stylecolorattributes.cc_country_of_sourcing,
        trd_ma_stylecolorattributes.cc_country_of_manufacturing,
        trd_ma_stylecolorattributes.cc_unit_cost,
        trd_ma_stylecolorattributes.cc_freight,
        trd_ma_stylecolorattributes.cc_royalty,
        trd_ma_stylecolorattributes.cc_duty,
        trd_ma_stylecolorattributes.cc_ship_method,
        trd_ma_stylecolorattributes.cc_lading_port,
        trd_ma_stylecolorattributes.cc_hts,
        trd_ma_stylecolorattributes.cc_primary_supplier,
        trd_ma_stylecolorattributes.cc_sub_brand,
        trd_ma_stylecolorattributes.cc_pattern_type,
        trd_ma_stylecolorattributes.cc_pop_print_neutral,
        trd_ma_stylecolorattributes.cc_debut_season_code,
        trd_ma_stylecolorattributes.cc_matchback,
        trd_ma_stylecolorattributes.cc_primary_collection,
        trd_ma_stylecolorattributes.cc_secondary_collection,
        trd_ma_stylecolorattributes.cc_vpn_color,
        trd_ma_stylecolorattributes.cc_orig_unit_retail,
        trd_ma_stylecolorattributes.cc_orig_unit_retail_cad,
        trd_ma_stylecolorattributes.cc_first_rec_week,
        trd_ma_stylecolorattributes.cc_first_inv_week,
        trd_ma_stylecolorattributes.cc_first_sale_week,
        trd_ma_stylecolorattributes.cc_first_md_week,
        trd_ma_stylecolorattributes.cc_last_md_week,
        trd_ma_stylecolorattributes.cc_last_rec_week,
        trd_ma_stylecolorattributes.cc_store_price_status,
        trd_ma_stylecolorattributes.cc_ifc_price_status,
        trd_ma_stylecolorattributes.cc_omni_price_type,
        trd_ma_stylecolorattributes.ccstylecolorcreatedate,
        trd_ma_stylecolorattributes.cc_price_band,
        trd_ma_stylecolorattributes.cc_good_better_best,
        trd_ma_stylecolorattributes.cccolor,
        trd_ma_stylecolorattributes.cccolorfamily,
        trd_ma_stylecolorattributes.total_brand_name,
        trd_ma_stylecolorattributes.division_name,
        trd_ma_stylecolorattributes.group_name,
        trd_ma_stylecolorattributes.department_name,
        trd_ma_stylecolorattributes.class_name,
        trd_ma_stylecolorattributes.subclass_name,
        trd_ma_stylecolorattributes.eventdate,
        trd_ma_stylecolorattributes.version_id,
        trd_ma_stylecolorattributes.created_at,
        trd_ma_stylecolorattributes.created_by,
        trd_ma_stylecolorattributes.updated_at,
        trd_ma_stylecolorattributes.updated_by,
        trd_ma_stylecolorattributes.record_state,
        trd_ma_stylecolorattributes.isassortment,
        trd_ma_stylecolorattributes.merch_comments,
        trd_ma_stylecolorattributes.plan_comments,
        trd_ma_stylecolorattributes.cc_is_locked,
        trd_ma_stylecolorattributes.cc_s5_adopted,
        trd_ma_stylecolorattributes.cc_prepublish,
        trd_ma_stylecolorattributes.cc_prepublished_at,
        trd_ma_stylecolorattributes.allocator_comments,
        trd_ma_stylecolorattributes.cccolorid,
        trd_ma_stylecolorattributes.cc_specstylecolor_status,
        trd_ma_stylecolorattributes.cc_supp_cost,
        trd_ma_stylecolorattributes.cc_finish,
        trd_ma_stylecolorattributes.cc_license,
        trd_ma_stylecolorattributes.cc_channel_availability,
        trd_ma_stylecolorattributes.cc_extended_size,
        trd_ma_stylecolorattributes.cc_op_markdown_week,
        trd_ma_stylecolorattributes.cc_motif,
        trd_ma_stylecolorattributes.cc_rp_revised_markdown_week,
        trd_ma_stylecolorattributes.cc_web_current_retail,
        trd_ma_stylecolorattributes.cc_parent_season_code,
        trd_ma_stylecolorattributes.cc_art_code,
        trd_ma_stylecolorattributes.cc_material_content,
        trd_ma_stylecolorattributes.cc_fabrication,
        trd_ma_stylecolorattributes.stylecolor_name,
        trd_ma_stylecolorattributes.style_name,
        trd_ma_stylecolorattributes.cc_spec_division,
        trd_ma_stylecolorattributes.cc_spec_group,
        trd_ma_stylecolorattributes.cc_development_season,
        trd_ma_stylecolorattributes.cc_delivery_season,
        trd_ma_stylecolorattributes.cc_po_due_date,
        trd_ma_stylecolorattributes.cc_pd_ndc_week,
        trd_ma_stylecolorattributes.cc_additional_tariff,
        trd_ma_stylecolorattributes.cc_design_notes,
        trd_ma_stylecolorattributes.cc_pd_notes,
        trd_ma_stylecolorattributes.cc_compliance_notes
 FROM public.trd_ma_stylecolorattributes
 ORDER BY trd_ma_stylecolorattributes.product,
          trd_ma_stylecolorattributes.cc_item_diff_1,
          trd_ma_stylecolorattributes.cc_unit_retail,
          trd_ma_stylecolorattributes.cc_unit_retail_cad,
          trd_ma_stylecolorattributes.cc_pattern,
          trd_ma_stylecolorattributes.cc_graphic,
          trd_ma_stylecolorattributes.cc_fashion_basic,
          trd_ma_stylecolorattributes.cc_holiday
SEGMENTED BY hash(trd_ma_stylecolorattributes.cc_unit_retail, trd_ma_stylecolorattributes.cc_unit_retail_cad, trd_ma_stylecolorattributes.cc_unit_cost, trd_ma_stylecolorattributes.cc_orig_unit_retail, trd_ma_stylecolorattributes.cc_orig_unit_retail_cad, trd_ma_stylecolorattributes.eventdate, trd_ma_stylecolorattributes.version_id, trd_ma_stylecolorattributes.created_at) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_sizeattributes_super /*+basename(trd_ma_sizeattributes),createtype(A)*/ 
(
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
AS
 SELECT trd_ma_sizeattributes.product,
        trd_ma_sizeattributes.parent_id,
        trd_ma_sizeattributes.item_diff_2,
        trd_ma_sizeattributes.item_diff_3,
        trd_ma_sizeattributes.sizeattribute,
        trd_ma_sizeattributes.isvalid,
        trd_ma_sizeattributes.eventdate,
        trd_ma_sizeattributes.version_id,
        trd_ma_sizeattributes.created_at,
        trd_ma_sizeattributes.created_by,
        trd_ma_sizeattributes.updated_at,
        trd_ma_sizeattributes.updated_by,
        trd_ma_sizeattributes.record_state,
        trd_ma_sizeattributes.ccctylecolorsizecreatedate
 FROM public.trd_ma_sizeattributes
 ORDER BY trd_ma_sizeattributes.product,
          trd_ma_sizeattributes.parent_id,
          trd_ma_sizeattributes.item_diff_2,
          trd_ma_sizeattributes.item_diff_3,
          trd_ma_sizeattributes.sizeattribute,
          trd_ma_sizeattributes.isvalid,
          trd_ma_sizeattributes.eventdate,
          trd_ma_sizeattributes.version_id
SEGMENTED BY hash(trd_ma_sizeattributes.isvalid, trd_ma_sizeattributes.eventdate, trd_ma_sizeattributes.version_id, trd_ma_sizeattributes.created_at, trd_ma_sizeattributes.created_by, trd_ma_sizeattributes.updated_at, trd_ma_sizeattributes.updated_by, trd_ma_sizeattributes.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_CC_SKU_MAPPING_super /*+basename(TRD_REF_CC_SKU_MAPPING),createtype(A)*/ 
(
 STYLECOLORSIZE,
 STYLECOLOR,
 STYLE,
 SUBCLASS,
 CLASS,
 DEPARTMENT,
 "GROUP",
 DIVISION,
 TOTAL_BRAND
)
AS
 SELECT TRD_REF_CC_SKU_MAPPING.STYLECOLORSIZE,
        TRD_REF_CC_SKU_MAPPING.STYLECOLOR,
        TRD_REF_CC_SKU_MAPPING.STYLE,
        TRD_REF_CC_SKU_MAPPING.SUBCLASS,
        TRD_REF_CC_SKU_MAPPING.CLASS,
        TRD_REF_CC_SKU_MAPPING.DEPARTMENT,
        TRD_REF_CC_SKU_MAPPING."GROUP",
        TRD_REF_CC_SKU_MAPPING.DIVISION,
        TRD_REF_CC_SKU_MAPPING.TOTAL_BRAND
 FROM public.TRD_REF_CC_SKU_MAPPING
 ORDER BY TRD_REF_CC_SKU_MAPPING.STYLECOLORSIZE,
          TRD_REF_CC_SKU_MAPPING.STYLECOLOR,
          TRD_REF_CC_SKU_MAPPING.STYLE,
          TRD_REF_CC_SKU_MAPPING.SUBCLASS,
          TRD_REF_CC_SKU_MAPPING.CLASS,
          TRD_REF_CC_SKU_MAPPING.DEPARTMENT,
          TRD_REF_CC_SKU_MAPPING."GROUP",
          TRD_REF_CC_SKU_MAPPING.DIVISION
SEGMENTED BY hash(TRD_REF_CC_SKU_MAPPING.STYLECOLORSIZE, TRD_REF_CC_SKU_MAPPING.STYLECOLOR, TRD_REF_CC_SKU_MAPPING.STYLE, TRD_REF_CC_SKU_MAPPING.SUBCLASS, TRD_REF_CC_SKU_MAPPING.CLASS, TRD_REF_CC_SKU_MAPPING.DEPARTMENT, TRD_REF_CC_SKU_MAPPING."GROUP", TRD_REF_CC_SKU_MAPPING.DIVISION) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_CC_STYLE_MAPPING_super /*+basename(TRD_REF_CC_STYLE_MAPPING),createtype(A)*/ 
(
 STYLECOLOR,
 STYLE
)
AS
 SELECT TRD_REF_CC_STYLE_MAPPING.STYLECOLOR,
        TRD_REF_CC_STYLE_MAPPING.STYLE
 FROM public.TRD_REF_CC_STYLE_MAPPING
 ORDER BY TRD_REF_CC_STYLE_MAPPING.STYLECOLOR,
          TRD_REF_CC_STYLE_MAPPING.STYLE
SEGMENTED BY hash(TRD_REF_CC_STYLE_MAPPING.STYLECOLOR, TRD_REF_CC_STYLE_MAPPING.STYLE) ALL NODES OFFSET 0;

CREATE PROJECTION public.size_ids_super /*+basename(size_ids),createtype(A)*/ 
(
 size_name,
 size_id
)
AS
 SELECT size_ids.size_name,
        size_ids.size_id
 FROM public.size_ids
 ORDER BY size_ids.size_name,
          size_ids.size_id
SEGMENTED BY hash(size_ids.size_name, size_ids.size_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_imgattributes_super /*+basename(trd_ma_imgattributes),createtype(A)*/ 
(
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
AS
 SELECT trd_ma_imgattributes.indx,
        trd_ma_imgattributes.product,
        trd_ma_imgattributes.img,
        trd_ma_imgattributes.eventdate,
        trd_ma_imgattributes.version_id,
        trd_ma_imgattributes.created_at,
        trd_ma_imgattributes.created_by,
        trd_ma_imgattributes.updated_at,
        trd_ma_imgattributes.updated_by,
        trd_ma_imgattributes.record_state
 FROM public.trd_ma_imgattributes
 ORDER BY trd_ma_imgattributes.indx,
          trd_ma_imgattributes.product,
          trd_ma_imgattributes.img,
          trd_ma_imgattributes.eventdate,
          trd_ma_imgattributes.version_id,
          trd_ma_imgattributes.created_at,
          trd_ma_imgattributes.created_by,
          trd_ma_imgattributes.updated_at
SEGMENTED BY hash(trd_ma_imgattributes.indx, trd_ma_imgattributes.eventdate, trd_ma_imgattributes.version_id, trd_ma_imgattributes.created_at, trd_ma_imgattributes.created_by, trd_ma_imgattributes.updated_at, trd_ma_imgattributes.updated_by, trd_ma_imgattributes.record_state) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_swatches_super /*+basename(trd_swatches),createtype(A)*/ 
(
 attributeid,
 validvalue,
 datastr,
 strtype,
 type,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_swatches.attributeid,
        trd_swatches.validvalue,
        trd_swatches.datastr,
        trd_swatches.strtype,
        trd_swatches.type,
        trd_swatches.eventdate,
        trd_swatches.version_id,
        trd_swatches.created_at,
        trd_swatches.created_by,
        trd_swatches.updated_at,
        trd_swatches.updated_by,
        trd_swatches.record_state
 FROM public.trd_swatches
 ORDER BY trd_swatches.validvalue
SEGMENTED BY hash(trd_swatches.attributeid, trd_swatches.strtype, trd_swatches.type, trd_swatches.eventdate, trd_swatches.version_id, trd_swatches.created_at, trd_swatches.created_by, trd_swatches.updated_at) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_dependencylookup_super /*+basename(trd_l_dependencylookup),createtype(L)*/ 
(
 lookup_id,
 lookup_value,
 target_id,
 target_value,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state,
 index
)
AS
 SELECT trd_l_dependencylookup.lookup_id,
        trd_l_dependencylookup.lookup_value,
        trd_l_dependencylookup.target_id,
        trd_l_dependencylookup.target_value,
        trd_l_dependencylookup.eventdate,
        trd_l_dependencylookup.version_id,
        trd_l_dependencylookup.created_at,
        trd_l_dependencylookup.created_by,
        trd_l_dependencylookup.updated_at,
        trd_l_dependencylookup.updated_by,
        trd_l_dependencylookup.record_state,
        trd_l_dependencylookup.index
 FROM public.trd_l_dependencylookup
 ORDER BY trd_l_dependencylookup.lookup_id,
          trd_l_dependencylookup.lookup_value,
          trd_l_dependencylookup.target_id,
          trd_l_dependencylookup.target_value,
          trd_l_dependencylookup.eventdate,
          trd_l_dependencylookup.version_id,
          trd_l_dependencylookup.created_at,
          trd_l_dependencylookup.created_by
SEGMENTED BY hash(trd_l_dependencylookup.eventdate, trd_l_dependencylookup.version_id, trd_l_dependencylookup.created_at, trd_l_dependencylookup.updated_at, trd_l_dependencylookup.record_state, trd_l_dependencylookup.index, trd_l_dependencylookup.created_by, trd_l_dependencylookup.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_locgrade_super /*+basename(temp_locgrade),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_locgrade."time",
        temp_locgrade.product,
        temp_locgrade.id,
        temp_locgrade.value,
        temp_locgrade.stores
 FROM public.temp_locgrade
 ORDER BY temp_locgrade."time",
          temp_locgrade.product,
          temp_locgrade.value
SEGMENTED BY hash(temp_locgrade.id, temp_locgrade."time", temp_locgrade.value, temp_locgrade.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_locgrade_nograde_super /*+basename(temp_locgrade_nograde),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_locgrade_nograde."time",
        temp_locgrade_nograde.product,
        temp_locgrade_nograde.id,
        temp_locgrade_nograde.value,
        temp_locgrade_nograde.stores
 FROM public.temp_locgrade_nograde
 ORDER BY temp_locgrade_nograde.product
SEGMENTED BY hash(temp_locgrade_nograde.value, temp_locgrade_nograde.id, temp_locgrade_nograde."time", temp_locgrade_nograde.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_locclimate_super /*+basename(temp_locclimate),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_locclimate."time",
        temp_locclimate.product,
        temp_locclimate.id,
        temp_locclimate.value,
        temp_locclimate.stores
 FROM public.temp_locclimate
 ORDER BY temp_locclimate.product
SEGMENTED BY hash(temp_locclimate.id, temp_locclimate."time", temp_locclimate.product, temp_locclimate.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_loccapacity_super /*+basename(temp_loccapacity),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_loccapacity."time",
        temp_loccapacity.product,
        temp_loccapacity.id,
        temp_loccapacity.value,
        temp_loccapacity.stores
 FROM public.temp_loccapacity
 ORDER BY temp_loccapacity.product
SEGMENTED BY hash(temp_loccapacity.id, temp_loccapacity."time", temp_loccapacity.product, temp_loccapacity.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_locbanner_super /*+basename(temp_locbanner),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_locbanner."time",
        temp_locbanner.product,
        temp_locbanner.id,
        temp_locbanner.value,
        temp_locbanner.stores
 FROM public.temp_locbanner
 ORDER BY temp_locbanner.product
SEGMENTED BY hash(temp_locbanner.id, temp_locbanner."time", temp_locbanner.product, temp_locbanner.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_locregion_super /*+basename(temp_locregion),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_locregion."time",
        temp_locregion.product,
        temp_locregion.id,
        temp_locregion.value,
        temp_locregion.stores
 FROM public.temp_locregion
 ORDER BY temp_locregion.product
SEGMENTED BY hash(temp_locregion.id, temp_locregion."time", temp_locregion.product, temp_locregion.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.temp_lochazmat_super /*+basename(temp_lochazmat),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores
)
AS
 SELECT temp_lochazmat."time",
        temp_lochazmat.product,
        temp_lochazmat.id,
        temp_lochazmat.value,
        temp_lochazmat.stores
 FROM public.temp_lochazmat
 ORDER BY temp_lochazmat.product
SEGMENTED BY hash(temp_lochazmat.id, temp_lochazmat."time", temp_lochazmat.product, temp_lochazmat.value) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_storelookup_super /*+basename(trd_l_storelookup),createtype(A)*/ 
(
 "time",
 product,
 id,
 value,
 stores,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_l_storelookup."time",
        trd_l_storelookup.product,
        trd_l_storelookup.id,
        trd_l_storelookup.value,
        trd_l_storelookup.stores,
        trd_l_storelookup.eventdate,
        trd_l_storelookup.version_id,
        trd_l_storelookup.created_at,
        trd_l_storelookup.created_by,
        trd_l_storelookup.updated_at,
        trd_l_storelookup.updated_by,
        trd_l_storelookup.record_state
 FROM public.trd_l_storelookup
 ORDER BY trd_l_storelookup."time",
          trd_l_storelookup.product,
          trd_l_storelookup.id,
          trd_l_storelookup.value,
          trd_l_storelookup.eventdate,
          trd_l_storelookup.version_id,
          trd_l_storelookup.created_at,
          trd_l_storelookup.created_by
SEGMENTED BY hash(trd_l_storelookup.eventdate, trd_l_storelookup.version_id, trd_l_storelookup.created_at, trd_l_storelookup.created_by, trd_l_storelookup.updated_at, trd_l_storelookup.updated_by, trd_l_storelookup.record_state, trd_l_storelookup.id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_v_memberbasedvalidvalues_super /*+basename(trd_v_memberbasedvalidvalues),createtype(L)*/ 
(
 attributeid,
 membertie,
 attributekey,
 attributevalue,
 indx,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_v_memberbasedvalidvalues.attributeid,
        trd_v_memberbasedvalidvalues.membertie,
        trd_v_memberbasedvalidvalues.attributekey,
        trd_v_memberbasedvalidvalues.attributevalue,
        trd_v_memberbasedvalidvalues.indx,
        trd_v_memberbasedvalidvalues.eventdate,
        trd_v_memberbasedvalidvalues.version_id,
        trd_v_memberbasedvalidvalues.created_at,
        trd_v_memberbasedvalidvalues.created_by,
        trd_v_memberbasedvalidvalues.updated_at,
        trd_v_memberbasedvalidvalues.updated_by,
        trd_v_memberbasedvalidvalues.record_state
 FROM public.trd_v_memberbasedvalidvalues
 ORDER BY trd_v_memberbasedvalidvalues.attributekey
SEGMENTED BY hash(trd_v_memberbasedvalidvalues.indx, trd_v_memberbasedvalidvalues.eventdate, trd_v_memberbasedvalidvalues.version_id, trd_v_memberbasedvalidvalues.created_at, trd_v_memberbasedvalidvalues.updated_at, trd_v_memberbasedvalidvalues.record_state, trd_v_memberbasedvalidvalues.created_by, trd_v_memberbasedvalidvalues.updated_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_ssglookup_super /*+basename(trd_l_ssglookup),createtype(L)*/ 
(
 product,
 location,
 ssg_id,
 ssg_name,
 stores,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_l_ssglookup.product,
        trd_l_ssglookup.location,
        trd_l_ssglookup.ssg_id,
        trd_l_ssglookup.ssg_name,
        trd_l_ssglookup.stores,
        trd_l_ssglookup.eventdate,
        trd_l_ssglookup.version_id,
        trd_l_ssglookup.created_at,
        trd_l_ssglookup.created_by,
        trd_l_ssglookup.updated_at,
        trd_l_ssglookup.updated_by,
        trd_l_ssglookup.record_state
 FROM public.trd_l_ssglookup
 ORDER BY trd_l_ssglookup.ssg_id
SEGMENTED BY hash(trd_l_ssglookup.eventdate, trd_l_ssglookup.version_id, trd_l_ssglookup.created_at, trd_l_ssglookup.updated_at, trd_l_ssglookup.record_state, trd_l_ssglookup.created_by, trd_l_ssglookup.updated_by, trd_l_ssglookup.product) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_l_pricebandlookup_super /*+basename(trd_l_pricebandlookup),createtype(L)*/ 
(
 product,
 ticket_price_min,
 ticket_price_max,
 price_band,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_l_pricebandlookup.product,
        trd_l_pricebandlookup.ticket_price_min,
        trd_l_pricebandlookup.ticket_price_max,
        trd_l_pricebandlookup.price_band,
        trd_l_pricebandlookup.eventdate,
        trd_l_pricebandlookup.version_id,
        trd_l_pricebandlookup.created_at,
        trd_l_pricebandlookup.created_by,
        trd_l_pricebandlookup.updated_at,
        trd_l_pricebandlookup.updated_by,
        trd_l_pricebandlookup.record_state
 FROM public.trd_l_pricebandlookup
 ORDER BY trd_l_pricebandlookup.product
SEGMENTED BY hash(trd_l_pricebandlookup.ticket_price_min, trd_l_pricebandlookup.ticket_price_max, trd_l_pricebandlookup.eventdate, trd_l_pricebandlookup.version_id, trd_l_pricebandlookup.created_at, trd_l_pricebandlookup.updated_at, trd_l_pricebandlookup.record_state, trd_l_pricebandlookup.created_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_INT_ACT_ONORDER_super /*+basename(TRD_INT_ACT_ONORDER),createtype(A)*/ 
(
 MEMBER_ID,
 LOCATION_ID,
 FLOW_ID,
 WEEK_ID,
 PRICE_STATUS,
 NDC_DATE,
 START_SHIP_DATE,
 PO_CANCEL_DATE,
 PO_ID,
 TOTAL_UNITS,
 TOTAL_COST,
 TOTAL_RETAIL,
 P_NBR_PACKS,
 P_PACK_ID,
 P_QTY_PER_PACK,
 P_PO_TYPE,
 P_VENDOR_NBR,
 P_PO_VENDOR_NBR,
 P_VENDOR_DESC,
 PO_LN_SEQ_NUM
)
AS
 SELECT TRD_INT_ACT_ONORDER.MEMBER_ID,
        TRD_INT_ACT_ONORDER.LOCATION_ID,
        TRD_INT_ACT_ONORDER.FLOW_ID,
        TRD_INT_ACT_ONORDER.WEEK_ID,
        TRD_INT_ACT_ONORDER.PRICE_STATUS,
        TRD_INT_ACT_ONORDER.NDC_DATE,
        TRD_INT_ACT_ONORDER.START_SHIP_DATE,
        TRD_INT_ACT_ONORDER.PO_CANCEL_DATE,
        TRD_INT_ACT_ONORDER.PO_ID,
        TRD_INT_ACT_ONORDER.TOTAL_UNITS,
        TRD_INT_ACT_ONORDER.TOTAL_COST,
        TRD_INT_ACT_ONORDER.TOTAL_RETAIL,
        TRD_INT_ACT_ONORDER.P_NBR_PACKS,
        TRD_INT_ACT_ONORDER.P_PACK_ID,
        TRD_INT_ACT_ONORDER.P_QTY_PER_PACK,
        TRD_INT_ACT_ONORDER.P_PO_TYPE,
        TRD_INT_ACT_ONORDER.P_VENDOR_NBR,
        TRD_INT_ACT_ONORDER.P_PO_VENDOR_NBR,
        TRD_INT_ACT_ONORDER.P_VENDOR_DESC,
        TRD_INT_ACT_ONORDER.PO_LN_SEQ_NUM
 FROM public.TRD_INT_ACT_ONORDER
 ORDER BY TRD_INT_ACT_ONORDER.MEMBER_ID,
          TRD_INT_ACT_ONORDER.LOCATION_ID,
          TRD_INT_ACT_ONORDER.FLOW_ID,
          TRD_INT_ACT_ONORDER.WEEK_ID,
          TRD_INT_ACT_ONORDER.PRICE_STATUS,
          TRD_INT_ACT_ONORDER.NDC_DATE,
          TRD_INT_ACT_ONORDER.START_SHIP_DATE,
          TRD_INT_ACT_ONORDER.PO_CANCEL_DATE
SEGMENTED BY hash(TRD_INT_ACT_ONORDER.TOTAL_UNITS, TRD_INT_ACT_ONORDER.TOTAL_COST, TRD_INT_ACT_ONORDER.TOTAL_RETAIL, TRD_INT_ACT_ONORDER.MEMBER_ID, TRD_INT_ACT_ONORDER.LOCATION_ID, TRD_INT_ACT_ONORDER.FLOW_ID, TRD_INT_ACT_ONORDER.WEEK_ID, TRD_INT_ACT_ONORDER.PRICE_STATUS) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_REF_TIMEMAPPING_WEEK_INDX_super /*+basename(TRD_REF_TIMEMAPPING_WEEK_INDX),createtype(A)*/ 
(
 week_id,
 indx
)
AS
 SELECT TRD_REF_TIMEMAPPING_WEEK_INDX.week_id,
        TRD_REF_TIMEMAPPING_WEEK_INDX.indx
 FROM public.TRD_REF_TIMEMAPPING_WEEK_INDX
 ORDER BY TRD_REF_TIMEMAPPING_WEEK_INDX.week_id
SEGMENTED BY hash(TRD_REF_TIMEMAPPING_WEEK_INDX.indx, TRD_REF_TIMEMAPPING_WEEK_INDX.week_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_OO_WEEKS_super /*+basename(TRD_PERF_ACT_OO_WEEKS),createtype(A)*/ 
(
 week_id
)
AS
 SELECT TRD_PERF_ACT_OO_WEEKS.week_id
 FROM public.TRD_PERF_ACT_OO_WEEKS
 ORDER BY TRD_PERF_ACT_OO_WEEKS.week_id
SEGMENTED BY hash(TRD_PERF_ACT_OO_WEEKS.week_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_OO_13WEEKS_super /*+basename(TRD_PERF_ACT_OO_13WEEKS),createtype(A)*/ 
(
 week_id
)
AS
 SELECT TRD_PERF_ACT_OO_13WEEKS.week_id
 FROM public.TRD_PERF_ACT_OO_13WEEKS
 ORDER BY TRD_PERF_ACT_OO_13WEEKS.week_id
SEGMENTED BY hash(TRD_PERF_ACT_OO_13WEEKS.week_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_PERF_ACT_ONORDER_SKU_super /*+basename(trd_PERF_ACT_ONORDER_SKU),createtype(A)*/ 
(
 STYLECOLORSIZE,
 STYLECOLOR,
 LOCATION_ID,
 on_order_r,
 on_order_u,
 on_order_c
)
AS
 SELECT trd_PERF_ACT_ONORDER_SKU.STYLECOLORSIZE,
        trd_PERF_ACT_ONORDER_SKU.STYLECOLOR,
        trd_PERF_ACT_ONORDER_SKU.LOCATION_ID,
        trd_PERF_ACT_ONORDER_SKU.on_order_r,
        trd_PERF_ACT_ONORDER_SKU.on_order_u,
        trd_PERF_ACT_ONORDER_SKU.on_order_c
 FROM public.trd_PERF_ACT_ONORDER_SKU
 ORDER BY trd_PERF_ACT_ONORDER_SKU.STYLECOLORSIZE,
          trd_PERF_ACT_ONORDER_SKU.STYLECOLOR,
          trd_PERF_ACT_ONORDER_SKU.LOCATION_ID
SEGMENTED BY hash(trd_PERF_ACT_ONORDER_SKU.on_order_r, trd_PERF_ACT_ONORDER_SKU.on_order_u, trd_PERF_ACT_ONORDER_SKU.on_order_c, trd_PERF_ACT_ONORDER_SKU.STYLECOLORSIZE, trd_PERF_ACT_ONORDER_SKU.STYLECOLOR, trd_PERF_ACT_ONORDER_SKU.LOCATION_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_ONORDER_SKU_4WKS_super /*+basename(TRD_PERF_ACT_ONORDER_SKU_4WKS),createtype(A)*/ 
(
 STYLECOLORSIZE,
 STYLECOLOR,
 LOCATION_ID,
 on_order_r_4wk,
 on_order_u_4wk,
 on_order_c_4wk
)
AS
 SELECT TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLORSIZE,
        TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLOR,
        TRD_PERF_ACT_ONORDER_SKU_4WKS.LOCATION_ID,
        TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_r_4wk,
        TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_u_4wk,
        TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_c_4wk
 FROM public.TRD_PERF_ACT_ONORDER_SKU_4WKS
 ORDER BY TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLORSIZE,
          TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLOR,
          TRD_PERF_ACT_ONORDER_SKU_4WKS.LOCATION_ID
SEGMENTED BY hash(TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_r_4wk, TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_u_4wk, TRD_PERF_ACT_ONORDER_SKU_4WKS.on_order_c_4wk, TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLORSIZE, TRD_PERF_ACT_ONORDER_SKU_4WKS.STYLECOLOR, TRD_PERF_ACT_ONORDER_SKU_4WKS.LOCATION_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.TRD_PERF_ACT_ONORDER_SKU_13WKS_super /*+basename(TRD_PERF_ACT_ONORDER_SKU_13WKS),createtype(A)*/ 
(
 STYLECOLORSIZE,
 STYLECOLOR,
 LOCATION_ID,
 on_order_r_13wk,
 on_order_u_13wk,
 on_order_c_13wk
)
AS
 SELECT TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLORSIZE,
        TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLOR,
        TRD_PERF_ACT_ONORDER_SKU_13WKS.LOCATION_ID,
        TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_r_13wk,
        TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_u_13wk,
        TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_c_13wk
 FROM public.TRD_PERF_ACT_ONORDER_SKU_13WKS
 ORDER BY TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLORSIZE,
          TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLOR,
          TRD_PERF_ACT_ONORDER_SKU_13WKS.LOCATION_ID
SEGMENTED BY hash(TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_r_13wk, TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_u_13wk, TRD_PERF_ACT_ONORDER_SKU_13WKS.on_order_c_13wk, TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLORSIZE, TRD_PERF_ACT_ONORDER_SKU_13WKS.STYLECOLOR, TRD_PERF_ACT_ONORDER_SKU_13WKS.LOCATION_ID) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_tbl_super /*+basename(trd_p_onorder_tbl),createtype(A)*/ 
(
 product,
 stylecolor,
 location,
 prodlife,
 cluster,
 on_order_r,
 on_order_u,
 on_order_c,
 on_order_r_4wk,
 on_order_u_4wk,
 on_order_c_4wk,
 on_order_r_13wk,
 on_order_u_13wk,
 on_order_c_13wk,
 eventdate,
 version_id,
 created_at,
 created_by,
 updated_at,
 updated_by,
 record_state
)
AS
 SELECT trd_p_onorder_tbl.product,
        trd_p_onorder_tbl.stylecolor,
        trd_p_onorder_tbl.location,
        trd_p_onorder_tbl.prodlife,
        trd_p_onorder_tbl.cluster,
        trd_p_onorder_tbl.on_order_r,
        trd_p_onorder_tbl.on_order_u,
        trd_p_onorder_tbl.on_order_c,
        trd_p_onorder_tbl.on_order_r_4wk,
        trd_p_onorder_tbl.on_order_u_4wk,
        trd_p_onorder_tbl.on_order_c_4wk,
        trd_p_onorder_tbl.on_order_r_13wk,
        trd_p_onorder_tbl.on_order_u_13wk,
        trd_p_onorder_tbl.on_order_c_13wk,
        trd_p_onorder_tbl.eventdate,
        trd_p_onorder_tbl.version_id,
        trd_p_onorder_tbl.created_at,
        trd_p_onorder_tbl.created_by,
        trd_p_onorder_tbl.updated_at,
        trd_p_onorder_tbl.updated_by,
        trd_p_onorder_tbl.record_state
 FROM public.trd_p_onorder_tbl
 ORDER BY trd_p_onorder_tbl.product,
          trd_p_onorder_tbl.stylecolor,
          trd_p_onorder_tbl.location
SEGMENTED BY hash(trd_p_onorder_tbl.prodlife, trd_p_onorder_tbl.cluster, trd_p_onorder_tbl.on_order_r, trd_p_onorder_tbl.on_order_u, trd_p_onorder_tbl.on_order_c, trd_p_onorder_tbl.on_order_r_4wk, trd_p_onorder_tbl.on_order_u_4wk, trd_p_onorder_tbl.on_order_c_4wk) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_onorder_by_po_tbl_super /*+basename(trd_p_onorder_by_po_tbl),createtype(A)*/ 
(
 sku,
 parent_id,
 location_id,
 flow_id,
 week_id,
 price_status,
 ndc_date,
 start_ship_date,
 po_cancel_date,
 po_id,
 total_units,
 total_cost,
 total_retail,
 p_nbr_packs,
 p_pack_id,
 p_qty_per_pack,
 p_po_type,
 p_vendor_nbr,
 p_po_vendor_nbr,
 p_vendor_desc,
 po_ln_seq_num,
 eventdate,
 updated_at
)
AS
 SELECT trd_p_onorder_by_po_tbl.sku,
        trd_p_onorder_by_po_tbl.parent_id,
        trd_p_onorder_by_po_tbl.location_id,
        trd_p_onorder_by_po_tbl.flow_id,
        trd_p_onorder_by_po_tbl.week_id,
        trd_p_onorder_by_po_tbl.price_status,
        trd_p_onorder_by_po_tbl.ndc_date,
        trd_p_onorder_by_po_tbl.start_ship_date,
        trd_p_onorder_by_po_tbl.po_cancel_date,
        trd_p_onorder_by_po_tbl.po_id,
        trd_p_onorder_by_po_tbl.total_units,
        trd_p_onorder_by_po_tbl.total_cost,
        trd_p_onorder_by_po_tbl.total_retail,
        trd_p_onorder_by_po_tbl.p_nbr_packs,
        trd_p_onorder_by_po_tbl.p_pack_id,
        trd_p_onorder_by_po_tbl.p_qty_per_pack,
        trd_p_onorder_by_po_tbl.p_po_type,
        trd_p_onorder_by_po_tbl.p_vendor_nbr,
        trd_p_onorder_by_po_tbl.p_po_vendor_nbr,
        trd_p_onorder_by_po_tbl.p_vendor_desc,
        trd_p_onorder_by_po_tbl.po_ln_seq_num,
        trd_p_onorder_by_po_tbl.eventdate,
        trd_p_onorder_by_po_tbl.updated_at
 FROM public.trd_p_onorder_by_po_tbl
 ORDER BY trd_p_onorder_by_po_tbl.sku,
          trd_p_onorder_by_po_tbl.location_id,
          trd_p_onorder_by_po_tbl.flow_id,
          trd_p_onorder_by_po_tbl.week_id,
          trd_p_onorder_by_po_tbl.price_status,
          trd_p_onorder_by_po_tbl.ndc_date,
          trd_p_onorder_by_po_tbl.start_ship_date,
          trd_p_onorder_by_po_tbl.po_cancel_date,
          trd_p_onorder_by_po_tbl.po_id,
          trd_p_onorder_by_po_tbl.total_units,
          trd_p_onorder_by_po_tbl.total_cost,
          trd_p_onorder_by_po_tbl.total_retail,
          trd_p_onorder_by_po_tbl.p_nbr_packs,
          trd_p_onorder_by_po_tbl.p_pack_id,
          trd_p_onorder_by_po_tbl.p_qty_per_pack,
          trd_p_onorder_by_po_tbl.p_po_type,
          trd_p_onorder_by_po_tbl.p_vendor_nbr,
          trd_p_onorder_by_po_tbl.p_po_vendor_nbr,
          trd_p_onorder_by_po_tbl.p_vendor_desc,
          trd_p_onorder_by_po_tbl.po_ln_seq_num
SEGMENTED BY hash(trd_p_onorder_by_po_tbl.price_status, trd_p_onorder_by_po_tbl.total_units, trd_p_onorder_by_po_tbl.total_cost, trd_p_onorder_by_po_tbl.total_retail, trd_p_onorder_by_po_tbl.eventdate, trd_p_onorder_by_po_tbl.updated_at, trd_p_onorder_by_po_tbl.sku, trd_p_onorder_by_po_tbl.parent_id) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_stylecolor_super /*+basename(trd_p_dc_adj_stylecolor),createtype(A)*/ 
(
 stylecolor,
 store,
 WEEK_ID,
 ON_ORDER_V,
 ON_ORDER_U,
 ON_ORDER_C,
 ON_ORDER_V_ECOM,
 ON_ORDER_U_ECOM,
 ON_ORDER_C_ECOM,
 adj_cost
)
AS
 SELECT trd_p_dc_adj_stylecolor.stylecolor,
        trd_p_dc_adj_stylecolor.store,
        trd_p_dc_adj_stylecolor.WEEK_ID,
        trd_p_dc_adj_stylecolor.ON_ORDER_V,
        trd_p_dc_adj_stylecolor.ON_ORDER_U,
        trd_p_dc_adj_stylecolor.ON_ORDER_C,
        trd_p_dc_adj_stylecolor.ON_ORDER_V_ECOM,
        trd_p_dc_adj_stylecolor.ON_ORDER_U_ECOM,
        trd_p_dc_adj_stylecolor.ON_ORDER_C_ECOM,
        trd_p_dc_adj_stylecolor.adj_cost
 FROM public.trd_p_dc_adj_stylecolor
 ORDER BY trd_p_dc_adj_stylecolor.stylecolor,
          trd_p_dc_adj_stylecolor.WEEK_ID
SEGMENTED BY hash(trd_p_dc_adj_stylecolor.store, trd_p_dc_adj_stylecolor.ON_ORDER_V, trd_p_dc_adj_stylecolor.ON_ORDER_U, trd_p_dc_adj_stylecolor.ON_ORDER_C, trd_p_dc_adj_stylecolor.ON_ORDER_V_ECOM, trd_p_dc_adj_stylecolor.ON_ORDER_U_ECOM, trd_p_dc_adj_stylecolor.ON_ORDER_C_ECOM, trd_p_dc_adj_stylecolor.adj_cost) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_p_dc_adj_stylecolorsize_super /*+basename(trd_p_dc_adj_stylecolorsize),createtype(A)*/ 
(
 stylecolorsize,
 store,
 WEEK_ID,
 ON_ORDER_V,
 ON_ORDER_U,
 ON_ORDER_C,
 ON_ORDER_V_ECOM,
 ON_ORDER_U_ECOM,
 ON_ORDER_C_ECOM,
 adj_cost
)
AS
 SELECT trd_p_dc_adj_stylecolorsize.stylecolorsize,
        trd_p_dc_adj_stylecolorsize.store,
        trd_p_dc_adj_stylecolorsize.WEEK_ID,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_V,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_U,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_C,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_V_ECOM,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_U_ECOM,
        trd_p_dc_adj_stylecolorsize.ON_ORDER_C_ECOM,
        trd_p_dc_adj_stylecolorsize.adj_cost
 FROM public.trd_p_dc_adj_stylecolorsize
 ORDER BY trd_p_dc_adj_stylecolorsize.stylecolorsize,
          trd_p_dc_adj_stylecolorsize.WEEK_ID
SEGMENTED BY hash(trd_p_dc_adj_stylecolorsize.store, trd_p_dc_adj_stylecolorsize.ON_ORDER_V, trd_p_dc_adj_stylecolorsize.ON_ORDER_U, trd_p_dc_adj_stylecolorsize.ON_ORDER_C, trd_p_dc_adj_stylecolorsize.ON_ORDER_V_ECOM, trd_p_dc_adj_stylecolorsize.ON_ORDER_U_ECOM, trd_p_dc_adj_stylecolorsize.ON_ORDER_C_ECOM, trd_p_dc_adj_stylecolorsize.adj_cost) ALL NODES OFFSET 0;

CREATE PROJECTION public.fix_stylecolor_hier_super /*+basename(fix_stylecolor_hier),createtype(A)*/ 
(
 cc_hier_id,
 cc_hier_anc0,
 cc_hier_anc2,
 cc_hier_anc3,
 cc_hier_anc4,
 cc_hier_anc5,
 cc_hier_anc6,
 cc_hier_anc7,
 style_hier_id,
 style_hier_anc1,
 style_hier_anc2,
 style_hier_anc3,
 style_hier_anc4,
 style_hier_anc5,
 style_hier_anc6
)
AS
 SELECT fix_stylecolor_hier.cc_hier_id,
        fix_stylecolor_hier.cc_hier_anc0,
        fix_stylecolor_hier.cc_hier_anc2,
        fix_stylecolor_hier.cc_hier_anc3,
        fix_stylecolor_hier.cc_hier_anc4,
        fix_stylecolor_hier.cc_hier_anc5,
        fix_stylecolor_hier.cc_hier_anc6,
        fix_stylecolor_hier.cc_hier_anc7,
        fix_stylecolor_hier.style_hier_id,
        fix_stylecolor_hier.style_hier_anc1,
        fix_stylecolor_hier.style_hier_anc2,
        fix_stylecolor_hier.style_hier_anc3,
        fix_stylecolor_hier.style_hier_anc4,
        fix_stylecolor_hier.style_hier_anc5,
        fix_stylecolor_hier.style_hier_anc6
 FROM public.fix_stylecolor_hier
 ORDER BY fix_stylecolor_hier.style_hier_id,
          fix_stylecolor_hier.cc_hier_anc0
SEGMENTED BY hash(fix_stylecolor_hier.cc_hier_id, fix_stylecolor_hier.cc_hier_anc0, fix_stylecolor_hier.cc_hier_anc2, fix_stylecolor_hier.cc_hier_anc3, fix_stylecolor_hier.cc_hier_anc4, fix_stylecolor_hier.cc_hier_anc5, fix_stylecolor_hier.cc_hier_anc6, fix_stylecolor_hier.cc_hier_anc7) ALL NODES OFFSET 0;

CREATE PROJECTION public.fix_sku_hier_super /*+basename(fix_sku_hier),createtype(A)*/ 
(
 sku_hier_id,
 sku_hier_anc0,
 sku_hier_anc2,
 sku_hier_anc3,
 sku_hier_anc4,
 sku_hier_anc5,
 sku_hier_anc6,
 sku_hier_anc7,
 styclr_hier_id,
 styclr_hier_anc1,
 styclr_hier_anc2,
 styclr_hier_anc3,
 styclr_hier_anc4,
 styclr_hier_anc5,
 styclr_hier_anc6
)
AS
 SELECT fix_sku_hier.sku_hier_id,
        fix_sku_hier.sku_hier_anc0,
        fix_sku_hier.sku_hier_anc2,
        fix_sku_hier.sku_hier_anc3,
        fix_sku_hier.sku_hier_anc4,
        fix_sku_hier.sku_hier_anc5,
        fix_sku_hier.sku_hier_anc6,
        fix_sku_hier.sku_hier_anc7,
        fix_sku_hier.styclr_hier_id,
        fix_sku_hier.styclr_hier_anc1,
        fix_sku_hier.styclr_hier_anc2,
        fix_sku_hier.styclr_hier_anc3,
        fix_sku_hier.styclr_hier_anc4,
        fix_sku_hier.styclr_hier_anc5,
        fix_sku_hier.styclr_hier_anc6
 FROM public.fix_sku_hier
 ORDER BY fix_sku_hier.styclr_hier_id,
          fix_sku_hier.sku_hier_anc0
SEGMENTED BY hash(fix_sku_hier.sku_hier_id, fix_sku_hier.sku_hier_anc0, fix_sku_hier.sku_hier_anc2, fix_sku_hier.sku_hier_anc3, fix_sku_hier.sku_hier_anc4, fix_sku_hier.sku_hier_anc5, fix_sku_hier.sku_hier_anc6, fix_sku_hier.sku_hier_anc7) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_h_prodstd_mismatch_super /*+basename(trd_h_prodstd_mismatch),createtype(A)*/ 
(
 brand_master,
 ancestor7,
 division_master,
 ancestor6,
 group_master,
 ancestor5,
 dept_master,
 ancestor4,
 class_master,
 ancestor3,
 subclass_master,
 ancestor2,
 stylecolor,
 sku_id
)
AS
 SELECT trd_h_prodstd_mismatch.brand_master,
        trd_h_prodstd_mismatch.ancestor7,
        trd_h_prodstd_mismatch.division_master,
        trd_h_prodstd_mismatch.ancestor6,
        trd_h_prodstd_mismatch.group_master,
        trd_h_prodstd_mismatch.ancestor5,
        trd_h_prodstd_mismatch.dept_master,
        trd_h_prodstd_mismatch.ancestor4,
        trd_h_prodstd_mismatch.class_master,
        trd_h_prodstd_mismatch.ancestor3,
        trd_h_prodstd_mismatch.subclass_master,
        trd_h_prodstd_mismatch.ancestor2,
        trd_h_prodstd_mismatch.stylecolor,
        trd_h_prodstd_mismatch.sku_id
 FROM public.trd_h_prodstd_mismatch
 ORDER BY trd_h_prodstd_mismatch.stylecolor,
          trd_h_prodstd_mismatch.sku_id
SEGMENTED BY hash(trd_h_prodstd_mismatch.brand_master, trd_h_prodstd_mismatch.ancestor7, trd_h_prodstd_mismatch.division_master, trd_h_prodstd_mismatch.ancestor6, trd_h_prodstd_mismatch.group_master, trd_h_prodstd_mismatch.ancestor5, trd_h_prodstd_mismatch.dept_master, trd_h_prodstd_mismatch.ancestor4) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_ma_imgattributes_existing_temp_super /*+basename(trd_ma_imgattributes_existing_temp),createtype(A)*/ 
(
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
AS
 SELECT trd_ma_imgattributes_existing_temp.indx,
        trd_ma_imgattributes_existing_temp.product,
        trd_ma_imgattributes_existing_temp.img,
        trd_ma_imgattributes_existing_temp.eventdate,
        trd_ma_imgattributes_existing_temp.version_id,
        trd_ma_imgattributes_existing_temp.created_at,
        trd_ma_imgattributes_existing_temp.created_by,
        trd_ma_imgattributes_existing_temp.updated_at,
        trd_ma_imgattributes_existing_temp.updated_by,
        trd_ma_imgattributes_existing_temp.record_state
 FROM public.trd_ma_imgattributes_existing_temp
 ORDER BY trd_ma_imgattributes_existing_temp.product
SEGMENTED BY hash(trd_ma_imgattributes_existing_temp.indx, trd_ma_imgattributes_existing_temp.eventdate, trd_ma_imgattributes_existing_temp.version_id, trd_ma_imgattributes_existing_temp.created_at, trd_ma_imgattributes_existing_temp.updated_at, trd_ma_imgattributes_existing_temp.record_state, trd_ma_imgattributes_existing_temp.product, trd_ma_imgattributes_existing_temp.created_by) ALL NODES OFFSET 0;

CREATE PROJECTION public.trd_replannable_choices_super /*+basename(trd_replannable_choices),createtype(A)*/ 
(
 stylecolor_id
)
AS
 SELECT trd_replannable_choices.stylecolor_id
 FROM public.trd_replannable_choices
 ORDER BY trd_replannable_choices.stylecolor_id
SEGMENTED BY hash(trd_replannable_choices.stylecolor_id) ALL NODES OFFSET 0;


CREATE  VIEW public.trd_ma_dptflrsetattributes_view_verification_test AS
 SELECT a.product AS department,
        b.id AS "time",
        a."time" AS floorset
 FROM public.trd_ma_dptflrsetattributes_test a, public.trd_d_time b
 WHERE ((b.id >= a.rcptstart) AND (b.id <= a.rcptend) AND (b.levelid = 'week'::varchar(4)) AND (a.rcptend >= ( SELECT trd_serviceparams.value
 FROM public.trd_serviceparams
 WHERE (trd_serviceparams.id = 'plan_current'::varchar(12)))));

CREATE  VIEW public.trd_dptflrset_verification_view_rcpt AS
 SELECT a.Product_Dept_ID AS department,
        b.id AS "time",
        a.Floorset_ID AS floorset
 FROM public.trd_dptflrset_verification a, public.trd_d_time b
 WHERE ((b.id >= a.Rcptstart) AND (b.id <= a.Rcptend) AND (b.levelid = 'week'::varchar(4)));

CREATE  VIEW public.trd_dptflrset_verification_view_apstart AS
 SELECT a.Product_Dept_ID AS department,
        b.id AS "time",
        a.Floorset_ID AS floorset
 FROM public.trd_dptflrset_verification a, public.trd_d_time b
 WHERE ((b.id >= a.AP_Start) AND (b.id <= a.AP_End) AND (b.levelid = 'week'::varchar(4)));

CREATE  VIEW public.trd_ma_dptflrsetattributes_view_verification AS
 SELECT a.product AS department,
        b.id AS "time",
        a."time" AS floorset
 FROM public.trd_ma_dptflrsetattributes a, public.trd_d_time b
 WHERE ((b.id >= a.rcptstart) AND (b.id <= a.rcptend) AND (a.rcptend >= ( SELECT trd_serviceparams.value
 FROM public.trd_serviceparams
 WHERE (trd_serviceparams.id = 'plan_current'::varchar(12)))));

CREATE FUNCTION public.isOrContains(map Long Varchar, val Varchar)
RETURN boolean AS
BEGIN
RETURN CASE WHEN (public.MapSize(map) <> (-1)) THEN public.MapContainsValue(map, val) ELSE (map = (val)) END;
END;


