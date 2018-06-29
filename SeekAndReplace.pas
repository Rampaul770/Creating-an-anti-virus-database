(*
//*************************************************\\
||*             Seek and Replace Engine           *||
||*                    Version 1.3                *||
||*           Copyright[c] 2oo7 by Spirit         *||
||*************************************************||
||* -Information                                  *||
||*  You can use this engine for file patching... *||
||*  If You use this engine not for patching,     *||
||*  please mail to me :p                         *||
||*  Only sniper want to use this engine for      *||
||*  IAT protection :)                            *||
||*************************************************||
||* -Using:                                       *||
||*  Engine have 3 functions:                     *||
||*  SeekNReplaceB - for Byte Seek'n'Replace      *||
||*  SeekNReplaceD - for DWord Seek'n'Replace     *||
||*  SeekNReplaceS - for String Seek'n'Replace    *||
||* --Params:                                     *||
||*   First  - File name to patch                 *||
||*   Second - Data for seeking                   *||
||*   Third  - Data for replacing                 *||
||*   Fourth - Max count of patches               *||
||*************************************************||
||* -Example:                                     *||
||*  Uses SeekAndReplace;                         *||
||*  ...                                          *||
||*  procedure ButtonClick(Sender: TObject);      *||
||*  begin                                        *||
||*  SeekAndReplace.SeekNReplaceB('tt',$FA,$C8,8) *||
||*  end;                                         *||
||*  --In this example:                           *||
||*    1) Openinig file "tt"                      *||
||*    2) Seeking $FA byte                        *||
||*    3) Replacing $FA to $C8                    *||
||*    4) Only 8 bytes was replased               *||
||*************************************************||
||* -Contacts:                                    *||
||*  WEB  - http://WWW.SpiritST.MyLivePage.com    *||
||*  Mail - SpiritST@yandex.ru                    *||
||*  ICQ  - 28-33-00                              *||
\\*************************************************//
*) {$WARNINGS OFF}
unit SeekAndReplace;
interface

uses windows;

type
Reslt = record
IsComplete: Boolean;
PatchCount:integer;
end;

var
MyResult:Reslt;
c:integer;

Function SeekNReplaceB(FName:string;ByteToSeek,ByteToReplace:byte;MaxCount:integer):boolean;
Function SeekNReplaceD(FName:string;DWordToSeek,DWordToReplace:DWord;MaxCount:integer):boolean;
Function SeekNReplaceS(FName:string;StringToSeek,StringToReplace:string;MaxCount:integer):boolean;
implementation

Procedure null;
begin
c:=0;
MyResult.IsComplete:=False;
MyResult.PatchCount:=0;
end;

Function SeekNReplaceB(FName:string;ByteToSeek,ByteToReplace:byte;MaxCount:integer):boolean;
var
  f: file;
  l: Longint;
  ByteS: Byte;
begin
Null;
//..Seek and Replace - Byte
  ByteS := ByteToSeek;
  AssignFile(f, FName);
  Reset(f, 1);
  for l := 0 to FileSize(f) - 1 do
  begin
    Seek(f, l);
    BlockRead(f, ByteToSeek, 1);
    if ByteToSeek = ByteS then
    begin
      If c=MaxCount
      Then exit;
      c:=c+1;
      MyResult.PatchCount:=MyResult.PatchCount+1;
      MyResult.IsComplete:=True;
      Seek(f, l);
      BlockWrite(f, ByteToReplace, 1);
    end;
  end;
  CloseFile(f);
end;

Function SeekNReplaceD(FName:string;DWordToSeek,DWordToReplace:DWord;MaxCount:integer):boolean;
var
  f: file;
  l: Longint;
  DWordS: DWord;
begin
Null;
//..Seek and Replace - DWORD
  DWordS := DWordToSeek;
  AssignFile(f, FName);
  Reset(f, 1);
  for l := 0 to FileSize(f) - 5 do
  begin
     If c=MaxCount
      Then exit;
      c:=c+1;
      MyResult.PatchCount:=MyResult.PatchCount+1;
      MyResult.IsComplete:=True;
    Seek(f, l);
    BlockRead(f, DWordToSeek, 4);
    if DWordToSeek = DWordS then
    begin
      Seek(f, l);
      BlockWrite(f, DWordToReplace, 4);
      Result:=true;
    end;
  end;
  CloseFile(f);
end;

Function SeekNReplaceS(FName:string;StringToSeek,StringToReplace:string;MaxCount:integer):boolean;
var
  f: file;
  l: Longint;
  StringS: string;
begin
Null;
If Length(StringToSeek)<>Length(StringToReplace)
Then begin
If MessageBox(0,'StringToSeek and StringToReplace have different length.'#13#10'Do you want to continue?','Warning',MB_YESNO or MB_ICONASTERISK)=7
Then exit;
end;
c:=0;
Result:=false;
//..Seek and Replace - String
  StringS := StringToSeek;
  AssignFile(f, FName);
  Reset(f, 1);
  for l := 0 to FileSize(f) - Length(StringToSeek) - 1 do
  begin
    Seek(f, l);
    BlockRead(f, StringToSeek[1], Length(StringToSeek));
    if StringToSeek = StringS then
    begin
      If c=MaxCount
      Then exit;
      c:=c+1;
      MyResult.PatchCount:=MyResult.PatchCount+1;
      MyResult.IsComplete:=True;
      Seek(f, l);
      BlockWrite(f, StringToReplace[1], Length(StringToReplace));
      Result:=true;
    end;
  end;
  CloseFile(f); 
end;
end.
 