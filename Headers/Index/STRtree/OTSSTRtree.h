//
//  OTSSTRtree.h
//

#import <Foundation/Foundation.h>

#import "OTSAbstractSTRtree.h" // for inheritance
#import "OTSSpatialIndex.h" // for inheritance
#import "OTSEnvelope.h" // for inlines
#import "OTSBoundable.h"

@interface OTSSTRIntersectsOp : NSObject <OTSIntersectsOp> {	
}
@end


@interface OTSSTRtree : OTSAbstractSTRtree <OTSSpatialIndex> {
	OTSSTRIntersectsOp *intersectsOp;
}

- (id)initWithCapacity:(int)newNodeCapacity;

- (NSArray *)createParentBoundablesFromVerticalSlices:(NSArray *)verticalSlices level:(int)newLevel;
- (NSArray *)createParentBoundablesFromVerticalSlicesWithChildBoundables:(NSArray *)childBoundables level:(int)newLevel;
- (NSArray *)verticalSlices:(NSArray *)childBoundables count:(int)sliceCount;
+ (double)avgOfDouble:(double)a andDouble:(double)b;
+ (double)centreY:(OTSEnvelope *)e;

- (NSArray *)createParentBoundables:(NSArray *)childBoundables level:(int)newLevel;
- (NSArray *)sortBoundables:(NSArray *)input;
- (OTSAbstractNode *)createNode:(int)level;
- (id <NSObject, OTSIntersectsOp>)getIntersectsOp;

- (void)insert:(id)item havingEnvelope:(OTSEnvelope *)itemEnv;
- (void)query:(OTSEnvelope *)searchEnv into:(NSMutableArray *)output;
- (void)query:(OTSEnvelope *)searchEnv with:(id <OTSItemVisitor>)visitor;
- (BOOL)remove:(id)item havingEnvelope:(OTSEnvelope *)itemEnv;

@end
