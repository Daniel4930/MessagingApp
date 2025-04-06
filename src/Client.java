package src;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) {

        try(Scanner scanner = new Scanner(System.in);
            Socket clientSocket = new Socket("localhost", 4444);
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()))
        ){
            String message = "";
            System.out.print("Enter your name: ");
            String name = scanner.nextLine();

            System.out.println("Connected to server.");
            System.out.println("Type \"exit\" to stop the connection.");

            out.write(name);
            out.println();

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
        }
    }
}
