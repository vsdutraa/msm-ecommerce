unit Usuarios.DAO;

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
  TADRConnUsuario = class(TADRConnDAOBase)
    public
      function GravaUsuario (login, password, Tipo : String ; out Retorno, Usu_Id : String) : Boolean;
      function ListaInfoUsu (usu_id : String) : TJSONObject;
      function AlteraDadosUsu (Usu_Id, telefone, nome, documento, senha, dataNascimento : String ; out Retorno : String) : Boolean;
end;

implementation

function TADRConnUsuario.GravaUsuario (login, password, Tipo : String ; out Retorno, Usu_Id : String) : Boolean;
const
  xSql = 'SELECT OUT_CODIGO_STATUS, OUT_RETORNO, OUT_USU_ID FROM STP_GRAVA_USUARIO(:P1,:P2,:P3)';
var
  LDataSet : TDataSet;
begin
  try

    LDataSet := FQuery
                    .SQL(xSql)
                    .ParamAsString('P1',login)
                    .ParamAsString('P2',password)
                    .ParamAsString('P3',Tipo)
                    .OpenDataSet;

    if LDataSet.FieldByName('OUT_CODIGO_STATUS').AsString = '200' then
    begin
      Result := true;
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
      Usu_Id := LDataSet.FieldByName('OUT_USU_ID').AsString;
    end
      else
    begin
      Result := false;
      Retorno := LDataSet.FieldByName('OUT_RETORNO').AsString;
    end;

  Except on E: Exception do
    begin
      Result := false;
      Retorno := E.Message;
    end;
  end;

end;

function TADRConnUsuario.ListaInfoUsu (usu_id : String) : TJSONObject;
const
  xSql = 'SELECT * FROM USUARIOS WHERE 1=1 ';
var
  LDataSet : TDataSet;
begin

  if Usu_Id <> '' then
  begin
    LDataSet := FQuery
                    .SQL(xSql + ' AND USU_ID = :P1')
                    .ParamAsString('P1',usu_id)
                    .OpenDataSet;
  end
    else
  begin
    LDataSet := FQuery
                    .SQL(xSql)
                    .OpenDataSet;
  end;

   result := LDataSet.ToJSONObject;

end;

function TADRConnUsuario.AlteraDadosUsu (Usu_Id, telefone, nome, documento, senha, dataNascimento : String ; out Retorno : String) : Boolean;
const
  xSql = 'UPDATE                                    '+
  '    USUARIOS                                     '+
  'SET                                              '+
  '    USU_NOME = COALESCE(:P2,USU_NOME),           '+
  '    USU_TELEFONE = COALESCE(:P3,USU_TELEFONE),   '+
  '    USU_DOCUMENTO = COALESCE(:P4,USU_DOCUMENTO), '+
  '    USU_SENHA = COALESCE(:P5,USU_SENHA),         '+
  '    USU_DATA_NASCIMENTO = COALESCE(:P6,USU_DATA_NASCIMENTO) '+
  'WHERE                                            '+
  '    USU_ID = :P1                                 ';
var
  LDataSet : TDataSet;
begin
  try

    FQuery
        .SQL(xSql)
        .ParamAsString('P1',Usu_Id);

      if nome <> '' then
        FQuery.ParamAsString('P2',nome);

      if telefone <> '' then
        FQuery.ParamAsString('P3',telefone);

      if documento <> '' then
        FQuery.ParamAsString('P4',documento);

      if senha <> '' then
        FQuery.ParamAsString('P5',senha);

      if dataNascimento <> '' then
        FQuery.ParamAsString('P6',dataNascimento);

    FQuery.ExecSQLAndCommit;

    Result := true;
    Retorno := 'Sucesso ao atualizar dados.';

  Except on E: Exception do
    begin
      Result := false;
      Retorno := E.Message;
    end;
  end;

end;

end.
