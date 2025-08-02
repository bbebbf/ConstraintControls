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
    fSelStart: Integer;
    fSelLength: Integer;
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
    property SelStart: Integer read fSelStart;
    property SelLength: Integer read fSelLength;
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

  TValidationMessageKind = (InvalidInputTitle,
    InvalidTextTitle,
    InvalidValueHint,
    ValueTooLowTitle,
    ValueTooLowHint,
    ValueTooHighTitle,
    ValueTooHighHint,
    ValueOutOfRangeHint);

  TValidationMessages = record
    Messages: Array[TValidationMessageKind] of string;
    ValuePlaceholder: Char;
  end;

  TValidationMessage = record
    ValidationMessage: string;
    ValuePlaceholder: Char;
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

    fUserValidationMessages: TValidationMessages;

    fTextValidated: Boolean;
    fInvalidHint: TBalloonHint;

    fExitOnInvalidValue: Boolean;
    fOnExitQueryValidation: TOnExitQueryValidation<T>;

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

    function ValuesReplaced(const aMessagePart: string;
      const aCurrentText: string; aCurrentValue: T): string;
  strict protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;

    function GetValueText(const aValue: T): string; virtual;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult<T>; virtual;
    function IsTextValid(const aText: string): TValidationResult<T>; virtual;
    function GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage; virtual;

    function IsValueWithinBounds(const aValue: T; const aTestMaxOnly: Boolean;
      var aValidationResult: TValidationResult<T>): Boolean;
    procedure  DoOnExitQueryValidation(const aValidationResult: TValidationResult<T>;
      var aValidationRequired: Boolean);

    function GetFormattedMessage(const aMessage: string; const aValuePlaceholder: Char;
      const aCurrentText: string; aCurrentValue: T): string;
    function GetValidationMessage(const aMessageKind: TValidationMessageKind;
      const aCurrentText: string; aCurrentValue: T): string;
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

    property MessageValuePlaceholder: Char
      read fUserValidationMessages.ValuePlaceholder
      write SetMessageValuePlaceholder default '#';
    property MessageInvalidInputTitle: string
      read fUserValidationMessages.Messages[TValidationMessageKind.InvalidInputTitle]
      write fUserValidationMessages.Messages[TValidationMessageKind.InvalidInputTitle];
    property MessageInvalidTextTitle: string
      read fUserValidationMessages.Messages[TValidationMessageKind.InvalidTextTitle]
      write fUserValidationMessages.Messages[TValidationMessageKind.InvalidTextTitle];
    property MessageInvalidValueHint: string
      read fUserValidationMessages.Messages[TValidationMessageKind.InvalidValueHint]
      write fUserValidationMessages.Messages[TValidationMessageKind.InvalidValueHint];
    property MessageValueTooLowTitle: string
      read fUserValidationMessages.Messages[TValidationMessageKind.ValueTooLowTitle]
      write fUserValidationMessages.Messages[TValidationMessageKind.ValueTooLowTitle];
    property MessageValueTooLowHint: string
      read fUserValidationMessages.Messages[TValidationMessageKind.ValueTooLowHint]
      write fUserValidationMessages.Messages[TValidationMessageKind.ValueTooLowHint];
    property MessageValueTooHighTitle: string
      read fUserValidationMessages.Messages[TValidationMessageKind.ValueTooHighTitle]
      write fUserValidationMessages.Messages[TValidationMessageKind.ValueTooHighTitle];
    property MessageValueTooHighHint: string
      read fUserValidationMessages.Messages[TValidationMessageKind.ValueTooHighHint]
      write fUserValidationMessages.Messages[TValidationMessageKind.ValueTooHighHint];
    property MessageValueOutOfRangeHint: string
      read fUserValidationMessages.Messages[TValidationMessageKind.ValueOutOfRangeHint]
      write fUserValidationMessages.Messages[TValidationMessageKind.ValueOutOfRangeHint];
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
  fUserValidationMessages.ValuePlaceholder := '#';
end;

destructor TConstraintEdit<T>.Destroy;
begin
  fInvalidHint.Free;
  inherited;
end;

procedure TConstraintEdit<T>.Clear;
begin
  inherited;
  fValue := fNotSetValue;
  fValueSet := False;
end;

function TConstraintEdit<T>.GetValidationMessage(const aMessageKind: TValidationMessageKind;
  const aCurrentText: string; aCurrentValue: T): string;
begin
  var lMesssage := fUserValidationMessages.Messages[aMessageKind];
  var lValuePlaceholder := fUserValidationMessages.ValuePlaceholder;
  if Length(lMesssage) = 0 then
  begin
    var lDefaultMesssage := GetValidationDefaultMessage(aMessageKind);
    lMesssage := lDefaultMesssage.ValidationMessage;
    lValuePlaceholder := lDefaultMesssage.ValuePlaceholder;
  end;
  Result := GetFormattedMessage(lMesssage, lValuePlaceholder, aCurrentText, aCurrentValue);
end;

function TConstraintEdit<T>.GetFormattedMessage(const aMessage: string; const aValuePlaceholder: Char;
  const aCurrentText: string; aCurrentValue: T): string;
begin
  var lMessageParts := aMessage.Split([aValuePlaceholder]);
  if Length(lMessageParts) = 0 then
    Exit('');
  Result := lMessageParts[0];
  for var i := 1 to High(lMessageParts) do
    Result := Result + ValuesReplaced(lMessageParts[i], aCurrentText, aCurrentValue);
end;

function TConstraintEdit<T>.ValuesReplaced(const aMessagePart: string;
  const aCurrentText: string; aCurrentValue: T): string;
begin
  Result := aMessagePart;
  if aMessagePart.StartsWith('t', True) then
    Result := aCurrentText + aMessagePart.Substring(1)
  else if aMessagePart.StartsWith('v', True) then
    Result := GetValueText(aCurrentValue) + aMessagePart.Substring(1)
  else if aMessagePart.StartsWith('mi', True) then
    Result := GetValueText(fRangeMinValue) + aMessagePart.Substring(2)
  else if aMessagePart.StartsWith('ma', True) then
    Result := GetValueText(fRangeMaxValue) + aMessagePart.Substring(2);
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

procedure TConstraintEdit<T>.SetMessageValuePlaceholder(const aValue: Char);
begin
  if aValue < #32 then
    fUserValidationMessages.ValuePlaceholder := '#'
  else
    fUserValidationMessages.ValuePlaceholder := aValue;
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

function TConstraintEdit<T>.GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage;
begin
  Result := default(TValidationMessage);
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
    Result.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.InvalidInputTitle,
      aInputData.TextToValidate, fValue);
    Result.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.InvalidValueHint,
      aInputData.TextToValidate, fValue);
  end;
end;

function TConstraintEdit<T>.IsTextValid(const aText: string): TValidationResult<T>;
begin
  Result := default(TValidationResult<T>);
end;

function TConstraintEdit<T>.IsTextValidInternal(const aOnExit: Boolean): TValidationResult<T>;
begin
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
        lValidationResult.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.InvalidTextTitle,
          Text, lValidationResult.NewValue);
        lValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.InvalidValueHint,
          Text, lValidationResult.NewValue);
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
  if not aTestMaxOnly and fRangeMinValueSet and (CompareValues(aValue, fRangeMinValue) < 0) then
  begin
    aValidationResult.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.ValueTooLowTitle, Text, aValue);
    aValidationResult.IsValid := False;
  end;
  if fRangeMaxValueSet and (CompareValues(aValue, fRangeMaxValue) > 0) then
  begin
    aValidationResult.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.ValueTooHighTitle, Text, aValue);
    aValidationResult.IsValid := False;
  end;
  if not aValidationResult.IsValid then
  begin
    if fRangeMinValueSet and fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.ValueOutOfRangeHint, Text, aValue);
    end
    else if fRangeMinValueSet then
    begin
      aValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.ValueTooLowHint, Text, aValue);
    end
    else if fRangeMaxValueSet then
    begin
      aValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.ValueTooHighHint, Text, aValue);
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
  begin
    Result := TextBefore + NewText + TextAfter;
  end
  else if NewChar = Char_Backspace then
  begin
    Result := TextBefore;
    var lTextBeforeLen := Length(fTextBefore);
    if (fSelLength = 0) and (lTextBeforeLen > 0)  then
    begin
      Delete(Result, lTextBeforeLen, 1);
    end;
    Result := Result + TextAfter;
  end
  else
  begin
    Result := TextBefore + NewChar + TextAfter;
  end;

  fTextToValidateGenerated := True;
  fTextToValidate := Result;
end;

procedure TInputValidationData.SetControlData(const aEdit: TCustomEdit);
begin
  fSelStart := aEdit.SelStart;
  fSelLength := aEdit.SelLength;
  fTextBefore := Copy(aEdit.Text, 1, fSelStart);
  fTextAfter := Copy(aEdit.Text, fSelStart + fSelLength + 1, Length(aEdit.Text));
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

end.
