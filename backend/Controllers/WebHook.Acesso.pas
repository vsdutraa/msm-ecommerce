unit WebHook.Acesso;

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

  Acesso.DAO,

  ADRConn.Model.Interfaces,
  ADRConn.Model.Factory;

  const
    xChaveMaster = '37c92a0309f99cb4a647af037e382fe064f6434dd73303c57738f9ccd455211358a94a95';

  procedure RegisterAcesso;

  procedure GetAccess (Req : THorseRequest; Res : THorseResponse; Next : TProc);

  type
  TMyClaims = class(TJWTClaims)
  private
    FEmail: String;
    function GetNomeUser: string;
    procedure SetNomeUser(const Value: string);
    procedure SetEmail(const Value: String);
  public
    property NomeUser: string read GetNomeUser write SetNomeUser;
    property Email : String read FEmail write SetEmail;
  end;


implementation

procedure RegisterAcesso;
begin

  THorse
//    .AddCallback(HorseJWT(xChaveMaster, THorseJWTConfig.New.SessionClass(TMyClaims)))
    .Get('v1/GetTokenAccess',GetAccess);

end;

procedure GetAccess(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
  LJWT        : TJWT;
  LClaims     : TMyClaims;
  LDataSet    : TDataSet;
  LConnection : IADRConnection;
  LDAO        : TADRConnAcesso;
  LToken      : String;
  LResponse: IResponse;
  Retorno: TJSONArray;
  NovoValor: TJSONObject;

begin
  try
    LConnection := TADRConnModelFactory.GetConnectionIniFile;
    LConnection.Connect;

    LDAO        := TADRConnAcesso.create(LConnection);

    if Req.Headers.Items['x-login'] <> '' then
    begin
      if Req.Headers.Items['x-password'] <> '' then
      begin
        if Req.Headers.Items['x-Ambiente'] <> '' then
        begin
          if Req.Headers.Items['x-Versao'] <> '' then
          begin

            LDataSet := LDAO.GeraAcesso(Req.Headers.Items['x-login'],
                                        Req.Headers.Items['x-password'],
                                        Req.Headers.Items['x-Ambiente'],
                                        Req.Headers.Items['x-Versao']);

            if not LDataSet.IsEmpty then
            begin
              if Pos('OK',LDataSet.FieldByName('out_Retorno').AsString) > 0 then
              begin

                LJWT    := TJWT.Create(TMyClaims);
                LClaims := TMyClaims(LJWT.Claims);

                LClaims.Issuer     := 'Luscz';
                LClaims.Subject    := 'Bank as Service';
                LClaims.Expiration := IncMinute(Now,18000);

                LClaims.NomeUser       := LDataSet.FieldByName('out_Nome').AsString;
                LClaims.Email          := LDataSet.FieldByName('out_email').AsString;

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

  finally
    LDAO.Free
  end;

end;

{ TMyClaims }

function TMyClaims.GetNomeUser: string;
begin
  Result := TJSONUtils.GetJSONValue('NomeUser', FJSON).AsString;
end;

procedure TMyClaims.SetEmail(const Value: String);
begin
  FEmail := Value;
end;

procedure TMyClaims.SetNomeUser(const Value: string);
begin
   TJSONUtils.SetJSONValueFrom<string>('NomeUser', Value, FJSON);
end;

end.
