unit uFormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLType, StdCtrls, ComCtrls,
  cm_theme, cm_Plat, cm_dialogs,
  uForm, uConmponents,
  uSale, uFrameSale,
  uFrameTest,
  uDAO, uSystem, uInitialize;

type

  { TMainForm }

  TMainForm = class(TPOSForm)
    PanelLeft: TPanel;
    PanelWork: TPanel;
    PanelTest: TPanel;
    PanelService: TPanel;
    PanelRightHint: TPanel;
    PanelRight: TPanel;
    PanelClient: TPanel;
    PanelBottom: TPanel;
    PanelTop: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure PanelRightHintDblClick(Sender: TObject);
  private
    FPOSTitlePanel: TPOSTitlePanel;
    FMsgBar: TCMMsgBar;
    FHasSet: Boolean;
    FSaleFrame: TSaleFrame;
    FTestFrame: TTestFrame;
  public
    procedure SetTheme(ATheme: ITheme); override;
  end;

var
  MainForm: TMainForm;

implementation

uses uConstant, uMain, uMainTool;

{$R *.frm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  mainBlock: IMainBlock;
begin
  FPOSTitlePanel := TPOSTitlePanel.Create(Self);
  FPOSTitlePanel.Parent := PanelTop;
  FPOSTitlePanel.Align := alTop;
  PanelTop.Height := FPOSTitlePanel.Height;
  FMsgBar := TCMMsgBar.Create(PanelBottom);
  FMsgBar.Align := alTop;
  FMsgBar.InherentHeight := 14;
  FMsgBar.Font.Size := 10;
  POSInitialize.MsgBar := FMsgBar;
  FHasSet := False;
  // 加入主区块
  mainBlock := TMainTool.Create(PanelTop, PanelLeft, PanelClient, PanelRight, PanelRightHint, PanelBottom);
  InterfaceRegister.PutInterface('IMainBlock', IMainBlock, mainBlock);
  //
  FSaleFrame := TSaleFrame.Create(Self);
  FSaleFrame.Parent := PanelClient;
  FSaleFrame.Align := alClient;
  InterfaceRegister.PutInterface('ISaleBoard', ISaleBoard, FSaleFrame);
  //
  FTestFrame := TTestFrame.Create(Self);
  FTestFrame.Parent := PanelTest;
  FTestFrame.Align := alClient;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  POSInitialize.NotifySystem('Closing');
end;

var
  _Prepared: Boolean = False;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  // TODO
  if not _Prepared then
    POSInitialize.NotifySystem('Prepared');
  _Prepared := True;

  if not AppSystem.IsLogined then
    POSInitialize.NotifySystem('Logined');
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FMsgBar.Visible := False;
  if Key = 27 then
    Close;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Self.Left := 0;
  Self.Top := 0;
  if Assigned(AppSystem) then
    begin
      if not FHasSet then
        begin
          FPOSTitlePanel.SetTitle('');
          FPOSTitlePanel.SetVersion('v' + AppSystem.GetVersion);
          FPOSTitlePanel.SetImage(AppSystem.GetParameter.Get(LogoParameterName).AsString);
          FHasSet := True;
        end;
      //
      if AppSystem.IsTestMode then
        begin
          PanelTest.Visible := True;
          PanelTest.Width := 280;
          Self.Width := 1024 + PanelTest.Width;
          Self.Height := 768;
        end;
      //
      POSInitialize.WorkRectControl := PanelWork;
      POSInitialize.ServiceRectControl := PanelService;
    end;
  //TODO 登陆
  //FNavigatorFrame.LoadConfig;
  PanelRightHint.Width := 12;
end;

procedure TMainForm.PanelRightHintDblClick(Sender: TObject);
begin
  if TPanel(Sender).Width < 200 then
    TPanel(Sender).Width := 200
  else
    TPanel(Sender).Width := 12;
end;

procedure TMainForm.SetTheme(ATheme: ITheme);
begin
  inherited SetTheme(ATheme);
  PanelClient.Color := ATheme.GetParameter.Get('panelColor').AsInteger;
  PanelRight.Color := PanelClient.Color;
  PanelBottom.Color := ATheme.GetParameter.Get('footer.color').AsInteger;
  if not ATheme.GetParameter.Get('mainForm').IsNull then
    PanelRight.Width := ATheme.GetParameter.Get('mainForm.rightWidth').AsInteger;
end;


end.

