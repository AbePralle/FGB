// ZoneList.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "ZoneList.h"
#include "wingk.h"
#include "Controls.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CZoneList

CZoneList::CZoneList()
{
  gkWinShape buffer;
  buffer.LoadBMP("exitTiles.bmp");

  int i;
  for(i=0; i<7; i++) exitTiles[i+1].GetShape(&buffer, i*16, 0, 16, 16);
}

CZoneList::~CZoneList()
{
}


BEGIN_MESSAGE_MAP(CZoneList, CListBox)
	//{{AFX_MSG_MAP(CZoneList)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CZoneList message handlers

void CZoneList::DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct) 
{
  CControls *controls = (CControls*) this->GetParent();

  CDC dc;
  dc.Attach(lpDrawItemStruct->hDC);

  if(controls->GetDrawingExits()==-1){
    int color = this->GetZoneColor(lpDrawItemStruct->itemData);
    
    dc.FillSolidRect(&(lpDrawItemStruct->rcItem), 
      color);
    
    CBrush brush;
    
    CRect rect = lpDrawItemStruct->rcItem;
    rect.DeflateRect(1,1);
    
    //Draw outline around selected
    if(lpDrawItemStruct->itemState & ODS_SELECTED){
      
      
      if(color!=0){
        brush.Attach(GetStockObject(BLACK_BRUSH));
        dc.FrameRect(&rect,&brush);
      }else{
        brush.Attach(GetStockObject(WHITE_BRUSH));
        dc.FrameRect(&rect,&brush);
      }
      
      brush.Detach();
      
    }
    
    //draw the orange dot that means waypoint
    if(color==0){
      rect.DeflateRect(4,4);
      //brush.CreateSolidBrush(0x0080ff);  //orange brush
      dc.FillSolidRect(&rect,0x0080ff);
    }
  }else{
    //drawing exits
    int index = controls->MapIndexToExit(lpDrawItemStruct->itemID);
    CRect rect = lpDrawItemStruct->rcItem;
    exitTiles[index].BlitToDC(&dc,rect.left, rect.top);
    
    rect.DeflateRect(1,1);
    
    //Draw outline around selected
    CBrush brush;
    if(lpDrawItemStruct->itemState & ODS_SELECTED){  
      brush.Attach(GetStockObject(WHITE_BRUSH));
      dc.FrameRect(&rect,&brush);
      brush.Detach();
    }
  }

  dc.Detach();
}

int  CZoneList::GetZoneColor(int n)
{
  int color=0;
  switch(n){
    case 0:   break;
    case 1:   color = 0xffffff;  break;  //white
    case 2:   color = 0x8888ff;  break;  //pink
    case 3:   color = 0x0000ff;  break;  //red
    case 4:   color = 0x0088ff;  break;  //orange
    case 5:   color = 0x00ffff;  break;  //yellow
    case 6:   color = 0x004488;  break;  //brown
    case 7:   color = 0x88ff88;  break;  //bright green
    case 8:   color = 0x00ff00;  break;  //green
    case 9:   color = 0x008800;  break;  //dark green
    case 10:  color = 0xffff00;  break;  //cyan
    case 11:  color = 0xff8888;  break;  //light blue
    case 12:  color = 0xff0000;  break;  //royal blue
    case 13:  color = 0x880000;  break;  //dark blue
    case 14:  color = 0xff88ff;  break;  //light purple
    case 15:  color = 0xff00ff;  break;  //purple
  }
  return color;
}

void CZoneList::MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct) 
{
	//tell windows the dimensions of each member of our selection box
  lpMeasureItemStruct->itemWidth = 16;
  lpMeasureItemStruct->itemHeight = 16;
	
}
