#if !defined(AFX_TILELIMITDIALOG_H__A65950A1_6466_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_TILELIMITDIALOG_H__A65950A1_6466_11D4_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// TileLimitDialog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CTileLimitDialog dialog

class CTileLimitDialog : public CDialog
{
// Construction
public:
	CTileLimitDialog(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CTileLimitDialog)
	enum { IDD = IDD_TILELIMIT };
	CButton	m_selection;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTileLimitDialog)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CTileLimitDialog)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TILELIMITDIALOG_H__A65950A1_6466_11D4_B6CE_525400E2D57B__INCLUDED_)
