unit WebHook.Controllers.Usuarios;

interface

uses
  Horse,
  Horse.Jhonson,
  System.SysUtils,
  System.JSON,
  Horse.Paginate,
  Horse.compression,
  System.StrUtils,
  RESTRequest4D,
  DateUtils,
  Dataset.Serialize,
  Data.DB,
  System.Hash,

  Horse.JWT,
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  JOSE.Types.JSON,

  Usuario.DAO,
  Seguranca.DAO.Access,

  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory;

  const
  //pRODUCAO
  xChaveMaster = '37c92a0309f99cb4a647af037e382fe064f6434dd73303c57738f9ccd455211358a94a95';
  //sANDbOX
  //xChaveMaster = 'BUILD ACCESS TOKEN SANDBOX 2023@@##';

  xChavePrintServer = 'Pingo Do Servidor de Impressao.';

  procedure RegisterUsuarios;
  procedure RegisterUsuariosAfiliados;
  procedure RegisterAlteraUsuarios;
  procedure RegisterCadastraUsuarios;
  procedure RegisterPerfilAcesso;
  procedure RegisterListaUsuarios;
  procedure RegisterValidacoes;
  procedure RegisterChats;

  //acesso usuarios tontens e desktops ... afiliados > usuarios
  procedure GetAcessoUsuarios(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAcessoUsuariosAfiliados(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure PostCadastraUsuario(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure PutAlteraUsuario(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetListaUsuarios(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAcessoPingPrintSrv(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAccess(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  //acesso cliente web e afiliado ... afiliados > pessoas - aficodigo obrigadorio
  procedure GetAcessoUsuarioWeb(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAccessTokenWebMobile (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAccessTokenWebCliente (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  //PerfisDeAcesso
  procedure PostCadastraPerfilAcesso(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure PutAlteraPerfilCadastro(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  //refresh token
  procedure RefershTokenUserSaquei(Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure GetAccessTokenWebMobileBackOffice (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetUsuariosTerminais (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure AlteraSenhaAcesso (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure CriaNovaSenhaDeAcesso (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure CriaNovaSenhaDeAcessoUsuario (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetAccessTokenMedPay (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  //nova redefinição de senha
  procedure PostRedefineSenhaPadrao(Req : THorseRequest; Res : THorseResponse; Next : TProc);

  //nova alteração de senha (possível que substitua geral)
  procedure AlteraSenhaPadrao (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure AlteraLoginCliente (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  // altera senha do backoffice
  procedure AlteraSenhaClienteBackoffice (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure ResetTwoFactorToken (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure GetValidaKeyTransacional (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure CadastraKeyTransacional (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure VisualizaKeyTransacional (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetPermissaoUsuario (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetChatAfiliado (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure GetStatusAberturaChat(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure PostRespostaChat (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure PostTwoFactorChange (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  //tokenCelCoin
  //procedure GetTokenCelCoin(Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure ListaUsuariosAfiliado (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure ValidaImeiAparelho (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure ValidaTokenPushAparelho (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure ValidaDocumentoPessoa (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure ResetImeiAparelhoPessoa (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure RetornaVersaoAmbiente (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  procedure CriaInativaAcessoAPI (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure VisualizaAcessoAPI (Req : THorseRequest; Res : THorseResponse; Next : TProc);

 type
  TMyClaims = class(TJWTClaims)
  private
    FEmail: String;
    FTelefone: string;
    FConta: string;
    FAgencia: string;
    FDocumentoContaBtg: string;
    FChavePixBtg: string;
    FNumerobtg: string;
    FComplementobtg: string;
    FCidadebtg: string;
    FEstadobtg: string;
    FRuabtg: string;
    FBairrobtg: string;
    FCepbtg: string;
    function GetuserId: string;
    function GetNomeUser: string;
    function GetCodigoAfiliado: string;
    function GetTerminal: string;
    procedure SetuserId(const Value: string);
    procedure SetNomeUser(const Value: string);
    procedure SetCodigoAfiliado(const Value: string);
    procedure SetTerminal(const Value: string);
    procedure SetEmail(const Value: String);
    procedure SetTelefone(const Value: string);
    procedure SetAgencia(const Value: string);
    procedure SetConta(const Value: string);
    procedure SetDocumentoContaBtg(const Value: string);
    procedure SetChavePixBtg(const Value: string);
    procedure SetBairrobtg(const Value: string);
    procedure SetCepbtg(const Value: string);
    procedure SetCidadebtg(const Value: string);
    procedure SetComplementobtg(const Value: string);
    procedure SetEstadobtg(const Value: string);
    procedure SetNumerobtg(const Value: string);
    procedure SetRuabtg(const Value: string);
  public
    property userId: string read GetuserId write SetuserId;
    property NomeUser: string read GetNomeUser write SetNomeUser;
    property CodigoAfiliado: string read GetCodigoAfiliado write SetCodigoAfiliado;
    property Terminal: string read GetTerminal write SetTerminal;
    property Email : String read FEmail write SetEmail;
    property Telefone : string read FTelefone write SetTelefone;
    property Conta : string read FConta write SetConta;
    property Agencia : string read FAgencia write SetAgencia;
    property DocumentoContaBtg : string read FDocumentoContaBtg write SetDocumentoContaBtg;
    property ChavePixBtg : string read FChavePixBtg write SetChavePixBtg;
    property Ruabtg : string read FRuabtg write SetRuabtg;
    property Numerobtg : string read FNumerobtg write SetNumerobtg;
    property Complementobtg : string read FComplementobtg write SetComplementobtg;
    property Bairrobtg : string read FBairrobtg write SetBairrobtg;
    property Cidadebtg : string read FCidadebtg write SetCidadebtg;
    property Estadobtg : string read FEstadobtg write SetEstadobtg;
    property Cepbtg : string read FCepbtg write SetCepbtg;
  end;

implementation

procedure RegisterUsuarios;
begin
  THorse
    .Get('AcessoUsuario',GetAcessoUsuarios)
    .Get('AcessoUsuarioWeb',GetAcessoUsuarioWeb)
    .Get('GetAccessTokenWebMobile',GetAccessTokenWebMobile)
    .Get('GetAccessTokenMedPay',GetAccessTokenMedPay)
    .Get('GetAccessTokenWebCliente',GetAccessTokenWebCliente)
    .Get('GetAccessBackOffice',GetAccessTokenWebMobileBackOffice)
    .Get('GetAccess',GetAccess)    //Novo padrão de login backoffice em teste


end;

procedure RegisterChats;
begin
  THorse
    .Get('GetChatAfiliado',GetChatAfiliado)
    .Post('PostRespostaChat',PostRespostaChat)
    .Get('GetStatusAberturaChat',GetStatusAberturaChat)
end;

procedure RegisterUsuariosAfiliados;
begin
  THorse
    //.AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('AcessoUsuarioAfiliados',GetAcessoUsuariosAfiliados);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetUsuariosTerminais',GetUsuariosTerminais);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetListaUsuariosAfiliado',ListaUsuariosAfiliado);
end;

procedure RegisterPerfilAcesso;
begin
 THorse
  .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('GravaPerfilAcesso',PostCadastraPerfilAcesso);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Put('AlteraPerfilAcesso',PutAlteraPerfilCadastro);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Put('PutCriaNovaSenhaDeAcesso',CriaNovaSenhaDeAcesso);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Put('PutCriaNovaSenhaDeAcessoUsuario',CriaNovaSenhaDeAcessoUsuario);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('RedefinirSenhaDeAcesso',AlteraSenhaAcesso);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostAlteraSenhaPadrao',AlteraSenhaPadrao);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostAlteraSenhaClienteBack',AlteraSenhaClienteBackoffice);

  THorse
    //.AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostRedefineSenhaPadrao',PostRedefineSenhaPadrao);

  THorse
    //.AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetRetornaVersaoAmbiente',RetornaVersaoAmbiente);
end;

procedure RegisterAlteraUsuarios;
begin
//  THorse
//  .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
//  .Put('AlteraDadosUsuario',PutAlteraUsuario);

  THorse
  .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Put('AlteraLoginCliente',AlteraLoginCliente);
end;

procedure RegisterCadastraUsuarios;
begin
  THorse
  .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Post('CadastraNovoUsuario',PostCadastraUsuario);
end;

procedure RegisterListaUsuarios;
begin
  THorse
  .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
  .Get('ListaUsuarios',GetListaUsuarios);
end;

procedure RegisterValidacoes;
begin
  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetConfereKeyTransa',GetValidaKeyTransacional);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetPermissaoUsuario',GetPermissaoUsuario);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostTwoFactorChange',PostTwoFactorChange);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostCadastraKeyTransacional',CadastraKeyTransacional);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetVisualizaKeyTransacional',VisualizaKeyTransacional);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostResetTwoFactorToken',ResetTwoFactorToken);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostValidaImeiAparelho',ValidaImeiAparelho);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostResetImeiAparelhoPessoa',ResetImeiAparelhoPessoa);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostValidaTokenPushAparelho',ValidaTokenPushAparelho);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostValidaDocumentoPessoa',ValidaDocumentoPessoa);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('PostCriaInativaAcessoAPI',CriaInativaAcessoAPI);

   THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('GetVisualizaAcessoAPI',VisualizaAcessoAPI);

end;


function GuidCreate: string;
var
  ID: TGUID;
begin
  Result := '';
  if CreateGuid(ID) = S_OK then
    Result := GUIDToString(ID);
end;

function GenerateHash(dados: string): string;
var
  Hash: string;
begin
  Hash := THashSHA2.GetHashString(Dados);
  result := hash;
end;

procedure CriaNovaSenhaDeAcesso (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if LDAO.AlteraSenhaDeAcesso(req.Headers.Items['x-AfiCodigo'],req.Headers.Items['x-Login'],req.Headers.Items['x-SenhaAntiga'],req.Headers.Items['x-NovaSenha1'],req.Headers.Items['x-NovaSenha2'], req.Headers.Items['x-Interno']) then
        Res.Send('{"erros":false}').status(THTTPStatus.OK)
      else
        Res.Send('{"erros":true}');
    finally
      LDAO.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.OK);
  end;
end;


procedure CriaNovaSenhaDeAcessoUsuario (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if LDAO.AlteraSenhaDeAcessoUsuario(req.Headers.Items['x-AfiCodigo'],req.Headers.Items['x-Login'],req.Headers.Items['x-SenhaAntiga'],req.Headers.Items['x-NovaSenha1'],req.Headers.Items['x-NovaSenha2'], req.Headers.Items['x-UserID']) then
        Res.Send('{"erros":false}').status(THTTPStatus.OK)
      else
        Res.Send('{"erros":true}');
    finally
      LDAO.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.OK);
  end;
end;



procedure RefershTokenUserSaquei(Req : THorseRequest; Res : THorseResponse; Next : TProc);
begin
  // Unpack and verify the token
end;

procedure GetUsuariosTerminais (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      Res.Send<TJsonArray>(ldao.GetUsuariosAfiliadoTerminais(req.Headers.Items['x-AfiCodigo'], req.Headers.Items['x-Operador'])).status(THTTPStatus.OK);
    finally
      Ldao.Free;
    end;
  except
    Res.Send('"erros":true').Status(THTTPStatus.OK);
  end;
end;

procedure PostRedefineSenhaPadrao(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-Login'] <> '' then
      begin
        if Req.Headers.Items['x-Tipo'] <> '' then
        begin
          if Req.Headers.Items['x-Documento'] <> '' then
          begin
            if Req.Headers.Items['x-Telefone'] <> '' then
            begin
              if Req.Headers.Items['x-AfiCodigo'] <> '' then
              begin

                //Login, Tipo, Documento, Telefone, AfiCodigo
                if LDAO.RedefineSenhaPadrao(Req.Headers.Items['x-Login'],
                                            Req.Headers.Items['x-Tipo'],
                                            Req.Headers.Items['x-Documento'],
                                            Req.Headers.Items['x-Telefone'],
                                            Req.Headers.Items['x-AfiCodigo'],
                                            retorno) then
                begin
                  Res.Send('{"erros":false, "retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
                end
                  else
                begin

                  if Req.Headers.Items['x-AfiCodigo'] = 'MEDPY001' then
                  begin

                    if LDAO.RedefineSenhaPadrao(Req.Headers.Items['x-Login'],
                                                Req.Headers.Items['x-Tipo'],
                                                Req.Headers.Items['x-Documento'],
                                                Req.Headers.Items['x-Telefone'],
                                                'NVDGS001',
                                                retorno) then

                    begin
                      Res.Send('{"erros":false, "retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
                    end
                      else
                    begin

                      if LDAO.RedefineSenhaPadrao(Req.Headers.Items['x-Login'],
                                                  Req.Headers.Items['x-Tipo'],
                                                  Req.Headers.Items['x-Documento'],
                                                  Req.Headers.Items['x-Telefone'],
                                                  'MDCSM001',
                                                  retorno) then

                      begin
                        Res.Send('{"erros":false, "retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
                      end
                        else
                      begin
                        Res.Send('{"erros":true, "retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
                      end;

                    end;

                  end
                    else
                  begin
                    Res.Send('{"erros":true, "retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
                  end;

                end;

              end
                else
              begin
                Res.Send('{"erros":true,"message":"AfiCodigo Vazio"}').Status(THTTPStatus.Unauthorized);
              end;
            end
              else
            begin
              Res.Send('{"erros":true,"message":"Telefone Vazio"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true,"message":"Documento Vazio"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true,"message":"Tipo Vazio"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"message":"Login Vazio"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDao.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.Unauthorized);
  end;
end;

procedure AlteraSenhaAcesso (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
        if Req.Headers.Items['x-Login'] <> '' then
        begin
          if Req.Headers.Items['x-Usuario'] <> '' then
          begin
            if LDAO.RedefinirSenha(Req.Headers.Items['x-AfiCodigo'],Req.Headers.Items['x-Login'],Req.Headers.Items['x-Usuario']) then
              Res.Send('{"erros":false}').Status(THTTPStatus.OK)
            else
              Res.Send('{"erros":true}').Status(THTTPStatus.OK);


          end
            else
          begin
            Res.Send('{"erros":true,"message":"Usuario Vazio"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true,"message":"Login Vazio"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"message":"AfiCodigo Vazio"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDao.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.Unauthorized);
  end;
end;

procedure AlteraLoginCliente (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  Retorno: string;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-PesId'] <> '' then
    begin
      if Req.Headers.Items['x-LoginAntigo'] <> '' then
      begin
        if Req.Headers.Items['x-NovoLogin'] <> '' then
        begin

          //PesId, LoginAntigo, NovoLogin
          if LDAO.RedefineLoginAcesso(Req.Headers.Items['x-PesId'],
                                      Req.Headers.Items['x-LoginAntigo'],
                                      Req.Headers.Items['x-NovoLogin']) then

          begin
            Res.Send('{"erros":false,"retorno":"Alteracao executada."}').Status(THTTPStatus.ok);
          end
            else
          begin
           Res.Send('{"erros":true,"retorno":"Alteracao nao executada."}').Status(THTTPStatus.Unauthorized);
          end;

        end
          else
        begin
          Res.Send('{"erros":true,"message":"NovoLogin Vazio"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"message":"LoginAntigo Vazio"}').Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send('{"erros":true,"message":"PesId Vazio"}').Status(THTTPStatus.Unauthorized);
    end;

  finally
    LDAO.Free;
  end;

end;

procedure AlteraSenhaPadrao (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  Retorno: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-Login'] <> '' then
      begin
        if Req.Headers.Items['x-NovaSenha'] <> '' then
        begin
          if Req.Headers.Items['x-TipoAcesso'] <> '' then
          begin
            if Req.Headers.Items['x-PesID'] <> '' then
            begin
              if Req.Headers.Items['x-AfiCodigo'] <> '' then
              begin
                  if Req.Headers.Items['x-SenhaAntiga'] <> '' then
                  begin

                    //Login, SenhaNova, TipoAcesso, PesID, AfiCodigo, UsuID, SenhaAntiga
                    if LDAO.AlteraSenhaPadrao(Req.Headers.Items['x-Login'],
                                            Req.Headers.Items['x-NovaSenha'],
                                            Req.Headers.Items['x-TipoAcesso'],
                                            Req.Headers.Items['x-PesID'],
                                            Req.Headers.Items['x-AfiCodigo'],
                                            Req.Headers.Items['x-UsuID'],
                                            Req.Headers.Items['x-SenhaAntiga'],
                                            Retorno) then

                    begin
                      Res.Send('{"erros":false,"retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
                    end
                      else
                    begin
                     Res.Send('{"erros":true,"retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
                    end;

                  end
                    else
                  begin
                    Res.Send('{"erros":true,"message":"SenhaAntiga Vazio"}').Status(THTTPStatus.Unauthorized);
                  end;

              end
                else
              begin
                Res.Send('{"erros":true,"message":"AfiCodigo Vazio"}').Status(THTTPStatus.Unauthorized);
              end;
            end
              else
            begin
              Res.Send('{"erros":true,"message":"PesID Vazio"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true,"message":"TipoAcesso Vazio"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true,"message":"NovaSenha Vazio"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"message":"Login Vazio"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDao.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure AlteraSenhaClienteBackoffice (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  Retorno, senha: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-Login'] <> '' then
      begin
        if Req.Headers.Items['x-TipoAcesso'] <> '' then
        begin
          if Req.Headers.Items['x-PesID'] <> '' then
          begin
            if Req.Headers.Items['x-AfiCodigo'] <> '' then
            begin

              //Login, TipoAcesso, PesID, AfiCodigo, UsuID
              if LDAO.AlteraSenhaClienteBackoffice(Req.Headers.Items['x-Login'],
                                      Req.Headers.Items['x-TipoAcesso'],
                                      Req.Headers.Items['x-PesID'],
                                      Req.Headers.Items['x-AfiCodigo'],
                                      Req.Headers.Items['x-UsuID'],
                                      Retorno,
                                      Senha) then

              begin
                Res.Send('{"erros":false, "retorno":"'+retorno+'", "senha":"'+Senha+'"}').Status(THTTPStatus.ok);
              end
                else
              begin
               Res.Send('{"erros":true,"retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
              end;


            end
              else
            begin
              Res.Send('{"erros":true,"message":"AfiCodigo Vazio"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true,"message":"PesID Vazio"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true,"message":"TipoAcesso Vazio"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"message":"Login Vazio"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDao.Free;
    end;
  except
    Res.Send('{"erros":true}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure GetAcessoPingPrintSrv(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LToken  : String;
  LJWT    : TJWT;
  LClaims : TMyClaims;
begin
  if Req.Headers.Items['x-User'] = 'PingSrv' then
  begin
    if Req.Headers.Items['x-Password'] = '#ArrotoDeSapo' then
    begin
      LJWT    := TJWT.Create(TMyClaims);
      LClaims := TMyClaims(LJWT.Claims);

      LClaims.Issuer     := 'SAQUEI';
      LClaims.Subject    := 'Print Server';
      LClaims.Expiration := IncMinute(Now,480); //8horas de token.

      LClaims.Terminal   := 'PrintServer';


      LToken := TJOSE.SHA512CompactToken(xChavePrintServer, LJWT);
      Res.Send(LToken).Status(THTTPStatus.OK);
    end;
  end;
end;

procedure GetAcessoUsuariosAfiliados(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xAcess      : String;
  LToken      : String;
  xResult     : TStringArray;
  LResponse   : IResponse;
begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  LConnection := TADRConnModelFactory.GetConnectionIniFile();
  LConnection.Connect;

  LDAO := TADRConnAccessDAO.create(LConnection);
  Try
      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
        if Req.Headers.Items['x-Terminal'] <> '' then
        begin
          if Req.Headers.Items['x-User'] <> '' then
          begin
            if Req.Headers.Items['x-Password'] <> '' then
            begin
              xResult :=  LDAO.ValidaAcessoUsuario(
                          Req.Headers.Items['x-AfiCodigo'],
                          Req.Headers.Items['x-Terminal'],
                          Req.Headers.Items['x-User'],
                          Req.Headers.Items['x-Password'],
                          Req.Headers.Items['x-Dispositivo'],
                          Req.Headers.Items['x-Versao']);

              {

              out_user_nome_exibicao,
              out_user_nome,
              out_afiliadocodigo,
              out_terminal;

              }



              if xResult[0] = '200 - Acesso Liberado.' then
              begin
                LJWT    := TJWT.Create(TMyClaims);
                LClaims := TMyClaims(LJWT.Claims);

                LClaims.Issuer     := 'SAQUEI';
                LClaims.Subject    := 'Bank as Service';
                LClaims.Expiration := IncMinute(Now,480); //8horas de token.

                LClaims.userId         := xResult[2];
                LClaims.NomeUser       := xResult[3];
                LClaims.CodigoAfiliado := xResult[1];
                LClaims.Terminal       := xResult[5];
                LClaims.Email          := xResult[6];
                LClaims.Telefone       := xResult[8];

                LClaims.Conta          := xResult[11];
                LClaims.Agencia        := xResult[12];
                LClaims.DocumentoContaBtg := xResult[13];
                LClaims.ChavePixBtg    := xResult[14];

                LClaims.Ruabtg          := xResult[15];
                LClaims.Numerobtg       := xResult[16];
                LClaims.Complementobtg  := xResult[17];
                LClaims.Bairrobtg       := xResult[18];
                LClaims.Cidadebtg       := xResult[19];
                LClaims.Estadobtg       := xResult[20];
                LClaims.Cepbtg          := xResult[21];

                LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                .AddPair('usuario',LClaims.NomeUser)
                                .AddPair('terminal',LClaims.Terminal)
                                .AddPair('email',LClaims.Email)
                                .AddPair('afiliado',LClaims.CodigoAfiliado)
                                .AddPair('CpfCnpj',xResult[7])
                                .AddPair('Telefone',xResult[8])
                                .AddPair('logo',xResult[9])
                                .AddPair('Conta',LClaims.userId)
                                .AddPair('CodTerminalTefSitef',xResult[10])
                                .AddPair('ContaBtg',xResult[11])
                                .AddPair('AgenciaBtg',xResult[12])
                                .AddPair('DocumentoContaBtg',xResult[13])
                                .AddPair('ChavePixBtg',xResult[14])
                                .AddPair('Ruabtg',xResult[15])
                                .AddPair('Numerobtg',xResult[16])
                                .AddPair('Complementobtg',xResult[17])
                                .AddPair('Bairrobtg',xResult[18])
                                .AddPair('Cidadebtg',xResult[19])
                                .AddPair('Estadobtg',xResult[20])
                                .AddPair('Cepbtg',xResult[21])
                                .AddPair('Nomecontabtg',xResult[22])
                                .AddPair('TipoAcesso',xResult[23])
                                .AddPair('TokenSitef',xResult[24])
                                ).Status(THTTPStatus.OK);

                
              end
                else
              begin
                Res.Send('{"erros":true,"mensagem":"Acesso Negado 00", "retorno":"'+xResult[0]+'"}').Status(THTTPStatus.OK);
              end;
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"Acesso Negado. 01", "retorno":"'+xResult[0]+'"}').Status(THTTPStatus.OK);
            end;
          end
            else
          begin
            Res.Send('{"erros":true,"mensagem":"Acesso Negado. 02", "retorno":"'+xResult[0]+'"}').Status(THTTPStatus.OK);
          end;
        end
          else
        begin
          Res.Send('{"erros":true,"mensagem":"Acesso Negado. 03", "retorno":"'+xResult[0]+'"}').Status(THTTPStatus.OK);
        end;
      end
        else
      begin
        Res.Send('{"erros":true,"mensagem":"Acesso Negado. 04", "retorno":"'+xResult[0]+'"}').Status(THTTPStatus.OK);
      end;
  finally
    LDataSet.Free;
    LDAO.Free;
  end;
end;

procedure GetAccessTokenWebMobile (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  //xAcess    : String;
  LToken      : String;
  LResponse   : IResponse;
  xAfiCodigo  : string;
  //xResult   : TStringArray;
begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin

        if Req.Headers.Items['x-AfiCodigo'] <> ''  then
          xAfiCodigo := Req.Headers.Items['x-AfiCodigo']
        else
          xAfiCodigo := 'SOCZA001';

        LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                 Req.Headers.Items['x-password'],
                                 xAfiCodigo);

        if not LDataSet.IsEmpty then
        begin
          if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
          begin

            LJWT    := TJWT.Create(TMyClaims);
            LClaims := TMyClaims(LJWT.Claims);

            LClaims.Issuer     := 'SAQUEI';
            LClaims.Subject    := 'Bank as Service';
            LClaims.Expiration := IncMinute(Now,120);

            LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
            LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
            LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
            LClaims.Terminal       := '';
            LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
            LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

            LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
            Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                .AddPair('AlterSenha',LDataSet.FieldByName('OUT_ALTER_SENHA').AsString)
                                .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                .AddPair('TipoContaAcesso',LDataSet.FieldByName('OUT_TIPO_CONTA').AsString)
                                .AddPair('imei',LDataSet.FieldByName('OUT_IMEI').AsString)
                                .AddPair('Fcm_Token',LDataSet.FieldByName('OUT_FCM_TOKEN').AsString)
                                .AddPair('ListaAfiliados',LDataSet.FieldByName('OUT_AFILIADOS').AsString)
                                .AddPair('ListaPesIds',LDataSet.FieldByName('OUT_PES_IDS').AsString)
                                ).Status(THTTPStatus.OK);

          end
            else
          begin
            if xAfiCodigo = 'MEDPY001' then
            begin


              LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                   Req.Headers.Items['x-password'],
                                   'NVDGS001');

              if not LDataSet.IsEmpty then
              begin

                if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                begin

                  LJWT    := TJWT.Create(TMyClaims);
                  LClaims := TMyClaims(LJWT.Claims);

                  LClaims.Issuer     := 'SAQUEI';
                  LClaims.Subject    := 'Bank as Service';
                  LClaims.Expiration := IncMinute(Now,120);

                  LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
                  LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                  LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
                  LClaims.Terminal       := '';
                  LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
                  LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

                  LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                  Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                      .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                      .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                      .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                      .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                      .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                      .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                      .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                      .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                      .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                      .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                      .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                      .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                      .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                      .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                      .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                      .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                      .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                      .AddPair('AlterSenha',LDataSet.FieldByName('OUT_ALTER_SENHA').AsString)
                                      .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                      .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                      .AddPair('TipoContaAcesso',LDataSet.FieldByName('OUT_TIPO_CONTA').AsString)
                                      .AddPair('imei',LDataSet.FieldByName('OUT_IMEI').AsString)
                                      .AddPair('Fcm_Token',LDataSet.FieldByName('OUT_FCM_TOKEN').AsString)
                                      .AddPair('ListaAfiliados',LDataSet.FieldByName('OUT_AFILIADOS').AsString)
                                      .AddPair('ListaPesIds',LDataSet.FieldByName('OUT_PES_IDS').AsString)
                                      ).Status(THTTPStatus.OK);


                end
                  else
                begin
                  LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                     Req.Headers.Items['x-password'],
                                     'MDCSM001');

                  if not LDataSet.IsEmpty then
                  begin

                    if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                    begin

                      LJWT    := TJWT.Create(TMyClaims);
                      LClaims := TMyClaims(LJWT.Claims);

                      LClaims.Issuer     := 'SAQUEI';
                      LClaims.Subject    := 'Bank as Service';
                      LClaims.Expiration := IncMinute(Now,120);

                      LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
                      LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                      LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
                      LClaims.Terminal       := '';
                      LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
                      LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

                      LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                      Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                          .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                          .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                          .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                          .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                          .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                          .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                          .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                          .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                          .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                          .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                          .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                          .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                          .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                          .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                          .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                          .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                          .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                          .AddPair('AlterSenha',LDataSet.FieldByName('OUT_ALTER_SENHA').AsString)
                                          .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                          .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                          .AddPair('TipoContaAcesso',LDataSet.FieldByName('OUT_TIPO_CONTA').AsString)
                                          .AddPair('imei',LDataSet.FieldByName('OUT_IMEI').AsString)
                                          .AddPair('Fcm_Token',LDataSet.FieldByName('OUT_FCM_TOKEN').AsString)
                                          .AddPair('ListaAfiliados',LDataSet.FieldByName('OUT_AFILIADOS').AsString)
                                          .AddPair('ListaPesIds',LDataSet.FieldByName('OUT_PES_IDS').AsString)
                                          ).Status(THTTPStatus.OK);


                    end
                      else
                    begin

                      LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                     Req.Headers.Items['x-password'],
                                     'SOCZAAPR');

                      if not LDataSet.IsEmpty then
                      begin

                        if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                        begin

                          LJWT    := TJWT.Create(TMyClaims);
                          LClaims := TMyClaims(LJWT.Claims);

                          LClaims.Issuer     := 'SAQUEI';
                          LClaims.Subject    := 'Bank as Service';
                          LClaims.Expiration := IncMinute(Now,120);

                          LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
                          LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                          LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
                          LClaims.Terminal       := '';
                          LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
                          LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

                          LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                          Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                              .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                              .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                              .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                              .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                              .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                              .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                              .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                              .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                              .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                              .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                              .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                              .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                              .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                              .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                              .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                              .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                              .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                              .AddPair('AlterSenha',LDataSet.FieldByName('OUT_ALTER_SENHA').AsString)
                                              .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                              .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                              .AddPair('TipoContaAcesso',LDataSet.FieldByName('OUT_TIPO_CONTA').AsString)
                                              .AddPair('imei',LDataSet.FieldByName('OUT_IMEI').AsString)
                                              .AddPair('Fcm_Token',LDataSet.FieldByName('OUT_FCM_TOKEN').AsString)
                                              .AddPair('ListaAfiliados',LDataSet.FieldByName('OUT_AFILIADOS').AsString)
                                              .AddPair('ListaPesIds',LDataSet.FieldByName('OUT_PES_IDS').AsString)
                                              ).Status(THTTPStatus.OK);
                        end
                          else
                        begin

                          LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                     Req.Headers.Items['x-password'],
                                     'DINAM001');

                          if not LDataSet.IsEmpty then
                          begin

                            if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                            begin

                              LJWT    := TJWT.Create(TMyClaims);
                              LClaims := TMyClaims(LJWT.Claims);

                              LClaims.Issuer     := 'SAQUEI';
                              LClaims.Subject    := 'Bank as Service';
                              LClaims.Expiration := IncMinute(Now,120);

                              LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
                              LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                              LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
                              LClaims.Terminal       := '';
                              LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
                              LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

                              LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                              Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                                  .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                                  .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                                  .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                                  .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                                  .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                                  .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                                  .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                                  .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                                  .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                                  .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                                  .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                                  .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                                  .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                                  .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                                  .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                                  .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                                  .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                                  .AddPair('AlterSenha',LDataSet.FieldByName('OUT_ALTER_SENHA').AsString)
                                                  .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                                  .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                                  .AddPair('TipoContaAcesso',LDataSet.FieldByName('OUT_TIPO_CONTA').AsString)
                                                  .AddPair('imei',LDataSet.FieldByName('OUT_IMEI').AsString)
                                                  .AddPair('Fcm_Token',LDataSet.FieldByName('OUT_FCM_TOKEN').AsString)
                                                  .AddPair('ListaAfiliados',LDataSet.FieldByName('OUT_AFILIADOS').AsString)
                                                  .AddPair('ListaPesIds',LDataSet.FieldByName('OUT_PES_IDS').AsString)
                                                  ).Status(THTTPStatus.OK);
                            end
                              else
                            begin

                              Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                            end;

                          end
                            else
                          begin
                            Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                          end;

                        end;

                      end
                        else
                      begin
                        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                      end;

                    end;

                  end
                    else
                  begin
                    Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                  end;
                end;

              end
                else
              begin

                Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);

              end;

            end
              else
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
            end;

          end;
        end
          else
        begin
          Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;


procedure GetAccessTokenMedPay(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  //xAcess    : String;
  LToken      : String;
  LResponse   : IResponse;
  xAfiCodigo  : string;
  //xResult   : TStringArray;
begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin

        if Req.Headers.Items['x-AfiCodigo'] <> ''  then
          xAfiCodigo := Req.Headers.Items['x-AfiCodigo']
        else
          xAfiCodigo := 'SOCZA001';

        LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                 Req.Headers.Items['x-password'],
                                 xAfiCodigo);

        if not LDataSet.IsEmpty then
        begin
          if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
          begin

            LJWT    := TJWT.Create(TMyClaims);
            LClaims := TMyClaims(LJWT.Claims);

            LClaims.Issuer     := 'SAQUEI';
            LClaims.Subject    := 'Bank as Service';
            LClaims.Expiration := IncMinute(Now,120);

            LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
            LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
            LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
            LClaims.Terminal       := '';
            LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
            LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

            LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
            Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                .addPair('Afiliado',LDataSet.FieldByName('out_aficodigo').AsString)
                                .AddPair('ContaBtg',LDataSet.FieldByName('OUT_CONTABTG').AsString)
                                .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AGENCIA').AsString)
                                .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_DOCBTG').AsString)
                                .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_CHAVEBTG').AsString)
                                .AddPair('Ruabtg',LDataSet.FieldByName('OUT_RUABTG').AsString)
                                .AddPair('Numerobtg',LDataSet.FieldByName('OUT_NUMEROBTG').AsString)
                                .AddPair('Complementobtg',LDataSet.FieldByName('OUT_COMPLEMENTOBTG').AsString)
                                .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_BAIRROBTG').AsString)
                                .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_CIDADEBTG').AsString)
                                .AddPair('Estadobtg',LDataSet.FieldByName('OUT_ESTADOBTG').AsString)
                                .AddPair('Cepbtg',LDataSet.FieldByName('OUT_CEPBTG').AsString)
                                .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_NOMEBTG').AsString)
                                .AddPair('TipoContaSaquei',LDataSet.FieldByName('OUT_TIPO_PESSOA').AsString)
                                .AddPair('TipoAcesso',LDataSet.FieldByName('OUT_ACESSO_SERVICO').AsString)
                                ).Status(THTTPStatus.OK);

          end
            else
          begin
            Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;

procedure GetAccessTokenWebCliente (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  //xAcess    : String;
  LToken      : String;
  LResponse   : IResponse;

begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-Login'] <> '' then
    begin
      if Req.Headers.Items['x-Password'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> ''  then
        begin
          if Req.Headers.Items['x-Versao'] <> ''  then
          begin
            if Req.Headers.Items['x-Dispositivo'] <> ''  then
            begin

                LDataSet := LDAO.AcessoUsuarioWebCliente(Req.Headers.Items['x-AfiCodigo'],
                                                         Req.Headers.Items['x-login'],
                                                         Req.Headers.Items['x-password'],
                                                         Req.Headers.Items['x-Versao'],
                                                         Req.Headers.Items['x-Dispositivo']);

              if not LDataSet.IsEmpty then
              begin
                if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                begin

                  LJWT    := TJWT.Create(TMyClaims);
                  LClaims := TMyClaims(LJWT.Claims);

                  LClaims.Issuer     := 'SAQUEI';
                  LClaims.Subject    := 'Bank as Service';
                  LClaims.Expiration := IncMinute(Now,120);

                  LClaims.userId         := LDataSet.FieldByName('OUT_CLI_PES_ID').AsString;
                  LClaims.NomeUser       := LDataSet.FieldByName('OUT_CLI_NOME').AsString;
                  LClaims.CodigoAfiliado := LDataSet.FieldByName('OUT_DOCUMENTO').AsString;
                  LClaims.Terminal       := '';
                  LClaims.Email          := LDataSet.FieldByName('OUT_CLI_EMAIL').AsString;
                  LClaims.Telefone       := LDataSet.FieldByName('OUT_TELEFONE').AsString;

                  LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                  Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                .AddPair('Nome',LDataSet.FieldByName('OUT_CLI_NOME').AsString)
                                .AddPair('Documento',LDataSet.FieldByName('OUT_DOCUMENTO').AsString)
                                .AddPair('Email',LDataSet.FieldByName('OUT_CLI_EMAIL').AsString)
                                .AddPair('Telefone',LDataSet.FieldByName('OUT_TELEFONE').AsString)
                                .AddPair('Conta',LDataSet.FieldByName('OUT_CLI_PES_ID').AsString)
                                .addPair('Afiliado',LDataSet.FieldByName('OUT_CLI_AFI_CODIGO').AsString)
                                .AddPair('Razao',LDataSet.FieldByName('OUT_CLI_RAZAO').AsString)
                                .AddPair('Endereco',LDataSet.FieldByName('OUT_CLI_ENDERECO').AsString)
                                .AddPair('Bairro',LDataSet.FieldByName('OUT_CLI_BAIRRO').AsString)
                                .AddPair('Cidade',LDataSet.FieldByName('OUT_CLI_CIDADE').AsString)
                                .AddPair('Cep',LDataSet.FieldByName('OUT_CLI_CEP').AsString)
                                .AddPair('Uf',LDataSet.FieldByName('OUT_CLI_UF').AsString)
                                .AddPair('Numero',LDataSet.FieldByName('OUT_CLI_NUMERO').AsString)
                                .AddPair('Complemento',LDataSet.FieldByName('OUT_CLI_COMPLEMENTO').AsString)
                                .AddPair('ContaBtg',LDataSet.FieldByName('OUT_AFI_CONTA').AsString)
                                .AddPair('AgenciaBtg',LDataSet.FieldByName('OUT_AFI_AGENCIA').AsString)
                                .AddPair('DocumentoContaBtg',LDataSet.FieldByName('OUT_AFI_DOCUMENTO').AsString)
                                .AddPair('ChavePixBtg',LDataSet.FieldByName('OUT_AFI_CHAVE_PIX').AsString)
                                .AddPair('Ruabtg',LDataSet.FieldByName('OUT_AFI_RUABTG').AsString)
                                .AddPair('Numerobtg',LDataSet.FieldByName('OUT_AFI_NUMEROBTG').AsString)
                                .AddPair('Complementobtg',LDataSet.FieldByName('OUT_AFI_COMPLEMENTOBTG').AsString)
                                .AddPair('Bairrobtg',LDataSet.FieldByName('OUT_AFI_BAIRROBTG').AsString)
                                .AddPair('Cidadebtg',LDataSet.FieldByName('OUT_AFI_CIDADEBTG').AsString)
                                .AddPair('Estadobtg',LDataSet.FieldByName('OUT_AFI_ESTADOBTG').AsString)
                                .AddPair('Cepbtg',LDataSet.FieldByName('OUT_AFI_CEPBTG').AsString)
                                .AddPair('Nomecontabtg',LDataSet.FieldByName('OUT_AFI_NOMECONTABTG').AsString)
                                .AddPair('Numerooab',LDataSet.FieldByName('OUT_CLI_OAB').AsString)
                                ).Status(THTTPStatus.OK);
                 
                end
                  else
                begin
                  Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                end;
              end
                else
                Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
            end
              else
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;

procedure GetAccessTokenWebMobileBackOffice (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  //xAcess      : String;
  LToken      : String;
  LResponse: IResponse;
  //xResult     : TStringArray;
begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> '' then
        begin
          LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                   Req.Headers.Items['x-password'],
                                   Req.Headers.Items['x-AfiCodigo']);

          if not LDataSet.IsEmpty then
          begin
            if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
            begin

              LJWT    := TJWT.Create(TMyClaims);
              LClaims := TMyClaims(LJWT.Claims);

              LClaims.Issuer     := 'SAQUEI';
              LClaims.Subject    := 'Bank as Service';
              LClaims.Expiration := IncMinute(Now,120);

              LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
              LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
              LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
              LClaims.Terminal       := '';
              LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
              LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

              LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
              Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))
                                  .AddPair('usuario',LDataSet.FieldByName('out_nome').AsString)
                                  .AddPair('cpfcnpj',LDataSet.FieldByName('out_Cpfcnpj').AsString)
                                  .AddPair('email',LDataSet.FieldByName('out_email').AsString)
                                  .AddPair('telefone',LDataSet.FieldByName('out_telefone').AsString)
                                  .AddPair('nomebtg',LDataSet.FieldByName('out_nomebtg').AsString)
                                  .AddPair('docbtg',LDataSet.FieldByName('out_docbtg').AsString)
                                  .AddPair('contabtg',LDataSet.FieldByName('out_contabtg').AsString)
                                  .AddPair('chavebtg',LDataSet.FieldByName('out_chavebtg').AsString)
                                  .AddPair('cepbtg',LDataSet.FieldByName('out_cepbtg').AsString)
                                  .AddPair('ruabtg',LDataSet.FieldByName('out_ruabtg').AsString)
                                  .AddPair('numerobtg',LDataSet.FieldByName('out_numerobtg').AsString)
                                  .AddPair('complementobtg',LDataSet.FieldByName('out_complementobtg').AsString)
                                  .AddPair('bairrobtg',LDataSet.FieldByName('out_bairrobtg').AsString)
                                  .AddPair('cidadebtg',LDataSet.FieldByName('out_cidadebtg').AsString)
                                  .AddPair('estadobtg',LDataSet.FieldByName('out_estadobtg').AsString)
                                  .AddPair('Conta',LDataSet.FieldByName('out_Pessoa').AsString)
                                  .AddPair('AlterSenha',LDataSet.FieldByName('out_alter_senha').AsString)).Status(THTTPStatus.OK);



            end
              else
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;

procedure GetAccess(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  LToken      : String;
  LResponse: IResponse;
  Retorno: TJSONArray;
  NovoValor: TJSONObject;

begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> '' then
        begin
          if Req.Headers.Items['x-Ambiente'] <> '' then
          begin
            if Req.Headers.Items['x-Versao'] <> '' then
            begin

              LDataSet := LDAO.GetAccess(Req.Headers.Items['x-login'],
                                   Req.Headers.Items['x-password'],                      //Painel_Saquei
                                   Req.Headers.Items['x-AfiCodigo'],
                                   Req.Headers.Items['x-Ambiente'],
                                   Req.Headers.Items['x-Versao']);

              if not LDataSet.IsEmpty then
              begin
                if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
                begin

                  LJWT    := TJWT.Create(TMyClaims);
                  LClaims := TMyClaims(LJWT.Claims);

                  LClaims.Issuer     := 'SAQUEI';
                  LClaims.Subject    := 'Bank as Service';
                  LClaims.Expiration := IncMinute(Now,180);

                  LClaims.userId         := LDataSet.FieldByName('out_Pessoa').AsString;
                  LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                  LClaims.CodigoAfiliado := LDataSet.FieldByName('out_Cpfcnpj').AsString;
                  LClaims.Terminal       := '';
                  LClaims.Email          := LDataSet.FieldByName('out_email').AsString;
                  LClaims.Telefone       := LDataSet.FieldByName('out_telefone').AsString;

                  Retorno := LDataSet.ToJSONArray();

                  LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);

                  Res.Send('{"token":"'+LToken+'","retorno":'+Retorno.ToString+'}').Status(THTTPStatus.OK);

                end
                  else
                begin
                  Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
                end;
              end
                else
              begin
                 Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
              end;
            end
              else
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;

procedure GetAcessoUsuarioWeb(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  LDataSet    : TDataSet;
  LResponse   : IResponse;
  xAfiCodigo  : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if req.Params.Items['x-AfiCodigo'] <> '' then
      xAfiCodigo := req.Params.Items['x-AfiCodigo']
    else
      xAfiCodigo := 'SOCZA001';

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin
        LDataSet := LDAO.AcessoUsuarioWeb(Req.Headers.Items['x-login'],
                                 Req.Headers.Items['x-password'],
                                 xAfiCodigo);

        if not LDataSet.IsEmpty then
        begin
          Res.Send<TJSONArray>(LDataSet.ToJSONArray()).Status(THTTPStatus.OK);

          
        end
          else
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end
        else
      begin
        Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('mensagem', 'Acesso negado'))).Status(THTTPStatus.Unauthorized);
    end;
  finally
    LDAO.Free
  end;
end;

procedure GetListaUsuarios(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xRetorno    : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Query.Items['AfiCodigo'] <> '' then
    begin
      Res.Send<TJSONObject>(LDAO.ListaUsuarios(Req.Query.Items['x-AfiCodigo'],Req.Query.Items['x-Usuario']));
    end
      else
    begin
      Res.Send('Mensagem: Codigo nao informado.').Status(THTTPStatus.NotFound);
    end;
  finally
    LDAO.Free;
  end;
end;

procedure PostCadastraUsuario(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xRetorno    : String;
begin




  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Query.Items['x-AfiCodigo'] <> '' then
    begin
      if Req.Query.Items['x-PerfilUsuario'] <> '' then
      begin
        if Req.Query.Items['x-NomeUsuario'] <> '' then
        begin
          if Req.Query.Items['x-NomeExibicaoUsuario'] <> '' then
          begin
            if Req.Query.Items['x-UsuarioLogin'] <> '' then
            begin
               if Req.Query.Items['x-UsuarioSenha'] <> '' then
               begin
                 if ldao.CadastraUsuario(Req.Query.Items['x-AfiCodigo'],
                                      Req.Query.Items['x-PerfilUsuario'],
                                      Req.Query.Items['x-NomeUsuario'],
                                      Req.Query.Items['x-NomeExibicaoUsuario'],
                                      Req.Query.Items['x-UsuarioLogin'],
                                      Req.Query.Items['x-UsuarioSenha'],
                                      Req.Query.Items['x-UsuarioEmail'],
                                      Req.Query.Items['x-UsuarioTelefone'],
                                      xRetorno) then
                 begin
                   if Pos('OK',xRetorno) > 0  then
                   begin
                     Res.Send(xRetorno).Status(THTTPStatus.OK);
                   end
                     else
                   begin
                     Res.Send(xRetorno).Status(THTTPStatus.Unauthorized);
                   end;
                 end
                   else
                 begin
                   Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
                 end;
               end
                 else
               begin
                 Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
               end;
            end
              else
            begin
              Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
    end;
  except
    Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
  end;
end;

procedure PutAlteraUsuario(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xRetorno    : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if (Req.Query.Items['x-AfiCodigo'] <> '') and (Req.Query.Items['x-UsuarioLogin'] <> '')then
    begin
      if Req.Query.Items['x-PerfilUsuario'] <> '' then
      begin
        if Req.Query.Items['x-NomeUsuario'] <> '' then
        begin
          if Req.Query.Items['x-NomeExibicaoUsuario'] <> '' then
          begin
            if Req.Query.Items['x-UsuarioSenha'] <> '' then
              begin
                if ldao.AlteraUsuario(Req.Query.Items['x-AfiCodigo'],
                                      Req.Query.Items['x-PerfilUsuario'],
                                      Req.Query.Items['x-NomeUsuario'],
                                      Req.Query.Items['x-NomeExibicaoUsuario'],
                                      Req.Query.Items['x-UsuarioLogin'],
                                      Req.Query.Items['x-UsuarioSenha'],
                                      Req.Query.Items['x-UsuarioEmail'],
                                      Req.Query.Items['x-UsuarioTelefone'],
                                      xRetorno) then
                begin
                  if Pos('OK',xRetorno) > 0  then
                  begin
                    Res.Send(xRetorno).Status(THTTPStatus.OK);
                  end
                    else
                  begin
                    Res.Send(xRetorno).Status(THTTPStatus.Unauthorized);
                  end;
                end
                  else
                begin
                  Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
                end;
              end
                else
              begin
                Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
              end;
          end
            else
          begin
            Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
         Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
    end;
  except
    Res.Send('Usuario nao cadastrado.').Status(THTTPStatus.Unauthorized);
  end;
end;

procedure GetAcessoUsuarios(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xAcess      : String;
  LToken      : String;
  xResult     : TStringArray;

  LResponse : IResponse;
begin
  //Pega o ini na raiz do exe, para realizar a conexao.         33510109000128
  LConnection := TADRConnModelFactory.GetConnectionIniFile();
  LConnection.Connect;

  LDAO := TADRConnAccessDAO.create(LConnection);
  Try
    if (Req.Headers.Items['x-Afiliado-Licence'] <> '')  and
       (Req.Headers.Items['x-Afiliado-KeyAcess'] <> '') and
        (Req.Headers.Items['x-Afiliado-Token'] <> '')   then
    begin
      if Req.Headers.Items['x-Afiliado'] <> '' then
      begin
        if Req.Headers.Items['x-Terminal'] <> '' then
        begin
          if Req.Headers.Items['x-user'] <> '' then
          begin
            if Req.Headers.Items['x-pass'] <> '' then
            begin
              if Req.Headers.Items['x-Afiliado-Licence'] = ValidaChaveRegistro('',Req.Headers.Items['x-Afiliado']+Req.Headers.Items['x-Terminal']) then
              begin
                //System.WriteLn('#length - %d', Length(Trim(Req.Headers.Items['x-Afiliado-KeyAcess'])));
                //System.WriteLn('#length - %d', Req.Headers.Items['x-Afiliado-KeyAcess']);
                if Length(Trim(Req.Headers.Items['x-Afiliado-KeyAcess'])) <= 22 then
                begin
                  xAcess := ValidaCodigoAcessoToken(Req.Headers.Items['x-Afiliado-Token'],Req.Headers.Items['x-Afiliado-KeyAcess']);

                  if Copy(xAcess,1,14) = Req.Headers.Items['x-Afiliado'] then
                  begin
                    if StrToDate(Copy(xAcess,16,10)) >= Date then
                    begin
                      //Cria as posicoes para o Retorno.
                      SetLength(xResult,6);

                      xResult :=  LDAO.ValidaAcessoUsuario(
                                  Req.Headers.Items['x-Afiliado'],
                                  Req.Headers.Items['x-Terminal'],
                                  Req.Headers.Items['x-user'],
                                  Req.Headers.Items['x-pass'],
                                  Req.Headers.Items['x-Dispositivo'],
                                  Req.Headers.Items['x-Versao']);

                      if xResult[0] = '200 - Acesso Liberado.' then
                      begin
                        LJWT    := TJWT.Create(TMyClaims);
                        LClaims := TMyClaims(LJWT.Claims);

                        LClaims.Issuer     := 'SAQUEI';
                        LClaims.Subject    := 'Bank as Service';
                        LClaims.Expiration := IncMinute(Now,40);

                        LClaims.userId         := xResult[2];
                        LClaims.NomeUser       := xResult[4];
                        LClaims.CodigoAfiliado := xResult[1];
                        LClaims.Terminal       := xResult[5];

                        LToken := TJOSE.SHA512CompactToken(xChaveMaster, LJWT);
                        Res.Send(TJSONObject.Create(TJSONPair.Create('token', LToken))).Status(THTTPStatus.OK);

                      
                      end
                        else
                      begin
                        Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
                      end;
                    end
                      else
                    begin
                      Res.Send('Expired License').Status(THTTPStatus.ServiceUnavailable);
                    end;
                  end
                    else
                  begin
                    Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
                  end;
                end
                  else
                begin
                  Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
                end;
              end
                else
              begin
                Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
              end;
            end
              else
            begin
              Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
      end;
    end
      else
    begin
      Res.Send('Unauthorized').Status(THTTPStatus.Unauthorized);
    end;
  Finally
    LDataSet.Free;
    LDAO.Free;
  End;
end;

procedure PostCadastraPerfilAcesso(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xRetorno    : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Query.Items['X-AfiCodigo'] <> '' then
    begin
      if Req.Query.Items['X-PerfilNome'] <> '' then
      begin
        if LDAO.CadastraPerfil(Req.Query.Items['X-AfiCodigo'],
                            Req.Query.Items['X-PerfilNome'],
                            xRetorno) then
        begin
          if Pos('OK',xRetorno) > 0  then
          begin
            Res.Send(xRetorno).Status(THTTPStatus.OK);
          end
            else
          begin
            Res.Send(xRetorno).Status(THTTPStatus.Unauthorized);
          end;
        end;
      end;
    end;
  finally
    LDAO.Free;
  end;
end;

procedure PutAlteraPerfilCadastro(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  xRetorno    : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAccessDAO.create(LConnection);

    if Req.Query.Items['X-AfiCodigo'] <> '' then
    begin
      if Req.Query.Items['X-Perfil'] <> '' then
      begin
        if Req.Query.Items['X-PerfilNome'] <> '' then
        begin
          if LDAO.AlteraPerfil(Req.Query.Items['X-AfiCodigo'],
                            Req.Query.Items['X-Perfil'],
                            Req.Query.Items['X-PerfilNome'],
                            xRetorno) then
          begin
            if Pos('OK',xRetorno) > 0  then
            begin
              Res.Send(xRetorno).Status(THTTPStatus.OK);
            end
              else
            begin
              Res.Send(xRetorno).Status(THTTPStatus.Unauthorized);
            end;
          end;
        end;
      end;
    end;
  finally
    LDAO.Free;
  end;
end;

procedure GetValidaKeyTransacional(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
        if Req.Headers.Items['x-Pes'] <> '' then
        begin
          if Req.Headers.Items['x-Key'] <> '' then
          begin
            if LDAO.ValidaKeyTransacional(Req.Headers.Items['x-AfiCodigo'],
                                          Req.Headers.Items['x-Pes'],
                                          Req.Headers.Items['x-Key']) then
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', true))).Status(THTTPStatus.OK);
            end
              else
            begin
              Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', false))).Status(THTTPStatus.OK);
            end;
          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"Key invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Pes invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;
  except on E: Exception do
    Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', 'Erro interno.'))).Status(THTTPStatus.Unauthorized);
  end;
end;

procedure CadastraKeyTransacional(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PesID'] <> '' then
      begin
        if Req.Headers.Items['x-Login'] <> '' then
        begin
          if Req.Headers.Items['x-Key'] <> '' then
          begin
            if Req.Headers.Items['x-AfiCodigo'] <> '' then
            begin

              //PesID, Login, Key, AfiCodigo
              if LDAO.CadastraKeyTransacional(Req.Headers.Items['x-PesID'],
                                            Req.Headers.Items['x-Login'],
                                            Req.Headers.Items['x-Key'],
                                            Req.Headers.Items['x-AfiCodigo'],
                                            retorno) then
              begin
                Res.Send('{"erros":false, "retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
              end
                else
              begin
                Res.Send('{"erros":true, "retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
              end;

            end
              else
            begin
              Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"Key invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Login invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;
  except on E: Exception do
    Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', 'Erro interno.'))).Status(THTTPStatus.Unauthorized);
  end;
end;


procedure VisualizaKeyTransacional(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-Login'] <> '' then
      begin
        if Req.Headers.Items['x-Senha'] <> '' then
        begin
          if Req.Headers.Items['x-AfiCodigo'] <> '' then
          begin
            if Req.Headers.Items['x-PesID'] <> '' then
            begin

              //Login, Senha, AfiCodigo, PesID
              if LDAO.VisualizaKeyTransacional(Req.Headers.Items['x-Login'],
                                            Req.Headers.Items['x-Senha'],
                                            Req.Headers.Items['x-AfiCodigo'],
                                            Req.Headers.Items['x-PesID'],
                                            retorno) then
              begin
                Res.Send('{"erros":false, "retorno":"'+retorno+'"}').Status(THTTPStatus.ok);
              end
                else
              begin
                Res.Send('{"erros":true, "retorno":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
              end;

            end
              else
            begin
              Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Senha invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Login invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;
  except on E: Exception do
    Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', 'Erro interno.'))).Status(THTTPStatus.Unauthorized);
  end;
end;


procedure GetPermissaoUsuario(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if True then




    finally
      LDAO.Free;
    end;
  except on E: Exception do
    Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', 'Erro interno.'))).Status(THTTPStatus.Unauthorized);
  end;
end;


procedure PostTwoFactorChange(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
        if Req.Headers.Items['x-PerfilAcessoID'] <> '' then
        begin

          if LDAO.PostTwoFactorChange(Req.Headers.Items['x-AfiCodigo'],
                                Req.Headers.Items['x-PerfilAcessoID']) then

          begin
            Res.Send('{"erros":false,"mensagem":"Atualizado"}').Status(THTTPStatus.OK)
          end
            else
          begin
            Res.Send('{"erros":true,"mensagem":"Nao Atualizado"}').Status(THTTPStatus.OK);
          end;

        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"PerfilAcessoID invalido"}').Status(THTTPStatus.Unauthorized);
        end;

      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
      end;


    finally
      LDAO.Free;
    end;
  except on E: Exception do
    Res.Send(TJSONObject.Create(TJSONPair.Create('resultado', 'Erro interno.'))).Status(THTTPStatus.Unauthorized);
  end;
end;

{####### CHATS #######}


procedure GetChatAfiliado(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
         Res.Send<TJsonArray>(LDAO.ChatAfiliado(Req.Headers.Items['x-Documento'], Req.Headers.Items['x-AfiCodigo'])).Status(THTTPStatus.OK);
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;

procedure GetStatusAberturaChat(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;
      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-Documento'] <> '' then
      begin
         Res.Send<TJsonArray>(LDAO.GetStatusAberturaChat(Req.Headers.Items['x-Documento'])).Status(THTTPStatus.OK);
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Documento invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure PostRespostaChat(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno: string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PerguntaID'] <> '' then
      begin
        if Req.Headers.Items['x-Documento'] <> '' then
        begin
          if Req.Headers.Items['x-Afiliado'] <> '' then
          begin
            if Req.Headers.Items['x-Resposta'] <> '' then
            begin
              if Req.Headers.Items['x-IMEI'] <> '' then
              begin

                if LDAO.RespostaChat(Req.Headers.Items['x-PerguntaID'],
                                      Req.Headers.Items['x-Documento'],
                                      Req.Headers.Items['x-Afiliado'],
                                      Req.Headers.Items['x-Resposta'],
                                      Req.Headers.Items['x-IMEI'],
                                      retorno) then

                begin
                  Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
                end
                  else
                begin
                  Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK);
                end;

              end
                else
              begin
                Res.Send('{"erros":true, "mensagem":"IMEI invalido"}').Status(THTTPStatus.Unauthorized);
              end;
            end
              else
            begin
              Res.Send('{"erros":true, "mensagem":"Resposta invalido"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Documento invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PerguntaID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;



procedure ListaUsuariosAfiliado(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
         Res.Send<TJsonArray>(LDAO.ListaUsuariosAfiliado(Req.Headers.Items['x-AfiCodigo'])).Status(THTTPStatus.OK);
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure ResetTwoFactorToken(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-UsuID'] <> '' then
      begin
        if Req.Headers.Items['x-Login'] <> '' then
        begin
          if Req.Headers.Items['x-AfiCodigo'] <> '' then
          begin

            //UsuID, Login, AfiCodigo
           if LDAO.ResetTwoFactorToken(Req.Headers.Items['x-UsuID'],
                                        Req.Headers.Items['x-Login'],
                                        Req.Headers.Items['x-AfiCodigo'],
                                        retorno) then

            begin
              Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK);
            end;

          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Login invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"UsuID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure ValidaImeiAparelho(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PesID'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> '' then
        begin
          if Req.Headers.Items['x-IMEI'] <> '' then
          begin

            //PesID, AfiCodigo, IMEI
            if LDAO.ValidaImeiAparelho(Req.Headers.Items['x-PesID'],
                                        Req.Headers.Items['x-AfiCodigo'],
                                        Req.Headers.Items['x-IMEI'],
                                        retorno) then

            begin
              Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
            end;

          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"IMEI invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure ResetImeiAparelhoPessoa(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PesID'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> '' then
        begin
          if Req.Headers.Items['x-UsuID'] <> '' then
          begin

            //PesID, AfiCodigo
            if LDAO.ResetImeiAparelhoPessoa(Req.Headers.Items['x-PesID'],
                                        Req.Headers.Items['x-AfiCodigo'],
                                        Req.Headers.Items['x-UsuID'],
                                        retorno) then

            begin
              Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
            end;

          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"UsuID invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure ValidaTokenPushAparelho(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PesID'] <> '' then
      begin
        if Req.Headers.Items['x-AfiCodigo'] <> '' then
        begin
          if Req.Headers.Items['x-FCM'] <> '' then
          begin

            //PesID, AfiCodigo, FCM, Remocao
            if LDAO.ValidaTokenPushAparelho(Req.Headers.Items['x-PesID'],
                                        Req.Headers.Items['x-AfiCodigo'],
                                        Req.Headers.Items['x-FCM'],
                                        retorno) then

            begin
              Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK);
            end;

          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"FCM invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;

end;


procedure ValidaDocumentoPessoa(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-PesID'] <> '' then
      begin
        if Req.Headers.Items['x-DocID'] <> '' then
        begin
          if Req.Headers.Items['x-UsuID'] <> '' then
          begin
            if Req.query.Items['x-Documento'] <> '' then
            begin

              //PesID, DocID, UsuID, Documento, Validade
              if LDAO.ValidaDocumentoPessoa(Req.Headers.Items['x-PesID'],
                                            Req.Headers.Items['x-DocID'],
                                            Req.Headers.Items['x-UsuID'],
                                            Req.query.Items['x-Documento'],
                                            Req.Headers.Items['x-Validade'],
                                            retorno) then

              begin
                Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
              end
                else
              begin
                Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
              end;

            end
              else
            begin
               Res.Send('{"erros":true, "mensagem":"Documento invalido"}').Status(THTTPStatus.Unauthorized);
            end;
          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"UsuID invalido"}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"DocID invalido"}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"PesID invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;

end;



procedure RetornaVersaoAmbiente(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
        if Req.Headers.Items['x-Ambiente'] <> '' then
        begin

           Res.Send<TJsonArray>(LDAO.RetornaVersaoAmbiente(Req.Headers.Items['x-AfiCodigo'],Req.Headers.Items['x-Ambiente'])).Status(THTTPStatus.OK);

        end
          else
        begin
          Res.Send('{"erros":true, "mensagem":"Ambiente invalido"}').Status(THTTPStatus.Unauthorized);
        end;

      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;




procedure CriaInativaAcessoAPI(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
  retorno, Login, Senha, APiKey  : string;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin
//        if Req.Headers.Items['x-Tipo'] <> '' then
//        begin
          if Req.Headers.Items['x-UsuID'] <> '' then
          begin

            APiKey := GuidCreate;
            APiKey := StringReplace(APiKey,'{','',[rfReplaceAll]);
            APiKey := StringReplace(APiKey,'}','',[rfReplaceAll]);

            Login := GenerateHash(Req.Headers.Items['x-AfiCodigo'] + APiKey + now().ToString);
            Login := copy(Login,1,120);

            Senha := GenerateHash(Login + APiKey + now().ToString);
            Senha := copy(Senha,1,120);


            //AfiCodigo, Tipo, Login, Senha, UsuID, ACP_ID, Status
            if LDAO.CriaInativaAcessoAPI(Req.Headers.Items['x-AfiCodigo'],
//                                          Req.Headers.Items['x-Tipo'],
                                          Login,
                                          Senha,
                                          APiKey,
                                          Req.Headers.Items['x-UsuID'],
                                          Req.Headers.Items['x-ACP_ID'],
                                          Req.Headers.Items['x-Status'],
                                          Req.Headers.Items['x-Resetar'],
                                          retorno) then

            begin
              Res.Send('{"erros":false,"mensagem":"'+retorno+'"}').Status(THTTPStatus.OK)
            end
              else
            begin
              Res.Send('{"erros":true,"mensagem":"'+retorno+'"}').Status(THTTPStatus.Unauthorized);
            end;

          end
            else
          begin
            Res.Send('{"erros":true, "mensagem":"UsuID invalido"}').Status(THTTPStatus.Unauthorized);
          end;
//        end
//          else
//        begin
//          Res.Send('{"erros":true, "mensagem":"Tipo invalido"}').Status(THTTPStatus.Unauthorized);
//        end;
      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"AfiCodigo invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


procedure VisualizaAcessoAPI(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnAccessDAO;
begin
  try
    try
      LConnection := TADRConnModelFactory.GetConnectionIniFile;
      LConnection.Connect;

      LDAO        := TADRConnAccessDAO.create(LConnection);

      if Req.Headers.Items['x-AfiCodigo'] <> '' then
      begin

        Res.Send<TJsonArray>(LDAO.VisualizaAcessoAPI(Req.Headers.Items['x-AfiCodigo'])).Status(THTTPStatus.OK);

      end
        else
      begin
        Res.Send('{"erros":true, "mensagem":"Afiliado invalido"}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free;
    end;

  except on E: Exception do
    Res.Send('{"erros":true, "mensagem":"'+e.Message+'"}').Status(THTTPStatus.Unauthorized);
  end;
end;


{ TMyClaims }

function TMyClaims.GetCodigoAfiliado: string;
begin
  Result := TJSONUtils.GetJSONValue('CodigoAfiliado', FJSON).AsString;
end;

function TMyClaims.GetNomeUser: string;
begin
  Result := TJSONUtils.GetJSONValue('NomeUser', FJSON).AsString;
end;

function TMyClaims.GetTerminal: string;
begin
  Result := TJSONUtils.GetJSONValue('Terminal', FJSON).AsString;
end;

function TMyClaims.GetuserId: string;
begin
  Result := TJSONUtils.GetJSONValue('userId', FJSON).AsString;
end;

procedure TMyClaims.SetAgencia(const Value: string);
begin
  FAgencia := Value;
end;

procedure TMyClaims.SetBairrobtg(const Value: string);
begin
  FBairrobtg := Value;
end;

procedure TMyClaims.SetCepbtg(const Value: string);
begin
  FCepbtg := Value;
end;

procedure TMyClaims.SetChavePixBtg(const Value: string);
begin
  FChavePixBtg := Value;
end;

procedure TMyClaims.SetCidadebtg(const Value: string);
begin
  FCidadebtg := Value;
end;

procedure TMyClaims.SetCodigoAfiliado(const Value: string);
begin
   TJSONUtils.SetJSONValueFrom<string>('CodigoAfiliado', Value, FJSON);
end;

procedure TMyClaims.SetComplementobtg(const Value: string);
begin
  FComplementobtg := Value;
end;

procedure TMyClaims.SetConta(const Value: string);
begin
  FConta := Value;
end;

procedure TMyClaims.SetDocumentoContaBtg(const Value: string);
begin
  FDocumentoContaBtg := Value;
end;

procedure TMyClaims.SetEmail(const Value: String);
begin
  FEmail := Value;
end;

procedure TMyClaims.SetEstadobtg(const Value: string);
begin
  FEstadobtg := Value;
end;

procedure TMyClaims.SetNomeUser(const Value: string);
begin
   TJSONUtils.SetJSONValueFrom<string>('NomeUser', Value, FJSON);
end;

procedure TMyClaims.SetNumerobtg(const Value: string);
begin
  FNumerobtg := Value;
end;

procedure TMyClaims.SetRuabtg(const Value: string);
begin
  FRuabtg := Value;
end;

procedure TMyClaims.SetTelefone(const Value: string);
begin
  FTelefone := Value;
end;

procedure TMyClaims.SetTerminal(const Value: string);
begin
   TJSONUtils.SetJSONValueFrom<string>('Terminal', Value, FJSON);
end;

procedure TMyClaims.SetuserId(const Value: string);
begin
   TJSONUtils.SetJSONValueFrom<string>('userId', Value, FJSON);
end;

end.
