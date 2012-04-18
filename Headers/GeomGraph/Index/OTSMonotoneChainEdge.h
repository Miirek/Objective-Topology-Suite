//
//  OTSMonotoneChainEdge.h
//

#import <Foundation/Foundation.h>

#import "OTSEnvelope.h" // for composition

@class OTSCoordinateSequence;
@class OTSEdge;
@class OTSSegmentIntersector;

@interface OTSMonotoneChainEdge : NSObject {
	OTSEdge *e;
	OTSCoordinateSequence* pts; // cache a reference to the coord array, for efficiency
	// the lists of start/end indexes of the monotone chains.
	// Includes the end point of the edge as a sentinel
	NSMutableArray *startIndex;
	// these envelopes are created once and reused
	OTSEnvelope *env1;
	OTSEnvelope *env2;
}

@property (nonatomic, retain) OTSEdge *e;
@property (nonatomic, retain) OTSCoordinateSequence* pts; 
@property (nonatomic, retain) NSMutableArray *startIndex;
@property (nonatomic, retain) OTSEnvelope *env1;
@property (nonatomic, retain) OTSEnvelope *env2;

- (id)initWithEdge:(OTSEdge *)newE;
- (double)minX:(int)chainIndex;
- (double)maxX:(int)chainIndex;

- (OTSCoordinateSequence *)getCoordinates;
- (NSMutableArray *)getStartIndexes;
- (void)computeIntersects:(OTSMonotoneChainEdge *)mce si:(OTSSegmentIntersector *)si;
- (void)computeIntersectsForChainWithChainIndex0:(int)chainIndex0 mce:(OTSMonotoneChainEdge *)mce chainIndex1:(int)chainIndex1 si:(OTSSegmentIntersector *)si;
- (void)computeIntersectsForChainWithStart0:(int)start0 end0:(int)end0 mce:(OTSMonotoneChainEdge *)mce start1:(int)start1 end1:(int)end1 si:(OTSSegmentIntersector *)si;

@end
