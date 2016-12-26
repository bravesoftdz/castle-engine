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
  TScmlObject = class
  protected
    FScmlVersion,
    FGenerator,
    FGeneratorVersion: string;
    FFolders,
    FEntities: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
constructor TScmlObject.Create;
begin
  inherited;
  FFolders := TObjectList.Create;
  FEntities := TObjectList.Create;
end;

destructor TScmlObject.Destroy;
begin
  FreeAndNil(FFolders);
  FreeAndNil(FEntities);
  inherited;
end;

procedure TScmlObject.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
  Folder: TFolder;
  Entity: TEntity;
begin
  FScmlVersion := ReadString(ANode.Attributes.GetNamedItem('scml_version'));
  FGenerator := ReadString(ANode.Attributes.GetNamedItem('generator'));
  FGeneratorVersion :=
      ReadString(ANode.Attributes.GetNamedItem('generator_version'));
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'folder':
        begin
          Folder := TFolder.Create;
          Folder.Parse(C);
          FFolders.Add(Folder);
        end;
      'entity':
        begin
          Entity := TEntity.Create;
          Entity.Parse(C);
          FEntities.Add(Entity);
        end;
    end;
    C := C.NextSibling;
  end;
end;
{$endif}
