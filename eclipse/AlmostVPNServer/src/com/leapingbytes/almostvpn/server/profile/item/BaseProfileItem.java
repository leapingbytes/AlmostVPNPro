package com.leapingbytes.almostvpn.server.profile.item;

import java.util.ArrayList;
import java.util.Iterator;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.Profile;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;


abstract public class BaseProfileItem implements IProfileItem {
	private static final Log log = LogFactory.getLog( BaseProfileItem.class );
	
	public static final String _WILL_START_EVENT_ = "will-start";
	public static final String _DID_START_EVENT_ = "did-start";
	public static final String _WILL_STOP_EVENT_ = "will-stop";
	public static final String _DID_STOP_EVENT_ = "did-stop";
	
	public static final String _FAIL_TO_START_EVENT_ = "fail-to-start";
	public static final String _FAIL_TO_STOP_EVENT_ = "fail-to-stop";
	
	public interface IProfileItemWatcher {
		public void event( String eventType, IProfileItem target );
	}
	
	static ArrayList _watchers = new ArrayList();
	
	public static void addWatcher( final IProfileItemWatcher watcher ) {
		addWatcher( null, watcher );
	}
	public static void addWatcher( final Class targetClass, final IProfileItemWatcher watcher ) {
		_watchers.add(
			new IProfileItemWatcher() {
				Class _targetClass = targetClass;
				IProfileItemWatcher	_watcher = watcher;
				public void event(String eventType, IProfileItem target) {
					if( _targetClass == null || ( _targetClass.isAssignableFrom( target.getClass() ) )) {
						_watcher.event( eventType, target); 
					}
				}
				public boolean equals( Object o ) {
					return _watcher == o;
				} 
			}
		);
	}

	public static void removeWatcher(IProfileItemWatcher watcher ) {
		_watchers.remove(  watcher );
	}
	
	public static void fireEvent( String eventType, IProfileItem target ) {
		Iterator i = _watchers.iterator();
		while( i.hasNext()) {
			((IProfileItemWatcher)i.next()).event( eventType, target );
		}
	}
	
	protected void fireEvent( String eventType ) {
		fireEvent( eventType, this );
	}
	
	public BaseProfileItem( IProfileItem dependsOn ) {
		setPrerequisit( dependsOn );
	}
	public BaseProfileItem() {		
	}
	
	public static String stateToString( int v ) {
		switch( v ) {
			case IProfileItem.INIT : return "init";
			case IProfileItem.RUNNING : return "running";
			case IProfileItem.STOPPED : return "stopped";
		}
		
		log.warn( "stateToString : unknown state : " + v );
		
		return "unknown";
	}
	
	protected String 	_title = null;
	protected int		_profileGeneration = -1;
	public String title() {
		int currentGeneration = Profile.threadCurrentProfile().generation();
		if( currentGeneration != _profileGeneration ) {
			_profileGeneration = currentGeneration;
			_title = _title();
		}
		return _title;
	}
	public void resetTitle() {
		_title = null;
	}
	
	public abstract String _title();

	public String toString() {
		return title() + "(" + stateToString( state()) + ")";
	}
	public int hashCode() {
		return title().hashCode();
	}

	public boolean equals( Object o ) {
		if( o instanceof BaseProfileItem ) {
			BaseProfileItem s = (BaseProfileItem)o;
			String thisTitle = title();
			String thatTitle = s.title();
			if( thisTitle == null && thatTitle != null ) {
				return this.getClass().equals( o.getClass());
			} else {
				return this.getClass().equals( o.getClass()) && thisTitle.equals( thatTitle );
			}
		} else {
			return false;
		}
	}
	
	IProfileItem	_prerequisit = null;
	
	public IProfileItem prerequisit() {
		return _prerequisit;
	}
	
	public BaseProfileItem setPrerequisit( IProfileItem v ) {
		if( _prerequisit == null ) {
			_prerequisit = v;
		} else if( v == null ) {
			_prerequisit = null;
		}else if( _prerequisit == v ) {
			// DONE
			return this;
		} else if( v.dependsOn( _prerequisit )) {
			_prerequisit = v;
		} else if( v.dependsOn( this )) {
			log.error( "setPrerequisit : Loop. " + v + " depends on " + this );
		} else {
			((BaseProfileItem) _prerequisit).setPrerequisit( v );
		}
		return this;
	}
	
	public boolean dependsOn( IProfileItem v ) {
		if( _prerequisit == null ) {
			return false;
		}
		
		if( _prerequisit == v ) {
			return true;
		}
		
		return _prerequisit.dependsOn( v );
	}
	
	int	_state = IProfileItem.INIT;

	public int state() {
		return _state;
	}	
	
	public boolean isStartable() {
		return  state() == IProfileItem.INIT || state() == IProfileItem.STOPPED;
	}
	
	public boolean isStoppable() {
		return state() == IProfileItem.RUNNING;
	}
	
	protected void setState( int v ) {
		setState( v, null );
	}
	protected void setState( int v, String comment ) {
		log.info( "setState : " + this + " state = " + stateToString( v ));
		_state = v;
		if( comment != null ) {
			Profile.threadCurrentProfile().setState( null, comment);
		}
	}

	protected void startDone( String comment ) {
		if( state() != IProfileItem.RUNNING ) {
			setState( IProfileItem.RUNNING, comment );
		}
	}
	protected void stopDone( String comment ) {
		if( state() != IProfileItem.STOPPED ) {
			setState( IProfileItem.STOPPED, comment );
		}
	}
	
	public void dismiss() throws ProfileException {
		if( _state != INIT ) {
			throw new ProfileException( "Profile Item can be dissmissed only in INIT state");
		}
	}
}
