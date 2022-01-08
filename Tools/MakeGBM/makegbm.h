// makegbm.h
// 2000.08.19 by Abe Pralle
// Plasma Works Game Boy Music Compiler

#include <iostream.h>
#include <fstream.h>

#define MAX_LABELS 4096

class Label{
	protected:
		int  pc;
		char *text;

	public:
		Label();
		~Label();

		SetLabel(char *st, int pcPos);
		int GetPC(){ return pc; }
		char *GetText(){ return text; }
};

class GBMParser{
protected:
	int notesPerSecond;
	char *curBaseLabel;
	int track;
	int track1Start, track2Start, track3Start, track4Start;
	int envelope1,envelope2,duration3,envelope4;
	int repeat1,repeat2,repeat3,repeat4;
	int pc;
	int line;
	Label labelList[MAX_LABELS];
	int numLabels;
	int lastByteWritten;
	ofstream *outfile;
  int transpose;

public:
	GBMParser();
	~GBMParser();

	int Compile(char *sourcefile);

protected:
	char *GetInput(istream &in);
	int  GetByte(istream &in);
	int  GetRegister(istream &in);
	int  GetDecimal(istream &in);
	int  GetHold(istream &in);
	int  HandleCommand(istream &in, char *cmd, int genCode);
	int  Error(char *st);

	int  AddLabel(char *text);
	int  GetLabel(char *st);
	int  LookupFrequency(char *st);
	void Write(int n);
};

