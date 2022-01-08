// ChildView.cpp : implementation of the CChildView class
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "ChildView.h"
#include <strstrea.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CChildView

CChildView::CChildView()
{

	//load in bitmap
	tyPic.LoadBMP("ty.bmp");

}

CChildView::~CChildView()
{
}


BEGIN_MESSAGE_MAP(CChildView,CWnd )
	//{{AFX_MSG_MAP(CChildView)
	ON_WM_PAINT()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDOWN()
	ON_WM_ERASEBKGND()
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_KEYDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CChildView message handlers

BOOL CChildView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CWnd::PreCreateWindow(cs))
		return FALSE;

	cs.dwExStyle |= WS_EX_CLIENTEDGE;
	cs.style &= ~WS_BORDER;
	cs.lpszClass = AfxRegisterWndClass(CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS, 
		::LoadCursor(NULL, IDC_ARROW), HBRUSH(COLOR_WINDOW+1), NULL);

	return TRUE;
}

void CChildView::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
	if(1)
		return;
}


void CChildView::OnMouseMove(UINT nFlags, CPoint point) 
{

	// TODO: Add your message handler code here and/or call default
	this->InvalidateRect(0, TRUE);
	CWnd ::OnMouseMove(nFlags, point);

}

void CChildView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default
	
	CWnd ::OnLButtonDown(nFlags, point);

	
}

BOOL CChildView::OnEraseBkgnd(CDC* pDC) 
{
	// TODO: Add your message handler code here and/or call default
	
	// we'll handle clearing
	return true;

	//return CWnd ::OnEraseBkgnd(pDC);
}



int CChildView::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CWnd ::OnCreate(lpCreateStruct) == -1)
		return -1;
	

	// TODO: Add your specialized creation code here
	controls.Create(IDD_CONTROLS, this);
	mapWin.Create(NULL, NULL, WS_CHILD | WS_VISIBLE | WS_HSCROLL | WS_VSCROLL, 
    CRect(0,0,0,0), this, 0, 0);

	controls.ShowWindow(SW_SHOW);

	return 0;
}

void CChildView::ReSizeWindows()
{

	CRect rect;

	this->GetClientRect(&rect);

	controls.SetWindowPos(&wndTop, 0, 0, 300, rect.Height(), SWP_SHOWWINDOW);
	mapWin.SetWindowPos(&wndTop, 300, 0, rect.Width()-300, rect.Height(), SWP_SHOWWINDOW);
	

}

void CChildView::OnSize(UINT nType, int cx, int cy) 
{
	CWnd ::OnSize(nType, cx, cy);
	
	// TODO: Add your message handler code here
	this->ReSizeWindows();
	
}

// display grids on the mapview
void CChildView::SetGrids(bool on){
	mapWin.SetGrids(on);
}

// naughty function to grab a reference to WinMap
CMapWin* CChildView::GrabWinMap(){
	return &mapWin;
}

// naughty function to grab a reference to control
CControls* CChildView::GrabControls(){
	return &controls;
}
								



void CChildView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
ASSERT(0);	
	CWnd ::OnKeyDown(nChar, nRepCnt, nFlags);
}
