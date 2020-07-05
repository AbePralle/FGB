#if !defined(AFX_EDITPALETTEDIALOG_H__E83CE848_1BC5_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_EDITPALETTEDIALOG_H__E83CE848_1BC5_11D4_B6CE_525400E2D57B__INCLUDED_

#include "wingk.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// EditPaletteDialog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CEditPaletteDialog dialog

class CEditPaletteDialog : public CDialog
{
// Construction
public:
	void SetNum(CEdit &edit, int n);
	int GetNum(CEdit &edit);
	gkRGB colors[4];
	gkRGB initColors[4];
	CEditPaletteDialog(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CEditPaletteDialog)
	enum { IDD = IDD_EDIT_PALETTE };
	CEdit	m_editRed3;
	CEdit	m_editRed2;
	CEdit	m_editRed1;
	CEdit	m_editRed0;
	CEdit	m_editGreen3;
	CEdit	m_editGreen2;
	CEdit	m_editGreen1;
	CEdit	m_editGreen0;
	CEdit	m_editBlue3;
	CEdit	m_editBlue2;
	CEdit	m_editBlue1;
	CEdit	m_editBlue0;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEditPaletteDialog)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CEditPaletteDialog)
	virtual void OnOK();
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_EDITPALETTEDIALOG_H__E83CE848_1BC5_11D4_B6CE_525400E2D57B__INCLUDED_)
