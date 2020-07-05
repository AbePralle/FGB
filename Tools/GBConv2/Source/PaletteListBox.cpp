// PaletteListBox.cpp : implementation file
//

#include "stdafx.h"
#include "GBConv2.h"
#include "PaletteListBox.h"
#include "gb_pic.h"
#include "ChildView.h"
#include "Controls.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPaletteListBox

CPaletteListBox::CPaletteListBox()
{
  int i;
  for(i=0; i<17; i++) itemSelected[i] = 0;
  pic = 0;
}

CPaletteListBox::~CPaletteListBox()
{
}


BEGIN_MESSAGE_MAP(CPaletteListBox, CListBox)
	//{{AFX_MSG_MAP(CPaletteListBox)
	ON_WM_CREATE()
	ON_CONTROL_REFLECT(LBN_SELCHANGE, OnSelchange)
	ON_WM_ERASEBKGND()
	//}}AFX_MSG_MAP
  ON_LBN_SELCHANGE(IDLIST_PALETTES, OnSelchange)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPaletteListBox message handlers

void CPaletteListBox::MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct) 
{
  lpMeasureItemStruct->itemWidth  = 64;
  lpMeasureItemStruct->itemHeight = 16;
}

void CPaletteListBox::DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct) 
{
  CDC *pDC = CDC::FromHandle(lpDrawItemStruct->hDC);

  int index = this->GetItemData(lpDrawItemStruct->itemID);
  if(index < 0 || index>15) return;

  if(lpDrawItemStruct->itemState & ODS_SELECTED){  
    pic->SetCurPalette(index);
  }

  CRect rect = lpDrawItemStruct->rcItem;
  int x = rect.left;
  int y = rect.top;

  CBrush black((int) 0);
  CBrush white(0xffffff);
  //CBrush bgColor(pDC->GetBkColor());
  CBrush bgColor(0x303030);

  gkRGB *pal = view->pic.GetPalette(index);

  int i;
  for(i=0; i<4; i++){
    gkRGB color = pal[i];
    if(color.GetA()==0){
      //blit the "no color" image
      //pic->nonColorBG.BlitToDC(pDC, x+3, y+3);
      pic->nonColorBG.BlitToHDC(*pDC, x+3, y+3);
    }else{
      pDC->FillSolidRect(x+3,y+3,10,10,color);
    }
    pDC->FrameRect(CRect(x+2,y+2,x+14,y+14), &black);
    x += 16;
  }

  //clear the frame to the bg color
  //pDC->FrameRect(rect, &bgColor);

  if(lpDrawItemStruct->itemState & ODS_SELECTED){
    itemSelected[index] = 1;
    pDC->FrameRect(rect, &white);
  }else{
    itemSelected[index] = 0;
    pDC->FrameRect(rect, &bgColor);
  }
}

int CPaletteListBox::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CListBox::OnCreate(lpCreateStruct) == -1)
		return -1;
	
  controls = (CControls*) this->GetParent();
  view = (CChildView*) controls->GetParent();
	
	return 0;
}



void CPaletteListBox::OnSelchange() 
{
  this->MessageBox("Super Duper!");	
}


BOOL CPaletteListBox::OnEraseBkgnd(CDC* pDC) 
{
  CRect rect;
  GetClientRect(&rect);

  pDC->FillSolidRect(&rect, 0x303030);
  return 1;

	//return CListBox::OnEraseBkgnd(pDC);
}
