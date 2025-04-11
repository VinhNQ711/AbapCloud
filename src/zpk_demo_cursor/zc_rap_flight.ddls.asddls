@EndUserText.label: 'Flight Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RAP_FLIGHT
  as projection on ZI_RAP_FLIGHT
{
  key FlightId,
      @Search.defaultSearchElement: true
      DeparturePoint,
      @Search.defaultSearchElement: true
      Destination,
      DepartureTime,
      EstimatedDuration,
      FlightStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      
      /* Associations */
      _Passengers : redirected to composition child ZC_RAP_PASSENGER
} 