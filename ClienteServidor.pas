unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Datasnap.DBClient, Data.DB;

type
  TServidor = class
  private
    FPath: AnsiString;
  public
    constructor Create;
    procedure DeletarArquivos(sDiretorio: string);
    function  PossuiArquivos(Attr, Val: Integer): boolean;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant; iNumero: integer): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;
    function InitDataset: TClientDataset;
  public
    procedure setProgress(iPosition: integer);
  end;

var
  fClienteServidor: TfClienteServidor;
  iNroArquivo: integer;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  try
    cds := InitDataset;
    iNroArquivo := 0;
    setProgress(0);

    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
      cds.Post;

      Inc(iNroArquivo, 1);
      {$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL, iNroArquivo);
      {$ENDREGION}

      setProgress(i);
    end;
  except on E: Exception do
    begin
      if (cds <> Nil) then
        FreeAndNil(cds);

      raise Exception.Create(E.Message);
    end;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
begin
 //
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  try
    try
      cds := InitDataset;
      iNroArquivo := 0;
      setProgress(0);

      for i := 0 to QTD_ARQUIVOS_ENVIAR do
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
        cds.Post;

        Inc(iNroArquivo, 1);
        FServidor.SalvarArquivos(cds.Data, iNroArquivo);

        cds.EmptyDataSet;
        setProgress(i);
      end;

      Application.MessageBox('Arquivos Enviados sem Erros.','Ok.', MB_OK + MB_ICONINFORMATION);
      setProgress(0);
    finally
      FreeAndNil(cds);
    end;
  except on E: Exception do
    begin
      if (cds <> Nil) then
        FreeAndNil(cds);

      raise Exception.Create(E.Message);
    end;
  end;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := AnsiString(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf');
  FServidor := TServidor.Create;

  ProgressBar.Position := 0;
  ProgressBar.Min := 0;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
end;

procedure TfClienteServidor.FormDestroy(Sender: TObject);
begin
  if FServidor <> Nil then
    FreeAndNil(FServidor);
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

procedure TfClienteServidor.setProgress(iPosition: integer);
begin
  ProgressBar.Position := iPosition;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\');
end;

procedure TServidor.DeletarArquivos(sDiretorio: string);
var iRet: Integer;
    F: TSearchRec;
begin
  iRet := FindFirst(sDiretorio + '\*.*', faAnyFile, F);

  if PossuiArquivos(F.Attr, faDirectory) then
  begin
    try
      try
        while (iRet = 0) do
        begin
          if (F.Name <> '.') and (F.Name <> '..') then
            DeleteFile(sDiretorio + F.Name);

          iRet := FindNext(F);
        end;
      except
        on E: Exception do
          raise Exception.Create(PChar(E.Message));
      end;
    finally
      FindClose(F);
    end;
  end;
end;

function TServidor.PossuiArquivos(Attr, Val: Integer): boolean;
begin
  result := Attr and Val = Val;
end;

function TServidor.SalvarArquivos(AData: OleVariant; iNumero: integer): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  Result := False;

  try
    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      if not DirectoryExists(String(FPath)) then
        ForceDirectories(String(FPath));

      //FileName := String(FPath) + cds.RecNo.ToString + '.pdf';
      FileName := String(FPath) + iNumero.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;

    Result := True;
    FreeAndNil(cds);
  except on E: Exception do
    begin
      DeletarArquivos(String(FPath));

      if (cds <> Nil) then
        FreeAndNil(cds);

      raise Exception.Create(E.Message);
    end;
  end;
end;

end.
