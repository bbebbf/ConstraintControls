unit SimpleDate;

interface

uses System.SysUtils;

type
  EInvalidDateException = class(Exception);

  TMonthRange = 0..12;
  TDayRange = 0..31;

  TSimpleDate = record
  strict private
    fYear: Word;
    fMonth: TMonthRange;
    fDay: TDayRange;
    procedure SetDay(const aValue: TDayRange);
    procedure SetMonth(const aValue: TMonthRange);
    procedure SetYear(const aValue: Word);
  public
    class operator Implicit(a: TDate): TSimpleDate;
    class operator Explicit(a: TDate): TSimpleDate;
    class operator Equal(a, b: TSimpleDate): Boolean;
    class operator NotEqual(a, b: TSimpleDate): Boolean;
    class operator GreaterThan(a, b: TSimpleDate): Boolean;
    class operator GreaterThanOrEqual(a, b: TSimpleDate): Boolean;
    class operator LessThan(a, b: TSimpleDate): Boolean;
    class operator LessThanOrEqual(a, b: TSimpleDate): Boolean;

    function IsYearKnown: Boolean;
    function IsDateValid: Boolean;
    function AsDate: TDate;
    function TryAsDate(out aDate:TDate): Boolean;
    procedure SetYMD(const aYear: Word; const aMonth: TMonthRange; const aDay: TDayRange);
    property Year: Word read fYear write SetYear;
    property Month: TMonthRange read fMonth write SetMonth;
    property Day: TDayRange read fDay write SetDay;
  end;

const
  SimpleDateLeapYearExample = 2024;

implementation

uses System.DateUtils;

{ TSimpleDate }

function TSimpleDate.AsDate: TDate;
begin
  var lDatetime: TDateTime;
  if not TryEncodeDate(fYear, fMonth, fDay, lDatetime) then
      raise EInvalidDateException.CreateFmt('Year = %d, Month = %d, Day = %d', [fYear, fMonth, fDay]);
  Result := lDatetime;
end;

function TSimpleDate.TryAsDate(out aDate: TDate): Boolean;
begin
  Result := False;
  var lDatetime: TDateTime;
  if TryEncodeDate(fYear, fMonth, fDay, lDatetime) then
  begin
    aDate := lDatetime;
    Result := True;
  end;
end;

function TSimpleDate.IsDateValid: Boolean;
begin
  Result := False;
  var lDate: TDateTime;
  if fYear > 0 then
  begin
    if TryEncodeDate(fYear, fMonth, fDay, lDate) then
      Exit(True);
  end
  else
  begin
    // If no year is set we need to test day and month with a leap year example.
    if TryEncodeDate(SimpleDateLeapYearExample, fMonth, fDay, lDate) then
      Exit(True);
  end;
end;

class operator TSimpleDate.Equal(a, b: TSimpleDate): Boolean;
begin
  Result := (a.Year = b.Year) and (a.Month = b.Month) and (a.Day = b.Day);
end;

class operator TSimpleDate.GreaterThan(a, b: TSimpleDate): Boolean;
begin
  Result := False;
  if a.Year <> b.Year then
    Exit(a.Year > b.Year);
  if a.Month <> b.Month then
    Exit(a.Month > b.Month);
  if a.Day <> b.Day then
    Exit(a.Day > b.Day);
end;

class operator TSimpleDate.GreaterThanOrEqual(a, b: TSimpleDate): Boolean;
begin
  Result := (a = b) or (a > b);
end;

class operator TSimpleDate.LessThan(a, b: TSimpleDate): Boolean;
begin
  Result := False;
  if a.Year <> b.Year then
    Exit(a.Year < b.Year);
  if a.Month <> b.Month then
    Exit(a.Month < b.Month);
  if a.Day <> b.Day then
    Exit(a.Day < b.Day);
end;

class operator TSimpleDate.LessThanOrEqual(a, b: TSimpleDate): Boolean;
begin
  Result := (a = b) or (a < b);
end;

class operator TSimpleDate.NotEqual(a, b: TSimpleDate): Boolean;
begin
  Result := not (a = b);
end;

class operator TSimpleDate.Implicit(a: TDate): TSimpleDate;
begin
  Result := default(TSimpleDate);
  Result.SetYMD(YearOf(a), MonthOf(a), DayOf(a));
end;

class operator TSimpleDate.Explicit(a: TDate): TSimpleDate;
begin
  Result := default(TSimpleDate);
  Result.SetYMD(YearOf(a), MonthOf(a), DayOf(a));
end;

function TSimpleDate.IsYearKnown: Boolean;
begin
  Result := fYear > 0;
end;

procedure TSimpleDate.SetDay(const aValue: TDayRange);
begin
  fDay := aValue;
end;

procedure TSimpleDate.SetMonth(const aValue: TMonthRange);
begin
  fMonth := aValue;
end;

procedure TSimpleDate.SetYear(const aValue: Word);
begin
  fYear := aValue;
end;

procedure TSimpleDate.SetYMD(const aYear: Word; const aMonth: TMonthRange; const aDay: TDayRange);
begin
  fYear := aYear;
  fMonth := aMonth;
  fDay := aDay;
end;

end.
