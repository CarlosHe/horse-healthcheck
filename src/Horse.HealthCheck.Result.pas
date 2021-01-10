unit Horse.HealthCheck.Result;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  Horse.HealthCheck.Types;

type

  THorseHealthCheckResult = class
  private
    { private declarations }
    FStatus: THorseHealthStatus;
    FDescription: string;
    FException: Exception;
    FData: TJsonObject;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AStatus: THorseHealthStatus; const ADescription: string = ''; const AException: Exception = nil; const AData: TJsonObject = nil);
    class function Degraded(const ADescription: string = ''; const AException: Exception = nil; const AData: TJsonObject = nil): THorseHealthCheckResult;
    class function Healthy(const ADescription: string = ''; const AData: TJsonObject = nil): THorseHealthCheckResult;
    class function Unhealthy(const ADescription: string = ''; const AException: Exception = nil; const AData: TJsonObject = nil): THorseHealthCheckResult;
    property Status: THorseHealthStatus read FStatus;
    property Description: string read FDescription;
    property Exception: Exception read FException;
    property Data: TJsonObject read FData;
  end;

implementation


{ THealthCheckResult }

constructor THorseHealthCheckResult.Create(AStatus: THorseHealthStatus; const ADescription: string; const AException: Exception; const AData: TJsonObject);
begin
  FStatus := AStatus;
  FDescription := ADescription;
  FException := AException;
  FData := AData;
end;

class function THorseHealthCheckResult.Degraded(const ADescription: string; const AException: Exception; const AData: TJsonObject): THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(THorseHealthStatus.Degraded, ADescription, AException, AData);
end;

class function THorseHealthCheckResult.Healthy(const ADescription: string; const AData: TJsonObject): THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(THorseHealthStatus.Healthy, ADescription, nil, AData);
end;

class function THorseHealthCheckResult.Unhealthy(const ADescription: string; const AException: Exception; const AData: TJsonObject): THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(THorseHealthStatus.Unhealthy, ADescription, AException, AData);
end;

end.
