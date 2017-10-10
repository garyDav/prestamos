import java.math.*;
import java.math.BigDecimal;
import java.math.BigInteger;

public class Aleatorio1 {
    private BigInteger xn = new BigInteger("0");//es la semilla
    private final BigInteger a = new BigInteger("1103515245");//multiplicador
    public final BigInteger m = new BigInteger("2").pow(32);//modulo
    private final BigInteger c = new BigInteger("12345");//constante aditiva

    public int precision = 5;// la cantidad de digitos despues del punto decimal

    public Aleatorio1() {
    }

    public BigInteger getXn() {
        return xn;
    }

    public void setXn(BigInteger xn) {
        this.xn = xn;
    }

    public int getPrecision() {
        return precision;
    }

    public void setPrecision(int precision) {
        this.precision = precision;
    }
    public BigDecimal next() {
        //xn=(a*xn+c)%m;
        //System.out.println("xn-> "+xn);
        xn = ((xn.multiply(a)).add(c)).mod(m);
        BigDecimal r = new BigDecimal(xn.floatValue() / m.floatValue()).setScale(precision, BigDecimal.ROUND_HALF_UP);
        //System.out.print("1"+"-- "+m);
        
        return r;
        
    }
}

