//
//  OTSGeometryTransformer.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // destructor visibility for vector
#import "OTSGeometry.h" // destructor visibility for auto_ptr
#import "OTSCoordinateSequence.h" // destructor visibility for auto_ptr

@class OTSGeometry;
@class OTSGeometryFactory;
@class OTSPoint;
@class OTSLinearRing;
@class OTSLineString;
@class OTSPolygon;
@class OTSMultiPoint;
@class OTSMultiPolygon;
@class OTSMultiLineString;
@class OTSGeometryCollection;

@interface OTSGeometryTransformer : NSObject {
	OTSGeometryFactory* factory;
	OTSGeometry *inputGeom;
	BOOL pruneEmptyGeometry;
	BOOL preserveGeometryCollectionType;
	BOOL preserveCollections;
	BOOL preserveType;
}

@property (nonatomic, retain) OTSGeometryFactory* factory;
@property (nonatomic, retain) OTSGeometry *inputGeom;
@property (nonatomic, assign) BOOL pruneEmptyGeometry;
@property (nonatomic, assign) BOOL preserveGeometryCollectionType;
@property (nonatomic, assign) BOOL preserveCollections;
@property (nonatomic, assign) BOOL preserveType;

- (OTSGeometry *)transform:(OTSGeometry *)nInputGeom;
- (OTSCoordinateSequence *)transformCoordinates:(OTSCoordinateSequence *)coords parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformPoint:(OTSPoint *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformMultiPoint:(OTSMultiPoint *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformLinearRing:(OTSLinearRing *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformLineString:(OTSLineString *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformMultiLineString:(OTSMultiLineString *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformPolygon:(OTSPolygon *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformMultiPolygon:(OTSMultiPolygon *)geom parent:(OTSGeometry *)parent;
- (OTSGeometry *)transformGeometryCollection:(OTSGeometryCollection *)geom parent:(OTSGeometry *)parent;

@end
