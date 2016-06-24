//
//  FileManager.m
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/23.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import "FileManager.h"
#import "WsqMD5Util.h"

@implementation FileManager



-(BOOL)translateFileFromURLorStringPath:(NSObject *)startingPoint toURLorStringPath:(NSObject *)destinationPoint ifNeedCheckingUpdate:(BOOL)needChecking{
    NSFileManager *manager = [NSFileManager defaultManager];

    BOOL result = nil;
    NSURL *startingURL = [self transformObjectToURL:startingPoint];
    NSURL *destinationURL = [self transformObjectToURL:destinationPoint];
  
    if (startingPoint == nil || destinationPoint == nil) {
        NSLog(@"输入有误");
        return NO;
    }

    
//    处理输入，初始化变量。
    
    
    if (needChecking == YES) {
        if ([manager fileExistsAtPath:[destinationURL path]] == NO) {
            NSLog(@"目标路径并没有文件");
        }
        else if ([manager fileExistsAtPath:[destinationURL path]] == YES)
        {
           
            NSLog(@"目标路径已有文件。");
            [self checkUpdateOfFileAtPathOrURL:destinationPoint withPotentialUpdatedtarget:startingPoint];
        }
    }
    
    
//    check操作。如果目标路径没有文件，那就直接复制。如果有，那就check一下是否一样，如果一样，不管，如果不一样，删掉老的，copy过去新的，然后备份。如果copy失败，还原。
    
    
    NSError *error = nil;
    [manager removeItemAtURL:destinationURL error:&error];
    error = nil;
    [manager copyItemAtURL:startingURL toURL:destinationURL error:&error];
    
    if(error != nil)
    {
        NSLog(@"拷贝失败");
        [manager removeItemAtURL:destinationURL error:&error];
    }
    
    else if (error == nil)
    {
        NSString * cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cacheBak = [cache stringByAppendingPathComponent:@"bak/"];
        error = nil;
        [manager createDirectoryAtPath:cacheBak withIntermediateDirectories:NO attributes:nil error:&error];
        error = nil;
        result = [manager copyItemAtPath:[startingURL path] toPath:cacheBak error:&error];
        if (error != nil) {
            NSLog(@"备份失败");
            [manager removeItemAtPath:cacheBak error:&error];
        }
        else{
            NSLog(@"备份成功");
        }
        
    }
    
    return result;
    

}





-(void)checkUpdateOfFileAtPathOrURL:(NSObject *)fileAdress withPotentialUpdatedtarget:(NSObject *)target{
    
    NSString *targetPath = [self transformObjectToNSString:target];
    NSString *originPath = [self transformObjectToNSString:fileAdress];
    
    if (targetPath == nil || originPath == nil) {
        NSLog(@"输入有误");
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bakPath = [cache stringByAppendingPathComponent:@"bak/"];
    NSData *originData = [manager contentsAtPath:originPath];
    NSData *targetData = [manager contentsAtPath:targetPath];
    NSString *originMD5 = [WsqMD5Util getMD5WithData:originData];
    NSString *targetMD5 = [WsqMD5Util getMD5WithData:targetData];
    
    if ([originMD5 isEqualToString:targetMD5]) {
        NSLog(@"文件没有更新");
    }
    
    else
    {
        NSLog(@"文件发生更新");
        [manager removeItemAtPath:originPath error:&error];
        BOOL updated = [self translateFileFromURLorStringPath:targetPath toURLorStringPath:originPath ifNeedCheckingUpdate:NO];
//        更新文件。删除旧的，copy过去新的。
        if (updated == NO) {
            [manager removeItemAtPath:originPath error:&error];
            error = nil;
             [manager copyItemAtPath:bakPath toPath:originPath error:&error];
            if (error != nil) {
                NSLog(@"更新失败，还原完成");
            }
            else{
                NSLog(@"更新失败，还原失败");
                [manager removeItemAtPath:originPath error:&error];
            }
        }

    }
    
//        检查文件的数量，如果不同，一定发生了变化，此时删除旧文件，拷贝新文件。
//        使用URL进行文件的检查。
    
}



-(NSURL *)transformObjectToURL:(NSObject *)obj{
    
    NSURL *URL = nil;
    
    if ([obj isKindOfClass:[NSString class]]) {
        
        URL = [NSURL fileURLWithPath:(NSString *)obj];
        
    }
    
    else if ([obj isKindOfClass:[NSURL class]])
    {
        URL = (NSURL *)obj;
    }
      return URL;
}


-(NSString *)transformObjectToNSString:(NSObject *)obj{
    
    NSString *string = nil;
    
    if ([obj isKindOfClass:[NSString class]]) {
        string = (NSString *)obj;
    }
    
    else if ([obj isKindOfClass:[NSURL class]])
    {
        string = [(NSURL *)obj path];
    }
    return string;
}



@end
