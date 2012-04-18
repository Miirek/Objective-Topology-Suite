//
//  OTSDepth.h
//

#import <Foundation/Foundation.h>

@class OTSLabel;

enum {
	kOTSDepthNullValue=-1 //Replaces NULL
};

@interface OTSDepth : NSObject {
	int depth[2][3];
}

+ (int)depthAtLocation:(int)location;
- (int)depthAt:(int)geomIndex posIndex:(int)posIndex;
- (void)setDepth:(int)depthValue at:(int)geomIndex posIndex:(int)posIndex;
- (int)locationAt:(int)geomIndex posIndex:(int)posIndex;
- (void)addLocation:(int)location at:(int)geomIndex posIndex:(int)posIndex;
- (BOOL)isNull;
- (BOOL)isNullAt:(int)geomIndex;
- (BOOL)isNullAt:(int)geomIndex posIndex:(int)posIndex;
- (int)deltaAt:(int)geomIndex;
- (void)normalize;
- (void)addLabel:(OTSLabel *)lbl;

@end
