// JRTruthTable.h semver:0.0.4
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/JRTruthTable

#import <Foundation/Foundation.h>

extern NSString * const JRTruthTable_EndOfColumns;
extern NSString * const JRTruthTable_CurrentStateChangedNotification;
extern NSString * const JRTruthTable_CurrentStateChangedNotification_PreviousState;

@class JRTruthTable;
@protocol JRTruthTableConditionSource <NSObject>
@required
- (id)truthTable:(JRTruthTable*)truthTable_ currentValueOfCondition:(NSString*)conditionName_;
@end


@interface JRTruthTable : NSObject {
#ifndef NOIVARS
  @protected
    NSArray                         *conditionNames;
    NSMutableArray                  *rows;
    NSMutableDictionary             *currentConditionsCache;
    id<JRTruthTableConditionSource> conditionSource;
#endif
}
@property(assign)           id<JRTruthTableConditionSource> conditionSource;
@property(retain, readonly) NSArray                         *conditionNames;
@property(retain, readonly) id                              currentState;

- (id)initWithConditionSource:(id<JRTruthTableConditionSource>)conditionSource_ columnsAndRows:(id)firstColumn_, ... NS_REQUIRES_NIL_TERMINATION;

- (void)reload;
- (void)reloadCondition:(NSString*)conditionName_;

- (void)addStateChangeObserver:(id)observer_ selector:(SEL)selector_;
@end


@interface JRTruthTableDictionaryConditionSource : NSObject <JRTruthTableConditionSource> {
#ifndef NOIVARS
  @protected
    NSDictionary *dictionary;
#endif
}
@property(retain) NSDictionary *dictionary;

@end


#ifndef JRYES
    #define JRYES (NSNumber*)kCFBooleanTrue
    #define JRNO  (NSNumber*)kCFBooleanFalse
    #define jrT   JRYES
    #define jrF   JRNO
#endif
