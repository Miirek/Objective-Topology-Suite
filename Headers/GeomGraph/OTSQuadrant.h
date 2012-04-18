//
//  OTSQuadrant.h
//

#import <Foundation/Foundation.h>

#define kOTSQuadrantNE 0
#define kOTSQuadrantNW 1
#define kOTSQuadrantSW 2
#define kOTSQuadrantSE 3


@interface OTSQuadrant : NSObject {

}

/**
 * Returns the quadrant of a directed line segment
 * (specified as x and y displacements, which cannot both be 0).
 *
 * @throws IllegalArgumentException if the displacements are both 0
 */
+ (int)quadrant:(double)dx dy:(double)dy;

/**
 * Returns the quadrant of a directed line segment from p0 to p1.
 *
 * @throws IllegalArgumentException if the points are equal
 */
+ (int)quadrant:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1;

/**
 * Returns true if the quadrants are 1 and 3, or 2 and 4
 */
+ (BOOL)isOpposite:(int)quad1 quad2:(int)quad2;

/* 
 * Returns the right-hand quadrant of the halfplane defined by
 * the two quadrants,
 * or -1 if the quadrants are opposite, or the quadrant if they
 * are identical.
 */
+ (int)commonHalfPlane:(int)quad1 quad2:(int)quad2;

/**
 * Returns whether the given quadrant lies within the given halfplane
 * (specified by its right-hand quadrant).
 */
+ (BOOL)isInHalfPlane:(int)quad halfPlane:(int)halfPlane;

/**
 * Returns true if the given quadrant is 0 or 1.
 */
+ (BOOL)isNorthern:(int)quad;


@end
