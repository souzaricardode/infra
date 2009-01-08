unit InfraPersistenceServiceTests;

interface

uses
  InfraPersistence,
  InfraPersistenceIntf,
  InfraCommonIntf,
  TestFrameWork;

type
  TInfraPersistenceServiceTests = class(TTestCase)
  private
    FPersistenceService: IInfraPersistenceService;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // Test methods
    procedure TestConfigurationIsNotNull;
    procedure TestConfiguration;
    procedure TestOpenSessionWithNoConfig;
    procedure TestOpenSession;
  end;

implementation

uses
  InfraConsts, InfraPersistenceConsts, InfraMocks, ZDbcIntfs;

procedure TInfraPersistenceServiceTests.SetUp;
begin
  inherited;
  FPersistenceService := TInfraPersistenceService.Create;
end;

procedure TInfraPersistenceServiceTests.TearDown;
begin
  // Se esta linha nao existir, acontece um AV no final da aplica��o
  FPersistenceService := nil;
  inherited;
end;

procedure TInfraPersistenceServiceTests.TestConfiguration;
var
  vInstancia1, vInstancia2: IConfiguration;
begin
  vInstancia1 := FPersistenceService.Configuration;
  vInstancia2 := FPersistenceService.Configuration;
  CheckTrue( vInstancia1 = vInstancia2, 'GetConfiguration retornou uma inst�ncia diferente de Configuration');
end;

procedure TInfraPersistenceServiceTests.TestConfigurationIsNotNull;
begin
  CheckNotNull(FPersistenceService.Configuration);
end;

procedure TInfraPersistenceServiceTests.TestOpenSessionWithNoConfig;
begin
  ExpectedException := EInfraError;
  FPersistenceService.OpenSession;
  ExpectedException := nil;
end;

procedure TInfraPersistenceServiceTests.TestOpenSession;
begin
  FPersistenceService.Configuration.SetValue(cCONFIGKEY_DRIVER, 'firebird');
  FPersistenceService.Configuration.SetValue(cCONFIGKEY_HOSTNAME, 'localhost');
  FPersistenceService.Configuration.SetValue(cCONFIGKEY_USERNAME, 'sysdba');
  FPersistenceService.Configuration.SetValue(cCONFIGKEY_PASSWORD, 'masterkey');
  FPersistenceService.OpenSession;
end;

initialization
  TestFramework.RegisterTest('Persistence Testes Caixa-Cinza',
    TInfraPersistenceServiceTests.Suite);
end.
 