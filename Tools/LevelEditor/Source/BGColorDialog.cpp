// BGColorDialog.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "BGColorDialog.h"
#include <strstrea.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

int CBGColorDialog::initRed   = 0;
int CBGColorDialog::initGreen = 0;
int CBGColorDialog::initBlue  = 0;

/////////////////////////////////////////////////////////////////////////////
// CBGColorDialog dialog


CBGColorDialog::CBGColorDialog(CWnd* pParent /*=NULL*/)
	: CDialog(CBGColorDialog::IDD, pParent)
{
	//{{AFX_DATA_INIT(CBGColorDialog)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CBGColorDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CBGColorDialog)
	DDX_Control(pDX, IDC_COLOR, m_colorFrame);
	DDX_Control(pDX, IDC_RED, m_red);
	DDX_Control(pDX, IDC_GREEN, m_green);
	DDX_Control(pDX, IDC_BLUE, m_blue);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CBGColorDialog, CDialog)
	//{{AFX_MSG_MAP(CBGColorDialog)
	ON_EN_KILLFOCUS(IDC_RED, OnKillfocusRed)
	ON_EN_KILLFOCUS(IDC_GREEN, OnKillfocusGreen)
	ON_EN_KILLFOCUS(IDC_BLUE, OnKillfocusBlue)
	ON_WM_PAINT()
	ON_EN_CHANGE(IDC_RED, OnChangeRed)
	ON_EN_CHANGE(IDC_GREEN, OnChangeGreen)
	ON_EN_CHANGE(IDC_BLUE, OnChangeBlue)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CBGColorDialog message handlers

BOOL CBGColorDialog::OnInitDialog() 
{
	CDialog::OnInitDialog();

  SetValue(m_red, initRed);
  SetValue(m_green, initGreen);
  SetValue(m_blue, initBlue);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CBGColorDialog::SetValue(CEdit &edit, int val)
{
  char st[80];
  ostrstream stout(st,80);
  stout << val << ends;
  edit.SetWindowText(st);
}

int CBGColorDialog::GetValue(CEdit &edit)
{
  char st[80];
  edit.GetWindowText(st,80);
  istrstream stin(st,80);
  
  int n;
  stin >> n;
  return n;
}

void CBGColorDialog::LimitValue(CEdit &edit, int min, int max)
{
  int n = GetValue(edit);
  if(n < min || n > max){
    if(n<min) n = min;
    else      n = max;
    SetValue(edit, n);
  }
}

void CBGColorDialog::OnKillfocusRed() 
{
	LimitValue(m_red, 0, 255);
  initRed = GetValue(m_red);
  this->InvalidateRect(0);
}

void CBGColorDialog::OnKillfocusGreen() 
{
	LimitValue(m_green, 0, 255);
  initGreen = GetValue(m_green);
  this->InvalidateRect(0);
}

void CBGColorDialog::OnKillfocusBlue() 
{
  LimitValue(m_blue, 0, 255);
  initBlue = GetValue(m_blue);
  this->InvalidateRect(0);
}

void CBGColorDialog::OnOK() 
{
	CDialog::OnOK();
}

void CBGColorDialog::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
  CRect rect;
  m_colorFrame.GetWindowRect(&rect);
  this->ScreenToClient(&rect);

  int color = (initBlue<<16) | (initGreen<<8) | initRed;
  dc.FillSolidRect(&rect,color);

	// Do not call CDialog::OnPaint() for painting messages
}

void CBGColorDialog::OnChangeRed() 
{
  this->OnKillfocusRed();	
}

void CBGColorDialog::OnChangeGreen() 
{
  this->OnKillfocusGreen();	
}

void CBGColorDialog::OnChangeBlue() 
{
  this->OnKillfocusBlue();	
}
