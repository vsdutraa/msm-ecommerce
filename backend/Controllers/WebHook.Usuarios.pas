unit WebHook.Usuarios;

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
  FireDAC.Comp.Client,
  System.Classes,

  WebHook.Acesso,
  Usuarios.DAO,

  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory;

  procedure RegisterUsuarios;

  procedure GravaUsuarios (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure ListaUsuarios (Req : THorseRequest; Res : THorseResponse; Next : TProc);
  procedure AlteraInfoUsuario (Req : THorseRequest; Res : THorseResponse; Next : TProc);

implementation

procedure RegisterUsuarios;
begin

  THorse
//    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('v1/PostGravaUsuarios',GravaUsuarios);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('v1/GetUsuarios',ListaUsuarios);

  THorse
    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Post('v1/PostAltDadosUsuarios',AlteraInfoUsuario);

end;

procedure GravaUsuarios (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnUsuario;
  xRetorno,
  xUsuID      : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO := TADRConnUsuario.create(LConnection);

    try

      if Req.Headers.Items['x-login'] <> '' then
      begin
        if Req.Headers.Items['x-password'] <> '' then
        begin
          if Req.Headers.Items['x-Tipo'] <> '' then
          begin

            if LDAO.GravaUsuario(Req.Headers.Items['x-login'   ],
                                 Req.Headers.Items['x-password'],
                                 Req.Headers.Items['x-Tipo'    ],
                                 xRetorno,
                                 xUsuID) then

            begin
              Res.Send('{"erros":"false","mensagem":"'+xRetorno+'","usuId":"'+xUsuID+'"}').Status(THTTPStatus.OK);
            end
              else
            begin
              Res.Send('{"erros":"true","mensagem":"'+xRetorno+'"}').Status(THTTPStatus.Unauthorized);
            end;

          end
            else
          begin
            Res.Send('{"erros":"true","mensagem":"Campo Tipo vazio."}').Status(THTTPStatus.Unauthorized);
          end;
        end
          else
        begin
          Res.Send('{"erros":"true","mensagem":"Campo password vazio."}').Status(THTTPStatus.Unauthorized);
        end;
      end
        else
      begin
        Res.Send('{"erros":"true","mensagem":"Campo login vazio."}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free
    end;

  except on E: Exception do
    begin
      Res.Send('{"erros":"true","mensagem":"'+E.Message+'"}').Status(THTTPStatus.Unauthorized);
    end;

  end;

end;

procedure ListaUsuarios (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnUsuario;
  xRetorno,
  xUsuID      : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO := TADRConnUsuario.create(LConnection);

    try

      Res.Send<TJSONObject>(LDAO.ListaInfoUsu(Req.Headers.Items['x-UsuID'])).Status(THTTPStatus.OK);

    finally
      LDAO.Free
    end;

  except on E: Exception do
    begin
      Res.Send('{"erros":"true","mensagem":"'+E.Message+'"}').Status(THTTPStatus.Unauthorized);
    end;

  end;

end;

procedure AlteraInfoUsuario (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LConnection : IADRConnection;
  LDAO        : TADRConnUsuario;
  xRetorno,
  xUsuID      : String;
begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO := TADRConnUsuario.create(LConnection);

    try

      if Req.Headers.Items['x-UsuID'] <> '' then
      begin

        // Usu_Id, telefone, nome, documento, senha

        if LDAO.AlteraDadosUsu(Req.Headers.Items['x-UsuID'         ],
                               Req.Headers.Items['x-Telefone'      ],
                               Req.Headers.Items['x-Nome'          ],
                               Req.Headers.Items['x-Documento'     ],
                               Req.Headers.Items['x-Senha'         ],
                               Req.Headers.Items['x-DataNascimento'],
                               xRetorno
                               ) then

        begin
          Res.Send('{"erros":"false","mensagem":"'+xRetorno+'"}').Status(THTTPStatus.OK);
        end
          else
        begin
          Res.Send('{"erros":"true","mensagem":"'+xRetorno+'"}').Status(THTTPStatus.Unauthorized);
        end;

      end
        else
      begin
        Res.Send('{"erros":"true","mensagem":"Campo UsuID vazio."}').Status(THTTPStatus.Unauthorized);
      end;

    finally
      LDAO.Free
    end;

  except on E: Exception do
    begin
      Res.Send('{"erros":"true","mensagem":"'+E.Message+'"}').Status(THTTPStatus.Unauthorized);
    end;

  end;

end;

end.
