//
//  OTSNodeFactory.m
//

#import "OTSCoordinate.h"
#import "OTSNode.h"
#import "OTSNodeFactory.h"

static OTSNodeFactory *singletonNodeFactory = nil;

@implementation OTSNodeFactory

+ (OTSNodeFactory *)instance {
	@synchronized(self) {
        if (singletonNodeFactory == nil)
			singletonNodeFactory = [[OTSNodeFactory alloc] init];
    }
    return singletonNodeFactory;	
}

- (OTSNode *)nodeWithCoordinate:(OTSCoordinate *)coord {
	return [[[OTSNode alloc] initWithCoordinate:coord edges:nil] autorelease];
}

+ (id)allocWithZoneSkipSingleton:(NSZone *)zone {
	return [super allocWithZone:zone];
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonNodeFactory == nil) {
            singletonNodeFactory = [super allocWithZone:zone];
            return singletonNodeFactory;  // assignment and return on first allocation
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
