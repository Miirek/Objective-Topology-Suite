//
//  OTSPointOnGeometryLocator.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate; 

@interface OTSPointOnGeometryLocator : NSObject {

}

- (int)locate:(OTSCoordinate *)p;

@end
