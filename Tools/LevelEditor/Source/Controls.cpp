// Controls.cpp : implementation file
//

#include <fstream.h>
#include <strstrea.h>
#include "stdafx.h"
#include "EditDefines.h"
#include "LevelEditor.h"
#include "Controls.h"
#include "ChildView.h"
#include "MapWin.h"
#include "ZoneList.h"
#include "WayPointList.h"
#include "ClassList.h"
#include "BGColorDialog.h"
#include "LinkExitsDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define E_TILETITLE "background0001-1535.bmp"
#define E_PEOPLETITLE "objects2048-2303.bmp"

/////////////////////////////////////////////////////////////////////////////
// CControls dialog


CControls::CControls(CWnd* pParent /*=NULL*/)
	: CDialog(CControls::IDD, pParent)
{
	
	gkWinShape temp1, temp2;

	//Load tiles into buffer
	temp1.LoadBMP(E_TILETITLE);

	//CHANGE 
	//go ahead an set the cur tile as first tile in tileBuff
	curTile = 1;
	int i;

	//load all the tiles of a 512 wide file into tileList
	//assuming all tiles are 16 pixel squares
	int tmpIndex = 1;
	for(int j=0;j<(E_TILEBMPSIZEY >> 4);j++)
		for(i=0;i<(E_TILEBMPSIZEX >> 4);i++)
			tileList[tmpIndex++].GetShape(&temp1,i<<4,j<<4,16,16);

	//Load people tiles into buffer
  tmpIndex--;    //start people at 1024, not 1025
	temp2.LoadBMP(E_PEOPLETITLE);
	for(j=0;j<(E_PEOPLEBMPSIZEY >> 4);j++)
		for(i=0;i<(E_PEOPLEBMPSIZEX >> 4);i++)
			tileList[tmpIndex++].GetShape(&temp2,i<<4,j<<4,16,16);

	tileBuff.Create(E_TOTALBUFFERSIZEW,E_TOTALBUFFERSIZEH);
	tileBuff.Cls(gkRGB(0,0,0));
	temp1.Blit(&tileBuff,0,0);
	temp2.Blit(&tileBuff,0,E_TILEBMPSIZEY);

  mapWidth = E_LEVELSIZEX;
  mapHeight = E_LEVELSIZEY;

  //discover map pitch
  mapPitch = 0;
  int temp = mapWidth-1;
  while(temp){
    temp = (temp>>1) & 0x7f;
    mapPitch = (mapPitch<<1) | 1;
  }
  mapPitch++;

  g_wayPointList.SetPitch(mapPitch);

  drawingZones = -1;
  drawingExits = -1;

  metaWidth = metaHeight = 1;
  areaSpecial = 0;

	links[0] = 0x4040;   //+0, +0
  links[1] = 0x4081;   //+0,-1
  links[2] = 0x4140;   //+1,+0
  links[3] = 0x4041;   //+0,+1
  links[4] = 0x8140;   //-1,+0
  links[5] = links[6] = links[7] = 0x4040;  //+0, +0

  isWall = 0;

	//{{AFX_DATA_INIT(CControls)
	//}}AFX_DATA_INIT
}


void CControls::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CControls)
	DDX_Control(pDX, IDC_SORTCLASSESBY, m_sortClassesBy);
	DDX_Control(pDX, IDC_WALLCHECK, m_wallCheck);
	DDX_Control(pDX, IDC_COPYDOWN, m_copyDown);
	DDX_Control(pDX, IDC_COPYLEFT, m_copyLeft);
	DDX_Control(pDX, IDC_COPYRIGHT, m_copyRight);
	DDX_Control(pDX, IDC_COPYUP, m_copyUp);
	DDX_Control(pDX, IDC_SHIFTUP, m_shiftUp);
	DDX_Control(pDX, IDC_SHIFTRIGHT, m_shiftRight);
	DDX_Control(pDX, IDC_SHIFTLEFT, m_shiftLeft);
	DDX_Control(pDX, IDC_SHIFTDOWN, m_shiftDown);
	DDX_Control(pDX, IDC_META_HEIGHT, m_metaHeight);
	DDX_Control(pDX, IDC_META_WIDTH, m_metaWidth);
	DDX_Control(pDX, IDC_RADIO_TILES, m_radioTiles);
	DDX_Control(pDX, IDC_LOAD_FILENAME, m_loadLevel);
	DDX_Control(pDX, IDC_ZONELIST, m_zoneList);
	DDX_Control(pDX, IDC_EDIT_HEIGHT, m_editHeight);
	DDX_Control(pDX, IDC_EDIT_WIDTH, m_editWidth);
	DDX_Control(pDX, IDC_CURTILE, m_loadlevelname);
	DDX_Control(pDX, IDC_SAVELEVEL, m_levelname);
	DDX_Control(pDX, IDC_SHOWGRIDS, m_showGrids);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CControls, CDialog)
	//{{AFX_MSG_MAP(CControls)
	ON_BN_CLICKED(IDC_SHOWGRIDS, OnShowgrids)
	ON_WM_PAINT()
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_BN_CLICKED(IDC_WRITEFILE, OnWritefile)
	ON_BN_CLICKED(IDC_LOAD, OnLoad)
	ON_BN_CLICKED(IDC_CLEAR, OnClear)
	ON_EN_KILLFOCUS(IDC_EDIT_HEIGHT, OnKillfocusEditHeight)
	ON_EN_KILLFOCUS(IDC_EDIT_WIDTH, OnKillfocusEditWidth)
	ON_WM_MEASUREITEM()
	ON_WM_DRAWITEM()
	ON_LBN_SELCHANGE(IDC_ZONELIST, OnSelchangeZonelist)
	ON_BN_CLICKED(IDC_BUTTON_CLASSLIST, OnButtonClasslist)
	ON_WM_DESTROY()
	ON_WM_KEYDOWN()
	ON_BN_CLICKED(IDC_RADIO_TILES, OnRadioTiles)
	ON_BN_CLICKED(IDC_RADIO_ZONES, OnRadioZones)
	ON_BN_CLICKED(IDC_RADIO_EXITS, OnRadioExits)
	ON_BN_CLICKED(IDC_BGCOLOR, OnBgcolor)
	ON_BN_CLICKED(IDC_SETMETA_1X1, OnSetmeta1x1)
	ON_BN_CLICKED(IDC_SETMETA_2X2, OnSetmeta2x2)
	ON_EN_CHANGE(IDC_META_WIDTH, OnChangeMetaWidth)
	ON_EN_CHANGE(IDC_META_HEIGHT, OnChangeMetaHeight)
	ON_BN_CLICKED(IDC_SHIFTUP, OnShiftup)
	ON_BN_CLICKED(IDC_SHIFTRIGHT, OnShiftright)
	ON_BN_CLICKED(IDC_SHIFTDOWN, OnShiftdown)
	ON_BN_CLICKED(IDC_SHIFTLEFT, OnShiftleft)
	ON_BN_CLICKED(IDC_COPYUP, OnCopyup)
	ON_BN_CLICKED(IDC_COPYRIGHT, OnCopyright)
	ON_BN_CLICKED(IDC_COPYDOWN, OnCopydown)
	ON_BN_CLICKED(IDC_COPYLEFT, OnCopyleft)
	ON_BN_CLICKED(IDC_BUTTON_LINKEXITS, OnButtonLinkexits)
	ON_BN_CLICKED(IDC_WALLCHECK, OnWallcheck)
	ON_BN_CLICKED(IDC_SETMETA_3x3, OnSETMETA3x3)
	ON_BN_CLICKED(IDC_SETMETA_4x4, OnSETMETA4x4)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CControls message handlers

void CControls::OnShowgrids() 
{
	CChildView* papa;

	if(!::IsWindow(this->m_hWnd))
		return;


	//grab a pointer to the view
	papa = (CChildView*)this->GetParent();
	//if(!papa)
	//	return;

	// TODO: Add your control notification handler code here
	if(m_showGrids.GetCheck())
	{
		papa->SetGrids(true);
	}else
		papa->SetGrids(false);
	
}

void CControls::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
	// TODO: Add your message handler code here

	/////////////////Draw Current Tile/////////////////

	// draw Box
	dc.MoveTo(15,50);
	dc.LineTo(15,74);
	dc.MoveTo(15,50);
	dc.LineTo(39,50);
	dc.MoveTo(39,50);
	dc.LineTo(39,74);
	dc.MoveTo(39,74);
	dc.LineTo(15,74);
	//draw current tile
	tileList[curTile].BlitToDC(&dc,19,54);
	

	// Do not call CDialog::OnPaint() for painting messages
}


// grab pointer to the current tile
gkWinShape *CControls::GrabCurTilePointer()
{
	return &tileList[curTile];
}

int CControls::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CDialog::OnCreate(lpCreateStruct) == -1)
		return -1;
	
	// TODO: Add your specialized creation code here

	// TODO: Add your specialized creation code here
	terrainTiles.Create(NULL, NULL, WS_CHILD | WS_VISIBLE | WS_HSCROLL | WS_VSCROLL
		, CRect(0,0,0,0), this, 0, 0);
	terrainTiles.ShowWindow(SW_SHOW);

	return 0;
}

void CControls::OnSize(UINT nType, int cx, int cy) 
{
	CDialog::OnSize(nType, cx, cy);
	
	CRect rect;
  this->GetClientRect(&rect);
	terrainTiles.SetWindowPos(&wndTop,5,100,rect.Width()-10,189,SWP_SHOWWINDOW );

  /*
	SCROLLINFO info;
	info.cbSize = sizeof(SCROLLINFO);
	info.fMask = SIF_ALL;
	info.nPage = 32;
	info.nMin = 0;
	info.nMax = TERRAINSCROLLMAXV;
	info.nPos = 0;
	terrainTiles.SetScrollInfo(SB_HORZ, &info);
	terrainTiles.SetScrollInfo(SB_VERT, &info);
  */

}

gkWinShape* CControls::GrabTileBuffer(){
	return &tileBuff;
}

void CControls::SetCurTilePointer(int index)
{
	curTile = index;
	this->InvalidateRect(0);
}

// when this button is pressed we want to take the current file
// and write it to a .lvl gb binary
void CControls::OnWritefile() 
{
	ofstream	output;
	CMapWin* mapWin;
	int i;//declare on top for compatibility

	char str[80];

	m_levelname.GetWindowText(str,80);
	//m_levelname
	if(!strcmp(str,""))
	{
		output.open(E_DEFAULTFILENAME, ios::out | ios::binary);
		if(output.fail())
		{
			this->MessageBox("Couldn't open file bitch ass");
			return;
		}
	}else{
		output.open(str, ios::out | ios::binary);
		if(output.fail())
		{
			this->MessageBox("Couldn't open file bitch ass");
			return;
		}
	}

  //add to drop-down filename list?
  if(m_loadLevel.FindStringExact(0,str)==CB_ERR){
    //m_loadLevel.InsertString(0,str);
	m_loadLevel.AddString(str);
  }

	mapWin = (CMapWin*)(((CChildView*)this->GetParent())->GrabWinMap());
	
  output.put((char) 3);   //file format version 3
  //2:  Added exit arrays
  //3:  Added exit links
	//---------------------write number of classes used-------------------
	unsigned char totalTilesUsed = mapWin->getTotalTilesUsed()-1;
	output.write(&totalTilesUsed, sizeof(unsigned char));

	//remap tiles
	mapWin->remapMonsters();

	//---------------------write index of first monster---------------
	short int firstCharacterID;
	short int* listOfAllTiles;

	unsigned char firstCharacterIndex;
	listOfAllTiles = mapWin->getListOfTilesUsed();

	firstCharacterID = (E_TILEBMPSIZEX >> 4) * (E_TILEBMPSIZEY >> 4);
	
	firstCharacterIndex=0;
	while((firstCharacterIndex<totalTilesUsed+1) && listOfAllTiles[firstCharacterIndex] < firstCharacterID)
	 firstCharacterIndex++;

	output.write((char*)&firstCharacterIndex,sizeof(unsigned char));

  //absolute first character class
  output.put((char) (firstCharacterID & 0xff));
  output.put((char) ((firstCharacterID>>8) & 0xff));
	
	//---------------------write full id for each tile--------------------

	for(i=1;i<=totalTilesUsed;i++)
		output.write((char*)&listOfAllTiles[i],sizeof(short int));
	
	//---------------------write level width------------------------------
	unsigned char width = mapWidth;
	output.write(&width, sizeof(unsigned char));

	//----------------------write level pitch-----------------------------
	unsigned char pitch;

  pitch = 1;
  while(pitch < width) pitch *= 2;

	output.write(&pitch,sizeof(unsigned char));
	
	//--------------------write level height------------------------------
	unsigned char height = mapHeight;
	output.write(&height, sizeof(unsigned char));

	//--------------------write level indeces-----------------------------
	PicStruct envArray[256][256];
	mapWin->getEnvArray(envArray);


  int numBGTiles = 0;
  int numObjects = 0;
  for(i=0;i<height;i++){
    for(int j=0;j<width;j++){
      output.put((char) envArray[j][i].index);
      if(envArray[j][i].index>=firstCharacterIndex){
        numObjects++;
      }else{
        numBGTiles++;
      }
			//output.write(&(envArray[j][i].index), sizeof(unsigned char));
    }
  }

	//--------------------write background color---------------------------
	int backgroundColor = mapWin->getBackgroundColor();
	short int modifiedColor = 0;
	int mask1 = 0x00FF0000;
	int mask2 = 0x0000FF00;
	int mask3 = 0x000000FF;

	unsigned char blue = ((backgroundColor & mask1) >> 16);
	unsigned char green = ((backgroundColor & mask2) >> 8);
	unsigned char red = (backgroundColor & mask3);

	modifiedColor |= (blue >> 3)<< 10;
	modifiedColor |= (green >> 3)<< 5;
	modifiedColor |= (red >> 3);

	output.write((char *)&modifiedColor,sizeof(short int));

  //--------------------let the WayPointList write itself----------------
  g_wayPointList.Write(output);

  //------------tell the map to write the zones & exit info--------------
  mapWin->WriteZones(output);  
  mapWin->WriteExits(output);

  //------------Write the exit links-------------------------------------
  output << (char) 0 << (char) 0;
  for(i=1; i<8; i++){
    output << (char) (links[i] & 0xff) << (char) ((links[i]>>8) & 0xff);
  }

	output.close();

  //Display results
  char st[80];
  ostrstream stout(st,80);
  stout << "Number of Classes:  " << (mapWin->getTotalTilesUsed()-1) << endl;
  stout << "Number of Objects:  " << numObjects << ends;
  MessageBox(st,"Statistics");
}


int CControls::GrabCurTileIndex()
{
	return curTile;
}


void CControls::OnCancel() 
{
	// TODO: Add extra cleanup here
	
//	CDialog::OnCancel();
}

void CControls::OnOK() 
{
	// TODO: Add extra validation here
	
//	CDialog::OnOK();
}

void CControls::OnLoad() 
{
	// TODO: Add your control notification handler code here
	char str[80];
	m_loadLevel.GetWindowText(str,80);
  m_levelname.SetWindowText(str);

	CMapWin* mapWin;
	mapWin = (CMapWin*)(((CChildView*)this->GetParent())->GrabWinMap());


	if(!strcmp(str,""))
	{
		this->MessageBox("You need to specify a level name bitch ass");
		return;
	}

  //add to drop-down filename list?
  if(m_loadLevel.FindStringExact(0,str)==CB_ERR){
    m_loadLevel.InsertString(0,str);
  }

	mapWin->loadLevel(str);
  offset_x = 0;
  offset_y = 0;
}

void CControls::OnClear() 
{
	// TODO: Add your control notification handler code here
		CMapWin* mapWin;
		mapWin = (CMapWin*)(((CChildView*)this->GetParent())->GrabWinMap());
		mapWin->clearLevel();
		mapWin->InvalidateRect(0);

	  links[0] = 0x4040;   //+0, +0
    links[1] = 0x4081;   //+0,-1
    links[2] = 0x4140;   //+1,+0
    links[3] = 0x4041;   //+0,+1
    links[4] = 0x8140;   //-1,+0
    links[5] = links[6] = links[7] = 0x4040;

    m_levelname.SetWindowText("unnamed.lvl");
}

//return a pointer to a picture at a given index
gkWinShape* CControls::GrabPicAt(int index)
{
	return &tileList[index];
}

int CControls::GetMapWidth()
{
  return mapWidth;
}

int CControls::GetMapHeight()
{
  return mapHeight;
}

void CControls::SetMapWidth(int n)
{
  mapWidth = n;
  char st[80];
  ostrstream stout(st,80);
  stout << n << ends;
  m_editWidth.SetWindowText(st);

}

void CControls::SetMapHeight(int n)
{
  mapHeight = n;
  char st[80];
  ostrstream stout(st,80);
  stout << n << ends;
  m_editHeight.SetWindowText(st);
}

void CControls::SetOffsetX(int n)
{
  offset_x = n;
}

void CControls::SetOffsetY(int n)
{
  offset_y = n;
}

int  CControls::GetOffsetX()
{
  return offset_x;
}

int  CControls::GetOffsetY()
{
  return offset_y;
}

void CControls::OnKillfocusEditHeight() 
{
  char st[80];
  m_editHeight.GetWindowText(st,80);
  istrstream stin(st,80);
  stin >> mapHeight;
  offset_y = 0;
  
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *mapWin = view->GrabWinMap();
  mapWin->SetScrollBarPositions();
  mapWin->InvalidateRect(0);
}

void CControls::OnKillfocusEditWidth() 
{
  char st[80];
  m_editWidth.GetWindowText(st,80);
  istrstream stin(st,80);
  stin >> mapWidth;
  offset_x = 0;

  //discover map pitch
  mapPitch = 0;
  int temp = mapWidth-1;
  while(temp){
    temp = (temp>>1) & 0x7f;
    mapPitch = (mapPitch<<1) | 1;
  }
  mapPitch++;
  g_wayPointList.SetPitch(mapPitch);
  
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *mapWin = view->GrabWinMap();
  mapWin->SetScrollBarPositions();
  mapWin->InvalidateRect(0);
}

void CControls::OnMeasureItem(int nIDCtl, LPMEASUREITEMSTRUCT lpMeasureItemStruct) 
{
  lpMeasureItemStruct->itemWidth = 16;
  lpMeasureItemStruct->itemHeight = 16;

	CDialog::OnMeasureItem(nIDCtl, lpMeasureItemStruct);
}


void CControls::OnDrawItem(int nIDCtl, LPDRAWITEMSTRUCT lpDrawItemStruct) 
{
	
	CDialog::OnDrawItem(nIDCtl, lpDrawItemStruct);
}

BOOL CControls::OnInitDialog() 
{
	CDialog::OnInitDialog();

	HANDLE findFileHandle;
	WIN32_FIND_DATA findFileData;

	findFileHandle = FindFirstFile("L*.lvl",&findFileData);
	do{
		m_loadLevel.AddString(findFileData.cFileName);
	}while(FindNextFile(findFileHandle,&findFileData));
	/*
  ifstream recentFiles("recentFiles.txt",ios::in|ios::nocreate);
  if(!(!recentFiles)){
    char st[80];
    recentFiles.getline(st,80);
    while(!recentFiles.eof()){
      m_loadLevel.AddString(st);
      recentFiles.getline(st,80);
    }

    recentFiles.close();
  }
  */

  int i;
  for(i=0; i<16; i++) m_zoneList.AddString((char*) i);

  m_zoneList.SetCurSel(0);

  m_editWidth.SetWindowText("32");
  m_editHeight.SetWindowText("32");

  m_radioTiles.SetCheck(1);

  m_metaWidth.SetWindowText("1");
  m_metaHeight.SetWindowText("1");

  m_wallCheck.SetCheck(0);
  
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CControls::OnCheckShowzones() 
{
  /*
  if(m_checkShowZones.GetCheck()){
    drawingZones = m_zoneList.GetCurSel();
  }else{
    drawingZones = -1;
  }

  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  map->InvalidateRect(0);
  */
}

int CControls::GetDrawingZones()
{
  return drawingZones;
}

void CControls::OnSelchangeZonelist() 
{
  if(drawingZones>=0) drawingZones = m_zoneList.GetCurSel();	
  else if(drawingExits>=0) drawingExits = MapIndexToExit(m_zoneList.GetCurSel());
}

int CControls::GetMapPitch()
{
  return mapPitch;
}

void CControls::OnButtonClasslist() 
{
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  CClassList classList;
  classList.listOfTilesUsed = map->getListOfTilesUsed();
  classList.listOfAllTiles = map->getListOfAllTiles();
  classList.totalTilesUsed = map->getTotalTilesUsed();
  classList.tileList = this->tileList;
  classList.DoModal();

  map->RemakeListOfTilesUsed();
}

void CControls::OnDestroy() 
{
  //write out recent files list
	/*
  ofstream outfile("recentFiles.txt",ios::out);
  char st[80];
  int n = m_loadLevel.GetCount();
  int i;
  for(i=0; i<n; i++){
    if(i>20) break;
    m_loadLevel.GetLBText(i,st);
    outfile << st << endl;
  }
  outfile.close();
  */

	CDialog::OnDestroy();	
}

void CControls::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
  switch(nChar){
    case VK_LEFT:
      curTile--;
      this->InvalidateRect(0);
      break;
    case VK_RIGHT:
      curTile++;
      this->InvalidateRect(0);
      break;
    case VK_UP:
      curTile-=32;
      this->InvalidateRect(0);
      break;
    case VK_DOWN:
      curTile+=32;
      this->InvalidateRect(0);
      break;
  }
  if(curTile<0) curTile=0;
  else if(curTile>E_LASTTILE) curTile=E_LASTTILE;
	CDialog::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CControls::SendToKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)
{
  OnKeyDown(nChar,nRepCnt,nFlags);
}

void CControls::OnRadioTiles() 
{
  drawingZones = -1;
  drawingExits = -1;
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  map->InvalidateRect(0);
  m_zoneList.InvalidateRect(0);
}

void CControls::OnRadioZones() 
{
  drawingZones = m_zoneList.GetCurSel();
  drawingExits = -1;
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  map->InvalidateRect(0);
  m_zoneList.InvalidateRect(0);
}

void CControls::OnRadioExits() 
{
	drawingZones = -1;
  drawingExits = MapIndexToExit(m_zoneList.GetCurSel());

  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  map->InvalidateRect(0);
  m_zoneList.InvalidateRect(0);
}

int CControls::MapIndexToExit(int n)
{
  static int map[17] = {7,4,4,7, 1,5,6,3, 1,5,6,3, 7,2,2,7};
  return map[n];
}

int CControls::GetDrawingExits()
{
  return drawingExits;
}

void CControls::OnBgcolor() 
{
  CChildView *view = (CChildView*) this->GetParent();
  CMapWin *map = view->GrabWinMap();

  CBGColorDialog dialog;

  int color = map->getBackgroundColor();
  dialog.initRed = (color & 0xff);
  dialog.initGreen = ((color >> 8) & 0xff);
  dialog.initBlue = ((color >> 16) & 0xff);

  if(dialog.DoModal()==IDOK){
    int r = dialog.initRed;
    int g = dialog.initGreen;
    int b = dialog.initBlue;
    color = (b<<16) | (g<<8) | r;
    map->setBackgroundColor(color);
    map->InvalidateRect(0);
  }
}

void CControls::OnSetmeta1x1() 
{
  isWall = 0;
  m_wallCheck.SetCheck(0);

  metaWidth = metaHeight = 1;
  m_metaWidth.SetWindowText("1");
  m_metaHeight.SetWindowText("1");
}

void CControls::OnSetmeta2x2() 
{
  isWall = 0;
  m_wallCheck.SetCheck(0);

  metaWidth = metaHeight = 2;
  m_metaWidth.SetWindowText("2");
  m_metaHeight.SetWindowText("2");
}

void CControls::OnChangeMetaWidth() 
{
  metaWidth = LimitEditValue(m_metaWidth, 1, 10);
}

int CControls::LimitEditValue(CEdit &edit, int min, int max)
{
  char st[80];
  edit.GetWindowText(st,80);

  istrstream stin(st,80);
  int n;
  stin >> n;

  if(n < min || n > max){
    if(n<min) n = min;
    else      n = max;
    ostrstream stout(st,80);
    stout << n << ends;
    edit.SetWindowText(st);
  }

  return n; 
}

void CControls::OnChangeMetaHeight() 
{
  metaHeight = LimitEditValue(m_metaHeight, 1, 10);
}

gkWinShape* CControls::GrabTilePointer(int n)
{
  return &tileList[n];
}

void CControls::OnShiftup() 
{
  if(m_shiftUp.GetCheck()) areaSpecial |= 1;
  else                     areaSpecial &= ~1;
}

void CControls::OnShiftright() 
{
  if(m_shiftRight.GetCheck()) areaSpecial |= 2;
  else                        areaSpecial &= ~2;
}

void CControls::OnShiftdown() 
{
  if(m_shiftDown.GetCheck()) areaSpecial |= 4;
  else                       areaSpecial &= ~4;
}

void CControls::OnShiftleft() 
{
  if(m_shiftLeft.GetCheck()) areaSpecial |= 8;
  else                       areaSpecial &= ~8;	
}

void CControls::OnCopyup() //cut
{
  if(m_copyUp.GetCheck()) areaSpecial |= 16;
  else                    areaSpecial &= ~16;	

  if(m_copyRight.GetCheck()){ 
    m_copyRight.SetCheck(0);
    areaSpecial &= ~32;
  }

  if(m_copyDown.GetCheck()){
    m_copyDown.SetCheck(0);
    areaSpecial &= ~64;
  }
}

void CControls::OnCopyright() //copy
{
  if(m_copyRight.GetCheck()) areaSpecial |= 32;
  else                    areaSpecial &= ~32;	

  if(m_copyUp.GetCheck()){ 
    m_copyUp.SetCheck(0);
    areaSpecial &= ~16;
  }

  if(m_copyDown.GetCheck()){
    m_copyDown.SetCheck(0);
    areaSpecial &= ~64;
  }
}

void CControls::OnCopydown() //paste
{
  if(m_copyDown.GetCheck()) areaSpecial |= 64;
  else                    areaSpecial &= ~64;	

  if(m_copyRight.GetCheck()){ 
    m_copyRight.SetCheck(0);
    areaSpecial &= ~32;
  }

  if(m_copyUp.GetCheck()){
    m_copyUp.SetCheck(0);
    areaSpecial &= ~16;
  }
}

void CControls::OnCopyleft() 
{
  if(m_copyLeft.GetCheck()) areaSpecial |= 128;
  else                    areaSpecial &= ~128;	
}

void CControls::OnButtonLinkexits() 
{
  CLinkExitsDialog dialog;

	dialog.initNorthExit = links[1];
	dialog.initEastExit  = links[2];
	dialog.initSouthExit = links[3];
	dialog.initWestExit  = links[4];
	dialog.initUpExit    = links[5];
	dialog.initDownExit  = links[6];
	dialog.initExitExit  = links[7];

  if(dialog.DoModal()==IDOK){
		links[1] = dialog.initNorthExit;
		links[2] = dialog.initEastExit;
		links[3] = dialog.initSouthExit;
		links[4] = dialog.initWestExit;
		links[5] = dialog.initUpExit;
		links[6] = dialog.initDownExit;
		links[7] = dialog.initExitExit;
  }
}

void CControls::OnWallcheck() 
{
  metaWidth = metaHeight = 1;
  m_metaWidth.SetWindowText("1");
  m_metaHeight.SetWindowText("1");
  
  if(m_wallCheck.GetCheck()) isWall = 1;
  else isWall = 0;
}

void CControls::OnSETMETA3x3() 
{
  isWall = 0;
  m_wallCheck.SetCheck(0);

  metaWidth = metaHeight = 3;
  m_metaWidth.SetWindowText("3");
  m_metaHeight.SetWindowText("3");
}

void CControls::OnSETMETA4x4() 
{
  isWall = 0;
  m_wallCheck.SetCheck(0);

  metaWidth = metaHeight = 4;
  m_metaWidth.SetWindowText("4");
  m_metaHeight.SetWindowText("4");
}

int CControls::GetSortClassesBy()
{
	return m_sortClassesBy.GetCheck();
}
