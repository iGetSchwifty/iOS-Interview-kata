//
//  ContentView.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    @State var currentState: ContentViewModel.State = ContentViewModel.State.initalize
    
    var body: some View {
        VStack {
            TopNavView { action in
                viewModel.handle(newState: action)
            }
            
            switch currentState {
            case .load:
                LoadingView()
            case .results(let events):
                ResultList(events: events)
            default:
                VStack {
                    Text("Tap Load.")
                    Spacer()
                }
            }
        }
        .onReceive(viewModel.$currentState) { state in
            self.currentState = state
        }
    }
}
