// FixAPI.h : Replacing CRT APIs with generic text versions
// Copyright (c) December 2007, Mihai Nita
//

#ifndef __FIXAPI_H__
#define __FIXAPI_H__
#pragma once

void initApiTables( void );
int isSuspectExpliciteAPI( const char * const szApiToCheck );
const char * const fixBadApi( const char * const szApiToCheck, int *toCheck );

#endif // __FIXAPI_H__
