package src;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class Server {
    private static final int PORT = 4444;
    private static ArrayList<ClientInfo> clients = new ArrayList<>();

    public static void main(String[] args) {

        try(ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Running server...");
            while (true) {
                Socket clientSocket = serverSocket.accept();

                PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
                BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

                String name = in.readLine();
                ClientInfo client = new ClientInfo(clientSocket, out, in, name);
                clients.add(client);
                System.out.println("A client connected: " + name);

                new Thread(() -> handleClient(client)).start();
            }

        } catch (IOException e) {
            System.err.println("Server exception: " + e.getMessage());
        }
    }

    private static void handleClient(ClientInfo client) {
        try {
            String message;

            while((message = client.in.readLine()) != null) {
                System.out.println(client.name + " said: " + message);

                if (message.equalsIgnoreCase("exit")) {
                    break;
                }
            }
        } catch (IOException error) {
            System.err.println(error.getMessage());
        } finally {
            cleanupClient(client);
        }
    }

    private static synchronized void cleanupClient(ClientInfo client) {
        try {
            System.out.println(client.name + " disconnected.");
            synchronized (clients) {
                clients.remove(client);
            }
            if (client.socket != null) client.socket.close();
            if (client.in != null) client.in.close();
            if (client.out != null) client.out.close();
        } catch (IOException e) {
            System.err.println("Cleanup error: " + e.getMessage());
        }
    }
}

class ClientInfo {
    Socket socket;
    PrintWriter out;
    BufferedReader in;
    String name;

    public ClientInfo(Socket socket, PrintWriter out, BufferedReader in, String name) {
        this.socket = socket;
        this.in = in;
        this.out = out;
        this.name = name;
    }
}