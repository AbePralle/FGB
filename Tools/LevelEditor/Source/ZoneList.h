#if !defined(AFX_ZONELIST_H__FF8F62A8_C532_11D3_B6CE_525400E2D57B__INCLUDED_)
#define AFX_ZONELIST_H__FF8F62A8_C532_11D3_B6CE_525400E2D57B__INCLUDED_

#include "wingk.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// ZoneList.h : header file
//

#include "wingk.h"

/////////////////////////////////////////////////////////////////////////////
// CZoneList window

class CZoneList : public CListBox
{
// Construction
public:
	CZoneList();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CZoneList)
	public:
	virtual void DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct);
	virtual void MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct);
	//}}AFX_VIRTUAL

// Implementation
public:
	static int GetZoneColor(int n);
	virtual ~CZoneList();

	// Generated message map functions
protected:
	gkWinShape exitTiles[8];
	//{{AFX_MSG(CZoneList)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ZONELIST_H__FF8F62A8_C532_11D3_B6CE_525400E2D57B__INCLUDED_)
