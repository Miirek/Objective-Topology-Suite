//
//  OTSOverlayNodeFactory.m
//

#import "OTSOverlayNodeFactory.h"
#import "OTSNode.h"
#import "OTSDirectedEdgeStar.h"

static OTSOverlayNodeFactory *singletonOverlayNodeFactory = nil;

@implementation OTSOverlayNodeFactory

+ (OTSNodeFactory *)instance {
	@synchronized(self) {
        if (singletonOverlayNodeFactory == nil)
			singletonOverlayNodeFactory = [[OTSOverlayNodeFactory alloc] init];
    }
    return singletonOverlayNodeFactory;	
}

- (OTSNode *)nodeWithCoordinate:(OTSCoordinate *)coord {
	OTSDirectedEdgeStar *des = [[OTSDirectedEdgeStar alloc] init];
	OTSNode *ret = [[[OTSNode alloc] initWithCoordinate:coord edges:des] autorelease];
	[des release];
	return ret;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonOverlayNodeFactory == nil) {
            //singletonOverlayNodeFactory = [super allocWithZone:zone];
			singletonOverlayNodeFactory = [super allocWithZoneSkipSingleton:zone];
            return singletonOverlayNodeFactory;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

@end
