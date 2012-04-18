//
//  OTSAbstractNode.h
//

#import <Foundation/Foundation.h>

#import "OTSBoundable.h"

@interface OTSAbstractNode : NSObject <OTSBoundable> {
	id bounds;
	NSMutableArray *childBoundables;
	int level;
}

@property (nonatomic, retain) NSMutableArray *childBoundables;
@property (nonatomic, assign) int level;

- (id)initWithLevel:(int)newLevel;
- (id)initWithLevel:(int)newLevel capacity:(int)capacity;
- (void)addChildBoundable:(id <OTSBoundable>)childBoundable;
- (id)computeBounds;

@end
