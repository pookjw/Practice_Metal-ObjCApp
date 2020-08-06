//
//  Chapter3Renderer.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/7/20.
//

#import "Chapter3Renderer.h"
#import "Chapter3Primitive.h"

@implementation Chapter3Renderer
+(instancetype)initWithMTKView:(MTKView *)metalView {
    metalView.device = Chapter3Renderer.device;
    Chapter3Renderer *renderer = [[Chapter3Renderer alloc] init];
    
    MDLMesh *mdlMesh = [Chapter3Primitive makeCube:Chapter3Renderer.device size:1];
    
    NSError __autoreleasing * _Nullable error1 = nil;
    renderer.mesh = [[MTKMesh alloc] initWithMesh:mdlMesh device:Chapter3Renderer.device error:&error1];
    if (error1 != nil) NSLog(@"error1: %@", error1.localizedDescription);
    renderer.vertexBuffer = renderer.mesh.vertexBuffers[0].buffer;
    
    id<MTLLibrary> library = [Chapter3Renderer.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor);
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat;
    
    NSError __autoreleasing * _Nullable error2 = nil;
    renderer.pipelineState = [Chapter3Renderer.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error2];
    if (error2 != nil) NSLog(@"error1: %@", error2.localizedDescription);
    
    metalView.clearColor = MTLClearColorMake(1.0, 1.0, 0.8, 1.0);
    metalView.delegate = renderer;
    return renderer;
}

+(id<MTLDevice>)device {
    static id<MTLDevice> device = nil;
    if (device == nil) {
        device = MTLCreateSystemDefaultDevice();
    }
    return device;
}

+(id<MTLCommandQueue>)commandQueue {
    static id<MTLCommandQueue> commandQueue = nil;
    if (commandQueue == nil) {
        commandQueue = [Chapter3Renderer.device newCommandQueue];
    }
    return commandQueue;
}

+(void)setDevice:(id<MTLDevice>)device {
    Chapter3Renderer.device = device;
}
+(void)setCommandQueue:(id<MTLCommandQueue>)commandQueue {
    Chapter3Renderer.commandQueue = commandQueue;
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    id<MTLCommandBuffer> commandBuffer = [Chapter3Renderer.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    
    self.timer += 0.05;
    float currentTime = sin(self.timer);
    [renderEncoder setVertexBytes:&currentTime length:sizeof(float) atIndex:1];
    
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    
    for (MTKSubmesh *submesh in self.mesh.submeshes) {
        [renderEncoder
         drawIndexedPrimitives:MTLPrimitiveTypeTriangle
         indexCount:submesh.indexCount
         indexType:submesh.indexType
         indexBuffer:submesh.indexBuffer.buffer
         indexBufferOffset:submesh.indexBuffer.offset];
    }
    
    [renderEncoder endEncoding];
    id<CAMetalDrawable> drawable = view.currentDrawable;
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
