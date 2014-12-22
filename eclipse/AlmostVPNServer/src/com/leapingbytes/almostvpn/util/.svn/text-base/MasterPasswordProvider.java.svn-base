package com.leapingbytes.almostvpn.util;

import com.leapingbytes.almostvpn.util.macosx.KeychainMasterPasswordProvider;

public abstract class MasterPasswordProvider {
	static final MasterPasswordProvider _defaultProvider = new KeychainMasterPasswordProvider();
	
	public static MasterPasswordProvider defaultProvider() {
		return _defaultProvider;
	}
	
	public abstract String masterPassword();
}
