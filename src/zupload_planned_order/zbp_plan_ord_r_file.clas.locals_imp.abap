CLASS lhc_fileupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      gcf_action_create(2) TYPE c VALUE '01',
      gcf_action_update(2) TYPE c VALUE '02',
      gcf_action_delete(2) TYPE c VALUE '03'.

    CONSTANTS:
      gcf_mimetype_xlsx TYPE string VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      gcf_mimetype_csv  TYPE string VALUE 'text/csv',
      gcf_mimetype_tab  TYPE string VALUE 'text/plain'.

    CONSTANTS:
      gcf_status_neutral  TYPE i VALUE 0,
      gcf_status_negative TYPE i VALUE 1, " Red
      gcf_status_critical TYPE i VALUE 2, " Orange
      gcf_status_positive TYPE i VALUE 3. " Green

    CONSTANTS:
      gcf_struct TYPE string VALUE 'zplan_ord_data_upload'.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR fileupload RESULT result.

    METHODS getdatafile FOR DETERMINE ON MODIFY
      IMPORTING keys FOR fileupload~getdatafile.

    METHODS updatefilestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR fileupload~updatefilestatus.

    METHODS updatebusinessobject FOR DETERMINE ON SAVE
      IMPORTING keys FOR fileupload~updatebusinessobject.

ENDCLASS.

CLASS lhc_fileupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD getdatafile.
    DATA: ldt_zplan_ord_data TYPE TABLE OF zplan_ord_data_a,
          lds_zplan_ord_data TYPE zplan_ord_data_a,
          ldt_data_upload    TYPE TABLE FOR CREATE zplan_ord_r_file\_data_upload,
          lds_data_upload    LIKE LINE OF ldt_data_upload,
          ldf_index          TYPE sy-tabix,
          ldf_actiontext     TYPE zplan_ord_i_data-actiontext.

    "Read object file processing
    READ ENTITIES OF zplan_ord_r_file IN LOCAL MODE
     ENTITY fileupload
       FIELDS ( attachment )
       WITH CORRESPONDING #( keys )
     RESULT DATA(ldt_files)
     FAILED DATA(read_failed).

    CHECK ldt_files IS NOT INITIAL.

    "Only return one records
    READ TABLE ldt_files INTO DATA(lds_files) INDEX 1.
    IF lds_files-attachment IS NOT INITIAL.
      "Convert XSTRING(binary) data file attachment to ABAP table
      zcl_file_to_abap=>file2abap(
        EXPORTING
          idf_mimetype   = lds_files-mimetype
          idf_attachment = lds_files-attachment
          idf_struct     = gcf_struct
        IMPORTING
          edt_data       =  ldt_zplan_ord_data
      ).

      "Setting child key(foreign key)
      lds_data_upload = VALUE #(
             %key-attachmentuuid = lds_files-attachmentuuid
             %is_draft = lds_files-%is_draft
      ).

      LOOP AT ldt_zplan_ord_data INTO lds_zplan_ord_data.
        ldf_index = sy-tabix.

        "Setting action text
        CASE lds_zplan_ord_data-action.
          WHEN gcf_action_create. " Create
            ldf_actiontext = TEXT-001.
          WHEN gcf_action_update. " Update
            ldf_actiontext = TEXT-002.
          WHEN gcf_action_delete. " Delete
            ldf_actiontext = TEXT-003.
          WHEN OTHERS.
            CONTINUE.
        ENDCASE.

        "Setting data uploaded from file
        APPEND VALUE #(
          %key-attachmentuuid = lds_files-attachmentuuid
          %is_draft = lds_files-%is_draft
          pkey1 = lds_zplan_ord_data-material
          pkey2 = lds_zplan_ord_data-mrparea
          pkey3 = ldf_index
          plannedorder = lds_zplan_ord_data-plannedorder
          material = lds_zplan_ord_data-material
          mrparea = lds_zplan_ord_data-mrparea
          plndorderplannedstartdate = lds_zplan_ord_data-plndorderplannedstartdate
          materialprocurementcategory = lds_zplan_ord_data-materialprocurementcategory
          plannedorderprofile = lds_zplan_ord_data-plannedorderprofile
          totalquantity = lds_zplan_ord_data-totalquantity
          baseunit = lds_zplan_ord_data-baseunit
          yy1_test6_pla = lds_zplan_ord_data-yy1_test6_pla
          longtext = lds_zplan_ord_data-longtext
          action = lds_zplan_ord_data-action "更新ステータス
          actiontext = ldf_actiontext
          criticalitystatus = gcf_status_critical
          statustext = TEXT-004
          %control-pkey1 = if_abap_behv=>mk-on
          %control-pkey2 = if_abap_behv=>mk-on
          %control-pkey3 = if_abap_behv=>mk-on
          %control-plannedorder = if_abap_behv=>mk-on
          %control-material = if_abap_behv=>mk-on
          %control-mrparea = if_abap_behv=>mk-on
          %control-plndorderplannedstartdate = if_abap_behv=>mk-on
          %control-materialprocurementcategory = if_abap_behv=>mk-on
          %control-plannedorderprofile = if_abap_behv=>mk-on
          %control-totalquantity = if_abap_behv=>mk-on
          %control-baseunit = if_abap_behv=>mk-on
          %control-yy1_test6_pla = if_abap_behv=>mk-on
          %control-longtext = if_abap_behv=>mk-on
          %control-action = if_abap_behv=>mk-on
          %control-actiontext = if_abap_behv=>mk-on
          %control-statustext = if_abap_behv=>mk-on
          %control-criticalitystatus = if_abap_behv=>mk-on
        ) TO lds_data_upload-%target.
      ENDLOOP.
      APPEND lds_data_upload TO ldt_data_upload.
      "Create child entity Data uploaded from file
      MODIFY ENTITIES OF zplan_ord_r_file
          IN LOCAL MODE
          ENTITY fileupload
          CREATE BY \_data_upload
          AUTO FILL CID WITH ldt_data_upload
      REPORTED DATA(reported_upload)
      FAILED DATA(failed_data)
      MAPPED DATA(mapped_data).

    ELSE.
      READ ENTITIES OF zplan_ord_r_file IN LOCAL MODE
            ENTITY fileupload
            BY \_data_upload
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(ldt_file_data).

      CHECK ldt_file_data IS NOT INITIAL.
      MODIFY ENTITIES OF zplan_ord_r_file IN LOCAL MODE
            ENTITY data
            DELETE FROM
            VALUE #( FOR lds_file_data IN ldt_file_data
                    (
                        %tky = lds_file_data-%tky
                    )
                   )
        REPORTED reported_upload
        FAILED failed_data.
    ENDIF.

  ENDMETHOD.

  METHOD updatefilestatus.
    "Read entity file processing
    READ ENTITIES OF zplan_ord_r_file IN LOCAL MODE
     ENTITY fileupload
       FIELDS ( attachment )
       WITH CORRESPONDING #( keys )
     RESULT DATA(ldt_files)
     FAILED DATA(read_failed).

    CHECK ldt_files IS NOT INITIAL.

    DATA: ldf_filestatus(20)       TYPE c,
          ldf_criticalitystatus(1) TYPE c.

    READ TABLE ldt_files INTO DATA(lds_files) INDEX 1.

    "Setting file status
    CASE lds_files-mimetype.
      WHEN gcf_mimetype_xlsx OR gcf_mimetype_csv OR gcf_mimetype_tab.
        ldf_criticalitystatus = gcf_status_positive.
        ldf_filestatus = TEXT-005. "File Uploaded
      WHEN space.
        ldf_criticalitystatus = gcf_status_neutral.
        ldf_filestatus = TEXT-006. "File not Uploaded
      WHEN OTHERS.
        ldf_filestatus = TEXT-007. "File is invalid
        ldf_criticalitystatus = gcf_status_negative.
    ENDCASE.

    "Update file status
    MODIFY ENTITIES OF zplan_ord_r_file IN LOCAL MODE
        ENTITY fileupload
        UPDATE
        FIELDS ( filestatus criticalitystatus )
        WITH VALUE #( (
            %is_draft = lds_files-%is_draft
            %key = lds_files-%key
            filestatus = ldf_filestatus
            criticalitystatus = ldf_criticalitystatus
            %control-filestatus = if_abap_behv=>mk-on
            %control-criticalitystatus = if_abap_behv=>mk-on
        ) )
        REPORTED DATA(update_reported).

    "Set the changing parameter to update UI screen
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD updatebusinessobject.
    "Read entity child (Data uploaded from file)
    READ ENTITIES OF zplan_ord_r_file IN LOCAL MODE
        ENTITY fileupload
        BY \_data_upload
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ldt_data_upload)
        FAILED DATA(read_failed).

    DATA: lds_zplan_ord_upload TYPE zplan_ord_i_data.
    DATA(lo_process_parallel) = NEW zcl_plan_ord_modify(  ).

    LOOP AT ldt_data_upload ASSIGNING FIELD-SYMBOL(<l_s_data_upload>).
      IF <l_s_data_upload>-vstat IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <l_s_data_upload> TO lds_zplan_ord_upload.

      "Edit production version using parallel
      lo_process_parallel->modify_planned_order(
        EXPORTING is_input = lds_zplan_ord_upload
        IMPORTING es_output = lds_zplan_ord_upload
      ).
      "Update data result
      MOVE-CORRESPONDING lds_zplan_ord_upload TO <l_s_data_upload>.
    ENDLOOP.

    "Update table Data Uploaded
    MODIFY ENTITIES OF zplan_ord_r_file IN LOCAL MODE
        ENTITY data
        UPDATE
        FIELDS ( message vstat plannedorder )
        WITH VALUE #( FOR lds_data_upload IN ldt_data_upload (
            %tky = lds_data_upload-%tky
            plannedorder = lds_data_upload-plannedorder
            message = lds_data_upload-message
            vstat = lds_data_upload-vstat
            %control-plannedorder = if_abap_behv=>mk-on
            %control-message = if_abap_behv=>mk-on
            %control-vstat = if_abap_behv=>mk-on
        ) )
    REPORTED DATA(update_reported).

    "Update table parent (File Uploaded)
    MODIFY ENTITIES OF zplan_ord_r_file  IN LOCAL MODE
        ENTITY fileupload
        UPDATE
        FROM VALUE #( (
            %is_draft = ldt_data_upload[ 1 ]-%is_draft
            %key-attachmentuuid = ldt_data_upload[ 1 ]-attachmentuuid
            %data-status = abap_true "File Processed
            %control-status = if_abap_behv=>mk-on

        ) ).

    "Set the changing parameter to update UI screen
    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zplan_ord_r_file DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zplan_ord_r_file IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
