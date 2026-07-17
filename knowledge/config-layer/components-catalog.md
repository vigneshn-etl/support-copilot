# Component Catalog — per-component schema requirements + real examples

Companion to components-reference.md. **Generated programmatically** from:
schema requirements parsed from `configuration-schemas/schemas/*` (zod);
examples copied from live TRD confdefns (arrays >4 items shortened to `…`);
usage counts from live TRD confdefns. Generated 2026-07. Regenerate after
frontend upgrades — the schema moves with the assortmentui monorepo.

Reading requirements: REQUIRED = zod field without .optional()/.default().
`defns.subheader` REQUIRED accepts `{}`. Props marked `(default X)` apply
when omitted. `(schema form not parsed)` = check the schema file by hand.

## AssortmentAddBySearch  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `level`, `cartItemType`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `showSelectAll`, `fabType`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## AssortmentAddView  (4× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `level`, `cartItemType`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `subheader.errorText`, `showSelectAll`, `fabType`, `showFlowStatus (default true)`, `showRangeSelector`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Select Parent Styles (New)",
 "level": "styles",
 "showRangeSelector": true,
 "cartItemType": "similar",
 "fabType": "cart",
 "defns": {
  "model": "AddtoAssortmentHistorySummary",
  "assortmentModel": "AddtoAssortmentAssortmentSummary",
  "subheader": {
   "groupBy": "AssortmentStyleCanvasViewGroupBy",
   "sortBy": "AssortmentStyleCanvasViewSortBy"
  },
  "view": [
   "AssortmentAddSimilarCanvasViewDetails",
   "AssortmentStyleCanvasViewRollUp"
  ]
 }
}
```

## AssortmentCart  (1× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Review Styles in Cart",
 "defns": {
  "model": "",
  "subheader": {},
  "view": [
   "AssortmentCart"
  ]
 }
}
```

## AssortmentPublish  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `keys.idProp`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `subheader.errorText`, `dataApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## BulkImport  (0× in TRD)
**Required:** `importId`

**Optional:** `title (default per component)`, `hideTitle`, `stepper1Label`, `stepper2Label`, `templateType`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## CanvasView  (4× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys`, `showPopover`, `fabType`, `allowWorklistFunctionality`, `showFlowStatus (default true)`, `subheader.downloadLink`, `subheader.errorText`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Canvas View",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "groupBy": "HistoryStyleColorReviewGroupBy",
   "sortBy": "HistoryReviewSortBy"
  },
  "view": [
   "HistoryStyleColorCanvasViewDetails",
   "HistoryRollUp"
  ]
 },
 "showPopover": true
}
```

## CategorySummary  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `topMembers`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Quick Snapshot",
 "defns": {
  "model": "HistoryCatRecapCatSummary",
  "subheader": {
   "groupBy": "HistoryCatRecapGroupBy"
  },
  "view": [
   "HistoryCatRecapGroupBy",
   "HistoryCatRecapCatSummaryKeyFinancials",
   "HistoryCatRecapCatSummaryChoiceProductivity",
   "HistoryCatRecapCatSummaryGrid"
  ]
 }
}
```

## CollectionAnalysis  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `collectionDataApi`, `itemsDataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `topMembers`, `showFlowStatus (default true)`, `macroDataApi`, `anchorGridDataApi`, `clusterGridDataApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## CollectionView  (5× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `keys.idProp`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `subheader.downloadLink`, `topMembers`, `floorsetApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Collection View",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "groupBy": "HistoryStyleColorReviewGroupBy",
   "sortBy": "HistoryReviewSortBy"
  },
  "view": [
   "HistoryRollUp"
  ]
 },
 "keys": {
  "idProp": "id"
 }
}
```

## ConfigEditor  (1× in TRD)
Propless component — `componentProps` not used; just `component`, `id`, `name`, `pathSlot`, `inPerspectives`.

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## ConfigurableGrid  (17× in TRD)
**Required:** `dataApi`, `configApi`, `planningApi`, `keys.idProp`

**Optional:** `topAttributesApi`, `floorsetApi`, `isStyleColorEdit`, `topMembers`, `allowWorklistFunctionality`, `showPopover`, `title (default per component)`, `hideTitle`, `hideCompanion`, `showUndoBtn`, `showFlowStatus (default true)`, `subheader.downloadLink`, `showLookBackPeriod (default true)`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `subheader.errorText`, `workflow`, `level`, `cartItemType`, `showSelectAll`, `defns`, `fabType`, `topMemberObj`, `showPublishText`, `publishText`, `publishAttribute`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "keys": {
  "idProp": "store",
  "leafIdProp": "store"
 },
 "hideCompanion": true,
 "showFlowStatus": false,
 "title": "Review Store Metadata (Like Store)",
 "dataApi": {
  "isListData": true,
  "defnId": "DeptStoreMetaData",
  "params": {
   "aggBy": "level:department,level:store",
   "nestData": false
  }
 },
 "configApi": {
  "url": "/api/uidefn/config",
  "params": {
   "appName": "Assortment",
   "defnId": "DeptStoreMetaData"
  }
 },
 "planningApi": {
  "url": "/api/assortment/plan",
  "params": {
   "appName": "Assortment",
   "defnId": "FlowSheetPlan"
  }
 },
 "topAttributesApi": {
  "url": "",
  "params": {
   "appName": "Assortment",
   "defnId": "DummyTopAttributes"
  }
 },
 "showPopover": true,
 "showLookBackPeriod": false
}
```

## EnhancedOvertime  (0× in TRD)
**Required:** `defns.models`, `defns.view`, `defns.subheader`

**Optional:** `title`, `workflow`, `topMembers`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## ExceptionsSummary  (1× in TRD)
**Required:** `dataApi`, `configApi`

**Optional:** `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "configApi": {
  "url": "/api/uidefn/config",
  "params": {
   "appName": "Assortment",
   "defnId": "HistoryExceptionsSummary"
  }
 },
 "dataApi": {
  "isListData": true,
  "defnId": "HistoryExceptionsSummary",
  "params": {
   "appName": "Assortment",
   "aggBy": "custom:groupid,custom:id"
  }
 }
}
```

## FloorsetComparison  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `keys.idProp`, `groupingInfo.dataIndex`, `groupingInfo.staticColumns`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `topMembers`, `allowWorklistFunctionality`, `subheader.downloadLink`, `floorsetApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Floorset Comparison",
 "defns": {
  "model": "AssortmentFitFloorsetComparison",
  "subheader": {
   "sortBy": "AssortmentReviewSortBy"
  },
  "view": [
   "AssortmentCardViewDetails",
   "AssortmentRollUp"
  ]
 },
 "floorsetApi": {
  "url": "/api/assortment/gettrimmedfloorsets",
  "params": {
   "appName": "Assortment"
  }
 },
 "keys": {
  "idProp": "id",
  "descProp": "description"
 },
 "groupingInfo": {
  "dataIndex": "key",
  "staticColumns": [
   "SELECTED",
   "PREVIOUS",
   "LAST YEAR"
  ]
 },
 "showPopover": true,
 "fabType": "buttonModal"
}
```

## FlowSheetByStyle  (4× in TRD)
**Required:** `defns.models`, `defns.view`, `defns.subheader`, `keys.idProp`

**Optional:** `title`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `showFlowStatus (default true)`, `topMembers`, `showUndoBtn`, `hideCompanion`, `subheader.errorText`, `dataApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Flow Sheet",
 "defns": {
  "models": [
   "AssortmentFullList",
   "AssortmentFit"
  ],
  "subheader": {
   "groupBy": "AssortmentBuildStyleGridViewGroupBy"
  },
  "view": [
   "AssortmentBuildFlowSheetGrid",
   "AssortmentBuildStyleGridViewListSort",
   "AssortmentBuildStyleGridViewGroupBy",
   "AssortmentBuildStyleGridViewRollUp",
   "\u2026"
  ]
 },
 "keys": {
  "idProp": "member:style:id"
 },
 "showPopover": true,
 "fabType": "planning",
 "subheaderErrorText": "Location and Time Scope Filters do not apply on this view"
}
```

## FlowType  (4× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `keys.idProp`, `groupingInfo.dataIndex`, `groupingInfo.staticColumns`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `topMembers`, `allowWorklistFunctionality`, `subheader.downloadLink`, `floorsetApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Flow Type",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "sortBy": "HistoryReviewSortBy"
  },
  "view": [
   "HistoryCardViewDetails",
   "HistoryRollUp"
  ]
 },
 "keys": {
  "idProp": "id",
  "descProp": "description"
 },
 "groupingInfo": {
  "dataIndex": "s5flowstatus",
  "staticColumns": [
   "NEW",
   "CARRYOVER",
   "SELL DOWN"
  ]
 }
}
```

## GeoTrends  (1× in TRD)
**Required:** `dataApi`, `graphDataApi`, `defns`

**Optional:** `showLookBackPeriod (default true)`, `showFlowStatus (default true)`, `title (default per component)`, `hideTitle`, `topMembers`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Geo Trends",
 "showFlowStatus": true,
 "showLookBackPeriod": true,
 "defns": {
  "subheader": {},
  "view": [
   "HistoryYearlyTrendRecapGeoTrends",
   "HistoryYearlyTrendRecapGeoTrendsCharts"
  ]
 },
 "dataApi": {
  "defnId": "HistoryGeo",
  "isListData": true,
  "params": {
   "appName": "Assortment",
   "aggBy": ""
  }
 },
 "graphDataApi": {
  "defnId": "HistoryGeoByMonth",
  "isListData": true,
  "params": {
   "appName": "Assortment",
   "aggBy": "level:month"
  }
 },
 "fabType": "none"
}
```

## GridView  (23× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys`, `showPopover`, `fabType`, `allowWorklistFunctionality`, `showFlowStatus (default true)`, `subheader.downloadLink`, `topMembers`, `hideCompanion`, `showUndoBtn`, `subheader.errorText`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Grid View",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "groupBy": "HistoryStyleColorReviewGroupBy"
  },
  "view": [
   "HistoryStyleColorGridViewGrid",
   "HistoryCompanionListSort",
   "HistoryStyleColorReviewGroupBy",
   "HistoryRollUp",
   "\u2026"
  ]
 },
 "showPopover": true
}
```

## ListView  (1× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys`, `topMembers`, `hideCompanion`, `fabType`, `showFlowStatus (default true)`, `subheader.errorText`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "List View",
 "defns": {
  "model": "AssortmentAnalysisGridListViewGrid",
  "subheader": {},
  "view": [
   "AssortmentAnalysisGridListViewGrid",
   "AssortmentAnalysisGridListViewListSort",
   "AssortmentAnalysisGridListViewList",
   "AssortmentAnalysisGridListViewRollUp"
  ]
 }
}
```

## MacroMix  (1× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `dataApi`, `chartDataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `showFlowStatus (default true)`, `showLookBackPeriod (default true)`, `topMembers`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Macro Mix",
 "showFlowStatus": true,
 "showLookBackPeriod": true,
 "defns": {
  "model": "HistoryMacroMix",
  "subheader": {},
  "view": [
   "HistoryMacroMix"
  ]
 },
 "dataApi": {
  "defnId": "HistoryMacroMix",
  "isListData": true,
  "params": {
   "appName": "TDAnalysis",
   "aggBy": ""
  }
 },
 "chartDataApi": {
  "defnId": "HistoryMacroMixByMonth",
  "isListData": true,
  "params": {
   "appName": "TDAnalysis",
   "aggBy": "level:month"
  }
 }
}
```

## MfpFavorite  (7× in TRD)
**Required:** `viewParams`

**Optional:** `title (default per component)`, `hideTitle`, `subheader`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Favorite",
 "subheader": {
  "extraBtns": [
   "Submit",
   "Save",
   "Import",
   "Comment",
   "\u2026"
  ]
 },
 "viewParams": {
  "title": "Class x Floorset x Grade",
  "summaryMetrics": {
   "metrics": {
    "dimension": "metrics",
    "items": [
     "gross_sales_u",
     "rec_u",
     "avail_inv_u",
     "ref_distinct_cc_count",
     "\u2026"
    ]
   },
   "revisions": {
    "dimension": "revisions",
    "items": [
     "wp",
     "ly-actuals"
    ]
   }
  },
  "rows": [
   {
    "dimension": "product",
    "items": [
     "level:department",
     "level:class"
    ]
   },
   {
    "dimension": "time",
    "items": [
     "level:quarter",
     "level:floorset_uda"
    ]
   },
   {
    "dimension": "location",
    "items": [
     "level:grade"
    ]
   }
  ],
  "columns": [
   {
    "dimension": "metrics",
    "items": [
     "receipt_start_boh_u",
     "sales_start_boh_u",
     "ref_funded_receipt_start_boh_u",
     "ref_funded_receipt_start_rec_u",
     "\u2026"
    ]
   },
   {
    "dimension": "revisions",
    "items": [
     "member:wp",
     "member:ly-actuals"
    ]
   }
  ]
 }
}
```

## MfpMassActualize  (7× in TRD)
Propless component — `componentProps` not used; just `component`, `id`, `name`, `pathSlot`, `inPerspectives`.

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## MfpMassCopy  (7× in TRD)
Propless component — `componentProps` not used; just `component`, `id`, `name`, `pathSlot`, `inPerspectives`.

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## MfpReporting  (0× in TRD)
Propless component — `componentProps` not used; just `component`, `id`, `name`, `pathSlot`, `inPerspectives`.

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## MfpReviewPlans  (7× in TRD)
**Required:** `viewParams`

**Optional:** `title (default per component)`, `hideTitle`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "viewParams": {
  "title": "Class x Floorset",
  "summaryMetrics": {
   "metrics": {
    "dimension": "metrics",
    "items": [
     "gross_sales_u",
     "rec_u",
     "avail_inv_u",
     "ref_distinct_cc_count",
     "\u2026"
    ]
   },
   "revisions": {
    "dimension": "revisions",
    "items": [
     "ty-review-approved",
     "ly-actuals"
    ]
   }
  },
  "rows": [
   {
    "dimension": "product",
    "items": [
     "level:department",
     "level:class"
    ]
   },
   {
    "dimension": "time",
    "items": [
     "level:quarter",
     "level:floorset_uda"
    ]
   }
  ],
  "columns": [
   {
    "dimension": "metrics",
    "items": [
     "receipt_start_boh_u",
     "sales_start_boh_u",
     "ref_funded_receipt_start_boh_u",
     "ref_funded_receipt_start_rec_u",
     "\u2026"
    ]
   },
   {
    "dimension": "revisions",
    "items": [
     "member:wp",
     "member:ly-actuals"
    ]
   }
  ]
 }
}
```

## MfpReviewPrivatePlans  (7× in TRD)
**Required:** `viewParams`

**Optional:** `title (default per component)`, `hideTitle`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "viewParams": {
  "title": "Class x Floorset",
  "summaryMetrics": {
   "metrics": {
    "dimension": "metrics",
    "items": [
     "gross_sales_u",
     "rec_u",
     "avail_inv_u",
     "ref_distinct_cc_count",
     "\u2026"
    ]
   },
   "revisions": {
    "dimension": "revisions",
    "items": [
     "ty-review-approved",
     "ly-actuals"
    ]
   }
  },
  "rows": [
   {
    "dimension": "product",
    "items": [
     "level:department",
     "level:class"
    ]
   },
   {
    "dimension": "time",
    "items": [
     "level:quarter",
     "level:floorset_uda"
    ]
   }
  ],
  "columns": [
   {
    "dimension": "metrics",
    "items": [
     "receipt_start_boh_u",
     "sales_start_boh_u",
     "ref_funded_receipt_start_boh_u",
     "ref_funded_receipt_start_rec_u",
     "\u2026"
    ]
   },
   {
    "dimension": "revisions",
    "items": [
     "member:wp",
     "member:ly-actuals"
    ]
   }
  ]
 }
}
```

## MfpSmartPlan  (0× in TRD)
**Required:** `title`, `description`, `sections`, `viewParams`

**Optional:** `subheader`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## MfpSplitView  (0× in TRD)
**Required:** `viewParams`

**Optional:** `title (default per component)`, `hideTitle`, `subheader`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## MfpSummaryGrid  (76× in TRD)
**Required:** `viewParams`

**Optional:** `title (default per component)`, `hideTitle`, `subheader`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "subheader": {
  "extraBtns": [
   "Submit",
   "Save",
   "Import",
   "Comment",
   "\u2026"
  ]
 },
 "title": "Collection View",
 "viewParams": {
  "title": "Review Store Count",
  "summaryMetrics": {
   "metrics": {
    "dimension": "metrics",
    "items": [
     "rec_u",
     "gross_sales_u",
     "ref_distinct_cc_count",
     "rec_u_depth",
     "\u2026"
    ]
   },
   "revisions": {
    "dimension": "revisions",
    "items": [
     "wp",
     "ly-actuals"
    ]
   }
  },
  "rows": [
   {
    "items": [
     "level:department",
     "level:class"
    ],
    "dimension": "product"
   },
   {
    "items": [
     "ref_ttl_store_count"
    ],
    "dimension": "metrics"
   },
   {
    "items": [
     "level:channel",
     "level:selling_channel",
     "level:grade"
    ],
    "dimension": "location"
   }
  ],
  "columns": [
   {
    "items": [
     "wp",
     "ly-actuals",
     "lly-actuals"
    ],
    "dimension": "revisions"
   }
  ]
 }
}
```

## NestedAttribute  (23× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `showFlowStatus (default true)`, `subheader.errorText`, `configure`, `fullHeight`, `summaries`, `topMembers`, `noTreeColumnDefinition`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Nested Attribute",
 "defns": {
  "model": "",
  "subheader": {},
  "view": [
   "TD_HistoryAggregateViewsNestedAttributeGrid",
   "HistoryAggregateViewsNestedAttributeMacro",
   "HistoryAggregateViewsNestedAttributeConfigure",
   "HistoryAggregateViewsNestedAttributeList"
  ]
 }
}
```

## NestedOvertime  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `dataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `companionDataApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Nested Over Time",
 "defns": {
  "model": "AggNestedOverTime",
  "subheader": {},
  "view": [
   "AssortmentBuildNestedOvertime"
  ]
 },
 "dataApi": {
  "params": {
   "appName": "Assortment",
   "defnId": "AggNestedOverTime",
   "aggBy": "level:week",
   "ignoreAncestors": true
  }
 }
}
```

## NestedStyleOvertime  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `dataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `companionDataApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## NestedView  (14× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys`, `topMembers`, `hideCompanion`, `fabType`, `showFlowStatus (default true)`, `subheader.errorText`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "History Grid",
 "defns": {
  "model": "HistoryHistoryGridNestedViewGrid",
  "subheader": {},
  "view": [
   "HistoryHistoryGridNestedViewGrid",
   "HistoryCompanionListSort",
   "HistoryHistoryGridNestedViewConfigure",
   "HistoryHistoryGridNestedViewList",
   "\u2026"
  ]
 },
 "keys": {
  "idProp": "name"
 }
}
```

## ParameterToggles  (3× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `fabType`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Cluster Params",
 "defns": {
  "model": "",
  "subheader": {},
  "view": [
   "ClusterParamsSections"
  ]
 },
 "fabType": "clustering"
}
```

## ParetoDetails  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `groupingInfo.dataIndex`, `groupingInfo.staticColumns`, `graphDataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Pareto Details",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "sortBy": "HistoryParetoGraphSortBy"
  },
  "view": [
   "HistoryParetoSummary",
   "HistoryParetoItemStrip",
   "HistoryParetoGraphConfiguration",
   "HistoryParetoDetailsRollUp",
   "\u2026"
  ]
 },
 "groupingInfo": {
  "dataIndex": "",
  "staticColumns": []
 },
 "graphDataApi": {
  "defnId": "HistoryByStore",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 }
}
```

## ParetoSummary  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `groupingInfo.dataIndex`, `groupingInfo.staticColumns`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Pareto Summary",
 "defns": {
  "model": "HistoryFit",
  "subheader": {},
  "view": [
   "HistoryParetoSummary",
   "HistoryParetoItemStrip",
   "HistoryParetoGraphConfiguration",
   "HistoryParetoDetailsRollUp",
   "\u2026"
  ]
 },
 "groupingInfo": {
  "dataIndex": "",
  "staticColumns": []
 }
}
```

## PlanogramSimple  (0× in TRD)
**Required:** (none)

**Optional:** `title` (default "Planogram Edit"), `hideTitle` — schema is `.loose()` (accepts additional arbitrary props; hand-verified at confdefnComponentProps.ts:519).

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## PricingOverTime  (2× in TRD)
**Required:** `defns.models`, `defns.view`, `defns.subheader`, `keys.idProp`

**Optional:** `title`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `showFlowStatus (default true)`, `topMembers`, `showUndoBtn`, `hideCompanion`, `subheader.errorText`, `dataApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Pricing View",
 "defns": {
  "models": [
   "AssortmentSummary",
   "AssortmentFit"
  ],
  "subheader": {
   "groupBy": "AssortmentBuildStyleGridViewGroupBy"
  },
  "view": [
   "AssortmentBuildPricingGrid",
   "AssortmentBuildStyleGridViewListSort",
   "AssortmentBuildStyleGridViewGroupBy",
   "AssortmentBuildStyleGridViewRollUp",
   "\u2026"
  ]
 },
 "keys": {
  "idProp": "member:style:id"
 },
 "showPopover": true,
 "fabType": "planning",
 "subheaderErrorText": "Location and Time Scope Filters do not apply on this view"
}
```

## ProductDetails  (1× in TRD)
**Required:** `defns.models`, `defns.view`, `defns.subheader`

**Optional:** `title`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Product Details",
 "defns": {
  "models": [
   "AssortmentAnalysisAggregateViewsProductDetailsGrid",
   "AssortmentAnalysisAggregateViewsProductDetailsMacro"
  ],
  "subheader": {},
  "view": [
   "AssortmentAnalysisAggregateViewsProductDetailsGrid",
   "AssortmentAnalysisAggregateViewsProductDetailsMacro"
  ]
 }
}
```

## ProductMix  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `topMembers`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Product Mix",
 "defns": {
  "model": "HistoryCatRecapProductMixPieChart",
  "subheader": {
   "groupBy": "HistoryCatRecapGroupBy"
  },
  "view": [
   "HistoryCatRecapProductMixView"
  ]
 }
}
```

## Productivity  (2× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Productivity",
 "defns": {
  "model": "HistoryCatRecapProductivity",
  "subheader": {
   "groupBy": "HistoryCatRecapGroupBy",
   "sortBy": "HistoryCatRecapProductivitySortBy"
  },
  "view": [
   "HistoryCatRecapProductivityView"
  ]
 }
}
```

## QuickTrends  (0× in TRD)
**Required:** `defns.models`, `defns.view`, `defns.subheader`, `graphDataApi`

**Optional:** `title`, `workflow`, `topMembers`, `showLookBackPeriod (default true)`, `showFlowStatus (default true)`, `gridDataApi`, `floorsetApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## Reporting  (1× in TRD)
Propless component — `componentProps` not used; just `component`, `id`, `name`, `pathSlot`, `inPerspectives`.

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## RouteToLocation  (0× in TRD)
**Required:** `dataApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## SankeyGroupedView  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `sankeyDataApi`, `detailDataApi`, `metricIndex`, `defns`, `defaults`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## SizeEligibilityListGrid  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `viewProperty`, `dataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `subheader.downloadLink`, `floorsetApi`, `companionApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## StyleCollection  (0× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `collectionDataApi`, `itemsDataApi`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `topMembers`, `showFlowStatus (default true)`, `macroDataApi`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## StyleEdit  (1× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `fabType`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Style Details View",
 "defns": {
  "model": "AssortmentFullList",
  "subheader": {},
  "view": [
   "AssortmentStyleEdit",
   "AssortmentStyleEditRollup"
  ]
 },
 "fabType": "planning"
}
```

## Summary  (1× in TRD)
**Required:** `keyFinancialsDataApi`, `choiceProductivityDataApi`, `analysisDataApi`, `productMixAndTrendDataApi`, `geoTrendDataApi`, `defns`

**Optional:** `title (default per component)`, `hideTitle`, `showFlowStatus (default true)`, `showLookBackPeriod (default true)`, `workflow`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "defns": {
  "model": "",
  "subheader": {},
  "view": [
   "HistoryYearlySummary"
  ]
 },
 "title": "Summary",
 "showFlowStatus": true,
 "showLookBackPeriod": true,
 "keyFinancialsDataApi": {
  "defnId": "HistoryYearlyTrendRecapSummaryKeyFinancials",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 },
 "choiceProductivityDataApi": {
  "defnId": "HistoryYearlyTrendRecapSummaryChoiceProductivity",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 },
 "analysisDataApi": {
  "defnId": "HistoryYearlyTrendRecapSummaryTrendAnalysis",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 },
 "productMixAndTrendDataApi": {
  "defnId": "HistoryYearlyTrendRecapSummaryProductMixAndTrend",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 },
 "geoTrendDataApi": {
  "defnId": "HistoryGeo",
  "isListData": true,
  "params": {
   "aggBy": ""
  }
 }
}
```

## SummaryView  (8× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys`, `showPopover`, `fabType`, `allowWorklistFunctionality`, `showFlowStatus (default true)`, `subheader.downloadLink`, `topMembers`, `subheader.errorText`, `floorsetApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Summary View",
 "defns": {
  "model": "HistoryFit",
  "subheader": {
   "groupBy": "HistoryStyleColorReviewGroupBy",
   "sortBy": "HistoryReviewSortBy"
  },
  "view": [
   "HistoryCardViewDetails",
   "HistoryRollUp"
  ]
 }
}
```

## TargetList  (0× in TRD)
**Required:** `type`, `view`

_No TRD usage — supported by the software, no working example in this client's config. Clone from another client or author against the schema._

## TopPerformers  (1× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `showFlowStatus (default true)`, `allowWorklistFunctionality`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "defns": {
  "model": "HistoryTopPerformers",
  "subheader": {
   "sortBy": "HistoryYearlyTrendTopPerformersSortBy",
   "countLimit": "HistoryMacroTrendsTopPerformersCountLimit"
  },
  "view": [
   "HistoryYearlyTrendTopPerformers"
  ]
 },
 "title": "Top Performers"
}
```

## TopTYvsLY  (6× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`, `keys.idProp`, `groupingInfo.dataIndex`, `groupingInfo.staticColumns`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `keys.descProp`, `keys.styleId`, `keys.leafIdProp`, `showPopover`, `fabType`, `topMembers`, `allowWorklistFunctionality`, `subheader.downloadLink`, `floorsetApi`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "title": "Top TY vs LY",
 "defns": {
  "model": "HistoryTYLY",
  "subheader": {
   "sortBy": "HistoryReviewSortBy",
   "countLimit": "HistoryStyleTopTYvsLYCountLimit"
  },
  "view": [
   "HistoryCardViewDetails",
   "HistoryRollUp"
  ]
 },
 "keys": {
  "idProp": "id",
  "descProp": "description"
 },
 "groupingInfo": {
  "dataIndex": "key",
  "staticColumns": [
   "TY",
   "LY"
  ]
 }
}
```

## Worklist  (50× in TRD)
**Required:** `defns.model`, `defns.view`, `defns.subheader`

**Optional:** `defns.dataApi`, `title`, `hideTitle`, `workflow`, `fabType`, `showFlowStatus (default true)`, `hideCompanion`, `showLevel`, `defaultPathSlot`

Example (live TRD, AssortmentUiConf.confdefn):

```json
{
 "defaultPathSlot": "hist-category-summary",
 "defns": {
  "model": "HistoryGrid_Companion",
  "subheader": {},
  "view": [
   "HistoryCatRecapCatSummaryWorklist"
  ]
 }
}
```
