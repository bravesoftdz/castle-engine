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

{ Spriter 2D animations loader. }
unit X3DLoadInternalSpriter;

{$I castleconf.inc}

interface

uses X3DNodes;

function LoadSpriter(URL: string): TX3DRootNode;

implementation

uses SysUtils, Classes, FGL, FpJson, JSONParser, JSONScanner, Math,
  CastleVectors, CastleUtils, CastleLog, CastleURIUtils, CastleDownload,
  CastleStringUtils, CastleClassUtils, CastleColors,
  X3DLoadInternalUtils, X3DFields, CastleGenericLists;

type
  ESpriterReadError = class(Exception);

{ XML skeleton -------------------------------------------------------------- }

  { forward declarations }

  {$define read_interface}
  {$undef read_interface}

  {$define read_implementation}
  {$undef read_implementation}

{ Main loading function ------------------------------------------------------ }

function LoadSpriter(URL: string): TX3DRootNode;
var
  S: TStream;
begin
  S := Download(URL);
  try

  finally
    FreeAndNil(S);
  end;
end;

end.
