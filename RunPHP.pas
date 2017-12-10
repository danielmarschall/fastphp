unit RunPHP;

interface

uses
  SysUtils, Forms, Classes, Windows;

type
  TInputRequestCallback = function: string of object;
  TOutputNotifyCallback = procedure(const output: string) of object;
  TRunCodeExplorer = class(TThread)
  private
    FInputRequestCallback: TInputRequestCallback;
    FOutputNotifyCallback: TOutputNotifyCallback;
    FInputWaiting: string;
    FOutputWaiting: string;
  protected
    procedure CallInputRequestCallback;
    procedure CallOutputNotifyCallback;
  public
    PhpExe: string;
    PhpFile: string;
    WorkDir: string;
    property InputRequestCallback: TInputRequestCallback read FInputRequestCallback write FInputRequestCallback;
    property OutputNotifyCallback: TOutputNotifyCallback read FOutputNotifyCallback write FOutputNotifyCallback;
    procedure Execute; override;
  end;

implementation

procedure TRunCodeExplorer.Execute;

  function ProcessRunning(PI: TProcessInformation): boolean; inline;
  var
    exitcode: Cardinal;
  begin
    result := GetExitCodeProcess(PI.hProcess, exitcode) and (exitcode = STILL_ACTIVE);
  end;

var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  StdInPipeRead, StdInPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead, BytesWritten: Cardinal;
  WorkDir: string;
  Handle: Boolean;
  testString: AnsiString;
  CommandLine: string;
  result: string;
begin
  if Self.WorkDir = '' then
    WorkDir := ExtractFilePath(ParamStr(0))
  else
    WorkDir := Self.WorkDir;

  if not FileExists(Self.PhpExe) then exit;
  if not FileExists(Self.PhpFile) then exit;

  CommandLine := '"'+Self.PhpExe+'" "'+Self.PhpFile+'"';

  Result := '';
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  CreatePipe(StdInPipeRead, StdInPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := StdInPipeRead;
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;

    Handle := CreateProcess(nil, PChar('cmd.exe /C "' + CommandLine + '"'),
                            nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);

    sleep(100);

    if Handle then
      try
        while not Self.Terminated and ProcessRunning(PI) do
        begin
          {$REGION 'Get input from mainthread'}
          if Assigned(FInputRequestCallback) then
          begin
            Synchronize(CallInputRequestCallback);

            // Attention: This call will block if the process exited
            WriteFile(StdInPipeWrite, FInputWaiting[1], Length(FInputWaiting), BytesWritten, nil);
          end;
          {$ENDREGION}

          {$REGION 'Terminate input sequence'}
          testString := #13#10#1#2#3#4#5#6#7#8#13#10;
          WriteFile(StdInPipeWrite, testString[1], Length(testString), BytesWritten, nil);
          {$ENDREGION}

          {$REGION 'Gather output'}
          result := '';
          repeat
            WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
            if BytesRead > 0 then
            begin
              Buffer[BytesRead] := #0;
              Result := Result + Buffer;
              if Pos(#1#2#3#4#5#6#7#8, result) >= 1 then
              begin
                result := StringReplace(result, #1#2#3#4#5#6#7#8, '', []);
                break;
              end;
            end;
          until not WasOK or (BytesRead = 0) or Self.Terminated or not ProcessRunning(PI);
          {$ENDREGION}

          {$REGION 'Notify main thread about output'}
          if Assigned(FOutputNotifyCallback) and not Self.Terminated and ProcessRunning(PI) then
          begin
            FOutputWaiting := result;
            Synchronize(CallOutputNotifyCallback);
          end;
          {$ENDREGION}
        end;

        CloseHandle(StdInPipeWrite);
        TerminateProcess(pi.hProcess, 0);  // TODO: for some reason, after closing the editor, php.exe keeps running in the task list
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
    CloseHandle(StdInPipeRead);
  end;
end;

procedure TRunCodeExplorer.CallInputRequestCallback;
begin
  FInputWaiting := FInputRequestCallback;
end;

procedure TRunCodeExplorer.CallOutputNotifyCallback;
begin
  FOutputNotifyCallback(FOutputWaiting);
end;

end.
