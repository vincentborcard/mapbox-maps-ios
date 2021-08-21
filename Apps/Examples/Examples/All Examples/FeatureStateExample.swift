import UIKit
import MapboxMaps

@objc(FeatureStateExample)

public class FeatureStateExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    
    static let earthquakeSourceId: String = "earthquakes"
    static let earthquakeLayerId: String = "earthquake-viz"
    
    var previouslyTappedFeatureId: String = ""

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2.4))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
        }
    }

    public func setupExample() {

        // Create a new GeoJSON data source which gets its data from an external URL.
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            preconditionFailure("Could not calculate date for seven days ago.")
        }
        
        // Format the date to ISO8601 as required by the earthquakes API
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let startTime = iso8601DateFormatter.string(from: sevenDaysAgo)
        
        // Create the url required for the GeoJSONSource
        guard let earthquakeURL = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&eventtype=earthquake&minmagnitude=1&starttime=" + startTime) else {
            preconditionFailure("URL is not valid")
        }
        
        var earthquakeSource = GeoJSONSource()
        earthquakeSource.data = .url(earthquakeURL)
        earthquakeSource.generateId = true
        try! mapView.mapboxMap.style.addSource(earthquakeSource, id: Self.earthquakeSourceId)
        
        /*
         
         'circle-radius': [
                       'case',
                       ['boolean', ['feature-state', 'hover'], false],
                       [
                         'interpolate',
                         ['linear'],
                         ['get', 'mag'],
                         1,
                         8,
                         1.5,
                         10,
                         2,
                         12,
                         2.5,
                         14,
                         3,
                         16,
                         3.5,
                         18,
                         4.5,
                         20,
                         6.5,
                         22,
                         8.5,
                         24,
                         10.5,
                         26
                       ],
                       5
                     ],
         
         */
        // Add earthquake-viz layer
        var earthquakeVizLayer = CircleLayer(id: Self.earthquakeLayerId)
        earthquakeVizLayer.source = Self.earthquakeSourceId
        earthquakeVizLayer.circleRadius = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    8
                    1.5
                    10
                    2
                    12
                    2.5
                    14
                    3
                    16
                    3.5
                    18
                    4.5
                    20
                    6.5
                    22
                    8.5
                    24
                    10.5
                    26
                }
                5
            }
        )
        earthquakeVizLayer.circleRadiusTransition = StyleTransition(duration: 0.5, delay: 0)
        earthquakeVizLayer.circleStrokeColor = .constant(.init(color: .black))
        earthquakeVizLayer.circleStrokeWidth = .constant(1)
        earthquakeVizLayer.circleColor = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    "#fff7ec"
                    1.5
                    "#fee8c8"
                    2
                    "#fdd49e"
                    2.5
                    "#fdbb84"
                    3
                    "#fc8d59"
                    3.5
                    "#ef6548"
                    4.5
                    "#d7301f"
                    6.5
                    "#b30000"
                    8.5
                    "#7f0000"
                    10.5
                    "#000"
                }
                "#000"
            }
        )
        earthquakeVizLayer.circleColorTransition = StyleTransition(duration: 0.5, delay: 0)
        try! mapView.mapboxMap.style.addLayer(earthquakeVizLayer)

        // Set up the tap gesture
        addTapGesture(to: mapView)
    }

    // Add a tap gesture to the map view.
    public func addTapGesture(to mapView: MapView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(findFeatures))
        mapView.addGestureRecognizer(tapGesture)
    }

    /**
     Use the tap point received from the gesture recognizer to query
     the map for rendered features at the given point within the layer specified.
     */
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)

        mapView.mapboxMap.queryRenderedFeatures(
            at: tapPoint,
            options: RenderedQueryOptions(layerIds: ["earthquake-viz"], filter: nil)) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let queriedfeatures):
                if let firstFeature = queriedfeatures.first?.feature,
                   let featureId = (firstFeature.identifier as? NSNumber)?.stringValue,
                   let magnitude = firstFeature.properties["mag"],
                   let place = firstFeature.properties["place"],
                   let timestamp = firstFeature.properties["time"] as? NSNumber {
                   
                   
                    print("----------------------------------------------")
                    print("Feature id: \(firstFeature.identifier)")
                    print("Magnitude: \(magnitude)")
                    print("Location: \(place)")
                    print("Date: \(timestamp)")
                    
                    self.mapView.mapboxMap.setFeatureState(sourceId: Self.earthquakeSourceId,
                                                           sourceLayerId: nil,
                                                           featureId: featureId,
                                                           state: ["selected": true])
                    
                    if self.previouslyTappedFeatureId != "" && featureId != self.previouslyTappedFeatureId  {
                        self.mapView.mapboxMap.setFeatureState(sourceId: Self.earthquakeSourceId,
                                                                sourceLayerId: nil,
                                                                featureId: self.previouslyTappedFeatureId,
                                                                state: ["selected": false])
                    }
                    self.previouslyTappedFeatureId = featureId
                    
                    let point = firstFeature.geometry.extractLocations()!.cgPointValue
                    let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.x), longitude: CLLocationDegrees(point.y))
                    
                    self.mapView.camera.fly(to: CameraOptions(center: coord, zoom: 10))
                    
                } else {
                    self.mapView.mapboxMap.removeFeatureState(sourceId: Self.earthquakeSourceId, sourceLayerId: nil, featureId: self.previouslyTappedFeatureId, stateKey: "selected")
                    self.previouslyTappedFeatureId = ""
                }
            case .failure(let error):
                self.showAlert(with: "An error occurred: \(error.localizedDescription)")
            }
        }
    }

    // Present an alert with a given title.
    public func showAlert(with title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}


fileprivate class EarthquakeDescriptionView: UIView {
    
    var magnitudeLabel: UILabel!
    var locationLabel: UILabel!
    var dateLabel: UILabel!
    
    var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.borderColor = UIColor.black.cgColor
        
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        
        magnitudeLabel = UILabel(frame: .zero)
        magnitudeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        locationLabel = UILabel(frame: .zero)
        locationLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dateLabel = UILabel(frame: .zero)
        dateLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [magnitudeLabel, locationLabel, dateLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
    }
    
}
