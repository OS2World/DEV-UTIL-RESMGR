/* resmgr.cmd -- A "zip-like" .RES manager                    960217 */
/* (c) Copyright Martin Lafaix 1995, 1996                            */

say 'Operating System/2  Resource Manager'
say 'Version 0.04.000 Feb 17 1996'
say '(C) Copyright Martin Lafaix 1995, 1996'
say 'All rights reserved.'
say

parse upper value translate(arg(1),'\','/') with param orgfile outfile x y
tempneeded = 0; modified = 0; nl = '0d0a'x; rid = ''; rtype = ''
typeName = '/POINTER /BITMAP /MENU /DIALOG /STRING /FONTDIR /FONT /ACCELTABLE /RCDATA',
           '/MESSAGE /DLGINCLUDE /VKEYTBL /KEYTBL /CHARTBL /DISPLAYINFO /FKASHORT',
           '/FKALONG /HELPTABLE /HELPSUBTABLE /FDDIR /FD'

call RxFuncAdd 'SysTempFileName', 'RexxUtil', 'SysTempFileName'

if param = '-H' | param = '' | y \= '' then
   do
      say 'Usage:  resmgr <option> <.RES file> [id.type] [file]'
      say '        -a              - Add specified resources (default)'
      say '        -d              - Delete specified resources'
      say '        -l              - List resources (short format)'
      say '        -v              - List resources (long format)'
      say '        -x              - Extract specified resources'
      say '        -h              - Access Help'
      say
      say '        .RES file       = .RES, .EXE or .DLL filename'
      say '        file            = Input or output file name'
      say '        type            = Resource type or *'
      say '        id              = Resource ID or *'
      say
      say 'Possible type value (with -d, -l, -v or -x):'
      say
      say '  Acceltable Bitmap   Chartbl Dialog  Displayinfo  Dlginclude Fd     Fddir'
      say '  Fkalong    Fkashort Font    Fontdir Helpsubtable Helptable  Keytbl Menu'
      say '  Messagetable        Pointer RCData  Stringtable  Vkeytbl'
      say
      say 'Environment variables:'
      say '        TMP=temporary file path'
      say '        TEMP=temporary file path'
      if y \= '' then
         exit 1
      else
         exit
   end

if param \= '-A' & param \= '-D' & param \= '-L' & param \= '-X' & param \= '-V' then
   call error 'Invalid option :' param, 2

if verify(orgfile,'*?<>|"','M') > 0 then
   call error 'Invalid file name :' orgfile, 1

if charin(orgfile,1,1) \= 'FF'x then
   do
      call stream orgfile, 'c', 'close'
      tempneeded = 1
      tempname = gettemp('RES?????.RES')
      '@call rdc -r' orgfile tempname '>nul'
      if rc \= 0 then
         call error 'Invalid input file :' orgfile, 1
      infile = tempname
   end
else
   infile = orgfile

call initialize
 
call charin infile,1,0
do while chars(infile) > 0
   call skip 1
   rt = readw()
   call skip 1
   id = readw()
   opt = readw()
   cb = readl()
 
   if (rtype = '*' | rt = rtype) & (rid = '*' | id = rid) then
      select
         when param = '-A' then call add
         when param = '-D' then do; modified = 1; say '    'id'.'rt' ('cb' bytes)'; end
         when param = '-L' then call shows
         when param = '-V' then call showl
         when param = '-X' then do; say '    'id'.'rt' ('cb' bytes)'; call extract; end
      end  /* select */
   else
   if param = '-D' then
      call extract
 
   call skip cb
end /* do */

call terminate

exit

terminate: /* do option-dependant termination */
   if param = '-D' | param = '-A' then
      do
         call stream infile, 'c', 'close'
         call stream outfile, 'c', 'close'
         if modified then
            '@copy' outfile infile '>nul'
         '@del /f' outfile
      end
   if tempneeded & modified then
      '@call rc' infile orgfile '>nul'
   if tempneeded then
      do
         call stream infile, 'c', 'close'
         '@del /f' infile
      end
   return
 
initialize: /* do option-dependant initialisation */
   select
      when param = '-A' then
         do
            if x \= '' then
               call error 'Too many arguments for -A :' x, 1
            call getspec ''
            oinfile = infile; infile = outfile; addedResources = '';
            call charin infile,1,0
            do while chars(infile) > 0
               modified = 1
               call skip 1
               rt = readw()
               call skip 1
               id = readw()
               opt = readw()
               addedResources = addedResources id'.'rt
               cb = readl()
               call skip cb
            end /* do */
            call stream infile, 'c', 'close'
            outfile = gettemp('RES?????.TMP')
            '@copy' infile outfile '>nul'
            infile = oinfile
         end
      when param = '-L' | param = '-V' then
         do
            call getspec outfile
            if param = '-L' then
               do
                  say 'Res.ID   Resource type   Res. size'
                  say '----------------------------------'
               end
            else
               do
                  say 'Res.ID   Resource type       Res. size   Res. flags'
                  say '------------------------------------------------------------'
               end
         end
      when param = '-X' then
         do
            if x = '' then
               call getspec ''
            else
               do
                  call getspec outfile
                  outfile = x
               end
            if verify(outfile,'*?<>|"','M') > 0 then
               call error 'Invalid file name :' outfile, 1
            if stream(outfile,'c','query exists') \= '' then
               '@del' outfile
            say 'Extracting...'
         end
      when param = '-D' then
         do
            call getspec outfile
            outfile = gettemp('RES?????.TMP')
            say 'Removing...'
         end
   otherwise
   end  /* select */
   return

add:     /* add specified resource to outfile if not present */
   if wordpos(id'.'rt,addedResources) > 0 then
      return
extract: /* extract specified resource */
   call emit 'FF'x||d2w(rt)'FF'x||d2w(id)d2w(opt)d2l(cb)
   call emit charin(infile,,cb)
   cb = 0
   return

shows:   /* display specified resource info (short format) */
   call charout ,right(id,6)'   '
   if rt < 22 then
      call charout ,left(substr(word(typeName,rt),2),15)
   else
      call charout ,left(rt,15)
   call charout ,right(cb,10)nl
   return

showl:   /* display specified resource info (long format) */
   call charout ,right(id,6)'   '
   if rt < 22 then
      call charout ,left(substr(word(typeName,rt),2) '('rt')',19)
   else
      call charout ,left(rt,19)
   call charout ,right(cb,10)'   'option()nl
   return
 
option:  /* convert flags to option string */
   if bit(opt,10) then r = 'PRELOAD'; else r = 'LOADONCALL'
   if bit(opt,12) then r = r' MOVEABLE'
   if bit(opt, 4) then r = r' DISCARDABLE'
   if \ (bit(opt,4) | bit(opt,12)) then r = r' FIXED'
   if r = 'LOADONCALL MOVEABLE DISCARDABLE' then r = ''
   return r

getspec: /* get resources specs as described in arg(1) */
   procedure expose rid rtype typeName
   if arg(1) \= '' then
      parse value arg(1) with rid '.' rtype
   parse value rid rtype '* *' with rid rtype .
   if wordpos('/'rtype, typeName) > 0 then
      rtype = wordpos('/'rtype, typeName)
   return

gettemp: /* get a temp file name following arg(1) specs */
   procedure
   tempdir = value('TMP',,'OS2ENVIRONMENT')
   if tempdir = '' then tempdir = value('TEMP',,'OS2ENVIRONMENT')
   if tempdir = '' then tempdir = directory()
   tempdir = translate(tempdir,'\','/')
   if tempdir \= '' & right(tempdir,1) \= '\' then tempdir = tempdir||'\'
   return SysTempFileName(tempdir||arg(1))

emit:    /* write data to output file */
   return charout(outfile,arg(1))
 
readw:   /* read one word from infile */
   return w2d(charin(infile,,2))

readl:   /* read one long from infile */
   return l2d(charin(infile,,4))

skip:    /* skip arg(1) chars */
   return charin(infile,,arg(1))

bit:     /* return bit arg(2) of arg(1) */
   return substr(x2b(d2x(arg(1),4)), arg(2),1)

w2d:     /* littleendian word to decimal */
   w = c2x(arg(1))
   return x2d(substr(w,3,2)substr(w,1,2))

d2w:     /* decimal to littleendian word */
   w = d2x(arg(1),4)
   return x2c(substr(w,3,2)substr(w,1,2))

l2d:     /* littleendian long to decimal */
   l = c2x(arg(1))
   return x2d(substr(l,7,2)substr(l,5,2)substr(l,3,2)substr(l,1,2))

d2l:     /* decimal to littleindian long */
   l = d2x(arg(1),8)
   return x2c(substr(l,7,2)substr(l,5,2)substr(l,3,2)substr(l,1,2))
 
error:   /* display arg(1) and exit with code arg(2) */
   say arg(1)
   exit arg(2)
