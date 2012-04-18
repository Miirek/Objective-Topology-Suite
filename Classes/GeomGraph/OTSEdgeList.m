//
//  OTSEdgeList.m
//

#import "OTSEdge.h"
#import "OTSEdgeList.h"
#import "OTSOrientedCoordinateArray.h"

@implementation OTSEdgeList

@synthesize edges;
@synthesize ocaMap;

- (id)init {
	if (self = [super init]) {
		self.edges = [NSMutableArray array];
		self.ocaMap = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)dealloc {
	[edges release];
	[ocaMap release];
	[super dealloc];
}

- (void)add:(OTSEdge *)e {
	[edges addObject:e];
	OTSOrientedCoordinateArray *oca = [[OTSOrientedCoordinateArray alloc] initWithCoordinateSequence:[e getCoordinates]];
	[ocaMap setObject:e forKey:oca];
	[oca release];
}

- (void)addAll:(NSArray *)edgeColl {
	for (OTSEdge *e in edgeColl) {
		[self add:e];
	}
}

- (OTSEdge *)findEqualEdge:(OTSEdge *)e {
	OTSOrientedCoordinateArray *oca = [[OTSOrientedCoordinateArray alloc] initWithCoordinateSequence:[e getCoordinates]];
	OTSEdge *ret = [ocaMap objectForKey:oca];
  [oca release];
  return ret;
}

- (OTSEdge *)get:(int)i {
	return [edges objectAtIndex:i];
}

- (int)findEdgeIndex:(OTSEdge *)e {	
	for (int i = 0, s = [edges count]; i < s; ++i) {
		OTSEdge *ce = [edges objectAtIndex:i];
		if ([ce equalsTo:e]) return i;
	}
	return -1;
}

- (void)clearList {
	[edges removeAllObjects];
}

@end
