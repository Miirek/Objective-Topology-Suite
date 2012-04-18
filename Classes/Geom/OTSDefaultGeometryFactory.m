//
//  OTSDefaultGeometryFactory.m
//  VectorMap
//

#import "OTSGeometryFactory.h"
#import "OTSDefaultGeometryFactory.h"

static OTSDefaultGeometryFactory *singletonDefaultGeometryFactory = nil;

@implementation OTSDefaultGeometryFactory

+ (OTSDefaultGeometryFactory *)instance {
	@synchronized(self) {
    if (singletonDefaultGeometryFactory == nil)
			singletonDefaultGeometryFactory = [[OTSGeometryFactory alloc] init];
  }
  return singletonDefaultGeometryFactory;	
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (singletonDefaultGeometryFactory == nil) {
      singletonDefaultGeometryFactory = [super allocWithZone:zone];
      return singletonDefaultGeometryFactory;  // assignment and return on first allocation
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
