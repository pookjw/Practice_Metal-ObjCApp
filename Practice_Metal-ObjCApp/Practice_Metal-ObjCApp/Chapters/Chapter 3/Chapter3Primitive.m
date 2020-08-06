//
//  Chapter3Primitive.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/7/20.
//

#import "Chapter3Primitive.h"

@implementation Chapter3Primitive
+(MDLMesh*)makeCube:(id<MTLDevice>)device size:(float)size {
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:device];
    MDLMesh *mesh = [[MDLMesh alloc]
                     initBoxWithExtent:simd_make_float3(size, size, size)
                     segments:simd_make_uint3(1,1,1)
                     inwardNormals:NO
                     geometryType:MDLGeometryTypeTriangles
                     allocator:allocator
                     ];
    return mesh;
}
@end
