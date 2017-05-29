grammar Lua;

@members {
   public static String grupo="619523,619655,619744";
}

/*
* Regras Léxicas
* Foram utilizadas as diretrizes especificadas na documentação do Antlr4
* https://github.com/antlr/antlr4/blob/master/doc/lexer-rules.md
*/

// Declaração de fragmentos que serão utilizados em outras regras léxicas
fragment LETRA : ('a'..'z'|'A'..'Z');
fragment DIGITO : ('0'..'9');

// Foi utilizada a notação [\\'] para representa o caracter '
// Pois é um caracter especial na notação do antlr
CADEIA : ('"'(~'"')*'"') | ([\\'](~[\\'])*[\\']);

// A notação "-> skip" diz ao antlr para ignorar o token
// No nosso caso estamos ignorando todos os comentários, espaços em branco
// e quebras de linha
COMENTARIO : '--'(~[\n]|[\r])+ -> skip;

WS : (' ' | [\t]) -> skip; // White Space

EOL : ([\n] | [\r]) -> skip; // End of Line

// Palavras e simbolos reservados segundo a gramática da Lua
// Foram declarados antes das demais regras para que não possam ser
// utilizadas em outro contexto (como um identiifcador por exemplo)
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
*
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


// As regras a baixo foram modificadas para que fosse possível implementar
// a precedência de operadores.

// Regras originais:
// exp : 'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao | expprefixo | construtortabela | exp opbin exp | opunaria exp;
// opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' | '<' | '<=' | '>' | '>=' | '==' | '~=' | 'and' | 'or';

// Regras resultantes:
exp : exp1 opbin7 exp | exp1;

exp1 : exp2 opbin6 exp1 | exp2;

exp2 : exp3 opbin5 exp2 | exp3;

exp3 : exp4 opbin4 exp3 | exp4;

exp4 : exp5 opbin3 exp4 | exp5;

exp5 : opunaria exp5 | exp6;

exp6 : exp7 opbin2 exp6 | exp7;

exp7 : exp_operandos opbin1 exp7 | exp_operandos;

opbin1 : '^';

opbin2 : '*' | '/' | '%';

opbin3 : '+' | '-';

opbin4 : '..';

opbin5 : '<' | '<=' | '>' | '>=' | '==' | '~=';

opbin6 : 'and';

opbin7 : 'or';

opunaria : '-' | 'not' | '#'; // Regra original mantida


//A produção exp_operandos foi criada para simplificar as regras modificadas
//que implementam a precedência de operadores
exp_operandos : 'nil' | 'false' | 'true' | NUMERO | CADEIA | '...' | funcao |
                expprefixo | construtortabela ;
// Fim da alteração de precedência de operadores


// Na gramática fornecida pela documentação da Lua, havia uma recursão
// não-direta [var, expprefixo, chamadadefuncao], que o antlr não consegue lidar.
// Foi utilizado o algoritmo apresentado no site abaixo para eliminar essa recursão:
// http://www.csd.uwo.ca/~moreno/CS447/Lectures/Syntax.html/node8.html

// Regras originais:
// expprefixo : var | chamadadefuncao | '(' exp ')';
// chamadadefuncao : expprefixo args | expprefixo ':' IDENTIFICADOR args;

// Regras resultantes:
expprefixo : IDENTIFICADOR expprefixo_aux | IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} |
             chamadadefuncao expprefixo_aux | chamadadefuncao | expprefixo_aux |
             '(' exp ')' expprefixo_aux | '(' exp ')';

expprefixo_aux : '[' exp ']' expprefixo_aux | '[' exp ']' |
                 '.' IDENTIFICADOR expprefixo_aux | '.' IDENTIFICADOR;

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
// Fim da eliminação da recursão


args : '(' (listaexp)? ')' | construtortabela | CADEIA;

funcao : 'function' corpodafuncao;

corpodafuncao : '(' (listapar)? ')' bloco 'end';

listapar : listadenomes (',' '...')? | '...';

construtortabela : '{' (listadecampos)? '}';

listadecampos : campo (separadordecampos campo)* (separadordecampos)?;

campo : '[' exp ']' '=' exp | IDENTIFICADOR { TabelaDeSimbolos.adicionarSimbolo($IDENTIFICADOR.text,Tipo.VARIAVEL);} '=' exp | exp;

separadordecampos : ',' | ';';
