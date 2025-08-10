unit unTestDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ConstraintControls.ConstraintEdit, ConstraintControls.IntegerEdit,
  ConstraintControls.DateEdit;

type
  TfmTestDialog = class(TForm)
    btCorfirm: TButton;
    btCancel: TButton;
    IntegerEdit1: TIntegerEdit;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

end.
