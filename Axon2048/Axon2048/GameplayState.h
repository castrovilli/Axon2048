//
//  GameplayState.h
//  Axon2048
//
//  Created by ROSE JEFFREY D. on 2014-04-21.
//  Copyright (c) 2014 Axon Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    BEGIN_TURN = 0,
    WAIT_FOR_USER,
    ANIMATE_MOVE_ACTIONS,
    DO_OTHER_ACTIONS
} GameplayState;
