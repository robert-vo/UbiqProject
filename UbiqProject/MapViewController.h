//
//  MapViewController.h
//  UbiqProject
//
//  Created by Robert Vo on 10/18/15.
//  Copyright © 2015 Joey. All rights reserved.
//
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Query.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *ConvergeMapView;
@property Query *queryToShow;
@property NSString *commonPoints;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic,assign) CLLocationCoordinate2D addressCoordinates;
@property (strong, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property MKAnnotationView *annotationViewOfMap;

@property double firstLocationLatitude;
@property double firstLocationLongitude;
@property double secondLocationLatitude;
@property double secondLocationLongitude;

- (IBAction)settingsButtonClick:(id)sender;

- (void) loadConvergeMapViewForConvergedPoint;
- (void) loadPlacesFromNaturalLanguageQuery:(CLLocationCoordinate2D) halfwayCoordinates;
- (CLLocationCoordinate2D)locationPlacemarkCoordinatesFactoryMethod:(id)locationCoordinates;

@end
