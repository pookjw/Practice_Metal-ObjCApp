//
//  Chapter3Primitive.h
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/7/20.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Chapter3Primitive : NSObject
+(MDLMesh*)makeCube:(id<MTLDevice>)device size:(float)size;
@end

NS_ASSUME_NONNULL_END
