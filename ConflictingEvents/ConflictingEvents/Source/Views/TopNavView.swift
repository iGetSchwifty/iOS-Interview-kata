//
//  TopNavView.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/13/20.
//

import SwiftUI

struct TopNavView: View {
    var actionCallback: ((ContentViewModel.State) -> Void)?
    
    var body: some View {
        ZStack {
            self.buttonLayer()
            
            self.iconLayer()
        }
        .padding([.leading, .trailing], 10)
    }
    
    private func iconLayer() -> some View {
        HStack {
            Spacer()
            
            Image("spaceman")
                .resizable()
                .frame(width: 40, height: 40)
            
            Spacer()
        }
    }
    
    private func buttonLayer() -> some View {
        HStack {
            Button("Delete") {
                actionCallback?(.remove)
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(10)
            
            Spacer()
            
            Button("Load") {
                actionCallback?(.load)
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(10)
        }
    }
}
