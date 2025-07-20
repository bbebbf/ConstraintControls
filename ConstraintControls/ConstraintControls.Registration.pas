unit ConstraintControls.Registration;

interface

uses
  ConstraintControls.IntegerEdit;

procedure Register;

implementation

uses System.Classes;

procedure Register;
begin
  System.Classes.RegisterComponents('ConstraintControls', [TIntegerEdit]);
end;

end.
