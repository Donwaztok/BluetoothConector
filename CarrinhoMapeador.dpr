program CarrinhoMapeador;

uses
  System.StartUpCopy,
  FMX.Forms,
  Client in 'Client.pas' {FormBluetooth};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormBluetooth, FormBluetooth);
  Application.Run;
end.
