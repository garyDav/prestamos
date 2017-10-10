
import java.rmi.*;

public interface Factoriel extends Remote {
    long compute(long arg) throws RemoteException; 
}


