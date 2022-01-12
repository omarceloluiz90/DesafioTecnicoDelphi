unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Threading,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TParallelProcess = class(TThread)
  private
    FLine: string;
    FMemo: TMemo;
    FProgressBar: TProgressBar;
    FTempoEspera: integer;
  public
    constructor Create(AMemo: TMemo; AProgressBar: TProgressBar; ATempo: integer); reintroduce;
    destructor Destroy; reintroduce;
    procedure Execute; override;
    procedure doSynchronize;
    procedure doSynchronizeBar;
  end;

type
  TfThreads = class(TForm)
    edtNroThreads: TEdit;
    edtTempoEspera: TEdit;
    ProgressBar: TProgressBar;
    mmTexto: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    btnIniciar: TButton;
    procedure btnIniciarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTParallel: TParallelProcess;
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.btnIniciarClick(Sender: TObject);
var iCount, iNroThreads, iTempoEspera: integer;
begin
  iNroThreads := StrToIntDef(edtNroThreads.Text, 0);
  iTempoEspera := StrToIntDef(edtTempoEspera.Text, 0);

  ProgressBar.Position := 0;
  ProgressBar.Min := 0;
  ProgressBar.Max := (iNroThreads * 101);

  for iCount := 0 to Pred(iNroThreads) do
  begin
    Self.FTParallel := TParallelProcess.Create(mmTexto, ProgressBar, iTempoEspera);
    Self.FTParallel.Start();
  end;
end;

{ TParallelProcess }

constructor TParallelProcess.Create(AMemo: TMemo; AProgressBar: TProgressBar; ATempo: integer);
begin
  inherited Create(True);
  Self.FreeOnTerminate := True;

  FMemo := AMemo;
  FProgressBar := AProgressBar;

  FLine := '';
  FTempoEspera := ATempo;
end;

procedure TParallelProcess.Execute;
var iCount: Integer;
    iTempoEspera: integer;
begin
  inherited;

  Self.FLine := (Self.ThreadID.ToString) + ' - Iniciando processamento';
  Self.Synchronize(Self.doSynchronize);

  for iCount := 0 to 100 do
  begin
    if Self.Terminated then
      break
    else
    begin
      Self.Synchronize(Self.doSynchronizeBar);
      iTempoEspera:= Random(FTempoEspera);
      Self.Sleep(iTempoEspera);
    end;
  end;

  Self.FLine := (Self.ThreadID.ToString) + ' - Processamento finalizado';
  Self.Synchronize(Self.doSynchronize);
end;

destructor TParallelProcess.Destroy;
begin
  inherited;
end;

procedure TParallelProcess.doSynchronize;
begin
  FMemo.Lines.Add(Self.FLine);
end;

procedure TParallelProcess.doSynchronizeBar;
begin
  FProgressBar.Position := (FProgressBar.Position + 1);
end;

procedure TfThreads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Self.FTParallel <> nil) then
    if Self.FTParallel.Finished = False then
      Self.FTParallel.Terminate;
end;

end.
