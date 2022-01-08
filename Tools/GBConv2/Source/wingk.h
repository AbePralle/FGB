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
    inline int operator==(gkRGB &c2){
      return ((color.argb & 0xffffff) == (c2.color.argb & 0xffffff)); }
    inline int Equals(int _r, int _g, int _b);
		void   Combine(gkRGB c2, int alpha);
		operator COLORREF();
};

class gkPalGenItem{
  protected:
    gkRGB color;
    int occurrences;
    gkPalGenItem *nextItem;

  public:
    gkPalGenItem(gkRGB _color);
    ~gkPalGenItem();
    inline gkRGB GetColor();
    inline void AddOccurrence();
    inline int  GetOccurrences();
    inline void SetOccurrences(int n);
    inline void SetNextItem(gkPalGenItem *item);
    inline gkPalGenItem *GetNextItem();
    int    GetCount();
    static int SortCallback(const void *e1, const void *e2);
};

class gkPaletteGenerator{
  protected:
    gkPalGenItem *colorCube[13*4];

  public:
    gkPaletteGenerator();
    ~gkPaletteGenerator();
    void Reset();
    void AddColor(gkRGB color);
		int  GetNumColors();
    void CreatePalette(gkRGB *palette, int numEntries);
    int  GetHash(gkRGB color);
		int  ColorExists(gkRGB color);
    gkRGB MatchColor(gkRGB color);
};

class gkTransparencyTable{
  protected:
    gkBYTE *lookup;

  public:
    gkTransparencyTable();
    ~gkTransparencyTable();
    inline int LookupTransparencyOffset(int baseOffset, int alpha);
};

class gkWinShape{
	friend class gkRGB;

  protected:
    gkBYTE *data;
    int width, height;
    char bpp, fontSpacing, fontKerning;
    short int x_handle, y_handle;
    static gkTransparencyTable tranTable;

  public:
    gkWinShape();
    ~gkWinShape();

		inline gkBYTE* GetData(){ return data; }

    void  FreeData();
		inline void Reset(){ FreeData(); }
    void  Create(int _width, int _height);
	  HBITMAP GetDIB(HDC hdc);
    void  Cls();
    void  Cls(gkRGB color);
    void  Plot(int x, int y, gkRGB color, int testBoundaries=1);
    gkRGB Point(int x, int y, int testBoundaries=1);
		void  Line(int x1, int y1, int x2, int y2, gkRGB color);
		void  LineAlpha(int x1, int y1, int x2, int y2, gkRGB color, int alpha);
    void  RectFrame(int x, int y, int w, int h, gkRGB color);
    void  RectFill(int x, int y, int w, int h, gkRGB color);
    void  RectFillAlpha(int x, int y, int w, int h, gkRGB color, int alpha);
    void  RectFillChannel(int x, int y, int w, int h, gkRGB color, int mask);
		void  FloodFill(int x, int y, gkRGB color);
    void  RemapColor(gkRGB oldColor, gkRGB newColor);
		int   GetNumColors();
		int   GetPalette(gkRGB *palette, int maxColors);
    void  RemapToPalette(gkRGB *palette, int numColors);
    void  ReduceColors(int numColors);
    void  ExchangeColors(gkRGB c1, gkRGB c2);
    void  SetAlpha(int alpha);
    void  SetColorAlpha(gkRGB color, int alpha);

    int   GetShape(gkWinShape *srcShape, int x, int y, int w, int h);
    int   GetShape(gkWinShape *srcShape);
		int   GetShape(HDC hdc);
		int   GetShape(HBITMAP bitmap);
    int   SaveShape(char *filename);
    int   SaveShape(ostream &outfile);
    int   LoadShape(char *filename);
    int   LoadShape(istream &infile);
    int   LoadBMP(char *filename);
    int   LoadBMP(istream &infile);
    void Blit(gkWinShape *destShape, int x, int y, 
    	      int flags=GKBLT_TRANSPARENT);
    void BlitScale(gkWinShape *destShape, int x, int y, int scale,
    	      int flags=GKBLT_TRANSPARENT);
    void BlitScale(gkWinShape *destShape, int x, int y, float scale,
    	      int flags=GKBLT_TRANSPARENT);
		void BlitChannel(gkWinShape *destShape, int x, int y, int mask);
	  void BlitToHDC(HDC hDC, int x, int y);

    int GetWidth(){ return width; }
    int GetHeight(){ return height; }

    //internal support routines
    static void MemCpyTrans(gkBYTE *dest, gkBYTE *src, int nBytes);
    static void BlitLineScale(gkBYTE *dest, gkBYTE *src, int pixels,int ratio);
};

#endif

