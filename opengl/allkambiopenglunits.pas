unit AllKambiOpenGLUnits;

{ This is automatically generated unit, useful to compile all units
  in this directory (and OS-specific subdirectories like
  unix/, linux/, and windows/).
  Don't edit.
  Don't use this unit in your programs, it's just not for this.
  Generated by Kambi's Elisp function all-units-in-dir. }

interface

uses
  beziercurve,
  curve,
  glimages,
  glmenu,
  glshaders,
  glsoundmenu,
  glversionunit,
  glw_demo,
  glw_navigated,
  glw_win,
  glwindow,
  glwindowrecentmenu,
  glwininputs,
  glwinmessages,
  glwinmodes,
  kambiglut,
  kambiglutils,
  normalizationcubemap,
  openglbmpfonts,
  openglfonts,
  openglttfonts,
  progressgl,
  shadowvolumeshelper,
  timemessages,
  {$ifdef UNIX}
  kambixf86vmode,
  xlibutils
  {$endif UNIX}
  {$ifdef MSWINDOWS}
  glwindowwinapimenu,
  openglwindowsfonts
  {$endif MSWINDOWS}
  ;

implementation

end.
