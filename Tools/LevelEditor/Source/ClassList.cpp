// ClassList.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "ClassList.h"
#include "EditDefines.h"
#include "wingk.h"
#include "strstrea.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CClassList dialog


CClassList::CClassList(CWnd* pParent /*=NULL*/)
	: CDialog(CClassList::IDD, pParent)
{
	//{{AFX_DATA_INIT(CClassList)
	//}}AFX_DATA_INIT
}


void CClassList::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CClassList)
	DDX_Control(pDX, IDC_CLASS_LIST, m_classList);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CClassList, CDialog)
	//{{AFX_MSG_MAP(CClassList)
	ON_WM_CREATE()
	ON_WM_CTLCOLOR()
	ON_LBN_SELCHANGE(IDC_CLASS_LIST, OnSelchangeClassList)
	ON_BN_CLICKED(IDC_CLASSLIST_CLEARALL, OnClasslistClearall)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CClassList message handlers

int CClassList::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CDialog::OnCreate(lpCreateStruct) == -1)
		return -1;
	

	return 0;
}

HBRUSH CClassList::OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor) 
{
	HBRUSH hbr = CDialog::OnCtlColor(pDC, pWnd, nCtlColor);
	
  	
	// TODO: Return a different brush if the default is not desired
	return hbr;
}

BOOL CClassList::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
  m_classList.tileList = tileList;
  int i;
  for(i=2; i<=E_LAST_TILE; i++){
    char st[80];
    ostrstream stout(st,80);
    stout << "Tile " << i << ends;
    int index = m_classList.AddString(st);
    int data = 0;
    if(listOfAllTiles[i]) data |= (1<<16);
    data |= (i & 0xffff);
    m_classList.SetItemData(index, data);
  }
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CClassList::OnSelchangeClassList() 
{
  int index = m_classList.GetCurSel();
  
  //toggle selected bit
  int data = m_classList.GetItemData(index);
  data ^= (1<<16);
  m_classList.SetItemData(index, data);

  if(data & (1<<16)){
    //check was set
    listOfAllTiles[index+2] = 1;
  }else{
    //check was cleared
    listOfAllTiles[index+2] = 0;
  }

  m_classList.InvalidateRect(0);
}

void CClassList::OnClasslistClearall() 
{
  int last = m_classList.GetCount();
  int i;
  for(i=0; i<last; i++){
    int data = m_classList.GetItemData(i);
    data &= ~(1<<16);
    m_classList.SetItemData(i,data);
    listOfAllTiles[i+2] = 0;
  }
  m_classList.InvalidateRect(0);
}
