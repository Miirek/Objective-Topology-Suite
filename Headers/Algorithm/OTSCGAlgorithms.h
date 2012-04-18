//
//  OTSCGAlgorithms.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;
@class OTSCoordinateSequence;

enum {
	kOTSCGAClockwise=-1,
	kOTSCGACollinear,
	kOTSCGACounterClockwise
};

enum {
	kOTSCGARight=-1,
	kOTSCGALeft,
	kOTSCGAStraight
};

@interface OTSCGAlgorithms : NSObject {

}

+ (BOOL)isPoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring;
+ (BOOL)isPoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring;
+ (int)locatePoint:(OTSCoordinate *)p inRing:(OTSCoordinateSequence*)ring;
+ (int)locatePoint:(OTSCoordinate *)p inArrayRing:(NSArray *)ring;
+ (BOOL)isPoint:(OTSCoordinate *)p onLine:(OTSCoordinateSequence*) pt;
+ (BOOL)isCCW:(OTSCoordinateSequence*)ring;
+ (int)computeOrientation:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q:(OTSCoordinate *)q;
+ (double)distancePointLine:(OTSCoordinate *)p A:(OTSCoordinate *) A B:(OTSCoordinate *)B;
+ (double)distancePointLinePerpendicular:(OTSCoordinate *)p A:(OTSCoordinate *) A B:(OTSCoordinate *)B;
+ (double)distanceLineLine:(OTSCoordinate *) A B:(OTSCoordinate *)B C:(OTSCoordinate *)C D:(OTSCoordinate *)D;
+ (double)signedArea:(OTSCoordinateSequence *)ring;
+ (double)length:(OTSCoordinateSequence *)pts;
+ (int)orientationIndex:(OTSCoordinate *)p1 p2:(OTSCoordinate *)p2 q:(OTSCoordinate *)q;

@end
