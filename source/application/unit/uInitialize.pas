unit uInitialize;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Forms, DateTimePicker,
  cm_classes, cm_interfaces, cm_TypeUtils, cm_InterfaceLoader, cm_DOM, cm_XML, cm_dialogs, cm_logutils,
  cm_messager, cm_SimpleMessage,
  cm_parameter, cm_ParameterUtils,
  cm_theme, cm_ThemeUtils,
  cm_plat, cm_PlatInitialize, cm_LCLUtils,
  uSystem, uSystemBase, uFormLoading;

type

  { TPOSInitialize }

  TPOSInitialize = class(TAppSystemBase, IAppSystem)
  private
    FLogger: TCMJointFileLogger;
    FMessageHandler: ICMMessageHandler;
    FParameter: ICMParameter;
    FMsgBar: ICMMsgBar;
    FMsgBox: TCMMsgBox;
    FWorkRectControl, FServiceRectControl: TControl;
    //
    FParameterLoader: ICMParameterLoader;
    FThemeUtil: TCMThemeUtil;
    FExceptMsgBox: TCMMsgBox;
    procedure HandleExceptionEvent(Sender: TObject; E: Exception);
    procedure AppKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LibLoading(Sender: TObject; const TheFileName: string);
  public
    constructor Create;
    property MessageHandler: ICMMessageHandler read FMessageHandler;
    property MsgBar: ICMMsgBar write FMsgBar;
    property WorkRectControl: TControl write FWorkRectControl;
    property ServiceRectControl: TControl write FServiceRectControl;
    procedure StartRecordKeyDown;
    procedure NotifySystem(const AEventName: string);
  public
    function InitHeadmost: Boolean;
    function InitParameter: Boolean;
    function InitLCLOperate: Boolean;
    function InitTheme: Boolean;
    function InitDBMessageHandler: Boolean;
    function InitAWT: Boolean;
  public //IAppSystem
    function GetParameter: ICMParameter; override;
    function GetMsgBar: ICMMsgBar; override;
    function GetMsgBox: ICMMsgBox; override;
    function GetLog: ICMLog; override;
    function GetWorkRect: TRect; override;
    function GetServiceRect: TRect; override;
  public
    procedure Init;
    procedure Start;
  end;

var
  POSInitialize: TPOSInitialize;

implementation

uses
  LazFileUtils, TypInfo, cm_controlutils, uDialogs, uConstant, uVersion, uSystemUtils,
  cm_AWT, cm_AWTProxy, cm_AWTProxyToolkit;

function MessageBoxFunc(Text, Caption :PChar; Flags: Longint): Integer;
begin
  //TODO 同步问题
  if POSInitialize.FMsgBox.Visible then
    POSInitialize.FMsgBox.Close;
  Result := AppSystem.GetMsgBox.MessageBox(Text, Caption, Flags)
end;

{ TPOSInitialize }

constructor TPOSInitialize.Create;
begin
  inherited Create;
  //1、日志
  FLogger := TCMJointFileLogger.Create(Application);
  FLogger.FilePath := LogPath;
  FLogger.FileNamePrefix := LogFileNamePrefix;
  FLogger.Info('=================================================================================');
  FLogger.Info(Format('--- [%s] [%s] ---', [ParamStr(0), VersionStr]));
  //2、默认信息处理
  FMessageHandler := TCMLogMessageHandler.Create(FLogger);
  cm_PlatInitialize.InitPlat(FMessageHandler);
  DefaultMessagerName := 'MPOS';
  //3、初始值
  FParameterLoader := nil;
  FExceptMsgBox := nil;
  FMsgBar := nil;
  FWorkRectControl := nil;
  FServiceRectControl := nil;

  //------------------------------------------------------------------------------------------------
  //以下是其他构建所需的一些依赖
  //------------------------------------------------------------------------------------------------

  //1、主窗体紧接之后创建，需要IThemeable；IThemeable 需要集合 IThemeableSet。
  FThemeUtil := TCMThemeUtil.Create;
  GetThemeableManager.AddThemeableSet(FThemeUtil);
  //2、AppSystem
  InterfaceRegister.PutInterface('IAppSystem', IAppSystem, Self);
end;

function TPOSInitialize.InitHeadmost: Boolean;
begin
  Result := False;
  Messager.Info('开始初始化基础工具...');
  //这时初始化因为要设置主题
  FMsgBox := TPOSMsgBox.Create(Application);
  Result := True;
  DefaultMsgBox := FMsgBox;
  InterfaceRegister.PutInterface('ICMMsgBox', ICMMsgBox, DefaultMsgBox, DefaultMsgBoxCode);
end;

function TPOSInitialize.InitParameter: Boolean;
var
  ns: TCMDOMNodeStreamer;
  node: TCMDOMNode;
  i: Integer;
  xmlConfigParameter: ICMParameter;
  fn: string;
  paramObj: TCMParameter;
  p: ICMParameter;
begin
  Result := False;
  Messager.Info('开始初始化参数工具...');
  paramObj := TCMParameter.Create(nil, 'root', '');
  FParameter := paramObj;
  FParameterLoader := paramObj.ParameterSet as ICMParameterLoader;
  InterfaceRegister.PutInterface('ICMParameterLoader', ICMParameterLoader, FParameterLoader);
  //
  ns := TCMDOMNodeStreamer.Create(nil);
  try
    Messager.Info('开始加载默认配置参数...');
    if not FileExistsUTF8(DefaultConfigFileName) then
      begin
        AppSystem.GetMsgBox.ShowMessage('默认配置文件:' + DefaultConfigFileName + '不存在.');
        Exit;
      end;
    if ns.ReadXML(node, DefaultConfigFileName) then
      begin
        FParameterLoader.LoadParameters(paramObj, node);
        node.Free;
      end;
    Messager.Info('开始加载配置的XML文件参数...');
    xmlConfigParameter := FParameter.Get(XMLConfigParameterName);
    if not xmlConfigParameter.IsNull then
      begin
        for i:=0 to xmlConfigParameter.ItemCount-1 do
          begin
            p := xmlConfigParameter.GetItem(i);
            fn := p.AsString;
            if not FileExistsUTF8(fn) then
              begin
                Messager.Error('配置文件:%s不存在.', [fn]);
                Continue;
              end;
            if ns.ReadXML(node, fn) then
              begin
                Messager.Debug('开始加载XML文件:%s...', [fn]);
                try
                  FParameterLoader.LoadParameters(paramObj, node);
                except
                  on e: Exception do
                    GetMsgBox.ShowMessage(Format('加载XML文件:%s出错！'#10'%s %s', [fn, e.ClassName, e.Message]));
                end;
                node.Free;
              end;
          end;
        Messager.Info('结束加载配置的XML文件参数.');
      end;
  finally
    ns.Free;
  end;
  Result := True;
end;

function TPOSInitialize.InitLCLOperate: Boolean;
var
  manager: TCMLCLGlobalManager;
  generator: TCMObjectGenerator;
begin
  Result := False;
  //
  //Messager.Info('开始初始化LCL套件...');
  //cm_PlatInitialize.InitLCLSuite;
  //
  manager := cm_PlatInitialize.GetLCLGlobalManager;
  Messager.Debug('设置主LCL消息盒...');
  manager.GetMainLCLGlobalSet.SetMessageBoxFunction(@MessageBoxFunc);
  Messager.Debug('设置主错误处理事件...');
  manager.ApplicationExceptionEvent := @HandleExceptionEvent;
  //
  Messager.Info('开始注册组件:TDateTimePicker...');
  generator := cm_PlatInitialize.GetObjectGenerator;
  generator.RegisterClass('TDateTimePicker', TDateTimePicker);
  //
  Result := True;
end;

function TPOSInitialize.InitTheme: Boolean;
var
  i: Integer;
  themeName, themeTitle: string;
  theme: TCMTheme;
  themesParameter, themeParam: ICMParameter;
begin
  Result := False;
  Messager.Info('开始初始化主题工具...');
  themesParameter := AppSystem.GetParameter.Get('themes');
  if themesParameter.IsNull then
    begin
      Messager.Error('主题配置参数加载失败.');
      Exit;
    end;
  //寄存主题控制器
  InterfaceRegister.PutInterface(IThemeableSet, IThemeableSet(FThemeUtil));
  InterfaceRegister.PutInterface(IThemeController, IThemeController(FThemeUtil));
  //
  for i:=0 to themesParameter.ItemCount-1 do
    begin
      themeParam := themesParameter.GetItem(i);
      if themeParam.Name = 'theme' then
        begin
          themeName := themeParam.Get('name').AsString;
          themeTitle := themeParam.Get('title').AsString;
          //构建主题
          theme := TCMTheme.Create(themeName, themeTitle, themeParam);
          //加入控制器
          FThemeUtil.AddTheme(theme);
        end;
    end;
  LoadingForm.SetLoadMsg('开始设置默认主题...');
  FThemeUtil.SetFirstTheme;
  Result := True;
end;

function TPOSInitialize.InitDBMessageHandler: Boolean;
begin
  Result := InterfaceRegister.PutInterface('数据库信息处理器', ICMMessageHandler, TCMLogMessageHandler.Create(FLogger), DBMessageHandlerCode) >= 0;
end;

function TPOSInitialize.InitAWT: Boolean;
begin
  Result := False;
  TAWTManager.DefaultToolkit := TProxyToolkit.Create;
  Result := InterfaceRegister.PutInterface('IAToolkit', IAToolkit, TAWTManager.DefaultToolkit, DefaultToolkitCode) >= 0;
end;

//private
procedure TPOSInitialize.HandleExceptionEvent(Sender: TObject; E: Exception);
var
  es: string;
begin
  if not Assigned(FExceptMsgBox) then
    FExceptMsgBox := TPOSMsgBox.Create(Application);
  if FExceptMsgBox.Visible then
    FExceptMsgBox.Close;
  es := '系统错误:' + E.ClassName + #10#10'错误信息:' + E.Message;
  Messager.Error('FExceptMsgBox行将显示:' + es);
  FExceptMsgBox.ShowMessage(es);
end;

procedure TPOSInitialize.AppKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ds: string;
  cri: IInterfaceComponentReference;
begin
  ds := 'KeyDown:';
  if Assigned(Sender) then
    begin
      if Supports(Sender, IInterfaceComponentReference, cri) then
        begin
          ds := ds + cri.GetComponent.Name;
        end;
      ds := ds + '[' + Sender.UnitName + '.' + Sender.ClassName + ']';
    end;
  Messager.Debug('%s:%s', [ds, GetKeyCodeText(Key)]);
end;

procedure TPOSInitialize.LibLoading(Sender: TObject; const TheFileName: string);
begin
  LoadingForm.SetLoadMsg(Format('开始加载 %s ...', [TheFileName]));
end;

//仅 Widdows 有效
procedure TPOSInitialize.StartRecordKeyDown;
begin
  Messager.Info('开始记录按键信息...');
  Application.AddOnKeyDownHandler(@AppKeyDown);
end;

procedure TPOSInitialize.NotifySystem(const AEventName: string);
var
  i: Integer;
  sl: ISystemListener;
  se: ISystemEvent;
begin
  Messager.Debug('NotifySystem(%s)...', [AEventName]);
  for i:=0 to FSystemListenerList.Count-1 do
    begin
      Messager.Debug('NotifySystem() 执行 FSystemListenerList[%d]', [i]);
      sl := FSystemListenerList[i];
      se := TSystemEvent.Create(Self, Self);
      case AEventName of
      'Loaded': sl.Loaded(se);
      'Prepared': sl.Prepared(se);
      'Logined': sl.Logined(se);
      'Logoutting': sl.Logoutting(se);
      'Closing': sl.Closing(se);
      end;
    end;
  //
  case AEventName of
  'Loaded':
     begin
       for i:=0 to FLoadedExecuteList.Count-1 do
         begin
           Messager.Debug('NotifySystem() 执行 FLoadedExecuteList[%d]', [i]);
           FLoadedExecuteList[i].Run;
         end;
       FLoadedExecuteList.Clear;
     end;
  'Prepared':
     begin
       for i:=0 to FPreparedExecuteList.Count-1 do
         begin
           Messager.Debug('NotifySystem() 执行 PreparedExecuteList[%d]', [i]);
           FPreparedExecuteList[i].Run;
         end;
       FPreparedExecuteList.Clear;
     end;
  'Logined':
     begin
       for i:=0 to FLoginedExecuteList.Count-1 do
         begin
           Messager.Debug('NotifySystem() 执行 FLoginedExecuteList[%d]', [i]);
           FLoginedExecuteList[i].Run;
         end;
       FLoginedExecuteList.Clear;
     end;
  end;
end;

//---- 以下接口实现 --------------------------------------------------------------------------------

function TPOSInitialize.GetParameter: ICMParameter;
begin
  Result := FParameter;
end;

function TPOSInitialize.GetMsgBar: ICMMsgBar;
begin
  Result := FMsgBar;
end;

function TPOSInitialize.GetMsgBox: ICMMsgBox;
begin
  Result := FMsgBox;
end;

function TPOSInitialize.GetLog: ICMLog;
begin
  Result := FLogger;
end;

function TPOSInitialize.GetWorkRect: TRect;
begin
  if Assigned(FWorkRectControl) then
    Result := FWorkRectControl.BoundsRect
  else
    Result := Screen.DesktopRect;
end;

function TPOSInitialize.GetServiceRect: TRect;
begin
  if Assigned(FServiceRectControl) then
    Result := FServiceRectControl.BoundsRect
  else
    Result := Screen.DesktopRect;
end;

procedure TPOSInitialize.Init;
begin
  Messager.Debug('创建加载画面...');
  LoadingForm := TLoadingForm.Create(Application);
  LoadingForm.Show;
  LoadingForm.SetLoadMsg('系统开始启动...', 2);
end;

//在创建 main form 之后
procedure TPOSInitialize.Start;
var
  icoFileName: string;
  loader: ICMInterfaceLoader;
  mLevelStr: string;
  mLevel: TEventTypeLevel;
begin
  LoadingForm.SetLoadMsg('开始初始化基础工具...', 3);
  InitHeadmost;
  LoadingForm.SetLoadMsg('开始初始化参数相关操作...');
  InitParameter;
  //
  LoadingForm.SetLoadMsg('开始加载应用图标...');
  icoFileName := AppSystem.GetParameter.Get(IcoParameterName).AsString;
  if FileExists(icoFileName) then
    Application.Icon.LoadFromFile(icoFileName)
  else
    Messager.Error('%s 文件:%s 不存在.', [IcoParameterName, icoFileName]);
  //
  LoadingForm.SetLoadMsg('开始设置默认信息等级...');
  mLevelStr := AppSystem.GetParameter.Get(MessageLevelParameterName).AsString;
  if mLevelStr <> '' then
    begin
      Messager.Info('设置默认信息等级为：%s', [mLevelStr]);
      mLevel := TEventTypeLevel(GetEnumValue(TypeInfo(TEventTypeLevel), mLevelStr));
      TCMMessageManager.DefaultHandler.SetLevel(mLevel);
    end;
  //
  LoadingForm.SetLoadMsg('开始初始化 LCL 组件库相关操作工具...');
  InitLCLOperate;
  //
  LoadingForm.SetLoadMsg('开始初始化主题工具...');
  InitTheme;
  //
  LoadingForm.SetLoadMsg('开始数据库信息处理器...');
  InitDBMessageHandler;
  //
  {$IFDEF Windows}
  LoadingForm.SetLoadMsg('开始启用记录按键...');
  StartRecordKeyDown;
  {$ENDIF}
  //
  LoadingForm.SetLoadMsg('开始初始化抽象窗口工具...');
  InitAWT;

  //---- 以下加载 ----------------------------------------------------------------------------------
  LoadingForm.SetLoadMsg('开始加载支撑模块...', 40);
  loader := nil;
  cm_PlatInitialize.GetInterfaceLoader.OnLoading := @LibLoading;
  if InterfaceRegister.OutInterface(ICMInterfaceLoader, loader) then
    loader.LoadByConfig(LibrariesConfigFileName);
  //
  LoadingForm.SetLoadMsg('开始加载业务模块...', 60);
  if Assigned(loader) then
    loader.LoadDirAll(ModulesPath);
  //
  LoadingForm.SetLoadMsg('开始加载完成后工作...', 90);
  Self.NotifySystem('Loaded');
  LoadingForm.SetLoadMsg('准备显示主操作界面...', 100);
  LoadingForm.Close;
end;


initialization
  POSInitialize := TPOSInitialize.Create;


end.

