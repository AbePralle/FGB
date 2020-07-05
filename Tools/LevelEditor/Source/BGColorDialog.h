#if !defined(AFX_BGCOLORDIALOG_H__7540E1C1_F5D2_11D3_B6CE_525400E2D57B__INCLUDED_)
#define AFX_BGCOLORDIALOG_H__7540E1C1_F5D2_11D3_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BGColorDialog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBGColorDialog dialog

class CBGColorDialog : public CDialog
{
// Construction
public:
	void LimitValue(CEdit &edit, int min, int max);
	int GetValue(CEdit &edit);
	void SetValue(CEdit &edit, int val);
	static int initRed, initGreen, initBlue;
	CBGColorDialog(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CBGColorDialog)
	enum { IDD = IDD_COLORPICKER };
	CStatic	m_colorFrame;
	CEdit	m_red;
	CEdit	m_green;
	CEdit	m_blue;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CBGColorDialog)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CBGColorDialog)
	virtual BOOL OnInitDialog();
	afx_msg void OnKillfocusRed();
	afx_msg void OnKillfocusGreen();
	afx_msg void OnKillfocusBlue();
	virtual void OnOK();
	afx_msg void OnPaint();
	afx_msg void OnChangeRed();
	afx_msg void OnChangeGreen();
	afx_msg void OnChangeBlue();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BGCOLORDIALOG_H__7540E1C1_F5D2_11D3_B6CE_525400E2D57B__INCLUDED_)
