//
//  OTSLabel.h
//

#import <Foundation/Foundation.h>

#import "OTSTopologyLocation.h" 

@interface OTSLabel : NSObject {
	OTSTopologyLocation *elt[2];
}

+ (OTSLabel *)lineLabelFromLabel:(OTSLabel *)label;

- (id)initWithOnLocation:(int)onLoc;
- (id)initWithGeometryIndex:(int)geomIndex onLocation:(int)onLoc;
- (id)initWithOnLocation:(int)onLoc 
			leftLocation:(int)leftLoc 
		   rightLocation:(int)rightLoc;
- (id)initWithGeometryIndex:(int)geomIndex 
				 onLocation:(int)onLoc 
			   leftLocation:(int)leftLoc 
			  rightLocation:(int)rightLoc;
- (id)initWithLabel:(OTSLabel *)l;

- (void)flip;
- (int)locationAtGeometryIndex:(int)geomIndex atPosIndex:(int)posIndex;
- (int)locationAtGeometryIndex:(int)geomIndex;
- (void)setLocation:(int)location atGeometryIndex:(int)geomIndex atPosIndex:(int)posIndex;
- (void)setLocation:(int)location atGeometryIndex:(int)geomIndex;
- (void)setAllLocations:(int)location atGeometryIndex:(int)geomIndex;
- (void)setAllLocationsIfNull:(int)location atGeometryIndex:(int)geomIndex;
- (void)setAllLocationsIfNull:(int)location;
- (void)merge:(OTSLabel *)lbl;
- (int)geometryCount;
- (BOOL)isNullAtGeometryIndex:(int)geomIndex;
- (BOOL)isAnyNullAtGeometryIndex:(int)geomIndex;
- (BOOL)isArea;
- (BOOL)isAreaAtGeometryIndex:(int)geomIndex;
- (BOOL)isLineAtGeometryIndex:(int)geomIndex;
- (BOOL)isLabel:(OTSLabel *)lbl equalOnSide:(int)side;
- (BOOL)allPositionsEqualAtGeometryIndex:(int)geomIndex toLocation:(int)location;
- (void) toLineAtGeometryIndex:(int)geomIndex;

- (OTSTopologyLocation *)getLocationAt:(int)idx;

@end
