//
//  OTSRayCrossingCounter.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;
@class OTSCoordinateSequence;

@interface OTSRayCrossingCounter : NSObject {
	OTSCoordinate *point;
	int crossingCount;
	// true if the test point lies on an input segment
    bool pointOnSegment;
}

@property (nonatomic, retain) OTSCoordinate *point;
@property (nonatomic, assign) int crossingCount;
@property (nonatomic, assign) bool pointOnSegment;

- (id)initWithPoint:(OTSCoordinate *)point;
+ (int)locatePoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring;
+ (int)locatePoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring;
- (void)countSegment:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2;
- (int)getLocation;
- (BOOL)isPointInPolygon;

@end
