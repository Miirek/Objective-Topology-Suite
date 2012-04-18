//
//  OTSBoundaryNodeRule.m
//

#import "OTSBoundaryNodeRule.h"

static OTSMod2BoundaryNodeRule *mod2Rule = nil;
static OTSEndPointBoundaryNodeRule *endPointRule = nil;
static OTSMultiValentEndPointBoundaryNodeRule *multiValentRule = nil;
static OTSMonoValentEndPointBoundaryNodeRule *monoValentRule = nil;

@implementation OTSBoundaryNodeRule

+ (OTSBoundaryNodeRule *)OGC_SFS_BOUNDARY_RULE {
	return [OTSMod2BoundaryNodeRule instance];
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

- (BOOL)isInBoundary:(int)boundaryCount {
	return NO;
}

@end

@implementation OTSMod2BoundaryNodeRule

+ (OTSMod2BoundaryNodeRule *)instance {
    @synchronized(self) {
        if (mod2Rule == nil)
			mod2Rule = [[OTSMod2BoundaryNodeRule alloc] init];
    }
    return mod2Rule;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (mod2Rule == nil) {
            mod2Rule = [super allocWithZone:zone];
            return mod2Rule;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (BOOL)isInBoundary:(int)boundaryCount {
	// the "Mod-2 Rule"
	return boundaryCount % 2 == 1;
}

@end

@implementation OTSEndPointBoundaryNodeRule

+ (OTSEndPointBoundaryNodeRule *)instance {
    @synchronized(self) {
        if (endPointRule == nil)
			endPointRule = [[OTSEndPointBoundaryNodeRule alloc] init];
    }
    return endPointRule;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (endPointRule == nil) {
            endPointRule = [super allocWithZone:zone];
            return endPointRule;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (BOOL)isInBoundary:(int)boundaryCount {
	return boundaryCount > 0;
}

@end

@implementation OTSMultiValentEndPointBoundaryNodeRule

+ (OTSMultiValentEndPointBoundaryNodeRule *)instance {
    @synchronized(self) {
        if (multiValentRule == nil)
			multiValentRule = [[OTSMultiValentEndPointBoundaryNodeRule alloc] init];
    }
    return multiValentRule;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (multiValentRule == nil) {
            multiValentRule = [super allocWithZone:zone];
            return multiValentRule;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (BOOL)isInBoundary:(int)boundaryCount {
	return boundaryCount > 0;
}

@end

@implementation OTSMonoValentEndPointBoundaryNodeRule

+ (OTSMonoValentEndPointBoundaryNodeRule *)instance {
    @synchronized(self) {
        if (monoValentRule == nil)
			monoValentRule = [[OTSMonoValentEndPointBoundaryNodeRule alloc] init];
    }
    return monoValentRule;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (monoValentRule == nil) {
            monoValentRule = [super allocWithZone:zone];
            return monoValentRule;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (BOOL)isInBoundary:(int)boundaryCount {
	return boundaryCount > 0;
}

@end

