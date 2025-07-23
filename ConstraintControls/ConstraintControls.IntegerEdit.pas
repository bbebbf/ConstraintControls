unit ConstraintControls.IntegerEdit;

interface

uses System.Classes, ConstraintControls.ConstraintEdit;

type
  TIntegerEdit = class(TConstraintEdit<Int64>)
  strict protected
    function GetValueText(const aValue: Int64): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<Int64>; override;
    function IsTextValid(const aText: string): TValidationResult<Int64>; override;
    function GetValidationDefaultMessages: TValidationDefaultMessages; override;
  public
    function CompareValues(const aValue1, aValue2: Int64): Integer; override;
  published
    property Value: Int64 read GetValue write SetValue default 0;
    property NotSetValue: Int64 read GetNotSetValue write SetNotSetValue default 0;
    property RangeMinValue: Int64 read GetRangeMinValue write SetRangeMinValue default 0;
    property RangeMaxValue: Int64 read GetRangeMaxValue write SetRangeMaxValue default 0;
  end;

implementation

uses System.SysUtils;

{ TIntegerEdit }

function TIntegerEdit.GetValidationDefaultMessages: TValidationDefaultMessages;
begin
  Result := default(TValidationDefaultMessages);
  Result.InvalidInputTitle := 'Hinweis';
  Result.InvalidTextTitle := 'Unzulässig';
  Result.InvalidValueHint := 'Es sind nur Ziffern erlaubt.';
  Result.ValueTooLowTitle := 'Zu niedrig';
  Result.ValueTooLowHint := 'Zahl muss mindestens %d sein.';
  Result.ValueTooHighTitle := 'Zu hoch';
  Result.ValueTooHighHint := 'Zahl darf höchstens %d sein.';
  Result.ValueOutOfRangeHint := 'Zahl muss zwischen %d und %d liegen.';
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
    if RangeMinValueSet and (RangeMinValue >= 0) then
    begin
      IsValueWithinBounds(-1, False, Result);
      Exit;
    end;
  end;
  if not TryStrToInt64(aInputData.TextToValidate, Result.NewValue) then
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
