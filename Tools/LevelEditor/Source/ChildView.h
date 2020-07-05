// ChildView.h : interface of the CChildView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_CHILDVIEW_H__CA2832CA_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
#define AFX_CHILDVIEW_H__CA2832CA_B4C7_11D3_958B_00A0CC533895__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "wingk.h"
#include "mapwin.h"
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
	void ReSizeWindows();
	void SetGrids(bool);
	virtual ~CChildView();

	// naughty function to grab references to Children
	CMapWin* GrabWinMap();
	CControls* GrabControls();


	
	// Generated message map functions
protected:

	gkWinShape tyPic;
	//background
	gkWinShape bckgrndBffr;
	
	CControls controls;
	CMapWin mapWin;


	//{{AFX_MSG(CChildView)
	afx_msg void OnPaint();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CHILDVIEW_H__CA2832CA_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
