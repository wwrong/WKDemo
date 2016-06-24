//
//  FileManager.h
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/23.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject



-(BOOL)translateFileFromURLorStringPath:(NSObject *)startingPoint toURLorStringPath:(NSObject *)destinationPoint ifNeedCheckingUpdate:(BOOL)needChecking;


@end






//拷文件或者文件夹。    ./
//备份功能。 备份一个bak到cache    ./

//错误处理。如果拷贝中出现错误，删除正在拷贝的文件。如果备份出现错误，删除当前正在拷贝的备份。    ./

//更新功能。如果bundle中的这个文件更新了，检查副本，如果相同，什么都不做。如果不同，从bundle再次拷贝。如果拷贝失败，从备份还原。  ./






//只留下一个方法。参数直接使用NSObject类型，然后进行类型判断，如果是NSString类型，可以直接转换成url.     /.

//使用MD5.   对源地址和目标地址的文件/文件夹进行md5，然后就可以进行文件是否相同的检查。

//没必要使用任何属性。    ->使用md5来确定一切。





//只留下一个方法。check加入方法中，让使用者选择。

//整合判断方法，NSObject判断，输出URL。

//利用error参数而不是返回值来判断操作是否成功，每次置空error。
