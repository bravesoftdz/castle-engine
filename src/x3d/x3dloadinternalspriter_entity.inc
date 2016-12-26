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
  TEntity = class
  protected
    FId: integer;
    FName: string;
    FCharacterMaps,
    FAnimations: TFPObjectList;
  public     
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
constructor TEntity.Create;
begin
  inherited;
  FCharacterMaps := TFPObjectList.Create;   
  FAnimations := TFPObjectList.Create;
end;

destructor TEntity.Destroy;
begin
  FreeAndNil(FCharacterMaps);  
  FreeAndNil(FAnimations);
  inherited;
end;

procedure TEntity.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
  CharacterMap: TCharacterMap;
  Animation: TAnimation;
begin
  FId := ReadInteger((ANode.Attributes.GetNamedItem('id')));
  FName := ReadString(ANode.Attributes.GetNamedItem('name'));
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'character_map':
        begin
          CharacterMap := TCharacterMap.Create;
          CharacterMap.Parse(C);
          FCharacterMaps.Add(CharacterMap);
        end;
      'animation':
        begin
          Animation := TAnimation.Create;
          Animation.Parse(C);
          FAnimations.Add(Animation);
        end;
    end;
    C := C.NextSibling;
  end;
end;
{$endif}
