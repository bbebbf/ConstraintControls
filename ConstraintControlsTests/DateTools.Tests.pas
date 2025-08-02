unit DateTools.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils;

type
  [TestFixture]
  TDateToolsTests = class
  strict private
    fFormatSettings: TFormatSettings;
  public
    [SetupFixture]
    procedure SetupFixture;

    [TestCase('1', '1')]
    procedure TryToParseDateTestCompleteSucceded(const aInputText: string);

    [TestCase('1234567', '1234567,12.03.4567')]
    [TestCase('141414', '141414,1.4.1414')]
    procedure TryToParseDateTestCompleteSuccededDate(const aInputText: string; const aDate: TDate);

    procedure TryToParseDateTestCompleteFailed(const aInputText: string);

    [TestCase('1', '1')]
    [TestCase('12', '12')]
    [TestCase('999', '999')]
    [TestCase('1239', '1239')]
    [TestCase('23.', '23.')]
    [TestCase('1.2', '1.2')]
    [TestCase('1.2.39', '1.2.39')]
    [TestCase('1234567', '1234567')]
    [TestCase('99999', '99999')]
    procedure InputTextMatchesDateSucceeds(const aInputText: string);

    [TestCase('.14', '.14')]
    [TestCase('.12', '.12')]
    procedure InputTextMatchesDateFails(const aInputText: string);

    [TestCase('1', '1')]
    [TestCase('12', '12')]
    [TestCase('999', '999')]
    [TestCase('1239', '1239')]
    [TestCase('23.', '23.')]
    [TestCase('1.2', '1.2')]
    [TestCase('1.2.39', '1.2.39')]
    [TestCase('1234567', '1234567')]
    [TestCase('99999', '99999')]
    [TestCase('.14', '.14')]
    [TestCase('.12', '.12')]
    procedure InputTextMatchesTryParseSucceeds(const aInputText: string);

    [TestCase('999', '999')]
    [TestCase('99999', '99999')]
    [TestCase('1', '1')]
    [TestCase('12', '12')]
    [TestCase('1239', '1239')]
    [TestCase('23.', '23.')]
    [TestCase('1.2', '1.2')]
    [TestCase('1.2.39', '1.2.39')]
    [TestCase('1234567', '1234567')]
    [TestCase('.14', '.14')]
    [TestCase('.12', '.12')]
    procedure InputTextMatchesTryParseFails(const aInputText: string);
  end;

implementation

uses System.DateUtils, ConstraintControls.DateTools;

{ TDateToolsTests }

procedure TDateToolsTests.SetupFixture;
begin
  fFormatSettings := TFormatSettings.Create;
end;

procedure TDateToolsTests.TryToParseDateTestCompleteSucceded(const aInputText: string);
begin
  var lDate: TDate;
  Assert.IsTrue(TDateTools.TryToParseDate(aInputText, fFormatSettings, lDate),
    'aInputText "' + aInputText + '" is invalid.');
end;

procedure TDateToolsTests.TryToParseDateTestCompleteSuccededDate(const aInputText: string; const aDate: TDate);
begin
  var lDate: TDate;
  Assert.IsTrue(TDateTools.TryToParseDate(aInputText, fFormatSettings, lDate),
    'aInputText "' + aInputText + '" is invalid.');
  Assert.IsTrue(CompareDate(aDate, lDate) = 0, 'Wrong date.');
end;

procedure TDateToolsTests.TryToParseDateTestCompleteFailed(const aInputText: string);
begin
  var lDate: TDate;
  Assert.IsFalse(TDateTools.TryToParseDate(aInputText, fFormatSettings, lDate),
    'aInputText "' + aInputText + '" is valid.');
end;

procedure TDateToolsTests.InputTextMatchesDateSucceeds(const aInputText: string);
begin
  Assert.IsTrue(TDateTools.InputTextMatchesDate(aInputText, fFormatSettings),
    'aInputText "' + aInputText + '" is invalid.');
end;

procedure TDateToolsTests.InputTextMatchesDateFails(const aInputText: string);
begin
  Assert.IsFalse(TDateTools.InputTextMatchesDate(aInputText, fFormatSettings),
    'aInputText "' + aInputText + '" is valid.');
end;

procedure TDateToolsTests.InputTextMatchesTryParseSucceeds(const aInputText: string);
begin
  var lDate: TDate;
  var lParsedSuccessfully := TDateTools.TryToParseDate(aInputText, fFormatSettings, lDate);
  if lParsedSuccessfully then
    InputTextMatchesDateSucceeds(aInputText)
  else
    Assert.Pass;
end;

procedure TDateToolsTests.InputTextMatchesTryParseFails(const aInputText: string);
begin
  var lParsedSuccessfully := TDateTools.InputTextMatchesDate(aInputText, fFormatSettings);
  if not lParsedSuccessfully then
    TryToParseDateTestCompleteFailed(aInputText)
  else
    Assert.Pass;
end;

initialization
  TDUnitX.RegisterTestFixture(TDateToolsTests);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

end.
