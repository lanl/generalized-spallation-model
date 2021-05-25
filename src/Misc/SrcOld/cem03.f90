     program cem03

! ======================================================================
!
!                              NOTICE
!
!    This software and ancillary information (herein called "SOFTWARE")
!    named CEM03.03 is made available under the terms described here.
!    The SOFTWARE has been approved for release with associated LA-CC
!    number LA-CC-04-085.
!
!    Copyright (2012). Los Alamos National Security, LLC.
!
!    This material was produced under U.S. Government contract
!    DE-AC52-06NA25396 for Los Alamos National Laboratory, which is
!    operated by Los Alamos National Security, LLC, for the U.S. 
!    Department of Energy. The Government is granted for itself and 
!    others acting on its behalf a paid-up, nonexclusive, irrevocable
!    worldwide license in this material to reproduce, prepare derivative
!    works, and perform publicly and display publicly.
!    
!    NEITHER THE UNITED STATES NOR THE UNITED STATES DEPARTMENT OF 
!    ENERGY, NOR LOS ALAMOS NATIONAL SECURITY LLC, NOR ANY OF THEIR 
!    EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY
!    LEGAL LIABILITY OR RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS,
!    OR USEFULNESS OF ANY INFORMATION, APPARATUS, PRODUCT, OR PROCESS
!    DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT INFRINGE PRIVATELY
!    OWNED RIGHTS.
!
!    Additionally, this program is free software; you can redistribute 
!    it and/or modify it under the terms of the GNU General Publi! 
!    License as published by the Free Software Foundation; either 
!    version 2 of the License, or (at your option) any later version. 
!    Accordingly, this program is distributed in the hope that it will 
!    be useful, but WITHOUT ANY WARRANTY; without even the implied 
!    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
!    See the GNU General Public License for more details. 
!
! ======================================================================
!
!    The primary authors of CEM03.03 are:
!    S. G. Mashnik (LANL), K. K. Gudima (IAP), and A. J. Sierk (LANL);
!    with important contributions from R. E. Prael (LANL), M. I. Baznat (IAP),
!    and N. Mokhov (Fermilab).  (IAP = IAP, Academy of Science of Moldova.)
!
! ======================================================================
!
!    Final version for CEM03.03 release, AJS, LANL T-2, February, 2012.
!
!    INCOMPLETE LIST OF CHANGES:
!    1) Restricted asymmetric fission fragments to A >= 13 to prevent
!       a very rare problem.
!    2) Added Fermi breakup after each stage of the reaction to decay
!       any excited nuclei with A < 13 produced at the stage considered.
!    3) Replaced the RNDM generator with the RANG generator, which is
!       about 5 times faster because it can be compiled inline, and
!       has a period of about 2^63 ~ 10^19. See comments in the module
!       ranmc.f.
!    4) An early error derived wrong values for the a_f/a_n 
!       multipliers found in the routine FITAFPA for the nucleus
!       181 Ta, which would affect fission cross sections for Z = 72 and
!       73. New values which now actually do reproduce the systematics
!       of Prokofiev are included in the routine.
!    5) Some fixes to the Fermi breakup were made by K. K. Gudima, 
!       R. Prael of LANL, and S. G. Mashnik.
!    6) Integers are now explicitly typed as Real*4 or real*8 as needed.
!    7) Several other bug fixes.
!    8) Some additional clarifying comments were added to various SRs.
!
! ======================================================================
!    Various minor mods. were made; 2005-2009
! ======================================================================
!
!   October 7, 2005.
!
!   Incorporated several fixes to problems cropping up when Mokhov
!   runs a CEM03 event generator inside MARS in an MPP implementation of
!   MARS.  Also, some revised values of af/an for fission of Tungsten
!   isotopes were added to reflect recent data. AJS
!
! ======================================================================
!
!   February 14, 2005:
!
!   There have been several major changes introduced by Gudima and 
!   Baznat, including redetermining af/an values for fission.
!     **** See 4) above ****                                  Mashnik
!   introduced Kalbach systematics for preequilibrium decay, some
!   improved angular distribution treatments for N-N and gamma-N
!   reactions and incorporation of systematics for gamma-A total cross
!   sections were implemented by Gudima and Mashnik. Sierk has 
!   rewritten much of this later coding to vastly improve the execution
!   speed of the code, and also made some speedups in GEM2. Many 
!   additional output options have been implemented. The important
!   improvements are discussed in the CEM03.01 Manual.
!
! ======================================================================
!
!   March 11, 2004.
!
!   THE CODE SHOULD BE COMPILED TO USE 8-BYTE INTEGERS!!!!!
!    ****  See 6) above ****
!   (Large simulations exhaust the range of 32-bit integers.)
!
!   Improvements made by A. J. Sierk, LANL T-16:
!
!   Edited various modules to have a consistent style (lower case,
!   indentation, etc.).
!   Corrected a number of logic errors and outright mistakes.
!   Fixed the photonuclear part of the cascade, which was incorrectly
!   implemented previously.
!   Removed calculation of several arrays from inside PRECOF and put
!   the quantities in larger arrays to save time (ALJ and GB).
!   Broke up PRECOF into a number of smaller and more manageable
!   pieces; (new) PRECOF, PREQAUX, AUXL, PEQEMT, EQDECY.
!   Removed a large part of TYPEOUT into 2 separate subroutines PRTDIST
!   and PRTMULT to remove redundant code fragments.
!   Put in GAUSS2, a much more efficient gaussian-distributed random
!   number generator in place of GAUSSN, used by GEM2.
!   Enhanced the breakdown of emitted particles into those from
!   spallation, prefission, fission fragments, coalescence, etc.
!   Fixed the DERIG routine so it works properly for debugging the
!   preequilibrium, evaporation, and fission fragment production.
!   Converted many (all, I hope, except large tables in MOLLNIX, etc.)
!   constants to double precision.
!   Used the array a3rd to remove many calculations of A^1/3.
!   Put the reduced mass calculation into INITIAL to save time, also
!   ignoring the mass excess to remove the slight Z-dependence of
!   the reduced masses. **** THIS IS NOT IMPLEMENTED IN CEM03.03 ****
!   Fixed the calculation of statistics of the nuclei at various
!   stages of the collision. (See TYPEOUT, PRTMULT, PRTDIST)
!   Completely removed the iopt = 1 option, which gives the CEM95 
!   version of the code.  This is obsolete and unuseable with the 
!   modified GEM2 code modules.
!   Removed and/or commented some portions of unused code.
!   Replaced many INT statements with NINT where appropriate.
!   Removed all reference to file 14, the old cemxx.out file.
!   Replaced the Wapstra + Cameron calculations in the ENERGY function
!   by Wapstra and Moller-Nix, where MN are defined; use MNMACRO for
!   heavier nuclei outside the MN table, and Cameron (based on M(O16)
!   = 16.000!!) only for EXTREMELY neutron-rich isotopes of Z = 1-7.
!   Removed the request for the name of the input file; this is always
!   cem03.inp in the current version.
!   Switched to REAL*8 typing for more precision in variable typing.
!   Renamed the auxiliary ....tbl files to lower case.
!   Updated the constants in md in GITAB to be current with a newer
!   version of the Wapstra-Audi mass table.
!   Removed all EQUIVALENCE statements as a token move toward f90/f95.
!   Fixed the coalescence module; the trajectory separation was not
!   defined, so was always zero and the comparison to a radius 
!   parameter was always satisfied. This leads to MUCH less coalescence.
!
! ======================================================================

!*******************************************************************
! Cascade-Exciton Model by Stepan Mashnik, A. J. Sierk, 
! Konstantin Gudima et al.
! Version CEM2KPH of July 2003
!
! cem03.f, fermi2k2.f, gadd90.f, gem2fit.f, photo.f:
! modified August 2003 by NVMokhov
!
!   "Last" change: 14-AUG-2003 by NVMokhov
!
! Modifications by NVMokhov: 12-14 August 2003:

! Conversion to Global DOUBLE PRECISION

! ALOG  replaced with LOG
! Similarly: DABS->ABS, DSQRT ->SQRT, DCOS->COS, DSIN->SIN, DEXP->EXP
! AMAX1 replaced with MAX
! AMIN1 replaced with MIN
! IFIX  replaced with INT
! FLOAT replaced with DBLE
! REAL  replaced with DBLE
! DNINT replaced with ANINT
! IDNINT replaced with NINT

! functions RAN1, RAN3 and RNDM(-1) removed, 
! double precision MARS'S RNDM(-1.) is used instead
!   ****  See 3) above ****

! Modifications by NVMokhov: 9-15 June1998, update 08/14/03:

! subroutine TRANS  renamed to TRANS8
! subroutine DIRECT renamed to DIRECT8
! function   COLOMB renamed to COLOMB8
! function   SIGMAT renamed to SIGMAT8
! function   GEOM   renamed to GEOM8

! common/O/      has been aligned
! common/VUL/    has been aligned
! common/ADBF/   has been aligned
! common/MENU2/  has been aligned
! common/FISCEM/ has been aligned

! Modifications by NVMokhov: 01-DEC-1998, update 08/14/03:

! function FIS   -> subroutine sfis
! function FINT  -> subroutine sfint
! function FINT1 -> subroutine sfint1
! function FINT2 -> subroutine sfint2 - commented (unused)
! function fname -> subroutine sfname
! function s1    -> subroutine ss1
! function S2    -> subroutine ss2

! Modification by NVMokhov: 09-Oct-1999, update 08/14/03:
! common /INDEX/ -> /BINDEX/
! common /FISS/ replaced with /FISCEM/

!   "Last" change: 14-AUG-2003 by NVMokhov
!   "Last" change: 17-SEP-2004 by KKGudima
!
! ======================================================================
!
!   Changes made by S. G. Mashnik, LANL T-16, 2000-2001 to get a
!        preliminary version of CEM2k:
!
!    1. Changed the method for transition from the CASCADE stage of a
!       reaction to the preequilibrium and the time of equilibration.
!       For incident energies above 150 Mev, the transition from the
!       cascade stage of a reaction to the preequiliblium is determined
!       comparing the energy of the cascade nucleons to a cutoff energy
!       of 1 MeV (still a parameter): all cascade nucleons with energies
!       less than 1 MeV above the Fermi surface are absorbed (as excitons),
!       to continue the following equilibration of the preequilibrium nucleus
!       and emit particles at the preequilibrium stage; the cascade nucleons
!       with higher energies are considered as cascade particles with 
!       further interactions with intranuclear nucleons (spectators), if the
!       Pauli principle allows this.
!
!    2. At incident energies above 150 Mev, only transitions with Delta_n = +2
!       (in the direction of equilibration) are allowed at the preequilibrium
!       part of a reaction. This makes the preequilibrium stage shorter
!       and the evaporation stage longer, that in couple with 1) result in
!       a longer evaporation part of a reaction, with higher excitation
!       energy, and, as a result, more evaporated neutrons. Both points
!       1) and 2) were inspired by the recent GSI measurements (Phys. Rev.
!       Lett. 84 (2000) 5736): Incorporating 1) and 2) in CEM97 allows us
!       to describe well the GSI data, while without these modifications
!       we got with CEM97 too few neutrons and a bad agreement with the 
!       data, just as we got with other 7 different codes we tested.
!
!    3. To be able to describe correctly backward emitted particles at 
!       incident energies bellow 150, MeV we keep in CEM2k the "Proximity"
!       parameter, P=0.3, used previously in CEM97 and CEM95, and take into
!       account all transitions, Delta_n = +2, 0, and -2 at the 
!       preequilibrium stage of a reaction. Some "physical" speculations 
!       may be made about this (changing the time of the cascade and
!       preequilibrium stages of reactions with increasing the energy of the
!       bombarding particle), but we do not have now a good understanding of
!       how quantitatively and qualitatively different mechanisms of nuclear 
!       reactions change with the bombarding energy, and the mentioned
!       changes here are of a more pragmati! type: to describe better all
!       the available data.
!
!    4. The real binding energies were incorporated for nucleons at the
!       cascade stage of reactions instead of the approximation of a constant 
!       separation energy of 7 MeV used in previous versions of the CEM. This
!       required an additional routine, BindNUC, and improved significantly
!       the agreement with the data for some excitation functions, like 
!       (p,n), (n,p), (p,2p), etc., where the threshold of reactions is
!       important and should be calculated accurately.
!
!    5. The momentum-energy conservation for the each cascade simulated
!       event was imposed using real masses of the projectile and target
!       and of emitted cascade particles and residual excited nucleus after
!       the cascade: The excitation energy of a residual nucleus is 
!       redefined according to the momentum-energy conservation law, or
!       this cascade event is considered false and resimulated, if the
!       conservation law does not provide a positive excitation energy for
!       the simulated already emitted particles and residual nucleus.
!       A new routine, RENORM, was written for this, and included in CEM2k.
!       The last points 4) and 5) have solved the problem #1 in the list
!       of "deficients" written above in 1997 by A.J. Sierk, and allow to
!       get a better agreement with the data. Note, than the "deficient #6
!       of the mentioned list was solved in 1999 by A.J. Sierk: the present
!       version of the code is several times (up to 6-7, for heavy targets)
!       faster than the initial version of CEM97. 
!
!    6. The reduced masses of particles were included in calculation particle
!       widths at preequilibrium and evaporation stages of a reaction instead
!       of using the approximation of no-recoil used in previous versions of
!       CEM. This point is especially important when calculating emission of
!       complex particles from light nuclei, and allowed to get a much better
!       agreement with the data for the yields of He4, He3, t, and d (gas
!       production) from light nuclei. But to solve completely the problem 
!       of complex particle emission (gas production) from arbitrary targets,
!       better inverse cross sections have to be incorporated in CEM2k, as
!       mentioned above in "deficient" #2. We derived already our own 
!       universal systematics for inverse cross sections of complex particles
!       and light fragments and plan to incorporate them in CEM2k in FY2002,
!       solving the "deficients" #2 and 4 from the above list.
!
!    7. To solve the problem of using reliable total reaction cross sections 
!       (for the absolute normalization of calculated yields) at incident 
!       energies bellow 100 Mev, we have incorporated into CEM2k the NASA 
!       systematics by Tripathi et al. (niM b117 (1996) 347) for all incident
!       protons and neutrons with energies above the maximum in the reaction 
!       cross section, and the Kalbach systematics (J. Phys. G: Nucl. Phys.,
!       24 (1998) 847) for neutrons of lower energies. All nucleon-induced
!       reaction results by CEM2k are now normalized to these reaction cross
!       sections (printed in the output file as "Used here inelastic cross
!       section"), while the old inelastic cross section calculated by the code
!       using the geometrical cross section and the numbers of inelastic and
!       elastic simulated events are printed nearby in the output file as
!       ("Monte Carlo inelastic cross section", so a renormalization of results
!       to the old cross section is possible as well. Note, that the new 
!       normalization provides a much better agreement with practically all 
!       available nucleon-induced reaction data.
!
!  with KKG and MIB (Baznat) changes for interpolations of the fitaf 
!  and fitaf1 
! 
!  last changes(gb, isotope printing,ang. momenta etc.) by KKG 07/12/02
!  sigpre is included by KKG  07/15/02
!  Fermi decay of excited nuclei (A <= 12) is included by KKG 08/06/02
!  last corrections from 10.08/02 by KKG
!  Coalescence of the cascade nucleons into d,t,he3,he4 is included by
!  KKG 02/06/2003 
!  last corrections by KKG&MIB 03/20/03 (see below and vlob) and
!  23/06/03 (see cascad)
!
!   "Last" change: 13-AUG-2003 by NVMokhov
!    Modified by A. J. Sierk, LANL T-16, October, 2003.
!    Modified by K. K. Gudima, LANL T-16, Feb.-Mar., 2004.
!
! ======================================================================
!
!*******************************************************************
!
!   December, 1997
!
!   This program is a modified version of the code CEM95 written by
!   S. G. Mashnik.
!   
!   Many of the historical options have been removed; so that only the
!   current best physics options are retained.  There are two basic
!   options:
!     1).  The CEM95 program as released by Mashnik in 1995; with its
!          preferred options for level densities (iljinov, et al.,#3, 
!          1992), microscopic ground state corrections (Truran, Cameron,
!          and Hilf, 1970), and macroscopic fission barrier heights 
!          (krappe, Nix, & Sierk, 1979). This version of the code
!          uses old-style nuclear masses (M(O-16) = 16.0000),
!          and the Cameron (1957) macroscopic energy calculation; it
!          also assumes all nucleon masses are 0.94 Gev, and all pion
!          masses are 0.14 GeV.
!          This version uses the new elementary N-N and pi-N
!          cross sections in the cascade, so is not identical to the
!          original CEM95; differences are small in the cases so far
!          checked.
!
!     2).  The partially upgraded 1997 version which includes the
!          mass tables of Moller, Nix, Myers, & Swiatecki, with
!          the corresponding shell corrections and pairing gaps,
!          the level densities as calculated by Sierk in 1996 to be
!          consistent with the Moller-Nix microscopic corrections using
!          identical methods to those of Iljinov, et al., new fits
!          to the elementary N-N and pi-N cross sections used in the
!          cascade portion of the model, actual free nucleon and pion
!          masses used in the cascade, and the Sierk (1986) angular
!          momentum dependnt macroscopic fission barriers, which are
!          consistent with the macroscopic model used in the Moller-
!          Nix mass calculations.
!
!    NOTE: This version still has many deficiencies which will be
!          addressed in the coming months.  This preliminary release
!          is being made because of the desire of the MCNPX team to
!          have a version of the code available.
!
!    Among the deficiencies are:
! 
!     1).  The cascade does not conserve energy properly. The energy
!          of the Fermi surface is assumed to be -7.0 Mev, irrespective
!          of the actual nuclide. The excitation energy of the 
!          residual nucleus after emission of a cascade particle is
!          not calculated with the actual ground state energy or 
!          particle separation energy.
!
!     2).  The inverse cross sections used in the calculation of
!          preequilibrium and compound particle decay widths are not
!          a good representation of real cross sections.
!
!     3).  While calculating fission, the code does not have a model
!          for selecting fission fragments and following their 
!          subsequent decay. When fission is a significant channel,
!          the emission of low energy nucleons will not be properly
!          modeled.
!
!     4).  The code does not have a model for fragmentation (emission
!          of particles heavier than alphas), either in the pre-
!          equilibrium or the compound decay parts of the code.
!
!     5).  Nuclei near the proton or neutron drip line are allowed to
!          to exist, although their particle decay will occur in much
!          less than the compound decay times implicitly assumed in
!          the model.
!
!     6).  No serious attempt has been made to improve the execution
!          speed of the code by analyzing where the majority of time
!          is being spent.
!
!     ....
!
! ======================================================================
!
! NOTE:   In the derivation of the level density parameters by Iljinov,
!         et al., pairing of 11.0/sqrt(A) was used, although the value
!         of 12.0 was stated in the paper.  This code uses 12.0, which
!         is inconsistent with the parameter sets.
!
!  Changes made at LANL, July-August 1995 (D. W. Muir):
!
!     1.  3 redundant variables removed (prinp:zapran,franz and partn:v)
!     2.  hollerith constants replaced with single-quote limited strings
!     3.  program card activated
!     4.  all Uc alphabetic characters outside of strings lowered.
!     5.  comments added to functions ranf1 and rndm to explain purpose
!     6.  save statement added to function ranf1 (not actually required)
!     7.  added cpu timing call and timing print
!     8.  most variables read from a single record for easier updating
!
!   Changes made by A. J. Sierk,  LANL  T-2, February-May, 1996; July-
!        December, 1997:
!
!    Moved program card to beginning of file.
!    Changed arithmetic if and go to (a,b,c...) statements to
!        if..then..else constructions; thereby removing many numbers
!        from statements.
!    Added indentation to if..then..else  and  do loops.
!    Inserted real and int functions to remove implicit typing where
!        noticed.
!    Explicitly open unit 15; cem97n.inp .
!    Change unit 16 to cem97n.info; for error and diagnostic messages.
!    Changed comment lines to be more easily readable.
!    Added extensive new comments.
!    Changed output formats to enhance readability.
!    Suppressed printout of descriptions of calculation after the
!        first energy; originally this was repeated for each energy
!        of the projectile.
!    Reduced maximum length of lines to 72 columns.
!    Arranged common blocks alphabetically in each subroutine.
!    Converted to generic Fortran implicit functions (alog -> log, etc.)
!   NOTE:  This RNDM was a different generator and has been discarded;
!   AJS  1/07/05.
!    Modified rndm to remove a problem with random numbers [rndm(i-1)] 
!        greater than 0.999 . [The succeeding random number [rndm(i)] 
!        was constrained to be in the neighborhood of 0.80, the spread
!        depending on the magnitude of 1.0 - rndm(i-1)].
!    Removed the ground-state shell correction calculation from bf,
!        putting it into a call to shell.
!    Changed the calling arguments to shell, to implement above^.
!    Added the parameter ipair, which allows selection between the
!        original approximate pairing gap of 12.0/sqrt(A) * chi and
!        the tabulated pairing gaps of Moller, Nix & Kratz (1997);
!        [Atomic Data Nucl. data Tables 66, #2 131-343].
!    Added the character variable heading(nh) to allow for printing a
!        descriptive text at the beginning of cem97n.res.
!    Added the Moller-Nix shell correction option to the ground-state
!        microscopic correction to the barrier height.
!    Put in tabulated (where available) or calculated (Moller-Nix)
!        mass excesses, in lieu of the formula in deltam.
!        For nuclei outside the table, use the macroscopic RLDM
!        formula from Moller, Nix, Myers, & Swiatecki.
!    Derived additional semiempirical level density parameters using
!        Moller-Nix ground-state microscopic corrections, both with 
!        and without Moller-Nix-Kratz pairing gaps.
!        [Atomic Data Nucl. data Tables, 59, 185 (1995)]
!        (DISCOVERD THAT ILJINOV, ET AL. USED 11.0/sqrt(A) in DERIVING 
!        THEIR LEVEL DENSITY SYSTEMATICS INSTEAD OF THE STATED VALUE
!        OF 12.0/sqrt(A)!!)
!    Corrected the energetics in PRECOF to use a more accurate mass
!        for the compound or residual nucleus.
!    Removed the use of the ground-state microscopic correction from
!        the calculation of the level density parameter at the
!        saddle point.
!    Extended the number of channels printed out for mchy=1.
!    Added the mpyld flag to print out a summary table of particles
!        (n, p, d, t, He-3, alpha, pi +,-,0) emitted without the detail
!        of mchy=1.
!    Print out the time, the energy, and the reaction at the end of 
!        each energy of a multi-energy run.
!    Made several changes to eliminate infinite loops.
!
! ======================================================================
!
!                    Program input variables:
!**cm0     = projectile mass in GeV (enter a negative number to end run)
!  t0gev   = initial projectile kinetic energy (in GeV)
!  anucl   = target mass number.
!  znucl   = target proton number.
!**me0     = projectile charge (in units of proton charge)
!**mb0     = projectile baryon number
!  Above projectile quantities cm0, me0, mb0, are OBSOLETE!
!  limc    = total number of inelastic events, normally 2000-500000.
!**nnnp    = number of initial cascade steps with detailed diagnostics.
!  nnnp REMOVED!
!**wam     = ratio of saddle-point fission level density to compound
!            level density; af/ac.  (Usually called af/an).
!**idel    = do evaporation calculations with or without fission.
!          = 0 do calculations without fission.
!          = 1 allow competition between fission and particle emission
!            at compound stage.
!          = 2 to accumulate particle spectra, etc. ONLY for fission
!            events.
! NOTE:  idel removed from input; idel=2 function moved to mpyld!
!  dt0     = projectile kinetic energy step size in MeV.
!  t0max   = final projectile kinetic energy in MeV (last energy run
!            will be less than or equal to t0max).
!     Note:  To run a single energy, input a negative dt0 (-5.0) and
!             a value of t0max larger than 1000.*t0gev
!  dteta   = step size (degrees) in ejectile angular distributions.
!  mspec   = (0/1/2) if ejectile energy spectra (not/are) needed.
!             (See variables ipar1 and ipar2.)
!            mspec = 2 gives a breakdown of the source of evaporated
!            particles (prefiss, fiss frags, evap residue).
!  mpyld   = (0/1/2) if particle yield summary table (is not/is)
!            desired.  Prints cross sections and mean energies for
!            particles n -- pi+ broken into total, cascade,
!            preequilibrium, and compound production.
!            mpyld = 2 gives multiplicities ONLY for fission events.
!  mchy    = (0/1) if excitation functions (are not/are) needed.
!            If mchy = 1, 192 "channel" cross sections  with values of
!            at least 1 mb and up to 26 summed channel cross sections
!            in mb  (not isotope yields, see misy) are calculated.
!            To save cpu time in routine calculations, use mchy=0.
!  misy    = (0/1 or 2, or 3) If isotope yields (are not/are) needed.
!            If misy=1, the primary yield for all nuclides with non-zero
!            production will be printed.
!            If misy=2, the primary yield for all nuclides with non-zero
!            production and forward/backward correlations will be printed.
!            If misy=3, the residual (after cascade and preeq.) nuclear
!            information, and fission-fragment opening angle distribution,
!            and the neutron multiplicity distribution will be printed.
!  mdubl   = (0/1/2) if ddx spectra (are not/are) needed.
!            (See variables ipar1 and ipar2.)
!            mdubl = 2 gives a breakdown of the source of evaporated
!            particles (prefiss, fiss frags, evap residue).
!  mang    = (0/1/2) if angular distributions (are not/are) needed.
!            (See variables ipar1 and ipar2.)
!            mang = 2 gives a breakdown of the source of evaporated
!            particles (prefiss, fiss frags, evap residue).
!  ipar1,ipar2 = range of ejectile types for spectrum calcs.
!            See variables mspec, mang, mdubl.  
!            Types are defined as follows:
!            1 n          4 t          7 pi-
!            2 p          5 He3        8 pi0
!            3 d          6 He4        9 pi+
!
!  tet1(j),tet2(j) = up to 10 angle bins for angular distributions.
!            used if mdubl=1.  Terminate with a negative tet1 value.
!  tmin(j),tmax(j),dt(j) = 4 energy regions and bin sizes (MeV).
!            used if mdubl>=1 or mspec>=1
! 
!**The following 5 flags are set in INITIAL!!
!**noprec  = (0/1) for (using/not using) preequilibrium decay.
!**sigpre  = value of "smearing" parameter for transition from
!            preq. to compound decay. Usually 0.4 for CEM03. 
!**nevtype = number of particle types evaporated in GEM2; 6 for 
!            p-->alpha; 66 for all isotopes up to Mg-28. See table
!            in Block Data BDJEC. 
!**irefrac = (0/1) for (NOT/changing directions) when passing between
!            zones of the potential during the cascade. 
!**icostan = (0/1) for using (OLD/NEW) approximations for the 
!            angular distributions of N-N elastic scattering and 
!            gamma-N [Duarte approx for T <= 2 GeV; extrapolation  
!            to avoid unphysical deviations in old approximations for 
!            angles near 0 and pi for other energies. 
!
!  nh      = Number of lines of text (up to 10) to be printed as
!            a header describing the calculation at the beginning of
!            the cem97n.res file.
!  header()  Lines of text as described above (up to 72 characters per
!            line).
!
! ======================================================================
!
!    Edited by A. J. Sierk,  LANL  T-2  February, 1996.
!    Edited by A. J. Sierk,  LANL  T-2  November-December, 1997.
!    Modified by AJS, March, 1999.
!    Modified by SGM at 06/16/2000
!    Modified by KKG at 10/29/2001
!    Modified by A. J. Sierk, LANL T-16, October, 2003.
!    Modified by KKG , Feb, 2004
!    Comments modified by AJS, May, 2004.
!    Modified by KKG , June, October, 2004
!    Edited by AJS, January, 2005.
!    Modified by AJS, January, 2005.
!    Modified by AJS, July-September, 2005.
!    Updated copyright notice, AJS, February, 2006.
!    Edited by AJS, LANL T-2, December, 2011 - February, 2012.
!    Modified by LMK, XCP-3, June 2012-July 2013 (expand preeq).
!    Edited by LMK, XCP-3, July 2013 (included error protection).
!
! ======================================================================

! LMK 07/2012, Added hist_mod.f90
 	USE hist_mod
! 
! LMK 02/2013
	USE gamma_j_mod
!
! LMK 07/2014
	USE inverse_x_section
	USE fund_data


      implicit real*8 (a-h, o-z)
      integer*4 ia1, iafr, ibadren, ibrems, icase, iclose, idel, &
          ifam, ifr, ih, ijsp, in, ipar1, ipar2, ityp, iz, &
          iz1, izfr, j, jfr, kfr, kstart, ktot, l0, ln, ln1, &
          m, m1, mang, mb0, mchy, mdubl, me0, misy, mpyld, ms0, &
          mspec, n, n0, nel, nevtype, nexin, nexip, nh, nh0, &
          nhol, nhump, np0, npz0, nstf, nt2, nt3, ntet, nti, ntt
 !FBB integer*8 i, icntr, icnt, icntr, ifermi, intel,
      integer*8 i, icntr, icnt,        ifermi, intel, &
          irec, irep, irpt, irpt2, isd0, itkmgd, itkmtot, lim, &
          limc, limcc, ncaa, ncas, nfis, niren
! LMK 06/2012
      integer*8 izr8
      integer*4 ipisa
! LMK 07/2012
      integer*4 ihist
      integer*4 npreqtyp

      real*8 molnix
      real*4 dtime, utime(2)
      logical first, fisonly

      character*24 datstr
      character*72 heading
      character*30 fgam, finf, fres, finp
      character*4 parname(8), pname

! ======================================================================

      dimension a(10), pnucl(3), amnucl(3)

      common /adbf/    amf, r0m, ijsp, nhump
      common /ajsbar/  ainit, zinit, eb(30,70,100), egs(30,70,100)
      common /begin/   cm0, t0gev, me0, mb0, ms0, l0
      common /blok77/  spt(5,150)
      common /bl1003/  ut, at, zt
      common /bl1004/  u0, a0, z0
      common /counter/ icntr, icnt
      common /d2sdto/  tet1(10), tet2(10), te1(200), te2(200), dtt(200), &
                 se(200), dtdo(200,10), d2spec(9,10,200), &
                 d2spe(14,10,200), ntt, ntet, nt2, nt3, nti(4)
      common /dele/    sfu, wf, fusion, sigfw
      common /deltt/   dteta
      common /exiton/  nexip, nexin, nhol
      common /fiscem/  fision, sigfis, nfis
      common /fitaf/   fitaf, fitaf1
      common /gamfil/  fgam
!     KKG  06/21/04:
      common /gbmul/   gbm(4)
      common /gbrems/  tgmin, tgmax, teqv, sxabs, ibrems 
      common /head1/   nh
      common /head2/   heading(10), datstr
      common /kktot/   ktot
      common /menu/    mspec, mpyld, mchy, misy, mdubl, mang
      common /menu1/   ipar1, ipar2, ifam, idel, fisonly
      common /nevtyp/  nevtype
! LMK 07/2012
      common /npreqtyp/ npreqtyp
!
      common /o/       anucl, znucl, eps, vpi, rsm(10), rbig(10), &
                 rhop(10), rhon(10), af(10), tfp(10), tfn(10), n
      common /pairc/   cevap, cfis
      common /pi/      pi, twpi
      common /proda/   prod(7,20)
      common /repcnt/  irpt, irep, irec, niren, irpt2
      common /targ0/   atar0, ztar0, ener0
      common /tkmcnt/  itkmgd, itkmtot, ifermi

      common /tou/     tmin(4), tmax(4), dt(4), rm, dt0, t0max, limc, &
                 lim
      common /vul/     sigom, ncas, intel, limcc 
      common /zapp/    parz(6,150)
! LMK 06/2012
      common /ipisa/ ipisa
! LMK 07/2012
      common /ihist/ ihist
!
! LMK 03/2015, needed for gamma_beta_init
      common /bl1005/ aj(66)
      common /bl1006/ zj(66)
!

      data a          /0.95d0, 0.8d0, 0.5d0, 0.2d0, 0.1d0, 0.05d0, &
                 0.01d0, 3*0.d0/
      data iclose     /0/
      data zro, hlf, one, two, fiv /0.d0, 0.5d0, 1.d0, 2.d0, 5.d0/
      data first /.true./
      data parname /'prot','neut','pipl','pimi','pize','gamm','gamb', &
              'stop'/ 
      data icase, isd0 /0, 0/

! ======================================================================
      fgam = 'gamman.tbl'
      ! write(*,*) 'Enter the input name...'
      ! read(*,*) finp
      finp = 'cem03.inp'
      write(*,*) 'Reading input file ''', finp, '''.'
      open (15, file=finp, status='old')
      read (15, 1200) finf
      read (15, 1200) fres
      open (16, file=finf, status='unknown')
      open (31, file=fres, status='unknown')
      write (16, 1200) finf
      write (16, 1200) fres
      open (10, file ='mass.tbl', status='old')
      open (11, file ='shell.tbl', status='old')
      open (13, file ='level.tbl', status='old')

   10 continue
      read (15, *) pname
      if (pname == parname(8)) then
        if (iclose.ne.1) then
          xxdum = dtime (utime)
          thour = dble(int (utime(1)/3600.d0))
          utim2 = (dble(utime(1)) - 3600.d0*thour)
          ttmin = dble(int (utim2/60.d0))
          utim3 = (utim2 - 60.d0*ttmin)
          tsec = utim3
          if (thour > zro) write (31, 1000) thour, ttmin, tsec
          if (thour == zro) write (31, 1100) ttmin, tsec
          close (31)
          iclose = 1
        endif
        close (16)
        stop
      endif
      read (15, 1200) heading(1)
      read (15, 1200) heading(2)
      read (15, *) t0mev
      t0gev = t0mev/1000.d0
      t000 = t0gev
      read (15, *) anucl
      read (15, *) znucl
      read (15, *) limc
      read (15, *) dt0
      read (15, *) t0max
      read (15, *) dteta
      read (15, *) mspec
      read (15, *) mpyld
      read (15, *) mchy
      read (15, *) misy
      read (15, *) mdubl
      read (15, *) mang
      read (15, *) ipar1, ipar2
      read (15, *) (tet1(j), tet2(j), j = 1,10)
      read (15, *) (tmin(j), tmax(j), dt(j), j = 1,4)
      read (15, *) nevtype
! LMK 07/2012
      read (15, *) npreqtyp
! LMK 6/2012
      read (15, *) ipisa
      if(ipisa.ne.0)  call PisaInit()
! LMK 07/2012
      read (15, *) ihist
      if (ihist/=0) call hist_Init()
!
      read (15, *) ityp
! LMK 07/2014
      call radius_rms()
!
!  Read in up to ten lines of text to write at the top of
!  'fres' and 'finf'  and on the terminal as comments on the run.

      read (15, *) nh
      if (nh > 0) then
        write ( *, 1900)
        read (15, 1200) (heading(ih), ih=1,nh)
          do ih = 1,nh
          write ( *, 1200) heading(ih)
          end do 
        write ( *, 1900)
      endif
 
      ibrems = 0
      if (pname == parname(1))     then 
        me0 = 1
        mb0 = 1
        cm0 = 0.9382723d0
      elseif (pname == parname(2)) then 
        me0 = 0
        mb0 = 1
        cm0 = 0.9395656d0
      elseif (pname == parname(3)) then 
        me0 = 1
        mb0 = 0
        cm0 = 0.139568d0
      elseif (pname == parname(4)) then 
        me0 =-1
        mb0 = 0
        cm0 = 0.139568d0
      elseif (pname == parname(5)) then 
        me0 = 0
        mb0 = 0
        cm0 = 0.134973d0
      elseif (pname == parname(6)) then 
!  Monoenergetic photon:
        me0 = 0
        mb0 = 0
        cm0 = zro
      elseif (pname == parname(7)) then 
!  Bremsstrahlung spectrum f(E)dE=const*dE/E, tgmin < E < tgmax;
!  tgmin = t0mev/1000. from input;  tgmax = t0max/1000. from input 
        me0 = 0                        
        mb0 = 0                         
        cm0 = zro
        tgmin = t0gev                   
        tgmax = t0max/1000.d0           
        ibrems = 1
        teqv = zro
        sxabs = zro
      else
        write (31,*) ' Wrong name of incident particle !', pname
      endif
!  Initialize various constants and arrays:
      call initial
      icase = icase + 1
      cevap = 12.d0
      r0m = 1.2d0
      lim = 10*limc
      if (cm0 == zro) lim = 600*limc
      ifam = 12
      n = 7
      bn = 0.545d0
      r0n = 1.07d0
      rmax = 10.0d0
      if (first) then
        call inigem                   
        call gitab                  
        if (ityp < 1 .or. ityp > 7) ityp = 1
        call raninit (ityp, isd0)
        first = .false.
      endif
   20 continue
!  Make call to INIGAM in TYPINT so correct energy is used.
!  and it is only called when a single pion is produced!
!  AJS  (03/24/05)
!    if (l0.ne.0 .and. ibrems == 0) call inigam (fgam, t0gev)
      if (t000.ne.t0gev) call initial
      atar0 = anucl
      ztar0 = znucl
      ener0 = t0gev
! LMK 03/2015, set up F_j for gamma_beta
      call gamma_beta_init(npreqtyp, t0mev, anucl, aj, zj, pname)
!  Set up neutron and proton densities and Coulomb potential
!  in the n zones of the nucleus:
      call help (a, r0n, rmax, bn)
      obr = af(n)/two
!  Geometrical cross section using radius at which density is
!  0.01 x central density:
      sigom = twpi*fiv*rsm(n)**2
      t0mev = t0gev*1000.d0
      if (t0mev > t0max) go to 10
      iclose = 0
      ncaa = 0

!   Determine semiempirical af/an fits for fission cross sections:
!  Corrected by NVMokhov, 10/08/03:
      if (ibrems.ne.1) then
        if (ztar0 > 88.d0) then 
          call fitafac (fitaf, fitaf1)
!        write (31, 2100) fitaf
        elseif (ztar0 <= 88.d0 .and. ztar0 >= 67.d0) then
          call fitafpa (fitaf, fitaf1)
!        write (31, 2100) fitaf
!        write ( *, 2100) fitaf
!2100 format (/' The af/an ratio to GEM2 default is ',f8.6,' .')
        else
          fitaf = one
          fitaf1 = one
        endif   
      endif   
!   fitaf = a_f(CEM)/a_f(RAL)
!   fitaf1 = C(Z)[CEM]/C(Z)[RAL]
!
!   Fill eb and egs arrays:   (AJS  02/14/05)
!
      ainit = anucl + mb0
      zinit = znucl + me0
        do iz1 = 1,30
        z = zinit - dble(iz1 - 1)
        if (z > hlf) then
          do ia1 = 1,70
          aa = ainit - dble(ia1 - 1)
          if (aa > hlf) then
            do ln1 = 1,100
            ln = ln1 - 1
            call barfit (aa, z, ln, bf0, egs0)
            daz = shell (aa, z)
            bf = bf0 - daz
            bf = max(bf, zro)
            eb(iz1, ia1, ln1) = bf
            egs(iz1, ia1, ln1) = egs0
            end do
          endif
          end do
        endif
        end do
!
!  Beginning main event loop:
        do i = 1,lim
        icntr = i
        if (ncaa >= limc) go to 100
   30     do m1 = 1,150
            do m = 1,5
            parz(m,m1) = zro
            spt(m,m1) = zro
            end do
          parz(6,m1) = zro
          end do
        if (l0.ne.0 .and. ibrems == 1) then
!   Sampling the energy of gamma from Schiff's spectra (1/E) and
!     preparing g + N --> pi + N angular distributions:
!   [The latter moved to TYPINT  02/25/05]
          rdm = rang(icnt)
	  temp = tgmin
	  if (temp < 1.0d-12 .and. temp > -1.0d-12) then
      	    temp = 1.0d-12
  	    print *, 'Divide by zero error in cem03.f90 line 928'
    	  end if
          t0gev = tgmin*(tgmax/temp)**rdm
!  Make call to INIGAM in TYPINT so correct energy is used.
!  and it is only called when a single `pion is produced!
!        call inigam (fgam, t0gev)
        endif
        call cascad (up, ap, zp, pnucl, amnucl, kstart, obr, nel)
        if (up <= zro) then
          intel = intel + 1
        else
          if (nel > 0) then
            intel = intel + 1
          else
!  Rerun cascade if an unphysical nucleus was produced:
            if (ap < 4.d0 .or. zp < one .or. ap < zp) go to 30
            call renorm (up, ap, zp, pnucl, kstart, ibadren)
            if (ibadren > 0) then
!  Bad event from renormalization, re-run cascad:
              niren = niren + 1
!            call derig (ncas, intel)  ! for debug.
              go to 30
            endif
            call coalesl (kstart)
!   Maximum momentum possible in the system (approximate):
	    temp = (t0gev + two*cm0)*t0gev
	    temp2 = anucl + cm0
	    if (temp2 < 1.0d-12 .and. temp2 > -1.0d-12) then
	      temp2 = 1.0d-12
	      print *, 'Divide by zero error in cem03.f90 line 961'
	    end if
	    if (temp < 0.0d0) then
	      temp = 0.01d0
	      print *, 'Sqrt error in cem03.f90 line 961'
	    end if
            pmax = ap*sqrt(temp)/(temp2)
            pmax = pmax + hlf
            prec = sqrt(pnucl(1)**2 + pnucl(2)**2 + pnucl(3)**2)	!No error check needed because sqrt of squares
            if (prec > pmax) then
!   If recoil kinetic energy is too large, rerun cascade:
              irec = irec + 1
              go to 30
            endif
            up = up*1000.d0

! LMK 07/2012, Tally particle info after cascade
!LMK testing hist 
!		ap = 198
!		zp = 79
!		nexin = 3
!		nexip = 3
!		nhol = 4
!		pnucl(1) = 10.d0
!		pnucl(2) = 10.d0
!		pnucl(3) = 10.d0
!		amnucl(1) = 2.d0
!		amnucl(2) = 2.d0
!		amnucl(3) = 2.d0
!		up = uold + increm
!		uold = up
!		print *, up		

            if (ap >= 4.d0 .and. zp >= one .and. ap >= zp) then
              at = ap
              zt = zp
              iz = nint(zp)
              in = nint(ap - zp)
              pevap = molnix (iz, in, 3)
              call auxl (amnucl, bf0, ln, erotev, delu)
              u = up + delu
              ue = u - pevap - erotev
              call ststcs (ap, zp, ue, ln, bf0, 1)

	      if (ihist/=0) then
		call hist_Tally(pnucl, amnucl, up, ap, zp, nexin, nexip, nhol)
	      end if

              ncas = ncas + 1
              ncaa = ncaa + 1
!   KKG 06/21/04
!            if ((ncaa/1000)*1000 == ncaa) write (*, *) ' nc = ', ncaa
!             if ((ncaa/10000)*10000 == ncaa) write (*, *) ' nc = ', 
!    &                                                      ncaa
              if ((ncaa/10000)*10000 == ncaa) write (*, 2000) ncaa
              if (ap <= 12.d0) then    		!Go to Fermi break-up for A<=12
!   Fermi break-up calculation:
                upg = up/1000.d0
                a0 = ap
                z0 = zp
                u0 = upg
                nstf = 0
                ifermi = ifermi + 1
                call fermid (ap, zp, upg, pnucl, nstf)
                fusion = zro 
                wf = zro 
                if (nstf > 0) then
                  do ifr = 1,nstf
                  pxfr = prod(3,ifr)
                  pyfr = prod(4,ifr)
                  pzfr = prod(5,ifr)
                  pfr  = sqrt(pxfr**2 + pyfr**2 + pzfr**2)	!No error check needed because sqrt of squares
		  temp = pfr
		  if (temp < 1.0d-12 .and. temp > -1.0d-12) then
	      	    temp = 1.0d-12
	  	    print *, 'Divide by zero error in cem03.f90 line 1029'
	    	  end if
                  ctfr = pzfr/temp
                  stfr = sqrt(abs(one - ctfr**2))		!No error check needed because sqrt of abs
                  if (stfr > zro) then
		    temp = pfr*stfr
		    if (temp < 1.0d-12 .and. temp > -1.0d-12) then
	      	      temp = 1.0d-12
	  	      print *, 'Divide by zero error in cem03.f90 line 1037,1038'
	    	    end if
                    cffr = pxfr/(temp)
                    sffr = pyfr/(temp)
                  else
                    cffr = one
                    sffr = zro                 
                  endif 
                  fifr = atan2 (sffr, cffr)
                  if (fifr < zro) fifr = twpi + fifr
                  tefr = atan2 (stfr, ctfr)
                  kfr = kstart + ifr - 1
                  tkfr = prod(6,ifr)
                  afr  = prod(1,ifr)
                  zfr  = prod(2,ifr)                   
                  spt(1,kfr) = stfr
                  spt(2,kfr) = ctfr
                  spt(3,kfr) = tkfr/1000.d0
                  spt(4,kfr) = zfr
                  spt(5,kfr) = prod(7,ifr)/1000.d0
                  iafr = nint(afr)
                  izfr = nint(zfr)
                  jfr = 0
                  if (afr <= 4.1d0 .and. zfr <= 2.1d0) then
                    if (iafr == 1 .and. izfr == 0) jfr = 1
                    if (iafr == 1 .and. izfr == 1) jfr = 2
                    if (iafr == 2 .and. izfr == 1) jfr = 3
                    if (iafr == 3 .and. izfr == 1) jfr = 4
                    if (iafr == 3 .and. izfr == 2) jfr = 5
                    if (iafr == 4 .and. izfr == 2) jfr = 6
                  else
                    jfr = 1000*izfr + (iafr - izfr)
                  endif
                  if (jfr == 0) jfr = 1000*izfr + (iafr - izfr)
                  parz(1,kfr) = jfr
                  parz(2,kfr) = tkfr/1000.d0
                  parz(3,kfr) = tefr
                  parz(4,kfr) = fifr
                  parz(5,kfr) = 1500.d0       !Identify Fermi breakup
                  parz(6,kfr) = zfr
                  enddo
                endif 
                ktot = kfr
              else   
!   Regular decay; ap > 12:
                wam = one
                u0 = up
                a0 = ap
                z0 = zp
                pnx = pnucl(1)
                pny = pnucl(2)
                pnz = pnucl(3)
                elx = amnucl(1)
                ely = amnucl(2)
                elz = amnucl(3)
                n0 = nexip + nexin + nhol
                nh0 = nhol
                npz0 = nexip
                np0 = nexip + nexin
!   KKG  10/13/04
                if (ibrems == 1) then
                  ener0 = t0gev
!   Determine semiempirical af/an fits for fission cross sections;
!   gamma energy varies randomly, so need new value for each iteration:
!  Corrected by NVMokhov, 10/08/03:
                  if (ztar0 > 88.d0) then 
                    call fitafac (fitaf, fitaf1)
                  elseif (ztar0 <= 88.d0 .and. ztar0 >= 67.d0) then
                    call fitafpa (fitaf, fitaf1)
                  else
                    fitaf = one
                    fitaf1 = one
                  endif   
!   fitaf = a_f(CEM)/a_f(RAL)
!   fitaf1 = C(Z)[CEM]/C(Z)[RAL]
                endif 
!		call orig_dost_init(zp, ap)		! Remove when done testing XS implementation, LMK 7/2014
!		print *, 'got to cem03 before precof'
                call precof (up, ap, zp, pnx, pny, pnz, elx, ely, elz, &
                       rm, kstart, n0, np0, nh0, npz0, wam)
                if (wam == -13.d0) then
                  wam = one
                  go to 30
                endif
              endif 
!   KKG  10/13/04
              if (ibrems == 1) then
                teqv = teqv + t0gev
                t0mev = t0gev*1000.d0
                sxabs = sxabs + gabs (t0mev, anucl)
              endif                                 
            else
!   Unphysical A and Z values; rerun cascade:
              irep = irep + 1
              go to 30
            endif
            up = up/1000.d0
!          if (ncaa <= nnnp) call derig (ncas, intel)
            if (fusion > zro .and. idel > 0) nfis = nfis + 1
            sfu = sfu + wf
            call vlobd
! LMK 06/2012
          if(ipisa.ne.0)  call PisaSpectra()
! 
          endif
        endif
        end do
!  End of main event loop ^
  100 limcc = ncas + intel
      call fdate (datstr) 
      call prinp (icase)
      call typeout
      if (ihist/=0) call hist_Print(ncas)		!LMK 07/2012

!    if (irpt > 0) then
!      write (16, 1300) irpt
!      write (31, 1300) irpt
!    endif
!    if (irpt2 > 0) then
!      write (16, 1350) irpt2
!      write (31, 1350) irpt2
!    endif
!    if (irep > 0) then
!      write (16, 1400) irep
!      write (31, 1400) irep
!    endif
!    if (irec > 0) then
!      write (16, 1500) irec
!      write (31, 1500) irec
!    endif
!    if (niren > 0) then
!      write (16, 1600) niren
!      write (31, 1600) niren
!    endif
      if (ifermi > 0) then
        write (16, 1700) ifermi
        write (31, 1700) ifermi
      endif
!    write (16, 1800) itkmgd, itkmtot
!    write (31, 1800) itkmgd, itkmtot
      if (dt0 <= zro) go to 10
      t0gev = t0gev + dt0/1000.d0
      call flush (31)
      go to 20

! ======================================================================

 1000 format (/,' Elapsed cpu time  = ',f4.0,' hr, ',f3.0,' min, and ', &
          f6.3,' sec.')
 1100 format (/,' Elapsed cpu time  = ',f3.0,' min and ',f6.3,' sec.')
 1200 format (a)
!1300 format (/1x,'The program repeated a cascade after getting hung ',
!    &       'up in GEOM8 ',i6,' times.')
!1350 format (/1x,'The program repeated a cascade with a value of np = ',
!    &       i16, '.')
!1400 format (/1x,'The program repeated a cascade after returning ',
!    &       'from CASCAD'/1x,'with unphysical values of Z & A ',i6,
!    &       ' times.')
!1500 format (/1x,'The program repeated a cascade after returning ',
!    &       'from CASCAD'/1x,'with too large a recoil energy',i6,
!    &       ' times.')
!1600 format (/1x,'The program repeated a cascade after returning ',
!    &       'from RENORM'/1x,'with an error ',i6,' times.')
 1700 format (/1x,'The program called Fermi breakup ',i8,' times.')
!1800 format (/1x,'TKINM3 was called ',i8,' times, with ',i8,
!    &       ' random numbers used.')
 1900 format (1x)
 2000 format (' nc = ',i8)

! ======================================================================
      end
