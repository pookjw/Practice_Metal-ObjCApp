//
//  Chapter3Renderer.h
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/7/20.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Chapter3Renderer : NSObject <MTKViewDelegate>
+(instancetype)initWithMTKView:(MTKView *)metalView;
+(id<MTLDevice>)device;
+(id<MTLCommandQueue>)commandQueue;
+(void)setDevice:(id<MTLDevice>)device;
+(void)setCommandQueue:(id<MTLCommandQueue>)commandQueue;

@property MTKMesh *mesh;
@property id<MTLBuffer> vertexBuffer;
@property id<MTLRenderPipelineState> pipelineState;
@property float timer;
@end

NS_ASSUME_NONNULL_END
