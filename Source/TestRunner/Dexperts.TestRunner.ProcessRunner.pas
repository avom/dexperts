unit Dexperts.TestRunner.ProcessRunner;

interface

uses
  Dexperts.TestRunner.Interfaces;

type
  TProcessRunner = class(TInterfacedObject, IProcessRunner)
  public
    function ExecAndCapture(const ACmdLine: string; var AOutput: string): Integer;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

type
  TAnoPipe = record
    Input: THandle;
    Output: THandle;
  end;

// Original source: https://gist.github.com/hotsoft-desenv2/bed7a75bbe19f19b163d2059fe85c57e
function TProcessRunner.ExecAndCapture(const ACmdLine: string; var AOutput: string): Integer;
const
  cBufferSize = 2048;
var
  vBuffer: Pointer;
  vStartupInfo: TStartUpInfo;
  vSecurityAttributes: TSecurityAttributes;
  vReadBytes: DWord;
  vProcessInfo: TProcessInformation;
  vStdInPipe : TAnoPipe;
  vStdOutPipe: TAnoPipe;
begin
  Result := 0;

  with vSecurityAttributes do
  begin
    nlength := SizeOf(TSecurityAttributes);
    binherithandle := True;
    lpsecuritydescriptor := nil;
  end;

  // Create anonymous pipe for standard input
  if not CreatePipe(vStdInPipe.Output, vStdInPipe.Input, @vSecurityAttributes, 0) then
    raise Exception.Create('Failed to create pipe for standard input. System error message: ' + SysErrorMessage(GetLastError));

  try
    // Create anonymous pipe for standard output (and also for standard error)
    if not CreatePipe(vStdOutPipe.Output, vStdOutPipe.Input, @vSecurityAttributes, 0) then
      raise Exception.Create('Failed to create pipe for standard output. System error message: ' + SysErrorMessage(GetLastError));

    try
      GetMem(vBuffer, cBufferSize);
      try
        // initialize the startup info to match our purpose
        FillChar(vStartupInfo, Sizeof(TStartUpInfo), #0);
        vStartupInfo.cb         := SizeOf(TStartUpInfo);
        vStartupInfo.wShowWindow:= SW_HIDE;  // we don't want to show the process
        // assign our pipe for the process' standard input
        vStartupInfo.hStdInput  := vStdInPipe.Output;
        // assign our pipe for the process' standard output
        vStartupInfo.hStdOutput := vStdOutPipe.Input;
        vStartupInfo.dwFlags    := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;

        var lCmdLine := ACmdLine;
        UniqueString(lCmdLine);
        if not CreateProcess(nil
                             , PWideChar(lCmdLine)
                             , @vSecurityAttributes
                             , @vSecurityAttributes
                             , True
                             , NORMAL_PRIORITY_CLASS
                             , nil
                             , nil
                             , vStartupInfo
                             , vProcessInfo) then
          raise Exception.Create('Failed creating the console process. System error msg: ' + SysErrorMessage(GetLastError));

        try
          // wait until the console program terminated
          while WaitForSingleObject(vProcessInfo.hProcess, 50)=WAIT_TIMEOUT do
            Sleep(0);

          // clear the output storage
          AOutput := '';
          // Read text returned by the console program in its StdOut channel
          repeat
            ReadFile(vStdOutPipe.Output, vBuffer^, cBufferSize, vReadBytes, nil);
            if vReadBytes > 0 then
            begin
              var Chunk: string;
              SetString(Chunk, PAnsiChar(vBuffer), vReadBytes);
              AOutput := AOutput + Chunk;
              Inc(Result, vReadBytes);
            end;
          until (vReadBytes < cBufferSize);
        finally
          CloseHandle(vProcessInfo.hProcess);
          CloseHandle(vProcessInfo.hThread);
        end;
      finally
        FreeMem(vBuffer);
      end;
    finally
      CloseHandle(vStdOutPipe.Input);
      CloseHandle(vStdOutPipe.Output);
    end;
  finally
    CloseHandle(vStdInPipe.Input);
    CloseHandle(vStdInPipe.Output);
  end;
end;

end.

