#ifndef WAYPOINTLIST_H
#define WAYPOINTLIST_H

#include <fstream.h>

class WayPointList{
  protected:
    //Lookup zoneMatrix[i][j] to find out the index of the path list 
		//to go to to get from zone i to zone j.  Upon saving each path list
		//will be a linked list that may merge with another waypoint list.
		//But in the editor it's just a list of waypoints up to 32 long.
		int zoneMatrix[16][16];

    //The contents of path[i] is a list of 32 indices to waypoints
		//that a unit must travel.
		int path[256][32];

    //Each waypoint is a ((j<<8)+i) coordinate that will be 
		//$c000 + (j*pitch) + i upon saving
		int wayPoints[256];

		//up to 255
	  int numWayPoints;
		int numPaths;
		int curPath;
		int curPathStartZone;
		int curReturnedWayPoint;
		int pitch;

	public:
	  WayPointList();
	  ~WayPointList();
		void Reset();
		void CreateWayPoint(int i, int j);
		void RemoveWayPoint(int i, int j);
		void MoveWayPoint(int si, int sj, int di, int dj);
		int  RemovePath(int n);
		int  BeginPath(int zone);
		void AddWayPointToPath(int i, int j);
		void AddWayPointToPath(int waypoint);
		int  EndPath(int endZone);

		int  GetPathLength(int nPath);
		int  GetPath(int startZone, int endZone);
		int  WayPointExists(int i, int j);
		int  GetFirstWayPoint(int npath);
		int  GetNextWayPoint(int npath);

		inline void SetPitch(int p){ pitch = p; }
		inline int  GetPitch(){ return pitch; }
		inline int  GetNumPaths(){ return numPaths; }
		inline int  GetNumWayPoints(){ return numWayPoints; }
		inline int  GetWayPoint(int n){ return wayPoints[n]; }

		void Write(ostream &out);
		void Read(istream &in);
};

extern WayPointList g_wayPointList;

#endif

