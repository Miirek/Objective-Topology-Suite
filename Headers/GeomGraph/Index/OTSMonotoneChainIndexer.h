//
//  OTSMonotoneChainIndexer.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinateSequence;

@interface OTSMonotoneChainIndexer : NSObject {

}

- (void)getChainStartIndices:(OTSCoordinateSequence *)pts startIndexList:(NSMutableArray *)startIndexList;
- (int)findChainEnd:(OTSCoordinateSequence *)pts start:(int)start;

@end
