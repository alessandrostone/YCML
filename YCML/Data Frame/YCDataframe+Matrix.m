//
//  YCDataframe+Matrix.m
//  YCML
//
//  Created by Ioannis (Yannis) Chatzikonstantinou on 29/3/15.
//  Copyright (c) 2015 Ioannis (Yannis) Chatzikonstantinou. All rights reserved.
//
// This file is part of YCML.
//
// YCML is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// YCML is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with YCML.  If not, see <http://www.gnu.org/licenses/>.

// References for this document:
// http://stackoverflow.com/questions/6720191/reverse-nsstring-text

#import "YCDataframe+Matrix.h"
@import YCMatrix;

@implementation YCDataframe (Matrix)

+ (instancetype)dataframeWithMatrix:(Matrix *)input conversionArray:(NSArray *)array
{
    YCDataframe *newDataframe = [YCDataframe dataframe];
    for (NSString *attribute in array)
    {
        [newDataframe addBlankAttributeWithIdentifier:attribute];
    }
    [newDataframe setDataWithMatrix:input conversionArray:array];
    return newDataframe;
}

- (Matrix *)getMatrixUsingConversionArray:(NSArray *)conversionArray
{
    NSUInteger sampleCount = [self dataCount];
    if (sampleCount == 0) return nil;
    Matrix *convertedMatrix = [Matrix matrixOfRows:0 Columns:(int)sampleCount];
    for (id element in conversionArray)
    {
        if ([element isKindOfClass:[NSString class]])
        {
            NSString *label = element;
            Matrix *rowMatrix = [Matrix matrixOfRows:1 Columns:(int)sampleCount];
            int iter = 0;
            for (id val in [self->_data objectForKey:label])
            {
                [rowMatrix setValue:[val doubleValue] Row:0 Column:iter++];
            }
            convertedMatrix = [convertedMatrix appendRow:rowMatrix];
        }
        else if ([element isKindOfClass:[NSDictionary class]])
        {
            NSString *label = element[@"label"];
            NSOrderedSet *classes = element[@"classes"];
            NSUInteger count = [classes count];
            NSMutableDictionary *newRows = [NSMutableDictionary dictionary];
            for (int i=0; i<count; i++)
            {
                newRows[classes[i]] = [Matrix matrixOfRows:1 Columns:(int)sampleCount];
            }
            int iter = 0;
            for (id class in [self->_data objectForKey:label])
            {
                [newRows[class] setValue:1 Row:0 Column:iter++];
            }
            for (id class in classes)
            {
                convertedMatrix = [convertedMatrix appendRow:newRows[class]];
            }
        }
        else
        {
            // Exception
        }
        
    }
    return convertedMatrix;
}

- (NSArray *)conversionArray
{
    NSMutableArray *conversionArray = [NSMutableArray array];
    for (NSString *label in [self->_data allKeys])
    {
        if ([self.attributeTypes[label] intValue] == Ordinal)
        {
            [conversionArray addObject:label];
        }
        else
        {
            [conversionArray addObject:@{@"label" : label,
                                         @"classes" : [self classesForAttribute:label]}];
        }
    }
    return conversionArray;
}

- (void)setDataWithMatrix:(Matrix *)inputMatrix conversionArray:(NSArray *)conversionArray
{
    int sampleCount = inputMatrix->columns;
    NSUInteger attributeCount = MIN(inputMatrix->rows, [conversionArray count]);
    NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
    int iter = 0;
    for (id element in conversionArray)
    {
        NSMutableArray *attributeSamples = [NSMutableArray array];
        if ([element isKindOfClass:[NSString class]])
        {
            NSString *label = element;
            for (int i=0; i<sampleCount; i++)
            {
                double value = [inputMatrix valueAtRow:iter Column:i];
                [attributeSamples addObject:@(value)];
            }
            [convertedDictionary setValue:attributeSamples forKey:label];
            if (++iter >= attributeCount)
            {
                // exception
            }
        }
        else if ([element isKindOfClass:[NSDictionary class]])
        {
            NSString *label = element[@"label"];
            NSOrderedSet *classes = element[@"classes"];
            NSUInteger count = [classes count];
            Matrix *subset = [inputMatrix matrixWithRowsInRange:NSMakeRange(iter, count)];
            for (int i=0; i<sampleCount; i++)
            {
                int largestIndex = [self indexOfLargestValueIn:[subset getRow:i]];
                [attributeSamples addObject:classes[largestIndex]];
            }
            [convertedDictionary setValue:attributeSamples forKey:label];
            iter += count;
            if (iter >= attributeCount)
            {
                // exception
            }
        }
        else
        {
            // exception
        }
        
    }
    _data = convertedDictionary;
}

- (int)indexOfLargestValueIn:(Matrix *)values
{
    NSUInteger index = -1;
    double value = DBL_MIN;
    for (NSUInteger i=0, j=[values count]; i<j; i++)
    {
        if (values->matrix[i] > value)
        {
            index = i;
            value = values->matrix[i];
        }
    }
    return (int)index;
}

- (NSString *)generateID
{
    return [self encode:arc4random() % 1000000000];
}

- (NSString *)encode:(int)num
{
    NSString * alphabet = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString * precursor = [NSMutableString stringWithCapacity:3];
    
    while (num > 0)
    {
        [precursor appendString:[alphabet substringWithRange:NSMakeRange( num % 62, 1 )]];
        num /= 62;
    }
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[precursor length]];
    
    [precursor enumerateSubstringsInRange:NSMakeRange(0,[precursor length])
                                  options:(NSStringEnumerationReverse |NSStringEnumerationByComposedCharacterSequences)
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                   [reversedString appendString:substring];
                               }];
    return reversedString;
}

@end
