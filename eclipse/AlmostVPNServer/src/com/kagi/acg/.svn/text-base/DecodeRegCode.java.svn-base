/**
 * DecodeRegCode.java
 * Created on Mar 18, 2005
 * Copyright(c) 2005  Kagi. All rights reserved.
 */
package com.kagi.acg;

/**
 * @author rupali
 * @version $Id: DecodeRegCode.java,v 1.2 2005/05/25 16:46:26 rupali Exp $
 * This class
 */

/*
 * DecodeRegCode.java
 * Created on February 21, 2003, 10:05 AM
 * Copyright Notice: DecodeRegCode is Copyright(c) 2004  Kagi.  All Rights Reserved.
 * Permission is granted to use this code module for development of decoding algorithm
 * for the generic acg.No warranty is made as to the suitability to your application
 *
 *     BECAUSE THE REFERENCE IS LICENSED FREE OF CHARGE, THERE IS NO
 *     WARRANTY FOR THE REFERENCE, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
 *     EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR
 *     OTHER PARTIES PROVIDE THE REFERENCE "AS IS" WITHOUT WARRANTY OF ANY
 *     KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
 *     IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *     PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
 *     REFERENCE IS WITH YOU.  SHOULD THE REFERENCE PROVE DEFECTIVE, YOU ASSUME
 *     THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
 *     If you make any corrections to the basic reference or have suggestions
 *     please send them to acg@kagi.com so other may benefit.
 *
 */

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.StringTokenizer;

/**
 * This class demonstrates how to obtain the seed parameters from the registration
 * code. The reverse process includes 6 steps. 1. Unformat the registration.Seperate
 * the check digit and the registration code 2. Verify that the registration code
 * gives the same check digit as the one appended to it. 3. Convert the number to
 * base ten. 4. Undo the mathematical operations on each set of digits. 5. Unscramble
 * the characters. 6. Seperate the seed parameters.
 */
public class DecodeRegCode {
  private String baseMap;// base character set

  private int base; //the base to which the number was converted to.

  /* baseTable stores 0=A, 1=B, while reverseBaseTable stores A=0,B=1 */
  private Hashtable baseTable, reverseBaseTable;

  /* Number of ascii digits used for character to decimal number conversion */
  private int asciiDigit;

  /* arithmetic operations string : 7A,R 7A -> 7 =operand A=operator */
  private String arithmeticOps;

  /* The scramble order U- user seed D- date c- constant s- sequence */
  private String scrambleOrder;

  /* Max Length of user seed */
  private int seedMax = 30;

  /* Max length of constant */
  private int constMax = 3;

  /* Length of sequence */
  private int seq = 3;

  /* The checkdigit for the regcode */
  private String checkDigit;

  /* The unformatted regcode */
  private String RegCode;

  /* Set to true if using debug mode */
  private boolean debug;

  /*
   * Set to true if regcode checkdigit is the same as that calculated using the
   * regcode
   */
  private boolean validCode = false;

  /* Stores the the seed in decimal format as a string */
  private String BaseTenNumb;

  /* Stores the seed in decimal format */
  int[] seedInDecimal;

  /* Stores the format information for the regcode */
  private String regFormat;

  /* is set to true is MathsOP were specified for alll digits */
  private boolean mathOpsOK;

  /* Length of the seed used to generate the registration code */
  private int seedSize;

  /* Stores the seed after it is decoded */
  private String userSeed, constantValue, sequenceNumber, regDate;

	private String seedCombo;

  private String email, name, hotSyncId;

  private int nameLength, emailLength, hotSyncLength, seedLength;

  /**
   * Create an instance of DecodeRegCode
   *
   * @param mode
   *          :Set to true if using the debugging mode
   */
  public DecodeRegCode(boolean mode, String configuration) {

    debug = mode;
    init(configuration);
  }

  private void init(String configuration) {

    Hashtable configParams = populateConfigParamTable(configuration);
    initialize(configParams);
  }


  /**
   * @param configData
   *          :An hashtable containing the configuration parameters as key value
   *          pairs. This method intializes the various data members of the the class
   *          using the hashtable containing configuration parameters. It then uses
   *          the base character set to create two hashtables. baseTable contains the
   *          digits as keys and base characters as values. reversebaseTable contains
   *          the base characters as keys and digits as values.
   */
  public void initialize(Hashtable configData) {
    if (debug)
      System.out.println(configData);

    //Intialize the data members
    seedMax = Integer.parseInt((String) configData.get("SDLGTH"));
    seq = Integer.parseInt((String) configData.get("SEQL"));
    constMax = Integer.parseInt((String) configData.get("CONSTLGTH"));
    arithmeticOps = (String) configData.get("MATH");
    asciiDigit = Integer.parseInt((String) configData.get("ASCDIG"));
    scrambleOrder = (String) configData.get("SCRMBL");
    base = Integer.parseInt((String) configData.get("BASE"));
    baseMap = (String) configData.get("BASEMAP");
    regFormat = (String) configData.get("REGFRMT");
		seedCombo = (String) configData.get("COMBO");
    nameLength = Integer.parseInt((String) configData.get("E"));
    emailLength =  Integer.parseInt((String) configData.get("N"));
    hotSyncLength = Integer.parseInt((String) configData.get("H"));

    if (debug) {
      System.out.println("The seed length is : " + seedMax);
      System.out.println("The sequence length is " + seq);
      System.out.println("The constant length is: " + constMax);
    }

    //Instantiate the hashtables
    baseTable = new Hashtable();
    reverseBaseTable = new Hashtable();

    for (int i = 0; i < base; ++i) {
      String key = Integer.toString(i); //digit
      String value = String.valueOf(baseMap.charAt(i)); //base charcter set
      baseTable.put(key, value); //digit - base chars mapping
      reverseBaseTable.put(value, key); //base char- digit mapping
    }
    if (debug) {
      System.out.println("Base Table: " + baseTable + "\n" + "Reverse Table: "
          + reverseBaseTable);
    }
  }

  /**
   * @param regCode
   *          The formatted registration code This method unformats the registration
   *          code using format pattern specified. Unformated reg code is without the
   *          static text,seperator character('-') and check digit.
   */

  public void unformatRegCode(String regCode) {
    if (debug)
      System.out.println("The formatted regcode is:" + regCode);

    boolean checkDigitFound = false;
    //holds the unformatted reg code
    StringBuffer code = new StringBuffer();
    //length of the formatted reg code
    int regLength = regCode.length();

    char formatChar;

    for (int i = 0; i < regLength; ++i) {
      try {
        formatChar = regFormat.charAt(i);
        // if the format char is '#' then its is the regcode
        if (formatChar == '#')
          code.append(regCode.charAt(i));
        // if the formatChar is "^" then it is check digit
        else if (formatChar == '^') {
          checkDigitFound = true;
          checkDigit = String.valueOf(regCode.charAt(i));
        }
        else if (formatChar == '[') {
          String tailFormat = regFormat.substring(i, regFormat.length());
          String tailCode = regCode.substring(i, regCode.length());
          code.append(getTailEndOfRegCode(tailFormat, tailCode));
          break;
        }
        //if the character is other than "^" or "#" then it is
        //static text and not part of regcode.
        else
          continue;
      }
      catch (StringIndexOutOfBoundsException indexError) {
        code.append(regCode.substring(i, regLength));
        break;
      }
    }

    RegCode = code.toString();

    if (debug)
      System.out.println("Registraion code is" + RegCode);

    //seperate the registration code and check digit.
    //if the supplier did not specify a position for the checkdigit
    //then it was appended at the end of the reg code.
    //The last character is the check digit.

    if (checkDigitFound == false) {
      checkDigit = RegCode.charAt(RegCode.length() - 1) + "";
      RegCode = RegCode.substring(0, RegCode.length() - 1);
    }

    //appends the results of this step

    if (debug) {
      System.out.println("The regcode is : " + RegCode
          + " and the check digit is " + checkDigit);
    }
  }

  /**
   * This method
   *
   * @param tailFormat
   * @param tailCode
   * @return
   */
  public String getTailEndOfRegCode(String tailFormat, String tailCode) {
    tailFormat = tailFormat.replaceAll("\\[", "");
    tailFormat = tailFormat.replaceAll("\\]", "");
    System.out.println(tailFormat + " " + tailCode);
    StringBuffer temp = new StringBuffer();
    int i;
    for (i = 0; i < tailFormat.length(); ++i) {
      char formatChar = tailFormat.charAt(i);
      if (formatChar == '#') {
        try {
          temp.append(String.valueOf(tailCode.charAt(i)));
        }
        catch (StringIndexOutOfBoundsException indexError) {
          break;
        }
      }
    }
    if (i < tailCode.length()) {
      temp.append(tailCode.substring(i, tailCode.length()));
    }
    System.out.println(temp.toString());
    return temp.toString();
  }

  /**
   * This method verifies that the registration code is valid. Calculate the check
   * digit for the registration code. It should be equal to the check digit you got
   * with the registration code. if both the check digits are equal then the
   * registration code is valid. Starting at the last digit assign a weight to it and
   * multiply it with the digit value. Add the values for all digits and do sum%base.
   * Then convert the digit to its base character mapping. This is the check digit.
   */

  public void verifyCheckDigit(String code, String checkDigit) {
    int sum = 0;
    int weight = 2;
    try {
      for (int i = code.length() - 1; i >= 0; --i) {
        //get the character
        String digit = String.valueOf(code.charAt(i));

        //get the digit value of the character.
        String value = (String) reverseBaseTable.get(digit);
        if (debug)
          System.out.println("Digit: " + digit + "Value : " + value);
        int temp = Integer.parseInt(value);
        //multiply the digit value by weight.
        temp = weight * temp;
        sum = sum + temp;
        if (weight == 2)
          weight = 1;
        else
          weight = 2;
      }
    }
    catch (NumberFormatException invalidNumber) {
      System.out.println("Invalid reg code for the selected config Data");
    }
    //get the checkdigit
    int mod = sum % base;
    String checkD = (String) baseTable.get(mod + "");
    if (debug)
      System.out.println("The calculated check Digit is :" + checkD
          + " and that from regcode is:" + checkDigit);

    //if the calculated check digit and the check digit received with the reg
    //code is the same then we have a valid reg code
    if (checkD.equals(checkDigit)) {
      validCode = true;
      if (debug)
        System.out.println("The check digit is verified.");
    }
    //the check digits did not match so output an error message
    else {
      validCode = false;
    }
  }

  /**
   * This method return true if reg code is valid
   */
  public boolean isRegCodeValid() {
    return validCode;
  }

  /**
   * This method converts the registration code to base ten number It makes uses of
   * the BigIntArithmetic class to perform base conversion on the large number.
   */
  public void convertToBaseTen() {

    int codeLength = RegCode.length();
    String weight;
    String result;
    String sum = "0";
    String oldBase = String.valueOf(base);
    int index = codeLength - 1;
    for (int power = 0; power < codeLength; ++power) {
      //find the weight to multiply each digit with.
      weight = BigIntArithmetic.pow(oldBase, power);
      //get the digit
      String digit = (String) reverseBaseTable.get(String.valueOf(RegCode
          .charAt(index)));
      // multiply weight by the digit.
      result = BigIntArithmetic.multiply(weight, digit);
      // add the digit value
      sum = BigIntArithmetic.add(sum, result);
      --index;
    }
    if (debug)
      System.out.println("The number after converting to base ten is" + sum);
    BaseTenNumb = sum;
  }

  /**
   * This method perform reverse arithmetic operations to those performed during the
   * creation of registration code.So if the arithmetic operation string specifies 7A
   * which add & .This method will do subtract 7.
   */
  public void unDoArithmeticOps() {
    int[] decimalNumb = null;
    //if you chose 2 for ascii digit then the number length should
    //be a multiple of two so append a "0" at the start if it is not.
    if (asciiDigit == 2) {
      if (BaseTenNumb.length() % 2 != 0)
        BaseTenNumb = "0" + BaseTenNumb;
      decimalNumb = new int[BaseTenNumb.length() / 2];
    }
    //if you chose 3 for ascii digit then the number length should
    //be a multiple of three so append a "0" at the start if it is not.
    else if (asciiDigit == 3) {
      if (BaseTenNumb.length() % 3 != 0)
        BaseTenNumb = "0" + BaseTenNumb;
      decimalNumb = new int[BaseTenNumb.length() / 3];
    }

    // the converts the number in base ten to an array of decimal digits.
    int sIndex = 0;
    int eIndex = asciiDigit;
    seedSize = 0;
    for (int i = 0; i < decimalNumb.length; ++i) {
      decimalNumb[i] = Integer.parseInt(BaseTenNumb.substring(sIndex, eIndex));
      ++seedSize;
      sIndex = eIndex;
      eIndex = eIndex + asciiDigit;

      if (debug) {
        if (i == 0)
          System.out.print("The decimal number is: ");
        System.out.print(decimalNumb[i] + " ");
      }
    }
    seedInDecimal = decimalNumb;

    if (debug)
      System.out.println("The arithmetic ops are." + arithmeticOps);
    String temp = replaceAll(arithmeticOps, ",,", "");

    //parse the string containing arithmetic ops.
    //the delimiter charcter is ":
    StringTokenizer tokenizer = new StringTokenizer(arithmeticOps, ",");
    int index = 0;
    int count = 0;
    while (tokenizer.hasMoreTokens()) {
      String token = tokenizer.nextToken();
      //token is of type 56A
      ++count;
      int operand = 0;
      char operation = ' ';
      try {
        //everything but the last character is the token '56A' is operand.
        operand = Integer.parseInt(token.substring(0, token.length() - 1));
      }
      catch (Exception error) {
        //Ignore error.There is no possibility of invalid operand as they were
        // verified when the config data
        //was created.
      }
      //last character in the token of type'56A' specifies the operation
      operation = token.charAt(token.length() - 1);
      if (debug)
        System.out.println("The token is :" + token + "operation is"
            + operation + "operand is" + operand);
      switch (operation) {
        case 'A'://addition
        {
          seedInDecimal[index] = seedInDecimal[index] - operand;
          break;
        }
        case 'S'://subtraction
        {
          seedInDecimal[index] = seedInDecimal[index] + operand;
          break;
        }
        case 'M'://multiplication
        {
          seedInDecimal[index] = seedInDecimal[index] / operand;
          break;
        }
        case 'R'://reverse
        {
          //if digit = 840
          //digit = 840/10 = 84
          if (asciiDigit == 3)
            seedInDecimal[index] = seedInDecimal[index] / 10;
          //rev = 84%10 + 84/10 = 48
          String rev = (seedInDecimal[index] % 10) + ""
              + (seedInDecimal[index] / 10) + "";
          seedInDecimal[index] = Integer.parseInt(rev);
          break;
        }
      }// switch
      if (debug)
        System.out.println(seedInDecimal[index] + " : "
            + (char) seedInDecimal[index]);
      ++index;
    }//while

    for (int i = 0; i < seedInDecimal.length; ++i) {
      if (debug)
        System.out.print(seedInDecimal[i] + " ");
      //append the result of this step(undoing arithmetic op)
    }

    //check if seed size is equal to the number of arithmetic operations specified
    //if they are equal then proceed with the next step of decoding
    //else display an error message
    if (seedSize != count) {
      mathOpsOK = false;
    }
    else
      mathOpsOK = true;
  }

  /**
   * @param arithmeticOps2
   * @param string
   * @param string2
   * @return
   */
  private String replaceAll(String stringWithPattern, String pattern, String replacementPattern) {

    StringBuffer newString = new StringBuffer();
    
    StringTokenizer tokenizer = new StringTokenizer(stringWithPattern, pattern);
    
    while (tokenizer.hasMoreTokens()) {
      
      String token = tokenizer.nextToken();
      newString.append(token);
      newString.append(replacementPattern);
      
    }
    
    return newString.toString();
  }

  /**
   * This method converts the decimal number into ascii characters and unscrambles
   * the text. The scramble sequence is of type U0,U2,U5,C0,U8,U7,D1,D3, Each token
   * consists of the seed symbol and its index in the original seed b before it was
   * scrambled. U -user seed D- Date C- constant S- sequence
   */
  public void unScrambleSeed() {
    char[] useed = new char[seedMax];//stores the user seed
    char[] constant = new char[constMax];//stores the constant
    char[] sequence = new char[seq]; //stores the sequence
    char[] date = new char[4]; //stores the date
    StringBuffer scrambledSeed = new StringBuffer();

    //parse the scramble sequence,the delimiter is ','
    StringTokenizer st = new StringTokenizer(scrambleOrder, ",,");
    int index = 0;
    int count = 0;//count of scramble sequence symbols
    while (st.hasMoreTokens()) {

      try {
        String token = st.nextToken();
        //first character is the seed symbol in the token of type 'C1'
        String type = token.substring(0, 1);

        scrambledSeed.append(String.valueOf((char) seedInDecimal[count]));
        // the rest of the the token is the index of the
        // the character
        String temp = token.substring(1, token.length());
        index = Integer.parseInt(temp);

        //case user seed parameter
        if (type.equals("U")) {
          useed[index] = (char) seedInDecimal[count];
        }
        // case constant
        else if (type.equals("C")) {
          constant[index] = (char) seedInDecimal[count];
        }
        //case sequence
        else if (type.equals("S")) {
          sequence[index] = (char) seedInDecimal[count];
        }
        //case date
        else if (type.equals("D")) {
          date[index] = (char) seedInDecimal[count];
        }
      }
      catch (NullPointerException nullError) {
      }
      ++count;
    }//while

    //check if the scramble count is same as seed size
    //if yes then append the results of this stage.
    // to the decoding message

    if (count == seedSize) {
      userSeed = new String(useed);
      constantValue = new String(constant);
      sequenceNumber = new String(sequence);
      String formatDate = getFormattedDate(new String(date));
      regDate = formatDate;
      if (debug) {
        System.out.println("\nThe scrambled SEED was :"
            + scrambledSeed.toString());
        System.out.println("\nUser seed :" + new String(useed));
        System.out.println("Constant: " + new String(constant));
        System.out.println("Sequence :" + new String(sequence));
        System.out.println("Date :" + formatDate);
      }
    }

  }

  /**
   * This method converts the 4 digit representation of date to the format Mon, day
   * year. So if date has value 0693 where 69 is day in the year and 3 is last digit
   * of year(2003). Then it will be converted into March 10,2003.
   */

  public String getFormattedDate(String date) {
    // Create an instance of the Gregorian calendar
    Calendar cal = new GregorianCalendar();

    // get the present year
    int year = cal.get(Calendar.YEAR);

    // everything but the last digit is day of the year
    // so for 0693, 069 is the day
    String temp = date.substring(0, date.length() - 1);
    int day = Integer.parseInt(temp);

    // now form the year which is "20" + decade + year
    // so for the above example it will be 20+(2013-2000)/10+(the last char of 0693)
    // 20+1+3 = 2013
    temp = "20" + String.valueOf((year - 2000) / 10)
        + String.valueOf(date.charAt(3));
    year = Integer.parseInt(temp);

    if (debug)
      System.out.println("The year is :" + year + " and day of the year is "
          + day);

    cal.set(Calendar.DAY_OF_YEAR, day);
    cal.set(Calendar.YEAR, year);

    // now create a date object using this year and day
    // Date d = new
    // Date(cal.get(Calendar.YEAR)-1900,cal.get(Calendar.MONTH),cal.get(Calendar.DATE
    // ));
    Date d = cal.getTime();

    // format the date object using the date formatter
    DateFormat df = DateFormat.getDateInstance();
    String formatDate = df.format(d);
    if (debug)
      System.out.println("The formatted date is:" + formatDate);
    return formatDate;
  }

  /**
   * @return the String containing the results of each step involved in decoding.
   *         This method decodes the registration code. It calls methods to do the
   *         following Unformat registration code Validate check digit Convert to
   *         base ten Reverse the arithmetic Unscramble seed
   */
  public void decode(String code) {
    //first unformat the reg code
    unformatRegCode(code);
    verifyCheckDigit(RegCode, checkDigit);
    if (isRegCodeValid() == true) {
      convertToBaseTen();
      unDoArithmeticOps();
      if (mathOpsOK == true)
        unScrambleSeed();
    }

  }

  /**
   * @return the User seed part of the seed
   */
  public String getUserSeed() {
    return userSeed;
  }

  /**
   * @return the value of the constant
   */
  public String getConstant() {
    return constantValue;
  }

  /**
   * @return the sequence number
   */
  public String getSequenceNumber() {
    return sequenceNumber;
  }

  /**
   * @return the reg code date
   */
  public String getRegDate() {
    return regDate;
  }


  /**
   *
   * @param configData
   * @param configParamsTable
   */
  public Hashtable populateConfigParamTable(String configData) {

    Hashtable configParamsTable = new Hashtable();

    //intialize a hashtable.
    boolean configDataValid;
    //intialize the string tokenizer using "%" as delimiter
    StringTokenizer tokenizer = new StringTokenizer(configData, "%");
    String key = null;
    String value = null;
    if (debug)
      System.out.println(configData);
    while (tokenizer.hasMoreTokens()) {
      try {
        String token = tokenizer.nextToken();
        //parse the key and value from the token
        //eveerything upto ':' is key and everything beyond
        //';' is value.
        int index = token.indexOf(':');
        key = token.substring(0, index);
        value = token.substring(index + 1, token.length());
        try {
          if (value.equals(null) || value.equals("")) {
            configDataValid = false;
            break;
          }
          else
            configDataValid = true;
        }
        //if key doest not have value then we will get a null pointer exception.
        catch (NullPointerException nullValue) {
          configDataValid = false;
          break;
        }
        if (debug)
          System.out.println("The key is " + key + " The value is " + value);
        // if we reached this point we have a non null key and value
        //store the key and value
        configParamsTable.put(key, value);
      }
      catch (StringIndexOutOfBoundsException error) {
        System.out.println(error);
      }

    }

    return configParamsTable;

  }







  /**
   * @return Returns the email.
   */
  public String getEmail() {

    return email;
  }


  /**
   * @param email The email to set.
   */
  public void setEmail(String email) {

    this.email = email;
  }


  /**
   * @return Returns the hotSyncId.
   */
  public String getHotSyncId() {

    return hotSyncId;
  }


  /**
   * @param hotSyncId The hotSyncId to set.
   */
  public void setHotSyncId(String hotSyncId) {

    this.hotSyncId = hotSyncId;
  }


  /**
   * @return Returns the name.
   */
  public String getName() {

    return name;
  }


  /**
   * @param name The name to set.
   */
  public void setName(String name) {

    this.name = name;
  }


	 /**
   * This method validates the customer data against config parameters
   * and if they could be validated it creates the user seed
   */
  public String createUserSeed() {

    String originalUserSeed = null;
    boolean seedValidated = false;

    //validate the customer seed parameters against the config Data
    if (seedCombo.equals("ee"))  {

      originalUserSeed = email;
    }
    else if ( seedCombo.equals("en") || seedCombo.equals("ne")) {

      if (seedCombo.equals("en")) {
        originalUserSeed = email + " " + name;
      }
      else {
        originalUserSeed = name + " " + email;
      }
    }
    else if (seedCombo.equals("nn")) {

      originalUserSeed = name;
    }
    else if (seedCombo.equals("hs")) {

      originalUserSeed = hotSyncId;
    }

    //character array to hold the user seed
    char[] userSeed = buildUserSeed(originalUserSeed);

    System.out.println(new String(userSeed));

    return new String(userSeed);

  }


  /**
   *
   * @param originalSeed
   * @return
   */
  private char[] buildUserSeed(String originalSeed) {


    char userSeed[] = new char[seedMax];

    String temp = originalSeed.toUpperCase();

    int i = 0;

    while (i < userSeed.length) {

      for (int j  = 0; j < temp.length() ; ++j) {

        char c = temp.charAt(j);

        if (((c >= '0') && (c <= '9')) || ((c >= 'A') && (c <= 'Z'))) {

          if (i < userSeed.length) {

            userSeed[i] = c;
            ++i;
          }
        }
      } // for
    } // while

    return userSeed;

  }


  /**
   * Validates the user seed decoded from reg code with that geneerated from
   * the user provided data.
   * @return
   */
  private boolean isRegCodeValidated() {

    boolean result = false;

    String seedFromData = createUserSeed();

    if (seedFromData.equals(userSeed)) {

      result = true;
    }


    return result;
  }



  /**
   * Unit test for testing the class DecodeRegCode
   */
  public static void main(String[] args) {

    String regCode = "PROD-CE0NYL-QER3H-5XE9L-M80C7-EC";
    String configuration = "SUPPLIERID:rupali_test%E:1%N:1%H:1%COMBO:ee%SDLGTH:10%CONSTLGTH:1%CONSTVAL:F%SEQL:1%ALTTEXT:Contact abc@supplier.com to obtain your registration code%SCRMBL:D1,,D0,,C0,,U8,,U5,,U3,,U2,,S0,,U9,,U6,,U4,,D2,,U1,,D3,,U0,,U7,,%ASCDIG:2%MATH:R,,R,,R,,R,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,0A,,%BASE:30%BASEMAP:HAKTNEDQ9M0318Y65PFCJX4WLG27UR%REGFRMT:PROD-^#####-#####-#####-#####-##[-#]";

    DecodeRegCode decodeCode = new DecodeRegCode(false, configuration);
    decodeCode.decode(regCode);

    System.out.println("The User seed is :" + decodeCode.getUserSeed());
    System.out.println("The constant value is   :" + decodeCode.getConstant());
    System.out.println("The sequence number: " + decodeCode.getSequenceNumber());
    System.out
        .println("The registration code date is :" + decodeCode.getRegDate());

    decodeCode.setEmail("janedoe@email.com");


    if (decodeCode.isRegCodeValidated() == true) {

      System.out.println("Seed validated");
    }
  }



}

