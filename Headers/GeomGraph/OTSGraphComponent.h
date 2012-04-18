//
//  OTSGraphComponent.h
//

#import <Foundation/Foundation.h>

@class OTSIntersectionMatrix;
@class OTSLabel;

@interface OTSGraphComponent : NSObject {
	OTSLabel *label;
	BOOL inResult;
	BOOL covered;
	BOOL coveredSet;
	BOOL visited;
	BOOL isolated;
}

@property (nonatomic, retain) OTSLabel *label;
@property (nonatomic, assign) BOOL inResult;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) BOOL isolated;

- (id)initWithLabel:(OTSLabel *)_label;
- (void)updateIM:(OTSIntersectionMatrix *)im;
- (void)computeIM:(OTSIntersectionMatrix *)im;

- (void)setCovered:(BOOL)isCovered;
- (BOOL)isCovered;
- (BOOL)isCoveredSet;
- (BOOL)isIsolated;

@end
