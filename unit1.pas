unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Buttons, Grids, HlpHashFactory, HlpCRC32Fast, HlpIHash,
  Clipbrd, EditBtn, IniPropStorage, Menus, Types, INIFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    LabeledEdit1: TLabeledEdit;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckGroup1Click(Sender: TObject);
    procedure CheckGroup1ItemClick(Sender: TObject; Index: integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure StringGrid2MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: integer);
    procedure HashFile(filename: string);
    function getFileHash(filename: string; algo: string): string;
    procedure CopyOnSelectSave(Sender: TObject);
    procedure StringGrid2Selection(Sender: TObject; aCol, aRow: integer);
    procedure StringGrid3CellProcess(Sender: TObject; aCol, aRow: integer;
      processType: TCellProcessType; var aValue: string);
    procedure StringGrid3Click(Sender: TObject);
    procedure StringGrid3DrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid3MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure StringGrid3Selection(Sender: TObject; aCol, aRow: integer);

  private

  public

  end;

const
  _config = '.gethash/gethash.conf';

var
  Form1: TForm1;
  max_checked: shortint;

implementation

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin

  //Button1.Caption := THashFactory.TCrypto.CreateTiger_5_192().ComputeString('Fish', TEncoding.UTF8).ToString();
  //  Button1.Caption := THashFactory.TCrypto.CreateGOST3411_2012_256().ComputeFile('/tmp/LibreOffice-mate').ToString();

end;

procedure TForm1.CopyOnSelectSave(Sender: TObject);
var
  _ini: TIniFile;
begin
  _ini := TIniFile.Create(GetUserDir + PathDelim + _config);
  if Checkbox1.Checked then
    _ini.WriteString('Settings', 'CopyOnSelect', '1')
  else
    _ini.WriteString('Settings', 'CopyOnSelect', '0');
  _ini.Free;
end;

procedure TForm1.StringGrid2Selection(Sender: TObject; aCol, aRow: integer);
var
  Clipboard: TClipboard;
begin
  if CheckBox1.Checked and (StringGrid2.Cells[aCol, aRow] <> '') then
  begin
    Clipboard := TClipboard.Create();
    ClipBoard.AsText := StringGrid2.Cells[aCol, aRow];
    StatusBar1.SimpleText := 'скопировано в буфер ' +
      StringGrid2.Cells[aCol, aRow] + '';
  end;
end;


procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  CopyOnSelectSave(Sender);
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
var
  _ini: TIniFile;
begin
  _ini := TIniFile.Create(GetUserDir + PathDelim + _config);
  if CheckBox2.Checked then
    _ini.WriteBool('Settings', 'SaveCSV', True)
  else
    _ini.WriteBool('Settings', 'SaveCSV', False);
  _ini.Free;
end;

procedure TForm1.CheckGroup1Click(Sender: TObject);
begin
  StringGrid1.Clear;
  StringGrid2.Clear;
  StringGrid3.Clear;
end;

procedure TForm1.CheckGroup1ItemClick(Sender: TObject; Index: integer);
var
  _ini: TIniFile;
  i: shortint;
begin
  _ini := TIniFile.Create(GetUserDir + PathDelim + _config);
  if CheckGroup1.Checked[Index] then
    _ini.WriteString('Hashes', CheckGroup1.Items.Strings[Index], '1')
  else
    _ini.WriteString('Hashes', CheckGroup1.Items.Strings[Index], '0');
  _ini.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: shortint;
  _ini: TIniFile;
begin
  _ini := TIniFile.Create(GetUserDir + PathDelim + _config);

  for i := 0 to CheckGroup1.Items.Count - 1 do
  begin
    if CheckGroup1.Checked[i] then
      _ini.WriteString('Hashes', CheckGroup1.Items.Strings[i], '1')
    else
      _ini.WriteString('Hashes', CheckGroup1.Items.Strings[i], '0');
  end;

  _ini.WriteBool('Settings', 'CopyOnSelect', CheckBox1.Checked);
  _ini.WriteBool('Settings', 'SaveCSV', CheckBox2.Checked);
  _ini.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  _ini: TINIFile;
  i: shortint;
  hashes: array of string;
  _hashes_name: TStringList;
begin
  if FileExists(GetUserDir + PathDelim + _config) then
  begin
    //заполним из конфига
    _ini := TIniFile.Create(GetUserDir + PathDelim + _config);

    _hashes_name := TStringList.Create;
    _ini.ReadSectionValues('Hashes', _hashes_name);
    _hashes_name.Sort;

    CheckBox1.Checked := _ini.ReadBool('Settings', 'CopyOnSelect', True);

    for i := 0 to _hashes_name.Count - 1 do

      if _hashes_name.Strings[i].Split(['='])[1] = '1' then
      begin
        CheckGroup1.Checked[i] := True;
      end;

    _hashes_name.Free;

    max_checked := 0;
    for i := 0 to CheckGroup1.Items.Count - 1 do
    begin
      if CheckGroup1.Checked[i] then
        Inc(max_checked, 1);
    end;

    CheckBox2.Checked := _ini.ReadBool('Settings', 'SaveCSV', True);
    stringGrid1.Clear;
    stringGrid2.Clear;
    stringGrid3.Clear;
    StringGrid3.ColCount := max_checked + 1;
    _ini.Free;
  end
  else
  begin
    CheckBox1.Checked := True;
    CheckBox2.Checked := True;
    // just for fun
    CheckGroup1.Checked[0]:=true;
    CheckGroup1.Checked[1]:=true;
  end;

end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
  sendername: string;
begin

  sendername := ActiveControl.Name;
  // Application.MessageBox(pchar(sendername),'',0);
  //sendername:=TComponent(Sender).GetParentComponent.name;
  case sendername of
    'StringGrid1':
    begin
      SaveDialog1.FileName := 'gethash.csv';
      if SaveDialog1.Execute then
        if CheckBox2.Checked then
          StringGrid1.SaveToCSVFile(SaveDialog1.FileName, ';', True)
        else
          StringGrid1.SaveToFile(SaveDialog1.FileName);
    end;

    'StringGrid2':
    begin
      SaveDialog1.FileName := 'gethash.csv';
      if SaveDialog1.Execute then

      begin
        StringGrid2.InsertRowWithValues(0, [edit1.Text]);
        if CheckBox2.Checked then
          StringGrid2.SaveToCSVFile(SaveDialog1.FileName, ';', True)
        else
          StringGrid2.SaveToFile(SaveDialog1.FileName);

        StringGrid2.DeleteRow(0);
      end;
    end;

    'StringGrid3':
    begin
      SaveDialog1.FileName := 'gethash.csv';
      if SaveDialog1.Execute then
        if CheckBox2.Checked then
          StringGrid3.SaveToCSVFile(SaveDialog1.FileName, ';', True)
        else
          StringGrid3.SaveToFile(SaveDialog1.FileName);
    end;

  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
var
  i: byte;
  r: byte;
  hash_str: string;
  crc32: ihash;
begin
  if LabeledEdit1.Text = '' then exit;
  StringGrid1.Clear;
  for i := 0 to CheckGroup1.Items.Count - 1 do
  begin
    if CheckGroup1.Checked[i] then
      //  StringGrid1.ColCount:=2;

    begin
      case CheckGroup1.Items.Strings[i] of
        'MD5':
          hash_str := THashFactory.TCrypto.CreateMD5().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'SHA1':
          hash_str := THashFactory.TCrypto.CreateSHA1().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'SHA256':
          hash_str := THashFactory.TCrypto.CreateSHA2_256().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'SHA512':
          hash_str := THashFactory.TCrypto.CreateSHA2_512().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'GOST R34.11-94':
          hash_str := THashFactory.TCrypto.CreateGost().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'GOST R 34.11-2012 256':
          hash_str := THashFactory.TCrypto.CreateGOST3411_2012_256().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'GOST R 34.11-2012 512':
          hash_str := THashFactory.TCrypto.CreateGOST3411_2012_512().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'CRC32':
          hash_str := THashFactory.TChecksum.TCRC.CreateCRC32_PKZIP().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'BLAKE2B 512':
          hash_str := THashFactory.TCrypto.CreateBlake2B_512().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'BLAKE2s 256':
          hash_str := THashFactory.TCrypto.CreateBlake2S_256().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'SHA3-256':
          hash_str := THashFactory.TCrypto.CreateSHA3_256().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();
        'SHA3-512':
          hash_str := THashFactory.TCrypto.CreateSHA3_512().ComputeString(
            LabeledEdit1.Text, TEncoding.UTF8).ToString();

      end;

      StringGrid1.InsertRowWithValues(0, [CheckGroup1.Items.Strings[i], hash_str]);

      StringGrid1.ColWidths[1] := 600;
{     StringGrid1.ColCount:=2;
     StringGrid1.Cells[0,r]:=CheckGroup1.Items.Strings[i];
//     StringGrid1.Cells[1,r]
     StringGrid1.Cells[1,r]:='hash here';
     ;//CheckGroup1.Items[i];
 }
    end;
  end;
end;

procedure TForm1.PageControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin

end;

procedure TForm1.HashFile(filename: string);
var
  hash_str: string;
  i: shortint;
begin

  StringGrid2.Clear;
  ProgressBar1.Position := 0;
  ProgressBar1.Visible := True;
  SpeedButton1.Enabled := False;

  for i := 0 to CheckGroup1.Items.Count - 1 do
  begin
    ProgressBar1.Max := max_checked;
    if CheckGroup1.Checked[i] then
      //  StringGrid1.ColCount:=2;

    begin
      Application.ProcessMessages;
      StatusBar1.SimpleText :=
        'Идет обработка: ' + CheckGroup1.Items.Strings[i];
     {case CheckGroup1.Items.Strings[i] of
     'MD5':
           hash_str:= THashFactory.TCrypto.CreateMD5().ComputeFile(OpenDialog1.FileName).ToString();
     'SHA1':
           hash_str:= THashFactory.TCrypto.CreateSHA1().ComputeFile(OpenDialog1.FileName).ToString();
     'SHA256':
           hash_str:= THashFactory.TCrypto.CreateSHA2_256().ComputeFile(OpenDialog1.FileName).ToString();
     'SHA512':
              hash_str:= THashFactory.TCrypto.CreateSHA2_512().ComputeFile(OpenDialog1.FileName).ToString();
     'GOST R34.11-94':
           hash_str:= THashFactory.TCrypto.CreateGost().ComputeFile(OpenDialog1.FileName).ToString();
     'GOST R 34.11-2012 256':
                hash_str:= THashFactory.TCrypto.CreateGOST3411_2012_256().ComputeFile(OpenDialog1.FileName).ToString();
     'GOST R 34.11-2012 512':
                hash_str:= THashFactory.TCrypto.CreateGOST3411_2012_512().ComputeFile(OpenDialog1.FileName).ToString();
     'CRC32':
                hash_str:=THashFactory.TChecksum.TCRC.CreateCRC32_PKZIP().ComputeFile(OpenDialog1.FileName).ToString();
     'BLAKE2B 512':
                hash_str:= THashFactory.TCrypto.CreateBlake2B_512().ComputeFile(OpenDialog1.FileName).ToString();
     'BLAKE2s 256':
                hash_str:= THashFactory.TCrypto.CreateBlake2S_256().ComputeFile(OpenDialog1.FileName).ToString();
     'SHA3-256':
                hash_str:= THashFactory.TCrypto.CreateSHA3_256().ComputeFile(OpenDialog1.FileName).ToString();
     'SHA3-512':
                hash_str:= THashFactory.TCrypto.CreateSHA3_512().ComputeFile(OpenDialog1.FileName).ToString();

     end;}
      hash_str := getFileHash(OpenDialog1.FileName, CheckGroup1.Items.Strings[i]);

      ProgressBar1.Position := ProgressBar1.Position + 1;
      StringGrid2.InsertRowWithValues(0, [CheckGroup1.Items.Strings[i], hash_str]);
      StringGrid2.ColWidths[1] := 600;

    end;

  end;

  StatusBar1.SimpleText := 'Подсчет закончен';
  SpeedButton1.Enabled := True;
  ProgressBar1.Visible := False;

end;

procedure TForm1.StringGrid3CellProcess(Sender: TObject; aCol, aRow: integer;
  processType: TCellProcessType; var aValue: string);
begin

end;

procedure TForm1.StringGrid3Click(Sender: TObject);
begin

end;

procedure TForm1.StringGrid3DrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if StringGrid3.RowCount > 1 then
    SpeedButton5.Enabled := True
  else
    SpeedButton5.Enabled := False;
end;

procedure TForm1.StringGrid3MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  Col, Row: integer;
begin
  StringGrid2.MouseToCell(X, Y, Col, Row);
  if (Row >= 0) and (Col >= 0) and (StringGrid2.Hint <>
    StringGrid2.Cells[Col, Row]) then
  begin
    Application.CancelHint;
    StringGrid2.Hint := StringGrid2.Cells[Col, Row];
  end;
end;

procedure TForm1.StringGrid3Selection(Sender: TObject; aCol, aRow: integer);
var
  clipboard: TClipboard;
begin
  if (CheckBox1.Checked) and (aCol >= 1) and (StringGrid3.Cells[aCol, aRow] <> '') then
  begin
    Clipboard := TClipboard.Create();
    ClipBoard.AsText := StringGrid3.Cells[aCol, aRow];
    StatusBar1.SimpleText := 'скопировано в буфер ' +
      StringGrid3.Cells[aCol, aRow] + '';
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Edit1.Caption := OpenDialog1.FileName;
    HashFile(OpenDialog1.FileName);
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  oldOptions: TOpenOptions;
  i: integer;
  hashes: array of string;
begin

  StringGrid3.FixedCols := 0;
  StringGrid3.RowCount := 1;


  SetLength(hashes, 1);
  hashes[0] := 'Filename';

  for i := 0 to CheckGroup1.Items.Count - 1 do
  begin
    if CheckGroup1.Checked[i] then
      SetLength(hashes, Length(hashes) + 1);
    hashes[High(hashes)] := CheckGroup1.Items.Strings[i];
  end;

  //StringGrid3.Row:=Length(hashes)+1;

  StringGrid3.InsertRowWithValues(0, hashes);

  oldOptions := OpenDialog1.Options;
  OpenDialog1.Options := [ofAllowMultiSelect, ofEnableSizing, ofViewDetail];
  if OpenDialog1.Execute then
  begin

    for i := 0 to OpenDialog1.Files.Count - 1 do
    begin
      StringGrid3.InsertRowWithValues(1, [OpenDialog1.Files[i]]);
    end;
  end;

  StringGrid3.FixedRows := 1;
  StringGrid3.RowCount := OpenDialog1.Files.Count + 1;

  OpenDialog1.Options := oldOptions;
  SpeedButton3.Enabled := True;
  SpeedButton4.Enabled := True;

end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  StringGrid3.DeleteRow(StringGrid3.row);
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  StringGrid3.Clear;
  SpeedButton3.Enabled := False;
  SpeedButton4.Enabled := False;
  SpeedButton5.Enabled := False;

end;

function TForm1.getFileHash(filename: string; algo: string): string;
var
  hash_str: string;
begin

  case algo of
    'MD5':
      hash_str := THashFactory.TCrypto.CreateMD5().ComputeFile(filename).ToString();
    'SHA1':
      hash_str := THashFactory.TCrypto.CreateSHA1().ComputeFile(filename).ToString();
    'SHA256':
      hash_str := THashFactory.TCrypto.CreateSHA2_256().ComputeFile(
        filename).ToString();
    'SHA512':
      hash_str := THashFactory.TCrypto.CreateSHA2_512().ComputeFile(
        filename).ToString();
    'GOST R34.11-94':
      hash_str := THashFactory.TCrypto.CreateGost().ComputeFile(filename).ToString();
    'GOST R 34.11-2012 256':
      hash_str := THashFactory.TCrypto.CreateGOST3411_2012_256().ComputeFile(
        filename).ToString();
    'GOST R 34.11-2012 512':
      hash_str := THashFactory.TCrypto.CreateGOST3411_2012_512().ComputeFile(
        filename).ToString();
    'CRC32':
      hash_str := THashFactory.TChecksum.TCRC.CreateCRC32_PKZIP().ComputeFile(
        filename).ToString();
    'BLAKE2B 512':
      hash_str := THashFactory.TCrypto.CreateBlake2B_512().ComputeFile(
        filename).ToString();
    'BLAKE2s 256':
      hash_str := THashFactory.TCrypto.CreateBlake2S_256().ComputeFile(
        filename).ToString();
    'SHA3-256':
      hash_str := THashFactory.TCrypto.CreateSHA3_256().ComputeFile(
        filename).ToString();
    'SHA3-512':
      hash_str := THashFactory.TCrypto.CreateSHA3_512().ComputeFile(
        filename).ToString();

  end;
  Result := hash_str;
end;


procedure TForm1.SpeedButton5Click(Sender: TObject);
var
  x, i: integer;
begin
  ProgressBar1.Visible := True;
  ProgressBar1.Max := StringGrid3.RowCount - 1;

  for i := 1 to StringGrid3.RowCount - 1 do
  begin
    // Application.MessageBox(pchar(inttostr(i)),'',0);

    //имя файла

    ProgressBar1.Position := ProgressBar1.Position + 1;
    for x := 1 to StringGrid3.ColCount - 1 do
    begin
      Application.ProcessMessages;
      StatusBar1.SimpleText :=
        'Идет обработка файла: ' +
        ExtractFileName(StringGrid3.Cells[0, i]) + ' (' + StringGrid3.Cells[x, 0] + ')';
      StringGrid3.Cells[x, i] :=
        getFileHash(StringGrid3.Cells[0, i], StringGrid3.Cells[x, 0]);
    end;

  end;
  ProgressBar1.Visible := False;
  StatusBar1.SimpleText := 'Обработка закончена';

end;

procedure TForm1.StringGrid2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  Row: integer;
  Col: integer;
begin
  StringGrid2.MouseToCell(X, Y, Col, Row);
  if (Row >= 0) and (Col >= 0) and (StringGrid2.Hint <>
    StringGrid2.Cells[Col, Row]) then
  begin
    Application.CancelHint;
    StringGrid2.Hint := StringGrid2.Cells[Col, Row];
  end;
end;

procedure TForm1.StringGrid1Selection(Sender: TObject; aCol, aRow: integer);
var
  Clipboard: TClipboard;
begin
  if CheckBox1.Checked then
  begin
    Clipboard := TClipboard.Create();
    ClipBoard.AsText := StringGrid1.Cells[aCol, aRow];
    StatusBar1.SimpleText := 'скопировано в буфер ' +
      StringGrid1.Cells[aCol, aRow] + '';

  end;
end;

initialization
  {$I unit1.lrs}

end.
