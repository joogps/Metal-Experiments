//
//  ContentView.swift
//  MetalCircle
//
//  Created by João Gabriel Pozzobon dos Santos on 17/11/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalCircleViewRepresentable()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MetalCircleViewRepresentable: NSViewRepresentable {
    typealias NSViewType = MetalCircleView
    
    func makeNSView(context: Context) -> MetalCircleView {
        return MetalCircleView()
    }
    
    func updateNSView(_ view: MetalCircleView, context: Context) {
        
    }
}
