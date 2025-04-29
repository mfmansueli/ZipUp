////
////  User.swift
////  ZipUp
////
////  Created by Mathew Blanc on 04/03/25.
////
//
//import SwiftData
//import SwiftUI
//
//
//@Model
//class User: Identifiable, Codable {
//    var id = UUID()
//    var trips: [Trip]
//    
//    enum CodingKeys: String, CodingKey {
//        case id, trips
//    }
//    
//    init(id: UUID = UUID(), trips: [Trip]) {
//        self.id = id
//        self.trips = trips
//    }
//    
//    required init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            self.id = try container.decode(UUID.self, forKey: .id)
//            self.trips = try container.decode([Trip].self, forKey: .trips)
//        }
//
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(id, forKey: .id)
//            try container.encode(trips, forKey: .trips)
//        }
//    
//}
//
//extension User {
//    static func defaultUser() -> User {
//        return User(trips: []) // Modify as needed
//    }
//}
//
//@MainActor
//class UserManager: ObservableObject {
//    @Published var user: User?
//    let modelContext: ModelContext
//
//    init(modelContext: ModelContext) {
//        self.modelContext = modelContext
//        loadUser()
//    }
//
//    private func loadUser() {
//        let fetchDescriptor = FetchDescriptor<User>()
//        if let existingUser = try? modelContext.fetch(fetchDescriptor).first {
//            user = existingUser
//        } else {
//            let newUser = User.defaultUser()
//            modelContext.insert(newUser)
//            user = newUser
//            try? modelContext.save()
//        }
//    }
//}
