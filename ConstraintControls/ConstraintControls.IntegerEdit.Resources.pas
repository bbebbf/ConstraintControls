unit ConstraintControls.IntegerEdit.Resources;

interface

type
  TIntegerEditResourcesDefaultMessages = class
  strict private
    const
      InvalidInputTitle = 'Hinweis';
      InvalidTextTitle = 'Unzulässig';
      InvalidOnlyNumbersAllowed = 'Es sind nur Ziffern erlaubt.';
      ValueTooLowTitle = 'Zu niedrig';
      ValueTooLowHint = 'Zahl muss mindestens %d sein.';
      ValueTooHighTitle = 'Zu hoch';
      ValueTooHighHint = 'Zahl darf höchstens %d sein.';
      ValueOutOfRangeHint = 'Zahl muss zwischen %d und %d liegen.';
    class function GetMessageString(const aPrimary, aSecondary: string): string;
    class function GetFormattedMessage(const aMessage: string; const aValuePlaceholder: Char;
      const aValues: array of Int64): string;
  public
    class function GetInvalidInputTitle(const aMessage: string): string;
    class function GetInvalidTextTitle(const aMessage: string): string;
    class function GetInvalidOnlyNumbersAllowed(const aMessage: string): string;
    class function GetValueTooLowTitle(const aMessage: string): string;
    class function GetValueTooLowHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMinValue: Int64): string;
    class function GetValueTooHighTitle(const aMessage: string): string;
    class function GetValueTooHighHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMaxValue: Int64): string;
    class function GetValueOutOfRangeHint(const aMessage: string;
      const aValuePlaceholder: Char; const aMinValue, aMaxValue: Int64): string;
  end;

implementation

uses System.SysUtils, System.StrUtils;

{ TIntegerEditResourcesDefaultMessages }

class function TIntegerEditResourcesDefaultMessages.GetInvalidInputTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, InvalidInputTitle);
end;

class function TIntegerEditResourcesDefaultMessages.GetInvalidOnlyNumbersAllowed(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, InvalidOnlyNumbersAllowed);
end;

class function TIntegerEditResourcesDefaultMessages.GetInvalidTextTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, InvalidTextTitle);
end;

class function TIntegerEditResourcesDefaultMessages.GetValueOutOfRangeHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMinValue, aMaxValue: Int64): string;
begin
  var lMessage := GetMessageString(aMessage, ValueOutOfRangeHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMinValue, aMaxValue]);
end;

class function TIntegerEditResourcesDefaultMessages.GetValueTooHighHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMaxValue: Int64): string;
begin
  var lMessage := GetMessageString(aMessage, ValueTooHighHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMaxValue]);
end;

class function TIntegerEditResourcesDefaultMessages.GetValueTooHighTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, ValueTooHighTitle);
end;

class function TIntegerEditResourcesDefaultMessages.GetValueTooLowHint(const aMessage: string;
  const aValuePlaceholder: Char; const aMinValue: Int64): string;
begin
  var lMessage := GetMessageString(aMessage, ValueTooLowHint);
  Result := GetFormattedMessage(lMessage, aValuePlaceholder, [aMinValue]);
end;

class function TIntegerEditResourcesDefaultMessages.GetValueTooLowTitle(const aMessage: string): string;
begin
  Result := GetMessageString(aMessage, ValueTooLowTitle);
end;

class function TIntegerEditResourcesDefaultMessages.GetFormattedMessage(const aMessage: string;
  const aValuePlaceholder: Char; const aValues: array of Int64): string;
begin
  var lMessageParts := aMessage.Split([aValuePlaceholder]);
  if Length(lMessageParts) = 0 then
    Exit('');
  Result := lMessageParts[0];
  for var i := 1 to High(lMessageParts) do
  begin
    if i - 1 <= High(aValues) then
      Result := Result + IntToStr(aValues[i - 1])
    else
      Result := Result + aValuePlaceholder;
    Result := Result + lMessageParts[i];
  end;
end;

class function TIntegerEditResourcesDefaultMessages.GetMessageString(const aPrimary, aSecondary: string): string;
begin
  if Length(aPrimary) > 0 then
    Result := aPrimary
  else
    Result := aSecondary;
end;

end.
