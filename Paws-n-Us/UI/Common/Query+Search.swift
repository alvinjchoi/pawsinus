//
//  Query+Search.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 8/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI
#if canImport(SwiftData)
import SwiftData
#endif

#if canImport(SwiftData)
@available(iOS 17.0, *)
extension View {
    /**
     Allows for recreating the @Query each time a searchText changes
     */
    func query<T: PersistentModel>(
        searchText: String,
        results: Binding<[T]>,
        _ builder: @escaping (String) -> Query<T, [T]>
    ) -> some View {
        background {
            QueryViewContainer(searchText: searchText, builder: builder) { _, values in
                results.wrappedValue = values
            }.equatable()
        }
    }
}

/**
 This view serves as a "shield" over QueryView to avoid dual query
 */
@available(iOS 17.0, *)
private struct QueryViewContainer<T: PersistentModel>: View, Equatable {

    let searchText: String
    let builder: (String) -> Query<T, [T]>
    let results: ([T], [T]) -> Void

    var body: some View {
        QueryView(query: builder(searchText), results: results)
    }

    nonisolated static func == (lhs: QueryViewContainer<T>, rhs: QueryViewContainer<T>) -> Bool {
        return lhs.searchText == rhs.searchText
    }
}

@available(iOS 17.0, *)
private struct QueryView<T: PersistentModel>: View {

    @Query var query: [T]
    let results: ([T], [T]) -> Void

    init(query: Query<T, [T]>, results: @escaping ([T], [T]) -> Void) {
        _query = query
        self.results = results
    }

    var body: some View {
        Rectangle()
            .hidden()
            .onChange(of: query) { _, newValue in
                results([], newValue)
            }
            .onAppear {
                results([], query)
            }
    }
}
#endif
