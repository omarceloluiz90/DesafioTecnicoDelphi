unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.SynCObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TException = class
   private
   { private declarations }
     FArquivoLog: string;
   public
     constructor Create;
     procedure TratarException(Sender: TObject; E: Exception);
     procedure EscreverLinhaLog(sLinha: string);
   end;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
  public
  end;

var
  fMain: TfMain;
  ViewExceptions: TException;

implementation

uses
  DatasetLoop, ClienteServidor, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads.Show;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  ViewExceptions := TException.Create();
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  ViewExceptions.Free;
end;

{ TException }

constructor TException.Create;
begin
  FArquivoLog := ChangeFileExt(ParamStr(0),'.log');
  Application.OnException := TratarException;
end;

procedure TException.EscreverLinhaLog(sLinha: string);
var iArquivoTexto: TextFile;
    ctsLog: TCriticalSection;
begin
  ctsLog := TCriticalSection.Create();

  try
    ctsLog.Enter;
    AssignFile(iArquivoTexto, FArquivoLog);

    if FileExists(FArquivoLog) then
      Append(iArquivoTexto)
    else
      ReWrite(iArquivoTexto);

    try
      WriteLn(iArquivoTexto, '---------------------------------------------------------');
      WriteLn(iArquivoTexto, FormatDateTime('DD/MM/YYYY HH:NN:SS.ZZZ', now), ' ', sLinha);
      WriteLn(iArquivoTexto, '---------------------------------------------------------');
      CloseFile(iArquivoTexto);
    except on E: Exception do
      CloseFile(iArquivoTexto);
    end;
  finally
    ctsLog.Leave;
    FreeAndNil(ctsLog);
  end;
end;

procedure TException.TratarException(Sender: TObject; E: Exception);
begin
  if TComponent(Sender) is TForm then
  begin
    EscreverLinhaLog('Form.Name: '+ TForm(Sender).Name);
    EscreverLinhaLog('Form.Caption: '+ TForm(Sender).Caption);
    EscreverLinhaLog('E.ClassName: '+ E.ClassName);
    EscreverLinhaLog('E.Message: '+ PChar(E.Message));
  end
  else
  begin
    EscreverLinhaLog('Form.Name: '+ TForm(TComponent(Sender).Owner).Name);
    EscreverLinhaLog('Form.Caption: '+ TForm(TComponent(Sender).Owner).Caption);
    EscreverLinhaLog('E.ClassName: '+ E.ClassName);
    EscreverLinhaLog('E.Message: '+ PChar(E.Message));
  end;

  raise Exception.Create(PChar(E.Message));
end;

end.
