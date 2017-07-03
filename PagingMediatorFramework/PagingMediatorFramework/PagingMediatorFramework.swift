//
//  PagingMediatorFramework.swift
//
//  Created by Andreas Dybdahl on 22/06/2017.
//  Copyright © 2017 Makeable. All rights reserved.
//

import UIKit

/**
 This class represents an Error as a result to a PagingMediator.getResults() call, it is returned whenever something went wrong in the call.
 */
public struct PagingMediatorError {
    var errorMessage: String
    
    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
}

/**
 This Mediator class wraps a network call so it handles paging automatically. The mediator is used as an encapsulation between a calling class and the network call, and thereby eliminates the need to handle paging.
 */

/// This Mediator class wraps a network call so it handles paging automatically. The mediator is used as an encapsulation between a calling class and the network call, and thereby eliminates the need to handle paging.
///
/// **FuncParameters:** typically either a tuple/array of parameters, or a single parameter for the pagedFunc
///
/// **ReturnType:** a list of results. This list can be of any type.
public class PagingMediator<FuncParameters, ReturnType: Collection> {
    
    private var isLoadingMoreData: Bool = false
    
    private let pageLimit: Int
    
    private var page: Int
    
    private var totalPages: Int
    
    // The paged function takes generic parameters. What it must do though, is have a completion block that passes a list of results, and the totalCount of the results, also passes an error if there was one.
    private let pagedFunc: (_ params: FuncParameters, _ page: Int, _ limit: Int, _ completion: @escaping (_ result: ReturnType?, _ totalCount: Int?, _ error: PagingMediatorError?) -> Void) -> ()
    
    
    /// PagingMediator Initializer
    ///
    /// - Parameters:
    ///   - pageLimit: The supplied pageLimit should always be greater than or equal to the number of cells that can be shown in the tableView on "one" screen. So if 10 cells can fit on screen, the pageLimit should be >= 10.
    ///   - pagedFunc: This function is the network call that supports Paging. This is the function that will be wrapped in this Mediator Class.
    public init(pageLimit: Int, pagedFunc: @escaping (_ params: FuncParameters, _ page: Int, _ limit: Int, _ completion: @escaping (_ result: ReturnType?, _ totalCount: Int?, _ error: PagingMediatorError?) -> Void) -> ()) {
        self.pageLimit = pageLimit
        self.page = 1
        self.totalPages = 0
        self.pagedFunc = pagedFunc
    }
    
    /**
     This function is called whenever results needs to be fetched for the current mediator. If there is an error, the results and the totalCount will be nil, and there will be returned a PagingError.Error reference.
     */
    public func getResults(params: FuncParameters, completion: @escaping (_ result: ReturnType?, _ error: PagingMediatorError?) -> Void) {
        self.isLoadingMoreData = true // Set to true, because pagedFunc is called next
        
        self.pagedFunc(params, self.page, self.pageLimit) { (results, totalCount, error) in
            // Call returned, set isLoadingMoreData to false
            self.isLoadingMoreData = false
            
            if error != nil { // There was an error. Return the error object
                return completion(nil, error!)
            }
            else {
                if let results = results, let totalCount = totalCount {
                    self.totalPages = Int(ceil(Double(totalCount) / Double(self.pageLimit)))
                    
                    if results.count > 0 {
                        self.page += 1
                    }
                    return completion(results, nil)
                }
                return completion(nil, nil)
            }
        }
    }
    
    private var moreResults: Bool {
        get {
            return self.page <= self.totalPages
        }
    }
    
    public func reset() {
        self.page = 1
        self.totalPages = 0
        self.isLoadingMoreData = false
    }
    
    /**
     This function needs to be called in a tableView's cellForRowAt dataSource method. It returns true if the PagingMediator has more objects to load, and if the tableView has reached a point in the scrolling where the new data should be fetched, this is based on the loadOffset parameter. If the loadOffset is 5, then this function returns true if we have reached the numberOfRows-loadOffset row, and therefor should load the next data. Default value for loadOffset is 1: which loads when the last row has been reached.
     */
    public func tableViewShouldLoadMoreData(loadOffset: Int? = nil, indexPath: IndexPath, tableView: UITableView) -> Bool {
        var result: Bool = false
        
        var rowNumber: Int = 1
        for i in 0..<indexPath.section {
            rowNumber += tableView.numberOfRows(inSection: i)
        }
        rowNumber += indexPath.row
        
        // if rowNumber is close to the number of rows in tableView
        var totalRowCount: Int = 0
        for i in 0..<tableView.numberOfSections {
            totalRowCount += tableView.numberOfRows(inSection: i)
        }
        
        // Set result
        let offset = loadOffset ?? 1
        if !isLoadingMoreData && rowNumber == totalRowCount-offset && self.moreResults {
            result = true
        }
        
        return result
    }
    
    
}
