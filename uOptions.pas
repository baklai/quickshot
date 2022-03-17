{******************************************************************************}
{                                                                              }
{                    Copyright (c) 2010-2017 Alex Krapka                       }
{                                                                              }
{******************************************************************************}
unit uOptions;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.StdCtrls, System.DateUtils, System.Classes,
  System.Win.Registry, System.IniFiles, System.TypInfo, Vcl.WinXCtrls, Vcl.Graphics;

type
  TItemType = (itString, itInteger, itReal, itBoolean, itDate);

type
  TItem = record
    FComponent : TComponent;
    FProperty  : String;
    FSection   : String;
    FCaption   : String;
    FDefault   : variant;
    FItemType  : TItemType;
  end;
  TListItem = array of TItem;

type
  TREGOptions = class
  private
  { Секция частных объявлений }
    FItem: TListItem;
    FREGSection: string;
    FEXEName: string;
    FEXESection: string;
    FDIRSection: string;
  protected
  { Секция защищенных объявлений }
  public
  { Секция общих объявлений }
    procedure Autorun(Value: boolean);
    procedure Add(Value: TItem); overload;
    procedure Add(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Save; overload;
    procedure Save(Value: TItem); overload;
    procedure Save(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Load; overload;
    procedure Load(Value: TItem); overload;
    procedure Load(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Default; overload;
    procedure Default(Value: TItem); overload;
    procedure Default(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    constructor Create(const AREGSection: string = '');
    destructor Destroy; override;
  end;

type
  TINIOptions = class
  private
  { Секция частных объявлений }
    FItem: TListItem;
    FINISection: string;
    FEXEName: string;
    FEXESection: string;
    FDIRSection: string;
  protected
  { Секция защищенных объявлений }
  public
  { Секция общих объявлений }
    procedure Autorun(Value: boolean);
    procedure Add(Value: TItem); overload;
    procedure Add(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Save; overload;
    procedure Save(Value: TItem); overload;
    procedure Save(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Load; overload;
    procedure Load(Value: TItem); overload;
    procedure Load(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    procedure Default; overload;
    procedure Default(Value: TItem); overload;
    procedure Default(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection: string = ''; const ACaption: string = ''); overload;
    constructor Create(const AINISection: string = '');
    destructor Destroy; override;
  end;

implementation

{ TREGOptions }

constructor TREGOptions.Create(const AREGSection: string);
begin
  FEXEName:=ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  FEXESection:=ExtractFilePath(ParamStr(0))+ExtractFileName(ParamStr(0));
  FDIRSection:=ExtractFilePath(ParamStr(0));
  if AREGSection='' then FREGSection:=FEXEName else FREGSection:=AREGSection;
end;

destructor TREGOptions.Destroy;
begin
  Save;
  FItem:=nil;
  inherited destroy;
end;

procedure TREGOptions.Autorun(Value: boolean);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
      if Value then WriteString(FEXEName,FEXESection) else DeleteValue(FEXEName);
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Add(Value: TItem);
begin
try
  SetLength(FItem,Length(FItem)+1);
  FItem[Length(FItem)-1].FComponent:=Value.FComponent;
  FItem[Length(FItem)-1].FProperty:=Value.FProperty;
  FItem[Length(FItem)-1].FSection:=Value.FSection;
  FItem[Length(FItem)-1].FItemType:=Value.FItemType;
  if Value.FCaption='' then FItem[Length(FItem)-1].FCaption:=Value.FComponent.Name
  else FItem[Length(FItem)-1].FCaption:=Value.FCaption;
  FItem[Length(FItem)-1].FDefault:=Value.FDefault;
except
  SetLength(FItem,Length(FItem)-1);
end;
end;

procedure TREGOptions.Add(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
begin
try
  SetLength(FItem,Length(FItem)+1);
  FItem[Length(FItem)-1].FComponent:=AComponent;
  FItem[Length(FItem)-1].FProperty:=AProperty;
  FItem[Length(FItem)-1].FSection:=ASection;
  FItem[Length(FItem)-1].FItemType:=AItemType;
  if ACaption='' then FItem[Length(FItem)-1].FCaption:=AComponent.Name
  else FItem[Length(FItem)-1].FCaption:=ACaption;
  FItem[Length(FItem)-1].FDefault:=ADefault;
except
  SetLength(FItem,Length(FItem)-1);
end;
end;

procedure TREGOptions.Load;
var
  Registry: TRegistry;
  i: integer;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      for i:=Low(FItem) to High(FItem) do
        begin
          OpenKey('\SOFTWARE\'+FREGSection+'\'+FItem[i].FSection,true);
          case FItem[i].FItemType of
            itInteger : if ValueExists(FItem[i].FCaption) then
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadInteger(FItem[i].FCaption))
                        else
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault);
            itReal    : if ValueExists(FItem[i].FCaption) then
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadFloat(FItem[i].FCaption))
                        else
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault);
            itDate    : if ValueExists(FItem[i].FCaption) then
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadDate(FItem[i].FCaption))
                        else
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault);
            itBoolean : if ValueExists(FItem[i].FCaption) then
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadBool(FItem[i].FCaption))
                        else
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault);
            itString  : if ValueExists(FItem[i].FCaption) then
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadString(FItem[i].FCaption))
                        else
                          SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault);
          end;
          CloseKey;
        end;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Load(Value: TItem);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+Value.FSection,true);
        case Value.FItemType of
          itInteger : if ValueExists(Value.FCaption) then SetPropValue(Value.FComponent,Value.FProperty,ReadInteger(Value.FCaption)) else SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault);
          itReal    : if ValueExists(Value.FCaption) then SetPropValue(Value.FComponent,Value.FProperty,ReadFloat(Value.FCaption)) else SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault);
          itDate    : if ValueExists(Value.FCaption) then SetPropValue(Value.FComponent,Value.FProperty,ReadDate(Value.FCaption)) else SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault);
          itBoolean : if ValueExists(Value.FCaption) then SetPropValue(Value.FComponent,Value.FProperty,ReadBool(Value.FCaption)) else SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault);
          itString  : if ValueExists(Value.FCaption) then SetPropValue(Value.FComponent,Value.FProperty,ReadString(Value.FCaption)) else SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault);
        end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Load(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+ASection,true);
        case AItemType of
          itInteger : if ValueExists(ACaption) then SetPropValue(AComponent,AProperty,ReadInteger(ACaption)) else SetPropValue(AComponent,AProperty,ADefault);
          itReal    : if ValueExists(ACaption) then SetPropValue(AComponent,AProperty,ReadFloat(ACaption)) else SetPropValue(AComponent,AProperty,ADefault);
          itDate    : if ValueExists(ACaption) then SetPropValue(AComponent,AProperty,ReadDate(ACaption)) else SetPropValue(AComponent,AProperty,ADefault);
          itBoolean : if ValueExists(ACaption) then SetPropValue(AComponent,AProperty,ReadBool(ACaption)) else SetPropValue(AComponent,AProperty,ADefault);
          itString  : if ValueExists(ACaption) then SetPropValue(AComponent,AProperty,ReadString(ACaption)) else SetPropValue(AComponent,AProperty,ADefault);
        end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Save;
var
  Registry: TRegistry;
  i: integer;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      for i:=Low(FItem) to High(FItem) do
        begin
          OpenKey('\SOFTWARE\'+FREGSection+'\'+FItem[i].FSection,true);
          case FItem[i].FItemType of
            itInteger : WriteInteger(FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itReal    : WriteFloat(FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itDate    : WriteDate(FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itBoolean : WriteBool(FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itString  : WriteString(FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
          end;
          CloseKey;
        end;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Save(Value: TItem);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+Value.FSection,true);
      case Value.FItemType of
        itInteger : WriteInteger(Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itReal    : WriteFloat(Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itDate    : WriteDate(Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itBoolean : WriteBool(Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itString  : WriteString(Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
      end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Save(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+ASection,true);
      case AItemType of
        itInteger : WriteInteger(ACaption,GetPropValue(AComponent,AProperty));
        itReal    : WriteFloat(ACaption,GetPropValue(AComponent,AProperty));
        itDate    : WriteDate(ACaption,GetPropValue(AComponent,AProperty));
        itBoolean : WriteBool(ACaption,GetPropValue(AComponent,AProperty));
        itString  : WriteString(ACaption,GetPropValue(AComponent,AProperty));
      end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Default;
var
  Registry: TRegistry;
  i: integer;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      for i:=Low(FItem) to High(FItem) do
        begin
          OpenKey('\SOFTWARE\'+FREGSection+'\'+FItem[i].FSection,true);
          case FItem[i].FItemType of
            itInteger : begin WriteInteger(FItem[i].FCaption,FItem[i].FDefault); SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itReal    : begin WriteFloat(FItem[i].FCaption,FItem[i].FDefault);   SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itDate    : begin WriteDate(FItem[i].FCaption,FItem[i].FDefault);    SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itBoolean : begin WriteBool(FItem[i].FCaption,FItem[i].FDefault);    SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itString  : begin WriteString(FItem[i].FCaption,FItem[i].FDefault);  SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
          end;
          CloseKey;
        end;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Default(Value: TItem);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+Value.FSection,true);
      case Value.FItemType of
        itInteger : begin WriteInteger(Value.FCaption,Value.FDefault); SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itReal    : begin WriteFloat(Value.FCaption,Value.FDefault);   SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itDate    : begin WriteDate(Value.FCaption,Value.FDefault);    SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itBoolean : begin WriteBool(Value.FCaption,Value.FDefault);    SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itString  : begin WriteString(Value.FCaption,Value.FDefault);  SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
      end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TREGOptions.Default(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\'+FREGSection+'\'+ASection,true);
      case AItemType of
        itInteger : begin WriteInteger(ACaption,ADefault); SetPropValue(AComponent,AProperty,ADefault); end;
        itReal    : begin WriteFloat(ACaption,ADefault);   SetPropValue(AComponent,AProperty,ADefault); end;
        itDate    : begin WriteDate(ACaption,ADefault);    SetPropValue(AComponent,AProperty,ADefault); end;
        itBoolean : begin WriteBool(ACaption,ADefault);    SetPropValue(AComponent,AProperty,ADefault); end;
        itString  : begin WriteString(ACaption,ADefault);  SetPropValue(AComponent,AProperty,ADefault); end;
      end;
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

{ TINIOptions }

constructor TINIOptions.Create(const AINISection: string);
begin
  FEXEName:=ExtractFilePath(ParamStr(0))+ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  FEXESection:=ExtractFilePath(ParamStr(0))+ExtractFileName(ParamStr(0));
  FDIRSection:=ExtractFilePath(ParamStr(0));
  if AINISection = '' then FINISection:=FEXEName else FINISection:=AINISection;

  if not FileExists(FEXEName+AINISection+'.ini') then FileClose(FileCreate(FEXEName+AINISection+'.ini'))

end;

destructor TINIOptions.Destroy;
begin
  Save;
  FItem:=nil;
  inherited destroy;
end;

procedure TINIOptions.Autorun(Value: boolean);
var
  Registry: TRegistry;
begin
try
  Registry:=TRegistry.Create;
  with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
      if Value then WriteString(FEXEName,FEXESection) else DeleteValue(FEXEName);
      CloseKey;
    end;
finally
  FreeAndNil(Registry);
end;
end;

procedure TINIOptions.Add(Value: TItem);
begin
try
  SetLength(FItem,Length(FItem)+1);
  FItem[Length(FItem)-1].FComponent:=Value.FComponent;
  FItem[Length(FItem)-1].FProperty:=Value.FProperty;
  FItem[Length(FItem)-1].FSection:=Value.FSection;
  FItem[Length(FItem)-1].FItemType:=Value.FItemType;
  if Value.FCaption='' then FItem[Length(FItem)-1].FCaption:=Value.FComponent.Name
  else FItem[Length(FItem)-1].FCaption:=Value.FCaption;
  FItem[Length(FItem)-1].FDefault:=Value.FDefault;
except
  SetLength(FItem,Length(FItem)-1);
end;
end;

procedure TINIOptions.Add(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
begin
try
  SetLength(FItem,Length(FItem)+1);
  FItem[Length(FItem)-1].FComponent:=AComponent;
  FItem[Length(FItem)-1].FProperty:=AProperty;
  FItem[Length(FItem)-1].FSection:=ASection;
  FItem[Length(FItem)-1].FItemType:=AItemType;
  if ACaption='' then FItem[Length(FItem)-1].FCaption:=AComponent.Name
  else FItem[Length(FItem)-1].FCaption:=ACaption;
  FItem[Length(FItem)-1].FDefault:=ADefault;
except
  SetLength(FItem,Length(FItem)-1);
end;
end;

procedure TINIOptions.Load;
var
  IniFile: TIniFile;
  i: integer;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      for i:=Low(FItem) to High(FItem) do
        begin
          case FItem[i].FItemType of
            itInteger : SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadInteger(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault));
            itReal    : SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadFloat(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault));
            itDate    : SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadDate(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault));
            itBoolean : SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadBool(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault));
            itString  : SetPropValue(FItem[i].FComponent,FItem[i].FProperty,ReadString(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault));
          end;
        end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Load(Value: TItem);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case Value.FItemType of
        itInteger : SetPropValue(Value.FComponent,Value.FProperty,ReadInteger(Value.FSection,Value.FCaption,Value.FDefault));
        itReal    : SetPropValue(Value.FComponent,Value.FProperty,ReadFloat(Value.FSection,Value.FCaption,Value.FDefault));
        itDate    : SetPropValue(Value.FComponent,Value.FProperty,ReadDate(Value.FSection,Value.FCaption,Value.FDefault));
        itBoolean : SetPropValue(Value.FComponent,Value.FProperty,ReadBool(Value.FSection,Value.FCaption,Value.FDefault));
        itString  : SetPropValue(Value.FComponent,Value.FProperty,ReadString(Value.FSection,Value.FCaption,Value.FDefault));
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Load(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case AItemType of
        itInteger : SetPropValue(AComponent,AProperty,ReadInteger(ASection,ACaption,ADefault));
        itReal    : SetPropValue(AComponent,AProperty,ReadFloat(ASection,ACaption,ADefault));
        itDate    : SetPropValue(AComponent,AProperty,ReadDate(ASection,ACaption,ADefault));
        itBoolean : SetPropValue(AComponent,AProperty,ReadBool(ASection,ACaption,ADefault));
        itString  : SetPropValue(AComponent,AProperty,ReadString(ASection,ACaption,ADefault));
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Save;
var
  IniFile: TIniFile;
  i: integer;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      for i:=Low(FItem) to High(FItem) do
        begin
          case FItem[i].FItemType of
            itInteger : WriteInteger(FItem[i].FSection,FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itReal    : WriteFloat(FItem[i].FSection,FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itDate    : WriteDate(FItem[i].FSection,FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itBoolean : WriteBool(FItem[i].FSection,FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
            itString  : WriteString(FItem[i].FSection,FItem[i].FCaption,GetPropValue(FItem[i].FComponent,FItem[i].FProperty));
          end;
        end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Save(Value: TItem);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case Value.FItemType of
        itInteger : WriteInteger(Value.FSection,Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itReal    : WriteFloat(Value.FSection,Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itDate    : WriteDate(Value.FSection,Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itBoolean : WriteBool(Value.FSection,Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
        itString  : WriteString(Value.FSection,Value.FCaption,GetPropValue(Value.FComponent,Value.FProperty));
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Save(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case AItemType of
        itInteger : WriteInteger(ASection,ACaption,GetPropValue(AComponent,AProperty));
        itReal    : WriteFloat(ASection,ACaption,GetPropValue(AComponent,AProperty));
        itDate    : WriteDate(ASection,ACaption,GetPropValue(AComponent,AProperty));
        itBoolean : WriteBool(ASection,ACaption,GetPropValue(AComponent,AProperty));
        itString  : WriteString(ASection,ACaption,GetPropValue(AComponent,AProperty));
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Default;
var
  IniFile: TIniFile;
  i: integer;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      for i:=Low(FItem) to High(FItem) do
        begin
          case FItem[i].FItemType of
            itInteger : begin WriteInteger(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault); SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itReal    : begin WriteFloat(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault);   SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itDate    : begin WriteDate(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault);    SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itBoolean : begin WriteBool(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault);    SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
            itString  : begin WriteString(FItem[i].FSection,FItem[i].FCaption,FItem[i].FDefault);  SetPropValue(FItem[i].FComponent,FItem[i].FProperty,FItem[i].FDefault); end;
          end;
        end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Default(Value: TItem);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case Value.FItemType of
        itInteger : begin WriteInteger(Value.FSection,Value.FCaption,Value.FDefault); SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itReal    : begin WriteFloat(Value.FSection,Value.FCaption,Value.FDefault);   SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itDate    : begin WriteDate(Value.FSection,Value.FCaption,Value.FDefault);    SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itBoolean : begin WriteBool(Value.FSection,Value.FCaption,Value.FDefault);    SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
        itString  : begin WriteString(Value.FSection,Value.FCaption,Value.FDefault);  SetPropValue(Value.FComponent,Value.FProperty,Value.FDefault); end;
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;

procedure TINIOptions.Default(AComponent: TComponent; AProperty: string; AItemType: TItemType; ADefault: variant; const ASection, ACaption: string);
var
  IniFile: TIniFile;
begin
try
  IniFile:=TIniFile.Create(FINISection+'.ini');
  with IniFile do
    begin
      case AItemType of
        itInteger : begin WriteInteger(ASection,ACaption,ADefault); SetPropValue(AComponent,AProperty,ADefault); end;
        itReal    : begin WriteFloat(ASection,ACaption,ADefault);   SetPropValue(AComponent,AProperty,ADefault); end;
        itDate    : begin WriteDate(ASection,ACaption,ADefault);    SetPropValue(AComponent,AProperty,ADefault); end;
        itBoolean : begin WriteBool(ASection,ACaption,ADefault);    SetPropValue(AComponent,AProperty,ADefault); end;
        itString  : begin WriteString(ASection,ACaption,ADefault);  SetPropValue(AComponent,AProperty,ADefault); end;
      end;
    end;
finally
  FreeAndNil(IniFile);
end;
end;



initialization
{ Инициализация модуля }

finalization
{ Завершение работы модуля }

end.
