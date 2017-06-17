import java.math.BigInteger;

public class Principal{

    public static void main(String[] args) {
        Aleatorio1 aleatorio = new Aleatorio1();
        Principal p = new Principal();
        aleatorio.setXn(new BigInteger("111"));
        //BigInteger entero = new BigInteger("0");
        String cadena = "";
        int fo[]=new int[7];
        double fe[]=new double[7];

        int td=0,par=0,par2=0,trica=0,full=0,poker=0,quin=0;


        aleatorio.setPrecision(5);
        for (int i = 1; i <= 100; i++) {
			cadena = aleatorio.next().toString();
            switch( p.proba(cadena.substring(2)) ) {
                case 1:
                    System.out.println(cadena.substring(2)+"-");
					td++;
					break;
				case 2:
					par++;
					break;
				case 3:
					par2++;
					break;
				case 4:
					trica++;
					break;
				case 5:
					full++;
					break;
				case 6:
					poker++;
					break;
				case 7:
					quin++;
					break;
			}
        }
        fo[0] = td;         fe[0] = 30.24;
        fo[1] = par;        fe[1] = 50.40;
        fo[2] = par2;       fe[2] = 10.80;
        fo[3] = trica;      fe[3] = 7.20;
        fo[4] = full;       fe[4] = 0.90;
        fo[5] = poker;      fe[5] = 0.45;
        fo[6] = quin;       fe[6] = 0.010;


        
        System.out.println("------Frecuencia Observada---------Frecuencia Esperada--------");
        System.out.println("Todos Diferentes :"+ fo[0] +"                       "+fe[0]);
        System.out.println("Un par           :"+ fo[1] +"                       "+fe[1]);
        System.out.println("Dos pares        :"+ fo[2] +"                        "+fe[2]);
        System.out.println("Trica o tercia   :"+ fo[3] +"                        "+fe[3]);
        System.out.println("Full             :"+ fo[4] +"                        "+fe[4]);
        System.out.println("Poker            :"+ fo[5] +"                        "+fe[5]);
        System.out.println("Quintilla        :"+ fo[6] +"                        "+fe[6]);
        System.out.println("--------------------------------------------------------------");

        if( p.chiCuadrado(fo,fe),2 ) < 7.81 ) {
            System.out.println( p.redondear( p.chiCuadrado(fo,fe),2 )+" < "+7.81+": No se rechaza la Hipotesis" );
        } else
            System.out.println("Se rechaza la Hipotesis");


    }
    public int proba(String num) {
    	int ctP=0;
    	for(int i=0;i<4;i++) {
        	for(int j=i+1;j<5;j++) {
        		if( num.charAt(i) == num.charAt(j) )
        			ctP++;
        	}
		}
		if(ctP==0)
            return 1;
        if(ctP==1)
            return 2;
        if(ctP==2)
            return 3;
        if(ctP==3)
            return 4;
        if(ctP==4)
            return 5;
        if(ctP==6)
            return 6;
        if(ctP==10)
            return 7;
        return 0;
    }
    public static double redondear(double numero,int digitos) {
          int cifras=(int) Math.pow(10,digitos);
          return Math.rint(numero*cifras)/cifras;
    }
    public double chiCuadrado(int[] fo,double[] fe) {
        double res=0;
        double ctfo=0,ctfe=0;
        for (int i=0;i<fo.length ;i++ ) {
            if(i<3) {
                res+=Math.pow( (fo[i]-fe[i]),2 )/fe[i];
                System.out.println("Res: "+res);
            }
            if(i>2) {
                ctfo+=fo[i];
                ctfe+=fe[i];
            }
        }
        /*System.out.println("ctfo: "+ctfo);
        System.out.println("ctfe: "+ctfe);*/

        return res+=Math.pow( (ctfo-ctfe),2 )/ctfe;
    }
}