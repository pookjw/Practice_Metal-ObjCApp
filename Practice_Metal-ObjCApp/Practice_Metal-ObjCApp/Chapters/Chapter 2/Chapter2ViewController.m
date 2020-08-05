//
//  Chapter2ViewController.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/4/20.
//

#import "Chapter2ViewController.h"
#import <MetalKit/MetalKit.h>

@interface Chapter2ViewController ()
@property UIView *presentationView;
@end

@implementation Chapter2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self runPractice];
    [self setupUI];
}

-(void)setupUI {
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"Chapter 1";
    
    [self.view addSubview:self.presentationView];
    self.presentationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.presentationView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.presentationView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.presentationView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.presentationView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    self.presentationView.backgroundColor = UIColor.systemBackgroundColor;
}

- (void)runPractice {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    MTKView *view = [[MTKView alloc] initWithFrame:frame device:device];
    view.clearColor = MTLClearColorMake(1, 1, 0.8, 1);
    
    // MARK: The Model
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:device];
    NSURL *assetURL = [NSBundle.mainBundle URLForResource:@"train" withExtension:@"obj"];
    MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.layouts[0].stride = sizeof(simd_float3);
    MDLVertexDescriptor *meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor);
    meshDescriptor.attributes[0].name = MDLVertexAttributePosition;
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:assetURL vertexDescriptor:meshDescriptor bufferAllocator:allocator];
    MDLMesh *mdlMesh = [[asset childObjectsOfClass:[MDLMesh class]] firstObject];
    MTKMesh *mesh = [[MTKMesh alloc] initWithMesh:mdlMesh device:device error:nil];
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    
    // MARK: Shader
    NSString *shader = [NSString stringWithFormat:@"\n"
                        "#include <metal_stdlib>\n"
                        "using namespace metal;\n"
                        "struct VertexIn {\n"
                        "    float4 position [[ attribute(0) ]];\n"
                        "};\n"

                        // 꼭짓점
                        "vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {\n"
                            "return vertex_in.position;\n"
                        "}\n"

                        // the fragment function is where you specify the pixel color.
                        "fragment float4 fragment_main() {\n"
                            "return float4(1, 0, 0, 1);\n"
                        "}\n"
                        "\n"];
    id<MTLLibrary> library = [device newLibraryWithSource:shader options:nil error:nil];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    
    // MARK: Pipeline
    // Telling to GPU... using descriptor
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor);
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:nil];
    
    // MARK: Rendering
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = [view currentRenderPassDescriptor];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [renderEncoder setRenderPipelineState:pipelineState];
    [renderEncoder setVertexBuffer:mesh.vertexBuffers[0].buffer offset:0 atIndex:0];
    
    // MARK: Submeshes
    [renderEncoder setTriangleFillMode:MTLTriangleFillModeLines];
    
    for (MTKSubmesh *submesh in mesh.submeshes) {
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:submesh.indexCount indexType:submesh.indexType indexBuffer:submesh.indexBuffer.buffer indexBufferOffset:submesh.indexBuffer.offset];
    }
    
    [renderEncoder endEncoding];
    id<CAMetalDrawable> drawable = view.currentDrawable;
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    self.presentationView = view;
}

@end
