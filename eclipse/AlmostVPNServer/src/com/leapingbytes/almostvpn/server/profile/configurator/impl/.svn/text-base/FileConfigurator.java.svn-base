package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.impl.PrefixMarker;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHCommand;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHFileCopy;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.impl.Script;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.jcocoa.NSDictionary;

public class FileConfigurator extends BaseConfigurator {
	public FileConfigurator() {
		super( Model.AVPNFileRefClass );
	}

	public IProfileItem configure(NSDictionary definition) throws ProfileException {
		IProfileItem	result = null;
		
		Model	fileRef = new Model( definition );
		
		Model	file = fileRef.referencedModel();
		Model	fileHost = file.parentModel();
		Model 	fileLocation = fileHost.isLocation() || fileHost.isLocalhost() ?
			fileHost :
			fileHost.parentModel();
		String  filePath = file.path();
		
		Model	dstLocation = fileRef.modelReferencedBy( Model.AVPNDstLocationProperty );
		String  dstPath = fileRef.dstPath();

		boolean doAfterStart = fileRef.doAfterStart();
		String doThis = fileRef.doThis();
		boolean andExecute  = fileRef.andExecute();
		
		boolean fileIsLocal = fileHost.isLocalhost();
		boolean dstIsLocal = dstLocation.isLocalhost();
		
		
		SSHSession	srcSession = null;
		SSHSession	dstSession = null;
		
		/*
		 * Deal with move/copy
		 */
		if( ! Model.AVPNNopMarker.equals( doThis )) { // If it is not "nop", than it must be copy/move
			boolean doMove = Model.AVPNMoveMarker.equals( doThis );
			if( fileIsLocal && dstIsLocal ) { // Local move
				Script script = (Script) add( new Script( (  doMove ? "mv " : "cp " ) + filePath + " " + dstPath, "" ));
				script.setPrerequisit( PrefixMarker.marker());
			} else {				
				srcSession = fileIsLocal ? null : (SSHSession) profile().configure( fileLocation.definition());	
				dstSession = dstIsLocal ? null : (SSHSession) profile().configure( dstLocation.definition());	
				result = add( new SSHFileCopy( srcSession, filePath, dstSession, dstPath, doAfterStart, ! doAfterStart ));
				if( doMove ) {
					BaseProfileItem rmFile;
					if( fileIsLocal ) {
						rmFile =
							doAfterStart ?
									new Script( "rm " + filePath, "" ) :
									new Script( "", "rm " + filePath ) ;
					} else {
						rmFile = new SSHCommand( srcSession, "rm " + filePath, doAfterStart, ! doAfterStart, false, false );
					}
					rmFile = (BaseProfileItem) add( rmFile );
					
					if( doAfterStart ) {
						rmFile.setPrerequisit( result );
						result = rmFile;						
					} else { // Things happen in reverse when doBeforeStop ...
						IProfileItem resultDependOn = ((SSHFileCopy)result).prerequisit();
						rmFile.setPrerequisit( resultDependOn );
						((SSHFileCopy)result).setPrerequisit( null );
						((SSHFileCopy)result).setPrerequisit( rmFile );						
					}					
				}
			}
			if( andExecute ) {
				BaseProfileItem execFile;
				if( dstIsLocal ) { // 
					execFile = new Script( dstPath, "" );
				} else {
					execFile = new SSHCommand( dstSession, dstPath, doAfterStart, ! doAfterStart, file.x11(), file.console());
				}
				execFile = (BaseProfileItem) add( execFile );
				execFile.setPrerequisit( result ); result = execFile;
			}
		} else if( andExecute ) {
			BaseProfileItem execFile;
			if( fileIsLocal ) { // 
				execFile = new Script( filePath, "" );
			} else {
				srcSession = (SSHSession) profile().configure( fileLocation.definition());	
				execFile = new SSHCommand( srcSession, filePath, doAfterStart, ! doAfterStart, file.x11(), file.console());
			}
			execFile = (BaseProfileItem) add( execFile );
			execFile.setPrerequisit( result ); result = execFile;
		} else {
			// DO NOTHING AT ALL ???
		}
		
		return result;
	}		
}
