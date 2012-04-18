//
//  OTSCoordinateSequenceFactory.m
//

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinateSequenceFactory.h"

static OTSCoordinateSequenceFactory *singletonCoordinateSequenceFactory = nil;

@implementation OTSCoordinateSequenceFactory

- (OTSCoordinateSequence *)createWithArray:(NSArray *)coordinates {
	return [[[OTSCoordinateSequence alloc] initWithArray:coordinates] autorelease];
}

- (OTSCoordinateSequence *)createWithSize:(int)size dimension:(int)dimension {	
	return [[[OTSCoordinateSequence alloc] initWithCapacity:size] autorelease];
}

+ (OTSCoordinateSequenceFactory *)instance {
	@synchronized(self) {
        if (singletonCoordinateSequenceFactory == nil)
			singletonCoordinateSequenceFactory = [[OTSCoordinateSequenceFactory alloc] init];
    }
    return singletonCoordinateSequenceFactory;	
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonCoordinateSequenceFactory == nil) {
            singletonCoordinateSequenceFactory = [super allocWithZone:zone];
            return singletonCoordinateSequenceFactory;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
