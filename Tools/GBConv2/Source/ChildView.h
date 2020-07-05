// ChildView.h : interface of the CChildView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_CHILDVIEW_H__2F0A9B4C_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_CHILDVIEW_H__2F0A9B4C_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_

#include "EditArea.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "gb_pic.h"
#include "EditArea.h"
#include "Controls.h"


/////////////////////////////////////////////////////////////////////////////
// CChildView window

class CChildView : public CWnd
{
// Construction
public:
	CChildView();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CChildView)
	protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	//}}AFX_VIRTUAL

// Implementation
public:
	CEditArea editArea;
  CControls controls;
	void DebugMesg(char *title, int num);
	int OnLoadBMP();
	virtual ~CChildView();

	static CString preferredSourcePath;
	gbPic pic;
	CString sourceFileName, destFileName;
	CFileDialog* sourceFile, *destFile;

	// Generated message map functions
protected:
	//{{AFX_MSG(CChildView)
	afx_msg void OnPaint();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CHILDVIEW_H__2F0A9B4C_0CC2_11D4_B6CE_525400E2D57B__INCLUDED_)
