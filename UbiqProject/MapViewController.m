//
//  MapViewController.m
//  UbiqProject
//
//  Created by Robert Vo on 10/18/15.
//  Copyright © 2015 Joey. All rights reserved.
//

#import "MapViewController.h"
#import "Query.h"
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@end

@implementation MapViewController {
MKLocalSearch *localSearch;
MKLocalSearchResponse *results;
}
@synthesize ConvergeMapView, queryToShow, locationManager, addressCoordinates, FirstLocationSwitchOnOrOff, SecondLocationSwitchOnOrOff;

- (void)viewDidLoad {

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewDidLoad];
   // self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.searchDisplayController setDelegate:self];
    [self.ibSearchBar setDelegate:self];
    self.locationManager= [[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    [self.locationManager requestAlwaysAuthorization];
    // Zoom the map to current location.
    [self.ConvergeMapView setShowsUserLocation:YES];
    [self.ConvergeMapView setUserInteractionEnabled:YES];
    [self.ConvergeMapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    MKPointAnnotation *firstAddressAnnotation = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *secondAddressAnnotation = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *halfwayAnnotation = [[MKPointAnnotation alloc] init];
    
    CLPlacemark *firstAddressPlacemark = [queryToShow.locations objectAtIndex:0];
    CLPlacemark *secondAddressPlacemark = [queryToShow.locations objectAtIndex:1];
    
    CLLocationDegrees halfwayLatitude = (firstAddressPlacemark.location.coordinate.latitude + secondAddressPlacemark.location.coordinate.latitude)/2.0;
    CLLocationDegrees halfwayLongitude = (firstAddressPlacemark.location.coordinate.longitude + secondAddressPlacemark.location.coordinate.longitude)/2.0;
    
    
    
    
    
    
    
    firstAddressAnnotation.coordinate =
        CLLocationCoordinate2DMake(firstAddressPlacemark.location.coordinate.latitude, firstAddressPlacemark.location.coordinate.longitude);
    secondAddressAnnotation.coordinate =
        CLLocationCoordinate2DMake(secondAddressPlacemark.location.coordinate.latitude, secondAddressPlacemark.location.coordinate.longitude);
    halfwayAnnotation.coordinate = CLLocationCoordinate2DMake(halfwayLatitude, halfwayLongitude);

    
    //new code
    double lat = firstAddressPlacemark.location.coordinate.latitude;
    double lon = firstAddressPlacemark.location.coordinate.longitude;
    
    NSLog(@"lat = %f", lat);
    NSLog(@"lat = %f", lon);
    
    
    NSLog(@"first switch = %d", FirstLocationSwitchOnOrOff);
    NSLog(@"first switch = %d", SecondLocationSwitchOnOrOff);
   
    
    //end of new code
    
    
    
    
    
    
    [ConvergeMapView addAnnotation:firstAddressAnnotation];
    [ConvergeMapView addAnnotation:secondAddressAnnotation];
    [ConvergeMapView addAnnotation:halfwayAnnotation];
    
    MKCoordinateSpan zoom;
    zoom.latitudeDelta = .3f; //the zoom level in degrees
    zoom.longitudeDelta = .3f;//the zoom level in degrees
    MKCoordinateRegion myRegion;
    myRegion.center = halfwayAnnotation.coordinate;
    myRegion.span = zoom;
    [ConvergeMapView setRegion:myRegion animated:YES];

    //NSLog(@"💩");
    //NSLog([NSString stringWithFormat:@"%f", [queryToShow.locations objectAtIndex:0]]);
    //[self loadConvergeMapViewForConvergedPoint];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadConvergeMapViewForConvergedPoint {
    
    self.ConvergeMapView.delegate = self;
    addressCoordinates = [[queryToShow.locations objectAtIndex:0] coordinate];
    MKCoordinateSpan zoom;
    zoom.latitudeDelta = .01f; //the zoom level in degrees
    zoom.longitudeDelta = .01f;//the zoom level in degrees
    MKCoordinateRegion myRegion;
    myRegion.center = addressCoordinates;
    myRegion.span = zoom;
    [ConvergeMapView setRegion:myRegion animated:YES];

}

- (void) loadMapAtCurrentLocation { //use this snippet to load the map at the current location.
    self.ConvergeMapView.delegate = self;
    self.locationManager= [[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    [self.locationManager requestAlwaysAuthorization];
    addressCoordinates = self.locationManager.location.coordinate;
    MKCoordinateSpan zoom;
    zoom.latitudeDelta = .1f; //the zoom level in degrees
    zoom.longitudeDelta = .1f;//the zoom level in degrees
    MKCoordinateRegion myRegion;
    myRegion.center = addressCoordinates;
    myRegion.span = zoom;
    [ConvergeMapView setRegion:myRegion animated:YES];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.ConvergeMapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
    [self.ConvergeMapView addAnnotation:item.placemark];
    [self.ConvergeMapView selectAnnotation:item.placemark animated:YES];
    
    [self.ConvergeMapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    
    [self.ConvergeMapView setUserTrackingMode:MKUserTrackingModeNone];
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
