package com.leapingbytes.almostvpn.server.profile.item.impl;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;

public class CupsAd extends BaseProfileItem {
	private static final Log log = LogFactory.getLog( CupsAd.class );

	private static final int _CUPS_PORT_	= 631;
	
	String	_adLine;
	Timer	_timer;

	public CupsAd( String adLine ) {
		_adLine = adLine;
	}
	
	public void start() {
		_timer = new Timer();
		_timer.schedule( new TimerTask() {
			public void run() {
				sendAd();
			}			
		}, 10*1000, 60*1000 );
		startDone(  "CUPS Browsing started : " + _adLine );
	}

	public void stop() {
		_timer.cancel();
		stopDone(  "CUPS Browsing stopped : " + _adLine );
	}

	private void sendAd() {
		try {
			DatagramSocket socket = new DatagramSocket();
			DatagramPacket packet = new DatagramPacket( 
//					_adLine.getBytes(), _adLine.getBytes().length, InetAddress.getLocalHost(), _CUPS_PORT_ 
					_adLine.getBytes(), _adLine.getBytes().length, InetAddress.getByName("255.255.255.255"), _CUPS_PORT_ 
			);
			socket.send( packet );
			log.debug( "AVPN: CUPS Browsing send : " + _adLine );
		} catch (IOException e) {
			log.warn( "CUPS Browsing failed to send", e );
		}
	}

	public String _title() {
		return _adLine;
	}
}
