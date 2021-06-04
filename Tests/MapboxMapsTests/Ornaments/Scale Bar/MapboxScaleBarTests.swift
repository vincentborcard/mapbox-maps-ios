import XCTest
@testable import MapboxMaps

class MapboxScaleBarTests: MapViewIntegrationTests {
    func testScaleBarsCountMetric() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The MapView should include a scale bar view as a subview")
        scaleBar.isHidden = false
        let metricTable = MapboxScaleBarOrnamentView.Constants.metricTable
        for row in metricTable {
            scaleBar.metersPerPoint = row.distance + 0.5
            print("number of bars: \(row.numberOfBars), count: \(scaleBar.bars.count)")
            XCTAssertEqual(Int(row.numberOfBars), scaleBar.bars.count)
        }
    }
    
    func testScaleBarsCountImperial() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The MapView should include a scale bar view as a subview")
        scaleBar.isHidden = false
        
        let imperialTable = MapboxScaleBarOrnamentView.Constants.imperialTable
        print(scaleBar.maximumWidth)
        for row in imperialTable {
            scaleBar.metersPerPoint = row.distance
            print("number of bars: \(row.numberOfBars), count: \(scaleBar.bars.count)")
            
            XCTAssertEqual(Int(scaleBar.preferredRow().numberOfBars), scaleBar.dynamicContainerView.subviews.count)
        }
    }

}
