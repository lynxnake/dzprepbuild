unit u_dzNullableInt64;

interface

uses
  Math,
  Variants,
  u_dzTranslator,
  u_dzVariantUtils,
  u_dzNullableTypesUtils;

{$DEFINE __DZ_NULLABLE_NUMBER_TEMPLATE__}
type
  _NULLABLE_TYPE_BASE_ = Int64;
{$INCLUDE 't_NullableNumber.tpl'}

type
  TNullableInt64 = _NULLABLE_NUMBER_;

implementation

{$INCLUDE 't_NullableNumber.tpl'}

end.

