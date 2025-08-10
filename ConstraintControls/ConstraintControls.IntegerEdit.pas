unit ConstraintControls.IntegerEdit;

interface

uses System.Classes, ConstraintControls.ConstraintEdit;

type
  TIntegerEditValue = class(TConstraintNullableValue<Int64>)
  published
    property Value: Int64 read GetValue write SetValue default 0;
    property NullValue: Int64 read GetNullValue write SetNullValue default 0;
  end;

  TIntegerEdit = class(TConstraintEdit<Int64>)
  strict private
    function GetValue(const aIndex: TConstraintEditValueType): TIntegerEditValue;
  strict protected
    class function CreateValueInstance: TConstraintNullableValue<Int64>; override;
    function GetValueText(const aValue: Int64): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<Int64>; override;
    function IsTextValid(const aText: string): TValidationResult<Int64>; override;
    function GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage; override;
  public
    function CompareValues(const aValue1, aValue2: Int64): Integer; override;
  published
    property Value: TIntegerEditValue index TConstraintEditValueType.vtValue read GetValue;
    property RangeMin: TIntegerEditValue index TConstraintEditValueType.vtRangeMin read GetValue;
    property RangeMax: TIntegerEditValue index TConstraintEditValueType.vtRangeMax read GetValue;
  end;

implementation

uses System.SysUtils;

{ TIntegerEdit }

function TIntegerEdit.GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage;
begin
  Result := default(TValidationMessage);
  Result.ValuePlaceholder := '#';
  case aKind of
    TValidationMessageKind.InvalidInputTitle:
      Result.ValidationMessage := 'Hinweis';
    TValidationMessageKind.InvalidTextTitle:
      Result.ValidationMessage := 'Unzulässig';
    TValidationMessageKind.InvalidValueHint:
      Result.ValidationMessage := 'Es sind nur Ziffern erlaubt.';
    TValidationMessageKind.ValueTooLowTitle:
      Result.ValidationMessage := 'Zu niedrig';
    TValidationMessageKind.ValueTooLowHint:
      Result.ValidationMessage := 'Die Zahl muss mindestens #mi sein.';
    TValidationMessageKind.ValueTooHighTitle:
      Result.ValidationMessage := 'Zu hoch';
    TValidationMessageKind.ValueTooHighHint:
      Result.ValidationMessage := 'Die Zahl darf höchstens #ma sein.';
    TValidationMessageKind.ValueOutOfRangeHint:
      Result.ValidationMessage := 'Die Zahl muss zwischen #mi und #ma liegen.';
  end;
end;

class function TIntegerEdit.CreateValueInstance: TConstraintNullableValue<Int64>;
begin
  Result := TIntegerEditValue.Create;
end;

function TIntegerEdit.GetValue(const aIndex: TConstraintEditValueType): TIntegerEditValue;
begin
  Result := GetValueInstance(aIndex) as TIntegerEditValue;
end;

function TIntegerEdit.GetValueText(const aValue: Int64): string;
begin
  Result := IntToStr(aValue);
end;

function TIntegerEdit.CompareValues(const aValue1, aValue2: Int64): Integer;
begin
  Result := 0;
  if aValue1 < aValue2 then
    Exit(-1);
  if aValue1 > aValue2 then
    Exit(+1);
end;

function TIntegerEdit.IsInputValid(const aInputData: TInputValidationData): TValidationResult<Int64>;
begin
  Result := default(TValidationResult<Int64>);
  if CompareStr(aInputData.TextToValidate, '-') = 0 then
  begin
    if not RangeMin.Null and (RangeMin.Value >= 0) then
    begin
      IsValueWithinBounds(-1, False, Result);
      Exit;
    end;
  end
  else if not TryStrToInt64(aInputData.TextToValidate, Result.NewValue) then
    Exit;

  Result.IsValid := True;
end;

function TIntegerEdit.IsTextValid(const aText: string): TValidationResult<Int64>;
begin
  Result := default(TValidationResult<Int64>);
  if not TryStrToInt64(aText, Result.NewValue) then
    Exit;

  Result.IsValid := True;
end;

end.
