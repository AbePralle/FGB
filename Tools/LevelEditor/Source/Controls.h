#if !defined(AFX_CONTROLS_H__CA2832D1_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
#define AFX_CONTROLS_H__CA2832D1_B4C7_11D3_958B_00A0CC533895__INCLUDED_


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Controls.h : header file
//

#include "wingk.h"
#include "TerrainTiles.h"
#include "ZoneList.h"

/////////////////////////////////////////////////////////////////////////////
// CControls dialog

class CControls : public CDialog
{
// Construction
public:
	int GetSortClassesBy();
	int links[8];
	int areaSpecial;
	gkWinShape* GrabTilePointer(int n);
	int LimitEditValue(CEdit &edit, int min, int max);
	int metaWidth, metaHeight, isWall;
	int GetDrawingExits();
	int MapIndexToExit(int n);
	void SendToKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	int GetMapPitch();
	int GetDrawingZones();
	void SetOffsetX(int n);  //at what point in the map is the TL corner of view?
  void SetOffsetY(int n);
  int  GetOffsetX();
  int  GetOffsetY();

	int GetMapWidth();
  int GetMapHeight();
  void SetMapWidth(int n);
  void SetMapHeight(int n);
	CControls(CWnd* pParent = NULL);   // standard constructor

	//return the current tile pointer
	gkWinShape *GrabCurTilePointer();
	//return the full tile buffer
	gkWinShape* GrabTileBuffer();
	//return a pointer to a picture at a given index
	gkWinShape* GrabPicAt(int);
	void SetCurTilePointer(int index);
	int GrabCurTileIndex();

// Dialog Data
	//{{AFX_DATA(CControls)
	enum { IDD = IDD_CONTROLS };
	CButton	m_sortClassesBy;
	CButton	m_wallCheck;
	CButton	m_copyDown;
	CButton	m_copyLeft;
	CButton	m_copyRight;
	CButton	m_copyUp;
	CButton	m_shiftUp;
	CButton	m_shiftRight;
	CButton	m_shiftLeft;
	CButton	m_shiftDown;
	CEdit	m_metaHeight;
	CEdit	m_metaWidth;
	CButton	m_radioTiles;
	CComboBox	m_loadLevel;
	CZoneList	m_zoneList;
	CEdit	m_editHeight;
	CEdit	m_editWidth;
	CStatic	m_loadlevelname;
	CEdit	m_levelname;
	CButton	m_showGrids;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CControls)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL


// Implementation
protected:
	int drawingZones, drawingExits;
	CTerrainTiles terrainTiles;
  int offset_x, offset_y;
  int mapPitch;

	//			Application Specific Code				//

	//buffer for all tiles
	gkWinShape tileBuff;

	//current tile	index	
	//REMOVE gkWinShape curTile;
	int curTile;

	//list of all tiles
	gkWinShape tileList[E_MAXTILES];

  //current map width and height
  int mapWidth, mapHeight;


	//					//			//					//


	// Generated message map functions
	//{{AFX_MSG(CControls)
	afx_msg void OnShowgrids();
	afx_msg void OnPaint();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnWritefile();
	virtual void OnCancel();
	virtual void OnOK();
	afx_msg void OnLoad();
	afx_msg void OnClear();
	afx_msg void OnKillfocusEditHeight();
	afx_msg void OnKillfocusEditWidth();
	afx_msg void OnMeasureItem(int nIDCtl, LPMEASUREITEMSTRUCT lpMeasureItemStruct);
	afx_msg void OnDrawItem(int nIDCtl, LPDRAWITEMSTRUCT lpDrawItemStruct);
	virtual BOOL OnInitDialog();
	afx_msg void OnCheckShowzones();
	afx_msg void OnSelchangeZonelist();
	afx_msg void OnButtonClasslist();
	afx_msg void OnDestroy();
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnRadioTiles();
	afx_msg void OnRadioZones();
	afx_msg void OnRadioExits();
	afx_msg void OnBgcolor();
	afx_msg void OnSetmeta1x1();
	afx_msg void OnSetmeta2x2();
	afx_msg void OnChangeMetaWidth();
	afx_msg void OnChangeMetaHeight();
	afx_msg void OnShiftup();
	afx_msg void OnShiftright();
	afx_msg void OnShiftdown();
	afx_msg void OnShiftleft();
	afx_msg void OnCopyup();
	afx_msg void OnCopyright();
	afx_msg void OnCopydown();
	afx_msg void OnCopyleft();
	afx_msg void OnButtonLinkexits();
	afx_msg void OnWallcheck();
	afx_msg void OnSETMETA3x3();
	afx_msg void OnSETMETA4x4();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CONTROLS_H__CA2832D1_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
