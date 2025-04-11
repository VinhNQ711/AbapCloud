@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Passenger Interface View'
define view entity ZI_RAP_PASSENGER
  as select from zrap_passngr
  association to parent ZI_RAP_FLIGHT as _Flight 
    on $projection.FlightId = _Flight.FlightId
{
  key passenger_id as PassengerId,
      flight_id as FlightId,
      full_name as FullName,
      id_number as IdNumber,
      birth_date as BirthDate,
      gender as Gender,
      seat_number as SeatNumber,
      @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      /* Associations */
      _Flight
} 