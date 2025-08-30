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
    procedure SetValue(const aIndex: TConstraintEditValueType; const aValue: TIntegerEditValue);
  strict protected
    function CreateValueInstance: TConstraintNullableValue<Int64>; override;
    function GetValueText(const aValue: Int64): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<Int64>; override;
    function IsTextValid(const aText: string): TValidationResult<Int64>; override;
    procedure EvaluateBounds(const aPartialInput: Boolean; var aValidationResult: TValidationResult<Int64>); override;
    function GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage; override;
  public
    function CompareValues(const aValue1, aValue2: Int64): Integer; override;
  published
    property Value: TIntegerEditValue index TConstraintEditValueType.vtValue read GetValue write SetValue;
    property BoundsLower: TIntegerEditValue index TConstraintEditValueType.vtBoundsLower read GetValue write SetValue;
    property BoundsUpper: TIntegerEditValue index TConstraintEditValueType.vtBoundsUpper read GetValue write SetValue;
    property OnExitQueryValidation: TOnExitQueryValidation
      read GetOnExitQueryValidation write SetOnExitQueryValidation;
    property OnExitQueryValidationValue: TOnExitQueryValidationValue<Int64>
      read fOnExitQueryValidationValue write fOnExitQueryValidationValue;
  end;

implementation

uses System.SysUtils, System.Math;

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
    TValidationMessageKind.EmptyValueHint:
      Result.ValidationMessage := 'Die Zahl muss angegeben sein.';
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

function TIntegerEdit.CreateValueInstance: TConstraintNullableValue<Int64>;
begin
  Result := TIntegerEditValue.Create(Self);
end;

function TIntegerEdit.GetValue(const aIndex: TConstraintEditValueType): TIntegerEditValue;
begin
  const Instance = GetValueInstance(aIndex);
  if Assigned(Instance) then
    Result := Instance as TIntegerEditValue
  else
    Result := nil;
end;

procedure TIntegerEdit.SetValue(const aIndex: TConstraintEditValueType; const aValue: TIntegerEditValue);
begin
  const Instance = GetValueInstance(aIndex);
  if Assigned(Instance) then
    Instance.Assign(aValue);
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
    if not BoundsLower.Null and (BoundsLower.Value >= 0) then
    begin
      Result.NewValue := -1;
      IsValueWithinBounds(True, Result);
      Result.InvalidHintTitle := 'Negative Werte sind nicht zugelassen';
      Result.CustomInvalidHintSet := True;
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

procedure TIntegerEdit.EvaluateBounds(const aPartialInput: Boolean; var aValidationResult: TValidationResult<Int64>);
begin
  if aValidationResult.IsValid then
    Exit;
  if not aPartialInput then
    Exit;
  if aValidationResult.BoundaryCheckResult = TBoundaryCheckResult.ValueTooHigh then
    Exit;

  if aValidationResult.BoundaryCheckResult = TBoundaryCheckResult.ValueTooLow then
  begin
    if Sign(aValidationResult.NewValue) <> Sign(BoundsUpper.Value) then
      Exit;
  end;

  aValidationResult.IsValid := True;
end;

end.
