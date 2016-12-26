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

uses SysUtils, Classes, Contnrs, DOM, XMLRead, Math,
  CastleVectors, CastleUtils, CastleLog, CastleURIUtils, CastleDownload,
  CastleStringUtils, CastleClassUtils, CastleColors,
  X3DLoadInternalUtils, X3DFields, CastleGenericLists;

type
  ESpriterReadError = class(Exception);

{ XML skeleton -------------------------------------------------------------- }

type
  { forward declarations }
  { For scml file format/pseudo code, please refer to
    http://www.brashmonkey.com/ScmlDocs/ScmlReference.html }

  {$define read_interface}
  {$I x3dloadinternalspriter_scmlobject.inc}
  {$I x3dloadinternalspriter_filefolder.inc}
  {$I x3dloadinternalspriter_entity.inc}
  {$I x3dloadinternalspriter_charactermap.inc}
  {$I x3dloadinternalspriter_animation.inc}
  {$I x3dloadinternalspriter_mainlinekey.inc}
  {$I x3dloadinternalspriter_timeline.inc}
  {$undef read_interface}

  {$define read_implementation}           
  {$I x3dloadinternalspriter_xml.inc}
  {$I x3dloadinternalspriter_scmlobject.inc} 
  {$I x3dloadinternalspriter_filefolder.inc}
  {$I x3dloadinternalspriter_entity.inc}
  {$I x3dloadinternalspriter_charactermap.inc}
  {$I x3dloadinternalspriter_animation.inc}
  {$I x3dloadinternalspriter_mainlinekey.inc}
  {$I x3dloadinternalspriter_timeline.inc}
  {$undef read_implementation}

{ Main loading function ------------------------------------------------------ }

function LoadSpriter(URL: string): TX3DRootNode;
var
  S: TStream;
  Doc: TXMLDocument;
  ScmlObject: TScmlObject;
begin
  S := Download(URL);
  try
    ReadXMLFile(Doc, S);
    try
      Result := TX3DRootNode.Create('', URL);
      try
        ScmlObject := TScmlObject.Create;
        try
          ScmlObject.Parse(Doc.FindNode('spriter_data'));
        finally
          FreeAndNil(ScmlObject);
        end;
      except
        FreeAndNil(Result);
        raise;
      end;
    finally
      FreeAndNil(Doc);
    end;
  finally
    FreeAndNil(S);
  end;
end;

end.
