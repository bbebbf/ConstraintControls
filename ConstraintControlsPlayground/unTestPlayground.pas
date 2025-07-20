unit unTestPlayground;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfmTestPlayground = class(TForm)
    btOpenDialog: TButton;
    procedure btOpenDialogClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fmTestPlayground: TfmTestPlayground;

implementation

{$R *.dfm}

uses unTestDialog;

procedure TfmTestPlayground.btOpenDialogClick(Sender: TObject);
begin
  var lDialog := TfmTestDialog.Create(Self);
  try
    lDialog.ShowModal;
  finally
    lDialog.Free;
  end;
end;

end.
