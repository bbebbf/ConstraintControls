unit ConstraintControls.ConstraintEdit;

{$SCOPEDENUMS ON}

interface

uses Winapi.Messages, Vcl.Controls, Vcl.Forms, System.Classes, Vcl.StdCtrls;

type
  TInputValidationReason = (Undefined, KeyPressed, PastedFromClipboard, CutToClipboard, ClearSelection);

  TInputValidationData = record
  strict private
    fReason: TInputValidationReason;
    fNewChar: Char;
    fNewText: string;
    fTextBefore: string;
    fTextAfter: string;
    fTextToValidate: string;
    fTextToValidateGenerated: Boolean;
    function GetTextToValidate: string;
    procedure SetNewChar(const aValue: Char);
    procedure SetNewText(const aValue: string);
  public
    procedure SetControlData(const aEdit: TCustomEdit);
    property Reason: TInputValidationReason read fReason;
    property NewChar: Char read fNewChar write SetNewChar;
    property NewText: string read fNewText write SetNewText;
    property TextBefore: string read fTextBefore;
    property TextAfter: string read fTextAfter;
    property TextToValidate: string read GetTextToValidate;
  end;

  TValidationResult<T> = record
    NewValue: T;
    IsValid: Boolean;
    ValidationNotRequired: Boolean;
    InvalidHintTitle: string;
    InvalidHintDescription: string;
  end;

  TOnExitQueryValidation<T> = procedure(Sender: TObject; const aValidationResult: TValidationResult<T>;
    var aValidationRequired: Boolean) of object;

  TValidationDefaultMessages = record
    InvalidInputTitle: string;
    InvalidTextTitle: string;
    InvalidValueHint: string;
    ValueTooLowTitle: string;
    ValueTooLowHint: string;
    ValueTooHighTitle: string;
    ValueTooHighHint: string;
    ValueOutOfRangeHint: string;
  end;

  TGetValueText<T> = reference to function(const aValue: T): string;

  TValidationMessages<T> = class
  strict private
    fDefaultMessages: TValidationDefaultMessages;
    fGetValueText: TGetValueText<T>;
    function GetMessageString(const aPrimary, aSecondary: string): string;
    function GetFormattedMessage(const aMessage: string; const aValuePlaceholder: Char;
      const aValues: array of T): string;
  public
    constructor Create(const aDefaultMessages: TValidationDefaultMessages; const aGetValueText: TGetValueText<T>);
    function GetInvalidInputTitle(const aMessage: string): string;
    function GetInvalidTextTitle(const aMessage: string): string;
    function GetInvalidValueHint(const aMessage: string): string;
    function GetValueTooLowTitle(const aMessage: string): string;
    function GetValueTooLowHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMinValue: T): string;
    function GetValueTooHighTitle(const aMessage: string): string;
    function GetValueTooHighHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMaxValue: T): string;
    function GetValueOutOfRangeHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMinValue, aMaxValue: T): string;
  end;

  TConstraintEdit<T> = class(TCustomEdit)
  strict private
    fValue: T;
    fValueSet: Boolean;
    fNotSetValue: T;
    fRangeMinValue: T;
    fRangeMinValueSet: Boolean;
    fRangeMaxValue: T;
    fRangeMaxValueSet: Boolean;

    fMessageValuePlaceholder: Char;
    fMessageInvalidInputTitle: string;
    fMessageInvalidTextTitle: string;
    fMessageInvalidValueHint: string;
    fMessageValueTooLowTitle: string;
    fMessageValueTooLowHint: string;
    fMessageValueTooHighTitle: string;
    fMessageValueTooHighHint: string;
    fMessageValueOutOfRangeHint: string;

    fTextValidated: Boolean;
    fInvalidHint: TBalloonHint;

    fExitOnInvalidValue: Boolean;
    fOnExitQueryValidation: TOnExitQueryValidation<T>;

    fValidationMessages: TValidationMessages<T>;

    function GetInheritedText: string;
    procedure SetInheritedText(const aValue: string);

    procedure SetValueSet(const aValue: Boolean);
    procedure WMPaste(var Msg: TWMPaste); message WM_PASTE;
    procedure WMClear(var Msg: TWMClear); message WM_CLEAR;
    procedure WMCut(var Msg: TWMCut); message WM_CUT;
    procedure UpdateText;
    function NewInputValidationData(const aReason: TInputValidationReason): TInputValidationData;
    function IsInputValidInternal(const aInputData: TInputValidationData): TValidationResult<T>;
    function IsTextValidInternal(const aOnExit: Boolean): TValidationResult<T>;
    procedure ShowInvalidHint(const aValidationResult: TValidationResult<T>);
    procedure CreateValidationMessagesInstance;

    procedure SetInvalidInternal(var aValidationResult: TValidationResult<T>;
      const aPrimaryMsg, aSecondaryMsg: string; const aValues: TArray<T>);
  strict protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;

    function GetValueText(const aValue: T): string; virtual;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<T>; virtual;
    function IsTextValid(const aText: string): TValidationResult<T>; virtual;
    function GetValidationDefaultMessages: TValidationDefaultMessages; virtual;

    procedure SetInvalidInput(var aValidationResult: TValidationResult<T>;
      const aPrimaryMsg, aSecondaryMsg: string; const aValues: TArray<T>);

    function IsValueWithinBounds(const aValue: T; const aTestMaxOnly: Boolean;
      var aValidationResult: TValidationResult<T>): Boolean;
    procedure  DoOnExitQueryValidation(const aValidationResult: TValidationResult<T>;
      var aValidationRequired: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetValue: T;
    procedure Clear; override;
    procedure SetValue(const aValue: T);
    function GetNotSetValue: T;
    procedure SetNotSetValue(const aValue: T);
    function GetRangeMinValue: T;
    procedure SetRangeMinValue(const aValue: T);
    procedure SetRangeMinValueSet(const aValue: Boolean);
    function GetRangeMaxValue: T;
    procedure SetRangeMaxValue(const aValue: T);
    procedure SetRangeMaxValueSet(const aValue: Boolean);
    procedure SetMessageValuePlaceholder(const aValue: Char);
    function CompareValues(const aValue1, aValue2: T): Integer; virtual;

    property Text: string read GetInheritedText;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DoubleBufferedMode;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property CanUndoSelText;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TextHint;
    property Touch;
    property Visible;
    property StyleElements;
    property StyleName;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

    property ValueSet: Boolean read fValueSet write SetValueSet default False;
    property ExitOnInvalidValue: Boolean read fExitOnInvalidValue write fExitOnInvalidValue default False;
    property OnExitQueryValidation: TOnExitQueryValidation<T> read fOnExitQueryValidation write fOnExitQueryValidation;
    property RangeMinValueSet: Boolean read fRangeMinValueSet write SetRangeMinValueSet default False;
    property RangeMaxValueSet: Boolean read fRangeMaxValueSet write SetRangeMaxValueSet default False;

    property MessageValuePlaceholder: Char read fMessageValuePlaceholder write SetMessageValuePlaceholder default '#';
    property MessageInvalidInputTitle: string read fMessageInvalidInputTitle write fMessageInvalidInputTitle;
    property MessageInvalidTextTitle: string read fMessageInvalidTextTitle write fMessageInvalidTextTitle;
    property MessageInvalidValueHint: string read fMessageInvalidValueHint write fMessageInvalidValueHint;
    property MessageValueTooLowTitle: string read fMessageValueTooLowTitle write fMessageValueTooLowTitle;
    property MessageValueTooLowHint: string read fMessageValueTooLowHint write fMessageValueTooLowHint;
    property MessageValueTooHighTitle: string read fMessageValueTooHighTitle write fMessageValueTooHighTitle;
    property MessageValueTooHighHint: string read fMessageValueTooHighHint write fMessageValueTooHighHint;
    property MessageValueOutOfRangeHint: string read fMessageValueOutOfRangeHint write fMessageValueOutOfRangeHint;
  end;

const
  Char_Space: Char = #32;
  Char_Backspace: Char = #8;

implementation

uses System.SysUtils, Vcl.Clipbrd;

{ TConstraintEdit<T> }

constructor TConstraintEdit<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMessageValuePlaceholder := '#'
end;

procedure TConstraintEdit<T>.CreateValidationMessagesInstance;
begin
  if Assigned(fValidationMessages) then
    Exit;
  fValidationMessages := TValidationMessages<T>.Create(GetValidationDefaultMessages, GetValueText);
end;

destructor TConstraintEdit<T>.Destroy;
begin
  fInvalidHint.Free;
  fValidationMessages.Free;
  inherited;
end;

procedure TConstraintEdit<T>.Clear;
begin
  inherited;
  fValue := fNotSetValue;
  fValueSet := False;
end;

function TConstraintEdit<T>.GetInheritedText: string;
begin
  Result := inherited Text;
end;

function TConstraintEdit<T>.GetNotSetValue: T;
begin
  Result := fNotSetValue;
end;

function TConstraintEdit<T>.GetRangeMaxValue: T;
begin
  Result := fRangeMaxValue;
end;

function TConstraintEdit<T>.GetRangeMinValue: T;
begin
  Result := fRangeMinValue;
end;

procedure TConstraintEdit<T>.SetInheritedText(const aValue: string);
begin
  inherited Text := aValue;
end;

procedure TConstraintEdit<T>.SetInvalidInput(var aValidationResult: TValidationResult<T>; const aPrimaryMsg,
  aSecondaryMsg: string; const aValues: TArray<T>);
begin

end;

procedure TConstraintEdit<T>.SetInvalidInternal(var aValidationResult: TValidationResult<T>; const aPrimaryMsg,
  aSecondaryMsg: string; const aValues: TArray<T>);
begin

end;

procedure TConstraintEdit<T>.SetMessageValuePlaceholder(const aValue: Char);
begin
  if aValue < #32 then
    fMessageValuePlaceholder := '#'
  else
    fMessageValuePlaceholder := aValue;
end;

procedure TConstraintEdit<T>.SetNotSetValue(const aValue: T);
begin
  fNotSetValue := aValue;
  if not fValueSet then
    fValue := fNotSetValue;
end;

procedure TConstraintEdit<T>.SetRangeMaxValue(const aValue: T);
begin
  fRangeMaxValue := aValue;
  fRangeMaxValueSet := True;
  if CompareValues(fRangeMaxValue, fRangeMinValue) < 0 then
    SetRangeMinValue(fRangeMaxValue);
end;

procedure TConstraintEdit<T>.SetRangeMaxValueSet(const aValue: Boolean);
begin
  if fRangeMaxValueSet = aValue then
    Exit;
  fRangeMaxValueSet := aValue;
  if not fRangeMaxValueSet then
    fRangeMaxValue := default(T);
end;

procedure TConstraintEdit<T>.SetRangeMinValue(const aValue: T);
begin
  fRangeMinValue := aValue;
  fRangeMinValueSet := True;
  if CompareValues(fRangeMinValue,  fRangeMaxValue) > 0 then
    SetRangeMaxValue(fRangeMinValue);
end;

procedure TConstraintEdit<T>.SetRangeMinValueSet(const aValue: Boolean);
begin
  if fRangeMinValueSet = aValue then
    Exit;
  fRangeMinValueSet := aValue;
  if not fRangeMinValueSet then
    fRangeMinValue := default(T);
end;

function TConstraintEdit<T>.GetValidationDefaultMessages: TValidationDefaultMessages;
begin
  Result := default(TValidationDefaultMessages);
end;

function TConstraintEdit<T>.GetValue: T;
begin
  var lValidationResult := IsTextValidInternal(False);
  if lValidationResult.IsValid then
  begin
    Result := fValue;
  end
  else
  begin
    Result := fNotSetValue;
  end;
end;

function TConstraintEdit<T>.CompareValues(const aValue1, aValue2: T): Integer;
begin
  Result := 0;
end;

function TConstraintEdit<T>.GetValueText(const aValue: T): string;
begin
  Result := '';
end;

procedure TConstraintEdit<T>.SetValue(const aValue: T);
begin
  fValue := aValue;
  fValueSet := True;
  UpdateText;
end;

procedure TConstraintEdit<T>.SetValueSet(const aValue: Boolean);
begin
  fValueSet := aValue;
  if not fValueSet then
  begin
    fValue := fNotSetValue;
  end;
  UpdateText;
end;

procedure TConstraintEdit<T>.KeyPress(var Key: Char);
begin
  inherited;
  if (Key < Char_Space) and (Key <> Char_Backspace) then
    Exit;

  var lInputValidationData := NewInputValidationData(TInputValidationReason.KeyPressed);
  lInputValidationData.NewChar := Key;
  var lValidationResult := IsInputValidInternal(lInputValidationData);
  if lValidationResult.IsValid then
  begin
    fTextValidated := False;
  end
  else
  begin
    ShowInvalidHint(lValidationResult);
    Key := #0;
  end;
end;

procedure TConstraintEdit<T>.WMClear(var Msg: TWMClear);
begin
  var lInputValidationData := NewInputValidationData(TInputValidationReason.ClearSelection);
  var lValidationResult := IsInputValidInternal(lInputValidationData);
  if lValidationResult.IsValid then
  begin
    fTextValidated := False;
    inherited;
  end
  else
  begin
    ShowInvalidHint(lValidationResult);
  end;
end;

procedure TConstraintEdit<T>.WMCut(var Msg: TWMCut);
begin
  var lInputValidationData := NewInputValidationData(TInputValidationReason.CutToClipboard);
  var lValidationResult := IsInputValidInternal(lInputValidationData);
  if lValidationResult.IsValid then
  begin
    fTextValidated := False;
    inherited;
  end
  else
  begin
    ShowInvalidHint(lValidationResult);
  end;
end;

procedure TConstraintEdit<T>.WMPaste(var Msg: TWMPaste);
begin
  var lInputValidationData := NewInputValidationData(TInputValidationReason.PastedFromClipboard);
  lInputValidationData.NewText := Clipboard.AsText;
  var lValidationResult := IsInputValidInternal(lInputValidationData);
  if lValidationResult.IsValid then
  begin
    fTextValidated := False;
    inherited;
  end
  else
  begin
    ShowInvalidHint(lValidationResult);
  end;
end;

procedure TConstraintEdit<T>.DoExit;
begin
  var lExitOk := fExitOnInvalidValue;
  var lValidationResult := IsTextValidInternal(True);
  if lValidationResult.IsValid then
  begin
    lExitOk := True;
  end;
  if not lExitOk then
  begin
    if lValidationResult.ValidationNotRequired then
    begin
      lExitOk := True;
    end;
  end;
  if lExitOk then
  begin
    UpdateText;
    if Assigned(fInvalidHint) then
      fInvalidHint.HideHint;
    inherited;
  end
  else
  begin
    ShowInvalidHint(lValidationResult);
    System.SysUtils.Abort;
  end;
end;

procedure TConstraintEdit<T>.DoOnExitQueryValidation(const aValidationResult: TValidationResult<T>;
  var aValidationRequired: Boolean);
begin
  if Assigned(fOnExitQueryValidation) then
    fOnExitQueryValidation(Self, aValidationResult, aValidationRequired);
end;

procedure TConstraintEdit<T>.UpdateText;
begin
  if fValueSet then
    SetInheritedText(GetValueText(fValue))
  else
    SetInheritedText('');
end;

function TConstraintEdit<T>.NewInputValidationData(const aReason: TInputValidationReason): TInputValidationData;
begin
  Result := default(TInputValidationData);
  Result.SetControlData(Self);
end;

function TConstraintEdit<T>.IsInputValid(const aInputData: TInputValidationData): TValidationResult<T>;
begin
  Result := default(TValidationResult<T>);
end;

function TConstraintEdit<T>.IsInputValidInternal(const aInputData: TInputValidationData): TValidationResult<T>;
begin
  Result := default(TValidationResult<T>);
  CreateValidationMessagesInstance;
  if Length(aInputData.TextToValidate) = 0 then
  begin
    Result.IsValid := True;
    Exit;
  end;
  Result := IsInputValid(aInputData);
  if Result.IsValid then
  begin
    IsValueWithinBounds(Result.NewValue, True, Result);
  end
  else
  begin
    Result.InvalidHintTitle := fValidationMessages.GetInvalidInputTitle(fMessageInvalidInputTitle);
    Result.InvalidHintDescription := fValidationMessages.GetInvalidValueHint(fMessageInvalidValueHint);
  end;
end;

function TConstraintEdit<T>.IsTextValid(const aText: string): TValidationResult<T>;
begin
  Result := default(TValidationResult<T>);
end;

function TConstraintEdit<T>.IsTextValidInternal(const aOnExit: Boolean): TValidationResult<T>;
begin
  CreateValidationMessagesInstance;
  var lValidationResult := default(TValidationResult<T>);
  if fTextValidated then
  begin
    lValidationResult.IsValid := True;
  end
  else
  begin
    var lValueValidated := False;
    if Length(Text) > 0 then
    begin
      lValidationResult := IsTextValid(Text);
      if lValidationResult.IsValid then
      begin
        lValueValidated := IsValueWithinBounds(lValidationResult.NewValue, False, lValidationResult);
      end
      else
      begin
        lValidationResult.InvalidHintTitle := fValidationMessages.GetInvalidTextTitle(fMessageInvalidTextTitle);
        lValidationResult.InvalidHintDescription := fValidationMessages.GetInvalidValueHint(fMessageInvalidValueHint);
      end;
    end
    else
    begin
      lValidationResult.ValidationNotRequired := True;
    end;
    if lValueValidated then
    begin
      fValue := lValidationResult.NewValue;
      fValueSet := True;
      fTextValidated := True;
    end
    else
    begin
      fValue := fNotSetValue;
      fValueSet := False;
    end;
    if aOnExit and not lValidationResult.ValidationNotRequired then
    begin
      var lValidationRequired := True;
      DoOnExitQueryValidation(lValidationResult, lValidationRequired);
      if not lValidationRequired then
      begin
        lValidationResult.ValidationNotRequired := True;
      end;
    end;
  end;
  Result := lValidationResult;
end;

function TConstraintEdit<T>.IsValueWithinBounds(const aValue: T; const aTestMaxOnly: Boolean;
  var aValidationResult: TValidationResult<T>): Boolean;
begin
  CreateValidationMessagesInstance;
  if not aTestMaxOnly and fRangeMinValueSet and (CompareValues(aValue, fRangeMinValue) < 0) then
  begin
    aValidationResult.InvalidHintTitle := fValidationMessages.GetValueTooLowTitle(fMessageValueTooLowTitle);
    aValidationResult.IsValid := False;
  end;
  if fRangeMaxValueSet and (CompareValues(aValue, fRangeMaxValue) > 0) then
  begin
    aValidationResult.InvalidHintTitle := fValidationMessages.GetValueTooHighTitle(fMessageValueTooHighTitle);
    aValidationResult.IsValid := False;
  end;
  if not aValidationResult.IsValid then
  begin
    if fRangeMinValueSet and fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        fValidationMessages.GetValueOutOfRangeHint(fMessageValueOutOfRangeHint, fMessageValuePlaceholder, fRangeMinValue, fRangeMaxValue);
    end
    else if fRangeMinValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        fValidationMessages.GetValueTooLowHint(fMessageValueTooLowHint, fMessageValuePlaceholder, fRangeMinValue);
    end
    else if fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription :=
        fValidationMessages.GetValueTooHighHint(fMessageValueTooHighHint, fMessageValuePlaceholder, fRangeMaxValue);
    end;
  end;
  Result := aValidationResult.IsValid;
end;

procedure TConstraintEdit<T>.ShowInvalidHint(const aValidationResult: TValidationResult<T>);
begin
  if aValidationResult.IsValid then
    Exit;
  if Length(aValidationResult.InvalidHintDescription) = 0 then
    Exit;

  if not Assigned(fInvalidHint) then
  begin
    fInvalidHint := TBalloonHint.Create(Self);
    fInvalidHint.HideAfter := 1200;
  end;
  fInvalidHint.Title := aValidationResult.InvalidHintTitle;
  fInvalidHint.Description := aValidationResult.InvalidHintDescription;
  fInvalidHint.ShowHint(Self);
end;

{ TInputValidationData }

function TInputValidationData.GetTextToValidate: string;
begin
  if fTextToValidateGenerated then
    Exit(fTextToValidate);

  if NewChar = #0 then
    Result := TextBefore + NewText + TextAfter
  else if NewChar = Char_Backspace then
    Result := TextBefore + TextAfter
  else
    Result := TextBefore + NewChar + TextAfter;

  fTextToValidateGenerated := True;
  fTextToValidate := Result;
end;

procedure TInputValidationData.SetControlData(const aEdit: TCustomEdit);
begin
  fTextBefore := Copy(aEdit.Text, 1, aEdit.SelStart);
  fTextAfter := Copy(aEdit.Text, aEdit.SelStart + aEdit.SelLength + 1, Length(aEdit.Text));
  fTextToValidateGenerated := False;
end;

procedure TInputValidationData.SetNewChar(const aValue: Char);
begin
  fNewChar := aValue;
  fTextToValidateGenerated := False;
end;

procedure TInputValidationData.SetNewText(const aValue: string);
begin
  fNewText := aValue;
  fTextToValidateGenerated := False;
end;

{ TValidationMessages<T> }

constructor TValidationMessages<T>.Create(const aDefaultMessages: TValidationDefaultMessages;
  const aGetValueText: TGetValueText<T>);
begin
  inherited Create;
  fDefaultMessages := aDefaultMessages;
  fGetValueText := aGetValueText;
end;

function TValidationMessages<T>.GetInvalidInputTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, fDefaultMessages.InvalidInputTitle);
end;

function TValidationMessages<T>.GetInvalidTextTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, fDefaultMessages.InvalidTextTitle);
end;

function TValidationMessages<T>.GetInvalidValueHint(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, fDefaultMessages.InvalidValueHint);
end;

function TValidationMessages<T>.GetValueOutOfRangeHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMinValue, aMaxValue: T): string;
begin
  var lMessage := GetMessageString(aMessage, fDefaultMessages.ValueOutOfRangeHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMinValue, aMaxValue]);
end;

function TValidationMessages<T>.GetValueTooHighHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMaxValue: T): string;
begin
  var lMessage := GetMessageString(aMessage, fDefaultMessages.ValueTooHighHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMaxValue]);
end;

function TValidationMessages<T>.GetValueTooHighTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, fDefaultMessages.ValueTooHighTitle);
end;

function TValidationMessages<T>.GetValueTooLowHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMinValue: T): string;
begin
  var lMessage := GetMessageString(aMessage, fDefaultMessages.ValueTooLowHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMinValue]);
end;

function TValidationMessages<T>.GetValueTooLowTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, fDefaultMessages.ValueTooLowTitle);
end;

function TValidationMessages<T>.GetFormattedMessage(const aMessage: string;
  const aValuePlaceholder: Char; const aValues: array of T): string;
begin
  var lMessageParts := aMessage.Split([aValuePlaceholder]);
  if Length(lMessageParts) = 0 then
    Exit('');
  Result := lMessageParts[0];
  for var i := 1 to High(lMessageParts) do
  begin
    if i - 1 <= High(aValues) then
      Result := Result + fGetValueText(aValues[i - 1])
    else
      Result := Result + aValuePlaceholder;
    Result := Result + lMessageParts[i];
  end;
end;

function TValidationMessages<T>.GetMessageString(const aPrimary, aSecondary: string): string;
begin
  if Length(aPrimary) > 0 then
    Result := aPrimary
  else
    Result := aSecondary;
end;

end.
