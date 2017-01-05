//
//  Lame2mp3Tool.h
//  record2mp3demo
//
//  Created by mba on 16/10/17.
//  Copyright © 2016年 mbalib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lame2mp3Tool : NSObject
+ (void)transformCAFPath:(NSURL *)cafPath  ToMP3:(NSURL *)mp3Path;
@end
