unit Form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  synaser { Synaser library downloaded from http://synapse.ararat.cz/files/synaser.zip }
  ;

type
  TMainForm = class(TForm)
    Mem_Rcv: TMemo;
    Tmr_Rcv: TTimer;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    Button1: TButton;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    procedure Tmr_RcvTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Mem_RcvChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  ser: TBlockSerial;
  myFile,mySettings: Text;
  XonOff : boolean ; { manual XonOff handling ... I want to see it }
  x, logfilename, displayfilename: string;
  floattempalt,floattemp,tempdelta: extended;
  timestamp: Array[1..3] of TDateTime;
  logfilecounter: integer;

implementation

{$R *.DFM}


function GetFileModifyDate(FileName: string): TDateTime;
var
  h: THandle;
  Struct: TOFSTRUCT;
  lastwrite: Integer;
  t: TDateTime;
begin
  h := OpenFile(PChar(FileName), Struct, OF_SHARE_DENY_NONE);
  try
    if h <> HFILE_ERROR then
    begin
      lastwrite := FileGetDate(h);
      Result    := FileDateToDateTime(lastwrite);
    end;
  finally
    CloseHandle(h);
  end;
end;


procedure TMainForm.Tmr_RcvTimer(Sender: TObject);
var Ch: Byte ;
    sl: TStringList;
    itemp,iisttemp,isolltemp,i:integer;
    tfs, solltemp, isttemp, line2, temp: string;
begin
  Tmr_Rcv.Enabled := false ;
  DecimalSeparator := '.';
  timestamp[1]:= GetFileModifyDate(displayfilename);
  if ((ComboBox2.Text='NTC10000') or (ComboBox2.Text='DS18B20') and (ser.WaitingData>0)) then
  begin
    repeat
      Ch := Ser.RecvByte(2) ;
      if ser.LastError<>ErrTimeout then
        if (Ch=13) then
          begin
          Mem_Rcv.Lines.Append('');
          sl:=TStringList.Create; //Objekt erzeugen
          try
            floattempalt:=floattemp;
            try floattemp:=strtofloat(Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]); except end;
            tempdelta:=floattemp-floattempalt;
            if timestamp[1]=timestamp[3] then
            begin
              Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Logdatei seit >2 min. unverändert';
            end
            else if (floattemp<0) or (floattemp>=100) or (tempdelta<-5) or (tempdelta>5) then
            begin
              Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Temperaturwert unplausibel';
            end
            else
            begin
              try
                AssignFile (MyFile, logfilename);
                if logfilecounter>100 then begin DeleteFile(logfilename); logfilecounter:=0; end;
                if FileExists(logfilename) then
                try Append(MyFile); except Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Datei konnte nicht geschrieben werden'; Tmr_Rcv.Enabled := true; exit; end
                else
                try ReWrite(MyFile); except Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Datei konnte nicht geschrieben werden'; Tmr_Rcv.Enabled := true; exit; end;
                tfs:=(DateTimeToStr(Now)+';'+Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]);
                writeln(MyFile, tfs);
                CloseFile(MyFile);
                logfilecounter:=logfilecounter+1;
                Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:=(DateTimeToStr(Now)+';'+Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]); //Text hinzufügen
              except
                Tmr_Rcv.Enabled := true;
                Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Datei konnte nicht geschrieben werden';
              end;
            end;
          finally
            sl.free; //Objekt wieder freigeben
          end;
          end
        else if Ch=17 then
          begin
          XonOff := false ;
          end
        else if Ch=19 then
          begin
          XonOff := true ;
          end
        else if (Ch<>13)and(Ch<>10) then
          Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-1] :=
          Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-1] + chr(Ch);
    until (ser.LastError=ErrTimeout) or (ser.WaitingData>0) ;
  end;
  if FileExists(displayfilename) then
  begin
    try
      AssignFile(myFile, displayfilename);
      Reset(myFile);
      ReadLn(myFile, isttemp); iisttemp:=round(strtofloat(isttemp)*10);
      ReadLn(myFile, solltemp); isolltemp:=round(strtofloat(solltemp));
      ReadLn(myFile, temp); if temp='1' then itemp:=1 else itemp:=0;
      ReadLn(myFile, temp); if temp='1' then itemp:=itemp+2;
      ReadLn(myFile, temp); if temp='1' then itemp:=itemp+4;
      ReadLn(myFile, temp); if temp='1' then itemp:=itemp+8;
      line2:='C'+char(itemp);
      ReadLn(myFile, temp); if temp='aktiv' then itemp:=1 else if temp='pausiert' then itemp:=2 else itemp:=4;
      if timestamp[1]=timestamp[3] then itemp:=itemp+8 else itemp:=itemp+16;
      if ComboBox2.Text='Display' then itemp:=itemp+32 else if ComboBox2.Text='DS18B20' then itemp:=itemp+64 else itemp:=itemp+128;
      if iisttemp>255 then repeat begin iisttemp:=iisttemp-256; i:=i+1; end until iisttemp<256;
      line2:=line2+char(itemp)+char(isolltemp)+char(i)+char(iisttemp);
      ReadLn(myFile, temp); if temp<>'0' then itemp:=128 else itemp:=0;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+64;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+32;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+16;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+8;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+4;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+2;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+1;
      line2:=line2+char(itemp);
      ReadLn(myFile, temp); if temp<>'0' then itemp:=2 else itemp:=0;
      ReadLn(myFile, temp); if temp<>'0' then itemp:=itemp+1;
      line2:=line2+char(itemp)+('----------c');
      CloseFile(myFile);
      ser.SendString(line2);
    except
      Tmr_Rcv.Enabled := true;
      exit;
    end;
  end
  else
  begin
    if Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]<>'Displaydatei existiert nicht' then
    begin
      Mem_Rcv.Lines.Append('');
      Mem_Rcv.Lines.Strings[Mem_Rcv.Lines.Count-2]:='Displaydatei existiert nicht';
    end;
  end;
  Tmr_Rcv.Enabled := true ;
end;

procedure OpenLine ;
begin with MainForm do begin
  ser.Connect(ComboBox1.Text) ;
  if ser.LastError<>sOK then begin Mem_Rcv.Lines.Append('No '+ComboBox1.Text) ; exit ; end ;
  ser.Config({Baud}19200, {Bits}8, {Parity}'N', {StopBits}SB1, {Xon/Xoff}false, {DTR/CTS}false);
  if ser.LastError<>sOK then begin Mem_Rcv.Lines.Append('Config fail') ; exit ; end ;
  Mem_Rcv.Lines.append('Connected');
  Mem_Rcv.Lines.Append('');
  Tmr_Rcv.Interval := 200 ; Tmr_Rcv.Enabled := true ; XonOff := false ;
end ; end ;

procedure CloseLine ;
begin with MainForm do begin
  Tmr_Rcv.Enabled := false ;
  ser.CloseSocket ;
end ; end ;

procedure TMainForm.FormCreate(Sender: TObject);
var i: integer;
begin
  for i:=1 to 3 do timestamp[i]:=0;
  if FileExists('settings_usb.txt') then
  begin
    AssignFile(mySettings, 'settings_usb.txt');
    Reset(mySettings);
    ReadLn(mySettings, x); ComboBox1.Text:=x;
    ReadLn(mySettings, x); ComboBox2.Text:=x;
    ReadLn(mySettings, logfilename); Edit1.Text:=logfilename;
    ReadLn(mySettings, displayfilename); Edit2.Text:=displayfilename;
    CloseFile(mySettings);
  end
  else
  begin
    logfilename:=Edit1.Text;
    displayfilename:=Edit2.Text;
  end;
  if DeleteFile(logfilename) then
  begin
    AssignFile(myFile, logfilename);
    ReWrite(myFile);
    Writeln(myFile, '01-01-2000 00:00:00;21.0');
    CloseFile(myFile);
  end;
  Label2.Caption:=DateTimeToStr(Now);
  ser:=TBlockserial.Create;
  ser.RaiseExcept:=False;
  OpenLine;
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  CloseLine;
  OpenLine;
end;

procedure TMainForm.Mem_RcvChange(Sender: TObject);
begin
  Label1.Caption:=DateTimeToStr(Now);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  try
  AssignFile(mySettings, 'settings_usb.txt');
  ReWrite(mySettings);
  WriteLn(mySettings, ComboBox1.Text);
  WriteLn(mySettings, ComboBox2.Text);
  WriteLn(mySettings, Edit1.Text);
  WriteLn(mySettings, Edit2.Text);
  CloseFile(mySettings);
  logfilename:=Edit1.Text;
  displayfilename:=Edit2.Text;
  except
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  timestamp[3]:=timestamp[2];
  timestamp[2]:=timestamp[1];
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked=true then Timer1.Enabled:=true else Timer1.Enabled:=false;
  timestamp[2]:=0;
  timestamp[3]:=0;
end;

end.
