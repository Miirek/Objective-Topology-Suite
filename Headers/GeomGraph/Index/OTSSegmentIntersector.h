//
//  OTSSegmentIntersector.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for composition

@class OTSLineIntersector;
@class OTSNode;
@class OTSEdge;


@interface OTSSegmentIntersector : NSObject {
	/**
	 * These variables keep track of what types of intersections were
	 * found during ALL edges that have been intersected.
	 */
	BOOL hasIntersection;
	BOOL hasProperIntersection;
	BOOL hasProperInteriorIntersection;
	
	// the proper intersection point found
	OTSCoordinate *properIntersectionPoint;
	
	OTSLineIntersector *li;
	
	BOOL includeProper;
	BOOL recordIsolated;
	
	int numIntersections;
	
	/// Elements are externally owned (std::vector<std::vector<Node*>*> bdyNodes)
	NSMutableArray *bdyNodes;
}

@property (nonatomic, assign) BOOL hasIntersection;
@property (nonatomic, assign) BOOL hasProperIntersection;
@property (nonatomic, assign) BOOL hasProperInteriorIntersection;
@property (nonatomic, retain) OTSCoordinate *properIntersectionPoint;
@property (nonatomic, retain) OTSLineIntersector *li;
@property (nonatomic, assign) BOOL includeProper;
@property (nonatomic, assign) BOOL recordIsolated;
@property (nonatomic, assign) int numIntersections;
@property (nonatomic, retain) NSMutableArray *bdyNodes;

- (id)initWithLineIntersector:(OTSLineIntersector *)newLi 
			 newIncludeProper:(BOOL)newIncludeProper 
			newRecordIsolated:(BOOL)newRecordIsolated;

- (BOOL)isTrivialIntersection:(OTSEdge *)e0 
					segIndex0:(int)segIndex0 
						   e1:(OTSEdge *)e1 
					segIndex1:(int)segIndex1;

- (BOOL)isBoundaryPoint:(OTSLineIntersector *)_li arrayOfArraysOfNodes:(NSArray *)tstBdyNodes;
- (BOOL)isBoundaryPoint:(OTSLineIntersector *)_li arrayOfNodes:(NSArray *)tstBdyNodes;

+ (BOOL)isAdjacentSegments:(int)i1 i2:(int)i2;
- (void)setBoundaryNodes:(NSArray *)bdyNodes0 bdyNodes1:(NSArray *)bdyNodes1;

- (void)addIntersections:(OTSEdge *)e0 
			   segIndex0:(int)segIndex0 
					  e1:(OTSEdge *)e1 
			   segIndex1:(int)segIndex1;

@end
