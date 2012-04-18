//
//  OTSNodeFactory.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;
@class OTSNode;

@interface OTSNodeFactory : NSObject {
}

+ (OTSNodeFactory *)instance;
- (OTSNode *)nodeWithCoordinate:(OTSCoordinate *)coord;

+ (id)allocWithZoneSkipSingleton:(NSZone *)zone;

@end
