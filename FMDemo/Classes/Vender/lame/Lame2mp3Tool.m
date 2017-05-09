//
//  Lame2mp3Tool.m
//  record2mp3demo
//
//  Created by mba on 16/10/17.
//  Copyright © 2016年 mbalib. All rights reserved.
//

#import "Lame2mp3Tool.h"
#import "lame.h"

@implementation Lame2mp3Tool{

    NSURL* recordUrl;
    NSURL* mp3FilePath;
    NSURL* audioFileSavePath;
}
    
+ (void)transformCAFPath:(NSURL *)cafPath  ToMP3:(NSURL *)mp3Path{
//    mp3FilePath = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([[cafPath path] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[mp3Path path] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        const int samplerate = 44100;//11025
        lame_t lame = lame_init();
        
        lame_set_in_samplerate(lame, samplerate);
        lame_set_num_channels(lame,1);
        lame_set_out_samplerate(lame, samplerate);
        
        lame_set_brate(lame,32);

        lame_set_quality(lame,7); /* 2=high 5 = medium 7=low 音质*/
        lame_init_params(lame);

        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);            
            } else {
            write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",mp3Path);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mp3转化成功！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
    }
}

@end
