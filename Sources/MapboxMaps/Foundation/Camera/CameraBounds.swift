import Foundation
import CoreLocation

extension CameraBounds {
    internal static var `default`: CameraBounds {
        let defaultSouthWest = CLLocationCoordinate2D(latitude: -90, longitude: -180)
        let defaultNorthEast = CLLocationCoordinate2D(latitude: 90, longitude: 180)

        return CameraBounds(bounds: CoordinateBounds(southwest: defaultSouthWest,
                                                     northeast: defaultNorthEast,
                                                     infiniteBounds: true),
                            maxZoom: 22,
                            minZoom: 0,
                            maxPitch: 85,
                            minPitch: 0)
    }
}
