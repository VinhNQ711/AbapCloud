CLASS lhc_Flight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateFlightTimes FOR VALIDATE ON SAVE
      IMPORTING keys FOR Flight~validateFlightTimes.

ENDCLASS.

CLASS lhc_Flight IMPLEMENTATION.

  METHOD validateFlightTimes.
    " Read relevant flight instance data
    READ ENTITIES OF zi_rap_flight IN LOCAL MODE
      ENTITY Flight
        FIELDS ( DepartureTime EstimatedDuration )
        WITH CORRESPONDING #( keys )
      RESULT DATA(flights).

    LOOP AT flights INTO DATA(flight).
      " Validate departure time is not in the past
      IF flight-DepartureTime < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = flight-%tky ) TO failed-flight.
        APPEND VALUE #( %tky = flight-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Departure time cannot be in the past' )
                     ) TO reported-flight.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Passenger DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateSeatNumber FOR VALIDATE ON SAVE
      IMPORTING keys FOR Passenger~validateSeatNumber.

    METHODS validateIdNumber FOR VALIDATE ON SAVE
      IMPORTING keys FOR Passenger~validateIdNumber.

ENDCLASS.

CLASS lhc_Passenger IMPLEMENTATION.

  METHOD validateSeatNumber.
    " Read relevant passenger instance data
    READ ENTITIES OF zi_rap_flight IN LOCAL MODE
      ENTITY Passenger
        FIELDS ( FlightId SeatNumber )
        WITH CORRESPONDING #( keys )
      RESULT DATA(passengers).

    " Check for duplicate seat numbers in the same flight
    LOOP AT passengers INTO DATA(passenger).
      SELECT COUNT(*)
        FROM zrap_passngr
        WHERE flight_id = @passenger-FlightId
          AND seat_number = @passenger-SeatNumber.
      
      IF sy-dbcnt > 1.
        APPEND VALUE #( %tky = passenger-%tky ) TO failed-passenger.
        APPEND VALUE #( %tky = passenger-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Seat number already taken' )
                     ) TO reported-passenger.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateIdNumber.
    " Read relevant passenger instance data
    READ ENTITIES OF zi_rap_flight IN LOCAL MODE
      ENTITY Passenger
        FIELDS ( IdNumber )
        WITH CORRESPONDING #( keys )
      RESULT DATA(passengers).

    " Validate ID number format (example: must be 12 digits)
    LOOP AT passengers INTO DATA(passenger).
      IF NOT matches( val = passenger-IdNumber
                     regex = '^\d{12}$' ).
        APPEND VALUE #( %tky = passenger-%tky ) TO failed-passenger.
        APPEND VALUE #( %tky = passenger-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'ID number must be 12 digits' )
                     ) TO reported-passenger.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS. 