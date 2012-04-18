//
//  OTSEdgeEndStar.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeEnd.h"  // for EdgeEndLT
#import "OTSCoordinate.h"  // for p0,p1

@class OTSBoundaryNodeRule;
@class OTSGeometryGraph;

@interface OTSEdgeEndStar : NSObject {
	NSMutableArray *edgeMap;
	int ptInAreaLocation[2];
}

@property (nonatomic, retain) NSMutableArray *edgeMap;

- (void)insert:(OTSEdgeEnd *)e;
- (OTSCoordinate *)getCoordinate;
- (int)getDegree;
- (OTSEdgeEnd *)getNextCW:(OTSEdgeEnd *)ee;
- (void)computeLabelling:(NSArray *)geomGraph;
- (BOOL)isAreaLabelsConsistent:(OTSGeometryGraph *)geomGraph;
- (void)propagateSideLabels:(int)geomIndex;
- (int)find:(OTSEdgeEnd *)eSearch;
- (void)insertEdgeEnd:(OTSEdgeEnd *)ee;
- (int)getLocation:(int)geomIndex p:(OTSCoordinate *)p geom:(NSArray *)geom; 
- (void)computeEdgeEndLabels:(OTSBoundaryNodeRule *)bnr;
- (BOOL)checkAreaLabelsConsistent:(int)geomIndex;

@end
