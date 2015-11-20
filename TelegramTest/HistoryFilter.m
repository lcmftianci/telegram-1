//
//  HistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "HistoryFilter.h"

#import "ChatHistoryController.h"
#import "PhotoHistoryFilter.h"
#import "PhotoVideoHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "MP3HistoryFilter.h"
#import "MessageTableItem.h"
#import "SharedLinksHistoryFilter.h"
#import "ChannelImportantFilter.h"
#import "ChannelFilter.h"
#import "MessageTableItem.h"
#import "ChannelCommonFilter.h"

@interface HistoryFilter ()
@property (nonatomic,strong,readonly) TGMessageHole *botHole;
@property (nonatomic,strong,readonly) TGMessageHole *topHole;




@property (nonatomic,strong) NSMutableArray *messageItems;
@property (nonatomic,strong) NSMutableDictionary *messageKeys;
@end

@implementation HistoryFilter



-(id)initWithController:(ChatHistoryController *)controller peer:(TLPeer *)peer {
    if(self = [super init]) {
        _controller = controller;
        _peer = peer;
        _messageItems = [[NSMutableArray alloc] init];
        _messageKeys = [[NSMutableDictionary alloc] init];
        
        _nextState = ChatHistoryStateLocal;
        _prevState = ChatHistoryStateLocal;
    }
    
    return self;
}



-(int)type {
    return HistoryFilterNone;
}

+(int)type {
    return HistoryFilterNone;
}


-(BOOL)checkState:(ChatHistoryState)state next:(BOOL)next {
    return next ? _nextState == state : _prevState == state;
}

-(ChatHistoryState)stateWithNext:(BOOL)next {
    return next ? _nextState : _prevState;
}


-(void)setState:(ChatHistoryState)state next:(BOOL)next {
    if(next)
        _nextState = state;
    else
        _prevState = state;
    
    if(state == 3) {
        int bp = 0;
    }
}



-(int)min_id {
    
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0)
        return INT32_MAX;
    
    
    __block MessageTableItem *lastObject;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            lastObject = obj;
            *stop = YES;
        }
        
    }];
    
    return lastObject.message.n_id;
    
}

-(int)minDate {
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0)
        return INT32_MAX;
    
    
    __block MessageTableItem *lastObject;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            lastObject = obj;
            *stop = YES;
        }
        
    }];
    
    return lastObject.message.date ;
    
}



-(int)max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    if(allItems.count == 0) {
        if(self.controller.conversation.peer_id == _peer.peer_id && ![self isKindOfClass:[CommonMediaHistoryFilter class]])
            return self.controller.conversation.last_marked_message;
        return 0;
    }
    
    
    
    
    __block MessageTableItem *firstObject;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            firstObject = obj;
            *stop = YES;
        }
        
    }];
    
    return firstObject.message.n_id;
}

-(int)maxDate {
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0) {
        if(self.controller.conversation.peer_id == _peer.peer_id && ![self isKindOfClass:[CommonMediaHistoryFilter class]])
            return self.controller.conversation.last_marked_date;
        else
            return 0;
    }
    
    
    __block MessageTableItem *firstObject;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            firstObject = obj;
            *stop = YES;
        }
        
    }];
    
    return firstObject.message.date;
}

-(int)server_min_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    __block int msgId = 0;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        
        if(obj.message.n_id > 0 && obj.message.n_id < TGMINFAKEID)
        {
            msgId = obj.message.n_id;
            *stop = YES;
        }
        
    }];
    
    return msgId;
    
}

-(int)server_max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    __block int msgId = 1;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        
        if(obj.message.n_id > 0 && obj.message.n_id < TGMINFAKEID)
        {
            msgId = obj.message.n_id;
            *stop = YES;
        }
        
    }];
    
    return msgId;
    
}


-(NSArray *)selectAllItems {
    
    NSArray *memory = [self sortItems:_messageItems];
    
    return memory;
}


-(NSArray *)sortItems:(NSArray *)sort {
    
    return [sort sortedArrayUsingComparator:^NSComparisonResult(MessageTableItem *obj1, MessageTableItem *obj2) {
        
        return (obj1.message.date < obj2.message.date ? NSOrderedDescending : (obj1.message.date > obj2.message.date ? NSOrderedAscending : (obj1.message.n_id < obj2.message.n_id ? NSOrderedDescending : NSOrderedAscending)));
    }];
}


-(int)posAtMessage:(TL_localMessage *)message {
    
    
    NSArray *memoryItems = [self selectAllItems];
    
    
    int pos = 0;
    if(memoryItems.count > 0) {
        pos = [self posInArray:memoryItems date:message.date n_id:message.n_id];
    }
    
    return pos;
}

-(int)selectLimit {
    return (int) _controller.selectLimit;
}

-(int)posInArray:(NSArray *)list date:(int)date n_id:(int)n_id {
    int pos = 0;
    
    
    while (pos+1 < list.count &&
           ([((MessageTableItem *)list[pos]).message date] > date ||
            ([((MessageTableItem *)list[pos]).message date] == date && [((MessageTableItem *)list[pos]).message n_id] > n_id)))
        pos++;
    
    return pos;
}


-(NSArray *)proccessResponse:(NSArray *)result state:(ChatHistoryState)state next:(BOOL)next {
    
    NSArray *converted = [self filterAndAdd:result latest:NO];
    
    converted = [self sortItems:converted];
    
    state = next && state == ChatHistoryStateRemote && (self.controller.conversation.type == DialogTypeSecretChat || self.controller.conversation.type == DialogTypeBroadcast) ? ChatHistoryStateFull : state;
    
    
   [self setState:state next:next];
    
    
    TL_conversation *conversation = [[DialogsManager sharedManager] find:self.peer_id];
    
    if(self.prevState != ChatHistoryStateFull && conversation.top_message > 0 && conversation.top_message <= self.server_max_id)
        [self setState:ChatHistoryStateFull next:NO];
    
    return converted;
}


-(NSArray *)filterAndAdd:(NSArray *)items latest:(BOOL)latest {
    
    __block  NSMutableArray *filtred = [[NSMutableArray alloc] init];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        NSMutableArray *filterItems = [self messageItems];
        NSMutableDictionary *filterKeys = [self messageKeys];
        
        BOOL needAdd = [filterItems indexOfObject:obj] == NSNotFound;
        
        if((obj.message.peer_id == self.peer_id) && ((obj.message.filterType & [self type]) > 0 && (_prevState == ChatHistoryStateFull || !latest))) {
            
            if(obj.message.n_id != 0) {
                id saved = filterKeys[@(obj.message.n_id)];
                if(!saved) {
                    filterKeys[@(obj.message.n_id)] = obj;
                    
                } else {
                    needAdd = NO;
                }
            }
            
            if(needAdd) {
                [filterItems addObject:obj];
                
                [filtred addObject:obj];
            }
        }
    }];

     return filtred;
    
}


-(NSArray *)storageRequest:(BOOL)next state:(ChatHistoryState *)state {
    
    
    int maxId = next ? self.min_id : INT32_MAX;
    int minId = next ? 0 : self.max_id;
    
    int maxDate = next ? self.minDate : INT32_MAX;
    int minDate = next ? 0 : self.maxDate;
    
    
    TGHistoryResponse *response = [[Storage manager] loadMessages:self.peer_id min_id:minId max_id:maxId minDate:minDate maxDate:maxDate limit:(int)self.selectLimit next:next filterMask:[self type] isChannel:[self.peer isKindOfClass:[TL_peerChannel class]]];
    
    [self setHole:response.hole withNext:next];
    
        
    *state = response.result.count < self.selectLimit || [self confirmHoleWithNext:next] ? ChatHistoryStateRemote : ChatHistoryStateLocal;
    
        
    return response.result;
    
}

-(void)request:(BOOL)next callback:(void (^)(NSArray *response,ChatHistoryState state))callback {
    
    if([self checkState:ChatHistoryStateRemote next:next]) {
        
        [self remoteRequest:next hole:[self holeWithNext:next] callback:callback];
        
    } else {
        
        ChatHistoryState state;
                
        callback([self storageRequest:next state:&state],state);
        
    }
    
}


-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    int maxId = next ? self.server_min_id : self.server_max_id;
    
    if(hole != nil && !next) {
        maxId = hole.min_id;
    } else if(hole != nil && next) {
        maxId = hole.max_id;
    }
    
    [self remoteRequest:next max_id:maxId hole:hole callback:callback];
    
}

-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
   int source_id = next ? self.server_min_id : self.server_max_id;
    
    if(!_controller)
        return;

    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[_peer inputPeer] offset_id:source_id add_offset:next ||  source_id == 0 ? 0 : -(int)self.selectLimit limit:(int)self.selectLimit max_id:next ? 0 : INT32_MAX min_id:0] successHandler:^(RPCRequest *request, TL_messages_channelMessages * response) {
        
        
        [SharedManager proccessGlobalResponse:response];
        
        
        NSArray *messages = [[response messages] copy];
        
        [self fillGroupHoles:messages bottom:!next];
        
        [self setHole:[self proccessAndGetHoleWithHole:hole next:next messages:messages] withNext:next];
        
        if(callback) {
            ChatHistoryState state = hole && ![self holeWithNext:next] ? ChatHistoryStateLocal : messages.count < self.selectLimit && !hole && ![self holeWithNext:next] ? ChatHistoryStateFull : ChatHistoryStateRemote;
            
            callback(messages,state);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && self.controller) {
            callback(nil,ChatHistoryStateFull);
        }
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
}

-(BOOL)confirmHoleWithNext:(BOOL)next {
    return [self holeWithNext:next] && ( next ? [self holeWithNext:next].max_id <= self.max_id : [self holeWithNext:next].max_id > [self holeWithNext:next].max_id);
}

-(int)additionSenderFlags {
    return 0 ;
}


-(int)peer_id {
    return _peer.peer_id;
}

-(TGMessageHole *)holeWithNext:(BOOL)next {
    return next ? _topHole : _botHole;
}

-(void)setHole:(TGMessageHole *)hole withNext:(BOOL)next {
    if(next)
        _topHole = hole;
    else
        _botHole = hole;
}

-(TGMessageHole *)proccessAndGetHoleWithHole:(TGMessageHole *)hole next:(BOOL)next messages:(NSArray *)messages {
    
    TGMessageHole *nHole;

    
    if(hole != nil) {
        
        int min = hole.min_id;
        int max = hole.max_id;
        
        if(messages.count > 0)
        {
            TL_localMessage *first = [messages firstObject];
            TL_localMessage *last = [messages lastObject];
            
            max = first.n_id;
            min = last.n_id;
        }
        
        
        
        nHole = [[TGMessageHole alloc] initWithUniqueId:hole.uniqueId peer_id:hole.peer_id min_id:next ? hole.min_id : max max_id:next ? min : hole.max_id date:hole.date count:0];
        
        
        if(nHole.min_id >= nHole.max_id) {
           
           [nHole remove];
            nHole = nil;
        } else
            [nHole save];
        
        
    }
    
    return nHole;
}


-(void)fillGroupHoles:(NSArray *)messages bottom:(BOOL)bottom {
    
}

-(void)dealloc {
    
    if(self.request != nil) {
        [self.request cancelRequest];
        self.request = nil;
    }
    
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterEmpty create];
}

@end
