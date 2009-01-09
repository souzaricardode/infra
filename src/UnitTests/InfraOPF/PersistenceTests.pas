unit PersistenceTests;

interface

uses
  InfraOPFIntf,
  ZDbcInterbase6,
  ZDbcIntfs,
  TestFramework,
  PersistenceModelIntf;

type
  TPersistenceTests = class(TTestCase)
  private
    procedure PreparaBancoParaCarga;
    procedure PreparaBancoParaDeletar;
    procedure PreparaBancoParaInserir;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLoadWithObject;
    procedure TestLoadWithParams;
    procedure TestSaveInsertWithObject;
    procedure TestDeleteWithObject;
  end;

implementation

uses
  Dialogs,
  SysUtils,
  Forms,
  Math,
  Classes,
  InfraValueType,
  InfraValueTypeIntf,
  PersistenceModel,
  InfraPersistence,
  InfraOPFConsts,
  InfraTestsUtil;

{ TPersistenceTests }

procedure TPersistenceTests.SetUp;
begin
  inherited;
  // Aqui � definido no Configuration algumas propriedades, para que o
  // InfraPersistence saiba algumas coisas necess�rias para configurar o
  // connection e outras coisas internas. Caso haja propriedades especificas
  // que precisam ser definidas, podem ser naturalmente colocados ai tambem
  // que o tipo de Connection espec�fico poderar ler sem problema.
  with PersistenceService.Configuration do
  begin
    SetValue(cCONFIGKEY_DRIVER, 'firebird-2.0');
    SetValue(cCONFIGKEY_USERNAME, 'SYSDBA');
    SetValue(cCONFIGKEY_PASSWORD, 'masterkey');
    SetValue(cCONFIGKEY_HOSTNAME, 'localhost');
    SetValue(cCONFIGKEY_DATABASENAME,
      ExtractFilePath(Application.ExeName) + 'data\dbdemos.fdb');
    SetValue(cCONFIGKEY_TEMPLATETYPE, 'TemplateReader_IO');
    SetValue(cCONFIGKEY_TEMPLATEPATH,
      ExtractFilePath(Application.ExeName) + 'Data');
  end;
  // Prepara o DBUnit para deixar o banco no estado adequado antes de testar.
  GetZeosExecutor.OpenConnection('zdbc:firebird-2.0://localhost/' +
    ExtractFilePath(Application.ExeName) + 'data\dbdemos.fdb' +
    '?username=SYSDBA;password=masterkey');
end;

procedure TPersistenceTests.PreparaBancoParaCarga;
begin
  GetZeosExecutor.Execute('DELETE FROM ACCOUNT');
  GetZeosExecutor.Execute(
    'INSERT INTO ACCOUNT (ID, ACCOUNTNUMBER, ACCOUNTNAME, '+
    'INITIALBALANCE, CURRENTBALANCE) VALUES (1, ''1361-2'', ''BB 1361'', '+
    '125.3, 1524.25)');
end;

procedure TPersistenceTests.PreparaBancoParaInserir;
begin
  GetZeosExecutor.Execute('DELETE FROM ACCOUNT');
end;

procedure TPersistenceTests.PreparaBancoParaDeletar;
begin
  GetZeosExecutor.Execute('DELETE FROM ACCOUNT');
  GetZeosExecutor.Execute(
    'INSERT INTO ACCOUNT (ID, ACCOUNTNUMBER, ACCOUNTNAME, '+
    'INITIALBALANCE, CURRENTBALANCE) VALUES (3, ''1111-3'', ''CEF 1111'', '+
    'NULL, NULL)');
end;

procedure TPersistenceTests.TestLoadWithObject;
var
  vSession: ISession;
  vObj: IAccount;
  vSQLCommand: ISQLCommandQuery;
begin
  PreparaBancoParaCarga;
  // abre uma nova sess�o e cria um objeto preenchendo apenas as propriedades
  // que ir�o servir de par�metro para a busca
  vSession := PersistenceService.OpenSession;
  vObj := TAccount.Create;
  vObj.Id.AsInteger := 1;
  // *** verificar estado do objeto
  // Prepara a carga, definindo o objeto como par�metro
  vSQLCommand := vSession.CreateQuery('LoadAccountbyId', vObj);
  // Executa a carga do objeto
  vObj := vSQLCommand.GetResult as IAccount;

  CheckNotNull(vObj, 'Objecto n�o foi carregado');
  CheckEquals('BB 1361', vObj.Name.AsString, 'Nome conta incompat�vel');
  CheckEquals('1361-2', vObj.AccountNumber.AsString, 'N�mero da conta incompat�vel');
  CheckTrue(SameValue(125.3, vObj.InitialBalance.AsDouble), 'Saldo inicial incompat�vel');
  CheckTrue(SameValue(1524.25, vObj.CurrentBalance.AsDouble), 'Saldo atual incompat�vel');
  // *** verificar estado do objeto
end;

procedure TPersistenceTests.TestLoadWithParams;
var
  vSession: ISession;
  vObj: IAccount;
  vSQLCommand: ISQLCommandQuery;
begin
  PreparaBancoParaCarga;
  // Abre a sessao e define o parametro e o tipo de classe a ser carregada.
  vSession := PersistenceService.OpenSession;
  vSQLCommand := vSession.CreateQuery('LoadAccountbyId');
  vSQLCommand.ClassID := IAccount;
  vSQLCommand.Params['Id'] := TInfraInteger.NewFrom(1);
  // Executa a carga do objeto
  vObj := vSQLCommand.GetResult as IAccount;

  CheckNotNull(vObj, 'Objecto n�o foi carregado');
  CheckEquals('BB 1361', vObj.Name.AsString, 'Nome conta incompat�vel');
  CheckEquals('1361-2', vObj.AccountNumber.AsString, 'N�mero da conta incompat�vel');
  CheckTrue(SameValue(125.3, vObj.InitialBalance.AsDouble), 'Saldo inicial incompat�vel');
  CheckTrue(SameValue(1524.25, vObj.CurrentBalance.AsDouble), 'Saldo atual incompat�vel');
  // *** verificar estado do objeto
end;

procedure TPersistenceTests.TestSaveInsertWithObject;
var
  vSession: ISession;
  vObj: IAccount;
  vCont: integer;
  vSQLCommand :ISQLCommandQuery;
begin
  PreparaBancoParaInserir;
  vSession := PersistenceService.OpenSession;
  vObj := TAccount.Create;
  vObj.Id.AsInteger := 2;
  vObj.AccountNumber.AsString := '2812-3';
  vObj.InitialBalance.AsDouble := 789.3;
  vObj.CurrentBalance.AsDouble := 222.25;
  // *** Deveria testar aqui o estado do objeto deveria estar Clear e not Persistent
  vSession.Save('InsertAccount', vObj);
  vCont := vSession.Flush;
  // *** Deveria testar aqui o estado do objeto deveria estar Clear e Persistent
  CheckEquals(1, vCont, 'Quantidade de registros afetados inv�lida');

  vSQLCommand := vSession.CreateQuery('LoadAccountbyId', vObj);
  vObj := vSQLCommand.GetResult as IAccount;

  CheckEquals('2812-3', vObj.AccountNumber.AsString, 'N�mero da conta incompat�vel');
  CheckTrue(SameValue(789.3, vObj.InitialBalance.AsDouble), 'Saldo inicial incompat�vel');
  CheckTrue(SameValue(222.25, vObj.CurrentBalance.AsDouble), 'Saldo atual incompat�vel');
end;

procedure TPersistenceTests.TestDeleteWithObject;
var
  vSession: ISession;
  vObj: IAccount;
  vCont :integer;
begin
  PreparaBancoParaDeletar;

  // Abre a sessao, cria um objeto e define o id a ser deletado
  vSession := PersistenceService.OpenSession;
  vObj := TAccount.Create;
  vObj.Id.AsInteger := 3;
  vSession.Delete('DeleteAccountByID', vObj);
  vCont := vSession.Flush;

  // *** Deveria testar aqui o estado do objeto deveria estar Deleted e Persistent
  // *** pegar um resultset e verificar se o dado foi realmente apagado
  CheckEquals(1, vCont, 'Quantidade de registros afetados inv�lida');
end;

procedure TPersistenceTests.TearDown;
begin
  inherited;
  ReleaseZeosExecutor;
end;

initialization
  TestFramework.RegisterTest('Persistence Testes Caixa-Preta',
    TPersistenceTests.Suite);

end.
