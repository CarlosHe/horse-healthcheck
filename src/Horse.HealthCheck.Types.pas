unit Horse.HealthCheck.Types;

{$SCOPEDENUMS ON}

interface

uses
  Horse.Commons,
  System.Generics.Collections;

type

  THorseHealthStatus = (Healthy, Degraded, Unhealthy);
  TResultStatusCodes = TDictionary<THorseHealthStatus, THTTPStatus>;

implementation

end.
