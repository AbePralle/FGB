#if !defined(AFX_PALETTELISTBOX_H__74CE4C4B_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_PALETTELISTBOX_H__74CE4C4B_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// PaletteListBox.h : header file
//

#include "gb_pic.h"

class CChildView;
class CControls;

/////////////////////////////////////////////////////////////////////////////
// CPaletteListBox window

class CPaletteListBox : public CListBox
{
// Construction
public:
	CPaletteListBox();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPaletteListBox)
	public:
	virtual void MeasureItem(LPMEASUREITEMSTRUCT lpMeasureItemStruct);
	virtual void DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct);
	//}}AFX_VIRTUAL

// Implementation
public:
	CChildView *view;
	CControls *controls;
	gbPic * pic;
	virtual ~CPaletteListBox();

	// Generated message map functions
protected:
	int itemSelected[17];
	//{{AFX_MSG(CPaletteListBox)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSelchange();
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PALETTELISTBOX_H__74CE4C4B_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
