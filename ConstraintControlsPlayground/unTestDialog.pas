unit unTestDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ConstraintControls.ConstraintEdit, ConstraintControls.IntegerEdit;

type
  TfmTestDialog = class(TForm)
    btCorfirm: TButton;
    btCancel: TButton;
    IntegerEdit1: TIntegerEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

procedure TfmTestDialog.FormCreate(Sender: TObject);
begin
  IntegerEdit1.Value := 77;
  IntegerEdit1.Clear;
end;

end.
