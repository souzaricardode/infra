program GUIBuilderDemo;

uses
  FastMM4,
  ApplicationContext,
  Forms,
  SysUtils,
  InfraGUIBuilder,
  InfraGUIBuilderIntf,
  GUIAnnotation,
  GUIAnnotationIntf,
  InfraCommonIntf,
  InfraValueTypeIntf,
  InfraValueType,
  LayoutManager,
  ExtCtrls,
  Model in 'Model.pas',
  ModelIntf in 'ModelIntf.pas',
  StdCtrls,
  cxCalendar, cxTextEdit;

var
  lPerson: IPerson;
  lPerson2: IPerson;
  lPersonInfo: IClassInfo;
  lGUIPersonSimple: IScreen;
  lGUIPerson: IScreen;
  lItem: IScreenControl;

{$R *.res}

begin
  Application.Initialize;
  Application.Run;



  //Data -----------------------------------------------------------------------
  lPerson := TPerson.Create;
  lPerson.ID.AsInteger := 1;
  lPerson.Name.AsString := 'Diogo Augusto Pereira';
  lPerson.Email.AsString := 'diogoap82@gmail.com';
  lPerson.Address.AsString := 'Rua Alfredo Wust, 838';
  lPerson.City.Name.AsString := 'Rolante';
  lPerson.City.Population.AsInteger := 18500;
  lPerson.State.AsString := 'RS';
  lPerson.Country.AsString := 'Brasil';
  lPerson.Birthday.AsDateTime := 30280;
  lPerson.Active.AsBoolean := True;
  lPerson.Amount.AsDouble := 10000;
  lPerson.Details.AsString := 'Observa��es linha 1' + #13 +
    'Observa��es linha 2' + #13 + 'Observa��es linha 3';



  //Simples --------------------------------------------------------------------
  lPersonInfo := TypeService.GetType(IPerson);
  lGUIPersonSimple := (lPersonInfo.Annotate(IScreens) as IScreens).
    AddScreen('PersonSimple');
  lGUIPersonSimple.Title.AsString := 'Cadastro de pessoas - Dados b�sicos';
  lGUIPersonSimple.CaptionPosition := lpAbove;
  lGUIPersonSimple.ShowProperties.Add('ID');
  lGUIPersonSimple.ShowProperties.Add('Name');
  lGUIPersonSimple.ShowProperties.Add('Email');
  lGUIPersonSimple.ShowProperties.Add('Birthday');

  lItem := lGUIPersonSimple.AddControl('ID');
  lItem.Caption.AsString := 'C�digo';
  lItem.Width.AsInteger := 50;

  lItem := lGUIPersonSimple.AddControl('Name');
  lItem.Caption.AsString := 'Nome';
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPersonSimple.AddControl('Email');
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPersonSimple.AddControl('Birthday');
  lItem.Caption.AsString := 'Data de nascimento';
  lItem.ControlClass := TcxDateEdit;



  //Completa -------------------------------------------------------------------
  lPersonInfo := TypeService.GetType(IPerson);
  lGUIPerson := (lPersonInfo.Annotate(IScreens) as IScreens).AddScreen('Person');
  lGUIPerson.Title.AsString := 'Cadastro de pessoas';

  lItem := lGUIPerson.AddControl('ID');
  lItem.Caption.AsString := 'C�digo';
  lItem.Width.AsInteger := 50;

  lItem := lGUIPerson.AddControl('Name');
  lItem.Caption.AsString := 'Nome';
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPerson.AddControl('Email');
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPerson.AddControl('Address');
  lItem.Caption.AsString := 'Endere�o';
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPerson.AddControl('State');
  lItem.Caption.AsString := 'Estado';
  lItem.Width.AsInteger := 50;

  lGUIPerson.AddControl('Country').Caption.AsString := 'Pa�s';
  lGUIPerson.AddControl('Amount').Caption.AsString := 'Saldo';

  lItem := lGUIPerson.AddControl('Active');
  lItem.Caption.AsString := 'Ativo';
  lItem.Width.AsInteger := 65;

  lItem := lGUIPerson.AddControl('Birthday');
  lItem.Caption.AsString := 'Data de nascimento';
  lItem.ControlClass := TcxDateEdit;

  lItem := lGUIPerson.AddControl('Details');
  lItem.Caption.AsString := 'Observa��es';
  lItem.ControlClass := TMemo;
  lItem.ItemHeightMeasureType := mtPercent;
  lItem.ItemHeight.AsInteger := 35;
  lItem.ItemWidthMeasureType := mtPercent;
  lItem.ItemWidth.AsInteger := 100;

  lItem := lGUIPerson.AddControl('City.Name');
  lItem.Caption.AsString := 'Cidade - Nome';
  lItem.Width.AsInteger := 200;
  lItem.ControlClass := TComboBox;
  lItem.PutAfter := 'Address';





  //Build ----------------------------------------------------------------------
  //GUIService.RegisterGUIMapping(TcxTextEdit, IInfraString, 'Text');
  //GUIService.Build(lPerson, lGUIPersonSimple);
  GUIService.Build(lPerson, lGUIPerson);
  //GUIService.Build(lPerson);
end.