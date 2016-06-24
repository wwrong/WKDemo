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
@property(strong,nonatomic) NSURL *wwwURL;
@property(strong,nonatomic) NSURL *bakURL;
@end




@implementation GNFileManager

static id instance;


-(void)addResources

{
//    遍历bundle下的www文件夹中的所有文件，然后拷进temp的www文件夹中。
//    如果拷贝失败，报错并且删除。      ---- 什么情况下会失败？？  磁盘已满，或者有坏道。    怎么判断？
//    如果拷贝成功，制作www备份。      放进Caches目录里。
    
        NSString *bunPath =  [[NSBundle mainBundle]bundlePath];
        NSString *wPath = [bunPath stringByAppendingPathComponent:@"www/"];
        NSLog(@"\n www path  is %@ \n",wPath);
        NSArray *resourceArray = [self allFilesAtPath:wPath];
        NSLog(@"the array is \n   %@   \n",resourceArray);
    
        NSFileManager *fileManager= [NSFileManager defaultManager];
//        NSString * cachedir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString * cachedir = NSTemporaryDirectory();
        NSURL *temDirURL = [[NSURL fileURLWithPath:cachedir] URLByAppendingPathComponent:@"www"];

        self.wwwURL = temDirURL;
    
        NSURL *cacDirURL = [[NSURL fileURLWithPath:cachedir] URLByAppendingPathComponent:@"bak"];
        NSLog(@"wwwURL is %@\n",self.wwwURL);
    
        [[NSFileManager defaultManager] removeItemAtURL:temDirURL error:nil];
    
        [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    

//    移到temp
    
    for (NSString *resourceURLStr in resourceArray) {
        
        NSLog(@"temDirURL is %@",temDirURL);
        NSURL *dstURL = [temDirURL URLByAppendingPathComponent:resourceURLStr.lastPathComponent];
        NSLog(@"dstURL is %@",dstURL);
        NSString *fullURLStr = [@"file://" stringByAppendingString:resourceURLStr];
        [fileManager removeItemAtURL:dstURL error:nil];
        BOOL moveSuccess = [fileManager copyItemAtURL:[NSURL URLWithString:fullURLStr] toURL:dstURL error:nil];
        if ([resourceURLStr.lastPathComponent containsString:@"html"]) {
            NSLog(@"\n bingo %@\n",resourceURLStr.lastPathComponent);
            self.htmlURL = [NSURL URLWithString:fullURLStr];
        }
        if (moveSuccess == NO) {
            NSLog(@"%@文件移动失败！",resourceURLStr.lastPathComponent);
            NSError *error = nil;
            [[NSFileManager defaultManager]removeItemAtURL:dstURL error:&error];
            
            return;
        }
    }
    
//    如果文件移动中出现问题，就直接return，不进行bak的创建，如果全部成功，才能继续进行备份
    
//    备份到Caches/bak
    
    [[NSFileManager defaultManager] removeItemAtURL:cacDirURL error:nil];
    [fileManager createDirectoryAtURL:cacDirURL withIntermediateDirectories:YES attributes:nil error:nil];

    
    for (NSString *resourceURLStr in resourceArray) {
        NSLog(@"cacheDirURL is %@",cacDirURL);
        NSURL *cacdstURL = [cacDirURL URLByAppendingPathComponent:resourceURLStr.lastPathComponent];
        NSLog(@"cacdstURL is %@",cacdstURL);
        NSString *fullcacURLStr = [@"file://" stringByAppendingString:resourceURLStr];
        [fileManager removeItemAtURL:cacdstURL error:nil];
        NSError * error = nil;
        [fileManager copyItemAtURL:[NSURL URLWithString:fullcacURLStr] toURL:cacdstURL error:&error];
        self.bakURL = cacDirURL;
    }
        self.resourceURL = temDirURL;
    
    if (self.htmlURL == nil) {
        NSLog(@"html未找到");
    }
    
}



- (NSArray*) allFilesAtPath:(NSString*) dirString {
    
    NSError *error = [[NSError alloc] init];
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:&error];
    
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
    NSLog(@"\npath%@\n",self.wwwURL.path);
    
    if ([self differFromBundle]) {
        NSLog(@"资源有不同");
        NSLog(@"wwwurl is %@, bak is %@\n",self.wwwURL,self.bakURL);
        NSString *wwwPath = [self.wwwURL path];
        NSError *error = nil;
        [[NSFileManager defaultManager]removeItemAtPath:wwwPath error:&error];
//        [[NSFileManager defaultManager]ItemAtURL:self.bakURL toURL:self.wwwURL error:&error];
        [[NSFileManager defaultManager]copyItemAtURL:self.bakURL toURL:self.wwwURL error:nil];
           }
    
    else{
        
        NSLog(@"无更新。");
    }
    
//    检查temp的www文件夹中的文件，和bundle中的www文件夹对比。
//    如果没有区别，什么都不做。
//    如果有区别，进行还原。
    
}

-(BOOL)differFromBundle{
    BOOL result = nil;
//        NSString *fullStr = [@"file://" stringByAppendingString:resourceStr];
        NSString *cachePath = NSTemporaryDirectory();
//        NSString *cachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fullcacPath = [cachePath stringByAppendingPathComponent:@"www/"];
        NSString *bdPath = [[NSBundle mainBundle] bundlePath];
        NSString *fullbdPath = [bdPath stringByAppendingPathComponent:@"www/"];

        NSArray *cacArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullcacPath error:nil];
        NSArray *bdArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullbdPath error:nil];
        if (bdArray.count != cacArray.count) {
            NSLog(@"文件有更新！");
            result = YES;
        }
        else{
            result = NO;
        }
 
    return result;
//   遍历bundle中的www文件夹，和cache中的www对比，如果文件内容不同，返回yes，如果没有区别返回no。
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
