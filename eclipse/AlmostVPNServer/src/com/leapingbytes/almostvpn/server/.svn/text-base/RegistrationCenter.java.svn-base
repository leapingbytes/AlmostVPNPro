package com.leapingbytes.almostvpn.server;

import com.kagi.acg.DecodeRegCode;
import com.leapingbytes.almostvpn.util.SecureStorageProvider;

public class RegistrationCenter {
	private static final String	_SECURE_STORAGE_KEY_	= RegistrationCenter.class.getName() + ":2296656382987441060";

	private static final String _DECODER_ = "SUPPLIERID:leapingbytes%E:13%N:5%H:5%COMBO:en%SDLGTH:13%CONSTLGTH:2%CONSTVAL:L1%SEQL:3%ALTTEXT:Contact abc@supplier.com to obtain your registration code%SCRMBL:D1,,U2,,U6,,U3,,U10,,U0,,C1,,U9,,U7,,D3,,U4,,U11,,S0,,U5,,C0,,U8,,S2,,U12,,S1,,D0,,U1,,D2,,%ASCDIG:2%MATH:9A,,8S,,R,,1M,,8A,,7S,,1M,,R,,7A,,6S,,R,,1M,,6A,,5S,,1M,,R,,6S,,5A,,R,,1M,,9A,,1S,,%BASE:30%BASEMAP:G0EHMT1FR7QD63JNCKL4A8UX92YP5W%REGFRMT:AVPN1.0-^#####-#####-#####-#####-#####-#####[-#]";
	
//	private static String _name = null;
	private static String _email = null;
	private static String _registration = null;
	
	public static final String verifyRegistration( String name, String email ) {
		return verifyRegistration( name, email, SecureStorageProvider.retriveSecureObject( RegistrationCenter.secureStorageKey()));
	}
	public static final String verifyRegistration( String name, String email, String registration ) {
//		_name = name;
		_email = email;
		_registration = registration;
		
		if( _registration == null ) {
			return "ERROR";
		}
		
	    return registrationLevel();
	}

	public static String secureStorageKey() {
		return _SECURE_STORAGE_KEY_;
	}

	public static String saveRegistration(String name, String email, String registration) {
		if( ! "ERROR".equals( verifyRegistration( name, email, registration ))) {
			SecureStorageProvider.saveSecureObject( RegistrationCenter.secureStorageKey(), registration );
			return registrationLevel();
		} else {
			return "ERROR";
		}
	}
	
	public static String registrationLevel() {
		DecodeRegCode decodeCode = new DecodeRegCode(false, _DECODER_);
	    decodeCode.decode( _registration );
	    decodeCode.setEmail( _email );
		
	    return decodeCode.isRegCodeValid() ? decodeCode.getConstant() : "ERROR";
	}
	
	public static String forgetRegistration() {		
		String result = SecureStorageProvider.retriveSecureObject( RegistrationCenter.secureStorageKey());
		SecureStorageProvider.deleteSecureObject( RegistrationCenter.secureStorageKey() );
		return result == null ? "ERROR" : result;
	}
}
