 //
//  Board.m
//  Axon2048
//
//  Created by ZINGER JAMES J. on 2014-04-16.
//  Copyright (c) 2014 Axon Interactive. All rights reserved.
//

#import "Board.h"
#import "CardAction.h"

@implementation Board

NSMutableArray* _Cards;
NSMutableArray* _TileGrid;
int _Size;

-(id) initWithGridSize:(int)Size
{
    self = [super init];
    
    _Size = Size;
    
    _score = 0;
    
    _TileGrid = [[NSMutableArray alloc] initWithCapacity: Size];
    for (int i = 0; i < Size; i++)
    {
        [_TileGrid addObject:[[NSMutableArray alloc] initWithCapacity: Size]];
        for (int j = 0; j < Size; j++)
        {
            
            TileIndex *index = [[TileIndex alloc] init];
            index.x = i;
            index.y = j;
            _TileGrid[i][j] = [[Tile alloc]initAtIndex:index];
        }
    }
    
    _Cards = [[NSMutableArray alloc] initWithCapacity:Size*Size];
    
    return self;
}

- (BOOL)addCardAtIndex:(TileIndex*)Index
{
    Tile* tile = [self getTileAtIndex:Index];
    
    if (tile.Card != nil)
    {
        return false;
    }
    
    Card* card = [[Card alloc] initWithValue:2 AndTile:tile];
    
    [_Cards addObject:card];
    
    tile.Card = card;
    
    return true;
}

- (TileIndex*) addCardAtRandomIndex
{
    TileIndex *index = [[TileIndex alloc]init];
    
    NSMutableArray* freeTiles = [self getEmptyTiles];
    
    if ([freeTiles count] == 0)
    {
        index.x = -1;
        index.y = -1;
        return index;
    }
    
    int random = arc4random() % [freeTiles count];
    
    Tile* tile = freeTiles[random];

    Card* newCard = [[Card alloc] initWithValue:2 AndTile:tile];
    
    [_Cards addObject:newCard];
    
    tile.Card = newCard;
    
    NSLog([NSString stringWithFormat:@"Random Index: %d - %d", tile.Index.x, tile.Index.y ]);
    
    return tile.Index;
}

- (NSMutableArray*) Update:(DIRECTION)Direction
{
    NSMutableArray* array;
    
    switch (Direction) {
        case UP:
            array = [self UpdateUp];
            break;
        
        case DOWN:
            array = [self UpdateDown];
            break;
            
        case RIGHT:
            array = [self UpdateRight];
            break;
            
        case LEFT:
            array = [self UpdateLeft];
            break;
    }
    
    // If no actions are being returned, we need to clear the merge flags
    if ( [array count] == 0 )
    {
        [self ClearMerges];
    }
    
    return array;
}

-(Tile *)getTileAtIndex:(TileIndex*)Index
{
    Tile* tile = nil;
    
    if (![self isTileIndexValid:Index])
    {
        return tile;
    }
    
    return _TileGrid[Index.x][Index.y];
}

// Private functions
-(BOOL) isTileIndexValid:(TileIndex*)Index
{
    if (Index.x < 0 || Index.x >= _Size || Index.y < 0 || Index.y >= _Size)
    {
        return false;
    }
    
    return true;
}

-(NSMutableArray*) getEmptyTiles
{
    NSMutableArray* tileArray = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < _Size; x++)
    {
        for (int y = 0; y < _Size; y++)
        {
            if ([_TileGrid[x][y] Card] == nil)
                 [tileArray addObject:_TileGrid[x][y]];
        }
    }
    
    return tileArray;
}

- (BOOL) checkIfBoardIsFull
{
    return ([_Cards count] == _Size*_Size);
}

// Update
// Forward   0    -  Size
// Backward Size  -  0
// Row - X
// Col - Y

- (NSMutableArray*) UpdateUp
{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
 
    // Row Forward
    // Col Forward
    for (int y = 0; y < _Size; y++)
    {
        for (int x = 0; x < _Size; x++)
        {
            Tile* tile = _TileGrid[x][y];
            if ([tile Card] == nil)
            {
                continue;
            }
            
            Tile* tileContext = [tile getNeightbourInDirection: UP];
            
            [self CompareTile:tile WithTile:tileContext ToArray:changes];
        }
    }
    
    return changes;
}

- (NSMutableArray*) UpdateDown
{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
    
    // Row Backward
    // Col Backward
    for (int y = _Size - 1; y >= 0; y--)
    {
        for (int x = 0; x < _Size; x++)
        {
            Tile* tile = _TileGrid[x][y];
            if ([tile Card] == nil)
            {
                continue;
            }
            
            Tile* tileContext = [tile getNeightbourInDirection: DOWN];
            
            [self CompareTile:tile WithTile:tileContext ToArray:changes];
        }
    }
    return changes;
}

- (NSMutableArray*) UpdateLeft
{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
    
    // Col Forward
    // Row Forward
    for (int x = 0; x < _Size; x++)
    {
        for (int y = 0; y < _Size; y++)
        {
            Tile* tile = _TileGrid[x][y];
            if ([tile Card] == nil)
            {
                continue;
            }
            
            Tile* tileContext = [tile getNeightbourInDirection: LEFT];
            
            [self CompareTile:tile WithTile:tileContext ToArray:changes];
        }
    }
    
    return changes;
}

- (NSMutableArray*) UpdateRight
{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
   
    //Col Backward
    //Row Forward
    for (int x = _Size - 1; x >= 0; x--)
    {
        for (int y = 0; y < _Size; y++)
        {
            Tile* tile = _TileGrid[x][y];
            if ([tile Card] == nil)
            {
                continue;
            }
            
            Tile* tileContext = [tile getNeightbourInDirection: RIGHT];
            [self CompareTile:tile WithTile:tileContext ToArray:changes];
        }
    }
    
    return changes;
}

- (void) ClearMerges
{
    for (int y = 0; y < _Size; y++)
    {
        for (int x = 0; x < _Size; x++)
        {
            Tile* tile = _TileGrid[ x ][ y ];
            if ( [tile Card] != nil )
            {
                tile.Card.HasMerged = NO;
            }
        }
    }
}

- (void) CompareTile: (Tile*) Tile1 WithTile:(Tile*) Tile2 ToArray:(NSMutableArray*) changes
{
    if (Tile2 == nil)
        return;
    
    Card* card = [Tile1 Card];
    
    Card* targetCard = [Tile2 Card];
    
    // Move up one index
    if ( targetCard == nil)
    {
        
        card.Tile = Tile2;
        Tile2.Card = card;
        Tile1.Card = nil;
        
        CardAction* action  = [[CardAction alloc] init];
        action.lookupIndex  = Tile1.Index;
        action.shouldDelete = NO;
        action.updatedValue     = card.Value;
        action.updatedIndex     = Tile2.Index;
        [changes addObject:action];
        
    }
    else if ( !( [targetCard HasMerged] || [card HasMerged] ) && [targetCard Value] == [card Value] )
    {
        
        [targetCard doubleValue];
        _score += [targetCard Value];
        
        CardAction* action1  = [[CardAction alloc] init];
        action1.lookupIndex  = Tile1.Index;
        action1.updatedIndex     = Tile2.Index;
        action1.updatedValue     = card.Value;
        action1.shouldDelete = YES;
        [changes addObject:action1];
        
        Tile1.Card = nil;
        [_Cards removeObject:card];
        
        CardAction* action2  = [[CardAction alloc]init];
        action2.lookupIndex  = Tile2.Index;
        action2.updatedIndex = Tile2.Index;
        action2.updatedValue = targetCard.Value;
        action2.shouldDelete = NO;
        [changes addObject:action2];
        
    }

}


@end
