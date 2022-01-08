#if !defined(AFX_TERRAINTILES_H__5105A4C0_BC7B_11D3_958B_00A0CC533895__INCLUDED_)
#define AFX_TERRAINTILES_H__5105A4C0_BC7B_11D3_958B_00A0CC533895__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// TerrainTiles.h : header file
//


#include "EditDefines.h"


/////////////////////////////////////////////////////////////////////////////
// CTerrainTiles window

class CTerrainTiles : public CWnd
{
// Construction
public:
	CTerrainTiles();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTerrainTiles)
	//}}AFX_VIRTUAL

// Implementation
public:
	void SetScrollBarPositions();
	virtual ~CTerrainTiles();

	// Generated message map functions
protected:
	//{{AFX_MSG(CTerrainTiles)
	afx_msg void OnPaint();
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TERRAINTILES_H__5105A4C0_BC7B_11D3_958B_00A0CC533895__INCLUDED_)
