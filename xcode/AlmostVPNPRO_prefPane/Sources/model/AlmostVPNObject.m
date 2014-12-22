//
//  AlmostVPNObject.m
//  AlmostVPNPRO_model
//
//  Created by andrei tchijov on 11/4/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <assert.h>
#import "AlmostVPNObject.h"

#define _CLASS_NAME_KEY_	@"class-name"

static NSMutableDictionary* _objectsByUUID = nil;
static NSMutableDictionary*	_delegatesByClass = nil;

id	IGNORE_DELEGATE = nil;

@interface NSMutableDictionary (AlmostVPNObject)
	- (void) removeObjectsForKeyRecursively: (NSString*) key;
@end

@interface AlmostVPNObject (Private) 
	+ (NSMutableDictionary*)_objectsByUUID;
	+ (void) registerObject: (AlmostVPNObject*) anObject;
	+ (void) deregisterObject: (AlmostVPNObject*) anObject;
	
	- (AlmostVPNObject*) initWithUUID: (NSString*) aUUID;
	- (void) setUuid: (NSString*) aUUID;
@end
@implementation AlmostVPNObject (Private)
+ (void) initialize {
	IGNORE_DELEGATE = [[ NSObject alloc ] init ];
}

+ (NSMutableDictionary*)_objectsByUUID {
	if( _objectsByUUID == nil ) {
		_objectsByUUID = [[ NSMutableDictionary alloc ] init ];
	}
	return _objectsByUUID;
}

+ (void) registerObject: (AlmostVPNObject*) anObject {
	NSString* uuid = [ anObject uuid ];	
	assert( uuid != nil );	
	id otherObject = [[ self _objectsByUUID ] objectForKey: uuid ];	
	assert( otherObject == nil || otherObject == anObject );	
	if( otherObject == nil ) {
		NSValue* noneRetainWrapper = [ NSValue valueWithNonretainedObject: anObject ];
		[[ self _objectsByUUID ] setObject: noneRetainWrapper forKey: uuid ];
	}	
}

+ (void) deregisterObject: (AlmostVPNObject*) anObject {
	NSValue* noneRetainWrapper = [[ self _objectsByUUID ] objectForKey: [ anObject uuid ]];	
	if( noneRetainWrapper == nil ) {
		return;
	}
	AlmostVPNObject* registredObject = [ noneRetainWrapper nonretainedObjectValue ];
	if( registredObject == nil || registredObject != anObject ) {
		return;
	}
	[[ self _objectsByUUID ] removeObjectForKey: [ anObject uuid ]];
}

- (AlmostVPNObject*) initWithUUID: (NSString*) aUUID {
	[ super init ];
	_embeddedDictionary = [[ NSMutableDictionary alloc ] init ];
//	[ _embeddedDictionary setObject: @"" forKey: @"_retainCount_" ];
//	[ _embeddedDictionary setObject: [ NSNumber numberWithInt: (int)self ] forKey: @"_hash_" ];
//	[ _embeddedDictionary setObject: NSStringFromClass( [ self class ] ) forKey: @"_class_" ];
	if( aUUID != nil ) {
		[ self setUuid: aUUID ];
	}
	[ self setObject: NSStringFromClass( [ self class ] ) forKey: _CLASS_NAME_KEY_ ];
	[ AlmostVPNObject registerObject: self ];
	return self;
}

- (void) setUuid: (NSString*) aUUID {
	NSString* oldUUID = [ self uuid ];
	assert( oldUUID == nil );
	[ self setObject: aUUID forKey: _UUID_KEY_ ];
}

+ (void) dumpObjects {
	NSEnumerator* allObjects = [ _objectsByUUID objectEnumerator ];
	id object;
	NSLog( @"dumpObjects : START\n" );
	while( ( object = [ allObjects nextObject ] ) != nil ) {
		object = [ object nonretainedObjectValue ];
		NSLog( @"%@[%d]\n%@\n\n", NSStringFromClass( [ object class ] ), [ object retainCount ], [ object description ] );
	}
	NSLog( @"dumpObjects : END\n" );
}
@end

@implementation AlmostVPNObject
+ (void) reInitialize {
	if( _objectsByUUID != nil ) {
		[ _objectsByUUID release ];
	}
//	if( _delegatesByClass != nil ) {
//		[ _delegatesByClass release ];
//	}
	_objectsByUUID = nil;
//	_delegatesByClass = nil;
}

+ (AlmostVPNObject*) newObjectOfClass: (Class) aClass withUUID: (NSString*) uuid {
	AlmostVPNObject* result = [ self findObjectWithUUID: uuid ];
	if( result != nil ) {
		assert( [ result class ] == aClass );
		return result;
	}
	result = [[ aClass alloc ] initWithUUID: uuid ];
	[ result bootstrap ];
	return result;
}
	
+ (id<AlmostVPNObjectDelegate>) delegate {
	Class currentClass = self;
	id<AlmostVPNObjectDelegate> delegate = [ _delegatesByClass objectForKey: currentClass ];
	while( currentClass != nil && delegate == nil ) {
		currentClass = [ currentClass superclass ];
		delegate = [ _delegatesByClass objectForKey: currentClass ];
	}
	return delegate;
}

+ (void) setDelegate: (id<AlmostVPNObjectDelegate>) v {
	Class currentClass = self;
	@synchronized( self ) {
		if( _delegatesByClass == nil ) {
			_delegatesByClass = [[ NSMutableDictionary alloc ] init ];
		}
	}
	[ _delegatesByClass setObject: v forKey: currentClass ];
}

+ (id) performOnDelegate: (SEL) selector withObject: (id) arg1 {
	id<AlmostVPNObjectDelegate> delegate = [ self delegate ];
	if( delegate != nil && [ delegate respondsToSelector: selector ] ) {
		return [ delegate performSelector: selector withObject: arg1 ];
	} else {
		return IGNORE_DELEGATE;
	}
}
+ (id) performOnDelegate: (SEL) selector withObject: (id) arg1 withObject: (id) arg2 {
	id<AlmostVPNObjectDelegate> delegate = [ self delegate ];
	if( delegate != nil && [ delegate respondsToSelector: selector ] ) {
		return [ delegate performSelector: selector withObject: arg1 withObject: arg2 ];
	} else {
		return IGNORE_DELEGATE;
	}
}

+ (id) performOnDelegate: (SEL) selector withObject: (id) arg1 withObject: (id) arg2 withObject: (id) arg3 {
	id<AlmostVPNObjectDelegate> delegate = [ self delegate ];
	if( delegate != nil && [ delegate respondsToSelector: selector ] ) {
		NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: [ (NSObject*)delegate methodSignatureForSelector: selector ]];
		[ invocation setSelector: selector ];
		[ invocation setArgument: &arg1 atIndex: 2 ];
		[ invocation setArgument: &arg2 atIndex: 3 ];
		[ invocation setArgument: &arg3 atIndex: 4 ];
		[ invocation invokeWithTarget: delegate ];
		id result;
		[ invocation getReturnValue: &result ];
		return result;
	} else {
		return IGNORE_DELEGATE;
	}
}

- (id) performOnDelegate: (SEL) selector withObject: (id) arg1 {
	id result = IGNORE_DELEGATE;
	if( ! _delegationInProgress ) {
		_delegationInProgress = YES;
		result = [[ self class ] performOnDelegate: selector withObject: arg1 ];
		_delegationInProgress = NO;
	}
	return result;
}

- (id) performOnDelegate: (SEL) selector withObject: (id) arg1 withObject: (id) arg2 {
	id result = IGNORE_DELEGATE;
	if( ! _delegationInProgress ) {
		_delegationInProgress = YES;
		result = [[ self class ] performOnDelegate: selector withObject: arg1 withObject: arg2 ];
		_delegationInProgress = NO;
	}
	return result;
}

- (id) performOnDelegate: (SEL) selector withObject: (id) arg1 withObject: (id) arg2 withObject: (id) arg3 {
	id result = IGNORE_DELEGATE;
	if( ! _delegationInProgress ) {
		_delegationInProgress = YES;
		result =  [[ self class ] performOnDelegate: selector withObject: arg1 withObject: arg2 withObject: arg3];
		_delegationInProgress = NO;
	}
	return result;
}

+ (id) objectWithDictionary: (NSDictionary*) aDictionary {
	NSString* className = [ aDictionary objectForKey: _CLASS_NAME_KEY_ ];
	Class class = NSClassFromString( className );
	if( class == nil ) {
		return nil;
	} 
	AlmostVPNObject* result = [[ class alloc ] initWithDictionary: aDictionary ];
	return result;
}

+ (id) objectWithObject: (AlmostVPNObject*) otherObject {	
	NSMutableDictionary* aDictionary = [[ otherObject asDictionary ] mutableCopy ];
	
	[ aDictionary removeObjectsForKeyRecursively: _UUID_KEY_ ];
	[ aDictionary removeObjectsForKeyRecursively: @"parent-uuid" ];
		
	return [ self objectWithDictionary: aDictionary ];
}


- (AlmostVPNObject*) init {
	CFUUIDRef uuid = CFUUIDCreate( nil );
	NSString* uuidString = (NSString*)CFUUIDCreateString( nil, uuid );
	CFRelease( uuid );
	[ self initWithUUID: uuidString ];
	return self;
}

- (void) bootstrap {
	// Do nothing by default
}

- (void) initKeys: (NSString*[])keys fromDictionary: (NSDictionary*) aDictionary {
	for( int i = 0; keys[ i ] != nil; i++ ) {
		[ self setObject: [ aDictionary objectForKey: keys[ i ] ] forKey: keys[ i ] ];	
	}
}

- (id) initWithDictionary: (NSDictionary*) aDictionary {
	NSString* uuidString = [ aDictionary objectForKey: _UUID_KEY_ ];
	if( uuidString == nil ) {
		CFUUIDRef uuid = CFUUIDCreate( nil );
		uuidString = (NSString*)CFUUIDCreateString( nil, uuid );
		CFRelease( uuid );
	}
	
	[ self initWithUUID: uuidString ];
	
	[ self setObject: [ aDictionary objectForKey: _NAME_KEY_ ] forKey: _NAME_KEY_ ];
	
	return self;
}

- (BOOL) isEqual: (id) anotherObject {
	if( [ anotherObject isKindOfClass: [ AlmostVPNObject class ]] ) {
		return [[ self uuid ] isEqual: [ anotherObject uuid ]];
	} else {
		return nil;
	}
}

- (int) hash {
	return [[ self uuid ] hash ];
}

- (void) dealloc {
	[ AlmostVPNObject deregisterObject: self ];
	[ _embeddedDictionary release ];
	[super dealloc];
}


- (NSDictionary*) asDictionary {
	NSData* archData = [ NSKeyedArchiver archivedDataWithRootObject: _embeddedDictionary ];
	NSDictionary* unarchDic = [ NSKeyedUnarchiver unarchiveObjectWithData: archData ]; 
	return unarchDic;
}

#pragma mark Accessors:Boolean

- (BOOL) booleanValueForKey: (NSString*) key {
	id result = nil;
	result = [ self performOnDelegate: PROPERTY_OF_OBJECT withObject: key withObject: self ];
	return [( result != IGNORE_DELEGATE ? result : [ self objectForKey: key ]) isEqual: @"yes" ];
}

- (void) setBooleanValue: (BOOL) value forKey: key {
	id result = nil;
	result = [ self 
		performOnDelegate: SET_VALUE_FOR_PROPERTY_OF_OBJECT 
		withObject: ( value ? @"yes" : @"no" ) 
		withObject: key
		withObject: self 
	];
	if( result == nil ) {
		return;
	} else if( result == IGNORE_DELEGATE ) {
		result = ( value ? @"yes" : @"no" );
	} 
	[ self setObject: result forKey: key];
}

- (id) booleanObjectForKey: (NSString*) key {
	return [ NSNumber numberWithBool: [ self booleanValueForKey: key ] ];
}

- (void) setBooleanObject: (id) value forKey: key {
	[ self setBooleanValue: [ value boolValue ] forKey: key];
}

#pragma mark Accessors:Int

- (int) intValueForKey: (NSString*) key {
	id result = nil;
	result = [ self performOnDelegate: PROPERTY_OF_OBJECT withObject: key withObject: self ];

	return [( result != IGNORE_DELEGATE ? result : [ self objectForKey: key ]) intValue ];
}

- (void) setIntValue: (int) value forKey: (NSString*) key {
	id result = nil;
	result = [ self 
		performOnDelegate: SET_VALUE_FOR_PROPERTY_OF_OBJECT 
		withObject: [ NSNumber numberWithInt: value ] 
		withObject: key
		withObject: self 
	];
	if( result == nil ) {
		return;
	} else if( result == IGNORE_DELEGATE ) {
		result = [ NSNumber numberWithInt: value ];
	} 
	[ self setObject: result forKey: key ];
}

- (id) intObjectForKey: (NSString*) key {
	return [ NSNumber numberWithInt: [ self intValueForKey: key ]];
}

- (void) setIntObject: (id) value forKey: (NSString*) key {
	[ self setIntValue: [ value intValue ] forKey: key ];
}

#pragma mark Accessors:String

- (NSString*) stringValueForKey: (NSString*) key {
	id result = nil;
	result = [ self performOnDelegate: PROPERTY_OF_OBJECT withObject: key withObject: self ];

	return result != IGNORE_DELEGATE ? result : [ self objectForKey: key ];
}

- (void) setStringValue: (NSString*) value forKey: (NSString*) key {
	id result = nil;
	result = [ self 
		performOnDelegate: SET_VALUE_FOR_PROPERTY_OF_OBJECT 
		withObject: value
		withObject: key
		withObject: self 
	];

	if( result == nil ) {
		return;
	} else if( result == IGNORE_DELEGATE ) {
		result = value;
	} 

	if( result == nil ) {
		[ self removeObjectForKey: key ];
	} else {
		[ self setObject:  [ NSString stringWithFormat: @"%@", result ] forKey: key ];
	}
}
#pragma mark Accessors:Object
- (id) objectValueForKey: (NSString*) key {
	id result = nil;
	result = [ self performOnDelegate: PROPERTY_OF_OBJECT withObject: key withObject: self ];

	return result != IGNORE_DELEGATE ? result : [ self objectForKey: key ];
}

- (id) setObjectValue: (id) value forKey: (NSString*) key {
	id result = nil;
	result = [ self 
		performOnDelegate: SET_VALUE_FOR_PROPERTY_OF_OBJECT 
		withObject: value
		withObject: key
		withObject: self 
	];
	if( result == nil ) {
		return nil;
	} else if( result == IGNORE_DELEGATE ) {
		result = value;
	} 

	if( result == nil ) {
		[ self removeObjectForKey: key ];
	} else {
		[ self setObject: result forKey: key ];
	}
	return nil;
}

+ (AlmostVPNObject*) findObjectWithUUID: (NSString*) uuid {
	return [[ _objectsByUUID objectForKey: uuid ] nonretainedObjectValue ];
}

+ (AlmostVPNObject*) findObjectOfClass: (Class) aClass withProperty: (NSString*) name equalTo: (id) value {
	NSArray* allOfThisClass = [ self objectsMemberOfClass: aClass ];
	NSEnumerator* objects = [ allOfThisClass objectEnumerator ];
	AlmostVPNObject* object;
	while(( object = [ objects nextObject ] ) != nil ) {
		id propertyValue = [ object valueForKey: name ];
		if( [ value isEqual: propertyValue ] ) {
			return object;
		}
	}
	return nil;
}
+ (AlmostVPNObject*) findObjectKindOfClass: (Class) aClass withProperty: (NSString*) name equalTo: (id) value {
	NSArray* allOfThisClass = [ self objectsKindOfClass: aClass ];
	NSEnumerator* objects = [ allOfThisClass objectEnumerator ];
	AlmostVPNObject* object;
	while(( object = [ objects nextObject ] ) != nil ) {
		id propertyValue = [ object valueForKey: name ];
		if( [ value isEqual: propertyValue ] ) {
			return object;
		}
	}
	return nil;
}


+ (NSArray*) objectsKindOfClass: (Class) aClass {
	if( aClass == nil ) {
		return [ NSArray array ];
	}
	NSEnumerator* objects = [ _objectsByUUID objectEnumerator ];
	NSValue* anObject = nil;
	NSMutableArray* result = [ NSMutableArray array ];
	while(( anObject = [ objects nextObject ] ) != nil ) {
		if( [[ anObject nonretainedObjectValue]  isKindOfClass: aClass ] ) {
			[ result addObject: [ anObject nonretainedObjectValue ]];
		}
	}
	return result;
}

+ (NSArray*) objectsMemberOfClass: (Class) aClass {
	if( aClass == nil ) {
		return [ NSArray array ];
	}
	NSEnumerator* objects = [ _objectsByUUID objectEnumerator ];
	NSValue* anObject = nil;
	NSMutableArray* result = [ NSMutableArray array ];
	while(( anObject = [ objects nextObject ] ) != nil ) {
		if( [[ anObject nonretainedObjectValue ] isMemberOfClass: aClass ] ) {
			[ result addObject: [ anObject nonretainedObjectValue ]];
		}
	}
	return result;
}

+ (NSString*) kind {
	NSString* className = NSStringFromClass( self );
	if( [ className rangeOfString: @"AlmostVPN" ].location == 0 ) {
		return [ className substringFromIndex: [ @"AlmostVPN" length ]];
	}
	return nil;
}

- (NSString*) kind {
	return [[ self class ] kind ];
}


+ (NSString*) classNameForKind: (NSString*) kind {
	return [ NSString stringWithFormat: @"AlmostVPN%@", kind ];
}


- (NSString*) uuid {
	return [ self objectForKey: _UUID_KEY_ ];
}

- (NSString*) name {
	NSString* result = [ self objectForKey: _NAME_KEY_ ];
	if( result == nil ) {
		result = [[[ self class ] kind ] lowercaseString ];
		[ self setName: result ];
	}
	
	return result;
}

- (void) setName: (NSString*) value {
	[ self setObject: value forKey: _NAME_KEY_ ];
}

- (NSString*) fullName {
	return [ self name ];
}

- (BOOL) hasDefaultName {
	return [[ self objectForKey: _NAME_KEY_ ] isEqual: [[[ self class ] kind ] lowercaseString ]];
}

- (BOOL) isContainer {
	return NO;
}

- (BOOL) isResource {
	return NO;
}

- (BOOL) isReference {
	return NO;
}
#pragma mark  NSObject Key Value Methods

- (id) valueForKey: (NSString*) aKey {
	SEL getter = NSSelectorFromString( aKey );
	id result = nil;
	if( [ self respondsToSelector: getter ] ) {
		result = [ self performSelector: getter ];
//		NSLog( @"valueForKey : %@ : getter %@ = %@\n", NSStringFromClass( [self class ] ), aKey, result ); 
	} else {
		result = [ super valueForKey: aKey ];
		if( result != nil ) {
			NSLog( @"valueForKey : %@ :        %@ = %@\n", NSStringFromClass( [self class ] ), aKey, result ); 
		}
	}
	return result;
}

- (SEL) setterForProperty: (NSString*) name {
	NSString* firstChar = [[ name substringToIndex: 1 ] uppercaseString ];
	NSString* restOfIt = [ name substringFromIndex: 1 ];
	
	NSString* setterString = [ NSString stringWithFormat: @"set%@%@:", firstChar, restOfIt ];
	return NSSelectorFromString( setterString );
}

- (void) setValue: (id) aValue forKey: (NSString*) aKey {
	SEL setter = [ self setterForProperty: aKey ];
	if( [ self respondsToSelector: setter ] ) {
		[ self performSelector: setter withObject: aValue ];
	} else {
		[ super setValue: aValue forKey: aKey ];
	}
	
	[[ NSNotificationCenter defaultCenter ] postNotificationName: _ALMOSTVPN_SET_VALUE_FOR_KEY_NOTIFICATION_ object: self ];
}

- (id) valueForUndefinedKey: (NSString*)aKey {
//	return [ super valueForUndefinedKey: aKey ];
	return nil;
}

- (void) setValue: (id) aValue forUndefinedKey: (NSString*) aKey {
//	[ super setValue: aValue forUndefinedKey: aKey ];
}


- (id) copyWithZone: (NSZone*) zone {
	NSString* className = [ _embeddedDictionary objectForKey: _CLASS_NAME_KEY_ ];
	Class class = NSClassFromString( className );
	if( class == nil ) {
		return nil;
	} 
	AlmostVPNObject* result = [ class allocWithZone: zone ];

	
	result->_embeddedDictionary = [ _embeddedDictionary  copyWithZone: zone ];
	result->_observerCount = 0;
	return [ result retain ];
}
- (NSString*) title {
	return [ NSString stringWithFormat: @"%@/%@/%@", [ self name ], [ self kind ], [ self uuid ]];
}

static int _globalObserverCount = 0;

- (void)addObserver:(NSObject *)anObserver forKeyPath:(NSString *)aKeyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
	if( anObserver == nil || aKeyPath == nil ) {
		NSLog( @"   AddObserver : ERROR : anObserver and/or keyPath == nil");
		return;
	}
	@try {
		// NSLog( @"   AddObserver[ %2d : %4d ] : %@ - %@", _observerCount, _globalObserverCount,  [ self title ], aKeyPath );
		[ super addObserver: anObserver forKeyPath: aKeyPath options: options context: context ];
		_observerCount++;
		_globalObserverCount++;
	} @catch ( NSException* e ) {
	#pragma unused( e )
		// Do nothing
	}
}

- (void) removeObserver: (NSObject*) anObserver forKeyPath: (NSString*) aKeyPath {
	if( anObserver == nil || aKeyPath == nil ) {
		NSLog( @"RemoveObserver : ERROR : anObserver and/or keyPath == nil");
		return;
	}
	// NSLog( @"RemoveObserver[ %2d : %4d ] : %@ - %@", _observerCount, _globalObserverCount, [ self title ], aKeyPath );
	if( _observerCount > 0 ) {
		_observerCount--;
		_globalObserverCount--;
		@try {
			[ super removeObserver: anObserver forKeyPath: aKeyPath ];
		} @catch ( NSException* e ) {
		#pragma unused( e )
			// Do nothing
		}
	}
}


id <AlmostVPNSecureStorageProvider> _secureStorageProvider = nil;

+ (id<AlmostVPNSecureStorageProvider>) secureStorageProvider {
	return _secureStorageProvider;
}

+ (void) setSecureStorageProvider: (id<AlmostVPNSecureStorageProvider>) provider {
	_secureStorageProvider = provider;
}

+ (BOOL) isKeySecure: (id) key {
	return NO;
}

- (BOOL) isKeySecure: (id) key {
	return [[ self class ] isKeySecure: key ];
}

#pragma mark  NSDictionary primitive methods
-initWithCapacity: (int) capacity {
	self = [ self init ];
	[ _embeddedDictionary release ];
	_embeddedDictionary = [[ NSMutableDictionary alloc ] initWithCapacity: capacity ];
	return self;
}

-(int) count {
	return [ _embeddedDictionary count ];
}

- (id) objectForKey: (id) aKey {
	if( [ @"_retainCount_" isEqual: aKey ] ) {
		return [ NSNumber numberWithInt: [ self retainCount ]];
	} else if( [ self isKeySecure: aKey ] && ( _secureStorageProvider != nil )) {
		return [ _secureStorageProvider retriveSecureObjectWithKey: aKey ofObject: self ];
	} else {
		return [ _embeddedDictionary objectForKey: aKey ];
	}
}

- (NSEnumerator*) keyEnumerator {
	return [ _embeddedDictionary keyEnumerator ];
}

#pragma mark  NSMutableDictionary primitive methods
-(void) setObject: (id) anObject forKey: (id) aKey {
	if( [ @"_retainCount_" isEqual: aKey ] || [ @"_hash_" isEqual: aKey ] || [ @"_class_" isEqual: aKey ] ) {
		return;
	} else if( [ self isKeySecure: aKey ] && ( _secureStorageProvider != nil )) {
		return [ _secureStorageProvider saveSecureObject: anObject withKey: aKey ofObject: self ];
	} else if( anObject == nil ) {
		[ _embeddedDictionary removeObjectForKey: aKey ];
	} else {
		[ _embeddedDictionary setObject: anObject forKey: aKey ];
	}
}
- (void) removeObjectForKey: (id) aKey {
	[ _embeddedDictionary removeObjectForKey: aKey ];
}

- (void) removeAllObjects {
	[ _embeddedDictionary removeAllObjects ];
}
@end

@implementation NSMutableDictionary (AlmostVPNObject)
- (void) removeObjectsForKeyRecursively: (NSString*) key {
	NSEnumerator* values = [ self objectEnumerator ];
	NSObject* value;
	while(( value = [ values nextObject ]) != nil ) {
		if( [ value isKindOfClass: [ NSMutableDictionary class ]] ) {
			[ (NSMutableDictionary*)value removeObjectsForKeyRecursively: key ];
		} else if( [ value isKindOfClass: [ NSArray class ]] ) {
			NSArray* anArray = (NSArray*) value;
			for( int i = 0; i < [ anArray count ]; i++ ) {
				NSObject* element = [ anArray objectAtIndex: i ];
				if( [ element isKindOfClass: [ NSMutableDictionary class ]] ) {
					[ (NSMutableDictionary*)element removeObjectsForKeyRecursively: key ];
				}
			}
		}
	}
	[ self removeObjectForKey: key ];
}
@end


