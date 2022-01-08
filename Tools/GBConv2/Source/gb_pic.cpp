#include "stdafx.h"
#include "gb_pic.h"
#include <winuser.h>
#include <fstream.h>

//statics
gkWinShape gbPic::nonPictureBG;
gkWinShape gbPic::nonColorBG;
gkWinShape gbPic::gfxTiles[20];

//////////////////////////////////////////////////////////////////////
//  Open8BitHashTable
//////////////////////////////////////////////////////////////////////
Open8BitHashTable::Open8BitHashTable(){
	table = 0;
	Reset();
}

Open8BitHashTable::~Open8BitHashTable(){
	Reset();
}

void Open8BitHashTable::Reset(){
	if(table) delete table;
	table = 0;
	size = 0;
}

void Open8BitHashTable::Create(int maxElements){
	Reset();

	size = maxElements + 1;
	int powerTwo = 1;
	while(powerTwo < size) powerTwo<<=1;
	size = powerTwo;

	table = new HashEntry[size];

	int i;
	for(i=0; i<256; i++){
		entryPoint[i] = (size * i) / 256;
	}
}

int  Open8BitHashTable::SetFirstIndex(int code){
	return entryPoint[code & 0xff];
}

int  Open8BitHashTable::GetNextIndex(int &position){
  int retVal;
	if(table[position].hash==-1){
    retVal = -1;
    position++;
  }else{
	  retVal = table[position++].index;
  }
	position &= (size-1);   //size is always power of two
  return retVal;
}

void Open8BitHashTable::Add(int code, int index){
	int pos = SetFirstIndex(code);

	//advance 'pos' to the proper position
  while(GetNextIndex(pos)!=-1);

	pos--;
	pos &= (size-1);

	table[pos].hash = code;
	table[pos].index = index;
}



//////////////////////////////////////////////////////////////////////
//  gbTile
//////////////////////////////////////////////////////////////////////

gbTile::gbTile(){
	gkWinShape::gkWinShape();
	colors = 0;
  Reset();
}

gbTile::~gbTile(){
	Reset();
}

void gbTile::Reset(){
	gkWinShape::FreeData();
	if(colors) delete colors;
	colors = 0;
}

void gbTile::OnColorChange(){
  paletteUsed = -1;

	gkPaletteGenerator gen;
	int numPixels;
	numPixels = width * height;
	gkRGB *curData = (gkRGB*) data;
	while(numPixels--){
		gen.AddColor(*(curData++));
	}
	colorsUsed = gen.GetNumColors();
	if(colors) delete colors;
	colors = new gkRGB[colorsUsed];
	gen.CreatePalette(colors,colorsUsed);
}

int  gbTile::OnPaletteChange(int palettes){
	int result = 0;

	if(paletteUsed==-1) return 0;
	if(palettes & (1 << paletteUsed)){
	  paletteUsed = -1;
	  OnColorChange();
		result = 1;
	}

	return result;
}

int gbTile::TestMatch(gkRGB *palette){
	int i, diff = 0;
	gkPaletteGenerator gen;

	for(i=0; i<4; i++){
		if(palette[i].GetA()==0){
			if(i==0) return 0xffff;
			break;
		}
		gen.AddColor(palette[i]);
	}

	for(i=0; i<colorsUsed; i++){
		gkRGB match = gen.MatchColor(colors[i]);
		if(match!=colors[i]){
			diff += abs(match.GetR() - colors[i].GetR()) * 2;
			diff += abs(match.GetG() - colors[i].GetG()) * 2;
			diff += abs(match.GetB() - colors[i].GetB()) * 2;
		}
	}

	return diff;
}

void gbTile::UsePalette(int palNum, gkRGB *palette){
	paletteUsed = palNum;
	palettePtr = palette;

	RemapToPalette(palette, 4);
}

int  gbTile::HasColor(gkRGB color){
	int i;
	for(i=0; i<colorsUsed; i++){
		if(colors[i]==color) return 1;
	}
	return 0;
}

int  gbTile::GetShape(gkWinShape *srcShape, int x, int y, int w, int h){
  int result = gkWinShape::GetShape(srcShape,x,y,w,h);
  OnColorChange();
  return result;
}

void gbTile::RemapColor(gkRGB oldColor, gkRGB newColor){
	gkWinShape::RemapColor(oldColor, newColor);
  OnColorChange();
}

void gbTile::ExchangeColors(gkRGB c1, gkRGB c2){
	gkWinShape::ExchangeColors(c1,c2);
  OnColorChange();
}

void gbTile::MakeRawData(gbPic *pic){
	if(paletteUsed==-1) return;

	gkRGB *src = (gkRGB*) this->data;
	int i, bit, dest;
	dest = 0;
	dataHash = 0;
	for(i=0; i<8; i++){           //8 lines
		int byte1 = 0;
		int byte2 = 0;
		for(bit=0; bit<8; bit++){    // 8 bits per line
			//find the color index of next pixel
			gkRGB color = *(src++);
      int index;
			for(index=0; index<4; index++){
				if(palettePtr[index]==color) break;
			}

			//save the two bits of the color index in separate bytes
			byte1 = (byte1<<1) | (index & 1);
			byte2 = (byte2<<1) | ((index>>1)&1);
		}

		dataHash += byte1 + byte2;
		rawData[dest++] = byte1;
		rawData[dest++] = byte2;
	}
}

void gbTile::SetRawData(gkBYTE *data){
	dataHash = 0;
	int i;
	for(i=0; i<16; i++){
		rawData[i] = data[i];
		dataHash += data[i];
	}
}

void gbTile::CreateFromRawData(gbPic *pic){
	Create(8,8);

	gkRGB *dest = (gkRGB*) data;
	int pos = 0;

	int i;
	for(i=0; i<8; i++){
		int byte1 = rawData[pos++];
		int byte2 = rawData[pos++];

		for(int bit=0; bit<8; bit++){
			int index = 0;
			if(byte1 & 128) index += 1;
			if(byte2 & 128) index += 2;
			byte1<<=1;
			byte2<<=1;
			*(dest++) = palettePtr[index];
		}
	}

	int pal = paletteUsed;
	OnColorChange();
	SetPaletteUsed(pic,pal);
}

int  gbTile::CompareRawData(gkBYTE *data2){
	int i;
	for(i=0; i<16; i++){
		if(rawData[i] != data2[i]) return 0;
	}
	return 1;
}

void gbTile::SetPaletteUsed(gbPic *pic, int n){
	paletteUsed = n;
	palettePtr = pic->GetPalette(n);
}

void gbTile::CopyRawDataTo(gkBYTE *dest){
	int i;
	for(i=0; i<16; i++) dest[i] = rawData[i];
}

void gbTile::WriteRawData(ostream &out){
	int i;
	for(i=0; i<16; i++) out.put(rawData[i]);
}


//////////////////////////////////////////////////////////////////////
//  gbSprite
//////////////////////////////////////////////////////////////////////
gbSprite::gbSprite(){
	gkWinShape::gkWinShape();
	Reset();
}

gbSprite::~gbSprite(){
	Reset();
	gkWinShape::~gkWinShape();
}

void gbSprite::Reset(){
	gkWinShape::Reset();
}

void gbSprite::Create8x16FromSelection(int x1, int y1, 
		gbTile *tile1, gbTile *tile2, gkWinShape *selection, gbPic *pic){

	xp = x1;
	yp = y1;

	Create(8,16);
	int pal = tile1->GetPaletteUsed();
	if(pal==-1) pal = pic->GetCurPalette();

	palette = pic->GetPalette(pal);
	paletteNum = pal;

	gkRGB bgColor = pic->GetColor(pal,0);
	Cls(bgColor);

	int x,y;
	for(y=0; y<8; y++){
		for(x=0; x<8; x++){
			gkRGB color = selection->Point(x+x1,y+y1);
			if(color.GetA() != 255){
				Plot(x,y,tile1->Point(x,y));
				selection->Plot(x+x1,y+y1,gkRGB(0,0,0,255));
				tile1->Plot(x,y,bgColor);
			}
		}
	}
	tile1->OnColorChange();

	if(tile2){
		for(y=8; y<16; y++){
			for(x=0; x<8; x++){
				gkRGB color = selection->Point(x+x1,y+y1);
				if(color.GetA() != 255){
					Plot(x,y,tile2->Point(x,y-8));
					selection->Plot(x+x1,y+y1,gkRGB(0,0,0,255));
					tile2->Plot(x,y-8,bgColor);
				}
			}
		}
		tile2->OnColorChange();
	}

	SetColorAlpha(bgColor,0);
	MakeRawData();
}

void gbSprite::Blit(gkWinShape *dest){
  gkWinShape::Blit(dest,xp,yp);
}

void gbSprite::DrawFrame(gkWinShape *dest, int magnification){
	int shrink = 1;
	if(((yp>>3)&1) == 1) shrink = 3;

	int x = ((xp*magnification) >> 8);
	int y = ((yp*magnification) >> 8);

	int width = (8 * magnification) >> 8;
	int height = (16 * magnification) >> 8;

	dest->RectFrame(x+shrink,y+shrink,width-shrink*2,height-shrink*2,
			gkRGB(128,255,128));
}

int gbSprite::ExistsAtIndex(int i, int j){
	int my_i = xp>>3;
	int my_j = yp>>3;
	if(my_i==i && (my_j==j || my_j+1==j)) return 1;
	return 0;
}

int gbSprite::Unmake(gbPic *pic){
	int i,j;
  i = xp>>3;
	j = yp>>3;
	int index1 = j * pic->tileWidth + i;
	int index2 = index1 + pic->tileWidth;
	
  this->gkWinShape::Blit(&pic->tiles[index1], 0, 0);
	pic->tiles[index1].OnColorChange();
	if(j+1 < pic->tileHeight){
    this->gkWinShape::Blit(&pic->tiles[index2],0,-8);
		pic->tiles[index2].OnColorChange();
	}

  return 1;
}

void gbSprite::WriteTileDefinitions(ostream &out){
	int i;
	for(i=0; i<32; i++) out.put((char) rawData[i]);
}


void gbSprite::ReadTileDefinitions(istream &in){
	//no palette yet, have to store raw data for later
	int i;
	for(i=0; i<32; i++) rawData[i] = in.get();
}


void gbSprite::WriteAttributes(ostream &out, int index){
	// 		BYTE:  Y-position
	// 		BYTE:  X-position
	// 		BYTE:  Image index of sprite used (0-127)
	// 		BYTE:  ATTRIBUTES:
	// 					 Bit 7:  0 = Sprite displayed over BG & window
	// 									 1 = Sprite hidden behind colors 1,2,&3 of 
	// 											 BG & win (stored as 0)
	// 					 Bit 6:  Y flip status (stored as 0)
	// 					 Bit 5:  X flip status (stored as 0)
	// 					 Bit 4:  Not used in GBC (stored as 0)
	// 					 Bit 3:  Character bank used (1/0)
	// 					 Bits[2:0]:  Palette number (0-7) (Stored as 0)
	out.put((char) (yp + 16));
	out.put((char) (xp + 8));
	out.put((char) (index * 2));

	int attributes = paletteNum;
	out.put((char) attributes);
}


void gbSprite::ReadAttributes(istream &in, gbPic *pic){
	// 		BYTE:  Y-position
	// 		BYTE:  X-position
	// 		BYTE:  Image index of sprite used (0-127)
	// 		BYTE:  ATTRIBUTES:
	// 					 Bit 7:  0 = Sprite displayed over BG & window
	// 									 1 = Sprite hidden behind colors 1,2,&3 of 
	// 											 BG & win (stored as 0)
	// 					 Bit 6:  Y flip status (stored as 0)
	// 					 Bit 5:  X flip status (stored as 0)
	// 					 Bit 4:  Not used in GBC (stored as 0)
	// 					 Bit 3:  Character bank used (1/0)
	// 					 Bits[2:0]:  Palette number (0-7) (Stored as 0)
	yp = (in.get() & 0xff) - 16;
	xp = (in.get() & 0xff) - 8;
	in.get();                              //discard index
  paletteNum = in.get() & 7;
	palette = pic->GetPalette(paletteNum);
}


void gbSprite::CreateFromRawData(){
	Create(8,16);

	gkRGB *dest = (gkRGB*) data;
	int pos = 0;

	int i;
	for(i=0; i<16; i++){
		int byte1 = rawData[pos++];
		int byte2 = rawData[pos++];

		for(int bit=0; bit<8; bit++){
			int index = 0;
			if(byte1 & 128) index += 1;
			if(byte2 & 128) index += 2;
			byte1<<=1;
			byte2<<=1;
			*(dest++) = palette[index];
		}
	}

	SetColorAlpha(palette[0],0);
}

void gbSprite::MakeRawData(){
	gkRGB *src = (gkRGB*) this->data;
	int i, bit, dest;
	dest = 0;
	for(i=0; i<16; i++){           //16 lines
		int byte1 = 0;
		int byte2 = 0;
		for(bit=0; bit<8; bit++){    // 8 bits per line
			//find the color index of next pixel
			gkRGB color = *(src++);
      int index;
			for(index=0; index<4; index++){
				if(palette[index]==color) break;
			}

			//save the two bits of the color index in separate bytes
			byte1 = (byte1<<1) | (index & 1);
			byte2 = (byte2<<1) | ((index>>1)&1);
		}

		rawData[dest++] = byte1;
		rawData[dest++] = byte2;
	}
}


//////////////////////////////////////////////////////////////////////
//  gbPic
//////////////////////////////////////////////////////////////////////

gbPic::gbPic(){
  tiles = 0;
	selected = 0;
	magnifiedArea.Create(80,80);
	numSprites = 0;
  Reset();

	//set up static stuff
	if(!nonPictureBG.GetData()){
		nonPictureBG.Create(80,80);
		nonPictureBG.Cls(gkRGB(0x60,0x60,0x60));
		int i,j;
		for(j=0; j<5; j++){
			for(i=0; i<5; i++){
				if(((j&1) && !(i&1)) || (!(j&1) && (i&1))){
					nonPictureBG.RectFill(i<<4, j<<4, 16, 16, gkRGB(0xa0,0xa0,0xa0));
				}
			}
		}

		nonColorBG.Create(10,10);
		nonPictureBG.BlitScale(&nonColorBG,0,0,0x48,0); 

		gkWinShape buffer;
		buffer.LoadBMP("converter_gfx.bmp");
		for(i=0; i<20; i++){
			gfxTiles[i].GetShape(&buffer,i*16,0,16,16);
			if(i<16) gfxTiles[i].SetAlpha(0xc0);
			gfxTiles[i].SetColorAlpha(gkRGB(0,0,255), 0);
		}
	}
}

gbPic::~gbPic(){
  Reset();
}

void gbPic::Reset(){
  if(tiles) delete [] tiles;
	tiles = 0;
	if(selected) delete selected;
	selected = 0;
	tileWidth = tileHeight = displayWidth = displayHeight = 0;
	totalTiles = 0;
	displayBuffer.FreeData();
	magnification = 0x400;
	needsRedraw = 1;
	showGrid = 1;
	dragSetOrClear = 0;

	int i;
	for(i=0; i<64; i++) palettes[i] = gkRGB(0,0,0,0);

	for(i=0; i<numSprites; i++){
		delete sprites[i];
		sprites[i] = 0;
	}

	numSelColors = 0;
	curPalette = 0;
	bgColor = gkRGB(0,0,0xf8);   //blue
	numSprites = 0;
	numSelTiles = 0;
}

int gbPic::LoadBMP(char *filename){
  gkWinShape original;
	if(!original.LoadBMP(filename)) return 0;

  Reset();
  tileWidth = ((original.GetWidth() + 7) & (~7)) >> 3;
  tileHeight = ((original.GetHeight() + 7) & (~7)) >> 3;
	//displayWidth = tileWidth * 8 * 4;
	//displayHeight = tileHeight * 8 * 4;
	//magnification = 0x10000 << 2;

  original.ReduceColors(56);

	//merge vagrant colors (colors that will appear the same in the GBC
	//15-bit palette)
	int *data = (int*) original.GetData();
	int i = original.GetWidth() * original.GetHeight();
	while(i--){
		*(data++) &= 0xfff8f8f8;    //clear bits 2:0 of each color
	}

	//create some buffers
	int pixelWidth = tileWidth << 3;
	int pixelHeight = tileHeight << 3;
	totalTiles = tileWidth * tileHeight;
	SetMagnification(0x400);       //default 4x magnification

	backbuffer.Create(pixelWidth, pixelHeight);
	pixelBuffer.Create(pixelWidth, pixelHeight);
	selectionBuffer.Create(pixelWidth, pixelHeight);
	displayBuffer.Create(displayWidth, displayHeight);

	displayBuffer.Cls(gkRGB(255,255,0));
	original.Blit(&displayBuffer,0,0,0);

	selectionBuffer.SetAlpha(255);

	int j,index;
	selected = new int[totalTiles];
	for(i=0; i<totalTiles; i++) selected[i] = 0;

	tiles = new gbTile[totalTiles];
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			tiles[index].GetShape(&displayBuffer, i<<3, j<<3, 8, 8);
			index++;
		}
	}

	displayBuffer.Cls(gkRGB(255,255,0));
  index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			tiles[index].Blit(&displayBuffer, i<<3, j<<3);
			index++;
		}
	}

	return 1;
}

void gbPic::Redraw(int flags){
	int i,j,index;
  int mag = magnification * 8;

	//draw the plain pixels to the screen
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			tiles[index].Blit(&pixelBuffer, i<<3, j<<3, 0);
			index++;
		}
	}

	//set opacity to half for selected colors, full for non-sel colors
	//pixelBuffer.SetAlpha(255);
	//for(i=0; i<numSelColors; i++){
		//pixelBuffer.SetColorAlpha(selectedColors[i],0x80);
	//}

	//clear to white so the (semitransparent) selected colors will appear
	//whiter
	backbuffer.Cls(gkRGB(255,255,255));
	selectionBuffer.BlitChannel(&pixelBuffer,0,0,0xff000000);  //copy alpha only

	//add in current selection being drawn
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			if((selected[index]&4)){  //selection being filled
				pixelBuffer.RectFillChannel(i<<3,j<<3,8,8,
						gkRGB(0,0,0,0x80),0xff000000);
			}
			if((selected[index]&2)){  //selection being cleared
				pixelBuffer.RectFillChannel(i<<3,j<<3,8,8,
						gkRGB(0,0,0,255),0xff000000);
			}
			index++;
		}
	}

	pixelBuffer.Blit(&backbuffer,0,0);

	//blit sprites if necessary
	if(flags & 1){
		for(i=numSprites-1; i>=0; i--) sprites[i]->Blit(&backbuffer);
	}

	//highlight selected tiles
	//index = 0;
	//for(j=0; j<tileHeight; j++){
		//for(i=0; i<tileWidth; i++){
			//if((selected[index]&4)){  // || selected[index]==1)
				//backbuffer.RectFillAlpha(i<<3,j<<3,8,8,gkRGB(255,255,255),0x80);
			//}
			//index++;
		//}
	//}

	backbuffer.BlitScale(&displayBuffer,0,0,magnification,0);

	//draw the palette number each tile is mapped to
	if(flags & 2){
		index = 0;
		for(j=0; j<tileHeight; j++){
			int y = (j*mag) >> 8;
			for(i=0; i<tileWidth; i++){
				int x = (i*mag) >> 8;
				int pal = tiles[index].GetPaletteUsed();
				if(pal>=0){
					gfxTiles[TILE_PAL0+pal].Blit(&displayBuffer,x,y);
				}
				index++;
			}
		}
	}

	//draw the grid
	if(showGrid){
		for(j=0; j<tileHeight; j++){
			int y = (((j+1) * mag) >> 8) - 1;
			displayBuffer.Line(0,y,displayWidth-1,y,gkRGB(128,128,128));
		}
		for(i=0; i<tileWidth; i++){
			int x = (((i+1) * mag) >> 8) - 1;
			displayBuffer.Line(x,0,x,displayHeight-1,gkRGB(128,128,128));
		}
	}

	//draw the sprite bounding boxes
	if(flags & 1){
		for(i=numSprites-1; i>=0; i--){
			sprites[i]->DrawFrame(&displayBuffer,magnification);
		}
	}
}

gkWinShape *gbPic::GetDisplayBuffer(int showSprites){
	if(needsRedraw){
		needsRedraw = 0;
		Redraw(showSprites);
	}

	return &displayBuffer; 
}

gkWinShape *gbPic::GetMagnifiedArea(int x, int y){
	//magnifiedArea.Cls();
	nonPictureBG.Blit(&magnifiedArea, 0, 0, 0);

	if(x<0 || y<0 || x>=displayWidth || y>=displayHeight 
		 || !backbuffer.GetData()){
		//draw black frame
	  magnifiedArea.RectFrame(0,0,80,80,gkRGB(0,0,0));
		return &magnifiedArea;
	}

	x = (x<<8) / magnification;
	y = (y<<8) / magnification;

	x = (x * 0x1000) >> 8;
	y = (y * 0x1000) >> 8;
  backbuffer.BlitScale(&magnifiedArea,-x + 32, -y + 32, 0x1000, 0);

	//draw green highlight box around pixel under cursor
	//magnifiedArea.RectFrame(32,32,16,16,gkRGB(128,255,128));
	gfxTiles[TILE_BORDER].Blit(&magnifiedArea,32,32);

	//draw black border around whole thing
	magnifiedArea.RectFrame(0,0,80,80,gkRGB(0,0,0));

	return &magnifiedArea;
}


void gbPic::SetMagnification(int n){
	int width = tileWidth * 8;
	int height = tileHeight * 8;

	int sx = GetSystemMetrics(SM_CXSCREEN) - (224 + 32);
	int sy = GetSystemMetrics(SM_CYSCREEN) - 128;

  //reduce magnification until image is <= width & height of screen
	while(width * n > (sx << 8)){
		if(n > 0x200) n -= 0x100;
		else          n -= 0x10;
	}

	while(height * n > (sy << 8)){
		if(n > 0x200) n -= 0x100;
		else          n -= 0x10;
	}

	width = (width * n) >> 8;
	height = (height * n) >> 8;

	if(width > displayWidth || height > displayHeight){
		displayBuffer.Create(width, height);
	}

	displayWidth = width;
	displayHeight = height;
	magnification = n;
}

gkRGB gbPic::GetColor(int pal, int n){ 
	return palettes[pal*4+n]; 
}

void  gbPic::SetColor(int pal, int n, gkRGB c){
	palettes[pal*4+n] = c; 

	int palChanged = (1<<pal);
	int i;
	for(i=0; i<totalTiles; i++){
		needsRedraw |= tiles[i].OnPaletteChange(palChanged);
	}
	for(i=0; i<numSprites; i++){
		sprites[i]->CreateFromRawData();
		sprites[i]->MakeRawData();
	}
}

//  Returns:  1 if tile index is selected, 0 if not or out of bounds
int   gbPic::GetSelected(int i, int j){
	if(i<0 || j<0 || i>=tileWidth || j>=tileHeight) return 0;
	return selected[j*tileWidth + i];
}

void  gbPic::GetIndicesAtPoint(int x, int y, int &i, int &j){
	//get unmagnified pixel coords
	x = (x<<8) / magnification;  
	y = (y<<8) / magnification;

	//divide by 8 to get tile indices
	i = x >> 3;
	j = y >> 3; 

	if(i<0 || j<0 || i>=tileWidth || j>=tileHeight){
		i = j = -1;
	}
}


gkRGB gbPic::GetColorAtPoint(int x, int y){
	//get unmagnified pixel coords
	x = (x<<8) / magnification;  
	y = (y<<8) / magnification;

	if(x<0 || x<0 || x>=pixelBuffer.GetWidth() || y>=pixelBuffer.GetHeight()){
		return gkRGB(0,0,0);
	}

	return pixelBuffer.Point(x,y);
}


int gbPic::GetMappingAtPoint(int x, int y){
	//get unmagnified pixel coords
	x = (x<<8) / magnification;  
	y = (y<<8) / magnification;

	//divide by 8 to get tile indices
	int i = x >> 3;
	int j = y >> 3; 

	if(i<0 || j<0 || i>=tileWidth || j>=tileHeight){
		return -1;
	}

	return tiles[j*tileWidth+i].GetPaletteUsed();
}



void  gbPic::OnMouseLMB(int x, int y){
	int i,j;

	GetIndicesAtPoint(x,y,i,j);
	if(i==-1) return;

	//set selection to "set" if *all* pixels in selectionBuffer
	//have alpha 255, "clear" otherwise.
//static int times=1;
//if(times++ == 2){
//ASSERT(0);
//}

	x = i<<3;
	y = j<<3;
	int sel = 0, ii, jj;
	for(jj=y+7; jj>=y; jj--){
		gkRGB *data = (gkRGB*) selectionBuffer.GetData();
		data += jj*selectionBuffer.GetWidth() + x + 7;
		for(ii=x+7; ii>=x; ii--){
			if(data->GetA()!=255){
				sel = 1;
				break;
			}
			data--;
		}
		if(sel==1) break;
	}
	dragSetOrClear = 1 - sel;

	//if(GetSelected(i,j)){
		//already highlighted, so clear it
		//dragSetOrClear = 0;
	//}else{
		//dragSetOrClear = 1;
	//}

	int index = j*tileWidth + i;
	//if(selected[index] != dragSetOrClear){
	selected[index] = dragSetOrClear;
	needsRedraw = 1;
	//}

	dragStart_i = i;
	dragStart_j = j;
}

void  gbPic::OnMouseLDrag(int x, int y){
	int i1,j1,i2,j2; 
	GetIndicesAtPoint(x,y,i2,j2);
	if(i2==-1) return;

	if(i2 > dragStart_i) i1 = dragStart_i;
	else{
		i1 = i2;
		i2 = dragStart_i;
	}

	if(j2 > dragStart_j) j1 = dragStart_j;
	else{
		j1 = j2;
		j2 = dragStart_j;
	}

	//clear temporary "visual feedback" selected grids
	int i,j,index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			selected[index++] &= 1;
		}
	}

	//create new temp feedback grids
	for(j=j1; j<=j2; j++){
	  for(i=i1; i<=i2; i++){
	    index = j*tileWidth + i;
			selected[index] |= ((dragSetOrClear+1)<<1);
		}
	}
	needsRedraw = 1;
}

void  gbPic::OnMouseLRelease(int x, int y){
	int i1,j1,i2,j2; 
	GetIndicesAtPoint(x,y,i2,j2);
	if(i2==-1) return;

	//clear temporary "visual feedback" selected grids
	int i,j,index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			selected[index++] &= 1;
		}
	}

	if(i2 > dragStart_i) i1 = dragStart_i;
	else{
		i1 = i2;
		i2 = dragStart_i;
	}

	if(j2 > dragStart_j) j1 = dragStart_j;
	else{
		j1 = j2;
		j2 = dragStart_j;
	}

	//select permanent 
	//ASSERT(0);
	numSelColors = 0;
	for(j=j1; j<=j2; j++){
	  for(i=i1; i<=i2; i++){
	    index = j*tileWidth + i;
			selected[index] = dragSetOrClear;
			if(dragSetOrClear){
				//set
			  selectionBuffer.RectFill(i<<3,j<<3,8,8,gkRGB(255,255,255,0x80));
				int numPixels = 64;
				gkRGB *colors = (gkRGB*) tiles[index].GetData();
				while(numPixels--){
					gkRGB c = *(colors++);
					int sel, found=0;
					for(sel=0; sel<numSelColors; sel++){
            if(selectedColors[sel]==c){
              found = 1;
              break;
            }
					}
          if(found) continue;

					//make bgcolor the first color if selecting a whole tile
					if(c==bgColor){
						selectedColors[numSelColors++] = selectedColors[0];
						selectedColors[0] = c;
					}else{
					  selectedColors[numSelColors++] = c;
					}
				}
			}else{
				//clear
			  selectionBuffer.RectFill(i<<3,j<<3,8,8,gkRGB(0,0,0,255));
			}
		}
	}

	//count total # of selected tiles
	numSelTiles = 0;
	for(i=0; i<totalTiles; i++){
		if(selected[i]) numSelTiles++;
	}
	needsRedraw = 1;
}

void  gbPic::SetFirstColor(gkRGB c){
	int i;
	for(i=0; i<numSelColors; i++){
		RemoveColor(selectedColors[i]);
	}
	numSelColors = 0;
	AddNextColor(c);
}

void  gbPic::AddNextColor(gkRGB c){
	selectionBuffer.BlitChannel(&pixelBuffer,0,0,0xff000000);  //copy alpha only
	pixelBuffer.SetColorAlpha(c,0x80);                //add new info
	pixelBuffer.BlitChannel(&selectionBuffer,0,0,0xff000000);   //copy back

  int i;
	//mark as "selected" any tiles containing the color
	for(i=0; i<totalTiles; i++){
		if(tiles[i].HasColor(c)) selected[i] = 1;
	}
	
	//see if the color is already in the selected color set
	for(i=0; i<numSelColors; i++){
		if(selectedColors[i]==c) return;
  }

	//add it if need be
	if(c==bgColor){
		selectedColors[numSelColors++] = selectedColors[0];
		selectedColors[0] = c;
	}else{
		selectedColors[numSelColors++] = c;
	}
}

void gbPic::RemoveColor(gkRGB c){
	int i;
	selectionBuffer.BlitChannel(&pixelBuffer,0,0,0xff000000);
	pixelBuffer.SetColorAlpha(c,255);
	pixelBuffer.BlitChannel(&selectionBuffer,0,0,0xff000000);
	for(i=0; i<numSelColors; i++){
		if(selectedColors[i]==c){
			numSelColors--;
			for(; i<numSelColors; i++) 
				selectedColors[i] = selectedColors[i+1];
			return;
		}
	}
}

void  gbPic::ClearSelection(){
	int i,j,index;
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			selected[index++] = 0;
		}
	}
	selectionBuffer.RectFill(0,0,tileWidth<<3,tileHeight<<3,gkRGB(0,0,0,255));

	numSelColors = 0;
	numSelTiles = 0;
	needsRedraw = 1;
}

void  gbPic::RemapSelectedToBGColor(){
	int i,j;
	for(i=0; i<numSelColors; i++){
		gkRGB color = selectedColors[i];
		for(j=0; j<totalTiles; j++){
      tiles[j].RemapColor(color,bgColor);
		}
	}
	needsRedraw = 1;
}

void  gbPic::SwapSelectedWithBGColor(){
	int i,j;
	for(i=numSelColors-1; i>=0; i--){
		gkRGB color = selectedColors[i];
		for(j=0; j<totalTiles; j++){
      tiles[j].ExchangeColors(color,bgColor);
		}
	}
	needsRedraw = 1;
}

//  Arguments:  palettes - set of flags for palettes to use.
//                         Uses 0-7 (BG palettes) only.
void  gbPic::AutoMapToPalette(int palettes){
	int i, palNum, anySelected;

	anySelected = 0;
	for(i=0; i<totalTiles; i++){
		if(selected[i]){
			anySelected = 1;
			break;
		}
	}

	for(palNum=0; palNum < 8; palNum++){
		if(palettes & (1 << palNum)){
			for(i=0; i<totalTiles; i++){
				if(!anySelected || selected[i]){
					if(tiles[i].GetPaletteUsed()==-1){
						if(tiles[i].TestMatch(GetPalette(palNum))==0){
							tiles[i].UsePalette(palNum,GetPalette(palNum));
							needsRedraw = 1;
						}
					}
				}
			}
		}
	}
}


void  gbPic::MapToPalette(int palettes){
	int i, palNum, anySelected;

	anySelected = 0;
	for(i=0; i<totalTiles; i++){
		if(selected[i]){
			anySelected = 1;
			break;
		}
	}

	for(i=0; i<totalTiles; i++){
		if(!anySelected || selected[i]){
			if(tiles[i].GetPaletteUsed()==-1){
				int bestIndex = 0;
				int bestMatch = 0xffff;
				for(palNum=0; palNum < 8; palNum++){
					if(palettes & (1 << palNum)){
						int match = tiles[i].TestMatch(GetPalette(palNum));
						if(match < bestMatch){
							bestIndex = palNum;
							bestMatch = match;
						}
					}
				}
				tiles[i].UsePalette(bestIndex,GetPalette(bestIndex));
				needsRedraw = 1;
			}
		}
	}
}

void gbPic::Unmap(){
	int i, anySelected;

	anySelected = 0;
	for(i=0; i<totalTiles; i++){
		if(selected[i]){
			anySelected = 1;
			break;
		}
	}

	for(i=0; i<totalTiles; i++){
		if(!anySelected || selected[i]){
			tiles[i].OnColorChange();
		}
	}
	needsRedraw = 1;
}

void gbPic::SelectNonEmpty(){
	int i,j,index;
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			if(tiles[index].GetColorsUsed()>1 || 
					tiles[index].GetColors()[0]!=bgColor){
				if(!selected[index]) numSelTiles++;
				selected[index] = 1;
			  selectionBuffer.RectFill(i<<3,j<<3,8,8,gkRGB(255,255,255,0x80));
	      needsRedraw = 1;
			}
			index++;
		}
	}
}


void gbPic::SelectUnmapped(){
	int i,j,index;
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			if(tiles[index].GetPaletteUsed()==-1){
				if(!selected[index]) numSelTiles++;
				selected[index] = 1;
			  selectionBuffer.RectFill(i<<3,j<<3,8,8,gkRGB(255,255,255,0x80));
	      needsRedraw = 1;
			}
			index++;
		}
	}
}


//////////////////////////////////////////////////////////////////////
//  Function:     MakeSprites
//  Description:  Lifts any selected colors to form a metasprite
//                composed of 8x16 sprites.  Replaces the area
//                underneath with the bg color.  Sprites are always
//                aligned on the 8-pixel boundaries of the tiles
//                they came from
//////////////////////////////////////////////////////////////////////
void gbPic::MakeSprites(){
	int i,j;

	//loop top-to-bottom for each column.  The first tile that has
	//selected pixels will be the top of an 8x16 sprite part. 
	for(i=0; i<tileWidth; i++){
		for(j=0; j<tileHeight; j++){
			if(numSprites>=40) return;
			int myIndex = j*tileWidth + i;
			int nextIndex = (j+1)*tileWidth + i;
      gbTile *tile1 = &tiles[myIndex];
			if(selected[myIndex]){
				selected[myIndex] = 0;

				//extract the tile
				gbTile *tile2;
				if(j == tileHeight-1 || !selected[nextIndex]){
					//no tile below or not selected
					tile2 = 0;
				}else{
					tile2 = &tiles[nextIndex];
					if(tile2->GetPaletteUsed() != tile1->GetPaletteUsed()){
						tile2 = 0;
					}else{
					  selected[nextIndex] = 0;
					}
				}
        sprites[numSprites] = new gbSprite();
				sprites[numSprites]->Create8x16FromSelection(i<<3,j<<3,
						tile1, tile2, &selectionBuffer, this);
				numSprites++;
			}
		}
	}
				
	needsRedraw = 1;
}

int gbPic::FindBestSpritePalette(gkRGB *pal, int numColors){
	return 0;
}

int gbPic::UnmakeSprite(int x, int y){
	int i2,j2; 
	GetIndicesAtPoint(x,y,i2,j2);
	if(i2==-1) return 0;

	int i;
	for(i=numSprites-1; i>=0; i--){
    if(sprites[i]->ExistsAtIndex(i2,j2)){
			sprites[i]->Unmake(this);
			delete sprites[i];
			numSprites--;
			for(; i<numSprites; i++){
				sprites[i] = sprites[i+1];
			}
			needsRedraw = 1;
			return 1;
		}
	}
	return 0;
}

void gbPic::SavePaletteInfo(ostream &out){
	// BYTE:  nColors # of palette colors following (4,8,12...)
	// REPT[nColors]:   PALETTE DATA (Total of 3 * numColors bytes)
	// 			BYTE  Write specification flags (store in $ff6a)
	// 			BYTE  Lower byte of color (store in $ff6b after storing
	// 						the write spec flags)
	// 			BYTE  Upper byte of color
	int i,numPalettes=0;
	for(i=0; i<8; i++){
		if(GetColor(i,0).GetA()!=0) numPalettes++;
	}

	int numColors = numPalettes * 4;
	out.put((char) numColors);
	int pal, entry, index;
	index = 0;
	for(pal=0; pal<8; pal++){
		if(palettes[index].GetA()==0){   //skip unused palettes
			index+=4;
			continue;
		}
		for(entry=0; entry<4; entry++){
			int spec = 128 | (pal<<3) | (entry<<1);
			out.put((char) spec);

			gkRGB color = palettes[index];
			int r = (color.GetR() >> 3) & 31;
			int g = (color.GetG() >> 3) & 31;
			int b = (color.GetB() >> 3) & 31;
			int gbColor = (b<<10) | (g<<5) | r;
			out.put((char) (gbColor & 0xff));
			out.put((char) ((gbColor>>8) & 0xff));
			index++;
		}
	}

}

void gbPic::SaveGBSprite(const char *filename){

	ofstream out(filename,ios::out|ios::binary);
	if(!out) return;

	int numTiles = numSprites * 2;     //will be 80 max
	int i;

	// BYTE  Bank 0 Sprite definition data exists (!0 = true)
	// 				BYTE  Number of sprite patterns (0 = 256)  
	// 				REPT[number of defined sprites]
	// 							BYTE[16]  sprite data
	out.put((char) (numTiles!=0));
	if(numTiles>0){
	  out.put((char) (numTiles));
	  for(i=0; i<numSprites; i++){
			sprites[i]->WriteTileDefinitions(out);
		}
	}


  // BYTE  Bank 1 Sprite definition data exists (!0 = true)
	out.put((char) 0);    //no bank 1 sprites

	//width & height
	out.put((char) tileWidth);
	out.put((char) 0);            //store zero for pitch
	out.put((char) tileHeight);

	//sprite instances (composing metasprite)
	// BYTE  numSprites
	// REPT[numSprites]:  SPRITE ATTRIBUTE DATA (Copy to spriteOAMBuffer)
	out.put((char) numSprites);
	for(i=0; i<numSprites; i++){
		sprites[i]->WriteAttributes(out,i);
	}

	SavePaletteInfo(out);

	fileSize = (int) out.tellp();

	out.close();
}


int gbPic::LoadGBSprite(const char *filename){
	ifstream in(filename, ios::in | ios::binary | ios::nocreate);
	if(!in) return 0;

	Reset();

	int hasBank0 = in.get();
	if(!hasBank0) return 1;

	int numTileDefs = in.get();
	numSprites = numTileDefs / 2;

	int i;
	for(i=0; i<numSprites; i++){
		sprites[i] = new gbSprite();
		sprites[i]->ReadTileDefinitions(in);
	}

	in.get();    //discard bank 1 definitions exist

	tileWidth = in.get() & 0xff;
	in.get();
	tileHeight = in.get() & 0xff;

	//Set up buffers
	int pixelWidth = tileWidth << 3;
	int pixelHeight = tileHeight << 3;
	totalTiles = tileWidth * tileHeight;
	SetMagnification(0x400);       //default 4x magnification

	backbuffer.Create(pixelWidth, pixelHeight);
	pixelBuffer.Create(pixelWidth, pixelHeight);
	selectionBuffer.Create(pixelWidth, pixelHeight);
	displayBuffer.Create(displayWidth, displayHeight);

	displayBuffer.Cls(gkRGB(0,0,0xf8));
	selectionBuffer.SetAlpha(255);

	int j,index;
	selected = new int[totalTiles];
	for(i=0; i<totalTiles; i++) selected[i] = 0;

	tiles = new gbTile[totalTiles];
	index = 0;
	for(j=0; j<tileHeight; j++){
		for(i=0; i<tileWidth; i++){
			tiles[index].GetShape(&displayBuffer, i<<3, j<<3, 8, 8);
			index++;
		}
	}
	displayBuffer.Cls(gkRGB(0,0,0xf8));

	in.get();   //discard, already have num sprites
  for(i=0; i<numSprites; i++){
		sprites[i]->ReadAttributes(in,this);
	}

	//read palette
	int numColors = in.get() & 0xff;
	for(i=0; i<numColors; i++){
		int spec = in.get();
		int pal = (spec >> 3) & 7;
		int entry = (spec >> 1) & 3;
		int gbColor = in.get() & 0xff;
    gbColor = ((in.get() & 0xff) << 8) | gbColor;
		int r = (gbColor & 31)       << 3;
		int g = ((gbColor>>5) & 31)  << 3;
		int b = ((gbColor>>10) & 31) << 3;
		palettes[pal*4 + entry] = gkRGB(r,g,b);
	}

	for(i=0; i<numSprites; i++){
		sprites[i]->CreateFromRawData();
	}

	needsRedraw = 1;

	in.close();
	return 1;
}

void  gbPic::SaveGBPic(const char *filename){
	ofstream out(filename,ios::out|ios::binary);
	if(!out) return;

	ClearSelection();
	AutoMap(255);

	out.put((char) 1);   //bank 0 exists
	out.put((char) 0);   //allocate space for numBank0Tiles

	gkBYTE rawData[512*16];
  int    dataHash[512];
	int    numUnique = 0;

	//Write out blank tile definition as tile zero
	int i;
  for(i=0; i<16; i++){
    out.put((char) 0);
    rawData[i] = 0;
  }
	dataHash[numUnique++] = 0;

	//write out tile definitions, avoiding duplicates
	int bank1Pos = 0;
	int index;
	for(i=0; i<totalTiles; i++){
    if(tiles[i].GetPaletteUsed()==-1) tiles[i].SetPaletteUsed(this,0);
		tiles[i].SetTileIndex(numUnique);
		tiles[i].MakeRawData(this);

		//look for existing hash to quickly dicard non-possibilities
		int hash = tiles[i].GetDataHash();
		int found = 0;
		for(index=0; index<numUnique; index++){
			if(dataHash[index] == hash){
				//found a rough match, take a closer look
				if(tiles[i].CompareRawData(&rawData[index<<4])==1){
					//found an exact match!
					tiles[i].SetTileIndex(index);
					found = 1;
					break;
				}
			}
		}

		if(!found){
			//unique tile!  Add to hash table & write to file
			if(numUnique==256){
				//written out max tiles for bank 0, put info about bank 1
				//& spot for numTiles
				out.put((char) 1);   //bank 1 exists
				bank1Pos = (int) out.tellp();
				out.put((char) 0);   //spot for # of bank 1 tiles
			}

      tiles[i].CopyRawDataTo(&rawData[numUnique<<4]);
			dataHash[numUnique] = hash;
			tiles[i].WriteRawData(out);

			numUnique++;
		}
	}

	numUniqueTiles = numUnique;

	//written out all unique defs.  Fill in info about how many bank0
	//and bank1 tiles
	int curFilePos = (int) out.tellp();
	out.seekp(1);
	if(numUnique<256) out.put((char) numUnique);
	else             out.put((char) 0);

	if(bank1Pos>0){
	  out.seekp(bank1Pos);
		out.put((char) (numUnique - 256));
	  out.seekp(curFilePos);
	}else{
	  out.seekp(curFilePos);
		out.put((char) 0);    //no bank 1 tiles
	}

	int tilePitch = 1;
	while(tilePitch < tileWidth) tilePitch<<=1;

	out.put((char) tileWidth);
	//out.put((char) tilePitch);
	out.put((char) tileHeight);

	//write out tile index data
	for(i=0; i<totalTiles; i++){
		index = tiles[i].GetTileIndex();
		if(index<256){
			out.put((char) index);
		}else{
			out.put((char) (index-256));
		}
	}

	//write out tile attributes (palettes) used, 2 per byte
	for(i=0; i<totalTiles; i++){
		index = tiles[i].GetTileIndex();
		int attr1 = tiles[i].GetPaletteUsed();
		if(index>=256) attr1 |= 8;
		i++;

		index = tiles[i].GetTileIndex();
		int attr2 = tiles[i].GetPaletteUsed();
		if(index>=256) attr2 |= 8;

		out.put((char) ((attr1<<4) | attr2));
	}

	SavePaletteInfo(out);

	fileSize = (int) out.tellp();

	out.close();
}

int   gbPic::LoadGBPic(const char *filename){
	ifstream in(filename, ios::in | ios::binary | ios::nocreate);
	if(!in) return 0;

	Reset();

	int i;
	gkBYTE rawData[1024*16];   //twice as much as max

	int hasBank0 = in.get();
	if(!hasBank0) return 1;

	int numBank0 = in.get();
	if(!numBank0) numBank0 = 256;
	in.read(rawData,numBank0*16);

	int numBank1 = 0;
	int hasBank1 = in.get();
	if(hasBank1){
		numBank1 = in.get();
	  if(!numBank1) numBank1 = 256;
		in.read(rawData + numBank0*16, numBank1*16);
	}

	tileWidth = in.get();
	tileHeight = in.get();
	totalTiles = tileWidth * tileHeight;

	//Set up buffers
	int pixelWidth = tileWidth << 3;
	int pixelHeight = tileHeight << 3;
	SetMagnification(0x400);       //default 4x magnification

	backbuffer.Create(pixelWidth, pixelHeight);
	pixelBuffer.Create(pixelWidth, pixelHeight);
	selectionBuffer.Create(pixelWidth, pixelHeight);
	displayBuffer.Create(displayWidth, displayHeight);

	displayBuffer.Cls(gkRGB(0,0,0xf8));
	selectionBuffer.SetAlpha(255);

	selected = new int[totalTiles];
	for(i=0; i<totalTiles; i++) selected[i] = 0;

	tiles = new gbTile[totalTiles];
	displayBuffer.Cls(gkRGB(0,0,0xf8));

	//read tile indices
	for(i=0; i<totalTiles; i++){
		tiles[i].SetTileIndex(in.get());
	}

	//read attributes (palette + bank0/1 info) (2 per byte)
	for(i=0; i<totalTiles; i++){
		int combo = in.get();
		int attr1 = (combo>>4) & 15;
		int attr2 = combo & 15;
		if(attr1 & 8) tiles[i].SetRawData(
				rawData+numBank0*16+tiles[i].GetTileIndex()*16);
		else tiles[i].SetRawData(rawData + tiles[i].GetTileIndex()*16);
		tiles[i].SetPaletteUsed(this, attr1 & 7);
		i++;

		if(attr2 & 8) tiles[i].SetRawData(
				rawData+numBank0*16+tiles[i].GetTileIndex()*16);
		else tiles[i].SetRawData(rawData + tiles[i].GetTileIndex()*16);
		tiles[i].SetPaletteUsed(this, attr2 & 7);
	}

	//read palette
	int numColors = in.get() & 0xff;
	for(i=0; i<numColors; i++){
		int spec = in.get();
		int pal = (spec >> 3) & 7;
		int entry = (spec >> 1) & 3;
		int gbColor = in.get() & 0xff;
    gbColor = ((in.get() & 0xff) << 8) | gbColor;
		int r = (gbColor & 31)       << 3;
		int g = ((gbColor>>5) & 31)  << 3;
		int b = ((gbColor>>10) & 31) << 3;
		palettes[pal*4 + entry] = gkRGB(r,g,b);
	}

	for(i=0; i<totalTiles; i++){
		tiles[i].CreateFromRawData(this);
	}

	needsRedraw = 1;
	
	in.close();
	return 1;
}

void gbPic::AutoMap(int usePalettes){
	//if palette zero empty then set its first color to be black
	if(palettes[0].GetA()==0){
		palettes[0] = gkRGB(0,0,0);
	}

	ClearSelection();
	AutoMapToPalette(255);

	//At this point any tiles without palettes cannot be defined using
	//an existing palette.  Try to fill in blank palettes appropriately

	//Count the number of available colors in each palette
	int i,j;
	int colorsAvailable[8], colorsUsed[8];
	for(i=0; i<8; i++){
		int num = 0;
		for(j=0; j<4; j++){
			if(GetColor(i,j).GetA()==0) num++;
		}
		colorsAvailable[i] = num;
		colorsUsed[i] = 4 - num;
	}

	for(int t=0; t<totalTiles; t++){
		if(tiles[t].GetPaletteUsed()==-1){
			int numUnmatchedColors[8];

			for(i=0; i<8; i++) numUnmatchedColors[i] = tiles[t].GetColorsUsed();

			gkRGB *pal = tiles[t].GetColors();
			int num = tiles[t].GetColorsUsed();
			for(int p=0; p<8; p++){
				for(j=0; j<colorsUsed[p]; j++){
					for(i=0; i<num; i++){
						if(pal[i]==GetColor(p,j)){
							numUnmatchedColors[p]--;
							break;
						}
					}
				}
			}

			//find best palette to add to
			int bestIndex = 0;
			int bestRating = 0;
			for(i=0; i<8; i++){
				int rating = 0;
				if(colorsUsed[i] + numUnmatchedColors[i] <= 4){
					rating += 100;
					rating += colorsUsed[i] * 10;
				}
				if(rating > bestRating){
					bestIndex = i;
					bestRating = rating;
				}
			}

      if(bestRating>0){
        //add new colors to that palette
        for(i=0; i<num; i++){    //for each color in this tile...
          int exists = 0;
          for(j=0; j<colorsUsed[bestIndex]; j++){  //does it exist already?
            if(GetColor(bestIndex,j)==pal[i]) exists = 1;
          }
          if(!exists && j<4){   //add it if not
            palettes[bestIndex*4 + j] = pal[i];
            colorsUsed[bestIndex]++;
            colorsAvailable[bestIndex]--;
          }
        }
        
        tiles[t].SetPaletteUsed(this,bestIndex);
        AutoMapToPalette(1 << bestIndex);
      }
		}
	}

	needsRedraw = 1;
}

