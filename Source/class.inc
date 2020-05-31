;1.2.2000 by Abe Pralle

;vector offsets
METHOD_INIT   EQU  0
METHOD_DRAW   EQU  2
METHOD_CHECK  EQU  4
METHOD_TAKE_DAMAGE  EQU  6
METHOD_DIE    EQU  8

BGACTION_HIT      EQU 0
BGACTION_MOVEOVER EQU 1

;object offsets
OBJ_IPOS      EQU  0
OBJ_JPOS      EQU  1
OBJ_FRAME     EQU  2
OBJ_MOVE      EQU  3
OBJ_LIMIT     EQU  4
OBJ_HEALTH    EQU  5
OBJ_DESTZONE  EQU  6
OBJ_MISC      EQU  7
OBJ_STATE     EQU  8
OBJ_GROUP     EQU  9
OBJ_DESTL     EQU  10
OBJ_DESTH     EQU  11
OBJ_SPRITELO  EQU  12
OBJ_FIRETIMER EQU  13
OBJ_NEXT      EQU  15
OBJ_BYTES     EQU  16

OBJBIT_THROWN EQU  7

;Flags (FGAttributes)
FLAG_PALETTE   EQU  %00000111
FLAG_ISBULLET  EQU  %00010000
FLAG_2X2       EQU  %00100000
FLAG_NOROTATE  EQU  %01000000
FLAG_NOTHROW   EQU  %10000000

BIT_ISBULLET   EQU  4
BIT_2X2        EQU  5
BIT_NOROTATE   EQU  6
BIT_NOTHROW    EQU  7

;Groups
GROUP_FFA      EQU  0
GROUP_HERO     EQU  1
GROUP_MONSTERA EQU  2
GROUP_MONSTERB EQU  3
GROUP_MONSTERC EQU  4
GROUP_MONSTERD EQU  5
GROUP_MONSTERE EQU  6
GROUP_MONSTERF EQU  7
GROUP_MONSTERG EQU  8
GROUP_MONSTERH EQU  9
GROUP_MONSTERI EQU 10
GROUP_MONSTERJ EQU 11
GROUP_MONSTERK EQU 12
GROUP_MONSTERL EQU 13
GROUP_MONSTERM EQU 14
GROUP_MONSTERN EQU 15
FOF_FRIEND EQU 1
FOF_ENEMY  EQU 0

;misc defines
CLASS_EXPLOSION EQU 255  ;$ff

;class fns
GLOBAL        ConvertLocHLToXY
GLOBAL        ConvertXYToLocHL
GLOBAL        ConvertLocHLToSpriteCoords

GLOBAL        classDoNothing
GLOBAL        classDoNothing2
GLOBAL        classDoNothing3
GLOBAL        classHeroIdle
GLOBAL        classGeneric
GLOBAL        classTalker
GLOBAL        classBAPlayer
GLOBAL        classBSPlayer
GLOBAL        classPansy
GLOBAL        classBigLongLaser
GLOBAL        classExplosion
GLOBAL        classLadyFlower
GLOBAL        classCaptainFlour
GLOBAL        classCroutonHulk
GLOBAL        classCroutonGrunt
GLOBAL        classB12Soldier
GLOBAL        classActor
GLOBAL        classActorSpeed1
GLOBAL        classActor2x2
GLOBAL        classGuard

;global class methods
GLOBAL        SuperInit
GLOBAL        SuperDie
GLOBAL        RemoveFromMap
GLOBAL        GetCurZone
GLOBAL        SetState
GLOBAL        SetPuffCount
GLOBAL        GetPuffCount
GLOBAL        AmAtLocation
GLOBAL        IsActorAtDest
GLOBAL        SetAttackDelay
GLOBAL        GetAttackDelay
GLOBAL        GetHealth
GLOBAL        SetHealth
GLOBAL        SetDestL
GLOBAL        SetDestH
GLOBAL        GetDestL
GLOBAL        GetDestH
GLOBAL        SetMisc
GLOBAL        GetMisc
GLOBAL        CreateExplosion
GLOBAL        GetCurLocation
GLOBAL        SetCurLocation
GLOBAL        GetFacing
GLOBAL        SetFacing
GLOBAL        SetGroup
GLOBAL        GetGroup
GLOBAL        SetActorDestLoc
GLOBAL        SetFoodIndexRange
GLOBAL        GetBGAttributes
GLOBAL        GetFGAttributes
GLOBAL        SetFGAttributes
GLOBAL        ShiftObjectInDirection

;objList vars and functions
GLOBAL        headTable
GLOBAL        tailTable
GLOBAL        AddObjectsToObjList
GLOBAL        IndexToPointerDE
GLOBAL        IndexToPointerHL
GLOBAL        PointerDEToIndex
GLOBAL        PointerHLToIndex
GLOBAL        ResetList
GLOBAL        CreateObject
GLOBAL        CreateInitAndDrawObject
GLOBAL        DeleteObject
GLOBAL        IterateAllLists
GLOBAL        IterateList
GLOBAL        FindObject
GLOBAL        CallMethod
GLOBAL        SetObjWidthHeight
GLOBAL        IterateMaxObjects
GLOBAL        AllocateSprite
GLOBAL        FreeSprite
GLOBAL        CreateMetaSprite
GLOBAL        CreateMetaSpriteUsingMask
GLOBAL        ScrollMetaSprite
GLOBAL        SetMetaSpritePos
GLOBAL        FreeMetaSprite
GLOBAL        DeleteObjectsOfClass
GLOBAL        DeleteObjectsOfClassIndex
GLOBAL        GetFirst
GLOBAL        GetNextObject
GLOBAL        GetNext
GLOBAL        GetAssociated
GLOBAL        GetHead
GLOBAL        GetTail
GLOBAL        SetHead
GLOBAL        SetNext
GLOBAL        InitFOF
GLOBAL        SetFOF
GLOBAL        GetFOF
GLOBAL        LinkRemakeLists
GLOBAL        GetClass
GLOBAL        GetFGMapping
GLOBAL        SetFGMapping
GLOBAL        GetBGMapping
GLOBAL        SetBGMapping
GLOBAL        GetMyHero

GLOBAL        classTable
GLOBAL        objects
GLOBAL        objExists
GLOBAL        objClassLookup

GLOBAL        colorTable
GLOBAL        oldZone
GLOBAL        firstFreeObj
GLOBAL        curObjIndex
GLOBAL        nextObjIndex
GLOBAL        iterateNext
GLOBAL        oamFindPos
GLOBAL        numFreeSprites

GLOBAL GetClassMethodTable
GLOBAL InstanceOf
GLOBAL SetAssociated
GLOBAL CountNumObjects
GLOBAL ClassIndexIsHeroType

BA_CINDEX          EQU 2054
BS_CINDEX          EQU 2056
HAIKU_CINDEX       EQU 2058
BABULLET_CINDEX    EQU 2130
FLOWER_CINDEX      EQU 2136
FLOUR_CINDEX       EQU 2138
BSBULLET_CINDEX    EQU 2218
PANSYBULLET_CINDEX EQU 2132

FREEVERSE_CINDEX EQU 2292
CS_CINDEX        EQU 2256
RA_CINDEX        EQU 2254

