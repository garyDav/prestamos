import java.rmi.*;
import java.rmi.registry.*;

public class Client{
    public static void main(String args[]){
	Factoriel calculator;
      int number;
	try {
	    calculator=(Factoriel)Naming.lookup("rmi://localhost/TheCalculator");
          number=Integer.parseInt(args[0]);
	    System.out.println();
	    System.out.println( "   "+number+"! = "+calculator.compute(number));
	    System.out.println();
	}
	catch (Exception e){
	    e.printStackTrace();
	}
    }
}

