//
//  TQImageCache.m
//
//
//  Created by Tang Qiao on 12-5-9.
//  Copyright (c) 2012年 blog.devtang.com. All rights reserved.
//

#import "TQImageCache.h"

@interface TQImageCache()

@property (nonatomic, retain) NSFileManager * fileManager;
@property (nonatomic, retain) NSMutableDictionary * memoryCache;
@property (nonatomic, retain) NSMutableArray *memoryCacheKeys;

@end

#define PATH_OF_TEMP        [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]

@implementation TQImageCache;

@synthesize fileManager;
@synthesize memoryCache;
@synthesize memoryCacheKeys;
@synthesize maxMemoryCacheNumber;
@synthesize lastCacheKitStatus;
@synthesize cachePath;

static BOOL debugMode = NO;

- (id) init {
    return [self initWithCachePath:@"TQImageCache" andMaxMemoryCacheNumber:50];
}

- (id) initWithCachePath:(NSString*)path andMaxMemoryCacheNumber:(NSInteger)maxNumber {
    NSString * tmpDir = PATH_OF_TEMP;
    if ([path hasPrefix:tmpDir]) {
        cachePath = path;
    } else {
        if ([path length] != 0) {
            cachePath = [tmpDir stringByAppendingPathComponent:path];
        } else {
            return nil;
        }
    }
    maxMemoryCacheNumber = maxNumber;

    if (self = [super init]) {
        fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cachePath isDirectory:nil] == NO) {
            // create the directory
            BOOL res = [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
            if (!res) {
                debugLog(@"file cache directory create failed! The path is %@", _cachePath);
                return nil;
            }
        }
        memoryCache = [[NSMutableDictionary alloc] initWithCapacity:maxMemoryCacheNumber + 1];
        memoryCacheKeys = [[NSMutableArray alloc] initWithCapacity:maxMemoryCacheNumber + 1];
        return self;
    }
    return nil;
}

- (void)clear {
    memoryCache = [[NSMutableDictionary alloc] initWithCapacity:maxMemoryCacheNumber + 1];
    memoryCacheKeys = [[NSMutableArray alloc] initWithCapacity:maxMemoryCacheNumber + 1];

    // remove all the file in temporary
    NSArray * files = [self.fileManager contentsOfDirectoryAtPath:self.cachePath error:nil];
    for (NSString * file in files) {
        if (debugMode) {
            debugLog(@"remove cache file: %@", file);
        }
        [self.fileManager removeItemAtPath:file error:nil];
    }
}

- (void) checkCacheSize {
    if ([self.memoryCache count] > maxMemoryCacheNumber) {
        NSString * key = [self.memoryCacheKeys objectAtIndex:0];
        [self.memoryCache removeObjectForKey:key];
        [self.memoryCacheKeys removeObjectAtIndex:0];
        if (debugMode) {
            debugLog(@"remove oldest cache from memory: %@", key);
        }
    }
}

- (void) putImage:(NSData *) imageData withName:(NSString*)imageName {
    if (imageData == nil) {
        if (debugMode) {
            debugLog(@"image data is nil");
        }
        return;
    }
    [self.memoryCache setObject:imageData forKey:imageName];
    [self.memoryCacheKeys addObject:imageName];
    [self checkCacheSize];
    NSString * path = [self.cachePath stringByAppendingPathComponent:imageName];
    [imageData writeToFile:path atomically:YES];
    if (debugMode) {
        debugLog(@"TQImageCache put cache image to %@", path);
    }
}

- (NSData *) getImage:(NSString *)imageName {
    NSData * data = [self.memoryCache objectForKey:imageName];
    if (data != nil) {
        if (debugMode) {
            debugLog(@"TQImageCache hit cache from memory: %@", imageName);
        }
        self.lastCacheKitStatus = kLastCacheKitStatusInMemory;
        return data;
    }
    NSString * path = [self.cachePath stringByAppendingPathComponent:imageName];
    if ([self.fileManager fileExistsAtPath:path]) {
        if (debugMode) {
            debugLog(@"TQImageCache hit cache from file %@", path);
        }
        data = [NSData dataWithContentsOfFile:path];
        // put it to memeory
        [self.memoryCache setObject:data forKey:imageName];
        [self.memoryCacheKeys addObject:imageName];
        [self checkCacheSize];
        self.lastCacheKitStatus = kLastCacheKitStatusInDisk;
        return data;
    }
    self.lastCacheKitStatus = kLastCacheKitStatusNotFound;
    return nil;
}


+ (NSString *)parseUrlForCacheName:(NSString *)name {
    if (name == nil) {
        return nil;
    }
    name = [name stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"://" withString:@"-"];
    name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    name = [NSString stringWithFormat:@"%@.png", name];
    // debugLog(@"dest video url cache name :%@", name);
    return name;
}


@end
