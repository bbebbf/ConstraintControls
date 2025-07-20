unit ConstraintControls.IntegerEdit;

interface

uses System.Classes, ConstraintControls.ConstraintEdit;

type
  TIntegerEdit = class(TConstraintEdit<Int64>)
  strict private
    fRangeMinValue: Int64;
    fRangeMinValueSet: Boolean;
    fRangeMaxValue: Int64;
    fRangeMaxValueSet: Boolean;
    fMessageValuePlaceholder: Char;
    fMessageInvalidInputTitle: string;
    fMessageInvalidInputNegativeNumbers: string;
    fMessageInvalidTextTitle: string;
    fMessageInvalidOnlyNumbersAllowed: string;
    fMessageValueTooLowTitle: string;
    fMessageValueTooLowHint: string;
    fMessageValueTooHighTitle: string;
    fMessageValueTooHighHint: string;
    fMessageValueOutOfRangeHint: string;

    procedure SetRangeMinValue(const aValue: Int64);
    procedure SetRangeMinValueSet(const aValue: Boolean);
    procedure SetRangeMaxValue(const aValue: Int64);
    procedure SetRangeMaxValueSet(const aValue: Boolean);
    procedure SetMessageValuePlaceholder(const aValue: Char);

    function IsValueWithinBounds(const aValue: Int64; const aTestMaxOnly: Boolean;
      var aValidationResult: TValidationResult): Boolean;
  strict protected
    function GetValueText(const aValue: Int64): string; override;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult; override;
    function IsTextValid(const aText: string; out aValue: Int64): TValidationResult; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Value: Int64 read GetValue write SetValue default 0;
    property NotSetValue: Int64 read GetNotSetValue write SetNotSetValue default 0;
    property RangeMinValue: Int64 read fRangeMinValue write SetRangeMinValue default 0;
    property RangeMinValueSet: Boolean read fRangeMinValueSet write SetRangeMinValueSet default False;
    property RangeMaxValue: Int64 read fRangeMaxValue write SetRangeMaxValue default 0;
    property RangeMaxValueSet: Boolean read fRangeMaxValueSet write SetRangeMaxValueSet default False;
    property MessageValuePlaceholder: Char read fMessageValuePlaceholder write SetMessageValuePlaceholder default '#';
    property MessageInvalidInputTitle: string read fMessageInvalidInputTitle write fMessageInvalidInputTitle;
    property MessageInvalidInputNegativeNumbers: string read fMessageInvalidInputNegativeNumbers write fMessageInvalidInputNegativeNumbers;
    property MessageInvalidTextTitle: string read fMessageInvalidTextTitle write fMessageInvalidTextTitle;
    property MessageInvalidOnlyNumbersAllowed: string read fMessageInvalidOnlyNumbersAllowed write fMessageInvalidOnlyNumbersAllowed;
    property MessageValueTooLowTitle: string read fMessageValueTooLowTitle write fMessageValueTooLowTitle;
    property MessageValueTooLowHint: string read fMessageValueTooLowHint write fMessageValueTooLowHint;
    property MessageValueTooHighTitle: string read fMessageValueTooHighTitle write fMessageValueTooHighTitle;
    property MessageValueTooHighHint: string read fMessageValueTooHighHint write fMessageValueTooHighHint;
    property MessageValueOutOfRangeHint: string read fMessageValueOutOfRangeHint write fMessageValueOutOfRangeHint;
  end;

implementation

uses System.SysUtils, ConstraintControls.IntegerEdit.Resources;

{ TIntegerEdit }

constructor TIntegerEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMessageValuePlaceholder := '#';
end;

procedure TIntegerEdit.SetMessageValuePlaceholder(const aValue: Char);
begin
  if aValue < #32 then
    fMessageValuePlaceholder := '#'
  else
    fMessageValuePlaceholder := aValue;
end;

procedure TIntegerEdit.SetRangeMaxValue(const aValue: Int64);
begin
  fRangeMaxValue := aValue;
  fRangeMaxValueSet := True;
  if fRangeMaxValue < RangeMinValue then
    RangeMinValue := fRangeMaxValue;
end;

procedure TIntegerEdit.SetRangeMaxValueSet(const aValue: Boolean);
begin
  if fRangeMaxValueSet = aValue then
    Exit;
  fRangeMaxValueSet := aValue;
  if not fRangeMaxValueSet then
    fRangeMaxValue := 0;
end;

procedure TIntegerEdit.SetRangeMinValue(const aValue: Int64);
begin
  fRangeMinValue := aValue;
  fRangeMinValueSet := True;
  if fRangeMinValue > RangeMaxValue then
    RangeMaxValue := fRangeMinValue;
end;

procedure TIntegerEdit.SetRangeMinValueSet(const aValue: Boolean);
begin
  if fRangeMinValueSet = aValue then
    Exit;
  fRangeMinValueSet := aValue;
  if not fRangeMinValueSet then
    fRangeMinValue := 0;
end;

function TIntegerEdit.GetValueText(const aValue: Int64): string;
begin
  Result := IntToStr(aValue);
end;

function TIntegerEdit.IsInputValid(const aInputData: TInputValidationData): TValidationResult;
begin
  Result := default(TValidationResult);
  if CompareStr(aInputData.TextToValidate, '-') = 0 then
  begin
    if fRangeMinValueSet and (fRangeMinValue >= 0) then
    begin
      IsValueWithinBounds(-1, False, Result);
      Exit;
    end;
  end;

  var lNewValue: Int64;
  if not TryStrToInt64(aInputData.TextToValidate, lNewValue) then
  begin
    Result.InvalidHintTitle := TIntegerEditResourcesDefaultMessages.GetInvalidInputTitle(fMessageInvalidInputTitle);
    Result.InvalidHintDescription := TIntegerEditResourcesDefaultMessages.GetInvalidOnlyNumbersAllowed(fMessageInvalidOnlyNumbersAllowed);
    Exit;
  end;
  if not IsValueWithinBounds(lNewValue, True, Result) then
  begin
    Exit;
  end;
  Result.IsValid := True;
end;

function TIntegerEdit.IsTextValid(const aText: string; out aValue: Int64): TValidationResult;
begin
  Result := default(TValidationResult);
  if not TryStrToInt64(aText, aValue) then
  begin
    Result.InvalidHintTitle := TIntegerEditResourcesDefaultMessages.GetInvalidTextTitle(fMessageInvalidTextTitle);
    Result.InvalidHintDescription := TIntegerEditResourcesDefaultMessages.GetInvalidOnlyNumbersAllowed(fMessageInvalidOnlyNumbersAllowed);
    Exit;
  end;
  if not IsValueWithinBounds(aValue, False, Result) then
  begin
    Exit;
  end;
  Result.IsValid := True;
end;

function TIntegerEdit.IsValueWithinBounds(const aValue: Int64; const aTestMaxOnly: Boolean;
  var aValidationResult: TValidationResult): Boolean;
begin
  aValidationResult.IsValid := True;
  if not aTestMaxOnly and fRangeMinValueSet and (aValue < fRangeMinValue) then
  begin
    aValidationResult.InvalidHintTitle := TIntegerEditResourcesDefaultMessages.GetValueTooLowTitle(fMessageValueTooLowTitle);
    aValidationResult.IsValid := False;
  end;
  if fRangeMaxValueSet and (aValue > fRangeMaxValue) then
  begin
    aValidationResult.InvalidHintTitle := TIntegerEditResourcesDefaultMessages.GetValueTooHighTitle(fMessageValueTooHighTitle);
    aValidationResult.IsValid := False;
  end;
  if not aValidationResult.IsValid then
  begin
    if fRangeMinValueSet and fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        TIntegerEditResourcesDefaultMessages.GetValueOutOfRangeHint(fMessageValueOutOfRangeHint, fMessageValuePlaceholder, fRangeMinValue, fRangeMaxValue);
    end
    else if fRangeMinValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        TIntegerEditResourcesDefaultMessages.GetValueTooLowHint(fMessageValueTooLowHint, fMessageValuePlaceholder, fRangeMinValue);
    end
    else if fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        TIntegerEditResourcesDefaultMessages.GetValueTooHighHint(fMessageValueTooHighHint, fMessageValuePlaceholder, fRangeMaxValue);
    end;
  end;
  Result := aValidationResult.IsValid;
end;

end.
