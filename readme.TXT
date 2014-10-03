/* readme  - this is the readme file of the RESMGR package    960217 */

RESMGR is a collection of tools which allows you to manipulate
resources.  That is, you can add, remove or extract resources from a
binary resource file as well as from an executable file.

Enjoy!


Change Notes
============

      o  allways use external extractor program if not in list-mode
         previous version could extract garbage where trailing
         zeroes from resources are not storen in executable
         can be happen after using lxlite

      o  faster external extractor program, unpacks compression
         of resources for NE and LX executables

      o  fixed missing trailing blanks like
          STRINGTABLE 
           BEGIN
            1       "test  "
           END

         would result in
          STRINGTABLE 
           BEGIN
            1       "test"
           END

      o  non-random resource names like Pointer900.ptr
         instead of res01726.ptr
         this does not work on FAT and can disabled
         by changing in the first lines of rdc.cmd:
         create_random_names = 1


Release Notes
=============

      o  RESMGR has been tested with OS/2 Warp v3.0, but it is
         expected to work with OS/2 v2.0 or higher.

      o  Online help is included in RDC.INF.

      o  See RESMGR.ABS for a description of all included files.


Product Description
===================

      The RESMGR package contains two parts: a Resource Decompiler and
      a Resource Manager.

      The Resource Decompiler can extract resources from an executable
      file (1.x format and 2.x format, Warp packed resources
      included).  It can also "decompile" binary resource files.  That
      is, it can translate a .RES file into a corresponding .RC file.

      The Resource Manager allows you to operate at a higher level <g>
      With it, you can view binary resource files (as well as
      executable) as resource container.  That is, you can view their
      contents, and add or remove resources to/from them.

      It's not a "Resource Editor for the dummies" because it does not
      yet offers a PM front end nor does it hides you the resource
      script files mysteries.


Installation:
=============

      1. Unpack this package.

      2. Copy all .EXE and .CMD somewhere along your PATH.

      3. Copy RDC.INF somewhere along your BOOKSHELF.

      [3.bis  If you're using the OS/2 Developer's toolkit, I highly
         recommend you to add or edit the following line in your
         CONFIG.SYS:

            SET TOOLSREF=TOOLINFO.INF+RDC.INF

         and to adjust the parameter line of the "Tools References"
         icon in the "Toolkit Information" folder.]

      You're done!


Miscellaneous:
==============

      Source code for RDC.INF and RDCPP.EXE is included in SOURCE.ZIP
      (which is part of the RESMGR package).

      And, yes, it's free :-)


Common troubles:
================

      RC.EXE and RCPP.EXE must have been installed in your system if
      you want to be able to add or remove resources from an
      executable file.

      In the same flavor, REXX support should be enabled.

      RDC does not decompile Dialog resources from a .RES file.  Use
      DLGEDIT.EXE instead (the Dialog Editor is included in the OS/2
      Developer's toolkit).


Original FILE_ID.DIZ:
=====================

      RESMGR is a resource decompiler/manager.  It
      can view/add/replace/remove resources from
      either a .EXE, a .DLL or a .RES file.  It can
      also decompile these resources into a .RC
      script.  Resources can be extracted from OS/2
      1.x or OS/2 2.x files (Warp included).
      [FREEWARE, w/ source code.  960217 release.]
      Author: Martin Lafaix (lafaix@alto.unice.fr)


--
Martin Lafaix
lafaix@alto.unice.fr
