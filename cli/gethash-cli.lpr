program gethash_cli;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  StrUtils,
  LazFileUtils,
  HlpHashFactory { you can add units after this };

type

  { TMyGetHashCli }

  TMyGetHashCli = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure WriteMsg(_msg: string);
    procedure ComputeHash(_filenames: array of string; algo: string); virtual;
    procedure CleanParams(_filenames: array of string; _algo: string);
    //        function CheckParams(_filenames: array of string; _algo: string): boolean;
    procedure ListAlgo;
  end;

  { TMyGetHashCli }

const
  algos: array [0..43] of string = (
    'BLAKE2B_256',
    'BLAKE2B_512',
    'BLAKE2S_128',
    'BLAKE2S_256',
    'GOST',
    'GOST3411_2012_256',
    'GOST3411_2012_512',
    'HAVAL_3_128',
    'HAVAL_4_128',
    'HAVAL_5_128',
    'KECCAK_224',
    'KECCAK_256',
    'KECCAK_288',
    'KECCAK_384',
    'KECCAK_512',
    'MD5',
    'RIPEMD_128',
    'RIPEMD_160',
    'RIPEMD_256',
    'RIPEMD_320',
    'SHA1',
    'SHA2_256',
    'SHA2_512',
    'SHA3_224',
    'SHA3_256',
    'SHA3_512',
    'TIGER2_3_128',
    'TIGER2_3_160',
    'TIGER2_3_192',
    'TIGER2_4_128',
    'TIGER2_4_160',
    'TIGER2_4_192',
    'TIGER2_5_128',
    'TIGER2_5_160',
    'TIGER2_5_192',
    'TIGER3_128',
    'TIGER3_160',
    'TIGER3_192',
    'TIGER4_128',
    'TIGER4_160',
    'TIGER4_192',
    'TIGER5_128',
    'TIGER5_160',
    'TIGER5_192'
    );

var
  allgood: boolean;
  valid_filenames: array of string;

  procedure TMyGetHashCli.DoRun;
  var
    ErrorMsg: string;
    sr: TSearchRec;
    _filename, _algo, _value, _folder: string;
    _filenames: array of string;
    x, y, z: word;
  begin
    // quick check parameters
    OptionChar := '-';
    ErrorMsg := CheckOptions('hlaf', 'help list algo file');
    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;
    // parse parameters

    if HasOption('l', 'list') then
    begin
      ListAlgo;
      Terminate;
      Exit;
    end;

    if HasOption('h', 'help') or
      ((not HasOption('a', 'algo') or not HasOption('f', 'file'))) then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    {$IFDEF LINUX}
    for x := 1 to ParamCount do
    begin
      if (y = 1) then
      begin
        SetLength(_filenames, Length(_filenames) + 1);
        _filenames[High(_filenames)] := ParamStr(x);
      end;
      if (ParamStr(x) = '-f') or (ParamStr(x) = '--file') then y := 1;
    end;
    {$ENDIF}


    {$IFDEF WINDOWS}

    x := 1;
    while x <= ParamCount do
    begin

      _value := ParamStr(x);
      Inc(x);
      if ((_value = '-f') or (_value = '--file')) then
      begin
        _value := ParamStr(x);
        Inc(x);
        if (Pos('*', _value) <> 0) or (Pos('?', _value) <> 0) then
        begin
          _folder :=ExtractFilePath(_value);
          //writeln('FOLDER'+_folder+'jj');
          if FindFirst(_value, faAnyFile, sr) = 0 then
          try
            repeat
              if (sr.Name <> '.') and (sr.Name <> '..')
                and
                ((sr.Attr and faDirectory) = 0)
                then
              begin
               // writeln('loop:'+sr.Name);
                SetLength(_filenames, Length(_filenames) + 1);
                _filenames[High(_filenames)] := _folder + sr.Name;
                //files.Add(folder + sr.Name);
              end;
            until FindNext(sr) <> 0;
          finally
            FindClose(sr);
          end;
        end
        else
        begin
         // writeln('notloop:'+_value);
          SetLength(_filenames, Length(_filenames) + 1);
          _filenames[High(_filenames)] := _value;
          //files.Add(_value);
          while x <= ParamCount do
          begin
            _value := ParamStr(x);
            if _value[1] = '-' then Break;
            Inc(x);
          end;
        end;
      end;

    end;




    {$ENDIF}
  {     for x:=Low(_filenames) to High(_filenames) do
    begin
      writeln (_filenames[x]);
    end;
   }

    _algo := GetOptionValue('a', 'algo');

    if (HasOption('a', 'algo') and HasOption('f', 'file')) then
    begin
      CleanParams(_filenames, _algo);
      if allgood then

        ComputeHash(valid_filenames, _algo);

    end;

    { add your program here }


    // stop program loop
    Terminate;
  end;

  constructor TMyGetHashCli.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TMyGetHashCli.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TMyGetHashCli.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExtractFileNameOnly(ExeName),
      ' [PARAMETER(S)]… [FILE(S)]' + LineEnding + 'Print checksums.' +
      LineEnding + LineEnding + '  -h, --help      this help' +
      LineEnding + '  -l, --list      list all algorithms' + LineEnding +
      '  -a  --algo      specify the algorithm used' + LineEnding +
      '  -f  --file      file or files for proccesing' + LineEnding + LineEnding +
      'Report any bugs to https://github.com/x09/gethash');
  end;


  procedure TMyGetHashCli.WriteMsg(_msg: string);
  begin
    { add your code here }
    writeln('Msg: ' + _msg);
    Terminate;
  end;

  procedure TMyGetHashCli.ListAlgo;
  var
    x: byte;
  begin
    writeln('Supported algoritms:');
    for x := 0 to High(algos) do
    begin
      Writeln(IntToStr(x + 1) + ') ' + algos[x]);
    end;

  end;

  procedure TMyGetHashCli.ComputeHash(_filenames: array of string; algo: string);
  var
    x: byte;
    hash: string;
  begin
    for x := Low(_filenames) to High(_filenames) do
    begin

      case algo.ToLower of
        'md5':
          hash := THashFactory.TCrypto.CreateMD5().ComputeFile(_filenames[x]).ToString();
        'sha1':
          hash := THashFactory.TCrypto.CreateSHA1().ComputeFile(
            _filenames[x]).ToString();
        'sha256':
          hash := THashFactory.TCrypto.CreateSHA2_256().ComputeFile(
            _filenames[x]).ToString();
        'sha512':
          hash := THashFactory.TCrypto.CreateSHA2_512().ComputeFile(
            _filenames[x]).ToString();
        'gost':
          hash := THashFactory.TCrypto.CreateGost().ComputeFile(
            _filenames[x]).ToString();
        'gost3411_2012_256':
          hash := THashFactory.TCrypto.CreateGOST3411_2012_256().ComputeFile(
            _filenames[x]).ToString();
        'gost3411_2012_512':
          hash := THashFactory.TCrypto.CreateGOST3411_2012_512().ComputeFile(
            _filenames[x]).ToString();
        'ctc32':
          hash := THashFactory.TChecksum.TCRC.CreateCRC32_PKZIP().ComputeFile(
            _filenames[x]).ToString();
        'blake2b_512':
          hash := THashFactory.TCrypto.CreateBlake2B_512().ComputeFile(
            _filenames[x]).ToString();
        'blake2s_256':
          hash := THashFactory.TCrypto.CreateBlake2S_256().ComputeFile(
            _filenames[x]).ToString();
        'sha3_256':
          hash := THashFactory.TCrypto.CreateSHA3_256().ComputeFile(
            _filenames[x]).ToString();
        'sha3_512':
          hash := THashFactory.TCrypto.CreateSHA3_512().ComputeFile(
            _filenames[x]).ToString();
        // added 12/09
        'sha3_224':
          hash := THashFactory.TCrypto.CreateSHA3_224().ComputeFile(
            _filenames[x]).ToString();

        'blake2b_256':
          hash := THashFactory.TCrypto.CreateBlake2B_256().ComputeFile(
            _filenames[x]).ToString();
        'blake2s_128':
          hash := THashFactory.TCrypto.CreateBlake2S_128().ComputeFile(
            _filenames[x]).ToString();

        'tiger2_3_128':
          hash := THashFactory.TCrypto.CreateTiger2_3_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_3_160':
          hash := THashFactory.TCrypto.CreateTiger2_3_160().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_3_192':
          hash := THashFactory.TCrypto.CreateTiger2_3_192().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_4_128':
          hash := THashFactory.TCrypto.CreateTiger2_4_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_4_160':
          hash := THashFactory.TCrypto.CreateTiger2_4_160().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_4_192':
          hash := THashFactory.TCrypto.CreateTiger2_4_192().ComputeFile(
            _filenames[x]).ToString();

        'tiger2_5_128':
          hash := THashFactory.TCrypto.CreateTiger2_5_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_5_160':
          hash := THashFactory.TCrypto.CreateTiger2_5_160().ComputeFile(
            _filenames[x]).ToString();
        'tiger2_5_192':
          hash := THashFactory.TCrypto.CreateTiger2_5_192().ComputeFile(
            _filenames[x]).ToString();

        'tiger3_128':
          hash := THashFactory.TCrypto.CreateTiger_3_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger3_160':
          hash := THashFactory.TCrypto.CreateTiger_3_160().ComputeFile(
            _filenames[x]).ToString();
        'tiger3_192':
          hash := THashFactory.TCrypto.CreateTiger_3_192().ComputeFile(
            _filenames[x]).ToString();


        'tiger4_128':
          hash := THashFactory.TCrypto.CreateTiger_4_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger4_160':
          hash := THashFactory.TCrypto.CreateTiger_4_160().ComputeFile(
            _filenames[x]).ToString();
        'tiger4_192':
          hash := THashFactory.TCrypto.CreateTiger_4_192().ComputeFile(
            _filenames[x]).ToString();


        'tiger5_128':
          hash := THashFactory.TCrypto.CreateTiger_5_128().ComputeFile(
            _filenames[x]).ToString();
        'tiger5_160':
          hash := THashFactory.TCrypto.CreateTiger_5_160.ComputeFile(
            _filenames[x]).ToString();
        'tiger5_192':
          hash := THashFactory.TCrypto.CreateTiger_5_192().ComputeFile(
            _filenames[x]).ToString();


        'keccak_224':
          hash := THashFactory.TCrypto.CreateKeccak_224().ComputeFile(
            _filenames[x]).ToString();

        'keccak_256':
          hash := THashFactory.TCrypto.CreateKeccak_256().ComputeFile(
            _filenames[x]).ToString();

        'keccak_288':
          hash := THashFactory.TCrypto.CreateKeccak_288().ComputeFile(
            _filenames[x]).ToString();

        'keccak_384':
          hash := THashFactory.TCrypto.CreateKeccak_384().ComputeFile(
            _filenames[x]).ToString();

        'keccak_512':
          hash := THashFactory.TCrypto.CreateKeccak_512().ComputeFile(
            _filenames[x]).ToString();


        'ripemd_128':
          hash := THashFactory.TCrypto.CreateRIPEMD128().ComputeFile(
            _filenames[x]).ToString();

        'ripemd_256':
          hash := THashFactory.TCrypto.CreateRIPEMD256().ComputeFile(
            _filenames[x]).ToString();

        'ripemd_160':
          hash := THashFactory.TCrypto.CreateRIPEMD160().ComputeFile(
            _filenames[x]).ToString();
        'ripemd_320':
          hash := THashFactory.TCrypto.CreateRIPEMD320().ComputeFile(
            _filenames[x]).ToString();


        'haval_3_128':
          hash := THashFactory.TCrypto.CreateHaval_3_128().ComputeFile(
            _filenames[x]).ToString();

        'haval_4_128':
          hash := THashFactory.TCrypto.CreateHaval_4_128().ComputeFile(
            _filenames[x]).ToString();

        'haval_5_128':
          hash := THashFactory.TCrypto.CreateHaval_5_128().ComputeFile(
            _filenames[x]).ToString();

      end;

      WriteLn(hash + ' ' + _filenames[x]);
    end;
  end;


  procedure TMyGetHashCli.CleanParams(_filenames: array of string; _algo: string);
  var
    x: word;
  begin

    for x := Low(_filenames) to High(_filenames) do
    begin
      if (not (FileExists(_filenames[x])) or not
        (lazfileutils.FileIsReadable(_filenames[x]))) then
      begin
        WriteMsg('File ' + _filenames[x] +
          ' not found or not readable. Will be ignored');
      end
      else
      begin
        SetLength(valid_filenames, Length(valid_filenames) + 1);
        valid_filenames[High(valid_filenames)] := _filenames[x];
      end;

    end;

    if (not (_algo.ToUpper in algos)) then
    begin
      WriteMsg('Unknow algo name: ' + _algo);
      allgood := False;
    end
    else
      allgood := True;

  end;


var
  Application: TMyGetHashCli;

{$R *.res}

begin
  Application := TMyGetHashCli.Create(nil);
  Application.Title := 'gethash-cli';
  Application.Run;
  Application.Free;
end.

