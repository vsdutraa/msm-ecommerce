program SrvEcommerce;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.JSON,
  System.StrUtils,
  DateUtils,
  Winsock,
  ADRConn.Config.IniFile in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Config.IniFile.pas',
  ADRConn.Model.Factory in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Factory.pas',
  ADRConn.Model.Firedac.Connection in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Firedac.Connection.pas',
  ADRConn.Model.Firedac.Driver in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Firedac.Driver.pas',
  ADRConn.Model.Firedac.Query in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Firedac.Query.pas',
  ADRConn.Model.Generator.Firebird in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Generator.Firebird.pas',
  ADRConn.Model.Generator.MySQL in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Generator.MySQL.pas',
  ADRConn.Model.Generator in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Generator.pas',
  ADRConn.Model.Generator.Postgres in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Generator.Postgres.pas',
  ADRConn.Model.Generator.SQLite in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Generator.SQLite.pas',
  ADRConn.Model.Interfaces in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Interfaces.pas',
  ADRConn.Model.Params in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.Model.Params.pas',
  RESTRequest4D in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.pas',
  RESTRequest4D.Request.Contract in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.Request.Contract.pas',
  RESTRequest4D.Response.Contract in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.Response.Contract.pas',
  RESTRequest4D.Request.Adapter.Contract in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.Request.Adapter.Contract.pas',
  RESTRequest4D.Request.Client in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.Request.Client.pas',
  RESTRequest4D.Response.Client in '..\Repositorio\Componentes\restrequest4delphi\src\RESTRequest4D.Response.Client.pas',
  Horse.Callback in '..\Repositorio\Componentes\horse-master\src\Horse.Callback.pas',
  Horse.Commons in '..\Repositorio\Componentes\horse-master\src\Horse.Commons.pas',
  Horse.Constants in '..\Repositorio\Componentes\horse-master\src\Horse.Constants.pas',
  Horse.Core.Files in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Files.pas',
  Horse.Core.Group.Contract in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Group.Contract.pas',
  Horse.Core.Group in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Group.pas',
  Horse.Core.Param.Config in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Param.Config.pas',
  Horse.Core.Param.Field.Brackets in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Param.Field.Brackets.pas',
  Horse.Core.Param.Field in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Param.Field.pas',
  Horse.Core.Param.Header in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Param.Header.pas',
  Horse.Core.Param in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Param.pas',
  Horse.Core in '..\Repositorio\Componentes\horse-master\src\Horse.Core.pas',
  Horse.Core.Route.Contract in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Route.Contract.pas',
  Horse.Core.Route in '..\Repositorio\Componentes\horse-master\src\Horse.Core.Route.pas',
  Horse.Core.RouterTree.NextCaller in '..\Repositorio\Componentes\horse-master\src\Horse.Core.RouterTree.NextCaller.pas',
  Horse.Core.RouterTree in '..\Repositorio\Componentes\horse-master\src\Horse.Core.RouterTree.pas',
  Horse.Exception.Interrupted in '..\Repositorio\Componentes\horse-master\src\Horse.Exception.Interrupted.pas',
  Horse.Exception in '..\Repositorio\Componentes\horse-master\src\Horse.Exception.pas',
  Horse in '..\Repositorio\Componentes\horse-master\src\Horse.pas',
  Horse.Proc in '..\Repositorio\Componentes\horse-master\src\Horse.Proc.pas',
  Horse.Provider.Abstract in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.Abstract.pas',
  Horse.Provider.Apache in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.Apache.pas',
  Horse.Provider.CGI in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.CGI.pas',
  Horse.Provider.Console in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.Console.pas',
  Horse.Provider.Daemon in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.Daemon.pas',
  Horse.Provider.FPC.Apache in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.Apache.pas',
  Horse.Provider.FPC.CGI in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.CGI.pas',
  Horse.Provider.FPC.Daemon in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.Daemon.pas',
  Horse.Provider.FPC.FastCGI in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.FastCGI.pas',
  Horse.Provider.FPC.HTTPApplication in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.HTTPApplication.pas',
  Horse.Provider.FPC.LCL in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.FPC.LCL.pas',
  Horse.Provider.IOHandleSSL in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.IOHandleSSL.pas',
  Horse.Provider.ISAPI in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.ISAPI.pas',
  Horse.Provider.VCL in '..\Repositorio\Componentes\horse-master\src\Horse.Provider.VCL.pas',
  Horse.Request in '..\Repositorio\Componentes\horse-master\src\Horse.Request.pas',
  Horse.Response in '..\Repositorio\Componentes\horse-master\src\Horse.Response.pas',
  Horse.Rtti.Helper in '..\Repositorio\Componentes\horse-master\src\Horse.Rtti.Helper.pas',
  Horse.Rtti in '..\Repositorio\Componentes\horse-master\src\Horse.Rtti.pas',
  Horse.Session in '..\Repositorio\Componentes\horse-master\src\Horse.Session.pas',
  Horse.WebModule in '..\Repositorio\Componentes\horse-master\src\Horse.WebModule.pas',
  ThirdParty.Posix.Syslog in '..\Repositorio\Componentes\horse-master\src\ThirdParty.Posix.Syslog.pas',
  Web.WebConst in '..\Repositorio\Componentes\horse-master\src\Web.WebConst.pas',
  Horse.Jhonson in '..\Repositorio\Componentes\jhonson\src\Horse.Jhonson.pas',
  Horse.Paginate in '..\Repositorio\Componentes\Horse-Paginate-master\src\Horse.Paginate.pas',
  Horse.Compression in '..\Repositorio\Componentes\horse-compression\src\Horse.Compression.pas',
  Horse.Compression.Types in '..\Repositorio\Componentes\horse-compression\src\Horse.Compression.Types.pas',
  DataSet.Serialize.Config in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Config.pas',
  DataSet.Serialize.Consts in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Consts.pas',
  DataSet.Serialize.Export in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Export.pas',
  DataSet.Serialize.Import in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Import.pas',
  DataSet.Serialize.Language in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Language.pas',
  DataSet.Serialize in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.pas',
  DataSet.Serialize.UpdatedStatus in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.UpdatedStatus.pas',
  DataSet.Serialize.Utils in '..\Repositorio\Componentes\dataset-serialize-master\src\DataSet.Serialize.Utils.pas',
  JOSE.Encoding.Base64 in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Encoding.Base64.pas',
  JOSE.Hashing.HMAC in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Hashing.HMAC.pas',
  JOSE.OpenSSL.Headers in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.OpenSSL.Headers.pas',
  JOSE.Signing.Base in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Signing.Base.pas',
  JOSE.Signing.ECDSA in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Signing.ECDSA.pas',
  JOSE.Signing.RSA in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Signing.RSA.pas',
  JOSE.Types.Arrays in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Types.Arrays.pas',
  JOSE.Types.Bytes in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Types.Bytes.pas',
  JOSE.Types.JSON in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Types.JSON.pas',
  JOSE.Types.Utils in '..\Repositorio\Componentes\delphi-jose-jwt\Source\Common\JOSE.Types.Utils.pas',
  JOSE.Builder in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Builder.pas',
  JOSE.Consumer in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Consumer.pas',
  JOSE.Consumer.Validators in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Consumer.Validators.pas',
  JOSE.Context in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Context.pas',
  JOSE.Core.Base in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.Base.pas',
  JOSE.Core.Builder in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.Builder.pas',
  JOSE.Core.JWA.Compression in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWA.Compression.pas',
  JOSE.Core.JWA.Encryption in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWA.Encryption.pas',
  JOSE.Core.JWA.Factory in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWA.Factory.pas',
  JOSE.Core.JWA in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWA.pas',
  JOSE.Core.JWA.Signing in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWA.Signing.pas',
  JOSE.Core.JWE in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWE.pas',
  JOSE.Core.JWK in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWK.pas',
  JOSE.Core.JWS in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWS.pas',
  JOSE.Core.JWT in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.JWT.pas',
  JOSE.Core.Parts in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Core.Parts.pas',
  JOSE.Producer in '..\Repositorio\Componentes\delphi-jose-jwt\Source\JOSE\JOSE.Producer.pas',
  Horse.JWT in '..\Repositorio\Componentes\horse-jwt-master\src\Horse.JWT.pas',
  Horse.CORS in '..\Repositorio\Componentes\horse-cors\src\Horse.CORS.pas',
  Acesso.DAO in 'DAO\Acesso.DAO.pas',
  ADRConn.DAO.Base in '..\Repositorio\Componentes\adrconnection\Source\ADRConn.DAO.Base.pas',
  WebHook.Acesso in 'Controllers\WebHook.Acesso.pas',
  Usuarios.DAO in 'DAO\Usuarios.DAO.pas',
  WebHook.Usuarios in 'Controllers\WebHook.Usuarios.pas';

function GetIp : String;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Name:string;
begin
  WSAStartup(2, WSAData);

  SetLength(Name, 255);
  Gethostname(PANsiChar(Name), 255);
  SetLength(Name, StrLen(PANsiChar(Name)));

  HostEnt := gethostbyname(PANsiChar(Name));

  with HostEnt^ do
  begin
    Result := Format('%d.%d.%d.%d',
    [Byte(h_addr^[0]),Byte(h_addr^[1]),
    Byte(h_addr^[2]),Byte(h_addr^[3])]);
  end;

  WSACleanup;
end;

begin

  // Registers
  RegisterAcesso;
  RegisterUsuarios;

  THorse
    .Use(Compression())
    .Use(Jhonson())
    .Use(Paginate)
    .Use(CORS);

  begin
    System.WriteLn('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
    System.WriteLn('= -       -       -       -  ††   -       -       -       - =');
    System.WriteLn('=  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -=');
    System.WriteLn('=   =       =       =       =       -       =       =       =');
    System.WriteLn('=-   -   -   -   -   -   -   -   -   -   -   -   -   -   -  =');
    System.WriteLn('=     =       =      WEBHOOK  30.05.25a       =       =     =');
    System.WriteLn('=  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -=');
    System.WriteLn('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
    System.WriteLn(Format('#Running - %d', [7033]));

    THorse.Listen(7033);
  end;
end.
