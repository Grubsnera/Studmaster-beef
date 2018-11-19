// Application: StudMaster for Beef Cattle
//   File Name: SM3ALMA.PRG
// Description: Program to enter initial data
//   Copyright: (c) 1995 by Tarragon Computing CC
//      Author: Albert van Rensburg
//  Created on: 01-02-95      07:41:33am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/******************************************************************************/
FUNCTION sm3alma

   // Declare
   local getlist := {}
   local aSend := {}
   local aData := {}
   local aCdbf := fATopen()
   local lLoop := .t.
   local nCoun := 1
   local nBoxCoo := 0
   local h001 := ""
   local cData := ""
   local i     := 0
   local nData := 0
   local aDscr   := {}
   private aEenn := {}
   private aTwee := {}
   private aDrie := {}
   private aVier := {}
   private aVyff := {}
   private aSess := {}
   private aSewe := {}
   private aAgtt := {}

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif

      aDscr := fASaveScr()
/*
	  // Open the fields file
      aCdbf := fATopen(aCdbf,,"STDFIEL",,"tdb")
      if !aCdbf[len(aCdbf),1]
         break
      endif
*/
      // Screen
      fScrBood(maxrow()-1)

      // First screen
      if cLanType() == "A"
         fScrWbood( maxrow(), "Algemene Veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "General field information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "idnr" })
      aadd( aSend, { "sm3data", "idnaam" })
      aadd( aSend, { "sm3data", "remark" })
      aadd( aSend, { "sm3data", "kuddek" })
      aadd( aSend, { "sm3data", "jaarle" })
      aadd( aSend, { "sm3data", "volgno" })
      aadd( aSend, { "sm3data", "skaalid" })
      aadd( aSend, { "sm3data", "idsoc" })
      aadd( aSend, { "sm3data", "reknr" })
      aadd( aSend, { "sm3data", "kalfbnr" })
      aadd( aSend, { "sm3data", "bloednr" })
      aadd( aSend, { "sm3data", "idvaar" })
      aadd( aSend, { "sm3data", "idmoer" })
      aadd( aSend, { "sm3data", "bloedlyn" })
      aadd( aSend, { "sm3data", "geslag" })
      aadd( aSend, { "sm3data", "generasie" })
      aadd( aSend, { "sm3data", "gebdatum" })
      aadd( aSend, { "sm3data", "mouderdom" })

      aadd( aSend, { "sm3data", "gekeur" })
      aadd( aSend, { "sm3data", "keurda" })
      aadd( aSend, { "sm3data", "redeui" })
      aadd( aSend, { "sm3data", "opmerking1" })
      aadd( aSend, { "sm3data", "opmerking2" })
      aadd( aSend, { "sm3data", "uitkrede" })
      aadd( aSend, { "sm3data", "uitkdatum" })
      aadd( aSend, { "sm3data", "indekskode" })
      aadd( aSend, { "sm3data", "fasekode" })
      aadd( aSend, { "sm3data", "toggle1" })
      aadd( aSend, { "sm3data", "ibcoef" })
      aadd( aSend, { "sm3data", "michip" })
      aadd( aSend, { "sm3data", "divers" })
      aadd( aSend, { "sm3data", "divert" })
      aEenn := fGetField( aSend )

      // Tweede skerm
      if cLanType() == "A"
         fScrWbood( maxrow(), "Ander veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Other field information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "gebmassa" })
      aadd( aSend, { "sm3data", "mamoergeb" })
      aadd( aSend, { "sm3data", "gebmasv" })
      aadd( aSend, { "sm3data", "mamoerspe" })
      aadd( aSend, { "sm3data", "spnmasvhd" })
      aadd( aSend, { "sm3data", "mpresind" })
      aadd( aSend, { "sm3data", "klfspnind" })
      aadd( aSend, { "sm3data", "spnspnind" })
      aadd( aSend, { "sm3data", "moerou" })
      aadd( aSend, { "sm3data", "kalfno" })

      aadd( aSend, { "sm3data", "vaarkode" })
      aadd( aSend, { "sm3data", "gebstat" })
      aadd( aSend, { "sm3data", "tweeling" })
      aadd( aSend, { "sm3data", "kalfstat" })
      aadd( aSend, { "sm3data", "kalfgem" })
      aadd( aSend, { "sm3data", "nagebo" })
      aadd( aSend, { "sm3data", "niereg" })
      aadd( aSend, { "sm3data", "subafd" })
      aadd( aSend, { "sm3data", "ident" })
      aadd( aSend, { "sm3data", "tipies" })
      aadd( aSend, { "sm3data", "idatum" })
      aadd( aSend, { "sm3data", "dataan" })
      aadd( aSend, { "sm3data", "type" })
      aadd( aSend, { "sm3data", "compos" })
      aadd( aSend, { "sm3data", "eyepig" })
      aTwee := fGetField( aSend )

      //Derde skerm
      if cLanType() == "A"
         fScrWbood( maxrow(), "Indeks veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Index field information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "kod100" })      // 1
      aadd( aSend, { "sm3data", "dat100" })      // 2
      aadd( aSend, { "sm3data", "mas100" })      // 3
      aadd( aSend, { "sm3data", "gma100" })      // 4
      aadd( aSend, { "sm3data", "oud100" })      // 5
      aadd( aSend, { "sm3data", "aan100" })      // 6
      aadd( aSend, { "sm3data", "gdo100" })      // 7
      aadd( aSend, { "sm3data", "ind100" })      // 8
      aadd( aSend, { "sm3data", "kod205" })      // 9
      aadd( aSend, { "sm3data", "dat205" })      // 10
      aadd( aSend, { "sm3data", "mas205" })      // 11
      aadd( aSend, { "sm3data", "gma205" })      // 12
      aadd( aSend, { "sm3data", "oud205" })      // 13
      aadd( aSend, { "sm3data", "aan205" })      // 14
      aadd( aSend, { "sm3data", "gdo205" })      // 15
      aadd( aSend, { "sm3data", "ind205" })      // 16
      aadd( aSend, { "sm3data", "kod365" })      // 17
      aadd( aSend, { "sm3data", "dat365" })      // 18
      aadd( aSend, { "sm3data", "mas365" })      // 19
      aadd( aSend, { "sm3data", "gma365" })      // 20
      aadd( aSend, { "sm3data", "oud365" })      // 21
      aadd( aSend, { "sm3data", "aan365" })      // 22
      aadd( aSend, { "sm3data", "gdo365" })      // 23
      aadd( aSend, { "sm3data", "ind365" })      // 24
      aadd( aSend, { "sm3data", "kod540" })      // 25
      aadd( aSend, { "sm3data", "dat540" })      // 26
      aadd( aSend, { "sm3data", "mas540" })      // 27
      aadd( aSend, { "sm3data", "gma540" })      // 28
      aadd( aSend, { "sm3data", "oud540" })      // 29
      aadd( aSend, { "sm3data", "aan540" })      // 30
      aadd( aSend, { "sm3data", "gdo540" })      // 31
      aadd( aSend, { "sm3data", "ind540" })      // 32
      aDrie := fGetField( aSend )

      //Vierde skerm
      if cLanType() == "A"
         fScrWbood( maxrow(), "Fase C & D veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Phase C & D field information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "begdatum"   })
      aadd( aSend, { "sm3data", "begmassa"   })
      aadd( aSend, { "sm3data", "eindat"     })
      aadd( aSend, { "sm3data", "einmas"     })
      aadd( aSend, { "sm3data", "daeint"     })
      aadd( aSend, { "sm3data", "tydgen"     })
      aadd( aSend, { "sm3data", "rangor"     })
      aadd( aSend, { "sm3data", "gdogdo"     })
      aadd( aSend, { "sm3data", "gdoind"     })
      aadd( aSend, { "sm3data", "gdtgdt"     })
      aadd( aSend, { "sm3data", "gdtind"     })
      aadd( aSend, { "sm3data", "voeromset"  })
      aadd( aSend, { "sm3data", "voeromseti" })
      aadd( aSend, { "sm3data", "mateskouer" })
      aadd( aSend, { "sm3data", "gekhoo"     })
      aadd( aSend, { "sm3data", "matelengte" })
      aadd( aSend, { "sm3data", "geklen"     })
      aadd( aSend, { "sm3data", "hoolen"     })
      aadd( aSend, { "sm3data", "veldikte"   })
      aadd( aSend, { "sm3data", "gekvel"     })
      aadd( aSend, { "sm3data", "mateskrot"  })
      aadd( aSend, { "sm3data", "gekskr"     })
      aadd( aSend, { "sm3data", "kleiber"    })
      aadd( aSend, { "sm3data", "kleiberi"   })
      aVier := fGetField( aSend )

      //Vyfde skerm
      if cLanType() == "A"
         fScrWbood( maxrow(), "Nageslag veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Progeny field information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "oudekalf"   })
      aadd( aSend, { "sm3data", "kalfaantal" })
      aadd( aSend, { "sm3data", "gemkalfin"  })
      aadd( aSend, { "sm3data", "mwprod"     })
      aadd( aSend, { "sm3data", "prodpj"     })  // 5
      aadd( aSend, { "sm3data", "simdeks"    })  // 6
      aadd( aSend, { "sm3data", "gemdind"    })  // 7
      aadd( aSend, { "sm3data", "gemgmv"     })  // 8
      aadd( aSend, { "sm3data", "gemgebmas"  })  // 9
      aadd( aSend, { "sm3data", "gemspeena"  })  // 10
      aadd( aSend, { "sm3data", "gem100"     })  // 11
      aadd( aSend, { "sm3data", "gemspeeni"  })  // 12
      aadd( aSend, { "sm3data", "gem365"     })  // 13
      aadd( aSend, { "sm3data", "gem540"     })  // 14
      aadd( aSend, { "sm3data", "gegdti"     })  // 15
      aadd( aSend, { "sm3data", "speper"     })  // 16
      aadd( aSend, { "sm3data", "gemret"     })  // 17
      aadd( aSend, { "sm3data", "retens"     })  // 18
      aadd( aSend, { "sm3data", "dekdat"     })  // 19
      aadd( aSend, { "sm3data", "tipede"     })  // 20
      aadd( aSend, { "sm3data", "bulid"      })  // 21
      aadd( aSend, { "sm3data", "teelgroep"  })  // 22
      aadd( aSend, { "sm3data", "dragda"     })  // 23
      aadd( aSend, { "sm3data", "dragti"     })  // 24
      aadd( aSend, { "sm3data", "lkalfdatum" })  // 25
      aadd( aSend, { "sm3data", "lkalfn"     })  // 26
      aadd( aSend, { "sm3data", "oudlkalf"   })  // 27
      aadd( aSend, { "sm3data", "gegdoi"     })  // 28
      aVyff := fGetField( aSend )

      //Sesde skerm
      if cLanType() == "A"
         fScrWbood( maxrow(), "Liggaamsmates veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Body measurement fields information being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "pypb" })        // 1
      aadd( aSend, { "sm3data", "fra205" })      // 2
      aadd( aSend, { "sm3data", "fra365" })      // 3
      aadd( aSend, { "sm3data", "fra540" })      // 4
      aadd( aSend, { "sm3data", "len205" })      // 5
      aadd( aSend, { "sm3data", "len365" })      // 6
      aadd( aSend, { "sm3data", "len540" })      // 7
      aadd( aSend, { "sm3data", "skr365" })      // 8
      aadd( aSend, { "sm3data", "skr540" })      // 9
      aadd( aSend, { "sm3data", "oogpig" })      // 10
      aadd( aSend, { "sm3data", "divers" })      // 11
      aSess := fGetField( aSend )

      // Seventh screen
      if cLanType() == "A"
         fScrWbood( maxrow(), "Teelwaarde veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Breeding value fields being read" )
      endif
      asize( aSend, 0 )
      aadd( aSend, { "sm3data", "analdate" })    // 1
      aadd( aSend, { "sm3data", "tkpdir" })      // 2
      aadd( aSend, { "sm3data", "tkpacc" })      // 3
      aadd( aSend, { "sm3data", "oekdir" })      // 4
      aadd( aSend, { "sm3data", "oekacc" })      // 5
      aadd( aSend, { "sm3data", "eocdir" })      // 6
      aadd( aSend, { "sm3data", "eocacc" })      // 7
      aadd( aSend, { "sm3data", "eocmat" })      // 8
      aadd( aSend, { "sm3data", "eocmac" })      // 9

      aadd( aSend, { "sm3data", "birdir" })      //10
      aadd( aSend, { "sm3data", "biracc" })      //11
      aadd( aSend, { "sm3data", "birmat" })      //12
      aadd( aSend, { "sm3data", "birmac" })      //13
      aadd( aSend, { "sm3data", "weadir" })      //14
      aadd( aSend, { "sm3data", "weaacc" })      //15
      aadd( aSend, { "sm3data", "weamat" })      //16
      aadd( aSend, { "sm3data", "weamac" })      //17
      aadd( aSend, { "sm3data", "weacom" })      //18
      aadd( aSend, { "sm3data", "weacac" })      //19
      aadd( aSend, { "sm3data", "yeadir" })      //20
      aadd( aSend, { "sm3data", "yeaacc" })      //21
      aadd( aSend, { "sm3data", "m18dir" })      //22
      aadd( aSend, { "sm3data", "m18acc" })      //23
      aadd( aSend, { "sm3data", "adgdir" })      //24
      aadd( aSend, { "sm3data", "adgacc" })      //25

      aadd( aSend, { "sm3data", "cowdir" })      //26
      aadd( aSend, { "sm3data", "cowacc" })      //27
      aadd( aSend, { "sm3data", "coedir" })      //28
      aadd( aSend, { "sm3data", "coeacc" })      //29

      aSewe := fGetField( aSend )

      // Eigth screen
      if cLanType() == "A"
         fScrWbood( maxrow(), "Teelwaarde veldbesonderhede word gelees" )
      else
         fScrWbood( maxrow(), "Breeding value fields being read" )
      endif
      asize( aSend, 0 )

      aadd( aSend, { "sm3data", "adgdir" })      // 1
      aadd( aSend, { "sm3data", "adgacc" })      // 2
      aadd( aSend, { "sm3data", "pcfcrd" })      // 3
      aadd( aSend, { "sm3data", "pcfcra" })      // 4
      aadd( aSend, { "sm3data", "kledir" })      // 5
      aadd( aSend, { "sm3data", "kleacc" })      // 6
      aadd( aSend, { "sm3data", "scrdir" })      // 7
      aadd( aSend, { "sm3data", "scracc" })      // 8
      aadd( aSend, { "sm3data", "hgtdir" })      // 9
      aadd( aSend, { "sm3data", "hgtacc" })      // 10
      aadd( aSend, { "sm3data", "lgtdir" })      // 11
      aadd( aSend, { "sm3data", "lgtacc" })      // 12

      aadd( aSend, { "sm3data", "findir" })      // 13
      aadd( aSend, { "sm3data", "finacc" })      // 14
      aadd( aSend, { "sm3data", "mcwdir" })      // 15
      aadd( aSend, { "sm3data", "mcwacc" })      // 16
      aadd( aSend, { "sm3data", "cardir" })      // 17
      aadd( aSend, { "sm3data", "caracc" })      // 18
      aadd( aSend, { "sm3data", "ribdir" })      // 19
      aadd( aSend, { "sm3data", "ribacc" })      // 20
      aadd( aSend, { "sm3data", "kmedir" })      // 21
      aadd( aSend, { "sm3data", "kmeacc" })      // 22

      aAgtt := fGetField( aSend )

      // Close the fields file
      fATclose(aCdbf)
      asize(aCdbf,len(aCdbf)-1)

      // Open the data files
      fScrBood(maxrow()-1)
      if cLanType() == "A"
         fScrWbood( maxrow(), "Datalˆers word geopen" )
      else
         fScrWbood( maxrow(), "Opening data files" )
      endif

      // Where is animal codes
      aCdbf := fATopen(aCdbf,cDd(),"SM3WAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Remarks
      aCdbf := fATopen(aCdbf,cDd(),"SM3OPMK")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Reasons
      aCdbf := fATopen(aCdbf,cDd(),"SM3REDE")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Main file
      // Reasons
      aCdbf := fATopen(aCdbf,cDd(),"SM3DATA")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Loop to get the data
      lLoop := .t.
      do while lLoop

         // Restore the screen
         fARestScr(aDscr)

         //Demonstrasieprogram
         nBoxCoo := fBoxCent( 12, space(33), 1 )
         if "0000" $ cReeNomm() .and. lastrec() > 200 .or. ;
               len(trim(cReeNomm())) <= 0 .and. lastrec() > 200
            if cLanType() == "A"
               fScrBood(maxrow()-1,"Nuwe diere kan nie met die demonstrasieprogram bygevoeg word nie!")
               fScrWait(maxrow())
            else
               fScrBood(maxrow()-1,"New animals cannot be added with the demonstration program!")
               fScrWait(maxrow())
            endif
            h001 := sm3idnr( , 12, nBoxCoo, , , , .f. )
         else
            h001 := sm3idnr( , 12, nBoxCoo, , , , .t. )
         endif

         do case
            case left( h001, 9 ) == "CANCELLED"
               lLoop := .f.
               loop
            case left( h001, 3 ) == "NOT"
               lLoop := .f.
               loop
         endcase

         seek h001
         if eof()
            appe blank
            SM3DATA->idnr := h001
         endif
         nCoun := 1

         do while nCoun >= 1

            // Clear function keys
            set key K_F3 to
            set key K_F4 to
            set key K_F5 to

            do case

               case nCoun == 1

                  // First screen

                  // Activate F keys
                  //set key K_F3 to WaarID
                  //set key K_F4 to Opmerk
                  //set key K_F5 to Redeui

                  // Data file
                  select sm3data

                  // Get the current data
                  for i = 1 to len( aEenn )
                     aEenn[i][14] := fieldget(aEenn[i][13])
                  next

                  // Screen
                  if cLanType() == "A"
                     fBox( 3, 1, maxrow()-2, maxcol()-2, "ALGEMENE INLIGTING   - "+TRIM(h001), cColNorm(), .f.  )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow()  ,"[F1 ]=Hulp                      ")
                  else
                     fBox( 3, 1, maxrow()-2, maxcol()-2, "GENERAL INFORMATION     - "+TRIM(h001), cColNorm(), .f.  )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next screen")
                     fScrBood(maxrow()  ,"[F1 ]=Help                    ")
                  endif

                  // The gets
                  nData := fEnum(aEenn,"idnaam")
                  @ 5, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict "@!"
                  nData := fEnum(aEenn,"remark")
                  @ 6, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"kuddek")
                  @ 7, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"jaarle")
                  @ 8, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"volgno")
                  @ 9, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"idsoc")
                  @10, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"skaalid")
                  @11, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"reknr")
                  @12, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"kalfbnr")
                  @13, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"bloednr")
                  @14, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"idvaar")
                  @15, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"idmoer")
                  @16, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"bloedlyn")
                  @17, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"geslag")
                  @18, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"generasie")
                  @19, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"gebdatum")
                  @20, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"mouderdom")
                  @21, 2 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWmouderdom(getlist,aEenn)
                  //nData := fEnum(aEenn,"gebmassa")
                  //@21, 2 say aEenn[nData,6] ;
                  //   get aEenn[nData,14] ;
                  //   pict aEenn[nData,10]


                  nData := fEnum(aEenn,"gekeur")
                  @ 7,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"keurda")
                  @ 8,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"redeui")
                  @ 9,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWredeui(getlist,aEenn,aDscr) ;
                     valid fVredeui(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"opmerking1")
                  @10,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWopmerk1(getlist,aEenn,aDscr) ;
                     valid fVopmerk1(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"opmerking2")
                  @11,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWopmerk2(getlist,aEenn,aDscr) ;
                     valid fVopmerk2(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"uitkrede")
                  @12,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWuitkrede(getlist,aEenn,aDscr) ;
                     valid fVuitkrede(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"uitkdatum")
                  @13,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"indekskode")
                  @14,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWindekskode(getlist,aEenn,aDscr) ;
                     valid fVindekskode(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"fasekode")
                  @15,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10] ;
                     when fWfasekode(getlist,aEenn,aDscr) ;
                     valid fVfasekode(getlist,aEenn,aDscr)
                  nData := fEnum(aEenn,"toggle1")
                  @16,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"ibcoef")
                  @17,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"michip")
                  @18,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"divers")
                  @19,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]
                  nData := fEnum(aEenn,"divert")
                  @20,41 say aEenn[nData,6] ;
                     get aEenn[nData,14] ;
                     pict aEenn[nData,10]

                  set curs on
                  read
                  set curs off

                  // Data file
                  select sm3data

                  // Save data
                  do while !rlock()
                  enddo
                  for i = 2 to len( aEenn )
                     fieldput( aEenn[i][13], aEenn[i][14] )
                  next
                  dbunlock()

                  // Where to
                  do case
                     case lastkey() == K_ESC
                        // Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        // Next screen
                        nCoun++
                     case lastkey() == K_PGUP
                        // Previous screen

                     case lastkey() == K_PGDN
                        // Next screen
                        nCoun++
                  endcase

               case nCoun == 2

                  // Tweede skerm

                  // Teken raam ens.
                  if cLanType() == "A"
                     fBox( 4, 2, maxrow()-2, maxcol()-2, "ANDER INLIGTING      - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad  ")
                  else
                     fBox( 4, 2, maxrow()-2, maxcol()-2, "OTHER INFORMATION       - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next page    ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page")
                  endif

                  // Databasis
                  select sm3data

                  // Lees data in veranderlikes in
                  for i = 1 to len( aTwee )
                     aTwee[i][14] := fieldget(aTwee[i][13])
                  next

                  // Vra die data
                  nData := fEnum(aTwee,"gebmassa")
                  @ 6, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"mamoergeb")
                  @ 7, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"gebmasv")
                  @ 8, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10] ;
                     when fWgebmasv(getlist,aTwee)
                  nData := fEnum(aTwee,"mamoerspe")
                  @ 9, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"spnmasvhd")
                  @10, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"mpresind")
                  @11, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"klfspnind")
                  @12, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"spnspnind")
                  @13, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"moerou")
                  @14, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"kalfno")
                  @15, 3 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]

                  nData := fEnum(aTwee,"vaarkode")
                  @ 6,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"gebstat")
                  @ 7,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"tweeling")
                  @ 8,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"kalfstat")
                  @ 9,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"kalfgem")
                  @10,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"nagebo")
                  @11,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"niereg")
                  @12,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"subafd")
                  @13,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"ident")
                  @14,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"tipies")
                  @15,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"idatum")
                  @16,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"dataan")
                  @17,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"type")
                  @18,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"compos")
                  @19,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]
                  nData := fEnum(aTwee,"eyepig")
                  @20,41 say aTwee[nData,6] ;
                     get aTwee[nData,14] ;
                     pict aTwee[nData,10]

                  set curs on
                  read
                  set curs off

                  // Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aTwee )
                        fieldput(aTwee[i][13],aTwee[i][14])
                     next
                  endif

                  // Wat nou?
                  do case

                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0

                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++

                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--

                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++

                     otherwise
                        //Anders

                  endcase

               case nCoun == 3
                  //Derde skerm

                  //Teken raam ens.
                  if cLanType() == "A"
                     fBox( 5, 3, maxrow()-2, maxcol()-2, "INDEKS INLIGTING     - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad  ")
                  else
                     fBox( 5, 3, maxrow()-2, maxcol()-2, "INDEX INFORMATION       - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next page    ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page")
                  endif

                  //Databasis
                  select sm3data

                  //Lees data in veranderlikes in
                  for i = 1 to len( aDrie )
                     aDrie[i][14] := fieldget(aDrie[i][13])
                  next

                  //Vra die data
                  @  7,  4 say aDrie[  2,6] get aDrie[2][14] pict aDrie[  2,10]
                  @  8,  4 say aDrie[  3,6] get aDrie[3][14] pict aDrie[  3,10]
                  @  8, 30 get aDrie[ 1,14] pict aDrie[  1,10]
                  @  9,  4 say aDrie[  4,6] get aDrie[4][14] pict aDrie[  4,10]
                  @ 10,  4 say aDrie[  5,6] get aDrie[5][14] pict aDrie[  5,10]
                  @ 11,  4 say aDrie[  6,6] get aDrie[6][14] pict aDrie[  6,10]
                  @ 12,  4 say aDrie[  7,6] get aDrie[7][14] pict aDrie[  7,10]
                  @ 13,  4 say aDrie[  8,6] get aDrie[8][14] pict aDrie[  8,10]

                  @ 15,  4 say aDrie[ 10,6] get aDrie[10][14] pict aDrie[ 10,10]
                  @ 16,  4 say aDrie[ 11,6] get aDrie[11][14] pict aDrie[ 11,10]
                  @ 16, 30 get aDrie[ 9,14] pict aDrie[  9,10]
                  @ 17,  4 say aDrie[ 12,6] get aDrie[12][14] pict aDrie[ 12,10]
                  @ 18,  4 say aDrie[ 13,6] get aDrie[13][14] pict aDrie[ 13,10]
                  @ 19,  4 say aDrie[ 14,6] get aDrie[14][14] pict aDrie[ 14,10]
                  @ 20,  4 say aDrie[ 15,6] get aDrie[15][14] pict aDrie[ 15,10]
                  @ 21,  4 say aDrie[ 16,6] get aDrie[16][14] pict aDrie[ 16,10]

                  @  7, 41 say aDrie[ 18,6] get aDrie[18][14] pict aDrie[ 18,10]
                  @  8, 41 say aDrie[ 19,6] get aDrie[19][14] pict aDrie[ 19,10]
                  @  8, 67 get aDrie[17,14] pict aDrie[ 17,10]
                  @  9, 41 say aDrie[ 20,6] get aDrie[20][14] pict aDrie[ 20,10]
                  @ 10, 41 say aDrie[ 21,6] get aDrie[21][14] pict aDrie[ 21,10]
                  @ 11, 41 say aDrie[ 22,6] get aDrie[22][14] pict aDrie[ 22,10]
                  @ 12, 41 say aDrie[ 23,6] get aDrie[23][14] pict aDrie[ 23,10]
                  @ 13, 41 say aDrie[ 24,6] get aDrie[24][14] pict aDrie[ 24,10]

                  @ 15, 41 say aDrie[ 26,6] get aDrie[26][14] pict aDrie[ 26,10]
                  @ 16, 41 say aDrie[ 27,6] get aDrie[27][14] pict aDrie[ 27,10]
                  @ 16, 67 get aDrie[25,14] pict aDrie[ 25,10]
                  @ 17, 41 say aDrie[ 28,6] get aDrie[28][14] pict aDrie[ 28,10]
                  @ 18, 41 say aDrie[ 29,6] get aDrie[29][14] pict aDrie[ 29,10]
                  @ 19, 41 say aDrie[ 30,6] get aDrie[30][14] pict aDrie[ 30,10]
                  @ 20, 41 say aDrie[ 31,6] get aDrie[31][14] pict aDrie[ 31,10]
                  @ 21, 41 say aDrie[ 32,6] get aDrie[32][14] pict aDrie[ 32,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aDrie )
                        fieldput(aDrie[i][13],aDrie[i][14])
                     next
                  endif

                  //Wat nou?
                  do case

                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0

                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++

                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--

                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++

                     otherwise
                        //Anders

                  endcase

               case nCoun == 4
                  //Vierde skerm

                  //Teken raam ens.
                  if cLanType() == "A"
                     fBox( 6, 4, maxrow()-2, maxcol()-2, "FASE C & D INLIGTING - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad  ")
                  else
                     fBox( 6, 4, maxrow()-2, maxcol()-2, "PHASE C & D INFORMATION - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next page    ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page")
                  endif

                  //Indien nie fase D - Volgende skerm
                  if sm3data->fasekode == "      "
                     if lastkey() == K_PGUP
                        nCoun--
                     else
                        nCoun++
                     endif
                     loop
                  endif

                  //Lees data in veranderlikes in
                  for i = 1 to len( aVier )
                     aVier[i][14] := fieldget(aVier[i][13])
                  next

                  //Vra die data
                  @  8,  5 say aVier[  1,6] get aVier[1][14] pict aVier[  1,10]
                  @  9,  5 say aVier[  2,6] get aVier[2][14] pict aVier[  2,10]
                  @ 10,  5 say aVier[  3,6] get aVier[3][14] pict aVier[  3,10]
                  @ 11,  5 say aVier[  4,6] get aVier[4][14] pict aVier[  4,10]
                  @ 12,  5 say aVier[  5,6] get aVier[5][14] pict aVier[  5,10]
                  @ 13,  5 say aVier[  6,6] get aVier[6][14] pict aVier[  6,10]
                  @ 14,  5 say aVier[  7,6] get aVier[7][14] pict aVier[  7,10]
                  @ 15,  5 say aVier[  8,6] get aVier[8][14] pict aVier[  8,10]
                  @ 16,  5 say aVier[  9,6] get aVier[9][14] pict aVier[  9,10]
                  @ 17,  5 say aVier[ 10,6] get aVier[10][14] pict aVier[ 10,10]
                  @ 18,  5 say aVier[ 11,6] get aVier[11][14] pict aVier[ 11,10]
                  @ 19,  5 say aVier[ 12,6] get aVier[12][14] pict aVier[ 12,10]
                  @ 20,  5 say aVier[ 13,6] get aVier[13][14] pict aVier[ 13,10]

                  @  8, 42 say aVier[ 23,6] get aVier[23][14] pict aVier[ 23,10]
                  @  9, 42 say aVier[ 24,6] get aVier[24][14] pict aVier[ 24,10]
                  @ 10, 42 say aVier[ 14,6] get aVier[14][14] pict aVier[ 14,10]
                  @ 11, 42 say aVier[ 15,6] get aVier[15][14] pict aVier[ 15,10]
                  @ 12, 42 say aVier[ 16,6] get aVier[16][14] pict aVier[ 16,10]
                  @ 13, 42 say aVier[ 17,6] get aVier[17][14] pict aVier[ 17,10]
                  @ 14, 42 say aVier[ 18,6] get aVier[18][14] pict aVier[ 18,10]
                  @ 15, 42 say aVier[ 19,6] get aVier[19][14] pict aVier[ 19,10]
                  @ 16, 42 say aVier[ 20,6] get aVier[20][14] pict aVier[ 20,10]
                  @ 17, 42 say aVier[ 21,6] get aVier[21][14] pict aVier[ 21,10]
                  @ 18, 42 say aVier[ 22,6] get aVier[22][14] pict aVier[ 22,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aVier )
                        //Bewaar die data
                        fieldput(aVier[i][13],aVier[i][14])
                     next
                  endif

                  //Wat nou?
                  do case
                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++
                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--
                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++
                     otherwise
                        //Anders
                  endcase

               case nCoun == 5
                  //Vyfde skerm

                  //Teken raam ens.
                  if cLanType() == "A"
                     fBox( 7, 5, maxrow()-2, maxcol()-2, "NAGESLAG INLIGTING   - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad  ")
                  else
                     fBox( 7, 5, maxrow()-2, maxcol()-2, "PROGENY INFORMATION     - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next page    ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page")
                  endif

                  //Databasis
                  select sm3data

                  //Lees data in veranderlikes in
                  for i = 1 to len( aVyff )
                     aVyff[i][14] := fieldget(aVyff[i][13])
                  next

                  //Vra die data
                  @  8,  6 say aVyff[  1,6] get aVyff[ 1][14] pict aVyff[  1,10]
                  @  9,  6 say aVyff[ 27,6] get aVyff[27][14] pict aVyff[ 27,10]
                  @ 10,  6 say aVyff[  2,6] get aVyff[ 2][14] pict aVyff[  2,10]
                  @ 11,  6 say aVyff[  3,6] get aVyff[ 3][14] pict aVyff[  3,10]
                  @ 12,  6 say aVyff[  4,6] get aVyff[ 4][14] pict aVyff[  4,10]
                  @ 13,  6 say aVyff[  5,6] get aVyff[ 5][14] pict aVyff[  5,10]
                  @ 14,  6 say aVyff[  6,6] get aVyff[ 6][14] pict aVyff[  6,10]
                  @ 15,  6 say aVyff[  7,6] get aVyff[ 7][14] pict aVyff[  7,10]
                  @ 16,  6 say aVyff[  8,6] get aVyff[ 8][14] pict aVyff[  8,10]
                  @ 17,  6 say aVyff[  9,6] get aVyff[ 9][14] pict aVyff[  9,10]
                  @ 18,  6 say aVyff[ 11,6] get aVyff[11][14] pict aVyff[ 11,10]
                  @ 19,  6 say aVyff[ 12,6] get aVyff[12][14] pict aVyff[ 12,10]
                  @ 20,  6 say aVyff[ 13,6] get aVyff[13][14] pict aVyff[ 13,10]
                  @ 21,  6 say aVyff[ 14,6] get aVyff[14][14] pict aVyff[ 14,10]

                  @  8, 42 say aVyff[ 28,6] get aVyff[28][14] pict aVyff[ 28,10]
                  @  9, 42 say aVyff[ 15,6] get aVyff[15][14] pict aVyff[ 15,10]
                  @ 10, 42 say aVyff[ 10,6] get aVyff[10][14] pict aVyff[ 10,10]
                  @ 11, 42 say aVyff[ 16,6] get aVyff[16][14] pict aVyff[ 16,10]
                  @ 12, 42 say aVyff[ 17,6] get aVyff[17][14] pict aVyff[ 17,10]
                  @ 13, 42 say aVyff[ 18,6] get aVyff[18][14] pict aVyff[ 18,10]
                  @ 14, 42 say aVyff[ 19,6] get aVyff[19][14] pict aVyff[ 19,10]
                  @ 15, 42 say aVyff[ 20,6] get aVyff[20][14] pict aVyff[ 20,10]
                  @ 16, 42 say aVyff[ 21,6] get aVyff[21][14] pict aVyff[ 21,10]
                  @ 17, 42 say aVyff[ 22,6] get aVyff[22][14] pict aVyff[ 22,10]
                  @ 18, 42 say aVyff[ 23,6] get aVyff[23][14] pict aVyff[ 23,10]
                  @ 19, 42 say aVyff[ 24,6] get aVyff[24][14] pict aVyff[ 24,10]
                  @ 20, 42 say aVyff[ 25,6] get aVyff[25][14] pict aVyff[ 25,10]
                  @ 21, 42 say aVyff[ 26,6] get aVyff[26][14] pict aVyff[ 26,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aVyff )
                        //Bewaar die data
                        fieldput(aVyff[i][13],aVyff[i][14])
                     next
                  endif

                  //Wat nou?
                  do case
                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++
                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--
                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++
                     otherwise
                        //Anders
                  endcase

               case nCoun == 6
                  //Sesde skerm

                  //Teken raam ens.
                  if cLanType() == "A"
                     fBox( 8, 6, maxrow()-2, maxcol()-2, "LIGGAAMSMATES        - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad")
                  else
                     fBox( 8, 6, maxrow()-2, maxcol()-2, "BODY MEASUREMENTS       - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Next page     ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page ")
                  endif

                  //Databasis
                  select sm3data

                  //Lees data in veranderlikes in
                  for i = 1 to len( aSess )
                     aSess[i][14] := fieldget(aSess[i][13])
                  next

                  //Vra die data
                  @ 10,  7 say aSess[ 1,6] get aSess[ 1][14] pict aSess[ 1,10]
                  @ 11,  7 say aSess[ 2,6] get aSess[ 2][14] pict aSess[ 2,10]
                  @ 12,  7 say aSess[ 3,6] get aSess[ 3][14] pict aSess[ 3,10]
                  @ 13,  7 say aSess[ 4,6] get aSess[ 4][14] pict aSess[ 4,10]
                  @ 14,  7 say aSess[ 5,6] get aSess[ 5][14] pict aSess[ 5,10]
                  @ 15,  7 say aSess[ 6,6] get aSess[ 6][14] pict aSess[ 6,10]
                  @ 16,  7 say aSess[ 7,6] get aSess[ 7][14] pict aSess[ 7,10]
                  @ 17,  7 say aSess[ 8,6] get aSess[ 8][14] pict aSess[ 8,10]
                  @ 18,  7 say aSess[ 9,6] get aSess[ 9][14] pict aSess[ 9,10]
                  @ 19,  7 say aSess[10,6] get aSess[10][14] pict aSess[10,10]
                  @ 20,  7 say aSess[11,6] get aSess[11][14] pict aSess[11,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aSess )
                        //Bewaar die data
                        fieldput(aSess[i][13],aSess[i][14])
                     next
                     dbUnlock()
                  endif

                  //Wat nou?
                  do case
                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++
                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--
                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++
                     otherwise
                        //Anders
                  endcase

               case nCoun == 7
                  // Seventh screen

                  // Teken raam ens.
                  if cLanType() == "A"
                     fBox( 9, 7, maxrow()-2, maxcol()-2, "FASE A&B TEELWAARDES - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad")
                  else
                     fBox( 9, 7, maxrow()-2, maxcol()-2, "PHASE A&B BREED VALUES  - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu  [PgDn]=Volgende blad")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad")
                  endif

                  //Databasis
                  select sm3data

                  //Lees data in veranderlikes in
                  for i = 1 to len( aSewe )
                     aSewe[i][14] := fieldget(aSewe[i][13])
                  next

                  //Vra die data
                  @ 11,  8 say aSewe[ 1,6] get aSewe[ 1][14] pict aSewe[ 1,10]
                  @ 12,  8 say aSewe[ 2,6] get aSewe[ 2][14] pict aSewe[ 2,10]
                  @ 12, 38 get aSewe[ 3][14] pict aSewe[ 3,10]
                  @ 13,  8 say aSewe[ 4,6] get aSewe[ 4][14] pict aSewe[ 4,10]
                  @ 13, 38 get aSewe[ 5][14] pict aSewe[ 5,10]
                  @ 14,  8 say aSewe[ 6,6] get aSewe[ 6][14] pict aSewe[ 6,10]
                  @ 14, 38 get aSewe[ 7][14] pict aSewe[ 7,10]
                  @ 15,  8 say aSewe[ 8,6] get aSewe[ 8][14] pict aSewe[ 8,10]
                  @ 15, 38 get aSewe[ 9][14] pict aSewe[ 9,10]
                  @ 16,  8 say aSewe[26,6] get aSewe[26][14] pict aSewe[26,10]
                  @ 16, 38 get aSewe[27][14] pict aSewe[27,10]
                  @ 17,  8 say aSewe[28,6] get aSewe[28][14] pict aSewe[28,10]
                  @ 17, 38 get aSewe[29][14] pict aSewe[29,10]


                  @ 11, 43 say aSewe[10,6] get aSewe[10][14] pict aSewe[10,10]
                  @ 11, 73 get aSewe[11][14] pict aSewe[11,10]
                  @ 12, 43 say aSewe[12,6] get aSewe[12][14] pict aSewe[12,10]
                  @ 12, 73 get aSewe[13][14] pict aSewe[13,10]
                  @ 13, 43 say aSewe[14,6] get aSewe[14][14] pict aSewe[14,10]
                  @ 13, 73 get aSewe[15][14] pict aSewe[15,10]
                  @ 14, 43 say aSewe[16,6] get aSewe[16][14] pict aSewe[16,10]
                  @ 14, 73 get aSewe[17][14] pict aSewe[17,10]
                  @ 15, 43 say aSewe[18,6] get aSewe[18][14] pict aSewe[18,10]
                  @ 15, 73 get aSewe[19][14] pict aSewe[19,10]
                  @ 16, 43 say aSewe[20,6] get aSewe[20][14] pict aSewe[20,10]
                  @ 16, 73 get aSewe[21][14] pict aSewe[21,10]
                  @ 17, 43 say aSewe[22,6] get aSewe[22][14] pict aSewe[22,10]
                  @ 17, 73 get aSewe[23][14] pict aSewe[23,10]
                  @ 18, 43 say aSewe[24,6] get aSewe[24][14] pict aSewe[24,10]
                  @ 18, 73 get aSewe[25][14] pict aSewe[25,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aSewe )
                        //Bewaar die data
                        fieldput(aSewe[i][13],aSewe[i][14])
                     next
                     dbUnlock()
                  endif

                  //Wat nou?
                  do case
                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun++
                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--
                     case lastkey() == K_PGDN
                        //Volgende blad
                        nCoun++
                     otherwise
                        //Anders
                  endcase

               case nCoun == 8
                  // Eigth screen

                  // Teken raam ens.
                  if cLanType() == "A"
                     fBox(10, 8, maxrow()-2, maxcol()-2, "FASE C&D TEELWAARDES - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu                    ")
                     fScrBood(maxrow(),"[F1 ]=Hulp  [PgUp]=Vorige blad")
                  else
                     fBox(10, 8, maxrow()-2, maxcol()-2, "PHASE C&D BREED VALUES  - "+TRIM(h001), cColNorm(), .f. )
                     fScrBood(maxrow()-1,"[Esc]=Menu                      ")
                     fScrBood(maxrow(),"[F1 ]=Help  [PgUp]=Previous page")
                  endif

                  //Databasis
                  select sm3data

                  //Lees data in veranderlikes in
                  for i = 1 to len( aAgtt )
                     aAgtt[i][14] := fieldget(aAgtt[i][13])
                  next

                  //Vra die data
                  @ 12,  9 say aAgtt[ 1,6] get aAgtt[ 1][14] pict aAgtt[ 1,10]
                  @ 12, 39 get aAgtt[ 2][14] pict aAgtt[ 2,10]
                  @ 13,  9 say aAgtt[ 3,6] get aAgtt[ 3][14] pict aAgtt[ 3,10]
                  @ 13, 39 get aAgtt[ 4][14] pict aAgtt[ 4,10]
                  @ 14,  9 say aAgtt[ 5,6] get aAgtt[ 5][14] pict aAgtt[ 5,10]
                  @ 14, 39 get aAgtt[ 6][14] pict aAgtt[ 6,10]
                  @ 15,  9 say aAgtt[ 7,6] get aAgtt[ 7][14] pict aAgtt[ 7,10]
                  @ 15, 39 get aAgtt[ 8][14] pict aAgtt[ 8,10]
                  @ 16,  9 say aAgtt[ 9,6] get aAgtt[ 9][14] pict aAgtt[ 9,10]
                  @ 16, 39 get aAgtt[10][14] pict aAgtt[10,10]
                  @ 17,  9 say aAgtt[11,6] get aAgtt[11][14] pict aAgtt[11,10]
                  @ 17, 39 get aAgtt[12][14] pict aAgtt[12,10]

                  @ 12, 44 say aAgtt[13,6] get aAgtt[13][14] pict aAgtt[13,10]
                  @ 12, 74 get aAgtt[14][14] pict aAgtt[14,10]
                  @ 13, 44 say aAgtt[15,6] get aAgtt[15][14] pict aAgtt[15,10]
                  @ 13, 74 get aAgtt[16][14] pict aAgtt[16,10]
                  @ 14, 44 say aAgtt[17,6] get aAgtt[17][14] pict aAgtt[17,10]
                  @ 14, 74 get aAgtt[18][14] pict aAgtt[18,10]
                  @ 15, 44 say aAgtt[19,6] get aAgtt[19][14] pict aAgtt[19,10]
                  @ 15, 74 get aAgtt[20][14] pict aAgtt[20,10]
                  @ 16, 44 say aAgtt[21,6] get aAgtt[21][14] pict aAgtt[21,10]
                  @ 16, 74 get aAgtt[22][14] pict aAgtt[22,10]

                  set curs on
                  read
                  set curs off

                  //Bewaar
                  do while !rlock()
                  enddo
                  if updated()
                     for i = 1 to len( aAgtt )
                        //Bewaar die data
                        fieldput(aAgtt[i][13],aAgtt[i][14])
                     next
                     dbUnlock()
                  endif

                  //Wat nou?
                  do case
                     case lastkey() == K_ESC
                        //Menu
                        nCoun := 0
                     case lastkey() == K_ENTER
                        //Volgende skerm
                        nCoun := 0
                     case lastkey() == K_PGUP
                        //Vorige bladsy
                        nCoun--
                     case lastkey() == K_PGDN
                        //Volgende blad

                     otherwise
                        //Anders
                  endcase

            endcase

         enddo

      enddo

   end

   // Reset
   fATclose(aCdbf)

return NIL

/******************************************************************************/
STATIC FUNCTION fWmouderdom(aGetl,aFiel)

   // Function to calculate the month age

   // Declare
   local lRetu := .t.
   local nMoud := fEnum(aFiel,"mouderdom")-1
   local nGebd := fEnum(aFiel,"gebdatum")-1
   local nData := 0

   // Calculate age if empty age and date of birth is known
   if empty(aGetl[nMoud]:varget()) .and. ;
         !empty(aGetl[nGebd]:varget())
      nData := int((dAppDate()-aGetl[nGebd]:varget())/30.4375)
      if nData > 0 .and. nData <= 999
         aGetl[nMoud]:varput(nData)
         aGetl[nMoud]:display()
      endif
   endif

return lRetu

/******************************************************************************/
STATIC FUNCTION fWgebmasv(aGetl,aFiel)

   // Function to calculate the birth mass ratio

   // Declare
   local lRetu := .t.
   local nGebm := fEnum(aFiel,"gebmassa")
   local nMoer := fEnum(aFiel,"mamoergeb")
   local nVerh := fEnum(aFiel,"gebmasv")
   local nData := 0

   // Calculate age if empty age and date of birth is known
   if empty(aGetl[nVerh]:varget()) .and. ;
         !empty(aGetl[nGebm]:varget()) .and. ;
         !empty(aGetl[nMoer]:varget())
      nData := round((aGetl[nGebm]:varget()/aGetl[nMoer]:varget())*100,1)
      if nData > 0 .and. nData <= 99.9
         aGetl[nVerh]:varput(nData)
         aGetl[nVerh]:display()
      endif
   endif

return lRetu


/******************************************************************************/
STATIC FUNCTION fWredeui(aGetl,aFiel,aDscr)

   // Function to display the meaning of reasons out

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nRede := fEnum(aFiel,"redeui")-1
   local aCscr := fASaveScr()
   local i     := 0
   local aDesc := {}
   local cData := ""

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Afkeurredes     ")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Rejection codes")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen ")
   endif

   // Data file
   select SM3REDE
   cData := substr(aGetl[nRede]:varget(),1,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3REDE->besk)
      endif
   endif
   cData := substr(aGetl[nRede]:varget(),4,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3REDE->besk)
      endif
   endif
   cData := substr(aGetl[nRede]:varget(),7,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3REDE->besk)
      endif
   endif
   cData := substr(aGetl[nRede]:varget(),10,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3REDE->besk)
      endif
   endif
   cData := substr(aGetl[nRede]:varget(),13,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3REDE->besk)
      endif
   endif

   // Display code if not empty
   if !empty(aDesc)

      // Screen
      if cLanType() == "A"
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"AFKEURREDES")
      else
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"REJECTION REASONS")
      endif
      for i := 1 to len(aDesc)
         @maxrow()-4-len(aDesc)+i,4 say aDesc[i]
      next

   endif

   // Reset
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVredeui(aGetl,aFiel,aDscr)

   // Function to test the where is animal code existance

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nRede := fEnum(aFiel,"redeui")-1
   local cRede := ""

   // Call the reasons window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         cRede := sm3rede(6,8,,,left(aGetl[nRede]:varget(),2))

         // Update get
         if !empty(cRede)
            if cRede $ aGetl[nRede]:varget()
            else
               aGetl[nRede]:varput(strtran(aGetl[nRede]:varget(),"  ",cRede,1,1))
            endif
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWopmerk1(aGetl,aFiel,aDscr)

   // Function to display the meaning of remarks 1

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking1")-1
   local aCscr := fASaveScr()
   local i     := 0
   local aDesc := {}
   local cData := ""

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Opmerkings      ")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Remarks       ")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen")
   endif

   // Data file
   select SM3OPMK
   cData := substr(aGetl[nOpmk]:varget(),1,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),4,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),7,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),10,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),13,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif

   // Display code if not empty
   if !empty(aDesc)

      // Screen
      if cLanType() == "A"
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"OPMERKINGS #1")
      else
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"REMARKS #1")
      endif
      for i := 1 to len(aDesc)
         @maxrow()-4-len(aDesc)+i,4 say aDesc[i]
      next

   endif

   // Reset
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVopmerk1(aGetl,aFiel,aDscr)

   // Function to test the remarks 1 field

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking1")-1
   local cOpmk := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3opmk", "kode" })
         aadd( aVeld, { "sm3opmk", "besk" })
         if empty(left(aGetl[nOpmk]:varget(),2))
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld)
         else
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld,left(aGetl[nOpmk]:varget(),2))
         endif

         // Update get
         if !empty(cOpmk)
            if cOpmk $ aGetl[nOpmk]:varget()
            else
               aGetl[nOpmk]:varput(strtran(aGetl[nOpmk]:varget(),"  ",cOpmk,1,1))
            endif
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWopmerk2(aGetl,aFiel,aDscr)

   // Function to display the meaning of remarks 1

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking2")-1
   local aCscr := fASaveScr()
   local i     := 0
   local aDesc := {}
   local cData := ""

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Opmerkings      ")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Remarks       ")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen")
   endif

   // Data file
   select SM3OPMK
   cData := substr(aGetl[nOpmk]:varget(),1,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),4,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),7,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),10,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif
   cData := substr(aGetl[nOpmk]:varget(),13,2)
   if !empty(cData)
      seek cData
      if found()
         aadd(aDesc,SM3OPMK->besk)
      endif
   endif

   // Display code if not empty
   if !empty(aDesc)

      // Screen
      if cLanType() == "A"
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"OPMERKINGS #2")
      else
         fBox(maxrow()-4-len(aDesc),3,maxrow()-3,64,"REMARKS #2")
      endif
      for i := 1 to len(aDesc)
         @maxrow()-4-len(aDesc)+i,4 say aDesc[i]
      next

   endif

   // Reset
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVopmerk2(aGetl,aFiel,aDscr)

   // Function to test the remarks 1 field

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nOpmk := fEnum(aFiel,"opmerking2")-1
   local cOpmk := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3opmk", "kode" })
         aadd( aVeld, { "sm3opmk", "besk" })
         if empty(left(aGetl[nOpmk]:varget(),2))
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld)
         else
            cOpmk := sm3opme(6,8,maxrow()-3,aVeld,left(aGetl[nOpmk]:varget(),2))
         endif

         // Update get
         if !empty(cOpmk)
            if cOpmk $ aGetl[nOpmk]:varget()
            else
               aGetl[nOpmk]:varput(strtran(aGetl[nOpmk]:varget(),"  ",cOpmk,1,1))
            endif
         endif

      endif
   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWuitkrede(aGetl,aFiel,aDscr)

   // Function to display the meaning of the where is animal code

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nWaar := fEnum(aFiel,"uitkrede")-1
   local aCscr := fASaveScr()
   local i     := 0

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Waar-is-dier kodes")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad  ")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Where-is-animal codes")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen       ")
   endif

   // Display code if not empty
   if !empty(aGetl[nWaar]:varget())

      // Select the data file
      select SM3WAAR

      // Seek the data
      seek aGetl[nWaar]:varget()
      if found()

         // Screen
         if cLanType() == "A"
            fBox(maxrow()-5,3,maxrow()-3,64,"WAAR-IS-DIER KODE")
         else
            fBox(maxrow()-5,3,maxrow()-3,64,"WHERE-IS-ANIMAL CODE")
         endif
         @maxrow()-4,4 say SM3WAAR->besk

      endif

   endif

   // Reset
   fATclose(aCdbf)

return lRetu

/******************************************************************************/
STATIC FUNCTION fVuitkrede(aGetl,aFiel,aDscr)

   // Function to test the where is animal code existance

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nWaar := fEnum(aFiel,"uitkrede")-1
   local cWaar := ""
   local aVeld := {}

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         asize( aVeld, 0 )
         aadd( aVeld, { "sm3waar", "kode" })
         aadd( aVeld, { "sm3waar", "besk" })
         if empty(aGetl[nWaar]:varget())
            cWaar := sm3waar(6,8,maxrow()-3,aVeld)
         else
            cWaar := sm3waar(6,8,maxrow()-3,aVeld,aGetl[nWaar]:varget())
         endif

         // Update get
         if !empty(cWaar)
            aGetl[nWaar]:varput(cWaar)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWindekskode(aGetl,aFiel,aDscr)

   // Function to display the meaning of the index groups

   // Declare
   local lRetu := .t.
   local nInde := fEnum(aFiel,"indekskode")-1
   local aCscr := fASaveScr()
   local i     := 0

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Indeksgroepe    ")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Index groups  ")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen")
   endif

   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fVindekskode(aGetl,aFiel,aDscr)

   // Function to test index group existance

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nInde := fEnum(aFiel,"indekskode")-1
   local cInde := ""

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         if empty(aGetl[nInde]:varget())
            cInde := sm3indg(6,8,maxrow()-3)
         else
            cInde := sm3indg(6,8,maxrow()-3,,aGetl[nInde]:varget())
         endif

         // Update get
         if !empty(cInde)
            aGetl[nInde]:varput(cInde)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fWfasekode(aGetl,aFiel,aDscr)

   // Function to display the meaning of the phase groups

   // Declare
   local lRetu := .t.
   local nFase := fEnum(aFiel,"fasekode")-1
   local aCscr := fASaveScr()
   local i     := 0

   // Save the current screen
   for i := 1 to len(aCscr)
      aDscr[i] := aCscr[i]
   next

   // Screen
   if cLanType() == "A"
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Fase C & D groepe")
      fScrBood(maxrow()  ,"[F1 ]=Hulp  [PgDn]=Volgende blad ")
   else
      fScrBood(maxrow()-1,"[Esc]=Menu  "+D_DNARR+"=Phase C & D groups")
      fScrBood(maxrow()  ,"[F1 ]=Help  [PgDn]=Next screen    ")
   endif

   // Reset

return lRetu

/******************************************************************************/
STATIC FUNCTION fVfasekode(aGetl,aFiel,aDscr)

   // Function to test phase group existance

   // Declare
   local lRetu := .t.
   local aCdbf := fATopen()
   local nFase := fEnum(aFiel,"fasekode")-1
   local cFase := ""

   // Call the remarks window
   if lastkey() == K_DOWN

      if "SME0107" $ cReeNomm()

         // Disable downarrow for Burkhard Herrmann

      else

         // Display the window
         if empty(aGetl[nFase]:varget())
            cFase := sm3fasg(6,8,maxrow()-3)
         else
            cFase := sm3fasg(6,8,maxrow()-3,,aGetl[nFase]:varget())
         endif

         // Update get
         if !empty(cFase)
            aGetl[nFase]:varput(cFase)
         endif

      endif

   endif

   // Reset
   fATclose(aCdbf)
   fARestScr(aDscr)

return lRetu
