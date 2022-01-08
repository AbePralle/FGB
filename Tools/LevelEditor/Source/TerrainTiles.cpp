// TerrainTiles.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "TerrainTiles.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "Controls.h"

/////////////////////////////////////////////////////////////////////////////
// CTerrainTiles

CTerrainTiles::CTerrainTiles()
{
}

CTerrainTiles::~CTerrainTiles()
{
}


BEGIN_MESSAGE_MAP(CTerrainTiles, CWnd)
	//{{AFX_MSG_MAP(CTerrainTiles)
	ON_WM_PAINT()
	ON_WM_HSCROLL()
	ON_WM_VSCROLL()
	ON_WM_RBUTTONDOWN()
	ON_WM_LBUTTONDOWN()
	ON_WM_CREATE()
	ON_WM_SIZE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CTerrainTiles message handlers

void CTerrainTiles::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	CControls* papa;
	papa = (CControls*)this->GetParent();

	// TODO: Add your message handler code here
	//dc.FillSolidRect(0,0,100,100, 0x000000);

	(papa->GrabTileBuffer())->BlitToDC(&dc,-(this->GetScrollPos(SB_HORZ)),
										   -(this->GetScrollPos(SB_VERT)));

  int index = papa->GrabCurTileIndex();
  if(index<2047) index--;
  int frame_x = ((index % 32) * 16) - this->GetScrollPos(SB_HORZ);
  int frame_y = ((index / 32) * 16) - this->GetScrollPos(SB_VERT);

  CRect rect(frame_x, frame_y, frame_x+16, frame_y+16);
 

  CBrush whiteBrush;
  whiteBrush.Attach((HBRUSH) ::GetStockObject(WHITE_BRUSH));
  dc.FrameRect(rect,&whiteBrush);
  whiteBrush.Detach();


	// Do not call CWnd::OnPaint() for painting messages
}

void CTerrainTiles::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	// TODO: Add your message handler code here and/or call default
	
	int pos = this->GetScrollPos(SB_HORZ);

	switch(nSBCode){
//SB_LEFT
	  case SB_LINELEFT:
		  pos -= 16;
		  break;
	  case SB_LINERIGHT:
		  pos += 16;
		  break;
	  case SB_PAGELEFT:
		  pos -= 256;
		  break;
	  case SB_PAGERIGHT:
		  pos += 256;
		  break;
	  case SB_THUMBPOSITION:
		  ;
	  case SB_THUMBTRACK:
		  pos = nPos;
		  break;
	  default:
		  pos = pos;
	}

    if(pos<0) pos = 0;
	if(pos>(TERRAINSCROLLMAXH - 1)) pos = (TERRAINSCROLLMAXH - 1);
	this->SetScrollPos(SB_HORZ, pos);

	this->InvalidateRect(0);
}

void CTerrainTiles::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	// TODO: Add your message handler code here and/or call default
	
	int pos = this->GetScrollPos(SB_VERT);

	switch(nSBCode){

	  case SB_LINELEFT:
		  pos -= 16;
		  break;
	  case SB_LINERIGHT:
		  pos += 16;
		  break;
	  case SB_PAGELEFT:
		  pos -= 64;
		  break;
	  case SB_PAGERIGHT:
		  pos += 64;
		  break;
	  case SB_THUMBPOSITION:
		  ;
	  case SB_THUMBTRACK:
		  pos = nPos;
		  break;
	  default:
		  pos = pos;
	}

    if(pos<0) pos = 0;
	if(pos>(TERRAINSCROLLMAXV - 1)) pos = (TERRAINSCROLLMAXV - 1);
	this->SetScrollPos(SB_VERT, pos);


	CWnd::OnVScroll(nSBCode, nPos, pScrollBar);
	this->InvalidateRect(0);
}

void CTerrainTiles::OnRButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default1
	CControls* papa;
	int newCurTile;

	if(!::IsWindow(this->m_hWnd))
		return;

	//grab a pointer to the view
	papa = (CControls*)this->GetParent();
	

	//set current tile from x position
	newCurTile = (point.x + this->GetScrollPos(SB_HORZ)) >> 4;
	//figure in y component of index
	newCurTile += (32 * ((point.y + this->GetScrollPos(SB_VERT)) >> 4))+1;
  if(newCurTile >= 2048) newCurTile--;

	papa->SetCurTilePointer(newCurTile);
	papa->InvalidateRect(0);

	this->InvalidateRect(0);


	CWnd::OnRButtonDown(nFlags, point);
}

void CTerrainTiles::OnLButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default
	this->OnRButtonDown(nFlags, point);
	CWnd::OnLButtonDown(nFlags, point);
}

int CTerrainTiles::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
	return 0;
}

void CTerrainTiles::SetScrollBarPositions()
{
  CRect rect;
  this->GetClientRect(&rect);

  int mapWidth = TERRAINSCROLLMAXH;
  int mapHeight = TERRAINSCROLLMAXV;
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
    scrollInfo.nMax = mapWidth-1;
    scrollInfo.nPos = 0;
    scrollInfo.nPage = rect.Width();
    this->SetScrollInfo(SB_HORZ, &scrollInfo, scrollInfo.fMask);
    
  }

  if(extraHeight>=0){
    scrollInfo.fMask = SIF_POS | SIF_RANGE;
    scrollInfo.nMin = scrollInfo.nMax = scrollInfo.nPos = 0;
    this->SetScrollInfo(SB_VERT, &scrollInfo, scrollInfo.fMask);
  }else{
    scrollInfo.fMask = SIF_RANGE | SIF_PAGE;
    scrollInfo.nMin = 0;
    scrollInfo.nMax = mapHeight-1;
    scrollInfo.nPos = 0;
    scrollInfo.nPage = rect.Height();
    this->SetScrollInfo(SB_VERT, &scrollInfo, scrollInfo.fMask);
  }
}

void CTerrainTiles::OnSize(UINT nType, int cx, int cy) 
{
	CWnd::OnSize(nType, cx, cy);
	
  SetScrollBarPositions();	
}
