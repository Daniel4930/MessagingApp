//
//  FrameView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/1/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct FrameView: View {
    @StateObject var cameraFrameHandler = FrameHandler()
    
    private let label = Text("frame")
    private let minZoomValue = 1.0
    private let maxZoomValue = 5.0
    @State private var baseZoom: CGFloat = 1.5
    @State private var currentZoom: CGFloat = 1.5
    @State private var enableFlash = false
    @State private var showFlashOptions = false
    
    var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                var newZoom = baseZoom * value.magnification
                newZoom = min(max(newZoom, minZoomValue), maxZoomValue)
                currentZoom = newZoom
            }
            .onEnded { value in
                baseZoom = currentZoom
            }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "bolt.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    showFlashOptions.toggle()
                }
            
            Spacer()
            
            if showFlashOptions {
                Text("Auto")
                Spacer()
                Text("On")
                Spacer()
                Text("Off")
                Spacer()
            }
        }
        .padding(.horizontal)
        
        if let image = cameraFrameHandler.frame {
            Image(image, scale: 1.0, orientation: .up, label: label)
                .resizable()
                .scaledToFit()
                .padding(.vertical)
                .gesture(magnification)
                .onChange(of: currentZoom) { oldValue, newValue in
                    guard let device = cameraFrameHandler.device else { return }
                    do {
                        try device.lockForConfiguration()
                        
                        device.videoZoomFactor = newValue
                        
                        device.unlockForConfiguration()
                    } catch {
                        print("Error locking device for configuration: \(error)")
                    }
                }
                .overlay(alignment: .bottom) {
                    let zoomValue = round(currentZoom * 10) / 10 - 0.5
                    let lower = zoomValue < 1.0 ? zoomValue : 0.5
                    let upper = zoomValue >= 1.0 ? zoomValue : 1.0
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: (zoomValue >= 0.5 && zoomValue < 1.0) ? 40 : 30, height: (zoomValue >= 0.5 && zoomValue < 1.0) ? 40 : 30)

                            Text(String(format: "%.1fx", lower))
                                .foregroundColor((zoomValue >= 0.5 && zoomValue < 1.0) ? .yellow : .white)
                                .font((zoomValue >= 0.5 && zoomValue < 1.0) ? .caption : .caption2)
                        }
                        .onTapGesture {
                            currentZoom = 1.0
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: zoomValue >= 1.0 ? 40 : 30, height: zoomValue >= 1.0 ? 40 : 30)

                            Text(zoomValue == 1.0 ? "1x" : String(format: "%.1fx", upper))
                                .foregroundColor(zoomValue >= 1.0 ? .yellow : .white)
                                .font(zoomValue >= 1.0 ? .caption : .caption2)
                        }
                        .onTapGesture {
                            currentZoom = 1.5
                        }
                    }
                    .padding(6)
                    .background() {
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 100, height: 50)
                    }
                    .padding()
                    .padding(.vertical)
                }
        } else {
            Color.black
        }
    }
}
