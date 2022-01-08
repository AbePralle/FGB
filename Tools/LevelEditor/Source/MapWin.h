#if !defined(AFX_MAPWIN_H__CA2832D2_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
#define AFX_MAPWIN_H__CA2832D2_B4C7_11D3_958B_00A0CC533895__INCLUDED_


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// MapWin.h : header file
//

#include "wingk.h"
#include "EditDefines.h"


/////////////////////////////////////////////////////////////////////////////
// CMapWin window

class CMapWin : public CWnd
{
// Construction
public:
	CMapWin();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMapWin)
	//}}AFX_VIRTUAL

// Implementation
public:
	void FlagTooMuchOpenSpace();
	void PlaceTile(int tileIndex, CPoint point);
	void ReadExits(istream &in);
	gkWinShape exitTiles[8];
	void WriteExits(ostream &out);
	void RemakeListOfTilesUsed();
	short int * getListOfAllTiles();
	void ReadZones(istream &in);
	void WriteZones(ostream &out);
	void DrawPath(int destZone, int nPath, gkWinShape &tileBuffer);
	void EraseTile(CPoint point);
	void PlaceCurrentTile(CPoint point);
	void SetScrollBarPositions();
	virtual ~CMapWin();

	//				Application specific public methods	//

	void SetGrids(bool);
	void setBackgroundColor(int color);
	int getBackgroundColor();
	void setGridColor(int color);
	void getEnvArray(PicStruct[256][256]);
	unsigned char getTotalTilesUsed();
	short int* getListOfTilesUsed();
	void loadLevel(char*);
	//sort the tiles in decending order for abe!
	void remapMonsters();
	//clear the current level
	void clearLevel();

	//				End Application specific pubilc methods //


	// Generated message map functions
protected:
	char tooMuchOpenSpace[256][256];
  PicStruct copyBuffer[256][256];
  int copyWidth, copyHeight;
	int drawingRect, rectStartX, rectStartY, rectEndX, rectEndY;
	int lmb_isDown, rmb_isDown;
  int drawingPath, pathStartX, pathStartY;
  int selectedZone;

//////				Application Specific Variables		///////////
	bool showGrids;

	//current tile to be blitted
	gkWinShape *curTile;

	//2-D array ofenvironment tiles
	PicStruct envArray[256][256];

  //2-D array of zone/attribute tiles
  unsigned char zoneArray[256][256];
  unsigned char exitArray[256][256];

	//background color
	int backgroundColor;
	int gridColor;

	//total number of tiles uesd
	unsigned char totalTilesUsed;
	short int listOfTilesUsed[257];
	short int listOfAllTiles[65536];

//////				end App Specific Variables			/////////////

	

	//{{AFX_MSG(CMapWin)
	afx_msg void OnPaint();
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAPWIN_H__CA2832D2_B4C7_11D3_958B_00A0CC533895__INCLUDED_)
