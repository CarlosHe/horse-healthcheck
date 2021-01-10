unit Horse.HealthCheck.Manager;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.Threading,
  Horse.Commons,
  Horse.HealthCheck.Result,
  Horse.HealthCheck.Helpers,
  Horse.HealthCheck.Contract,
  Horse.HealthCheck.Options;

type

  THorseHealthCheckManager = class
  private
    { private declarations }
    FHealthCheckObjectList: TObjectDictionary<string, IHorseHealthCheck>;
    FHorseHealthCheckOptions: THorseHealthCheckOptions;
    class var FDefaultManager: THorseHealthCheckManager;
  protected
    { protected declarations }
    class function GetDefaultManager: THorseHealthCheckManager; static;
    function GetDefaultList: TObjectDictionary<string, IHorseHealthCheck>;
    function GetHorseHealthCheckOptions: THorseHealthCheckOptions;
    procedure SetHorseHealthCheckOptions(AHorseHealthCheckOptions: THorseHealthCheckOptions);
    procedure ProcessResponseStatus(var AStatusCode: THTTPStatus; AHealthyCount, ADegradedCount, AUnhealthyCount: Integer);
    function FutureCheck(AHorseHealthCheck: IHorseHealthCheck; ACheckName: string): IFuture<TJsonObject>;
    procedure GetCheckHealth(var AStatusCode: THTTPStatus; var AJsonObjectCheckHealth: TJsonObject);
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    class function CheckHealth(var AStatusCode: THTTPStatus; var AJsonObjectCheckHealth: TJsonObject): THorseHealthCheckManager;
    class function SetOptions(AOptions: THorseHealthCheckOptions): THorseHealthCheckManager;
    class function GetOptions(out AOptions: THorseHealthCheckOptions): THorseHealthCheckManager;
    class function AddCheck(ACheckName: string; AHorseHealthCheckResult: THorseHealthCheckResult): THorseHealthCheckManager; overload;
    class function AddCheck<T: constructor, IHorseHealthCheck>(ACheckName: string): THorseHealthCheckManager; overload;
    class function RemoveCheck(ACheckName: string): THorseHealthCheckManager;
    class function CheckCount: Integer;
    class destructor UnInitialize;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  System.SyncObjs,
  Horse.HealthCheck.Builder,
  Horse.HealthCheck,
  Horse.HealthCheck.Types;

{ THorseHealthCheckManager }

class function THorseHealthCheckManager.AddCheck(ACheckName: string; AHorseHealthCheckResult: THorseHealthCheckResult): THorseHealthCheckManager;
var
  LHorseHealthCheck: IHorseHealthCheck;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  LHorseHealthCheck := THorseHealthCheckBuilder.Create(AHorseHealthCheckResult);
  THorseHealthCheckManager.GetDefaultManager.GetDefaultList.AddOrSetValue(ACheckName, LHorseHealthCheck);
end;

class function THorseHealthCheckManager.AddCheck<T>(ACheckName: string): THorseHealthCheckManager;
var
  LHorseHealthCheck: IHorseHealthCheck;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  LHorseHealthCheck := T.Create;
  THorseHealthCheckManager.GetDefaultManager.GetDefaultList.AddOrSetValue(ACheckName, LHorseHealthCheck);
end;

class function THorseHealthCheckManager.CheckCount: Integer;
begin
  Result := THorseHealthCheckManager.GetDefaultManager.GetDefaultList.Count;
end;

class function THorseHealthCheckManager.CheckHealth(var AStatusCode: THTTPStatus; var AJsonObjectCheckHealth: TJsonObject): THorseHealthCheckManager;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  THorseHealthCheckManager.GetDefaultManager.GetCheckHealth(AStatusCode, AJsonObjectCheckHealth);
end;

constructor THorseHealthCheckManager.Create;
begin
  FHealthCheckObjectList := TObjectDictionary<string, IHorseHealthCheck>.Create([]);
  FHorseHealthCheckOptions := THorseHealthCheckOptions.Create;
end;

function THorseHealthCheckManager.FutureCheck(AHorseHealthCheck: IHorseHealthCheck; ACheckName: string): IFuture<TJsonObject>;
var
  LHorseHealthCheck: IHorseHealthCheck;
  LCheckName: string;
begin
  LHorseHealthCheck := AHorseHealthCheck;
  LCheckName := ACheckName;
  Result := TTask.Future<TJsonObject>(
    function: TJsonObject
    var
      LStartAt: TDateTime;
      LFinishAt: TDateTime;
      LJsonObjectCheckHealth: TJsonObject;
      LJsonObjectResult: TJsonObject;
      LHorseHealthCheckResult: THorseHealthCheckResult;
    begin
      LJsonObjectResult := TJsonObject.Create;
      Result := LJsonObjectResult;
      try
        LStartAt := Now();
        LHorseHealthCheckResult := AHorseHealthCheck.CheckHealth;
        LFinishAt := Now();
        LJsonObjectCheckHealth := LHorseHealthCheckResult.ToJson;
        LJsonObjectCheckHealth.AddPair('duration', FormatDateTime('hh:nn:ss:zzz', LFinishAt - LStartAt));
        LJsonObjectResult.AddPair(ACheckName, LJsonObjectCheckHealth);
      finally
        FreeAndNil(LHorseHealthCheckResult);
      end;
    end
    );

end;

destructor THorseHealthCheckManager.Destroy;
begin
  FreeAndNil(FHealthCheckObjectList);
  if FHorseHealthCheckOptions <> nil then
    FreeAndNil(FHorseHealthCheckOptions);
  inherited;
end;

procedure THorseHealthCheckManager.GetCheckHealth(var AStatusCode: THTTPStatus; var AJsonObjectCheckHealth: TJsonObject);
var
  LCheckList: TDictionary<string, IHorseHealthCheck>;
  LJsonArrayResult: TJsonArray;
  LCheckListKeyCollection: TArray<string>;
  LFutureList: TList<ITask>;
  I: Integer;
  LHealthyCount: Integer;
  LDegradedCount: Integer;
  LUnhealthyCount: Integer;
  LFutureResult: TJsonObject;
  LFutureCheck: IFuture<TJsonObject>;
begin
  LJsonArrayResult := TJsonArray.Create;
  AJsonObjectCheckHealth.AddPair('health_check', LJsonArrayResult);
  LCheckList := GetDefaultList;
  LHealthyCount := 0;
  LDegradedCount := 0;
  LUnhealthyCount := 0;

  LFutureList := TList<ITask>.Create;
  try
    LCheckListKeyCollection := LCheckList.Keys.ToArray;
    for I := Low(LCheckListKeyCollection) to High(LCheckListKeyCollection) do
    begin
      LFutureCheck := FutureCheck(LCheckList.Items[LCheckListKeyCollection[I]], LCheckListKeyCollection[I]);
      LFutureList.Add(
        LFutureCheck
        );
    end;

    TTask.WaitForAll(LFutureList.ToArray);

    for I := 0 to Pred(LFutureList.Count) do
    begin
      LFutureResult := IFuture<TJsonObject>(LFutureList.Items[I]).Value;

      LJsonArrayResult.Add(
        LFutureResult
        );

      case StringToHorseHealthStatus(LFutureResult.Pairs[0].JsonValue.GetValue<string>('status')) of
        THorseHealthStatus.Healthy:
          Inc(LHealthyCount);
        THorseHealthStatus.Degraded:
          Inc(LDegradedCount);
        THorseHealthStatus.Unhealthy:
          Inc(LUnhealthyCount);
      end;
    end;

    ProcessResponseStatus(AStatusCode, LHealthyCount, LDegradedCount, LUnhealthyCount);

  finally
    LFutureList.Free;
  end;

end;

function THorseHealthCheckManager.GetDefaultList: TObjectDictionary<string, IHorseHealthCheck>;
begin
  Result := FHealthCheckObjectList;
end;

class function THorseHealthCheckManager.GetDefaultManager: THorseHealthCheckManager;
begin
  if FDefaultManager = nil then
    FDefaultManager := THorseHealthCheckManager.Create;
  Result := FDefaultManager;
end;

function THorseHealthCheckManager.GetHorseHealthCheckOptions: THorseHealthCheckOptions;
begin
  Result := FHorseHealthCheckOptions;
end;

class function THorseHealthCheckManager.GetOptions(out AOptions: THorseHealthCheckOptions): THorseHealthCheckManager;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  AOptions := THorseHealthCheckManager.GetDefaultManager.GetHorseHealthCheckOptions;
end;

class function THorseHealthCheckManager.SetOptions(AOptions: THorseHealthCheckOptions): THorseHealthCheckManager;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  THorseHealthCheckManager.GetDefaultManager.SetHorseHealthCheckOptions(AOptions);
end;

procedure THorseHealthCheckManager.ProcessResponseStatus(var AStatusCode: THTTPStatus; AHealthyCount, ADegradedCount, AUnhealthyCount: Integer);
var
  LResultStatusCodes: TResultStatusCodes;
begin
  THorseHealthCheckManager.GetDefaultManager.GetHorseHealthCheckOptions.GetResultStatusCodes(LResultStatusCodes);
  if (AUnhealthyCount = 0) and (ADegradedCount = 0) then
    LResultStatusCodes.TryGetValue(THorseHealthStatus.Healthy, AStatusCode)
  else if (AHealthyCount = 0) then
    LResultStatusCodes.TryGetValue(THorseHealthStatus.Unhealthy, AStatusCode)
  else
    LResultStatusCodes.TryGetValue(THorseHealthStatus.Degraded, AStatusCode)
end;

class function THorseHealthCheckManager.RemoveCheck(ACheckName: string): THorseHealthCheckManager;
begin
  Result := THorseHealthCheckManager.GetDefaultManager;
  THorseHealthCheckManager.GetDefaultManager.GetDefaultList.Remove(ACheckName);
end;

procedure THorseHealthCheckManager.SetHorseHealthCheckOptions(AHorseHealthCheckOptions: THorseHealthCheckOptions);
begin
  if FHorseHealthCheckOptions <> nil then
    FreeAndNil(FHorseHealthCheckOptions);
  FHorseHealthCheckOptions := AHorseHealthCheckOptions;
end;

class destructor THorseHealthCheckManager.UnInitialize;
begin
  FreeAndNil(FDefaultManager);
end;

end.
