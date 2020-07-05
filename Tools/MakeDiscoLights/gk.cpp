#include "gk.h"
#include <stdlib.h>

extern ofstream logFile;

gkTransparencyTable gkBitmap::tranTable;

struct BMP_header{
  gkLONG fSize;          //54 byte header + 4*numColors (1-8bit) + (w*h*bpp)/8
  gkWORD  zero1, zero2;   //0,0
  gkLONG offsetBytes;    //should be header (54) plus Palette Size

  gkLONG headerSize;     //size of remaining header (40)
  gkLONG width, height;  //w,h in pixels
  gkWORD  planes, bpp;    //plane=1, bpp=1,2,4, or most commonly 8
  gkLONG compression, imageSize;       //compression to zero, size is w*h(8bit)
  gkLONG xpels, ypels, zero3, zero4;   //set to 0,0,0,0
};

#ifdef _WIN32
gkFileInputBuffer::gkFileInputBuffer(char *filename){
	buffer = 0;
	stin = 0;
	exists = 0;
  HANDLE handle = CreateFile(filename,GENERIC_READ,FILE_SHARE_READ,0,
			OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
	if(handle==INVALID_HANDLE_VALUE) return;
	int size = GetFileSize(handle,0);
	buffer = new char[size];
	unsigned long bytesRead;
  ReadFile(handle,buffer,size,&bytesRead,0);
	CloseHandle(handle);
	stin = new istrstream(buffer,size);
	exists = 1;
}

gkFileInputBuffer::~gkFileInputBuffer(){
	if(stin){
		delete stin;
		stin = 0;
	}
	if(buffer) delete buffer;
	buffer = 0;
}

gkFileOutputBuffer::gkFileOutputBuffer(char *filename){
	exists = 0;
  handle = CreateFile(filename,GENERIC_WRITE,FILE_SHARE_READ,0,
			CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
	if(handle==INVALID_HANDLE_VALUE){
		return;
	}
	exists = 1;
}

gkFileOutputBuffer::~gkFileOutputBuffer(){
	if(handle==INVALID_HANDLE_VALUE) return;
	unsigned long written;
	WriteFile(handle,stout.str(),stout.tellp(),&written,0);
	//unfreeze the ostrstream so it will delete the array
	stout.rdbuf()->freeze(0);  
	CloseHandle(handle);
}
#endif

gkList::gkList(void){
  head = tail = 0;
  numItems = 0;
}

gkList::~gkList(void){
	Reset();
}


void gkList::Reset(){
  gkListItem *cur, *next;
  for(cur=head; cur; cur=next){
    next = cur->NextItem();
    delete cur;
  }
  head = tail = 0;
}

gkListItem *gkList::GetItem(int n){
  if(n >= numItems) return 0;
  gkListItem *cur;
  cur = head;
  while(n-- > 0){
    cur = cur->NextItem();
  }
  return cur;
}

void gkList::AddItem(gkListItem *li){
  numItems++;
  if(!head){
    head = tail = li;
  }else{
    tail->SetNextItem(li);
    tail = tail->NextItem();
    li->SetNextItem(0);
  }
}

void gkList::DeleteItem(gkListItem *item){
	gkListItem *cur, *prev;
  
	//is it the head?
	if(item==head){
		head=head->GetNext();
		if(!head) tail = 0;
		delete item;
		return;
	}

	//must be in body or tail
	prev = 0;
	for(cur=head; cur; cur=cur->GetNext()){
		if(cur==item){
			prev->SetNext(cur->GetNext());
			if(cur==tail) tail=prev;
			delete cur;
			break;
		}
		prev = cur;
	}
}

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

int gkRGB::Equals(int _r, int _g, int _b){
  return _r==color.bytes.r && _g==color.bytes.g && _b==color.bytes.b;
}

void gkRGB::Combine(gkRGB c2, int alpha){
	//mix alpha
	color.bytes.r += 
		gkBitmap::tranTable.LookupTransparencyOffset(c2.GetR()-GetR(), alpha);
	color.bytes.g += 
		gkBitmap::tranTable.LookupTransparencyOffset(c2.GetG()-GetG(), alpha);
	color.bytes.b += 
		gkBitmap::tranTable.LookupTransparencyOffset(c2.GetB()-GetB(), alpha);
}

void gkRGB::SetFromGBColor(int gbColor){
	color.bytes.r = (gbColor<<3) & 0xf8;
	color.bytes.g = (gbColor>>2) & 0xf8;
	color.bytes.b = (gbColor>>7) & 0xf8;
}

gkPalGenItem::gkPalGenItem(gkRGB _color){
  color = _color;
  occurrences = 1;
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

int gkPalGenItem::GetCount(){
  gkPalGenItem *cur;
  int count = 0;
  for(cur=this; cur; cur=cur->nextItem){
    if(cur->occurrences) count++;
  }
  return count;
}

int gkPalGenItem::SortCallback(const void *e1, const void *e2){
  gkPalGenItem *i1 = *((gkPalGenItem**) e1);
  gkPalGenItem *i2 = *((gkPalGenItem**) e2);
  if(i1->occurrences > i2->occurrences) return -1;
  if(i1->occurrences == i2->occurrences) return 0;
  return 1;
}

gkPaletteGenerator::gkPaletteGenerator(){
  int i;
  for(i=0; i<52; i++){
    colorCube[i] = 0;
  }
}

gkPaletteGenerator::~gkPaletteGenerator(){
  Reset();
}

void gkPaletteGenerator::Reset(){
  int i;
  for(i=0; i<52; i++){
    if(colorCube[i]){
      gkPalGenItem *cur, *next;
      for(cur=colorCube[i]; cur; cur=next){
	next = cur->GetNextItem();
	delete cur;
      }
      colorCube[i] = 0;
    }
  }
}

void gkPaletteGenerator::AddColor(gkRGB color){
  int i = GetHash(color);
  
  if(!colorCube[i]){
    colorCube[i] = new gkPalGenItem(color);
  }else{
    gkPalGenItem *cur, *prev;
    for(cur=colorCube[i]; cur; cur=cur->GetNextItem()){
      if((cur->GetColor()) == color){
	cur->AddOccurrence();   //Color already in list
	break;
      }
      prev = cur;
    }
    if(!cur){   //color not in list
      prev->SetNextItem(new gkPalGenItem(color));
    }
  }
}

void gkPaletteGenerator::CreatePalette(gkRGB *palette, int numEntries){
  if(numEntries<=0) return;

  //Set all entries to black
  int i;
  for(i=0; i<numEntries; i++) palette[i] = gkRGB(0,0,0);

  //1 entry from every this many indices
  double scaleFactor = 52.0 / numEntries;

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
      if(colorCube[i]) count += colorCube[i]->GetCount();
    }
    while(!count){   //if no colors yet expand area of inclusion
      if(first==0 && last==51) return;    //no colors anywhere!
      if(first>0){
	      first--;
	      if(colorCube[first]) count += colorCube[first]->GetCount();
      }
      if(last<51){
	      last++;
	      if(colorCube[last]) count += colorCube[last]->GetCount();
      }
    }

    //Create an array to hold all the colors for sorting purposes
    gkPalGenItem **colors = new gkPalGenItem*[count];
    gkPalGenItem *cur;
    i = 0;
    int j;
    for(j=first; j<=last; j++){
      if(colorCube[j]){
	    for(cur=colorCube[j]; cur; cur=cur->GetNextItem()){
	      if(cur->GetOccurrences()) colors[i++] = cur;
      }
      }
    }

    //figure out how many colors will come from this section of the cube
    int numToGrab = 1;
    int tempCurEntry = curEntry;
    while(nextEntry==first && tempCurEntry<(52-1)){
      tempCurEntry++;
      nextEntry = (int) (scaleFactor * (tempCurEntry+1));
      numToGrab++;
    }

    if(numToGrab > count) numToGrab = count;

    //sort colors into descending order and pick "num" most frequent
    qsort(colors, count, sizeof(gkPalGenItem*), gkPalGenItem::SortCallback);

    for(i=0; i<numToGrab; i++){
      palette[curEntry++] = colors[i]->GetColor();
      colors[i]->SetOccurrences(0);
    }

    //delete sorting table
    delete colors;
  }
}


int  gkPaletteGenerator::GetNumColors(){
	int num = 0, i;
  for(i=0; i<52; i++) 
    if(colorCube[i]) num += colorCube[i]->GetCount();
	return num;
}


int  gkPaletteGenerator::GetHash(gkRGB color){
  int r = color.GetR() >> 6;   //rough categories 0-3
  int g = color.GetG() >> 6;
  int b = color.GetB() >> 6;
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
}

int  gkPaletteGenerator::ColorExists(gkRGB color){
  int hash = GetHash(color);
	if(!colorCube[hash]) return 0;

	gkPalGenItem *cur;
	for(cur=colorCube[hash]; cur; cur=cur->GetNextItem()){
		if(cur->GetColor()==color) return 1;  //found exact color
	}
	return 0;
}

gkRGB gkPaletteGenerator::MatchColor(gkRGB color){
  int hash = GetHash(color);
  int r = color.GetR();
  int g = color.GetG();
  int b = color.GetB();
  if(colorCube[hash]){           //near colors; search just this section
    gkPalGenItem *cur, *bestMatch;
    int bestDiff;
    bestMatch = colorCube[hash];
    int r2, g2, b2;
    r2 = abs(r - bestMatch->GetColor().GetR());
    g2 = abs(g - bestMatch->GetColor().GetG());
    b2 = abs(b - bestMatch->GetColor().GetB());
    bestDiff = r2 + g2 + b2;
    for(cur=bestMatch->GetNextItem(); cur; cur=cur->GetNextItem()){
      r2 = abs(r - cur->GetColor().GetR());
      g2 = abs(g - cur->GetColor().GetG());
      b2 = abs(b - cur->GetColor().GetB());
      int curDiff = r2 + g2 + b2;
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
    first = last = 36 + (hash % 4);
    if(!colorCube[first]){
      first = 0;    //nothing there either; search everything
      last = 51;
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
    }
    gkPalGenItem *cur, *bestMatch;
    int bestDiff = 0x7fffffff;
    bestMatch = 0;
    int i;
    for(i=first; i<=last; i++){
      for(cur=colorCube[i]; cur; cur=cur->GetNextItem()){
	int r2 = abs(r - cur->GetColor().GetR());
	int g2 = abs(g - cur->GetColor().GetG());
	int b2 = abs(b - cur->GetColor().GetB());
	int curDiff = r2 + g2 + b2;
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


gkBitmap::gkBitmap(){
  data = 0;
  width = height = bpp = 0;
}

gkBitmap::~gkBitmap(){
  FreeData();
}

void  gkBitmap::FreeData(){
  if(data){
    delete data;
    data = 0;
  }
  width = height = 0;
}

void  gkBitmap::Create(int _width, int _height){
  if(_width <= 0 || _height <= 0) return;
  
  FreeData();
  width = _width;
  height = _height;

  //round up width to ensure multiple of 4 pixels
  width = (width + 3) & (~3);

  int size = (width*height)<<2;
  data = new gkBYTE[size];

  //data = new gkBYTE[(width*height)<<2];
  bpp = 32;
}

void  gkBitmap::Cls(){
  if(!this->data) return;

  gkLONG *dest = (gkLONG*) this->data;
  int i = this->width * this->height;
  while(i--){
    *(dest++) = 0xff000000;
  }
}

void  gkBitmap::Cls(gkRGB color){
  if(!this->data) return;

  gkLONG *dest = (gkLONG*) this->data;
  int i = this->width * this->height;
  while(i--){
    *(dest++) = color.GetARGB();
  }
}

void  gkBitmap::Plot(int x, int y, gkRGB color, int testBoundaries){
  if(!data) return;
  if(testBoundaries){
    if(x<0 || x>=width || y<0 || y>=height) return;
  }

  gkRGB *dest = (gkRGB*) (data + ((y*width + x) << 2));
  *dest = color;
}

gkRGB gkBitmap::Point(int x, int y, int testBoundaries){
  if(!data) return gkRGB(0,0,0);
  if(testBoundaries){
    if(x<0 || x>=width || y<0 || y>=height) return gkRGB(0,0,0);
  }

  gkRGB *color = (gkRGB*) (data + ((y*width + x) << 2));
  return *color;
}

void  gkBitmap::Line(int x1, int y1, int x2, int y2, gkRGB color){
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
  gkRGB *dest = (gkRGB*) (data + (((y1 * width) + x1) <<2));
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
				dest += pitch;
			}
		}
	}else{                //loop on y, change x every so often
		err = 0;
		for(i=ydist; i>=0; i--){
			*dest = color;
			dest += pitch;
			err += xdist;
			if(err >= ydist){
				err -= ydist;
				dest++;
			}
		}
	}
}

void  gkBitmap::LineAlpha(int x1, int y1, int x2, int y2, gkRGB color, 
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
  gkRGB *dest = (gkRGB*) (data + (((y1 * width) + x1) <<2));
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
				dest += pitch;
			}
		}
	}else{                //loop on y, change x every so often
		err = 0;
		for(i=ydist; i>=0; i--){
			dest->Combine(color,alpha);
			dest += pitch;
			err += xdist;
			if(err >= ydist){
				err -= ydist;
				dest++;
			}
		}
	}
}

void  gkBitmap::RectFrame(int x, int y, int w, int h, gkRGB color){
	int x2 = x + w - 1;
	int y2 = y + h - 1;
	RectFill(x,y,w,1,color);
	RectFill(x,y2,w,1,color);
	RectFill(x,y,1,h,color);
	RectFill(x2,y,1,h,color);
}

void  gkBitmap::RectFill(int x, int y, int w, int h, gkRGB color){
	int x2 = (x + w) - 1;
	int y2 = (y + h) - 1;

	//Clip rectangle
	if(x < 0) x = 0;
	if(y < 0) y = 0;

	if(x2 >= width) x2 = width - 1;
	if(y2 >= height) y2 = height - 1;

	if(x2 < x || y2 < y) return;

  //Set pointers and offsets
  gkRGB *destStart = (gkRGB*) (data + (((y * width) + x) <<2));
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
		destStart += width;
	}
}

void  gkBitmap::RectFillAlpha(int x, int y, int w, int h, gkRGB color,
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
  gkRGB *destStart = (gkRGB*) (data + (((y * width) + x) <<2));
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
		destStart += width;
	}
}

void  gkBitmap::RectFillChannel(int x, int y, int w, int h, 
		gkRGB color, int mask){
	int x2 = (x + w) - 1;
	int y2 = (y + h) - 1;

	//Clip rectangle
	if(x < 0) x = 0;
	if(y < 0) y = 0;

	if(x2 >= width) x2 = width - 1;
	if(y2 >= height) y2 = height - 1;

	if(x2 < x || y2 < y) return;

  //Set pointers and offsets
  gkLONG *destStart = (gkLONG*) (data + (((y * width) + x) <<2));
	gkLONG *dest;
	int numRows = (y2 - y) + 1;
	int rowWidth = (x2 - x) + 1;

	gkLONG srcColor = color.GetARGB() & mask;
	gkLONG destMask = ~mask;

	//do it
	while(numRows--){
		dest = destStart;

		int i;
		for(i=0; i<rowWidth; i++){
			*dest = (*dest & destMask) | (srcColor);
			dest++;
		}
		destStart += width;
	}
}

struct gkFillItem{
	short int x, y;
	gkRGB *pos;

  inline gkFillItem(){}
  inline gkFillItem(int _x, int _y, gkRGB *_pos){
    x = _x;
    y = _y;
    pos = _pos;
  }
};

void  gkBitmap::FloodFill(int x, int y, gkRGB color){
	gkFillItem queue[16384];
	int qHead=0, qTail=0;
	
	//not the color we're filling WITH, the color we're filling ON
	gkRGB fillColor = Point(x,y);
	if(color==fillColor) return;

	//enqueue the starting location
	queue[qTail++] = gkFillItem(x,y,(gkRGB *)(data + ((y*width + x) * 4)));

	//keep looping, filling current location & adding adjacent locations
	//until queue is empty
	while(qHead != qTail){
		//dequeue an item
		gkFillItem cur = queue[qHead++];
		qHead &= 16383;

		//out of bounds check
		if(cur.x<0 || cur.y<0 || cur.x>=width || cur.y>=height) continue;

		//filling correct color check
    if(!(*(cur.pos)==fillColor)) continue;

		//fill color & add adjacent
		*(cur.pos) = color;

		queue[qTail++] = gkFillItem(cur.x+1,cur.y,cur.pos+1);
		qTail &= 16383;
		queue[qTail++] = gkFillItem(cur.x-1,cur.y,cur.pos-1);
		qTail &= 16383;
		queue[qTail++] = gkFillItem(cur.x,cur.y+1,cur.pos+width);
		qTail &= 16383;
		queue[qTail++] = gkFillItem(cur.x,cur.y-1,cur.pos-width);
		qTail &= 16383;
	}
}

int   gkBitmap::GetNumColors(){
	gkPaletteGenerator palGen;
	int i = width * height;
  gkRGB *src = (gkRGB*) data;
  while(i--){
		palGen.AddColor(*(src++));
  }

	return palGen.GetNumColors();
}

void  gkBitmap::RemapColor(gkRGB oldColor, gkRGB newColor){
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


int   gkBitmap::GetPalette(gkRGB *palette, int maxColors){
	gkPaletteGenerator palGen;
	int i = width * height;
  gkRGB *src = (gkRGB*) data;
  while(i--){
		palGen.AddColor(*(src++));
  }

	int num = palGen.GetNumColors();
  palGen.CreatePalette(palette, maxColors);
	return num;
}


void  gkBitmap::RemapToPalette(gkRGB *palette, int numColors){
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

void  gkBitmap::ReduceColors(int numColors){
  gkPaletteGenerator generator;
  int i = width * height;
  gkRGB *src = (gkRGB*) data;
  while(i--){
    generator.AddColor(*(src++));
  }

  //gkRGB palette[256];
  gkRGB *palette = new gkRGB[numColors];
  generator.CreatePalette(palette, numColors);
  RemapToPalette(palette, numColors);
  delete palette;
}

void  gkBitmap::ExchangeColors(gkRGB c1, gkRGB c2){
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

void  gkBitmap::SetAlpha(int alpha){
  if(!data) return;

  gkRGB *src = (gkRGB*) data;
  int i = (width * height);
  while(i--){
    (src++)->SetA(alpha);
  }
}

void  gkBitmap::SetColorAlpha(gkRGB color, int alpha){
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

void gkBitmap::SetAlphaEdges(float opacity, int iterations){
  { //body in block to prevent recursive memory waste
    gkBitmap work;
    work.GetBitmap(this);
    gkRGB *src  = (gkRGB*) work.data;
    gkRGB *dest = (gkRGB*) data;
    gkRGB alpha;
    int i, j;
    for(j=0; j<height; j++){
      for(i=0; i<width; i++){
        if(src->GetA()==255){
          int alpha = 0;
          int samples = 0;
          if(i>0 && j>0){
            alpha += work.Point(i-1,j-1).GetA();
            samples++;
          }
          if(i>0 && j<height-1){
            alpha += work.Point(i-1,j+1).GetA();
            samples++;
          }
          if(i<width-1 && j>0){
            alpha += work.Point(i+1,j-1).GetA();
            samples++;
          }
          if(i<width-1 && j<height-1){
            alpha += work.Point(i+1,j+1).GetA();
            samples++;
          }
          if(samples==0) samples=1;  //would only happen on 1x1
          alpha /= samples;
          alpha = (int) (alpha * opacity);
          dest->SetA(alpha);
        }
        dest++;
        src++;
      }
    }
  }

  if(iterations>0) SetAlphaEdges(opacity, iterations-1);
}

void gkBitmap::MirrorH(){
	gkRGB *buffer = new gkRGB[width];
	if(!buffer) return;

	gkRGB *cur = (gkRGB*) data;

	int i,j,i2;
	for(j=0; j<height; j++){
	  for(i=0,i2=width-1; i<width; i++,i2--){
			buffer[i2] = cur[i];
	  }
	  for(i=0; i<width; i++){
			cur[i] = buffer[i];
	  }
		cur += width;
	}

	delete buffer;
}

int  gkBitmap::GetBitmap(gkBitmap *srcBitmap, int x, int y, int w, int h){
  if(!srcBitmap || !srcBitmap->data) return 0;

  //adjust src rectangle until it fits within source data
  if(x<0){
    w += x;
    x = 0;
  }
  if(y<0){
    h += y;
    y = 0;
  }
  if(x + w > srcBitmap->width){
    w = srcBitmap->width - x;
  }
  if(y + h > srcBitmap->height){
    h = srcBitmap->height - y;
  }

  if(w<=0 || h<=0) return 0;

  FreeData();
  Create(w, h);

  gkBYTE *src = srcBitmap->data + ((y*srcBitmap->width + x)<<2);
  gkBYTE *dest = this->data;
  int srcSkip = srcBitmap->width << 2;   //4 bytes per pixel
	w <<= 2;  //4 bytes per pixel

  while(h--){
    memcpy(dest, src, w);
    dest += w;
    src  += srcSkip;
  }

  return 1;
}

int   gkBitmap::GetBitmap(gkBitmap *srcBitmap){
  if(this->width != srcBitmap->width || this->height != srcBitmap->height
      || (!this->data) || (!srcBitmap->data)){
    //mem needs to be reallocated
    FreeData();
    memcpy(this, srcBitmap, sizeof(gkBitmap));
    data = 0;
    if(srcBitmap->data){
      data = new gkBYTE[(width * height) << 2];
      memcpy(data, srcBitmap->data, (width * height) << 2 );
    }
  }else{
    //already got right size mem, just copy data over
    memcpy(data, srcBitmap->data, (width * height) << 2);
    fontSpacing = srcBitmap->fontSpacing;
    fontKerning = srcBitmap->fontKerning;
    x_handle = srcBitmap->x_handle;
    y_handle = srcBitmap->y_handle;
  }
  return data!=0;
}

int   gkBitmap::SaveBitmap(char *filename){
  ofstream outfile;
	outfile.open(filename, ios::out | ios::binary);
  if(!outfile) return 0;

  int result = SaveBitmap(outfile);
  outfile.close();

  return result;
}

int   gkBitmap::SaveBitmap(ostream &out){
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
    gkBYTE *srcStart = data;

    int i,j;
    for(j=0; j<height; j++){
      src = (gkLONG*) srcStart;
      for(i=0; i<width; i++){
	      gkIO::WriteLong(out, *(src++));
      }
      srcStart += pitch;
    }
  }

  return 1;
}

int   gkBitmap::LoadBitmap(char *filename){
	ifstream infile(filename,ios::in|ios::binary|ios::nocreate);
  if(!infile) return 0;

	//gkFileInputBuffer gkInfile(filename);
  //if(!gkInfile.Exists()) return 0;
  //istream &infile = *gkInfile.GetIStream();

  int result = this->LoadBitmap(infile);
  infile.close();

  return result;
}

int   gkBitmap::LoadBitmap(istream &infile){
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
  gkBYTE *destStart = data;
  gkLONG *dest;
  int x,y;
  for(y=0; y<height; y++){
    dest = (gkLONG*) destStart;
    for(x=0; x<width; x++){
      *(dest++) = gkIO::ReadLong(infile);
    }
    destStart += pitch;
  }

  return 1;
}

int   gkBitmap::LoadBMP(char *filename){
	ifstream infile(filename,ios::in|ios::binary|ios::nocreate);
  if(!infile) return 0;

	//gkFileInputBuffer gkInfile(filename);
  //if(!gkInfile.Exists()) return 0;
  //istream &infile = *gkInfile.GetIStream();

  int result = this->LoadBMP(infile);
  infile.close();

  return result;
}

int   gkBitmap::LoadBMP(istream &infile){
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
  gkBYTE *nextBuffPtr = buffer + ((height-1) * srcPitch);
  gkBYTE *buffPtr;

  infile.read(buffer, srcPitch * height);

  gkBYTE *nextDest = data;
  gkRGB *dest;
  int destPitch = (width << 2);
  
  int i, j;
  j = height;
  while(j--){
    buffPtr = nextBuffPtr;
    nextBuffPtr -= srcPitch;
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

int   gkBitmap::SaveBMP(char *filename){
	if(!data) return 0;
	if(!filename) return 0;

	//open file
  ofstream outfile;
	outfile.open(filename, ios::out | ios::binary);
	if(!outfile) return 0;

	outfile << 'B' << 'M';  //"BM" (file type)

	BMP_header header;
	memset(&header,0,sizeof(header));   //clear everything to zero
	header.width  = width;
	header.height = height;
	header.bpp    = 24;
	header.planes = 1;
	header.imageSize = (header.width * header.height * header.bpp) / 8;
	header.headerSize  = 40;
	header.offsetBytes = 54;    //header + palette size
	header.fSize       = 54 + header.imageSize;

	outfile.write((char*)&header, sizeof(BMP_header));

	// save graphics as bottom-to-top, left-to-right //
	int y = height - 1;
	int pitch = width*4;
	gkBYTE *src = data + (y * pitch);  //find bottom of buffer
	gkBYTE *d;

	//write brg bytes out
	int i;
	for(; y>=0; y--){
		d = src;
		for(i=0; i<width; i++){
			int r,g,b;
			b = *(d++); g = *(d++); r = *d;
			outfile << (char) b << (char) g << (char) r;
			d+=2;
		}
		src -= pitch;
	}

	outfile.close();
	return 1;
}

void  gkBitmap::Blit(gkBitmap *destBitmap, int x, int y, int flags){
  if(!data || !destBitmap || !destBitmap->data) return;

  gkBYTE *src  = 0;
  int srcWidth = this->width;
  int srcSkip  = this->width;
  int lines    = this->height;

  //clip left side
  if(x < 0){
    src += -x;     //times 4 later
    srcWidth -= -x;
    x = 0;
  }

  //clip right side
  int diff = (x + srcWidth) - destBitmap->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   += (-y * this->width);    //times 4 later
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destBitmap->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destBitmap->width;

  gkBYTE *dest = destBitmap->data + (((y * destBitmap->width) + x) << 2);
  src  = this->data + ((int)src << 2);
  srcWidth <<= 2;
  srcSkip  <<= 2;
  destSkip <<= 2;

  if(flags & GKBLT_TRANSPARENT){
    //blit using alpha 0 as fully transparent
    while(lines--){
      MemCpyTrans(dest, src, srcWidth);
      src  += srcSkip;
      dest += destSkip;
    }
  }else{
    //blit without a transparent color
    while(lines--){
      memcpy(dest, src, srcWidth);
      src  += srcSkip;
      dest += destSkip;
    }
  }
}


//////////////////////////////////////////////////////////////////////
//  Method:       BlitColorToAlpha
//  Description:  Converts this bitmap's colors into alpha values on
//                the destination bitmap.  Black becomes transparent,
//                white fully opaque.
//////////////////////////////////////////////////////////////////////
void gkBitmap::BlitColorToAlpha(gkBitmap *destBitmap, int x, int y){
  if(!data || !destBitmap || !destBitmap->data) return;

  gkBYTE *src  = 0;
  int srcWidth = this->width;
  int srcSkip  = this->width;
  int lines    = this->height;

  //clip left side
  if(x < 0){
    src += -x;     //times 4 later
    srcWidth -= -x;
    x = 0;
  }

  //clip right side
  int diff = (x + srcWidth) - destBitmap->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   += (-y * this->width);    //times 4 later
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destBitmap->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destBitmap->width;

  gkBYTE *dest = destBitmap->data + (((y * destBitmap->width) + x) << 2);
  src  = this->data + ((int)src << 2);
  srcWidth <<= 2;
  srcSkip  <<= 2;
  destSkip <<= 2;

  //blit converting color(B) to alpha.
  while(lines--){
    MemCpyColorToAlpha(dest, src, srcWidth);
    src  += srcSkip;
    dest += destSkip;
  }
}

//////////////////////////////////////////////////////////////////////
//  Function:    BlitScale
//  Arguments:   destBitmap
//               x
//               y
//               flags
//               scale      - number of source pixels for every one
//                            dest pixel, stored in 24:8 fixed point.
//                            $100=100%, $200=200% (mag x2), $80=50%
//////////////////////////////////////////////////////////////////////
void gkBitmap::BlitScale(gkBitmap *destBitmap, int x, int y, 
				int scale, int flags){
  if(!data || !destBitmap || !destBitmap->data || !scale) return;

  gkBYTE *src  = 0;
  int srcSkip  = this->width;
  int srcWidth = (this->width * scale) >> 8;
  int lines    = (this->height * scale) >> 8;

  //clip left side
  if(x < 0){
    src += (-x << 8) / scale;
    srcWidth -= -x;
    x = 0;
  }

  //clip right side
  int diff = (x + srcWidth) - destBitmap->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   += ((-y * this->width) << 8) / scale;
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destBitmap->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destBitmap->width;

  gkBYTE *dest = destBitmap->data + (((y * destBitmap->width) + x) << 2);
  src  = this->data + ((int)src << 2);
  srcSkip  <<= 2;
  destSkip <<= 2;

	int ratio = (int) ((1.0f / (((float) scale) / 256.0f)) * 256.0f);

	int lineError = 0;
	while(lines--){
		BlitLineScale(dest, src, srcWidth, ratio);
		lineError += ratio;
		src  += srcSkip * (lineError >> 8);
		lineError &= 0xff;
		dest += destSkip;
	}

	/*
  if(flags & GKBLT_TRANSPARENT){
    //blit using alpha 0 as fully transparent
    while(lines--){
      MemCpyTrans(dest, src, srcWidth);
      src  += srcSkip;
      dest += destSkip;
    }
  }else{
    //blit without a transparent color
    while(lines--){
      memcpy(dest, src, srcWidth);
      src  += srcSkip;
      dest += destSkip;
    }
  }
	*/
}

void gkBitmap::BlitScale(gkBitmap *destBitmap, int x, int y, 
				float scale, int flags){
	BlitScale(destBitmap,x,y,flags,(int) (256.0f * scale));
}

void gkBitmap::BlitChannel(gkBitmap *destBitmap, int x, int y, int mask){
  if(!data || !destBitmap || !destBitmap->data) return;

  gkBYTE *src  = 0;
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
  int diff = (x + srcWidth) - destBitmap->width;
  if(diff > 0){
    srcWidth -= diff;
  }

  if(srcWidth <= 0) return;

  //clip top
  if(y<0){
    src   += (-y * this->width);
    lines += y;    //lines -= (-y)
    y = 0;
  }

  //clip bottom
  diff = (y + lines) - destBitmap->height;
  if(diff > 0){
    lines -= diff;
  }

  if(lines <= 0) return;

  int destSkip = destBitmap->width;

  gkBYTE *dest = destBitmap->data + (((y * destBitmap->width) + x) << 2);
  src  = this->data + ((int)src << 2);
  srcSkip  <<= 2;
  destSkip <<= 2;

	int inverseMask = ~mask;

	while(lines--){
		gkLONG *curSrc = (gkLONG*) src;
		gkLONG *curDest = (gkLONG*) dest;
		int pixels = srcWidth;
		while(pixels--){
			*curDest = (*curSrc & mask) | (*curDest & inverseMask);
			curSrc++;
			curDest++;
		}
		src  += srcSkip;
		dest += destSkip;
	}
}

void gkBitmap::MemCpyTrans(gkBYTE *dest, gkBYTE *src, 
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
								c1 += tranTable.LookupTransparencyOffset(
										  srcColor->GetR()-c1, alpha);
								destColor->SetR(c1);
								c1 = destColor->GetG();
								c1 += tranTable.LookupTransparencyOffset(
										  srcColor->GetG()-c1, alpha);
								destColor->SetG(c1);
								c1 = destColor->GetB();
								c1 += tranTable.LookupTransparencyOffset(
										  srcColor->GetB()-c1, alpha);
								destColor->SetB(c1);
								break;
		}
		srcColor++;
		destColor++;
	}
}

void gkBitmap::MemCpyColorToAlpha(gkBYTE *dest, gkBYTE *src, 
		int numBytes){
	//converts blue to alpha during copy
	gkRGB *destColor = (gkRGB*) dest;
	gkRGB *srcColor  = (gkRGB*) src;
	int numColors = numBytes >> 2;
	while(numColors--){
    destColor->SetA(srcColor->GetB());
		srcColor++;
		destColor++;
	}
}

void gkBitmap::BlitLineScale(gkBYTE *dest,gkBYTE *src,int pixels,int ratio){
	gkRGB *srcRGB = (gkRGB*) src;
	gkRGB *destRGB = (gkRGB*) dest;

	int error = 0;

	while(pixels--){
		*(destRGB++) = *srcRGB;
		error += ratio;
		srcRGB += error >> 8;
		error &= 0xff;
	}
}

