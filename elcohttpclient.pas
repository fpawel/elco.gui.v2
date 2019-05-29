unit elcohttpclient;

interface

uses superobject, System.sysutils;

type
    ERemoteError = class(Exception);

function GetResponse(method: string; params: ISuperobject): ISuperobject;

implementation

uses registry, System.Net.HttpClient, winapi.windows,
    ujsonrpc,  classes, System.Net.URLClient;

function _httpaddr: string;
var
    key: TRegistry;
begin
    key := TRegistry.Create(KEY_READ);
    try
        if not key.OpenKey('elco\http', False) then
            raise Exception.Create('cant open elco\http');
        result := key.ReadString('addr');
    finally
        key.CloseKey;
        key.Free;
    end;
end;

function formatMessagetype(mt: TJsonRpcObjectType): string;
begin
    case mt of
        jotInvalid:
            exit('invalid');
        jotRequest:
            exit('request');
        jotNotification:
            exit('notification');
        jotSuccess:
            exit('success');
        jotError:
            exit('error');
    end;
end;

function GetResponse(method: string; params: ISuperobject): ISuperobject;
var
    HttpClient: THTTPClient;
    requestStream: TStringStream;
    response: IHTTPResponse;
    headers: TNetHeaders;
    JsonRpcParsedResponse: IJsonRpcParsed;
    rx: ISuperObject;
begin
    try

        HttpClient := THTTPClient.Create();

        SetLength(headers, 2);
        headers[0].Name := 'Content-Type';
        headers[0].Value := 'application/json';
        headers[1].Name := 'Accept';
        headers[1].Value := 'application/json';

        requestStream := TStringStream.Create(TJsonRpcMessage.request(0, method,
          params).AsJSon);

        response := HttpClient.Post(_httpaddr + '/rpc', requestStream,
          nil, headers);

        if response.StatusCode <> 200 then
            raise Exception.Create(Inttostr(response.StatusCode) + ': ' +
              response.StatusText);

        JsonRpcParsedResponse := TJsonRpcMessage.Parse
          (response.ContentAsString);

        if not Assigned(JsonRpcParsedResponse) then
            raise Exception.Create(Format('%s%s: unexpected nil response',
              [method, params.AsString]));

        if not Assigned(JsonRpcParsedResponse.GetMessagePayload) then
            raise Exception.Create
              (Format('%s%s: unexpected nil message payload',
              [method, params.AsString]));

        rx := JsonRpcParsedResponse.GetMessagePayload.AsJsonObject;

        if Assigned(rx['result']) then
        begin
            result := rx['result'];
            exit;
        end;

        if Assigned(rx['error.message']) then
            raise ERemoteError.Create(rx['error'].S['message']);

        raise Exception.Create(Format('%s%s'#13'%s'#13'message type: %s',
              [method, params.AsString, JsonRpcParsedResponse.GetMessagePayload,
              formatMessagetype(JsonRpcParsedResponse.GetMessageType)]));

    finally
        HttpClient.Free;
        requestStream.Free;
    end;
end;

end.
