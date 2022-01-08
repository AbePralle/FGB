#if !defined(AFX_CONTROLS_H__74CE4C48_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_CONTROLS_H__74CE4C48_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_

#include "PaletteListBox.h"	// Added by ClassView
#include "BGSaveDialog.h"

class CChildView;
class CPaletteListBox;

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Controls.h : header file
//


#define CTRLWIDTH  224
#define CTRLHEIGHT 416


/////////////////////////////////////////////////////////////////////////////
// CControls window

class CControls : public CWnd
{
// Construction
public:
	CControls();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CControls)
	//}}AFX_VIRTUAL

// Implementation
public:
	void OnB_MapToPalette();
	void OnB_ShowMapping();
	void OnB_SaveGBPic();
	void OnB_AutoMapAll();
	void OnB_EditPalette();
	void OnB_SaveGBSprite();
	void OnB_SelectUnmapped();
	void OnB_CheckShowSprites();
	void OnSelChangePalettes();
	void OnB_MakeSprites();
	void OnB_Unmap();
	void OnB_SelectNonEmpty();
	void OnB_AutoMapToPalette();
	void OnB_SwapWithBGColor();
	void OnB_SetToBGColor();
	void OnPaletteFromSel();
	void InvalidateEditArea();
	void InvalidateColors();
	void InvalidateMagnifiedArea();
  CPaletteListBox palettes;
	virtual ~CControls();

  int showSprites, showMapping;

	// Generated message map functions
protected:
	int palettesSelected[17];
	CChildView *view;
	CButton createPaletteFromSel;
  CButton b_setToBGColor;
  CButton b_swapWithBGColor;
  CButton b_selectNonEmpty;
  CButton b_unmap;
  CButton b_makeSprites;
  CButton b_autoMapToPalette;
  CButton b_mapToPalette;
  CButton b_showSprites;
  CButton b_showMapping;
  CButton b_selectUnmapped;
  CButton b_saveGBSprite;
  CButton b_editPalette;

  CButton b_autoMapAll;
  CButton b_saveGBPic;

	static CString preferredDestPath;
  CString destFilename;
  CFileDialog *destFileDialog;
  CString bgFilename;
  CBGSaveDialog *bgFileDialog;

	//{{AFX_MSG(CControls)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnPaint();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CONTROLS_H__74CE4C48_0DAC_11D4_B6CE_525400E2D57B__INCLUDED_)
