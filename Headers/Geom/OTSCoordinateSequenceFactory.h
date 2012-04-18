//
//  OTSCoordinateSequenceFactory.h
//

#import <Foundation/Foundation.h>


@interface OTSCoordinateSequenceFactory : NSObject {

}

- (OTSCoordinateSequence *)createWithArray:(NSArray *)coordinates;
- (OTSCoordinateSequence *)createWithSize:(int)size dimension:(int)dimension;
+ (OTSCoordinateSequenceFactory *)instance;

@end
