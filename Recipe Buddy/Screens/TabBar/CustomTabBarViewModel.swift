// TabModels.swift
import SwiftUI

struct TabItem {
    let icon: String
}

enum ContentTab: Int, CaseIterable {
    case home = 0
    case recipe = 1
    case shoppingList = 2
    case settings = 3
}
