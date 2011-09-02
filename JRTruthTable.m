// JRTruthTable.m semver:0.0.3
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/JRTruthTable

#import "JRTruthTable.h"

NSString * const JRTruthTable_EndOfColumns = @"JRTruthTable_EndOfColumns";
NSString * const JRTruthTable_CurrentStateChangedNotification = @"JRTruthTable_CurrentStateChangedNotification";
NSString * const JRTruthTable_CurrentStateChangedNotification_PreviousState = @"JRTruthTable_CurrentStateChangedNotification_PreviousState";

@interface JRTruthTable ()
@property(retain) NSMutableArray *rows;
@property(retain) NSMutableDictionary *currentConditionsCache;
@end

@interface JRTruthTable_Row : NSObject {
#ifndef NOIVARS
  @protected
    NSMutableDictionary *conditions;
    id state;
#endif
}
@property(retain) NSMutableDictionary *conditions;
@property(retain) id state;
@end

@implementation JRTruthTable
@synthesize conditionNames;
@synthesize rows;
@synthesize currentConditionsCache;
@synthesize conditionSource;

- (id)initWithConditionSource:(id<JRTruthTableConditionSource>)conditionSource_ columnsAndRows:(id)firstColumn_, ... {
    self = [super init];
    
    NSParameterAssert(firstColumn_);
    
    if (self) {
        rows = [[NSMutableArray alloc] init];
        currentConditionsCache = [[NSMutableDictionary alloc] init];
        conditionSource = conditionSource_;
        
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:firstColumn_];
        
        NSUInteger endOfColumnArgIndex = NSNotFound;
        {
            id arg;
            NSUInteger vargIndex = 0;
            
            va_list vargs;
            va_start(vargs, firstColumn_);
            while ((arg = va_arg(vargs, id))) {
                if (arg == JRTruthTable_EndOfColumns) {
                    assert(endOfColumnArgIndex == NSNotFound);
                    endOfColumnArgIndex = vargIndex;
                } else {
                    [args addObject:arg];
                }
                vargIndex++;
            }
            va_end(vargs);
        }
        assert(endOfColumnArgIndex != NSNotFound);
        
        conditionNames = [[args subarrayWithRange:NSMakeRange(0, endOfColumnArgIndex+1)] retain];
        NSUInteger length = [args count] - endOfColumnArgIndex - 1;
        NSArray *cells = [args subarrayWithRange:NSMakeRange(endOfColumnArgIndex+1, length)];
        
        NSUInteger columnIndex = 0, stateNameColumnIndex = [conditionNames count];
        
        JRTruthTable_Row *row = [[[JRTruthTable_Row alloc] init] autorelease];
        for (id cell in cells) {
            if (columnIndex == stateNameColumnIndex) {
                row.state = cell;
                [rows addObject:row];
                row = [[[JRTruthTable_Row alloc] init] autorelease];
                columnIndex = 0;
            } else {
                [row.conditions setObject:cell forKey:[conditionNames objectAtIndex:columnIndex]];
                columnIndex++;
            }
        }
        
        [self reload];
    }
    
    return self;
}

- (void)dealloc {
    [conditionNames release];
	[rows release];
	[currentConditionsCache release];
	[super dealloc];
}

- (id)currentState {
    for (JRTruthTable_Row *row in rows) {
        if ([row.conditions isEqualToDictionary:currentConditionsCache]) {
            return row.state;
        }
    }
    return nil;
}

- (BOOL)reloadCondition:(NSString*)conditionName_ postStateChangedNotification:(BOOL)postNotification_ {
    BOOL conditionChanged = NO;
    id newCondition = [conditionSource truthTable:self currentValueOfCondition:conditionName_];
    if (![[currentConditionsCache objectForKey:conditionName_] isEqual:newCondition]) {
        [currentConditionsCache setObject:newCondition forKey:conditionName_];
        conditionChanged = YES;
        if (postNotification_) {
            [[NSNotificationCenter defaultCenter] postNotificationName:JRTruthTable_CurrentStateChangedNotification
                                                                object:self];
        }
    }
    return conditionChanged;
}

- (void)reloadConditions:(NSArray*)conditionNames_ {
    NSParameterAssert(conditionSource);
    
    id oldCurrentState = [[[self currentState] retain] autorelease];
    for (NSString *conditionName in conditionNames_) {
        [currentConditionsCache setObject:[conditionSource truthTable:self currentValueOfCondition:conditionName]
                                   forKey:conditionName];
    }
    if (oldCurrentState && ![[self currentState] isEqual:oldCurrentState]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JRTruthTable_CurrentStateChangedNotification
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:oldCurrentState
                                                                                               forKey:JRTruthTable_CurrentStateChangedNotification_PreviousState]];
    }
}

- (void)reload {
    [self reloadConditions:conditionNames];
}

- (void)reloadCondition:(NSString*)conditionName_ {
    [self reloadConditions:[NSArray arrayWithObject:conditionName_]];
}

@end

@implementation JRTruthTable_Row
@synthesize conditions;
@synthesize state;

- (id)init {
    self = [super init];
    if (self) {
        conditions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
	[conditions release];
	[state release];
	[super dealloc];
}
@end

@implementation JRTruthTableDictionaryConditionSource
@synthesize dictionary;

- (void)dealloc {
	[dictionary release];
	[super dealloc];
}

- (id)truthTable:(JRTruthTable*)truthTable_ currentValueOfCondition:(NSString*)conditionName_ {
    return [dictionary objectForKey:conditionName_];
}

@end
