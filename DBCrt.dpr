program DBCrt;

uses
  Forms,
  Unit1 in 'Unit1.pas' {DBCreate},
  wait in 'wait.pas' {ViewS};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Update DataBases Virus';
  Application.CreateForm(TDBCreate, DBCreate);
  Application.CreateForm(TViewS, ViewS);
  Application.Run;
end.
