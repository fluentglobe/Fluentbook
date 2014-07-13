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
let MAX_FILE_SIZE = 24 // The maximum file size that will be cached 2^24 = 16M
let FILE_NUMBERS_MAX = 10


class CardURLCache: NSURLCache {
    
    var cacheDirectory:String = "/cache/"
    var preloadedDirectory:String = "/preloaded/"

    #if DEBUG_LOG
    func debugLog(str:AnyObject...) {
        
    }
    #endif
    
    class func activate() {
        // set caching paths
        let cachePathArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [String]
        let cachePath = cachePathArray[0]
        
        //TODO add bundleid before folder name
        let cacheDirectory = cachePath.stringByAppendingPathComponent(CACHE_FOLDER)
        
        let preloadedDirectory = NSBundle.mainBundle().resourcePath.stringByAppendingPathComponent(PRE_CACHE_FOLDER)

        #if DEBUG_LOG
        println("Cache = \(cacheDirectory), \nPreloaded = \(preloadedDirectory)")
        #endif

        // activate cache
        var urlCache = CardURLCache(memoryCapacity: 1<<MAX_FILE_SIZE, diskCapacity: FILE_NUMBERS_MAX * 1<<MAX_FILE_SIZE, diskPath: CACHE_FOLDER)
        urlCache.preloadedDirectory = preloadedDirectory
        urlCache.cacheDirectory = cacheDirectory
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    // used with the above activate()
    init(memoryCapacity: Int, diskCapacity: Int, diskPath path: String!) {
        super.init(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: path)
    }
    
    override func cachedResponseForRequest(request: NSURLRequest!) -> NSCachedURLResponse! {
        #if DEBUG_LOG
        println("CACHE REQUEST %@", request)
        #endif
        
        // is caching allowed
        if (request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData || request.cachePolicy == NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData || request.URL.absoluteString.hasPrefix("file://") || request.URL.absoluteString.hasPrefix("data:")) && CardURLCache.networkAvailable() {
            
            #if DEBUG_LOG
            println("CACHE not allowed for %@", request.URL)
            #endif
            return nil
        }
        
        // is the file in the cache? If not, is the file in the Preloaded
        var storagePath = self.storagePathForRequest(request)
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
                    #if DEBUG_LOG
                    println("CACHE item older than %@ maxAgeHours", maxAge)
                    #endif
                    return nil
                }
                #if DEBUG_LOG
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
            var storagePath = self.storagePathForRequest(request, path: self.preloadedDirectory)
            if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
                #if DEBUG_LOG
                println("CACHE not storing file, it's not allowed by the cachePolicy: %@", request.URL)
                #endif
                return
            }
            #if DEBUG_LOG
                println("CACHE file in Preloaded folder, overriding cachePolicy: %@", request.URL)
            #endif
        }
        
        // create storage folder
        var storagePath = self.storagePathForRequest(request, path: cacheDirectory)
        var storageDirectory = storagePath.stringByDeletingLastPathComponent
        var error:NSError? = nil
        if NSFileManager.defaultManager().createDirectoryAtPath(storageDirectory, withIntermediateDirectories: true, attributes: nil, error: &error) {
            #if DEBUG_LOG
                println("Error creating cache directory: %@", error)
            #endif
        }
        
        // save file
        #if DEBUG_LOG
            println("Writing data to %@", storagePath)
        #endif
        if !cachedResponse.data.writeToFile(storagePath, atomically: true) {
            #if DEBUG_LOG
                println("Could not write file to cache")
            #endif
        } else {
            // prevent iCloud  backup
            var cacheURL = NSURL(fileURLWithPath: storagePath)
            cacheURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey, error: &error) //TODO check if this is the newer better version of the next stuff
            if !CardURLCache.addSkipBackupAttributeToItemAtURL(cacheURL) {
                #if DEBUG_LOG
                    println("Could not set the do not backup attribute")
                #endif
            }
        }
        
    }
    
    // #pragma mark - helper methods
    
    func storagePathForRequest(request: NSURLRequest) -> String? {
        var storagePath:String? = self.storagePathForRequest(request, path: self.cacheDirectory)
        if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
            storagePath = self.storagePathForRequest(request, path: self.preloadedDirectory)
            if !NSFileManager.defaultManager().fileExistsAtPath(storagePath) {
                storagePath = nil
            }
        }
        return storagePath
    }

    func storagePathForRequest(request: NSURLRequest, path: String) -> String {
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
