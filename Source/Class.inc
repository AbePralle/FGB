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
EXPORT        ConvertLocHLToXY
EXPORT        ConvertXYToLocHL
EXPORT        ConvertLocHLToSpriteCoords

EXPORT        classDoNothing
EXPORT        classDoNothing2
EXPORT        classDoNothing3
EXPORT        classHeroIdle
EXPORT        classGeneric
EXPORT        classTalker
EXPORT        classBAPlayer
EXPORT        classBSPlayer
EXPORT        classPansy
EXPORT        classBigLongLaser
EXPORT        classExplosion
EXPORT        classLadyFlower
EXPORT        classCaptainFlour
EXPORT        classCroutonHulk
EXPORT        classCroutonGrunt
EXPORT        classB12Soldier
EXPORT        classActor
EXPORT        classActorSpeed1
EXPORT        classActor2x2
EXPORT        classGuard

;global class methods
EXPORT        SuperInit
EXPORT        SuperDie
EXPORT        RemoveFromMap
EXPORT        GetCurZone
EXPORT        SetState
EXPORT        SetPuffCount
EXPORT        GetPuffCount
EXPORT        AmAtLocation
EXPORT        IsActorAtDest
EXPORT        SetAttackDelay
EXPORT        GetAttackDelay
EXPORT        GetHealth
EXPORT        SetHealth
EXPORT        SetDestL
EXPORT        SetDestH
EXPORT        GetDestL
EXPORT        GetDestH
EXPORT        SetMisc
EXPORT        GetMisc
EXPORT        CreateExplosion
EXPORT        GetCurLocation
EXPORT        SetCurLocation
EXPORT        GetFacing
EXPORT        SetFacing
EXPORT        SetGroup
EXPORT        GetGroup
EXPORT        SetActorDestLoc
EXPORT        SetFoodIndexRange
EXPORT        GetBGAttributes
EXPORT        GetFGAttributes
EXPORT        SetFGAttributes
EXPORT        ShiftObjectInDirection

;objList vars and functions
EXPORT        headTable
EXPORT        tailTable
EXPORT        AddObjectsToObjList
EXPORT        IndexToPointerDE
EXPORT        IndexToPointerHL
EXPORT        PointerDEToIndex
EXPORT        PointerHLToIndex
EXPORT        ResetList
EXPORT        CreateObject
EXPORT        CreateInitAndDrawObject
EXPORT        DeleteObject
EXPORT        IterateAllLists
EXPORT        IterateList
EXPORT        FindObject
EXPORT        CallMethod
EXPORT        SetObjWidthHeight
EXPORT        IterateMaxObjects
EXPORT        AllocateSprite
EXPORT        FreeSprite
EXPORT        CreateMetaSprite
EXPORT        CreateMetaSpriteUsingMask
EXPORT        ScrollMetaSprite
EXPORT        SetMetaSpritePos
EXPORT        FreeMetaSprite
EXPORT        DeleteObjectsOfClass
EXPORT        DeleteObjectsOfClassIndex
EXPORT        GetFirst
EXPORT        GetNextObject
EXPORT        GetNext
EXPORT        GetAssociated
EXPORT        GetHead
EXPORT        GetTail
EXPORT        SetHead
EXPORT        SetNext
EXPORT        InitFOF
EXPORT        SetFOF
EXPORT        GetFOF
EXPORT        LinkRemakeLists
EXPORT        GetClass
EXPORT        GetFGMapping
EXPORT        SetFGMapping
EXPORT        GetBGMapping
EXPORT        SetBGMapping
EXPORT        GetMyHero

EXPORT        classTable
EXPORT        objects
EXPORT        objExists
EXPORT        objClassLookup

EXPORT        colorTable
EXPORT        oldZone
EXPORT        firstFreeObj
EXPORT        curObjIndex
EXPORT        nextObjIndex
EXPORT        iterateNext
EXPORT        oamFindPos
EXPORT        numFreeSprites

EXPORT GetClassMethodTable
EXPORT InstanceOf
EXPORT SetAssociated
EXPORT CountNumObjects
EXPORT ClassIndexIsHeroType

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

