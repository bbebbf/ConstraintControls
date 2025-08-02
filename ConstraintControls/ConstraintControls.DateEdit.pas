unit ConstraintControls.DateEdit;

interface

uses System.Classes, System.SysUtils, ConstraintControls.ConstraintEdit;

type
  TDateEdit = class(TConstraintEdit<TDate>)
  strict private
    fFormatSettings: TFormatSettings;
  strict protected
    function GetValueText(const aValue: TDate): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<TDate>; override;
    function IsTextValid(const aText: string): TValidationResult<TDate>; override;
    function GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CompareValues(const aValue1, aValue2: TDate): Integer; override;
  published
    property Value: TDate read GetValue write SetValue;
    property NotSetValue: TDate read GetNotSetValue write SetNotSetValue;
    property RangeMinValue: TDate read GetRangeMinValue write SetRangeMinValue;
    property RangeMaxValue: TDate read GetRangeMaxValue write SetRangeMaxValue;
  end;

implementation

uses System.DateUtils, ConstraintControls.DateTools;

{ TDateEdit }

constructor TDateEdit.Create(AOwner: TComponent);
begin
  inherited;
  fFormatSettings := TFormatSettings.Create;
end;

destructor TDateEdit.Destroy;
begin
  fFormatSettings := default(TFormatSettings);
  inherited;
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

function TDateEdit.GetValueText(const aValue: TDate): string;
begin
  Result := FormatDateTime('ddddd', aValue);
end;

function TDateEdit.CompareValues(const aValue1, aValue2: TDate): Integer;
begin
  Result := CompareDate(aValue1, aValue2);
end;

function TDateEdit.IsInputValid(const aInputData: TInputValidationData): TValidationResult<TDate>;
begin
  Result := default(TValidationResult<TDate>);
  if TDateTools.InputTextMatchesDate(aInputData.TextToValidate, fFormatSettings) then
    Result.IsValid := True;
end;

function TDateEdit.IsTextValid(const aText: string): TValidationResult<TDate>;
begin
  Result := default(TValidationResult<TDate>);
  if TDateTools.TryToParseDate(aText, fFormatSettings, Result.NewValue) then
    Result.IsValid := True;
end;

end.
