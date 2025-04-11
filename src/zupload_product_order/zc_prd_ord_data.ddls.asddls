@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Production order: data'
define view entity ZC_PRD_ORD_DATA
  as projection on ZI_PRD_ORD_DATA
{
  key AttachmentUUID,
  key Pkey1,
  key Pkey2,
  key Pkey3,
      Vstat,
      productionorder,
      product,
      productionplant,
      productionversion,
      productionordertype,
      @Semantics.quantity.unitOfMeasure : 'productionunit'
      orderplannedtotalqty,
      productionunit,
      basicschedulingtype,
      yy1_pp_demo_f0001_ord,
      value01,
      value02,
      value03,
      Message,
      Action,
      ActionText,
      StatusText,
      CriticalityStatus,
      /* Associations */
      _file : redirected to parent ZC_PRD_ORD_FILE
}
