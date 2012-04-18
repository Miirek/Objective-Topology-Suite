//
//  OTSIntersectionMatrix.h
//

#import <Foundation/Foundation.h>


@interface OTSIntersectionMatrix : NSObject {
	int firstDim; // = 3;
	int secondDim; // = 3;	
	// Internal buffer for 3x3 matrix.
	int matrix[3][3];	
}

@property (nonatomic, assign) int firstDim;
@property (nonatomic, assign) int secondDim;

- (id)initWithDimensionSymbols:(NSString *)elements;
- (id)initWithIntersectionMatrix:(OTSIntersectionMatrix *)other;
- (BOOL)matchesRequiredDimensionSymbols:(NSString *)requiredDimensionSymbols;
+ (BOOL)matchesActualDimensionValue:(int)actualDimensionValue requiredDimensionSymbol:(char)requiredDimensionSymbol;
+ (BOOL)matchesActualDimensionSymbols:(NSString *)actualDimensionSymbols requiredDimensionSymbols:(NSString *)requiredDimensionSymbols;
- (void)addIntersectionMatrix:(OTSIntersectionMatrix *)other;
- (void)setRow:(int)row column:(int)column dimensionValue:(int)dimensionValue;
- (void)setDimensionSymbols:(NSString *)dimensionSymbols;
- (void)setAtLeastRow:(int)row column:(int)column dimensionValue:(int)minimumDimensionValue;
- (void)setAtLeastIfValidRow:(int)row column:(int)column dimensionValue:(int)minimumDimensionValue;
- (void)setAtLeastDimensionSymbols:(NSString *)minimumDimensionSymbols;
- (void)setAllWithDimensionValue:(int)dimensionValue;
- (int)getAtRow:(int)row column:(int)column;
- (BOOL)isDisjoint;
- (BOOL)isIntersects;
- (BOOL)isTouchesDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB;
- (BOOL)isCrossesDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB;
- (BOOL)isWithin;
- (BOOL)isContains;
- (BOOL)isEqualsDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB;
- (BOOL)isOverlapsDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB;
- (BOOL)isCovers;
- (BOOL)isCoveredBy;
- (OTSIntersectionMatrix *)transpose;

@end
