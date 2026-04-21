CLASS zcl_inventory_optimization DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_inventory,
      matnr          TYPE string,
      matxt          TYPE string,
      matkl          TYPE string,
      plant          TYPE string,
      labst          TYPE i,
      umlab          TYPE i,
      netpr          TYPE decfloat16,
      stock_value    TYPE decfloat16,
      movement_90    TYPE i,
      velocity       TYPE string,
      days_supply    TYPE decfloat16,
      status         TYPE string,
      recommendation TYPE string,
    END OF ty_inventory.

    DATA it_inventory TYPE TABLE OF ty_inventory.

    METHODS fetch_data.
    METHODS calculate_metrics.
    METHODS classify_status.
    METHODS display_results
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.


CLASS zcl_inventory_optimization IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    me->fetch_data( ).
    me->calculate_metrics( ).
    me->classify_status( ).
    me->display_results( out ).
  ENDMETHOD.

  METHOD fetch_data.
    DATA wa_inventory TYPE ty_inventory.

    wa_inventory-matnr = 'MAT-001'.
    wa_inventory-matxt = 'Widget A'.
    wa_inventory-matkl = 'ELEC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 1500.
    wa_inventory-umlab = 1500.
    wa_inventory-netpr = 150.
    wa_inventory-movement_90 = 15.
    APPEND wa_inventory TO it_inventory.

    wa_inventory-matnr = 'MAT-002'.
    wa_inventory-matxt = 'Widget B'.
    wa_inventory-matkl = 'ELEC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 80.
    wa_inventory-umlab = 80.
    wa_inventory-netpr = 30.
    wa_inventory-movement_90 = 5.
    APPEND wa_inventory TO it_inventory.

    wa_inventory-matnr = 'MAT-003'.
    wa_inventory-matxt = 'Widget C'.
    wa_inventory-matkl = 'MECH'.
    wa_inventory-plant = 'P002'.
    wa_inventory-labst = 5000.
    wa_inventory-umlab = 5000.
    wa_inventory-netpr = 30.
    wa_inventory-movement_90 = 25.
    APPEND wa_inventory TO it_inventory.

    wa_inventory-matnr = 'MAT-004'.
    wa_inventory-matxt = 'Widget D'.
    wa_inventory-matkl = 'ELEC'.
    wa_inventory-plant = 'P001'.
    wa_inventory-labst = 45.
    wa_inventory-umlab = 45.
    wa_inventory-netpr = 50.
    wa_inventory-movement_90 = 2.
    APPEND wa_inventory TO it_inventory.

    wa_inventory-matnr = 'MAT-005'.
    wa_inventory-matxt = 'Widget E'.
    wa_inventory-matkl = 'MECH'.
    wa_inventory-plant = 'P002'.
    wa_inventory-labst = 2200.
    wa_inventory-umlab = 2200.
    wa_inventory-netpr = 66.
    wa_inventory-movement_90 = 8.
    APPEND wa_inventory TO it_inventory.

  ENDMETHOD.

  METHOD calculate_metrics.
    LOOP AT it_inventory INTO DATA(wa_inventory).
      wa_inventory-stock_value = wa_inventory-umlab * wa_inventory-netpr.

      IF wa_inventory-movement_90 > 10.
        wa_inventory-velocity = 'FAST'.
      ELSE.
        wa_inventory-velocity = 'SLOW'.
      ENDIF.

      IF wa_inventory-movement_90 > 0.
        DATA(lv_daily_usage) = wa_inventory-movement_90 / 90.
        IF lv_daily_usage > 0.
          wa_inventory-days_supply = wa_inventory-umlab / lv_daily_usage.
        ELSE.
          wa_inventory-days_supply = 999.
        ENDIF.
      ELSE.
        wa_inventory-days_supply = 999.
      ENDIF.

      MODIFY it_inventory FROM wa_inventory.
    ENDLOOP.
  ENDMETHOD.

  METHOD classify_status.
    LOOP AT it_inventory INTO DATA(wa_inventory).

      IF wa_inventory-umlab = 0.
        wa_inventory-status = 'RED'.
        wa_inventory-recommendation = 'URGENT Stock depleted'.

      ELSEIF wa_inventory-umlab < 50.
        wa_inventory-status = 'RED'.
        wa_inventory-recommendation = 'CRITICAL Low stock'.

      ELSEIF wa_inventory-umlab < 100.
        wa_inventory-status = 'YELLOW'.
        wa_inventory-recommendation = 'CAUTION Monitor'.

      ELSEIF wa_inventory-umlab > 500 AND wa_inventory-velocity = 'SLOW'.
        wa_inventory-status = 'YELLOW'.
        wa_inventory-recommendation = 'REVIEW High stock'.

      ELSEIF wa_inventory-days_supply > 180.
        wa_inventory-status = 'YELLOW'.
        wa_inventory-recommendation = 'OPTIMIZE Overstock'.

      ELSE.
        wa_inventory-status = 'GREEN'.
        wa_inventory-recommendation = 'OK Healthy'.

      ENDIF.

      MODIFY it_inventory FROM wa_inventory.
    ENDLOOP.
  ENDMETHOD.

  METHOD display_results.
    DATA lv_total_val TYPE decfloat16.
    DATA lv_total_qty TYPE i.
    DATA lv_red_count TYPE i.
    DATA lv_yellow_count TYPE i.
    DATA lv_green_count TYPE i.

    LOOP AT it_inventory INTO DATA(wa).
      lv_total_val = lv_total_val + wa-stock_value.
      lv_total_qty = lv_total_qty + wa-umlab.
      IF wa-status = 'RED'.
        lv_red_count = lv_red_count + 1.
      ELSEIF wa-status = 'YELLOW'.
        lv_yellow_count = lv_yellow_count + 1.
      ELSE.
        lv_green_count = lv_green_count + 1.
      ENDIF.
    ENDLOOP.

    out->write( '━━━ SUMMARY ━━━' ).
    out->write( |Total Items: { lv_total_qty }| ).
    out->write( |Total Value: { lv_total_val } SAR| ).
    out->write( |Red: { lv_red_count } Yellow: { lv_yellow_count } Green: { lv_green_count }| ).
    out->write( ' ' ).

    out->write( '━━━ INVENTORY STATUS ━━━' ).
    out->write( 'MAT ID - Description - Plant - Qty - Value - Days' ).
    out->write( ' - Velocity - Status - Action' ).
    out->write( '───────────────────────────────────────────────────' ).

    LOOP AT it_inventory INTO DATA(wa_inventory).
      DATA(p1) = wa_inventory-matnr && ' - ' && wa_inventory-matxt.
      DATA(p2) = wa_inventory-plant && ' - ' && |{ wa_inventory-umlab }|.
      DATA(p3) = |{ wa_inventory-stock_value }| && ' - '.
      DATA(p4) = |{ wa_inventory-days_supply }| && ' - '.
      DATA(p5) = wa_inventory-velocity && ' - ' && wa_inventory-status.
      DATA(p6) = wa_inventory-recommendation.
      DATA(lv_line) = p1 && ' - ' && p2 && ' - ' && p3 && p4 && p5 && ' - ' && p6.
      out->write( lv_line ).
    ENDLOOP.

    out->write( '───────────────────────────────────────────────────' ).

  ENDMETHOD.

ENDCLASS.
