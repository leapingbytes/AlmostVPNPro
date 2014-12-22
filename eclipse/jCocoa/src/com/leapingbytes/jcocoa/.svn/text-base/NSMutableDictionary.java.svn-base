package com.leapingbytes.jcocoa;

public class NSMutableDictionary extends NSDictionary {
	public interface Watcher {
		public void allObjectsWillBeRemoved( NSMutableDictionary host );
		public void objectForKeyWillBeSet( NSMutableDictionary host,Object o, Object k );
		public void objectForKeyHasBeenRemoved( NSMutableDictionary host,Object o, Object k );
	}
	
	/* TODO: May want to make _globalWatcher thread local.
	 * 
	 */
	static Watcher	_globalWatcher = null;
	Watcher			_watcher = null;
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 8796571249268318029L;

	public void removeAllObjects() {
		if( _globalWatcher != null ) _globalWatcher.allObjectsWillBeRemoved( this );
		if( _watcher != null ) _watcher.allObjectsWillBeRemoved( this );
		
		this.clear();
	}
	
	public void setObjectForKey( Object o, Object k ) {
		if( _globalWatcher != null ) _globalWatcher.objectForKeyWillBeSet( this, o, k );
		if( _watcher != null ) _watcher.objectForKeyWillBeSet( this, o, k );
		
		this.put( k,  o );
	}
	
	public void removeObjectForKey( Object k ) {
		Object o = this.remove( k );

		if( _globalWatcher != null ) _globalWatcher.objectForKeyHasBeenRemoved( this, o, k );
		if( _watcher != null ) _watcher.objectForKeyHasBeenRemoved( this, o, k );
	}
	
	public static void setGlobalWatcher( Watcher watcher ) {
		_globalWatcher = watcher;
	}
	public static Watcher globalWatcher() {
		return _globalWatcher;
	}
	
	public void setWatcher( Watcher watcher ) {
		_watcher = watcher;
	}
	public Watcher watcher() {
		return _watcher;
	}
}
