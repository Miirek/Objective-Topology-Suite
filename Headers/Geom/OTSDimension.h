//
//  OTSDimension.h
//

#import <Foundation/Foundation.h>

typedef enum {
	/// Dimension value for any dimension (= {FALSE, TRUE}).
	kOTSDimensionDontCare=-3,
	
	/// Dimension value of non-empty geometries (= {P, L, A}).
	kOTSDimensionTrue=-2,
	
	/// Dimension value of the empty geometry (-1).
	kOTSDimensionFalse=-1,
	
	/// Dimension value of a point (0).
	kOTSDimensionP=0,
	
	/// Dimension value of a curve (1).
	kOTSDimensionL=1,
	
	/// Dimension value of a surface (2).
	kOTSDimensionA=2
} OTSDimensionType;

@interface OTSDimension : NSObject {
}

+ (char)toDimensionSymbol:(int)dimensionValue;
+ (int)toDimensionValue:(char)dimensionSymbol;

@end
