//
//  OTSRelateNodeFactory.m
//

#import "OTSRelateNodeFactory.h"
#import "OTSRelateNode.h"
#import "OTSEdgeEndBundleStar.h"

static OTSRelateNodeFactory *singletonRelateNodeFactory = nil;

@implementation OTSRelateNodeFactory

+ (OTSNodeFactory *)instance {
	@synchronized(self) {
        if (singletonRelateNodeFactory == nil)
			singletonRelateNodeFactory = [[OTSRelateNodeFactory alloc] init];
    }
    return singletonRelateNodeFactory;	
}

- (OTSNode *)nodeWithCoordinate:(OTSCoordinate *)coord {
	return [[[OTSRelateNode alloc] initWithCoordinate:coord 
												   edges:[[[OTSEdgeEndBundleStar alloc] init] autorelease]] autorelease];
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonRelateNodeFactory == nil) {
            singletonRelateNodeFactory = [super allocWithZoneSkipSingleton:zone];
            return singletonRelateNodeFactory;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


@end
