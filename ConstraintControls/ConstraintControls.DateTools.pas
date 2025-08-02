unit ConstraintControls.DateTools;

interface

uses System.SysUtils;

type
  TDateFormat = record
    IsValid: Boolean;
    SeparatorCount: Byte;
    SeparatedParts: TArray<string>;
    Text: string;
    TextLength: Byte;
  end;

  TDateTools = class
  strict private
  type
    TDatePartOrder = (ymd, dmy, mdy);
    TDateCandidate = record
      Year: Word;
      Month: Word;
      Day: Word;
      Incomplete: Boolean;
    end;
  const
    NumberChars = ['0'..'9'];
  var
    class function GetDatePartOrder(const aFormatSettings: TFormatSettings): TDatePartOrder;
    class function GetCompleteYear(const aYear: Word): Word;
    class function TryStrToWord(const aStr: string; out aValue: Word): Boolean;
    class function AddAsWord(const aValue: Word; const aDigitChar: Char): Word;
    class function ReadDateFormat(const aText: string; const aDateSeparator: Char): TDateFormat;
    class function TryToParseDateInternal(const aText: string; const aIsCompleteParse: Boolean;
      const aFormatSettings: TFormatSettings; out aDate: TDate): Boolean;
    class function TestCandidate(const aCandidate: TDateCandidate; const aIsCompleteParse: Boolean;
      out aDate: TDate): Boolean;
    class function TestByPattern(const aTextDate: TDateFormat; const aIsCompleteParse: Boolean;
      const aDatePartOrder: TDatePartOrder; out aDate: TDate): Boolean;
    class function TestBySeparator(const aTextDate: TDateFormat; const aIsCompleteParse: Boolean;
      const aDatePartOrder: TDatePartOrder; out aDate: TDate): Boolean;
  public
    class function TryToParseDate(const aText: string; out aDate: TDate): Boolean; overload;
    class function TryToParseDate(const aText: string; const aFormatSettings: TFormatSettings;
      out aDate: TDate): Boolean; overload;
    class function InputTextMatchesDate(const aInputText: string): Boolean; overload;
    class function InputTextMatchesDate(const aInputText: string; const aFormatSettings: TFormatSettings): Boolean; overload;
  end;

implementation

uses System.DateUtils, System.Generics.Collections, System.Generics.Defaults;


{ TDateTools }

class function TDateTools.TryToParseDate(const aText: string; out aDate: TDate): Boolean;
begin
  var lSettings := TFormatSettings.Create;
  Result := TryToParseDate(aText, lSettings, aDate);
end;

class function TDateTools.TryToParseDate(const aText: string; const aFormatSettings: TFormatSettings;
  out aDate: TDate): Boolean;
begin
  Result := TryToParseDateInternal(aText, True, aFormatSettings, aDate);
end;

class function TDateTools.InputTextMatchesDate(const aInputText: string): Boolean;
begin
  var lSettings := TFormatSettings.Create;
  Result := InputTextMatchesDate(aInputText, lSettings);
end;

class function TDateTools.InputTextMatchesDate(const aInputText: string; const aFormatSettings: TFormatSettings): Boolean;
begin
  var lDate: TDate;
  Result := TryToParseDateInternal(aInputText, False, aFormatSettings, lDate);
end;

class function TDateTools.TryToParseDateInternal(const aText: string; const aIsCompleteParse: Boolean;
  const aFormatSettings: TFormatSettings; out aDate: TDate): Boolean;
begin
  aDate := default(TDate);
  var lDateFormat := ReadDateFormat(aText, aFormatSettings.DateSeparator);
  if not lDateFormat.IsValid then
    Exit(False);

  var lDatePartOrder := GetDatePartOrder(aFormatSettings);
  if lDateFormat.SeparatorCount > 0 then
  begin
    Result := TestBySeparator(lDateFormat, aIsCompleteParse, lDatePartOrder, aDate);
  end
  else
  begin
    Result := TestByPattern(lDateFormat, aIsCompleteParse, lDatePartOrder, aDate);
  end;
end;

class function TDateTools.TestBySeparator(const aTextDate: TDateFormat; const aIsCompleteParse: Boolean;
  const aDatePartOrder: TDatePartOrder; out aDate: TDate): Boolean;
begin
  Result := False;
  aDate := default(TDate);
  var lSeparatedPartsLen := Length(aTextDate.SeparatedParts);
  if not aIsCompleteParse and (lSeparatedPartsLen < 3) then
    Exit(True);

  var lYearsIdx: Byte := 0;
  var lMonthsIdx: Byte := 0;
  var lDaysIdx: Byte := 0;
  case aDatePartOrder of
    TDatePartOrder.ymd:
    begin
      lYearsIdx := 0;
      lMonthsIdx := 1;
      lDaysIdx := 2;
    end;
    TDatePartOrder.mdy:
    begin
      lYearsIdx := 2;
      lMonthsIdx := 0;
      lDaysIdx := 1;
    end;
    TDatePartOrder.dmy:
    begin
      lYearsIdx := 2;
      lMonthsIdx := 1;
      lDaysIdx := 0;
    end;
  end;

  var lCandidate := default(TDateCandidate);
  if lDaysIdx < lSeparatedPartsLen then
    if not TryStrToWord(aTextDate.SeparatedParts[lDaysIdx], lCandidate.Day) then
      Exit(False);
  if lMonthsIdx < lSeparatedPartsLen then
    if not TryStrToWord(aTextDate.SeparatedParts[lMonthsIdx], lCandidate.Month) then
      lCandidate.Month := 0;
  if lYearsIdx < lSeparatedPartsLen then
    if not TryStrToWord(aTextDate.SeparatedParts[lYearsIdx], lCandidate.Year) then
      lCandidate.Year := 0;
  if TestCandidate(lCandidate, aIsCompleteParse, aDate) then
    Exit(True);
end;

class function TDateTools.TestByPattern(const aTextDate: TDateFormat; const aIsCompleteParse: Boolean;
  const aDatePartOrder: TDatePartOrder; out aDate: TDate): Boolean;
begin
  Result := False;
  aDate := default(TDate);
  if not aIsCompleteParse and (aTextDate.TextLength < 4) then
    Exit(True);

  var lPatternArray: TArray<string>;
  case aDatePartOrder of
    TDatePartOrder.ymd:
    begin
    end;
    TDatePartOrder.mdy:
    begin
    end;
    TDatePartOrder.dmy:
    begin
      lPatternArray := ['d',
        'dd', 'dm',
        'ddm', 'dmm',
        'ddmm', 'dmyy',
        'ddmyy', 'dmmyy',
        'ddmmyy', 'dmyyyy',
        'ddmyyyy', 'dmmyyyy',
        'ddmmyyyy'];
    end;
  end;
  for var lPattern in lPatternArray do
  begin
    var lPatternLength := Length(lPattern);
    if lPatternLength < aTextDate.TextLength then
      Continue;
    if aIsCompleteParse and (lPatternLength <> aTextDate.TextLength) then
      Continue;
    var lCandidate := default(TDateCandidate);
    for var i := 1 to aTextDate.TextLength do
    begin
      var lTextChar := aTextDate.Text[i];
      case lPattern[i] of
        'd': lCandidate.Day := AddAsWord(lCandidate.Day, lTextChar);
        'm': lCandidate.Month := AddAsWord(lCandidate.Month, lTextChar);
        'y': lCandidate.Year := AddAsWord(lCandidate.Year, lTextChar);
      end;
    end;
    lCandidate.Incomplete := aTextDate.TextLength < lPatternLength;
    if TestCandidate(lCandidate, aIsCompleteParse, aDate) then
      Exit(True);
  end;
end;

class function TDateTools.TestCandidate(const aCandidate: TDateCandidate; const aIsCompleteParse: Boolean;
  out aDate: TDate): Boolean;
begin
  Result := False;
  aDate := default(TDate);

  var lNow := Now;
  var lDateTime: TDateTime;
  var lMonth := aCandidate.Month;
  if aCandidate.Incomplete then
  begin
    if lMonth > 12 then
      Exit;
    if aCandidate.Day > 31 then
      Exit;
    if (lMonth > 0) and (aCandidate.Day > 0) then
    begin
      if (lMonth in [2, 4, 6, 9, 11]) and (aCandidate.Day = 31) then
        Exit;
      if (lMonth = 2) and (aCandidate.Day > 29) then
        Exit;
    end;
    Exit(True);
  end
  else
  begin
    var lYear := aCandidate.Year;
    if lYear = 0 then
      lYear := YearOf(lNow)
    else
      lYear := GetCompleteYear(lYear);
    if lMonth = 0 then
      lMonth := MonthOf(lNow);
    if TryEncodeDate(lYear, lMonth, aCandidate.Day, lDateTime) then
    begin
      aDate := lDateTime;
      Exit(True);
    end;
  end;
end;

class function TDateTools.AddAsWord(const aValue: Word; const aDigitChar: Char): Word;
begin
  var lIntValue := 0;
  if not TryStrToInt(aDigitChar, lIntValue) then
    Exit(aValue);

  Result := (10 * aValue) + lIntValue;
end;

class function TDateTools.GetCompleteYear(const aYear: Word): Word;
begin
  Result := aYear;
  if Result >= 100 then
    Exit;
  if Result < 50 then
    Result := aYear + 2000
  else
    Result := aYear + 1900;
end;

class function TDateTools.GetDatePartOrder(const aFormatSettings: TFormatSettings): TDatePartOrder;
begin
  if aFormatSettings.ShortDateFormat.StartsWith('d') then
    Result := TDatePartOrder.dmy
  else if aFormatSettings.ShortDateFormat.StartsWith('m') then
    Result := TDatePartOrder.mdy
  else
    Result := TDatePartOrder.ymd;
end;

class function TDateTools.ReadDateFormat(const aText: string; const aDateSeparator: Char): TDateFormat;
begin
  Result := default(TDateFormat);
  Result.Text := aText;
  Result.TextLength := Length(aText);
  if (Result.TextLength = 0) or (Result.TextLength > 10) then
    Exit;

  var lSeparatorAllowed := False;
  for var lChar in Result.Text do
  begin
    if lChar = aDateSeparator then
    begin
      if not lSeparatorAllowed then
        Exit;
      Inc(Result.SeparatorCount);
      if Result.SeparatorCount > 2 then
        Exit;
      lSeparatorAllowed := False;
    end
    else if CharInSet(lChar, NumberChars) then
      lSeparatorAllowed := True
    else
      Exit;
  end;
  if (Result.SeparatorCount = 0) and (Result.TextLength > 8) then
    Exit;

  Result.IsValid := True;
  if Result.SeparatorCount > 0 then
    Result.SeparatedParts := Result.Text.Split([aDateSeparator]);
end;

class function TDateTools.TryStrToWord(const aStr: string; out aValue: Word): Boolean;
begin
  Result := False;
  aValue := 0;
  var lValueCardinal: Cardinal;
  if TryStrToUInt(aStr, lValueCardinal) then
  begin
    if lValueCardinal <= High(Word) then
    begin
      Result := True;
      aValue := lValueCardinal;
    end;
  end;
end;

end.
