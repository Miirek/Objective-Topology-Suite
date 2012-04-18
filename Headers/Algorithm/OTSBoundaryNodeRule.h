//
//  OTSBoundaryNodeRule.h
//

#import <Foundation/Foundation.h>

@interface OTSBoundaryNodeRule : NSObject {
}
- (BOOL)isInBoundary:(int)boundaryCount;
+ (OTSBoundaryNodeRule *)OGC_SFS_BOUNDARY_RULE;
@end

@interface OTSMod2BoundaryNodeRule : OTSBoundaryNodeRule {
}
+ (OTSMod2BoundaryNodeRule *)instance;
@end

@interface OTSEndPointBoundaryNodeRule : OTSBoundaryNodeRule {
}
+ (OTSEndPointBoundaryNodeRule *)instance;
@end

@interface OTSMultiValentEndPointBoundaryNodeRule : OTSBoundaryNodeRule {
}
+ (OTSMultiValentEndPointBoundaryNodeRule *)instance;
@end

@interface OTSMonoValentEndPointBoundaryNodeRule : OTSBoundaryNodeRule {
}
+ (OTSMonoValentEndPointBoundaryNodeRule *)instance;
@end
