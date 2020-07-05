#include "wingk.h"
#include <stdlib.h>

#include <strstrea.h>


gkTransparencyTable gkWinShape::tranTable;

struct BMP_header{
  gkLONG fSize;          //54 byte header + 4*numColors (1-8bit) + (w*h*bpp)/8
  gkWORD  zero1, zero2;   //0,0
  gkLONG offsetBytes;    //should be header (54) plus Palette Size

  gkLONG headerSize;     //size of remaining header (40)
  gkLONG width, height;  //w,h in pixels
  gkWORD planes, bpp;    //plane=1, bpp=1,2,4, or most commonly 8
  gkLONG compression, imageSize;       //compression to zero, size is w*h(8bit)
  gkLONG xpels, ypels, zero3, zero4;   //set to 0,0,0,0
};

int  gkIO::ReadWord(istream &in){
  int retval = in.get() << 8;
  return retval | (in.get() & 0xff);
}

int  gkIO::ReadLong(istream &in){
  int retval = ReadWord(in) << 16;
  return retval | (ReadWord(in) & 0xffff);
}

char *gkIO::ReadString(istream &in){
  static char st[80];
  int len = ReadWord(in);
  if(!len) return 0;
  in.read(st,len);
  st[len] = 0;
  return st;
}

char *gkIO::ReadNewString(istream &in){
  int len = ReadWord(in);
  if(!len) return 0;

  char *st = new char[len+1];
  in.read(st,len);
  st[len] = 0;
  return st;
}

void gkIO::WriteLong(ostream &out, int n){
  WriteWord(out, n>>16);
  WriteWord(out, n);
}

void gkIO::WriteWord(ostream &out, int n){
  out << (char) ((n>>8)&0xff);
  out << (char) (n&0xff);
}

void gkIO::WriteString(ostream &out, char *st){
  WriteWord(out,strlen(st));
  out.write(st,strlen(st));
}


int gkRGB::operator==(gkRGB &c2){
  return ((color.argb & 0xffffff) == (c2.color.argb & 0xffffff));
}

int gkRGB::Equals(int _r, int _g, int _b){
  return _r==color.bytes.r && _g==color.bytes.g && _b==color.bytes.b;
}

int gkRGB::GetCategory(){
  int r = GetR() >> 6;   //rough categories 0-3
  int g = GetG() >> 6;
  int b = GetB() >> 6;

  int highest = r;
  if(g > highest) highest = g;
  if(b > highest) highest = b;

  int hash;

  if(r > g && r > b){         //red high
    if(g < b) hash = 0;         // r > (g < b)
    else if(g==b) hash = 1;     // r > (g = b)
    else hash = 2;              // r > (g > b)
  }else if(g > r && g > b){   //green high
    if(r < b) hash = 3;         // g > (r < b)
    else if(r==b) hash = 4;     // g > (r = b)
    else hash = 5;              // g > (r > b)
  }else if(b > r && b > g){   //blue high
    if(r < g) hash = 6;         // b > (r < g)
    else if(r==g) hash = 7;     // b > (r = g)
    else hash = 8;              // b > (r > g)
  }else if(r==b && b==g){     //r = g = b
    hash = 9;
  }else if(r==b){      //(r = b) > g
    hash = 10;
  }else if(r==g){      //(r = g) > b
    hash = 11;
  }else{               //(g = b) > r
    hash = 12;
  }

  //make room in each category for four levels of intensity (0-3)
  hash = hash*4 + highest;

  return hash;
}

void gkRGB::Combine(gkRGB c2, int alpha){
	//mix alpha
	color.bytes.r += 
		gkWinShape::tranTable.LookupTransparencyOffset(c2.GetR()-GetR(), alpha);
	color.bytes.g += 
		gkWinShape::tranTable.LookupTransparencyOffset(c2.GetG()-GetG(), alpha);
	color.bytes.b += 
		gkWinShape::tranTable.LookupTransparencyOffset(c2.GetB()-GetB(), alpha);
}

gkPalGenItem::gkPalGenItem(gkRGB _color){
  color = _color;
  occurrences = 1;
  nextItem = 0;
}

gkPalGenItem::gkPalGenItem(gkPalGenItem *item){
  color = item->color;
  occurrences = item->occurrences;
  nextItem = 0;
}

gkPalGenItem::~gkPalGenItem(){
}

gkRGB gkPalGenItem::GetColor(){
  return color;
}

void gkPalGenItem::AddOccurrence(){
  occurrences++;
}

int  gkPalGenItem::GetOccurrences(){
  return occurrences;
}

void gkPalGenItem::SetOccurrences(int n){
  occurrences = n;
}

void gkPalGenItem::SetNextItem(gkPalGenItem *item){
  nextItem = item;
}

gkPalGenItem *gkPalGenItem::GetNextItem(){
  return nextItem;
}

int gkPalGenItem::SortCallback(const void *e1, const void *e2){
  gkPalGenItem *i1 = *((gkPalGenItem**) e1);
  gkPalGenItem *i2 = *((gkPalGenItem**) e2);
  if(i1->occurrences > i2->occurrences) return -1;
  if(i1->occurrences == i2->occurrences) return 0;
  return 1;
}

gkColorCategory::gkColorCategory(){
  int i;
  for(i=0; i<64; i++) hashHead[i] = hashTail[i] = 0;
  curHash = 0;
  curItem = 0;
  uniqueCount = 0;
}

gkColorCategory::~gkColorCategory(){
  int i;
  for(i=0; i<64; i++){
    gkPalGenItem *cur, *next;
    for(cur=hashHead[i]; cur; cur=next){
      next = cur->GetNextItem();
      delete cur;
    }
    hashHead[i] = hashTail[i] = 0;
  }
  uniqueCount = 0;
}

gkPalGenItem *gkColorCategory::GetFirstItem(){
  if(!uniqueCount) return 0;
  curHash = -1;
  curItem = 0;
  return GetNextItem();
}

gkPalGenItem *gkColorCategory::GetNextItem(){
  if(curHash>=64) return 0;

  if(!curItem || !curItem->GetNextItem()){
    while(curHash<(64-1)){
      curHash++;
      if(hashHead[curHash]){
	curItem = hashHead[curHash];
	return curItem;
      }
    }
    return 0;
  }

  curItem = curItem->GetNextItem();
  return curItem;
}

gkPalGenItem *gkColorCategory::Exists(gkRGB color){
  int hash = GetHash(color);
  gkPalGenItem *cur;
  for(cur=hashHead[hash]; cur; cur=cur->GetNextItem()){
    if(cur->GetColor() == color) return cur;
  }
  return 0;
}

void gkColorCategory::AddColor(gkRGB color){
  int hash = GetHash(color);
  gkPalGenItem *item = new gkPalGenItem(color);
  uniqueCount++;
  if(!hashHead[hash]){
    hashHead[hash] = hashTail[hash] = item;
  }else{
    gkPalGenItem *prev = hashTail[hash];
    //gkPalGenItem *cur, *prev;
    //for(cur=hashHead[hash]; cur; cur=cur->GetNextItem()){
      //prev = cur;
    //}
    prev->SetNextItem(item);
    hashTail[hash] = item;
  }
}

void gkColorCategory::SetZeroOccurrences(gkRGB color){
  int hash = GetHash(color);
  gkPalGenItem *cur;
  for(cur=hashHead[hash]; cur; cur=cur->GetNextItem()){
    if(cur->GetColor()==color){
      cur->SetOccurrences(0);
      uniqueCount--;
      break;
    }
  }
}

int gkColorCategory::GetHash(gkRGB color){
  //hash is concatenation of lower 2 bits of r, g, and b so that minute color
  //differences will elicit a different hash
  int hash = ((color.GetR() & 3) << 4) | ((color.GetG() & 3) << 2)
    | (color.GetB() & 3);
  return hash;
}

gkRGB gkColorCategory::GetMostFrequent(){
  gkPalGenItem *cur = GetMostFrequentItem();
  if(!cur) return gkRGB(0,0,0);
  return cur->GetColor();
}

gkPalGenItem *gkColorCategory::GetMostFrequentItem(){
  gkPalGenItem *cur, *highest=0;
  int highestCount=0;
  for(cur=GetFirstItem(); cur; cur=GetNextItem()){
    if(cur->GetOccurrences() > highestCount){
      highest = cur;
      highestCount = cur->GetOccurrences();
    }
  }
  return highest;
}

gkPaletteGenerator::gkPaletteGenerator(){
}

gkPaletteGenerator::~gkPaletteGenerator(){
  Reset();
}

void gkPaletteGenerator::Reset(){
}

void gkPaletteGenerator::AddColor(gkRGB color){
  int i = GetHash(color);
  gkPalGenItem *cur;
  if(cur = colorCube[i].Exists(color)){
    cur->AddOccurrence();
  }else{
    //color not in list
    colorCube[i].AddColor(color);
  }
}

int  gkPaletteGenerator::CreatePalette(gkRGB *palette, int numEntries){
  if(numEntries<=0) return 0;

  //Set all entries to black
  int i;
  for(i=0; i<numEntries; i++) palette[i] = gkRGB(0,0,0);

  //1 entry from every this many indices
  double scaleFactor = 512.0 / numEntries;

  int curEntry = 0;

  while(curEntry < numEntries){
    //Get first & last array indices for this section
    int first = (int) (scaleFactor * (curEntry));
    int nextEntry = (int) (scaleFactor * (curEntry+1));
    int last  = nextEntry - 1;
    if(last < first) last = first;

    //Count total # of colors in this section
    int count = 0;
    for(i=first; i<=last; i++){
      count += colorCube[i].GetUniqueCount();
    }
    while(!count){   //if no colors yet expand area of inclusion
      if(first==0 && last==(512-1)) return curEntry;    //no colors anywhere!
      if(first>0){
        first--;
        count += colorCube[first].GetUniqueCount();
      }
      if(last<(512-1)){
        last++;
        count += colorCube[last].GetUniqueCount();
      }
    }

    //Create an array to hold all the colors for sorting purposes
    gkPalGenItem **colors = new gkPalGenItem*[count];
    gkPalGenItem *cur;
    i = 0;
    int j;
    for(j=first; j<=last; j++){
      for(cur=colorCube[j].GetFirstItem(); cur; 
        cur=colorCube[j].GetNextItem()){
        if(cur->GetOccurrences()){
          colors[i++] = cur;
        }
      }
    }
    count = i;   //i may be different from "count" since occurrences is set
                 //to zero after a color is selected

    //figure out how many colors will come from this section of the cube
    int numToGrab = 1;
    int tempCurEntry = curEntry;
    while(nextEntry==first && tempCurEntry<(512-1)){
      tempCurEntry++;
      nextEntry = (int) (scaleFactor * (tempCurEntry+1));
      numToGrab++;
    }

    //sort colors into descending order and pick "num" most frequent
    qsort(colors, count, sizeof(gkPalGenItem*), gkPalGenItem::SortCallback);

    for(i=0; i<numToGrab; i++){
      palette[curEntry] = colors[i]->GetColor();
      curEntry++;
      colorCube[GetHash(colors[i]->GetColor())].SetZeroOccurrences(
	  colors[i]->GetColor());
    }

    //delete sorting table
    delete colors;
  }
  return numEntries;
}

int  gkPaletteGenerator::GetHash(gkRGB color){
  int r = color.GetR() >> 5;   //rough categories 0-3
  int g = color.GetG() >> 5;
  int b = color.GetB() >> 5;
  return (r<<6) | (g<<3) | b;

  /*
  int highest = r;
  if(g > highest) highest = g;
  if(b > highest) highest = b;

  int hash;

  // r > (g < b)
  // r > (g = b)
  // r > (g > b)
  // g > (r < b)
  // g > (r = b)
  // g > (r > b)
  // b > (r < g)
  // b > (r = g)
  // b > (r > g)
  // (r = b) > g
  // (r = g) > b
  // (g = b) > r
  // (r = g) = b
  if(r > g && r > b){         //red high
    if(g < b) hash = 0;         // r > (g < b)
    else if(g==b) hash = 1;     // r > (g = b)
    else hash = 2;              // r > (g > b)
  }else if(g > r && g > b){   //green high
    if(r < b) hash = 3;         // g > (r < b)
    else if(r==b) hash = 4;     // g > (r = b)
    else hash = 5;              // g > (r > b)
  }else if(b > r && b > g){   //blue high
    if(r < g) hash = 6;         // b > (r < g)
    else if(r==g) hash = 7;     // b > (r = g)
    else hash = 8;              // b > (r > g)
  }else if(r==b && b==g){     //r = g = b
    hash = 9;
  }else if(r==b){      //(r = b) > g
    hash = 10;
  }else if(r==g){      //(r = g) > b
    hash = 11;
  }else{               //(g = b) > r
    hash = 12;
  }

  //make room in each category for four levels of intensity (0-3)
  hash = hash*4 + highest;

  return hash;
  */
}

gkRGB gkPaletteGenerator::MatchColor(gkRGB color){
  int hash = GetHash(color);
  int r = color.GetR();
  int g = color.GetG();
  int b = color.GetB();
  if(colorCube[hash].GetFirstItem()){  //near colors; search just this section
    gkPalGenItem *cur, *bestMatch;
    int bestDiff;
    bestMatch = colorCube[hash].GetFirstItem();
    int r2, g2, b2;
    r2 = abs(r - bestMatch->GetColor().GetR());
    g2 = abs(g - bestMatch->GetColor().GetG());
    b2 = abs(b - bestMatch->GetColor().GetB());
    bestDiff = r2*r2 + g2*g2 + b2*b2;
    for(cur=colorCube[hash].GetNextItem(); cur; cur=colorCube[hash].GetNextItem()){
      r2 = abs(r - cur->GetColor().GetR());
      g2 = abs(g - cur->GetColor().GetG());
      b2 = abs(b - cur->GetColor().GetB());
      int curDiff = r2*r2 + g2*g2 + b2*b2;
      if(curDiff < bestDiff){
	bestDiff = curDiff;
	bestMatch = cur;
	if(!curDiff) return bestMatch->GetColor();
      }
    }
    return bestMatch->GetColor();
  }else{
    //no colors nearby; expand search
    //Get it from ~greyscale if possible
    int first, last;
    //first = last = 36 + (hash % 4);
    //if(!colorCube[first].GetFirstItem()){
      first = 0;    //nothing there either; search everything
      last = (512-1);
      /*
      first = 36;
      last = 39;
      //first = hash - (hash%4);    //different intensities, same color
      //last = first + 3;
      if(!colorCube[first] && !colorCube[first+1] && !colorCube[first+2]
	  && !colorCube[last]){
	first = 0;    //nothing there either; search everything
	last = 51;
      }
      */
    //}
    gkPalGenItem *cur, *bestMatch;
    int bestDiff = 0x7fffffff;
    bestMatch = 0;
    int i;
    for(i=first; i<=last; i++){
      for(cur=colorCube[i].GetFirstItem(); cur; 
	  cur=colorCube[i].GetNextItem()){
	int r2 = abs(r - cur->GetColor().GetR());
	int g2 = abs(g - cur->GetColor().GetG());
	int b2 = abs(b - cur->GetColor().GetB());
	int curDiff = r2*r2 + g2*g2 + b2*b2;
	if(curDiff < bestDiff){
	  bestDiff = curDiff;
	  bestMatch = cur;
	  if(!curDiff) return bestMatch->GetColor();
	}
      }
    }
    if(!bestMatch) return gkRGB(0,0,0);
    return bestMatch->GetColor();
  }
}

gkRGB gkPaletteGenerator::GetMostFrequent(){
  int i, highestCount=0;
  gkRGB  highestColor;
  for(i=0; i<512; i++){
    gkPalGenItem *cur;
    for(cur=colorCube[i].GetFirstItem(); cur; cur=colorCube[i].GetNextItem()){
      int count = cur->GetOccurrences();
      if(count > highestCount){
	highestCount = count;
	highestColor = cur->GetColor();
      }
    }
  }
  return highestColor;
}

int   gkPaletteGenerator::NumUniqueColors(){
  int totalUnique = 0;
  int i;
  for(i=0; i<512; i++){
    totalUnique += colorCube[i].GetUniqueCount();
  }
  return totalUnique;
}

gkColorCategory *gkPaletteGenerator::GetCategory(int hash){
  return &colorCube[hash];
}

gkTransparencyTable::gkTransparencyTable(){
  lookup = new gkBYTE[256*256];

  int baseOffset, alpha, i;
  i = 0;
  for(baseOffset=0; baseOffset<256; baseOffset++){
    for(alpha=0; alpha<256; alpha++){
      lookup[i++] = (baseOffset * alpha) / 255;
    }
  }
}

gkTransparencyTable::~gkTransparencyTable(){
  if(lookup) delete lookup;
  lookup = 0;
}

int gkTransparencyTable::LookupTransparencyOffset(int baseOffset, int alpha){
  return (baseOffset>=0) ? lookup[(baseOffset<<8)+alpha] 
    : (-lookup[((-baseOffset)<<8)+alpha]);
}


gkWinShape::gkWinShape(){
  data = 0;
  width = height = bpp = 0;
  x_origin = y_origin = x_handle = y_handle = 0;
}

gkWinShape::~gkWinShape(){
  FreeData();
}

void  gkWinShape::FreeData(){
  if(data){
    delete data;
    data = 0;
  }
}

void  gkWinShape::Create(int _width, int _height){
  if(_width <= 0 || _height <= 0) return;
  
  FreeData();
  width = _width;
  height = _height;

  //round up width to ensure multiple of 4 pixels
  width = (width + 3) & (~3);

  data = new gkBYTE[(width*height)<<2];
  bpp = 32;
}

void  gkWinShape::Cls(){
  if(!this->data) return;
  memset(this->data, 0, (this->width * this->height)<<2);
}

void  gkWinShape::Cls(gkRGB color){
  if(!this->data) return;

  gkLONG *dest = (gkLONG*) this->data;
  int i = this->width * this->height;
  while(i--){
    *(dest++) = color.GetARGB();
  }
}

void  gkWinShape::Plot(int x, int y, gkRGB color, int testBoundaries){
  if(!data) return;
  if(testBoundaries){
    if(x<0 || x>=width || y<0 || y>=height) return;
  }

  gkRGB *dest = (gkRGB*) (data + ((((height - (y+1)) * width) + x) <<2));
  *dest = color;
}

gkRGB gkWinShape::Point(int x, int y, int testBoundaries){
  if(!data) return gkRGB(0,0,0);
  if(testBoundaries){
    if(x<0 || x>=width || y<0 || y>=height) return gkRGB(0,0,0);
  }

  gkRGB *color = (gkRGB*) (data + ((((height - (y+1)) * width) + x) <<2));
  return *color;
}

void  gkWinShape::Line(int x1, int y1, int x2, int y2, gkRGB color){
	int temp;
	if(y1==y2){         //straight horizontal line
		if(x2 < x1) RectFill(x2,y1,(x1-x2)+1,1,color);
		else        RectFill(x1,y1,(x2-x1)+1,1,color);
		return;
	}else if(x1==x2){   //straight vertical line
		if(y2 < y1) RectFill(x1,y2,1,(y1-y2)+1,color);
		else        RectFill(x1,y1,1,(y2-y1)+1,color);
		return;
	}


	//clip line to screen
	if(y2 < y1){                         //orient line to be drawn from top to 
		temp = x1;  x1 = x2;  x2 = temp;   //bottom for initial clipping tests
		temp = y1;  y1 = y2;  y2 = temp;
	}
	if(y2 < 0 || y1 >= height) return;

	double xdiff = x2-x1, ydiff = y2-y1;
	double slopexy = xdiff / ydiff;
	int diff;

	//perform vertical clipping
	diff = 0 - y1;
	if(diff > 0){    //y1 is above top boundary
		x1 += (int) (slopexy * diff);
		y1 = 0;
	}
	diff = (y2 - height) + 1;
	if(diff > 0){    //y2 is below bottom boundary
		x2 -= (int) (slopexy * diff);
		y2 = height - 1;
	}

	//reorient line to be drawn from left to right for horizontal clipping tests
	if(x2 < x1){
		temp = x1;  x1 = x2;  x2 = temp;
		temp = y1;  y1 = y2;  y2 = temp;
		xdiff = x2-x1;
		ydiff = y2-y1;
	}
	double slopeyx = ydiff / xdiff;

	if(x2 < 0 || x1 >= width) return;

	diff = 0 - x1;
	if(diff > 0){    //x1 is to left of left boundary
		y1 += (int) (slopeyx * diff);
		x1 = 0;
	}
	diff = (x2 - width) + 1;
	if(diff > 0){    //x2 is to right of right boundary
		y2 -= (int) (slopeyx * diff);
		x2 = width - 1;
	}

	//draw the line using Bresenham's
	//coordinates are now such that x increment is always positive
	int xdist = x2-x1;
	int ydist = y2-y1;
	int pitch = width;
  gkRGB *dest = (gkRGB*) (data + ((((height - (y1+1)) * width) + x1) <<2));
	if(ydist < 0){
		ydist = -ydist;
		pitch = -pitch;
	}

  int err, i;
	if(xdist >= ydist){   //loop on x, change y every so often
		err = 0;
		for(i=xdist; i>=0; i--){
			*(dest++) = color;
			err += ydist;
			if(err >= xdist){
				err -= xdist;
				dest -= pitch;
			}
		}
	}else{                //loop on y, change x every so often
		err = 0;
		for(i=ydist; i>=0; i--){
			*dest = color;
			dest -= pitch;
			err += xdist;
			if(err >= ydist){
				err -= ydist;
				dest++;
			}
		}
	}
}

void  gkWinShape::LineAlpha(int x1, int y1, int x2, int y2, gkRGB color, 
		int alpha){
	int temp;
	if(y1==y2){         //straight horizontal line
		if(x2 < x1) RectFill(x2,y1,(x1-x2)+1,1,color);
		else        RectFill(x1,y1,(x2-x1)+1,1,color);
		return;
	}else if(x1==x2){   //straight vertical line
		if(y2 < y1) RectFill(x1,y2,1,(y1-y2)+1,color);
		else        RectFill(x1,y1,1,(y2-y1)+1,color);
		return;
	}


	//clip line to screen
	if(y2 < y1){                         //orient line to be drawn from top to 
		temp = x1;  x1 = x2;  x2 = temp;   //bottom for initial clipping tests
		temp = y1;  y1 = y2;  y2 = temp;
	}
	if(y2 < 0 || y1 >= height) return;

	double xdiff = x2-x1, ydiff = y2-y1;
	double slopexy = xdiff / ydiff;
	int diff;

	//perform vertical clipping
	diff = 0 - y1;
	if(diff > 0){    //y1 is above top boundary
		x1 += (int) (slopexy * diff);
		y1 = 0;
	}
	diff = (y2 - height) + 1;
	if(diff > 0){    //y2 is below bottom boundary
		x2 -= (int) (slopexy * diff);
		y2 = height - 1;
	}

	//reorient line to be drawn from left to right for horizontal clipping tests
	if(x2 < x1){
		temp = x1;  x1 = x2;  x2 = temp;
		temp = y1;  y1 = y2;  y2 = temp;
		xdiff = x2-x1;
		ydiff = y2-y1;
	}
	double slopeyx = ydiff / xdiff;

	if(x2 < 0 || x1 >= width) return;

	diff = 0 - x1;
	if(diff > 0){    //x1 is to left of left boundary
		y1 += (int) (slopeyx * diff);
		x1 = 0;
	}
	diff = (x2 - width) + 1;
	if(diff > 0){    //x2 is to right of right boundary
		y2 -= (int) (slopeyx * diff);
		x2 = width - 1;
	}

	//draw the line using Bresenham's
	//coordinates are now such that x increment is always positive
	int xdist = x2-x1;
	int ydist = y2-y1;
	int pitch = width;
  gkRGB *dest = (gkRGB*) (data + ((((height - (y1+1)) * width) + x1) <<2));
	if(ydist < 0){
		ydist = -ydist;
		pitch = -pitch;
	}

  int err, i;
	if(xdist >= ydist){   //loop on x, change y every so often
		err = 0;
		for(i=xdist; i>=0; i--){
			dest->Combine(color,alpha);
			dest++;
			err += ydist;
			if(err >= xdist){
				err -= xdist;
				dest -= pitch;
			}
		}
	}else{                //loop on y, change x every so often
		err = 0;
		for(i=ydist; i>=0; i--){
			dest->Combine(color,alpha);
			dest -= pitch;
			err += xdist;
			if(err >= ydist){
				err -= ydist;
				dest++;
			}
		}
	}
}


void  gkWinShape::RectFill(int x, int y, int w, int h, gkRGB color){
	int x2 = (x + w) - 1;
	int y2 = (y + h) - 1;

	//Clip rectangle
	if(x < 0) x = 0;
	if(y < 0) y = 0;

	if(x2 >= width) x2 = width - 1;
	if(y2 >= height) y2 = height - 1;

	if(x2 < x || y2 < y) return;

  //Set pointers and offsets
  gkRGB *destStart = (gkRGB*) (data + ((((height - (y+1)) * width) + x) <<2));
	gkRGB *dest;
	int numRows = (y2 - y) + 1;
	int rowWidth = (x2 - x) + 1;

	//do it
	while(numRows--){
		dest = destStart;

		int i;
		for(i=0; i<rowWidth; i++){
			*(dest++) = color;
		}
		destStart -= width;
	}
}

void  gkWinShape::RectFillAlpha(int x, int y, int w, int h, gkRGB color,
		int alpha){
	int x2 = (x + w) - 1;
	int y2 = (y + h) - 1;

	//Clip rectangle
	if(x < 0) x = 0;
	if(y < 0) y = 0;

	if(x2 >= width) x2 = width - 1;
	if(y2 >= height) y2 = height - 1;

	if(x2 < x || y2 < y) return;

  //Set pointers and offsets
  gkRGB *destStart = (gkRGB*) (data + ((((height - (y+1)) * width) + x) <<2));
	gkRGB *dest;
	int numRows = (y2 - y) + 1;
	int rowWidth = (x2 - x) + 1;

	//do it
	while(numRows--){
		dest = destStart;

		int i;
		for(i=0; i<rowWidth; i++){
			dest->Combine(color,alpha);
			dest++;
		}
		destStart -= width;
	}
}


void  gkWinShape::RemapColor(gkRGB oldColor, gkRGB newColor){
  if(!data) return;

  gkRGB *src = (gkRGB*) data;
  int i, j;
  for(j=0; j<height; j++){
    for(i=0; i<width; i++){
      if(oldColor == (*src)){
	*src = newColor;
      }
      src++;
    }
  }
}

void  gkWinShape::RemapToPalette(gkRGB *palette, int numColors){
  //add palette colors to generator for matching purposes
  gkPaletteGenerator generator;
  int i = numColors;
  gkRGB *src = palette;
  while(i--){
    generator.AddColor(*(src++));
  }

  //find color in palette that best matches each pixel
  i = width * height;
  src = (gkRGB*) data;
  while(i--){
    *src = generator.MatchColor(*src);
    src++;
  }
}

int   gkWinShape::ReduceColors(int numColors){
  gkPaletteGenerator generator;
  int i = width * height;
  gkRGB *src = (gkRGB*) data;
  while(i--){
    generator.AddColor(*(src++));
  }

  gkRGB *palette = new gkRGB[numColors];
  int palColors = generator.CreatePalette(palette, numColors);
  RemapToPalette(palette, numColors);
  delete palette;
  return palColors;
}

gkGBCShape *g_sixth;
void  gkWinShape::RemapToGBC(gkRGB *palettes, 
    int numPalettes, int colorsPerPalette){
  //Reduce total colors in this shape
  int totalColors = numPalettes * colorsPerPalette;
  totalColors = ReduceColors(totalColors);
  
  //Break up this picture into a set of 8x8 tiles
  int tilesWide = (width+7) / 8;
  int tilesHigh = (height+7) / 8;
  int numTiles = tilesWide * tilesHigh;
  if(!numTiles) return;

  gkGBCShape **tiles = new gkGBCShape*[numTiles];
  char *marked = new char[numTiles];
  int i,j;
  numTiles = 0;
  for(j=0; j<tilesHigh; j++){
    for(i=0; i<tilesWide; i++){
      tiles[numTiles] = new gkGBCShape();
      tiles[numTiles]->GetShape(this, (i<<3), (j<<3), 8, 8);
      tiles[numTiles]->ReduceTo4Colors();
if(numTiles==5) g_sixth = tiles[numTiles];
      numTiles++;
    }
  }

  int numTilePalettes = numTiles;
  gkGBCPalette **tilePalettes = new gkGBCPalette*[numTilePalettes];
  for(i=0; i<numTilePalettes; i++){
    tilePalettes[i] = new gkGBCPalette(tiles[i]->GetPalette(),
	tiles[i]->GetColorsUsed());
    tiles[i]->SetCurPalette(tilePalettes[i]);
  }

  //Sort into "most frequent first"
  //qsort(tilePalettes, numTilePalettes, sizeof(gkGBCPalette*), 
    //gkGBCPalette::SortByReferences);


  //Attempt to merge each palette with any of the previous ones in the list
  for(i=0; i<numTilePalettes; i++){
    int k;
    for(j=0; j<i; j++){
      if(tilePalettes[i]->CanUnionWith(tilePalettes[j], colorsPerPalette)){
	tilePalettes[i]->MakeUnionWith(tilePalettes[j]);
	for(k=0; k<numTiles; k++){
	  if(tiles[k]->GetCurPalette()==tilePalettes[i]){
	    tiles[k]->SetCurPalette(tilePalettes[j]);
	  }
	}
	delete tilePalettes[i];
	tilePalettes[i] = tilePalettes[--numTilePalettes];
	i--;  //try new occupant of this index next loop
	break;
      }
    }
  }

  while(numTilePalettes > 8){
    //okay now re-sort, get rid of the least-used palette, and pick one
    //of the remaining palettes for its tiles
    qsort(tilePalettes, numTilePalettes, sizeof(gkGBCPalette*), 
          gkGBCPalette::SortByReferences);

    numTilePalettes--;  //numTilePalettes is now index of disappearing palette
    for(int t=0; t<numTiles; t++){
      if(tiles[t]->GetCurPalette() != tilePalettes[numTilePalettes]) continue;
      int bestMatch = 0;
      int smallestDifference = 0x7fffffff;
      for(i=0; i<numTilePalettes; i++){
	int diff = tiles[t]->MatchPalette(tilePalettes[i]->GetPalette(), 
	    tilePalettes[i]->GetColorsUsed());
	if(diff<smallestDifference){
	  smallestDifference = diff;
	  bestMatch = i;
	}
      }
      tilePalettes[bestMatch]->SetNumReferences(
	  tilePalettes[bestMatch]->GetNumReferences() + 1);
      tiles[t]->SetCurPalette(tilePalettes[bestMatch]);
    }

    delete tilePalettes[numTilePalettes];
  }

  //Remap tiles to the palettes they've chosen
  for(i=0; i<numTiles; i++){
    //for(j=0; j<numTilePalettes; j++){
      //if(tilePalettes[j]==tiles[i]->GetCurPalette())
      tiles[i]->Finalize(j);
    //}
  }


  ofstream outfile("gbpic.bin",ios::out|ios::binary);
  if(!outfile) return;

  int totalTiles = (width>>3) * (height>>3);
  if(totalTiles > 512) totalTiles = 512;

  int numBank0Tiles, numBank1Tiles;

  if(totalTiles > 256){
    numBank0Tiles = 256;
    numBank1Tiles = totalTiles - 256;
  }else{
    numBank0Tiles = totalTiles;
    numBank1Tiles = 0;
  }

  outfile.put((char)(numBank0Tiles>0));
  if(numBank0Tiles){
    outfile.put((char)numBank0Tiles);
    for(i=0; i<numBank0Tiles; i++){
      gkGBCShape *tile = tiles[i];
      gkRGB *pal = tile->GetCurPalette()->GetPalette();
      int cbyte1, cbyte2;
      for(int row=0; row<8; row++){
	for(int col=0; col<8; col++){
	  gkRGB pixel = tile->Point(col,row);
	  int j;
	  for(j=0; j<4; j++) if(pal[j]==pixel) break;
	  cbyte1 = (cbyte1<<1) | (j&1);
	  cbyte2 = (cbyte2<<1) | ((j>>1)&1);
	}
	outfile.put((char)cbyte1);
	outfile.put((char)cbyte2);
      }
    }
  }

  outfile.put((char)(numBank1Tiles>0));
  if(numBank1Tiles){
    outfile.put((char)numBank1Tiles);
    for(i=0; i<numBank1Tiles; i++){
      gkGBCShape *tile = tiles[i+numBank0Tiles];
      gkRGB *pal = tile->GetCurPalette()->GetPalette();
      int cbyte1, cbyte2;
      for(int row=0; row<8; row++){
	for(int col=0; col<8; col++){
	  gkRGB pixel = tile->Point(col,row);
	  for(j=0; j<4; j++) if(pal[j]==pixel) break;
	  cbyte1 = (cbyte1<<1) | (j&1);
	  cbyte2 = (cbyte2<<1) | ((j>>1)&1);
	}
	outfile.put((char)cbyte1);
	outfile.put((char)cbyte2);
      }
    }
  }


  outfile.put((char)tilesWide);
  outfile.put((char)tilesHigh);

  for(j=0; j<tilesHigh; j++){
    for(i=0; i<tilesWide; i++){
      outfile.put((char)(j*tilesWide+i));
    }
  }

  for(j=0; j<tilesHigh; j++){
    for(i=0; i<tilesWide; i+=2){
      gkGBCPalette *pal = tiles[j*tilesWide+i]->GetCurPalette();
      int p;
      for(p=0; p<numTilePalettes; p++) if(tilePalettes[p]==pal) break;
      p &= 7;
      int spec1 = p;

      pal = tiles[j*tilesWide+i+1]->GetCurPalette();
      for(p=0; p<numTilePalettes; p++) if(tilePalettes[p]==pal) break;
      p &= 7;
      int spec2 = p;

      if(j*tilesWide+i > 255) spec1 |= 8;
      if(j*tilesWide+i+1 > 255) spec2 |= 8;

      outfile.put((char)((spec1<<4) | spec2));
    }
  }

  //write color palettes
  for(j=0; j<8; j++){
    gkGBCPalette *gbpal = tilePalettes[j];
    gkRGB *pal = gbpal->GetPalette();
    for(i=0; i<4; i++){
      int sel = (j<<3) | (i<<1);
      int p1 = ((pal[i].GetB()>>3)<<10) | ((pal[i].GetG()>>3)<<5)
	 | (pal[i].GetR()>>3);
      int p2 = p1>>8;
      p1 &= 0xff;
      outfile.put((char)sel);
      outfile.put((char)p1);
      outfile.put((char)p2);
    }
  }

  outfile.close();

  for(i=0; i<numTilePalettes; i++){
    delete tilePalettes[i];
  }
  delete tilePalettes;

  //Blit tiles back to their parent shape
  for(i=0; i<numTiles; i++) tiles[i]->Blit(this);

  //clean up
  for(i=0; i<numTiles; i++){
    if(tiles[i]) delete tiles[i];
  }

  delete tiles;
  delete marked;
}

void  gkWinShape::ExchangeColors(gkRGB c1, gkRGB c2){
  if(!data) return;

  gkRGB *src = (gkRGB*) data;
  int i, j;
  for(j=0; j<height; j++){
    for(i=0; i<width; i++){
      if(c1 == (*src)){
	*src = c2;
      }else if(c2 == (*src)){
	*src = c1;
      }
      src++;
    }
  }
}

void  gkWinShape::SetAlpha(int alpha){
  if(!data) return;

  gkRGB *src = (gkRGB*) data;
  int i = (width * height);
  while(i--){
    (src++)->SetA(alpha);
  }
}

void  gkWinShape::SetColorAlpha(gkRGB color, int alpha){
  if(!data) return;

  gkRGB *src = (gkRGB*) data;
  int i, j;
  for(j=0; j<height; j++){
    for(i=0; i<width; i++){
      if(color == (*src)){
	src->SetA(alpha);
      }
      src++;
    }
  }
}

int  gkWinShape::GetShape(gkWinShape *srcShape, int x, int y, int w, int h){
  if(!srcShape || !srcShape->data) return 0;

  //adjust src rectangle until it fits within source data
  if(x<0){
    w += x;
    x = 0;
  }
  if(y<0){
    h += y;
    y = 0;
  }
  if(x + w > srcShape->width){
    w = srcShape->width - x;
  }
  if(y + h > srcShape->height){
    h = srcShape->height - y;
  }

  if(w<=0 || h<=0) return 0;

  FreeData();
  Create(w, h);
  x_origin = x;
  y_origin = y;

  gkBYTE *src = (gkBYTE*) ((((srcShape->height-1) - y) * srcShape->width) + x);
  src = srcShape->data + ((int)src <<2);
  gkBYTE *dest = this->data + (((h-1) * w) << 2);
  int srcSkip = srcShape->width << 2;
  w <<= 2;

  while(h--){
    memcpy(dest, src, w);
    dest -= w;
    src  -= srcSkip;
  }

  return 1;
}

int   gkWinShape::GetShape(gkWinShape *srcShape){
  if(this->width != srcShape->width || this->height != srcShape->height
      || (!this->data) || (!srcShape->data)){
    //mem needs to be reallocated
    FreeData();
    memcpy(this, srcShape, sizeof(gkWinShape));
    data = 0;
    if(srcShape->data){
      data = new gkBYTE[(width * height) << 2];
      memcpy(data, srcShape->data, (width * height) << 2 );
    }
  }else{
    //already got right size mem, just copy data over
    memcpy(data, srcShape->data, (width * height) << 2);
    fontSpacing = srcShape->fontSpacing;
    fontKerning = srcShape->fontKerning;
    x_handle = srcShape->x_handle;
    y_handle = srcShape->y_handle;
    x_origin = srcShape->x_origin;
    y_origin = srcShape->y_origin;
  }
  return data!=0;
}

int   gkWinShape::SaveShape(char *filename){
  ofstream outfile(filename, ios::out | ios::binary);
  if(!outfile) return 0;

  int result = SaveShape(outfile);
  outfile.close();

  return result;
}

int   gkWinShape::SaveShape(ostream &out){
  int totalSize = ((width * height) << 2);

  out << "SHPE";
  int skipSize = totalSize + 20;
  gkIO::WriteLong(out, skipSize);

  //Write shape header
  gkIO::WriteWord(out, 3);          //type 3
  gkIO::WriteWord(out, width);
  gkIO::WriteWord(out, height);
  gkIO::WriteWord(out, (bpp==8)?8:32);
  out << (char) fontSpacing << (char) fontKerning;
  gkIO::WriteWord(out, x_handle);
  gkIO::WriteWord(out, y_handle);
  gkIO::WriteWord(out, 0);   //6 bytes of reserved space
  gkIO::WriteLong(out, 0);   


  //Write data
  if(data){
    int pitch = width << 2;
    gkLONG *src;
    gkBYTE *srcStart=(gkBYTE*) ((height-1) * pitch);

    int i,j;
    for(j=0; j<height; j++){
      src = (gkLONG*) srcStart;
      for(i=0; i<width; i++){
	gkIO::WriteLong(out, *(src++));
      }
      srcStart -= pitch;
    }
  }

  return 1;
}

int   gkWinShape::LoadShape(char *filename){
  ifstream infile(filename,ios::in | ios::binary | ios::nocreate);
  if(!infile) return 0;

  int result = this->LoadShape(infile);
  infile.close();

  return result;
}

int   gkWinShape::LoadShape(istream &infile){
  FreeData();
  if(infile.get() != 'S') return 0;
  if(infile.get() != 'H') return 0;
  if(infile.get() != 'P') return 0;
  if(infile.get() != 'E') return 0;

  gkIO::ReadLong(infile);   //discard skipsize

  //Read shape header
  if(gkIO::ReadWord(infile) != 2) return 0;
  width  = gkIO::ReadWord(infile);
  height = gkIO::ReadWord(infile);
  int filebpp = gkIO::ReadWord(infile);
  if(!bpp) bpp = filebpp;

  if(width && height){
    Create(width,height);
  }

  fontSpacing = infile.get();
  fontKerning = infile.get();
  x_handle = gkIO::ReadWord(infile);
  y_handle = gkIO::ReadWord(infile);

  gkIO::ReadWord(infile);
  gkIO::ReadLong(infile);   //discard reserved space

  if(!width || !height) return 1;  //nothing to load, null shape

  int pitch = width << 2;
  gkBYTE *destStart = data + (height-1) * pitch;
  gkLONG *dest;
  int x,y;
  for(y=0; y<height; y++){
    dest = (gkLONG*) destStart;
    for(x=0; x<width; x++){
      *(dest++) = gkIO::ReadLong(infile);
      //dest->SetA(infile.get());
      //dest->SetR(infile.get());
      //dest->SetG(infile.get());
      //dest->SetB(infile.get());
      //dest++;
    }
    destStart -= pitch;
  }

  return 1;
}

int   gkWinShape::LoadBMP(char *filename){
  ifstream infile(filename,ios::in | ios::binary | ios::nocreate);
  if(!infile) return 0;

  int result = this->LoadBMP(infile);
  infile.close();

  return result;
}

int   gkWinShape::LoadBMP(istream &infile){
  BMP_header header;
  if(gkIO::ReadWord(infile)!=0x424d){  //check for "BM"
    return 0;
  }
  infile.read((char*)&header, sizeof(BMP_header));
  if(header.bpp != 24){
    cout << "LoadBMP can only handle 24-bit files" << endl;
    return 0;
  }

  FreeData();
  width = header.width;
  height = header.height;
  bpp = (char) header.bpp;
  Create(width,height);

  // load graphics, coverting every three (B,R,G) bytes to one ARGB value.
  // lines padded to even multiple of 4 bytes
  int srcPitch = ((header.width * 3) + 3) & (~3);
  gkBYTE *buffer = new gkBYTE[srcPitch * height];
  gkBYTE *nextBuffPtr = buffer;
  gkBYTE *buffPtr;

  infile.read(buffer, srcPitch * height);

  gkBYTE *nextDest = data;
  gkRGB *dest;
  int destPitch = (width << 2);
  
  int i, j;
  j = height;
  while(j--){
    buffPtr = nextBuffPtr;
    nextBuffPtr += srcPitch;
    dest = (gkRGB*) nextDest;
    nextDest += destPitch;
    i = header.width;
    while(i--){
      dest->SetB(*(buffPtr++));
      dest->SetG(*(buffPtr++));
      dest->SetR(*(buffPtr++));
      dest->SetA(0xff);
      dest++;
    }
    for(i=header.width; i<width; i++){
      dest->SetARGB(0);
      dest++;
    }
  }

  delete buffer;

  return 1;
}


void gkWinShape::Blit(gkWinShape *destShape, int flags){
  Blit(destShape, x_origin, y_origin, flags);
}

void  gkWinShape::Blit(gkWinShape *destShape, int x, int y, int flags){
  if(!data || !destShape || !destShape->data) return;

  //keep in mind that we're dealing with info organized in the screwy
  //BMP bottom-to-top, left-to-right format

  gkBYTE *src  = (gkBYTE*) ((this->height - 1) * this->width);
  int srcWidth = this->width;
  int srcSkip  = this->width;
  int lines    = this->height;

  //clip left side
  if(x < 0){
    src += -x;
    srcWidth -= -x;
    x = 0;
  }

  //clip right side
  int diff = (x + srcWidth) - destShape->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   -= (-y * this->width);
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destShape->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destShape->width;

  gkBYTE *dest = 
    (gkBYTE*) ((((destShape->height-1) - y) * destShape->width) + x);
  src  = this->data + ((int)src << 2);
  dest = destShape->data + ((int)dest << 2);
  srcWidth <<= 2;
  srcSkip  <<= 2;
  destSkip <<= 2;

  if(flags & GKBLT_TRANSPARENT){
    //blit using alpha 0 as fully transparent
    while(lines--){
      MemCpyTrans(dest, src, srcWidth);
      src  -= srcSkip;
      dest -= destSkip;
    }
  }else{
    //blit without a transparent color
    while(lines--){
      memcpy(dest, src, srcWidth);
      src  -= srcSkip;
      dest -= destSkip;
    }
  }
}

void  gkWinShape::BlitHalfBrite(gkWinShape *destShape, int x, int y, 
		int flags){
  if(!data || !destShape || !destShape->data) return;

  //keep in mind that we're dealing with info organized in the screwy
  //BMP bottom-to-top, left-to-right format

  gkBYTE *src  = (gkBYTE*) ((this->height - 1) * this->width);
  int srcWidth = this->width;
  int srcSkip  = this->width;
  int lines    = this->height;

  //clip left side
  if(x < 0){
    src += -x;
    srcWidth -= -x;
    x = 0;
  }

  //clip right side
  int diff = (x + srcWidth) - destShape->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   -= (-y * this->width);
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destShape->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destShape->width;

  gkBYTE *dest = 
    (gkBYTE*) ((((destShape->height-1) - y) * destShape->width) + x);
  src  = this->data + ((int)src << 2);
  dest = destShape->data + ((int)dest << 2);
  srcWidth <<= 2;
  srcSkip  <<= 2;
  destSkip <<= 2;

  if(flags & GKBLT_TRANSPARENT){
    //blit using alpha 0 as fully transparent
    while(lines--){
      MemCpyTransHalfBrite(dest, src, srcWidth);
      src  -= srcSkip;
      dest -= destSkip;
    }
  }else{
    //blit without a transparent color
    while(lines--){
      MemCpyHalfBrite(dest, src, srcWidth);
      src  -= srcSkip;
      dest -= destSkip;
    }
  }
}

void  gkWinShape::BlitToDC(CDC *pDC, int x, int y){
  //static BITMAPINFOHEADER bmHeader={40, 0, 0, 1, 32, 0, 0, 0, 0, 0, 0};
  static BITMAPINFO bmInfo={{40, 0, 0, 1, 32, 0, 0, 0, 0, 0, 0}};
  static CDC srcDC;
  static int setup=0;

  if(!setup){
    setup = 1;

    //HDC hdc = CreateDC("DISPLAY",0,0,0);
    //srcDC.Attach(hdc);
    srcDC.CreateCompatibleDC(0);
    *((int*)(&bmInfo.bmiColors[0])) = 0xff0000;  //red mask
    *((int*)(&bmInfo.bmiColors[4])) = 0x00ff00;  //green mask
    *((int*)(&bmInfo.bmiColors[8])) = 0x0000ff;  //blue mask
  }

  bmInfo.bmiHeader.biWidth  = width;
  bmInfo.bmiHeader.biHeight = height;

  HBITMAP dib = CreateDIBitmap((HDC) (*pDC),
      &bmInfo.bmiHeader, 
      CBM_INIT,
      data,
      &bmInfo,
      DIB_RGB_COLORS);

  CBitmap bitmap;
  bitmap.Attach(dib);

  CBitmap *oldBitmap = srcDC.SelectObject(&bitmap);
  pDC->BitBlt(x, y, width, height, &srcDC, 0, 0, SRCCOPY);
  srcDC.SelectObject(oldBitmap);

  bitmap.Detach();
  DeleteObject(dib);
}

void gkWinShape::MemCpyTrans(gkBYTE *dest, gkBYTE *src, 
		int numBytes){
	//copies colors using the Alpha for transparency
	gkRGB *destColor = (gkRGB*) dest;
	gkRGB *srcColor  = (gkRGB*) src;
	int numColors = numBytes >> 2;
	int c1;
	while(numColors--){
		int alpha;
		switch(alpha = (srcColor->GetA())){
			case 0:   break;
			case 255: //Straight copy
								*destColor = *srcColor;
								break;
			default:  //mix alpha
								c1 = destColor->GetR();
								c1 += tranTable.LookupTransparencyOffset(srcColor->GetR()-c1, alpha);
								destColor->SetR(c1);
								c1 = destColor->GetG();
								c1 += tranTable.LookupTransparencyOffset(srcColor->GetG()-c1, alpha);
								destColor->SetG(c1);
								c1 = destColor->GetB();
								c1 += tranTable.LookupTransparencyOffset(srcColor->GetB()-c1, alpha);
								destColor->SetB(c1);
								break;
		}
		srcColor++;
		destColor++;
	}
}

void gkWinShape::MemCpyTransHalfBrite(gkBYTE *dest, gkBYTE *src, 
		int numBytes){
	//copies colors using the Alpha for transparency
	gkRGB *destColor = (gkRGB*) dest;
	gkRGB *srcColor  = (gkRGB*) src;
	int numColors = numBytes >> 2;
	int c1;
	while(numColors--){
		int alpha;
		switch(alpha = (srcColor->GetA())){
			case 0:   break;
			case 255: //Straight copy
				destColor->SetR((srcColor->GetR()>>1)&0x7f);
				destColor->SetG((srcColor->GetG()>>1)&0x7f);
				destColor->SetB((srcColor->GetB()>>1)&0x7f);
				break;
			default:  //mix alpha
				c1 = destColor->GetR();
				c1 += tranTable.LookupTransparencyOffset(
						(srcColor->GetR()>>1)-c1, alpha);
				destColor->SetR(c1);
				c1 = destColor->GetG();
				c1 += tranTable.LookupTransparencyOffset(
						(srcColor->GetG()>>1)-c1, alpha);
				destColor->SetG(c1);
				c1 = destColor->GetB();
				c1 += tranTable.LookupTransparencyOffset(
						(srcColor->GetB()>>1)-c1, alpha);
				destColor->SetB(c1);
				break;
		}
		srcColor++;
		destColor++;
	}
}

void gkWinShape::MemCpyHalfBrite(gkBYTE *dest, gkBYTE *src, 
		int numBytes){
	//copies colors using the Alpha for transparency
	gkRGB *destColor = (gkRGB*) dest;
	gkRGB *srcColor  = (gkRGB*) src;
	int numColors = numBytes >> 2;
	while(numColors--){
		//Straight copy
		destColor->SetR((srcColor->GetR()>>1)&0x7f);
		destColor->SetG((srcColor->GetG()>>1)&0x7f);
		destColor->SetB((srcColor->GetB()>>1)&0x7f);
		srcColor++;
		destColor++;
	}
}

gkGBCShape::gkGBCShape() : gkWinShape(){
  colorsMapped = 0;
  numColorsMapped = 0;
  curPalette = 0;
}

gkGBCShape::~gkGBCShape(){
  gkWinShape::~gkWinShape();
}

void gkGBCShape::ReduceTo4Colors(){
  gkWinShape::ReduceColors(4);

  //record the colors used
  colorsUsed = 0;
  int i, j;
  for(i=0; i<4; i++) occurrences[i] = 0;
  gkRGB *src = (gkRGB*) data;
  i = width*height;
  while(i--){
    //generator.AddColor(*src);
    for(j=0; j<colorsUsed; j++){
      if(*src == colors[j]){  //already recorded this color
	occurrences[j]++;
	break;
      }
    }
    if(j>=colorsUsed){    //found unrecorded color
      occurrences[colorsUsed] = 1;
      colors[colorsUsed++] = *src;
    }
    if(colorsUsed==4) break;
    src++;
  }
}

int  gkGBCShape::MatchPalette(gkRGB *palette, int numColors){
  gkPaletteGenerator generator;

  //Add other palette to gen
  int i;
  for(i=0; i<numColors; i++){
    generator.AddColor(palette[i]);
  }

  //count my total colors
  int totalColors = 0;
  for(i=0; i<colorsUsed; i++){
    totalColors += occurrences[i];
  }

  //how far off each is of my colors from the palette's?
  int difference=0;
  int rdiff, gdiff, bdiff;
  gkRGB newColor;
  for(i=0; i<colorsUsed; i++){
    newColor = generator.MatchColor(colors[i]);
    if(!(newColor==colors[i])){
      int diff = 0;
      rdiff = abs(newColor.GetR() - palette[i].GetR());
      gdiff = abs(newColor.GetG() - palette[i].GetG());
      bdiff = abs(newColor.GetB() - palette[i].GetB());
      rdiff *= rdiff;
      gdiff *= gdiff;
      bdiff *= bdiff;
      diff = rdiff + gdiff + bdiff;
      int categoryDiff = abs(newColor.GetCategory() 
	  - palette[i].GetCategory())+1;
      //worse for more numerous colors to be off
      difference += (diff * 
	  (occurrences[i])) / totalColors;
      //difference += diff;
    }
  }

  return difference;
}

void gkGBCShape::Finalize(int n){
  /*
  int grey = n*32;
  Cls(gkRGB(grey,grey,grey));
  gkRGB c1 = curPalette->GetPalette()[0];
  gkRGB c2 = curPalette->GetPalette()[1];
  gkRGB c3 = curPalette->GetPalette()[2];
  gkRGB c4 = curPalette->GetPalette()[3];
  int cUsed = curPalette->GetColorsUsed();
  ASSERT(n!=1);
  */
//if(this==g_sixth) ASSERT(0);
  RemapToPalette(curPalette->GetPalette(), 
     curPalette->GetColorsUsed());
}

gkGBCPalette::gkGBCPalette(gkRGB *init_colors, int init_colorsUsed){
  int i;
  colorsUsed = init_colorsUsed;
  for(i=0; i<init_colorsUsed; i++){
    colors[i] = init_colors[i];
  }
  numReferences = 1;
}

int gkGBCPalette::SortByReferences(const void *e1, const void *e2){
  gkGBCPalette *p1 = *((gkGBCPalette**) e1);
  gkGBCPalette *p2 = *((gkGBCPalette**) e2);
  if(p1->numReferences > p2->numReferences) return -1;
  if(p1->numReferences < p2->numReferences) return  1;
  return 0;
}

int gkGBCPalette::CanUnionWith(gkGBCPalette *p2, int maxColors){
  gkPaletteGenerator generator;

  //add all colors in both palettes to generator
  int i;
  for(i=0; i<colorsUsed; i++) generator.AddColor(colors[i]);
  for(i=0; i<p2->colorsUsed; i++) generator.AddColor(p2->colors[i]);

  if(generator.NumUniqueColors() > maxColors) return 0;  //no union possible
  return 1;  //can do a union
}

void gkGBCPalette::MakeUnionWith(gkGBCPalette *p2){
  gkPaletteGenerator generator;

  //add all colors in both palettes to generator
  int i;
  for(i=0; i<colorsUsed; i++) generator.AddColor(colors[i]);
  for(i=0; i<p2->colorsUsed; i++) generator.AddColor(p2->colors[i]);

  p2->colorsUsed = 
    generator.CreatePalette(p2->colors, generator.NumUniqueColors());
  p2->numReferences += numReferences;
}

