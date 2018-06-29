unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,
  SeekAndReplace,
  IniFiles,
  avDataBase,
  avHash,
  wait,
  Crc32,
  XPMan,
  DCPblockciphers, DCPrijndael, DCPsha512, DCPcrypt2, Buttons;

type
  TDBCreate = class(TForm)
    DBListView: TListView;
    grp1: TGroupBox;
    pb1: TProgressBar;
    btn2: TSpeedButton;
    mmo1: TMemo;
    btn3: TSpeedButton;
    btn4: TSpeedButton;
    mmo2: TMemo;
    UPD: TCheckBox;
    procedure FindFile(Dir:String);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBListViewClick(Sender: TObject);
  private
    { Private declarations }
  public
    ind,indp: Integer; 
  end;

var
  DBCreate: TDBCreate;
  icrc,bcrc: cardinal;
  TST,TVir,TSig,TName: TStringList;
  KeyRelease:string = 'DJFDKSFghjyg;KH9bn6CRTXCx4hUGLB.8.nkVTJ6FJfjylk7gl7GLUHm'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'gnkBkL1om4XbALjhgkk7sDkJ2_8JvYmWFn LR3CRxyfswstoPp5DkJ2_8JvYmWFn_LR3CRxyf'+
                      'Go0NLL1om23;d923NrUdkzkk7sda823r23;d923NrUdkzPp5DkJ2_8JvYmWFn_LR3CRxyfsws'+
                      'cvnkscv78h2lk8HHKhlkjdfvsd;vlkvsd0vvds;ldvhyB[NXzl5y5Z';

implementation

{$R *.dfm}

//Зашифрование/расшифрование файла:
function EncryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.EncryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

function DecryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.DecryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

//Поиск строки в базе
function LV_FindAndSelectItems(lv: TListView; const S: string; column: Integer): Boolean;
var
  i: Integer;
  found: Boolean;
  lvItem: TListItem;
begin
  Assert(Assigned(lv));
  Assert((lv.ViewStyle = vsReport) or (column = 0));
  Assert(S <> '');
  for i := 0 to lv.Items.Count - 1 do
  begin
    lvItem := lv.Items[i];
    if column = 0 then
      found := AnsiCompareText(lvItem.Caption, S) = 0
    else if column > 0 then
    begin
      if lvItem.SubItems.Count >= Column then
        found := AnsiCompareText(lvItem.SubItems[column - 1], S) = 0
      else
        found := False; 
    end
    else
      found := False;
    if found then
    begin
      lv.Selected := lvItem;
      Break;
    end;
  end;
  Result:=found;
end;

Function GetSize(FileN: String): String;
var
  hdc : cardinal;
  Buf : integer;
begin
  hdc := FileOpen(FileN,0);
  buf := GetFileSize(hdc,0);
  result := inttostr(buf);
  FileClose(hdc);
end;

procedure AddRecToList(Rec: TDataRecord);
begin
with DBCreate.DBListView.Items.Add, Rec do begin
    if Rec.SignType = 0 then Caption := 'MD5';
      SubItems.Add(VirName);
      SubItems.Add(Signature);
end;
end;

procedure OpenDBFile(const sFileName: String;var DBFile: TDBFile);
var
  DBRec: TDataRecord;
  i: Integer;
begin
  AssignFile(DBFile, sFileName);
  Reset(DBFile);
  i:=Filesize(DBFile);
  DBCreate.pb1.Max:=i;
  if DBCreate.btn4.Tag <> 1 then begin
     ViewS.CRLabel.Caption:='';
     ViewS.CRLabel00.Caption:='';
     ViewS.Show;
     Application.ProcessMessages;
  end;
  while not EOF(DBFile) do
    begin
      Read(DBFile, DBRec);
      AddRecToList(DBRec);
      DBCreate.pb1.Position:=DBCreate.DBListView.Items.Count;
      DBCreate.Caption:=IntToStr(DBCreate.pb1.Position-1)+' / '+IntToStr(i-1);
      ViewS.CRLabel00.Caption:=DBRec.VirName;
      ViewS.CRLabel.Caption:=DBCreate.Caption;
      TSig.Add(AnsiUpperCase(DBRec.Signature));
      DBCreate.ind:=i-1;
      DBCreate.indp:=DBCreate.pb1.Position-1;
      Application.ProcessMessages;
    end;
    CloseFile(DBFile);
    DBCreate.btn4.Tag:=0;
end;

function ExtractOnlyFileName(const FileName: string): string;
begin
   result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

procedure TDBCreate.FindFile(Dir:String);
Var SR:TSearchRec; 
    FindRes:Integer;
begin 
FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR); 
While FindRes=0 do 
   begin 
      if ((SR.Attr and faDirectory)=faDirectory) and 
         ((SR.Name='.')or(SR.Name='..')) then 
         begin 
            FindRes:=FindNext(SR);
            Continue; 
         end;
      if ((SR.Attr and faDirectory)=faDirectory) then // если найден каталог, то
         begin 
            FindFile(Dir+SR.Name+'\'); // входим в процедуру поиска с параметрами текущего каталога + каталог, что мы нашли
            FindRes:=FindNext(SR); // после осмотра вложенного каталога мы продолжаем поиск в этом каталоге 
            Continue; // продолжить цикл 
         end;
      TST.Add(Dir+SR.Name);
      FindRes:=FindNext(SR);
   end; 
FindClose(SR);
end;

procedure DecryptFileData;
var
  DBFile: TDBFile;
  sf,FBases: string;
begin
    sf:=ExtractFilePath(ParamStr(0))+'Bases\DataBase.sts.crypt';
    FBases:=ExtractOnlyFileName(sf);
   if ExtractFileExt(sf) = '.crypt' then begin
   if FileExists(sf) then
      DecryptFile(sf,ExtractFilePath(sf)+FBases,KeyRelease);
   if FileExists(ExtractFilePath(sf)+FBases) then
      DBCreate.Caption:='Decrypt complete!';
      sf:=ExtractFilePath(sf)+FBases;
      OpenDBFile(sf,DBFile);
      DeleteFile(sf);
   end;
end;

procedure TDBCreate.btn2Click(Sender: TObject);
var
  i,y: integer;
  s,s1: string;
  virf,sigf: string;
  DBFile: TDBFile;
  sf,FBases: string;
  stat: Boolean;
begin
     DBListView.Clear;
     btn2.Tag:=1;
     btn4.Tag:=0;
     sf:=ExtractFilePath(ParamStr(0))+'Bases\DataBase.sts.crypt';
     FBases:=ExtractOnlyFileName(sf);
  if not DirectoryExists(ExtractFilePath(ParamStr(0))+'VIRUS') then
     CreateDir(ExtractFilePath(ParamStr(0))+'VIRUS');
  if DirectoryExists(ExtractFilePath(ParamStr(0))+'VIRUS') then
     FindFile(ExtractFilePath(ParamStr(0))+'VIRUS\'); 
  if TST.Count <= 0 then begin
     mmo1.Lines.Add('No new viruses to add to the database!');
     Exit;
  end;
  if FileExists(sf) then begin
  for i:=0 to TST.Count-1 do begin
  if TST.IndexOf(TST.Strings[i]) <> -1 then begin
     virf:='('+ExtractOnlyFileName(ExtractFileName(TST.Strings[i]))+' - Worm)';
     sigf:=MD5DigestToStr(MD5F(TST.Strings[i]))+ ':' + GetSize(TST.Strings[i]);
     mmo1.Lines.Add('New virus: '+ExtractFileName(TST.Strings[i])+' -> '+virf+' = '+sigf);
     TVir.Add(sigf);
     TName.Add(virf);
     grp1.Caption:='Log count new virus: '+IntToStr(TVir.Count);
     Application.ProcessMessages;     
  end;
  end;
  if ExtractFileExt(sf) = '.crypt' then begin
  if FileExists(sf) then
     DecryptFile(sf,ExtractFilePath(sf)+FBases,KeyRelease);
  if FileExists(ExtractFilePath(sf)+FBases) then
     Caption:='Decrypt complete!';
     sf:=ExtractFilePath(sf)+FBases;
     OpenDBFile(sf,DBFile);
     ViewS.Close;
     DeleteFile(sf);
  end;
  mmo1.Lines.Clear;
  mmo2.Lines.Clear;
  for i:=0 to TVir.Count-1 do begin
      s:=TVir.Strings[i];
      mmo2.Lines.Add('Virus signature: '+s+' Count: '+IntToStr(mmo2.Lines.Count));
      for y:=0 to TSig.Count-1 do begin
          s1:=TSig.Strings[y];
          s1:=AnsiUpperCase(s1);
       if s1 = s then begin
          stat:=True;
          mmo1.Lines.Add('Virus signature found: '+s1+' Count: '+IntToStr(mmo1.Lines.Count));
          grp1.Caption:='Log count new virus: '+IntToStr(TVir.Count)+' / '+IntToStr(mmo2.Lines.Count);
          Application.ProcessMessages;
          Break;
       end else stat:=False;
      end;
  end;
  if (not stat) or (UPD.Checked) then
  for i:=0 to TST.Count-1 do begin
      s:=TST.Strings[i];
  if FileExists(s) then begin
     virf:='('+ExtractOnlyFileName(ExtractFileName(s))+' - Worm)';
     sigf:=MD5DigestToStr(MD5F(s))+ ':' + GetSize(s);
    with DBCreate.DBListView.Items.Add  do begin
         Caption := 'MD5';
         SubItems.Add(virf);
         SubItems.Add(sigf);
    end;
  end;
  end;
  end else mmo1.Lines.Add('No database!');
end;

procedure TDBCreate.FormCreate(Sender: TObject);
begin
  TST:=TStringList.Create;
  TVir:=TStringList.Create;
  TSig:=TStringList.Create;
  TName:=TStringList.Create;
end;

procedure TDBCreate.FormDestroy(Sender: TObject);
begin
  TST.Free;
  TVir.Free;
  TSig.Free;
  TName.Free;
end;

procedure TDBCreate.btn3Click(Sender: TObject);
var
  s: string;
  i,y: integer;
begin
  if (TST.Count <= 0) and (DBListView.Items.Count <= 0) then begin
     mmo1.Lines.Add('No viruses to remove!');
     Exit;
  end;
  TST.Clear;
  ViewS.CRLabel.Caption:='';
  ViewS.CRLabel00.Caption:='';
  ViewS.Show;
  Application.ProcessMessages;
  for i := 0 to DBListView.Items.Count-1 do begin
      s:=DBListView.Items.Item[i].SubItems[0];
      if DBListView.Items[I].Selected then y:=I;
      TST.Add(s);
  end;
  TST.Delete(y);
  DBListView.DeleteSelected;
  ViewS.Close;
end;

procedure TDBCreate.btn4Click(Sender: TObject);
label vx;
var
  DBFile: TDBFile;
  sf,FBases: string;
  i,y: integer;
  Rec: TDataRecord;
  s,s1,dt: string;
  stat: Boolean;
begin
  if (TST.Count <= 0) and (TVir.Count <= 0) then begin
     mmo1.Lines.Add('No viruses to save!');
     Exit;
  end;
  if btn2.Tag = 1 then begin
    btn2.Tag:=0;
    btn4.Tag:=1;
    ViewS.CRLabel.Caption:='';
    ViewS.CRLabel00.Caption:='';
    ViewS.Show;
    Application.ProcessMessages;
    for i:=0 to TVir.Count-1 do begin
        s:=TVir.Strings[i];
        for y:=0 to TSig.Count-1 do begin
           s1:=TSig.Strings[y];
           s1:=AnsiUpperCase(s1);
        if s1 = s then begin
           stat:=True;
           mmo1.Lines.Add('Virus signature found: '+s1+' Count: '+IntToStr(y));
           Break;
        end else stat:=False;
        end;
    end;
    if (not stat) or (UPD.Checked) then begin
    Application.ProcessMessages;
    dt:=DateToStr(Now);
    btn4.Tag:=1;
    sf:=ExtractFilePath(ParamStr(0))+'DataBase.sts.tmp';
    FBases:=ExtractOnlyFileName(sf);
    if FileExists(sf) then DeleteFile(sf);
    if FileExists(FBases) then DeleteFile(FBases);
    if not FileExists(sf) then begin
       CreateDBFile(FBases,DBFile);
       for i := 0 to DBListView.Items.Count-1 do begin
        if i <> 0 then begin
           Rec.VirName := DBListView.Items.Item[i].SubItems[0];
           Rec.Signature := DBListView.Items.Item[i].SubItems[1];
           Rec.SignType := 0;
           AddRecToDBFile(DBFile,Rec);
        end;
       end;
       DBListView.Clear;
    end;
       CloseFile(DBFile);
    if FileExists(ExtractFilePath(sf)+FBases) then
       sf:=ExtractFilePath(sf)+FBases;
      while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
      if dt <> '' then
      SeekNReplaceS(sf,'03032016',dt,8);
      OpenDBFile(sf,DBFile);
      Sleep(500);
      if FileExists(sf) then
      EncryptFile(sf,sf+'.crypt',KeyRelease);
      Sleep(500);
      DeleteFile(sf);
      TST.Clear;
      for i := 0 to DBListView.Items.Count-1 do begin
          s:=DBListView.Items.Item[i].SubItems[0];
          TST.Add(s);
          Caption:=IntToStr(DBCreate.pb1.Position-2)+' / '+IntToStr(i-2);
      end;
      if TST.Count > 0 then begin
         TST.Delete(1);
         DBListView.Items[1].Selected := true;
      if DBListView.Items[1].Selected then
         DBListView.DeleteSelected;
         ViewS.Close;
      end;
      sf:=ExtractFilePath(ParamStr(0))+'Bases\DataBase.sts.crypt';
      FBases:=ExtractFilePath(ParamStr(0))+'DataBase.sts.crypt';
      vx:
      if (FileExists(sf) and FileExists(FBases)) then begin
         icrc:= FileCRC32(sf);
         bcrc:= FileCRC32(FBases);
         mmo1.Lines.Add('Crc '+sf+' -> '+IntToStr(icrc));
         mmo1.Lines.Add('Crc '+FBases+' -> '+IntToStr(bcrc));
         if bcrc <> icrc then begin
            CopyFile(PChar(FBases),PChar(sf),False);
            mmo1.Lines.Add('Copy Files '+FBases+' -> '+sf);
            goto vx;
         end;
      end;
      if FileExists(sf) then DeleteFile(FBases);
    end else begin
    sf:=ExtractFilePath(ParamStr(0))+'DataBase.sts.tmp';
    FBases:=ExtractOnlyFileName(sf);
    if FileExists(sf) then DeleteFile(sf);
    if FileExists(FBases) then DeleteFile(FBases);
    if not FileExists(sf) then begin
       CreateDBFile(FBases,DBFile);
       for i := 0 to DBListView.Items.Count-1 do begin
        if i <> 0 then begin
           Rec.VirName := DBListView.Items.Item[i].SubItems[0];
           Rec.Signature := DBListView.Items.Item[i].SubItems[1];
           Rec.SignType := 0;
           AddRecToDBFile(DBFile,Rec);
        end;
       end;
       DBListView.Clear;
    end;
      CloseFile(DBFile);
      if dt <> '' then
      while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
      if dt <> '' then
      SeekNReplaceS(FBases,'03032016',dt,8);
      OpenDBFile(FBases,DBFile);
      Sleep(500);
      if FileExists(FBases) then
      EncryptFile(FBases,FBases+'.crypt',KeyRelease);
      Sleep(500);
      DeleteFile(FBases);
      ViewS.Close;
      sf:=ExtractFilePath(ParamStr(0))+'Bases\DataBase.sts.crypt';
      FBases:=ExtractFilePath(ParamStr(0))+'DataBase.sts.crypt';
      if (FileExists(sf) and FileExists(FBases)) then begin
         icrc:= FileCRC32(sf);
         bcrc:= FileCRC32(FBases);
         mmo1.Lines.Add('Crc '+sf+' -> '+IntToStr(icrc));
         mmo1.Lines.Add('Crc '+FBases+' -> '+IntToStr(bcrc));
         if bcrc <> icrc then begin
            CopyFile(PChar(FBases),PChar(sf),False);
            mmo1.Lines.Add('Copy Files '+FBases+' -> '+sf);
            if FileExists(sf) then DeleteFile(FBases);
         end else if FileExists(sf) then DeleteFile(FBases);
      end;
    end;
  end;
end;

procedure TDBCreate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (btn4.Tag = 0) and (btn2.Tag = 1) then
  btn4.Click;
  mmo1.Lines.SaveToFile('Log.txt');
  Application.Terminate;
end;

procedure TDBCreate.DBListViewClick(Sender: TObject);
begin
  grp1.Caption:='Log -> '+IntToStr(DBListView.ItemIndex)+' = '+DBListView.Items.Item[DBListView.ItemIndex].SubItems[1];
  Application.ProcessMessages;
end;

end.
