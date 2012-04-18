//
//  OTSSegmentIntersectionTester.h
//

#import <Foundation/Foundation.h>

#import "OTSLineIntersector.h" // for composition

@class OTSLineString;
@class OTSCoordinateSequence;

@interface OTSSegmentIntersectionTester : NSObject {
	OTSLineIntersector *li;
	BOOL hasIntersection;
}

@property (nonatomic, retain) OTSLineIntersector *li;
@property (nonatomic, assign) BOOL hasIntersection;

- (BOOL)coordinateSequence:(OTSCoordinateSequence *)seq hasIntersectionWithLineStrings:(NSArray *)lines;
- (BOOL)coordinateSequence:(OTSCoordinateSequence *)seq0 hasIntersectionCoordinateSequence:(OTSCoordinateSequence *)seq1;

@end
