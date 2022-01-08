// ChildView.cpp : implementation of the CChildView class
//

#include "stdafx.h"
#include "GBConv2.h"
#include "ChildView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include "Controls.h"
#include "EditArea.h"

/////////////////////////////////////////////////////////////////////////////
// CChildView

CString CChildView::preferredSourcePath = "d:\\aprogs\\fgbpix\\*.bmp";

CChildView::CChildView()
{
  sourceFile = destFile = 0;
  sourceFileName = destFileName = "";
}

CChildView::~CChildView()
{
  if(sourceFile){
    delete sourceFile;
    sourceFile = 0;
  }

  if(destFile){
    delete destFile;
    destFile = 0;
  }
}


BEGIN_MESSAGE_MAP(CChildView,CWnd )
	//{{AFX_MSG_MAP(CChildView)
	ON_WM_PAINT()
	ON_WM_CREATE()
	ON_WM_ERASEBKGND()
	ON_WM_MOUSEMOVE()
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

}


int CChildView::OnLoadBMP()
{
  if(!sourceFile){
    sourceFile = new CFileDialog(TRUE,"*.bmp", preferredSourcePath,
      0, "Bitmap Files (.bmp)|*.bmp|Backgrounds (*.bg)|*.bg|Sprites (*.sp)|*.sp|Bitmap, BG, & Sprite Files (.bmp;.bg;.sp)|*.bmp;*.bg;*.sp||");
  }


  if(sourceFile->DoModal()==IDOK){
    sourceFileName = sourceFile->GetPathName();

    //set dest
    destFileName = sourceFileName.Left(sourceFileName.GetLength() 
      - (sourceFile->GetFileName()).GetLength());

    preferredSourcePath = destFileName;
    preferredSourcePath += "*.bmp";

    destFileName += sourceFile->GetFileTitle();

    if(sourceFileName.Right(3).CompareNoCase("bmp")==0){
      // BMP
      pic.LoadBMP((char*) (LPCTSTR) sourceFileName);
    }else if(sourceFileName.Right(2).CompareNoCase("bg")==0){
      // gameboy BG file
      pic.LoadGBPic(sourceFileName);
    }else{
      //hopefully a .sp file
      pic.LoadGBSprite(sourceFileName);
    }

    CFrameWnd *frame = this->GetParentFrame();
    int innerHeight = pic.GetDisplayHeight();
    if(innerHeight < CTRLHEIGHT) innerHeight = CTRLHEIGHT;
    CRect frameRect(0,0,pic.GetDisplayWidth()+CTRLWIDTH,innerHeight);
    AdjustWindowRectEx(&frameRect, frame->GetStyle() | GetStyle(), 0, 
      frame->GetExStyle()|GetExStyle());

    int width = frameRect.Width();
    int height = frameRect.Height();
    //if(height < CTRLHEIGHT) height = CTRLHEIGHT;

    frame->SetWindowPos(&wndTop, 0, 0, width, height, SWP_NOMOVE);
    
    width = pic.GetDisplayWidth();
    height = pic.GetDisplayHeight();
    if(height < CTRLHEIGHT) height = CTRLHEIGHT;

    controls.SetWindowPos(&wndTop, 0, 0, CTRLWIDTH, height, SWP_SHOWWINDOW);
    editArea.SetWindowPos(&wndTop, CTRLWIDTH, 0, width, height, SWP_SHOWWINDOW);

    return 1;
    /*
    switch(m_listType.GetCurSel()){
      case 0:
        destFileName += ".bg";
        break;
      case 1:
        destFileName += ".tx";
        break;
      case 2:
        destFileName += ".sp";
        break;
    }
    */
  }
  return 0;
}

int CChildView::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
  
  if (CWnd ::OnCreate(lpCreateStruct) == -1)
		return -1;

  controls.Create(0,0,WS_CHILD,CRect(0,0,0,0),this,0,0);
  editArea.Create(0,0,WS_CHILD,CRect(0,0,0,0),this,0,0);

  if(!OnLoadBMP()) this->GetParent()->PostMessage(WM_CLOSE);

	return 0;
}

BOOL CChildView::OnEraseBkgnd(CDC* pDC) 
{
  //return true;	
	return CWnd ::OnEraseBkgnd(pDC);
}

void CChildView::DebugMesg(char *title, int num)
{
    char st[80];
    ostrstream stout(st,80);
    stout << num << ends;
    this->MessageBox(st,title);
}



void CChildView::OnMouseMove(UINT nFlags, CPoint point) 
{

	CWnd ::OnMouseMove(nFlags, point);
}

void CChildView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
	CWnd ::OnKeyDown(nChar, nRepCnt, nFlags);
}
