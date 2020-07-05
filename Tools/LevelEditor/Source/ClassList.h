#if !defined(AFX_CLASSLIST_H__D14BA4E8_C76B_11D3_B6CE_525400E2D57B__INCLUDED_)
#define AFX_CLASSLIST_H__D14BA4E8_C76B_11D3_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "wingk.h"
#include "ClassListList.h"

// ClassList.h : header file
//

#include "wingk.h"

/////////////////////////////////////////////////////////////////////////////
// CClassList dialog

class CClassList : public CDialog
{
// Construction
public:
	short int *listOfTilesUsed, *listOfAllTiles, totalTilesUsed;
  gkWinShape *tileList;
	CClassList(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CClassList)
	enum { IDD = IDD_CLASS_LIST_DIALOG };
	CClassListList	m_classList;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CClassList)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CClassList)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeClassList();
	afx_msg void OnClasslistClearall();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CLASSLIST_H__D14BA4E8_C76B_11D3_B6CE_525400E2D57B__INCLUDED_)
