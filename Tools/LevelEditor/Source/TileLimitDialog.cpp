// TileLimitDialog.cpp : implementation file
//

#include "stdafx.h"
#include "LevelEditor.h"
#include "TileLimitDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CTileLimitDialog dialog


CTileLimitDialog::CTileLimitDialog(CWnd* pParent /*=NULL*/)
	: CDialog(CTileLimitDialog::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTileLimitDialog)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CTileLimitDialog::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTileLimitDialog)
	DDX_Control(pDX, IDC_LIMIT_TEXTBOX, m_selection);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CTileLimitDialog, CDialog)
	//{{AFX_MSG_MAP(CTileLimitDialog)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTileLimitDialog message handlers
