unit Acesso.DAO;

interface

uses
  ADRCOnn.Model.Interfaces,
  ADRCOnn.DAO.Base,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.StrUtils,
  System.IOUtils,
  DataSet.Serialize,
  Data.DB,
  IdURI,
  RESTRequest4D,
  DateUtils,
  Soap.EncdDecd,
  System.Hash,
  ADRConn.Model.Factory,
  REST.Client,
  Horse.JWT,
  JOSE.Core.JWT,
  JOSE.Core.JWS,
  JOSE.Core.JWK,
  JOSE.Core.JWA,
  System.NetEncoding,
  REST.Types;

type
  TADRConnAcesso = class(TADRConnDAOBase)
    public
      function GeraAcesso (login, password, ambiente, versao : String) : TDataSet;
end;

implementation

function TADRConnAcesso.GeraAcesso(login, password, ambiente, versao: string): TDataSet;
const
  xSql = 'SELECT * FROM STP_ACESSO(:P1,:P2,:P3,:P4)';
var
  LDataSet : TDataSet;
begin

    LDataSet := FQuery
                    .SQL(xSql)
                    .ParamAsString('P1',login)
                    .ParamAsString('P2',password)
                    .ParamAsString('P3',ambiente)
                    .ParamAsString('P4',versao)
                    .OpenDataSet;

      Result := LDataSet;

end;

end.
