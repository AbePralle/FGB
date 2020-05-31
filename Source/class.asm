;1.2.2000 by Abe Pralle
;functions that compose the 'classes' of FGB.
;Each class begins a vector table of jump instructions.

;Each method call takes the following inputs:
;  c  - class index
;  de - pointer to object

;The various methods behave as follows:
;  redraw - Draws itself and its tile attributes into the shadowbuffers
;  update - performs any required AI
;           adjusts its own position within the map

INCLUDE "Source/defs.inc"
INCLUDE "Source/start.inc"
INCLUDE "Source/items.inc"


GRENADE_CINDEX          EQU 2048+ 12
WALLCREATURE_CINDEX     EQU 2048+ 19
BEE_CINDEX              EQU 2048+ 22
RECIPROCATOR_POWERUP_CINDEX   EQU 2048+ 35
TRI_CINDEX              EQU 2048+ 37
TRILING_CINDEX          EQU 2048+ 39
BAT_CINDEX              EQU 2048+ 45
BURROWER_CINDEX         EQU 2048+ 47
BURROWER_DIRT_CINDEX    EQU 2048+ 49
DANDELION_CINDEX        EQU 2048+ 51
DANDELIONPUFF_CINDEX    EQU 2048+ 52
SHEEP_CINDEX            EQU 2048+ 96
CHICKEN_CINDEX          EQU 2048+ 98
WOLF_CINDEX             EQU 2048+104
NEANDERTHAL_CINDEX      EQU 2048+108
BOW_CINDEX              EQU 2048+146
CROUTONBULLET_CINDEX    EQU 2048+154
WIZARDBULLET_CINDEX     EQU 2048+158
ARROWBULLET_CINDEX      EQU 2048+162
CROUTONROCKET_CINDEX    EQU 2048+164
COWBOYBULLET_CINDEX     EQU 2048+166
BIGSPIDER_CINDEX        EQU 2048+210
LITTLESPIDER_CINDEX     EQU 2048+218
TCUBE_CINDEX            EQU 2048+220
TCUBE2_CINDEX           EQU 2048+224
B12SOLDIERBULLET_CINDEX EQU 2048+246
TREEBULLET_CINDEX       EQU 2048+253
STUNNEDWALL_CINDEX      EQU 2048+256
INVISIBLEBAT_CINDEX     EQU 2048+258
SLIME_CINDEX            EQU 2048+260
MONKEY_CINDEX           EQU 2048+267
BANANABULLET_CINDEX     EQU 2048+269
DUKE_CINDEX             EQU 2048+271
PIG_CINDEX              EQU 2048+281
EGG_CINDEX              EQU 2048+283
BLOWER_CINDEX           EQU 2048+284
SLEEPINGMONKEY_CINDEX   EQU 2048+286
BELL_CINDEX             EQU 2048+287
RINGINGBELL_CINDEX      EQU 2048+291
BANANATREE_CINDEX       EQU 2048+295
HERMITINSHELL_CINDEX    EQU 2048+301
CRAB_CINDEX             EQU 2048+311
CRABBURROWING_CINDEX    EQU 2048+313
UBERMOUSE_CINDEX        EQU 2048+314
TURRET_CINDEX           EQU 2048+322
TURRETBULLET_CINDEX     EQU 2048+334
FAKEBA_CINDEX           EQU 2048+336
FAKEBS_CINDEX           EQU 2048+338
FAKEHAIKU_CINDEX        EQU 2048+340
HEROLADY_CINDEX         EQU 2048+350
HEROFLOUR_CINDEX        EQU 2048+352
FLOUR_BULLET_CINDEX     EQU 2048+406
LADY_BULLET_CINDEX      EQU 2048+408

BA_MAX_HEALTH EQU 20
BS_MAX_HEALTH EQU 10
HAIKU_MAX_HEALTH EQU 20
FLOUR_MAX_HEALTH EQU 40
LADY_MAX_HEALTH EQU 40
GRENADE_MAX_HEALTH EQU 30

SECTION "ClassTableSection",ROMX
classTable::    ;starts with ptr to FIRSTOBJTILE
  ;BG classes
  REPT 27          ;0-26
  DW classGenericBG
  ENDR

  DW classAppomattoxBG  ;27

  REPT 78       ;28-105
  DW classGenericBG
  ENDR

  DW classShiftPlusOneBG  ;106 destructable pumpkin
  DW classShiftPlusOneBG  ;107 destructable pumpkin
  DW classShiftPlusOneBG  ;108 destructable pumpkin
  DW classDestructableBG  ;109 destructable pumpkin

  DW classGenericBG       ;110 blue thingy

  REPT 9         ;111-119 purple destructable
  DW classChangeTo120BG
  ENDR

  DW classShiftPlusOneBG  ;120 purple destroy stage 1
  DW classShiftPlusOneBG  ;121 purple destroy stage 2
  DW classDestructableBG  ;122 purple destroy stage 3
  DW classSplitterBG      ;123 four-way shot splitter

  REPT 133       ;124-256
  DW classGenericBG
  ENDR

  REPT 46        ;257-302
  DW classHiveBG
  ENDR

  REPT 588       ;303-890
  DW classGenericBG
  ENDR

  DW classNoExplosionBG    ;891 grey door

  REPT 181      ;892-1072
  DW classGenericBG
  ENDR

  DW classLandingLightsBG   ;1073

  REPT 328      ;1074-1401
  DW classGenericBG
  ENDR

  DW classChangeToBigSpiderBG       ;TL corner big spider weed
  DW classAdjoinWestBG              ;big spider weed
  DW classAdjoinNorthBG             ;big spider weed
  DW classAdjoinNorthBG             ;big spider weed
  DW classChangeToLittleSpiderBG    ;small spider weed

  REPT 57        ;1407-1463
  DW classGenericBG
  ENDR

  ;1464-1475 destructable shrooms
  REPT 12
  DW classDestructableBG
  ENDR

  DW classNoExplosionBG    ;wall tile

  ;1477-1493
  REPT 17
  DW classGenericBG
  ENDR

  ;1494-1511 Destructable foliage
  REPT 18
  DW classDestructableBG
  ENDR

  DW classEdibleCheeseBG   ;1512 edible cheese
  DW classCheeseBG         ;1513 cheese
  DW classCheeseBG         ;1514 cheese
  DW classCheeseBG         ;1515 cheese
  DW classCheeseBG         ;1516 cheese
  DW classCheeseBG         ;1517 cheese
  DW classCheeseBG         ;1518 cheese
  DW classCheeseBG         ;1519 cheese
  DW classCheeseBG         ;1520 cheese
  DW classCheeseBG         ;1521 cheese
  DW classCheeseBG         ;1522 cheese
  DW classCheeseBG         ;1523 cheese
  DW classCheeseBG         ;1524 cheese
  DW classCheeseBG         ;1525 cheese
  DW classCheeseBG         ;1526 cheese
  DW classCheeseBG         ;1527 cheese
  DW classCheeseBG         ;1528 cheese
  DW classCheeseBG         ;1529 cheese
  DW classCheeseBG         ;1530 cheese
  DW classCheeseBG         ;1531 cheese
  DW classCheeseBG         ;1532 cheese
  DW classInvisibleWallBG  ;1533 Invisible Wall

  DW classPorkBG           ;1534 Bacon
  DW classPorkBG           ;1535 Ham
  DW classPorkBG           ;1536 Sausage
  DW classFriedEggBG       ;1537 Fried Egg
  DW classDrumstickBG      ;1538 Drumstick

  ;1539-1571
  REPT 33
  DW classGenericBG
  ENDR

  DW classHermitCrabShellBG  ;1572 Hermit Crab Shell
  DW classBananaBG         ;1573 Banana

  ;1574-1642
  REPT 69
  DW classGenericBG
  ENDR

  DW classGeneratorBG  ;1643
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG
  DW classGeneratorBG  ;1651

  DW classSlugTrailBG   ;1652 slug trail

  ;1653-1854
  REPT 202
  DW classGenericBG
  ENDR

  ;1855-1874
  DW classDestructableBG
  DW classDestructableBG
  DW classDestructableBG
  DW classDestructableBG
  DW classDestructableAdjoinRightBG
  DW classDestructableAdjoinLeftBG
  DW classDestructableAdjoinRightBG
  DW classDestructableAdjoinLeftBG
  DW classDestructableAdjoinRightBG
  DW classDestructableAdjoinLeftBG
  DW classDestructableAdjoinRightBG
  DW classDestructableAdjoinLeftBG
  DW classDestructableAdjoinBottomBG
  DW classDestructableAdjoinTopBG
  DW classDestructableAdjoinBottomBG
  DW classDestructableAdjoinTopBG
  DW classDestructableAdjoinBottomBG
  DW classDestructableAdjoinTopBG
  DW classDestructableAdjoinBottomBG
  DW classDestructableAdjoinTopBG

  ;1875-2042
  REPT 168
  DW classGenericBG
  ENDR

  DW classClearanceBG

  ;2044-2047
  REPT 4
  DW classGenericBG
  ENDR

  ;FG classes

  ;pansies o+0, +2, +4
  REPT 3
  DW classPansy,0
  ENDR

  DW classBAPlayer,0        ;BA +6
  DW classBSPlayer,0        ;BS +8

  DW classHaikuPlayer, 0    ;+10 Haiku

  DW classGrenade, 0        ;+12 Grenade
  DW classGeneric           ;+14 old Stunned Wall Creature (unused)
  DW classVacuum, 0         ;+15 vacuum
  DW classSlug, 0           ;+17 Slug
  DW classWallCreature, 0   ;+19 Wall Creature
  DW classSmallBeeHive      ;+21 small bee hive

  DW classBee, 0            ;+22 bee

  DW classGeneric               ;+24  yinyang
  DW classGeneric, 0            ;+25  yin
  DW classGeneric, 0            ;+27  yang
  DW classScaredie, 0           ;+29  scaredie
  DW classChomper, 0            ;+31  big mouth (chomper)
  DW classReciprocator, 0       ;+33  purple energy dude lo power
  DW classReciprocatorPowerup,0 ;+35  purple dude hi power
  DW classTri, 0                ;+37  yellow thing
  DW classTriling, 0            ;+39  small yellow thing
  DW classTree                  ;+41  tree
  DW classBush                  ;+42  bush
  DW classNeedle,0              ;+43  needle thing
  DW classBat, 0                ;+45  bat
  DW classBurrower,0            ;+47  burrower
  DW classBurrowerDirt,0        ;+49  burrower dirt mound
  DW classDandelion             ;+51  dandelion
  DW classDandelionPuff,0       ;+52  dandelion puff
  DW classGeneric,0,0,0,0,0,0,0 ;+54  King Grenade
  DW classMouse, 0              ;+62  mouse
  DW classPenguin, 0            ;+64  penguin
  DW classBIOS,0                ;+66  BIOS soldier
  DW classGeneric,0,0,0         ;+68  king snake
  DW classCroutonHulk,0,0,0,0,0,0,0 ;+72  crouton hulk
  DW classCroutonGrunt, 0       ;+80  crouton grunt

  ;BA Bullet +82
  DW classBABullet, 0

  ;Pansy Bullet +84
  DW classPansyBullet, 0

  ;Big Long Laser +86
  DW classBigLongLaser, 0

  DW classLadyFlower, 0         ;Lady Flower    +88
;DW classBSPlayer,0        ;BS +8
  DW classCaptainFlour, 0       ;Captain Flour  +90
  DW classBigBeeHive, 0, 0, 0   ;+92   big bee hive
  DW classSheep, 0              ;+96   sheep
  DW classChicken, 0            ;+98   chicken
  DW classPurpleWisp, 0         ;+100  wisp
  DW classQuatrain,0            ;+102  quatrain
  DW classWolf, 0               ;+104  ice wolf
  DW classSnake, 0              ;+106  snake
  DW classNeanderthal, 0        ;+108  neanderthal
  DW classGeneric,0,0,0,0,0,0,0 ;+110  genie
  DW classCrow,0                ;+118  crow
  DW classScarecrow,0,0,0,0,0,0,0 ;+120  scarecrow
  DW classTalker, 0             ;+128  hermit
  DW classTalker, 0             ;+130  grey hermit
  DW classGeneric, 0             ;+132  red villager
  DW classGeneric, 0             ;+134  blue villager
  DW classAlligator,0,0,0,0,0,0,0 ;+136  alligator
  DW classScorpion, 0           ;+144  scorpion
  DW classBow,0                 ;+146  archer
  DW classCowboy, 0             ;+148  blue villager
  DW classCowboy, 0             ;+150  brown villager
  DW classCroutonDoctor, 0      ;+152  doctor crouton / guard
  DW classCroutonBullet, 0      ;+154  crouton bullet
  DW classCroutonWizard, 0      ;+156  wizard crouton
  DW classWizardBullet, 0       ;+158  spiral wizard bullet
  DW classGeneric, 0            ;+160  mud?
  DW classArrowBullet, 0        ;+162  arrow bullet
  DW classRocketBullet, 0       ;+164  rocket bullet
  DW classCowboyBullet, 0       ;+166  yellow bolt bullet
  DW classGeneric, 0            ;+168  purple sparkley bullet
  DW classBSBullet, 0           ;+170  bs bullet
  DW classCroutonGoblin, 0      ;+172  goblin crouton
  DW classGeneralGyro,0,0,0,0,0,0,0 ;+174  General Gyro
  DW classCroutonArtillery,0,0,0,0,0,0,0 ;+182  artillery tank crouton
  DW classGeneric,0,0,0,0,0,0,0 ;+190  stabbing tank crouton
  DW classMajorSkippy,0,0,0,0,0,0,0 ;+198  Major Skippy
  DW classBAPlayer,0            ;+206  RA
  DW classBSPlayer,0            ;+208  CS
  DW classBigSpider,0,0,0,0,0,0,0 ;+210  Big Spider
  DW classLittleSpider,0        ;+218  Little Spider
  DW classTeleportCube,0,0,0    ;+220  Teleport Field
  DW classTeleportCube2,0,0,0   ;+224  Teleport Field
  DW classDandelionGuard,0      ;+228  Dandelion guard
  DW classB12Soldier,0          ;+230  Purple Soldier
  DW classB12Soldier,0          ;+232  Grey Soldier
  DW classB12Soldier,0          ;+234  Yellow Soldier
  DW classGeneric,0             ;+236  Orange Specialist
  DW classGeneric,0             ;+238  Grey Specialist
  DW classGeneric,0             ;+240  Green Specialist
  DW classActor,0               ;+242  Red Ninja (Iambic)
  DW classHaikuPlayer,0         ;+244  Purple Ninja (Free Verse)
  DW classB12SoldierBullet,0    ;+246  B12 Soldier Bullet
  DW classGeneric               ;+248  bomb thing
  DW classGeneric,0,0,0         ;+249  BRAINIAC
  DW classTreeBullet,0          ;+253  Tree and bush bullet
  DW 0                          ;+255  pad
  DW classStunnedWall,0         ;+256  Stunned wall creature
  DW classInvisibleBat,0        ;+258  Invisible Bat
  DW classSlime,0               ;+260  Small slime

  DW classYellowWisp,0          ;+262  Yellow wisp
  DW classGeneric               ;+264  Immobile armor
  DW classGeneric,0             ;+265  Suit of armor
  DW classMonkey,0              ;+267  Brown Monkey
  DW classBananaBullet,0        ;+269  Bananna bullet
  DW classDuke,0,0,0,0,0,0,0    ;+271  Duke the one-armed orangutan
  DW classGeneric,0             ;+279  leprechaun
  DW classPig,0                 ;+281  pig
  DW classEgg                   ;+283  egg
  DW classBlower,0              ;+284  Crouton Blower
  DW classSleepingMonkey        ;+286  Sleeping Monkey
  DW classBell,0,0,0            ;+287  Bell
  DW classRingingBell,0,0,0     ;+291  Ringing Bell
  DW classBananaTree,0,0,0      ;+295  Banana Tree
  DW classHermitNoShell,0       ;+299  Hermit Crab, no shell
  DW classHermitInShell,0       ;+301  Hermit Crab inside shell
  DW classSwampThang,0,0,0,0,0,0,0  ;+303  Swamp Thang
  DW classCrab,0                    ;+311  Red Crab
  DW classCrabBurrowing             ;+313  Red Crab Burrowing
  DW classUberMouse,0,0,0,0,0,0,0   ;+314  Uber Mouse
  DW classTurret,0,0,0              ;+322  Turret
  DW classCroutonKing,0,0,0,0,0,0,0 ;+326  Turret Bullet
  DW classTurretBullet,0            ;+334  Turret Bullet
  DW classActor,0                   ;+336  Fake BA
  DW classActor,0                   ;+338  Fake BS
  DW classActor,0                   ;+340  Fake Haiku
  DW classGrenadePlayer,0,0,0,0,0,0,0    ;+342  Fake King Grenade
  DW classHeroLady,0                ;+350  Hero Lady Flower
  DW classHeroFlour,0               ;+352  Hero Captain Flour
  DW classGeneric,0                 ;+354  Disco Dancer
  DW classActor,0,0,0               ;+356  Lying Head single 2x2 frame
  DW classActor2x2,0,0,0,0,0,0,0    ;+360  Thaddius Pencilbody
  DW classActor,0                   ;+368  Blue Skull
  DW classActor2x2,0,0,0,0,0,0,0    ;+370  Santa
  DW classActor2x2,0,0,0,0,0,0,0    ;+378  Queen Bee
  DW classActor2x2,0,0,0,0,0,0,0    ;+386  Rocking Horse
  DW classActor,0                   ;+394  Candy Cane
  DW classActor,0                   ;+396  Doll
  DW classActor2x2,0,0,0,0,0,0,0    ;+398  Reindeer
  DW classFlourBullet,0             ;+406  Captain Flour Bullet
  DW classLadyBullet,0              ;+408  Hero Lady Flower Bullet
  ;DW classLadyBullet,0              ;+410  Hero Lady Flower Bullet
  ;DW classLadyBullet,0              ;+412  Hero Lady Flower Bullet
  ;DW classLadyBullet,0              ;+414  Hero Lady Flower Bullet

classDoNothing::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DoNothingCheck       ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDoNothing2::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DoNothingCheck       ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDoNothing3::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DoNothingCheck       ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHeroIdle::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  IdleCantDieCheck     ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classGeneric::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GenericCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTalker::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TalkerCheck          ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classActor::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classActor2::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classGuard::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GuardCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classActorSpeed1::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorSpeed1Check     ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classActor2x2::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classPansy::
        DW  PansyInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  PansyCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHippiePansy::
        DW  PansyInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  HippiePansyCheck     ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classPansyBullet::
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  StdBulletCheck       ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBAPlayer::
        DW  BAInit
        DW  StandardRedraw
        DW  BAPlayerCheck
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBAPlayerSpace::
        DW  BAInit
        DW  StandardRedraw
        DW  BAPlayerCheckSpace
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBSPlayer::
        DW  BSInit               ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BSPlayerCheck        ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBSPlayerSpace::
        DW  BSInit               ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BSPlayerCheckSpace   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHaikuPlayer::
        DW  HaikuInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  HaikuPlayerCheck     ;vector for check method
        DW  HaikuTakeDamage      ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHaikuPlayerSpace::
        DW  HaikuInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  HaikuPlayerCheckSpace ;vector for check method
        DW  HaikuTakeDamage      ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHeroLady::
        DW  LadyInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  LadyPlayerCheck      ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHeroFlour::
        DW  FlourInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  FlourPlayerCheck     ;vector for check method
        ;DW  HaikuTakeDamage      ;vector for take damage method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classFlourBullet::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  FlourBulletCheck     ;vector for check method
        DW  HaikuTakeDamage      ;vector for take damage method
        DW  StandardDie          ;vector for die method

classLadyBullet::
        DW  LadyBulletInit       ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  LadyBulletCheck      ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classGrenadePlayer::
        DW  GrenadePlayerInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GrenadePlayerCheck   ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBSActor::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBee:
        DW  BeeInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BeeCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classStunnedWall::
        DW  StunnedWallInit      ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  StunnedWallCheck     ;vector for check method
        DW  WallTakeDamage       ;vector for take damage method
        DW  StandardDie          ;vector for die method

classGrenade:
        DW  GrenadeInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GrenadeCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classVacuum:
        DW  VacuumInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  VacuumCheck          ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSlug:
        DW  SlugInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SlugCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classWallCreature::
        DW  WallCreatureInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  WallCreatureCheck    ;vector for check method
        DW  WallTakeDamage       ;vector for take damage method
        DW  StandardDie          ;vector for die method

classWallTalker::
        DW  WallCreatureInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TalkerCheck          ;vector for check method
        DW  WallTakeDamage       ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSmallBeeHive:
        DW  SmallBeeHiveInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SmallBeeHiveCheck    ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classScaredie:
        DW  ScardieInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ScardieCheck         ;vector for check method
        DW  ScardieTakeDamage    ;vector for take damage method
        DW  StandardDie          ;vector for die method

classChomper::
        DW  ChomperInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ChomperCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classReciprocator:
        DW  ReciprocatorInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ReciprocatorCheck    ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classReciprocatorPowerup:
        DW  ReciprocatorInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ReciprocatorPowerupCheck ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTri:
        DW  TriInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TriCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTriling:
        DW  TrilingInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TrilingCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTree::
        DW  TreeInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TreeCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTreeTalker::
        DW  TreeInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TreeTalkerCheck      ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBush:
        DW  BushInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BushCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classNeedle:
        DW  NeedleInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  NeedleCheck          ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBat:
        DW  BatInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BatCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBurrower:
        DW  BurrowerInit         ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BurrowerCheck        ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBurrowerDirt:
        DW  BurrowerDirtInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BurrowerDirtCheck    ;vector for check method
        DW  TakeZeroDamage       ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDandelion::
        DW  DandelionInit        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DandelionCheck       ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDandelionPuff:
        DW  DandelionPuffInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DandelionPuffCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBABullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  BASuperFastBulletCheck
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBigLongLaser::
        DW  StdBulletInit        ;vector for init method
        DW  StreamRedraw         ;vector for redraw method
        DW  StreamCheck          ;vector for check method
        DW  DoNothing            ;vector for take damage method
        DW  StreamDie            ;vector for die method

classExplosion::
        DW  ExplosionInit        ;vector for init method
        DW  ExplosionRedraw      ;vector for redraw method
        DW  ExplosionCheck       ;vector for check method
        DW  ExplosionCheck       ;vector for take damage method
        DW  ExplosionDie         ;vector for die method

classLadyFlower::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCaptainFlour::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classMouse::
        DW  MouseInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  MouseCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classPenguin::
        DW  PenguinInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  PenguinCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBIOS::
        DW  BIOSInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BIOSCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonHulk::
        DW  CroutonHulkInit      ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonHulkCheck     ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonGrunt::
        DW  CroutonGruntInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonGruntCheck    ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBigBeeHive:
        DW  BigBeeHiveInit       ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BigBeeHiveCheck      ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSheep:
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SheepCheck           ;vector for check method
        DW  CowboyTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classChicken::
        DW  ChickenInit          ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ChickenCheck         ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classPurpleWisp::
        DW  WispInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  WispCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classQuatrain::
        DW  QuatrainInit         ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  QuatrainCheck        ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classWolf::
        DW  WolfInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  WolfCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSnake::
        DW  SnakeInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SnakeCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classNeanderthal::
        DW  NeanderthalInit      ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  NeanderthalCheck     ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCrow::
        DW  CrowInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CrowCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classScarecrow::
        DW  ScarecrowInit        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ScarecrowCheck       ;vector for check method
        DW  ScarecrowTakeDamage  ;vector for take damage method
        DW  StandardDie          ;vector for die method

classAlligator:
        DW  AlligatorInit        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  AlligatorCheck       ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classWolfSheep::
        DW  WolfSheepInit        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  WolfSheepCheck       ;vector for check method
        DW  WolfSheepTakeDamage  ;vector for take damage method
        DW  StandardDie          ;vector for die method

classScorpion:
        DW  ScorpionInit         ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ScorpionCheck        ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBow:
        DW  BowInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BowCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCowboy::
        DW  CowboyInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CowboyCheck          ;vector for check method
        DW  CowboyTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classAngryCowboy::
        DW  CowboyInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  AngryCowboyCheck     ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCowboyTalker::
        DW  CowboyInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TalkerCheck          ;vector for check method
        DW  CowboyTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonDoctor::
        DW  CroutonDoctorInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonDoctorCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  StdBulletCheck       ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonWizard::
        DW  CroutonWizardInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonWizardCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classWizardBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  WizardBulletCheck    ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBSBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
IF UPGRADES
        DW  HeroSuperFastBulletCheck
ELSE
        ;DW  HeroBulletCheck      ;vector for check method
        DW  HeroSuperFastBulletCheck
ENDC
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classArrowBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  StdBulletCheck       ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classRocketBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  ExplodingBulletCheck ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCowboyBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  SuperFastBulletCheck ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonGoblin::
        DW  CroutonGoblinInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonGoblinCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classGeneralGyro::
        DW  GeneralGyroInit      ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonArtillery::
        DW  CroutonArtilleryInit ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CroutonArtilleryCheck;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classMajorSkippy::
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  ActorCheck           ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTeleportCube::
        DW  TeleportCubeInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TeleportCubeCheck    ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTeleportCube2::
        DW  TeleportCubeInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TeleportCubeCheck2   ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDandelionGuard::
        DW  DandelionGuardInit   ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DandelionGuardCheck  ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classB12Soldier::
        DW  B12SoldierInit       ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  B12SoldierCheck      ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classB12SoldierBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  StdBulletCheck       ;vector for check method
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBigSpider:
        DW  BigSpiderInit        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BigSpiderCheck       ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classLittleSpider:
        DW  LittleSpiderInit     ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  LittleSpiderCheck    ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTreeBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  SuperFastBulletCheck
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBushBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  StdBulletCheck
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classInvisibleBat:
        DW  BatInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  InvisibleBatCheck    ;vector for check method
        DW  InvisibleBatTakeDamage ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSlime::
        DW  SlimeInit            ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SlimeCheck           ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classYellowWisp::
        DW  WispInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  WispCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classMonkey::
        DW  MonkeyInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  MonkeyCheck          ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBananaBullet:
        DW  YellowBulletInit     ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  SuperFastBulletCheck
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classDuke:
        DW  DukeInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DukeCheck            ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classPig:
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  PigCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classEgg::
        DW  EggInit              ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  EggCheck             ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBlower:
        DW  BlowerInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BlowerCheck          ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSleepingMonkey:
        DW  SleepingMonkeyInit   ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  SleepingMonkeyCheck  ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBell:
        DW  BellInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DoNothingCheck       ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classRingingBell:
        DW  BellInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  DoNothingCheck       ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classBananaTree:
        DW  BananaTreeInit       ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  BananaTreeCheck      ;vector for check method
        DW  BananaTreeTakeDamage ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHermitNoShell:
        DW  HermitNoShellInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  HermitNoShellCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classHermitInShell:
        DW  HermitNoShellInit    ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  HermitInShellCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classSwampThang:
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GenericCheck         ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCrab:
        DW  CrabInit             ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  CrabCheck            ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCrabBurrowing:
        DW  CrabBurrowingInit    ;vector for init method
        DW  DoNothing            ;vector for redraw method
        DW  CrabBurrowingCheck   ;vector for check method
        DW  StdTakeDamage        ;vector for take damage method
        DW  StandardDie          ;vector for die method

classUberMouse:
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  UberMouseCheck       ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTurret::
        DW  TurretInit           ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  TurretCheck          ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classCroutonKing:
        DW  InitTwoHealth        ;vector for init method
        DW  StandardRedraw       ;vector for redraw method
        DW  GenericCheck         ;vector for check method
        DW  StdTakeDamage2x2     ;vector for take damage method
        DW  StandardDie          ;vector for die method

classTurretBullet:
        DW  StdBulletInit        ;vector for init method
        DW  StdBulletRedraw      ;vector for redraw method
        DW  SuperSuperFastBulletCheck
        DW  BulletTakeDamage     ;vector for take damage method
        DW  StandardDie          ;vector for die method

SECTION "ClassesSection",ROMX,BANK[CLASSROM]

;---------------------------------------------------------------------
;bg methods
;are passed parameters:
;   a - method type (BGACTION_HIT,BGACTION_MOVEOVER)
;   c - tile index (eg class index 24, not class 1045)
;  hl - map location
;---------------------------------------------------------------------
classGenericBG:
        ret

classAppomattoxBG::
        ret
classLandingLightsBG::
        ret
classInvisibleWallBG::
        ret

classChangeTo120BG:
        cp      BGACTION_HIT
        ret     nz

        ld      bc,classShiftPlusOneBG
        call    FindClassIndex

        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        pop     af

        ld      [hl],a
        ret

classShiftPlusOneBG:
        cp      BGACTION_HIT
        ret     nz

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        inc     a
        ld      [hl],a
        ret

classGeneratorBG:
classDestructableBG:
        cp      BGACTION_HIT
        ret     nz

        ;remove myself from the map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      [hl],0

        ld      hl,levelVars+15
        inc     [hl]
        ret

classDestructableAdjoinRightBG:
        cp      BGACTION_HIT
        ret     nz

        ;remove myself & neighbor from the map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl+],a
        ld      [hl],a
        inc     a

        ld      hl,levelVars+15
        inc     [hl]
        ret

classDestructableAdjoinLeftBG:
        cp      BGACTION_HIT
        ret     nz

        ;remove myself & neighbor from the map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl-],a
        ld      [hl],a
        inc     a

        ld      hl,levelVars+15
        inc     [hl]
        ret

classDestructableAdjoinBottomBG:
        cp      BGACTION_HIT
        ret     nz

        ;remove myself & neighbor from the map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      [hl],0
        ld      a,[mapPitch]
        add     l
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a
        ld      [hl],0

        ld      hl,levelVars+15
        inc     [hl]
        ret

classDestructableAdjoinTopBG:
        cp      BGACTION_HIT
        ret     nz

        ;remove myself & upper neighbor from the map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      [hl],0
        ld      a,[mapOffsetNorth]
        add     l
        ld      l,a
        ld      a,[mapOffsetNorth+1]
        adc     h
        ld      h,a
        ld      [hl],0

        ld      hl,levelVars+15
        inc     [hl]
        ret


classSplitterBG:
        cp      BGACTION_HIT
        jr      nz,.done

        ;get class of bullet
        ld      a,[bulletClassIndex]
        ld      c,a

        call    GetFGAttributes
        and     FLAG_ISBULLET
        ret     z

        ld      a,[bulletDirection]
        ld      b,a
        ld      [fireBulletDirection],a

        ;create a bullet continuing in the same direction
        call    CreateBulletOfClass

        ;and 90 CW
        ld      a,b
        inc     a
        and     %11
        ld      [fireBulletDirection],a
        call    CreateBulletOfClass

        ;and 90 CCW
        ld      a,b
        dec     a
        and     %11
        ld      [fireBulletDirection],a
        call    CreateBulletOfClass

.done
        xor     a    ;no explosion
        ret

classNoExplosionBG:
        xor     a
        ret

classChangeToBigSpiderBG:
        cp      BGACTION_HIT
        ret     nz

        ;I'm corner of 2x2 tile; remove tile
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl+],a
        ld      [hl-],a
        push    hl
        ld      a,[mapPitch]
        add     l
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a
        ld      [hl+],a
        ld      [hl-],a
        pop     hl

        ;create a big spider here
        ld      bc,classBigSpider
        call    FindClassIndex
        ret     z
        ld      c,a
        jp      CreateInitAndDrawObject

classAdjoinWestBG:
        cp      BGACTION_HIT
        ret     nz

        ;pass the buck to the west
        ld      a,MAPBANK
        ldio    [$ff70],a
        dec     hl
        ld      c,[hl]
        ld      a,BGACTION_HIT
        jp      CallBGAction

classAdjoinNorthBG:
        cp      BGACTION_HIT
        ret     nz

        ;pass the buck to the north
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[mapOffsetNorth]
        ld      e,a
        ld      d,$ff
        add     hl,de
        ld      c,[hl]
        ld      a,BGACTION_HIT
        jp      CallBGAction

classChangeToLittleSpiderBG:
        cp      BGACTION_HIT
        ret     nz

        ;create a little spider right here
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl],a

        ld      bc,classLittleSpider
        call    FindClassIndex
        ret     z
        ld      c,a
        jp      CreateInitAndDrawObject

classHiveBG:
        call    FindEmptyLocationAround1x1Loc
        or      a
        ret     z

        ;create an adjacent bee when the wall is shot
        ld      bc,classBee
        call    FindClassIndex
        ret     z
        ld      c,a
        jp      CreateInitAndDrawObject

classCheeseBG:
        call    FindEmptyLocationAround1x1Loc
        or      a
        ret     z

        ld      bc,classEdibleCheeseBG
        call    FindClassIndex
        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        pop     af
        ld      [hl],a

        jp      ResetMyBGSpecialFlags

classHermitCrabShellBG:
        ret

classEdibleCheeseBG:
        jr      HealthPlusOneBG

classPorkBG:
        jr      HealthPlusOneBG

classFriedEggBG:
        jr      HealthPlusOneBG

classDrumstickBG:
        jr      HealthPlusOneBG

classBananaBG:
        jr      HealthPlusOneBG

HealthPlusOneBG:
        cp      BGACTION_MOVEOVER
        ret     nz

        ldio    a,[firstMonster]
        ld      b,a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    EnsureTileIsHead
        cp      b
        ret     c                 ;not a monster

        ld      c,a
        call    GetFGAttributes
        and     FLAG_ISBULLET
        ret     nz                ;want monster not bullet

        ;clear out tile shadow bank at this loc
        ;(egg->nothing under creature)
        call    ClearBGUnderSprite

        call    GetObjectOnBG
        ;ld      a,MAPBANK
        ;ldio    [$ff70],a
        ;ld      a,[hl]
        ;call    EnsureTileIsHead
        ;ld      d,h
        ;ld      e,l
        ;call    FindObject        ;get that monster
        call    GetHealth         ;increase its health
        cp      63
        ret     nc
        inc     a
        call    SetHealth
        ld      a,BANK(eat_gbw)
        ld      hl,eat_gbw
        jp      PlaySample

classSlugTrailBG:
        cp      BGACTION_MOVEOVER
        ret     nz

        push    hl
        call    GetObjectOnBG
        pop     hl
        call    GetFGAttributes
        and     FLAG_ISBULLET
        ret     nz
        call    ClearBGUnderSprite
        ld      a,30
        jp      SetMoveDelay

GetObjectOnBG:
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    EnsureTileIsHead
        ld      c,a
        ld      d,h
        ld      e,l
        jp      FindObject        ;get that monster

ClearBGUnderSprite:
        ld      a,TILESHADOWBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl],a
        ret

classClearanceBG:
        cp      BGACTION_MOVEOVER
        ret     nz

        push    hl
        call    GetObjectOnBG
        pop     hl
        call    IsHero
        ret     z
        call    ClearBGUnderSprite

        ;add appropriate code to inventory
        ld      hl,mapToCodeIndexTable
        ld      a,[curLevelStateIndex]
        call    LookupIndexOfData8
        ld      hl,romxIndexToItemTable
        call    Lookup16
        push    hl
        pop     bc
        call    AddInventoryItem

        ;increase clearance level
        ld      bc,ITEM_ALPHACLEAR
        call    HasInventoryItem
        jr      nz,.foundCurLevel
        ld      bc,ITEM_BETACLEAR
        call    HasInventoryItem
        jr      nz,.foundCurLevel
        ld      bc,ITEM_GAMMACLEAR
        call    HasInventoryItem
        jr      nz,.foundCurLevel
        ld      bc,ITEM_DELTACLEAR
        call    HasInventoryItem
        jr      nz,.foundCurLevel
        ld      bc,ITEM_EPSILONCLEAR
        call    HasInventoryItem
        jr      nz,.foundCurLevel
        ld      bc,ITEM_ZETACLEAR
        call    HasInventoryItem
        ret     nz               ;don't go higher than zeta

        ;start with alpha clearance
        ld      bc,ITEM_ALPHACLEAR
        call    AddInventoryItem
        ret

.foundCurLevel
        call    RemoveInventoryItem
        rlc     c
        call    AddInventoryItem
        ret

IsHero:
        ld      a,[hero0_index]
        cp      c
        jr      z,.returnTrue

        ld      a,[hero1_index]
        cp      c
        jr      z,.returnTrue

.returnFalse
        xor     a
        ret

.returnTrue
        ld      a,1
        or      a
        ret

mapToCodeIndexTable:
        DB $04,$09,$2a,$6a,$a4,$73

codeIndexToItemTable:
        DW ITEM_CODE0400,ITEM_CODE0900,ITEM_CODE1002,ITEM_CODE1006
        DW ITEM_CODE0410,ITEM_CODE0307

; Arguments:    bc - item corresponding to clearance
RemoveClearanceIfTaken::
        call    HasInventoryItem
        ret     z  ;not taken yet

        ld      hl,classClearanceBG
        call    FindFirstBGLoc
        ret     z

        xor     a
        ld      [hl],a
        ret



;---------------------------------------------------------------------
;obj methods
;---------------------------------------------------------------------

SuperInit::
        push    hl

        ld      a,OBJBANK
        ldio    [$ff70],a

        ld      hl,OBJ_FRAME
        add     hl,de

        xor     a
        ld      [hl+],a           ;frame
        ld      a,1
        ld      [hl+],a           ;move countdown
        xor     a
        ld      [hl+],a           ;limit
        ld      [hl+],a           ;health
        ld      [hl+],a           ;
        ld      [hl+],a           ;
        ld      [hl+],a           ;state
        ld      [hl+],a           ;group
        ld      [hl+],a           ;destl
        ld      [hl+],a           ;desth

        ld      a,$ff
        ld      [hl+],a           ;spritelo

        xor     a
        ld      [hl+],a           ;13
        ld      [hl+],a           ;14
        ;leave NEXTL alone

        pop     hl
        ret

SuperDie::
        push    hl
        xor     a
        call    SetHealth
        jr      SuperDieFreeSprite
FreeSpriteLoPtr:
        push    hl
SuperDieFreeSprite:
        call    GetSpriteLo
        call    FreeSprite
        ld      a,$ff
        call    SetSpriteLo
        pop     hl
        ret

InitTwoHealth:
        ld      hl,.initTwoHealthTable
        jp      StdInitFromTable

.initTwoHealthTable
        DB      4                ;initial facing
        DB      2                ;health (max)
        DB      GROUP_MONSTERN   ;group friends with everyone
        DB      0                ;has bullet

DoNothing:
        ret

StandardRedraw:
        push    bc
        push    de
        push    hl

        call    GetFacing

        bit     7,a
        jr      z,StandardRedrawAfterPush   ;not a sprite

        push    bc
        ld      c,a
        call    RemoveFromMap
        pop     bc

        jr      StandardRedrawAfterPush

StandardRedrawNoCheckSprite:
StandardChooseColor:
        push    bc
        push    de
        push    hl

StandardRedrawAfterPush:
        ;white if dandelion puffs on me
        call    GetPuffCount
        or      a
        jr      z,.noPuffs

        ld      b,0
        jr      StandardDraw

.noPuffs
        call    GetFGAttributes
        and     %111
        ld      b,a

        ;falling through from above
StandardDraw:
        ;bc, de, hl already pushed in chooseColor
        ld      a,c
        ld      [curObjIndex],a

        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a

        ;save map location for later use
        ld      a,[de]
        inc     de
        ld      [methodParamL],a
        ld      a,[de]
        inc     de
        ld      [methodParamH],a

        ;get frame (facing + animation)
        ;check isSprite flag
        ld      a,[de]
        bit     7,a
        jr      z,.drawTileBased

        jp      .drawSpriteBased

.drawTileBased
        and     %111                       ;mask off facing stuff
        push    af                         ;save frame for later
        ld      d,0
        ld      e,a                        ;done with original de

        ;get attributes of tile
        ld      hl,.attributeLookup
        ld      a,[fgFlags]
        bit     BIT_NOROTATE,a
        jr      z,.afterLoadAttributeLookup
        ld      hl,.attributeLookup+8
.afterLoadAttributeLookup
        add     hl,de                      ;hl is &attributeLookup[frame]

        ld      a,[hl]                     ;flip attributes for this frame
        or      b                          ;combined
        ld      b,a                        ;B is full attributes

        ld      a,TILEINDEXBANK  ;select RAM bank of tile index maps
        ldio    [$ff70],a

        ;add 16+(is2x2*16) to attributeLookup to get tile offset Lookup
        ld      e,16
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.eHasCorrectValue
        ld      e,32
.eHasCorrectValue
        add     hl,de                      ;[hl] is tile offset

        ld      e,c                        ;index of tile is low byte
        ld      d,((fgTileMap>>8) & $ff)   ;de pts to base tile

        ld      a,[de]                     ;get base tile
        pop     de                         ;frame in d
        ld      e,c                        ;save class index in e
        cp      $ff
        jr      z,.afterAddOffset
        add     [hl]                       ;add offset
.afterAddOffset
        ld      c,a                        ;c is tile to draw

        ;retrieve ptr to map location of this object
        ld      a,[methodParamL]           ;hl = ptr to draw dest
        ld      l,a
        ld      a,[methodParamH]
        ld      h,a

        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.draw1x1tileBased

        jp      Draw2x2tileBased

.draw1x1tileBased
        ;use frame to determine how many tiles to spread this across
        ;and in what direction
        bit     2,d                 ;d is frame
        jr      z,.drawSingleTile
        bit     0,d
        jr      z,.drawNorthToSouthSplit

.drawEastToWestSplit
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      a,e
        ld      [hl+],a           ;draw class index
        ld      a,CLASS_ADJOIN_W
        ld      [hl-],a           ;in next tile too
        ld      a,TILESHADOWBANK  ;select tile shadow RAM
        ldio    [$ff70],a
        ld      a,c
        ld      [hl+],a           ;draw tile to tile shadow RAM
        ;tile plus one or minus one for frame modifier
        bit     1,d
        jr      z,.EWIncrement
        dec     a
        jr      .EWDone
.EWIncrement
        inc     a
.EWDone
        ld      [hl-],a           ;and again
        ld      a,ATTRSHADOWBANK  ;select attribute shadow RAM
        ldio    [$ff70],a
        ld      a,b
        ld      [hl+],a           ;draw attribute to attribute shadow RAM
        ld      [hl-],a           ;and again
        jr      .done

.drawNorthToSouthSplit
        call    .drawAtHL
        push    de
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        pop     de
        ld      e,CLASS_ADJOIN_N
        ;tile plus one or minus one for frame modifier
        bit     1,d
        jr      z,.NSIncrement
        ;handle NOROTATE
        ld      a,[fgFlags]
        bit     BIT_NOROTATE,a
        jr      nz,.NSIncrement
        dec     c
        jr      .NSDone
.NSIncrement
        inc     c
.NSDone
        call    .drawAtHL
        jr      .done

.drawSingleTile
        call    .drawAtHL
        jr      .done

.drawAtHL
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      [hl],e            ;draw class index
.drawShadowAtHL
        ld      a,TILESHADOWBANK  ;select tile shadow RAM
        ldio    [$ff70],a
        ld      [hl],c            ;draw tile to tile shadow RAM
        ld      a,ATTRSHADOWBANK  ;select attribute shadow RAM
        ldio    [$ff70],a
        ld      [hl],b            ;draw attribute to attribute shadow RAM
        ret

.done   pop     hl
        pop     de
        pop     bc
        ret

.drawSpriteBased
        push    bc
        push    af             ;save frame
        dec     de
        dec     de
        call    GetCurLocation

        ;copy map underneath current to tile & attribute shadow buffers
        call    .copyMapToShadowBuffers
        pop     af             ;get frame back

        bit     2,a             ;split?
        jr      z,.updateSprite ;done copying tile stuff

        bit     0,a             ;n/s or e/w?
        jr      z,.spriteNS

        ;e/w split
        inc     hl
        call    .copyMapToShadowBuffers
        jr      .updateSprite

.spriteNS
        ;n/s split
        push    de                     ;retrieve vertical offset
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        pop     de

        call    .copyMapToShadowBuffers

.updateSprite
        pop     bc

        push    bc
        ld      a,[curObjIndex]
        ld      c,a
        ;draw the object's id to the map buffer
        call    GetFacing
        ld      b,a
        call    GetCurLocation
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      [hl],c     ;head of obj
        ld      a,b
        and     %00000101
        cp      %00000101  ;E/W split
        jr      nz,.checkNS_Split
        inc     hl
        ld      [hl],CLASS_ADJOIN_W
        jr      .doneDrawID
.checkNS_Split
        ld      a,b
        and     %00000100
        jr      z,.doneDrawID
        ;N/S split
        ld      a,[mapOffsetSouth]
        add     l
        ld      l,a
        ld      a,[mapOffsetSouth+1]
        adc     h
        ld      h,a
        ld      [hl],CLASS_ADJOIN_N
.doneDrawID
        pop     bc

        call    GetCurLocation
        ld      a,TILESHADOWBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        jr      z,.afterCallMoveOverBG

        push    bc
        ld      c,a
        ld      a,BGACTION_MOVEOVER
        call    CallBGAction
        pop     bc

.afterCallMoveOverBG
        ;attempt to allocate sprite if we don't have one
        call    GetSpriteLo
        cp      $ff
        jr      nz,.haveSprite

        ;see if the sprite will show up onscreen
        call    GetCurLocation
        call    ConvertLocHLToSpriteCoords
        ;ld      a,l
        ;or      a
        ;jr      z,.spdone       ;won't show up anyways

        call    AllocateSprite
        cp      $ff
        jr      z,.spdone       ;no sprite for you
        call    SetSpriteLo

.coordsOkay
        ;initialize the sprite's position
        push    af
        push    de
        ld      e,a
        ld      d,((spriteOAMBuffer>>8) & $ff)
        ld      a,l
        ld      [de],a
        inc     de
        ld      a,h
        ld      [de],a
        pop     de
        pop     af

        ;if split bit is set scoot in one direction or another
        push    bc
        push    af
        call    GetFacing
        bit     2,a
        jr      z,.afterScoot

        bit     0,a          ;N/S or E/W?
        jr      nz,.scootEW

        ;scoot down for N/S split
        ld      b,%00000010
        jr      .doSplit

.scootEW  ;scoot right for E/W split
        ld      b,%00000001

.doSplit
        pop     af
        push    af
        call    ScootSprite

.afterScoot
        pop     af
        pop     bc

.haveSprite     ;set up the sprite to reflect the current facing
        push    bc

        call    GetSpritePtrInHL
        inc     hl
        inc     hl
        call    GetFGTileMapping
        ld      c,a

        call    GetFacing
        bit     0,a
        jr      nz,.facingEastWest

        ;facing north/south
        inc     c
        inc     c
        bit     1,a
        jr      z,.checkAnim    ;facing north no flip

        ;facing south
        set     6,b             ;flip tile vertically
        jr      .checkAnim

.facingEastWest
        bit     1,a             ;facing east or west?
        jr      z,.checkAnim    ;facing east, no flip

        set     5,b             ;facing west, flip horizontally

.checkAnim
        bit     2,a             ;check split bit
        jr      z,.baseAnimOkay

        inc     c

.baseAnimOkay
        ld      a,c             ;tile number
        ld      [hl+],a

        ld      a,b
        or      %00001000       ;attributes
        ld      [hl],a

        pop     bc

        ;clear vflip bit if NOROTATE flag set
        call    GetFGAttributes
        and     FLAG_NOROTATE
        jr      z,.spdone

        res     6,[hl]

.spdone pop     hl
        pop     de
        pop     bc
        ret

.copyMapToShadowBuffers
        ;assumes hl points to location
        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      a,[hl]            ;get map tile

        ;get bg attributes of this map tile
        ld      c,a
        ld      b,((bgAttributes>>8) & $ff)
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,[bc]

        ;clear off all but the palette
        and     %00000111
        ld      b,a
        call    .drawShadowAtHL

        ret

.attributeLookup
  DB %00001000,%00001000,%01001000,%00101000  ;1x1 normal
  DB %00001000,%00001000,%01001000,%00101000
  DB %00001000,%00001000,%00001000,%00101000  ;no rotate
  DB %00001000,%00001000,%00001000,%00101000
.tileOffsetLookup
  DB  0, 3, 0, 3, 1, 4, 2, 5    ;1x1 creature n,e,s,w,nsp,esp,ssp,wsp
  DB  0, 3, 0, 3, 1, 4, 1, 5    ;1x1 no rotate
  DB  0,10, 2,11, 4,14, 8,16    ;2x2 creature
  DB  0,10, 2,11, 4,14, 8,16    ;2x2 creature

  DB  0   ;pad to make emulator not freak the disasm

Draw2x2tileBased:
        ;use frame to determine how many tiles to spread this across
        ;and in what direction
        bit     2,d                 ;d is frame
        jr      nz,.decideWhichSplit
        jp      .drawNonSplit
.decideWhichSplit
        bit     0,d
        jr      z,.drawNorthToSouthSplit

.drawEastToWestSplit
        bit     1,d
        jr      nz,.drawSplitFacingWest

.drawSplitFacingEast
        push    hl
        call    .drawHeadOfEWSplit
        call    .drawSplitE_PatternAndAttrNumbers
        ld      a,c
        add     3
        ld      c,a

        ;move hl to start of next row
        pop     hl
        call    HLToNextRow

        ;repeat for row 2
        call    .drawSecondRowOfEWSplit
        call    .drawSplitE_PatternAndAttrNumbers
        jp      .done

.drawSplitFacingWest
        push    hl
        call    .drawHeadOfEWSplit
        call    .drawSplitW_PatternAndAttrNumbers
        ld      a,c
        add     3
        ld      c,a

        ;move hl to start of next row
        pop     hl
        call    HLToNextRow

        ;repeat for row 2
        call    .drawSecondRowOfEWSplit
        call    .drawSplitW_PatternAndAttrNumbers
        jp      .done

.drawNorthToSouthSplit
        bit     1,d
        jr      nz,.drawSplitFacingSouth

.drawSplitFacingNorth
        push    hl
        call    .drawHeadOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        inc     c
        inc     c

        ;move hl to start of next row
        pop     hl
        call    HLToNextRow

        ;repeat for row 2 & 3
        push    hl
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        inc     c
        inc     c
        pop     hl
        call    HLToNextRow
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        jp      .done

.drawSplitFacingSouth
        push    hl
        call    .drawHeadOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        dec     c
        dec     c

        ;move hl to start of next row
        pop     hl
        call    HLToNextRow

        ;repeat for row 2 & 3
        push    hl
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        dec     c
        dec     c
        pop     hl
        call    HLToNextRow
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        jr      .done

.drawNonSplit
        bit     1,d
        jr      z,.drawNonSplitNorE

        bit     0,d
        jr      nz,.drawNonSplitW

.drawNonSplitS
        push    hl
        call    .drawHeadOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        dec     c
        dec     c

        ;move hl to start of next row
        pop     hl
        call    HLToNextRow

        ;repeat for next row
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        jr      .done

.drawNonSplitW
        push    hl
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,e
        ld      [hl+],a
        ld      a,CLASS_ADJOIN_W
        ld      [hl-],a

        call    .drawWPatternAndAttributeNumbers
        inc     c
        inc     c

        pop     hl
        call    HLToNextRow

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,CLASS_ADJOIN_N
        ld      [hl+],a
        ld      [hl-],a
        call    .drawWPatternAndAttributeNumbers
        jr      .done

.drawNonSplitNorE
        push    hl
        call    .drawHeadOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers
        inc     c
        inc     c
        pop     hl
        call    HLToNextRow
        call    .drawSecondRowOfNSSplit
        call    .drawSplitNS_PatternAndAttrNumbers

.done   pop     hl
        pop     de
        pop     bc
        ret

.drawHeadOfEWSplit
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      a,e
        ld      [hl+],a           ;draw class index
        ld      a,CLASS_ADJOIN_W
        ld      [hl+],a
        ld      [hl-],a
        dec     hl
        ret

.drawSecondRowOfEWSplit
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      a,CLASS_ADJOIN_N
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl-],a
        dec     hl
        ret

.drawSplitE_PatternAndAttrNumbers
        ;draw pattern numbers to tile shadow bank
        ld      a,TILESHADOWBANK  ;select tile shadow RAM
        ldio    [$ff70],a
        ld      a,c
        ld      [hl+],a           ;draw tile to tile shadow RAM
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl],a

        ;draw colors to attr shadow bank
        ld      a,ATTRSHADOWBANK  ;select attribute shadow RAM
        ldio    [$ff70],a
        ld      a,b
        ld      [hl-],a           ;draw attribute to attribute shadow RAM
        ld      [hl-],a
        ld      [hl],a
        ret

.drawSplitW_PatternAndAttrNumbers
        ;draw pattern numbers to tile shadow bank
        ld      a,TILESHADOWBANK  ;select tile shadow RAM
        ldio    [$ff70],a
        ld      a,c
        ld      [hl+],a           ;draw tile to tile shadow RAM
        dec     a
        ld      [hl+],a
        dec     a
        ld      [hl],a

        ;draw colors to attr shadow bank
        ld      a,ATTRSHADOWBANK  ;select attribute shadow RAM
        ldio    [$ff70],a
        ld      a,b
        ld      [hl-],a           ;draw attribute to attribute shadow RAM
        ld      [hl-],a
        ld      [hl],a
        ret

.drawHeadOfNSSplit
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      a,e
        ld      [hl+],a           ;draw class index
        ld      a,CLASS_ADJOIN_W
        ld      [hl-],a
        ret

.drawSecondRowOfNSSplit
        ld      a,MAPBANK         ;select map RAM
        ldio    [$ff70],a
        ld      a,CLASS_ADJOIN_N
        ld      [hl+],a
        ld      [hl-],a
        ret

.drawSplitNS_PatternAndAttrNumbers
        ;draw pattern numbers to tile shadow bank
        ld      a,TILESHADOWBANK  ;select tile shadow RAM
        ldio    [$ff70],a
        ld      a,c
        ld      [hl+],a           ;draw tile to tile shadow RAM
        inc     a
        ld      [hl],a

        ;draw colors to attr shadow bank
        ld      a,ATTRSHADOWBANK  ;select attribute shadow RAM
        ldio    [$ff70],a
        ld      a,b
        ld      [hl-],a           ;draw attribute to attribute shadow RAM
        ld      [hl],a
        ret

.drawWPatternAndAttributeNumbers
        ld      a,TILESHADOWBANK
        ldio    [$ff70],a
        ld      a,c
        ld      [hl+],a
        dec     a
        ld      [hl],a

        ld      a,ATTRSHADOWBANK
        ldio    [$ff70],a
        ld      a,b
        ld      [hl-],a
        ld      [hl],a
        ret

HLToNextRow:
        push    de
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        pop     de
        ret

GenericCheck:
        ld      hl,.genericCheckTable
        jp      StdCheckFromTable

.genericCheckTable
        DB      5      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      nullSound
        DB      10     ;fire delay
        DW      StdVectorToState

IF 0
        ;push    bc
        ;push    de
        ;push    hl

        ;am I dead?
        call    GetHealth
        or      a
        jr      nz,.checkTimeToMove
        call    StandardDie
        jr      .done

.checkTimeToMove
        ;time to move?
        ld      a,5  ;2
        call    TestMove
        or      a
        jr      z,.skipMove       ;timer lsb==frame lsb, don't move yet

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StdVectorToState
        or      a
        jr      z,.skipMove
        ;call    GetRandomMovement
        ;ld      b,2      ;everyone move this way
        call    StandardValidateMoveAndRedraw
.skipMove

.done   ;pop     hl
        ;pop     de
        ;pop     bc
        ret
ENDC

TalkerCheck:
        ld      hl,talkerCheckTable
TalkerCheckAfterSetupHL:
        ld      a,c
        ld      [dialogBalloonClassIndex],a
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
        push    hl
        call    StdCheckTalk
        pop     hl
        ret     z
        call    StdMove
        ret


talkerCheckTable:
        DB      5      ;move delay
        DW      StdVectorToState


GetRandomMovement:
        ;returns random value in b
        ;alters a, b, and hl

        ;pick a "random value" ((counter+=17))
        ld      a,%00001111
        call    GetRandomNumMask

        ;ldio    a,[randomLoc]
        ;add     17
        ;ldio    [randomLoc],a
        ;and     %00001111       ;restrict to 0-15
        cp      4
        jr      c,.randomDir    ;less than 4 move in a different direction

        ;move in direction we're currently facing
        ;get current frame
        ld      a,OBJBANK       ;select object RAM
        ldio    [$ff70],a
        ld      hl,2
        add     hl,de
        ld      a,[hl]
        and     %00000011       ;clear off all but the direction bits
        ld      b,a             ;b is same direction as before
        ret

.randomDir
        and     %00000011       ;mask off our random # to a direction
        ld      b,a
        ret


;---------------------------------------------------------------------
; Routine:      EnforceLegalMove
; Arguments:    b  - original desired move direction
;               c  - class index
;               de - "this"
; Returns:      b  - modified move direction
; Alters:       a, b, hl
; Description:  Adjusts move direction stored in b so that it is legal.
;               A creature can always turn 180 around, but otherwise
;               this means that it will travel forward if it is split
;               between two tiles or if there is a wall in the desired
;               direction.
;---------------------------------------------------------------------
EnforceLegalMove:
        ;get current frame in a
        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a
        ld      hl,2
        add     hl,de
        ld      a,[hl]

        ;is object split between two tiles?
        bit     2,a
        jr      z,.notSplit

        ;It is split.  This makes our job easy - creature can only
        ;turn around or go forward
        ld      h,a              ;save current direction in h
        add     2                ;add two and mask off to reverse
        and     %00000011
        cp      b                ;reverse dir equal to desired?
        jr      nz,.splitMF      ;no, move forward

        ret                      ;allow move in reverse direction

.splitMF
        ;force the wee bairn to move forward
        ld      a,h
        and     %00000011
        ld      b,a
        ret

.notSplit
        ;critter's not split.  Maybe it just wants to turn around
        ;without a lot of fuss?
        ld      h,a              ;save current direction in h
        add     2                ;add two and mask off to reverse
        and     %00000011
        cp      b                ;reverse dir equal to desired?
        jr      nz,.noReverse    ;hmm guess not

        ret                      ;let 'im turn around slowly like

.noReverse
        push    de
        push    hl
jr .moveAnywhere

        ;setup de with ptr to current location
        ld      h,d
        ld      l,e
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a              ;de has ptr to cur location

        ld      a,MAPBANK        ;select map RAM
        ldio    [$ff70],a

        ;Determine offset to check for wall and store in HL.
        ld      a,b              ;desired dir
        add     b                ;times two
        ld      h,((mapOffsetNorth>>8)&$ff)
        add     (mapOffsetNorth & $ff)
        ld      l,a              ;hl pts to offset
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a              ;hl IS offset

        ;don't examine my tail in the process; multiply offset
        ;by two if 2x2 and facing east or south
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.afterModifyOffset

        ld      a,b
        and     %00000011
        cp      %01         ;east
        jr      z,.offsetTimesTwo
        cp      %10         ;south
        jr      nz,.afterModifyOffset

.offsetTimesTwo
        sla     l    ;hl<<=1   (same as *2)
        rl      h

.afterModifyOffset
        add     hl,de            ;hl is &location in desired dir
        ldio    a,[firstMonster] ;d = firstMonster
        ld      d,a
        ld      a,[hl]           ;what's there?
        or      a
        jr      z,.moveAnywhere  ;nothing there
        cp      d
        jr      nc,.moveAnywhere

        ;wall there, move forward unless special flag says okay
        push    af
        ld      a,ZONEBANK
        ldio    [$ff70],a
        pop     af
        bit     7,[hl]       ;marked as special somehow?
        jr      z,.moveForwardIfNotBlocked  ;nope

        call    GetBGAttributes
        bit     BG_BIT_ATTACKABLE,a
        jr      nz,.moveAnywhere

        bit     BG_BIT_WALKOVER,a
        jr      z,.moveForwardIfNotBlocked

        ldio    a,[curObjWidthHeight]
        cp      1
        jr      z,.moveAnywhere              ;can walk over
        jr      .moveForwardIfNotBlocked

        ;nuttin there or a monster to face, let the creature move in
        ;whatever direction it wants, bless its little heart (direction
        ;B is fine)
.moveAnywhere
        pop     hl
        pop     de
        ret

.moveForwardIfNotBlocked
        pop     hl
        pop     de
        ld      l,b
        ld      a,h
        and     %00000011
        ld      b,a
        push    hl
        ld      a,1
        call    CheckDestEmpty
        pop     hl
        or      a
        jr      nz,.done
        ld      b,l              ;allow turn anywhere if blocked ahead
        ret


.moveForward
        ;hey, you can only move forward asshole
        ld      a,h              ;desired dir = cur dir
        and     %00000011
        ld      b,a
.done
        ret

;---------------------------------------------------------------------
; Routine:      ScootSprite
; Arguments:    a  - loptr to sprite
;               b  - desired move direction
; Alters:       af
; Description:  Moves an existing sprite 4 pixels in a given
;               direction.
;---------------------------------------------------------------------
ScootSprite:
        cp      $ff
        ret     z

        push    hl

        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)

        bit     0,b     ;test direction of travel
        jr      nz,.eastWest

        ld      a,[hl]
        bit     1,b
        jr      nz,.south

        ;north
        sub     4
        ld      [hl],a
        jr      .afterUpdateSpritePos

.south
        add     4
        ld      [hl],a
        jr      .afterUpdateSpritePos

.eastWest
        inc     hl
        ld      a,[hl]
        bit     1,b
        jr      nz,.west

        ;east
        add     4
        ld      [hl],a
        jr      .afterUpdateSpritePos

.west
        sub     4
        ld      [hl],a

.afterUpdateSpritePos
        pop     hl
        ret


;---------------------------------------------------------------------
; Routine:      Move
; Arguments:    b  - desired move direction
;               c  - class index
;               de - "this"
; Returns:      Nothing
; Alters:       a, hl
; Description:  If desired dir is != current dir then turns creature
;               to desired dir.  Otherwise takes a step forward.
;               If it moves AND changes zones the curPathPos
;               (frame bits 6:5) is set to zero.
;
;               There are three steps:
;               1)  Remove From Map
;                   If the IsSprite flag is set (FRAME:7) then the
;                   map is restored from the contents of the
;                   tileShadowBuffer.  Otherwise the map tiles creature
;                   is occupying are cleared to zero.
;
;               2)  Adjust IsSprite flag (FRAME:7)
;                   If 0:  If [bgFlags] contains FLAG_WALKOVER or
;                          FLAG_SHOOTOVER then IsSprite is set to 1.
;                   Else If 1:
;                          If frame:split is 0 and tile under is zero
;                          then IsSprite is set to zero.
;
;               3)  Redraw
;                   If the IsSprite flag is set then the map
;                   underneath is copied to the tileShadowBuffer.
;
;                   Regardless the class index of the object is drawn
;                   into the map.

;               If [bgFlags] contains either BG_FLAG_WALKOVER or
;               BG_FLAG_SHOOTOVER then
;---------------------------------------------------------------------
Move:
        push    bc

        ;save current zone to see if it changes when we move
        call    GetCurZone
        ld      [oldZone],a

        ;get current direction in c
        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[hl]         ;a = frame
        ld      c,a

        ;same as desired direction?
        and     %00000011
        cp      b
        jr      z,.sameDirection

        ;Different direction.  Turn to desired direction.
        ld      a,c
        and     %11111100      ;preserve non-direction other bits
        or      b              ;combined with new direction
        ld      [hl],a         ;and that's our new frame!

        ;have to remove from map if we're a sprite
        call    GetFacing
        bit     7,a
        jr      z,.doneTurn

        call    RemoveFromMap

.doneTurn
        pop     bc
        ret

.sameDirection
        call    RemoveFromMap  ;gonna be drawin again real soon, Baby!

        ld      a,OBJBANK      ;select object RAM
        ld      [$ff70],a

        ;if we were split facing west or north then we don't actually
        ;move, we just turn off the split bit
        bit     2,c
        jr      z,.noSplitCheckEastSouth

        ;facing west?
        ld      a,c
        and     %00000111
        cp      %00000111
        jr      nz,.checkSplitFacingNorth

.noMoveToggleSplit
        ld      a,c
        xor     %00000100
        ld      c,a
        jr      .stowNewFrame

.checkSplitFacingNorth
        cp      %00000100
        jr      z,.noMoveToggleSplit
        jr      .moveForwardToggleSplit

.noSplitCheckEastSouth
        ;if we're not split and we're heading East or South then again
        ;we just toggle the split bit as our move
        ld      a,c
        and     %00000111
        cp      %00000001              ;facing East?
        jr      z,.noMoveToggleSplit
        cp      %00000010              ;facing South?
        jr      z,.noMoveToggleSplit

.moveForwardToggleSplit
        push    hl
        push    de

        ;setup de with ptr to current location
        ld      h,d
        ld      l,e
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a              ;de has ptr to cur location

        ;Determine offset to check for wall and store in HL.
        ld      a,b              ;desired dir
        add     b                ;times two
        ld      hl,mapOffsetNorth
        add     l
        ld      l,a              ;hl pts to offset
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a              ;hl IS offset
        add     hl,de
        ld      d,h
        ld      e,l

        ;toggle the split bit for the new frame
        ld      a,c
        xor     %00000100
        ld      c,a              ;c has new frame

        ;store new location in object
        pop     hl               ;hl is ptr to this

        ld      a,e
        ld      [hl+],a
        ld      a,d
        ld      [hl-],a

        ;restore de
        ld      d,h
        ld      e,l

        pop     hl

.stowNewFrame
        ;if IsSprite bit off, check to see if we want to turn
        ;it on
        bit     7,c
        jr      nz,.spriteBitIsOn

        ld      a,[bgFlags]
        and     BG_FLAG_SPECIAL
        jr      z,.reallyStowNewFrame

        set     7,c                  ;turn sprite flag on
        ;call    AllocateSprite
        ;call    StoreSpriteLo
        jr      .reallyStowNewFrame

.spriteBitIsOn
        ;can we turn it off?
        bit     2,c                        ;is frame bit zero?
        jr      nz,.updateSpritePos        ;no, leave it on

        ;maybe turn it off; see what we're over
        push    hl
        call    GetCurLocation
        ld      a,MAPBANK
        ld      [$ff70],a
        ld      a,[hl]
        push    af
        ld      a,OBJBANK
        ld      [$ff70],a
        pop     af
        pop     hl

        or      a
        jr      nz,.updateSpritePos        ;leave it on

        res     7,c                        ;turn it off
        call    FreeSpriteLoPtr
        jr      .reallyStowNewFrame

.updateSpritePos
        ;since the sprite has been on let's scoot the sprite 4
        ;pixels in the direction we've moved

        call    GetSpriteLo
        call    ScootSprite

.reallyStowNewFrame
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      a,c            ;new frame
        ld      [hl],a

        ;if oldZone != curZone then set curPathPos to zero
        call    GetCurZone
        ld      hl,oldZone
        cp      [hl]
        jr      z,.done

        call    ResetCurPathPos

.done   pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      RemoveFromMap
; Arguments:    c  - current frame
;               de - "this"
; Returns:      Nothing
; Alters:       af
; Description:  Removes the this object's class index from the main
;               map buffa
;---------------------------------------------------------------------
RemoveFromMap::
        push    bc
        push    de
        push    hl

        call    GetCurLocation

        ;is object currently a sprite?
        bit     7,c
        jr      nz,.clearSprite

        ld      a,MAPBANK      ;select map RAM
        ldio    [$ff70],a

        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.clear2x2tiles

        ;clear out this location
        xor     a
        ld      [hl+],a

        ;if we were a split tile then clear out the next one to the
        ;right OR to the bottom
        bit     2,c
        jr      z,.done

        bit     0,c
        jr      z,.splitNS

        ;split E/W
        ld      [hl+],a       ;clear out the next location too, sucka
        jr      .done

.splitNS
        ;scoot HL down a row
        ld      d,0
        ld      a,[mapPitchMinusOne]
        ld      e,a
        add     hl,de
        ld      [hl],d        ;clear 'em all
        jr      .done

.clearSprite
        call    .getTilePreviouslyHere

        ;if we were a split tile then clear out the next one to the
        ;right OR to the bottom
        bit     2,c
        jr      z,.done

        bit     0,c
        jr      z,.spriteSplitNS

        ;split E/W
        inc     hl
        call    .getTilePreviouslyHere
        jr      .done

.spriteSplitNS
        ;scoot HL down a row
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        call    .getTilePreviouslyHere

.done   pop     hl
        pop     de
        pop     bc
        ret

.getTilePreviouslyHere
        ld      a,TILESHADOWBANK
        ld      [$ff70],a

        ld      b,[hl]

        ld      a,MAPBANK
        ld      [$ff70],a

        ld      [hl],b

        ret

.clear2x2tiles
        push    hl
        call    .clear2x2row
        pop     hl
        call    HLToNextRow
        push    hl
        call    .clear2x2row
        pop     hl
        ld      a,c
        and     %00000101
        cp      %00000100
        jr      nz,.done2x2
        call    HLToNextRow
        call    .clear2x2row

.done2x2
        pop     hl
        pop     de
        pop     bc
        ret

.clear2x2row
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      a,c
        and     %00000101
        xor     %00000101
        ret     nz
        ld      [hl+],a
        ret

;---------------------------------------------------------------------
; Routine:      CheckDestEmpty
; Arguments:    b   - desired direction
;               de  - "this"
;               a   - 0=don't consider facing, 1=consider facing
;
; Returns:      a   - dest is empty
;               !a  - dest is not empty
; Alters:       a, hl
; Description:  Checks along direction of travel for empty tile
;---------------------------------------------------------------------
CheckDestEmpty:
        ld      [temp],a

        xor     a
        ld      [bgFlags],a

        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a

        ;load cur frame into a
        ld      hl,2
        add     hl,de
        ld      a,[hl]

        ;don't bother if split bit is set, we're fine
        bit     2,a
        ret     nz

        ;and don't bother if direction of travel is not equal to
        ;current facing (just turning)
        ld      a,[temp]
        or      a
        jr      z,.check
        ld      a,[hl]

        and     %00000011
        cp      b
        jr      z,.check
        ld      a,1            ;set return value A to non-zero
        ret

.check
        push    de
        push    hl

        ;setup de with ptr to current location
        ld      h,d
        ld      l,e
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a              ;de has ptr to cur location

        ld      a,MAPBANK      ;select map RAM
        ldio    [$ff70],a

        call    GetMapOffset

        ;don't examine my tail in the process; multiply offset
        ;by two if 2x2 and facing east or south
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.afterModifyOffset

        ld      a,b
        and     %00000011
        cp      %01         ;east
        jr      z,.offsetTimesTwo
        cp      %10         ;south
        jr      nz,.afterModifyOffset

.offsetTimesTwo
        sla     l    ;hl<<=1   (same as *2)
        rl      h

.afterModifyOffset
        add     hl,de            ;hl is ptr to new location

        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.check2x2

        ;check 1x1
        ld      a,[hl]           ;contents of dest into a
        call    .checkCanMoveOver
        pop     hl
        pop     de
        ret

.check2x2
        ;check first adjacent tile
        ld      a,[hl]
        call    .checkCanMoveOver
        or      a
        jr      z,.done   ;blocked on first, no use checking second

        ;first clear; check second adj tile
        ld      a,b
        and     1    ;now 0=n/s, 1=e/w
        add     1    ;now check adj in e for original n/s, s for e/w
        call    AdvanceLocHLInDirection
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    .checkCanMoveOver

.done   pop     hl
        pop     de
        ret

.checkCanMoveOver
        or      a                ;zero?
        jr      nz,.checkSpecialFlags
        ld      a,1              ;return true
        ret

.checkSpecialFlags
        ld      e,a
        ldio    a,[firstMonster]
        cp      e
        jr      z,.false         ;is a monster
        jr      c,.false         ;is a monster

        ld      a,TILEINDEXBANK
        ld      [$ff70],a
        ld      d,((bgAttributes>>8) & $ff)
        ld      a,[de]
        ld      [bgFlags],a
        and     BG_FLAG_WALKOVER
        jr      z,.false

        ldio    a,[curObjWidthHeight]
        cp      1
        jr      nz,.false

        ;return true
        ld      a,1
        ret

.false  xor     a                ;return false
        ret

;---------------------------------------------------------------------
; Routines:     GetMapOffset
; Arguments:    b  - map direction to get offset in
; Returns:      hl - desired offset
; Alters:       a, hl
;---------------------------------------------------------------------
GetMapOffset:
        ld      a,b              ;desired dir
        add     b                ;times two
        ld      hl,mapOffsetNorth
        add     l
        ld      l,a              ;hl pts to offset
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a              ;hl IS offset
        ret

;---------------------------------------------------------------------
; Routines:     TestMove
;               HeroTestMove
; Arguments:    a  - value to reset counter to if it reaches zero
;               de - "this"
; Returns:      a  - time to move
;               !a - don't move
; Alters:       a,hl
; Description:
;---------------------------------------------------------------------
TestMove:
        push    af
        call    PointToSpecialFlags
        bit     OBJBIT_THROWN,[hl]
        jr      nz,TestMoveThrown
        pop     af

TestMoveNoCheckSpecial:
        push    bc
        ld      c,a

        ld      a,[objTimer60ths]    ;get timer
        and     %00011000         ;get rid of other bits
        ld      b,a
        ld      hl,OBJ_FRAME      ;offset of frame variable
        add     hl,de
        xor     a,[hl]            ;xor timer4:3 w/frame4:3, hl=&move

        push    af
        ld      a,[hl]            ;current state
        and     %11100111         ;mask off area for timer
        or      b                 ;store bits from current timer
        ld      [hl],a
        pop     af
        and     %00011000         ;get rid of other bits
        jr      z,.skipMove       ;already moved this turn

        push    bc
        inc     hl

        dec     [hl]

        jr      z,.timeToMove

        ;no move but save modified timer
        pop     bc
        pop     bc
        xor     a
        ret

.timeToMove
        ;time to move!
        push    hl
        ld      hl,OBJ_DESTZONE   ;point to # puffs
        add     hl,de
        ld      a,[hl]
        and     %1111
        pop     hl
        add     a,c               ;reset move counter (add #puffs)

        ;or      b
        ld      [hl-],a

        pop     bc

        ld      a,1               ;return true/able to move

.skipMove
        pop     bc
        ret

HeroTestMove:
        push    af
        call    PointToSpecialFlags
        bit     OBJBIT_THROWN,[hl]
        jr      nz,TestMoveThrown
        pop     af

        push    bc
        ld      c,a

        ld      a,OBJBANK       ;select object RAM
        ldio    [$ff70],a

        ld      a,[heroTimer60ths]    ;get timer
        and     %00011000         ;get rid of other bits
        ld      b,a
        ld      hl,OBJ_FRAME      ;offset of frame variable
        add     hl,de
        xor     a,[hl]            ;xor timer4:3 w/frame4:3, hl=&move
        push    af
        ld      a,[hl]            ;current state
        and     %11100111         ;mask off area for timer
        or      b                 ;store bits from current timer
        ld      [hl],a
        pop     af
        and     %00011000         ;get rid of other bits
        jr      z,.skipMove       ;already moved this turn

        push    bc
        inc     hl

        dec     [hl]

        jr      z,.timeToMove

        ;no move but save modified timer
        pop     bc
        pop     bc
        xor     a
        ret

.timeToMove
        ;time to move!
        push    hl
        ld      hl,OBJ_DESTZONE   ;point to # puffs
        add     hl,de
        ld      a,[hl]
        and     %1111
        pop     hl
        add     a,c               ;reset move counter (add #puffs)

        ld      [hl-],a
        pop     bc

        ld      a,1               ;return true/able to move

.skipMove
        pop     bc
        ret

TestMoveThrown:
        ;move one in current facing and return "unable to move"
        pop     af
        ld      a,1
        call    TestMoveNoCheckSpecial
        or      a
        ret     z

        ldio    a,[firstMonster]
        ld      b,a
        ld      a,4
        call    GetLocInFront
        or      a
        jr      z,.emptyAhead

        cp      b
        jr      nc,.stop

        ld      a,[bgFlags]
        bit     BG_BIT_WALKOVER,a
        jr      z,.stop

        ldio    a,[curObjWidthHeight]
        cp      1
        jr      z,.emptyAhead

.stop   call    PointToSpecialFlags
        res     OBJBIT_THROWN,[hl]
        ld      a,[hero0_index]
        cp      c
        jr      z,.heroJiggle
        ld      a,[hero1_index]
        cp      c
        jr      z,.heroJiggle
        xor     a
        ret

.heroJiggle
        ld      a,5
        ldio    [jiggleDuration],a
        xor     a
        ret

.emptyAhead
        call    GetCurLocation
        push    hl
        call    GetFacing
        and     %111
        ld      b,a
        push    bc
        and     %11
        ld      b,a
        call    StandardValidateMoveAndRedraw
        pop     bc
        pop     hl

        ;check if way blocked after all (2x2 monster)
        call    GetFacing
        and     %111
        cp      b
        jr      nz,.done
        ld      a,[de]
        cp      l
        jr      nz,.done
        inc     de
        ld      a,[de]
        dec     de
        cp      h
        jr      z,.stop

.done
        xor     a
        ret

;---------------------------------------------------------------------
; Routines:     StdVectorToState
;               EatVectorToState
;               TrackEnemyVectorToState
;               ActorVectorToState
;               FleeVectorToState
; Arguments:    de  - "this"
; Returns:      b   - direction to move
;               a   - non-zero for move valid, zero for no move
; Alters:       a, b, hl
;---------------------------------------------------------------------
VectorToStateCommonInit:
        call    GetState
        rlca
        and     %01111110
        ret

StdVectorToState:
        call    VectorToStateCommonInit
        add     (stdStateTable & $ff)
        ld      l,a
        ld      h,((stdStateTable>>8) & $ff)
VectorToStateCommon:
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        jp      hl

EatVectorToState:
        call    VectorToStateCommonInit
        add     (eatStateTable & $ff)
        ld      l,a
        ld      h,((eatStateTable>>8) & $ff)
        jr      VectorToStateCommon

TrackEnemyVectorToState:
        call    VectorToStateCommonInit
        add     (trackEnemyStateTable & $ff)
        ld      l,a
        ld      h,((trackEnemyStateTable>>8) & $ff)
        jr      VectorToStateCommon

ActorVectorToState:
        call    VectorToStateCommonInit
        add     (actorStateTable & $ff)
        ld      l,a
        ld      h,((actorStateTable>>8) & $ff)
        jr      VectorToStateCommon

FleeVectorToState:
        call    VectorToStateCommonInit
        add     (fleeStateTable & $ff)
        ld      l,a
        ld      h,((fleeStateTable>>8) & $ff)
        jr      VectorToStateCommon

LadyVectorToState:
        call    VectorToStateCommonInit
        add     (ladyBulletStateTable & $ff)
        ld      l,a
        ld      h,((ladyBulletStateTable>>8) & $ff)
        jr      VectorToStateCommon

;---------------------------------------------------------------------
; STATE METHODS
; Arguments:    de  - "this"
; Returns:      b   - direction to move
;               a   - non-zero for move valid, zero for no move
; Alters:       a, b, hl
;---------------------------------------------------------------------
SetupRandomMoveState:
        ld      a,6
        call    SetState
        xor     a
        ret

EatOrTrackState:
        ;move in direction of food next to me
        ld      b,0
.checkDirectionForFood
        ld      a,b
        call    GetLocInFront
        or      a
        jr      z,.continue

        push    bc
        push    hl
        ld      b,a
        call    GetDestL    ;min index I can eat
        cp      b
        jr      z,.maybeFood
        jr      nc,.notFood
.maybeFood
        call    GetDestH    ;max index I can eat
        cp      b
        jr      nc,.food

.notFood
        pop     hl
        pop     bc
        jr      .continue


.food
        pop     hl
        pop     bc

        ;remove tile in direction I'm facing that way and I'm not split
        call    GetFacing
        bit     2,a
        jr      nz,.foundFood

        and     %11
        cp      b
        jr      nz,.foundFood

        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl],a

        ld      hl,eatSound
        call    PlaySound

.foundFood
        ld      a,1    ;b contains valid move
        ret

.continue
        inc     b
        ld      a,b
        cp      4
        jr      nz,.checkDirectionForFood

        jp      TrackEnemyVectorToState  ;no food around, track hero

SetupTrackEnemy:
        call    GetCurZone
        ld      b,a
        ;Use bit 5 of my object address to determine which hero
        ;to try and follow.
        ld      a,e
        swap    a
        and     %10    ;from %00 or %10 we get...
        ld      h,a
        rrca
        xor     %01
        or      h      ;%01 or %10
        call    GetHeroZone
        cp      b
        jr      z,.inSameZone

        call    SetDestZone
        ld      a,1
        call    SetState
        xor     a
        ret

.inSameZone
        ;ld      a,1    ;bit of slack
        xor     a       ;no slack
        jp      MoveToLocation

;return zero for no move
SetupMoveToLoc:
        call    GetActorDestLoc
        ld      a,h
        or      a
        jr      nz,.moveToLoc
        ;ret     z   ;no dest loc

        ;1/32 chance of face random direction
        ld      a,31
        call    GetRandomNumMask
        or      a
        jr      z,.faceRandom

        xor     a
        ret

.faceRandom
        call    GetFacing
        bit     2,a
        ret     nz         ;don't change dir if split
        and     %11111000
        ld      b,a
        ld      a,3
        call    GetRandomNumMask
        or      b
        call    SetFacing
        call    StandardRedraw
        xor     a
        ret

.moveToLoc
        push    hl
        call    GetCurZone
        pop     hl
        ld      b,a

        call    GetActorDestZone
        cp      b
        jr      z,.inSameZone

        call    SetDestZone
        ld      a,1
        call    SetState
        xor     a
        ret

.inSameZone
        call    GetActorDestLoc
        xor     a
        ld      [moveAlignPrecision],a
        call    AmAtLocation
        or      a
        jr      z,.findLocation

        ld      hl,0
        call    SetActorDestLoc

        ;call    GetFacing
        ;and     %11111011    ;set split bit to zero
        ;call    SetFacing

        xor     a

        ret

.findLocation
        xor     a     ;no slack
        ld      [moveAlignPrecision],a
        jp      MoveToLocation


MoveToZone:
        ;-------------------------------------------------------------
        ; State 1:  MOVE TOWARDS DEST ZONE
        ;           if (curZone == destZone){
        ;             this->state = 0;
        ;           }else{
        ;             nextWayPoint=GetNextWayPoint(curZone,destZone);
        ;             if(this->pos == nextWayPoint){
        ;               curPathPos++;
        ;             }else{
        ;               int r = ChooseDirection(nextWayPoint, &dir);
        ;               if(!r){
        ;                 this->moveLimit = 3;
        ;                 this->majorAxis = dir:7;
        ;                 this->state = 2;  //try to the right
        ;               }
        ;               return r;
        ;             }
        ;           }
        ;           return 0;
        ;-------------------------------------------------------------
        call    GetCurZone
        ld      b,a               ;save curZone
        call    GetDestZone

        ;if(curZone==destZone)
        cp      b
        jr      nz,.cur_NE_dest

        xor     a
        call    SetState
        xor     a
        ret

.cur_NE_dest
        swap    a
        or      b                 ;destZone in 7:4, curZone in 3:0
        call    GetNextWayPoint   ;returns next WP loc in hl
        xor     a
        cp      h
        jr      nz,.validWayPoint
        cp      l
        jr      nz,.validWayPoint

        ;invalid way point, try just moving towards hero w/dumb ai
        ;Use bit 5 of my object address to determine which hero
        ;to try and follow.
        ld      a,e
        swap    a
        and     %10    ;from %00 or %10 we get...
        ld      h,a
        rrca
        xor     %01
        or      h      ;%01 or %10
        call    GetHeroZone
        xor     a       ;no slack
        jp      MoveToLocation

.validWayPoint
        call    AmAtLocation
        or      a
        jr      z,.moveToLocation

        call    IncrementPathPos  ;at next waypoint, increment waypoint
        xor     a
        ret

.moveToLocation
        ld      a,1               ;cut some slack on alignment
MoveToLocation:
        ;use "dumb-AI" to move towards waypoint
        ;hl should be destination location
        call    ChooseDirection   ;args hl=curWP
                                  ;returns a=1 on success, b=dir
        or      a
        jr      z,.decideDirectionLeftOrRight

        ;success!
        ret

.decideDirectionLeftOrRight
        ld      a,b
        call    SetDesiredDirection
        ld      a,6
        call    SetMoveLimit
        call    GetMoveRightOfDesiredDir
        or      a
        jr      z,.tryLeft    ;try left if no exit to right

        ld      a,[secondChoiceDirection]
        cp      b
        jr      z,.tryRight   ;right matches our second choice

.tryLeft   ;try left then right
        ld      a,8
        call    SetState
        xor     a
        ret


.tryRight
        ;set critter to try along its right for a while
        ld      a,2
        call    SetState
        xor     a
        ret

TryRight:
        ;-------------------------------------------------------------
        ; State 2:  MOVE RIGHT TO LOOK FOR PASSAGE
        ;-------------------------------------------------------------
        call    GetMoveRightOfDesiredDir
        or      a
        jr      z,.changeState2To4  ;can't move right

        ;if move limit has expired switch to looking left
        call    DecrementMoveLimit
        or      a
        jr      z,.changeState2To4

.moveRightCheckForward
        ld      a,3                 ;check for forward passage next
        call    SetState
        ld      a,1
        ret

.changeState2To4
        ld      a,15
        call    SetMoveLimit
        ld      a,4
        call    SetState
        xor     a
        ret

TryFwdAfterRight:
        ;-------------------------------------------------------------
        ; State 3:  JUST MOVED RIGHT, CHECK FOR FORWARD PASSAGE
        ;-------------------------------------------------------------
        call    CheckForwardPassage
        or      a
        jr      nz,.changeState3ToState7

        ld      a,2
        call    SetState
        xor     a
        ret

.changeState3ToState7
        ;passage exists, MF twice (once to turn, once to move)
        ld      a,7
        call    SetState
        ld      a,1
        ret

TryLeft:
        ;-------------------------------------------------------------
        ; State 4:  MOVE LEFT CHECKING FOR FORWARD PROGRESS
        ;-------------------------------------------------------------
        call    GetMoveLeftOfDesiredDir
        or      a
        jr      z,.changeState4To6  ;can't move left, move random

        ;if move limit has expired switch to moving random
        call    DecrementMoveLimit
        or      a
        jr      z,.changeState4To6

        ld      a,5                 ;check for forward passage next
        call    SetState
        ld      a,1
        ret

.changeState4To6
ChangeToStateRandom:
        ld      a,15
        call    SetMoveLimit
        ld      a,6
        call    SetState
        xor     a
        ret

TryFwdAfterLeft:
        ;-------------------------------------------------------------
        ; State 5:  CHECK FORWARD AFTER HAVING MOVED LEFT
        ;-------------------------------------------------------------
        call    CheckForwardPassage
        or      a
        jr      nz,.changeState5ToState7

        ld      a,4
        call    SetState
        xor     a
        ret

.changeState5ToState7
        ;passage exists, MF twice (once now to turn, once to move)
        ld      a,7
        call    SetState
        ld      a,1
        ret

RandomMove:
        ;-------------------------------------------------------------
        ; State 6:  MOVE IN A RANDOM DIRECTION
        ;-------------------------------------------------------------
        call    GetRandomMovement

        call    DecrementMoveLimit
        or      a
        jr      z,.randomBackToState0
        ret

.randomBackToState0
        ;a is zero
        call    SetState
        ret

MoveFwdThenState1:
        ;-------------------------------------------------------------
        ; State 7:  Move Forward, Go to state 1
        ;-------------------------------------------------------------
        ld      a,1
        call    SetState
        call    CheckForwardPassage
        ret

TryLeftFirst:
        ;-------------------------------------------------------------
        ; State 8:  MOVE LEFT CHECKING FOR FORWARD PROGRESS
        ;-------------------------------------------------------------
        call    GetMoveLeftOfDesiredDir
        or      a
        jr      z,.changeState8To10  ;can't move left, move right

        ;if move limit has expired switch to looking right
        call    DecrementMoveLimit
        or      a
        jr      z,.changeState8To10

        ld      a,9                 ;check for forward passage next
        call    SetState
        ld      a,1
        ret

.changeState8To10
        ;look to the right
        ld      a,15
        call    SetMoveLimit
        ld      a,10
        call    SetState
        xor     a
        ret

TryFwdAfterLeftFirst:
        ;-------------------------------------------------------------
        ; State 9:  CHECK FORWARD AFTER HAVING MOVED LEFT
        ;-------------------------------------------------------------
        call    CheckForwardPassage
        or      a
        jr      nz,.changeState9ToState7

        ld      a,8       ;go back to checking left
        call    SetState
        xor     a
        ret

.changeState9ToState7
        ;passage exists, MF twice (once now to turn, once to move)
        ld      a,7
        call    SetState
        ld      a,1
        ret

TryRightSecond:
        ;-------------------------------------------------------------
        ; State 10:  MOVE RIGHT TO LOOK FOR PASSAGE
        ;-------------------------------------------------------------
        call    GetMoveRightOfDesiredDir
        or      a
        jr      z,.changeState10To6  ;can't move right, move random

        ;if move limit has expired switch to moving random
        call    DecrementMoveLimit
        or      a
        jr      z,.changeState10To6

.moveRightCheckForward
        ld      a,11                ;check for forward passage next
        call    SetState
        ld      a,1
        ret

.changeState10To6
        ld      a,15
        call    SetMoveLimit
        ld      a,6
        call    SetState
        xor     a
        ret

TryFwdAfterRightSecond:
        ;-------------------------------------------------------------
        ; State 11:  JUST MOVED RIGHT, CHECK FOR FORWARD PASSAGE
        ;-------------------------------------------------------------
        call    CheckForwardPassage
        or      a
        jr      nz,.changeState11ToState7

.keepGoing
        ld      a,10
        call    SetState
        xor     a
        ret

.changeState11ToState7
        ;passage exists, MF twice (once to turn, once to move)
        ld      a,7
        call    SetState
        ld      a,1
        ret

NoMove:
        ;-------------------------------------------------------------
        ; Default:  RETURN "NO MOVE"
        ;-------------------------------------------------------------
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      GetCurZone
; Arguments:    de  - "this"
; Returns:      a   - ID of current zone
;               hl  - current location
; Alters:       a, hl
;---------------------------------------------------------------------
GetCurZone::
        call    GetCurLocation

        ld      a,ZONEBANK        ;select zone RAM parallel to map ram
        ldio    [$ff70],a

        ld      a,[hl]            ;A is curZone
        and     $0f
        ret
;---------------------------------------------------------------------
; Routine:      GetHeroZone
; Arguments:    a   - prefer which hero?  1=Hero0, 2=Hero1, 0/3=Either
;               de  - "this"
; Returns:      a   - ID of zone hero is in
;               hl  - current location
; Alters:       a, hl
;---------------------------------------------------------------------
GetHeroZone:
        push    de

        ld      d,a
        ld      a,[heroesPresent]
        and     d
        jr      z,.pickFirstAvailable
        cp      3
        jr      c,.getChosenHero

.pickFirstAvailable
        ld      a,[heroesPresent]
        and     %01
        jr      nz,.getChosenHero

        ld      a,%10

.getChosenHero
        ;a has the valid, desired hero %10 or %01.
        ld      hl,hero0_object
        cp      %01                      ;do we want hero 0?
        jr      z,.haveHeroObjAddr

        ld      l,(hero1_object & $ff)   ;we want hero 1

.haveHeroObjAddr
        ;Load the Hero object
        ld      a,[hl+]       ;heroX_objectL
        ld      e,a
        ld      d,[hl]        ;heroX_objectH

        call    GetCurZone
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      GetState
; Arguments:    de  - "this"
; Returns:      a   - this->state
;               hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
GetState:
        ld      a,OBJBANK         ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_STATE
        add     hl,de
        ld      a,[hl]
        and     %00111111
        ret

;---------------------------------------------------------------------
; Routine:      SetState
; Arguments:    de  - "this"
;               a   - desired state
; Returns:      hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
SetState::
        push    bc

        and     %00111111
        ld      b,a

        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_STATE
        add     hl,de

        ld      a,[hl]            ;get old state
        and     %11000000
        or      b
        ld      [hl],a            ;save new state

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetAttackDirState
; Arguments:    de  - "this"
; Returns:      a   - 2-bit value[1:0] from this->state[7:6]
;               hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
GetAttackDirState:
        ld      a,OBJBANK         ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_STATE
        add     hl,de
        ld      a,[hl]

        rlca
        rlca
        and     %00000011
        ret

;---------------------------------------------------------------------
; Routine:      SetAttackDirState
; Arguments:    de  - "this"
;               a   - desired state (lower 2 bits)
; Returns:      hl  - &this->state
; Alters:       a, hl
; Description:  Sets the upper two bits of "state" to be the value
;               passed in.
;---------------------------------------------------------------------
SetAttackDirState:
        push    bc

        rrca
        rrca
        and     %11000000
        ld      b,a

        call    GetState
        or      b
        ld      [hl],a

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetDestZone
; Arguments:    de  - "this"
;               a   - desired dest zone
; Returns:      hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
SetDestZone:
        ld      hl,OBJ_DESTZONE   ;hl = &this->move
        add     hl,de

        push    af
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a
        ld      a,[hl]
        and     %00001111         ;mask off old zone
        ld      [hl],a
        pop     af
        swap    a                 ;destZone in 7:4
        or      [hl]              ;combine with move
        ld      [hl],a            ;save in move

        ret

;---------------------------------------------------------------------
; Routine:      GetDestZone
; Arguments:    de  - "this"
; Returns:      a   - dest zone
;               hl  - &this->destzone
; Alters:       a, hl
;---------------------------------------------------------------------
GetDestZone:
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_DESTZONE   ;hl = &this->destzone
        add     hl,de

        ld      a,[hl]            ;get this->destzone
        swap    a
        and     %00001111
        ret

;---------------------------------------------------------------------
; Routine:      GetPuffCount
; Arguments:    de  - "this"
; Returns:      a   - dest zone
;               hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
GetPuffCount::
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_DESTZONE   ;hl = &this->state
        add     hl,de

        ld      a,[hl]            ;get this->state
        and     %00001111
        ret

;---------------------------------------------------------------------
; Routine:      SetPuffCount
; Arguments:    a   - # of puffs
;               de  - "this"
; Returns:      a   - dest zone
;               hl  - &this->state
; Alters:       a, hl
;---------------------------------------------------------------------
SetPuffCount::
        push    bc
        ld      b,a
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_DESTZONE   ;hl = &this->state
        add     hl,de

        ld      a,[hl]
        and     %11110000
        or      b
        ld      [hl],a            ;get this->state
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetNextWayPoint
; Arguments:    de  - "this"
;               a   - curZone[7:4], destZone[3:0]
; Returns:      hl  - position of next waypoint
; Alters:       a, hl
; C Code:
;                int curPath = pathMatrix[curZone][destZone];
;                int curWPIndex  = pathList[curPath][this->pathPos];
;                int nextWayPoint = wayPointList[curWPIndex];
;               return nextWayPoint
;---------------------------------------------------------------------
GetNextWayPoint:
        push    bc

        ld      b,0
        ld      c,a               ;BC gets index to array

        call    GetPathPos
        push    de
        ld      d,0
        ld      e,a               ;E gets pathPos

        ld      a,WAYPOINTBANK    ;select object list RAM
        ld      [$ff70],a

        ld      hl,pathMatrix
        add     hl,bc
        ld      a,[hl]            ;A = curPath
        ld      c,a               ;Setup curPath*4 as offset into
        xor     a                 ;  pathlist
        sla     c
        rla
        sla     c
        rla
        ld      b,a               ;bc = curPath*4
        ld      hl,pathList
        add     hl,bc             ;hl = &pathList[curPath]
        add     hl,de             ;hl = &pathList[curPath][pathPos]
        ld      a,[hl]            ;a = curWPIndex
        ld      c,a               ;offset into WP list = curWPIndex*2
        xor     a
        sla     c
        rla
        ld      b,a               ;bc = offset
        ld      hl,wayPointList
        add     hl,bc
        ld      a,[hl+]           ;low byte of waypoint location
        ld      h,[hl]            ;high byte
        ld      l,a               ;hl is location of next waypoint

        pop     de

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetPathPos
; Arguments:    de  - "this"
; Returns:      a   - current path position (0-3)
;               hl  - &this->frame
; Alters:       a, hl
;---------------------------------------------------------------------
GetPathPos:
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_FRAME
        add     hl,de

        ld      a,[hl]            ;get frame var
        swap    a
        rrca
        and     %00000011         ;get pathPos in 1:0
        ret

;---------------------------------------------------------------------
; Routine:      AmAtLocation
; Arguments:    de  - "this"
;               hl  - a location
;               [moveAlignPrecision]
; Returns:      a   - 1 if this->loc == location, 0 if not
; Alters:       a
; Note:         Compares X,Y coordinates +/- [moveAlignPrecision]
;---------------------------------------------------------------------
AmAtLocation::
        push    bc
        push    de
        push    hl

        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ;not there if split bit is set
        call    GetFacing
        and     %100
        ld      a,0
        jr      nz,.done

        ;cur loc in bc
        ld      a,[de]            ;low byte of cur pos
        inc     de
        ld      c,a
        ld      a,[de]            ;high byte
        ld      b,a

        ;dest XY in de
        call    ConvertLocHLToXY
        ld      d,h
        ld      e,l

        ;cur XY in hl
        ld      h,b
        ld      l,c
        call    ConvertLocHLToXY

        ;compare sourceX to destX +/- 1
        ;ld      a,h
        ;add     1

        ld      a,[moveAlignPrecision]     ;x + precision
        add     h
        cp      d
        jr      c,.returnFalse

        ;sub     3
        ld      a,[moveAlignPrecision]     ;x - precision
        cpl
        add     1
        add     h
        cp      d
        jr      z,.checkY
        jr      nc,.returnFalse

.checkY
        ;compare sourceY to destY +/- 1
        ld      a,[moveAlignPrecision]     ;y + precision
        add     l
        cp      e
        jr      c,.returnFalse

        ld      a,[moveAlignPrecision]     ;y - precision
        cpl
        add     1
        add     l
        cp      e
        jr      z,.returnTrue
        jr      nc,.returnFalse

.returnTrue
        ld      a,1
        jr      .done

.returnFalse
        xor     a
.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      IsActorAtDest
; Arguments:    de  - "this"
; Returns:      a   - 1 if actor stopped moving, 0 if not
; Alters:       af
;---------------------------------------------------------------------
IsActorAtDest::
        push    hl
        call    GetActorDestLoc
        ld      a,h
        or      a
        jr      z,.returnTrue

        xor     a
        pop     hl
        ret

.returnTrue
        ld      a,1
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      ResetCurPathPos
; Arguments:    de  - "this"
; Returns:      Nothing
; Alters:       a,hl
; Description:  Sets curPathPos (bits 6:5 of this->frame) to zero
;---------------------------------------------------------------------
ResetCurPathPos:
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a

        ld      hl,OBJ_FRAME
        add     hl,de

        ld      a,[hl]
        and     %10011111
        ld      [hl],a

        ret


;---------------------------------------------------------------------
; Routine:      IncrementPathPos
; Arguments:    de  - "this"
; Returns:      Nothing
; Alters:       a,hl
; Description:  Adds 1 to bits 6:5 of this->frame, preserving others
;---------------------------------------------------------------------
IncrementPathPos:
        ld      a,OBJBANK         ;select object RAM
        ld      [$ff70],a
        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[hl]
        bit     7,a
        jr      nz,.bit7WasOne

        add     %00100000
        res     7,a
        ld      [hl],a
        ret

.bit7WasOne
        add     %00100000
        set     7,a
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      ChooseDirection
; Arguments:    [moveAlignPrecision] 0=go to exact spot, 1=+/-1
;               de  - "this"
;               hl  - location of destination
; Returns:      a   - 1 for valid move, 0 for no move
;               b   - direction of desired move (N,E,S,W)
; Alters:       a,b,hl
; Description:  Converts current "source" location and destination
;               location into x,y coordinates, then picks a direction
;               based on the following "dumb-AI" algorithm:
;
;               int order = GetDirectionAttemptOrder(sx,sy,dx,dy);
;               if(CheckDestEmpty(order[0]))
;                 { dir = order[0]; return 1;}
;               return 0;
;---------------------------------------------------------------------
ChooseDirection:
        push    bc
        push    de

        ld      [moveAlignPrecision],a

        call    ConvertLocHLToXY
        push    hl

        call    GetCurLocation ;into hl

        call    ConvertLocHLToXY
        ld      b,h
        ld      c,l
        pop     de             ;source in bc, dest in de

        call    GetDirectionAttemptOrder  ;check order in A

        pop     de             ;retrieve ptr to this

        ;check first direction
        rlca                   ;get first direction in 1:0
        rlca
        ld      c,a
        and     %00000011      ;mask off other choices
        ld      b,a
        xor     a
        call    CheckDestEmpty
        or      a              ;check result
        jr      z,.checkDir2

.foundDirection
        ld      a,b            ;setup b with direction, return 1
        pop     bc
        ld      b,a
        ld      a,1
        ret

.checkDir2
        ld      a,c
        rlca                   ;get second direction in 1:0
        rlca
        ld      c,a
        and     %00000011      ;mask off other choices
        ld      [secondChoiceDirection],a  ;save for left/right decision

        ;ld      b,a
        ;xor     a
        ;call    CheckDestEmpty
        ;or      a              ;check result
        ;jr      z,.checkDir3

        ;foundDirection
        ;ld      a,b            ;setup b with direction, return 1
        ;pop     bc
        ;ld      b,a
        ;ld      a,1
        ;ret

.checkDir3
        ;ld      a,c
        ;rlca                   ;get third direction in 1:0
        ;rlca
        ;ld      c,a
        ;and     %00000011      ;mask off other choices
        ;ld      b,a
        ;xor     a
        ;call    CheckDestEmpty
        ;or      a              ;check result
        ;jr      z,.checkDir4

        ;foundDirection
        ;ld      a,b            ;setup b with direction, return 1
        ;pop     bc
        ;ld      b,a
        ;ld      a,1
        ;ret

.checkDir4
        ;no direction found, load b with desired direction and return
        ;false
        ld      a,b
        pop     bc
        ld      b,a
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      GetDirectionAttemptOrder
; Arguments:    de  - x,y of destination
;               bc  - x,y of origin
; Returns:      a   - every two bits is a direction to attempt;
;                     [7:6] is the first direction and so on.
; Alters:       a,hl
; Description:  Based off the following formula:
;
;               if(sx>=dx-2){
;                 if(sy < dy) order = SWEN;
;                 else        order = NEWS;
;               }else if(sy==dy){
;                 if(sx < dx) order = ESNW;
;                 else        order = WNSE;
;               }else{
;                 offset_x = abs(sx - dx);
;                 offset_y = abs(sy - dy);
;                 if(offset_x < offset_y){  //close horizontal gap
;                   if(sx < dx){
;                     if(sy < dy) order = ESWN;
;                     else        order = ENWS;
;                   }else{
;                     if(sy < dy) order = WSEN;
;                     else        order = WNES;
;                   }
;                 }else{  //close vertical gap first
;                   if(sx < dx){
;                     if(sy < dy) order = SENW;
;                     else        order = NESW;
;                   }else{
;                     if(sy < dy) order = SWNE;
;                     else        order = NWSE;
;                   }
;                 }
;               }
;
;  Note:        precision of "cur==dest" depends on current value
;               stored in [moveAlignPrecision], e.g. value of 1 yields
;               cur>=(dest-1) && cur<=(dest+1)
;               e.g. (cur+1)>=dest && (cur-1)<=dest
;---------------------------------------------------------------------
GetDirectionAttemptOrder:
IF 0
        ;if abs(dx-sx) <= 1 and abs(dy-sY)<=1 then set tolerance to
        ;zero.  dx-sx yields $ff, 0, or 1 - plus one gives 0, 1, or 2
        ld      h,3
        ld      a,b
        sub     d
        cp      h
        jr      nc,.afterSetAlignPrecision

        ld      a,c
        sub     e
        cp      h
        jr      nc,.afterSetAlignPrecision

        xor     a
        ld      [moveAlignPrecision],a

.afterSetAlignPrecision
ENDC
        ld      h,0

        ld      a,[moveAlignPrecision]
        add     b
        ;ld      a,b
        ;add     1
        cp      d
        jr      c,.sx_LessThan_dx

        ld      a,[moveAlignPrecision]
        cpl
        add     1
        add     b
        cp      d
        jr      c,.sx_Equals_dx
        jr      z,.sx_Equals_dx

        ;sx > dx
        jr      .checkYCoords

.sx_Equals_dx
        set     3,h
        jr      .checkYCoords

.sx_LessThan_dx
        set     1,h

.checkYCoords
        ;ld      a,c
        ;add     1
        ld      a,[moveAlignPrecision]
        add     c
        cp      e
        jr      c,.sy_LessThan_dy

        ld      a,[moveAlignPrecision]
        cpl
        add     1
        add     c
        ;sub     3
        cp      e
        jr      c,.sy_Equals_dy
        jr      z,.sy_Equals_dy

        ;sy>dy
        jr      .checkOffsets

.sy_Equals_dy
        set     2,h
        jr      .pickOrder

.sy_LessThan_dy
        set     0,h

.checkOffsets
        bit     3,h
        jr      nz,.pickOrder

        ;set bit 4 if abs(sx-dx) < abs(sy-dy)
        ld      a,b
        cp      d                 ;is sx < dx?
        jr      c,.subtract_sx_from_dx

        sub     d
        jr      .getAbsY

.subtract_sx_from_dx
        ld      a,d
        sub     b

.getAbsY
        ld      l,a               ;save abs(sx-dx) in l
        ld      a,c
        cp      e
        jr      c,.subtract_sy_from_dy

        sub     e
        jr      .haveAbsValues

.subtract_sy_from_dy
        ld      a,e
        sub     c

.haveAbsValues
        cp      l                 ;is abs(sy-dy) < abs(sx-dx)?
        jr      nc,.pickOrder     ;no, leave bit 4 alone

        set     4,h

.pickOrder
        ld      a,h
        add     (.orderTable & $ff)
        ld      l,a
        ld      a,0               ;not xoring to leave the carry alone
        adc     ((.orderTable >> 8) & $ff)
        ld      h,a      ;hl is &orderTable[directionFlags]
        ld      a,[hl]
        ret

.orderTable
        ;first half of table is for closing x-distance first
        DB %11000110    ;WNES    0000  sx > dx, sy > dy
        DB %11100100    ;WSEN    0001  sx > dx, sy < dy
        DB %01001101    ;ENWS    0010  sx < dx, sy > dy
        DB %01101100    ;ESWN    0011  sx < dx, sy < dy
        DB %11100001    ;WSNE    0100  sy==dy, sx > dx
        DB %11100001    ;WSNE    0101  sy==dy, sx > dx  (invalid)
        DB %01001011    ;ENSW    0110  sy==dy, sx < dx
        DB %01001011    ;ENSW    0111  sy==dy, sx < dx  (invalid)
        DB %00011110    ;NEWS    1000  sx==dx, sy > dy
        DB %10110100    ;SWEN    1001  sx==dx, sy < dy
        DB %00011110    ;NEWS    1010  sx==dx, sy > dy  (invalid)
        DB %10110100    ;SWEN    1011  sx==dx, sy < dy  (invalid)
        DB %00011110    ;NEWS    1100  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1101  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1110  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1111  sx==dx, sy==dy   (invalid)

        ;second half of table is for closing y-distance first
        DB %00111001    ;NWSE    0000  sx > dx, sy > dy
        DB %10110001    ;SWNE    0001  sx > dx, sy < dy
        DB %00011011    ;NESW    0010  sx < dx, sy > dy
        DB %10010011    ;SENW    0011  sx < dx, sy < dy
        DB %10110100    ;SWEN    0100  sy==dy, sx > dx
        DB %10110100    ;SWEN    0101  sy==dy, sx > dx  (invalid)
        DB %00011110    ;NEWS    0110  sy==dy, sx < dx
        DB %00011110    ;NEWS    0111  sy==dy, sx < dx  (invalid)
        DB %01001011    ;ENSW    1000  sx==dx, sy > dy
        DB %11100001    ;WSNE    1001  sx==dx, sy < dy
        DB %01001011    ;ENSW    1010  sx==dx, sy > dy  (invalid)
        DB %11100001    ;WSNE    1011  sx==dx, sy < dy  (invalid)
        DB %00011110    ;NEWS    1100  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1101  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1110  sx==dx, sy==dy   (invalid)
        DB %00011110    ;NEWS    1111  sx==dx, sy==dy   (invalid)

;---------------------------------------------------------------------
; Routine:      SetDesiredDirection
; Arguments:    a   - (0-3) - direction critter was trying to travel
;                     when it ran into a wall.
; Returns:      Nothing
; Alters:       a,hl
; Description:  Sets bits 7:6 of this->health to be value passed in
;---------------------------------------------------------------------
SetDesiredDirection:
        push    bc

        rrca
        rrca
        and     %11000000
        ld      b,a

        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]
        and     %00111111
        or      b
        ld      [hl],a
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      SetMoveLimit / SetFireDirection
; Arguments:    a   - move limit 0-15
; Returns:      Nothing
; Alters:       a,hl
; Description:  Sets bits 3:0 of the obj->misc to indicate how many
;               moves should be made before changing to a new state
;---------------------------------------------------------------------
SetMoveLimit:
SetFireDirection:
        push    bc
        ld      b,a
        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_LIMIT
        add     hl,de
        ld      a,[hl]
        and     %11110000
        or      b
        ld      [hl],a
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetMoveLimit / GetFireDirection
; Returns:      a - value
; Alters:       a,hl
; Description:  Retrieves bits 3:0 of the obj->limit
;---------------------------------------------------------------------
GetMoveLimit:
GetFireDirection:
        ld      a,OBJBANK      ;select object RAM
        ldio    [$ff70],a
        ld      hl,OBJ_LIMIT
        add     hl,de
        ld      a,[hl]
        and     %00001111
        ret

;---------------------------------------------------------------------
; Routine:      PointToSpecialFlags
; Arguments:    de - this
; Returns:      Nothing.
; Alters:       a,hl
; Description:  Sets HL to point to obj->limit.
;---------------------------------------------------------------------
PointToSpecialFlags:
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      hl,OBJ_LIMIT
        add     hl,de
        ret

;---------------------------------------------------------------------
; Routines:     GetMoveRightOfDesiredDir
;               GetMoveLeftOfDesiredDir
; Arguments:    None.
; Returns:      a - 0=no move, 1=move
;               b - direction of move if move possible
; Alters:       a,b,hl
; Description:  Uses the value of this->desiredDirection to determine the
;               direction to move right of the major axis.  If that
;               move is possible, returns 1 and the direction in b.
;---------------------------------------------------------------------
GetMoveRightOfDesiredDir:
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]

        rlca
        rlca
        inc     a               ;"turn" right
        and     %00000011
        ld      b,a
        xor     a
        call    CheckDestEmpty
        ret

GetMoveLeftOfDesiredDir:
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]

        rlca
        rlca
        dec     a               ;"turn" left
        and     %00000011
        ld      b,a
        xor     a
        call    CheckDestEmpty
        ret

;---------------------------------------------------------------------
; Routines:     CheckForwardPassage
; Arguments:    None.
; Returns:      a - 0=no move, 1=move
;               b - direction of move if move possible
; Alters:       a,hl
; Description:  Uses the value of this->desiredDirection along with
;               current facing to determine the direction to move
;               forward.
; Note:         Returns zero if the creature is split between
;               tiles (this->frame:2 == 1)
;---------------------------------------------------------------------
CheckForwardPassage:
        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_FRAME
        add     hl,de

        ;check for split tile first
        ld      a,[hl+]
        and     %00000100
        jr      z,.continue

        xor     a
        ret

.continue
        inc     hl           ;state to misc
        inc     hl           ;misc to health
        ld      a,[hl]       ;get health byte

        rlca                 ;bits 7:6 have desired dir
        rlca
        and     %00000011
        ld      b,a
        xor     a
        call    CheckDestEmpty
        ret

;---------------------------------------------------------------------
; Routines:     DecrementMoveLimit
; Arguments:    None.
; Returns:      a - moves left = non-zero, no moves = 0
; Alters:       a,hl
; Description:  Decrements bits 3:0 of this->misc
;               Does not decrement if split across tiles
;---------------------------------------------------------------------
DecrementMoveLimit:
        push    bc

        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME
        add     hl,de

        ld      a,[hl+]             ;check for split tiles
        and     %00000100
        jr      z,.continue

        pop     bc
        ld      a,1
        ret

.continue
        inc     hl
        ld      a,[hl]
        ld      c,a
        and     %11110000
        ld      b,a
        ld      a,c
        dec     a
        and     %00001111
        or      b
        ld      [hl],a
        and     %00001111           ;set a to be zero/nonzero

        pop     bc
        ret

BAInit:
        push    bc
        push    de
        ld      a,OBJBANK        ;select object RAM
        ld      bc,8
        inc     de
        inc     de
        ld      hl,.baInitTable
        call    MemCopy
        pop     de
        pop     bc

        ;setup baUpgrades
        push    bc
        ld      hl,baUpgrades
        ld      [hl],0
        ld      bc,ITEM_BAHIGHIMPACT
        call    HasInventoryItem
        jr      z,.afterSetHighImpactBullets
        set     UPGRADE_BAHIGHIMPACT,[hl]
.afterSetHighImpactBullets
        pop     bc

        ;Load BA's bullet-type
        call    SaveFGTileInfo
        ld      a,HERO_BA_FLAG
        call    SetHeroTileSet

        ld      de,classBABullet
        ld      hl,BABULLET_CINDEX
        xor     a
        call    LoadAssociatedClass
        call    GetAssociated
        ld      b,a
        ld      a,HERO_BA_FLAG
        call    SetHeroBulletIndex

        call    RestoreFGTileInfo
.done
        ret

.baInitTable
  DB 1,1,$0f,BA_MAX_HEALTH,0,0,0,GROUP_HERO

BAPlayerCheck:
        ld      b,BA_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.noDirPressed
        ;xor     a
        ;call    SetMisc

.checkButtons
        call    DecrementAttackDelay
        or      a
        jr      z,.done

        ;ld      a,HERO_BA_FLAG
        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        call    GetFireDirection
        ld      b,a
        cp      4
        jr      nc,.noStrafe    ;button not held down previously

.strafeCheckSplit
        ;can only fire if not split frame or firing perpendicular
        call    GetFacing
        bit     2,a
        jr      z,.gotFireDirection
        xor     b
        bit     0,a    ;bit zero = 0 if parallel direction
        jr      z,.gotFireDirection
        jr      .forceMoveForward    ;can't fire

.noStrafe
        call    GetFacing
        and     %00000011
        ld      b,a
        call    SetFireDirection

.gotFireDirection
        ld      a,b
        call    GetLocInFront
        push    bc
        push    af
        push    hl
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        ld      hl,baFireSound
IF UPGRADES
        ld      a,4               ;four points of damage
ELSE
        ld      a,2               ;two points of damage
ENDC
        call    StdFireBullet
        ld      a,22
        call    SetAttackDelay

        pop     hl
        pop     af

        ld      b,a
        ldio    a,[firstMonster]
        cp      b
        pop     bc
        jr      z,.checkUpgrade
        jr      nc,.afterThrowMonster

.checkUpgrade
        ld      a,[baUpgrades]
        bit     UPGRADE_BAHIGHIMPACT,a
        jr      z,.afterThrowMonster

        call    ThrowObjAtHLInDirB

.afterThrowMonster
        jr      .checkButtonB

.forceMoveForward
        call    GetHeroMoved
        ;ld      a,[baMoved]
        or      a
        jr      nz,.checkButtonB
        call    GetFacing
        and     %00000011
        ld      b,a
        call    PlayerValidateMoveAndRedraw

.checkButtonB
.done
        ret

BAPlayerCheckSpace:
        ld      b,BA_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        ;can only move if in different direction than facing
        ;and not opposite to fire direction
        call    GetFacing
        and     %11
        cp      b
        jr      z,.checkButtons

        call    GetFireDirection
        cp      4
        jr      nc,.move

        add     2
        and     %11
        cp      b
        jr      z,.checkButtons

.move
        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.noDirPressed
        ;xor     a
        ;call    SetMisc

.checkButtons
        call    DecrementAttackDelay
        or      a
        jp      z,.done

        ;ld      a,HERO_BA_FLAG
        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jp      z,.checkButtonB

        call    GetFireDirection
        ld      b,a
        cp      4
        jr      nc,.noStrafe    ;button not held down previously

.strafeCheckSplit
        ;can only fire if not split frame or firing perpendicular
        call    GetFacing
        bit     2,a
        jr      z,.gotFireDirection
        xor     b
        bit     0,a    ;bit zero = 0 if parallel direction
        jr      z,.gotFireDirection
        jr      .forceMoveForward    ;can't fire

.noStrafe
        call    GetFacing
        and     %00000011
        ld      b,a
        call    SetFireDirection

.gotFireDirection
        ld      a,b
        call    GetLocInFront
        push    bc
        push    af
        push    hl
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        ld      hl,baFireSound
IF UPGRADES
        ld      a,4               ;four points of damage
ELSE
        ld      a,2               ;two points of damage
ENDC
        call    StdFireBullet
        ld      a,22
        call    SetAttackDelay

        ;reverse fire direction for travel direction
        call    GetFacing
        and     %11
        push    af

        call    GetCurLocation
        ld      a,b
        add     2
        and     %11
        push    af
        call    ShiftObjectInDirection
        call    GetCurLocation
        pop     af
        push    af
        call    ShiftObjectInDirection
        call    GetCurLocation
        pop     af
        call    ShiftObjectInDirection

        call    GetFacing
        and     %11111100
        ld      b,a
        pop     af
        or      b
        call    SetFacing
        call    StandardRedrawNoCheckSprite

        pop     hl
        pop     af

        ld      b,a
        ldio    a,[firstMonster]
        cp      b
        pop     bc
        jr      z,.checkUpgrade
        jr      nc,.afterThrowMonster

.checkUpgrade
        ld      a,[baUpgrades]
        bit     UPGRADE_BAHIGHIMPACT,a
        jr      z,.afterThrowMonster

        call    ThrowObjAtHLInDirB

.afterThrowMonster
        jr      .checkButtonB

.forceMoveForward
        call    GetHeroMoved
        ;ld      a,[baMoved]
        or      a
        jr      nz,.checkButtonB
        call    GetFacing
        and     %00000011
        ld      b,a
        call    PlayerValidateMoveAndRedraw

.checkButtonB
.done
        ret

IF 0
BAPlayerCheck:
        ld      b,BA_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.checkButtons
        call    DecrementAttackDelay
        or      a
        jr      z,.done

        ;ld      a,HERO_BA_FLAG
        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        ret     z

        call    HeroSetupFireDirection
        ret     z

        ld      a,b
        call    GetLocInFront

        push    bc
        push    af
        push    hl

        ld      hl,baFireSound
IF UPGRADES
        ld      a,4               ;four points of damage
ELSE
        ld      a,2               ;two points of damage
ENDC
        call    StdFireBullet
        ld      a,22
        call    SetAttackDelay

        pop     hl
        pop     af

        jr      BAThrowMonster
.done
        ret

BAThrowMonster:
        ld      b,a
        ldio    a,[firstMonster]
        cp      b
        pop     bc
        jr      z,.checkUpgrade
        ret     nc

.checkUpgrade
        ld      a,[baUpgrades]
        bit     UPGRADE_BAHIGHIMPACT,a
        ret     z

        call    ThrowObjAtHLInDirB
        ret
ENDC

;---------------------------------------------------------------------
; Routine:      SetHeroBulletIndex
; Arguments:    a  - flag of hero (e.g. HERO_BA_FLAG)
;               b  - bullet index of hero
; Returns:      Nothing.
; Alters:       af
; Description:  Stores the bullet index in the appropriate
;               hero0_bullet_index or hero1_bullet_index.
;---------------------------------------------------------------------
SetHeroBulletIndex:
        push    hl
        ld      hl,heroJoyIndex
        and     [hl]
        ld      a,b
        jr      nz,.useIndex1  ;note flags are still from AND

.useIndex0
        ld      [hero0_bullet_index],a
        jr      .done

.useIndex1
        ld      [hero1_bullet_index],a

.done
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetHeroTileSet
; Arguments:    a  - flag of hero (e.g. HERO_BA_FLAG)
; Returns:      Nothing.
; Alters:       af
; Description:  Sets [numFGTiles] to be either 6 or 26 depending on
;               who's controlling the hero.  Note that the original
;               value of [numFGTiles] must be saved and restored
;               separately.  Also sets [fgDestPtr] and [numClasses]
;---------------------------------------------------------------------
SetHeroTileSet:
        push    bc
        push    de
        push    hl

        ld      hl,heroJoyIndex
        and     [hl]
        jr      nz,.secondTileSet
        ld      a,6
        ld      bc,$9060
        ld      d,1
        jr      .pickedTileSet
.secondTileSet
        ld      a,26
        ld      bc,$91a0
        ld      d,3
.pickedTileSet
        ld      [numFGTiles],a
        ld      a,c
        ld      [fgDestPtr],a
        ld      a,b
        ld      [fgDestPtr+1],a
        ld      a,[firstHero]
        add     d
        ld      [numClasses],a

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetHeroJoyInput
; Arguments:    c  - hero class index
; Returns:      a  - current input from [curJoy0] or [curJoy1]
; Alters:       af
;---------------------------------------------------------------------
GetHeroJoyInput:
        ld      a,[hero0_index]
        cp      c
        jr      nz,.useIndex1
        ld      a,[curJoy0]
        ret

.useIndex1
        ld      a,[curJoy1]
        ret

GetAssocJoyInput:
        call    GetAssociated
        push    bc
        ld      b,a
        ld      a,[hero0_index]
        cp      b
        pop     bc
        jr      nz,.useIndex1
        ld      a,[curJoy0]
        ret

.useIndex1
        ld      a,[curJoy1]
        ret


;---------------------------------------------------------------------
; Routine:      SetHeroMoved
; Arguments:    a  - value to set to (1 or 0)
;               c  - class index of current hero
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
SetHeroMoved:
        push    af
        ld      a,[hero0_index]
        cp      c
        jr      nz,.useIndex1
        pop     af
        ld      [hero0_moved],a
        ret

.useIndex1
        pop     af
        ld      [hero1_moved],a
        ret

;---------------------------------------------------------------------
; Routine:      GetHeroMoved
; Arguments:    c  - class index of current hero
; Returns:      a  - "moved" value
; Alters:       af
;---------------------------------------------------------------------
GetHeroMoved:
        ld      a,[hero0_index]
        cp      c
        jr      nz,.useIndex1
        ld      a,[hero0_moved]
        ret

.useIndex1
        ld      a,[hero1_moved]
        ret

;---------------------------------------------------------------------
; BS
;---------------------------------------------------------------------
BSInit:
        push    bc
        push    de
        push    hl

        push    bc
        push    de
        ld      a,OBJBANK        ;select object RAM
        ld      bc,8
        inc     de
        inc     de
        ld      hl,.bsInitTable
        call    MemCopy
        pop     de
        pop     bc


        ;setup bsUpgrades
        push    bc
        ld      hl,bsUpgrades
        ld      [hl],0
        ld      bc,ITEM_BSSHOOTFAST
        call    HasInventoryItem
        jr      z,.afterSetShootFast
        set     UPGRADE_BSSHOOTFAST,[hl]
.afterSetShootFast
        pop     bc

        ;Load BS's bullet-type
        call    SaveFGTileInfo
        ld      a,HERO_BS_FLAG
        call    SetHeroTileSet

        ld      de,classBSBullet
        ld      hl,BSBULLET_CINDEX
        xor     a
        call    LoadAssociatedClass
        call    GetAssociated
        ld      b,a
        ld      a,HERO_BS_FLAG
        call    SetHeroBulletIndex

        call    RestoreFGTileInfo

        pop     hl
        pop     de
        pop     bc
        ret

.bsInitTable
  DB 1,1,$0f,BS_MAX_HEALTH,0,0,0,GROUP_HERO

BSPlayerCheck:
        ld      b,BS_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.checkButtons
        call    HeroCheckCanFire
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        call    HeroSetupFireDirection
        jr      z,.checkButtonB

        ld      hl,bsFireSound
        ld      a,1               ;one point of damage
        call    StdFireBullet
        ld      a,[bsUpgrades]
        bit     UPGRADE_BSSHOOTFAST,a
        jr      z,.shootSlow
.shootFast
        ld      a,10
        jr      .setAttackD
.shootSlow
        ld      a,18
.setAttackD
        call    SetAttackDelay
        jr      .checkButtonB

.checkButtonB
.done
        ret

BSPlayerCheckSpace:
        ld      b,BS_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        ;can only move if in different direction than facing
        ;and not opposite to fire direction
        call    GetFacing
        and     %11
        cp      b
        jr      z,.checkButtons

        call    GetFireDirection
        cp      4
        jr      nc,.move

        add     2
        and     %11
        cp      b
        jr      z,.checkButtons

.move
        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.checkButtons
        call    HeroCheckCanFire
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        call    HeroSetupFireDirection
        jr      z,.checkButtonB

        ld      hl,bsFireSound
        ld      a,1               ;one point of damage
        call    StdFireBullet
        ld      a,[bsUpgrades]
        bit     UPGRADE_BSSHOOTFAST,a
        jr      z,.shootSlow
.shootFast
        ld      a,10
        jr      .setAttackD
.shootSlow
        ld      a,18
.setAttackD
        call    SetAttackDelay

        ;reverse fire direction for travel direction
        call    GetFacing
        and     %11
        push    af

        call    GetCurLocation
        ld      a,b
        add     2
        and     %11
        push    af
        call    ShiftObjectInDirection
        call    GetCurLocation
        pop     af
        push    af
        call    ShiftObjectInDirection
        call    GetCurLocation
        pop     af
        call    ShiftObjectInDirection

        call    GetFacing
        and     %11111100
        ld      b,a
        pop     af
        or      b
        call    SetFacing
        call    StandardRedrawNoCheckSprite

        ;call    ThrowObjAtHLInDirB

        jr      .checkButtonB

.checkButtonB
.done
        ret

HeroCheckCanFire:
        call    DecrementAttackDelay
        or      a
        ret     z

        call    GetAssociated   ;has a gun?
        or      a
        ret

HeroSetupFireDirection:
        call    GetFireDirection
        ld      b,a
        cp      4
        jr      nc,.noStrafe    ;button not held down previously

.strafeCheckSplit
        ;can only fire if not split frame or firing perpendicular
        call    GetFacing
        bit     2,a
        jr      z,.gotFireDirection
        xor     b
        bit     0,a    ;bit zero = 0 if parallel direction
        jr      z,.gotFireDirection
        jr      .forceMoveForward    ;can't fire

.noStrafe
        call    GetFacing
        and     %00000011
        ld      b,a
        call    SetFireDirection

.gotFireDirection
        ld      a,b
        call    GetLocInFront
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        or      a
        ret

.forceMoveForward
        call    GetHeroMoved
        or      a
        jr      nz,.done
        call    GetFacing
        and     %00000011
        ld      b,a
        call    PlayerValidateMoveAndRedraw
.done
        xor     a
        ret


;---------------------------------------------------------------------
; HAIKU
;---------------------------------------------------------------------
HaikuInit:
        ld      a,OBJBANK        ;select object RAM
        ld      bc,8
        inc     de
        inc     de
        ld      hl,.haikuInitTable
        call    MemCopy
        ret

.haikuInitTable
  DB 3,1,$0f,HAIKU_MAX_HEALTH,0,0,0,GROUP_HERO

HaikuPlayerCheck:
        ;am I dead?
        ld      b,HAIKU_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw
        or      a
        jr      z,.checkButtons

        call    GetHeroJoyInput  ;no attack if braking
        bit     JOY_B_BIT,a
        jr      nz,.checkButtons

        call    HaikuHitObject

.checkButtons
        call    DecrementAttackDelay
        or      a
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        ;clip to edges of map
;and (JOY_DOWN | JOY_A)
;cp (JOY_DOWN | JOY_A)
;jr nz,.skip
;ld b,b
;.skip
        call    GetFacing
        and     %11
        ld      b,a
        call    AmAtEdgeInDirection
        jr      nz,.checkButtonB

        call    GetFacing
        and     %00000011
        ld      b,a
        call    GetLocInFront
        ld      a,b
        call    AdvanceLocHLInDirection

        call    LocIsPassable
        jr      z,.checkButtonB

        ;haiku teleports two squares ahead
        call    GetFacing
        push    af
        push    bc
        ld      c,a
        call    RemoveFromMap
        pop     bc
        call    SetCurLocation
        pop     af

        push    hl
        res     2,a              ;turn off split
        bit     7,a              ;sprite?
        jr      z,.afterFreeSprite
        push    af
        call    FreeSpriteLoPtr
        pop     af
        res     7,a
.afterFreeSprite
        call    SetFacing
        pop     hl

        ;----BEGIN call MOVEOVER method
        push    bc

        ld      a,[bgFlags]
        ld      b,a
        push    af

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]

        push    af
        ld      a,b
        bit     BG_BIT_WALKOVER,a
        jr      z,.afterSetSpriteBit
        call    GetFacing
        set     7,a
        call    SetFacing
.afterSetSpriteBit
        call    StandardRedrawNoCheckSprite
        pop     af

        ld      c,a
        pop     af
        bit     BG_BIT_WALKOVER,a
        jr      z,.afterAction
        ld      a,BGACTION_MOVEOVER
        call    CallBGAction
.afterAction

        pop     bc
        ;----END call MOVEOVER method

        ld      a,15
        call    SetAttackDelay
        jr      .checkButtonB

.forceMoveForward
.checkButtonB
.done
        ret

HaikuPlayerCheckSpace:
        ;am I dead?
        ld      b,HAIKU_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        ;can only move if in different direction than facing
        ;or object in front
        ld      a,4
        call    GetLocInFront
        or      a
        jr      nz,.move

        call    GetFacing
        and     %11
        cp      b
        jr      z,.checkButtons

.move
        call    PlayerValidateMoveAndRedraw
        or      a
        jr      z,.checkButtons

        call    GetHeroJoyInput  ;no attack if braking
        bit     JOY_B_BIT,a
        jr      nz,.checkButtons

        call    HaikuHitObject

.checkButtons
        call    DecrementAttackDelay
        or      a
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        ;clip to edges of map
        call    GetFacing
        and     %11
        ld      b,a
        call    AmAtEdgeInDirection
        jr      nz,.checkButtonB

        call    GetFacing
        and     %00000011
        ld      b,a
        call    GetLocInFront
        ld      a,b
        call    AdvanceLocHLInDirection

        call    LocIsPassable
        jr      z,.checkButtonB

        ;haiku teleports two squares ahead
        call    GetFacing
        push    af
        push    bc
        ld      c,a
        call    RemoveFromMap
        pop     bc
        call    SetCurLocation
        pop     af

        push    hl
        res     2,a              ;turn off split
        bit     7,a              ;sprite?
        jr      z,.afterFreeSprite
        push    af
        call    FreeSpriteLoPtr
        pop     af
        res     7,a
.afterFreeSprite
        call    SetFacing
        pop     hl

        ;----BEGIN call MOVEOVER method
        push    bc

        ld      a,[bgFlags]
        ld      b,a
        push    af

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]

        push    af
        ld      a,b
        bit     BG_BIT_WALKOVER,a
        jr      z,.afterSetSpriteBit
        call    GetFacing
        set     7,a
        call    SetFacing
.afterSetSpriteBit
        call    StandardRedrawNoCheckSprite
        pop     af

        ld      c,a
        pop     af
        bit     BG_BIT_WALKOVER,a
        jr      z,.afterAction
        ld      a,BGACTION_MOVEOVER
        call    CallBGAction
.afterAction

        pop     bc
        ;----END call MOVEOVER method

        ld      a,15
        call    SetAttackDelay
        jr      .checkButtonB

.forceMoveForward
.checkButtonB
.done
        ret

HaikuHitObject:
        ;attack forward
        call    GetFacing
        and     %00000011
        ld      b,a
        ld      [fireBulletDirection],a
        ld      a,4
        call    GetLocInFront
        ld      a,MAPBANK
        ldio    [$ff70],a

        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[hl]
        cp      b
        jr      nc,.hitMonster

.hitAttackableWall
        call    HitWall
        jr      .afterHit

.hitMonster
        ld      b,a           ;index of monster being hit

        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        ld      a,1               ;one point of damage
        ld      [methodParamL],a

        ldio    a,[curObjWidthHeight]
        push    af
        ld      a,[fireBulletDirection]
        call    HitObject
        pop     af
        ldio    [curObjWidthHeight],a

.afterHit
        ld      hl,haikuSound
        call    PlaySound
        ld      a,15
        call    SetAttackDelay
        call    GetFacing
        ld      h,a
        add     2
        and     %00000011
        ld      l,a
        ld      a,h
        and     %11111100
        or      l
        call    SetFacing
        push    bc
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        pop     bc
        call    StandardRedrawNoCheckSprite  ;turn around
        ret

HaikuTakeDamage:
        push    bc
        push    hl

        ;store object palette color to be the explosion color later
        call    GetFGAttributes
        and     %111
        ld      [bulletColor],a

        ;take damage only if I'm not facing bullet
        call    GetFacing
        add     2
        and     %11
        ld      hl,bulletDirection    ;was fireBulletDirection
        cp      [hl]
        jr      nz,.notFacingBullet

        ;take no damage
        xor     a
        pop     hl
        pop     bc
        ret

.notFacingBullet
        ld      a,OBJBANK
        ld      [$ff70],a

        ;play the explosion sound effect
        ld      hl,stdExplosionSound
        call    PlaySound

        ;blow off a puff instead of taking damage?
        ld      hl,OBJ_DESTZONE
        add     hl,de
        ld      a,[hl]
        and     %1111
        jr      z,.noPuffs

        dec     [hl]
        ld      b,METHOD_DRAW
        call    CallMethod
        ld      b,1
        jr      .done

.noPuffs
        ld      a,[methodParamL]
        ld      c,a                   ;c is damage

        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]
        ;ld      b,a
        ld      b,0
        and     %00111111
        jr      z,.done            ;already dead
        ld      b,c                ;b is damage inflicted
        sub     c
        jr      nc,.notNegative

        add     c                  ;original health
        ld      b,a                ;is damage inflicted
        xor     a                  ;less than zero is zero
.notNegative
        ld      c,a
        ld      a,[hl]
        ;ld      a,b
        and     %11000000
        or      c
        ld      [hl],a

.done
        ld      a,b      ;return damage inflicted
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Hero Lady Flower
;---------------------------------------------------------------------
LadyInit:
        ;initialize object
        push    bc
        push    de
        ld      a,OBJBANK        ;select object RAM
        ld      bc,8
        inc     de
        inc     de
        ld      hl,.ladyInitTable
        call    MemCopy
        pop     de
        pop     bc

        ;Load Lady's bullet-type
        push    bc
        push    de
        call    SaveFGTileInfo
        ld      a,HERO_FLOWER_FLAG
        call    SetHeroTileSet

        ld      de,classLadyBullet
        ld      hl,LADY_BULLET_CINDEX
        xor     a
        call    LoadAssociatedClass
        call    GetAssociated
        ld      b,a
        ld      a,HERO_FLOWER_FLAG
        call    SetHeroBulletIndex

        call    RestoreFGTileInfo

        pop     de
        pop     bc

        ret

.ladyInitTable
  DB 1,1,$0f,LADY_MAX_HEALTH,0,0,0,GROUP_HERO

LadyPlayerCheck:
        ld      b,LADY_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    LadyGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

        ld      a,1
        call    SetHeroMoved

.checkButtons
        call    HeroCheckCanFire
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.checkButtonB

        call    HeroSetupFireDirection
        jr      z,.checkButtonB

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]     ;way obstructed?
        or      a
        jr      nz,.checkShootOver

        ld      a,[numFreeObjects]
        cp      200
        jr      c,.done

.checkShootOver ;don't shoot on shootover-only tiles
        ldio    a,[firstMonster]
        push    bc
        ld      b,a
        ld      a,[hl]
        cp      b
        pop     bc
        jr      nc,.fire

        call    GetBGAttributes
        bit     BG_BIT_WALKOVER,a
        jr      nz,.fire
        bit     BG_BIT_SHOOTOVER,a
        jr      nz,.done

.fire
        ld      hl,ladyFireSound
        ld      a,1               ;one point of damage
        call    StdFireBullet
        ld      a,20
        call    SetAttackDelay
        jr      .checkButtonB

.checkButtonB
.done
        ret

ladyFireSound:
  DB 1,$35,$80,$f3,$00,$c4

LadyGetInput:
        call    GetHeroJoyInput

        bit     JOY_A_BIT,a             ;check strafe release
        jr      nz,.afterStrafeRelease  ;nope

        push    af
        ld      a,15                    ;yep
        call    SetFireDirection
        pop     af

.afterStrafeRelease
        bit     JOY_B_BIT,a
        jr      z,.normalMove

.slowMove
        xor     a
        ret

.normalMove
        ld      a,2

.testMove
        call    HeroTestMove
        or      a
        ret     z
        jp      HeroDoSparks

LadyBulletInit:
        ;ld      a,3
        ;call    GetRandomNumMask
        ;add     c
        ;call    ChangeMyClass

        ld      hl,.pansyInitTable
        call    StdInitFromTable

        ld      a,[methodParamL]
        and     %00000011
        ld      b,a
        call    GetFacing
        and     %11111100
        or      b
        call    SetFacing

        call    PointToSpecialFlags
        set     OBJBIT_THROWN,[hl]

        xor     a
        call    SetMisc

        ret

.pansyInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_HERO       ;group
        DB      1                ;has bullet
        DW      classPansyBullet ;associated bullet class ptr
        DW      PANSYBULLET_CINDEX

LadyBulletCheck:
        call    GetMisc
        or      a
        jr      nz,.changedClass

.changedClass
        ld      hl,.pansyCheckTable
        jp      StdCheckFromTable

.pansyCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      pansyFireSound
        DB      10     ;fire delay
        DW      LadyVectorToState

;---------------------------------------------------------------------
; Hero Captain Flour
;---------------------------------------------------------------------
FlourInit:
        ;initialize object
        push    bc
        push    de
        ld      a,OBJBANK        ;select object RAM
        ld      bc,9
        inc     de
        inc     de
        ld      hl,.flourInitTable
        call    MemCopy
        pop     de
        pop     bc

        ;Load Captain's bullet-type
        push    bc
        push    de
        call    SaveFGTileInfo
        ld      a,HERO_FLOUR_FLAG
        call    SetHeroTileSet
        ld      de,classFlourBullet
        ld      hl,FLOUR_BULLET_CINDEX
        xor     a
        call    LoadAssociatedClass
        call    GetAssociated
        ld      b,a
        ld      a,HERO_FLOUR_FLAG
        call    SetHeroBulletIndex
        call    RestoreFGTileInfo
        pop     de
        pop     bc

        call    LinkAssocToMe
        ret

.flourInitTable
  DB 1,1,$0f,FLOUR_MAX_HEALTH,0,0,0,GROUP_HERO,1

FlourPlayerCheck:
        ld      b,FLOUR_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    StdPlayerGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

.checkButtons
        call    DecrementAttackDelay
        or      a
        jr      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jr      z,.done

        ld      hl,flourAttackSound
        call    PlaySound

        ;turn into bullet
        xor     a
        call    SetMisc
        call    ChangeMyClassToAssociatedAndRedraw

.done
        ret

flourAttackSound:
  DB 1,$43,$81,$f7,$00,$c3

FlourBulletCheck:
        call    .flourBulletCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    HeroTestMove

        or      a
        ret     z

        call    .flourBulletCheckMain  ;move first of two
        ;ret

        call    GetHealth
        ld      b,FLOUR_MAX_HEALTH
        call    HealthSparks
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ld      a,1   ;no, move again

        call    .flourBulletCheckMain  ;move first of two
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ld      a,1   ;no, move again

.flourBulletCheckMain
        or      a
        jr      z,.done           ;timer lsb==frame lsb, don't move yet

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      nc,.hitMonster

        ;bg in front flagged as shoot over?
        ld      a,[bgFlags]
        bit     BG_BIT_SHOOTOVER,a
        jr      z,.hitWall
        ;and     BG_FLAG_SHOOTOVER
        ;jr      z,.hitWall
        jr      .keepGoing

.hitMonster
        call    .flourBulletHitMonster
        ret

.hitWall
        call    .flourBulletHitWall
        ret

.keepGoing
        jp      .flourBulletKeepGoing
.done
        ret

.flourBulletCheckDead
        call    GetHealth
        cp      b
        jr      c,.afterLimitHealth

        ld      a,b
        push    af
        call    SetHealth
        pop     af

.afterLimitHealth
        or      a
        ret     nz

        ld      a,[amShowingDialog]   ;don't die while showing dialog
        or      a
        ret     nz
IF INFINITEHEALTH==0
        call    ChangeMyClassToAssociatedAndRedraw
        xor     a
ELSE
        ld      a,1
        or      a
ENDC
        ret


.flourBulletHitMonster
        ;object in front, hit it for damage
        ld      b,a                  ;monster index in b, loc in hl

        ;get damage
        ld      a,1

        ld      [methodParamL],a
        ld      a,4                  ;use direction of this object for expl
        call    HitObject
        call    .changeDirection
        ret

.flourBulletHitWall
        bit     BG_BIT_ATTACKABLE,a
        jr      z,.afterHitWall

        ld      b,16                 ;initial frame
        call    HitWall

.afterHitWall
        call    .changeDirection
        ret

.flourBulletKeepGoing
        call    GetMisc    ;bounced over three times?
        cp      1
        jr      c,.afterCheckStop

.checkStop
        call    GetFacing  ;can't be split
        bit     2,a
        jr      nz,.afterCheckStopSound   ;can't be sprite
        bit     7,a
        jr      nz,.afterCheckStopSound

        call    ChangeMyClassToAssociatedAndRedraw
        ret

.afterCheckStopSound
        ld      hl,flourAttackSound
        call    PlaySound

.afterCheckStop
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME         ;get current direction
        add     hl,de
        ld      a,[hl]
        and     %00000011            ;keep going same direction
        ld      b,a

        call    Move
        call    StdBulletRedraw  ;draw me please
        ret

.changeDirection
        call    GetMisc
        inc     [hl]
        call    GetFacing
        ld      b,a

        call    GetAssocJoyInput   ;allow user to dictate dir of exit
        and     %1111
        jr      z,.reverseDir

        push    bc
        call    JoyAToDirB
        ld      a,b
        pop     bc
        push    bc
        ld      c,a
        xor     b
        and     %11
        ld      a,c
        pop     bc
        jr      nz,.gotDir

.reverseDir
        ld      a,2
        add     b
        and     %11
.gotDir
        ;call    GetRandomNumZeroToN
        ;inc     a
        res     0,b
        res     1,b
        or      b
        push    af
        call    SetFacing
        pop     af
        and     %11
        ld      b,a
        ;call    Move
        ;call    StdBulletRedraw
        push    bc
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        pop     bc
        call    StandardRedrawNoCheckSprite  ;turn around
        ret

StdPlayerCheckDead:
        call    GetHealth
        cp      b
        jr      c,.afterLimitHealth

        ld      a,b
        push    af
        call    SetHealth
        pop     af

.afterLimitHealth
        or      a
        ret     nz

        ld      a,[amShowingDialog]   ;don't die while showing dialog
        or      a
        ret     nz
IF INFINITEHEALTH==0
        call    RemoveHero
        xor     a
ELSE
        ld      a,1
        or      a
ENDC
        ret

StdPlayerGetInput:
        ;args:     b - max health
        ;returns:  z - no move, nz=has move
        ;          b - dir of move
        call    GetHeroJoyInput

        bit     JOY_A_BIT,a             ;check strafe release
        jr      nz,.afterStrafeRelease  ;nope

        push    af
        ld      a,15                    ;yep
        call    SetFireDirection
        pop     af

.afterStrafeRelease
        bit     JOY_B_BIT,a
        jr      z,.normalMove

.slowMove
        ld      a,2
        jr      .testMove

.normalMove
        ld      a,1

.testMove
        call    HeroTestMove
        or      a
        ret     z
;fall through below

;falling through above
HeroDoSparks:
        xor     a
        call    SetHeroMoved

        call    GetHealth
        ;ld      b,HAIKU_MAX_HEALTH   ;b should be set up
        call    HealthSparks

        call    GetHeroJoyInput

        and     %1111               ;get directions only
        ret     z
        ;jr      nz,.checkEast
        ;jp      .checkButtons

        call    JoyAToDirB
        ld      a,1
        or      a
        ret

JoyAToDirB:
.checkEast
        bit     0,a
        jr      z,.checkWest
        ld      b,DIR_EAST
        ret

.checkWest
        bit     1,a
        jr      z,.checkNorth
        ld      b,DIR_WEST
        ret

.checkNorth
        bit     2,a
        jr      z,.checkSouth
        ld      b,DIR_NORTH
        ret

.checkSouth
        ld      b,DIR_SOUTH
        ret

;---------------------------------------------------------------------
; Routine:      LocIsPassable
; Arguments:    hl - location
; Alters:       af
; Returns:      a - 1 if passable, 0 if not
;               [bgFlags]
;---------------------------------------------------------------------
LocIsPassable:
        push    bc

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        jr      z,.returnTrueSetBG

        cp      b
        jr      nc,.returnFalse

        call    GetBGAttributes
        ld      [bgFlags],a
        bit     BG_BIT_WALKOVER,a
        jr      nz,.returnTrue

.returnFalse
        xor     a
        pop     bc
        ret

.returnTrueSetBG
        call    GetBGAttributes
        ld      [bgFlags],a

.returnTrue
        pop     bc
        ld      a,1
        or      a
        ret

;---------------------------------------------------------------------
; Routine:      AmAtEdgeInDirection
; Arguments:    b  - direction
;               c  - class index of object
;               de - this
; Alters:       af,hl
; Returns:      a  - 1=at edge, 0=not at edge
;               zflag - or a
;---------------------------------------------------------------------
AmAtEdgeInDirection:
        ;clip and make sure I'm at least 2 from the edge
        call    GetCurLocation
        call    ConvertLocHLToXY
        ld      a,b
        cp      DIR_NORTH
        jr      z,.checkNorth
        cp      DIR_EAST
        jr      z,.checkEast
        cp      DIR_SOUTH
        jr      z,.checkSouth

.checkWest
        ld      a,h
        cp      2
        jr      c,.returnTrue
        jr      .returnFalse

.checkNorth
        ld      a,l
        cp      2
        jr      c,.returnTrue
        jr      .returnFalse

.checkEast
        ;add 1 to X if split
        call    GetFacing
        bit     2,a
        jr      z,.xOkay

        inc     h
.xOkay
        ld      a,[mapWidth]
        sub     3
        cp      h
        jr      c,.returnTrue
        jr      .returnFalse

.checkSouth
        ;add 1 to Y if split
        call    GetFacing
        bit     2,a
        jr      z,.yOkay

        inc     l

.yOkay
        ld      a,[mapHeight]
        sub     3
        cp      l
        jr      c,.returnTrue

.returnFalse
        xor     a
        ret

.returnTrue
        ld      a,1
        or      a
        ret

;---------------------------------------------------------------------
; Hero King Grenade
;---------------------------------------------------------------------
GrenadePlayerInit:
        ;initialize object
        push    bc
        push    de
        ld      a,OBJBANK        ;select object RAM
        ld      bc,9
        inc     de
        inc     de
        ld      hl,.grenadeInitTable
        call    MemCopy
        pop     de
        pop     bc

        xor     a
        call    SetMisc
        ret

.grenadeInitTable
  DB 1,1,$0f,GRENADE_MAX_HEALTH,0,0,0,GROUP_HERO,1

GrenadePlayerCheck:
        ld      b,GRENADE_MAX_HEALTH
        call    StdPlayerCheckDead
        ret     z

        call    GrenadeGetInput
        jr      z,.checkButtons

        call    PlayerValidateMoveAndRedraw

.checkButtons
        call    DecrementAttackDelay
        or      a
        jp      z,.done

        call    GetHeroJoyInput
        bit     4,a               ;button A pressed?
        jp      z,.done

        call    GetMisc   ;already started explosion?
        or      a
        jr      nz,.done

        ld      a,1
        call    SetMisc

        push    bc
        push    de
        ld      a,3
        ld      [bulletColor],a
        ld      a,15
        ldio    [jiggleDuration],a
        call    GetCurLocation
        call    ConvertLocHLToXY
        dec     h
        dec     l
        call    ConvertXYToLocHL
        ld      bc,$0404
        ld      de,$1407
        call    CreateBigExplosion
        ld      hl,bigExplosionSound
        call    PlaySound
        pop     de
        pop     bc

        xor     a
        call    SetHealth

        ;on correct level $1010 to blow up gate?
        ld      a,[curLevelIndex]
        or      a
        jr      nz,.done
        ld      a,[curLevelIndex+1]
        cp      $10
        jr      nz,.done

        call    GetCurZone
        cp      4
        jr      nz,.done

        ld      a,1
        ld      [levelVars+4],a     ;used in $1000 VAR_EXPLODEDGATE
        ;ld      hl,heroesAvailable
        ;res     HERO_GRENADE_BIT,[hl]

        call    levelCheckRAM    ;start gate exploding before death

IF 0
        ld      a,[hero0_type]
        cp      HERO_GRENADE_FLAG
        jr      nz,.resetHero1

        ;reset hero to bs
        ld      hl,2056  ;bs
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero0_type],a
        jr      .done

.resetHero1
        ;reset hero to bs
        ld      hl,2056  ;bs
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero1_type],a
ENDC

.done
        ret

GrenadeGetInput:
        call    GetHeroJoyInput

        bit     JOY_A_BIT,a             ;check strafe release
        jr      nz,.afterStrafeRelease  ;nope

        push    af
        ld      a,15                    ;yep
        call    SetFireDirection
        pop     af

.afterStrafeRelease
        bit     JOY_B_BIT,a
        jr      z,.normalMove

.slowMove
        ld      a,5
        jr      .testMove

.normalMove
        ld      a,4

.testMove
        call    HeroTestMove
        or      a
        ret     z
        jp      HeroDoSparks

;---------------------------------------------------------------------
; Routine:      StdBulletInit
; Arguments:    c  - class index, de - this
;               [methodParamL]  - 4:2=color, 1:0=direction
;---------------------------------------------------------------------
StdBulletInit:
        push    bc
        push    hl

        ld      a,OBJBANK
        ld      [$ff70],a

        ld      a,[methodParamL]
        ld      b,a

        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,b
        and     %10000011
        ld      c,a
        ld      a,[objTimer60ths]   ;set to cur timer so no move this round
        or      c
        ld      [hl+],a          ;set frame
        push    af               ;save frame for later

        ld      a,1
        ld      [hl+],a          ;move one
        ld      a,b
        and     %00011100        ;extract color palette
        srl     a
        srl     a
        ld      [hl+],a          ;store in misc
        ld      a,1
        ld      [hl+],a          ;health = 1
        inc     hl               ;skip nextL
        inc     hl               ;skip nextH
        ld      a,1
        ld      [hl+],a          ;state=1 (length for long bullets)
        ld      a,GROUP_FFA
        ld      [hl+],a          ;group = FFA

        ld      a,[fireBulletDamage]
        ld      [hl+],a          ;DESTL/Damage

        inc     hl               ;skip DESTH

        ;allocate a sprite if the isSprite flag starts out at 1
        pop     af               ;retrieve frame
        bit     7,a              ;sprite flag set?
        jr      z,.afterAlloc

        ;call    AllocateSprite
        ;ld      [hl+],a          ;set SPRITELO

.afterAlloc
        pop     hl
        pop     bc
        ret

YellowBulletInit:
        ld      hl,methodParamL
        ld      a,[hl]
        and     %11100011
        or      %00010100        ;yellow
        ld      [hl],a
        jp      StdBulletInit

StdBulletRedraw:
        push    bc
        push    de
        push    hl

        ld      a,OBJBANK
        ld      [$ff70],a

        xor     a
        ld      [fgFlags],a

        ld      hl,OBJ_LIMIT      ;get my color
        add     hl,de
        ld      b,[hl]
        jp      StandardDraw

StdCheckDead:
        push    hl
        call    GetHealth
        pop     hl
        or      a
        ret     nz
        call    StandardDie
        xor     a
        ret         ;return z flag set

StdCheckTimeToMove:
        ;time to move?
        ld      a,[hl+]
        ld      [checkTemp],a
        or      a
        jr      nz,.goAhead
        inc     a
        ret            ;return nz - no move but can attack

.goAhead
        push    hl
        call    TestMove
        pop     hl
        or      a
        ret     nz    ;can move
        xor     a     ;return z
        ret           ;timer lsb==frame lsb, don't move yet

StdCheckAttack:
.checkAttack
        ;can I attack yet?
        push    hl
        call    DecrementAttackDelay
        pop     hl
        or      a
        jr      nz,.attackOkay
        inc     hl
.didntFindEnemy
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jr      .skipAttack

.attackOkay
        ld      a,[hl+]
        or      a
        jr      z,.didntFindEnemy

        cp      1
        jr      z,.meleeOnly

        ;Got an enemy in my sights?
        xor     a
        ld      [losLimit],a
        call    LookForEnemyInLOS        ;returns dir of enemy in b
        or      a
        jr      z,.didntFindEnemy
        jr      .foundEnemy

.meleeOnly
        ld      a,1
        ld      [losLimit],a
        call    LookForEnemyInLOS        ;returns dir of enemy in b
        or      a
        jr      z,.didntFindEnemy

.foundEnemy
        ;Fire instead of moving
        ld      a,[curObjWidthHeight]
        push    af

        ld      a,[hl+]   ;bullet damage
        push    hl
        push    af

        ld      a,[hl+]   ;hl = fire sound
        ld      h,[hl]
        ld      l,a

        pop     af             ;damage
        call    StdFireBullet  ;b is direction to fire
        pop     hl
        inc     hl
        inc     hl
        ld      a,[hl+]        ;delay
        call    SetAttackDelay

        pop     af
        ld      [curObjWidthHeight],a

        ;turn to face the direction we just fired
        ld      a,[checkTemp]
        or      a
        jr      z,.skipMove

        call    GetFacing
        and     %11
        cp      b
        jr      z,.skipMove  ;no need to turn

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StandardValidateMoveAndRedraw

        jr      .skipMove

.skipAttack
        ld      a,1 ;return nz (go ahead and move)
        or      a
        ret

.skipMove
        xor     a   ;return z (skip move)
        ret

StdCheckTalk:
        ld      a,[dialogNPC_speakerIndex]  ;someone else talking?
        or      a
        jr      nz,.skipTalk

        call    GetMisc  ;already talked?
        or      a
        ret     nz

        call    GetCurLocation
        inc     hl

.checkTalkEast
        ld      b,DIR_EAST
        call    .getHeroAtHL
        or      a
        jr      nz,.foundHero

.checkTalkWest
        ld      b,DIR_WEST
        dec     hl
        dec     hl
        call    .getHeroAtHL
        or      a
        jr      nz,.foundHero

.checkTalkSouth
        ld      b,DIR_SOUTH
        ld      a,[mapPitch]
        inc     hl
        call    ConvertLocHLToXY
        push    hl
        inc     l
        call    ConvertXYToLocHL
        call    .getHeroAtHL
        pop     hl
        or      a
        jr      nz,.foundHero

.checkTalkNorth
        ld      b,DIR_NORTH
        dec     hl
        call    ConvertXYToLocHL
        call    .getHeroAtHL
        or      a
        jr      z,.skipTalk

.foundHero
        ld      a,1
        call    SetMisc

        call    GetFacing
        and     %11
        cp      b
        jr      z,.skipMove  ;no need to turn

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StandardValidateMoveAndRedraw

        jr      .skipMove

.skipTalk
        ld      a,1 ;return nz (go ahead and move)
        or      a
        ret

.skipMove
        xor     a   ;return z (skip move)
        ret

.getHeroAtHL
        ;if a hero is at HL, sets up [dialogNPC*] with appropriate
        ;values
        ld      a,MAPBANK
        ldio    [$ff70],a

        push    bc
        ld      a,[hl]
        or      a
        jr      z,.checkHero1
        push    hl
        call    EnsureTileIsHead
        pop     hl
        ld      b,a

        ld      a,[hero0_index]
        or      a
        jr      z,.checkHero1
        cp      b
        jr      z,.isHero

.checkHero1
        ld      a,[hero1_index]
        or      a
        jr      z,.notHero
        cp      b
        jr      z,.isHero

.notHero
        pop     bc
        xor     a
        ret

.isHero
        pop     bc
        ld      [dialogNPC_heroIndex],a
        ld      a,c
        ld      [dialogNPC_speakerIndex],a
        ret

StdMove:
        ld      a,1
  ld      [moveAlignPrecision],a
  ld      a,c
  ld      bc,.vectorToStateReturnAddress
  push    bc
  ld      c,a
  ld      a,[hl+]
  ld      h,[hl]
  ld      l,a
  or      a      ;no movement if vector table is zero
  jr      nz,.jumpToVector
  cp      h
  jr      nz,.jumpToVector

  pop     bc
  jr      .vectorToStateReturnAddress

.jumpToVector
        jp      hl
.vectorToStateReturnAddress
        or      a
        ret     z

        call    StandardValidateMoveAndRedraw
.done
        ret



;----bullet check methods---------------------------------------------
WizardBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,2
        call    TestMove

        or      a
        jr      z,.done           ;timer lsb==frame lsb, don't move yet

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      nc,.hitMonster

        ;bg in front flagged as shoot over?
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      z,.hitWall
        jr      .keepGoing

.hitMonster
        ;'a' is class index of monster hit, hl it's location
        ld      b,a
        call    StandardDie
        ld      c,b
        ld      d,h
        ld      e,l
        call    FindObject

        ;perform a random effect on the monster hit
        ld      a,1
        call    GetRandomNumMask
        or      a
        jr      nz,.checkMonsterRand1

        ;freeze the monster for a bit
        ld      a,60
        call    SetMoveDelay
        ret

.checkMonsterRand1
        ;don't let the monster attack for a bit
        ld      a,[hero0_index]
        cp      c
        jr      z,.setHeroAttackDelay
        ld      a,[hero1_index]
        cp      c
        jr      z,.setHeroAttackDelay

        ;set monster attack delay
        ld      a,20
        call    SetAttackDelay
        ret

.setHeroAttackDelay
        ld      a,200
        call    SetAttackDelay
        ret

.hitWall
        call    StdBulletHitWall
        ret

.keepGoing
        jp      StdBulletKeepGoing
.done
        ret

SuperSuperFastBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    TestMove

        or      a
        ret     z

        call    BulletCheckCommon  ;move first of two
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ;no, move again
        call    BulletCheckCommon
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ;no, move yet again
        jr      BulletCheckCommon

SuperFastBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    TestMove

        or      a
        ret     z

        call    BulletCheckCommon  ;move first of two
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ld      a,1   ;no, move again
        jr      BulletCheckCommon

StdBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,2
        call    TestMove

BulletCheckCommon:
        or      a
        jr      z,.done           ;timer lsb==frame lsb, don't move yet

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      nc,.hitMonster

        ;bg in front flagged as shoot over?
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      z,.hitWall
        jr      .keepGoing

.hitMonster
        call    StdBulletHitMonster
        ret
        ;jr      .done

.hitWall
        call    StdBulletHitWall
        ret
        ;jr      .done

.keepGoing
        jp      StdBulletKeepGoing
.done
bulletCheckDone:
        ret

StdBulletHitMonster:
        ;object in front, hit it for damage
        ld      b,a                  ;monster index in b, loc in hl

        ;get damage from object
        push    hl
        call    GetBulletDamage
        pop     hl

        ld      [methodParamL],a
        ld      a,4                  ;use direction of this object for expl
        call    HitObject
        call    StandardDie
        ret

StdBulletHitWall:
        ld      b,16                 ;initial frame
        call    HitWall
        call    StandardDie
        ret

StdBulletKeepGoing:
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME         ;get current direction
        add     hl,de
        ld      a,[hl]
        and     %00000011            ;keep going same direction
        ld      b,a

        call    Move
        call    StdBulletRedraw  ;draw me please
        ret

BASuperFastBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    HeroTestMove

        or      a
        ret     z

        call    BABulletCheckCommon  ;move first of two
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ld      a,1   ;no, move again
BABulletCheckCommon:
        or      a
        jr      z,.done           ;timer lsb==frame lsb, don't move yet

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      nc,.hitMonster

        ;bg in front flagged as shoot over?
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      z,.hitWall
        jr      .keepGoing

.hitMonster
        push    hl
        call    StdBulletHitMonster
        pop     hl
        ld      a,[baUpgrades]
        bit     UPGRADE_BAHIGHIMPACT,a
        ret     z
        call    GetFacing
        and     %11
        ld      b,a
        call    ThrowObjAtHLInDirB
        ret
        ;jr      .done

.hitWall
        call    StdBulletHitWall
        ret
        ;jr      .done

.keepGoing
        jp      StdBulletKeepGoing
.done
        ret



HeroBulletCheck:
        ;am I dead?
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    HeroTestMove
        jp      BulletCheckCommon

HeroSuperFastBulletCheck:
        call    StdCheckDead
        ret     z

.checkTimeToMove
        ;time to move?
        ld      a,1
        call    HeroTestMove

        or      a
        ret     z

        call    BulletCheckCommon  ;move first of two
        call    GetHealth  ;died yet?
        or      a
        ret     z

        ld      a,1   ;no, move again
        jp      BulletCheckCommon


ExplodingBulletCheck:
        ;am I dead?
        call    GetHealth
        or      a
        jr      nz,.checkTimeToMove
        call    StandardDie
        jr      .done

.checkTimeToMove
        ;time to move?
        ld      a,2
        call    TestMove
        or      a
        jr      z,.done           ;timer lsb==frame lsb, don't move yet

        ldio    a,[firstMonster]
        ld      b,a
        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      nc,.hitSomething

        ;bg in front flagged as shoot over?
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      nz,.keepGoing

.hitWall
        call    GetMoveLimit
        and     %00000111
        ld      [bulletColor],a
        call    GetBulletDamage
        ld      b,a
        call    GetCurLocation
        call    StandardDie
        call    BombLocation
        jr      .done

.hitSomething
        ;get damage from object
        push    hl
        call    GetMoveLimit
        and     %00000111
        ld      [bulletColor],a
        call    GetBulletDamage
        pop     hl
        ld      b,a
        call    StandardDie
        call    BombLocation
        jr      .done

.keepGoing
        call    GetFacing
        and     %00000011            ;keep going same direction
        ld      b,a

        call    Move
        call    StdBulletRedraw  ;draw me please

.done
        ret

;---------------------------------------------------------------------
; Routine:      GetLocInFront
; Arguments:    a  - 4=in front, same directon, split tile included
;                      returns zero
;                    0-3=this direction AFTER split tile
;               c  - class index
;               de - this
; Returns:      a  - tile index in front of object
;               hl - location in front of object
;               [bgFlags] - if tile in front is non-zero bg tile,
;                           its flags are loaded here
; Alters:       af,hl
; Description:  For 2x2 creatures facing east or south, returns
;               location one tile further away to avoid tail of obj.
;---------------------------------------------------------------------
GetLocInFront:
        push    bc
        push    de

        cp      4
        jr      nz,.checkArbitraryAfterSplit

        xor     a
        ld      [bgFlags],a

        ;check in direction of current facing
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME        ;get facing
        add     hl,de
        ld      a,[hl]
        bit     2,a
        jr      z,.notSplit

        ;is split, return zero and location in hl
        ld      h,d
        ld      l,e                 ;hl = location
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        xor     a                   ;return zero
        jr      .done

.notSplit
        and     %00000011            ;left with cur direction in A

.checkArbitraryAfterSplit
        ld      b,a                 ;b is dir to check
        ld      [getLocInitFacing],a

        xor     a
        ld      [bgFlags],a

        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME        ;get facing
        add     hl,de
        ld      a,[hl]
        bit     2,a
        jr      nz,.isSplit

        ;not split, get offset, get location & we're done
        call    .getLocInHLAndOffsetInDE
        jr      .addedOnceOrTwice
        ;ld      a,[hl]
        ;jr      .done

.isSplit
        ;combine desired facing + cur facing in B
        rlca
        rlca
        and     %00001100
        or      b
        ld      b,a                 ;B is combo cur facing+desired check
        ld      hl,getLocSplitTable
        add     l
        ld      l,a
        ld      a,[hl]
        or      a
        jr      nz, .addTwice

        ;add once
        call    .getLocInHLAndOffsetInDE
        jr      .addedOnceOrTwice

.addTwice
        ldio    a,[curObjWidthHeight]
        push    af
        ld      a,1
        ldio    [curObjWidthHeight],a
        call    .getLocInHLAndOffsetInDE
        add     hl,de
        pop     af
        ldio    [curObjWidthHeight],a

.addedOnceOrTwice
        ldio    a,[firstMonster]
        ld      b,a

        ld      a,[hl]
        or      a
        jr      z,.done
        cp      b
        jr      nc,.done

        ;non-zero bg tile, get attribute flags in [bgFlags]
        ld      e,a
        ld      d,((bgAttributes>>8) & $ff)
        ld      a,TILEINDEXBANK
        ld      [$ff70],a
        ld      a,[de]
        ld      [bgFlags],a
        ld      a,MAPBANK
        ld      [$ff70],a
        ld      a,e

.done
        pop     de
        pop     bc
        ret

.getLocInHLAndOffsetInDE
        ;location in hl
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      h,d
        ld      l,e                 ;hl = location
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        ;direction offset in de
        ld      a,MAPBANK
        ld      [$ff70],a

        ld      d,((mapOffsetNorth>>8)&$ff)  ;add offset to go in front
        ld      a,b
        and     %00000011
        rla                                  ;times two
        add     (mapOffsetNorth & $ff)
        ld      e,a                          ;de pts to offset
        ld      a,[de]
        ld      c,a
        inc     de
        ld      a,[de]
        ld      e,c
        ld      d,a                          ;de IS offset

        ;2x2 creatures facing east or south should be +1 more tile
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.afterAdjust

        ld      a,[getLocInitFacing]
        cp      1
        jr      z,.offsetTimesTwo

        cp      2
        jr      nz,.afterAdjust

.offsetTimesTwo
        sla     e
        rl      d

.afterAdjust
        add     hl,de                        ;hl += offset
        ret

;---------------------------------------------------------------------
; Routine:      StdFireBullet
; Arguments:    a  - amount of damage
;               b  - direction to fire (0-3) or 4=in dir of facing
;               c  - class index of firing object
;               de - "this"
;               hl - ptr to fire sound data for channel 1
; Alters:       af
;---------------------------------------------------------------------
StdFireBullet:
        push    bc
        push    de
        push    hl
        push    hl   ;save temp copy of fire sound

        ld      [fireBulletDamage],a
        ld      a,1
        ld      [guardAlarm],a

        ;save my facing for later
        ld      a,b
        cp      4                ;use current facing if b=4
        jr      nz,.gotFacing    ;otherwise b is facing

        call    GetFacing
        and     %00000011
        ld      b,a
        call    GetLocInFront
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        ld      a,b
.gotFacing
        ld      [fireBulletDirection],a

        ;Position to place bullet
        ldio    a,[firstMonster]
        ld      b,a
        ;ld      a,[fireBulletDirection]
        ;call    GetLocInFront            ;a is direction
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[fireBulletLocation]
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        ld      a,[hl]
        or      a
        jr      z,.okayToFire
        cp      b
        jr      nc,.hitMonsterRightAway
        ld      a,[bgFlags]
        bit     BG_BIT_SHOOTOVER,a
        jr      nz,.okayToFire
        bit     BG_BIT_ATTACKABLE,a
        jr      nz,.hitWallRightAway

        ;wall straight ahead, can't fire
        pop     hl     ;get rid of fire sound
        jr      .done

.hitWallRightAway
        ld      a,[fireBulletDirection]
        ld      [bulletDirection],a
        call    GetFGAttributes
        and     %111
        ld      [bulletColor],a
        call    GetAssociated
        push    bc
        ld      c,a
        call    HitWallAfterSetDirection
        pop     bc
        jr      .playFireSound

.hitMonsterRightAway
        ;object in front, hit it for damage
        ld      b,a                  ;monster index in b, loc in hl
        ld      a,[fireBulletDamage] ;one point of damage
        ld      [methodParamL],a
        ld      a,[fireBulletDirection]
        call    HitObject

        pop     hl   ;fire sound
        call    PlaySound
        jr      .done

.okayToFire
        ;Get class index of bullet
        call    GetAssociated
        ld      b,c                  ;save class index
        ld      c,a                  ;retreive class index

        ;create the bullet
        call    CreateObject

        ;init bullet sending my color palette and my facing
        ld      a,TILEINDEXBANK
        ld      [$ff70],a
        ld      l,b                     ;retrieve my class index
        ld      h,((fgAttributes>>8) & $ff)
        ld      a,[hl]
        rlca
        rlca                            ;b has palette in 4:2
        and     %00011100
        ld      b,a

        ;retrieve facing
        ld      a,[fireBulletDirection]
        or      b

        ;set isSprite if firing over background
        ld      b,a
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      z,.doneSetSprite

        set     7,b

.doneSetSprite
        ld      a,b

        ld      [methodParamL],a        ;param is combo color+facing
        ld      b,METHOD_INIT
        call    CallMethod
        ld      b,METHOD_DRAW
        call    CallMethod

.playFireSound
        pop     hl   ;fire sound
        call    PlaySound

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CreateBulletOfClass
; Arguments:    [fireBulletDamage]    - amount of damage
;               [fireBulletDirection] - 1:0 - direction to fire
;               [bulletColor]         - bullet color
;               hl - location of bullet origin
;               c  - class index of bullet
; Alters:       af, de
;---------------------------------------------------------------------
CreateBulletOfClass:
        push    bc
        push    de
        push    hl

        ld      a,[fireBulletDirection]
        call    AdvanceLocHLInDirection

        ;Position to place bullet
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        push    af
        call    GetBGAttributes
        ld      [bgFlags],a
        pop     af
        or      a
        jr      z,.okayToFire
        cp      b
        jr      nc,.hitMonsterRightAway
        ld      a,[bgFlags]
        bit     BG_BIT_SHOOTOVER,a
        jr      nz,.okayToFire
        bit     BG_BIT_ATTACKABLE,a
        jr      nz,.hitWallRightAway

        ;wall straight ahead, can't fire
        jr      .done

.hitWallRightAway
        ld      a,[fireBulletDirection]
        ld      [bulletDirection],a
        call    HitWallAfterSetDirection
        jr      .done

.hitMonsterRightAway
        ;object in front, hit it for damage
        ld      b,a                  ;monster index in b, loc in hl
        ld      a,[fireBulletDamage] ;one point of damage
        ld      [methodParamL],a
        ld      a,[fireBulletDirection]
        call    HitObject
        jr      .done

.okayToFire
        ;create the bullet
        call    CreateObject

        ld      a,[bulletColor]
        and     %111
        rlca
        rlca
        ld      b,a
        ld      a,[fireBulletDirection]
        or      b

        ;set isSprite if firing over background
        ld      b,a
        ld      a,[bgFlags]
        and     BG_FLAG_SHOOTOVER
        jr      z,.doneSetSprite

        set     7,b

.doneSetSprite
        ld      a,b

        ld      [methodParamL],a        ;param is combo color+facing
        ld      b,METHOD_INIT
        call    CallMethod
        ld      b,METHOD_DRAW
        call    CallMethod

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetFireTimer
; Arguments:    a  - value to set fire timer to
; Alters:       af,hl
;---------------------------------------------------------------------
SetFireTimer:
        push    af
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FIRETIMER
        add     hl,de
        pop     af
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      DecrementAttackDelay
; Arguments:    c  - class index of object
;               de - "this"
; Returns:      a  - 1=can attack now, 2=can't attack
; Alters:       af,hl
; Description:  If this->attackDelay==0 returns 1.
;               Otherwise decrements attackDelay and returns zero
;---------------------------------------------------------------------
DecrementAttackDelay:
        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_FIRETIMER
        add     hl,de
        ld      a,[hl]
        or      a
        jr      z,.returnTrue

        dec     [hl]

        xor     a
        ret

.returnTrue
        ld      a,1
        ret

;---------------------------------------------------------------------
; Routine:      SetAttackDelay
; Arguments:    a  - desired attack delay 0-15
;               c  - class index of object
;               de - "this"
; Alters:       af,hl
; Description:  Stores attack delay in OBJ_FIRETIMER
;---------------------------------------------------------------------
SetAttackDelay::
        push    bc
        ld      b,a

        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_FIRETIMER
        add     hl,de
        ld      a,b
        ld      [hl],a

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetAttackDelay
; Arguments:    c  - class index of object
;               de - "this"
; Returns:      a  - remaining attack delay
; Alters:       af,hl
; Description:  Stores attack delay in OBJ_FIRETIMER
;---------------------------------------------------------------------
GetAttackDelay::
        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_FIRETIMER
        add     hl,de
        ld      a,[hl]
        ret

;---------------------------------------------------------------------
; Routine:      HitObject
; Arguments:    a  - 0-3=direction of explosion, 4=use this obj 4 dir
;               b  - class index of monster hit
;               c  - class index of object
;               de - "this"
;               hl - map location of monster hit
;               [methodParamL] - points of damage
; Alters:       af
; Description:  Locates the creature that's been hit and calls its
;               TAKE_DAMAGE method.
;---------------------------------------------------------------------
HitObject:
        push    bc
        push    de
        push    hl

        ;Get direction bullet was travelling
        cp      a,4
        jr      nz,.gotBulletDirection

        ;use this objects facing for bullet direction
        ld      a,OBJBANK
        ld      [$ff70],a
        inc     de
        inc     de
        ld      a,[de]
.gotBulletDirection
        and     %11
        ld      [bulletDirection],a

        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a

        ld      a,b          ;store monster class index in c
        call    EnsureTileIsHead
        ld      d,h    ;de stores location of monster
        ld      e,l
        ld      c,a    ;a is class of monster

        call    FindObject
        ld      b,METHOD_TAKE_DAMAGE  ;should fill [bulletColor] w/obj color
        call    CallMethod
        or      a
        jr      z,.done   ;zero damage, skip explosion

        ld      b,1
        call    CreateExplosion

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      HitWall
; Arguments:    b  - initial frame
;               c  - class index of object
;               de - "this"
;               hl - map location of wall hit
;               [bgFlags]
;               [bulletDirection]
; Alters:       af,hl
; Description:  Creates an explosion over the wall that's been hit
;               If wall is flagged as BG_FLAG_ATTACKABLE, wall's
;               method is called with BGACTION_HIT.
;---------------------------------------------------------------------
HitWallAfterSetDirection:
        push    bc
        push    de
        jr      HitWallAfterSetDirectionPushedBCDE

HitWall:
        push    bc
        push    de

        ld      a,[bgFlags]
        and     BG_FLAG_ATTACKABLE
        jr      z,HitWall_WallNotAttackable

        ;set bullet's facing
        call    GetFacing
        and     %11
        ;ld      [fireBulletDirection],a
        ld      [bulletDirection],a

        ;save bullet's damage and color
        push    hl
        call    GetDestL
        ld      [fireBulletDamage],a
        call    GetMoveLimit
        ld      [bulletColor],a
        pop     hl

HitWallAfterSetDirectionPushedBCDE:
        ;save bullet's class index
        ld      a,c
        ld      [bulletClassIndex],a

        ;set 'b' to directional blast over wall
        ld      b,1
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a

        ;get the bg tiles color
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        ld      c,a
        call    GetBGAttributes
        and     %111
        push    af

        ld      a,BGACTION_HIT
        call    CallBGAction
        jr      z,HitWall_DoneAF

        pop     af
        ld      [bulletColor],a
        ;call    GetHealth
        ;cp      2
        ;jr      nc,.skipSound    ;kludge for captain flour

        ld      hl,stdExplosionSound
        call    PlaySound
.skipSound
        jr      HitWall_CreateExplosion

HitWall_WallNotAttackable:
        ;Get direction bullet was travelling
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      h,d
        ld      l,e
        ld      a,[hl+]
        ld      [bulletLocation],a
        ld      a,[hl+]
        ld      [bulletLocation+1],a

        ;get bullet color
        ld      hl,OBJ_LIMIT
        add     hl,de
        ld      a,[hl]
        ld      [bulletColor],a

        ;call    GetHealth
        ;cp      2
        ;jr      nc,.skipSound    ;kludge for captain flour
        ld      hl,bigExplosionSound
        call    PlaySound
.skipSound

HitWall_CreateExplosion:
        call    CreateExplosion   ;uses b as initial frame

HitWall_Done:
        pop     de
        pop     bc
        ret

HitWall_DoneAF:
        pop     af
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      StdTakeDamage
; Arguments:    [methodParamL] - points of damage
;               c  - class index of object
;               de - "this"
; Returns:      [bulletColor] - color of this obj for explosion
;               a  - points of damage actually taken by this creature
; Alters:       af
;---------------------------------------------------------------------
StdTakeDamage:
        push    bc
        push    hl

        ;store object palette color to be the explosion color later
        call    GetFGAttributes
        and     %111
        ld      [bulletColor],a

        ld      a,OBJBANK
        ld      [$ff70],a

        ;play the explosion sound effect
        ld      hl,stdExplosionSound
        call    PlaySound

TakeDamageCommon:
        ;blow off a puff instead of taking damage?
        ld      hl,OBJ_DESTZONE
        add     hl,de
        ld      a,[hl]
        and     %1111
        jr      z,.noPuffs

        dec     [hl]
        ld      b,METHOD_DRAW
        call    CallMethod
        jr      .resetState

.noPuffs
        ld      a,[methodParamL]
        ld      c,a                   ;c is damage

        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]
        ;ld      b,a
        ld      b,0
        and     %00111111
        jr      z,.done            ;already dead
        ld      b,c                ;b is damage inflicted
        sub     c
        jr      nc,.notNegative

        add     c                  ;original health
        ld      b,a                ;is damage inflicted
        xor     a                  ;less than zero is zero
.notNegative
        ld      c,a
        ld      a,[hl]
        ;ld      a,b
        and     %11000000
        or      c
        ld      [hl],a

.resetState
        ;reset state to zero (rethink where I'm going)
        ld      a,0
        call    SetState

.done
        ld      a,b      ;return damage inflicted
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CowboyTakeDamage
; Alters:       af
; Description:  Pisses the cowboys off (group M becomes enemy)
;---------------------------------------------------------------------
CowboyTakeDamage:
        push    bc
        push    de
        push    hl

        xor     a
        ld      b,GROUP_HERO
        ld      c,GROUP_MONSTERM
        call    SetFOF

        ;change any remaining CowboyTalkers to Angry Cowboys
        ld      bc,classCowboyTalker
        ld      de,classAngryCowboy
        call    ChangeClass

        ;change any regular cowboys to angry cowboys
        ld      bc,classCowboy
        ld      de,classAngryCowboy
        call    ChangeClass

        ;change music to hoedown music
        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    IsCurMusic
        jr      z,.afterChangeMusic   ;not in cowboy land

        ld      a,BANK(hoedown_gbm)
        ld      hl,hoedown_gbm
        call    InitMusic
.afterChangeMusic

        ;zero talker index
        xor     a
        ld      [dialogBalloonClassIndex],a

        pop     hl
        pop     de
        pop     bc
        jp      StdTakeDamage

;---------------------------------------------------------------------
; Routine:      WallTakeDamage
; Description:  Toggles the wall creature between stunned and
;               normal.
;---------------------------------------------------------------------
WallTakeDamage:
        ;change to other state (stunned<->normal)
        call    ChangeMyClassToAssociatedAndRedraw

        ld      b,METHOD_DRAW
        call    CallMethod
.done
        xor     a
        ld      [bulletColor],a
        ld      a,1
        ret

;---------------------------------------------------------------------
; Routine:      TakeZeroDamage
;---------------------------------------------------------------------
TakeZeroDamage:
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      BulletTakeDamage
; Arguments:    [methodParamL] - points of damage
;               c  - class index of object
;               de - "this"
; Returns:      [bulletColor] - color of this bullet for explosion
; Alters:       af
;---------------------------------------------------------------------
BulletTakeDamage:
        push    bc
        push    hl

        ;store bullet palette color to be the explosion color later
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_LIMIT
        add     hl,de
        ld      a,[hl]
        and     %00000111
        ld      [bulletColor],a

        ;play the explosion sound effect
        ld      hl,stdExplosionSound
        call    PlaySound

        jp      TakeDamageCommon

;---------------------------------------------------------------------
; Routine:      StdTakeDamage2x2
; Arguments:    c  - class index of object
;               de - this
; Alters:       af
; Description:  Like StandardTakeDamage except creates 4 explosion
;               sprites over the area of the object when it dies.
;---------------------------------------------------------------------
StdTakeDamage2x2:
        push    bc
        push    hl

        ;store object palette color to be the explosion color later
        call    GetFGAttributes
        and     %111
        ld      [bulletColor],a

        ld      a,OBJBANK
        ld      [$ff70],a

        ;play the explosion sound effect
        ld      hl,stdExplosionSound
        call    PlaySound

        ld      a,[methodParamL]
        ld      c,a                   ;c is damage
        ld      b,c                   ;b is damage actually inflicted

        call    GetHealth
        and     %00111111
        jr      z,.doneReturnZero     ;already dead
        sub     c
        jr      nc,.notNegative

        add     c
        ld      b,a
        xor     a                     ;less than zero is zero
.notNegative
        ld      c,a
        ld      a,[hl]
        and     %11000000
        or      c
        ld      [hl],a
        and     %00111111
        jr      nz,.done

        ;it's dead; blow up the 2x2 creature
        ;save original bullet hit location
        push    bc
        ld      a,[bulletLocation]
        ld      l,a
        ld      a,[bulletLocation+1]
        ld      h,a
        push    hl

        ;create explosions
        call    GetCurLocation
        push    hl
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        xor     a
        call    .createExplosion
        ld      a,[bulletLocation]
        inc     a
        ld      [bulletLocation],a
        ld      a,1
        call    .createExplosion
        pop     hl
        call    ConvertLocHLToXY
        inc     l
        call    ConvertXYToLocHL
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        ld      a,2
        call    .createExplosion
        ld      a,[bulletLocation]
        inc     a
        ld      [bulletLocation],a
        ld      a,3
        call    .createExplosion

        ;restore original bullet location
        pop     hl
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        pop     bc
        jr      .done

.doneReturnZero
        ld      b,0
.done
        ld      a,b
        pop     hl
        pop     bc
        ret

.createExplosion
        rlca    ;times 8
        rlca
        rlca
        and     %00011000
        add     32
        ld      b,a
        call    CreateExplosion
        or      a
        ret     z

        ;offset sprites +0,+0 to +4,+4
        call    IndexToPointerHL
        ld      a,l
        add     12
        ld      l,a
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)
        push    hl
        call    GetFacing
        pop     hl

        bit     2,a
        jr      z,.afterSetOffset

        bit     0,a
        jr      nz,.eastWest

        ;facing north/south, add +4 offset
        ld      a,[hl]
        add     4
        ld      [hl],a
        jr      .afterSetOffset

.eastWest
        inc     hl
        ld      a,[hl]
        add     4
        ld      [hl],a
        dec     hl

.afterSetOffset
        ret


;---------------------------------------------------------------------
; Routine:      StandardDie
; Arguments:    c  - class index of object
;               de - this
; Alters:       af
; Description:  Removes the object from the map and deletes it
;---------------------------------------------------------------------
StandardDie:
        push    bc
        push    de
        push    hl

        ld      b,c
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        ld      c,b
        call    SuperDie
        call    DeleteObject

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetHealth
; Arguments:    c  - class index of object
;               de - this
; Returns:      a  - number of health points
; Alters:       af,hl
;---------------------------------------------------------------------
GetHealth::
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]
        and     %00111111
        ret

;---------------------------------------------------------------------
; Routine:      SetHealth
; Arguments:    a  - health to set to
;               de - this
; Returns:      Nothing.
; Alters:       af,hl
;---------------------------------------------------------------------
SetHealth::
        push    af
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_HEALTH
        add     hl,de
        ld      a,[hl]
        and     %11000000
        ld      [hl],a
        pop     af
        or      [hl]
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      SetMoveDelay
; Arguments:    a  - move delay to set to (0-255)
;               de - this
; Returns:      Nothing.
; Alters:       af,hl
;---------------------------------------------------------------------
SetMoveDelay:
        push    af
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      hl,OBJ_MOVE
        add     de
        pop     af
        ld      [hl],a
        ret

        ;push    bc
        ;ld      b,a
        ;ld      a,OBJBANK
        ;ldio    [$ff70],a
        ;ld      hl,OBJ_MOVE
        ;add     de
        ;ld      a,[hl]
        ;and     %11110000
        ;or      b
        ;ld      [hl],a
        ;pop     bc
        ;ret


;---------------------------------------------------------------------
; Routine:      ConvertLocHLToSpriteCoords
; Arguments:    hl - map location
; Returns:      hl - h = x, l = y sprite coords
; Alters:       af,hl
;---------------------------------------------------------------------
ConvertLocHLToSpriteCoords::
        ;calculate screen pixel positions
        ;x = (((tile_x * 8) - (mapLeft * 8)) - pixelOffset_x) + 8
        ;  = (((tile_x - mapLeft) * 8) - pixelOffset_x) + 8
        ;y = (((tile_y - mapTop) * 8) - pixelOffset_y) + 16
        call    ConvertLocHLToXY

        ;----------------------x coordinate---------------------------
        ld      a,[mapLeft]          ;a = -mapLeft
        cpl
        add     1
        add     h                    ;a += tile_x
        cp      32                   ;any chance of being visible?
        jr      nc,.returnZero
        rlca                         ;a *= 8
        rlca
        rlca
        ld      h,a                  ;tile_x = a
        ld      a,[desiredPixelOffset_x]
        cpl
        add     1
        add     h
        add     8
        ld      h,a                  ;tile_x=(tile_x-pixelOffset_x)+8

        ;----------------------y coordinate---------------------------
        ld      a,[mapTop]           ;a = -mapTop
        cpl
        add     1
        add     l                    ;a += tile_y
        cp      32                   ;any chance of being visible?
        jr      nc,.returnZero
        rlca                         ;a *= 8
        rlca
        rlca
        ld      l,a                  ;tile_y = a
        ld      a,[desiredPixelOffset_y]
        cpl
        add     1
        add     l
        add     16
        ld      l,a                ;tile_y=(tile_y-pixelOffset_y)+16
        ret

.returnZero
        ld      hl,0               ;sprite not visible
        ret


;---------------------------------------------------------------------
; Routine:      CreateExplosion
; Arguments:    b  - 1=moves in direction, >1 initial frame
;               c  - class index of object  (if directed)
;               de - this  (if directed)
;               [bulletColor]
;               [bulletLocation]
; Returns:      a  - explosion object index
; Alters:       af
; Description:  Creates an explosion sprite positioned over this
;               object with this object's color
;               Object memory usage for sprites:
;                 Bytes 0,1:  screen coordinate location (x,y)
;                 Byte  2:    frame
;                             bit[1:0] - direction
;                             bit[2]   - 1 if no direction
;                             bit[3]   - unused
;                             bit[6:4] - color palette (0-7)
;                 Byte  3:    (move)
;                 Byte  4:    bit[2:0] - animation frame (0-7)
;                 Byte 10:    initial frame (0,8,16,24,32,64,...)
;                 Byte 12:    Lo-Ptr to OAM table position
;---------------------------------------------------------------------
CreateExplosion::
        push    bc
        push    de
        push    hl

        call    AllocateSprite  ;returns sprite OAM lo-ptr in a or $ff
        inc     a
        jr      z,.done         ;no free sprites for explosion

        dec     a
        ld      [methodParamL],a

        ld      hl,bulletLocation
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        call    ConvertLocHLToSpriteCoords
        ld      a,b
        cp      1                     ;directional or round?
        jr      nz,.roundExplosion

        ;directed explosion
        xor     a
        ld      [explosionInitialFrame],a
        ld      a,[bulletColor]
        ld      b,a
        swap    b

        ld      a,[bulletDirection]
        and     %00000011
        or      b
        jr      .aIsSetup

.roundExplosion
        ld      [explosionInitialFrame],a
        ld      a,[bulletColor]
        swap    a
        or      %00000100

.aIsSetup
        ld      [methodParamH],a

        ld      c,CLASS_EXPLOSION
        call    CreateObject

        ld      b,METHOD_INIT
        call    CallMethod

        call    PointerDEToIndex   ;return index of explosion object

.done   pop     hl
        pop     de
        pop     bc
        ret

ExplosionInit:
        push    bc
        push    de
        push    hl

        push    de

        ld      a,[methodParamL]
        call    SetSpriteLo

        ;set up other stuff
        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[methodParamH]    ;color + direction
        ld      b,a
        ld      [hl+],a
        inc     hl
        xor     a
        ld      [hl],a              ;anim frame zero
        dec     hl                  ;hl = move
        ld      d,((spriteOAMBuffer>>8) & $ff)
        ld      a,[methodParamL]    ;loptr
        ld      e,a
        ld      a,1
        ld      [hl-],a             ;move = 1
        dec      hl

        inc     de
        ld      a,[hl-]             ;copy y pixel coordinate
        ld      [de],a
        dec     de
        ld      a,[hl+]             ;copy x pixel coordinate
        ld      [de],a
        inc     de
        inc     de                  ;de pts to pattern

        ;make hl point to frame lookup table
        ld      a,b                 ;get color+dir byte
        and     %00000111           ;mask off all but dir
        add     (explosionFrameTable & $ff)
        ld      l,a
        ld      h,((explosionFrameTable>>8) & $ff)
        ld      a,[explosionInitialFrame]
        add     [hl]                ;pattern
        ld      [de],a
        inc     de                  ;de now pts to flags
        set     3,l                 ;hl += 8
        ld      a,b
        swap    a
        and     %00001111
        ld      b,a
        ld      a,[hl]
        or      b
        ld      b,a

        ;set flak to be randomly flipped
        ld      a,[explosionInitialFrame]
        cp      64   ;flack or spark?
        ld      a,b
        jr      c,.afterFlipFlack

        ld      a,%01100000
        call    GetRandomNumMask

.afterFlipFlack
        or      b
        ld      [de],a              ;store attributes

        pop     de

        ;---extra setup-----------------------------------------------
        ;store initial frame in DESTL
        ld      a,[explosionInitialFrame]
        ld      hl,OBJ_DESTL
        add     hl,de
        ld      [hl],a

        pop     hl
        pop     de
        pop     bc
        ret

ExplosionRedraw:
ExplosionCheck:
        push    hl

        ld      a,OBJBANK
        ldio    [$ff70],a

        ;Check timer slower for flack & 2x2 explosions
        ld      hl,OBJ_DESTL      ;storage of initial frame
        add     hl,de
        ld      a,[hl]
        cp      32
        jr      c,.faster
        cp      72
        jr      nc,.faster

.slower
        ld      a,3               ;slower
        jr      .checkMove

.faster
        ld      a,1

.checkMove
        ;my turn yet?
        call    TestMove
        or      a
        jr      z,.skipTurn       ;timer lsb==frame lsb, don't move yet

        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[hl]
        bit     2,a               ;should explosion move position?
        jr      nz,.afterMove

        ;figger out which direction to move
        ;get ptr to sprite in hl
        ld      hl,OBJ_SPRITELO
        add     hl,de
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)

        bit     1,a
        jr      nz,.moveSouthOrWest

        bit     0,a
        jr      z,.moveNorth

.moveEast
        inc     hl
        inc     [hl]
        inc     [hl]
        jr      .afterMove

.moveNorth
        dec     [hl]
        dec     [hl]
        jr      .afterMove

.moveSouthOrWest
        bit     0,a
        jr      z,.moveSouth

.moveWest
        inc     hl
        dec     [hl]
        dec     [hl]
        jr      .afterMove

.moveSouth
        inc     [hl]
        inc     [hl]

.afterMove
        ld      hl,OBJ_LIMIT      ;get current frame
        add     hl,de
        inc     [hl]              ;add one
        ld      a,[hl+]           ;get frame in a

        ;get lo-ptr to sprite
        ld      hl,OBJ_SPRITELO
        add     hl,de
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)
        bit     3,a               ;become 8?
        jr      z,.keepGoing

        ;run out of frames, delete myself
        call    SuperDie
        call    ExplosionDie

        jr      .skipTurn

.keepGoing
        inc     hl                ;add one to actual sprite frame
        inc     hl
        inc     [hl]

.skipTurn
        pop     hl
        ret

ExplosionDie:
        call    DeleteObject      ;delete myself
        ret

IdleCantDieCheck:
        ret

DoNothingCheck:
        ;am I dead?
        call    GetHealth
        or      a
        jr      nz,.skipMove
        call    StandardDie
.skipMove
        ret

;---------------------------------------------------------------------
; Routine:      StdInitFromTable
; Arguments:    hl - table containing
;                    BYTE initial facing (4 = random)
;                    BYTE health  (last value popped off)
;                    BYTE monster group (e.g. MONSTER_A)
;                    BYTE hasBullet
;                    WORD bullet class ptr
;                    WORD bullet class index
; Alters:       all
; Returns:      Nothing.
; Description:  Sets
;                 - state to zero
;                 - facing to random
;                 - fire delay to 1
;                 - group to specified
;                 - health to specified
;               Loads associated bullet class
;---------------------------------------------------------------------
StdInitFromTable:
        ld      a,[hl+]
        cp      4
        jr      nz,.setFacing

        ld      a,3
        call    GetRandomNumZeroToN

.setFacing
        push    hl
        call    SetFacing

        xor     a
        call    SetState

        xor     a
        call    SetFireTimer
        pop     hl

        ld      a,[hl+]
        push    hl
        call    SetHealth
        pop     hl

        ld      a,[hl+]
        call    SetGroup

        push    de
        ld      a,[hl+]   ;has bullet?
        or      a
        jr      z,.afterLoadAssociated

        ld      a,[hl+]
        ld      e,a
        ld      a,[hl+]
        ld      d,a

        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        ld      a,1
        call    LoadAssociatedClass
.afterLoadAssociated
        ;hl screwed up here
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      StdCheckFromTable
; Arguments:    hl - pointer to table containing:
;                    BYTE  move delay
;                    BYTE  attack type (0=no attack,1=melee,2=missile)
;                    BYTE  bullet damage
;                    WORD  fire sound effect address
;                    BYTE  fire delay
;                    WORD  vectore to state routine pointer
; Alters:       all
; Returns:      Nothing.
;---------------------------------------------------------------------
StdCheckFromTable:
        call    StdCheckDead
        ret     z
StdCheckFromTableNotDead:
        call    StdCheckTimeToMove
        ret     z
        call    StdCheckAttack
        ret     z
        call    StdMove
        ret

ActorSpeed1Check:
        ld      hl,.actorCheckTable
        jp      StdCheckFromTable

.actorCheckTable
        DB      1      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      nullSound
        DB      3      ;fire delay
        DW      ActorVectorToState

GuardCheck:
        ;this guy can only attack in the direction he's facing
        ;call    GetFacing
        ;and     %00000011
        ;call    SetAttackDirState

        call    StdCheckDead
        ret     z
        ld      hl,.guardCheckTable
        call    StdCheckFromTableNotDead

        ;sound the alarm if I attacked recently (attack delay non-zero)
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      hl,OBJ_FIRETIMER
        add     hl,de
        ld      a,[hl]
        or      a
        ret     z

        ld      a,1
        ld      [guardAlarm],a
        ret


.guardCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      guardFireSound
        DB      6      ;fire delay
        DW      ActorVectorToState

;----bee--------------------------------------------------------------
BeeInit:
        ld      hl,.beeInitTable
        jp      StdInitFromTable

.beeInitTable
        DB      4                ;initial facing
        DB      1                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

BeeCheck:
        push    bc
        ld      bc,ITEM_BUGSPRAY
        call    HasInventoryItem
        pop     bc
        jr      z,.fastCheck

.slowCheck
        ld      hl,.beeCheckTableSlow
        jp      StdCheckFromTable

.fastCheck
        ld      hl,.beeCheckTableFast
        jp      StdCheckFromTable

.beeCheckTableFast
        DB      1      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      beeSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

.beeCheckTableSlow
        DB      2      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      beeSound
        DB      20     ;fire delay
        DW      StdVectorToState


;----Stunned Wall-----------------------------------------------------
StunnedWallInit:
        ld      hl,.stunnedWallInitTable
        call    StdInitFromTable

        jp      LinkAssocToMe

.stunnedWallInitTable
        DB      4                ;initial facing
        DB      63               ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classWallCreature
        DW      WALLCREATURE_CINDEX

StunnedWallCheck:
        ld      hl,.stunnedWallCheckTable
        jp      StdCheckFromTable

.stunnedWallCheckTable
        DB      0      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      nullSound
        DB      64     ;fire delay
        DW      0

;----Grenade----------------------------------------------------------
GrenadeInit:
        ld      hl,.grenadeInitTable
        jp      StdInitFromTable

.grenadeInitTable
        DB      4                ;initial facing
        DB      3                ;health
        DB      GROUP_HERO       ;group
        DB      0                ;has bullet

GrenadeCheck:
        call    GetHealth
        or      a
        jr      nz,.check

        call    GetCurLocation
        ld      b,4
        call    BombLocation
        ld      hl,bigExplosionSound
        call    PlaySound
        ld      a,5
        ld      [jiggleDuration],a

.check
        ld      hl,.grenadeCheckTable
        jp      StdCheckFromTable

.grenadeCheckTable
        DB      4      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      nullSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

;----Vacuum-----------------------------------------------------------
VacuumInit:
        ld      hl,.vacuumInitTable
        jp      StdInitFromTable

.vacuumInitTable
        DB      4                ;initial facing
        DB      6                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

VacuumCheck:
        call    StdCheckDead
        ret     z
        ld      hl,.vacuumCheckTable
        call    StdCheckFromTableNotDead

        ;handle 'firing' ourselves
        ;can we attack yet?
        call    DecrementAttackDelay
        or      a
        ret     z

        push    de
        call    GetFacing
        push    af
        and     %11
        call    GetLocInFront
        pop     af
        rlca
        and     %110
        push    hl
        ld      l,a
        ld      a,(mapOffsetNorth & $ff)
        add     l
        ld      l,a
        ld      h,((mapOffsetNorth>>8)&$ff)
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl]
        ld      d,a
        pop     hl

        xor     a
        ld      [losLimit],a
        call    ScanDirectionForEnemy    ;returns dir of enemy in b
        or      a
        jr      z,.doneDE

        ;suck the enemy towards me
        ld      a,[fireBulletLocation]   ;enemy's location
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        pop     de
        call    GetFacing
        add     2
        and     %11
        call    ShiftObjectInDirection
        ld      a,3
        call    SetAttackDelay
        ld      hl,.vacuumSuckSound
        call    PlaySound
        ret

.doneDE pop     de
        ret

.vacuumCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=none,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .vacuumAttackSound
        DB      25      ;fire delay
        DW      TrackEnemyVectorToState

.vacuumAttackSound
        DB      1,$54,$c0,$f2,$00,$83

.vacuumSuckSound
        DB      1,$55,$80,$f3,$00,$84

;----Slug-------------------------------------------------------------
SlugInit:
        ld      hl,.slugInitTable
        call    StdInitFromTable
        ld      bc,classSlugTrailBG
        call    FindClassIndex
        jp      SetMisc

.slugInitTable
        DB      4                ;initial facing
        DB      5                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

SlugCheck:
        call    GetCurLocation
        call    GetFacing
        and     %111
        cp      %100
        jr      z,.adjustSouth
        cp      %111
        jr      nz,.foundCurLocation

.adjustWest
        call    ConvertLocHLToXY
        inc     h
        jr      .convertBack

.adjustSouth
        call    ConvertLocHLToXY
        inc     l

.convertBack
        call    ConvertXYToLocHL

.foundCurLocation
        push    hl

        call    GetHealth
        push    af
        ld      hl,.slugCheckTable
        call    StdCheckFromTable
        pop     af
        or      a
        jr      nz,.notDead

        pop     af   ;dead
        ret

.notDead
        call    GetMisc
        ld      b,a
        pop     hl   ;retrieve old location
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]      ;empty now?
        or      a
        ret     nz          ;still something in there

        ;leave a slime trail
        ld      [hl],b
        jp      ResetMyBGSpecialFlags

.slugCheckTable
        DB      6      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .slugFireSound
        DB      15     ;fire delay
        DW      StdVectorToState

.slugFireSound
        DB      1,$14,$80,$f0,$00,$c1

;----Wall Creature----------------------------------------------------
WallCreatureInit:
        ld      hl,.wallCreatureInitTable
        call    StdInitFromTable

        jp      LinkAssocToMe

.wallCreatureInitTable
        DB      4                ;initial facing
        DB      63               ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classStunnedWall
        DW      STUNNEDWALL_CINDEX

WallCreatureCheck:
        ld      hl,.wallCreatureCheckTable
        jp      StdCheckFromTable

.wallCreatureCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .wallCreatureFireSound
        DB      25     ;fire delay
        DW      TrackEnemyVectorToState

.wallCreatureFireSound
        DB      1,$7b,$40,$f0,$00,$c6

;----Small Bee Hive---------------------------------------------------
BigBeeHiveInit:
SmallBeeHiveInit:
        ld      hl,.smallBeeHiveInitTable
        jp      StdInitFromTable

.smallBeeHiveInitTable
        DB      DIR_EAST         ;initial facing
        DB      5                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classBee         ;associated bullet class ptr
        DW      BEE_CINDEX

SmallBeeHiveCheck:
        ld      hl,.smallBeeHiveCheckTable
        jp      StdCheckFromTable

.smallBeeHiveCheckTable
        DB      0      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      beeSound
        DB      20     ;fire delay
        DW      0

;----Scardie----------------------------------------------------------
ScardieInit:
        ld      hl,.scardieInitTable
        jp      StdInitFromTable

.scardieInitTable
        DB      4                ;initial facing
        DB      4                ;health
        DB      GROUP_FFA        ;group
        DB      0                ;has bullet

ScardieCheck:
        call    StdCheckDead
        ret     z
        ld      hl,.scardieCheckTable
        call    StdCheckFromTableNotDead

        ;test if either hero in zone
        call    GetCurZone
        ld      b,a
        ld      a,1
        call    GetHeroZone
        cp      b
        jr      z,.heroHere
        ld      a,2
        call    GetHeroZone
        cp      b
        ret     nz
.heroHere
        jp      ScardieFlee

.scardieCheckTable
        DB      2      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      nullSound
        DB      20     ;fire delay
        DW      StdVectorToState

;If scardie's dest zone is == cur zone or not moving to zone then pick
;a new dest zone
ScardieFlee:
        call    GetCurZone
        ld      b,a
        call    GetDestZone
        or      a
        jr      z,ScardiePickNewZone
        cp      b
        jr      z,ScardiePickNewZone

        call    GetState
        or      a
        ret     nz

        ld      a,1
        jp      SetState

ScardiePickNewZone:
        ;starting at my current zone, run through the zone path matrix
        ;to see what's available
        ld      a,b
        swap    a
        or      b
        ld      l,a
        ld      h,((pathMatrix>>8)&$ff)

        ld      a,WAYPOINTBANK
        ldio    [$ff70],a

        ld      b,15
.checkNewZone
        push    bc        ;increment dest zone
        ld      a,l
        add     1
        and     %1111
        ld      b,a
        ld      a,l
        and     %11110000
        or      b
        ld      l,a
        and     %1111
        jr      nz,.afterIncL
        inc     l   ;dest zone can't be zero
.afterIncL
        pop     bc

        ld      a,[hl]
        or      a
        jr      nz,.foundPath

        dec     b
        jr      nz,.checkNewZone

        ret     ;can do nothing

.foundPath
        ld      a,l
        and     %1111
        call    SetDestZone
        ld      a,1
        jp      SetState

ScardieTakeDamage:
        call    ScardieFlee
        jp      StdTakeDamage

LadyBulletMove:
        ld      a,[hero0_type]
        cp      HERO_FLOWER_FLAG
        jr      nz,.useJoy1

        ld      hl,curJoy0
        jr      .gotJoy

.useJoy1
        ld      hl,curJoy1

.gotJoy
        ld      a,[hl]
        and     %1111
        ret     z

        call    JoyAToDirB
        ld      a,1
        or      a
        ret

;----Chomper----------------------------------------------------------
ChomperInit:
        ld      hl,.chomperInitTable
        jp      StdInitFromTable

.chomperInitTable
        DB      4                ;initial facing
        DB      4                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

ChomperCheck:
        ld      hl,.chomperCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
        call    StdCheckAttack
        ret     z

        ;see if an enemy is +2 in any direction; if so eat
        ;through the wall towards it
        push    hl

        call    AmAtEdge
        jr      nz,.stdMove

        ld      b,0
.checkNextDirection
        call    GetMapOffset
        sla     l          ;offset times 2
        rl      h

        push    de
        push    hl
        call    GetCurLocation
        pop     de
        add     hl,de
        pop     de
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    IsMyEnemy
        cp      1
        jr      nz,.continue

        ;remove wall if in-between, not split and facing
        ;correct direction and not a walkover tile
        call    GetFacing
        bit     2,a
        ;jr      nz,.gotDirection
        jr      nz,.directionToB

        and     %11
        cp      b
        ;jr      nz,.gotDirection
        jr      nz,.directionToB

        ;remove wall before moving
        push    de
        call    GetMapOffset
        push    hl
        call    GetCurLocation
        pop     de
        add     hl,de
        pop     de
        ld      a,MAPBANK
        ldio    [$ff70],a

        ldio    a,[firstMonster]
        cp      [hl]
        jr      z,.gotDirection
        jr      c,.gotDirection  ;is not a wall

        ;make sure not walkover
        push    hl
        ld      l,[hl]
        ld      a,TILEINDEXBANK
        ld      [$ff70],a
        ld      h,((bgAttributes>>8) & $ff)
        ld      a,[hl]
        pop     hl
        bit     BG_BIT_WALKOVER,a
        jr      nz,.gotDirection   ;is a walkover

        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl],a
        ld      hl,eatSound
        call    PlaySound

.gotDirection
        call    StandardValidateMoveAndRedraw
        pop     hl
        ret

.directionToB
        ld      b,a
        jr      .gotDirection

.continue
        inc     b
        ld      a,b
        cp      4
        jr      nz,.checkNextDirection

.stdMove
        pop     hl
        call    StdMove  ;nothing special found
        ret


.chomperCheckTable
        DB      5      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      .chomperSound
        DB      3      ;fire delay
        DW      TrackEnemyVectorToState

.chomperSound
        DB      1,$59,$00,$f0,$00,$c4

;---------------------------------------------------------------------
; Routine:      AmAtEdge
; Arguments:    c  - class index of object
;               de - this
; Alters:       af,hl
; Returns:      a  - 1=at edge, 0=not at edge
;               zflag - or a
;---------------------------------------------------------------------
AmAtEdge:
        ;clip and make sure I'm at least 2 from the edge
        call    GetCurLocation
        call    ConvertLocHLToXY
        ld      a,h
        cp      2
        jr      c,.returnTrue
        ld      a,l
        cp      2
        jr      c,.returnTrue
        ld      a,[mapWidth]
        sub     3
        cp      h
        jr      c,.returnTrue
        ld      a,[mapHeight]
        sub     3
        cp      l
        jr      c,.returnTrue

        xor     a
        ret

.returnTrue
        ld      a,1
        or      a
        ret

;----Reciprocator-----------------------------------------------------
ReciprocatorInit:
        ld      hl,.reciprocatorInitTable
        jp      StdInitFromTable

.reciprocatorInitTable
        DB      4                ;initial facing
        DB      10               ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classReciprocatorPowerup
        DW      RECIPROCATOR_POWERUP_CINDEX

ReciprocatorCheck:
        call    GetHealth
        cp      10
        jr      nc,.afterChangeToPowerup

        jp      ChangeMyClassToAssociatedAndRedraw

.afterChangeToPowerup
        ld      hl,.reciprocatorCheckTable
        jp      StdCheckFromTable

.reciprocatorCheckTable
        DB      10     ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      reciprocatorSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

reciprocatorSound:
        DB      1,$2e,$80,$f0,$00,$c7

;----ReciprocatorPowerup----------------------------------------------
ReciprocatorPowerupCheck:
        ;use $c000 as temporary check table, fill in with:
        ; moveDelay = health;
        ; bulletDamage = 11 - health;
        call    GetHealth
        ld      b,a
        ld      hl,$c000
        ld      [hl+],a
        ld      [hl],1
        inc     hl
        ld      a,11
        sub     b
        ld      [hl+],a
        ld      a,(reciprocatorSound & $ff)
        ld      [hl+],a
        ld      a,((reciprocatorSound>>8) & $ff)
        ld      [hl+],a
        ld      [hl],10
        inc     hl
        ld      a,(TrackEnemyVectorToState & $ff)
        ld      [hl+],a
        ld      a,((TrackEnemyVectorToState>>8) & $ff)
        ld      [hl],a

        ld      hl,$c000
        jp      StdCheckFromTable

;----Tri--------------------------------------------------------------
TriInit:
        ld      hl,.triInitTable
        jp      StdInitFromTable

.triInitTable
        DB      4                ;initial facing
        DB      4                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classTriling
        DW      TRILING_CINDEX

TriCheck:
        call    GetHealth
        or      a
        jr      nz,.afterCheckSplit

        ;split into 3 trilings
        call    GetCurLocation
        push    bc
        call    GetAssociated
        ld      c,a

        ld      b,3
.createTrilings
        call    FindEmptyLocationAround1x1
        or      a
        jr      z,.doneCreateTrilings

        push    de
        call    CreateInitAndDrawObject
        pop     de
        dec     b
        jr      nz,.createTrilings

.doneCreateTrilings
        pop     bc
        call    StandardDie
        ret

.afterCheckSplit
        ld      hl,.triCheckTable
        jp      StdCheckFromTable

.triCheckTable
        DB      12     ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      .triSound
        DB      25     ;fire delay
        DW      TrackEnemyVectorToState

.triSound
        DB      1,$43,$c0,$f0,$00,$c2

;----Triling----------------------------------------------------------
TrilingInit:
        ld      hl,.trilingInitTable
        jp      StdInitFromTable

.trilingInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classTri
        DW      TRI_CINDEX

TrilingCheck:
        call    StdCheckDead
        ret     z
        ld      hl,.trilingCheckTable
        call    StdCheckFromTableNotDead

        call    GetMisc   ;mature into adult after 256 cycles
        inc     a
        ld      [hl],a
        ret     nz

        jp      ChangeMyClassToAssociatedAndRedraw

.trilingCheckTable
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .trilingSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

.trilingSound
        DB      1,$43,$c0,$f0,$00,$c4

;----Tree-------------------------------------------------------------
TreeInit:
        ld      hl,.treeInitTable
        jp      StdInitFromTable

.treeInitTable
        DB      DIR_EAST         ;initial facing
        DB      8                ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classTreeBullet  ;associated bullet class ptr
        DW      TREEBULLET_CINDEX

TreeCheck:
        ld      hl,.treeCheckTable
        jp      StdCheckFromTable

.treeCheckTable
        DB      0      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      treeFireSound
        DB      10     ;fire delay
        DW      0

TreeTalkerCheck:
        ld      hl,.treeTalkerCheckTable
        jp      TalkerCheckAfterSetupHL

.treeTalkerCheckTable
        DB      0      ;move delay
        DW      0

;----Bush-------------------------------------------------------------
BushInit:
        ld      hl,.bushInitTable
        jp      StdInitFromTable

.bushInitTable
        DB      DIR_EAST         ;initial facing
        DB      4                ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classBushBullet  ;associated bullet class ptr
        DW      TREEBULLET_CINDEX

BushCheck:
        ld      hl,.bushCheckTable
        jp      StdCheckFromTable

.bushCheckTable
        DB      0      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      bushFireSound
        DB      15     ;fire delay
        DW      0

;----Needle-----------------------------------------------------------
NeedleInit:
        ld      hl,.needleInitTable
        call    StdInitFromTable
        ld      a,3
        call    SetDestL  ;bullet damage
        xor     a
        call    SetMoveLimit  ;bullet color
        xor     a
        jp      SetMisc   ;not triggered

.needleInitTable
        DB      4         ;initial facing
        DB      8         ;health
        DB      GROUP_MONSTERC
        DB      0         ;has bullet

NeedleCheck:
        call    GetMisc   ;triggered?
        or      a
        jr      z,.notTriggered
        jp      SuperFastBulletCheck
.notTriggered
        ld      hl,.needleCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z

        call    GetFacing
        bit     2,a           ;split tile?
        jr      nz,.noEnemy   ;don't "fire" on the split tile

        xor     a
        ld      [losLimit],a
        ld      a,4
.lookInAllDirections
        push    af
        call    LookForEnemyInLOS
        or      a
        jr      nz,.foundEnemy
        pop     af
        dec     a
        jr      nz,.lookInAllDirections
        jr      .noEnemy

.foundEnemy
        pop     af
        ld      a,1
        call    SetMisc    ;mark as triggered

        ld      hl,.needleTriggeredSound
        call    PlaySound

        call    .amFacingB
        ret     z

        ;close split tile or turn in dir
        push    bc
        call    StandardValidateMoveAndRedraw    ;move in dir 'b'
        pop     bc
        call    .amFacingB
        ret     z

        ;closed split tile, now turn in dir
        jp      StandardValidateMoveAndRedraw    ;move in dir 'b'

.noEnemy
        ;move forward if possible
        call    GetFacing
        and     %11
        ld      b,a
        xor     a
        call    CheckDestEmpty
        or      a
        jr      z,.turnInRandomDir
        jp      StandardValidateMoveAndRedraw

.turnInRandomDir
        ld      a,%11
        call    GetRandomNumMask
        ld      b,a
        jp      StandardValidateMoveAndRedraw

.amFacingB
        call    GetFacing  ;turn to face enemy
        and     %11
        cp      b
        ret     ;z=1 facing direction of enemy, z=0 not

.needleCheckTable
        DB      8    ;move delay

.needleTriggeredSound
        DB      1,$15,$00,$f0,$00,$c4

;----Bat--------------------------------------------------------------
BatInit:
        ld      hl,.batInitTable
        call    StdInitFromTable

        ;countdown until turn invisible
        ld      a,15
        call    GetRandomNumMask
        add     10
        call    SetMisc

        ld      b,c  ;this->assoc->assoc = this
        call    GetAssociated
        ld      c,a
        call    SetAssociated

        ret

.batInitTable
        DB      4         ;initial facing
        DB      2         ;health
        DB      GROUP_MONSTERC
        DB      1         ;has bullet
        DW      classInvisibleBat
        DW      INVISIBLEBAT_CINDEX

BatCheck:
        call    StdCheckDead
        ret     z

        ld      hl,.batCheckTable
        call    StdCheckFromTableNotDead

        call    GetAttackDelay   ;attacked someone?
        or      a
        jr      z,.checkInvisible

        ld      a,50             ;delay until invisible
        call    SetMisc
        ret

.checkInvisible
        call    GetMisc
        dec     a
        ld      [hl],a
        ret     nz
        jp      ChangeMyClassToAssociatedAndRedraw

.batCheckTable
        DB      3    ;move delay
        DB      1    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      batFireSound
        DB      20   ;fire delay
        DW      TrackEnemyVectorToState

batFireSound:
        DB      1,$35,$00,$f0,$00,$c7

;----Burrower--------------------------------------------------------------
BurrowerInit:
        ld      hl,.burrowerInitTable
        call    StdInitFromTable

        ld      a,10     ;keep track of my health
        call    SetMisc

        ld      b,c  ;this->assoc->assoc = this
        call    GetAssociated
        ld      c,a
        call    SetAssociated

        ret

.burrowerInitTable
        DB      4                ;initial facing
        DB      10               ;health  (above also)
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classBurrowerDirt
        DW      BURROWER_DIRT_CINDEX

BurrowerCheck:
        ;burrow if I've taken damage
        call    GetHealth
        ld      b,a
        call    GetMisc
        cp      b
        jr      z,.normalCheck    ;same health, no burrow

        ld      a,64    ;cycles until unburrow
        call    SetMisc

        jp      ChangeMyClassToAssociatedAndRedraw

.normalCheck
        ld      hl,.burrowerCheckTable
        jp      StdCheckFromTable

.burrowerCheckTable
        DB      5      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .burrowerSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

.burrowerSound
        DB      1,$2c,$c0,$f0,$00,$c4

;----BurrowerDirt----------------------------------------------------------
BurrowerDirtInit:
        ld      hl,.burrowerDirtInitTable
        jp      StdInitFromTable

.burrowerDirtInitTable
        DB      4                ;initial facing
        DB      10               ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classBurrower
        DW      BURROWER_CINDEX

BurrowerDirtCheck:
        ;unburrow at end of 64 cycles
        call    GetMisc
        dec     [hl]
        jr      nz,.normalCheck

        call    GetHealth     ;track my health
        call    SetMisc

        jp      ChangeMyClassToAssociatedAndRedraw

.normalCheck
        ld      hl,.burrowerDirtCheckTable
        jp      StdCheckFromTable

.burrowerDirtCheckTable
        DB      7      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      nullSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

;----Dandelion--------------------------------------------------------
DandelionInit:
        ld      hl,.dandelionInitTable
        call    StdInitFromTable
        jp      LinkAssocToMe

.dandelionInitTable
        DB      1                ;initial facing
        DB      1                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classDandelionPuff
        DW      DANDELIONPUFF_CINDEX

DandelionCheck:
        call    GetHealth
        or      a
        ret     nz

        call    GetCurLocation
        push    bc
        call    GetAssociated
        ld      c,a

        ld      b,4
.createPuffs
        call    FindEmptyLocationAround1x1
        or      a
        jr      z,.doneCreatePuffs

        push    de
        call    CreateInitAndDrawObject
        pop     de
        dec     b
        jr      nz,.createPuffs

.doneCreatePuffs
        pop     bc

        jp      StdCheckDead

;----Dandelion Puff---------------------------------------------------
DandelionPuffInit:
        ld      hl,.dandelionPuffInitTable
        call    StdInitFromTable
        ld      a,255   ;countdown till take root
        jp      SetMisc

.dandelionPuffInitTable
        DB      4                ;initial facing
        DB      1                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classDandelion
        DW      DANDELION_CINDEX

DandelionPuffCheck:
        call    GetMisc
        dec     [hl]    ;countdown till root
        jr      nz,.checkAttach

        ld      a,[numFreeObjects]
        cp      (255-60)
        jr      nc,.takeRoot

        xor     a
        jp      SetHealth

.takeRoot
        call    MoveForwardIfSplit
        jp      ChangeMyClassToAssociatedAndRedraw

.checkAttach
        ld      hl,.dandelionPuffCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
.checkAttack
        ld      a,1
        ld      [losLimit],a
        call    LookForEnemyInLOS
        or      a
        jr      z,.noEnemy

.enemyFound
        xor     a
        call    SetHealth    ;die next time
        ld      hl,.dandelionPuffAttackSound
        call    PlaySound
        ld      a,[fireBulletLocation]   ;location of enemy
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        ld      a,MAPBANK
        ld      [$ff70],a
        ld      a,[hl]    ;enemy class index
        call    EnsureTileIsHead
        ld      c,a
        ld      d,h
        ld      e,l
        call    FindObject
        call    GetPuffCount
        cp      15
        ret     z
        add     1
        call    SetPuffCount
        ret

.noEnemy
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jp      StdMove

.dandelionPuffCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      .dandelionPuffAttackSound
        DB      1      ;fire delay
        DW      StdVectorToState

.dandelionPuffAttackSound
        DB      1,$7c,$80,$f4,$00,$84

;----Mouse------------------------------------------------------------
MouseInit:
        ld      hl,.mouseInitTable
        jp      StdInitFromTable

.mouseInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_HERO       ;group
        DB      1                ;has bullet
        DW      classUberMouse   ;associated bullet class ptr
        DW      UBERMOUSE_CINDEX

MouseCheck:
        ;health >= 5?
        call    GetHealth
        cp      5
        jr      c,.mouseCheck

        ;want to become UberMouse
        ld      a,63
        call    SetHealth
        call    GetFacing    ;must not be split or sprite
        and     %10000100
        jr      nz,.mouseCheck

        ;adjacent locations must be clear
        call    GetCurLocation
        inc     hl
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        jr      nz,.mouseCheck    ;not empty

        ld      a,[mapPitch]
        add     l
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a
        ld      a,[hl-]
        or      a
        jr      nz,.mouseCheck
        ld      a,[hl]
        or      a
        jr      nz,.mouseCheck

        jp      ChangeMyClassToAssociatedAndRedraw

.mouseCheck
        ld      hl,.mouseCheckTable
        jp      StdCheckFromTable

.mouseCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .mouseFireSound
        DB      4      ;fire delay
        DW      StdVectorToState

.mouseFireSound
        DB      1,$17,$80,$f0,$00,$c7


;----Penguin----------------------------------------------------------
PenguinInit:
        ld      hl,.penguinInitTable
        jp      StdInitFromTable

.penguinInitTable
        DB      4                ;initial facing
        DB      5                ;health
        DB      GROUP_MONSTERB   ;group
        DB      0                ;has bullet

PenguinCheck:
        ld      hl,.penguinCheckTable
        jp      StdCheckFromTable

.penguinCheckTable
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .penguinFireSound
        DB      4      ;fire delay
        DW      TrackEnemyVectorToState

.penguinFireSound
        DB      1,$2e,$c0,$f0,$00,$c6

;----BIOS-------------------------------------------------------------
BIOSInit:
        ld      hl,.BIOSInitTable
        jp      StdInitFromTable

.BIOSInitTable
        DB      4                ;initial facing
        DB      4                ;health
        DB      GROUP_MONSTERA   ;group
        DB      0                ;has bullet

BIOSCheck:
        ld      hl,.BIOSCheckTable
        jp      StdCheckFromTable

.BIOSCheckTable
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .BIOSFireSound
        DB      4      ;fire delay
        DW      TrackEnemyVectorToState

.BIOSFireSound
        DB      1,$01,$00,$f0,$00,$c4

;----Crouton Hulk-----------------------------------------------------
CroutonHulkInit:
        ld      hl,.croutonHulkInitTable
        jp      StdInitFromTable

.croutonHulkInitTable
        DB      4                ;initial facing
        DB      10               ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classCroutonBullet ;associated bullet class ptr
        DW      CROUTONBULLET_CINDEX

CroutonHulkCheck:
        ld      hl,.croutonHulkCheckTable
        jp      StdCheckFromTable

.croutonHulkCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      hulkFireSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

CroutonGruntInit:
        ld      hl,.croutonGruntInitTable
        jp      StdInitFromTable

.croutonGruntInitTable
        DB      4                ;initial facing
        DB      5                ;health
        DB      GROUP_MONSTERA   ;group
        DB      0                ;has bullet

;----Crouton Grunt----------------------------------------------------
CroutonGruntCheck:
        ld      hl,.croutonGruntCheckTable
        jp      StdCheckFromTable

.croutonGruntCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      gruntFireSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

;----Wolf-------------------------------------------------------------
WolfSheepInit:
        ld      hl,.wolfSheepInitTable
        jp      StdInitFromTable

.wolfSheepInitTable
        DB      4                ;initial facing
        DB      3                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classWolf        ;associated bullet class ptr
        DW      WOLF_CINDEX

WolfInit:
        ld      hl,.wolfInitTable
        call    StdInitFromTable

        call    LinkAssocToMe

        jp      ChangeMyClassToAssociatedAndRedraw

.wolfInitTable:
        DB      4                ;initial facing
        DB      3                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classWolfSheep   ;associated bullet class ptr
        DW      SHEEP_CINDEX

WolfCheck:
        call    StdCheckDead
        ret     z

        ld      hl,.wolfCheckTable
        call    StdCheckFromTableNotDead

        call    GetAttackDelay
        or      a
        jr      z,.checkChangeToSheep

        ld      a,100        ;delay until I can change back
        call    SetMisc
        ret

.checkChangeToSheep
        ;turn back into a sheep after bit
        call    GetMisc     ;countdown until sheep
        dec     a
        ld      [hl],a
        ret     nz
        jp      ChangeMyClassToAssociatedAndRedraw

.wolfCheckTable:
        DB      2      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      wolfFireSound
        DB      6      ;fire delay
        DW      TrackEnemyVectorToState

WolfSheepCheck:
        call    StdCheckDead
        ret     z

        ld      hl,.wolfSheepCheckTable
        call    StdCheckFromTableNotDead

        ;turn into a wolf if I attacked somebody
        call    GetAttackDelay     ;attacked this round?
        or      a
        ret     z

        ;change into wolf
        ld      a,100        ;delay until I can change back
        call    SetMisc
        jp      ChangeMyClassToAssociatedAndRedraw

.wolfSheepCheckTable:
        DB      5      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      wolfFireSound
        DB      6      ;fire delay
        DW      TrackEnemyVectorToState

wolfFireSound:
        DB      1,$1d,$40,$f2,$00,$82

WolfSheepTakeDamage:
        call    StdTakeDamage

        ;change into wolf
        ld      a,100        ;delay until I can change back
        call    SetMisc
        jp      ChangeMyClassToAssociatedAndRedraw

;---------------------------------------------------------------------
;  LinkAssocToMe
;---------------------------------------------------------------------
LinkAssocToMe:
        push    bc
        ld      b,c  ;this->assoc->assoc = this
        call    GetAssociated
        ld      c,a
        call    SetAssociated
        pop     bc
        ret

;----Snake------------------------------------------------------------
SnakeInit:
        ld      hl,.snakeInitTable
        jp      StdInitFromTable

.snakeInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

SnakeCheck:
        push    bc
        ld      bc,ITEM_SNAKEBITEKIT
        call    HasInventoryItem
        pop     bc
        jr      z,.checkNoKit

.checkWithKit
        ld      hl,.snakeCheckTable
        jp      StdCheckFromTable

.checkNoKit
        ld      hl,.snakeCheckTableNoKit
        jp      StdCheckFromTable

.snakeCheckTable
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .snakeFireSound
        DB      4      ;fire delay
        DW      TrackEnemyVectorToState

.snakeCheckTableNoKit
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      20     ;bullet damage
        DW      .snakeFireSound
        DB      4      ;fire delay
        DW      TrackEnemyVectorToState

.snakeFireSound
        DB      4,$00,$f3,$41,$80

;----Neanderthal------------------------------------------------------
NeanderthalInit:
        ld      hl,.neanderthalInitTable
        call    StdInitFromTable
        ld      a,4
        jp      SetMisc      ;direction throwing enemy 4=none

.neanderthalInitTable
        DB      4                ;initial facing
        DB      6                ;health
        DB      GROUP_MONSTERD   ;group
        DB      0                ;has bullet

NeanderthalCheck:
        ld      hl,.neanderthalCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
        call    .neanderthalCheckAttack
        ret     z
        call    StdMove
        ret

.neanderthalCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .neanderthalAttackSound
        DB      20     ;fire delay
        DW      TrackEnemyVectorToState

.neanderthalCheckAttack
        ;can I attack yet?
        push    hl
        call    DecrementAttackDelay
        pop     hl
        or      a
        jr      nz,.attackOkay
        inc     hl
.didntFindEnemy
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jr      .skipAttack

.attackOkay
        ld      a,[hl+]

.meleeOnly
        ld      a,1
        ld      [losLimit],a
        call    LookForEnemyInLOS        ;returns dir of enemy in b
        or      a
        jr      z,.didntFindEnemy

.foundEnemy

        ;Fire instead of moving
        ld      a,[curObjWidthHeight]
        push    af

        ld      a,[hl+]   ;bullet damage
        push    hl
        push    af

        ld      a,[hl+]   ;hl = fire sound
        ld      h,[hl]
        ld      l,a

        pop     af             ;damage
        call    StdFireBullet  ;b is direction to fire
        pop     hl
        inc     hl
        inc     hl
        ld      a,[hl+]        ;delay
        call    SetAttackDelay

        ;throw enemy object away from us
        push    hl
        ld      a,[fireBulletLocation]
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        call    ThrowObjAtHLInDirB
        pop     hl

        pop     af
        ld      [curObjWidthHeight],a

        ;turn to face the direction we just fired
        call    GetFacing
        and     %11
        cp      b
        jr      z,.skipMove  ;no need to turn

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StandardValidateMoveAndRedraw

        jr      .skipMove

.skipAttack
        ld      a,1 ;return nz (go ahead and move)
        or      a
        ret

.skipMove
        xor     a   ;return z (skip move)
        ret

.neanderthalAttackSound
        DB      1,$79,$c0,$f3,$00,$c3

ThrowObjAtHLInDirB:
        push    bc
        push    de
        push    hl
        ldio    a,[curObjWidthHeight]
        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        ldio    a,[firstMonster]
        ld      c,a
        ld      a,[hl]
        cp      c
        jr      c,.done   ;no monster here

        call    EnsureTileIsHead
        ld      d,h
        ld      e,l
        ld      c,a
        call    GetFGAttributes
        and     FLAG_NOTHROW
        jr      nz,.done

        call    FindObject
        call    SetObjWidthHeight
        call    StandardValidateMoveAndRedraw
        call    StandardValidateMoveAndRedraw
        call    PointToSpecialFlags
        set     OBJBIT_THROWN,[hl]

        ;set timer to current-1 to ensure this moves next check
        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[hl]
        and     %11100111
        ld      b,a
        ld      a,[objTimer60ths]
        sub     %00001000
        and     %00011000
        or      b
        ld      [hl+],a
        ld      [hl],1      ;can move next turn

.done
        pop     af
        ldio    [curObjWidthHeight],a
        pop     hl
        pop     de
        pop     bc
        ret

;----Crow-------------------------------------------------------------
CrowInit:
        ld      hl,.crowInitTable
        call    StdInitFromTable
        ld      hl,0
        call    SetFoodIndexRange
        ret

.crowInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

CrowCheck:
        ld      hl,.crowCheckTable
        jp      StdCheckFromTable

.crowCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .crowSound
        DB      20     ;fire delay
        DW      EatVectorToState

.crowSound
        DB      1,$4c,$80,$f0,$00,$c5

;----Scarecrow--------------------------------------------------------
ScarecrowInit:
        ld      hl,.scarecrowInitTable
        jp      StdInitFromTable

.scarecrowInitTable
        DB      1                ;initial facing
        DB      20               ;health
        DB      GROUP_MONSTERN   ;group
        DB      0                ;has bullet

ScarecrowCheck:
        ld      hl,.crowCheckTable
        jp      StdCheckFromTable

.crowCheckTable
        DB      0      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      nullSound
        DB      20     ;fire delay
        DW      0

ScarecrowTakeDamage:
        ;call    GetFacing
        ;xor     %10
        ;call    SetFacing
        ;ld      b,METHOD_DRAW
        ;call    CallMethod
        jp      StdTakeDamage2x2

;----Alligator--------------------------------------------------------
AlligatorInit:
        ld      hl,.alligatorInitTable
        jp      StdInitFromTable
.alligatorInitTable
        DB      4                ;initial facing
        DB      13               ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

AlligatorCheck:
        call    StdCheckDead
        ret     z

        ;save original facing
        call    GetFacing
        and     %00000011
        push    af

        ld      hl,.alligatorCheckTable
        call    StdCheckFromTableNotDead

        ;if facing changes set move delay to 10
        call    GetFacing
        and     %00000011
        pop     bc
        cp      b
        ret     z
        ld      a,10
        call    SetMoveDelay
        ret

.alligatorCheckTable
        DB      2      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .alligatorAttackSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

.alligatorAttackSound
        DB      1,$d9,$00,$f0,$00,$c4

;----Scorpion---------------------------------------------------------
ScorpionInit:
        ld      hl,.scorpionInitTable
        jp      StdInitFromTable

.scorpionInitTable
        DB      4         ;initial facing
        DB      2         ;health
        DB      GROUP_MONSTERC
        DB      0         ;has bullet

ScorpionCheck:
        ld      hl,.scorpionCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
        call    .scorpionCheckAttack
        ret     z
        call    StdMove
        ret

.scorpionCheckAttack
        ;can I attack yet?
        push    hl
        call    DecrementAttackDelay
        pop     hl
        or      a
        jr      nz,.attackOkay
        inc     hl
.didntFindEnemy
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jr      .skipAttack

.attackOkay
        ld      a,[hl+]

.meleeOnly
        ld      a,1
        ld      [losLimit],a
        call    LookForEnemyInLOS        ;returns dir of enemy in b
        or      a
        jr      z,.didntFindEnemy

.foundEnemy
        ;Fire instead of moving
        ld      a,[curObjWidthHeight]
        push    af

        ld      a,[hl+]   ;bullet damage
        push    hl
        push    af

        ld      a,[hl+]   ;hl = fire sound
        ld      h,[hl]
        ld      l,a

        pop     af             ;damage
        call    StdFireBullet  ;b is direction to fire
        pop     hl
        inc     hl
        inc     hl
        ld      a,[hl+]        ;delay
        call    SetAttackDelay

        ;freeze enemy
        push    bc
        push    de
        push    hl
        ld      a,[fireBulletLocation]
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    EnsureTileIsHead
        ld      d,h
        ld      e,l
        ld      c,a
        call    FindObject

        ;freeze the enemy for a bit
        call    GetHealth
        or      a
        jr      z,.afterFreeze

        ld      a,60
        call    SetMoveDelay

        call    GetHealth   ;deal 1 point of damage
        dec     a           ;(so can't get stuck with Haiku)
        call    SetHealth

.afterFreeze
        pop     hl
        pop     de
        pop     bc

        pop     af
        ld      [curObjWidthHeight],a

        ;turn to face the direction we just fired
        call    GetFacing
        and     %11
        cp      b
        jr      z,.skipMove  ;no need to turn

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StandardValidateMoveAndRedraw

        jr      .skipMove

.skipAttack
        ld      a,1 ;return nz (go ahead and move)
        or      a
        ret

.skipMove
        xor     a   ;return z (skip move)
        ret

.scorpionCheckTable
        DB      5    ;move delay
        DB      1    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      scorpionFireSound
        DB      15   ;fire delay
        DW      StdVectorToState

scorpionFireSound:
        DB      1,$3b,$c0,$f0,$00,$c4


;----Bow--------------------------------------------------------------
BowInit:
        ld      hl,.bowInitTable
        jp      StdInitFromTable

.bowInitTable
        DB      4         ;initial facing
        DB      3         ;health
        DB      GROUP_MONSTERC
        DB      1         ;has bullet
        DW      classArrowBullet
        DW      ARROWBULLET_CINDEX

BowCheck:
        ld      hl,.bowCheckTable
        jp      StdCheckFromTable

.bowCheckTable
        DB      3    ;move delay
        DB      2    ;attack type (0=none,1=melee,2=missile)
        DB      2    ;bullet damage
        DW      bowFireSound
        DB      8    ;fire delay
        DW      StdVectorToState

bowFireSound:
        DB      1,$25,$00,$f0,$00,$c3

;----Cowboy-----------------------------------------------------------
CowboyInit:
        ld      hl,.cowboyInitTable
        jp      StdInitFromTable

.cowboyInitTable
        DB      4         ;initial facing
        DB      4         ;health
        DB      GROUP_MONSTERM  ;friends
        DB      1         ;has bullet
        DW      classCowboyBullet
        DW      COWBOYBULLET_CINDEX

CowboyCheck:
        ld      hl,.cowboyCheckTable
        jp      StdCheckFromTable

.cowboyCheckTable
        DB      3    ;move delay
        DB      2    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      cowboyFireSound
        DB      6    ;fire delay
        DW      StdVectorToState

cowboyFireSound:
        DB      4,$00,$f2,$42,$80

AngryCowboyCheck:
        ld      hl,.cowboyCheckTable
        jp      StdCheckFromTable

.cowboyCheckTable
        DB      2    ;move delay
        DB      2    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      cowboyFireSound
        DB      6    ;fire delay
        DW      TrackEnemyVectorToState

;----Crouton Doctor / Guard-------------------------------------------
CroutonDoctorInit:
        ld      hl,.croutonDoctorInitTable
        jp      StdInitFromTable

.croutonDoctorInitTable
        DB      4                ;initial facing
        DB      3                ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classCroutonBullet ;associated bullet class ptr
        DW      CROUTONBULLET_CINDEX

CroutonDoctorCheck:
        ld      hl,.croutonDoctorCheckTable
        jp      StdCheckFromTable

.croutonDoctorCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      guardFireSound
        DB      6      ;fire delay
        DW      TrackEnemyVectorToState

;----Crouton Wizard---------------------------------------------------
CroutonWizardInit:
        ld      hl,.croutonWizardInitTable
        jp      StdInitFromTable

.croutonWizardInitTable
        DB      4                ;initial facing
        DB      3                ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classWizardBullet ;associated bullet class ptr
        DW      WIZARDBULLET_CINDEX

CroutonWizardCheck:
        ld      hl,.croutonWizardCheckTable
        jp      StdCheckFromTable

.croutonWizardCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      .wizardFireSound
        DB      6      ;fire delay
        DW      TrackEnemyVectorToState

.wizardFireSound
        DB      1,$34,$40,$f6,$00,$81

;----Big Bee Hive-----------------------------------------------------
BigBeeHiveCheck:
        ;randomly create a bee every so often
        ld      a,127
        call    GetRandomNumMask
        or      a
        jr      nz,.afterCreateBee

        ld      a,[numFreeObjects]
        cp      (255-32)
        jr      c,.afterCreateBee

        call    FindEmptyLocationAround2x2
        ld      a,h
        or      a
        jr      z,.afterCreateBee

        push    bc
        push    de
        ld      bc,classBee
        call    FindClassIndex
        or      a
        jr      z,.afterCreateObject
        ld      c,a
        call    CreateInitAndDrawObject
.afterCreateObject
        pop     de
        pop     bc

.afterCreateBee
        ld      hl,.bigBeeHiveCheckTable
        jp      StdCheckFromTable

.bigBeeHiveCheckTable
        DB      0      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      beeSound
        DB      20     ;fire delay
        DW      0

;----Sheep------------------------------------------------------------
SheepCheck:
        call    GetHealth
        or      a
        jr      nz,.afterChangeToDrumstick

        call    GetCurLocation
        push    hl
        call    StandardDie
        pop     hl

        ld      bc,classDrumstickBG
        call    FindClassIndex
        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        pop     af
        ld      [hl],a

        jp      ResetMyBGSpecialFlags

.afterChangeToDrumstick
        jp      GenericCheck

;----Chicken----------------------------------------------------------
ChickenInit:
        ld      hl,.chickenInitTable
        jp      StdInitFromTable

.chickenInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERB   ;group
        DB      1                ;has bullet
        DW      classEgg
        DW      EGG_CINDEX

ChickenCheck:
        ;lay egg?
        ld      a,255
        call    GetRandomNumMask
        or      a
        jr      nz,.afterLayEgg
        ldio    a,[updateTimer]
        and     %11
        or      a
        jr      nz,.afterLayEgg
        ld      a,[numFreeObjects]
        cp      200
        jr      c,.afterLayEgg

        push    bc
        call    GetAssociated
        ld      c,a
        call    FindEmptyLocationAround1x1
        or      a
        jr      z,.afterCreateEgg
        push    de
        call    CreateInitAndDrawObject
        pop     de
.afterCreateEgg
        pop     bc

.afterLayEgg
        ld      hl,.chickenCheckTable
        jp      StdCheckFromTable

.chickenCheckTable
        DB      5      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      nullSound
        DB      30     ;fire delay
        DW      StdVectorToState

;----Wisp-------------------------------------------------------------
WispInit:
        ld      hl,.wispInitTable
        jp      StdInitFromTable

.wispInitTable
        DB      4                ;initial facing
        DB      1                ;health
        DB      GROUP_MONSTERC   ;group
        DB      0                ;has bullet

WispCheck:
        ld      hl,.wispCheckTable
        call    StdCheckDead
        ret     z
        call    StdCheckTimeToMove
        ret     z
        call    .wispCheckAttack
        ret     z
        call    StdMove
        ret

.wispCheckAttack
        ;can I attack yet?
        push    hl
        call    DecrementAttackDelay
        pop     hl
        or      a
        jr      nz,.attackOkay
        inc     hl
.didntFindEnemy
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jp      .skipAttack

.attackOkay
        ld      a,[hl+]

.meleeOnly
        ld      a,1
        ld      [losLimit],a
        call    LookForEnemyInLOS        ;returns dir of enemy in b
        or      a
        jr      z,.didntFindEnemy

.foundEnemy
        ;Fire instead of moving
        ld      a,[curObjWidthHeight]
        push    af

        ld      a,[hl+]   ;bullet damage
        push    hl
        push    af

        ld      a,[hl+]   ;hl = fire sound
        ld      h,[hl]
        ld      l,a

        pop     af             ;damage
        call    StdFireBullet  ;b is direction to fire
        pop     hl
        inc     hl
        inc     hl
        ld      a,[hl+]        ;delay
        call    SetAttackDelay

        push    bc
        ;exchange enemy with another randomly selected wisp
        ld      a,c
        call    CountNumObjects
        dec     a
        jr      z,.afterExchange
        call    GetRandomNumZeroToN

        ld      b,a
        inc     b

        push    bc   ;save my class and object
        push    de

        call    GetFirst
        dec     b
        jr      z,.foundRemoteWisp

.findWisp
        call    GetNextObject
        dec     b
        jr      nz,.findWisp

.foundRemoteWisp
        ;save remote wisp's class and object
        push    bc
        push    de

        call    GetCurLocation
        push    hl

        call    .wispRemove

        call    GetFireTargetAsObject
        call    GetCurLocation
        push    hl
        call    .wispRemove
        ld      hl,sp+2     ;other object's location
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        call    SetCurLocation
        ld      b,METHOD_DRAW
        call    CallMethod

        ;reset camera if it was the hero that was moved
        LDHL_CURHERODATA HERODATA_OBJ
        ld      a,[hl+]
        cp      e
        jr      nz,.afterResetCamera
        ld      a,[hl+]
        cp      d
        jr      nz,.afterResetCamera

        call    AdjustCameraToHero
        call    RestrictCameraToBounds
        ld      a,[desiredMapLeft]
        ld      [mapLeft],a
        ld      a,[desiredMapTop]
        ld      [mapTop],a
.afterResetCamera

        pop     hl
        pop     de    ;first location(discard)

        pop     de    ;first object
        pop     bc
        call    SetCurLocation
        ld      b,METHOD_DRAW
        call    CallMethod

.exchangeDone
        pop     de
        pop     bc
.afterExchange
        pop     bc

        pop     af
        ld      [curObjWidthHeight],a

        ;turn to face the direction we just fired
        call    GetFacing
        and     %11
        cp      b
        jr      z,.skipMove  ;no need to turn

        ld      a,1
        ld      [moveAlignPrecision],a
        call    StandardValidateMoveAndRedraw

        jr      .skipMove

.skipAttack
        ld      a,1 ;return nz (go ahead and move)
        or      a
        ret

.skipMove
        xor     a   ;return z (skip move)
        ret

.wispCheckTable
        DB      3      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .wispFireSound
        DB      4      ;fire delay
        DW      StdVectorToState

.wispFireSound
        DB      1,$75,$c0,$f0,$00,$c6

.wispRemove
        call    GetFGAttributes
        and     FLAG_2X2
        swap    a
        ldio    [curObjWidthHeight],a
        call    GetFacing
        push    bc
        ld      c,a
        call    RemoveFromMap
        pop     bc
        call    GetFacing
        and     %11111011     ;turn off split
        jp      SetFacing

;----GetFireTargetAsObject--------------------------------------------
GetFireTargetAsObject:
        ld      a,[fireBulletLocation]
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    EnsureTileIsHead
        ld      d,h
        ld      e,l
        ld      c,a
        jp      FindObject

;----Quatrain---------------------------------------------------------
QuatrainInit:
        ld      hl,.quatrainInitTable
        jp      StdInitFromTable

.quatrainInitTable
        DB      4                ;initial facing
        DB      10               ;health
        DB      GROUP_MONSTERA   ;group
        DB      0                ;has bullet

QuatrainCheck:
        ld      hl,.quatrainCheckTable
        jp      StdCheckFromTable

.quatrainCheckTable
        DB      1      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      nullSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

;----Crouton Goblin---------------------------------------------------
CroutonGoblinInit:
        ld      hl,.croutonGoblinInitTable
        jp      StdInitFromTable
.croutonGoblinInitTable
        DB      4                ;initial facing
        DB      1                ;health
        DB      GROUP_MONSTERA   ;group
        DB      0                ;has bullet

CroutonGoblinCheck:
        ld      hl,.croutonGoblinCheckTable
        jp      StdCheckFromTable

.croutonGoblinCheckTable
        DB      2      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      goblinSound
        DB      3      ;fire delay
        DW      TrackEnemyVectorToState

;----General Gyro-----------------------------------------------------
GeneralGyroInit:
        ld      hl,.gyroInitTable
        jp      StdInitFromTable
.gyroInitTable
        DB      4                ;initial facing
        DB      63               ;health (max)
        DB      GROUP_MONSTERA   ;group
        DB      0                ;has bullet

;----Crouton Artillery------------------------------------------------
CroutonArtilleryInit:
        ld      hl,.croutonArtilleryInitTable
        jp      StdInitFromTable
.croutonArtilleryInitTable
        DB      4                ;initial facing
        DB      10               ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classRocketBullet ;associated bullet class ptr
        DW      CROUTONROCKET_CINDEX

CroutonArtilleryCheck:
        call    StdCheckDead
        ret     z

        ;save original facing
        call    GetFacing
        and     %00000011
        push    af

        ld      hl,.croutonArtilleryCheckTable
        call    StdCheckFromTableNotDead

        ;if facing changes set move delay to 15
        call    GetFacing
        and     %00000011
        pop     bc
        cp      b
        ret     z
        ld      a,15
        call    SetMoveDelay
        ret

.croutonArtilleryCheckTable
        DB      3      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      6      ;bullet damage
        DW      rocketFireSound
        DB      10     ;fire delay
        DW      TrackEnemyVectorToState

;----Teleport Cube----------------------------------------------------
TeleportCubeInit:
        ld      hl,.cubeInitTable
        call    StdInitFromTable
        jp      LinkAssocToMe

.cubeInitTable
        DB      1                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classTeleportCube2
        DW      TCUBE2_CINDEX

TeleportCubeCheck:
        call    GetCurLocation
        push    hl
        call    StdCheckDead
        pop     hl
        jr      nz,.tick

        ;died because of being shot (was timer up?)
        push    hl
        call    GetMisc
        pop     hl
        cp      254
        ret     nz

        ;finished; resolve into one or more enemies
        ld      a,3
        call    GetRandomNumMask
        cp      2
        jr      nc,.cluster

        ;one big enemy
        or      a
        jr      nz,.artillery

        ;create a hulk
        ld      bc,classCroutonHulk
        jr      .createSingle

.artillery
        ld      bc,classCroutonArtillery
.createSingle
        call    FindClassIndex
        ret     z
        ld      c,a
        jp      CreateInitAndDrawObject

.cluster
        ;create a cluster of grunts or goblins
        and     1
        jr      nz,.goblins

        ld      bc,classCroutonGrunt
        jr      .createCluster

.goblins
        ;goblins
        ld      bc,classCroutonGoblin
.createCluster
        call    FindClassIndex
        ret     z
        ld      c,a
        call    CreateInitAndDrawObject
        inc     hl
        call    CreateInitAndDrawObject
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        call    CreateInitAndDrawObject
        dec     hl
        jp      CreateInitAndDrawObject

.tick
        call    GetMisc
        add     2
        ld      [hl],a
        cp      254
        jr      nz,.notFinished

        xor     a
        call    SetHealth
        ret

.notFinished
        ;determine how fast we're flashing
        ld      a,[hl]
        cp      226
        jr      nc,.speed1
        cp      200
        jr      nc,.speed2
        cp      150
        jr      nc,.speed3
        cp      100
        jr      nc,.speed4
.speed5
        ldio    a,[updateTimer]
        and     %11111
        jr      .checkFlash

.speed4
        ldio    a,[updateTimer]
        and     %1111
        jr      .checkFlash

.speed3
        ldio    a,[updateTimer]
        and     %111
        jr      .checkFlash

.speed2
        ldio    a,[updateTimer]
        and     %11
        jr      .checkFlash

.speed1
        xor     a

.checkFlash
        ret     nz

        ld      hl,.flashSound
        call    PlaySound
        jp      ChangeMyClassToAssociatedAndRedraw

.flashSound
  DB 1,$35,$40,$f0,$00,$c4

TeleportCubeCheck2:
        call    StdCheckDead
        ret     z
        jp      ChangeMyClassToAssociatedAndRedraw

;----Dandelion Guard--------------------------------------------------
DandelionGuardInit:
        ld      hl,.dandelionGuardInitTable
        jp      StdInitFromTable

.dandelionGuardInitTable
        DB      4                ;initial facing
        DB      5                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classPansyBullet ;associated bullet class ptr
        DW      PANSYBULLET_CINDEX

DandelionGuardCheck:
        ld      hl,.dandelionGuardCheckTable
        jp      StdCheckFromTable

.dandelionGuardCheckTable
        DB      3      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      .dandelionGuardFireSound
        DB      8      ;fire delay
        DW      TrackEnemyVectorToState

.dandelionGuardFireSound
        DB      1,$32,$80,$f0,$00,$c3

;----B12 Soldier------------------------------------------------------
B12SoldierInit:
        ld      hl,.b12SoldierInitTable
        jp      StdInitFromTable

.b12SoldierInitTable
        DB      4                ;initial facing
        DB      8                ;health
        DB      GROUP_MONSTERB   ;group
        DB      1                ;has bullet
        DW      classB12SoldierBullet   ;associated bullet class ptr
        DW      B12SOLDIERBULLET_CINDEX

B12SoldierCheck:
        ld      hl,.b12SoldierCheckTable
        jp      StdCheckFromTable

.b12SoldierCheckTable
        DB      3      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      baFireSound
        DB      5      ;fire delay
        DW      TrackEnemyVectorToState

;----Big Spider-------------------------------------------------------
BigSpiderInit:
        ld      hl,.bigSpiderInitTable
        jp      StdInitFromTable

.bigSpiderInitTable
        DB      4                ;initial facing
        DB      9                ;health
        DB      GROUP_MONSTERE   ;group
        DB      0                ;has bullet

BigSpiderCheck:
        ld      hl,.bigSpiderCheckTable
        jp      StdCheckFromTable

.bigSpiderCheckTable
        DB      12     ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      .bigSpiderSound
        DB      5      ;fire delay
        DW      StdVectorToState

.bigSpiderSound
        DB      $33,$80,$f0,$00,$c5

;----Little Spider----------------------------------------------------
LittleSpiderInit:
        ld      hl,.littleSpiderInitTable
        jp      StdInitFromTable

.littleSpiderInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERE   ;group
        DB      0                ;has bullet

LittleSpiderCheck:
        ld      hl,.littleSpiderCheckTable
        jp      StdCheckFromTable

.littleSpiderCheckTable
        DB      10     ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .littleSpiderSound
        DB      5      ;fire delay
        DW      StdVectorToState

.littleSpiderSound
        DB      $33,$80,$f0,$60,$c5

;----Invisible Bat----------------------------------------------------
InvisibleBatCheck:
        call    StdCheckDead
        ret     z

        ld      hl,.invisibleBatCheckTable
        call    StdCheckFromTableNotDead

        ;make a noise every so often
        ld      hl,updateTimer
        ld      a,e
        rrca
        rrca
        rrca
        add     [hl]
        and     %11111
        cp      %10000
        jr      nz,.checkAttack

        ld      hl,batFireSound
        call    PlaySound

.checkAttack
        call    GetAttackDelay   ;attacked someone?
        or      a
        ret     z

        call    ChangeMyClassToAssociatedAndRedraw
        ld      a,50             ;delay until invisible
        jp      SetMisc

.invisibleBatCheckTable
        DB      3    ;move delay
        DB      1    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      batFireSound
        DB      20   ;fire delay
        DW      TrackEnemyVectorToState

InvisibleBatTakeDamage:
        call    StdTakeDamage

        call    ChangeMyClassToAssociatedAndRedraw
        ld      a,50             ;delay until invisible
        jp      SetMisc


;----Slime------------------------------------------------------------
SlimeInit:
        call    GetCurLocation
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl],a  ;clear slime BG tile I'm on

        ld      hl,.slimeInitTable
        jp      StdInitFromTable

.slimeInitTable
        DB      4         ;initial facing
        DB      1         ;health
        DB      GROUP_MONSTERC
        DB      0         ;has bullet

SlimeCheck:
        ld      hl,.slimeCheckTable
        jp      StdCheckFromTable

.slimeCheckTable
        DB      4    ;move delay
        DB      1    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      .slimeFireSound
        DB      20   ;fire delay
        DW      TrackEnemyVectorToState

.slimeFireSound
        DB      1,$35,$00,$f0,$00,$c7

;----Egg--------------------------------------------------------------
EggInit:
        ld      hl,.eggInitTable
        call    StdInitFromTable
        ld      a,255
        jp      SetMisc   ;turns until hatch

.eggInitTable
        DB      1         ;initial facing
        DB      2         ;health
        DB      GROUP_MONSTERN
        DB      1         ;has bullet
        DW      classChicken
        DW      CHICKEN_CINDEX

;----Monkey-----------------------------------------------------------
MonkeyInit:
        push    bc
        push    de
        ld      de,classSleepingMonkey
        ld      hl,MONKEY_CINDEX
        ld      a,1
        call    LoadAssociatedClass
        pop     de
        pop     bc

        ld      hl,.monkeyInitTable
        jp      StdInitFromTable

.monkeyInitTable
        DB      4         ;initial facing
        DB      2         ;health
        DB      GROUP_MONSTERD
        DB      1         ;has bullet
        DW      classBananaBullet
        DW      BANANABULLET_CINDEX

MonkeyCheck:
        ld      hl,.monkeyCheckTable
        jp      StdCheckFromTable

.monkeyCheckTable
        DB      3    ;move delay
        DB      2    ;attack type (0=none,1=melee,2=missile)
        DB      1    ;bullet damage
        DW      monkeyFireSound
        DB      4    ;fire delay
        DW      TrackEnemyVectorToState

monkeyFireSound:
        DB      1,$57,$2a,$f3,$10,$c7

;----Duke-------------------------------------------------------------
DukeInit:
        ld      hl,.dukeInitTable
        jp      StdInitFromTable
.dukeInitTable
        DB      4                ;initial facing
        DB      63               ;health (max)
        DB      GROUP_MONSTERD   ;group
        DB      1                ;has bullet
        DW      classBananaBullet
        DW      BANANABULLET_CINDEX

DukeCheck:
        ld      hl,.dukeCheckTable
        jp      StdCheckFromTable

.dukeCheckTable
        DB      5      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      3      ;bullet damage
        DW      monkeyFireSound
        DB      3      ;fire delay
        DW      StdVectorToState

;----Pig--------------------------------------------------------------
PigCheck:
        call    GetHealth
        or      a
        jr      nz,.afterPorkProducts

        call    GetCurLocation
        push    hl
        call    StandardDie
        pop     hl

        ld      bc,classPorkBG
        call    FindClassIndex
        ld      b,a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,2
        call    GetRandomNumZeroToN
        add     b
        ld      [hl],a

        call    ResetMyBGSpecialFlags
        ret

.afterPorkProducts
        jp      GenericCheck


EggCheck:
        call    GetHealth
        or      a
        jr      nz,.afterFried

        call    GetCurLocation
        push    hl
        call    StandardDie
        pop     hl

        ld      bc,classFriedEggBG
        call    FindClassIndex
        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        pop     af
        ld      [hl],a

        call    ResetMyBGSpecialFlags
        ret

.afterFried
        call    GetMisc
        dec     [hl]
        jr      nz,.notHatchedYet

        ld      hl,.eggHatchSound
        call    PlaySound
        jp      ChangeMyClassToAssociatedAndRedraw

.notHatchedYet
        ld      hl,.eggCheckTable
        jp      StdCheckFromTable

.eggCheckTable
        DB      0    ;move delay
        DB      0    ;attack type (0=none,1=melee,2=missile)
        DB      0    ;bullet damage
        DW      nullSound
        DB      20   ;fire delay
        DW      0

.eggHatchSound
        DB      4,$1b,$f0,$62,$c0

;----Crouton Blower---------------------------------------------------
BlowerInit:
        ld      hl,.blowerInitTable
        jp      StdInitFromTable

.blowerInitTable
        DB      4         ;initial facing
        DB      4         ;health
        DB      GROUP_MONSTERA
        DB      0         ;has bullet

BlowerCheck:
        call    StdCheckDead
        ret     z

        ld      hl,.blowerCheckTable
        call    StdCheckFromTableNotDead

        ;handle 'firing' ourselves
        ;can we attack yet?
        call    DecrementAttackDelay
        or      a
        ret     z

        push    de
        call    GetFacing
        push    af
        and     %11
        call    GetLocInFront
        pop     af
        rlca
        and     %110
        push    hl
        ld      l,a
        ld      a,(mapOffsetNorth & $ff)
        add     l
        ld      l,a
        ld      h,((mapOffsetNorth>>8)&$ff)
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl]
        ld      d,a
        pop     hl

        xor     a
        ld      [losLimit],a
        call    ScanDirectionForEnemy    ;returns dir of enemy in b
        or      a
        jr      z,.doneDE

        ;blow the enemy away from me
        ld      a,[fireBulletLocation]   ;enemy's location
        ld      l,a
        ld      a,[fireBulletLocation+1]
        ld      h,a
        pop     de
        call    GetFacing
        and     %11
        call    ShiftObjectInDirection
        ld      a,3
        call    SetAttackDelay
        ld      hl,.blowerBlowSound
        call    PlaySound
        ret

.doneDE pop     de
        ret

.blowerCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=none,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      gruntFireSound
        DB      5       ;fire delay
        DW      TrackEnemyVectorToState

.blowerBlowSound
        DB      4,$00,$f5,$07,$80

;----Sleeping Monkey--------------------------------------------------
SleepingMonkeyInit:
        ld      hl,.sleepingMonkeyInitTable
        jp      StdInitFromTable

.sleepingMonkeyInitTable
        DB      4                ;initial facing
        DB      2                ;health (max)
        DB      GROUP_MONSTERD   ;group
        DB      1                ;has bullet
        DW      classMonkey
        DW      MONKEY_CINDEX

SleepingMonkeyCheck:
        ld      a,[guardAlarm]
        or      a
        jr      z,.check

        call    ChangeMyClassToAssociatedAndRedraw
        ld      de,classBananaBullet
        ld      hl,BANANABULLET_CINDEX
        ld      a,1
        jp      LoadAssociatedClass

.check
        ld      hl,.sleepingMonkeyCheckTable
        jp      StdCheckFromTable

.sleepingMonkeyCheckTable
        DB      0      ;move delay
        DB      0      ;attack type (0=no attack,1=melee,2=missile)
        DB      0      ;bullet damage
        DW      monkeyFireSound
        DB      3      ;fire delay
        DW      0

;----Bell-------------------------------------------------------------
BellInit:
        ld      hl,.bellInitTable
        call    StdInitFromTable

        jp      LinkAssocToMe

.bellInitTable
        DB      1                ;initial facing
        DB      63               ;health (max)
        DB      GROUP_MONSTERN   ;group
        DB      1                ;has bullet
        DW      classRingingBell
        DW      RINGINGBELL_CINDEX

;----Banana Tree------------------------------------------------------
BananaTreeInit:
        ld      hl,.bananaTreeInitTable
        jp      StdInitFromTable

.bananaTreeInitTable
        DB      1                ;initial facing
        DB      6                ;health (max)
        DB      GROUP_MONSTERN   ;group
        DB      0                ;has bullet

BananaTreeCheck:
        ;regain 1 health every few seconds
        ldio    a,[updateTimer]
        or      a
        jr      nz,.check

        call    GetHealth
        cp      6   ;at max?
        jr      nc,.check

        inc     a
        call    SetHealth
.check
        jp      DoNothingCheck

BananaTreeTakeDamage:
        ;create an adjacent banana that "fell off"
        call    FindEmptyLocationAround2x2
        or      a
        jr      z,.takeDamage

        push    bc
        ld      bc,classBananaBG
        call    FindClassIndex
        push    af
        ld      a,MAPBANK
        ldio    [$ff70],a
        pop     af
        ld      [hl],a
        pop     bc
        call    ResetMyBGSpecialFlags

.takeDamage
        jp      StdTakeDamage2x2

;----Hermit Crab No Shell---------------------------------------------
HermitNoShellInit:
        ld      hl,.hermitNoShellInitTable
        call    StdInitFromTable

        ;set misc to be class index of shell
        ld      bc,classHermitCrabShellBG
        call    FindClassIndex
        jp      SetMisc

.hermitNoShellInitTable
        DB      4                ;initial facing
        DB      3                ;health (max)
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classHermitInShell
        DW      HERMITINSHELL_CINDEX

HermitNoShellCheck:
        ;standing on shell?
        call    GetFacing
        bit     7,a       ;must be sprite
        jr      z,.notOnShell

        call    GetMisc
        ld      b,a

        call    GetCurLocation
        ld      a,TILESHADOWBANK
        ldio    [$ff70],a
        ld      a,[hl]
        cp      b
        jr      nz,.notOnShell

        ;get in shell
        ld      [hl],0     ;clear out shell
        push    bc
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        pop     bc

        ld      a,20
        call    SetHealth
        call    ChangeMyClassToAssociatedAndRedraw
        ret

.notOnShell
        ld      hl,.hermitNoShellCheckTable
        jp      StdCheckFromTable

.hermitNoShellCheckTable
        DB      5      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      crabAttackSound
        DB      4      ;fire delay
        DW      StdVectorToState

crabAttackSound:
        DB      1,$2c,$38,$f0,$00,$c6

;----Hermit Crab In Shell---------------------------------------------
HermitInShellCheck:
        ld      hl,.hermitInShellCheckTable
        jp      StdCheckFromTable

.hermitInShellCheckTable
        DB      4      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      crabAttackSound
        DB      4      ;fire delay
        DW      TrackEnemyVectorToState

;----Crab / Crab Burrowing -------------------------------------------
CrabInit:
        ld      hl,.crabInitTable
        call    StdInitFromTable
        ld      a,100            ;time till burrow
        jp      SetMisc

.crabInitTable
        DB      4                ;initial facing
        DB      3                ;health (max)
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classCrabBurrowing
        DW      CRABBURROWING_CINDEX

CrabCheck:
        ;can't burrow if sprite
        call    GetFacing
        bit     7,a
        jr      nz,.notBurrowing

        call    GetMisc
        dec     [hl]
        jr      nz,.notBurrowing

        ;take another step if split tile
        call    MoveForwardIfSplit
        jp      ChangeMyClassToAssociatedAndRedraw

.notBurrowing
        ld      hl,.crabCheckTable
        jp      StdCheckFromTable

.crabCheckTable
        DB      6      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      2      ;bullet damage
        DW      crabAttackSound
        DB      1      ;fire delay
        DW      TrackEnemyVectorToState

CrabBurrowingInit:
        ld      hl,.crabBurrowingInitTable
        call    StdInitFromTable
        xor     a
        call    SetMisc

        jp      LinkAssocToMe

.crabBurrowingInitTable
        DB      4                ;initial facing
        DB      3                ;health (max)
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classCrab
        DW      CRAB_CINDEX

CrabBurrowingCheck:
        ;fully burrowed yet?
        call    GetMisc
        cp      100
        jr      z,.burrowed
        cp      5
        jr      z,.burrowed

        inc     [hl]
        call    GetFacing
        ld      c,a
        jp      RemoveFromMap

.burrowed
        call    GetMisc   ;time to unburrow?
        cp      100
        jr      nz,.notUnburrowing

        call    GetCurLocation
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        ret     nz    ;can't unburrow when someone's on top

        call    GetFacing   ;clear split bit
        res     2,a
        call    SetFacing
        jp      ChangeMyClassToAssociatedAndRedraw

.notUnburrowing
        ;is an enemy on top of me?
        call    GetCurLocation
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        call    IsMyEnemy
        cp      1
        ret     nz

        ;flag to unburrow next time
        ld      a,100
        jp      SetMisc


;---------------------------------------------------------------------
;MoveForwardIfSplit
;---------------------------------------------------------------------
MoveForwardIfSplit:
        call    GetFacing
        bit     2,a
        ret     z
        and     %11
        ld      b,a
        jp      StandardValidateMoveAndRedraw

;----UberMouse--------------------------------------------------------
UberMouseCheck:
        ld      a,63      ;can never die
        call    SetHealth
        ld      hl,.uberMouseCheckTable
        jp      StdCheckFromTable

.uberMouseCheckTable
        DB      5      ;move delay
        DB      1      ;attack type (0=no attack,1=melee,2=missile)
        DB      5      ;bullet damage
        DW      .uberMouseFireSound
        DB      2      ;fire delay
        DW      TrackEnemyVectorToState

.uberMouseFireSound
        DB      1,$17,$00,$f0,$00,$c6

;----Turret-----------------------------------------------------------
TurretInit:
        ld      hl,.turretInitTable
        jp      StdInitFromTable
.turretInitTable
        DB      4                ;initial facing
        DB      20               ;health (max)
        DB      GROUP_MONSTERA   ;group
        DB      1                ;has bullet
        DW      classTurretBullet
        DW      TURRETBULLET_CINDEX

TurretCheck:
        ld      hl,.turretCheckTable
        jp      StdCheckFromTable

.turretCheckTable
        DB      2      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      .turretFireSound
        DB      1      ;fire delay
        DW      0

.turretFireSound
        DB      1,$3b,$80,$f3,$00,$83
        ;DB      1,$fa,$80,$f3,$00,$84

;----Pansy------------------------------------------------------------
PansyInit:
        ld      hl,.pansyInitTable
        jp      StdInitFromTable

.pansyInitTable
        DB      4                ;initial facing
        DB      2                ;health
        DB      GROUP_MONSTERC   ;group
        DB      1                ;has bullet
        DW      classPansyBullet ;associated bullet class ptr
        DW      PANSYBULLET_CINDEX

PansyCheck:
        ld      hl,.pansyCheckTable
        jp      StdCheckFromTable

.pansyCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      pansyFireSound
        DB      10     ;fire delay
        DW      TrackEnemyVectorToState

HippiePansyCheck:
        ld      hl,.hippiePansyCheckTable
        jp      StdCheckFromTable

.hippiePansyCheckTable
        DB      4      ;move delay
        DB      2      ;attack type (0=no attack,1=melee,2=missile)
        DB      1      ;bullet damage
        DW      pansyFireSound
        DB      10     ;fire delay
        DW      EatVectorToState

;---------------------------------------------------------------------
; ActorCheck
;---------------------------------------------------------------------
ActorCheck:
        push    bc
        push    de
        push    hl

        ;am I dead?
        call    GetHealth
        or      a
        jr      nz,.checkTimeToMove
        call    StandardDie
        jr      .done

.checkTimeToMove
        ;time to move?
        ld      a,2
        call    TestMove
        or      a
        jr      z,.skipMove       ;timer lsb==frame lsb, don't move yet

        ;xor     a
        ld      a,1
        ld      [moveAlignPrecision],a
        call    ActorVectorToState
        or      a
        jr      z,.skipMove
        call    StandardValidateMoveAndRedraw
.skipMove

.done   pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      LookForEnemyInLOS
; Arguments:    c  - class index of object
;               de - this
; Alters:       af,b
; Returns:      a  - 1=enemy spotted, 0=no enemy
;               b  - direction of enemy
;               [fireBulletLocation]
;                    loc adj to shooter to place bullet
;---------------------------------------------------------------------
LookForEnemyInLOS:
        push    hl

        ;save my group and direction first
        call    GetGroup
        ld      [myGroup],a

        call    GetAttackDirState
        or      a
        jr      nz,.scanEast

        ;de = north offset
        push    de
        ld      a,DIR_NORTH
        ld      [myFacing],a
        call    GetLocInFront
        ld      a,[mapOffsetNorth]    ;get North offset
        ld      e,a
        ld      a,[mapOffsetNorth+1]
        ld      d,a

        call    ScanDirectionForEnemy
        or      a
        jr      nz,.afterN2
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.try2x2N
        xor     a
        jr      .afterN2
.try2x2N
        inc     hl   ;try again to the side
        call    ScanDirectionForEnemy

.afterN2
        pop     de
        or      a
        jr      nz,.foundEnemyN
        jp      .advanceState       ;found a wall
.foundEnemyN
        ld      b,DIR_NORTH           ;found enemy
        jp      .saveEnemyLocation

.scanEast
        ;Attack Dir State says look east?
        cp      1
        jr      nz,.scanSouth

        ;de = east offset
        push    de
        ld      a,DIR_EAST
        ld      [myFacing],a
        call    GetLocInFront
        ld      a,[mapOffsetEast]    ;get East offset
        ld      e,a
        ld      a,[mapOffsetEast+1]
        ld      d,a

        call    ScanDirectionForEnemy
        or      a
        jr      nz,.afterE2
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.try2x2E
        xor     a
        jr      .afterE2
.try2x2E
        ;try again to the side
        ld      a,[mapOffsetSouth]
        add     l
        ld      l,a
        ld      a,[mapOffsetSouth+1]
        adc     h
        ld      h,a
        call    ScanDirectionForEnemy

.afterE2
        pop     de
        or      a
        jr      z,.advanceState       ;found a wall
        ld      b,DIR_EAST            ;found enemy
        jr      .saveEnemyLocation

.scanSouth
        ;Attack Dir State says look south?
        cp      2
        jr      nz,.scanWest

        ;de = south offset
        push    de
        ld      a,DIR_SOUTH
        ld      [myFacing],a
        call    GetLocInFront
        ld      a,[mapOffsetSouth]    ;get South offset
        ld      e,a
        ld      a,[mapOffsetSouth+1]
        ld      d,a

        call    ScanDirectionForEnemy
        or      a
        jr      nz,.afterS2
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.try2x2S
        xor     a
        jr      .afterS2
.try2x2S
        inc     hl   ;try again to the side
        call    ScanDirectionForEnemy

.afterS2
        pop     de
        or      a
        jr      z,.scanWest           ;found a wall
        ld      b,DIR_SOUTH           ;found enemy
        jr      .saveEnemyLocation

.scanWest
        ;de = west offset
        push    de
        ld      a,DIR_WEST
        ld      [myFacing],a
        call    GetLocInFront
        ld      a,[mapOffsetWest]    ;get West offset
        ld      e,a
        ld      a,[mapOffsetWest+1]
        ld      d,a

        call    ScanDirectionForEnemy
        or      a
        jr      nz,.afterW2
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      z,.try2x2W
        xor     a
        jr      .afterW2
.try2x2W
        ;try again to the side
        ld      a,[mapOffsetSouth]
        add     l
        ld      l,a
        ld      a,[mapOffsetSouth+1]
        adc     h
        ld      h,a
        call    ScanDirectionForEnemy

.afterW2
        pop     de
        or      a
        jr      z,.advanceState       ;found a wall
        ld      b,DIR_WEST            ;found enemy

.saveEnemyLocation
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        ld      a,1
        jr      .done

.advanceState
        ;no enemies found, look next direction next time
        call    GetAttackDirState
        inc     a
        call    SetAttackDirState
        xor     a

.done
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      ScanDirectionForEnemy
; Arguments:    c  - class index of scanning object
;               de - offset to scan in
;               hl - starting location for scan
;               [losLimit] - 1=1 tile, 0=infinite
; Returns:      a  - 1=enemy found, 0=no enemy
;               [fireBulletLocation] - location of enemy if found
; Alters:       af
;---------------------------------------------------------------------
ScanDirectionForEnemy:
        push    bc
        push    hl

        ld      a,MAPBANK
        ld      [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a

        ld      a,[losLimit]
        cp      1
        jr      nz,.loop

        ;one time only
        ld      a,[hl]
        or      a
        jr      z,.done
        cp      b
        jr      c,.returnFalse
        call    IsMyEnemy
        and     1           ;mask out & ignore bullets
        jr      .done

        ;infinite until hit wall
.loop   ld      a,[hl]
        or      a
        jr      z,.nextLocation
        cp      b
        jr      c,.foundWall

        ;might be an enemy
        push    af
        ld      a,l
        ld      [fireBulletLocation],a
        ld      a,h
        ld      [fireBulletLocation+1],a
        pop     af
        call    IsMyEnemy
        cp      2
        jr      z,.restoreMapNextLocation    ;is bullet, look past it
        and     1
        jr      .done              ;is creature

.restoreMapNextLocation
        ld      a,MAPBANK
        ldio    [$ff70],a
.nextLocation
        add     hl,de
        jr      .loop

.foundWall
        ;might be a shoot-over wall
        push    af
        ld      a,ZONEBANK
        ldio    [$ff70],a
        pop     af
        bit     7,[hl]    ;anything special here?
        jr      z,.returnFalse   ;nope
        call    GetBGAttributes  ;maybe...
        and     BG_FLAG_SHOOTOVER
        jr      z,.returnFalse   ;still no
        ld      a,MAPBANK
        ldio    [$ff70],a
        jr      .nextLocation    ;go back to looking

.returnFalse
        xor     a
.done
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      IsMyEnemy
; Arguments:    a  - class index of potential enemy
;               c  - class index of object
;               hl - map location
; Returns:      a  - 0=no enemy, 1=is enemy, 2=no enemy but is bullet
;               (bullet coming towards me = 1)
; Alters:       af
; Description:  Follows tail tiles back to head (if need be) & figures
;               out if this index is friend or foe
;---------------------------------------------------------------------
IsMyEnemy:
        push    bc
        push    de
        push    hl

        push    af
        ldio    a,[firstMonster]
        ld      b,a
        pop     af
        cp      b
        jr      c,.notEnemy

        call    EnsureTileIsHead     ;a = findHead(a)
        ld      c,a
        ld      d,h
        ld      e,l
        call    FindObject

        call    GetFGAttributes
        and     FLAG_ISBULLET
        jr      nz,.specialCaseIsBullet

        call    GetGroup

        ld      b,a
        ld      a,[myGroup]
        ld      c,a
        call    GetFOF
        xor     1                    ;reverse return value
        jr      .done

.specialCaseIsBullet
        call    GetFacing            ;get bullets direction
        add     2                    ;reverse it
        and     %11
        ld      hl,myFacing
        cp      [hl]                 ;coming towards me if same dir
        jr      z,.isEnemy

        ;no enemy but is bullet
        ld      a,2
        jr      .done

.notEnemy
        ;not my enemy
        xor     a
        jr      .done

.isEnemy
        ld      a,1

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      EnsureTileIsHead
; Arguments:    a  - class index of tile (maybe adjoin ptr)
;               hl - map location
; Returns:      a  - head of obj / class index
;               hl - location of head
; Alters:       af,hl
; Description:  Follows tail tiles back to head (if need be)
;---------------------------------------------------------------------
EnsureTileIsHead::
        push    bc
        push    de
        ld      c,a

        ld      d,h
        ld      e,l

        ld      a,MAPBANK
        ld      [$ff70],a

.checkIfFoundHead
        ld      a,c
        cp      CLASS_ADJOIN_N
        jr      c,.foundHeadTile

        jr      z,.followTileToNorth
        cp      CLASS_ADJOIN_W
        jr      z,.followTileToWest

        di
.error  jr      .error   ;no classes should adjoin east or south

.followTileToNorth
        ld      a,[mapOffsetNorth]
        ld      l,a
        ld      a,[mapOffsetNorth+1]
        ld      h,a
        add     hl,de
        ld      d,h
        ld      e,l
        ld      c,[hl]
        jr      .checkIfFoundHead

.followTileToWest
        dec     de
        ld      a,[de]
        ld      c,a
        jr      .checkIfFoundHead

.foundHeadTile
        ld      h,d
        ld      l,e
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      StandardValidateMoveAndRedraw
; Arguments:    b - direction to move
;---------------------------------------------------------------------
StandardValidateMoveAndRedraw:
        ld      a,b
        and     %11
        ld      b,a
        call    EnforceLegalMove
        ld      a,1
        call    CheckDestEmpty
        or      a
        ret     z
        call    Move
        call    StandardRedrawNoCheckSprite
        ret

;---------------------------------------------------------------------
; Routine:      PlayerValidateMoveAndRedraw
; Arguments:    b - desired move dir
; Returns:      a - 1 if bumping into monster
;                   0 otherwise
; Description:  Additional functionality of changing map if player
;               hits a wall flagged as an exit
;---------------------------------------------------------------------
PlayerValidateMoveAndRedraw:
        call    EnforceLegalMove
        ld      a,1
        call    CheckDestEmpty
        or      a
        jr      nz,.move

        ;can't move.  Bumping into exit?
        ld      a,4
        call    GetLocInFront

        ;can't be a monster
        ld      a,MAPBANK
        ld      [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[hl]
        cp      b
        jr      c,.notAMonster

        ;return is monster unless it is a talker
        call    EnsureTileIsHead
        ld      b,a
        ld      a,[dialogBalloonClassIndex]
        cp      b
        jr      nz,.returnTrue

        xor     a
        ret

.returnTrue
        ld      a,1
        ret

.notAMonster
        ;save monster(?) index in b
        ;ld      b,a

        ;switch to zone/exit map
        ld      a,ZONEBANK
        ld      [$ff70],a

        ;get & check exit at location in front
        ld      a,[hl]
        and     %01110000  ;clear off extraneous
        xor     %01110000  ;must be type "X"
        ;jr      nz,.checkBumpIntoMonster
        jr      nz,.checkBumpIntoAttackable

        ;have an exit!
        ;save exit tile index
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        ld      [exitTileIndex],a
        call    HandleExitFromMap
        xor     a
        ret

.move
        call    Move
        call    StandardRedrawNoCheckSprite
        xor     a
        ret

        ;ld      a,MAPBANK
        ;ldio    [$ff70],a
        ;ld      a,[firstMonster]
        ;ld      b,a
        ;ld      a,[hl]
        ;cp      b
        ;jr      c,.checkBumpIntoAttackable
        ;ld      a,1
        ;ret

.checkBumpIntoAttackable
        ld      a,[bgFlags]
        and     BG_FLAG_ATTACKABLE
        ret     z
        ld      a,1
        ret

;---------------------------------------------------------------------
; Routines:     StreamRedraw
;               StreamCheck
;               StreamDraw
;               StreamDie
;---------------------------------------------------------------------
StreamRedraw:
        push    bc
        push    de
        push    hl

        ld      a,OBJBANK
        ld      [$ff70],a

        xor     a
        ld      [fgFlags],a

        ld      hl,OBJ_LIMIT      ;get my color
        add     hl,de
        ld      b,[hl]
        jp      StreamDraw

StreamCheck:
        ;time to move?
        ld      a,1
        call    TestMove
        or      a
        jr      z,.streamDone    ;timer lsb==frame lsb, don't move yet

        call    .streamMove
        call    .streamMove
        call    .streamMove
        call    StreamRedraw         ;draw me please
.streamDone
        ret

.streamMove
        push    bc
        push    hl

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,4
        call    GetLocInFront        ;4=in front, split included
        or      a
        jr      z,.keepGoing         ;nothing in front
        cp      b                    ;is a monster or what?
        jr      c,.hitWall           ;wall in front, bullet just dies

        ;object in front, hit it for damage but keep going next time
        ld      b,a                  ;monster index in b, loc in hl
        ld      a,1                  ;one point of damage
        ld      [methodParamL],a
        ld      a,4                  ;use direction of this object for expl
        call    HitObject
        jr      .done

.hitWall
        call    StreamDie
        call    GetCurLocation       ;move obj over wall
        call    GetFacing
        and     %11
        call    AdvanceLocHLInDirection
        call    SetCurLocation
        ld      a,MAPBANK
        ld      [$ff70],a
        xor     a
        ld      [hl],a               ;destroy bg tile at this loc

        ld      b,24                 ;initial frame
        call    HitWall

        ld      hl,bigExplosionSound
        call    PlaySound
        pop     hl
        pop     bc
        pop     af    ;return addr
        ret

.keepGoing
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME         ;get current direction
        add     hl,de
        ld      a,[hl]
        and     %00000011            ;keep going same direction
        ld      b,a

        call    Move
        ;call    StreamRedraw         ;draw me please

.done
        pop     hl
        pop     bc
        ret

StreamDraw:
        jp      StandardDraw

        ;call    GetCurLocation
        ;call    GetFacing
        ;add     2
        ;and     %11            ;reverse facing
        ;call    AdvanceLocHLInDirection   ;location behind head
        ;call    GetBaseTile



StreamDie:
        ld      a,5
        ld      [jiggleDuration],a
        jp      StandardDie

;---------------------------------------------------------------------
; Routine:      BombLocation
; Arguments:    b  - damage
;               hl - center of blast
; Returns:      Nothing.
; Alters:       af
; Description:  Does 'b' damage in a cross shape spreading outward
;               from center in a random radius of (2...b) horizontally
;               and another random radius of (2...b) vertically.
;
;               Uses $c000 as work RAM to collect locations and
;               objects affected.
;---------------------------------------------------------------------
BombLocation:
        push    bc
        push    de
        push    hl

        ld      a,MAPBANK
        ldio    [$ff70],a

        ;save current object width & height
        ldio    a,[curObjWidthHeight]
        push    af

        xor     a          ;number of objects found
        ld      [$c000],a

        ld      a,b
        ld      [fireBulletDamage],a

        ;limit b to 4 max
        ld      a,b
        cp      5
        jr      c,.bOkay
        ld      b,4
.bOkay

        push    hl

        ;----left/right-----------------------------------------------
        ;get random radius 1...b
        ld      a,b
        sub     2
        call    GetRandomNumZeroToN
        inc     a
        inc     a
        ld      c,a   ;c is original desired number of explosions

        ;find left and right boundaries
        ld      de,$ffff
        call    .numTilesUntilWall
        cp      c
        jr      c,.leftSideOkay
        jr      z,.leftSideOkay
        ld      a,c     ;clip
.leftSideOkay
        push    af

        ld      de,1
        call    .numTilesUntilWall
        cp      c
        jr      c,.rightSideOkay
        jr      z,.rightSideOkay
        ld      a,c     ;clip
.rightSideOkay
        dec     a
        ld      c,a
        pop     af
        push    af
        add     c
        ld      c,a
        pop     af
        cpl
        inc     a
        inc     a
        add     l
        ld      l,a

        ;hl is at left side, c indiates num tiles until right side
        ld      de,1
        call    .createExplosions

        pop     hl

        ;----up/down--------------------------------------------------
        ;get random radius 1...b
        ld      a,b
        sub     2
        call    GetRandomNumZeroToN
        inc     a
        inc     a
        ld      c,a

        ;find top and bottom boundaries
        ld      a,[mapOffsetNorth]
        ld      e,a
        ld      a,[mapOffsetNorth+1]
        ld      d,a
        call    .numTilesUntilWall
        cp      c
        jr      c,.topSideOkay
        jr      z,.topSideOkay
        ld      a,c     ;clip
.topSideOkay
        ld      b,c
        dec     a
        ld      c,a
        or      a
        jr      z,.topSideDone

        push    hl
.adjustTopHL
        add     hl,de
        dec     a
        jr      nz,.adjustTopHL

        ;hl is at top side, c indiates num tiles until bottom side
        ld      a,[mapOffsetSouth]
        ld      e,a
        ld      a,[mapOffsetSouth+1]
        ld      d,a
        call    .createExplosions
        pop     hl
.topSideDone

        ld      a,[mapOffsetSouth]
        ld      e,a
        ld      a,[mapOffsetSouth+1]
        ld      d,a
        ld      c,b
        call    .numTilesUntilWall
        cp      c
        jr      c,.bottomSideOkay
        jr      z,.bottomSideOkay
        ld      a,c     ;clip
.bottomSideOkay
        dec     a
        jr      z,.bottomSideDone
        ld      c,a

        add     hl,de

        ;hl is at top side, c indiates num tiles until bottom side
        call    .createExplosions
.bottomSideDone

        ;loop through list of objects recorded as being in bomb
        ;blast and cause damage to each one
        ld      a,[$c000]
        or      a
        jr      z,.done
        ld      c,a
        ld      hl,$c001

.distributeDamageLoop
        push    bc
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl+]
        ld      d,a
        ld      a,[de]    ;class index of target
        ld      c,a       ;class index to look for
        call    FindObject
        ld      a,[fireBulletDamage]
        ld      [methodParamL],a
        ld      a,4
        ld      [fireBulletDirection],a
        ld      b,METHOD_TAKE_DAMAGE
        call    CallMethod
        pop     bc
        dec     c
        jr      nz,.distributeDamageLoop

        ;ld      hl,bombSound
        ;call    PlaySound

.done
        ;restore current object width and height
        pop     af
        ldio    [curObjWidthHeight],a

        pop     hl
        pop     de
        pop     bc
        ret

.createExplosions
        ld      a,c
        or      a
        ret     z

        push    bc
        push    de
        push    hl

.createExplosionLoop
        ld      a,MAPBANK
        ldio    [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[hl]
        cp      b
        push    de
        push    hl
        jr      c,.afterRecordObject

        call    EnsureTileIsHead

        ;add location to list of locations if not already there
        call    .isLocationRecorded
        or      a
        jr      nz,.afterRecordObject

        ;record the location
        ld      a,[$c000]
        push    af
        sla     a               ;times two + 1
        inc     a
        ld      e,a
        ld      d,$c0           ;de = numObj*2 + 1
        ld      a,l
        ld      [de],a
        inc     de
        ld      a,h
        ld      [de],a
        pop     af
        inc     a
        ld      [$c000],a       ;one more in the list

.afterRecordObject
        pop     hl
        pop     de
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        ld      b,16
        call    CreateExplosion
        add     hl,de
        dec     c
        jr      nz,.createExplosionLoop

        pop     hl
        pop     de
        pop     bc
        ret

.isLocationRecorded
        ;args:     a  - class
        ;          hl - cur location
        ;returns:  a  - 1=in list, 0=not in list
        push       bc
        push       de
        push       hl
        call       EnsureTileIsHead
        ld         d,h
        ld         e,l
        ld         a,[$c000]  ;num classes
        or         a
        jr         z,.inListDone    ;no list - so not in list
        ld         c,a
        ld         hl,$c001
.testInListLoop
        ld         a,[hl+]
        cp         e
        jr         nz,.continueInListLoop
        ld         a,[hl]
        cp         d
        jr         nz,.continueInListLoop

        ld         a,1     ;is in list
        jr         .inListDone

.continueInListLoop
        inc        hl
        dec        c
        jr         nz,.testInListLoop

        xor        a

.inListDone
        pop        hl
        pop        de
        pop        bc
        ret

.numTilesUntilWall
        ;takes a location (hl), an offset (de), and returns how
        ;many tiles (including the first) there are until a wall.
        push    bc
        push    hl

        ld      a,MAPBANK
        ldio    [$ff70],a

        ldio    a,[firstMonster]
        ld      b,a

        ld      c,0
.loop   ld      a,[hl]
        or      a
        jr      z,.keepCounting
        cp      b
        jr      c,.foundWall

.keepCounting
        inc     c
        add     hl,de
        jr      .loop

.foundWall
        ;keep going if shoot-over type
        push    af
        ld      a,ZONEBANK
        ldio    [$ff70],a
        pop     af
        bit     7,[hl]     ;special?
        jr      z,.foundWallDone
        call    GetBGAttributes
        bit     BG_BIT_SHOOTOVER,a
        jr      z,.foundWallDone
        ld      a,MAPBANK   ;keep looking
        ldio    [$ff70],a
        jr      .keepCounting

.foundWallDone
        ld      a,c
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindEmptyLocationAround1x1
; Arguments:    de - 1x1 object
; Returns:      hl - empty location around object or $0000 if none
;               a  - 0 = no empty locations
; Alters:       af,hl
;---------------------------------------------------------------------
FindEmptyLocationAround1x1Loc:
        push    bc
        jr      FindEmptyLocationAround1x1Common

FindEmptyLocationAround1x1:
        push    bc

        ;get my TL corner plus (-1,-1)
        call    GetCurLocation
FindEmptyLocationAround1x1Common:
        call    ConvertLocHLToXY
        dec     h
        dec     l

        ld      b,0
.outer
        ld      c,0
.inner
        push    hl
        ld      a,h
        add     b
        ld      h,a
        ld      a,l
        add     c
        ld      l,a
        call    ConvertXYToLocHL
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        jr      nz,.notEmpty

        ld      a,1
        pop     bc
        jr      .done

.notEmpty
        pop     hl
        ld      a,3
        inc     c
        cp      c
        jr      nz,.inner
        inc     b
        cp      b
        jr      nz,.outer

        ld      hl,0
        xor     a

.done
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindEmptyLocationAround2x2
; Arguments:    de - 2x2 object
; Returns:      hl - empty location around object or $0000 if none
;               a  - 0 if none empty
; Alters:       af,hl
;---------------------------------------------------------------------
FindEmptyLocationAround2x2:
        push    bc

        ;get my TL corner plus (-1,-1)
        call    GetCurLocation
        call    ConvertLocHLToXY
        dec     h
        dec     l

        ld      b,0
.outer
        ld      c,0
.inner
        push    hl
        ld      a,h
        add     b
        ld      h,a
        ld      a,l
        add     c
        ld      l,a
        call    ConvertXYToLocHL
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        or      a
        jr      nz,.notEmpty

        ld      a,1
        pop     bc
        jr      .done

.notEmpty
        pop     hl
        ld      a,4
        inc     c
        cp      c
        jr      nz,.inner
        inc     b
        cp      b
        jr      nz,.outer

        xor     a
        ld      hl,0

.done
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetCurLocation
; Arguments:    de - object
; Returns:      hl - current location
; Alters:       af
;---------------------------------------------------------------------
GetCurLocation::
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      a,[de]
        ld      l,a
        inc     de
        ld      a,[de]
        ld      h,a
        dec     de
        ret

;---------------------------------------------------------------------
; Routine:      SetCurLocation
;---------------------------------------------------------------------
SetCurLocation::
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      a,l
        ld      [de],a
        inc     de
        ld      a,h
        ld      [de],a
        dec     de
        ret

;---------------------------------------------------------------------
; Routine:      GetFacing
; Returns:      current facing + split
; Alters:       af
;---------------------------------------------------------------------
GetFacing::
        push    hl
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME
        add     hl,de
        ld      a,[hl]
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetFacing
; Arguments:    a - byte to set facing to
; Alters:       af,hl
;---------------------------------------------------------------------
SetFacing::
        push    af
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_FRAME
        add     hl,de
        pop     af
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      AdvanceLocHLInDirection
; Arguments:    a  - direction to advance in
;---------------------------------------------------------------------
AdvanceLocHLInDirection:
        bit     0,a
        jr      nz,.eastOrWest

        push    de

        rlca
        ld      de,mapOffsetNorth     ;de to correct map offset
        add     e
        ld      e,a

        ld      a,[de]
        inc     de
        add     l
        ld      l,a
        ld      a,[de]
        adc     h
        ld      h,a

        pop     de
        ret

.eastOrWest
        bit     1,a
        jr      nz,.west

        inc     hl
        ret

.west   dec     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetGroup
; Arguments:    a  - group to set to (see object.asm for details)
;               de - object
; Alters:       af
; Returns:      nothing
;---------------------------------------------------------------------
SetGroup::
        push    bc
        push    hl

        ld      b,a
        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_GROUP
        add     hl,de
        ld      a,[hl]
        and     %11110000
        or      b
        ld      [hl],a

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetGroup
; Arguments:    de - object
; Alters:       af
; Returns:      a  - this object's group (see object.asm for details)
;---------------------------------------------------------------------
GetGroup:
        push    hl
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_GROUP
        add     hl,de
        ld      a,[hl]
        and     %00001111
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      GetActorDestZone
; Arguments:    de - object
; Alters:       af
; Returns:      a  - destination zone of DESTL/DESTH
;---------------------------------------------------------------------
GetActorDestZone:
        push    hl

        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_DESTL
        add     hl,de

        ld      a,[hl+]        ;get location in hl
        ld      h,[hl]
        ld      l,a

        ld      a,ZONEBANK
        ld      [$ff70],a

        ld      a,[hl]
        and     %1111

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetActorDestLoc
;               aka SetFoodIndexRange
; Arguments:    de - object
;               hl - location / food range h=high index, l=low
; Alters:       af
; Returns:      nothing
;---------------------------------------------------------------------
SetActorDestLoc::
SetFoodIndexRange::
        push    bc
        push    hl

        ld      b,h
        ld      c,l

        ld      a,OBJBANK
        ld      [$ff70],a

        ld      hl,OBJ_DESTL
        add     hl,de

        ld      [hl],c
        inc     hl
        ld      [hl],b

        xor     a
        call    SetState

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetActorDestLoc
; Arguments:    de - object
; Alters:       af, hl
; Returns:      hl - location
;---------------------------------------------------------------------
GetActorDestLoc:
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_DESTL
        add     hl,de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ret

;---------------------------------------------------------------------
; Routine:      GetDestL
;               GetDestH
; Arguments:    de - object
; Returns:      a  - contents of DESTL/DESTH
; Alters:       af,hl
;---------------------------------------------------------------------
GetDestL::
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      hl,OBJ_DESTL
        add     hl,de
        ld      a,[hl]
        ret

GetDestH::
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      hl,OBJ_DESTH
        add     hl,de
        ld      a,[hl]
        ret

;---------------------------------------------------------------------
; Routine:      SetDestL
;               SetDestH
; Arguments:    a  - value to set to
;               de - object
; Returns:      Nothing.
; Alters:       af,hl
;---------------------------------------------------------------------
SetDestL::
        push    af
        ld      a,OBJBANK
        ldio    [$ff70],a
        pop     af
        ld      hl,OBJ_DESTL
        add     hl,de
        ld      [hl],a
        ret

SetDestH::
        push    af
        ld      a,OBJBANK
        ldio    [$ff70],a
        pop     af
        ld      hl,OBJ_DESTH
        add     hl,de
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      SetMisc
;               GetMisc
; Arguments:    a  - value to set to (SetMisc)
;               de - object
; Returns:      a  - retrieved value (GetMisc)
; Alters:       af,hl
;---------------------------------------------------------------------
SetMisc::
       push     af
       ld       a,OBJBANK
       ldio     [$ff70],a
       ld       hl,OBJ_MISC
       add      hl,de
       pop      af
       ld       [hl],a
       ret

GetMisc::
       ld       a,OBJBANK
       ldio     [$ff70],a
       ld       hl,OBJ_MISC
       add      hl,de
       ld       a,[hl]
       ret

;---------------------------------------------------------------------
; Routine:      SetSpriteLo
; Alters:       af
; Arguments:    a  - loptr to sprite
;               de - object
;---------------------------------------------------------------------
SetSpriteLo:
        push    hl
        ld      h,a
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      a,h
        ld      hl,OBJ_SPRITELO
        add     hl,de
        ld      [hl],a
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      GetSpriteLo
; Arguments:    de - object
; Returns:      a  - loptr to sprite
; Alters:       af
;---------------------------------------------------------------------
GetSpriteLo:
        push    hl

        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_SPRITELO
        add     hl,de
        ld      a,[hl]

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      GetSpritePtrInHL
; Arguments:    de - object
; Returns:      hl - loptr to sprite
; Alters:       af
;---------------------------------------------------------------------
GetSpritePtrInHL:
        call    GetSpriteLo
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ret

;---------------------------------------------------------------------
; Routine:      GetBulletDamage
; Returns:      this.destL
; Alters:       a,hl
;---------------------------------------------------------------------
GetBulletDamage:
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      hl,OBJ_DESTL
        add     hl,de
        ld      a,[hl]
        ret


;---------------------------------------------------------------------
; Routine:      GetFGAttributes
; Arguments:    c - class index
; Alters:       af
; Returns:      a - attributes for given class index
;               [fgFlags] copy of attributes
;
;               Returns full set of attributes including:
;               [2:0] - color        FLAG_PALETTE
;               [4]   - isBullet     FLAG_ISBULLET
;               [5]   - is2x2        FLAG_2X2
;               [6]   - noRotate     FLAG_NOROTATE
;---------------------------------------------------------------------
GetFGAttributes::
        push    hl
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      l,c
        ld      h,((fgAttributes>>8) & $ff)
        ld      a,[hl]
        ld      [fgFlags],a
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetFGAttributes
; Arguments:    a - new attributs
;               c - class index
; Alters:       af
;---------------------------------------------------------------------
SetFGAttributes::
        push    hl
        push    af
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      l,c
        ld      h,((fgAttributes>>8) & $ff)
        pop     af
        ld      [hl],a
        pop     hl
        ret


;---------------------------------------------------------------------
; Routine:      GetFGTileMapping
; Arguments:    c - class index
; Returns:      a - base fg tile for given class index
; Alters:       af
;---------------------------------------------------------------------
GetFGTileMapping:
        push    hl

        ld      a,TILEINDEXBANK
        ld      [$ff70],a

        ld      l,c
        ld      h,((fgTileMap>>8) & $ff)

        ld      a,[hl]

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetupHeroData
; Arguments:    c  - class index
; Returns:      hl - ptr to hero0_data or hero1_data
; Alters:       af,hl
;---------------------------------------------------------------------
SetupHeroData:
        ld      a,[hero0_index]
        cp      c
        jr      nz,.hero1
        ld      hl,hero0_data
        ret

.hero1
        ld      hl,hero1_data
        ret

;---------------------------------------------------------------------
; Routine:      GetHeroData
; Arguments:    a  - data offset (e.g. HERODATA_HEALTH)
;               hl - ptr to hero0_data or hero1_data
; Returns:      a - 8-bit value
; Alters:       af
;---------------------------------------------------------------------
GetHeroData:
        push    de
        push    hl

        ld      d,0
        ld      e,a
        add     hl,de
        ld      a,[hl]

        pop     hl
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      SetHeroData
; Arguments:    a  - data to set
;               b  - data offset (e.g. HERODATA_HEALTH)
;               hl - ptr to hero0_data or hero1_data
; Returns:      a - 8-bit value
; Alters:       af
;---------------------------------------------------------------------
SetHeroData:
        push    de
        push    hl

        ld      d,0
        ld      e,b
        add     hl,de
        ld      [hl],a

        pop     hl
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      HealthSparks
; Arguments:    a  - cur health
;               b  - max health
;               de - this
; Returns:      Nothing.
; Alters:       af, hl
; Description:  Makes a spark every often if lower than half
;               health, twice as often if lower than 1/4 health,
;               like crazy if lower than 1/8 health or at 1
;---------------------------------------------------------------------
HealthSparks:
        push    bc
        push    de

        srl     b      ;half max health
        cp      b
        jr      z,.atHalfHealth
        jr      nc,.done   ;greater than half health

        srl     b          ;1/4 max
        cp      b
        jr      z,.atQuarterHealth
        jr      nc,.atHalfHealth

        srl     b          ;1/8 max
        cp      b
        jr      z,.atEighthHealth
        jr      nc,.atQuarterHealth

.atEighthHealth
        ;at 1/8 health
        call    GetState
        add     1
        call    SetState
        and     %00000001
        jr      .spark

.atQuarterHealth
        call    GetState
        add     1
        call    SetState
        and     %00000111
        jr      .spark

.atHalfHealth
        call    GetState
        add     1
        call    SetState
        and     %00001111

.spark
        or      a
        jr      nz,.done

        call    GetFGAttributes
        and     %111
        ld      [bulletColor],a
        call    GetCurLocation
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        ld      b,72   ;initial spark frame
        call    CreateExplosion

        ;hl points to explosion object
        push    de
        call    IndexToPointerDE
        call    GetSpriteLo
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      l,a
        pop     de

        ;add +4 y if split north/south
        push    hl
        push    hl
        call    GetFacing
        pop     hl
        bit     2,a
        jr      z,.afterSplit

        bit     0,a
        jr      z,.splitNS

        inc     hl   ;split e/w

.splitNS
        ld      a,[hl]
        add     4
        ld      [hl],a
.afterSplit
        pop     hl

        ;offset by random +/- 0-3 pixels
        ld      a,%111
        call    GetRandomNumMask
        add     [hl]     ;sprite y pos
        sub     4
        ld      [hl+],a
        ld      a,%111
        call    GetRandomNumMask
        add     [hl]     ;sprite x pos
        sub     4
        ld      [hl],a

.done
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ShiftObjectInDirection
; Arguments:    a  - direction to shift object
;               hl - location of object
; Alters:       af, [curObjWidthHeight]
; Returns:      Nothing.
;---------------------------------------------------------------------
ShiftObjectInDirection::
        push    bc
        push    de
        push    hl

        ld      b,a

        ldio    a,[curObjWidthHeight]
        push    af

        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      a,[hl]
        call    EnsureTileIsHead
        ld      d,h
        ld      e,l

        ld      c,a
        ld      a,[hero0_index]
        cp      c
        jr      z,.isPlayer
        ld      a,[hero1_index]
        cp      c
        jr      z,.isPlayer

        call    FindObject
        call    SetObjWidthHeight
        call    StandardValidateMoveAndRedraw

        pop     af
        ldio    [curObjWidthHeight],a

        pop     hl
        pop     de
        pop     bc
        ret

.isPlayer
        call    FindObject
        call    PlayerValidateMoveAndRedraw

        pop     af
        ldio    [curObjWidthHeight],a

        pop     hl
        pop     de
        pop     bc
        ret


nullSound:
  DB 0

;channel 1 effects
pansyFireSound:
  DB 1,$72,$80,$f7,$00,$84
baFireSound:
  DB 1,$3b,$40,$f3,$00,$84
bsFireSound:
  DB 1,$4c,$40,$f3,$00,$87
bigLaserSound::
  DB 1,$3d,$80,$f6,$00,$86
disappearSound::
  DB 1,$72,$80,$f5,$00,$c2
goblinSound:
  DB 1,$11,$80,$f0,$00,$c1
rocketFireSound:
  DB 1,$25,$00,$f4,$00,$81
hulkFireSound:
  DB 1,$31,$c0,$f0,$00,$c1
gruntFireSound:
  DB 1,$21,$e0,$f8,$50,$80
haikuSound:
  DB 1,$9c,$48,$f2,$d0,$c7
guardFireSound:
  DB 1,$31,$80,$f0,$00,$c1
treeFireSound:
  DB 1,$4d,$c0,$f0,$00,$c5
bushFireSound:
  DB 1,$4d,$c0,$f0,$00,$c4
beeSound:
  DB 1,$f7,$00,$f3,$00,$83
eatSound:
  DB 1,$5a,$80,$f2,$00,$84


;low frogger 1,$23,$20,$af,$00,$81

;channel 4 effects
stdExplosionSound:
  DB 4,$00,$c3,$44,$80
bigExplosionSound::
  DB 4,$00,$f3,$81,$80
closeGateSound::
  DB 4,$00,$f4,$4f,$80
bombSound::
  DB 4,$00,$f6,$90,$80



;SECTION "AlignedClassTables",ROMX[$7F00],BANK[CLASSROM]
;---------------------------------------------------------------------
SECTION "AlignedClassTables",ROM0[$200]
;---------------------------------------------------------------------
stdStateTable:
  ;$7f00
  DW SetupRandomMoveState, MoveToZone, TryRight, TryFwdAfterRight
  DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove

eatStateTable:
  ;$7f20
  ;DW EatOrTrack, MoveToZone, TryRight, TryFwdAfterRight
  ;DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  ;DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  ;DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove
  DW EatOrTrackState,EatOrTrackState,EatOrTrackState,EatOrTrackState
  DW EatOrTrackState,EatOrTrackState,EatOrTrackState,EatOrTrackState
  DW EatOrTrackState,EatOrTrackState,EatOrTrackState,EatOrTrackState
  DW EatOrTrackState,EatOrTrackState,EatOrTrackState,EatOrTrackState

explosionFrameTable:
  ;$7f40
  DB 0,8,0,8,0,0,0,0    ;pattern numbers
  DB %00000000,%00000000,%01000000,%00100000    ;base attributes
  DB %00000000,%01000000,%00100000,%01100000

trackEnemyStateTable:
  ;$7f50
  DW SetupTrackEnemy, MoveToZone, TryRight, TryFwdAfterRight
  DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove

getLocSplitTable:
  ;$7f70
  DB 0   ;%00 00   Facing: N  Check: N
  DB 0   ;%00 01   Facing: N  Check: E
  DB 1   ;%00 10   Facing: N  Check: S
  DB 0   ;%00 11   Facing: N  Check: W
  DB 0   ;%01 00   Facing: E  Check: N
  DB 1   ;%01 01   Facing: E  Check: E
  DB 0   ;%01 10   Facing: E  Check: S
  DB 0   ;%01 11   Facing: E  Check: W
  DB 0   ;%10 00   Facing: S  Check: N
  DB 0   ;%10 01   Facing: S  Check: E
  DB 1   ;%10 10   Facing: S  Check: S
  DB 0   ;%10 11   Facing: S  Check: W
  DB 0   ;%11 00   Facing: W  Check: N
  DB 1   ;%11 01   Facing: W  Check: E
  DB 0   ;%11 10   Facing: W  Check: S
  DB 0   ;%01 11   Facing: W  Check: W


actorStateTable:
  ;$7f80
  DW SetupMoveToLoc, MoveToZone, TryRight, TryFwdAfterRight
  DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove

fleeStateTable:
  ;$7fa0
  DW ScardieFlee, MoveToZone, TryRight, TryFwdAfterRight
  DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove

ladyBulletStateTable:
  ;$7fc0
  DW LadyBulletMove, MoveToZone, TryRight, TryFwdAfterRight
  DW TryLeft, TryFwdAfterLeft, RandomMove, MoveFwdThenState1
  DW TryLeftFirst, TryFwdAfterLeftFirst, TryRightSecond
  DW TryFwdAfterRightSecond, NoMove, NoMove, NoMove, NoMove

  ;$7fe0
