FasdUAS 1.101.10   ��   ��    k             l     �� ��      Ask for version number       	  l     
�� 
 I    ��  
�� .sysodlogaskr        TEXT  m         Enter Version:     ��  
�� 
dtxt  m       	 1.6     ��  
�� 
btns  J           m        Cancel      ��  m        OK   ��    �� ��
�� 
dflt  m   	 
���� ��  ��   	     l    ��  r        l    ��  n       !   1    ��
�� 
ttxt ! l    "�� " 1    ��
�� 
rslt��  ��    o      ���� 0 versionnumber versionNumber��     # $ # l     �� %��   %   Ask for build number    $  & ' & l   # (�� ( I   #�� ) *
�� .sysodlogaskr        TEXT ) m     + +  Enter Build:    * �� , -
�� 
dtxt , m     . . 	 pre    - �� / 0
�� 
btns / J     1 1  2 3 2 m     4 4  Cancel    3  5�� 5 m     6 6  OK   ��   0 �� 7��
�� 
dflt 7 m    ���� ��  ��   '  8 9 8 l  $ + :�� : r   $ + ; < ; l  $ ' =�� = n   $ ' > ? > 1   % '��
�� 
ttxt ? l  $ % @�� @ 1   $ %��
�� 
rslt��  ��   < o      ���� 0 buildnumber buildNumber��   9  A B A l     ������  ��   B  C D C l  , E�� E O   , F G F k   2
 H H  I J I r   2 9 K L K m   2 5 M M 4 ./Users/atchijov/Work/LeapingBytes/AlmostVPNPRO    L o      ���� 0 avpnpro_top AVPNPRO_TOP J  N O N r   : E P Q P b   : A R S R o   : =���� 0 avpnpro_top AVPNPRO_TOP S m   = @ T T  	/Versions    Q o      ���� $0 avpnpro_versions AVPNPRO_VERSIONS O  U V U r   F Q W X W b   F M Y Z Y o   F I���� 0 avpnpro_top AVPNPRO_TOP Z m   I L [ [ " /xcode/AlmostVPNPRO_prefPane    X o      ���� 0 avpnpro_home AVPNPRO_HOME V  \ ] \ l  R R������  ��   ]  ^ _ ^ l  R R�� `��   `   Prepare DMG    _  a b a r   R c c d c b   R _ e f e b   R [ g h g b   R W i j i m   R U k k  AlmostVPNPRO_    j o   U V���� 0 versionnumber versionNumber h o   W Z���� 0 buildnumber buildNumber f m   [ ^ l l  -tmp.dmg    d o      ���� 0 dmgname dmgName b  m n m r   d u o p o b   d q q r q b   d m s t s b   d i u v u m   d g w w  AlmostVPNPRO_    v o   g h���� 0 versionnumber versionNumber t o   i l���� 0 buildnumber buildNumber r m   m p x x 
 .dmg    p o      ���� 0 dmgfinalname dmgFinalName n  y z y r   v � { | { b   v � } ~ } b   v   �  b   v { � � � m   v y � �  
AlmostVPN_    � o   y z���� 0 versionnumber versionNumber � m   { ~ � �  _    ~ o    ����� 0 buildnumber buildNumber | o      ���� 0 
volumename 
volumeName z  � � � l  � �������  ��   �  � � � I  � ��� ���
�� .sysoexecTEXT���     TEXT � b   � � � � � b   � � � � � b   � � � � � m   � � � � 	 cd     � o   � ����� $0 avpnpro_versions AVPNPRO_VERSIONS � m   � � � �  	; rm -rf     � o   � ����� 0 dmgname dmgName��   �  � � � I  � ��� ���
�� .sysoexecTEXT���     TEXT � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � 	 cd     � o   � ����� $0 avpnpro_versions AVPNPRO_VERSIONS � m   � � � � 4 .; hdiutil create -size 10m -fs HFS+  -volname     � o   � ����� 0 
volumename 
volumeName � m   � � � �       � o   � ����� 0 dmgname dmgName��   �  � � � I  � ��� ���
�� .sysoexecTEXT���     TEXT � b   � � � � � b   � � � � � b   � � � � � m   � � � � 	 cd     � o   � ����� $0 avpnpro_versions AVPNPRO_VERSIONS � m   � � � �  ; hdiutil attach     � o   � ����� 0 dmgname dmgName��   �  � � � I  � ��� ���
�� .sysoexecTEXT���     TEXT � b   � � � � � m   � � � �  open /Volumes/    � o   � ����� 0 
volumename 
volumeName��   �  � � � l  � �������  ��   �  � � � l  � ��� ���   �   setup window    �  � � � r   � � � � � l  � � ��� � 4  � ��� �
�� 
cwin � m   � ����� ��   � o      ���� 0 targetwindow targetWindow �  � � � r   � � � � � m   � ���
�� ecvwicnv � n       � � � 1   � ���
�� 
pvew � o   � ����� 0 targetwindow targetWindow �  � � � r   � � � � � n   � � � � � m   � ���
�� 
icop � o   � ����� 0 targetwindow targetWindow � o      ���� "0 targetwindowivo targetWindowIVO �  � � � r   � � � � m   � ���
�� earrnarr � n       � � � 1  ��
�� 
iarr � l  � ��� � o   ����� "0 targetwindowivo targetWindowIVO��   �  � � � r   � � � m  
���� @ � n       � � � 1  ��
�� 
lvis � l 
 ��� � o  
���� "0 targetwindowivo targetWindowIVO��   �  � � � r   � � � m  ��
�� eposlbot � n       � � � 1  ��
�� 
lpos � l  ��� � o  ���� "0 targetwindowivo targetWindowIVO��   �  � � � l ������  ��   �  � � � r  * � � � n  & � � � m  "&��
�� 
cfol � l " ��� � o  "���� 0 targetwindow targetWindow��   � l      ��� � o      ���� 0 targetfolder targetFolder��   �  � � � l ++������  ��   �  � � � r  +6 � � � b  +2 � � � m  +. � �  	/Volumes/    � o  .1���� 0 
volumename 
volumeName � l      ��� � o      ���� $0 targetfolderpath targetFolderPath��   �  � � � l 77������  ��   �  � � � r  7B � � � b  7> � � � o  7:���� $0 targetfolderpath targetFolderPath � m  := � �  /.resources    � l      ��� � o      ���� 60 resourceshiddenfolderpath resourcesHiddenFolderPath��   �  � � � r  CN �  � b  CJ o  CF���� $0 targetfolderpath targetFolderPath m  FI  
/resources     l     �� o      ���� *0 resourcesfolderpath resourcesFolderPath��   �  l OO������  ��    I On��	��
�� .sysoexecTEXT���     TEXT	 b  Oj

 b  Of b  Ob b  O^ b  OZ b  OV m  OR  ( [ -r     o  RU���� 60 resourceshiddenfolderpath resourcesHiddenFolderPath m  VY  	 ] && mv     o  Z]���� 60 resourceshiddenfolderpath resourcesHiddenFolderPath m  ^a       o  be���� *0 resourcesfolderpath resourcesFolderPath m  fi   ) ; echo ok   ��    l oo������  ��    l oo����     deal with .resources      l oo������  ��    !"! Z  o�#$��%# H  o~&& l o}'��' I o}�(�~
� .coredoexbool        obj ( n  oy)*) 4  ry�}+
�} 
cobj+ m  ux,,  	resources   * o  or�|�| 0 targetfolder targetFolder�~  ��  $ r  ��-.- I ���{�z/
�{ .corecrel****      � null�z  / �y01
�y 
kocl0 m  ���x
�x 
cfol1 �w23
�w 
insh2 l ��4�v4 o  ���u�u 0 targetfolder targetFolder�v  3 �t5�s
�t 
prdt5 K  ��66 �r7�q
�r 
pnam7 m  ��88  	resources   �q  �s  . o      �p�p "0 resourcesfolder resourcesFolder��  % r  ��9:9 n  ��;<; 4  ���o=
�o 
cobj= m  ��>>  	resources   < o  ���n�n 0 targetfolder targetFolder: o      �m�m "0 resourcesfolder resourcesFolder" ?@? r  ��ABA J  ��CC DED m  ���l�l�E F�kF m  ���j�j��k  B n      GHG 1  ���i
�i 
posnH o  ���h�h "0 resourcesfolder resourcesFolder@ IJI l ���g�f�g  �f  J KLK l ���eM�e  M   copy all things   L NON l ���d�c�d  �c  O PQP I ���bR�a
�b .sysoexecTEXT���     TEXTR b  ��STS b  ��UVU b  ��WXW m  ��YY  cp -r    X o  ���`�` 0 avpnpro_home AVPNPRO_HOMEV m  ��ZZ + %/build/Release/AlmostVPNPRO.prefPane    T o  ���_�_ $0 targetfolderpath targetFolderPath�a  Q [\[ l ���^]�^  ] m g do shell script "cp -r " & AVPNPRO_HOME & "/build/Release/AlmostVPNProMenuBar.app " & targetFolderPath   \ ^_^ I ���]`�\
�] .sysoexecTEXT���     TEXT` b  ��aba b  ��cdc b  ��efe b  ��ghg m  ��ii ! tar cf - --exclude .svn -C    h o  ���[�[ 0 avpnpro_home AVPNPRO_HOMEf m  ��jj 7 1/Distro/Extras AlmostVPNPRO.cleanup.app | tar -C    d o  ���Z�Z $0 targetfolderpath targetFolderPathb m  ��kk   -xf -   �\  _ lml I ��Yn�X
�Y .sysoexecTEXT���     TEXTn b  ��opo b  ��qrq b  ��sts m  ��uu  cp -r    t o  ���W�W 0 avpnpro_home AVPNPRO_HOMEr m  ��vv N H/../AlmostVPNPRO.Uninstaller/build/Release/AlmostVPNPRO.Uninstaller.app    p o  ���V�V $0 targetfolderpath targetFolderPath�X  m wxw l �U�T�U  �T  x yzy r  {|{ b  }~} o  �S�S 0 avpnpro_home AVPNPRO_HOME~ m  
  /Resources/Images   | o      �R�R 0 avpnpro_icons AVPNPRO_ICONSz ��� r  ��� b  ��� o  �Q�Q 0 avpnpro_home AVPNPRO_HOME� m  ��  /Distro/Collateral   � o      �P�P (0 avpnpro_collateral AVPNPRO_COLLATERAL� ��� I /�O��N
�O .sysoexecTEXT���     TEXT� b  +��� b  '��� b  #��� m  �� 	 cp    � o  "�M�M 0 avpnpro_icons AVPNPRO_ICONS� m  #&��  /AlmostVPNPRO.icns    � o  '*�L�L *0 resourcesfolderpath resourcesFolderPath�N  � ��� l 00�K��K  � } w do shell script "cp " & AVPNPRO_HOME & "/Sources/MenuBar.target/Icons/AlmostVPNPROMenuBar.icns " & resourcesFolderPath   � ��� I 0C�J��I
�J .sysoexecTEXT���     TEXT� b  0?��� b  0;��� b  07��� m  03�� 	 cp    � o  36�H�H (0 avpnpro_collateral AVPNPRO_COLLATERAL� m  7:��  /AlmostVPNPRO_Link.icns    � o  ;>�G�G *0 resourcesfolderpath resourcesFolderPath�I  � ��� I DW�F��E
�F .sysoexecTEXT���     TEXT� b  DS��� b  DO��� b  DK��� m  DG�� 	 cp    � o  GJ�D�D (0 avpnpro_collateral AVPNPRO_COLLATERAL� m  KN�� # /AlmostVPNPRO_Uninstall.icns    � o  OR�C�C *0 resourcesfolderpath resourcesFolderPath�E  � ��� I Xk�B��A
�B .sysoexecTEXT���     TEXT� b  Xg��� b  Xc��� b  X_��� m  X[�� 	 cp    � o  [^�@�@ 0 avpnpro_icons AVPNPRO_ICONS� m  _b�� ! /AlmostVPNPRO_Cleanup.icns    � o  cf�?�? *0 resourcesfolderpath resourcesFolderPath�A  � ��� I l�>��=
�> .sysoexecTEXT���     TEXT� b  l{��� b  lw��� b  ls��� m  lo�� 	 cp    � o  or�<�< (0 avpnpro_collateral AVPNPRO_COLLATERAL� m  sv��  /LBLogo_Link.icns    � o  wz�;�; *0 resourcesfolderpath resourcesFolderPath�=  � ��� I ���:��9
�: .sysoexecTEXT���     TEXT� b  ����� b  ����� b  ����� m  ���� 	 cp    � o  ���8�8 (0 avpnpro_collateral AVPNPRO_COLLATERAL� m  ����  /AlmostVPNPRO_bg.png    � o  ���7�7 *0 resourcesfolderpath resourcesFolderPath�9  � ��� I ���6��5
�6 .sysoexecTEXT���     TEXT� b  ����� b  ����� b  ����� m  ���� 	 cp    � o  ���4�4 (0 avpnpro_collateral AVPNPRO_COLLATERAL� m  ���� # /AlmostVPNPRO_diskimage.icns    � o  ���3�3 *0 resourcesfolderpath resourcesFolderPath�5  � ��� l ���2�1�2  �1  � ��� l ���0��0  �   init all icons	   � ��� r  ����� n ����� I  ���/��.�/ 0 geticon getIcon� ��� m  ����  AlmostVPNPRO.icns   � ��� o  ���-�- 0 targetfolder targetFolder� ��,� o  ���+�+ "0 resourcesfolder resourcesFolder�,  �.  �  f  ��� o      �*�* 0 avpnicon avpnIcon� ��� l ���)��)  � c ] set avpnMenuBarIcon to my getIcon("AlmostVPNPROMenuBar.icns", targetFolder, resourcesFolder)   � ��� r  ����� n ����� I  ���(��'�( 0 geticon getIcon� ��� m  ����  AlmostVPNPRO_Link.icns   � ��� o  ���&�& 0 targetfolder targetFolder� ��%� o  ���$�$ "0 resourcesfolder resourcesFolder�%  �'  �  f  ��� o      �#�# 0 avpnlinkicon avpnLinkIcon� ��� r  ����� n ����� I  ���"��!�" 0 geticon getIcon�    m  �� ! AlmostVPNPRO_Uninstall.icns     o  ��� �  0 targetfolder targetFolder � o  ���� "0 resourcesfolder resourcesFolder�  �!  �  f  ��� o      �� &0 avpnuninstallicon avpnUninstallIcon�  r  ��	 n ��

 I  ����� 0 geticon getIcon  m  ��  AlmostVPNPRO_Cleanup.icns     o  ���� 0 targetfolder targetFolder � o  ���� "0 resourcesfolder resourcesFolder�  �    f  ��	 o      �� "0 avpncleanupicon avpnCleanupIcon  r  � n � I  ���� 0 geticon getIcon  m  ��  LBLogo_Link.icns     o  ���� 0 targetfolder targetFolder � o  ���� "0 resourcesfolder resourcesFolder�  �    f  �� o      �� 0 
lblinkicon 
lbLinkIcon  !  r  "#" n $%$ I  �&�� 0 geticon getIcon& '(' m  ))  AlmostVPNPRO_bg.png   ( *+* o  �� 0 targetfolder targetFolder+ ,�, o  �� "0 resourcesfolder resourcesFolder�  �  %  f  # o      �� 0 bgimage bgImage! -.- r  ,/0/ n (121 I  (�
3�	�
 0 geticon getIcon3 454 m  66 ! AlmostVPNPRO_diskimage.icns   5 787 o  !�� 0 targetfolder targetFolder8 9�9 o  !$�� "0 resourcesfolder resourcesFolder�  �	  2  f  0 o      �� 0 dmgicon dmgIcon. :;: l --���  �  ; <=< l --�>�  > 6 0 set dmgFile to AVPNPRO_VERSIONS & "/" & dmgName   = ?@? r  -]ABA l -YC�C n  -YDED 4  RY� F
�  
cobjF o  UX���� 0 dmgname dmgNameE l -RG��G n  -RHIH 4  KR��J
�� 
cobjJ m  NQKK  Versions   I l -KL��L n  -KMNM 4  DK��O
�� 
cobjO m  GJPP  AlmostVPNPRO   N l -DQ��Q n  -DRSR 4  =D��T
�� 
cobjT m  @CUU  LeapingBytes   S l -=V��V n  -=WXW 4  6=��Y
�� 
cobjY m  9<ZZ 
 Work   X l -6[��[ n  -6\]\ m  26��
�� 
ctnr] 1  -2��
�� 
desk��  ��  ��  ��  ��  �  B o      ���� 0 dmgfile dmgFile@ ^_^ l ^^������  ��  _ `a` n ^ibcb I  _i��d���� &0 setcustomfileicon setCustomFileIcond efe o  _b���� 0 dmgfile dmgFilef g��g o  be���� 0 dmgicon dmgIcon��  ��  c  f  ^_a hih l jj������  ��  i jkj l jj��l��  l   init all apps   k mnm r  juopo l jmq��q o  jm���� 0 bgimage bgImage��  p n      rsr 1  pt��
�� 
ibkgs l mpt��t o  mp���� "0 targetwindowivo targetWindowIVO��  n uvu l vv������  ��  v wxw r  v�yzy n  v�{|{ 4  y���}
�� 
cobj} m  |~~  AlmostVPNPRO.prefPane   | o  vy���� 0 targetfolder targetFolderz o      ���� 0 avpnprefpan avpnPrefPanx � l �������  � H B set avpnMenuBar to item "AlmostVPNProMenuBar.app" of targetFolder   � ��� r  ����� n  ����� 4  �����
�� 
cobj� m  ���� " AlmostVPNPRO.Uninstaller.app   � o  ������ 0 targetfolder targetFolder� o      ���� 0 avpnuninstall avpnUninstall� ��� r  ����� n  ����� 4  �����
�� 
cobj� m  ����  AlmostVPNPRO.cleanup.app   � o  ������ 0 targetfolder targetFolder� o      ���� 0 	avpnclean 	avpnClean� ��� l ��������  ��  � ��� l �������  � ; 5 my setCustomFolderIcon(avpnMenuBar, avpnMenuBarIcon)   � ��� n ����� I  ��������� *0 setcustomfoldericon setCustomFolderIcon� ��� o  ������ 0 avpnuninstall avpnUninstall� ���� o  ������ &0 avpnuninstallicon avpnUninstallIcon��  ��  �  f  ��� ��� n ����� I  ��������� *0 setcustomfoldericon setCustomFolderIcon� ��� o  ������ 0 	avpnclean 	avpnClean� ���� o  ������ "0 avpncleanupicon avpnCleanupIcon��  ��  �  f  ��� ��� l ��������  ��  � ��� l  �������  � � �
	set position of avpnPrefPan to {100, 100}
	set position of avpnUninstall to {300, 250}
	set position of avpnClean to {500, 250}
	   � ��� l ��������  ��  � ��� l �������  � ( " create web link to release notes	   � ��� r  ����� n ����� I  ��������� 0 createalinkto createALinkTo� ��� o  ������ 0 targetfolder targetFolder� ��� b  ����� b  ����� b  ����� b  ����� b  ����� l 	������ m  ����  Release Notes   ��  � o  ����
�� 
ret � m  ����  AlmostVPNPRO    � o  ������ 0 versionnumber versionNumber� m  ����      � o  ������ 0 buildnumber buildNumber� ��� l 	������ o  ������ 0 avpnlinkicon avpnLinkIcon��  � ��� b  ����� b  ����� m  ���� K Ehttp://www.leapingbytes.com/almostvpn/wiki/AlmostVPNPRO_ReleaseNotes_   � o  ������ 0 versionnumber versionNumber� o  ������ 0 buildnumber buildNumber� ��� l 	������ m  ������,��  � ���� l 
������ m  ������ d��  ��  ��  �  f  ��� o      ���� $0 avpnreleasenotes avpnReleaseNotes� ��� l ��������  ��  � ��� l �������  � ) # create web link to AVPN home page	   � ��� r  �
��� n ���� I  �������� 0 createalinkto createALinkTo� ��� o  ������ 0 targetfolder targetFolder� ��� m  ���� $ AlmostVPNPRO Official Web Site   � ��� o  ������ 0 avpnlinkicon avpnLinkIcon� ��� m  ���� + %http://www.leapingbytes.com/almostvpn   � ��� m  �������� ���� m  ����� d��  ��  �  f  ��� o      ���� 0 avpnwebsite avpnWebSite� ��� l ������  ��  � ��� l �����  � 2 , create web link to Leaping Bytes home page	   � ��� r  .��� n *��� I  *������� 0 createalinkto createALinkTo� ��� o  ���� 0 targetfolder targetFolder�    b   b   m    Developed by    o  ��
�� 
ret  m    Leaping Bytes, LLC    	 o  ���� 0 
lblinkicon 
lbLinkIcon	 

 m    ! http://www.leapingbytes.com     m   #���� d �� m  #&���� ���  ��  �  f  � o      ���� "0 avpndevelopedby avpnDevelopedBy�  l //������  ��    I /N����
�� .sysoexecTEXT���     TEXT b  /J b  /F b  /B b  /> b  /: b  /6  m  /2!!  ( [ -r      o  25���� *0 resourcesfolderpath resourcesFolderPath m  69""  	 ] && mv     o  :=���� *0 resourcesfolderpath resourcesFolderPath m  >A##       o  BE���� 60 resourceshiddenfolderpath resourcesHiddenFolderPath m  FI$$   ) ; echo ok   ��   %&% l OO������  ��  & '(' r  OZ)*) m  OR��
�� earrnarr* n      +,+ 1  UY��
�� 
iarr, l RU-��- o  RU���� "0 targetwindowivo targetWindowIVO��  ( ./. l [[������  ��  / 010 r  [k232 J  [c44 565 m  [^���� d6 7��7 m  ^a���� d��  3 n      898 1  fj��
�� 
posn9 o  cf���� 0 avpnprefpan avpnPrefPan1 :;: r  l|<=< J  lt>> ?@? m  lo���� d@ A��A m  or���� ���  = n      BCB 1  w{��
�� 
posnC o  tw���� "0 avpndevelopedby avpnDevelopedBy; DED r  }�FGF J  }�HH IJI m  }�����,J K��K m  ������ d��  G n      LML 1  ����
�� 
posnM o  ���� $0 avpnreleasenotes avpnReleaseNotesE NON r  ��PQP J  ��RR STS m  ���~�~,T U�}U m  ���|�| ��}  Q n      VWV 1  ���{
�{ 
posnW o  ���z�z 0 avpnuninstall avpnUninstallO XYX r  ��Z[Z J  ��\\ ]^] m  ���y�y�^ _�x_ m  ���w�w d�x  [ n      `a` 1  ���v
�v 
posna o  ���u�u 0 avpnwebsite avpnWebSiteY bcb r  ��ded J  ��ff ghg m  ���t�t�h i�si m  ���r�r ��s  e n      jkj 1  ���q
�q 
posnk o  ���p�p 0 	avpnclean 	avpnCleanc lml l ���o�n�o  �n  m non I ���mpq
�m .sysodlogaskr        TEXTp m  ��rr  Does it look OK   q �lst
�l 
dtxts m  ��uu  OK   t �kvw
�k 
btnsv J  ��xx yzy m  ��{{  Cancel   z |�j| m  ��}}  OK   �j  w �i~�h
�i 
dflt~ m  ���g�g �h  o � l ���f�e�f  �e  � ��� I ���d��c
�d .coreclosnull���    obj � 4 ���b�
�b 
cwin� m  ���a�a �c  � ��� l ���`�_�`  �_  � ��� I ���^��]
�^ .sysoexecTEXT���     TEXT� b  ����� m  ����  hdiutil detach /Volumes/   � o  ���\�\ 0 
volumename 
volumeName�]  � ��� l ���[�Z�[  �Z  � ��� l ���Y��Y  � � � set dmgFile to (item (name of targetFolder & ".dmg") of (item "Versions" of (item "AlmostVPNPRO" of (item "LeapingBytes" of (item "Work" of (container of desktop))))))   � ��� l  ���X��X  � � �
	do shell script "cd " & AVPNPRO_VERSIONS & "; mv " & dmgName & " " & dmgName & ".org; hdiutil convert " & dmgName & ".org -format UDCO -o " & dmgName & "; rm -rf " & dmgName & ".org"
	   � ��W� I �
�V��U
�V .sysoexecTEXT���     TEXT� b  ���� b  ���� b  ����� b  ����� b  ����� m  ���� 	 cd    � o  ���T�T $0 avpnpro_versions AVPNPRO_VERSIONS� m  ����  ; hdiutil convert    � o  ���S�S 0 dmgname dmgName� m  ���   -format UDCO -o    � o  �R�R 0 dmgfinalname dmgFinalName�U  �W   G m   , /���null     ߀�� /j�
Finder.app���  ���- ��������   z�   )       �8(��Y�����MACS   alis    b  BigDisk                    �ڙ�H+   /j�
Finder.app                                                      /�4�g~5        ����  	                CoreServices    ���4      �gą     /j� /j� /j�  .BigDisk:System:Library:CoreServices:Finder.app   
 F i n d e r . a p p    B i g D i s k  &System/Library/CoreServices/Finder.app  / ��  ��   D ��� l     �Q�P�Q  �P  � ��� i     ��� I      �O��N�O 0 createalinkto createALinkTo� ��� o      �M�M 0 targetfolder targetFolder� ��� o      �L�L 0 	linktitle 	linkTitle� ��� o      �K�K 0 linkicon linkIcon� ��� o      �J�J 0 linkurl linkURL� ��� o      �I�I 0 x  � ��H� o      �G�G 0 y  �H  �N  � k     *�� ��� Z     ���F�� H     	�� l    ��E� I    �D��C
�D .coredoexbool        obj � n     ��� 4    �B�
�B 
cobj� o    �A�A 0 	linktitle 	linkTitle� o     �@�@ 0 targetfolder targetFolder�C  �E  � r    ��� n   ��� l 	  ��?� I    �>��=�> (0 createinternetlink createInternetLink� ��� o    �<�< 0 targetfolder targetFolder� ��� l 	  ��;� o    �:�: 0 	linktitle 	linkTitle�;  � ��9� l 	  ��8� o    �7�7 0 linkurl linkURL�8  �9  �=  �?  �  f    � o      �6�6 0 newlink newLink�F  � r    ��� n    ��� 4    �5�
�5 
cobj� o    �4�4 0 	linktitle 	linkTitle� o    �3�3 0 targetfolder targetFolder� o      �2�2 0 newlink newLink� ��� n    '��� I   ! '�1��0�1 &0 setcustomfileicon setCustomFileIcon� ��� o   ! "�/�/ 0 newlink newLink� ��.� o   " #�-�- 0 linkicon linkIcon�.  �0  �  f     !� ��� l  ( (�,��,  � I C	tell application "Finder" to set position of the newLink to {x, y}   � ��� l  ( (�+��+  � I C tell application "Finder" to set position of the newLink to {x, y}   � ��*� L   ( *�� o   ( )�)�) 0 newlink newLink�*  � ��� l     �(�'�(  �'  � ��� i    ��� I      �&��%�& 0 asposixpath asPosixPath� ��$� o      �#�# 0 apath aPath�$  �%  � k     �� ��� r     ��� l    ��"� m     ��  :   �"  � n     ��� 1    �!
�! 
txdl� 1    � 
�  
ascr� ��� r    ��� n    ��� 2   	 �
� 
citm� l   	��� l   	��� c    	��� o    �� 0 apath aPath� m    �
� 
TEXT�  �  � l      �  o      �� 0 	pathparts 	pathParts�  �  r     l   � m      /   �   n      1    �
� 
txdl 1    �
� 
ascr 	�	 r    

 c     l   � o    �� 0 	pathparts 	pathParts�   m    �
� 
TEXT 1      �
� 
rslt�  �  i     I      ��� 0 	asmacpath 	asMacPath � o      �� 0 apath aPath�  �   k     ,  r      l    � m       /   �   n      1    �
� 
txdl 1    �

�
 
ascr  r     !  n    "#" 2   	 �	
�	 
citm# l   	$�$ l   	%�% c    	&'& o    �� 0 apath aPath' m    �
� 
TEXT�  �  ! l     (�( o      �� 0 	pathparts 	pathParts�   )*) Z     +,��+ =   -.- n    /0/ 4    � 1
�  
cobj1 m    ���� 0 o    ���� 0 	pathparts 	pathParts. m    22      , r    343 n    565 1    ��
�� 
rest6 o    ���� 0 	pathparts 	pathParts4 o      ���� 0 	pathparts 	pathParts�  �  * 787 r   ! &9:9 l  ! ";��; m   ! "<<  :   ��  : n     =>= 1   # %��
�� 
txdl> 1   " #��
�� 
ascr8 ?��? r   ' ,@A@ c   ' *BCB l  ' (D��D o   ' (���� 0 	pathparts 	pathParts��  C m   ( )��
�� 
TEXTA 1      ��
�� 
rslt��   EFE l     ������  ��  F GHG i    IJI I      ��K���� *0 setcustomfoldericon setCustomFolderIconK LML o      ���� 0 targetfolder targetFolderM N��N o      ���� 0 
targeticon 
targetIcon��  ��  J k     6OO PQP r     
RSR b     TUT m     VV  	/Volumes/   U n   WXW I    ��Y���� 0 asposixpath asPosixPathY Z��Z o    ���� 0 targetfolder targetFolder��  ��  X  f    S l     [��[ o      ���� &0 posixtargetfolder posixTargetFolder��  Q \]\ r    ^_^ b    `a` m    bb  	/Volumes/   a n   cdc I    ��e���� 0 asposixpath asPosixPathe f��f o    ���� 0 
targeticon 
targetIcon��  ��  d  f    _ l     g��g o      ���� "0 posixtargeticon posixTargetIcon��  ] hih l   ������  ��  i jkj l   ��l��  l A ; display alert posixTargetFolder & return & posixTargetIcon   k mnm l   ������  ��  n opo I   #��q��
�� .sysoexecTEXT���     TEXTq b    rsr b    tut b    vwv b    xyx m    zz # echo "read 'icns' (-16455) \"   y o    ���� "0 posixtargeticon posixTargetIconw m    {{ . (\";" | /Developer/Tools/Rez -o `printf "   u o    ���� &0 posixtargetfolder posixTargetFolders m    ||  	/Icon\r"`   ��  p }~} I  $ +����
�� .sysoexecTEXT���     TEXT b   $ '��� m   $ %�� $ /Developer/Tools/SetFile -a C    � o   % &���� &0 posixtargetfolder posixTargetFolder��  ~ ���� O   , 6��� I  0 5�����
�� .fndrfupdnull���     obj � o   0 1���� 0 targetfolder targetFolder��  � m   , -���  H ��� l     ������  ��  � ��� i    ��� I      ������� &0 setcustomfileicon setCustomFileIcon� ��� o      ���� 0 
targetfile 
targetFile� ���� o      ���� 0 
targeticon 
targetIcon��  ��  � k     E�� ��� r     ��� l    ���� m     ��  :   ��  � n     ��� 1    ��
�� 
txdl� 1    ��
�� 
ascr� ��� r    ��� n    ��� 2   	 ��
�� 
citm� l   	���� l   	���� c    	��� o    ���� 0 
targetfile 
targetFile� m    ��
�� 
TEXT��  ��  � l     ���� o      ���� 0 filepathparts filePathParts��  � ��� r    ��� n    ��� 2    ��
�� 
citm� l   ���� l   ���� c    ��� o    ���� 0 
targeticon 
targetIcon� m    ��
�� 
TEXT��  ��  � l     ���� o      ���� 0 iconpathparts iconPathParts��  � ��� r    ��� l   ���� m    ��  /   ��  � n     ��� 1    ��
�� 
txdl� 1    ��
�� 
ascr� ��� l   �����  � K E set the posixTargetFile to the "/Volumes/" & filePathParts as string   � ��� r    #��� c    !��� b    ��� l   ���� m    ��  	/Volumes/   ��  � o    ���� 0 filepathparts filePathParts� m     ��
�� 
TEXT� l     ���� o      ���� "0 posixtargetfile posixTargetFile��  � ��� r   $ +��� c   $ )��� b   $ '��� l  $ %���� m   $ %��  	/Volumes/   ��  � o   % &���� 0 iconpathparts iconPathParts� m   ' (��
�� 
TEXT� l     ���� o      ���� "0 posixtargeticon posixTargetIcon��  � ��� l  , ,������  ��  � ��� l  , ,�����  � %  display dialog posixTargetFile   � ��� l  , ,������  ��  � ��� I  , 9�����
�� .sysoexecTEXT���     TEXT� b   , 5��� b   , 3��� b   , 1��� b   , /��� m   , -�� # echo "read 'icns' (-16455) \"   � o   - .���� "0 posixtargeticon posixTargetIcon� m   / 0�� &  \";" | /Developer/Tools/Rez -o "   � o   1 2���� "0 posixtargetfile posixTargetFile� m   3 4��  "   ��  � ��� I  : C�����
�� .sysoexecTEXT���     TEXT� b   : ?��� b   : =��� m   : ;�� % /Developer/Tools/SetFile -a C "   � o   ; <���� "0 posixtargetfile posixTargetFile� m   = >��  "   ��  � ���� l   D D�����  � A ;
	tell application "Finder"
		update targetFile
	end tell
	   ��  � ��� l     ������  ��  � ��� i    ��� I      ������� (0 createinternetlink createInternetLink� ��� o      ���� 0 targetfolder targetFolder� ��� o      ���� 0 alabel aLabel� ���� o      ���� 0 targeurl targeURL��  ��  � O     ��� I   �����
�� .corecrel****      � null��  � �� 
�� 
kocl  m    ��
�� 
inlf ��
�� 
insh o    	���� 0 targetfolder targetFolder ��
�� 
prdt K   
  ����
�� 
pnam o    ���� 0 alabel aLabel��   ����
�� 
to   o    ���� 0 targeurl targeURL��  � m     �� 	
	 l     ������  ��  
  i     I      ������ 0 geticon getIcon  o      ���� 0 iconname iconName  o      ���� 0 	topfolder 	topFolder �� o      �� "0 resourcesfolder resourcesFolder��  ��   k     c  r      n      1    �~
�~ 
pcnt o     �}�} 0 	topfolder 	topFolder o      �|�| 0 	topfolder 	topFolder  r     n    	 !  1    	�{
�{ 
pcnt! o    �z�z "0 resourcesfolder resourcesFolder o      �y�y "0 resourcesfolder resourcesFolder "�x" Z    c#$%&# I   �w'�v
�w .coredoexbool        obj ' n    ()( 4    �u*
�u 
cobj* o    �t�t 0 iconname iconName) o    �s�s "0 resourcesfolder resourcesFolder�v  $ L    ++ c    ,-, n    ./. 4    �r0
�r 
cobj0 o    �q�q 0 iconname iconName/ o    �p�p "0 resourcesfolder resourcesFolder- m    �o
�o 
alis% 121 I  ! )�n3�m
�n .coredoexbool        obj 3 n   ! %454 4   " %�l6
�l 
cobj6 o   # $�k�k 0 iconname iconName5 o   ! "�j�j 0 	topfolder 	topFolder�m  2 7�i7 k   , O88 9:9 r   , 4;<; c   , 2=>= n   , 0?@? 4   - 0�hA
�h 
cobjA o   . /�g�g 0 iconname iconName@ o   , -�f�f 0 	topfolder 	topFolder> m   0 1�e
�e 
alis< o      �d�d 0 
resulticon 
resultIcon: BCB I  5 L�cD�b
�c .sysoexecTEXT���     TEXTD b   5 HEFE b   5 AGHG b   5 ?IJI b   5 =KLK m   5 6MM  mv /Volumes/   L n  6 <NON I   7 <�aP�`�a 0 asposixpath asPosixPathP Q�_Q o   7 8�^�^ 0 	topfolder 	topFolder�_  �`  O  f   6 7J o   = >�]�] 0 iconname iconNameH m   ? @RR  
 /Volumes/   F n  A GSTS I   B G�\U�[�\ 0 asposixpath asPosixPathU V�ZV o   B C�Y�Y "0 resourcesfolder resourcesFolder�Z  �[  T  f   A B�b  C WXW l  M M�XY�X  Y ) # move resultIcon to resourcesFolder   X Z�WZ L   M O[[ o   M N�V�V 0 
resulticon 
resultIcon�W  �i  & I  R c�U\�T
�U .sysodisAaleR        TEXT\ b   R _]^] b   R ]_`_ b   R [aba b   R Ycdc b   R Wefe b   R Ughg m   R Sii  Can not find icon    h o   S T�S�S 0 iconname iconNamef m   U Vjj   in these folders:   d o   W X�R
�R 
ret b o   Y Z�Q�Q 0 	topfolder 	topFolder` o   [ \�P
�P 
ret ^ o   ] ^�O�O "0 resourcesfolder resourcesFolder�T  �x   k�Nk l     �M�L�M  �L  �N       B�Klmnopqrstuv Mwxyz{|}~��������������������J�I�H�G�F�E�D�C�B�A�@�?�>�=�<�;�:�9�8�7�6�5�4�3�2�K  l @�1�0�/�.�-�,�+�*�)�(�'�&�%�$�#�"�!� ����������������������
�	��������� �����������������������������1 0 createalinkto createALinkTo�0 0 asposixpath asPosixPath�/ 0 	asmacpath 	asMacPath�. *0 setcustomfoldericon setCustomFolderIcon�- &0 setcustomfileicon setCustomFileIcon�, (0 createinternetlink createInternetLink�+ 0 geticon getIcon
�* .aevtoappnull  �   � ****�) 0 versionnumber versionNumber�( 0 buildnumber buildNumber�' 0 avpnpro_top AVPNPRO_TOP�& $0 avpnpro_versions AVPNPRO_VERSIONS�% 0 avpnpro_home AVPNPRO_HOME�$ 0 dmgname dmgName�# 0 dmgfinalname dmgFinalName�" 0 
volumename 
volumeName�! 0 targetwindow targetWindow�  "0 targetwindowivo targetWindowIVO� 0 targetfolder targetFolder� $0 targetfolderpath targetFolderPath� 60 resourceshiddenfolderpath resourcesHiddenFolderPath� *0 resourcesfolderpath resourcesFolderPath� "0 resourcesfolder resourcesFolder� 0 avpnpro_icons AVPNPRO_ICONS� (0 avpnpro_collateral AVPNPRO_COLLATERAL� 0 avpnicon avpnIcon� 0 avpnlinkicon avpnLinkIcon� &0 avpnuninstallicon avpnUninstallIcon� "0 avpncleanupicon avpnCleanupIcon� 0 
lblinkicon 
lbLinkIcon� 0 bgimage bgImage� 0 dmgicon dmgIcon� 0 dmgfile dmgFile� 0 avpnprefpan avpnPrefPan� 0 avpnuninstall avpnUninstall� 0 	avpnclean 	avpnClean� $0 avpnreleasenotes avpnReleaseNotes� 0 avpnwebsite avpnWebSite� "0 avpndevelopedby avpnDevelopedBy�
  �	  �  �  �  �  �  �  �  �  �   ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  m ������������� 0 createalinkto createALinkTo�� ����� �  �������������� 0 targetfolder targetFolder�� 0 	linktitle 	linkTitle�� 0 linkicon linkIcon�� 0 linkurl linkURL�� 0 x  �� 0 y  ��  � ���������������� 0 targetfolder targetFolder�� 0 	linktitle 	linkTitle�� 0 linkicon linkIcon�� 0 linkurl linkURL�� 0 x  �� 0 y  �� 0 newlink newLink� ��������
�� 
cobj
�� .coredoexbool        obj �� (0 createinternetlink createInternetLink�� &0 setcustomfileicon setCustomFileIcon�� +��/j  )���m+ E�Y ��/E�O)��l+ O�n ������������� 0 asposixpath asPosixPath�� ����� �  ���� 0 apath aPath��  � ������ 0 apath aPath�� 0 	pathparts 	pathParts� �����������
�� 
ascr
�� 
txdl
�� 
TEXT
�� 
citm
�� 
rslt�� ���,FO��&�-E�O���,FO��&E�o ������������ 0 	asmacpath 	asMacPath�� ����� �  ���� 0 apath aPath��  � ������ 0 apath aPath�� 0 	pathparts 	pathParts� 
����������2��<��
�� 
ascr
�� 
txdl
�� 
TEXT
�� 
citm
�� 
cobj
�� 
rest
�� 
rslt�� -���,FO��&�-E�O��k/�  
��,E�Y hO���,FO��&E�p ��J���������� *0 setcustomfoldericon setCustomFolderIcon�� ����� �  ������ 0 targetfolder targetFolder�� 0 
targeticon 
targetIcon��  � ���������� 0 targetfolder targetFolder�� 0 
targeticon 
targetIcon�� &0 posixtargetfolder posixTargetFolder�� "0 posixtargeticon posixTargetIcon� 
V��bz{|�������� 0 asposixpath asPosixPath
�� .sysoexecTEXT���     TEXT
�� .fndrfupdnull���     obj �� 7�)�k+ %E�O�)�k+ %E�O�%�%�%�%j O�%j O� �j 	Uq ������������� &0 setcustomfileicon setCustomFileIcon�� ����� �  ������ 0 
targetfile 
targetFile�� 0 
targeticon 
targetIcon��  � �������������� 0 
targetfile 
targetFile�� 0 
targeticon 
targetIcon�� 0 filepathparts filePathParts�� 0 iconpathparts iconPathParts�� "0 posixtargetfile posixTargetFile�� "0 posixtargeticon posixTargetIcon� �������������������
�� 
ascr
�� 
txdl
�� 
TEXT
�� 
citm
�� .sysoexecTEXT���     TEXT�� F���,FO��&�-E�O��&�-E�O���,FO�%�&E�O�%�&E�O�%�%�%�%j O�%�%j OPr ������������� (0 createinternetlink createInternetLink�� ����� �  �������� 0 targetfolder targetFolder�� 0 alabel aLabel�� 0 targeurl targeURL��  � �������� 0 targetfolder targetFolder�� 0 alabel aLabel�� 0 targeurl targeURL� 	�����������������
�� 
kocl
�� 
inlf
�� 
insh
�� 
prdt
�� 
pnam
�� 
to  �� 
�� .corecrel****      � null�� � *�����l�� Us ������������ 0 geticon getIcon�� ����� �  �������� 0 iconname iconName�� 0 	topfolder 	topFolder�� "0 resourcesfolder resourcesFolder��  � ���������� 0 iconname iconName�� 0 	topfolder 	topFolder�� "0 resourcesfolder resourcesFolder�� 0 
resulticon 
resultIcon� ����~�}M�|R�{ij�z�y
�� 
pcnt
� 
cobj
�~ .coredoexbool        obj 
�} 
alis�| 0 asposixpath asPosixPath
�{ .sysoexecTEXT���     TEXT
�z 
ret 
�y .sysodisAaleR        TEXT�� d��,E�O��,E�O��/j  ��/�&Y D��/j  (��/�&E�O�)�k+ %�%�%)�k+ %j O�Y �%�%�%�%�%�%j t �x��w�v���u
�x .aevtoappnull  �   � ****� k    ��  ��  ��  &��  8��  C�t�t  �w  �v  �  � � �s �r  �q�p�o�n�m�l + . 4 6�k� M�j T�i [�h k l�g w x�f � ��e � ��d � � � � � ��c�b�a�`�_�^�]�\�[�Z�Y�X�W�V ��U ��T�S�R,�Q�P�O�N�M8�L�K>�J�IYZijkuv�H��G����������������F�E��D�C�B�A)�@6�?�>�=ZUPK�<�;�:~�9��8��7�6��5����4�3�2�1���0�/�.�-!"#$ru{}�,����
�s 
dtxt
�r 
btns
�q 
dflt�p 
�o .sysodlogaskr        TEXT
�n 
rslt
�m 
ttxt�l 0 versionnumber versionNumber�k 0 buildnumber buildNumber�j 0 avpnpro_top AVPNPRO_TOP�i $0 avpnpro_versions AVPNPRO_VERSIONS�h 0 avpnpro_home AVPNPRO_HOME�g 0 dmgname dmgName�f 0 dmgfinalname dmgFinalName�e 0 
volumename 
volumeName
�d .sysoexecTEXT���     TEXT
�c 
cwin�b 0 targetwindow targetWindow
�a ecvwicnv
�` 
pvew
�_ 
icop�^ "0 targetwindowivo targetWindowIVO
�] earrnarr
�\ 
iarr�[ @
�Z 
lvis
�Y eposlbot
�X 
lpos
�W 
cfol�V 0 targetfolder targetFolder�U $0 targetfolderpath targetFolderPath�T 60 resourceshiddenfolderpath resourcesHiddenFolderPath�S *0 resourcesfolderpath resourcesFolderPath
�R 
cobj
�Q .coredoexbool        obj 
�P 
kocl
�O 
insh
�N 
prdt
�M 
pnam
�L .corecrel****      � null�K "0 resourcesfolder resourcesFolder�J�
�I 
posn�H 0 avpnpro_icons AVPNPRO_ICONS�G (0 avpnpro_collateral AVPNPRO_COLLATERAL�F 0 geticon getIcon�E 0 avpnicon avpnIcon�D 0 avpnlinkicon avpnLinkIcon�C &0 avpnuninstallicon avpnUninstallIcon�B "0 avpncleanupicon avpnCleanupIcon�A 0 
lblinkicon 
lbLinkIcon�@ 0 bgimage bgImage�? 0 dmgicon dmgIcon
�> 
desk
�= 
ctnr�< 0 dmgfile dmgFile�; &0 setcustomfileicon setCustomFileIcon
�: 
ibkg�9 0 avpnprefpan avpnPrefPan�8 0 avpnuninstall avpnUninstall�7 0 	avpnclean 	avpnClean�6 *0 setcustomfoldericon setCustomFolderIcon
�5 
ret �4,�3 d�2 0 createalinkto createALinkTo�1 $0 avpnreleasenotes avpnReleaseNotes�0��/ 0 avpnwebsite avpnWebSite�. ��- "0 avpndevelopedby avpnDevelopedBy
�, .coreclosnull���    obj �u������lv�l� O��,E�O������lv�l� O��,E` Oa �a E` O_ a %E` O_ a %E` Oa �%_ %a %E` Oa �%_ %a %E` Oa �%a %_ %E`  Oa !_ %a "%_ %j #Oa $_ %a %%_  %a &%_ %j #Oa '_ %a (%_ %j #Oa )_  %j #O*a *k/E` +Oa ,_ +a -,FO_ +a .,E` /Oa 0_ /a 1,FOa 2_ /a 3,FOa 4_ /a 5,FO_ +a 6,E` 7Oa 8_  %E` 9O_ 9a :%E` ;O_ 9a <%E` =Oa >_ ;%a ?%_ ;%a @%_ =%a A%j #O_ 7a Ba C/j D %*a Ea 6a F_ 7a Ga Ha Il� JE` KY _ 7a Ba L/E` KOa Ma Mlv_ Ka N,FOa O_ %a P%_ 9%j #Oa Q_ %a R%_ 9%a S%j #Oa T_ %a U%_ 9%j #O_ a V%E` WO_ a X%E` YOa Z_ W%a [%_ =%j #Oa \_ Y%a ]%_ =%j #Oa ^_ Y%a _%_ =%j #Oa `_ W%a a%_ =%j #Oa b_ Y%a c%_ =%j #Oa d_ Y%a e%_ =%j #Oa f_ Y%a g%_ =%j #O)a h_ 7_ Km+ iE` jO)a k_ 7_ Km+ iE` lO)a m_ 7_ Km+ iE` nO)a o_ 7_ Km+ iE` pO)a q_ 7_ Km+ iE` rO)a s_ 7_ Km+ iE` tO)a u_ 7_ Km+ iE` vO*a w,a x,a Ba y/a Ba z/a Ba {/a Ba |/a B_ /E` }O)_ }_ vl+ ~O_ t_ /a ,FO_ 7a Ba �/E` �O_ 7a Ba �/E` �O_ 7a Ba �/E` �O)_ �_ nl+ �O)_ �_ pl+ �O)_ 7a �_ �%a �%�%a �%_ %_ la ��%_ %a �a ��+ �E` �O)_ 7a �_ la �a �a ��+ �E` �O)_ 7a �_ �%a �%_ ra �a �a ��+ �E` �Oa �_ =%a �%_ =%a �%_ ;%a �%j #Oa 0_ /a 1,FOa �a �lv_ �a N,FOa �a �lv_ �a N,FOa �a �lv_ �a N,FOa �a �lv_ �a N,FOa �a �lv_ �a N,FOa �a �lv_ �a N,FOa ��a ��a �a �lv�l� O*a *k/j �Oa �_  %j #Oa �_ %a �%_ %a �%_ %j #Uu ���  1 . 6v ���  p r ew = 7/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions   x P J/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNPRO_prefPane   y ��� 6 A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m gz ��� . A l m o s t V P N P R O _ 1 . 6 p r e . d m g{ ��� " A l m o s t V P N _ 1 . 6 _ p r e| �� ��+�*�)
�+ 
brow�* 2
�) kfrmID  } �� ��(� ��'�&�%
�' 
brow�& 2
�% kfrmID  
�( 
icop~ �� ��$�
�$ 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e ��� 4 / V o l u m e s / A l m o s t V P N _ 1 . 6 _ p r e� ��� J / V o l u m e s / A l m o s t V P N _ 1 . 6 _ p r e / . r e s o u r c e s� ��� H / V o l u m e s / A l m o s t V P N _ 1 . 6 _ p r e / r e s o u r c e s� �� ��#�� ��"�
�" 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
�# 
cfol� ���  r e s o u r c e s� a [/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNPRO_prefPane/Resources/Images   � b \/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNPRO_prefPane/Distro/Collateral   �zalis    v   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO.icns                                                 ��,!d        ����                 	resources     �,Y�      �,Y�         -AlmostVPN_1.6_pre:resources:AlmostVPNPRO.icns   $  A l m o s t V P N P R O . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  /resources/AlmostVPNPRO.icns  /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  ��alis    �   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO_Link.icns                                            ��,!d        ����                 	resources     �,Y�      �,Y�         2AlmostVPN_1.6_pre:resources:AlmostVPNPRO_Link.icns  .  A l m o s t V P N P R O _ L i n k . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  !/resources/AlmostVPNPRO_Link.icns   /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  ��alis    �   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO_Uninstall.icns                                       ��,!d        ����                 	resources     �,Y�      �,Y�         7AlmostVPN_1.6_pre:resources:AlmostVPNPRO_Uninstall.icns   8  A l m o s t V P N P R O _ U n i n s t a l l . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  &/resources/AlmostVPNPRO_Uninstall.icns  /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  ��alis    �   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO_Cleanup.icns                                         ��,!d        ����                 	resources     �,Y�      �,Y�         5AlmostVPN_1.6_pre:resources:AlmostVPNPRO_Cleanup.icns   4  A l m o s t V P N P R O _ C l e a n u p . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  $/resources/AlmostVPNPRO_Cleanup.icns  /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  �valis    r   AlmostVPN_1.6_pre          �,!_H+    LBLogo_Link.icns                                                  ��,!d        ����                 	resources     �,Y�      �,Y�         ,AlmostVPN_1.6_pre:resources:LBLogo_Link.icns  "  L B L o g o _ L i n k . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  /resources/LBLogo_Link.icns   /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  ��alis    ~   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO_bg.png                                               ��,!dPNGf8BIM����                 	resources     �,Y�      �,Y�         /AlmostVPN_1.6_pre:resources:AlmostVPNPRO_bg.png   (  A l m o s t V P N P R O _ b g . p n g  $  A l m o s t V P N _ 1 . 6 _ p r e  /resources/AlmostVPNPRO_bg.png  /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  ��alis    �   AlmostVPN_1.6_pre          �,!_H+    AlmostVPNPRO_diskimage.icns                                       ��,!d        ����                 	resources     �,Y�      �,Y�         7AlmostVPN_1.6_pre:resources:AlmostVPNPRO_diskimage.icns   8  A l m o s t V P N P R O _ d i s k i m a g e . i c n s  $  A l m o s t V P N _ 1 . 6 _ p r e  &/resources/AlmostVPNPRO_diskimage.icns  /Volumes/AlmostVPN_1.6_pre �    �   BigDisk                    �ڙ�H+  2�AlmostVPNPRO_1.6pre-tmp.dmg                                    �i>�,!^devrddsk����  	                Versions    ���4      �,Y�    2�[W ��� <�l -�� /ɗ  ZBigDisk:Users:atchijov:Work:LeapingBytes:AlmostVPNPRO:Versions:AlmostVPNPRO_1.6pre-tmp.dmg  8  A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g    B i g D i s k  RUsers/atchijov/Work/LeapingBytes/AlmostVPNPRO/Versions/AlmostVPNPRO_1.6pre-tmp.dmg  /    ��  ��  � �� ��!�� �� �� ���� ���� ���� ���� ���� ��
� 
sdsk
� 
cfol� ��� 
 U s e r s
� 
cfol� ���  a t c h i j o v
� 
cfol� ���  W o r k
� 
cfol� ���  L e a p i n g B y t e s
� 
cfol� ���  A l m o s t V P N P R O
�  
cfol� ���  V e r s i o n s
�! 
docf� ��� 6 A l m o s t V P N P R O _ 1 . 6 p r e - t m p . d m g� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
docf� ��� * A l m o s t V P N P R O . p r e f P a n e� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
appf� ��� 8 A l m o s t V P N P R O . U n i n s t a l l e r . a p p� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
appf� ��� 0 A l m o s t V P N P R O . c l e a n u p . a p p� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
inlf� ��� R R e l e a s e   N o t e s  A l m o s t V P N P R O   1 . 6   p r e . w e b l o c� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
inlf� ��� J A l m o s t V P N P R O   O f f i c i a l   W e b   S i t e . w e b l o c� �� ���� ���
� 
cdis� ��� " A l m o s t V P N _ 1 . 6 _ p r e
� 
inlf� ��� L D e v e l o p e d   b y  L e a p i n g   B y t e s ,   L L C . w e b l o c�J  �I  �H  �G  �F  �E  �D  �C  �B  �A  �@  �?  �>  �=  �<  �;  �:  �9  �8  �7  �6  �5  �4  �3  �2  ascr  ��ޭ