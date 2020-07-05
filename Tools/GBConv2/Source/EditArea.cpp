// EditArea.cpp : implementation file
//

#include "stdafx.h"
#include "GBConv2.h"
#include "EditArea.h"
#include "ChildView.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CEditArea

CEditArea::CEditArea()
{
  view = 0;
  downLMB = downRMB = 0;
  pickingColors = 0;
}

CEditArea::~CEditArea()
{
}


BEGIN_MESSAGE_MAP(CEditArea, CWnd)
	//{{AFX_MSG_MAP(CEditArea)
	ON_WM_ERASEBKGND()
	ON_WM_PAINT()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_CREATE()
	ON_WM_KEYDOWN()
	ON_WM_RBUTTONDOWN()
	ON_WM_RBUTTONUP()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CEditArea message handlers

BOOL CEditArea::OnEraseBkgnd(CDC* pDC) 
{
  CRect rect;
  GetClientRect(&rect);

  //fill to the right of the picture
  int width = rect.Width() - view->pic.GetDisplayWidth();
  if(width > 0){
	  pDC->FillSolidRect(view->pic.GetDisplayWidth(), 0, width, rect.Height(), 0x303030);
  }

  int height = rect.Height() - view->pic.GetDisplayHeight();
  if(height > 0){
    pDC->FillSolidRect(0,view->pic.GetDisplayHeight(),
      view->pic.GetDisplayWidth(), height, 0x303030);
  }

  return 1;
	
	//return CWnd::OnEraseBkgnd(pDC);
}

void CEditArea::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
  //view->pic.GetDisplayBuffer()->BlitToDC(&dc, 0, 0);
  int flags = (view->controls.showMapping << 1) | view->controls.showSprites;
  view->pic.GetDisplayBuffer(flags)->BlitToHDC(dc, 0, 0);

 }

void CEditArea::OnMouseMove(UINT nFlags, CPoint point) 
{
  this->SetFocus();

  view->controls.InvalidateMagnifiedArea();

  if(downLMB){
    if(!pickingColors){
      view->pic.OnMouseLDrag(point.x, point.y);
      view->controls.InvalidateColors();
      if(view->pic.GetNeedsRedraw()) this->InvalidateRect(0);
    }else{
      if(GetAsyncKeyState(VK_CONTROL) & 0x8000){
        if(GetAsyncKeyState(VK_SHIFT) & 0x8000){
          view->pic.AddNextColor(view->pic.GetColorAtPoint(point.x,point.y));
        }else{
          view->pic.SetFirstColor(view->pic.GetColorAtPoint(point.x,point.y));
        }
        view->controls.InvalidateColors();
      }else{
        pickingColors = 0;
      }
    }
  }

  if(downRMB){
    if(GetAsyncKeyState(VK_CONTROL) & 0x8000){
      if(GetAsyncKeyState(VK_SHIFT) & 0x8000){
        //remove a color
        view->pic.RemoveColor(view->pic.GetColorAtPoint(point.x,point.y));
      }else{
        //set the bg color
        view->pic.SetBGColor(view->pic.GetColorAtPoint(point.x,point.y));
      }
    view->controls.InvalidateColors();
    }
  }

  CMainFrame *frame = (CMainFrame*) view->GetTopLevelFrame();
  char st[80];
  ostrstream stout(st,80);
  stout << "Selected: " << view->pic.GetNumSelTiles()
    << "  Sprites: " << view->pic.GetNumSprites() << "  ";
  stout << "Mapping: ";
  int mapping = view->pic.GetMappingAtPoint(point.x,point.y);
  if(mapping==-1) stout << "(None)  ";
  else            stout << mapping << "  ";
  stout << ends;
  CString str(st);
  frame->ShowStatus(&str);
	
	CWnd::OnMouseMove(nFlags, point);
}

void CEditArea::OnLButtonDown(UINT nFlags, CPoint point) 
{
  if(view->controls.showSprites){
    if(view->pic.UnmakeSprite(point.x, point.y)){
      this->InvalidateRect(0);
      return;
    }
  }

  downLMB = 1;
  if(GetAsyncKeyState(VK_CONTROL) & 0x8000){
    if(GetAsyncKeyState(VK_SHIFT) & 0x8000){
      view->pic.AddNextColor(view->pic.GetColorAtPoint(point.x,point.y));
    }else{
      //pick a color
      view->pic.SetFirstColor(view->pic.GetColorAtPoint(point.x,point.y));
    }
    view->controls.InvalidateColors();
    pickingColors = 1;
  }else{
    //select tiles
    view->pic.OnMouseLMB(point.x, point.y);
    view->controls.InvalidateColors();
    pickingColors = 0;
  }
  if(view->pic.GetNeedsRedraw()) this->InvalidateRect(0);
  this->SetCapture();
	CWnd::OnLButtonDown(nFlags, point);
}

void CEditArea::OnLButtonUp(UINT nFlags, CPoint point) 
{
  if(downLMB){
	  downLMB = 0;
    if(!pickingColors){
      view->pic.OnMouseLRelease(point.x, point.y);
      view->controls.InvalidateColors();
	    CWnd::OnLButtonUp(nFlags, point);
      if(view->pic.GetNeedsRedraw()) this->InvalidateRect(0);
    }
    ReleaseCapture();
    pickingColors = 0;
  }
}

int CEditArea::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  view = (CChildView*) this->GetParent();	
	return 0;
}

void CEditArea::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  if(nChar==VK_CONTROL){
    //this->MessageBox("CTRL pressed!");	
  }
	CWnd::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CEditArea::OnRButtonDown(UINT nFlags, CPoint point) 
{
  if(GetAsyncKeyState(VK_CONTROL) & 0x8000){
    if(GetAsyncKeyState(VK_SHIFT) & 0x8000){
      //remove a color
      view->pic.RemoveColor(view->pic.GetColorAtPoint(point.x,point.y));
    }else{
      //set the bg color
      view->pic.SetBGColor(view->pic.GetColorAtPoint(point.x,point.y));
    }
    view->controls.InvalidateColors();
  }else{
    //not picking colors; clear all selected pixels
    view->pic.ClearSelection();
    this->InvalidateRect(0);
    view->controls.InvalidateMagnifiedArea();
    view->controls.InvalidateColors();
  }
  downRMB = 1;
	CWnd::OnRButtonDown(nFlags, point);
}

void CEditArea::OnRButtonUp(UINT nFlags, CPoint point) 
{
  downRMB = 0;	
	CWnd::OnRButtonUp(nFlags, point);
}
