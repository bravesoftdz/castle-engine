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
{$endif}

{$ifdef read_implementation}
function ReadInteger(const ANode: TDOMNode; const ADef: integer = 0): integer;
begin
  if ANode <> nil then
    Result := StrToInt(ANode.NodeValue)
  else
    Result := ADef;
end;                         

function ReadFloat(const ANode: TDOMNode; const ADef: single= 0): single;
begin
  if ANode <> nil then
    Result := StrToFloat(ANode.NodeValue)
  else
    Result := ADef;
end;

function ReadBool(const ANode: TDOMNode; const ADef: boolean = false): boolean;
begin
  if ANode <> nil then
    Result := StrToBool(ANode.NodeValue)
  else
    Result := ADef;
end;

function ReadString(const ANode: TDOMNode; const ADef: string = ''): string;
begin
  if ANode <> nil then
    Result := ANode.NodeValue
  else
    Result := ADef;
end;
{$endif}
