function log( msg ) {
	widget.system( "echo \"AlmostVPN.Widget : " + msg + "\" >/dev/console", null );
}

function importScript( href, parameters ) {
	var result;
	
	var cstAjax =  new Ajax.Request( href, { method: 'get', parameters: parameters, asynchronous: false });
	var transport = cstAjax.transport;
	
	if( transport.status == 200 ) {
		result = eval( transport.responseText );
	} else {
		result = new Error(  "Fail to import " + href + " : " + transport.status );
	}	
	return result;
}

var startButton, stopButton, pauseButton, restartButton;
var profilesDiv;
var statusIcon;

var profiles = new Array();

function initialize() {
	profilesScrollbar = new AppleVerticalScrollbar(
        document.getElementById("profilesScrollbar")
    );
 
    profilesDiv = new AppleScrollArea(
        document.getElementById("profiles")
    );
 
    profilesDiv.addScrollbar(profilesScrollbar);


	startButton = $( "startButton" );
	stopButton = $( "stopButton" );
	pauseButton = $( "pauseButton" );
	restartButton = $( "restartButton" );
	
	profilesDiv = $( "profiles" );
	statusIcon = $( "statusIcon" );
}

var _states_ = {
	idle: {
		weight: 0,
		title: "idle",
		imgSrc: "images/blank.png",
		statusSrc: "images/status-grey.png"
	},
	paused: {
		weight: 1,
		title: "paused",
		imgSrc: "images/grey.png",
		statusSrc: "images/status-grey.png"
	},
	running : {
		weight: 10,
		title: "running",
		imgSrc: "images/green.png",
		statusSrc: "images/status-green.png"
	},
	starting: {
		weight: 20,
		title: "starting",
		imgSrc: "images/yellow.png",
		statusSrc: "images/status-yellow.png"
	},
	stopping: {
		weight: 21,
		title: "stopping",
		imgSrc: "images/yellow.png",
		statusSrc: "images/status-yellow.png"
	},
	fail: {
		weight: 50,
		title: "fail",
		imgSrc: "images/red.png",
		statusSrc: "images/status-red.png"
	}
};

function bestState( state1, state2 ) {
	var weight1 = _states_[ state1 ].weight;
	var weight2 = _states_[ state2 ].weight;
	
	if( weight1 <= weight2 ) {
		return state1;
	} else {
		return state2;
	}
}

function worstState( state1, state2 ) {
	var weight1 = _states_[ state1 ].weight;
	var weight2 = _states_[ state2 ].weight;
	
	if( weight1 > weight2 ) {
		return state1;
	} else {
		return state2;
	}
}

function makeNewProfileDiv( profiles, i ) {
	var profile = profiles[ i ];
	var newProfileDiv = document.createElement( "div" );
		profiles.div = newProfileDiv;
		newProfileDiv.setAttribute( "profileName", profile.name );
		newProfileDiv.setAttribute( "profileState", profile.state );
		newProfileDiv.setAttribute( "profileIndex", i );
		
		var newProfileImg = document.createElement( "img" );
			newProfileImg.setAttribute( "src",  _states_[ profile.state ].imgSrc );
			newProfileImg.setAttribute( "alt",  profile.state_comment );
		newProfileDiv.appendChild( newProfileImg );
		newProfileDiv.appendChild( document.createTextNode( profile.name ));
		newProfileDiv.setAttribute( "onClick", "selectProfile( this );" );
		Element.addClassName( newProfileDiv, "profile" );
		Element.addClassName( newProfileDiv, i % 2 == 0 ? "even" : "odd" );		

	return newProfileDiv;
}

function refreshDisplay( selectedProfileName ) {
	profilesDiv.innerHTML = "";
		
	var best = "fail";
	var worst = "idle";

	var needToRebuild = false;	
	
	for( var i = 0; i < profiles.length; i++ ) {
		var newProfileDiv = makeNewProfileDiv( profiles, i );
		
		if( selectedProfileName == profiles[ i ].name ) {
			Element.addClassName( newProfileDiv, "selected" );
		}

		profilesDiv.appendChild( newProfileDiv );
		
		best = bestState( best, profiles[ i ].state );
		worst = worstState( worst, profiles[ i ].state );
	}
	
	for( ; i < 4; i++ ) {
		var newProfileDiv = document.createElement( "div" );
			var newProfileImg = document.createElement( "img" );
				newProfileImg.setAttribute( "src",  "images/blank.png" );
			newProfileDiv.appendChild( newProfileImg );
			newProfileDiv.appendChild( document.createTextNode( "dummy" ));
			Element.addClassName( newProfileDiv, "profile" );
			Element.addClassName( newProfileDiv, "empty" );
			Element.addClassName( newProfileDiv, i % 2 == 0 ? "even" : "odd" );		
		profilesDiv.appendChild( newProfileDiv );
	}
	
	statusIcon.setAttribute( "src", _states_[ worst ].statusSrc );
}

var _fastRefresh_ = 0;

function doAlmostVPNAction( actionName, profileName ) {
	var href = "http://127.0.0.1:1313/almostvpn/control/action/do";
	var parameters = "action=" + actionName + "&report-format=js:profiles"+ ( profileName ? "&profile=" + profileName : "" );	
	
	importScript( href, parameters );
	
	_fastRefresh_ = 5;
}

var _timeToStop_ = false;
var _updateTimeout_ = null;

function doUpdate() {
	if( _updateTimeout_ != null ) {
		window.clearTimeout( _updateTimeout_ );
		_updateTimeout_ = null;
	}
	
	var href = "http://127.0.0.1:1313/almostvpn/control/action/do";
	var parameters = "action=status&report-format=js:profiles";
	
	var selectedProfileName = getSelectedProfileName();
	
	if( ! ( importScript( href, parameters ) instanceof Error )) {
		Element.show( startButton );
		Element.show( stopButton );
		Element.show( pauseButton );
		Element.show( restartButton );
	}; 
	
	profiles = profiles.sortBy( function( profile, index ) { 
		if( profile.stateWait == undefined ) {
			profile.stateWait = _states_[ profile.state ].weight ;
		} 
		
		return 100 - profile.stateWait;
	});

	refreshDisplay( selectedProfileName );	

	if( ! _timeToStop_ ) {	
		_updateTimeout_ = window.setTimeout( doUpdate, _fastRefresh_ > 0 ? 1000 : 5000 );
		_fastRefresh_ --;
		_fastRefresh_ = _fastRefresh_ < 0 ? 0 : _fastRefresh_;
	}		
}

function startUpdates() {
	_timeToStop_ = false;
	doUpdate();
}

function stopUpdates() {
	if( _updateTimeout_ != null ) {
		window.clearTimeout( _updateTimeout_ );
		_updateTimeout_ = null;
	}
	_timeToStop_ = true;
}

function startProfile() {
	if( $A( getSelectedProfiles() ).any( function( p, index ) { return p.state == "paused"; } )) {
		$A( 
			getSelectedProfiles().findAll( function( p, index ) { return p.state == "paused"; } )
		).each(
			function( profile ) {
				doAlmostVPNAction( "start", profile.name );
			}
		);
	} else {
		$A( getSelectedProfiles() ).each(
			function( profile ) {
				doAlmostVPNAction( "start", profile.name );
			}
		);
	}
	doUpdate();
}

function stopProfile() {
	$A( getSelectedProfiles()).each(
		function( p ) {
			doAlmostVPNAction( "stop", p.name );
		}
	);
	doUpdate();
}

function pauseProfile() {
	$A( getSelectedProfiles().findAll( function( p, i ) { return p.state == "running"; } ) ).each(
		function( profile ) {
			doAlmostVPNAction( "pause", profile.name );
		}
	);
	doUpdate();
}

function logSystemResults( anObject ) {
	log( "outputString = " + anObject.outputString );
	log( "errorString = " + anObject.errorString );
	log( "status = " + anObject.status );
}

function restartService() {
	stopUpdates();
	
	Element.hide( startButton );
	Element.hide( stopButton );
	Element.hide( pauseButton );
	Element.hide( restartButton );
	
	log( "restartService" );
	if( widget.system( "test -f ~/Library/Application\\ Support/AlmostVPNPRO/AlmostVPNServer", null ).status == 0 ) {
		log( "restartService : service in ~/Library" );
		widget.system( "~/Library/Application\\ Support/AlmostVPNPRO/AlmostVPNServer --restartService", function( anObject ) { logSystemResults( anObject ); });
	} else {
		log( "restartService : service in /Library" );
		widget.system( "/Library/Application\\ Support/AlmostVPNPRO/AlmostVPNServer --restartService", function( anObject ) { logSystemResults( anObject ); });
	}
		
	 window.setTimeout( startUpdates, 5000 );
}

function openPrefPane() {
	var command = "open ~/Library/PreferencePanes/AlmostVPNPRO.prefPane";
	if( widget.system( "test -d ~/Library/PreferencePanes/AlmostVPNPRO.prefPane", null ).status != 0 ) {
		command = "open /Library/PreferencePanes/AlmostVPNPRO.prefPane";
	}
	widget.system( command, null );
	widget.openURL("");
}

function getSelectedProfileName() {
	var sibling = profilesDiv.firstChild;
	
	var result = 0;
	
	while( sibling ) {
		if( sibling.nodeType == 1 && sibling.nodeName == "DIV" ) {
			if( Element.hasClassName( sibling, "selected" )) {
				return sibling.getAttribute( "profileName" );
			}
		}
		sibling = sibling.nextSibling;
	}
	
	return null;
}

function countSelectedProfiles() {
	var sibling = profilesDiv.firstChild;
	
	var result = 0;
	
	while( sibling ) {
		if( sibling.nodeType == 1 && sibling.nodeName == "DIV" ) {
			if( Element.hasClassName( sibling, "selected" )) {
				result++;
			}
		}
		sibling = sibling.nextSibling;
	}
	
	return result;
}

function getSelectedProfiles() {
	var sibling = profilesDiv.firstChild;
	
	var result = new Array();
	
	var i = 0;
	while( sibling ) {
		if( sibling.nodeType == 1 && sibling.nodeName == "DIV" && sibling.hasAttribute( "profileIndex" )) {
			result[ i ] = profiles[ i ];
			if( Element.hasClassName( sibling, "selected" )) {
				return [ profiles[ i ] ];
			}
			i++;
		}
		sibling = sibling.nextSibling;
	}

	return result;
}

function selectProfile( pDiv ) {
	var parentNode = pDiv.parentNode;
	var sibling = parentNode.firstChild;
	
	var selectedProfiles = 0;
	
	while( sibling ) {
		if( sibling.nodeType == 1 && sibling.nodeName == "DIV" ) {
			if( sibling == pDiv ) {
				if( Element.hasClassName( sibling, "selected" )) {
					Element.removeClassName( sibling, "selected" );
				} else {
					Element.addClassName( sibling, "selected" );
					selectedProfiles = 1;
				}
			} else {
				Element.removeClassName( sibling, "selected" );
			}
		}
		sibling = sibling.nextSibling;
	}	
}

function onShow() {
	initialize();
	startUpdates();
}

function onHide() {
	stopUpdates();
}

function mousemove( evnt ) {
}

function mouseexit( evnt ) {
}
