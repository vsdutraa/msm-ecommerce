unit Usuario.DAO;

interface

uses
  ADRCOnn.Model.Interfaces,
  ADRCOnn.DAO.Base,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.StrUtils,
  Data.DB,
  DataSet.Serialize,
  RESTRequest4D;

type
  TStringArray = array of string;

type
  TADRConnAccessDAO = class(TADRConnDAOBase)
    public
      function ValidaAcessoUsuario (afiliado_cnpj, terminal, user, password, dispositivo, versao : string) : TStringArray;
      function CadastraUsuario (AfiCodigo,PerfilUsuario,NomeUsuario,
NomeExibicaoUsuario,UsuarioLogin,UsuarioSenha,UsuarioEmail,UsuarioTelefone : string;
out retorno : String) : Boolean;
      function AlteraUsuario (AfiCodigo,PerfilUsuario,NomeUsuario,
NomeExibicaoUsuario,UsuarioLogin,UsuarioSenha,UsuarioEmail,UsuarioTelefone : string;
out retorno : String) : Boolean;
      function CadastraPerfil (AfiCodigo,NomePerfil : String; out retorno : string) : Boolean;
      function AlteraPerfil (AfiCodigo, PerfilUsuario, NomePerfil : String; out retorno : String) : Boolean;
      function ListaUsuarios (AfiCodigo, UsuarioId : string) : TJsonObject;
      function AcessoUsuarioWeb (login, password, Afiliado : String) : TDataSet;
      function AcessoUsuarioWebCliente (Afiliado, login, password, Versao, Dispositivo : String) : TDataSet;
      function AcessoUsuarioDetran (login, password : string) : TDataSet;
      function GetUsuariosAfiliadoTerminais (AfiCOdigo, Operador : String) : TJsonArray;
      function GetAccess (login, password, Afiliado, Ambiente, Versao : String) : TDataSet;
      function RedefinirSenha(AfiCodigo, Login, Usuario : String) : Boolean; //Gera Senha Provisoria e envia por email...
      function AlteraSenhaDeAcesso(AfiCodigo, Login, SenhaAntigo, NovaSenha, NovaSenha2, tipo : String) : Boolean;
      function AlteraSenhaDeAcessoUsuario(AfiCodigo, Login, SenhaAntigo,NovaSenha, NovaSenha2, UserID: String): Boolean;

      //novo altera senha (substitui os outros)
      function AlteraSenhaPadrao(Login, SenhaNova, TipoAcesso, PesID, AfiCodigo, UsuID, SenhaAntiga: string; out retorno: string): boolean;
      function AlteraSenhaClienteBackoffice(Login, TipoAcesso, PesID, AfiCodigo, UsuID: string; out retorno, senha: string): boolean;

      function ResetTwoFactorToken(UsuID, Login, AfiCodigo: string; out retorno: string):boolean;

      //function AlteraSenhaPadrao(Login, SenhaNova, TipoAcesso, PesID, AfiCodigo, SenhaAntiga, Documento, Telefone: string; out retorno: string): boolean;
      function RedefineSenhaPadrao(Login, Tipo, Documento, Telefone, AfiCodigo: string; out retorno: string):boolean;
      function RedefineLoginAcesso(PesId, LoginAntigo, NovoLogin: string) : boolean;

      //Envio de Email
      function ProcEnviaEmail(const ACopia, ACopiaOculta, ATitulo, AAssunto, ADestino, AAnexo: String; ACorpo: TStrings): Boolean;
      function ValidaKeyTransacional(AfiCodigo ,PesID, key: String): boolean;
      function CadastraKeyTransacional(PesID, Login, Key, AfiCodigo: string; out retorno: string): boolean;
      function VisualizaKeyTransacional(Login, Senha, AfiCodigo, PesID: string; out retorno: string): boolean;
      function PostTwoFactorChange(AfiCodigo, PerfilAcessoID: String): boolean;

      //chats


      function ChatAfiliado(Documento, Afiliado: String): TJsonArray;
      function GetStatusAberturaChat(Documento: String): TJsonArray;
      function RespostaChat(PerguntaID, Documento, Afiliado, Resposta, IMEI: String; out Retorno: string): Boolean;
      function ListaUsuariosAfiliado(AfiCodigo: string): TJSONArray;

      function GravaChats(Ambiente, Descricao, TipoResposta, Obrigatorio, Placeholder, ValorPositivo, ValorNegativo, Categoria, PerId: string; out retorno: string): boolean;

      // processo de nova abertura

      function RetornaDadosPessoaAbertura(PesID, Documento: string): TJSONArray;
      function RetornaDadosSocioAbertura(PesID: string): TJSONArray;
      function RetornaDadosAberturaTipoJ(PesID: string): TJSONArray;
      function SalvaOnboardingIdPessoa(PesID, Documento, OnboardingID: string): boolean;

      // contas celcoin

      function SalvaContaCelcoin(dados: string): boolean;

      // FCM TOKEN E IMEI

      function ValidaImeiAparelho(PesID, AfiCodigo, IMEI: string; out retorno: string): boolean;
      function ValidaTokenPushAparelho(PesID, AfiCodigo, FCM: string; out retorno: string): boolean;
      function ValidaDocumentoPessoa(PesID, DocID, UsuID, Documento, validade: string; out retorno: string): boolean;
      function ResetImeiAparelhoPessoa(PesID, AfiCodigo, UsuID: string; out retorno: string): boolean;

      function RetornaVersaoAmbiente(AfiCodigo, Ambiente: string): TJSONArray;

      function CriaInativaAcessoAPI(AfiCodigo, Login, Senha, APiKey, UsuID, ACP_ID, Status, Resetar: string; out retorno: string): boolean;
      function VisualizaAcessoAPI(AfiCodigo: string): TJSONArray;

      function RetornaDadosAberturaTipoAfiliado(PesID: string): TJSONArray;
      function RetornaDadosSocioAberturaAfiliado(PesID: string): TJSONArray;

  end;

implementation

uses
  System.IniFiles, IdSSLOpenSSL, IdSMTP, IdText, IdMessage,
  IdExplicitTLSClientServerBase, IdAttachmentFile;

{ TADRConnMDPDAO }

function TADRConnAccessDAO.ProcEnviaEmail(const ACopia, ACopiaOculta, ATitulo, AAssunto, ADestino, AAnexo: String; ACorpo: TStrings): Boolean;
var
  IniFile              : TIniFile;
  sFrom                : String;
  sBccList             : String;
  sHost                : String;
  iPort                : Integer;
  sUserName            : String;
  sPassword            : String;
  idMsg                : TIdMessage;
  idText               : TIdText;
  idSMTP               : TIdSMTP;
  idSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
begin
  try
    try
      //Criação e leitura do arquivo INI com as configurações
      IniFile                          := TIniFile.Create('C:\SRVSAQUEI\ConfigEmail.ini');

      sFrom                            := IniFile.ReadString('Email' , 'From'     , sFrom);
      sBccList                         := IniFile.ReadString('Email' , 'BccList'  , sBccList);
      sHost                            := IniFile.ReadString('Email' , 'Host'     , sHost);
      iPort                            := IniFile.ReadInteger('Email', 'Port'     , iPort);
      sUserName                        := IniFile.ReadString('Email' , 'UserName' , sUserName);
      sPassword                        := IniFile.ReadString('Email' , 'Password' , sPassword);


      //Configura os parâmetros necessários para SSL
      IdSSLIOHandlerSocket                   := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
      IdSSLIOHandlerSocket.SSLOptions.Mode  := sslmClient;
      //Variável referente a mensagem
      idMsg                            := TIdMessage.Create(nil);
      idMsg.CharSet                    := 'utf-8';
      idMsg.Encoding                   := meMIME;
      idMsg.From.Name                  := ATitulo;
      idMsg.From.Address               := sFrom;
      idMsg.Priority                   := mpNormal;
      idMsg.Subject                    := AAssunto;
      //Add Destinatário(s)
      idMsg.Recipients.Add;

      if Pos('@',ADestino) <= 0 then
        idMsg.Recipients.EMailAddresses := 'pdr.albuquerque@hotmail.com'
      else
        idMsg.Recipients.EMailAddresses := ADestino;

      if ACopia <> '' then
        idMsg.CCList.EMailAddresses      := ACopia;
      if ACopiaOculta <> '' then
      begin
        idMsg.BccList.EMailAddresses    := sBccList;
        idMsg.BccList.EMailAddresses    := ACopiaOculta; //Cópia Oculta
      end;
      //Variável do texto
      idText := TIdText.Create(idMsg.MessageParts);
      idText.Body.Add(ACorpo.Text);
      idText.ContentType := 'text/html; text/plain; charset=iso-8859-1';
      //Prepara o Servidor
      idSMTP                           := TIdSMTP.Create(nil);
      idSMTP.IOHandler                 := IdSSLIOHandlerSocket;
      idSMTP.UseTLS                    := utUseImplicitTLS;
      idSMTP.AuthType                  := satDefault;
      idSMTP.Host                      := sHost;
      idSMTP.AuthType                  := satDefault;
      idSMTP.Port                      := iPort;
      idSMTP.Username                  := sUserName;
      idSMTP.Password                  := sPassword;
      //Conecta e Autentica


      idSMTP.Connect;

      idSMTP.Authenticate;

      if AAnexo <> EmptyStr then
        if FileExists(AAnexo) then
          TIdAttachmentFile.Create(idMsg.MessageParts, AAnexo);
      //Se a conexão foi bem sucedida, envia a mensagem
      if idSMTP.Connected then
      begin
        try

          IdSMTP.Send(idMsg);

        except on E:Exception do
          begin

          end;
        end;
      end;
      //Depois de tudo pronto, desconecta do servidor SMTP
      if idSMTP.Connected then
        idSMTP.Disconnect;
      Result := True;
    finally
      IniFile.Free;
      UnLoadOpenSSLLibrary;
      FreeAndNil(idMsg);
      FreeAndNil(idSSLIOHandlerSocket);
      FreeAndNil(idSMTP);
    end;
  except on e:Exception do
    begin
      Result := False;

    end;
  end;
end;

function TADRConnAccessDAO.AcessoUsuarioDetran(login, password: string): TDataSet;
const
  xSQl = 'SELECT * FROM STP_ACESSOUSUARIOWEBAPI(:P1,:P2)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',login)
                .ParamAsString('P2',password)
                .OpenDataSet;

  result := LDataSet;
end;

function TADRConnAccessDAO.AcessoUsuarioWeb(login,
  password, Afiliado: String): TDataSet;
const
  xSQl = 'SELECT * FROM STP_ACESSOWEBMOBILE(:P1,:P2,:P3)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',login)
                .ParamAsString('P2',password)
                .paramAsString('P3',Afiliado)
                .OpenDataSet;

  Result := LDataSet;
end;

function TADRConnAccessDAO.AcessoUsuarioWebCliente(Afiliado, login, password, Versao, Dispositivo: String): TDataSet;
const
  xSQl = 'SELECT * FROM STP_ACESSO_CLIENTE(:P1,:P2,:P3,:P4,:P5)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',Afiliado)
                .ParamAsString('P2',login)
                .paramAsString('P3',password)
                .paramAsString('P4',Versao)
                .paramAsString('P5',Dispositivo)
                .OpenDataSet;

  Result := LDataSet;
end;

function TADRConnAccessDAO.AlteraPerfil(AfiCodigo, PerfilUsuario,
  NomePerfil: String; out retorno: String): Boolean;
const
  xSQl = 'SELECT * FROM STP_ALTERAPERFILACESSO(:P1,:P2,:P3)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',PerfilUsuario)
                .ParamAsString('P3',NomePerfil)
                .OpenDataSet;

  if not LDataSet.IsEmpty then
  begin
    Result  := UpperCase(LDataSet.FieldByName('OUT_RETORNO').AsString) = 'OK PERFIL ALTERADO.';
    retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
  end
    else
  begin
    Result  := false;
    retorno := 'ERRO PERFIL NAO ALTERADO.';
  end;
end;

function TADRConnAccessDAO.AlteraSenhaClienteBackoffice(Login, TipoAcesso,
  PesID, AfiCodigo, UsuID: string; out retorno, senha: string): boolean;
const
  xsql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_ALTER_SENHA_ACESSO(:P1,:P2,:P3,:P4,:P5,:P6,:P7,:P8)';
var
  Ldataset : TDataSet;
  xNewPass : String;
  xCorpoStr : TStringList;
  LResponse: IResponse;
  function GeraCodigoInterno(Tamanho: Integer): String;
  var
    I: Integer;
  begin
    if Tamanho = -1 then
      Tamanho := Random(255);

    Setlength(Result, Tamanho);
    for I := 1 to Tamanho do
    begin
      if Random(2) = 0 then
        Result[I] := Chr(Ord('A') + Random(Ord('Z') - Ord('A') + 1))
      else
        Result[I] := Chr(Ord('0') + Random(Ord('9') - Ord('0') + 1));
    end;
  end;
begin
  try

    xNewPass := GeraCodigoInterno(10);

    FQuery
        .SQL(xsql)
        .ParamAsString('P1',Login)
        .ParamAsString('P2',xNewPass)
        .ParamAsString('P3',TipoAcesso)
        .ParamAsString('P4',PesID)
        .ParamAsString('P5',AfiCodigo)
        .ParamAsString('P7','S');

    if UsuID <> '' then
      FQuery.ParamAsString('P6',UsuID);

    LDataSet :=  FQuery.OpenDataSet;

    Result  := LDataset.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
    Retorno := LDataset.FieldByName('OUT_RETORNO').AsString;
    senha := xNewPass;

  except
    Result := false;
  end;

end;

function TADRConnAccessDAO.AlteraSenhaDeAcesso(AfiCodigo, Login, SenhaAntigo,
  NovaSenha, NovaSenha2, tipo: String): Boolean;
const
  xSql = 'UPDATE PESSOAS SET PES_AFILIADO_SENHA = :P1, PES_ALTER_SENHAPL = ''N'' WHERE PES_AFI_CODIGO = :P2 AND PES_LOGIN_CLIENTE = :P3 AND PES_AFILIADO_SENHA = :P4 ';
  xValidaPessoa = 'SELECT PES_ID FROM PESSOAS WHERE PES_AFI_CODIGO = :P1 AND PES_LOGIN_CLIENTE = :P2 AND PES_AFILIADO_SENHA = :P3 AND COALESCE(PES_ALTER_SENHAPL,''N'') = ''S''';
  xUpdateAlterSenha = 'UPDATE PESSOAS SET PES_ALTER_SENHAPL = ''S'' WHERE PES_AFI_CODIGO = :P1 AND PES_LOGIN_CLIENTE = :P2 AND PES_AFILIADO_SENHA = :P3 ';
var
  LdataSet : TDataSet;
begin
  try
    if NovaSenha =  NovaSenha2 then
    begin
      //ADICIONEI UM TIPO PARA SABER SE A ALTERACAO DE SENHA É DE DENTRO DA PLATAFORMA, ASSIM ELE LIBERA A ALTERAÇÃO (WALLETZ)
      if tipo = 'S' then
      begin
        FQuery
            .SQL(xUpdateAlterSenha)
            .ParamAsString('P1',AfiCodigo)
            .ParamAsString('P2',Login)
            .ParamAsString('P3',SenhaAntigo)
            .ExecSQLAndCommit;

      end;

       LDataSet := FQuery
                   .SQL(xValidaPessoa)
                   .ParamAsString('P1',AfiCodigo)
                   .ParamAsString('P2',Login)
                   .ParamAsString('P3',SenhaAntigo)
                   .OpenDataSet;

      if LdataSet.FieldByName('PES_ID').AsInteger > 0 then
      begin
        FQuery
            .SQL(xSql)
            .ParamAsString('P1',NovaSenha)
            .ParamAsString('P2',AfiCodigo)
            .ParamAsString('P3',Login)
            .ParamAsString('P4',SenhaAntigo)
            .ExecSQLAndCommit;
          Result := True;
      end
        else
        Result := false;
    end
      else
    Result := false;
  except
    Result := false;
  end;
end;


function TADRConnAccessDAO.AlteraSenhaDeAcessoUsuario(AfiCodigo, Login, SenhaAntigo,
  NovaSenha, NovaSenha2, UserID: String): Boolean;
const
  xSql = 'UPDATE USUARIOS SET USU_SENHA = :P1, USU_ALTERASENHA_PROXLOGIN = ''N'' WHERE AFI_CODIGO = :P2 AND USU_LOGIN = :P3 AND USU_SENHA = :P4 AND USU_ID = :P5';

var
  LdataSet : TDataSet;
begin
  try
    if NovaSenha =  NovaSenha2 then
    begin

        FQuery
            .SQL(xSql)
            .ParamAsString('P1',NovaSenha)
            .ParamAsString('P2',AfiCodigo)
            .ParamAsString('P3',Login)
            .ParamAsString('P4',SenhaAntigo)
            .ParamAsString('P5',UserID)
            .ExecSQLAndCommit;

        Result := True;
    end
      else
    Result := false;
  except
    Result := false;
  end;
end;

function TADRConnAccessDAO.AlteraSenhaPadrao(Login, SenhaNova, TipoAcesso,
  PesID, AfiCodigo, UsuID, SenhaAntiga: string; out retorno: string): boolean;
const
  xsql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_ALTER_SENHA_ACESSO(:P1,:P2,:P3,:P4,:P5,:P6,:P7,:P8)';
var
  Ldataset : TDataSet;
begin
  try
    FQuery
        .SQL(xsql)
        .ParamAsString('P1',Login)
        .ParamAsString('P2',SenhaNova)
        .ParamAsString('P3',TipoAcesso)
        .ParamAsString('P4',PesID)
        .ParamAsString('P5',AfiCodigo)
        .ParamAsString('P8',SenhaAntiga);


    if UsuID <> '' then
      FQuery.ParamAsString('P6',UsuID);

    LDataSet :=  FQuery.OpenDataSet;

    Result  := LDataset.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
    Retorno := LDataset.FieldByName('OUT_RETORNO').AsString;

  except
    Result := false;
    Retorno := 'erro interno';
  end;

end;

function TADRConnAccessDAO.AlteraUsuario(AfiCodigo, PerfilUsuario, NomeUsuario,
  NomeExibicaoUsuario, UsuarioLogin, UsuarioSenha, UsuarioEmail,
  UsuarioTelefone: String; out retorno: String): Boolean;
const
  xSQl = 'SELECT * FROM STP_ALTERAUSUARIOS(:P1,:P2,:P3,:P4,:P5,:P6)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',PerfilUsuario)
                .ParamAsString('P3',NomeUsuario)
                .ParamAsString('P4',NomeExibicaoUsuario)
                .ParamAsString('P5',UsuarioLogin)
                .ParamAsString('P6',UsuarioSenha)
                .ParamAsString('P7',UsuarioEmail)
                .ParamAsString('P8',UsuarioTelefone)
                .OpenDataSet;

  if not LDataSet.IsEmpty then
  begin
    Result  := UpperCase(LDataSet.FieldByName('OUT_RETORNO').AsString) = 'OK. USUARIO ALTERADO.';
    retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
  end
    else
  begin
    Result  := false;
    retorno := 'ERRO - Usuario nao cadastrado.';
  end;

end;

function TADRConnAccessDAO.CadastraKeyTransacional(PesID, Login, Key, AfiCodigo: string; out retorno: string): boolean;
const
  xSQl = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_CAD_SENHA_TRANSAC(:P1,:P2,:P3,:P4)';
var
  LDataSet : TDataSet;
begin
  try
     LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',PesID)
                .ParamAsString('P2',Login)
                .ParamAsString('P3',Key)
                .ParamAsString('P4',AfiCodigo)
                .OpenDataSet;

    if LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
    begin
      Result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
    end
      else
    begin
      if AfiCodigo = 'MEDPY001' then
      begin

        LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',PesID)
                .ParamAsString('P2',Login)
                .ParamAsString('P3',Key)
                .ParamAsString('P4','NVDGS001')
                .OpenDataSet;

        if LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
        begin
          Result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
          retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
        end
          else
        begin

          LDataset := FQuery
                  .SQL(xSQl)
                  .ParamAsString('P1',PesID)
                  .ParamAsString('P2',Login)
                  .ParamAsString('P3',Key)
                  .ParamAsString('P4','MDCSM001')
                  .OpenDataSet;


          Result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
          retorno := LDataSet.FieldByName('OUT_RETORNO').AsString

        end;

      end
        else
      begin
        Result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
        retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
      end;

    end;

  Except on E: Exception do

    begin
      Result  := false;
      retorno := E.Message;
    end;

  end;

end;

function TADRConnAccessDAO.CadastraPerfil(AfiCodigo, NomePerfil: String; out retorno: String): Boolean;
const
  xSQl = 'SELECT * FROM STP_GRAVAPERFILACESSO(:P1,:P2)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',NomePerfil)
                .OpenDataSet;

  if not LDataSet.IsEmpty then
  begin
    Result  := UpperCase(LDataSet.FieldByName('OUT_RETORNO').AsString) = 'OK PERFIL GRAVADO.';
    retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
  end
    else
  begin
    Result  := false;
    retorno := 'ERRO PERFIL NAO GRAVADO.';
  end;
end;

function TADRConnAccessDAO.CadastraUsuario(AfiCodigo,PerfilUsuario,NomeUsuario,
NomeExibicaoUsuario,UsuarioLogin,UsuarioSenha,UsuarioEmail,UsuarioTelefone : String;
out retorno : String): Boolean;
const
  xSQl = 'SELECT * FROM STP_GRAVAUSUARIOS(:P1,:P2,:P3,:P4,:P5,:P6)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',PerfilUsuario)
                .ParamAsString('P3',NomeUsuario)
                .ParamAsString('P4',NomeExibicaoUsuario)
                .ParamAsString('P5',UsuarioLogin)
                .ParamAsString('P6',UsuarioSenha)
                .ParamAsString('P7',UsuarioEmail)
                .ParamAsString('P8',UsuarioTelefone)
                .OpenDataSet;

  if not LDataSet.IsEmpty then
  begin
    Result  := UpperCase(LDataSet.FieldByName('OUT_RETORNO').AsString) = 'OK. USUARIO ALTERADO.';
    retorno := LDataSet.FieldByName('OUT_RETORNO').AsString
  end
    else
  begin
    Result  := false;
    retorno := 'ERRO - Usuario nao cadastrado.';
  end;

end;

function TADRConnAccessDAO.GetAccess(login, password,
  Afiliado, Ambiente, Versao: String): TDataSet;
const
  xSQl = 'SELECT * FROM STP_ACESSO_BACKOFFICE(:P1,:P2,:P3,:P4,:P5)';
var
  LDataSet : TDataSet;
begin
  LDataset := FQuery
                .SQL(xSQl)
                .ParamAsString('P1',login)
                .ParamAsString('P2',password)
                .paramAsString('P3',Afiliado)
                .paramAsString('P4',Ambiente)
                .paramAsString('P5',Versao)
                .OpenDataSet;

  Result := LDataSet;

end;

function TADRConnAccessDAO.GetUsuariosAfiliadoTerminais(AfiCOdigo, Operador: String): TJsonArray;
const
  xSQLusuID = 'SELECT USUARIOS.USU_ID, USUARIOS.USU_TERMINAL, USUARIOS.AFI_CODIGO, USUARIOS.USU_STATUS, USUARIOS.USU_NOME, USUARIOS.USU_NOMEEXIBICAO FROM USUARIOS WHERE USUARIOS.AFI_CODIGO = :P1';
var
  LDataSet : TDataSet;
begin
  try
    if Operador = 'N' then
    begin

      LDataSet := FQuery
                .SQL(xSQLusuID + ' AND COALESCE(USU_TIPO,'''') NOT IN (''BCF'')')
                .ParamAsString('P1',AfiCodigo)
                .OpenDataSet;
    end
      else
    begin

      LDataSet := FQuery
                  .SQL(xSQLusuID)
                  .ParamAsString('P1',AfiCodigo)
                  .OpenDataSet;

    end;

  finally
    Result := LDataSet.ToJSONArray;
  end;
end;



function TADRConnAccessDAO.ListaUsuarios(AfiCodigo, UsuarioId : string): TJsonObject;
const
  xSQLusuID = 'SELECT * FROM VW_USUARIOS WHERE AFI_CODIGO = :P1';

var
  LDataSet : TDataSet;
begin
  try
    if UsuarioId <> '' then
    begin
      LDataSet := FQuery
                  .SQL(xSQLusuID+' AND USU_ID = :P2')
                  .ParamAsString('P1',AfiCodigo)
                  .ParamAsString('P2',UsuarioId)
                  .OpenDataSet;
    end
      else
    begin
      LDataSet := FQuery
                  .SQL(xSQLusuID)
                  .ParamAsString('P1',AfiCodigo)
                  .OpenDataSet;
    end;

      if not LDataSet.IsEmpty then
      begin
        Result := LDataSet.ToJSONObject()
      end
        else
      Result := LDataSet.ToJSONObject().AddPair('Mensagem','Usuário não localizado.');
  finally
    LDataSet.Free;
  end;
end;

function TADRConnAccessDAO.ListaUsuariosAfiliado(AfiCodigo: string): TJSONArray;
const
  xSql = 'SELECT USUARIOS.PES_ID, COALESCE(USU_ID,0) AS USUARIO_ID,USU_NOMEEXIBICAO, USU_TIPO ,USU_LOGIN,'+'PERFILACESSO.PFA_DESCRICAO, COALESCE(USU_STATUS,''I'') STATUS_ACESSO, COALESCE(USU_SENHA_TRANSA_ALT,''N'') STATUS_SENHATRANSAC, COALESCE(USU_ALTERASENHA_PROXLOGIN,''N'') STATUS_SENHACESSO, COALESCE(USUARIOS.USU_TWOFACTOR_TOKEN,''F'') STATUS_TOKEN,'+'COALESCE(PERFILACESSO.PFA_ID,0) AS PERFIL_ID FROM USUARIOS LEFT JOIN PERFILACESSO ON (PERFILACESSO.PFA_ID = USUARIOS.PFA_ID) WHERE USUARIOS.AFI_CODIGO = :P1 AND USU_TIPO = ''BCF''';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',AfiCodigo)
                .OpenDataSet;

    finally
      result := LDataSet.ToJSONArray();
    end;

  except on E: Exception do
    result := LDataSet.ToJSONArray();
  end;

end;

function GeraCodigoInterno(Tamanho: Integer): String;
var
  I: Integer;
begin
  if Tamanho = -1 then
    Tamanho := Random(255);

  Setlength(Result, Tamanho);
  for I := 1 to Tamanho do
  begin
    if Random(2) = 0 then
      Result[I] := Chr(Ord('A') + Random(Ord('Z') - Ord('A') + 1))
    else
      Result[I] := Chr(Ord('0') + Random(Ord('9') - Ord('0') + 1));
  end;
end;

//Redefinicao de Senha de Acesso...
function TADRConnAccessDAO.RedefineLoginAcesso(PesId, LoginAntigo,
  NovoLogin: string): boolean;
const
  SqlLogin = 'UPDATE PESSOAS SET PES_LOGIN_CLIENTE = :P1 WHERE PESSOAS.PES_ID = :P2 AND PES_LOGIN_CLIENTE = :P3 ';
begin
  try
    FQuery
      .SQL(SqlLogin)
      .ParamAsString('P1',NovoLogin)
      .ParamAsString('P2',PesId)
      .ParamAsString('P3',LoginAntigo)
      .ExecSQLAndCommit;
  finally
    Result := True;
  end;
end;

function TADRConnAccessDAO.RedefineSenhaPadrao(Login, Tipo, Documento, Telefone, AfiCodigo: string; out retorno: string): boolean;
const
  xsql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_REDEF_SENHA_ACESSO (:P1,:P2,:P3,:P4,:P5,:P6)';
  xSqlTelefone = 'SELECT COALESCE(PES_TELEFONE,'''') AS TELEFONE_PES, PES_NOME FROM PESSOAS WHERE PES_AFI_CODIGO = :P1 AND PES_LOGIN_CLIENTE = :P2 AND PES_CPF_CNPJ = :P3';
var
  LDataSet : TDataSet;
  LResponseZap : IResponse;
  xNewPass, Cliente, xmsg, xbody, xChave, xToken : String;
begin
  try
    LDataSet := FQuery
                  .SQL(xSqlTelefone)
                  .ParamAsString('P1',AfiCodigo)
                  .ParamAsString('P2',Login)
                  .ParamAsString('P3',Documento)
                  .OpenDataSet;

    if not LDataset.FieldByName('TELEFONE_PES').IsNull then
    begin
      Cliente := LDataset.FieldByName('PES_NOME').AsString;
      if LDataset.FieldByName('TELEFONE_PES').AsString = Telefone then
      begin
        xNewPass := GeraCodigoInterno(10);

        LDataSet:= FQuery
                  .SQL(xSql)
                  .ParamAsString('P1',Login)
                  .ParamAsString('P2',xNewPass)
                  .ParamAsString('P3',Tipo)
                  .ParamAsString('P4',Documento)
                  .ParamAsString('P5',Telefone)
                  .ParamAsString('P6',AfiCodigo)
                  .OpenDataSet;

        if LDataset.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
        begin

          xChave := '3B3217A290E490C7CC3DA2CB4232B497';
          xToken := 'F4B25E1AEAC90C0BE2629DA6';

          xmsg := '*Olá, '+Cliente+'\n\nUma solicitação de redefinir senha foi realizada. \nSenha de acesso: '+xNewPass+'';

          xbody := '{"phone":"'+'55'+Telefone+'", "message":"'+xmsg+'"}';

          LResponseZap := TRequest.New.BaseURL('https://api.plugzapi.com.br/instances/'+xchave+'/token/'+xtoken+'/send-messages')
                              .AddBody(xBody)
                              .AddHeader('Client-Token','Fd12760a313c649dc9b0017695e7f9db1S')
                              .Accept('application/json')
                              .Post;


          if LResponseZap.StatusCode = 200 then
          begin
            Result := true;
            Retorno := LDataset.FieldByName('OUT_RETORNO').AsString;
          end
            else
          begin
            Result := false;
            Retorno := 'Erro ao enviar mensagem';
          end;

        end
          else
        begin
          Result := false;
          Retorno := LDataset.FieldByName('OUT_RETORNO').AsString;
        end;

      end
        else
      begin
        result:= false;
        retorno:= 'Numero diferente do cadastro';
      end;

    end
      else
    begin
      Result := False;
      retorno := 'Numero nao encontrado';
    end;

  except on E: Exception do
    begin
      Result := false;
      retorno:= E.message;
    end;
  end;
end;


function TADRConnAccessDAO.RedefinirSenha(AfiCodigo, Login, Usuario: String): Boolean;
const
  xsql = 'UPDATE PESSOAS SET PES_AFILIADO_SENHA = :P1, PES_ALTER_SENHAPL = ''S'' WHERE PES_AFI_CODIGO = :P2 AND PES_LOGIN_CLIENTE = :P3';
  xSqlEmail = 'SELECT PES_EMAIL, PES_NOME FROM PESSOAS WHERE PES_AFI_CODIGO = :P1 AND PES_LOGIN_CLIENTE = :P2';
var
  Ldataset : TDataSet;
  xNewPass : String;
  xCorpoStr : TStringList;
  LResponse: IResponse;
  function GeraCodigoInterno(Tamanho: Integer): String;
  var
    I: Integer;
  begin
    if Tamanho = -1 then
      Tamanho := Random(255);

    Setlength(Result, Tamanho);
    for I := 1 to Tamanho do
    begin
      if Random(2) = 0 then
        Result[I] := Chr(Ord('A') + Random(Ord('Z') - Ord('A') + 1))
      else
        Result[I] := Chr(Ord('0') + Random(Ord('9') - Ord('0') + 1));
    end;
  end;
begin
  try
    LDataSet := FQuery
                  .SQL(xSqlEmail)
                  .ParamAsString('P1',AfiCodigo)
                  .ParamAsString('P2',Login)
                  .OpenDataSet;

    if not LDataset.FieldByName('PES_EMAIL').IsNull then
    begin
      xNewPass := GeraCodigoInterno(18);

      try
        FQuery
          .SQL(xSql)
          .ParamAsString('P2',AfiCodigo)
          .ParamAsString('P3',Login)
          .ParamAsString('P1',xNewPass)
          .ExecSQLAndCommit;

        LResponse := TRequest.New.BaseURL('http://localhost:2525/HostSendSmtp')
          .BasicAuthentication('hostSMtp.909011', 'seNd@2023@')
          .addHeader('x-tipoEmail','acessos')
          .addHeader('x-Afiliado',Usuario)
          .addHeader('x-Password',xNewPass)
          .addHeader('x-Destino',LDataset.FieldByName('PES_EMAIL').AsString)
          .Accept('application/json')
          .Put;

        result := true;

      except on E: exception do
        Result := False;
      end;

    end
      else
    begin
      Result := False;
    end;
  except
    Result := false;
  end;
end;

function TADRConnAccessDAO.ValidaAcessoUsuario(afiliado_cnpj, terminal, user,
  password, dispositivo, versao: string): TStringArray;
const
  SQLComprovantePagamento = 'SELECT OUT_TOKEN_SITEF, OUT_CEPBTG, OUT_NOMECONTABTG, OUT_RUABTG, OUT_NUMEROBTG, OUT_COMPLEMENTOBTG, OUT_BAIRROBTG, '+' OUT_CIDADEBTG, OUT_ESTADOBTG, OUT_RETORNO, OUT_AFILIADOCODIGO, OUT_CHAVE_PIX, OUT_USER_ID, OUT_USER_NOME, OUT_USER_NOME_EXIBICAO, OUT_TERMINAL, '+'OUT_EMAIL, OUT_CNPJAFILIADO, OUT_TELEFONE, OUT_LOGO, OUT_CODTERMINALTEF, OUT_CONTA, OUT_AGENCIA, OUT_DOCUMENTO, OUT_TIPOACESSO FROM STP_ACESSOUSUARIO(:P1,:P2,:P3,:P4,:P5,:P6)';
var
  LDataSet : TDataSet;
begin
  try
    LDataSet := FQuery
                  .SQL(SQLComprovantePagamento)
                  .ParamAsString('P1',afiliado_cnpj)
                  .ParamAsString('P2',terminal)
                  .ParamAsString('P3',user)
                  .ParamAsString('P4',password)
                  .ParamAsString('P5',versao)
                  .ParamAsString('P6',dispositivo)
                  .OpenDataSet;

    {      out_conta, out_agencia, out_documento

    out_user_id,
    out_user_nome_exibicao,
    out_user_nome,
    out_afiliadocodigo,
    out_terminal,
    out_email;

    }

      SetLength(Result,25);

      if LDataSet.FieldByName('OUT_RETORNO').AsString = '200 - Acesso Liberado.' then
      begin
        Result[0] := LDataSet.FieldByName('OUT_RETORNO').AsString;
        Result[1] := LDataSet.FieldByName('OUT_AFILIADOCODIGO').AsString;
        Result[2] := LDataSet.FieldByName('OUT_USER_ID').AsString;
        Result[3] := LDataSet.FieldByName('OUT_USER_NOME').AsString;
        Result[4] := LDataSet.FieldByName('OUT_USER_NOME_EXIBICAO').AsString;
        Result[5] := LDataSet.FieldByName('OUT_TERMINAL').AsString;
        Result[6] := LDataSet.FieldByName('OUT_EMAIL').AsString;
        Result[7] := LDataSet.FieldByName('OUT_CNPJAFILIADO').AsString;
        Result[8] := LDataSet.FieldByName('OUT_TELEFONE').AsString;
        Result[9] := LDataSet.FieldByName('OUT_LOGO').AsString;
        Result[10] := LDataSet.FieldByName('OUT_CODTERMINALTEF').AsString;
        Result[11] := LDataSet.FieldByName('OUT_CONTA').AsString;
        Result[12] := LDataSet.FieldByName('OUT_AGENCIA').AsString;
        Result[13] := LDataSet.FieldByName('OUT_DOCUMENTO').AsString;
        Result[14] := LDataSet.FieldByName('OUT_CHAVE_PIX').AsString;

        Result[15] := LDataSet.FieldByName('OUT_RUABTG').AsString;
        Result[16] := LDataSet.FieldByName('OUT_NUMEROBTG').AsString;
        Result[17] := LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString;
        Result[18] := LDataSet.FieldByName('OUT_BAIRROBTG').AsString;
        Result[19] := LDataSet.FieldByName('OUT_CIDADEBTG').AsString;
        Result[20] := LDataSet.FieldByName('OUT_ESTADOBTG').AsString;

        Result[21] := LDataSet.FieldByName('OUT_CEPBTG').AsString;

        Result[22] := LDataSet.FieldByName('OUT_NOMECONTABTG').AsString;
        Result[23] := LDataSet.FieldByName('OUT_TIPOACESSO').AsString;

        Result[24] := LDataSet.FieldByName('OUT_TOKEN_SITEF').AsString;

      end
        else
      Result[0] := LDataSet.FieldByName('OUT_RETORNO').AsString;

  finally
    LDataSet.Free;
  end;
end;


function TADRConnAccessDAO.ValidaKeyTransacional(AfiCodigo ,PesID, key: String): boolean;
const
  xSql = 'SELECT PES_SENHA_TRANSAC FROM PESSOAS WHERE PES_AFI_CODIGO = :P1 AND PES_ID = :P2';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',PesID)
                .OpenDataSet;

    if LdataSet.fieldbyname('PES_SENHA_TRANSAC').AsString = key then
    begin
      result:= true;
    end
      else
    begin
      result:= false;
    end;

  except on E: Exception do
    result := false
  end;

end;



function TADRConnAccessDAO.VisualizaKeyTransacional(Login, Senha, AfiCodigo, PesID: string; out retorno: string): boolean;
const
  xSql = 'SELECT COALESCE(PES_SENHA_TRANSAC,'''') AS SENHA_TRANSAC FROM PESSOAS WHERE PES_LOGIN_CLIENTE = :P1 AND PES_AFILIADO_SENHA = :P2 AND PES_STATUS = ''A'' AND PES_AFI_CODIGO = :P3 AND PES_ID = :P4 AND PES_SENHA_TRANSAC IS NOT NULL';
var
  LdataSet : TDataSet;
begin
  try

    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',Login)
              .ParamAsString('P2',Senha)
              .ParamAsString('P3',AfiCodigo)
              .ParamAsString('P4',PesID)
              .OpenDataSet;

    if not LdataSet.IsEmpty then
    begin
      result  := true;
      Retorno := LDataSet.FieldByName('SENHA_TRANSAC').AsString;
    end
      else
    begin
      if AfiCodigo = 'MEDPY001' then
      begin
          LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',Login)
                .ParamAsString('P2',Senha)
                .ParamAsString('P3','NVDGS001')
                .ParamAsString('P4',PesID)
                .OpenDataSet;

        if not LdataSet.IsEmpty then
        begin

          result  := true;
          Retorno := LDataSet.FieldByName('SENHA_TRANSAC').AsString;

        end
          else
        begin

          LDataSet := FQuery
                        .SQL(xSql)
                        .ParamAsString('P1',Login)
                        .ParamAsString('P2',Senha)
                        .ParamAsString('P3','MDCSM001')
                        .ParamAsString('P4',PesID)
                        .OpenDataSet;

          if not LdataSet.IsEmpty then
          begin

            result  := true;
            Retorno := LDataSet.FieldByName('SENHA_TRANSAC').AsString;

          end
            else
          begin

            result  := true;
            retorno := 'Usuario nao possui chave';

          end;
        end;

      end
        else
      begin
        result  := true;
        retorno := 'Usuario nao possui chave';
      end;

    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := 'Erro Interno';
    end;
  end;

end;

function TADRConnAccessDAO.PostTwoFactorChange(AfiCodigo, PerfilAcessoID: String): boolean;
const
  xSql = 'UPDATE USUARIOS SET USUARIOS.USU_TWOFACTOR_TOKEN = ''T'' WHERE USUARIOS.AFI_CODIGO = :P1 AND USUARIOS.PFA_ID = :P2 AND USUARIOS.USU_STATUS IN (''A'')';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',AfiCodigo)
                .ParamAsString('P2',PerfilAcessoID)
                .OpenDataSet;

    result := true;

  except on E: Exception do
    result := false
  end;

end;

{######## CHATS ########}

function TADRConnAccessDAO.ChatAfiliado(Documento, Afiliado: String): TJsonArray;
const
  xSql = 'SELECT * FROM STP_RETORNA_PERGUNTAS(:P1, :P2)';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',Documento)
                .ParamAsString('P2',Afiliado)
                .OpenDataSet;

    finally
      result := LDataSet.ToJSONArray();
    end;

  except on E: Exception do
    result := LDataSet.ToJSONArray();
  end;

end;



function TADRConnAccessDAO.GetStatusAberturaChat(Documento: String): TJsonArray;
const
  xSql = 'SELECT * FROM STP_STATUS_SIGNUP(:P1)';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',Documento)
                .OpenDataSet;

    finally
      result := LDataSet.ToJSONArray();
    end;

  except on E: Exception do
    result := LDataSet.ToJSONArray();
  end;

end;


function TADRConnAccessDAO.RespostaChat(PerguntaID, Documento, Afiliado, Resposta, IMEI: String; out Retorno: string): Boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_ENVIA_RESPOSTA(:P1,:P2,:P3,:P4,:P5)';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',PerguntaID)
                .ParamAsString('P2',Documento)
                .ParamAsString('P3',Afiliado)
                .ParamAsString('P4',Resposta)
                .ParamAsString('P5',IMEI)
                .OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := 'Erro Interno';
    end;
  end;

end;


function TADRConnAccessDAO.GravaChats(Ambiente, Descricao, TipoResposta,
  Obrigatorio, Placeholder, ValorPositivo, ValorNegativo, Categoria,
  PerId: string; out retorno: string): boolean;
begin

end;



function TADRConnAccessDAO.ResetTwoFactorToken(UsuID, Login, AfiCodigo: string;
  out retorno: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_RESETA_TOKEN(:P1,:P2,:P3)';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',UsuID)
                .ParamAsString('P2',Login)
                .ParamAsString('P3',AfiCodigo)
                .OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := 'Erro Interno';
    end;
  end;

end;



/////////////////// fluxo nova abertura ///////////////////////////



function TADRConnAccessDAO.RetornaDadosPessoaAbertura(PesID, Documento: string): TJSONArray;
const
  xSql = 'SELECT PES_TELEFONE PHONENUMBER, PES_CEP POSTALCODE,PES_ENDERECO ADDRESS,PES_NUMERO NUMBER,PES_COMPLEMENTO ADDRESSCOMPLEMENT, PES_BAIRRO NEIGHBORHOOD, PES_CIDADE CITY , '+'PES_UF STATE, ''0'' AS LATITUDE, ''0'' AS LONGITUDE,PES_CPF_CNPJ DOCUMENTNUMBER, PES_EMAIL EMAIL,PES_NOME_MAE MOTHERNAME, PES_NOME FULLNAME,PES_DATANASCIMENTO BIRTHDATE,PES_PEP'+' ISPOLITICALLYEXPOSEDPERSON FROM PESSOAS  WHERE PESSOAS.PES_ID = :P1 AND PES_CPF_CNPJ = :P2 AND PESSOAS.PES_STATUS = ''V''';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',PesID)
              .ParamAsString('P2',Documento)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;
end;

function TADRConnAccessDAO.RetornaDadosAberturaTipoJ(PesID: string): TJSONArray;
const
  xSql = 'SELECT                                 '+
  '        PESSOAS.PES_AFI_CODIGO,               '+
  '         PESSOAS.PES_NOME,                    '+
  '         PESSOAS.PES_RAZAO,                   '+
  '         PESSOAS.PES_ENDERECO,                '+
  '         PESSOAS.PES_NUMERO,                  '+
  '         PESSOAS.PES_COMPLEMENTO,             '+
  '         PESSOAS.PES_BAIRRO,                  '+
  '         PESSOAS.PES_CIDADE,                  '+
  '         PESSOAS.PES_CEP,                     '+
  '         PESSOAS.PES_UF,                      '+
  '         PESSOAS.PES_CPF_CNPJ,                '+
  '         PESSOAS.PES_EMAIL,                   '+
  '         PESSOAS.PES_TELEFONE,                '+
  '         PESSOAS.PES_LOGIN_CLIENTE,           '+
  '         PESSOAS.PES_ALTER_SENHAPL,           '+
  '         PESSOAS.PES_SENHA_TRANSAC,           '+
  '         PESSOAS.PES_ACESSA_SERVICO,          '+
  '         PESSOAS.PES_DATANASCIMENTO,          '+
  '         PESSOAS.PES_PROFISSAO,               '+
  '         PESSOAS.PES_NATURALIDADE,            '+
  '         PESSOAS.PES_NACIONALIDADE,           '+
  '         PESSOAS.PES_NOME_MAE,                '+
  '         PESSOAS.PES_NUMERO_RELATORIO_KYC,    '+
  '         PESSOAS.PES_STATUS_KYC,              '+
  '         PESSOAS.PES_NCONSULTA_KYC,           '+
  '         PESSOAS.PES_TELEFONE_ALTERNATIVO,    '+
  '         PESSOAS.PES_ESCOLARIDADE,            '+
  '         PESSOAS.PES_PEP,                     '+
  '         PESSOAS.PES_ORIGEM_RENDA,            '+
  '         PESSOAS.PES_ESTADO_CIVIL,            '+
  '         PESSOAS.PES_POSSUICONTACELC          '+
  '     FROM                                     '+
  '         PESSOAS                              '+
  '     WHERE                                    '+
  '         PESSOAS.PES_REFERENCIA = :P1         '+
  '     AND                                      '+
  '         PES_TIPO = ''D''                     '+
  '     AND                                      '+
  '         PES_STATUS = ''A'' ';

var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',PesID)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;

function TADRConnAccessDAO.RetornaDadosAberturaTipoAfiliado(PesID: string): TJSONArray;
const
  xSql = 'SELECT                                 '+
  '        PESSOAS.PES_AFI_CODIGO,               '+
  '         PESSOAS.PES_NOME,                    '+
  '         PESSOAS.PES_RAZAO,                   '+
  '         PESSOAS.PES_ENDERECO,                '+
  '         PESSOAS.PES_NUMERO,                  '+
  '         PESSOAS.PES_COMPLEMENTO,             '+
  '         PESSOAS.PES_BAIRRO,                  '+
  '         PESSOAS.PES_CIDADE,                  '+
  '         PESSOAS.PES_CEP,                     '+
  '         PESSOAS.PES_UF,                      '+
  '         PESSOAS.PES_CPF_CNPJ,                '+
  '         PESSOAS.PES_EMAIL,                   '+
  '         PESSOAS.PES_TELEFONE,                '+
  '         PESSOAS.PES_LOGIN_CLIENTE,           '+
  '         PESSOAS.PES_ALTER_SENHAPL,           '+
  '         PESSOAS.PES_SENHA_TRANSAC,           '+
  '         PESSOAS.PES_ACESSA_SERVICO,          '+
  '         PESSOAS.PES_DATANASCIMENTO,          '+
  '         PESSOAS.PES_PROFISSAO,               '+
  '         PESSOAS.PES_NATURALIDADE,            '+
  '         PESSOAS.PES_NACIONALIDADE,           '+
  '         PESSOAS.PES_NOME_MAE,                '+
  '         PESSOAS.PES_NUMERO_RELATORIO_KYC,    '+
  '         PESSOAS.PES_STATUS_KYC,              '+
  '         PESSOAS.PES_NCONSULTA_KYC,           '+
  '         PESSOAS.PES_TELEFONE_ALTERNATIVO,    '+
  '         PESSOAS.PES_ESCOLARIDADE,            '+
  '         PESSOAS.PES_PEP,                     '+
  '         PESSOAS.PES_ORIGEM_RENDA,            '+
  '         PESSOAS.PES_ESTADO_CIVIL,            '+
  '         PESSOAS.PES_POSSUICONTACELC          '+
  '     FROM                                     '+
  '         PESSOAS                              '+
  '     WHERE                                    '+
  '         PESSOAS.PES_ID = :P1                 '+
  '     AND                                      '+
  '         PES_TIPO = ''A''                     '+
  '     AND                                      '+
  '         PES_STATUS = ''V'' ';

var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',PesID)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;

function TADRConnAccessDAO.RetornaDadosSocioAberturaAfiliado(PesID: string): TJSONArray;
const
  xSql = 'SELECT                                       '+
  '       PESSOAS.PES_NOME,                            '+
  '       PESSOAS.PES_RAZAO,                           '+
  '       PESSOAS.PES_ENDERECO,                        '+
  '       PESSOAS.PES_NUMERO,                          '+
  '       PESSOAS.PES_COMPLEMENTO,                     '+
  '       PESSOAS.PES_BAIRRO,                          '+
  '       PESSOAS.PES_CIDADE,                          '+
  '       PESSOAS.PES_CEP,                             '+
  '       PESSOAS.PES_UF,                              '+
  '       PESSOAS.PES_CPF_CNPJ,                        '+
  '       PESSOAS.PES_EMAIL,                           '+
  '       PESSOAS.PES_TELEFONE,                        '+
  '       PESSOAS.PES_DATANASCIMENTO,                  '+
  '       PESSOAS.PES_NOME_MAE,                        '+
  '       PESSOAS.PES_NUMERO_RELATORIO_KYC,            '+
  '       PESSOAS.PES_STATUS_KYC,                      '+
  '       PESSOAS.PES_NCONSULTA_KYC,                   '+
  '       PESSOAS.PES_PEP,                             '+
  '       PESSOAS.PES_POSSUICONTACELC,                 '+
  '       PESSOAS.PES_ABERTURA_AUTO                    '+
  '   FROM                                             '+
  '       PESSOAS                                      '+
  '   WHERE                                            '+
  '       PESSOAS.PES_TIPO = ''B''                     '+
  '   AND                                              '+
  '       PESSOAS.PES_STATUS = ''N''                   '+
  '   AND                                              '+
  '       COALESCE(PESSOAS.PES_REFERENCIA,0) = :P1';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',PesID)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;

function TADRConnAccessDAO.RetornaDadosSocioAbertura(PesID: string): TJSONArray;
const
  xSql = 'SELECT                                       '+
  '       PESSOAS.PES_NOME,                            '+
  '       PESSOAS.PES_RAZAO,                           '+
  '       PESSOAS.PES_ENDERECO,                        '+
  '       PESSOAS.PES_NUMERO,                          '+
  '       PESSOAS.PES_COMPLEMENTO,                     '+
  '       PESSOAS.PES_BAIRRO,                          '+
  '       PESSOAS.PES_CIDADE,                          '+
  '       PESSOAS.PES_CEP,                             '+
  '       PESSOAS.PES_UF,                              '+
  '       PESSOAS.PES_CPF_CNPJ,                        '+
  '       PESSOAS.PES_EMAIL,                           '+
  '       PESSOAS.PES_TELEFONE,                        '+
  '       PESSOAS.PES_DATANASCIMENTO,                  '+
  '       PESSOAS.PES_NOME_MAE,                        '+
  '       PESSOAS.PES_NUMERO_RELATORIO_KYC,            '+
  '       PESSOAS.PES_STATUS_KYC,                      '+
  '       PESSOAS.PES_NCONSULTA_KYC,                   '+
  '       PESSOAS.PES_PEP,                             '+
  '       PESSOAS.PES_POSSUICONTACELC,                 '+
  '       PESSOAS.PES_ABERTURA_AUTO                    '+
  '   FROM                                             '+
  '       PESSOAS                                      '+
  '   WHERE                                            '+
  '       PES_ID = :P1                                 '+
  '   AND                                              '+
  '       PESSOAS.PES_STATUS = ''V''                   '+
  '   AND                                              '+
  '       PESSOAS.PES_POSSUICONTACELC = ''J''          '+
  '   AND                                              '+
  '       COALESCE(PESSOAS.PES_REFERENCIA,0) = 0';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',PesID)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;


function TADRConnAccessDAO.SalvaOnboardingIdPessoa(PesID, Documento, OnboardingID: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_CADCONTA_CELCOIN(:P1,:P2,:P3)';
var
  LdataSet : TDataSet;
begin
  try
    try
      LDataSet := FQuery
                .SQL(xSql)
                .ParamAsString('P1',PesID)
                .ParamAsString('P2',Documento)
                .ParamAsString('P3',OnboardingID)
                .OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
    end;

  except on E: Exception do
    begin
      result  := false;
    end;
  end;

end;


function TADRConnAccessDAO.SalvaContaCelcoin(dados: string): boolean;
const
  xSql = 'SELECT OUT_RETORNO, OUT_CODIGO_STATUS FROM STP_REGISTRA_DADOS_CECLCOIN(:P1,:P2,:P3,:P4)';
var
  LdataSet : TDataSet;
  bodyJson, Body, accountJson: TJSONObject;
  status, entity, branch, account, document, onboarding: string;
  xJsonStrBody : TStringList;
begin
  try

    bodyJson := TJsonObject.ParseJSONValue(dados) as TJsonObject;

    entity    :=  bodyJson.GetValue('entity').value;
    status    :=  bodyJson.GetValue('status').value;

    if entity = 'onboarding-create' then
    begin
      if status = 'CONFIRMED' then
      begin

        Body         := TJSONObject.ParseJSONValue(bodyJson.findvalue('body').ToString) as TJsonObject;

        accountJson  := TJSONObject.ParseJSONValue(Body.findvalue('account').ToString) as TJsonObject;

        onboarding :=  Body.GetValue('onboardingId').value;
        branch     :=  accountJson.GetValue('branch').value;
        account    :=  accountJson.GetValue('account').value;
        document   :=  accountJson.GetValue('documentNumber').value;

       LdataSet := FQuery
                    .SQL(xSql)
                    .ParamAsString('P1',onboarding)
                    .ParamAsString('P2',account)
                    .ParamAsString('P3',branch)
                    .OpenDataSet;


        if LdataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
        begin
          result := true;
        end
          else
        begin
          result := false;
        end;
      end
        else
      begin

       LdataSet := FQuery
                    .ParamAsString('P1', onboarding)
                    .ParamAsString('P4', 'C')
                    .SQL(xSql)
                    .OpenDataSet;

        if LdataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
        begin
          result := true;
        end
          else
        begin
          result := false;
        end;

      end;
    end
      else
    begin
      result := true;
    end;

    try
      xJsonStrBody := TStringList.Create;
      xJsonStrBody.Text := dados;

      xJsonStrBody.SaveToFile(ExtractFilePath(ChangeFileExt(GetModuleName(HInstance),'.exe'))+'\abertura_celcoin\onboarding'+StringReplace(onboarding,'"','',[rfReplaceAll])+'_'+FormatDateTime('ddmmyyyyhhmmdd',now)+'.txt')

    finally
      xJsonStrBody.Free;
    end;

  except on E: Exception do
    begin
      result  := false;
    end;
  end;

end;


function TADRConnAccessDAO.ValidaImeiAparelho(PesID, AfiCodigo, IMEI: string; out retorno: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_VALIDA_IMEI(:P1,:P2,:P3)';
var
  LdataSet : TDataSet;
begin
  try
    try

      FQuery
          .SQL(xSql)
          .ParamAsString('P1',PesID)
          .ParamAsString('P2',AfiCodigo)
          .ParamAsString('P3',IMEI);


      LDataSet := FQuery.OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;

    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := E.Message;
    end;
  end;

end;


function TADRConnAccessDAO.ValidaTokenPushAparelho(PesID, AfiCodigo, FCM: string; out retorno: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_VALIDA_TOKEN_PUSH(:P1,:P2,:P3)';
var
  LdataSet : TDataSet;
begin
  try
    try

      FQuery
          .SQL(xSql)
          .ParamAsString('P1',PesID)
          .ParamAsString('P2',AfiCodigo)
          .ParamAsString('P3',FCM);

      LDataSet := FQuery.OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := E.Message;
    end;
  end;

end;




function TADRConnAccessDAO.ValidaDocumentoPessoa(PesID, DocID, UsuID, Documento, Validade: string; out retorno: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_VALIDA_DOCUMENTO_PESSOA(:P1,:P2,:P3,:P4,:P5)';
var
  LdataSet : TDataSet;
begin
  try
    try

      FQuery
          .SQL(xSql)
          .ParamAsString('P1',PesID)
          .ParamAsString('P2',DocID)
          .ParamAsString('P3',UsuID)
          .ParamAsString('P4',Documento);

      if Validade <> '' then
        FQuery.ParamAsString('P5',Validade);

      LDataSet := FQuery.OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := E.Message;
    end;
  end;

end;


function TADRConnAccessDAO.ResetImeiAparelhoPessoa(PesID, AfiCodigo, UsuId: string; out retorno: string): boolean;
const
  xSQL = 'SELECT * FROM STP_RESETA_IMEI(:P1,:P2,:P3) ';
var
  LDataSet : TDataSet;
begin
  try

    LDataSet :=  FQuery
                    .SQL(xSQL)
                    .ParamAsString('P1',PesID)
                    .ParamAsString('P2',AfiCodigo)
                    .ParamAsString('P3',UsuId)
                    .OpenDataSet;

    retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    result := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';

  Except on E: Exception do
    begin
      result := false;
      Retorno := E.Message;
    end;

  end;

end;



function TADRConnAccessDAO.RetornaVersaoAmbiente(AfiCodigo, Ambiente: string): TJSONArray;
const
  xSql = 'SELECT * FROM PARAMETROS WHERE AFI_CODIGO = :P1 AND PAR_CHAVE = :P2 AND PAR_AGRUPAMENTO = ''VERSAOAPP'' ';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',AfiCodigo)
              .ParamAsString('P2',Ambiente)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;


function TADRConnAccessDAO.CriaInativaAcessoAPI(AfiCodigo, Login, Senha, APiKey, UsuID, ACP_ID, Status, Resetar: string; out retorno: string): boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO FROM STP_CRIA_ACESSO_API(:P1,:P2,:P3,:P4,:P5,:P6,:P7,:P8)';
var
  LdataSet : TDataSet;
begin
  try
    try

      FQuery
          .SQL(xSql)
          .ParamAsString('P1',AfiCodigo)
          .ParamAsString('P2',Login)
          .ParamAsString('P3',Senha)
          .ParamAsString('P4',APiKey)
          .ParamAsString('P5',UsuID);

      if ACP_ID <> '' then
        FQuery.ParamAsString('P6',ACP_ID);

      if Status <> '' then
        FQuery.ParamAsString('P7',Status);

      if Status <> '' then
        FQuery.ParamAsString('P8',Resetar);

      LDataSet := FQuery.OpenDataSet;

    finally
      result  := LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200';
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  except on E: Exception do
    begin
      result  := false;
      Retorno := E.Message;
    end;
  end;

end;

function TADRConnAccessDAO.VisualizaAcessoAPI(AfiCodigo: string): TJSONArray;
const
  xSql = 'SELECT * FROM ACESSO_API WHERE ACESSO_API.AFI_CODIGO = :P1';
var
  LdataSet : TDataSet;
begin
  try
    LDataSet := FQuery
              .SQL(xSql)
              .ParamAsString('P1',AfiCodigo)
              .OpenDataSet;

  finally
    result :=   LdataSet.ToJSONArray();
  end;

end;


end.
