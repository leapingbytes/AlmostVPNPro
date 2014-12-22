package com.leapingbytes.almostvpn.util.GUI;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import javax.swing.AbstractAction;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

public class PasswordDialog extends JFrame {
//	private static final Log log = LogFactory.getLog( PasswordDialog.class );

	private static final long	serialVersionUID	= 1L;

	private JPanel				jContentPane		= null;

	private JLabel passwordLabel = null;

	private JTextArea promptField = null;

	private JPasswordField passwordField = null;

	private JButton okButton = null;

	private JButton cancelButton = null;

	private JLabel avpnIcon = null;
	
	private static String _titleText = "Password";
	private static String _promptText = "Please enter password...";
	private static char[] _password = null;

	/**
	 * This method initializes passwordField	
	 * 	
	 * @return javax.swing.JPasswordField	
	 */
	private JPasswordField getPasswordField() {
		if (passwordField == null) {
			passwordField = new JPasswordField();
			passwordField.setLocation(new Point(130, 70));
			passwordField.setSize(new Dimension(200, 25));
		}
		return passwordField;
	}

	/**
	 * This method initializes okButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getOkButton() {
		if (okButton == null) {
			okButton = new JButton();
			okButton.setLocation(new Point(255, 110));
			okButton.setSize(new Dimension(75, 30));
			okButton.setAction( new AbstractAction( "OK" ) {
				private static final long	serialVersionUID	= -2506235392941693705L;

				public void actionPerformed(ActionEvent e) {
					_password = passwordField.getPassword();
					closeDialog();
				}
			});
		}
		return okButton;
	}

	/**
	 * This method initializes cancelButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getCancelButton() {
		if (cancelButton == null) {
			cancelButton = new JButton();
			cancelButton.setLocation(new Point(20, 110));
			cancelButton.setSize(new Dimension(75, 30));
			cancelButton.setAction( new AbstractAction( "Cancel") {
				private static final long	serialVersionUID	= 1357168338138000325L;

				public void actionPerformed(ActionEvent e) {
					_password = "".toCharArray();
					closeDialog();
				}
			});
		}
		return cancelButton;
	}

	/**
	 * @param args
	 * @throws UnsupportedEncodingException 
	 */
	public static void main(String[] args) throws UnsupportedEncodingException {
		_titleText = args[0];
		_promptText = URLDecoder.decode( args[1], "UTF-8" );

		PasswordDialog thisClass = new PasswordDialog();
		thisClass.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		thisClass.show();
	}
	
	private static void closeDialog() {
		System.out.println( _password );
		System.exit( 0 );
	}


	/**
	 * This is the default constructor
	 */
	public PasswordDialog() {
		super( _titleText );
		this.setSize(350, 170);
		this.setLocation( 200, 200 );
		buildJContentPane();
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel buildJContentPane() {
		if (jContentPane == null) {
			avpnIcon = new JLabel();
			avpnIcon.setIcon(new ImageIcon(getClass().getResource("/com/leapingbytes/almostvpn/util/images/askPassword.png")));
			avpnIcon.setLocation(new Point(10, 10));
			avpnIcon.setSize(new Dimension(48, 48));
			avpnIcon.setText("");

			promptField = new JTextArea();
			promptField.setEditable( false );
			promptField.setLineWrap( true );
			promptField.setBorder( null );
			promptField.setBackground( new Color( 0, 0, 0, 0 ));
			promptField.setWrapStyleWord( true );
			promptField.setText( _promptText );
			promptField.setLocation(new Point(60, 10));
			promptField.setFont(new Font("Lucida Grande", Font.PLAIN, 12));
			promptField.setSize(new Dimension(270, 60));
			
			passwordLabel = new JLabel();
			passwordLabel.setText("Password:");
			passwordLabel.setPreferredSize(new Dimension(100, 32));
			passwordLabel.setLocation(new Point(20, 65));
			passwordLabel.setSize(new Dimension(100, 32));
			passwordLabel.setHorizontalAlignment(SwingConstants.RIGHT);
			passwordLabel.setFont(new Font("Lucida Grande", Font.BOLD, 13));
			
			jContentPane = (JPanel) getContentPane();
			jContentPane.setLayout(null);			

			jContentPane.add(promptField, null);
			jContentPane.add(passwordLabel, null);
			jContentPane.add(getPasswordField(), null);
			jContentPane.add(getOkButton());
			jContentPane.add(getCancelButton(), null);
			jContentPane.add(avpnIcon, null);
		}
		return jContentPane;
	}

}
