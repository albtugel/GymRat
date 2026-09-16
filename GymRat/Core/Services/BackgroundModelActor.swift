import Foundation
import SwiftData

/// Creates a `ModelActor` away from the main thread and hands it out on demand.
///
/// SwiftData ties a model actor's executor to the thread that created it, so a `@ModelActor` built in
/// the main-actor composition root would run all of its "background" work on the main thread. This
/// plain actor runs on the cooperative pool, so building the model actor inside it puts its executor
/// on a background thread. Creation is deferred to first use because `Dependencies` is synchronous.
actor BackgroundModelActor<Model: ModelActor> {
    private let make: @Sendable () -> Model
    private var instance: Model?

    init(_ make: @escaping @Sendable () -> Model) {
        self.make = make
    }

    func get() -> Model {
        if let instance {
            return instance
        }
        let created = make()
        instance = created
        return created
    }
}
