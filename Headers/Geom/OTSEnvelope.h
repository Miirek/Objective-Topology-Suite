//
//  OTSEnvelope.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"

@interface OTSEnvelope : NSObject {
	/// the minimum x-coordinate
	double minx;
	/// the maximum x-coordinate
	double maxx;
	/// the minimum y-coordinate
	double miny;
	/// the maximum y-coordinate
	double maxy;
}

@property (nonatomic, assign) double minx;
@property (nonatomic, assign) double maxx;
@property (nonatomic, assign) double miny;
@property (nonatomic, assign) double maxy;

- (id)initWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2;
- (id)initWithFirstCoordinate:(OTSCoordinate *)p1 secondCoordinate:(OTSCoordinate *)p2;
- (id)initWithCoordinate:(OTSCoordinate *)p;
- (id)initWithEnvelope:(OTSEnvelope *)env;

- (void)setWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2;
- (void)setWithFirstCoordinate:(OTSCoordinate *)p1 secondCoordinate:(OTSCoordinate *)p2;

+ (id)envelopeWithFirstX:(double)x1 secondX:(double)x2 firstY:(double)y1 secondY:(double)y2;

+ (BOOL)isFirstCoordinate:(OTSCoordinate *)p1 
		 secondCoordinate:(OTSCoordinate *)p2 
			   intersects:(OTSCoordinate *)q;

+ (BOOL)isFirstCoordinate:(OTSCoordinate *)p1 
		 secondCoordinate:(OTSCoordinate *)p2 
intersectsFirstCoordinate:(OTSCoordinate *)q1 
	  andSecondCoordinate:(OTSCoordinate *)q2;

- (void)setToNull;
- (BOOL)isNull;
- (double)width;
- (double)height;
- (double)area;
- (OTSCoordinate *)centre;

- (OTSEnvelope *)intersection:(OTSEnvelope *)env;
- (void)translateWithX:(double)transX andY:(double)transY;
- (void)expandByDeltaX:(double)deltaX deltaY:(double)deltaY;
- (void)expandByDistance:(double)distance;
- (void)expandToIncludeCoordinate:(OTSCoordinate *)p;
- (void)expandToIncludeX:(double)x andY:(double)y;
- (void)expandToInclude:(OTSEnvelope *)other;
- (BOOL)contains:(OTSEnvelope *)other;
- (BOOL)containsCoordinate:(OTSCoordinate *)p;
- (BOOL)containsX:(double)x andY:(double)y;
- (BOOL)intersectsCoordinate:(OTSCoordinate *)p;
- (BOOL)intersectsX:(double)x andY:(double)y;
- (BOOL)intersects:(OTSEnvelope *)other;
- (BOOL)coversCoordinate:(OTSCoordinate *)p;
- (BOOL)coversX:(double)x andY:(double)y;
- (BOOL)covers:(OTSEnvelope *)other;
- (BOOL)equals:(OTSEnvelope *)other;
- (double)distanceToFirstX:(double)x0 firstY:(double)y0 secondX:(double)x1 secondY:(double)y1;
- (double)distanceTo:(OTSEnvelope *)env;

@end
