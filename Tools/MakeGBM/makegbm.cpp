// makegbm.cpp
// 2000.08.19 by Abe Pralle
// Plasma Works Game Boy Music Compiler

#include "makegbm.h"

#include <stdlib.h>
#include <fstream.h>
#include <strstream.h>
#include <string.h>

#define PERCUSSION_VOLUME 0x51
// ride    rd  20 71 00 80
// snare   sn  3f 71 17 80
// bass    bs  00 71 90 80
// tom1    ta  2b 71 57 80
// tom2    tb  2b 71 47 80

Label::Label(){
	text = 0;
	pc = 0;
}

Label::~Label(){
	if(text) delete text;
	text = 0;
}

Label::SetLabel(char *st,int pcPos){
	if(text) delete text;
	text = new char[strlen(st)+1];
	strcpy(text,st);
	pc = pcPos;
}

GBMParser::GBMParser(){
	notesPerSecond = 4;

	curBaseLabel = new char[5];
	strcpy(curBaseLabel,"main");

	track = 2;

	pc = 0;    //program counter
	line = 1;  //line number

	numLabels = 0;

	track1Start = track2Start = track3Start = track4Start = 0;

	outfile = 0;

	lastByteWritten = 2;

  envelope1 = 0xf1;  //default envelopes for restoring after a hold
	envelope2 = 0xc2;
	duration3 = 0xcf;
	envelope4 = 0xf0;
	repeat1 = repeat2 = repeat3 = repeat4 = 0;
}


GBMParser::~GBMParser(){
	delete curBaseLabel;
	curBaseLabel = 0;
	if(outfile){
		delete outfile;
		outfile = 0;
	}
}


int GBMParser::Compile(char *sourcefile){
	ifstream infile(sourcefile,ios::in | ios::binary | ios::nocreate);
	if(!infile){
		cout << "Error:  Can't open input file " << sourcefile << endl;
		return 0;
	}

  transpose = 0;

	pc += 4;   //space for infinite nop loop
	lastByteWritten = 2;

	//pass 1:  collect labels
	cout << "Pass 1...";
	char *input;
	for(input=GetInput(infile); !infile.eof(); input=GetInput(infile)){
		if(!AddLabel(input)){
		  //not a label or comment
		  if(!HandleCommand(infile,input,0)) return 0;
		}
	}

	//open the output file
	char outputFilename[256];
	ostrstream stout(outputFilename,256);
	stout << sourcefile << ".bin" << ends;
	outfile = new ofstream(outputFilename,ios::out|ios::binary);
	if(!(*outfile)){
		delete outfile;
		outfile = 0;
		return Error("Can't open output file");
	}

	//write out header
	track1Start += 6;
	track2Start += 4;
	track3Start += 2;

	Write(1);   //version
	Write(60 / notesPerSecond);
	Write(0);   //flags
	Write(0);   //pad1
	Write(0);   //pad2
	Write(0);   //pad3
	Write(0);   //pad4
	Write(0);   //pad5
	Write(track1Start & 0xff);
	Write((track1Start>>8) & 0xff);
	Write(track2Start & 0xff);
	Write((track2Start>>8) & 0xff);
	Write(track3Start & 0xff);
	Write((track3Start>>8) & 0xff);
	Write(track4Start & 0xff);
	Write((track4Start>>8) & 0xff);

	//write infinite nop loop
	pc = 0;
	Write(0);     //nop
	Write(0x6e);  //jump.l cc=always
	Write(0xfc);  //-4 offset
	Write(0xff);

	lastByteWritten = 2;

	//pass 2:  generate code
	cout << "Pass 2...";
	infile.close();
	infile.open(sourcefile,ios::in | ios::binary);
	line = 1;
	delete curBaseLabel;
	curBaseLabel = new char[5];
	strcpy(curBaseLabel,"main");
	track = 2;

	for(input=GetInput(infile); !infile.eof(); input=GetInput(infile)){

		if(input[0]=='.'){   //sub label
			//char st[1024];
			//ostrstream stout(st,1024);
			//stout << curBaseLabel << input << '.' << track << ends;
			//labelList[numLabels++].SetLabel(st,pc);
		}else if(input[strlen(input)-1]==':'){  // base label
			int len = strlen(input);
			if(curBaseLabel) delete curBaseLabel;
			curBaseLabel = new char[len+3];
			{
			  ostrstream stout(curBaseLabel,len+3);
			  stout << input;
			  stout.seekp(stout.tellp()-1);   //erase ':'
			  stout << ends;
			}

			//char st[1024];
			//ostrstream stout(st,1024);
			//stout << curBaseLabel << '.' << track << ends;
			//labelList[numLabels++].SetLabel(st,pc);
		}else{
		  //not a label or comment
		  if(!HandleCommand(infile,input,1)) return 0;
		}
	}

	//write a return at the end
	Write(2);

	cout << "Compilation successful to " << sourcefile << ".bin" << endl;

	return 1;
}

char *GBMParser::GetInput(istream &in){
	static char buffer[1024];
	int pos=0;

	//eat whitespace
  char ch;
	for(ch=in.get(); ; ch=in.get()){
		if(in.eof()) return 0;
		if(ch==10) line++;
		if(ch==' ' || ch==9 || ch==10 || ch==13) continue;
		break;
	}

	//eat comments
	if(ch=='/'){
		if(in.get()!='/'){
			in.unget();
		}else{
			for(ch=in.get(); ch!=10; ch=in.get()){
				if(in.eof()) return 0;
			}
			line++;
			return GetInput(in);
		}
	}

	//accumulate the word
	for(;;){
	  buffer[pos++]=ch;
		ch = in.get();
		if(in.eof()){
			buffer[pos]=0;
			return buffer;
		}
		if(ch==10) line++;
		if(ch==','||ch==' '||ch==9||ch==10||ch==13) break;  //end of word
	}
	buffer[pos] = 0;    //null terminate the word
	return buffer;
}

int GBMParser::GetByte(istream &in){
	int togo = 2;
	int value = 0;
	while(togo>0){
		int ch = in.get();
		if(ch>='A' && ch<='F') ch+=32;
		if(ch>='a' && ch<='f'){
			value = value*16 + ((ch-'a')+10);
			togo--;
		}else if(ch>='0' && ch<='9'){
			value = value * 16 + (ch - '0');
			togo--;
		}else if(ch != ',' && ch!=' '){
			char st[80];
			ostrstream stout(st,80);
			stout << "Expecting hex digit, got " << ch << ends;
			Error(st);
			return -1;
		}
	}
	return value;
}

int GBMParser::GetRegister(istream &in){
	//eat white space until we find an "r"
	int ch;
	for(ch=in.get(); ch!='r'; ch=in.get()){
		if(in.eof()) return -1;
		if(ch!=' ' && ch!=9 && ch!=','){
			in.unget();
			return -1;
		}
	}

	int value = 0;
	for(ch=in.get(); ch>='0' && ch<='9'; ch=in.get()){
		if(in.eof()) return -1;
		value = value*10 + (ch - '0');
	}
	in.unget();

	return value;
}

int GBMParser::GetDecimal(istream &in){
	//eat white space until we find a number
	int ch;
  int negative = 1;
	for(ch=in.get(); ch<'0' || ch>'9'; ch=in.get()){
		if(in.eof()) return -1;
    if(ch=='-'){
      negative = -1;
    }else if(ch!=' ' && ch!=9 && ch!=','){
			in.unget();
			return -1;
		}
	}

	int value = ch - '0';
	for(ch=in.get(); ch>='0' && ch<='9'; ch=in.get()){
		if(in.eof()) return value*negative;
		value = value*10 + (ch - '0');
	}
	in.unget();

	return value*negative;
}

int GBMParser::GetHold(istream &in){
	//eat white space until we find an h or non-h
	int ch;
	for(ch=in.get(); ch!='h' && ch!='H'; ch=in.get()){
		if(in.eof()) return 0;
		if(ch==10) line++;
		if(ch!=' ' && ch!=9 && ch!=',' && ch!=10 && ch!=13){
			in.unget();
			return 0;
		}
	}

	//multiplier?
	int num = GetDecimal(in);
	if(num>0) return num + GetHold(in);
	else      return 1 + GetHold(in);
}

int GBMParser::HandleCommand(istream &in, char *cmd, int genCode){

	int ch0 = cmd[0],i;
	if(ch0>='A' && ch0<='Z') ch0+=32;

	if(stricmp(cmd,"track")==0){
		char *trackNum = GetInput(in);
		if(!trackNum) return Error("Expecting track number 1-4");

		track = trackNum[0] - '0';
		if(track<1 || track>4){
			return Error("Track number must be 1-4");
		}

		//implied "ret" if last command not "ret"
		if(lastByteWritten != 2) Write(2);

		if(track==1 && track1Start==0) track1Start = pc;
		if(track==2 && track2Start==0) track2Start = pc;
		if(track==3 && track3Start==0) track3Start = pc;
		if(track==4 && track4Start==0) track4Start = pc;

	}else if(stricmp(cmd,"transpose")==0){
    transpose = GetDecimal(in);
	}else if(stricmp(cmd,"rd")==0){
		Write(7);
		Write(0x20);
		Write(PERCUSSION_VOLUME);
		envelope4 = 0xf1;
		Write(0x00);
		Write(0x80);
		repeat4 = 1;
	}else if(stricmp(cmd,"sn")==0){
		Write(7);
		Write(0x3f);
		Write(PERCUSSION_VOLUME);
		envelope4 = 0xf1;
		Write(0x17);
		Write(0x80);
		repeat4 = 1;
	}else if(stricmp(cmd,"bs")==0){
		Write(7);
		Write(0x00);
		Write(PERCUSSION_VOLUME);
		envelope4 = 0xf1;
		Write(0x90);
		Write(0x80);
		repeat4 = 1;
	}else if(stricmp(cmd,"ta")==0){
		Write(7);
		Write(0x2b);
		Write(PERCUSSION_VOLUME);
		envelope4 = 0xf1;
		Write(0x57);
		Write(0x80);
		repeat4 = 1;
	}else if(stricmp(cmd,"tb")==0){
		Write(7);
		Write(0x2b);
		Write(PERCUSSION_VOLUME);
		envelope4 = 0xf1;
		Write(0x47);
		Write(0x80);
		repeat4 = 1;
	}else if(stricmp(cmd,"notesPerSecond")==0){
		notesPerSecond = GetDecimal(in);
		if(notesPerSecond==-1) 
			return Error("Expecting decimal notesPerSecond value");
	}else if(stricmp(cmd,"skip")==0 || cmd[0]=='-' || cmd[0]=='h'||cmd[0]=='H'){
		istrstream inst(cmd+1,strlen(cmd)-1);
		int repeatCount = GetDecimal(inst);
		Write(0);
		if(repeatCount>0){
			for(i=1; i<repeatCount; i++) Write(0);
		}
	}else if(stricmp(cmd,"again")==0){
		if(track==1) Write(0x80);
		else if(track==2) Write(0x81);
		else if(track==3) Write(0x82);
		else if(track==4) Write(0x83);
	}else if(stricmp(cmd,"ret")==0){
		Write(2);
	}else if(stricmp(cmd,"instrument1")==0){
		Write(0x0c);
		int b;
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		envelope1 = b;
		if((GetByte(in))==-1) return 0;  //pad
		if((b=GetByte(in))==-1) return 0;
		repeat1 = (b&0x40)?0:1;
	}else if(stricmp(cmd,"instrument2")==0){
		Write(0x0d);
		int b;
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		envelope2 = b;
		if((GetByte(in))==-1) return 0;  //pad
		if((b=GetByte(in))==-1) return 0;
		repeat2 = (b&0x40)?0:1;
	}else if(stricmp(cmd,"instrument3")==0){
		Write(0x0e);
		int i,b;
		if((GetByte(in))==-1) return 0;  //pad
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		duration3 = b;
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		repeat3 = (b&0x40)?0:1;
		for(i=0; i<16; i++){
		  if((b=GetByte(in))==-1) return 0;
			Write(b);
		}
	}else if(stricmp(cmd,"instrument4")==0){
		Write(0x0f);
		int b;
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		envelope4 = b;
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		if((b=GetByte(in))==-1) return 0;
		Write(b);
		repeat4 = (b&0x40)?0:1;
	}else if(stricmp(cmd,"set")==0){
		int r1,r2,d;
		if((r1=GetRegister(in))==-1) return Error("Register r0-r15 expected");

		Write(0x10 | r1);

		if((r2=GetRegister(in))==-1){
			if((d=GetDecimal(in))==-1){
				return Error("Reg or val expected as second arg");
			}else{
				Write(0x10 | r1);
				Write(d);
			}
		}else{
			Write(0x20 | r1);
			Write(r2);
		}

	}else if(stricmp(cmd,"dec")==0){
		int r;
		if((r=GetRegister(in))==-1) return Error("Register r0-r15 expected");
		Write(0x30 | r);

	}else if(stricmp(cmd,"cmp")==0){
		int r1,r2,d;
		if((r1=GetRegister(in))==-1) return Error("Register r0-r15 expected");
		if((r2=GetRegister(in))==-1){
			if((d=GetDecimal(in))==-1){
				return Error("Reg or val expected as second arg");
			}else{
				Write(0x40 | r1);
				Write(d);
			}
		}else{
			Write(0x50 | r1);
			Write(r2);
		}
	}else if(stricmp(cmd,"jmp")==0 || stricmp(cmd,"jump")==0){
		int cc;
		char *ccst = GetInput(in);
		if(stricmp(ccst,"lt")==0) cc = 0;
		else if(stricmp(ccst,"le")==0) cc = 1;
		else if(stricmp(ccst,"eq")==0) cc = 2;
		else if(stricmp(ccst,"ge")==0) cc = 3;
		else if(stricmp(ccst,"gt")==0) cc = 4;
		else if(stricmp(ccst,"ne")==0) cc = 5;
		else                           cc = 6;  //jump always

		Write(0x68 + cc);  //opcode
		char *label;
		if(cc!=6) label = GetInput(in);
		else      label = ccst;

		if(genCode){
			int pos = GetLabel(label);
			if(pos==-1){
				Error("Undefined label referenced");
				return Error(label);
			}
			int offset = pos - (pc + 2);
			Write(offset & 0xff);
			Write((offset>>8) & 0xff);
		}else{
			pc += 2;
		}
	}else if(stricmp(cmd,"call")==0){
		int cc;
		char *ccst = GetInput(in);
		if(stricmp(ccst,"lt")==0) cc = 0;
		else if(stricmp(ccst,"le")==0) cc = 1;
		else if(stricmp(ccst,"eq")==0) cc = 2;
		else if(stricmp(ccst,"ge")==0) cc = 3;
		else if(stricmp(ccst,"gt")==0) cc = 4;
		else if(stricmp(ccst,"ne")==0) cc = 5;
		else                           cc = 6;  //jump always

		Write(0x78 + cc);  //opcode

		char *label;
		if(cc!=6) label = GetInput(in);
		else      label = ccst;

		if(genCode){
			int pos = GetLabel(label);
			if(pos==-1){
				Error("Undefined label referenced");
				return Error(label);
			}
			int offset = pos - (pc + 2);
			Write(offset & 0xff);
			Write((offset>>8) & 0xff);
		}else{
			pc += 2;
		}
	}else if((ch0>='a' && ch0<='g') && (cmd[1]>='3' && cmd[1]<='8')){

		int freq = LookupFrequency(cmd);
		if(!freq) return 0;
		freq |= 0x8000;    //set play bit

		//note
		int hold = GetHold(in);
    //cout << cmd << " got hold " << hold << endl;

		//write out the note
		if(track==1){
			Write(0x04);
		  if(!repeat1) freq |= 0x4000;
		}
		else if(track==2){
			Write(0x05);
		  if(!repeat2) freq |= 0x4000;
		}else if(track==3){
			Write(0x06);
		  if(!repeat3) freq |= 0x4000;
		}
		Write(freq & 0xff);
		Write((freq>>8) & 0xff);

		//write out "hold" number of nops
		for(i=0; i<hold; i++) Write(0);
	
		/*
		if(hold>1){
			//write a note without fade
			if(track==1){
				Write(0x08);
				Write(0xf0);
			}else if(track==2){
				Write(0x09);
				Write(0xf0);
			}else if(track==3){
				Write(0x0a);
				Write(0x00);
			}else if(track==4){
				Write(0x0b);
				Write(0xf0);
			}

			//write note w/repeat flag set
			Write(freq & 0xff);
			Write(((freq|0x4000)>>8)&0xff);

			//repeat this note for the hold between the start and end
			for(i=2; i<hold; i++){
				if(track==1) Write(0x80);
				else if(track==2) Write(0x81);
				else if(track==3) Write(0x82);
				else if(track==4) Write(0x83);
			}

			//write final note that restores fade info
			if(track==1){
				Write(0x08);
				Write(envelope1);
			}else if(track==2){
				Write(0x09);
				Write(envelope2);
			}else if(track==3){
				Write(0x0a);
				Write(duration3);
			}else if(track==4){
				Write(0x0b);
				Write(envelope4);
			}

			Write(freq & 0xff);
			Write((freq>>8) & 0xff);
		}else{
		}
		*/

	}else if(ch0>='a' && ch0<='z'){    //implied function call
		if(genCode){
		  int pos = GetLabel(cmd);
		  if(pos==-1){
				Error("Undefined label referenced");
				return Error(cmd);
			}
		  Write(0x7e);   //long call cc=always opcode
		  int offset = pos - (pc + 2);
		  Write(offset & 0xff);
		  Write((offset>>8) & 0xff);
		}else{
			pc += 3;
		}
	}else{
		char st[80];
		ostrstream stout(st,80);
		stout << "Unexpected input: " << cmd << ends;
		return Error(st);
	}
	return 1;
}

int  GBMParser::Error(char *st){
  cout << "Error (" << line << "):  " << st << endl;
	return 0;
}

int  GBMParser::AddLabel(char *text){
	if(GetLabel(text)>=0) return Error("Label already exists");
	if(numLabels >= MAX_LABELS) return Error("Max labels reached!");
	if(text[0]=='.'){   //sub label
		char st[1024];
		ostrstream stout(st,1024);
		stout << curBaseLabel << text << '.' << track << ends;
		labelList[numLabels++].SetLabel(st,pc);

	}else if(text[strlen(text)-1]==':'){  // base label
		int len = strlen(text);
		if(curBaseLabel) delete curBaseLabel;
		curBaseLabel = new char[len+3];
		{
			ostrstream stout(curBaseLabel,len+3);
			stout << text;
			stout.seekp(stout.tellp()-1);   //erase ':'
			stout << ends;
		}

		char st[1024];
		ostrstream stout(st,1024);
		stout << curBaseLabel << '.' << track << ends;
		labelList[numLabels++].SetLabel(st,pc);
	}else{
		return 0;  //not a label
	}
	return 1;
}

int  GBMParser::GetLabel(char *st){
	char text[120];
	ostrstream stout(text,120);

	if(st[0]=='.') stout << curBaseLabel << st << '.' << track << ends;
	else if(st[strlen(st)-1]==':'){
		stout << st; 
		stout.seekp(stout.tellp()-1);    //get rid of the ':'
		stout << '.' << track << ends;
	}else stout << st << '.' << track << ends;

	int i;
	for(i=0; i<numLabels; i++){
		if(stricmp(text,labelList[i].GetText())==0) return labelList[i].GetPC();
	}

	//one more try assuming it's a local label w/o the dot in front
	stout.seekp(0);
	stout << curBaseLabel << '.' << st << '.' << track << ends;

	for(i=0; i<numLabels; i++){
    //cout << text << "/" << labelList[i].GetText() << endl;
		if(stricmp(text,labelList[i].GetText())==0) return labelList[i].GetPC();
	}

	return -1;
}

int  GBMParser::LookupFrequency(char *st){
	static int frequencyTable[]={
		44,     //C3  
		156,    //C3# 
		262,    //D3  
		363,    //D3# 
		457,    //E3  
		547,    //F3  
		631,    //F3# 
		710,    //G3  
		786,    //G3# 
		854,    //A3  
		923,    //A3# 
		986,    //B3  
		1046,   //C4  
		1102,   //C4# 
		1155,   //D4  
		1205,   //D4# 
		1253,   //E4  
		1297,   //F4  
		1339,   //F4# 
		1379,   //G4  
		1417,   //G4# 
		1452,   //A4  
		1486,   //A4# 
		1517,   //B4  
		1546,   //C5  
		1575,   //C5# 
		1602,   //D5  
		1627,   //D5# 
		1650,   //E5  
		1673,   //F5  
		1694,   //F5# 
		1714,   //G5  
		1732,   //G5# 
		1750,   //A5  
		1767,   //A5# 
		1783,   //B5  
		1798,   //C6  
		1812,   //C6# 
		1825,   //D6  
		1837,   //D6# 
		1849,   //E6  
		1860,   //F6  
		1871,   //F6# 
		1881,   //G6  
		1890,   //G6# 
		1899,   //A6  
		1907,   //A6# 
		1915,   //B6  
		1923,   //C7  
		1930,   //C7# 
		1936,   //D7  
		1943,   //D7# 
		1949,   //E7  
		1954,   //F7  
		1959,   //F7# 
		1964,   //G7  
		1969,   //G7# 
		1974,   //A7  
		1978,   //A7# 
		1982,   //B7  
		1985,   //C8  
		1988,   //C8# 
		1992,   //D8  
		1995,   //D8# 
		1998,   //E8  
		2001,   //F8  
		2004,   //F8# 
		2006,   //G8  
		2009,   //G8# 
		2011,   //A8  
		2013,   //A8# 
		2015    //B8  
	};

	int index = 0;   //c3
	switch(st[0] | 32){
		case 'a':
			index += 9;
			break;
		case 'b':
			index += 11;
			break;
		case 'c':
			break;
		case 'd':
			index += 2;
			break;
		case 'e':
			index += 4;
			break;
		case 'f':
			index += 5;
			break;
		case 'g':
			index += 7;
			break;
	}

	index += 12 * ((st[1] - '0') - 3);
	if(st[2]=='#') index++;

  index += transpose;

	if(index < 0 || index > 71) return Error("Bad note computation");
	//if(stricmp(st,"a4")==0) cout << st << " " << frequencyTable[index] << endl;

	return frequencyTable[index];
}

void GBMParser::Write(int n){
	if(outfile){
		outfile->put((char) n);
		//cout << pc << ": " << n << endl;
	}
	lastByteWritten = n;
	pc++;
}

//--------------------------------------------------------------------
//
int main(int argc, char *argv[]){
	if(argc==1){
		cout << "Usage:  makegbm filename.gtx [file2.gtx...]" << endl;
		exit(1);
	}

	int i;
	for(i=1; i<argc; i++){
		cout << argv[i] << ':' << endl;
		GBMParser parser;
		if(!parser.Compile(argv[i])){
			cout << "Compilation aborted due to errors!" << endl;
			return 0;
		}
	}
	return 0;
}

