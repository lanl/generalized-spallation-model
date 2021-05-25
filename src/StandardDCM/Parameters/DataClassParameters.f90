! copyright LANS/LANL/DOE - see file COPYRIGHT_INFO

module standardDCMDataParams
  !=======================================================================================
  ! Description:
  ! Various parameters used by many routines in standardDCM.
  ! ALL PARAMETERS IN THIS MODULE ARE PUBLIC.
  ! DO NOT PUT ANY FUNCTIONS OR SUBROUTINES IN THIS MODULE.
  !
  ! Organization:
  !   * Kind parameters
  !   * Numbers
  !   * General code & control
  !   * Parallel
  !   * Particle types
  !   * Xsecs
  !   * I/O Units
  !   * Physical constants
  !
  !=======================================================================================

  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  PUBLIC

  !--------------------------------------------------------- NUMBERS ---------------------
  ! Frequently used real numbers:
  real(real64), parameter ::  &
       &  zro              = 0.0_real64,                 &
       &  one              = 1.0_real64,                 &
       &  two              = 2.0_real64,                 &
       &  thr              = 3.0_real64,                 &
       &  four             = 4.0_real64,                 &
       &  five             = 5.0_real64,                 &
       &  hlf              = 0.5_real64,                 &
       &  twthrd           = two/thr,                    &
       &  pi               = 3.141592653589793d0,        &
                     != pi.  3.14159265358979324_real64,
       &  twpi             = two  * pi,                  &
       &  fourpi           = four * pi,                  &
       &  esq              = 0.001439976_real64
  !---------------------------------------------------------------------------------------



  !--------------------------------------------------------- MISC. NUMBERS ----------
  ! Gaussian quadrature weights and associated abscissa's
  integer(int32), parameter :: numQuads = 8_int32
  real(real64), parameter, dimension(numQuads) :: gaussWgt =  &
       & [  0.101228536290376d0,  0.222381034453374d0, &
       &    0.313706645877887d0,  0.362683783378362d0, &
       &    0.362683783378362d0,  0.313706645877887d0, &
       &    0.222381034453374d0,  0.101228536290376d0  ]

  real(real64), parameter, dimension(numQuads) :: gaussAbsc = &
       & [ -0.960289856497536d0, -0.796666477413627d0, &
       &   -0.525532409916329d0, -0.183434642495650d0, &
       &    0.183434642495650d0,  0.525532409916329d0, &
       &    0.796666477413627d0,  0.960289856497536d0  ]
  !---------------------------------------------------------------------------------------



  !-------------------------------------------------------------------  A**(1/3)  --------
  integer(int32), parameter :: largest_atomic_weight = 300_int32
  real(real64), parameter :: ato3rd(1:largest_atomic_weight) = [  &
       & 1.00000000000000, 1.25992104989487, 1.44224957030741, 1.58740105196820, 1.70997594667670,&
       & 1.81712059283214, 1.91293118277239, 2.00000000000000, 2.08008382305190, 2.15443469003188,&
       & 2.22398009056932, 2.28942848510666, 2.35133468772076, 2.41014226417523, 2.46621207433047,&
       & 2.51984209978975, 2.57128159065824, 2.62074139420890, 2.66840164872194, 2.71441761659491,&
       & 2.75892417638112, 2.80203933065539, 2.84386697985157, 2.88449914061482, 2.92401773821287,&
       & 2.96249606840737, 3.00000000000000, 3.03658897187566, 3.07231682568585, 3.10723250595386,&
       & 3.14138065239139, 3.17480210393640, 3.20753432999583, 3.23961180127748, 3.27106631018859,&
       & 3.30192724889463, 3.33222185164595, 3.36197540679896, 3.39121144301417, 3.41995189335339,&
       & 3.44821724038273, 3.47602664488645, 3.50339806038672, 3.53034833532606, 3.55689330449006,&
       & 3.58304787101595, 3.60882608013869, 3.63424118566428, 3.65930571002297, 3.68403149864039,& ! < 50
       & 3.70842976926619, 3.73251115681725, 3.75628575422107, 3.77976314968462, 3.80295246076139,&
       & 3.82586236554478, 3.84850113127681, 3.87087664062780, 3.89299641587326, 3.91486764116886,&
       & 3.93649718310217, 3.95789160968041, 3.97905720789639, 4.00000000000000, 4.02072575858906,&
       & 4.04124002062219, 4.06154810044568, 4.08165510191735, 4.10156592970235, 4.12128529980856,&
       & 4.14081774942285, 4.16016764610381, 4.17933919638123, 4.19833645380841, 4.21716332650875,&
       & 4.23582358425489, 4.25432086511501, 4.27265868169792, 4.29084042702621, 4.30886938006377,&
       & 4.32674871092223, 4.34448148576861, 4.36207067145484, 4.37951913988789, 4.39682967215818,&
       & 4.41400496244210, 4.43104762169363, 4.44796018113863, 4.46474509558454, 4.48140474655716,&
       & 4.49794144527541, 4.51435743547400, 4.53065489608349, 4.54683594377634, 4.56290263538697,&
       & 4.57885697021333, 4.59470089220704, 4.61043629205845, 4.62606500918274, 4.64158883361278,& ! <100
       & 4.65700950780384, 4.67232872835526, 4.68754814765360, 4.70266937544152, 4.71769398031653,&
       & 4.73262349116337, 4.74745939852340, 4.76220315590460, 4.77685618103502, 4.79141985706278,&
       & 4.80589553370533, 4.82028452835046, 4.83458812711164, 4.84880758583988, 4.86294413109428,&
       & 4.87699896107331, 4.89097324650875, 4.90486813152402, 4.91868473445873, 4.93242414866094,&
       & 4.94608744324870, 4.95967566384230, 4.97318983326859, 4.98663095223865, 5.00000000000000,&
       & 5.01329793496458, 5.02652569531348, 5.03968419957949, 5.05277434720856, 5.06579701910089,&
       & 5.07875307813270, 5.09164336965949, 5.10446872200146, 5.11722994691205, 5.12992784003009,&
       & 5.14256318131647, 5.15513673547577, 5.16764925236362, 5.18010146738029, 5.19249410185110,&
       & 5.20482786339420, 5.21710344627617, 5.22932153175598, 5.24148278841779, 5.25358787249290,&
       & 5.26563742817144, 5.27763208790408, 5.28957247269421, 5.30145919238090, 5.31329284591306,& ! <150
       & 5.32507402161499, 5.33680329744389, 5.34848124123936, 5.36010841096536, 5.37168535494483,&
       & 5.38321261208728, 5.39469071210959, 5.40612017575022, 5.41750151497718, 5.42883523318981,&
       & 5.44012182541480, 5.45136177849642, 5.46255557128140, 5.47370367479843, 5.48480655243262,&
       & 5.49586466009501, 5.50687844638735, 5.51784835276224, 5.52877481367887, 5.53965825675446,&
       & 5.55049910291155, 5.56129776652124, 5.57205465554262, 5.58277017165842, 5.59344471040698,&
       & 5.60407866131077, 5.61467240800149, 5.62522632834186, 5.63574079454424, 5.64621617328617,&
       & 5.65665282582291, 5.66705110809706, 5.67741137084543, 5.68773395970313, 5.69801921530506,&
       & 5.70826747338486, 5.71847906487132, 5.72865431598244, 5.73879354831717, 5.74889707894483,&
       & 5.75896522049240, 5.76899828122963, 5.77899656515213, 5.78896037206240, 5.79888999764900,&
       & 5.80878573356370, 5.81864786749696, 5.82847668325146, 5.83827246081400, 5.84803547642573,& ! <200
       & 5.85776600265065, 5.86746430844262, 5.87713065921074, 5.88676531688334, 5.89636853997037,&
       & 5.90594058362449, 5.91548169970072, 5.92499213681474, 5.93447214039994, 5.94392195276313,&
       & 5.95334181313905, 5.96273195774369, 5.97209261982640, 5.98142402972089, 5.99072641489509,&
       & 6.00000000000000, 6.00924500691737, 6.01846165480645, 6.02765016014974, 6.03681073679769,&
       & 6.04594359601251, 6.05504894651110, 6.06412699450696, 6.07317794375133, 6.08220199557340,&
       & 6.09119934891979, 6.10017020039306, 6.10911474428961, 6.11803317263662, 6.12692567522842,&
       & 6.13579243966196, 6.14463365137169, 6.15344949366368, 6.16224014774904, 6.17100579277672,&
       & 6.17974660586564, 6.18846276213620, 6.19715443474113, 6.20582179489575, 6.21446501190772,&
       & 6.22308425320606, 6.23167968436975, 6.24025146915571, 6.24879976952624, 6.25732474567597,&
       & 6.26582655605827, 6.27430535741117, 6.28276130478279, 6.29119455155629, 6.29960524947437,& ! <250
       & 6.30799354866327, 6.31635959765638, 6.32470354341737, 6.33302553136292, 6.34132570538500,&
       & 6.34960420787280, 6.35786117973420, 6.36609676041689, 6.37431108792909, 6.38250429885991,&
       & 6.39067652839931, 6.39882791035777, 6.40695857718556, 6.41506865999165, 6.42315828856237,&
       & 6.43122759137962, 6.43927669563891, 6.44730572726691, 6.45531481093889, 6.46330407009565,&
       & 6.47127362696036, 6.47922360255497, 6.48715411671635, 6.49506528811226, 6.50295723425693,&
       & 6.51083007152643, 6.51868391517377, 6.52651887934375, 6.53433507708757, 6.54213262037719,&
       & 6.54991162011937, 6.55767218616971, 6.56541442734614, 6.57313845144243, 6.58084436524139,&
       & 6.58853227452786, 6.59620228410148, 6.60385449778925, 6.61148901845794, 6.61910594802623,&
       & 6.62670538747667, 6.63428743686750, 6.64185219534421, 6.64939976115098, 6.65693023164187,&
       & 6.66444370329191, 6.67194027170795, 6.67942003163937, 6.68688307698865, 6.69432950082169 & ! <300
       &    ]
  !---------------------------------------------------------------------------------------


end module standardDCMDataParams

