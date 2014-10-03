/* rdcpp.c - A Warp-compatible resource decompiler            950525 */
/* (c) Copyright Martin Lafaix 1995                                  */

#define  INCL_DOSRESOURCES     /* Resources values */
#define  INCL_DOSMODULEMGR     /* Module Manager values */
#define  INCL_DOSFILEMGR       /* File System values */
#define  INCL_DOSMEMMGR        /* Memory Manager values */
#include <os2.h>
#include <stdio.h>

#include "rdcpp.h"
#include <newexe.h>
#include <exe386.h>


int main(int argc, char *argv[], char *envp[])
{
  CHAR      LoadError[256];
  HMODULE   ModuleHandle;
  HFILE     hf, hDestFile;
  ULONG     ulAction, i, ulSize;
  PRESENTRY pre;
  APIRET    rc;

  /*
   * argv[1] is input file name (a DLL)
   * argv[2] is output file name (a RES)
   */
 
  /**** Extracting resource table ****/
 
  rc = DosOpen(argv[1],
               &hf,
               &ulAction,
               0,
               FILE_NORMAL,
               FILE_OPEN,
               OPEN_ACCESS_READWRITE | OPEN_SHARE_DENYREADWRITE,
               (PEAOP2) NULL);

  ENSURE(DosOpen MODULE_NAME)

  rc = _getresourcetable(hf, &ulSize, &pre);

  ENSURE(_getresourcetable)
 
  rc = DosClose(hf);
 
  ENSURE(DosClose MODULE_NAME)
  /**** Done! ****/

  /**** Opening module ****/
  rc = DosLoadModule(LoadError,
                     sizeof(LoadError),
                     argv[1],
                     &ModuleHandle);

  ENSURE(DosLoadModule)
  /**** Done! ****/

  /**** Creating resource file ****/
  rc = DosOpen(argv[2],
               &hDestFile,
               &ulAction,
               0,
               FILE_NORMAL,
               FILE_CREATE | OPEN_ACTION_REPLACE_IF_EXISTS,
               OPEN_ACCESS_WRITEONLY | OPEN_SHARE_DENYREADWRITE,
               (PEAOP2) NULL);
 
  ENSURE(DosOpen RES_FILE_NAME)
 
  printf("\n\nWriting binary resources to %s\n",argv[2]);
 
  for(i = 0; i < ulSize; i++)
    _extractresource(ModuleHandle, 
                     pre[i].name,
                     pre[i].type,
                     pre[i].flags,
                     hDestFile);

  rc = DosClose(hDestFile);
 
  ENSURE(DosClose RES_FILE_NAME)
  /**** Done! ****/

  /**** Clean up ****/
  rc = _freeresourcetable(pre);
 
  ENSURE(_freeresourcetable)
 
  rc = DosFreeModule(ModuleHandle);
 
  ENSURE(DosFreeModule)
 
  /**** Done! ****/
  return 0;
}

/* extract resource ulName.ulType from hmod, and write it with its header in hf */
APIRET _extractresource(HMODULE hmod, ULONG ulName, ULONG ulType, ULONG ulFlags, HFILE hf)
{
  ULONG     ulSize;         /* Size of the resource (returned) */
  PVOID     pvOffset;       /* Offset of the resource (returned) */
  ULONG     cbWritten;      /* Number of bytes written to file */
  RESHEADER rh;
  APIRET    rc;

  rc = DosQueryResourceSize(hmod, ulType, ulName, &ulSize);

  ENSURE(DosQueryResourceSize)

  rc = DosGetResource(hmod, ulType, ulName, &pvOffset);

  ENSURE(DosGetResource)
 
  rh.b1 = 0xFF;
  rh.type = ulType;
  rh.b2 = 0xFF;
  rh.name = ulName;
  rh.flags = ulFlags;
  rh.cb = ulSize;
  rc = DosWrite(hf, &rh, sizeof(RESHEADER), &cbWritten);
 
  ENSURE(DosWrite)
 
  rc = DosWrite(hf, pvOffset, ulSize, &cbWritten);

  ENSURE(DosWrite)
 
  rc = DosFreeResource(pvOffset);

  ENSURE(DosFreeResource)
 
  printf("    %ld.%ld (%ld)\n", ulName, ulType, ulSize);
  return 0;
}

/* get the resource table from EXE or DLL, 286 or 386 format */
APIRET _getresourcetable(HFILE hf, PULONG pulSize, PRESENTRY *ppre)
{
  ULONG     ulPos, ulDummy;
  APIRET    rc;
  char buff[2];

  rc = DosSetFilePtr(hf, 0, FILE_BEGIN, &ulDummy);

  ENSURE(DosSetFilePtr)
 
  rc = DosRead(hf, &buff, sizeof(buff), &ulDummy);
 
  ENSURE(DosRead)
 
  if(buff[0] == 'M' && buff[1] == 'Z')
    {
    /* it's a DOS header, find the new header offset */
    rc = DosSetFilePtr(hf, 60, FILE_BEGIN, &ulDummy);
    rc = DosRead(hf, &ulPos, sizeof(ulPos), &ulDummy);
    }
  else
    ulPos = 0;
 
  rc = DosSetFilePtr(hf, ulPos, FILE_BEGIN, &ulDummy);
  rc = DosRead(hf, &buff, sizeof(buff), &ulDummy);
 
  if(buff[0] == 'L' && buff[1] == 'X')
    {
    /* read the 386 header */
    struct e32_exe header;
    int i;
 
    puts("Reading OS/2 v2.x .EXE file");
 
    rc = DosSetFilePtr(hf, -sizeof(buff), FILE_CURRENT, &ulDummy);
    rc = DosRead(hf, &header, sizeof(header), &ulDummy);

    E32_MFLAGS(header) = E32NOTP|(E32_MFLAGS(header)&(E32NOEXTFIX|E32NOINTFIX));
    E32_STARTOBJ(header) = 0;
    E32_EIP(header) = 0;
    E32_STACKOBJ(header) = 0;
    E32_ESP(header) = 0;
    E32_HEAPSIZE(header) = 0;
    E32_STACKSIZE(header) = 0;
    E32_IMPMODCNT(header) = 0;
    E32_INSTDEMAND(header) = 0;
    E32_INSTPRELOAD(header) = 0;
 
    rc = DosSetFilePtr(hf, ulPos, FILE_BEGIN, &ulDummy);
    rc = DosWrite(hf, &header, sizeof(header), &ulDummy);

    *pulSize = E32_RSRCCNT(header);
 
    rc = DosAllocMem((PPVOID)ppre,
                     *pulSize*sizeof(RESENTRY),
                     PAG_READ|PAG_WRITE|PAG_COMMIT);

    ENSURE(DosAllocMem)
 
    rc = DosSetFilePtr(hf, ulPos+E32_RSRCTAB(header), FILE_BEGIN, &ulDummy);
    for(i = 0; i < *pulSize; i++)
      {
      /* read rsrctab */
      struct rsrc32 rs;
 
      rc = DosRead(hf, &rs, 14, &ulDummy); /* KLUDGE: gcc returns 16 instead of 14 for sizeof(rs) */
      (*ppre)[i].name = rs.name;
      (*ppre)[i].type = rs.type;
      (*ppre)[i].flags = rs.obj;
      }

    for(i = 0; i < *pulSize; i++)
      {
      /* read objtab (for resource flag) */
      struct o32_obj ot;
 
      rc = DosSetFilePtr(hf,
                         ulPos+E32_OBJTAB(header)+sizeof(ot)*((*ppre)[i].flags - 1),
                         FILE_BEGIN,
                         &ulDummy);
      rc = DosRead(hf, &ot, sizeof(ot), &ulDummy);
 
      (*ppre)[i].flags  = (O32_FLAGS(ot) & OBJWRITE) ? 0 : RNPURE;
      (*ppre)[i].flags |= (O32_FLAGS(ot) & OBJDISCARD) ? 4096 : 0;
      (*ppre)[i].flags |= (O32_FLAGS(ot) & OBJSHARED) ? RNMOVE : 0;
      (*ppre)[i].flags |= (O32_FLAGS(ot) & OBJPRELOAD) ? RNPRELOAD : 0;
 
      printf(".");
      }
    }
  else
  if(buff[0] == 'N' && buff[1] == 'E')
    {
    /* read the 286 header */
    struct new_exe header;
    int i;
 
    puts("Reading OS/2 v1.x .EXE file");
 
    rc = DosSetFilePtr(hf, -sizeof(buff), FILE_CURRENT, &ulDummy);
    rc = DosRead(hf, &header, sizeof(header), &ulDummy);

    NE_FLAGS(header) = NENOTP | NEPROT | NEINST;
    NE_CSIP(header) = 0;
    NE_SSSP(header) = 0;
    NE_STACK(header) = 0;
    NE_HEAP(header) = 0;
 
    rc = DosSetFilePtr(hf, ulPos, FILE_BEGIN, &ulDummy);
    rc = DosWrite(hf, &header, sizeof(header), &ulDummy);
 
    *pulSize = NE_CRES(header);
 
    rc = DosAllocMem((PPVOID)ppre,
                     *pulSize*sizeof(RESENTRY),
                     PAG_READ|PAG_WRITE|PAG_COMMIT);
 
    ENSURE(DosAllocMem)
 
    rc = DosSetFilePtr(hf, ulPos+NE_RSRCTAB(header), FILE_BEGIN, &ulDummy);
    for(i = 0; i < *pulSize; i++)
      {
      /* read rsrctab */
      struct {unsigned short type; unsigned short name;} rti;
 
      rc = DosRead(hf, &rti, sizeof(rti), &ulDummy);
      (*ppre)[i].name = rti.name;
      (*ppre)[i].type = rti.type;
      }

    for(i = 0; i < *pulSize; i++)
      {
      struct new_seg ns;
 
      rc = DosSetFilePtr(hf,
                         ulPos+NE_SEGTAB(header)+sizeof(ns)*i,
                         FILE_BEGIN,
                         &ulDummy);
      rc = DosRead(hf, &ns, sizeof(ns), &ulDummy);
 
      (*ppre)[i].flags  = (NS_FLAGS(ns) & NSPRELOAD) ? RNPRELOAD : 0;
      (*ppre)[i].flags |= (NS_FLAGS(ns) & NSSHARED) ? RNPURE : 0;
      (*ppre)[i].flags |= (NS_FLAGS(ns) & NSMOVE) ? RNMOVE : 0;
      (*ppre)[i].flags |= (NS_FLAGS(ns) & NSDISCARD) ? 4096 : 0;
 
      printf(".");
      }
    }
  else
    {
    puts("Invalid EXE header!");
    *ppre = 0;
    }
 
  return 0;
}

/* free the previously allocated resource table */
APIRET _freeresourcetable(PRESENTRY pre)
{
  if(pre)
    DosFreeMem(pre);
 
  return 0;
}
