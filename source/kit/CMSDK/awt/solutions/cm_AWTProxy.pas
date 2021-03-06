{
    This file is part of the CM SDK.
    Copyright (c) 2013-2018 by the ChenMeng studio

    cm_AWTProxy

    This is not a complete unit, for testing

    一种 AWT 的解决方案，通过简单代理的方式

    NOTE:
    20181119 add 鼠标事件、memo、datetimepicker

 **********************************************************************}

unit cm_AWTProxy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, Forms, Graphics,
  DateTimePicker, Grids,
  cm_interfaces, cm_messager, cm_dialogs, cm_classes,
  cm_AWT, cm_AWTEventBuilder;

type

  { TProxyPeer }

  TProxyPeer = class(TCMBase, IAPeer)
  private
    FIsSelfCreateDelegate: Boolean;
  protected
    FDelegateObj: TObject;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetDelegate: TObject;
  end;

  { TProxyFontPeer }

  TProxyFontPeer = class(TProxyPeer, IAFontPeer)
  public
    constructor Create;
    constructor Create(TheDelegate: TFont); overload;
    function GetDelegate: TFont;
  public
    function GetColor: TColor;
    function GetHeight: Integer;
    function GetName: string;
    function GetSize: Integer;
    procedure SetColor(AValue: TColor);
    procedure SetHeight(AValue: Integer);
    procedure SetName(AValue: string);
    procedure SetSize(AValue: Integer);
  end;

  { TProxyGraphicPeer }

  TProxyGraphicPeer = class abstract(TProxyPeer, IAGraphicPeer)
  public
    function GetDelegate: TGraphic;
  public
    function GetEmpty: Boolean;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(AValue: Integer);
    procedure SetWidth(AValue: Integer);
    procedure Clear;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(AStream: TStream);
  end;

  { TProxyRasterImagePeer }

  TProxyRasterImagePeer = class abstract(TProxyGraphicPeer, IARasterImagePeer)
  private
    FCanvas: TACanvas;
  public
    constructor Create;
    destructor Destroy; override;
    function GetDelegate: TRasterImage;
  public
    function GetCanvas: TACanvas;
    procedure FreeImage;
  end;

  { TProxyCustomBitmapPeer }

  TProxyCustomBitmapPeer = class(TProxyRasterImagePeer, IACustomBitmapPeer)
  public
    constructor Create(TheDelegate: TCustomBitmap);
    function GetDelegate: TCustomBitmap;
  public
    function GetMonochrome: Boolean;
    procedure SetMonochrome(AValue: Boolean);
    procedure SetSize(AWidth, AHeight: Integer);
  end;

  { TProxyBrushPeer }

  TProxyBrushPeer = class(TProxyPeer, IABrushPeer)
  private
    FCustomBitmap: TACustomBitmap;
  public
    constructor Create(TheDelegate: TBrush);
    destructor Destroy; override;
    function GetDelegate: TBrush;
  public
    function GetBitmap: TACustomBitmap;
    function GetColor: TColor;
    procedure SetBitmap(AValue: TACustomBitmap);
    procedure SetColor(AValue: TColor);
  end;

  { TProxyCanvasPeer }

  TProxyCanvasPeer = class(TProxyPeer, IACanvasPeer)
  private
    FBrush: TABrush;
    FFont: TAFont;
  public
    constructor Create;
    constructor Create(TheDelegate: TCanvas); overload;
    destructor Destroy; override;
    function GetDelegate: TCanvas;
  public
    function GetBrush: TABrush;
    function GetFont: TAFont;
    procedure SetBrush(AValue: TABrush);
    procedure SetFont(AValue: TAFont);
    procedure FillRect(X1,Y1,X2,Y2: Integer);
    procedure TextOut(X,Y: Integer; const Text: string);
  end;

  { TProxyControlBorderSpacingPeer }

  TProxyControlBorderSpacingPeer = class(TProxyPeer, IAControlBorderSpacingPeer)
  public
    constructor Create(OwnerControl: TControl);
    constructor Create(TheDelegate: TControlBorderSpacing); overload;
    function GetDelegate: TControlBorderSpacing;
  public
    function GetAround: Integer;
    function GetBottom: Integer;
    function GetLeft: Integer;
    function GetRight: Integer;
    function GetTop: Integer;
    procedure SetAround(AValue: Integer);
    procedure SetBottom(AValue: Integer);
    procedure SetLeft(AValue: Integer);
    procedure SetRight(AValue: Integer);
    procedure SetTop(AValue: Integer);
  end;

  { TProxyComponentPeer }

  TProxyComponentPeer = class(TProxyPeer, IAComponentPeer)
  protected
    FTargetObj: TAComponent;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); virtual;
    function GetDelegate: TComponent;
  public
    function GetName: TComponentName;
    procedure SetName(AValue: TComponentName);
    function GetTag: PtrInt;
    procedure SetTag(AValue: PtrInt);
  end;

  { TProxyControlPeer }

  TProxyControlPeer = class(TProxyComponentPeer, IAControlPeer)
  private
    FFont: TAFont;
    FBorderSpacing: TAControlBorderSpacing;
    FMouseListenerList: TMouseListenerList;
    FMark: string;
    class var FControlPeerList: TFPList;
  protected
    FControlListenerList: TCMInterfaceList; //同时用于子类扩展
    procedure ControlDblClickEvent(Sender: TObject); //Control 未公开，在公开的子类中使用。
    procedure RegisterControlEvents; virtual;
    procedure RegisterMouseEvents; virtual; //Control 未公开,需要子类操作
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TControl;
    procedure ControlClickEvent(Sender: TObject);
    procedure ControlResizeEvent(Sender: TObject);
    procedure MouseDownEvent(Sender: TObject; Button: Controls.TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseUpEvent(Sender: TObject; Button: Controls.TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseEnterEvent(Sender: TObject);
    procedure MouseLeaveEvent(Sender: TObject);
    procedure MouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseWheelEvent(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
    function GetAlign: TAlign;
    function GetAutoSize: Boolean;
    function GetBorderSpacing: TAControlBorderSpacing;
    function GetBoundsRect: TRect;
    function GetColor: TColor;
    function GetEnabled: Boolean;
    function GetFont: TAFont;
    function GetHeight: Integer;
    function GetHint: TCaption;
    function GetLeft: Integer;
    function GetMark: TCaption;
    function GetText: TCaption;
    function GetTop: Integer;
    function GetVisible: Boolean;
    function GetWidth: Integer;
    procedure SetAlign(AValue: TAlign);
    procedure SetAutoSize(AValue: Boolean);
    procedure SetBorderSpacing(AValue: TAControlBorderSpacing);
    procedure SetBoundsRect(AValue: TRect);
    procedure SetColor(AValue: TColor);
    procedure SetEnabled(AValue: Boolean);
    procedure SetFont(AValue: TAFont);
    procedure SetHeight(AValue: Integer);
    procedure SetHint(AValue: TCaption);
    procedure SetLeft(AValue: Integer);
    procedure SetMark(AValue: TCaption);
    procedure SetText(AValue: TCaption);
    procedure SetTop(AValue: Integer);
    procedure SetVisible(AValue: Boolean);
    procedure SetWidth(AValue: Integer);
  protected
    function GetParentColor: Boolean; virtual; abstract;
    function GetParentFont: Boolean; virtual; abstract;
    procedure SetParentColor(AValue: Boolean); virtual; abstract;
    procedure SetParentFont(AValue: Boolean); virtual; abstract;
  public
    function GetParent: TAWinControl;
    procedure SetParent(AValue: TAWinControl);
  protected  //control 未公开
    procedure Click; virtual;
    procedure DblClick; virtual;
  public
    procedure AdjustSize;
    procedure InvalidatePreferredSize;
    procedure BringToFront;
    procedure Hide;
    procedure Invalidate;
    procedure SendToBack;
    procedure Show;
    procedure Update;
    //
    procedure AddControlListener(l: IControlListener);
    procedure RemoveControlListener(l: IControlListener);
    function GetControlListeners: TControlListenerList;
    procedure AddMouseListener(l: IMouseListener);
    procedure RemoveMouseListener(l: IMouseListener);
    function GetMouseListeners: TMouseListenerList;
  end;

  TProxyGraphicControlPeer = class(TProxyControlPeer, IAGraphicControlPeer)

  end;

  { TProxyWinControlPeer }

  TProxyWinControlPeer = class abstract(TProxyControlPeer, IAWinControlPeer)
  private
    FControls: TFPList;    // the child controls
    FKeyListenerList: TKeyListenerList;
  protected
    procedure CheckWinControlEvents;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TWinControl;
    procedure WinControlEnterEvent(Sender: TObject);
    procedure WinControlExitEvent(Sender: TObject);
    procedure KeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure KeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    function GetBorderStyle: TBorderStyle; virtual; abstract; //WinControl未公开
    function GetControl(AIndex: Integer): TAControl;
    function GetControlCount: Integer;
    function GetShowing: Boolean;
    function GetTabOrder: TTabOrder;
    procedure SetBorderStyle(AValue: TBorderStyle); virtual; abstract;
    procedure SetTabOrder(AValue: TTabOrder);
    //
    procedure InsertControl(AControl: TAControl);
    procedure RemoveControl(AControl: TAControl);
    function CanFocus: Boolean;
    function CanSetFocus: Boolean;
    function Focused: Boolean;
    procedure SetFocus;
    //
    procedure AddWinControlListener(l: IWinControlListener);
    procedure RemoveWinControlListener(l: IWinControlListener);
    function GetWinControlListeners: TWinControlListenerList;
    procedure AddKeyListener(l: IKeyListener);
    procedure RemoveKeyListener(l: IKeyListener);
    function GetKeyListeners: TKeyListenerList;
  end;

  { TProxyCustomControlPeer }

  TProxyCustomControlPeer = class abstract(TProxyWinControlPeer, IACustomControlPeer)
  private
    FCanvas: TACanvas;
  protected
    procedure CheckCustomControlEvents;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TCustomControl;
    procedure CustomControlPaintEvent(Sender: TObject);
  public //override WinControl
    function GetBorderStyle: TBorderStyle; override;
    procedure SetBorderStyle(AValue: TBorderStyle); override;
  public
    function GetCanvas: TACanvas;
    procedure SetCanvas(AValue: TACanvas);
    procedure AddCustomControlListener(l: ICustomControlListener);
    procedure RemoveCustomControlListener(l: ICustomControlListener);
    function GetCustomControlListeners: TCustomControlListenerList;
  end;

  { TProxyListBoxPeer }

  TProxyListBoxPeer = class(TProxyWinControlPeer, IAListBoxPeer)
  private
    FCanvas: TACanvas;
  protected
    procedure CheckListBoxEvents;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TListBox;
    procedure ListBoxSelectionChangeEvent(Sender: TObject; User: Boolean);
  public //override TProxyControlPeer
    procedure Click; override;
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public //override TProxyWinControlPeer
    function GetBorderStyle: TBorderStyle; override;
    procedure SetBorderStyle(AValue: TBorderStyle); override;
  public
    function GetCanvas: TACanvas;
    function GetCount: Integer;
    function GetItemHeight: Integer;
    function GetItemIndex: Integer;
    function GetItems: TStrings;
    function GetSelected(Index: Integer): Boolean;
    function GetSorted: Boolean;
    procedure SetItemHeight(AValue: Integer);
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TStrings);
    procedure SetSelected(Index: Integer; AValue: Boolean);
    procedure SetSorted(AValue: Boolean);
    procedure Clear;
    function GetSelectedText: string;
    function ItemRect(Index: Integer): TRect;
    procedure AddListBoxListener(l: IListBoxListener);
    procedure RemoveListBoxListener(l: IListBoxListener);
    function GetListBoxListeners: TListBoxListenerList;
  end;

  { TProxyComboBoxPeer }

  TProxyComboBoxPeer = class(TProxyWinControlPeer, IAComboBoxPeer)
  private
    FCanvas: TACanvas;
  protected
    procedure CheckComboBoxEvents;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TComboBox;
    procedure ComboBoxChangeEvent(Sender: TObject);
    procedure ComboBoxDropDownEvent(Sender: TObject);
    procedure ComboBoxSelectEvent(Sender: TObject);
  public //override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public //override TProxyWinControlPeer
    function GetBorderStyle: TBorderStyle; override;
    procedure SetBorderStyle(AValue: TBorderStyle); override;
  public
    function GetMaxLength: Integer;
    function GetSorted: Boolean;
    procedure SetMaxLength(AValue: Integer);
    procedure SetSorted(AValue: Boolean);
    procedure AddComboBoxListener(l: IComboBoxListener);
    procedure RemoveComboBoxListener(l: IComboBoxListener);
    function GetComboBoxListeners: TComboBoxListenerList;
    //
    function GetCanvas: TACanvas;
    function GetDropDownCount: Integer;
    function GetItemIndex: Integer;
    function GetItems: TStrings;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    function GetStyle: TComboBoxStyle;
    procedure SetDropDownCount(AValue: Integer);
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TStrings);
    procedure SetSelLength(AValue: Integer);
    procedure SetSelStart(AValue: Integer);
    procedure SetSelText(AValue: string);
    procedure SetStyle(AValue: TComboBoxStyle);
    //
    procedure Clear;
    procedure SelectAll;
  end;

  { TProxyLabelPeer }

  TProxyLabelPeer = class(TProxyGraphicControlPeer, IALabelPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TLabel;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public
    function GetAlignment: TAlignment;
    function GetLayout: TTextLayout;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetLayout(AValue: TTextLayout);
  end;

  { TProxyPanelPeer }

  TProxyPanelPeer = class(TProxyCustomControlPeer, IAPanelPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TPanel;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public
    function GetAlignment: TAlignment;
    function GetBevelColor: TColor;
    function GetBevelInner: TPanelBevel;
    function GetBevelOuter: TPanelBevel;
    function GetBevelWidth: TBevelWidth;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetBevelColor(AValue: TColor);
    procedure SetBevelInner(AValue: TPanelBevel);
    procedure SetBevelOuter(AValue: TPanelBevel);
    procedure SetBevelWidth(AValue: TBevelWidth);
  end;

  { TProxyCustomEditPeer }

  TProxyCustomEditPeer = class abstract(TProxyWinControlPeer, IACustomEditPeer)
  public
    function GetDelegate: TCustomEdit;
    procedure EditChangeEvent(Sender: TObject);
  public // override TProxyWinControlPeer
    function GetBorderStyle: TBorderStyle; override;
    procedure SetBorderStyle(AValue: TBorderStyle); override;
  public
    procedure Clear;
    procedure SelectAll;
    function GetMaxLength: Integer;
    function GetNumbersOnly: Boolean;
    function GetPasswordChar: Char;
    function GetReadOnly: Boolean;
    function GetSelLength: integer;
    function GetSelStart: integer;
    function GetSelText: String;
    procedure SetMaxLength(AValue: Integer);
    procedure SetNumbersOnly(AValue: Boolean);
    procedure SetPasswordChar(AValue: Char);
    procedure SetReadOnly(AValue: Boolean);
    procedure SetSelLength(AValue: integer);
    procedure SetSelStart(AValue: integer);
    procedure SetSelText(AValue: String);
    //
    procedure AddEditListener(l: IEditListener);
    procedure RemoveEditListener(l: IEditListener);
    function GetEditListeners: TEditListenerList;
  end;

  { TProxyEditPeer }

  TProxyEditPeer = class(TProxyCustomEditPeer, IAEditPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TEdit;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  end;

  { TProxyMemoPeer }

  TProxyMemoPeer = class(TProxyCustomEditPeer, IAMemoPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TMemo;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public
    function GetLines: TStrings;
    function GetScrollBars: TScrollStyle;
    procedure SetLines(AValue: TStrings);
    procedure SetScrollBars(AValue: TScrollStyle);
  end;

  { TProxyFormPeer }

  TProxyFormPeer = class(TProxyCustomControlPeer, IAFormPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure CheckFormControlEvents;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TForm;
    procedure FormActivateEvent(Sender: TObject);
    procedure FormCloseEvent(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDeactivateEvent(Sender: TObject);
    procedure FormHideEvent(Sender: TObject);
    procedure FormShowEvent(Sender: TObject);
  protected // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
  public // override TProxyControlPeer
    function GetParentFont: Boolean; override;
    procedure SetParentFont(AValue: Boolean); override;
  public
    function GetFormBorderStyle: TFormBorderStyle;
    procedure SetFormBorderStyle(AValue: TFormBorderStyle);
    procedure Close;
    function ShowModal: Integer;
    procedure AddFormListener(l: IFormListener);
    procedure RemoveFormListener(l: IFormListener);
    function GetFormListeners: TFormListenerList;
  end;

  { TProxyFramePeer }

  TProxyFramePeer = class(TProxyCustomControlPeer, IAFramePeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TFrame;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  end;

  { TProxyDateTimePickerPeer }

  TProxyDateTimePickerPeer = class(TProxyCustomControlPeer, IADateTimePickerPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure RegisterMouseEvents; override;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    function GetDelegate: TDateTimePicker;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public
    function GetDate: TDate;
    function GetDateTime: TDateTime;
    function GetMaxDate: TDate;
    function GetMinDate: TDate;
    function GetTime: TTime;
    procedure SetDate(AValue: TDate);
    procedure SetDateTime(AValue: TDateTime);
    procedure SetMaxDate(AValue: TDate);
    procedure SetMinDate(AValue: TDate);
    procedure SetTime(AValue: TTime);
  end;

  { TProxyCustomGridPeer }

  TProxyCustomGridPeer = class abstract(TProxyCustomControlPeer, IACustomGridPeer)
  public
    function GetDelegate: TCustomGrid;
  protected  //以下皆因 CustomGrid 未公开
    function GetBorderColor: TColor; virtual; abstract;
    function GetCol: Integer; virtual; abstract;
    function GetColCount: Integer; virtual; abstract;
    function GetColWidths(ACol: Integer): Integer; virtual; abstract;
    function GetDefColWidth: Integer; virtual; abstract;
    function GetDefRowHeight: Integer; virtual; abstract;
    function GetFixedColor: TColor; virtual; abstract;
    function GetFixedCols: Integer; virtual; abstract;
    function GetFixedRows: Integer; virtual; abstract;
    function GetGridBorderStyle: TBorderStyle; virtual; abstract;
    function GetOptions: TGridOptions; virtual; abstract;
    function GetRow: Integer; virtual; abstract;
    function GetRowCount: Integer; virtual; abstract;
    function GetRowHeights(ARow: Integer): Integer; virtual; abstract;
    function GetScrollBars: TScrollStyle; virtual; abstract;
    function GetTitleFont: TAFont; virtual; abstract;
    procedure SetBorderColor(AValue: TColor); virtual; abstract;
    procedure SetCol(AValue: Integer); virtual; abstract;
    procedure SetColCount(AValue: Integer); virtual; abstract;
    procedure SetColWidths(ACol: Integer; AValue: Integer); virtual; abstract;
    procedure SetDefColWidth(AValue: Integer); virtual; abstract;
    procedure SetDefRowHeight(AValue: Integer); virtual; abstract;
    procedure SetFixedcolor(AValue: TColor); virtual; abstract;
    procedure SetFixedCols(AValue: Integer); virtual; abstract;
    procedure SetFixedRows(AValue: Integer); virtual; abstract;
    procedure SetGridBorderStyle(AValue: TBorderStyle); virtual; abstract;
    procedure SetOptions(AValue: TGridOptions); virtual; abstract;
    procedure SetRow(AValue: Integer); virtual; abstract;
    procedure SetRowCount(AValue: Integer); virtual; abstract;
    procedure SetRowHeights(ARow: Integer; AValue: Integer); virtual; abstract;
    procedure SetScrollBars(AValue: TScrollStyle); virtual; abstract;
    procedure SetTitleFont(AValue: TAFont); virtual; abstract;
  public
    procedure BeginUpdate;
    function  CellRect(ACol, ARow: Integer): TRect;
    procedure Clear;
    procedure EndUpdate(ARefresh: Boolean=True);
    procedure InvalidateCell(ACol, ARow: Integer);
    procedure InvalidateCol(ACol: Integer);
    procedure InvalidateRow(ARow: Integer);
  end;

  { TProxyCustomDrawGridPeer }

  TProxyCustomDrawGridPeer = class abstract(TProxyCustomGridPeer, IACustomDrawGridPeer)
  protected
    procedure RegisterControlEvents; override;
    procedure CheckCustomDrawGridControlEvents;
    procedure RegisterMouseEvents; override;
  public
    function GetDelegate: TCustomDrawGrid;
    procedure CustomDrawGridDrawCellEvent(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState:TGridDrawState);
    procedure CustomDrawGridSelectionEvent(Sender: TObject; aCol, aRow: Integer);
    procedure CustomDrawGridSelectCellEvent(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
  public //覆盖 TProxyCustomGridPeer
    function GetBorderColor: TColor; override;
    function GetCol: Integer; override;
    function GetColCount: Integer; override;
    function GetColWidths(ACol: Integer): Integer; override;
    function GetDefColWidth: Integer; override;
    function GetDefRowHeight: Integer; override;
    function GetFixedColor: TColor; override;
    function GetFixedCols: Integer; override;
    function GetFixedRows: Integer; override;
    function GetGridBorderStyle: TBorderStyle; override;
    function GetOptions: TGridOptions; override;
    function GetRow: Integer; override;
    function GetRowCount: Integer; override;
    function GetRowHeights(ARow: Integer): Integer; override;
    function GetScrollBars: TScrollStyle; override;
    procedure SetBorderColor(AValue: TColor); override;
    procedure SetCol(AValue: Integer); override;
    procedure SetColCount(AValue: Integer); override;
    procedure SetColWidths(ACol: Integer; AValue: Integer); override;
    procedure SetDefColWidth(AValue: Integer); override;
    procedure SetDefRowHeight(AValue: Integer); override;
    procedure SetFixedcolor(AValue: TColor); override;
    procedure SetFixedCols(AValue: Integer); override;
    procedure SetFixedRows(AValue: Integer); override;
    procedure SetGridBorderStyle(AValue: TBorderStyle); override;
    procedure SetOptions(AValue: TGridOptions); override;
    procedure SetRow(AValue: Integer); override;
    procedure SetRowCount(AValue: Integer); override;
    procedure SetRowHeights(ARow: Integer; AValue: Integer); override;
    procedure SetScrollBars(AValue: TScrollStyle); override;
  public
    procedure AddDrawGridListener(l: IDrawGridListener);
    procedure RemoveDrawGridListener(l: IDrawGridListener);
    function GetDrawGridListeners: TDrawGridListenerList;
  end;

  { TProxyStringGridPeer }

  TProxyStringGridPeer = class(TProxyCustomDrawGridPeer, IAStringGridPeer)
  private
    FTitleFont: TAFont;
  public
    constructor Create(TheTarget: TAComponent; AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDelegate: TStringGrid;
  public // override TProxyControlPeer
    function GetParentColor: Boolean; override;
    function GetParentFont: Boolean; override;
    procedure SetParentColor(AValue: Boolean); override;
    procedure SetParentFont(AValue: Boolean); override;
  public //覆盖 TProxyCustomGridPeer
    function GetTitleFont: TAFont; override;
    procedure SetTitleFont(AValue: TAFont); override;
  public
    function GetCells(ACol, ARow: Integer): string;
    function GetCols(Index: Integer): TStrings;
    function GetRows(Index: Integer): TStrings;
    procedure SetCells(ACol, ARow: Integer; AValue: string);
    procedure SetCols(Index: Integer; AValue: TStrings);
    procedure SetRows(Index: Integer; AValue: TStrings);
    procedure AutoSizeColumn(ACol: Integer);
    procedure AutoSizeColumns;
  end;

implementation

{$i graphics_proxy.inc}

{ TProxyPeer }

constructor TProxyPeer.Create;
begin
  FIsSelfCreateDelegate := False;
  FDelegateObj := nil;
end;

destructor TProxyPeer.Destroy;
begin
  if FIsSelfCreateDelegate and Assigned(FDelegateObj) then
    FDelegateObj.Free;
  inherited Destroy;
end;

function TProxyPeer.GetDelegate: TObject;
begin
  Result := FDelegateObj;
end;

{ TProxyControlBorderSpacingPeer }

constructor TProxyControlBorderSpacingPeer.Create(OwnerControl: TControl);
begin
  inherited Create;
  FIsSelfCreateDelegate := True;
  FDelegateObj := TControlBorderSpacing.Create(OwnerControl);
end;

constructor TProxyControlBorderSpacingPeer.Create(TheDelegate: TControlBorderSpacing);
begin
  inherited Create;
  FDelegateObj := TheDelegate;
end;

function TProxyControlBorderSpacingPeer.GetDelegate: TControlBorderSpacing;
begin
  Result := TControlBorderSpacing(FDelegateObj);
end;

function TProxyControlBorderSpacingPeer.GetAround: Integer;
begin
  Result := GetDelegate.Around;
end;

function TProxyControlBorderSpacingPeer.GetBottom: Integer;
begin
  Result := GetDelegate.Bottom;
end;

function TProxyControlBorderSpacingPeer.GetLeft: Integer;
begin
  Result := GetDelegate.Left;
end;

function TProxyControlBorderSpacingPeer.GetRight: Integer;
begin
  Result := GetDelegate.Right;
end;

function TProxyControlBorderSpacingPeer.GetTop: Integer;
begin
  Result := GetDelegate.Top;
end;

procedure TProxyControlBorderSpacingPeer.SetAround(AValue: Integer);
begin
  GetDelegate.Around := AValue;
end;

procedure TProxyControlBorderSpacingPeer.SetBottom(AValue: Integer);
begin
  GetDelegate.Bottom := AValue;
end;

procedure TProxyControlBorderSpacingPeer.SetLeft(AValue: Integer);
begin
  GetDelegate.Left := AValue;
end;

procedure TProxyControlBorderSpacingPeer.SetRight(AValue: Integer);
begin
  GetDelegate.Right := AValue;
end;

procedure TProxyControlBorderSpacingPeer.SetTop(AValue: Integer);
begin
  GetDelegate.Top := AValue;
end;

{ TProxyComponentPeer }

constructor TProxyComponentPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create;
  FTargetObj := TheTarget;
end;

function TProxyComponentPeer.GetDelegate: TComponent;
begin
  Result := TComponent(FDelegateObj);
end;

function TProxyComponentPeer.GetName: TComponentName;
begin
  Result := GetDelegate.Name;
end;

procedure TProxyComponentPeer.SetName(AValue: TComponentName);
begin
  GetDelegate.Name := AValue;
end;

function TProxyComponentPeer.GetTag: PtrInt;
begin
  Result := GetDelegate.Tag;
end;

procedure TProxyComponentPeer.SetTag(AValue: PtrInt);
begin
  GetDelegate.Tag := AValue;
end;

{ TProxyControlPeer }

constructor TProxyControlPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FFont := nil;
  FBorderSpacing := nil;
  FControlPeerList.Add(Self);
  FControlListenerList := nil;
  FMouseListenerList := nil;
  FMark := '';
end;

destructor TProxyControlPeer.Destroy;
begin
  if Assigned(FFont) then
    FFont.Free;
  if Assigned(FBorderSpacing) then
    FBorderSpacing.Free;
  FControlPeerList.Remove(Self);
  if Assigned(FControlListenerList) then
    FControlListenerList.Free;
  if Assigned(FMouseListenerList) then
    FMouseListenerList.Free;
  inherited Destroy;
end;

function TProxyControlPeer.GetDelegate: TControl;
begin
  Result := TControl(FDelegateObj);
end;

procedure TProxyControlPeer.ControlClickEvent(Sender: TObject);
var
  i: Integer;
  ce: IControlEvent;
begin
  if Assigned(FControlListenerList) then
    begin
      ce := TControlEvent.Create(Sender, TAControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        IControlListener(FControlListenerList[i]).ControlClick(ce);
    end;
end;

procedure TProxyControlPeer.ControlDblClickEvent(Sender: TObject);
var
  i: Integer;
  ce: IControlEvent;
begin
  if Assigned(FControlListenerList) then
    begin
      ce := TControlEvent.Create(Sender, TAControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        IControlListener(FControlListenerList[i]).ControlDblClick(ce);
    end;
end;

procedure TProxyControlPeer.ControlResizeEvent(Sender: TObject);
var
  i: Integer;
  ce: IControlEvent;
begin
  if Assigned(FControlListenerList) then
    begin
      ce := TControlEvent.Create(Sender, TAControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        IControlListener(FControlListenerList[i]).ControlResize(ce);
    end;
end;

procedure TProxyControlPeer.MouseDownEvent(Sender: TObject; Button: Controls.TMouseButton; Shift: TShiftState; X, Y: Integer)
  ;
var
  i: Integer;
  me: IMouseEvent;
  p: TPoint;
begin
  if Assigned(FMouseListenerList) then
    begin
      p.X := X;
      p.Y := Y;
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), p, Mouse.CursorPos, Shift, cm_AWT.TMouseButton(Button));
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MousePressed(me);
    end;
end;

procedure TProxyControlPeer.MouseUpEvent(Sender: TObject; Button: Controls.TMouseButton; Shift: TShiftState; X, Y: Integer)
  ;
var
  i: Integer;
  me: IMouseEvent;
  p: TPoint;
begin
  if Assigned(FMouseListenerList) then
    begin
      p.X := X;
      p.Y := Y;
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), p, Mouse.CursorPos, Shift, cm_AWT.TMouseButton(Button));
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MouseReleased(me);
    end;
end;

procedure TProxyControlPeer.MouseEnterEvent(Sender: TObject);
var
  i: Integer;
  me: IMouseEvent;
  p: TPoint;
begin
  if Assigned(FMouseListenerList) then
    begin
      p := GetDelegate.ScreenToClient(Mouse.CursorPos);
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), p, Mouse.CursorPos, []);
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MouseEntered(me);
    end;
end;

procedure TProxyControlPeer.MouseLeaveEvent(Sender: TObject);
var
  i: Integer;
  me: IMouseEvent;
  p: TPoint;
begin
  if Assigned(FMouseListenerList) then
    begin
      p := GetDelegate.ScreenToClient(Mouse.CursorPos);
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), p, Mouse.CursorPos, []);
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MouseExited(me);
    end;
end;

procedure TProxyControlPeer.MouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  me: IMouseEvent;
  p: TPoint;
begin
  if Assigned(FMouseListenerList) then
    begin
      p.X := X;
      p.Y := Y;
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), p, Mouse.CursorPos, Shift);
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MouseMoved(me);
    end;
end;

procedure TProxyControlPeer.MouseWheelEvent(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  i: Integer;
  me: IMouseEvent;
begin
  if Assigned(FMouseListenerList) then
    begin
      me := TMouseEvent.Create(Sender, TAControl(Self.FTargetObj), MousePos, Mouse.CursorPos, Shift, WheelDelta);
      for i:=0 to FMouseListenerList.Count-1 do
        FMouseListenerList[i].MouseWheeled(me);
    end;
end;

function TProxyControlPeer.GetAlign: TAlign;
begin
  Result := cm_AWT.TAlign(GetDelegate.Align);
end;

function TProxyControlPeer.GetAutoSize: Boolean;
begin
  Result := GetDelegate.AutoSize;
end;

function TProxyControlPeer.GetBorderSpacing: TAControlBorderSpacing;
var
  cbsp: IAControlBorderSpacingPeer;
begin
  Result := nil;
  if not Assigned(FBorderSpacing) then
    begin
      cbsp := TProxyControlBorderSpacingPeer.Create(GetDelegate.BorderSpacing);
      FBorderSpacing := TAControlBorderSpacing.Create(cbsp);
    end;
  Result := FBorderSpacing;
end;

function TProxyControlPeer.GetBoundsRect: TRect;
begin
  Result := GetDelegate.BoundsRect;
end;

function TProxyControlPeer.GetColor: TColor;
begin
  Result := GetDelegate.Color;
end;

procedure TProxyControlPeer.SetColor(AValue: TColor);
begin
  GetDelegate.Color := AValue;
end;

function TProxyControlPeer.GetEnabled: Boolean;
begin
  Result := GetDelegate.Enabled;
end;

procedure TProxyControlPeer.SetEnabled(AValue: Boolean);
begin
  GetDelegate.Enabled := AValue;
end;

function TProxyControlPeer.GetFont: TAFont;
var
  fp: IAFontPeer;
begin
  Result := nil;
  if not Assigned(FFont) then
    begin
      fp := TProxyFontPeer.Create(GetDelegate.Font);
      FFont := TAFont.Create(fp);
    end;
  Result := FFont;
end;

procedure TProxyControlPeer.SetFont(AValue: TAFont);
begin
  if FFont = AValue then
    Exit;
  if Assigned(FFont) then
    FreeAndNil(FFont);
  FFont := TAFont.Create(AValue.GetPeer);
  if FFont.GetPeer.GetDelegate is TFont then
    GetDelegate.Font := TFont(FFont.GetPeer.GetDelegate);
end;

function TProxyControlPeer.GetLeft: Integer;
begin
  Result := GetDelegate.Left;
end;

function TProxyControlPeer.GetMark: TCaption;
begin
  Result := FMark;
end;

function TProxyControlPeer.GetText: TCaption;
begin
  Result := GetDelegate.Caption; //LCL 中 Text 和 Caption 内容一致
end;

procedure TProxyControlPeer.SetLeft(AValue: Integer);
begin
  GetDelegate.Left := AValue;
end;

procedure TProxyControlPeer.SetMark(AValue: TCaption);
begin
  FMark := AValue;
end;

procedure TProxyControlPeer.SetText(AValue: TCaption);
begin
  GetDelegate.Caption := AValue;  //LCL 中 Text 和 Caption 内容一致
end;

function TProxyControlPeer.GetHeight: Integer;
begin
  Result := GetDelegate.Height;
end;

function TProxyControlPeer.GetHint: TCaption;
begin
  Result := GetDelegate.Hint;
end;

procedure TProxyControlPeer.SetHeight(AValue: Integer);
begin
  GetDelegate.Height := AValue;
end;

procedure TProxyControlPeer.SetHint(AValue: TCaption);
begin
  GetDelegate.Hint := AValue;
end;

function TProxyControlPeer.GetTop: Integer;
begin
  Result := GetDelegate.Top;
end;

function TProxyControlPeer.GetVisible: Boolean;
begin
  Result := GetDelegate.Visible;
end;

procedure TProxyControlPeer.SetTop(AValue: Integer);
begin
  GetDelegate.Top := AValue;
end;

procedure TProxyControlPeer.SetVisible(AValue: Boolean);
begin
  GetDelegate.Visible := AValue;
end;

function TProxyControlPeer.GetWidth: Integer;
begin
  Result := GetDelegate.Width;
end;

procedure TProxyControlPeer.SetAlign(AValue: TAlign);
begin
  GetDelegate.Align := Controls.TAlign(AValue);
end;

procedure TProxyControlPeer.SetAutoSize(AValue: Boolean);
begin
  GetDelegate.AutoSize := AValue;
end;

procedure TProxyControlPeer.SetBorderSpacing(AValue: TAControlBorderSpacing);
begin
  if FBorderSpacing = AValue then
    Exit;
  if Assigned(FBorderSpacing) then
    FreeAndNil(FBorderSpacing);
  FBorderSpacing := TAControlBorderSpacing.Create(AValue.GetPeer);
  if FBorderSpacing.GetPeer.GetDelegate is TControlBorderSpacing then
    GetDelegate.BorderSpacing := TControlBorderSpacing(FBorderSpacing.GetPeer.GetDelegate);
end;

procedure TProxyControlPeer.SetBoundsRect(AValue: TRect);
begin
  GetDelegate.BoundsRect := AValue;
end;

procedure TProxyControlPeer.SetWidth(AValue: Integer);
begin
  GetDelegate.Width := AValue;
end;

function TProxyControlPeer.GetParent: TAWinControl;
var
  i: Integer;
  cp: TProxyControlPeer;
begin
  // TODO 改进实现
  Result := nil;
  try
    //Result := FParent;
    //if Assigned(FParent) and (GetDelegate.Parent = FParent.GetPeer.GetDelegate) then
    //  Result := FParent;
    for i:=0 to FControlPeerList.Count-1 do
      begin
        cp := TProxyControlPeer(FControlPeerList[i]);
        if cp.GetDelegate = GetDelegate.Parent then
          Result := TAWinControl(cp.FTargetObj);
      end;
  except
    on e: Exception do
      DefaultMsgBox.MessageBox(e.ClassName + #10 + e.Message, Self.ClassName + ' output error');
  end;
end;

procedure TProxyControlPeer.SetParent(AValue: TAWinControl);
var
  parent: TObject;
begin
  // 之前在外面的代码，这里已直接代理外部了，不再需要这层关系。
  //if FParent = AValue then
  //  Exit;
  //GetPeer.ReParent(AValue.GetPeer);
  //if FParent <> nil then
  //  FParent.RemoveControl(Self);
  //if AValue <> nil then
  //  AValue.InsertControl(Self);
  //FParent := AValue;
  try
    parent := AValue.GetPeer.GetDelegate;
    if parent is TWinControl then
      begin
        GetDelegate.Parent := TWinControl(parent);
        //FParent := AValue;
      end;
  except
    on e: Exception do
      DefaultMsgBox.MessageBox(e.ClassName + #10 + e.Message, Self.ClassName + ' output error');
  end;
end;

procedure TProxyControlPeer.Click;
begin
  //
end;

procedure TProxyControlPeer.DblClick;
begin
  //
end;

procedure TProxyControlPeer.AdjustSize;
begin
  GetDelegate.AdjustSize;
end;

procedure TProxyControlPeer.InvalidatePreferredSize;
begin
  GetDelegate.InvalidatePreferredSize;
end;

procedure TProxyControlPeer.BringToFront;
begin
  GetDelegate.BringToFront;
end;

procedure TProxyControlPeer.Hide;
begin
  GetDelegate.Hide;
end;

procedure TProxyControlPeer.Invalidate;
begin
  GetDelegate.Invalidate;
end;

procedure TProxyControlPeer.SendToBack;
begin
  GetDelegate.SendToBack;
end;

procedure TProxyControlPeer.Show;
begin
  GetDelegate.Show;
end;

procedure TProxyControlPeer.Update;
begin
  GetDelegate.Update;
end;

procedure TProxyControlPeer.RegisterControlEvents;
begin
  GetDelegate.OnClick := @ControlClickEvent;
  GetDelegate.OnResize := @ControlResizeEvent;
end;

procedure TProxyControlPeer.RegisterMouseEvents;
begin
  // Control 未公开
end;

procedure TProxyControlPeer.AddControlListener(l: IControlListener);
begin
  if not Assigned(FControlListenerList) then
    begin
      FControlListenerList := TCMInterfaceList.Create;
      RegisterControlEvents;
    end;
  FControlListenerList.Add(l);
end;

procedure TProxyControlPeer.RemoveControlListener(l: IControlListener);
begin
  if Assigned(FControlListenerList) then
    FControlListenerList.Remove(l);
end;

function TProxyControlPeer.GetControlListeners: TControlListenerList;
begin
  if not Assigned(FControlListenerList) then
    begin
      FControlListenerList := TCMInterfaceList.Create;
      RegisterControlEvents;
    end;
  Result := TControlListenerList(FControlListenerList).Clone;
end;

procedure TProxyControlPeer.AddMouseListener(l: IMouseListener);
begin
  if not Assigned(FMouseListenerList) then
    begin
      FMouseListenerList := TMouseListenerList.Create;
      RegisterMouseEvents;
    end;
  FMouseListenerList.Add(l);
end;

procedure TProxyControlPeer.RemoveMouseListener(l: IMouseListener);
begin
  if Assigned(FMouseListenerList) then
    FMouseListenerList.Remove(l);
end;

function TProxyControlPeer.GetMouseListeners: TMouseListenerList;
begin
  if not Assigned(FMouseListenerList) then
    begin
      FMouseListenerList := TMouseListenerList.Create;
      RegisterMouseEvents;
    end;
  Result := FMouseListenerList.Clone;
end;

{ TProxyWinControlPeer }

constructor TProxyWinControlPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FControls := TFPList.Create;
  FKeyListenerList := nil;
end;

destructor TProxyWinControlPeer.Destroy;
var
  c: TAControl;
begin
  while FControls.Count > 0 do
    begin
      c := TAControl(FControls.Last);
      RemoveControl(c);
    end;
  if Assigned(FKeyListenerList) then
    FKeyListenerList.Free;
  inherited Destroy;
end;

function TProxyWinControlPeer.GetDelegate: TWinControl;
begin
  Result := TWinControl(FDelegateObj);
end;

procedure TProxyWinControlPeer.WinControlEnterEvent(Sender: TObject);
var
  i: Integer;
  wce: IWinControlEvent;
  wcl: IWinControlListener;
begin
  if Assigned(FControlListenerList) then
    begin
      wce := TWinControlEvent.Create(Sender, TAWinControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IWinControlListener, wcl) then
          wcl.ControlEnter(wce);
    end;
end;

procedure TProxyWinControlPeer.WinControlExitEvent(Sender: TObject);
var
  i: Integer;
  wce: IWinControlEvent;
  wcl: IWinControlListener;
begin
  if Assigned(FControlListenerList) then
    begin
      wce := TWinControlEvent.Create(Sender, TAWinControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IWinControlListener, wcl) then
          wcl.ControlExit(wce);
    end;
end;

procedure TProxyWinControlPeer.KeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
  ke: IKeyEvent;
begin
  if Assigned(FKeyListenerList) then
    begin
      ke := TKeyEvent.Create(Sender, TAWinControl(Self.FTargetObj), Key, Shift);
      for i:=0 to FKeyListenerList.Count-1 do
        begin
          FKeyListenerList[i].KeyPressed(ke);
          Key := ke.GetKeyCode;
        end;
    end;
end;

procedure TProxyWinControlPeer.KeyPressEvent(Sender: TObject; var Key: Char);
var
  i: Integer;
  ke: IKeyEvent;
begin
  if Assigned(FKeyListenerList) then
    begin
      ke := TKeyEvent.Create(Sender, TAWinControl(Self.FTargetObj), Key, []);
      for i:=0 to FKeyListenerList.Count-1 do
        begin
          FKeyListenerList[i].KeyTyped(ke);
          Key := ke.GetKeyChar;
        end;
    end;
end;

procedure TProxyWinControlPeer.KeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: Integer;
  ke: IKeyEvent;
begin
  if Assigned(FKeyListenerList) then
    begin
      ke := TKeyEvent.Create(Sender, TAWinControl(Self.FTargetObj), Key, Shift);
      for i:=0 to FKeyListenerList.Count-1 do
        begin
          FKeyListenerList[i].KeyReleased(ke);
          Key := ke.GetKeyCode;
        end;
    end;
end;

function TProxyWinControlPeer.GetControl(AIndex: Integer): TAControl;
var
  c: TControl;
  i: Integer;
  cp: TProxyControlPeer;
begin
  // TODO 改进实现
  c := GetDelegate.Controls[AIndex];
  if Assigned(c) then
    begin
      for i:=0 to FControlPeerList.Count-1 do
        begin
          cp := TProxyControlPeer(FControlPeerList[i]);
          if cp.GetDelegate = c then
            Result := TAControl(cp.FTargetObj);
        end;
    end;
end;

function TProxyWinControlPeer.GetControlCount: Integer;
begin
  Result := GetDelegate.ControlCount;
end;

function TProxyWinControlPeer.GetShowing: Boolean;
begin
  Result := GetDelegate.Showing;
end;

function TProxyWinControlPeer.GetTabOrder: TTabOrder;
begin
  Result := GetDelegate.TabOrder;
end;

procedure TProxyWinControlPeer.SetTabOrder(AValue: TTabOrder);
begin
  GetDelegate.TabOrder := AValue;
end;

procedure TProxyWinControlPeer.InsertControl(AControl: TAControl);
var
  c: TObject;
begin
  c := AControl.GetPeer.GetDelegate;
  if Assigned(c) then
    GetDelegate.InsertControl(TControl(c));
  //AControl.FParent := Self;
end;

procedure TProxyWinControlPeer.RemoveControl(AControl: TAControl);
var
  c: TObject;
begin
  c := AControl.GetPeer.GetDelegate;
  if Assigned(c) then
    GetDelegate.RemoveControl(TControl(c));
  //AControl.FParent := nil;
end;

function TProxyWinControlPeer.CanFocus: Boolean;
begin
  Result := GetDelegate.CanFocus;
end;

function TProxyWinControlPeer.CanSetFocus: Boolean;
begin
  Result := GetDelegate.CanSetFocus;
end;

function TProxyWinControlPeer.Focused: Boolean;
begin
  Result := GetDelegate.Focused;
end;

procedure TProxyWinControlPeer.SetFocus;
begin
  GetDelegate.SetFocus;
end;

procedure TProxyWinControlPeer.CheckWinControlEvents;
begin
  if GetDelegate.OnEnter <> @WinControlEnterEvent then
    GetDelegate.OnEnter := @WinControlEnterEvent;
  if GetDelegate.OnExit <> @WinControlExitEvent then
    GetDelegate.OnExit := @WinControlExitEvent;
end;

procedure TProxyWinControlPeer.AddWinControlListener(l: IWinControlListener);
begin
  CheckWinControlEvents;
  Self.AddControlListener(l);
end;

procedure TProxyWinControlPeer.RemoveWinControlListener(l: IWinControlListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyWinControlPeer.GetWinControlListeners: TWinControlListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TWinControlListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], IWinControlListener) then
        Result.Add(IWinControlListener(FControlListenerList[i]));
end;

procedure TProxyWinControlPeer.AddKeyListener(l: IKeyListener);
begin
  if not Assigned(FKeyListenerList) then
    begin
      FKeyListenerList := TKeyListenerList.Create;
      GetDelegate.OnKeyDown := @KeyDownEvent;
      GetDelegate.OnKeyPress := @KeyPressEvent;
      GetDelegate.OnKeyUp := @KeyUpEvent;
    end;
  FKeyListenerList.Add(l);
end;

procedure TProxyWinControlPeer.RemoveKeyListener(l: IKeyListener);
begin
  if Assigned(FKeyListenerList) then
    FKeyListenerList.Remove(l);
end;

function TProxyWinControlPeer.GetKeyListeners: TKeyListenerList;
begin
  if not Assigned(FKeyListenerList) then
    begin
      FKeyListenerList := TKeyListenerList.Create;
      GetDelegate.OnKeyDown := @KeyDownEvent;
      GetDelegate.OnKeyPress := @KeyPressEvent;
      GetDelegate.OnKeyUp := @KeyUpEvent;
    end;
  Result := FKeyListenerList;
end;

{ TProxyCustomControlPeer }

constructor TProxyCustomControlPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FCanvas := nil;
end;

destructor TProxyCustomControlPeer.Destroy;
begin
  if Assigned(FCanvas) then
    FCanvas.Free;
  inherited Destroy;
end;

function TProxyCustomControlPeer.GetDelegate: TCustomControl;
begin
  Result := TCustomControl(FDelegateObj);
end;

procedure TProxyCustomControlPeer.CustomControlPaintEvent(Sender: TObject);
var
  i: Integer;
  cce: ICustomControlEvent;
  ccl: ICustomControlListener;
begin
  if Assigned(FControlListenerList) then
    begin
      cce := TCustomControlEvent.Create(Sender, TACustomControl(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], ICustomControlListener, ccl) then
          ccl.ControlPaint(cce);
    end;
end;

function TProxyCustomControlPeer.GetBorderStyle: TBorderStyle;
begin
  Result := cm_AWT.TBorderStyle(GetDelegate.BorderStyle);
end;

function TProxyCustomControlPeer.GetCanvas: TACanvas;
var
  cp: IACanvasPeer;
begin
  Result := nil;
  if not Assigned(FCanvas) then
    begin
      cp := TProxyCanvasPeer.Create(GetDelegate.Canvas);
      FCanvas := TACanvas.Create(cp);
    end;
  Result := FCanvas;
end;

procedure TProxyCustomControlPeer.SetBorderStyle(AValue: TBorderStyle);
begin
  GetDelegate.BorderStyle := Controls.TBorderStyle(AValue);
end;

procedure TProxyCustomControlPeer.SetCanvas(AValue: TACanvas);
begin
  if FCanvas = AValue then
    Exit;
  if Assigned(FCanvas) then
    FreeAndNil(FCanvas);
  FCanvas := TACanvas.Create(AValue.GetPeer);
  if FCanvas.GetPeer.GetDelegate is TCanvas then
    GetDelegate.Canvas := TCanvas(FCanvas.GetPeer.GetDelegate);
end;

procedure TProxyCustomControlPeer.CheckCustomControlEvents;
begin
  if GetDelegate.OnPaint <> @CustomControlPaintEvent then
    GetDelegate.OnPaint := @CustomControlPaintEvent;
end;

procedure TProxyCustomControlPeer.AddCustomControlListener(l: ICustomControlListener);
begin
  CheckCustomControlEvents;
  Self.AddWinControlListener(l);
end;

procedure TProxyCustomControlPeer.RemoveCustomControlListener(l: ICustomControlListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyCustomControlPeer.GetCustomControlListeners: TCustomControlListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TCustomControlListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], ICustomControlListener) then
        Result.Add(ICustomControlListener(FControlListenerList[i]));
end;

{ TProxyListBoxPeer }

constructor TProxyListBoxPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FCanvas := nil;
  FDelegateObj := TListBox.Create(AOwner);
end;

destructor TProxyListBoxPeer.Destroy;
begin
  if Assigned(FCanvas) then
    FCanvas.Free;
  inherited Destroy;
end;

procedure TProxyListBoxPeer.CheckListBoxEvents;
begin
  if GetDelegate.OnSelectionChange <> @ListBoxSelectionChangeEvent then
    GetDelegate.OnSelectionChange := @ListBoxSelectionChangeEvent;
end;

function TProxyListBoxPeer.GetDelegate: TListBox;
begin
  Result := TListBox(FDelegateObj);
end;

procedure TProxyListBoxPeer.ListBoxSelectionChangeEvent(Sender: TObject; User: Boolean);
var
  i: Integer;
  lbe: IListBoxEvent;
  lbl: IListBoxListener;
begin
  if Assigned(FControlListenerList) then
    begin
      lbe := TListBoxEvent.Create(Sender, TAListBox(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IListBoxListener, lbl) then
          lbl.ListBoxSelectionChange(lbe);
    end;
end;

procedure TProxyListBoxPeer.Click;
begin
  GetDelegate.Click;
end;

function TProxyListBoxPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyListBoxPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyListBoxPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyListBoxPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyListBoxPeer.GetBorderStyle: TBorderStyle;
begin
  Result := cm_AWT.TBorderStyle(GetDelegate.BorderStyle);
end;

procedure TProxyListBoxPeer.SetBorderStyle(AValue: TBorderStyle);
begin
  GetDelegate.BorderStyle := Controls.TBorderStyle(AValue);
end;

function TProxyListBoxPeer.GetCanvas: TACanvas;
var
  cp: IACanvasPeer;
begin
  Result := nil;
  if not Assigned(FCanvas) then
    begin
      cp := TProxyCanvasPeer.Create(GetDelegate.Canvas);
      FCanvas := TACanvas.Create(cp);
    end;
  Result := FCanvas;
end;

function TProxyListBoxPeer.GetCount: Integer;
begin
  Result := GetDelegate.Count;
end;

function TProxyListBoxPeer.GetItemHeight: Integer;
begin
  Result := GetDelegate.ItemHeight;
end;

function TProxyListBoxPeer.GetItemIndex: Integer;
begin
  Result := GetDelegate.ItemIndex;
end;

function TProxyListBoxPeer.GetItems: TStrings;
begin
  Result := GetDelegate.Items;
end;

function TProxyListBoxPeer.GetSelected(Index: Integer): Boolean;
begin
  Result := GetDelegate.Selected[Index];
end;

function TProxyListBoxPeer.GetSorted: Boolean;
begin
  Result := GetDelegate.Sorted;
end;

procedure TProxyListBoxPeer.SetItemHeight(AValue: Integer);
begin
  GetDelegate.ItemHeight := AValue;
end;

procedure TProxyListBoxPeer.SetItemIndex(AValue: Integer);
begin
  GetDelegate.ItemIndex := AValue;
end;

procedure TProxyListBoxPeer.SetItems(AValue: TStrings);
begin
  GetDelegate.Items := AValue;
end;

procedure TProxyListBoxPeer.SetSelected(Index: Integer; AValue: Boolean);
begin
  GetDelegate.Selected[Index] := AValue;
end;

procedure TProxyListBoxPeer.SetSorted(AValue: Boolean);
begin
  GetDelegate.Sorted := AValue;
end;

procedure TProxyListBoxPeer.Clear;
begin
  GetDelegate.Clear;
end;

function TProxyListBoxPeer.GetSelectedText: string;
begin
  Result := GetDelegate.GetSelectedText;
end;

function TProxyListBoxPeer.ItemRect(Index: Integer): TRect;
begin
  Result := GetDelegate.ItemRect(Index);
end;

procedure TProxyListBoxPeer.AddListBoxListener(l: IListBoxListener);
begin
  CheckListBoxEvents;
  Self.AddWinControlListener(l);
end;

procedure TProxyListBoxPeer.RemoveListBoxListener(l: IListBoxListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyListBoxPeer.GetListBoxListeners: TListBoxListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TListBoxListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], IListBoxListener) then
        Result.Add(IListBoxListener(FControlListenerList[i]));
end;

{ TProxyComboBoxPeer }

constructor TProxyComboBoxPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FCanvas := nil;
  FDelegateObj := TComboBox.Create(AOwner);
end;

destructor TProxyComboBoxPeer.Destroy;
begin
  if Assigned(FCanvas) then
    FCanvas.Free;
  inherited Destroy;
end;

procedure TProxyComboBoxPeer.CheckComboBoxEvents;
begin
  if GetDelegate.OnChange <> @ComboBoxChangeEvent then
    GetDelegate.OnChange := @ComboBoxChangeEvent;
  if GetDelegate.OnDropDown <> @ComboBoxDropDownEvent then
    GetDelegate.OnDropDown := @ComboBoxDropDownEvent;
  if GetDelegate.OnSelect <> @ComboBoxSelectEvent then
    GetDelegate.OnSelect := @ComboBoxSelectEvent;
end;

function TProxyComboBoxPeer.GetDelegate: TComboBox;
begin
  Result := TComboBox(FDelegateObj);
end;

procedure TProxyComboBoxPeer.ComboBoxChangeEvent(Sender: TObject);
var
  i: Integer;
  cbe: IComboBoxEvent;
  cbl: IComboBoxListener;
begin
  if Assigned(FControlListenerList) then
    begin
      cbe := TComboBoxEvent.Create(Sender, TAComboBox(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IComboBoxListener, cbl) then
          cbl.ComboBoxChange(cbe);
    end;
end;

procedure TProxyComboBoxPeer.ComboBoxDropDownEvent(Sender: TObject);
var
  i: Integer;
  cbe: IComboBoxEvent;
  cbl: IComboBoxListener;
begin
  if Assigned(FControlListenerList) then
    begin
      cbe := TComboBoxEvent.Create(Sender, TAComboBox(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IComboBoxListener, cbl) then
          cbl.ComboBoxDropDown(cbe);
    end;
end;

procedure TProxyComboBoxPeer.ComboBoxSelectEvent(Sender: TObject);
var
  i: Integer;
  cbe: IComboBoxEvent;
  cbl: IComboBoxListener;
begin
  if Assigned(FControlListenerList) then
    begin
      cbe := TComboBoxEvent.Create(Sender, TAComboBox(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IComboBoxListener, cbl) then
          cbl.ComboBoxSelect(cbe);
    end;
end;

function TProxyComboBoxPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyComboBoxPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyComboBoxPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyComboBoxPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyComboBoxPeer.GetBorderStyle: TBorderStyle;
begin
  Result := cm_AWT.TBorderStyle(GetDelegate.BorderStyle);
end;

procedure TProxyComboBoxPeer.SetBorderStyle(AValue: TBorderStyle);
begin
  GetDelegate.BorderStyle := Controls.TBorderStyle(AValue);
end;

function TProxyComboBoxPeer.GetMaxLength: Integer;
begin
  Result := GetDelegate.MaxLength;
end;

function TProxyComboBoxPeer.GetSorted: Boolean;
begin
  Result := GetDelegate.Sorted;
end;

procedure TProxyComboBoxPeer.SetMaxLength(AValue: Integer);
begin
  GetDelegate.MaxLength := AValue;
end;

procedure TProxyComboBoxPeer.SetSorted(AValue: Boolean);
begin
  GetDelegate.Sorted := AValue;
end;

procedure TProxyComboBoxPeer.AddComboBoxListener(l: IComboBoxListener);
begin
  CheckComboBoxEvents;
  Self.AddWinControlListener(l);
end;

procedure TProxyComboBoxPeer.RemoveComboBoxListener(l: IComboBoxListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyComboBoxPeer.GetComboBoxListeners: TComboBoxListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TComboBoxListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], IComboBoxListener) then
        Result.Add(IComboBoxListener(FControlListenerList[i]));
end;

function TProxyComboBoxPeer.GetCanvas: TACanvas;
var
  cp: IACanvasPeer;
begin
  Result := nil;
  if not Assigned(FCanvas) then
    begin
      cp := TProxyCanvasPeer.Create(GetDelegate.Canvas);
      FCanvas := TACanvas.Create(cp);
    end;
  Result := FCanvas;
end;

function TProxyComboBoxPeer.GetDropDownCount: Integer;
begin
  Result := GetDelegate.DropDownCount;
end;

function TProxyComboBoxPeer.GetItemIndex: Integer;
begin
  Result := GetDelegate.ItemIndex;
end;

function TProxyComboBoxPeer.GetItems: TStrings;
begin
  Result := GetDelegate.Items;
end;

function TProxyComboBoxPeer.GetSelLength: Integer;
begin
  Result := GetDelegate.SelLength;
end;

function TProxyComboBoxPeer.GetSelStart: Integer;
begin
  Result := GetDelegate.SelStart;
end;

function TProxyComboBoxPeer.GetSelText: string;
begin
  Result := GetDelegate.SelText;
end;

function TProxyComboBoxPeer.GetStyle: TComboBoxStyle;
begin
  Result := cm_AWT.TComboBoxStyle(GetDelegate.Style);
end;

procedure TProxyComboBoxPeer.SetDropDownCount(AValue: Integer);
begin
  GetDelegate.DropDownCount := AValue;
end;

procedure TProxyComboBoxPeer.SetItemIndex(AValue: Integer);
begin
  GetDelegate.ItemIndex := AValue;
end;

procedure TProxyComboBoxPeer.SetItems(AValue: TStrings);
begin
  GetDelegate.Items := AValue;
end;

procedure TProxyComboBoxPeer.SetSelLength(AValue: Integer);
begin
  GetDelegate.SelLength := AValue;
end;

procedure TProxyComboBoxPeer.SetSelStart(AValue: Integer);
begin
  GetDelegate.SelStart := AValue;
end;

procedure TProxyComboBoxPeer.SetSelText(AValue: string);
begin
  GetDelegate.SelText := AValue;
end;

procedure TProxyComboBoxPeer.SetStyle(AValue: TComboBoxStyle);
begin
  GetDelegate.Style := StdCtrls.TComboBoxStyle(AValue);
end;

procedure TProxyComboBoxPeer.Clear;
begin
  GetDelegate.Clear;
end;

procedure TProxyComboBoxPeer.SelectAll;
begin
  GetDelegate.SelectAll;
end;

{ TProxyLabelPeer }

procedure TProxyLabelPeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

procedure TProxyLabelPeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

constructor TProxyLabelPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TLabel.Create(AOwner);
end;

function TProxyLabelPeer.GetDelegate: TLabel;
begin
  Result := TLabel(FDelegateObj);
end;

function TProxyLabelPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyLabelPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyLabelPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyLabelPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyLabelPeer.GetAlignment: TAlignment;
begin
  Result := GetDelegate.Alignment;
end;

function TProxyLabelPeer.GetLayout: TTextLayout;
begin
  Result := cm_AWT.TTextLayout(GetDelegate.Layout);
end;

procedure TProxyLabelPeer.SetAlignment(AValue: TAlignment);
begin
  GetDelegate.Alignment := AValue;
end;

procedure TProxyLabelPeer.SetLayout(AValue: TTextLayout);
begin
  GetDelegate.Layout := Graphics.TTextLayout(AValue);
end;

{ TProxyPanelPeer }

procedure TProxyPanelPeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

procedure TProxyPanelPeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

constructor TProxyPanelPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TPanel.Create(AOwner);
end;

function TProxyPanelPeer.GetDelegate: TPanel;
begin
  Result := TPanel(FDelegateObj);
end;

function TProxyPanelPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyPanelPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyPanelPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyPanelPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyPanelPeer.GetAlignment: TAlignment;
begin
  Result := GetDelegate.Alignment;
end;

function TProxyPanelPeer.GetBevelColor: TColor;
begin
  Result := GetDelegate.BevelColor;
end;

function TProxyPanelPeer.GetBevelInner: TPanelBevel;
begin
  Result := cm_AWT.TPanelBevel(GetDelegate.BevelInner);
end;

function TProxyPanelPeer.GetBevelOuter: TPanelBevel;
begin
  Result := cm_AWT.TPanelBevel(GetDelegate.BevelOuter);
end;

function TProxyPanelPeer.GetBevelWidth: TBevelWidth;
begin
  Result := GetDelegate.BevelWidth;
end;

procedure TProxyPanelPeer.SetAlignment(AValue: TAlignment);
begin
  GetDelegate.Alignment := AValue;
end;

procedure TProxyPanelPeer.SetBevelColor(AValue: TColor);
begin
  GetDelegate.BevelColor := AValue;
end;

procedure TProxyPanelPeer.SetBevelInner(AValue: TPanelBevel);
begin
  GetDelegate.BevelInner := ExtCtrls.TPanelBevel(AValue);
end;

procedure TProxyPanelPeer.SetBevelOuter(AValue: TPanelBevel);
begin
  GetDelegate.BevelOuter := ExtCtrls.TPanelBevel(AValue);
end;

procedure TProxyPanelPeer.SetBevelWidth(AValue: TBevelWidth);
begin
  GetDelegate.BevelWidth := AValue;
end;

{ TProxyCustomEditPeer }

function TProxyCustomEditPeer.GetDelegate: TCustomEdit;
begin
  Result := TCustomEdit(FDelegateObj);
end;

procedure TProxyCustomEditPeer.EditChangeEvent(Sender: TObject);
var
  i: Integer;
  ee: IEditEvent;
  el: IEditListener;
begin
  if Assigned(FControlListenerList) then
    begin
      ee := TEditEvent.Create(Sender, TACustomEdit(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IEditListener, el) then
          el.EditChanged(ee);
    end;
end;

function TProxyCustomEditPeer.GetBorderStyle: TBorderStyle;
begin
  Result := cm_AWT.TBorderStyle(GetDelegate.BorderStyle);
end;

procedure TProxyCustomEditPeer.SetBorderStyle(AValue: TBorderStyle);
begin
  GetDelegate.BorderStyle := Controls.TBorderStyle(AValue);
end;

procedure TProxyCustomEditPeer.Clear;
begin
  GetDelegate.Clear;
end;

procedure TProxyCustomEditPeer.SelectAll;
begin
  GetDelegate.SelectAll;
end;

function TProxyCustomEditPeer.GetMaxLength: Integer;
begin
  Result := GetDelegate.MaxLength;
end;

function TProxyCustomEditPeer.GetNumbersOnly: Boolean;
begin
  Result := GetDelegate.NumbersOnly;
end;

function TProxyCustomEditPeer.GetPasswordChar: Char;
begin
  Result := GetDelegate.PasswordChar;
end;

function TProxyCustomEditPeer.GetReadOnly: Boolean;
begin
  Result := GetDelegate.ReadOnly;
end;

function TProxyCustomEditPeer.GetSelLength: integer;
begin
  Result := GetDelegate.SelLength;
end;

function TProxyCustomEditPeer.GetSelStart: integer;
begin
  Result := GetDelegate.SelStart;
end;

function TProxyCustomEditPeer.GetSelText: String;
begin
  Result := GetDelegate.SelText;
end;

procedure TProxyCustomEditPeer.SetMaxLength(AValue: Integer);
begin
  GetDelegate.MaxLength := AValue;
end;

procedure TProxyCustomEditPeer.SetNumbersOnly(AValue: Boolean);
begin
  GetDelegate.NumbersOnly := AValue;
end;

procedure TProxyCustomEditPeer.SetPasswordChar(AValue: Char);
begin
  GetDelegate.PasswordChar := AValue;
end;

procedure TProxyCustomEditPeer.SetReadOnly(AValue: Boolean);
begin
  GetDelegate.ReadOnly := AValue;
end;

procedure TProxyCustomEditPeer.SetSelLength(AValue: integer);
begin
  GetDelegate.SelLength := AValue;
end;

procedure TProxyCustomEditPeer.SetSelStart(AValue: integer);
begin
  GetDelegate.SelStart := AValue;
end;

procedure TProxyCustomEditPeer.SetSelText(AValue: String);
begin
  GetDelegate.SelText := AValue;
end;

procedure TProxyCustomEditPeer.AddEditListener(l: IEditListener);
begin
  if GetDelegate.OnChange <> @EditChangeEvent then
    GetDelegate.OnChange := @EditChangeEvent;
  Self.AddWinControlListener(l);
end;

procedure TProxyCustomEditPeer.RemoveEditListener(l: IEditListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyCustomEditPeer.GetEditListeners: TEditListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TEditListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], IEditListener) then
        Result.Add(IEditListener(FControlListenerList[i]));
end;

{ TProxyEditPeer }

procedure TProxyEditPeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

procedure TProxyEditPeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

constructor TProxyEditPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TEdit.Create(AOwner);
end;

function TProxyEditPeer.GetDelegate: TEdit;
begin
  Result := TEdit(FDelegateObj);
end;

function TProxyEditPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyEditPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyEditPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyEditPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

{ TProxyMemoPeer }

procedure TProxyMemoPeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

procedure TProxyMemoPeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

constructor TProxyMemoPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TMemo.Create(AOwner);
end;

function TProxyMemoPeer.GetDelegate: TMemo;
begin
  Result := TMemo(FDelegateObj);
end;

function TProxyMemoPeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyMemoPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyMemoPeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyMemoPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyMemoPeer.GetLines: TStrings;
begin
  Result := GetDelegate.Lines;
end;

function TProxyMemoPeer.GetScrollBars: TScrollStyle;
begin
  Result := cm_AWT.TScrollStyle(GetDelegate.ScrollBars);
end;

procedure TProxyMemoPeer.SetLines(AValue: TStrings);
begin
  GetDelegate.Lines := AValue;
end;

procedure TProxyMemoPeer.SetScrollBars(AValue: TScrollStyle);
begin
  GetDelegate.ScrollBars := StdCtrls.TScrollStyle(AValue);
end;

{ TProxyFormPeer }

procedure TProxyFormPeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

constructor TProxyFormPeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TForm.Create(AOwner);
  TForm(FDelegateObj).KeyPreview := True;
end;

function TProxyFormPeer.GetDelegate: TForm;
begin
  Result := TForm(FDelegateObj);
end;

procedure TProxyFormPeer.FormActivateEvent(Sender: TObject);
var
  i: Integer;
  fe: IFormEvent;
  fl: IFormListener;
begin
  if Assigned(FControlListenerList) then
    begin
      fe := TFormEvent.Create(Sender, TAForm(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IFormListener, fl) then
          fl.FormActivate(fe);
    end;
end;

procedure TProxyFormPeer.FormCloseEvent(Sender: TObject; var CloseAction: TCloseAction);
var
  i: Integer;
  fe: IFormEvent;
  fl: IFormListener;
begin
  if Assigned(FControlListenerList) then
    begin
      fe := TFormEvent.Create(Sender, TAForm(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IFormListener, fl) then
          fl.FormClose(fe);
    end;
end;

procedure TProxyFormPeer.FormDeactivateEvent(Sender: TObject);
var
  i: Integer;
  fe: IFormEvent;
  fl: IFormListener;
begin
  if Assigned(FControlListenerList) then
    begin
      fe := TFormEvent.Create(Sender, TAForm(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IFormListener, fl) then
          fl.FormDeactivate(fe);
    end;
end;

procedure TProxyFormPeer.FormHideEvent(Sender: TObject);
var
  i: Integer;
  fe: IFormEvent;
  fl: IFormListener;
begin
  if Assigned(FControlListenerList) then
    begin
      fe := TFormEvent.Create(Sender, TAForm(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IFormListener, fl) then
          fl.FormHide(fe);
    end;
end;

procedure TProxyFormPeer.FormShowEvent(Sender: TObject);
var
  i: Integer;
  fe: IFormEvent;
  fl: IFormListener;
begin
  if Assigned(FControlListenerList) then
    begin
      fe := TFormEvent.Create(Sender, TAForm(Self.FTargetObj));
      for i:=0 to FControlListenerList.Count-1 do
        if Supports(FControlListenerList[i], IFormListener, fl) then
          fl.FormShow(fe);
    end;
end;

function TProxyFormPeer.GetParentColor: Boolean;
begin
  // Form ParentColor 未公开
  Result := False;
end;

function TProxyFormPeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyFormPeer.SetParentColor(AValue: Boolean);
begin
  // Form ParentColor 未公开
end;

procedure TProxyFormPeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

function TProxyFormPeer.GetFormBorderStyle: TFormBorderStyle;
begin
  Result := cm_AWT.TFormBorderStyle(GetDelegate.BorderStyle);
end;

procedure TProxyFormPeer.SetFormBorderStyle(AValue: TFormBorderStyle);
begin
  GetDelegate.BorderStyle := Controls.TFormBorderStyle(AValue);
end;

procedure TProxyFormPeer.Close;
begin
  GetDelegate.Close;
end;

function TProxyFormPeer.ShowModal: Integer;
begin
  Result := GetDelegate.ShowModal;
end;

procedure TProxyFormPeer.CheckFormControlEvents;
begin
  if GetDelegate.OnActivate <> @FormActivateEvent then
    GetDelegate.OnActivate := @FormActivateEvent;
  if GetDelegate.OnClose <> @FormCloseEvent then
    GetDelegate.OnClose := @FormCloseEvent;
  if GetDelegate.OnDeactivate <> @FormDeactivateEvent then
    GetDelegate.OnDeactivate := @FormDeactivateEvent;
  if GetDelegate.OnHide <> @FormHideEvent then
    GetDelegate.OnHide := @FormHideEvent;
  if GetDelegate.OnShow <> @FormShowEvent then
    GetDelegate.OnShow := @FormShowEvent;
end;

procedure TProxyFormPeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

procedure TProxyFormPeer.AddFormListener(l: IFormListener);
begin
  CheckFormControlEvents;
  Self.AddCustomControlListener(l);
end;

procedure TProxyFormPeer.RemoveFormListener(l: IFormListener);
begin
  Self.RemoveControlListener(l);
end;

function TProxyFormPeer.GetFormListeners: TFormListenerList;
var
  i: Integer;
begin
  // TODO 线程安全
  Result := TFormListenerList.Create;
  if Assigned(FControlListenerList) then
    for i:=0 to FControlListenerList.Count-1 do
      if Supports(FControlListenerList[i], IFormListener) then
        Result.Add(IFormListener(FControlListenerList[i]));
end;

{ TProxyFramePeer }

procedure TProxyFramePeer.RegisterControlEvents;
begin
  inherited RegisterControlEvents;
  GetDelegate.OnDblClick := @ControlDblClickEvent;
end;

procedure TProxyFramePeer.RegisterMouseEvents;
begin
  inherited RegisterMouseEvents;
  GetDelegate.OnMouseDown := @MouseDownEvent;
  GetDelegate.OnMouseUp := @MouseUpEvent;
  GetDelegate.OnMouseEnter := @MouseEnterEvent;
  GetDelegate.OnMouseLeave := @MouseLeaveEvent;
  GetDelegate.OnMouseMove := @MouseMoveEvent;
  GetDelegate.OnMouseWheel:= @MouseWheelEvent;
end;

constructor TProxyFramePeer.Create(TheTarget: TAComponent; AOwner: TComponent);
begin
  inherited Create(TheTarget, AOwner);
  FDelegateObj := TFrame.Create(AOwner);
end;

function TProxyFramePeer.GetDelegate: TFrame;
begin
  Result := TFrame(FDelegateObj);
end;

function TProxyFramePeer.GetParentColor: Boolean;
begin
  Result := GetDelegate.ParentColor;
end;

function TProxyFramePeer.GetParentFont: Boolean;
begin
  Result := GetDelegate.ParentFont;
end;

procedure TProxyFramePeer.SetParentColor(AValue: Boolean);
begin
  GetDelegate.ParentColor := AValue;
end;

procedure TProxyFramePeer.SetParentFont(AValue: Boolean);
begin
  GetDelegate.ParentFont := AValue;
end;

{$i extctrls_proxy.inc}



initialization
  TProxyControlPeer.FControlPeerList := TFPList.Create;

finalization
  TProxyControlPeer.FControlPeerList.Free;

end.

