//
//  AstronomyTests.swift
//  AstronomyTests
//
//  Created by Carolyn Lea on 9/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import XCTest
@testable import Astronomy

class MockDataLoader: NetworkDataLoader
{
    let data: Data?
    let error: Error?
    private(set) var request: URLRequest? = nil
     var url: URL? = nil
    
    init(data: Data?, error: Error?)
    {
        self.data = data
        self.error = error
        
    }
    
    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void)
    {
        self.request = request
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            completion(self.data, self.error)
        }
        
    }
    
    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void)
    {
        self.url = url
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            completion(self.data, self.error)
        }
    }
}

class AstronomyTests: XCTestCase
{//validRoverJSON//validSol1JSON
    func testFetchMarsRover()
    {
        let expectation = self.expectation(description: "Mars Rover Expectation")
        
        let mock = MockDataLoader(data: validRoverJSON, error: nil)
        let marsRoverClient = MarsRoverClient(dataLoader: mock)
        
        marsRoverClient.fetchMarsRover(named: "Curiosity") { (rover, error) in
            
            XCTAssertNotNil(mock.url)
            
            let components = URLComponents(url: mock.url!, resolvingAgainstBaseURL: true)!
            let testComponents = URLComponents(url: URL(string: "https://api.nasa.gov/mars-photos/api/v1/manifests/Curiosity?api_key=qzGsj0zsKk6CA9JZP1UjAbpQHabBfaPg2M5dGMB7")!, resolvingAgainstBaseURL: true)!
            XCTAssertTrue(self.urlComponents(components, equalTo: testComponents))
            
            XCTAssertNotNil(rover)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
            
    }
    
    let marsRover = MarsRover.init(name: "Curiosity", launchDate: Date(), landingDate: Date(), status: .active, maxSol: 2172, maxDate: Date(), numberOfPhotos: 341463, solDescriptions: [SolDescription(sol: 1, totalPhotos: 16, cameras: ["MAHLI","MAST","NAVCAM"])])
    
    func testFetchPhotos()
    {
        let expectation = self.expectation(description: "Fetch Photos Expectations")
        
        let mock = MockDataLoader(data: validSol1JSON, error: nil)
        let marsRoverClient = MarsRoverClient(dataLoader: mock)
        
        
        marsRoverClient.fetchPhotos(from: marsRover, onSol: 1) { (photoRefs, error) in
            
            XCTAssertNotNil(mock.url)
            
            let components = URLComponents(url: mock.url!, resolvingAgainstBaseURL: true)!
            let testComponents = URLComponents(url: URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/Curiosity/photos?sol=1&api_key=qzGsj0zsKk6CA9JZP1UjAbpQHabBfaPg2M5dGMB7")!, resolvingAgainstBaseURL: true)!
            XCTAssertTrue(self.urlComponents(components, equalTo: testComponents))
            
            XCTAssertNotNil(photoRefs)
            XCTAssertNil(error)
            
            let firstObject = photoRefs!.first!
            XCTAssertEqual(firstObject.id, 4477)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
}

func urlComponents(_ components1: URLComponents, equalTo components2: URLComponents) -> Bool
{
    var scratch1 = components1
    var scratch2 = components2
    
    scratch1.queryItems = []
    scratch2.queryItems = []
    if scratch1 != scratch2
    {
        return false
    }
    
    // Compare query items
    if let queryItems1 = components1.queryItems,
        let queryItems2 = components2.queryItems
    {
        if Set(queryItems1) != Set(queryItems2)
        {
            return false
        }
    }
    
    return true
}
}
