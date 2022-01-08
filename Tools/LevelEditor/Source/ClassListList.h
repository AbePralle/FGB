#if !defined(AFX_CLASSLISTLIST_H__D14BA4E9_C76B_11D3_B6CE_525400E2D57B__INCLUDED_)
#define AFX_CLASSLISTLIST_H__D14BA4E9_C76B_11D3_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "wingk.h"

// ClassListList.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CClassListList window

class CClassListList : public CListBox
{
// Construction
public:
	CClassListList();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CClassListList)
	public:
	virtual void MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct);
	virtual void DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct);
	//}}AFX_VIRTUAL

// Implementation
public:
	gkWinShape* tileList;
	virtual ~CClassListList();

	// Generated message map functions
protected:
	//{{AFX_MSG(CClassListList)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CLASSLISTLIST_H__D14BA4E9_C76B_11D3_B6CE_525400E2D57B__INCLUDED_)
