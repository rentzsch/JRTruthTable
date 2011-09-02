// JRTruthTable.h semver:0.0.2
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/JRTruthTable

#import <Foundation/Foundation.h>

#ifndef JRYES
    #define JRYES (NSNumber*)kCFBooleanTrue
    #define JRNO  (NSNumber*)kCFBooleanFalse
    #define jrT   JRYES
    #define jrF   JRNO
#endif

extern NSString * const JRTruthTable_EndOfColumns;

@interface JRTruthTable : NSObject {
#ifndef NOIVARS
  @protected
    NSMutableArray *rows;
    NSMutableDictionary *currentConditions;
#endif
}
@property(retain, readonly) id currentState;

- (id)initWithColumnsAndRows:(id)firstColumn_, ... NS_REQUIRES_NIL_TERMINATION;

- (void)updateCondition:(NSString*)conditionName_ value:(id)value_;

@end
