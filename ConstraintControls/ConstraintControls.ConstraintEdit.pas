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

  TValidationResult<T: record> = record
    NewValue: T;
    IsValid: Boolean;
    ValidationNotRequired: Boolean;
    InvalidHintTitle: string;
    InvalidHintDescription: string;
  end;

  TOnExitQueryValidation<T: record> = procedure(Sender: TObject; const aValidationResult: TValidationResult<T>;
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

  TValueCompare<T> = reference to function(const aValue1, aValue2: T): Integer;
  TConstraintNullableValue<T: record> = class;
  TOnConstraintNullableValueNotifyEvent<T: record> = procedure(const aSender: TConstraintNullableValue<T>) of object;

  TConstraintNullableValue<T: record> = class(TPersistent)
  strict private
    fValue: T;
    fNullValue: T;
    fNull: Boolean;
    fValidated: Boolean;
    fOnValueCompare: TValueCompare<T>;
    fOnValueChanged: TOnConstraintNullableValueNotifyEvent<T>;
    fOnValueRead: TOnConstraintNullableValueNotifyEvent<T>;
    function DoValueCompare(const aValue1, aValue2: T): Integer;
    procedure DoValueChanged;
    procedure DoValueRead;
  strict protected
    function GetValue: T;
    procedure SetValue(const aValue: T);
    procedure SetNull(const aValue: Boolean);
    function GetNullValue: T;
    procedure SetNullValue(const aValue: T);
  public
    constructor Create;
    procedure InvalidateValue;
    property Value: T read GetValue write SetValue;
    property NullValue: T read GetNullValue write SetNullValue;
    property Validated: Boolean read fValidated;
  published
    property Null: Boolean read fNull write SetNull default True;
    property OnValueCompare: TValueCompare<T> read fOnValueCompare write fOnValueCompare;
    property OnValueChanged: TOnConstraintNullableValueNotifyEvent<T> read fOnValueChanged write fOnValueChanged;
    property OnValueRead: TOnConstraintNullableValueNotifyEvent<T> read fOnValueRead write fOnValueRead;
  end;

  TConstraintEditValueType = (vtValue, vtRangeMin, vtRangeMax);

  TConstraintEdit<T: record> = class(TCustomEdit)
  strict private
    fValue: TConstraintNullableValue<T>;
    fRangeMin: TConstraintNullableValue<T>;
    fRangeMax: TConstraintNullableValue<T>;
    fUserValidationMessages: TValidationMessages;
    fInvalidHint: TBalloonHint;
    fExitOnInvalidValue: Boolean;
    fOnExitQueryValidation: TOnExitQueryValidation<T>;

    procedure OnValueChangedUpdateText(const aSender: TConstraintNullableValue<T>);
    procedure OnRangeMinValueChangedAdjustMax(const aSender: TConstraintNullableValue<T>);
    procedure OnRangeMaxValueChangedAdjustMin(const aSender: TConstraintNullableValue<T>);
    procedure OnValueReadValidate(const aSender: TConstraintNullableValue<T>);

    function GetInheritedText: string;
    procedure SetInheritedText(const aValue: string);

    procedure WMPaste(var Msg: TWMPaste); message WM_PASTE;
    procedure WMClear(var Msg: TWMClear); message WM_CLEAR;
    procedure WMCut(var Msg: TWMCut); message WM_CUT;
    function NewInputValidationData(const aReason: TInputValidationReason): TInputValidationData;
    function IsInputValidInternal(const aInputData: TInputValidationData): TValidationResult<T>;
    function IsTextValidInternal(const aOnExit: Boolean): TValidationResult<T>;
    procedure ShowInvalidHint(const aValidationResult: TValidationResult<T>);

    function ValuesReplaced(const aMessagePart: string;
      const aCurrentText: string; aCurrentValue: T): string;
  strict protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;

    class function CreateValueInstance: TConstraintNullableValue<T>; virtual;
    function GetValueInstance(const aValueType: TConstraintEditValueType): TConstraintNullableValue<T>;

    function GetValueText(const aValue: T): string; virtual;
    function GetNoValueText: string; virtual;
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
    procedure Clear; override;
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

    property ExitOnInvalidValue: Boolean read fExitOnInvalidValue write fExitOnInvalidValue default False;
    property OnExitQueryValidation: TOnExitQueryValidation<T> read fOnExitQueryValidation write fOnExitQueryValidation;

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
  fValue := CreateValueInstance;
  fValue.OnValueCompare := CompareValues;
  fValue.OnValueChanged := OnValueChangedUpdateText;
  fValue.OnValueRead := OnValueReadValidate;

  fRangeMin := CreateValueInstance;
  fRangeMin.OnValueCompare := CompareValues;
  fRangeMin.OnValueChanged := OnRangeMinValueChangedAdjustMax;

  fRangeMax := CreateValueInstance;
  fRangeMax.OnValueCompare := CompareValues;
  fRangeMax.OnValueChanged := OnRangeMaxValueChangedAdjustMin;

  fUserValidationMessages.ValuePlaceholder := '#';
end;

destructor TConstraintEdit<T>.Destroy;
begin
  fValue.Free;
  fRangeMin.Free;
  fRangeMax.Free;
  fInvalidHint.Free;
  inherited;
end;

class function TConstraintEdit<T>.CreateValueInstance: TConstraintNullableValue<T>;
begin
  raise ENotImplemented.Create(ClassName + 'CreateValueInstance');
end;

function TConstraintEdit<T>.GetValueInstance(const aValueType: TConstraintEditValueType): TConstraintNullableValue<T>;
begin
  case aValueType of
    TConstraintEditValueType.vtValue:
      Result := fValue;
    TConstraintEditValueType.vtRangeMin:
      Result := fRangeMin;
    TConstraintEditValueType.vtRangeMax:
      Result := fRangeMax;
  end;
end;

procedure TConstraintEdit<T>.OnValueChangedUpdateText(const aSender: TConstraintNullableValue<T>);
begin
  if aSender.Null then
    SetInheritedText(GetNoValueText)
  else
    SetInheritedText(GetValueText(aSender.Value));
end;

procedure TConstraintEdit<T>.OnRangeMinValueChangedAdjustMax(const aSender: TConstraintNullableValue<T>);
begin
  if not aSender.Null and not fRangeMax.Null and (CompareValues(aSender.Value, fRangeMax.Value) > 0) then
    fRangeMax.Value := aSender.Value;
end;

procedure TConstraintEdit<T>.OnRangeMaxValueChangedAdjustMin(const aSender: TConstraintNullableValue<T>);
begin
  if not aSender.Null and not fRangeMin.Null and (CompareValues(aSender.Value, fRangeMin.Value) < 0) then
    fRangeMin.Value := aSender.Value;
end;

procedure TConstraintEdit<T>.OnValueReadValidate(const aSender: TConstraintNullableValue<T>);
begin
  var lValidationResult := IsTextValidInternal(False);
  if not lValidationResult.IsValid then
  begin
    fValue.Null := True;
  end;
end;

procedure TConstraintEdit<T>.Clear;
begin
  inherited;
  fValue.Null := True;
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
    Result := GetValueText(fRangeMin.Value) + aMessagePart.Substring(2)
  else if aMessagePart.StartsWith('ma', True) then
    Result := GetValueText(fRangeMax.Value) + aMessagePart.Substring(2);
end;

function TConstraintEdit<T>.GetInheritedText: string;
begin
  Result := inherited Text;
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

function TConstraintEdit<T>.GetValidationDefaultMessage(const aKind: TValidationMessageKind): TValidationMessage;
begin
  Result := default(TValidationMessage);
end;

function TConstraintEdit<T>.CompareValues(const aValue1, aValue2: T): Integer;
begin
  Result := 0;
end;

function TConstraintEdit<T>.GetValueText(const aValue: T): string;
begin
  Result := '';
end;

function TConstraintEdit<T>.GetNoValueText: string;
begin
  Result := '';
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
    fValue.InvalidateValue;
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
    fValue.InvalidateValue;
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
    fValue.InvalidateValue;
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
    fValue.InvalidateValue;
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
    OnValueChangedUpdateText(fValue);
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
      aInputData.TextToValidate, fValue.Value);
    Result.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.InvalidValueHint,
      aInputData.TextToValidate, fValue.Value);
  end;
end;

function TConstraintEdit<T>.IsTextValid(const aText: string): TValidationResult<T>;
begin
  Result := default(TValidationResult<T>);
end;

function TConstraintEdit<T>.IsTextValidInternal(const aOnExit: Boolean): TValidationResult<T>;
begin
  var lValidationResult := default(TValidationResult<T>);
  if fValue.Validated then
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
      fValue.Value := lValidationResult.NewValue;
    end
    else
    begin
      fValue.Null := True;
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
  if not aTestMaxOnly and not fRangeMin.Null and (CompareValues(aValue, fRangeMin.Value) < 0) then
  begin
    aValidationResult.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.ValueTooLowTitle, Text, aValue);
    aValidationResult.IsValid := False;
  end;
  if not fRangeMax.Null and (CompareValues(aValue, fRangeMax.Value) > 0) then
  begin
    aValidationResult.InvalidHintTitle := GetValidationMessage(TValidationMessageKind.ValueTooHighTitle, Text, aValue);
    aValidationResult.IsValid := False;
  end;
  if not aValidationResult.IsValid then
  begin
    if not fRangeMin.Null and not fRangeMax.Null then
    begin
      aValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.ValueOutOfRangeHint, Text, aValue);
    end
    else if not fRangeMin.Null then
    begin
      aValidationResult.InvalidHintDescription := GetValidationMessage(TValidationMessageKind.ValueTooLowHint, Text, aValue);
    end
    else if not fRangeMax.Null then
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

{ TConstraintNullableValue<T> }

constructor TConstraintNullableValue<T>.Create;
begin
  inherited Create;
  fNull := True;
end;

function TConstraintNullableValue<T>.GetValue: T;
begin
  if not fValidated then
    DoValueRead;
  if fNull then
    Result := fNullValue
  else
    Result := fValue;
end;

procedure TConstraintNullableValue<T>.InvalidateValue;
begin
  fValidated := False;
end;

procedure TConstraintNullableValue<T>.SetValue(const aValue: T);
begin
  if (DoValueCompare(fValue, aValue) = 0) and not fNull then
    Exit;
  fValue := aValue;
  fNull := False;
  fValidated := True;
  DoValueChanged;
end;

procedure TConstraintNullableValue<T>.SetNull(const aValue: Boolean);
begin
  if fNull = aValue then
    Exit;
  fNull := aValue;
  if fNull then
    fValue := default(T);
  fValidated := True;
  DoValueChanged;
end;

function TConstraintNullableValue<T>.GetNullValue: T;
begin
  Result := fNullValue;
end;

procedure TConstraintNullableValue<T>.SetNullValue(const aValue: T);
begin
  if DoValueCompare(fNullValue, aValue) = 0 then
    Exit;
  fNullValue := aValue;
  if fNull then
    DoValueChanged;
end;

function TConstraintNullableValue<T>.DoValueCompare(const aValue1, aValue2: T): Integer;
begin
  if Assigned(fOnValueCompare) then
    Result := fOnValueCompare(aValue1, aValue2)
  else
    Result := 0;
end;

procedure TConstraintNullableValue<T>.DoValueChanged;
begin
  if Assigned(fOnValueChanged) then
    fOnValueChanged(Self);
end;

procedure TConstraintNullableValue<T>.DoValueRead;
begin
  if Assigned(fOnValueRead) then
    fOnValueRead(Self);
end;

end.
