//
//  CardURLCache.swift
//  Web Cards
//
//  Created by Henrik Vendelbo on 28/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//
// Based on EVURLCache from evermeer

import UIKit

let URLCACHE_CACHE_KEY = "MobileAppCacheKey"
let URLCACHE_EXPIRATION_AGE_KEY = "MobileAppExpirationAgeKey"
let MAX_AGE = "604800000"
let PRE_CACHE_FOLDER = "/CardPreloaded/"
let CACHE_FOLDER = "/CardCache/"
let MAX_FILE_SIZE = 26 // The maximum file size that will be cached 2^24 = 16M

//TODO make class vars
var cardCacheDirectory:String = "/cache/"
var cardPreloadedDirectory:String = "/preloaded/"

class CardURLCache: NSURLCache {
    
    #if DEBUG
    func debugLog(str:AnyObject...) {
        
    }
    #endif
    
    class func activate() {
        // set caching paths
        var documentDirectory : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        cardCacheDirectory = documentDirectory.stringByAppendingString(CACHE_FOLDER)
        mkdir(cardCacheDirectory.bridgeToObjectiveC().UTF8String, 0700)
        
        cardPreloadedDirectory = NSBundle.mainBundle().resourcePath.stringByAppendingPathComponent(PRE_CACHE_FOLDER)

        #if DEBUG
        println("Docs = \(documentDirectory), \nCache = \(cardCacheDirectory), \nPreloaded = \(cardPreloadedDirectory)")
        #endif

        // activate cache
        var urlCache = CardURLCache(memoryCapacity: 1<<MAX_FILE_SIZE, diskCapacity: 1<<MAX_FILE_SIZE, diskPath: cardCacheDirectory)
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    // used with the above activate()
    init(memoryCapacity: Int, diskCapacity: Int, diskPath path: String!) {
        super.init(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: path)
    }
    
    override func cachedResponseForRequest(request: NSURLRequest!) -> NSCachedURLResponse! {
        #if DEBUG
        println("CACHE REQUEST %@", request)
        #endif
        
        // is caching allowed
        if (request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData || request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData || request.URL.absoluteString.hasPrefix("file://") || request.URL.absoluteString.hasPrefix("data:")) && CardURLCache.networkAvailable() {
            
            #if DEBUG
            println("CACHE not allowed for %@", request.URL)
            #endif
            return nil
        }
        
        // is the file in the cache? If not, is the file in the Preloaded
        var storagePath = CardURLCache.storagePathForRequest(request)
        //?? original source repeated test
        
        if NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
            
            if CardURLCache.networkAvailable() {
                // Max cache age for request
                var maxAge:String? = request.valueForHTTPHeaderField(URLCACHE_EXPIRATION_AGE_KEY)
                if maxAge == nil || maxAge!.bridgeToObjectiveC().floatValue == 0 {
                    maxAge = MAX_AGE
                }
                
                // Last modification date for file
                var error:NSError? = nil
                var attributes = NSFileManager.defaultManager().attributesOfItemAtPath(storagePath, error: &error)
                var modDate = attributes[NSFileModificationDate] as NSDate
                
                // Test if the file is older than max age
                var threshold = maxAge!.bridgeToObjectiveC().doubleValue as NSTimeInterval
                var modificationTimeSinceNow = -modDate.timeIntervalSinceNow
                if modificationTimeSinceNow > threshold {
                    #if DEBUG
                    println("CACHE item older than %@ maxAgeHours", maxAge)
                    #endif
                    return nil
                }
                #if DEBUG
                println("CACHE max age = %@, file date = %@", maxAge, modDate)
                #endif
            }
            
            // Return the cache response
            var content = NSData(contentsOfFile: storagePath)
            var response = NSURLResponse(URL: request.URL, MIMEType: "cache", expectedContentLength: content.length, textEncodingName: nil)
            return NSCachedURLResponse(response: response, data: content)
        }
        
        #if DEBUG
            println("CACHE not found %@", storagePath)
        #endif
        return nil
    }
    
    override func storeCachedResponse(cachedResponse: NSCachedURLResponse!, forRequest request: NSURLRequest!) {
        
        // check if caching is allowed
        if request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData || request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData {
            
            // If the file is in the Preloaded folder, then we do want to save a copy in case we are without internet connection
            var storagePath = CardURLCache.storagePathForRequest(request, path: cardPreloadedDirectory)
            if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
                #if DEBUG
                println("CACHE not storing file, it's not allowed by the cachePolicy: %@", request.URL)
                #endif
                return
            }
            #if DEBUG
                println("CACHE file in Preloaded folder, overriding cachePolicy: %@", request.URL)
            #endif
        }
        
        // create storage folder
        var storagePath = CardURLCache.storagePathForRequest(request, path: cardCacheDirectory)
        var storageDirectory = storagePath.stringByDeletingLastPathComponent
        var error:NSError? = nil
        if NSFileManager.defaultManager().createDirectoryAtPath(storageDirectory, withIntermediateDirectories: true, attributes: nil, error: &error) {
            #if DEBUG
                println("Error creating cache directory: %@", error)
            #endif
        }
        
        // save file
        #if DEBUG
            println("Writing data to %@", storagePath)
        #endif
        if !cachedResponse.data.writeToFile(storagePath, atomically: true) {
            #if DEBUG
                println("Could not write file to cache")
            #endif
        } else {
            // prevent iCloud  backup
            var cacheURL = NSURL(fileURLWithPath: storagePath)
            if !CardURLCache.addSkipBackupAttributeToItemAtURL(cacheURL) {
                #if DEBUG
                    println("Could not set the do not backup attribute")
                #endif
            }
        }
        
    }
    
    // #pragma mark - helper methods
    
    class func storagePathForRequest(request: NSURLRequest) -> String? {
        var storagePath:String? = CardURLCache.storagePathForRequest(request, path: cardCacheDirectory)
        if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
            storagePath = CardURLCache.storagePathForRequest(request, path: cardPreloadedDirectory)
            if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
                storagePath = nil
            }
        }
        return storagePath
    }

    class func storagePathForRequest(request: NSURLRequest, path: String) -> String {
        var cacheKey: String? = request.valueForHTTPHeaderField(URLCACHE_CACHE_KEY);
        var localUrl:String? = nil
        if cacheKey == nil {
            localUrl = String(format:"%@%@", path, request.URL.relativePath.lowercaseString)
        } else {
            localUrl = String(format:"%@/%@", path, cacheKey!)
        }
        var pathBits = localUrl!.componentsSeparatedByString("/")
        var storageFile:String = pathBits[pathBits.count - 1]
        //TODO
//        if storageFile.rangeOfString(".").location == NSNotFound {
//            return String(format:"%@/index.html", localUrl)
//        }
        return localUrl!
     }
    
    class func addSkipBackupAttributeToItemAtURL(url: NSURL) -> Bool {
        let filePath = url.path.bridgeToObjectiveC().fileSystemRepresentation
        let attrName = "com.apple.MobileBackup".bridgeToObjectiveC().UTF8String
//        if NSURLIsExcludedFromBackupKey == nil iOS 5
        
        // first try and remove the extended attribute if it is present
        var attrSize:size_t = 1 /*sizeof(Int8)*/
        var result = getxattr(filePath, attrName, nil, attrSize , 0, 0)
        if result != -1 {
            // The attribute exists, we need to remove it
            var removeResult = removexattr(filePath, attrName, 0)
            if removeResult == 0 {
                #if DEBUG
                println("removed extended attribute for caching on %@", URL)
                #endif
            }
        }

        return url.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey, error:nil)
    }
    
    class func networkAvailable() -> Bool {
        var reachability = Reachability.reachabilityForInternetConnection()
        var internetStatus = reachability.currentReachabilityStatus()
        if internetStatus != NetworkStatus.NotReachable {
            return true
        }
        return false
    }
}
