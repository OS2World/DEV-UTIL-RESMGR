.* EBOOKIE (IPFTAGS.DEF)
.* Copyright (c) 1995-1996, 2000, 2002 Martin Lafaix. All Rights Reserved.
:userdoc.
:h1 x=left y=bottom width=27% height=100% scroll=none.Resource Decompiler
:p.Select one:
:p.:link reftype=hd res=200 auto.
:link reftype=hd res=200.Introduction:elink.
.br
:link reftype=hd res=210 viewport group=1.Help:elink.
.br
:link reftype=hd res=220 viewport group=1.Using:elink.
.br
:link reftype=hd res=230 viewport group=1.Options:elink.
.br
:link reftype=hd res=235 viewport group=1.Errors:elink.
.br
:link reftype=hd res=237 viewport group=1.Remarks:elink.
.br
:link reftype=hd res=240 viewport group=1.Bug report:elink.
.br
:link reftype=hd res=250 viewport group=1.Copyright:elink.
.br
:link reftype=hd res=255 viewport group=1.Credits:elink.
.br
:link reftype=hd res=260 viewport group=1.History:elink.
:h1 res=200 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Introduction
:lm margin=1.
:p.The OS/2* Resource Decompiler (RDC) is an application-development
tool that lets you extract application resources, such as message
strings, pointers, menus, and dialog boxes, from the executable file
of your application.  The Resource Decompiler is primarily intended to
prepare data for OS/2 applications that use functions such as
WinLoadString, WinLoadPointer, WinLoadMenu, and WinLoadDlg.  These
functions load resources from the executable file of your application
or another specified executable file.  The application can then use
the loaded resources as needed.
:p.The Resource Decompiler and the resource functions let you quickly
modify application resources without recompiling the application
itself.  That is, RDC can modify the resources in an executable file
at any time without affecting the rest of the file.  This means that
you can create custom applications from a single executable file - you
just use RDC to edit the custom resources you need to each
application.
:p.The Resource Decompiler is especially important for international
applications  because it lets you define all language-dependent data,
such as message strings,  as resources.  Preparing the application for
a new language is simply a matter of editing new resources from the
existing executable file.
:p.If Paul Ratcliffe's RES2DLG.EXE is present somewhere along your PATH,
RDC will use it to create DLG files for the dialogs resources present
in the resource file.  Otherwise, you will have to use a tool such as
DLGEDIT to extract DLG definitions from RES files.
:note.Make sure the file RDCPP.EXE (the Resource Decompiler
preprocessor) is available for the use of the Resource Decompiler.  It
can be in the current directory, or in a directory to which there is a
path.
:h1 res=210 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Help
:lm margin=1.
:p.To display Resource Decompiler help, type RDC at the prompt, with
no parameters.  The appropriate copyright statement will be displayed,
along with a list of Resource Decompiler options.
:xmp.
Usage:  rdc [<option>] <.EXE input file> [<.RC output file>]
        -r              - Extract .res file only
        -l              - List resources (but do not extract)
        -k              - Keep resources IDs in filenames
        -h              - Access Help

Environment variables:
        PATH=application file path
:exmp.
:h1 res=220 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Using
:lm margin=1.
:p.The Resource Decompiler (RDC) extracts a binary resource
file from the executable file of the application.
:p.The binary resource file is decompiled in a resource script
file.
:p.You can start RDC in any of three ways.
:ul compact.
:li.Extract and decompile a binary resource file from an executable
file.
:li.Extract a binary resource file from an executable file.
:li.Decompile a binary resource file.
:eul.
:p.The RDC command line has the following three basic forms:
:xmp.
rdc &lbrk.-k&rbrk. executable-file [resource-script-file]

rdc &lbrk.-k&rbrk. binary-resource-file [resource-script-file]

rdc -r executable-file [binary-resource-file]
:exmp.
:note.The third option does not decompile the binary resource file.
:p.The :hp2.resource-script-file:ehp2. field must be the filename of
the resource script file to be decompiled.  If the file is not in the
current directory, you must provide a full path.  If you provide a
filename without specifying a filename extension, RDC automatically
appends the &per.RC2 extension to the name.  If you omit the
resource-script-file field, RDC puts the decompiled resources to the
executable file that has the same name as the binary resource file but
which has the &per.RC2 filename extension.
:p.The :hp2.executable-file:ehp2. field must be the name of the
executable file from which to extract the compiled resources.  This is
a file having a filename extension of either .EXE or .DLL.  If the
file is not in the current directory, you must provide a full path.
If you specify the executable-file field but omit the filename
extension, RC will append the .EXE extension.  If this executable file
does not exist, RDC displays an error message.
:p.The :hp2.-r:ehp2. option directs RDC to extract the binary
resource file without decompiling it to a resource script file.  You
can use this option to prepare a binary resource file that you can
decompile to a resource script file at a later time.  If you do not
explicitly name a binary resource file along with the -r option, RDC
uses the same name as the executable file but with the .RES filename
extension.
:p.The :hp2.binary-resource-file:ehp2. field must be the name of the
binary resource file to be extracted from the executable file.  If the
binary resource file does not already exist, rdc creates it;
otherwise, rdc replaces the existing file.  If the file is not in the
current directory, you must provide a full path.  The binary resource
file must have the .RES filename extension.
:p.The :hp2.-k:ehp2. option forces the creation of verbose filenames
for extracted resources.  By default, RDC creates unique (but somewhat
cryptic) filenames of the form 'RES?????.EXT', where EXT describes the
resource type.  The verbose filenames are of the form 'NameID.EXT',
where Name is an friendlier form of EXT and ID is the real resource
ID.  The drawback of this option is that decompiling two resources
files both containing a resource with the same type and ID causes
conflict (and hence the resource is only accurate for the last
decompiled resource file).
:p.For example, to extract the binary resource file EXAMPLE.RES from
the executable file EXAMPLE.EXE and decompile it to the resource
script file EXAMPLE.RC2, use the following command:
:xmp.
   rdc example.exe
:exmp.
:p.RDC creates the binary resource file EXAMPLE.RES and puts the
decompiled resources to the resource script file EXAMPLE.RC2.
:p.To extract the binary resource file from EXAMPLE.EXE without
decompiling the resources to a resource script file, use the following
command:
:xmp.
   rdc -r example.exe
:exmp.
:p.The decompiler creates the binary resource file EXAMPLE.RES.  To
create a binary resource file that has a name different from the
executable file, use the following command:
:xmp.
   rdc -r example.exe newfile.res
:exmp.
:p.To decompile the compiled resources in the binary resource file
EXAMPLE.RES to a resource script file, use the following command:
:xmp.
   rdc example.res
:exmp.
:p.To specify the name of the resource script file, if the name is
different from the resource file, use the following command:
:xmp.
   rdc example.res newfile.rc
:exmp.
:p.To extract the compiled resources of a dynamic-link-library (.DLL)
file, use the following command:
:xmp.
   rdc -r dynalink.dll
:exmp.
:p.In addition to -r and -k, RC offers one other command-line option: -l.
The -l option lets you view the resources contained in an
executable file.  The syntax is as follows:
:xmp.
   rdc -l executable-file
:exmp.
:h1 res=230 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Options
:lm margin=1.
:p.The following options can be specified on the Resource Decompiler
command line:
:dl.
:dt.-r
:dd.Extract .res file
:dt.-l
:dd.List content of a .exe file
:dt.-k
:dd.Keep resources IDs in filenames
:dt.-h
:dd.Access Help
:edl.
:h1 res=235 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Options
:lm margin=1.
:p.The Resource Decompiler can return three values: 0, 1, or 2.  0
means success.  1 means an error occured during the operation.  2
means the specified resource file contained no resources.
:p.When the return code is 1, an error message is also displayed.  It
can be one of the following:
:dl compact break=all.
:dt.Missing input file name
:dd.No input file name was specified.  Except for the -H option
(help), you have to specify an input file name.
:dt.Too many parameters
:dd.At least one extra parameter was specified.  There can be at most
three parameters: the option, the mandatory input file name, and
when appropriate, an optional output file name.
:dt.Invalid input file header
:dd.The specified input file is not valid for the Resource Decompiler.
A 16 bit OS/2 executable, or a 32 bit OS/2
executable was expected, but the specified input file was neither of
those.
:dt.Invalid .RES input file
:dd.The specified input file was not a valid .RES file.  If the .RES
file was produced by the Resource Decompiler, please report this as it
is a bug.
:dt.Invalid resource entry
:dd.One of the entries in the specified .RES input file is not valid.
 If the .RES file was produced by the Resource Decompiler, please
report this as it is a bug.
:dt.Invalid RCDATA entry
:dd.One of the entries in the specified .RES input file is an invalid
RCDATA block.  If the .RES file was produced by the Resource
Decompiler, please report this as it is a bug.
:edl.
:h1 res=237 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Remarks
:p.The Resource Decompiler tries to produce .RC2 files that are
compatible with all existing versions of RC.  Alas, IBM made many
different versions of RC, all with their idiosyncrasies.
:p.In particular, recents RC versions (v5.x) handle excape sequences
in strings incorrecly.  The Resource Decompiler works around this
bug, but this produces less readable code.  For example:
:xmp.
  "Foo&bsl.x0d&bsl.x0aBar"
:exmp.
works as expected with RC v3.x and v4.x, but is interpreted as:
:xmp.
  "Foo&bsl.x0d&bsl.x0a&bsl.xBar"
:exmp.
by RC v5.x.  To work around this, the Resource Decompiler produces:
:xmp.
  "Foo&bsl.x0d&bsl.x0a&bsl.x42&bsl.x61r" /* "Foo..Bar" */
:exmp.
(Note the generated comment, that helps understanding the string
content.)
:p.Another example are the RCDATA resources.  Not all RC versions
allows to define them in external files.  Hence, the Resource
Decompiler inline them in the .RC2 script.  Alas, due to the fact that
RC only understand words and longs constants (i.e., 16 or 32 bit
values), RCDATA with an odd length have to be handled in a weird way
(an empty string "" is used to produce a null byte value).
:p.Here is an example of a RCDATA resource as produced by the Resource
Decompiler (from a French WPCONMRI.DLL):
:xmp.
RCDATA 5000
BEGIN
  0x72756F53L, 0x43007369L, 0x6976616CL, 0x50007265L, /* Souris.Clavier.P */
  0x00737961L, 0x6C726F48L, 0x0065676FL, 0x656C6150L, /* ays.Horloge.Pale */
  0x20657474L, 0x70206564L, 0x63696C6FL, 0x50007365L, /* tte de polices.P */
  ...
  0x6220656EL, 0x65747461L, 0x00656972L, ""           /* ne batterie.. */
END
:exmp.
:p.(Note the fact that the hex values are to be considered in little
endian form.  For example, the first long word 0x72756F53L will be
written least significant bytes first in the .RES file: byte 0x53,
followed by byte 0x6F, followed by byte 0x75, followed by byte
0x72---in other words, "Sour" will be written.)
:p.Yet another RC quirk is that it ignores the LOADONCALL, MOVEABLE,
and DISCARDABLE attributes for pointers and bitmaps resources.  Alas,
RC v3.x and 4.x always replace those attributes with "LOADONCALL
MOVEABLE DISCARDABLE" while RC v5.x use "LOADONCALL MOVEABLE" in .RES
files.  But then, all RC versions ignore those attributes when binding
the resources to an executable, always using "LOADONCALL MOVEABLE
DISCARDABLE".  As there is no possible way to handle this oddity in a
version-agnostic manner, the Resource Decompiler preserves the
attributes defined.
:p.As a final remark, RC v5.x often forgets to remove the
RC???????.C2T files it creates in your TMP/TEMP directory.  Neither
the Resource Decompiler nor the Resource Manager try to clean those
up, as they have no way to know whether those files were created due
to them calling RC or not.
:h1 res=240 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Bug Report
:p.If you encounter a bug while using RDC or RESMGR, please send a
description of it to the following address:
:xmp.
   lafaix&atsign.online.fr
:exmp.
or
:xmp.
   Martin Lafaix
   8, rue Berthollet
   75005 Paris
   FRANCE
:exmp.
:p.Be sure to include at least your calling command and the output
produced by RDC or RESMGR.  Thank you&xclm.
:h1 res=250 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Copyright
:p.The term :hp2.OS/2:ehp2. is a trademark of the IBM Corporation.
:p.RDC and RESMGR (c) Martin Lafaix 1994-1996, 2000, 2002.
:p.Author: Martin Lafaix
.br
Address:
:xmp.
    8, rue Berthollet
    75005 Paris
    France

    email: lafaix@online.fr
:exmp.
:h1 res=255 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Credits
:p.I thank Veit Kannegieser, Christian Langanke, Yuri Proniakin, and
Paul Ratcliffe for their numerous comments, suggestions and
contributions.
:p.Veit Kannegieser wrote the new RDCPP preprocessor used from v2.11
onward.
:p.Evgeny Brednya wrote the UNRC application included in v2.15 onward.
:h1 x=left y=bottom width=27% height=100% scroll=none.Resource Manager
:p.Select one:
:p.:link reftype=hd res=300 auto.
:link reftype=hd res=300.Introduction:elink.
.br
:link reftype=hd res=310 viewport group=1.Help:elink.
.br
:link reftype=hd res=320 viewport group=1.Using:elink.
.br
:link reftype=hd res=330 viewport group=1.Options:elink.
.br
:link reftype=hd res=237 viewport group=1.Remarks:elink.
.br
:link reftype=hd res=240 viewport group=1.Bug report:elink.
.br
:link reftype=hd res=250 viewport group=1.Copyright:elink.
.br
:link reftype=hd res=360 viewport group=1.History:elink.
:h1 res=300 x=right y=bottom width=73% height=100% hide.Resource Manager - Introduction
:lm margin=1.
:p.The OS/2* Resource Manager (RESMGR) is an application-development
tool that lets you manage application resources, such as
message, strings, pointers, menus, and dialog boxes.
:p.You can start RESMGR with a single command from the command line.
:p.With RESMGR, you can:
:ul compact.
:li.Extract specified resources from a file.
:li.Add resources to a file.
:li.View the resources included in a file.
:li.Delete specified resources from a file.
:eul.
:note.In the previous list, "file" can be a binary resource file or an
executable file.
:h1 res=310 x=right y=bottom width=73% height=100% hide.Resource Manager - Help
:lm margin=1.
:p.To display Resource Manager help, type RESMGR at the prompt, with
no parameters.  The appropriate copyright statement will be displayed,
along with a list of Resource Manager options.
:xmp.
Usage:  resmgr <option> <.RES file> [id.type] [file]
        -a              - Add specified resources (default)
        -d              - Delete specified resources
        -l              - List resources (short format)
        -v              - List resources (long format)
        -x              - Extract specified resources
        -h              - Access Help

        .RES file       = .RES, .EXE or .DLL filename
        file            = Input or output file name
        type            = Resource type or *
        id              = Resource ID or *

Possible type value (with -d, -l, -v or -x):

  Acceltable Bitmap   Chartbl Dialog  Displayinfo  Dlginclude Fd     Fddir
  Fkalong    Fkashort Font    Fontdir Helpsubtable Helptable  Keytbl Menu
  Messagetable        Pointer RCData  Stringtable  Vkeytbl

Environment variables:
        TMP=temporary file path
        TEMP=temporary file path
:exmp.
:h1 res=320 x=right y=bottom width=73% height=100% hide.Resource Manager - Using
:lm margin=1.
:p.The Resource Manager (RESMGR) manages resources from binary
resource files or executable files.
:p.You can start RESMGR in any of four ways.
:ul compact.
:li.Add a binary resource file to a file.
:li.Extract specified resources from a file.
:li.Remove specified resouces from a file.
:li.List specified resources from a file.
:eul.
:p.The RESMGR command line has the following four basic forms:
:xmp.
resmgr -a file binary-resource-file

resmgr -x file [id.type] [binary-resource-file]

resmgr -d file [id.type]

resmgr -l file [id.type]  -or-  resmgr -v file [id.type]
:exmp.
:p.The :hp2.file:ehp2. field must be the name of the executable or
binary resource file from which to manage the resources.  This is a
file having a filename extension of either .RES, .EXE or .DLL.  If the
file is not in the current directory, you must provide a full path.
If this file does not exist, RESMGR displays an error message.
:note.You cannot perform "destructive" actions (:hp2.-A:ehp2. or
:hp2.-D:ehp2.) if the file is in use.  If you want to do so, close
the program using the file, or make your modifications over a copy of
the file, and replace it later when it is no longer used.
:p.The :hp2.id.type:ehp2. field can be used to specify a range of
resources.  The :hp2.id:ehp2. part is either "*" or a number (the
resource ID), while the :hp2.type:ehp2. part can be "*", a resource
type name (such as DIALOG, STRING, or ...) or a number (the resource
type ID).  If this field is specified, the requested command will only
affect the specified resources.
:p.The :hp2.binary-resource-file:ehp2. field must be the name of the
binary resource file to be added or extracted from the file. If the
binary resource file does not already exist, rdc creates it;
otherwise, rdc replaces the existing file.  If the file is not in the
current directory, you must provide a full path.  The binary resource
file must have the .RES filename extension.
:p.For example, to view all resources included in the binary
resource file EXAMPLE.RES, use the following command:
:xmp.
   resmgr -v example.res
:exmp.
:p.To only view all Dialog resources included in the binary
resource file EXAMPLE.RES, use the following command instead:
:xmp.
   resmgr -v example.res *.dialog
:exmp.
:p.To extract the all string resources included in EXAMPLE.EXE, use
the following command:
:xmp.
   resmgr -x example.exe *.string example.res
:exmp.
:p.The manager creates the binary resource file EXAMPLE.RES.  To add
resources to a file, use the following command:
:xmp.
   resmgr -a example.exe newfile.res
:exmp.
:p.The resources included in NEWFILES.RES will be added in
EXAMPLE.EXE.  If a resource already exists in the file, it will be
replaced (but if a resource is present in EXAMPLE.RES but not in
NEWFILE.RES, it will be preserved).
:p.To remove the resource 123.999 from EXEMPLE.RES, use the
following command:
:xmp.
   resmgr -d example.res 123.999
:exmp.
:p.123 is the resource ID and 999 is the resource type ID (a
user-defined one).
:note.Not all versions of RC (the system-provided resource compiler)
are able to remove all resources from a file.  If your version is
one of those, RESMGR will insert a dummy resource (a STRINGTABLE
with just one entry at ID 1, containing nothing).  Please also note
that some versions of RC may left 0-bytes .RES files in your temp
directory.  You can safely remove those.
:h1 res=330 x=right y=bottom width=73% height=100% hide.Resource Manager - Options
:lm margin=1.
:p.The following options can be specified on the Resource Manager
command line:
:dl.
:dt.-a
:dd.Add resources to a file
:dt.-d
:dd.Remove specified resources from a file
:dt.-l
:dd.List specified resource content of a file (short form)
:dt.-v
:dd.List specified resource content of a file (long form)
:dt.-x
:dd.Extract specified resources from a file
:dt.-h
:dd.Access Help
:edl.
:h1 res=260 x=right y=bottom width=73% height=100% hide.Resource Decompiler - History
:font facename=Helv size=12x12.
:xmp.
.im HISTORY.RDC
:exmp.
:font facename=default.
:h1 res=360 x=right y=bottom width=73% height=100% hide.Resource Manager - History
:font facename=Helv size=12x12.
:xmp.
.im HISTORY.MGR
:exmp.
:font facename=default.
:euserdoc.
