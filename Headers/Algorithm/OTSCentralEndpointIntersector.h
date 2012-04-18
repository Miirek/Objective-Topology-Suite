//
//  OTSCentralEndpointIntersector.h
//

#import <Foundation/Foundation.h>


@interface OTSCentralEndpointIntersector : NSObject {
	NSArray *pts;
	OTSCoordinate *intPt;	
}

@property (nonatomic, retain) NSArray *pts;
@property (nonatomic, retain) OTSCoordinate *intPt;

+ (OTSCoordinate *)getIntersection:(OTSCoordinate *)p00 
								  p01:(OTSCoordinate *)p01 
								  p10:(OTSCoordinate *)p10 
								  p11:(OTSCoordinate *)p11;
+ (OTSCoordinate *)average:(NSArray *)ppts;

- (id)initWithP00:(OTSCoordinate *)p00 
			  p01:(OTSCoordinate *)p01 
			  p10:(OTSCoordinate *)p10 
			  p11:(OTSCoordinate *)p11;
- (OTSCoordinate *)getIntersection;
- (void)compute;
- (OTSCoordinate *)findNearestPoint:(OTSCoordinate *) p pts:(NSArray *)ppts;

@end
