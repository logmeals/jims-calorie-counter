//
//  Miscellaneous.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI

@ViewBuilder
func settingsSection<Content: View>(header: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(header)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.bottom, 5)
        
        VStack(spacing: 0) {
            content()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color(UIColor.systemGray4), radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor.systemGray3), lineWidth: 1)
        )
    }
    .padding(.bottom, 10)
}

@ViewBuilder
func settingsRow(title: String, value: String? = nil, imageName: String? = nil, lastRow: Bool?, gray: Bool?, danger: Bool?, onTap: ((String) -> Void)?, grayValue: Bool?) -> some View {
    Button(action: { if onTap != nil {
        onTap?(title)
    }}) {
        if((value ?? "").count < 23) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(danger == true ? Color.red : gray == true ? Color(UIColor.systemGray) : Color.black)
                    .frame(minWidth: 100, alignment: .leading)
                Spacer()
                if let value = value {
                    Text(value)
                        .foregroundColor(grayValue == false ? .blue : Color(UIColor.systemGray2))
                }
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(danger == true ? Color.red.opacity(0.12) : Color.white)
            .contentShape(Rectangle())
        } else {
            VStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(danger == true ? Color.red : gray == true ? Color(UIColor.systemGray) : Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                if let value = value {
                    Text(value)
                        .foregroundColor(grayValue == false ? .blue : Color(UIColor.systemGray2))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .padding(.top, 1)
                }
            }
            .padding()
            .background(danger == true ? Color.red.opacity(0.12) : Color.white)
            .contentShape(Rectangle())
        }
    }
    .overlay(
        Rectangle()
            .frame(height: lastRow != true ? 1 : 0)
            .foregroundColor(Color(UIColor.systemGray3)),
        alignment: .bottom
    )
    .buttonStyle(PlainButtonStyle())
}

// Empty function to handle taps
func handleTap(option: String) {
    print("Tapped on \(option)")
    // Add your functionality here
}
