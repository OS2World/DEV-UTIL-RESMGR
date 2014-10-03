/* rdcpp.h - A Warp-compatible resource decompiler            950525 */
/* (c) Copyright Martin Lafaix 1995                                  */

#define FOR_EXEHDR 1
#define DWORD unsigned long
#define WORD  unsigned short

/* defining local structures */

#pragma pack(1) /* Force byte alignment */

typedef struct _RESHEADER
{
  BYTE b1;
  unsigned short type;
  BYTE b2;
  unsigned short name;
  unsigned short flags;
  unsigned long cb;
} RESHEADER, *PRESHEADER;

#pragma pack()

typedef struct _RESENTRY
{
  ULONG name;
  ULONG type;
  ULONG flags;
} RESENTRY, *PRESENTRY;

#define ENSURE(x)     if(rc != 0) \
                        { \
                        printf("RDCPP: " #x " error: return code = %ld\n",rc); \
                        return 1; \
                        }

/* defining local functions */
APIRET _getresourcetable(HFILE hf, PULONG pulSize, PRESENTRY *ppre);
APIRET _freeresourcetable(PRESENTRY pre);
APIRET _extractresource(HMODULE hmod, ULONG ulName, ULONG ulType, ULONG ulFlag, HFILE hf);

