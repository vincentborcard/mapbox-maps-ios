import Foundation
import CoreLocation
import UIKit
@_spi(Internal) import MapboxCoreMaps

public extension CameraState {
    var padding: UIEdgeInsets {
        get {
            _padding.toUIEdgeInsetsValue()
        }
        set {
            _padding = newValue.toMBXEdgeInsetsValue()
        }
    }

    var bearing: CLLocationDirection {
        get {
            _bearing
        }
        set {
            _bearing = newValue
        }
    }

    init(center: CLLocationCoordinate2D, padding: UIEdgeInsets, zoom: Double, bearing: CLLocationDirection, pitch: Double) {
        self.init(_center: center, padding: padding.toMBXEdgeInsetsValue(), zoom: zoom, bearing: bearing, pitch: pitch)
    }
}
