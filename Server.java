import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

class Client {
    Socket socket;
    PrintWriter out;
    BufferedReader in;

    public Client(Socket socket, PrintWriter out, BufferedReader in) {
        this.socket = socket;
        this.in = in;
        this.out = out;
    }
}

public class Server {
    public static void main(String[] args) {
        ServerSocket serverSocket = null;
        Client client = null;

        while (true) {
            try {
                serverSocket = new ServerSocket(4444);
                client = connectClientToServerSocket(serverSocket);
                String response = null;

                while (true) {
                    response = client.in.readLine();
                    System.out.println("Received: " + response);
                    if (response.equalsIgnoreCase("exit")) {
                        break;
                    }
                }

            } catch (IOException e) {
                System.err.println(e.getMessage());
                break;
            } finally {
                try {
                    if (serverSocket != null) {
                        serverSocket.close();
                    }
                    if (client.out != null) {
                        client.out.close();
                    }
                    if (client.in != null) {
                        client.in.close();
                    }
                    if (client.socket != null) {
                        client.socket.close();
                    }
                } catch (IOException e) {
                    System.err.println(e.getMessage());
                    break;
                }
            }
        }
    }

    public static Client connectClientToServerSocket(ServerSocket serverSocket) {
        Client client = null;
        PrintWriter out = null;
        BufferedReader in = null;

        try {
            Socket clientSocket = serverSocket.accept();
            out = new PrintWriter(clientSocket.getOutputStream(), false);
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

            client = new Client(clientSocket, out, in);
            System.out.println("Client connected: " + clientSocket.getInetAddress().getHostName());

        } catch (IOException error) {
            System.err.println("Accept failed with error: " + error.getMessage());
            System.exit(1);
        }
        return client;
    }
}
