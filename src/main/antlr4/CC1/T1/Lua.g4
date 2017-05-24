grammar Lua;

/*
* Regras Léxicas
*/

fragment LETRA : ('a'..'z'|'A'..'Z');
fragment DIGITO : ('0'..'9');


PALAVRA_RESERVADA : 'and' | 'break' | 'do' | 'else' | 'elseif' |
                    'end' | 'false' | 'for' | 'function' | 'if' |
                    'in' | 'local' | 'nil' | 'not' | 'or' | 'repeat' |
                     'return' | 'then' | 'true' | 'until' | 'while';

SIMBOLO_RESERVADO : '+' | '-' | '*' | '/' | '%' | '^' | '#' |
                    '=='| '~=' | '<=' | '>=' | '<' | '>' | '=' |
                    '(' | ')' | '{' | '}' | '[' | ']' |
                    ';' | ':' | ',' | '.' | '..' | '...';

IDENTIFICADOR : (LETRA|'_')(LETRA|DIGITO|'_')*;

// Cadeias de caracteres literais podem ser delimitadas através do uso de aspas simples ou aspas duplas

CADEIA : ('\'')|(' ');

NUMERO : (DIGITO)+('.'(DIGITO)+)?;

WS : ' ' {skip()}; // Whitespace


/*
* Regras Sintáticas
*/

//programa : IDENTIFICADOR | PALAVRA_RESERVADA;

programa : trecho;

trecho : (comando (';')?)* (ultimocomando (';')?)?;
// Isso é necessário?
bloco : trecho;

comando : listavar '=' listaexp | chamadadefuncao | do bloco end |
            while exp do bloco end | repeat bloco until exp |
            if exp then bloco (elseif exp then bloco)* (else bloco)? end |
            for IDENTIFICADOR '=' exp ',' exp (',' exp)? do bloco end |
            for listadenomes in listaexp do bloco end | function nomedafuncao corpodafuncao |
            local function IDENTIFICADOR corpodafuncao | local listadenomes ('=' listaexp)?;

ultimocomando : return (listaexp)? | break;

nomedafuncao : IDENTIFICADOR ('.' IDENTIFICADOR)+ (':' IDENTIFICADOR)?;

listavar : var (',' var)*;

var : IDENTIFICADOR | expprefixo '[' exp ']' | expprefixo '.' IDENTIFICADOR;

listadenomes : IDENTIFICADOR (',' IDENTIFICADOR)*;

listaexp : (exp ',')* exp;

exp : nil | false | true | NUMERO | CADEIA | '...' | funcao |
    expprefixo | construtortabela | exp opbin exp | opunaria exp;

expprefixo : var | chamadadefuncao | '(' exp ')';

chamadadefuncao : expprefixo args | expprefixo ':' IDENTIFICADOR args;

args : '(' (listaexp)? ')' | construtortabela | CADEIA;

funcao : function corpodafuncao;

corpodafuncao : '(' (listapar)? ')' bloco end;

listapar : listadenomes (',' '...')? | '...';

construtortabela : '{' (listadecampos)? '}';

listadecampos : campo (separadordecampos campo)* (separadordecampos)?;

campo : '[' exp ']' '=' exp | IDENTIFICADOR '=' exp | exp;

separadordecampos : ',' | ';';

opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' | '<' | '<=' | '>' | '>=' | '==' | '~=' |
       and | or;

opunaria : '-' | not | '#';





// TODO: Preencher no final para a entrega
//@members {
//   public static String grupo="<<Digite os RAs do grupo aqui>>";
//}
