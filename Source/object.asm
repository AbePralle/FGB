; object.asm
; 1.2.2000 by Abe Pralle
; defines and handles the objects (data of classes) of FGB

;see map.asm for location definitions of object RAM

;object data:
;each object is 16 bytes long
;  Byte Name    Description
;  ---- ------  -------------------------------------------------------------
;    0  i_pos   i index of left of object within map
;    1  j_pos   j index of top of object within map
;    2  frame   bits[2:0] - facing/frame of object.  See (1) below.
;               bits[4:3] - copy of timer's 2 LSB on upon last move
;               bits[6:5] - index 0-3 on current path
;               bit[7]    - 1 if obj is currently a sprite, 0 if not
;    3  move    Next move info
;               bits[7:0] - counter 'till next move
;    4  limit   Moves until AI switch + moves until fire again
;               bits[3:0] - moveLimit.  Decremented every move and
;                           sometimes used to switch states ("well this
;                           direction's not working").
;                           - Used as direction of fire by hero
;                           - Used as bullet color by bullet.
;               bits[7-4] - special flags
;                           7 = travel straight, speed=1 (OBJBIT_THROWN)
;    5  health  Amount of health left
;               bits[5:0] - Amount of health / hit points left
;               bits[7:6] - desired direction.  When the AI is sliding
;                           to the side looking for forward progress
;                           these bits tell the original direction.
;               bits[7:6] - Fire timer.  When not equal to classes
;    6  destzone bits [7:4] Destination zone (0-15) (no zone zero)
;                     [3:0] Number of dandelion puffs on me
;    7  misc    bits[7:0] - Used for class-specific AI
;    8  state   Current state of movement/ai
;               bits[5:0] - state.  Commonly:
;                           0 - Reset.  Figure out from scratch what
;                               to do.
;                           1 - Move straightforwardly towards waypoint.
;                           2 - Move up to "moveLimit" (see byte 4
;                               following) parallel to right of major
;                               axis, each time switching to state 3 to
;                               check for forward movement
;                           3 - If can move forward along major axis do
;                               do and go back to state 1.  If not go back
;                               to state 2.
;                           4 - Same as (2) but moving left of major axis.
;                           5 - Same as 3.
;                           6 - Wander randomly.
;                           For heroes is spark timer
;                bits[7:6]  - attack dir state (direction to scan for
;                             attacking)
;    9  group  bits[3:0] - group.  Values:
;                           0  - Free for all (shoot anything)
;                           1  - Hero group
;                           2-15 Monster A - Monster N
;   10  DESTL            - actor dest low byte
;                        - eater low index
;                        - bullet damage
;                        - explosion initial frame
;   11  DESTH            - actor dest high byte
;                        - eater high byte
;   12  SPRITELO         - low ptr to sprite when obj is sprite
;   13  FIRETIMER        - ticks before can fire again
;   14  unused
;   15  NEXT             - index of next object or 0 for null

; (1) Frames have the following definitions:
;     0 (%000) - Facing north, frame0
;     1 (%001) - East, frame0
;     2 (%010) - South, frame0
;     3 (%011) - West, frame0
;     4 (%100) - Facing north, frame1 (top of two tiles)
;     5 (%101) - East, frame1         (left of two tiles)
;     6 (%110) - South, frame1        (top of two tiles)
;     7 (%111) - West, frame1         (left of two tiles)

; The object list works as follows:
;   - All objects of the same class are stored as consecutive nodes in the
;     linked list.
;   - The following variables are used to keep track of the linked list:
;     firstFree[1]:    Index of first free object in objectExists[].
;                      node is linked to the next free node and so on (stored
;                      in bank0 instead of bank3 like the others)
;     headTable[256]:  Indices of head of list of a certain class.  Every two
;                      bytes marks the start of a LowByte, HighByte address
;     tailTable[256]:  Indices of tail of list of a certain class.

INCLUDE "Source/defs.inc"
INCLUDE "Source/start.inc"


SECTION "ObjList",ROMX,BANK[CLASSROM]

;---------------------------------------------------------------------
; Routine:      AddObjectsToObjList
; Arguments:    none
; Description:  Parses through the map (just loaded) and creates an
;               object for each creature and adds it to the objList.
;---------------------------------------------------------------------
AddObjectsToObjList::
        push    bc
        push    de
        push    hl


        ;initialize outer loop (b=0...mapHeight-1)
        ld      hl,map          ;set hl to point to first tile in map
        ld      b,0

        ;initialize inner loop (c=0...mapWidth-1)
.outer  ld      c,0
        ldio    a,[firstMonster]
        ld      d,a

.inner  ld      a,MAPBANK       ;switch to map RAM bank
        ld      [$ff00+$70],a
        ld      a,[hl]         ;get a class index from map
        cp      d               ;is it < first monster index?
        jr      c,.notAnObject

        ;create an object for d monsta
        push    bc
        push    de
        ;hl is ptr to location in map
        ld      c,a             ;class index
        call    CreateObject    ;returns de as ptr to object
        pop     de
        pop     bc

.notAnObject
        ;termination test for inner loop (is c==mapWidth?)
        inc     hl
        inc     c
        ld      a,[mapWidth]
        cp      c
        jr      nz,.inner

        ;skip excess width to make power of 2 pitch
        ld      a,[mapSkip]
        ld      d,0
        ld      e,a
        add     hl,de

        ;termination test for outer loop (is b==mapHeight?)
        inc     b
        ld      a,[mapHeight]
        cp      b
        jr      nz,.outer

        ;call the INIT method of each object
        ld      b,METHOD_INIT
        call    IterateAllLists

        ;call the DRAW method of each object
        ld      b,METHOD_DRAW
        call    IterateAllLists

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routines:     PointerDEToIndex
;               PointerHLToIndex
; Arguments:    de/hl - pointer $d010-$dff0 to object
; Returns:      a     - index 1-255 of object
;---------------------------------------------------------------------
PointerDEToIndex::
        push    de
        ld      a,d
				and     %00001111
				ld      d,a
				ld      a,e
				and     %11110000
				or      d
				swap    a
				pop     de
				ret

PointerHLToIndex::
        push    hl
        ld      a,h
				and     %00001111
				ld      h,a
				ld      a,l
				and     %11110000
				or      h
				swap    a
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      ResetList
; Arguments:    none
; Description:  Sets all elements of headTable[] and tailTable[] to
;               point to null.  Sets up all 256 objExists flags to
;               zero and [firstFreeObj] to 1.  A few other misc things
;---------------------------------------------------------------------
ResetList::
        push    af
        push    bc
        push    de
        push    hl

        ;Switch to the objectList RAM bank
        ld      a,OBJLISTBANK
        ld      [$ff00+$70],a

        ;Set object zero (which should never be accessed) to
				;all-null to help ID infinite loops.
				ld      hl,objects
				ld      b,16
				xor     a
.setObjNullLoop
				ld      [hl+],a
				dec     b
				jr      nz,.setObjNullLoop

        ;Clear all elements of headTable[] and tailTable[] to
        ;point to null.  tailTable[] follows headTable[] in memory so
        ;in total that's 512 bytes we need to set (or 256*2)
        ld      hl,headTable
        xor     a
        ld      c,0           ;e.g. counter of 256

.loop1  ld      [hl+],a
        ld      [hl+],a
        dec     c
        jr      nz,.loop1

        ;Switch to the object RAM bank
        ld      a,OBJBANK
        ld      [$ff00+$70],a

        ;Set firstFreeObj to point to the first object, 1 ($d010)
        ld      a,1
        ld      [firstFreeObj],a

				;255 objExists flags to zero
				ld      a,OBJLISTBANK
				ld      bc,255
				ld      d,0
				ld      hl,objExists+1
				call    MemSet

				;set objExists[0] to 1 to prevent it from being allocated
				ld      a,1
				ld      [objExists],a

        ld      a,((objExists+1) & $ff)
				ld      [iterateNext],a
				ld      a,(((objExists+1)>>8) & $ff)
				ld      [iterateNext+1],a

				ld      a,255
				ld      [numFreeObjects],a

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      ClearFGBGFlags
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Clears bgAttributes and fgAttributes
;---------------------------------------------------------------------
ClearFGBGFlags::
        push    bc
        push    de
        push    hl

        ld      a,OBJLISTBANK
				ld      bc,256
				ld      d,0
				ld      hl,bgAttributes
				call    MemSet

				ld      a,OBJLISTBANK
				ld      bc,256
				ld      d,0
				ld      hl,fgAttributes
				call    MemSet

IF 0
				;set all bgAttribute flags to zero
				ld      c,0
				ld      hl,bgAttributes
				xor     a
.bgAttrLoop
        ld      [hl+],a
				dec     c
				jr      nz,.bgAttrLoop

				;set all fgAttribute flags to zero
				ld      c,0
				ld      hl,fgAttributes
				xor     a
.attrLoop
        ld      [hl+],a
				dec     c
				jr      nz,.attrLoop
ENDC

				ld      a,OBJLISTBANK
				ld      bc,256
				ld      d,0
				ld      hl,associatedIndex
				call    MemSet

				ld      a,OBJLISTBANK
				ld      bc,512
				ld      d,0
				ld      hl,classLookup
				call    MemSet

				pop     hl
				pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CreateObject
; Arguments:    c  - class index of object to create
;               hl - ptr to location in map
; Returns:      de - address of object
; Alters:       af,de
; Description:  Creates and adds the specified object into the list
;               providing there's room.  Equivalent to the following
;               C code:
;
;                 if(!firstFreeObj) return 0;
;                 newObj = firstFreeObj;
;                 firstFreeObj = (next free obj index);
;                 if(!headTable[c]){
;                   headTable[c] = tailTable[c] = newObj;
;                 }else{
;                   tailTable[c]->nextItem = newObj;
;                   tailTable[c] = newObj;
;                 }
;                 return newObj;
;---------------------------------------------------------------------
CreateObject::
        push    af
        push    bc
        push    hl

        ld      a,OBJBANK       ;switch in Object RAM
        ld      [$ff00+$70],a

        ;see if there's room for a new object
        ;if(!firstFreeObj) return 0;
        ld      a,[firstFreeObj]
        or      a                  ;check it out
        jr      nz,.freeNodeExists

        ld      de,0               ;return null
        jp      .doneHL

.freeNodeExists
        push    bc             ;save class index for a bit
        ;newObj = firstFreeObj
        ;setup de to point to free node
				ld      [curObjIndex],a
				call    IndexToPointerDE ;de is now ptr to free node

        ;store location ptr (hl)
        ld      a,l
        ld      [de],a    ;OBJ_IPOS
        inc     de
        ld      a,h
        ld      [de],a    ;OBJ_JPOS
        dec     de

				ld      hl,numFreeObjects
				dec     [hl]

        ;firstFreeObj = (next free object index)
				ld      a,OBJLISTBANK
				ld      [$ff70],a
				ld      a,[firstFreeObj]
				ld      h,((objExists>>8) & $ff)
				inc     a
				jr      z,.foundNextFree   ;no free objects
				ld      l,a
.lookAtNextObj
				ld      a,[hl+]
				or      a
				jr      nz,.thisObjNotFree

				dec     hl
				ld      a,l
				jr      .foundNextFree

.thisObjNotFree
        ld      a,l
				or      a
				jr      nz,.lookAtNextObj
				;no free objects (1st is zero)

.foundNextFree
				ld      [firstFreeObj],a

        ;if(!headTable[c]){
				ld      h,((headTable>>8) & $ff)
				ld      l,c
        ld      a,[hl]         ;get object index
        or      a
        jr      nz,.headExists

.noHead ;headTable[c] = curObjIndex
        ld      a,[curObjIndex]
				ld      [hl],a

        ;tailTable[c] = curObjIndex
				ld      h,((tailTable>>8) & $ff)     ;hl is tailTable[c]
        ld      [hl],a

        ;switch in object RAM
        ld      a,OBJBANK
        ld      [$ff00+$70],a

        jr      .setNextToNull

.headExists
        ;oldTail = tailTable[c]
				ld      h,((tailTable>>8) & $ff)
        ld      a,[hl]         ;old tail index
				push    de
				call    IndexToPointerDE
				ld      b,d
				ld      c,e        ;bc = oldTail
				pop     de

        ;tailTable[c] = curObjIndex
				ld      a,[curObjIndex]
        ld      [hl],a

        ;switch in object RAM
        ld      a,OBJBANK
        ld      [$ff00+$70],a

        ;oldTail->nextItem = newObj
        ld      hl,OBJ_NEXT    ;offset to get to nextItem
        add     hl,bc          ;hl = &oldTail->nextItem
				ld      a,[curObjIndex]
        ld      [hl],a         ;oldTail->nextItem = newObj

.setNextToNull
        ;newObj->nextItem = null
        ld      hl,OBJ_NEXT    ;offset to get to nextItem low byte
				add     hl,de           ;hl = &newObj->nextItem
        xor     a
        ld      [hl],a         ;newObj->nextItem = null

        ;objExists[objectIndex] = 1;
        ld      a,OBJLISTBANK
        ld      [$ff00+$70],a
				call    GetObjectIndex    ;sets up hl
				ld      a,1
				ld      [hl],a

				;objClassLookup[objIndex] = classIndex
				ld      h,((objClassLookup>>8) & $ff)
				pop     bc                ;get class lookup in c
				ld      [hl],c

.doneHL pop     hl
        ;de is return value
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      CreateInitAndDrawObject
; Arguments:    c  - class index to create
;               hl - ptr to location in map
; Returns:      de - address of object
; Alters:       af,de
; Description:  Creates and adds the specified object into the list
;               providing there's room.
;---------------------------------------------------------------------
CreateInitAndDrawObject::
        push    bc
				push    hl

				call    CreateObject
				ld      a,d
				or      a
				jr      z,.done

				ld      b,METHOD_INIT
				call    CallMethod
        ld      b,METHOD_DRAW
				call    CallMethod

.done
				pop     hl
				pop     bc
				ret


;---------------------------------------------------------------------
; Routine:      DeleteObject
; Arguments:    c  - class index of object to delete
;               de - address of object
; Alters:       af
; Description:  Deletes the specified object from the class index's
;               object list and returns it to the free node list.
;               Equivalent to the following C code:
;
;                 //find the object
;                 prev = 0;
;                 for(cur=headTable[c]; cur; cur=cur->nextItem){
;                   if(cur==obj) break;
;                   prev = cur;
;                 }
;                 if(!cur) goto addToFreeList;    //object not found
;
;                 //handle special cases of head and tail
;                 if(cur==headTable[c]){
;                   headTable[c] = cur->nextItem;
;                 }else{
;                   prev->nextItem = cur->nextItem;
;                 }
;                 if(cur==tailTable[c]){
;                   tailTable[c] = prev;
;                 }
;
;                 addToFreeList:
;                   firstFreeObj = min(firstFreeObj, curIndex);
;                   objExists[objIndex] = 0;
;---------------------------------------------------------------------
DeleteObject::
        push    bc
				push    de
				push    hl

				ld      hl,numFreeObjects
				inc     [hl]

        ;retrieve & save index of next object
				ld      a,OBJBANK
				ld      [$ff70],a
				ld      hl,OBJ_NEXT
				add     hl,de
				ld      a,[hl]
				ld      [nextObjIndex],a

        ;switch in objectList RAM
        ld      a,OBJLISTBANK
        ld      [$ff00+$70],a

				;hl = &headTable[c]
				ld      h,((headTable>>8) & $ff)
				ld      l,c

        ;c = object index to remove
				call    PointerDEToIndex
				ld      [curObjIndex],a
				ld      c,a
				;push    de          ;save original ptr to object

				; prev = 0
				; for(cur=headTable[c]; cur!=obj; cur=cur->nextItem){
				;   prev = cur;
				; }

				;b is prev index, a is cur index
				ld      b,0         ; prev = 0;
				ld      a,[hl]      ; cur=headTable[c]
				push    hl          ; save headTable
				push    hl          ; save headTable again

				push    af
				ld      a,OBJBANK
				ld      [$ff70],a
				pop     af

        ;cur equal to desired?
.findIt
				cp      c
				jr      z,.foundIt

				;prev = cur
				ld      b,a

				;cur=cur->nextItem
				call    IndexToPointerHL
				ld      de,OBJ_NEXT
				add     hl,de

				ld      a,[hl]
				jr      .findIt

.foundIt
        pop     hl      ;retrieve headTable[c]

				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ;check value of prev to determine if cur is head or not
				ld      a,b
				or      a

				;is head, set headTable[c] = cur->nextObj
				jr      z,.afterCheckHead

.notHead
        ;prev->nextObj = cur->nextObj
				call    IndexToPointerHL     ;'a' is prevObj
				ld      de,OBJ_NEXT
				add     hl,de
				ld      a,OBJBANK
				ld      [$ff70],a

.afterCheckHead
				ld      a,[nextObjIndex]
				ld      [hl],a

        ;-------------------------check tail-----------------
				; if(cur==tailTable[c]){
				;   tailTable[c] = prev;
				; }
				ld      a,OBJLISTBANK
				ld      [$ff70],a
				pop     hl                         ;retrieve headTable[c]
				ld      h,((tailTable>>8) & $ff)   ;make it tailTable[c]

        ld      a,c                        ;c is cur (found) obj
				cp      [hl]
				jr      nz,.afterCheckTail

				ld      [hl],b    ;change tail = prev

.afterCheckTail
        ;objExists[objIndex] = 0;
				ld      h,((objExists>>8) & $ff)  ;hl = &objExists[objIndex]
				ld      a,[curObjIndex]
				ld      l,a
				xor     a
				ld      [hl],a

				;firstFreeObj = min(firstFreeObj, curObjIndex)
				ld      a,[firstFreeObj]
				cp      l         ;compare to curObjIndex
				jr      c,.afterSetFirstFree   ;no change

				ld      a,l
				ld      [firstFreeObj],a

.afterSetFirstFree

				;pop     de       ;retrieve original pointer to object

				pop     hl
				pop     de
				pop     bc
				ret

;---------------------------------------------------------------------
; Routine:      IterateAllLists
; Arguments:    b  - offset of method to call on a given object
; Description:  Loops through all the objects in each class calling a
;               specified method on each.  Makes use of the IterateList
;               routine to do so.
;
;               Equivalent to the following C code:
;
;               void IterateAllLists(void *fnptr()){
;                 for(i=0; i<256; i++){
;                   IterateList(headTable[i],fnptr);
;                 }
;               }
;
;---------------------------------------------------------------------
IterateAllLists::
        push    bc
        push    de
        push    hl

        ld      hl,headTable     ;start of array of ptrs to heads of list
        ld      c,0              ;loop 0...numClasses - 1

.loop   ld      a,OBJLISTBANK    ;switch in objectList RAM
        ld      [$ff00+$70],a

        ld      a,[hl+]          ;de = headTable[i]
				or      a
				jr      z,.afterIterate

				call    IndexToPointerDE
        call    IterateList

.afterIterate
        inc     c
				jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      IterateList
; Arguments:    b  - offset of method to call on a given object
;               c  - class index of object
;               de - ptr to current object
; Description:  Given a pointer to a list node (presumably the head),
;               loops though all linked nodes calling a specified method
;               on each object.
;
;               Equivalent to the following C code:
;
;               void IterateList(Node*cur, void *fnptr()){
;                 if(!cur) return;
;                 do{
;                   cur->fnptr();   //not really a C cmd I know!
;                   cur = cur->nextItem;
;                 }while(cur);
;               }
;
;---------------------------------------------------------------------
IterateList::
        push    bc
        push    de
        push    hl

        ldio    a,[curObjWidthHeight]
        push    af

        ;pre-test curPtr to avoid unnecessary work if null
        ld      a,d              ;test high byte of ptr
        or      a
        jr      z,.done

        ;save class index
        ld      a,c
        ld      [delTempL],a
				ld      a,b
				ld      [delTempH],a  ;and method type

        ld      a,OBJLISTBANK
				ld      [$ff70],a

        ;convert offset into actual address of class method to call
        ld      a,b              ;save function offset
        ld      b,0              ;clear high byte of bc
        sla     c                ;shift c one left
        rl      b                ;bit shifted out of c into b
        ld      hl,classLookup
        add     hl,bc            ;hl is &classLookup[classIndex*2]

        ld      c,a              ;method offset into c
        ld      a,[hl+]
        ld      b,a              ;store LOW byte of addr in b
        ld      h,[hl]           ;get high byte
        ld      l,b              ;hl is now ptr to class
        ld      b,0              ;clear high byte of bc
        add     hl,bc            ;hl is now ptr to ptr to class method

				call    GetMethodAddrFromPointer

.loop   ;get ptr to next before calling method
        ld      a,OBJBANK        ;switch in object RAM
        ld      [$ff00+$70],a

        push    hl
        ld      hl,OBJ_NEXT
        add     hl,de
        ld      a,[hl]
				call    IndexToPointerHL
				ld      b,h
				ld      c,l
        pop     hl
        push    bc               ;save ptr to next on stack

        push    hl
        ld      bc,.returnAddress   ;save return address on stack
        push    bc
        ld      a,[delTempL]           ;class index into c
        ld      c,a

        ;----call super methods
        push    bc
				push    de
				ld      a,[delTempH]   ;method index
				cp      METHOD_INIT
				jr      nz,.checkSuperDie

				call    SuperInit
				jr      .afterSuperDie

.checkSuperDie
        cp      METHOD_DIE
				jr      nz,.afterSuperDie

				call    SuperDie

.afterSuperDie
        ld      a,b
				cp      METHOD_CHECK
				jr      nz,.afterCheckIdle
				ld      a,[allIdle]
				or      a
				jr      z,.afterCheckIdle
				;can't be explosion
				pop     de
				pop     bc
				ld      a,c
				cp      $ff
				jr      z,.returnAddress
				jr      .afterPopDEBC
.afterCheckIdle

        pop     de
				pop     bc
.afterPopDEBC
				;---------

				push    hl
        call    SetObjWidthHeight
				pop     hl
        jp      hl                ;start class method (de is cur)
.returnAddress

        pop     hl
        pop     de                  ;de = de->nextItem
        ld      a,d
        or      a                ;we done?
        jr      nz,.loop

.done   pop     af
        ldio    [curObjWidthHeight],a
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindObject
; Arguments:    c  - class index of object to find
;               de - location of object
; Returns:      de - ptr to object
;               a  - non-zero if object was found
; Alters:       af,de
; Description:  Given a class and a location, finds the corresponding
;               object.
; Note:         Leaves the RAM bank set to OBJECT mem
;
;               cur = headTable[c];
;               while(cur){
;                 if(cur->loc == loc) return cur;
;                 cur = cur->nextItem;
;               }
;---------------------------------------------------------------------
FindObject::
        push    bc
        ;de is return value
        push    hl

        ;find the head of the list
        ld      a,OBJLISTBANK    ;switch in objectList RAM
        ld      [$ff00+$70],a

        ;find byte index into headTable array
				ld     h,((headTable>>8) & $ff)
				ld     l,c
        ld     a,[hl]
				call   IndexToPointerHL  ;hl is head of list

        ld     bc,OBJ_NEXT-1     ;offset to add to hl during loop

        ;loop while our pointer is non-null
        ld      a,OBJBANK        ;switch in object RAM
        ld      [$ff00+$70],a

.terminationTest
        ld      a,h              ;high byte of ptr
        or      a                ;null?
        jr      nz,.pointerOkay

.pointerNull
        ld      de,0             ;return null
        jr      .done

.pointerOkay
        ;test to see if object->loc == loc
        ld      a,[hl+]          ;compare low byte
        cp      e
        jr      nz,.continue
        ld      a,[hl]           ;compare high byte
        cp      d
        jr      nz,.continue

.foundMatch
        dec     hl
        jr      .returnMatch

.continue
        add     hl,bc            ;add offset to get to nextItem
        ld      a,[hl]
				call    IndexToPointerHL ;cur = cur->nextItem
        jr      .terminationTest

.returnMatch
        ld      d,h
        ld      e,l

.done   pop     hl
        ;de is return value
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CallMethod
; Arguments:    b  - offset of method to call
;               c  - class index of object
;               de - ptr to object
; Returns:      a  - return value
; Alters:       af
; Description:  Calls the a class method passing in the location of an
;               associated object.
;               If calling Init or Die then calls SuperInit or
;               or SuperDie first.
;---------------------------------------------------------------------
CallMethod::
        ld      a,b
        cp      METHOD_CHECK
				jr      nz,.afterCheckIdle

				ld      a,[allIdle]
				or      a
				jr      z,.afterCheckIdle
				;can't be explosion
				ld      a,c
				cp      $ff
				ret     nz

.afterCheckIdle
        push    bc
				push    de
        push    hl
        ldio    a,[curObjWidthHeight]
        push    af

        call    SetObjWidthHeight

				ld      a,b
				cp      METHOD_INIT
				jr      nz,.checkSuperDie

				call    SuperInit
				jr      .afterSuperDie

.checkSuperDie
        cp      METHOD_DIE
				jr      nz,.afterSuperDie

				call    SuperDie

.afterSuperDie
        ;find the base address of class and add method offset
        ;get offset into classLookup
        ld      l,c
				ld      a,OBJLISTBANK
				ld      [$ff70],a
        xor     a
        sla     l
        rla
        add     ((classLookup>>8) & $ff)
        ld      h,a                 ;hl is &classLookup[c]
        ld      a,[hl+]
        add     b                   ;add offset of method
        ld      h,[hl]
        ld      l,a                 ;hl is addr of class methods
				ld      a,0
        adc     h
        ld      h,a                 ;hl is addr of specific method

				call    GetMethodAddrFromPointer

        ld      a,c                 ;store class index in A temporarily
        ld      bc,.returnAddress   ;save return address on stack
        push    bc
        ld      c,a                 ;class index into c
        jp      hl                ;start class method (de is cur)
.returnAddress

.done
        ld      h,a  ;save return value
        pop     af
        ldio    [curObjWidthHeight],a
        ld      a,h  ;restore return value
        pop     hl
				pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetObjWidthHeight
; Arguments:    c - class index
; Returns:      Nothing.
; Alters:       af,hl
; Description:  Sets up [curObjWidthHeight] with either 1 (for 1x1)
;               or 2 (2x2)
;---------------------------------------------------------------------
SetObjWidthHeight::
        ;set the tile width and height to either 1x1 or 2x2
				ld      a,TILEINDEXBANK
				ld      [$ff70],a
				ld      h,((fgAttributes>>8) & $ff)
				ld      l,c
				ld      a,[hl]
				rrca
				swap    a
				and     1
				inc     a           ;one or two
				ldio    [curObjWidthHeight],a
				ret

;---------------------------------------------------------------------
; Routine:      GetObjectIndex
; Arguments:    de - ptr to object
; Returns:      hl - &objExists[objIndex]
; Alters:       af,hl
;---------------------------------------------------------------------
GetObjectIndex:
        call    PointerDEToIndex
				ld      h,((objExists>>8) & $ff)
				ld      l,a
        ret

;---------------------------------------------------------------------
; Routine:      IterateMaxObjects
; Arguments:    b  - offset of method to call on a given object
;               c  - max objects to iterate through
; Alters:       af
; Description:  Loops through the next 256 objects indices.  If an
;               object exists then the specified method is called on
;               it and one is added to the maxObjects counter.  When
;               "maxObjects" have been handled the routine returns
;               and picks up again next time where it left off.  Each
;               time the counter wraps around the object timers are
;               incremented
;---------------------------------------------------------------------
IterateMaxObjects::
        push    bc
				push    de
				push    hl

        ld      a,OBJLISTBANK
        ld      [$ff00+$70],a

        ld      a,[iterateNext]
				ld      l,a
				ld      a,[iterateNext+1]
				ld      h,a

.outer  ld      e,0

.inner  ld      a,[hl+]                ;pick up the next flag

        or      a                      ;non-zero?
				jr      z,.continue

				;found an existing object
				push    de
				push    hl

				dec     hl   ;go back to where we found it

        ;convert objIndex hl into objAddress de
				ld      a,l
				call    IndexToPointerDE

        ;get the class index
				;hl = &objClassLookup[objIndex]
				ld      h,((objClassLookup>>8) & $ff)
				ld      a,[hl]                 ;what's the class index?
				ld      h,c                    ;stow c for a sec
				ld      c,a

				call    CallMethod

				ld      c,h                    ;retrieve c from storage

				pop     hl
        pop     de
				dec     c                      ;used one of our max checks

        ld      a,OBJLISTBANK          ;be sure & point back to our
        ld      [$ff00+$70],a          ;list RAM

.continue
        ;wrap around hl
        ld      a,h                    ;is hl < objExists + 256?
				cp      (((objExists>>8)&$ff)+1)
				jr      c,.hlOkay

				ld      hl,objExists+1            ;wrap around to beginning
				call    UpdateObjTimers           ;update timers

.hlOkay
        xor     a
				cp      c
				jr      z,.skipUnused          ;bust out if we've checked enough

				dec     e
				jr      nz,.inner

.skipUnused

.done
        ;save current value of hl
        ld      a,l
				ld      [iterateNext],a
				ld      a,h
				ld      [iterateNext+1],a

        pop     hl
				pop     de
				pop     bc
				ret


;---------------------------------------------------------------------
; Routine:      DeleteObjectsOfClass
; Arguments:    bc - class to delete objects
; Alters:       af
; Description:
;---------------------------------------------------------------------
DeleteObjectsOfClass::
        push    de
        push    hl

				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ld      e,1
				ld      hl,classLookup+2

.loop   ld      a,[hl+]
        cp      c
				jr      nz,.afterCheck
				ld      a,[hl]
				cp      b
				jr      nz,.afterCheck

				ld      a,e
				call    DeleteObjectsOfClassIndex

.afterCheck
        inc     hl
				inc     e
				jr      nz,.loop

        pop     hl
        pop     de
				ret

;---------------------------------------------------------------------
; Routine:      DeleteObjectsOfClassIndex
; Arguments:    a - class index to delete objects
; Alters:       af,hl
; Description:  Deletes all objects of the specified class index type
;---------------------------------------------------------------------
DeleteObjectsOfClassIndex::
        push    bc
				push    de
				push    hl

				ld      c,a                     ;class index in c

				ld      a,TILEINDEXBANK
				ldio    [$ff70],a

        ld      h,((headTable>>8) & $ff)
				ld      l,c

.loop   ld      a,[hl]                  ;get head object in de
        or      a
				jr      z,.done
        call    IndexToPointerDE

				ld      b,METHOD_DIE
				call    IterateList

				ld      a,OBJLISTBANK
				ld      [$ff70],a

.done
				pop     hl
				pop     de
				pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetFirst
; Arguments:    c  - class index
; Returns:      de - head of list or null
;               a  - null if no first object
;               zflag - or a
; Alters:       af,de
;---------------------------------------------------------------------
GetFirst::
        call    GetHead
				call    IndexToPointerDE
				ret

;---------------------------------------------------------------------
; Routine:      GetNextObject
; Arguments:    de - current object
; Returns:      a  - null if no next object
;               de - next object
;               zflag - or a
; Alters:       af,de
;---------------------------------------------------------------------
GetNextObject::
        call    GetNext
				call    IndexToPointerDE
				ld      a,d
				or      a
				ret

;---------------------------------------------------------------------
; Routine:      GetNext
; Arguments:    de - current object
; Returns:      a  - index of next object or null
; Alters:       af
;---------------------------------------------------------------------
GetNext::
        push    hl

				ld      a,OBJBANK
				ld      [$ff70],a

				ld      hl,OBJ_NEXT
				add     hl,de
				ld      a,[hl]

				pop     hl
				or      a
				ret

;---------------------------------------------------------------------
; Routine:      SetNext
; Arguments:    a  - index of next object
;               de - current object
; Returns:      Nothing.
; Alters:       Nothing.
;---------------------------------------------------------------------
SetNext::
        push    hl
        push    af
        ld      a,OBJBANK
				ldio    [$ff70],a
				pop     af

				ld      hl,OBJ_NEXT
				add     hl,de
				ld      [hl],a

				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      SetHead
; Arguments:    a  - index to set head to
;               c  - class index
; Returns:      None.
; Alters:       af
;---------------------------------------------------------------------
SetHead::
        push    hl
				push    af
				ld      a,OBJLISTBANK
				ld      [$ff70],a
				pop     af

        ld      h,((headTable>>8) & $ff)
				ld      l,c

				ld      [hl],a
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      GetHead
; Arguments:    c  - class index
; Returns:      a  - index of object at head or null if empty list
; Alters:       af
;---------------------------------------------------------------------
GetHead::
        push    hl
				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ld      h,((headTable>>8) & $ff)
				ld      l,c

        ld      a,[hl]                  ;get head object index
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      GetTail
; Arguments:    c  - class index
; Returns:      a  - index of object at tail or null if empty list
;               de - list
; Alters:       af
;---------------------------------------------------------------------
GetTail::
        push    hl
				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ld      h,((tailTable>>8) & $ff)
				ld      l,c

        ld      a,[hl]                  ;get tail object index
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      SetTail
; Arguments:    a  - index to set head to
;               c  - class index
; Returns:      Nothing.
; Alters:       Nothing.
;---------------------------------------------------------------------
SetTail::
        push    hl
				push    af
				ld      a,OBJLISTBANK
				ld      [$ff70],a
				pop     af

        ld      h,((tailTable>>8) & $ff)
				ld      l,c

				ld      [hl],a
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      GetNumObjects
; Arguments:    c  - class index
; Returns:      a  - object count for class
;               zflag - or a
; Alters:       af
;---------------------------------------------------------------------
GetNumObjects::
        push    bc
        push    de
        push    hl

        ld      b,0
        call    GetFirst
        jr      z,.countFinished

.getNext
        inc     b
        call    GetNextObject
        jr      z,.countFinished
        jr      .getNext

.countFinished
        ld      a,b
        or      a

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetAssociated
; Arguments:    c  - class index
; Returns:      a  - associated class index
; Alters:       af
;---------------------------------------------------------------------
GetAssociated::
        push    hl
        ld      a,TILEINDEXBANK
				ld      [$ff70],a
				ld      h,((associatedIndex>>8)&$ff)
				ld      l,c
				ld      a,[hl]
				pop     hl
				ret

;---------------------------------------------------------------------
SECTION "ObjListHome",ROM0
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Routine:      InitFOF
; Arguments:    none
; Returns:      nothing
; Alters:       af
; Description:  Initializes the Friend Or Foe Table so that each group
;               is friends only with itself except for:
;                 - FFA group friends with no one (not even selves)
;                 - MONSTERM/N (groups M&N) set to friends with all
;                   but FFA
;                 - MONSTERB set to friends with hero
;---------------------------------------------------------------------
InitFOF::
        push    bc
        push    de
				push    hl

				ld      a,OBJLISTBANK
				ld      [$ff70],a

				ld      c,0                ;loop 256 times
				ld      hl,FOFTable
				xor     a

.loop1  ld      [hl+],a
        dec     c
				jr      nz,.loop1

				ld      hl,FOFTable+17
				ld      c,15
				ld      a,1
				ld      de,16          ;offset

.loop2  ld      [hl+],a
        add     hl,de
        dec     c
				jr      nz,.loop2

        ;set monster N to be friends with all but FFA
				;row
				ld      hl,FOFTable+30   ;row 2, second to last column
				ld      c,15             ;set next 15 rows
.loop30 ld      [hl],a
        add     hl,de
				dec     c
				jr      nz,.loop30

        ;column
				ld      hl,FOFTable+(14*16)+1
				ld      c,15
.loop40 ld      [hl+],a
        dec     c
				jr      nz,.loop40

        ;set monster N to be friends with all but FFA
				;row
				ld      hl,FOFTable+31   ;row 2, last column
				ld      c,15             ;set next 15 rows
.loop3  ld      [hl],a
        add     hl,de
				dec     c
				jr      nz,.loop3

        ;column
				ld      hl,FOFTable+(15*16)+1
				ld      c,15
.loop4  ld      [hl+],a
        dec     c
				jr      nz,.loop4

				ld      a,1
				ld      b,GROUP_HERO
				ld      c,GROUP_MONSTERB
				call    SetFOF

				pop     hl
				pop     de
				pop     bc
				ret

;---------------------------------------------------------------------
; Routine:      SetFOF
; Arguments:    a - value to set to (0=enemies or 1=friends)
;               b - group 1
;               c - group 2
; Returns:      nothing
; Alters:       af
; Description:  Sets an entry in the FOF table
;---------------------------------------------------------------------
SetFOF::
				push    hl

        ;combine b and c in l
				push    af

				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ld      a,b
				swap    a
				or      c
				ld      l,a
				ld      h,((FOFTable>>8) & $ff)
				pop     af

        ;set the one entry
				ld      [hl],a

				;set the reverse entry
				swap    l
				ld      [hl],a

				pop     hl
				ret


;---------------------------------------------------------------------
; Routine:      GetFOF
; Arguments:    b - group 1
;               c - group 2
; Returns:      a - 1=friend, 0=foe
; Alters:       af
; Description:  Sets an entry in the FOF table
;---------------------------------------------------------------------
GetFOF::
        push    hl

				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ld      a,b
				swap    a
				or      c
				ld      l,a
				ld      h,((FOFTable>>8) & $ff)

				ld      a,[hl]

				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      LinkRemakeLists
; Arguments:    None.
; Alters:       af
; Returns:      Nothing.
; Description:  Initializes some values.
;                 objTimerBase   = 0
;                 objTimer60ths  = 0
;                 heroTimerBase  = 0
;                 heroTimer60ths = 0
;                 oamFindPos = 0
;                 baMoved = 0
;                 bsMoved = 0
;                 iterateNext = objExists + 1
;
;               Remakes the tailTable.
;               Waits for a VBLANK
;               Resets $ff+vblankTimer to zero
;               Resets updateTimer to zero
;---------------------------------------------------------------------
LinkRemakeLists::
        push    bc
				push    de
				push    hl

				;initialize some values
				xor     a
				ld      [objTimerBase],a
				ld      [objTimer60ths],a
				ld      [heroTimerBase],a
				ld      [heroTimer60ths],a
				ld      [oamFindPos],a
				ld      [baMoved],a
				ld      [bsMoved],a
				ld      de,objExists+1
				ld      hl,iterateNext
				ld      [hl],e
				inc     hl
				ld      [hl],d

				ld      a,OBJLISTBANK
				ld      [$ff70],a

        ;----remake tailTable-----------------------------------------
				;first go through and zero out contents of tailTable
				ld      hl,tailTable
				ld      c,0            ;loop 256 times
				xor     a
.zeroTailTable
        ld      [hl+],a
				dec     c
				jr      nz,.zeroTailTable

        ;start at the head of each list and follow each link until
				;a null link is found.  That will be the tail.
				ld      de,headTable
.getNextListHead
				ld      a,[de]
				or      a              ;this linked list null?
				jr      z,.afterMakeTail

        ld      b,a
				ld      a,OBJBANK
				ld      [$ff70],a
				ld      a,b              ;index of object
				ld      bc,OBJ_NEXT
.followLink
				call    IndexToPointerHL ;convert into object pointer
				add     hl,bc            ;set HL to point to link
				ld      a,[hl]           ;get link
				or      a
				jr      nz,.followLink

				;HL is the tail + OBJ_NEXT
				;convert HL to obj index and use that to set up
				;entry into tailTable
				ld      a,OBJLISTBANK
				ld      [$ff70],a
				ld      a,l              ;align hl on 16-byte boundary
				and     %11110000
				ld      l,a
				call    PointerHLToIndex
				ld      d,((tailTable>>8) & $ff) ;de is &tailTable[class]
				ld      [de],a
				ld      d,((headTable>>8) & $ff) ;de is &headTable[class]

.afterMakeTail
        inc     de
				ld      a,e
				or      a
				jr      nz,.getNextListHead

        xor     a
				ldio    [vblankTimer],a
				ldio    [updateTimer],a

				;count the number of free objects
				ld      c,$ff
				ld      hl,objExists+1
.countFree
				ld      a,[hl+]
				or      a
				jr      z,.countContinue
        dec     c
.countContinue
        ld      a,h
				cp      $d5
				jr      nz,.countFree
				ld      a,c
				ld      [numFreeObjects],a

				call    SetBGSpecialFlags

        ld      b,METHOD_DRAW
        call    IterateAllLists

				call    ClearBackBuffer

        call    RestrictCameraToBounds
				call    ScrollToCamera
        call    DrawMapToBackBuffer

				;turn on sound master control
				ld      a,$80
				ld      [$ff26],a

				ld      a,$ff
				ld      [$ff24],a         ;full volume both channels
				ld      [$ff25],a         ;all sounds to both channels

				pop     hl
				pop     de
				pop     bc
				ret

;---------------------------------------------------------------------
; Routine:      GetClass
; Arguments:    de - current object
; Returns:      c  - class index of object
; Alters:       af,c
;---------------------------------------------------------------------
GetClass::
        push    hl
        ld      a,OBJLISTBANK
				ldio    [$ff70],a
				call    PointerDEToIndex
				ld      h,((objClassLookup>>8) & $ff)
				ld      l,a
				ld      c,[hl]   ;obj class
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      InstanceOf
; Arguments:    c  - class index of object
;               hl - class (e.g. classWallCreature)
; Returns:      a  - 1 if this instanceof, 0 if not instanceof
; Alters:       af,hl
;---------------------------------------------------------------------
InstanceOf::
        push    de
				ld      d,h
				ld      e,l
				call    GetClassMethodTable
				ld      a,d
				cp      h
				jr      nz,.false
				ld      a,e
				cp      l
				jr      nz,.false
				ld      a,1
				pop     de
				ret
.false
        pop     de
				xor     a
				ret

;---------------------------------------------------------------------
; Routine:      GetClassMethodTable
; Arguments:    c  - class index of object
; Returns:      hl - ptr to method vector table
; Alters:       af,hl
;---------------------------------------------------------------------
GetClassMethodTable::
        ld      a,OBJLISTBANK
				ldio    [$ff70],a

				ld      h,0
				ld      l,c
				sla     l
				rl      h
				push    bc
				ld      bc,classLookup
				add     hl,bc
				pop     bc

				ld      a,[hl+]
				ld      h,[hl]
				ld      l,a
				ret


;---------------------------------------------------------------------
; Routine:      GetFGMapping
; Arguments:    c  - class index
; Returns:      a  - tile index mapped to class
; Alters:       af, hl
;---------------------------------------------------------------------
GetFGMapping::
        ld      a,TILEINDEXBANK
				ldio    [$ff70],a
				ld      h,((fgTileMap>>8) & $ff)
				ld      l,c
				ld      a,[hl]
				ret

;---------------------------------------------------------------------
; Routine:      SetFGMapping
; Arguments:    a  - tile index to set to
;               c  - class index
; Returns:      Nothing.
; Alters:       af, hl
;---------------------------------------------------------------------
SetFGMapping::
        push    af
        ld      a,TILEINDEXBANK
				ldio    [$ff70],a
				pop     af
				ld      h,((fgTileMap>>8) & $ff)
				ld      l,c
				ld      [hl],a
				ret

;---------------------------------------------------------------------
; Routine:      GetBGMapping
; Arguments:    c  - class index
; Returns:      a  - tile index mapped to class
; Alters:       af, hl
;---------------------------------------------------------------------
GetBGMapping::
        ld      a,TILEINDEXBANK
				ldio    [$ff70],a
				ld      h,((bgTileMap>>8) & $ff)
				ld      l,c
				ld      a,[hl]
				ret

;---------------------------------------------------------------------
; Routine:      SetBGMapping
; Arguments:    a  - tile index to set to
;               c  - class index
; Returns:      Nothing.
; Alters:       af, hl
;---------------------------------------------------------------------
SetBGMapping::
        push    af
        ld      a,TILEINDEXBANK
				ldio    [$ff70],a
				pop     af
				ld      h,((bgTileMap>>8) & $ff)
				ld      l,c
				ld      [hl],a
				ret

;---------------------------------------------------------------------
; Routine:      CheckEachHero
; Arguments:    a  - skip hero1 if hero0 return true (1=yes, 0=no)
;               hl - routine to call
; Returns:      a  - 1 or 0 result of last function called
; Alters:       all
; Description:  loads {A} with hero0_index and then hero1_index,
;               calling the routine pointer with each.
;---------------------------------------------------------------------
CheckEachHero::
        push    af

				ld      a,[hero0_index]
				or      a
				jr      z,.checkHero1
				push    hl
				ld      de,.returnPoint0
				push    de ;return address
				jp      hl
.returnPoint0
        pop     hl
				or      a
				jr      z,.checkHero1

				;second is optional
				pop     af
				or      a
				ret     nz     ;optional okay

				push    af
.checkHero1
        pop     af
				ld      a,[hero1_index]
				or      a
				ret     z

        ld      de,.returnAddress1
				push    de
				jp      hl   ;will return to my parent
.returnAddress1
        ret

;---------------------------------------------------------------------
; Routine:      RemoveHero
; Arguments:    c  - hero class index
; Returns:      Nothing.
; Alters:       af
; Description:  Saving heroes current health etc into heroX_data.
;               If its health is zero:
;                  - restores health to full (incorrect)
;                  - changes map to [respawnMap] if local hero, leaves
;                    map be if remote hero.
;               Does nothing if class index is null.
;               Removes the hero from the map.
;               If local, sets [heroesPresent] to zero. If remote
;               then remote hero flag is removed by RemoveRemoteHero
;---------------------------------------------------------------------
RemoveHero::
        ld      a,c
				or      a
				ret     z

				push    bc
				push    de
				push    hl

				call    GetFirst  ;get the hero object in de
				call    GetHealth
				or      a
				jr      nz,.afterDeath

IF INFINITEHEALTH==0
				;----dead, create an explosion----
				call    GetFGAttributes
				and     %111   ;isolate color
				ld      [bulletColor],a
				call    GetCurLocation
				ld      a,l
				ld      [bulletLocation],a
				ld      a,h
				ld      [bulletLocation+1],a
				ld      b,16  ;initial frame
				call    CreateExplosion
ENDC

.afterDeath
        ld      a,[hero0_index]
				cp      c
				jr      nz,.handleHero1

				;----hero 0 (local)-----
				call    GetPuffCount
				ld      [hero0_puffCount],a
				call    GetHealth
				ld      [hero0_health],a
				ld      b,a
				ld      hl,hero0_data
				ld      a,[amLinkMaster]
				or      a
				jr      z,.removeRemote
				jr      .removeLocal

.handleHero1
				;----hero 1 (remote)----
				call    GetPuffCount
				ld      [hero1_puffCount],a
				call    GetHealth
				ld      [hero1_health],a
				ld      b,a
				ld      hl,hero1_data
				ld      a,[amLinkMaster]
				or      a
				jr      z,.removeLocal
				jr      .removeRemote

.removeLocal
        push    bc
				push    hl
				call    GetFacing
				ld      c,a
				call    RemoveFromMap
				xor     a
				ld      [heroesPresent],a
				pop     hl
				pop     bc

				push    bc
				push    de
				push    hl
				ld      de,classDoNothing
				call    GetClassMethodTable
				ld      b,h
				ld      c,l
				call    ChangeClass
				pop     hl
				pop     de
				pop     bc

				ld      a,b
				or      a
				jr      nz,.done        ;wasn't dying, just leaving

IF INFINITEHEALTH==0
        ;pause for a second
				ld      a,30
				call    Delay

        ;fade to black
        ;ld      a,30
        ;call    SetupFadeToBlack
        ;call    WaitFade

				;----respawn at the appropriate map----
				ld      de,HERODATA_ENTERDIR
				add     hl,de
				ld      a,EXIT_D
				ld      [hl],a

        call    UpdateState

        ld       hl,$1500
        ld       a,l
        ld       [curLevelIndex],a
        ld       a,h
        ld       [curLevelIndex+1],a
        ld       a,1
				ld       [timeToChangeLevel],a
ENDC
				jr      .done

.removeRemote
        call    RemoveRemoteHero

.done
				pop     hl
				pop     de
				pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CallBGAction
; Arguments:    a  - action type (BGACTION_HIT)
;               c  - class
;               hl - map location of bg tile
; Returns:      'a' zflag from action + a's zflag, normally:
;               0 - no explosion
;               non-zero - explosion
; Alters:       af
; Description:
;---------------------------------------------------------------------
CallBGAction::
        push    bc
				push    de
				push    hl

        ;ensure class IS a bg class
				ld      d,a
				ldio    a,[firstMonster]
				ld      e,a
				ld      a,c
				or      a
				jr      z,.returnAddress     ;null tile
				cp      e
				jr      nc,.returnAddress    ;is a monster (myself?)
				ld      a,d

        ;save return address on stack
				ld      de,.returnAddress
				push    de

				;get tile class in c
				push    af

        push    hl
				call    GetClassMethodTable
				ld      d,h
				ld      e,l
				pop     hl
				pop     af
				push    de          ;addr of method on stack

				ret                 ;call method

.returnAddress
				pop     hl
				pop     de
				pop     bc
				or      a
				ret

;---------------------------------------------------------------------
; Routine:      ChangeMyClass
;               ChangeMyClassAndRedraw
;               ChangeMyClassToAssociatedAndRedraw
; Arguments:    a  - new class type
;               c  - old class type
;               de - this
; Returns:      c  - new class type
; Alters:       af,c
; Description:  Changes this object from the old to new class type.
;---------------------------------------------------------------------
ChangeMyClassToAssociatedAndRedraw::
        call    GetAssociated
				jp      ChangeMyClassAndRedraw

ChangeMyClassAndRedraw::
        call    ChangeMyClass
				ld      b,METHOD_DRAW
				jp      CallMethod

ChangeMyClass::
        push    af
				call    RemoveObjectFromList
				pop     af
				ld      c,a
				call    AddObjectToList
				ret

;---------------------------------------------------------------------
; Routine:      RemoveObjectFromList
; Arguments:    c  - class type
;               de - this
; Returns:      Nothing.
; Alters:       af
; Description:  Removes the object from its class's linked list but
;               does not delete it.
;---------------------------------------------------------------------
RemoveObjectFromList::
        push    bc
				push    de
				push    hl

				call    PointerDEToIndex
				ld      b,a

				;head of list?
				call    GetHead
				cp      b
				jr      nz,.notHead

				;make next item new head of list
				call    IndexToPointerDE
				call    GetNext
				call    SetHead
				jr      .done

.notHead
.search
        ;search through list for item that points to that to remove
				call    IndexToPointerDE
				call    GetNext
				cp      b
				jr      nz,.search

.foundPrevious
        ;set prev->next = prev->next->next
				call    PointerDEToIndex
				push    af                 ;save index of prev
				ld      a,b                ;get searchObj
				call    IndexToPointerDE
				call    GetNext            ;searchObj->next
				ld      b,a
				pop     af
				call    IndexToPointerDE   ;prev = searchObj->next
				ld      a,b
				call    SetNext

				;if next is null then removed obj was tail.  Reset tail
				;to prev
				;ld      b,a   redundant; A already == B
				or      a
				jr      nz,.done

				call    PointerDEToIndex
				call    SetTail

.done
				pop     hl
				pop     de
				pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      AddObjectToList
; Arguments:    c  - class type
;               de - this
; Returns:      Nothing.
; Alters:       af
; Description:
;---------------------------------------------------------------------
AddObjectToList::
        push    de

				xor     a
				call    SetNext   ;obj->next = null in all cases

				call    PointerDEToIndex

        push    af

				;objClassLookup[objIndex] = classIndex
				ld      d,((objClassLookup>>8) & $ff)
				ld      e,a
				ld      a,OBJLISTBANK
				ldio    [$ff70],a
				ld      a,c
				ld      [de],a

        ;head == null?
        call    GetHead
				or      a
				jr      nz,.addToTail

.addToHead
        pop     af
				call    SetHead
				call    SetTail
				pop     de
				ret

.addToTail
        call    GetTail
				call    IndexToPointerDE
				pop     af

				call    SetNext
				call    SetTail

				pop     de
        ret

;---------------------------------------------------------------------
; Routine:      SetAssociated
; Arguments:    b - class to associate
;               c - current class
; Alters:       af
;---------------------------------------------------------------------
SetAssociated::
        push    hl
				ld      a,OBJLISTBANK
				ld      [$ff70],a

				ld      h,((associatedIndex>>8)&$ff)
				ld      l,c
				ld      [hl],b
				pop     hl
				ret

;---------------------------------------------------------------------
; Routine:      CountNumObjects
; Arguments:    a - class index to count
; Returns:      a - number of objects of this class
; Alters:       af
;---------------------------------------------------------------------
CountNumObjects::
				push    bc
        push    de

				ld      c,a

        ld      b,0
				call    GetFirst
				or      a
				jr      z,.done

				inc     b

.loop   call    GetNextObject
        or      a
				jr      z,.done
				inc     b
				jr      .loop

.done   ld      a,b
				pop     de
				pop     bc
				ret


;---------------------------------------------------------------------
; Routine:      ClassIndexIsHeroType
; Arguments:    a - hero flag e.g. HERO_BS_FLAG
;               c - class index
; Returns:      a - 1 if matches
;               zflag - or a
; Alters:       af
;---------------------------------------------------------------------
ClassIndexIsHeroType::
        push    bc
        ld      b,a

        ld      a,[hero0_index]
        cp      c
        jr      nz,.checkingHero1

.checkingHero0
        ld      a,[hero0_type]
        jr      .checkType

.checkingHero1
        ld      a,[hero1_type]
.checkType
        cp      b
        jr      nz,.returnFalse

        ld      a,1    ;return true
        or      a
        pop     bc
        ret

.returnFalse
        xor     a
        pop     bc
        ret

