//
//  OTSGeometryComponentFilter.h
//
// Copyright (C) 2010 ObjGeo.org
//
// This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
//

#import <Foundation/Foundation.h>

@class OTSGeometry;

/**	@brief  
 * Geometry classes support the concept of applying a Geometry
 * filter to the Geometry.
 *
 * In the case of GeometryCollection
 * subclasses, the filter is applied to every element Geometry.
 * A Geometry filter can either record information about the Geometry
 * or change the Geometry in some way.
 * Geometry filters implement the interface GeometryFilter.
 * (GeometryFilter is an example of the Gang-of-Four Visitor pattern). 
 **/
@protocol OTSGeometryFilter

/**	@brief Performs an operation with or on <code>geom</code>.
 *
 *	@param geom  a <code>Geometry</code> to which the filter
 *         is applied.
 **/
- (void)filterReadWrite:(OTSGeometry *)geom;
- (void)filterReadOnly:(OTSGeometry * const)geom;

@end
