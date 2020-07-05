#if !defined(AFX_EDITAREA_H__74CE4C4A_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_EDITAREA_H__74CE4C4A_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// EditArea.h : header file
//

class CChildView;

/////////////////////////////////////////////////////////////////////////////
// CEditArea window

class CEditArea : public CWnd
{
// Construction
public:
	CEditArea();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEditArea)
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CEditArea();

	// Generated message map functions
protected:
	int downRMB;
	short int pickingColors;
	CChildView *view;
	int downLMB;
	//{{AFX_MSG(CEditArea)
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnPaint();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_EDITAREA_H__74CE4C4A_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
