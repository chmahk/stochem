C#######################################################################
      PROGRAM STOCHEM
C----------------------------------------------------------------------
C-
C-   This is version S7_3_dlt   as of 28-Jun-98
C-
C----------------------------------------------------------------------
C-   PRESENT-DAY EMISSIONS AND INITIAL CONCENTRATIONS
C-   This version:
C    Version for Steve Utembe July 2007
C    ** CRAY c90 Optimised Version **
C    Derived from S6_BIG.FOR
C    Etadot interpolation in the vertical direction.
C    Runge-Kutta cell advection.
C    70 species mechanism with aqueous phase chemistry.
C    version to study new emissions Dick Derwent May 2004
C    spatial distribution for 2000 Asian pulse runs initial model
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : UKMO Tropospheric Oxidants Model
C-
C-   Inputs  : Trace Gas Emissions and Stratospheric Ozone Data
C-             Meteorological variables from UM archives.
C-
C-   Outputs :
C-   Controls:
C-
C-   Created  21-APR-1993   Colin Johnson - STOCH3DB
C-   Updated                Bill Collins Added X-polar transport. - S_2
C-   Updated                Bill Collins Added extra vertical level for U,V and
C-                                       T. Interpolation of wind SDs. - S_3
C-   Updated                Bill Collins Add chemistry, correct TMASS etc. to
C-                                       work on eta levels. add concentration
C-                                       snapshot output.  - S_4
C-   Updated                Bill Collins Add ETA3 grid. Correct sources.
C-                                       Turn on SDs. Add emissions to each
C-                                       species. Chemical output now to
C-                                       STOCH3D.DAT. - S_5
C-   Updated                Bill Collins Correct NO2 source. Correct declination
C-                                       and local hour angle. Do storage after
C-                                       emissions.- S_6
C-   Updated                Bill Collins Add routine to read source data. - S_7
C-   Updated                Bill Collins Rewritten to modularise. - S2_0
C-   Updated                Bill Collins Add NOx and SO2 emissions. Demodularise
C-                                       some integrations. - S2_1
C-   Updated                Bill Collins Add reaction fluxes in RATES. - S2_2
C-   Updated                Bill Collins Add dry deposition, SO2 oxidation and
C-                                       SA removal. Add VOC emissions,
C-                                       lightning, monthly wind variation,
C-                                       Biological emissions. - S2_3.
C-   Updated  11-APR-1994   Bill Collins Slight restructuring of output code.
C-                                       Outputs on 15th Month, 24hr average and
C-                                       3 hourly snapshots every 3 months. -
C-                                       S2_5
C-   Updated  29-APR-1994   Bill Collins Put cell velocity calculation into
C-                                       subroutine VELOC, temperature
C-                                       calculation into TEMP. Remove INDICIES
C-                                       - indicies are calculated separately.
C-                                       Chemical variables no longer in main
C-                                       program. Small changes to INIPOS,
C-                                       INIGRI, INITCO. - S2_6
C-   Updated   5-MAY-1994   Bill Collins Add flux calculations and output -
C-                                       S2_6_1
C-   Updated  31-MAY-1994   Bill Collins Update Chemistry to include toluene,
C-                                       correct O3 dry deposition. Dry deposit
C-                                       CH3O2H rather than CH3O2 and C2H5O2.
C-   Updated   3-JUN-1994   Bill Collins Added calculation of photolysis rates
C-                                       - S3
C-   Updated   5-JUL-1994   Bill Collins Now reads in files to decide what data
C-                                       to output. Made routines MREAD and
C-                                       DATRD more general. - S3_1
C-   Updated   7-JUL-1994   Bill Collins Add standard deviations to temperature
C-                                       calculation. Release emissions into
C-                                       bottom two layers. - S3_2
C-   Updated   4-JUL-1994   D Stevenson  Added code to output cell
C-                                       diagnostics.
C-   Updated  22-Sep-1994   D Stevenson  Reduced budget arrays tflux,m0 & mass
C-                                       to allow run on HP.
C-   Updated  22-Sep-1994   D Stevenson  Added drift velocities - turned off
C-                                       near poles to keep polar wind symmetry
C-   Updated  26-Sep-1994   D Stevenson  Changed MREAD array pass to u(1,0,2)
C-   Updated   4-Oct-1994   D Stevenson  Added diffusion of stratospheric
C-                                       O3 to top layer (O3 from 2D model)
C-                                       in PLOT - [now turned off]
C-   Updated   7-Oct_1994   D Stevenson  Added lightning distribution, removed
C-                                       old lightn subroutine
C-   Updated   7-Oct_1994   D Stevenson  Added aircraft NO2 emiss distribution
C-   Updated  17-Nov-1994   D Stevenson  Dump end concs / Initialize with
C-                                       previously dumped concs. (inicon2)
C-   Updated   6-Dec-1994   D Stevenson  Added STRATCALC for O3&HNO3 'emissions'
C-                                       from stratosphere (currently from 95mb)
C-                                       & turned off diffusion of strat o3 in
C-                                       PLOT.
C-   Updated  15-Dec-1994   D Stevenson  Upgraded initialisation INICON - S3_3
C-   Updated  13-Jan-1995   Bill Collins Changed filenames to DEC VMS format and
C-                                       added NCHEM to parameter list for
C-                                       MCALC. Don't pass NLONG,MNLAT,NMETLEV
C-                                       to  LIGHTREAD.
C-   Updated   7-MAR-1995   Bill Collins Now read in specific humidity and
C-                                       boundary layer height. Dry deposit from
C-                                       and emit to boundary layer. - S3_5
C-   Updated   8-MAR-1995   Bill Collins Calculate pressures properly from eta.
C-                                       - S4_0
C-   Updated   4-MAY-1995   Bill Collins Particles hitting ground now reset to
C-                                       ETA3(1) not ETA3(2). Converted many
C-                                       variables to real. - S4_1
C-   Updated  15-MAY-1995   Bill Collins Added aerodynamic resistance to dry
C-                                       deposition. Added advection term to
C-                                       accumulated fluxes. - S4_2
C-   Updated   7-JUN-1995   Bill Collins Eulerian concentrations now smoothed by
C-                                       Gaussian filter. Running total of cells
C-                                       in each gridbox stored. - S4_3
C-   Revised  25-MAY-1995  Colin Johnson Revision to CHEMIS which now calls
C-                                       new solver DERIV. EMCALC and other
C-                                       routines changed to reflect new
C-                                       species order.
C-   Updated  13-JUN-1995  Colin Johnson RATES replaced by code in DERIV.
C-   Updated   5-SEP-1995  Colin Johnson PAN photolysis added. - S5_1b
C-   Updated  29-SEP-1995  Colin Johnson New Routines added to change total
C-                                       Ozone and Stratospheric Ozone:
C-                                       O3TOTMOD and O3FACTOR. - S5_1f
C-   Updated  12-NOV-1995  Colin Johnson Photolysis calculation now uses
C-                                       internal
C-                                       ozone tropospheric dobson calculation.
C-                                       INTHRI now uses met. data profiles.
C-                                       Changes to AANDB, PHOT, INIO3; EINTERP
C-                                       added. - S5_1I
C-   Updated   5-DEC-1995   Bill Collins Put in Convection. New routines CLRAIN
C-                                       and CLMIX, and function P2ETA. New
C-                                       VARIABLES CT,CB,CC,ACP. - S5_2_BIG
C-   Updated   9-JAN-1996   Bill Collins Isoprene emissions now proportional to
C-                                       COS(theta). Use GEIA emissions for soil
C-                                       NOX, Isoprene and anthopogenic NOX and
C-                                       SO2. - S5_2a_BIG.
C-   Updated  26-JAN-1996   Bill Collins Got rid of 3D mass fields.
C-  Updated  27-NOV-1995  Colin Johnson  Added new NEWPOS routine, with random
C-                                       allocation in b.l.  Mods to DDCALC to
C-                                       limit dry deposition.
C-  Updated  30-NOV-1995  Colin Johnson  Added dry deposition for SA and dry and
C-                                       wet deposition for ORGNIT. - s5_1J
C-  Updated  15-FEB-1996  Colin Johnson  Wet deposition routine added: DWCALC.
C-                                       - S5_3_BIG
C-  Updated  16-JUL-1996   Bill Collins Now use 6 hourly met data, and
C-                                      calculate boundary layer and aerodynamic
C-                                      deposition online. - S6_BIG
C-  Restructured 30-JUL-1996 Colin Johnson  Chemistry etc called in blocks to
C-                                          allow vectorisation on CRAY.  CHEMIS
C-                                          incorporated into MAIN.
C-   Updated   7-AUG-1996   Bill Collins  Moved a lot of PARAMETER statments and
C-                                        ETAn data to an INCLUDE file at the
C-                                        beginning of each subroutine. Removed
C-                                        0th latitude circle from met data and
C-                                        surface layer of met data. =>
C-                                        altered VELOC and INTERP. -S6_1
C-   Updated  12-AUG-1996   Bill Collins  Move a lot of old CHEMIS code into
C-                                        DERIV. Add 3d Cloud calculation CLCALC
C-                                        - S7.
C-   Updated  13-AUG-1996   Colin Johnson Photolysis code now done hourly rates
C-                                        interpolated between hours. Removed
C-                                        AANDB,FIT,ESEC,SECANT,CHEMPH; added
C-                                        JVALS, DJCALC, altered PHOT.
C-   Updated  13-DEC-1996   Bill Collins  70 species, more, reactions, species
C-                                        and reactions renumbered. -S7_2
C-   Updated   8-JAN-1997   Bill Collins  Wet chemistry -S7_3
C-   Updated  29-JAN-1997   Colin Johnson STRATCALC calls CUBFIT2D for etadot
C-                                        interpolation. RKO4 used for cell
C-                                        advection, replaced VELOC, new routine
C-                                        REPOS to position cells in grid. VELOC
C-                                        calls CUBFIT for etadot interpolation.
C-   Updated   4-FEB-1997   Colin Johnson Wind components now have 5 hours data
C-                                        to allow interpolation.
C-   Updated  26-JUN-1998   Bill Collins  Modified to use DLT drive. 
C-   Updated  30-JUN-1998   Bill Collins  Fixed MOLEC bug. 
C-
C-------------------------------------------------------------------------------
C     STOCHEM - METEOROLOGICAL OFFICE THREE-DIMENSIONAL LAGRANGIAN
C               TRANSPORT MODEL FOR TROPOSPHERIC CHEMISTRY
C
C
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C     GCM DIAGNOSTICS FROM METEOROLOGICAL OFFICE UNIFIED MODEL           
C     50 THOUSAND LAGRANGIAN CELLS
C     FIVE DEGREES LONG X LAT EULERIAN GRID
C     TEN ETA SURFACES
C     218 CHEMICAL SPECIES
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C
C      EULERIAN GRID IN DEGREES : CONC(NC,NLONG,MNLAT,NLEV),
C      GRID BEGINS AT 90 N, 0 E.
C      LAGRANGIAN CELLS : XX(NC,NCELL), CENTRES AT: POS(3,NCELL)
C                         IPOS(5,NCELL) HAS LONG, LAT,
C                         ETA1, ETA2 AND ETA3 INDICES
C
C----------------------------------------------------------------------

C   NLONG: No. of Eulerian longitude grids; East from Greenwich
C   NLAT:  No. of Eulerian latitude grids;  North to South
C   NLEV:  No. of Eulerian levels;
C   NCELL: No. of Lagrangian cells (nominal);
C   DLAT:  Eulerian latitudinal grid (degrees);
C   DLONG: Eulerian longitudinal grid  (degrees);
C   NMETLAT,NMETLONG,NMETLEV: Meteorological grid dimensions;
C   DLATM,DLONGM: Meteorological grid spacing.
C   NBLOCK:  No. of cells treated per block in structured calculation.

      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'

      INTEGER  IHOUR
      INTEGER I,L,KK1,KK2,KK3,KK4,N,SECS,IM,IX,JM,NAVG,NDW,NBLK,
     &    IPOS(5,NCELL),NNN(NLONG,MNLAT,NLEV),NSTEP,JA,JB,
     &    NBL(NLONG,MNLAT),NM(NLONG,MNLAT,NLEV),NSTAT,J,K,NJ
      CHARACTER*10 VERSION
      INTEGER*4 SEED,SEED2,SEED3

C   Lagrangian mixing ratio: XX, Position: POS, Velocity: V,
C   Temperature: TL, & Random numbers: B.

      REAL DJA(NDJ,NLEV,NLONG,MNLAT,4),
     &  CLOUD(NLONG,MNLAT,NLEV,NHR),OZONE(NLONG,MNLAT),
     &  LAND(NLONG,MNLAT)
C Still using ECMWF humidities until we get UM ones
C      REAL HUMID(NLONG,MNLAT,NLEV+1),H2O,H2OCAL
      REAL POS(3,NCELL),V(3),B(NCELL)
      REAL TL(NCELL),XX(NC,NCELL),S(3),XXO3(NCELL)

C   Eulerian concentration: CONC,

      REAL  CONC(NC,NLONG,MNLAT,NLEV),O3CONC(NLONG,MNLAT,NLEV),
     &     MCONC(NC,NLONG,MNLAT,NLEV),SDCONC(NC,NLONG,MNLAT,NLEV)
      REAL M0(NUMCHEM,NLONG,MNLAT,NLEV),
     &  MASS(NUMCHEM,NLONG,MNLAT,NLEV),
     &  M1(NUMCHEM,NLONG,MNLAT,NLEV)
      REAL TOTM0(NUMCHEM),TOTM1(NUMCHEM),TOTAVG(NUMCHEM),TOTMAS(NUMCHEM)
      REAL TFLUX(NUM3DFLUX,NLONG,MNLAT,NLEV),TOTFLU(NUMFLUX)
      INTEGER FLIST(2,NUMFLUX),NFLUX,CLIST(NUMCHEM),NCHEM,NSTATION
      REAL STLON(NUMSTAT),STLAT(NUMSTAT)
      REAL EMISS(NC,NLONG,MNLAT),O3100(NLONG,MNLAT),
     &     ESTORE(NC,NLONG,MNLAT),DDEPO(NC,NLONG,MNLAT)
      REAL LONG(NLONG), LAT(NLAT),
     &     LONGM(NMETLONG),LATM(NMETLAT),
     &     LONGM2(NMETLONG),LATM2(NMETLAT)
      CHARACTER*40 FNAMES(NUMFLUX)
C
C      Block arrays:
      REAL
     &     FLUX(NBLOCK,2200),
     &     EMITD(NBLOCK,NC),EM(NBLOCK,NC),DD(NBLOCK,NC),DW(NBLOCK,NC),
     &    SOA(NBLOCK),MOM(NBLOCK)
C
C      Meteorological data from diagnostics:
C      Those marked with a * are derived data.
C      Those marked with a # are modified in READPP.
C      Other diagnostics are used within READPP.
C
      REAL T(NMETLONG,NMETLAT,NMETLEV,NHR),        ! Temperatures
     &     U(NMETLONG,NMETLAT,NMETLEV,NHR+1),      ! U Component of Wind
     &     VV(NMETLONG,NMETLAT,NMETLEV,NHR+1),     ! V Component of Wind
     &     W(NMETLONG,NMETLAT,NMETLEV,NHR+1),      ! Etadot
     &     Q(NMETLONG,NMETLAT,NMETLEV,NHR),        ! Specific Humidity
     &     CLW(NMETLONG,NMETLAT,NMETLEV,NHR),      ! Cloud liquid water
     &     P0(NMETLONG,NMETLAT,1,NHR),             ! Surface Pressure
     &     T0(NMETLONG,NMETLAT,1,NHR),             ! Surface Temperature
     &     BL(NMETLONG,NMETLAT,1,NHR),             !#Boundary Layer Depth
     &     VA(NMETLONG,NMETLAT,1,NHR),             !*Aerodynamic Deposition
     &     CC(NMETLONG,NMETLAT,1,NHR),             ! Convective Cloud Amount
     &     CB(NMETLONG,NMETLAT,1,NHR),             !#Convective Cloud Base No.
     &     CT(NMETLONG,NMETLAT,1,NHR),             !#Convective Cloud Top No.
     &     LCA(NMETLONG,NMETLAT,1,NHR),            ! Low Cloud Amount
     &     MCA(NMETLONG,NMETLAT,1,NHR),            ! Medium Cloud Amount
     &     HCA(NMETLONG,NMETLAT,1,NHR),            ! High Cloud Amount
     &     ACP(NMETLONG,NMETLAT,1,NHR),            !*Convective Precipitation
     &     ADP(NMETLONG,NMETLAT,1,NHR)             !*Dynamic Precipitation

C      INTEGER ISTAT,ICPU,LIB$GETJPI
C      REAL RESTCPU,DERIVCPU,JVALSCPU
      REAL QL(NCELL),M(NCELL),LIQ(NCELL)
      REAL D1,D2,ASTEP,HDIFF,VDIFF
      DOUBLE PRECISION TIME,CTIME,LMOLEC,MOLEC,ENDTIME,TIMESWAP,TI,DTS,
     &                 TMAX
      REAL DAY,DDAY,DAY0,DAYSTART,DAYNUMBER,ZEN,THET
      INTEGER DAYM(12),MONTH,MMONTH,OUTMON
      INTEGER CELLNO(NFOLLOW),DOBAL,CLINDX
      REAL NOXBAL(18,NFOLLOW),O3BAL(18,NFOLLOW)
      REAL NO0,NO20,HNO30,PAN0,NO30,N2O50,ORGNIT0
      REAL O30(NFOLLOW)
      INTEGER DONO2,IFILE
      REAL NO2EM(1,NLONG,MNLAT,NLEV),TOTNO2EM,MISSING
      CHARACTER*12 BINFILE
      REAL ETA2P,TMIN,RANDNUM
      INTEGER YEAR,YYEAR
      REAL OUTDAY,PERIOD
      CHARACTER*2 SMONTH
      LOGICAL CELLBUD
      CHARACTER*7 STATUS
      REAL ETIME,ET1
C   NO. OF DAYS IN EACH MONTH:
      DATA DAYM /31,28,31,30,31,30,31,31,30,31,30,31/
C   DEFINES FILE TO BE READ FIRST
      DATA IFILE/0/
      IF(CRAY) THEN
        STATUS='UNKNOWN'
      ELSE
        STATUS='NEW'
      ENDIF
      OPEN(7,FILE=OUTDIR//'stoch3d.out',STATUS=STATUS)
      OPEN(20,FILE=OUTDIR//'stoch3d.dat',STATUS=STATUS)
      OPEN(19,FILE=OUTDIR//'stoch3d.bud',STATUS=STATUS)
      OPEN(18,FILE=OUTDIR//'stoch3d.tot',STATUS=STATUS)
      OPEN(60,FILE=OUTDIR//'stoch3d.sta',STATUS=STATUS)
c      OPEN(61,FILE=OUTDIR//'depout.dat',STATUS=STATUS)
c      WRITE(61,*) "VD,DDEPO(K,I,L),VA(IM,JM,1),H,DD,K"
c      OPEN(61,FILE=OUTDIR//'stoch3d_new.txt',STATUS=STATUS)

C   ******************************************************************

C   INITIAL VALUES :
C   VERSION, D DIFFUSION COEFF. TIME, INITIAL TIME; ENDTIME.

      VERSION='S7_3_dlt   '
      OUTDAY=2.     ! Day of month for output to start
      PERIOD=25.      ! Averaging period in days
      D1=1.0D-03
      D2=1.0D-06
      ET1=SECNDS(0.0)
      YEAR=94        ! Starting date
      MONTH=10
      OUTMON=MONTH
      DAY=15.0
      ENDTIME=9.125    ! Duration of run in days
      CELLBUD=.FALSE.
      DONO2=1
c      YEAR = 98
c      MONTH=1
c      DAY =1
c      ENDTIME=365
      WRITE(6,*) 'Start Year (93-95) ? >>'
      READ(5,*) YEAR
      WRITE(6,*) YEAR
      WRITE(6,*) 'Start Month (1-12) ? >>'
      READ(5,*) MONTH
      WRITE(6,*) MONTH
      WRITE(6,*) 'Start Day (1-31) ? >>'
      READ(5,*) DAY
      WRITE(6,*) DAY
      WRITE(6,*) 'Run Length in days ? >>'
      READ(5,*) ENDTIME
      WRITE(6,*) ENDTIME

      WRITE(6,*) 'Start : ',DAY,'/',MONTH,'/',YEAR
      WRITE(6,*) 'Duration : ',ENDTIME,' (Days)'
      IF (DONO2.EQ.1) WRITE(6,*)'1. Lightning and Aircraft NOx'
      IF (DONO2.EQ.2) WRITE(6,*)'2. Lightning only NOx'
      IF (DONO2.EQ.3) WRITE(6,*)'3. Aircraft only NOx'
      IF (DONO2.EQ.4) WRITE(6,*)'4. No Lightning and Aircraft NOx'
C
C   PHOTOLYSIS STARTS AT MIDNIGHT GMT 21st June

      DAY0=DAYNUMBER(21.0,6,93)
      TIME=DBLE(SECS(INT(DAY),MONTH,(YEAR-93)))
      TIME=TIME+(DAY-INT(DAY))*86400.D0
      ENDTIME=TIME+86400.*ENDTIME
      NBLK=(NCELL/NBLOCK)
      NSTEP=0

C   ASTEP, Advection step; SEED, For normalised random no. generator;
C   SEED2, For selection of random no. from array; SEED not required on CRAY

      ASTEP=10800.0D00
      SEED=1277
      SEED2=3261
      SEED3=1234321
      CALL GETLIS(FLIST,FNAMES,NFLUX,CLIST,NCHEM,STLON,STLAT,NSTATION)
      PRINT *,'CLIST=',CLIST
      PRINT *,'FLIST=',FLIST
      CALL INIGRI(LONG,LONGM,LONGM2,LAT,LATM,LATM2)

C   CALCULATE TOTAL MASS OF MODEL ATMOSPHERE AND MASS OF CELLS

      CALL INIPOS(POS,NNN,LAT)
      DO J=1,NCELL
        CALL AINDEX(IPOS(1,J),POS(1,J))
      ENDDO

C   LMOLEC is number of molecules in one Lagrangian cell.
      LMOLEC=MOLEC()
      WRITE(7,201) VERSION,NLONG,MNLAT,NLEV,ASTEP,D1,D2,
     &            LONG,LAT,ETA3,LMOLEC

C   INTIALISE LAGRANGIAN CONCENTRATIONS OF CHEMICALLY REACTING SPECIES
C   -all cells start off the same
      CALL INICON(XX,NO0,NO20,HNO30,PAN0,NO30,N2O50,ORGNIT0,
     &  O30,IPOS,CELLNO)

C   -or initialize from a previous run - all eulerian grid squares different
C       CALL INICON3(XXO3,1,IPOS,'o3field.bin')
C       DO J=1,NCELL
C         XX(6,J)=XXO3(J)
C       ENDDO
      CALL MCALC(M0,XX,CLIST,IPOS,NCHEM)
      CALL ZEROFL(TFLUX,TOTFLU,TOTAVG,NAVG)
      CALL PLOT(CONC,XX,IPOS,NNN,0.,0.)

C   CALCULATE ARRAY OF NORMALLY DISTRIBUTED RANDOM NUMBERS

      CALL RANDOM(SEED,B)
      CALL RESTART(XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
     &  CONC,MCONC,SDCONC,
     &  NM,M0,TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,TOTAVG,NAVG)
      PRINT *,'TIME,ENDTIME=',TIME,ENDTIME

      CALL FILLDP3(EMISS,NC,NLONG,MNLAT,0.0E0)
      CALL FILLDP2(NOXBAL,18,NFOLLOW,0.0E0)
      CALL FILLDP2(O3BAL,18,NFOLLOW,0.0E0)

C      Open output balance diagnostics files,write headers etc.

      IF(CELLBUD) CALL INITBAL(CELLNO,ENDTIME,ASTEP,LMOLEC,POS,TIME)
      CLINDX=1

C       Next statement to modify total ozone data.
C      CALL O3TOTMOD(OZONE,DAY,MONTH,YEAR)

      WRITE(SMONTH,'(I2.2)') MONTH
C
C      Read in landmask, ozone and met. data
C
C        CALL DATRD(HUMID,metdir//'h2o85_big.dat'//SMONTH,35,9)
      CALL DATRD(LAND,DATDIR//'land_big.dat',17,1)
      CALL DATRD(OZONE,DATDIR//'oz_big.d'//SMONTH,30,1)
C       For CRAY version all meteorological diagnostics read in by READPP
      YYEAR=YEAR
      MMONTH=MONTH
      DDAY=DAY+.25
      IF(DDAY.GE.DAYM(MMONTH)+1.0) THEN
        DDAY=DDAY-DAYM(MMONTH)
        MMONTH=MMONTH+1
        IF(MMONTH.GT.12)THEN
          MMONTH=1
          YYEAR=YYEAR+1
        ENDIF
      ENDIF
      IF(CRAY) THEN
        CALL READPP2(U,VV,W,T,Q,CLW,P0,T0,BL,VA,CC,CB,CT,LCA,MCA,HCA,
     &            ACP,ADP,DAY,MONTH,IFILE)
C          Set first hours winds equal to second initially.
      ELSE
        CALL METREA2(P0,T,U(1,1,1,2),VV(1,1,1,2),W(1,1,1,2),
     &    DDAY,MMONTH,YYEAR)
        CALL WATREA2(Q,CLW)
        CALL CLRAIN2(HCA,MCA,LCA,CC,CB,CT,ACP,ADP,P0)
        CALL BLREAD2(BL,VA,P0,T,U(1,1,1,2),VV(1,1,1,2))
      ENDIF
      DO I=1,NMETLONG
        DO J=1,NMETLAT
          DO K=1,NMETLEV
            U(I,J,K,1)=U(I,J,K,2)
            VV(I,J,K,1)=VV(I,J,K,2)
            W(I,J,K,1)=W(I,J,K,2)
          ENDDO
        ENDDO
      ENDDO
      CALL CLCALC(CLOUD,HCA,MCA,LCA,CC,CB,CT)
C      Establish initial photolysis rates, call PLOT to provide Eulerian concs.
C
c      CALL PLOT(CONC,XX,IPOS,NNN,D1,D2)
C
C      Calculate influx from stratosphere (O3 & HNO3 only at present)
      CALL STRATCALC(EMISS,O3100,LAT,LMOLEC,MONTH,W(1,1,1,2),T(1,1,1,2))
C
C
C   Calculate emissions and dry depositions
C   EMISS has units (molecules s^-1 per grid square)
C                   (------------------------------)
C                   (     molecules per cell       )

      CALL EMCALC(EMISS,DDEPO,LAND,LMOLEC,MONTH)

C   Read in and convert NO2 emissions from lightning + aircraft

      CALL LIGHTREAD(NO2EM,MONTH,LMOLEC,DONO2)
      CALL TOTAL(TOTNO2EM,NO2EM,1)

C   ******************************************************************
C   ##ADVECTION

C   Main advection timestep loop start

      DO 70 WHILE (TIME.LT.ENDTIME)
      WRITE(6,*) 'DAY: ',DAY,' MONTH: ',MONTH,' YEAR: ',YEAR
      WRITE(7,*) 'DAY: ',DAY,' MONTH: ',MONTH,' YEAR: ',YEAR

C   Decide which 6-hour period for clouds, humidity etc.
      IHOUR=MOD(INT(0.5+TIME/21600.),4)+1
      PRINT *,'IHOUR=',IHOUR

C   RESET NUMBER ARRAYS TO ZERO

      CALL FILLIN3(NNN,NLONG,MNLAT,NLEV,0)
      CALL FILLIN2(NBL,NLONG,MNLAT,0)

      KK1=INT(RANDNUM(SEED2)*NCELL)
      KK2=INT(RANDNUM(SEED2)*NCELL)
      KK3=INT(RANDNUM(SEED2)*NCELL)
      KK4=INT(RANDNUM(SEED2)*NCELL)

      DO 55 J=1,NCELL
C       IF(MOD(J,1000).EQ.0) PRINT *,'J=',J
        S(1)=B(MOD((J+KK1),NCELL)+1)      !S's are fractions of the
        S(2)=B(MOD((J+KK2),NCELL)+1)      !standard deviations to add
        S(3)=B(MOD((J+KK3),NCELL)+1)      !(1,2,3=U,V,W)

        IM=INT(POS(1,J)/DLONGM+1.0)        ! Indices for met grids
        JM=INT(POS(2,J)/DLATM+1.0)         ! before advection
        I=IPOS(1,J)
        K=IPOS(2,J)
        L=IPOS(5,J)
C diffusion coefficients taken from NAME model
        IF(POS(3,J).GE.BL(IM,JM,1,IHOUR)) THEN ! in bl
          VDIFF=7.0E-9
          HDIFF=5300.0
        ELSE
          VDIFF=7.0E-9
          HDIFF=5300.0/4
        ENDIF
        CALL RKO4(POS(1,J),U,VV,W,LONGM,LATM,LONGM2,LATM2,TIME,ASTEP,
     &                S,J,BL(IM,JM,1,IHOUR),SEED)
C        DO N=1,NFLUX
C          IF(FLIST(1,N).GT.700) THEN ! Advection fluxes
C            TOTFLU(N)=TOTFLU(N)-XX(FLIST(1,N)-700,J)*LMOLEC
C            IF(FLIST(2,N).GT.0) THEN ! 3D fluxes
C              TFLUX(FLIST(2,N),I,L,K)=TFLUX(FLIST(2,N),I,L,K)-
C     &          XX(FLIST(1,N)-700,J)*LMOLEC
C            ENDIF
C          ENDIF
C        ENDDO
C        ETABLPLUS is set in NEWPOS now.
C        CALL NEWPOS(POS(1,J),V,ASTEP,J,BL(IM,JM,1,IHOUR),SEED)
        S(1)=B(MOD((J+KK4),NCELL)+1)
        CALL TEMP(POS(1,J),LONGM,LATM,T(1,1,1,IHOUR),TL(J))
C        Interpolate specific humidity & convert to mixing ratio
        CALL WATER(POS(1,J),LONGM,LATM,Q(1,1,1,IHOUR),CLW(1,1,1,IHOUR),
     &    QL(J),LIQ(J))
        IF(QL(J).LT.0.) PRINT *,'Q=',QL(J),'J=',J
C M in molecules/cm^3
        M(J)=1.0D-6*NA*(ETA2P(POS(3,J),P0(IM,JM,1,IHOUR))*1.0E2)/
     &    (RGC*TL(J))
C LIQ g/g -> g/cm^3
        LIQ(J)=LIQ(J)*MAIR*M(J)/NA
        CALL AINDEX(IPOS(1,J),POS(1,J))    !calc indices
        I=IPOS(1,J)
        K=IPOS(2,J)
        L=IPOS(5,J)
C        DO N=1,NFLUX
C          IF(FLIST(1,N).GT.700) THEN ! Advection fluxes
C            TOTFLU(N)=TOTFLU(N)+XX(FLIST(1,N)-700,J)*LMOLEC
C            IF(FLIST(2,N).GT.0) THEN ! 3D fluxes
C              TFLUX(FLIST(2,N),I,L,K)=TFLUX(FLIST(2,N),I,L,K)+
C     &          XX(FLIST(1,N)-700,J)*LMOLEC
C            ENDIF
C          ENDIF
C        ENDDO
        IM=INT(POS(1,J)/DLONGM+1.0)   ! Indicies for met grids
        JM=INT(POS(2,J)/DLATM+1.0)    ! after advection
        NNN(I,K,L)=NNN(I,K,L)+1       !Increment no. cells in box
        IF(POS(3,J).GE.BL(IM,JM,1,IHOUR))        ! BL in eta units
     &    NBL(I,K)=NBL(I,K)+1 ! Increment no. cells in b.l.
   55 CONTINUE                           !end of advection, now do chemistry
C   find grid boxes with no cells, increase NO2 em in all others to make up
      MISSING=0.0
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            IF(NNN(I,J,K).LT.1) MISSING=MISSING+NO2EM(1,I,J,K)
          ENDDO
        ENDDO
      ENDDO
      IF(TOTNO2EM.GT.0)THEN
        MISSING=TOTNO2EM/(TOTNO2EM-MISSING)
      ENDIF

C   ******************************************************************
C   CALCULATE NEW CONCENTRATIONS
C   EMISSION, DEPOSITION AND CHEMICAL EQUATIONS
C   Optimised version for Cray: EGET, DDCALC, DWCALC, CHEMCO, CHEMPH & DERIV
C   routines operate with NBLOCK dimensions.

C      Establish photolysis rates at start, 1/3, 2/3 and end of ASTEP.
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            O3CONC(I,J,K)=CONC(6,I,J,K)
          ENDDO
        ENDDO
      ENDDO
      CALL JVALS(DJA,CLOUD,OZONE,O3CONC,LAND,LAT,TIME,T,P0,O3100,LONG,
     &  ASTEP)

      DO 100 JA=1,NBLK                        ! Main block loop
C        PRINT *,'JA=',JA
        J=(JA-1)*NBLOCK+1
        CALL EGET(ESTORE,EM,EMITD,EMISS,IPOS(1,J),POS(1,J),
     &    BL(1,1,1,IHOUR),NNN,NBL,MONTH,NO2EM,TIME,MISSING)
        CALL DDCALC(DD,DDEPO,IPOS(1,J),POS(1,J),TL(J),BL(1,1,1,IHOUR),
     &              VA(1,1,1,IHOUR))
        CALL DWCALC(DW,ADP(1,1,1,IHOUR),ACP(1,1,1,IHOUR),
     &              CT(1,1,1,IHOUR),IPOS(1,J),POS(1,J))
C#######################################################################
C   Update chemical species concentrations and fluxes
        CALL DERIV(DD,DW,EM,DJA,TL(J),QL(J),LIQ(J),M(J),XX(1,J),FLUX,
     &    POS(1,J),IPOS(1,J),ASTEP,TIME,NOXBAL,O3BAL,CLINDX,CELLBUD,JA,
     &    SOA,MOM)

        DO 332 JB=1,NBLOCK
          J=JB+(JA-1)*NBLOCK                ! Cell index
          I=IPOS(1,J)
          L=IPOS(2,J)
          K=IPOS(5,J)
C        IF (J.EQ.CELLNO(CLINDX).AND.CELLBUD) CALL CELLBAL(NOXBAL(1,CLINDX),
C     &              O3BAL(1,CLINDX),POS(1,J),NO0,NO20,HNO30,PAN0,NO30,
C     &              N2O50,ORGNIT0,O30(CLINDX),CLINDX,TIME,ASTEP,DOBAL,
CC     &              NFOLLOW,TL(J),P0(IM,JM,1,IHOUR))
          DO N=1,NFLUX
            IF(FLIST(1,N).LT.2200) THEN
              TOTFLU(N)=TOTFLU(N)+FLUX(JB,FLIST(1,N))
              IF(FLIST(2,N).GT.0) THEN
                TFLUX(FLIST(2,N),I,L,K)=TFLUX(FLIST(2,N),I,L,K)+
     &            FLUX(JB,FLIST(1,N))
              ENDIF
            ENDIF
          ENDDO
  332   CONTINUE
C     ---------------------------------------------------------------
C
  100 CONTINUE                            ! End of nblock loop in JA

C   PLACE EMISSIONS INTO STORAGE IF NO CELLS ARE PRESENT
C   OR RESET STORAGE

      CALL STORE(ESTORE,EMISS,NNN,NBL,TIME,MONTH)
      CALL PLOT(CONC,XX,IPOS,NNN,D1,D2)
      CALL CLMIX(XX,POS,CC(1,1,1,IHOUR),CT(1,1,1,IHOUR),CB(1,1,1,IHOUR),
     &  ACP(1,1,1,IHOUR),P0(1,1,1,IHOUR),Q(1,1,1,IHOUR),ASTEP,SEED3)

C   ******************************************************************

      TIME=TIME+ASTEP

C   Calculate day and month. If month changes, get new emissions.

      DAY=DAY+ASTEP/86400.0
      IF(DAY.GE.DAYM(MONTH)+1.0) THEN
        DAY=DAY-DAYM(MONTH)
        MONTH=MONTH+1
        IF(MONTH.GT.12)THEN
          MONTH=1
          YEAR=YEAR+1
        ENDIF
        WRITE(6,*)'New Month, call EMCALC & lightread & stratcalc'
        WRITE(6,'(a5,2(i2.2,a1),i2.2)')
     &    'Day: ',INT(DAY),'-',MONTH,'-',YEAR
        CALL EMCALC(EMISS,DDEPO,LAND,LMOLEC,MONTH)

        WRITE(SMONTH,'(I2.2)') MONTH
        CALL DATRD(OZONE,DATDIR//'OZ_big.d'//SMONTH,30,1)
        CALL LIGHTREAD(NO2EM,MONTH,LMOLEC,DONO2)
        CALL TOTAL(TOTNO2EM,NO2EM,1)
      ENDIF
      IF(MOD(INT(0.5+TIME/21600.),4).EQ.0.AND.IHOUR.EQ.4)THEN
        YYEAR=YEAR
        MMONTH=MONTH
        DDAY=DAY+1.0
        IF(DDAY.GE.DAYM(MMONTH)+1.0) THEN
          DDAY=DDAY-DAYM(MMONTH)
          MMONTH=MMONTH+1
          IF(MMONTH.GT.12)THEN
            MMONTH=1
            YYEAR=YYEAR+1
          ENDIF
        ENDIF
C      Set first hours wind data equal to previous last.
        DO I=1,NMETLONG
          DO J=1,NMETLAT
            DO K=1,NMETLEV
              U(I,J,K,1)=U(I,J,K,5)
              VV(I,J,K,1)=VV(I,J,K,5)
              W(I,J,K,1)=W(I,J,K,5)
            ENDDO
          ENDDO
        ENDDO
        IF(CRAY) THEN
          CALL READPP2(U,VV,W,T,Q,CLW,P0,T0,BL,VA,CC,CB,CT,LCA,MCA,HCA,
     &            ACP,ADP,DDAY,MMONTH,IFILE)
        ELSE
          CALL METREA2(P0,T,U(1,1,1,2),VV(1,1,1,2),W(1,1,1,2),
     &      DDAY,MMONTH,YYEAR)
          CALL WATREA2(Q,CLW)
          CALL CLRAIN2(HCA,MCA,LCA,CC,CB,CT,ACP,ADP,P0)
          CALL BLREAD2(BL,VA,P0,T,U(1,1,1,2),VV(1,1,1,2))
        ENDIF
        CALL STRATCALC(EMISS,O3100,LAT,LMOLEC,MMONTH,W(1,1,1,3),
     &   T(1,1,1,3))
C        Next statement to modify total ozone data.
c        CALL O3TOTMOD(OZONE,DAY,MMONTH,YYEAR)
C
      ENDIF
C
      NSTEP=NSTEP+1
      ETIME=SECNDS(ET1)
      WRITE(6,*) 'NSTEP: ',NSTEP,' TCPU: ',ETIME
	WRITE(6,*)'SOA,MOM=',SOA(1),MOM(1),MOM(9)
      WRITE(7,*) 'NSTEP: ',NSTEP

C   ******************************************************************

C   COLLECT STATISTICS

      IF(DAY.EQ.OUTDAY) THEN
        CALL GETLIS(FLIST,FNAMES,NFLUX,CLIST,NCHEM,STLON,STLAT,NSTATION)
        CALL ZEROFL(TFLUX,TOTFLU,TOTAVG,NAVG)
        CALL ZEROST(MCONC,SDCONC,NM,NSTAT)
        CALL MCALC(M0,XX,CLIST,IPOS,NCHEM)
        CALL TOTAL(TOTM0,M0,NUMCHEM)
        WRITE(18,*) 'INVENTORY CALCULATED AT:'
        WRITE(18,204) TIME,NSTEP,DAY,MONTH
      ENDIF
C   START AVERAGING FROM 'OUTDAY' OF THE MONTH
      IF(DAY.GE.OUTDAY.AND.DAYNUMBER(DAY,MONTH,YEAR).LT.
     &  DAYNUMBER(OUTDAY,MONTH,YEAR)+PERIOD) THEN
        CALL SMOOTH(CONC,NNN,LAT,LONG)
        CALL STATS(MCONC,SDCONC,NM,NSTAT,NNN,CONC)
        CALL MCALC(M1,XX,CLIST,IPOS,NCHEM)
        CALL TOTAL(TOTM1,M1,NUMCHEM)
        NAVG=NAVG+1
        DO L=1,NUMCHEM
          TOTAVG(L)=TOTAVG(L)+TOTM1(L)
        ENDDO
      ENDIF
C   ******************************************************************
C   EVERY 3RD MONTH OUTPUT CONCENTRATIONS EVERY TIMESTEP ON THE 9TH

      IF(DAY.GE.OUTDAY.AND.
     &  DAYNUMBER(DAY,MONTH,YEAR).LT.DAYNUMBER(OUTDAY,MONTH,YEAR)
     &  +PERIOD.AND.MOD(MONTH,3).EQ.3) THEN ! use MOD .EQ.3 for no snapshots
        WRITE(20,204) TIME,NSTEP,DAY,MONTH
        WRITE(20,*) 'Snapshot concentrations'
        CALL SMOOTH(CONC,NNN,LAT,LONG)
        CALL OUTSTA(CONC,CLIST,NCHEM)
      ENDIF

C   OUTPUT STATISTICS FOR THE 8TH OF MONTH

      IF(ABS(DAYNUMBER(DAY,MONTH,YEAR)-(DAYNUMBER(OUTDAY,MONTH,YEAR)
     &  +PERIOD)).LT.0.1) THEN
C!* JUST BEFORE 0000

        WRITE(7,204) TIME,NSTEP,DAY,MONTH  !output location data
        CALL OUTLEV(NNN)

        WRITE(19,204) TIME,NSTEP,DAY,MONTH
        CALL MCALC(MASS,XX,CLIST,IPOS,NCHEM)
        CALL TOTAL(TOTMAS,MASS,NUMCHEM)
        CALL TOTAL(TOTM0,M0,NUMCHEM)

        WRITE(18,*) 'INVENTORY CALCULATED AT:'
        WRITE(18,204) TIME,NSTEP,DAY,MONTH
C        Calculate average inventories over the period.
        DO L=1,NUMCHEM
          TOTAVG(L)=TOTAVG(L)/NAVG
        ENDDO
        CALL OUTBUD(NM,MASS,M0,TFLUX,LMOLEC,CLIST,NCHEM,FNAMES,NFLUX,
     &    TOTM0,TOTMAS,TOTAVG,TOTFLU,NAVG,FLIST,OUTDAY,PERIOD,DAY,MONTH,
     &    YEAR)
        WRITE(20,204) TIME,NSTEP,DAY,MONTH
        WRITE(20,*) '24hr mean'
        CALL CALSTA(SDCONC,MCONC,NSTAT,M)
        CALL SMOOTH(MCONC,NNN,LAT,LONG)
C ! next line should be MCONC **************************************
        CALL OUTSTA(MCONC,CLIST,NCHEM)
      ENDIF
C
      IF(DAYNUMBER(DAY,MONTH,YEAR).EQ.
     &  DAYNUMBER(OUTDAY,MONTH,YEAR)+PERIOD+1.0) THEN ! Zero for next month.
        NAVG=0
        DO L=1,NUMCHEM
          TOTAVG(L)=0.0
        ENDDO
      ENDIF
C
      CALL STATION(XX,POS,BL(1,1,1,IHOUR),STLON,STLAT,NSTATION,DAY,
     &  MONTH,YEAR,CLIST,NCHEM,M)
      CALL PLOT(CONC,XX,IPOS,NNN,0.,0.)
      CALL DUMP(XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
     &  CONC,MCONC,SDCONC,NM,
     &  M0,TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,TOTAVG,NAVG)
   70 CONTINUE      !  MAIN ADVECTION TIMESTEP LOOP FINISH

C   save eulerian grid concentrations for initialisation of a future run

      WRITE(6,*)'Do you wish to save end concentrations for a future'//
     &'initialisation ?(0=no)'
C      READ(5,*) i
      I=0
      PRINT *,I
      IF(I.GT.0)THEN
        WRITE(6,*)'Enter filename for save of concentrations (12)'
        READ(5,'(12A)') BINFILE
        PRINT *,BINFILE
        OPEN(60,FILE=OUTDIR//BINFILE,FORM='UNFORMATTED',
     &         STATUS=STATUS)
        WRITE(60) CONC
        CLOSE(60)
      ENDIF

      STOP

C   ******************************************************************
C   ##FORMATS

  201 FORMAT(A10,' 3-D LAGRANGIAN TRANSPORT MODEL WITH '/
     *I4,' EULERIAN GRID CELLS AROUND A CIRCLE OF LONGITUDE AND ',
     *I4,' CELLS FROM POLE TO POLE.'/
     *I4,' DIVISIONS IN THE VERTICAL'/
     *'   ADVECTION STEP SIZE: ',
     *1F10.1,' SECONDS'/'   DIFFUSION COEFFICIENTS: ',2F9.4//
     *'   LONGITUDINAL GRID:'/18F4.0/18F4.0/18F4.0/18F4.0//
     *'   LATITUDINAL GRID:'/19F4.0/18F4.0//
     *'   VERTICAL GRID:'/10F10.4//
     *'   MOLECULES PER CELL:',1PD14.6)
  202 FORMAT('EULERIAN WINDSPEEDS IN SURFACE CELLS'/
     &       24(9F7.3/)//)
  204 FORMAT(//'TIME',F12.1,'   NSTEP',I10,'    DAY ',F5.2,'    MONTH',
     &       I2//)
  205 FORMAT('TIME',F12.1,'    NSTEP',I10,' INVENTORY ANALYSIS'//
     &       '  SPECIES      ','LAGRANGIAN INVENTORY',
     &       '        L/E FACTOR ','     TOTAL EMITTED  '//)
  990 FORMAT(I5,2F10.4)
  995 FORMAT(E12.4)
      END

C***********************************************************************

C***********************************************************************
      SUBROUTINE RANDOM(SEED,X)
C
C     PROVIDES NCELL NORMALLY DISTRIBUTED RANDOM NUMBERS
C
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C
      REAL X(NCELL)
      REAL Q,T,V,SIGN,RANDNUM
      INTEGER SEED, I
C
      DO 10 I=1,NCELL
        Q = RANDNUM(SEED)
        IF (Q.GT.0.5) THEN
          Q=Q-0.5
          SIGN=-1.0
        ELSE
          SIGN=1.0
        ENDIF
        T = SQRT(LOG(1.0/Q**2))
        V = T - (2.515517+0.802853*T+0.010328*T**2)/
     &        (1.0+1.432788*T+0.189269*T**2+0.001308*T**3)
        X(I)=V*SIGN
   10 CONTINUE
      RETURN
      END
C#######################################################################
      SUBROUTINE READPP2(U,VV,W,T,Q,CLW,P0,T0,BL,VA,CC,CB,CT,LCA,
     &     MCA,HCA,ACP,ADP,DAY,MONTH,IFILE)
C----------------------------------------------------------------------
C-   USE FOR READING PP FIELDS IN IBM FORMAT ON CRAY.
C-
C-   Purpose and Methods : Read in pp fields
C-
C-   Inputs  : NMETLEV,NMETLONG,NMETLAT,NHR
C-   Outputs : U,VV,W,T etc
C-   Controls:
C-
C-   Created    8-SEP-1995   C.E. Johnson
C-   Updated   18-SEP-1995   DS Put it into STOCHEM Rn tracer model
C-   Updated   18-DEC-1995   DS read in P0 clouds and rain for convection
C-                           - based on bills CLRAIN routine.
C-   Updated   16-JUL-1996   CEJ Changed array dimensions (IHR at end),
C-                             more diagnostics. Added VA calculation.
C-   Modified   5-AUG-1996   CEJ Added BL from (m) to eta calculation.
C-   Updated   6-AUG-1996   Bill Collins Parameters now in INCLUDE code.
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated    7-AUG-1996   DS added var UNIT, to cope with 5 day blocks.
C-   Updated   19-AUG-1996   DS now correctly reads tauu,tauv,hf & cc.
C-                        DS nb day and month are redundant for sequential
C-                           reading (ifile).
C-   Updated    2-OCT-1996  CEJ Added IWHR to read in winds as hours 2-5.
C-   Updated   16-JAN-1997  CEJ Altered READ to account for offset, see
C-                          Emma Hibling's testread.f90 program.
C-                          (getibm should use df=tb option, and the -N ibm
C-                          option in the assign statement should NOT be used).
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
C
      INTEGER MAXFIELD,NFIELDS
      PARAMETER(MAXFIELD=8000,NFIELDS=736)
      INTEGER HEADER(45),PPBUFFER(32)
      REAL RHEADER(46:64)
      REAL DATA1(7008)
      REAL DATA2(6912)
      REAL IBMPPFIELD((MAXFIELD/2)+1)
C
      INTEGER H,I,I2,J,K,N, NF, LBYR, LBMON, LBDAT, LBHR, LBLREC,
     &        LBFC, LBVC, LBLEV, IHR, IWHR, ILEV, STASH, LBPROC,
     &        CONVCODE, FIELDSIZE, IFILE, MONTH
      REAL BLEV, BZY, BDY, BZX, BDX, BHLEV, ETA, DAY
C
      REAL MOD2ETA,AERO,ETA2P,ccmax
      REAL  U(NMETLONG,NMETLAT,NMETLEV,NHR+1),
     &     VV(NMETLONG,NMETLAT,NMETLEV,NHR+1),
     &     W(NMETLONG,NMETLAT,NMETLEV,NHR+1),
     &     T(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     Q(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     CLW(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     P0(NMETLONG,NMETLAT,1,NHR),
     &     T0(NMETLONG,NMETLAT,1,NHR),
     &     BL(NMETLONG,NMETLAT,1,NHR),
     &     TAUU(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     TAUV(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     VA(NMETLONG,NMETLAT,1,NHR),
     &     HF(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     CC(NMETLONG,NMETLAT,1,NHR),
     &     CB(NMETLONG,NMETLAT,1,NHR),
     &     CT(NMETLONG,NMETLAT,1,NHR),
     &     HCA(NMETLONG,NMETLAT,1,NHR),
     &     MCA(NMETLONG,NMETLAT,1,NHR),
     &     LCA(NMETLONG,NMETLAT,1,NHR),
     &     ACP(NMETLONG,NMETLAT,1,NHR),
     &     ACR(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     ACS(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     ADP(NMETLONG,NMETLAT,1,NHR),
     &     ADR(NMETLONG,NMETLAT,1,NHR),                ! internal
     &     ADS(NMETLONG,NMETLAT,1,NHR)                 ! internal
      INTEGER UNIT

      INTEGER IBM2CRAY             ! Cray Library function
C      EXTERNAL IBM2CRAY

C      Set unused portion of u grid arrays to value.

      DO I=1,NMETLONG
        DO K=1,NHR
          TAUU(I,73,1,K)=9.9999
          TAUV(I,73,1,K)=9.9999
          DO J=1,NMETLEV
            U(I,73,J,K+1)=9.9999
            VV(I,73,J,K+1)=9.9999
          ENDDO
        ENDDO
      ENDDO

C      Read the header and data

      N=0
      UNIT=94+IFILE
      WRITE(6,*)'Reading met data on unit:',UNIT
      OPEN(80,FILE='readpp.out',STATUS='UNKNOWN')
      WRITE(80,*)'Reading met data on unit:',UNIT
      WRITE(80,*) ' LBYR LBMON LBDAT  LBHR LBLREC LBLEV  LBVC',
     &           '     ETA     LBFC STASH'
      DO 10 NF=1,NFIELDS
        READ(UNIT) HEADER,RHEADER
        READ(UNIT,END=91) PPBUFFER

C        Convert the header to Cray format, and split into integer and 
C        real parts.
         CONVCODE=0
C        CONVCODE=IBM2CRAY(1,45,PPBUFFER,0,HEADER)
        IF(CONVCODE.NE.0) THEN
C          WRITE(6,*) 'ERROR CONVERTING HEADER INTEGERS, FIELD: ',N
          GOTO 100
        ENDIF
C        The header contains 64 words, 45 integers and 19 reals. Reals
C        therefore start at word 23 of the buffer array. This word contains
C        IBM words 45 and 46, so to pick up the first real (IBM word 46),
C        we need to use an offset.
C        CONVCODE=IBM2CRAY(2,19,PPBUFFER(23),32,RHEADER)
        IF(CONVCODE.NE.0) THEN
C          WRITE(6,*) 'ERROR CONVERTING HEADER REALS, FIELD: ',N
          GOTO 100
        ENDIF
        N=N+1
        LBYR=HEADER(1)
        LBMON=HEADER(2)
        LBDAT=HEADER(3)
        LBHR=HEADER(4)
        LBLREC=HEADER(15)
        LBFC=HEADER(23)
        LBPROC=HEADER(25)
        LBVC=HEADER(26)
        LBLEV=HEADER(33)
        STASH=HEADER(42)
        BLEV=RHEADER(52)          !'B' value of level
        BHLEV=RHEADER(54)         !'A' value of level
        BZY=RHEADER(59)
        BDY=RHEADER(60)
        BZX=RHEADER(61)
        BDX=RHEADER(62)
        IF(LBVC.EQ.9) THEN
          ETA=RHEADER(52)+(RHEADER(54)/1.0E5)
        ENDIF

        WRITE(80,110) LBYR,LBDAT,LBMON,LBHR,LBLREC,LBLEV,
     &               LBVC,ETA,LBFC,STASH
C
C        Get the field and convert it.
        FIELDSIZE=HEADER(15)/2
        IF (LBLREC.EQ.7008) THEN      !read one levels worth data
          READ(UNIT,END=91) (IBMPPFIELD(I),I=1,FIELDSIZE)
C          CONVCODE = IBM2CRAY(2, HEADER(15), IBMPPFIELD, 0, DATA1)
        ELSEIF (LBLREC.EQ.6912) THEN
          READ(UNIT,END=91) (IBMPPFIELD(I),I=1,FIELDSIZE)
C          CONVCODE = IBM2CRAY(2, HEADER(15), IBMPPFIELD, 0, DATA2)
        ELSE
          WRITE(6,*) 'LBLREC NOT EQUAL TO 7008 OR 6912'
          GOTO 100
        ENDIF
        IF(CONVCODE.NE.0) THEN
C          WRITE(6,*) 'ERROR CONVERTING DATA, FIELD: ',N
          GOTO 100
        END IF
C
C        Calculate hour and height indices and fill the data arrays.
C        The time sequence is 06,12,18,00 hrs
C        IWHR has previous 00 as IHR=1, rest= 1-5.
        IHR=(LBHR/6)
        IF (IHR.EQ.0) IHR=4
        IWHR=IHR+1
        IF (LBVC.EQ.9) THEN                           !data on eta levels
C        Calculate height index for fields on eta grid.
          IF (LBLEV.EQ.9999) THEN
            ILEV=1
          ELSE
            ILEV=LBLEV
          ENDIF
          IF (ILEV.LE.NMETLEV) THEN         ! do we want the data, or is it
C                                           ! beyond our upper boundary ?
C
C        Fill the data arrays, depending on p or u grid.
            IF (LBLREC.EQ.7008) THEN                          ! p grid
              DO  J=1,NMETLAT
                DO I=1,NMETLONG
                  K=(J-1)*NMETLONG+I
                  IF(LBFC.EQ.43)  W(I,J,ILEV,IWHR)=DATA1(K)
                  IF(LBFC.EQ.16.AND.STASH.EQ.5209)
     &                            T(I,J,ILEV,IHR)=DATA1(K)
                  IF(LBFC.EQ.95)  Q(I,J,ILEV,IHR)=DATA1(K)
                  IF(STASH.EQ.3217.AND.LBLEV.EQ.9999)
     &                            HF(I,J,1,IHR)=DATA1(K)
C                  IF(LBFC.EQ.34)  CC2(I,J,ILEV,IHR)=DATA1(K)  ! not available
                  IF(LBFC.EQ.79)  CLW(I,J,ILEV,IHR)=DATA1(K)
                ENDDO
              ENDDO
            ENDIF
            IF (LBLREC.EQ.6912) THEN                          ! u grid
              DO  J=1,NMETLAT-1
                DO I=1,NMETLONG
                  K=(J-1)*NMETLONG+I
                  IF(LBFC.EQ.56)  U(I,J,ILEV,IWHR)=DATA2(K)
                  IF(LBFC.EQ.57) VV(I,J,ILEV,IWHR)=DATA2(K)
                  IF(LBFC.EQ.61.AND.LBLEV.EQ.9999)
     &                           TAUU(I,J,1,IHR)=DATA2(K)
                  IF(LBFC.EQ.62.AND.LBLEV.EQ.9999)
     &                           TAUV(I,J,1,IHR)=DATA2(K)
                ENDDO
              ENDDO
            ENDIF
          ENDIF
        ELSEIF (LBVC.EQ.129.OR.LBVC.EQ.142.
     &         OR.LBVC.EQ.143.OR.LBVC.EQ.5.OR.LBVC.EQ.0) THEN
C           !Surface or other 2-D field.
          IF (LBLREC.EQ.7008) THEN
            DO J=1,NMETLAT
              DO I=1,NMETLONG
                K=(J-1)*NMETLONG+I
                IF(LBFC.EQ.5)    BL(I,J,1,IHR)=DATA1(K)    !n.b. BL is in metres
                IF(LBFC.EQ.8.AND.STASH.EQ.1)
     &                             P0(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.16.AND.STASH.EQ.24)
     &                             T0(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.31)  HCA(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.32)  MCA(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.33)  LCA(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.34)   CC(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.98.AND.LBPROC.EQ.0)
     &                            ACR(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.99.AND.LBPROC.EQ.0)
     &                            ADR(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.119.AND.LBPROC.EQ.0)
     &                            ACS(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.118.AND.LBPROC.EQ.0)
     &                            ADS(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.222)  CB(I,J,1,IHR)=DATA1(K)
                IF(LBFC.EQ.223)  CT(I,J,1,IHR)=DATA1(K)
              ENDDO
            ENDDO
          ENDIF
        ENDIF
C
   10 CONTINUE
C
      GOTO 92
   91 WRITE(6,*) 'End of file reached by READPP'
      WRITE(80,*) 'End of file reached by READPP'
   92 CONTINUE
      WRITE(6,*) N,' FIELDS READ'
      WRITE(80,*) N,' FIELDS READ'
      IFILE=IFILE+1

      ccmax=0.0
      DO H=1,NHR
        DO I=1,NMETLONG
          DO J=1,NMETLAT
C Convert cloud top/bottoms from model levels to eta, then to pressure.
            IF(CB(I,J,1,H).NE.0.) THEN  ! check there is a cloud there
              CB(I,J,1,H)=MOD2ETA(CB(I,J,1,H))
              CB(I,J,1,H)=MIN(CB(I,J,1,H),0.96) ! Lower limit on base
              CT(I,J,1,H)=MOD2ETA(CT(I,J,1,H))
              IF(CT(I,J,1,H).LT.0.09) PRINT *,' *** READPP: CT < 0.09 ',
     &              'I=',I,' J=',J,' H=',H,' CT=',CT(I,J,1,H)
            ENDIF
C Precipitation=rain+snow
            ACP(I,J,1,H)=ACR(I,J,1,H)+ACS(I,J,1,H)
            ADP(I,J,1,H)=ADR(I,J,1,H)+ADS(I,J,1,H)
C Calculate aerodynamic deposition velocity
            VA(I,J,1,H)=AERO(T0(I,J,1,H),TAUU(I,J,1,H),
     &        TAUV(I,J,1,H),HF(I,J,1,H))
C Convert BL depth from metres to eta.
            IF(T(I,J,1,H).LT.100.0) WRITE(6,*) ' *** READPP: ',
     &        ' T < 100 ! I,J,H = ',I,J,H,' T = ',T(I,J,1,H)
            BL(I,J,1,H)=EXP(-BL(I,J,1,H)*G*MAIR*1E-3/(RGC*T(I,J,1,H)))
C Convert P0 from Pa to hPa.
            P0(I,J,1,H)=P0(I,J,1,H)/100.0
            if(CC(I,J,1,H).gt.ccmax) ccmax=CC(I,J,1,H)
          ENDDO
        ENDDO
      ENDDO
c      print*,'Max cc(P at cloud base):',ccmax

C Print out some results for checking:
      WRITE(80,*) ' *** READPP: Results for I=8,J=20,K=1,'
      I=8
      J=50
      K=1
      DO H=1,4
        WRITE(80,*)  ' HOUR: ',H
        WRITE(80,*)  ' U: ',U(I,J,K,H+1)
        WRITE(80,*)  ' VV: ',VV(I,J,K,H+1)
        WRITE(80,*)  ' W: ',W(I,J,K,H+1)
        WRITE(80,*)  ' T: ',T(I,J,K,H)
        WRITE(80,*)  ' Q: ',Q(I,J,K,H)
        WRITE(80,*)  ' CLW: ',CLW(I,J,K,H)
        WRITE(80,*)  ' P0: ',P0(I,J,1,H)
        WRITE(80,*)  ' T0: ',T0(I,J,1,H)
        WRITE(80,*)  ' BL: ',BL(I,J,1,H)
        WRITE(80,*)  ' HF: ',HF(I,J,1,H)
        WRITE(80,*)  ' TAUU: ',TAUU(I,J,1,H)
        WRITE(80,*)  ' TAUV: ',TAUV(I,J,1,H)
        WRITE(80,*)  ' VA: ',VA(I,J,1,H)
        WRITE(80,*)  ' CC: ',CC(I,J,1,H)
        WRITE(80,*)  ' CB: ',CB(I,J,1,H)
        WRITE(80,*)  ' CT: ',CT(I,J,1,H)
        WRITE(80,*)  ' HCA: ',HCA(I,J,1,H)
        WRITE(80,*)  ' MCA: ',MCA(I,J,1,H)
        WRITE(80,*)  ' LCA: ',LCA(I,J,1,H)
        WRITE(80,*)  ' ACP: ',ACP(I,J,1,H)
        WRITE(80,*)  ' ADP: ',ADP(I,J,1,H)
      ENDDO

      GOTO 101
 100  CONTINUE  
C      WRITE(6,*) 'ERROR IN READPP, SKIPPED STATEMENTS'
C      WRITE(6,*) N,' FIELDS READ OUT OF ',NFIELDS
 101  CONTINUE
      CLOSE(80)
      RETURN
 110  FORMAT(7I6,F12.6,2I6)
      END
C#######################################################################
      SUBROUTINE DATRD(D,FNAME,LUN,NLEVELS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : FILL DATA ARRAYS
C-
C-   Inputs  : FNAME,LUN,NLEVELS
C-   Outputs : D
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  24-JUN-1994   Bill Collins  MADE MORE GENERAL
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER LUN,NLEVELS
      CHARACTER*(*) FNAME
      REAL D(NLONG,MNLAT,NLEVELS)
      INTEGER I,J,K
C
      OPEN(LUN,FILE=FNAME,STATUS='OLD')
      READ(LUN,*) (((D(I,J,K),I=1,NLONG),J=MNLAT,1,-1),K=1,NLEVELS)
      CLOSE(LUN)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE METREA2(P0,T,U,VV,W,DAY,MONTH,YEAR)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN MET DATA
C-
C-   Inputs  : DAY,MONTH,YEAR
C-   Outputs : P0,T,U,VV,W
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   2-MAR-1995   Bill Collins  Just pass file description and month
C-                                        to MREAD
C-   Updated  10-JUL-1996   Bill Collins  Now read 6 hourly met files
C-   Updated   7-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  No longer have surface level for U,V,
C-                                        W or T, remove 0th lat circle
C-   Updated   4-DEC-1996   Bill Collins  Reads from combined daily file
C-   Updated  26-JUN-1998   Bill Collins  Uses dlt tapes 
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      CHARACTER SDATE*4
      INTEGER MONTH,YEAR
      REAL DAY,RDAY,RMONTH,RYEAR

c      READ IN METEOROLOGICAL FIELDS

C      METEOROLOGICAL GRIDS:
C      T,P0 USES    GRID1: ORIGIN 0E,90N
C                   ETA2 LEVELS
C      W USES       GRID2: ORIGIN 0E,90N
C                   ETA1 LEVELS
C      U,VV USES    GRID3: ORIGIN 0E+(1.25/2), 90N-(0.833333/2)
C                   ETA2 LEVELS
C
C      UNITS AND SIGN CONVENTION:
C
C      P0   mb
C      T    C
C      U    knots, +ve EAST
C      VV   knots, +ve NORTH
C      W    eta dot, -ve UP
C
      INTEGER I,J,K,IHOUR,IERR,ISTAT,LIB$WAIT,ICOUNT
      REAL P0(NMETLONG,NMETLAT,NHR),
     &     T(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     U(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     VV(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     W(NMETLONG,NMETLAT,NMETLEV,NHR)
C
      WRITE(SDATE,'(2I2.2)') INT(DAY),MONTH
      IERR=1
      OPEN(8,FILE='c:\metdata\A'//SDATE//'98.dat',
     &    STATUS='OLD',FORM='UNFORMATTED',CONVERT='IBM',
     &    RECL=288,BLOCKSIZE=9216,RECORDTYPE='FIXED')
c      OPEN(8,FILE='E:\A'//SDATE//'.TXT')
c      OPEN(10,FILE='OUTPUTFROM_ASSCI.TXT')
      READ(8) RDAY,RMONTH,RYEAR
c      READ(8,*) RDAY,RMONTH,RYEAR
c      WRITE(10,*)RDAY,RMONTH,RYEAR
      PRINT *,'RDAY,RMONTH,RYEAR=',RDAY,RMONTH,RYEAR
C
      CALL MREAD2(P0,'P',1)
      CALL MREAD2(T,'T',NMETLEV)
      CALL MREAD2(U,'U',NMETLEV)
      CALL MREAD2(VV,'V',NMETLEV)
      CALL MREAD2(W,'W',NMETLEV)
C
C      CONVERT U AND V TO m/s, T TO Kelvin
C
      DO IHOUR=1,NHR
        DO K=1,NMETLEV
          DO J=1,NMETLAT
            DO I=1,NMETLONG
              U(I,J,K,IHOUR)=U(I,J,K,IHOUR)*0.515
              VV(I,J,K,IHOUR)=VV(I,J,K,IHOUR)*0.515
              T(I,J,K,IHOUR)=T(I,J,K,IHOUR)+273.15
            ENDDO
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CLRAIN2(HCA,MCA,LCA,CC,CB,CT,ACP,ADP,P0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN CONVECTIVE CLOUD DATA
C-
C-   Inputs  : P0
C-   Outputs : HCA,MCA,LCA,CC,CB,CT,ACP,ADP
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   2-MAR-1995   Bill Collins  Just pass file description and month
C-                                        to MREAD
C-   Updated   5-DEC-1995   Bill Collins  Read cloud data.
C-   Updated  21-MAY-1996   Bill Collins  Add dynamic rain for wet dep.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated   8-AUG-1996   Bill Collins  Added high,med,low cloud
C-   Updated   4-DEC-1996   Bill Collins  Reads from combined daily file
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
C
C      UNITS: hPa - convert to eta
C
C
      INTEGER I,J,K
      REAL P0(NMETLONG,NMETLAT,1,NHR),
     &     CC(NMETLONG,NMETLAT,1,NHR),
     &     CB(NMETLONG,NMETLAT,1,NHR),
     &     CT(NMETLONG,NMETLAT,1,NHR),
     &     ACP(NMETLONG,NMETLAT,1,NHR),
     &     ADP(NMETLONG,NMETLAT,1,NHR),
     &     ACR(NMETLONG,NMETLAT,1,NHR),
     &     ACS(NMETLONG,NMETLAT,1,NHR),
     &     ADR(NMETLONG,NMETLAT,1,NHR),
     &     ADS(NMETLONG,NMETLAT,1,NHR),
     &     HCA(NMETLONG,NMETLAT,1,NHR),
     &     MCA(NMETLONG,NMETLAT,1,NHR),
     &     LCA(NMETLONG,NMETLAT,1,NHR)
      REAL P2ETA

C
C
      CALL MREAD2(HCA,'CH',1)
      CALL MREAD2(MCA,'CM',1)
      CALL MREAD2(LCA,'CL',1)
      CALL MREAD2(CC,'cc',1)
      CALL MREAD2(CB,'cb',1)
      CALL MREAD2(CT,'ct',1)
      CALL MREAD2(ADR,'dr',1)
      CALL MREAD2(ACR,'cr',1)
      CALL MREAD2(ADS,'ds',1)
      CALL MREAD2(ACS,'cs',1)
      DO K=1,NHR
        DO J=1,NMETLAT
          DO I=1,NMETLONG
C convert from hPa to eta
            IF(CB(I,J,1,K).NE.0.) THEN  ! check there is a cloud there
              CB(I,J,1,K)=MIN(CB(I,J,1,K),P0(I,J,1,K)-40.)! Lower limit on base
C              IF(CB(I,J,1,K).LT.100.) PRINT *,'CB',I,J,K,CB(I,J,1,K)
              CB(I,J,1,K)=P2ETA(CB(I,J,1,K),P0(I,J,1,K))
C              IF(CT(I,J,1,K).LT.100.) PRINT *,'CT',I,J,K,CT(I,J,1,K)
              CT(I,J,1,K)=P2ETA(CT(I,J,1,K),P0(I,J,1,K))
            ENDIF
C precipitation=rain+snow, convert from per six hours to per seconds
            ACP(I,J,1,K)=(ACR(I,J,1,K)+ACS(I,J,1,K))/(3600.*6)
            ADP(I,J,1,K)=(ADR(I,J,1,K)+ADS(I,J,1,K))/(3600.*6)
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE BLREAD2(BL,VA,P0,T,U,VV)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE BOUNDARY PARAMETERS - DEPTH AND AERODYNAMIC
C-                         DEPOSITION VELOCITY
C-
C-   Inputs  : P0,VA,T,U,VV
C-   Outputs : BL
C-   Controls:
C-
C-   Created   11-JUL-1996  W.J. Collins
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated   4-DEC-1996   Bill Collins Reads from combined daily file
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IHOUR
C
      INTEGER I,J,K
      REAL P0(NMETLONG,NMETLAT,1,NHR),
     &     T(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     U(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     VV(NMETLONG,NMETLAT,NMETLEV,NHR),
     &     BL(NMETLONG,NMETLAT,1,NHR),
     &     VA(NMETLONG,NMETLAT,1,NHR),
     &     T0(NMETLONG,NMETLAT,1,NHR),
     &     TAUU(NMETLONG,NMETLAT,1,NHR),
     &     TAUV(NMETLONG,NMETLAT,1,NHR),
     &     H(NMETLONG,NMETLAT,1,NHR),
     &     UCOL(NMETLEV),VCOL(NMETLEV),TCOL(NMETLEV)
      REAL BOUND,AERO

C
      CALL MREAD2(T0,'t0',1)
      CALL MREAD2(H,'h',1)
      CALL MREAD2(TAUU,'tu',1)
      CALL MREAD2(TAUV,'tv',1)
      CLOSE(8)
c      CLOSE(10)
      DO IHOUR=1,NHR
        DO J=1,NMETLAT
          DO I=1,NMETLONG
            T0(I,J,1,IHOUR)=T0(I,J,1,IHOUR)+273.15
            DO K=1,NMETLEV
              UCOL(K)=U(I,J,K,IHOUR)
              VCOL(K)=VV(I,J,K,IHOUR)
              TCOL(K)=T(I,J,K,IHOUR)
            ENDDO
C Calculate boundary layer depth (as eta)
C            PRINT *,'T0,P0',T0(I,J,1,IHOUR),P0(I,J,1,IHOUR)
C            PRINT*,'TCOL,UCOL,VCOL',TCOL,UCOL,VCOL
            BL(I,J,1,IHOUR)=BOUND(T0(I,J,1,IHOUR),P0(I,J,1,IHOUR),TCOL,
     &        UCOL,VCOL)
            IF(BL(I,J,1,IHOUR).EQ.-1) THEN
              PRINT *,'BL=-1,I,J,IHOUR=',I,J,IHOUR
              PRINT *,'T0,P0',T0(I,J,1,IHOUR),P0(I,J,1,IHOUR)
              PRINT*,'TCOL,UCOL,VCOL',TCOL,UCOL,VCOL
            ENDIF
C Calculate aerodynamic deposition velocity
            VA(I,J,1,IHOUR)=AERO(T0(I,J,1,IHOUR),TAUU(I,J,1,IHOUR),
     &        TAUV(I,J,1,IHOUR),H(I,J,1,IHOUR))
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE WATREA2(Q,CLW)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ HUMIDITY DATA
C-
C-   Inputs  :
C-   Outputs : Q,CLW
C-   Controls:
C-
C-   Created   07-AUG-1996  W.J. Collins
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated   4-DEC-1996   Bill Collins Reads from combined daily file
C-   Updated   8-JAN-1997   Bill Collins Added cloud liquid water
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      CHARACTER SDATE*6
      INTEGER MONTH,MTH,YEAR,IHOUR,I,J,K
      REAL DAY
      REAL Q(NMETLONG,NMETLAT,NMETLEV,NHR)
      REAL CLW(NMETLONG,NMETLAT,NMETLEV,NHR)
      REAL ICE(NMETLONG,NMETLAT,1,NHR)

C
      CALL MREAD2(Q,'Q',NMETLEV)
      CALL MREAD2(CLW,'WAT',NMETLEV)
      CALL MREAD2(ICE,'ICE',1)
C No data for highest level - set humidity and liquid water to zero.
      DO K=1,NHR
        DO J=1,NMETLAT
          DO I=1,NMETLONG
            Q(I,J,NMETLEV,K)=0.
            CLW(I,J,NMETLEV,K)=0.
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END

C***********************************************************************
      SUBROUTINE MREAD2(M,FNAME,NLEVELS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN DATA FILES
C-
C-   Inputs  : FNAME,LUN,NLEVELS
C-   Outputs : M
C-   Controls:
C-
C-   Created  24-JUN-1994   Bill Collins
C-   Updated   2-MAR-1995   Bill Collins  Reads binary or text files
C-   Updated  10-JUL-1996   Bill Collins  Read 6 hourly files, binary only
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated   4-DEC-1996   Bill Collins  Reads from combined daily file
C-   Updated   8-JAN-1997   Bill Collins  Added cloud liquid water
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NLEVELS,I,J,K,ILEV,IHOUR,LUN
      REAL M(NMETLONG,NMETLAT,NLEVELS,NHR)
      REAL DUMMY(NMETLONG,NMETLAT)
      CHARACTER*(*) FNAME
C
      LUN=8
C       LUN = 10
C
      PRINT *,FNAME
      DO IHOUR=1,NHR
        DO K=1,NLEVELS
C Temporary fix to read right number of records. Q and T have extras that we
C don't want to read
          IF(FNAME.EQ.'Q'.OR.FNAME.EQ.'T'.OR.FNAME.EQ.'WAT') THEN
            IF(K.EQ.9) THEN
              DO J=1,NMETLAT
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
              ENDDO
            ELSEIF(K.EQ.10) THEN
              DO J=1,NMETLAT
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
              ENDDO
            ELSEIF(K.EQ.11.AND.FNAME.EQ.'T') THEN
              DO J=1,NMETLAT
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
                READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C                WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
              ENDDO
            ENDIF
          ENDIF
          IF((FNAME.NE.'Q'.AND.FNAME.NE.'WAT').OR.K.LT.NMETLEV) THEN
             DO J=1,NMETLAT
                READ(LUN) (M(I,J,K,IHOUR),I=1,NMETLONG)
c                WRITE(10,*) (M(I,J,K,IHOUR),I=1,NMETLONG)
             ENDDO
          ENDIF
        ENDDO
C Temporary fix to read right no. of records. W,Q have one less than the others
        IF(NLEVELS.GT.1.AND.
     &    (FNAME.NE.'W'.AND.FNAME.NE.'Q'.AND.FNAME.NE.'WAT')) THEN
          DO J=1,NMETLAT
            READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C            WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
          ENDDO
        ENDIF
C Fix not to read in cloud ice data
        IF(FNAME.EQ.'ICE') THEN
          DO K=1,14
            DO J=1,NMETLAT
              READ(LUN) (DUMMY(I,J),I=1,NMETLONG)
C              WRITE(10,*) (DUMMY(I,J),I=1,NMETLONG)
            ENDDO
          ENDDO
        ENDIF
      ENDDO
C  12    FORMAT(288(1PE15.8))
  999 RETURN
      END
C#######################################################################
      SUBROUTINE DATRD2(D,FNAME,LUN,NLEVELS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : FILL DATA ARRAYS
C-
C-   Inputs  : FNAME,LUN,NLEVELS
C-   Outputs : D
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  24-JUN-1994   Bill Collins  MADE MORE GENERAL
C-   Updated  16-OCT-1995   Colin Johnson REVERSE LATITUDE READ (N to S)
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER LUN,NLEVELS
      CHARACTER*(*) FNAME
      REAL D(NLONG,MNLAT,NLEVELS)
      INTEGER I,J,K
C
      OPEN(LUN,FILE=FNAME,STATUS='OLD')
      READ(LUN,*) (((D(I,J,K),I=1,NLONG),J=1,MNLAT),K=1,NLEVELS)
      CLOSE(LUN)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INICON(XX,NO0,NO20,HNO30,PAN0,NO30,N2O50,
     &  ORGNIT0,O30,IPOS,CELLNO)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : INITIALIZE SPECIES CONCENTRATIONS
C-
C-   Inputs  : XX
C-   Outputs : XX
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  11-APR-1994   Bill Collins  Do copying to XX within subroutine.
C-   Updated  19-JUL-1994   Bill Collins  Added species used in David
C-                                        Stevensons's balance routines
C-   Updated  15-Dec-1994 David Stevenson Added lat fields for O3,CO,CH4
C-                                        and other new values
C-   Updated  14-Mar-1995 David Stevenson Corrected NOx initialisation
C-   Updated   2-JUN-1995 Colin Johnson   New species list.
C-   Updated  29-JUN-1995 Colin Johnson   Pre-industrial conditions.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5,NCELL),L
      REAL XX(NC,NCELL)
      REAL O3_PPB(MNLAT,NLEV),CO_PPB(MNLAT),CH4_PPB(MNLAT)
      REAL MET_PPT(MNLAT)
      DOUBLE PRECISION
     & O1D         ,O           ,OH          , NO2         ,
     & NO3         , O3          ,N2O5        ,NO          ,
     & HO2         ,H2          , CO          , H2O2        ,
     & HONO        , HNO3        , HO2NO2      , SO2         ,
     & SO3         , HSO3        , NAER        , SA          ,
     & CH4         , CH3O2       , C2H6        , C2H5O2      ,
     & C3H8        , IC3H7O2     , RN10O2      , NC4H10      ,
     & RN13O2      , C2H4        , HOCH2CH2O2  , C3H6        ,
     & RN9O2       , TBUT2ENE    , RN12O2      , NRN6O2      ,
     & NRN9O2      , NRN12O2     , HCHO        , HCOOH       ,
     & CH3CO2H     , CH3CHO      , C5H8        , RU14O2      ,
     & NRU14O2     , UCARB10     , APINENE     , RTN28O2     ,
     & NRTN28O2    , RTN26O2     , TNCARB26    , RCOOH25    ,
     & BPINENE     , RTX28O2     , NRTX28O2    , RTX24O2     ,
     & TXCARB24    , TXCARB22    , C2H2        , CARB3       ,
     & BENZENE     , RA13O2      , AROH14      , TOLUENE     ,
     & RA16O2      , AROH17      , OXYL        , RA19AO2     ,
     & RA19CO2     , CH3CO3      , C2H5CHO     , C2H5CO3     ,
     & CH3COCH3    , RN8O2       , RN11O2      , CH3OH       ,
     & C2H5OH      , NPROPOL     , IPROPOL     , CH3CL       ,
     & CH2CL2      , CHCL3       , CH3CCL3     , TCE         ,
     & TRICLETH    , CDICLETH    , TDICLETH    , CARB11A     ,
     & RN16O2      , RN15AO2     , RN19O2      , RN18AO2     ,
     & RN13AO2     , RN16AO2     , RN15O2      , UDCARB8     ,
     & UDCARB11    , CARB6       , UDCARB14    , CARB9       ,
     & MEK        ,
     & HOCH2CHO    , RN18O2      , CARB13      , CARB16      ,
     & HOCH2CO3    , RN14O2      , RN17O2      , UCARB12     ,
     & RU12O2      , CARB7       , RU10O2      , NUCARB12    ,
     & NRU12O2     , NOA         , RTN25O2     , RTN24O2     ,
     & RTN23O2     , RTN14O2     , TNCARB10    , RTN10O2     ,
     & RTX22O2     , CH3NO3      , C2H5NO3     , RN10NO3     ,
     & IC3H7NO3    , RN13NO3     , RN16NO3     , RN19NO3     ,
     & HOC2H4NO3   , RN9NO3      , RN12NO3     , RN15NO3     ,
     & RN18NO3     , RU14NO3     , RA13NO3     , RA16NO3     ,
     & RA19NO3     , RTN28NO3    , RTN25NO3    , RTX28NO3    ,
     & RTX24NO3    , RTX22NO3    , CH3OOH      , C2H5OOH     ,
     & RN10OOH     , IC3H7OOH    , RN13OOH     , RN16OOH     ,
     & RN19OOH     , RA13OOH     , RA16OOH    ,
     & RA19OOH     , HOC2H4OOH   , RN9OOH      , RN12OOH     ,
     & RN15OOH     , RN18OOH     , CH3CO3H     , C2H5CO3H    ,
     & HOCH2CO3H   , RN8OOH      , RN11OOH     , RN14OOH     ,
     & RN17OOH     , RU14OOH     , RU12OOH     , RU10OOH     ,
     & NRN6OOH     , NRN9OOH     , NRN12OOH    , NRU14OOH    ,
     & NRU12OOH    , RTN28OOH    , NRTN28OOH   , RTN26OOH    ,
     & RTN25OOH    , RTN24OOH    , RTN23OOH    , RTN14OOH    ,
     & RTN10OOH    , RTX28OOH    , RTX24OOH    , RTX22OOH    ,
     & NRTX28OOH   , CARB14      , CARB17      , CARB10      ,
     & CARB12      , CARB15      , CCARB12     , ANHY        ,
     & TNCARB15    , RAROH14     , ARNOH14     , RAROH17     ,
     & ARNOH17     , PAN         , PPN         , PHAN        ,
     & RU12PAN     , MPAN        , RTN26PAN    , P2604       ,
     & P4608       , P2631       , P2635       , P4610       ,
     & P2605       , P2630       , P2629       , P2632       ,
     & P2637       , P3612       , P3613       , P3442       ,
     & CH3O2NO2    , EMPOA       , P2007       , DMS         ,
     & DMSO        , CH3SO       , CH3SO2      , CH3SO3      ,
     & MSIA        , MSA         , CH3BR       , NH3         ,
     & AMMSUL      , SCIE        , SCIPA       , SCIPS       ,
     & SCIMAA      , SCIMAS      , SCIMVA      , SCIMVS      ,
     & SCIPAA      , SCIPAS      , SCIIPA      , SCIIPS      ,
     & SCIBPA      , SCIBPS      , SCIMGA      , SCIMGS      ,
     & SCIGAA      , SCIGAS	     , FTOH	       , PFOA        ,
     & APHOC2H4O   , BPRU14OOH   , APRU14OOH   , C1RU12OOH   ,
     & ISRU12OOH   , BPRU12OOH   , BPRU10OOH   , APRU10OOH   ,
     & BPNRU14OO   , APNRU14OO   , C1NRU12OO   , ISNRU12OO   ,
     & BPNRU12OO   , ISRTN28OO   , BPRTN28OO   , APRTN28OO   ,
     & ISRTN26OO   , BPRTN26OO   , APRTN26OO   , BPRTN25OO   ,
     & APRTN25OO   , ISRTN24OO   , BPRTN24OO   , APRTN24OO   ,
     & C1RTN23OO   , ISRTN23OO   , BPRTN23OO   , ISNRTN28O   ,
     & BPNRTN28O   , APNRTN28O   , APRN8OOH    , ISRTX28OO   ,
     & BPRTX28OO   , APRTX28OO   , BPRTX24OO   , APRTX24OO   ,
     & ISRTX22OO   , BPRTX22OO   , APRTX22OO   , ISNRTX28O   ,
     & BPNRTX28O   , APNRTX28O   , C1RTN14OO   , ISRTN14OO   ,
     & BPRTN14OO   , APRTN14OO   , APRTN10OO   , P1001       ,
     & P1002       , P1003       , P1004       , P1005       ,
     & P1006       , P1007       , P1008       , P1009       ,
     & P1010       , P1011       , P1012       , P1013       ,
     & P1014       , P1015       , P1016       , P1017       ,
     & P1018       , P1019       , P1020       , P1021       ,
     & P1022       , P1023       , P1024       , P1025       ,
     & P1026       , P1027       , P1028       , P1029       ,
     & P1030       , P1031       , P1032       , P1033       ,
     & P1034       , P1035       , P1036       , P1037       ,
     & P1038       , P1039       , P1040       , P1041       ,
     & P1042       , P1043       , P1044       , P1045       ,
     & P1046       , P1047 
      COMMON
     & O1D         ,O           ,OH          , NO2         ,
     & NO3         , O3          ,N2O5        ,NO          ,
     & HO2         ,H2          , CO          , H2O2        ,
     & HONO        , HNO3        , HO2NO2      , SO2         ,
     & SO3         , HSO3        , NAER        , SA          ,
     & CH4         , CH3O2       , C2H6        , C2H5O2      ,
     & C3H8        , IC3H7O2     , RN10O2      , NC4H10      ,
     & RN13O2      , C2H4        , HOCH2CH2O2  , C3H6        ,
     & RN9O2       , TBUT2ENE    , RN12O2      , NRN6O2      ,
     & NRN9O2      , NRN12O2     , HCHO        , HCOOH       ,
     & CH3CO2H     , CH3CHO      , C5H8        , RU14O2      ,
     & NRU14O2     , UCARB10     , APINENE     , RTN28O2     ,
     & NRTN28O2    , RTN26O2     , TNCARB26    , RCOOH25    ,
     & BPINENE     , RTX28O2     , NRTX28O2    , RTX24O2     ,
     & TXCARB24    , TXCARB22    , C2H2        , CARB3       ,
     & BENZENE     , RA13O2      , AROH14      , TOLUENE     ,
     & RA16O2      , AROH17      , OXYL        , RA19AO2     ,
     & RA19CO2     , CH3CO3      , C2H5CHO     , C2H5CO3     ,
     & CH3COCH3    , RN8O2       , RN11O2      , CH3OH       ,
     & C2H5OH      , NPROPOL     , IPROPOL     , CH3CL       ,
     & CH2CL2      , CHCL3       , CH3CCL3     , TCE         ,
     & TRICLETH    , CDICLETH    , TDICLETH    , CARB11A     ,
     & RN16O2      , RN15AO2     , RN19O2      , RN18AO2     ,
     & RN13AO2     , RN16AO2     , RN15O2      , UDCARB8     ,
     & UDCARB11    , CARB6       , UDCARB14    , CARB9       ,
     & MEK        ,
     & HOCH2CHO    , RN18O2      , CARB13      , CARB16      ,
     & HOCH2CO3    , RN14O2      , RN17O2      , UCARB12     ,
     & RU12O2      , CARB7       , RU10O2      , NUCARB12    ,
     & NRU12O2     , NOA         , RTN25O2     , RTN24O2     ,
     & RTN23O2     , RTN14O2     , TNCARB10    , RTN10O2     ,
     & RTX22O2     , CH3NO3      , C2H5NO3     , RN10NO3     ,
     & IC3H7NO3    , RN13NO3     , RN16NO3     , RN19NO3     ,
     & HOC2H4NO3   , RN9NO3      , RN12NO3     , RN15NO3     ,
     & RN18NO3     , RU14NO3     , RA13NO3     , RA16NO3     ,
     & RA19NO3     , RTN28NO3    , RTN25NO3    , RTX28NO3    ,
     & RTX24NO3    , RTX22NO3    , CH3OOH      , C2H5OOH     ,
     & RN10OOH     , IC3H7OOH    , RN13OOH     , RN16OOH     ,
     & RN19OOH     , RA13OOH     , RA16OOH    ,
     & RA19OOH     , HOC2H4OOH   , RN9OOH      , RN12OOH     ,
     & RN15OOH     , RN18OOH     , CH3CO3H     , C2H5CO3H    ,
     & HOCH2CO3H   , RN8OOH      , RN11OOH     , RN14OOH     ,
     & RN17OOH     , RU14OOH     , RU12OOH     , RU10OOH     ,
     & NRN6OOH     , NRN9OOH     , NRN12OOH    , NRU14OOH    ,
     & NRU12OOH    , RTN28OOH    , NRTN28OOH   , RTN26OOH    ,
     & RTN25OOH    , RTN24OOH    , RTN23OOH    , RTN14OOH    ,
     & RTN10OOH    , RTX28OOH    , RTX24OOH    , RTX22OOH    ,
     & NRTX28OOH   , CARB14      , CARB17      , CARB10      ,
     & CARB12      , CARB15      , CCARB12     , ANHY        ,
     & TNCARB15    , RAROH14     , ARNOH14     , RAROH17     ,
     & ARNOH17     , PAN         , PPN         , PHAN        ,
     & RU12PAN     , MPAN        , RTN26PAN    , P2604       ,
     & P4608       , P2631       , P2635       , P4610       ,
     & P2605       , P2630       , P2629       , P2632       ,
     & P2637       , P3612       , P3613       , P3442       ,
     & CH3O2NO2    , EMPOA       , P2007       , DMS         ,
     & DMSO        , CH3SO       , CH3SO2      , CH3SO3      ,
     & MSIA        , MSA	 , CH3BR       , NH3         ,
     & AMMSUL      , SCIE        , SCIPA       , SCIPS       ,
     & SCIMAA      , SCIMAS      , SCIMVA      , SCIMVS      ,
     & SCIPAA      , SCIPAS      , SCIIPA      , SCIIPS      ,
     & SCIBPA      , SCIBPS      , SCIMGA      , SCIMGS      ,
     & SCIGAA      , SCIGAS	     , FTOH	       , PFOA        ,
     & APHOC2H4O   , BPRU14OOH   , APRU14OOH   , C1RU12OOH   ,
     & ISRU12OOH   , BPRU12OOH   , BPRU10OOH   , APRU10OOH   ,
     & BPNRU14OO   , APNRU14OO   , C1NRU12OO   , ISNRU12OO   ,
     & BPNRU12OO   , ISRTN28OO   , BPRTN28OO   , APRTN28OO   ,
     & ISRTN26OO   , BPRTN26OO   , APRTN26OO   , BPRTN25OO   ,
     & APRTN25OO   , ISRTN24OO   , BPRTN24OO   , APRTN24OO   ,
     & C1RTN23OO   , ISRTN23OO   , BPRTN23OO   , ISNRTN28O   ,
     & BPNRTN28O   , APNRTN28O   , APRN8OOH    , ISRTX28OO   ,
     & BPRTX28OO   , APRTX28OO   , BPRTX24OO   , APRTX24OO   ,
     & ISRTX22OO   , BPRTX22OO   , APRTX22OO   , ISNRTX28O   ,
     & BPNRTX28O   , APNRTX28O   , C1RTN14OO   , ISRTN14OO   ,
     & BPRTN14OO   , APRTN14OO   , APRTN10OO   , P1001       ,
     & P1002       , P1003       , P1004       , P1005       ,
     & P1006       , P1007       , P1008       , P1009       ,
     & P1010       , P1011       , P1012       , P1013       ,
     & P1014       , P1015       , P1016       , P1017       ,
     & P1018       , P1019       , P1020       , P1021       ,
     & P1022       , P1023       , P1024       , P1025       ,
     & P1026       , P1027       , P1028       , P1029       ,
     & P1030       , P1031       , P1032       , P1033       ,
     & P1034       , P1035       , P1036       , P1037       ,
     & P1038       , P1039       , P1040       , P1041       ,
     & P1042       , P1043       , P1044       , P1045       ,
     & P1046       , P1047       
C
      DOUBLE PRECISION CP(NC)
      EQUIVALENCE (O1D,CP(1))
      INTEGER I,J,K,CELLNO(NFOLLOW),N
      REAL NO0,NO20,HNO30,PAN0,NO30,N2O50,ORGNIT0
      REAL O30(NFOLLOW)
C       Present day conditions for July (s5_1M, run 86):
      DATA ((O3_PPB(I,J),I=1,MNLAT),J=1,NLEV) / 
     &              2*25.0, 2*26.0, 2*28.0, 2*29.0, 2*35.0, 2*40.0,
     &              2*35.0, 2*30.0, 2*25.0, 2*22.0, 2*20.0, 2*18.0,
     &              2*18.0, 2*18.0, 2*20.0, 2*20.0, 2*20.0, 2*20.0,
     &              2*55.0, 2*52.0, 2*50.0, 2*45.0, 2*50.0, 2*50.0,
     &              2*40.0, 2*30.0, 2*25.0, 2*22.0, 2*22.0, 2*22.0,
     &              2*21.0, 2*20.0, 2*20.0, 2*21.0, 2*25.0, 2*25.0,
     &              2*62.0, 2*60.0, 2*58.0, 2*60.0, 2*60.0, 2*55.0,
     &              2*48.0, 2*34.0, 2*28.0, 2*25.0, 2*25.0, 2*25.0,
     &              2*25.0, 2*24.0, 2*23.0, 2*25.0, 2*28.0, 2*28.0,
     &              2*68.0, 2*66.0, 2*62.0, 2*65.0, 2*67.0, 2*60.0,
     &              2*50.0, 2*38.0, 2*28.0, 2*26.0, 2*27.0, 2*27.0,
     &              2*27.0, 2*26.0, 2*26.0, 2*28.0, 2*32.0, 2*32.0,
     &              2*80.0, 2*80.0, 2*70.0, 2*70.0, 2*75.0, 2*66.0,
     &              2*55.0, 2*40.0, 2*29.0, 2*29.0, 2*32.0, 2*32.0,
     &              2*30.0, 2*28.0, 2*28.0, 2*27.0, 2*32.0, 2*36.0,
     &              2*90.0, 2*88.0, 2*80.0, 2*82.0, 2*86.0, 2*75.0,
     &              2*60.0, 2*40.0, 2*30.0, 2*30.0, 2*38.0, 2*42.0,
     &              2*40.0, 2*36.0, 2*34.0, 2*30.0, 2*46.0, 2*50.0,
     &             2*110.0,2*108.0,2*100.0,2*100.0,2*104.0, 2*80.0,
     &              2*76.0, 2*56.0, 2*30.0, 2*38.0, 2*52.0, 2*64.0,
     &              2*62.0, 2*50.0, 2*48.0, 2*38.0, 2*50.0, 2*58.0,
     &             2*150.0,2*150.0,2*140.0,2*130.0,2*120.0,2*100.0,
     &              2*76.0, 2*48.0, 2*42.0, 2*45.0, 2*70.0, 2*90.0,
     &              2*86.0, 2*76.0, 2*70.0, 2*82.0, 2*80.0, 2*80.0,
     &             2*200.0,2*200.0,2*180.0,2*180.0,2*160.0,2*120.0,
     &             2*100.0, 2*80.0, 2*60.0, 2*60.0, 2*80.0,2*140.0,
     &             2*180.0,2*180.0,2*180.0,2*180.0,2*180.0,2*180.0 /
      DATA CO_PPB  / 2*125.,2*125.,2*125.,2*126.,2*127.,2*113.,2*92.,
     &               2*75.,2*264.,2*59.,2*49.,2*46.,2*45.,2*45.,2*45.,
     &               2*46.,2*46.,2*46./
      DATA CH4_PPB / 2*1803.,2*1807.,2*1795.,2*1793.,2*1784.,2*1769.,
     &               2*1750.,2*1727.,2*1700.,2*1688.,2*1672.,2*1670.,
     &               2*1668.,2*1668.,2*1667.,2*1667.,2*1666.,2*1666./
      DATA MET_PPT / 2*8.0,2*8.0,2*8.0,2*8.0,2*8.2,2*8.3,
     &               2*8.5,2*8.5,2*9.0,2*9.0,2*9.2,2*9.2,
     &               2*9.7,2*9.7,2*10.2,2*10.2,2*10.5,2*10.5/
C
C      INITIALISE CONCENTRATIONS OF TROPOSPHERIC GASES
C      (VOLUMETRIC MIXING RATIO UNITS)
C
C
      DO 31 I=1,NC
        CP(I)=4.0D-18
   31 CONTINUE
      SO2=4.0D-13
      CH3CHO=4.0D-13
      O1D=4.0D-23
      H2=5.62D-07
      NO=7.5D-12
      NO2=22.5D-12
      HNO3=300.0D-12
      C2H6=734.0D-12
      NC4H10=80.0D-12
      C2H4=59.0D-12
      C3H6=12.0D-12
      HCHO=0.2D-9
      OXYL=4.0D-30
      EMPOA=1.0D-12

C COPY CONCENTRATIONS TO LAGRANGIAN CELLS
      DO J=1,NCELL
        DO K=1,NC
          XX(K,J)=CP(K)
        ENDDO
      ENDDO

      N=1
      DO L=1,NCELL
        J=IPOS(2,L)                        !lat band
        K=IPOS(5,L)                        !height band
        XX(6,L)=O3_PPB(J,K)*1.0E-9          !O3
        XX(11,L) =CO_PPB(J)*1.0E-9          !CO
        XX(21,L) =CH4_PPB(J)*1.0E-9         !CH4
        XX(227,L)=MET_PPT(J)*1.0E-12        !CH3BR
        IF(L.EQ.CELLNO(N))THEN
          O30(N)=XX(6,L)
          IF(N.LT.NFOLLOW)N=N+1
        ENDIF
      ENDDO
C
C  Initial mixing ratios for balance species
C
      NO0=NO
      NO20=NO2
      HNO30=HNO3
      PAN0=PAN
      NO30=NO3
      N2O50=N2O5
c      ORGNIT0=ORGNIT
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INIGRI(LONG,LONGM,LONGM2,LAT,LATM,LATM2)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : SET UP GRIDS
C-
C-   Inputs  :
C-   Outputs : LONG,LONGM,LAT,LATM
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL LONG(NLONG), LAT(NLAT), LONGM(NMETLONG),
     &    LATM(NMETLAT),LONGM2(NMETLONG),LATM2(NMETLAT)
      INTEGER I,J
C      SET UP EULERIAN GRID BOUNDARIES:
C         LONGITUDE: 0-360, W-E
C         LATITUDE: 0-180, N-S
C
C
      DO 20 I=1,NLONG
        LONG(I)=DLONG*REAL(I-1)
   20 CONTINUE
C
      DO 21 I=1,NMETLONG
        LONGM(I)=DLONGM*REAL(I-1)
        LONGM2(I)=DLONGM*REAL(I-1)+(DLONGM/2.0)
   21 CONTINUE
C
      DO 22 J=1,NLAT
        LAT(J)=DLAT*REAL(J-1)
   22 CONTINUE
C
      DO 23 J=1,NMETLAT
        LATM(J)=DLATM*REAL(J-1)
        LATM2(J)=DLATM*REAL(J-1)+(DLATM/2.0)
   23 CONTINUE

  999 RETURN
      END
C#######################################################################
      SUBROUTINE INIPOS(POS,NNN,LAT)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : SET UP INITIAL CELL POSITIONS
C-
C-   Inputs  : LAT
C-   Outputs : POS
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   updated   2-oct-1995   d.s.         Randomised initial distribution
C-   Modified  6-AUG-1996   C.E. Johnson  To give exact number of cells.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   C.E. J.      Exact number of cells given.
C-                                       - no longer pass MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NNN(NLONG,MNLAT,NLEV),MCELL
      REAL POS(3,NCELL)
      REAL XT,MFRACT(MNLAT,NLEV),LAT(NLAT),RAD
      REAL XGRID,RANDNUM
      REAL Q,R,S,DETA
      INTEGER I,J,K,K0,L,N,MLEV(NLEV),NN(MNLAT,NLEV),SEED
      RAD=PI/180.0
C      SET INITIAL POSITIONS OF LAGRANGIAN CELLS
C      1. CALCULATE NO. OF CELLS IN EACH BAND
C
      DATA SEED/123321/
      N=0
      XT=0

      DO J=1,NLEV
        MLEV(J)=0
      ENDDO

      DO J=1,MNLAT
        DO K=1,NLEV
          MFRACT(J,K)=
     &      (SIN((LAT(J+1)-90.0)*RAD)-SIN((LAT(J)-90.0)*RAD))*
     &      (ETA3(K)-ETA3(K+1))/(2*(ETA3(1)-ETA3(NLEV+1)))
          NN(J,K)=NINT(NCELL*MFRACT(J,K))
          N=N+NN(J,K)
          XT=XT+MFRACT(J,K)
          MLEV(K)=MLEV(K)+NN(J,K)
        ENDDO
      ENDDO
      WRITE(6,*) ' *** INIPOS: N = ',N

C      Add in extra cells into random positions:

      K0=N
      IF(K0.LT.NCELL) THEN
        WRITE(6,*) ' *** INIPOS: K0 < NCELL ! K0=',K0
        DO I=K0+1,NCELL
          J=NINT(RANDNUM(SEED)*MNLAT)
          IF(J.EQ.0) J=1
          K=NINT(RANDNUM(SEED)*NLEV)
          IF(K.EQ.0) K=1
          NN(J,K)=NN(J,K)+1
          MLEV(K)=MLEV(K)+1
          N=N+1
        ENDDO
      ELSEIF(K0.GT.NCELL) THEN
        WRITE(6,*) ' *** INIPOS: K0 > NCELL ! K0=',K0
        DO I=NCELL+1,K0
          J=NINT(RANDNUM(SEED)*MNLAT)
          IF(J.EQ.0) J=1
          K=NINT(RANDNUM(SEED)*NLEV)
          IF(K.EQ.0) K=1
          NN(J,K)=NN(J,K)-1
          MLEV(K)=MLEV(K)-1
          N=N-1
        ENDDO
      ENDIF
      MCELL=N
      IF(MCELL.NE.NCELL) WRITE(6,*) '******MCELL,NCELL=',MCELL,NCELL
C
C      WRITE OUT INITIAL CONDITIONS AND ALLOCATION TABLES
C
      WRITE(7,230) N,XT,MLEV,((NN(J,K),J=1,MNLAT),K=NLEV,1,-1)
C
C      2. PLACE CELLS IN CENTRE OF EULERIAN GRID SQUARES
C
C     +3. Perturb cells position to obtain random distribution
C         ds 2-oct-1995
C
      L=0
      N=1
      DO 44 J=1,MNLAT
        DO 42 K=1,NLEV
          DETA=ETA3(K)-ETA3(K+1)
          DO 43 I=1,NLONG
            NNN(I,J,K)=0
   43     CONTINUE
          IF (NN(J,K).GT.0) THEN
            XGRID=360.0/NN(J,K)
            NN(J,K)=NN(J,K)+L
            DO 41 WHILE (N.LE.NN(J,K))
            Q=RANDNUM(SEED)-0.5            !random no. between -0.5 and 0.5
            R=RANDNUM(SEED)-0.5            !random no. between -0.5 and 0.5
            S=RANDNUM(SEED)-0.5            !random no. between -0.5 and 0.5
            POS(1,N)=XGRID*(REAL(N-L) + Q)              !add random bit
            IF (POS(1,N).GE.360.0) POS(1,N)=POS(1,N)-360.0
            I=INT(POS(1,N)*NLONG/360.)+1
            POS(2,N)=(LAT(J)+LAT(J+1))/2.0 + R*DLAT     !add random bit
            IF (POS(2,N).GT.180.0) POS(2,N)=360.-POS(2,N)
            IF (POS(2,N).LT.0.0)   POS(2,N)=-POS(2,N)
            POS(3,N)=(ETA3(K)+ETA3(K+1))/2.0 + S*DETA   !add random bit
            IF (POS(3,N).GT.1.0)   POS(3,N)=2.-POS(3,N)
            IF (POS(3,N).LT.0.0)   POS(3,N)=-POS(3,N)
            N=N+1
            NNN(I,J,K)=NNN(I,J,K)+1
   41     CONTINUE
          L=NN(J,K)
        ENDIF
   42 CONTINUE
   44 CONTINUE
  230 FORMAT('TOTAL NO. CELLS: ', I6, ' TOTAL FRACTION: ', F7.3/
     *' ALLOCATION OF CELLS IN EACH LEVEL: ',9I6/
     *' ALLOCATION OF CELLS IN 2-D:'/9(2(18I4/)/)//)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE TEMP(POS,LONGM,LATM,T,TL)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Return temperature of cell
C-
C-   Inputs  : POS,LONGM,LATM,T
C-   Outputs : TL
C-   Controls:
C-
C-   Created  11-APR-1994   Bill Collins
C-   Updated  10-JUL-1996   Bill Collins  No S.D.s in 6 hourly data
C-   Updated   6-AUG-1996   Bill Collins  Parameters in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  Removed 0 latitude circle in T and I4
C-                                        in INTERP
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL POS(3),INTERP,T7
      REAL TL,LONGM(NMETLONG),LATM(NMETLAT)
      REAL T(NMETLONG,NMETLAT,NMETLEV)
      INTEGER K,I3,L4,HEIGHT
      REAL D1,D2,D3

C        CALCULATE  CELL  INDICES FOR TEMPERATURE INTERPOLATION
C
      I3=INT(POS(1)/DLONGM+1.0)
      L4=INT(POS(2)/DLATM+1.0)
      K=HEIGHT(POS(3),ETA2)
C
      D1=POS(1)-LONGM(I3)
      D2=POS(2)-LATM(L4)
      IF(K.GT.0) THEN
        D3=ETA2(K)-POS(3)
      ELSE ! If below bottom eta level, use value for bottom eta level
        D3=0.
        K=1.
      ENDIF
      T7=INTERP(T,D1,D2,D3,I3,L4,K,2)
      TL=T7
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE WATER(POS,LONGM,LATM,Q,CLW,QL,LIQ)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Return water content of cell (mixing ratio)
C-
C-   Inputs  : POS,LONGM,LATM,Q,CLW
C-   Outputs : QL,LIQ
C-   Controls:
C-
C-   Created  15-JUL-1996   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  Removed 0 latitude circle in T and I4
C-                                        in INTERP
C-   Updated   8-JAN-1997   Bill Collins  Added cloud liquid water
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL POS(3),LINTERP,Q7,LIQ7
      REAL QL,LONGM(NMETLONG),LATM(NMETLAT),LIQ
      REAL Q(NMETLONG,NMETLAT,NMETLEV),CLW(NMETLONG,NMETLAT,NMETLEV)
      INTEGER K,I3,L4,HEIGHT,I,I2,J,J2
      REAL D1,D2,D3,DETA
C        CALCULATE  CELL  INDICES FOR HUMIDITY INTERPOLATION
C
      I3=INT(POS(1)/DLONGM+1.0)
      L4=INT(POS(2)/DLATM+1.0)
      K=HEIGHT(POS(3),ETA2)
C
      D1=POS(1)-LONGM(I3)
      D2=POS(2)-LATM(L4)
      IF(K.GT.0) THEN
        D3=ETA2(K)-POS(3)
        DETA=ETA2(K)-ETA2(K+1)
      ELSE ! If below bottom eta level, use value for bottom eta level
        D3=0.
        DETA=1.
        K=1.
      ENDIF
      Q7=LINTERP(Q,DETA,D1,D2,D3,I3,L4,K)
      LIQ7=LINTERP(CLW,DETA,D1,D2,D3,I3,L4,K)
      QL=Q7*MAIR/MH2O ! convert g/G to mixing ratio
      LIQ=LIQ7        ! convert g/G to
C
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION INTERP(X,D1,D2,D3,I,L,K,IETA)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : DO 3D INTERPOLATIONS
C-
C-   Returned value  : X7
C-   Inputs  : X,D1,D2,D3,I,L,K
C-   Outputs :
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated  30-JAN-1997  Colin Johnson Cubic interpolation in vertical.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL X1,X2,X3
      REAL D1,D2,D3,Z
      INTEGER I,J,J2,L,K,I2,IETA
      REAL X(NMETLONG,NMETLAT,NMETLEV)
      REAL XX(4,4),XR(4),EX1(4)

      I2=MOD(I,NMETLONG)+1
C      Set up the four sets of profiles for interpolation.
C      Repeat the bottom or top if needed.
      DO J = 1,4
        J2=K-2+J
        IF(J2.LT.1) J2=K                       ! set to lowest available
        IF(J2.GT.NMETLEV) J2=NMETLEV           ! set to highest available
        XX(J,1)=X(I,L,J2)
        XX(J,2)=X(I,L+1,J2)
        XX(J,3)=X(I2,L,J2)
        XX(J,4)=X(I2,L+1,J2)
      ENDDO
C      Do the cubic interpolation in vertical direction.
      IF(IETA.EQ.1) THEN
        Z=ETA1(K)-D3
        DO J = 1,4
          J2=K-2+J
          IF(J2.LT.1) J2=K                       ! set to lowest available
          IF(J2.GT.NMETLEV) J2=NMETLEV           ! set to highest available
          EX1(J)=ETA1(J2)
        ENDDO
      ELSE
        Z=ETA2(K)-D3
        DO J = 1,4
          J2=K-2+J
          IF(J2.LT.1) J2=K                       ! set to lowest available
          IF(J2.GT.NMETLEV) J2=NMETLEV           ! set to highest available
          EX1(J)=ETA2(J2)
        ENDDO
      ENDIF
        DO J = 1,4
          CALL CUBFIT(EX1,XX(1,J),Z,XR(J))
        ENDDO
C      Do linear interpolation in horizontal directions.
      X1=XR(1)+((XR(3)-XR(1))/DLONGM)*D1
      X2=XR(2)+((XR(2)-XR(4))/DLONGM)*D1
      X3=X1+((X2-X1)/DLATM)*D2
      INTERP=X3

  999 RETURN
      END
C#######################################################################
      REAL FUNCTION LINTERP(X,DETA,D1,D2,D3,I,L,K)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : DO 3D INTERPOLATIONS
C-
C-   Returned value  : X7
C-   Inputs  : X,DETA,D1,D2,D3,I,L,K
C-   Outputs :
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL X1,X2,X3,X4,X5,X6,X7
      REAL DETA,D1,D2,D3
      INTEGER I,L,K,I2
      REAL X(NMETLONG,NMETLAT,NMETLEV)
      I2=MOD(I,NMETLONG)+1
      X1=X(I,L,K)+((X(I2,L,K)-X(I,L,K))/DLONGM)*D1
      X2=X(I,L+1,K)+((X(I2,L+1,K)-X(I,L+1,K))/DLONGM)*D1
      X3=X(I,L,K+1)+((X(I2,L,K+1)-X(I,L,K+1))/DLONGM)*D1
      X4=X(I,L+1,K+1)+((X(I2,L+1,K+1)-X(I,L+1,K+1))/DLONGM)*D1
      X5=X1+((X2-X1)/DLATM)*D2
      X6=X3+((X4-X3)/DLATM)*D2
      X7=X5+((X6-X5)/DETA)*D3
      LINTERP=X7
  999 RETURN
      END
C#######################################################################
      SUBROUTINE RKO4(POS,U,VV,W,LONGM,LATM,LONGM2,LATM2,TIME,ASTEP,
     &                S,JCELL,ETABL,SEED)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :  To advect cells in the windfield.
C-
C-   Inputs  : POS,U,VV,W,JCELL,ETABL,TIME,ASTEP,S
C-   Outputs : POS
C-   Controls:
C-
C-   Created  30-SEP-1996   C.E. Johnson  Runge-Kutta solution, conversion of
C-                                        U,VV to degrees/s now in VELOC.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL POS(3),NPOS(3),V1(3),V2(3),V3(3),V4(3),V5(3),S(3)
      REAL U(NMETLONG,NMETLAT,NMETLEV,NHR+1),        ! U Component of Wind
     &     VV(NMETLONG,NMETLAT,NMETLEV,NHR+1),       ! V Component of Wind
     &     W(NMETLONG,NMETLAT,NMETLEV,NHR+1)         ! Etadot

      REAL ASTEP,HDIFF,VDIFF,HALF,SIXTH
      REAL ETABL,ETABLPLUS,RANDNUM
      REAL LONGM(NMETLONG),LATM(NMETLAT),LONGM2(NMETLONG),
     &  LATM2(NMETLAT)
      DOUBLE PRECISION TIME
      INTEGER I,J,SEED,JHOUR,JCELL
      LOGICAL COINCIDE

      HALF=ASTEP*0.5
      SIXTH=ASTEP/6.0
      IF(ABS(ASTEP-10800).GT.1.0) THEN
	PRINT *,' *** NEWPOS: TIME STEP NOT EQUAL THREE HOURS !!!'
	STOP
      ENDIF
C     IF(ETABL.LT.0.2) PRINT *,' *** NEWPOS: ETABL < 0.2, ETABL=',ETABL
      IF(POS(3).GE.ETABL) THEN                   ! In Boundary Layer
	VDIFF=7.0E-9
        HDIFF=5300.0
      ELSE
	VDIFF=7.0E-9
	HDIFF=5300.0/4.0
      ENDIF

      JHOUR=MOD(INT(0.6+(TIME-10800)/10800.),8)+1  ! The three hour period
      J=MOD(JHOUR/2,4)+1
      IF(MOD(JHOUR,2).EQ.0) THEN
        COINCIDE=.TRUE.                            ! Time coincides with data
      ELSE
        COINCIDE=.FALSE.                           ! Time not coincident
      ENDIF
      IF(JCELL.EQ.3108) THEN
C       WRITE(6,*) ' *** NEWPOS: JCELL = ',JCELL,' INITIAL'
C       WRITE(6,*) ' *** TIME  = ',TIME ,' JHOUR = ',JHOUR,' J = ',J,
C    &             ' COINCIDE = ',COINCIDE
C       WRITE(6,*) ' *** POS(1) = ',POS(1)
C       WRITE(6,*) ' *** POS(2) = ',POS(2)
C       WRITE(6,*) ' *** POS(3) = ',POS(3)
      ENDIF

C      IF(POS(3).LT.0.1.OR.POS(3).GT.1.0) THEN
C        WRITE(6,*) ' *** NEWPOS: STEP 0, JCELL = ',JCELL
C        WRITE(6,*) ' *** NEWPOS: POS(3) = ',POS(3)
C      ENDIF
C      1) Find winds at time,initial position and find new position at 
C         time+astep/2.
      IF(COINCIDE) THEN
        CALL VELOC(POS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J),
     &       VV(1,1,1,J),W(1,1,1,J),S,V1,ASTEP,HDIFF,VDIFF)
      ELSE
        CALL VELOC(POS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J),
     &       VV(1,1,1,J),W(1,1,1,J),S,V1,ASTEP,HDIFF,VDIFF)
        CALL VELOC(POS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J+1),
     &       VV(1,1,1,J+1),W(1,1,1,J+1),S,V2,ASTEP,HDIFF,VDIFF)
	DO I=1,3
	  V1(I)=(V1(I)+V2(I))/2.0
        ENDDO
      ENDIF
      DO I=1,3
	NPOS(I)=POS(I)+V1(I)*HALF
      ENDDO
      IF(JCELL.EQ.3108) THEN
C       WRITE(6,*) ' *** NEWPOS: JCELL = ',JCELL,' STEP 1'
C       WRITE(6,*) ' *** NPOS(1) = ',NPOS(1),' V1(1) = ',V1(1)
C       WRITE(6,*) ' *** NPOS(2) = ',NPOS(2),' V1(2) = ',V1(2)
C       WRITE(6,*) ' *** NPOS(3) = ',NPOS(3),' V1(3) = ',V1(3)
      ENDIF
C      IF(NPOS(3).LT.0.1.OR.NPOS(3).GT.1.0) THEN
C        WRITE(6,*) ' *** NEWPOS: STEP 1, JCELL = ',JCELL
C        WRITE(6,*) ' *** NEWPOS: NPOS(3) = ',NPOS(3),'V1(3) = ',V1(3)
C      ENDIF
      CALL REPOS(NPOS,JCELL,V1,ETABL)

C      2) Estimate velocities at time+astep/2, using position from step 1,
C         and use to find new position at time+astep/2.
      CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J),
     &     VV(1,1,1,J),W(1,1,1,J),S,V2,ASTEP,HDIFF,VDIFF)
      CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J+1),
     &     VV(1,1,1,J+1),W(1,1,1,J+1),S,V3,ASTEP,HDIFF,VDIFF)
      IF(COINCIDE) THEN
        DO I=1,3
          V2(I)=V2(I)+(V3(I)-V2(I))*0.25
          NPOS(I)=POS(I)+V2(I)*HALF
        ENDDO
      ELSE
        DO I=1,3
          V2(I)=V2(I)+(V3(I)-V2(I))*0.75
          NPOS(I)=POS(I)+V2(I)*HALF
        ENDDO
      ENDIF
C      IF(NPOS(3).LT.0.1.OR.NPOS(3).GT.1.0) THEN
C        WRITE(6,*) ' *** NEWPOS: STEP 2, JCELL = ',JCELL
C        WRITE(6,*) ' *** NEWPOS: NPOS(3) = ',NPOS(3),'V2(3) = ',V2(3)
C      ENDIF
      IF(JCELL.EQ.3108) THEN
C       WRITE(6,*) ' *** NEWPOS: JCELL = ',JCELL,' STEP 2'
C       WRITE(6,*) ' *** TIME  = ',TIME ,' JHOUR = ',JHOUR,' J = ',J,
C    &             ' COINCIDE = ',COINCIDE
C       WRITE(6,*) ' *** NPOS(1) = ',NPOS(1),' V2(1) = ',V2(1)
C       WRITE(6,*) ' *** NPOS(2) = ',NPOS(2),' V2(2) = ',V2(2)
C       WRITE(6,*) ' *** NPOS(3) = ',NPOS(3),' V2(3) = ',V2(3)
      ENDIF
      CALL REPOS(NPOS,JCELL,V2,ETABL)

C      3) Estimate velocities at time+astep/2 using position from step 2,
C         and use to estimate position at time+astep.
      CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J),
     &     VV(1,1,1,J),W(1,1,1,J),S,V3,ASTEP,HDIFF,VDIFF)
      CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J+1),
     &     VV(1,1,1,J+1),W(1,1,1,J+1),S,V4,ASTEP,HDIFF,VDIFF)
      IF(COINCIDE) THEN
        DO I=1,3
          V3(I)=V3(I)+(V4(I)-V3(I))*0.25
          NPOS(I)=POS(I)+V3(I)*ASTEP
        ENDDO
      ELSE
        DO I=1,3
          V3(I)=V3(I)+(V4(I)-V3(I))*0.75
          NPOS(I)=POS(I)+V3(I)*ASTEP
        ENDDO
      ENDIF
      IF(JCELL.EQ.3108) THEN
C       WRITE(6,*) ' *** NEWPOS: JCELL = ',JCELL,' STEP 3'
C       WRITE(6,*) ' *** TIME  = ',TIME ,' JHOUR = ',JHOUR,' J = ',J,
C    &             ' COINCIDE = ',COINCIDE
C       WRITE(6,*) ' *** NPOS(1) = ',NPOS(1),' V3(1) = ',V3(1)
C       WRITE(6,*) ' *** NPOS(2) = ',NPOS(2),' V3(2) = ',V3(2)
C       WRITE(6,*) ' *** NPOS(3) = ',NPOS(3),' V3(3) = ',V3(3)
      ENDIF
C      IF(NPOS(3).LT.0.1.OR.NPOS(3).GT.1.0) THEN
C        WRITE(6,*) ' *** NEWPOS: STEP 3, JCELL = ',JCELL
C        WRITE(6,*) ' *** NEWPOS: NPOS(3) = ',NPOS(3),'V3(3) = ',V3(3)
C      ENDIF
      CALL REPOS(NPOS,JCELL,V3,ETABL)

C      4) Estimate velocities at time+astep using position from step 3.
      IF(COINCIDE) THEN
        CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J),
     &       VV(1,1,1,J),W(1,1,1,J),S,V4,ASTEP,HDIFF,VDIFF)
        CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J+1),
     &       VV(1,1,1,J+1),W(1,1,1,J+1),S,V5,ASTEP,HDIFF,VDIFF)
	DO I=1,3
	  V4(I)=(V4(I)+V5(I))/2.0
        ENDDO
      ELSE
        CALL VELOC(NPOS,LONGM,LATM,LONGM2,LATM2,U(1,1,1,J+1),
     &       VV(1,1,1,J+1),W(1,1,1,J+1),S,V4,ASTEP,HDIFF,VDIFF)
      ENDIF

C      5) Estimate final position.
      POS(1)=POS(1)+SIXTH*(V1(1)+V4(1)+2.0*(V2(1)+V3(1)))
      POS(2)=POS(2)+SIXTH*(V1(2)+V4(2)+2.0*(V2(2)+V3(2)))
C      IF(POS(3).GE.1.0) PRINT *,' *** NEWPOS: POS(3),ETABL=',POS(3),
C     &                           ETABL
      IF(POS(3).GE.ETABL)THEN                !in boundary layer
C       ! random reassignment in bl+extra bit:
        ETABLPLUS = ETABL-0.55*(2*ASTEP*VDIFF)**0.5
C       IF(POS(3).EQ.1.0) PRINT *,'POS(3),ETABLPLUS=',POS(3),ETABLPLUS
        POS(3) = 1.0-RANDNUM(SEED)*(1.0-ETABLPLUS)       ! non-cray
c	CALL RANSET(SEED)                                ! cray
c        POS(3) = 1.0-RANF()*(1.0-ETABLPLUS)              ! cray
c        SEED=RANGET()                                    ! cray
C        IF(POS(3).GE.1.0) PRINT *,'POS(3),ETABLPLUS=',POS(3),ETABLPLUS
      ELSE
        POS(3)=POS(3)+SIXTH*(V1(3)+V4(3)+2.0*(V2(3)+V3(3)))
C       IF(POS(3).GE.1.0) PRINT *,' *** NEWPOS: POS(3),V2(3)=',
C     &                            POS(3),V2(3),ETABL
      ENDIF
C     IF(POS(3).GE.1.0.OR.POS(3).LT.0.07)
C    &  PRINT *,' *** NEWPOS: POS(3) >1.0 or <0.07 ! JCELL = ',
C    &          JCELL,' POS(3) = ',POS(3),' V3(3) = ',V3(3),
C    &          ' ETABL = ',ETABL
      CALL REPOS(POS,JCELL,V4,ETABL)

      IF(JCELL.EQ.3108) THEN
C       WRITE(6,*) ' *** NEWPOS: JCELL = ',JCELL,' FINAL'
C       WRITE(6,*) ' *** TIME  = ',TIME ,' JHOUR = ',JHOUR,' J = ',J,
C    &             ' COINCIDE = ',COINCIDE
C       WRITE(6,*) ' *** POS(1) = ',POS(1),' V4(1) = ',V4(1)
C       WRITE(6,*) ' *** POS(2) = ',POS(2),' V4(2) = ',V4(2)
C       WRITE(6,*) ' *** POS(3) = ',POS(3),' V4(3) = ',V4(3)
      ENDIF
  999 RETURN
      END
C ######################################################################
      SUBROUTINE REPOS(POS,JCELL,V,ETABL)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :   To reposition cells inside grid 
C-
C-   Inputs  : POS,JCELL,V,ETABL
C-   Outputs : POS
C-   Controls:
C-
C-   Created   3-OCT-1996   C.E. Johnson   From old NEWPOS
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL POS(3),V(3),ETABL
      INTEGER JCELL

C      IF(POS(3).GE.1.0.OR.POS(3).LT.0.07)
C     &  PRINT *,' *** REPOS: POS(3) >1.0 or <0.07 ! JCELL = ',
C     &          JCELL,' POS(3) = ',POS(3),' V(3) = ',V(3),
C     &          ' ETABL = ',ETABL

      IF (POS(1).LT.0.0) POS(1)=POS(1)+360.0
      IF (POS(1).GE.360.0) POS(1)=POS(1)-360.0
      IF (POS(1).GE.360.0.OR.POS(1).LT.0.0) THEN
        WRITE(6,*) ' *** REPOS: LONG > 360 or <0.0 !'
        WRITE(6,*) POS(1),POS(2),POS(3)
        WRITE(6,*) V(1),V(2),V(3)
        WRITE(6,*) 'Cell no.',JCELL
        POS(1) = AMOD(POS(1),360.0)
        IF(POS(1).LT.0.0)POS(1)=POS(1)+360.0
      ENDIF
      IF (POS(2).LT.0.0) THEN
        POS(2)=-POS(2)
        POS(1)=POS(1)+180
      ENDIF
      IF (POS(2).GT.180.0) THEN
        POS(2)=360.0-POS(2)
        POS(1)=POS(1)+180
      ENDIF
      IF (POS(1).GE.360.0) POS(1)=POS(1)-360.0

      IF(POS(1).GE.360.0.OR.POS(1).LT.0.0)
     &  PRINT *,' *** REPOS: POS(1) >=360 or <0 !!',POS(1),JCELL

      IF(POS(2).GE.180.0)THEN      !equal is possible
        POS(2)=179.9
      ENDIF
      IF(POS(2).LE.0.0)THEN        !equal is possible
        POS(2)=0.1
      ENDIF

      IF (POS(3).GT.1.0) POS(3)=ETA3(1)
C      IF (POS(3).LT.ETA3(NLEV+1)) POS(3)=2*ETA3(NLEV+1)-POS(3)
C      IF(POS(3).LT.ETA3(NLEV+1)) POS(3)=ETA3(NLEV+1)
C      Reset to middle of layer
      IF(POS(3).LT.ETA3(NLEV+1)) POS(3)=0.13
C

  999 RETURN
      END
C ######################################################################
      SUBROUTINE VELOC(POS,LONGM,LATM,LONGM2,LATM2,U,VV,W,S,V,ASTEP,
     &  HDIFF,VDIFF)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Return wind velocities for advection
C-
C-   Inputs  : POS,LONGM,LATM,LONGM2,LATM2,U,VV,W,S,
C-   Outputs : V
C-   Controls:
C-
C-   Created  11-APR-1994   Bill Collins
C-   Drifts and check for <1e-30 added 22 Sept 94 David Stevenson
C-   Updated  10-JUL-1996   Bill Collins  No S.D.s - use diffusion coeffs.
C-   Updated   6-AUG-1996   Bill Collins  Parameters in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  No longer have surface eta level for
C-                                        U,V,W. Moved I2 (I4) calculation to
C-                                        INTERP. Do interpolation over the
C-                                        poles explicitly.
C-   Updated  30-SEP-1996   C.E. Johnson  U,V output in degrees per second.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL POS(3),HDIFF,VDIFF
      REAL LONGM(NMETLONG),LATM(NMETLAT),LONGM2(NMETLONG),
     &  LATM2(NMETLAT)
      REAL
     &  U(NMETLONG,NMETLAT,NMETLEV),
     &  VV(NMETLONG,NMETLAT,NMETLEV),
     &  W(NMETLONG,NMETLAT,NMETLEV)
      INTEGER I,J,K,I3,I4,L,L4,K2,HEIGHT
      REAL WX(4,4),WR(4),W1,W2,Z    
      REAL D1,D2,D3,ASTEP,DPMY
      REAL U7,V7,W7,INTERP,V(3),S(3)
      REAL RAD

      RAD=PI/180.0
      DPMY=180.0/(RADIUS*1.0D03*PI)
C
C        CALCULATE INDICES FOR WIND INTERPOLATION
C        I, LONGITUDE ; L, LATITUDE ; K, ETA2 ; K2, ETA1
C
      I=INT(0.5+POS(1)/DLONGM)
      IF(I.EQ.0) I=NMETLONG
      L=INT(0.5+POS(2)/DLATM)
      K=HEIGHT(POS(3),ETA2)
      I3=INT(POS(1)/DLONGM+1.0)
      L4=INT(POS(2)/DLATM+1.0)
      K2=HEIGHT(POS(3),ETA1)
C
      D1=POS(1)-LONGM2(I)
      IF(D1.LT.-180.0) D1=D1+360
      IF(K.GT.0) THEN
        D3=ETA2(K)-POS(3)
      ELSE ! If below bottom eta level, use value for bottom eta level
        D3=0.
        K=1.
      ENDIF
C
C        INTERPOLATE WIND COMPONENTS FROM DATA, complicated when interpolating
C        over the poles.
C
      IF(L.EQ.0) THEN                  ! North Pole
        D2=POS(2)+0.5*DLATM
        U7=INTERP(U,D1,0.,D3,I,1,K,2)*(D2/(DLATM/2.)-1.) !=0 when pos(2)=0.
        V7=INTERP(VV,D1,0.,D3,I,1,K,2)*(D2/DLATM)
        I=MOD(I+NMETLONG/2-1,NMETLONG)+1  ! point other side of pole
        V7=V7+INTERP(VV,D1,0.,D3,I,1,K,2)*(1.-D2/DLATM)
      ELSEIF(L.EQ.NMETLAT-1) THEN        ! South Pole
        D2=180.-POS(2)+0.5*DLATM
        U7=INTERP(U,D1,0.,D3,I,NMETLAT-1,K,2)*(D2/(DLATM/2.)-1.)
        V7=INTERP(VV,D1,0.,D3,I,NMETLAT-1,K,2)*(D2/DLATM)
        I=MOD(I+NMETLONG/2-1,NMETLONG)+1  ! point other side of pole
        V7=V7+INTERP(VV,D1,0.,D3,I,NMETLAT-1,K,2)*(1.-D2/DLATM)
      ELSE
        D2=POS(2)-LATM2(L)
        U7=INTERP(U,D1,D2,D3,I,L,K,2)
        V7=INTERP(VV,D1,D2,D3,I,L,K,2)
      ENDIF

      D1=POS(1)-LONGM(I3)
      D2=POS(2)-LATM(L4)
      IF(K2.GT.0) THEN
        D3=ETA1(K2)-POS(3)
      ELSE ! If below bottom eta level, use value for bottom eta level
        D3=0.
        K2=1.
      ENDIF
      W7=INTERP(W,D1,D2,D3,I3,L4,K2,1)
C
C     Turn off diffusion near poles, convert to degrees per second.

      IF(POS(2).LE.DLATM.OR.POS(2).GE.180.-DLATM)THEN
        V(1)=U7*DPMY/COS((POS(2)-90.0)*RAD)
        V(2)=-V7*DPMY
        V(3)=W7
      ELSE
        V(1)=(U7+S(1)*(2.0*(1.0/ASTEP)*HDIFF)**0.5)*
     &                DPMY/COS((POS(2)-90.0)*RAD)
        V(2)=-(V7+S(2)*(2.0*(1.0/ASTEP)*HDIFF)**0.5)*DPMY
        V(3)=W7+S(3)*(2.0*(1.0/ASTEP)*VDIFF)**0.5
      ENDIF
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE EGET(ESTORE,EM,EMITD,EMISS,IPOS,POS,BL,NNN,NBL,
     &                MONTH,NO2EM,TIME,MISSING)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : GET EMISSIONS
C-
C-   Inputs  : EMISS,NNN
C-   Outputs : ESTORE,EM
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   1-Oct-1995   D.S.         H is cell height in metres,
C-                                       BL is b.layer height in metres.
C-   Modified 29-Jul-1996   C.E. Johnson To operate on nblock dimension arrays.
C-   Updated   6-AUG-1996   Bill Collins Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,KB,IM,JM,L,I2,MONTH,SECS,JB
      INTEGER NNN(NLONG,MNLAT,NLEV),IPOS(5,NBLOCK),NBL(NLONG,MNLAT)
      DOUBLE PRECISION TIME,TI
      REAL ESTORE(NC,NLONG,MNLAT),EMISS(NC,NLONG,MNLAT),
     &  EM(NBLOCK,NC),EMITD(NBLOCK,NC),H,BL(NMETLONG,NMETLAT),
     &  POS(3,NBLOCK),THET,ZEN
      REAL NO2EM(1,NLONG,MNLAT,NLEV),MISSING

C
C      Find cells in boundary layer to recieve emissions
C
C      PRINT *,'IPOS=',IPOS(1,1),IPOS(2,1),IPOS(5,1)
C      PRINT *,'POS=',POS(1,1),POS(2,1),POS(3,1)
C      PRINT *,'IPOS=',IPOS(1,2),IPOS(2,2),IPOS(5,2)
C      PRINT *,'POS=',POS(1,2),POS(2,2),POS(3,2)
C      PRINT *,'IPOS=',IPOS(1,3),IPOS(2,3),IPOS(5,3)
C      PRINT *,'POS=',POS(1,3),POS(2,3),POS(3,3)
      DO 300 KB=1,NBLOCK
        I=IPOS(1,KB)
        L=IPOS(2,KB)
        I2=IPOS(5,KB)
        IM=INT(POS(1,KB)/DLONGM+1.0)               ! Indicies for met grids
        JM=INT(POS(2,KB)/DLATM+1.0)
        DO 250 J=1,NC
          EM(KB,J)=0.
          IF (POS(3,KB).GE.BL(IM,JM).AND.J.NE.6.AND.J.NE.14) THEN
            IF(NBL(I,L).LE.0) THEN
              PRINT*,' *** EGET: NBL=0 !',' at I=',I,' L=',L,' KB =',KB
              PRINT*,' POS(3) = ',POS(3,KB), ' BL = ',BL(IM,JM)
            ENDIF
            EM(KB,J)=((EMISS(J,I,L)+ESTORE(J,I,L))/NBL(I,L))
            EMITD(KB,J)=EMITD(KB,J)+EM(KB,J)
          ENDIF
  250   CONTINUE
C        PRINT *,'KB=',KB
        IF(I2.GT.8)THEN                       ! put stratos o3/hno3 in level 9
          IF(NNN(I,L,9).LE.0) WRITE(6,*) ' *** EGET: NNN LE 0 ! I =',I,
     &          ' L = ',L,' I2 = ',I2,'NNN=',NNN(I,L,9)
          IF(NNN(I,L,9).LE.0) WRITE(6,*) ' IPOS: ',IPOS(1,KB),
     &      IPOS(2,KB),IPOS(5,KB)
          EM(KB,6)=(EMISS(6,I,L)+ESTORE(6,I,L))/NNN(I,L,9)
          EMITD(KB,6)=EMITD(KB,6)+EM(KB,6)
          EM(KB,14)=(EMISS(14,I,L)+ESTORE(14,I,L))/NNN(I,L,9)
          EMITD(KB,14)=EMITD(KB,14)+EM(KB,14)
        ENDIF
C Set diurnal variation of isoprene emissions.
C Get zenith angle for this time of day on 15th of the month
        TI=DBLE(SECS(15,MONTH,1))+DMOD(TIME,86400.D0)
        THET=ZEN(TI,90.-((L-.5)*180.)/MNLAT,((I-.5)*360.)/NLONG)
        IF(COS(THET).LT.0) THEN
          EM(KB,43)=0.                  ! set isoprene emissions to zero
        ELSE
          EM(KB,43)=EM(KB,43)*COS(THET)
        ENDIF
  300 CONTINUE
C
C      Add in 'NO2' emissions to NO.
      DO 400 JB=1,NBLOCK
        I=IPOS(1,JB)
        L=IPOS(2,JB)
        K=IPOS(5,JB)
        EM(JB,8)=EM(JB,8)+(MISSING*NO2EM(1,I,L,K)/NNN(I,L,K))
  400 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE DJCALC(DJ,DJA,IPOS,TIME,CTIME,ASTEP)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculates the photolysis rates DJ,
C-                         interpolated with time.
C-
C-   Inputs  : DJA,IPOS,JA
C-   Outputs : DJ
C-   Controls:
C-
C-   Created  8-AUG-1996   Colin Johnson
C-   Updated  13-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C-----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C-----------------------------------------------------------------------
      INTEGER JB
      REAL DJ(NBLOCK,NDJ),DJA(NDJ,NLEV,NLONG,MNLAT,4)
      REAL ASTEP
      INTEGER I,J,K,I1,L1,K1,IPOS(5,NBLOCK)
      DOUBLE PRECISION TIME,CTIME

      K=INT((CTIME-TIME)/(ASTEP/3.))+1
      IF(K.EQ.4) K=3                      ! to cope with end of step
      IF(K.GT.3.OR.K.LT.1) WRITE(6,*) ' *** DJCALC: K > 3 OR < 1 ',K
      DO I=1,NDJ
        DO JB=1,NBLOCK
          I1=IPOS(1,JB)
          L1=IPOS(2,JB)
          K1=IPOS(5,JB)
          DJ(JB,I)=DJA(I,K1,I1,L1,K)+(DJA(I,K1,I1,L1,K)-
     &          DJA(I,K1,I1,L1,K+1))*(CTIME-TIME)/ASTEP
          DJ(JB,I)=MAX(DJ(JB,I),1.0E-20)
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE DERIV(DD,DW,EM,DJA,TC,QL,LL,M,XX,FLUX,POS,IPOS,ASTEP,
     &  TIME,NOXBAL,O3BAL,CLINDX,CELLBUD,JA,SOA,MOM)
C-----------------------------------------------------------------------
C-    PURPOSE:    -  TO EVALUATE CONCENTRATIONS Y FROM RATE COEFFICIENTS,
C-                   J VALUES, DRY DEPOSITION AND EMISSION RATES.
C-                   DETAILED CHEMISTRY OF NC SPECIES: 102 THERMAL
C-                   THERMAL REACTIONS, NDJ PHOTOLYTIC.
C-
C-    INPUTS:     -  SPECIES CONCENTRATIONS (Y), RATE COEFFICIENTS (RC),
C-                   PHOTOLYSIS RATES (DJ),   EMISSIONS (EM), DRY DEPOSITION
C-                   RATES (DD), WET DEPOSITION RATES (DW),
C-                   AND PREVIOUS CONCENTRATIONS (YP).
C-
C-    OUTPUTS:    -  CONCENTRATIONS (Y), CHEMICAL FLUXES (FLUX)
C-
C-    CONTROLS:   -  NIT is number of iterations.
C-
C-    CREATED:    -  1-SEPT-1994   Colin Johnson
C-
C-    VER 2:      -  20-FEV-1995   Colin Johnson
C-                                 New chemical scheme with 50 species
C-                                 from chem3.txt mechanism.
C-    Updated     -   5-SEP-1995   Colin Johnson Added PAN photolysis.
C-    Updated     -  12-JAN-1996   Bill Collins MGLYOX photolysis produces
C-                                 acetyl peroxy and HO2 instead of CH3CHO.
C-    Updated     -  30-NOV-1995   Colin Johnson Added dry deposition to
C-                                 SA and ORGNIT, and wet depn. for ORGNIT.
C-    Updated     -  16-FEB-1996   Colin Johnson Added wet deposition rates
C-                                 explicitly: DW.
C-    Modified    -   1-AUG-1996   Colin Johnson Added block structure.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C                    11-OCT-1996   Dick Derwent O+NO2 added
C                                  N2O5+H2O deleted but NAER added
C                                  HO2+NO3 added
C                                  HO2NO2 & CH3OH added
C                                  acetone, peroxides and DMS added
C-----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C-----------------------------------------------------------------------
      INTEGER NIT,I,J,JA,JB,K,IPOS(5,NBLOCK)
      PARAMETER(NIT=8)
      REAL EM(NBLOCK,NC),DD(NBLOCK,NC),DW(NBLOCK,NC),DJ(NBLOCK,NDJ),
     &     RC(NBLOCK,NR),XX(NC,NBLOCK),ASTEP,KH(NBLOCK,5),KE(NBLOCK,6)
      REAL DJA(NDJ,NLEV,NLONG,MNLAT,4),LAQ(NBLOCK,10),FAQ(NBLOCK,5)
      REAL FLUX(NBLOCK,2200),POS(3,NBLOCK),LL(NBLOCK),N2(NBLOCK)
      REAL H2O(NBLOCK),O2(NBLOCK),M(NBLOCK),QL(NBLOCK),TC(NBLOCK)
      DOUBLE PRECISION Y(NBLOCK,NC),YP(NBLOCK,NC),DTS,TIME,CTIME,TMAX
      DOUBLE PRECISION P,L,L1,L2,L3,R1,R2,CTH2O2(NBLOCK),CTHNO3(NBLOCK),
     &  CTNH3(NBLOCK),SO4(NBLOCK),CS(NBLOCK,10),CP(NBLOCK,10),
     &  CPH2O2(NBLOCK),CTSO2(NBLOCK),CPSO2(NBLOCK),CPNH3(NBLOCK),
     & EMPOAMOL(NBLOCK,NC)
	DOUBLE PRECISION P01(NBLOCK), P02(NBLOCK),P03(NBLOCK),P04(NBLOCK)
	DOUBLE PRECISION P05(NBLOCK),P06(NBLOCK),P07(NBLOCK),P08(NBLOCK)
	DOUBLE PRECISION P09(NBLOCK),P10(NBLOCK),P11(NBLOCK),P12(NBLOCK)
	DOUBLE PRECISION P13(NBLOCK)
	DOUBLE PRECISION P01M(NBLOCK),P02M(NBLOCK),P03M(NBLOCK),
     & P04M(NBLOCK),P05M(NBLOCK),P06M(NBLOCK),P07M(NBLOCK),P08M(NBLOCK)
	DOUBLE PRECISION P09M(NBLOCK),P10M(NBLOCK),P11M(NBLOCK),
     & P12M(NBLOCK), P13M(NBLOCK)
      REAL NOXBAL(18,NFOLLOW),O3BAL(18,NFOLLOW),RO2(NBLOCK),SCI(NBLOCK),
     & ISP(NBLOCK),BPN(NBLOCK),APN(NBLOCK)
      INTEGER DOBAL,CLINDX
      REAL OD,OP,OH,NO,NO2,NO3,O3,HNO3,CH3O2,HO2,C2H5O2,PAN,SC4H9O2,
     &     C2H4,C3H6,CVF
      REAL NO3H,HSO3H,SO3H,OHH,NH4H,HP,REUS,PSTAR,BGOAM
      REAL SOA(NBLOCK),MOM(NBLOCK)
      LOGICAL CELLBUD
      DATA CVF/0.2/   ! Cloud volume fraction
      DATA PSTAR/101325./ ! Standard pressure (Pa)
      DATA BGOAM/0.7/  ! BACKGROUND AEROSOL MASS IN MICROG M-3
      DATA LAQ/NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0,
     &  NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0,NBLOCK*0.0/
C
C     ************************************************
C     ESTABLISH INITIAL CONDITIONS FOR BLOCK OF CELLS:
C     ************************************************
C
      DO 60 JB=1,NBLOCK                   ! No of cells in block
C     Set water vapour in molecules cm-3.
        H2O(JB)=QL(JB)*M(JB)
C     molecular oxygen set
        O2(JB)=0.2095*M(JB)
C     molecular NITROGEN set
        N2(JB)=0.7807*M(JB)
C      RO2(JB)=0.0
C     Pick up the concentrations from the previous chemistry
        DO 54 K=1,NC
          EM(JB,K)=EM(JB,K)*M(JB)
          YP(JB,K)=XX(K,JB)*M(JB)
          Y(JB,K)=YP(JB,K)

   54   CONTINUE
C
C  DEFINE TOTAL CONCENTRATION OF PEROXY RADICALS
C
       RO2(JB) =  Y(JB,22) + Y(JB,24)+ Y(JB,27) + Y(JB,26) + Y(JB,29)+
     & Y(JB,93) + Y(JB,94) + Y(JB,89) + Y(JB,91) 
     &+ Y(JB,31) + Y(JB,33) +
     & Y(JB,35) + Y(JB,95) + Y(JB,103) + Y(JB,90) + Y(JB,92) 
     &+ Y(JB,70) + Y(JB,72) + Y(JB,75) + Y(JB,107) + Y(JB,108) 
     &+ Y(JB,106) + Y(JB,44) + Y(JB,110) + Y(JB,112) + Y(JB,36) 
     &+ Y(JB,37) + Y(JB,38) + Y(JB,48) +
     & Y(JB,45) + Y(JB,114) + Y(JB,62) + Y(JB,65) 
     &+ Y(JB,68) + Y(JB,69) +
     & Y(JB,74) + Y(JB,50) + Y(JB,49) + Y(JB,116) + Y(JB,117) 
     &+ Y(JB,118) +
     & Y(JB,119) + Y(JB,121) + Y(JB,54) + Y(JB,56) + Y(JB,122) 
     &+ Y(JB,55)
C
       SCI(JB) =  Y(JB,230)+Y(JB,231)+Y(JB,232)+Y(JB,233)+
     & Y(JB,234)+Y(JB,235)+Y(JB,236)+Y(JB,237)+Y(JB,238)
     &+Y(JB,239)+Y(JB,240)+Y(JB,241)+Y(JB,242)+Y(JB,243)
     &+Y(JB,244)+Y(JB,245)+Y(JB,246)
C
       ISP(JB) =  Y(JB,233)+Y(JB,234)+Y(JB,235)+Y(JB,236)+
     & Y(JB,243) + Y(JB,244) + Y(JB,245) + Y(JB,246) 
       BPN(JB) =  (Y(JB,241)+Y(JB,242))*90
       APN(JB) =  Y(JB,237)+Y(JB,238)+Y(JB,239)+Y(JB,240)
C
C Mass of organic particulate material             
C -------------------------------------------------------------------
C     
	SOA(JB) = Y(JB,204)*3.574E-10 + Y(JB,205)*3.574E-10 + 
     & Y(JB,206)*3.059E-10 + Y(JB,207)*3.126E-10 + Y(JB,208)*3.093E-10 + 
     & Y(JB,209)*3.093E-10 + Y(JB,210)*3.325E-10 + Y(JB,211)*4.072E-10 + 
     & Y(JB,212)*2.860E-10 + Y(JB,213)*3.391E-10 + Y(JB,214)*2.310E-10 + 
     & Y(JB,215)*2.543E-10 + Y(JB,216)*1.628E-10 + Y(JB,219)*2.493E-10 +
     & Y(JB,296)*2.623E-10 + Y(JB,297)*2.733E-10 + Y(JB,298)*3.034E-10 +
     & Y(JB,299)*1.962E-10 + Y(JB,300)*2.372E-10 + Y(JB,301)*3.053E-10 +
     & Y(JB,302)*2.753E-10 + Y(JB,303)*3.053E-10 + Y(JB,304)*3.173E-10 +
     & Y(JB,305)*3.484E-10 + Y(JB,306)*2.490E-10 + Y(JB,307)*2.822E-10 +
     & Y(JB,308)*3.504E-10 + Y(JB,309)*2.733E-10 + Y(JB,310)*3.415E-10 +
     & Y(JB,311)*3.715E-10 + Y(JB,312)*2.873E-10 + Y(JB,313)*3.555E-10 +
     & Y(JB,314)*3.855E-10 + Y(JB,315)*3.274E-10 + Y(JB,316)*3.575E-10 +
     & Y(JB,317)*2.753E-10 + Y(JB,318)*3.434E-10 + Y(JB,319)*3.735E-10 +
     & Y(JB,320)*2.503E-10 + Y(JB,321)*2.913E-10 + Y(JB,322)*3.594E-10 +
     & Y(JB,323)*3.183E-10 + Y(JB,324)*3.865E-10 + Y(JB,325)*4.165E-10 +
     & Y(JB,326)*2.743E-10 + Y(JB,327)*2.733E-10 + Y(JB,328)*3.415E-10 +
     & Y(JB,329)*3.715E-10 + Y(JB,330)*3.244E-10 + Y(JB,331)*3.555E-10 +
     & Y(JB,332)*2.733E-10 + Y(JB,333)*3.414E-10 + Y(JB,334)*3.715E-10 +
     & Y(JB,335)*3.173E-10 + Y(JB,336)*3.865E-10 + Y(JB,337)*4.165E-10 +
     & Y(JB,338)*2.082E-10 + Y(JB,339)*2.492E-10 + Y(JB,340)*3.174E-10 +
     & Y(JB,341)*3.474E-10 + Y(JB,342)*3.313E-10
C
C    MOM IS CURRENTLY IN MOLECULES CM-3 
c    NEED TO CONVERT TO ug m-3
      MOM(JB) = SOA(JB) + Y(JB,218)*13.2*1.0D12/NA
C	WRITE(6,*)'MOM=', MOM(JB),JB
C     Set flux arrays to zero
        DO 56 I=1,2200
          FLUX(JB,I)=0.
   56   CONTINUE
C Set in-cloud concentrations
        CTH2O2(JB)=Y(JB,12)*1.0E3/NA
        CTHNO3(JB)=Y(JB,14)*1.0E3/NA
        CTSO2(JB)=Y(JB,16)*1.0E3/NA
        CTNH3(JB)=Y(JB,228)*1.0E3/NA
        IF(LL(JB).GT.1.E-20) THEN
          SO4(JB)=Y(JB,20)*1.0E3/(NA*LL(JB))
        ELSE
          SO4(JB)=0.
        ENDIF
C      Check for ozone depletion by dry deposition.
        IF(DD(JB,6)*ASTEP.GT.0.2) THEN
C          WRITE(6,*) 'Large ozone deposition corrected at position: ',
C     &      POS(1,JB),POS(2,JB),POS(3,JB),DD(JB,6)
          DD(JB,6) = 0.2/ASTEP
        ENDIF
C      Avoid ozone deposition if ozone < 1 ppb.
        IF(XX(6,JB).LT.1.0D-9) THEN
          DD(JB,6) = 0.0
C          WRITE(6,*) 'Ozone dry dep. set to zero at position: ',
C     &      POS(1,JB),POS(2,JB),POS(3,JB)
        ENDIF
C      Avoid ozone becoming too low.
        IF(XX(6,JB).LT.1.0D-20) THEN
          XX(6,JB)=1.0D-20
          YP(JB,6)=XX(6,JB)*M(JB)
          Y(JB,6)=YP(JB,6)
        ENDIF
   60 CONTINUE
C
C
C
C     WRITE(6,*) 'O3: ',O3,' HO2: ',HO2
C
C     ***************
C     INITIALIZATION:
C     ***************
C
C      Lagrangian time local starting time
      CTIME=TIME
C
C      Tmax local stop-time for integration
      TMAX=ASTEP+CTIME
C
C     -Calculate-Rate-Coeffs.-------------

c

c
      CALL CHEMCO(RC,TC,M,O2,H2O,N2,RO2,SCI,ISP,BPN,APN,MOM)
      CALL EQMCON(KE,KH,TC)
C     ------------------------------------
C
C     **************************************
C     Chemical time integration loop starts:
C     **************************************
C
C      debug concentrations for one cell.
CO     IF (J.EQ.CELLNO(CLINDX)) DOBAL=1
CD     IF(DOBAL.EQ.1)THEN
CD       WRITE(6,*) 'CHEMIS: AT ENTRY TO TIME INTEGRATION'
CD       WRITE(6,*) (CP(I),I=1,NC)
CD     ENDIF
CD     IF (EM(4).GT.1E-10) THEN
CD       WRITE(6,*) EM
CD     ENDIF
C
C        DTS is current chemistry step size.
C        Set DTS depending on CO emission.
CO        IF(EM(8).GT.1.0E-19) THEN
CO          DTS=100.0
CO        ELSE
CO          DTS=300.0
CO        ENDIF
      DTS=300.0                       !Set constant for now
      DO 400 WHILE (CTIME.LT.TMAX)
      CTIME=CTIME+DTS
C
C     -Update-photolysis-rates----------------------------------------
      CALL DJCALC(DJ,DJA,IPOS,TIME,CTIME,ASTEP)
c      write(61,*)'OP AND OD DJ',DJ(1,2),DJ(1,1)
C     ----------------------------------------------------------------
C
C     -Calculate-new-concentrations----------------------------------
C      debug concentrations for one cell.
CD     IF(DOBAL.EQ.1)THEN
CD       WRITE(6,*) 'DERIV: AT ENTRY, YP,DJ&RC'
CD       WRITE(6,*) 'YP: ',(YP(I),I=1,NC)
CD       WRITE(6,*) 'DJ: ',(DJ(I),I=1,NDJ)
CD       WRITE(6,*) 'RC: ',(RC(I),I=1,NR)
CD       WRITE(6,*) 'DD: ',(DD(I),I=1,NC)
CD       WRITE(6,*) 'EM: ',(EM(I),I=1,NC)
CD     ENDIF
C
      DO JB=1,NBLOCK
        CS(JB,10)=SO4(JB)
        CP(JB,10)=SO4(JB)
        CPH2O2(JB)=CTH2O2(JB)
        CPSO2(JB)=CTSO2(JB)
        CPNH3(JB)=CTNH3(JB)
      ENDDO
C       iteration start
      DO 1000 I=1,NIT
C
C       WRITE(6,*) ' ITERATION: ',I
C       WRITE(6,504) (CNAMES(J),J=1,6)
C       WRITE(6,503) (Y(J),J=1,6)
C       WRITE(6,504) (CNAMES(J),J=7,12)
C       WRITE(6,503) (Y(J),J=7,12)
C       WRITE(6,504) (CNAMES(J),J=13,NC)
C       WRITE(6,503) (Y(J),J=13,NC)
  503   FORMAT(1X,1P8E12.4)
  504   FORMAT(1X,8A12)
        DO 901 JB=1,NBLOCK
C        PRINT *,'JB=',JB
c
C
C          -----------------------
C          AQUEOUS PHASE REACTIONS
C          -----------------------
C
C      1) Obtain dissolved species concentrations in (mol/l):
C         H2O2, O3, HNO3, SO2, NH3 from equilibrium equations.

          IF(LL(JB).GT.1.E-20) THEN
            REUS=RGC*TC(JB)*1.0E6/(NA*PSTAR)
            CS(JB,1)=KH(JB,1)*Y(JB,6)*REUS                   ! O3    (Aq)
            CS(JB,2)=CTHNO3(JB)/(LL(JB)+PSTAR/
     &      (KH(JB,2)*RGC*TC(JB)*1.0E3))                    ! HNO3  (Aq)
            CS(JB,3)=CTH2O2(JB)/(LL(JB)+PSTAR/
     &      (KH(JB,3)*RGC*TC(JB)*1.0E3))                    ! H2O2  (Aq)
            CS(JB,4)=CTSO2(JB)/(LL(JB)+PSTAR/
     &      (KH(JB,4)*RGC*TC(JB)*1.0E3))                    ! SO2   (Aq)
            CS(JB,5)=CTNH3(JB)/(LL(JB)+PSTAR/
     &      (KH(JB,5)*RGC*TC(JB)*1.0E3))                    ! NH3   (Aq)


            NO3H=CS(JB,2)*KE(JB,1)
            HSO3H=CS(JB,4)*KE(JB,2)
            SO3H=HSO3H*KE(JB,3)
            OHH=(1000.0/18.0)*KE(JB,6)
            NH4H=CS(JB,5)*KE(JB,4)/OHH
            HP=(2.*CS(JB,10)+SQRT((4.*CS(JB,10))**2+4.*(1.+NH4H)*NO3H))/
     &      (2.*(1.0+NH4H))
c        HP  = 1.0
C          PH = -1.0*LOG10(HP)
c
C         CS(JB,6) = NO3H/HP                                ! NO3 (not required)
            CS(JB,7) = HSO3H/HP                             ! HSO3
            CS(JB,8) = SO3H/HP**2                           ! SO3
            CS(JB,9) = NH4H*HP                              ! NH4 (not required)

C      2) Calculate the production of SO4 and the loss of H2O2, and pass
C         these rates to the main model.

C      Fluxes:  (for budget printout)
C      FAQ(1) - SO2->SA (includes FAQ(2))
C      FAQ(2) - H2O2+SO2->SA
C      FAQ(3) - 2NH4+SO4->(NH4)2SO4
C      FAQ(4) - HSO3+O3->SO4
C      FAQ(5) - SO3+O3->SO4
C
C      Loss rates:
C      LAQ(6) - loss of in-cloud total NH3,
C      LAQ(7) - loss of in-cloud SO4,
C      LAQ(8) - loss of gaseous NH3,
C      LAQ(9) - loss of SA.
C      LAQ(10) - gain of Ammonium Sulphate.

            IF(CPNH3(JB).GT.1.0E-20.AND.CP(JB,10).GT.1.0E-20) THEN
              LAQ(JB,6) = 2.0*MIN(CS(JB,9),CS(JB,10))*LL(JB)
     &          /(DTS*CTNH3(JB))
              LAQ(JB,7) = MIN(CS(JB,9),CS(JB,10))/(DTS*CS(JB,10))
              LAQ(JB,8) = LAQ(JB,6)*CTNH3(JB)*NA*1.0D-3*CVF/Y(JB,228)
              LAQ(JB,9) = LAQ(JB,7)*CS(JB,10)*LL(JB)*NA*1.0D-3*CVF/Y(JB,
     &          20)
              LAQ(JB,10)= LAQ(JB,9)*Y(JB,20)
            ELSE
              LAQ(JB,6) = 0.0
              LAQ(JB,7) = 0.0
              LAQ(JB,8) = 0.0
              LAQ(JB,9) = 0.0
              LAQ(JB,10)= 0.0
            ENDIF
            FAQ(JB,3) = LAQ(JB,10)
c
c          SO4(Aq)         CS(10)
            P = CS(JB,7)*CS(JB,3)*RC(JB,527)*HP/(HP+0.1)
     &+CS(JB,7)*CS(JB,1)*RC(JB,528)  +CS(JB,8)*CS(JB,1)*RC(JB,529)
            L = 0.0 +LAQ(JB,7)+DW(JB,20)
            CS(JB,10) = (CP(JB,10)+DTS*P)/(1.0+DTS*L)
c
C      Loss rates:
C      LAQ(1) - loss of gaseous SO2,
C      LAQ(2) - gain of SA,
C      LAQ(3) - loss of in-cloud total H2O2,
C      LAQ(4) - loss of gaseous H2O2,
C      LAQ(5) - loss of in-cloud total SO2.

            LAQ(JB,2) = P*NA*LL(JB)*1.0D-3*CVF
            LAQ(JB,1) = LAQ(JB,2)/Y(JB,26)
            LAQ(JB,3) = LL(JB)*(CS(JB,7)*CS(JB,3)*RC(JB,527)*HP/
     &        (HP+0.1))/CTH2O2(JB)
            LAQ(JB,4) = LAQ(JB,3)*CTH2O2(JB)*NA*1.0D-3*CVF/Y(JB,12)
            LAQ(JB,5) = LL(JB)*P/CTSO2(JB)
            FAQ(JB,1) = LAQ(JB,2)
            FAQ(JB,2) = LAQ(JB,4)*Y(JB,12)
            FAQ(JB,4) = CS(JB,1)*CS(JB,7)*RC(JB,528)*LL(JB)
     &        *NA*1.0D-3*CVF
            FAQ(JB,5) = CS(JB,1)*CS(JB,8)*RC(JB,529)*LL(JB)
     &        *NA*1.0D-3*CVF
          ELSE
            DO K=1,10
              LAQ(JB,K)=0.
            ENDDO
            DO K=1,5
              FAQ(JB,K)=0.
            ENDDO
          ENDIF

C          Total cloud peroxide  CTH2O2
            P=0.0
            L=LAQ(JB,3)
            CTH2O2(JB) = (CPH2O2(JB)+DTS*P)/(1.0+DTS*L)

C          Total cloud SO2  CTSO2
            P=0.0
            L=LAQ(JB,5)
            CTSO2(JB) = (CPSO2(JB)+DTS*P)/(1.0+DTS*L)
c
C          Total cloud NH3  CTNH3
          P=0.0
          L=LAQ(JB,6)+DW(JB,228)
          CTNH3(JB) = (CPNH3(JB)+DTS*P)/(1.0+DTS*L)
c
C      This section written automatically by MECH3 from the file newmech.txt
C      with 169 equations.  Scheme from R.G. Derwent 26/XI/96
C
C      Hand edits: deleted RC(123) double losses on O3 & C3H6, also RC(112),
C                  RC(128),RC(129)
C                  NO3 & N2O5 solved simultaneously.
C                  CORRECTED: wrong product for RC(32)
C                  CORRECTED: additional product for RC(112)
C                  CORRECTED: DJ(12) instead of DJ(11) for GLYOX
C                  ADDED:     RC(256) as wet deposition of SA.
C                  CORRECTED: HNO3 from RC(209) and RC(211) deleted.
C                  ADDED:     PAN photolysis.
C                  ADDED:     DW rates explicitly, replaces RC(256) for aerosols
C                  CORRECTED: biacetyl removed for NAER as species 32
C                  ADDED:     HO2NO2 as species 51
C                  CORRECTED: Criegee biradical instead of RNOXYL
C
C          O1D              Y(JB,  1)
      P = 
     &+(DJ(JB,1)      *Y(JB,6  ))                                             
      L = 
     &+(RC(JB,7)      )       +(RC(JB,8) ) +(RC(JB,16)     *H2O(JB))      
      Y(JB,  1) = P/L
C
C          O                Y(JB,  2)
      P = 
     &+(DJ(JB,6)      *Y(JB,5  ))                                             
     &+(DJ(JB,2)      *Y(JB,6  ))       +(DJ(JB,4)      *Y(JB,4  ))                 
     &+(RC(JB,7)      *Y(JB,1  ))       +(RC(JB,8)      *Y(JB,1  ))          
      L = 
     &+(RC(JB,36)     *Y(JB,16 ))                                             
     &+(RC(JB,4)      *Y(JB,8  ))+(RC(JB,5)      *Y(JB,4  ))
     &+(RC(JB,6)      *Y(JB,4  ))   
     &+(RC(JB,1)      )       +(RC(JB,2) )+(RC(JB,3)      *Y(JB,6  ))   
      Y(JB,  2) = P/L
C
C          OH               Y(JB,  3)
      P = EM(JB,  3)
     &+(DJ(JB,95)     *Y(JB,184))       +(DJ(JB,96)     *Y(JB,185))                 
     &+(DJ(JB,93)     *Y(JB,182))       +(DJ(JB,94)     *Y(JB,183))                 
     &+(DJ(JB,91)     *Y(JB,180))       +(DJ(JB,92)     *Y(JB,181))                 
     &+(DJ(JB,89)     *Y(JB,178))       +(DJ(JB,90)     *Y(JB,179))                 
     &+(DJ(JB,87)     *Y(JB,176))       +(DJ(JB,88)     *Y(JB,177))                 
     &+(DJ(JB,85)     *Y(JB,174))       +(DJ(JB,86)     *Y(JB,175))                 
     &+(DJ(JB,83)     *Y(JB,152))       +(DJ(JB,84)     *Y(JB,153))                 
     &+(DJ(JB,81)     *Y(JB,171))       +(DJ(JB,82)     *Y(JB,151))                 
     &+(DJ(JB,79)     *Y(JB,169))       +(DJ(JB,80)     *Y(JB,170))                 
     &+(DJ(JB,77)     *Y(JB,157))       +(DJ(JB,78)     *Y(JB,158))                 
     &+(DJ(JB,75)     *Y(JB,155))       +(DJ(JB,76)     *Y(JB,156))                 
     &+(DJ(JB,73)     *Y(JB,173))       +(DJ(JB,74)     *Y(JB,154))                 
     &+(DJ(JB,71)     *Y(JB,168))       +(DJ(JB,72)     *Y(JB,172))                 
     &+(DJ(JB,69)     *Y(JB,166))       +(DJ(JB,70)     *Y(JB,167))                 
     &+(DJ(JB,67)     *Y(JB,165))       +(DJ(JB,68)     *Y(JB,166))                 
     &+(DJ(JB,65)     *Y(JB,163))       +(DJ(JB,66)     *Y(JB,164))                 
     &+(DJ(JB,63)     *Y(JB,161))       +(DJ(JB,64)     *Y(JB,162))                 
     &+(DJ(JB,61)     *Y(JB,159))       +(DJ(JB,62)     *Y(JB,160))                 
     &+(DJ(JB,59)     *Y(JB,149))       +(DJ(JB,60)     *Y(JB,150))                 
     &+(DJ(JB,57)     *Y(JB,148))       +(DJ(JB,58)     *Y(JB,148))                 
     &+(DJ(JB,55)     *Y(JB,146))       +(DJ(JB,56)     *Y(JB,147))                 
     &+(DJ(JB,53)     *Y(JB,144))       +(DJ(JB,54)     *Y(JB,145))                 
     &+(DJ(JB,7)      *Y(JB,13 ))       +(DJ(JB,8)      *Y(JB,14 ))                 
     &+(RC(JB,464)    *Y(JB,3  )*Y(JB,184))
     &+(DJ(JB,3)      *Y(JB,12 )*2.00)            
     &+(RC(JB,456)    *Y(JB,3  )*Y(JB,175))
     &+(RC(JB,463)    *Y(JB,3  )*Y(JB,183))          
     &+(RC(JB,453)    *Y(JB,3  )*Y(JB,153))
     &+(RC(JB,454)    *Y(JB,3  )*Y(JB,174))          
     &+(RC(JB,451)    *Y(JB,3  )*Y(JB,151))
     &+(RC(JB,452)    *Y(JB,3  )*Y(JB,152))          
     &+(RC(JB,449)    *Y(JB,3  )*Y(JB,170))
     &+(RC(JB,450)    *Y(JB,3  )*Y(JB,171))          
     &+(RC(JB,447)    *Y(JB,3  )*Y(JB,158))
     &+(RC(JB,448)    *Y(JB,3  )*Y(JB,169))          
     &+(RC(JB,445)    *Y(JB,3  )*Y(JB,156))
     &+(RC(JB,446)    *Y(JB,3  )*Y(JB,157))          
     &+(RC(JB,443)    *Y(JB,3  )*Y(JB,154))
     &+(RC(JB,444)    *Y(JB,3  )*Y(JB,155))          
     &+(RC(JB,441)    *Y(JB,3  )*Y(JB,172))
     &+(RC(JB,442)    *Y(JB,3  )*Y(JB,173))          
     &+(RC(JB,437)    *Y(JB,3  )*Y(JB,165))
     &+(RC(JB,438)    *Y(JB,3  )*Y(JB,166))          
     &+(RC(JB,435)    *Y(JB,3  )*Y(JB,163))
     &+(RC(JB,436)    *Y(JB,3  )*Y(JB,164))          
     &+(RC(JB,430)    *Y(JB,3  )*Y(JB,150))
     &+(RC(JB,434)    *Y(JB,3  )*Y(JB,162))          
     &+(RC(JB,428)    *Y(JB,3  )*Y(JB,148))
     &+(RC(JB,429)    *Y(JB,3  )*Y(JB,149))          
     &+(RC(JB,426)    *Y(JB,3  )*Y(JB,146))
     &+(RC(JB,427)    *Y(JB,3  )*Y(JB,147))          
     &+(RC(JB,424)    *Y(JB,3  )*Y(JB,144))
     &+(RC(JB,425)    *Y(JB,3  )*Y(JB,145))          
     &+(RC(JB,362)    *Y(JB,6  )*Y(JB,46 ))
     &+(RC(JB,374)    *Y(JB,6  )*Y(JB,109))          
     &+(RC(JB,75)     *Y(JB,59 )*Y(JB,3  ))          
     &+(RC(JB,61)     *Y(JB,6  )*Y(JB,43 ))
     &+(RC(JB,65)     *Y(JB,47 )*Y(JB,6  ))          
     &+(RC(JB,55)     *Y(JB,6  )*Y(JB,32 ))
     &+(RC(JB,57)     *Y(JB,6  )*Y(JB,34 ))          
     &+(RC(JB,33)     *Y(JB,9  )*Y(JB,5  ))
     &+(RC(JB,53)     *Y(JB,6  )*Y(JB,30 ))          
     &+(RC(JB,21)     *Y(JB,9  )*Y(JB,6  ))
     &+(RC(JB,29)     *Y(JB,9  )*Y(JB,8  ))          
     &+(RC(JB,16)     *Y(JB,1  )*H2O(JB)*2.00)  
     &+(RC(JB,534)*Y(JB,6)*Y(JB,43)) 
     &+(RC(JB,375)    *Y(JB,6  )*Y(JB,109))    
     &+(RC(JB,555)*Y(JB,232)*2.00)    
     &+(RC(JB,560)*Y(JB,235))+(RC(JB,561)*Y(JB,236))     
      L = 0.0
     &+(RC(JB,481)    *Y(JB,201))+(RC(JB,484)    *Y(JB,203))                        
     &+(RC(JB,474)    *Y(JB,199))+(RC(JB,475)    *Y(JB,200))
     &+(RC(JB,480)    *Y(JB,202))   
     &+(RC(JB,465)    *Y(JB,185))+(RC(JB,466)    *Y(JB,192))
     &+(RC(JB,473)    *Y(JB,198))   
     &+(RC(JB,462)    *Y(JB,182))+(RC(JB,463)    *Y(JB,183))
     &+(RC(JB,464)    *Y(JB,184))   
     &+(RC(JB,459)    *Y(JB,179))+(RC(JB,460)    *Y(JB,180))
     &+(RC(JB,461)    *Y(JB,181))   
     &+(RC(JB,456)    *Y(JB,175))+(RC(JB,457)    *Y(JB,177))
     &+(RC(JB,458)    *Y(JB,178))   
     &+(RC(JB,453)    *Y(JB,153))+(RC(JB,454)    *Y(JB,174))
     &+(RC(JB,455)    *Y(JB,176))   
     &+(RC(JB,450)    *Y(JB,171))+(RC(JB,451)    *Y(JB,151))
     &+(RC(JB,452)    *Y(JB,152))   
     &+(RC(JB,447)    *Y(JB,158))+(RC(JB,448)    *Y(JB,169))
     &+(RC(JB,449)    *Y(JB,170))   
     &+(RC(JB,444)    *Y(JB,155))+(RC(JB,445)    *Y(JB,156))
     &+(RC(JB,446)    *Y(JB,157))   
     &+(RC(JB,441)    *Y(JB,172))+(RC(JB,442)    *Y(JB,173))
     &+(RC(JB,443)    *Y(JB,154))   
     &+(RC(JB,438)    *Y(JB,166))+(RC(JB,439)    *Y(JB,167))
     &+(RC(JB,440)    *Y(JB,168))   
     &+(RC(JB,435)    *Y(JB,163))+(RC(JB,436)    *Y(JB,164))
     &+(RC(JB,437)    *Y(JB,165))   
     &+(RC(JB,432)    *Y(JB,160))+(RC(JB,433)    *Y(JB,161))
     &+(RC(JB,434)    *Y(JB,162))   
     &+(RC(JB,429)    *Y(JB,149))+(RC(JB,430)    *Y(JB,150))
     &+(RC(JB,431)    *Y(JB,159))   
     &+(RC(JB,426)    *Y(JB,146))+(RC(JB,427)    *Y(JB,147))
     &+(RC(JB,428)    *Y(JB,148))   
     &+(RC(JB,423)    *Y(JB,144))+(RC(JB,424)    *Y(JB,144))
     &+(RC(JB,425)    *Y(JB,145))   
     &+(RC(JB,416)    *Y(JB,195))+(RC(JB,418)    *Y(JB,66 ))
     &+(RC(JB,421)    *Y(JB,197))   
     &+(RC(JB,411)    *Y(JB,142))+(RC(JB,412)    *Y(JB,143))
     &+(RC(JB,413)    *Y(JB,63 ))   
     &+(RC(JB,408)    *Y(JB,139))+(RC(JB,409)    *Y(JB,140))
     &+(RC(JB,410)    *Y(JB,141))   
     &+(RC(JB,405)    *Y(JB,136))+(RC(JB,406)    *Y(JB,137))
     &+(RC(JB,407)    *Y(JB,138))   
     &+(RC(JB,402)    *Y(JB,133))+(RC(JB,403)    *Y(JB,134))
     &+(RC(JB,404)    *Y(JB,135))   
     &+(RC(JB,399)    *Y(JB,130))+(RC(JB,400)    *Y(JB,131))
     &+(RC(JB,401)    *Y(JB,132))   
     &+(RC(JB,396)    *Y(JB,127))+(RC(JB,397)    *Y(JB,128))
     &+(RC(JB,398)    *Y(JB,129))   
     &+(RC(JB,393)    *Y(JB,124))+(RC(JB,394)    *Y(JB,125))
     &+(RC(JB,395)    *Y(JB,126))   
     &+(RC(JB,390)    *Y(JB,57 ))+(RC(JB,391)    *Y(JB,58 ))
     &+(RC(JB,392)    *Y(JB,123))   
     &+(RC(JB,385)    *Y(JB,193))+(RC(JB,386)    *Y(JB,120))
     &+(RC(JB,389)    *Y(JB,52 ))   
     &+(RC(JB,382)    *Y(JB,99 ))+(RC(JB,383)    *Y(JB,99 ))
     &+(RC(JB,384)    *Y(JB,51 ))   
     &+(RC(JB,379)    *Y(JB,96 ))+(RC(JB,380)    *Y(JB,97 ))
     &+(RC(JB,381)    *Y(JB,97 ))   
     &+(RC(JB,376)    *Y(JB,113))+(RC(JB,377)    *Y(JB,115))
     &+(RC(JB,378)    *Y(JB,96 ))   
     &+(RC(JB,370)    *Y(JB,190))+(RC(JB,371)    *Y(JB,191))
     &+(RC(JB,372)    *Y(JB,109))   
     &+(RC(JB,367)    *Y(JB,98 ))+(RC(JB,368)    *Y(JB,100))
     &+(RC(JB,369)    *Y(JB,189))   
     &+(RC(JB,360)    *Y(JB,46 ))+(RC(JB,364)    *Y(JB,102))
     &+(RC(JB,366)    *Y(JB,60 ))   
     &+(RC(JB,357)    *Y(JB,188))+(RC(JB,358)    *Y(JB,104))
     &+(RC(JB,359)    *Y(JB,105))   
     &+(RC(JB,354)    *Y(JB,187))+(RC(JB,355)    *Y(JB,88 ))
     &+(RC(JB,356)    *Y(JB,111))   
     &+(RC(JB,105)    *Y(JB,86 ))+(RC(JB,106)    *Y(JB,87 ))
     &+(RC(JB,353)    *Y(JB,186))   
     &+(RC(JB,102)    *Y(JB,83 ))+(RC(JB,103)    *Y(JB,84 ))
     &+(RC(JB,104)    *Y(JB,85 ))   
     &+(RC(JB,99)     *Y(JB,80 ))+(RC(JB,100)    *Y(JB,81 ))
     &+(RC(JB,101)    *Y(JB,82 ))   
     &+(RC(JB,96)     *Y(JB,79 ))+(RC(JB,97)     *Y(JB,40 ))
     &+(RC(JB,98)     *Y(JB,41 ))   
     &+(RC(JB,93)     *Y(JB,78 ))+(RC(JB,94)     *Y(JB,78 ))
     &+(RC(JB,95)     *Y(JB,79 ))   
     &+(RC(JB,90)     *Y(JB,76 ))+(RC(JB,91)     *Y(JB,77 ))
     &+(RC(JB,92)     *Y(JB,77 ))   
     &+(RC(JB,84)     *Y(JB,71 ))+(RC(JB,88)     *Y(JB,73 ))
     &+(RC(JB,89)     *Y(JB,101))   
     &+(RC(JB,81)     *Y(JB,67 ))+(RC(JB,82)     *Y(JB,39 ))
     &+(RC(JB,83)     *Y(JB,42 ))   
     &+(RC(JB,78)     *Y(JB,64 ))+(RC(JB,79)     *Y(JB,64 ))
     &+(RC(JB,80)     *Y(JB,67 ))   
     &+(RC(JB,75)     *Y(JB,59 ))+(RC(JB,76)     *Y(JB,61 ))
     &+(RC(JB,77)     *Y(JB,61 ))   
     &+(RC(JB,63)     *Y(JB,47 ))+(RC(JB,68)     *Y(JB,53 ))
     &+(RC(JB,74)     *Y(JB,59 ))   
     &+(RC(JB,48)     *Y(JB,32 ))+(RC(JB,49)     *Y(JB,34 ))
     &+(RC(JB,59)     *Y(JB,43 ))   
     &+(RC(JB,45)     *Y(JB,25 ))+(RC(JB,46)     *Y(JB,28 ))
     &+(RC(JB,47)     *Y(JB,30 ))   
     &+(RC(JB,42)     *Y(JB,21 ))+(RC(JB,43)     *Y(JB,23 ))
     &+(RC(JB,44)     *Y(JB,25 ))   
     &+(RC(JB,34)     *Y(JB,13 ))+(RC(JB,35)     *Y(JB,14 ))
     &+(RC(JB,37)     *Y(JB,16 ))   
     &+(RC(JB,27)     *Y(JB,4  ))+(RC(JB,28)     *Y(JB,5  ))
     &+(RC(JB,32)     *Y(JB,15 ))   
     &+(RC(JB,20)     *Y(JB,12 ))+(RC(JB,22)     *Y(JB,9  ))
     &+(RC(JB,25)     *Y(JB,8  ))   
     &+(RC(JB,17)     *Y(JB,6  ))+(RC(JB,18)     *Y(JB,10 ))
     &+(RC(JB,19)     *Y(JB,11 ))
     &+(RC(JB,513)    *Y(JB,220))+(RC(JB,514)    *Y(JB,220))
     &+(RC(JB,516)    *Y(JB,221))
     &+(RC(JB,519)    *Y(JB,225))+(RC(JB,526)    *Y(JB,227))  
      Y(JB,  3) = P/L
C
C          NO2              Y(JB,  4)
      P = EM(JB,  4)
     &+(DJ(JB,86)     *Y(JB,175))       +(DJ(JB,96)     *Y(JB,185))                 
     &+(DJ(JB,80)     *Y(JB,170))       +(DJ(JB,81)     *Y(JB,171))                 
     &+(DJ(JB,52)     *Y(JB,142))       +(DJ(JB,79)     *Y(JB,169))                 
     &+(DJ(JB,50)     *Y(JB,137))       +(DJ(JB,51)     *Y(JB,138))                 
     &+(DJ(JB,48)     *Y(JB,129))       +(DJ(JB,49)     *Y(JB,136))                 
     &+(DJ(JB,46)     *Y(JB,127))       +(DJ(JB,47)     *Y(JB,128))                 
     &+(DJ(JB,44)     *Y(JB,126))       +(DJ(JB,45)     *Y(JB,127))                 
     &+(DJ(JB,42)     *Y(JB,124))       +(DJ(JB,43)     *Y(JB,125))                 
     &+(DJ(JB,32)     *Y(JB,115))       +(DJ(JB,41)     *Y(JB,123))                 
     &+(DJ(JB,8)      *Y(JB,14 ))       +(DJ(JB,31)     *Y(JB,115))                 
     &+(RC(JB,484)    *Y(JB,3  )*Y(JB,203))+(DJ(JB,6)      *Y(JB,5  ))                 
     &+(RC(JB,481)    *Y(JB,3  )*Y(JB,201))+(RC(JB,483)    *Y(JB,203))                 
     &+(RC(JB,479)    *Y(JB,202)) +(RC(JB,480) *Y(JB,3  )*Y(JB,202))          
     &+(RC(JB,475)    *Y(JB,3  )*Y(JB,200))+(RC(JB,477)    *Y(JB,201))                 
     &+(RC(JB,473)    *Y(JB,3  )*Y(JB,198))
     &+(RC(JB,474)    *Y(JB,3  )*Y(JB,199))          
     &+(RC(JB,470)    *Y(JB,199))       +(RC(JB,472)    *Y(JB,200))                 
     &+(RC(JB,456)    *Y(JB,3  )*Y(JB,175))
     &+(RC(JB,468)    *Y(JB,198))                 
     &+(RC(JB,449)    *Y(JB,3  )*Y(JB,170))
     &+(RC(JB,450)    *Y(JB,3  )*Y(JB,171))          
     &+(RC(JB,422)    *Y(JB,5  )*Y(JB,197))
     &+(RC(JB,448)    *Y(JB,3  )*Y(JB,169))          
     &+(RC(JB,417)    *Y(JB,5  )*Y(JB,195))
     &+(RC(JB,421)    *Y(JB,3  )*Y(JB,197))          
     &+(RC(JB,412)    *Y(JB,3  )*Y(JB,143))
     &+(RC(JB,416)    *Y(JB,3  )*Y(JB,195))          
     &+(RC(JB,410)    *Y(JB,3  )*Y(JB,141))
     &+(RC(JB,411)    *Y(JB,3  )*Y(JB,142))          
     &+(RC(JB,408)    *Y(JB,3  )*Y(JB,139))
     &+(RC(JB,409)    *Y(JB,3  )*Y(JB,140))          
     &+(RC(JB,406)    *Y(JB,3  )*Y(JB,137))
     &+(RC(JB,407)    *Y(JB,3  )*Y(JB,138))          
     &+(RC(JB,404)    *Y(JB,3  )*Y(JB,135))
     &+(RC(JB,405)    *Y(JB,3  )*Y(JB,136))          
     &+(RC(JB,402)    *Y(JB,3  )*Y(JB,133))
     &+(RC(JB,403)    *Y(JB,3  )*Y(JB,134))          
     &+(RC(JB,400)    *Y(JB,3  )*Y(JB,131))
     &+(RC(JB,401)    *Y(JB,3  )*Y(JB,132))          
     &+(RC(JB,398)    *Y(JB,3  )*Y(JB,129))
     &+(RC(JB,399)    *Y(JB,3  )*Y(JB,130))          
     &+(RC(JB,396)    *Y(JB,3  )*Y(JB,127))
     &+(RC(JB,397)    *Y(JB,3  )*Y(JB,128))          
     &+(RC(JB,394)    *Y(JB,3  )*Y(JB,125))
     &+(RC(JB,395)    *Y(JB,3  )*Y(JB,126))          
     &+(RC(JB,392)    *Y(JB,3  )*Y(JB,123))
     &+(RC(JB,393)    *Y(JB,3  )*Y(JB,124))          
     &+(RC(JB,352)    *Y(JB,55 ))       
     &+(RC(JB,377)    *Y(JB,3  )*Y(JB,115))          
     &+(RC(JB,338)    *Y(JB,38 ))       
     &+(RC(JB,342)    *Y(JB,49 ))                 
     &+(RC(JB,336)    *Y(JB,36 ))       
     &+(RC(JB,337)    *Y(JB,37 ))                 
     &+(RC(JB,242)    *Y(JB,122)*Y(JB,5  ))
     &+(RC(JB,243)    *Y(JB,55 )*Y(JB,5  )*2.00)     
     &+(RC(JB,240)    *Y(JB,54 )*Y(JB,5  ))
     &+(RC(JB,241)    *Y(JB,56 )*Y(JB,5  ))          
     &+(RC(JB,238)    *Y(JB,119)*Y(JB,5  ))
     &+(RC(JB,239)    *Y(JB,121)*Y(JB,5  ))          
     &+(RC(JB,236)    *Y(JB,117)*Y(JB,5  ))
     &+(RC(JB,237)    *Y(JB,118)*Y(JB,5  ))          
     &+(RC(JB,234)    *Y(JB,50 )*Y(JB,5  ))
     &+(RC(JB,235)    *Y(JB,116)*Y(JB,5  ))          
     &+(RC(JB,232)    *Y(JB,48 )*Y(JB,5  ))
     &+(RC(JB,233)    *Y(JB,49 )*Y(JB,5  )*2.00)     
     &+(RC(JB,230)    *Y(JB,45 )*Y(JB,5  ))
     &+(RC(JB,231)    *Y(JB,114)*Y(JB,5  ))          
     &+(RC(JB,229)    *Y(JB,38 )*Y(JB,5  )*2.00)                                 
     &+(RC(JB,228)    *Y(JB,37 )*Y(JB,5  )*2.00)                                 
     &+(RC(JB,226)    *Y(JB,112)*Y(JB,5  ))
     &+(RC(JB,227)    *Y(JB,36 )*Y(JB,5  )*2.00)     
     &+(RC(JB,224)    *Y(JB,112)*Y(JB,5  ))
     &+(RC(JB,225)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,222)    *Y(JB,110)*Y(JB,5  ))
     &+(RC(JB,223)    *Y(JB,110)*Y(JB,5  ))          
     &+(RC(JB,220)    *Y(JB,44 )*Y(JB,5  ))
     &+(RC(JB,221)    *Y(JB,44 )*Y(JB,5  ))          
     &+(RC(JB,218)    *Y(JB,107)*Y(JB,5  ))
     &+(RC(JB,219)    *Y(JB,108)*Y(JB,5  ))          
     &+(RC(JB,216)    *Y(JB,74 )*Y(JB,5  ))
     &+(RC(JB,217)    *Y(JB,75 )*Y(JB,5  ))          
     &+(RC(JB,214)    *Y(JB,72 )*Y(JB,5  ))
     &+(RC(JB,215)    *Y(JB,106)*Y(JB,5  ))          
     &+(RC(JB,212)    *Y(JB,92 )*Y(JB,5  ))
     &+(RC(JB,213)    *Y(JB,70 )*Y(JB,5  ))          
     &+(RC(JB,210)    *Y(JB,103)*Y(JB,5  ))
     &+(RC(JB,211)    *Y(JB,90 )*Y(JB,5  ))          
     &+(RC(JB,208)    *Y(JB,35 )*Y(JB,5  ))
     &+(RC(JB,209)    *Y(JB,95 )*Y(JB,5  ))          
     &+(RC(JB,206)    *Y(JB,31 )*Y(JB,5  ))
     &+(RC(JB,207)    *Y(JB,33 )*Y(JB,5  ))          
     &+(RC(JB,204)    *Y(JB,69 )*Y(JB,5  ))
     &+(RC(JB,205)    *Y(JB,31 )*Y(JB,5  ))          
     &+(RC(JB,202)    *Y(JB,65 )*Y(JB,5  ))
     &+(RC(JB,203)    *Y(JB,68 )*Y(JB,5  ))          
     &+(RC(JB,200)    *Y(JB,62 )*Y(JB,5  ))
     &+(RC(JB,201)    *Y(JB,65 )*Y(JB,5  ))          
     &+(RC(JB,198)    *Y(JB,93 )*Y(JB,5  ))
     &+(RC(JB,199)    *Y(JB,94 )*Y(JB,5  ))          
     &+(RC(JB,196)    *Y(JB,89 )*Y(JB,5  ))
     &+(RC(JB,197)    *Y(JB,91 )*Y(JB,5  ))          
     &+(RC(JB,194)    *Y(JB,29 )*Y(JB,5  ))
     &+(RC(JB,195)    *Y(JB,29 )*Y(JB,5  ))          
     &+(RC(JB,192)    *Y(JB,27 )*Y(JB,5  ))
     &+(RC(JB,193)    *Y(JB,26 )*Y(JB,5  ))          
     &+(RC(JB,190)    *Y(JB,22 )*Y(JB,5  ))
     &+(RC(JB,191)    *Y(JB,24 )*Y(JB,5  ))          
     &+(RC(JB,163)    *Y(JB,122)*Y(JB,8  ))
     &+(RC(JB,165)    *Y(JB,217))                 
     &+(RC(JB,161)    *Y(JB,56 )*Y(JB,8  ))
     &+(RC(JB,162)    *Y(JB,56 )*Y(JB,8  ))          
     &+(RC(JB,160)    *Y(JB,55 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,158)    *Y(JB,54 )*Y(JB,8  ))
     &+(RC(JB,159)    *Y(JB,54 )*Y(JB,8  ))          
     &+(RC(JB,156)    *Y(JB,119)*Y(JB,8  ))
     &+(RC(JB,157)    *Y(JB,121)*Y(JB,8  ))          
     &+(RC(JB,154)    *Y(JB,117)*Y(JB,8  ))
     &+(RC(JB,155)    *Y(JB,118)*Y(JB,8  ))          
     &+(RC(JB,152)    *Y(JB,50 )*Y(JB,8  ))
     &+(RC(JB,153)    *Y(JB,116)*Y(JB,8  ))          
     &+(RC(JB,151)    *Y(JB,49 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,149)    *Y(JB,48 )*Y(JB,8  ))
     &+(RC(JB,150)    *Y(JB,48 )*Y(JB,8  ))          
     &+(RC(JB,147)    *Y(JB,45 )*Y(JB,8  ))
     &+(RC(JB,148)    *Y(JB,114)*Y(JB,8  ))          
     &+(RC(JB,146)    *Y(JB,38 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,145)    *Y(JB,37 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,143)    *Y(JB,112)*Y(JB,8  ))
     &+(RC(JB,144)    *Y(JB,36 )*Y(JB,8  )*2.00)     
     &+(RC(JB,141)    *Y(JB,112)*Y(JB,8  ))
     &+(RC(JB,142)    *Y(JB,112)*Y(JB,8  ))          
     &+(RC(JB,139)    *Y(JB,110)*Y(JB,8  ))
     &+(RC(JB,140)    *Y(JB,110)*Y(JB,8  ))          
     &+(RC(JB,137)    *Y(JB,44 )*Y(JB,8  ))
     &+(RC(JB,138)    *Y(JB,44 )*Y(JB,8  ))          
     &+(RC(JB,135)    *Y(JB,107)*Y(JB,8  ))
     &+(RC(JB,136)    *Y(JB,108)*Y(JB,8  ))          
     &+(RC(JB,133)    *Y(JB,74 )*Y(JB,8  ))
     &+(RC(JB,134)    *Y(JB,75 )*Y(JB,8  ))          
     &+(RC(JB,131)    *Y(JB,72 )*Y(JB,8  ))
     &+(RC(JB,132)    *Y(JB,106)*Y(JB,8  ))          
     &+(RC(JB,129)    *Y(JB,92 )*Y(JB,8  ))
     &+(RC(JB,130)    *Y(JB,70 )*Y(JB,8  ))          
     &+(RC(JB,127)    *Y(JB,103)*Y(JB,8  ))
     &+(RC(JB,128)    *Y(JB,90 )*Y(JB,8  ))          
     &+(RC(JB,125)    *Y(JB,35 )*Y(JB,8  ))
     &+(RC(JB,126)    *Y(JB,95 )*Y(JB,8  ))          
     &+(RC(JB,123)    *Y(JB,31 )*Y(JB,8  ))
     &+(RC(JB,124)    *Y(JB,33 )*Y(JB,8  ))          
     &+(RC(JB,121)    *Y(JB,69 )*Y(JB,8  ))
     &+(RC(JB,122)    *Y(JB,31 )*Y(JB,8  ))          
     &+(RC(JB,119)    *Y(JB,65 )*Y(JB,8  ))
     &+(RC(JB,120)    *Y(JB,68 )*Y(JB,8  ))          
     &+(RC(JB,117)    *Y(JB,62 )*Y(JB,8  ))
     &+(RC(JB,118)    *Y(JB,65 )*Y(JB,8  ))          
     &+(RC(JB,115)    *Y(JB,93 )*Y(JB,8  ))
     &+(RC(JB,116)    *Y(JB,94 )*Y(JB,8  ))          
     &+(RC(JB,113)    *Y(JB,89 )*Y(JB,8  ))
     &+(RC(JB,114)    *Y(JB,91 )*Y(JB,8  ))          
     &+(RC(JB,111)    *Y(JB,29 )*Y(JB,8  ))
     &+(RC(JB,112)    *Y(JB,29 )*Y(JB,8  ))          
     &+(RC(JB,109)    *Y(JB,27 )*Y(JB,8  ))
     &+(RC(JB,110)    *Y(JB,26 )*Y(JB,8  ))          
     &+(RC(JB,107)    *Y(JB,22 )*Y(JB,8  ))
     &+(RC(JB,108)    *Y(JB,24 )*Y(JB,8  ))          
     &+(RC(JB,33)     *Y(JB,9  )*Y(JB,5  ))
     &+(RC(JB,34)     *Y(JB,3  )*Y(JB,13 ))          
     &+(RC(JB,31)     *Y(JB,15 ))       
     &+(RC(JB,32)     *Y(JB,3  )*Y(JB,15 ))          
     &+(RC(JB,28)     *Y(JB,3  )*Y(JB,5  ))
     &+(RC(JB,29)     *Y(JB,9  )*Y(JB,8  ))          
     &+(RC(JB,13)     *Y(JB,4  )*Y(JB,5  ))
     &+(RC(JB,15)     *Y(JB,7  ))                 
     &+(RC(JB,12)     *Y(JB,8  )*Y(JB,5  )*2.00)                                 
     &+(RC(JB,11)     *Y(JB,8  )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,4)      *Y(JB,2  )*Y(JB,8  ))
     &+(RC(JB,9)      *Y(JB,8  )*Y(JB,6  ))          
      L = DD(JB, 4)+DW(JB, 4)
     &+(RC(JB,478)    *Y(JB,112))+(RC(JB,482)    *Y(JB,50 ))
     &+(DJ(JB,4)      )          
     &+(RC(JB,469)    *Y(JB,72 ))+(RC(JB,471)    *Y(JB,106))
     &+(RC(JB,476)    *Y(JB,110))   
     &+(RC(JB,415)    *Y(JB,194))+(RC(JB,420)    *Y(JB,196))
     &+(RC(JB,467)    *Y(JB,70 ))   
     &+(RC(JB,27)     *Y(JB,3  ))+(RC(JB,30)     *Y(JB,9  ))
     &+(RC(JB,164)    *Y(JB,22 ))   
     &+(RC(JB,13)     *Y(JB,5  ))+(RC(JB,14)     *Y(JB,5  ))
     &+(RC(JB,26)     )          
     &+(RC(JB,5)      *Y(JB,2  ))+(RC(JB,6)      *Y(JB,2  ))
     &+(RC(JB,10)     *Y(JB,6  ))
     &+(RC(JB,518)    *Y(JB,222))+(RC(JB,521)    *Y(JB,223))	   
      Y(JB,  4) = (YP(JB,  4)+DTS*P)/(1.0+DTS*L)
C
C          NO3              Y(JB,  5)
      P = EM(JB,  5)
     &+(RC(JB,15)     *Y(JB,7  ))       
     &+(RC(JB,35)     *Y(JB,3  )*Y(JB,14 ))          
     &+(RC(JB,6)      *Y(JB,2  )*Y(JB,4  ))
     &+(RC(JB,10)     *Y(JB,4  )*Y(JB,6  ))          
      L = 0.0
     &+(DJ(JB,6)      )                                                    
     &+(RC(JB,419)    *Y(JB,66 ))+(RC(JB,422)    *Y(JB,197))
     &+(DJ(JB,5)      )          
     &+(RC(JB,388)    *Y(JB,120))+(RC(JB,414)    *Y(JB,63 ))
     &+(RC(JB,417)    *Y(JB,195))   
     &+(RC(JB,365)    *Y(JB,102))+(RC(JB,373)    *Y(JB,109))
     &+(RC(JB,387)    *Y(JB,51 ))   
     &+(RC(JB,242)    *Y(JB,122))+(RC(JB,243)    *Y(JB,55 ))
     &+(RC(JB,361)    *Y(JB,46 ))   
     &+(RC(JB,239)    *Y(JB,121))+(RC(JB,240)    *Y(JB,54 ))
     &+(RC(JB,241)    *Y(JB,56 ))   
     &+(RC(JB,236)    *Y(JB,117))+(RC(JB,237)    *Y(JB,118))
     &+(RC(JB,238)    *Y(JB,119))   
     &+(RC(JB,233)    *Y(JB,49 ))+(RC(JB,234)    *Y(JB,50 ))
     &+(RC(JB,235)    *Y(JB,116))   
     &+(RC(JB,230)    *Y(JB,45 ))+(RC(JB,231)    *Y(JB,114))
     &+(RC(JB,232)    *Y(JB,48 ))   
     &+(RC(JB,227)    *Y(JB,36 ))+(RC(JB,228)    *Y(JB,37 ))
     &+(RC(JB,229)    *Y(JB,38 ))   
     &+(RC(JB,224)    *Y(JB,112))+(RC(JB,225)    *Y(JB,112))
     &+(RC(JB,226)    *Y(JB,112))   
     &+(RC(JB,221)    *Y(JB,44 ))+(RC(JB,222)    *Y(JB,110))
     &+(RC(JB,223)    *Y(JB,110))   
     &+(RC(JB,218)    *Y(JB,107))+(RC(JB,219)    *Y(JB,108))
     &+(RC(JB,220)    *Y(JB,44 ))   
     &+(RC(JB,215)    *Y(JB,106))+(RC(JB,216)    *Y(JB,74 ))
     &+(RC(JB,217)    *Y(JB,75 ))   
     &+(RC(JB,212)    *Y(JB,92 ))+(RC(JB,213)    *Y(JB,70 ))
     &+(RC(JB,214)    *Y(JB,72 ))   
     &+(RC(JB,209)    *Y(JB,95 ))+(RC(JB,210)    *Y(JB,103))
     &+(RC(JB,211)    *Y(JB,90 ))   
     &+(RC(JB,206)    *Y(JB,31 ))+(RC(JB,207)    *Y(JB,33 ))
     &+(RC(JB,208)    *Y(JB,35 ))   
     &+(RC(JB,203)    *Y(JB,68 ))+(RC(JB,204)    *Y(JB,69 ))
     &+(RC(JB,205)    *Y(JB,31 ))   
     &+(RC(JB,200)    *Y(JB,62 ))+(RC(JB,201)    *Y(JB,65 ))
     &+(RC(JB,202)    *Y(JB,65 ))   
     &+(RC(JB,197)    *Y(JB,91 ))+(RC(JB,198)    *Y(JB,93 ))
     &+(RC(JB,199)    *Y(JB,94 ))   
     &+(RC(JB,194)    *Y(JB,29 ))+(RC(JB,195)    *Y(JB,29 ))
     &+(RC(JB,196)    *Y(JB,89 ))   
     &+(RC(JB,191)    *Y(JB,24 ))+(RC(JB,192)    *Y(JB,27 ))
     &+(RC(JB,193)    *Y(JB,26 ))   
     &+(RC(JB,86)     *Y(JB,42 ))+(RC(JB,87)     *Y(JB,71 ))
     &+(RC(JB,190)    *Y(JB,22 ))   
     &+(RC(JB,64)     *Y(JB,47 ))+(RC(JB,69)     *Y(JB,53 ))
     &+(RC(JB,85)     *Y(JB,39 ))   
     &+(RC(JB,51)     *Y(JB,32 ))+(RC(JB,52)     *Y(JB,34 ))
     &+(RC(JB,60)     *Y(JB,43 ))   
     &+(RC(JB,28)     *Y(JB,3  ))+(RC(JB,33)     *Y(JB,9  ))
     &+(RC(JB,50)     *Y(JB,30 ))   
     &+(RC(JB,12)     *Y(JB,8  ))+(RC(JB,13)     *Y(JB,4  ))
     &+(RC(JB,14)     *Y(JB,4  ))
     &+(RC(JB,515)    *Y(JB,220))	  
      Y(JB,  5) = (YP(JB,  5)+DTS*P)/(1.0+DTS*L)
C
C          O3               Y(JB,  6)
      P = EM(JB,  6)
     &+(RC(JB,1)      *Y(JB,2  ))       +(RC(JB,2)      *Y(JB,2  ))          
      L = DD(JB,6)+DW(JB,6) 
     &+(DJ(JB,1)      )       +(DJ(JB,2)      )                               
     &+(RC(JB,363)    *Y(JB,46 ))+(RC(JB,374)    *Y(JB,109))
     &+(RC(JB,375)    *Y(JB,109))   
     &+(RC(JB,72)     *Y(JB,53 ))+(RC(JB,73)     *Y(JB,53 ))
     &+(RC(JB,362)    *Y(JB,46 ))   
     &+(RC(JB,67)     *Y(JB,47 ))+(RC(JB,70)     *Y(JB,53 ))
     &+(RC(JB,71)     *Y(JB,53 ))   
     &+(RC(JB,62)     *Y(JB,43 ))+(RC(JB,65)     *Y(JB,47 ))
     &+(RC(JB,66)     *Y(JB,47 ))   
     &+(RC(JB,57)     *Y(JB,34 ))+(RC(JB,58)     *Y(JB,34 ))
     &+(RC(JB,61)     *Y(JB,43 ))   
     &+(RC(JB,54)     *Y(JB,30 ))+(RC(JB,55)     *Y(JB,32 ))
     &+(RC(JB,56)     *Y(JB,32 ))   
     &+(RC(JB,17)     *Y(JB,3  ))+(RC(JB,21)     *Y(JB,9  ))
     &+(RC(JB,53)     *Y(JB,30 ))   
     &+(RC(JB,3)      *Y(JB,2  ))+(RC(JB,9)      *Y(JB,8  ))
     &+(RC(JB,10)     *Y(JB,4  ))
     &+(RC(JB,517)    *Y(JB,222))+(RC(JB,520)    *Y(JB,223))  
     &+(RC(JB,530)*Y(JB,30))  +(RC(JB,531)*Y(JB,32))
     &+(RC(JB,532)*Y(JB,32))+(RC(JB,533)*Y(JB,34))
     &+(RC(JB,534)*Y(JB,43))+(RC(JB,535)*Y(JB,43))
     &+(RC(JB,536)*Y(JB,43))+(RC(JB,537)*Y(JB,43))
     &+(RC(JB,538)*Y(JB,43))+(RC(JB,539)*Y(JB,43))
     &+(RC(JB,540)*Y(JB,47))+(RC(JB,541)*Y(JB,47))
     &+(RC(JB,542)*Y(JB,47))+(RC(JB,543)*Y(JB,53))
     &+(RC(JB,544)*Y(JB,53))+(RC(JB,545)*Y(JB,46))
     &+(RC(JB,546)*Y(JB,46))+(RC(JB,547)*Y(JB,46))
     &+(RC(JB,548)*Y(JB,109))+(RC(JB,549)*Y(JB,109))
     &+(RC(JB,550)*Y(JB,46))+(RC(JB,551)*Y(JB,46))
      Y(JB,  6) = (YP(JB,  6)+DTS*P)/(1.0+DTS*L)
C
C          N2O5             Y(JB,  7)
      P = EM(JB,  7)
     &+(RC(JB,14)     *Y(JB,4  )*Y(JB,5  ))                                      
      L = DD(JB,7)+DW(JB, 7)
     &+(RC(JB,15)     )       +(RC(JB,40)     )                               
      Y(JB,  7) = (YP(JB,  7)+DTS*P)/(1.0+DTS*L)
C
C          NO               Y(JB,  8)
      P = EM(JB,  8)
     &+(DJ(JB,7)      *Y(JB,13 ))                                             
     &+(DJ(JB,4)      *Y(JB,4  ))       +(DJ(JB,5)      *Y(JB,5  ))                 
     &+(RC(JB,5)      *Y(JB,2  )*Y(JB,4  ))
     &+(RC(JB,13)     *Y(JB,4  )*Y(JB,5  ))
     &+(RC(JB,518)    *Y(JB,4  )*Y(JB,222))
     &+(RC(JB,521)    *Y(JB,4  )*Y(JB,223))	          
      L = 0.0
     &+(RC(JB,189)    *Y(JB,122))                                             
     &+(RC(JB,186)    *Y(JB,116))+(RC(JB,187)    *Y(JB,54 ))
     &+(RC(JB,188)    *Y(JB,56 ))   
     &+(RC(JB,183)    *Y(JB,68 ))+(RC(JB,184)    *Y(JB,69 ))
     &+(RC(JB,185)    *Y(JB,48 ))   
     &+(RC(JB,180)    *Y(JB,44 ))+(RC(JB,181)    *Y(JB,62 ))
     &+(RC(JB,182)    *Y(JB,65 ))   
     &+(RC(JB,177)    *Y(JB,103))+(RC(JB,178)    *Y(JB,90 ))
     &+(RC(JB,179)    *Y(JB,92 ))   
     &+(RC(JB,174)    *Y(JB,33 ))+(RC(JB,175)    *Y(JB,35 ))
     &+(RC(JB,176)    *Y(JB,95 ))   
     &+(RC(JB,171)    *Y(JB,89 ))+(RC(JB,172)    *Y(JB,91 ))
     &+(RC(JB,173)    *Y(JB,31 ))   
     &+(RC(JB,168)    *Y(JB,27 ))+(RC(JB,169)    *Y(JB,26 ))
     &+(RC(JB,170)    *Y(JB,29 ))   
     &+(RC(JB,163)    *Y(JB,122))+(RC(JB,166)    *Y(JB,22 ))
     &+(RC(JB,167)    *Y(JB,24 ))   
     &+(RC(JB,160)    *Y(JB,55 ))+(RC(JB,161)    *Y(JB,56 ))
     &+(RC(JB,162)    *Y(JB,56 ))   
     &+(RC(JB,157)    *Y(JB,121))+(RC(JB,158)    *Y(JB,54 ))
     &+(RC(JB,159)    *Y(JB,54 ))   
     &+(RC(JB,154)    *Y(JB,117))+(RC(JB,155)    *Y(JB,118))
     &+(RC(JB,156)    *Y(JB,119))   
     &+(RC(JB,151)    *Y(JB,49 ))+(RC(JB,152)    *Y(JB,50 ))
     &+(RC(JB,153)    *Y(JB,116))   
     &+(RC(JB,148)    *Y(JB,114))+(RC(JB,149)    *Y(JB,48 ))
     &+(RC(JB,150)    *Y(JB,48 ))   
     &+(RC(JB,145)    *Y(JB,37 ))+(RC(JB,146)    *Y(JB,38 ))
     &+(RC(JB,147)    *Y(JB,45 ))   
     &+(RC(JB,142)    *Y(JB,112))+(RC(JB,143)    *Y(JB,112))
     &+(RC(JB,144)    *Y(JB,36 ))   
     &+(RC(JB,139)    *Y(JB,110))+(RC(JB,140)    *Y(JB,110))
     &+(RC(JB,141)    *Y(JB,112))   
     &+(RC(JB,136)    *Y(JB,108))+(RC(JB,137)    *Y(JB,44 ))
     &+(RC(JB,138)    *Y(JB,44 ))   
     &+(RC(JB,133)    *Y(JB,74 ))+(RC(JB,134)    *Y(JB,75 ))
     &+(RC(JB,135)    *Y(JB,107))   
     &+(RC(JB,130)    *Y(JB,70 ))+(RC(JB,131)    *Y(JB,72 ))
     &+(RC(JB,132)    *Y(JB,106))   
     &+(RC(JB,127)    *Y(JB,103))+(RC(JB,128)    *Y(JB,90 ))
     &+(RC(JB,129)    *Y(JB,92 ))   
     &+(RC(JB,124)    *Y(JB,33 ))+(RC(JB,125)    *Y(JB,35 ))
     &+(RC(JB,126)    *Y(JB,95 ))   
     &+(RC(JB,121)    *Y(JB,69 ))+(RC(JB,122)    *Y(JB,31 ))
     &+(RC(JB,123)    *Y(JB,31 ))   
     &+(RC(JB,118)    *Y(JB,65 ))+(RC(JB,119)    *Y(JB,65 ))
     &+(RC(JB,120)    *Y(JB,68 ))   
     &+(RC(JB,115)    *Y(JB,93 ))+(RC(JB,116)    *Y(JB,94 ))
     &+(RC(JB,117)    *Y(JB,62 ))   
     &+(RC(JB,112)    *Y(JB,29 ))+(RC(JB,113)    *Y(JB,89 ))
     &+(RC(JB,114)    *Y(JB,91 ))   
     &+(RC(JB,109)    *Y(JB,27 ))+(RC(JB,110)    *Y(JB,26 ))
     &+(RC(JB,111)    *Y(JB,29 ))   
     &+(RC(JB,29)     *Y(JB,9  ))+(RC(JB,107)    *Y(JB,22 ))
     &+(RC(JB,108)    *Y(JB,24 ))   
     &+(RC(JB,11)     *Y(JB,8  ))+(RC(JB,12)     *Y(JB,5  ))
     &+(RC(JB,25)     *Y(JB,3  ))   
     &+(RC(JB,4)      *Y(JB,2  ))+(RC(JB,9)      *Y(JB,6  ))
     &+(RC(JB,11)     *Y(JB,8  ))   
      Y(JB,  8) = (YP(JB,  8)+DTS*P)/(1.0+DTS*L)
C
C          HO2              Y(JB,  9)
      P = EM(JB,  9)
     &+(DJ(JB,94)     *Y(JB,183))                                             
     &+(DJ(JB,91)     *Y(JB,180))       +(DJ(JB,93)     *Y(JB,182))                 
     &+(DJ(JB,84)     *Y(JB,153))       +(DJ(JB,85)     *Y(JB,174))                 
     &+(DJ(JB,82)     *Y(JB,151))       +(DJ(JB,83)     *Y(JB,152))                 
     &+(DJ(JB,77)     *Y(JB,157))       +(DJ(JB,78)     *Y(JB,158))                 
     &+(DJ(JB,75)     *Y(JB,155))       +(DJ(JB,76)     *Y(JB,156))                 
     &+(DJ(JB,73)     *Y(JB,173))       +(DJ(JB,74)     *Y(JB,154))                 
     &+(DJ(JB,70)     *Y(JB,167))       +(DJ(JB,72)     *Y(JB,172))                 
     &+(DJ(JB,68)     *Y(JB,166))       +(DJ(JB,69)     *Y(JB,166))                 
     &+(DJ(JB,58)     *Y(JB,148))       +(DJ(JB,63)     *Y(JB,161))                 
     &+(DJ(JB,55)     *Y(JB,146))       +(DJ(JB,56)     *Y(JB,147))                 
     &+(DJ(JB,53)     *Y(JB,144))       +(DJ(JB,54)     *Y(JB,145))                 
     &+(DJ(JB,51)     *Y(JB,138))       +(DJ(JB,52)     *Y(JB,142))                 
     &+(DJ(JB,49)     *Y(JB,136))       +(DJ(JB,50)     *Y(JB,137))                 
     &+(DJ(JB,44)     *Y(JB,126))       +(DJ(JB,46)     *Y(JB,127))                 
     &+(DJ(JB,42)     *Y(JB,124))       +(DJ(JB,43)     *Y(JB,125))                 
     &+(DJ(JB,39)     *Y(JB,51 ))       +(DJ(JB,41)     *Y(JB,123))                 
     &+(DJ(JB,37)     *Y(JB,99 ))       +(DJ(JB,38)     *Y(JB,99 ))                 
     &+(DJ(JB,35)     *Y(JB,97 ))       +(DJ(JB,36)     *Y(JB,97 ))                 
     &+(DJ(JB,33)     *Y(JB,96 ))       +(DJ(JB,34)    *Y(JB,96 )*2.00)            
     &+(DJ(JB,30)     *Y(JB,113)*2.00)                                        
     &+(DJ(JB,25)     *Y(JB,98 ))       +(DJ(JB,29)     *Y(JB,109))                 
     &+(DJ(JB,23)     *Y(JB,46 ))       +(DJ(JB,24)    *Y(JB,60 )*2.00)            
     &+(DJ(JB,22)     *Y(JB,102)*2.00)                                        
     &+(DJ(JB,20)     *Y(JB,104))       +(DJ(JB,21)     *Y(JB,105))                 
     &+(DJ(JB,18)     *Y(JB,111))       +(DJ(JB,19)     *Y(JB,188))                 
     &+(DJ(JB,11)     *Y(JB,42 ))       +(DJ(JB,12)     *Y(JB,71 ))                 
     &+(RC(JB,379)    *Y(JB,3  )*Y(JB,96 ))+(DJ(JB,9) *Y(JB,39 )*2.00)            
     &+(RC(JB,357)    *Y(JB,3  )*Y(JB,188))
     &+(RC(JB,366)    *Y(JB,3  )*Y(JB,60 ))          
     &+(RC(JB,350)    *Y(JB,56 ))       
     &+(RC(JB,356)    *Y(JB,3  )*Y(JB,111))          
     &+(RC(JB,347)    *Y(JB,119))       +(RC(JB,349)    *Y(JB,54 ))                 
     &+(RC(JB,340)    *Y(JB,114))       +(RC(JB,341)    *Y(JB,48 ))                 
     &+(RC(JB,335)    *Y(JB,112))       +(RC(JB,339)    *Y(JB,45 ))                 
     &+(RC(JB,332)    *Y(JB,110))       +(RC(JB,334)    *Y(JB,112))                 
     &+(RC(JB,329)    *Y(JB,44 ))       +(RC(JB,330)    *Y(JB,44 ))                 
     &+(RC(JB,321)    *Y(JB,92 ))       +(RC(JB,324)    *Y(JB,106))                 
     &+(RC(JB,319)    *Y(JB,103))       +(RC(JB,320)    *Y(JB,90 ))                 
     &+(RC(JB,317)    *Y(JB,35 ))       +(RC(JB,318)    *Y(JB,95 ))                 
     &+(RC(JB,315)    *Y(JB,31 ))       +(RC(JB,316)    *Y(JB,33 ))                 
     &+(RC(JB,311)    *Y(JB,69 ))       +(RC(JB,314)    *Y(JB,31 ))                 
     &+(RC(JB,309)    *Y(JB,65 ))       +(RC(JB,310)    *Y(JB,68 ))                 
     &+(RC(JB,307)    *Y(JB,62 ))       +(RC(JB,308)    *Y(JB,65 ))                 
     &+(RC(JB,300)    *Y(JB,26 ))       +(RC(JB,304)    *Y(JB,29 ))                 
     &+(RC(JB,294)    *Y(JB,24 ))       +(RC(JB,297)    *Y(JB,27 ))                 
     &+(RC(JB,241)    *Y(JB,56 )*Y(JB,5  ))+(RC(JB,291)    *Y(JB,22 ))                 
     &+(RC(JB,238)    *Y(JB,119)*Y(JB,5  ))
     &+(RC(JB,240)    *Y(JB,54 )*Y(JB,5  ))          
     &+(RC(JB,231)    *Y(JB,114)*Y(JB,5  ))
     &+(RC(JB,232)    *Y(JB,48 )*Y(JB,5  ))          
     &+(RC(JB,226)    *Y(JB,112)*Y(JB,5  ))
     &+(RC(JB,230)    *Y(JB,45 )*Y(JB,5  ))          
     &+(RC(JB,223)    *Y(JB,110)*Y(JB,5  ))
     &+(RC(JB,225)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,220)    *Y(JB,44 )*Y(JB,5  ))
     &+(RC(JB,221)    *Y(JB,44 )*Y(JB,5  ))          
     &+(RC(JB,212)    *Y(JB,92 )*Y(JB,5  ))
     &+(RC(JB,215)    *Y(JB,106)*Y(JB,5  ))          
     &+(RC(JB,210)    *Y(JB,103)*Y(JB,5  ))
     &+(RC(JB,211)    *Y(JB,90 )*Y(JB,5  ))          
     &+(RC(JB,208)    *Y(JB,35 )*Y(JB,5  ))
     &+(RC(JB,209)    *Y(JB,95 )*Y(JB,5  ))          
     &+(RC(JB,206)    *Y(JB,31 )*Y(JB,5  ))
     &+(RC(JB,207)    *Y(JB,33 )*Y(JB,5  ))          
     &+(RC(JB,204)    *Y(JB,69 )*Y(JB,5  ))
     &+(RC(JB,205)    *Y(JB,31 )*Y(JB,5  ))          
     &+(RC(JB,202)    *Y(JB,65 )*Y(JB,5  ))
     &+(RC(JB,203)    *Y(JB,68 )*Y(JB,5  ))          
     &+(RC(JB,200)    *Y(JB,62 )*Y(JB,5  ))
     &+(RC(JB,201)    *Y(JB,65 )*Y(JB,5  ))          
     &+(RC(JB,193)    *Y(JB,26 )*Y(JB,5  ))
     &+(RC(JB,195)    *Y(JB,29 )*Y(JB,5  ))          
     &+(RC(JB,191)    *Y(JB,24 )*Y(JB,5  ))
     &+(RC(JB,192)    *Y(JB,27 )*Y(JB,5  ))          
     &+(RC(JB,161)    *Y(JB,56 )*Y(JB,8  ))
     &+(RC(JB,190)    *Y(JB,22 )*Y(JB,5  ))          
     &+(RC(JB,156)    *Y(JB,119)*Y(JB,8  ))
     &+(RC(JB,158)    *Y(JB,54 )*Y(JB,8  ))          
     &+(RC(JB,148)    *Y(JB,114)*Y(JB,8  ))
     &+(RC(JB,149)    *Y(JB,48 )*Y(JB,8  ))          
     &+(RC(JB,143)    *Y(JB,112)*Y(JB,8  ))
     &+(RC(JB,147)    *Y(JB,45 )*Y(JB,8  ))          
     &+(RC(JB,140)    *Y(JB,110)*Y(JB,8  ))
     &+(RC(JB,142)    *Y(JB,112)*Y(JB,8  ))          
     &+(RC(JB,137)    *Y(JB,44 )*Y(JB,8  ))
     &+(RC(JB,138)    *Y(JB,44 )*Y(JB,8  ))          
     &+(RC(JB,129)    *Y(JB,92 )*Y(JB,8  ))
     &+(RC(JB,132)    *Y(JB,106)*Y(JB,8  ))          
     &+(RC(JB,127)    *Y(JB,103)*Y(JB,8  ))
     &+(RC(JB,128)    *Y(JB,90 )*Y(JB,8  ))          
     &+(RC(JB,125)    *Y(JB,35 )*Y(JB,8  ))
     &+(RC(JB,126)    *Y(JB,95 )*Y(JB,8  ))          
     &+(RC(JB,123)    *Y(JB,31 )*Y(JB,8  ))
     &+(RC(JB,124)    *Y(JB,33 )*Y(JB,8  ))          
     &+(RC(JB,121)    *Y(JB,69 )*Y(JB,8  ))
     &+(RC(JB,122)    *Y(JB,31 )*Y(JB,8  ))          
     &+(RC(JB,119)    *Y(JB,65 )*Y(JB,8  ))
     &+(RC(JB,120)    *Y(JB,68 )*Y(JB,8  ))          
     &+(RC(JB,117)    *Y(JB,62 )*Y(JB,8  ))
     &+(RC(JB,118)    *Y(JB,65 )*Y(JB,8  ))          
     &+(RC(JB,110)    *Y(JB,26 )*Y(JB,8  ))
     &+(RC(JB,112)    *Y(JB,29 )*Y(JB,8  ))          
     &+(RC(JB,108)    *Y(JB,24 )*Y(JB,8  ))
     &+(RC(JB,109)    *Y(JB,27 )*Y(JB,8  ))          
     &+(RC(JB,97)     *Y(JB,40 )*Y(JB,3  ))
     &+(RC(JB,107)    *Y(JB,22 )*Y(JB,8  ))          
     &+(RC(JB,93)     *Y(JB,78 )*Y(JB,3  ))
     &+(RC(JB,95)     *Y(JB,3  )*Y(JB,79 ))          
     &+(RC(JB,90)     *Y(JB,3  )*Y(JB,76 ))
     &+(RC(JB,91)     *Y(JB,3  )*Y(JB,77 ))          
     &+(RC(JB,82)     *Y(JB,3  )*Y(JB,39 ))
     &+(RC(JB,85)     *Y(JB,5  )*Y(JB,39 ))          
     &+(RC(JB,77)     *Y(JB,61 )*Y(JB,3  ))
     &+(RC(JB,79)     *Y(JB,64 )*Y(JB,3  ))          
     &+(RC(JB,61)     *Y(JB,6  )*Y(JB,43 ))
     &+(RC(JB,74)     *Y(JB,59 )*Y(JB,3  ))          
     &+(RC(JB,38)     *Y(JB,18 ))       
     &+(RC(JB,53)     *Y(JB,6  )*Y(JB,30 ))          
     &+(RC(JB,28)     *Y(JB,3  )*Y(JB,5  ))
     &+(RC(JB,31)     *Y(JB,15 ))                 
     &+(RC(JB,19)     *Y(JB,3  )*Y(JB,11 ))
     &+(RC(JB,20)     *Y(JB,3  )*Y(JB,12 ))          
     &+(RC(JB,17)     *Y(JB,3  )*Y(JB,6  ))
     &+(RC(JB,18)     *Y(JB,3  )*Y(JB,10 ))
     &+(RC(JB,514)    *Y(JB,3  )*Y(JB,220))
     &+(RC(JB,525)    *Y(JB,224)*Y(JB,39 ))
     &+(RC(JB,537)*Y(JB,6)*Y(JB,43))   
     &+(RC(JB,375)    *Y(JB,6  )*Y(JB,109))     
      L = 0.0
     &+(RC(JB,289)    *Y(JB,122))+(RC(JB,290)    *Y(JB,55 ))                        
     &+(RC(JB,286)    *Y(JB,121))+(RC(JB,287)    *Y(JB,54 ))
     &+(RC(JB,288)    *Y(JB,56 ))   
     &+(RC(JB,283)    *Y(JB,117))+(RC(JB,284)    *Y(JB,118))
     &+(RC(JB,285)    *Y(JB,119))   
     &+(RC(JB,280)    *Y(JB,49 ))+(RC(JB,281)    *Y(JB,50 ))
     &+(RC(JB,282)    *Y(JB,116))   
     &+(RC(JB,277)    *Y(JB,45 ))+(RC(JB,278)    *Y(JB,114))
     &+(RC(JB,279)    *Y(JB,48 ))   
     &+(RC(JB,274)    *Y(JB,36 ))+(RC(JB,275)    *Y(JB,37 ))
     &+(RC(JB,276)    *Y(JB,38 ))   
     &+(RC(JB,271)    *Y(JB,44 ))+(RC(JB,272)    *Y(JB,110))
     &+(RC(JB,273)    *Y(JB,112))   
     &+(RC(JB,268)    *Y(JB,75 ))+(RC(JB,269)    *Y(JB,107))
     &+(RC(JB,270)    *Y(JB,108))   
     &+(RC(JB,265)    *Y(JB,72 ))+(RC(JB,266)    *Y(JB,106))
     &+(RC(JB,267)    *Y(JB,74 ))   
     &+(RC(JB,262)    *Y(JB,90 ))+(RC(JB,263)    *Y(JB,92 ))
     &+(RC(JB,264)    *Y(JB,70 ))   
     &+(RC(JB,259)    *Y(JB,35 ))+(RC(JB,260)    *Y(JB,95 ))
     &+(RC(JB,261)    *Y(JB,103))   
     &+(RC(JB,256)    *Y(JB,69 ))+(RC(JB,257)    *Y(JB,31 ))
     &+(RC(JB,258)    *Y(JB,33 ))   
     &+(RC(JB,253)    *Y(JB,62 ))+(RC(JB,254)    *Y(JB,65 ))
     &+(RC(JB,255)    *Y(JB,68 ))   
     &+(RC(JB,250)    *Y(JB,91 ))+(RC(JB,251)    *Y(JB,93 ))
     &+(RC(JB,252)    *Y(JB,94 ))   
     &+(RC(JB,247)    *Y(JB,26 ))+(RC(JB,248)    *Y(JB,29 ))
     &+(RC(JB,249)    *Y(JB,89 ))   
     &+(RC(JB,244)    *Y(JB,22 ))+(RC(JB,245)    *Y(JB,24 ))
     &+(RC(JB,246)    *Y(JB,27 ))   
     &+(RC(JB,29)     *Y(JB,8  ))+(RC(JB,30)     *Y(JB,4  ))
     &+(RC(JB,33)     *Y(JB,5  ))   
     &+(RC(JB,23)     *Y(JB,9  ))+(RC(JB,24)     *Y(JB,9  ))
     &+(RC(JB,24)     *Y(JB,9  ))   
     &+(RC(JB,21)     *Y(JB,6  ))+(RC(JB,22)     *Y(JB,3  ))
     &+(RC(JB,23)     *Y(JB,9  ))
     &+(RC(JB,523)    *Y(JB,224))	  
      Y(JB,  9) = (YP(JB,  9)+DTS*P)/(1.0+DTS*L)
C
C          H2               Y(JB, 10)
      P = EM(JB, 10)
     &+(DJ(JB,10)     *Y(JB,39 ))                                             
      L = DD(JB,10)+DW(JB,10)
     &+(RC(JB,18)     *Y(JB,3  ))                                             
      Y(JB, 10) = (YP(JB, 10)+DTS*P)/(1.0+DTS*L)
C
C          CO               Y(JB, 11)
      P = EM(JB, 11)
     &+(DJ(JB,92)     *Y(JB,181))                                             
     &+(DJ(JB,40)     *Y(JB,120))       +(DJ(JB,73)     *Y(JB,173))                 
     &+(DJ(JB,30)     *Y(JB,113)*2.00)                                        
     &+(DJ(JB,25)     *Y(JB,98 ))       +(DJ(JB,29)     *Y(JB,109))                 
     &+(DJ(JB,24)     *Y(JB,60 )*2.00)                                        
     &+(DJ(JB,12)     *Y(JB,71 ))       +(DJ(JB,22)     *Y(JB,102))                 
     &+(DJ(JB,10)     *Y(JB,39 ))       +(DJ(JB,11)     *Y(JB,42 ))                 
     &+(RC(JB,480)    *Y(JB,3  )*Y(JB,202))+(DJ(JB,9)      *Y(JB,39 ))                 
     &+(RC(JB,474)    *Y(JB,3  )*Y(JB,199))
     &+(RC(JB,475)    *Y(JB,3  )*Y(JB,200))          
     &+(RC(JB,442)    *Y(JB,3  )*Y(JB,173))
     &+(RC(JB,473)    *Y(JB,3  )*Y(JB,198))          
     &+(RC(JB,367)    *Y(JB,3  )*Y(JB,98 ))
     &+(RC(JB,374)    *Y(JB,6  )*Y(JB,109))          
     &+(RC(JB,362)    *Y(JB,6  )*Y(JB,46 ))
     &+(RC(JB,366)    *Y(JB,3  )*Y(JB,60 )*2.00)     
     &+(RC(JB,340)    *Y(JB,114))       +(RC(JB,348)    *Y(JB,121))                 
     &+(RC(JB,231)    *Y(JB,114)*Y(JB,5  ))
     &+(RC(JB,239)    *Y(JB,121)*Y(JB,5  ))          
     &+(RC(JB,157)    *Y(JB,121)*Y(JB,8  ))
     &+(RC(JB,223)    *Y(JB,110)*Y(JB,5  ))          
     &+(RC(JB,140)    *Y(JB,110)*Y(JB,8  ))
     &+(RC(JB,148)    *Y(JB,114)*Y(JB,8  ))          
     &+(RC(JB,82)     *Y(JB,3  )*Y(JB,39 ))
     &+(RC(JB,85)     *Y(JB,5  )*Y(JB,39 ))          
     &+(RC(JB,74)     *Y(JB,59 )*Y(JB,3  ))          
     &+(RC(JB,57)     *Y(JB,6  )*Y(JB,34 ))
     &+(RC(JB,61)     *Y(JB,6  )*Y(JB,43 ))          
     &+(RC(JB,53)     *Y(JB,6  )*Y(JB,30 ))
     &+(RC(JB,55)     *Y(JB,6  )*Y(JB,32 ))
     &+(RC(JB,525)    *Y(JB,39 )*Y(JB,224))  
     &+(RC(JB,54)     *Y(JB,6  )*Y(JB,30 ))   
     &+(RC(JB,537)*Y(JB,6)*Y(JB,43)) 
     &+(RC(JB,534)*Y(JB,6)*Y(JB,43))    
     &+(RC(JB,70)     *Y(JB,53 )*Y(JB,6  ))    
     &+(RC(JB,555)*Y(JB,232))  
     &+(RC(JB,560)*Y(JB,235))        
      L = DD(JB, 11)+DW(JB, 11)
     &+(RC(JB,19)     *Y(JB,3  ))                                             
      Y(JB, 11) = (YP(JB, 11)+DTS*P)/(1.0+DTS*L)
C
C          H2O2             Y(JB, 12)
      P = EM(JB, 12)
     &+(RC(JB,363)    *Y(JB,6  )*Y(JB,46 ))
     &+(RC(JB,66)     *Y(JB,47 )*Y(JB,6  ))
     &+(RC(JB,71)     *Y(JB,53 )*Y(JB,6  ))          
     &+(RC(JB,23)     *Y(JB,9  )*Y(JB,9  ))
     &+(RC(JB,24)     *Y(JB,9  )*Y(JB,9  ))          
      L = DD(JB,12)+DW(JB,12)+LAQ(JB,4) 
     &+(RC(JB,20)     *Y(JB,3  ))+(DJ(JB,3)      )                               
      Y(JB, 12) = (YP(JB, 12)+DTS*P)/(1.0+DTS*L)
C
C          HONO             Y(JB, 13)
      P = EM(JB, 13)
     &+(RC(JB,25)     *Y(JB,3  )*Y(JB,8  ))+(RC(JB,26)     *Y(JB,4  ))                 
      L = DD(JB, 13)+DW(JB, 13)
     &+(RC(JB,34)     *Y(JB,3  ))+(DJ(JB,7)      )                               
      Y(JB, 13) = (YP(JB, 13)+DTS*P)/(1.0+DTS*L)
C
C          HNO3             Y(JB, 14)
      P = EM(JB, 14)
     &+(RC(JB,422)    *Y(JB,5  )*Y(JB,197))                                      
     &+(RC(JB,417)    *Y(JB,5  )*Y(JB,195))
     &+(RC(JB,419)    *Y(JB,5  )*Y(JB,66 ))          
     &+(RC(JB,388)    *Y(JB,5  )*Y(JB,120))
     &+(RC(JB,414)    *Y(JB,5  )*Y(JB,63 ))          
     &+(RC(JB,373)    *Y(JB,5  )*Y(JB,109))
     &+(RC(JB,387)    *Y(JB,5  )*Y(JB,51 ))          
     &+(RC(JB,361)    *Y(JB,5  )*Y(JB,46 ))
     &+(RC(JB,365)    *Y(JB,5  )*Y(JB,102))          
     &+(RC(JB,86)     *Y(JB,5  )*Y(JB,42 ))
     &+(RC(JB,87)     *Y(JB,5  )*Y(JB,71 ))          
     &+(RC(JB,27)     *Y(JB,3  )*Y(JB,4  ))
     &+(RC(JB,85)     *Y(JB,5  )*Y(JB,39 ))
     &+(RC(JB,515)    *Y(JB,5  )*Y(JB,220))          
      L = DD(JB,14)+DW(JB,14)
     &+(RC(JB,35)     *Y(JB,3  ))+(RC(JB,39)     ) +(DJ(JB,8)   )          
      Y(JB, 14) = (YP(JB, 14)+DTS*P)/(1.0+DTS*L)
C
C          HO2NO2           Y(JB, 15)
      P = EM(JB, 15)
     &+(RC(JB,30)     *Y(JB,9  )*Y(JB,4  ))                                      
      L = 0.0
     &+(RC(JB,31)     )       +(RC(JB,32)     *Y(JB,3  ))                        
      Y(JB, 15) = (YP(JB, 15)+DTS*P)/(1.0+DTS*L)
C
C          SO2              Y(JB, 16)
      P = EM(JB, 16)
     &+(RC(JB,522)    *Y(JB,223))
      L = DD(JB,16)+DW(JB,16)+LAQ(JB,1) 
     &+(RC(JB,36)     *Y(JB,2  ))+(RC(JB,37)     *Y(JB,3  ))                        
      Y(JB, 16) = (YP(JB, 16)+DTS*P)/(1.0+DTS*L)
C
C          SO3              Y(JB, 17)
      P = EM(JB, 17)
     &+(RC(JB,36)     *Y(JB,2  )*Y(JB,16 ))+(RC(JB,38)     *Y(JB,18 ))                 
      L = 0.0
     &+(RC(JB,41)     )                                                    
      Y(JB, 17) = (YP(JB, 17)+DTS*P)/(1.0+DTS*L)
C
C          HSO3             Y(JB, 18)
      P = EM(JB, 18)
     &+(RC(JB,37)     *Y(JB,3  )*Y(JB,16 ))                                      
      L = 0.0
     &+(RC(JB,38)     )                                                    
      Y(JB, 18) = (YP(JB, 18)+DTS*P)/(1.0+DTS*L)
C
C          NAER               Y(JB, 19)
      P = EM(JB, 19)
     &+(RC(JB,40)     *Y(JB,7  ))                                             
     &+(RC(JB,39)     *Y(JB,14 ))       +(RC(JB,40)     *Y(JB,7  ))                 
      L = DD(JB,19)+DW(JB,19) 
      Y(JB, 19) = (YP(JB, 19)+DTS*P)/(1.0+DTS*L)
C
C          SA               Y(JB, 20)
      P = EM(JB, 20)+LAQ(JB,2)
     &+(RC(JB,41)     *Y(JB,17 ))
     &+(RC(JB,524)    *Y(JB,224))	                                            
      L = DD(JB,20)+DW(JB,20)+LAQ(JB,9) 
      Y(JB, 20) = (YP(JB, 20)+DTS*P)/(1.0+DTS*L)
C
C          CH4              Y(JB, 21)
      P = EM(JB, 21)
      L = 0.0
     &+(RC(JB,42)     *Y(JB,3  ))                                             
      Y(JB, 21) = (YP(JB, 21)+DTS*P)/(1.0+DTS*L)
C
C          CH3O2            Y(JB, 22)
      P = EM(JB, 22)
     &+(DJ(JB,61)     *Y(JB,159))                                             
     &+(DJ(JB,13)     *Y(JB,73 ))       +(DJ(JB,36)     *Y(JB,97 ))                 
     &+(RC(JB,423)    *Y(JB,3  )*Y(JB,144))+(DJ(JB,11)     *Y(JB,42 ))                 
     &+(RC(JB,322)    *Y(JB,70 ))       
     &+(RC(JB,381)    *Y(JB,3  )*Y(JB,97 ))          
     &+(RC(JB,165)    *Y(JB,217))       
     &+(RC(JB,213)    *Y(JB,70 )*Y(JB,5  ))          
     &+(RC(JB,101)    *Y(JB,3  )*Y(JB,82 ))
     &+(RC(JB,130)    *Y(JB,70 )*Y(JB,8  ))          
     &+(RC(JB,99)     *Y(JB,3  )*Y(JB,80 ))
     &+(RC(JB,100)    *Y(JB,3  )*Y(JB,81 ))          
     &+(RC(JB,57)     *Y(JB,6  )*Y(JB,34 ))
     &+(RC(JB,98)     *Y(JB,41 )*Y(JB,3  ))          
     &+(RC(JB,42)     *Y(JB,3  )*Y(JB,21 ))
     &+(RC(JB,55)     *Y(JB,6  )*Y(JB,32 ))
     &+(RC(JB,516)    *Y(JB,3  )*Y(JB,220))
     &+(RC(JB,522)    *Y(JB,223))
     &+(RC(JB,524)    *Y(JB,224))
     &+(RC(JB,537)*Y(JB,6)*Y(JB,43))       
      L = 0.0
     &+(RC(JB,292)    )       +(RC(JB,293)    )                               
     &+(RC(JB,190)    *Y(JB,5  ))+(RC(JB,244)    *Y(JB,9  ))
     &+(RC(JB,291)    )          
     &+(RC(JB,107)    *Y(JB,8  ))+(RC(JB,164)    *Y(JB,4  ))
     &+(RC(JB,166)    *Y(JB,8  ))   
      Y(JB, 22) = (YP(JB, 22)+DTS*P)/(1.0+DTS*L)
C
C          C2H6             Y(JB, 23)
      P = EM(JB, 23)
      L = 0.0
     &+(RC(JB,43)     *Y(JB,3  ))                                             
      Y(JB, 23) = (YP(JB, 23)+DTS*P)/(1.0+DTS*L)
C
C          C2H5O2           Y(JB, 24)
      P = EM(JB, 24)
     &+(DJ(JB,64)     *Y(JB,162))                                             
     &+(DJ(JB,57)     *Y(JB,148))       +(DJ(JB,62)     *Y(JB,160))                 
     &+(DJ(JB,38)     *Y(JB,99 ))       +(DJ(JB,45)     *Y(JB,127))                 
     &+(DJ(JB,17)     *Y(JB,88 ))       +(DJ(JB,33)     *Y(JB,96 ))                 
     &+(DJ(JB,12)     *Y(JB,71 ))       +(DJ(JB,14)     *Y(JB,101))                 
     &+(RC(JB,378)    *Y(JB,3  )*Y(JB,96 ))
     &+(RC(JB,383)    *Y(JB,3  )*Y(JB,99 ))          
     &+(RC(JB,303)    *Y(JB,29 ))       +(RC(JB,323)    *Y(JB,72 ))                 
     &+(RC(JB,194)    *Y(JB,29 )*Y(JB,5  ))
     &+(RC(JB,214)    *Y(JB,72 )*Y(JB,5  ))          
     &+(RC(JB,111)    *Y(JB,29 )*Y(JB,8  ))
     &+(RC(JB,131)    *Y(JB,72 )*Y(JB,8  ))          
     &+(RC(JB,43)     *Y(JB,3  )*Y(JB,23 ))
     &+(RC(JB,102)    *Y(JB,3  )*Y(JB,83 ))          
      L = 0.0
     &+(RC(JB,296)    )                                                    
     &+(RC(JB,245)    *Y(JB,9  ))+(RC(JB,294)    )       
     &+(RC(JB,295)    )          
     &+(RC(JB,108)    *Y(JB,8  ))+(RC(JB,167)    *Y(JB,8  ))
     &+(RC(JB,191)    *Y(JB,5  ))   
      Y(JB, 24) = (YP(JB, 24)+DTS*P)/(1.0+DTS*L)
C
C          C3H8             Y(JB, 25)
      P = EM(JB, 25)
      L = 0.0
     &+(RC(JB,44)     *Y(JB,3  ))+(RC(JB,45)     *Y(JB,3  ))                        
      Y(JB, 25) = (YP(JB, 25)+DTS*P)/(1.0+DTS*L)
C
C          IC3H7O2          Y(JB, 26)
      P = EM(JB, 26)
     &+(RC(JB,44)     *Y(JB,3  )*Y(JB,25 ))                                      
      L = 0.0
     &+(RC(JB,302)    )                                                    
     &+(RC(JB,247)    *Y(JB,9  ))+(RC(JB,300)    )       
     &+(RC(JB,301)    )          
     &+(RC(JB,110)    *Y(JB,8  ))+(RC(JB,169)    *Y(JB,8  ))
     &+(RC(JB,193)    *Y(JB,5  ))   
      Y(JB, 26) = (YP(JB, 26)+DTS*P)/(1.0+DTS*L)
C
C          RN10O2           Y(JB, 27)
      P = EM(JB, 27)
     &+(DJ(JB,35)     *Y(JB,97 ))       +(DJ(JB,65)     *Y(JB,163))                 
     &+(DJ(JB,15)     *Y(JB,186))       +(DJ(JB,16)     *Y(JB,187))                 
     &+(RC(JB,45)     *Y(JB,3  )*Y(JB,25 ))
     &+(RC(JB,380)    *Y(JB,3  )*Y(JB,97 ))          
      L = 0.0
     &+(RC(JB,299)    )                                                    
     &+(RC(JB,246)    *Y(JB,9  ))+(RC(JB,297)    )       
     &+(RC(JB,298)    )          
     &+(RC(JB,109)    *Y(JB,8  ))+(RC(JB,168)    *Y(JB,8  ))
     &+(RC(JB,192)    *Y(JB,5  ))   
      Y(JB, 27) = (YP(JB, 27)+DTS*P)/(1.0+DTS*L)
C
C          NC4H10           Y(JB, 28)
      P = EM(JB, 28)
      L = 0.0
     &+(RC(JB,46)     *Y(JB,3  ))                                             
      Y(JB, 28) = (YP(JB, 28)+DTS*P)/(1.0+DTS*L)
C
C          RN13O2           Y(JB, 29)
      P = EM(JB, 29)
     &+(DJ(JB,95)     *Y(JB,184))                                             
     &+(DJ(JB,37)     *Y(JB,99 ))       +(DJ(JB,66)     *Y(JB,164))                 
     &+(RC(JB,358)    *Y(JB,3  )*Y(JB,104))
     &+(RC(JB,382)    *Y(JB,3  )*Y(JB,99 ))          
     &+(RC(JB,242)    *Y(JB,122)*Y(JB,5  ))
     &+(RC(JB,351)    *Y(JB,122))                 
     &+(RC(JB,46)     *Y(JB,3  )*Y(JB,28 ))
     &+(RC(JB,163)    *Y(JB,122)*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,303)    )       +(RC(JB,304)    )                               
     &+(RC(JB,194)    *Y(JB,5  ))+(RC(JB,195)    *Y(JB,5  ))
     &+(RC(JB,248)    *Y(JB,9  ))   
     &+(RC(JB,111)    *Y(JB,8  ))+(RC(JB,112)    *Y(JB,8  ))
     &+(RC(JB,170)    *Y(JB,8  ))   
      Y(JB, 29) = (YP(JB, 29)+DTS*P)/(1.0+DTS*L)
C
C          C2H4             Y(JB, 30)
      P = EM(JB, 30)
      L = 0.0
     &+(RC(JB,54)     *Y(JB,6  ))                                             
     &+(RC(JB,47)     *Y(JB,3  ))+(RC(JB,50)     *Y(JB,5  ))
     &+(RC(JB,53)     *Y(JB,6  )) +(RC(JB,530)*Y(JB,6))  
      Y(JB, 30) = (YP(JB, 30)+DTS*P)/(1.0+DTS*L)
C
C          HOCH2CH2O2       Y(JB, 31)
      P = EM(JB, 31)
     &+(RC(JB,466)    *Y(JB,3  )*Y(JB,192))                                      
     &+(RC(JB,105)    *Y(JB,3  )*Y(JB,86 ))
     &+(RC(JB,106)    *Y(JB,3  )*Y(JB,87 ))          
     &+(RC(JB,103)    *Y(JB,3  )*Y(JB,84 ))
     &+(RC(JB,104)    *Y(JB,3  )*Y(JB,85 ))          
     &+(RC(JB,47)     *Y(JB,3  )*Y(JB,30 ))
     &+(RC(JB,92)     *Y(JB,3  )*Y(JB,77 ))          
      L = 0.0
     &+(RC(JB,314)    )       +(RC(JB,315)    )                               
     &+(RC(JB,205)    *Y(JB,5  ))+(RC(JB,206)    *Y(JB,5  ))
     &+(RC(JB,257)    *Y(JB,9  ))   
     &+(RC(JB,122)    *Y(JB,8  ))+(RC(JB,123)    *Y(JB,8  ))
     &+(RC(JB,173)    *Y(JB,8  ))   
      Y(JB, 31) = (YP(JB, 31)+DTS*P)/(1.0+DTS*L)
C
C          C3H6             Y(JB, 32)
      P = EM(JB, 32)
      L = 0.0
     &+(RC(JB,56)     *Y(JB,6  ))                                             
     &+(RC(JB,48)     *Y(JB,3  ))+(RC(JB,51)     *Y(JB,5  ))
     &+(RC(JB,55)     *Y(JB,6  )) +(RC(JB,531)*Y(JB,6))
     &+(RC(JB,532)*Y(JB,6))     
      Y(JB, 32) = (YP(JB, 32)+DTS*P)/(1.0+DTS*L)
C
C          RN9O2            Y(JB, 33)
      P = EM(JB, 33)
     &+(RC(JB,96)     *Y(JB,3  )*Y(JB,79 ))
     &+(RC(JB,368)    *Y(JB,3  )*Y(JB,100))          
     &+(RC(JB,48)     *Y(JB,3  )*Y(JB,32 ))
     &+(RC(JB,94)     *Y(JB,78 )*Y(JB,3  ))          
      L = 0.0
     &+(RC(JB,258)    *Y(JB,9  ))+(RC(JB,316)    )                               
     &+(RC(JB,124)    *Y(JB,8  ))+(RC(JB,174)    *Y(JB,8  ))
     &+(RC(JB,207)    *Y(JB,5  ))   
      Y(JB, 33) = (YP(JB, 33)+DTS*P)/(1.0+DTS*L)
C
C          TBUT2ENE         Y(JB, 34)
      P = EM(JB, 34)
      L = 0.0
     &+(RC(JB,58)     *Y(JB,6  ))                                             
     &+(RC(JB,49)     *Y(JB,3  ))+(RC(JB,52)     *Y(JB,5  ))
     &+(RC(JB,57)     *Y(JB,6  )) +(RC(JB,533)*Y(JB,6))  
      Y(JB, 34) = (YP(JB, 34)+DTS*P)/(1.0+DTS*L)
C
C          RN12O2           Y(JB, 35)
      P = EM(JB, 35)
     &+(RC(JB,369)    *Y(JB,3  )*Y(JB,189))
     &+(RC(JB,371)    *Y(JB,3  )*Y(JB,191))          
     &+(RC(JB,198)    *Y(JB,93 )*Y(JB,5  ))
     &+(RC(JB,305)    *Y(JB,93 ))                 
     &+(RC(JB,49)     *Y(JB,3  )*Y(JB,34 ))
     &+(RC(JB,115)    *Y(JB,93 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,259)    *Y(JB,9  ))+(RC(JB,317)    )                               
     &+(RC(JB,125)    *Y(JB,8  ))+(RC(JB,175)    *Y(JB,8  ))
     &+(RC(JB,208)    *Y(JB,5  ))   
      Y(JB, 35) = (YP(JB, 35)+DTS*P)/(1.0+DTS*L)
C
C          NRN6O2           Y(JB, 36)
      P = EM(JB, 36)
     &+(RC(JB,50)     *Y(JB,5  )*Y(JB,30 ))                                      
      L = 0.0
     &+(RC(JB,336)    )                                                    
     &+(RC(JB,144)    *Y(JB,8  ))+(RC(JB,227)    *Y(JB,5  ))
     &+(RC(JB,274)    *Y(JB,9  ))   
      Y(JB, 36) = (YP(JB, 36)+DTS*P)/(1.0+DTS*L)
C
C          NRN9O2           Y(JB, 37)
      P = EM(JB, 37)
     &+(RC(JB,51)     *Y(JB,5  )*Y(JB,32 ))                                      
      L = 0.0
     &+(RC(JB,337)    )                                                    
     &+(RC(JB,145)    *Y(JB,8  ))+(RC(JB,228)    *Y(JB,5  ))
     &+(RC(JB,275)    *Y(JB,9  ))   
      Y(JB, 37) = (YP(JB, 37)+DTS*P)/(1.0+DTS*L)
C
C          NRN12O2          Y(JB, 38)
      P = EM(JB, 38)
     &+(RC(JB,52)     *Y(JB,5  )*Y(JB,34 ))                                      
      L = 0.0
     &+(RC(JB,338)    )                                                    
     &+(RC(JB,146)    *Y(JB,8  ))+(RC(JB,229)    *Y(JB,5  ))
     &+(RC(JB,276)    *Y(JB,9  ))   
      Y(JB, 38) = (YP(JB, 38)+DTS*P)/(1.0+DTS*L)
C
C          HCHO             Y(JB, 39)
      P = EM(JB, 39)
     &+(DJ(JB,93)     *Y(JB,182))       +(DJ(JB,96)     *Y(JB,185))                 
     &+(DJ(JB,80)     *Y(JB,170))       +(DJ(JB,91)     *Y(JB,180))                 
     &+(DJ(JB,75)     *Y(JB,155))       
     &+(DJ(JB,79)     *Y(JB,169)*2.00)            
     &+(DJ(JB,74)     *Y(JB,154)*2.00)                                        
     &+(DJ(JB,63)     *Y(JB,161))       +(DJ(JB,69)     *Y(JB,166))                 
     &+(DJ(JB,41)     *Y(JB,123))       +(DJ(JB,53)     *Y(JB,144))                 
     &+(DJ(JB,31)     *Y(JB,115))       +(DJ(JB,32)     *Y(JB,115))                 
     &+(DJ(JB,22)     *Y(JB,102))       +(DJ(JB,23)     *Y(JB,46 ))                 
     &+(RC(JB,475)    *Y(JB,3  )*Y(JB,200))+(DJ(JB,18)     *Y(JB,111))                 
     &+(RC(JB,449)    *Y(JB,3  )*Y(JB,170))
     &+(RC(JB,473)    *Y(JB,3  )*Y(JB,198))          
     &+(RC(JB,424)    *Y(JB,3  )*Y(JB,144))
     &+(RC(JB,448)    *Y(JB,3  )*Y(JB,169)*2.00)     
     &+(RC(JB,392)    *Y(JB,3  )*Y(JB,123))
     &+(RC(JB,410)    *Y(JB,3  )*Y(JB,141))          
     &+(RC(JB,362)    *Y(JB,6  )*Y(JB,46 ))
     &+(RC(JB,363)    *Y(JB,6  )*Y(JB,46 ))          
     &+(RC(JB,349)    *Y(JB,54 ))       +(RC(JB,352)    *Y(JB,55 ))                 
     &+(RC(JB,337)    *Y(JB,37 ))       +(RC(JB,347)    *Y(JB,119))                 
     &+(RC(JB,336)    *Y(JB,36 )*2.00)                                        
     &+(RC(JB,334)    *Y(JB,112))       +(RC(JB,335)    *Y(JB,112))                 
     &+(RC(JB,325)    *Y(JB,74 ))       +(RC(JB,330)    *Y(JB,44 ))                 
     &+(RC(JB,316)    *Y(JB,33 ))       +(RC(JB,324)    *Y(JB,106))                 
     &+(RC(JB,314)    *Y(JB,31 )*2.00)                                        
     &+(RC(JB,291)    *Y(JB,22 ))       +(RC(JB,292)    *Y(JB,22 ))                 
     &+(RC(JB,240)    *Y(JB,54 )*Y(JB,5  ))
     &+(RC(JB,243)    *Y(JB,55 )*Y(JB,5  ))          
     &+(RC(JB,228)    *Y(JB,37 )*Y(JB,5  ))
     &+(RC(JB,238)    *Y(JB,119)*Y(JB,5  ))          
     &+(RC(JB,227)    *Y(JB,36 )*Y(JB,5  ))
     &+(RC(JB,227)    *Y(JB,36 )*Y(JB,5  ))          
     &+(RC(JB,225)    *Y(JB,112)*Y(JB,5  ))
     &+(RC(JB,226)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,216)    *Y(JB,74 )*Y(JB,5  ))
     &+(RC(JB,221)    *Y(JB,44 )*Y(JB,5  ))          
     &+(RC(JB,207)    *Y(JB,33 )*Y(JB,5  ))
     &+(RC(JB,215)    *Y(JB,106)*Y(JB,5  ))          
     &+(RC(JB,205)    *Y(JB,31 )*Y(JB,5  )*2.00)                                 
     &+(RC(JB,162)    *Y(JB,56 )*Y(JB,8  ))
     &+(RC(JB,190)    *Y(JB,22 )*Y(JB,5  ))          
     &+(RC(JB,158)    *Y(JB,54 )*Y(JB,8  ))
     &+(RC(JB,160)    *Y(JB,55 )*Y(JB,8  ))          
     &+(RC(JB,145)    *Y(JB,37 )*Y(JB,8  ))
     &+(RC(JB,156)    *Y(JB,119)*Y(JB,8  ))          
     &+(RC(JB,144)    *Y(JB,36 )*Y(JB,8  ))
     &+(RC(JB,144)    *Y(JB,36 )*Y(JB,8  ))          
     &+(RC(JB,142)    *Y(JB,112)*Y(JB,8  ))
     &+(RC(JB,143)    *Y(JB,112)*Y(JB,8  ))          
     &+(RC(JB,133)    *Y(JB,74 )*Y(JB,8  ))
     &+(RC(JB,138)    *Y(JB,44 )*Y(JB,8  ))          
     &+(RC(JB,124)    *Y(JB,33 )*Y(JB,8  ))
     &+(RC(JB,132)    *Y(JB,106)*Y(JB,8  ))          
     &+(RC(JB,122)    *Y(JB,31 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,90)     *Y(JB,3  )*Y(JB,76 ))
     &+(RC(JB,107)    *Y(JB,22 )*Y(JB,8  ))          
     &+(RC(JB,71)     *Y(JB,53 )*Y(JB,6  ))
     &+(RC(JB,72)     *Y(JB,53 )*Y(JB,6  ))          
     &+(RC(JB,55)     *Y(JB,6  )*Y(JB,32 ))       
     &+(RC(JB,53)     *Y(JB,6  )*Y(JB,30 ))
     &+(RC(JB,54)     *Y(JB,6  )*Y(JB,30 ))
     &+(RC(JB,513)    *Y(JB,3  )*Y(JB,220))
     &+(RC(JB,515)    *Y(JB,5  )*Y(JB,220))
     &+(RC(JB,530)*Y(JB,6)*Y(JB,30))  
     &+(RC(JB,531)*Y(JB,6)*Y(JB,32)) 
     &+(RC(JB,532)*Y(JB,6)*Y(JB,32)) 
     &+(RC(JB,534)*Y(JB,6)*Y(JB,43)*2.00)
     &+(RC(JB,535)*Y(JB,6)*Y(JB,43))   
     &+(RC(JB,536)*Y(JB,6)*Y(JB,43))   
     &+(RC(JB,537)*Y(JB,6)*Y(JB,43)*2.00) 
     &+(RC(JB,538)*Y(JB,6)*Y(JB,43))  
     &+(RC(JB,539)*Y(JB,6)*Y(JB,43))
     &+(RC(JB,73)*Y(JB,6)*Y(JB,53))   
     &+(RC(JB,544)*Y(JB,6)*Y(JB,53)) 
     &+(RC(JB,545)*Y(JB,6)*Y(JB,46))    
     &+(RC(JB,546)*Y(JB,6)*Y(JB,46))    
     &+(RC(JB,555)*Y(JB,232)) 
     &+(RC(JB,560)*Y(JB,235))  
     &+(RC(JB,551)*Y(JB,46)*Y(JB,6))
     &+(RC(JB,550)*Y(JB,46)*Y(JB,6))      
      L = DD(JB,39)+DW(JB,39)
     &+(DJ(JB,10)     )                                                    
     &+(RC(JB,82)     *Y(JB,3  ))+(RC(JB,85)     *Y(JB,5  ))
     &+(DJ(JB,9)      )
     &+(RC(JB,525)    *Y(JB,224))	 
      Y(JB, 39) = (YP(JB, 39)+DTS*P)/(1.0+DTS*L)
C
C          HCOOH            Y(JB, 40)
      P = EM(JB, 40)
     &+(RC(JB,74)     *Y(JB,59 )*Y(JB,3  ))   
     &+(RC(JB,552)*Y(JB,230)*H2O(JB)*H2O(JB))     
      L = DD(JB,40)+DW(JB,40)
     &+(RC(JB,97)     *Y(JB,3  ))                                             
      Y(JB, 40) = (YP(JB, 40)+DTS*P)/(1.0+DTS*L)
C
C          CH3CO2H          Y(JB, 41)
      P = EM(JB, 41)
     &+(RC(JB,553)*Y(JB,231)*H2O(JB)) 
     &+(RC(JB,554)*Y(JB,231)*H2O(JB)*H2O(JB))        
      L = DD(JB,41)+DW(JB,41)
     &+(RC(JB,98)     *Y(JB,3  ))                                             
      Y(JB, 41) = (YP(JB, 41)+DTS*P)/(1.0+DTS*L)
C
C          CH3CHO           Y(JB, 42)
      P = EM(JB, 42)
     &+(DJ(JB,81)     *Y(JB,171)*2.00)                                        
     &+(DJ(JB,77)     *Y(JB,157))       +(DJ(JB,80)     *Y(JB,170))                 
     &+(DJ(JB,76)     *Y(JB,156)*2.00)                                        
     &+(DJ(JB,57)     *Y(JB,148))       +(DJ(JB,75)     *Y(JB,155))                 
     &+(DJ(JB,45)     *Y(JB,127))       +(DJ(JB,54)     *Y(JB,145))                 
     &+(DJ(JB,20)     *Y(JB,104))       +(DJ(JB,42)     *Y(JB,124))                 
     &+(RC(JB,474)    *Y(JB,3  )*Y(JB,199))+(DJ(JB,19)     *Y(JB,188))                 
     &+(RC(JB,449)    *Y(JB,3  )*Y(JB,170))
     &+(RC(JB,450)    *Y(JB,3  )*Y(JB,171)*2.00)     
     &+(RC(JB,393)    *Y(JB,3  )*Y(JB,124))
     &+(RC(JB,425)    *Y(JB,3  )*Y(JB,145))          
     &+(RC(JB,338)    *Y(JB,38 )*2.00)                                        
     &+(RC(JB,327)    *Y(JB,107))       +(RC(JB,337)    *Y(JB,37 ))                 
     &+(RC(JB,318)    *Y(JB,95 ))       +(RC(JB,326)    *Y(JB,75 ))                 
     &+(RC(JB,317)    *Y(JB,35 )*2.00)                                        
     &+(RC(JB,303)    *Y(JB,29 ))       +(RC(JB,316)    *Y(JB,33 ))                 
     &+(RC(JB,294)    *Y(JB,24 ))       +(RC(JB,295)    *Y(JB,24 ))                 
     &+(RC(JB,229)    *Y(JB,38 )*Y(JB,5  )*2.00)                                 
     &+(RC(JB,218)    *Y(JB,107)*Y(JB,5  ))
     &+(RC(JB,228)    *Y(JB,37 )*Y(JB,5  ))          
     &+(RC(JB,209)    *Y(JB,95 )*Y(JB,5  ))
     &+(RC(JB,217)    *Y(JB,75 )*Y(JB,5  ))          
     &+(RC(JB,207)    *Y(JB,33 )*Y(JB,5  ))
     &+(RC(JB,208)    *Y(JB,35 )*Y(JB,5  )*2.00)     
     &+(RC(JB,191)    *Y(JB,24 )*Y(JB,5  ))
     &+(RC(JB,194)    *Y(JB,29 )*Y(JB,5  ))          
     &+(RC(JB,146)    *Y(JB,38 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,135)    *Y(JB,107)*Y(JB,8  ))
     &+(RC(JB,145)    *Y(JB,37 )*Y(JB,8  ))          
     &+(RC(JB,126)    *Y(JB,95 )*Y(JB,8  ))
     &+(RC(JB,134)    *Y(JB,75 )*Y(JB,8  ))          
     &+(RC(JB,125)    *Y(JB,35 )*Y(JB,8  )*2.00)                                 
     &+(RC(JB,111)    *Y(JB,29 )*Y(JB,8  ))
     &+(RC(JB,124)    *Y(JB,33 )*Y(JB,8  ))          
     &+(RC(JB,91)     *Y(JB,3  )*Y(JB,77 ))
     &+(RC(JB,108)    *Y(JB,24 )*Y(JB,8  ))          
     &+(RC(JB,57)     *Y(JB,6  )*Y(JB,34 ))
     &+(RC(JB,58)     *Y(JB,6  )*Y(JB,34 ))       
     &+(RC(JB,56)     *Y(JB,6  )*Y(JB,32 ))      
     &+(RC(JB,533)     *Y(JB,6  )*Y(JB,34 ))       
      L = DD(JB,42)+DW(JB,42)
     &+(RC(JB,83)     *Y(JB,3  ))+(RC(JB,86)     *Y(JB,5  ))
     &+(DJ(JB,11)     )          
      Y(JB, 42) = (YP(JB, 42)+DTS*P)/(1.0+DTS*L)
C
C          C5H8             Y(JB, 43)
      P = EM(JB, 43)
      L = 0.0
     &+(RC(JB,62)     *Y(JB,6  ))                                             
     &+(RC(JB,59)     *Y(JB,3  ))+(RC(JB,60)     *Y(JB,5  ))
     &+(RC(JB,61)     *Y(JB,6  ))+(RC(JB,534)*Y(JB,6))   
     &+(RC(JB,535)*Y(JB,6)) +(RC(JB,536)*Y(JB,6))  
     &+(RC(JB,537)*Y(JB,6)) +(RC(JB,538)*Y(JB,6))     
     &+(RC(JB,539)*Y(JB,6))     
      Y(JB, 43) = (YP(JB, 43)+DTS*P)/(1.0+DTS*L)
C
C          RU14O2           Y(JB, 44)
      P = EM(JB, 44)
     &+(RC(JB,59)     *Y(JB,3  )*Y(JB,43 ))                                      
      L = 0.0
     &+(RC(JB,329)    )       +(RC(JB,330)    )                               
     &+(RC(JB,220)    *Y(JB,5  ))+(RC(JB,221)    *Y(JB,5  ))
     &+(RC(JB,271)    *Y(JB,9  ))   
     &+(RC(JB,137)    *Y(JB,8  ))+(RC(JB,138)    *Y(JB,8  ))
     &+(RC(JB,180)    *Y(JB,8  ))   
      Y(JB, 44) = (YP(JB, 44)+DTS*P)/(1.0+DTS*L)
C
C          NRU14O2          Y(JB, 45)
      P = EM(JB, 45)
     &+(RC(JB,60)     *Y(JB,5  )*Y(JB,43 ))                                      
      L = 0.0
     &+(RC(JB,339)    )                                                    
     &+(RC(JB,147)    *Y(JB,8  ))+(RC(JB,230)    *Y(JB,5  ))
     &+(RC(JB,277)    *Y(JB,9  ))   
      Y(JB, 45) = (YP(JB, 45)+DTS*P)/(1.0+DTS*L)
C
C          UCARB10          Y(JB, 46)
      P = EM(JB, 46)
     &+(DJ(JB,69)     *Y(JB,166))                                             
     &+(RC(JB,330)    *Y(JB,44 ))       
     &+(RC(JB,481)    *Y(JB,3  )*Y(JB,201))          
     &+(RC(JB,138)    *Y(JB,44 )*Y(JB,8  ))
     &+(RC(JB,221)    *Y(JB,44 )*Y(JB,5  ))          
     &+(RC(JB,61)     *Y(JB,6  )*Y(JB,43 ))
     &+(RC(JB,62)     *Y(JB,6  )*Y(JB,43 ))          
      L = DD(JB,46)+DW(JB,46)
     &+(RC(JB,363)    *Y(JB,6  ))+(DJ(JB,23)     )                               
     &+(RC(JB,360)    *Y(JB,3  ))+(RC(JB,361)    *Y(JB,5  ))
     &+(RC(JB,362)    *Y(JB,6  )) +(RC(JB,545)*Y(JB,6))
     &+(RC(JB,546)*Y(JB,6))+(RC(JB,547)*Y(JB,6))
     &+(RC(JB,550)*Y(JB,6))+(RC(JB,551)*Y(JB,6))     
      Y(JB, 46) = (YP(JB, 46)+DTS*P)/(1.0+DTS*L)
C
C          APINENE          Y(JB, 47)
      P = EM(JB, 47)
      L = 0.0
     &+(RC(JB,66)     *Y(JB,6  ))+(RC(JB,67)     *Y(JB,6  ))                        
     &+(RC(JB,63)     *Y(JB,3  ))+(RC(JB,64)     *Y(JB,5  ))
     &+(RC(JB,65)     *Y(JB,6  )) +(RC(JB,540)*Y(JB,6))
     &+(RC(JB,541)*Y(JB,6))+(RC(JB,542)*Y(JB,6))     
      Y(JB, 47) = (YP(JB, 47)+DTS*P)/(1.0+DTS*L)
C
C          RTN28O2          Y(JB, 48)
      P = EM(JB, 48)
     &+(RC(JB,63)     *Y(JB,47 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,232)    *Y(JB,5  ))+(RC(JB,279)    *Y(JB,9  ))
     &+(RC(JB,341)    )          
     &+(RC(JB,149)    *Y(JB,8  ))+(RC(JB,150)    *Y(JB,8  ))
     &+(RC(JB,185)    *Y(JB,8  ))   
      Y(JB, 48) = (YP(JB, 48)+DTS*P)/(1.0+DTS*L)
C
C          NRTN28O2         Y(JB, 49)
      P = EM(JB, 49)
     &+(RC(JB,64)     *Y(JB,47 )*Y(JB,5  ))                                      
      L = 0.0
     &+(RC(JB,342)    )                                                    
     &+(RC(JB,151)    *Y(JB,8  ))+(RC(JB,233)    *Y(JB,5  ))
     &+(RC(JB,280)    *Y(JB,9  ))   
      Y(JB, 49) = (YP(JB, 49)+DTS*P)/(1.0+DTS*L)
C
C          RTN26O2          Y(JB, 50)
      P = EM(JB, 50)
     &+(RC(JB,483)    *Y(JB,203))       
     &+(DJ(JB,39)     *Y(JB,51 ))                 
     &+(RC(JB,387)    *Y(JB,5  )*Y(JB,51 ))
     &+(RC(JB,455)    *Y(JB,3  )*Y(JB,176))          
     &+(RC(JB,65)     *Y(JB,47 )*Y(JB,6  ))
     &+(RC(JB,384)    *Y(JB,3  )*Y(JB,51 ))          
      L = 0.0
     &+(RC(JB,343)    )       +(RC(JB,482)    *Y(JB,4  ))                        
     &+(RC(JB,152)    *Y(JB,8  ))+(RC(JB,234)    *Y(JB,5  ))
     &+(RC(JB,281)    *Y(JB,9  ))   
      Y(JB, 50) = (YP(JB, 50)+DTS*P)/(1.0+DTS*L)
C
C          TNCARB26         Y(JB, 51)
      P = EM(JB, 51)
     &+(DJ(JB,85)     *Y(JB,174))       
     &+(DJ(JB,86)     *Y(JB,175))                 
     &+(RC(JB,454)    *Y(JB,3  )*Y(JB,174))
     &+(RC(JB,456)    *Y(JB,3  )*Y(JB,175))          
     &+(RC(JB,342)    *Y(JB,49 ))       
     &+(RC(JB,408)    *Y(JB,3  )*Y(JB,139))          
     &+(RC(JB,233)    *Y(JB,49 )*Y(JB,5  ))
     &+(RC(JB,341)    *Y(JB,48 ))                 
     &+(RC(JB,151)    *Y(JB,49 )*Y(JB,8  ))
     &+(RC(JB,232)    *Y(JB,48 )*Y(JB,5  ))          
     &+(RC(JB,66)     *Y(JB,47 )*Y(JB,6  ))
     &+(RC(JB,149)    *Y(JB,48 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,384)    *Y(JB,3  ))+(RC(JB,387)    *Y(JB,5  ))
     &+(DJ(JB,39)     )          
      Y(JB, 51) = (YP(JB, 51)+DTS*P)/(1.0+DTS*L)
C
C          RCOOH25          Y(JB, 52)
      P = EM(JB, 52)
     &+(RC(JB,490)    *Y(JB,206))                 
      L = 0.0
     &+(RC(JB,389)    *Y(JB,3  ))+(RC(JB,489)    )                               
      Y(JB, 52) = (YP(JB, 52)+DTS*P)/(1.0+DTS*L)
C
C          BPINENE          Y(JB, 53)
      P = EM(JB, 53)
      L = 0.0
     &+(RC(JB,71)     *Y(JB,6  ))+(RC(JB,72)     *Y(JB,6  ))
     &+(RC(JB,73)     *Y(JB,6  ))   
     &+(RC(JB,68)     *Y(JB,3  ))+(RC(JB,69)     *Y(JB,5  ))
     &+(RC(JB,70)     *Y(JB,6  )) +(RC(JB,543)*Y(JB,6))
     &+(RC(JB,544)*Y(JB,6))     
      Y(JB, 53) = (YP(JB, 53)+DTS*P)/(1.0+DTS*L)
C
C          RTX28O2          Y(JB, 54)
      P = EM(JB, 54)
     &+(RC(JB,68)     *Y(JB,53 )*Y(JB,3  ))
     &+(RC(JB,462)    *Y(JB,3  )*Y(JB,182))          
      L = 0.0
     &+(RC(JB,240)    *Y(JB,5  ))+(RC(JB,287)    *Y(JB,9  ))
     &+(RC(JB,349)    )          
     &+(RC(JB,158)    *Y(JB,8  ))+(RC(JB,159)    *Y(JB,8  ))
     &+(RC(JB,187)    *Y(JB,8  ))   
      Y(JB, 54) = (YP(JB, 54)+DTS*P)/(1.0+DTS*L)
C
C          NRTX28O2         Y(JB, 55)
      P = EM(JB, 55)
     &+(RC(JB,69)     *Y(JB,53 )*Y(JB,5  ))
     &+(RC(JB,465)    *Y(JB,3  )*Y(JB,185))          
      L = 0.0
     &+(RC(JB,352)    )                                                    
     &+(RC(JB,160)    *Y(JB,8  ))+(RC(JB,243)    *Y(JB,5  ))
     &+(RC(JB,290)    *Y(JB,9  ))   
      Y(JB, 55) = (YP(JB, 55)+DTS*P)/(1.0+DTS*L)
C
C          RTX24O2          Y(JB, 56)
      P = EM(JB, 56)
     &+(RC(JB,70)     *Y(JB,53 )*Y(JB,6  ))
     &+(RC(JB,390)    *Y(JB,3  )*Y(JB,57 ))   
     &+(RC(JB,543)*Y(JB,6)*Y(JB,53))     
      L = 0.0
     &+(RC(JB,241)    *Y(JB,5  ))+(RC(JB,288)    *Y(JB,9  ))
     &+(RC(JB,350)    )          
     &+(RC(JB,161)    *Y(JB,8  ))+(RC(JB,162)    *Y(JB,8  ))
     &+(RC(JB,188)    *Y(JB,8  ))   
      Y(JB, 56) = (YP(JB, 56)+DTS*P)/(1.0+DTS*L)
C
C          TXCARB24         Y(JB, 57)
      P = EM(JB, 57)
     &+(DJ(JB,96)     *Y(JB,185))                                             
     &+(RC(JB,410)    *Y(JB,3  )*Y(JB,141))+(DJ(JB,93)     *Y(JB,182))                 
     &+(RC(JB,349)    *Y(JB,54 ))       +(RC(JB,352)    *Y(JB,55 ))                 
     &+(RC(JB,240)    *Y(JB,54 )*Y(JB,5  ))
     &+(RC(JB,243)    *Y(JB,55 )*Y(JB,5  ))          
     &+(RC(JB,158)    *Y(JB,54 )*Y(JB,8  ))
     &+(RC(JB,160)    *Y(JB,55 )*Y(JB,8  ))          
     &+(RC(JB,71)     *Y(JB,53 )*Y(JB,6  ))       
      L = 0.0
     &+(RC(JB,390)    *Y(JB,3  ))                                             
      Y(JB, 57) = (YP(JB, 57)+DTS*P)/(1.0+DTS*L)
C
C          TXCARB22         Y(JB, 58)
      P = EM(JB, 58)
     &+(DJ(JB,52)     *Y(JB,142))       +(DJ(JB,94)     *Y(JB,183))                 
     &+(RC(JB,411)    *Y(JB,3  )*Y(JB,142))
     &+(RC(JB,463)    *Y(JB,3  )*Y(JB,183))          
     &+(RC(JB,241)    *Y(JB,56 )*Y(JB,5  ))
     &+(RC(JB,350)    *Y(JB,56 ))                 
     &+(RC(JB,72)     *Y(JB,53 )*Y(JB,6  ))
     &+(RC(JB,161)    *Y(JB,56 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,391)    *Y(JB,3  ))                                             
      Y(JB, 58) = (YP(JB, 58)+DTS*P)/(1.0+DTS*L)
C
C          C2H2             Y(JB, 59)
      P = EM(JB, 59)
      L = 0.0
     &+(RC(JB,74)     *Y(JB,3  ))+(RC(JB,75)     *Y(JB,3  ))                        
      Y(JB, 59) = (YP(JB, 59)+DTS*P)/(1.0+DTS*L)
C
C          CARB3            Y(JB, 60)
      P = EM(JB, 60)
     &+(DJ(JB,83)     *Y(JB,152))                                             
     &+(DJ(JB,50)     *Y(JB,137))       +(DJ(JB,82)     *Y(JB,151))                 
     &+(RC(JB,452)    *Y(JB,3  )*Y(JB,152))+(DJ(JB,49)     *Y(JB,136))                 
     &+(RC(JB,406)    *Y(JB,3  )*Y(JB,137))
     &+(RC(JB,451)    *Y(JB,3  )*Y(JB,151))          
     &+(RC(JB,311)    *Y(JB,69 ))       
     &+(RC(JB,405)    *Y(JB,3  )*Y(JB,136))          
     &+(RC(JB,308)    *Y(JB,65 ))       +(RC(JB,310)    *Y(JB,68 ))                 
     &+(RC(JB,203)    *Y(JB,68 )*Y(JB,5  ))
     &+(RC(JB,307)    *Y(JB,62 ))                 
     &+(RC(JB,200)    *Y(JB,62 )*Y(JB,5  ))
     &+(RC(JB,201)    *Y(JB,65 )*Y(JB,5  ))          
     &+(RC(JB,118)    *Y(JB,65 )*Y(JB,8  ))
     &+(RC(JB,120)    *Y(JB,68 )*Y(JB,8  ))          
     &+(RC(JB,75)     *Y(JB,59 )*Y(JB,3  ))
     &+(RC(JB,117)    *Y(JB,62 )*Y(JB,8  ))  
     &+(RC(JB,375)    *Y(JB,6  )*Y(JB,109))     
      L = 0.0
     &+(RC(JB,366)    *Y(JB,3  ))+(DJ(JB,24)     )                               
      Y(JB, 60) = (YP(JB, 60)+DTS*P)/(1.0+DTS*L)
C
C          BENZENE          Y(JB, 61)
      P = EM(JB, 61)
      L = 0.0
     &+(RC(JB,76)     *Y(JB,3  ))+(RC(JB,77)     *Y(JB,3  ))                        
      Y(JB, 61) = (YP(JB, 61)+DTS*P)/(1.0+DTS*L)
C
C          RA13O2           Y(JB, 62)
      P = EM(JB, 62)
     &+(RC(JB,76)     *Y(JB,61 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,253)    *Y(JB,9  ))+(RC(JB,307)    )                               
     &+(RC(JB,117)    *Y(JB,8  ))+(RC(JB,181)    *Y(JB,8  ))
     &+(RC(JB,200)    *Y(JB,5  ))   
      Y(JB, 62) = (YP(JB, 62)+DTS*P)/(1.0+DTS*L)
C
C          AROH14           Y(JB, 63)
      P = EM(JB, 63)
     &+(RC(JB,77)     *Y(JB,61 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,413)    *Y(JB,3  ))+(RC(JB,414)    *Y(JB,5  ))                        
      Y(JB, 63) = (YP(JB, 63)+DTS*P)/(1.0+DTS*L)
C
C          TOLUENE          Y(JB, 64)
      P = EM(JB, 64)
      L = 0.0
     &+(RC(JB,78)     *Y(JB,3  ))+(RC(JB,79)     *Y(JB,3  ))                        
      Y(JB, 64) = (YP(JB, 64)+DTS*P)/(1.0+DTS*L)
C
C          RA16O2           Y(JB, 65)
      P = EM(JB, 65)
     &+(RC(JB,78)     *Y(JB,64 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,308)    )       +(RC(JB,309)    )                               
     &+(RC(JB,201)    *Y(JB,5  ))+(RC(JB,202)    *Y(JB,5  ))
     &+(RC(JB,254)    *Y(JB,9  ))   
     &+(RC(JB,118)    *Y(JB,8  ))+(RC(JB,119)    *Y(JB,8  ))
     &+(RC(JB,182)    *Y(JB,8  ))   
      Y(JB, 65) = (YP(JB, 65)+DTS*P)/(1.0+DTS*L)
C
C          AROH17           Y(JB, 66)
      P = EM(JB, 66)
     &+(RC(JB,79)     *Y(JB,64 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,418)    *Y(JB,3  ))+(RC(JB,419)    *Y(JB,5  ))                        
      Y(JB, 66) = (YP(JB, 66)+DTS*P)/(1.0+DTS*L)
C
C          OXYL             Y(JB, 67)
      P = EM(JB, 67)
      L = 0.0
     &+(RC(JB,80)     *Y(JB,3  ))+(RC(JB,81)     *Y(JB,3  ))                        
      Y(JB, 67) = (YP(JB, 67)+DTS*P)/(1.0+DTS*L)
C
C          RA19AO2          Y(JB, 68)
      P = EM(JB, 68)
     &+(RC(JB,80)     *Y(JB,67 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,255)    *Y(JB,9  ))+(RC(JB,310)    )                               
     &+(RC(JB,120)    *Y(JB,8  ))+(RC(JB,183)    *Y(JB,8  ))
     &+(RC(JB,203)    *Y(JB,5  ))   
      Y(JB, 68) = (YP(JB, 68)+DTS*P)/(1.0+DTS*L)
C
C          RA19CO2          Y(JB, 69)
      P = EM(JB, 69)
     &+(RC(JB,81)     *Y(JB,67 )*Y(JB,3  ))                                      
      L = 0.0
     &+(RC(JB,256)    *Y(JB,9  ))+(RC(JB,311)    )                               
     &+(RC(JB,121)    *Y(JB,8  ))+(RC(JB,184)    *Y(JB,8  ))
     &+(RC(JB,204)    *Y(JB,5  ))   
      Y(JB, 69) = (YP(JB, 69)+DTS*P)/(1.0+DTS*L)
C
C          CH3CO3           Y(JB, 70)
      P = EM(JB, 70)
     &+(DJ(JB,71)     *Y(JB,168))                                             
     &+(DJ(JB,40)     *Y(JB,120)*2.00)                                        
     &+(DJ(JB,31)     *Y(JB,115))       +(DJ(JB,32)     *Y(JB,115))                 
     &+(DJ(JB,27)     *Y(JB,189))       +(DJ(JB,29)     *Y(JB,109))                 
     &+(DJ(JB,25)     *Y(JB,98 ))       +(DJ(JB,26)     *Y(JB,100)*2.00)            
     &+(DJ(JB,19)     *Y(JB,188))       +(DJ(JB,23)     *Y(JB,46 ))                 
     &+(DJ(JB,17)     *Y(JB,88 ))       +(DJ(JB,18)     *Y(JB,111))                 
     &+(DJ(JB,14)     *Y(JB,101))       +(DJ(JB,15)     *Y(JB,186))                 
     &+(RC(JB,468)    *Y(JB,198))       +(DJ(JB,13)     *Y(JB,73 ))                 
     &+(RC(JB,374)    *Y(JB,6  )*Y(JB,109))
     &+(RC(JB,431)    *Y(JB,3  )*Y(JB,159))          
     &+(RC(JB,362)    *Y(JB,6  )*Y(JB,46 ))
     &+(RC(JB,367)    *Y(JB,3  )*Y(JB,98 ))          
     &+(RC(JB,331)    *Y(JB,110))       +(RC(JB,333)    *Y(JB,112))                 
     &+(RC(JB,325)    *Y(JB,74 ))       +(RC(JB,326)    *Y(JB,75 ))                 
     &+(RC(JB,222)    *Y(JB,110)*Y(JB,5  ))
     &+(RC(JB,224)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,216)    *Y(JB,74 )*Y(JB,5  ))
     &+(RC(JB,217)    *Y(JB,75 )*Y(JB,5  ))          
     &+(RC(JB,139)    *Y(JB,110)*Y(JB,8  ))
     &+(RC(JB,141)    *Y(JB,112)*Y(JB,8  ))          
     &+(RC(JB,133)    *Y(JB,74 )*Y(JB,8  ))
     &+(RC(JB,134)    *Y(JB,75 )*Y(JB,8  ))          
     &+(RC(JB,83)     *Y(JB,3  )*Y(JB,42 ))
     &+(RC(JB,86)     *Y(JB,5  )*Y(JB,42 )) 
     &+(RC(JB,534)*Y(JB,6)*Y(JB,43))  
     &+(RC(JB,560)*Y(JB,235))        
      L = 0.0
     &+(RC(JB,322)    )       +(RC(JB,467)    *Y(JB,4  ))                        
     &+(RC(JB,130)    *Y(JB,8  ))+(RC(JB,213)    *Y(JB,5  ))
     &+(RC(JB,264)    *Y(JB,9  ))   
      Y(JB, 70) = (YP(JB, 70)+DTS*P)/(1.0+DTS*L)
C
C          C2H5CHO          Y(JB, 71)
      P = EM(JB, 71)
     &+(DJ(JB,78)     *Y(JB,158)*2.00)                                        
     &+(DJ(JB,55)     *Y(JB,146))       +(DJ(JB,77)     *Y(JB,157))                 
     &+(DJ(JB,21)     *Y(JB,105))       +(DJ(JB,43)     *Y(JB,125))                 
     &+(RC(JB,394)    *Y(JB,3  )*Y(JB,125))
     &+(RC(JB,426)    *Y(JB,3  )*Y(JB,146))          
     &+(RC(JB,318)    *Y(JB,95 ))       +(RC(JB,319)    *Y(JB,103)*2.00)            
     &+(RC(JB,297)    *Y(JB,27 ))       +(RC(JB,298)    *Y(JB,27 ))                 
     &+(RC(JB,210)    *Y(JB,103)*Y(JB,5  )*2.00)                                 
     &+(RC(JB,192)    *Y(JB,27 )*Y(JB,5  ))
     &+(RC(JB,209)    *Y(JB,95 )*Y(JB,5  ))          
     &+(RC(JB,126)    *Y(JB,95 )*Y(JB,8  ))
     &+(RC(JB,127)    *Y(JB,103)*Y(JB,8  )*2.00)     
     &+(RC(JB,93)     *Y(JB,78 )*Y(JB,3  ))
     &+(RC(JB,109)    *Y(JB,27 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,84)     *Y(JB,3  ))+(RC(JB,87)     *Y(JB,5  ))
     &+(DJ(JB,12)     )          
      Y(JB, 71) = (YP(JB, 71)+DTS*P)/(1.0+DTS*L)
C
C          C2H5CO3          Y(JB, 72)
      P = EM(JB, 72)
     &+(RC(JB,470)    *Y(JB,199))                                             
     &+(RC(JB,327)    *Y(JB,107))       
     &+(RC(JB,432)    *Y(JB,3  )*Y(JB,160))          
     &+(RC(JB,135)    *Y(JB,107)*Y(JB,8  ))
     &+(RC(JB,218)    *Y(JB,107)*Y(JB,5  ))          
     &+(RC(JB,84)     *Y(JB,3  )*Y(JB,71 ))
     &+(RC(JB,87)     *Y(JB,5  )*Y(JB,71 ))          
      L = 0.0
     &+(RC(JB,323)    )       +(RC(JB,469)    *Y(JB,4  ))                        
     &+(RC(JB,131)    *Y(JB,8  ))+(RC(JB,214)    *Y(JB,5  ))
     &+(RC(JB,265)    *Y(JB,9  ))   
      Y(JB, 72) = (YP(JB, 72)+DTS*P)/(1.0+DTS*L)
C
C          CH3COCH3         Y(JB, 73)
      P = EM(JB, 73)
     &+(DJ(JB,90)     *Y(JB,179))       +(DJ(JB,95)     *Y(JB,184))                 
     &+(DJ(JB,44)     *Y(JB,126))       +(DJ(JB,56)     *Y(JB,147))                 
     &+(RC(JB,464)    *Y(JB,3  )*Y(JB,184))
     &+(RC(JB,484)    *Y(JB,3  )*Y(JB,203))          
     &+(RC(JB,412)    *Y(JB,3  )*Y(JB,143))
     &+(RC(JB,427)    *Y(JB,3  )*Y(JB,147))          
     &+(RC(JB,395)    *Y(JB,3  )*Y(JB,126))
     &+(RC(JB,409)    *Y(JB,3  )*Y(JB,140))          
     &+(RC(JB,346)    *Y(JB,118))       +(RC(JB,351)    *Y(JB,122))                 
     &+(RC(JB,300)    *Y(JB,26 ))       +(RC(JB,301)    *Y(JB,26 ))                 
     &+(RC(JB,237)    *Y(JB,118)*Y(JB,5  ))
     &+(RC(JB,242)    *Y(JB,122)*Y(JB,5  ))          
     &+(RC(JB,163)    *Y(JB,122)*Y(JB,8  ))
     &+(RC(JB,193)    *Y(JB,26 )*Y(JB,5  ))          
     &+(RC(JB,159)    *Y(JB,54 )*Y(JB,8  ))
     &+(RC(JB,162)    *Y(JB,56 )*Y(JB,8  ))          
     &+(RC(JB,150)    *Y(JB,48 )*Y(JB,8  ))
     &+(RC(JB,155)    *Y(JB,118)*Y(JB,8  ))          
     &+(RC(JB,95)     *Y(JB,3  )*Y(JB,79 ))
     &+(RC(JB,110)    *Y(JB,26 )*Y(JB,8  ))          
      L = DD(JB,73)+DW(JB,73)
     &+(RC(JB,88)     *Y(JB,3  ))+(DJ(JB,13)     ) 
     &+(RC(JB,578)*SCI(JB))                              
      Y(JB, 73) = (YP(JB, 73)+DTS*P)/(1.0+DTS*L)
C
C          RN8O2            Y(JB, 74)
      P = EM(JB, 74)
     &+(DJ(JB,92)     *Y(JB,181))                                             
     &+(DJ(JB,28)     *Y(JB,190)*2.00)                                        
     &+(DJ(JB,21)     *Y(JB,105))       +(DJ(JB,27)     *Y(JB,189))                 
     &+(DJ(JB,16)     *Y(JB,187))       +(DJ(JB,20)     *Y(JB,104))                 
     &+(RC(JB,239)    *Y(JB,121)*Y(JB,5  ))+(RC(JB,348)    *Y(JB,121))                 
     &+(RC(JB,88)     *Y(JB,3  )*Y(JB,73 ))
     &+(RC(JB,157)    *Y(JB,121)*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,325)    )                                                    
     &+(RC(JB,133)    *Y(JB,8  ))+(RC(JB,216)    *Y(JB,5  ))
     &+(RC(JB,267)    *Y(JB,9  ))   
      Y(JB, 74) = (YP(JB, 74)+DTS*P)/(1.0+DTS*L)
C
C          RN11O2           Y(JB, 75)
      P = EM(JB, 75)
     &+(RC(JB,89)     *Y(JB,101)*Y(JB,3  ))
     &+(RC(JB,355)    *Y(JB,3  )*Y(JB,88 ))          
      L = 0.0
     &+(RC(JB,326)    )                                                    
     &+(RC(JB,134)    *Y(JB,8  ))+(RC(JB,217)    *Y(JB,5  ))
     &+(RC(JB,268)    *Y(JB,9  ))   
      Y(JB, 75) = (YP(JB, 75)+DTS*P)/(1.0+DTS*L)
C
C          CH3OH            Y(JB, 76)
      P = EM(JB, 76)
     &+(RC(JB,293)    *Y(JB,22 ))                                             
      L =DD(JB,76)+DW(JB,76)
     &+(RC(JB,90)     *Y(JB,3  ))                                             
      Y(JB, 76) = (YP(JB, 76)+DTS*P)/(1.0+DTS*L)
C
C          C2H5OH           Y(JB, 77)
      P = EM(JB, 77)
     &+(RC(JB,296)    *Y(JB,24 ))                                             
      L = DD(JB,77)+DW(JB,77)
     &+(RC(JB,91)     *Y(JB,3  ))+(RC(JB,92)     *Y(JB,3  ))                        
      Y(JB, 77) = (YP(JB, 77)+DTS*P)/(1.0+DTS*L)
C
C          NPROPOL          Y(JB, 78)
      P = EM(JB, 78)
     &+(RC(JB,299)    *Y(JB,27 ))                                             
      L = 0.0
     &+(RC(JB,93)     *Y(JB,3  ))+(RC(JB,94)     *Y(JB,3  ))                        
      Y(JB, 78) = (YP(JB, 78)+DTS*P)/(1.0+DTS*L)
C
C          IPROPOL          Y(JB, 79)
      P = EM(JB, 79)
     &+(RC(JB,302)    *Y(JB,26 ))                                             
      L = 0.0
     &+(RC(JB,95)     *Y(JB,3  ))+(RC(JB,96)     *Y(JB,3  ))                        
      Y(JB, 79) = (YP(JB, 79)+DTS*P)/(1.0+DTS*L)
C
C          CH3CL            Y(JB, 80)
      P = EM(JB, 80)
      L = 0.0
     &+(RC(JB,99)     *Y(JB,3  ))                                             
      Y(JB, 80) = (YP(JB, 80)+DTS*P)/(1.0+DTS*L)
C
C          CH2CL2           Y(JB, 81)
      P = EM(JB, 81)
      L = 0.0
     &+(RC(JB,100)    *Y(JB,3  ))                                             
      Y(JB, 81) = (YP(JB, 81)+DTS*P)/(1.0+DTS*L)
C
C          CHCL3            Y(JB, 82)
      P = EM(JB, 82)
      L = 0.0
     &+(RC(JB,101)    *Y(JB,3  ))                                             
      Y(JB, 82) = (YP(JB, 82)+DTS*P)/(1.0+DTS*L)
C
C          CH3CCL3          Y(JB, 83)
      P = EM(JB, 83)
      L = 0.0
     &+(RC(JB,102)    *Y(JB,3  ))                                             
      Y(JB, 83) = (YP(JB, 83)+DTS*P)/(1.0+DTS*L)
C
C          TCE              Y(JB, 84)
      P = EM(JB, 84)
      L = 0.0
     &+(RC(JB,103)    *Y(JB,3  ))                                             
      Y(JB, 84) = (YP(JB, 84)+DTS*P)/(1.0+DTS*L)
C
C          TRICLETH         Y(JB, 85)
      P = EM(JB, 85)
      L = 0.0
     &+(RC(JB,104)    *Y(JB,3  ))                                             
      Y(JB, 85) = (YP(JB, 85)+DTS*P)/(1.0+DTS*L)
C
C          CDICLETH         Y(JB, 86)
      P = EM(JB, 86)
      L = 0.0
     &+(RC(JB,105)    *Y(JB,3  ))                                             
      Y(JB, 86) = (YP(JB, 86)+DTS*P)/(1.0+DTS*L)
C
C          TDICLETH         Y(JB, 87)
      P = EM(JB, 87)
      L = 0.0
     &+(RC(JB,106)    *Y(JB,3  ))                                             
      Y(JB, 87) = (YP(JB, 87)+DTS*P)/(1.0+DTS*L)
C
C          CARB11A          Y(JB, 88)
      P = EM(JB, 88)
     &+(DJ(JB,58)     *Y(JB,148))                                             
     &+(RC(JB,428)    *Y(JB,3  )*Y(JB,148))
     &+(DJ(JB,46)     *Y(JB,127))                 
     &+(RC(JB,304)    *Y(JB,29 ))       
     &+(RC(JB,396)    *Y(JB,3  )*Y(JB,127))          
     &+(RC(JB,112)    *Y(JB,29 )*Y(JB,8  ))
     &+(RC(JB,195)    *Y(JB,29 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,355)    *Y(JB,3  ))+(DJ(JB,17)     )                               
      Y(JB, 88) = (YP(JB, 88)+DTS*P)/(1.0+DTS*L)
C
C          RN16O2           Y(JB, 89)
      P = EM(JB, 89)
     &+(RC(JB,359)    *Y(JB,3  )*Y(JB,105))
     &+(DJ(JB,67)     *Y(JB,165))                 
      L = 0.0
     &+(RC(JB,249)    *Y(JB,9  ))+(RC(JB,312)    )                               
     &+(RC(JB,113)    *Y(JB,8  ))+(RC(JB,171)    *Y(JB,8  ))
     &+(RC(JB,196)    *Y(JB,5  ))   
      Y(JB, 89) = (YP(JB, 89)+DTS*P)/(1.0+DTS*L)
C
C          RN15AO2          Y(JB, 90)
      P = EM(JB, 90)
     &+(DJ(JB,59)     *Y(JB,149))                                             
     &+(RC(JB,312)    *Y(JB,89 ))       
     &+(RC(JB,385)    *Y(JB,3  )*Y(JB,193))          
     &+(RC(JB,113)    *Y(JB,89 )*Y(JB,8  ))
     &+(RC(JB,196)    *Y(JB,89 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,262)    *Y(JB,9  ))+(RC(JB,320)    )                               
     &+(RC(JB,128)    *Y(JB,8  ))+(RC(JB,178)    *Y(JB,8  ))
     &+(RC(JB,211)    *Y(JB,5  ))   
      Y(JB, 90) = (YP(JB, 90)+DTS*P)/(1.0+DTS*L)
C
C          RN19O2           Y(JB, 91)
      P = EM(JB, 91)
     &+(RC(JB,150)    *Y(JB,48 )*Y(JB,8  ))
     &+(RC(JB,159)    *Y(JB,54 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,250)    *Y(JB,9  ))+(RC(JB,313)    )                               
     &+(RC(JB,114)    *Y(JB,8  ))+(RC(JB,172)    *Y(JB,8  ))
     &+(RC(JB,197)    *Y(JB,5  ))   
      Y(JB, 91) = (YP(JB, 91)+DTS*P)/(1.0+DTS*L)
C
C          RN18AO2          Y(JB, 92)
      P = EM(JB, 92)
     &+(RC(JB,313)    *Y(JB,91 ))       +(DJ(JB,60)     *Y(JB,150))                 
     &+(RC(JB,114)    *Y(JB,91 )*Y(JB,8  ))
     &+(RC(JB,197)    *Y(JB,91 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,263)    *Y(JB,9  ))+(RC(JB,321)    )                               
     &+(RC(JB,129)    *Y(JB,8  ))+(RC(JB,179)    *Y(JB,8  ))
     &+(RC(JB,212)    *Y(JB,5  ))   
      Y(JB, 92) = (YP(JB, 92)+DTS*P)/(1.0+DTS*L)
C
C          RN13AO2          Y(JB, 93)
      P = EM(JB, 93)
     &+(RC(JB,162)    *Y(JB,56 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,305)    )                                                    
     &+(RC(JB,115)    *Y(JB,8  ))+(RC(JB,198)    *Y(JB,5  ))
     &+(RC(JB,251)    *Y(JB,9  ))   
      Y(JB, 93) = (YP(JB, 93)+DTS*P)/(1.0+DTS*L)
C
C          RN16AO2          Y(JB, 94)
      P = EM(JB, 94)
     &+(RC(JB,328)    *Y(JB,108))                                             
     &+(RC(JB,136)    *Y(JB,108)*Y(JB,8  ))
     &+(RC(JB,219)    *Y(JB,108)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,306)    )                                                    
     &+(RC(JB,116)    *Y(JB,8  ))+(RC(JB,199)    *Y(JB,5  ))
     &+(RC(JB,252)    *Y(JB,9  ))   
      Y(JB, 94) = (YP(JB, 94)+DTS*P)/(1.0+DTS*L)
C
C          RN15O2           Y(JB, 95)
      P = EM(JB, 95)
     &+(DJ(JB,47)     *Y(JB,128))                                             
     &+(RC(JB,306)    *Y(JB,94 ))       
     &+(RC(JB,370)    *Y(JB,3  )*Y(JB,190))          
     &+(RC(JB,116)    *Y(JB,94 )*Y(JB,8  ))
     &+(RC(JB,199)    *Y(JB,94 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,260)    *Y(JB,9  ))+(RC(JB,318)    )                               
     &+(RC(JB,126)    *Y(JB,8  ))+(RC(JB,176)    *Y(JB,8  ))
     &+(RC(JB,209)    *Y(JB,5  ))   
      Y(JB, 95) = (YP(JB, 95)+DTS*P)/(1.0+DTS*L)
C
C          UDCARB8          Y(JB, 96)
      P = EM(JB, 96)
     &+(DJ(JB,49)     *Y(JB,136))       
     &+(DJ(JB,82)     *Y(JB,151))                 
     &+(RC(JB,405)    *Y(JB,3  )*Y(JB,136))
     &+(RC(JB,451)    *Y(JB,3  )*Y(JB,151))          
     &+(RC(JB,307)    *Y(JB,62 ))       
     &+(RC(JB,309)    *Y(JB,65 ))                 
     &+(RC(JB,202)    *Y(JB,65 )*Y(JB,5  ))
     &+(RC(JB,204)    *Y(JB,69 )*Y(JB,5  ))          
     &+(RC(JB,121)    *Y(JB,69 )*Y(JB,8  ))
     &+(RC(JB,200)    *Y(JB,62 )*Y(JB,5  ))          
     &+(RC(JB,117)    *Y(JB,62 )*Y(JB,8  ))
     &+(RC(JB,119)    *Y(JB,65 )*Y(JB,8  ))          
      L = 0.0
     &+(DJ(JB,34)     )                                                    
     &+(RC(JB,378)    *Y(JB,3  ))
     &+(RC(JB,379)    *Y(JB,3  ))+(DJ(JB,33)     )          
      Y(JB, 96) = (YP(JB, 96)+DTS*P)/(1.0+DTS*L)
C
C          UDCARB11         Y(JB, 97)
      P = EM(JB, 97)
     &+(DJ(JB,84)     *Y(JB,153))                                             
     &+(DJ(JB,51)     *Y(JB,138))       
     &+(DJ(JB,83)     *Y(JB,152))                 
     &+(RC(JB,453)    *Y(JB,3  )*Y(JB,153))
     &+(DJ(JB,50)     *Y(JB,137))                 
     &+(RC(JB,407)    *Y(JB,3  )*Y(JB,138))
     &+(RC(JB,452)    *Y(JB,3  )*Y(JB,152))          
     &+(RC(JB,308)    *Y(JB,65 ))       
     &+(RC(JB,406)    *Y(JB,3  )*Y(JB,137))          
     &+(RC(JB,118)    *Y(JB,65 )*Y(JB,8  ))
     &+(RC(JB,201)    *Y(JB,65 )*Y(JB,5  ))          
      L = 0.0
     &+(DJ(JB,36)     )                                                    
     &+(RC(JB,380)    *Y(JB,3  ))
     &+(RC(JB,381)    *Y(JB,3  ))+(DJ(JB,35)     )          
      Y(JB, 97) = (YP(JB, 97)+DTS*P)/(1.0+DTS*L)
C
C          CARB6            Y(JB, 98)
      P = EM(JB, 98)
     &+(DJ(JB,70)     *Y(JB,167))       
     &+(DJ(JB,84)     *Y(JB,153))                 
     &+(RC(JB,453)    *Y(JB,3  )*Y(JB,153))
     &+(DJ(JB,51)     *Y(JB,138))                 
     &+(RC(JB,407)    *Y(JB,3  )*Y(JB,138))
     &+(RC(JB,434)    *Y(JB,3  )*Y(JB,162))          
     &+(RC(JB,375)    *Y(JB,6  )*Y(JB,109))
     &+(RC(JB,377)    *Y(JB,3  )*Y(JB,115))          
     &+(RC(JB,356)    *Y(JB,3  )*Y(JB,111))
     &+(RC(JB,363)    *Y(JB,6  )*Y(JB,46 ))          
     &+(RC(JB,309)    *Y(JB,65 ))       
     &+(RC(JB,334)    *Y(JB,112))                 
     &+(RC(JB,202)    *Y(JB,65 )*Y(JB,5  ))
     &+(RC(JB,225)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,119)    *Y(JB,65 )*Y(JB,8  ))
     &+(RC(JB,142)    *Y(JB,112)*Y(JB,8  ))    
     &+(RC(JB,547)*Y(JB,46)*Y(JB,6)) 
       L = DD(JB,98)+DW(JB,98)
     &+(RC(JB,367)    *Y(JB,3  ))+(DJ(JB,25)     )                               
      Y(JB, 98) = (YP(JB, 98)+DTS*P)/(1.0+DTS*L)
C
C          UDCARB14         Y(JB, 99)
      P = EM(JB, 99)
     &+(RC(JB,310)    *Y(JB,68 ))       
     &+(RC(JB,311)    *Y(JB,69 ))                 
     &+(RC(JB,120)    *Y(JB,68 )*Y(JB,8  ))
     &+(RC(JB,203)    *Y(JB,68 )*Y(JB,5  ))          
      L = 0.0
     &+(DJ(JB,38)     )                                                    
     &+(RC(JB,382)    *Y(JB,3  ))
     &+(RC(JB,383)    *Y(JB,3  ))+(DJ(JB,37)     )          
      Y(JB, 99) = (YP(JB, 99)+DTS*P)/(1.0+DTS*L)
C
C          CARB9            Y(JB,100)
      P = EM(JB,100)
     &+(RC(JB,357)    *Y(JB,3  )*Y(JB,188))
     &+(RC(JB,435)    *Y(JB,3  )*Y(JB,163))          
     &+(RC(JB,121)    *Y(JB,69 )*Y(JB,8  ))
     &+(RC(JB,204)    *Y(JB,69 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,368)    *Y(JB,3  ))+(DJ(JB,26)     )                               
      Y(JB,100) = (YP(JB,100)+DTS*P)/(1.0+DTS*L)
C
C          MEK              Y(JB,101)
      P = EM(JB,101)
      L = DD(JB,101)+DW(JB,101)
     &+(RC(JB,89)     *Y(JB,3  ))+(DJ(JB,14)     )                               
      Y(JB,101) = (YP(JB,101)+DTS*P)/(1.0+DTS*L)
C
C          HOCH2CHO         Y(JB,102)
      P = EM(JB,102)
     &+(DJ(JB,71)     *Y(JB,168))                                             
     &+(DJ(JB,29)     *Y(JB,109))       
     &+(DJ(JB,70)     *Y(JB,167))                 
     &+(RC(JB,399)    *Y(JB,3  )*Y(JB,130))
     &+(RC(JB,443)    *Y(JB,3  )*Y(JB,154))          
     &+(RC(JB,374)    *Y(JB,6  )*Y(JB,109))        
     &+(RC(JB,332)    *Y(JB,110))       
     &+(RC(JB,333)    *Y(JB,112))                 
     &+(RC(JB,315)    *Y(JB,31 ))       
     &+(RC(JB,331)    *Y(JB,110))                 
     &+(RC(JB,222)    *Y(JB,110)*Y(JB,5  ))
     &+(RC(JB,224)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,141)    *Y(JB,112)*Y(JB,8  ))
     &+(RC(JB,206)    *Y(JB,31 )*Y(JB,5  ))          
     &+(RC(JB,123)    *Y(JB,31 )*Y(JB,8  ))
     &+(RC(JB,139)    *Y(JB,110)*Y(JB,8  )) 
     &+(RC(JB,548)*Y(JB,109)*Y(JB,6))
     &+(RC(JB,549)*Y(JB,109)*Y(JB,6))
      L = 0.0
     &+(RC(JB,364)    *Y(JB,3  ))
     &+(RC(JB,365)    *Y(JB,5  ))+(DJ(JB,22)     )          
      Y(JB,102) = (YP(JB,102)+DTS*P)/(1.0+DTS*L)
C
C          RN18O2           Y(JB,103)
      P = EM(JB,103)
     &+(DJ(JB,48)     *Y(JB,129))                                             
      L = 0.0
     &+(RC(JB,261)    *Y(JB,9  ))+(RC(JB,319)    )                               
     &+(RC(JB,127)    *Y(JB,8  ))+(RC(JB,177)    *Y(JB,8  ))
     &+(RC(JB,210)    *Y(JB,5  ))   
      Y(JB,103) = (YP(JB,103)+DTS*P)/(1.0+DTS*L)
C
C          CARB13           Y(JB,104)
      P = EM(JB,104)
     &+(RC(JB,446)    *Y(JB,3  )*Y(JB,157))                                      
     &+(RC(JB,416)    *Y(JB,3  )*Y(JB,195))
     &+(RC(JB,417)    *Y(JB,5  )*Y(JB,195))          
     &+(RC(JB,320)    *Y(JB,90 ))       
     &+(RC(JB,402)    *Y(JB,3  )*Y(JB,133))          
     &+(RC(JB,128)    *Y(JB,90 )*Y(JB,8  ))
     &+(RC(JB,211)    *Y(JB,90 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,358)    *Y(JB,3  ))+(DJ(JB,20)     )                               
      Y(JB,104) = (YP(JB,104)+DTS*P)/(1.0+DTS*L)
C
C          CARB16           Y(JB,105)
      P = EM(JB,105)
     &+(RC(JB,447)    *Y(JB,3  )*Y(JB,158))
     &+(RC(JB,484)    *Y(JB,3  )*Y(JB,203))          
     &+(RC(JB,421)    *Y(JB,3  )*Y(JB,197))
     &+(RC(JB,422)    *Y(JB,5  )*Y(JB,197))          
     &+(RC(JB,321)    *Y(JB,92 ))       
     &+(RC(JB,403)    *Y(JB,3  )*Y(JB,134))          
     &+(RC(JB,129)    *Y(JB,92 )*Y(JB,8  ))
     &+(RC(JB,212)    *Y(JB,92 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,359)    *Y(JB,3  ))+(DJ(JB,21)     )                               
      Y(JB,105) = (YP(JB,105)+DTS*P)/(1.0+DTS*L)
C
C          HOCH2CO3         Y(JB,106)
      P = EM(JB,106)
     &+(RC(JB,433)    *Y(JB,3  )*Y(JB,161))
     &+(RC(JB,472)    *Y(JB,200))                 
     &+(RC(JB,364)    *Y(JB,3  )*Y(JB,102))
     &+(RC(JB,365)    *Y(JB,5  )*Y(JB,102))          
      L = 0.0
     &+(RC(JB,324)    )       +(RC(JB,471)    *Y(JB,4  ))                        
     &+(RC(JB,132)    *Y(JB,8  ))+(RC(JB,215)    *Y(JB,5  ))
     &+(RC(JB,266)    *Y(JB,9  ))   
      Y(JB,106) = (YP(JB,106)+DTS*P)/(1.0+DTS*L)
C
C          RN14O2           Y(JB,107)
      P = EM(JB,107)
     &+(RC(JB,353)    *Y(JB,3  )*Y(JB,186))                                      
      L = 0.0
     &+(RC(JB,327)    )                                                    
     &+(RC(JB,135)    *Y(JB,8  ))+(RC(JB,218)    *Y(JB,5  ))
     &+(RC(JB,269)    *Y(JB,9  ))   
      Y(JB,107) = (YP(JB,107)+DTS*P)/(1.0+DTS*L)
C
C          RN17O2           Y(JB,108)
      P = EM(JB,108)
     &+(RC(JB,354)    *Y(JB,3  )*Y(JB,187))                                      
      L = 0.0
     &+(RC(JB,328)    )                                                    
     &+(RC(JB,136)    *Y(JB,8  ))+(RC(JB,219)    *Y(JB,5  ))
     &+(RC(JB,270)    *Y(JB,9  ))   
      Y(JB,108) = (YP(JB,108)+DTS*P)/(1.0+DTS*L)
C
C          UCARB12          Y(JB,109)
      P = EM(JB,109)
     &+(RC(JB,438)    *Y(JB,3  )*Y(JB,166))
     &+(DJ(JB,68)     *Y(JB,166))                 
     &+(RC(JB,329)    *Y(JB,44 ))       
     &+(RC(JB,404)    *Y(JB,3  )*Y(JB,135))          
     &+(RC(JB,137)    *Y(JB,44 )*Y(JB,8  ))
     &+(RC(JB,220)    *Y(JB,44 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,375)    *Y(JB,6  ))+(DJ(JB,29)     )                               
     &+(RC(JB,372)    *Y(JB,3  ))+(RC(JB,373)    *Y(JB,5  ))
     &+(RC(JB,374)    *Y(JB,6  ))  +(RC(JB,548)*Y(JB,6)) 
     &+(RC(JB,549)*Y(JB,6))
      Y(JB,109) = (YP(JB,109)+DTS*P)/(1.0+DTS*L)
C
C          RU12O2           Y(JB,110)
      P = EM(JB,110)
     &+(RC(JB,439)    *Y(JB,3  )*Y(JB,167))
     &+(RC(JB,477)    *Y(JB,201))                 
     &+(RC(JB,372)    *Y(JB,3  )*Y(JB,109))
     &+(RC(JB,373)    *Y(JB,5  )*Y(JB,109))          
      L = 0.0
     &+(RC(JB,332)    )       +(RC(JB,476)    *Y(JB,4  ))                        
     &+(RC(JB,223)    *Y(JB,5  ))+(RC(JB,272)    *Y(JB,9  ))
     &+(RC(JB,331)    )          
     &+(RC(JB,139)    *Y(JB,8  ))+(RC(JB,140)    *Y(JB,8  ))
     &+(RC(JB,222)    *Y(JB,5  ))   
      Y(JB,110) = (YP(JB,110)+DTS*P)/(1.0+DTS*L)
C
C          CARB7            Y(JB,111)
      P = EM(JB,111)
     &+(RC(JB,480)    *Y(JB,3  )*Y(JB,202))                                      
     &+(RC(JB,400)    *Y(JB,3  )*Y(JB,131))
     &+(RC(JB,444)    *Y(JB,3  )*Y(JB,155))          
     &+(RC(JB,332)    *Y(JB,110))       
     &+(RC(JB,335)    *Y(JB,112))                 
     &+(RC(JB,223)    *Y(JB,110)*Y(JB,5  ))
     &+(RC(JB,226)    *Y(JB,112)*Y(JB,5  ))          
     &+(RC(JB,140)    *Y(JB,110)*Y(JB,8  ))
     &+(RC(JB,143)    *Y(JB,112)*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,356)    *Y(JB,3  ))+(DJ(JB,18)     )                               
      Y(JB,111) = (YP(JB,111)+DTS*P)/(1.0+DTS*L)
C
C          RU10O2           Y(JB,112)
      P = EM(JB,112)
     &+(RC(JB,440)    *Y(JB,3  )*Y(JB,168))
     &+(RC(JB,479)    *Y(JB,202))                 
     &+(RC(JB,360)    *Y(JB,3  )*Y(JB,46 ))
     &+(RC(JB,361)    *Y(JB,5  )*Y(JB,46 ))          
      L = 0.0
     &+(RC(JB,335)    )       +(RC(JB,478)    *Y(JB,4  ))                        
     &+(RC(JB,273)    *Y(JB,9  ))+(RC(JB,333)    )       
     &+(RC(JB,334)    )          
     &+(RC(JB,224)    *Y(JB,5  ))+(RC(JB,225)    *Y(JB,5  ))
     &+(RC(JB,226)    *Y(JB,5  ))   
     &+(RC(JB,141)    *Y(JB,8  ))+(RC(JB,142)    *Y(JB,8  ))
     &+(RC(JB,143)    *Y(JB,8  ))   
      Y(JB,112) = (YP(JB,112)+DTS*P)/(1.0+DTS*L)
C
C          NUCARB12         Y(JB,113)
      P = EM(JB,113)
     &+(DJ(JB,72)     *Y(JB,172))                                             
     &+(RC(JB,339)    *Y(JB,45 ))       
     &+(RC(JB,441)    *Y(JB,3  )*Y(JB,172))          
     &+(RC(JB,147)    *Y(JB,45 )*Y(JB,8  ))
     &+(RC(JB,230)    *Y(JB,45 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,376)    *Y(JB,3  ))+(DJ(JB,30)     )                               
      Y(JB,113) = (YP(JB,113)+DTS*P)/(1.0+DTS*L)
C
C          NRU12O2          Y(JB,114)
      P = EM(JB,114)
     &+(RC(JB,376)    *Y(JB,3  )*Y(JB,113))                                      
      L = 0.0
     &+(RC(JB,340)    )                                                    
     &+(RC(JB,148)    *Y(JB,8  ))+(RC(JB,231)    *Y(JB,5  ))
     &+(RC(JB,278)    *Y(JB,9  ))   
      Y(JB,114) = (YP(JB,114)+DTS*P)/(1.0+DTS*L)
C
C          NOA              Y(JB,115)
      P = EM(JB,115)
     &+(DJ(JB,30)     *Y(JB,113))       
     &+(DJ(JB,73)     *Y(JB,173))                 
     &+(RC(JB,340)    *Y(JB,114))       
     &+(RC(JB,442)    *Y(JB,3  )*Y(JB,173))          
     &+(RC(JB,148)    *Y(JB,114)*Y(JB,8  ))
     &+(RC(JB,231)    *Y(JB,114)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,377)    *Y(JB,3  ))+(DJ(JB,31)     )      
     & +(DJ(JB,32)     )          
      Y(JB,115) = (YP(JB,115)+DTS*P)/(1.0+DTS*L)
C
C          RTN25O2          Y(JB,116)
      P = EM(JB,116)
     &+(RC(JB,457)    *Y(JB,3  )*Y(JB,177))+
     &(DJ(JB,87)     *Y(JB,176))                 
     &+(RC(JB,343)    *Y(JB,50 ))       
     &+(RC(JB,389)    *Y(JB,3  )*Y(JB,52 ))          
     &+(RC(JB,152)    *Y(JB,50 )*Y(JB,8  ))
     &+(RC(JB,234)    *Y(JB,50 )*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,282)    *Y(JB,9  ))+(RC(JB,344)    )                               
     &+(RC(JB,153)    *Y(JB,8  ))+(RC(JB,186)    *Y(JB,8  ))
     &+(RC(JB,235)    *Y(JB,5  ))   
      Y(JB,116) = (YP(JB,116)+DTS*P)/(1.0+DTS*L)
C
C          RTN24O2          Y(JB,117)
      P = EM(JB,117)
     &+(DJ(JB,88)     *Y(JB,177))                                             
     &+(RC(JB,344)    *Y(JB,116))       
     &+(RC(JB,458)    *Y(JB,3  )*Y(JB,178))          
     &+(RC(JB,153)    *Y(JB,116)*Y(JB,8  ))
     &+(RC(JB,235)    *Y(JB,116)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,345)    )                                                    
     &+(RC(JB,154)    *Y(JB,8  ))+(RC(JB,236)    *Y(JB,5  ))
     &+(RC(JB,283)    *Y(JB,9  ))   
      Y(JB,117) = (YP(JB,117)+DTS*P)/(1.0+DTS*L)
C
C          RTN23O2          Y(JB,118)
      P = EM(JB,118)
     &+(DJ(JB,89)     *Y(JB,178))                                             
     &+(RC(JB,345)    *Y(JB,117))       
     &+(RC(JB,459)    *Y(JB,3  )*Y(JB,179))          
     &+(RC(JB,154)    *Y(JB,117)*Y(JB,8  ))
     &+(RC(JB,236)    *Y(JB,117)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,346)    )                                                    
     &+(RC(JB,155)    *Y(JB,8  ))+(RC(JB,237)    *Y(JB,5  ))
     &+(RC(JB,284)    *Y(JB,9  ))   
      Y(JB,118) = (YP(JB,118)+DTS*P)/(1.0+DTS*L)
C
C          RTN14O2          Y(JB,119)
      P = EM(JB,119)
     &+(DJ(JB,90)     *Y(JB,179))                                             
     &+(RC(JB,346)    *Y(JB,118))       
     &+(RC(JB,460)    *Y(JB,3  )*Y(JB,180))          
     &+(RC(JB,155)    *Y(JB,118)*Y(JB,8  ))
     &+(RC(JB,237)    *Y(JB,118)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,347)    )                                                    
     &+(RC(JB,156)    *Y(JB,8  ))+(RC(JB,238)    *Y(JB,5  ))
     &+(RC(JB,285)    *Y(JB,9  ))   
      Y(JB,119) = (YP(JB,119)+DTS*P)/(1.0+DTS*L)
C
C          TNCARB10         Y(JB,120)
      P = EM(JB,120)
     &+(RC(JB,347)    *Y(JB,119))       
     &+(DJ(JB,91)     *Y(JB,180))                 
     &+(RC(JB,156)    *Y(JB,119)*Y(JB,8  ))
     &+(RC(JB,238)    *Y(JB,119)*Y(JB,5  ))          
      L = 0.0
     &+(RC(JB,386)    *Y(JB,3  ))+(RC(JB,388)    *Y(JB,5  ))
     &+(DJ(JB,40)     )          
      Y(JB,120) = (YP(JB,120)+DTS*P)/(1.0+DTS*L)
C
C          RTN10O2          Y(JB,121)
      P = EM(JB,121)
     &+(RC(JB,461)    *Y(JB,3  )*Y(JB,181))                                      
     &+(RC(JB,386)    *Y(JB,3  )*Y(JB,120))
     &+(RC(JB,388)    *Y(JB,5  )*Y(JB,120))          
      L = 0.0
     &+(RC(JB,348)    )                                                    
     &+(RC(JB,157)    *Y(JB,8  ))+(RC(JB,239)    *Y(JB,5  ))
     &+(RC(JB,286)    *Y(JB,9  ))   
      Y(JB,121) = (YP(JB,121)+DTS*P)/(1.0+DTS*L)
C
C          RTX22O2          Y(JB,122)
      P = EM(JB,122)
     &+(RC(JB,391)    *Y(JB,3  )*Y(JB,58 ))                                      
      L = 0.0
     &+(RC(JB,289)    *Y(JB,9  ))+(RC(JB,351)    )                               
     &+(RC(JB,163)    *Y(JB,8  ))+(RC(JB,189)    *Y(JB,8  ))
     &+(RC(JB,242)    *Y(JB,5  ))   
      Y(JB,122) = (YP(JB,122)+DTS*P)/(1.0+DTS*L)
C
C          CH3NO3           Y(JB,123)
      P = EM(JB,123)
     &+(RC(JB,166)    *Y(JB,22 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,392)    *Y(JB,3  ))+(DJ(JB,41)     )                               
      Y(JB,123) = (YP(JB,123)+DTS*P)/(1.0+DTS*L)
C
C          C2H5NO3          Y(JB,124)
      P = EM(JB,124)
     &+(RC(JB,167)    *Y(JB,24 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,393)    *Y(JB,3  ))+(DJ(JB,42)     )                               
      Y(JB,124) = (YP(JB,124)+DTS*P)/(1.0+DTS*L)
C
C          RN10NO3          Y(JB,125)
      P = EM(JB,125)
     &+(RC(JB,168)    *Y(JB,27 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,394)    *Y(JB,3  ))+(DJ(JB,43)     )                               
      Y(JB,125) = (YP(JB,125)+DTS*P)/(1.0+DTS*L)
C
C          IC3H7NO3         Y(JB,126)
      P = EM(JB,126)
     &+(RC(JB,169)    *Y(JB,26 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,395)    *Y(JB,3  ))+(DJ(JB,44)     )                               
      Y(JB,126) = (YP(JB,126)+DTS*P)/(1.0+DTS*L)
C
C          RN13NO3          Y(JB,127)
      P = EM(JB,127)
     &+(RC(JB,170)    *Y(JB,29 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,396)    *Y(JB,3  ))+(DJ(JB,45)     )       
     &+(DJ(JB,46)     )          
      Y(JB,127) = (YP(JB,127)+DTS*P)/(1.0+DTS*L)
C
C          RN16NO3          Y(JB,128)
      P = EM(JB,128)
     &+(RC(JB,171)    *Y(JB,89 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,397)    *Y(JB,3  ))+(DJ(JB,47)     )                               
      Y(JB,128) = (YP(JB,128)+DTS*P)/(1.0+DTS*L)
C
C          RN19NO3          Y(JB,129)
      P = EM(JB,129)
     &+(RC(JB,172)    *Y(JB,91 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,398)    *Y(JB,3  ))+(DJ(JB,48)     )                               
      Y(JB,129) = (YP(JB,129)+DTS*P)/(1.0+DTS*L)
C
C          HOC2H4NO3        Y(JB,130)
      P = EM(JB,130)
     &+(RC(JB,173)    *Y(JB,31 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,399)    *Y(JB,3  ))                                             
      Y(JB,130) = (YP(JB,130)+DTS*P)/(1.0+DTS*L)
C
C          RN9NO3           Y(JB,131)
      P = EM(JB,131)
     &+(RC(JB,174)    *Y(JB,33 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,400)    *Y(JB,3  ))                                             
      Y(JB,131) = (YP(JB,131)+DTS*P)/(1.0+DTS*L)
C
C          RN12NO3          Y(JB,132)
      P = EM(JB,132)
     &+(RC(JB,175)    *Y(JB,35 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,401)    *Y(JB,3  ))                                             
      Y(JB,132) = (YP(JB,132)+DTS*P)/(1.0+DTS*L)
C
C          RN15NO3          Y(JB,133)
      P = EM(JB,133)
     &+(RC(JB,176)    *Y(JB,95 )*Y(JB,8  ))
     &+(RC(JB,178)    *Y(JB,90 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,402)    *Y(JB,3  ))                                             
      Y(JB,133) = (YP(JB,133)+DTS*P)/(1.0+DTS*L)
C
C          RN18NO3          Y(JB,134)
      P = EM(JB,134)
     &+(RC(JB,177)    *Y(JB,103)*Y(JB,8  ))
     &+(RC(JB,179)    *Y(JB,92 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,403)    *Y(JB,3  ))                                             
      Y(JB,134) = (YP(JB,134)+DTS*P)/(1.0+DTS*L)
C
C          RU14NO3          Y(JB,135)
      P = EM(JB,135)
     &+(RC(JB,180)    *Y(JB,44 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,404)    *Y(JB,3  ))                                             
      Y(JB,135) = (YP(JB,135)+DTS*P)/(1.0+DTS*L)
C
C          RA13NO3          Y(JB,136)
      P = EM(JB,136)
     &+(RC(JB,181)    *Y(JB,62 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,405)    *Y(JB,3  ))+(DJ(JB,49)     )                               
      Y(JB,136) = (YP(JB,136)+DTS*P)/(1.0+DTS*L)
C
C          RA16NO3          Y(JB,137)
      P = EM(JB,137)
     &+(RC(JB,182)    *Y(JB,65 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,406)    *Y(JB,3  ))+(DJ(JB,50)     )                               
      Y(JB,137) = (YP(JB,137)+DTS*P)/(1.0+DTS*L)
C
C          RA19NO3          Y(JB,138)
      P = EM(JB,138)
     &+(RC(JB,183)    *Y(JB,68 )*Y(JB,8  ))
     &+(RC(JB,184)    *Y(JB,69 )*Y(JB,8  ))          
      L = 0.0
     &+(RC(JB,407)    *Y(JB,3  ))+(DJ(JB,51)     )                               
      Y(JB,138) = (YP(JB,138)+DTS*P)/(1.0+DTS*L)
C
C          RTN28NO3         Y(JB,139)
      P = EM(JB,139)
     &+(RC(JB,185)    *Y(JB,48 )*Y(JB,8  ))
     &+(RC(JB,486)    *Y(JB,204))                 
      L = 0.0
     &+(RC(JB,408)    *Y(JB,3  ))+(RC(JB,485)    )                               
      Y(JB,139) = (YP(JB,139)+DTS*P)/(1.0+DTS*L)
C
C          RTN25NO3         Y(JB,140)
      P = EM(JB,140)
     &+(RC(JB,186)    *Y(JB,116)*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,409)    *Y(JB,3  ))                                             
      Y(JB,140) = (YP(JB,140)+DTS*P)/(1.0+DTS*L)
C
C          RTX28NO3         Y(JB,141)
      P = EM(JB,141)
     &+(RC(JB,187)    *Y(JB,54 )*Y(JB,8  ))
     &+(RC(JB,488)    *Y(JB,205))                 
      L = 0.0
     &+(RC(JB,410)    *Y(JB,3  ))+(RC(JB,487)    )                               
      Y(JB,141) = (YP(JB,141)+DTS*P)/(1.0+DTS*L)
C
C          RTX24NO3         Y(JB,142)
      P = EM(JB,142)
     &+(RC(JB,188)    *Y(JB,56 )*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,411)    *Y(JB,3  ))+(DJ(JB,52)     )                               
      Y(JB,142) = (YP(JB,142)+DTS*P)/(1.0+DTS*L)
C
C          RTX22NO3         Y(JB,143)
      P = EM(JB,143)
     &+(RC(JB,189)    *Y(JB,122)*Y(JB,8  ))                                      
      L = 0.0
     &+(RC(JB,412)    *Y(JB,3  ))                                             
      Y(JB,143) = (YP(JB,143)+DTS*P)/(1.0+DTS*L)
C
C          CH3OOH           Y(JB,144)
      P = EM(JB,144)
     &+(RC(JB,244)    *Y(JB,22 )*Y(JB,9  ))                                      
      L = DD(JB,144)+DW(JB,144)
     &+(RC(JB,423)    *Y(JB,3  ))+(RC(JB,424)    *Y(JB,3  ))
     &+(DJ(JB,53)     )          
      Y(JB,144) = (YP(JB,144)+DTS*P)/(1.0+DTS*L)
C
C          C2H5OOH          Y(JB,145)
      P = EM(JB,145)
     &+(RC(JB,245)    *Y(JB,24 )*Y(JB,9  ))                                      
      L = DD(JB,145)+DW(JB,145)
     &+(RC(JB,425)    *Y(JB,3  ))+(DJ(JB,54)     )                               
      Y(JB,145) = (YP(JB,145)+DTS*P)/(1.0+DTS*L)
C
C          RN10OOH          Y(JB,146)
      P = EM(JB,146)
     &+(RC(JB,246)    *Y(JB,27 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,426)    *Y(JB,3  ))+(DJ(JB,55)     )                               
      Y(JB,146) = (YP(JB,146)+DTS*P)/(1.0+DTS*L)
C
C          IC3H7OOH         Y(JB,147)
      P = EM(JB,147)
     &+(RC(JB,247)    *Y(JB,26 )*Y(JB,9  ))                                      
      L = DD(JB,147)+DW(JB,147)
     &+(RC(JB,427)    *Y(JB,3  ))+(DJ(JB,56)     )                               
      Y(JB,147) = (YP(JB,147)+DTS*P)/(1.0+DTS*L)
C
C          RN13OOH          Y(JB,148)
      P = EM(JB,148)
     &+(RC(JB,248)    *Y(JB,29 )*Y(JB,9  ))
     &+(RC(JB,251)    *Y(JB,93 )*Y(JB,9  ))          
      L = 0.0
     &+(RC(JB,428)    *Y(JB,3  ))+(DJ(JB,57)     )       
     &+(DJ(JB,58)     )          
      Y(JB,148) = (YP(JB,148)+DTS*P)/(1.0+DTS*L)
C
C          RN16OOH          Y(JB,149)
      P = EM(JB,149)
     &+(RC(JB,249)    *Y(JB,89 )*Y(JB,9  ))
     &+(RC(JB,252)    *Y(JB,94 )*Y(JB,9  ))          
      L = 0.0
     &+(RC(JB,429)    *Y(JB,3  ))+(DJ(JB,59)     )                               
      Y(JB,149) = (YP(JB,149)+DTS*P)/(1.0+DTS*L)
C
C          RN19OOH          Y(JB,150)
      P = EM(JB,150)
     &+(RC(JB,250)    *Y(JB,91 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,430)    *Y(JB,3  ))+(DJ(JB,60)     )                               
      Y(JB,150) = (YP(JB,150)+DTS*P)/(1.0+DTS*L)
C
C          RA13OOH          Y(JB,151)
      P = EM(JB,151)
     &+(RC(JB,253)    *Y(JB,62 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,451)    *Y(JB,3  ))+(DJ(JB,82)     )                               
      Y(JB,151) = (YP(JB,151)+DTS*P)/(1.0+DTS*L)
C
C          RA16OOH          Y(JB,152)
      P = EM(JB,152)
     &+(RC(JB,254)    *Y(JB,65 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,452)    *Y(JB,3  ))+(DJ(JB,83)     )                               
      Y(JB,152) = (YP(JB,152)+DTS*P)/(1.0+DTS*L)
C
C          RA19OOH          Y(JB,153)
      P = EM(JB,153)
     &+(RC(JB,255)    *Y(JB,68 )*Y(JB,9  ))
     &+(RC(JB,256)    *Y(JB,69 )*Y(JB,9  ))          
      L = 0.0
     &+(RC(JB,453)    *Y(JB,3  ))+(DJ(JB,84)     )                               
      Y(JB,153) = (YP(JB,153)+DTS*P)/(1.0+DTS*L)
C
C          HOC2H4OOH        Y(JB,154)
      P = EM(JB,154)
     &+(RC(JB,257)    *Y(JB,31 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,443)    *Y(JB,3  ))+(DJ(JB,74)     )                               
      Y(JB,154) = (YP(JB,154)+DTS*P)/(1.0+DTS*L)
C
C          RN9OOH           Y(JB,155)
      P = EM(JB,155)
     &+(RC(JB,258)    *Y(JB,33 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,444)    *Y(JB,3  ))+(DJ(JB,75)     )                               
      Y(JB,155) = (YP(JB,155)+DTS*P)/(1.0+DTS*L)
C
C          RN12OOH          Y(JB,156)
      P = EM(JB,156)
     &+(RC(JB,259)    *Y(JB,35 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,445)    *Y(JB,3  ))+(DJ(JB,76)     )                               
      Y(JB,156) = (YP(JB,156)+DTS*P)/(1.0+DTS*L)
C
C          RN15OOH          Y(JB,157)
      P = EM(JB,157)
     &+(RC(JB,260)    *Y(JB,95 )*Y(JB,9  ))
     &+(RC(JB,262)    *Y(JB,90 )*Y(JB,9  ))          
      L = 0.0
     &+(RC(JB,446)    *Y(JB,3  ))+(DJ(JB,77)     )                               
      Y(JB,157) = (YP(JB,157)+DTS*P)/(1.0+DTS*L)
C
C          RN18OOH          Y(JB,158)
      P = EM(JB,158)
     &+(RC(JB,261)    *Y(JB,103)*Y(JB,9  ))
     &+(RC(JB,263)    *Y(JB,92 )*Y(JB,9  ))          
      L = 0.0
     &+(RC(JB,447)    *Y(JB,3  ))+(DJ(JB,78)     )                               
      Y(JB,158) = (YP(JB,158)+DTS*P)/(1.0+DTS*L)
C
C          CH3CO3H          Y(JB,159)
      P = EM(JB,159)
     &+(RC(JB,264)    *Y(JB,70 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,431)    *Y(JB,3  ))+(DJ(JB,61)     )                               
      Y(JB,159) = (YP(JB,159)+DTS*P)/(1.0+DTS*L)
C
C          C2H5CO3H         Y(JB,160)
      P = EM(JB,160)
     &+(RC(JB,265)    *Y(JB,72 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,432)    *Y(JB,3  ))+(DJ(JB,62)     )                               
      Y(JB,160) = (YP(JB,160)+DTS*P)/(1.0+DTS*L)
C
C          HOCH2CO3H        Y(JB,161)
      P = EM(JB,161)
     &+(RC(JB,266)    *Y(JB,106)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,433)    *Y(JB,3  ))+(DJ(JB,63)     )                               
      Y(JB,161) = (YP(JB,161)+DTS*P)/(1.0+DTS*L)
C
C          RN8OOH           Y(JB,162)
      P = EM(JB,162)
     &+(RC(JB,267)    *Y(JB,74 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,434)    *Y(JB,3  ))+(DJ(JB,64)     )                               
      Y(JB,162) = (YP(JB,162)+DTS*P)/(1.0+DTS*L)
C
C          RN11OOH          Y(JB,163)
      P = EM(JB,163)
     &+(RC(JB,268)    *Y(JB,75 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,435)    *Y(JB,3  ))+(DJ(JB,65)     )                               
      Y(JB,163) = (YP(JB,163)+DTS*P)/(1.0+DTS*L)
C
C          RN14OOH          Y(JB,164)
      P = EM(JB,164)
     &+(RC(JB,269)    *Y(JB,107)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,436)    *Y(JB,3  ))+(DJ(JB,66)     )                               
      Y(JB,164) = (YP(JB,164)+DTS*P)/(1.0+DTS*L)
C
C          RN17OOH          Y(JB,165)
      P = EM(JB,165)
     &+(RC(JB,270)    *Y(JB,108)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,437)    *Y(JB,3  ))+(DJ(JB,67)     )                               
      Y(JB,165) = (YP(JB,165)+DTS*P)/(1.0+DTS*L)
C
C          RU14OOH          Y(JB,166)
      P = EM(JB,166)
     &+(RC(JB,271)    *Y(JB,44 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,438)    *Y(JB,3  ))+(DJ(JB,68)     )       
     &+(DJ(JB,69)     )          
      Y(JB,166) = (YP(JB,166)+DTS*P)/(1.0+DTS*L)
C
C          RU12OOH          Y(JB,167)
      P = EM(JB,167)
     &+(RC(JB,272)    *Y(JB,110)*Y(JB,9  ))
     &+(RC(JB,512)    *Y(JB,219))                                     
      L = 0.0
     &+(RC(JB,439)    *Y(JB,3  ))+(DJ(JB,70)     )  
     &+(RC(JB,511)    )                             
      Y(JB,167) = (YP(JB,167)+DTS*P)/(1.0+DTS*L)
C
C          RU10OOH          Y(JB,168)
      P = EM(JB,168)
     &+(RC(JB,273)    *Y(JB,112)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,440)    *Y(JB,3  ))+(DJ(JB,71)     )                               
      Y(JB,168) = (YP(JB,168)+DTS*P)/(1.0+DTS*L)
C
C          NRN6OOH          Y(JB,169)
      P = EM(JB,169)
     &+(RC(JB,274)    *Y(JB,36 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,448)    *Y(JB,3  ))+(DJ(JB,79)     )                               
      Y(JB,169) = (YP(JB,169)+DTS*P)/(1.0+DTS*L)
C
C          NRN9OOH          Y(JB,170)
      P = EM(JB,170)
     &+(RC(JB,275)    *Y(JB,37 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,449)    *Y(JB,3  ))+(DJ(JB,80)     )                               
      Y(JB,170) = (YP(JB,170)+DTS*P)/(1.0+DTS*L)
C
C          NRN12OOH         Y(JB,171)
      P = EM(JB,171)
     &+(RC(JB,276)    *Y(JB,38 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,450)    *Y(JB,3  ))+(DJ(JB,81)     )                               
      Y(JB,171) = (YP(JB,171)+DTS*P)/(1.0+DTS*L)
C
C          NRU14OOH         Y(JB,172)
      P = EM(JB,172)
     &+(RC(JB,277)    *Y(JB,45 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,441)    *Y(JB,3  ))+(DJ(JB,72)     )                               
      Y(JB,172) = (YP(JB,172)+DTS*P)/(1.0+DTS*L)
C
C          NRU12OOH         Y(JB,173)
      P = EM(JB,173)
     &+(RC(JB,278)    *Y(JB,114)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,442)    *Y(JB,3  ))+(DJ(JB,73)     )                               
      Y(JB,173) = (YP(JB,173)+DTS*P)/(1.0+DTS*L)
C
C          RTN28OOH         Y(JB,174)
      P = EM(JB,174)
     &+(RC(JB,279)    *Y(JB,48 )*Y(JB,9  ))
     &+(RC(JB,496)    *Y(JB,209))                 
      L = 0.0
     &+(RC(JB,454)    *Y(JB,3  ))+(RC(JB,495)    )       
     &+(DJ(JB,85)     )          
      Y(JB,174) = (YP(JB,174)+DTS*P)/(1.0+DTS*L)
C
C          NRTN28OOH        Y(JB,175)
      P = EM(JB,175)
     &+(RC(JB,280)    *Y(JB,49 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,456)    *Y(JB,3  ))+(DJ(JB,86)     )                               
      Y(JB,175) = (YP(JB,175)+DTS*P)/(1.0+DTS*L)
C
C          RTN26OOH         Y(JB,176)
      P = EM(JB,176)
     &+(RC(JB,281)    *Y(JB,50 )*Y(JB,9  ))+(RC(JB,498)    *Y(JB,210))                 
      L = 0.0
     &+(RC(JB,455)    *Y(JB,3  ))+(RC(JB,497)    )       
     &+(DJ(JB,87)     )          
      Y(JB,176) = (YP(JB,176)+DTS*P)/(1.0+DTS*L)
C
C          RTN25OOH         Y(JB,177)
      P = EM(JB,177)
     &+(RC(JB,282)    *Y(JB,116)*Y(JB,9  ))+(RC(JB,502)    *Y(JB,212))                 
      L = 0.0
     &+(RC(JB,457)    *Y(JB,3  ))+(RC(JB,501)    )       
     &+(DJ(JB,88)     )          
      Y(JB,177) = (YP(JB,177)+DTS*P)/(1.0+DTS*L)
C
C          RTN24OOH         Y(JB,178)
      P = EM(JB,178)
     &+(RC(JB,283)    *Y(JB,117)*Y(JB,9  ))+(RC(JB,492)    *Y(JB,207))                 
      L = 0.0
     &+(RC(JB,458)    *Y(JB,3  ))+(RC(JB,491)    )       
     &+(DJ(JB,89)     )          
      Y(JB,178) = (YP(JB,178)+DTS*P)/(1.0+DTS*L)
C
C          RTN23OOH         Y(JB,179)
      P = EM(JB,179)
     &+(RC(JB,284)    *Y(JB,118)*Y(JB,9  ))+(RC(JB,504)    *Y(JB,213))                 
      L = 0.0
     &+(RC(JB,459)    *Y(JB,3  ))+(RC(JB,503)    )       
     &+(DJ(JB,90)     )          
      Y(JB,179) = (YP(JB,179)+DTS*P)/(1.0+DTS*L)
C
C          RTN14OOH         Y(JB,180)
      P = EM(JB,180)
     &+(RC(JB,285)    *Y(JB,119)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,460)    *Y(JB,3  ))+(DJ(JB,91)     )                               
      Y(JB,180) = (YP(JB,180)+DTS*P)/(1.0+DTS*L)
C
C          RTN10OOH         Y(JB,181)
      P = EM(JB,181)
     &+(RC(JB,286)    *Y(JB,121)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,461)    *Y(JB,3  ))+(DJ(JB,92)     )                               
      Y(JB,181) = (YP(JB,181)+DTS*P)/(1.0+DTS*L)
C
C          RTX28OOH         Y(JB,182)
      P = EM(JB,182)
     &+(RC(JB,287)    *Y(JB,54 )*Y(JB,9  ))+(RC(JB,494)    *Y(JB,208))                 
      L = 0.0
     &+(RC(JB,462)    *Y(JB,3  ))+(RC(JB,493)    )       
     &+(DJ(JB,93)     )          
      Y(JB,182) = (YP(JB,182)+DTS*P)/(1.0+DTS*L)
C
C          RTX24OOH         Y(JB,183)
      P = EM(JB,183)
     &+(RC(JB,288)    *Y(JB,56 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,463)    *Y(JB,3  ))+(DJ(JB,94)     )                               
      Y(JB,183) = (YP(JB,183)+DTS*P)/(1.0+DTS*L)
C
C          RTX22OOH         Y(JB,184)
      P = EM(JB,184)
     &+(RC(JB,289)    *Y(JB,122)*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,464)    *Y(JB,3  ))+(DJ(JB,95)     )                               
      Y(JB,184) = (YP(JB,184)+DTS*P)/(1.0+DTS*L)
C
C          NRTX28OOH        Y(JB,185)
      P = EM(JB,185)
     &+(RC(JB,290)    *Y(JB,55 )*Y(JB,9  ))                                      
      L = 0.0
     &+(RC(JB,465)    *Y(JB,3  ))+(DJ(JB,96)     )                               
      Y(JB,185) = (YP(JB,185)+DTS*P)/(1.0+DTS*L)
C
C          CARB14           Y(JB,186)
      P = EM(JB,186)
     &+(RC(JB,397)    *Y(JB,3  )*Y(JB,128))
     &+(RC(JB,429)    *Y(JB,3  )*Y(JB,149))          
      L = 0.0
     &+(RC(JB,353)    *Y(JB,3  ))+(DJ(JB,15)     )                               
      Y(JB,186) = (YP(JB,186)+DTS*P)/(1.0+DTS*L)
C
C          CARB17           Y(JB,187)
      P = EM(JB,187)
     &+(RC(JB,398)    *Y(JB,3  )*Y(JB,129))
     &+(RC(JB,430)    *Y(JB,3  )*Y(JB,150))          
      L = 0.0
     &+(RC(JB,354)    *Y(JB,3  ))+(DJ(JB,16)     )                               
      Y(JB,187) = (YP(JB,187)+DTS*P)/(1.0+DTS*L)
C
C          CARB10           Y(JB,188)
      P = EM(JB,188)
     &+(RC(JB,401)    *Y(JB,3  )*Y(JB,132))
     &+(RC(JB,445)    *Y(JB,3  )*Y(JB,156))          
      L = 0.0
     &+(RC(JB,357)    *Y(JB,3  ))+(DJ(JB,19)     )                               
      Y(JB,188) = (YP(JB,188)+DTS*P)/(1.0+DTS*L)
C
C          CARB12           Y(JB,189)
      P = EM(JB,189)
     &+(RC(JB,436)    *Y(JB,3  )*Y(JB,164))                                      
      L = 0.0
     &+(RC(JB,369)    *Y(JB,3  ))+(DJ(JB,27)     )                               
      Y(JB,189) = (YP(JB,189)+DTS*P)/(1.0+DTS*L)
C
C          CARB15           Y(JB,190)
      P = EM(JB,190)
     &+(RC(JB,437)    *Y(JB,3  )*Y(JB,165))                                      
      L = 0.0
     &+(RC(JB,370)    *Y(JB,3  ))+(DJ(JB,28)     )                               
      Y(JB,190) = (YP(JB,190)+DTS*P)/(1.0+DTS*L)
C
C          CCARB12          Y(JB,191)
      P = EM(JB,191)
     &+(RC(JB,412)    *Y(JB,3  )*Y(JB,143))
     &+(RC(JB,464)    *Y(JB,3  )*Y(JB,184))          
      L = 0.0
     &+(RC(JB,371)    *Y(JB,3  ))                                             
      Y(JB,191) = (YP(JB,191)+DTS*P)/(1.0+DTS*L)
C
C          ANHY             Y(JB,192)
      P = EM(JB,192)
     &+(DJ(JB,38)     *Y(JB,99 ))                                             
     &+(DJ(JB,34)     *Y(JB,96 ))       +(DJ(JB,36)     *Y(JB,97 ))                 
     &+(RC(JB,383)    *Y(JB,3  )*Y(JB,99 ))
     &+(RC(JB,510)    *Y(JB,216))                 
     &+(RC(JB,379)    *Y(JB,3  )*Y(JB,96 ))
     &+(RC(JB,381)    *Y(JB,3  )*Y(JB,97 ))          
      L = 0.0
     &+(RC(JB,466)    *Y(JB,3  ))+(RC(JB,509)    )                               
      Y(JB,192) = (YP(JB,192)+DTS*P)/(1.0+DTS*L)
C
C          TNCARB15         Y(JB,193)
      P = EM(JB,193)
     &+(RC(JB,409)    *Y(JB,3  )*Y(JB,140))                                      
      L = 0.0
     &+(RC(JB,385)    *Y(JB,3  ))                                             
      Y(JB,193) = (YP(JB,193)+DTS*P)/(1.0+DTS*L)
C
C          RAROH14          Y(JB,194)
      P = EM(JB,194)
     &+(RC(JB,413)    *Y(JB,3  )*Y(JB,63 ))
     &+(RC(JB,414)    *Y(JB,5  )*Y(JB,63 ))          
      L = 0.0
     &+(RC(JB,415)    *Y(JB,4  ))                                             
      Y(JB,194) = (YP(JB,194)+DTS*P)/(1.0+DTS*L)
C
C          ARNOH14          Y(JB,195)
      P = EM(JB,195)
     &+(RC(JB,415)    *Y(JB,194)*Y(JB,4  ))
     &+(RC(JB,506)    *Y(JB,214))                 
      L = 0.0
     &+(RC(JB,416)    *Y(JB,3  ))+(RC(JB,417)    *Y(JB,5  ))
     &+(RC(JB,505)    )          
      Y(JB,195) = (YP(JB,195)+DTS*P)/(1.0+DTS*L)
C
C          RAROH17          Y(JB,196)
      P = EM(JB,196)
     &+(RC(JB,418)    *Y(JB,3  )*Y(JB,66 ))
     &+(RC(JB,419)    *Y(JB,5  )*Y(JB,66 ))          
      L = 0.0
     &+(RC(JB,420)    *Y(JB,4  ))                                             
      Y(JB,196) = (YP(JB,196)+DTS*P)/(1.0+DTS*L)
C
C          ARNOH17          Y(JB,197)
      P = EM(JB,197)
     &+(RC(JB,420)    *Y(JB,196)*Y(JB,4  ))
     &+(RC(JB,508)    *Y(JB,215))                 
      L = 0.0
     &+(RC(JB,421)    *Y(JB,3  ))+(RC(JB,422)    *Y(JB,5  ))
     &+(RC(JB,507)    )          
      Y(JB,197) = (YP(JB,197)+DTS*P)/(1.0+DTS*L)
C
C          PAN              Y(JB,198)
      P = EM(JB,198)
     &+(RC(JB,467)    *Y(JB,70 )*Y(JB,4  ))                                      
      L = DD(JB,198)+DW(JB,198)
     &+(RC(JB,468)    )       +(RC(JB,473)    *Y(JB,3  ))                        
      Y(JB,198) = (YP(JB,198)+DTS*P)/(1.0+DTS*L)
C
C          PPN              Y(JB,199)
      P = EM(JB,199)
     &+(RC(JB,469)    *Y(JB,72 )*Y(JB,4  ))                                      
      L = 0.0
     &+(RC(JB,470)    )       +(RC(JB,474)    *Y(JB,3  ))                        
      Y(JB,199) = (YP(JB,199)+DTS*P)/(1.0+DTS*L)
C
C          PHAN             Y(JB,200)
      P = EM(JB,200)
     &+(RC(JB,471)    *Y(JB,106)*Y(JB,4  ))                                      
      L = 0.0
     &+(RC(JB,472)    )       +(RC(JB,475)    *Y(JB,3  ))                        
      Y(JB,200) = (YP(JB,200)+DTS*P)/(1.0+DTS*L)
C
C          RU12PAN          Y(JB,201)
      P = EM(JB,201)
     &+(RC(JB,476)    *Y(JB,110)*Y(JB,4  ))                                      
      L = 0.0
     &+(RC(JB,477)    )       +(RC(JB,481)    *Y(JB,3  ))                        
      Y(JB,201) = (YP(JB,201)+DTS*P)/(1.0+DTS*L)
C
C          MPAN             Y(JB,202)
      P = EM(JB,202)
     &+(RC(JB,478)    *Y(JB,112)*Y(JB,4  ))                                      
      L = DD(JB,202)+DW(JB,202)
     &+(RC(JB,479)    )       +(RC(JB,480)    *Y(JB,3  ))                        
      Y(JB,202) = (YP(JB,202)+DTS*P)/(1.0+DTS*L)
C
C          RTN26PAN         Y(JB,203)
      P = EM(JB,203)
     &+(RC(JB,482)    *Y(JB,50 )*Y(JB,4  ))
     &+(RC(JB,500)    *Y(JB,211))                 
      L = 0.0
     &+(RC(JB,483)    )       +(RC(JB,484)    *Y(JB,3  ))
     &+(RC(JB,499)    )          
      Y(JB,203) = (YP(JB,203)+DTS*P)/(1.0+DTS*L)
C
C          P2604            Y(JB,204)
      P = EM(JB,204)
     &+(RC(JB,485)    *Y(JB,139))                                             
      L = DD(JB,204)+ DW(JB,204)
     &+(RC(JB,486)    )                                                    
      Y(JB,204) = (YP(JB,204)+DTS*P)/(1.0+DTS*L)
C
C          P4608            Y(JB,205)
      P = EM(JB,205)
     &+(RC(JB,487)    *Y(JB,141))                                             
      L = DD(JB,205)+ DW(JB,205)
     &+(RC(JB,488)    )                                                    
      Y(JB,205) = (YP(JB,205)+DTS*P)/(1.0+DTS*L)
C
C          P2631            Y(JB,206)
      P = EM(JB,206)
     &+(RC(JB,489)    *Y(JB,52 ))                                             
      L = DD(JB,206)+ DW(JB,206)
     &+(RC(JB,490)    )                                                    
      Y(JB,206) = (YP(JB,206)+DTS*P)/(1.0+DTS*L)
C
C          P2635            Y(JB,207)
      P = EM(JB,207)
     &+(RC(JB,491)    *Y(JB,178))                                             
      L = DD(JB,207)+ DW(JB,207)
     &+(RC(JB,492)    )                                                    
      Y(JB,207) = (YP(JB,207)+DTS*P)/(1.0+DTS*L)
C
C          P4610            Y(JB,208)
      P = EM(JB,208)
     &+(RC(JB,493)    *Y(JB,182))                                             
      L = DD(JB,208)+ DW(JB,208)
     &+(RC(JB,494)    )                                                    
      Y(JB,208) = (YP(JB,208)+DTS*P)/(1.0+DTS*L)
C
C          P2605            Y(JB,209)
      P = EM(JB,209)
     &+(RC(JB,495)    *Y(JB,174))                                             
      L = DD(JB,209)+ DW(JB,209)
     &+(RC(JB,496)    )                                                    
      Y(JB,209) = (YP(JB,209)+DTS*P)/(1.0+DTS*L)
C
C          P2630            Y(JB,210)
      P = EM(JB,210)
     &+(RC(JB,497)    *Y(JB,176))                                             
      L = DD(JB,210)+ DW(JB,210)
     &+(RC(JB,498)    )                                                    
      Y(JB,210) = (YP(JB,210)+DTS*P)/(1.0+DTS*L)
C
C          P2629            Y(JB,211)
      P = EM(JB,211)
     &+(RC(JB,499)    *Y(JB,203))                                             
      L = DD(JB,211)+ DW(JB,211)
     &+(RC(JB,500)    )                                                    
      Y(JB,211) = (YP(JB,211)+DTS*P)/(1.0+DTS*L)
C
C          P2632            Y(JB,212)
      P = EM(JB,212)
     &+(RC(JB,501)    *Y(JB,177))                                             
      L = DD(JB,212)+ DW(JB,212)
     &+(RC(JB,502)    )                                                    
      Y(JB,212) = (YP(JB,212)+DTS*P)/(1.0+DTS*L)
C
C          P2637            Y(JB,213)
      P = EM(JB,213)
     &+(RC(JB,503)    *Y(JB,179))                                             
      L = DD(JB,213)+ DW(JB,213)
     &+(RC(JB,504)    )                                                    
      Y(JB,213) = (YP(JB,213)+DTS*P)/(1.0+DTS*L)
C
C          P3612            Y(JB,214)
      P = EM(JB,214)
     &+(RC(JB,505)    *Y(JB,195))                                             
      L = DD(JB,214)+ DW(JB,214)
     &+(RC(JB,506)    )                                                    
      Y(JB,214) = (YP(JB,214)+DTS*P)/(1.0+DTS*L)
C
C          P3613            Y(JB,215)
      P = EM(JB,215)
     &+(RC(JB,507)    *Y(JB,197))                                             
      L = DD(JB,215)+ DW(JB,215)
     &+(RC(JB,508)    )                                                    
      Y(JB,215) = (YP(JB,215)+DTS*P)/(1.0+DTS*L)
C
C          P3442            Y(JB,216)
      P = EM(JB,216)
     &+(RC(JB,509)    *Y(JB,192))                                             
      L = DD(JB,216)+ DW(JB,216)
     &+(RC(JB,510)    )                                                    
      Y(JB,216) = (YP(JB,216)+DTS*P)/(1.0+DTS*L)
C

C          CH3O2NO2         Y(JB,217)
      P = EM(JB,217)
     &+(RC(JB,164)    *Y(JB,22 )*Y(JB,4  ))                                      
      L = 0.0
     &+(RC(JB,165)    )                                                    
      Y(JB,217) = (YP(JB,217)+DTS*P)/(1.0+DTS*L)
C
C
C          EMPOA        Y(JB,218)
      P = EM(JB,218)
      L = DD(JB,218)+ DW(JB,218)
      Y(JB,218) = (YP(JB,218)+DTS*P)/(1.0+DTS*L)
C
C          P2007            Y(JB,219)
      P = EM(JB,219)
     &+(RC(JB,511)    *Y(JB,167))                                             
      L = DD(JB,219)+ DW(JB,219)
     &+(RC(JB,512)    )                                                    
      Y(JB,219) = (YP(JB,219)+DTS*P)/(1.0+DTS*L)
C
C          DMS          Y(JB,220)
          P = EM(JB,220)
          L = DD(JB,220)+DW(JB,220)+
     &(RC(JB,513)*Y(JB,3 ))+(RC(JB,514)*Y(JB,3 ))+(RC(JB,515)*Y(JB,5 ))
          Y(JB,220) = (YP(JB,220)+DTS*P)/(1.0+DTS*L)
C
C          DMSO         Y(JB,221)
          P =
     &(RC(JB,514)*Y(JB,3 )*Y(JB,220))
          L =
     &(RC(JB,516)*Y(JB,3 ))
          Y(JB,221) = (YP(JB,221)+DTS*P)/(1.0+DTS*L)
C
C          CH3SO        Y(JB,222)
          P =
     & (RC(JB,513)*Y(JB,3 )*Y(JB,220))
     &+(RC(JB,515)*Y(JB,5 )*Y(JB,220))
          L =
     &(RC(JB,517)*Y(JB,6))+(RC(JB,518)*Y(JB,4 ))
          Y(JB,222) = (YP(JB,222)+DTS*P)/(1.0+DTS*L)
C
C          CH3SO2       Y(JB,223)
          P =
     &(RC(JB,519)*Y(JB,225)*Y(JB,3))
     &+(RC(JB,518)*Y(JB,222)*Y(JB,4))
     &+(RC(JB,517)*Y(JB,222)*Y(JB,6 ))
          L =
     &(RC(JB,520)*Y(JB,6))
     &+(RC(JB,521)*Y(JB,4 ))
     &+(RC(JB,522))
          Y(JB,223) = (YP(JB,223)+DTS*P)/(1.0+DTS*L)
C
C          CH3SO3       Y(JB,224)
          P =
     &(RC(JB,520)*Y(JB,223)*Y(JB,6 ))
     &+(RC(JB,521)*Y(JB,223)*Y(JB,4))
          L =
     &(RC(JB,523)*Y(JB,9))
     &+(RC(JB,524))      
     &+(RC(JB,525)*Y(JB,39))
          Y(JB,224) = (YP(JB,224)+DTS*P)/(1.0+DTS*L)
C
C          MSIA         Y(JB,225)
          P =
     &(RC(JB,516)*Y(JB,3 )*Y(JB,221))
          L =
     &(RC(JB,519)*Y(JB,3 ))
          Y(JB,225) = (YP(JB,225)+DTS*P)/(1.0+DTS*L)
C
C          MSA          Y(JB,226)
          P = EM(JB,226)
     &+(RC(JB,523)*Y(JB,224)*Y(JB,9))
     &+(RC(JB,525)*Y(JB,224)*Y(JB,39))
          L = DD(JB,226)+DW(JB,226)
          Y(JB,226) = (YP(JB,226)+DTS*P)/(1.0+DTS*L)
C
C          CH3BR        Y(JB,227)
          P = EM(JB,227)
          L = DD(JB,227)
     &+(RC(JB,526)*Y(JB,3 ))
          Y(JB,227) = (YP(JB,227)+DTS*P)/(1.0+DTS*L)
C          NH3          Y(JB,228)
          P = EM(JB,228)
          L = DD(JB,228) + DW(JB,228)+LAQ(JB,8)
          Y(JB,228) = (YP(JB,228)+DTS*P)/(1.0+DTS*L)
C
C          AMMSUL       Y(JB,229)
          P = LAQ(JB,10)
          L = DD(JB,229) + DW(JB,229)
          Y(JB,229) = (YP(JB,229)+DTS*P)/(1.0+DTS*L)
C
C          SCIE        Y(JB,230)
          P = EM(JB,230)
     &+(RC(JB,530)*Y(JB,6 )*Y(JB,30))
     &+(RC(JB,56)     *Y(JB,6  )*Y(JB,32 ))   
     &+(RC(JB,62)*Y(JB,6)*Y(JB,43))
     &+(RC(JB,543)*Y(JB,6)*Y(JB,53)) 
     &+(RC(JB,547)*Y(JB,46)*Y(JB,6))
          L = DD(JB,230)
     &+(RC(JB,552)*H2O(JB)*H2O(JB))
          Y(JB,230) = (YP(JB,230)+DTS*P)/(1.0+DTS*L)	  
C          SCIPA        Y(JB,231)
          P = EM(JB,231)
     &+(RC(JB,531)*Y(JB,6 )*Y(JB,32))
     &+(RC(JB,58)     *Y(JB,6  )*Y(JB,34 ))  
          L = DD(JB,231)
     &+(RC(JB,553)*H2O(JB))
     &+(RC(JB,554)*H2O(JB)*H2O(JB))
          Y(JB,231) = (YP(JB,231)+DTS*P)/(1.0+DTS*L)	
C          SCIPS        Y(JB,232)
          P = EM(JB,232)
     &+(RC(JB,532)*Y(JB,6 )*Y(JB,32))
     &+(RC(JB,533)     *Y(JB,6  )*Y(JB,34 ))  
          L = DD(JB,232)
     &+(RC(JB,555))
          Y(JB,232) = (YP(JB,232)+DTS*P)/(1.0+DTS*L)	
C          SCIMAA        Y(JB,233)
          P = EM(JB,233)
     &+(RC(JB,535)*Y(JB,6 )*Y(JB,43)) 
          L = DD(JB,233)
     &+(RC(JB,556)*H2O(JB))
     &+(RC(JB,557)*H2O(JB)*H2O(JB))
     &+(RC(JB,558))
          Y(JB,233) = (YP(JB,233)+DTS*P)/(1.0+DTS*L)	
C          SCIMAS        Y(JB,234)
          P = EM(JB,234)
     &+(RC(JB,536)*Y(JB,6 )*Y(JB,43)) 
          L = DD(JB,234)
     &+(RC(JB,559))
          Y(JB,234) = (YP(JB,234)+DTS*P)/(1.0+DTS*L)	
C          SCIMVA        Y(JB,235)
          P = EM(JB,235)
     &+(RC(JB,538)*Y(JB,6 )*Y(JB,43)) 
          L = DD(JB,235)
     &+(RC(JB,560))
          Y(JB,235) = (YP(JB,235)+DTS*P)/(1.0+DTS*L)	
C          SCIMVS        Y(JB,236)
          P = EM(JB,236)
     &+(RC(JB,539)*Y(JB,6 )*Y(JB,43)) 
          L = DD(JB,236)
     &+(RC(JB,561))
          Y(JB,236) = (YP(JB,236)+DTS*P)/(1.0+DTS*L)	
C          SCIPAA        Y(JB,237)
          P = EM(JB,237)
     &+(RC(JB,67)*Y(JB,6 )*Y(JB,47)) 
          L = DD(JB,237)
     &+(RC(JB,562)*H2O(JB))
     &+(RC(JB,563)*H2O(JB)*H2O(JB))
          Y(JB,237) = (YP(JB,237)+DTS*P)/(1.0+DTS*L)
C          SCIPAS        Y(JB,238)
          P = EM(JB,238)
     &+(RC(JB,540)*Y(JB,6 )*Y(JB,47)) 
          L = DD(JB,238)
     &+(RC(JB,564))
          Y(JB,238) = (YP(JB,238)+DTS*P)/(1.0+DTS*L)	  
C          SCIIPA        Y(JB,239)
          P = EM(JB,239)
     &+(RC(JB,541)*Y(JB,6 )*Y(JB,47)) 
          L = DD(JB,239)
     &+(RC(JB,565))
          Y(JB,239) = (YP(JB,239)+DTS*P)/(1.0+DTS*L)
C          SCIIPS        Y(JB,240)
          P = EM(JB,240)
     &+(RC(JB,542)*Y(JB,6 )*Y(JB,47)) 
          L = DD(JB,240)
     &+(RC(JB,566))
          Y(JB,240) = (YP(JB,240)+DTS*P)/(1.0+DTS*L)
C          SCIBPA        Y(JB,241)
          P = EM(JB,241)
     &+(RC(JB,73)*Y(JB,6 )*Y(JB,53)) 
          L = DD(JB,241)
     &+(RC(JB,567))+(RC(JB,568)*H2O(JB))
          Y(JB,241) = (YP(JB,241)+DTS*P)/(1.0+DTS*L)
C          SCIBPS        Y(JB,242)
          P = EM(JB,242)
     &+(RC(JB,544)*Y(JB,6 )*Y(JB,53)) 
          L = DD(JB,242)
     &+(RC(JB,569))
          Y(JB,242) = (YP(JB,242)+DTS*P)/(1.0+DTS*L)
C          SCIMGA        Y(JB,243)
          P = EM(JB,243)
     &+(RC(JB,545)*Y(JB,6 )*Y(JB,46)) 
     &+(RC(JB,548)*Y(JB,109)*Y(JB,6))
          L = DD(JB,243)
     &+(RC(JB,570))
          Y(JB,243) = (YP(JB,243)+DTS*P)/(1.0+DTS*L)
C          SCIMGS        Y(JB,244)
          P = EM(JB,244)
     &+(RC(JB,546)*Y(JB,6 )*Y(JB,46)) 
     &+(RC(JB,549)*Y(JB,109)*Y(JB,6))
          L = DD(JB,244)
     &+(RC(JB,571))+(RC(JB,572)*H2O(JB))
     &+(RC(JB,577)*H2O(JB)*H2O(JB))
          Y(JB,244) = (YP(JB,244)+DTS*P)/(1.0+DTS*L)
C          SCIGAA        Y(JB,245)
          P = EM(JB,245)
     &+(RC(JB,550)*Y(JB,6 )*Y(JB,46)) 
          L = DD(JB,245)
     &+(RC(JB,573)*H2O(JB))
     &+(RC(JB,574)*H2O(JB)*H2O(JB))
          Y(JB,245) = (YP(JB,245)+DTS*P)/(1.0+DTS*L)
C          SCIGAS        Y(JB,246)
          P = EM(JB,246)
     &+(RC(JB,551)*Y(JB,6 )*Y(JB,46)) 
          L = DD(JB,246)
     &+(RC(JB,575)*H2O(JB))
     &+(RC(JB,576)*H2O(JB)*H2O(JB))
          Y(JB,246) = (YP(JB,246)+DTS*P)/(1.0+DTS*L)
C          FTOH          Y(JB,247)
          P = EM(JB,247)
          L = DD(JB,247) 
          Y(JB,247) = (YP(JB,247)+DTS*P)/(1.0+DTS*L)
C         PFOA           Y(JB,248)
          P = EM(JB,248)
          L = DD(JB,248) 
          Y(JB,248) = (YP(JB,248)+DTS*P)/(1.0+DTS*L)
C          APHOC2H4OOH          Y(JB,249)
      P = 0.0
     &+(RC(JB,579)*Y(JB,154)*APN(JB))
     &+(RC(JB,627)    *Y(JB,296))                                     
      L = 0.0
     &+(RC(JB,720)    *Y(JB,3  ))+(DJ(JB,97)     )  
     &+(RC(JB,626)    )                             
      Y(JB,249) = (YP(JB,249)+DTS*P)/(1.0+DTS*L)
C          BPRU14OOH          Y(JB,250)
      P = 0.0
     &+(RC(JB,580)    *Y(JB,166)*BPN(JB))
     &+(RC(JB,629)    *Y(JB,297))                                     
      L = 0.0
     &+(RC(JB,721)    *Y(JB,3  ))+(DJ(JB,98)     )  
     &+(RC(JB,628)    )                             
      Y(JB,250) = (YP(JB,250)+DTS*P)/(1.0+DTS*L)
C          APRU14OOH          Y(JB,251)
      P = 0.0
     &+(RC(JB,581)    *Y(JB,166)*APN(JB))
     &+(RC(JB,631)    *Y(JB,298))                                     
      L = 0.0
     &+(RC(JB,722)    *Y(JB,3  ))+(DJ(JB,99)     )  
     &+(RC(JB,630)    )                             
      Y(JB,251) = (YP(JB,251)+DTS*P)/(1.0+DTS*L)
C          C1RU12OOH          Y(JB,252)
      P = 0.0
     &+(RC(JB,582)    *Y(JB,167)*Y(JB,230))
     &+(RC(JB,633)    *Y(JB,299))                                     
      L = 0.0
     &+(RC(JB,723)    *Y(JB,3  ))+(DJ(JB,100)     )  
     &+(RC(JB,632)    )                             
      Y(JB,252) = (YP(JB,252)+DTS*P)/(1.0+DTS*L)
C          ISRU12OOH          Y(JB,253)
      P = 0.0
     &+(RC(JB,583)    *Y(JB,167)*ISP(JB))
     &+(RC(JB,635)    *Y(JB,300))                                     
      L = 0.0
     &+(RC(JB,724)    *Y(JB,3  ))+(DJ(JB,101)     )  
     &+(RC(JB,634)    )                             
      Y(JB,253) = (YP(JB,253)+DTS*P)/(1.0+DTS*L)
C          BPRU12OOH          Y(JB,254)
      P = 0.0
     &+(RC(JB,584)    *Y(JB,167)*BPN(JB))
     &+(RC(JB,637)    *Y(JB,301))                                     
      L = 0.0
     &+(RC(JB,725)    *Y(JB,3  ))+(DJ(JB,102)     )  
     &+(RC(JB,636)    )                             
      Y(JB,254) = (YP(JB,254)+DTS*P)/(1.0+DTS*L)
C          BPRU10OOH          Y(JB,255)
      P = 0.0
     &+(RC(JB,585)    *Y(JB,168)*BPN(JB))
     &+(RC(JB,639)    *Y(JB,302))                                     
      L = 0.0
     &+(RC(JB,726)    *Y(JB,3  ))+(DJ(JB,103)     )  
     &+(RC(JB,638)    )                             
      Y(JB,255) = (YP(JB,255)+DTS*P)/(1.0+DTS*L)
C          APRU10OOH          Y(JB,256)
      P = 0.0
     &+(RC(JB,586)    *Y(JB,168)*APN(JB))
     &+(RC(JB,641)    *Y(JB,303))                                     
      L = 0.0
     &+(RC(JB,727)    *Y(JB,3  ))+(DJ(JB,104)     )  
     &+(RC(JB,640)    )                             
      Y(JB,256) = (YP(JB,256)+DTS*P)/(1.0+DTS*L)
C          BPNRU14OOH          Y(JB,257)
      P = 0.0
     &+(RC(JB,587)    *Y(JB,172)*BPN(JB))
     &+(RC(JB,643)    *Y(JB,304))                                     
      L = 0.0
     &+(RC(JB,728)    *Y(JB,3  ))+(DJ(JB,105)     )  
     &+(RC(JB,642)    )                             
      Y(JB,257) = (YP(JB,257)+DTS*P)/(1.0+DTS*L)
C          APNRU14OOH          Y(JB,258)
      P = 0.0
     &+(RC(JB,588)    *Y(JB,172)*APN(JB))
     &+(RC(JB,645)    *Y(JB,305))                                     
      L = 0.0
     &+(RC(JB,729)    *Y(JB,3  ))+(DJ(JB,106)     )  
     &+(RC(JB,644)    )                             
      Y(JB,258) = (YP(JB,258)+DTS*P)/(1.0+DTS*L)
C          C1NRU12OOH          Y(JB,259)
      P = 0.0
     &+(RC(JB,589)    *Y(JB,173)*Y(JB,230  ))
     &+(RC(JB,647)    *Y(JB,306))                                     
      L = 0.0
     &+(RC(JB,730)    *Y(JB,3  ))+(DJ(JB,107)     )  
     &+(RC(JB,646)    )                             
      Y(JB,259) = (YP(JB,259)+DTS*P)/(1.0+DTS*L)
C          ISNRU12OOH          Y(JB,260)
      P = 0.0
     &+(RC(JB,590)    *Y(JB,173)*ISP(JB))
     &+(RC(JB,649)    *Y(JB,307))                                     
      L = 0.0
     &+(RC(JB,731)    *Y(JB,3  ))+(DJ(JB,108)     )  
     &+(RC(JB,648)    )                             
      Y(JB,260) = (YP(JB,260)+DTS*P)/(1.0+DTS*L)
C          BPNRU12OOH          Y(JB,261)
      P = 0.0
     &+(RC(JB,591)    *Y(JB,173)*BPN(JB))
     &+(RC(JB,651)    *Y(JB,308))                                     
      L = 0.0
     &+(RC(JB,732)    *Y(JB,3  ))+(DJ(JB,109)     )  
     &+(RC(JB,650)    )                             
      Y(JB,261) = (YP(JB,261)+DTS*P)/(1.0+DTS*L)
C          ISRTN28OOH          Y(JB,262)
      P = 0.0
     &+(RC(JB,592)    *Y(JB,173)*APN(JB))
     &+(RC(JB,653)    *Y(JB,309))                                     
      L = 0.0
     &+(RC(JB,733)    *Y(JB,3  ))+(DJ(JB,110)     )  
     &+(RC(JB,652)    )                             
      Y(JB,262) = (YP(JB,262)+DTS*P)/(1.0+DTS*L)
C          BPRTN28OOH          Y(JB,263)
      P = 0.0
     &+(RC(JB,593)    *Y(JB,174)*BPN(JB))
     &+(RC(JB,655)    *Y(JB,310))                                     
      L = 0.0
     &+(RC(JB,734)    *Y(JB,3  ))+(DJ(JB,111)     )  
     &+(RC(JB,654)    )                             
      Y(JB,263) = (YP(JB,263)+DTS*P)/(1.0+DTS*L)
C          APRTN28OOH          Y(JB,264)
      P = 0.0
     &+(RC(JB,594)    *Y(JB,174)*BPN(JB))
     &+(RC(JB,657)    *Y(JB,311))                                     
      L = 0.0
     &+(RC(JB,735)    *Y(JB,3  ))+(DJ(JB,112)     )  
     &+(RC(JB,656)    )                             
      Y(JB,264) = (YP(JB,264)+DTS*P)/(1.0+DTS*L)
C          ISRTN26OOH          Y(JB,265)
      P = 0.0
     &+(RC(JB,595)    *Y(JB,176)*ISP(JB))
     &+(RC(JB,659)    *Y(JB,312))                                     
      L = 0.0
     &+(RC(JB,736)    *Y(JB,3  ))+(DJ(JB,113)     )  
     &+(RC(JB,658)    )                             
      Y(JB,265) = (YP(JB,265)+DTS*P)/(1.0+DTS*L)
C          BPRTN26OOH          Y(JB,266)
      P = 0.0
     &+(RC(JB,596)    *Y(JB,176)*BPN(JB))
     &+(RC(JB,661)    *Y(JB,313))                                     
      L = 0.0
     &+(RC(JB,737)    *Y(JB,3  ))+(DJ(JB,114)     )  
     &+(RC(JB,660)    )                             
      Y(JB,266) = (YP(JB,266)+DTS*P)/(1.0+DTS*L)
C          APRTN26OOH          Y(JB,267)
      P = 0.0
     &+(RC(JB,597)    *Y(JB,176)*APN(JB))
     &+(RC(JB,663)    *Y(JB,314))                                     
      L = 0.0
     &+(RC(JB,738)    *Y(JB,3  ))+(DJ(JB,115)     )  
     &+(RC(JB,662)    )                             
      Y(JB,267) = (YP(JB,267)+DTS*P)/(1.0+DTS*L)
C          BPRTN25OOH          Y(JB,268)
      P = 0.0
     &+(RC(JB,598)    *Y(JB,177)*BPN(JB))
     &+(RC(JB,665)    *Y(JB,315))                                     
      L = 0.0
     &+(RC(JB,739)    *Y(JB,3  ))+(DJ(JB,116)     )  
     &+(RC(JB,664)    )                             
      Y(JB,268) = (YP(JB,268)+DTS*P)/(1.0+DTS*L)
C          APRTN25OOH          Y(JB,269)
      P = 0.0
     &+(RC(JB,599)    *Y(JB,177)*APN(JB))
     &+(RC(JB,667)    *Y(JB,316))                                     
      L = 0.0
     &+(RC(JB,740)    *Y(JB,3  ))+(DJ(JB,117)     )  
     &+(RC(JB,666)    )                             
      Y(JB,269) = (YP(JB,269)+DTS*P)/(1.0+DTS*L)
C          ISRTN24OOH          Y(JB,270)
      P = 0.0
     &+(RC(JB,600)    *Y(JB,178)*ISP(JB))
     &+(RC(JB,669)    *Y(JB,317))                                     
      L = 0.0
     &+(RC(JB,741)    *Y(JB,3  ))+(DJ(JB,118)     )  
     &+(RC(JB,668)    )                             
      Y(JB,270) = (YP(JB,270)+DTS*P)/(1.0+DTS*L)
C          BPRTN24OOH          Y(JB,271)
      P = 0.0
     &+(RC(JB,601)    *Y(JB,178)*BPN(JB))
     &+(RC(JB,671)    *Y(JB,318))                                     
      L = 0.0
     &+(RC(JB,742)    *Y(JB,3  ))+(DJ(JB,119)     )  
     &+(RC(JB,670)    )                             
      Y(JB,271) = (YP(JB,271)+DTS*P)/(1.0+DTS*L)
C          APRTN24OOH          Y(JB,272)
      P = 0.0
     &+(RC(JB,602)    *Y(JB,178)*APN(JB))
     &+(RC(JB,673)    *Y(JB,319))                                     
      L = 0.0
     &+(RC(JB,743)    *Y(JB,3  ))+(DJ(JB,120)     )  
     &+(RC(JB,672)    )                             
      Y(JB,272) = (YP(JB,272)+DTS*P)/(1.0+DTS*L)
C          C1RTN23OOH          Y(JB,273)
      P = 0.0
     &+(RC(JB,603)    *Y(JB,179)*Y(JB,230  ))
     &+(RC(JB,675)    *Y(JB,320))                                     
      L = 0.0
     &+(RC(JB,744)    *Y(JB,3  ))+(DJ(JB,121)     )  
     &+(RC(JB,674)    )                             
      Y(JB,273) = (YP(JB,273)+DTS*P)/(1.0+DTS*L)
C          ISRTN23OOH          Y(JB,274)
      P = 0.0
     &+(RC(JB,604)    *Y(JB,179)*ISP(JB))
     &+(RC(JB,677)    *Y(JB,321))                                     
      L = 0.0
     &+(RC(JB,745)    *Y(JB,3  ))+(DJ(JB,122)     )  
     &+(RC(JB,676)    )                             
      Y(JB,274) = (YP(JB,274)+DTS*P)/(1.0+DTS*L)
C          BPRTN23OOH          Y(JB,275)
      P = 0.0
     &+(RC(JB,605)    *Y(JB,179)*BPN(JB))
     &+(RC(JB,679)    *Y(JB,322))                                     
      L = 0.0
     &+(RC(JB,746)    *Y(JB,3  ))+(DJ(JB,123)     )  
     &+(RC(JB,678)    )                             
      Y(JB,275) = (YP(JB,275)+DTS*P)/(1.0+DTS*L)
C          ISNRTN28OOH          Y(JB,276)
      P = 0.0
     &+(RC(JB,606)    *Y(JB,175)*ISP(JB))
     &+(RC(JB,681)    *Y(JB,323))                                     
      L = 0.0
     &+(RC(JB,747)    *Y(JB,3  ))+(DJ(JB,124)     )  
     &+(RC(JB,680)    )                             
      Y(JB,276) = (YP(JB,276)+DTS*P)/(1.0+DTS*L)
C          BPNRTN28OOH          Y(JB,277)
      P = 0.0
     &+(RC(JB,607)    *Y(JB,175)*BPN(JB))
     &+(RC(JB,683)    *Y(JB,324))                                     
      L = 0.0
     &+(RC(JB,748)    *Y(JB,3  ))+(DJ(JB,125)     )  
     &+(RC(JB,682)    )                             
      Y(JB,277) = (YP(JB,277)+DTS*P)/(1.0+DTS*L)
C          APNRTN28OOH          Y(JB,278)
      P = 0.0
     &+(RC(JB,608)    *Y(JB,175)*APN(JB))
     &+(RC(JB,685)    *Y(JB,325))                                     
      L = 0.0
     &+(RC(JB,749)    *Y(JB,3  ))+(DJ(JB,126)     )  
     &+(RC(JB,684)    )                             
      Y(JB,278) = (YP(JB,278)+DTS*P)/(1.0+DTS*L)
C          APRN8OOH          Y(JB,279)
      P = 0.0
     &+(RC(JB,609)    *Y(JB,162)*APN(JB))
     &+(RC(JB,687)    *Y(JB,326))                                     
      L = 0.0
     &+(RC(JB,750)    *Y(JB,3  ))+(DJ(JB,127)     )  
     &+(RC(JB,686)    )                             
      Y(JB,279) = (YP(JB,279)+DTS*P)/(1.0+DTS*L)
C          ISRTX28OOH          Y(JB,280)
      P = 0.0
     &+(RC(JB,610)    *Y(JB,182)*ISP(JB))
     &+(RC(JB,689)    *Y(JB,327))                                     
      L = 0.0
     &+(RC(JB,751)    *Y(JB,3  ))+(DJ(JB,128)     )  
     &+(RC(JB,688)    )                             
      Y(JB,280) = (YP(JB,280)+DTS*P)/(1.0+DTS*L)
C          BPRTX28OOH          Y(JB,281)
      P = 0.0
     &+(RC(JB,611)    *Y(JB,182)*BPN(JB))
     &+(RC(JB,691)    *Y(JB,328))                                     
      L = 0.0
     &+(RC(JB,752)    *Y(JB,3  ))+(DJ(JB,129)     )  
     &+(RC(JB,690)    )                             
      Y(JB,281) = (YP(JB,281)+DTS*P)/(1.0+DTS*L)
C          APRTX28OOH          Y(JB,282)
      P = 0.0
     &+(RC(JB,612)    *Y(JB,182)*APN(JB))
     &+(RC(JB,693)    *Y(JB,329))                                     
      L = 0.0
     &+(RC(JB,753)    *Y(JB,3  ))+(DJ(JB,130)     )  
     &+(RC(JB,692)    )                             
      Y(JB,282) = (YP(JB,282)+DTS*P)/(1.0+DTS*L)
C          BPRTX24OOH          Y(JB,283)
      P = 0.0
     &+(RC(JB,613)    *Y(JB,183)*BPN(JB))
     &+(RC(JB,695)    *Y(JB,330))                                     
      L = 0.0
     &+(RC(JB,754)    *Y(JB,3  ))+(DJ(JB,131)     )  
     &+(RC(JB,694)    )                             
      Y(JB,283) = (YP(JB,283)+DTS*P)/(1.0+DTS*L)
C          APRTX24OOH          Y(JB,284)
      P = 0.0
     &+(RC(JB,614)    *Y(JB,183)*APN(JB))
     &+(RC(JB,697)    *Y(JB,331))                                     
      L = 0.0
     &+(RC(JB,755)    *Y(JB,3  ))+(DJ(JB,132)     )  
     &+(RC(JB,696)    )                             
      Y(JB,284) = (YP(JB,284)+DTS*P)/(1.0+DTS*L)
C          ISRTX22OOH          Y(JB,285)
      P = 0.0
     &+(RC(JB,615)    *Y(JB,184)*ISP(JB))
     &+(RC(JB,699)    *Y(JB,332))                                     
      L = 0.0
     &+(RC(JB,756)    *Y(JB,3  ))+(DJ(JB,133)     )  
     &+(RC(JB,698)    )                             
      Y(JB,285) = (YP(JB,285)+DTS*P)/(1.0+DTS*L)
C          BPRTX22OOH          Y(JB,286)
      P = 0.0
     &+(RC(JB,616)    *Y(JB,184)*BPN(JB))
     &+(RC(JB,701)    *Y(JB,333))                                     
      L = 0.0
     &+(RC(JB,757)    *Y(JB,3  ))+(DJ(JB,134)     )  
     &+(RC(JB,700)    )                             
      Y(JB,286) = (YP(JB,286)+DTS*P)/(1.0+DTS*L)
C          APRTX22OOH          Y(JB,287)
      P = 0.0
     &+(RC(JB,617)    *Y(JB,184)*APN(JB))
     &+(RC(JB,703)    *Y(JB,334))                                     
      L = 0.0
     &+(RC(JB,758)    *Y(JB,3  ))+(DJ(JB,135)     )  
     &+(RC(JB,702)    )                             
      Y(JB,287) = (YP(JB,287)+DTS*P)/(1.0+DTS*L)
C          ISNRTX28OOH          Y(JB,288)
      P = 0.0
     &+(RC(JB,618)    *Y(JB,185)*ISP(JB))
     &+(RC(JB,705)    *Y(JB,335))                                     
      L = 0.0
     &+(RC(JB,759)    *Y(JB,3  ))+(DJ(JB,136)     )  
     &+(RC(JB,704)    )                             
      Y(JB,288) = (YP(JB,288)+DTS*P)/(1.0+DTS*L)
C          BPNRTX28OOH          Y(JB,289)
      P = 0.0
     &+(RC(JB,619)    *Y(JB,185)*BPN(JB))
     &+(RC(JB,707)    *Y(JB,336))                                     
      L = 0.0
     &+(RC(JB,760)    *Y(JB,3  ))+(DJ(JB,137)     )  
     &+(RC(JB,706)    )                             
      Y(JB,289) = (YP(JB,289)+DTS*P)/(1.0+DTS*L)
C          APNRTX28OOH          Y(JB,290)
      P = 0.0
     &+(RC(JB,620)    *Y(JB,185)*APN(JB))
     &+(RC(JB,709)    *Y(JB,337))                                     
      L = 0.0
     &+(RC(JB,761)    *Y(JB,3  ))+(DJ(JB,138)     )  
     &+(RC(JB,708)    )                             
      Y(JB,290) = (YP(JB,290)+DTS*P)/(1.0+DTS*L)
C          C1RTN14OOH          Y(JB,291)
      P = 0.0
     &+(RC(JB,621)    *Y(JB,180)*Y(JB,230  ))
     &+(RC(JB,711)    *Y(JB,338))                                     
      L = 0.0
     &+(RC(JB,762)    *Y(JB,3  ))+(DJ(JB,139)     )  
     &+(RC(JB,710)    )                             
      Y(JB,291) = (YP(JB,291)+DTS*P)/(1.0+DTS*L)
C          ISRTN14OOH          Y(JB,292)
      P = 0.0
     &+(RC(JB,622)    *Y(JB,180)*ISP(JB))
     &+(RC(JB,713)    *Y(JB,339))                                     
      L = 0.0
     &+(RC(JB,763)    *Y(JB,3  ))+(DJ(JB,140)     )  
     &+(RC(JB,712)    )                             
      Y(JB,292) = (YP(JB,292)+DTS*P)/(1.0+DTS*L)
C          BPRTN14OOH          Y(JB,293)
      P = 0.0
     &+(RC(JB,623)    *Y(JB,180)*BPN(JB))
     &+(RC(JB,715)    *Y(JB,340))                                     
      L = 0.0
     &+(RC(JB,764)    *Y(JB,3  ))+(DJ(JB,141)     )  
     &+(RC(JB,714)    )                             
      Y(JB,293) = (YP(JB,293)+DTS*P)/(1.0+DTS*L)
C          APRTN14OOH          Y(JB,294)
      P = 0.0
     &+(RC(JB,624)    *Y(JB,180)*APN(JB))
     &+(RC(JB,717)    *Y(JB,341))                                     
      L = 0.0
     &+(RC(JB,765)    *Y(JB,3  ))+(DJ(JB,142)     )  
     &+(RC(JB,716)    )                             
      Y(JB,294) = (YP(JB,294)+DTS*P)/(1.0+DTS*L)
C          APRTN10OOH          Y(JB,295)
      P = 0.0
     &+(RC(JB,625)    *Y(JB,181)*APN(JB))
     &+(RC(JB,719)    *Y(JB,342))                                     
      L = 0.0
     &+(RC(JB,766)    *Y(JB,3  ))+(DJ(JB,143)     )  
     &+(RC(JB,718)    )                             
      Y(JB,295) = (YP(JB,295)+DTS*P)/(1.0+DTS*L)
C          P1001            Y(JB,296)
      P = 0.0
     &+(RC(JB,626)    *Y(JB,249))                                             
      L = DD(JB,296)+ DW(JB,296)
     &+(RC(JB,627)    )                                                    
      Y(JB,296) = (YP(JB,296)+DTS*P)/(1.0+DTS*L)
C          P1002            Y(JB,297)
      P = 0.0
     &+(RC(JB,628)    *Y(JB,250))                                             
      L = DD(JB,297)+ DW(JB,297)
     &+(RC(JB,629)    )                                                    
      Y(JB,297) = (YP(JB,297)+DTS*P)/(1.0+DTS*L)
C          P1003            Y(JB,298)
      P = 0.0
     &+(RC(JB,630)    *Y(JB,251))                                             
      L = DD(JB,298)+ DW(JB,298)
     &+(RC(JB,631)    )                                                    
      Y(JB,298) = (YP(JB,298)+DTS*P)/(1.0+DTS*L)
C          P1004            Y(JB,299)
      P = 0.0
     &+(RC(JB,632)    *Y(JB,252))                                             
      L = DD(JB,299)+ DW(JB,299)
     &+(RC(JB,633)    )                                                    
      Y(JB,299) = (YP(JB,299)+DTS*P)/(1.0+DTS*L)
C          P1005            Y(JB,300)
      P = 0.0
     &+(RC(JB,634)    *Y(JB,253))                                             
      L = DD(JB,300)+ DW(JB,300)
     &+(RC(JB,635)    )                                                    
      Y(JB,300) = (YP(JB,300)+DTS*P)/(1.0+DTS*L)
C          P1006            Y(JB,301)
      P = 0.0
     &+(RC(JB,636)    *Y(JB,254))                                             
      L = DD(JB,301)+ DW(JB,301)
     &+(RC(JB,637)    )                                                    
      Y(JB,301) = (YP(JB,301)+DTS*P)/(1.0+DTS*L)
C          P1007            Y(JB,302)
      P = 0.0
     &+(RC(JB,638)    *Y(JB,255))                                             
      L = DD(JB,302)+ DW(JB,302)
     &+(RC(JB,639)    )                                                    
      Y(JB,302) = (YP(JB,302)+DTS*P)/(1.0+DTS*L)
C          P1008            Y(JB,303)
      P = 0.0
     &+(RC(JB,640)    *Y(JB,256))                                             
      L = DD(JB,303)+ DW(JB,303)
     &+(RC(JB,641)    )                                                    
      Y(JB,303) = (YP(JB,303)+DTS*P)/(1.0+DTS*L)
C          P1009            Y(JB,304)
      P = 0.0
     &+(RC(JB,642)    *Y(JB,257))                                             
      L = DD(JB,304)+ DW(JB,304)
     &+(RC(JB,643)    )                                                    
      Y(JB,304) = (YP(JB,304)+DTS*P)/(1.0+DTS*L)
C          P1010            Y(JB,305)
      P = 0.0
     &+(RC(JB,644)    *Y(JB,258))                                             
      L = DD(JB,305)+ DW(JB,305)
     &+(RC(JB,645)    )                                                    
      Y(JB,305) = (YP(JB,305)+DTS*P)/(1.0+DTS*L)
C          P1011            Y(JB,306)
      P = 0.0
     &+(RC(JB,646)    *Y(JB,259))                                             
      L = DD(JB,306)+ DW(JB,306)
     &+(RC(JB,647)    )                                                    
      Y(JB,306) = (YP(JB,306)+DTS*P)/(1.0+DTS*L)
C          P1012            Y(JB,307)
      P = 0.0
     &+(RC(JB,648)    *Y(JB,260))                                             
      L = DD(JB,307)+ DW(JB,307)
     &+(RC(JB,649)    )                                                    
      Y(JB,307) = (YP(JB,307)+DTS*P)/(1.0+DTS*L)
C          P1013            Y(JB,308)
      P = 0.0
     &+(RC(JB,650)    *Y(JB,261))                                             
      L = DD(JB,308)+ DW(JB,308)
     &+(RC(JB,651)    )                                                    
      Y(JB,308) = (YP(JB,308)+DTS*P)/(1.0+DTS*L)
C          P1014            Y(JB,309)
      P = 0.0
     &+(RC(JB,652)    *Y(JB,262))                                             
      L = DD(JB,309)+ DW(JB,309)
     &+(RC(JB,653)    )                                                    
      Y(JB,309) = (YP(JB,309)+DTS*P)/(1.0+DTS*L)
C          P1015            Y(JB,310)
      P = 0.0
     &+(RC(JB,654)    *Y(JB,263))                                             
      L = DD(JB,310)+ DW(JB,310)
     &+(RC(JB,655)    )                                                    
      Y(JB,310) = (YP(JB,310)+DTS*P)/(1.0+DTS*L)
C          P1016            Y(JB,311)
      P = 0.0
     &+(RC(JB,656)    *Y(JB,264))                                             
      L = DD(JB,311)+ DW(JB,311)
     &+(RC(JB,657)    )                                                    
      Y(JB,311) = (YP(JB,311)+DTS*P)/(1.0+DTS*L)
C          P1017            Y(JB,312)
      P = 0.0
     &+(RC(JB,658)    *Y(JB,265))                                             
      L = DD(JB,312)+ DW(JB,312)
     &+(RC(JB,659)    )                                                    
      Y(JB,312) = (YP(JB,312)+DTS*P)/(1.0+DTS*L)
C          P1018            Y(JB,313)
      P = 0.0
     &+(RC(JB,660)    *Y(JB,266))                                             
      L = DD(JB,313)+ DW(JB,313)
     &+(RC(JB,661)    )                                                    
      Y(JB,313) = (YP(JB,313)+DTS*P)/(1.0+DTS*L)
C          P1019            Y(JB,314)
      P = 0.0
     &+(RC(JB,662)    *Y(JB,267))                                             
      L = DD(JB,314)+ DW(JB,314)
     &+(RC(JB,663)    )                                                    
      Y(JB,314) = (YP(JB,314)+DTS*P)/(1.0+DTS*L)
C          P1020            Y(JB,315)
      P = 0.0
     &+(RC(JB,664)    *Y(JB,268))                                             
      L = DD(JB,315)+ DW(JB,315)
     &+(RC(JB,665)    )                                                    
      Y(JB,315) = (YP(JB,315)+DTS*P)/(1.0+DTS*L)
C          P1021            Y(JB,316)
      P = 0.0
     &+(RC(JB,666)    *Y(JB,269))                                             
      L = DD(JB,316)+ DW(JB,316)
     &+(RC(JB,667)    )                                                    
      Y(JB,316) = (YP(JB,316)+DTS*P)/(1.0+DTS*L)
C          P1022            Y(JB,317)
      P = 0.0
     &+(RC(JB,668)    *Y(JB,270))                                             
      L = DD(JB,317)+ DW(JB,317)
     &+(RC(JB,669)    )                                                    
      Y(JB,317) = (YP(JB,317)+DTS*P)/(1.0+DTS*L)
C          P1023            Y(JB,318)
      P = 0.0
     &+(RC(JB,670)    *Y(JB,271))                                             
      L = DD(JB,318)+ DW(JB,318)
     &+(RC(JB,671)    )                                                    
      Y(JB,318) = (YP(JB,318)+DTS*P)/(1.0+DTS*L)
C          P1024            Y(JB,319)
      P = 0.0
     &+(RC(JB,672)    *Y(JB,272))                                             
      L = DD(JB,319)+ DW(JB,319)
     &+(RC(JB,673)    )                                                    
      Y(JB,319) = (YP(JB,319)+DTS*P)/(1.0+DTS*L)
C          P1025            Y(JB,320)
      P = 0.0
     &+(RC(JB,674)    *Y(JB,273))                                             
      L = DD(JB,320)+ DW(JB,320)
     &+(RC(JB,675)    )                                                    
      Y(JB,320) = (YP(JB,320)+DTS*P)/(1.0+DTS*L)
C          P1026            Y(JB,321)
      P = 0.0
     &+(RC(JB,676)    *Y(JB,274))                                             
      L = DD(JB,321)+ DW(JB,321)
     &+(RC(JB,677)    )                                                    
      Y(JB,321) = (YP(JB,321)+DTS*P)/(1.0+DTS*L)
C          P1027            Y(JB,322)
      P = 0.0
     &+(RC(JB,678)    *Y(JB,275))                                             
      L = DD(JB,322)+ DW(JB,322)
     &+(RC(JB,679)    )                                                    
      Y(JB,322) = (YP(JB,322)+DTS*P)/(1.0+DTS*L)
C          P1028            Y(JB,323)
      P = 0.0
     &+(RC(JB,680)    *Y(JB,276))                                             
      L = DD(JB,323)+ DW(JB,323)
     &+(RC(JB,681)    )                                                    
      Y(JB,323) = (YP(JB,323)+DTS*P)/(1.0+DTS*L)
C          P1029            Y(JB,324)
      P = 0.0
     &+(RC(JB,682)    *Y(JB,277))                                             
      L = DD(JB,324)+ DW(JB,324)
     &+(RC(JB,683)    )                                                    
      Y(JB,324) = (YP(JB,324)+DTS*P)/(1.0+DTS*L)
C          P1030            Y(JB,325)
      P = 0.0
     &+(RC(JB,684)    *Y(JB,278))                                             
      L = DD(JB,325)+ DW(JB,325)
     &+(RC(JB,685)    )                                                    
      Y(JB,325) = (YP(JB,325)+DTS*P)/(1.0+DTS*L)
C          P1031            Y(JB,326)
      P = 0.0
     &+(RC(JB,686)    *Y(JB,279))                                             
      L = DD(JB,326)+ DW(JB,326)
     &+(RC(JB,687)    )                                                    
      Y(JB,326) = (YP(JB,326)+DTS*P)/(1.0+DTS*L)
C          P1032            Y(JB,327)
      P = 0.0
     &+(RC(JB,688)    *Y(JB,280))                                             
      L = DD(JB,327)+ DW(JB,327)
     &+(RC(JB,689)    )                                                    
      Y(JB,327) = (YP(JB,327)+DTS*P)/(1.0+DTS*L)
C          P1033            Y(JB,328)
      P = 0.0
     &+(RC(JB,690)    *Y(JB,281))                                             
      L = DD(JB,328)+ DW(JB,328)
     &+(RC(JB,691)    )                                                    
      Y(JB,328) = (YP(JB,328)+DTS*P)/(1.0+DTS*L)
C          P1034            Y(JB,329)
      P = 0.0
     &+(RC(JB,692)    *Y(JB,282))                                             
      L = DD(JB,329)+ DW(JB,329)
     &+(RC(JB,693)    )                                                    
      Y(JB,329) = (YP(JB,329)+DTS*P)/(1.0+DTS*L)
C          P1035            Y(JB,330)
      P = 0.0
     &+(RC(JB,694)    *Y(JB,283))                                             
      L = DD(JB,330)+ DW(JB,330)
     &+(RC(JB,695)    )                                                    
      Y(JB,330) = (YP(JB,330)+DTS*P)/(1.0+DTS*L)
C          P1036            Y(JB,331)
      P = 0.0
     &+(RC(JB,696)    *Y(JB,284))                                             
      L = DD(JB,331)+ DW(JB,331)
     &+(RC(JB,697)    )                                                    
      Y(JB,331) = (YP(JB,331)+DTS*P)/(1.0+DTS*L)
C          P1037            Y(JB,332)
      P = 0.0
     &+(RC(JB,698)    *Y(JB,285))                                             
      L = DD(JB,332)+ DW(JB,332)
     &+(RC(JB,699)    )                                                    
      Y(JB,332) = (YP(JB,332)+DTS*P)/(1.0+DTS*L)
C          P1038            Y(JB,333)
      P = 0.0
     &+(RC(JB,700)    *Y(JB,286))                                             
      L = DD(JB,333)+ DW(JB,333)
     &+(RC(JB,701)    )                                                    
      Y(JB,333) = (YP(JB,333)+DTS*P)/(1.0+DTS*L)
C          P1039            Y(JB,334)
      P = 0.0
     &+(RC(JB,702)    *Y(JB,287))                                             
      L = DD(JB,334)+ DW(JB,334)
     &+(RC(JB,703)    )                                                    
      Y(JB,334) = (YP(JB,334)+DTS*P)/(1.0+DTS*L)
C          P1040            Y(JB,335)
      P = 0.0
     &+(RC(JB,704)    *Y(JB,288))                                             
      L = DD(JB,335)+ DW(JB,335)
     &+(RC(JB,705)    )                                                    
      Y(JB,335) = (YP(JB,335)+DTS*P)/(1.0+DTS*L)
C          P1041            Y(JB,336)
      P = 0.0
     &+(RC(JB,706)    *Y(JB,289))                                             
      L = DD(JB,336)+ DW(JB,336)
     &+(RC(JB,707)    )                                                    
      Y(JB,336) = (YP(JB,336)+DTS*P)/(1.0+DTS*L)
C          P1042            Y(JB,337)
      P = 0.0
     &+(RC(JB,708)    *Y(JB,290))                                             
      L = DD(JB,337)+ DW(JB,337)
     &+(RC(JB,709)    )                                                    
      Y(JB,337) = (YP(JB,337)+DTS*P)/(1.0+DTS*L)
C          P1043            Y(JB,338)
      P = 0.0
     &+(RC(JB,710)    *Y(JB,291))                                             
      L = DD(JB,338)+ DW(JB,338)
     &+(RC(JB,711)    )                                                    
      Y(JB,338) = (YP(JB,338)+DTS*P)/(1.0+DTS*L)
C          P1044            Y(JB,339)
      P = 0.0
     &+(RC(JB,712)    *Y(JB,292))                                             
      L = DD(JB,339)+ DW(JB,339)
     &+(RC(JB,713)    )                                                    
      Y(JB,339) = (YP(JB,339)+DTS*P)/(1.0+DTS*L)
C          P1045            Y(JB,340)
      P = 0.0
     &+(RC(JB,714)    *Y(JB,293))                                             
      L = DD(JB,340)+ DW(JB,340)
     &+(RC(JB,715)    )                                                    
      Y(JB,340) = (YP(JB,340)+DTS*P)/(1.0+DTS*L)
C          P1046            Y(JB,341)
      P = 0.0
     &+(RC(JB,716)    *Y(JB,294))                                             
      L = DD(JB,341)+ DW(JB,341)
     &+(RC(JB,717)    )                                                    
      Y(JB,341) = (YP(JB,341)+DTS*P)/(1.0+DTS*L)
C          P1047            Y(JB,342)
      P = 0.0
     &+(RC(JB,718)    *Y(JB,295))                                             
      L = DD(JB,342)+ DW(JB,342)
     &+(RC(JB,719)    )                                                    
      Y(JB,342) = (YP(JB,342)+DTS*P)/(1.0+DTS*L)
C      iteration loop stop
  901   CONTINUE
 1000 CONTINUE
      DO JB=1,NBLOCK
        SO4(JB)=CS(JB,10)
      ENDDO
C
C      -----------------
C      THERMAL REACTIONS
C      -----------------
C
C      at end of iteration, calculate flux terms.
      DO 1021 JB=1,NBLOCK
C
C      O + O2 + M = O3 + M
      FLUX(JB,1)=FLUX(JB,1)+RC(JB,1)*Y(JB,2)*DTS/M(JB)
C      O + N2 + M = O3 + M
      FLUX(JB,2)=FLUX(JB,2)+RC(JB,2)*Y(JB,2)*DTS/M(JB)
C      O + O3 = 
      FLUX(JB,3)=FLUX(JB,3)+RC(JB,3)*Y(JB,2)*Y(JB,6)*DTS/M(JB)
C       O + NO = NO2
      FLUX(JB,4)=FLUX(JB,4)+RC(JB,8)*Y(JB,2)*Y(JB,8)*DTS/M(JB)
C      O + NO2 = NO
      FLUX(JB,5)=FLUX(JB,5)+RC(JB,5)*Y(JB,2)*Y(JB,4)*DTS/M(JB)
C      O + NO2 = NO3
      FLUX(JB,6)=FLUX(JB,6)+RC(JB,6)*Y(JB,2)*Y(JB,4)*DTS/M(JB)
C      O1D + O2 + M = O + M
      FLUX(JB,7)=FLUX(JB,7)+RC(JB,7)*Y(JB,1)*DTS/M(JB)
C      O1D + N2 + M = O + M
      FLUX(JB,8)=FLUX(JB,8)+RC(JB,8)*Y(JB,1)*DTS/M(JB)
C      NO + O3 = NO2
      FLUX(JB,9)=FLUX(JB,9) + RC(JB,9)*Y(JB,8)*Y(JB,6)*DTS/M(JB)
C      NO2 + O3 = NO3
      FLUX(JB,10)=FLUX(JB,10)+RC(JB,10)*Y(JB,4)*Y(JB,6)*DTS/M(JB)
C      NO + NO = NO2 + NO2
      FLUX(JB,11)=FLUX(JB,11)+RC(JB,11)*Y(JB,8)*Y(JB,8)*DTS/M(JB)
C      NO + NO3 = NO2 + NO2
      FLUX(JB,12)=FLUX(JB,12)+RC(JB,12)*Y(JB,8)*Y(JB,5)*DTS/M(JB)
C      NO2 + NO3 = NO + NO2
      FLUX(JB,13)=FLUX(JB,13)+RC(JB,13)*Y(JB,4)*Y(JB,5)*DTS/M(JB)
C      NO2 + NO3 = N2O5
      FLUX(JB,14)=FLUX(JB,14)+RC(JB,14)*Y(JB,4)*Y(JB,5)*DTS/M(JB)
C      N2O5 = NO2 + NO3
      FLUX(JB,15)=FLUX(JB,15)+RC(JB,15)*Y(JB,7)*DTS/M(JB)
C      O1D = OH + OH
      FLUX(JB,16)=FLUX(JB,16)+RC(JB,16)*Y(JB,1)*H2O(JB)*DTS/M(JB)
C      OH + O3 = HO2
      FLUX(JB,17)=FLUX(JB,17)+RC(JB,17)*Y(JB,3)*Y(JB,6)*DTS/M(JB)
C      OH + H2 = HO2
      FLUX(JB,18)=FLUX(JB,18)+RC(JB,18)*Y(JB,3)*Y(JB,10)*DTS/M(JB)
C       OH + CO = HO2
      FLUX(JB,19)=FLUX(JB,19)+RC(JB,19)*Y(JB,3)*Y(JB,11)*DTS/M(JB)
C      OH + H2O2 = HO2
      FLUX(JB,20)=FLUX(JB,20)+RC(JB,20)*Y(JB,3)*Y(JB,12)*DTS/M(JB)
C      HO2 + O3 = OH
      FLUX(JB,21)=FLUX(JB,21)+RC(JB,21)*Y(JB,9)*Y(JB,6)*DTS/M(JB)
C      OH + HO2 = 
      FLUX(JB,22)=FLUX(JB,22)+RC(JB,22)*Y(JB,3)*Y(JB,9)*DTS/M(JB)
C      HO2 + HO2 = H2O2
      FLUX(JB,23)=FLUX(JB,23)+RC(JB,23)*Y(JB,9)*Y(JB,9)*DTS/M(JB)
C      HO2 + HO2 = H2O2
      FLUX(JB,24)=FLUX(JB,24)+RC(JB,24)*Y(JB,9)*Y(JB,9)*DTS/M(JB)
C      OH + NO = HONO
      FLUX(JB,25)=FLUX(JB,25)+RC(JB,25)*Y(JB,3)*Y(JB,8)*DTS/M(JB)
C      NO2 = HONO
      FLUX(JB,26)=FLUX(JB,26)+RC(JB,26)*Y(JB,4)*DTS/M(JB)
C      OH + NO2 = HNO3
      FLUX(JB,27)=FLUX(JB,27)+RC(JB,27)*Y(JB,3)*Y(JB,4)*DTS/M(JB)
C      OH + NO3 = HO2 + NO2
      FLUX(JB,28)=FLUX(JB,28)+RC(JB,28)*Y(JB,3)*Y(JB,5)*DTS/M(JB)
C      HO2 + NO = OH + NO2
      FLUX(JB,29)=FLUX(JB,29)+RC(JB,29)*Y(JB,9)*Y(JB,8)*DTS/M(JB)
C      HO2 + NO2 = HO2NO2
      FLUX(JB,30)=FLUX(JB,30)+RC(JB,30)*Y(JB,9)*Y(JB,4)*DTS/M(JB)
C      HO2NO2 = HO2 + NO2
      FLUX(JB,31)=FLUX(JB,31)+RC(JB,31)*Y(JB,15)*DTS/M(JB)
C      OH + HO2NO2 = NO2 
      FLUX(JB,32)=FLUX(JB,32)+RC(JB,32)*Y(JB,3)*Y(JB,15)*DTS/M(JB)
C      HO2 + NO3 = OH + NO2
      FLUX(JB,33)=FLUX(JB,33)+RC(JB,33)*Y(JB,9)*Y(JB,5)*DTS/M(JB)
C      OH + HONO = NO2
      FLUX(JB,34)=FLUX(JB,34)+RC(JB,34)*Y(JB,3)*Y(JB,13)*DTS/M(JB)
C      OH + HNO3 = NO3
      FLUX(JB,35)=FLUX(JB,35)+RC(JB,35)*Y(JB,3)*Y(JB,14)*DTS/M(JB)
C      O + SO2 = SO3
      FLUX(JB,36)=FLUX(JB,36)+RC(JB,36)*Y(JB,2)*Y(JB,16)*DTS/M(JB)
C      OH + SO2 = HSO3 
      FLUX(JB,37)=FLUX(JB,37)+RC(JB,37)*Y(JB,3)*Y(JB,16)*DTS/M(JB)
C      HSO3 = HO2 + SO3
      FLUX(JB,38)=FLUX(JB,38)+RC(JB,38)*Y(JB,18)*DTS/M(JB)
C      HNO3 = NA
      FLUX(JB,39)=FLUX(JB,39)+RC(JB,39)*Y(JB,14)*DTS/M(JB)
C      N2O5 = NA + NA
      FLUX(JB,40)=FLUX(JB,40)+RC(JB,40)*Y(JB,7)*DTS/M(JB)
C      SO3 = SA
      FLUX(JB,41)=FLUX(JB,41)+RC(JB,41)*Y(JB,17)*DTS/M(JB)
C      OH + CH4 = CH3O2
      FLUX(JB,42)=FLUX(JB,42)+RC(JB,42)*Y(JB,3)*Y(JB,21)*DTS/M(JB)
C      OH + C2H6 = C2H5O2
      FLUX(JB,43)=FLUX(JB,43)+RC(JB,43)*Y(JB,3)*Y(JB,23)*DTS/M(JB)
C      OH + C3H8 = IC3H7O2
      FLUX(JB,44)=FLUX(JB,44)+RC(JB,44)*Y(JB,3)*Y(JB,25)*DTS/M(JB)
C      OH + C3H8 = RN10O2 
      FLUX(JB,45)=FLUX(JB,45)+RC(JB,45)*Y(JB,3)*Y(JB,25)*DTS/M(JB)
C      OH + NC4H10 = RN13O2
      FLUX(JB,46)=FLUX(JB,46)+RC(JB,46)*Y(JB,3)*Y(JB,28)*DTS/M(JB)
C      OH + C2H4 = HOCH2CH2O2
      FLUX(JB,47)=FLUX(JB,47)+RC(JB,47)*Y(JB,3)*Y(JB,30)*DTS/M(JB)
C      OH + C3H6 = RN9O2
      FLUX(JB,48)=FLUX(JB,48)+RC(JB,48)*Y(JB,3)*Y(JB,32)*DTS/M(JB)
C      OH + TBUT2ENE = RN12O2
      FLUX(JB,49)=FLUX(JB,49)+RC(JB,49)*Y(JB,3)*Y(JB,34)*DTS/M(JB)
C      NO3 + C2H4 = NRN6O2
      FLUX(JB,50)=FLUX(JB,50)+RC(JB,50)*Y(JB,5)*Y(JB,30)*DTS/M(JB)
C      NO3 + C3H6 = NRN9O2
      FLUX(JB,51)=FLUX(JB,51)+RC(JB,51)*Y(JB,5)*Y(JB,32)*DTS/M(JB)
C      NO3 + TBUT2ENE = NRN12O2
      FLUX(JB,52)=FLUX(JB,52)+RC(JB,52)*Y(JB,5)*Y(JB,34)*DTS/M(JB)
C      O3 + C2H4 = HCHO + CO + HO2 + OH
      FLUX(JB,53)=FLUX(JB,53)+RC(JB,53)*Y(JB,6)*Y(JB,30)*DTS/M(JB)
C      O3 + C2H4 = HCHO + CO
      FLUX(JB,54)=FLUX(JB,54)+RC(JB,54)*Y(JB,6)*Y(JB,30)*DTS/M(JB)
C      O3 + C3H6 = HCHO + CO + CH3O2 + OH
      FLUX(JB,55)=FLUX(JB,55)+RC(JB,55)*Y(JB,6)*Y(JB,32)*DTS/M(JB)
C      O3 + C3H6 = CH3CHO + SCIE
      FLUX(JB,56)=FLUX(JB,56)+RC(JB,56)*Y(JB,6)*Y(JB,32)*DTS/M(JB)
C      O3 + TBUT2ENE = CH3CHO + CO + CH3O2 + OH
      FLUX(JB,57)=FLUX(JB,57)+RC(JB,57)*Y(JB,6)*Y(JB,34)*DTS/M(JB)
C      O3 + TBUT2ENE = CH3CHO + SCIPA
      FLUX(JB,58)=FLUX(JB,58)+RC(JB,58)*Y(JB,6)*Y(JB,34)*DTS/M(JB)
C      OH + C5H8 = RU14O2
      FLUX(JB,59)=FLUX(JB,59)+RC(JB,59)*Y(JB,3)*Y(JB,43)*DTS/M(JB)
C      NO3 + C5H8 = NRU14O2
      FLUX(JB,60)=FLUX(JB,60)+RC(JB,60)*Y(JB,5)*Y(JB,43)*DTS/M(JB)
C      O3 + C5H8 = UCARB10 + CO + HO2 + OH
      FLUX(JB,61)=FLUX(JB,61)+RC(JB,61)*Y(JB,6)*Y(JB,43)*DTS/M(JB)
C      O3 + C5H8 = UCARB10 + SCIE
      FLUX(JB,62)=FLUX(JB,62)+RC(JB,62)*Y(JB,6)*Y(JB,43)*DTS/M(JB)
C      APINENE + OH = RTN28O2
      FLUX(JB,63)=FLUX(JB,63)+RC(JB,63)*Y(JB,47)*Y(JB,3)*DTS/M(JB)
C      APINENE + NO3 = NRTN28O2
      FLUX(JB,64)=FLUX(JB,64)+RC(JB,64)*Y(JB,47)*Y(JB,5)*DTS/M(JB)
C      APINENE + O3 = OH + RTN26O2 
      FLUX(JB,65)=FLUX(JB,65)+RC(JB,65)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C      APINENE + O3 = TNCARB26 + H2O2
      FLUX(JB,66)=FLUX(JB,66)+RC(JB,66)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C      APINENE + O3 = SCIPAA 
      FLUX(JB,67)=FLUX(JB,67)+RC(JB,67)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C      BPINENE + OH = RTX28O2
      FLUX(JB,68)=FLUX(JB,68)+RC(JB,68)*Y(JB,53)*Y(JB,3)*DTS/M(JB)
C      BPINENE + NO3 = NRTX28O2
      FLUX(JB,69)=FLUX(JB,69)+RC(JB,69)*Y(JB,53)*Y(JB,5)*DTS/M(JB)
C      BPINENE + O3 =  RTX24O2 + CO
      FLUX(JB,70)=FLUX(JB,70)+RC(JB,70)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C      BPINENE + O3 =  HCHO + TXCARB24 + H2O2
      FLUX(JB,71)=FLUX(JB,71)+RC(JB,71)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C      BPINENE + O3 =  HCHO + TXCARB22
      FLUX(JB,72)=FLUX(JB,72)+RC(JB,72)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C      BPINENE + O3 =  HCHO+SCIBPA 
      FLUX(JB,73)=FLUX(JB,73)+RC(JB,73)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C      C2H2 + OH = HCOOH + CO + HO2
      FLUX(JB,74)=FLUX(JB,74)+RC(JB,74)*Y(JB,59)*Y(JB,3)*DTS/M(JB)
C      C2H2 + OH = CARB3 + OH
      FLUX(JB,75)=FLUX(JB,75)+RC(JB,75)*Y(JB,59)*Y(JB,3)*DTS/M(JB)
C      BENZENE + OH = RA13O2
      FLUX(JB,76)=FLUX(JB,76)+RC(JB,76)*Y(JB,61)*Y(JB,3)*DTS/M(JB)
C      BENZENE + OH = AROH14 + HO2
      FLUX(JB,77)=FLUX(JB,77)+RC(JB,77)*Y(JB,61)*Y(JB,3)*DTS/M(JB)
C      TOLUENE + OH = RA16O2
      FLUX(JB,78)=FLUX(JB,78)+RC(JB,78)*Y(JB,64)*Y(JB,3)*DTS/M(JB)
C      TOLUENE + OH = AROH17 + HO2
      FLUX(JB,79)=FLUX(JB,79)+RC(JB,79)*Y(JB,64)*Y(JB,3)*DTS/M(JB)
C      OXYL + OH = RA19AO2
      FLUX(JB,80)=FLUX(JB,80)+RC(JB,80)*Y(JB,67)*Y(JB,3)*DTS/M(JB)
C      OXYL + OH = RA19CO2
      FLUX(JB,81)=FLUX(JB,81)+RC(JB,81)*Y(JB,67)*Y(JB,3)*DTS/M(JB)
C      OH + HCHO = HO2 + CO
      FLUX(JB,82)=FLUX(JB,82)+RC(JB,82)*Y(JB,3)*Y(JB,39)*DTS/M(JB)
C      OH + CH3CHO = CH3CO3
      FLUX(JB,83)=FLUX(JB,83)+RC(JB,83)*Y(JB,3)*Y(JB,42)*DTS/M(JB)
C      OH + C2H5CHO = C2H5CO3
      FLUX(JB,84)=FLUX(JB,84)+RC(JB,84)*Y(JB,3)*Y(JB,71)*DTS/M(JB)
C      NO3 + HCHO = HO2 + CO + HNO3
      FLUX(JB,85)=FLUX(JB,85)+RC(JB,85)*Y(JB,5)*Y(JB,39)*DTS/M(JB)
C      NO3 + CH3CHO = CH3CO3 + HNO3
      FLUX(JB,86)=FLUX(JB,86)+RC(JB,86)*Y(JB,5)*Y(JB,42)*DTS/M(JB)
C      NO3 + C2H5CHO = C2H5CO3 + HNO3
      FLUX(JB,87)=FLUX(JB,87)+RC(JB,87)*Y(JB,5)*Y(JB,71)*DTS/M(JB)
C      OH + CH3COCH3 = RN8O2
      FLUX(JB,88)=FLUX(JB,88)+RC(JB,88)*Y(JB,3)*Y(JB,73)*DTS/M(JB)
C      MEK + OH = RN11O2
      FLUX(JB,89)=FLUX(JB,89)+RC(JB,89)*Y(JB,101)*Y(JB,3)*DTS/M(JB)
C      OH + CH3OH = HO2 + HCHO
      FLUX(JB,90)=FLUX(JB,90)+RC(JB,90)*Y(JB,3)*Y(JB,76)*DTS/M(JB)
C      OH + C2H5OH = CH3CHO + HO2
      FLUX(JB,91)=FLUX(JB,91)+RC(JB,91)*Y(JB,3)*Y(JB,77)*DTS/M(JB)
C      OH + C2H5OH = HOCH2CH2O2 
      FLUX(JB,92)=FLUX(JB,92)+RC(JB,92)*Y(JB,3)*Y(JB,77)*DTS/M(JB)
C     NPROPOL + OH = C2H5CHO + HO2 
      FLUX(JB,93)=FLUX(JB,93)+RC(JB,93)*Y(JB,3)*Y(JB,78)*DTS/M(JB)
C      NPROPOL + OH = RN9O2
      FLUX(JB,94)=FLUX(JB,94)+RC(JB,94)*Y(JB,3)*Y(JB,78)*DTS/M(JB)
C      OH + IPROPOL = CH3COCH3 + HO2
      FLUX(JB,95)=FLUX(JB,95)+RC(JB,95)*Y(JB,3)*Y(JB,79)*DTS/M(JB)
C      OH + IPROPOL = RN9O2
      FLUX(JB,96)=FLUX(JB,96)+RC(JB,96)*Y(JB,3)*Y(JB,79)*DTS/M(JB)
C      HCOOH + OH = HO2
      FLUX(JB,97)=FLUX(JB,97)+RC(JB,97)*Y(JB,3)*Y(JB,40)*DTS/M(JB)
C      CH3CO2H + OH = CH3O2
      FLUX(JB,98)=FLUX(JB,98)+RC(JB,98)*Y(JB,3)*Y(JB,41)*DTS/M(JB)
C      OH + CH3CL = CH3O2 
      FLUX(JB,99)=FLUX(JB,99)+RC(JB,99)*Y(JB,3)*Y(JB,80)*DTS/M(JB)
C      OH + CH2CL2 = CH3O2
      FLUX(JB,100)=FLUX(JB,100)+RC(JB,100)*Y(JB,3)*Y(JB,81)*DTS/M(JB)
C      OH + CHCL3 = CH3O2
      FLUX(JB,101)=FLUX(JB,101)+RC(JB,101)*Y(JB,3)*Y(JB,80)*DTS/M(JB)
C      OH + CH3CCL3 = C2H5O2
      FLUX(JB,102)=FLUX(JB,102)+RC(JB,102)*Y(JB,3)*Y(JB,83)*DTS/M(JB)
C      OH + TCE = HOCH2CH2O2 
      FLUX(JB,103)=FLUX(JB,103)+RC(JB,103)*Y(JB,3)*Y(JB,84)*DTS/M(JB)
C      OH + TRICLETH = HOCH2CH2O2
      FLUX(JB,104)=FLUX(JB,104)+RC(JB,104)*Y(JB,3)*Y(JB,85)*DTS/M(JB)
C      OH + CDICLETH = HOCH2CH2O2
      FLUX(JB,105)=FLUX(JB,105)+RC(JB,105)*Y(JB,3)*Y(JB,86)*DTS/M(JB)
C      OH + TDICLETH = HOCH2CH2O2
      FLUX(JB,106)=FLUX(JB,106)+RC(JB,106)*Y(JB,3)*Y(JB,87)*DTS/M(JB)
C      CH3O2 + NO = HCHO + HO2 + NO2
      FLUX(JB,107)=FLUX(JB,107)+RC(JB,107)*Y(JB,8)*Y(JB,22)*DTS/M(JB)
C      C2H5O2 + NO = CH3CHO + HO2 + NO2
      FLUX(JB,108)=FLUX(JB,108)+RC(JB,108)*Y(JB,8)*Y(JB,24)*DTS/M(JB)
C      RN10O2 + NO = C2H5CHO + HO2 + NO2
      FLUX(JB,109)=FLUX(JB,109)+RC(JB,109)*Y(JB,8)*Y(JB,27)*DTS/M(JB)
C      IC3H7O2 + NO = CH3COCH3 + HO2 + NO2
      FLUX(JB,110)=FLUX(JB,110)+RC(JB,110)*Y(JB,8)*Y(JB,26)*DTS/M(JB)
C      RN13O2 + NO = CH3CHO + C2H5O2 + NO2 
      FLUX(JB,111)=FLUX(JB,111)+RC(JB,111)*Y(JB,8)*Y(JB,29)*DTS/M(JB)
C      RN13O2 + NO = CARB11A + HO2 + NO2
      FLUX(JB,112)=FLUX(JB,112)+RC(JB,112)*Y(JB,8)*Y(JB,29)*DTS/M(JB)
C      RN16O2 + NO = RN15AO2 + NO2 
      FLUX(JB,113)=FLUX(JB,113)+RC(JB,113)*Y(JB,8)*Y(JB,89)*DTS/M(JB)
C      RN19O2 + NO = RN18AO2 + NO2
      FLUX(JB,114)=FLUX(JB,114)+RC(JB,114)*Y(JB,8)*Y(JB,91)*DTS/M(JB)
C      RN13AO2 + NO = RN12O2 + NO2
      FLUX(JB,115)=FLUX(JB,115)+RC(JB,115)*Y(JB,8)*Y(JB,93)*DTS/M(JB)
C      RN16AO2 + NO = RN15O2 + NO2 
      FLUX(JB,116)=FLUX(JB,116)+RC(JB,116)*Y(JB,8)*Y(JB,94)*DTS/M(JB)
C      RA13O2 + NO = CARB3 + UDCARB8 + HO2 + NO2
      FLUX(JB,117)=FLUX(JB,117)+RC(JB,117)*Y(JB,8)*Y(JB,62)*DTS/M(JB)
C      RA16O2 + NO = CARB3 + UDCARB11 + HO2 + NO2 
      FLUX(JB,118)=FLUX(JB,118)+RC(JB,118)*Y(JB,8)*Y(JB,65)*DTS/M(JB)
C      RA16O2 + NO = CARB6 + UDCARB8 + HO2 + NO2  
      FLUX(JB,119)=FLUX(JB,119)+RC(JB,119)*Y(JB,8)*Y(JB,65)*DTS/M(JB)
C      RA19AO2 + NO = CARB3 + UDCARB14 + HO2 + NO2
      FLUX(JB,120)=FLUX(JB,120)+RC(JB,120)*Y(JB,8)*Y(JB,68)*DTS/M(JB)
C      RA19CO2 + NO = CARB9 + UDCARB8 + HO2 + NO2
      FLUX(JB,121)=FLUX(JB,121)+RC(JB,121)*Y(JB,8)*Y(JB,69)*DTS/M(JB)
C      HOCH2CH2O2 + NO = HCHO + HCHO + HO2 + NO2
      FLUX(JB,122)=FLUX(JB,122)+RC(JB,122)*Y(JB,8)*Y(JB,31)*DTS/M(JB)
C      HOCH2CH2O2 + NO = HOCH2CHO + HO2 + NO2
      FLUX(JB,123)=FLUX(JB,123)+RC(JB,123)*Y(JB,8)*Y(JB,31)*DTS/M(JB)
C       RN9O2 + NO = CH3CHO + HCHO + HO2 + NO2 
      FLUX(JB,124)=FLUX(JB,124)+RC(JB,124)*Y(JB,8)*Y(JB,33)*DTS/M(JB)
C      RN12O2 + NO = CH3CHO + CH3CHO + HO2 + NO2
      FLUX(JB,125)=FLUX(JB,125)+RC(JB,125)*Y(JB,8)*Y(JB,35)*DTS/M(JB)
C      RN15O2 + NO = C2H5CHO + CH3CHO + HO2 + NO2
      FLUX(JB,126)=FLUX(JB,126)+RC(JB,126)*Y(JB,8)*Y(JB,95)*DTS/M(JB)
C      RN18O2 + NO = C2H5CHO + C2H5CHO + HO2 + NO2 
      FLUX(JB,127)=FLUX(JB,127)+RC(JB,127)*Y(JB,8)*Y(JB,103)*DTS/M(JB)
C      RN15AO2 + NO = CARB13 + HO2 + NO2 
      FLUX(JB,128)=FLUX(JB,128)+RC(JB,128)*Y(JB,8)*Y(JB,90)*DTS/M(JB)
C      RN18AO2 + NO = CARB16 + HO2 + NO2
      FLUX(JB,129)=FLUX(JB,129)+RC(JB,129)*Y(JB,8)*Y(JB,92)*DTS/M(JB)
C      CH3CO3 + NO = CH3O2 + NO2 
      FLUX(JB,130)=FLUX(JB,130)+RC(JB,130)*Y(JB,8)*Y(JB,70)*DTS/M(JB)
C     C2H5CO3+NO->C2H5O2+NO2
      FLUX(JB,131)=FLUX(JB,131)+RC(JB,131)*Y(JB,8)*Y(JB,160)*DTS/M(JB)
C     HOCH2CO3+NO->HO2+HCHO+NO2
      FLUX(JB,132)=FLUX(JB,132)+RC(JB,132)*Y(JB,8)*Y(JB,106)*DTS/M(JB)
C     RN8O2+NO->CH3CO3+HCHO+NO2
      FLUX(JB,133)=FLUX(JB,133)+RC(JB,133)*Y(JB,8)*Y(JB,74)*DTS/M(JB)
C     RN11O2+NO->CH3CO3+CH3CHO+NO2
      FLUX(JB,134)=FLUX(JB,134)+RC(JB,134)*Y(JB,8)*Y(JB,75)*DTS/M(JB)
C     RN14O2+NO->C2H5CO3+CH3CHO+NO2
      FLUX(JB,135)=FLUX(JB,135)+RC(JB,135)*Y(JB,8)*Y(JB,107)*DTS/M(JB)
C     RN17O2+NO->RN16AO2+NO2
      FLUX(JB,136)=FLUX(JB,136)+RC(JB,136)*Y(JB,8)*Y(JB,108)*DTS/M(JB)
C     RU14O2+NO->UCARB12+HO2+NO2
      FLUX(JB,137)=FLUX(JB,137)+RC(JB,137)*Y(JB,8)*Y(JB,44)*DTS/M(JB)
C     RU14O2+NO->UCARB10+HCHO+HO2+NO2
      FLUX(JB,138)=FLUX(JB,138)+RC(JB,138)*Y(JB,8)*Y(JB,44)*DTS/M(JB)
C     RU12O2+NO->CH3CO3+HOCH2CHO+NO2
      FLUX(JB,139)=FLUX(JB,139)+RC(JB,139)*Y(JB,8)*Y(JB,110)*DTS/M(JB)
C     RU12O2+NO->CARB7+CO+HO2+NO2
      FLUX(JB,140)=FLUX(JB,140)+RC(JB,140)*Y(JB,8)*Y(JB,110)*DTS/M(JB)
C     RU10O2+NO->CH3CO3+HOCH2CHO+NO2
      FLUX(JB,141)=FLUX(JB,141)+RC(JB,141)*Y(JB,8)*Y(JB,112)*DTS/M(JB)
C     RU10O2+NO->CARB6+HCHO+HO2+NO2
      FLUX(JB,142)=FLUX(JB,142)+RC(JB,142)*Y(JB,8)*Y(JB,112)*DTS/M(JB)
C     RU10O2+NO->CARB7+HCHO+HO2+NO2
      FLUX(JB,143)=FLUX(JB,143)+RC(JB,143)*Y(JB,8)*Y(JB,112)*DTS/M(JB)
C     NRN6O2+NO->HCHO+HCHO+NO2+NO2
      FLUX(JB,144)=FLUX(JB,144)+RC(JB,144)*Y(JB,8)*Y(JB,36)*DTS/M(JB)
C     NRN9O2+NO->CH3CHO+HCHO+NO2+NO2
      FLUX(JB,145)=FLUX(JB,145)+RC(JB,145)*Y(JB,8)*Y(JB,37)*DTS/M(JB)
C     NRN12O2+NO->CH3CHO+CH3CHO+NO2+NO2
      FLUX(JB,146)=FLUX(JB,146)+RC(JB,146)*Y(JB,8)*Y(JB,38)*DTS/M(JB)
C     NRU14O2+NO->NUCARB12+HO2+NO2
      FLUX(JB,147)=FLUX(JB,147)+RC(JB,147)*Y(JB,8)*Y(JB,45)*DTS/M(JB)
C     NRU12O2+NO->NOA+CO+HO2+NO2
      FLUX(JB,148)=FLUX(JB,148)+RC(JB,148)*Y(JB,8)*Y(JB,114)*DTS/M(JB)
C     RTN28O2+NO->TNCARB26+HO2+NO2
      FLUX(JB,149)=FLUX(JB,149)+RC(JB,149)*Y(JB,8)*Y(JB,48)*DTS/M(JB)
C     RTN28O2+NO->CH3COCH3+RN19O2+NO2
      FLUX(JB,150)=FLUX(JB,150)+RC(JB,150)*Y(JB,8)*Y(JB,48)*DTS/M(JB)
C     NRTN28O2+NO->TNCARB26+NO2+NO2
      FLUX(JB,151)=FLUX(JB,151)+RC(JB,151)*Y(JB,8)*Y(JB,49)*DTS/M(JB)
C     RTN26O2+NO->RTN25O2+NO2
      FLUX(JB,152)=FLUX(JB,152)+RC(JB,152)*Y(JB,8)*Y(JB,50)*DTS/M(JB)
C     RTN25O2+NO->RTN24O2+NO2
      FLUX(JB,153)=FLUX(JB,153)+RC(JB,153)*Y(JB,8)*Y(JB,116)*DTS/M(JB)
C     RTN24O2+NO->RTN23O2+NO2
      FLUX(JB,154)=FLUX(JB,154)+RC(JB,154)*Y(JB,8)*Y(JB,117)*DTS/M(JB)
C     RTN23O2+NO->CH3COCH3+RTN14O2+NO2
      FLUX(JB,155)=FLUX(JB,155)+RC(JB,155)*Y(JB,8)*Y(JB,118)*DTS/M(JB)
C     RTN14O2+NO->HCHO+TNCARB10+HO2+NO2
      FLUX(JB,156)=FLUX(JB,156)+RC(JB,156)*Y(JB,8)*Y(JB,119)*DTS/M(JB)
C     RTN10O2+NO->RN8O2+CO+NO2
      FLUX(JB,157)=FLUX(JB,157)+RC(JB,157)*Y(JB,8)*Y(JB,121)*DTS/M(JB)
C     RTX28O2+NO->TXCARB24+HCHO+HO2+NO2
      FLUX(JB,158)=FLUX(JB,158)+RC(JB,158)*Y(JB,8)*Y(JB,54)*DTS/M(JB)
C     RTX28O2+NO->CH3COCH3+RN19O2+NO2
      FLUX(JB,159)=FLUX(JB,159)+RC(JB,159)*Y(JB,8)*Y(JB,54)*DTS/M(JB)
C     NRTX28O2+NO->TXCARB24+HCHO+NO2+NO2
      FLUX(JB,160)=FLUX(JB,160)+RC(JB,160)*Y(JB,8)*Y(JB,55)*DTS/M(JB)
C     RTX24O2+NO->TXCARB22+HO2+NO2
      FLUX(JB,161)=FLUX(JB,161)+RC(JB,161)*Y(JB,8)*Y(JB,56)*DTS/M(JB)
C     RTX24O2+NO->CH3COCH3+RN13AO2+HCHO+NO2
      FLUX(JB,162)=FLUX(JB,162)+RC(JB,162)*Y(JB,8)*Y(JB,56)*DTS/M(JB)
C     RTX22O2+NO->CH3COCH3+RN13O2+NO2
      FLUX(JB,163)=FLUX(JB,163)+RC(JB,163)*Y(JB,8)*Y(JB,122)*DTS/M(JB)
C     CH3O2+NO2->CH3O2NO2
      FLUX(JB,164)=FLUX(JB,164)+RC(JB,164)*Y(JB,4)*Y(JB,22)*DTS/M(JB)
C     CH3O2NO2->CH3O2+NO2
      FLUX(JB,165)=FLUX(JB,165)+RC(JB,165)*Y(JB,217)*DTS/M(JB)
C     CH3O2+NO->CH3NO3
      FLUX(JB,166)=FLUX(JB,166)+RC(JB,166)*Y(JB,8)*Y(JB,22)*DTS/M(JB)
C     C2H5O2+NO->C2H5NO3
      FLUX(JB,167)=FLUX(JB,167)+RC(JB,167)*Y(JB,8)*Y(JB,24)*DTS/M(JB)
C     RN10O2+NO->RN10NO3
      FLUX(JB,168)=FLUX(JB,168)+RC(JB,168)*Y(JB,8)*Y(JB,27)*DTS/M(JB)
C     IC3H7O2+NO->IC3H7NO3
      FLUX(JB,169)=FLUX(JB,169)+RC(JB,169)*Y(JB,8)*Y(JB,26)*DTS/M(JB)
C     RN13O2+NO->RN13NO3
      FLUX(JB,170)=FLUX(JB,170)+RC(JB,170)*Y(JB,8)*Y(JB,29)*DTS/M(JB)
C     RN16O2+NO->RN16NO3
      FLUX(JB,171)=FLUX(JB,171)+RC(JB,171)*Y(JB,8)*Y(JB,89)*DTS/M(JB)
C     RN19O2+NO->RN19NO3
      FLUX(JB,172)=FLUX(JB,172)+RC(JB,172)*Y(JB,8)*Y(JB,91)*DTS/M(JB)
C     HOCH2CH2O2+NO->HOC2H4NO3
      FLUX(JB,173)=FLUX(JB,173)+RC(JB,173)*Y(JB,8)*Y(JB,31)*DTS/M(JB)
C     RN9O2+NO->RN9NO3
      FLUX(JB,174)=FLUX(JB,174)+RC(JB,174)*Y(JB,8)*Y(JB,33)*DTS/M(JB)
C     RN12O2+NO->RN12NO3
      FLUX(JB,175)=FLUX(JB,175)+RC(JB,175)*Y(JB,8)*Y(JB,35)*DTS/M(JB)
C     RN15O2+NO->RN15NO3
      FLUX(JB,176)=FLUX(JB,176)+RC(JB,176)*Y(JB,8)*Y(JB,95)*DTS/M(JB)
C     RN18O2+NO->RN18NO3
      FLUX(JB,177)=FLUX(JB,177)+RC(JB,177)*Y(JB,8)*Y(JB,103)*DTS/M(JB)
C     RN15AO2+NO->RN15NO3
      FLUX(JB,178)=FLUX(JB,178)+RC(JB,178)*Y(JB,8)*Y(JB,90)*DTS/M(JB)
C     RN18AO2+NO->RN18NO3
      FLUX(JB,179)=FLUX(JB,179)+RC(JB,179)*Y(JB,8)*Y(JB,92)*DTS/M(JB)
C     RU14O2+NO->RU14NO3
      FLUX(JB,180)=FLUX(JB,180)+RC(JB,180)*Y(JB,8)*Y(JB,44)*DTS/M(JB)
C     RA13O2+NO->RA13NO3
      FLUX(JB,181)=FLUX(JB,181)+RC(JB,181)*Y(JB,8)*Y(JB,62)*DTS/M(JB)
C     RA16O2+NO->RA16NO3
      FLUX(JB,182)=FLUX(JB,182)+RC(JB,182)*Y(JB,8)*Y(JB,65)*DTS/M(JB)
C     RA19AO2+NO->RA19NO3
      FLUX(JB,183)=FLUX(JB,183)+RC(JB,183)*Y(JB,8)*Y(JB,68)*DTS/M(JB)
C     RA19CO2+NO->RA19NO3
      FLUX(JB,184)=FLUX(JB,184)+RC(JB,184)*Y(JB,8)*Y(JB,69)*DTS/M(JB)
C     RTN28O2+NO->RTN28NO3
      FLUX(JB,185)=FLUX(JB,185)+RC(JB,185)*Y(JB,8)*Y(JB,48)*DTS/M(JB)
C     RTN25O2+NO->RTN25NO3
      FLUX(JB,186)=FLUX(JB,186)+RC(JB,186)*Y(JB,8)*Y(JB,116)*DTS/M(JB)
C     RTX28O2+NO->RTX28NO3
      FLUX(JB,187)=FLUX(JB,187)+RC(JB,187)*Y(JB,8)*Y(JB,54)*DTS/M(JB)
C     RTX24O2+NO->RTX24NO3
      FLUX(JB,188)=FLUX(JB,188)+RC(JB,188)*Y(JB,8)*Y(JB,56)*DTS/M(JB)
C     RTX22O2+NO->RTX22NO3
      FLUX(JB,189)=FLUX(JB,189)+RC(JB,189)*Y(JB,8)*Y(JB,122)*DTS/M(JB)
C     CH3O2+NO3->HCHO+HO2+NO2
      FLUX(JB,190)=FLUX(JB,190)+RC(JB,190)*Y(JB,5)*Y(JB,22)*DTS/M(JB)
C     C2H5O2+NO3->CH3CHO+HO2+NO2
      FLUX(JB,191)=FLUX(JB,191)+RC(JB,191)*Y(JB,5)*Y(JB,24)*DTS/M(JB)
C     RN10O2+NO3->C2H5CHO+HO2+NO2
      FLUX(JB,192)=FLUX(JB,192)+RC(JB,192)*Y(JB,5)*Y(JB,27)*DTS/M(JB)
C     IC3H7O2+NO3->CH3COCH3+HO2+NO2
      FLUX(JB,193)=FLUX(JB,193)+RC(JB,193)*Y(JB,5)*Y(JB,26)*DTS/M(JB)
C     RN13O2+NO3->CH3CHO+C2H5O2+NO2
      FLUX(JB,194)=FLUX(JB,194)+RC(JB,194)*Y(JB,5)*Y(JB,29)*DTS/M(JB)
C     RN13O2+NO3->CARB11A+HO2+NO2
      FLUX(JB,195)=FLUX(JB,195)+RC(JB,195)*Y(JB,5)*Y(JB,29)*DTS/M(JB)
C     RN16O2+NO3->RN15AO2+NO2
      FLUX(JB,196)=FLUX(JB,196)+RC(JB,196)*Y(JB,5)*Y(JB,89)*DTS/M(JB)
C     RN19O2+NO3->RN18AO2+NO2
      FLUX(JB,197)=FLUX(JB,197)+RC(JB,197)*Y(JB,5)*Y(JB,91)*DTS/M(JB)
C     RN13AO2+NO3->RN12O2+NO2
      FLUX(JB,198)=FLUX(JB,198)+RC(JB,198)*Y(JB,5)*Y(JB,93)*DTS/M(JB)
C     RN16AO2+NO3->RN15O2+NO2
      FLUX(JB,199)=FLUX(JB,199)+RC(JB,199)*Y(JB,5)*Y(JB,94)*DTS/M(JB)
C     RA13O2+NO3->CARB3+UDCARB8+HO2+NO2
      FLUX(JB,200)=FLUX(JB,200)+RC(JB,200)*Y(JB,5)*Y(JB,62)*DTS/M(JB)
C     RA16O2+NO3->CARB3+UDCARB11+HO2+NO2
      FLUX(JB,201)=FLUX(JB,201)+RC(JB,201)*Y(JB,5)*Y(JB,65)*DTS/M(JB)
C     RA16O2+NO3->CARB6+UDCARB8+HO2+NO2
      FLUX(JB,202)=FLUX(JB,202)+RC(JB,202)*Y(JB,5)*Y(JB,65)*DTS/M(JB)
C     RA19AO2+NO3->CARB3+UDCARB14+HO2+NO2
      FLUX(JB,203)=FLUX(JB,203)+RC(JB,203)*Y(JB,5)*Y(JB,68)*DTS/M(JB)
C     RA19CO2+NO3->CARB9+UDCARB8+HO2+NO2
      FLUX(JB,204)=FLUX(JB,204)+RC(JB,204)*Y(JB,5)*Y(JB,69)*DTS/M(JB)
C     HOCH2CH2O2+NO3->HCHO+HCHO+HO2+NO2
      FLUX(JB,205)=FLUX(JB,205)+RC(JB,205)*Y(JB,5)*Y(JB,31)*DTS/M(JB)
C     HOCH2CH2O2+NO3->HOCH2CHO+HO2+NO2
      FLUX(JB,206)=FLUX(JB,206)+RC(JB,206)*Y(JB,5)*Y(JB,31)*DTS/M(JB)
C     RN9O2+NO3->CH3CHO+HCHO+HO2+NO2
      FLUX(JB,207)=FLUX(JB,207)+RC(JB,207)*Y(JB,5)*Y(JB,33)*DTS/M(JB)
C     RN12O2+NO3->CH3CHO+CH3CHO+HO2+NO2
      FLUX(JB,208)=FLUX(JB,208)+RC(JB,208)*Y(JB,5)*Y(JB,35)*DTS/M(JB)
C     RN15O2+NO3->C2H5CHO+CH3CHO+HO2+NO2
      FLUX(JB,209)=FLUX(JB,209)+RC(JB,209)*Y(JB,5)*Y(JB,95)*DTS/M(JB)
C     RN18O2+NO3->C2H5CHO+C2H5CHO+HO2+NO2
      FLUX(JB,210)=FLUX(JB,210)+RC(JB,210)*Y(JB,5)*Y(JB,103)*DTS/M(JB)
C     RN15AO2+NO3->CARB13+HO2+NO2
      FLUX(JB,211)=FLUX(JB,211)+RC(JB,211)*Y(JB,5)*Y(JB,90)*DTS/M(JB)
C     RN18AO2+NO3->CARB16+HO2+NO2
      FLUX(JB,212)=FLUX(JB,212)+RC(JB,212)*Y(JB,5)*Y(JB,92)*DTS/M(JB)
C     CH3CO3+NO3->CH3O2+NO2
      FLUX(JB,213)=FLUX(JB,213)+RC(JB,213)*Y(JB,5)*Y(JB,70)*DTS/M(JB)
C     C2H5CO3+NO3->C2H5O2+NO2
      FLUX(JB,214)=FLUX(JB,214)+RC(JB,214)*Y(JB,5)*Y(JB,72)*DTS/M(JB)
C     HOCH2CO3+NO3->HO2+HCHO+NO2
      FLUX(JB,215)=FLUX(JB,215)+RC(JB,215)*Y(JB,5)*Y(JB,106)*DTS/M(JB)
C     RN8O2+NO3->CH3CO3+HCHO+NO2
      FLUX(JB,216)=FLUX(JB,216)+RC(JB,216)*Y(JB,5)*Y(JB,74)*DTS/M(JB)
C     RN11O2+NO3->CH3CO3+CH3CHO+NO2
      FLUX(JB,217)=FLUX(JB,217)+RC(JB,217)*Y(JB,5)*Y(JB,75)*DTS/M(JB)
C     RN14O2+NO3->C2H5CO3+CH3CHO+NO2
      FLUX(JB,218)=FLUX(JB,218)+RC(JB,218)*Y(JB,5)*Y(JB,107)*DTS/M(JB)
C     RN17O2+NO3->RN16AO2+NO2
      FLUX(JB,219)=FLUX(JB,219)+RC(JB,219)*Y(JB,5)*Y(JB,108)*DTS/M(JB)
C     RU14O2+NO3->UCARB12+HO2+NO2
      FLUX(JB,220)=FLUX(JB,220)+RC(JB,220)*Y(JB,5)*Y(JB,44)*DTS/M(JB)
C     RU14O2+NO3->UCARB10+HCHO+HO2+NO2
      FLUX(JB,221)=FLUX(JB,221)+RC(JB,221)*Y(JB,5)*Y(JB,44)*DTS/M(JB)
C     RU12O2+NO3->CH3CO3+HOCH2CHO+NO2
      FLUX(JB,222)=FLUX(JB,222)+RC(JB,222)*Y(JB,5)*Y(JB,110)*DTS/M(JB)
C     RU12O2+NO3->CARB7+CO+HO2+NO2
      FLUX(JB,223)=FLUX(JB,223)+RC(JB,223)*Y(JB,5)*Y(JB,110)*DTS/M(JB)
C     RU10O2+NO3->CH3CO3+HOCH2CHO+NO2
      FLUX(JB,224)=FLUX(JB,224)+RC(JB,224)*Y(JB,5)*Y(JB,112)*DTS/M(JB)
C     RU10O2+NO3->CARB6+HCHO+HO2+NO2
      FLUX(JB,225)=FLUX(JB,225)+RC(JB,225)*Y(JB,5)*Y(JB,112)*DTS/M(JB)
C     RU10O2+NO3->CARB7+HCHO+HO2+NO2
      FLUX(JB,226)=FLUX(JB,226)+RC(JB,226)*Y(JB,5)*Y(JB,112)*DTS/M(JB)
C     NRN6O2+NO3->HCHO+HCHO+NO2+NO2
      FLUX(JB,227)=FLUX(JB,227)+RC(JB,227)*Y(JB,5)*Y(JB,36)*DTS/M(JB)
C     NRN9O2+NO3->CH3CHO+HCHO+NO2+NO2
      FLUX(JB,228)=FLUX(JB,228)+RC(JB,228)*Y(JB,5)*Y(JB,37)*DTS/M(JB)
C     NRN12O2+NO3->CH3CHO+CH3CHO+NO2+NO2
      FLUX(JB,229)=FLUX(JB,229)+RC(JB,229)*Y(JB,5)*Y(JB,38)*DTS/M(JB)
C     NRU14O2+NO3->NUCARB12+HO2+NO2
      FLUX(JB,230)=FLUX(JB,230)+RC(JB,230)*Y(JB,5)*Y(JB,45)*DTS/M(JB)
C     NRU12O2+NO3->NOA+CO+HO2+NO2
      FLUX(JB,231)=FLUX(JB,231)+RC(JB,231)*Y(JB,5)*Y(JB,114)*DTS/M(JB)
C     RTN28O2+NO3->TNCARB26+HO2+NO2
      FLUX(JB,232)=FLUX(JB,232)+RC(JB,232)*Y(JB,5)*Y(JB,48)*DTS/M(JB)
C     NRTN28O2+NO3->TNCARB26+NO2+NO2
      FLUX(JB,233)=FLUX(JB,233)+RC(JB,233)*Y(JB,5)*Y(JB,49)*DTS/M(JB)
C     RTN26O2+NO3->RTN25O2+NO2
      FLUX(JB,234)=FLUX(JB,234)+RC(JB,234)*Y(JB,5)*Y(JB,50)*DTS/M(JB)
C     RTN25O2+NO3->RTN24O2+NO2
      FLUX(JB,235)=FLUX(JB,235)+RC(JB,235)*Y(JB,5)*Y(JB,116)*DTS/M(JB)
C     RTN24O2+NO3->RTN23O2+NO2
      FLUX(JB,236)=FLUX(JB,236)+RC(JB,236)*Y(JB,5)*Y(JB,117)*DTS/M(JB)
C     RTN23O2+NO3->CH3COCH3+RTN14O2+NO2
      FLUX(JB,237)=FLUX(JB,237)+RC(JB,237)*Y(JB,5)*Y(JB,118)*DTS/M(JB)
C     RTN14O2+NO3->HCHO+TNCARB10+HO2+NO2
      FLUX(JB,238)=FLUX(JB,238)+RC(JB,238)*Y(JB,5)*Y(JB,119)*DTS/M(JB)
C     RTN10O2+NO3->RN8O2+CO+NO2
      FLUX(JB,239)=FLUX(JB,239)+RC(JB,239)*Y(JB,5)*Y(JB,121)*DTS/M(JB)
C     RTX28O2+NO3->TXCARB24+HCHO+HO2+NO2
      FLUX(JB,240)=FLUX(JB,240)+RC(JB,240)*Y(JB,5)*Y(JB,54)*DTS/M(JB)
C     RTX24O2+NO3->TXCARB22+HO2+NO2
      FLUX(JB,241)=FLUX(JB,241)+RC(JB,241)*Y(JB,5)*Y(JB,56)*DTS/M(JB)
C     RTX22O2+NO3->CH3COCH3+RN13O2+NO2
      FLUX(JB,242)=FLUX(JB,242)+RC(JB,242)*Y(JB,5)*Y(JB,122)*DTS/M(JB)
C     NRTX28O2+NO3->TXCARB24+HCHO+NO2+NO2
      FLUX(JB,243)=FLUX(JB,243)+RC(JB,243)*Y(JB,5)*Y(JB,55)*DTS/M(JB)
C     CH3O2+HO2->CH3OOH
      FLUX(JB,244)=FLUX(JB,244)+RC(JB,244)*Y(JB,9)*Y(JB,22)*DTS/M(JB)
C     C2H5O2+HO2->C2H5OOH
      FLUX(JB,245)=FLUX(JB,245)+RC(JB,245)*Y(JB,9)*Y(JB,24)*DTS/M(JB)
C     RN10O2+HO2->RN10OOH
      FLUX(JB,246)=FLUX(JB,246)+RC(JB,246)*Y(JB,9)*Y(JB,27)*DTS/M(JB)
C     IC3H7O2+HO2->IC3H7OOH
      FLUX(JB,247)=FLUX(JB,247)+RC(JB,247)*Y(JB,9)*Y(JB,26)*DTS/M(JB)
C     RN13O2+HO2->RN13OOH
      FLUX(JB,248)=FLUX(JB,248)+RC(JB,248)*Y(JB,9)*Y(JB,29)*DTS/M(JB)
C     RN16O2+HO2->RN16OOH
      FLUX(JB,249)=FLUX(JB,249)+RC(JB,249)*Y(JB,9)*Y(JB,89)*DTS/M(JB)
C     RN19O2+HO2->RN19OOH
      FLUX(JB,250)=FLUX(JB,250)+RC(JB,250)*Y(JB,9)*Y(JB,91)*DTS/M(JB)
C     RN13AO2+HO2->RN13OOH
      FLUX(JB,251)=FLUX(JB,251)+RC(JB,251)*Y(JB,9)*Y(JB,93)*DTS/M(JB)
C     RN16AO2+HO2->RN16OOH
      FLUX(JB,252)=FLUX(JB,252)+RC(JB,252)*Y(JB,9)*Y(JB,94)*DTS/M(JB)
C     RA13O2+HO2->RA13OOH
      FLUX(JB,253)=FLUX(JB,253)+RC(JB,253)*Y(JB,9)*Y(JB,62)*DTS/M(JB)
C     RA16O2+HO2->RA16OOH
      FLUX(JB,254)=FLUX(JB,254)+RC(JB,254)*Y(JB,9)*Y(JB,65)*DTS/M(JB)
C     RA19AO2+HO2->RA19OOH
      FLUX(JB,255)=FLUX(JB,255)+RC(JB,255)*Y(JB,9)*Y(JB,68)*DTS/M(JB)
C     RA19CO2+HO2->RA19OOH
      FLUX(JB,256)=FLUX(JB,256)+RC(JB,256)*Y(JB,9)*Y(JB,69)*DTS/M(JB)
C     HOCH2CH2O2+HO2->HOC2H4OOH
      FLUX(JB,257)=FLUX(JB,257)+RC(JB,257)*Y(JB,9)*Y(JB,31)*DTS/M(JB)
C     RN9O2+HO2->RN9OOH
      FLUX(JB,258)=FLUX(JB,258)+RC(JB,258)*Y(JB,9)*Y(JB,33)*DTS/M(JB)
C     RN12O2+HO2->RN12OOH
      FLUX(JB,259)=FLUX(JB,259)+RC(JB,259)*Y(JB,9)*Y(JB,35)*DTS/M(JB)
C     RN15O2+HO2->RN15OOH
      FLUX(JB,260)=FLUX(JB,260)+RC(JB,260)*Y(JB,9)*Y(JB,95)*DTS/M(JB)
C     RN18O2+HO2->RN18OOH
      FLUX(JB,261)=FLUX(JB,261)+RC(JB,261)*Y(JB,9)*Y(JB,103)*DTS/M(JB)
C     RN15AO2+HO2->RN15OOH
      FLUX(JB,262)=FLUX(JB,262)+RC(JB,262)*Y(JB,9)*Y(JB,90)*DTS/M(JB)
C     RN18AO2+HO2->RN18OOH
      FLUX(JB,263)=FLUX(JB,263)+RC(JB,263)*Y(JB,9)*Y(JB,92)*DTS/M(JB)
C     CH3CO3+HO2->CH3CO3H
      FLUX(JB,264)=FLUX(JB,264)+RC(JB,264)*Y(JB,9)*Y(JB,70)*DTS/M(JB)
C     C2H5CO3+HO2->C2H5CO3H
      FLUX(JB,265)=FLUX(JB,265)+RC(JB,265)*Y(JB,9)*Y(JB,72)*DTS/M(JB)
C     HOCH2CO3+HO2->HOCH2CO3H
      FLUX(JB,266)=FLUX(JB,266)+RC(JB,266)*Y(JB,9)*Y(JB,106)*DTS/M(JB)
C     RN8O2+HO2->RN8OOH
      FLUX(JB,267)=FLUX(JB,267)+RC(JB,267)*Y(JB,9)*Y(JB,74)*DTS/M(JB)
C     RN11O2+HO2->RN11OOH
      FLUX(JB,268)=FLUX(JB,268)+RC(JB,268)*Y(JB,9)*Y(JB,75)*DTS/M(JB)
C     RN14O2+HO2->RN14OOH
      FLUX(JB,269)=FLUX(JB,269)+RC(JB,269)*Y(JB,9)*Y(JB,107)*DTS/M(JB)
C     RN17O2+HO2->RN17OOH
      FLUX(JB,270)=FLUX(JB,270)+RC(JB,270)*Y(JB,9)*Y(JB,108)*DTS/M(JB)
C	RU14O2+HO2->RU14OOH
      FLUX(JB,271)=FLUX(JB,271)+RC(JB,271)*Y(JB,9)*Y(JB,44)*DTS/M(JB)
C	RU12O2+HO2->RU12OOH
      FLUX(JB,272)=FLUX(JB,272)+RC(JB,272)*Y(JB,9)*Y(JB,110)*DTS/M(JB)
C	RU10O2+HO2->RU10OOH
      FLUX(JB,273)=FLUX(JB,273)+RC(JB,273)*Y(JB,9)*Y(JB,112)*DTS/M(JB)
C	NRN6O2+HO2->NRN6OOH
      FLUX(JB,274)=FLUX(JB,274)+RC(JB,274)*Y(JB,9)*Y(JB,36)*DTS/M(JB)
C	NRN9O2+HO2->NRN9OOH
      FLUX(JB,275)=FLUX(JB,275)+RC(JB,275)*Y(JB,9)*Y(JB,37)*DTS/M(JB)
C	NRN12O2+HO2->NRN12OOH
      FLUX(JB,276)=FLUX(JB,276)+RC(JB,276)*Y(JB,9)*Y(JB,38)*DTS/M(JB)
C	NRU14O2+HO2->NRU14OOH
      FLUX(JB,277)=FLUX(JB,277)+RC(JB,277)*Y(JB,9)*Y(JB,45)*DTS/M(JB)
C	NRU12O2+HO2->NRU12OOH
      FLUX(JB,278)=FLUX(JB,278)+RC(JB,278)*Y(JB,9)*Y(JB,114)*DTS/M(JB)
C	RTN28O2+HO2->RTN28OOH
      FLUX(JB,279)=FLUX(JB,279)+RC(JB,279)*Y(JB,9)*Y(JB,48)*DTS/M(JB)
C	NRTN28O2+HO2->NRTN28OOH
      FLUX(JB,280)=FLUX(JB,280)+RC(JB,280)*Y(JB,9)*Y(JB,49)*DTS/M(JB)
C	RTN26O2+HO2->RTN26OOH
      FLUX(JB,281)=FLUX(JB,281)+RC(JB,281)*Y(JB,9)*Y(JB,50)*DTS/M(JB)
C	RTN25O2+HO2->RTN25OOH
      FLUX(JB,282)=FLUX(JB,282)+RC(JB,282)*Y(JB,9)*Y(JB,116)*DTS/M(JB)
C	RTN24O2+HO2->RTN24OOH
      FLUX(JB,283)=FLUX(JB,283)+RC(JB,283)*Y(JB,9)*Y(JB,117)*DTS/M(JB)
C	RTN23O2+HO2->RTN23OOH
      FLUX(JB,284)=FLUX(JB,284)+RC(JB,284)*Y(JB,9)*Y(JB,118)*DTS/M(JB)
C	RTN14O2+HO2->RTN14OOH
      FLUX(JB,285)=FLUX(JB,285)+RC(JB,285)*Y(JB,9)*Y(JB,119)*DTS/M(JB)
C	RTN10O2+HO2->RTN10OOH
      FLUX(JB,286)=FLUX(JB,286)+RC(JB,286)*Y(JB,9)*Y(JB,121)*DTS/M(JB)
C	RTX28O2+HO2->RTX28OOH
      FLUX(JB,287)=FLUX(JB,287)+RC(JB,287)*Y(JB,9)*Y(JB,54)*DTS/M(JB)
C	RTX24O2+HO2->RTX24OOH
      FLUX(JB,288)=FLUX(JB,288)+RC(JB,288)*Y(JB,9)*Y(JB,56)*DTS/M(JB)
C	RTX22O2+HO2->RTX22OOH
      FLUX(JB,289)=FLUX(JB,289)+RC(JB,289)*Y(JB,9)*Y(JB,122)*DTS/M(JB)
C	NRTX28O2+HO2->NRTX28OOH
      FLUX(JB,290)=FLUX(JB,290)+RC(JB,290)*Y(JB,9)*Y(JB,55)*DTS/M(JB)
C	CH3O2->HCHO+HO2
      FLUX(JB,291)=FLUX(JB,291)+RC(JB,291)*Y(JB,22)*DTS/M(JB)
C	CH3O2->HCHO
      FLUX(JB,292)=FLUX(JB,292)+RC(JB,292)*Y(JB,22)*DTS/M(JB)
C	CH3O2->CH3OH
      FLUX(JB,293)=FLUX(JB,293)+RC(JB,293)*Y(JB,22)*DTS/M(JB)
C	C2H5O2->CH3CHO+HO2
      FLUX(JB,294)=FLUX(JB,294)+RC(JB,294)*Y(JB,24)*DTS/M(JB)
C	C2H5O2->CH3CHO
      FLUX(JB,295)=FLUX(JB,295)+RC(JB,295)*Y(JB,24)*DTS/M(JB)
C	C2H5O2->C2H5OH
      FLUX(JB,296)=FLUX(JB,296)+RC(JB,296)*Y(JB,24)*DTS/M(JB)
C	RN10O2->C2H5CHO+HO2
      FLUX(JB,297)=FLUX(JB,297)+RC(JB,297)*Y(JB,27)*DTS/M(JB)
C	RN10O2->C2H5CHO
      FLUX(JB,298)=FLUX(JB,298)+RC(JB,298)*Y(JB,27)*DTS/M(JB)
C	RN10O2->NPROPOL
      FLUX(JB,299)=FLUX(JB,299)+RC(JB,299)*Y(JB,27)*DTS/M(JB)
C	IC3H7O2->CH3COCH3+HO2
      FLUX(JB,300)=FLUX(JB,300)+RC(JB,300)*Y(JB,26)*DTS/M(JB)
C	IC3H7O2->CH3COCH3
      FLUX(JB,301)=FLUX(JB,301)+RC(JB,301)*Y(JB,26)*DTS/M(JB)
C	IC3H7O2->IPROPOL
      FLUX(JB,302)=FLUX(JB,302)+RC(JB,302)*Y(JB,26)*DTS/M(JB)
C	RN13O2->CH3CHO+C2H5O2
      FLUX(JB,303)=FLUX(JB,303)+RC(JB,303)*Y(JB,29)*DTS/M(JB)
C	RN13O2->CARB11A+HO2
      FLUX(JB,304)=FLUX(JB,304)+RC(JB,304)*Y(JB,29)*DTS/M(JB)
C	RN13AO2->RN12O2
      FLUX(JB,305)=FLUX(JB,305)+RC(JB,305)*Y(JB,93)*DTS/M(JB)
C	RN16AO2->RN15O2
      FLUX(JB,306)=FLUX(JB,306)+RC(JB,306)*Y(JB,94)*DTS/M(JB)
C	RA13O2->CARB3+UDCARB8+HO2
      FLUX(JB,307)=FLUX(JB,307)+RC(JB,307)*Y(JB,62)*DTS/M(JB)
C	RA16O2->CARB3+UDCARB11+HO2
      FLUX(JB,308)=FLUX(JB,308)+RC(JB,308)*Y(JB,65)*DTS/M(JB)
C	RA16O2->CARB6+UDCARB8+HO2
      FLUX(JB,309)=FLUX(JB,309)+RC(JB,309)*Y(JB,65)*DTS/M(JB)
C	RA19AO2->CARB3+UDCARB14+HO2
      FLUX(JB,310)=FLUX(JB,310)+RC(JB,310)*Y(JB,68)*DTS/M(JB)
C	RA19CO2->CARB3+UDCARB14+HO2
      FLUX(JB,311)=FLUX(JB,311)+RC(JB,311)*Y(JB,69)*DTS/M(JB)
C	RN16O2->RN15AO2
      FLUX(JB,312)=FLUX(JB,312)+RC(JB,312)*Y(JB,89)*DTS/M(JB)
C	RN19O2->RN18AO2
      FLUX(JB,313)=FLUX(JB,313)+RC(JB,313)*Y(JB,91)*DTS/M(JB)
C	HOCH2CH2O2->HCHO+HCHO+HO2
      FLUX(JB,314)=FLUX(JB,314)+RC(JB,314)*Y(JB,31)*DTS/M(JB)
C	HOCH2CH2O2->HOCH2CHO+HO2
      FLUX(JB,315)=FLUX(JB,315)+RC(JB,315)*Y(JB,31)*DTS/M(JB)
C	RN9O2->CH3CHO+HCHO+HO2
      FLUX(JB,316)=FLUX(JB,316)+RC(JB,316)*Y(JB,33)*DTS/M(JB)
C	RN12O2->CH3CHO+CH3CHO+HO2
      FLUX(JB,317)=FLUX(JB,317)+RC(JB,317)*Y(JB,35)*DTS/M(JB)
C	RN15O2->C2H5CHO+CH3CHO+HO2
      FLUX(JB,318)=FLUX(JB,318)+RC(JB,318)*Y(JB,95)*DTS/M(JB)
C	RN18O2->C2H5CHO+C2H5CHO+HO2
      FLUX(JB,319)=FLUX(JB,319)+RC(JB,319)*Y(JB,103)*DTS/M(JB)
C	RN15AO2->CARB13+HO2
      FLUX(JB,320)=FLUX(JB,320)+RC(JB,320)*Y(JB,90)*DTS/M(JB)
C	RN18AO2->CARB16+HO2
      FLUX(JB,321)=FLUX(JB,321)+RC(JB,321)*Y(JB,92)*DTS/M(JB)
C	CH3CO3->CH3O2
      FLUX(JB,322)=FLUX(JB,322)+RC(JB,322)*Y(JB,70)*DTS/M(JB)
C	C2H5CO3->C2H5O2
      FLUX(JB,323)=FLUX(JB,323)+RC(JB,323)*Y(JB,72)*DTS/M(JB)
C	HOCH2CO3->HCHO+HO2
      FLUX(JB,324)=FLUX(JB,324)+RC(JB,324)*Y(JB,106)*DTS/M(JB)
C	RN8O2->CH3CO3+HCHO
      FLUX(JB,325)=FLUX(JB,325)+RC(JB,325)*Y(JB,74)*DTS/M(JB)
C	RN11O2->CH3CO3+CH3CHO
      FLUX(JB,326)=FLUX(JB,326)+RC(JB,326)*Y(JB,75)*DTS/M(JB)
C	RN14O2->C2H5CO3+CH3CHO
      FLUX(JB,327)=FLUX(JB,327)+RC(JB,327)*Y(JB,107)*DTS/M(JB)
C	RN17O2->RN16AO2
      FLUX(JB,328)=FLUX(JB,328)+RC(JB,328)*Y(JB,108)*DTS/M(JB)
C	RU14O2->UCARB12+HO2
      FLUX(JB,329)=FLUX(JB,329)+RC(JB,329)*Y(JB,44)*DTS/M(JB)
C	RU14O2->UCARB10+HCHO+HO2
      FLUX(JB,330)=FLUX(JB,330)+RC(JB,330)*Y(JB,44)*DTS/M(JB)
C	RU12O2->CH3CO3+HOCH2CHO
      FLUX(JB,331)=FLUX(JB,331)+RC(JB,331)*Y(JB,110)*DTS/M(JB)
C	RU12O2->CARB7+HOCH2CHO+HO2
      FLUX(JB,332)=FLUX(JB,332)+RC(JB,332)*Y(JB,110)*DTS/M(JB)
C	RU10O2->CH3CO3+HOCH2CHO
      FLUX(JB,333)=FLUX(JB,333)+RC(JB,333)*Y(JB,112)*DTS/M(JB)
C	RU10O2->CARB6+HCHO+HO2
      FLUX(JB,334)=FLUX(JB,334)+RC(JB,334)*Y(JB,112)*DTS/M(JB)
C	RU10O2->CARB7+HCHO+HO2
      FLUX(JB,335)=FLUX(JB,335)+RC(JB,335)*Y(JB,112)*DTS/M(JB)
C	NRN6O2->HCHO+HCHO+NO2
      FLUX(JB,336)=FLUX(JB,336)+RC(JB,336)*Y(JB,36)*DTS/M(JB)
C	NRN9O2->CH3CHO+HCHO+NO2
      FLUX(JB,337)=FLUX(JB,337)+RC(JB,337)*Y(JB,37)*DTS/M(JB)
C	NRN12O2->CH3CHO+CH3CHO+NO2
      FLUX(JB,338)=FLUX(JB,338)+RC(JB,338)*Y(JB,38)*DTS/M(JB)
C	NRU14O2->NUCARB12+HO2
      FLUX(JB,339)=FLUX(JB,339)+RC(JB,339)*Y(JB,45)*DTS/M(JB)
C	NRU12O2->NOA+CO+HO2
      FLUX(JB,340)=FLUX(JB,340)+RC(JB,340)*Y(JB,114)*DTS/M(JB)
C	RTN28O2->TNCARB26+HO2
      FLUX(JB,341)=FLUX(JB,341)+RC(JB,341)*Y(JB,48)*DTS/M(JB)
C	NRTN28O2->TNCARB26+NO2
      FLUX(JB,342)=FLUX(JB,342)+RC(JB,342)*Y(JB,49)*DTS/M(JB)
C	RTN26O2->RTN25O2
      FLUX(JB,343)=FLUX(JB,343)+RC(JB,343)*Y(JB,50)*DTS/M(JB)
C	RTN25O2->RTN24O2
      FLUX(JB,344)=FLUX(JB,344)+RC(JB,344)*Y(JB,116)*DTS/M(JB)
C	RTN24O2->RTN23O2
      FLUX(JB,345)=FLUX(JB,345)+RC(JB,345)*Y(JB,117)*DTS/M(JB)
C	RTN23O2->CH3COCH3+RTN14O2
      FLUX(JB,346)=FLUX(JB,346)+RC(JB,346)*Y(JB,118)*DTS/M(JB)
C	RTN14O2->HCHO+TNCARB10+HO2
      FLUX(JB,347)=FLUX(JB,347)+RC(JB,347)*Y(JB,119)*DTS/M(JB)
C	RTN10O2->RN8O2+CO
      FLUX(JB,348)=FLUX(JB,348)+RC(JB,348)*Y(JB,121)*DTS/M(JB)
C	RTX28O2->TXCARB24+HCHO+HO2
      FLUX(JB,349)=FLUX(JB,349)+RC(JB,349)*Y(JB,54)*DTS/M(JB)
C	RTX24O2->TXCARB22+HO2
      FLUX(JB,350)=FLUX(JB,350)+RC(JB,350)*Y(JB,56)*DTS/M(JB)
C	RTX22O2->CH3COCH3+RN13O2
      FLUX(JB,351)=FLUX(JB,351)+RC(JB,351)*Y(JB,122)*DTS/M(JB)
C	NRTX28O2->TXCARB24+HCHO+NO2
      FLUX(JB,352)=FLUX(JB,352)+RC(JB,352)*Y(JB,55)*DTS/M(JB)
C	OH+CARB14->RN14O2
      FLUX(JB,353)=FLUX(JB,353)+RC(JB,353)*Y(JB,3)*Y(JB,186)*DTS/M(JB)
C	OH+CARB17->RN17O2
      FLUX(JB,354)=FLUX(JB,354)+RC(JB,354)*Y(JB,3)*Y(JB,187)*DTS/M(JB)
C	OH+CARB11A->RN11O2
      FLUX(JB,355)=FLUX(JB,355)+RC(JB,355)*Y(JB,3)*Y(JB,88)*DTS/M(JB)
C	OH+CARB7->CARB6+HO2
      FLUX(JB,356)=FLUX(JB,356)+RC(JB,356)*Y(JB,3)*Y(JB,111)*DTS/M(JB)
C	OH+CARB10->CARB9+HO2
      FLUX(JB,357)=FLUX(JB,357)+RC(JB,357)*Y(JB,3)*Y(JB,188)*DTS/M(JB)
C	OH+CARB13->RN13O2
      FLUX(JB,358)=FLUX(JB,358)+RC(JB,358)*Y(JB,3)*Y(JB,104)*DTS/M(JB)
C	OH+CARB16->RN16O2
      FLUX(JB,359)=FLUX(JB,359)+RC(JB,359)*Y(JB,3)*Y(JB,105)*DTS/M(JB)
C	OH+UCARB10->RU10O2
      FLUX(JB,360)=FLUX(JB,360)+RC(JB,360)*Y(JB,3)*Y(JB,46)*DTS/M(JB)
C	NO3+UCARB10->RU10O2+HNO3
      FLUX(JB,361)=FLUX(JB,361)+RC(JB,361)*Y(JB,5)*Y(JB,46)*DTS/M(JB)
C	O3+UCARB10->HCHO+CH3CO3+CO+OH
      FLUX(JB,362)=FLUX(JB,362)+RC(JB,362)*Y(JB,6)*Y(JB,46)*DTS/M(JB)
C	O3+UCARB10->HCHO+CARB6+H2O2
      FLUX(JB,363)=FLUX(JB,363)+RC(JB,363)*Y(JB,6)*Y(JB,46)*DTS/M(JB)
C	OH+HOCH2CHO->HOCH2CO3
      FLUX(JB,364)=FLUX(JB,364)+RC(JB,364)*Y(JB,3)*Y(JB,102)*DTS/M(JB)
C	NO3+HOCH2CHO->HOCH2CO3+HNO3
      FLUX(JB,365)=FLUX(JB,365)+RC(JB,365)*Y(JB,5)*Y(JB,102)*DTS/M(JB)
C	OH+CARB3->CO+CO+HO2
      FLUX(JB,366)=FLUX(JB,366)+RC(JB,366)*Y(JB,3)*Y(JB,60)*DTS/M(JB)
C	OH+CARB6->CH3CO3+CO
      FLUX(JB,367)=FLUX(JB,367)+RC(JB,367)*Y(JB,3)*Y(JB,98)*DTS/M(JB)
C	OH+CARB9->RN9O2
      FLUX(JB,368)=FLUX(JB,368)+RC(JB,368)*Y(JB,3)*Y(JB,100)*DTS/M(JB)
C	OH+CARB12->RN12O2
      FLUX(JB,369)=FLUX(JB,369)+RC(JB,369)*Y(JB,3)*Y(JB,189)*DTS/M(JB)
C	OH+CARB15->RN15O2
      FLUX(JB,370)=FLUX(JB,370)+RC(JB,370)*Y(JB,3)*Y(JB,190)*DTS/M(JB)
C	OH+CCARB12->RN12O2
      FLUX(JB,371)=FLUX(JB,371)+RC(JB,371)*Y(JB,3)*Y(JB,191)*DTS/M(JB)
C	OH+UCARB12->RU12O2
      FLUX(JB,372)=FLUX(JB,372)+RC(JB,372)*Y(JB,3)*Y(JB,109)*DTS/M(JB)
C	NO3+UCARB12->RU12O2+HNO3
      FLUX(JB,373)=FLUX(JB,373)+RC(JB,373)*Y(JB,5)*Y(JB,109)*DTS/M(JB)
C	O3+UCARB12->HOCH2CHO+CH3CO3+CO+OH
      FLUX(JB,374)=FLUX(JB,374)+RC(JB,374)*Y(JB,6)*Y(JB,109)*DTS/M(JB)
C	O3+UCARB12->CARB3+CARB6+HO2+OH
      FLUX(JB,375)=FLUX(JB,375)+RC(JB,375)*Y(JB,6)*Y(JB,109)*DTS/M(JB)
C	OH+NUCARB12->NRU12O2
      FLUX(JB,376)=FLUX(JB,376)+RC(JB,376)*Y(JB,3)*Y(JB,113)*DTS/M(JB)
C	OH+NOA->CARB6+NO2
      FLUX(JB,377)=FLUX(JB,377)+RC(JB,377)*Y(JB,3)*Y(JB,115)*DTS/M(JB)
C	OH+UDCARB8->C2H5O2
      FLUX(JB,378)=FLUX(JB,378)+RC(JB,378)*Y(JB,3)*Y(JB,96)*DTS/M(JB)
C	OH+UDCARB8->ANHY+HO2
      FLUX(JB,379)=FLUX(JB,379)+RC(JB,379)*Y(JB,3)*Y(JB,96)*DTS/M(JB)
C	OH+UDCARB11->RN10O2
      FLUX(JB,380)=FLUX(JB,380)+RC(JB,380)*Y(JB,3)*Y(JB,97)*DTS/M(JB)
C	OH+UDCARB11->ANHY+CH3O2
      FLUX(JB,381)=FLUX(JB,381)+RC(JB,381)*Y(JB,3)*Y(JB,97)*DTS/M(JB)
C	OH+UDCARB14->RN13O2
      FLUX(JB,382)=FLUX(JB,382)+RC(JB,382)*Y(JB,3)*Y(JB,99)*DTS/M(JB)
C	OH+UDCARB14->ANHY+C2H5O2
      FLUX(JB,383)=FLUX(JB,383)+RC(JB,383)*Y(JB,3)*Y(JB,99)*DTS/M(JB)
C	OH+TNCARB26->RTN26O2
      FLUX(JB,384)=FLUX(JB,384)+RC(JB,384)*Y(JB,3)*Y(JB,51)*DTS/M(JB)
C	OH+TNCARB15->RN15AO2
      FLUX(JB,385)=FLUX(JB,385)+RC(JB,385)*Y(JB,3)*Y(JB,193)*DTS/M(JB)
C	OH+TNCARB10->RTN10O2
      FLUX(JB,386)=FLUX(JB,386)+RC(JB,386)*Y(JB,3)*Y(JB,120)*DTS/M(JB)
C	NO3+TNCARB26->RTN26O2+HNO3
      FLUX(JB,387)=FLUX(JB,387)+RC(JB,387)*Y(JB,5)*Y(JB,51)*DTS/M(JB)
C	NO3+TNCARB10->RTN10O2+HNO3
      FLUX(JB,388)=FLUX(JB,388)+RC(JB,388)*Y(JB,5)*Y(JB,120)*DTS/M(JB)
C	OH+RCOOH25->RTN25O2
      FLUX(JB,389)=FLUX(JB,389)+RC(JB,389)*Y(JB,3)*Y(JB,52)*DTS/M(JB)
C	OH+TXCARB24->RTX24O2
      FLUX(JB,390)=FLUX(JB,390)+RC(JB,390)*Y(JB,3)*Y(JB,57)*DTS/M(JB)
C	OH+TXCARB22->RTX22O2
      FLUX(JB,391)=FLUX(JB,391)+RC(JB,391)*Y(JB,3)*Y(JB,58)*DTS/M(JB)
C	OH+CH3NO3->HCHO+NO2
      FLUX(JB,392)=FLUX(JB,392)+RC(JB,392)*Y(JB,3)*Y(JB,123)*DTS/M(JB)
C	OH+C2H5NO3->CH3CHO+NO2
      FLUX(JB,393)=FLUX(JB,393)+RC(JB,393)*Y(JB,3)*Y(JB,124)*DTS/M(JB)
C	OH+RN10NO3->C2H5CHO+NO2
      FLUX(JB,394)=FLUX(JB,394)+RC(JB,394)*Y(JB,3)*Y(JB,125)*DTS/M(JB)
C	OH+IC3H7NO3->CH3COCH3+NO2
      FLUX(JB,395)=FLUX(JB,395)+RC(JB,395)*Y(JB,3)*Y(JB,126)*DTS/M(JB)
C	OH+RN13NO3->CARB11A+NO2
      FLUX(JB,396)=FLUX(JB,396)+RC(JB,396)*Y(JB,3)*Y(JB,127)*DTS/M(JB)
C	OH+RN16NO3->CARB14+NO2
      FLUX(JB,397)=FLUX(JB,397)+RC(JB,397)*Y(JB,3)*Y(JB,128)*DTS/M(JB)
C	OH+RN19NO3->CARB17+NO2
      FLUX(JB,398)=FLUX(JB,398)+RC(JB,398)*Y(JB,3)*Y(JB,129)*DTS/M(JB)
C	OH+HOC2H4NO3->HOCH2CHO+NO2
      FLUX(JB,399)=FLUX(JB,399)+RC(JB,399)*Y(JB,3)*Y(JB,130)*DTS/M(JB)
C	OH+RN9NO3->CARB7+NO2
      FLUX(JB,400)=FLUX(JB,400)+RC(JB,400)*Y(JB,3)*Y(JB,131)*DTS/M(JB)
C	OH+RN12NO3->CARB10+NO2
      FLUX(JB,401)=FLUX(JB,401)+RC(JB,401)*Y(JB,3)*Y(JB,132)*DTS/M(JB)
C	OH+RN15NO3->CARB13+NO2
      FLUX(JB,402)=FLUX(JB,402)+RC(JB,402)*Y(JB,3)*Y(JB,133)*DTS/M(JB)
C	OH+RN18NO3->CARB16+NO2
      FLUX(JB,403)=FLUX(JB,403)+RC(JB,403)*Y(JB,3)*Y(JB,134)*DTS/M(JB)
C	OH+RU14NO3->UCARB12+NO2
      FLUX(JB,404)=FLUX(JB,404)+RC(JB,404)*Y(JB,3)*Y(JB,135)*DTS/M(JB)
C	OH+RA13NO3->CARB3+UDCARB8+NO2
      FLUX(JB,405)=FLUX(JB,405)+RC(JB,405)*Y(JB,3)*Y(JB,136)*DTS/M(JB)
C	OH+RA16NO3->CARB3+UDCARB11+NO2
      FLUX(JB,406)=FLUX(JB,406)+RC(JB,406)*Y(JB,3)*Y(JB,137)*DTS/M(JB)
C	OH+RA19NO3->CARB6+UDCARB11+NO2
      FLUX(JB,407)=FLUX(JB,407)+RC(JB,407)*Y(JB,3)*Y(JB,138)*DTS/M(JB)
C	OH+RTN28NO3->TNCARB26+NO2
      FLUX(JB,408)=FLUX(JB,408)+RC(JB,408)*Y(JB,3)*Y(JB,139)*DTS/M(JB)
C	OH+RTN25NO3->CH3COCH3+TNCARB15+NO2
      FLUX(JB,409)=FLUX(JB,409)+RC(JB,409)*Y(JB,3)*Y(JB,140)*DTS/M(JB)
C	OH+RTX28NO3->TXCARB24+HCHO+NO2
      FLUX(JB,410)=FLUX(JB,410)+RC(JB,410)*Y(JB,3)*Y(JB,141)*DTS/M(JB)
C	OH+RTX24NO3->TXCARB22+NO2
      FLUX(JB,411)=FLUX(JB,411)+RC(JB,411)*Y(JB,3)*Y(JB,142)*DTS/M(JB)
C	OH+RTX22NO3->CH3COCH3+CCARB12+NO2
      FLUX(JB,412)=FLUX(JB,412)+RC(JB,412)*Y(JB,3)*Y(JB,143)*DTS/M(JB)
C	OH+AROH14->RAROH14
      FLUX(JB,413)=FLUX(JB,413)+RC(JB,413)*Y(JB,3)*Y(JB,63)*DTS/M(JB)
C	NO3+AROH14->RAROH14+HNO3
      FLUX(JB,414)=FLUX(JB,414)+RC(JB,414)*Y(JB,5)*Y(JB,63)*DTS/M(JB)
C	RAROH14+NO2->ARNOH14
      FLUX(JB,415)=FLUX(JB,415)+RC(JB,415)*Y(JB,4)*Y(JB,194)*DTS/M(JB)
C	OH+ARNOH14->CARB13+NO2
      FLUX(JB,416)=FLUX(JB,416)+RC(JB,416)*Y(JB,3)*Y(JB,195)*DTS/M(JB)
C	NO3+ARNOH14->CARB13+NO2+HNO3
      FLUX(JB,417)=FLUX(JB,417)+RC(JB,417)*Y(JB,5)*Y(JB,195)*DTS/M(JB)
C	OH+AROH17->RAROH17
      FLUX(JB,418)=FLUX(JB,418)+RC(JB,418)*Y(JB,3)*Y(JB,66)*DTS/M(JB)
C	NO3+AROH17->RAROH17+HNO3
      FLUX(JB,419)=FLUX(JB,419)+RC(JB,419)*Y(JB,5)*Y(JB,66)*DTS/M(JB)
C	RAROH17+NO2->ARNOH17
      FLUX(JB,420)=FLUX(JB,420)+RC(JB,420)*Y(JB,4)*Y(JB,196)*DTS/M(JB)
C	OH+ARNOH17->CARB16+NO2
      FLUX(JB,421)=FLUX(JB,421)+RC(JB,421)*Y(JB,3)*Y(JB,197)*DTS/M(JB)
C	NO3+ARNOH17->CARB16+NO2+HNO3
      FLUX(JB,422)=FLUX(JB,422)+RC(JB,422)*Y(JB,5)*Y(JB,197)*DTS/M(JB)
C	OH+CH3OOH->CH3O2
      FLUX(JB,423)=FLUX(JB,423)+RC(JB,423)*Y(JB,3)*Y(JB,144)*DTS/M(JB)
C	OH+CH3OOH->HCHO+OH
      FLUX(JB,424)=FLUX(JB,424)+RC(JB,424)*Y(JB,3)*Y(JB,144)*DTS/M(JB)
C	OH+C2H5OOH->CH3CHO+OH
      FLUX(JB,425)=FLUX(JB,425)+RC(JB,425)*Y(JB,3)*Y(JB,145)*DTS/M(JB)
C	OH+RN10OOH->C2H5CHO+OH
      FLUX(JB,426)=FLUX(JB,426)+RC(JB,426)*Y(JB,3)*Y(JB,146)*DTS/M(JB)
C	OH+IC3H7OOH->CH3COCH3+OH
      FLUX(JB,427)=FLUX(JB,427)+RC(JB,427)*Y(JB,3)*Y(JB,147)*DTS/M(JB)
C	OH+RN13OOH->CARB11A+OH
      FLUX(JB,428)=FLUX(JB,428)+RC(JB,428)*Y(JB,3)*Y(JB,148)*DTS/M(JB)
C	OH+RN16OOH->CARB14+OH
      FLUX(JB,429)=FLUX(JB,429)+RC(JB,429)*Y(JB,3)*Y(JB,149)*DTS/M(JB)
C	OH+RN19OOH->CARB17+OH
      FLUX(JB,430)=FLUX(JB,430)+RC(JB,430)*Y(JB,3)*Y(JB,150)*DTS/M(JB)
C	OH+CH3CO3H->CH3CO3
      FLUX(JB,431)=FLUX(JB,431)+RC(JB,431)*Y(JB,3)*Y(JB,159)*DTS/M(JB)
C	OH+C2H5CO3H->C2H5CO3
      FLUX(JB,432)=FLUX(JB,432)+RC(JB,432)*Y(JB,3)*Y(JB,160)*DTS/M(JB)
C	OH+HOCH2CO3H->HOCH2CO3
      FLUX(JB,433)=FLUX(JB,433)+RC(JB,433)*Y(JB,3)*Y(JB,161)*DTS/M(JB)
C	OH+RN8OOH->CARB6+OH
      FLUX(JB,434)=FLUX(JB,434)+RC(JB,434)*Y(JB,3)*Y(JB,162)*DTS/M(JB)
C	OH+RN11OOH->CARB9+OH
      FLUX(JB,435)=FLUX(JB,435)+RC(JB,435)*Y(JB,3)*Y(JB,163)*DTS/M(JB)
C	OH+RN14OOH->CARB12+OH
      FLUX(JB,436)=FLUX(JB,436)+RC(JB,436)*Y(JB,3)*Y(JB,164)*DTS/M(JB)
C	OH+RN17OOH->CARB15+OH
      FLUX(JB,437)=FLUX(JB,437)+RC(JB,437)*Y(JB,3)*Y(JB,165)*DTS/M(JB)
C	OH+RU14OOH->UCARB12+OH
      FLUX(JB,438)=FLUX(JB,438)+RC(JB,438)*Y(JB,3)*Y(JB,166)*DTS/M(JB)
C	OH+RU12OOH->RU12O2
      FLUX(JB,439)=FLUX(JB,439)+RC(JB,439)*Y(JB,3)*Y(JB,167)*DTS/M(JB)
C	OH+RU10OOH->RU10O2
      FLUX(JB,440)=FLUX(JB,440)+RC(JB,440)*Y(JB,3)*Y(JB,168)*DTS/M(JB)
C	OH+NRU14OOH->NUCARB12+OH
      FLUX(JB,441)=FLUX(JB,441)+RC(JB,441)*Y(JB,3)*Y(JB,172)*DTS/M(JB)
C	OH+NRU12OOH->NOA+CO+OH
      FLUX(JB,442)=FLUX(JB,442)+RC(JB,442)*Y(JB,3)*Y(JB,173)*DTS/M(JB)
C	OH+HOC2H4OOH->HOCH2CHO+OH
      FLUX(JB,443)=FLUX(JB,443)+RC(JB,443)*Y(JB,3)*Y(JB,154)*DTS/M(JB)
C	OH+RN9OOH->CARB7+OH
      FLUX(JB,444)=FLUX(JB,444)+RC(JB,444)*Y(JB,3)*Y(JB,155)*DTS/M(JB)
C	OH+RN12OOH->CARB10+OH
      FLUX(JB,445)=FLUX(JB,445)+RC(JB,445)*Y(JB,3)*Y(JB,156)*DTS/M(JB)
C	OH+RN15OOH->CARB13+OH
      FLUX(JB,446)=FLUX(JB,446)+RC(JB,446)*Y(JB,3)*Y(JB,157)*DTS/M(JB)
C	OH+RN18OOH->CARB16+OH
      FLUX(JB,447)=FLUX(JB,447)+RC(JB,447)*Y(JB,3)*Y(JB,158)*DTS/M(JB)
C	OH+NRN6OOH->HCHO+HCHO+NO2+OH
      FLUX(JB,448)=FLUX(JB,448)+RC(JB,448)*Y(JB,3)*Y(JB,169)*DTS/M(JB)
C	OH+NRN9OOH->CH3CHO+HCHO+NO2+OH
      FLUX(JB,449)=FLUX(JB,449)+RC(JB,449)*Y(JB,3)*Y(JB,170)*DTS/M(JB)
C	OH+NRN12OOH->CH3CHO+CH3CHO+NO2+OH
      FLUX(JB,450)=FLUX(JB,450)+RC(JB,450)*Y(JB,3)*Y(JB,171)*DTS/M(JB)
C	OH+RA13OOH->CARB3+UDCARB8+OH
      FLUX(JB,451)=FLUX(JB,451)+RC(JB,451)*Y(JB,3)*Y(JB,151)*DTS/M(JB)
C	OH+RA16OOH->CARB3+UDCARB11+OH
      FLUX(JB,452)=FLUX(JB,452)+RC(JB,452)*Y(JB,3)*Y(JB,152)*DTS/M(JB)
C	OH+RA19OOH->CARB6+UDCARB11+OH
      FLUX(JB,453)=FLUX(JB,453)+RC(JB,453)*Y(JB,3)*Y(JB,153)*DTS/M(JB)
C	OH+RTN28OOH->TNCARB26+OH
      FLUX(JB,454)=FLUX(JB,454)+RC(JB,454)*Y(JB,3)*Y(JB,174)*DTS/M(JB)
C	OH+RTN26OOH->RTN26O2
      FLUX(JB,455)=FLUX(JB,455)+RC(JB,455)*Y(JB,3)*Y(JB,176)*DTS/M(JB)
C	OH+NRTN28OOH->TNCARB26+NO2+OH
      FLUX(JB,456)=FLUX(JB,456)+RC(JB,456)*Y(JB,3)*Y(JB,175)*DTS/M(JB)
C	OH+RTN25OOH->RTN25O2
      FLUX(JB,457)=FLUX(JB,457)+RC(JB,457)*Y(JB,3)*Y(JB,177)*DTS/M(JB)
C	OH+RTN24OOH->RTN24O2
      FLUX(JB,458)=FLUX(JB,458)+RC(JB,458)*Y(JB,3)*Y(JB,178)*DTS/M(JB)
C	OH+RTN23OOH->RTN23O2
      FLUX(JB,459)=FLUX(JB,459)+RC(JB,459)*Y(JB,3)*Y(JB,179)*DTS/M(JB)
C	OH+RTN14OOH->RTN14O2
      FLUX(JB,460)=FLUX(JB,460)+RC(JB,460)*Y(JB,3)*Y(JB,180)*DTS/M(JB)
C	OH+RTN10OOH->RTN10O2
      FLUX(JB,461)=FLUX(JB,461)+RC(JB,461)*Y(JB,3)*Y(JB,181)*DTS/M(JB)
C	OH+RTX28OOH->RTX28O2
      FLUX(JB,462)=FLUX(JB,462)+RC(JB,462)*Y(JB,3)*Y(JB,182)*DTS/M(JB)
C	OH+RTX24OOH->TXCARB22+OH
      FLUX(JB,463)=FLUX(JB,463)+RC(JB,463)*Y(JB,3)*Y(JB,183)*DTS/M(JB)
C	OH+RTX22OOH->CH3COCH3+CCARB12+OH
      FLUX(JB,464)=FLUX(JB,464)+RC(JB,464)*Y(JB,3)*Y(JB,184)*DTS/M(JB)
C	OH+NRTX28OOH->NRTX28O2
      FLUX(JB,465)=FLUX(JB,465)+RC(JB,465)*Y(JB,3)*Y(JB,185)*DTS/M(JB)
C	OH+ANHY->HOCH2CH2O2
      FLUX(JB,466)=FLUX(JB,466)+RC(JB,466)*Y(JB,3)*Y(JB,192)*DTS/M(JB)
C	CH3CO3+NO2->PAN
      FLUX(JB,467)=FLUX(JB,467)+RC(JB,467)*Y(JB,4)*Y(JB,70)*DTS/M(JB)
C	PAN->CH3CO3+NO2
      FLUX(JB,468)=FLUX(JB,468)+RC(JB,468)*Y(JB,198)*DTS/M(JB)
C	C2H5CO3+NO2->PPN
      FLUX(JB,469)=FLUX(JB,469)+RC(JB,469)*Y(JB,4)*Y(JB,72)*DTS/M(JB)
C	PPN->C2H5CO3+NO2
      FLUX(JB,470)=FLUX(JB,470)+RC(JB,470)*Y(JB,199)*DTS/M(JB)
C	HOCH2CO3+NO2->PHAN
      FLUX(JB,471)=FLUX(JB,471)+RC(JB,471)*Y(JB,4)*Y(JB,106)*DTS/M(JB)
C	PHAN->HOCH2CO3+NO2
      FLUX(JB,472)=FLUX(JB,472)+RC(JB,472)*Y(JB,200)*DTS/M(JB)
C	OH+PAN->HCHO+CO+NO2
      FLUX(JB,473)=FLUX(JB,473)+RC(JB,473)*Y(JB,3)*Y(JB,198)*DTS/M(JB)
C	OH+PPN->CH3CHO+CO+NO2
      FLUX(JB,474)=FLUX(JB,474)+RC(JB,474)*Y(JB,3)*Y(JB,199)*DTS/M(JB)
C	OH+PHAN->HCHO+CO+NO2
      FLUX(JB,475)=FLUX(JB,475)+RC(JB,475)*Y(JB,3)*Y(JB,200)*DTS/M(JB)
C	RU12O2+NO2->RU12PAN
      FLUX(JB,476)=FLUX(JB,476)+RC(JB,476)*Y(JB,4)*Y(JB,110)*DTS/M(JB)
C	RU12PAN->RU12O2+NO2
      FLUX(JB,477)=FLUX(JB,477)+RC(JB,477)*Y(JB,201)*DTS/M(JB)
C	RU10O2+NO2->MPAN
      FLUX(JB,478)=FLUX(JB,478)+RC(JB,478)*Y(JB,4)*Y(JB,112)*DTS/M(JB)
C	MPAN->RU10O2+NO2
      FLUX(JB,479)=FLUX(JB,479)+RC(JB,479)*Y(JB,202)*DTS/M(JB)
C	OH+MPAN->CARB7+CO+NO2
      FLUX(JB,480)=FLUX(JB,480)+RC(JB,480)*Y(JB,3)*Y(JB,202)*DTS/M(JB)
C	OH+RU12PAN->UCARB10+NO2
      FLUX(JB,481)=FLUX(JB,481)+RC(JB,481)*Y(JB,3)*Y(JB,201)*DTS/M(JB)
C	RTN26O2+NO2->RTN26PAN
      FLUX(JB,482)=FLUX(JB,482)+RC(JB,482)*Y(JB,4)*Y(JB,50)*DTS/M(JB)
C	RTN26PAN->RTN26O2+NO2
      FLUX(JB,483)=FLUX(JB,483)+RC(JB,483)*Y(JB,203)*DTS/M(JB)
C	OH+RTN26PAN->CH3COCH3+CARB16+NO2
      FLUX(JB,484)=FLUX(JB,484)+RC(JB,484)*Y(JB,3)*Y(JB,203)*DTS/M(JB)
C      RTN28NO3 = P2604
      FLUX(JB,485)=FLUX(JB,485)+RC(JB,485)*Y(JB,139)*DTS/M(JB)
C      P2604 = RTN28NO3
      FLUX(JB,486)=FLUX(JB,486)+RC(JB,486)*Y(JB,204)*DTS/M(JB)
C      RTX28NO3 = P4608
      FLUX(JB,487)=FLUX(JB,487)+RC(JB,487)*Y(JB,141)*DTS/M(JB)
C      P4608 = RTX28NO3
      FLUX(JB,488)=FLUX(JB,488)+RC(JB,488)*Y(JB,205)*DTS/M(JB)
C      RCOOH25 = P2631
      FLUX(JB,489)=FLUX(JB,489)+RC(JB,489)*Y(JB,52)*DTS/M(JB)
C      P2631 = RCOOH25
      FLUX(JB,490)=FLUX(JB,490)+RC(JB,490)*Y(JB,206)*DTS/M(JB)
C      RTN24OOH = P2635
      FLUX(JB,491)=FLUX(JB,491)+RC(JB,491)*Y(JB,178)*DTS/M(JB)
C      P2635 = RTN24OOH 
      FLUX(JB,492)=FLUX(JB,492)+RC(JB,492)*Y(JB,207)*DTS/M(JB)
C      RTX28OOH = P4610
      FLUX(JB,493)=FLUX(JB,493)+RC(JB,493)*Y(JB,182)*DTS/M(JB)
C      P4610 = RTX28OOH
      FLUX(JB,494)=FLUX(JB,494)+RC(JB,494)*Y(JB,208)*DTS/M(JB)
C      RTN28OOH = P2605
      FLUX(JB,495)=FLUX(JB,495)+RC(JB,495)*Y(JB,174)*DTS/M(JB)
C      P2605 = RTN28OOH
      FLUX(JB,496)=FLUX(JB,496)+RC(JB,496)*Y(JB,209)*DTS/M(JB)
C      RTN26OOH = P2630
      FLUX(JB,497)=FLUX(JB,497)+RC(JB,497)*Y(JB,176)*DTS/M(JB)
C      P2630 = RTN26OOH
      FLUX(JB,498)=FLUX(JB,498)+RC(JB,498)*Y(JB,210)*DTS/M(JB)
C      RTN26PAN = P2629
      FLUX(JB,499)=FLUX(JB,499)+RC(JB,499)*Y(JB,203)*DTS/M(JB)
C      P2629 = RTN26PAN
      FLUX(JB,500)=FLUX(JB,500)+RC(JB,500)*Y(JB,211)*DTS/M(JB)
C      RTN25OOH = P2632
      FLUX(JB,501)=FLUX(JB,501)+RC(JB,501)*Y(JB,177)*DTS/M(JB)
C      P2632 = RTN25OOH
      FLUX(JB,502)=FLUX(JB,502)+RC(JB,502)*Y(JB,212)*DTS/M(JB)
C      RTN23OOH = P2637
      FLUX(JB,503)=FLUX(JB,503)+RC(JB,503)*Y(JB,179)*DTS/M(JB)
C      P2637 = RTN23OOH
      FLUX(JB,504)=FLUX(JB,504)+RC(JB,504)*Y(JB,213)*DTS/M(JB)
C      ARNOH14 = P3612
      FLUX(JB,505)=FLUX(JB,505)+RC(JB,505)*Y(JB,195)*DTS/M(JB)
C      P3612 = ARNOH14
      FLUX(JB,506)=FLUX(JB,506)+RC(JB,506)*Y(JB,214)*DTS/M(JB)
C      ARNOH17 = P3613
      FLUX(JB,507)=FLUX(JB,507)+RC(JB,507)*Y(JB,197)*DTS/M(JB)
C      P3613 = ARNOH17
      FLUX(JB,508)=FLUX(JB,508)+RC(JB,508)*Y(JB,215)*DTS/M(JB)
C      ANHY = P3442
      FLUX(JB,509)=FLUX(JB,509)+RC(JB,509)*Y(JB,192)*DTS/M(JB)
C      P3442 = ANHY
      FLUX(JB,510)=FLUX(JB,510)+RC(JB,510)*Y(JB,216)*DTS/M(JB)
C      RU12OOH = P2007
      FLUX(JB,511)=FLUX(JB,511)+RC(JB,511)*Y(JB,167)*DTS/M(JB)
C      P2007 = RU12OOH
      FLUX(JB,512)=FLUX(JB,512)+RC(JB,512)*Y(JB,219)*DTS/M(JB)
C      OH + DMS = CH3SO + HCHO
      FLUX(JB,513)=FLUX(JB,513)+RC(JB,513)*Y(JB,3)*Y(JB,220)*DTS/M(JB)
C      OH + DMS = DMSO + HO2
      FLUX(JB,514)=FLUX(JB,514)+RC(JB,514)*Y(JB,3)*Y(JB,220)*DTS/M(JB)
C      DMS + NO3 = CH3SO + HCHO + HNO3
      FLUX(JB,515)=FLUX(JB,515)+RC(JB,515)*Y(JB,220)*Y(JB,5)*DTS/M(JB)
C      OH + DMSO = MSIA + CH3O2
      FLUX(JB,516)=FLUX(JB,516)+RC(JB,516)*Y(JB,3)*Y(JB,221)*DTS/M(JB)
C       CH3SO + O3 = CH3SO2
      FLUX(JB,517)=FLUX(JB,517)+RC(JB,517)*Y(JB,222)*Y(JB,6)*DTS/M(JB)
C       CH3SO + NO2 = CH3SO2 + NO
      FLUX(JB,518)=FLUX(JB,518)+RC(JB,518)*Y(JB,222)*Y(JB,4)*DTS/M(JB)
C        MSIA + OH = CH3SO2
      FLUX(JB,519)=FLUX(JB,519)+RC(JB,519)*Y(JB,3)*Y(JB,225)*DTS/M(JB)
C        CH3SO2 + O3 = CH3SO3
      FLUX(JB,520)=FLUX(JB,520)+RC(JB,520)*Y(JB,223)*Y(JB,6)*DTS/M(JB)
C        CH3SO2 + NO2 = CH3SO3 + NO
      FLUX(JB,521)=FLUX(JB,521)+RC(JB,521)*Y(JB,223)*Y(JB,4)*DTS/M(JB)
C        CH3SO2 = CH3O2 + SO2
      FLUX(JB,522)=FLUX(JB,522)+RC(JB,522)*Y(JB,223)*DTS/M(JB)
C        CH3SO3 + HO2 = MSA
      FLUX(JB,523)=FLUX(JB,523)+RC(JB,523)*Y(JB,224)*Y(JB,9)*DTS/M(JB)
C        CH3SO3 = CH3O2 + SA
      FLUX(JB,524)=FLUX(JB,524)+RC(JB,524)*Y(JB,224)*DTS/M(JB)
C        CH3SO3 + HCHO = MSA + HO2 + CO
      FLUX(JB,525)=FLUX(JB,525)+RC(JB,525)*Y(JB,224)*Y(JB,39)*DTS/M(JB)
C        OH + CH3BR = 
      FLUX(JB,526)=FLUX(JB,526)+RC(JB,526)*Y(JB,3)*Y(JB,227)*DTS/M(JB)
C        HSO3-(aq) + H2O2(aq) = SO4--(aq)
      FLUX(JB,527)=FLUX(JB,527)+FAQ(JB,2)*DTS/M(JB)
C        HSO3-(aq) + O3(aq) = SO4--(aq)
      FLUX(JB,528)=FLUX(JB,528)+FAQ(JB,2)*DTS/M(JB)
C        SO3--(aq) + O3(aq) = SO4--(aq)
      FLUX(JB,529)=FLUX(JB,529)+FAQ(JB,2)*DTS/M(JB)
C        SO2(aq) = SO4--(aq)
      FLUX(JB,530)=FLUX(JB,530)+FAQ(JB,1)*DTS/M(JB)
C        2NH4+(aq) + SO4--(aq) = (NH4)2SO4 (aq)
      FLUX(JB,531)=FLUX(JB,531)+FAQ(JB,3)*DTS/M(JB)
C        C2H4 + O3 = SCIE + HCHO
      FLUX(JB,532)=FLUX(JB,532)+RC(JB,530)*Y(JB,30)*Y(JB,6)*DTS/M(JB)
C        C3H6 + O3 = SCIPA+ HCHO
      FLUX(JB,533)=FLUX(JB,533)+RC(JB,531)*Y(JB,32)*Y(JB,6)*DTS/M(JB)
C        C3H6 + O3 = SCIPS + HCHO
      FLUX(JB,534)=FLUX(JB,534)+RC(JB,532)*Y(JB,32)*Y(JB,6)*DTS/M(JB)
C        O3 + TBUT2ENE = CH3CHO + SCIPS 
      FLUX(JB,535)=FLUX(JB,535)+RC(JB,533)*Y(JB,34)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = CH3CO3+HCHO+HCHO+CO+OH
      FLUX(JB,536)=FLUX(JB,536)+RC(JB,534)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = HCHO+SCIMAA
      FLUX(JB,537)=FLUX(JB,537)+RC(JB,535)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = HCHO+SCIMAS
      FLUX(JB,538)=FLUX(JB,538)+RC(JB,536)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = HCHO+CH3O2+HCHO+CO+HO2
      FLUX(JB,539)=FLUX(JB,539)+RC(JB,537)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = HCHO+SCIMVA
      FLUX(JB,540)=FLUX(JB,540)+RC(JB,538)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + C5H8 = HCHO+SCIMVS
      FLUX(JB,541)=FLUX(JB,541)+RC(JB,539)*Y(JB,43)*Y(JB,6)*DTS/M(JB)
C        O3 + APINENE = SCIPAS
      FLUX(JB,542)=FLUX(JB,542)+RC(JB,540)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C        O3 + APINENE = SCIIPA
      FLUX(JB,543)=FLUX(JB,543)+RC(JB,541)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C        O3 + APINENE = SCIIPS
      FLUX(JB,544)=FLUX(JB,544)+RC(JB,542)*Y(JB,47)*Y(JB,6)*DTS/M(JB)
C        O3 + BPINENE = RTX24O2+SCIE
      FLUX(JB,545)=FLUX(JB,545)+RC(JB,543)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C        O3 + BPINENE = HCHO+SCIBPS
      FLUX(JB,546)=FLUX(JB,546)+RC(JB,544)*Y(JB,53)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB10 = HCHO+SCIMGA
      FLUX(JB,547)=FLUX(JB,547)+RC(JB,545)*Y(JB,46)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB10 = HCHO+SCIMGS
      FLUX(JB,548)=FLUX(JB,548)+RC(JB,546)*Y(JB,46)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB10 = CARB6+SCIE
      FLUX(JB,549)=FLUX(JB,549)+RC(JB,547)*Y(JB,46)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB12 = HOCH2CHO+SCIMGA
      FLUX(JB,550)=FLUX(JB,550)+RC(JB,548)*Y(JB,109)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB12 = HOCH2CHO+SCIMGS
      FLUX(JB,551)=FLUX(JB,551)+RC(JB,549)*Y(JB,109)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB12 = CARB6+SCIGAA
      FLUX(JB,552)=FLUX(JB,552)+RC(JB,550)*Y(JB,109)*Y(JB,6)*DTS/M(JB)
C        O3 + UCARB12 = CARB6+SCIGAS
      FLUX(JB,553)=FLUX(JB,553)+RC(JB,551)*Y(JB,109)*Y(JB,6)*DTS/M(JB)
C        SCIE + dimer = HCOOH
      FLUX(JB,554)=FLUX(JB,554)+RC(JB,552)*Y(JB,230)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIPA + H2O = CH3COOH
      FLUX(JB,555)=FLUX(JB,555)+RC(JB,553)*Y(JB,231)*H2O(JB)*DTS/M(JB)
C        SCIPA + dimer = CH3COOH
      FLUX(JB,556)=FLUX(JB,556)+RC(JB,554)*Y(JB,231)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIPS= OH+HCHO+OH+CO
      FLUX(JB,557)=FLUX(JB,557)+RC(JB,555)*Y(JB,232)*DTS/M(JB)
C        SCIMAA + H2O = P
      FLUX(JB,558)=FLUX(JB,558)+RC(JB,556)*Y(JB,233)*H2O(JB)*DTS/M(JB)
C        SCIMAA + dimer = P
      FLUX(JB,559)=FLUX(JB,559)+RC(JB,557)*Y(JB,233)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIMAA= P
      FLUX(JB,560)=FLUX(JB,560)+RC(JB,558)*Y(JB,233)*DTS/M(JB)
C        SCIMAS= P
      FLUX(JB,561)=FLUX(JB,561)+RC(JB,559)*Y(JB,234)*DTS/M(JB)
C        SCIMVA= CH3CO3+HCHO+CO+OH
      FLUX(JB,562)=FLUX(JB,562)+RC(JB,560)*Y(JB,235)*DTS/M(JB)
C        SCIMVS= P+OH
      FLUX(JB,563)=FLUX(JB,563)+RC(JB,561)*Y(JB,236)*DTS/M(JB)
C        SCIPAA + H2O = P
      FLUX(JB,564)=FLUX(JB,564)+RC(JB,562)*Y(JB,237)*H2O(JB)*DTS/M(JB)
C        SCIPAA + dimer = P
      FLUX(JB,565)=FLUX(JB,565)+RC(JB,563)*Y(JB,237)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIPAS= P
      FLUX(JB,566)=FLUX(JB,566)+RC(JB,564)*Y(JB,238)*DTS/M(JB)
C        SCIIPA= P
      FLUX(JB,567)=FLUX(JB,567)+RC(JB,565)*Y(JB,239)*DTS/M(JB)
C        SCIIPS= P
      FLUX(JB,568)=FLUX(JB,568)+RC(JB,566)*Y(JB,240)*DTS/M(JB)
C        SCIBPA= P
      FLUX(JB,569)=FLUX(JB,569)+RC(JB,567)*Y(JB,241)*DTS/M(JB)
C        SCIBPA + H2O = P
      FLUX(JB,570)=FLUX(JB,570)+RC(JB,568)*Y(JB,241)*H2O(JB)*DTS/M(JB)
C        SCIBPS= P
      FLUX(JB,571)=FLUX(JB,571)+RC(JB,569)*Y(JB,242)*DTS/M(JB)
C        SCIMGA = P
      FLUX(JB,572)=FLUX(JB,572)+RC(JB,570)*Y(JB,243)*DTS/M(JB)
C        SCIMGS = P
      FLUX(JB,573)=FLUX(JB,573)+RC(JB,571)*Y(JB,244)*DTS/M(JB)
C        SCIMGS +water = P
      FLUX(JB,574)=FLUX(JB,574)+RC(JB,572)*Y(JB,244)*H2O(JB)*DTS/M(JB)
C        SCIGAA + H2O = P
      FLUX(JB,575)=FLUX(JB,575)+RC(JB,573)*Y(JB,245)*H2O(JB)*DTS/M(JB)
C        SCIGAA + dimer = P
      FLUX(JB,576)=FLUX(JB,576)+RC(JB,574)*Y(JB,245)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIGAS +water= P
      FLUX(JB,577)=FLUX(JB,577)+RC(JB,575)*Y(JB,246)*H2O(JB)*DTS/M(JB)
C        SCIGAS + water dimer = Products 
      FLUX(JB,578)=FLUX(JB,578)+RC(JB,576)*Y(JB,246)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)
C        SCIMGS+dimer = P 
      FLUX(JB,579)=FLUX(JB,579)+RC(JB,577)*Y(JB,244)*H2O(JB)*
     & H2O(JB)*DTS/M(JB)  
C        CH3COCH3 + SCI = P 
      FLUX(JB,580)=FLUX(JB,580)+RC(JB,578)*Y(JB,73)*SCI(JB)*DTS/M(JB)  
      FLUX(JB,581)=FLUX(JB,581)+RC(JB,579)*Y(JB,154)*APN(JB)*DTS/M(JB)  
      FLUX(JB,582)=FLUX(JB,582)+RC(JB,580)*Y(JB,166)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,583)=FLUX(JB,583)+RC(JB,581)*Y(JB,166)*APN(JB)*DTS/M(JB)  
      FLUX(JB,584)=FLUX(JB,584)+RC(JB,582)*Y(JB,167)*Y(JB,230)*DTS/M(JB)  
      FLUX(JB,585)=FLUX(JB,585)+RC(JB,583)*Y(JB,167)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,586)=FLUX(JB,586)+RC(JB,584)*Y(JB,167)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,587)=FLUX(JB,587)+RC(JB,585)*Y(JB,168)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,588)=FLUX(JB,588)+RC(JB,586)*Y(JB,168)*APN(JB)*DTS/M(JB)  
      FLUX(JB,589)=FLUX(JB,589)+RC(JB,587)*Y(JB,172)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,590)=FLUX(JB,590)+RC(JB,588)*Y(JB,172)*APN(JB)*DTS/M(JB)  
      FLUX(JB,591)=FLUX(JB,591)+RC(JB,589)*Y(JB,173)*Y(JB,230)*DTS/M(JB)  
      FLUX(JB,592)=FLUX(JB,592)+RC(JB,590)*Y(JB,173)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,593)=FLUX(JB,593)+RC(JB,591)*Y(JB,173)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,594)=FLUX(JB,594)+RC(JB,592)*Y(JB,174)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,595)=FLUX(JB,595)+RC(JB,593)*Y(JB,174)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,596)=FLUX(JB,596)+RC(JB,594)*Y(JB,174)*APN(JB)*DTS/M(JB)  
      FLUX(JB,597)=FLUX(JB,597)+RC(JB,595)*Y(JB,176)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,598)=FLUX(JB,598)+RC(JB,596)*Y(JB,176)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,599)=FLUX(JB,599)+RC(JB,597)*Y(JB,176)*APN(JB)*DTS/M(JB)  
      FLUX(JB,600)=FLUX(JB,600)+RC(JB,598)*Y(JB,177)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,601)=FLUX(JB,601)+RC(JB,599)*Y(JB,177)*APN(JB)*DTS/M(JB)  
      FLUX(JB,602)=FLUX(JB,602)+RC(JB,600)*Y(JB,178)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,603)=FLUX(JB,603)+RC(JB,601)*Y(JB,178)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,604)=FLUX(JB,604)+RC(JB,602)*Y(JB,178)*APN(JB)*DTS/M(JB)  
      FLUX(JB,605)=FLUX(JB,605)+RC(JB,603)*Y(JB,179)*Y(JB,230)*DTS/M(JB)  
      FLUX(JB,606)=FLUX(JB,606)+RC(JB,604)*Y(JB,179)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,607)=FLUX(JB,607)+RC(JB,605)*Y(JB,179)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,608)=FLUX(JB,608)+RC(JB,606)*Y(JB,175)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,609)=FLUX(JB,609)+RC(JB,607)*Y(JB,175)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,610)=FLUX(JB,610)+RC(JB,608)*Y(JB,175)*APN(JB)*DTS/M(JB)  
      FLUX(JB,611)=FLUX(JB,611)+RC(JB,609)*Y(JB,162)*APN(JB)*DTS/M(JB)  
      FLUX(JB,612)=FLUX(JB,612)+RC(JB,610)*Y(JB,182)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,613)=FLUX(JB,613)+RC(JB,611)*Y(JB,182)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,614)=FLUX(JB,614)+RC(JB,612)*Y(JB,182)*APN(JB)*DTS/M(JB)  
      FLUX(JB,615)=FLUX(JB,615)+RC(JB,613)*Y(JB,183)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,616)=FLUX(JB,616)+RC(JB,614)*Y(JB,183)*APN(JB)*DTS/M(JB)  
      FLUX(JB,617)=FLUX(JB,617)+RC(JB,615)*Y(JB,184)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,618)=FLUX(JB,618)+RC(JB,616)*Y(JB,184)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,619)=FLUX(JB,619)+RC(JB,617)*Y(JB,184)*APN(JB)*DTS/M(JB)  
      FLUX(JB,620)=FLUX(JB,620)+RC(JB,618)*Y(JB,185)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,621)=FLUX(JB,621)+RC(JB,619)*Y(JB,185)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,622)=FLUX(JB,622)+RC(JB,620)*Y(JB,185)*APN(JB)*DTS/M(JB)  
      FLUX(JB,623)=FLUX(JB,623)+RC(JB,621)*Y(JB,180)*Y(JB,230)*DTS/M(JB)  
      FLUX(JB,624)=FLUX(JB,624)+RC(JB,622)*Y(JB,180)*ISP(JB)*DTS/M(JB)  
      FLUX(JB,625)=FLUX(JB,625)+RC(JB,623)*Y(JB,180)*BPN(JB)*DTS/M(JB)  
      FLUX(JB,626)=FLUX(JB,626)+RC(JB,624)*Y(JB,180)*APN(JB)*DTS/M(JB)  
      FLUX(JB,627)=FLUX(JB,627)+RC(JB,625)*Y(JB,181)*APN(JB)*DTS/M(JB)  
      FLUX(JB,628)=FLUX(JB,628)+RC(JB,626)*Y(JB,249)*DTS/M(JB) 
      FLUX(JB,629)=FLUX(JB,629)+RC(JB,627)*Y(JB,296)*DTS/M(JB) 
      FLUX(JB,630)=FLUX(JB,630)+RC(JB,628)*Y(JB,250)*DTS/M(JB) 
      FLUX(JB,631)=FLUX(JB,631)+RC(JB,629)*Y(JB,297)*DTS/M(JB) 
      FLUX(JB,632)=FLUX(JB,632)+RC(JB,630)*Y(JB,251)*DTS/M(JB) 
      FLUX(JB,633)=FLUX(JB,633)+RC(JB,631)*Y(JB,298)*DTS/M(JB) 
      FLUX(JB,634)=FLUX(JB,634)+RC(JB,632)*Y(JB,252)*DTS/M(JB) 
      FLUX(JB,635)=FLUX(JB,635)+RC(JB,633)*Y(JB,299)*DTS/M(JB) 
      FLUX(JB,636)=FLUX(JB,636)+RC(JB,634)*Y(JB,253)*DTS/M(JB) 
      FLUX(JB,637)=FLUX(JB,637)+RC(JB,635)*Y(JB,300)*DTS/M(JB) 
      FLUX(JB,638)=FLUX(JB,638)+RC(JB,636)*Y(JB,254)*DTS/M(JB) 
      FLUX(JB,639)=FLUX(JB,639)+RC(JB,637)*Y(JB,301)*DTS/M(JB) 
      FLUX(JB,640)=FLUX(JB,640)+RC(JB,638)*Y(JB,255)*DTS/M(JB) 
      FLUX(JB,641)=FLUX(JB,641)+RC(JB,639)*Y(JB,302)*DTS/M(JB) 
      FLUX(JB,642)=FLUX(JB,642)+RC(JB,640)*Y(JB,256)*DTS/M(JB) 
      FLUX(JB,643)=FLUX(JB,643)+RC(JB,641)*Y(JB,303)*DTS/M(JB) 
      FLUX(JB,644)=FLUX(JB,644)+RC(JB,642)*Y(JB,257)*DTS/M(JB) 
      FLUX(JB,645)=FLUX(JB,645)+RC(JB,643)*Y(JB,304)*DTS/M(JB) 
      FLUX(JB,646)=FLUX(JB,646)+RC(JB,644)*Y(JB,258)*DTS/M(JB) 
      FLUX(JB,647)=FLUX(JB,647)+RC(JB,645)*Y(JB,305)*DTS/M(JB) 
      FLUX(JB,648)=FLUX(JB,648)+RC(JB,646)*Y(JB,259)*DTS/M(JB) 
      FLUX(JB,649)=FLUX(JB,649)+RC(JB,647)*Y(JB,306)*DTS/M(JB) 
      FLUX(JB,650)=FLUX(JB,650)+RC(JB,648)*Y(JB,260)*DTS/M(JB) 
      FLUX(JB,651)=FLUX(JB,651)+RC(JB,649)*Y(JB,307)*DTS/M(JB) 
      FLUX(JB,652)=FLUX(JB,652)+RC(JB,650)*Y(JB,261)*DTS/M(JB) 
      FLUX(JB,653)=FLUX(JB,653)+RC(JB,651)*Y(JB,308)*DTS/M(JB) 
      FLUX(JB,654)=FLUX(JB,654)+RC(JB,652)*Y(JB,262)*DTS/M(JB) 
      FLUX(JB,655)=FLUX(JB,655)+RC(JB,653)*Y(JB,309)*DTS/M(JB) 
      FLUX(JB,656)=FLUX(JB,656)+RC(JB,654)*Y(JB,263)*DTS/M(JB) 
      FLUX(JB,657)=FLUX(JB,657)+RC(JB,655)*Y(JB,310)*DTS/M(JB) 
      FLUX(JB,658)=FLUX(JB,658)+RC(JB,656)*Y(JB,264)*DTS/M(JB) 
      FLUX(JB,659)=FLUX(JB,659)+RC(JB,657)*Y(JB,311)*DTS/M(JB) 
      FLUX(JB,660)=FLUX(JB,660)+RC(JB,658)*Y(JB,265)*DTS/M(JB) 
      FLUX(JB,661)=FLUX(JB,661)+RC(JB,659)*Y(JB,312)*DTS/M(JB) 
      FLUX(JB,662)=FLUX(JB,662)+RC(JB,660)*Y(JB,266)*DTS/M(JB) 
      FLUX(JB,663)=FLUX(JB,663)+RC(JB,661)*Y(JB,313)*DTS/M(JB) 
      FLUX(JB,664)=FLUX(JB,664)+RC(JB,662)*Y(JB,267)*DTS/M(JB) 
      FLUX(JB,665)=FLUX(JB,665)+RC(JB,663)*Y(JB,314)*DTS/M(JB) 
      FLUX(JB,666)=FLUX(JB,666)+RC(JB,664)*Y(JB,268)*DTS/M(JB) 
      FLUX(JB,667)=FLUX(JB,667)+RC(JB,665)*Y(JB,315)*DTS/M(JB) 
      FLUX(JB,668)=FLUX(JB,668)+RC(JB,666)*Y(JB,269)*DTS/M(JB) 
      FLUX(JB,669)=FLUX(JB,669)+RC(JB,667)*Y(JB,316)*DTS/M(JB) 
      FLUX(JB,670)=FLUX(JB,670)+RC(JB,668)*Y(JB,270)*DTS/M(JB) 
      FLUX(JB,671)=FLUX(JB,671)+RC(JB,669)*Y(JB,317)*DTS/M(JB) 
      FLUX(JB,672)=FLUX(JB,672)+RC(JB,670)*Y(JB,271)*DTS/M(JB) 
      FLUX(JB,673)=FLUX(JB,673)+RC(JB,671)*Y(JB,318)*DTS/M(JB) 
      FLUX(JB,674)=FLUX(JB,674)+RC(JB,672)*Y(JB,272)*DTS/M(JB) 
      FLUX(JB,675)=FLUX(JB,675)+RC(JB,673)*Y(JB,319)*DTS/M(JB) 
      FLUX(JB,676)=FLUX(JB,676)+RC(JB,674)*Y(JB,273)*DTS/M(JB) 
      FLUX(JB,677)=FLUX(JB,677)+RC(JB,675)*Y(JB,320)*DTS/M(JB) 
      FLUX(JB,678)=FLUX(JB,678)+RC(JB,676)*Y(JB,274)*DTS/M(JB) 
      FLUX(JB,679)=FLUX(JB,679)+RC(JB,677)*Y(JB,321)*DTS/M(JB) 
      FLUX(JB,680)=FLUX(JB,680)+RC(JB,678)*Y(JB,275)*DTS/M(JB) 
      FLUX(JB,681)=FLUX(JB,681)+RC(JB,679)*Y(JB,322)*DTS/M(JB) 
      FLUX(JB,682)=FLUX(JB,682)+RC(JB,680)*Y(JB,276)*DTS/M(JB) 
      FLUX(JB,683)=FLUX(JB,683)+RC(JB,681)*Y(JB,323)*DTS/M(JB) 
      FLUX(JB,684)=FLUX(JB,684)+RC(JB,682)*Y(JB,277)*DTS/M(JB) 
      FLUX(JB,685)=FLUX(JB,685)+RC(JB,683)*Y(JB,324)*DTS/M(JB) 
      FLUX(JB,686)=FLUX(JB,686)+RC(JB,684)*Y(JB,278)*DTS/M(JB) 
      FLUX(JB,687)=FLUX(JB,687)+RC(JB,685)*Y(JB,325)*DTS/M(JB) 
      FLUX(JB,688)=FLUX(JB,688)+RC(JB,686)*Y(JB,279)*DTS/M(JB) 
      FLUX(JB,689)=FLUX(JB,689)+RC(JB,687)*Y(JB,326)*DTS/M(JB) 
      FLUX(JB,690)=FLUX(JB,690)+RC(JB,688)*Y(JB,280)*DTS/M(JB) 
      FLUX(JB,691)=FLUX(JB,691)+RC(JB,689)*Y(JB,327)*DTS/M(JB) 
      FLUX(JB,692)=FLUX(JB,692)+RC(JB,690)*Y(JB,281)*DTS/M(JB) 
      FLUX(JB,693)=FLUX(JB,693)+RC(JB,691)*Y(JB,328)*DTS/M(JB) 
      FLUX(JB,694)=FLUX(JB,694)+RC(JB,692)*Y(JB,282)*DTS/M(JB) 
      FLUX(JB,695)=FLUX(JB,695)+RC(JB,693)*Y(JB,329)*DTS/M(JB) 
      FLUX(JB,696)=FLUX(JB,696)+RC(JB,694)*Y(JB,283)*DTS/M(JB) 
      FLUX(JB,697)=FLUX(JB,697)+RC(JB,695)*Y(JB,330)*DTS/M(JB) 
      FLUX(JB,698)=FLUX(JB,698)+RC(JB,696)*Y(JB,284)*DTS/M(JB) 
      FLUX(JB,699)=FLUX(JB,699)+RC(JB,697)*Y(JB,331)*DTS/M(JB) 
      FLUX(JB,700)=FLUX(JB,700)+RC(JB,698)*Y(JB,285)*DTS/M(JB) 
      FLUX(JB,701)=FLUX(JB,701)+RC(JB,699)*Y(JB,332)*DTS/M(JB) 
      FLUX(JB,702)=FLUX(JB,702)+RC(JB,700)*Y(JB,286)*DTS/M(JB) 
      FLUX(JB,703)=FLUX(JB,703)+RC(JB,701)*Y(JB,333)*DTS/M(JB) 
      FLUX(JB,704)=FLUX(JB,704)+RC(JB,702)*Y(JB,287)*DTS/M(JB) 
      FLUX(JB,705)=FLUX(JB,705)+RC(JB,703)*Y(JB,334)*DTS/M(JB) 
      FLUX(JB,706)=FLUX(JB,706)+RC(JB,704)*Y(JB,288)*DTS/M(JB) 
      FLUX(JB,707)=FLUX(JB,707)+RC(JB,705)*Y(JB,335)*DTS/M(JB) 
      FLUX(JB,708)=FLUX(JB,708)+RC(JB,706)*Y(JB,289)*DTS/M(JB) 
      FLUX(JB,709)=FLUX(JB,709)+RC(JB,707)*Y(JB,336)*DTS/M(JB) 
      FLUX(JB,710)=FLUX(JB,710)+RC(JB,708)*Y(JB,290)*DTS/M(JB) 
      FLUX(JB,711)=FLUX(JB,711)+RC(JB,709)*Y(JB,337)*DTS/M(JB) 
      FLUX(JB,712)=FLUX(JB,712)+RC(JB,710)*Y(JB,291)*DTS/M(JB) 
      FLUX(JB,713)=FLUX(JB,713)+RC(JB,711)*Y(JB,338)*DTS/M(JB) 
      FLUX(JB,714)=FLUX(JB,714)+RC(JB,712)*Y(JB,292)*DTS/M(JB) 
      FLUX(JB,715)=FLUX(JB,715)+RC(JB,713)*Y(JB,339)*DTS/M(JB) 
      FLUX(JB,716)=FLUX(JB,716)+RC(JB,714)*Y(JB,293)*DTS/M(JB) 
      FLUX(JB,717)=FLUX(JB,717)+RC(JB,715)*Y(JB,340)*DTS/M(JB) 
      FLUX(JB,718)=FLUX(JB,718)+RC(JB,716)*Y(JB,294)*DTS/M(JB) 
      FLUX(JB,719)=FLUX(JB,719)+RC(JB,717)*Y(JB,341)*DTS/M(JB) 
      FLUX(JB,720)=FLUX(JB,720)+RC(JB,718)*Y(JB,295)*DTS/M(JB) 
      FLUX(JB,721)=FLUX(JB,721)+RC(JB,719)*Y(JB,342)*DTS/M(JB) 
      FLUX(JB,722)=FLUX(JB,722)+RC(JB,720)*Y(JB,249)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,723)=FLUX(JB,723)+RC(JB,721)*Y(JB,250)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,724)=FLUX(JB,724)+RC(JB,722)*Y(JB,251)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,725)=FLUX(JB,725)+RC(JB,723)*Y(JB,252)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,726)=FLUX(JB,726)+RC(JB,724)*Y(JB,253)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,727)=FLUX(JB,727)+RC(JB,725)*Y(JB,254)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,728)=FLUX(JB,728)+RC(JB,726)*Y(JB,255)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,729)=FLUX(JB,729)+RC(JB,727)*Y(JB,256)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,730)=FLUX(JB,730)+RC(JB,728)*Y(JB,257)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,731)=FLUX(JB,731)+RC(JB,729)*Y(JB,258)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,732)=FLUX(JB,732)+RC(JB,730)*Y(JB,259)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,733)=FLUX(JB,733)+RC(JB,731)*Y(JB,260)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,734)=FLUX(JB,734)+RC(JB,732)*Y(JB,261)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,735)=FLUX(JB,735)+RC(JB,733)*Y(JB,262)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,736)=FLUX(JB,736)+RC(JB,734)*Y(JB,263)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,737)=FLUX(JB,737)+RC(JB,735)*Y(JB,264)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,738)=FLUX(JB,738)+RC(JB,736)*Y(JB,265)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,739)=FLUX(JB,739)+RC(JB,737)*Y(JB,266)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,740)=FLUX(JB,740)+RC(JB,738)*Y(JB,267)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,741)=FLUX(JB,741)+RC(JB,739)*Y(JB,268)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,742)=FLUX(JB,742)+RC(JB,740)*Y(JB,269)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,743)=FLUX(JB,743)+RC(JB,741)*Y(JB,270)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,744)=FLUX(JB,744)+RC(JB,742)*Y(JB,271)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,745)=FLUX(JB,745)+RC(JB,743)*Y(JB,272)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,746)=FLUX(JB,746)+RC(JB,744)*Y(JB,273)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,747)=FLUX(JB,747)+RC(JB,745)*Y(JB,274)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,748)=FLUX(JB,748)+RC(JB,746)*Y(JB,275)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,749)=FLUX(JB,749)+RC(JB,747)*Y(JB,276)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,750)=FLUX(JB,750)+RC(JB,748)*Y(JB,277)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,751)=FLUX(JB,751)+RC(JB,749)*Y(JB,278)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,752)=FLUX(JB,752)+RC(JB,750)*Y(JB,279)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,753)=FLUX(JB,753)+RC(JB,751)*Y(JB,280)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,754)=FLUX(JB,754)+RC(JB,752)*Y(JB,281)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,755)=FLUX(JB,755)+RC(JB,753)*Y(JB,282)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,756)=FLUX(JB,756)+RC(JB,754)*Y(JB,283)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,757)=FLUX(JB,757)+RC(JB,755)*Y(JB,284)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,758)=FLUX(JB,758)+RC(JB,756)*Y(JB,285)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,759)=FLUX(JB,759)+RC(JB,757)*Y(JB,286)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,760)=FLUX(JB,760)+RC(JB,758)*Y(JB,287)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,761)=FLUX(JB,761)+RC(JB,759)*Y(JB,288)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,762)=FLUX(JB,762)+RC(JB,760)*Y(JB,289)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,763)=FLUX(JB,763)+RC(JB,761)*Y(JB,290)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,764)=FLUX(JB,764)+RC(JB,762)*Y(JB,291)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,765)=FLUX(JB,765)+RC(JB,763)*Y(JB,292)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,766)=FLUX(JB,766)+RC(JB,764)*Y(JB,293)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,767)=FLUX(JB,767)+RC(JB,765)*Y(JB,294)*Y(JB,3)*DTS/M(JB) 
      FLUX(JB,768)=FLUX(JB,768)+RC(JB,766)*Y(JB,295)*Y(JB,3)*DTS/M(JB) 
 1021 CONTINUE
C
C      --------------------
C      PHOTOLYTIC REACTIONS
C      --------------------
C
      DO 1020 JB=1,NBLOCK
C        O3 + hv = OD
        FLUX(JB,801)=FLUX(JB,801)+DJ(JB,1)*Y(JB,6)*DTS/M(JB)
C        O3 + hv = O
        FLUX(JB,802)=FLUX(JB,802)+DJ(JB,2)*Y(JB,6)*DTS/M(JB)
C        H2O2 + hv = OH + OH
        FLUX(JB,803)=FLUX(JB,803)+DJ(JB,3)*Y(JB,12)*DTS/M(JB)
C        NO2 + hv = NO + OP
        FLUX(JB,804)=FLUX(JB,804)+DJ(JB,4)*Y(JB,4)*DTS/M(JB)
C        NO3 + hv = NO
        FLUX(JB,805)=FLUX(JB,805)+DJ(JB,5)*Y(JB,5)*DTS/M(JB)
C        NO3 + hv = NO2 + OP
        FLUX(JB,806)=FLUX(JB,806)+DJ(JB,6)*Y(JB,5)*DTS/M(JB)
C        HONO + hv  = OH + NO
        FLUX(JB,807)=FLUX(JB,807)+DJ(JB,7)*Y(JB,13)*DTS/M(JB)
C        HNO3 + hv = NO2 + OH
        FLUX(JB,808)=FLUX(JB,808)+DJ(JB,8)*Y(JB,14)*DTS/M(JB)
C        HCHO + hv = CO + HO2 + HO2
        FLUX(JB,809)=FLUX(JB,809)+DJ(JB,9)*Y(JB,39)*DTS/M(JB)
C        HCHO + hv = CO + H2
        FLUX(JB,810)=FLUX(JB,810)+DJ(JB,10)*Y(JB,39)*DTS/M(JB)
C        CH3CHO + hv = CH3O2 + HO2 + CO
        FLUX(JB,811)=FLUX(JB,811)+DJ(JB,11)*Y(JB,42)*DTS/M(JB)
C      C2H5CHO = C2H5O2 + CO + HO2
        FLUX(JB,812)=FLUX(JB,812)+DJ(JB,12)*Y(JB,71)*DTS/M(JB)
C        CH3COCH3 + hv = CH3COO2 + CH3O2
        FLUX(JB,813)=FLUX(JB,813)+DJ(JB,13)*Y(JB,73)*DTS/M(JB)
C       MEK = CH3CO3 + C2H5O2 
        FLUX(JB,814)=FLUX(JB,814)+DJ(JB,14)*Y(JB,101)*DTS/M(JB)
C       CARB14 + CH3CO3 + RN10O2
        FLUX(JB,815)=FLUX(JB,815)+DJ(JB,15)*Y(JB,186)*DTS/M(JB)
C       CARB17->RN8O2+RN10O2 
        FLUX(JB,816)=FLUX(JB,816)+DJ(JB,16)*Y(JB,187)*DTS/M(JB)
C       CARB11A->CH3CO3+C2H5O2
        FLUX(JB,817)=FLUX(JB,817)+DJ(JB,17)*Y(JB,88)*DTS/M(JB)
C       CARB7->CH3CO3+HCHO+HO2    
        FLUX(JB,818)=FLUX(JB,818)+DJ(JB,18)*Y(JB,111)*DTS/M(JB)
C       CARB10->CH3CO3+CH3CHO+HO2 
        FLUX(JB,819)=FLUX(JB,819)+DJ(JB,19)*Y(JB,188)*DTS/M(JB)
C       CARB13->RN8O2+CH3CHO+HO2
        FLUX(JB,820)=FLUX(JB,820)+DJ(JB,20)*Y(JB,104)*DTS/M(JB)
C       CARB16->RN8O2+C2H5CHO+HO2
        FLUX(JB,821)=FLUX(JB,821)+DJ(JB,21)*Y(JB,105)*DTS/M(JB)
C       HOCH2CHO->HCHO+CO+HO2+HO2
        FLUX(JB,822)=FLUX(JB,822)+DJ(JB,22)*Y(JB,102)*DTS/M(JB)
C       UCARB10->CH3CO3+HCHO+HO2
        FLUX(JB,823)=FLUX(JB,823)+DJ(JB,23)*Y(JB,46)*DTS/M(JB)
C       CARB3->CO+CO+HO2+HO2
        FLUX(JB,824)=FLUX(JB,824)+DJ(JB,24)*Y(JB,60)*DTS/M(JB)
C       CARB6->CH3CO3+CO+HO2 
        FLUX(JB,825)=FLUX(JB,825)+DJ(JB,25)*Y(JB,98)*DTS/M(JB)
C       CARB9->CH3CO3+CH3CO3
        FLUX(JB,826)=FLUX(JB,826)+DJ(JB,26)*Y(JB,100)*DTS/M(JB)
C       CARB12->CH3CO3+RN8O2
        FLUX(JB,827)=FLUX(JB,827)+DJ(JB,27)*Y(JB,189)*DTS/M(JB)
C       CARB15->RN8O2+RN8O2
        FLUX(JB,828)=FLUX(JB,828)+DJ(JB,28)*Y(JB,190)*DTS/M(JB)
C       UCARB12->CH3CO3+HOCH2CHO+CO+HO2
        FLUX(JB,829)=FLUX(JB,829)+DJ(JB,29)*Y(JB,109)*DTS/M(JB)
C       NUCARB12->NOA+CO+CO+HO2+HO2
        FLUX(JB,830)=FLUX(JB,830)+DJ(JB,30)*Y(JB,113)*DTS/M(JB)
C       NOA->CH3CO3+HCHO+NO2
        FLUX(JB,831)=FLUX(JB,831)+DJ(JB,31)*Y(JB,115)*DTS/M(JB)
C       NOA->CH3CO3+HCHO+NO2
        FLUX(JB,832)=FLUX(JB,832)+DJ(JB,32)*Y(JB,115)*DTS/M(JB)
C       UDCARB8->C2H5O2+HO2
        FLUX(JB,833)=FLUX(JB,833)+DJ(JB,33)*Y(JB,96)*DTS/M(JB)
C       UDCARB8->ANHY+HO2+HO2
        FLUX(JB,834)=FLUX(JB,834)+DJ(JB,34)*Y(JB,96)*DTS/M(JB)
C       UDCARB11->RN10O2+HO2
        FLUX(JB,835)=FLUX(JB,835)+DJ(JB,35)*Y(JB,97)*DTS/M(JB)
C       UDCARB11->ANHY+HO2+CH3O2
        FLUX(JB,836)=FLUX(JB,836)+DJ(JB,36)*Y(JB,97)*DTS/M(JB)
C       UDCARB14->RN13O2+HO2
        FLUX(JB,837)=FLUX(JB,837)+DJ(JB,37)*Y(JB,99)*DTS/M(JB)
C       UDCARB14->ANHY+HO2+C2H5O2
        FLUX(JB,838)=FLUX(JB,838)+DJ(JB,38)*Y(JB,99)*DTS/M(JB)
C       TNCARB26->RTN26O2+HO2
        FLUX(JB,839)=FLUX(JB,839)+DJ(JB,39)*Y(JB,51)*DTS/M(JB)
C       TNCARB10->CH3CO3+CH3CO3+CO
        FLUX(JB,840)=FLUX(JB,840)+DJ(JB,40)*Y(JB,120)*DTS/M(JB)
C       CH3NO3->HCHO+HO2+NO2
        FLUX(JB,841)=FLUX(JB,841)+DJ(JB,41)*Y(JB,123)*DTS/M(JB)
C       C2H5NO3->CH3CHO+HO2+NO2
        FLUX(JB,842)=FLUX(JB,842)+DJ(JB,42)*Y(JB,124)*DTS/M(JB)
C       RN10NO3->C2H5CHO+HO2+NO2
        FLUX(JB,843)=FLUX(JB,843)+DJ(JB,43)*Y(JB,125)*DTS/M(JB)
C       IC3H7NO3->CH3COCH3+HO2+NO2
        FLUX(JB,844)=FLUX(JB,844)+DJ(JB,44)*Y(JB,126)*DTS/M(JB)
C       RN13NO3->CH3CHO+C2H5O2+NO2
        FLUX(JB,845)=FLUX(JB,845)+DJ(JB,45)*Y(JB,127)*DTS/M(JB)
C       RN13NO3->CARB11A+HO2+NO2
        FLUX(JB,846)=FLUX(JB,846)+DJ(JB,46)*Y(JB,127)*DTS/M(JB)
C       RN16NO3->RN15O2+NO2
        FLUX(JB,847)=FLUX(JB,847)+DJ(JB,47)*Y(JB,128)*DTS/M(JB)
C       RN19NO3->RN18O2+NO2
        FLUX(JB,848)=FLUX(JB,848)+DJ(JB,48)*Y(JB,129)*DTS/M(JB)
C       RA13NO3->CARB3+UDCARB8+HO2+NO2
        FLUX(JB,849)=FLUX(JB,849)+DJ(JB,49)*Y(JB,136)*DTS/M(JB)
C       RA16NO3->CARB3+UDCARB11+HO2+NO2
        FLUX(JB,850)=FLUX(JB,850)+DJ(JB,50)*Y(JB,137)*DTS/M(JB)
C       RA19NO3->CARB6+UDCARB11+HO2+NO2
        FLUX(JB,851)=FLUX(JB,851)+DJ(JB,51)*Y(JB,138)*DTS/M(JB)
C       RTX24NO3->TXCARB22+HO2+NO2
        FLUX(JB,852)=FLUX(JB,852)+DJ(JB,52)*Y(JB,142)*DTS/M(JB)
C       CH3OOH->HCHO+HO2+OH
        FLUX(JB,853)=FLUX(JB,853)+DJ(JB,53)*Y(JB,144)*DTS/M(JB)
C       C2H5OOH->CH3CHO+HO2+OH
        FLUX(JB,854)=FLUX(JB,854)+DJ(JB,54)*Y(JB,145)*DTS/M(JB)
C       RN10OOH->C2H5CHO+HO2+OH
        FLUX(JB,855)=FLUX(JB,855)+DJ(JB,55)*Y(JB,146)*DTS/M(JB)
C       IC3H7OOH->CH3COCH3+HO2+OH
        FLUX(JB,856)=FLUX(JB,856)+DJ(JB,56)*Y(JB,147)*DTS/M(JB)
C       RN13OOH->CH3CHO+C2H5O2+OH
        FLUX(JB,857)=FLUX(JB,857)+DJ(JB,57)*Y(JB,148)*DTS/M(JB)
C       RN13OOH->CARB11A+HO2+OH
        FLUX(JB,858)=FLUX(JB,858)+DJ(JB,58)*Y(JB,148)*DTS/M(JB)
C       RN16OOH->RN15AO2+OH
        FLUX(JB,859)=FLUX(JB,859)+DJ(JB,59)*Y(JB,149)*DTS/M(JB)
C       RN19OOH->RN18AO2+OH
        FLUX(JB,860)=FLUX(JB,860)+DJ(JB,60)*Y(JB,150)*DTS/M(JB)
C       CH3CO3H->CH3O2+OH
        FLUX(JB,861)=FLUX(JB,861)+DJ(JB,61)*Y(JB,159)*DTS/M(JB)
C       C2H5CO3H->C2H5O2+OH
        FLUX(JB,862)=FLUX(JB,862)+DJ(JB,62)*Y(JB,160)*DTS/M(JB)
C       HOCH2CO3H->HCHO+HO2+OH
        FLUX(JB,863)=FLUX(JB,863)+DJ(JB,63)*Y(JB,161)*DTS/M(JB)
C       RN8OOH->C2H5O2+OH
        FLUX(JB,864)=FLUX(JB,864)+DJ(JB,64)*Y(JB,162)*DTS/M(JB)
C       RN11OOH->RN10O2+OH
        FLUX(JB,865)=FLUX(JB,865)+DJ(JB,65)*Y(JB,163)*DTS/M(JB)
C       RN14OOH->RN13O2+OH
        FLUX(JB,866)=FLUX(JB,866)+DJ(JB,66)*Y(JB,164)*DTS/M(JB)
C       RN17OOH->RN16O2+OH
        FLUX(JB,867)=FLUX(JB,867)+DJ(JB,67)*Y(JB,165)*DTS/M(JB)
C       RU14OOH->UCARB12+HO2+OH
        FLUX(JB,868)=FLUX(JB,868)+DJ(JB,68)*Y(JB,166)*DTS/M(JB)
C       RU14OOH->UCARB10+HCHO+HO2+OH
        FLUX(JB,869)=FLUX(JB,869)+DJ(JB,69)*Y(JB,166)*DTS/M(JB)
C       RU12OOH->CARB6+HOCH2CHO+HO2+OH
        FLUX(JB,870)=FLUX(JB,870)+DJ(JB,70)*Y(JB,167)*DTS/M(JB)
C       RU10OOH->CH3CO3+HOCH2CHO+OH
        FLUX(JB,871)=FLUX(JB,871)+DJ(JB,71)*Y(JB,168)*DTS/M(JB)
C       NRU14OOH->NUCARB12+HO2+OH
        FLUX(JB,872)=FLUX(JB,872)+DJ(JB,72)*Y(JB,172)*DTS/M(JB)
C       NRU12OOH->NOA+CO+HO2+OH
        FLUX(JB,873)=FLUX(JB,873)+DJ(JB,73)*Y(JB,173)*DTS/M(JB)
C       HOC2H4OOH->HCHO+HCHO+HO2+OH
        FLUX(JB,874)=FLUX(JB,874)+DJ(JB,74)*Y(JB,154)*DTS/M(JB)
C       RN9OOH->CH3CHO+HCHO+HO2+OH
        FLUX(JB,875)=FLUX(JB,875)+DJ(JB,75)*Y(JB,155)*DTS/M(JB)
C       RN12OOH->CH3CHO+CH3CHO+HO2+OH
        FLUX(JB,876)=FLUX(JB,876)+DJ(JB,76)*Y(JB,156)*DTS/M(JB)
C       RN15OOH->C2H5CHO+CH3CHO+HO2+OH
        FLUX(JB,877)=FLUX(JB,877)+DJ(JB,77)*Y(JB,157)*DTS/M(JB)
C       RN18OOH->C2H5CHO+C2H5CHO+HO2+OH
        FLUX(JB,878)=FLUX(JB,878)+DJ(JB,78)*Y(JB,158)*DTS/M(JB)
C       NRN6OOH->HCHO+HCHO+NO2+OH
        FLUX(JB,879)=FLUX(JB,879)+DJ(JB,79)*Y(JB,169)*DTS/M(JB)
C       NRN9OOH->CH3CHO+HCHO+NO2+OH
        FLUX(JB,880)=FLUX(JB,880)+DJ(JB,80)*Y(JB,170)*DTS/M(JB)
C       NRN12OOH->CH3CHO+CH3CHO+NO2+OH
        FLUX(JB,881)=FLUX(JB,881)+DJ(JB,81)*Y(JB,171)*DTS/M(JB)
C       RA13OOH->CARB3+UDCARB8+HO2+OH
        FLUX(JB,882)=FLUX(JB,882)+DJ(JB,82)*Y(JB,151)*DTS/M(JB)
C       RA16OOH->CARB3+UDCARB11+HO2+OH
        FLUX(JB,883)=FLUX(JB,883)+DJ(JB,83)*Y(JB,152)*DTS/M(JB)
C       RA19OOH->CARB6+UDCARB11+HO2+OH
        FLUX(JB,884)=FLUX(JB,884)+DJ(JB,84)*Y(JB,153)*DTS/M(JB)
C       RTN28OOH->TNCARB26+HO2+OH
        FLUX(JB,885)=FLUX(JB,885)+DJ(JB,85)*Y(JB,174)*DTS/M(JB)
C       NRTN28OOH->TNCARB26+NO2+OH
        FLUX(JB,886)=FLUX(JB,886)+DJ(JB,86)*Y(JB,175)*DTS/M(JB)
C       RTN26OOH->RTN25O2+OH
        FLUX(JB,887)=FLUX(JB,887)+DJ(JB,87)*Y(JB,176)*DTS/M(JB)
C       RTN25OOH->RTN24O2+OH
        FLUX(JB,888)=FLUX(JB,888)+DJ(JB,88)*Y(JB,177)*DTS/M(JB)
C       RTN24OOH->RTN23O2+OH
        FLUX(JB,889)=FLUX(JB,889)+DJ(JB,89)*Y(JB,178)*DTS/M(JB)
C       RTN23OOH->CH3COCH3+RTN14O2+OH
        FLUX(JB,890)=FLUX(JB,890)+DJ(JB,90)*Y(JB,179)*DTS/M(JB)
C       RTN14OOH->TNCARB10+HCHO+HO2+OH
        FLUX(JB,891)=FLUX(JB,891)+DJ(JB,91)*Y(JB,180)*DTS/M(JB)
C       RTN10OOH->RN8O2+CO+OH
        FLUX(JB,892)=FLUX(JB,892)+DJ(JB,92)*Y(JB,181)*DTS/M(JB)
C       RTX28OOH->TXCARB24+HCHO+HO2+OH
        FLUX(JB,893)=FLUX(JB,893)+DJ(JB,93)*Y(JB,182)*DTS/M(JB)
C       RTX24OOH->TXCARB22+HO2+OH
        FLUX(JB,894)=FLUX(JB,894)+DJ(JB,94)*Y(JB,183)*DTS/M(JB)
C       TX22OOH->CH3COCH3+RN13O2+OH
        FLUX(JB,895)=FLUX(JB,895)+DJ(JB,95)*Y(JB,184)*DTS/M(JB)
C       NRTX28OOH->TXCARB24+HCHO+NO2+OH
        FLUX(JB,896)=FLUX(JB,896)+DJ(JB,96)*Y(JB,185)*DTS/M(JB)
        FLUX(JB,897)=FLUX(JB,897)+DJ(JB,97)*Y(JB,249)*DTS/M(JB)
        FLUX(JB,898)=FLUX(JB,898)+DJ(JB,98)*Y(JB,250)*DTS/M(JB)
        FLUX(JB,899)=FLUX(JB,899)+DJ(JB,99)*Y(JB,251)*DTS/M(JB)
        FLUX(JB,900)=FLUX(JB,900)+DJ(JB,100)*Y(JB,252)*DTS/M(JB)
        FLUX(JB,901)=FLUX(JB,901)+DJ(JB,101)*Y(JB,253)*DTS/M(JB)
        FLUX(JB,902)=FLUX(JB,902)+DJ(JB,102)*Y(JB,254)*DTS/M(JB)
        FLUX(JB,903)=FLUX(JB,903)+DJ(JB,103)*Y(JB,255)*DTS/M(JB)
        FLUX(JB,904)=FLUX(JB,904)+DJ(JB,104)*Y(JB,256)*DTS/M(JB)
        FLUX(JB,905)=FLUX(JB,905)+DJ(JB,105)*Y(JB,257)*DTS/M(JB)
        FLUX(JB,906)=FLUX(JB,906)+DJ(JB,106)*Y(JB,258)*DTS/M(JB)
        FLUX(JB,907)=FLUX(JB,907)+DJ(JB,107)*Y(JB,259)*DTS/M(JB)
        FLUX(JB,908)=FLUX(JB,908)+DJ(JB,108)*Y(JB,260)*DTS/M(JB)
        FLUX(JB,909)=FLUX(JB,909)+DJ(JB,109)*Y(JB,261)*DTS/M(JB)
        FLUX(JB,910)=FLUX(JB,910)+DJ(JB,110)*Y(JB,262)*DTS/M(JB)
        FLUX(JB,911)=FLUX(JB,911)+DJ(JB,111)*Y(JB,263)*DTS/M(JB)
        FLUX(JB,912)=FLUX(JB,912)+DJ(JB,112)*Y(JB,264)*DTS/M(JB)
        FLUX(JB,913)=FLUX(JB,913)+DJ(JB,113)*Y(JB,265)*DTS/M(JB)
        FLUX(JB,914)=FLUX(JB,914)+DJ(JB,114)*Y(JB,266)*DTS/M(JB)
        FLUX(JB,915)=FLUX(JB,915)+DJ(JB,115)*Y(JB,267)*DTS/M(JB)
        FLUX(JB,916)=FLUX(JB,916)+DJ(JB,116)*Y(JB,268)*DTS/M(JB)
        FLUX(JB,917)=FLUX(JB,917)+DJ(JB,117)*Y(JB,269)*DTS/M(JB)
        FLUX(JB,918)=FLUX(JB,918)+DJ(JB,118)*Y(JB,270)*DTS/M(JB)
        FLUX(JB,919)=FLUX(JB,919)+DJ(JB,119)*Y(JB,271)*DTS/M(JB)
        FLUX(JB,920)=FLUX(JB,920)+DJ(JB,120)*Y(JB,272)*DTS/M(JB)
        FLUX(JB,921)=FLUX(JB,921)+DJ(JB,121)*Y(JB,273)*DTS/M(JB)
        FLUX(JB,922)=FLUX(JB,922)+DJ(JB,122)*Y(JB,274)*DTS/M(JB)
        FLUX(JB,923)=FLUX(JB,923)+DJ(JB,123)*Y(JB,275)*DTS/M(JB)
        FLUX(JB,924)=FLUX(JB,924)+DJ(JB,124)*Y(JB,276)*DTS/M(JB)
        FLUX(JB,925)=FLUX(JB,925)+DJ(JB,125)*Y(JB,277)*DTS/M(JB)
        FLUX(JB,926)=FLUX(JB,926)+DJ(JB,126)*Y(JB,278)*DTS/M(JB)
        FLUX(JB,927)=FLUX(JB,927)+DJ(JB,127)*Y(JB,279)*DTS/M(JB)
        FLUX(JB,928)=FLUX(JB,928)+DJ(JB,128)*Y(JB,280)*DTS/M(JB)
        FLUX(JB,929)=FLUX(JB,929)+DJ(JB,129)*Y(JB,281)*DTS/M(JB)
        FLUX(JB,930)=FLUX(JB,930)+DJ(JB,130)*Y(JB,282)*DTS/M(JB)
        FLUX(JB,931)=FLUX(JB,931)+DJ(JB,131)*Y(JB,283)*DTS/M(JB)
        FLUX(JB,932)=FLUX(JB,932)+DJ(JB,132)*Y(JB,284)*DTS/M(JB)
        FLUX(JB,933)=FLUX(JB,933)+DJ(JB,133)*Y(JB,285)*DTS/M(JB)
        FLUX(JB,934)=FLUX(JB,934)+DJ(JB,134)*Y(JB,286)*DTS/M(JB)
        FLUX(JB,935)=FLUX(JB,935)+DJ(JB,135)*Y(JB,287)*DTS/M(JB)
        FLUX(JB,936)=FLUX(JB,936)+DJ(JB,136)*Y(JB,288)*DTS/M(JB)
        FLUX(JB,937)=FLUX(JB,937)+DJ(JB,137)*Y(JB,289)*DTS/M(JB)
        FLUX(JB,938)=FLUX(JB,938)+DJ(JB,138)*Y(JB,290)*DTS/M(JB)
        FLUX(JB,939)=FLUX(JB,939)+DJ(JB,139)*Y(JB,291)*DTS/M(JB)
        FLUX(JB,940)=FLUX(JB,940)+DJ(JB,140)*Y(JB,292)*DTS/M(JB)
        FLUX(JB,941)=FLUX(JB,941)+DJ(JB,141)*Y(JB,293)*DTS/M(JB)
        FLUX(JB,942)=FLUX(JB,942)+DJ(JB,142)*Y(JB,294)*DTS/M(JB)
        FLUX(JB,943)=FLUX(JB,943)+DJ(JB,143)*Y(JB,295)*DTS/M(JB)
C
C      -------------------------
C      EMISSIONS AND DEPOSITION:
C      -------------------------
C
        DO 1010 I=1,NC
          FLUX(JB,1000+I)=FLUX(JB,1000+I)+EM(JB,I)*DTS/M(JB)
          FLUX(JB,1400+I)=FLUX(JB,1400+I)+Y(JB,I)*DD(JB,I)*DTS/M(JB)
          FLUX(JB,1800+I)=FLUX(JB,1800+I)+Y(JB,I)*DW(JB,I)*DTS/M(JB)
 1010   CONTINUE
 1020 CONTINUE
C
C      debug concentrations for one cell.
CD     IF(DOBAL.EQ.1)THEN
CD       WRITE(6,*) 'DERIV: AFTER ITERATIONS, Y'
CD       WRITE(6,*) (Y(JB,I),I=1,NC)
CD     ENDIF
      DO I=1,NC
        DO  JB=1,NBLOCK                   ! No of cells per block
          YP(JB,I)=Y(JB,I)
        ENDDO
      ENDDO
C
C      FLUX now updated in DERIV
C FLUX(1-NR) holds fluxes through reactions 1-NR
C FLUX(601-600+NDJ) holds fluxes through photolytic reactions 1-NDJ
C FLUX(701-700+NC) holds fluxes through emissions of species 1-NC
C FLUX(801-800+NC) holds fluxes through depositions of species 1-NC
C FLUX(901-900+NC) holds fluxes through wet deposition of species 1-NC
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NOx emission & deposition %%%%%%%
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  400 CONTINUE                    ! End of Lagrangian time integration
C
      DO K=1,NC
        DO JB=1,NBLOCK
	  XX(K,JB)=Y(JB,K)/M(JB)   ! BACK TO MIXING RATIO
        ENDDO
      ENDDO
  999 RETURN
C
      END
C#######################################################################
      SUBROUTINE CHEMCO(RC,TC,M,O2,H2O,N2,RO2,SCI,ISP,BPN,APN,MOM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATES RATE COEFFICIENTS
C-
C-   Inputs  : TC,M,H2O
C-   Outputs : RC
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  21-MAR-1994   Bill Collins  Added RO2+CH3O2 reactions 240-241
C-   Updated  27-APR-1994   Bill Collins  Replaced ethanol with toluene -
C-                                        reactions 213 and 234.
C-   Modified 6-JAN-1994 Added SO2 oxidation and SA removal RC(255) and RC(256)
C-   Modified 7-JUN-1995 Colin Johnson Added M & O2 factors to RC(1),(7),(5)
C-  Modified 31-JUL-1996 Colin Johnson Given block structure.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated  26-NOV-1996   Dick Derwent with JPL 1994 rate coefficients
C-                                            Atkinson 1994 and MCM 1996
C-   Updated   7-JAN-1997   Bill Collins  Added aqueous phase reactions
C-                                        RC(260)-RC(262)
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,JB
      REAL RC(NBLOCK,NR),TC(NBLOCK),M(NBLOCK),H2O(NBLOCK)
      REAL RKLOW,RKHIGH,FC,BRN,REUS1
C
      REAL RK0,RK2,RK3
      REAL O2(NBLOCK),RO2(NBLOCK),SCI(NBLOCK),N2(NBLOCK)
      REAL ISP(NBLOCK),APN(NBLOCK),BPN(NBLOCK)
      REAL K0,KI,F
      REAL KRO2NO,KRO2HO2,KRO2NO3,KNO3AL,KDEC
      REAL KAPHO2,KFPAN,KBPAN,KAPNO,KDIMER
      REAL KC0,KCI,KRC,FCC
      REAL KD0,KDI,KRD,FCD,FD,K10,K1I,KR1,FC1,F1
      REAL K20,K2I,KR2,FC2,Fa2,K30,K3I,KR3,FC3,F3
      REAL K40,K4I,KR4,FC4,Fa4,K70,K7I,KR7,FC7,F7
      REAL K80,K8I,KR8,FC8,F8,K90,K9I,KR9,FC9,F9
      REAL K100,K10I,KR10,FC10,F10,K130,K13I,KR13,FC13,F13
      REAL K140,K14I,KR14,FC14,F14,K160,K16I,KR16,FC16,F16
      REAL K1,K2,K3,K4,KMT01,KMT02,KMT03,KMT04,KMT05
      REAL KMT06,KMT07,KMT08,KMT09,KMT10,KMT11
      REAL KMT12,KMT13,KMT14,KMT15,KMT16,KMT17 
      REAL KROPRIM,KROSEC,PANTOT,KDEC1,KTOT1,BR01(NBLOCK) 
      REAL FAC4,SOA,SOAM,YY,SC,OM,KIN,KOUT2604,KOUT4608
      REAL KOUT2631,KOUT2635,KOUT2641
      REAL KOUT4610,KOUT2605,KOUT4830,KOUT4829,KOUT3442
      REAL KOUT2630,KOUT2671,KOUT4834,KOUT5276,KOUT2617 
      REAL KOUT5236,KOUT4552,KOUT2703,KOUT2629,KOUT2007
      REAL KOUT2669,KOUT3613,KOUT3612,KOUT2637,KOUT2632
      REAL KOUT1001,KOUT1002,KOUT1003,KOUT1004,KOUT1005
      REAL KOUT1006,KOUT1007,KOUT1008,KOUT1009,KOUT1010
      REAL KOUT1011,KOUT1012,KOUT1013,KOUT1014,KOUT1015
      REAL KOUT1016,KOUT1017,KOUT1018,KOUT1019,KOUT1020
      REAL KOUT1021,KOUT1022,KOUT1023,KOUT1024,KOUT1025
      REAL KOUT1026,KOUT1027,KOUT1028,KOUT1029,KOUT1030
      REAL KOUT1031,KOUT1032,KOUT1033,KOUT1034,KOUT1035
      REAL KOUT1036,KOUT1037,KOUT1038,KOUT1039,KOUT1040
      REAL KOUT1041,KOUT1042,KOUT1043,KOUT1044,KOUT1045
      REAL KOUT1046,KOUT1047
      REAL BGOAM,KALKOXY,KALKPXY,K150,K15I,KR15,FC15,F15
      REAL K170, K17I, KR17,FC17,F17,R,MOM(NBLOCK)
       R = 8.314

      DO JB=1,NBLOCK
        DO I=1,NR
          RC(JB,I)=0.0
        ENDDO
      ENDDO

      DO JB=1,NBLOCK
C    SIMPLE RATE COEFFICIENTS                     
C                                                                     
      KRO2NO  = 2.54D-12*EXP(360/TC(JB)) 
      KAPNO   = 8.10D-12*EXP(270/TC(JB)) 
      KRO2NO3 = 2.50D-12 
      KRO2HO2 = 2.91D-13*EXP(1300/TC(JB)) 
      KAPHO2  = 4.30D-13*EXP(1040/TC(JB)) 
      KNO3AL  = 1.44D-12*EXP(-1862/TC(JB)) 
      KDEC    = 1.0D+06
      KALKOXY = 3.70D-14*EXP(-460/TC(JB))*O2(JB) 
      KALKPXY = 1.80D-14*EXP(-260/TC(JB))*O2(JB) 
      BR01(JB) = (0.156 + 9.77D+08*EXP(-6415/TC(JB))) 
      KDIMER=(4.8E-4)*EXP((1851.1/TC(JB))-(5.1E-3)*TC(JB))/
     &((8.4E+16)*TC(JB))
C

C
      KIN = 6.2E-03*MOM(JB)
      KOUT2007 = 2.065*EXP(-4421/(R*TC(JB)))
      KOUT2604 = 2.065*EXP(-7776/(R*TC(JB)))
      KOUT4608 = 2.065*EXP(-9765/(R*TC(JB)))
      KOUT2631 = 2.065*EXP(-14500/(R*TC(JB)))
      KOUT2635 = 2.065*EXP(-12541/(R*TC(JB)))
      KOUT4610 = 2.065*EXP(-10513/(R*TC(JB)))
      KOUT2605 = 2.065*EXP(-8879/(R*TC(JB)))
      KOUT2630 = 2.065*EXP(-12639/(R*TC(JB)))
      KOUT2629 = 2.065*EXP(-4954/(R*TC(JB)))
      KOUT2632 = 2.065*EXP(-3801/(R*TC(JB)))
      KOUT2637 = 2.065*EXP(-16752/(R*TC(JB)))
      KOUT3612 = 2.065*EXP(-6386/(R*TC(JB)))
      KOUT3613 = 2.065*EXP(-9027/(R*TC(JB)))
      KOUT3442 = 2.065*EXP(-10786/(R*TC(JB)))
C
      KOUT1001 = 2.065*EXP(-5578/(R*TC(JB)))
      KOUT1002 = 2.065*EXP(-4125/(R*TC(JB)))
      KOUT1003 = 2.065*EXP(-12191/(R*TC(JB)))
      KOUT1004 = 2.065*EXP(-4182/(R*TC(JB)))
      KOUT1005 = 2.065*EXP(-9477/(R*TC(JB)))
      KOUT1006 = 2.065*EXP(-22873/(R*TC(JB)))
      KOUT1007 = 2.065*EXP(-7448/(R*TC(JB)))
      KOUT1008 = 2.065*EXP(-15841/(R*TC(JB)))
      KOUT1009 = 2.065*EXP(-5373/(R*TC(JB)))
      KOUT1010 = 2.065*EXP(-13355/(R*TC(JB)))
      KOUT1011 = 2.065*EXP(-5421/(R*TC(JB)))
      KOUT1012 = 2.065*EXP(-10776/(R*TC(JB)))
      KOUT1013 = 2.065*EXP(-23839/(R*TC(JB)))
      KOUT1014 = 2.065*EXP(-1215/(R*TC(JB)))
      KOUT1015 = 2.065*EXP(-13025/(R*TC(JB)))
      KOUT1016 = 2.065*EXP(-21261/(R*TC(JB)))
      KOUT1017 = 2.065*EXP(-816/(R*TC(JB)))
      KOUT1018 = 2.065*EXP(-12177/(R*TC(JB)))
      KOUT1019 = 2.065*EXP(-20344/(R*TC(JB)))
      KOUT1020 = 2.065*EXP(-4222/(R*TC(JB)))
      KOUT1021 = 2.065*EXP(-11977/(R*TC(JB)))
      KOUT1022 = 2.065*EXP(-4911/(R*TC(JB)))
      KOUT1023 = 2.065*EXP(-16941/(R*TC(JB)))
      KOUT1024 = 2.065*EXP(-25510/(R*TC(JB)))
      KOUT1025 = 2.065*EXP(-7598/(R*TC(JB)))
      KOUT1026 = 2.065*EXP(-12568/(R*TC(JB)))
      KOUT1027 = 2.065*EXP(-24845/(R*TC(JB)))
      KOUT1028 = 2.065*EXP(-2549/(R*TC(JB)))
      KOUT1029 = 2.065*EXP(-13824/(R*TC(JB)))
      KOUT1030 = 2.065*EXP(-21863/(R*TC(JB)))
      KOUT1031 = 2.065*EXP(-1360/(R*TC(JB)))
      KOUT1032 = 2.065*EXP(-3145/(R*TC(JB)))
      KOUT1033 = 2.065*EXP(-14892/(R*TC(JB)))
      KOUT1034 = 2.065*EXP(-23186/(R*TC(JB)))
      KOUT1035 = 2.065*EXP(-5189/(R*TC(JB)))
      KOUT1036 = 2.065*EXP(-12970/(R*TC(JB)))
      KOUT1037 = 2.065*EXP(-248/(R*TC(JB)))
      KOUT1038 = 2.065*EXP(-11511/(R*TC(JB)))
      KOUT1039 = 2.065*EXP(-19646/(R*TC(JB)))
      KOUT1040 = 2.065*EXP(-4161/(R*TC(JB)))
      KOUT1041 = 2.065*EXP(-15442/(R*TC(JB)))
      KOUT1042 = 2.065*EXP(-23550/(R*TC(JB)))
      KOUT1043 = 2.065*EXP(-1614/(R*TC(JB)))
      KOUT1044 = 2.065*EXP(-6773/(R*TC(JB)))
      KOUT1045 = 2.065*EXP(-19367/(R*TC(JB)))
      KOUT1046 = 2.065*EXP(-28277/(R*TC(JB)))
      KOUT1047 = 2.065*EXP(-4036/(R*TC(JB)))
C
C    COMPLEX RATE COEFFICIENTS                    
C                                                                     
C    KFPAN                                                   
C                                                                     
      KC0     = 2.70D-28*M(JB)*(TC(JB)/300)**-7.1 
      KCI     = 1.21D-11*(TC(JB)/300)**-0.9    
      KRC     = KC0/KCI    
      FCC     = 0.30       
      FC      = 10**(LOG10(FCC)/(1+(LOG10(KRC))**2)) 
      KFPAN   = (KC0*KCI)*FC/(KC0+KCI) 
C                                                                   
C    KBPAN                                                   
      KD0     = 4.90D-03*M(JB)*EXP(-12100/TC(JB)) 
      KDI     = 3.70D+16*EXP(-13600/TC(JB))  
      KRD     = KD0/KDI    
      FCD     = 0.30       
      FD      = 10**(LOG10(FCD)/(1+(LOG10(KRD))**2)) 
      KBPAN   = (KD0*KDI)*FD/(KD0+KDI) 
C                                                                     
C     KMT01                                                   
      K10     = 9.00D-32*M(JB)*(TC(JB)/300)**-1.5 
      K1I     = 3.00D-11*(TC(JB)/300)**0.3    
      KR1     = K10/K1I    
      FC1     = 0.6 
      F1      = 10**(LOG10(FC1)/(1+(LOG10(KR1))**2)) 
      KMT01   = (K10*K1I)*F1/(K10+K1I) 
C                                                                     
C     KMT02                                                   
      K20 = 9.00D-32*((TC(JB)/300)**-2.0)*M(JB) 
      K2I = 2.20D-11
      KR2     = K20/K2I    
      FC2 = 0.6 
      Fa2      = 10**(LOG10(FC2)/(1+(LOG10(KR2))**2)) 
      KMT02   = (K20*K2I)*Fa2/(K20+K2I) 
C                                                                     
C      KMT03  : NO2      + NO3     = N2O5                               
C    IUPAC 2001                                                       
      K30     = 2.70D-30*M(JB)*(TC(JB)/300)**-3.4 
      K3I     = 2.00D-12*(TC(JB)/300)**0.2    
      KR3     = K30/K3I    
      FC3     = (EXP(-TC(JB)/250) + EXP(-1050/TC(JB))) 
      F3      = 10**(LOG10(FC3)/(1+(LOG10(KR3))**2)) 
      KMT03   = (K30*K3I)*F3/(K30+K3I) 
C                                                                     
C     KMT04  : N2O5               = NO2     + NO3                     
C IUPAC 1997/2001                                                 
      K40     =(2.20D-03*M(JB)*(TC(JB)/300)**-4.34)*(EXP(-11080/TC(JB)))
      K4I     = (9.70D+14*(TC(JB)/300)**0.1)*EXP(-11080/TC(JB))    
      KR4     = K40/K4I    
      FC4     = (EXP(-TC(JB)/250) + EXP(-1050/TC(JB)))
      Fa4      = 10**(LOG10(FC4)/(1+(LOG10(KR4))**2)) 
      KMT04   = (K40*K4I)*Fa4/(K40+K4I)       
C	WRITE(6,*)'KMTO4=',KMT04                                                               
C    KMT05                                                   
      KMT05  =  1 + ((0.6*M(JB))/(2.687D+19*(273/TC(JB)))) 
C                                                                     
C    KMT06                                                   
      KMT06  =  1 + (1.40D-21*EXP(2200/TC(JB))*H2O(JB)) 
C                                                                     
C    KMT07  : OH       + NO      = HONO                              
C    IUPAC 2001                                                      
      K70     = 7.00D-31*M(JB)*(TC(JB)/300)**-2.6 
      K7I     = 3.60D-11*(TC(JB)/300)**0.1    
      KR7     = K70/K7I    
      FC7     = 0.6  
      F7      = 10**(LOG10(FC7)/(1+(LOG10(KR7))**2)) 
      KMT07   = (K70*K7I)*F7/(K70+K7I) 
C                                                                     
C NASA 2000                                                           
  
C    KMT08                                                    
      K80 = 2.50D-30*((TC(JB)/300)**-4.4)*M(JB) 
      K8I = 1.60D-11 
      KR8 = K80/K8I 
      FC8 = 0.6 
      F8      = 10**(LOG10(FC8)/(1+(LOG10(KR8))**2)) 
      KMT08   = (K80*K8I)*F8/(K80+K8I) 
C                                                                     
C    KMT09  : HO2      + NO2     = HO2NO2                            
C IUPAC 1997/2001                                                 
      K90     = 1.80D-31*M(JB)*(TC(JB)/300)**-3.2 
      K9I     = 4.70D-12    
      KR9     = K90/K9I    
      FC9     = 0.6 
      F9      = 10**(LOG10(FC9)/(1+(LOG10(KR9))**2)) 
      KMT09   = (K90*K9I)*F9/(K90+K9I) 
C                                                                     
C KMT10  : HO2NO2             = HO2     + NO2                     
C IUPAC 2001                                                      
C
      K100     = 4.10D-05*M(JB)*EXP(-10650/TC(JB)) 
      K10I     = 5.70D+15*EXP(-11170/TC(JB))   
      KR10     = K100/K10I    
      FC10     = 0.5 
      F10      = 10**(LOG10(FC10)/(1+(LOG10(KR10))**2)) 
      KMT10    = (K100*K10I)*F10/(K100+K10I) 
C                                                                     
C   KMT11  : OH       + HNO3    = H2O     + NO3                     
C   IUPAC 2001                                                      
      K1     = 7.20D-15*EXP(785/TC(JB)) 
      K3     = 1.90D-33*EXP(725/TC(JB)) 
      K4     = 4.10D-16*EXP(1440/TC(JB)) 
      K2     = (K3*M(JB))/(1+(K3*M(JB)/K4)) 
      KMT11  = K1 + K2 
C                                                                     
C KMT12 : OH    +   SO2  =  HSO3                                  
C IUPAC 2003                                                      
      K0 = 3.0D-31*((TC(JB)/300)**-3.3)*M(JB) 
      KI = 1.5D-12 
      KR1 = K0/KI 
      FC = 0.6 
      F=10**(LOG10(FC)/(1+(LOG10(KR1))**2)) 
      KMT12=(K0*KI*F)/(K0+KI) 
C                                                                     
C KMT13  : CH3O2    + NO2     = CH3O2NO2                           
C IUPAC 2003                                                       
      K130     = 2.50D-30*((TC(JB)/300)**-5.5)*M(JB) 
      K13I     = 7.50D-12 
      KR13     = K130/K13I 
      FC13     = 0.36 
      F13      = 10**(LOG10(FC13)/(1+(LOG10(KR13))**2)) 
      KMT13    = (K130*K13I)*F13/(K130+K13I) 
C                                                                     
C  KMT14  : CH3O2NO2           = CH3O2   + NO2                      
C  IUPAC 2001                                                       
      K140     = 9.00D-05*EXP(-9690/TC(JB))*M(JB) 
      K14I     = 1.10D+16*EXP(-10560/TC(JB)) 
      KR14     = K140/K14I 
      FC14     = 0.36 
      F14      = 10**(LOG10(FC14)/(1+(LOG10(KR14))**2)) 
      KMT14    = (K140*K14I)*F14/(K140+K14I) 
C                                                                   
C KMT15  :    OH  +  C2H4  =                                       
C IUPAC 2001                                                      
      K150 = 6.00D-29*((TC(JB)/298)**-4.0)*M(JB) 
      K15I = 9.00D-12*((TC(JB)/298)**-1.1) 
      KR15 = K150/K15I 
      FC15 = 0.7
      F15      = 10**(LOG10(FC15)/(1+(LOG10(KR15))**2)) 
      KMT15    = (K150*K15I)*F15/(K150+K15I) 
C                                                                    
C KMT16  :  OH  +  C3H6         
C IUPAC 2003                                                     
      K160     = 3.00D-27*((TC(JB)/298)**-3.0)*M(JB) 
      K16I     = 2.80D-11*((TC(JB)/298)**-1.3) 
      KR16     = K160/K16I 
      FC16     = 0.5 
      F16      = 10**(LOG10(FC16)/(1+(LOG10(KR16))**2)) 
      KMT16    = (K160*K16I)*F16/(K160+K16I) 
C                                                                     
C    KMT17                                                   
      K170 = 5.00D-30*((TC(JB)/298)**-1.5)*M(JB) 
      K17I = 9.40D-12*EXP(-700/TC(JB)) 
      KR17     = K170/K17I 
      FC17 = (EXP(-TC(JB)/580) + EXP(-2320/TC(JB))) 
      F17      = 10**(LOG10(FC17)/(1+(LOG10(KR17))**2)) 
      KMT17    = (K170*K17I)*F17/(K170+K17I) 
C
C  LIST OF ALL REACTIONS 
C
C     Reaction (1) O = O3                                                             
         RC(JB,1) = 5.60D-34*O2(JB)*N2(JB)*((TC(JB)/300)**-2.6)
C
C     Reaction (2) O = O3                                                             
         RC(JB,2) = 6.00D-34*O2(JB)*O2(JB)*((TC(JB)/300)**-2.6)
C
C     Reaction (3) O + O3 =                                                           
         RC(JB,3) = 8.00D-12*EXP(-2060/TC(JB))         
C
C     Reaction (4) O + NO = NO2                                                       
         RC(JB,4) = KMT01                            
C
C     Reaction (5) O + NO2 = NO                                                       
         RC(JB,5) = 5.50D-12*EXP(188/TC(JB))           
C
C     Reaction (6) O + NO2 = NO3                                                      
         RC(JB,6) = KMT02                            
C
C     Reaction (7) O1D = O                                                            
         RC(JB,7) = 3.20D-11*O2(JB)*EXP(67/TC(JB))         
C
C     Reaction (8) O1D = O                                                            
         RC(JB,8) = 1.80D-11*N2(JB)*EXP(107/TC(JB))        
C
C     Reaction (9) NO + O3 = NO2                                                      
         RC(JB,9) = 1.40D-12*EXP(-1310/TC(JB))         
C
C     Reaction (10) NO2 + O3 = NO3                                                     
         RC(JB,10) = 1.40D-13*EXP(-2470/TC(JB))         
C
C     Reaction (11) NO + NO = NO2 + NO2                                                
         RC(JB,11) = 3.30D-39*EXP(530/TC(JB))*O2(JB)        
C
C     Reaction (12) NO + NO3 = NO2 + NO2                                               
         RC(JB,12) = 1.80D-11*EXP(110/TC(JB))           
C
C     Reaction (13) NO2 + NO3 = NO + NO2                                               
         RC(JB,13) = 4.50D-14*EXP(-1260/TC(JB))         
C
C     Reaction (14) NO2 + NO3 = N2O5                                                   
         RC(JB,14) = KMT03                            
C
C     Reaction (15) N2O5 = NO2 + NO3                                                   
         RC(JB,15) = KMT04                            
C
C     Reaction (16) O1D = OH + OH                                                      
         RC(JB,16) = 2.20D-10                     
C
C     Reaction (17) OH + O3 = HO2                                                      
         RC(JB,17) = 1.70D-12*EXP(-940/TC(JB))          
C
C     Reaction (18) OH + H2 = HO2                                                      
         RC(JB,18) = 7.70D-12*EXP(-2100/TC(JB))         
C
C     Reaction (19) OH + CO = HO2                                                      
         RC(JB,19) = 1.30D-13*KMT05                   
C
C     Reaction (20) OH + H2O2 = HO2                                                    
         RC(JB,20) = 2.90D-12*EXP(-160/TC(JB))          
C
C     Reaction (21) HO2 + O3 = OH                                                      
         RC(JB,21) = 2.03D-16*((TC(JB)/300)**4.57)*EXP(693/TC(JB))  
C
C     Reaction (22) OH + HO2 =                                                         
         RC(JB,22) = 4.80D-11*EXP(250/TC(JB))           
C
C     Reaction (23) HO2 + HO2 = H2O2                                                   
         RC(JB,23) = 2.20D-13*KMT06*EXP(600/TC(JB))     
C
C     Reaction (24) HO2 + HO2 = H2O2                                                   
         RC(JB,24) = 1.90D-33*M(JB)*KMT06*EXP(980/TC(JB))   
C
C     Reaction (25) OH + NO = HONO                                                     
         RC(JB,25) = KMT07                            
C
C     Reaction (26) NO2 = HONO                                                         
         RC(JB,26) = 5.0D-07                          
C
C     Reaction (27) OH + NO2 = HNO3                                                    
         RC(JB,27) = KMT08                            
C
C     Reaction (28) OH + NO3 = HO2 + NO2                                               
         RC(JB,28) = 2.00D-11                         
C
C     Reaction (29) HO2 + NO = OH + NO2                                                
         RC(JB,29) = 3.60D-12*EXP(270/TC(JB))           
C
C     Reaction (30) HO2 + NO2 = HO2NO2                                                 
         RC(JB,30) = KMT09                            
C
C     Reaction (31) HO2NO2 = HO2 + NO2                                                 
         RC(JB,31) = KMT10                            
C
C     Reaction (32) OH + HO2NO2 = NO2                                                  
         RC(JB,32) = 1.90D-12*EXP(270/TC(JB))           
C
C     Reaction (33) HO2 + NO3 = OH + NO2                                               
         RC(JB,33) = 4.00D-12                         
C
C     Reaction (34) OH + HONO = NO2                                                    
         RC(JB,34) = 2.50D-12*EXP(-260/TC(JB))          
C
C     Reaction (35) OH + HNO3 = NO3                                                    
         RC(JB,35) = KMT11                            
C
C     Reaction (36) O + SO2 = SO3                                                      
         RC(JB,36) = 4.00D-32*EXP(-1000/TC(JB))*M(JB)       
C
C     Reaction (37) OH + SO2 = HSO3                                                    
         RC(JB,37) = KMT12                            
C
C     Reaction (38) HSO3 = HO2 + SO3                                                   
         RC(JB,38) = 1.30D-12*EXP(-330/TC(JB))*O2(JB)       
C
C     Reaction (39) HNO3 = NAER                                                          
         RC(JB,39) = 6.00D-06                         
C
C     Reaction (40) N2O5 = NAER + NAER                                                     
         RC(JB,40) = 4.00D-05                         
C
C     Reaction (41) SO3 = SA                                                           
         RC(JB,41) = 1.20D-15*H2O(JB)                     
C
C     Reaction (42) OH + CH4 = CH3O2                                                   
         RC(JB,42) = 9.65D-20*TC(JB)**2.58*EXP(-1082/TC(JB)) 
C
C     Reaction (43) OH + C2H6 = C2H5O2                                                 
         RC(JB,43) = 1.52D-17*TC(JB)**2*EXP(-498/TC(JB)) 
C
C     Reaction (44) OH + C3H8 = IC3H7O2                                                
         RC(JB,44) = 1.55D-17*TC(JB)**2*EXP(-61/TC(JB))*0.736  
C
C     Reaction (45) OH + C3H8 = RN10O2                                                 
         RC(JB,45) = 1.55D-17*TC(JB)**2*EXP(-61/TC(JB))*0.264  
C
C     Reaction (46) OH + NC4H10 = RN13O2                                               
         RC(JB,46) = 1.69D-17*TC(JB)**2*EXP(145/TC(JB))  
C
C     Reaction (47) OH + C2H4 = HOCH2CH2O2                                             
         RC(JB,47) = KMT15                        
C
C     Reaction (48) OH + C3H6 = RN9O2                                                  
         RC(JB,48) = KMT16                        
C
C     Reaction (49) OH + TBUT2ENE = RN12O2                                             
         RC(JB,49) = 1.01D-11*EXP(550/TC(JB))       
C
C     Reaction (50) NO3 + C2H4 = NRN6O2                                                
         RC(JB,50) = 2.10D-16                     
C
C     Reaction (51) NO3 + C3H6 = NRN9O2                                                
         RC(JB,51) = 9.40D-15                     
C
C     Reaction (52) NO3 + TBUT2ENE = NRN12O2                                           
         RC(JB,52) = 3.90D-13                     
C
C     Reaction (53) O3 + C2H4 = HCHO + CO + HO2 + OH                                   
         RC(JB,53) = 9.14D-15*EXP(-2580/TC(JB))*0.13  
C
C     Reaction (54) O3 + C2H4 = HCHO + CO                                           
         RC(JB,54) = 9.14D-15*EXP(-2580/TC(JB))*0.50  
C
C     Reaction (55) O3 + C3H6 = HCHO + CO + CH3O2 + OH                                 
         RC(JB,55) = 5.51D-15*EXP(-1878/TC(JB))*0.47  
C
C     Reaction (56) O3 + C3H6 = CH3CHO + SCIE                                         
         RC(JB,56) = 5.51D-15*EXP(-1878/TC(JB))*0.37  
C
C     Reaction (57) O3 + TBUT2ENE = CH3CHO + CO + CH3O2 + OH                           
         RC(JB,57) = 6.64D-15*EXP(-1059/TC(JB))*0.79 
C
C     Reaction (58) O3 + TBUT2ENE = CH3CHO + SCIPA                                   
         RC(JB,58) = 6.64D-15*EXP(-1059/TC(JB))*0.105 
C
C     Reaction (59) OH + C5H8 = RU14O2                                                 
         RC(JB,59) = 2.54D-11*EXP(410/TC(JB))       
C
C     Reaction (60) NO3 + C5H8 = NRU14O2                                               
         RC(JB,60) = 3.03D-12*EXP(-446/TC(JB))      
C
C     Reaction (61) O3 + C5H8 = UCARB10 + CO + HO2 + OH                                
         RC(JB,61) = 1.03D-14*EXP(-1995/TC(JB))*0.19 
C
C     Reaction (62) O3 + C5H8 = UCARB10 + SCIE                                        
         RC(JB,62) = 1.03D-14*EXP(-1995/TC(JB))*0.31 
C
C     Reaction (63) APINENE + OH = RTN28O2                                             
         RC(JB,63) = 1.20D-11*EXP(444/TC(JB))           
C
C     Reaction (64) APINENE + NO3 = NRTN28O2                                           
         RC(JB,64) = 1.19D-12*EXP(490/TC(JB))           
C
C     Reaction (65) APINENE + O3 = OH + RTN26O2                                        
         RC(JB,65) = 8.05D-16*EXP(-640/TC(JB))*0.725  
C
C     Reaction (66) APINENE + O3 = TNCARB26 + H2O2                                     
         RC(JB,66) = 8.05D-16*EXP(-640/TC(JB))*0.075  
C
C     Reaction (67) APINENE + O3 = SCIPAA                                             
         RC(JB,67) = 8.05D-16*EXP(-640/TC(JB))*0.05  
C
C     Reaction (68) BPINENE + OH = RTX28O2                                             
         RC(JB,68) = 2.38D-11*EXP(357/TC(JB)) 
C
C     Reaction (69) BPINENE + NO3 = NRTX28O2                                           
         RC(JB,69) = 2.51D-12 
C
C     Reaction (70) BPINENE + O3 =  RTX24O2 + CO                                       
         RC(JB,70) = 1.35D-15*EXP(-1270/TC(JB))*0.18 
C
C     Reaction (71) BPINENE + O3 =  HCHO + TXCARB24 + H2O2                             
         RC(JB,71) = 1.35D-15*EXP(-1270/TC(JB))*0.20 
C
C     Reaction (72) BPINENE + O3 =  HCHO + TXCARB22                                    
         RC(JB,72) = 1.35D-15*EXP(-1270/TC(JB))*0.25 
C
C     Reaction (73) BPINENE + O3 =  HCHO+SCIBPA                                      
         RC(JB,73) = 1.35D-15*EXP(-1270/TC(JB))*0.18 
C
C     Reaction (74) C2H2 + OH = HCOOH + CO + HO2                                       
         RC(JB,74) = KMT17*0.364 
C
C     Reaction (75) C2H2 + OH = CARB3 + OH                                             
         RC(JB,75) = KMT17*0.636 
C
C     Reaction (76) BENZENE + OH = RA13O2                                              
         RC(JB,76) = 2.33D-12*EXP(-193/TC(JB))*0.47 
C
C     Reaction (77) BENZENE + OH = AROH14 + HO2                                        
         RC(JB,77) = 2.33D-12*EXP(-193/TC(JB))*0.53 
C
C     Reaction (78) TOLUENE + OH = RA16O2                                              
         RC(JB,78) = 1.81D-12*EXP(338/TC(JB))*0.82 
C
C     Reaction (79) TOLUENE + OH = AROH17 + HO2                                        
         RC(JB,79) = 1.81D-12*EXP(338/TC(JB))*0.18 
C
C     Reaction (80) OXYL + OH = RA19AO2                                                
         RC(JB,80) = 1.36D-11*0.70 
C
C     Reaction (81) OXYL + OH = RA19CO2                                                
         RC(JB,81) = 1.36D-11*0.30 
C
C     Reaction (82) OH + HCHO = HO2 + CO                                               
         RC(JB,82) = 1.20D-14*TC(JB)*EXP(287/TC(JB))  
C
C     Reaction (83) OH + CH3CHO = CH3CO3                                               
         RC(JB,83) = 5.55D-12*EXP(311/TC(JB))             
C
C     Reaction (84) OH + C2H5CHO = C2H5CO3                                             
         RC(JB,84) = 1.96D-11                                
C
C     Reaction (85) NO3 + HCHO = HO2 + CO + HNO3                                       
         RC(JB,85) = 5.80D-16                  
C
C     Reaction (86) NO3 + CH3CHO = CH3CO3 + HNO3                                       
         RC(JB,86) = KNO3AL                   
C
C     Reaction (87) NO3 + C2H5CHO = C2H5CO3 + HNO3                                     
         RC(JB,87) = KNO3AL*2.4             
C
C     Reaction (88) OH + CH3COCH3 = RN8O2                                              
         RC(JB,88) = 5.34D-18*TC(JB)**2*EXP(-230/TC(JB)) 
C
C     Reaction (89) MEK + OH = RN11O2                                                  
         RC(JB,89) = 3.24D-18*TC(JB)**2*EXP(414/TC(JB))
C
C     Reaction (90) OH + CH3OH = HO2 + HCHO                                            
         RC(JB,90) = 6.01D-18*TC(JB)**2*EXP(170/TC(JB))  
C
C     Reaction (91) OH + C2H5OH = CH3CHO + HO2                                         
         RC(JB,91) = 6.18D-18*TC(JB)**2*EXP(532/TC(JB))*0.887 
C
C     Reaction (92) OH + C2H5OH = HOCH2CH2O2                                           
         RC(JB,92) = 6.18D-18*TC(JB)**2*EXP(532/TC(JB))*0.113 
C
C     Reaction (93) NPROPOL + OH = C2H5CHO + HO2                                       
         RC(JB,93) = 5.53D-12*0.49 
C
C     Reaction (94) NPROPOL + OH = RN9O2                                               
         RC(JB,94) = 5.53D-12*0.51 
C
C     Reaction (95) OH + IPROPOL = CH3COCH3 + HO2                                      
         RC(JB,95) = 4.06D-18*TC(JB)**2*EXP(788/TC(JB))*0.86 
C
C     Reaction (96) OH + IPROPOL = RN9O2                                               
         RC(JB,96) = 4.06D-18*TC(JB)**2*EXP(788/TC(JB))*0.14 
C
C     Reaction (97) HCOOH + OH = HO2                                                   
         RC(JB,97) = 4.50D-13 
C
C     Reaction (98) CH3CO2H + OH = CH3O2                                               
         RC(JB,98) = 8.00D-13 
C
C     Reaction (99) OH + CH3CL = CH3O2                                                 
         RC(JB,99) = 7.33D-18*TC(JB)**2*EXP(-809/TC(JB))   
C
C     Reaction (100) OH + CH2CL2 = CH3O2                                                
         RC(JB,100) = 6.14D-18*TC(JB)**2*EXP(-389/TC(JB))   
C
C     Reaction (101) OH + CHCL3 = CH3O2                                                 
         RC(JB,101) = 1.80D-18*TC(JB)**2*EXP(-129/TC(JB))   
C
C     Reaction (102) OH + CH3CCL3 = C2H5O2                                              
         RC(JB,102) = 2.25D-18*TC(JB)**2*EXP(-910/TC(JB))   
C
C     Reaction (103) OH + TCE = HOCH2CH2O2                                              
         RC(JB,103) = 9.64D-12*EXP(-1209/TC(JB))         
C
C     Reaction (104) OH + TRICLETH = HOCH2CH2O2                                         
         RC(JB,104) = 5.63D-13*EXP(427/TC(JB))            
C
C     Reaction (105) OH + CDICLETH = HOCH2CH2O2                                         
         RC(JB,105) = 1.94D-12*EXP(90/TC(JB))            
C
C     Reaction (106) OH + TDICLETH = HOCH2CH2O2                                         
         RC(JB,106) = 1.01D-12*EXP(250/TC(JB))           
C
C     Reaction (107) CH3O2 + NO = HCHO + HO2 + NO2                                      
         RC(JB,107) = 3.00D-12*EXP(280/TC(JB))*0.999 
C
C     Reaction (108) C2H5O2 + NO = CH3CHO + HO2 + NO2                                   
         RC(JB,108) = 2.60D-12*EXP(365/TC(JB))*0.991 
C
C     Reaction (109) RN10O2 + NO = C2H5CHO + HO2 + NO2                                  
         RC(JB,109) = 2.80D-12*EXP(360/TC(JB))*0.980 
C
C     Reaction (110) IC3H7O2 + NO = CH3COCH3 + HO2 + NO2                                
         RC(JB,110) = 2.70D-12*EXP(360/TC(JB))*0.958 
C
C     Reaction (111) RN13O2 + NO = CH3CHO + C2H5O2 + NO2                                
         RC(JB,111) = KRO2NO*0.917*BR01(JB)       
C
C     Reaction (112) RN13O2 + NO = CARB11A + HO2 + NO2                                  
         RC(JB,112) = KRO2NO*0.917*(1-BR01(JB))   
C
C     Reaction (113) RN16O2 + NO = RN15AO2 + NO2                                        
         RC(JB,113) = KRO2NO*0.877                 
C
C     Reaction (114) RN19O2 + NO = RN18AO2 + NO2                                        
         RC(JB,114) = KRO2NO*0.788                 
C
C     Reaction (115) RN13AO2 + NO = RN12O2 + NO2                                        
         RC(JB,115) = KRO2NO                       
C
C     Reaction (116) RN16AO2 + NO = RN15O2 + NO2                                        
         RC(JB,116) = KRO2NO                       
C
C     Reaction (117) RA13O2 + NO = CARB3 + UDCARB8 + HO2 + NO2                          
         RC(JB,117) = KRO2NO*0.918       
C
C     Reaction (118) RA16O2 + NO = CARB3 + UDCARB11 + HO2 + NO2                         
         RC(JB,118) = KRO2NO*0.889*0.7 
C
C     Reaction (119) RA16O2 + NO = CARB6 + UDCARB8 + HO2 + NO2                          
         RC(JB,119) = KRO2NO*0.889*0.3 
C
C     Reaction (120) RA19AO2 + NO = CARB3 + UDCARB14 + HO2 + NO2                        
         RC(JB,120) = KRO2NO*0.862       
C
C     Reaction (121) RA19CO2 + NO = CARB9 + UDCARB8 + HO2 + NO2                         
         RC(JB,121) = KRO2NO*0.862       
C
C     Reaction (122) HOCH2CH2O2 + NO = HCHO + HCHO + HO2 + NO2                          
         RC(JB,122) = KRO2NO*0.995*0.776  
C
C     Reaction (123) HOCH2CH2O2 + NO = HOCH2CHO + HO2 + NO2                             
         RC(JB,123) = KRO2NO*0.995*0.224  
C
C     Reaction (124) RN9O2 + NO = CH3CHO + HCHO + HO2 + NO2                             
         RC(JB,124) = KRO2NO*0.979     
C
C     Reaction (125) RN12O2 + NO = CH3CHO + CH3CHO + HO2 + NO2                          
         RC(JB,125) = KRO2NO*0.959     
C
C     Reaction (126) RN15O2 + NO = C2H5CHO + CH3CHO + HO2 + NO2                         
         RC(JB,126) = KRO2NO*0.936     
C
C     Reaction (127) RN18O2 + NO = C2H5CHO + C2H5CHO + HO2 + NO2                        
         RC(JB,127) = KRO2NO*0.903     
C
C     Reaction (128) RN15AO2 + NO = CARB13 + HO2 + NO2                                  
         RC(JB,128) = KRO2NO*0.975     
C
C     Reaction (129) RN18AO2 + NO = CARB16 + HO2 + NO2                                  
         RC(JB,129) = KRO2NO*0.946     
C
C     Reaction (130) CH3CO3 + NO = CH3O2 + NO2                                          
         RC(JB,130) = KAPNO                      
C
C     Reaction (131) C2H5CO3 + NO = C2H5O2 + NO2                                        
         RC(JB,131) = KAPNO                      
C
C     Reaction (132) HOCH2CO3 + NO = HO2 + HCHO + NO2                                   
         RC(JB,132) = KAPNO                      
C
C     Reaction (133) RN8O2 + NO = CH3CO3 + HCHO + NO2                                   
         RC(JB,133) = KRO2NO                     
C
C     Reaction (134) RN11O2 + NO = CH3CO3 + CH3CHO + NO2                                
         RC(JB,134) = KRO2NO                     
C
C     Reaction (135) RN14O2 + NO = C2H5CO3 + CH3CHO + NO2                               
         RC(JB,135) = KRO2NO                     
C
C     Reaction (136) RN17O2 + NO = RN16AO2 + NO2                                        
         RC(JB,136) = KRO2NO                     
C
C     Reaction (137) RU14O2 + NO = UCARB12 + HO2 +  NO2                                 
         RC(JB,137) = KRO2NO*0.900*0.252  
C
C     Reaction (138) RU14O2 + NO = UCARB10 + HCHO + HO2 + NO2                           
         RC(JB,138) = KRO2NO*0.900*0.748 
C
C     Reaction (139) RU12O2 + NO = CH3CO3 + HOCH2CHO + NO2                              
         RC(JB,139) = KRO2NO*0.7         
C
C     Reaction (140) RU12O2 + NO = CARB7 + CO + HO2 + NO2                               
         RC(JB,140) = KRO2NO*0.3         
C
C     Reaction (141) RU10O2 + NO = CH3CO3 + HOCH2CHO + NO2                              
         RC(JB,141) = KRO2NO*0.5         
C
C     Reaction (142) RU10O2 + NO = CARB6 + HCHO + HO2 + NO2                             
         RC(JB,142) = KRO2NO*0.3         
C
C     Reaction (143) RU10O2 + NO = CARB7 + HCHO + HO2 + NO2                             
         RC(JB,143) = KRO2NO*0.2          
C
C     Reaction (144) NRN6O2 + NO = HCHO + HCHO + NO2 + NO2                              
         RC(JB,144) = KRO2NO                 
C
C     Reaction (145) NRN9O2 + NO = CH3CHO + HCHO + NO2 + NO2                            
         RC(JB,145) = KRO2NO                 
C
C     Reaction (146) NRN12O2 + NO = CH3CHO + CH3CHO + NO2 + NO2                         
         RC(JB,146) = KRO2NO                 
C
C     Reaction (147) NRU14O2 + NO = NUCARB12 + HO2 + NO2                                
         RC(JB,147) = KRO2NO                 
C
C     Reaction (148) NRU12O2 + NO = NOA + CO + HO2 + NO2                                
         RC(JB,148) = KRO2NO                 
C
C     Reaction (149) RTN28O2 + NO = TNCARB26 + HO2 + NO2                                
         RC(JB,149) = KRO2NO*0.767*0.915  
C
C     Reaction (150) RTN28O2 + NO = CH3COCH3 + RN19O2 + NO2                             
         RC(JB,150) = KRO2NO*0.767*0.085  
C
C     Reaction (151) NRTN28O2 + NO = TNCARB26 + NO2 + NO2                               
         RC(JB,151) = KRO2NO                  
C
C     Reaction (152) RTN26O2 + NO = RTN25O2 + NO2                                       
         RC(JB,152) = KAPNO                   
C
C     Reaction (153) RTN25O2 + NO = RTN24O2 + NO2                                       
         RC(JB,153) = KRO2NO*0.840        
C
C     Reaction (154) RTN24O2 + NO = RTN23O2 + NO2                                       
         RC(JB,154) = KRO2NO                   
C
C     Reaction (155) RTN23O2 + NO = CH3COCH3 + RTN14O2 + NO2                            
         RC(JB,155) = KRO2NO                  
C
C     Reaction (156) RTN14O2 + NO = HCHO + TNCARB10 + HO2 + NO2                         
         RC(JB,156) = KRO2NO               
C
C     Reaction (157) RTN10O2 + NO = RN8O2 + CO + NO2                                    
         RC(JB,157) = KRO2NO               
C
C     Reaction (158) RTX28O2 + NO = TXCARB24 + HCHO + HO2 + NO2                         
         RC(JB,158) = KRO2NO*0.767*0.915  
C
C     Reaction (159) RTX28O2 + NO = CH3COCH3 + RN19O2 + NO2                             
         RC(JB,159) = KRO2NO*0.767*0.085  
C
C     Reaction (160) NRTX28O2 + NO = TXCARB24 + HCHO + NO2 + NO2                        
         RC(JB,160) = KRO2NO            
C
C     Reaction (161) RTX24O2 + NO = TXCARB22 + HO2 + NO2                                
         RC(JB,161) = KRO2NO*0.843*0.6  
C
C     Reaction (162) RTX24O2 + NO = CH3COCH3 + RN13AO2 + HCHO + NO2                     
         RC(JB,162) = KRO2NO*0.843*0.4  
C
C     Reaction (163) RTX22O2 + NO = CH3COCH3 + RN13O2 + NO2                             
         RC(JB,163) = KRO2NO*0.700         
C
C     Reaction (164) CH3O2    + NO2     = CH3O2NO2                                      
         RC(JB,164) = KMT13         
C
C     Reaction (165) CH3O2NO2           = CH3O2   + NO2                                 
         RC(JB,165) = KMT14         
C
C     Reaction (166) CH3O2 + NO = CH3NO3                                                
         RC(JB,166) = 3.00D-12*EXP(280/TC(JB))*0.001 
C
C     Reaction (167) C2H5O2 + NO = C2H5NO3                                              
         RC(JB,167) = 2.60D-12*EXP(365/TC(JB))*0.009 
C
C     Reaction (168) RN10O2 + NO = RN10NO3                                              
         RC(JB,168) = 2.80D-12*EXP(360/TC(JB))*0.020 
C
C     Reaction (169) IC3H7O2 + NO = IC3H7NO3                                            
         RC(JB,169) = 2.70D-12*EXP(360/TC(JB))*0.042 
C
C     Reaction (170) RN13O2 + NO = RN13NO3                                              
         RC(JB,170) = KRO2NO*0.083                 
C
C     Reaction (171) RN16O2 + NO = RN16NO3                                              
         RC(JB,171) = KRO2NO*0.123                 
C
C     Reaction (172) RN19O2 + NO = RN19NO3                                              
         RC(JB,172) = KRO2NO*0.212                 
C
C     Reaction (173) HOCH2CH2O2 + NO = HOC2H4NO3                                        
         RC(JB,173) = KRO2NO*0.005                 
C
C     Reaction (174) RN9O2 + NO = RN9NO3                                                
         RC(JB,174) = KRO2NO*0.021                 
C
C     Reaction (175) RN12O2 + NO = RN12NO3                                              
         RC(JB,175) = KRO2NO*0.041                 
C
C     Reaction (176) RN15O2 + NO = RN15NO3                                              
         RC(JB,176) = KRO2NO*0.064                 
C
C     Reaction (177) RN18O2 + NO = RN18NO3                                              
         RC(JB,177) = KRO2NO*0.097                 
C
C     Reaction (178) RN15AO2 + NO = RN15NO3                                             
         RC(JB,178) = KRO2NO*0.025                 
C
C     Reaction (179) RN18AO2 + NO = RN18NO3                                             
         RC(JB,179) = KRO2NO*0.054                 
C
C     Reaction (180) RU14O2 + NO = RU14NO3                                              
         RC(JB,180) = KRO2NO*0.100                 
C
C     Reaction (181) RA13O2 + NO = RA13NO3                                              
         RC(JB,181) = KRO2NO*0.082                 
C
C     Reaction (182) RA16O2 + NO = RA16NO3                                              
         RC(JB,182) = KRO2NO*0.111                 
C
C     Reaction (183) RA19AO2 + NO = RA19NO3                                             
         RC(JB,183) = KRO2NO*0.138                 
C
C     Reaction (184) RA19CO2 + NO = RA19NO3                                             
         RC(JB,184) = KRO2NO*0.138                 
C
C     Reaction (185) RTN28O2 + NO = RTN28NO3                                            
         RC(JB,185) = KRO2NO*0.233        
C
C     Reaction (186) RTN25O2 + NO = RTN25NO3                                            
         RC(JB,186) = KRO2NO*0.160        
C
C     Reaction (187) RTX28O2 + NO = RTX28NO3                                            
         RC(JB,187) = KRO2NO*0.233        
C
C     Reaction (188) RTX24O2 + NO = RTX24NO3                                            
         RC(JB,188) = KRO2NO*0.157        
C
C     Reaction (189) RTX22O2 + NO = RTX22NO3                                            
         RC(JB,189) = KRO2NO*0.300        
C
C     Reaction (190) CH3O2 + NO3 = HCHO + HO2 + NO2                                     
         RC(JB,190) = KRO2NO3*0.40          
C
C     Reaction (191) C2H5O2 + NO3 = CH3CHO + HO2 + NO2                                  
         RC(JB,191) = KRO2NO3               
C
C     Reaction (192) RN10O2 + NO3 = C2H5CHO + HO2 + NO2                                 
         RC(JB,192) = KRO2NO3               
C
C     Reaction (193) IC3H7O2 + NO3 = CH3COCH3 + HO2 + NO2                               
         RC(JB,193) = KRO2NO3               
C
C     Reaction (194) RN13O2 + NO3 = CH3CHO + C2H5O2 + NO2                               
         RC(JB,194) = KRO2NO3*BR01(JB)     
C
C     Reaction (195) RN13O2 + NO3 = CARB11A + HO2 + NO2                                 
         RC(JB,195) = KRO2NO3*(1-BR01(JB)) 
C
C     Reaction (196) RN16O2 + NO3 = RN15AO2 + NO2                                       
         RC(JB,196) = KRO2NO3               
C
C     Reaction (197) RN19O2 + NO3 = RN18AO2 + NO2                                       
         RC(JB,197) = KRO2NO3               
C
C     Reaction (198) RN13AO2 + NO3 = RN12O2 + NO2                                       
         RC(JB,198) = KRO2NO3                      
C
C     Reaction (199) RN16AO2 + NO3 = RN15O2 + NO2                                       
         RC(JB,199) = KRO2NO3                      
C
C     Reaction (200) RA13O2 + NO3 = CARB3 + UDCARB8 + HO2 + NO2                         
         RC(JB,200) = KRO2NO3            
C
C     Reaction (201) RA16O2 + NO3 = CARB3 + UDCARB11 + HO2 + NO2                        
         RC(JB,201) = KRO2NO3*0.7     
C
C     Reaction (202) RA16O2 + NO3 = CARB6 + UDCARB8 + HO2 + NO2                         
         RC(JB,202) = KRO2NO3*0.3     
C
C     Reaction (203) RA19AO2 + NO3 = CARB3 + UDCARB14 + HO2 + NO2                       
         RC(JB,203) = KRO2NO3           
C
C     Reaction (204) RA19CO2 + NO3 = CARB9 + UDCARB8 + HO2 + NO2                        
         RC(JB,204) = KRO2NO3           
C
C     Reaction (205) HOCH2CH2O2 + NO3 = HCHO + HCHO + HO2 + NO2                         
         RC(JB,205) = KRO2NO3*0.776  
C
C     Reaction (206) HOCH2CH2O2 + NO3 = HOCH2CHO + HO2 + NO2                            
         RC(JB,206) = KRO2NO3*0.224  
C
C     Reaction (207) RN9O2 + NO3 = CH3CHO + HCHO + HO2 + NO2                            
         RC(JB,207) = KRO2NO3         
C
C     Reaction (208) RN12O2 + NO3 = CH3CHO + CH3CHO + HO2 + NO2                         
         RC(JB,208) = KRO2NO3         
C
C     Reaction (209) RN15O2 + NO3 = C2H5CHO + CH3CHO + HO2 + NO2                        
         RC(JB,209) = KRO2NO3         
C
C     Reaction (210) RN18O2 + NO3 = C2H5CHO + C2H5CHO + HO2 + NO2                       
         RC(JB,210) = KRO2NO3         
C
C     Reaction (211) RN15AO2 + NO3 = CARB13 + HO2 + NO2                                 
         RC(JB,211) = KRO2NO3         
C
C     Reaction (212) RN18AO2 + NO3 = CARB16 + HO2 + NO2                                 
         RC(JB,212) = KRO2NO3         
C
C     Reaction (213) CH3CO3 + NO3 = CH3O2 + NO2                                         
         RC(JB,213) = KRO2NO3*1.60          
C
C     Reaction (214) C2H5CO3 + NO3 = C2H5O2 + NO2                                       
         RC(JB,214) = KRO2NO3*1.60          
C
C     Reaction (215) HOCH2CO3 + NO3 = HO2 + HCHO + NO2                                  
         RC(JB,215) = KRO2NO3*1.60         
C
C     Reaction (216) RN8O2 + NO3 = CH3CO3 + HCHO + NO2                                  
         RC(JB,216) = KRO2NO3               
C
C     Reaction (217) RN11O2 + NO3 = CH3CO3 + CH3CHO + NO2                               
         RC(JB,217) = KRO2NO3               
C
C     Reaction (218) RN14O2 + NO3 = C2H5CO3 + CH3CHO + NO2                              
         RC(JB,218) = KRO2NO3               
C
C     Reaction (219) RN17O2 + NO3 = RN16AO2 + NO2                                       
         RC(JB,219) = KRO2NO3               
C
C     Reaction (220) RU14O2 + NO3 = UCARB12 + HO2 + NO2                                 
         RC(JB,220) = KRO2NO3*0.252     
C
C     Reaction (221) RU14O2 + NO3 = UCARB10 + HCHO + HO2 + NO2                          
         RC(JB,221) = KRO2NO3*0.748     
C
C     Reaction (222) RU12O2 + NO3 = CH3CO3 + HOCH2CHO + NO2                             
         RC(JB,222) = KRO2NO3*0.7         
C
C     Reaction (223) RU12O2 + NO3 = CARB7 + CO + HO2 + NO2                              
         RC(JB,223) = KRO2NO3*0.3         
C
C     Reaction (224) RU10O2 + NO3 = CH3CO3 + HOCH2CHO + NO2                             
         RC(JB,224) = KRO2NO3*0.5         
C
C     Reaction (225) RU10O2 + NO3 = CARB6 + HCHO + HO2 + NO2                            
         RC(JB,225) = KRO2NO3*0.3         
C
C     Reaction (226) RU10O2 + NO3 = CARB7 + HCHO + HO2 + NO2                            
         RC(JB,226) = KRO2NO3*0.2         
C
C     Reaction (227) NRN6O2 + NO3 = HCHO + HCHO + NO2 + NO2                             
         RC(JB,227) = KRO2NO3               
C
C     Reaction (228) NRN9O2 + NO3 = CH3CHO + HCHO + NO2 + NO2                           
         RC(JB,228) = KRO2NO3               
C
C     Reaction (229) NRN12O2 + NO3 = CH3CHO + CH3CHO + NO2 + NO2                        
         RC(JB,229) = KRO2NO3               
C
C     Reaction (230) NRU14O2 + NO3 = NUCARB12 + HO2 + NO2                               
         RC(JB,230) = KRO2NO3               
C
C     Reaction (231) NRU12O2 + NO3 = NOA + CO + HO2 + NO2                               
         RC(JB,231) = KRO2NO3               
C
C     Reaction (232) RTN28O2 + NO3 = TNCARB26 + HO2 + NO2                               
         RC(JB,232) = KRO2NO3                
C
C     Reaction (233) NRTN28O2 + NO3 = TNCARB26 + NO2 + NO2                              
         RC(JB,233) = KRO2NO3                
C
C     Reaction (234) RTN26O2 + NO3 = RTN25O2 + NO2                                      
         RC(JB,234) = KRO2NO3*1.60                   
C
C     Reaction (235) RTN25O2 + NO3 = RTN24O2 + NO2                                      
         RC(JB,235) = KRO2NO3                 
C
C     Reaction (236) RTN24O2 + NO3 = RTN23O2 + NO2                                      
         RC(JB,236) = KRO2NO3                   
C
C     Reaction (237) RTN23O2 + NO3 = CH3COCH3 + RTN14O2 + NO2                           
         RC(JB,237) = KRO2NO3                 
C
C     Reaction (238) RTN14O2 + NO3 = HCHO + TNCARB10 + HO2 + NO2                        
         RC(JB,238) = KRO2NO3             
C
C     Reaction (239) RTN10O2 + NO3 = RN8O2 + CO + NO2                                   
         RC(JB,239) = KRO2NO3               
C
C     Reaction (240) RTX28O2 + NO3 = TXCARB24 + HCHO + HO2 + NO2                        
         RC(JB,240) = KRO2NO3             
C
C     Reaction (241) RTX24O2 + NO3 = TXCARB22 + HO2 + NO2                               
         RC(JB,241) = KRO2NO3             
C
C     Reaction (242) RTX22O2 + NO3 = CH3COCH3 + RN13O2 + NO2                            
         RC(JB,242) = KRO2NO3             
C
C     Reaction (243) NRTX28O2 + NO3 = TXCARB24 + HCHO + NO2 + NO2                       
         RC(JB,243) = KRO2NO3            
C
C     Reaction (244) CH3O2 + HO2 = CH3OOH                                               
         RC(JB,244) = 4.10D-13*EXP(790/TC(JB))  
C
C     Reaction (245) C2H5O2 + HO2 = C2H5OOH                                             
         RC(JB,245) = 7.50D-13*EXP(700/TC(JB))  
C
C     Reaction (246) RN10O2 + HO2 = RN10OOH                                             
         RC(JB,246) = KRO2HO2*0.520           
C
C     Reaction (247) IC3H7O2 + HO2 = IC3H7OOH                                           
         RC(JB,247) = KRO2HO2*0.520           
C
C     Reaction (248) RN13O2 + HO2 = RN13OOH                                             
         RC(JB,248) = KRO2HO2*0.625           
C
C     Reaction (249) RN16O2 + HO2 = RN16OOH                                             
         RC(JB,249) = KRO2HO2*0.706           
C
C     Reaction (250) RN19O2 + HO2 = RN19OOH                                             
         RC(JB,250) = KRO2HO2*0.770           
C
C     Reaction (251) RN13AO2 + HO2 = RN13OOH                                            
         RC(JB,251) = KRO2HO2*0.625           
C
C     Reaction (252) RN16AO2 + HO2 = RN16OOH                                            
         RC(JB,252) = KRO2HO2*0.706           
C
C     Reaction (253) RA13O2 + HO2 = RA13OOH                                             
         RC(JB,253) = KRO2HO2*0.770           
C
C     Reaction (254) RA16O2 + HO2 = RA16OOH                                             
         RC(JB,254) = KRO2HO2*0.820           
C
C     Reaction (255) RA19AO2 + HO2 = RA19OOH                                            
         RC(JB,255) = KRO2HO2*0.859           
C
C     Reaction (256) RA19CO2 + HO2 = RA19OOH                                            
         RC(JB,256) = KRO2HO2*0.859           
C
C     Reaction (257) HOCH2CH2O2 + HO2 = HOC2H4OOH                                       
         RC(JB,257) = 2.03D-13*EXP(1250/TC(JB)) 
C
C     Reaction (258) RN9O2 + HO2 = RN9OOH                                               
         RC(JB,258) = KRO2HO2*0.520           
C
C     Reaction (259) RN12O2 + HO2 = RN12OOH                                             
         RC(JB,259) = KRO2HO2*0.625           
C
C     Reaction (260) RN15O2 + HO2 = RN15OOH                                             
         RC(JB,260) = KRO2HO2*0.706           
C
C     Reaction (261) RN18O2 + HO2 = RN18OOH                                             
         RC(JB,261) = KRO2HO2*0.770           
C
C     Reaction (262) RN15AO2 + HO2 = RN15OOH                                            
         RC(JB,262) = KRO2HO2*0.706           
C
C     Reaction (263) RN18AO2 + HO2 = RN18OOH                                            
         RC(JB,263) = KRO2HO2*0.770           
C
C     Reaction (264) CH3CO3 + HO2 = CH3CO3H                                             
         RC(JB,264) = KAPHO2                  
C
C     Reaction (265) C2H5CO3 + HO2 = C2H5CO3H                                           
         RC(JB,265) = KAPHO2                  
C
C     Reaction (266) HOCH2CO3 + HO2 = HOCH2CO3H                                         
         RC(JB,266) = KAPHO2                  
C
C     Reaction (267) RN8O2 + HO2 = RN8OOH                                               
         RC(JB,267) = KRO2HO2*0.520           
C
C     Reaction (268) RN11O2 + HO2 = RN11OOH                                             
         RC(JB,268) = KRO2HO2*0.625           
C
C     Reaction (269) RN14O2 + HO2 = RN14OOH                                             
         RC(JB,269) = KRO2HO2*0.706           
C
C     Reaction (270) RN17O2 + HO2 = RN17OOH                                             
         RC(JB,270) = KRO2HO2*0.770           
C
C     Reaction (271) RU14O2 + HO2 = RU14OOH                                             
         RC(JB,271) = KRO2HO2*0.770           
C
C     Reaction (272) RU12O2 + HO2 = RU12OOH                                             
         RC(JB,272) = KRO2HO2*0.706           
C
C     Reaction (273) RU10O2 + HO2 = RU10OOH                                             
         RC(JB,273) = KRO2HO2*0.625           
C
C     Reaction (274) NRN6O2 + HO2 = NRN6OOH                                             
         RC(JB,274) = KRO2HO2*0.387         
C
C     Reaction (275) NRN9O2 + HO2 = NRN9OOH                                             
         RC(JB,275) = KRO2HO2*0.520         
C
C     Reaction (276) NRN12O2 + HO2 = NRN12OOH                                           
         RC(JB,276) = KRO2HO2*0.625         
C
C     Reaction (277) NRU14O2 + HO2 = NRU14OOH                                           
         RC(JB,277) = KRO2HO2*0.770         
C
C     Reaction (278) NRU12O2 + HO2 = NRU12OOH                                           
         RC(JB,278) = KRO2HO2*0.625         
C
C     Reaction (279) RTN28O2 + HO2 = RTN28OOH                                           
         RC(JB,279) = KRO2HO2*0.914         
C
C     Reaction (280) NRTN28O2 + HO2 = NRTN28OOH                                         
         RC(JB,280) = KRO2HO2*0.914         
C
C     Reaction (281) RTN26O2 + HO2 = RTN26OOH                                           
         RC(JB,281) = KAPHO2                     
C
C     Reaction (282) RTN25O2 + HO2 = RTN25OOH                                           
         RC(JB,282) = KRO2HO2*0.890       
C
C     Reaction (283) RTN24O2 + HO2 = RTN24OOH                                           
         RC(JB,283) = KRO2HO2*0.890       
C
C     Reaction (284) RTN23O2 + HO2 = RTN23OOH                                           
         RC(JB,284) = KRO2HO2*0.890       
C
C     Reaction (285) RTN14O2 + HO2 = RTN14OOH                                           
         RC(JB,285) = KRO2HO2*0.770       
C
C     Reaction (286) RTN10O2 + HO2 = RTN10OOH                                           
         RC(JB,286) = KRO2HO2*0.706       
C
C     Reaction (287) RTX28O2 + HO2 = RTX28OOH                                           
         RC(JB,287) = KRO2HO2*0.914       
C
C     Reaction (288) RTX24O2 + HO2 = RTX24OOH                                           
         RC(JB,288) = KRO2HO2*0.890       
C
C     Reaction (289) RTX22O2 + HO2 = RTX22OOH                                           
         RC(JB,289) = KRO2HO2*0.890       
C
C     Reaction (290) NRTX28O2 + HO2 = NRTX28OOH                                         
         RC(JB,290) = KRO2HO2*0.914       
C
C     Reaction (291) CH3O2 = HCHO + HO2                                                 
         RC(JB,291) = 1.82D-13*EXP(416/TC(JB))*0.33*RO2(JB)  
C
C     Reaction (292) CH3O2 = HCHO                                                       
         RC(JB,292) = 1.82D-13*EXP(416/TC(JB))*0.335*RO2(JB) 
C
C     Reaction (293) CH3O2 = CH3OH                                                      
         RC(JB,293) = 1.82D-13*EXP(416/TC(JB))*0.335*RO2(JB) 
C
C     Reaction (294) C2H5O2 = CH3CHO + HO2                                              
         RC(JB,294) = 3.10D-13*0.6*RO2(JB)             
C
C     Reaction (295) C2H5O2 = CH3CHO                                                    
         RC(JB,295) = 3.10D-13*0.2*RO2(JB)             
C
C     Reaction (296) C2H5O2 = C2H5OH                                                    
         RC(JB,296) = 3.10D-13*0.2*RO2(JB)             
C
C     Reaction (297) RN10O2 = C2H5CHO + HO2                                             
         RC(JB,297) = 6.00D-13*0.6*RO2(JB)             
C
C     Reaction (298) RN10O2 = C2H5CHO                                                   
         RC(JB,298) = 6.00D-13*0.2*RO2(JB)             
C
C     Reaction (299) RN10O2 = NPROPOL                                                   
         RC(JB,299) = 6.00D-13*0.2*RO2(JB)             
C
C     Reaction (300) IC3H7O2 = CH3COCH3 + HO2                                           
         RC(JB,300) = 4.00D-14*0.6*RO2(JB)             
C
C     Reaction (301) IC3H7O2 = CH3COCH3                                                 
         RC(JB,301) = 4.00D-14*0.2*RO2(JB)             
C
C     Reaction (302) IC3H7O2 = IPROPOL                                                  
         RC(JB,302) = 4.00D-14*0.2*RO2(JB)             
C
C     Reaction (303) RN13O2 = CH3CHO + C2H5O2                                           
         RC(JB,303) = 2.50D-13*RO2(JB)*BR01(JB)       
C
C     Reaction (304) RN13O2 = CARB11A + HO2                                             
         RC(JB,304) = 2.50D-13*RO2(JB)*(1-BR01(JB))   
C
C     Reaction (305) RN13AO2 = RN12O2                                                   
         RC(JB,305) = 8.80D-13*RO2(JB)                 
C
C     Reaction (306) RN16AO2 = RN15O2                                                   
         RC(JB,306) = 8.80D-13*RO2(JB)                 
C
C     Reaction (307) RA13O2 = CARB3 + UDCARB8 + HO2                                     
         RC(JB,307) = 8.80D-13*RO2(JB)                 
C
C     Reaction (308) RA16O2 = CARB3 + UDCARB11 + HO2                                    
         RC(JB,308) = 8.80D-13*RO2(JB)*0.7          
C
C     Reaction (309) RA16O2 = CARB6 + UDCARB8 + HO2                                     
         RC(JB,309) = 8.80D-13*RO2(JB)*0.3          
C
C     Reaction (310) RA19AO2 = CARB3 + UDCARB14 + HO2                                   
         RC(JB,310) = 8.80D-13*RO2(JB)                 
C
C     Reaction (311) RA19CO2 = CARB3 + UDCARB14 + HO2                                   
         RC(JB,311) = 8.80D-13*RO2(JB)                 
C
C     Reaction (312) RN16O2 = RN15AO2                                                   
         RC(JB,312) = 2.50D-13*RO2(JB)                 
C
C     Reaction (313) RN19O2 = RN18AO2                                                   
         RC(JB,313) = 2.50D-13*RO2(JB)                 
C
C     Reaction (314) HOCH2CH2O2 = HCHO + HCHO + HO2                                     
         RC(JB,314) = 2.00D-12*RO2(JB)*0.776       
C
C     Reaction (315) HOCH2CH2O2 = HOCH2CHO + HO2                                        
         RC(JB,315) = 2.00D-12*RO2(JB)*0.224       
C
C     Reaction (316) RN9O2 = CH3CHO + HCHO + HO2                                        
         RC(JB,316) = 8.80D-13*RO2(JB)                 
C
C     Reaction (317) RN12O2 = CH3CHO + CH3CHO + HO2                                     
         RC(JB,317) = 8.80D-13*RO2(JB)                 
C
C     Reaction (318) RN15O2 = C2H5CHO + CH3CHO + HO2                                    
         RC(JB,318) = 8.80D-13*RO2(JB)                 
C
C     Reaction (319) RN18O2 = C2H5CHO + C2H5CHO + HO2                                   
         RC(JB,319) = 8.80D-13*RO2(JB)                 
C
C     Reaction (320) RN15AO2 = CARB13 + HO2                                             
         RC(JB,320) = 8.80D-13*RO2(JB)                 
C
C     Reaction (321) RN18AO2 = CARB16 + HO2                                             
         RC(JB,321) = 8.80D-13*RO2(JB)                 
C
C     Reaction (322) CH3CO3 = CH3O2                                                     
         RC(JB,322) = 1.00D-11*RO2(JB)                 
C
C     Reaction (323) C2H5CO3 = C2H5O2                                                   
         RC(JB,323) = 1.00D-11*RO2(JB)                 
C
C     Reaction (324) HOCH2CO3 = HCHO + HO2                                              
         RC(JB,324) = 1.00D-11*RO2(JB)                 
C
C     Reaction (325) RN8O2 = CH3CO3 + HCHO                                              
         RC(JB,325) = 1.40D-12*RO2(JB)                 
C
C     Reaction (326) RN11O2 = CH3CO3 + CH3CHO                                           
         RC(JB,326) = 1.40D-12*RO2(JB)                 
C
C     Reaction (327) RN14O2 = C2H5CO3 + CH3CHO                                          
         RC(JB,327) = 1.40D-12*RO2(JB)                 
C
C     Reaction (328) RN17O2 = RN16AO2                                                   
         RC(JB,328) = 1.40D-12*RO2(JB)                 
C
C     Reaction (329) RU14O2 = UCARB12 + HO2                                             
         RC(JB,329) = 1.71D-12*RO2(JB)*0.252        
C
C     Reaction (330) RU14O2 = UCARB10 + HCHO + HO2                                      
         RC(JB,330) = 1.71D-12*RO2(JB)*0.748        
C
C     Reaction (331) RU12O2 = CH3CO3 + HOCH2CHO                                         
         RC(JB,331) = 2.00D-12*RO2(JB)*0.7            
C
C     Reaction (332) RU12O2 = CARB7 + HOCH2CHO + HO2                                    
         RC(JB,332) = 2.00D-12*RO2(JB)*0.3            
C
C     Reaction (333) RU10O2 = CH3CO3 + HOCH2CHO                                         
         RC(JB,333) = 2.00D-12*RO2(JB)*0.5            
C
C     Reaction (334) RU10O2 = CARB6 + HCHO + HO2                                        
         RC(JB,334) = 2.00D-12*RO2(JB)*0.3            
C
C     Reaction (335) RU10O2 = CARB7 + HCHO + HO2                                        
         RC(JB,335) = 2.00D-12*RO2(JB)*0.2            
C
C     Reaction (336) NRN6O2 = HCHO + HCHO + NO2                                         
         RC(JB,336) = 6.00D-13*RO2(JB)                 
C
C     Reaction (337) NRN9O2 = CH3CHO + HCHO + NO2                                       
         RC(JB,337) = 2.30D-13*RO2(JB)                 
C
C     Reaction (338) NRN12O2 = CH3CHO + CH3CHO + NO2                                    
         RC(JB,338) = 2.50D-13*RO2(JB)                 
C
C     Reaction (339) NRU14O2 = NUCARB12 + HO2                                           
         RC(JB,339) = 1.30D-12*RO2(JB)                 
C
C     Reaction (340) NRU12O2 = NOA + CO + HO2                                           
         RC(JB,340) = 9.60D-13*RO2(JB)                 
C
C     Reaction (341) RTN28O2 = TNCARB26 + HO2                                           
         RC(JB,341) = 2.85D-13*RO2(JB)                 
C
C     Reaction (342) NRTN28O2 = TNCARB26 + NO2                                          
         RC(JB,342) = 1.00D-13*RO2(JB)                 
C
C     Reaction (343) RTN26O2 = RTN25O2                                                  
         RC(JB,343) = 1.00D-11*RO2(JB)                   
C
C     Reaction (344) RTN25O2 = RTN24O2                                                  
         RC(JB,344) = 1.30D-12*RO2(JB)           
C
C     Reaction (345) RTN24O2 = RTN23O2                                                  
         RC(JB,345) = 6.70D-15*RO2(JB)             
C
C     Reaction (346) RTN23O2 = CH3COCH3 + RTN14O2                                       
         RC(JB,346) = 6.70D-15*RO2(JB)            
C
C     Reaction (347) RTN14O2 = HCHO + TNCARB10 + HO2                                    
         RC(JB,347) = 8.80D-13*RO2(JB)        
C
C     Reaction (348) RTN10O2 = RN8O2 + CO                                               
         RC(JB,348) = 2.00D-12*RO2(JB)        
C
C     Reaction (349) RTX28O2 = TXCARB24 + HCHO + HO2                                    
         RC(JB,349) = 2.00D-12*RO2(JB)       
C
C     Reaction (350) RTX24O2 = TXCARB22 + HO2                                           
         RC(JB,350) = 2.50D-13*RO2(JB)       
C
C     Reaction (351) RTX22O2 = CH3COCH3 + RN13O2                                        
         RC(JB,351) = 2.50D-13*RO2(JB)       
C
C     Reaction (352) NRTX28O2 = TXCARB24 + HCHO + NO2                                   
         RC(JB,352) = 9.20D-14*RO2(JB)       
C
C     Reaction (353) OH + CARB14 = RN14O2                                               
         RC(JB,353) = 1.87D-11       
C
C     Reaction (354) OH + CARB17 = RN17O2                                               
         RC(JB,354) = 4.36D-12       
C
C     Reaction (355) OH + CARB11A = RN11O2                                              
         RC(JB,355) = 3.24D-18*TC(JB)**2*EXP(414/TC(JB))
C
C     Reaction (356) OH + CARB7 = CARB6 + HO2                                           
         RC(JB,356) = 3.00D-12       
C
C     Reaction (357) OH + CARB10 = CARB9 + HO2                                          
         RC(JB,357) = 5.86D-12       
C
C     Reaction (358) OH + CARB13 = RN13O2                                               
         RC(JB,358) = 1.65D-11       
C
C     Reaction (359) OH + CARB16 = RN16O2                                               
         RC(JB,359) = 1.25D-11       
C
C     Reaction (360) OH + UCARB10 = RU10O2                                              
         RC(JB,360) = 2.50D-11       
C
C     Reaction (361) NO3 + UCARB10 = RU10O2 + HNO3                                      
         RC(JB,361) = KNO3AL       
C
C     Reaction (362) O3 + UCARB10 = HCHO + CH3CO3 + CO + OH                             
         RC(JB,362) = 8.5D-16*EXP(-1520/TC(JB))*0.44       
C
C     Reaction (363) O3 + UCARB10 = HCHO + CARB6 + H2O2                                 
         RC(JB,363) = 8.5D-16*EXP(-1520/TC(JB))*0.10       
C
C     Reaction (364) OH + HOCH2CHO = HOCH2CO3                                           
         RC(JB,364) = 1.00D-11       
C
C     Reaction (365) NO3 + HOCH2CHO = HOCH2CO3 + HNO3                                   
         RC(JB,365) = KNO3AL        
C
C     Reaction (366) OH + CARB3 = CO + CO + HO2                                         
         RC(JB,366) = 1.14D-11       
C
C     Reaction (367) OH + CARB6 = CH3CO3 + CO                                           
         RC(JB,367) = 1.72D-11       
C
C     Reaction (368) OH + CARB9 = RN9O2                                                 
         RC(JB,368) = 2.40D-13       
C
C     Reaction (369) OH + CARB12 = RN12O2                                               
         RC(JB,369) = 1.38D-12       
C
C     Reaction (370) OH + CARB15 = RN15O2                                               
         RC(JB,370) = 4.81D-12       
C
C     Reaction (371) OH + CCARB12 = RN12O2                                              
         RC(JB,371) = 4.79D-12       
C
C     Reaction (372) OH + UCARB12 = RU12O2                                              
         RC(JB,372) = 4.52D-11            
C
C     Reaction (373) NO3 + UCARB12 = RU12O2 + HNO3                                      
         RC(JB,373) = KNO3AL*4.25    
C
C     Reaction (374) O3 + UCARB12 = HOCH2CHO + CH3CO3 + CO + OH                         
         RC(JB,374) = 2.40D-17*0.45   
C
C     Reaction (375) O3 + UCARB12 = CARB3 + CARB6 + HO2+OH                             
         RC(JB,375) = 2.40D-17*0.45   
C
C     Reaction (376) OH + NUCARB12 = NRU12O2                                            
         RC(JB,376) = 4.16D-11            
C
C     Reaction (377) OH + NOA = CARB6 + NO2                                             
         RC(JB,377) = 1.30D-13            
C
C     Reaction (378) OH + UDCARB8 = C2H5O2                                              
         RC(JB,378) = 5.20D-11*0.50        
C
C     Reaction (379) OH + UDCARB8 = ANHY + HO2                                          
         RC(JB,379) = 5.20D-11*0.50        
C
C     Reaction (380) OH + UDCARB11 = RN10O2                                             
         RC(JB,380) = 5.58D-11*0.55     
C
C     Reaction (381) OH + UDCARB11 = ANHY + CH3O2                                       
         RC(JB,381) = 5.58D-11*0.45     
C
C     Reaction (382) OH + UDCARB14 = RN13O2                                             
         RC(JB,382) = 7.00D-11*0.55     
C
C     Reaction (383) OH + UDCARB14 = ANHY + C2H5O2                                      
         RC(JB,383) = 7.00D-11*0.45     
C
C     Reaction (384) OH + TNCARB26 = RTN26O2                                            
         RC(JB,384) = 4.20D-11           
C
C     Reaction (385) OH + TNCARB15 = RN15AO2                                            
         RC(JB,385) = 1.00D-12           
C
C     Reaction (386) OH + TNCARB10 = RTN10O2                                            
         RC(JB,386) = 1.00D-10           
C
C     Reaction (387) NO3 + TNCARB26 = RTN26O2 + HNO3                                    
         RC(JB,387) = 3.80D-14            
C
C     Reaction (388) NO3 + TNCARB10 = RTN10O2 + HNO3                                    
         RC(JB,388) = KNO3AL*5.5      
C
C     Reaction (389) OH + RCOOH25 = RTN25O2                                             
         RC(JB,389) = 6.65D-12            
C
C     Reaction (390) OH + TXCARB24 = RTX24O2                                            
         RC(JB,390) = 1.55D-11           
C
C     Reaction (391) OH + TXCARB22 = RTX22O2                                            
         RC(JB,391) = 4.55D-12           
C
C     Reaction (392) OH + CH3NO3 = HCHO + NO2                                           
         RC(JB,392) = 1.00D-14*EXP(1060/TC(JB))      
C
C     Reaction (393) OH + C2H5NO3 = CH3CHO + NO2                                        
         RC(JB,393) = 4.40D-14*EXP(720/TC(JB))       
C
C     Reaction (394) OH + RN10NO3 = C2H5CHO + NO2                                       
         RC(JB,394) = 7.30D-13                     
C
C     Reaction (395) OH + IC3H7NO3 = CH3COCH3 + NO2                                     
         RC(JB,395) = 4.90D-13                     
C
C     Reaction (396) OH + RN13NO3 = CARB11A + NO2                                       
         RC(JB,396) = 9.20D-13                     
C
C     Reaction (397) OH + RN16NO3 = CARB14 + NO2                                        
         RC(JB,397) = 1.85D-12                     
C
C     Reaction (398) OH + RN19NO3 = CARB17 + NO2                                        
         RC(JB,398) = 3.02D-12                     
C
C     Reaction (399) OH + HOC2H4NO3 = HOCH2CHO + NO2                                    
         RC(JB,399) = 1.09D-12               
C
C     Reaction (400) OH + RN9NO3 = CARB7 + NO2                                          
         RC(JB,400) = 1.31D-12               
C
C     Reaction (401) OH + RN12NO3 = CARB10 + NO2                                        
         RC(JB,401) = 1.79D-12               
C
C     Reaction (402) OH + RN15NO3 = CARB13 + NO2                                        
         RC(JB,402) = 1.03D-11               
C
C     Reaction (403) OH + RN18NO3 = CARB16 + NO2                                        
         RC(JB,403) = 1.34D-11               
C
C     Reaction (404) OH + RU14NO3 = UCARB12 + NO2                                       
         RC(JB,404) = 5.55D-11               
C
C     Reaction (405) OH + RA13NO3 = CARB3 + UDCARB8 + NO2                               
         RC(JB,405) = 7.30D-11               
C
C     Reaction (406) OH + RA16NO3 = CARB3 + UDCARB11 + NO2                              
         RC(JB,406) = 7.16D-11               
C
C     Reaction (407) OH + RA19NO3 = CARB6 + UDCARB11 + NO2                              
         RC(JB,407) = 8.31D-11               
C
C     Reaction (408) OH + RTN28NO3 = TNCARB26 + NO2                                     
         RC(JB,408) = 4.35D-12               
C
C     Reaction (409) OH + RTN25NO3 = CH3COCH3 + TNCARB15 + NO2                          
         RC(JB,409) = 2.88D-12               
C
C     Reaction (410) OH + RTX28NO3 = TXCARB24 + HCHO + NO2                              
         RC(JB,410) = 3.53D-12                  
C
C     Reaction (411) OH + RTX24NO3 = TXCARB22 + NO2                                     
         RC(JB,411) = 6.48D-12                  
C
C     Reaction (412) OH + RTX22NO3 = CH3COCH3 + CCARB12 + NO2                           
         RC(JB,412) = 4.74D-12                  
C
C     Reaction (413) OH + AROH14 = RAROH14                                              
         RC(JB,413) = 2.63D-11             
C
C     Reaction (414) NO3 + AROH14 = RAROH14 + HNO3                                      
         RC(JB,414) = 3.78D-12               
C
C     Reaction (415) RAROH14 + NO2 = ARNOH14                                            
         RC(JB,415) = 2.08D-12               
C
C     Reaction (416) OH + ARNOH14 = CARB13 + NO2                                        
         RC(JB,416) = 9.00D-13               
C
C     Reaction (417) NO3 + ARNOH14 = CARB13 + NO2 + HNO3                                
         RC(JB,417) = 9.00D-14               
C
C     Reaction (418) OH + AROH17 = RAROH17                                              
         RC(JB,418) = 4.65D-11               
C
C     Reaction (419) NO3 + AROH17 = RAROH17 + HNO3                                      
         RC(JB,419) = 1.25D-11               
C
C     Reaction (420) RAROH17 + NO2 = ARNOH17                                            
         RC(JB,420) = 2.08D-12               
C
C     Reaction (421) OH + ARNOH17 = CARB16 + NO2                                        
         RC(JB,421) = 1.53D-12               
C
C     Reaction (422) NO3 + ARNOH17 = CARB16 + NO2 + HNO3                                
         RC(JB,422) = 3.13D-13               
C
C     Reaction (423) OH + CH3OOH = CH3O2                                                
         RC(JB,423) = 1.90D-11*EXP(190/TC(JB))       
C
C     Reaction (424) OH + CH3OOH = HCHO + OH                                            
         RC(JB,424) = 1.00D-11*EXP(190/TC(JB))       
C
C     Reaction (425) OH + C2H5OOH = CH3CHO + OH                                         
         RC(JB,425) = 1.36D-11               
C
C     Reaction (426) OH + RN10OOH = C2H5CHO + OH                                        
         RC(JB,426) = 1.89D-11               
C
C     Reaction (427) OH + IC3H7OOH = CH3COCH3 + OH                                      
         RC(JB,427) = 2.78D-11               
C
C     Reaction (428) OH + RN13OOH = CARB11A + OH                                        
         RC(JB,428) = 3.57D-11               
C
C     Reaction (429) OH + RN16OOH = CARB14 + OH                                         
         RC(JB,429) = 4.21D-11               
C
C     Reaction (430) OH + RN19OOH = CARB17 + OH                                         
         RC(JB,430) = 4.71D-11               
C
C     Reaction (431) OH + CH3CO3H = CH3CO3                                              
         RC(JB,431) = 3.70D-12                     
C
C     Reaction (432) OH + C2H5CO3H = C2H5CO3                                            
         RC(JB,432) = 4.42D-12                     
C
C     Reaction (433) OH + HOCH2CO3H = HOCH2CO3                                          
         RC(JB,433) = 6.19D-12                     
C
C     Reaction (434) OH + RN8OOH = CARB6 + OH                                           
         RC(JB,434) = 4.42D-12                     
C
C     Reaction (435) OH + RN11OOH = CARB9 + OH                                          
         RC(JB,435) = 2.50D-11                     
C
C     Reaction (436) OH + RN14OOH = CARB12 + OH                                         
         RC(JB,436) = 3.20D-11                     
C
C     Reaction (437) OH + RN17OOH = CARB15 + OH                                         
         RC(JB,437) = 3.35D-11                     
C
C     Reaction (438) OH + RU14OOH = UCARB12 + OH                                        
         RC(JB,438) = 7.51D-11                     
C
C     Reaction (439) OH + RU12OOH = RU12O2                                              
         RC(JB,439) = 3.00D-11                     
C
C     Reaction (440) OH + RU10OOH = RU10O2                                              
         RC(JB,440) = 3.00D-11                     
C
C     Reaction (441) OH + NRU14OOH = NUCARB12 + OH                                      
         RC(JB,441) = 1.03D-10                     
C
C     Reaction (442) OH + NRU12OOH = NOA + CO + OH                                      
         RC(JB,442) = 2.65D-11                     
C
C     Reaction (443) OH + HOC2H4OOH = HOCH2CHO + OH                                     
         RC(JB,443) = 2.13D-11               
C
C     Reaction (444) OH + RN9OOH = CARB7 + OH                                           
         RC(JB,444) = 2.50D-11               
C
C     Reaction (445) OH + RN12OOH = CARB10 + OH                                         
         RC(JB,445) = 3.25D-11               
C
C     Reaction (446) OH + RN15OOH = CARB13 + OH                                         
         RC(JB,446) = 3.74D-11               
C
C     Reaction (447) OH + RN18OOH = CARB16 + OH                                         
         RC(JB,447) = 3.83D-11               
C
C     Reaction (448) OH + NRN6OOH = HCHO + HCHO + NO2 + OH                              
         RC(JB,448) = 5.22D-12               
C
C     Reaction (449) OH + NRN9OOH = CH3CHO + HCHO + NO2 + OH                            
         RC(JB,449) = 6.50D-12               
C
C     Reaction (450) OH + NRN12OOH = CH3CHO + CH3CHO + NO2 + OH                         
         RC(JB,450) = 7.15D-12               
C
C     Reaction (451) OH + RA13OOH = CARB3 + UDCARB8 + OH                                
         RC(JB,451) = 9.77D-11               
C
C     Reaction (452) OH + RA16OOH = CARB3 + UDCARB11 + OH                               
         RC(JB,452) = 9.64D-11               
C
C     Reaction (453) OH + RA19OOH = CARB6 + UDCARB11 + OH                               
         RC(JB,453) = 1.12D-10               
C
C     Reaction (454) OH + RTN28OOH = TNCARB26 + OH                                      
         RC(JB,454) = 2.38D-11               
C
C     Reaction (455) OH + RTN26OOH = RTN26O2                                            
         RC(JB,455) = 1.20D-11               
C
C     Reaction (456) OH + NRTN28OOH = TNCARB26 + NO2 + OH                               
         RC(JB,456) = 9.50D-12               
C
C     Reaction (457) OH + RTN25OOH = RTN25O2                                            
         RC(JB,457) = 1.66D-11               
C
C     Reaction (458) OH + RTN24OOH = RTN24O2                                            
         RC(JB,458) = 1.05D-11               
C
C     Reaction (459) OH + RTN23OOH = RTN23O2                                            
         RC(JB,459) = 2.05D-11               
C
C     Reaction (460) OH + RTN14OOH = RTN14O2                                            
         RC(JB,460) = 8.69D-11               
C
C     Reaction (461) OH + RTN10OOH = RTN10O2                                            
         RC(JB,461) = 4.23D-12               
C
C     Reaction (462) OH + RTX28OOH = RTX28O2                                            
         RC(JB,462) = 2.00D-11               
C
C     Reaction (463) OH + RTX24OOH = TXCARB22 + OH                                      
         RC(JB,463) = 8.59D-11               
C
C     Reaction (464) OH + RTX22OOH = CH3COCH3 + CCARB12 + OH                            
         RC(JB,464) = 7.50D-11               
C
C     Reaction (465) OH + NRTX28OOH = NRTX28O2                                          
         RC(JB,465) = 9.58D-12               
C
C     Reaction (466) OH + ANHY = HOCH2CH2O2                                             
         RC(JB,466) = 1.50D-12        
C
C     Reaction (467) CH3CO3 + NO2 = PAN                                                 
         RC(JB,467) = KFPAN                        
C
C     Reaction (468) PAN = CH3CO3 + NO2                                                 
         RC(JB,468) = KBPAN                        
C
C     Reaction (469) C2H5CO3 + NO2 = PPN                                                
         RC(JB,469) = KFPAN                        
C
C     Reaction (470) PPN = C2H5CO3 + NO2                                                
         RC(JB,470) = KBPAN                        
C
C     Reaction (471) HOCH2CO3 + NO2 = PHAN                                              
         RC(JB,471) = KFPAN                        
C
C     Reaction (472) PHAN = HOCH2CO3 + NO2                                              
         RC(JB,472) = KBPAN                        
C
C     Reaction (473) OH + PAN = HCHO + CO + NO2                                         
         RC(JB,473) = 9.50D-13*EXP(-650/TC(JB))      
C
C     Reaction (474) OH + PPN = CH3CHO + CO + NO2                                       
         RC(JB,474) = 1.27D-12                       
C
C     Reaction (475) OH + PHAN = HCHO + CO + NO2                                        
         RC(JB,475) = 1.12D-12                       
C
C     Reaction (476) RU12O2 + NO2 = RU12PAN                                             
         RC(JB,476) = KFPAN*0.061             
C
C     Reaction (477) RU12PAN = RU12O2 + NO2                                             
         RC(JB,477) = KBPAN                   
C
C     Reaction (478) RU10O2 + NO2 = MPAN                                                
         RC(JB,478) = KFPAN*0.041             
C
C     Reaction (479) MPAN = RU10O2 + NO2                                                
         RC(JB,479) = KBPAN                  
C
C     Reaction (480) OH + MPAN = CARB7 + CO + NO2                                       
         RC(JB,480) = 3.60D-12 
C
C     Reaction (481) OH + RU12PAN = UCARB10 + NO2                                       
         RC(JB,481) = 2.52D-11 
C
C     Reaction (482) RTN26O2 + NO2 = RTN26PAN                                           
         RC(JB,482) = KFPAN*0.722      
C
C     Reaction (483) RTN26PAN = RTN26O2 + NO2                                           
         RC(JB,483) = KBPAN                   
C
C     Reaction (484) OH + RTN26PAN = CH3COCH3 + CARB16 + NO2                            
         RC(JB,484) = 3.66D-12  
C
C     Reaction (485) RTN28NO3 = P2604                                                   
         RC(JB,485) = KIN  		
C
C     Reaction (486) P2604 = RTN28NO3                                                   
         RC(JB,486) = KOUT2604 	
C
C     Reaction (487) RTX28NO3 = P4608                                                   
         RC(JB,487) = KIN 		
C
C     Reaction (488) P4608 = RTX28NO3                                                   
         RC(JB,488) = KOUT4608 	
C
C     Reaction (489) RCOOH25 = P2631                                                    
         RC(JB,489) = KIN  		
C
C     Reaction (490) P2631 = RCOOH25                                                    
         RC(JB,490) = KOUT2631 	
C
C     Reaction (491) RTN24OOH = P2635                                                   
         RC(JB,491) = KIN  		
C
C     Reaction (492) P2635 = RTN24OOH                                                   
         RC(JB,492) = KOUT2635 	
C
C     Reaction (493) RTX28OOH = P4610                                                   
         RC(JB,493) = KIN  		
C
C     Reaction (494) P4610 = RTX28OOH                                                   
         RC(JB,494) = KOUT4610 	
C
C     Reaction (495) RTN28OOH = P2605                                                   
         RC(JB,495) = KIN  		
C
C     Reaction (496) P2605 = RTN28OOH                                                   
         RC(JB,496) = KOUT2605 	
C
C     Reaction (497) RTN26OOH = P2630                                                   
         RC(JB,497) = KIN  		
C     Reaction (498) P2630 = RTN26OOH                                                   
         RC(JB,498) = KOUT2630 	
C     Reaction (499) RTN26PAN = P2629                                                   
         RC(JB,499) = KIN  		
C     Reaction (500) P2629 = RTN26PAN                                                   
         RC(JB,500) = KOUT2629 	
C     Reaction (501) RTN25OOH = P2632                                                   
         RC(JB,501) = KIN 		
C     Reaction (502) P2632 = RTN25OOH                                                   
         RC(JB,502) = KOUT2632 	
C     Reaction (503) RTN23OOH = P2637                                                   
         RC(JB,503) = KIN  		
C     Reaction (504) P2637 = RTN23OOH                                                   
         RC(JB,504) = KOUT2637 	
C     Reaction (505) ARNOH14 = P3612                                                    
         RC(JB,505) = KIN  		
C     Reaction (506) P3612 = ARNOH14                                                    
         RC(JB,506) = KOUT3612 	
C     Reaction (507) ARNOH17 = P3613                                                    
         RC(JB,507) = KIN 		
C     Reaction (508) P3613 = ARNOH17                                                    
         RC(JB,508) = KOUT3613 	
C     Reaction (509) ANHY = P3442                                                       
         RC(JB,509) = KIN  		
C     Reaction (510) P3442 = ANHY                                                       
         RC(JB,510) = KOUT3442 	
C     Reaction (511) RU12OOH = P2007                                                       
         RC(JB,511) = KIN 	
C     Reaction (512) P2007 = RU12OOH                                                       
         RC(JB,512) = KOUT2007
C
C     Reaction (513) : OH + DMS  = CH3SO +HCHO
         RC(JB,513) = 9.6E-12*EXP(-234/TC(JB))
C
C     Reaction (514) : OH + DMS = DMSO + HO2
        RC(JB,514)=(1.7D-42*EXP(7810/TC(JB))*O2(JB))/
     &    (1.+(5.5D-31*EXP(7460/TC(JB))*O2(JB)))
C
C     Reaction (515) : NO3 + DMS = CH3SO + HCHO + HNO3
        RC(JB,515) = 1.9E-13*EXP(520/TC(JB))
C     Reaction (516)  : OH + DMSO =  MSIA + CH3O2
        RC(JB,516) = 5.8E-11
C     Reaction (517)  : CH3SO + O3 = CH3SO2
        RC(JB,517) = 6.0E-13
C     Reaction (518) : CH3SO + NO2 = CH3SO2 + NO
        RC(JB,518) = 8.0E-12
C     Reaction (519) : OH + MSIA = CH3SO2
        RC(JB,519) = 1.6E-11
C     Reaction (520) : CH3SO2 + O3 = CH3SO3
        RC(JB,520) = 3.0E-13
C     Reaction (521) : CH3SO2 + NO2 = CH3SO3 + NO
        RC(JB,521) = 4.0E-12
C     Reaction (522) : CH3SO2 + O2 = CH3O2 + SO2
        RC(JB,522) = 5.0E+13*EXP(-(1.0+(8656/TC(JB))))
C     Reaction (523) : CH3SO3 + HO2 = MSA
        RC(JB,523) = 5.0E-11
C     Reaction (524) : CH3SO3 + O2 = CH3O2 + SA
        RC(JB,524) = 5.0E+13*EXP(-(1.0+(11071/TC(JB))))
C     Reaction (525) : CH3SO3 + HCHO = MSA + CO + HO2
        RC(JB,525) = 1.6E-15
C     Reaction (526): OH + CH3BR = 
        RC(JB,526) = 1.7E-12*EXP(-1215/TC(JB))
C     Reaction (530) O3 + C2H4 = HCHO + SCIE                                           
         RC(JB,530) = 9.14E-15*EXP(-2580/TC(JB))*0.37  
C     Reaction (531) O3 + C3H6 = HCHO + SCIPA                                        
         RC(JB,531) = 5.51E-15*EXP(-1878/TC(JB))*0.08  
C     Reaction (532) O3 + C3H6 = HCHO + SCIPS                                         
         RC(JB,532) = 5.51E-15*EXP(-1878/TC(JB))*0.08  
C     Reaction (533) O3 + TBUT2ENE = CH3CHO + SCIPS                                   
         RC(JB,533) = 6.64E-15*EXP(-1059/TC(JB))*0.105 
C     Reaction (534) O3 + C5H8 = CH3CO3+HCHO+HCHO+CO+OH                                        
         RC(JB,534) = 1.03E-14*EXP(-1995/TC(JB))*0.105 
C     Reaction (535) O3 + C5H8 = HCHO+SCIMAA                                      
         RC(JB,535) = 1.03E-14*EXP(-1995/TC(JB))*0.04 
C     Reaction (536) O3 + C5H8 = HCHO+SCIMAS                                      
         RC(JB,536) = 1.03E-14*EXP(-1995/TC(JB))*0.01 
C     Reaction (537) O3 + C5H8 = HCHO+CH3O2+HCHO+CO+HO2                                        
         RC(JB,537) = 1.03E-14*EXP(-1995/TC(JB))*0.135 
C     Reaction (538) O3 + C5H8 = HCHO+SCIMVA                                      
         RC(JB,538) = 1.03E-14*EXP(-1995/TC(JB))*0.07 
C     Reaction (539) O3 + C5H8 = HCHO+SCIMVS                                      
         RC(JB,539) = 1.03E-14*EXP(-1995/TC(JB))*0.14 
C     Reaction (540) APINENE + O3 = SCIPAS                                             
         RC(JB,540) = 8.05E-16*EXP(-640/TC(JB))*0.05 	
C     Reaction (541) APINENE + O3 = SCIIPA                                             
         RC(JB,541) = 8.05E-16*EXP(-640/TC(JB))*0.05 
C     Reaction (542) APINENE + O3 = SCIIPS                                             
         RC(JB,542) = 8.05E-16*EXP(-640/TC(JB))*0.05 	
C     Reaction (543) BPINENE + O3 =  RTX24O2 + SCIE                                       
         RC(JB,543) = 1.35E-15*EXP(-1270/TC(JB))*0.17 	 
C     Reaction (544) BPINENE + O3 =  HCHO+SCIBPS                                      
         RC(JB,544) = 1.35E-15*EXP(-1270/TC(JB))*0.02 
C     Reaction (545) O3 + UCARB10 = HCHO + SCIMGA                            
         RC(JB,545) = 8.5E-16*EXP(-1520/TC(JB))*0.01       
C     Reaction (546) O3 + UCARB10 = HCHO + SCIMGS                                 
         RC(JB,546) = 8.5E-16*EXP(-1520/TC(JB))*0.01 
C     Reaction (547) O3 + UCARB10 = CARB6 + SCIE                                 
         RC(JB,547) = 8.5E-16*EXP(-1520/TC(JB))*0.32  
C     Reaction (548) O3 + UCARB12 = HOCH2CHO + SCIMGA                        
         RC(JB,548) = 2.40E-17*0.025  	
C     Reaction (549) O3 + UCARB12 = HOCH2CHO + SCIMGS                        
         RC(JB,549) = 2.40E-17*0.025  	
C     Reaction (550) O3 + UCARB10 = HCHO + SCIGAA                        
         RC(JB,550) = 8.5E-16*EXP(-1520/TC(JB))*0.06 	
C     Reaction (551) O3 + UCARB10 = HCHO + SCIGAS                        
         RC(JB,551) = 8.5E-16*EXP(-1520/TC(JB))*0.06
C     Reaction (552) SCIE + water dimer = HCOOH  	 
         RC(JB,552) =  3.92D-16*EXP(2930/TC(JB))*KDIMER
C     Reaction (553) SCIPA + H2O = CH3COOH  	 
         RC(JB,553) =  1.3D-14
C     Reaction (554) SCIPA + water dimer = CH3COOH                                                    
         RC(JB,554) = 5.2E-20*EXP(6124/TC(JB))*KDIMER  			 
C     Reaction (555) SCIPS  = OH+HCHO+OH+CO                                                    
         RC(JB,555) = 8.352E-5*EXP(0.0486*TC(JB))   
C     Reaction (556) SCIMAA + H2O = MACOOH                                                    
         RC(JB,556) = 2.13E-19*(TC(JB))**1.74*EXP(-929/TC(JB))
C     Reaction (557) SCIMAA + water dimer = MACOOH                                                    
         RC(JB,557) = 2.24E-19*(TC(JB))**1.73*EXP(1313/TC(JB))*KDIMER
C     Reaction (558) SCIMAA = P  	 
         RC(JB,558) =  5.93E+8*(TC(JB))**1.46*EXP(-7832/TC(JB))	 
C     Reaction (559) SCIMAS = P  	 
         RC(JB,559) =  1.59E+11*(TC(JB))**0.44*EXP(-6102/TC(JB))	
C     Reaction (560) SCIMVA = CH3CO3+HCHO+CO+OH  	 
         RC(JB,560) =  1.94E+12*EXP(-6150/TC(JB))	
C     Reaction (561) SCIMVS = P+OH  	 
         RC(JB,561) = 0.58E-6*EXP(0.0576*TC(JB))
C     Reaction (562) SCIPAA + H2O = P  	 
         RC(JB,562) =  1.3E-14
C     Reaction (563) SCIPAA + water dimer = P 	 
         RC(JB,563) =  5.2E-20*EXP(6124/TC(JB))*KDIMER	 
C     Reaction (564) SCIPAS  = P                                
         RC(JB,564) = 8.352E-5*EXP(0.0486*TC(JB))   
C     Reaction (565) SCIIPA  = P                                
         RC(JB,565) = 8.352E-5*EXP(0.0486*TC(JB))   
C     Reaction (566) SCIIPS  = P                                
         RC(JB,566) = 1.682E-6*EXP(0.0593*TC(JB)) 
C     Reaction (567) SCIBPA  = P                                
         RC(JB,567) = 1.9E+9*(TC(JB))**1.33*EXP(-8425/TC(JB))  
C     Reaction (568) SCIBPA + H2O = P  	 
         RC(JB,568) =  8.46E-23*(TC(JB))**2.64*EXP(121/TC(JB))
C     Reaction (569) SCIBPS  = P                                
         RC(JB,569) = 8.352E-5*EXP(0.0486*TC(JB)) 
C     Reaction (570) SCIMGA = P  	 
         RC(JB,570) =  8.352E-5*EXP(0.0486*TC(JB))
C     Reaction (571) SCIMGS + water = P  	 
         RC(JB,571) =  7.81E-20*(TC(JB))**1.68*EXP(757/TC(JB))	 
C     Reaction (572) SCIMGS  = P                                
         RC(JB,572) = 2.76E-10*(TC(JB))**0.78*EXP(-5162/TC(JB)) 
C     Reaction (573) SCIGAA + H2O = P  	 
         RC(JB,573) =  1.3E-14
C     Reaction (574) SCIGAA + water dimer = P  	 
         RC(JB,574) =  5.23E-20*EXP(6124/TC(JB))*KDIMER	 
C     Reaction (575) SCIGAS +water = P                                
         RC(JB,575) = 2.18E-19*(TC(JB))**1.43*EXP(1268/TC(JB))
C     Reaction (576) SCIGAS +water dimer = P                                
         RC(JB,576) = 2.26E-19*(TC(JB))**1.43*EXP(3279/TC(JB))*KDIMER
C     Reaction (577) SCIMGS +water dimer = P                                
         RC(JB,577) = 8.07E-20*(TC(JB))**1.67*EXP(2828/TC(JB))*KDIMER
C     Reaction (578): CH3COCH3 + SCI = P
        RC(JB,578) =   1.45E-21*(TC(JB))**2.0*EXP(2407/TC(JB))
C     Reaction (579) HOC2H4OOH + AP = APHOC2H4OOH  	 
         RC(JB,579) =  2E-12			  	 
         RC(JB,580) =  2E-12		 
         RC(JB,581) =  2E-12	 	 
         RC(JB,582) =  2E-12		 
         RC(JB,583) =  2E-12	 	 
         RC(JB,584) =  2E-12		 
         RC(JB,585) =  2E-12	 	 
         RC(JB,586) =  2E-12	 	 
         RC(JB,587) =  2E-12		 
         RC(JB,588) =  2E-12		 
         RC(JB,589) =  2E-12		 
         RC(JB,590) =  2E-12		 
         RC(JB,591) =  2E-12		 
         RC(JB,592) =  2E-12	 	 
         RC(JB,593) =  2E-12	 	 
         RC(JB,594) =  2E-12		 
         RC(JB,595) =  2E-12	 	 
         RC(JB,596) =  2E-12		 
         RC(JB,597) =  2E-12		 
         RC(JB,598) =  2E-12		 
         RC(JB,599) =  2E-12		 
         RC(JB,600) =  2E-12		 
         RC(JB,601) =  2E-12		 
         RC(JB,602) =  2E-12	
         RC(JB,603) =  2E-12	
         RC(JB,604) =  2E-12	
         RC(JB,605) =  2E-12	
         RC(JB,606) =  2E-12	
         RC(JB,607) =  2E-12	
         RC(JB,608) =  2E-12	
         RC(JB,609) =  2E-12	
         RC(JB,610) =  2E-12	
         RC(JB,611) =  2E-12	
         RC(JB,612) =  2E-12	
         RC(JB,613) =  2E-12	
         RC(JB,614) =  2E-12
         RC(JB,615) =  2E-12
         RC(JB,616) =  2E-12
         RC(JB,617) =  2E-12
         RC(JB,618) =  2E-12
         RC(JB,619) =  2E-12
         RC(JB,620) =  2E-12
         RC(JB,621) =  2E-12
         RC(JB,622) =  2E-12
         RC(JB,623) =  2E-12
         RC(JB,624) =  2E-12	
         RC(JB,625) =  2E-12
         RC(JB,626) = KIN 	                                                      
         RC(JB,627) = KOUT1001
         RC(JB,628) = KIN 	                                                      
         RC(JB,629) = KOUT1002
         RC(JB,630) = KIN 	                                                      
         RC(JB,631) = KOUT1003
         RC(JB,632) = KIN 	                                                      
         RC(JB,633) = KOUT1004
         RC(JB,634) = KIN 	                                                      
         RC(JB,635) = KOUT1005
         RC(JB,636) = KIN 	                                                      
         RC(JB,637) = KOUT1006
         RC(JB,638) = KIN 	                                                      
         RC(JB,639) = KOUT1007
         RC(JB,640) = KIN 	                                                      
         RC(JB,641) = KOUT1008
         RC(JB,642) = KIN 	                                                      
         RC(JB,643) = KOUT1009
         RC(JB,644) = KIN 	                                                      
         RC(JB,645) = KOUT1010
         RC(JB,646) = KIN 	                                                      
         RC(JB,647) = KOUT1011
         RC(JB,648) = KIN 	                                                      
         RC(JB,649) = KOUT1012
         RC(JB,650) = KIN 	                                                      
         RC(JB,651) = KOUT1013
         RC(JB,652) = KIN 	                                                      
         RC(JB,653) = KOUT1014
         RC(JB,654) = KIN 	                                                      
         RC(JB,655) = KOUT1015
         RC(JB,656) = KIN 	                                                      
         RC(JB,657) = KOUT1016
         RC(JB,658) = KIN 	                                                      
         RC(JB,659) = KOUT1017
         RC(JB,660) = KIN 	                                                      
         RC(JB,661) = KOUT1018
         RC(JB,662) = KIN 	                                                      
         RC(JB,663) = KOUT1019
         RC(JB,664) = KIN 	                                                      
         RC(JB,665) = KOUT1020
         RC(JB,666) = KIN 	                                                      
         RC(JB,667) = KOUT1021
         RC(JB,668) = KIN 	                                                      
         RC(JB,669) = KOUT1022
         RC(JB,670) = KIN 	                                                      
         RC(JB,671) = KOUT1023
         RC(JB,672) = KIN 	                                                      
         RC(JB,673) = KOUT1024
         RC(JB,674) = KIN 	                                                      
         RC(JB,675) = KOUT1025
         RC(JB,676) = KIN 	                                                      
         RC(JB,677) = KOUT1026
         RC(JB,678) = KIN 	                                                      
         RC(JB,679) = KOUT1027
         RC(JB,680) = KIN 	                                                      
         RC(JB,681) = KOUT1028
         RC(JB,682) = KIN 	                                                      
         RC(JB,683) = KOUT1029
         RC(JB,684) = KIN 	                                                      
         RC(JB,685) = KOUT1030
         RC(JB,686) = KIN 	                                                      
         RC(JB,687) = KOUT1031
         RC(JB,688) = KIN 	                                                      
         RC(JB,689) = KOUT1032
         RC(JB,690) = KIN 	                                                      
         RC(JB,691) = KOUT1033
         RC(JB,692) = KIN 	                                                      
         RC(JB,693) = KOUT1034
         RC(JB,694) = KIN 	                                                      
         RC(JB,695) = KOUT1035
         RC(JB,696) = KIN 	                                                      
         RC(JB,697) = KOUT1036
         RC(JB,698) = KIN 	                                                      
         RC(JB,699) = KOUT1037
         RC(JB,700) = KIN 	                                                      
         RC(JB,701) = KOUT1038
         RC(JB,702) = KIN 	                                                      
         RC(JB,703) = KOUT1039
         RC(JB,704) = KIN 	                                                      
         RC(JB,705) = KOUT1040
         RC(JB,706) = KIN 	                                                      
         RC(JB,707) = KOUT1041
         RC(JB,708) = KIN 	                                                      
         RC(JB,709) = KOUT1042
         RC(JB,710) = KIN 	                                                      
         RC(JB,711) = KOUT1043
         RC(JB,712) = KIN 	                                                      
         RC(JB,713) = KOUT1044
         RC(JB,714) = KIN 	                                                      
         RC(JB,715) = KOUT1045
         RC(JB,716) = KIN 	                                                      
         RC(JB,717) = KOUT1046
         RC(JB,718) = KIN 	                                                      
         RC(JB,719) = KOUT1047
         RC(JB,720) =  2.1E-11
         RC(JB,721) =  7.5E-11
         RC(JB,722) =  7.5E-11
         RC(JB,723) =  3.0E-11
         RC(JB,724) =  3.0E-11
         RC(JB,725) =  3.0E-11
         RC(JB,726) =  3.0E-11
         RC(JB,727) =  3.0E-11
         RC(JB,728) =  1.0E-11
         RC(JB,729) =  1.0E-11
         RC(JB,730) =  2.6E-11
         RC(JB,731) =  2.6E-11
         RC(JB,732) =  2.6E-11
         RC(JB,733) =  2.3E-11
         RC(JB,734) =  2.3E-11
         RC(JB,735) =  2.3E-11
         RC(JB,736) =  1.2E-11
         RC(JB,737) =  1.2E-11
         RC(JB,738) =  1.2E-11
         RC(JB,739) =  1.6E-11
         RC(JB,740) =  1.6E-11
         RC(JB,741) =  1.0E-11
         RC(JB,742) =  1.0E-11
         RC(JB,743) =  1.0E-11
         RC(JB,744) =  2.0E-11
         RC(JB,745) =  2.0E-11
         RC(JB,746) =  2.0E-11
         RC(JB,747) =  9.5E-12
         RC(JB,748) =  9.5E-12
         RC(JB,749) =  9.5E-12
         RC(JB,750) =  4.4E-12
         RC(JB,751) =  2.0E-11
         RC(JB,752) =  2.0E-11
         RC(JB,753) =  2.0E-11
         RC(JB,754) =  8.6E-11
         RC(JB,755) =  8.6E-11
         RC(JB,756) =  7.5E-11
         RC(JB,757) =  7.5E-11
         RC(JB,758) =  7.5E-11
         RC(JB,759) =  9.6E-12
         RC(JB,760) =  9.6E-12
         RC(JB,761) =  9.6E-12
         RC(JB,762) =  8.7E-11
         RC(JB,763) =  8.7E-11
         RC(JB,764) =  8.7E-11
         RC(JB,765) =  8.7E-11
         RC(JB,766) =  4.2E-12
C       -----------------------
C       Aqueous phase reactions
C       -----------------------

        REUS1 = ((1.0/TC(JB))-(1.0/298.0))
C      HSO3(-) + H2O2(aq) = H(+) + SO4(2-) + H2O
C      RC(260): The H+ dependence is in backward Euler code
C      Martin & Damschen (1981), Bower et al., (1991).
        RC(JB,527) = 5.2D+6*EXP(-3650*REUS1)

C      HSO3(-) + O3 = H(+) + SO4(2-) + O2
C      Maahs (1983)
        RC(JB,528) = 4.2D+5*EXP(-4131*REUS1)

C      SO3(2-) + O3 = SO4(2-) + O2
C      Maahs (1983)
        RC(JB,529) = 1.5D+9*EXP(-996*REUS1)

      END DO
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE EQMCON(KE,KH,TC)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculate Henry's law and equilibrium constants
C-
C-   Inputs  : TC
C-   Outputs : KE,KH
C-   Controls:
C-
C-   Created   7-JAN-1997   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER JB
      REAL TC(NBLOCK),KE(NBLOCK,6),KH(NBLOCK,5),REUS1
C
      DO JB=1,NBLOCK
        REUS1 = ((1.0/TC(JB))-(1.0/298.0))
C      HNO3 = NO3(-) + H(+)
        KE(JB,1)=1.8D-5*EXP(-450.0*REUS1)
C       SO2(aq) = H(+) + HSO3(-)
        KE(JB,2) = 1.7D-02*EXP(2090.0*REUS1)
C       HSO3(-) = H(+) + SO3(2-)
        KE(JB,3) = 6.0D-08*EXP(1120.0*REUS1)
C      NH3 + H2O = NH4(+) + OH(-)
        KE(JB,4)=1.8D-5*EXP(-450.0*REUS1)
C      CO2 = H(+) + HCO3(-)
        KE(JB,5)=4.3D-7*EXP(-913.0*REUS1)
C      H2O = H(+) + OH(-)
        KE(JB,6)=1.8D-16*EXP(-6716.0*REUS1)

C      Henrys law constants (mol/(l.atm)).
C      Aqueous phase equilibria.

C      O3
        KH(JB,1)=1.1D-2*EXP(2300.0*REUS1)
C      HNO3
        KH(JB,2)=3.3D+6*EXP(8700.0*REUS1)
C      H2O2
        KH(JB,3)=7.36D+4*EXP(6621.0*REUS1)
C      SO2
        KH(JB,4)=1.23D+0*EXP(3120.0*REUS1)
C      NH3
        KH(JB,5)=7.5D+1*EXP(3400.0*REUS1)
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE PLOT(CONC,XX,IPOS,NNN,D1,D2)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : TRANSFER LAGRANGIAN CONCS TO EULERIAN GRID
C-                         AND DO MIXING
C-
C-   Inputs  : XX,IPOS,NNN,D1,D2
C-   Outputs : CONC,XX
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   4 Oct 1994   David Stevenson to do stratospheric diffusion
C-                                          and fluxes
C-   Updated   6 Dec 1994   David Stevenson turn off by putting dstrat=0.0
C-   Updated   2-MAR-1995   Bill Collins   Removed stratospheric diffusion
C-                                         parameters
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5,NCELL),NNN(NLONG,MNLAT,NLEV)
      REAL CONC(NC,NLONG,MNLAT,NLEV),XX(NC,NCELL),D1,D2,D
      INTEGER I,J,K,L,N
C
C      PLOT BACK TO EULERIAN GRID
C      GRID CONCENTRATIONS CALCULATED FROM CELLS WITHIN EACH GRID
C      MIXING OF LAGRANGIAN CELLS WITHIN EACH GRID
C
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            DO L=1,NC
              CONC(L,I,J,K)=0
            ENDDO
          ENDDO
        ENDDO
      ENDDO
C
      DO 66 N=1,NCELL
        I=IPOS(1,N)
        J=IPOS(2,N)
        K=IPOS(5,N)
        IF (NNN(I,J,K).EQ.0)
     &      WRITE(6,*) 'PLOT: NNN=0! ',N,I,J,K
        DO 65 L=1,NC
          CONC(L,I,J,K)=CONC(L,I,J,K)+XX(L,N)/NNN(I,J,K)
   65   CONTINUE
        IF(XX(6,N).GT.1.5E-06.OR.XX(6,N).LT.1.0E-11) THEN
C          PRINT *,' *** PLOT: OZONE CONCENTRATION OUT OF BOUNDS AT ',
C     &            'CELL =',N
        CONTINUE
C          PRINT *,'***XX(6,N)=',XX(6,N),' NNN(I,J,K)=',NNN(I,J,K),
C     &            ' POSITION ARRAY:(1,2,5) ',I,J,K
C          PRINT *,'***CELL MIXING RATIO DUMP:'
C          WRITE(6,101) (XX(L,N),L=1,NC)
C  101     FORMAT(10(5(1PE13.5)/))
        ENDIF
   66 CONTINUE
C
C      MIXING :
C      SET LAGRANGIAN CELLS EQUAL TO EULERIAN CONCENTRATION
C      OR EXCHANGE MASS BETWEEN EULERIAN AND LAGRANGIAN
C
      DO N=1,NCELL
        I=IPOS(1,N)
        J=IPOS(2,N)
        K=IPOS(5,N)
C        Test for sensitivity to D in upper model.
        IF (K.GT.6) THEN
          D=D2
        ELSE
          D=D1
        ENDIF
        DO L=1,NC
          XX(L,N)=XX(L,N)+D*(CONC(L,I,J,K)-XX(L,N))
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE SMOOTH(CONC,NNN,LAT,LONG)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : SMOOTHS HOLES
C-
C-   Inputs  : CONC,NNN,LAT,LONG
C-   Outputs : CONC
C-   Controls:
C-
C-   Created   7-JUN-1995   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L,II,JJ,ILON,JLAT,MLONG
      INTEGER NNN(NLONG,MNLAT,NLEV)
      REAL CONC(NC,NLONG,MNLAT,NLEV),LAT(NLAT),LONG(NLONG)
      REAL WEIGHT(0:MNLAT-1,-1:1),DIST,SUMW,DEGRAD,LAT1,LAT2,R
      REAL SUMCON(NC)
C FOR GRID SQUARES WITH NO CELLS, TAKE AVERAGE OF SURROUNDING SQUARES THAT DO
C CONTAIN CELLS
      R=2. ! Radius for smoothing (in degrees subtended at centre of earth)
      DEGRAD=PI/180.
      DO J=1,MNLAT
        LAT1=DEGRAD*(LAT(J)+LAT(J+1))/2.
        MLONG=INT(1.5/SIN(LAT1)+0.5)
        IF(MLONG.GT.NLONG/2-1) MLONG=NLONG/2-1
        DO JJ=-1,1
          LAT2=((LAT(J)+LAT(J+1))/2.+JJ*180./MNLAT)*DEGRAD
          DO II=0,NLONG/2-1
            DIST=COS(LAT1)*COS(LAT2)+SIN(LAT1)*SIN(LAT2)*
     &          COS(II*360.*DEGRAD/NLONG)
            IF(DIST.GT.1.0) DIST=1.0
            DIST=ACOS(DIST)/DEGRAD
            WEIGHT(II,JJ)=EXP(-DIST**2/R**2)
            IF((LAT2.GT.PI.OR.LAT2.LT.0.).AND.II.NE.0) WEIGHT(II,JJ)
     &          =0.

          ENDDO
        ENDDO
C        WRITE(6,'(X,2(18(1PF4.1)/))') WEIGHT
        DO K=1,NLEV
          DO I=1,NLONG
            IF(NNN(I,J,K).EQ.0.OR..TRUE.) THEN
              SUMW=0.
              DO L=1,NC
                SUMCON(L)=0.
              ENDDO
C calculate coordinates of surrounding squares
              DO JJ=-1,1
                DO II=-MLONG,MLONG
                  ILON=MOD(I+II+NLONG-1,NLONG)+1
                  JLAT=J+JJ
                  IF(JLAT.LT.1.OR.J.GT.MNLAT)
     &                ILON=MOD(ILON+NLONG/2-1,NLONG)+1
                  JLAT=MIN(MAX(JLAT,1),MNLAT)
C Add up the weights
                  IF(NNN(ILON,JLAT,K).NE.0) THEN
                    SUMW=SUMW+WEIGHT(ABS(II),JJ)
                    DO L=1,NC
C concentration is the average
                      SUMCON(L)=SUMCON(L)+
     &                    CONC(L,ILON,JLAT,K)*WEIGHT(ABS(II),JJ)
                    ENDDO
                  ENDIF
                ENDDO
              ENDDO
              IF(SUMW.GT.0.) THEN
                DO L=1,NC
                  CONC(L,I,J,K)=SUMCON(L)/SUMW
                ENDDO
              ELSE
                PRINT *,'SUMW=0. I,J,K=',I,J,K
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE MCALC(MASS,XX,CLIST,IPOS,NCHEM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATES MASS (IN NO. OF MOLECULES) OF SPECIES
C-                         IN EACH GRID VOLUME
C-
C-   Inputs  : XX,IPOS,clist,NCHEM
C-   Outputs : MASS
C-   Controls:
C-
C-   Created   10-MAY-1994   W.J. Collins
C-             21 sept ds changed so only masses of specified species calced
C-   Updated   13-JAN-1995   Bill Collins  Added parameter NCHEM
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5,NCELL),NCHEM
      REAL MASS(NUMCHEM,NLONG,MNLAT,NLEV),XX(NC,NCELL)
      INTEGER I,J,K,L,N,CLIST(NUMCHEM)
C
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            DO L=1,NUMCHEM
              MASS(L,I,J,K)=0.0
            ENDDO
          ENDDO
        ENDDO
      ENDDO
C
      DO N=1,NCELL
        I=IPOS(1,N)
        J=IPOS(2,N)
        K=IPOS(5,N)
        DO L=1,NCHEM
          MASS(L,I,J,K)=MASS(L,I,J,K)+XX(CLIST(L),N)
        ENDDO
      ENDDO
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE STATS(MCONC,SDCONC,NM,NSTAT,NNN,CONC)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : ACCUMULATE STATISTICS
C-
C-   Inputs  : CONC,NNN
C-   Outputs : MCONC,SDCONC,NM,NSTAT
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   7-JUN-1995   Bill Collins  NM is accumulated no. of cells per
C-                                        grid volume, NSTAT is no. of timesteps
C-                                        of accumulation.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L
      INTEGER NM(NLONG,MNLAT,NLEV),NSTAT,NNN(NLONG,MNLAT,NLEV)
      REAL MCONC(NC,NLONG,MNLAT,NLEV),
     &    SDCONC(NC,NLONG,MNLAT,NLEV),CONC(NC,NLONG,MNLAT,NLEV)
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            DO L=1,NC
              MCONC(L,I,J,K)=MCONC(L,I,J,K)+CONC(L,I,J,K)
              SDCONC(L,I,J,K)=SDCONC(L,I,J,K)+
     &            CONC(L,I,J,K)*CONC(L,I,J,K)
            ENDDO
            NM(I,J,K)=NM(I,J,K)+NNN(I,J,K)
          ENDDO
        ENDDO
      ENDDO
      NSTAT=NSTAT+1
  999 RETURN
      END
C#######################################################################
      SUBROUTINE OUTLEV(NNN)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : PRINT OUT CELL LOCATIONS
C-
C-   Inputs  : NNN
C-   Outputs : NONE
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NNN(NLONG,MNLAT,NLEV),MLEV(NLEV)
      INTEGER I,J,K,L,N
      DO 100 K=1,NLEV
        MLEV(K)=0
  100 CONTINUE
C
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            MLEV(K)=MLEV(K)+NNN(I,J,K)
          ENDDO
        ENDDO
      ENDDO
      WRITE(7,231) MLEV
C
      DO K=1,NLEV
        WRITE(7,220) K
        DO L=MNLAT,1,-1
          N=0
          DO I=1,NLONG
            N=N+NNN(I,L,K)
          ENDDO
          WRITE(7,221) (NNN(I,L,K), I=1,NLONG), N
        ENDDO
      ENDDO
  220 FORMAT(' LEVEL: ',I3/)
  221 FORMAT(36I3/36I3,I6)
  231 FORMAT(' ALLOCATION OF CELLS IN EACH LEVEL: ',9I6//)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE OUTBUD(NM,MASS,M0,TFLUX,LMOLEC,CLIST,NCHEM,FNAMES,
     &    NFLUX,TOTM0,TOTMAS,TOTAVG,TOTFLU,NAVG,FLIST,OUTDAY,PERIOD,DAY,
     &    MONTH,YEAR)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : PRINT OUT BUDGETS AND INVENTORIES
C-
C-   Inputs  : NM,MASS,M0,TFLUX,LMOLEC,CLIST,NCHEM,FNAMES,NFLUX,FLIST,TOTM0,
C-             TOTMAS, TOTAVG,NAVG
C-   Outputs : NONE
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  11-APR-1994   Bill Collins  Now includes calculation of EMOLEC,
C-                                        which was originally in main program.
C-   Updated   ?-???-1994   D.Stevenson   Added totom0,totmas,totflux,
C-                                        totstratflu.
C-   Updated   2-MAR-1995   Bill Collins  Removed totstratflu, added numchem and
C-                                        numflux.
C-   Updated   6-JUN-1995   Bill Collins  Added output of NM
C-   Updated  13-JUN-1995   Colin Johnson Conditional o/p to unit 19.
C-   Updated  26-JAN-1996   Bill Collins  Got rid of 3-d masses
C-   Updated  17-JAN-1996   Colin Johnson Added output of TOTAVG, NAVG
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L,LL,M,NCHEM,NFLUX,N3DFLUX,MONTH,YEAR,NAVG
      INTEGER FLIST(2,NUMFLUX)
      CHARACTER*40 FNAMES(NUMFLUX)
      CHARACTER*15 CLONG(6)
      INTEGER NM(NLONG,MNLAT,NLEV)
      REAL MASS(NUMCHEM,NLONG,MNLAT,NLEV),
     &    M0(NUMCHEM,NLONG,MNLAT,NLEV)
      DOUBLE PRECISION LMOLEC
      REAL TFLUX(NUM3DFLUX,NLONG,MNLAT,NLEV)
      REAL TOTM0(NUMCHEM),TOTMAS(NUMCHEM),TOTFLU(NUMFLUX),
     &    TOTAVG(NUMCHEM)
      REAL OUTDAY,PERIOD,DAY
      INTEGER CLIST(NUMCHEM)
      DATA CLONG /' 0-60 E ',' 60-120 E ',' 120-180 E ',
     &            ' 180-120 W ',' 120-60 W ',' 60-0 W '/
C
      WRITE(19,206) 'CELL NO.S'
      DO K=1,NLEV
        WRITE(19,220) K
        DO M=1,6
          WRITE(19,210) CLONG(M)
          DO J=MNLAT,1,-1
            WRITE(19,'(12I4)') (NM(I,J,K),I=(M-1)*12+1,(M-1)*12+12)
          ENDDO
        ENDDO
      ENDDO
      WRITE(19,*) ' NCHEM: ',0
      WRITE(18,*) ' NCHEM: ',NCHEM
      WRITE(18,207)
      DO LL=1,NCHEM
        L=CLIST(LL)
        WRITE(18,211) CNAMES(L),TOTM0(LL)*LMOLEC
      ENDDO

      WRITE(19,*) 0
      WRITE(18,*) NCHEM
      WRITE(18,207)
      DO LL=1,NCHEM
        L=CLIST(LL)
        WRITE(18,211) CNAMES(L),TOTMAS(LL)*LMOLEC
      ENDDO
C
C      Output average inventories.
      WRITE(18,*) 'NCHEM: ',NCHEM,' NAVG:  ',NAVG
      WRITE(18,214)
      DO LL=1,NCHEM
        L=CLIST(LL)
        WRITE(18,211) CNAMES(L),TOTAVG(LL)*LMOLEC
      ENDDO
C
      WRITE(18,*) 'NFLUX: ',NFLUX
      WRITE(18,209) PERIOD,OUTDAY
      N3DFLUX=0
      DO L=1,NFLUX
        IF(FLIST(2,L).GT.0) THEN
          N3DFLUX=FLIST(2,L)
        ENDIF
        WRITE(18,212) L,FNAMES(L),TOTFLU(L)*LMOLEC
      ENDDO
      WRITE(19,*) 'N3DFLUX: ',N3DFLUX
      DO L=1,NFLUX
        IF(FLIST(2,L).GT.0) THEN
          WRITE(19,213) FLIST(2,L),FNAMES(FLIST(2,L))
          DO K=1,NLEV
            WRITE(19,220) K
            DO M=1,6
              WRITE(19,210) CLONG(M)
              DO J=MNLAT,1,-1
                WRITE(19,208) (TFLUX(FLIST(2,L),I,J,K)*LMOLEC,
     &              I=(M-1)*12+1,(M-1)*12+12)
              ENDDO
            ENDDO
          ENDDO
        ENDIF
      ENDDO
C
  206 FORMAT('SPECIES: ',A10,' DAY: ',F3.0,' MONTH: ',I2,' YEAR: ',I2)
  207 FORMAT(' TOTAL INVENTORY IN MOLECULES',/)
  208 FORMAT(6(1PE15.8))
  209 FORMAT(/,' FLUX ANALYSIS IN MOLECULES PER ',F4.1,' DAY(S)',/
     &       ' DATA COLLECTED FROM DAY ',F4.1)
  210 FORMAT(/,A15)
  211 FORMAT(A40,': ',1PE20.8)
  212 FORMAT(1X,I3,1X,A40,': ',1PE20.8)
  213 FORMAT(I3,1X,A40)
  214 FORMAT(' AVERAGE INVENTORY OVER PERIOD IN MOLECULES',/)
  220 FORMAT(' LEVEL: ',I3/)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CALSTA(SDCONC,MCONC,NSTAT,M)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE MEANS AND STANDARD DEVIATIONS
C-
C-   Inputs  : SDCONC,MCONC,NSTAT,NC,NLONG,MNLAT,NLEV
C-   Outputs : SDCONC,MCONC
C-   Controls:
C-
C-   Created  11-APR-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L
      REAL SDCONC(NC,NLONG,MNLAT,NLEV),
     &      MCONC(NC,NLONG, MNLAT,NLEV),PX,M(NLEV)
      INTEGER NSTAT
C
C      CALCULATE MEAN AND STANDARD DEVIATION
C
      IF(NSTAT.GT.1) THEN
        DO L=1,NC
          DO I=1,NLONG
            DO J=1,MNLAT
              DO K=1,NLEV
                PX=SDCONC(L,I,J,K)-(MCONC(L,I,J,K)**2.0)/NSTAT
                IF (PX.LT.1.0D-40) THEN
                  SDCONC(L,I,J,K)=0.0
                ELSE
                  SDCONC(L,I,J,K)=SQRT(PX/(NSTAT-1))
                ENDIF
c                MCONC(L,I,J,K)=M(K)*MCONC(L,I,J,K)/NSTAT
                MCONC(L,I,J,K)=MCONC(L,I,J,K)/NSTAT
              ENDDO
            ENDDO
          ENDDO
        ENDDO
      ENDIF
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE OUTSTA(OUT,CLIST,NCHEM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : PRINTS OUT STATISTICS
C-
C-   Inputs  : OUT
C-   Outputs : NONE
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated  11-APR-1994   Bill Collins  Removed calculations from this
C-                                        routine (now in CALSTA). Array
C-                                        OUT is output. This can be snapshots,
C-                                        means or standard deviations.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L,M,LL,NCHEM
      CHARACTER*15 CLONG(6)
      REAL OUT(NC,NLONG,MNLAT,NLEV)
      INTEGER CLIST(NC)
      DATA CLONG /' 0-60 E ',' 60-120 E ',' 120-180 E ',
     &            ' 180-120 W ',' 120-60 W ',' 60-0 W '/
C
C        OUTPUT THE SPECIES MIXING RATIOS (MEAN, S. DEV.)
C
      WRITE(20,*) NCHEM
      DO LL=1,NCHEM
        L=CLIST(LL)
        WRITE(20,207) CNAMES(L)
        DO K=1,NLEV
          WRITE(20,220) K
          DO M=1,6
            WRITE(20,210) CLONG(M)
            DO J=MNLAT,1,-1
              WRITE(20,208) (OUT(L,I,J,K),I=(M-1)*12+1,(M-1)*12+12)
            ENDDO
          ENDDO
        ENDDO
      ENDDO
C
  207 FORMAT('SPECIES: ',A10)
  208 FORMAT(12(1PE10.3))
  210 FORMAT(/,A15)
  220 FORMAT(' LEVEL: ',I3/)

  999 RETURN
      END
C#######################################################################
      SUBROUTINE ZEROST(MCONC,SDCONC,NM,NSTAT)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : ZERO STATISTICAL ARRAYS
C-
C-   Inputs  : MCONC,SDCONC,NM,NSTAT
C-   Outputs : MCONC,SDCONC,NM,NSTAT
C-   Controls:
C-
C-   Created  11-APR-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NM(NLONG,MNLAT,NLEV),NSTAT
      REAL MCONC(NC,NLONG,MNLAT,NLEV),SDCONC(NC,NLONG,MNLAT,NLEV)
      INTEGER L,I,J,K
C
C      RESET STATISTICAL ARRAYS TO ZERO
      NSTAT=0
      DO I=1,NLONG
        DO J=1,MNLAT
          DO K=1,NLEV
            NM(I,J,K)=0
            DO L=1,NC
              MCONC(L,I,J,K)=0.0
              SDCONC(L,I,J,K)=0.0
            ENDDO
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      INTEGER FUNCTION HEIGHT(POS,ETA)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE HEIGHT INDICIES ON ETA GRIDS
C-
C-   Inputs  : POS
C-   Outputs : HEIGHT
C-   Controls:
C-
C-   Created  16-DEC-1993   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER N1
      REAL ETA(*)
      REAL POS
      N1=1
      DO 43 WHILE (POS.LT.ETA(N1))
      N1=N1+1
   43 CONTINUE
      IF(POS.EQ.ETA(1)) THEN
        HEIGHT=1
      ELSE
        HEIGHT=N1-1
      ENDIF
  999 RETURN
      END
C#######################################################################
      SUBROUTINE EMREAD(EMISS,CLASS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN EMISSIONS DATA
C-    reads in emissions in tonnes/year per grid square
C-    converts to molecules/s per grid square (output EMISS array)
C-
C-   Inputs  :
C-   Outputs : EMISS
C-   Controls:
C-
C-   Created  15-DEC-1993   Bill Collins
C-   Updated  27-APR-1994   Bill Collins  Added VOC emissions (from Piccot et
C-                                        al.). These include biomass burning
C-   Updated   8-MAR-1995   Bill Collins  Added CH4 emissions (wetland, tundra
C-                                        and paddy) and DMS emissions.
C-   Updated   2-JUN-1995   Colin Johnson To reflect new species order.
C-   Updated  28-JUN-1995   Colin Johnson DMS only in EMUPDT, C3H6=OLEFIN.
C-   Updated   9-JAN-1996   Bill Collins  Use GEIA emissions
C-   Updated  10-JAN-1996   Bill Collins  Emission tabulated in CLASS
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated  17-OCT-1996   Dick Derwent  Propane added as interim
C-   Updated  31-JAN-1997   Bill Collins  NH3 total added. 
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL EMISS(NC,NLONG,MNLAT),NOXDAT(NLONG,MNLAT),
     &  CODAT(NLONG,MNLAT),SO2DAT(NLONG,MNLAT),DMS(NLONG,MNLAT),
     &  WETLAN(NLONG,MNLAT),TUNDRA(NLONG,MNLAT),PADDY(NLONG,MNLAT),
     &  NH3(NLONG,MNLAT),CH4DAT(NLONG,MNLAT),NMVDAT(NLONG,MNLAT)
      REAL CLASS(5,NC)
      INTEGER I,J,I1,J1
C
C
C NOx data, kg/yr per grid square, as N
      OPEN(21,FILE=EMDIR//'nox_1998bau.dat',STATUS='OLD')
      READ(21,*) NOXDAT
      CLOSE(21)
C DMS DATA from oceans, tonnes/yr per grid square, as S
      OPEN(22,FILE=EMDIR//'invsea1.dms',STATUS='OLD')
      READ(22,101) DMS
      CLOSE(22)
C SO2 DATA, kg/yr per grid square, as S
      OPEN(22,FILE=EMDIR//'so2_2000bau.dat',STATUS='OLD')
      READ(22,*) SO2DAT
      CLOSE(22)
C CO  DATA, kg/yr per grid square
      OPEN(22,FILE=EMDIR//'co_1998bau.dat',STATUS='OLD')
      READ(22,*) CODAT
      CLOSE(22)
C CH4 DATA, kg/yr per grid square
      OPEN(22,FILE=EMDIR//'ch4_2000bau.dat',STATUS='OLD')
      READ(22,*) CH4DAT
      CLOSE(22)
C NMV DATA, kg/yr per grid square
      OPEN(22,FILE=EMDIR//'nmv_1998bau.dat',STATUS='OLD')
      READ(22,*) NMVDAT
      CLOSE(22)
C methane wetlands, tundra and paddys, tonnes/yr per grid square
      OPEN(22,FILE=EMDIR//'w_big.dat',STATUS='OLD')
      READ(22,101) WETLAN
      CLOSE(22)
      OPEN(22,FILE=EMDIR//'t_big.dat',STATUS='OLD')
      READ(22,101) TUNDRA
      CLOSE(22)
      OPEN(22,FILE=EMDIR//'p_big.dat',STATUS='OLD')
      READ(22,101) PADDY
      CLOSE(22)
C NH3 emissions excluding biomass burning, oceans and soil.
      OPEN(22,FILE=EMDIR//'nh3totalsinglecolumn.dat',STATUS='OLD')
      READ(22,*) NH3
      CLOSE(22)
C
C
      DO 10 J=1,MNLAT
        J1=MNLAT+1-J
        DO 20 I=1,NLONG
          I1=MOD(I+NLONG/2-1,NLONG)+1
C NOX
          EMISS(8,I,J)=(CLASS(1,8)/100.014)*NOXDAT(I1,J1)*1E3*NA
     &        /(14.0*31536000.0)
C EMPOA
          EMISS(218,I,J)=(CLASS(1,218)/100.014)*NOXDAT(I1,J1)*1E3*NA
     &        /(13.2*31536000.0)
C SO2 (anthro)
          EMISS(16,I,J)=(CLASS(1,16)/113.268)*SO2DAT(I1,J1)*1E3*NA
     &       /(32.0*31536000.0)
C CO (anthro)
          EMISS(11,I,J)=(CLASS(1,11)/570.120)*CODAT(I1,J1)*1E3*NA
     &       /(28.0*31536000.0)
C CH4 as NOx (anthro) +85.0 (animals) Tg/yr
          EMISS(21,I,J)=(CLASS(1,21)/260.304)*CH4DAT(I1,J1)*1E3*NA
     &       /(16.0*31536000.0)
C Other sources of CH4 - shifted by 180 degrees => use I instead of I1
C Paddy 60.0 Tg/yr, Tundra 50.0 Tg/yr, Wetlands 65 Tg/yr
C Updates by MCC ; based on Mikaloff Fletcher 2006 and Houweling 2000
C Paddy 56.0 Tg/yr, Tundra 0.0 Tg/yr (removed), Wetlands 220 Tg/yr
C values for the year 1999
          EMISS(21,I,J)=EMISS(21,I,J)+((WETLAN(I,J1)*220/65)+
     &      (PADDY(I,J1)*56/60))*1E6*NA/(16.0*31536000.0)
C C2H6 (anthro)
          EMISS(23,I,J)=(CLASS(1,23)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(30.0*31536000.0)
C C3H8 (anthro)
          EMISS(25,I,J)=(CLASS(1,25)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(44.0*31536000.0)
C C4H10 (anthro)
          EMISS(28,I,J)=(CLASS(1,28)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(58.0*31536000.0)
C CH3OH (anthro)
          EMISS(76,I,J)=(CLASS(1,76)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(32.0*31536000.0)
C ACETONE (anthro)
          EMISS(73,I,J)=(CLASS(1,73)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(58.0*31536000.0)
C C2H4 (anthro)
          EMISS(30,I,J)=(CLASS(1,30)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(28.0*31536000.0)
C C3H6 (anthro)
          EMISS(32,I,J)=(CLASS(1,32)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(42.0*31536000.0)
C O-XYL (anthro)
          EMISS(67,I,J)=(CLASS(1,67)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(106.0*31536000.0)
C HCHO (anthro)
          EMISS(39,I,J)=(CLASS(1,39)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(30.0*31536000.0)
C CH3CHO (anthro)
          EMISS(42,I,J)=(CLASS(1,42)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(44.0*31536000.0)
C H2 as NOx
          EMISS(10,I,J)=(CLASS(1,10)/100.014)*NOXDAT(I1,J1)*1E3*NA
     &       /(2.0*31536000.0)
C TOLUENE (anthro) 
          EMISS(64,I,J)=(CLASS(1,64)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(92.0*31536000.0)
C Isoprene (anthro) as NOX
          EMISS(43,I,J)=(CLASS(1,43)/100.014)*NOXDAT(I1,J1)*1E3*NA
     &       /(68.0*31526000.0)
C BENZENE (anthro)
          EMISS(61,I,J)=(CLASS(1,61)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(78.0*31536000.0)
C HCOOH (anthro)
          EMISS(40,I,J)=(CLASS(1,40)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(46.0*31536000.0)
C CH3CO2H (anthro)
          EMISS(41,I,J)=(CLASS(1,41)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(60.0*31536000.0)
C C2H5OH (anthro)
          EMISS(77,I,J)=(CLASS(1,77)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(46.0*31536000.0)
C MEK (anthro)
          EMISS(101,I,J)=(CLASS(1,101)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(72.0*31536000.0)
C C2H5CHO (anthro)
          EMISS(71,I,J)=(CLASS(1,71)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(58.0*31536000.0)
C C2H2 (anthro)
          EMISS(59,I,J)=(CLASS(1,59)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(26.0*31536000.0)
C TBUT2ENE (anthro)
          EMISS(34,I,J)=(CLASS(1,34)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(56.0*31536000.0)
C CH3BR (anthro) as NOx
          EMISS(227,I,J)=(CLASS(1,227)/100.014)*NOXDAT(I1,J1)*1E3*NA
     &       /(94.909*31536000.0)
C NH3 (man-related)
          EMISS(228,I,J)=(CLASS(1,228)/37.1)*NH3(I1,J1)*1E12*NA
     &       /(14.0*31526000.0)
C FTOH (anthro)
          EMISS(247,I,J)=(CLASS(1,247)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(464.0*31536000.0)
C PFOA (anthro)
          EMISS(248,I,J)=(CLASS(1,248)/122.079)*NMVDAT(I1,J1)*1E3*NA
     &       /(414.0*31536000.0)
   20   CONTINUE
   10 CONTINUE
  100 FORMAT(6E12.4)
  101 FORMAT(6F10.2)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE EMCALC(EMISS,DDEPO,LAND,LMOLEC,MONTH)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE EMISSIONS AND DEPOSITIONS
C-
C-   Inputs  : LAND,LAT,LMOLEC
C-   Outputs : EMISS,DDEPO
C-   Controls:
C-
C-   Created  23-DEC-1993   Bill Collins
C-   Updated  27-APR-1994   Bill Collins  Change ethanol to toluene, add TOLP1
C-   Updated  31-MAY-1994   Bill Collins  Remove dry dep. of CH3O2 and C2H5O2
C-                                        and replace with CH3O2H
C-   Updated   8-MAR-1995   Bill Collins  Remove 'LAND' sources
C-   Updated  31-MAY-1995   Colin Johnson Replaced DVLAND, DVSEA due to new
C-                                        species order.
C-   Updated  10-JAN-1996   Bill Collins  Tabulate emissions classes so they are
C-                                        easier to change.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,MONTH,IC
      REAL EMISS(NC,NLONG,MNLAT)
      DOUBLE PRECISION LMOLEC
      REAL DVLAND(NC),DVSEA(NC),LAND(NLONG,MNLAT),ISOPRE
      REAL CLASS(5,NC)
      REAL DDEPO(NC,NLONG,MNLAT)
C
C      non-zero values:
C      species      land     sea     index
C      NO2          1.0      0.5     4
C      CO           0.3      0.0     10
C      O3           6.0      1.0     6
C      H2           0.45     0.0     10
C      HNO3        40.0     10.0     14
C      H2O2        10.0     10.0     12
C      PAN          2.0      0.0     198
C      ROOH         5.0      5.0     144,147,145,35,52,53
C      SO2          6.0      8.0     26
C      SA           2.0      1.0     30
C      MSA          2.0      1.0     68
C      NAER         2.0      1.0     19
C      EMPOA        2.0      1.0     218
c      P2604        2.0      1.0     204
c      P4608        2.0      1.0     205
c      P2631        2.0      1.0     206
c      P2635        2.0      1.0     207
c      P4610        2.0      1.0     208
c      P2605        2.0      1.0     209
c      P2630        2.0      1.0     210
c      P2629        2.0      1.0     211
c      P2632        2.0      1.0     212
c      P2637        2.0      1.0     213
c      P3612        2.0      1.0     214
c      P3613        2.0      1.0     215
c      P3442        2.0      1.0     216
c      P2007        2.0      1.0     219

c      DATA DVLAND,DVSEA /NC*0.0,NC*0.0/
C                                 LAND   SEA    SPECIES
      DATA DVLAND(4),DVSEA(4)     /1.0,  0.5/ ! NO2
      DATA DVLAND(6),DVSEA(6)     /6.0,  1.0/ ! O3
      DATA DVLAND(10),DVSEA(10)   /.45,  0.0/ ! H2
      DATA DVLAND(11),DVSEA(11)   /0.3,  0.0/ ! CO
      DATA DVLAND(12),DVSEA(12)   /10.,  10./ ! H2O2
      DATA DVLAND(14),DVSEA(14)   /40.,  10./ ! HNO3
      DATA DVLAND(16),DVSEA(16)   /6.0,  8.0/ ! SO2
      DATA DVLAND(19),DVSEA(19)   /2.0,  1.0/ ! NAER
      DATA DVLAND(20),DVSEA(20)   /2.0,  1.0/ ! SA
      DATA DVLAND(39),DVSEA(39)   /3.8, 11.4/ ! HCHO - rvkdiss (adapted)
      DATA DVLAND(40),DVSEA(40)   /27.6,13.0/ ! HCOOH - rvkdiss( adapted)
      DATA DVLAND(41),DVSEA(41)   /13.0,13.4/ ! CH3CO2H - rvkdiss( adapted)
      DATA DVLAND(42),DVSEA(42)   /0.7,  0.3/ ! CH3CHO - rvkdiss( adapted)
      DATA DVLAND(46),DVSEA(46)   /0.7,  0.5/ ! Methacrolein - UCARB10 - rvkdiss( adapted)
      DATA DVLAND(73),DVSEA(73)   /0.8,  0.5/ ! CH3COCH3 - rvkdiss( adapted)
      DATA DVLAND(76),DVSEA(76)   /1.6,  3.0/ ! CH3OH - rvkdiss( adapted)
      DATA DVLAND(77),DVSEA(77)   /1.6,  3.0/ ! C2H5OH - CH3OH rvkdiss( adapted)
      DATA DVLAND(98),DVSEA(98)   /3.5, 11.4/ ! Methylglyoxal - CARB6 - rvkdiss( adapted)
      DATA DVLAND(101),DVSEA(101) /0.7,  0.4/ ! MEK - rvkdiss( adapted)
      DATA DVLAND(144),DVSEA(144) /5.0,  5.0/ ! CH3OOH
      DATA DVLAND(145),DVSEA(145) /5.0,  5.0/ ! C2H5OOH
      DATA DVLAND(147),DVSEA(147) /5.0,  5.0/ ! C3H7OOH      
      DATA DVLAND(198),DVSEA(198) /2.0,  0.0/ ! PAN
      DATA DVLAND(202),DVSEA(202) /2.0,  0.0/ ! MPAN - as PAN
c      DATA DVLAND(35),DVSEA(35)   /5.0,  5.0/ ! C4H9OOH
c      DATA DVLAND(52),DVSEA(52)   /5.0,  5.0/ ! ISOPOOH
c      DATA DVLAND(53),DVSEA(53)   /5.0,  5.0/ ! MVKOOH
      DATA DVLAND(204),DVSEA(204) /2.0,  1.0/ ! P2604
      DATA DVLAND(205),DVSEA(205) /2.0,  1.0/ ! P4608
      DATA DVLAND(206),DVSEA(206) /2.0,  1.0/ ! P2631
      DATA DVLAND(207),DVSEA(207) /2.0,  1.0/ ! P2635
      DATA DVLAND(208),DVSEA(208) /2.0,  1.0/ ! P4610
      DATA DVLAND(209),DVSEA(209) /2.0,  1.0/ ! P2605
      DATA DVLAND(210),DVSEA(210) /2.0,  1.0/ ! P2630
      DATA DVLAND(211),DVSEA(211) /2.0,  1.0/ ! P2629
      DATA DVLAND(212),DVSEA(212) /2.0,  1.0/ ! P2632
      DATA DVLAND(213),DVSEA(213) /2.0,  1.0/ ! P2637
      DATA DVLAND(214),DVSEA(214) /2.0,  1.0/ ! P3612
      DATA DVLAND(215),DVSEA(215) /2.0,  1.0/ ! P3613
      DATA DVLAND(216),DVSEA(216) /2.0,  1.0/ ! P3442
      DATA DVLAND(218),DVSEA(218) /2.0,  1.0/ ! EMPOA
      DATA DVLAND(219),DVSEA(219) /2.0,  1.0/ ! P2007
      DATA DVLAND(296),DVSEA(296) /2.0,  1.0/ ! P1001
      DATA DVLAND(297),DVSEA(297) /2.0,  1.0/ ! P1002
      DATA DVLAND(298),DVSEA(298) /2.0,  1.0/ ! P1003
      DATA DVLAND(299),DVSEA(299) /2.0,  1.0/ ! P1004
      DATA DVLAND(300),DVSEA(300) /2.0,  1.0/ ! P1005
      DATA DVLAND(301),DVSEA(301) /2.0,  1.0/ ! P1006
      DATA DVLAND(302),DVSEA(302) /2.0,  1.0/ ! P1007
      DATA DVLAND(303),DVSEA(303) /2.0,  1.0/ ! P1008
      DATA DVLAND(304),DVSEA(304) /2.0,  1.0/ ! P1009
      DATA DVLAND(305),DVSEA(305) /2.0,  1.0/ ! P1010
      DATA DVLAND(306),DVSEA(306) /2.0,  1.0/ ! P1011
      DATA DVLAND(307),DVSEA(307) /2.0,  1.0/ ! P1012
      DATA DVLAND(308),DVSEA(308) /2.0,  1.0/ ! P1013
      DATA DVLAND(309),DVSEA(309) /2.0,  1.0/ ! P1014
      DATA DVLAND(310),DVSEA(310) /2.0,  1.0/ ! P1015
      DATA DVLAND(311),DVSEA(311) /2.0,  1.0/ ! P1016
      DATA DVLAND(312),DVSEA(312) /2.0,  1.0/ ! P1017
      DATA DVLAND(313),DVSEA(313) /2.0,  1.0/ ! P1018
      DATA DVLAND(314),DVSEA(314) /2.0,  1.0/ ! P1019
      DATA DVLAND(315),DVSEA(315) /2.0,  1.0/ ! P1020
      DATA DVLAND(316),DVSEA(316) /2.0,  1.0/ ! P1021
      DATA DVLAND(317),DVSEA(317) /2.0,  1.0/ ! P1022
      DATA DVLAND(318),DVSEA(318) /2.0,  1.0/ ! P1023
      DATA DVLAND(319),DVSEA(319) /2.0,  1.0/ ! P1024
      DATA DVLAND(320),DVSEA(320) /2.0,  1.0/ ! P1025
      DATA DVLAND(321),DVSEA(321) /2.0,  1.0/ ! P1026
      DATA DVLAND(322),DVSEA(322) /2.0,  1.0/ ! P1027
      DATA DVLAND(323),DVSEA(323) /2.0,  1.0/ ! P1028
      DATA DVLAND(324),DVSEA(324) /2.0,  1.0/ ! P1029
      DATA DVLAND(325),DVSEA(325) /2.0,  1.0/ ! P1030
      DATA DVLAND(326),DVSEA(326) /2.0,  1.0/ ! P1031
      DATA DVLAND(327),DVSEA(327) /2.0,  1.0/ ! P1032
      DATA DVLAND(328),DVSEA(328) /2.0,  1.0/ ! P1033
      DATA DVLAND(329),DVSEA(329) /2.0,  1.0/ ! P1034
      DATA DVLAND(330),DVSEA(330) /2.0,  1.0/ ! P1035
      DATA DVLAND(331),DVSEA(331) /2.0,  1.0/ ! P1036
      DATA DVLAND(332),DVSEA(332) /2.0,  1.0/ ! P1037
      DATA DVLAND(333),DVSEA(333) /2.0,  1.0/ ! P1038
      DATA DVLAND(334),DVSEA(334) /2.0,  1.0/ ! P1039
      DATA DVLAND(335),DVSEA(335) /2.0,  1.0/ ! P1040
      DATA DVLAND(336),DVSEA(336) /2.0,  1.0/ ! P1041
      DATA DVLAND(337),DVSEA(337) /2.0,  1.0/ ! P1042
      DATA DVLAND(338),DVSEA(338) /2.0,  1.0/ ! P1043
      DATA DVLAND(339),DVSEA(339) /2.0,  1.0/ ! P1044
      DATA DVLAND(340),DVSEA(340) /2.0,  1.0/ ! P1045
      DATA DVLAND(341),DVSEA(341) /2.0,  1.0/ ! P1046
      DATA DVLAND(342),DVSEA(342) /2.0,  1.0/ ! P1047
C
      DATA DVLAND(226),DVSEA(226) /2.0,  1.0/ ! MSA   
      DATA DVLAND(227),DVSEA(227) /0.0,  0.0/ ! CH3BR
      DATA DVLAND(228),DVSEA(228) /8.0,  8.0/ ! NH3 - Sorteberg & Hov (1996)
      DATA DVLAND(248),DVSEA(248) /1.9,  1.9/ ! PFOA - Wallington et al (2006)
C
C      DATA DVLAND/ 0., 0., 0., 0., 1., 0., 0., .3, 0., 0.,
C     &             6.,.45,40.,10., 0., 0., 0., 0., 0., 0.,
C     &             2., 5., 0., 0., 0., 6., 0., 0., 0., 2.,
C     &             0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
C     &             0., 0., 0., 0., 0., 0., 0., 0., 2., 0./
C
C      DATA DVSEA / 0., 0., 0., 0., .5, 0., 0., 0., 0., 0.,
C     &             1., 0.,10.,10., 0., 0., 0., 0., 0., 0.,
C     &             0., 5., 0., 0., 0., 8., 0., 0., 0., 1.,
C     &             0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
C     &             0., 0., 0., 0., 0., 0., 0., 0., 1., 0./
C
C     -------------------EMISSION CLASSES------------------------------
C                                  Anth  ,Biomass,Veg   ,Soil  ,Oceans
      DATA (CLASS(IC,8),IC=1,5)   /30.45,  6.77,  8.0,  5.6,  0.0 / ! NOX
      DATA (CLASS(IC,11),IC=1,5)  /570.1,  472.0, 160.0,0.0,  20.0/ ! CO
      DATA (CLASS(IC,21),IC=1,5)  /220.0,  88.0,  0.0,  0.0,  15.0/ ! CH4
      DATA (CLASS(IC,39),IC=1,5)  /1.19,   3.61,  0.0,  0.0,  0.0 / ! HCHO
      DATA (CLASS(IC,10),IC=1,5)  /20.0,   20.0,  0.0,  5.0,  5.0 / ! H2
      DATA (CLASS(IC,23),IC=1,5)  /5.69,   3.17,  0.8,  0.0,  0.78/ ! C2H6
      DATA (CLASS(IC,42),IC=1,5)  /1.8,    3.58,  0.0,  0.0,  0.0 / ! CH3CHO
      DATA (CLASS(IC,28),IC=1,5)  /53.29,  1.1,   8.0,  0.0,  0.0 / ! C4H10
      DATA (CLASS(IC,16),IC=1,5)  /56.6,   2.2,   0.0,  0.0,  0.0 / ! SO2
      DATA (CLASS(IC,30),IC=1,5)  /4.15,   6.25,  4.28, 0.0,  1.19 / ! C2H4
      DATA (CLASS(IC,32),IC=1,5)  /2.04,   1.94,  0.86, 0.0,  1.3 / ! C3H6
      DATA (CLASS(IC,67),IC=1,5)  /4.0,    0.7,   0.0,  0.0,  0.0 / ! OXYL
      DATA (CLASS(IC,25),IC=1,5)  /6.42,   0.55,  1.63, 0.0,  1.06/ ! C3H8
      DATA (CLASS(IC,76),IC=1,5) /0.963,  9.2,   229.5,0.0,  0.0 / ! METHANOL
      DATA (CLASS(IC,73),IC=1,5)  /0.297,  1.83,  44.0, 0.0,  0.0 / ! ACETONE
      DATA (CLASS(IC,43),IC=1,5)  /0.0,    0.0,   501.0, 0.0, 0.0 / ! C5H8
      DATA (CLASS(IC,64),IC=1,5)  /5.3,    1.6,   0.0,  0.0,  0.0 / ! TOLUENE
      DATA (CLASS(IC,47),IC=1,5)  /0.0    ,0.0   ,84.71 ,0.0  ,0.0 / ! APINENE
      DATA (CLASS(IC,53),IC=1,5)  /0.0    ,0.0   ,42.29 ,0.0  ,0.0 / ! BPINENE
      DATA (CLASS(IC,61),IC=1,5)  /3.1,    2.5,   0.0,   0.0,  0.0 / ! BENZENE      
      DATA (CLASS(IC,40),IC=1,5)  /1.79,   5.47,  0.0,   0.0,  0.0 / ! HCOOH
      DATA (CLASS(IC,41),IC=1,5)  /16.81,  3.15,  0.0,   0.0,  0.0 / ! CH3CO2H
      DATA (CLASS(IC,77),IC=1,5)  /2.792  ,0.27,  0.0,   0.0,  0.0 / ! C2H5OH
      DATA (CLASS(IC,101),IC=1,5) /1.117  ,4.22  ,0.0   ,0.0   ,0.0 / ! MEK
      DATA (CLASS(IC,71),IC=1,5)  /1.56   ,0.0   ,0.0   ,0.0   ,0.0 / ! C2H5CHO
      DATA (CLASS(IC,59),IC=1,5)  /4.04,   1.73,  0.0,   0.0,   0.0 / ! C2H2
      DATA (CLASS(IC,34),IC=1,5)  /5.73   ,1.61  ,0.0   ,0.0   ,0.0 / ! TBUT2ENE
      DATA (CLASS(IC,220),IC=1,5)  /0.0   ,0.0    ,0.0   ,1.0   ,15.0/ ! DMS
      DATA (CLASS(IC,227),IC=1,5)  /0.065 ,0.02   ,0.0   ,0.0   ,0.0 / ! CH3BR
      DATA (CLASS(IC,228),IC=1,5)  /37.1  ,5.9    ,0.0   ,2.4   ,8.2 / ! NH3
      DATA (CLASS(IC,247),IC=1,5)  /0.00  ,0.0    ,0.0   ,0.0   ,0.0 / ! FTOH
       DATA (CLASS(IC,248),IC=1,5)  /0.000  ,0.0  ,0.0   ,0.0  ,0.0 / ! PFOA
       DATA (CLASS(IC,218),IC=1,5)  /12.3  ,52.48  ,0.0   ,0.0  ,0.0 / ! EMPOA
C      DATA (CLASS(IC,4),IC=1,5)   /21.0  ,8.0    ,0.0   ,5.6   ,0.0 / ! NOX
C      DATA (CLASS(IC,8),IC=1,5)   /425.0 ,500.0  ,75.0  ,0.0   ,50.0/ ! CO
C      DATA (CLASS(IC,9),IC=1,5)   /155.0 ,40.0   ,0.0   ,0.0   ,10.0/ ! CH4
C      DATA (CLASS(IC,10),IC=1,5)  /1.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! HCHO
C      DATA (CLASS(IC,12),IC=1,5)  /20.0  ,20.0   ,0.0   ,5.0   ,5.0 / ! H2
C      DATA (CLASS(IC,17),IC=1,5)  /6.0   ,6.5    ,3.5   ,0.0   ,0.0 / ! C2H6
C      DATA (CLASS(IC,19),IC=1,5)  /0.3   ,0.0    ,0.0   ,0.0   ,0.0 / ! CH3CHO
C      DATA (CLASS(IC,23),IC=1,5)  /47.0  ,2.0    ,8.0   ,0.0   ,0.0 / ! C4H10
C      DATA (CLASS(IC,26),IC=1,5)  /65.1  ,2.2    ,0.0   ,0.0   ,0.0 / ! SO2
C      DATA (CLASS(IC,27),IC=1,5)  /17.0  ,10.0   ,20.0  ,0.0   ,0.0 / ! C2H4
C      DATA (CLASS(IC,28),IC=1,5)  /21.0  ,5.0    ,20.0  ,0.0   ,0.0 / ! C3H6
C      DATA (CLASS(IC,29),IC=1,5)  /4.7   ,0.0    ,0.0   ,0.0   ,0.0 / ! OXYL
C      DATA (CLASS(IC,31),IC=1,5)  /6.0   ,6.5    ,3.5   ,0.0   ,0.0 / ! C3H8
C      DATA (CLASS(IC,36),IC=1,5)  /3.8   ,6.0    ,0.0   ,0.0   ,0.0 / ! METHANOL
C      DATA (CLASS(IC,37),IC=1,5)  /2.7   ,0.0    ,0.0   ,0.0   ,0.0 / ! ACETONE
C      DATA (CLASS(IC,48),IC=1,5)  /0.0   ,0.0    ,506.0 ,0.0   ,0.0 / ! C5H8
C      DATA (CLASS(IC,54),IC=1,5)  /14.0  ,0.0    ,0.0   ,0.0   ,0.0 / ! TOLUENE
C      DATA (CLASS(IC,60),IC=1,5)  /0.0   ,0.0    ,0.0   ,1.0   ,15.0/ ! DMS
C      DATA (CLASS(IC,61),IC=1,5)  /0.065 ,0.02   ,0.0   ,0.0   ,0.0 / ! CH3BR
C      DATA (CLASS(IC,70),IC=1,5)  /37.1  ,5.9    ,0.0   ,2.4   ,8.2 / ! NH3
C -PRE INDUSTRIAL
C      DATA (CLASS(IC,8),IC=1,5)   /0.0   ,1.6    ,0.0   ,5.6   ,0.0 / ! NOX
C      DATA (CLASS(IC,11),IC=1,5)   /0.0   ,160.0  ,75.0  ,0.0   ,50.0/ ! CO
C      DATA (CLASS(IC,21),IC=1,5)   /0.0   ,8.0    ,0.0   ,0.0   ,10.0/ ! CH4
C      DATA (CLASS(IC,31),IC=1,5)  /0.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! HCHO
C      DATA (CLASS(IC,10),IC=1,5)  /0.0   ,4.0    ,0.0   ,5.0   ,5.0 / ! H2
C      DATA (CLASS(IC,23),IC=1,5)  /0.0   ,6.5    ,3.5   ,0.0   ,0.0 / ! C2H6
C      DATA (CLASS(IC,42),IC=1,5)  /0.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! CH3CHO
C      DATA (CLASS(IC,28),IC=1,5)  /0.0   ,0.4    ,8.0   ,0.0   ,0.0 / ! C4H10
C      DATA (CLASS(IC,16),IC=1,5)  /0.0   ,0.4    ,0.0   ,0.0   ,15.0/ ! SO2
C      DATA (CLASS(IC,30),IC=1,5)  /0.0   ,2.0    ,20.0  ,0.0   ,0.0 / ! C2H4
C      DATA (CLASS(IC,32),IC=1,5)  /0.0   ,1.0    ,20.0  ,0.0   ,0.0 / ! C3H6
C      DATA (CLASS(IC,67),IC=1,5)  /0.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! OXYL
C      DATA (CLASS(IC,43),IC=1,5)  /0.0   ,0.0    ,506.0 ,0.0   ,0.0 / ! C5H8
C      DATA (CLASS(IC,64),IC=1,5)  /0.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! TOLUENE
c      DATA (CLASS(IC,61),IC=1,5)  /0.0   ,0.0    ,0.0   ,0.0   ,0.0 / ! BENZENE
C
C Get EMISS in units (molecules s^-1 per grid square)
      CALL EMREAD(EMISS,CLASS)

C Add seasonal variations in biomass burning, soil & vegetation emissions

      CALL EMUPDT(EMISS,CLASS,MONTH)
C      DVLAND(4) =1.0
C      DVSEA(4)=0.5
C Convert emissions to (molecules s^-1) per grid square / (molecules/cell)
C                                         !
      DO 27 K=1,NC                        !
        DO 27 I=1,NLONG                  !V!
          DO 27 J=1,MNLAT
C Don't scale O3 and HNO3 (already done in STRATCALC)
            IF(K.NE.6.AND.K.NE.14) EMISS(K,I,J)=EMISS(K,I,J)/LMOLEC
            IF(K.EQ.43) THEN ! Isoprene
              EMISS(43,I,J)=EMISS(43,I,J)*ISOPRE(MONTH,I,J)
            ENDIF
C Deposition velocities
            DDEPO(K,I,J)=DVLAND(K)*LAND(I,J)+DVSEA(K)*(1-LAND(I,J))
   27 CONTINUE
C      PRINT *,'LMOLEC=',LMOLEC
C      PRINT *,'EMISS(43)=',EMISS(43,13,5)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE DWCALC(DW,ADP,ACP,CT,IPOS,POS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculate wet deposition rates
C-
C-   Inputs  : ADP,ACP,CT,       ! dynamic & convective ppn, convective
C                                ! cloud top, eta level.
C-   Outputs : DW  (1/s)
C-   Controls: Scavenging coeffs.
C-
C-   Created:   Colin Johnson  6-FEB-1996
C-   Modified:  Colin Johnson 30-JUL-1996  To treat entire array DW(NC,NBLOCK)
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
C-
      INTEGER IHR
      INTEGER IPOS(5,NBLOCK),I,JB,IM,JM
      REAL DTS
      REAL ACP(NMETLONG,NMETLAT,1),
     &     ADP(NMETLONG,NMETLAT,1),
     &     CT(NMETLONG,NMETLAT,1)
      REAL POS(3,NBLOCK)
      REAL DF,CF,ETA,CPROFILE
      REAL DSC(NC),CSC(NC),DW(NBLOCK,NC),RJ(NC),DPROFILE(NLEV)
C-
C      non-zero values of scavenging coefficient (1/cm)
C      Penner, Atherton & Graedel (1994).
C      species    large scale  convective
C      HCHO         2.0          4.0
C      HNO3         2.4          4.7
C      N2O5         1.0          2.0
C      H2O2         2.4          4.7
C      ROOH         2.0          4.0
C      SO2          0.8          1.5
C      SA,MSA       5.0          1.5
C      NAER         5.0          1.0
C      EMPOA        5.0          1.0
c      P2604        5.0      1.0     204
c      P4608        5.0      1.0     205
c      P2631        5.0      1.0     206
c      P2635        5.0      1.0     207
c      P4610        5.0      1.0     208
c      P2605        5.0      1.0     209
c      P2630        5.0      1.0     210
c      P2629        5.0      1.0     211
c      P2632        5.0      1.0     212
c      P2637        5.0      1.0     213
c      P3612        5.0      1.0     214
c      P3613        5.0      1.0     215
c      P3442        5.0      1.0     216
c      P2007        5.0      1.0     219
C
c      DATA DSC,CSC /NC*0.,NC*0./
C
      DATA DSC(7) ,CSC(7)    / 1.0,  2.0 / ! N2O5
      DATA DSC(12),CSC(12)   / 2.4,  4.7 / ! H2O2
      DATA DSC(13),CSC(13)   / 1.5,  3.0 / ! HONO
      DATA DSC(14),CSC(14)   / 2.4,  4.7 / ! HNO3
      DATA DSC(16),CSC(16)   / 0.8,  1.5 / ! SO2
      DATA DSC(19),CSC(19)   / 5.0,  1.0 / ! NAER
      DATA DSC(20),CSC(20)   / 5.0,  1.5 / ! SA
      DATA DSC(39),CSC(39)   / 2.0,  4.0 / ! HCHO
      DATA DSC(40),CSC(40)   / 2.0,  4.0/ ! HCOOH
      DATA DSC(41),CSC(41)   / 2.0,  4.0/ ! CH3COOH
      DATA DSC(144),CSC(144) / 2.0,  4.0/ ! CH3OOH
      DATA DSC(145),CSC(145) / 2.0,  4.0/ ! C2H5OOH
      DATA DSC(147),CSC(147) / 2.0,  4.0/ ! C3H7OOH
      DATA DSC(204),CSC(204) / 5.0,  1.0/ ! P2604
      DATA DSC(205),CSC(205) / 5.0,  1.0/ ! P4608
      DATA DSC(206),CSC(206) / 5.0,  1.0/ ! P2631
      DATA DSC(207),CSC(207) / 5.0,  1.0/ ! P2635
      DATA DSC(208),CSC(208) / 5.0,  1.0/ ! P4610
      DATA DSC(209),CSC(209) / 5.0,  1.0/ ! P2605
      DATA DSC(210),CSC(210) / 5.0,  1.0/ ! P2630
      DATA DSC(211),CSC(211) / 5.0,  1.0/ ! P2629
      DATA DSC(212),CSC(212) / 5.0,  1.0/ ! P2632
      DATA DSC(213),CSC(213) / 5.0,  1.0/ ! P2637
      DATA DSC(214),CSC(214) / 5.0,  1.0/ ! P3612
      DATA DSC(215),CSC(215) / 5.0,  1.0/ ! P3613
      DATA DSC(216),CSC(216) / 5.0,  1.0/ ! P3442
      DATA DSC(218),CSC(218) / 5.0,  1.0/ ! EMPOA
      DATA DSC(219),CSC(219) / 5.0,  1.0/ ! P2007
      DATA DSC(226),CSC(226) / 5.0,  1.5/ ! MSA
      DATA DSC(228),CSC(228) / 2.4,  4.7/ ! NH3?
      DATA DSC(248),CSC(248) / 1.9,  3.8/ ! PFOA
      DATA DSC(296),CSC(296) / 5.0,  1.0/ ! P1001
      DATA DSC(297),CSC(297) / 5.0,  1.0/ ! P1002
      DATA DSC(298),CSC(298) / 5.0,  1.0/ ! P1003
      DATA DSC(299),CSC(299) / 5.0,  1.0/ ! P1004
      DATA DSC(300),CSC(300) / 5.0,  1.0/ ! P1005
      DATA DSC(301),CSC(301) / 5.0,  1.0/ ! P1006
      DATA DSC(302),CSC(302) / 5.0,  1.0/ ! P1007
      DATA DSC(303),CSC(303) / 5.0,  1.0/ ! P1008
      DATA DSC(304),CSC(304) / 5.0,  1.0/ ! P1009
      DATA DSC(305),CSC(305) / 5.0,  1.0/ ! P1010
      DATA DSC(306),CSC(306) / 5.0,  1.0/ ! P1011
      DATA DSC(307),CSC(307) / 5.0,  1.0/ ! P1012
      DATA DSC(308),CSC(308) / 5.0,  1.0/ ! P1013
      DATA DSC(309),CSC(309) / 5.0,  1.0/ ! P1014
      DATA DSC(310),CSC(310) / 5.0,  1.0/ ! P1015
      DATA DSC(311),CSC(311) / 5.0,  1.0/ ! P1016
      DATA DSC(312),CSC(312) / 5.0,  1.0/ ! P1017
      DATA DSC(313),CSC(313) / 5.0,  1.0/ ! P1018
      DATA DSC(314),CSC(314) / 5.0,  1.0/ ! P1019
      DATA DSC(315),CSC(315) / 5.0,  1.0/ ! P1020
      DATA DSC(316),CSC(316) / 5.0,  1.0/ ! P1021
      DATA DSC(317),CSC(317) / 5.0,  1.0/ ! P1022
      DATA DSC(318),CSC(318) / 5.0,  1.0/ ! P1023
      DATA DSC(319),CSC(319) / 5.0,  1.0/ ! P1024
      DATA DSC(320),CSC(320) / 5.0,  1.0/ ! P1025
      DATA DSC(321),CSC(321) / 5.0,  1.0/ ! P1026
      DATA DSC(322),CSC(322) / 5.0,  1.0/ ! P1027
      DATA DSC(323),CSC(323) / 5.0,  1.0/ ! P1028
      DATA DSC(324),CSC(324) / 5.0,  1.0/ ! P1029
      DATA DSC(325),CSC(325) / 5.0,  1.0/ ! P1030
      DATA DSC(326),CSC(326) / 5.0,  1.0/ ! P1031
      DATA DSC(327),CSC(327) / 5.0,  1.0/ ! P1032
      DATA DSC(328),CSC(328) / 5.0,  1.0/ ! P1033
      DATA DSC(329),CSC(329) / 5.0,  1.0/ ! P1034
      DATA DSC(330),CSC(330) / 5.0,  1.0/ ! P1035
      DATA DSC(331),CSC(331) / 5.0,  1.0/ ! P1036
      DATA DSC(332),CSC(332) / 5.0,  1.0/ ! P1037
      DATA DSC(333),CSC(333) / 5.0,  1.0/ ! P1038
      DATA DSC(334),CSC(334) / 5.0,  1.0/ ! P1039
      DATA DSC(335),CSC(335) / 5.0,  1.0/ ! P1040
      DATA DSC(336),CSC(336) / 5.0,  1.0/ ! P1041
      DATA DSC(337),CSC(337) / 5.0,  1.0/ ! P1042
      DATA DSC(338),CSC(338) / 5.0,  1.0/ ! P1043
      DATA DSC(339),CSC(339) / 5.0,  1.0/ ! P1044
      DATA DSC(340),CSC(340) / 5.0,  1.0/ ! P1045
      DATA DSC(341),CSC(341) / 5.0,  1.0/ ! P1046
      DATA DSC(342),CSC(342) / 5.0,  1.0/ ! P1047
c      DATA DSC(35),CSC(35) / 2.0,  4.0/  ! C4H9OOH
c      DATA DSC(52),CSC(52) / 2.0,  4.0/  ! ISOPOOH
c      DATA DSC(53),CSC(53) / 2.0,  4.0/  ! MVKOOH
c      DATA DSC(69),CSC(69) / 5.0,  1.0/  ! ORGNIT?
C      DATA DSC(204),CSC(204) / 0.0,  0.0/ ! P2604
C      DATA DSC(205),CSC(205) / 0.0,  0.0/ ! P4608
C      DATA DSC(206),CSC(206) / 0.0,  0.0/ ! P2631
C      DATA DSC(207),CSC(207) / 0.0,  0.0/ ! P2635
C      DATA DSC(208),CSC(208) / 0.0,  0.0/ ! P4610
C      DATA DSC(209),CSC(209) / 0.0,  0.0/ ! P2605
C      DATA DSC(210),CSC(210) / 0.0,  0.0/ ! P2630
C      DATA DSC(211),CSC(211) / 0.0,  0.0/ ! P2629
C      DATA DSC(212),CSC(212) / 0.0,  0.0/ ! P2632
C      DATA DSC(213),CSC(213) / 0.0,  0.0/ ! P2637
C      DATA DSC(214),CSC(214) / 0.0,  0.0/ ! P3612
C      DATA DSC(215),CSC(215) / 0.0,  0.0/ ! P3613
C      DATA DSC(216),CSC(216) / 0.0,  0.0/ ! P3442
C      DATA DSC(218),CSC(218) / 0.0,  0.0/ ! EMPOA
C      DATA DSC(219),CSC(219) / 0.0,  0.0/ ! P2007


C      DATA DSC/  0., 0., 0., 0., 0., 0.,1.0, 0., 0.,2.0,
C     &           0., 0.,2.4,2.4, 0., 0., 0., 0., 0., 0.,
C     &           0.,2.0, 0., 0., 0.,0.8, 0., 0., 0.,5.0,
C     &           0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
C     &           0., 0., 0., 0., 0., 0., 0., 0.,5.0, 0./
C
C      DATA CSC/  0., 0., 0., 0., 0., 0.,2.0, 0., 0.,4.0,
C     &           0., 0.,4.7,4.7, 0., 0., 0., 0., 0., 0.,
C     &           0.,4.0, 0., 0., 0.,1.5, 0., 0., 0.,1.5,
C     &           0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
C     &           0., 0., 0., 0., 0., 0., 0., 0.,1.0, 0./
C
      DATA DF /1.0/       !Assumed fraction of cell affected by dynamic ppn.
      DATA CF /0.3/       !Assumed fraction of cell affected by convective ppn.
C      Assumed dynamic rainfall profile:
      DATA DPROFILE /1.0,1.0,0.78,0.56,0.33,0.11,0.0,0.0,0.0/
C
      DTS=3*3600. ! 3 hour correlation period
      DO 300 JB=1,NBLOCK
        IM=INT(POS(1,JB)/DLONGM+1.0)       ! Indicies for met. grids
        JM=INT(POS(2,JB)/DLATM+1.0)
        DO I=1,NC
          DW(JB,I)=0.0
        ENDDO
        ETA=0.85-REAL(IPOS(5,JB)-2)*0.1
C      Dynamic ppn.
        IF(ADP(IM,JM,1).GT.1E-08.AND.ETA.GT.0.4) THEN
C      The factor of 10.0 converts ppn. from kg/(m^2.s) to cm/s.
          DO I=1,NC
            RJ(I)=DSC(I)*ADP(IM,JM,1)*DPROFILE(IPOS(5,JB))/(DF*10.0)
            DW(JB,I)=RJ(I)
            DW(JB,I)=DW(JB,I)-ALOG(1.-(CF-CF*EXP(-DTS*RJ(I)/CF))/DTS)
C             IF(I.EQ.218)
C     &       WRITE(6,*)'DW EMPOA1=',DW(JB,I),POS(3,JB)
C            WRITE(6,*) DPPN,DSC(I),DPROFILE(IPOS(5,JB)),DW(JB,I)
          ENDDO
        ENDIF
C      Convective ppn: Ppn. profile 1.0 below eta=0.85, then declines linearly.
        IF(ACP(IM,JM,1).GT.1.0E-08.AND.ETA.GT.CT(IM,JM,1)) THEN
          IF(IPOS(5,JB).LE.2) THEN
            CPROFILE=1.0
          ELSE
            CPROFILE=1.0-((0.85-ETA)/(0.85-CT(IM,JM,1)))
          ENDIF
C          WRITE(6,*) IPOS(5,JB),ETA,CTOP,CPROFILE
          DO I=1,NC
            RJ(I)=CSC(I)*ACP(IM,JM,1)*CPROFILE/(CF*10.0)
            DW(JB,I)=DW(JB,I)-ALOG(1.-(CF-CF*EXP(-DTS*RJ(I)/CF))/DTS)        
c             IF(I.EQ.218)
c     &       WRITE(6,*)'DW EMPOA=',DW(JB,I),POS(3,JB)
          ENDDO
        ENDIF
  300 CONTINUE
C
  999 RETURN
      END

C#######################################################################
      SUBROUTINE DDCALC(DD,DDEPO,IPOS,POS,TL,BL,VA)

C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculate dry depostion rates
C-
C-   Inputs  : DDEPO,IPOS,NC,NLONG,MNLAT,BL,VA,ETA,TL
C-   Outputs : DD
C-   Controls:
C-
C-   Created   6-JAN-1994   W.J. Collins
C-   Updated   7-MAR-1995   Bill Collins  B.L. now passed as eta value.
C-   Updated  15-MAY-1995   Bill Collins  Added calculation of aerodynamic
C-                                        velocity (VA).
C-   Updated  11-JUL-1996   Bill Collins  VA now passed as a parameter
C-   Modified 29-JUL-1996   Colin Johnson To use NBLOCK dimensioned arrays
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,K,L,JB,IM,JM,IPOS(5,NBLOCK)
      REAL DDEPO(NC,NLONG,MNLAT),DD(NBLOCK,NC),TL(NBLOCK)
      REAL VD,POS(3,NBLOCK),H
      REAL BL(NMETLONG,NMETLAT,1)
      REAL VA(NMETLONG,NMETLAT,1)
C
      DO 400 JB=1,NBLOCK
        IM=INT(POS(1,JB)/DLONGM+1.0)       ! Indicies for met. grids
        JM=INT(POS(2,JB)/DLATM+1.0)
        I=IPOS(1,JB)
        L=IPOS(2,JB)
C Calculate B.L. Height (mm). Eta=p/p0 for eta>.8
C   For BL in metres:
C        H=BL(IM,JM,1)*1.0E3
C   For BL in eta units:
        H=-1E3*ALOG(BL(IM,JM,1))*RGC*TL(JB)/(G*MAIR*1E-3)
        IF(H.LT.0.1) WRITE(6,*) ' *** DDCALC: H < 0.1  IM,JM,JB = ',
     &       IM,JM,JB,' BL = ',BL(IM,JM,1),' TL = ',TL(JB)
        DO 300 K=1,NC
          IF(POS(3,JB).GT.BL(IM,JM,1)) THEN
C Add in parallel
            VD=DDEPO(K,I,L)*VA(IM,JM,1)/
     &                  (DDEPO(K,I,L)+VA(IM,JM,1))
            DD(JB,K)=VD/H
C            IF(K.EQ.218.AND.DD(JB,K).GT.0.0)
C     &       WRITE(6,*)'DD EMPOA=',DD(JB,K),POS(3,JB)
c            WRITE(61,*) VD,DDEPO(K,I,L),VA(IM,JM,1),H,DD,K
          ELSE
            DD(JB,K)=0.
          ENDIF
  300   CONTINUE
  400 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE STORE(ESTORE,EMISS,NNN,NBL,TIME,MONTH)

C----------------------------------------------------------------------
C-
C-   Purpose and Methods : STORE EMISSIONS IF NO CELLS ARE PRESENT
C-
C-   Inputs  : EMISS,NNN
C-   Outputs : ESTORE
C-   Controls:
C-
C-   Created   9-DEC-1993   W.J. Collins
C-   Updated   6-dec 1994   David Stevenson to store empty top layer
C-                          o3 & hno3 emissions
C-   Updated   8-MAR-1995   Bill Collins Now looks to see if there are any cells
C-                          in the boundary layer
C-   Updated  10-MAR-1995   Bill Collins  Don't store isoprene if it is night
C-   Replaced 25-JUL-1995   From Bill Collins, updates to species list, C.E.J
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated  30-JUN-1998   Bill Collins  Rearrangement of logic. 
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NNN(NLONG,MNLAT,NLEV),I,J,K,NBL(NLONG,MNLAT)
      REAL ESTORE(NC,NLONG,MNLAT),EMISS(NC,NLONG,MNLAT)
      DOUBLE PRECISION TIME,TI
      INTEGER MONTH,SECS
      REAL ZEN,THET
C
C      FIND grid boxes IN boundary LAYER with no cells (not O3 or HNO3)
C    + FIND grid boxes IN top LAYER with no cells (O3 & HNO3)
C
      DO K=1,NC
        DO I=1,NLONG
          DO J=1,MNLAT
            IF(K.EQ.6.OR.K.EQ.14) THEN
C check for cells in top level for stratospheric emissions
              IF (NNN(I,J,9).EQ.0.)THEN
                ESTORE(K,I,J)=ESTORE(K,I,J)+EMISS(K,I,J)
              ELSE
                ESTORE(K,I,J)=0.
              ENDIF
            ELSE IF(K.NE.43) THEN
C not ISOPRENE
              IF(NBL(I,J).EQ.0) THEN
                ESTORE(K,I,J)=ESTORE(K,I,J)+EMISS(K,I,J)
              ELSE
                ESTORE(K,I,J)=0.
              ENDIF
            ELSE
C TEST TO SEE IF IT IS DAYTIME FOR ISOPRENE EMISSIONS
              TI=SECS(15,MONTH,1)+DMOD(TIME,86400.D0)
              THET=ZEN(TI,90.-((J-.5)*180.)/MNLAT,((I-.5)*360.)/NLONG)
              IF(NBL(I,J).EQ.0) THEN
                ESTORE(K,I,J)=ESTORE(K,I,J)+EMISS(K,I,J)*
     &            MAX(COS(THET),0.) ! i.e. set to 0. if COS(THET) -ve
              ELSE
                ESTORE(K,I,J)=0.
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      SUBROUTINE EMUPDT(EMISS,CLASS,MONTH)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN EMISSIONS DATA
C-
C-   Inputs  :
C-   Outputs : EMISS
C-   Controls:
C-
C-   Created  10-JAN-1994   Bill Collins
C-   Updated  27-APR-1994   Bill Collins  Removed biomass burning terms from
C-                                        ethane, ethylene and propylene. These
C-                                        are now in EMREAD
C-   Updated   8-MAR-1995   Bill Collins  Added termite emission to CH4
C-   Updated   2-JUN-1995   Colin Johnson To reflect new species order.
C-   Updated  28-JUN-1995   Colin Johnson Added ocean emission of CO.
C-   Updated   9-JAN-1996   Bill Collins  Use GEIA emissions + new ethane
C-   Updated  10-JAN-1996   Bill Collins  Use tabulated emission classes
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER MONTH
      REAL EMISS(NC,NLONG,MNLAT)
      CHARACTER*2 SMONTH
      REAL BURN(NLONG,MNLAT),VEG(NLONG,MNLAT),SOIL(NLONG,MNLAT),
     &  OCEAN(NLONG,MNLAT),ISOP(NLONG,MNLAT),SOILNOX(NLONG,MNLAT)
      INTEGER I,J,I1,J1
      REAL CLASS(5,NC)
C
C Write month digit(s) into string
      WRITE(SMONTH,201) MONTH
C      SMONTH='1'  !this is a fudge to use just 1 months data  (1=1-18/11/93)
      PRINT *,'>'//SMONTH//'<'
      OPEN(21,FILE=EMDIR//'irn_big.s'//SMONTH,
     &  STATUS='OLD')
      READ(21,100) BURN
      CLOSE(21)
      OPEN(22,FILE=EMDIR//'iol_big.d'//SMONTH,
     &  STATUS='OLD')
      READ(22,100) SOIL
      CLOSE(22)
      OPEN(22,FILE=EMDIR//'solnox'//SMONTH//'.dat',
     &  STATUS='OLD')
      READ(22,*) SOILNOX ! In moles
      CLOSE(22)
      OPEN(23,FILE=EMDIR//'ieg_big.d'//SMONTH,
     &  STATUS='OLD')
      READ(23,100) VEG
      CLOSE(23)
      OPEN(23,FILE=EMDIR//'iea_big.d'//SMONTH,
     &  STATUS='OLD')
      READ(23,100) OCEAN
      CLOSE(23)
      OPEN(23,FILE=EMDIR//'isop'//SMONTH//'.dat',
     &  STATUS='OLD')
      READ(23,*) ISOP ! In g Carbon
      CLOSE(23)
      DO 10 J=1,MNLAT
        J1=MNLAT+1-J
        DO 20 I=1,NLONG
          I1=MOD(I+NLONG/2-1,NLONG)+1
C NOx
          EMISS(8,I,J)=EMISS(8,I,J)+
     &      (CLASS(2,8)*BURN(I1,J1)+
     &      CLASS(3,8)*VEG(I1,J1)+
     &      (CLASS(4,8)/5.6)*SOILNOX(I1,J1)*14/1E12+
     &      CLASS(5,8)*OCEAN(I1,J1))*1E12*NA/(14.0*31536000.0)
C EMPOA
          EMISS(218,I,J)=EMISS(218,I,J)+
     &      (CLASS(2,218)*BURN(I1,J1)+
     &      CLASS(3,218)*VEG(I1,J1)+
     &      (CLASS(4,218)/5.6)*SOILNOX(I1,J1)*13.2/1E12+
     &      CLASS(5,218)*OCEAN(I1,J1))*1E12*NA/(13.2*31536000.0)
C SO2
          EMISS(16,I,J)=EMISS(16,I,J)+
     &      (CLASS(2,16)*BURN(I1,J1)+
     &      CLASS(3,16)*VEG(I1,J1)+
     &      CLASS(4,16)*SOIL(I1,J1)+
     &      CLASS(5,16)*OCEAN(I1,J1))*1E12*NA/(32.0*31536000.0)
C CO
          EMISS(11,I,J)=EMISS(11,I,J)+
     &      (CLASS(2,11)*BURN(I1,J1)+
     &      CLASS(3,11)*VEG(I1,J1)+
     &      CLASS(4,11)*SOIL(I1,J1)+
     &      CLASS(5,11)*OCEAN(I1,J1))*1E12*NA/(28.0*31536000.0)
C CH4  20 Tg/yr termites (=vegetation)
C mcc update based on Mikaloff Fletcher et. al. termites = 16 Tg/yr
          EMISS(21,I,J)=EMISS(21,I,J)+
     &      (CLASS(2,21)*BURN(I1,J1)+
     &      (CLASS(3,21)+16.)*VEG(I1,J1)+
     &      CLASS(4,21)*SOIL(I1,J1)+
     &      CLASS(5,21)*OCEAN(I1,J1))*1E12*NA/(16.0*31536000.0)
C C2H6
          EMISS(23,I,J)=EMISS(23,I,J)+
     &      (CLASS(2,23)*BURN(I1,J1)+
     &      CLASS(3,23)*VEG(I1,J1)+
     &      CLASS(4,23)*SOIL(I1,J1)+
     &      CLASS(5,23)*OCEAN(I1,J1))*1E12*NA/(30.0*31536000.0)
C C3H8
          EMISS(25,I,J)=EMISS(25,I,J)+
     &      (CLASS(2,25)*BURN(I1,J1)+
     &      CLASS(3,25)*VEG(I1,J1)+
     &      CLASS(4,25)*SOIL(I1,J1)+
     &      CLASS(5,25)*OCEAN(I1,J1))*1E12*NA/(44.0*31536000.0)
C C4H10
          EMISS(28,I,J)=EMISS(28,I,J)+
     &      (CLASS(2,28)*BURN(I1,J1)+
     &      CLASS(3,28)*VEG(I1,J1)+
     &      CLASS(4,28)*SOIL(I1,J1)+
     &      CLASS(5,28)*OCEAN(I1,J1))*1E12*NA/(58.0*31536000.0)
C CH3OH
          EMISS(76,I,J)=EMISS(76,I,J)+
     &      (CLASS(2,76)*BURN(I1,J1)+
     &      CLASS(3,76)*VEG(I1,J1)+
     &      CLASS(4,76)*SOIL(I1,J1)+
     &      CLASS(5,76)*OCEAN(I1,J1))*1E12*NA/(32.0*31536000.0)
C C2H4
          EMISS(30,I,J)=EMISS(30,I,J)+
     &      (CLASS(2,30)*BURN(I1,J1)+
     &      CLASS(3,30)*VEG(I1,J1)+
     &      CLASS(4,30)*SOIL(I1,J1)+
     &      CLASS(5,30)*OCEAN(I1,J1))*1E12*NA/(28.0*31536000.0)
C C3H6
          EMISS(32,I,J)=EMISS(32,I,J)+
     &      (CLASS(2,32)*BURN(I1,J1)+
     &      CLASS(3,32)*VEG(I1,J1)+
     &      CLASS(4,32)*SOIL(I1,J1)+
     &      CLASS(5,32)*OCEAN(I1,J1))*1E12*NA/(42.0*31536000.0)
C H2
          EMISS(10,I,J)=EMISS(10,I,J)+
     &      (CLASS(2,10)*BURN(I1,J1)+
     &      CLASS(3,10)*VEG(I1,J1)+
     &      CLASS(4,10)*SOIL(I1,J1)+
     &      CLASS(5,10)*OCEAN(I1,J1))*1E12*NA/(2.0*31536000.0)
C C5H8
          EMISS(43,I,J)=EMISS(43,I,J)+
     &      (CLASS(2,43)*BURN(I1,J1)+
     &      (CLASS(3,43)/501.0)*ISOP(I1,J1)*(68./60.)/1E12+
     &      CLASS(4,43)*SOIL(I1,J1)*
     &      CLASS(5,43)*OCEAN(I1,J1))*1E12*NA/(68.0*31536000.0)
C APINENE
          EMISS(47,I,J)=EMISS(47,I,J)+
     &      (CLASS(2,47)*BURN(I1,J1)+
     &      CLASS(3,47)*VEG(I1,J1)+
     &      CLASS(4,47)*SOIL(I1,J1)+
     &      CLASS(5,47)*OCEAN(I1,J1))*1E12*NA/(136.0*31536000.0)
C BPINENE
          EMISS(53,I,J)=EMISS(53,I,J)+
     &      (CLASS(2,53)*BURN(I1,J1)+
     &      CLASS(3,53)*VEG(I1,J1)+
     &      CLASS(4,53)*SOIL(I1,J1)+
     &      CLASS(5,53)*OCEAN(I1,J1))*1E12*NA/(136.0*31536000.0)
C HCHO
          EMISS(39,I,J)=EMISS(39,I,J)+
     &      (CLASS(2,39)*BURN(I1,J1)+
     &      CLASS(3,39)*VEG(I1,J1)+
     &      CLASS(4,39)*SOIL(I1,J1)+
     &      CLASS(5,39)*OCEAN(I1,J1))*1E12*NA/(30.0*31536000.0)
C CH3CHO
          EMISS(42,I,J)=EMISS(42,I,J)+
     &      (CLASS(2,42)*BURN(I1,J1)+
     &      CLASS(3,42)*VEG(I1,J1)+
     &      CLASS(4,42)*SOIL(I1,J1)+
     &      CLASS(5,42)*OCEAN(I1,J1))*1E12*NA/(44.0*31536000.0)
C O-XYL
          EMISS(67,I,J)=EMISS(67,I,J)+
     &      (CLASS(2,67)*BURN(I1,J1)+
     &      CLASS(3,67)*VEG(I1,J1)+
     &      CLASS(4,67)*SOIL(I1,J1)+
     &      CLASS(5,67)*OCEAN(I1,J1))*1E12*NA/(106.0*31536000.0)
C ACETONE
          EMISS(73,I,J)=EMISS(73,I,J)+
     &      (CLASS(2,73)*BURN(I1,J1)+
     &      CLASS(3,73)*VEG(I1,J1)+
     &      CLASS(4,73)*SOIL(I1,J1)+
     &      CLASS(5,73)*OCEAN(I1,J1))*1E12*NA/(58.0*31536000.0)
C TOLUENE
          EMISS(64,I,J)=EMISS(64,I,J)+
     &      (CLASS(2,64)*BURN(I1,J1)+
     &      CLASS(3,64)*VEG(I1,J1)+
     &      CLASS(4,64)*SOIL(I1,J1)+
     &      CLASS(5,64)*OCEAN(I1,J1))*1E12*NA/(92.0*31536000.0)
C BENZENE
          EMISS(61,I,J)=EMISS(61,I,J)+
     &      (CLASS(2,61)*BURN(I1,J1)+
     &      CLASS(3,61)*VEG(I1,J1)+
     &      CLASS(4,61)*SOIL(I1,J1)+
     &      CLASS(5,61)*OCEAN(I1,J1))*1E12*NA/(78.0*31536000.0)
C HCOOH
          EMISS(40,I,J)=EMISS(40,I,J)+
     &      (CLASS(2,40)*BURN(I1,J1)+
     &      CLASS(3,40)*VEG(I1,J1)+
     &      CLASS(4,40)*SOIL(I1,J1)+
     &      CLASS(5,40)*OCEAN(I1,J1))*1E12*NA/(46.0*31536000.0)
C CH3CO2H
          EMISS(41,I,J)=EMISS(41,I,J)+
     &      (CLASS(2,41)*BURN(I1,J1)+
     &      CLASS(3,41)*VEG(I1,J1)+
     &      CLASS(4,41)*SOIL(I1,J1)+
     &      CLASS(5,41)*OCEAN(I1,J1))*1E12*NA/(60.0*31536000.0)
C C2H5OH
          EMISS(77,I,J)=EMISS(77,I,J)+
     &      (CLASS(2,77)*BURN(I1,J1)+
     &      CLASS(3,77)*VEG(I1,J1)+
     &      CLASS(4,77)*SOIL(I1,J1)+
     &      CLASS(5,77)*OCEAN(I1,J1))*1E12*NA/(46.0*31536000.0)
C MEK
          EMISS(101,I,J)=EMISS(101,I,J)+
     &      (CLASS(2,101)*BURN(I1,J1)+
     &      CLASS(3,101)*VEG(I1,J1)+
     &      CLASS(4,101)*SOIL(I1,J1)+
     &      CLASS(5,101)*OCEAN(I1,J1))*1E12*NA/(72.0*31536000.0)
C C2H5CHO
          EMISS(71,I,J)=EMISS(71,I,J)+
     &      (CLASS(2,71)*BURN(I1,J1)+
     &      CLASS(3,71)*VEG(I1,J1)+
     &      CLASS(4,71)*SOIL(I1,J1)+
     &      CLASS(5,71)*OCEAN(I1,J1))*1E12*NA/(58.0*31536000.0)
C C2H2
          EMISS(59,I,J)=EMISS(59,I,J)+
     &      (CLASS(2,59)*BURN(I1,J1)+
     &      CLASS(3,59)*VEG(I1,J1)+
     &      CLASS(4,59)*SOIL(I1,J1)+
     &      CLASS(5,59)*OCEAN(I1,J1))*1E12*NA/(26.0*31536000.0)
C TBUT2ENE
          EMISS(34,I,J)=EMISS(34,I,J)+
     &      (CLASS(2,34)*BURN(I1,J1)+
     &      CLASS(3,34)*VEG(I1,J1)+
     &      CLASS(4,34)*SOIL(I1,J1)+
     &      CLASS(5,34)*OCEAN(I1,J1))*1E12*NA/(56.0*31536000.0)
C EMPOA
C          EMISS(218,I,J)=EMISS(218,I,J)+
C     &      (CLASS(2,218)*BURN(I1,J1)+
C     &      CLASS(3,218)*VEG(I1,J1)+
C     &      CLASS(4,218)*SOIL(I1,J1)+
C     &      CLASS(5,218)*OCEAN(I1,J1))*1E12*NA/(13.2*31536000.0)
C DMS
          EMISS(220,I,J)=EMISS(220,I,J)+
     &      (CLASS(2,220)*BURN(I1,J1)+
     &      CLASS(3,220)*VEG(I1,J1)+
     &      CLASS(4,220)*SOIL(I1,J1)+
     &      CLASS(5,220)*OCEAN(I1,J1))*1E12*NA/(32.0*31536000.0)
C CH3BR
          EMISS(227,I,J)=EMISS(227,I,J)+
     &      (CLASS(2,227)*BURN(I1,J1)+
     &      CLASS(3,227)*VEG(I1,J1)+
     &      CLASS(4,227)*SOIL(I1,J1)+
     &      CLASS(5,227)*OCEAN(I1,J1))*1E12*NA/(94.909*31536000.0)
C NH3
          EMISS(228,I,J)=EMISS(228,I,J)+
     &      (CLASS(2,228)*BURN(I1,J1)+
     &      CLASS(3,228)*VEG(I1,J1)+
     &      CLASS(4,228)*SOIL(I1,J1)+
     &      CLASS(5,228)*OCEAN(I1,J1))*1E12*NA/(14.0*31536000.0)
C FTOH
          EMISS(247,I,J)=EMISS(247,I,J)+
     &      (CLASS(2,247)*BURN(I1,J1)+
     &      CLASS(3,247)*VEG(I1,J1)+
     &      CLASS(4,247)*SOIL(I1,J1)+
     &      CLASS(5,247)*OCEAN(I1,J1))*1E12*NA/(464.0*31536000.0)
C PFOA
          EMISS(248,I,J)=EMISS(248,I,J)+
     &      (CLASS(2,248)*BURN(I1,J1)+
     &      CLASS(3,248)*VEG(I1,J1)+
     &      CLASS(4,248)*SOIL(I1,J1)+
     &      CLASS(5,248)*OCEAN(I1,J1))*1E12*NA/(414.0*31536000.0)
   20   CONTINUE
   10 CONTINUE
  100 FORMAT(6E12.4)
  200 FORMAT(I1)
  201 FORMAT(I2.2)
  999 RETURN
      END
C#######################################################################
      DOUBLE PRECISION FUNCTION MOLEC()
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE NUMBER OF MOLECULES IN A LAGRANGIAN
C-                         CELL
C-
C-   Inputs  :
C-   Outputs : MOLEC
C-   Controls:
C-
C-   Created   5-MAY-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
C-   Updated  30-JUN-1998   Bill Collins  Replaced NLEV with NLEV+1
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL TMASS,LMASS
C
      TMASS=1.0D3*(ETA3(1)-ETA3(NLEV+1))*1.0D02*
     &  (4.0*PI*(RADIUS*1.0D03)**2.0)/G
      LMASS=TMASS/NCELL
      MOLEC=LMASS*1.0D03*NA/MAIR
      WRITE(6,250) LMASS,MOLEC
  250 FORMAT(X,'LMASS: (kg) ',2E12.5,' molecules')
  999 RETURN
      END
C#######################################################################
      SUBROUTINE ZEROFL(TFLUX,TOTFLU,TOTAVG,NAVG)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : ZERO TFLUX ARRAY
C-
C-   Inputs  :
C-   Outputs : TFLUX
C-   Controls:
C-
C-   Created   6-MAY-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L,NAVG
      REAL TFLUX(NUM3DFLUX,NLONG,MNLAT,NLEV),TOTFLU(NUMFLUX),
     &     TOTAVG(NUMFLUX)
C
      DO 10 K=1,NLEV
        DO 20 J=1,MNLAT
          DO 30 I=1,NLONG
            DO 40 L=1,NUM3DFLUX
              TFLUX(L,I,J,K)=0.0D0
   40       CONTINUE
   30     CONTINUE
   20   CONTINUE
   10 CONTINUE
      DO L=1,NUMFLUX
        TOTFLU(L)=0.
        TOTAVG(L)=0.
      END DO
      NAVG=0
C
  999 RETURN
      END

C#######################################################################
      SUBROUTINE AINDEX(IPOS,POS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : RETURNS GRID INDICIES FOR A GRID POINT
C-
C-   Inputs  : POS
C-   Outputs : IPOS
C-   Controls:
C-
C-   Created   6-MAY-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5),HEIGHT
      REAL POS(3)
C
      IPOS(1) = INT(POS(1)/DLONG)+1
      IPOS(2) = INT(POS(2)/DLAT)+1
      IPOS(5) = HEIGHT(POS(3),ETA3)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE TOTAL(T,A,N)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATES GLOBAL TOTAL OF A FIELD
C-
C-   Inputs  : A,N
C-   Outputs : T
C-   Controls:
C-
C-   Created  11-MAY-1994   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER N
      REAL A(N,NLONG,MNLAT,NLEV),T(N)
      INTEGER I,J,K,L
      DO 10 I=1,N
        T(I)=0.0D0
        DO 20 L=1,NLEV
          DO 30 K=1,MNLAT
            DO 40 J=1,NLONG
              T(I)=T(I)+A(I,J,K,L)
   40       CONTINUE
   30     CONTINUE
   20   CONTINUE
   10 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE GETLIS(FLIST,FNAMES,NFLUX,CLIST,NCHEM,STLON,STLAT,
     &  NSTATION)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : GET LISTS OF FLUXES AND CHEMICAL SPECIES TO OUTPUT
C-
C-   Inputs  : 
C-   Outputs : FLIST,FNAMES,NFLUX,CLIST,NCHEM,STLON,STLAT,NSTATION
C-   Controls:
C-
C-   Created  30-JUN-1994   Bill Collins
C-   Updated   2-MAR-1995   Bill Collins  Pass array dimensions numchem and
C-                                        numflux.
C-   Modified 12-JUN-1995 Colin Johnson   To accept 8 character names.
C-   Modified 12-JUN-1995 Colin Johnson   FLIST now includes an integer
C-                                        '0 or 1' to determine array o/p.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated  25-FEB-1997   Bill Collins  Add station list 
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NFLUX,NCHEM,I,IERR,N3DFLUX,NSTATION
      INTEGER FLIST(2,NUMFLUX),CLIST(NUMCHEM)
      REAL STLON(NUMSTAT),STLAT(NUMSTAT)
      CHARACTER*40 FNAMES(NUMFLUX)
      CHARACTER*80 CSTRING
      CHARACTER*20 STNAMES(NUMSTAT)
C
      PRINT *,'READING CHEMICAL SPECIES LIST FOR OUTPUT'
      OPEN(40,FILE=DATDIR//'chem10_soa.dat',STATUS='OLD')
C      OPEN(40,FILE=datdir//'allchem.dat',STATUS='OLD')
      NCHEM=0
      IERR=0
      DO 10 WHILE(IERR.EQ.0.AND.NCHEM.LT.NC)
      READ(40,'(A80)',IOSTAT=IERR) CSTRING
      IF(IERR.EQ.0) THEN
        I=1
        DO 20 WHILE(I.LE.NC.AND.CSTRING(1:12).NE.CNAMES(I))
        I=I+1
   20 CONTINUE
      IF(I.LE.NC) THEN
        NCHEM=NCHEM+1
        CLIST(NCHEM)=I
      ENDIF
      ENDIF
   10 CONTINUE
      CLOSE(40)
C
      OPEN(41,FILE=DATDIR//'flux10_OH.dat',STATUS='OLD')
      NFLUX=0
      N3DFLUX=0
      IERR=0
      DO 30 WHILE(IERR.EQ.0.AND.NFLUX.LT.NUMFLUX)
      READ(41,'(A80)',IOSTAT=IERR) CSTRING
      IF(IERR.EQ.0) THEN
        IF(CSTRING(1:1).NE.'*') THEN
          NFLUX=NFLUX+1
          READ(CSTRING,'(A40)') FNAMES(NFLUX)
          READ(CSTRING(40:43),'(I4)') FLIST(1,NFLUX)
          READ(CSTRING(45:46),'(I2)') FLIST(2,NFLUX)
          IF(FLIST(2,NFLUX).GT.0) THEN
            N3DFLUX=N3DFLUX+1
            FLIST(2,NFLUX)=N3DFLUX
          ENDIF
        ENDIF
      ENDIF
   30 CONTINUE
      CLOSE(41)
      OPEN(42,FILE=DATDIR//'stat10_soa.dat',STATUS='OLD')
      NSTATION=0
      IERR=0
      DO 40 WHILE(IERR.EQ.0.AND.NSTATION.LT.NUMSTAT)
        READ(42,'(A80)',IOSTAT=IERR) CSTRING
        IF(IERR.EQ.0) THEN
          IF(CSTRING(1:1).NE.'*') THEN
            NSTATION=NSTATION+1
            READ(CSTRING,'(A20)') STNAMES(NSTATION)
            READ(CSTRING(21:30),'(F10.1)') STLON(NSTATION)
            READ(CSTRING(31:40),'(F10.1)') STLAT(NSTATION)
c            WRITE(61,*) STNAMES(NSTATION),STLON(NSTATION),STLAT(NSTATION)
          ENDIF
        ENDIF
   40 CONTINUE
      CLOSE(42)
      WRITE(60,*) NSTATION
      DO I=1,NSTATION
        WRITE(60,*) STNAMES(I)
      ENDDO
      WRITE(60,*) NCHEM
      DO I=1,NCHEM
        WRITE(60,*) CNAMES(CLIST(I))
      ENDDO
  999 RETURN
      END
C#######################################################################
      INTEGER FUNCTION SECS(IDAY,IMONTH,IYEAR)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Returns number of seconds since 0000Z June 21st,
C-                         no allowance for leap years.
C-   Inputs  : IDAY,IMONTH,IYEAR
C-   Outputs :
C-   Controls:
C-
C-   Created  31-AUG-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER IDAY,IMONTH,DAYS,IM,IYEAR,I
      INTEGER DAYM(12)
C NO. OF DAYS IN EACH MONTH.
      DATA DAYM /31,28,31,30,31,30,31,31,30,31,30,31/
      IM=IMONTH+12*IYEAR
C      IF(IMONTH.LT.6.OR.(IMONTH.EQ.6.AND.IDAY.LT.21)) IM=IM+12
      DAYS=0
      DO 10 I=6,IM-1
        DAYS=DAYS+DAYM(MOD(I-1,12)+1)
   10 CONTINUE
      DAYS=DAYS+IDAY-21
      SECS=DAYS*86400
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CELLBAL(NOXBAL,O3BAL,POS,NO0,NO20,HNO30,PAN0,NO30,
     &  N2O50,ORGNIT0,O30,CLINDX,TIME,ASTEP,DOBAL,TL,P0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Detailed NOx and O3 diagnostics for chosen cell(s)
C-
C-   Inputs  : pos,no0,no20,hno30,pan0,no30,n2o50,orgnit0,clindx,time,astep,
C-             dobal,tl,P0
C-   Outputs : noxbal,o3bal
C-   Controls:
C-
C-   Created   23-May-1994   D. Stevenson
C-   Updated    5 Oct 1994   D.S. (now calculates m within subroutine? -WJC)
C-   Updated   9-MAR-1995   Bill Collins  Calculate pressure properly.
C-   Updated   2-JUN-1995   Colin Johnson  New species list.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,DOBAL,CLINDX
      REAL NOXBAL(18),O3BAL(18)
      REAL POS(3)
      REAL NO0,NO20,HNO30,PAN0,NO30,N2O50,ORGNIT0,O30,M
      REAL TL,ASTEP
      DOUBLE PRECISION TIME
      REAL P0,ETA2P
      DOUBLE PRECISION
     & O1D         ,O           ,OH          , NO2         ,
     & NO3         , O3          ,N2O5        ,NO          ,
     & HO2         ,H2          , CO          , H2O2        ,
     & HONO        , HNO3        , HO2NO2      , SO2         ,
     & SO3         , HSO3        , NAER          , SA          ,
     & CH4         , CH3O2       , C2H6        , C2H5O2      ,
     & C3H8        , IC3H7O2     , RN10O2      , NC4H10      ,
     & RN13O2      , C2H4        , HOCH2CH2O2  , C3H6        ,
     & RN9O2       , TBUT2ENE    , RN12O2      , NRN6O2      ,
     & NRN9O2      , NRN12O2     , HCHO        , HCOOH       ,
     & CH3CO2H     , CH3CHO      , C5H8        , RU14O2      ,
     & NRU14O2     , UCARB10     , APINENE     , RTN28O2     ,
     & NRTN28O2    , RTN26O2     , TNCARB26    , RCOOH25    ,
     & BPINENE     , RTX28O2     , NRTX28O2    , RTX24O2     ,
     & TXCARB24    , TXCARB22    , C2H2        , CARB3       ,
     & BENZENE     , RA13O2      , AROH14      , TOLUENE     ,
     & RA16O2      , AROH17      , OXYL        , RA19AO2     ,
     & RA19CO2     , CH3CO3      , C2H5CHO     , C2H5CO3     ,
     & CH3COCH3    , RN8O2       , RN11O2      , CH3OH       ,
     & C2H5OH      , NPROPOL     , IPROPOL     , CH3CL       ,
     & CH2CL2      , CHCL3       , CH3CCL3     , TCE         ,
     & TRICLETH    , CDICLETH    , TDICLETH    , CARB11A     ,
     & RN16O2      , RN15AO2     , RN19O2      , RN18AO2     ,
     & RN13AO2     , RN16AO2     , RN15O2      , UDCARB8     ,
     & UDCARB11    , CARB6       , UDCARB14    , CARB9       ,
     & MEK        ,
     & HOCH2CHO    , RN18O2      , CARB13      , CARB16      ,
     & HOCH2CO3    , RN14O2      , RN17O2      , UCARB12     ,
     & RU12O2      , CARB7       , RU10O2      , NUCARB12    ,
     & NRU12O2     , NOA         , RTN25O2     , RTN24O2     ,
     & RTN23O2     , RTN14O2     , TNCARB10    , RTN10O2     ,
     & RTX22O2     , CH3NO3      , C2H5NO3     , RN10NO3     ,
     & IC3H7NO3    , RN13NO3     , RN16NO3     , RN19NO3     ,
     & HOC2H4NO3   , RN9NO3      , RN12NO3     , RN15NO3     ,
     & RN18NO3     , RU14NO3     , RA13NO3     , RA16NO3     ,
     & RA19NO3     , RTN28NO3    , RTN25NO3    , RTX28NO3    ,
     & RTX24NO3    , RTX22NO3    , CH3OOH      , C2H5OOH     ,
     & RN10OOH     , IC3H7OOH    , RN13OOH     , RN16OOH     ,
     & RN19OOH     , RA13OOH     , RA16OOH    ,
     & RA19OOH     , HOC2H4OOH   , RN9OOH      , RN12OOH     ,
     & RN15OOH     , RN18OOH     , CH3CO3H     , C2H5CO3H    ,
     & HOCH2CO3H   , RN8OOH      , RN11OOH     , RN14OOH     ,
     & RN17OOH     , RU14OOH     , RU12OOH     , RU10OOH     ,
     & NRN6OOH     , NRN9OOH     , NRN12OOH    , NRU14OOH    ,
     & NRU12OOH    , RTN28OOH    , NRTN28OOH   , RTN26OOH    ,
     & RTN25OOH    , RTN24OOH    , RTN23OOH    , RTN14OOH    ,
     & RTN10OOH    , RTX28OOH    , RTX24OOH    , RTX22OOH    ,
     & NRTX28OOH   , CARB14      , CARB17      , CARB10      ,
     & CARB12      , CARB15      , CCARB12     , ANHY        ,
     & TNCARB15    , RAROH14     , ARNOH14     , RAROH17     ,
     & ARNOH17     , PAN         , PPN         , PHAN        ,
     & RU12PAN     , MPAN        , RTN26PAN    , P2604       ,
     & P4608       , P2631       , P2635       , P4610       ,
     & P2605       , P2630       , P2629       , P2632       ,
     & P2637       , P3612       , P3613       , P3442       ,
     & CH3O2NO2    , EMPOA       , P2007       , CH3BR       ,
     & NH3             , AMMSUL     , SCIE        , SCIPA     ,
     & SCIPS         , SCIMAA      , SCIMAS    , SCIMVA  ,
     & SCIMVS      , SCIPAA      , SCIPAS    , SCIIPA    ,
     & SCIIPS      , SCIBPA      , SCIBPS     , SCIMGA  ,
     & SCIMGS    , SCIGAA      , SCIGAS		, FTOH ,
     & PFOA        ,
     & APHOC2H4O   , BPRU14OOH   , APRU14OOH   , C1RU12OOH   ,
     & ISRU12OOH   , BPRU12OOH   , BPRU10OOH   , APRU10OOH   ,
     & BPNRU14OO   , APNRU14OO   , C1NRU12OO   , ISNRU12OO   ,
     & BPNRU12OO   , ISRTN28OO   , BPRTN28OO   , APRTN28OO   ,
     & ISRTN26OO   , BPRTN26OO   , APRTN26OO   , BPRTN25OO   ,
     & APRTN25OO   , ISRTN24OO   , BPRTN24OO   , APRTN24OO   ,
     & C1RTN23OO   , ISRTN23OO   , BPRTN23OO   , ISNRTN28O   ,
     & BPNRTN28O   , APNRTN28O   , APRN8OOH    , ISRTX28OO   ,
     & BPRTX28OO   , APRTX28OO   , BPRTX24OO   , APRTX24OO   ,
     & ISRTX22OO   , BPRTX22OO   , APRTX22OO   , ISNRTX28O   ,
     & BPNRTX28O   , APNRTX28O   , C1RTN14OO   , ISRTN14OO   ,
     & BPRTN14OO   , APRTN14OO   , APRTN10OO   , P1001       ,
     & P1002       , P1003       , P1004       , P1005       ,
     & P1006       , P1007       , P1008       , P1009       ,
     & P1010       , P1011       , P1012       , P1013       ,
     & P1014       , P1015       , P1016       , P1017       ,
     & P1018       , P1019       , P1020       , P1021       ,
     & P1022       , P1023       , P1024       , P1025       ,
     & P1026       , P1027       , P1028       , P1029       ,
     & P1030       , P1031       , P1032       , P1033       ,
     & P1034       , P1035       , P1036       , P1037       ,
     & P1038       , P1039       , P1040       , P1041       ,
     & P1042       , P1043       , P1044       , P1045       ,
     & P1046       , P1047 
      COMMON
     & O1D         ,O           ,OH          , NO2         ,
     & NO3         , O3          ,N2O5        ,NO          ,
     & HO2         ,H2          , CO          , H2O2        ,
     & HONO        , HNO3        , HO2NO2      , SO2         ,
     & SO3         , HSO3        , NAER          , SA          ,
     & CH4         , CH3O2       , C2H6        , C2H5O2      ,
     & C3H8        , IC3H7O2     , RN10O2      , NC4H10      ,
     & RN13O2      , C2H4        , HOCH2CH2O2  , C3H6        ,
     & RN9O2       , TBUT2ENE    , RN12O2      , NRN6O2      ,
     & NRN9O2      , NRN12O2     , HCHO        , HCOOH       ,
     & CH3CO2H     , CH3CHO      , C5H8        , RU14O2      ,
     & NRU14O2     , UCARB10     , APINENE     , RTN28O2     ,
     & NRTN28O2    , RTN26O2     , TNCARB26    , RCOOH25    ,
     & BPINENE     , RTX28O2     , NRTX28O2    , RTX24O2     ,
     & TXCARB24    , TXCARB22    , C2H2        , CARB3       ,
     & BENZENE     , RA13O2      , AROH14      , TOLUENE     ,
     & RA16O2      , AROH17      , OXYL        , RA19AO2     ,
     & RA19CO2     , CH3CO3      , C2H5CHO     , C2H5CO3     ,
     & CH3COCH3    , RN8O2       , RN11O2      , CH3OH       ,
     & C2H5OH      , NPROPOL     , IPROPOL     , CH3CL       ,
     & CH2CL2      , CHCL3       , CH3CCL3     , TCE         ,
     & TRICLETH    , CDICLETH    , TDICLETH    , CARB11A     ,
     & RN16O2      , RN15AO2     , RN19O2      , RN18AO2     ,
     & RN13AO2     , RN16AO2     , RN15O2      , UDCARB8     ,
     & UDCARB11    , CARB6       , UDCARB14    , CARB9       ,
     & MEK        ,
     & HOCH2CHO    , RN18O2      , CARB13      , CARB16      ,
     & HOCH2CO3    , RN14O2      , RN17O2      , UCARB12     ,
     & RU12O2      , CARB7       , RU10O2      , NUCARB12    ,
     & NRU12O2     , NOA         , RTN25O2     , RTN24O2     ,
     & RTN23O2     , RTN14O2     , TNCARB10    , RTN10O2     ,
     & RTX22O2     , CH3NO3      , C2H5NO3     , RN10NO3     ,
     & IC3H7NO3    , RN13NO3     , RN16NO3     , RN19NO3     ,
     & HOC2H4NO3   , RN9NO3      , RN12NO3     , RN15NO3     ,
     & RN18NO3     , RU14NO3     , RA13NO3     , RA16NO3     ,
     & RA19NO3     , RTN28NO3    , RTN25NO3    , RTX28NO3    ,
     & RTX24NO3    , RTX22NO3    , CH3OOH      , C2H5OOH     ,
     & RN10OOH     , IC3H7OOH    , RN13OOH     , RN16OOH     ,
     & RN19OOH     , RA13OOH     , RA16OOH    ,
     & RA19OOH     , HOC2H4OOH   , RN9OOH      , RN12OOH     ,
     & RN15OOH     , RN18OOH     , CH3CO3H     , C2H5CO3H    ,
     & HOCH2CO3H   , RN8OOH      , RN11OOH     , RN14OOH     ,
     & RN17OOH     , RU14OOH     , RU12OOH     , RU10OOH     ,
     & NRN6OOH     , NRN9OOH     , NRN12OOH    , NRU14OOH    ,
     & NRU12OOH    , RTN28OOH    , NRTN28OOH   , RTN26OOH    ,
     & RTN25OOH    , RTN24OOH    , RTN23OOH    , RTN14OOH    ,
     & RTN10OOH    , RTX28OOH    , RTX24OOH    , RTX22OOH    ,
     & NRTX28OOH   , CARB14      , CARB17      , CARB10      ,
     & CARB12      , CARB15      , CCARB12     , ANHY        ,
     & TNCARB15    , RAROH14     , ARNOH14     , RAROH17     ,
     & ARNOH17     , PAN         , PPN         , PHAN        ,
     & RU12PAN     , MPAN        , RTN26PAN    , P2604       ,
     & P4608       , P2631       , P2635       , P4610       ,
     & P2605       , P2630       , P2629       , P2632       ,
     & P2637       , P3612       , P3613       , P3442       ,
     & CH3O2NO2    , EMPOA       , P2007       , CH3BR       ,
     & NH3             , AMMSUL     , SCIE        , SCIPA     ,
     & SCIPS         , SCIMAA      , SCIMAS    , SCIMVA  ,
     & SCIMVS      , SCIPAA      , SCIPAS    , SCIIPA    ,
     & SCIIPS      , SCIBPA      , SCIBPS     , SCIMGA  ,
     & SCIMGS    , SCIGAA      , SCIGAS		, FTOH , 
     & PFOA        ,
     & APHOC2H4O   , BPRU14OOH   , APRU14OOH   , C1RU12OOH   ,
     & ISRU12OOH   , BPRU12OOH   , BPRU10OOH   , APRU10OOH   ,
     & BPNRU14OO   , APNRU14OO   , C1NRU12OO   , ISNRU12OO   ,
     & BPNRU12OO   , ISRTN28OO   , BPRTN28OO   , APRTN28OO   ,
     & ISRTN26OO   , BPRTN26OO   , APRTN26OO   , BPRTN25OO   ,
     & APRTN25OO   , ISRTN24OO   , BPRTN24OO   , APRTN24OO   ,
     & C1RTN23OO   , ISRTN23OO   , BPRTN23OO   , ISNRTN28O   ,
     & BPNRTN28O   , APNRTN28O   , APRN8OOH    , ISRTX28OO   ,
     & BPRTX28OO   , APRTX28OO   , BPRTX24OO   , APRTX24OO   ,
     & ISRTX22OO   , BPRTX22OO   , APRTX22OO   , ISNRTX28O   ,
     & BPNRTX28O   , APNRTX28O   , C1RTN14OO   , ISRTN14OO   ,
     & BPRTN14OO   , APRTN14OO   , APRTN10OO   , P1001       ,
     & P1002       , P1003       , P1004       , P1005       ,
     & P1006       , P1007       , P1008       , P1009       ,
     & P1010       , P1011       , P1012       , P1013       ,
     & P1014       , P1015       , P1016       , P1017       ,
     & P1018       , P1019       , P1020       , P1021       ,
     & P1022       , P1023       , P1024       , P1025       ,
     & P1026       , P1027       , P1028       , P1029       ,
     & P1030       , P1031       , P1032       , P1033       ,
     & P1034       , P1035       , P1036       , P1037       ,
     & P1038       , P1039       , P1040       , P1041       ,
     & P1042       , P1043       , P1044       , P1045       ,
     & P1046       , P1047 
C

      M=NA*ETA2P(POS(3),P0)/(RGC*TL*1.0D04)

      NOXBAL(5) =NO/M-NO0
      NOXBAL(6) =NO2/M-NO20
      NOXBAL(7) =HNO3/M-HNO30
      NOXBAL(8) =PAN/M-PAN0
      NOXBAL(9) =NO3/M-NO30
      NOXBAL(10)=2.0*(N2O5/M-N2O50)
c      NOXBAL(11)=ORGNIT/M-ORGNIT0
      NOXBAL(12)=NOXBAL(1)
      DO I=2,11
        NOXBAL(12)=NOXBAL(12)-NOXBAL(I)
      ENDDO

      O3BAL(1)=O3/M-O30
      O3BAL(17)=0.0
      DO I=8,15
        O3BAL(17)=O3BAL(17)+O3BAL(I)
      ENDDO
      O3BAL(18)=O3BAL(6)+O3BAL(7)-O3BAL(16)-O3BAL(17)-O3BAL(1) 
C      WRITE(35+(CLINDX-1)*3,1235)TIME+ASTEP,(POS(I),I=1,3)
C     WRITE(36+(CLINDX-1)*3,1237)TIME+ASTEP,(NOXBAL(I),I=1,12) 
C       WRITE(37+(CLINDX-1)*3,1237)TIME+ASTEP,(O3BAL(I),I=1,18)
      DOBAL=0
      CLINDX=CLINDX+1
      IF (CLINDX.GT.NFOLLOW) CLINDX=1

 1235 FORMAT(E15.7,X,2(F8.4,X),F6.4)
 1237 FORMAT(E15.7,X,23(E11.4))
      RETURN
      END
C#######################################################################
      SUBROUTINE INITBAL(CELLNO,ENDTIME,ASTEP,LMOLEC,POS,TIME)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Open balance diagnostics files, write headers
C-                         (nfollow times)
C-   Inputs  :
C-   Outputs : cellno
C-   Controls:
C-
C-   Created   4-July-1994   D. Stevenson
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER POSUNIT,NOXUNIT,O3UNIT
      INTEGER CELLNO(NFOLLOW),K,JJ,J
      REAL ASTEP
      REAL POS(3,NCELL)
      DOUBLE PRECISION ENDTIME,LMOLEC,TIME
      CHARACTER*10 OUTFILE
      CHARACTER*7 STATUS
C
      IF(CRAY) THEN
        STATUS='UNKNOWN'
      ELSE
        STATUS='NEW'
      ENDIF
      DO J=1,NFOLLOW
        POSUNIT=35+(J-1)*3
        NOXUNIT=36+(J-1)*3
        O3UNIT =37+(J-1)*3
C        WRITE(6,*)'Cell index no.',j
C        WRITE(6,*)
C        WRITE(6,*)'Cell number to follow ?'
C        READ(5,*) cellno(j)
        CELLNO(J)=1153
        WRITE(6,*) 'Cell position to be followed for cell: ',CELLNO(J)
C        WRITE(6,*)'Cell position output filename ? (10 Chars)'
C        read(5,1230) outfile
C        if(outfile.eq.'')then
        OUTFILE='testps'
        WRITE(OUTFILE(7:10),'(i4)')CELLNO(J)
C        ENDIF
        OPEN(POSUNIT,FILE=OUTDIR//OUTFILE,STATUS=STATUS)
        WRITE(6,*)'Cell NOx chemistry output filename ? (10 Chars)'
C        read(5,1230) outfile
C        if(outfile.eq.'')then
        OUTFILE='testnx'
        WRITE(OUTFILE(7:10),'(i4)')CELLNO(J)
C        ENDIF
C        OPEN(noxunit,file=OUTDIR//outfile,recl=300,STATUS=STATUS)
        OPEN(NOXUNIT,FILE=OUTDIR//OUTFILE,STATUS=STATUS)
        WRITE(6,*)'Cell O3 chemistry output filename ? (10 Chars)'
C        read(5,1230) outfile
C        if(outfile.eq.'')then
        OUTFILE='testoz'
        WRITE(OUTFILE(7:10),'(i4)')CELLNO(J)
C        ENDIF
C        OPEN(o3unit,file=OUTDIR//outfile,recl=300,STATUS=STATUS)
        OPEN(O3UNIT,FILE=OUTDIR//OUTFILE,STATUS=STATUS)
        DO K=POSUNIT,O3UNIT
          WRITE(K,*)'Cell number:',CELLNO(J)
          WRITE(K,*)'Number of steps:',(ENDTIME-TIME)/ASTEP
          WRITE(K,251)LMOLEC
        ENDDO
        WRITE(POSUNIT,1234)'Time','Long','Lat','Eta'
        WRITE(POSUNIT,1235)TIME,(POS(JJ,CELLNO(J)),JJ=1,3)
        WRITE(NOXUNIT,1236)'Time','NO emit','NO2 dep','HNO3 dep',
     &    'PAN dep','dNO','dNO2','dHNO3','dPAN','dNO3','dN2O5',
     &    'dORGNIT','Diffusion'
        WRITE(O3UNIT,1236)'Time','O3 change','rc.17','rc.60',
     &    'rc.72','rc.83','dj3-rc11','dj14','rc5','rc8','rc12','rc13',
     &    'rc14','rc112','rc123','rc124','O3 dd','Chem.loss','Diffusion'
C
        WRITE(6,*)'Cell number:',CELLNO(J)
        WRITE(6,*)'Number of steps:',(ENDTIME-TIME)/ASTEP
        WRITE(6,251)LMOLEC
        WRITE(6,1234)'Time','Long','Lat','Eta'
        WRITE(6,1235) TIME,(POS(JJ,CELLNO(J)),JJ=1,3)
      ENDDO

  251 FORMAT(X,'No. of molecules in (lagrangian) cell:',1PE12.5)
 1230 FORMAT(A10)
 1234 FORMAT(7X,A4,5X,2(A4,5X),A3)
 1235 FORMAT(E15.7,X,2(F8.4,X),F6.4)
 1236 FORMAT(A4,5X,7A10/12A11/11A11)

      RETURN
      END
C#######################################################################
      SUBROUTINE JVALS(DJA,CLOUD,OZONE,O3CONC,LAND,LAT,TIME,T,P0,O3100,
     &  LONG,ASTEP)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Evaluate photolysis rates.
C-
C-   Inputs  : CLOUD,OZONE,O3CONC,LAND,P0,T
C-   Outputs : DJA
C-   Controls:
C-
C-   Created  9-AUG-1996   Colin Johnson
C-   Updated  13-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL DJA(NDJ,NLEV,NLONG,MNLAT,4),
     &  C(0:NLEV),CLOUD(NLONG,MNLAT,NLEV),OZONE(NLONG,MNLAT),
     &  LAND(NLONG,MNLAT),O3100(NLONG,MNLAT),
     &  O3CONC(NLONG,MNLAT,NLEV),P0(NMETLONG,NMETLAT),
     &  T(NMETLONG,NMETLAT,NMETLEV),ET(NLEV+1),EP0,ET0
      REAL LAT(NLAT),LONG(NLONG),O3(NLEV),O3TOP
      INTEGER I,J,K,L,M
      REAL LATIT,LONGIT,ASTEP
      DOUBLE PRECISION TIME,JTIME
      LOGICAL JFIRST

      DATA JFIRST /.TRUE./

      IF(JFIRST) THEN
        PRINT *,'***** FIXED TROPOSPHERIC DOBSONS UNIT (=50)***'
        DO I=1,4
          JTIME=TIME+(I-1)*ASTEP/3.0
C          WRITE(6,*) ' *** JVALS: FIRST CALL, HOUR = ',I,JTIME
C        Establish cloud and ozone profiles.
          DO K=1,MNLAT
            LATIT=90.-LAT(K)
            IF(LATIT.GT.0.) LATIT=90.-LAT(K+1)
            DO L=1,NLONG
              LONGIT=LONG(L)
              DO J=1,NLEV
                C(J)=0.01*CLOUD(L,K,J)
                O3(J)=O3CONC(L,K,J)
              ENDDO
              C(0)=0.0
C            Interpolate T profile, T0 and P0 to Eulerian grid centres.
              CALL EINTERP(L,K,P0,T,ET,EP0,ET0)
              O3TOP=O3100(L,K)
C            Call column-photolysis model.
              CALL PHOT(DJA(1,1,L,K,I),C,OZONE(L,K),O3,LAND(L,K),LATIT,
     &                  LONGIT,JTIME,ETA3,EP0,ET0,ET,O3TOP)
            ENDDO
          ENDDO
        ENDDO
        JFIRST=.FALSE.
      ELSE
C        Set first value = previous last, then calculate 1/3, 2/3 and end.
        DO J=1,NDJ
          DO K=1,NLEV
            DO L=1,NLONG
              DO M=1,MNLAT
                DJA(J,K,L,M,1)=DJA(J,K,L,M,4)
              ENDDO
            ENDDO
          ENDDO
        ENDDO
        DO I=2,4
          JTIME=TIME+(I-1)*ASTEP/3.0
C          WRITE(6,*) ' *** JVALS: HOUR = ',I,JTIME
C        Establish cloud and ozone profiles.
          DO K=1,MNLAT
            LATIT=90.-LAT(K)
            IF(LATIT.GT.0.) LATIT=90.-LAT(K+1)
            DO L=1,NLONG
              LONGIT=LONG(L)
              DO J=1,NLEV
                C(J)=0.01*CLOUD(L,K,J)
                O3(J)=O3CONC(L,K,J)
              ENDDO
              C(0)=0.0
C          Interpolate T profile, T0 and P0 to Eulerian grid centres.
              CALL EINTERP(L,K,P0,T,ET,EP0,ET0)
              O3TOP=O3100(L,K)
C          Call column-photolysis model.
              CALL PHOT(DJA(1,1,L,K,I),C,OZONE(L,K),O3,LAND(L,K),LATIT,
     &                  LONGIT,JTIME,ETA3,EP0,ET0,ET,O3TOP)
            ENDDO
          ENDDO
        ENDDO
      ENDIF

C     WRITE(6,*) ' *** JVALS for level 1, L=36, K=18,TIME= ',TIME
C     WRITE(6,*) 'JTIME=TIME, J(1) with longtitude:'
C     WRITE(6,*) (DJA(1,1,J,18,1),J=1,72,4)
C     WRITE(6,*) 'JTIME=TIME+ASTEP/3'
C     WRITE(6,*) (DJA(J,1,36,18,2),J=1,NDJ)
C     WRITE(6,*) 'JTIME=TIME+2ASTEP/3'
C     WRITE(6,*) (DJA(J,1,36,18,3),J=1,NDJ)
C     WRITE(6,*) 'JTIME=TIME+ASTEP'
C     WRITE(6,*) (DJA(J,1,36,18,4),J=1,NDJ)

  999 RETURN
      END
C#######################################################################
      SUBROUTINE EINTERP(L,K,P0,T,ET,EP0,ET0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Returns single column temperature profile on
C-                         eta3 vertical grid and surface temperature
C-                         and pressure at centre of Eulerian xy grid.
C-
C-   Inputs  : T,P0
C-   Outputs : ET,EP0,ET0
C-   Controls:
C-
C-   Created  11-OCT-1995   Colin Johnson
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  No longer have 'Surface' T. First
C-                                        level is 0.997
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
C-
      INTEGER I,II,J,K,L,M
      REAL P0(NMETLONG,NMETLAT),T(NMETLONG,NMETLAT,NMETLEV),
     &     ET(NLEV+1),EP0,ET0,DEG
C
C      Calculate indices for interpolation.
C      Select correct column (no interpolation needed)
      DEG = (L-1)*DLONG+DLONG/2.0
      I = NINT(DEG/DLONGM)
      DEG = (K-1)*DLAT+DLAT/2.0
      J = NINT(DEG/DLATM)+1
C      WRITE(6,*) 'INDICES IN EINTERP: ',I,J
C
      EP0=P0(I,J)
C      T(*,*,1) is not the true surface temperature !
      ET0=T(I,J,1)
C      WRITE(6,*) 'EP0,ET0',EP0,ET0
C
      II=1
      DO M = 2,NLEV+1
C       Find indices for height interpolation of T onto eta3 grid.
        DO WHILE((II.LE.NMETLEV).AND.ETA2(II).GT.ETA3(M))
          II=II+1
        ENDDO
        IF(II.GT.NMETLEV.OR.II.EQ.0)
     &     WRITE(6,*) ' II OUT OF RANGE IN EINTERP'
C      Interpolate:
        ET(M) =  T(I,J,II-1)+((T(I,J,II)-T(I,J,II-1))/
     &           (ETA2(II)-ETA2(II-1)))*(ETA3(M)-ETA2(II-1))
        ET(M)=ET(M)
      ENDDO
C
      RETURN
      END
C#######################################################################
      SUBROUTINE PHOT(P,CLOUD,O3COL,O3,FRLAND,LAT,LONG,TIME,ETA3,P0,T0,
     &                TT,O3TOP)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE PHOTOLYSIS RATES
C-
C-   Inputs  : CLOUD,O3COL,O3,FRLAND,NSTEPS,P0,T0,TT,ETA3
C-   Outputs : P
C-   Controls:
C-
C-   Created     FEB-1994   M.E. JENKIN
C-   Updated  23-FEB-1994   Colin Johnson  Converted to pressure coordinates
C-   Updated   3-JUN-1994   Bill Collins   Removed unused rates, Modularised,
C-                                         and corrected O3 column interpolation
C-   Updated  20-JUN-1994   Bill Collins   'half' levels are now level 0
C-   Updated  31-JAN-1995   Bill Collins   Photolysis rates now calculated for
C-                                         NSTEPS between 1200 and 2400 for
C-                                         latitude LAT and day since midsummer
C-                                         DAY.
C-   Updated   5-SEP-1995   Colin Johnson  Added PAN photolysis.
C-   Updated   5-OCT-1995   Colin Johnson  Ozone profile from simulation.
C-   Updated  25-OCT-1995   Colin Johnson  Temperature profile, T0 and P0 from
C-                                         Met. data, Ozone at 100mb.
C-   Updated   9-AUG-1996   Colin Johnson  Removed NSTEPS, now calculates one
C-                                         profile at TIME.
C-   Updated  26-NOV-1996   Colin Johnson  Replaced BIACETYL with HO2NO2.
C-   Updated  02-JUL-2008   Michael Cooke  Included species for CRIv2 chemistry.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
C PHOTOL  SINGLE-COLUMN PHOTOLYSIS CODE, A.M. HOUGH (HARWELL LABORATORY)
C         FORTRAN CONVERSION OF FACSIMILE OLIVER WILD (UNIV. CAMBRIDGE)
C
C NEWPHOT REVISED CROSS-SECTIONS & QUANTUM YIELDS (FEB. 1994, M.E. JENKIN,
C         C.E. JOHNSON, HARWELL LABORATORY)
C
C NPP     THIS VERSION IN PRESSURE COORDINATES FOR CONVERSION TO
C         SUBROUTINE.  CEJ 23/II/94.
C         VER. 2 HAS 9 LAYERS.
C         VER. 3 HAS 9 CLOUD LAYERS.
C
C RADIATION TRANSFER AND PHOTOLYSIS RATE CALCULATIONS
C 200-660 NM.
C
C VERSION WITH TWO-STREAM SCATTER AND REFLECTION CALCULATIONS
C 'HALF' PARAMETERS REFER TO VALUES 25% UP THE BOTTOM LEVEL
C
C THE EFFECTS OF SCATTER ABOVE THE MODEL DOMAIN ARE IGNORED !!
C
C CLOUD AND AERO REFER TO FRACTIONAL CLOUD COVER AND TO THE AEROSOL
C CONCENTRATION CENTRED ON THE TOP OF THE MODEL LAYERS
C CLOUD MAY BE PRESENT AT THE TOP OF ANY MODEL LEVEL.
C LOW CLOUD IS ASSUMED TO OCCUPY LOWEST THREE LAYERS.
C MEDIUM CLOUD IS ASSUMED TO OCCUPY MIDDLE THREE LAYERS.
C HIGH CLOUD IS ASSUMED TO OCCUPY HIGHEST THREE LAYERS.
C THIS WILL NEED CHANGING IF NLEV IS CHANGED.
C
C NOTE THAT ATTENUATION AND SCATTER ARE CALCULATED ON THE BOUNDARIES
C BETWEEN THE DIFFERENT LEVELS, SO AS TO OBTAIN VALUES FOR THE FLUXES
C AND RATES AT THE CENTRE OF THE LEVELS.
C
C US STANDARD ATMOSPHERE OZONE COLUMN.
C O3COL IS THE OZONE COLUMN ABOVE 100 hPa (ABOUT 16 KM) IN DOBSON UNITS.
C O2COL IS THE OXYGEN COLUMN ABOVE 100 hPa IN MOLECULES CM-2.
C
C FLUXES ARE FLUX<WLENGTH RANGE,SCATTERING ORDER,MODEL LEVEL>
C
C NLEV=NO. OF LEVELS
C NLAM=NO. OF WAVELENGTH INTERVALS
C
      INTEGER NLAM,NLEV,J,ICHEM
      PARAMETER(NLAM=106,NLEV=9)
      REAL RGC,NA
      PARAMETER(RGC=8.314,NA=6.022E23)
C
      REAL P(143,NLEV),BR01(NLEV)
      REAL ZENITH,YEAR,LAT,LONG,ZEN
      DOUBLE PRECISION TIME
      REAL NN(0:NLEV),TT(0:NLEV),ZZ(0:NLEV),TU(NLEV),
     1     PU(NLEV),DZ(0:NLEV),O2N(0:NLEV),
     2     CLOUD(0:NLEV),OZONE(0:NLEV),RI(0:NLEV),AERO(0:NLEV),
     2     CCOS(0:NLEV)
      REAL ACONC(33),ALB0SURF(NLAM),ALB1SURF(NLAM),ALBICE(NLAM),
     1     ALBLAND(NLAM),TRALOW(NLAM),TRAMED(NLAM),TRAHIGH(NLAM),
     2     O3CONC(33),O3(NLEV),ETA3(NLEV),O3TOP
C
      REAL J1O3(NLEV),J2O3(NLEV),JNO2(NLEV),
     &     J1NO3(NLEV),J2NO3(NLEV),J1N2O5(NLEV),
     &     JHNO3(NLEV),J1HCHO(NLEV),J2HCHO(NLEV),
     &     JH2O2(NLEV),JCH3OOH(NLEV),J1ACET(NLEV),
     &     JAONE(NLEV),J1GLY(NLEV),
     &     JMGLY(NLEV),JHO2NO2(NLEV),JPAN(NLEV),
     & JC2H5CHO(NLEV),JCH3COCH3(NLEV),JHONO(NLEV),
     & JUCARB10(NLEV),JCARB3(NLEV),JCARB6(NLEV),JCARB9(NLEV),
     & JCARB12(NLEV),JCARB15(NLEV),JUCARB12(NLEV),
     & JNUCARB12(NLEV),JHOCH2CHO(NLEV),
     & JTNCARB10(NLEV),JCH3NO3(NLEV),JC2H5NO3(NLEV),
     & JRN10NO3(NLEV),JIC3H7NO3(NLEV),JMEK(NLEV),
     & JBUTANAL(NLEV),JANOA(NLEV),JBNOA(NLEV)
C
      REAL LAMBDA(NLAM)
      REAL SGO3(NLAM),SGNO2(NLAM),SGHCHO(NLAM),
     &     SGH2O2(NLAM),SGANO2(NLAM),SGTNO2(NLAM),
     &     P1O3(NLAM)
      REAL SGO2(NLAM),SGAO3(NLAM),SGBO3(NLAM),SGNO3(NLAM),
     &     SGHNO3(NLAM),SGN2O5(NLAM),SGAHCHO(NLAM),
     &     SGBHCHO(NLAM),SGAH2O2(NLAM),SGBH2O2(NLAM),
     &     SGCH3OOH(NLAM),SGACET(NLAM),
     &     SGAONE(NLAM),SGGLY(NLAM),SGMGLY(NLAM),
     &     SGHO2NO2(NLAM),SGAHNO3(NLAM),SGTHNO3(NLAM),
     &     SGPAN(NLAM),SGAPAN(NLAM),SGTPAN(NLAM),SGHONO(NLAM),
     &     SGC2H5CHO(NLAM),SGMEK(NLAM),SGBUTANAL(NLAM),SGUCARB10(NLAM),
     &     SGCARB9(NLAM),SGNOA(NLAM),SGCH3NO3(NLAM),SGACH3NO3(NLAM),
     &     SGTCH3NO3(NLAM),SGC2H5NO3(NLAM),SGAC2H5NO3(NLAM),
     &     SGTC2H5NO3(NLAM),SGRN10NO3(NLAM),SGIC3H7NO3(NLAM),
     &     SGAIC3H7NO3(NLAM),SGTIC3H7NO3(NLAM) 
      REAL PNO2(NLAM),P1NO3(NLAM),P2NO3(NLAM),
     &     P1N2O5(NLAM),P2HCHO(NLAM),
     &     P1HCHO(NLAM),PP2HCHO(NLAM),P1ACET(NLAM),
     &     PP1ACET(NLAM),PAONE(NLAM),
     &     P1GLY(NLAM),PMGLY(NLAM),PC2H5CHO(NLAM),PUCARB10(NLAM),
     &     PCARB9(NLAM),PNOA56(NLAM),PNOA57(NLAM)
      REAL ATTA0(NLAM,0:NLEV),ATTA1(NLAM,0:NLEV),ATTS0(NLAM,0:NLEV),
     &     ATTS1(NLAM,0:NLEV),ALBC0(NLAM,0:NLEV),ALBC1(NLAM,0:NLEV),
     &     FRBK0(NLAM,0:NLEV),FRBK1(NLAM,0:NLEV),FRFD0(NLAM,0:NLEV),
     &     FRFD1(NLAM,0:NLEV),TRAC0(NLAM,0:NLEV),TRAC1(NLAM,0:NLEV)
      REAL FLUXTOT(NLAM,NLEV+1),FLUXDN(NLAM,6,0:NLEV+1),
     &     FLUXUP(NLAM,6,0:NLEV+1)
C
      REAL MMTOP,SSEC,MM,FRLAND,FROCEAN,FRICE,COSSURF,O2COL,
     &    O3COL,O3SCALE,DOBSON,N0,T0,P0,AERATT,AERSCAT,ASCAT,TDOB
C
      INTEGER MNLEV,PNLEV,NL
      LOGICAL FIRST
      REAL SFLUX(NLAM),RAYLEIGH(NLAM)
C
C ********************************************************************
C
C DATA STATEMENTS....
C
C ********************************************************************
C
      DATA FIRST/.TRUE./
      DATA YEAR/0.50/,O2COL/3.72E+23/,
     &    O3SCALE/1.0/,ASCAT/1.8508/,
     &    AERATT/0.01/,AERSCAT/0.09/,
     &    FRICE/0.0/
C     &    N0/2.514238E+19/,P0/1013.0/,T0/288.15/
C
C      PRESSURE AND TEMPERATURE DATA
C      TEMPERATURES FROM US STANDARD ATMOSPHERE
C
C      DATA TT/
C     &    0.,281.6,275.5,268.6,260.9,252.1,241.4,228.4,216.6,216.6/
C      DATA PP/
C     &    0.,900.0,800.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0/
C
      DATA SFLUX/0.0152,0.0178,0.0220,0.0269,0.0454,0.0714,
     1    0.083,0.084,0.108,0.118,0.160,0.134,0.141,0.157,0.138,0.160,
     2    0.145,0.220,0.199,0.197,0.194,0.291,0.495,0.453,1.07,1.20,
     3    1.10,1.04,0.824,1.52,2.15,3.48,3.40,3.22,4.23,4.95,
     4    5.44,5.93,6.95,8.15,7.81,8.35,8.14,8.53,9.17,8.38,
     5    10.4,11.0,9.79,11.3,8.89,11.4,9.17,16.9,17.0,18.4,
     6    18.7,19.5,18.1,16.7,19.8,20.2,21.8,23.6,23.1,23.9,
     7    23.8,23.9,24.4,25.1,23.0,23.9,24.8,24.0,24.6,24.9,
     8    23.2,23.9,24.2,25.5,25.1,24.9,25.5,25.3,25.4,25.0,
     9    25.7,25.8,26.7,26.7,27.0,26.2,26.9,26.3,26.8,26.6,
     9    25.9,26.9,26.1,26.2,26.2,26.3,26.0,25.5,24.8,25.7/
C ALL TO BE MULTIPLIED BY 1.0E+14
C
      DATA RAYLEIGH / 353.0, 336.0,320.0,305.0,290.0,276.0,
     1    262.0,249.0,236.0,224.0,213.0,202.0,192.0,182.0,172.0,163.0,
     2    154.0,146.0,138.0,131.0,123.0,117.0,110.0,104.0,97.8, 92.2,
     3    86.8, 81.7, 76.8, 72.2, 67.8, 63.6, 59.7, 55.9, 52.4, 49.0,
     4    45.8, 42.8, 40.1, 37.5, 35.2, 33.1, 31.1, 29.2, 27.5, 26.0,
     5    24.5, 23.1, 21.9, 20.7, 19.6, 18.6, 17.6, 16.7, 15.9, 15.1,
     6    14.4, 13.7, 13.0, 12.4, 11.8, 11.3, 10.8, 10.3, 9.85, 9.42,
     7    9.01, 8.63, 8.26, 7.92, 7.59, 7.28, 6.99, 6.71, 6.44, 6.19,
     8    5.95, 5.72, 5.50, 5.30, 5.10, 4.91, 4.73, 4.56, 4.34, 4.18,
     9    4.04, 3.90, 3.76, 3.63, 3.51, 3.39, 3.28, 3.17, 3.06, 2.96,
     9    2.87, 2.77, 2.68, 2.60, 2.52, 2.44, 2.36, 2.29, 2.22, 2.15/
C ALL TO BE MULTIPLIED BY 1.0E-27
C
C PHOTOABSORPTION CROSS-SECTION OF O2 (UNITS OF 1.0E-24 CM**2)
C
      DATA SGO2 / 7.69,7.53,7.32,7.00,6.50,6.12,
     &    5.74,5.30,4.60,4.26,3.79,3.21,2.69,2.22,1.79,1.38,
     &    1.05,0.75,88*0.0/
C JPL (1992). ELEMENTS 0,1 AND 17 ARE 0.96,0.96 AND 0.81 OF WMO (1986) ;
C
C PHOTOABSORPTION CROSS-SECTIONS (UNITS OF 1.0E-20 CM**2)
C (N2O CROSS SECTIONS ARE CALCULATED IN THE CODE)
C
      DATA SGAO3/
     &    31.4,32.6,36.4,43.4,54.2,69.9,
     &    92.1,119.0,155.0,199.0,256.0,323.0,400.0,483.0,579.0,686.0,
     &    797.0,900.0,1000.0,1080.0,1130.0,1150.0,1120.0,1060.0,
     &    965.0,834.0,692.0,542.0,402.0,277.0,179.0,109.0,62.4,34.3,
     &    18.5,9.80,5.01,2.49,1.20,0.617,0.274,0.117,0.0588,0.0266,
     &    0.0109,0.0055,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
     &    0.0, 0.0029,0.0031,0.0040,0.0065,0.0068,0.0087,0.0125,
     &    0.0149,0.0171,0.0212,0.0357,0.0368,0.0406,0.0489,0.0711,
     &    0.0843,0.0828,0.0909,0.122,
     &    0.162,0.158,0.160,0.178,0.207,0.255,0.274,0.288,0.307,0.317,
     &    0.336,0.388,0.431,0.467,0.475,0.455,0.435,0.442,0.461,0.489,
     &    0.484,0.454,0.424,0.390,0.360,0.434,0.317,0.274,0.261,0.242,
     &    0.220,0.202/
C VALUES AT 273K
C JPL (1992)/IUPAC (1992), BASED LARGELY ON WMO (1986)
C
      DATA SGBO3/
     &    31.4, 32.6, 36.4, 43.4, 54.2, 69.9,
     &    92.1, 119.0,155.0,199.0,256.0,323.0,400.0,483.0,579.0,686.0,
     &    797.0,900.0,1000.0,1080.0,1130.0,1150.0,1120.0,1060.0,
     &    959.0,831.0,689.0,535.0,391.0,267.0,173.0,104.0,58.5,31.6,
     &    16.6,8.67,4.33,2.09,0.937,0.471,0.198,0.0777,0.0,0.0,
     &    0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
     &    0.0,0.0029,0.0031,0.0040,0.0065,0.0068,0.0087,0.0125,0.0149,
     &    0.0171,0.0212,0.0357,0.0368,0.0406,0.0489,0.0711,0.0843,
     &    0.0828,0.0909,0.122,
     &    0.162,0.158,0.160,0.178,0.207,0.255,0.274,0.288,0.307,0.317,
     &    0.336,0.388,0.431,0.467,0.475,0.455,0.435,0.442,0.461,0.489,
     &    0.484,0.454,0.424,0.390,0.360,0.434,0.317,0.274,0.261,0.242,
     &    0.220,0.202/
C VALUES AT 203K ;
C JPL (1992)/IUPAC (1992), BASED LARGELY ON WMO (1986) ;
C
      DATA SGANO2/
     &    41.5,41.5,44.8,44.5,46.4,48.7,
     &    48.2,50.2,44.4,47.1,37.7,39.3,27.4,27.8,16.9,16.2,
     &    8.81,7.47,3.91,2.75,2.01,1.97,2.11,2.36,2.70,3.25,
     &    3.79,5.03,5.88,7.00,8.15,9.72,11.54,13.44,15.89,18.67,
     &    21.53,24.77,28.07,31.33,34.25,37.98,40.65,43.13,47.17,48.33,
     &    51.66,53.15,55.08,56.44,57.57,59.27,58.45,60.21,57.81,59.99,
     &    56.51,58.12,48*0.0/
C VALUES AT 273 K ;
C JPL (1992) ;
C
      DATA SGTNO2/
     &    26*0.0,
     &    0.017,0.075,0.082,-0.053,-0.043,-0.031,
     &    -0.162,-0.284,-0.357,-0.536,-0.686,-0.786,-1.105,-1.355,
     &    -1.277,-1.612,-1.890,-1.219,-1.921,-1.095,
     &    -1.322,-1.102,-0.806,-0.867,-0.945,-0.923,-0.738,
     &    -0.599,-0.545,-1.129,0.001,-1.208, 48*0.0/
C THIS IS THE TEMPERATURE DEPENDANCE IN 1.0E-22 CM**2 DEGREE-1
C JPL (1992) ;
C
      DATA SGNO3/53*0.0,0.4,2.8,4.4,
     1    5.4,8.2,10.4,13.0,18.4,19.4,22.4,28.4,33.4,37.2,
     2    43.4,51.0,60.4,64.4,68.6,88.0,96.8,98.8,109.8,132.0,
     3    140.0,144.6,148.4,194.0,204.4,183.2,180.8,235.6,268.0,307.2,
     4    253.4,254.4,273.8,305.2,276.8,513.8,408.0,283.4,345.4,147.8,
     5    196.2,358.2,925.0,565.8,144.8,110.8,62.4,37.8,76.0,735.8/
C
      DATA SGHONO/
     &    34*0.0,1.226,1.305,3,4.9,5,11.1,9.6,10,10.9,11.2,36.4,9,
     &    16.8,17.8,5.3,9.6,20.3,2.7,1,53*0.0/
C
C  QUANTUM YIELD = 1 @ ALL WAVELENGTHS	
C  BONGARTZ ET. AL. 1990, JPL_12_2
C  NO TEMP DEPENDENCE
C
      DATA SGN2O5/920.0,843.28,820.0,719.12,560.0,537.44,
     1    370.0,370.0,226.84,220.0,152.46,144.0,102.91,98.52,77.0,
     1    73.81,62.0,57.23,52.0,42.28,38.32,32.00,27.96,24.84,
     2    20.0,17.0,14.0,12.9,11.7,77*0.0/
C
      DATA SGAHNO3/
     &    516.8,384.5,273.0,183.8,118.8,74.0,
     &    44.96,28.18,18.51,13.35,10.19,8.02,6.51,5.21,4.17,3.21,
     &    2.66,2.30,2.09,1.99,1.96,1.95,1.93,1.88,1.80,1.68,
     &    1.52,1.34,1.13,0.924,0.720,0.533,0.371,0.242,0.144,0.081,
     &    0.042,0.020,0.010,0.004,0.002,0.001,0.001,63*0.0/
C BURKHOLDER ET AL (1993)/RATTIGAN ET AL (1992)
C
      DATA SGTHNO3/
     &    1.675,1.716,1.757,1.820,1.936,2.061,
     &    2.166,2.174,2.192,2.105,1.986,1.840,1.786,1.837,1.899,1.970,
     &    1.970,1.852,1.651,1.417,1.253,1.164,1.121,1.140,1.198,1.297,
     &    1.494,1.635,1.768,1.930,2.138,2.379,2.734,3.154,3.690,4.253,
     &    5.200,6.450,7.355,9.750,10.05,11.80,10.70,63*0.0/
C BURKHOLDER ET AL (1993)
C
      DATA SGAHCHO/
     &    14*0.0,0.02,0.02,
     &    0.03,0.09,0.12,0.18,0.24,0.35,0.41,0.62,0.59,1.11,
     &    1.26,1.46,2.00,2.18,2.41,2.10,3.63,2.83,2.79,2.44,
     &    2.49,1.80,2.09,2.04,1.22,1.42,0.58,0.48,0.48,0.06,
     &    60*0.0/
C VALUES AT 293K
C JPL (1992) AVERAGED
C
      DATA SGBHCHO/
     &    14*0.0,0.04,0.05,
     &    0.08,0.09,0.12,0.18,0.24,0.35,0.41,0.62,0.59,1.11,
     &    1.26,1.46,2.00,2.18,2.41,2.10,3.63,2.94,2.90,2.49,
     &    2.53,1.86,2.30,2.25,1.40,1.59,0.57,0.51,0.51,0.02,
     &    60*0.0/
C VALUES AT 223K
C JPL (1992) AVERAGED
C
      DATA SGAH2O2/
     &    48.00,43.01,41.50,39.17,35.50,34.85,
     &    30.00,30.00,25.71,25.50,21.95,21.50,18.40,18.03,15.00,
     &    14.41,
     &    12.20,11.10,9.90,8.36,7.66,6.40,5.51,4.87,4.00,3.30,
     &    2.81,2.34,1.84,1.48,1.23,0.986,0.750,0.562,0.420,0.308,
     &    0.223,0.160,0.115,0.082,0.060,0.043,0.031,0.022,0.0150,
     &    0.010,0.006,0.003,58*0.0/
C NICOVICH AND WINE (1988) ;
C
      DATA SGBH2O2/
     &    16*25.0,
     &    25.0,24.95,24.90,24.49,24.17,23.30,22.09,21.00,18.90,
     &    17.21,
     &    15.84,14.46,12.70,11.26,10.08,8.92,7.77,6.73,5.81,4.93,
     &    4.13,3.43,2.83,2.30,1.84,1.40,1.05,0.80,0.57,0.40,
     &    0.27,0.16,58*0.0/
C NICOVICH AND WINE (1988) ;
C
      DATA SGCH3OOH/
     &    35.23,32.38,31.52,30.08,27.81,23.15,
     &    19.56,16.96,14.76,13.18,11.69,10.35,9.13,8.04,7.08,6.20,
     &    5.48,4.81,4.26,3.74,3.26,2.82,2.43,2.12,1.83,1.57,
     &    1.34,1.11,0.922,0.767,0.635,0.515,0.398,0.308,0.238,0.182,
     &    0.137,0.105,0.079,0.061,0.047,0.035,0.027,0.021,0.016,0.012,
     &    60*0.0/
C JPL (1992)
C
      DATA SGACET/
     &    0.06,0.06,0.05,0.05,0.05,0.05,
     &    0.05,0.05,0.05,0.06,0.08,0.10,0.13,0.18,0.24,0.33,
     &    0.45,0.59,0.78,1.01,1.28,1.62,2.00,2.38,2.88,3.28,
     &    3.74,4.11,4.46,4.65,4.69,4.68,4.28,4.03,3.42,2.91,
     &    2.20,1.723,1.136,0.688,0.350,0.150,0.021,0.008,0.004,0.003,
     &    60*0.0/
C MARTINEZ ET AL. (1992)
C
      DATA SGAONE/
     &    0.61,0.43,0.21,0.12,0.11,0.11,
     &    0.12,0.14,0.17,0.22,0.29,0.36,0.47,0.61,0.77,0.98,
     &    1.24,1.53,1.88,2.27,2.70,3.15,3.62,4.08,4.46,4.78,
     &    4.99,5.06,5.05,4.79,4.43,3.94,3.30,2.69,2.05,1.40,
     &    0.858,0.467,0.205,0.067,0.017,0.005,0.002,0.001,62*0.0/
C MARTINEZ ET AL. (1992)
C
      DATA SGGLY/28*0.0,2.87,3.21,3.22,3.21,3.36,3.48,2.72,
     1    2.72,2.29,1.43,1.29,1.15,2.87,0.0,0.0,0.0,0.0,0.23,
     3    0.29,0.80,1.00,1.67,1.49,3.03,2.59,3.36,3.69,4.50,
     4    6.46,5.31,9.20,6.93,5.90,11.71,7.17,7.53,20.38,0.51,
     5    40*0.0/
C
      DATA SGMGLY/
     &    11*0.0,1.31,1.42,1.56,1.73,
     &    1.89,2.05,2.28,2.33,2.52,2.69,2.85,3.12,3.38,3.61,
     &    3.99,4.27,4.49,4.85,4.76,4.78,4.65,4.20,3.69,3.29,
     &    2.36,1.89,1.51,0.94,0.65,0.48,0.32,0.30,0.39,0.56,
     &    0.70,1.08,1.48,1.91,2.43,3.22,4.03,4.73,5.66,6.92,
     &    8.46,9.68,10.21,10.34,10.41,10.81,9.94,9.61,8.67,3.69,
     &    0.91,0.27,0.108,0.062,37*0.0/
C  REF REQUIRED
C
      DATA SGHO2NO2/
     *  563.0,412.6,367.0,318.1,241.0,231.9,
     *  164.0,164.0,122.0,120.0,97.96,95.20,82.05,80.56,69.80,
     *  67.53,59.10,54.61,49.70,43.30,40.39,35.10,30.19,26.76,
     *  22.4,18.9,16.0,13.1,9.3,6.9,5.0,3.5,2.4,1.5,1.1,0.7,
     *  0.4,0.3,0.2,0.1,66*0.0/
C  REF REQUIRED
C
      DATA SGAPAN/
     *  342.8,307.7,274.4,239.0,204.6,173.0,144.1,120.0,99.81,83.69,
     *  70.27,59.32,50.20,42.50,35.68,30.18,25.22,20.91,17.25,14.21,
     *  11.71,9.551,7.764,6.241,4.915,3.806,2.844,2.094,1.497,1.040,
     *  0.665,0.448,0.289,0.175,0.108,0.066,0.041,0.025,0.015,0.011,
     *  0.006,0.005,0.002,63*0.0 /
C  TENDULKAR et al.(1995), values at 298 K.
C
      DATA SGTPAN/
     *  1.213,0.960,0.798,0.725,0.739,0.824,0.964,1.139,1.343,1.555,
     *  1.765,1.980,2.186,2.398,2.624,2.856,3.075,3.280,3.481,3.667,
     *  3.847,4.027,4.236,4.489,4.744,5.010,5.353,5.747,6.171,6.634,
     *  7.123,7.628,8.110,8.505,8.835,9.138,9.515,10.00,10.50,10.90,
     *  11.60,12.20,12.50,63*0.0 /
C  TENDULKAR et al.(1995), temperature dependance.
C
      DATA SGC2H5CHO/
     &    0.0502,0.0482,0.0483,0.0508,0.0556,0.0617,0.0687,0.0752,
     &    0.0815,0.0873,0.0978,0.115,0.142,0.187,0.255,0.351,0.481,
     &    0.649,0.861,1.13,1.46,1.84,2.26,2.80,3.27,3.87,4.37,4.90,5.16,
     &    5.73,5.61,5.81,5.30,5.08,4.21,3.60,2.77,1.831,1.3,0.575,0.325,
     &    0.155,0.025,0.01,0.002,61*0.0/
C
C   Atkinson et. al. j. chem. phys. 21;6;1992
C   NO TEMP DEPENDENCE
C
      DATA SGMEK/
     &    1.90,0.976,0.355,0.0923,0.151,0.165,0.182,0.204,0.233,0.271,
     &    0.323,0.391,0.477,0.590,0.737,0.926,1.16,1.46,1.81,2.22,2.70,
     &    3.22,3.75,4.30,4.82,5.25,5.57,5.75,5.75,5.57,5.19,4.60,3.89,
     &    3.15,2.27,1.56,0.896,0.457,0.189,0.0670,0.0200,0.005,0.001,
     &    63*0.0/
C
C IUPAC 2006
C NO TEMPERATURE DEPENDENCE
C Quantum Yield = 0.34
C
      DATA SGBUTANAL/
     &    0.0147,0.0212,0.0284,0.0365,0.0453,0.0537,0.0620,0.0710,
     &    0.0785,0.0825,0.0900,0.102,0.119,0.150,0.200,0.273,0.375,
     &    0.510,0.684,0.915,1.20,1.54,1.94,2.44,2.92,3.54,4.09,4.68,
     &    5.16,5.59,5.86,5.93,5.81,5.43,4.98,4.06,3.46,2.25,1.69,0.868,
     &    0.485,0.215,0.041,0.015,0.006,0.002,0.001,59*0.0/
C
C IUPAC 2006; Martinez et al., 1991
C NO TEMPERATURE DEPENDENCE
C Quantum Yield = 0.30
C
      DATA SGUCARB10/
     &  22*0.0,0.187,0.216,0.281,0.379,0.525,0.725,0.990,1.32,1.76,
     &  2.28,2.90,3.57,4.26,4.94,5.70,6.27,6.74,7.15,6.08,6.24,6.53,
     &  4.16,4.14,5.05,2.33,1.42,0.98,1.3,0.331,0.147,0.123,
     &  53*0.0/
C IUPAC 2006; Pinho et al, 2005 - methacrolein - CH2=C(CH3)CHO
C NO TEMPERATURE DEPENDENCE
C
      DATA SGCARB9/
     &  5*0.0,0.0518,0.243,0.438,0.637,0.840,1.05,1.26,1.48,1.54,1.82,
     &  2.11,2.40,2.70,2.98,3.26,3.53,3.79,4.03,4.25,4.45,4.61,4.73,
     &  4.79,4.73,4.45,3.96,3.30,2.58,1.89,1.32,0.877,0.560,0.364,
     &  0.278,0.281,0.355,0.479,0.634,0.8,0.964,1.14,1.34,1.59,1.89,
     &  2.28,2.77,3.37,4.11,5,6.00,6.81,7.09,6.71,6.15,6.04,6.53,6.79,
     &  5.90,4.2,2.75,1.66,0.828,0.133,38*0.0/
C IUPAC 2006
C NO TEMPERATURE DEPENDENCE
C
      DATA SGNOA/
     &    23*0.0,1.05,2.09,3.00,3.78,4.40,4.87,5.15,5.22,5.05,4.64,
     &    4.03,3.29,2.52,1.79,1.18,0.725,0.417,0.224,0.112,0.0526,
     &     0.0230,0.00942,0.00359,60*0.0/
C
C Roberts and Fajer (1989)
C NO TEMPERATURE DEPENDENCE
C
      DATA SGACH3NO3/
     &  17*0.0,4.92,4.10,3.72,3.47,3.31,3.15,2.98,
     &  2.78,2.51,2.23,1.93,1.60,1.29,0.994,0.730,0.507,0.333,0.206,
     &  0.133,0.0633,0.0316,0.0144,0.00661,0.00274,0.00122,64*0.0/

C
      DATA SGTCH3NO3/
     &  17*0.0,3.41,3.27,3.05,2.90,2.82,2.81,
     &  2.85,2.92,3.03,3.16,3.32,3.50,3.71,3.91,4.20,4.59,5.03,5.61,
     &  6.35,7.34,8.74,9.97,13.6,13.6,13.6,64*0.0/
C
C JPL 2006; Roberts and Fajer (1989)
C TEMPERATURE DEPENDENCE 1E-3.
C
      DATA SGAC2H5NO3/
     &  1059.8,893.9,727.6,571.1,432.2,318.1,229.3,162.1,112.9,78.4,
     &  55.1,39.6,28.7,20.4,13.8,9.83,7.94,6.47,5.27,4.67,4.35,4.11,
     &  3.97,3.84,3.61,3.25,2.93,2.62,2.23,1.83,1.41,1.05,0.768,0.510,
     &  0.318,0.188,0.100,0.051,0.026,0.012,0.0049,0.0025,64*0.0/
C
      DATA SGTC2H5NO3/
     &    15*0.0,2.02,2.72,2.94,2.90,2.84,2.74,2.60,2.57,2.67,2.90,
     &    3.04,3.18,3.35,3.59,3.74,4.00,4.40,4.80,5.19,5.86,6.72,
     &    7.9,8.6,10.4,12.9,14.1,15.6,64*0.0/
C
C JPL 2006; MCMv3.1 data
C TEMPERATURE DEPENDENCE 1e10-3.
C
      DATA SGRN10NO3/
     &  1180.5,1014.4,844.2,678.2,525.3,394.5,287.4,201.0,134.5,88.7,
     &  61.1,44.1,32.0,23.3,17.0,12.4,9.30,7.20,5.85,5.04,4.63,4.41,
     &  4.16,3.88,3.61,3.32,3.04,2.72,2.33,1.93,1.51,1.15,0.850,
     &  0.523,0.328,0.188,0.1,0.053,0.031,0.022,0.018,0.016,64*0/
C
C jpl 2006 VALUES AT 298K
C
      DATA SGAIC3H7NO3/
     & 1181.1,1020.6,856.5,691.6,535.6,399.6,289.4,207.6,150.7,109.1,
     & 76.9,54.3,39.9,29.4,20.7,14.8,11.5,8.81,6.78,5.69,5.19,4.91,
     & 4.71,4.52,4.31,4.03,3.70,3.30,2.83,2.36,1.85,1.43,1.09,0.727,
     & 0.483,0.287,0.170,0.085,0.044,0.022,0.011,0.0053,0.0018,
     & 0.0008,0.00029,0.00018,60*0.0/
C
      DATA SGTIC3H7NO3/
     & 17*0.0,2.76,2.69,2.55,2.48,2.50,2.55,2.65,2.80,3.01,3.19,3.35,
     & 3.58,3.89,4.22,4.55,4.94,5.50,6.15,6.92,8.1,9.4,11.1,11.9,
     & 14.0,13.9,13.9,13.9,13.9,13.9,60*0.0/
C
C TEMPERATURE DEPENDENCE 1e10-3.	
C jpl 2006 VALUES AT 298K	  	  
C
C QUANTUM YIELDS (VALUES FOR OZONE ARE SET LATER )
C
      DATA PNO2/
     &    30*1.00,1.00,0.999,0.998,0.997,0.996,0.995,
     &    0.994,0.993,0.992,0.991,0.990,0.989,0.988,0.987,0.986,
     &    0.984,0.983,0.981,0.979,0.975,0.969,0.960,0.927,0.694,
     &    0.355,0.134,0.060,0.018,0.001,47*0.0/
C
      DATA P1NO3/
     &    90*0.0,0.10,0.25,0.40,0.45,0.35,0.25,
     &    0.15,0.10,0.075,0.05,0.025,5*0.0/
C
      DATA P2NO3/
     &    53*0.0,37*1.0,0.90,0.75,0.60,0.50,0.40,0.30,
     &    0.25,0.15,0.10,0.05,0.00,5*0.0/
C
      DATA P1N2O5/
     &    8*0.0,0.01,0.01,0.02,0.02,0.05,0.05,0.09,0.10,
     &    0.14,0.17,0.21,0.33,0.38,0.47,0.54,0.58,0.63,0.67,
     &    0.70,0.72,0.74,0.76,0.78,0.89,18*1.0,56*0.0/
C
      DATA P1HCHO/
     &    14*0.0,0.11,0.13,
     &    0.21,0.27,0.28,0.29,0.29,0.29,0.30,0.31,0.34,0.37,
     &    0.42,0.49,0.56,0.63,0.69,0.73,0.74,0.75,0.75,0.74,
     &    0.70,0.59,0.46,0.30,0.13,0.02,0.001,63*0.0/
C
      DATA P2HCHO/
     &    14*0.0,0.21,0.25,
     &    0.42,0.49,0.49,0.49,0.49,0.49,0.49,0.48,0.46,0.44,
     &    0.41,0.37,0.32,0.29,0.26,0.24,0.25,0.25,0.25,0.27,
     &    0.33,0.40,0.52,0.67,0.921,0.988,0.999,1.0,1.0,1.0,
     &    60*0.0/
C
      DATA PP2HCHO/
     &    40*0.0,3.36E-4,7.38E-4,1.32E-3,2.26E-3,
     &    4.51E-3,7.75E-3,60*0.0/
C P1HCHO AND P2HCHO FROM JPL (1992) ;
C PP2HCHO VALUES DERIVED FROM JPL (1992) 760 TORR, AND LOW P VALUES ;
C OF MOORTGAT ET AL (1983) ;
C
      DATA P1ACET/
     &    23*0.36,0.38,0.50,0.55,
     &    0.60,0.66,0.76,0.82,0.86,0.90,0.92,0.93,0.94,0.94,
     &    0.90,0.48,0.25,0.10,0.04,0.01,64*0.0/
C
      DATA PP1ACET/
     &    24*2.5E-4,5.7E-4,
     &    6.0E-4,5.2E-4,4.1E-4,4.2E-4,6.1E-4,
     &    7.8E-4,1.01E-3,1.28E-3,1.59E-3,2.09E-3,
     &    3.30E-3,5.65E-3,4.80E-3,6.91E-3,6.00E-3,
     &    3.80E-3,2.50E-3,64*0.0/
C
C P1ACET (LOW P) UNCHANGED ;
C PP1ACET VALUES MODIFIED TO GENERATE 760TORR P1ACET VALUES AS IUPAC
C (1992)
C
C
      DATA PAONE/
     &    20*0.70,0.77,0.79,0.80,0.80,0.78,0.70,
     &    0.61,0.57,0.55,0.50,0.39,0.29,0.21,0.14,0.10,0.05,
     &    0.03,0.03,0.03,0.03,0.03,65*0.0/
C MEYRAHN ET AL (1986)
C
      DATA P1GLY/
     &    44*0.0,22*0.0252,40*0.0/
C BASED ON COMMENTS IN IUPAC (1992) ;
C
      DATA PMGLY/
     &    50*0.11,19*0.045,37*0.0/
C PLUM ET AL (1983) AND TYNDALL (PRIV.COM.1993) ABOVE 380NM
C RABER AND MOORTGAT (1994) SCALED DATA BELOW 380NM
C
      DATA PC2H5CHO/
     &    19*0.0,0.0128,0.133,0.247,0.355,0.455,0.547,0.630,0.703,0.766,
     &    0.817,0.856,0.881,0.891,0.888,0.867,0.764,0.592,0.450,0.345,
     &    0.260,0.194,0.139,0.0869,0.0406,63*0.0/
C   Atkinson et. al. j. chem. phys. 21;6;1992  
C   NO TEMP DEPENDENCE
C
      DATA PUCARB10/
     &    106*0.0036/
C
C IUPAC 2006 less than 0.05 - methacrolein - CH2=C(CH3)CHO
C - Pinho (2005) Atmos. Environ. vol. 39 pg. 1303-1322
C
      DATA PCARB9/
     &    43*1.0,0.995,0.925,0.855,0.785,0.715,0.645,0.575,0.505,0.435,
     &    0.364,0.294,0.224,0.154,0.084,0.014,48*0.0/
C
C IUPAC 2006
C NO TEMPERATURE DEPENDENCE
C
      DATA PNOA56/
     &    19*1.0,0.984,0.916,0.851,0.786,0.724,0.663,0.604,0.548,0.494,
     &    0.443,0.396,0.352,0.312,0.276,0.245,0.221,0.200,0.175,0.150,
     &    0.121,0.100,0.109,0.110,0.070,63*0.0/
        
C	
	  DATA PNOA57/
     &    24*0.0,0.0610,0.162,0.246,0.312,0.358,0.381,0.381,0.351,0.286,
     &    0.220,0.167,0.119,0.0758,0.0430,0.0289,0.0250,0.0277,0.0290,
     &    0.0186,63*0.0/
C
C Roberts and Fajer (1989)
C NO TEMPERATURE DEPENDENCE
C
      DATA LAMBDA/
     &    201.010,203.051,205.134,207.2595,209.4295,
     &    211.646,213.910,216.2225,218.5855,221.001,223.4705,
     &    225.996,228.579,231.2215,233.926,236.6945,
     &    239.5295,242.433,245.408,248.457,251.5825,
     &    254.7875,258.075,261.449,264.9125,268.4685,
     &    272.1215,275.8755,279.734,283.702,287.7845,
     &    291.9865,296.3125,300.7685,305.3610,310.0960,
     &    315.0,320.0,325.0,330.0,335.0,
     &    340.0,345.0,350.0,355.0,360.0,365.0,370.0,375.0,
     &    380.0,385.0,390.0,395.0,400.0,405.0,410.0,415.0,
     &    420.0,425.0,430.0,435.0,440.0,445.0,450.0,455.0,
     &    460.0,465.0,470.0,475.0,480.0,485.0,
     &    490.0,495.0,500.0,505.0,510.0,515.0,520.0,
     &    525.0,530.0,535.0,540.0,545.0,550.0,555.0,560.0,565.0,
     &    570.0,575.0,580.0,585.0,590.0,595.0,600.0,605.0,
     &    610.0,615.0,620.0,625.0,630.0,635.0,
     &    640.0,645.0,650.0,655.0,660.0/
C
      DATA ACONC/215.5,70.15,17.7,7.41,2.45,0.798,0.621
     1    , 0.479,0.369,0.371,0.373,0.376,0.419,0.456
     2    , 0.507,0.547,0.587,0.667,0.735,0.798,0.884
     3    , 0.792,0.678,0.331,0.154,0.0701,0.0578,0.0477
     4    , 0.0394,0.0325 ,0.0268, 0.0219, 0.0178/
C
C      Mid latitude ozone profile from U.S. Standard Atmosphere.
C      (molecules cm-3).   Not used now.
      DATA O3CONC/7.50E+11,7.30E+11,6.80E+11,6.30E+11,
     1    5.80E+11
     1    , 5.75E+11,5.70E+11,6.10E+11,6.50E+11,8.90E+11
     2    , 1.13E+12,1.58E+12,2.02E+12,2.18E+12,2.35E+12
     3    , 2.65E+12,2.95E+12,3.50E+12,4.04E+12,4.40E+12
     4    , 4.77E+12,4.82E+12,4.86E+12,4.70E+12,4.54E+12
     5    , 4.29E+12,4.03E+12,3.64E+12,3.24E+12,2.88E+12
     6    , 2.52E+12,2.27E+12,2.03E+12/
C
      DATA ALBLAND/54*0.05,10*0.06,10*0.08,10*0.10,10*0.11,
     1              8*0.12,4*0.135/
      DATA ALBICE/106*0.75/
C
      DATA TRALOW/ 24*0.30, 4*0.29, 3*0.28,5*0.27,
     1              9*0.26,46*0.25,15*0.24/
      DATA TRAMED/24*0.50,4*0.4925,3*0.4825,5*0.4725,
     1             9*0.4625,  46*0.4525,  15*0.4425/
      DATA TRAHIGH/24*0.90, 9*0.878, 35*0.868,38*0.858/
C
C ********************************************************************
C
C      WRITE OUT INITIAL CONDITIONS
C
 1120 FORMAT(' SINGLE COLUMN PHOTOLYSIS PROGRAMME NPP3',//
     *' ZENITH : ',F6.2,'  TIME OF YEAR : ',F6.2,//
     *' O2 COLUMN ABOVE TOP (MOLECULES/CM^2) : ',1PE12.2,//
     *' O3 COLUMN ABOVE TOP (DOBSON UNITS  ) : ',1PE12.2,/
     *' O3 COLUMN SCALING : ',0PF6.2,//
     *' LAND FRACTION : ',F6.2,' OCEAN FRACTION : ',F6.2,
     *' ICE FRACTION : ',F6.2,//
     *' CLOUD FRACTION IN EACH LAYER : ',/10F6.2//)
C
C ********************************************************************
C
C      O3COL =350.
      MNLEV =NLEV-1
      PNLEV =NLEV+1
      DOBSON = 350.*O3SCALE
C      Number density in molecules/cm^3.
      N0 = (P0*100.0*NA)/(RGC*T0*1.0E6)
C
C
      CALL INTHRI(NN,PU,TU,ZZ,DZ,RI,TT,T0,P0,N0,NLEV)
C SCALE TOTAL AEROSOL COLUMN EXTINCTION BY AEROSOL COLUMN DENSITY
      IF(FIRST) THEN
        AERATT = AERATT/1.97E+7
        AERSCAT = AERSCAT/1.97E+7
        CALL INIAER(AERO,ZZ,ACONC,NLEV)
      ENDIF
C
C MULTIPLY THE INPUT DATA BY THE EXPONENTIAL FACTORS
C
      IF(FIRST) THEN
        DO 20 NL=1,NLAM
          SFLUX(NL)    = SFLUX(NL)*1.0E+14
          RAYLEIGH(NL) = RAYLEIGH(NL)*1.0E-27
          SGO2(NL)     = SGO2(NL)*1.0E-24
          SGAO3(NL)    = SGAO3(NL)*1.0E-20
          SGBO3(NL)    = SGBO3(NL)*1.0E-20
          SGANO2(NL)   = SGANO2(NL)*1.0E-20
          SGTNO2(NL)   = SGTNO2(NL)*1.0E-22
          SGNO3(NL)    = SGNO3(NL)*1.0E-20
          SGHONO(NL)   = SGHONO(NL)*1.0E-20
          SGAHNO3(NL)  = SGAHNO3(NL)*1.0E-20
          SGTHNO3(NL)  = SGTHNO3(NL)*1.0E-03
          SGN2O5(NL)   = SGN2O5(NL)*1.0E-20
          SGAHCHO(NL)  = SGAHCHO(NL)*1.0E-20
          SGBHCHO(NL)  = SGBHCHO(NL)*1.0E-20
          SGAH2O2(NL)  = SGAH2O2(NL)*1.0E-20
          SGBH2O2(NL)  = SGBH2O2(NL)*1.0E-20
          SGCH3OOH(NL) = SGCH3OOH(NL)*1.0E-20
          SGACET(NL)   = SGACET(NL)*1.0E-20
          SGAONE(NL)   = SGAONE(NL)*1.0E-20
          SGGLY(NL)    = SGGLY(NL)*1.0E-20
          SGMGLY(NL)   = SGMGLY(NL)*1.0E-20
          SGHO2NO2(NL) = SGHO2NO2(NL)*1.0E-20
          SGAPAN(NL)   = SGAPAN(NL)*1.0E-20
          SGTPAN(NL)   = SGTPAN(NL)*1.0E-03
          SGC2H5CHO(NL)   = SGC2H5CHO(NL)*1.0E-20
          SGMEK(NL)   = SGMEK(NL)*1.0E-20
          SGBUTANAL(NL)   = SGBUTANAL(NL)*1.0E-20
          SGUCARB10(NL)   = SGUCARB10(NL)*1.0E-20
          SGCARB9(NL)  = SGCARB9(NL)*1.0E-20
          SGNOA(NL) = SGNOA(NL)*1.0E-20
          SGACH3NO3(NL) = SGACH3NO3(NL)*1.0E-20
          SGTCH3NO3(NL) = SGTCH3NO3(NL)*1.0E-03
          SGAC2H5NO3(NL) = SGAC2H5NO3(NL)*1.0E-20
          SGTC2H5NO3(NL) = SGTC2H5NO3(NL)*1.0E-03
          SGRN10NO3(NL) = SGRN10NO3(NL)*1.0E-20
          SGAIC3H7NO3(NL) = SGAIC3H7NO3(NL)*1.0E-20
          SGTIC3H7NO3(NL) = SGTIC3H7NO3(NL)*1.0E-03
   20   CONTINUE
      ENDIF
      CALL INIO3(OZONE,TDOB,O2N,ZZ,O3SCALE,O3,O3TOP,NN,NLEV,DZ)
      TDOB=50. ! ****FIXED DOBSONS TO 50.***
C
C ********************************************************************
C
C
      DO ICHEM=1,96
        DO J=1,NLEV
          P(ICHEM,J)=0
        ENDDO
      ENDDO
      ZENITH=ZEN(TIME,LAT,LONG)

C      Write out initial conditions.
      IF(FIRST) THEN
        WRITE(6,1120) ZENITH,YEAR,O2COL,O3COL,O3SCALE,
     &              FRLAND,FROCEAN,FRICE,CLOUD
      ENDIF
      IF (COS(ZENITH).GT.0.) THEN
        CALL FLUX0(FLUXUP,FLUXDN,PNLEV,NLAM)
        CALL MMCALC(SSEC,MMTOP,COSSURF,ZENITH)
        CALL CLOUDS(TRAC0,TRAC1,ALBC0,ALBC1,TRALOW,TRAMED,TRAHIGH,
     &      SSEC,RI,ASCAT,NLAM,NLEV)
        CALL SURALB(ALB0SURF,ALB1SURF,COSSURF,ASCAT,ALBLAND,FRLAND,NLAM)
C
C CALCULATE THE ATTENUATION FACTORS FOR ABSORPTION AND SCATTER
        DO 100 J = NLEV,0,-1
C
          CCOS(J) = SQRT(1.0-((SSEC/RI(J))**2))
          MM = 1.0/CCOS(J)
          CALL ATTEN(ATTA0(1,J),ATTS0(1,J),FRBK0(1,J),FRFD0(1,J),SGAO3,
     &        SGBO3,SGO2,TT(J),DZ(J),OZONE(J),MM,AERATT,AERO(J),NN(J),
     &        RAYLEIGH,ALBC0(1,J),CLOUD(J),TRAC0(1,J),O2N(J),AERSCAT)
          CALL ATTEN(ATTA1(1,J),ATTS1(1,J),FRBK1(1,J),FRFD1(1,J),SGAO3,
     &        SGBO3,SGO2,TT(J),DZ(J),OZONE(J),ASCAT,AERATT,AERO(J),
     &        NN(J),
     &        RAYLEIGH,ALBC1(1,J),CLOUD(J),TRAC1(1,J),O2N(J),AERSCAT)
C
C
  100   CONTINUE
C
C
C CALCULATION OF THE SOLAR FLUXES THROUGH THE MODEL DOMAIN
C INCLUDING THE 2COS(THETA) FACTOR WHICH OCCURS IN THE ACTINIC FLUX
C WHEN A DIRECT BEAM IS SCATTERED ISOTROPICALLY.
C Subtract tropospheric dobson units from o3col to take acount of ozone
C column within the model.
        CALL INCFLX(FLUXDN(1,1,PNLEV),SFLUX,YEAR,O2COL,SGO2,
     &      O3SCALE*(O3COL-TDOB)*1.0E-3*N0,SGAO3,SGBO3,MMTOP,NLAM)
C
        CALL CALFLX(FLUXDN,FLUXUP,ATTA0,ATTS0,ATTA1,ATTS1,CCOS,COSSURF,
     &      ALB0SURF,ALB1SURF,FRBK0,FRFD0,FRBK1,FRFD1,NLAM,NLEV)
C
        DO 350 J = 1,NLEV
C
          CALL GETO3(P1O3,TU(J),LAMBDA)
      BR01(J) = (0.156 + 9.77D+08*EXP(-6415/TU(J))) 
C
          CALL GETSIG(SGO3,SGNO2,SGHNO3,SGHCHO,SGN2O5,SGH2O2,TU(J),
     &      LAMBDA,SGAO3,SGBO3,SGAHNO3,SGTHNO3,SGAHCHO,SGBHCHO,SGAH2O2,
     &      SGBH2O2,SGANO2,SGTNO2,SGPAN,SGAPAN,SGTPAN,SGCH3NO3,
     &      SGACH3NO3,SGTCH3NO3,SGC2H5NO3,SGAC2H5NO3,SGTC2H5NO3,
     &      SGIC3H7NO3,SGAIC3H7NO3,SGTIC3H7NO3,NLAM)
C
C
          CALL TOTFLX(FLUXTOT(1,J),FLUXUP(1,1,J),FLUXDN(1,1,J),NLAM)

C
C
          J1O3(J)=0.0
          J2O3(J)=0.0
          JNO2(J)=0.0
          J1NO3(J)=0.0
          J2NO3(J)=0.0
          J1N2O5(J)=0.0
          JHNO3(J)=0.0
          JHONO(J)=0.0
          J1HCHO(J)=0.0
          J2HCHO(J)=0.0
          JH2O2(J)=0.0
          JCH3OOH(J)=0.0
          J1ACET(J)=0.0
          JAONE(J)=0.0
          J1GLY(J)=0.0
          JMGLY(J)=0.0
          JHO2NO2(J)=0.0
          JPAN(J)=0.0
          JCH3COCH3(J) = 0.0
          JUCARB10(J) = 0.0
          JCARB3(J) = 0.0
          JCARB6(J) = 0.0
          JCARB9(J) = 0.0
          JCARB12(J) = 0.0
          JCARB15(J) = 0.0
          JUCARB12(J) = 0.0
          JNUCARB12(J) = 0.0
          JHOCH2CHO(J) = 0.0
          JTNCARB10(J) = 0.0
          JCH3NO3(J) = 0.0
          JC2H5NO3(J) = 0.0
          JRN10NO3(J) = 0.0
          JIC3H7NO3(J) = 0.0
          JC2H5CHO(J) = 0.0
          JMEK(J) = 0.0
          JBUTANAL(J) = 0.0
          JCARB9(J) = 0.0
          JANOA(J) = 0.0
          JBNOA(J) = 0.0
C
          DO 420 NL=1,NLAM
C
            J1O3(J)    = J1O3(J) + FLUXTOT(NL,J)*SGO3(NL)*P1O3(NL)
            J2O3(J)    = J2O3(J) + FLUXTOT(NL,J)*SGO3(NL)*(1.0-P1O3(NL))
            JNO2(J)    = JNO2(J) + FLUXTOT(NL,J)*SGNO2(NL)*PNO2(NL)
            J1NO3(J)   = J1NO3(J) + FLUXTOT(NL,J)*SGNO3(NL)*P1NO3(NL)
            J2NO3(J)   = J2NO3(J) + FLUXTOT(NL,J)*SGNO3(NL)*P2NO3(NL)
            J1N2O5(J)  = J1N2O5(J) + FLUXTOT(NL,J)*SGN2O5(NL)*P1N2O5(NL)
            JHNO3(J)   = JHNO3(J) + FLUXTOT(NL,J)*SGHNO3(NL)
            JHONO(J)   = JHONO(J) + FLUXTOT(NL,J)*SGHONO(NL)
            J1HCHO(J)  = J1HCHO(J) + FLUXTOT(NL,J)*SGHCHO(NL)*P1HCHO(NL)
            J2HCHO(J)  = J2HCHO(J) + FLUXTOT(NL,J)*SGHCHO(NL)
     &           *(P2HCHO(NL)/(1.0+(PU(J)*PP2HCHO(NL))))
            JH2O2(J)   = JH2O2(J) + FLUXTOT(NL,J)*SGH2O2(NL)
            JCH3OOH(J) = JCH3OOH(J) + FLUXTOT(NL,J)*SGCH3OOH(NL)
            J1ACET(J)  = J1ACET(J) + FLUXTOT(NL,J)*SGACET(NL)
     &           *(P1ACET(NL)/(1.0+(PU(J)*PP1ACET(NL))))
            JAONE(J)   = JAONE(J) + FLUXTOT(NL,J)*SGAONE(NL)*PAONE(NL)
            J1GLY(J)   = J1GLY(J) + FLUXTOT(NL,J)*SGGLY(NL)*P1GLY(NL)
            JMGLY(J)   = JMGLY(J) + FLUXTOT(NL,J)*SGMGLY(NL)*PMGLY(NL)
            JHO2NO2(J) = JHO2NO2(J) + FLUXTOT(NL,J)*SGHO2NO2(NL)
            JPAN(J)    = JPAN(J) + FLUXTOT(NL,J)*SGPAN(NL)
            JC2H5CHO(J) = JC2H5CHO(J) + FLUXTOT(NL,J)*SGC2H5CHO(NL)
     &           *PC2H5CHO(NL)
           JMEK(J) = JMEK(J) + (FLUXTOT(NL,J)*SGMEK(NL)*0.34)
        JBUTANAL(J) = JBUTANAL(J) + (FLUXTOT(NL,J)*SGBUTANAL(NL)*0.30)
           JUCARB10(J) = JUCARB10(J) + (FLUXTOT(NL,J)*SGUCARB10(NL)
     &           *PUCARB10(NL))
           JCARB9(J) = JCARB9(J) +  FLUXTOT(NL,J)*SGCARB9(NL)*PCARB9(NL)
           JANOA(J) = JANOA(J) + FLUXTOT(NL,J)*SGNOA(NL)*PNOA56(NL)
           JBNOA(J) = JBNOA(J) + FLUXTOT(NL,J)*SGNOA(NL)*PNOA57(NL)
           JCH3NO3(J)    = JCH3NO3(J) + FLUXTOT(NL,J)*SGCH3NO3(NL)
           JC2H5NO3(J)    = JC2H5NO3(J) + FLUXTOT(NL,J)*SGC2H5NO3(NL)
           JRN10NO3(J)    = JRN10NO3(J) + FLUXTOT(NL,J)*SGRN10NO3(NL)
       JIC3H7NO3(J) = JIC3H7NO3(J) + FLUXTOT(NL,J)*SGIC3H7NO3(NL)
  420     CONTINUE
C
C CORRECT J2O3 TO COMPENSATE FOR NEGLECTING LONGER WAVELENGTHS.
C
          J2O3(J) = J2O3(J)+(10.0*FLUXTOT(106,J)*SGO3(106))
C
C AIS -ALREADY IN STOCHEM
          P(1,J)=J1O3(J)
          P(2,J)=J2O3(J)
          P(3,J)=JH2O2(J)
          P(4,J)=JNO2(J)
          P(5,J)=J1NO3(J)
          P(6,J)=J2NO3(J)
          P(7,J)=JHONO(J)
          P(8,J)=JHNO3(J)
          P(9,J)=J1HCHO(J)
          P(10,J)=J2HCHO(J)
          P(11,J)=J1ACET(J)		!JCH3CHO - J<13>- AIS
          P(12,J)=JC2H5CHO(J)		!JC2H5CHO(J) - J<14>
          P(13,J)=JAONE(J)		!JCH3COCH3 - J<21> - AIS
          P(14,J)=JMEK(J) 	     	!MEK - J<22>
          P(15,J)=P(14,J)*4.74   	!CARB14 - J<22>*4.74
          P(16,J)=P(14,J)*1.33   	!CARB17 - J<22>*1.33
          P(17,J)=P(14,J)	   	!CARB11A - J<22>
          P(18,J)=P(14,J)	   	!CARB7 - J<22>
          P(19,J)=P(14,J)	   	!CARB10 - J<22>
          P(20,J)=P(14,J)*3.00   	!CARB13 - J<22>*3.00
          P(21,J)=P(14,J)*3.55   	!CARB16 - J<22>*3.55
          P(22,J)=JBUTANAL(J)		!JHOCH2CHO(J), J<15> same as C3H7CHO
          P(23,J)=JUCARB10(J)*2.00	!JUCARB10(J) - J<18>*2
          P(24,J)=J1GLY(J)		!JCARB3(J) - J<33> - AIS
          P(25,J)=JMGLY(J)		!JCARB6(J) - J<34> - AIS
          P(26,J)=JCARB9(J)		!JCARB9(J) - J<35>
          P(27,J)=JCARB9(J)		!JCARB12(J) - J<35>
          P(28,J)=JCARB9(J)		!JCARB15(J) - J<35>
          P(29,J)=JUCARB10(J)*2.00	!JUCARB12(J)	!J<18>*2
          P(30,J)=JUCARB10(J)	        !JNUCARB12(J)	!J<18>
          P(31,J)=JANOA(J)		!JNOA(J) - J(56)
          P(32,J)=JBNOA(J)		!JNOA(J) - J(57)
          P(33,J)=JNO2(J)*0.02*0.64	!JUDCARB8
          P(34,J)=JNO2(J)*0.02*0.36	!JUDCARB8
          P(35,J)=JNO2(J)*0.02*0.55	!JUDCARB11
          P(36,J)=JNO2(J)*0.02*0.45	!JUDCARB11
          P(37,J)=JNO2(J)*0.02*0.55	!JUDCARB14
          P(38,J)=JNO2(J)*0.02*0.45	!JUDCARB14
          P(39,J)=P(22,J)       	!JTNCARB26 - J<15> 
          P(40,J)=JCARB9(J)*0.5		!JTNCARB10(J) - J(35)*0.5
          P(41,J)=JCH3NO3(J)		!JCH3NO3(J) - J(51)
          P(42,J)=JC2H5NO3(J)		!JC2H5NO3(J) - J(52)
          P(43,J)=JRN10NO3(J)		!JRN10NO3(J) - J(53)
          P(44,J)=JIC3H7NO3(J) 		!JIC3H7NO3(J) - J(54)
          P(45,J)=JRN10NO3(J)*0.398	!JRN13NO3 - J<53>*0.398
          P(46,J)=JRN10NO3(J)*0.602	!JRN13NO3 - J<53>*0.602
          P(47,J)=JRN10NO3(J)		!JRN16NO3 - J<53>
          P(48,J)=JRN10NO3(J)		!JRN19NO3 - J<53>
          P(49,J)=JIC3H7NO3(J)		!RA13NO3 - J<54>
          P(50,J)=JIC3H7NO3(J)		!JRA16NO3 - J<54>
          P(51,J)=JIC3H7NO3(J)		!RA19NO3 - J<54>
          P(52,J)=JIC3H7NO3(J)		!RTX24NO3 - J<54>
          P(53,J)=JCH3OOH(J)		!J(41)
          P(54,J)=JCH3OOH(J)		!C2H5OOH 
          P(55,J)=JCH3OOH(J)		!RN10OOH 
          P(56,J)=JCH3OOH(J)		!IC3H7OOH 
          P(57,J)=JCH3OOH(J)*BR01(J)		!RN13OOH 
          P(58,J)=JCH3OOH(J)*(1.0-BR01(J))		!RN13OOH 
          P(59,J)=JCH3OOH(J)		!RN16OOH 
          P(60,J)=JCH3OOH(J)		!RN19OOH 
          P(61,J)=JCH3OOH(J)		!CH3CO3H 
          P(62,J)=JCH3OOH(J)		!C2H5CO3H 
          P(63,J)=JCH3OOH(J)		!HOCH2CO3H 
          P(64,J)=JCH3OOH(J)		!RN8OOH 
          P(65,J)=JCH3OOH(J)		!RN11OOH 
          P(66,J)=JCH3OOH(J)		!RN14OOH 
          P(67,J)=JCH3OOH(J)		!RN17OOH 
          P(68,J)=JCH3OOH(J)*0.252		!RU14OOH 
          P(69,J)=JCH3OOH(J)*0.748		!RU14OOH 
          P(70,J)=JCH3OOH(J)		!RU12OOH 
          P(71,J)=JCH3OOH(J)		!RU10OOH 
          P(72,J)=JCH3OOH(J)		!NRU14OOH 
          P(73,J)=JCH3OOH(J)		!NRU12OOH 
          P(74,J)=JCH3OOH(J)		!HOC2H4OOH 
          P(75,J)=JCH3OOH(J)		!RN9OOH 
          P(76,J)=JCH3OOH(J)		!RN12OOH 
          P(77,J)=JCH3OOH(J)		!RN15OOH 
          P(78,J)=JCH3OOH(J)		!RN18OOH 
          P(79,J)=JCH3OOH(J)		!NRN6OOH 
          P(80,J)=JCH3OOH(J)		!NRN9OOH 
          P(81,J)=JCH3OOH(J)		!NRN12OOH 
          P(82,J)=JCH3OOH(J)		!RA13OOH 
          P(83,J)=JCH3OOH(J)		!RA16OOH 
          P(84,J)=JCH3OOH(J)		!RA19OOH 
          P(85,J)=JCH3OOH(J)		!RTN28OOH
          P(86,J)=JCH3OOH(J)		!NRTN28OOH
          P(87,J)=JCH3OOH(J)		!RTN26OOH
          P(88,J)=JCH3OOH(J)		!RTN25OOH
          P(89,J)=JCH3OOH(J)		!RTN24OOH
          P(90,J)=JCH3OOH(J)		!RTN23OOH
          P(91,J)=JCH3OOH(J)		!RTN14OOH
          P(92,J)=JCH3OOH(J)		!RTN10OOH
          P(93,J)=JCH3OOH(J)		!RTX28OOH
          P(94,J)=JCH3OOH(J)		!RTX24OOH
          P(95,J)=JCH3OOH(J)		!RTX22OOH
          P(96,J)=JCH3OOH(J)		!NRTX28OO
          P(97,J)=JCH3OOH(J)		!NRTX28OO
          P(98,J)=JCH3OOH(J)		!NRTX28OO
          P(99,J)=JCH3OOH(J)		!NRTX28OO
          P(100,J)=JCH3OOH(J)		!NRTX28OO
          P(101,J)=JCH3OOH(J)		!NRTX28OO
          P(102,J)=JCH3OOH(J)		!NRTX28OO
          P(103,J)=JCH3OOH(J)		!NRTX28OO
          P(104,J)=JCH3OOH(J)		!NRTX28OO
          P(105,J)=JCH3OOH(J)		!NRTX28OO
          P(106,J)=JCH3OOH(J)		!NRTX28OO
          P(107,J)=JCH3OOH(J)		!NRTX28OO
          P(108,J)=JCH3OOH(J)		!NRTX28OO
          P(109,J)=JCH3OOH(J)		!NRTX28OO
          P(110,J)=JCH3OOH(J)		!NRTX28OO
          P(111,J)=JCH3OOH(J)		!NRTX28OO
          P(112,J)=JCH3OOH(J)		!NRTX28OO
          P(113,J)=JCH3OOH(J)		!NRTX28OO
          P(114,J)=JCH3OOH(J)		!NRTX28OO
          P(115,J)=JCH3OOH(J)		!NRTX28OO
          P(116,J)=JCH3OOH(J)		!NRTX28OO
          P(117,J)=JCH3OOH(J)		!NRTX28OO
          P(118,J)=JCH3OOH(J)		!NRTX28OO
          P(119,J)=JCH3OOH(J)		!NRTX28OO
          P(120,J)=JCH3OOH(J)		!NRTX28OO
          P(121,J)=JCH3OOH(J)		!NRTX28OO
          P(122,J)=JCH3OOH(J)		!NRTX28OO
          P(123,J)=JCH3OOH(J)		!NRTX28OO
          P(124,J)=JCH3OOH(J)		!NRTX28OO
          P(125,J)=JCH3OOH(J)		!NRTX28OO
          P(126,J)=JCH3OOH(J)		!NRTX28OO
          P(127,J)=JCH3OOH(J)		!NRTX28OO
          P(128,J)=JCH3OOH(J)		!NRTX28OO
          P(129,J)=JCH3OOH(J)		!NRTX28OO
          P(130,J)=JCH3OOH(J)		!NRTX28OO
          P(131,J)=JCH3OOH(J)		!NRTX28OO
          P(132,J)=JCH3OOH(J)		!NRTX28OO
          P(133,J)=JCH3OOH(J)		!NRTX28OO
          P(134,J)=JCH3OOH(J)		!NRTX28OO
          P(135,J)=JCH3OOH(J)		!NRTX28OO
          P(136,J)=JCH3OOH(J)		!NRTX28OO
          P(137,J)=JCH3OOH(J)		!NRTX28OO
          P(138,J)=JCH3OOH(J)		!NRTX28OO
          P(139,J)=JCH3OOH(J)		!NRTX28OO
          P(140,J)=JCH3OOH(J)		!NRTX28OO
          P(141,J)=JCH3OOH(J)		!NRTX28OO
          P(142,J)=JCH3OOH(J)		!NRTX28OO
          P(143,J)=JCH3OOH(J)		!NRTX28OO

C          P(8,J)=J1ACET(J)
C          P(9,J)=JAONE(J)
C          P(10,J)=JHO2NO2(J)
C          P(11,J)=JMGLY(J)
C          P(12,J)=J1GLY(J)
C          
C          P(15,J)=J1N2O5(J)
C          P(16,J)=JCH3OOH(J)
C          P(17,J)=JPAN(J)
  350   CONTINUE
      ENDIF
      FIRST=.FALSE.
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INTHRI(NN,PU,TU,ZZ,DZ,RI,TT,T0,P0,N0,NLEV)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : INITALISE TEMPERATURES,HEIGHTS,REFRACTIVE INDEX
C-
C-   Inputs  : TT,T0,PP,P0,NLEV,N0
C-   Outputs : PU,TU,ZZ,DZ,RI
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-   Modified 23-OCT-1995   Colin Johnson  To use meteorological data to
C-                                         find thicknesses.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLEV
      REAL TU(NLEV),ZZ(0:NLEV),DZ(0:NLEV),RI(0:NLEV),TT(0:NLEV),T0,
     &    PP(0:9),P0,PU(NLEV),NN(0:NLEV),N0,ZU(9),A(9),B(9)
      INTEGER J
      REAL HZ,RGC,G,MAIR
      DATA MAIR/28.97/,RGC/8.314/,G/9.81/
C      A and B are used to define eta3 grid pressures.
C      These values are interpolated from the UM documented values.
      DATA A / 0.0, 3.87, 24.08, 58.09, 96.43, 129.93, 146.87,
     &         136.70, 89.14 /
      DATA B / 0.90, 0.79613, 0.67549, 0.54141, 0.40357, 0.27007,
     &         0.15313, 0.06330, 0.01086 /
C
C      Find pressures corresponding to the eta3 levels.
      DO J=1,NLEV
        PP(J)=A(J)+B(J)*P0
      ENDDO
C
C      Interpolate temperatures to mid layer.
      TU(1)=(T0+TT(1))/2.0
      DO J=2,NLEV
        TU(J)=(TT(J-1)+TT(J))/2.0
      ENDDO
C
C      Find the heights corresponding to the pressure levels.
      DO 7 J = 1,NLEV
        HZ=(RGC*TU(J))/(G*MAIR)
        IF(J.GT.1) THEN
          DZ(J)=(LOG(PP(J)/PP(J-1))*(-HZ))
          ZZ(J)=ZZ(J-1)+DZ(J)
          ZU(J)=ZZ(J-1)+(DZ(J)/2.0)
        ELSE
          DZ(J)=LOG(PP(1)/P0)*(-HZ)
          ZZ(J)=DZ(1)
          ZU(J)=DZ(1)/2.0
        ENDIF
        PU(J) = PP(J)*EXP(DZ(J)/(2.0*HZ))
    7 CONTINUE
C
C      Calculate the thicknesses between the half levels
      DO 10 J=1,NLEV
        IF(J.EQ.NLEV) THEN
          DZ(J)=ZZ(J)-ZU(J)
        ELSE
          DZ(J)=ZU(J+1)-ZU(J)
        ENDIF
   10 CONTINUE
C
C      Calculate values for the bottom layer.
      TT(0) = (T0+TU(1))/2.0
      HZ=(RGC*TT(0))/(G*MAIR)
      ZZ(0) = ZZ(1)/4.0
      DZ(0) = ZU(1)
      PP(0) = P0*EXP(-ZZ(0)/HZ)
C
C SET THE REFRACTIVE INDEX AT THE TOP OF EACH LEVEL IN THE MODEL
C Convert DZ to cm.
C
C      WRITE(6,*) '  T0 =   ',T0,'  P0 =   ',P0
C      WRITE(6,*) '   PP(J)','     TT(J)','     ZZ(J)','     DZ(J)',
C     &           '    ZU(J)','     PU(J)'
      DO 8 J = 0,NLEV
        NN(J) = N0*(PP(J)/1000.0)*(T0/TT(J))
        RI(J) = 1.0+(0.00029*(PP(J)/1000.0))
        DZ(J)=DZ(J)*1.0E+5
C        IF(J.EQ.0) THEN
C         WRITE(6,100) PP(J),TT(J),ZZ(J),DZ(J)
C        ELSE
C         WRITE(6,100) PP(J),TT(J),ZZ(J),DZ(J),ZU(J),PU(J)
C        ENDIF
    8 CONTINUE
  100 FORMAT(6F10.2)
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INIAER(AERO,ZZ,ACONC,NLEV)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : INITIALISE AEROSOLS
C-
C-   Inputs  : ZZ,ACONC,NLEV
C-   Outputs : AERO
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLEV,AH,AL,J
      REAL ZZ(0:NLEV),ACONC(33),AERO(0:NLEV),ACF,DELZ
C
C SET THE AEROSOL CONCENTRATIONS CENTRED ON THE TOP OF EACH LAYER
C USING EXPONENTIAL INTERPOLATION.
C
      DO 10 J = 0,NLEV
        AL = IFIX(ZZ(J))+1
        AH = AL+1
        DELZ = ZZ(J)+1.0-FLOAT(AL)
        ACF = ALOG(ACONC(AL)/ACONC(AH))
        AERO(J) = ACONC(AL)*EXP(-ACF*DELZ)
   10 CONTINUE
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE FLUX0(FLUXUP,FLUXDN,PNLEV,NLAM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : ZERO FLUXES
C-
C-   Inputs  : PNLEV,NLAM
C-   Outputs : FLUXUP,FLUXDN
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER PNLEV,NLAM,JP,I,NL
      REAL FLUXUP(NLAM,6,0:PNLEV),FLUXDN(NLAM,6,0:PNLEV)
C
      DO 35 JP=0,PNLEV
        DO 32 I=1,6
          DO 30 NL=1,NLAM
            FLUXUP(NL,I,JP) = 0.0
            FLUXDN(NL,I,JP) = 0.0
   30     CONTINUE
   32   CONTINUE
   35 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INIO3(OZONE,TDOB,O2N,ZZ,O3SCALE,O3,O3TOP,NN,NLEV,DZ)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : INITIALISE O3 CONCENTRATIONS
C-
C-   Inputs  : ZZ,O3SCALE,O3,NN,O3TOP
C-   Outputs : OZONE,O2N,TDOB
C-   Controls: Minimum tropospheric dobson units set at 15.
C-
C-   Created   3-JUN-1994   Bill Collins
C-   Revised   5-OCT-1995   Colin Johnson  Now uses model Eulerian ozone
C-                                         Profile, and calculates
C-                                         tropospheric dobson units.
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLEV,J,AL,AH
      REAL ZZ(0:NLEV),O3SCALE,O3(NLEV),O2N(0:NLEV),DELZ,
     &     NN(0:NLEV),OZONE(0:NLEV),DZ(0:NLEV),TDOB,O3TOP
C
C SET THE PROFILES OF OXYGEN AND OZONE AT THE TOP OF EACH LAYER ;
C APPROPRIATE TO AN AVERAGE OVER THE TWO NEIGHBOURING HALF-LAYERS.
C
C      Set O3 at level 0 to the half level value.
C      Set O3 at top of uppermost level to be average of half level below
C      at ozone at 100 mb.
      DO 50 J = 0,NLEV
        IF(J.LT.1) THEN
          OZONE(J) = O3SCALE*NN(J)*O3(J+1)
        ELSEIF(J.EQ.NLEV) THEN
C          WRITE(6,*) 'O3(NLEV),O3TOP: ',O3(J),O3TOP
          OZONE(J) = O3SCALE*NN(J)*(O3(J)+O3TOP)/2.0
        ELSE
          OZONE(J) = O3SCALE*NN(J)*(O3(J)+O3(J+1))/2.0
        ENDIF
        O2N(J) = 0.2095*NN(J)
   50 CONTINUE
C      WRITE(6,*) 'O3 MIXING RATIO',(O3(J),J=1,NLEV)
C      WRITE(6,*) 'OZONE PROFILE: ',(OZONE(J),J=0,NLEV)
C
      TDOB=0.0
      DO 60 J = 1,NLEV
        TDOB=TDOB+O3SCALE*O3(J)*NN(J)*DZ(J)/2.69E16
   60 CONTINUE
      TDOB=MAX(TDOB,15.0)
C      WRITE(6,*) 'Number Density ',(NN(J),J=1,NLEV)
C      WRITE(6,*) 'Thickness      ',(DZ(J),J=1,NLEV)
C      WRITE(6,*) 'TROPOSPHERIC DOBSON: ',TDOB
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE MMCALC(SSEC,MMTOP,COSSURF,ZENITH)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE FLUX ANGLES
C-
C-   Inputs  : ZENITH
C-   Outputs : SSEC,MMTOP,COSSURF
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      REAL SSEC,MMTOP,COSSURF,ZENITH,RADIUS,RADCOS,SEC
      DATA RADIUS/6370.949/
C CALCULATION OF THE EXPONENTIAL MM FACTOR FOR FLUX ATTENUATION
C
C FIRST ALLOW FOR THE CURVATURE OF THE EARTH (TO PRODUCE SEC)
C THEN FOR THE ATMOSPHERIC REFRACTION
C CHECK FOR ROUNDING ERRORS WHICH COULD CAUSE A NEGATIVE SQUARE ROOT
C
      RADCOS = 2.0*RADIUS*COS(ZENITH)
      SEC = ((SQRT((RADCOS**2)+(57.6*RADIUS)+207.36))-RADCOS)/14.4
      SEC = AMAX1(1.0,SEC)
      SSEC = SQRT(1.0-(1.0/SEC)**2)
      MMTOP = SEC
      COSSURF = SQRT(1.0-((SSEC/1.00029)**2))
C
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CLOUDS(TRAC0,TRAC1,ALBC0,ALBC1,TRALOW,TRAMED,TRAHIGH,
     &    SSEC,RI,ASCAT,NLAM,NLEV)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : SET THE CLOUD COVER, TRANSMISSION AND ALBEDO
C-
C-   Inputs  : TRALOW,TRAMED,TRAHIGH,SSEC,RI,ASCAT
C-   Outputs : TRAC0,TRAC1,ALBC0,ALBC1
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NLEV,NL,J
      REAL TRAC0(NLAM,0:NLEV),TRAC1(NLAM,0:NLEV),ALBC0(NLAM,0:NLEV),
     &    ALBC1(NLAM,0:NLEV),TRALOW(NLAM),TRAMED(NLAM),TRAHIGH(NLAM),
     &    SSEC,RI(0:NLEV),ASCAT,MM
C
C
      DO 80 NL=1,NLAM
C
        DO 75 J=1,NLEV
          MM = 1.0/SQRT(1.0-((SSEC/RI(J))**2))
          IF(J.LE.3) THEN
            TRAC0(NL,J) =TRALOW(NL)-(0.01*MM)
            TRAC1(NL,J)=TRALOW(NL)-(0.01*ASCAT)
          ELSEIF(J.LE.6) THEN
            TRAC0(NL,J)=TRAMED(NL)-(0.0125*MM)
            TRAC1(NL,J)=TRAMED(NL)-(0.0125*ASCAT)
          ELSE
            TRAC0(NL,J)=TRAHIGH(NL)-(0.018*MM)
            TRAC1(NL,J)=TRAHIGH(NL)-(0.018*ASCAT)
          ENDIF
C
          TRAC0(NL,J) = MAX(TRAC0(NL,J),0.0)
          TRAC1(NL,J) = MAX(TRAC1(NL,J),0.0)
          ALBC0(NL,J) = 1.0-TRAC0(NL,J)
          ALBC1(NL,J) = 1.0-TRAC1(NL,J)
   75   CONTINUE
C
   80 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE SURALB(ALB0SURF,ALB1SURF,COSSURF,ASCAT,ALBLAND,
     &    FRLAND,NLAM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE THE SURFACE ALBEDO
C-
C-   Inputs  : COSSURF,ASCAT,ALBLAND,FRLAND
C-   Outputs : ALB0SURF,ALB1SURF
C-   Controls:
C-
C-   Created   3-JUN-1994   Bill Collins
C-   Updated  13-MAR-1995   D Stevenson - set ice albedo to 1 to stop NaN on HP
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NL
      REAL F0COST,F1COST,ALBOCEAN(106),ALB0SURF(NLAM),ALB1SURF(NLAM),
     &    ALBLAND(NLAM),FRLAND,FRICE,FROCEAN,COSSURF,ASCAT,ALBICE(106)
C
C
      FRICE=0.
      FROCEAN=1.-FRLAND
      COSSURF = MAX(COSSURF,0.3)
C
      F0COST = 1.6/COSSURF
      F1COST = 1.6*ASCAT
C
      DO 85 NL=1,NLAM
        ALBICE(NL)=1.0
        ALBOCEAN(NL) = ALBLAND(NL)*F0COST
        ALB0SURF(NL) =  (FRLAND*ALBLAND(NL))+
     1              (FROCEAN*ALBOCEAN(NL))+(FRICE*ALBICE(NL))
        ALBOCEAN(NL) = ALBLAND(NL)*F1COST
        ALB1SURF(NL) = (FRLAND*ALBLAND(NL))+
     1              (FROCEAN*ALBOCEAN(NL))+(FRICE*ALBICE(NL))
C  **** SET SURFACE TO 100% LAND ****
C        ALB0SURF(NL) =  ALBLAND(NL)
C        ALB1SURF(NL) =  ALBLAND(NL)
   85 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE ATTEN(ATTA,ATTS,FRBK,FRFD,SGAO3,SGBO3,SGO2,TT,DZ,OZONE,
     &    MM,AERATT,AERO,NN,RAYLEIGH,ALBC,CLOUD,TRAC,O2N,AERSCAT)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculate attenuation factors for absorption and
C-                         scatter
C-
C-   Inputs  : SGAO3,SGBO3,SGO2,TT,DZ,OZONE,MM,AERATT,AERO,NN,RAYLEIGH,
C-             ALBC,CLOUD,TRAC,O2N
C-   Outputs : ATTA,ATTS,FRBK,FRFD
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NL
      PARAMETER (NLAM=106)
      REAL ATTA(NLAM),ATTS(NLAM),FRBK(NLAM),FRFD(NLAM)
      REAL SGO3,SGAO3(NLAM),SGBO3(NLAM),SGO2(NLAM),DZ,MM,OZONE,O2N,
     &    AERATT,AERO,NN,RAYLEIGH(NLAM),ALBC(NLAM),TRAC(NLAM),CLOUD,
     &    SCAT,TT,AERSCAT
      DO 90 NL=1,NLAM
        SGO3 = SGAO3(NL)-(((SGAO3(NL)-SGBO3(NL))*
     1               (273.0-TT))/70.0)
        ATTA(NL) = EXP(-DZ*MM*((OZONE*SGO3)+
     1                (O2N*SGO2(NL))+(AERATT*AERO)))
C
        SCAT = EXP(-DZ*MM*((NN*RAYLEIGH(NL))+
     1                                (AERSCAT*AERO)))
        FRBK(NL) = ((0.5*(1.0-SCAT))+(ALBC(NL)*CLOUD))
     1        /((1.0-SCAT)+CLOUD)
        FRFD(NL) = ((0.5*(1.0-SCAT))+(TRAC(NL)*CLOUD))
     1        /((1.0-SCAT)+CLOUD)
        ATTS(NL) = SCAT*(1.0-CLOUD)
C
   90 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE INCFLX(FLUXDN,SFLUX,YEAR,O2COL,SGO2,O3COL,SGAO3,SGBO3,
     &    MMTOP,NLAM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE FLUX INCIDENT ON TOP OF MODEL
C-
C-   Inputs  : SFLUX,YEAR,O2COL,SGO2,O3COL,SGAO3,SGBO3,MMTOP,NLAM
C-   Outputs : FLUXDN
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NL
      REAL FLUXDN(NLAM),SFLUX(NLAM),FSUN,O2COL,SGO2(NLAM),O3COL,
     &    SGAO3(NLAM),SGBO3(NLAM),MMTOP,PI,YEAR
      PI=4.0*ATAN(1.0)
C ATTENUATION BY THE OXYGEN AND OZONE COLUMNS ABOVE MODEL TOP
C
C
      DO 120 NL=1,NLAM
C
C NEXT LINE ACCOUNTS FOR ELLIPTICAL ORBIT OF EARTH ROUND SUN
        FSUN = 1.0+(0.034*COS(2.0*PI*YEAR))
C SGO3 IS EQUIVALENT TO TEMPERATURE OF 230K
        FLUXDN(NL) = SFLUX(NL)*FSUN*EXP(-O2COL*SGO2(NL)*MMTOP)
     1      *EXP(-O3COL*((0.39*SGAO3(NL))+(0.61*SGBO3(NL)))*MMTOP)
C
  120 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CALFLX(FLUXDN,FLUXUP,ATTA0,ATTS0,ATTA1,ATTS1,CCOS,
     &    COSSURF,ALB0SURF,ALB1SURF,FRBK0,FRFD0,FRBK1,FRFD1,NLAM,NLEV)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE FLUXES
C-
C-   Inputs  : ATTA0,ATTS0,ATTA1,ATTS1,CCOS,COSSURF,ALB0SURF,ALB1SURF,
C-             FRBK0,FRFR0,FRBK1,FRFD1,NLAM,NLEV
C-   Outputs : FLUXDN,FLUXUP
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NLEV,I,J,NL
      REAL ATTA0(NLAM,0:NLEV),ATTS0(NLAM,0:NLEV),ATTA1(NLAM,0:NLEV),
     &    ATTS1(NLAM,0:NLEV),
     &    CCOS(0:NLEV),COSSURF,ALB0SURF(NLAM),ALB1SURF(NLAM),
     &    FRBK0(NLAM,0:NLEV),FRFD0(NLAM,0:NLEV),FRBK1(NLAM,0:NLEV),
     &    FRFD1(NLAM,0:NLEV),FLUXDN(NLAM,6,0:NLEV+1),
     &    FLUXUP(NLAM,6,0:NLEV+1),CCOS2
C
C THE DIRECT BEAM AND ITS REFLECTION AT THE SURFACE
C
      DO 140 J= NLEV,0,-1
        DO 150 NL=1,NLAM
          FLUXDN(NL,1,J) = FLUXDN(NL,1,J+1)*ATTA0(NL,J)*ATTS0(NL,J)
  150   CONTINUE
  140 CONTINUE
C
      DO 160 NL=1,NLAM
        FLUXUP(NL,1,0) = FLUXDN(NL,1,0)*ALB0SURF(NL)*(2.0*COSSURF)
  160 CONTINUE
C
      DO 170 J=0,NLEV
        DO 190 NL=1,NLAM
          FLUXUP(NL,1,J+1) = FLUXUP(NL,1,J)*ATTA1(NL,J)*ATTS1(NL,J)
  190   CONTINUE
  170 CONTINUE
C
C THE FIRST ORDER SCATTERED BEAM AND SURFACE REFLECTION
C
      DO 200 J=NLEV,0,-1
        CCOS2 = 2.0*CCOS(J)
        DO 220 NL=1,NLAM
          FLUXDN(NL,2,J) = FLUXDN(NL,2,J+1)*ATTA1(NL,J)*ATTS1(NL,J)
     1                + (FLUXDN(NL,1,J+1)*ATTA0(NL,J)*FRFD0(NL,J)
     2                *(1.0-ATTS0(NL,J))*CCOS2)
     1                + (FLUXUP(NL,1,J)*ATTA1(NL,J)*FRBK1(NL,J)
     2                *(1.0-ATTS1(NL,J)))
  220   CONTINUE
  200 CONTINUE
C
      DO 230 NL=1,NLAM
        FLUXUP(NL,2,0) = FLUXDN(NL,2,0)*ALB1SURF(NL)
  230 CONTINUE
C
      DO 240 J=0,NLEV
        CCOS2 = 2.0*CCOS(J)
        DO 250 NL=1,NLAM
          FLUXUP(NL,2,J+1) = FLUXUP(NL,2,J)*ATTA1(NL,J)*ATTS1(NL,J)
     1               + (FLUXDN(NL,1,J+1)*ATTA0(NL,J)*FRBK0(NL,J)
     2               *(1.0-ATTS0(NL,J))*CCOS2)
     1               + (FLUXUP(NL,1,J)*ATTA1(NL,J)*FRFD1(NL,J)
     2               *(1.0-ATTS1(NL,J)))
  250   CONTINUE
  240 CONTINUE
C
C THE THIRD TO SIXTH ORDER SCATTERED BEAMS.
C
      DO 260 I=3,6
        DO 280 J=NLEV,0,-1
          DO 300 NL=1,NLAM
            FLUXDN(NL,I,J) = FLUXDN(NL,I,J+1)*ATTA1(NL,J)*ATTS1(NL,J)
     1               + (FLUXDN(NL,I-1,J+1)*ATTA1(NL,J)*FRFD1(NL,J)
     2               *(1.0-ATTS1(NL,J)))
     1               + (FLUXUP(NL,I-1,J)*ATTA1(NL,J)*FRBK1(NL,J)
     2               *(1.0-ATTS1(NL,J)))
  300     CONTINUE
  280   CONTINUE
C
        DO 310 NL=1,NLAM
          FLUXUP(NL,I,0) = FLUXDN(NL,I,0)*ALB1SURF(NL)
  310   CONTINUE
C
        DO 320 J=0,NLEV
          DO 340 NL=1,NLAM
            FLUXUP(NL,I,J+1) = FLUXUP(NL,I,J)*ATTA1(NL,J)*ATTS1(NL,J)
     1              + (FLUXDN(NL,I-1,J+1)*ATTA1(NL,J)*FRBK1(NL,J)
     2              *(1.0-ATTS1(NL,J)))
     1              + (FLUXUP(NL,I-1,J)*ATTA1(NL,J)*FRFD1(NL,J)
     2              *(1.0-ATTS1(NL,J)))
  340     CONTINUE
  320   CONTINUE
C
  260 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE GETO3(P1O3,TUHERE,LAMBDA)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE QUANTUM YIELD FOR O3->O1D
C-
C-   Inputs  : TUHERE
C-   Outputs : P1O3
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER N
      REAL TUHERE,P1O3(106),TAU,TAU2,ATAU,BTAU,CTAU,DTAU,ETAU,FTAU,GTAU,
     &    LX,LX2,LX3,LX4,LX5,LX6,PTEMP,LAMBDA(106)
C
C TEMPERATURE DEPENDENCE OF THE QUANTUM YIELD FOR (O3 - O(1D))
C FROM JPL (1992)
C
      TAU = 298.0-TUHERE
      TAU2 = TAU**2
      ATAU =  0.94932   -(1.7039E-4*TAU) +(1.4072E-6*TAU2)
      BTAU = -2.4052E-2 +(1.0479E-3*TAU) -(1.0655E-5*TAU2)
      CTAU =  1.8771E-2 -(3.6401E-4*TAU) -(1.8587E-5*TAU2)
      DTAU = -1.4540E-2 -(4.7787E-5*TAU) +(8.1277E-6*TAU2)
      ETAU =  2.3287E-3 +(1.9891E-5*TAU) -(1.1801E-6*TAU2)
      FTAU = -1.4471E-4 -(1.7188E-6*TAU) +(7.2661E-8*TAU2)
      GTAU =  3.1830E-6 +(4.6209E-8*TAU) -(1.6266E-9*TAU2)
C
      DO 360 N = 1,34
        P1O3(N) = 0.9
  360 CONTINUE
C
      DO 370 N = 39,106
        P1O3(N) = 0.0
  370 CONTINUE
      DO 380 N = 35,38
        LX  = LAMBDA(N)-305.0
        LX2 = LX**2
        LX3 = LX**3
        LX4 = LX**4
        LX5 = LX**5
        LX6 = LX**6
        PTEMP = ATAU+(BTAU*LX)+(CTAU*LX2)+(DTAU*LX3)
     &              +(ETAU*LX4)+(FTAU*LX5)+(GTAU*LX6)
        PTEMP = AMAX1(0.0,PTEMP)
        P1O3(N) = AMIN1(0.95,PTEMP)
  380 CONTINUE
  999 RETURN
      END
      SUBROUTINE GETSIG(SGO3,SGNO2,SGHNO3,SGHCHO,SGN2O5,SGH2O2,TUHERE,
     &    LAMBDA,SGAO3,SGBO3,SGAHNO3,SGTHNO3,SGAHCHO,SGBHCHO,SGAH2O2,
     &    SGBH2O2,SGANO2,SGTNO2,SGPAN,SGAPAN,SGTPAN,SGCH3NO3,SGACH3NO3,
     &    SGTCH3NO3,SGC2H5NO3,SGAC2H5NO3,SGTC2H5NO3,SGIC3H7NO3,
     &    SGAIC3H7NO3,SGTIC3H7NO3,NLAM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :   To evaluate temperature dependence of cross
C-                           sections.
C-
C-   Inputs  : TUHERE,LAMBDA,SGAO3,SGBO3,SGAHNO3,SGTHNO3,SGAHCHO,SGBHCHO,
C-             SGAH2O2,SGBH2O2,SGANO2,SGTNO2,SGAPAN,SGTPAN,NLAM
C-   Outputs : SGO2,SGNO2,SGHNO3,SGHCHO,SGH2O2,SGPAN
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-   Updated   5-SEP-1995   Colin Johnson  Added PAN
C-
C-   Updated   2-JUL-2008   Micahel Cooke  Added CH3NO3,C2H5NO3,IC3H7NO3
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,N,NL
      REAL SGO3(NLAM),SGNO2(NLAM),SGHNO3(NLAM),SGHCHO(NLAM),
     &    SGH2O2(NLAM),SGN2O5(NLAM),SGPAN(NLAM),SGAPAN(NLAM),
     &    SGTPAN(NLAM),SGCH3NO3(NLAM),SGACH3NO3(NLAM),SGTCH3NO3(NLAM),
     &    TUHERE,LAMBDA(NLAM),SGAO3(NLAM),SGBO3(NLAM),SGAHNO3(NLAM),
     &    SGTHNO3(NLAM),SGAHCHO(NLAM),SGBHCHO(NLAM),SGAH2O2(NLAM),
     &    SGBH2O2(NLAM),SGANO2(NLAM),SGTNO2(NLAM),IQPART,
     &    SGC2H5NO3(NLAM),SGAC2H5NO3(NLAM),SGTC2H5NO3(NLAM),
     &    SGIC3H7NO3(NLAM),SGAIC3H7NO3(NLAM),SGTIC3H7NO3(NLAM)
C
      DO 400 N = 31,51
        SGN2O5(N) = 1.0E-20*EXP(2.735+((4728.5-
     1                          (17.127*LAMBDA(N)))/TUHERE))
  400 CONTINUE
C
      IQPART = 1.0/(1.0+EXP(-10489.0/(TUHERE*8.31441)))
C
      DO 410 NL=1,NLAM
        SGO3(NL) = SGAO3(NL)-(((SGAO3(NL)-SGBO3(NL))*
     &                                (273.0-TUHERE))/70.0)
        SGNO2(NL) = SGANO2(NL)+(SGTNO2(NL)*(TUHERE-273.0))
        SGHNO3(NL) = SGAHNO3(NL)*EXP(SGTHNO3(NL)*(TUHERE-298.0))
        SGPAN(NL) = SGAPAN(NL)*EXP(SGTPAN(NL)*(TUHERE-298.0))
        SGHCHO(NL) = SGAHCHO(NL)-(((SGAHCHO(NL)-SGBHCHO(NL))
     &                               *(293.0-TUHERE))/70.0)
        SGH2O2(NL) = (IQPART*SGAH2O2(NL))+
     &                            ((1.0-IQPART)*SGBH2O2(NL))
  410 CONTINUE
      IF (TUHERE.LT.240) THEN
      DO 411 NL=1,NLAM
      SGCH3NO3(NL) = SGACH3NO3(NL)*EXP(SGTCH3NO3(NL)*(240.0-298.0))
  411 CONTINUE  
      ELSE
      DO 412 NL=1,NLAM
      SGCH3NO3(NL) = SGACH3NO3(NL)*EXP(SGTCH3NO3(NL)*(TUHERE-298.0))
  412 CONTINUE
      ENDIF
      IF (TUHERE.LT.233) THEN
      DO 413 NL=1,NLAM
      SGC2H5NO3(NL) = SGAC2H5NO3(NL)*EXP(SGTC2H5NO3(NL)
     &                                         *(233.0-298.0))
      SGIC3H7NO3(NL) = SGAIC3H7NO3(NL)*EXP(SGTIC3H7NO3(NL)
     &                                         *(233.0-298.0)) 
  413 CONTINUE
      ELSE
      DO 414 NL=1,NLAM
      SGC2H5NO3(NL) = SGAC2H5NO3(NL)*EXP(SGTC2H5NO3(NL)
     &                                         *(TUHERE-298.0))
      SGIC3H7NO3(NL) = SGAIC3H7NO3(NL)*EXP(SGTIC3H7NO3(NL)
     &                                         *(TUHERE-298.0))
  414 CONTINUE
      ENDIF
  999 RETURN
      END
C#######################################################################
      SUBROUTINE TOTFLX(FLUXTOT,FLUXUP,FLUXDN,NLAM)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : ADD UP TOTAL FLUXES
C-
C-   Inputs  : FLUXUP,FLUXDN,NLAM
C-   Outputs : FLUXTOT
C-   Controls:
C-
C-   Created   6-JUN-1994   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      INTEGER NLAM,NL
      REAL FLUXTOT(NLAM),FLUXDN(NLAM,6),FLUXUP(NLAM,6)
C
      DO 10 NL=1,NLAM
        FLUXTOT(NL)=FLUXDN(NL,1)+FLUXDN(NL,2)+FLUXDN(NL,3)
     &           + FLUXDN(NL,4)+FLUXDN(NL,5)+FLUXDN(NL,6)
     &           + FLUXUP(NL,1)+FLUXUP(NL,2)+FLUXUP(NL,3)
     &           + FLUXUP(NL,4)+FLUXUP(NL,5)+FLUXUP(NL,6)
   10 CONTINUE
  999 RETURN
      END
C#######################################################################
      SUBROUTINE DUMP(XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
     &  CONC,MCONC,
     &  SDCONC,NM,M0,TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,TOTAVG,
     &  NAVG)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : DUMPS PROGRAM VARIABLES TO FILE
C-
C-   Inputs  : XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
C-             CONC,MCONC,SDCONC,NM,M0
C-             TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,TOTAVG,NAVG
C-   Outputs : none
C-   Controls:
C-
C-   Created  17-JAN-1995   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER YEAR,MONTH,SEED2,SEED3,NFLUX,NSTAT,NAVG
      INTEGER FLIST(2,NUMFLUX)
      REAL XX(NC,NCELL),
     &  CONC(NC,NLONG,MNLAT,NLEV),MCONC(NC,NLONG,MNLAT,NLEV),
     &  SDCONC(NC,NLONG,MNLAT,NLEV),M0(NUMCHEM,NLONG,MNLAT,NLEV),
     &  ESTORE(NC,NLONG,MNLAT),TFLUX(NUM3DFLUX,NLONG,MNLAT,NLEV),
     &  TOTFLU(NUMFLUX),TOTAVG(NUMFLUX)
      REAL DAY,POS(3,NCELL),B(NCELL)
      DOUBLE PRECISION TIME
      INTEGER NM(NLONG,MNLAT,NLEV)
      CHARACTER*15 FNAMES(NUMFLUX)
      OPEN(51,FILE=OUTDIR//'DUMP.BIN',STATUS='UNKNOWN',
     &  FORM='UNFORMATTED')
      WRITE(51) XX
      WRITE(51) POS
      WRITE(51) ESTORE
      WRITE(51) TFLUX
      WRITE(51) TOTFLU
      WRITE(51) FLIST,FNAMES
      WRITE(51) B
      WRITE(51) CONC
      WRITE(51) MCONC
      WRITE(51) SDCONC
      WRITE(51) NM
      WRITE(51) M0
      WRITE(51) TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX
      WRITE(51) NSTAT
      WRITE(51) TOTAVG
      WRITE(51) NAVG
      CLOSE(51)
  999 RETURN
      END
C#######################################################################
      SUBROUTINE RESTART(XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
     &  CONC,MCONC,
     &  SDCONC,NM,M0,TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,
     &  TOTAVG,NAVG)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : RESTARTS FROM DUMPED VARIABLES
C-
C-   Inputs  :
C-   Outputs : XX,POS,ESTORE,TFLUX,TOTFLU,FLIST,FNAMES,B,
C-             CONC,MCONC,SDCONC,NM,
C-            M0,TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX,NSTAT,TOTAVG,NAVG
C-   Controls:
C-
C-   Created  17-JAN-1995   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                                        use NCELL instead of MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER MONTH,SEED2,SEED3,NFLUX,YEAR,NSTAT,NAVG
      INTEGER FLIST(2,NUMFLUX),IERR
      REAL XX(NC,NCELL),
     &  CONC(NC,NLONG,MNLAT,NLEV),MCONC(NC,NLONG,MNLAT,NLEV),
     &  SDCONC(NC,NLONG,MNLAT,NLEV),M0(NUMCHEM,NLONG,MNLAT,NLEV),
     &  ESTORE(NC,NLONG,MNLAT),
     &  TFLUX(NUM3DFLUX,NLONG,MNLAT,NLEV),TOTFLU(NUMFLUX),
     &  TOTAVG(NUMFLUX)
      REAL DAY,POS(3,NCELL),B(NCELL)
      DOUBLE PRECISION TIME
      INTEGER NM(NLONG,MNLAT,NLEV)
      CHARACTER*15 FNAMES(NUMFLUX)
      OPEN(52,FILE=OUTDIR//'RESTART.BIN',STATUS='OLD',
     &  FORM='UNFORMATTED',IOSTAT=IERR)
C TEST TO SEE IF FILE EXISTS
      IF(IERR.EQ.0) THEN
        READ(52) XX
        READ(52) POS
        READ(52) ESTORE
        READ(52) TFLUX
        READ(52) TOTFLU
        READ(52) FLIST,FNAMES
        READ(52) B
        READ(52) CONC
        READ(52) MCONC
        READ(52) SDCONC
        READ(52) NM
        READ(52) M0
        READ(52) TIME,YEAR,MONTH,DAY,SEED2,SEED3,NFLUX
        READ(52) NSTAT
        READ(52) TOTAVG
        READ(52) NAVG
        CLOSE(52)
        PRINT *,'RESTART FILE EXISTS, VARIABLES RESTORED'
        PRINT *,'TIME: ',TIME,IERR
        PRINT *,'DAY: ',DAY,'MONTH: ',MONTH,'YEAR: ',YEAR
        WRITE(7,*) 'RESTART FILE EXISTS, VARIABLES RESTORED'
        WRITE(7,*) 'TIME: ',TIME
        WRITE(7,*) 'DAY: ',DAY,'MONTH: ',MONTH,'YEAR: ',YEAR
      ELSE
        PRINT *,'NO DUMP FILE FOUND, STARTING FROM SCRATCH'
        WRITE(7,*) 'NO DUMP FILE FOUND, STARTING FROM SCRATCH'
        WRITE(7,*) 'TIME: ',TIME,IERR
      ENDIF
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION ZEN(TIME,LAT,LONG)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculates local solar zenith angle for
C-                         particular time
C-
C-   Inputs  : TIME,LAT,LONG
C-   Outputs : none
C-   Controls:
C-
C-   Created  31-JAN-1995   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------
      DOUBLE PRECISION TIME
      DOUBLE PRECISION XLHA,DECL
      REAL LAT,LONG,COSINE
      DOUBLE PRECISION PI
      PI=4.0D0*DATAN(1.0D0)
C
      XLHA=(1.+TIME/4.32E4+LONG/180.)*PI ! LOCAL HOUR ANGLE
      DECL=-0.4142*COS(PI+(2.0*PI*TIME/3.1536E+7)) ! DECLINATION
      COSINE=COS(XLHA)*COS(LAT*PI/180.)*COS(DECL)+SIN(LAT*PI/180.)*
     &  SIN(DECL)
      ZEN=ACOS(COSINE)
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION ISOPRE(MONTH,I,J)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculates multiplier for isoprene emissions
C-                         at particular time
C-
C-   Inputs  : MONTH,I,J
C-   Outputs : none
C-   Controls:
C-
C-   Created  10-MAR-1995   Bill Collins
C-   Updated   9-JAN-1996   Bill Collins  Isoprene now proportional to
C-                                        COS(theta).
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      DOUBLE PRECISION TIME
      REAL LAT,LONG,DAYLEN,ZEN,THET
      INTEGER I,J,HOUR,SECS,MONTH
C
      LONG=(360.*(I-.5))/NLONG
      LAT=90.-(180.*(J-.5))/MNLAT
      DAYLEN=0.
      DO HOUR=0,7
C TAKE TIME TO BE 15TH OF THE MONTH
        TIME=1.0D0*SECS(15,MONTH,1)+HOUR*10800.D0
        THET=ZEN(TIME,LAT,LONG)
        IF(COS(THET).GT.0.) DAYLEN=DAYLEN+COS(THET)
      ENDDO
      IF(DAYLEN.EQ.0.) DAYLEN=0.1
      ISOPRE=8./DAYLEN
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION DAYNUMBER(DAY,MONTH,YEAR)
C------------------------------------------------------------------------------
C
C     Inputs day, month and year
C     Outputs day number after year 93, e.g. 21 June 93 = 172
C      -1 indicates date is not valid
C
C     Created  D.Stevenson   29 Sept 94
C     Updated  D.Stevenson    9 Mar  95
C
C------------------------------------------------------------------------------
      REAL DAY,X
      INTEGER MONTH,DAYM(12),I,YEAR
      DATA DAYM /31,28,31,30,31,30,31,31,30,31,30,31/

      IF(DAY.LE.0.0.OR.MONTH.LE.0.OR.YEAR.LE.0)THEN
        DAYNUMBER=-1.0
      ELSE
        X=0.
        IF(MONTH.EQ.1)THEN
          X=DAY
        ELSE
          DO I=1,MONTH-1
            X=X+DAYM(I)
          ENDDO
          X=X+DAY
        ENDIF
        DAYNUMBER=X+FLOAT((YEAR-93)*365)
      ENDIF
      RETURN
      END
C ######################################################################
      SUBROUTINE STRATREAD(CONC100,CONC57)
C------------------------------------------------------------------------------
C
C     Inputs
C     Outputs filled array of stratosphere (57 & 100mb) compositions:
C     conc57 & conc100 - only reads Ozone at present
C
C     Created  D.Stevenson   4 Oct 94
C     Updated  D.Stevenson   2 Dec 94
C     Modified C.E. Johnson  5 Feb 96 To read 2-D datasets for 100 & 57 mb
C                                     made conc single species. Ozone mass
C                                     m.r. from Li & Shine mean fields (g/g).
C
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K
      REAL CONC57(MNLAT,NLONG,12),CONC100(MNLAT,NLONG,12)
      OPEN(17,FILE=DATDIR//'ls100big.dat',STATUS='OLD')
      DO K=1,12
        DO J=1,MNLAT
          READ(17,'(2(6E11.3/),6E11.3)')(CONC100(J,I,K),I=1,NLONG)
        ENDDO
      ENDDO
      CLOSE(17)
C
      OPEN(17,FILE=DATDIR//'ls56big.dat',STATUS='OLD')
      DO K=1,12
        DO J=1,MNLAT
          READ(17,'(2(6E11.3/),6E11.3)')(CONC57(J,I,K),I=1,NLONG)
        ENDDO
      ENDDO
      CLOSE(17)
C
      WRITE(6,*) 'July 100 mb ozone'
      DO J=1,MNLAT
        WRITE(6,*) J,CONC100(J,1,7)
      ENDDO
C
      RETURN
      END
C ######################################################################
      SUBROUTINE LIGHTREAD(NO2EM,MONTH,LMOLEC,DONO2)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : READ IN Lightning + aircraft emissions DATA
C-
C-   Inputs  :
C-   Outputs : no2em
C-   Controls:
C-
C-   Created  7-Oct-1994    David Stevenson
C-   Updated  13-JAN-1995   Bill Collins  Don't pass NLONG, MNLAT, NMETLEV.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER MONTH,AMTH,DONO2
      REAL NO2EM(NLONG,MNLAT,NLEV)
      REAL LIGHTN(NLONG,MNLAT,NLEV)
      REAL AIRCRAFT(NLONG,MNLAT,NLEV)
      REAL MILITARY(NLONG,MNLAT,NLEV)
      INTEGER I,J,K
      DOUBLE PRECISION LMOLEC
      REAL SUM
      CHARACTER*14 LTFILENM
      CHARACTER*15 ACFILENM
      CHARACTER*16 MAFILENM
      LTFILENM='lnox  .out'
      ACFILENM='acnox  .out'
      MAFILENM='mil-year.out'
C   Decide which aircraft data month to use: DJF=JAN,MAM=APR,JJA=JUL,SON=OCT

      AMTH=MONTH
      IF(MONTH.EQ.12)AMTH=0
      AMTH=1+3*INT(AMTH/3)
      WRITE(LTFILENM(5:6),'(i2.2)')MONTH
      WRITE(ACFILENM(6:7),'(i2.2)')AMTH

C   Lightning NO2 data, kg/s/grid square

      OPEN(21,FILE=EMDIR//LTFILENM,STATUS='OLD')
      READ(21,100) LIGHTN
      CLOSE(21)

C   Aircraft NO2 data, kg/s/grid square

      OPEN(21,FILE=EMDIR//ACFILENM,STATUS='OLD')
      READ(21,101) AIRCRAFT
      CLOSE(21)

C   Military Aircraft NO2 data, kg/s/grid square

      OPEN(21,FILE=EMDIR//MAFILENM,STATUS='OLD')
      READ(21,102) MILITARY
      CLOSE(21)

      IF(DONO2.GT.2)CALL FILLDP3(LIGHTN,NLONG,MNLAT,NLEV,0.E0) !zero lightning
      IF(DONO2.EQ.2.OR.DONO2.GT.3)THEN
        CALL FILLDP3(AIRCRAFT,NLONG,MNLAT,NLEV,0.E0)           !zero aircraft
        CALL FILLDP3(MILITARY,NLONG,MNLAT,NLEV,0.E0)           !zero military
      ENDIF

C   Sum and convert to (    molecules NO2/grid square      )
C                      (-----------------------------------)  /s
C                      ( molecules air/lagrangian particle )

      DO I=1,NLEV
        DO J=1,MNLAT
          DO K=1,NLONG
            SUM=LIGHTN(K,J,I)+AIRCRAFT(K,J,I)+MILITARY(K,J,I)
            NO2EM(K,J,I)=SUM*1.0E3*NA/(46.0*LMOLEC)
          ENDDO
        ENDDO
      ENDDO

  100 FORMAT(6F7.4)
  101 FORMAT(6F10.4)
  102 FORMAT(6F10.6)
  999 RETURN
      END
C ######################################################################
      SUBROUTINE FILLDP3(X,N1,N2,N3,VAL)
C----------------------------------------------------------------------
C-   Purpose and Methods : fills a real 3-d array with val
C-   Inputs  : x,n1,n2,n3,val
C-   Outputs : x
C-   Created  12-Oct-1994    David Stevenson
C----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER I,J,K,N1,N2,N3
      REAL X(N1,N2,N3),VAL
      DO I=1,N3
        DO J=1,N2
          DO K=1,N1
            X(K,J,I)=VAL
          ENDDO
        ENDDO
      ENDDO
      RETURN
      END
C ######################################################################
      SUBROUTINE FILLDP2(X,N1,N2,VAL)
C----------------------------------------------------------------------
C-   Purpose and Methods : fills a real 2-d array with val
C-   Inputs  : x,n1,n2,val
C-   Outputs : x
C-   Created  12-Oct-1994    David Stevenson
C----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER J,K,N1,N2
      REAL X(N1,N2),VAL
      DO J=1,N2
        DO K=1,N1
          X(K,J)=VAL
        ENDDO
      ENDDO
      RETURN
      END
C ######################################################################
      SUBROUTINE FILLIN2(X,N1,N2,VAL)
C----------------------------------------------------------------------
C-   Purpose and Methods : fills a integer 2-d array with val
C-   Inputs  : x,n1,n2,val
C-   Outputs : x
C-   Created  12-Oct-1994    David Stevenson
C----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER J,K,N1,N2
      INTEGER X(N1,N2),VAL
      DO J=1,N2
        DO K=1,N1
          X(K,J)=VAL
        ENDDO
      ENDDO
      RETURN
      END
C ######################################################################
      SUBROUTINE FILLIN3(X,N1,N2,N3,VAL)
C----------------------------------------------------------------------
C-   Purpose and Methods : fills a integer 3-d array with val
C-   Inputs  : x,n1,n2,n3,val
C-   Outputs : x
C-   Created  12-Oct-1994    David Stevenson
C----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER I,J,K,N1,N2,N3
      INTEGER X(N1,N2,N3),VAL
      DO I=1,N3
        DO J=1,N2
          DO K=1,N1
            X(K,J,I)=VAL
          ENDDO
        ENDDO
      ENDDO
      RETURN
      END
C ######################################################################
      SUBROUTINE INICON2(XX,IPOS,BINFILE)
C----------------------------------------------------------------------
C-   Purpose and Methods : initializes cells to eulerian concs from a
C-                         previous run
C-   Inputs  : nlong,mnlat,NLEV,nc,ipos,binfile
C-   Outputs : xx
C-   Created  17-Nov-1994   David Stevenson
C-   Updated   2-MAR-1995   Bill Collins Read concentration file one species at
C-                          a time (only way to read a varying number of
C-                          species).
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                          use NCELL instead of MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5,NCELL),I,J,K,L,M
      REAL XX(NC,NCELL),INIT(NC,NLONG,MNLAT,NLEV)
      CHARACTER*15 BINFILE
C  1. Load previous concentrations
      OPEN(60,FILE=OUTDIR//BINFILE,STATUS='OLD',FORM='UNFORMATTED')
      READ(60) INIT
      CLOSE(60)
C  2. Fill cells
      DO M=1,NC
        DO L=1,NCELL
          I=IPOS(1,L)
          J=IPOS(2,L)
          K=IPOS(5,L)
          XX(M,L)=INIT(M,I,J,K)
        ENDDO
      ENDDO
      RETURN
      END
C ######################################################################
      SUBROUTINE INICON3(XX,IPOS,BINFILE)
C----------------------------------------------------------------------
C-   Purpose and Methods : initializes cells to eulerian concs from a
C-                         previous run
C-   Inputs  : ipos,binfile
C-   Outputs : xx
C-   Created  17-Nov-1994   David Stevenson
C-   Updated   2-MAR-1995   Bill Collins Read concentration file one species at
C-                          a time (only way to read a varying number of
C-                          species).
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-                          use NCELL instead of MCELL
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IPOS(5,NCELL),I,J,K,L,M
      REAL XX(NC,NCELL)
      DOUBLE PRECISION INIT(NLONG,MNLAT,NLEV)
      CHARACTER*15 BINFILE
C  1. Load previous concentrations
      OPEN(60,FILE=DATDIR//BINFILE,STATUS='OLD',FORM='UNFORMATTED')
C  2. Fill cells
      DO M=1,NC
        READ(60) INIT
        DO L=1,NCELL
          I=IPOS(1,L)
          J=IPOS(2,L)
          K=IPOS(5,L)
          XX(M,L)=INIT(I,J,K)
        ENDDO
      ENDDO
      CLOSE(60)
      RETURN
      END
C ######################################################################
      SUBROUTINE STRATCALC(EMISS,O3100,LAT,LMOLEC,MONTH,W,T)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATE O3 & HNO3 influx from stratosphere
C-
C-   Inputs  : LAT,LMOLEC,W,T
C-
C-   Outputs : EMISS(6),EMISS(14) are O3 and HNO3, O3100 are ozone
C-             concentrations at 100 mb (units of microg/g).
C
C-   Controls:
C-
C-   Created  6-DEC-1994   David Stevenson
C-   Updated  13-JAN-1995  Bill Collins Array dimensions for WMEAN, TMEAN,
C-                         O3FLUX, CONC100 ,CONC70 specified explicitly. II and
C-                         JJ loops now start at 0.
C-   Updated   ?-JAN-1995  David Stevenson Changed sign of w and fluxes
C-   Updated   2-JUN-1995  Colin Johnson   To reflect new species order.
C-   Updated  26-OCT-1995  Colin Johnson   To output O3100.
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-   Updated  29-JAN-1997  Colin Johnson Etadot interpolated by cubic function. 
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,MONTH
      REAL EMISS(NC,NLONG,MNLAT),LAT(MNLAT+1),O3100(NLONG,MNLAT)
      DOUBLE PRECISION LMOLEC
      REAL AREA(MNLAT),RAD
      REAL WMEAN(NLONG,MNLAT),WM(NMETLONG,NMETLAT),
     &  TMEAN(NLONG,MNLAT),SUMIN,SUMOUT,O3FLUX(NLONG,MNLAT)
      REAL W(NMETLONG,NMETLAT,NMETLEV)
      REAL T(NMETLONG,NMETLAT,NMETLEV)
      REAL CONC100(MNLAT,NLONG,12),CONC57(MNLAT,NLONG,12)
      REAL F,AIRRHO
      real f1,f2,deta

      RAD=PI/180.0

C  read in stratospheric o3 concentrations @57 & 100mb (2-D, 12 months)

      CALL STRATREAD(CONC100,CONC57)
C      Modify stratospheric ozone concentrations.
c      CALL O3FACTOR(CONC100,CONC57)

C  interpolate vertical wind and temperature onto 5x5 grid
C  w has units eta dot (1/s); to convert to vertical velocity:
C  vertical velocity = -(Href/Pressure)*Pref*etadot
C                    = -(7000m/100mb)*1000mb*w          (units m/s)
C  NB a negative etadot is a upwards velocity
C   & a positive   "     " " downwards   "
C
C- 0.0992 is top eta level for temperatures. 0.225 and 0.075 are top 2 eta
C- levels for vertical winds. Don't bother with accurate conversion to pressure
C- as this exchange method is approximate and at high altitudes (eta<.1)
C- pressure is very nearly 1000*eta anyway.
C
      IF (CLIM) THEN                               ! i.e. for 19 layer data
c        CALL CUBFIT2D(ETA1(14),W(1,1,14),0.1,WM)   ! cubic interpolation.
        CALL MET2DATA(WMEAN,WM,1)
c        CALL MET2DATA(TMEAN,T(1,1,15),1)
      ELSE                                         ! operational met data
C        ? Not enough heights to do this.
C        ? Repeat W(1,1,9) to W(1,1,10)
C        CALL CUBFIT2D(ETA1(8),W(1,1,8),0.1,WM)     ! cubic interpolation.

        f1=eta1(10)-0.1              ! =0.125
        f2=0.1-eta1(11)              ! =0.025
        deta=eta1(10)-eta1(11)       ! =0.15
        f1=f1/deta                   ! =0.83333
        f2=f2/deta                   ! =0.16666
        do i=1,nmetlong
          do j=1,nmetlat
            wm(i,j)=f1*w(i,j,11)+f2*w(i,j,10)
          enddo
        enddo
        CALL MET2DATA(WMEAN,WM,1)
        CALL MET2DATA(TMEAN,T(1,1,10),1)
      ENDIF

C      rep=1
C      do while(rep.eq.1)

C      write(6,*)'P of incoming stratospheric air (70-100mb) ?'
C      read(5,*)f
      F=98.5           !98.5mb level for incoming stratosphere
      F=(F-57.)/43.
      SUMOUT=0.0
      SUMIN=0.0
      DO J=1,MNLAT
        AREA(J)=(2.0*PI*(RADIUS*1.0E03)**2.0)*
     &     (SIN((LAT(J+1)-90.0)*RAD)-SIN((LAT(J)-90.0)*RAD))/NLONG
C        WRITE(6,*)area(j)
      ENDDO

C  calculate o3 flux in and out of troposphere (o3flux has units g/s)
C  reference height 7000m.
C  fluxes scaled by 0.5* Dick Derwent November 2003
      DO I=1,NLONG
        DO J=1,MNLAT
          AIRRHO=99.2*1.0E5/(286.7*TMEAN(I,J))         !@99.2mb in g/m^3
          IF(WMEAN(I,J).LT.0.0)THEN                    !outflux from trop
          O3FLUX(I,J)=0.5*WMEAN(I,J)*7000.*(1000./100.)*AREA(J)*AIRRHO*
     &        CONC100(J,I,MONTH)
            SUMOUT=SUMOUT+O3FLUX(I,J)
          ELSE                                         !influx to trop
          O3FLUX(I,J)=0.5*WMEAN(I,J)*7000.*(1000./100.)*AREA(J)*AIRRHO*
     &        (CONC57(J,I,MONTH)-F*(CONC57(J,I,MONTH)-
     &        CONC100(J,I,MONTH)))
            SUMIN=SUMIN+O3FLUX(I,J)
          ENDIF
        ENDDO
      ENDDO
C      WRITE(6,*)f
C      WRITE(6,*)'Total O3 outflux (g/yr):',-sumout*365.*86400.
C      WRITE(6,*)'Total O3 influx  (g/yr):',sumin*365.*86400.
      WRITE(6,*)'Strat O3 influx (g/yr):',(SUMOUT+SUMIN)*365.*86400.
C      write(6,*)'Repeat for another f ? (1/0)'
C      read(5,*)rep
C      enddo

C  redistribute net influx over grid squares with an influx; set outflux
C  squares to zero.

      DO I=1,NLONG
        DO J=1,MNLAT
          IF(WMEAN(I,J).LT.0.0)THEN                    !outflux from trop
            O3FLUX(I,J)=0.0
          ELSE                                         !influx to trop
            O3FLUX(I,J)=O3FLUX(I,J)*((SUMOUT+SUMIN)/SUMIN)
          ENDIF
        ENDDO
      ENDDO

C  convert o3flux to molecules s^-1 per grid square/(molecules/cell)
C  i.e. same units as other EMISS species

      DO I=1,NLONG
        DO J=1,MNLAT
          EMISS(6,I,J)=O3FLUX(I,J)*NA/(48.0*LMOLEC)            !Ozone
C
C  based on ratio of mass fluxes of N:O3 = 1:100 (Murphy & Fahey,1994)
C
          EMISS(14,I,J)=(O3FLUX(I,J)/1000.0)*NA/(14.0*LMOLEC)    !HNO3 (or NOy)
        ENDDO
      ENDDO
C
C      Convert to volume mixing ratio.
      DO I=1,NLONG
        DO J=1,MNLAT
          O3100(I,J)=CONC100(J,I,MONTH)*(29.0/48.0)
        ENDDO
      ENDDO
C
      RETURN
      END
C#######################################################################
      REAL FUNCTION H2OCAL(HUMID,I,J,ETA,P0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Find appropriate level for humidity data and
C-                         interpolate. Returns mixing ratio.
C-
C-   Inputs  : HUMID,I,J,ETA,P0
C-   Outputs :
C-   Controls:
C-
C-   Created   7-MAR-1995   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K
      REAL HUMID(NLONG,MNLAT,NLEV+1),P(NLEV+1),P0,ETA2P,PRESS,H2O
      REAL ETA
C HUMIDITY DATA IS DEFINED ON PRESSURE LEVELS
      DATA P/1000,850,700,500,400,300,250,200,150,100/
C
      PRESS=ETA2P(ETA,P0)
      K=1
      DO WHILE(K.LE.10.AND.PRESS.LT.P(K))
        K=K+1
      ENDDO
      IF(K.EQ.1) THEN
        H2O=HUMID(I,J,1)
      ELSEIF(K.EQ.11) THEN
        H2O=HUMID(I,J,10)
      ELSE
        H2O=HUMID(I,J,K)+
     &    (HUMID(I,J,K-1)-HUMID(I,J,K))*(PRESS-P(K))/(P(K-1)-P(K))
      ENDIF
      H2OCAL=H2O*MAIR/MH2O
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION ETA2P(ETA,P0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Converts from eta coordinates to pressure
C-
C-   Returned value  : ETA2P
C-   Inputs  : ETA,P0
C-   Outputs :
C-   Controls:
C-
C-   Created   8-MAR-1995   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  Some changes to allow for no surface
C-                                        level in ETA2
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL ETA
      REAL P0,PRESS,A
      INTEGER K
      K=1
      DO WHILE(K.LE.NMETLEV.AND.ETA.LT.ETA2(K))
        K=K+1
      ENDDO
      IF(ETA.GT.1.0) THEN
C        PRINT *,'**** ERROR: ETA>1.0 ****'
C        PRINT *,'ETA=',ETA
        PRESS=P0
      ELSEIF(K.EQ.1) THEN
        PRESS=P0*ETA
      ELSEIF(ETA.LT.ETA2(NMETLEV)) THEN
C        PRINT *,'*** ERROR in ETA2P: ETA<',ETA2(NMETLEV),'****'
C        PRINT *,'ETA=',ETA
        PRESS=ETA*1000.
      ELSE
        A=A2(K)+(A2(K-1)-A2(K))*(ETA-ETA2(K))/(ETA2(K-1)-ETA2(K))
        PRESS=P0*ETA+A*(1-P0/1000.)
      ENDIF
      ETA2P=PRESS
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION MOD2ETA(X)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : convert from model level to eta
C-
C-   Returned value  : X2
C-   Inputs  : X
C-   Outputs :
C-   Controls:
C-
C-   Created   22-DEC-1995   D Stevenson
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  Corrected calculation for ix<1
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER IX
      REAL X,RX,X2

      X2=0.0
      IF (X.GT.0.0) THEN
        IX=INT(X)
        RX=X-FLOAT(IX)
        IF (IX.LT.1) THEN
          X2=1.0+RX*(ETA2(1)-1.0)
        ELSEIF (IX.LT.NMETLEV) THEN
          X2=ETA2(IX)+RX*(ETA2(IX+1)-ETA2(IX))
        ELSE
          X2=ETA2(NMETLEV)
        ENDIF
      ENDIF
      MOD2ETA=X2
      RETURN
      END
C#######################################################################
      REAL FUNCTION P2ETA(PRESS,P0)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Converts from pressure coordinates to eta
C-
C-   Returned value  : P2ETA
C-   Inputs  : PRESS,P0
C-   Outputs :
C-   Controls:
C-
C-   Created   8-MAR-1995   Bill Collins
C-   Updated   5-DEC-1995   Bill Collins adapted for P to ETA
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins  Some changes to allow for no surface
C-                                        level in ETA2
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      REAL ETA
      REAL P0,PRESS,P2(NMETLEV),A
      INTEGER K
C Find pressure at standard eta levels
      DO K=1,NMETLEV
        P2(K)=P0*ETA2(K)+A2(K)*(1-P0/1000)
      ENDDO
      K=1
      DO WHILE(K.LE.NMETLEV.AND.PRESS.LE.P2(K))
        K=K+1
      ENDDO
      IF(PRESS.GT.P0) THEN
C        PRINT *,'**** ERROR: P>P0 ****'
C        PRINT *,'P=',PRESS,'P0=',P0
        ETA=1.
      ELSEIF(K.EQ.1) THEN
        ETA=PRESS/P0
      ELSEIF(K.GT.NMETLEV) THEN
C        PRINT *,'**** ERROR: P<',P2(NMETLEV),' ****'
C        PRINT *,'P=',PRESS
        ETA=PRESS/1000.
      ELSE
        A=A2(K)+(A2(K-1)-A2(K))*(PRESS-P2(K))/
     &    (P2(K-1)-P2(K))
        ETA=(PRESS-A*(1-P0/1000.))/P0
      ENDIF
      P2ETA=ETA
  999 RETURN
      END
C#######################################################################
      SUBROUTINE O3TOTMOD(OZONE,DAY,MONTH,YEAR)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :  To modify total stratospheric ozone data with
C-                          measured total ozone trends.
C-
C-   Inputs  : DAY,MONTH,YEAR,OZONE
C-   Outputs : OZONE
C-   Controls: TOMS total ozone trend data,NDECADES
C-
C-   Created  26-SEP-1995   Colin Johnson
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER MONTH,YEAR,I,J,K,L,ND,N
      INTEGER TRENDDAY(4)
      REAL OZONE(NLONG,MNLAT),DAY,ALPHA
      REAL O3TREND(MNLAT,4), MODLAT(MNLAT)
      REAL DJFTREND(26),MAMTREND(26),JJATREND(26),SONTREND(26)
      REAL TRENDLATS(26), TRENDS(26,4)
      REAL DAYNUMBER,NDECADES
C
C      TOMS total ozone trend for DJF in percent per decade (1/79-5/91)
      DATA DJFTREND /     ! S to N
     &  -6.8, -6.5, -6.2, -5.7, -4.5, -3.8, -3.2, -2.4,
     &  -1.8, -1.0, -0.3,  0.2,  0.3,  0.3,  0.4, -0.5,
     &  -1.6, -2.4, -3.8, -4.8, -5.7, -6.0, -5.6, -5.0,
     &  -4.4, -3.3 /
C
C      TOMS total ozone trend for MAM in percent per decade (1/79-5/91)
      DATA MAMTREND /     ! S to N
     &  -7.2, -5.7, -4.8, -4.4, -3.7, -3.3, -2.8, -1.9,
     &  -1.0, -0.4,  0.2,  1.2,  1.6,  1.6,  1.4,  0.9,
     &  0.3, -0.8, -2.0, -3.2, -4.3, -4.8, -5.0, -4.8,
     &  -5.2, -5.4 /
C
C      TOMS total ozone trend for JJA in percent per decade (1/79-5/91)
      DATA JJATREND /
     &-10.8, -8.3, -7.0, -5.8, -5.0, -4.2, -2.7, -1.8,
     & -1.2, -1.3, -0.8, -0.4,  0.0, -0.2, -0.3, -0.2,
     & -0.1, -0.4, -1.3, -1.8, -1.6, -2.0, -2.2, -2.8,
     & -3.5, -4.0 /
C
C      TOMS total ozone trend for SON in percent per decade (1/79-5/91)
      DATA SONTREND /
     &-13.5,-10.8, -5.7, -3.8, -2.8, -2.0, -1.6, -0.8,
     & -0.4,  0.2,  0.6,  0.6,  0.8,  0.6,  0.3, -0.1,
     & -0.2, -0.8, -1.6, -1.6, -1.8, -2.0, -2.7, -3.6,
     & -4.3, -5.2 /
C
      DATA TRENDLATS /
     &  62.5, 57.5, 52.5, 47.5, 42.5, 37.5, 32.5, 27.5,
     &  22.5, 17.5, 12.5,  7.5,  2.5, -2.5, -7.5,-12.5,
     &-17.5,-22.5,-27.5,-32.5,-37.5,-42.5,-47.5,-52.5,
     &-57.5,-62.5 /
C
      DATA TRENDDAY / 15,105,196,288 /
C
      NDECADES=1.0
      WRITE(6,*) ' NDECADES IN O3TOTMOD = ',NDECADES
      WRITE(7,*) ' NDECADES IN O3TOTMOD = ',NDECADES
C
      ND=DAYNUMBER(DAY,MONTH,93)
C
      DO 10 I=1,MNLAT
        MODLAT(I)=85.0-(I-1)*360./NLONG
   10 CONTINUE
C
      DO 20 I=1,26
        TRENDS(I,1)=DJFTREND(I)
        TRENDS(I,2)=MAMTREND(I)
        TRENDS(I,3)=JJATREND(I)
        TRENDS(I,4)=SONTREND(I)
   20 CONTINUE
C
C      Interpolate with latitude
      DO 60 J=1,4
        DO 50 I=1,MNLAT
C        If latitude higher than in data, set to end point.
          IF(MODLAT(I).GT.TRENDLATS(1)) THEN
            O3TREND(I,J)=TRENDS(1,J)
          ELSEIF(MODLAT(I).LT.TRENDLATS(26)) THEN
            O3TREND(I,J)=TRENDS(26,J)
          ELSE
C        Find interpolation points.
            N=INT((TRENDLATS(1)-MODLAT(I))/5.0)+1
            O3TREND(I,J)=TRENDS(N,J)+(TRENDS(N+1,J)-TRENDS(N,J))*
     &          (MODLAT(I)-TRENDLATS(N))/(TRENDLATS(N+1)-TRENDLATS(N))
          ENDIF
   50   CONTINUE
   60 CONTINUE
C
C      Interpolate with time.
      IF(ND.GT.TRENDDAY(1).AND.ND.LE.TRENDDAY(2)) THEN
        ALPHA = REAL(ND-TRENDDAY(1))/REAL((TRENDDAY(2)-TRENDDAY(1)))
        K=1
        L=2
      ELSEIF(ND.GT.TRENDDAY(2).AND.ND.LE.TRENDDAY(3)) THEN
        ALPHA = REAL(ND-TRENDDAY(2))/REAL((TRENDDAY(3)-TRENDDAY(2)))
        K=2
        L=3
      ELSEIF(ND.GT.TRENDDAY(3).AND.ND.LE.TRENDDAY(4)) THEN
        ALPHA = REAL(ND-TRENDDAY(3))/REAL((TRENDDAY(4)-TRENDDAY(3)))
        K=3
        L=4
      ELSE
        IF(ND.LT.16) ND=ND+365
        ALPHA = REAL(ND-TRENDDAY(4))/REAL((TRENDDAY(1)+365-TRENDDAY(3)))
        K=4
        L=1
      ENDIF
C
      DO 80 I=1,NLONG
        DO 75 J=1,MNLAT
          OZONE(I,J)=OZONE(I,J)+OZONE(I,J)*
     &      (ALPHA*O3TREND(J,K)+(1.0-ALPHA)*O3TREND(J,L))*(NDECADES/100.
     &      0)
   75   CONTINUE
   80 CONTINUE
C
      RETURN
      END
C#######################################################################
      SUBROUTINE O3FACTOR(CONC100,CONC57)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :  To modify stratospheric ozone concentratioons
C-                          with measured ozone trends.
C-
C-   Inputs  : CONC100,CONC57
C-   Outputs : CONC100,CONC57
C-   Controls: ozone trend data,NDECADES
C-
C-   Created  29-SEP-1995   Colin Johnson
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K
      REAL CONC100(MNLAT,NLONG,12),CONC57(MNLAT,NLONG,12)
      REAL TRENDO3(MNLAT,12),TREND(MNLAT),NDECADES
C
C      Seasonally independant trend for now.
      DATA TREND /    ! constant trend with latitude.
     &  -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5,
     &  -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5,
     &  -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5,
     &  -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5, -12.5 /
C
      NDECADES=0.0
      WRITE(6,*) ' NDECADES IN O3FACTOR = ',NDECADES
      WRITE(7,*) ' NDECADES IN O3FACTOR = ',NDECADES
C
      DO K=1,12
        DO I=1,MNLAT
          TRENDO3(I,K)=TREND(I)
          DO J=1,NLONG
            CONC100(I,J,K)=CONC100(I,J,K)+CONC100(I,J,K)*TRENDO3(I,K)*
     &                    (NDECADES/100.0)
            CONC57(I,J,K)=CONC57(I,J,K)+CONC57(I,J,K)*TRENDO3(I,K)*
     &                    (NDECADES/100.0)
          ENDDO
        ENDDO
      ENDDO
C
      RETURN
      END
C#######################################################################
      SUBROUTINE CLMIX(XX,POS,CC,CT,CB,ACP,P,Q,ASTEP,SEED3)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Convectively mix in clouds
C-
C-   Inputs  : XX,POS,CC,CT,CB,ACP,P,Q,ASTEP,SEED3
C-   Outputs : XX
C-   Controls:
C-
C-   Created   5-DEC-1995   Bill Collins
C-   Modified 31-JUL-1996   Colin Johnson Now for spec. humid. data
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-   Updated   7-AUG-1996   Bill Collins Removed 0th lat circle for met arrays
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,II,JJ,N
      REAL H2OCAL,H2O,RANDNUM
C      REAL HUMID(NLONG,MNLAT,NLEV)
      REAL XX(NC,NCELL),POS(3,NCELL)
      REAL P(NMETLONG,NMETLAT),
     &     CC(NMETLONG,NMETLAT),
     &     CB(NMETLONG,NMETLAT),
     &     CT(NMETLONG,NMETLAT),
     &     ACP(NMETLONG,NMETLAT),
     &     Q(NMETLONG,NMETLAT,NMETLEV),
     &     FRAC(NMETLONG,NMETLAT)
      REAL CLCONC(NC,NLONG,MNLAT)
      REAL RAINMIN
      REAL PEFF,ASTEP,MFLUX,ETA2P,R
      PARAMETER(PEFF=0.35) ! precipitation efficiency
C  Minimum rainfall for raining cloud (kg/s per sq m).
      PARAMETER(RAINMIN=1E-5)
      INTEGER NCLOUD(NLONG,MNLAT)
      LOGICAL LCLOUD(NCELL)
      INTEGER*4 SEED3
C
C Zero counter and concentrations
      DO J=1,MNLAT
        DO I=1,NLONG
          NCLOUD(I,J)=0
          DO N=1,NC
            CLCONC(N,I,J)=0.
          ENDDO
        ENDDO
      ENDDO
C
      DO J=1,NMETLAT-1
        DO I=1,NMETLONG
          IF(ACP(I,J).GT.RAINMIN.AND.CB(I,J).GT.0.8) THEN
C            II=INT((I-1)*DLONGM/DLONG)+1
C            JJ=INT((J-1)*DLATM/DLAT)+1
            H2O=Q(I,J,NINT((1.+CB(I,J))/2.))     ! For Q from meteorology
C            H2O=H2OCAL(HUMID,II,JJ,(1.+CB(I,J))/2., P(I,J))
C                   ! Specific humidity (kg/kg)
C Mass flux (kg per timestep)
            MFLUX=ACP(I,J)*ASTEP/(PEFF*(H2O*MH2O/MAIR))
            FRAC(I,J)=
     &        MFLUX/(100.*(P(I,J)-ETA2P(CB(I,J),P(I,J)))/G)
          ELSE
            FRAC(I,J)=4.*CC(I,J)/100.
          ENDIF
          FRAC(I,J)=MIN(FRAC(I,J),1.)
        ENDDO
      ENDDO
C
      DO K=1,NCELL
        I=INT(POS(1,K)/DLONGM)+1
        J=INT(POS(2,K)/DLATM)+1
        LCLOUD(K)=.FALSE.
        IF(POS(3,K).GT.CT(I,J)) THEN
          R=RANDNUM(SEED3)
          IF(R.LT.FRAC(I,J)) THEN
            LCLOUD(K)=.TRUE.
            II=INT((I-1)*DLONGM/DLONG)+1
            JJ=INT((J-1)*DLATM/DLAT)+1
            NCLOUD(II,JJ)=NCLOUD(II,JJ)+1
            DO N=1,NC
              CLCONC(N,II,JJ)=CLCONC(N,II,JJ)+XX(N,K)
            ENDDO
          ENDIF
        ENDIF
      ENDDO
      DO K=1,NCELL
        IF(LCLOUD(K)) THEN
          I=INT(POS(1,K)/DLONGM)+1
          J=INT(POS(2,K)/DLATM)+1
          II=INT((I-1)*DLONGM/DLONG)+1
          JJ=INT((J-1)*DLATM/DLAT)+1
          DO N=1,NC
            XX(N,K)=CLCONC(N,II,JJ)/NCLOUD(II,JJ)
          ENDDO
        ENDIF
      ENDDO
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION BOUND(T0,P0,T,U,V)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATES THE DEPTH OF THE BOUNDARY LAYER USING TWO
C-                         METHODS, PARCEL AND RICHARDSON NUMBER, AND USES THE
C-                         DEEPEST RESULT
C-
C-   Returned value : BOUND
C-   Inputs  : T0,P0,T,U,V
C-   Outputs :
C-   Controls:
C-
C-   Created  11-JUL-1996   Bill Collins
C-   Updated   6-AUG-1996   Bill Collins  Parameters now in INCLUDE
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I
      REAL T0,P0,T(NMETLEV),U(NMETLEV),V(NMETLEV),THET(NMETLEV),TOFF1,
     &  TOFF2
      REAL GAMMA,RCRIT,ETA2P,ETA(NMETLEV),RI,BLR,BLP,DU,TCRIT,E
C
C  TEMPERATURE OFFSETS
      TOFF1=.5
      TOFF2=1.2
      GAMMA=.286
      RCRIT=1.3 ! CRITICAL RICHARDSON NUMBER
C
C      PRINT *,'T0,P0=',T0,P0
C      PRINT *,'U=',U
C      PRINT *,'V=',V
C      PRINT *,'T=',T
C  CALCULATE CRITICAL TEMPERATURE FOR ADIABAT
      IF(T0.LT.T(1)) THEN
        TCRIT=(T(1)+TOFF1)*(1000./ETA2P(ETA2(1),P0))**GAMMA
      ELSE
        TCRIT=(T(1)+TOFF2)*(1000./ETA2P(ETA2(1),P0))**GAMMA
      ENDIF
C      PRINT *,'TCRIT=',TCRIT
C CALCULATE POTENTIAL TEMPERATURE
      DO I=1,NMETLEV
        THET(I)=(T(I))*
     +    (1000./ETA2P(ETA2(I),P0))**GAMMA
      END DO ! I
C      PRINT *,'THET=',THET
C RICHARDSON NUMBER METHOD
      I=1
      RI=0.
C Top of turbulent layer when Ri > Rcrit
      DO WHILE(I.LT.NMETLEV.AND.RI.LT.RCRIT)
        I=I+1
C (Delta U) squared
        DU=((U(I)-U(I-1))**2+(V(I)-V(I-1))**2)
        IF (DU.EQ.0.) DU=0.1
C Ri=(g/T)*(dTheta/dz)/(dU/dz)^2=R*dTheta*dln(eta)/dU^2
        RI=(1E3*RGC/MAIR)*(THET(I)-THET(I-1))*LOG(ETA2(I-1)/ETA2(I))/DU
C        PRINT *,'I,RI',I,RI
      END DO
      IF(I.EQ.NMETLEV) THEN
        BLR=-1.
      ELSE
        BLR=ETA2(I-1)
      ENDIF
C      PRINT *,'BLR=',BLR
C PARCEL METHOD
      I=1
C Top of inversion is where Theta > Tcrit
      DO WHILE(I.LT.NMETLEV.AND.THET(I).LT.TCRIT)
C        PRINT *,'I,THET(I)=',I,THET(I)
        I=I+1
      END DO
      IF(I.EQ.NMETLEV) THEN
        BLP=-1.
      ELSE
C Interpolate eta
        E=ETA2(I-1)+(TCRIT-THET(I-1))*
     &    (ETA2(I)-ETA2(I-1))/(THET(I)-THET(I-1))
        BLP=E
      ENDIF
C      PRINT *,'BLP=',BLP
C Choose the method that gives the deeper boundary layer
      IF(BLP.LT.BLR) THEN
        BOUND=BLP
      ELSE
        BOUND=BLR
      ENDIF
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION AERO(T0,TAUU,TAUV,H)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : CALCULATES THE AERODYNAMIC DEPOSITION VELOCITY
C-
C-   Inputs  : T0,TAUU,TAUV,H
C-   Outputs : AERO (in mm/s)
C-   Controls:
C-
C-   Created  11-JUL-1996   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
C----------------------------------------------------------------------

      REAL T0,TAUU,TAUV,H,USTAR,K,Z1,Z2,L,PHI,PSI,CP,G,RA,TSURF
      DATA K/0.4/,CP/1004.67/,G/9.81/
C Z1 IS REFERENCE HEIGHT FOR DEPOSITION VELOCITIES = 1m
C Z2 IS ARBITRARY HEIGHT WITHIN MIXED BOUNDARY LAYER =50m
      DATA Z1/1.0/,Z2/50.0/
C Ustar is friction velocity
      USTAR=SQRT(SQRT(TAUU**2+TAUV**2))
      TSURF=T0
      IF(USTAR.EQ.0.) USTAR=1E-2
      IF(H.EQ.0.) H=0.1
C      PRINT *,'AERO: T0,USTAR,H=',T0,USTAR,H
C Calculate Monin-Obukhov length
      L=-CP*TSURF*USTAR**3/(K*G*H)
      IF(L.EQ.0.)
     +  PRINT *,'L=0: T0,USTAR,H=',T0,USTAR,H
C Calculate Businger functions
      IF(L.GT.0.) THEN
C Stable b.l.
        PSI=-5*Z2/L
      ELSE
C Unstable b.l.
        PHI=(1-16*Z2/L)**.25
        PSI=2*ALOG((1+PHI**2)/2.)
      ENDIF
      RA=ALOG(Z2/Z1)-PSI
C Calculate Businger functions
      IF(L.GT.0.) THEN
        PSI=-5*Z1/L
C Stable b.l.
      ELSE
C Unstable b.l.
        PHI=(1-16*Z1/L)**.25
        PSI=2*ALOG((1+PHI**2)/2.)
      ENDIF
      RA=RA+PSI
      RA=RA/(K*USTAR)
      AERO=1000./RA ! in mm/s
  999 RETURN
      END
C#######################################################################
      SUBROUTINE MET2DATA(Y,X,NLEVELS)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Convert field from met grid to data grid
C-
C-   Inputs  : X,NLEVELS
C-   Outputs : Y
C-   Controls:
C-
C-   Created   8-AUG-1996   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER K,II,JJ,NLEVELS,I,J,I2
      REAL AISTEP,AJSTEP,FI,FJ,AREA
      REAL X(NMETLONG,NMETLAT,NLEVELS),Y(NLONG,MNLAT,NLEVELS),SUM

      AISTEP=REAL(NMETLONG)/REAL(NLONG)
      AJSTEP=REAL((NMETLAT-1))/REAL(MNLAT)
      AREA=AISTEP*AJSTEP
c      WRITE(6,*) 'MET2DATA: area,aistep,ajstep ',AREA,AISTEP,AJSTEP

      DO K=1,NLEVELS
        DO J=1,MNLAT
          DO I=1,NLONG
            Y(I,J,K)=0.0
          ENDDO
        ENDDO
      ENDDO

C Take each Met Grid point (noting that they are at the corners of the grid
C squares not the centres)
      DO K=1,NLEVELS
        DO J=1,NMETLAT
          DO I=1,NMETLONG
            II=INT((REAL(I)-.5)/AISTEP) ! index on data grid
            JJ=INT((REAL(J)-.5)/AJSTEP) ! index on data grid
            I2=II+1
C split each grid point into 4, with fractions governed by distance to edge of
C data grid
            FI=MAX(II*AISTEP+1.5-I,0.) ! if more than a grid length away
            FJ=MAX(JJ*AJSTEP+1.5-J,0.) ! fractions set to 0.
            IF(II.EQ.0) II=NLONG
C add each fraction to the appropriate data grid square and divide by the
C relative areas of the grid squares (assuming rectangular grids)
            IF(JJ.GT.0) THEN    ! not at north pole
              Y(II,JJ,K)=Y(II,JJ,K)+X(I,J,K)*FI*FJ/AREA
              Y(I2,JJ,K)=Y(I2,JJ,K)+X(I,J,K)*(1.-FI)*FJ/AREA
            ENDIF
            IF(JJ.LT.MNLAT) THEN   ! not at south pole
              Y(II,JJ+1,K)=Y(II,JJ+1,K)+X(I,J,K)*FI*(1.-FJ)/AREA
              Y(I2,JJ+1,K)=Y(I2,JJ+1,K)+X(I,J,K)*(1.-FI)*(1.-FJ)/AREA
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      END
C#######################################################################
      SUBROUTINE CLCALC(CLOUD,HCA,MCA,LCA,CC,CB,CT)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Calculate 3d cloud field on data grid
C-
C-   Inputs  : HCA,MCA,LCA,CC,CB,CT
C-   Outputs : CLOUD
C-   Controls:
C-
C-   Created   8-AUG-1996   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER I,J,K,L
      REAL HCA(NMETLONG,NMETLAT,1,NHR),
     &  MCA(NMETLONG,NMETLAT,1,NHR),
     &  LCA(NMETLONG,NMETLAT,1,NHR),
     &  CC(NMETLONG,NMETLAT,1,NHR),
     &  CB(NMETLONG,NMETLAT,1,NHR),
     &  CT(NMETLONG,NMETLAT,1,NHR),
     &  CMID(NMETLONG,NMETLAT,1),
     &  HCD(NLONG,MNLAT),          !
     &  MCD(NLONG,MNLAT),          !
     &  LCD(NLONG,MNLAT),          !ARRAYS ON
     &  CMD(NLONG,MNLAT),          !DATA GRID
     &  CCD(NLONG,MNLAT),          !
     &  CLOUD(NLONG,MNLAT,NLEV,NHR),ETA
      DO L=1,NHR
        CALL MET2DATA(HCD,HCA(1,1,1,L),1)
        CALL MET2DATA(MCD,MCA(1,1,1,L),1)
        CALL MET2DATA(LCD,LCA(1,1,1,L),1)
        DO J=1,NMETLAT
          DO I=1,NMETLONG
            CMID(I,J,1)=0.5*(CB(I,J,1,L)+CT(I,J,1,L))*CC(I,J,1,L)
          ENDDO
        ENDDO
        CALL MET2DATA(CCD,CC(1,1,1,L),1)
        CALL MET2DATA(CMD,CMID(1,1,1),1)
        DO J=1,MNLAT
          DO I=1,NLONG
            CLOUD(I,J,1,L)=LCD(I,J)
            CLOUD(I,J,3,L)=MCD(I,J)
            CLOUD(I,J,5,L)=HCD(I,J)
            IF(CCD(I,J).GT.0.) THEN
              ETA=CMD(I,J)/CCD(I,J)
              K=1
              DO WHILE(K.LE.NLEV+1.AND.ETA3(K).GT.ETA)
                K=K+1
              ENDDO
              IF(K.GT.NLEV+1) THEN
                PRINT *,'****CLOUDS ABOVE MODEL TOP,I,J,L=',I,J,L
              ELSEIF(ETA.GT.1.0) THEN
                PRINT *,'****CLOUDS BELOW SURFACE,I,J,L=',I,J,L
              ELSE
                CLOUD(I,J,K-1,L)=MIN(CLOUD(I,J,K-1,L)+CCD(I,J),100.)
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
  999 RETURN
      END
C#######################################################################
      REAL FUNCTION RANDNUM(SEED)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods : Returns a random number, and updates SEED
C-
C-   Inputs  : SEED
C-   Outputs : SEED
C-   Controls:
C-
C-   Created   7-AUG-1996   Bill Collins
C-
C----------------------------------------------------------------------
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER SEED
      IF(CRAY) THEN
        CALL RANSET(SEED)
        RANDNUM=RANF()
        SEED=RANGET()
      ELSE
        RANDNUM=RAN(SEED)
      ENDIF
  999 RETURN
      END
C#######################################################################
      SUBROUTINE CUBFIT2D(X,Y,XX,YY)
C-----------------------------------------------------------------------
C
C     PURPOSE:  Polynomial cubic interpolation in vertical direction for
C               arrays over long x lat grid.
C
C     INPUTS:   X,Y,XX     X are the positions of the know Y values,
C                          XX the required position.
C     OUTPUTS:  YY         YY is the array of required values.
C
C     Created:  28-JAN-1997  Bill Collins 
C     Modified  29-JAN-1997  Colin Johnson  For long x lat arrays.
C-----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C
      INTEGER N,I,J
      PARAMETER(N=4)
      REAL X(N),Y(NMETLONG,NMETLAT,N),YY(NMETLONG,NMETLAT)
      REAL XX,X2,X3,A,B,C,D,DYDX2,DYDX3,Y2,Y3

      DO I=1,NMETLONG
        DO J=1,NMETLAT
          IF(XX.GT.X(3)) THEN
            DYDX2=(Y(I,J,4)-Y(I,J,2))/(X(4)-X(2))     ! derivative at point 3
            DYDX3=(Y(I,J,4)-Y(I,J,3))/(X(4)-X(3))     ! derivative at point 4
C          Define coordinate system such that x=0 coincides with x2.
            X2=X(3)
            X3=X(4)-X2
            Y2=Y(I,J,3)
            Y3=Y(I,J,4)
          ELSE
            DYDX2=(Y(I,J,3)-Y(I,J,1))/(X(3)-X(1))     ! derivative at point 2
            DYDX3=(Y(I,J,4)-Y(I,J,2))/(X(4)-X(2))     ! derivative at point 3
C          Define coordinate system such that x=0 coincides with x2.
            X2=X(2)
            X3=X(3)-X2
            Y2=Y(I,J,2)
            Y3=Y(I,J,3)
          ENDIF
          D=Y2
          C=DYDX2
          B=(3*Y3-X3*DYDX3-2*C*X3-3*D)/X3**2
          A=(Y3-B*X3**2-C*X3-D)/X3**3
          YY(I,J)=A*(XX-X2)**3+B*(XX-X2)**2+C*(XX-X2)+D
        ENDDO
      ENDDO
  
      RETURN
      END
C#######################################################################
      SUBROUTINE CUBFIT(X,Y,X1,Y1)
C-----------------------------------------------------------------------
C
C     PURPOSE:  Polynomial cubic interpolation in vertical direction.
C
C     INPUTS:   X,Y,X1     X are the positions of the know Y values,
C                          X1 the required position.
C     OUTPUTS:  Y1         Y1 is the required value.
C
C     Created:  28-JAN-1997  Bill Collins 
C-----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C
      INTEGER N
      PARAMETER(N=4)
      REAL X(N),Y(N),Y1
      REAL X1,X2,X3,A,B,C,D,DYDX2,DYDX3

      DYDX2=(Y(3)-Y(1))/(X(3)-X(1))     ! derivative at point 2
      DYDX3=(Y(4)-Y(2))/(X(4)-X(2))     ! derivative at point 3
C      Define coordinate system such that x=0 coincides with x2.
      X2=X(2)
      X3=X(3)-X2
      D=Y(2)
      C=DYDX2
      B=(3*Y(3)-X3*DYDX3-2*C*X3-3*D)/X3**2
      A=(Y(3)-B*X3**2-C*X3-D)/X3**3
      Y1=A*(X1-X2)**3+B*(X1-X2)**2+C*(X1-X2)+D
  
      RETURN
      END
C#######################################################################
      SUBROUTINE STATION(XX,POS,BL,STLON,STLAT,NSTATION,DAY,
     &  MONTH,YEAR,CLIST,NCHEM,M)
C----------------------------------------------------------------------
C-
C-   Purpose and Methods :
C-
C-   Inputs  :
C-   Outputs :
C-   Controls:
C-
C-   Created  24-FEB-1997   Bill Collins
C-
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'INOPERVM10.SOA2'
C----------------------------------------------------------------------
      INTEGER NSTATION,N,I,J,IM,JM,ICODE,MONTH,YEAR,CLIST(NUMCHEM),NCHEM
      REAL XX(NC,NCELL),POS(3,NCELL),STLON(NUMSTAT),STLAT(NUMSTAT),
     &  BL(NMETLONG,NMETLAT),DAY,M(NCELL)
      REAL A,B,C,DANG,MAXANG,RAD,COSANG
      DATA MAXANG /1.0/ ! Maximum solid angle in degrees

      RAD=PI/180.0
      DO N=1,NCELL
        C=RAD*POS(2,N)
        DO I=1,NSTATION
          A=RAD*(90.-STLAT(I))
          B=RAD*(POS(1,N)-AMOD(360.+STLON(I),360.))
          COSANG=COS(C)*COS(A)+SIN(C)*SIN(A)*COS(B)
          IF(COSANG.GT.COS(MAXANG*RAD))THEN

            IM=INT(POS(1,N)/DLONGM+1.0)   !Indicies for met grids
            JM=INT(POS(2,N)/DLATM+1.0)
            ICODE=0
            IF(POS(3,N).LT.BL(IM,JM)) ICODE=1   !b.l.
            WRITE(60,900) I,YEAR,MONTH,DAY,POS(3,N),ICODE,N
            DO J=1,NCHEM
              WRITE(60,*) XX(CLIST(J),N)
C              WRITE(60,*) XX(CLIST(J),N)*M(N)
            ENDDO
          ENDIF
        ENDDO
      ENDDO

  900 FORMAT(I3,I6,I5,F8.3,F12.5,I3,I8)

  999 RETURN
      END
C#######################################################################
C*******These routines are all dummies to satisfy LINKing. *********************
C*******These routines are all dummies to satisfy LINKing. *********************
C******* They Should not be called
      REAL FUNCTION RANF()
      PRINT *,
     &  '*****ERROR: Called dummy RANF. This should not be called!'
      RANF=-1.
      RETURN
      END
      REAL FUNCTION RANGET()
      PRINT *,
     &  '*****ERROR: Called dummy RANGET. This should not be called!'
      RANGET=-1.
      RETURN
      END
      REAL FUNCTION RAN(SEED)
      INTEGER SEED
      PRINT *,'*****ERROR: Called dummy RAN. This should not be called!'
      RAN=-1
      RETURN
      END
      SUBROUTINE RANSET(SEED)
      INTEGER SEED
      PRINT *,
     &  '*****ERROR: Called dummy RANSET. This should not be called!'
      RETURN
      END
C*******End of dummy routines***************************************************
