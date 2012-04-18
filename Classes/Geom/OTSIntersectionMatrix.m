//
//  OTSIntersectionMatrix.m
//

#import "OTSIntersectionMatrix.h"
#import "OTSDimension.h"
#import "OTSLocation.h"

@implementation OTSIntersectionMatrix

@synthesize firstDim;
@synthesize secondDim;

- (id)init {
	if (self = [super init]) {
		self.firstDim = 3;
		self.secondDim = 3;
		[self setAllWithDimensionValue:kOTSDimensionFalse];
	}
	return self;
}

- (id)initWithDimensionSymbols:(NSString *)elements {
	if (self = [self init]) {
		[self setAllWithDimensionValue:kOTSDimensionFalse];
		[self setDimensionSymbols:elements];
	}
	return self;
}

- (id)initWithIntersectionMatrix:(OTSIntersectionMatrix *)other {
	if (self = [self init]) {
		matrix[kOTSLocationInterior][kOTSLocationInterior] = [other getAtRow:kOTSLocationInterior column:kOTSLocationInterior];
		matrix[kOTSLocationInterior][kOTSLocationBoundary] = [other getAtRow:kOTSLocationInterior column:kOTSLocationBoundary];
		matrix[kOTSLocationInterior][kOTSLocationExterior] = [other getAtRow:kOTSLocationInterior column:kOTSLocationExterior];
		matrix[kOTSLocationBoundary][kOTSLocationInterior] = [other getAtRow:kOTSLocationBoundary column:kOTSLocationInterior];
		matrix[kOTSLocationBoundary][kOTSLocationBoundary] = [other getAtRow:kOTSLocationBoundary column:kOTSLocationBoundary];
		matrix[kOTSLocationBoundary][kOTSLocationExterior] = [other getAtRow:kOTSLocationBoundary column:kOTSLocationExterior];
		matrix[kOTSLocationExterior][kOTSLocationInterior] = [other getAtRow:kOTSLocationExterior column:kOTSLocationInterior];
		matrix[kOTSLocationExterior][kOTSLocationBoundary] = [other getAtRow:kOTSLocationExterior column:kOTSLocationBoundary];
		matrix[kOTSLocationExterior][kOTSLocationExterior] = [other getAtRow:kOTSLocationExterior column:kOTSLocationExterior];		
	}
	return self;
}

- (BOOL)matchesRequiredDimensionSymbols:(NSString *)requiredDimensionSymbols {
	if ([requiredDimensionSymbols length] != 9) {
		NSException *e = [NSException exceptionWithName:@"IllegalArgumentException" 
												 reason:[NSString stringWithFormat:@"Should be length 9, is [%@] instead", requiredDimensionSymbols] 
											   userInfo:nil];
		@throw e;
	}
	for (int ai = 0; ai < firstDim; ai++) {
		for (int bi = 0; bi < secondDim; bi++) {
			if (![OTSIntersectionMatrix matchesActualDimensionValue:matrix[ai][bi] 
											   requiredDimensionSymbol:[requiredDimensionSymbols characterAtIndex:3*ai+bi]]) {
				return NO;
			}
		}
	}
	return YES;	
}

+ (BOOL)matchesActualDimensionValue:(int)actualDimensionValue requiredDimensionSymbol:(char)requiredDimensionSymbol {
	
	if (requiredDimensionSymbol=='*') return YES;
	
	if (requiredDimensionSymbol=='T' && (actualDimensionValue >= 0 ||
										 actualDimensionValue == kOTSDimensionTrue)) {
		return YES;
	}
	
	if (requiredDimensionSymbol=='F' &&
		actualDimensionValue == kOTSDimensionFalse)
	{
		return YES;
	}
	
	if (requiredDimensionSymbol=='0' &&
		actualDimensionValue == kOTSDimensionP)
	{
		return YES;
	}
	
	if (requiredDimensionSymbol=='1' &&
		actualDimensionValue == kOTSDimensionL)
	{
		return YES;
	}
	
	if (requiredDimensionSymbol=='2' &&
		actualDimensionValue == kOTSDimensionA)
	{
		return YES;
	}
	
	return NO;
	
}

+ (BOOL)matchesActualDimensionSymbols:(NSString *)actualDimensionSymbols requiredDimensionSymbols:(NSString *)requiredDimensionSymbols {
	OTSIntersectionMatrix *m = [[OTSIntersectionMatrix alloc] initWithDimensionSymbols:actualDimensionSymbols];
	BOOL result = [m matchesRequiredDimensionSymbols:requiredDimensionSymbols];
	[m release];
	return result;	
}

- (void)addIntersectionMatrix:(OTSIntersectionMatrix *)other {
	for(int i = 0; i < firstDim; i++) {
		for(int j = 0; j < secondDim; j++) {
			[self setAtLeastRow:i column:j dimensionValue:[other getAtRow:i column:j]];
		}
	}	
}

- (void)setRow:(int)row column:(int)column dimensionValue:(int)dimensionValue {
	NSAssert(row >= 0 && row < firstDim, @"Invalid row");
	NSAssert(column >= 0 && column < secondDim, @"Invalid column");	
	matrix[row][column] = dimensionValue;
	
}

- (void)setDimensionSymbols:(NSString *)dimensionSymbols {
	int limit = [dimensionSymbols length];
	
	for (int i = 0; i < limit; i++)
	{
		int row = i / firstDim;
		int col = i % secondDim;
		matrix[row][col] = [OTSDimension toDimensionValue:[dimensionSymbols characterAtIndex:i]];
	}
	
}

- (void)setAtLeastRow:(int)row column:(int)column dimensionValue:(int)minimumDimensionValue {
	NSAssert(row >= 0 && row < firstDim, @"Invalid row");
	NSAssert(column >= 0 && column < secondDim, @"Invalid column");		
	if (matrix[row][column] < minimumDimensionValue) {
		matrix[row][column] = minimumDimensionValue;
	}
}

- (void)setAtLeastIfValidRow:(int)row column:(int)column dimensionValue:(int)minimumDimensionValue {
	NSAssert(row >= 0 && row < firstDim, @"Invalid row");
	NSAssert(column >= 0 && column < secondDim, @"Invalid column");
	
	if (row >= 0 && column >= 0) {
		[self setAtLeastRow:row column:column dimensionValue:minimumDimensionValue];
	}	
}

- (void)setAtLeastDimensionSymbols:(NSString *)minimumDimensionSymbols {
	int limit = [minimumDimensionSymbols length];
	
	for (int i = 0; i < limit; i++)
	{
		int row = i / firstDim;
		int col = i % secondDim;
		[self setAtLeastRow:row column:col dimensionValue:[OTSDimension toDimensionValue:[minimumDimensionSymbols characterAtIndex:i]]];
	}	
}

- (void)setAllWithDimensionValue:(int)dimensionValue {
	for (int ai = 0; ai < firstDim; ai++) {
		for (int bi = 0; bi < secondDim; bi++) {
			matrix[ai][bi] = dimensionValue;
		}
	}	
}

- (int)getAtRow:(int)row column:(int)column {
	NSAssert(row >= 0 && row < firstDim, @"Invalid row");
	NSAssert(column >= 0 && column < secondDim, @"Invalid column");
	return matrix[row][column];	
}

- (BOOL)isDisjoint {
	return
		matrix[kOTSLocationInterior][kOTSLocationInterior] == kOTSDimensionFalse
		&&
		matrix[kOTSLocationInterior][kOTSLocationBoundary] == kOTSDimensionFalse
		&&
		matrix[kOTSLocationBoundary][kOTSLocationInterior] == kOTSDimensionFalse
		&&
		matrix[kOTSLocationBoundary][kOTSLocationBoundary] == kOTSDimensionFalse;
	
}

- (BOOL)isIntersects {
	return ![self isDisjoint];
}

- (BOOL)isTouchesDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB {
	if (dimensionOfGeometryA > dimensionOfGeometryB) {
		//no need to get transpose because pattern matrix is symmetrical
		return [self isTouchesDimensionOfGeometryA:dimensionOfGeometryB dimensionOfGeometryB:dimensionOfGeometryA];
	}
	if ((dimensionOfGeometryA==kOTSDimensionA && dimensionOfGeometryB==kOTSDimensionA)
		||
		(dimensionOfGeometryA==kOTSDimensionL && dimensionOfGeometryB==kOTSDimensionL)
		||
		(dimensionOfGeometryA==kOTSDimensionL && dimensionOfGeometryB==kOTSDimensionA)
		||
		(dimensionOfGeometryA==kOTSDimensionP && dimensionOfGeometryB==kOTSDimensionA)
		||
		(dimensionOfGeometryA==kOTSDimensionP && dimensionOfGeometryB==kOTSDimensionL))
	{
		return 
			matrix[kOTSLocationInterior][kOTSLocationInterior]==kOTSDimensionFalse &&
			([OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationBoundary] requiredDimensionSymbol:'T'] ||
			 [OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationInterior] requiredDimensionSymbol:'T'] ||
			 [OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationBoundary] requiredDimensionSymbol:'T']);
	}
	return NO;	
}

- (BOOL)isCrossesDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB {
	if ((dimensionOfGeometryA == kOTSDimensionP && dimensionOfGeometryB == kOTSDimensionL) ||
		(dimensionOfGeometryA == kOTSDimensionP && dimensionOfGeometryB == kOTSDimensionA) ||
		(dimensionOfGeometryA == kOTSDimensionL && dimensionOfGeometryB == kOTSDimensionA)) {
		return 
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationExterior] requiredDimensionSymbol:'T'];
	}
	if ((dimensionOfGeometryA == kOTSDimensionL && dimensionOfGeometryB == kOTSDimensionP) ||
		(dimensionOfGeometryA == kOTSDimensionA && dimensionOfGeometryB == kOTSDimensionP) ||
		(dimensionOfGeometryA == kOTSDimensionA && dimensionOfGeometryB == kOTSDimensionL)) {
		return 
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationExterior][kOTSLocationInterior] requiredDimensionSymbol:'T'];
	}
	if (dimensionOfGeometryA == kOTSDimensionL && dimensionOfGeometryB == kOTSDimensionL) {		
		return matrix[kOTSLocationInterior][kOTSLocationInterior] == 0;
	}
	return NO;
}

- (BOOL)isWithin {
	return 
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
		matrix[kOTSLocationInterior][kOTSLocationExterior] == kOTSDimensionFalse &&
		matrix[kOTSLocationBoundary][kOTSLocationExterior] == kOTSDimensionFalse;	
}

- (BOOL)isContains {
	return 
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
		matrix[kOTSLocationExterior][kOTSLocationInterior] == kOTSDimensionFalse &&
		matrix[kOTSLocationExterior][kOTSLocationBoundary] == kOTSDimensionFalse;	
}

- (BOOL)isEqualsDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB {
	if (dimensionOfGeometryA != dimensionOfGeometryB) {
		return NO;
	}
	return
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
		matrix[kOTSLocationExterior][kOTSLocationInterior] == kOTSDimensionFalse &&
		matrix[kOTSLocationInterior][kOTSLocationExterior] == kOTSDimensionFalse &&
		matrix[kOTSLocationExterior][kOTSLocationBoundary] == kOTSDimensionFalse &&
		matrix[kOTSLocationBoundary][kOTSLocationExterior] == kOTSDimensionFalse;
	
}

- (BOOL)isOverlapsDimensionOfGeometryA:(int)dimensionOfGeometryA dimensionOfGeometryB:(int)dimensionOfGeometryB {
	if ((dimensionOfGeometryA == kOTSDimensionP && dimensionOfGeometryB == kOTSDimensionP) ||
		(dimensionOfGeometryA == kOTSDimensionA && dimensionOfGeometryB == kOTSDimensionA)) {
		return 
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T'] &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationExterior] requiredDimensionSymbol:'T'] &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationExterior][kOTSLocationInterior] requiredDimensionSymbol:'T'];
	}
	if (dimensionOfGeometryA == kOTSDimensionL && dimensionOfGeometryB == kOTSDimensionL) {
		return 
			matrix[kOTSLocationInterior][kOTSLocationInterior] == 1 &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationExterior] requiredDimensionSymbol:'T'] &&
			[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationExterior][kOTSLocationInterior] requiredDimensionSymbol:'T'];
	}
	return NO;
}

- (BOOL)isCovers {
	BOOL hasPointInCommon =
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationBoundary] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationInterior] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationBoundary] requiredDimensionSymbol:'T'];
	
	return hasPointInCommon
		&&
		matrix[kOTSLocationExterior][kOTSLocationInterior] == kOTSDimensionFalse
		&&
		matrix[kOTSLocationExterior][kOTSLocationBoundary] == kOTSDimensionFalse;
}

- (BOOL)isCoveredBy {
	BOOL hasPointInCommon =
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationInterior] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationInterior][kOTSLocationBoundary] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationInterior] requiredDimensionSymbol:'T']
		||
		[OTSIntersectionMatrix matchesActualDimensionValue:matrix[kOTSLocationBoundary][kOTSLocationBoundary] requiredDimensionSymbol:'T'];
	
	return hasPointInCommon
		&&
		matrix[kOTSLocationInterior][kOTSLocationExterior] == kOTSDimensionFalse
		&&
		matrix[kOTSLocationBoundary][kOTSLocationExterior] == kOTSDimensionFalse;
}

- (OTSIntersectionMatrix *)transpose {
	int temp = matrix[1][0];
	matrix[1][0] = matrix[0][1];
	matrix[0][1] = temp;
	temp = matrix[2][0];
	matrix[2][0] = matrix[0][2];
	matrix[0][2] = temp;
	temp = matrix[2][1];
	matrix[2][1] = matrix[1][2];
	matrix[1][2] = temp;
	return self;	
}

@end
