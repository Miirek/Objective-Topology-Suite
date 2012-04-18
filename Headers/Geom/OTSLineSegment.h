//
//  OTSLineSegment.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for composition

@class OTSCoordinateSequence;
@class OTSGeometryFactory;
@class OTSLineString;

@interface OTSLineSegment : NSObject {
	OTSCoordinate *p0; /// Segment start	
	OTSCoordinate *p1; /// Segemnt end
}

@property (nonatomic, retain) OTSCoordinate *p0;
@property (nonatomic, retain) OTSCoordinate *p1;

- (id)initWithCoordinate:(OTSCoordinate *)_p0 toCoordinate:(OTSCoordinate *)_p1;

- (double)distance:(OTSCoordinate *)p;
- (double)projectionFactor:(OTSCoordinate *)p;
- (OTSCoordinate *)project:(OTSCoordinate *)p;
- (OTSCoordinate *)closestPoint:(OTSCoordinate *)p;
- (OTSCoordinateSequence *)closestPoints:(OTSLineSegment *)line;
- (OTSCoordinate *)intersection:(OTSLineSegment *)line;


@end
