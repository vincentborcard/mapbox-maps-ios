import XCTest
@testable import MapboxMaps

internal class LocationManagerTests: XCTestCase {

    var locationSupportableMapView: LocationSupportableMapViewMock!
    var locationSupportableStyle: MockLocationStyleDelegate!

    override func setUp() {
        locationSupportableMapView = LocationSupportableMapViewMock()
        locationSupportableStyle = MockLocationStyleDelegate()
        super.setUp()
    }

    override func tearDown() {
        locationSupportableMapView = nil
        locationSupportableStyle = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        let locationOptions = LocationOptions()

        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)

        XCTAssertEqual(locationManager.options, locationOptions)
        XCTAssertTrue(locationManager.locationSupportableMapView === locationSupportableMapView)
        XCTAssertNil(locationManager.delegate)
    }

    func testAddLocationConsumer() {
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)
        let locationConsumer = LocationConsumerMock()

        locationManager.addLocationConsumer(newConsumer: locationConsumer)

        XCTAssertTrue(locationManager.consumers.contains(locationConsumer))
    }

    func testUpdateLocationOptionsWithModifiedPuckType() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D(Puck2DConfiguration(scale: .constant(2.0)))
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D()
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = nil
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertNil(locationManager.locationPuckManager)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNonNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = nil
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D()
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testUpdateLocationOptionsWithCoursePuckBearingSource() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D()
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView,
                                              style: locationSupportableStyle)

        locationManager.options = locationOptions
        XCTAssertEqual(locationManager.locationPuckManager?.puckBearingSource, .heading)

        locationOptions.puckBearingSource = .course
        locationManager.options = locationOptions

        XCTAssertEqual(locationManager.options, locationOptions)
        XCTAssertEqual(locationManager.locationPuckManager?.puckBearingSource, .course)
    }
}
