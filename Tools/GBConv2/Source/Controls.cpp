// Controls.cpp : implementation file
//

#include "stdafx.h"
#include "GBConv2.h"
#include "Controls.h"
#include "ChildView.h"
#include "wingk.h"
#include "EditPaletteDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CControls

//statics
CString CControls::preferredDestPath = "d:\\aprogs\\fgbpix\\*.sp";

CControls::CControls()
{
  showSprites = 1;
  showMapping = 1;
  destFileDialog = 0;
  bgFileDialog = 0;
}

CControls::~CControls()
{
  if(destFileDialog){
    delete destFileDialog;
    destFileDialog = 0;
  }
  if(bgFileDialog){
    delete bgFileDialog;
    bgFileDialog = 0;
  }
}


BEGIN_MESSAGE_MAP(CControls, CWnd)
	//{{AFX_MSG_MAP(CControls)
	ON_WM_CREATE()
	ON_WM_PAINT()
	ON_WM_MOUSEMOVE()
	ON_WM_ERASEBKGND()
	//}}AFX_MSG_MAP
  ON_BN_CLICKED(IDB_PALETTEFROMSEL,OnPaletteFromSel)
  ON_BN_CLICKED(IDB_SETTOBGCOLOR,OnB_SetToBGColor)
  ON_BN_CLICKED(IDB_SWAPWITHBGCOLOR,OnB_SwapWithBGColor)
  ON_BN_CLICKED(IDB_AUTOMAPTOPALETTE,OnB_AutoMapToPalette)
  ON_BN_CLICKED(IDB_MAPTOPALETTE,OnB_MapToPalette)
  ON_BN_CLICKED(IDB_UNMAP,OnB_Unmap)
  ON_BN_CLICKED(IDB_SELECTNONEMPTY,OnB_SelectNonEmpty) 
  ON_BN_CLICKED(IDB_MAKESPRITES,OnB_MakeSprites)
  ON_BN_CLICKED(IDB_SHOWSPRITES,OnB_CheckShowSprites)
  ON_BN_CLICKED(IDB_SHOWMAPPING,OnB_ShowMapping)
  ON_BN_CLICKED(IDB_SELECTUNMAPPED,OnB_SelectUnmapped)
  ON_BN_CLICKED(IDB_SAVEGBSPRITE,OnB_SaveGBSprite)
  ON_BN_CLICKED(IDB_EDITPALETTE,OnB_EditPalette)

  ON_BN_CLICKED(IDB_AUTOMAPALL,OnB_AutoMapAll)
  ON_BN_CLICKED(IDB_SAVEGBPIC,OnB_SaveGBPic)

  ON_LBN_SELCHANGE(IDLIST_PALETTES,OnSelChangePalettes)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CControls message handlers

int CControls::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

  view = (CChildView*) this->GetParent();	

  palettes.Create(
    WS_CHILD|WS_VISIBLE|LBS_MULTIPLESEL|LBS_EXTENDEDSEL|LBS_OWNERDRAWFIXED,
    CRect(CTRLWIDTH-64,0,CTRLWIDTH,272),this,IDLIST_PALETTES);

  CChildView *view = (CChildView*) this->GetParent();

  palettes.pic = &(view->pic);

  int i;
  for(i=0; i<8; i++){
    int index = palettes.AddString("");
    palettes.SetItemData(index, i);
  }
  /*
  palettes.AddString((char*) -1);
  for(i=0; i<8; i++){
    int index = palettes.AddString("");
    palettes.SetItemData(index, i+8);
  }
  */

  CRect rect(0,0,144,24);
  createPaletteFromSel.Create("Colors->Palette",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_PALETTEFROMSEL);

  rect.OffsetRect(0,24);
  b_setToBGColor.Create("Colors To BG Color",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SETTOBGCOLOR);

  rect.OffsetRect(0,24);
  b_swapWithBGColor.Create("Swap Colors w/BG",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SWAPWITHBGCOLOR);

  rect.OffsetRect(0,32);
  b_autoMapToPalette.Create("AutoMap To Palette",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_AUTOMAPTOPALETTE);

  rect.OffsetRect(0,24);
  b_mapToPalette.Create("Map To Palette",WS_CHILD|WS_VISIBLE,rect,this,
    IDB_MAPTOPALETTE);

  rect.OffsetRect(0,24);
  b_unmap.Create("Unmap",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_UNMAP);

  rect.OffsetRect(0,24);
  b_selectUnmapped.Create("Select Unmapped",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SELECTUNMAPPED);

  rect.OffsetRect(0,24);
  b_autoMapAll.Create("AutoMap All",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_AUTOMAPALL);

  rect.OffsetRect(0,24);
  b_saveGBPic.Create("Save GB Pic",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SAVEGBPIC);

  rect.OffsetRect(0,32);
  b_selectNonEmpty.Create("Select Non-Empty",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SELECTNONEMPTY);

  rect.OffsetRect(0,24);
  b_makeSprites.Create("Make 8x16 Sprites",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_MAKESPRITES);

  rect.OffsetRect(0,24);
  b_saveGBSprite.Create("Save GB Sprite",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SAVEGBSPRITE);

  rect.OffsetRect(0,32);
  b_editPalette.Create("Edit Palette",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_EDITPALETTE);

  rect.OffsetRect(0,24);
  b_showSprites.Create("Show Sprites",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SHOWSPRITES);

  rect.OffsetRect(0,24);
  b_showMapping.Create("Show Mapping",WS_CHILD|WS_VISIBLE,
    rect,this,IDB_SHOWMAPPING);



	return 0;
}

void CControls::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
  CChildView *view = (CChildView*) this->GetParent();

  //------------------------draw magnified area-------------------------------
  CPoint point;
  GetCursorPos(&point);
  view->editArea.ScreenToClient(&point);
  
  //view->pic.GetMagnifiedArea(point.x,point.y)->BlitToDC(&dc, CTRLWIDTH-80,288);
  view->pic.GetMagnifiedArea(point.x,point.y)->BlitToHDC(dc, CTRLWIDTH-80,288);

  //-----------------------draw bg color & selected colors--------------------
  //clear the color area
  dc.FillSolidRect(0,CTRLHEIGHT-16,CTRLWIDTH,CTRLHEIGHT,0x303030);
  CBrush blackBrush;
  blackBrush.CreateSolidBrush(0);

  //draw the bg color
  CRect rect(0,CTRLHEIGHT-16,16,CTRLHEIGHT);
  dc.FillSolidRect(&rect, view->pic.GetBGColor());
  dc.FrameRect(&rect,&blackBrush);

  int count = view->pic.GetNumSelectedColors();
  if(count > 0){
    int pixelsPer = (CTRLWIDTH-32) / count;
    int totalWidth = count * pixelsPer;
    CRect curRect(32,CTRLHEIGHT-16,32+pixelsPer,CTRLHEIGHT);
    gkRGB *colors = view->pic.GetSelectedColors();

    int i;
    for(i=0; i<count; i++){
      dc.FillSolidRect(&curRect, colors[i]);
      curRect += CSize(pixelsPer,0);
    }

    //black border around it all
    curRect = CRect(32,CTRLHEIGHT-16,32+pixelsPer*count,CTRLHEIGHT);
    dc.FrameRect(&curRect,&blackBrush);
  }

}

void CControls::OnMouseMove(UINT nFlags, CPoint point) 
{
  InvalidateMagnifiedArea();
	
	CWnd::OnMouseMove(nFlags, point);
}

void CControls::InvalidateMagnifiedArea()
{
  CRect magView(CTRLWIDTH-80,288,CTRLWIDTH,368);
  InvalidateRect(magView, 0);
}


void CControls::InvalidateColors()
{
  CRect colors(0,CTRLHEIGHT-16,CTRLWIDTH,CTRLHEIGHT);
  InvalidateRect(colors, 0);
  InvalidateEditArea();
}

void CControls::InvalidateEditArea()
{
  view->pic.SetNeedsRedraw();
  view->editArea.InvalidateRect(0);
}

void CControls::OnPaletteFromSel()
{
  int curPal = palettes.GetCurSel();
  if(curPal==-1) return;
  if(curPal>=8) curPal--;   //blank divider item

  int n = view->pic.GetNumSelectedColors();
  if(n>4) n = 4;

  gkRGB *colors = view->pic.GetSelectedColors();

  int i;
  for(i=0; i<n; i++){
    view->pic.SetColor(curPal, i, colors[i]);
  }

  palettes.InvalidateRect(0);
  InvalidateEditArea();
}

void CControls::OnB_SetToBGColor()
{
  //set selected colors to be the background color
  view->pic.RemapSelectedToBGColor();
  InvalidateMagnifiedArea();
  InvalidateEditArea();
}

void CControls::OnB_SwapWithBGColor()
{
  view->pic.SwapSelectedWithBGColor();
  InvalidateMagnifiedArea();
  InvalidateEditArea();
}

void CControls::OnB_AutoMapToPalette()
{
  int pal = 0;
  int numSel = palettes.GetSelItems(17,palettesSelected);
  int i;
  for(i=0; i<numSel; i++){
    pal |= (1 << palettesSelected[i]);
  }
  view->pic.AutoMapToPalette(pal);
  InvalidateEditArea();
}

void CControls::OnB_SelectNonEmpty()
{
  view->pic.SelectNonEmpty();
  InvalidateEditArea();
  InvalidateMagnifiedArea();
}

void CControls::OnB_Unmap()
{
  view->pic.Unmap();
  InvalidateEditArea();
}

void CControls::OnB_MakeSprites()
{
  view->pic.SetCurPalette(palettes.GetCurSel());
  view->pic.MakeSprites();
  InvalidateEditArea();
}

void CControls::OnSelChangePalettes()
{
  //See same in CPaletteListBox
  this->MessageBox("Super!");
}

void CControls::OnB_CheckShowSprites()
{
  showSprites ^= 1;
  view->pic.SetNeedsRedraw();
  InvalidateEditArea();
}

void CControls::OnB_SelectUnmapped()
{
  view->pic.SelectUnmapped();
  InvalidateEditArea();
}

void CControls::OnB_SaveGBSprite()
{
  if(!destFileDialog){
    CString initialDestFilename = view->destFileName;
    if(initialDestFilename.Right(3).CompareNoCase(".sp")!=0) initialDestFilename += ".sp";
    destFileDialog = new CFileDialog(FALSE,".sp", initialDestFilename,
      0, "Sprite Files (.sp)|*.sp||");
  }


  if(destFileDialog->DoModal()==IDOK){
    destFilename = destFileDialog->GetPathName();
    view->pic.SaveGBSprite((char*) (const char*) destFilename);

    char st[80];
    ostrstream stout(st,80);
    stout << view->pic.GetFileSize() << " Bytes" << ends;
    this->MessageBox(st);
  }
}


void CControls::OnB_EditPalette()
{
  gbPic &pic = view->pic;
  
  int pal = pic.GetCurPalette();
  if(pal<0 || pal>7) return;

  CEditPaletteDialog dialog;

  int i;
  for(i=0; i<4; i++){
    dialog.initColors[i] = pic.GetColor(pal,i);
  }

  if(dialog.DoModal()==IDOK){
    for(i=0; i<4; i++){
      pic.SetColor(pal,i,dialog.initColors[i]);
    }
    view->controls.InvalidateEditArea();
  }
}

void CControls::OnB_AutoMapAll()
{
  view->pic.AutoMap(255);
  InvalidateEditArea();
  palettes.Invalidate(0);
}

void CControls::OnB_SaveGBPic()
{
  if(!bgFileDialog){
    CString initialDestFilename = view->destFileName;
    if(initialDestFilename.Right(3).CompareNoCase(".bg")!=0) initialDestFilename += ".bg";
    bgFileDialog = new CBGSaveDialog(FALSE,".bg", initialDestFilename,
      0, "Background (.bg)|*.bg||");
  }

  //CString path = bgFileDialog->GetPathName();
  //CString ext = bgFileDialog->GetFileExt();
  //if(ext.GetLength()>0) path = path.Left(path.GetLength() - ext.GetLength() - 1);
  //strcpy(bgFileDialog->m_ofn.lpstrFile,path);
  if(bgFileDialog->DoModal()==IDOK){
    bgFilename = bgFileDialog->GetPathName();
    //if(bgFileDialog->GetFileExt().CompareNoCase("bg")){
      view->pic.SaveGBPic(bgFilename);
    //}else{
      //view->pic.SaveGBText(bgFilename);
    //}

    char st[80];
    ostrstream stout(st,80);
    stout << view->pic.GetNumUniqueTiles() << " Unique Tiles" << endl;
    stout << view->pic.GetFileSize() << " Bytes" << ends;
    this->MessageBox(st);
  }

  InvalidateEditArea();
  palettes.Invalidate(0);
}

BOOL CControls::OnEraseBkgnd(CDC* pDC) 
{
	CRect rect;
  GetClientRect(&rect);
	
  pDC->FillSolidRect(&rect,0x303030);
  return 1;

	//return CWnd::OnEraseBkgnd(pDC);
}

void CControls::OnB_ShowMapping()
{
  showMapping ^= 1;
  view->pic.SetNeedsRedraw();
  InvalidateEditArea();
}

void CControls::OnB_MapToPalette()
{
  int pal = 0;
  int numSel = palettes.GetSelItems(17,palettesSelected);
  int i;
  for(i=0; i<numSel; i++){
    pal |= (1 << palettesSelected[i]);
  }
  view->pic.MapToPalette(pal);
  InvalidateEditArea();
}
