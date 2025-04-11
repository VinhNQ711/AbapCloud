@EndUserText.label: 'Passenger Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_RAP_PASSENGER
  as projection on ZI_RAP_PASSENGER
{
  key PassengerId,
      FlightId,
      @Search.defaultSearchElement: true
      FullName,
      IdNumber,
      BirthDate,
      Gender,
      SeatNumber,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      
      /* Associations */
      _Flight : redirected to parent ZC_RAP_FLIGHT
} 