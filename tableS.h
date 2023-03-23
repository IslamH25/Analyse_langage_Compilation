/****************CREATION DE LA TABLE DES SYMBOLES ******************/
/***Step 1: Definition des structures de données ***/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct element
{
   char name[30];
   char code[30];
   char type[30];
   float val;
   struct element *suiv;
 }ELEMENT;

ELEMENT* L1=NULL, *P=NULL, *Q=NULL ;

typedef struct elt
{ 
   char name[30];
   char type[30];
   struct elt *suiv;
}ELT;

ELT* Lm=NULL, *Ls=NULL, *P1=NULL, *Q1=NULL;

/***Step 2: initialisation***/

void initialisation()
{
	L1=NULL ; Lm=NULL ; Ls=NULL ;
}


/***Step 3: insertion des entitités lexicales dans les tables des symboles ***/

void inserer (char entite[], char code[], char type[], float val, int y)
{
switch (y)
{
	case 0: /*insertion dans la table des IDFs et CONST*/
		if(L1==NULL)
		{
			L1=malloc(sizeof(ELEMENT)) ;
			strcpy(L1->name, entite);
			strcpy(L1->type, type);
			strcpy(L1->code, code);
			L1->val=val;
			L1->suiv = NULL ;
		}
		else
		{
			P=malloc(sizeof(ELEMENT)) ;
			strcpy(P->name, entite);
			strcpy(P->type, type);
			strcpy(P->code, code);
			P->val=val;
			P->suiv = NULL ;

			//parcourir + chainage
			Q=L1;
			while(Q->suiv != NULL)
				Q = Q->suiv ;

			Q->suiv = P ;
		}
	break;
	
	case 1: /*insertion dans la table des mots clés*/
		if(Lm==NULL)
		{
			Lm=malloc(sizeof(ELT)) ;
			strcpy(Lm->name, entite);
			strcpy(Lm->type, type);
			Lm->suiv = NULL ;
		}
		else
		{
			P1=malloc(sizeof(ELT)) ;
			strcpy(P1->name, entite);
			strcpy(P1->type, type);
			P1->suiv = NULL ;

			//parcourir + chainage
			Q1=Lm ;
			while(Q1->suiv != NULL)
				Q1 = Q1->suiv ;

			Q1->suiv = P1 ;
		}
	break;
	
	case 2: /*insertion dans la table des séparateurs*/
		if(Ls==NULL)
		{
			Ls=malloc(sizeof(ELT)) ;
			strcpy(Ls->name, entite);
			strcpy(Ls->type, type);
			Ls->suiv = NULL ;
		}
		else
		{
			P1=malloc(sizeof(ELT)) ;
			strcpy(P1->name, entite);
			strcpy(P1->type, type);
			P1->suiv = NULL ;

			//parcourir + chainage
			Q1=Ls ;
			while(Q1->suiv != NULL)
				Q1 = Q1->suiv ;

			Q1->suiv = P1 ;
		}
	break;
	default : break ;
}
}


/***Step 4: La fonction Rechercher permet de verifier  si l'entité existe dèja dans la table des symboles */

void rechercher (char entite[], char code[], char type[], float val, int y)
{
	switch(y)
	{
		case 0:// inserer dans la table des IDFs et des constantes si l'entite n'existe pas !!
			P=L1 ;
			while( (P != NULL) && (strcmp(P->name,entite)!=0) )
				P = P->suiv ;

			if(P==NULL)
				inserer(entite, code, type, val, 0) ;
			else
				printf("Entite %s existe deja !\n" , entite) ;
		break;

		case 1:// inserer dans la table des mot clés !
			P1=Lm ;
			while((P1 != NULL) && (strcmp(P1->name,entite)!=0) )
				P1 = P1->suiv ;
			if(P1==NULL)
				inserer(entite, code, type, val, 1) ;
			else
				printf("Entite %s existe deja ! \n" , entite) ;
		break; 

		case 2:// inserer dans la table des separateurs !
			P1=Ls ;
			while((P1 != NULL) && (strcmp(P1->name,entite)!=0) )
				P1 = P1->suiv ;
			if(P1==NULL)
				inserer(entite, code, type, val, 2) ;		
			else
				printf("Entite %s existe deja ! \n" , entite) ;
		break ;
		default : break ;
	}
}

/***Step 5 L'affichage du contenue de la table des symboles ***/

void afficher()
{
	printf("/***************  Table de symboles des IDFs et CONST*************/\n");
	printf("_____________________________________________________________________________\n");
	printf("\t| Nom_Entite 	   |  Code_Entite  |  Type_Entite   | Val_Entite     |\n");
	printf("_____________________________________________________________________________\n");
	
	P=L1 ;
	while(P!=NULL)
	{
		if(P->val < 32767 && P->val > - 32768) 
			printf("\t|%14s    |%10s     | %10s     | %8.3f \t\n",P->name,P->code,P->type, P->val);
		else {if(strcmp(P->type,"string")==0)
		       { strcpy(P->name,"CHAINE");
                 printf("\t|%14s    |%10s     | %10s     |  \t\n",P->name,P->code,P->type);
	           }			 
		      else printf("\t|%14s    |%10s     | %10s     |  \t\n",P->name,P->code,P->type);}
		P = P->suiv; 
	}


	printf("\n\n\n\n/*************** Table de symboles des mots cles *************/\n");
	printf("_____________________________________________________\n");
	printf("\t| 	 Nom_Entite        |   CodeEntite   | \n");
	printf("_____________________________________________________\n");
	
	P1=Lm ;
	while(P1 != NULL)
	{
		printf("\t|%25s |%12s    | \n",P1->name, P1->type);
		P1 = P1->suiv ;
	}

	
	printf("\n\n\n\n/*************** Table de symboles des separateurs *************/\n");
	printf("___________________________________\n");
	printf("\t| NomEntite |  CodeEntite | \n");
	printf("___________________________________\n");

	P1 = Ls ;
	while(P1 != NULL)
	{
		printf("\t|%8s   |%8s     | \n",P1->name, P1->type);
		P1 = P1->suiv ;
	}
	
}

int doubleDeclaration(char entite[])    
{                                        

    P=L1;
    while(strcmp(P->name,entite)!=0)
        P=P->suiv;
    if (strcmp(P->type," ")==0)
        return 0 ;
    else 
	    return 1 ;

}
	
void insererTYPE(char entite[], char type[])
{ 
	P=L1;
	while( strcmp(P->name,entite)!=0)
		P=P->suiv;
	strcpy(P->type,type);
}

void insererVAL(char entite[], float *val)
{
	P=L1;
	while( strcmp(P->name,entite)!=0)
		P=P->suiv;
	P->val=*val;	
}
	
char *donneTYPE(char entite[])
{
	P=L1;
	while( strcmp(P->name,entite)!=0)
		P=P->suiv;	
	return P->type;	
}

float *donneVAL(char entite[])
{
	P=L1;
	while( strcmp(P->name,entite)!=0)
		P=P->suiv;	
	return (&P->val);
}