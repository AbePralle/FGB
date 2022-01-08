// LevelEditor.h : main header file for the LEVELEDITOR application
//

#if !defined(AFX_LEVELEDITOR_H__CA2832C4_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
#define AFX_LEVELEDITOR_H__CA2832C4_B4C7_11D3_958B_00A0CC533895__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CLevelEditorApp:
// See LevelEditor.cpp for the implementation of this class
//

class CLevelEditorApp : public CWinApp
{
public:
	CLevelEditorApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CLevelEditorApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

public:
	//{{AFX_MSG(CLevelEditorApp)
	afx_msg void OnAppAbout();
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LEVELEDITOR_H__CA2832C4_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
