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
  TFolder = class
  protected
    FId: integer;
    FName: string;
    FFiles: TFPObjectList;
  public     
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;

  TFile = class
  protected
    FId: integer;
    FName: string;
    FWidth,
    FHeight,
    FPivotX,
    FPivotY: single;
  public
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
constructor TFolder.Create;
begin
  inherited;
  FFiles := TFPObjectList.Create;
end;

destructor TFolder.Destroy;
begin
  FreeAndNil(FFiles);
  inherited;
end;

procedure TFolder.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
  File_: TFile;
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FName := ReadString(ANode.Attributes.GetNamedItem('name'));
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'file':
        begin
          File_ := TFile.Create;
          File_.Parse(C);
          FFiles.Add(File_);
        end;
    end;
    C := C.NextSibling;
  end;
end;

procedure TFile.Parse(const ANode: TDOMNode);
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FName := ReadString(ANode.Attributes.GetNamedItem('name'));
  FWidth := ReadFloat(ANode.Attributes.GetNamedItem('width'));
  FHeight := ReadFloat(ANode.Attributes.GetNamedItem('height'));
  FPivotX := ReadFloat(ANode.Attributes.GetNamedItem('pivot_x'), 0);      
  FPivotY := ReadFloat(ANode.Attributes.GetNamedItem('pivot_y'), 1);
end;
{$endif}
