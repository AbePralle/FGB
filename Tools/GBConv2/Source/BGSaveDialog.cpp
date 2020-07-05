// BGSaveDialog.cpp : implementation file
//

#include "stdafx.h"
#include "GBConv2.h"
#include "BGSaveDialog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CBGSaveDialog

IMPLEMENT_DYNAMIC(CBGSaveDialog, CFileDialog)

CBGSaveDialog::CBGSaveDialog(BOOL bOpenFileDialog, LPCTSTR lpszDefExt, LPCTSTR lpszFileName,
		DWORD dwFlags, LPCTSTR lpszFilter, CWnd* pParentWnd) :
		CFileDialog(bOpenFileDialog, lpszDefExt, lpszFileName, dwFlags, lpszFilter, pParentWnd)
{
}


BEGIN_MESSAGE_MAP(CBGSaveDialog, CFileDialog)
	//{{AFX_MSG_MAP(CBGSaveDialog)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


void CBGSaveDialog::OnTypeChange()
{
  int index = this->m_ofn.nFilterIndex;
  char *filter = (char*) this->m_ofn.lpstrFilter;
  int i;
  for(i=1; i<index; i++){
    while(*(filter++));
    while(*(filter++));
  }
  while(*(filter++));


  /*
  int curExtPos = m_ofn.nFileExtension;
  char *filename = m_ofn.lpstrFile;
  if(curExtPos==0){
    strcat(filename,filter);
  }else{
    strcpy(filename+curExtPos, filter+1);
  }
  */
}
