program ConstraintControlsPlayground;

uses
  Vcl.Forms,
  unTestPlayground in 'unTestPlayground.pas' {fmTestPlayground},
  unTestDialog in 'unTestDialog.pas' {fmTestDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmTestPlayground, fmTestPlayground);
  Application.Run;
end.
