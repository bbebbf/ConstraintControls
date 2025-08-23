unit ConstraintControls.DateEdit;

interface

uses System.Classes, System.SysUtils, ConstraintControls.ConstraintEdit, SimpleDate;

type
  TDateEditValue = class(TConstraintNullableValue<TSimpleDate>)
  strict private
    function GetDay: TDayRange;
    function GetMonth: TMonthRange;
    function GetYear: Word;
    procedure SetDay(const aValue: TDayRange);
    procedure SetMonth(const aValue: TMonthRange);
    procedure SetYear(const aValue: Word);
  published
    property ValueYear: Word read GetYear write SetYear default 0;
    property ValueMonth: TMonthRange read GetMonth write SetMonth default 0;
    property ValueDay: TDayRange read GetDay write SetDay default 0;
  end;

  TDateEdit = class(TConstraintEdit<TSimpleDate>)
  strict private
    fFormatSettings: TFormatSettings;
    fShortDateFormatWithoutYear: string;
    fOptionalYear: Boolean;
    function GetValue(const aIndex: TConstraintEditValueType): TDateEditValue;
    procedure SetValue(const aIndex: TConstraintEditValueType; const aValue: TDateEditValue);
  strict protected
    function CreateValueInstance: TConstraintNullableValue<TSimpleDate>; override;
    function GetValueText(const aValue: TSimpleDate): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<TSimpleDate>; override;
    function IsTextValid(const aText: string): TValidationResult<TSimpleDate>; override;
    function GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage; override;
  public
    constructor Create(AOwner: TComponent); override;
    function CompareValues(const aValue1, aValue2: TSimpleDate): Integer; override;
  published
    property OptionalYear: Boolean read fOptionalYear write fOptionalYear default False;
    property Value: TDateEditValue index TConstraintEditValueType.vtValue read GetValue write SetValue;
    property BoundsLower: TDateEditValue index TConstraintEditValueType.vtBoundsLower read GetValue write SetValue;
    property BoundsUpper: TDateEditValue index TConstraintEditValueType.vtBoundsUpper read GetValue write SetValue;
  end;

implementation

uses System.DateUtils, ConstraintControls.DateTools;

{ TDateEdit }

constructor TDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fFormatSettings := TFormatSettings.Create;

  fShortDateFormatWithoutYear := StringReplace(fFormatSettings.ShortDateFormat, 'y', '', [TReplaceFlag.rfReplaceAll]);
  fShortDateFormatWithoutYear := StringReplace(fShortDateFormatWithoutYear, '//', '/', [TReplaceFlag.rfReplaceAll]);
end;

function TDateEdit.GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage;
begin
  Result := default(TValidationMessage);
  Result.ValuePlaceholder := '#';
  case aKind of
    TValidationMessageKind.InvalidInputTitle:
      Result.ValidationMessage := 'Hinweis';
    TValidationMessageKind.InvalidTextTitle:
      Result.ValidationMessage := 'Unzulässig';
    TValidationMessageKind.InvalidValueHint:
      Result.ValidationMessage := '"#t" ist kein gültiges Datum.';
    TValidationMessageKind.ValueTooLowTitle:
      Result.ValidationMessage := 'Zu niedrig';
    TValidationMessageKind.ValueTooLowHint:
      Result.ValidationMessage := 'Das Datum muss mindestens #mi sein.';
    TValidationMessageKind.ValueTooHighTitle:
      Result.ValidationMessage := 'Zu hoch';
    TValidationMessageKind.ValueTooHighHint:
      Result.ValidationMessage := 'Das Datum darf höchstens #ma sein.';
    TValidationMessageKind.ValueOutOfRangeHint:
      Result.ValidationMessage := 'Das Datum muss zwischen #mi und #ma liegen.';
  end;
end;

function TDateEdit.CreateValueInstance: TConstraintNullableValue<TSimpleDate>;
begin
  Result := TDateEditValue.Create(Self);
end;

function TDateEdit.GetValue(const aIndex: TConstraintEditValueType): TDateEditValue;
begin
  Result := GetValueInstance(aIndex) as TDateEditValue;
end;

procedure TDateEdit.SetValue(const aIndex: TConstraintEditValueType; const aValue: TDateEditValue);
begin
  GetValueInstance(aIndex).Assign(aValue);
end;

function TDateEdit.GetValueText(const aValue: TSimpleDate): string;
begin
  if aValue.Year = 0 then
  begin
    var lDate: TDateTime;
    if TryEncodeDate(2000, aValue.Month, aValue.Day, lDate) then
    begin
      Result := FormatDateTime(fShortDateFormatWithoutYear, lDate, fFormatSettings);
    end
    else
    begin
      Result := '???';
    end;
  end
  else
  begin
    Result := FormatDateTime('ddddd', aValue.AsDate, fFormatSettings);
  end;
end;

function TDateEdit.CompareValues(const aValue1, aValue2: TSimpleDate): Integer;
begin
  Result := 0;
  if aValue1 < aValue2 then
    Exit(-1);
  if aValue1 > aValue2 then
    Exit(+1);
end;

function TDateEdit.IsInputValid(const aInputData: TInputValidationData): TValidationResult<TSimpleDate>;
begin
  Result := default(TValidationResult<TSimpleDate>);
  if TDateTools.InputTextMatchesDate(aInputData.TextToValidate, fOptionalYear, fFormatSettings) then
    Result.IsValid := True;
end;

function TDateEdit.IsTextValid(const aText: string): TValidationResult<TSimpleDate>;
begin
  Result := default(TValidationResult<TSimpleDate>);
  if TDateTools.TryToParseSimpleDate(aText, fOptionalYear, fFormatSettings, Result.NewValue) then
  begin
    Result.IsValid := True;
  end;
end;

{ TDateEditValue }

function TDateEditValue.GetDay: TDayRange;
begin
  Result := fValue.Day;
end;

function TDateEditValue.GetMonth: TMonthRange;
begin
  Result := fValue.Month;
end;

function TDateEditValue.GetYear: Word;
begin
  Result := fValue.Year;
end;

procedure TDateEditValue.SetDay(const aValue: TDayRange);
begin
  if (fValue.Year <> aValue) and not fNull then
    Exit;
  fValue.Year := aValue;
  fNull := False;
  fValidated := True;
  DoValueChanged;
end;

procedure TDateEditValue.SetMonth(const aValue: TMonthRange);
begin
  if (fValue.Month <> aValue) and not fNull then
    Exit;
  fValue.Month := aValue;
  fNull := False;
  fValidated := True;
  DoValueChanged;
end;

procedure TDateEditValue.SetYear(const aValue: Word);
begin
  if (fValue.Day <> aValue) and not fNull then
    Exit;
  fValue.Day := aValue;
  fNull := False;
  fValidated := True;
  DoValueChanged;
end;

end.

