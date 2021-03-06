//
//  YCBackPropTrainer.m
//  YCML
//
//  Created by Ioannis (Yannis) Chatzikonstantinou on 21/3/15.
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

#import "YCRpropTrainer.h"
#import "YCBackPropTrainer.h"
#import "YCRProp.h"

@implementation YCRpropTrainer

-(id)init
{
    if (self = [super init])
    {
        self.settings[@"Hidden Layer Count"] = @1;
        self.settings[@"Hidden Layer Size"]  = @5;
        self.settings[@"Lambda"]             = @0.0001;
        self.settings[@"Iterations"]         = @500;
        self.settings[@"Target"]             = @-1;
        [self.settings removeObjectForKey:@"Alpha"];
    }
    return self;
}

- (Class)optimizerClass
{
    return [YCRProp class];
}

@end
