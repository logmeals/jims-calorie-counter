//
//  CircularProgressView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct CircularProgressView: View {
    var percentage: Double
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(percentage / 100.0, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: percentage)
            
            Text("\(Int(percentage))%")
                .font(.caption2)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct CircularProgressView_Preview: PreviewProvider {
    static var previews: some View {
        CircularProgressView(percentage: 40.0, color: Color(UIColor.systemIndigo))
            .frame(width: 40, height: 40) // Adjust the size of the circular progress
    }
}
