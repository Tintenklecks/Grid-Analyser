//
//  View+Extensions.swift
//  Grid Analyzer
//
//  Common view extensions
//

import SwiftUI

extension View {
    /// Applies adaptive padding based on the current device
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        self.modifier(AdaptivePaddingModifier(edges: edges))
    }
    
    /// Makes the view's frame adaptive to the current device
    func adaptiveFrame(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> some View {
        self.modifier(AdaptiveFrameModifier(maxWidth: maxWidth, maxHeight: maxHeight))
    }
}

struct AdaptivePaddingModifier: ViewModifier {
    let edges: Edge.Set
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        content.padding(edges, horizontalSizeClass == .regular ? 20 : 16)
    }
}

struct AdaptiveFrameModifier: ViewModifier {
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: maxWidth ?? 800)
                .frame(maxHeight: maxHeight)
        } else {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxHeight: maxHeight)
        }
    }
} 