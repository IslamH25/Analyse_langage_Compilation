%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 int nb=1;
 int col=1;
 char sauvType[25];
 char sauvOPERATEUR[8];
 char sauvIDF1[10];
 char sauvIDF2[10];
 float sauvVAL1;
 float sauvVAL2;
 int cpt=0;
 int cptIDF=0;
 int choix;
 float resultat;
 char* tabIDF[50][10];
 int k=0;
%}
%union
{
   char caractere;
   char* chaine;
   float reel;
   int entier;
}

%token Mc_ID Mc_PID Mc_DDiv Mc_WSS Mc_ProcDiv Mc_StR Mc_Line Mc_Size <chaine>Mc_Int <chaine>Mc_Float <chaine>Mc_Char <chaine>Mc_String Mc_Const Mc_Acc Mc_Dis Mc_If Mc_Else Mc_End Mc_Move Mc_To Mc_Not
%token <chaine>Idf <entier>Int <reel>Float <caractere>Char <chaine>String Barre Aff Add Sub Div Mul OpL <chaine>OpC Po Pf Chev <caractere>SigneFormatage Arb DeuxPoint Point Pvg Virg


%start S 
%left OpL     
%right Mc_Not    
%left Add Sub
%left Div Mul


%%
S:  Mc_ID Mc_PID Idf Point Mc_DDiv Mc_WSS DEC Mc_ProcDiv INST Mc_StR { insererTYPE($3,"Nom_Prog");
                                                                        printf("\n Syntaxe correcte \n"); YYACCEPT;}
;
   
DEC: DEC_VAR DEC
     | DEC_TAB DEC
	 | DEC_CONST DEC
	 |
;

DEC_VAR: LIST_IDF 
;

DEC_TAB: Idf Mc_Line Int Virg Mc_Size Int TYPE { if($3<0) {printf("\n ! Erreur semantique: Borne du tableau negative ligne %d , colonne %d \n" , nb,col); YYERROR;}
                                                 else {if($3>=$6) printf("\n ! Erreur semantique: Bornes du tableau incorrectes ligne %d ,colonne %d\n",nb,col);
                                                      else {if(doubleDeclaration($1)==0)   
													           insererTYPE($1,sauvType);
                                                            else  
													           {printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col); YYERROR;}}}
                                               }
;

DEC_CONST: Mc_Const Idf TYPE {if(doubleDeclaration($2)==0)   
								insererTYPE($2,sauvType);
                              else  
								{printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
								 YYERROR;}
                             }							 
          |Mc_Const Idf Aff Int {strcpy(sauvType,"int");
		                               if(doubleDeclaration($2)==0){   
								            insererTYPE($2,sauvType);
											float val=$4; 
											   insererVAL($2,&val);
											  }
                                          else  
								            { printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
											  YYERROR;}
                                         }										 
		  |Mc_Const Idf Aff Float {{strcpy(sauvType,"float"); 
		                                 if(doubleDeclaration($2)==0){   
								            insererTYPE($2,sauvType);
											float* val=(float*) malloc(sizeof(float));
											*val=$4; 
											insererVAL($2, val);
											  }
                                          else  
								            { printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
											  YYERROR;}
                                         }}								 
		  |Mc_Const Idf Aff VALEUR {if(doubleDeclaration($2)==0)   
								            insererTYPE($2,sauvType);
                                          else  
								             {printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
											  YYERROR;}
                                         }						 
;

VALEUR: Char   {strcpy(sauvType,"char");}
	   |String   {strcpy(sauvType,"chaine");}
;     

TYPE: Mc_Int      {strcpy(sauvType,"int");}
     | Mc_Float   {strcpy(sauvType,"float");}
	 | Mc_Char    {strcpy(sauvType,"char");}
	 | Mc_String  {strcpy(sauvType,"string");}
;

LIST_IDF: Idf TYPE  {if(doubleDeclaration($1)== 0)     
						insererTYPE($1,sauvType);
                     else  
                       { printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
						 YYERROR;}
                    }
         | Idf Barre LIST_IDF {if(doubleDeclaration($1)==0)   
                                   insererTYPE($1,sauvType);
                                else  
                                  {printf("\n ! Erreur semantique: Double declaration  de l'entite << %s >> ligne %d ,colonne %d\n",$1,nb,col);
								   YYERROR;}
                                        }
;
              
INST: ARITH Point INST
     | AFFECTATION Point INST
	 | DIS INST
	 | ACC INST
	 | BOUCLE INST
	 | CONDITION INST
	 |
;

ARITH: EXPRESSION
      | EXPRESSION_PAR
;

EXPRESSION: OPERANDE OPERATEUR OPERANDE { if(choix == 1)
                                            { if(cptIDF == 1){
											     if((sauvVAL1 == 0) && (strcmp(sauvOPERATEUR,"/") == 0)){
                                                    printf("\n ! Erreur semantique: Division par '0' ligne %d ,colonne %d\n",nb,col);
								                    YYERROR;}
												 else
												    {if(strcmp(sauvOPERATEUR,"+") == 0)
													    { float* val= (float*)donneVAL(sauvIDF1);
														  resultat = (*val)+(sauvVAL1);
														  cpt =0; cptIDF=0;}
													 
													 else if(strcmp(sauvOPERATEUR,"-") == 0)
													         { float* val= (float*)donneVAL(sauvIDF1);
														       resultat = (*val)-(sauvVAL1);
														      cpt =0; cptIDF=0; }
													      
														  else if(strcmp(sauvOPERATEUR,"*") == 0)
													              { float* val= (float*)donneVAL(sauvIDF1);
														            resultat = (*val)*(sauvVAL1);
														            cpt =0; cptIDF=0;}
																	 
																else if(strcmp(sauvOPERATEUR,"/") == 0)
													                    { float* val= (float*)donneVAL(sauvIDF1);
														                  resultat = (*val)/(sauvVAL1);
														                  cpt =0; cptIDF=0;}
											        }
											  }
											  else 
											     if((sauvVAL2 == 0) && (strcmp(sauvOPERATEUR,"/") == 0)){
												    printf("\n ! Erreur semantique: Division par '0' ligne %d ,colonne %d\n",nb,col);
								                    YYERROR;}
												 else
												    {if(strcmp(sauvOPERATEUR,"+") == 0)
													    { resultat = (sauvVAL1)+(sauvVAL2);
														  cpt =0; cptIDF=0;} 
													 
													 else if(strcmp(sauvOPERATEUR,"-") == 0)
													         { resultat = (sauvVAL1)-(sauvVAL2);
															   cpt =0; cptIDF=0;} 
															
														  else if(strcmp(sauvOPERATEUR,"*") == 0)
													              { resultat = (sauvVAL1)*(sauvVAL2);
															        cpt =0; cptIDF=0;} 
																
																if(strcmp(sauvOPERATEUR,"/") == 0)
													               { resultat = (sauvVAL1)/(sauvVAL2);
															         cpt =0; cptIDF=0;} 
                                                     }
											}
                                          else if(choix == 0)
										    { if(cpt == 1){											
                                                       float* val= (float*)donneVAL(sauvIDF1);
												       if((*val == 0) && (strcmp(sauvOPERATEUR,"/") == 0)){   															 
													      printf("\n ! Erreur semantique: Division par '0' ligne %d ,colonne %d\n",nb,col);
								                          YYERROR;}
													   else 
													      {if(strcmp(sauvOPERATEUR,"+") == 0)
													          { float* val= (float*)donneVAL(sauvIDF1);
														        resultat = (sauvVAL1)+(*val);
														        cpt =0; cptIDF=0; }
													 
													       else if(strcmp(sauvOPERATEUR,"-") == 0)
													               { float* val= (float*)donneVAL(sauvIDF1);
														             resultat = (sauvVAL1)-(*val);
														             cpt =0; cptIDF=0; }
													      
														        else if(strcmp(sauvOPERATEUR,"*") == 0)
													                    { float* val= (float*)donneVAL(sauvIDF1);
														                  resultat = (sauvVAL1)*(*val);
														                  cpt =0; cptIDF=0;}
																	 
																      else if(strcmp(sauvOPERATEUR,"/") == 0)
													                       { float* val= (float*)donneVAL(sauvIDF1);
														                     resultat = (sauvVAL1)/(*val);
														                     cpt =0; cptIDF=0; }
											              } 
											  }
											  else {
													 float* val= (float*)donneVAL(sauvIDF2);
												     if((*val == 0) && (strcmp(sauvOPERATEUR,"/") == 0)){   															 
													      printf("\n ! Erreur semantique: Division par '0' ligne %d ,colonne %d\n",nb,col);
								                          YYERROR;}
													   else 
													      {if(strcmp(sauvOPERATEUR,"+") == 0)
													          { float* val1= (float*)donneVAL(sauvIDF1);
															    float* val2= (float*)donneVAL(sauvIDF2);
														        resultat = (*val1)+(*val2);
														        cpt =0; cptIDF=0; }
													 
													       else if(strcmp(sauvOPERATEUR,"-") == 0)
													               { float* val1= (float*)donneVAL(sauvIDF1);
																     float* val2= (float*)donneVAL(sauvIDF2);
														             resultat = (*val1)-(*val2);
														             cpt =0; cptIDF=0; }
													      
														        else if(strcmp(sauvOPERATEUR,"*") == 0)
													                    { float* val1= (float*)donneVAL(sauvIDF1);
																		  float* val2= (float*)donneVAL(sauvIDF2);
														                  resultat = (*val1)*(*val2);
														                  cpt =0; cptIDF=0; }
																	 
																     else if(strcmp(sauvOPERATEUR,"/") == 0)
													                       { float* val1= (float*)donneVAL(sauvIDF1);
																		     float* val2= (float*)donneVAL(sauvIDF2);
														                     resultat = (*val1)/(*val2);
														                     cpt =0; cptIDF=0; }
											              }
												   }
										    }
										}
           | OPERANDE OPERATEUR EXPRESSION    
		   | OPERANDE OPERATEUR EXPRESSION_PAR    
;  

EXPRESSION_PAR: Po EXPRESSION Pf
			  | Po EXPRESSION_PAR Pf
              | Po EXPRESSION Pf OPERATEUR EXPRESSION 
			  | Po EXPRESSION Pf OPERATEUR OPERANDE  
			  |	Po EXPRESSION_PAR Pf OPERATEUR EXPRESSION_PAR 
              | Po EXPRESSION_PAR Pf OPERATEUR OPERANDE
			  | Po EXPRESSION_PAR Pf OPERATEUR EXPRESSION	  
;
		
OPERANDE: Idf      { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
                     choix =0 ; if (cptIDF == 0)
                         	      {strcpy(sauvIDF1,$1);
								   cptIDF = 1;} 
                               else 
							      {strcpy(sauvIDF2,$1);
                                   cptIDF = 2;}								  
				   }
         | Int     {choix =1 ; if (cpt == 0)
                         	      {sauvVAL1 = $1;
								   cpt = 1;} 
                               else 
							      {sauvVAL2 = $1;
                                   cpt = 2;}								  
				   }
		 | Float   {choix =1 ; if (cpt == 0)
                         	      {sauvVAL1 = $1;
								   cpt = 1;} 
                               else 
							      {sauvVAL2 = $1;
                                   cpt = 2;}								  
				   }
;

OPERATEUR: Add     {strcpy(sauvOPERATEUR,"+");}
          | Div    {strcpy(sauvOPERATEUR,"/");}
		  | Sub    {strcpy(sauvOPERATEUR,"-");}
		  | Mul    {strcpy(sauvOPERATEUR,"*");}
;

AFFECTATION: Idf Aff Float   { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
                               strcpy(sauvType,"float");  
                               if(strcmp((char*)donneTYPE($1), sauvType)!=0) 
							     { printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								  YYERROR;}
							   else 
							     { float val=$3; 
							      insererVAL($1,&val);}
							 }
							 
            | Idf Aff Int    { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
			                  strcpy(sauvType,"int");  
                               if(strcmp((char*)donneTYPE($1), sauvType)!=0) 
							     { printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								  YYERROR;}
							   else 
							     { float val=$3; 
							      insererVAL($1,&val);}
							 }	
							 
			| Idf Aff String { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
			                   strcpy(sauvType,"string");  
                               if(strcmp((char*)donneTYPE($1), sauvType)!=0) 
							     { printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								  YYERROR;}
							 }
							 
			| Idf Aff Char   { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
			                   strcpy(sauvType,"char");  
                               if(strcmp((char*)donneTYPE($1), sauvType)!=0) 
							     { printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								  YYERROR;}
							 }
							 
			| Idf Aff Idf    { if((strcmp((char*)donneTYPE($1)," ")==0)|| (strcmp((char*)donneTYPE($3)," ")==0)){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
			                   if(strcmp((char*)donneTYPE($1),(char*)donneTYPE($3))!=0)
                                  {printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								  YYERROR;}
                               else 
							      { if((strcmp((char*)donneTYPE($3),"int")==0)|| (strcmp((char*)donneTYPE($3),"float")==0))
									    insererVAL($1,donneVAL($3)); }
							 }
							 
			| Idf Aff ARITH  { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
			                   if((resultat - (int)resultat)== 0)
			                      {if(strcmp((char*)donneTYPE($1),"int") == 0)
								     insererVAL($1, &resultat);
								   else {printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								         YYERROR;}
								  }
								  
								else {if(strcmp((char*)donneTYPE($1),"float") == 0)
								         insererVAL($1, &resultat);
								   else {printf("\n ! Erreur semantique: incompatibilite de types ligne %d , colonne %d\n" , nb,col);
								         YYERROR;}
								  }
							 }
; 

BOUCLE: Mc_Move Idf Mc_To Idf INST Mc_End { if((strcmp((char*)donneTYPE($2)," ")==0) ||(strcmp((char*)donneTYPE($4)," ")==0)) { printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
                                            if ((strcmp((char*)donneTYPE($2),"int") != 0) && (strcmp((char*)donneTYPE($4),"int") !=0))
                                               {printf("\n ! Erreur semantique: type des bornes de l'intervalle de la boucle incorrect ligne %d , colonne %d\n" , nb,col);
								                YYERROR;}
											
											else 
											   {
											      float* val1= (float*)donneVAL($2);
											      float* val2= (float*)donneVAL($4);
												  if(*val1 > *val2)
												     {printf("\n ! Erreur semantique: intervalle de la boucle incorrect ligne %d , colonne %d\n" , nb,col);
								                       YYERROR;}
											   }

                                            }
       |Mc_Move Int Mc_To Idf INST Mc_End { if(strcmp((char*)donneTYPE($4)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
	                                        float* val= (float*)donneVAL($4);
	                                        if((strcmp((char*)donneTYPE($4),"int")!=0) || ($2>*val))
	                                           {printf("\n ! Erreur semantique: intervalle de la boucle incorrect ligne %d , colonne %d\n" , nb,col);
								               YYERROR;}
										  }
	   |Mc_Move Idf Mc_To Int INST Mc_End { if(strcmp((char*)donneTYPE($2)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
	                                        float* val= (float*)donneVAL($2);
	                                        if((strcmp((char*)donneTYPE($2),"int")!=0) || (*val>$4))
	                                           {printf("\n ! Erreur semantique: intervalle de la boucle incorrect ligne %d , colonne %d\n" , nb,col);
								                YYERROR;}
	                                       }
	   |Mc_Move Int Mc_To Int INST Mc_End { if($2>$4)
	                                          {printf("\n ! Erreur semantique: intervalle de la boucle incorrect ligne %d , colonne %d\n" , nb,col);
								               YYERROR;}
	                                       }
;    

CONDITION: Mc_If Po COND Pf DeuxPoint INST Mc_End
         | Mc_If Po COND Pf DeuxPoint INST Mc_Else DeuxPoint INST Mc_End
;

COND: COND1
     | COND1 OpL COND1
	 | Mc_Not COND1
;

COND1: ARITH OpC ARITH     
     | OPERANDE OpC OPERANDE  { if(choix == 1){           
                                   if (cptIDF == 1){            
								      if((strcmp((char*)donneTYPE(sauvIDF1),"char")==0) || strcmp((char*)donneTYPE(sauvIDF1),"string")==0)
									     {printf("\n ! Erreur semantique: on ne peut pas faire la comparaison de caractere ou de chaine ligne %d , colonne %d\n" , nb,col);
								          YYERROR;}
								      else {
									     if(strcmp($2,".L.")==0){
										    float* val= (float*)donneVAL(sauvIDF1);
											if(*val >= sauvVAL1)
											   {printf("\n ! Erreur semantique: operande 1 est >= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                YYERROR;}
											cpt=0; cptIDF=0;
										  }
										  else if(strcmp($2,".G.")==0){
										           float* val= (float*)donneVAL(sauvIDF1);
											       if(*val <= sauvVAL1)
											          {printf("\n ! Erreur semantique: operande 1 est <= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                       YYERROR;}
                                                   cpt=0; cptIDF=0;													   
											    }
												else if(strcmp($2,".DI.")==0){
										                float* val= (float*)donneVAL(sauvIDF1);
											            if(*val == sauvVAL1)
											               {printf("\n ! Erreur semantique: operande 1 est = a operande 2 ligne %d , colonne %d\n" , nb,col);
								                            YYERROR;} 
													    cpt=0; cptIDF=0;
											         }
													 else if(strcmp($2,".EQ.")==0){
										                     float* val= (float*)donneVAL(sauvIDF1);
											                 if(*val != sauvVAL1)
											                    {printf("\n ! Erreur semantique: operande 1 est different de operande 2 ligne %d , colonne %d\n" , nb,col);
								                                 YYERROR;}
                                                             cpt=0; cptIDF=0;																 
											              }
														  else if(strcmp($2,".LE.")==0){
										                          float* val= (float*)donneVAL(sauvIDF1);
											                      if(*val > sauvVAL1)
											                         {printf("\n ! Erreur semantique: operande 1 est > operande 2 ligne %d , colonne %d\n" , nb,col);
								                                      YYERROR;} 
																  cpt=0; cptIDF=0;
											                    }
                                                                else if(strcmp($2,".GE.")==0){
										                                float* val= (float*)donneVAL(sauvIDF1);
											                            if(*val < sauvVAL1)
											                               {printf("\n ! Erreur semantique: operande 1 est < operande 2 ligne %d , colonne %d\n" , nb,col);
								                                            YYERROR;}
                                                                        cpt=0; cptIDF=0;																			
											                          } 																
										}
										}
										else {
										   if(strcmp($2,".L.")==0){
											  if(sauvVAL1 >= sauvVAL2)
											     {printf("\n ! Erreur semantique: operande 1 est >= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                  YYERROR;}
										    }
											else if(strcmp($2,".G.")==0){
											        if(sauvVAL1 <= sauvVAL2)
											           {printf("\n ! Erreur semantique: operande 1 est <= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                        YYERROR;} 
													cpt=0; cptIDF=0;
											      }
												  else if(strcmp($2,".DI.")==0){
											              if(sauvVAL1 == sauvVAL2)
											                 {printf("\n ! Erreur semantique: operande 1 est = a operande 2 ligne %d , colonne %d\n" , nb,col);
								                              YYERROR;} 
														  cpt=0; cptIDF=0;
											            }
														else if(strcmp($2,".EQ.")==0){
											                    if(sauvVAL1 != sauvVAL2)
											                       {printf("\n ! Erreur semantique: operande 1 est different de operande 2 ligne %d , colonne %d\n" , nb,col);
								                                    YYERROR;} 
																cpt=0; cptIDF=0;
											                  }
															  else if(strcmp($2,".LE.")==0){
											                          if(sauvVAL1 > sauvVAL2)
											                             {printf("\n ! Erreur semantique: operande 1 est > operande 2 ligne %d , colonne %d\n" , nb,col);
								                                          YYERROR;}
                                                                      cpt=0; cptIDF=0;																		  
											                        }
																	else if(strcmp($2,".GE.")==0){
											                                if(sauvVAL1 < sauvVAL2)
											                                   {printf("\n ! Erreur semantique: operande 1 est < operande 2 ligne %d , colonne %d\n" , nb,col);
								                                                YYERROR;} 
																			cpt=0; cptIDF=0;
											                              } 
										}
								   
									 }
									 else if(choix == 0){
									         if(cpt == 1){
											    if((strcmp((char*)donneTYPE(sauvIDF1),"char")==0) || (strcmp((char*)donneTYPE(sauvIDF1),"string")==0))
									               {printf("\n ! Erreur semantique: on ne peut pas faire la comparaison de caractere ou de chaine ligne %d , colonne %d\n" , nb,col);
								                    YYERROR;}
								                else {
									               if(strcmp($2,".L.")==0){
										              float* val= (float*)donneVAL(sauvIDF1);
											          if(sauvVAL1 >= *val)
											             {printf("\n ! Erreur semantique: operande 1 est >= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                          YYERROR;}
													  cpt=0; cptIDF=0;
										            }
										            else if(strcmp($2,".G.")==0){
										                    float* val= (float*)donneVAL(sauvIDF1);
											                if(sauvVAL1 <= *val)
											                   {printf("\n ! Erreur semantique: operande 1 est <= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                                YYERROR;}
                                                            cpt=0; cptIDF=0;																
											             }
												         else if(strcmp($2,".DI.")==0){
										                         float* val= (float*)donneVAL(sauvIDF1);
											                     if(sauvVAL1 == *val)
											                        {printf("\n ! Erreur semantique: operande 1 est = a operande 2 ligne %d , colonne %d\n" , nb,col);
								                                     YYERROR;} 
																  cpt=0; cptIDF=0;
											                   }
													           else if(strcmp($2,".EQ.")==0){
										                               float* val= (float*)donneVAL(sauvIDF1);
											                           if(sauvVAL1 != *val)
											                              {printf("\n ! Erreur semantique: operande 1 est different de operande 2 ligne %d , colonne %d\n" , nb,col);
								                                           YYERROR;} 
																		cpt=0; cptIDF=0;
											                        }
														            else if(strcmp($2,".LE.")==0){
										                                    float* val= (float*)donneVAL(sauvIDF1);
											                                if(sauvVAL1 > *val)
											                                   {printf("\n ! Erreur semantique: operande 1 est > operande 2 ligne %d , colonne %d\n" , nb,col);
								                                                YYERROR;} 
																		    cpt=0; cptIDF=0;
											                              }
                                                                          else if(strcmp($2,".GE.")==0){
										                                          float* val= (float*)donneVAL(sauvIDF1);
											                                      if(sauvVAL1 < *val)
											                                         {printf("\n ! Erreur semantique: operande 1 est < operande 2 ligne %d , colonne %d\n" , nb,col);
								                                                      YYERROR;} 
																				  cpt=0; cptIDF=0;
											                                    } 																
										        }
											 }
											 else{
											    if((strcmp((char*)donneTYPE(sauvIDF1),"char")==0) || (strcmp((char*)donneTYPE(sauvIDF1),"string")==0) || (strcmp((char*)donneTYPE(sauvIDF2),"char")==0) || (strcmp((char*)donneTYPE(sauvIDF1),"string")==0))
									               {printf("\n ! Erreur semantique: on ne peut pas faire la comparaison de caractere ou de chaine ligne %d , colonne %d\n" , nb,col);
								                    YYERROR;}
								                else {
									               if(strcmp($2,".L.")==0){
										              float* val1= (float*)donneVAL(sauvIDF1);
													  float* val2= (float*)donneVAL(sauvIDF2);
											          if(*val1 >= *val2)
											             {printf("\n ! Erreur semantique: operande 1 est >= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                          YYERROR;}
													  cpt=0; cptIDF=0;
										            }
										            else if(strcmp($2,".G.")==0){
										                    float* val1= (float*)donneVAL(sauvIDF1);
															float* val2= (float*)donneVAL(sauvIDF2);
											                if(*val1 <= *val2)
											                   {printf("\n ! Erreur semantique: operande 1 est <= a operande 2 ligne %d , colonne %d\n" , nb,col);
								                                YYERROR;} 
															cpt=0; cptIDF=0;
											             }
												         else if(strcmp($2,".DI.")==0){
										                         float* val1= (float*)donneVAL(sauvIDF1);
																 float* val2= (float*)donneVAL(sauvIDF2);
											                     if(*val1 == *val2)
											                        {printf("\n ! Erreur semantique: operande 1 est = a operande 2 ligne %d , colonne %d\n" , nb,col);
								                                     YYERROR;}
                                                                 cpt=0; cptIDF=0;																	 
											                   }
													           else if(strcmp($2,".EQ.")==0){
										                               float* val1= (float*)donneVAL(sauvIDF1);
																	   float* val2= (float*)donneVAL(sauvIDF2);
											                           if(*val1 != *val2)
											                              {printf("\n ! Erreur semantique: operande 1 est different de operande 2 ligne %d , colonne %d\n" , nb,col);
								                                           YYERROR;}
                                                                        cpt=0; cptIDF=0;																		   
											                        }
														            else if(strcmp($2,".LE.")==0){
										                                    float* val1= (float*)donneVAL(sauvIDF1);
																			float* val2= (float*)donneVAL(sauvIDF2);
											                                if(*val1 > *val2)
											                                   {printf("\n ! Erreur semantique: operande 1 est > operande 2 ligne %d , colonne %d\n" , nb,col);
								                                                YYERROR;} 
																			cpt=0; cptIDF=0;
											                              }
                                                                          else if(strcmp($2,".GE.")==0){
										                                          float* val1= (float*)donneVAL(sauvIDF1);
																				  float* val2= (float*)donneVAL(sauvIDF2);
											                                      if(*val1 < *val2)
											                                         {printf("\n ! Erreur semantique: operande 1 est < operande 2 ligne %d , colonne %d\n" , nb,col);
								                                                      YYERROR;}
                                                                                   cpt=0; cptIDF=0;																					  
											                                    } 																
										        }
                                                }											 
											}
                               }									 
     | OPERANDE OpC ARITH    
     | ARITH OpC OPERANDE   
	 | AFFECTATION    
;

IDFDIS: Idf { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
              strcpy((char*)tabIDF[cptIDF],$1); cptIDF++; }
       |Idf Barre IDFDIS { if(strcmp((char*)donneTYPE($1)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
                     	   strcpy((char*)tabIDF[cptIDF],$1); cptIDF++;}

DIS: Mc_Dis Po String DeuxPoint IDFDIS Pf Point {char* s= strdup($3);
                                                 char c;
											     int i;
												 int p=0;
											     int cptDIS=0;
												 for(i=0; (i<strlen(s)-1); i++)
												 {
												  c=s[i];
												  if ((c=='$') || (c=='&') || (c=='#') || (c=='%'))
                                                       cptDIS++;
                                                 }
												  if(cptDIS != cptIDF)
                                                    {printf("\n ! Erreur semantique: nombre d'IDF different du nombre designe de formatage , ligne %d , colonne %d\n" , nb,col);
								                     YYERROR;}

                                                  else { char tabSF[cptDIS-1];
												         int j=0;
												         for(i=0; (i<strlen(s)-1); i++)
												         {
												            c=s[i];
												            if ((c=='$') || (c=='&') || (c=='#') || (c=='%'))
                                                               {tabSF[j]=c;
															   j++;}
														 }
														 while(cptIDF>=0)
                                                         {  
														    switch(tabSF[p])
                                                            {
													            case '$': if (strcmp((char*)donneTYPE((char*)tabIDF[cptIDF-1]),"int")!=0)
            											                     {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                                               YYERROR;}
								                                 break ;
																 
																 case '%': if (strcmp((char*)donneTYPE((char*)tabIDF[cptIDF-1]),"float")!=0)
            											                     {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                                               YYERROR;}
								                                 break ;
																 
																 case '&': if (strcmp((char*)donneTYPE((char*)tabIDF[cptIDF-1]),"char")!=0)
            											                     {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                                               YYERROR;}
								                                 break ;
																 
																 case '#': if (strcmp((char*)donneTYPE((char*)tabIDF[cptIDF-1]),"string")!=0)
            											                     {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                                               YYERROR;}
								                                 break ;

																 default : break;
												            }
															cptIDF--;
															p++;
                                                          }      														  
                                                       }
												        
                                                }										  
                                                
;

ACC: Mc_Acc Po String DeuxPoint Arb Idf Pf Point { if(strcmp((char*)donneTYPE($6)," ")==0){ printf("\n ! Erreur semantique: idf non declare\n"); YYERROR;}
                                                  char* s= strdup($3);
                                                  char c = s[1];
                                                  switch(c)
                                                  {
													case '$': if (strcmp((char*)donneTYPE($6),"int")!=0)
            											      {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                              YYERROR;}
								                    break ;
														
									                case '%': if (strcmp((char*)donneTYPE($6),"float")!=0)
            								                  {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                              YYERROR;}
												    break ;
														
									                case '&': if (strcmp((char*)donneTYPE($6),"char")!=0)
            			        					          {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                               YYERROR;}
												    break;
														
													case '#': if (strcmp((char*)donneTYPE($6),"string")!=0)
            											       {printf("\n ! Erreur semantique: signe de formatage ne correspond pas au type de l'IDF ligne %d , colonne %d\n" , nb,col);
								                               YYERROR;}
													 break ;
													 
													 case ' ': 
													          {printf("\n ! Erreur semantique: pas de signe de formatage ligne %d , colonne %d\n" , nb,col);
								                               YYERROR;}
													 break ;
													
													 
													 default : break;
												  }
												 }
; 
%%
yywrap()
{}
int yyerror(char *msg)
{
 printf("erreur syntaxique a la ligne %d, colonne %d\n" , nb,col);
 return 1;
}