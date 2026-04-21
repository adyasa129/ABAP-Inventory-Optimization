CLASS z_inventory_analysis_advanced DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_inventory_extended,
      matnr              TYPE string,
      matxt              TYPE string,
      matkl              TYPE string,
      meins              TYPE string,
      plant              TYPE string,
      labst              TYPE i,
      umlab              TYPE i,
      netpr              TYPE decfloat16,
      stock_value        TYPE decfloat16,
      movement_90        TYPE i,
      movement_30        TYPE i,
      movement_7         TYPE i,
      velocity           TYPE string,
      turnover_ratio     TYPE decfloat16,
      days_supply        TYPE decfloat16,
      reorder_point      TYPE string,
      safety_stock       TYPE string,
      status             TYPE string,
      risk_level         TYPE string,
      recommendation     TYPE string,
      action_priority    TYPE string,
    END OF ty_inventory_extended.

    DATA it_inventory_extended TYPE TABLE OF ty_inventory_extended.
    DATA lv_message TYPE string.

    METHODS fetch_stock_data.
    METHODS calculate_advanced_metrics.
    METHODS classify_risk_level.
    METHODS generate_recommendations.
    METHODS display_results
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS log_message
      IMPORTING
        iv_message TYPE string.

ENDCLASS.


CLASS z_inventory_analysis_advanced IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    me->fetch_stock_data( ).
    me->calculate_advanced_metrics( ).
    me->classify_risk_level( ).
    me->generate_recommendations( ).
    me->display_results( out ).
  ENDMETHOD.

  METHOD fetch_stock_data.
    DATA wa_inventory TYPE ty_inventory_extended.

    wa_inventory-matnr = 'MAT-001'.
    wa_inventory-matxt = 'Widget A Premium'.
    wa_inventory-matkl = '100'.
    wa_inventory-meins = 'PC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 1500.
    wa_inventory-umlab = 1500.
    wa_inventory-netpr = 150.
    wa_inventory-movement_90 = 45.
    wa_inventory-movement_30 = 18.
    wa_inventory-movement_7 = 4.
    APPEND wa_inventory TO it_inventory_extended.

    wa_inventory-matnr = 'MAT-002'.
    wa_inventory-matxt = 'Widget B Standard'.
    wa_inventory-matkl = '101'.
    wa_inventory-meins = 'PC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 80.
    wa_inventory-umlab = 80.
    wa_inventory-netpr = 30.
    wa_inventory-movement_90 = 8.
    wa_inventory-movement_30 = 2.
    wa_inventory-movement_7 = 0.
    APPEND wa_inventory TO it_inventory_extended.

    wa_inventory-matnr = 'MAT-003'.
    wa_inventory-matxt = 'Widget C Industrial'.
    wa_inventory-matkl = '102'.
    wa_inventory-meins = 'BOX'.
    wa_inventory-plant = 'P002'.
    wa_inventory-labst = 5000.
    wa_inventory-umlab = 5000.
    wa_inventory-netpr = 30.
    wa_inventory-movement_90 = 120.
    wa_inventory-movement_30 = 42.
    wa_inventory-movement_7 = 10.
    APPEND wa_inventory TO it_inventory_extended.

    wa_inventory-matnr = 'MAT-004'.
    wa_inventory-matxt = 'Widget D Economy'.
    wa_inventory-matkl = '103'.
    wa_inventory-meins = 'PC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 45.
    wa_inventory-umlab = 45.
    wa_inventory-netpr = 50.
    wa_inventory-movement_90 = 3.
    wa_inventory-movement_30 = 1.
    wa_inventory-movement_7 = 0.
    APPEND wa_inventory TO it_inventory_extended.

    wa_inventory-matnr = 'MAT-005'.
    wa_inventory-matxt = 'Widget E Heavy'.
    wa_inventory-matkl = '104'.
    wa_inventory-meins = 'KG'.
    wa_inventory-plant = 'P002'.
    wa_inventory-labst = 2200.
    wa_inventory-umlab = 2200.
    wa_inventory-netpr = 66.
    wa_inventory-movement_90 = 25.
    wa_inventory-movement_30 = 9.
    wa_inventory-movement_7 = 2.
    APPEND wa_inventory TO it_inventory_extended.

    wa_inventory-matnr = 'MAT-006'.
    wa_inventory-matxt = 'Widget F Specialty'.
    wa_inventory-matkl = '105'.
    wa_inventory-meins = 'SET'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 0.
    wa_inventory-umlab = 0.
    wa_inventory-netpr = 200.
    wa_inventory-movement_90 = 15.
    wa_inventory-movement_30 = 5.
    wa_inventory-movement_7 = 1.
    APPEND wa_inventory TO it_inventory_extended.

  ENDMETHOD.

  METHOD calculate_advanced_metrics.
    DATA lv_daily_consumption TYPE decfloat16.

    LOOP AT it_inventory_extended INTO DATA(wa_inventory).
      wa_inventory-stock_value = wa_inventory-umlab * wa_inventory-netpr.

      IF wa_inventory-movement_90 > 0.
        lv_daily_consumption = wa_inventory-movement_90 / 90.
      ELSE.
        lv_daily_consumption = 0.
      ENDIF.

      IF wa_inventory-movement_90 > 60.
        wa_inventory-velocity = 'VERY_FAST'.
      ELSEIF wa_inventory-movement_90 > 30.
        wa_inventory-velocity = 'FAST'.
      ELSEIF wa_inventory-movement_90 > 10.
        wa_inventory-velocity = 'NORMAL'.
      ELSEIF wa_inventory-movement_90 > 3.
        wa_inventory-velocity = 'SLOW'.
      ELSE.
        wa_inventory-velocity = 'VERY_SLOW'.
      ENDIF.

      IF wa_inventory-umlab > 0.
        wa_inventory-turnover_ratio = ( wa_inventory-movement_90 / 90 )
          * 365 / wa_inventory-umlab.
      ELSE.
        wa_inventory-turnover_ratio = 0.
      ENDIF.

      IF lv_daily_consumption > 0.
        wa_inventory-days_supply = wa_inventory-umlab /
          lv_daily_consumption.
      ELSE.
        wa_inventory-days_supply = 999.
      ENDIF.

      IF lv_daily_consumption > 0.
        wa_inventory-reorder_point = |{ lv_daily_consumption * 10 }|.
        wa_inventory-safety_stock = |{ lv_daily_consumption * 20 }|.
      ELSE.
        wa_inventory-reorder_point = 'N/A'.
        wa_inventory-safety_stock = 'N/A'.
      ENDIF.

      MODIFY it_inventory_extended FROM wa_inventory.
    ENDLOOP.

  ENDMETHOD.

  METHOD classify_risk_level.

    LOOP AT it_inventory_extended INTO DATA(wa_inventory).

      IF wa_inventory-umlab = 0.
        wa_inventory-risk_level = 'CRITICAL'.
        wa_inventory-status = 'RED'.

      ELSEIF wa_inventory-umlab < 50 AND wa_inventory-movement_90 > 10.
        wa_inventory-risk_level = 'HIGH'.
        wa_inventory-status = 'RED'.

      ELSEIF wa_inventory-umlab < 100 OR wa_inventory-days_supply < 15.
        wa_inventory-risk_level = 'MEDIUM'.
        wa_inventory-status = 'YELLOW'.

      ELSEIF wa_inventory-days_supply > 180 AND
             wa_inventory-velocity = 'SLOW'.
        wa_inventory-risk_level = 'OVERSTOCK'.
        wa_inventory-status = 'YELLOW'.

      ELSEIF wa_inventory-velocity = 'VERY_SLOW' AND
             wa_inventory-umlab > 500.
        wa_inventory-risk_level = 'OBSOLESCENCE'.
        wa_inventory-status = 'YELLOW'.

      ELSE.
        wa_inventory-risk_level = 'LOW'.
        wa_inventory-status = 'GREEN'.

      ENDIF.

      MODIFY it_inventory_extended FROM wa_inventory.

    ENDLOOP.

  ENDMETHOD.

  METHOD generate_recommendations.

    LOOP AT it_inventory_extended INTO DATA(wa_inventory).

      CASE wa_inventory-risk_level.

        WHEN 'CRITICAL'.
          wa_inventory-recommendation =
            'URGENT Stock depleted Emergency order required'.
          wa_inventory-action_priority = 'P0 IMMEDIATE'.

        WHEN 'HIGH'.
          wa_inventory-recommendation =
            'Order immediately to avoid stockout'.
          wa_inventory-action_priority = 'P1 TODAY'.

        WHEN 'MEDIUM'.
          wa_inventory-recommendation =
            'Schedule order for next purchase cycle'.
          wa_inventory-action_priority = 'P2 THIS WEEK'.

        WHEN 'OVERSTOCK'.
          wa_inventory-recommendation =
            'Reduce stock Implement promotional strategy'.
          wa_inventory-action_priority = 'P3 THIS MONTH'.

        WHEN 'OBSOLESCENCE'.
          wa_inventory-recommendation =
            'Review demand forecast Consider phasing out'.
          wa_inventory-action_priority = 'P3 REVIEW'.

        WHEN 'LOW'.
          wa_inventory-recommendation =
            'Maintain current stock levels All good'.
          wa_inventory-action_priority = 'P4 MONITOR'.

      ENDCASE.

      MODIFY it_inventory_extended FROM wa_inventory.

    ENDLOOP.

  ENDMETHOD.

  METHOD display_results.
    DATA lv_total_qty TYPE i.
    DATA lv_total_val TYPE decfloat16.
    DATA lv_critical TYPE i.
    DATA lv_high TYPE i.
    DATA lv_medium TYPE i.
    DATA lv_overstock TYPE i.
    DATA lv_obsolete TYPE i.
    DATA lv_low TYPE i.

    LOOP AT it_inventory_extended INTO DATA(wa).
      lv_total_qty = lv_total_qty + wa-umlab.
      lv_total_val = lv_total_val + wa-stock_value.
      IF wa-risk_level = 'CRITICAL'.
        lv_critical = lv_critical + 1.
      ELSEIF wa-risk_level = 'HIGH'.
        lv_high = lv_high + 1.
      ELSEIF wa-risk_level = 'MEDIUM'.
        lv_medium = lv_medium + 1.
      ELSEIF wa-risk_level = 'OVERSTOCK'.
        lv_overstock = lv_overstock + 1.
      ELSEIF wa-risk_level = 'OBSOLESCENCE'.
        lv_obsolete = lv_obsolete + 1.
      ELSE.
        lv_low = lv_low + 1.
      ENDIF.
    ENDLOOP.

    out->write( '════════════════════════════════════════════════' ).
    out->write( '    ADVANCED INVENTORY ANALYSIS RESULTS' ).
    out->write( '════════════════════════════════════════════════' ).
    out->write( ' ' ).

    out->write( '━━━ SUMMARY STATISTICS ━━━' ).
    out->write( |Total Materials: { lines( it_inventory_extended ) }| ).
    out->write( |Total Stock Qty: { lv_total_qty }| ).
    out->write( |Total Stock Value: { lv_total_val } SAR| ).
    out->write( |Critical: { lv_critical } High: { lv_high } Medium:| &&
                | { lv_medium } Overstock: { lv_overstock }| ).
    out->write( |Obsolete: { lv_obsolete } Healthy: { lv_low }| ).
    out->write( ' ' ).

    out->write( '━━━ DETAILED ANALYSIS ━━━' ).
    out->write( 'MAT - Description - Plant - Qty - Value - Days -' &&
                ' Velocity - Risk - Priority' ).
    out->write( '───────────────────────────────────────────────────' ).

    LOOP AT it_inventory_extended INTO DATA(wa_inventory).
      DATA(p1) = wa_inventory-matnr && ' - ' && wa_inventory-matxt.
      DATA(p2) = wa_inventory-plant && ' - ' && |{ wa_inventory-umlab }|.
      DATA(p3) = |{ wa_inventory-stock_value }| && ' - '.
      DATA(p4) = |{ wa_inventory-days_supply }| && ' - '.
      DATA(p5) = wa_inventory-velocity && ' - ' &&
                 wa_inventory-risk_level && ' - '.
      DATA(p6) = wa_inventory-action_priority.
      DATA(lv_line) = p1 && ' - ' && p2 && ' - ' && p3 && p4 && p5 && p6.
      out->write( lv_line ).
    ENDLOOP.

    out->write( '───────────────────────────────────────────────────' ).
    out->write( ' ' ).

    out->write( '━━━ ADVANCED METRICS ━━━' ).
    out->write( 'MAT - Turnover - Reorder Pt - Safety Stk - Status' ).
    out->write( '───────────────────────────────────────────────────' ).

    LOOP AT it_inventory_extended INTO DATA(wa_metrics).
      DATA(mt1) = wa_metrics-matnr && ' - '.
      DATA(mt2) = |{ wa_metrics-turnover_ratio }| && ' - '.
      DATA(mt3) = wa_metrics-reorder_point && ' - '.
      DATA(mt4) = wa_metrics-safety_stock && ' - '.
      DATA(mt5) = wa_metrics-status.
      DATA(lv_metric_line) = mt1 && mt2 && mt3 && mt4 && mt5.
      out->write( lv_metric_line ).
    ENDLOOP.

    out->write( '───────────────────────────────────────────────────' ).
    out->write( ' ' ).

    out->write( '━━━ RECOMMENDATIONS ━━━' ).
    out->write( 'MAT - Risk Level - Recommendation - Priority' ).
    out->write( '───────────────────────────────────────────────────' ).

    LOOP AT it_inventory_extended INTO DATA(wa_rec).
      DATA(r1) = wa_rec-matnr && ' - ' && wa_rec-risk_level && ' - '.
      DATA(r2) = wa_rec-recommendation && ' - '.
      DATA(r3) = wa_rec-action_priority.
      DATA(lv_rec_line) = r1 && r2 && r3.
      out->write( lv_rec_line ).
    ENDLOOP.

    out->write( '───────────────────────────────────────────────────' ).
    out->write( ' ' ).


  ENDMETHOD.

  METHOD log_message.
    lv_message = iv_message.
  ENDMETHOD.

ENDCLASS.
