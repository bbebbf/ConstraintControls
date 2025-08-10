unit unTestPlayground;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ConstraintControls.ConstraintEdit,
  ConstraintControls.IntegerEdit;

type
  TfmTestPlayground = class(TForm)
    btOpenDialog: TButton;
    IntegerEdit1: TIntegerEdit;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fmTestPlayground: TfmTestPlayground;

implementation

{$R *.dfm}

end.
