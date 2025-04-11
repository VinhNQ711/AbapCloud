@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'file data'
define view entity ZRAP100_I_FILEDATA
  as select from zrap100_filedata
  association to parent ZRAP100_R_TRAVELTP_100 as _travel on $projection.TravelId = _travel.TravelID
{
  key zrap100_filedata.travel_id as TravelId,
  key zrap100_filedata.indx      as Indx,
      zrap100_filedata.value01   as Value01,
      zrap100_filedata.value02   as Value02,
      zrap100_filedata.value03   as Value03,
      /* Associations */
      _travel
}
