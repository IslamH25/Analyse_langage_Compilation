%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tableS.h"
#include "syntaxique.tab.h"
   extern nb; 
   extern col;
   extern YYSTYPE yylval;
   int i ;
   int j=0;
   char h = '(';
  
%}
commentaire ("#"[^#]*"!")|([#]*"!")
Chiffre [0-9]
Maj [A-Z]
Min [a-z]
lettre [a-zA-Z]
IDF ({lettre}|{Chiffre})+
INTEGER ({Chiffre}+|\([+-]{Chiffre}+\))
FLOAT (\([+-]{Chiffre}+"."{Chiffre}+\))|([+-]?{Chiffre}+"."{Chiffre}+)
STRING (\"[^"]*\")
Barre "|"
CHAR '.'
AFF "="
ADD "+"
SUB "-"
DIV "/"
MUL "*"
Operateur_L ".AND."|".OR."
Operateur_C ".G."|".L."|".GE."|".LE."|".EQ."|".DI."
PO "("
PF ")"
Chev "\""
%%                                
"IDENTIFICATION DIVISION"   {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_ID;}
"PROGRAM-ID"                {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_PID;}
"DATA DIVISION"             {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_DDiv;}
"WORKING-STORAGE SECTION"   {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_WSS; }
"PROCEDURE DIVISION"        {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_ProcDiv; }
"STOP RUN"                  {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_StR;}
"LINE"                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Line;}
"SIZE"                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Size;}
"INTEGER."                   {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Int;}
"FLOAT."                     {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Float;}
"CHAR."                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Char;}
"STRING."                    {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_String;}
"CONST"                     {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Const;}
"ACCEPT"                    {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Acc;}
"DISPLAY"                   {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Dis;}
"IF"                        {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_If;}
"ELSE"                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Else;}
"END"                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_End;}
"MOVE"                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Move;}
"TO"                        {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_To;}
"NOT"                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Mot Cle",0,1); return Mc_Not;}
{INTEGER}                   {col = col + strlen (yytext) ; 
                                                          if(yytext[0]=='+' || yytext[0] == '-') printf("erreur lexicale a la ligne %d, colonne %d de l'entite << %s >>\n",nb,col,yytext);
			                                              else if(yytext[0] ==h && yytext[yyleng -1] == ')' && (yytext[1] == '+' || yytext[1] == '-'))
			                                                   {
				                                                 if(yytext[2] == ')')
				                                                 {
					                                               printf("erreur lexical a la ligne %d, colonne %d de l'entite << %s >>\n",nb,col,(yytext));
				                                                 }
				                                                 else
				                                                 { char SousChaine[50];
																   j=0;
				                                                   for(i=1;(i<yyleng-1);i++)
				                                                   {
					                                                 SousChaine[j] = yytext[i] ;
					                                                 j++;
				                                                   }
                                                                   if(atoi(SousChaine) < 32767 && atoi(SousChaine) > -32768)
				                                                   {
					                                                 if(atoi(SousChaine)!=0)
					                                                 {
						                                               rechercher(yytext,"Const","int",atoi(SousChaine),0);
																	   yylval.entier= atoi(SousChaine);
																	   return Int;
					                                                 }
					                                                 else
						                                               printf("erreur lexical a la ligne %d, colonne %d de l'entite<< %s >>\n",nb,col,yytext);
				                                                    }
				                                                    else
					                                                   printf("erreur lexical a la ligne %d, colonne %d de l'entite<< %s >>\n",nb,col,yytext);
				                                                 }
			                                                    }
			                                                 else if(atoi(yytext) < 32767 && atoi(yytext) > -32768)
				                                                  {
					                                                 rechercher(yytext,"Const","int",atoi(yytext),0);
																	 yylval.entier= atoi(yytext);
																	 return Int;
				                                                  }	
				                                             else
					                                            printf("erreur lexical a la ligne %d, colonne %d de l'entite << %d >>\n",nb,col,atoi(yytext));}	
{IDF}                       {col = col + strlen (yytext) ; if (strlen(yytext)>8) printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext);
                                                           else 
														   { switch (yytext[0])
														     {
																case '0'...'9': 
																case 'a'...'z': printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext); break;												   
																case 'A'...'Z':
																	   for(i =1;i<yyleng;i++)
																       { switch (yytext[i]) 
																		 { case 'A'...'Z': col++ ; 
																		   printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext); 
																		   i=yyleng +1 ; 
																		   break ;
																		   default : break ;
																		  }
																		}
																		if(i==yyleng){ rechercher(yytext,"IDF"," ",88888,0); yylval.chaine= strdup(yytext); return Idf; }
																		break;
															 }
														    }
														   }                                        
{commentaire}               {col = col + strlen (yytext) ; printf("Commentaire reconnu \n");}										  
{FLOAT}                     {col = col + strlen (yytext) ; if(yytext[0]==h)
                                                           { char SousChaine[50];
														     j=0;
														   for(i=1; i<= strlen(yytext)-2; i++)
															 {
																SousChaine[j]= yytext[i];
																j++;
															 }
															 if (atof(SousChaine)==0) printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext); 
															 else 
															 {
															    rechercher(yytext,"Const","float",atof(SousChaine),0);
																yylval.reel= atof(SousChaine);
																return Float;
															 }
														   }
														   else if(yytext[0] == '+' || yytext[0] == '-')
															    {
																   printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext);
															    }
															    else
															     {
																    rechercher(yytext,"Const","float",atof(yytext),0);
																	yylval.reel= atof(yytext);
																	return Float;
															     }
													}																									
{CHAR}                      {col = col + strlen (yytext) ;  rechercher(yytext,"Const","char",88888,0); yylval.caractere= (int)strdup(yytext); return Char;}
{STRING}                    {col = col + strlen (yytext) ;  rechercher(yytext,"Const","string",88888,0); yylval.chaine= strdup(yytext); return String;} 
{Barre}                     {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); return Barre;}
{AFF}                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Aff; }
{ADD}                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Add;}
{SUB}                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Sub;}
{DIV}                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Div;}
{MUL}                       {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); return Mul;}
{Operateur_L}               {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return OpL;}
{Operateur_C}               {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); yylval.chaine= strdup(yytext); return OpC;} 
{PO}                        {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Po;}
{PF}                        {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); return Pf;}
{Chev}                      {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Chev;}
"&"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);yylval.caractere= (int)strdup(yytext);return SigneFormatage;}
"%"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);yylval.caractere= (int)strdup(yytext);return SigneFormatage;}
"#"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);yylval.caractere= (int)strdup(yytext);return SigneFormatage;}
"$"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);yylval.caractere= (int)strdup(yytext);return SigneFormatage;}
"@"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Arb;}
":"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return DeuxPoint;}
"."                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2);return Point;}
";"                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); return Pvg;}
","                         {col = col + strlen (yytext) ;  rechercher(yytext," ","Sep",0,2); return Virg;}
[ \t]  col=col+1;
[\n]   nb=nb+1; col=1;
. printf("Erreur lexicale , ligne %d , colonne %d : Entite <<%s>>\n", nb , col, yytext);
%%
int main () 
{  
  yyin = fopen("programme.txt","r");
   if (yyin==NULL) printf("ERROR \n");
      else 
	  {
	  initialisation();
	  yyparse();
	  afficher();
	  }
   return 0;}