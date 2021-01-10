# horse-healthcheck
Middleware for health check in HORSE

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/CarlosHe/horse-healthcheck
```

## Sample Horse HealthCheck
```delphi
uses Horse, Horse.HealthCheck;

begin
  THorse.Use('/healthcheck', HorseHealthCheck);

  THorseHealthCheckManager
    .AddCheck(
      'ping',
      THorseHealthCheckResult.Healthy(
        'basic ping-pong health check'
      )
    );
    
  THorse.Listen(9000);
end.
```

#### HealthCheck json result

**By calling the route /healthcheck, you will result in the following structure**

```json
{
    "health_check": [
        {
            "ping": {
                "status": "Healthy",
                "description": "basic ping-pong health check",
                "exception": null,
                "data": {},
                "duration": "00:00:00:000"
            }
        }
    ]
}
```

## Other methods of use

### You can also create a class and implement the IHorseHealthCheck interface

**Defining the class in THorseHealthCheckManager**

```delphi
uses Horse, Horse.HealthCheck;

begin
  THorse.Use('/healthcheck', HorseHealthCheck);

  THorseHealthCheckManager
    .AddCheck<THorseHealthCheckPing>('ping');

  THorse.Listen(9000);
end.
```

**Implementation of the IHorseHealthCheck interface**

```delphi
unit Horse.HealthCheck.Ping;

interface

uses
  Horse.HealthCheck;

type

  THorseHealthCheckPing = class(TInterfacedObject, IHorseHealthChecker)
  public
    { public declarations }
    function CheckHealth: THorseHealthCheckResult;
  end;

implementation

{ THorseHealthCheckPing }

function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(
    THorseHealthStatus.Healthy,
    'basic ping-pong health check'
  );
end;

end.
```

## Knowing the structure of THorseHealthCheckResult

### Some ways to create the result, see some examples:

**creating a Healthy result with description:**
```delphi
function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Healthy('description');
end;
```

**creating a Unhealthy result with description:**
```delphi
function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Healthy('description');
end;
```

**creating a Degraded result with description:**
```delphi
function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Degraded('description');
end;
```

**or using Create and passing the status with description:**
```delphi
function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(THorseHealthStatus.Healthy, 'description');
end;
```

## You can also pass in the method arguments some extra information

```delphi
function THorseHealthCheckPing.CheckHealth: THorseHealthCheckResult;
var
  LExtraJsonData: TJsonObject;
begin
  LExtraJsonData := TJsonObject.Create;

  LExtraJsonData.AddPair('extra', 'data');

  Result := THorseHealthCheckResult.Create(
    THorseHealthStatus.Degraded,
    'basic ping-pong health check',
    Exception.Create('Degraded'),
    LExtraJsonData
  );
end;
```

#### HealthCheck json result

```json

{
    "health_check": [
        {
            "ping": {
                "status": "Degraded",
                "description": "basic ping-pong health check",
                "exception": "Degraded",
                "data": {
                    "extra": "data"
                },
                "duration": "00:00:00:000"
            }
        }
    ]
}

```
