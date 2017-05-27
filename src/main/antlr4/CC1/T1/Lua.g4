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

WS : (' ' | [\t]) -> skip; // Whitespace

EOL : ([\n] | [\r] | [EOF]) -> skip;

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
            'for' IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);}  '=' exp ',' exp (',' exp)? 'do' bloco 'end' |
            'for' listadenomes 'in' listaexp 'do' bloco 'end' | 'function' nomedafuncao { TabelaDeSimbolos.adicionarSimbolo($nomedafuncao.text,Tipo.FUNCAO);} corpodafuncao |
            'local' 'function' IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.FUNCAO);} corpodafuncao | 'local' listadenomes ('=' listaexp)?;

ultimocomando : 'return' (listaexp)? | 'break';

nomedafuncao : IDENTIFICADOR ('.' IDENTIFICADOR)* (':' IDENTIFICADOR)?;

listavar : var (',' var)*;

var : IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL); } | expprefixo '[' exp ']' | expprefixo '.' IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} ;

listadenomes : IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} (',' IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);})*;

listaexp : (exp ',')* exp;

//exp : 'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao |
//    expprefixo | construtortabela | exp opbin exp | opunaria exp;

//exp : exp opbin exp | opunaria exp;
exp : exp1 opbin7 exp | exp1;

exp1 : exp2 opbin6 exp1 | exp2;

exp2 : exp3 opbin5 exp2 | exp3;

exp3 : exp4 opbin4 exp3 | exp4;

exp4 : exp5 opbin3 exp4 | exp5;

exp5 : opunaria exp5 | exp6;

exp6 : exp7 opbin2 exp6 | exp7;

exp7 : exp_operandos opbin1 exp7 | exp_operandos;


exp_operandos : 'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao |
                expprefixo | construtortabela ;

//expprefixo : var | chamadadefuncao | '(' exp ')';

expprefixo : IDENTIFICADOR expprefixo_aux | IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} |
             chamadadefuncao expprefixo_aux | chamadadefuncao | expprefixo_aux |
             '(' exp ')' expprefixo_aux | '(' exp ')';

expprefixo_aux : '[' exp ']' expprefixo_aux | '[' exp ']' |
                 '.' IDENTIFICADOR expprefixo_aux | '.' IDENTIFICADOR;

//chamadadefuncao : expprefixo args | expprefixo ':' IDENTIFICADOR args;

chamadadefuncao : IDENTIFICADOR expprefixo_aux args chamadadefuncao_aux |
                  IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.FUNCAO);} args | IDENTIFICADOR expprefixo_aux args | IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.FUNCAO);} args chamadadefuncao_aux |
                  '(' exp ')'  expprefixo_aux args chamadadefuncao_aux |
                  '(' exp ')'  args | '(' exp ')'  expprefixo_aux args | '(' exp ')'  args chamadadefuncao_aux |
                  IDENTIFICADOR expprefixo_aux ':' IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.FUNCAO);} args chamadadefuncao_aux |
                  IDENTIFICADOR ':' IDENTIFICADOR args | IDENTIFICADOR expprefixo_aux ':' IDENTIFICADOR args | IDENTIFICADOR ':' IDENTIFICADOR args chamadadefuncao_aux |
                  '(' exp ')' expprefixo_aux ':' IDENTIFICADOR args chamadadefuncao_aux |
                  '(' exp ')'  ':' IDENTIFICADOR args | '(' exp ')' expprefixo_aux ':' IDENTIFICADOR args | '(' exp ')' ':' IDENTIFICADOR args chamadadefuncao_aux;

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

campo : '[' exp ']' '=' exp | IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} '=' exp | exp;

separadordecampos : ',' | ';';

//opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' | '<' | '<=' | '>' | '>=' | '==' | '~=' |
//       'and' | 'or';

opbin1 : '^';

opbin2 : '*' | '/' | '%';

opbin3 : '+' | '-';

opbin4 : '..';

opbin5 : '<' | '<=' | '>' | '>=' | '==' | '~=';

opbin6 : 'and';

opbin7 : 'or';

opunaria : '-' | 'not' | '#';
