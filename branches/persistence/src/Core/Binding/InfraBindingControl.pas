unit InfraBindingControl;

interface

uses
  Controls,
  TypInfo,
  InfraCommon,
  Messages,
  InfraBindingIntf,
  InfraBindingType,
  InfraValueTypeIntf;

type
  TPropertyAccessMode = (paRTTI, paCustom);

  TBindableVCLPropertyClass = class of TBindableVCLProperty;

  // classe base para bindables de propriedades da vcl
  TBindableVCLProperty = class(TBindable, IBindableVCLProperty)
  private
    FControl: TControl;
    FOldWndProc: TWndMethod;
  protected
    procedure WndProc(var Message: TMessage); virtual;
    function GetControl: TControl;
    property Control: TControl read GetControl;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; virtual; abstract;
    constructor Create(pControl: TControl); reintroduce;
    destructor Destroy; override;
  end;

  // classe base para bindables de propriedades da vcl
  TBindableRTTIBased = class(TBindableVCLProperty)
  private
    FPropInfo: PPropInfo;
  protected
    function GetValue: IInfraType; override;
    procedure SetValue(const Value: IInfraType); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
    constructor Create(pControl: TControl; pPropInfo: PPropInfo); reintroduce;
  end;

  TBindableRTTIBasedTwoWay = class(TBindableRTTIBased)
  protected
    function Support2Way: Boolean; override;
  end;

  TBindableCaption = class(TBindableRTTIBased)
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

  TBindableText = class(TBindableRTTIBasedTwoWay)
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

  TBindableVisible = class(TBindableRTTIBasedTwoWay)
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

  TBindableEnabled = class(TBindableRTTIBasedTwoWay)
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

  TBindableChecked = class(TBindableRTTIBasedTwoWay)
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

  TBindableColor = class(TBindableRTTIBasedTwoWay)
  protected
    procedure WndProc(var Message: TMessage); override;
    function GetValue: IInfraType; override;
    procedure SetValue(const Value: IInfraType); override;
  public
    class function CreateIfSupports(pControl: TControl;
      const pPropertyPath: string): IBindableVCLProperty; override;
  end;

procedure RegisterBindableClass(pBindableClass: TBindableVCLPropertyClass);
function GetBindableVCL(pControl: TControl;
  const pPropertyPath: string): IBindable;

implementation

uses
  Classes,
  SysUtils,
  StdCtrls,
  Graphics,
  InfraValueType,
  InfraCommonIntf,
  InfraBindingConsts,
  InfraBindingManager,
  InfraBindingService;

var
  _BindableClasses: TList;

procedure RegisterBindableClass(pBindableClass: TBindableVCLPropertyClass);
begin
  if not Assigned(_BindableClasses) then
    _BindableClasses := TList.Create;
  _BindableClasses.Add(pBindableClass);
end;

function GetBindableVCL(pControl: TControl;
  const pPropertyPath: string): IBindable;
var
  vI: Integer;
begin
  for vI := 0 to _BindableClasses.Count - 1 do
  begin
    Result := TBindableVCLPropertyClass(_BindableClasses[vI]).CreateIfSupports(pControl, pPropertyPath) as IBindable;
    if Assigned(Result) then
      Break;
  end;
  if not Assigned(Result) then
    raise EInfraBindingError.CreateFmt(cErrorBindableNotDefined,
      [pControl.ClassName, pPropertyPath]);
end;

{ TBindableVCLProperty }

constructor TBindableVCLProperty.Create(pControl: TControl);
begin
  inherited Create;
  FControl := pControl;
  FOldWndProc := FControl.WindowProc;
  FControl.WindowProc := WndProc;
end;

destructor TBindableVCLProperty.Destroy;
begin
  FControl.WindowProc := FOldWndProc;
  inherited;
end;

function TBindableVCLProperty.GetControl: TControl;
begin
  Result := FControl;
end;

procedure TBindableVCLProperty.WndProc(var Message: TMessage);
begin
  FOldWndProc(Message);
end;

{ TBindableRTTIBased }

class function TBindableRTTIBased.CreateIfSupports(
  pControl: TControl; const pPropertyPath: string): IBindableVCLProperty;
var
  vPropInfo: PPropInfo;
begin
  vPropInfo := GetPropInfo(pControl, pPropertyPath);
  if Assigned(vPropInfo) then
    Result := Self.Create(pControl, vPropInfo)
  else
    Result := nil;
end;

constructor TBindableRTTIBased.Create(pControl: TControl;
  pPropInfo: PPropInfo);
begin
  inherited Create(pControl);
  FPropInfo := pPropInfo;
end;

function TBindableRTTIBased.GetValue: IInfraType;
begin
  case FPropInfo^.PropType^.Kind of
    tkLString, tkString:
      Result := TInfraString.NewFrom(GetStrProp(FControl, FPropInfo));
    tkEnumeration:
      if GetTypeData(FPropInfo^.PropType^)^.BaseType^ = System.TypeInfo(Boolean) then
        Result := TInfraBoolean.NewFrom(Boolean(GetOrdProp(FControl, FPropInfo)))
      else
        Result := TInfraInteger.NewFrom(GetOrdProp(FControl, FPropInfo));
  end;
end;

procedure TBindableRTTIBased.SetValue(const Value: IInfraType);
begin
  case FPropInfo^.PropType^.Kind of
    tkLString, tkString:
      SetStrProp(FControl, FPropInfo, (Value as IInfraString).AsString);
    tkEnumeration:
      if Supports(Value, IInfraBoolean) then
        SetOrdProp(FControl, FPropInfo,
          Abs(Trunc(Integer((Value as IInfraBoolean).AsBoolean))))
      else
        SetOrdProp(FControl, FPropInfo,
          Trunc((Value as IInfraInteger).AsInteger));
  end;
end;

{ TBindableRTTIBasedTwoWay }

function TBindableRTTIBasedTwoWay.Support2Way: Boolean;
begin
  Result := True;
end;

{ TBindableText }

class function TBindableText.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if (pControl is TCustomEdit) and AnsiSameText(pPropertyPath, 'Text') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

procedure TBindableText.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if Message.Msg in [WM_KILLFOCUS, WM_SETTEXT] then
    Changed;
end;

{ TBindableCaption }

class function TBindableCaption.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if AnsiSameText(pPropertyPath, 'Caption') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

{ TBindableVisible }

class function TBindableVisible.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if AnsiSameText(pPropertyPath, 'Visible') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

procedure TBindableVisible.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if Message.Msg = CM_VISIBLECHANGED then
    Changed;
end;

{ TBindableEnabled }

class function TBindableEnabled.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if AnsiSameText(pPropertyPath, 'Enabled') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

procedure TBindableEnabled.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if Message.Msg = CM_ENABLEDCHANGED then
    Changed;
end;

{ TBindableChecked }

class function TBindableChecked.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if AnsiSameText(pPropertyPath, 'Checked') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

procedure TBindableChecked.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if Message.Msg = BM_SETCHECK then
    Changed;
end;

{ TBindableColor }

class function TBindableColor.CreateIfSupports(pControl: TControl;
  const pPropertyPath: string): IBindableVCLProperty;
begin
  if AnsiSameText(pPropertyPath, 'Color') then
    Result := inherited CreateIfSupports(pControl, pPropertyPath)
  else
    Result := nil;
end;

function TBindableColor.GetValue: IInfraType;
begin
  case FPropInfo^.PropType^.Kind of
    tkInteger:
      Result := TInfraString.NewFrom(ColorToString(GetOrdProp(FControl, FPropInfo)));
  end;
end;

procedure TBindableColor.SetValue(const Value: IInfraType);
begin
  case FPropInfo^.PropType^.Kind of
    tkInteger:
      SetOrdProp(FControl, FPropInfo,StringToColor((Value as IInfraString).asString));
  end;
end;

procedure TBindableColor.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if Message.Msg = CM_COLORCHANGED then
    Changed;
end;

procedure RegisterBindables;
begin
  RegisterBindableClass(TBindableText);
  RegisterBindableClass(TBindableVisible);
  RegisterBindableClass(TBindableEnabled);
  RegisterBindableClass(TBindableCaption);
  RegisterBindableClass(TBindableChecked);
  RegisterBindableClass(TBindableColor);
end;

initialization
  RegisterBindables;

finalization
  if Assigned(_BindableClasses) then
    FreeAndNil(_BindableClasses);

end.

