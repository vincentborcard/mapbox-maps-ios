import Foundation
import CoreLocation

extension CameraBoundsOptions {

    /// Initialize a `CameraBoundsOptions` from the immutable `CameraBounds` type
    /// - Parameter cameraBounds: `CameraBounds`
    public init(cameraBounds: CameraBounds) {
        self.init(
            bounds: cameraBounds.bounds,
            maxZoom: cameraBounds.maxZoom,
            minZoom: cameraBounds.minZoom,
            maxPitch: cameraBounds.maxPitch,
            minPitch: cameraBounds.minPitch)
    }
}
