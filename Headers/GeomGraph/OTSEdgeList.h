//
//  OTSEdgeList.h
//

#import <Foundation/Foundation.h>

#import "OTSOrientedCoordinateArray.h" // for map comparator

//@class OTSSpatialIndex;
@class OTSEdge;

@interface OTSEdgeList : NSObject {
	NSMutableArray *edges;
	NSMutableDictionary *ocaMap;
}

@property (nonatomic, retain) NSMutableArray *edges;
@property (nonatomic, retain) NSMutableDictionary *ocaMap;

- (void)add:(OTSEdge *)e;
- (void)addAll:(NSArray *)edgeColl;
- (OTSEdge *)findEqualEdge:(OTSEdge *)e;
- (OTSEdge *)get:(int)i;
- (int)findEdgeIndex:(OTSEdge *)e;
- (void)clearList;

@end
