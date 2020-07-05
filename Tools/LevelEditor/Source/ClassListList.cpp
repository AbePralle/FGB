// ClassListList.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "ClassListList.h"
#include "ClassList.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CClassListList

CClassListList::CClassListList()
{
}

CClassListList::~CClassListList()
{
}


BEGIN_MESSAGE_MAP(CClassListList, CListBox)
	//{{AFX_MSG_MAP(CClassListList)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CClassListList message handlers

void CClassListList::MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct) 
{
  CRect rect;
  this->GetClientRect(&rect);
 
  //tell windows the dimensions of each member of our selection box
  //lpMeasureItemStruct->itemWidth = rect.Width();
  //lpMeasureItemStruct->itemHeight = 16;
	
}

void CClassListList::DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct) 
{
  HDC hdc = lpDrawItemStruct->hDC;
  CDC dc;
  dc.Attach(hdc);

  CBrush brush;
  brush.Attach(::GetStockObject(BLACK_BRUSH));

  CRect rect = lpDrawItemStruct->rcItem;
  int x = rect.left;
  int y = rect.top;


  int data = lpDrawItemStruct->itemData;
  int tile = data & 0xffff;
  int isUsed = (data>>16) & 1;

  //checkbox
  CRect checkBox(x+4,y+2,x+14,y+12);
  dc.FillSolidRect(&checkBox,0xffffff);
  dc.FrameRect(&checkBox,&brush);

  if(isUsed){
    checkBox.DeflateRect(2,2);
    dc.FillSolidRect(&checkBox,0);
    //dc.MoveTo(checkBox.left, checkBox.top);
    //dc.LineTo(checkBox.right-1, checkBox.bottom-1);
    //dc.MoveTo(checkBox.left, checkBox.bottom-1);
    //dc.LineTo(checkBox.right-1, checkBox.top);
  }

  //picture
  if(tile){
    tileList[tile].BlitToDC(&dc, x+20, y);
  }

  //text
  dc.SetBkColor(::GetSysColor(COLOR_WINDOW));
  char st[80];
  GetText(lpDrawItemStruct->itemID,st);
  dc.TextOut(x+38,y,st);

  if(lpDrawItemStruct->itemState & ODS_SELECTED){
    dc.FrameRect(rect,&brush);
  }

  brush.Detach();
  dc.Detach();
}
