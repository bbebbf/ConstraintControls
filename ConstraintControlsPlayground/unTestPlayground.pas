unit unTestPlayground;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ConstraintControls.ConstraintEdit,
  ConstraintControls.IntegerEdit, ConstraintControls.DateEdit;

type
  TfmTestPlayground = class(TForm)
    DateEdit1: TDateEdit;
    cbOptionalYear: TCheckBox;
    procedure cbOptionalYearClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fmTestPlayground: TfmTestPlayground;

implementation

{$R *.dfm}

procedure TfmTestPlayground.cbOptionalYearClick(Sender: TObject);
begin
  DateEdit1.OptionalYear := cbOptionalYear.Checked;
end;

end.
