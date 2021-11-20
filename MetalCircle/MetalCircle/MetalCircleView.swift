//
//  MetalCircleView.swift
//  MetalCircle
//
//  Created by João Gabriel Pozzobon dos Santos on 17/11/21.
//

import Cocoa
import MetalKit
import simd

class MetalCircleView: NSView {
    
    //MARK: METAL VARS
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalCommandQueue : MTLCommandQueue!
    private var metalRenderPipelineState : MTLRenderPipelineState!

    //MARK: VERTEX VARS
    private var circleVertices = [VertexOut]()
    private var vertexBuffer : MTLBuffer!
    
    //MARK: INIT
    public required init() {
        super.init(frame: .zero)
        setupView()
        setupMetal()
        createVertexPoints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK: SETUP
    fileprivate func setupView(){
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupMetal(){
        //view
        metalView = MTKView()
        addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        
        metalDevice = MTLCreateSystemDefaultDevice()
        metalView.device = metalDevice
        
        //creating the command queue
        metalCommandQueue = metalDevice.makeCommandQueue()!
        
        createVertexPoints()
        createPipelineState()
        
        vertexBuffer = metalDevice.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<VertexOut>.stride, options: [])!
        
        metalView.delegate = self
        metalView.needsDisplay = true
    }
    
    fileprivate func createPipelineState(){
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        //finds the metal file from the main bundle
        let library = metalDevice.makeDefaultLibrary()!

        //give the names of the function to the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")

        //set the pixel format to match the Metal View's pixel format
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        //make the pipelinestate using the gpu interface and the pipelineDescriptor
        metalRenderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    fileprivate func createVertexPoints() {
        func rads(forDegree d: Float)->Float32{
            return (Float.pi*d)/180
        }
        
        let origin = simd_float4(0, 0, 0, 1.0)
        
        let scale: Float = 2
        
        for i in 0...Int(360*scale) {
            let position: simd_float4 = [cos(rads(forDegree: Float(Float(i)/scale))), sin(rads(forDegree: Float(Float(i)/scale))), 0, 1]
            let color: simd_float4 = .init(hue: Float(i)/360.0/scale, saturation: 1, brightness: 1)
            circleVertices.append(VertexOut(position: position, color: color))
            if (i+1)%2 == 0 {
                circleVertices.append(VertexOut(position: origin, color: [1, 1, 1, 1]))
            }
        }
    }
}

extension MetalCircleView : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //not worried about this
    }
    
    func draw(in view: MTKView) {
        //this is where we do all our drawing
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {return}
        
        guard let renderDescriptor = view.currentRenderPassDescriptor else {return}
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}
        renderEncoder.setRenderPipelineState(metalRenderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: circleVertices.count/2)
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

struct VertexOut {
    let position: vector_float4
    let color: vector_float4
}

extension simd_float4 {
    // RGB color from HSV color (all parameters in range [0, 1])
    init(hue: Float, saturation: Float, brightness: Float) {
        let c = brightness * saturation
        let x = c * (1 - fabsf(fmodf(hue * 6, 2) - 1))
        let m = brightness - saturation
        
        var r: Float = 0
        var g: Float = 0
        var b: Float = 0
        switch hue {
        case _ where hue < 0.16667:
            r = c; g = x; b = 0
        case _ where hue < 0.33333:
            r = x; g = c; b = 0
        case _ where hue < 0.5:
            r = 0; g = c; b = x
        case _ where hue < 0.66667:
            r = 0; g = x; b = c
        case _ where hue < 0.83333:
            r = x; g = 0; b = c
        case _ where hue <= 1.0:
            r = c; g = 0; b = x
        default:
            break
        }
        
        r += m; g += m; b += m
        self.init(x: r, y: g, z: b, w: 1)
    }
}
