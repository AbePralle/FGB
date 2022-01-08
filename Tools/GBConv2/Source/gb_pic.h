#ifndef GB_PIC_H
#define GB_PIC_H

#include "wingk.h"

#define TILE_PAL0    0
#define TILE_X      16
#define TILE_BORDER 17

struct HashEntry{
	short int hash;
	short int index;

	HashEntry(){ hash = index = -1; }
};

class Open8BitHashTable{
	protected:
		HashEntry *table;
		int size;
		int entryPoint[256];

	public:
		Open8BitHashTable();
		~Open8BitHashTable();
		void Reset();
		void Create(int maxElements);
		int  SetFirstIndex(int code);
		int  GetNextIndex(int &position);
		void Add(int code, int index);
};

class gbPic;

class gbTile : public gkWinShape{
	protected:    
		int paletteUsed;
	  int colorsUsed;
		gkRGB *colors, *palettePtr;
		gkBYTE rawData[16];
		int dataHash;
		int tileIndex;

  public:
	  gbTile();
		~gbTile();
		void Reset();

		inline int GetColorsUsed(){ return colorsUsed; }
		inline int GetPaletteUsed(){ return paletteUsed; }
		inline gkRGB *GetColors(){ return colors; }
		inline int GetDataHash(){ return dataHash; }
		inline void SetTileIndex(int i){ tileIndex = i; }
		inline int  GetTileIndex(){ return tileIndex; }

		void OnColorChange();
		int  OnPaletteChange(int palettes);

		int  TestMatch(gkRGB *palette);
		void UsePalette(int palNum, gkRGB *palette);
		int  HasColor(gkRGB color);

    int  GetShape(gkWinShape *srcShape, int x, int y, int w, int h);
    void RemapColor(gkRGB oldColor, gkRGB newColor);
    void ExchangeColors(gkRGB c1, gkRGB c2);

		void MakeRawData(gbPic *pic);
		void SetRawData(gkBYTE *data);
		inline gkBYTE *GetRawData(){ return rawData; }
		void CreateFromRawData(gbPic *pic);
		int  CompareRawData(gkBYTE *data2);
		void SetPaletteUsed(gbPic *pic, int n);
		void CopyRawDataTo(gkBYTE *dest);
		void WriteRawData(ostream &out);
};

class gbSprite : public gkWinShape{
	protected:
		gkRGB *palette;
		int   xp, yp, paletteNum;
		gkBYTE rawData[32];

	public:
		gbSprite();
		~gbSprite();
		void Reset();
		void Create8x16FromSelection(int x1, int y1, gbTile *tile1, gbTile *tile2,
				 gkWinShape *selection, gbPic *pic);
		void Blit(gkWinShape *dest);
		void DrawFrame(gkWinShape *dest, int magnification);
		int  ExistsAtIndex(int i, int j);
		int  Unmake(gbPic *pic);
		void WriteTileDefinitions(ostream &out);
		void ReadTileDefinitions(istream &in);
		void WriteAttributes(ostream &out, int index);
		void ReadAttributes(istream &in, gbPic *pic);
		void CreateFromRawData();
		void MakeRawData();
};


class gbPic{
  friend class gbSprite;
  protected:
	  int tileWidth, tileHeight, totalTiles;
	  int displayWidth, displayHeight;
		int magnification;   //24:8, $100=100%, $80=50%, $200=200%
		int showGrid;

		gbTile *tiles;
		int    *selected;
		int    dragSetOrClear, dragStart_i, dragStart_j;

		gkWinShape displayBuffer, backbuffer, magnifiedArea;
		gkWinShape pixelBuffer, selectionBuffer;
		static gkWinShape nonPictureBG, gfxTiles[20];

		int needsRedraw;
		gkRGB palettes[16*4];

		gkRGB selectedColors[56], bgColor;
		int numSelColors;
		int numSelTiles;
		int curPalette;

		int numSprites;
		gbSprite *sprites[40];

		int numUniqueTiles, fileSize;

	public:
		static gkWinShape nonColorBG;

	  gbPic();
		~gbPic();
		void Reset();

		int LoadBMP(char *filename);
		void Redraw(int flags);
		gkWinShape *GetDisplayBuffer(int showSprites);
		gkWinShape *GetMagnifiedArea(int x, int y);
		void   SetMagnification(int n);
		gkRGB GetColor(int pal, int n);
		void  SetColor(int pal, int n, gkRGB c);
		int   GetSelected(int i, int j);
		void  GetIndicesAtPoint(int x, int y, int &i, int &j);
		gkRGB GetColorAtPoint(int x, int y);
		int   GetMappingAtPoint(int x, int y);
		void  OnMouseLMB(int x, int y);
		void  OnMouseLDrag(int x, int y);
		void  OnMouseLRelease(int x, int y);
		void  SetFirstColor(gkRGB c);
		void  AddNextColor(gkRGB c);
		void  RemoveColor(gkRGB c);
		void  ClearSelection();

		void  RemapSelectedToBGColor();
		void  SwapSelectedWithBGColor();
		void  AutoMapToPalette(int palettes);
		void  MapToPalette(int palettes);
		void  Unmap();
		void  SelectNonEmpty();
		void  SelectUnmapped();
		void  MakeSprites();
		int   FindBestSpritePalette(gkRGB *pal, int numColors);
		int   UnmakeSprite(int x, int y);
		void  SavePaletteInfo(ostream &out);
		void  SaveGBSprite(const char *filename);
		int   LoadGBSprite(const char *filename);
		void  SaveGBPic(const char *filename);
		int   LoadGBPic(const char *filename);
		void  AutoMap(int usePalettes);

		inline int GetTileWidth(){ return tileWidth; }
		inline int GetTileHeight(){ return tileHeight; }
		inline int GetDisplayWidth(){ return displayWidth; }
		inline int GetDisplayHeight(){ return displayHeight; }
		inline void SetNeedsRedraw(){ needsRedraw = 1; }
		inline int  GetNeedsRedraw(){ return needsRedraw; }
		inline int  GetMagnification(){ return magnification; }
		inline gkRGB *GetPalettes(){ return palettes; }
		inline gkRGB *GetPalette(int pal){ return &palettes[pal*4]; }
		inline gkRGB *GetSelectedColors(){ return selectedColors; }
		inline int   GetNumSelectedColors(){ return numSelColors; }
		inline void  SetBGColor(gkRGB c){ bgColor = c; }
		inline gkRGB GetBGColor(){ return bgColor; }
		inline void  SetCurPalette(int n){ curPalette = n; }
		inline int   GetCurPalette(){ return curPalette; }
		inline int   GetNumSprites(){ return numSprites; }
		inline int   GetNumSelTiles(){ return numSelTiles; }
		inline int   GetNumUniqueTiles(){ return numUniqueTiles; }
		inline int   GetFileSize(){ return fileSize; }
};

#endif

