#if !defined(AFX_BGSAVEDIALOG_H__F9E2F187_1EE9_11D4_B6CE_525400E2D57B__INCLUDED_)
#define AFX_BGSAVEDIALOG_H__F9E2F187_1EE9_11D4_B6CE_525400E2D57B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BGSaveDialog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CBGSaveDialog dialog

class CBGSaveDialog : public CFileDialog
{
	DECLARE_DYNAMIC(CBGSaveDialog)

public:
	virtual void OnTypeChange();
	CBGSaveDialog(BOOL bOpenFileDialog, // TRUE for FileOpen, FALSE for FileSaveAs
		LPCTSTR lpszDefExt = NULL,
		LPCTSTR lpszFileName = NULL,
		DWORD dwFlags = OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
		LPCTSTR lpszFilter = NULL,
		CWnd* pParentWnd = NULL);

protected:
	//{{AFX_MSG(CBGSaveDialog)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_BGSAVEDIALOG_H__F9E2F187_1EE9_11D4_B6CE_525400E2D57B__INCLUDED_)
