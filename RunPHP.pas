unit RunPHP;

interface

uses
  SysUtils, Forms, Classes, Windows;

type
  TInputRequestCallback = function(var data: AnsiString): boolean of object;
  TOutputNotifyCallback = function(const output: AnsiString): boolean of object;
  TRunCodeExplorer = class(TThread)
  private
    FInputRequestCallback: TInputRequestCallback;
    FOutputNotifyCallback: TOutputNotifyCallback;
    FInputWaiting: AnsiString;
    FInputWasSuccessful: boolean;
    FOutputWaiting: AnsiString;
    FOutputWasSuccessful: boolean;
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
  Output, OutputLastCache: string;
const
  SIGNAL_END_OF_TRANSMISSION = #1#2#3#4#5#6#7#8;
  SIGNAL_TERMINATE           = #8#7#6#5#4#3#2#1;
begin
  if Self.WorkDir = '' then
    WorkDir := ExtractFilePath(ParamStr(0))
  else
    WorkDir := Self.WorkDir;

  if not FileExists(Self.PhpExe) then exit;
  if not FileExists(Self.PhpFile) then exit;

  CommandLine := '"'+Self.PhpExe+'" "'+Self.PhpFile+'"';

  Output := '';
  OutputLastCache := '';
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

            if not FInputWasSuccessful then
            begin
              Sleep(100);
              continue;
            end;

            // Attention: This call will block if the process exited
            WriteFile(StdInPipeWrite, FInputWaiting[1], Length(FInputWaiting), BytesWritten, nil);
          end;
          {$ENDREGION}

          {$REGION 'Terminate input sequence'}
          testString := #13#10+SIGNAL_END_OF_TRANSMISSION+#13#10;
          WriteFile(StdInPipeWrite, testString[1], Length(testString), BytesWritten, nil);
          {$ENDREGION}

          {$REGION 'Gather output'}
          Output := '';
          repeat
            WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
            if BytesRead > 0 then
            begin
              Buffer[BytesRead] := #0;
              Output := Output + Buffer;
              if Pos(SIGNAL_END_OF_TRANSMISSION, Output) >= 1 then
              begin
                Output := StringReplace(Output, SIGNAL_END_OF_TRANSMISSION, '', []);
                break;
              end;
            end;
          until not WasOK or (BytesRead = 0) or Self.Terminated or not ProcessRunning(PI);
          {$ENDREGION}

          {$REGION 'Notify main thread about output'}
          if Assigned(FOutputNotifyCallback) and (OutputLastCache <> Output) and not Self.Terminated and ProcessRunning(PI) then
          begin
            FOutputWaiting := Output;
            Synchronize(CallOutputNotifyCallback);
            if FOutputWasSuccessful then
            begin
              OutputLastCache := Output;
            end;
          end;
          {$ENDREGION}
        end;

        // Signal the code explorer to terminate
        testString := #13#10+SIGNAL_TERMINATE+#13#10;
        WriteFile(StdInPipeWrite, testString[1], Length(testString), BytesWritten, nil);
        WaitForSingleObject(PI.hProcess, INFINITE);

        CloseHandle(StdInPipeWrite);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
    CloseHandle(StdInPipeRead);
  end;
end;

{synchron} procedure TRunCodeExplorer.CallInputRequestCallback;
begin
  FInputWasSuccessful := FInputRequestCallback(FInputWaiting);
end;

{synchron} procedure TRunCodeExplorer.CallOutputNotifyCallback;
begin
  FOutputWasSuccessful := FOutputNotifyCallback(FOutputWaiting);
end;

end.
