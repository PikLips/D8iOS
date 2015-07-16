//
//  Developer.h
//  Drupal8iOS
//
//  Created by Michael Smith on 7/15/15.
//  Copyright (c) 2015 PikLips. All rights reserved.
//
/* MAS:
 *     This is to support development of the project by managing the log and error
 *     messages.  It allows for a lot of overhead messaging in development while
 *     shutting down the noise as it gets closer to production.
 */

extern int d8FlagLevel;     // MAS: a nasty global, gods of OOP forgive me

#define D8FLAGDEBUG     3   // MAS: set to this in code creation
#define D8FLAGWARN      2   // MAS: set to this in test
#define D8FLAGERROR     1   // MAS: set to this in beta
#define D8PRODUCTION    0   // MAS: set to this when it goes to Apple

#ifndef Drupal8iOS_Developer_h
#define Drupal8iOS_Developer_h

#define D8D(FMT,...) if(d8FlagLevel < D8FLAGDEBUG) ; else  NSLog(@"DEBUG: " FMT, ##__VA_ARGS__)
#define D8W(FMT,...) if(d8FlagLevel < D8FLAGWARN)  ; else  NSLog(@"WARN: " FMT, ##__VA_ARGS__)
#define D8E(FMT,...) if(d8FlagLevel < D8FLAGERROR) ; else  NSLog(@"ERROR: " FMT, ##__VA_ARGS__)
#define D8P(FMT,...) if(d8FlagLevel == D8PRODUCTION) NSLog(@"D8iOS: " FMT, ##__VA_ARGS__)

#endif
