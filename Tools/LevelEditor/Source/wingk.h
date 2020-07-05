#ifndef WINGK_H
#define WINGK_H

#include "stdafx.h"

#include <iostream.h>
#include <fstream.h>
#include <strstrea.h>
#include <string.h>
#include <stdlib.h>

typedef unsigned char gkBYTE;
typedef short int gkWORD;
typedef int gkLONG;

#define GKHANDLE_TL  0
#define GKHANDLE_TC  1
#define GKHANDLE_TR  2
#define GKHANDLE_CR  3
#define GKHANDLE_BR  4
#define GKHANDLE_BC  5
#define GKHANDLE_BL  6
#define GKHANDLE_CL  7
#define GKHANDLE_CENTER 8

#define GKBLT_TRANSPARENT 1

class gkIO{
  public:
    inline static int  ReadByte(istream &in){ return in.get(); }
    static int  ReadWord(istream &in);
    static int  ReadLong(istream &in); 
    static char *ReadString(istream &in);
    static char *ReadNewString(istream &in);
    inline static void WriteByte(ostream &out, int n){ out << (char) n; }
    static void WriteLong(ostream &out, int n);
    static void WriteWord(ostream &out, int n);
    static void WriteString(ostream &out, char *st);
};

struct gkRGB_4bytes{
  unsigned char b, g, r, a;
};

union gkRGB_ColorUnion{
  gkRGB_4bytes bytes;
  gkLONG argb;
};

class gkRGB{
  public:
    gkRGB_ColorUnion color;

    inline gkRGB(){ color.argb = 0xff000000; }
    inline gkRGB(int _r, int _g, int _b, int _a=255){ 
      color.bytes.r=_r; color.bytes.g=_g; color.bytes.b=_b; color.bytes.a=_a;}
    inline void SetR(gkBYTE n){ color.bytes.r = n; }
    inline void SetG(gkBYTE n){ color.bytes.g = n; }
    inline void SetB(gkBYTE n){ color.bytes.b = n; }
    inline void SetA(gkBYTE n){ color.bytes.a = n; }
    inline void SetARGB(gkLONG n){ color.argb = n; }
    inline gkBYTE GetR(){ return color.bytes.r; }
    inline gkBYTE GetG(){ return color.bytes.g; }
    inline gkBYTE GetB(){ return color.bytes.b; }
    inline gkBYTE GetA(){ return color.bytes.a; }
    inline gkLONG GetARGB(){ return color.argb; }
    inline int operator==(gkRGB &c2);
    inline int Equals(int _r, int _g, int _b);
    int    GetCategory();
		void   Combine(gkRGB c2, int alpha);
};

class gkPalGenItem{
  protected:
    gkRGB color;
    int occurrences;
    gkPalGenItem *nextItem;

  public:
    gkPalGenItem(gkRGB _color);
    gkPalGenItem(gkPalGenItem *item);
    ~gkPalGenItem();
    inline gkRGB GetColor();
    inline void AddOccurrence();
    inline int  GetOccurrences();
    inline void SetOccurrences(int n);
    inline void SetNextItem(gkPalGenItem *item);
    inline gkPalGenItem *GetNextItem();
    static int SortCallback(const void *e1, const void *e2);
};

class gkColorCategory{
  protected:
    gkPalGenItem *hashHead[64];
    gkPalGenItem *hashTail[64];
    int uniqueCount;
    short int curHash;
    gkPalGenItem *curItem;

  public:
    gkColorCategory();
    ~gkColorCategory();
    gkPalGenItem *GetFirstItem();
    gkPalGenItem *GetNextItem();
    gkPalGenItem *Exists(gkRGB color);
    void AddColor(gkRGB color);
    void SetZeroOccurrences(gkRGB color);
    int  GetHash(gkRGB color);
    int  GetUniqueCount(){ return uniqueCount; }
    gkRGB GetMostFrequent();
    gkPalGenItem *GetMostFrequentItem();
};

class gkPaletteGenerator{
  protected:
    gkColorCategory colorCube[512];   //8*8*8

  public:
    gkPaletteGenerator();
    ~gkPaletteGenerator();
    void Reset();
    void AddColor(gkRGB color);
    int  CreatePalette(gkRGB *palette, int numEntries);
    int  GetHash(gkRGB color);
    gkRGB MatchColor(gkRGB color);
    gkRGB GetMostFrequent();
    int   NumUniqueColors();
    gkColorCategory *GetCategory(int hash);
};

class gkTransparencyTable{
  protected:
    gkBYTE *lookup;

  public:
    gkTransparencyTable();
    ~gkTransparencyTable();
    inline int LookupTransparencyOffset(int baseOffset, int alpha);
};

class gkGBCPalette;

class gkWinShape{
  protected:
    gkBYTE *data;
    int width, height;
    char bpp, fontSpacing, fontKerning;
    short int x_handle, y_handle;
    short int x_origin, y_origin;

	public:
    static gkTransparencyTable tranTable;

  public:
    gkWinShape();
    ~gkWinShape();
    void  FreeData();
    void  Create(int _width, int _height);
    void  Cls();
    void  Cls(gkRGB color);
    void  Plot(int x, int y, gkRGB color, int testBoundaries=1);
    gkRGB Point(int x, int y, int testBoundaries=1);
		void  Line(int x1, int y1, int x2, int y2, gkRGB color);
		void  LineAlpha(int x1, int y1, int x2, int y2, gkRGB color, int alpha);
		void  RectFill(int x, int y, int w, int h, gkRGB color);
		void  RectFillAlpha(int x, int y, int w, int h, gkRGB color, int alpha);
    void  RemapColor(gkRGB oldColor, gkRGB newColor);
    void  RemapToPalette(gkRGB *palette, int numColors);
    int   ReduceColors(int numColors);
    void  RemapToGBC(gkRGB *palettes, int numPalettes, 
	int colorsPerPalette);
    void  ExchangeColors(gkRGB c1, gkRGB c2);
    void  SetAlpha(int alpha);
    void  SetColorAlpha(gkRGB color, int alpha);

    int   GetShape(gkWinShape *srcShape, int x, int y, int w, int h);
    int   GetShape(gkWinShape *srcShape);
    int   SaveShape(char *filename);
    int   SaveShape(ostream &outfile);
    int   LoadShape(char *filename);
    int   LoadShape(istream &infile);
    int   LoadBMP(char *filename);
    int   LoadBMP(istream &infile);
    void Blit(gkWinShape *destShape, int flags=GKBLT_TRANSPARENT);
    void Blit(gkWinShape *destShape, int x, int y, 
    	      int flags=GKBLT_TRANSPARENT);
    void BlitHalfBrite(gkWinShape *destShape, int x, int y, 
				int flags=GKBLT_TRANSPARENT);
    void BlitToDC(CDC *pDC, int x, int y);

    int GetWidth(){ return width; }
    int GetHeight(){ return height; }
    gkBYTE *GetData(){ return data; }

    //internal support routines
    static void MemCpyTrans(gkBYTE *dest, gkBYTE *src, int nBytes);
    static void MemCpyTransHalfBrite(gkBYTE *dest, gkBYTE *src, int nBytes);
    static void MemCpyHalfBrite(gkBYTE *dest, gkBYTE *src, int nBytes);
};

class gkGBCShape : public gkWinShape{
  protected:
    gkRGB colors[4];
    int   occurrences[4];
    int   colorsUsed;
    int   colorsMapped;    //bits 0-3 determine which colors are mapped
    int   numColorsMapped;
    gkGBCPalette *curPalette;

  public:
    gkGBCShape();
    ~gkGBCShape();

    inline int GetColorsUsed(){ return colorsUsed; }
    inline gkRGB *GetPalette(){ return colors; }
    inline gkGBCPalette *GetCurPalette(){ return curPalette; }
    inline void SetCurPalette(gkGBCPalette *pal){ curPalette = pal; }

    void ReduceTo4Colors();
    int  MatchPalette(gkRGB *palette, int numColors);
    void Finalize(int n);
};

class gkGBCPalette{
  protected:
    gkRGB colors[4];
    int colorsUsed;
    int numReferences;

  public:
    gkGBCPalette(gkRGB *init_colors, int init_colorsUsed);
    inline gkRGB *GetPalette(){ return colors; }
    inline int  GetColorsUsed(){ return colorsUsed; }
    inline void SetNumReferences(int n){ numReferences = n; }
    inline int  GetNumReferences(){ return numReferences; }
    static int SortByReferences(const void *e1, const void *e2);
    int  CanUnionWith(gkGBCPalette *p2, int maxColors);
    void MakeUnionWith(gkGBCPalette *p2);
};

#endif

