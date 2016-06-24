//
//  FileManager.m
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/23.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import "FileManager.h"
#import "WsqMD5Util.h"
@interface FileManager ()

//@property(strong,nonatomic) NSURL *startingURL;
//@property(strong,nonatomic) NSURL *destinationURL;
//@property(strong,nonatomic) NSString *startingPathString;
//@property(strong,nonatomic) NSString *destinationPathString;
//@property(assign,nonatomic) BOOL useURL;
//@property(strong,nonatomic) NSString *bakPath;

@end


@implementation FileManager

//-(BOOL)transformFileFromURL:(NSObject *)startingURL toURL:(NSObject *)destinationURL {
//    
//    return YES;
//}


-(BOOL)transformFileFromURLorStringPath:(NSObject *)startingPoint toURLorStringPath:(NSObject *)destinationPoint{
    NSURL *startingURL = nil;
    NSURL *destinationURL = nil;
    
    if ([startingPoint isMemberOfClass:[NSString class]]) {
        NSString *full = [@"file://" stringByAppendingString:(NSString *)startingPoint];
        startingURL = [NSURL URLWithString:full];
    }
    else if ([startingPoint isMemberOfClass:[NSURL class]])
    {
        startingURL = (NSURL *)startingPoint;
    }
    else{
        NSLog(@"源文件地址类型有误");
    }
    
    
    
    if ([destinationPoint isMemberOfClass:[NSString class]]) {
        NSString *full = [@"file://" stringByAppendingString:(NSString *)destinationPoint];
        destinationURL = [NSURL URLWithString:full];
    }
    else if ([destinationPoint isMemberOfClass:[NSURL class]])
    {
        destinationURL = (NSURL *)startingPoint;
    }
    else{
        NSLog(@"目标地址类型有误");
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [manager copyItemAtURL:startingURL toURL:destinationURL error:&error];
    
    if(result == NO)
    {
        NSLog(@"拷贝失败");
        [manager removeItemAtURL:destinationURL error:&error];
    }
    
    
    else if (result == YES)
    {
        NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cacheBak = [cache stringByAppendingPathComponent:@"bak/"];
        [manager createDirectoryAtPath:cacheBak withIntermediateDirectories:NO attributes:nil error:&error];
        BOOL bakResult = [manager copyItemAtPath:[startingURL path] toPath:cacheBak error:&error];
        if (bakResult == NO) {
            NSLog(@"备份失败");
            [manager removeItemAtPath:cacheBak error:&error];
        }
        else{
            NSLog(@"备份成功");
        }
        
    }
    return result;
    

}




//-(BOOL)transformFileFromURL:(NSURL *)startingURL toURL:(NSURL *)destinationURL{
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSError *error = nil;
//    BOOL result = [manager copyItemAtURL:startingURL toURL:destinationURL error:&error];
//    if(result == NO)
//    {
//        NSLog(@"拷贝失败");
//        [manager removeItemAtURL:destinationURL error:&error];
//    }
//    
//    
//    else
//    {
//        NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *cacheBak = [cache stringByAppendingPathComponent:@"bak/"];
//        self.bakPath = cacheBak;
//        [manager createDirectoryAtPath:cacheBak withIntermediateDirectories:NO attributes:nil error:&error];
//        BOOL bakResult = [manager copyItemAtPath:[startingURL path] toPath:cacheBak error:&error];
//        if (bakResult == NO) {
//            NSLog(@"备份失败");
//            [manager removeItemAtPath:cacheBak error:&error];
//        }
//        else{
//            NSLog(@"备份成功");
//        }
//        
//    }
//    self.startingURL = startingURL;
//    self.destinationURL = destinationURL;
//    self.useURL = YES;
//    return result;
//}
//
//
//
//
//-(BOOL)transformFileFromPathString:(NSString *)startingPathString toPathString:(NSString *)destinationPathString{
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSError *error = nil;
//    BOOL result = [manager copyItemAtPath:startingPathString toPath:destinationPathString error:&error];
//    if (result == NO)
//    {
//        NSLog(@"拷贝失败");
//        [manager removeItemAtPath:destinationPathString error:&error];
//    }
//    else
//    {
//        NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *cacheBak = [cache stringByAppendingPathComponent:@"bak/"];
//        self.bakPath = cacheBak;
//        [manager createDirectoryAtPath:cacheBak withIntermediateDirectories:NO attributes:nil error:&error];
//        BOOL bakResult = [manager copyItemAtPath:startingPathString toPath:cacheBak error:&error];
//        if (bakResult == NO) {
//            NSLog(@"备份失败");
//            [manager removeItemAtPath:cacheBak error:&error];
//        }
//        else{
//            NSLog(@"备份成功");
//        }
//        
//    }
//    self.startingPathString = startingPathString;
//    self.destinationPathString = destinationPathString;
//    self.useURL = NO;
//    return result;
//
//    
//}
//
//





-(void)checkUpdateOfFileAtPathOrURL:(NSObject *)fileAdress with:(NSObject *)target {
    
    NSString *targetPath = nil;
    
    if ([target isMemberOfClass:[NSURL class]]) {
        targetPath = [(NSURL *)target path];
    }
    else if ([target isMemberOfClass:[NSString class]])
    {
        targetPath = (NSString *)target;
    }
    else{
        NSLog(@"目标类型错误");
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bakPath = [cache stringByAppendingPathComponent:@"bak/"];
    NSData *bakData = [manager contentsAtPath:bakPath];
    NSData *targetData = [manager contentsAtPath:targetPath];
    NSString *bakMD5 = [WsqMD5Util getMD5WithData:bakData];
    NSString *targetMD5 = [WsqMD5Util getMD5WithData:targetData];
    if ([bakMD5 isEqualToString:targetMD5]) {
        NSLog(@"文件没有更新");
    }
    else
    {
        NSLog(@"文件发生更新");
        
        [manager removeItemAtURL:self.destinationURL error:&error];
        BOOL updated = [self transformFileFromURL:self.startingURL toURL:self.destinationURL];
        if (updated == NO) {
            [manager removeItemAtURL:self.destinationURL error:&error];
            BOOL backedup = [manager copyItemAtPath:self.bakPath toPath:[self.destinationURL path] error:&error];
            if (backedup == YES) {
                NSLog(@"更新失败，还原完成");
            }
            else{
                NSLog(@"更新失败，还原失败");
            }
        }

    }
    
    
//    NSArray *copied = [manager contentsOfDirectoryAtURL:self.destinationURL includingPropertiesForKeys:nil options:0 error:&error];
//        NSArray *origin = [manager contentsOfDirectoryAtURL:self.startingURL includingPropertiesForKeys:nil options:0 error:&error];
//        
//        if (copied.count == origin.count)
//        {
//            NSLog(@"文件数量相同");
//        }
//        
//        else
//        {
//            NSLog(@"文件发生更新");
//            [manager removeItemAtURL:self.destinationURL error:&error];
//            BOOL updated = [self transformFileFromURL:self.startingURL toURL:self.destinationURL];
//            if (updated == NO) {
//                [manager removeItemAtURL:self.destinationURL error:&error];
//                BOOL backedup = [manager copyItemAtPath:self.bakPath toPath:[self.destinationURL path] error:&error];
//                if (backedup == YES) {
//                    NSLog(@"更新失败，还原完成");
//                }
//                else{
//                    NSLog(@"更新失败，还原失败");
//                }
//            }
//        }
//    
    
    
    
    
//        
//        检查文件的数量，如果不同，一定发生了变化，此时删除旧文件，拷贝新文件。
//        使用URL进行文件的检查。
    
}



@end
