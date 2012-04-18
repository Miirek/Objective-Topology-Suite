//
//  OTSCoordinateSequence.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for applyCoordinateFilter

@class OTSEnvelope;
@class OTSCoordinateFilter;
@class OTSCoordinate;

@interface OTSCoordinateSequence : NSObject {
	NSMutableArray *coordinates;
}

@property (nonatomic, retain) NSMutableArray *coordinates;

- (id)init;
- (id)initWithArray:(NSArray *)_coordinates;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)other;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)other allowRepeated:(BOOL)allowRepeated;
- (id)initWithCapacity:(int)capacity;

- (void)add:(OTSCoordinate *)coordinate;
- (int)size;
- (OTSCoordinate *)getAt:(NSUInteger)index;
- (void)set:(OTSCoordinate *)coordinate at:(NSUInteger)index;
- (OTSCoordinateSequence *)clone;
- (NSArray *)toArray;
- (void)apply_rw:(OTSCoordinateFilter *)filter;
- (void)apply_ro:(OTSCoordinateFilter *)filter;

+ (BOOL)hasRepeatedPoints:(OTSCoordinateSequence *)cl;
+ (OTSCoordinateSequence *)removeRepeatedPoints:(OTSCoordinateSequence *)cl;
+ (int)increasingDirection:(OTSCoordinateSequence *)pts;

// autoreleased factory method
+ (id)coordinateSequenceWithArray:(NSArray *)_coordinates;
+ (id)coordinateSequenceWithCoordinates:(OTSCoordinate *)firstObject, ...;
//+ (id)coordinateSequenceWithArrayOfXY:(double)firstOordinate, ...;

@end
