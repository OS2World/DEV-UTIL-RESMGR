(*$Delphi+,X+*)
{&Use32+}
program rdc2;

(* 2000.01.17 Veit Kannegieser *)
(* 2000.01.19 V.K.: VPPM.EXE R216 (liest Åber rle-Seite hinaus-kein richtiges Ende) *)
(* 2002.04.10 StOpenRead,
              28 byte stub
              no outputfile if no resources *)
(* 2002.04.11 NE format for OS/2, tried Windows but result is to different for rdc.cmd *)

uses
  ExeHdr,
  Objects,
  VpUtils;

const
  datum                         ='2000.01.17..2002.04.11';
  _00                           :byte=$00;
  _ff                           :byte=$ff;
  _0000                         :smallword=$0000;

type

  longint_z                     =^longint;
  smallword_z                   =^smallword;
  byte_z                        =^byte;
  string_z                      =^string;

  obj_tabelle_typ               =array[1..  1000] of o32_obj;
  seiten_tabelle_typ            =array[1..100000] of o32_map;
  resource_tabelle_typ          =array[1..100000] of rsrc32;
  obj_speicher_typ              =array[0..$7fffffff] of byte;

var
  d1,d2                         :pBufStream;

  exe_kopf:
    packed record
      e                         :exe;
      r                         :array[SizeOf(exe)..$3f] of byte;
    end;
  x_exe_ofs                     :longint;

  ne_kopf                       :new_exe;
  lx_kopf                       :e32_exe;
  loader_section                :pointer;
  obj_tabelle                   :^obj_tabelle_typ;
  seiten_tabelle                :^seiten_tabelle_typ;
  resource_tabelle              :^resource_tabelle_typ;

  akuelles_obj                  :longint;
  resource_zaehler              :longint;
  obj_speicher                  :^obj_speicher_typ;
  objekt_bits                   :smallword;

procedure Fehler(const f:longint;const zk:string);
  begin
    Write(zk);
    Halt(f);
  end;

procedure IOCheck(var d:pBufStream);
  var
    r:longint;
  begin
    r:=d^.status;
    if r<>stOK then
      Fehler(r,'stream I/O error.');
  end;

function lade_lx_seite(const seitennummer:longint;const offs:longint):longint;
  var
    tmp                       :array[0..4096-1] of byte;
    pagesize                  :longint;

  procedure kopiere(const quelle,ziel;const laenge:longint);assembler;
    (*$FRAME-*)(*$USES ESI,EDI,ECX*)
    asm
      mov esi,quelle
      mov edi,ziel
      mov ecx,laenge
      cld
      rep movsb
    end;

  procedure un_exepack1(const ql:longint);
    var
      quelle                    :longint;
      ziel                      :longint;
      mehrfach                  :longint;
      laenge                    :longint;
      qe                        :longint;
    begin
      quelle:=Ofs(tmp)+Low(tmp);
      qe:=quelle+ql;
      ziel:=offs;
      repeat
        mehrfach:=MemW[quelle];
        Inc(quelle,2);
        if mehrfach=0 then break;

        laenge:=MemW[quelle];
        Inc(quelle,2);

        while mehrfach>0 do
          begin
            Move(Mem[quelle],Mem[ziel],laenge);
            Dec(mehrfach);
            Inc(ziel,laenge);
          end;

        Inc(quelle,laenge);
      until quelle>=qe;
    end;

  (* -> OS2EXE.PAS LXLITE 1.21 *)
  procedure un_exepack2(const ql:longint);
    var
      quelle                    :longint;
      ziel                      :longint;
      laenge                    :longint;
      steuerwort                :longint;
      qe                        :longint;
    begin

      quelle:=Ofs(tmp)+Low(tmp);
      qe:=quelle+ql;
      ziel:=offs;
      repeat

        steuerwort:=MemW[quelle];
        case (steuerwort and $3) of
          0: (* Fall 0 *)
            begin
              (* Bits 23..16          = FÅllbyte
                 Bits 15.. 8          = laenge2
                 Bits  7.. 2          = laenge
                 Bits  1.. 0          = Fall          *)

              (* Fall 0, laenge0 *)
              if Lo(steuerwort)=0 then
                begin

                  (* FÅllen (laenge2) *)
                  laenge:=Hi(steuerwort);

                  (* laenge2=0 ? -> Ende *)
                  if laenge=0 then
                    break;

                  FillChar(Mem[ziel],laenge,Mem[quelle+2]);
                  Inc(quelle,3);
                  Inc(ziel,laenge);
                end
              else
                begin
                  (* Block kopieren (laenge) *)
                  laenge:=Lo(steuerwort) shr 2;
                  kopiere(Mem[quelle+1],Mem[ziel],laenge);
                  Inc(quelle,1+laenge);
                  Inc(ziel,laenge);
                end;
            end;

          1: (* Fall 1 *)
            begin
              (* Bits 15.. 7          = rueckwaerts
                 Bits  6.. 4      +3  = laenge2
                 Bits  3.. 2          = laenge1
                 Bits  1.. 0          = Fall          *)

              (* laenge1 kopieren *)
              laenge:=(steuerwort shr 2) and 3;
              kopiere(Mem[quelle+2],Mem[ziel],laenge);
              Inc(quelle,2+laenge);
              Inc(ziel,laenge);
              (* laenge2 vom entpackten holen *)
              laenge:=((steuerwort shr 4) and $7)+3;
              kopiere(Mem[ziel-(steuerwort shr 7)],Mem[ziel],laenge);
              Inc(ziel,laenge);
            end;

          2: (* Fall 2 *)
            begin
              (* Bits 15.. 4          = rueckwaerts
                 Bits  3.. 2   +3     = laenge
                 Bits  1.. 0          = Fall          *)

              laenge:=((steuerwort shr 2) and $3)+3;
              kopiere(Mem[ziel-(steuerwort shr 4)],Mem[ziel],laenge);
              Inc(quelle,2);
              Inc(ziel,laenge);
            end;

          3: (* Fall 3 *)
            begin
              steuerwort:=MemL[quelle];
              (* Bits 23..21          = ?
              (* Bits 20..12          = rueckwaets
                 Bits 11.. 6          = laenge2
                 Bits  5.. 2          = laenge1
                 Bits  1.. 0          = Fall          *)

              (* Block kopieren (laenge1) *)
              laenge:=(steuerwort shr 2) and $f;
              kopiere(Mem[quelle+3],Mem[ziel],laenge);
              Inc(quelle,3+laenge);
              Inc(ziel,laenge);

              (* schon entpacktes nochmal kopieren (laenge2) *)
              laenge:=(steuerwort shr 6) and $3f;
              kopiere(Mem[ziel-((steuerwort shr 12) and (4096-1))],Mem[ziel],laenge);
              Inc(ziel,laenge);
            end;

        end; (* case *)

      until quelle>=qe;

    end;

  begin (* lade_lx_seite *)
    with seiten_tabelle^[seitennummer] do
      begin

        d1^.Seek((*x_exe_ofs!+*)lx_kopf.e32_datapage+(o32_pagedataoffset shl lx_kopf.e32_pageshift));
        IOCheck(d1);

        case o32_pageflags of
          Valid:
            begin
              d1^.Read(Ptr(offs)^,o32_pageSize);
              IOCheck(d1);
            end;

          IterData:
            begin (* Fehler(99,'/EXEPACK:1'); *)
              d1^.Read(tmp,o32_pageSize);
              IOCheck(d1);
              un_exepack1(o32_pageSize);
            end;

          Invalid:
            Fehler(99,'"invalid page"(2)');

          Zeroed:
            ;
          Range:
            Fehler(99,'"Range"(4)');

          IterData2:
            begin
              d1^.Read(tmp,o32_pageSize);
              IOCheck(d1);
              un_exepack2(o32_pageSize);
            end;


        else
            Fehler(99,'invalid page flags:$'+Int2Hex(o32_pageflags,4));
        end;

      end;

    Result:=0;
  end;

procedure lade_obj(const o:longint);
  var
    sz:longint;
  begin
    if akuelles_obj<>-1 then
      Dispose(obj_speicher);

    akuelles_obj:=o;
    if o=-1 then exit;

    with obj_tabelle^[o] do
      begin
        {
        objekt_bits:=$0030;

        (* Big/Default bit setting (bit 12) *)
        if (o32_flags and ObjBigDef)<>0 then
          objekt_bits:=objekt_bits or $1000;

        (* preload/loadoncall (Bit 10) *)
        if (o32_flags and ObjDynamic)<>0 then
          objekt_bits:=objekt_bits or $0040;

        (* Bit 11 -> $10 ? *)

        (* discardable/fixed *)
        if (o32_flags and ObjDiscard)=0 then
          objekt_bits:=objekt_bits and (not $1010); (* nur $0020 *)


        (* shared/nonshared .. ist in der EXE nicht mehr erkennbar *)}

        if (o32_flags and ObjWrite)<>0 then
          objekt_bits:=0
        else
          objekt_bits:=RNPURE;

        if (o32_flags and ObjDiscard)<>0 then
          objekt_bits:=objekt_bits or 4096;

        if (o32_flags and ObjShared)<>0 then
          objekt_bits:=objekt_bits or RNMove;

        if (o32_flags and ObjPreLoad)<>0 then
          objekt_bits:=objekt_bits or RNPreLoad;

        //Write(Int2Hex(o,4),' ',Int2Hex(o32_flags,8),' ',Int2Hex(objekt_bits,4));

        GetMem(obj_speicher,o32_Size+4096); (* clres.dll *)
        FillChar(obj_speicher^,o32_Size,0);
        for sz:=1 to o32_mapSize do
          lade_lx_seite(o32_pagemap+sz-1,Ofs(obj_speicher^[4096*(sz-1)]));
      end;

  end;

procedure create_outputfile;
  begin
    d2:=New(pBufStream,Init(ParamStr(2),stCreate,8*1024));
    if d2^.Status<>stOK then
      Fehler(4,ParamStr(2)+' ?');
  end;


procedure extract_os2_ne_resources;
  type
    os2_ne_resource_table_type  =array[1..$ffff] of
      packed record
        r_type,
        r_id                    :smallword;
      end;
    ne_seg_tabelle_typ          =packed array[1..$ffff] of new_seg;

  var
    os2_ne_resource_table       :^os2_ne_resource_table_type;
    ne_seg_tabelle              :^ne_seg_tabelle_typ;
    i                           :word;
    reso,reso_u                 :pByteArray;
    q,t                         :longint;

  begin
    WriteLn('* OS/2 1.x+ NE format');
    with ne_kopf do
      begin
        if ne_cres<1 then Fehler(2,'NE: no resources.');

        GetMem(os2_ne_resource_table,SizeOf(os2_ne_resource_table^[1])*ne_cres);
        d1^.Seek(x_exe_ofs+ne_rsrctab);
        IOCheck(d1);
        d1^.Read(os2_ne_resource_table^,SizeOf(os2_ne_resource_table^[1])*ne_cres);
        IOCheck(d1);

        GetMem(ne_seg_tabelle,SizeOf(ne_seg_tabelle^[1])*ne_cseg);
        d1^.Seek(x_exe_ofs+ne_segtab);
        IOCheck(d1);
        d1^.Read(ne_seg_tabelle^,SizeOf(ne_seg_tabelle^[1])*ne_cseg);
        IOCheck(d1);

        create_outputfile;

        for i:=1 to ne_cres do
          with os2_ne_resource_table^[i],
               ne_seg_tabelle^[ne_cseg-ne_cres+i] do
            begin
              Write('<',i,'/',ne_cres,'>');

              d1^.Seek(ns_sector shl ne_align);
              IOCheck(d1);

              if ns_minalloc=0 then Fehler(99,'64KiB resource ?');
              if ns_minalloc<ns_cbseg then Fehler(99,'corrupted segment table');
              GetMem(reso,ns_minalloc);
              FillChar(reso^,ns_minalloc,0);
              d1^.Read(reso^,ns_cbseg);
              if (ns_flags and neNSIter)=neNSIter then
                begin (* un_exepack1 *)
                  GetMem(reso_u,ns_minalloc);
                  FillChar(reso_u^,ns_minalloc,0);
                  q:=0;
                  t:=0;
                  repeat
                    with LX_Iter(reso^[q]) do
                      begin
                        if (LX_nIter=0) or (LX_nBytes=0) or (q+4>=ns_cbseg) then Break;
                        while LX_nIter>0 do
                          begin
                            Move(LX_Iterdata,reso_u^[t],LX_nBytes);
                            Inc(t,LX_nBytes);
                            Dec(LX_nIter);
                          end;
                        Inc(q,4+LX_nBytes);
                      end;
                  until false;

                  Dispose(reso);
                  reso:=reso_u;
                end;

              ns_flags:=ns_flags and (neNSMove {or neNSShared} or neNSPreLoad or neNSDiscard);

              d2^.Write(_ff             ,SizeOf(_ff             )); (* ? *)
              IOCheck(d2);
              d2^.Write(r_type          ,SizeOf(r_type           ));
              IOCheck(d2);
              d2^.Write(_ff             ,SizeOf(_ff             )); (* ? *)
              IOCheck(d2);
              d2^.Write(r_id            ,SizeOf(r_id            ));
              IOCheck(d2);
              d2^.Write(ns_flags        ,SizeOf(ns_flags        ));
              IOCheck(d2);
              d2^.Write(ns_minalloc     ,SizeOf(ns_minalloc     ));
              IOCheck(d2);
              d2^.Write(_0000           ,SizeOf(_0000           ));
              IOCheck(d2);

              d2^.Write(reso^           ,ns_minalloc             );
              IOCheck(d2);

              Dispose(reso);

              Write(^M);
            end;

        Dispose(ne_seg_tabelle);
        Dispose(os2_ne_resource_table);
      end;
  end; (* extract_os2_ne_resources *)

{$IfDef NE_WINDOWS}
procedure extract_win_ne_resources;
  var
    res_table                   :pByteArray;
    i                           :longint;
    res_shift                   :longint;
    p,l                         :longint;
    reso                        :pByteArray;
    nr                          :word;

  procedure write_name_or_id(w:smallword);
    begin
      if (w and RSOrdID)=RSOrdID then
        begin
          w:=w and (not RSOrdID);
          d2^.Write(_ff             ,SizeOf(_ff             )); (* ? *)
          IOCheck(d2);
          d2^.Write(w               ,SizeOf(w                ));
          IOCheck(d2);
        end
      else
        begin
          d2^.Write(res_table^[w+1],res_table^[w]);
          IOCheck(d2);
          d2^.Write(_00,1);
          IOCheck(d2);
        end;
    end;

  begin
    with ne_kopf do
      begin
        WriteLn('* Windows ',ne_res[NERESBytes-2+2],'.',Int2StrZ(ne_res[NERESBytes-2+1],2),' NE format');

        if ne_restab-ne_rsrctab<2+SizeOf(rsrc_typeinfo)+SizeOf(rsrc_nameinfo)+2 then Fehler(2,'NE: no resources.');

        if (ne_flags and NEBound)=NEBound then WriteLn('Warning: Selfloader !');

        GetMem(res_table,ne_restab-ne_rsrctab);
        d1^.Seek(x_exe_ofs+ne_rsrctab);
        IOCheck(d1);
        d1^.Read(res_table^,ne_restab-ne_rsrctab);
        IOCheck(d1);

        i:=0;
        res_shift:=new_rsrc(res_table^[i]).rs_align;
        Inc(i,2);

        create_outputfile;
        nr:=0;

        repeat
          with rsrc_typeinfo(res_table^[i]) do
            begin
              if rt_id=0 then Break;
              Inc(i,SizeOf(rsrc_typeinfo));
              while rt_nres>0 do
                with rsrc_nameinfo(res_table^[i]) do
                  begin

                    Inc(nr);
                    Write('<',nr,'/?>');

                    write_name_or_id(rt_id);
                    write_name_or_id(rn_id);
                    //!!!rn_flags:=rn_flags and (neNSMove {or neNSShared} or neNSPreLoad or neNSDiscard);
                    d2^.Write(rn_flags,SizeOf(rn_flags));IOCheck(d2);
                    p:=rn_offset shl res_shift;
                    l:=rn_length shl res_shift;
                    d2^.Write(l,SizeOf(l));IOCheck(d2);
                    GetMem(reso,l);
                    d1^.Seek(p);IOCheck(d1);
                    d1^.Read(reso^,l);IOCheck(d1);
                    d2^.Write(reso^,l);IOCheck(d2);
                    Dispose(reso);
                    Dec(rt_nres);
                    Inc(i,SizeOf(rsrc_nameinfo));

                    Write(^M);
                  end;
            end;
        until false;

      end;
  end; (* extract_win_ne_resources *)
{$EndIf NE_WINDOWS}

begin
  //WriteLn('RDC2 * RDCPP replacement for LX * Veit Kannegieser * '+datum);
  WriteLn('RDC2 * RDCPP replacement * Veit Kannegieser * '+datum);

  if ParamCount<>2 then
    begin
      WriteLn('RDC2 <LX/NE EXE> <OS/2 RES>');
      Halt(1);
    end;

  d1:=New(pBufStream,Init(ParamStr(1),stOpenRead,8*1024));
  if d1^.Status<>stOK then
    Fehler(3,ParamStr(1)+' ?');

  d1^.Read(exe_kopf,SizeOf(exe_kopf));
  IOCheck(d1);
  if (   (exe_kopf.e.eid=Ord('M') shl 8+Ord('Z'))
      or (exe_kopf.e.eid=Ord('Z') shl 8+Ord('M')) )
    and (   (exe_kopf.e.ehdrsiz>=4) (* >=$40 *)
         or (exe_kopf.e.ereloff+4*exe_kopf.e.erelcnt<$3c))
     then
      x_exe_ofs:=longint_z(@exe_kopf.r[ENewHdr])^
    else
      x_exe_ofs:=0;

  d1^.Seek(x_exe_ofs);
  IOCheck(d1);
  d1^.Read(ne_kopf,SizeOf(ne_kopf));
  IOCheck(d1);

  if ne_kopf.ne_magic=NEMagic then
    with ne_kopf do

      begin
        if not (ne_exetyp in [NE_Os2,NE_Windows]) then
          Fehler(1,'NE: unknown target OS');

        case ne_exetyp of
          NE_Os2:
            begin
              extract_os2_ne_resources;
              WriteLn;
              d1^.Done;
              d2^.Done;
              Halt(0);
            end;

          NE_Windows:
            begin
              {$IfDef NE_WINDOWS}
              extract_win_ne_resources;
              WriteLn;
              d1^.Done;
              d2^.Done;
              Halt(0);
              {$Else}
              Fehler(99,'* Windows '+Int2Str(ne_res[NERESBytes-2+2])+'.'+Int2StrZ(ne_res[NERESBytes-2+1],2)+' NE format not supported yet.');
              {$EndIf}
            end;

        end;
      end;

  d1^.Seek(x_exe_ofs);
  IOCheck(d1);
  d1^.Read(lx_kopf,SizeOf(lx_kopf));
  IOCheck(d1);

  with lx_kopf do
    begin

      if (e32_Magic[0]<>Ord('L')) and (e32_Magic[1]<>Ord('X')) then
        Fehler(1,'not LX');

      if (e32_rsrctab=0) or (e32_rsrccnt=0) then
        Fehler(2,'LX: no resources');

      WriteLn('* OS/2 2.x+ LX format');
      create_outputfile;

      GetMem(loader_section,e32_ldrsize);
      d1^.Seek(x_exe_ofs+e32_objtab);
      IOCheck(d1);
      d1^.Read(loader_section^,e32_ldrsize);
      IOCheck(d1);

      obj_tabelle       :=Ptr(Ofs(loader_section^)+e32_objtab -e32_objtab);
      resource_tabelle  :=Ptr(Ofs(loader_section^)+e32_rsrctab-e32_objtab);
      seiten_tabelle    :=Ptr(Ofs(loader_section^)+e32_objmap -e32_objtab);

      akuelles_obj:=-1;
      for resource_zaehler:=1 to e32_rsrccnt do
        begin
          Write('<',resource_zaehler,'/',e32_rsrccnt,'>');

          with resource_tabelle^[resource_zaehler] do
            begin
              if Obj<>akuelles_obj then
                lade_obj(Obj);

              d2^.Write(_ff             ,SizeOf(_ff             )); (* ? *)
              IOCheck(d2);
              d2^.Write(rType           ,SizeOf(rType           ));
              IOCheck(d2);
              d2^.Write(_ff             ,SizeOf(_ff             )); (* ? *)
              IOCheck(d2);
              d2^.Write(Name            ,SizeOf(Name            ));
              IOCheck(d2);
              d2^.Write(objekt_bits     ,SizeOf(objekt_bits     ));
              IOCheck(d2);
              d2^.Write(cb              ,SizeOf(cb              ));
              IOCheck(d2);

              d2^.Write(obj_speicher^[Offset],cb                 );
              IOCheck(d2);

            end;

          Write(^M);
        end;
      WriteLn;

    end;

  d1^.Done;
  d2^.Done;

end.

