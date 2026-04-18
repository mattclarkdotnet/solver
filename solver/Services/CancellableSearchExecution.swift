import Foundation

enum CancellableSearchExecution {
    static let cancellationCheckStride = 128

    static func run<T: Sendable>(
        _ operation: @escaping @Sendable () throws -> T
    ) async throws -> T {
        let task = Task.detached(priority: .userInitiated) {
            try operation()
        }

        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }

    static func checkCancellation(afterProcessedCount count: Int) throws {
        if count.isMultiple(of: cancellationCheckStride) {
            try Task.checkCancellation()
        }
    }
}
