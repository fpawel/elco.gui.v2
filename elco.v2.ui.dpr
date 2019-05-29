program elco.v2.ui;

uses
  Vcl.Forms,
  UnitFormProducts in 'UnitFormProducts.pas' {FormProducts},
  elcohttpclient in 'elcohttpclient.pas',
  superdate in 'superobject\superdate.pas',
  superobject in 'superobject\superobject.pas',
  supertimezone in 'superobject\supertimezone.pas',
  supertypes in 'superobject\supertypes.pas',
  superxmlparser in 'superobject\superxmlparser.pas',
  ujsonrpc in 'jsonrpc\ujsonrpc.pas',
  stringgridutils in 'utils\stringgridutils.pas',
  stringutils in 'utils\stringutils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormProducts, FormProducts);
  Application.Run;
end.
