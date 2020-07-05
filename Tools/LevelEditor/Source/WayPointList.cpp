#include "WayPointList.h"

WayPointList::WayPointList(){
	Reset();
	pitch = 32;
}

WayPointList::~WayPointList(){
}

void WayPointList::Reset(){
  int i,j;
	for(i=1; i<16; i++){
		for(j=1; j<16; j++){
			zoneMatrix[i][j] = 0;
		}
	}

	for(i=0; i<256; i++){
		for(j=0; j<32; j++){
			path[i][j] = 0;
		}
	}

	numWayPoints = 0;
	numPaths = 0;
	curPathStartZone = 0;
}

void WayPointList::CreateWayPoint(int i, int j){
	if(numWayPoints==255) return;

	//don't create if it's a duplicate of existing
	int wp = (j<<8) + i;

	int index;
	for(index=1; index<=numWayPoints; index++){
		if(wayPoints[index]==wp) return;
	}
	
	wayPoints[++numWayPoints] = wp;
}

void WayPointList::RemoveWayPoint(int i, int j){
	int wp = (j<<8) + i;

	//find the index of the existing waypoint
	int index;
	for(index=1; index<=numWayPoints; index++){
		if(wayPoints[index] == wp) break;
	}
	if(index>numWayPoints) return;   //wasn't there

	//delete all paths that included the deleted waypoint
	int n,m;
	for(n=1; n<=numPaths; n++){
		if(path[n][0]>0){
			for(m=0; m<32; m++){
				if(path[n][m]==index){
					RemovePath(n);
					n--;
					break;
				}
			}
		}
	}

  //delete the waypoint itself by switching it with the end waypoint
  int replaceWith = numWayPoints--;
  if(numWayPoints>0){
    wayPoints[index] = wayPoints[replaceWith];

    //change all paths that use the replacer to use its new index
    for(n=1; n<numPaths; n++){
      for(m=0; m<32; m++){
        if(path[n][m]==replaceWith){
          path[n][m] = index;
        }
      }
    }
  }
}

void WayPointList::MoveWayPoint(int si, int sj, int di, int dj){
	int swp = (sj<<8) + si;
	int dwp = (dj<<8) + di;

	int index;
	for(index=1; index<=numWayPoints; index++){
		if(wayPoints[index] == swp){
			wayPoints[index] = dwp;
			break;
		}
	}
}

//  Returns:  0 if no path removed
//            Otherwise # of path that REPLACES path removed
int  WayPointList::RemovePath(int n){
	if(n==0) return 0;

	//delete this path by replacing it with the one at the end
	//copy the waypoint list from that path to this path
	int i,j;
	int nReplace = numPaths--;
	for(i=0; i<32; i++){
		path[n][i] = path[nReplace][i];
		path[nReplace][i] = 0;
	}

	//loop through the zone matrix and remove or replace all 
	//occurences of both indices
	for(i=1; i<16; i++){
		for(j=1; j<16; j++){
			if(zoneMatrix[i][j]==n){
				zoneMatrix[i][j] = 0;
			}else if(zoneMatrix[i][j] == nReplace){
				zoneMatrix[i][j] = n;
			}
		}
	}

	return nReplace;
}

int  WayPointList::BeginPath(int zone){
  curPath = ++numPaths;
	curPathStartZone = zone;

	int i;
	for(i=0; i<32; i++) path[curPath][i] = 0;

	return curPath;
}

void WayPointList::AddWayPointToPath(int i, int j){
  AddWayPointToPath((j<<8) + i);
	/*
	//find the waypoint we're talking about
	int wp = (j<<8) + i;
	int index;
	for(index=1; index<=numWayPoints; index++){
		if(wayPoints[index] == wp) break;
	}
	if(index>numWayPoints) return;

	//add waypoint index to path
	int n;
	for(n=0; n<32; n++){
		if(path[curPath][n] == 0){
			path[curPath][n] = index;
			break;
		}
	}
	*/
}

void WayPointList::AddWayPointToPath(int waypoint){
	int wp = waypoint;
	int index;
	for(index=1; index<=numWayPoints; index++){
		if(wayPoints[index] == wp) break;
	}
	if(index>numWayPoints) return;

	//add waypoint index to path
	int n;
	for(n=0; n<32; n++){
		if(path[curPath][n] == 0){
			path[curPath][n] = index;
			break;
		}
	}
}

int WayPointList::EndPath(int endZone){
	//remove the old path
	int oldPath = zoneMatrix[curPathStartZone][endZone];
	if(oldPath){
	  int shifted = RemovePath(zoneMatrix[curPathStartZone][endZone]);
		if(shifted==curPath){
	    zoneMatrix[curPathStartZone][endZone] = oldPath;
		}else{
	    zoneMatrix[curPathStartZone][endZone] = curPath;
		}
	}else{
	  zoneMatrix[curPathStartZone][endZone] = curPath;
	}
	return zoneMatrix[curPathStartZone][endZone];
}

int  WayPointList::GetPathLength(int nPath){
	int length=0;
	int i;
	for(i=0; i<32; i++){
		if(path[nPath][i]==0) break;
		length++;
	}
	return length;
}

int  WayPointList::GetPath(int startZone, int endZone){
	return zoneMatrix[startZone][endZone];
}

int  WayPointList::GetFirstWayPoint(int npath){
	curReturnedWayPoint = 0;
	return path[npath][0];
}

int  WayPointList::WayPointExists(int i, int j){
	int wp = (j<<8) + i;

	int index;
	for(index=0; index<=numWayPoints; index++){
		if(wayPoints[index]==wp) return 1;
	}
	return 0;
}

int  WayPointList::GetNextWayPoint(int npath){
	curReturnedWayPoint++;
	if(curReturnedWayPoint==32) return 0;
	return path[npath][curReturnedWayPoint];
}

void WayPointList::Write(ostream &out){
	out.put((char) numWayPoints);
	if(!numWayPoints) return;
	out.put((char) 0);

	//write waypoints (up to 255)
	int i,j;
	for(i=1; i<=numWayPoints; i++){
		int wp = wayPoints[i];
		int w_i = wp & 0xff;
		int w_j = (wp >> 8) & 0xff;
		wp = (0xd000 + w_j*pitch + w_i);
		out.put((char) (wp & 0xff));
		out.put((char) ((wp>>8) & 0xff));
	}

	//write paths (up to 255 paths, 4 bytes each)
	out.put((char) numPaths);
	for(i=1; i<=numPaths; i++){
		for(j=0; j<4; j++){
			out.put((char) path[i][j]);
		}
	}

	//write zone matrix containing paths 16 x 16 = 256 bytes 
	for(j=0; j<16; j++){
		for(i=0; i<16; i++){
			out.put((char) zoneMatrix[i][j]);
		}
	}
}

void WayPointList::Read(istream &in){
	Reset();

	int pos = in.tellg();

	numWayPoints = in.get();    //get num waypoints
	numWayPoints &= 0xff;

  if(in.eof() || !numWayPoints){
    numWayPoints = 0;
    return;
  }

	in.get();                   //discard pad

	//read waypoints
	int i,j;
  for(i=1; i<=numWayPoints; i++){
		int wp = in.get() & 0xff;
		wp |= in.get() << 8;
		wp &= 0xffff;
		wp -= 0xd000;
		int w_j = wp / pitch;
		int w_i = wp % pitch;
		wayPoints[i] = (w_j<<8) | w_i;
	}

	//read paths
	numPaths = in.get() & 0xff;
	for(i=1; i<=numPaths; i++){
		for(j=0; j<4; j++){
			path[i][j] = in.get() & 0xff;
		}
	}

	//read zone matrix
	for(j=0; j<16; j++){
		for(i=0; i<16; i++){
			zoneMatrix[i][j] = in.get() & 0xff;
		}
	}
}


//global declaration
WayPointList g_wayPointList;

