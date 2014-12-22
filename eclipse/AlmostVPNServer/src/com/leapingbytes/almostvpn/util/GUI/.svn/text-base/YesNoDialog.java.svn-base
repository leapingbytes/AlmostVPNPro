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
import javax.swing.JTextArea;

public class YesNoDialog extends JFrame {
//	private static final Log log = LogFactory.getLog( PasswordDialog.class );

	private static final long	serialVersionUID	= 1L;

	private JPanel				jContentPane		= null;

//	private JLabel passwordLabel = null;

	private JTextArea promptField = null;

//	private JPasswordField passwordField = null;

	private JButton okButton = null;

	private JButton cancelButton = null;

	private JLabel avpnIcon = null;
	
	private static String _titleText = "Yes or No";
	private static String _promptText = "Select Yes or No...";
	private static String _iconPath = "/com/leapingbytes/almostvpn/util/images/askWarning.png";
	
	private static char[] _answer = null;

	/**
	 * This method initializes okButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getOkButton() {
		if (okButton == null) {
			okButton = new JButton();
			okButton.setLocation(new Point(400, 140));
			okButton.setSize(new Dimension(75, 30));
			okButton.setAction( new AbstractAction( "YES" ) {
				private static final long	serialVersionUID	= -2506235392941693705L;

				public void actionPerformed(ActionEvent e) {
					_answer = "yes".toCharArray();
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
			cancelButton.setLocation(new Point(20, 140));
			cancelButton.setSize(new Dimension(75, 30));
			cancelButton.setAction( new AbstractAction( "NO") {
				private static final long	serialVersionUID	= 1357168338138000325L;

				public void actionPerformed(ActionEvent e) {
					_answer = "no".toCharArray();
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
		
		if( _promptText.indexOf( "WARNING" ) >= 0 ) {
			_iconPath = "/com/leapingbytes/almostvpn/util/images/askError.png";
		}

		YesNoDialog thisClass = new YesNoDialog();
		thisClass.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		thisClass.show();
	}
	
	private static void closeDialog() {
		System.out.println( _answer );
		System.exit( 0 );
	}


	/**
	 * This is the default constructor
	 */
	public YesNoDialog() {
		super( _titleText );
		this.setSize(500, 200);
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
			avpnIcon.setIcon(new ImageIcon(getClass().getResource(_iconPath)));
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
			Font f = new Font("Lucida Grande", Font.PLAIN, 10);
//			f.getLineMetrics( _promptText , ((Graphics2D)this.getGraphics()).getFontRenderContext());
			promptField.setFont(f);
			
			promptField.setSize(new Dimension(420, 120));
			
//			passwordLabel = new JLabel();
//			passwordLabel.setText("Password:");
//			passwordLabel.setPreferredSize(new Dimension(100, 32));
//			passwordLabel.setLocation(new Point(20, 65));
//			passwordLabel.setSize(new Dimension(100, 32));
//			passwordLabel.setHorizontalAlignment(SwingConstants.RIGHT);
//			passwordLabel.setFont(new Font("Lucida Grande", Font.BOLD, 13));
//			
			jContentPane = (JPanel) getContentPane();
			jContentPane.setLayout(null);			

			jContentPane.add(promptField, null);
//			jContentPane.add(passwordLabel, null);
//			jContentPane.add(getPasswordField(), null);
			jContentPane.add(getOkButton());
			jContentPane.add(getCancelButton(), null);
			jContentPane.add(avpnIcon, null);
		}
		return jContentPane;
	}

}
