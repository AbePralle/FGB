#if !defined(AFX_LINKEXITSDIALOG_H__02AEC5A1_F6B8_11D3_B6CE_525400E2D57B__INCLUDED_)
#define AFX_LINKEXITSDIALOG_H__02AEC5A1_F6B8_11D3_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// LinkExitsDialog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CLinkExitsDialog dialog

class CLinkExitsDialog : public CDialog
{
// Construction
public:
	int RetrieveLink(CEdit &edit);
	void DisplayLink(CEdit &edit, int link);
	static int initNorthExit, initEastExit, initSouthExit, initWestExit;
  static int initUpExit, initDownExit, initExitExit;

	CLinkExitsDialog(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CLinkExitsDialog)
	enum { IDD = IDD_LINKEXITS };
	CEdit	m_westExit;
	CEdit	m_upExit;
	CEdit	m_southExit;
	CEdit	m_northExit;
	CEdit	m_exitExit;
	CEdit	m_eastExit;
	CEdit	m_downExit;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CLinkExitsDialog)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CLinkExitsDialog)
	afx_msg void OnKillfocusNorthexit();
	afx_msg void OnKillfocusEastexit();
	afx_msg void OnKillfocusSouthexit();
	afx_msg void OnKillfocusWestexit();
	afx_msg void OnKillfocusUpexit();
	afx_msg void OnKillfocusDownexit();
	afx_msg void OnKillfocusExitexit();
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LINKEXITSDIALOG_H__02AEC5A1_F6B8_11D3_B6CE_525400E2D57B__INCLUDED_)
