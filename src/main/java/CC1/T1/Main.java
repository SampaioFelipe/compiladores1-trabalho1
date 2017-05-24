package CC1.T1;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.Token;

import java.io.FileInputStream;
import java.io.IOException;

public class Main {

    public static void main(String[] args) {
        try {
            ANTLRInputStream ais = new ANTLRInputStream(new
                    FileInputStream("/home/felipe/intelliJProjects/CC1-T1/src/main/java/CC1/T1/exemplos/lua1.txt"));
            LuaLexer lex = new LuaLexer(ais);
            while (lex.nextToken().getType() != Token.EOF) {
                System.out.println(lex.getToken());
            }
        } catch (IOException ex) { }
    }
}
