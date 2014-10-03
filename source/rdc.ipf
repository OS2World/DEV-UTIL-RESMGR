.* EBOOKIE (IPFTAGS.DEF)
.* Copyright (c) 1995, 1996 Martin Lafaix. All Rights Reserved.
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
:link reftype=hd res=240 viewport group=1.Bug report:elink.
.br
:link reftype=hd res=250 viewport group=1.Copyright:elink.
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
        -r              - Extract .res file
        -l              - List resources (but do not extract)
        -h              - Access Help

Environment variables:
        TMP=temporary file path
        TEMP=temporary file path
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
rdc executable-file [resource-script-file]

rdc binary-resource-file [resource-script-file]

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
:p.In addition to -r, RC offers one other command-line option: -l.
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
:dt.-h
:dd.Access Help
:edl.
:h1 res=240 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Bug Report
:p.If you encounter a bug while using RDC or RESMGR, please send a
description of it to the following address:
:xmp.
   lafaix&atsign.alto.unice.fr
:exmp.
or
:xmp.
   Martin Lafaix
   16, rue de Dijon
   06000 Nice
   FRANCE
:exmp.
:p.Be sure to include at least your calling command and the output
produced by RDC or RESMGR.  Thank you&xclm.
:h1 res=250 x=right y=bottom width=73% height=100% hide.Resource Decompiler - Copyright
:p.The term :hp2.OS/2:ehp2. is a trademark of the IBM Corporation.
:p.RDC and RESMGR (c) Martin Lafaix 1994, 1995, 1996.
:p.Author: Martin Lafaix
.br
Address:
:xmp.
    16, rue de Dijon
    06000 Nice
    France

    email: lafaix@alto.unice.fr
:exmp.
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
