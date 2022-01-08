// MapWin.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "MapWin.h"
#include "Controls.h"
#include "ChildView.h"
#include <strstrea.h>
#include <fstream.h>
#include "MainFrm.h"
#include <iomanip.h>


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "ChildView.h"
#include "Controls.h"
#include "WayPointList.h"


/////////////////////////////////////////////////////////////////////////////
// CMapWin

CMapWin::CMapWin()
{

	// Member initializations
	showGrids = false;
	backgroundColor = 0x808080;
	gridColor = 0x0000ff;
	curTile = 0;
	for(int i=0;i<256;i++)
		for(int j=0;j<256;j++)
			envArray[i][j].index = 0;

	totalTilesUsed = 1;
	for(i=0;i<=256;i++)
		listOfTilesUsed[i] = -1;
	for(i=0;i<65536;i++)
		listOfAllTiles[i] = 0;

  lmb_isDown = rmb_isDown = 0;
  drawingPath = 0;
  selectedZone = 1;
  pathStartX = pathStartY = 0;

  clearLevel();

  gkWinShape buffer;
  buffer.LoadBMP("exitTiles.bmp");
  for(i=0; i<7; i++){
    exitTiles[i+1].GetShape(&buffer,i*16,0,16,16);
    exitTiles[i+1].SetAlpha(192);
  }
  copyWidth = copyHeight = 0;
}

CMapWin::~CMapWin()
{	
}


BEGIN_MESSAGE_MAP(CMapWin, CWnd)
	//{{AFX_MSG_MAP(CMapWin)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_ERASEBKGND()
	ON_WM_RBUTTONDOWN()
	ON_WM_SIZE()
	ON_WM_HSCROLL()
	ON_WM_VSCROLL()
	ON_WM_LBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_WM_RBUTTONUP()
	ON_WM_KEYDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CMapWin message handlers

void CMapWin::OnPaint() 
{
	//MODIFIED 12.30.1999 ABE
	CPaintDC realdc(this); // device context for painting

    //get client window size MOVED 12.30.1999 ABE
	CRect rect;
	::GetClientRect(this->m_hWnd,&rect);

	//NEW 12.30.1999 ABE
	//variables for double-buffering 
	//static CBitmap backbuffer;
	static int backbufferWidth=0, backbufferHeight=0, needSetup=1;
  static gkWinShape tileBuffer;
  static gkWinShape wayPoint;

  if(needSetup){
    //Create orange dot waypoint
    needSetup = 0;
    wayPoint.Create(16,16);
    wayPoint.Cls();
    wayPoint.RectFill(5,5,6,6,gkRGB(255,128,0));
    wayPoint.SetColorAlpha(gkRGB(0,0,0), 0);
  }

	//check to see if we need to (re)create bitmap
	if(backbufferWidth < rect.Width() || backbufferHeight < rect.Height()){
		backbufferWidth = rect.Width();
		backbufferHeight = rect.Height();
		//if(backbuffer.GetSafeHandle() != 0){
		//	backbuffer.DeleteObject();
		//}
		//backbuffer.CreateCompatibleBitmap(&realdc, backbufferWidth, backbufferHeight);
    tileBuffer.Create(backbufferWidth, backbufferHeight);
	}

	//create a temporary device context & select the bitmap into it for drawing
	//CDC dc;
	//dc.CreateCompatibleDC(0);
	//CBitmap *oldBitmap = (CBitmap*) dc.SelectObject(&backbuffer);
	//END NEW

  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();
	
  // how many tiles by X?
	int numX;
	//how many tiles by Y?
	int numY;

	numX = (rect.Width()>>4) + 1;
	numY = (rect.Height()>>4) + 1;

  //see how far the screen is scrolled over
  int tileOff_x = controls->GetOffsetX() >> 4;
  int tileOff_y = controls->GetOffsetY() >> 4;

	//dc.FillSolidRect(0,0, rect.Width(), rect.Height(), backgroundColor);
  tileBuffer.Cls(gkRGB(backgroundColor&0xff,(backgroundColor>>8)&0xff,
    (backgroundColor>>16)&0xff));

  //figure out how far to scoot each tile to the left because of scrolling
  int pixOff_x = controls->GetOffsetX() & 15;
  int pixOff_y = controls->GetOffsetY() & 15;

  

	//go ahead and draw the environment tiles

  //blit all the tiles to the tile backbuffer (to allow for transparency etc)
  //then blit the tile backbuffer to the regular backbuffer
  for(int i=0;i<numX;i++){
    for(int j=0;j<numY;j++){
      int ti = i+tileOff_x;
      int tj = j+tileOff_y;

      if(ti<0 || tj<0 || ti>=controls->GetMapWidth() || tj>=controls->GetMapHeight()){
        continue;
      }

      int dx = (i<<4)-pixOff_x;
      int dy = (j<<4)-pixOff_y;

      if(controls->GetDrawingZones()==-1){
        if(envArray[i+tileOff_x][j+tileOff_y].index){
				  //envArray[i+tileOff_x][j+tileOff_y].pic->
          //BlitToDC(&dc,(i<<4)-pixOff_x,(j<<4)-pixOff_y);
          envArray[ti][tj].pic->Blit(&tileBuffer, dx, dy, 0);
        }

        if(controls->GetDrawingExits()>0){  //overlay exit if necessary
          if(exitArray[ti][tj]) 
            exitTiles[exitArray[ti][tj]].Blit(&tileBuffer,dx,dy);
        }else{
          //flag too much open space
          if(tooMuchOpenSpace[i+tileOff_x][j+tileOff_y]==1){
            tileBuffer.RectFillAlpha(dx, dy, 16, 16, gkRGB(128,0,0), 128);
          }
        }
      }else{
        if(envArray[i+tileOff_x][j+tileOff_y].index){
				  //envArray[i+tileOff_x][j+tileOff_y].pic->
          //BlitToDC(&dc,(i<<4)-pixOff_x,(j<<4)-pixOff_y);
          envArray[ti][tj].pic->BlitHalfBrite(&tileBuffer, dx, dy, 0);
        }

        //blit the zone if necessary
        if(controls->GetDrawingZones()>-1){
          int color = CZoneList::GetZoneColor(zoneArray[ti][tj]);
          //tileBuffer.RectFillAlpha(dx, dy, 16, 16, gkRGB(0,0,0), 128);
          int r= color & 0xff;
          int g = (color>>8) & 0xff;
          int b = (color>>16) & 0xff;
          tileBuffer.RectFillAlpha(dx, dy, 16, 16, gkRGB(r,g,b), 128);
        }

      }


    }
  }

  //draw WayPoints
  if(controls->GetDrawingZones()>-1){
    int nPoints = g_wayPointList.GetNumWayPoints();

    int n;
    for(n=1; n<=nPoints; n++){
      int p = g_wayPointList.GetWayPoint(n);
      
      int i = p & 0xff;
      int j = (p>>8) & 0xff;
      int dx = (i<<4) - controls->GetOffsetX();
      int dy = (j<<4) - controls->GetOffsetY();
      wayPoint.Blit(&tileBuffer, dx, dy);
    }
  }

  // show grids if showGrids is true
	if(showGrids){

		//CPen gridPen;
		//if(!gridPen.CreatePen(PS_SOLID,1,gridColor))
		//{
		//	//doh!
		//	::AfxMessageBox("Pen Creation Failed drawing grids", MB_OK);
		//	::AfxAbort();
		//}

    gkRGB lineColor;
    lineColor.SetR(gridColor & 0xff);
    lineColor.SetG((gridColor>>8) & 0xff);
    lineColor.SetB((gridColor>>16) & 0xff);

		//save the old pen
		//CPen* oldPen = dc.SelectObject(&gridPen);

    int off_x = controls->GetOffsetX();
    int off_y = controls->GetOffsetY();

	  //draw vertical lines
	  for(int i=0;i<(controls->GetMapWidth() + 1);i++)
	  {
      tileBuffer.Line((i<<4)-off_x,0,(i<<4)-off_x,rect.Height(),lineColor);
		//dc.MoveTo((i<<4)-off_x,0);
		//dc.LineTo((i<<4)-off_x,rect.Height());
	  }
	  //draw Horizontal lines
	  for(i=0;i<(controls->GetMapHeight() + 1);i++)
	  {
      tileBuffer.Line(0,(i<<4)-off_y,rect.Width(),(i<<4)-off_y,lineColor);
		//dc.MoveTo(0, (i<<4)-off_y);
		//dc.LineTo(rect.Width(), (i<<4)-off_y);
	  }


	  //reset old pen
	  //dc.SelectObject(oldPen);

	}// end if(showGrids)



  //if we're currently drawing a path then draw just the path so far
  if(drawingPath){
    this->DrawPath(selectedZone, drawingPath, tileBuffer);
  }else{
    //draw all the paths that originate at the selected zone
    if(selectedZone && controls->GetDrawingZones()>-1){
      int otherZone;
      for(otherZone=1; otherZone<16; otherZone++){
        int path = g_wayPointList.GetPath(selectedZone, otherZone);
        if(path){
          this->DrawPath(otherZone, path, tileBuffer);
        }
      }
    }
  }

  //if we're doing a selection rectangle then draw that
  if(drawingRect){
    if(controls->GetDrawingZones()!=0){
      int sx = min(rectStartX,rectEndX)<<4;
      int sy = min(rectStartY,rectEndY)<<4;
      int dx = (max(rectStartX,rectEndX)<<4)+15;
      int dy = (max(rectStartY,rectEndY)<<4)+15;
      sx -= controls->GetOffsetX();
      dx -= controls->GetOffsetX();
      sy -= controls->GetOffsetY();
      dy -= controls->GetOffsetY();
      gkRGB color = gkRGB(255,255,255);
      int curZone = controls->GetDrawingZones();
      if(curZone>0){
        int c = CZoneList::GetZoneColor(curZone);
        color.SetR(c&0xff);
        color.SetG((c>>8)&0xff);
        color.SetB((c>>16)&0xff);
      }
      tileBuffer.RectFillAlpha(sx,sy,(dx-sx)+1, (dy-sy)+1, color, 128);
    }else{
      //moving a waypoint
      int sx = rectStartX<<4;
      int sy = rectStartY<<4;
      int dx = rectEndX<<4;
      int dy = rectEndY<<4;
      sx -= controls->GetOffsetX();
      dx -= controls->GetOffsetX();
      sy -= controls->GetOffsetY();
      dy -= controls->GetOffsetY();
      gkRGB color = gkRGB(255,255,255);
      tileBuffer.Line(sx+7,sy+7,dx+7,dy+7,color);
      wayPoint.Blit(&tileBuffer, dx, dy);
    }
  }

  tileBuffer.BlitToDC(&realdc, 0, 0);


	//NEW 12.30.1999 ABE
	//Blit the backbuffer to the screen
	//realdc.BitBlt(0,0,rect.Width(), rect.Height(), &dc, 0, 0, SRCCOPY);

	//take bitmap out of temporary DC before the tempDC is destroyed
	//dc.SelectObject(oldBitmap);
	//END NEW

	// Do not call CWnd::OnPaint() for painting messages
}

void CMapWin::SetGrids(bool on){
	showGrids = on;
	this->InvalidateRect(0);
}


BOOL CMapWin::OnEraseBkgnd(CDC* pDC) 
{
	// TODO: Add your message handler code here and/or call default
	return true;

	//return CWnd::OnEraseBkgnd(pDC);
}


int CMapWin::getBackgroundColor(){
	return backgroundColor;
}


void CMapWin::setBackgroundColor(int color)
{
	backgroundColor = color;
}

void CMapWin::setGridColor(int color)
{
	gridColor = color;
}

void CMapWin::getEnvArray(PicStruct arg[256][256])
{
	for(int i=0;i<256;i++)
		for(int j=0;j<256;j++)
			arg[i][j] = envArray[i][j];
}
unsigned char CMapWin::getTotalTilesUsed()
{
	return totalTilesUsed;
}

short int* CMapWin::getListOfTilesUsed()
{
	return listOfTilesUsed;
}

//load a level from the file

void CMapWin::loadLevel(char *str){

	ifstream input(str, ios::in | ios::binary | ios::nocreate);
	//unsigned char trash;//used to through away unnecessary info on reads
	int i;
	CControls *controls;

	controls = (CControls*)(((CChildView*)this->GetParent())->GrabControls());

	if(input.fail()){
		this->MessageBox("Could not open file");
		return;
	}

	//clear the current level
	clearLevel();

	// Member initializations
	showGrids = false;
	curTile = 0;

	int firstCharacterID = (E_TILEBMPSIZEX >> 4) * (E_TILEBMPSIZEY >> 4);

  int version = input.get() & 0xff;
	//------------load in total classes used-----------------------
	input.read(&totalTilesUsed, sizeof(unsigned char));
	totalTilesUsed++;//must add 1 to compensate for 0 index
	//--------------throw away 1rst character index----------------
	int firstCharacterIndex = input.get() & 0xff;
  int oldFirstID = (input.get() & 0xff);
  oldFirstID |= (input.get() & 0xff) << 8;

	//----------------read monster list into listOfTilesUsed-------
  for(i=1;i<totalTilesUsed;i++){
	input.read((char*)&(listOfTilesUsed[i]),sizeof(short int));
	if(i>=firstCharacterIndex){
      listOfTilesUsed[i] += (firstCharacterID - oldFirstID);
    }
  }
	//-------------------set up listOfAllTiles----------------------
	for(i=0;i<256;i++)
		if(listOfTilesUsed[i] != -1)
			listOfAllTiles[listOfTilesUsed[i]] = 1;	
	//----------------read level width-----------------------------
	unsigned char width;
	input.read(&width,sizeof(unsigned char));
  controls->SetMapWidth(width);
	//----------------get pitch-----------------------------
	int pitch = input.get() & 0xff;
  g_wayPointList.SetPitch(pitch);
	//-----------------read level height---------------------------
	unsigned char height;
	input.read(&height,sizeof(unsigned char));
  controls->SetMapHeight(height);
	//-----------------read in level--------------------------------
	for(i=0;i<height;i++)
		for(int j=0;j<width;j++)
		{
			//input.read(&envArray[j][i].index,sizeof(unsigned char));
      int index = input.get() & 0xff;

	  if(listOfTilesUsed[index]==-1) index = 0;  //kludge to fix class -1 bug
      envArray[j][i].index = index;
			if(envArray[j][i].index)
				envArray[j][i].pic = controls->GrabPicAt(listOfTilesUsed[envArray[j][i].index]);
		}
	//-------------------get the backgruond color-------------------
  int bgByte0 = input.get() & 0xff;
  int bgByte1 = input.get() & 0xff;
  int bgColor = (bgByte1<<8) | bgByte0;
  int bg_r = (bgColor & 0x1f) << 3;
  int bg_g = ((bgColor>>5) & 0x1f) << 3;
  int bg_b = ((bgColor>>10) & 0x1f) << 3;
  backgroundColor = (bg_b << 16) | (bg_g << 8) | (bg_r);
  
  g_wayPointList.Read(input);
  
  ReadZones(input);
  
  if(version>=2){
	  ReadExits(input);
  }
  
  if(version>=3){
	  //read links
	  input.get();   //1st link always null
	  input.get();
	  for(i=1; i<8; i++){
		  int n = (input.get() & 0xff);
		  n |= (input.get() & 0xff) << 8;
		  controls->links[i] = n;
	  }
  }
  
  //be a good poopy
  input.close();
  this->SetScrollBarPositions();
  this->InvalidateRect(0);
  FlagTooMuchOpenSpace();
  
}

//we need to remap all the monsters so that listOfTilesUsed is in decending order
void CMapWin::remapMonsters()
{
	CChildView *view = (CChildView*) this->GetParent();
	CControls *controls = view->GrabControls();
	
	//----get the ID of the first monster--------------------------------
	short int firstCharacterID;
	firstCharacterID = (E_TILEBMPSIZEX >> 4) * (E_TILEBMPSIZEY >> 4);
	
	//----initialize the sort data--------------------------------------
	unsigned char tempArray[257];
	SwapStruct SortMeArray[257];
	int i,j;
	
	for(i = 0; i<=256; i++)
	{
		SortMeArray[i].index = i;
		SortMeArray[i].classID = listOfTilesUsed[i];
	}
	
	
	if(controls->GetSortClassesBy()==0){
		//sort linear low to high
		//--------------bubble sort here... hehehe -------------------------
		
		for(i=0;i<=totalTilesUsed;i++)
		{
			for( j=0;j<(totalTilesUsed-1);j++)
			{
				if(SortMeArray[j].classID > SortMeArray[j+1].classID)
				{//SWAP!!
					SwapStruct tmp;
					tmp.classID = SortMeArray[j].classID;
					tmp.index = SortMeArray[j].index;
					SortMeArray[j].classID = SortMeArray[j+1].classID;
					SortMeArray[j].index = SortMeArray[j+1].index;
					SortMeArray[j+1].classID = tmp.classID;
					SortMeArray[j+1].index = tmp.index;
				}
			}
		}
	}else{
		//keep same order except all monsters after all bg tiles
		for(i=0;i<=totalTilesUsed;i++)
		{
			for( j=0;j<(totalTilesUsed-1);j++)
			{
				if(SortMeArray[j].classID>=firstCharacterID && SortMeArray[j+1].classID<firstCharacterID)
				{//SWAP!!
					SwapStruct tmp;
					tmp.classID = SortMeArray[j].classID;
					tmp.index = SortMeArray[j].index;
					SortMeArray[j].classID = SortMeArray[j+1].classID;
					SortMeArray[j].index = SortMeArray[j+1].index;
					SortMeArray[j+1].classID = tmp.classID;
					SortMeArray[j+1].index = tmp.index;
				}
			}
		}
	}
	
	//---------whew..that was a little embarrassing--------------------------

	//Now we create a remapping array
	for(i=0;i<257;i++)
	{
		listOfTilesUsed[i] = SortMeArray[i].classID;
		tempArray[SortMeArray[i].index] = i;
	}


	//finally we loop through envArray and replace all the positions
	for(i=0;i<controls->GetMapWidth();i++)
		for(j=0;j<controls->GetMapHeight();j++)
			if(envArray[i][j].index)
				envArray[i][j].index = tempArray[envArray[i][j].index];

}

//Clear the level and start fresh...
void CMapWin::clearLevel()
{
	// Member initializations
	showGrids = false;
	backgroundColor = 0x808080;
	gridColor = 0x0000ff;
	curTile = 0;
  for(int i=0;i<256;i++){
    for(int j=0;j<256;j++){
			envArray[i][j].index = 0;
      zoneArray[i][j] = 1;
      exitArray[i][j] = 0;
    }
  }

	totalTilesUsed = 1;
	for(i=0;i<=256;i++)
		listOfTilesUsed[i] = -1;
	for(i=0;i<65536;i++)
		listOfAllTiles[i] = 0;

  drawingPath=0;
  pathStartX=0;
  pathStartY=0;
  selectedZone=0;
  drawingRect = 0;

  g_wayPointList.Reset();
}

//--------------------------------------------------------------------------
//						Mouse Methods
//--------------------------------------------------------------------------

void CMapWin::OnRButtonDown(UINT nFlags, CPoint point) 
{
  rmb_isDown = 1;

  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = (CControls*) view->GrabControls();

  if(controls->GetDrawingZones()!=0){
    this->EraseTile(point);
  }else{
    //screwing around with path stuff
    CPoint tPoint = point;
    tPoint.x += controls->GetOffsetX();
    tPoint.y += controls->GetOffsetY();

    int i = tPoint.x >> 4;
    int j = tPoint.y >> 4;
    
    if(i >= controls->GetMapWidth())
      return;
    if(j >= controls->GetMapHeight())
      return;

    if(drawingPath==0){
      //start drawing a path?
        if(!g_wayPointList.WayPointExists(i,j)){
        pathStartX = i;
        pathStartY = j;
        selectedZone = zoneArray[i][j];
        drawingPath = g_wayPointList.BeginPath(selectedZone);
      }else{
         //delete waypoint
         g_wayPointList.RemoveWayPoint(i,j);         
      }
      this->InvalidateRect(0);
    }
  }

	CWnd::OnRButtonDown(nFlags, point);
}


void CMapWin::OnLButtonDown(UINT nFlags, CPoint point) 
{
  this->SetFocus();

  lmb_isDown = 1;

  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = (CControls*) view->GrabControls();

  if(controls->GetDrawingZones()!=0){
    if(::GetAsyncKeyState(VK_SHIFT) & 0x8000){
      drawingRect = 1;
      rectStartX = (point.x + controls->GetOffsetX()) >> 4;
      rectStartY = (point.y + controls->GetOffsetY()) >> 4;
      rectEndX = rectStartX;
      rectEndY = rectStartY;

    }else{
      this->PlaceCurrentTile(point);
      FlagTooMuchOpenSpace();
    }
  }else{
    //make a waypoint or add to a path

    //account for scrolling
    CPoint tPoint = point;
    tPoint.x += controls->GetOffsetX();
    tPoint.y += controls->GetOffsetY();

    int i = tPoint.x >> 4;
    int j = tPoint.y >> 4;


    if(i >= controls->GetMapWidth())
      return;
    if(j >= controls->GetMapHeight())
      return;

    if(drawingPath){
      if(g_wayPointList.WayPointExists(i,j)){
        g_wayPointList.AddWayPointToPath(i,j);
      }else{
        int pathnum = g_wayPointList.EndPath(zoneArray[i][j]);
        if(::GetAsyncKeyState(VK_SHIFT) & 0x8000){  //make a new path
          //make a separate path that is the same w/o last waypoint
          int wpcount = 0;
          if(g_wayPointList.GetFirstWayPoint(pathnum)>0){
            wpcount++;
            while(g_wayPointList.GetNextWayPoint(pathnum)>0) wpcount++;
          }
          drawingPath = g_wayPointList.BeginPath(selectedZone);
          wpcount--;
       
          if(wpcount>0){
            g_wayPointList.AddWayPointToPath(
              g_wayPointList.GetWayPoint(g_wayPointList.GetFirstWayPoint(pathnum)));
            int x;
            for(x=1; x<wpcount; x++){
              g_wayPointList.AddWayPointToPath(
                g_wayPointList.GetWayPoint(g_wayPointList.GetNextWayPoint(pathnum)));
            }
          }
        }else{
          drawingPath = 0;
        }
      }
    }else{
      if(::GetAsyncKeyState(VK_SHIFT) & 0x8000){
        //move the waypoint?
        drawingRect = 1;
        rectStartX = rectEndX = i;
        rectStartY = rectEndY = j;
      }
    
      g_wayPointList.CreateWayPoint(i,j);
    }

    this->InvalidateRect(0);
  }

	//CWnd::OnLButtonDown(nFlags, point);
}


void CMapWin::OnSize(UINT nType, int cx, int cy) 
{
	CWnd::OnSize(nType, cx, cy);
	
  this->SetScrollBarPositions();	
  this->InvalidateRect(0);	
}

void CMapWin::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
  SCROLLINFO scrollInfo;
  scrollInfo.cbSize = sizeof(SCROLLINFO);
  scrollInfo.fMask = SIF_POS | SIF_PAGE | SIF_RANGE;
  this->GetScrollInfo(SB_HORZ, &scrollInfo, SIF_ALL);
  int pos = this->GetScrollPos(SB_HORZ);

  switch(nSBCode){
    case SB_LEFT:           //Scroll to far left.
      pos = 0;
      break;
    case SB_ENDSCROLL:      //End scroll.
      break;
    case SB_LINELEFT:       //Scroll left.
      pos -= 128;
      break;
    case SB_LINERIGHT:      //Scroll right.
      pos += 128;
      break;
    case SB_PAGELEFT:       //Scroll one page left.
      pos -= (scrollInfo.nPage * 3) / 4;
      break;
    case SB_PAGERIGHT:      //Scroll one page right.
      pos += (scrollInfo.nPage * 3) / 4;
      break;
    case SB_RIGHT:          //Scroll to far right.
      pos = scrollInfo.nMax;
      break;
    case SB_THUMBPOSITION:  //Scroll to absolute position
    case SB_THUMBTRACK:
      pos = nPos;
      break;
  }

  //adjust pos so it won't be out of bounds (looks nicer than letting win do it)
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();


  int mapWidth = controls->GetMapWidth() * 16;
  CRect rect;
  this->GetClientRect(&rect);
  if(pos<0){
    pos = 0;
  }else if(pos + rect.Width() > mapWidth){
    pos = mapWidth - rect.Width();
  }


  scrollInfo.nPos = pos;
  this->SetScrollInfo(SB_HORZ, &scrollInfo, scrollInfo.fMask);

  controls->SetOffsetX(pos);
  this->InvalidateRect(0);
}

void CMapWin::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
  SCROLLINFO scrollInfo;
  scrollInfo.cbSize = sizeof(SCROLLINFO);
  scrollInfo.fMask = SIF_POS | SIF_PAGE | SIF_RANGE;
  this->GetScrollInfo(SB_VERT, &scrollInfo, SIF_ALL);
  int pos = this->GetScrollPos(SB_VERT);

  switch(nSBCode){
    case SB_LEFT:           //Scroll to far left.
      pos = 0;
      break;
    case SB_ENDSCROLL:      //End scroll.
      break;
    case SB_LINELEFT:       //Scroll left.
      pos -= 128;
      break;
    case SB_LINERIGHT:      //Scroll right.
      pos += 128;
      break;
    case SB_PAGELEFT:       //Scroll one page left.
      pos -= (scrollInfo.nPage * 3) / 4;
      break;
    case SB_PAGERIGHT:      //Scroll one page right.
      pos += (scrollInfo.nPage * 3) / 4;
      break;
    case SB_RIGHT:          //Scroll to far right.
      pos = scrollInfo.nMax;
      break;
    case SB_THUMBPOSITION:  //Scroll to absolute position
    case SB_THUMBTRACK:
      pos = nPos;
      break;
  }

  //adjust pos so it won't be out of bounds (looks nicer than letting win do it)
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();


  int mapHeight = controls->GetMapHeight() * 16;
  CRect rect;
  this->GetClientRect(&rect);
  if(pos<0){
    pos = 0;
  }else if(pos + rect.Height() > mapHeight){
    pos = mapHeight - rect.Height();
  }
 

  scrollInfo.nPos = pos;
  this->SetScrollInfo(SB_VERT, &scrollInfo, scrollInfo.fMask);

  controls->SetOffsetY(pos);
  this->InvalidateRect(0);	
	
  CWnd::OnVScroll(nSBCode, nPos, pScrollBar);
}

void CMapWin::SetScrollBarPositions()
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  CRect rect;
  this->GetClientRect(&rect);

  int mapWidth = (controls->GetMapWidth() * 16);
  int mapHeight = (controls->GetMapHeight() * 16);
  int extraWidth = rect.Width() - mapWidth;
  int extraHeight = rect.Height() - mapHeight;

  SCROLLINFO scrollInfo;
  scrollInfo.cbSize = sizeof(SCROLLINFO);

  if(extraWidth>=0){
    //don't need the scroll bar
    scrollInfo.fMask = SIF_POS | SIF_RANGE;
    scrollInfo.nMin = scrollInfo.nMax = scrollInfo.nPos = 0;
    this->SetScrollInfo(SB_HORZ, &scrollInfo, scrollInfo.fMask);
  }else{
    scrollInfo.fMask = SIF_RANGE | SIF_PAGE;
    scrollInfo.nMin = 0;
    scrollInfo.nMax = mapWidth;
    scrollInfo.nPos = 0;
    scrollInfo.nPage = rect.Width();
    controls->SetOffsetX(this->GetScrollPos(SB_HORZ));
    this->SetScrollInfo(SB_HORZ, &scrollInfo, scrollInfo.fMask);
    
  }

  if(extraHeight>=0){
    scrollInfo.fMask = SIF_POS | SIF_RANGE;
    scrollInfo.nMin = scrollInfo.nMax = scrollInfo.nPos = 0;
    this->SetScrollInfo(SB_VERT, &scrollInfo, scrollInfo.fMask);
  }else{
    scrollInfo.fMask = SIF_RANGE | SIF_PAGE;
    scrollInfo.nMin = 0;
    scrollInfo.nMax = mapHeight+15;
    scrollInfo.nPos = 0;
    scrollInfo.nPage = rect.Height();
    controls->SetOffsetY(this->GetScrollPos(SB_VERT));
    this->SetScrollInfo(SB_VERT, &scrollInfo, scrollInfo.fMask);
  }
}

void CMapWin::PlaceCurrentTile(CPoint point)
{


  CPoint originalPoint = point;


	if(!::IsWindow(this->m_hWnd))
		return;

	//grab a pointer to the view
  CChildView* papa;
	papa = (CChildView*)this->GetParent();
  CControls *controls = papa->GrabControls();

  //account for scrolling
  point.x += controls->GetOffsetX();
  point.y += controls->GetOffsetY();

	if((point.x>>4) >= controls->GetMapWidth())
		return;
	if((point.y>>4) >= controls->GetMapHeight())
		return;
  
  if(controls->GetDrawingZones()==-1){
    if(controls->GetDrawingExits()==-1){
      int index = controls->GrabCurTileIndex();
      if(index==1){
        EraseTile(originalPoint);
        controls->SetCurTilePointer(1);
        return;
      }
  
      int i,j;
      int width = controls->metaWidth;
      for(j=0; j<controls->metaHeight; j++){
        for(i=0; i<width; i++){
          CPoint newPoint(point.x+(i<<4),point.y+(j<<4));
          PlaceTile(index + (width*j)+i, newPoint);
        }
      }
    }else{
      //drawing exits
      exitArray[point.x>>4][point.y>>4] = controls->GetDrawingExits();
    }
  }else if(controls->GetDrawingZones()>0){
    //drawing zones, not tiles:
    int i = point.x>>4;
    int j = point.y>>4;
    zoneArray[i][j] = controls->GetDrawingZones();
  }else{
    //placing a waypoint
  }

	this->InvalidateRect(0);
}

void CMapWin::PlaceTile(int tileIndex, CPoint point)
{
  //grab a pointer to the view
  CChildView* papa;
	papa = (CChildView*)this->GetParent();
  CControls *controls = papa->GrabControls();

  //lets see if we are placing a new tile
  int whatsCurTile;
  whatsCurTile = tileIndex;
  
  int tileExists = listOfAllTiles[whatsCurTile];
  if(controls->isWall){
	  int i;
	  for(i=0; i<16; i++){
		  if(!listOfAllTiles[whatsCurTile+i]) tileExists = 0;
	  }
  }

  if(!tileExists)
  {//looks like this is a new one :-)
    if(totalTilesUsed > 256 || (controls->isWall && totalTilesUsed > 256-15))
    {//have we used 255 tiles yet?
      this->MessageBox("You've used too many tiles Bitch Ass");
      return;
    }

    if(!controls->isWall){
      listOfTilesUsed[totalTilesUsed++] = whatsCurTile;
      listOfAllTiles[whatsCurTile] = 1;
    }else{
      int i;
      for(i=0; i<16; i++){
        listOfTilesUsed[totalTilesUsed++] = whatsCurTile + i;
        listOfAllTiles[whatsCurTile + i] = 1;
      }
    }
  }
  
  // find game index of tile
  int tempIndex;
  for(int i = 0; i < totalTilesUsed; i++){
    if(listOfTilesUsed[i] == whatsCurTile){
      tempIndex = i;
    }
  }

  int dx = point.x >> 4;
  int dy = point.y >> 4;

  //if part of a wall, change the drawn index based on surrounding similar walls
  int offsetOriginal=0;
  int offset = 0;

  static int offsetRemap[16] = 
  { 0, 12,  1, 13,
    4,  8,  5,  9,
    3, 15,  2, 14,
    7, 11,  6, 10
  };

  static int offsetRemapBack[16] = 
  { 0,  2, 10,  8,
    4,  6, 14, 12,
    5,  7, 15, 13,
    1,  3, 11,  9
  };

  if(controls->isWall){
    if(dy > 0 && (((envArray[dx][dy-1].index - tempIndex) | 15) == 15)) offset |= 1;
    if(dx < controls->GetMapWidth()-1 && (((envArray[dx+1][dy].index - tempIndex) | 15)) == 15) offset |= 2;
    if(dy < controls->GetMapHeight()-1 && (((envArray[dx][dy+1].index - tempIndex) | 15)) == 15) offset |= 4;
    if(dx > 0 && (((envArray[dx-1][dy].index - tempIndex) | 15) == 15)) offset |= 8;

    /*
    { 0,  2, 10,  8,
      4,  6, 14, 12,
      5,  7, 15, 13,
      1,  3, 11,  9};
      */

    offsetOriginal = offset;
    offset = offsetRemap[offset];
  }
    
  //CHANGE grab real index from controls
  envArray[dx][dy].index = (tempIndex+offset);
  envArray[dx][dy].pic = papa->GrabControls()->GrabTilePointer(tileIndex+offset);

  //make sure adjacent similar walls are modified accordingly
  if(offsetOriginal & 1){
    int off = offsetRemap[offsetRemapBack[envArray[dx][dy-1].index - tempIndex] | 4];
    envArray[dx][dy-1].index = tempIndex + off;
    envArray[dx][dy-1].pic = controls->GrabTilePointer(tileIndex + off);
  }
  if(offsetOriginal & 2){
    int off = offsetRemap[offsetRemapBack[envArray[dx+1][dy].index - tempIndex] | 8];
    envArray[dx+1][dy].index = tempIndex + off;
    envArray[dx+1][dy].pic = controls->GrabTilePointer(tileIndex + off);
  }
  if(offsetOriginal & 4){
    int off = offsetRemap[offsetRemapBack[envArray[dx][dy+1].index - tempIndex] | 1];
    envArray[dx][dy+1].index = tempIndex + off;
    envArray[dx][dy+1].pic = controls->GrabTilePointer(tileIndex + off);
  }
  if(offsetOriginal & 8){
    int off = offsetRemap[offsetRemapBack[envArray[dx-1][dy].index - tempIndex] | 2];
    envArray[dx-1][dy].index = tempIndex + off;
    envArray[dx-1][dy].pic = controls->GrabTilePointer(tileIndex + off);
  }
}

void CMapWin::OnLButtonUp(UINT nFlags, CPoint point) 
{
	lmb_isDown = 0;

  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  if(drawingRect){
    
    drawingRect = 0;
    
    if(controls->GetDrawingZones()!=0){
      {
        int temp;
        if(rectEndY < rectStartY){
          temp = rectStartY;
          rectStartY = rectEndY;
          rectEndY = temp;
        }
        if(rectEndX < rectStartX){
          temp = rectStartX;
          rectStartX = rectEndX;
          rectEndX = temp;
        }
      }
      if(controls->areaSpecial==0){   //no special fx
        //loop through every tile in the rect, drawing an item there
        int i,j;
        int lineToggle = 1;
        for(j=rectStartY; j<=rectEndY; j+=controls->metaHeight){
          int toggle = lineToggle;
          lineToggle ^= 1;
          for(i=rectStartX; i<=rectEndX; i+=controls->metaWidth){
            CPoint curPoint;
            if(!(::GetKeyState(VK_MENU) & 0x8000) || toggle){
              curPoint.x = (i<<4) - controls->GetOffsetX();
              curPoint.y = (j<<4) - controls->GetOffsetY();
              PlaceCurrentTile(curPoint);
            }
            toggle ^= 1;
          }
        }
        FlagTooMuchOpenSpace();
      }else{
        //do a special effect in the rect

        //if paste force the rect to be at least as large as the copy size
        if(controls->areaSpecial & 64){
          int width = rectEndX - rectStartX + 1;
          int height = rectEndY - rectStartY + 1;
          if(width < copyWidth) width = copyWidth;
          if(height < copyHeight) height = copyHeight;
          rectEndX = rectStartX + width - 1;
          rectEndY = rectStartY + height - 1;
        }

        //clip the rect first
        if(rectStartX<0) rectStartX = 0;
        if(rectStartY<0) rectStartY = 0;
        if(rectEndX >= controls->GetMapWidth()) rectEndX = controls->GetMapWidth()-1;
        if(rectEndY >= controls->GetMapHeight()) rectEndY = controls->GetMapHeight()-1;

        int i,j;
        picstruct temp;

        if(controls->areaSpecial & 1){   //shift up
          for(i=rectStartX; i<=rectEndX; i++){
            temp = envArray[i][rectStartY];
            for(j=rectStartY; j<rectEndY; j++){
              envArray[i][j] = envArray[i][j+1];
            }
            envArray[i][rectEndY] = temp;
          }
        }
        if(controls->areaSpecial & 2){   //shift right
          for(j=rectStartY; j<=rectEndY; j++){
            temp = envArray[rectEndX][j];
            for(i=rectEndX; i>rectStartX; i--){
              envArray[i][j] = envArray[i-1][j];
            }
            envArray[rectStartX][j] = temp;
          }
        }
        if(controls->areaSpecial & 4){   //shift down
          for(i=rectStartX; i<=rectEndX; i++){
            temp = envArray[i][rectEndY];
            for(j=rectEndY; j>rectStartY; j--){
              envArray[i][j] = envArray[i][j-1];
            }
            envArray[i][rectStartY] = temp;
          }
        }
        if(controls->areaSpecial & 8){   //shift left
          for(j=rectStartY; j<=rectEndY; j++){
            temp = envArray[rectStartX][j];
            for(i=rectStartX; i<rectEndX; i++){
              envArray[i][j] = envArray[i+1][j];
            }
            envArray[rectEndX][j] = temp;
          }
        }


        int rectWidth = (rectEndX - rectStartX) + 1;
        int rectHeight = (rectEndY - rectStartY) + 1;

        if(controls->areaSpecial & 16){   //copy up (cut)
          for(i=rectStartX; i<=rectEndX; i++){
            for(j=rectStartY; j<=rectEndY; j++){
              copyBuffer[i-rectStartX][j-rectStartY] = envArray[i][j];
              envArray[i][j].index = 0;
            }
          }
          copyWidth = rectEndX - rectStartX + 1;
          copyHeight = rectEndY - rectStartY + 1;
        }
        if(controls->areaSpecial & 32){   //copy right (copy)
          for(i=rectStartX; i<=rectEndX; i++){
            for(j=rectStartY; j<=rectEndY; j++){
             copyBuffer[i-rectStartX][j-rectStartY] = envArray[i][j];
            }
          }
          copyWidth = rectEndX - rectStartX + 1;
          copyHeight = rectEndY - rectStartY + 1;
        }
        if(controls->areaSpecial & 64){   //copy down (paste)
          for(i=rectStartX; i<=rectEndX; i++){
            for(j=rectStartY; j<=rectEndY; j++){
              envArray[i][j] = copyBuffer[(i-rectStartX)%copyWidth][(j-rectStartY)%copyHeight];
            }
          }
        }
        if(controls->areaSpecial & 128){   //copy left
          for(i=rectStartX; i<=rectEndX; i++){
            for(j=rectStartY; j<=rectEndY; j++){
              int di = i - rectWidth;
              int dj = j;
              if(di<0||dj<0||di>255||dj>255) continue;

              envArray[di][dj] = envArray[i][j];
            }
          }
        }
      }
    }else{
      //moving waypoint
      g_wayPointList.MoveWayPoint(rectStartX, rectStartY, rectEndX, rectEndY);
    }
    
    this->InvalidateRect(0);
    this->FlagTooMuchOpenSpace();
  }
	
	CWnd::OnLButtonUp(nFlags, point);
}

void CMapWin::OnMouseMove(UINT nFlags, CPoint point) 
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();
  CMainFrame *frame = (CMainFrame*) this->GetParentFrame();

  if(lmb_isDown){
    if(drawingRect){
      rectEndX = (point.x + controls->GetOffsetX())>>4;
      rectEndY = (point.y + controls->GetOffsetY())>>4;
      this->InvalidateRect(0);
    }else{
      this->PlaceCurrentTile(point);
      FlagTooMuchOpenSpace();
    }
  }else if(rmb_isDown){
    this->EraseTile(point);
  }else if(drawingPath){
    this->InvalidateRect(0);
  }

  int i = (point.x + controls->GetOffsetX()) >> 4;
  int j = (point.y + controls->GetOffsetY()) >> 4;

  char st[80];
  ostrstream stout(st,80);
  stout << "(" << i << "," << j;
  g_wayPointList.GetPitch();
  stout << " / $" << (hex) << (0xd000 + (j * g_wayPointList.GetPitch()) + i);
  stout << (dec) << ")  index: " << envArray[i][j].index;
  stout << "  class: " << listOfTilesUsed[envArray[i][j].index];
  stout << "  zone:  " << (int) zoneArray[i][j] << ends;
  frame->ShowStatus(st);

	CWnd::OnMouseMove(nFlags, point);
}

void CMapWin::EraseTile(CPoint point)
{
	if(!::IsWindow(this->m_hWnd))
		return;
	//grab a pointer to the view
  CControls *controls;
  controls = (CControls*)(((CChildView*)this->GetParent())->GrabControls());
  
  //account for scrolling
  point.x += controls->GetOffsetX();
  point.y += controls->GetOffsetY();
  
  int i = point.x>>4;
  int j = point.y>>4;
  if(i>=0 && j>=0 && i<controls->GetMapWidth() && j<controls->GetMapHeight()){
    if(controls->GetDrawingZones()==-1){
      if(controls->GetDrawingExits()==-1){  
        int curIndex = envArray[i][j].index;
        
        if(curIndex>0){
          //set the current tile
          controls->SetCurTilePointer(listOfTilesUsed[envArray[point.x>>4][point.y>>4].index]);
        }
        
        //reset index to zero
        envArray[point.x>>4][point.y>>4].index = 0;
      }else{
        //erasing exits
        exitArray[point.x>>4][point.y>>4] = 0;
      }
    }else if(!drawingPath){
      //"erase" selects a zone when drawing zones
      this->selectedZone = zoneArray[i][j];
      this->pathStartX = i;
      this->pathStartY = j;
    }
  }
  
  this->InvalidateRect(0);
  FlagTooMuchOpenSpace();
}

void CMapWin::OnRButtonUp(UINT nFlags, CPoint point) 
{
  rmb_isDown = 0;
  
	CWnd::OnRButtonUp(nFlags, point);
}

void CMapWin::DrawPath(int destZone, int nPath, gkWinShape &tileBuffer)
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  int c = CZoneList::GetZoneColor(destZone);
  gkRGB color(c&0xff, (c>>8)&0xff, (c>>16)&0xff);
  int prev_i = pathStartX;
  int prev_j = pathStartY;
  int next_i;
  int next_j;
  //CPoint tempP;
  //if(::GetCursorPos(&tempP)){
//    if(tempP.x > 600) ASSERT(0);
//  }
  int afterFirst = 0;
  int nextWP = g_wayPointList.GetFirstWayPoint(nPath);
  while(nextWP){
    
    int wp = g_wayPointList.GetWayPoint(nextWP);
    next_i = wp & 0xff;
    next_j = (wp>>8) & 0xff;
    int si = (prev_i<<4) - controls->GetOffsetX() + (destZone&afterFirst);
    int sj = (prev_j<<4) - controls->GetOffsetY() + (destZone&afterFirst);
    int di = (next_i<<4) - controls->GetOffsetX() + destZone;
    int dj = (next_j<<4) - controls->GetOffsetY() + destZone;
    afterFirst = 0xffffffff;
    
    tileBuffer.Line(si,sj,di,dj,color);
    
    prev_i = next_i;
    prev_j = next_j;
    nextWP = g_wayPointList.GetNextWayPoint(nPath);
  }
  
  //connect to mouse if currently drawing
  if(drawingPath){
    CPoint mousePoint;
    ::GetCursorPos(&mousePoint);
    this->ScreenToClient(&mousePoint);
    
    int si = (prev_i<<4) - controls->GetOffsetX() + destZone;
    int sj = (prev_j<<4) - controls->GetOffsetY() + destZone;
    int di = mousePoint.x;
    int dj = mousePoint.y;
    
    tileBuffer.Line(si,sj,di,dj,color);
  }
}

void CMapWin::WriteZones(ostream &out)
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  //pack the zone bytes 2:1
  int compressed[128][256];
  int i,j;
  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<controls->GetMapWidth(); i+=2){
      int byte1 = this->zoneArray[i][j] & 0x0f;
      int byte2 = zoneArray[i+1][j] & 0x0f;
      compressed[i/2][j] = (byte1<<4) | byte2;
    }
  }

  //write out zone info using RLE
  int numContinuous = 0;
  int continuousByte = compressed[0][0];
  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<(controls->GetMapWidth()>>1); i++){
      if(compressed[i][j] == continuousByte){
        numContinuous++;
      }else{
        out.put((char) numContinuous);
        out.put((char) continuousByte);
        continuousByte = compressed[i][j];
        numContinuous = 1;
      }
      if(numContinuous == 256){
        out.put((char) 255);
        out.put((char) continuousByte);
        numContinuous = 1;
      }
    }
  }
  out.put((char) numContinuous);
  out.put((char) continuousByte);
//  if(numContinuous != 0){
//    out.put((char) 0);
//    out.put((char) 0);
//  }
}

void CMapWin::ReadZones(istream &in)
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  //reads & inflates zones stored using Run Lengh Encoding and compressed 2:1
  int i,j,continuousByte,numContinuous;

  int temp = in.tellg();
  numContinuous = in.get() & 0xff;
  if(in.eof()) return;
  continuousByte = in.get() & 0xff;

  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<controls->GetMapWidth(); i+=2){
      if(!numContinuous){
        numContinuous = in.get() & 0xff;
        continuousByte = in.get() & 0xff;
      }
      zoneArray[i][j] = (continuousByte>>4) & 0x0f;
      zoneArray[i+1][j] = continuousByte & 0x0f;
      numContinuous--;
    }
  }

  //in.get();  //junk null terminator
  //in.get();
}

short int * CMapWin::getListOfAllTiles()
{
  return this->listOfAllTiles;
}

void CMapWin::RemakeListOfTilesUsed()
{
  //regenerates the tiles used list using the tiles from the map and the tiles
  //in the list of all tiles.  Called after the "classes used" dialog finishes.

  //first off flag any of the classes used in the map in the "listOfAllClasses"
  //and convert the map indices into actual classes
	CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  int i,j;
  for(i=0; i<256; i++){
    for(j=0; j<256; j++){
      if(envArray[i][j].index){
        if(i<controls->GetMapWidth() && j<controls->GetMapHeight()){
          listOfAllTiles[listOfTilesUsed[envArray[i][j].index]] = 1;
          envArray[i][j].index = listOfTilesUsed[envArray[i][j].index];
        }else{
          envArray[i][j].index = 0;
        }
      }  
    }
  }

  //clear the list of tiles used
	totalTilesUsed = 1;
	for(i=0;i<=256;i++)
		listOfTilesUsed[i] = -1;

  //refresh the listOfTilesUsed from the listOfAllTiles
  for(i=0; i<65536; i++){
    if(listOfAllTiles[i]){
      listOfTilesUsed[totalTilesUsed++] = i;
    }
  }

  //remap each location in the map back to an index
  for(i=0; i<256; i++){
    for(j=0; j<256; j++){
      int lookfor = envArray[i][j].index;
      if(lookfor){
        int n;
        for(n=1; n<=totalTilesUsed; n++){
          if(listOfTilesUsed[n]==lookfor){
            envArray[i][j].index = n;
            break;
          }
        }
      }
    }
  }
}

void CMapWin::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
	CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  controls->SendToKeyDown(nChar,nRepCnt,nFlags);

	CWnd::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CMapWin::WriteExits(ostream &out)
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  //pack the exit bytes 2:1
  int compressed[128][256];
  int i,j;
  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<controls->GetMapWidth(); i+=2){
      int byte1 = this->exitArray[i][j] & 0x0f;
      int byte2 = exitArray[i+1][j] & 0x0f;
      compressed[i/2][j] = (byte1<<4) | byte2;
    }
  }

  //int temp = out.tellp();
  //char st[80];
  //ostrstream stout(st,80);
  //stout << temp << ends;
  //this->MessageBox(st);

  //write out exit info using RLE
  int numContinuous = 0;
  int continuousByte = compressed[0][0];
  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<(controls->GetMapWidth()>>1); i++){
      if(compressed[i][j] == continuousByte){
        numContinuous++;
      }else{
        out.put((char) numContinuous);
        out.put((char) continuousByte);
        continuousByte = compressed[i][j];
        numContinuous = 1;
      }
      if(numContinuous == 256){
        out.put((char) 255);
        out.put((char) continuousByte);
        numContinuous = 1;
      }
    }
  }

  out.put((char) numContinuous);
  out.put((char) continuousByte);
  //if(numContinuous != 0){
    //out.put((char) 0);
    //out.put((char) 0);
  //}
}

void CMapWin::ReadExits(istream &in)
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();

  //reads & inflates zones stored using Run Lengh Encoding and compressed 2:1
  int i,j,continuousByte,numContinuous;

  //int temp = in.tellg();
  //char st[80];
  //ostrstream stout(st,80);
  //stout << temp << ends;
  //this->MessageBox(st);

  numContinuous = in.get() & 0xff;
  if(in.eof()) return;
  continuousByte = in.get() & 0xff;

  for(j=0; j<controls->GetMapHeight(); j++){
    for(i=0; i<controls->GetMapWidth(); i+=2){
      if(!numContinuous){
        numContinuous = in.get() & 0xff;
        continuousByte = in.get() & 0xff;
      }
      exitArray[i][j] = (continuousByte>>4) & 0x0f;
      exitArray[i+1][j] = continuousByte & 0x0f;
      numContinuous--;
    }
  }

  //in.get();  //junk null terminator
  //in.get();
}




void CMapWin::FlagTooMuchOpenSpace()
{
  CChildView *view = (CChildView*) this->GetParent();
  CControls *controls = view->GrabControls();
	int width = controls->GetMapWidth();
  int height = controls->GetMapHeight();

  int max_x = 18;
  int max_y = 16;

  int count, start_i, start_j;
  int i,j;

  //set all flags to zero
  for(j=0; j<height; j++){
    for(i=0; i<width; i++){
      this->tooMuchOpenSpace[i][j] = 0;
    }
  }

  //loop row by row
  for(j=0; j<height; j++){
    count = 0;

    for(i=0; i<width; i++){
      if(count==0){   //looking for first open space
        if(envArray[i][j].index==0 || listOfTilesUsed[envArray[i][j].index]>=E_FIRSTOBJ){
          start_i = i;
          count++;
        }
      }else{
        //continue finding open space
        if(envArray[i][j].index==0 || listOfTilesUsed[envArray[i][j].index]>=E_FIRSTOBJ) count++;
        else{
          if(count > max_x){
            while(start_i < i){
              tooMuchOpenSpace[start_i++][j] = 1;
            }
          }
          count = 0;
        }
      }
    }
  }

  //loop again column by column
  for(i=0; i<width; i++){
    count = 0;
    for(j=0; j<height; j++){
      if(count==0){   //looking for first open space
        if(envArray[i][j].index==0 || listOfTilesUsed[envArray[i][j].index]>=E_FIRSTOBJ){
          start_j = j;
          count++;
        }
      }else{
        //continue finding open space
        if(envArray[i][j].index==0 || listOfTilesUsed[envArray[i][j].index]>=E_FIRSTOBJ) count++;
        else{
          if(count > max_y){
            while(start_j < j){
              tooMuchOpenSpace[i][start_j++] = 1;
            }
          }
          count = 0;
        }
      }
    }
  }

}
