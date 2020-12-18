//
//  ResultList.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/13/20.
//

import SwiftUI

struct ResultList: View {
    var events: [[UIEventItem]]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach((0 ..< events.count)) { index in
                    Text("\(DateFormatter.sortIndexFormatter.string(from: Date(timeIntervalSince1970: Double(events[index].first?.sortIndex ?? 0))))")
                        .padding([.top, .bottom], 5)
                        .padding([.leading, .trailing], 40)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(42)
                    
                    ForEach(events[index], id: \.eventId) { event in
                        LazyVStack {
                            Text("\(event.title ?? "")")
                                .padding(5)

                            LazyHStack {
                                Text("Start:")
                                Text("\(DateFormatter.dateFormatter.string(from: event.start ?? Date()))")
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(15)

                            LazyHStack {
                                Text("End:  ")
                                Text("\(DateFormatter.dateFormatter.string(from: event.end ?? Date()))")
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(15)

                            Divider()
                                .padding(.top, 20)
                        }
                        .background(event.hasConflict ? Color.yellow : Color.clear)
                        .padding(10)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
