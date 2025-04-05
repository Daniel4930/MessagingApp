import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public static void main(String[] args) {
        ServerSocket serverSocket = null;
        PrintWriter out = null;
        BufferedReader in = null;

        try {
            serverSocket = new ServerSocket(4444);
            Socket clientSocket = connectClientToServerSocket(serverSocket);
            out = new PrintWriter(clientSocket.getOutputStream(), false);
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            String response = null;

            // out.println("Welcome " + clientSocket.getInetAddress().getHostAddress());

            while (true) {
                response = in.readLine();
                System.out.println("Received: " + response);
                if (response.equalsIgnoreCase("exit")) {
                    break;
                }
            }

        } catch (IOException e) {
            System.err.println(e.getMessage());
        } finally {
            try {
                if (serverSocket != null) {
                    serverSocket.close();
                }
                if (out != null) {
                    out.close();
                }
                if (in != null) {
                    in.close();
                }
            } catch (IOException e) {
                System.err.println(e.getMessage());
            }
        }
    }

    public static Socket connectClientToServerSocket(ServerSocket serverSocket) {
        Socket clientSocket = null;
        try {
            clientSocket = serverSocket.accept();
            System.out.println("Client connected: " + clientSocket.getInetAddress());
        } catch (IOException error) {
            System.err.println("Accept failed with error: " + error.getMessage());
            System.exit(1);
        }
        return clientSocket;
    }
}
