// LinkExitsDialog.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "LinkExitsDialog.h"
#include <strstrea.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//static variables
int CLinkExitsDialog::initNorthExit = 0;
int CLinkExitsDialog::initEastExit = 0;
int CLinkExitsDialog::initSouthExit = 0;
int CLinkExitsDialog::initWestExit = 0;
int CLinkExitsDialog::initUpExit = 0;
int CLinkExitsDialog::initDownExit = 0;
int CLinkExitsDialog::initExitExit = 0;

/////////////////////////////////////////////////////////////////////////////
// CLinkExitsDialog dialog


CLinkExitsDialog::CLinkExitsDialog(CWnd* pParent /*=NULL*/)
	: CDialog(CLinkExitsDialog::IDD, pParent)
{
	//{{AFX_DATA_INIT(CLinkExitsDialog)
	//}}AFX_DATA_INIT
}


void CLinkExitsDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CLinkExitsDialog)
	DDX_Control(pDX, IDC_WESTEXIT, m_westExit);
	DDX_Control(pDX, IDC_UPEXIT, m_upExit);
	DDX_Control(pDX, IDC_SOUTHEXIT, m_southExit);
	DDX_Control(pDX, IDC_NORTHEXIT, m_northExit);
	DDX_Control(pDX, IDC_EXITEXIT, m_exitExit);
	DDX_Control(pDX, IDC_EASTEXIT, m_eastExit);
	DDX_Control(pDX, IDC_DOWNEXIT, m_downExit);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CLinkExitsDialog, CDialog)
	//{{AFX_MSG_MAP(CLinkExitsDialog)
	ON_EN_KILLFOCUS(IDC_NORTHEXIT, OnKillfocusNorthexit)
	ON_EN_KILLFOCUS(IDC_EASTEXIT, OnKillfocusEastexit)
	ON_EN_KILLFOCUS(IDC_SOUTHEXIT, OnKillfocusSouthexit)
	ON_EN_KILLFOCUS(IDC_WESTEXIT, OnKillfocusWestexit)
	ON_EN_KILLFOCUS(IDC_UPEXIT, OnKillfocusUpexit)
	ON_EN_KILLFOCUS(IDC_DOWNEXIT, OnKillfocusDownexit)
	ON_EN_KILLFOCUS(IDC_EXITEXIT, OnKillfocusExitexit)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CLinkExitsDialog message handlers

void CLinkExitsDialog::DisplayLink(CEdit &edit, int link)
{
  char st[80];
  ostrstream stout(st,80);
  int x = (link >> 8) & 0xff;
  int y = link & 0xff;

  //x and y are in BCD form; convert to normal (1st digit will be 0 or 1)
  //preserve upper 3 bits of each byte unchanged
  x = (((x>>4) & 1) * 10 + (x & 0x0f)) | (x & 0xe0);
  y = (((y>>4) & 1) * 10 + (y & 0x0f)) | (y & 0xe0);

  if(x < 16) stout << x << ", ";
  else if(x & 64) stout << "+" << (x & 15) << ", ";
  else            stout << "-" << (x & 15) << ", ";

  if(y < 16)      stout << y << ends;
  else if(y & 64) stout << "+" << (y & 15) << ends;
  else            stout << "-" << (y & 15) << ends;

  edit.SetWindowText(st);
}

int CLinkExitsDialog::RetrieveLink(CEdit &edit)
{
  char st[80];
  edit.GetWindowText(st,80);
  
  int i,x,y;

  //eliminate white space
  for(i=0; st[i]; i++){
    if(st[i]!=' ') break;
  }

  //get x value
  x = 0;
  for(; st[i]; i++){
    if(st[i]=='+') x |= 64;
    else if(st[i]=='-') x |= 128;
    else if(st[i]>='0' && st[i]<='9') x = (x & 0xe0) | ((x & 1) * 10 + (st[i]-'0'));
    else break;
  }

  //skip comma and whitespace
  y = 0;
  for(; st[i]; i++){
    if(st[i]!=',' && st[i]!=' ') break;
  }

  //get y value
  y = 0;
  for(; st[i]; i++){
    if(st[i]=='+') y |= 64;
    else if(st[i]=='-') y |= 128;
    else if(st[i]>='0' && st[i]<='9') y = (y & 0xe0) | ((y & 1) * 10 + (st[i]-'0'));
    else break;
  }

  //convert values to BCD, preserving upper 3 bits
  x = (x & 0xe0) | ((((x & 31)/10)<<4) + ((x&31)%10));
  y = (y & 0xe0) | ((((y & 31)/10)<<4) + ((y&31)%10));

  i = (x << 8) | y;

  //redisplay our interpretation of the input
  DisplayLink(edit,i);

  return i;
}


void CLinkExitsDialog::OnKillfocusNorthexit() 
{
  initNorthExit = RetrieveLink(m_northExit);
}


void CLinkExitsDialog::OnKillfocusEastexit() 
{
  initEastExit = RetrieveLink(m_eastExit);
}

void CLinkExitsDialog::OnKillfocusSouthexit() 
{
  initSouthExit = RetrieveLink(m_southExit);	
}

void CLinkExitsDialog::OnKillfocusWestexit() 
{
  initWestExit = RetrieveLink(m_westExit);	
}

void CLinkExitsDialog::OnKillfocusUpexit() 
{
  initUpExit = RetrieveLink(m_upExit);	
}

void CLinkExitsDialog::OnKillfocusDownexit() 
{
  initDownExit = RetrieveLink(m_downExit);	
}

void CLinkExitsDialog::OnKillfocusExitexit() 
{
	initExitExit = RetrieveLink(m_exitExit);
}

BOOL CLinkExitsDialog::OnInitDialog() 
{
	CDialog::OnInitDialog();

  DisplayLink(m_northExit, initNorthExit);
  DisplayLink(m_eastExit,  initEastExit);
  DisplayLink(m_southExit, initSouthExit);	
  DisplayLink(m_westExit,  initWestExit);	
  DisplayLink(m_upExit,    initUpExit);	
  DisplayLink(m_downExit,  initDownExit);	
	DisplayLink(m_exitExit,  initExitExit);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
