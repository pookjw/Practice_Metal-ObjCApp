import PlaygroundSupport
import MetalKit

// MARK: View

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1) // RGBA in Metal...

// MARK: The model
/*
 Model I/O is a framework that integrates with Metal and SceneKit.
 */

let allocator = MTKMeshBufferAllocator(device: device)
let mdlMesh = MDLMesh(
    sphereWithExtent: [0.75, 0.75, 0.75], // 구의 규모
    segments: [100, 100],
    inwardNormals: false,
    geometryType: .triangles, // MDLGeometryType
    allocator: allocator
)
let mesh = try MTKMesh(mesh: mdlMesh, device: device) // convert Model I/O mesh to a MetalKit mesh

guard let commandQueue: MTLCommandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

// MARK: Shader

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

// 꼭짓점
vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
    return vertex_in.position;
}

// the fragment function is where you specify the pixel color.
fragment float4 fragment_main() {
    return float4(1, 0, 0, 1);
}
"""

let library: MTLLibrary = try device.makeLibrary(source: shader, options: nil)
let vertexFunction: MTLFunction? = library.makeFunction(name: "vertex_main")
let fragmentFunction: MTLFunction? = library.makeFunction(name: "fragment_main")

// MARK: Pipeline
/*
 Telling to GPU... using descriptor.
 */
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // MTLPixelFormat
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor) // MDLVertexDescriptor

let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

// MARK: Rendering
guard let commandBuffer = commandQueue.makeCommandBuffer(), // Stores all the commands that you'll ask the GPU to run.
    let renderPassDescriptor = view.currentRenderPassDescriptor, // Holds texture attachments (data for the render destinations...)
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) // Holds all the information necessary to send to the GPU so that it can draw the vertices. eg: Set pipeline state, Draw ground, Dran train...
else {
    fatalError()
}

renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

// MARK: Submeshes
/*
 When the artist creates a 3D model, they design it with different meterial groups. These translate to submeshes.
 */

print(mesh.submeshes.count) // 1
guard let submesh = mesh.submeshes.first else {
    fatalError()
}

renderEncoder.drawIndexedPrimitives(
    type: .triangle,
    indexCount: submesh.indexCount,
    indexType: submesh.indexType,
    indexBuffer: submesh.indexBuffer.buffer,
    indexBufferOffset: 0
)

renderEncoder.endEncoding() // Without this, you can see: -[_MTLCommandEncoder dealloc]:131: failed assertion `Command encoder released without endEncoding'
guard let drawable = view.currentDrawable else {
    fatalError()
}
commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view
