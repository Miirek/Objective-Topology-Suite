//
//  OTSSpatialIndex.h
//

#import <Foundation/Foundation.h>

@class OTSEnvelope;

@protocol OTSSpatialIndex

- (void)insert:(id)item havingEnvelope:(OTSEnvelope *)itemEnv;
- (void)query:(OTSEnvelope *)searchEnv into:(NSMutableArray *)output;
- (void)query:(OTSEnvelope *)searchEnv with:(id <OTSItemVisitor>)visitor;
- (BOOL)remove:(id)item havingEnvelope:(OTSEnvelope *)itemEnv;

@end
