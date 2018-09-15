unit cm_cmstp;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils,
  cm_interfaces, cm_generics,
  cm_net,
  cm_parameter,
  cm_ParameterUtils,
  cm_servlet;


type

  ICMSTPService = interface(ICMBase)
    ['{5B139E17-51B5-44B2-9045-E563EEEBB66B}']
    function CMSTP(const AURL: string; ARequestParameters: ICMConstantParameterDataList; out TheResponseContent: ICMConstantParameterDataList): Boolean;
  end;

  { TCMSTPURLConnection }  //TODO 连接未有响应时，响应体为空的情况；是否请求成功的标识
  TCMSTPURLConnection = class(TURLConnection)
  private

  public
    constructor Create(const AURL: string); override;
    procedure Connect; override;
  end;

  { IServletContainer
        这是一个 servlet 容器接口
    用于动态配置 servlet 应用时先行放入容器，后继可以依据配置的 code 找到相应的 servlet。
    由此，也意味着对于一个 servlet 应具有唯一的 code，这个 code 仅仅用于辨别无其他意义。
  }
  IServletCollection = interface(ICMBase)
    ['{04970409-8397-4A99-9BE6-EB46638B66BB}']
    function Add(const ACode: string; AServlet: IServlet): Boolean;
    function Remove(const ACode: string): IServlet;
  end;

  { TServletCollection }

  TServletCollection = class(TCMBase, IServletCollection)
  private
    FList: TCMHashInterfaceList<IServlet>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(const ACode: string; AServlet: IServlet): Boolean;
    function Remove(const ACode: string): IServlet;
  end;

var
  CMSTPService: ICMSTPService = nil;

implementation

{ TCMSTPURLConnection }

constructor TCMSTPURLConnection.Create(const AURL: string);
begin
  inherited Create(AURL);
  FRequestParameters := TCMParameterDataList.Create;
end;

procedure TCMSTPURLConnection.Connect;
begin
  FResponseContent := nil;
  if Assigned(CMSTPService) then
    begin
      CMSTPService.CMSTP(URL, FRequestParameters, FResponseContent);
    end;
end;

{ TServletCollection }

constructor TServletCollection.Create;
begin
  FList := TCMHashInterfaceList<IServlet>.Create;
end;

destructor TServletCollection.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TServletCollection.Add(const ACode: string; AServlet: IServlet): Boolean;
begin
  Result := FList.Add(ACode, AServlet) >= 0;
end;

function TServletCollection.Remove(const ACode: string): IServlet;
begin
  Result := FList.Find(ACode);
end;

end.
