//
//  OTSHCoordinate.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;

@interface OTSHCoordinate : NSObject {
	long double x;
	long double y;
	long double w;
}

@property (nonatomic, assign) long double x;
@property (nonatomic, assign) long double y;
@property (nonatomic, assign) long double w;

+ (OTSCoordinate *)intersectionOfP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q1:(OTSCoordinate *)q1 q2:(OTSCoordinate *)q2;

- (id)initWithX:(long double)_x y:(long double)_y w:(long double)_w;
- (id)initWithCoordinate:(OTSCoordinate *)p;
- (id)initWithCoordinateP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2;
- (id)initWithCoordinateP1:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q1:(OTSCoordinate *)q1 q2:(OTSCoordinate *)q2;
- (id)initWithHCoordinateP1:(OTSHCoordinate *)p1 p2:(OTSHCoordinate *)p2;

- (long double)getComputedX;
- (long double)getComputedY;
- (OTSCoordinate *)getCoordinate;

@end
