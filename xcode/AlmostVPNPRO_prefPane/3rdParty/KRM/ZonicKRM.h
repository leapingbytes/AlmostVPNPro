/*!    @header        ZonicKRM    @discussion       Kagi Registration Module by Zonic.              The ZonicKRM library provides the ability for applications to submit       payments to Kagi in real-time, and to obtain an immediate response       that can include a registration code for unlocking the application.              The user interface can be invoked as a modal dialog or a modeless       window. This window obtains the relevant information from the user       before submitting it to the Kagi Registration Server and returning       the result to the application.              The ZonicKRM is is distributed as a single static library, requires	   no additional resources or frameworks, and can be used from Mach-O	   or CFM applications packaged in either bundled or single-file form.    @copyright        Copyright 2004-2006 Zonic*//*    COPYRIGHT:        Copyright � 2004-2006, Zonic Ltd        <http://www.zonic.co.uk/>        If you have received this software as part of a source code        distribution from Zonic Ltd, subject to the limits of a        supporting contractual agreement, permission to use, copy,        modify, distribute, and sell this software for any purpose        is hereby granted.                Zonic retains full rights to this software.    ___________________________________________________________________________*/#ifndef ZONICKRM_HDR#define ZONICKRM_HDR//=============================================================================//      Include files//-----------------------------------------------------------------------------#include <TargetConditionals.h>#if TARGET_RT_MAC_CFM    #include <Carbon.h>#else    #include <Carbon/Carbon.h>	#ifdef __OBJC__		#include <Cocoa/Cocoa.h>	#endif#endif#ifdef __cplusplusextern "C" {#endif#pragma pack(1)//=============================================================================//      Constants//-----------------------------------------------------------------------------/*!    @enum        ZKRMLanguage    @discussion        Languages supported by the Zonic KRM.    @constant kZKRMLanguageSystem        The user interface will attempt to match the user's preferred language        for the system. If this language is not supported by the Zonic KRM,        kZKRMLanguageEnglishIntl will be used.    @constant kZKRMLanguageEnglishUS        The user interface will be displayed in US English.    @constant kZKRMLanguageEnglishIntl        The user interface will be displayed in International English.    @constant kZKRMLanguageJapanese        The user interface will be displayed in Japanese.    @constant kZKRMLanguageGerman        The user interface will be displayed in German.    @constant kZKRMLanguageFrench        The user interface will be displayed in French.    @constant kZKRMLanguageItalian        The user interface will be displayed in Italian.*/typedef enum {    kZKRMLanguageSystem             = 0,    kZKRMLanguageEnglishUS          = 10,    kZKRMLanguageEnglishIntl        = 20,    kZKRMLanguageJapanese           = 30,    kZKRMLanguageGerman             = 40,    kZKRMLanguageFrench             = 50,    kZKRMLanguageItalian            = 60,    kZKRMLanguageSize32             = 0xFFFFFFFF} ZKRMLanguage;/*!    @enum        ZKRMOrderType    @discussion        Type values for the result of an order.    @constant kZKRMTypeTest        The order was a test order.    @constant kZKRMTypeReal        The order was a real order.*/typedef enum {    kZKRMTypeTest                   = 0,    kZKRMTypeReal                   = 1,    kZKRMTypeSize32                 = 0xFFFFFFFF} ZKRMOrderType;/*!    @enum        ZKRMOrderStatus    @discussion        Status values for the result of an order.    @constant kZKRMOrderInvalid        The transaction could not be compeleted because there was a protocol        disagreement between Zonic KRM and the Kagi server.    @constant kZKRMOrderDuplicate        The transaction was not processed because it was identified as a        duplicate of a previous order. No charge was placed against the        credit card for this transaction.    @constant kZKRMOrderFailureNoCharge        There was a failure while processing the transaction. This status        includes the possibility of the sale not being authorized. No charge        was placed against the credit card for this transaction.    @constant kZKRMOrderFailureWithCharge        There was a failure while processing the transaction. The failure was        of a nature which did not prevent sale authorization, but which possibly        prevents the generation of user name/registration code data.                A charge will be placed against the credit card for this transaction,        and any user name/registration code data will be e-mailed to the address        supplied by the user.    @constant kZKRMOrderFailureChargeStatusUnknown        There was a failure while processing the transaction. The failure was of        a nature which does not make it possible to immediately determine whether        or not a charge was placed against the credit card for this transaction.    @constant kZKRMOrderHumanApprovalRequired        The order has neither been approved or denied. Before the order can be        approved or denied, it is necessary for a human to review the order.    @constant kZKRMOrderSuccess        The transaction was successful. A charge will be placed against the credit        card for this transaction, and any relevant user name/registration code        data has been generated and returned.*/typedef enum {    kZKRMOrderInvalid                       = 0,    kZKRMOrderDuplicate                     = 1000,    kZKRMOrderFailureNoCharge               = 2000,    kZKRMOrderFailureWithCharge             = 3000,    kZKRMOrderFailureChargeStatusUnknown    = 4000,    kZKRMOrderHumanApprovalRequired         = 4500,    kZKRMOrderSuccess                       = 5000,    kZKRMOrderSize32                        = 0xFFFFFFFF} ZKRMOrderStatus;/*!    @enum        ZKRMModuleStatus    @discussion        Status values for the result of a call to the Zonic KRM.    @constant kZKRMModuleNoErr        No error.    @constant kZKRMModuleUnavailable        The KRM is not available on this platform.    @constant kZKRMModuleInProgress        A transaction is already underway.    @constant kZKRMModuleBadResponse        The data returned by the Kagi server was malformed.    @constant kZKRMModuleUserCancelled        The user has cancelled the operation.    @constant kZKRMModuleUsedWebStore        The user has used the Kagi web store rather than the KRM.    @constant kZKRMModuleConnectionLost        The connection to the server was lost.    @constant kZKRMModuleOutOfMemory        The module was unable to allocate memory.*/typedef enum {    kZKRMModuleNoErr                = 0,    kZKRMModuleUnavailable          = 10,    kZKRMModuleInProgress           = 20,    kZKRMModuleBadResponse          = 30,    kZKRMModuleUserCancelled        = 40,    kZKRMModuleUsedWebStore         = 50,    kZKRMModuleConnectionLost       = 60,    kZKRMModuleOutOfMemory          = 70,    kZKRMModuleSize32               = 0xFFFFFFFF} ZKRMModuleStatus;/*!    @enum        ZKRMOptions    @discussion        Options for controlling the Zonic KRM.    @constant kZKRMOptionDefault        The KRM should use the default behaviour for all options.    @constant kZKRMOptionOfferWebOrder        If set, the KRM will offer the user a chance to purchase through the Kagi Web Store        before presenting the normal KRM user interface.        This option can be used for products that can be purchased in a manner not supported by        the KRM (e.g., cash or bulk orders), and where the application has not invoked the KRM        through a "Order a single copy now with a credit card" user interface element.                If the KRM has been invoked through a generic "Register Now" user interface element,        this option ensures that users can still reach the Web Store if required.    @constant kZKRMOptionEncryptedProductXML        If set, the productInitXML field of the ZKRMParameters structure is decrypted before        use.                This option can be set if the productInitXML field has been encrypted with a call to        EncryptKRMString.    @constant kZKRMOptionModalPrintDialogs        If set, the page setup and print sheets will be displayed as modal dialogs rather than		sheets.				This option can be used to work around a bug in Cocoa, where the print sheet may be		made visible even after the ZonicKRM has destroyed it and returned to the application.		Cocoa applications which do not set this option may see the print sheet momentarily		between the ZonicKRM returning and the resumption of the application event loop. Even		with this option set they may experience spurious console output, caused by Cocoa		referencing the now-destroyed printer sheets.				This problem may be printer-driver specific, and appears to be more common on Mac OS		X 10.4. It has been logged with Apple, and a copy of the Radar reports are available		on request.*/typedef enum {    kZKRMOptionDefault              = 0,    kZKRMOptionOfferWebOrder        = (1 << 0),    kZKRMOptionEncryptedProductXML  = (1 << 1),    kZKRMOptionModalPrintDialogs    = (1 << 2),    kZKRMOptionSize32               = 0xFFFFFFFF} ZKRMOptions;/*!    @enum        ZKRMEvent    @discussion        Zonic KRM Carbon Event.    @constant kEventClassZKRM        The event class for Carbon Events generated by the Zonic KRM.    @constant kEventZKRMCompleted        The Zonic KRM has completed a transaction.    @constant kEventParamZKRMResult        A typeVoidPtr parameter which can be cast to a pointer to a ZKRMResult.*/typedef enum {    kEventClassZKRM                 = FOUR_CHAR_CODE('ZKrm'),    kEventZKRMCompleted             = 1,    kEventParamZKRMResult           = FOUR_CHAR_CODE('ZKre'),    kZKRMEventSize32                = 0xFFFFFFFF} ZKRMEvent;//=============================================================================//      Types//-----------------------------------------------------------------------------/*!    @struct        ZKRMKeyValuePair    @discussion        Holds a key-value pair.    @field key        The key for the key-value pair.            @field value        The value for the key-value pair.*/typedef struct ZKRMKeyValuePair {    CFStringRef         key;    CFStringRef         value;} ZKRMKeyValuePair;/*!    @struct        ZKRMParameters    @discussion        Configuration parameters passed to the Zonic KRM.    @field moduleVersion        The version number of this structure. Currently defined values are 0 or 1, however        the recommended behaviour for applications is to use InitKRMParameters to initialise        this structure.                InitKRMParameters will provide safe default values for every field, allowing your        initialisation code to safely ignore new fields.    @field moduleLanguage        The language to be used by the module user interface.    @field moduleUserName        Optional user name to use as the default for the purchase window. If this field is        NULL, the user name will be obtained from the system.    @field moduleOptions        Options to control the module. Should be set to kZKRMOptionDefault if the default        behaviour is required.    @field moduleUserEmail        Optional user email address to use as the default for the purchase window. If this        field is NULL, the user email address will be obtained from the system.    @field productInitXML        Product initialization XML. This string is passed to the Kagi Registration Server,        which uses it to construct an appropriate order description for the KRM.    @field productStoreURL        Product store URL. If moduleOptions contains kZKRMOptionOfferWebOrder, the user        will be offered the chance to bypass the KRM and visit this URL in their browser.    @field productTFYP        Optional product-specific "TFYP" data. This string is passed unchanged through        the Kagi Registration Server, and included in both the final TFYP email and any        printed receipt.    @field productPO        Optional product-specific purchase order number. This string is passed unchanged        through the Kagi Registration Server, and included in both the final TFYP email        and any printed receipt.    @field acgKeyValueCount        The number of ZKRMKeyValuePair structures pointed to by acgKeyValueData.    @field acgKeyValueData        Optional array of ZKRMKeyValuePairs. These key-value pairs are passed unchanged        to the Kagi Automatic Code Generation system.    @field productAffiliate        Optional affiliate identifier. This string is passed to the Kagi Registration Server,        which uses it to identify the affilate that should be credited for this transaction.                This field is available in version 1 onwards.*/typedef struct ZKRMParameters {    // Common    UInt32              moduleVersion;    // Version 0    ZKRMLanguage        moduleLanguage;    ZKRMOptions         moduleOptions;    CFStringRef         moduleUserName;    CFStringRef         moduleUserEmail;    CFStringRef         productInitXML;    CFStringRef         productStoreURL;    CFStringRef         productTFYP;    CFStringRef         productPO;    UInt32              acgKeyValueCount;    ZKRMKeyValuePair    *acgKeyValueData;        // Version 1    CFStringRef         productAffiliate;} ZKRMParameters;/*!    @struct        ZKRMResult    @discussion        Results returned by the Zonic KRM.    @field moduleVersion        The version number of this structure (currently 0 or 1).    @field moduleStatus        The module result returned by the Zonic KRM. If this field is anything        other than kZKRMModuleNoErr, the remaining fields are undefined.    @field orderStatus        The order result returned by the Kagi server.    @field orderType        The type of order processed by the Kagi server.    @field acgUserName        The user name returned by the Kagi Automatic Code Generation system.        If this product does not use an ACG, NULL is returned.        @field acgRegCode        The registration code returned by the Kagi Automatic Code Generation system.        If this product does not use an ACG, NULL is returned.    @field kagiTransactionID        The Kagi Transaction ID for the order.    @field kagiReplyXML        The reply XML returned by the Kagi server.    @field acgUserEmail        The user email returned by the Kagi Automatic Code Generation system.        If this product does not use an ACG, NULL is returned.                This field is available in version 1 onwards.*/typedef struct ZKRMResult {    // Common    UInt32                  moduleVersion;    // Version 0    ZKRMModuleStatus        moduleStatus;    ZKRMOrderStatus         orderStatus;    ZKRMOrderType           orderType;    CFStringRef             acgUserName;    CFStringRef             acgRegCode;    CFStringRef             kagiTransactionID;    CFStringRef             kagiReplyXML;    // Version 1    CFStringRef             acgUserEmail;} ZKRMResult;//=============================================================================//      Functions//-----------------------------------------------------------------------------/*!    @function        IsKRMAvailable    @discussion        Checks to see if the KRM can be used on this system.    @result        Returns kZKRMModuleNoErr or kZKRMModuleUnavailable to indicate if the        module is available or not. If kZKRMModuleUnavailable is returned, no        further calls should be made to the KRM.*/extern ZKRMModuleStatusIsKRMAvailable(void);/*!    @function        InitKRMParameters    @discussion        Initialise a ZKRMParameters structure.    @result        Should be used to prepare a ZKRMParameters structure before use, to        ensure that any new fields are correctly initialised.*/extern voidInitKRMParameters(ZKRMParameters *theParameters);/*!    @function        GetKRMVersion    @discussion        Retrieves the current Zonic KRM version. Version numbers are BCD encoded.    @result        Returns the current Zonic KRM version.*/extern UInt32GetKRMVersion(void);/*!    @function        BeginModalKRM    @discussion        Begin a modal KRM session.                Runs the KRM session through a modal dialog. The application will regain        control when the transaction is complete.    @param theParameters        The configuration parameters for the KRM and the Kagi Registration Server.    @param theResult        Receives the results of the transaction. If a non-NULL value is returned,        the results must be disposed of with a subsequent call to DisposeKRMResult.    @result        Success or failure of the operation. Note that this refers to the module        status, and the status of the order must be retrieved from the ZKRMResult.*/extern ZKRMModuleStatusBeginModalKRM(const ZKRMParameters *theParameters, ZKRMResult **theResult);/*!    @function        BeginModelessKRM    @discussion        Begin a modeless KRM session.                Runs the KRM session through a modeless dialog. The application will regain        control immediately, with a preliminary status result.                If the preliminary status result is kZKRMModuleNoErr, a Carbon Event will be        dispatched to the application when the transaction is complete.                This event will be of class kEventClassZKRM and kind kEventZKRMCompleted. It        will contain a kEventParamZKRMResult parameter, which provides a pointer to        the final ZKRMResult.                As with the modal interface, this ZKRMResult must be disposed of by the        application with a subsequent call to DisposeKRMResult.    @param theParameters        The configuration parameters for the KRM and the Kagi Registration Server.    @result        Success or failure of the operation. Note that this refers to the module        status, and the status of the order must be retrieved from the ZKRMResult.                If kZKRMModuleNoErr is returned, a kEventZKRMCompleted Carbon Event will be        dispatched to the application. If any other value is returned, a Carbon Event        will not be dispatched.*/extern ZKRMModuleStatusBeginModelessKRM(const ZKRMParameters *theParameters);/*!    @function        DisposeKRMResult    @discussion        Dispose of a previously allocated ZKRMResult.    @param theResult        A pointer to a ZKRMResult pointer that was previously returned by the KRM.*/extern voidDisposeKRMResult(ZKRMResult **theResult);/*!    @function        EncryptKRMString    @discussion        Encrypt a string for the KRM.    @param cfString        A string to be encrypted. The string is updated to receive the encrypted form.                String data is encrypted with the Blowfish algorithm, and the encrypted form        is returned as a series of alphanumeric hex characters.*/extern ZKRMModuleStatusEncryptKRMString(CFMutableStringRef cfString);//=============================================================================//      Objective-C interface//-----------------------------------------------------------------------------#ifdef __OBJC__/*!    @class        ZonicKRMController    @discussion        The ZonicKRM controller.*/@interface ZonicKRMController : NSObject {}/*!    @method        sharedController    @discussion        Retrieves the ZonicKRM controller, which can be used to invoke the ZonicKRM.    @result        The ZonicKRM controller object.*/+ (ZonicKRMController *)sharedController;/*!    @method        runModalKRMWithParameters:toResult:    @discussion        Begin a modal KRM session.                Runs the KRM session through a modal dialog. The application will regain        control when the transaction is complete.    @param parameters        The configuration parameters for the KRM and the Kagi Registration Server.    @param result        Receives the results of the transaction. If a non-NULL value is returned,        the results must be disposed of with a subsequent call to DisposeKRMResult.    @result        Success or failure of the operation. Note that this refers to the module        status, and the status of the order must be retrieved from the ZKRMResult.*/- (ZKRMModuleStatus)runModalKRMWithParameters:(const ZKRMParameters *)parameters toResult:(ZKRMResult **)result;/*!    @method        runModelessKRMWithParameters:toDelegate:withSelector:    @discussion        Begin a modeless KRM session.                Runs the KRM session through a modeless dialog. The application will		regain control immediately, with a preliminary status result.                If the preliminary status result is kZKRMModuleNoErr, the selector		method of the delegate will be called. The selector should have the		following signature:				- (void)krmDidEndWithResult:(const ZKRMResult *)withResult;				Applications do not need to dispose of the result parameter passed to		the selector.    @param parameters        The configuration parameters for the KRM and the Kagi Registration Server.    @param delegate        The delegate object for this session.     @param selector        The selector to call when the session is completed.     @result        Success or failure of the operation. Note that this refers to the module        status, and the status of the order must be retrieved from the ZKRMResult.        If kZKRMModuleNoErr is returned, the withSelector method of the delegate		will be called. If any other value is returned, withSelector will not be		called.*/- (ZKRMModuleStatus)runModelessKRMWithParameters:(const ZKRMParameters *)parameters toDelegate:(id)delegate withSelector:(SEL)selector;@end   // ZonicKRMController#endif // __OBJC__#pragma pack()#ifdef __cplusplus}#endif#endif // ZONICKRM_HDR