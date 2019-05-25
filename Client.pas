unit Client;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.StdCtrls, FMX.Controls.Presentation, System.Bluetooth,
  System.Bluetooth.Components, FMX.ScrollBox, FMX.Memo;

type
  TFormBluetooth = class(TForm)
    ToolBar1: TToolBar;
    LabelConexao: TLabel;
    Label1: TLabel;
    ComboBoxLista: TComboBox;
    ButtonConectarBluetooth: TButton;
    ButtonEnviarDadosControladora: TButton;
    ButtonAtivarReceberDadosControladora: TButton;
    ButtonDesativarReceberDadosControladora: TButton;
    MemoBluetooth: TMemo;
    Timer: TTimer;
    Bluetooth: TBluetooth;
    procedure ButtonConectarBluetoothClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonEnviarDadosControladoraClick(Sender: TObject);
    procedure ButtonAtivarReceberDadosControladoraClick(Sender: TObject);
    procedure ButtonDesativarReceberDadosControladoraClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ComboBoxListaClosePopup(Sender: TObject);
  private
    { Private declarations }
    BluetoothSocket : TBluetoothSocket;
    const UUID = '{00001101-0000-1000-8000-00805F9B34FB}';
    function ObterDevicePeloNome(pNomeDevice: String): TBluetoothDevice;
    function ConectarControladoraBluetooth(pNomeDevice: String): boolean;
    procedure ListarDispositivosPareadosNoCombo;
    procedure AtivarReceberDados;
    procedure DesativarReceberDados;
  public
    { Public declarations }
  end;

var
  FormBluetooth: TFormBluetooth;

implementation

{$R *.fmx}


{ TFormBluetooth }

function TFormBluetooth.ObterDevicePeloNome(pNomeDevice: String): TBluetoothDevice;
var lDevice: TBluetoothDevice;
begin
  Result := nil;
  for lDevice in Bluetooth.PairedDevices do begin
    if lDevice.DeviceName = pNomeDevice then begin
      Result := lDevice;
    end;
  end;
end;

function TFormBluetooth.ConectarControladoraBluetooth( pNomeDevice: String): boolean;
var
  lDevice: TBluetoothDevice;
begin
  Result := False;
  lDevice := ObterDevicePeloNome(pNomeDevice);
  if lDevice <> nil then
  begin
    BluetoothSocket := lDevice.CreateClientSocket(StringToGUID(UUID), False);
    if BluetoothSocket <> nil then
    begin
      BluetoothSocket.Connect;
      Result := BluetoothSocket.Connected
    end;
  end;
end;

procedure TFormBluetooth.TimerTimer(Sender: TObject);
var
DadoRecebido : System.TArray<System.Byte>;
begin
  Bluetooth.Enabled:=True;
  if (BluetoothSocket = nil) or (not BluetoothSocket.Connected) then
    ConectarControladoraBluetooth(ComboBoxLista.Selected.Text);
  if (BluetoothSocket <> nil) and (BluetoothSocket.Connected) then begin
    DadoRecebido:=BluetoothSocket.ReceiveData;
    if length(DadoRecebido) > 0 then begin
      DadoRecebido:=DadoRecebido + BluetoothSocket.ReceiveData;
      MemoBluetooth.Lines.Clear;
      MemoBluetooth.Lines.Add(DateTimeToStr(Now));
      MemoBluetooth.Lines.Add('Dado Recebido: ' +
      Trim(TEncoding.ANSI.GetString(DadoRecebido)));
    end;
    Application.ProcessMessages;
  end;
  DadoRecebido:=nil;
end;


procedure TFormBluetooth.ButtonAtivarReceberDadosControladoraClick(
  Sender: TObject);
begin
  AtivarReceberDados;
end;

procedure TFormBluetooth.ButtonConectarBluetoothClick(Sender: TObject);
begin
  LabelConexao.Text := '';
  if (ComboBoxLista.Selected <> nil) and (ComboBoxLista.Selected.Text <> '') then begin
    if ConectarControladoraBluetooth(ComboBoxLista.Selected.Text) then begin
      LabelConexao.Text := 'Conectado';
    end else begin
      LabelConexao.Text := 'Desconectado';
    end;
  end else begin
    ShowMessage('Selecione um dispositivo');
  end;
end;

procedure TFormBluetooth.ButtonDesativarReceberDadosControladoraClick(
  Sender: TObject);
begin
  DesativarReceberDados;
end;

procedure TFormBluetooth.ButtonEnviarDadosControladoraClick(Sender: TObject);
begin
  DesativarReceberDados;
  Bluetooth.Enabled:=True;
  if (BluetoothSocket = nil) or (not BluetoothSocket.Connected) then
    ConectarControladoraBluetooth(ComboBoxLista.Selected.Text);
  if (BluetoothSocket <> nil) and (BluetoothSocket.Connected) then begin
    MemoBluetooth.Lines.Clear;
    MemoBluetooth.Lines.Add(DateTimeToStr(Now));
    BluetoothSocket.SendData(TEncoding.UTF8.GetBytes('L'));
    MemoBluetooth.Lines.Add('Enviado: L');
    sleep(1000);
    MemoBluetooth.Lines.Add('Recebido: ' +
    Trim(TEncoding.ANSI.GetString(BluetoothSocket.ReceiveData)));
    MemoBluetooth.Lines.Add('Enviado: D');
    BluetoothSocket.SendData(TEncoding.UTF8.GetBytes('D'));
    sleep(1000);
    MemoBluetooth.Lines.Add('Recebido: ' +
    Trim(TEncoding.ANSI.GetString(BluetoothSocket.ReceiveData)));
    BluetoothSocket.Free;
  end;
end;

procedure TFormBluetooth.ComboBoxListaClosePopup(Sender: TObject);
begin
  LabelConexao.Text := '';
end;

procedure TFormBluetooth.ListarDispositivosPareadosNoCombo;
var lDevice: TBluetoothDevice;
begin
  ComboBoxLista.Clear;
  for lDevice in Bluetooth.PairedDevices do begin
    ComboBoxLista.Items.Add(lDevice.DeviceName);
  end;
end;

procedure TFormBluetooth.AtivarReceberDados;
begin
  MemoBluetooth.Lines.Clear;
  Timer.Enabled:=True;
  ButtonAtivarReceberDadosControladora.Enabled:=False;
  ButtonDesativarReceberDadosControladora.Enabled:=True;
end;

procedure TFormBluetooth.DesativarReceberDados;
begin
  Timer.Enabled:=False;
  ButtonAtivarReceberDadosControladora.Enabled:=True;
  ButtonDesativarReceberDadosControladora.Enabled:=False;
end;

procedure TFormBluetooth.FormShow(Sender: TObject);
begin
  ListarDispositivosPareadosNoCombo;
end;

end.
