//
//  OTSCoordinate.h
//
// Copyright (C) 2010 ObjGeo.org
//
// This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
//

#import <Foundation/Foundation.h>

@interface OTSCoordinate : NSObject <NSCopying> {
	double x;
	double y;
	double z;
}

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;

/// @name Initialization
/// @{
- (id)initWithX:(double)_x Y:(double)_y;
- (id)initWithX:(double)_x Y:(double)_y Z:(double)_z;
- (id)initWithCoordinate:(OTSCoordinate * const)other;
///	@}

/// @name Autorelease instance creation
/// @{
+ (id)coordinateWithX:(double)_x Y:(double)_y;
+ (id)coordinateWithCoordinate:(OTSCoordinate * const)other;
- (OTSCoordinate *)clone;
///	@}

/// @name Comparisons
/// @{
- (BOOL)isEqual2D:(OTSCoordinate *)other;
- (int)compareTo:(OTSCoordinate *)other;
- (NSComparisonResult)compareForNSComparisonResult:(OTSCoordinate *)other;
+ (BOOL)coordinate:(OTSCoordinate *)c1 lessThan:(OTSCoordinate *)c2;
///	@}

- (double)distance:(OTSCoordinate *)p;
+ (OTSCoordinate * const)nullCoordinate;
- (BOOL)isNull;

@end
