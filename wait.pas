unit wait;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg;

type
  TViewS = class(TForm)
    CRLabel: TLabel;
    CRLabel00: TLabel;
    img1: TImage;
    tmr1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure SetTop;
    function tictac(i: Integer; tc: Integer) : string;
  public
    { Public declarations }
  end;

var
  ViewS: TViewS;
  TIK: Integer;

implementation

{$R *.dfm}

procedure TViewS.SetTop;
var
  hWnd, hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: Boolean;
begin
  if GetActiveWindow=Application.MainForm.Handle then Exit;
     Application.Restore;
     hWnd := Application.Handle;
     SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
     SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     hCurWnd := GetForegroundWindow;
     AResult := False;
     while not AResult do
     begin
        dwThreadID := GetCurrentThreadId;
        dwCurThreadID := GetWindowThreadProcessId(hCurWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, True);
        AResult := SetForegroundWindow(hWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, False);
     end;
     SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(OldTimeOut), 0);
end;

{
var
  h   : HWND;
  buf : array[Byte] of Char;
  St  : String;
  /////////////
  h := findwindow('TDBCreate',nil);
  if h <> 0 then begin
    SendMessage(h, WM_GETTEXT, SizeOF(buf), Integer(@buf));
    St := buf;
    CRLabel.Caption:=St;
  end;
  EnumChildWindows(h, @EnumChildFunc, 0);
}
function EnumChildFunc(Child: HWND; lParam : Longint) : BOOL; stdcall;
var
  szClass : array[0..63] of Char;
  buf     : array[Byte] of Char;
  St      : String;
begin
  GetClassName(Child, szClass, SizeOf(szClass));
  if lstrcmpi(szClass, 'TListView') = 0 then
  begin
    SendMessage(Child, WM_GETTEXT, SizeOF(buf), Integer(@buf));
    St := buf;
    ViewS.CRLabel00.Caption:=St;
  end;
  Result := True;
end;

function ForceForegroundWindow(Wnd: HWND): Boolean;
var
  Input: TInput;
begin
  FillChar(Input, SizeOf(Input), 0);
  SendInput(1, Input, SizeOf(TInput));
  Result := SetForegroundWindow(Wnd);
end;

function TViewS.tictac(i: Integer; tc: Integer) : string;
const
  s = '. ';
  s1 = '.. ';
  s2 = '... ';
  s3 = '.... ';
begin
  if i = 5 then Result := s;
  if i = 4 then Result := s1;
  if i = 3 then Result := s2;
  if i = 2 then Result := s3;
  if i <= 1 then Result := '. ';
  sleep(tc);
  Application.ProcessMessages;
end;

procedure TViewS.FormCreate(Sender: TObject);
var
  rgn: HRGN;
begin
  ViewS.Borderstyle := bsNone;
  rgn := CreateRoundRectRgn(0,// x-координата левого верхнего угла региона
    0,            // y-координата левого верхнего угла региона
    ClientWidth,  // x-координата нижнего правого угла региона
    ClientHeight, // y-координата нижнего правого угла региона
    40,           // высота эллипса закругленного угла
    40);          // ширина эллипса загругленного угла
  SetWindowRgn(Handle, rgn, True);
  TIK:=6;
end;

procedure TViewS.tmr1Timer(Sender: TObject);
begin
   TIK:=TIK-1;
   ForceForegroundWindow(ViewS.Handle);
   Application.ProcessMessages;
if TIK <= 0 then begin
   TIK:=3;
   SetTop;   
end else CRLabel00.Caption:=tictac(TIK,100);
end;

procedure TViewS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmr1.Enabled:=False;
end;

procedure TViewS.FormShow(Sender: TObject);
begin
  CRLabel.Caption:='Wait ...';
  Application.ProcessMessages;
  tmr1.Enabled:=True;
end;

end.
