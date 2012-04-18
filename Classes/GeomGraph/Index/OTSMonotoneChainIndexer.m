//
//  OTSMonotoneChainIndexer.m
//

#import "OTSMonotoneChainIndexer.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSQuadrant.h"

@implementation OTSMonotoneChainIndexer

- (void)getChainStartIndices:(OTSCoordinateSequence *)pts startIndexList:(NSMutableArray *)startIndexList {
	// find the startpoint (and endpoints) of all monotone chains
	// in this edge
	int start = 0;
	//vector<int>* startIndexList=new vector<int>();
	[startIndexList addObject:[NSNumber numberWithInt:start]];
	do {
		int last = [self findChainEnd:pts start:start];
		[startIndexList addObject:[NSNumber numberWithInt:last]];
		start = last;
	} while (start < [pts size]-1);
}

- (int)findChainEnd:(OTSCoordinateSequence *)pts start:(int)start {
	// determine quadrant for chain	
	int chainQuad = [OTSQuadrant quadrant:[pts getAt:start] p1:[pts getAt:start + 1]];
	int last = start + 1;
	while (last < [pts size]) {
		// compute quadrant for next possible segment in chain
		int quad = [OTSQuadrant quadrant:[pts getAt:last - 1] p1:[pts getAt:last]];
		if (quad != chainQuad) break;
		last++;
	}
	return last - 1;	
}

@end
