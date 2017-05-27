grammar Lua;

// TODO: Preencher no final para a entrega
@members {
   public static String grupo="<<Digite os RAs do grupo aqui>>";
}


/*
* Regras Léxicas
*/

fragment LETRA : ('a'..'z'|'A'..'Z');
fragment DIGITO : ('0'..'9');

CADEIA : ('"'(~'"')*'"') | ([\\'](~[\\'])*[\\']);

COMENTARIO : '--'(~[\n]|[\r])+ -> skip;

WS : ' ' -> skip; // Whitespace

EOL : ([\n] | [\r] | [\t]) -> skip;

PALAVRA_RESERVADA : 'and' | 'break' | 'do' | 'else' | 'elseif' |
                    'end' | 'false' | 'for' | 'function' | 'if' |
                    'in' | 'local' | 'nil' | 'not' | 'or' | 'repeat' |
                     'return' | 'then' | 'true' | 'until' | 'while';

SIMBOLO_RESERVADO : '+' | '-' | '*' | '/' | '%' | '^' | '#' |
                    '==' | '~=' | '<=' | '>=' | '<' | '>' | '=' |
                    '(' | ')' | '{' | '}' | '[' | ']' |
                    ';' | ':' | ',' | '.' | '..' | '...';

IDENTIFICADOR : (LETRA|'_')(LETRA|DIGITO|'_')*;

NUMERO : (DIGITO)+('.'(DIGITO)+)?;


/*
* Regras Sintáticas
*/

programa : trecho;

trecho : (comando (';')?)* (ultimocomando (';')?)?;

bloco : trecho;

comando : listavar '=' listaexp | chamadadefuncao | 'do' bloco 'end' |
            'while' exp 'do' bloco 'end' | 'repeat' bloco 'until' exp |
            'if' exp 'then' bloco ('elseif' exp 'then' bloco)* ('else' bloco)? 'end' |
            'for' IDENTIFICADOR '=' exp ',' exp (',' exp)? 'do' bloco 'end' |
            'for' listadenomes 'in' listaexp 'do' bloco 'end' | 'function' nomedafuncao corpodafuncao { TabelaDeSimbolos.adicionarSimbolo($nomedafuncao.text,Tipo.FUNCAO);}|
            'local' 'function' IDENTIFICADOR corpodafuncao | 'local' listadenomes ('=' listaexp)?;

ultimocomando : 'return' (listaexp)? | 'break';

nomedafuncao : IDENTIFICADOR ('.' IDENTIFICADOR)* (':' IDENTIFICADOR)?;

listavar : var (',' var)*;

var : IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL); } | expprefixo '[' exp ']' | expprefixo '.' IDENTIFICADOR ;

listadenomes : IDENTIFICADOR (',' IDENTIFICADOR)*;

listaexp : (exp ',')* exp;

exp : 'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao |
    expprefixo | construtortabela | exp opbin exp | opunaria exp;

//expprefixo : var | chamadadefuncao | '(' exp ')';

expprefixo : IDENTIFICADOR expprefixo_aux | IDENTIFICADOR |
             chamadadefuncao expprefixo_aux | chamadadefuncao | expprefixo_aux |
             '(' exp ')' expprefixo_aux | '(' exp ')';

expprefixo_aux : '[' exp ']' expprefixo_aux | '[' exp ']' |
                 '.' IDENTIFICADOR expprefixo_aux | '.' IDENTIFICADOR;

//chamadadefuncao : expprefixo args | expprefixo ':' IDENTIFICADOR args;

chamadadefuncao : IDENTIFICADOR expprefixo_aux args chamadadefuncao_aux |
                  IDENTIFICADOR args | IDENTIFICADOR expprefixo_aux args | IDENTIFICADOR args chamadadefuncao_aux |
                  '(' exp ')' 'fim' expprefixo_aux args chamadadefuncao_aux |
                  '(' exp ')' 'fim' args | '(' exp ')' 'fim' expprefixo_aux args | '(' exp ')' 'fim' args chamadadefuncao_aux |
                  IDENTIFICADOR expprefixo_aux ':' IDENTIFICADOR args chamadadefuncao_aux |
                  IDENTIFICADOR ':' IDENTIFICADOR args | IDENTIFICADOR expprefixo_aux ':' IDENTIFICADOR args | IDENTIFICADOR ':' IDENTIFICADOR args chamadadefuncao_aux |
                  '(' exp ')' 'fim' expprefixo_aux ':' IDENTIFICADOR args chamadadefuncao_aux |
                  '(' exp ')' 'fim' ':' IDENTIFICADOR args | '(' exp ')' 'fim' expprefixo_aux ':' IDENTIFICADOR args | '(' exp ')' 'fim' ':' IDENTIFICADOR args chamadadefuncao_aux;

chamadadefuncao_aux : expprefixo_aux args chamadadefuncao_aux |
                      args | expprefixo_aux args | args chamadadefuncao_aux |
                      expprefixo_aux':' IDENTIFICADOR args chamadadefuncao_aux |
                      ':' IDENTIFICADOR args | expprefixo_aux':' IDENTIFICADOR args | ':' IDENTIFICADOR args chamadadefuncao_aux;

args : '(' (listaexp)? ')' | construtortabela | CADEIA;

funcao : 'function' corpodafuncao;

corpodafuncao : '(' (listapar)? ')' bloco 'end';

listapar : listadenomes (',' '...')? | '...';

construtortabela : '{' (listadecampos)? '}';

listadecampos : campo (separadordecampos campo)* (separadordecampos)?;

campo : '[' exp ']' '=' exp | IDENTIFICADOR '=' exp | exp;

separadordecampos : ',' | ';';

opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' | '<' | '<=' | '>' | '>=' | '==' | '~=' |
       'and' | 'or';

opunaria : '-' | 'not' | '#';
