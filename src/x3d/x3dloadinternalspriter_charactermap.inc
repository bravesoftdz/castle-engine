{
  Copyright 2016 Trung Le (kagamma).

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{$ifdef read_interface}
  TCharacterMap = class
  protected
    FId: integer;
    FName: string;
    FMaps: TObjectList;
  public     
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;

  TMapInstruction = class
  protected
    FFolder,
    FFile,
    FTarFolder,
    FTarFile: integer;
  public
    procedure Parse(const ANode: TDOMNode);
  end;

{$endif}

{$ifdef read_implementation}
constructor TCharacterMap.Create;
begin
  inherited;
  FMaps := TObjectList.Create;
end;

destructor TCharacterMap.Destroy;
begin
  FreeAndNil(FMaps);
  inherited;
end;

procedure TCharacterMap.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
  MapInst: TMapInstruction;
begin
  FId := StrToInt(ANode.Attributes.GetNamedItem('id').NodeValue);  
  FName := ANode.Attributes.GetNamedItem('name').NodeValue;
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'map':
        begin
          MapInst := TMapInstruction.Create;
          MapInst.Parse(C);
          FMaps.Add(MapInst);
        end;
    end;
    C := C.NextSibling;
  end;
end;

procedure TMapInstruction.Parse(const ANode: TDOMNode);
begin
  FFolder := StrToInt(ANode.Attributes.GetNamedItem('folder').NodeValue);    
  FFile := StrToInt(ANode.Attributes.GetNamedItem('file').NodeValue);    
  FTarFolder := ReadInteger(ANode.Attributes.GetNamedItem('target_folder'), -1);
  FTarFile := ReadInteger(ANode.Attributes.GetNamedItem('target_file'), -1);
end;
{$endif}
