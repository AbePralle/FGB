// EditPaletteDialog.cpp : implementation file
//

#include "stdafx.h"
#include "GBConv2.h"
#include "EditPaletteDialog.h"
#include <strstrea.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CEditPaletteDialog dialog


CEditPaletteDialog::CEditPaletteDialog(CWnd* pParent /*=NULL*/)
	: CDialog(CEditPaletteDialog::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEditPaletteDialog)
	//}}AFX_DATA_INIT
}


void CEditPaletteDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEditPaletteDialog)
	DDX_Control(pDX, IDC_EDIT_PAL_RED3, m_editRed3);
	DDX_Control(pDX, IDC_EDIT_PAL_RED2, m_editRed2);
	DDX_Control(pDX, IDC_EDIT_PAL_RED1, m_editRed1);
	DDX_Control(pDX, IDC_EDIT_PAL_RED0, m_editRed0);
	DDX_Control(pDX, IDC_EDIT_PAL_GREEN3, m_editGreen3);
	DDX_Control(pDX, IDC_EDIT_PAL_GREEN2, m_editGreen2);
	DDX_Control(pDX, IDC_EDIT_PAL_GREEN1, m_editGreen1);
	DDX_Control(pDX, IDC_EDIT_PAL_GREEN0, m_editGreen0);
	DDX_Control(pDX, IDC_EDIT_PAL_BLUE3, m_editBlue3);
	DDX_Control(pDX, IDC_EDIT_PAL_BLUE2, m_editBlue2);
	DDX_Control(pDX, IDC_EDIT_PAL_BLUE1, m_editBlue1);
	DDX_Control(pDX, IDC_EDIT_PAL_BLUE0, m_editBlue0);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEditPaletteDialog, CDialog)
	//{{AFX_MSG_MAP(CEditPaletteDialog)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CEditPaletteDialog message handlers

void CEditPaletteDialog::OnOK() 
{
  //copy working colors to initColors
  initColors[0] = gkRGB(GetNum(m_editRed0),GetNum(m_editGreen0),GetNum(m_editBlue0));
  initColors[1] = gkRGB(GetNum(m_editRed1),GetNum(m_editGreen1),GetNum(m_editBlue1));
  initColors[2] = gkRGB(GetNum(m_editRed2),GetNum(m_editGreen2),GetNum(m_editBlue2));
  initColors[3] = gkRGB(GetNum(m_editRed3),GetNum(m_editGreen3),GetNum(m_editBlue3));

	CDialog::OnOK();
}

int CEditPaletteDialog::GetNum(CEdit &edit)
{
  char st[80];
  edit.GetWindowText(st,80);
  istrstream stin(st,80);
  
  int num;
  stin >> num;

  if(num<0) num = 0;
  if(num>255) num = 255;
  num &= 0xf8;
  return num;
}

BOOL CEditPaletteDialog::OnInitDialog() 
{
	CDialog::OnInitDialog();

  SetNum(m_editRed0,initColors[0].GetR());
  SetNum(m_editRed1,initColors[1].GetR());
  SetNum(m_editRed2,initColors[2].GetR());
  SetNum(m_editRed3,initColors[3].GetR());
  SetNum(m_editGreen0,initColors[0].GetG());
  SetNum(m_editGreen1,initColors[1].GetG());
  SetNum(m_editGreen2,initColors[2].GetG());
  SetNum(m_editGreen3,initColors[3].GetG());
  SetNum(m_editBlue0,initColors[0].GetB());
  SetNum(m_editBlue1,initColors[1].GetB());
  SetNum(m_editBlue2,initColors[2].GetB());
  SetNum(m_editBlue3,initColors[3].GetB());
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CEditPaletteDialog::SetNum(CEdit &edit, int n)
{
  char st[80];
  ostrstream stout(st,80);
  n &= 0xff;
  stout << n << ends;
  edit.SetWindowText(st);
}
