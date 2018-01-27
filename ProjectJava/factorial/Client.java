import java.rmi.*;
import java.rmi.registry.*;
import java.util.Scanner;

public class Client{
    public static void main(String args[]){
	Factoriel calculator;
      int number;
	try {
	    System.out.println("Numero Cabron Gary: ");
	    Scanner leer=new Scanner(System.in);
	    number = leer.nextInt();
	    calculator=(Factoriel)Naming.lookup("rmi://localhost/TheCalculator");
          //number=Integer.parseInt("5");
	    System.out.println();
	    System.out.println( "   "+number+"! = "+calculator.compute(number));
	    System.out.println();
	}
	catch (Exception e){
	    e.printStackTrace();
	}
    }
}

