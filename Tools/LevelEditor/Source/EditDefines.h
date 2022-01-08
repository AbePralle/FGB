/*****************************************
* EditDefines.h
* 12/17/99
*
* Martin Casado
*
* List of definitions and Macros for 
* FGB level editer
********************************************/

#ifndef _OBEY_EDITER_LAW_OR_PERISH_IN_ETERNAL_PUDDING_
#define _OBEY_EDITER_LAW_OR_PERISH_IN_ETERNAL_PUDDING_

#include "wingk.h"


//width and height of tiles 
#define E_TILESIZE 16

// name of file which holds tiles
//#define E_TILETITLE "background1-228.bmp"
//#define E_PEOPLETITLE "objects241-308.bmp"

//size of pic for terrain
#define E_TILEBMPSIZEX 512
#define E_TILEBMPSIZEY 1024

//size of pic for peoples
#define E_PEOPLEBMPSIZEX 512
#define E_PEOPLEBMPSIZEY 256

//TOTAL BUFFER SIZE FOR TILES
#define E_TOTALBUFFERSIZEW 512
#define E_TOTALBUFFERSIZEH (E_TILEBMPSIZEY + E_PEOPLEBMPSIZEY)

#define E_LAST_TILE ((((E_PEOPLEBMPSIZEY + E_TILEBMPSIZEY))/16) * 32)

//struct to define pointer to a shape and the tile number
typedef struct picstruct{
	short int index;
	gkWinShape *pic;
}PicStruct;

//struct used for remapping of tile lists
typedef struct swapstruct{
	unsigned char index;
	short int classID;
}SwapStruct;

//maximum number of tiles for game
#define E_MAXTILES 4096

//Verticle and Horizontal scroll maximums for terraintile window
#define TERRAINSCROLLMAXH 512
#define TERRAINSCROLLMAXV (E_TILEBMPSIZEY + E_PEOPLEBMPSIZEY)

#define E_LASTTILE ((TERRAINSCROLLMAXV*32)/16)
#define E_FIRSTOBJ  (E_TILEBMPSIZEY * 2)

//default level size in grids
#define E_LEVELSIZEX 32
#define E_LEVELSIZEY 32

//default level name 
#define E_DEFAULTFILENAME "test.lvl"

#endif
