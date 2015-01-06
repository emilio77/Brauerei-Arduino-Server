program CtlXY;

uses
  Forms,
  Form in 'Form.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Brauerei Arduino COM Server';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
