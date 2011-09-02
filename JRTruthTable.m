// JRTruthTable.m semver:0.0.2
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/JRTruthTable

#import "JRTruthTable.h"

@interface JRTruthTable ()
@property(retain) NSMutableArray *rows;
@property(retain) NSMutableDictionary *currentConditions;
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

NSString * const JRTruthTable_EndOfColumns = @"JRTruthTable_EndOfColumns";

@implementation JRTruthTable
@synthesize rows;
@synthesize currentConditions;

- (id)initWithColumnsAndRows:(id)firstColumn_, ... {
    self = [super init];
    
    NSParameterAssert(firstColumn_);
    
    if (self) {
        rows = [[NSMutableArray alloc] init];
        
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
        
        NSArray *columns = [args subarrayWithRange:NSMakeRange(0, endOfColumnArgIndex+1)];
        NSUInteger length = [args count] - endOfColumnArgIndex - 1;
        NSArray *cells = [args subarrayWithRange:NSMakeRange(endOfColumnArgIndex+1, length)];
        
        NSUInteger columnIndex = 0, stateNameColumnIndex = [columns count];
        
        JRTruthTable_Row *row = [[[JRTruthTable_Row alloc] init] autorelease];
        for (id cell in cells) {
            if (columnIndex == stateNameColumnIndex) {
                row.state = cell;
                [rows addObject:row];
                row = [[[JRTruthTable_Row alloc] init] autorelease];
                columnIndex = 0;
            } else {
                [row.conditions setObject:cell forKey:[columns objectAtIndex:columnIndex]];
                columnIndex++;
            }
        }
        
        JRTruthTable_Row *firstRow = [rows objectAtIndex:0];
        currentConditions = [firstRow.conditions mutableCopy];
    }
    
    return self;
}

- (void)dealloc {
	[rows release];
	[currentConditions release];
	[super dealloc];
}

- (void)updateCondition:(NSString*)conditionName_ value:(id)value_ {
    [currentConditions setObject:value_ forKey:conditionName_];
}

- (id)currentState {
    for (JRTruthTable_Row *row in rows) {
        if ([row.conditions isEqualToDictionary:currentConditions]) {
            return row.state;
        }
    }
    return nil;
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