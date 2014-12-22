package com.leapingbytes.almostvpn.util.file;

import com.leapingbytes.jcocoa.NSMutableArray;
import com.leapingbytes.jcocoa.NSMutableDictionary;

public class LaunchdPlist extends NSMutableDictionary {

	public static final String 		_YES_			= "yes";
	public static final String 		_NO_			= "no";
	
	public static final String		_DISABLED_KEY_		= "Disabled";
	public static final String		_RUN_AT_LOAD_KEY_	= "RunAtLoad";
	public static final String		_LABEL_KEY_			= "Label";
	public static final String		_USER_NAME_KEY_		= "UserName";
	public static final String		_GROUP_NAME_KEY_	= "GroupName";
	public static final String		_PROGRAM_KEY_		= "Program";
	public static final String		_PROG_ARGS_KEY_		= "ProgrammArguments";

	public static final String		_WORK_DIR_KEY_		= "WorkingDirectory";

	public static final String		_START_INTERVAL_KEY_= "StartInterval";
	public static final String		_START_CALENDAR_KEY_= "StartCalendarInterval";
		public static final String		_MINUTE_KEY_		= "Minute";
		public static final String		_HOUR_KEY_			= "Hour";
		public static final	String		_DAY_KEY_			= "Day";
		public static final String		_WEEKDAY_KEY_		= "Weekday";
		public static final String		_MONTH_KEY_			= "Month";
		
	public static final String		_DESCRIPTION_KEY_	= "ServiceDescription";
	
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 3998188152287896877L;

	public boolean disabled() {
		return _YES_.equals( this.objectForKey( _DISABLED_KEY_, "no" ));
	}
	public void setDisabled( boolean v ) {
		this.setObjectForKey( v ? _YES_ : _NO_, _DISABLED_KEY_ );
	}	
	
	public boolean runAtLoad() {
		return _YES_.equals( this.objectForKey( _RUN_AT_LOAD_KEY_, "no" ));
	}
	public void setRunAtLoad( boolean v ) {
		this.setObjectForKey( v ? _YES_ : _NO_, _RUN_AT_LOAD_KEY_ );
	}	
	
	public String label() {
		return (String) this.objectForKey( _LABEL_KEY_ );
	}
	public void setLabel( String v ) {
		this.setObjectForKey( v, _LABEL_KEY_ );
	}
	
	public String serviceDescription() {
		return (String) this.objectForKey( _DESCRIPTION_KEY_ );
	}
	public void setServiceDescription( String v ) {
		this.setObjectForKey( v, _DESCRIPTION_KEY_ );
	}
	
	public String userName() {
		return (String) this.objectForKey( _USER_NAME_KEY_ );
	}
	public void setUserName( String v ) {
		this.setObjectForKey( v, _USER_NAME_KEY_ );
	}

	public String groupName() {
		return (String) this.objectForKey( _GROUP_NAME_KEY_ );
	}
	public void setGroupName( String v ) {
		this.setObjectForKey( v, _GROUP_NAME_KEY_ );
	}

	public String program() {
		return (String) this.objectForKey( _PROGRAM_KEY_ );
	}
	public void setProgram( String v ) {
		this.setObjectForKey( v, _PROGRAM_KEY_ );
	}

	public String[] programArguments() {
		String[] result;
		result = (String[]) this.objectsAtPath( _PROG_ARGS_KEY_ + "/*" );
		return result;
	}	
	public void setProgrammArguments( String[] v ) {
		NSMutableArray array = new NSMutableArray();
		for( int i = 0; i < v.length; i++ ) {
			array.addObject( v[ i ] );
		}
		this.setObjectForKey( array, _PROG_ARGS_KEY_ );
	}
	
	public String workingDirectory() {
		return (String) this.objectForKey( _WORK_DIR_KEY_ );
	}
	public void setWorkingDirectory( String v ) {
		this.setObjectForKey( v, _WORK_DIR_KEY_ );
	}

	public int startInterval() {
		return ((Integer) this.objectForKey( _START_INTERVAL_KEY_ )).intValue();
	}
	public void setStartInterval( int v ) {
		this.setObjectForKey( new Integer( v ), _START_INTERVAL_KEY_ );
	}	
	
	public int minute() {
		return calendarAttribute( _MINUTE_KEY_ );		
	}
	public void setMinute( int v ) {
		this.setCalendarAttribute( _MINUTE_KEY_, v );
	}
	public int hour() {
		return calendarAttribute( _HOUR_KEY_ );		
	}
	public void setHour( int v ) {
		this.setCalendarAttribute( _HOUR_KEY_, v );
	}
	public int day() {
		return calendarAttribute( _DAY_KEY_ );		
	}
	public void setDay( int v ) {
		this.setCalendarAttribute( _DAY_KEY_, v );
	}
	public int weekday() {
		return calendarAttribute( _WEEKDAY_KEY_ );		
	}
	public void setWeekday( int v ) {
		this.setCalendarAttribute( _WEEKDAY_KEY_, v );
	}
	public int month() {
		return calendarAttribute( _MONTH_KEY_ );		
	}
	public void setMonth( int v ) {
		this.setCalendarAttribute( _MONTH_KEY_, v );
	}
	
	private int calendarAttribute( String key ) {
		NSMutableDictionary calendar = (NSMutableDictionary) this.objectForKey( _START_CALENDAR_KEY_ );
		if( calendar == null ) {
			return -1;
		}
		return ((Integer)calendar.objectForKey( key )).intValue();
	}
	private void setCalendarAttribute( String key, int v ) {
		NSMutableDictionary calendar = (NSMutableDictionary) this.objectForKey( _START_CALENDAR_KEY_ );
		if( calendar == null ) {
			calendar = new NSMutableDictionary();
			this.setObjectForKey( calendar, _START_CALENDAR_KEY_ );
		}
		calendar.setObjectForKey( new Integer( v ), key );
	}
}
