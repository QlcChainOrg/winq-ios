//
//  Bit.h
//  Vite-keystore
//
//  Created by Water on 2018/9/20.
//

@interface QLCMnemonicBit : NSObject

+ (NSData *) entropyFromWords:(NSArray*)words wordLists:(NSArray *)wordList ;

@end
