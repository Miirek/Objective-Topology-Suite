//
//  OTSOrientedCoordinateArray.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinateSequence;

@interface OTSOrientedCoordinateArray : NSObject <NSCopying> {
	/// Externally owned
	OTSCoordinateSequence *pts;	
	BOOL orientation;	
}

@property (nonatomic, retain) OTSCoordinateSequence *pts;
@property (nonatomic, assign) BOOL orientation;

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)pts;
- (int)compareTo:(OTSOrientedCoordinateArray *)oca;
+ (int)compareOrientedPts1:(OTSCoordinateSequence *)pts1 
			  orientation1:(BOOL)orientation1 
					  pts2:(OTSCoordinateSequence *)pts2 
			  orientation2:(BOOL)orientation2;
+ (BOOL)orientation:(OTSCoordinateSequence *)pts;

@end
