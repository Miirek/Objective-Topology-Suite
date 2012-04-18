//
//  OTSDimension.m
//

#import "OTSDimension.h"


@implementation OTSDimension

+ (char)toDimensionSymbol:(int)dimensionValue {
	switch (dimensionValue) {
		case kOTSDimensionFalse:
			return 'F';
		case kOTSDimensionTrue:
			return 'T';
		case kOTSDimensionDontCare:
			return '*';
		case kOTSDimensionP:
			return '0';
		case kOTSDimensionL:
			return '1';
		case kOTSDimensionA:
			return '2';
	}
	NSException *e = [NSException exceptionWithName:@"IllegalArgumentException" 
											 reason:[NSString stringWithFormat:@"Unknown dimension value: %d", dimensionValue] 
										   userInfo:nil];
	@throw e;
}

+ (int)toDimensionValue:(char)dimensionSymbol {
	switch (dimensionSymbol) {
		case 'F':
		case 'f':
			return kOTSDimensionFalse;
		case 'T':
		case 't':
			return kOTSDimensionTrue;
		case '*':
			return kOTSDimensionDontCare;
		case '0':
			return kOTSDimensionP;
		case '1':
			return kOTSDimensionL;
		case '2':
			return kOTSDimensionA;
	}
	NSException *e = [NSException exceptionWithName:@"IllegalArgumentException" 
											 reason:[NSString stringWithFormat:@"Unknown dimension symbol: %c", dimensionSymbol] 
										   userInfo:nil];
	@throw e;
}

@end
