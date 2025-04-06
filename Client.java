import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) {
        Socket clientSocket = null;
        PrintWriter out = null;
        BufferedReader in = null;

        try {
            String message = "";
            Scanner scanner = new Scanner(System.in);
            System.out.print("Enter your name: ");
            String name = scanner.nextLine();

            clientSocket = new Socket("name", 4444);
            System.out.println("Connected to server.");
            System.out.println("Type \"exit\" to stop the connection.");

            out = new PrintWriter(clientSocket.getOutputStream(), true);
            in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

            while (true) {
                System.out.print("Enter a message: ");
                message = scanner.nextLine();
                out.write(message);
                out.println();

                if (message.equalsIgnoreCase("exit")) {
                    scanner.close();
                    break;
                }
            }

        } catch(IOException e) {
            System.out.println(e.getMessage());
        } finally {
            try {
                clientSocket.close();
                out.close();
                in.close();
            } catch (IOException e) {
                System.out.println(e.getMessage());
            }
        }
    }
}
