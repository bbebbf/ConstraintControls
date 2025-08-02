unit ConstraintControls.Registration;

interface

uses
  ConstraintControls.IntegerEdit,
  ConstraintControls.DateEdit;

procedure Register;

implementation

uses System.Classes;

procedure Register;
begin
  System.Classes.RegisterComponents('ConstraintControls', [TIntegerEdit, TDateEdit]);
end;

end.
