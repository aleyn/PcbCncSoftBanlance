program pcsb;

uses
  Forms,
  pcsb_form in 'pcsb_form.pas' {frmPcsb};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPcsb, frmPcsb);
  Application.Run;
end.
