// makelights.cpp
// 2001.04.12 by Abe Pralle
// Converts "lights_all.bmp" into a raw set of 8*22*20 bytes 
// "discolights.dat"

#include <iostream.h>
#include <fstream.h>
#include "gk.h"

int main(void){
  gkBitmap bmp;
  if(!bmp.LoadBMP("lights_all.bmp")){
    cout << "Can't read lights_all.bmp!" << endl;
    return 0;
  }

  ofstream outfile("discolights.dat");
  if(!outfile){
    cout << "Can't open discolights.dat for writing!" << endl;
    return 0;
  }

  gkRGB white(255,255,255);
  int i,j,k;
  for(k=0; k<8; k++){
    for(j=0; j<18; j++){
      for(i=0; i<20; i++){
        if(bmp.Point(k*20+i,j)==white){
          outfile.put((char)1);
        }else{
          outfile.put((char)0);
        }
      }
    }
  }

  outfile.close();

  return 0;
}

