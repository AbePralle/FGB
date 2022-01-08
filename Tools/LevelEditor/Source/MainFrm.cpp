// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "LevelEditor.h"

#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNAMIC(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
	//{{AFX_MSG_MAP(CMainFrame)
	ON_WM_CREATE()
	ON_WM_SETFOCUS()
	ON_COMMAND(MENU_RED, OnRed)
	ON_COMMAND(MENU_BLACK, OnBlack)
	ON_COMMAND(MENU_BLUE, OnBlue)
	ON_COMMAND(MENU_WHITE, OnWhite)
	ON_COMMAND(MENU_YELLOW, OnYellow)
	ON_COMMAND(MENU_GRAY, OnGray)
	ON_COMMAND(GRID_BLACK, OnGridBlack)
	ON_COMMAND(GRID_RED, OnGridRed)
	ON_COMMAND(GRID_WHITE, OnGridWhite)
	ON_COMMAND(MENU_GREEN, OnGreen)
	ON_WM_KEYDOWN()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
	ID_INDICATOR_SCRL,
};

/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
	// TODO: add member initialization code here
	
}

CMainFrame::~CMainFrame()
{
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	// create a view to occupy the client area of the frame
	if (!m_wndView.Create(NULL, NULL, AFX_WS_DEFAULT_VIEW,
		CRect(0, 0, 0, 0), this, AFX_IDW_PANE_FIRST, NULL))
	{
		TRACE0("Failed to create view window\n");
		return -1;
	}
	
	if (!m_wndToolBar.CreateEx(this, TBSTYLE_FLAT, WS_CHILD | WS_VISIBLE | CBRS_TOP
		| CBRS_GRIPPER | CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC) ||
		!m_wndToolBar.LoadToolBar(IDR_MAINFRAME))
	{
		TRACE0("Failed to create toolbar\n");
		return -1;      // fail to create
	}

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}

	// TODO: Delete these three lines if you don't want the toolbar to
	//  be dockable
	m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
	EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndToolBar);

  this->ShowWindow(SW_SHOWMAXIMIZED);

	return 0;
}

BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	if( !CFrameWnd::PreCreateWindow(cs) )
		return FALSE;
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	cs.dwExStyle &= ~WS_EX_CLIENTEDGE;
	cs.lpszClass = AfxRegisterWndClass(0);
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CFrameWnd::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CMainFrame message handlers
void CMainFrame::OnSetFocus(CWnd* pOldWnd)
{
	// forward focus to the view window
	m_wndView.SetFocus();
}

BOOL CMainFrame::OnCmdMsg(UINT nID, int nCode, void* pExtra, AFX_CMDHANDLERINFO* pHandlerInfo)
{
	// let the view have first crack at the command
	if (m_wndView.OnCmdMsg(nID, nCode, pExtra, pHandlerInfo))
		return TRUE;

	// otherwise, do default handling
	return CFrameWnd::OnCmdMsg(nID, nCode, pExtra, pHandlerInfo);
}

	CChildView    m_wndView;


void CMainFrame::OnRed() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0x000022);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	

}

void CMainFrame::OnBlack() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0x000000);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	
}

void CMainFrame::OnBlue() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0x220000);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	
	
}

void CMainFrame::OnWhite() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0xffffff);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	

}

void CMainFrame::OnYellow() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0x002222);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	
	
}

void CMainFrame::OnGray() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setBackgroundColor(0x222222);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	
	

}

void CMainFrame::OnGridBlack() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setGridColor(0x010101);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	

	
}

void CMainFrame::OnGridRed() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setGridColor(0x0000ff);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	

}

void CMainFrame::OnGridWhite() 
{
	// TODO: Add your command handler code here
	(m_wndView.GrabWinMap())->setGridColor(0xffffff);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	

}

void CMainFrame::OnGreen()   //background green
{
	(m_wndView.GrabWinMap())->setBackgroundColor(0x002200);
	(m_wndView.GrabWinMap())->InvalidateRect(0);	
	

}

void CMainFrame::ShowStatus(char *st)
{
  m_wndStatusBar.SetWindowText(st);
}

void CMainFrame::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
ASSERT(0);	
	CFrameWnd::OnKeyDown(nChar, nRepCnt, nFlags);
}
