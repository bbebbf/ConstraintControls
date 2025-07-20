unit ConstraintControls.ConstraintEdit;

{$SCOPEDENUMS ON}

interface

uses Winapi.Messages, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

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

  TValidationResult = record
    IsValid: Boolean;
    ValidationNotRequired: Boolean;
    InvalidHintTitle: string;
    InvalidHintDescription: string;
  end;

  TOnExitQueryValidation = procedure(Sender: TObject; const aValidationResult: TValidationResult;
    var aValidationRequired: Boolean) of object;

  TConstraintEdit<T> = class(TCustomEdit)
  strict private
    fValue: T;
    fValueSet: Boolean;
    fNotSetValue: T;

    fTextValidated: Boolean;
    fInvalidHint: TBalloonHint;

    fExitOnInvalidValue: Boolean;
    fOnExitQueryValidation: TOnExitQueryValidation;

    function GetInheritedText: string;
    procedure SetInheritedText(const aValue: string);

    procedure SetValueSet(const aValue: Boolean);
    procedure WMPaste(var Msg: TWMPaste); message WM_PASTE;
    procedure WMClear(var Msg: TWMClear); message WM_CLEAR;
    procedure WMCut(var Msg: TWMCut); message WM_CUT;
    procedure UpdateText;
    function NewInputValidationData(const aReason: TInputValidationReason): TInputValidationData;
    function IsInputValidInternal(const aInputData: TInputValidationData): TValidationResult;
    function IsTextValidInternal(const aOnExit: Boolean): TValidationResult;
    procedure ShowInvalidHint(const aValidationResult: TValidationResult);
  strict protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;

    function GetValueText(const aValue: T): string; virtual;
    function IsInputValid(const aInputData: TInputValidationData): TValidationResult; virtual;
    function IsTextValid(const aText: string; out aValue: T): TValidationResult; virtual;

    procedure  DoOnExitQueryValidation(const aValidationResult: TValidationResult;
      var aValidationRequired: Boolean);
  public
    destructor Destroy; override;
    function GetValue: T;
    procedure Clear; override;
    procedure SetValue(const aValue: T);
    function GetNotSetValue: T;
    procedure SetNotSetValue(const aValue: T);

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
    property OnExitQueryValidation: TOnExitQueryValidation read fOnExitQueryValidation write fOnExitQueryValidation;
  end;

const
  Char_Space: Char = #32;
  Char_Backspace: Char = #8;

implementation

uses System.SysUtils, Vcl.Clipbrd;

{ TConstraintEdit<T> }

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

function TConstraintEdit<T>.GetInheritedText: string;
begin
  Result := inherited Text;
end;

function TConstraintEdit<T>.GetNotSetValue: T;
begin
  Result := fNotSetValue;
end;

procedure TConstraintEdit<T>.SetInheritedText(const aValue: string);
begin
  inherited Text := aValue;
end;

procedure TConstraintEdit<T>.SetNotSetValue(const aValue: T);
begin
  fNotSetValue := aValue;
  if not fValueSet then
    fValue := fNotSetValue;
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

procedure TConstraintEdit<T>.DoOnExitQueryValidation(const aValidationResult: TValidationResult;
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

function TConstraintEdit<T>.IsInputValid(const aInputData: TInputValidationData): TValidationResult;
begin
  Result := default(TValidationResult);
end;

function TConstraintEdit<T>.IsInputValidInternal(const aInputData: TInputValidationData): TValidationResult;
begin
  Result := default(TValidationResult);
  if Length(aInputData.TextToValidate) = 0 then
  begin
    Result.IsValid := True;
    Exit;
  end;
  Result := IsInputValid(aInputData);
end;

function TConstraintEdit<T>.IsTextValid(const aText: string; out aValue: T): TValidationResult;
begin
  Result := default(TValidationResult);
end;

function TConstraintEdit<T>.IsTextValidInternal(const aOnExit: Boolean): TValidationResult;
begin
  var lValidationResult := default(TValidationResult);
  if fTextValidated then
  begin
    lValidationResult.IsValid := True;
  end
  else
  begin
    if Length(Text) > 0 then
    begin
      var lNewValue: T;
      lValidationResult := IsTextValid(Text, lNewValue);
      if lValidationResult.IsValid then
      begin
        fValue := lNewValue;
        fValueSet := True;
        fTextValidated := True;
      end
      else
      begin
        fValue := fNotSetValue;
        fValueSet := False;
      end;
    end
    else
    begin
      fValue := fNotSetValue;
      fValueSet := False;
      lValidationResult.ValidationNotRequired := True;
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

procedure TConstraintEdit<T>.ShowInvalidHint(const aValidationResult: TValidationResult);
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

end.
