//
//  Chapter1ViewController.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/2/20.
//

#import "Chapter1ViewController.h"
#import <MetalKit/MetalKit.h>

@interface Chapter1ViewController ()
@property UIView *presentationView;
@end

@implementation Chapter1ViewController

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
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    MTKView *view = [[MTKView alloc] initWithFrame:frame device:device];
    view.clearColor = MTLClearColorMake(1, 1, 0.8, 1);
    
    // MARK: The Model
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:device];
    MDLMesh *mdlMesh = [[MDLMesh alloc]
                        initSphereWithExtent:simd_make_float3(0.2,0.75,0.2)
                        segments:simd_make_uint2(100, 100)
                        inwardNormals:NO
                        geometryType:MDLGeometryTypeTriangles
                        allocator:allocator
                        ];
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
                            "return float4(0, 0.4, 0.21, 1);\n"
                        "}\n"
                        "\n"];
    id<MTLLibrary> library = [device newLibraryWithSource:shader options:nil error:nil];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    
    // MARK: Pipeline
    // Telling to GPU... using descriptor.
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
    MTKSubmesh *submesh = mesh.submeshes.firstObject;
    
    [renderEncoder
     drawIndexedPrimitives:MTLPrimitiveTypeTriangle
     indexCount:submesh.indexCount
     indexType:submesh.indexType
     indexBuffer:submesh.indexBuffer.buffer
     indexBufferOffset:0
     ];

    [renderEncoder endEncoding];
    id<CAMetalDrawable> drawable = view.currentDrawable;
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    self.presentationView = view;
}

@end
