// GBConv2.h : main header file for the GBCONV2 application
//

#if !defined(AFX_GBCONV2_H__2F0A9B44_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_GBCONV2_H__2F0A9B44_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CGBConv2App:
// See GBConv2.cpp for the implementation of this class
//

class CGBConv2App : public CWinApp
{
public:
	CGBConv2App();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CGBConv2App)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation
protected:
	HMENU m_hMDIMenu;
	HACCEL m_hMDIAccel;

public:
	//{{AFX_MSG(CGBConv2App)
	afx_msg void OnAppAbout();
	afx_msg void OnFileNew();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_GBCONV2_H__2F0A9B44_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_)
