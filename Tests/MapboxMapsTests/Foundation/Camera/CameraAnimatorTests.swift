import XCTest
@testable import MapboxMaps

internal let cameraOptionsTestValue = CameraOptions(center: CLLocationCoordinate2D(latitude: 10, longitude: 10),
                                                              padding: .init(top: 10, left: 10, bottom: 10, right: 10),
                                                              anchor: .init(x: 10.0, y: 10.0),
                                                              zoom: 10,
                                                              bearing: 10,
                                                              pitch: 10)

internal class CameraAnimatorTests: XCTestCase {
    
    var delegate: CameraAnimatorDelegateMock!
    var propertyAnimator: UIViewPropertyAnimatorMock!
    var cameraView: CameraViewMock!
    var animator: CameraAnimator?

    override func setUp() {
        delegate = CameraAnimatorDelegateMock()
        propertyAnimator = UIViewPropertyAnimatorMock()
        cameraView = CameraViewMock()
        animator = CameraAnimator(delegate: delegate,
                                  propertyAnimator: propertyAnimator ,
                                  owner: .unspecified,
                                  cameraView: cameraView)
    }
    

    func testInitializationAndDeinit() {
        XCTAssertEqual(delegate.addViewToViewHeirarchyStub.invocations.count, 1)
        
        animator = nil
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(cameraView.removeFromSuperviewStub.invocations.count, 1)
    }
    
    func testStartAnimation() {
        animator?.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        
        animator?.startAnimation()
        
        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)
    }
    
    func testUpdate() {
        animator?.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        
        animator?.startAnimation()
        
        propertyAnimator.shouldReturnState = .active
        animator?.update()
        
        XCTAssertEqual(delegate.jumpToStub.invocations.count, 1)
        XCTAssertEqual(delegate.jumpToStub.invocations.first?.parameters.zoom,
                       cameraView.localCamera.zoom)
        
    }
}

