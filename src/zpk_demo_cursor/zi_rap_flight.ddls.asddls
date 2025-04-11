@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flight Interface View'
define root view entity ZI_RAP_FLIGHT
  as select from zrap_vnq_flight
  composition [0..*] of ZI_RAP_PASSENGER as _Passengers
{
  key flight_id as FlightId,
      departure_point as DeparturePoint,
      destination as Destination,
      departure_time as DepartureTime,
      estimated_duration as EstimatedDuration,
      flight_status as FlightStatus,
      @Semantics.user.createdBy: true
      created_by as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      /* Associations */
      _Passengers
} 