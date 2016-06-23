//
//  GNFileManager.m
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/22.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//


#import "GNFileManager.h"
@interface GNFileManager ()

@property (nonatomic,strong) NSArray *resourceArray;

@end




@implementation GNFileManager

static id instance;


-(void)addResources

{
//    遍历bundle下的www文件夹中的所有文件，然后拷进temp的www文件夹中。
//    如果拷贝失败，报错并且删除。      ----？？ 什么情况下会失败？？怎么判断？
//    如果拷贝成功，制作www备份。      放进Caches目录里。
    
    
        NSString *bunPath =  [[NSBundle mainBundle]bundlePath];
        NSString *wPath = [bunPath stringByAppendingPathComponent:@"www/"];
        NSLog(@"\n www path  is %@ \n",wPath);
        NSArray *resourceArray = [self allFilesAtPath:wPath];
        NSLog(@"the array is \n   %@   \n",resourceArray);
    
        NSFileManager *fileManager= [NSFileManager defaultManager];
        NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
        [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:nil];
        
        for (NSString *cssStr in resourceArray) {
            
            NSLog(@"temDirURL is %@",temDirURL);
            NSURL *dstURL = [temDirURL URLByAppendingPathComponent:cssStr.lastPathComponent];
            NSLog(@"dstURL is %@",dstURL);
            NSString *cssURLStr = [@"file://" stringByAppendingString:cssStr];
            [fileManager removeItemAtURL:dstURL error:nil];
            [fileManager copyItemAtURL:[NSURL URLWithString:cssURLStr] toURL:dstURL error:nil];
            if ([cssStr.lastPathComponent containsString:@"html"]) {
                NSLog(@"\n bingo %@\n",cssStr.lastPathComponent);
                self.htmlURL = [NSURL URLWithString:cssURLStr];
                NSLog(@"\nand the html is %@ \n",self.resourceURL);
            } 
            
        }
    
        
    
    
            self.resourceURL = temDirURL;
    
    
    if (self.htmlURL == nil) {
        NSLog(@"html未找到");
    }

}


- (NSArray*) allFilesAtPath:(NSString*) dirString {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        BOOL flag = YES;
        
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            
            if (!flag) {
                
                [array addObject:fullPath];
                
            }
            
        }
        
    }
    
    return array;
    
}








-(void)checkResources{
    if ([self differFromBundle]  == YES) {
        NSLog(@"资源有不同");
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"www"];
        
        
    }
    
    else{
        NSLog(@"无更新。");
    }
//    检查temp的www文件夹中的文件，和bundle中的www文件夹对比。
//    如果没有区别，什么都不做。
//    如果有区别，执行addResources方法，如果成功，覆盖文件。如果不成功，还原以前的www。
    
}






-(BOOL)differFromBundle{
    for (NSString *resourceStr in self.resourceArray) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *fullStr = [@"file://" stringByAppendingString:resourceStr];
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"www"];
        NSString *tempFilePath = [tempPath stringByAppendingPathComponent:resourceStr.lastPathComponent];
        if ([manager contentsEqualAtPath:fullStr andPath:tempFilePath] == NO) {
            NSLog(@"文件有更新！");
            return YES;
        }
        else{
            return NO;
        }
    
    }
    
    
    return YES;
}




+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [super allocWithZone:zone];
    });
    return instance;
}




+(instancetype)sharedfileManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
     instance = [[self alloc]init];
    });
    return instance;
}


@end
