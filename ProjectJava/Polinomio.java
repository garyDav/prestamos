import java.util.regex.*;

public class Polinomio {
	Polinomio() {

	}

	public String[][] strToArray(String cad) {
		String[] monomio = cad.split("(?=\\+)|(?=-)");//^-|^+    (?<=-)|(?<=\\+)
		int n = monomio.length;
		String[][] baseEx = new String[2][n];
		for(int i=0;i<n;i++) {
			String[] aux = monomio[i].split("x\\^",2);
			baseEx[0][i] = aux[0];
			if( aux.length >= 2 )
				baseEx[1][i] = aux[1];
			else
				baseEx[1][i] = "0";
		}
		return baseEx;
	}

	public int longitudN(String x[],String y[]) {
		int n = 0;
		for (String elX : x ) {
			for(String elY: y ) {
				if( elX.equals(elY) ) {
					n++;
					break;
				}
			}
		}
		return (x.length+y.length)-n;
	}

	public int[][] suma(String x[][],String y[][],int n) {
		int[][] res = new int[2][n];
		int aux = 0;
		int inc = 0;
		int iy = 0; //indice del vector y
		for(int i=0;i<x[1].length;i++) {
			for(int j=iy;j<y[1].length;j++) {
				if( x[1][i].equals(y[1][j]) ) {
					aux = Integer.parseInt(x[0][i]) + Integer.parseInt(y[0][j]);
					res[0][inc] = aux;
					res[1][inc] = Integer.parseInt(x[1][i]);
					inc++; iy++;
					break;
				} else if( Integer.parseInt(x[1][i]) > Integer.parseInt(y[1][j]) ) {
					res[0][inc] = Integer.parseInt(x[0][i]);
					res[1][inc] = Integer.parseInt(x[1][i]);
					inc++;
					break;
				} else if( Integer.parseInt(x[1][i]) < Integer.parseInt(y[1][j]) ) {
					res[0][inc] = Integer.parseInt(y[0][j]);
					res[1][inc] = Integer.parseInt(y[1][j]);
					inc++; iy++;
				}
			}
		}
		return res;
	}
	public int[][] resta(String x[][],String y[][],int n) {
		int[][] res = new int[2][n];
		int aux = 0;
		int inc = 0;
		int iy = 0; //indice del vector y
		for(int i=0;i<x[1].length;i++) {
			for(int j=iy;j<y[1].length;j++) {
				if( x[1][i].equals(y[1][j]) ) {
					aux = Integer.parseInt(x[0][i]) - Integer.parseInt(y[0][j]);
					res[0][inc] = aux;
					res[1][inc] = Integer.parseInt(x[1][i]);
					inc++; iy++;
					break;
				} else if( Integer.parseInt(x[1][i]) > Integer.parseInt(y[1][j]) ) {
					res[0][inc] = Integer.parseInt(x[0][i]);
					res[1][inc] = Integer.parseInt(x[1][i]);
					inc++;
					break;
				} else if( Integer.parseInt(x[1][i]) < Integer.parseInt(y[1][j]) ) {
					res[0][inc] = Integer.parseInt(y[0][j]);
					res[1][inc] = Integer.parseInt(y[1][j]);
					inc++; iy++;
				}
			}
		}
		return res;
	}

	public static void main(String args[]) {
		Polinomio p = new Polinomio();
		int n = 0;
		String[][] pol1 = p.strToArray("+10x^15+10x^9+10x^7+10x^6+10x^4+10x^3+10x^1+10");
		String[][] pol2 = p.strToArray("-3x^10-3x^8-3x^7-3x^5-3x^3-3x^2-3");

		n = p.longitudN(pol1[1],pol2[1]);
		int[][] suma = p.suma(pol1,pol2,n);
		int[][] resta = p.resta(pol1,pol2,n);



		for(int i=0;i<=1;i++) {
			for (String el : pol1[i] ) {
				System.out.print(el + " ");
			}
			System.out.println();
		}
		for(int i=0;i<=1;i++) {
			for (String el : pol2[i] ) {
				System.out.print(el + " ");
			}
			System.out.println();
		}

		for(int i=0;i<=1;i++) {
			for (int el : suma[i] ) {
				System.out.print(el + " ");
			}
			System.out.println();
		}

		System.out.println(Integer.parseInt("42")>Integer.parseInt("8"));
		/*int[] x = new int[10];
		x[0] = 1;
		x[1] = 2;
		x[2] = 3;
		for(int a : x) {
			System.out.println(a);
		}*/

		//System.out.println(aux.length);
		/*for(String a : aux) {
			System.out.println(a);
		}
		System.out.println();
		*/
	}

}