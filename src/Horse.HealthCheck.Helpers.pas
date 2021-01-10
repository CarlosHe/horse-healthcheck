unit Horse.HealthCheck.Helpers;

interface

uses
  System.JSON,
  Horse.HealthCheck.Types,
  Horse.HealthCheck.Result;

type

  THorseHealthStatusHelper = record helper for THorseHealthStatus
    function ToString: string;
  end;

  THorseHealthCheckResultHelper = class helper for THorseHealthCheckResult
    function ToJSON: TJsonObject;
  end;

function StringToHorseHealthStatus(AStatusString: string): THorseHealthStatus;

implementation

uses System.TypInfo;

{ THealthStatusHelper }

function StringToHorseHealthStatus(AStatusString: string): THorseHealthStatus;
begin
  Result := THorseHealthStatus(GetEnumValue(TypeInfo(THorseHealthStatus), AStatusString));
end;

function THorseHealthStatusHelper.ToString: string;
begin
  Result := GetEnumName(TypeInfo(THorseHealthStatus), Integer(Self));
end;

{ THealthCheckResultHelper }

function THorseHealthCheckResultHelper.ToJSON: TJsonObject;
var
  LJsonObject: TJsonObject;
begin
  LJsonObject := TJsonObject.Create;

  try
    LJsonObject.AddPair('status', Self.Status.ToString);

    LJsonObject.AddPair('description', Self.Description);

    if Self.Exception <> nil then
      LJsonObject.AddPair('exception', Self.Exception.Message)
    else
      LJsonObject.AddPair('exception', TJSONNull.Create);

    if Self.Data <> nil then
      LJsonObject.AddPair('data', Self.Data)
    else
      LJsonObject.AddPair('data', TJsonObject.Create);

  finally
    Result := LJsonObject;
  end;

end;

end.
