/**
 * BIgIntArithmetic.java
 * Created on Mar 18, 2005
 * Copyright(c) 2005  Kagi. All rights reserved.
 */
package com.kagi.acg;

/**
 * This class is used to perform arithmetic operations on large integers, which
 * cannot be represented by long primitive type in java. It converts the numbers to
 * integer arrays and performs arithmetic operations on each digit.The arrays are
 * dynamically increased as per the number of digits in the integer.
 */

public class BigIntArithmetic {
  public static boolean debug = false;

  /**
   * Returns of value of the first argument raised to the power of the second
   * argument.
   * 
   * @param base
   *          The number whose power is to be calculated
   * @param index
   *          The power(the power is always going to be in the range that can be
   *          represented by an int. This is calculated by multiplying the number
   *          power times. so 2 ^ 4 = 2 * 2 * 2 *2
   */
  public static String pow(String base, int index) 
  {
    String result = "1";
    if (debug) {
      System.out.println("The operands of pow are " + base + "  " + index);
    }
    //repeat the multiplication power times
    for (int i = 0; i < index; ++i) {
      
      result = multiply(result, base);
    }
    
    return result;
  }

  /**
   * @param multiplicand
   *          so in 2 * 4 2 is the multiplicand
   * @param baseNumb :
   *          the multiplier. so 4 is the multiplier Returns a String representation
   *          of a number whose value is (multiplicand * baseNumb). Multiplication is
   *          accomplished by adding the multiplicand multiplier times i.e 2+2+2+2
   * @return the reulst of multiplying multiplicand * baseNumb
   */

  public static String multiply(String multiplicand, String baseNumb) {
    if (debug)
      System.out.println("The operands for multiply are" + multiplicand + "  "
          + baseNumb);
    
    int multiplier = Integer.parseInt(baseNumb);
    int operand1[] = toArray(multiplicand);
    int result[] = toArray("0");
    
    // add the multiplicand ,multiplier times
    for (int i = 0; i < multiplier; ++i) {
      result = add(result, operand1);
      operand1 = toArray(multiplicand);
    }
    
    if (debug)
      System.out.println("The result of multiplying " + multiplicand + " * "
          + baseNumb + " is " + result);
    return toString(result);
  }

  /**
   * @param number
   *          The string representing a number Converts the string representaion of a
   *          number to an array of ints.
   */

  public static int[] toArray(String number) {
    int digits[] = new int[number.length()];
    for (int i = 0; i < number.length(); ++i) {
      String digit = String.valueOf(number.charAt(i));
      digits[i] = Integer.parseInt(digit);
    }
    return digits;
  }

  /**
   * @param operand1[]
   *          an int array
   * @param operand2[]
   *          an int array
   * @return Returns an int array obtained by adding operand1[] + operand2[]
   */

  public static int[] add(int operand1[], int operand2[]) {
    int op1[], op2[];
    int k, j;

    // assign to k the last index of the larger of the
    // two operands.
    if (operand1.length >= operand2.length) {
      k = operand1.length - 1;
      j = operand2.length - 1;
      op1 = operand1;
      op2 = operand2;
    }
    else {
      k = operand2.length - 1;
      j = operand1.length - 1;
      op1 = operand2;
      op2 = operand1;
    }

    int carry = 0;
    int sum = 0;
    // repeat the loop until k is >= "0".
    // The other operand is smaller.
    for (int i = k; i >= 0; --i) {
      //if the inner operand has digits
      //then use them to find the sum.
      if (j >= 0) {
        sum = op1[i] + op2[j] + carry;
      }
      else {
        // there are no digits in the smaller number
        // so the sum is obtained by adding the digit of the
        // larger number and the carry if it is greater than zero.
        if (carry > 0) {
          sum = op1[i] + carry;
        }
        else
          sum = op1[i];
      }
      //reset the carry.
      carry = 0;
      String digits = Integer.toString(sum);

      if (digits.length() > 1) {
        // seperate the unit and tens digit.
        op1[i] = sum % 10;
        carry = sum / 10;
      }
      else {
        op1[i] = sum;
      }
      --j;
    }//for
    int result[];
    //if we run out of digits and there is a carry,then
    // we have to increase the number of digits.
    if (carry != 0) {
      result = new int[op1.length + 1];
      result[0] = carry;
      //now copy the remaining number into the new array
      for (int i = 1; i < result.length; ++i)
        result[i] = op1[i - 1];
    }
    else
      result = op1;

    return result;
  }

  /**
   * This method converts an array of integers to a String
   * 
   * @param number
   *          an integer array
   * @return the string representation of the number
   */
  public static String toString(int[] number) {
    StringBuffer numb = new StringBuffer();

    for (int i = 0; i < number.length; ++i) {
      numb.append(number[i]);
    }
    return numb.toString();
  }

  /**
   * This method returns the result of adding two number represented by string.
   * 
   * @param operand1
   *          A string representing the number
   * @param operand2
   *          A string representing the number
   * @return the result of adding operand1 and operand2
   */

  public static String add(String operand1, String operand2) {
    int op1[] = toArray(operand1);
    int op2[] = toArray(operand2);
    int result[] = add(op1, op2);
    return toString(result);
  }

  /**
   * Method for unit testing BigIntArithmetic
   */
  public static void main(String args[]) {
    String result = BigIntArithmetic.pow("2", 10);
    System.out.println("The result is:" + result);
  }

}