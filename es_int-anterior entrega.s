* Inicializa el SP y el PC
**************************
        ORG     $0
        DC.L    $8000                       * Pila
        DC.L    INICIO                      * PC

        ORG     $400


*Buffers y punteros
*********************************
        TAMANO:  EQU     2001               *2000 + 1 auxiliar

    *Espacio reservado para los buffers
        recep_A:    DS.B    TAMANO          *0x400 (posición de memoria en hexadecimal) recepcion de a 
        recep_B:    DS.B    TAMANO          *0xbd1 recepcion de b
        trans_A:    DS.B    TAMANO          *0x13a2 transimision de a 
        trans_B:    DS.B    TAMANO          *0x1b73 transimision de b

        IMR_CP: DS.B    2


        BUFFER: DS.B 15000                  *Buffer para lectura y escritura de caracteres
        PARDIR: DC.L 0                      *Direcci´on que se pasa como par´ametro
        PARTAM: DC.W 0                      *Tama~no que se pasa como par´ametro
        CONTC: DC.W 0                       *Contador de caracteres a imprimir
        DESA: EQU 0                         *Descriptor línea A
        DESB: EQU 1                         *Descriptor línea B
        TAMBS: EQU 3000                     *Tama~no de bloque para SCAN
        TAMBP: EQU 3000                     *Tama~no de bloque para PRINT

    *Buffer de recepcion A
        rae:     DS.B  4                    *Escritura
        ral:     DS.B  4                    *Lectura
        raf:     DS.B  4                    *Fin       

    *Buffer de recepcion B
        rbe:     DS.B  4                    *Escritura
        rbl:     DS.B  4                    *Lectura
        rbf:     DS.B  4                    *Fin       

    *Buffer de transmision A
        tae:     DS.B  4                    *Escritura
        tal:     DS.B  4                    *Lectura
        taf:     DS.B  4                    *Fin       

    *Buffer de transmision b
        tbe:     DS.B  4                    *Escritura
        tbl:     DS.B  4                    *Lectura
        tbf:     DS.B  4                    *Fin 


*Definicion de equivalencias
*********************************

MR1A    EQU     $effc01                     *De modo A (escritura)
MR2A    EQU     $effc01                     *De modo A (2 escritura)
SRA     EQU     $effc03                     *De estado A (lectura)
CSRA    EQU     $effc03                     *De seleccion de reloj A (escritura)
CRA     EQU     $effc05                     *De control A (escritura)
TBA     EQU     $effc07                     *Buffer transmision A (escritura)
RBA     EQU     $effc07                     *Buffer recepcion A  (lectura)

ACR   	EQU	    $effc09	                    *De control auxiliar
IMR     EQU     $effc0B                     *De mascara de interrupcion A (escritura)
ISR     EQU     $effc0B                     *De estado de interrupcion A (lectura)

MR1B    EQU     $effc11                     *De modo B (escritura)
MR2B    EQU     $effc11                     *De modo B (2 escritura)
CRB     EQU     $effc15	                    *De control B (escritura)
TBB     EQU     $effc17                     *Buffer transmision B (escritura)
RBB	    EQU	    $effc17                     *Buffer recepcion B (lectura)
SRB     EQU     $effc13                     *e estado B (lectura)
CSRB	EQU	    $effc13                     *De seleccion de reloj B (escritura)
IVR     EQU     $effc19                     *De vector de interrupcion


INIT:
    MOVE.B #%00010000,CRA                   *Reinicia el puntero MR1
    MOVE.B #%00000011,MR1A                  *8 bits por caracter.
    MOVE.B #%00000000,MR2A                  *Eco desactivado.
    MOVE.B #%11001100,CSRA                  *Velocidad = 38400 bps.
    MOVE.B #%00000000,ACR                   *Velocidad = 38400 bps.
    MOVE.B #%00000101,CRA                   *Transmision y recepcion activados.
    MOVE.B #%00010000,CRB                   *Reinicia el puntero MR1
    MOVE.B #%00000011,MR1B                  *8 bits por caracter.
    MOVE.B #%00000000,MR2B                  *Eco desactivado.
    MOVE.B #%11001100,CSRB                  *Velocidad = 38400 bps.
    MOVE.B #%00000101,CRB                   *Transmision y recepcion activados.

    MOVE.B #%01000000,IVR                   *Vector de Interrrupcion 40
    MOVE.B #%00100010,IMR                   *IMR
    MOVE.B #%00100010,IMR_CP                *IMR_CP

    MOVE.L #RTI,$100                        *RTI

    MOVEM.L A0/D0-D1,-(A7)                  *Salvamos los registros

    MOVE.L #TAMANO,D0 
    SUB.L  #1,D0
        
    MOVE.L #recep_A,rae
    MOVE.L #recep_A,ral
    MOVE.L #recep_A,A0  
    MOVE.L A0,D1                            *En D1 esta 0x400
    ADD.L D0,D1                             *Puntero al final               
    MOVE.L D1,raf

    MOVE.L #recep_B,rbe
    MOVE.L #recep_B,rbl
    MOVE.L #recep_B,A0
    MOVE.L A0,D1                            *En D1 está 0xbd1
    ADD.L D0,D1                             *puntero al final                         
    MOVE.L D1,rbf

    MOVE.L #trans_A,tae
    MOVE.L #trans_A,tal
    MOVE.L #trans_A,A0
    MOVE.L A0,D1                            *En d1 esta 0x13a2
    ADD.L D0,D1                             *puntero al final                   
    MOVE.L D1,taf

    MOVE.L #trans_B,tbe
    MOVE.L #trans_B,tbl
    MOVE.L #trans_B,A0
    MOVE.L A0,D1                            *En d1 esta 0x1b73
    ADD.L D0,D1                             *puntero al final           
    MOVE.L D1,tbf

    MOVEM.L (A7)+,A0/D0-D1                  *Rescatamos registros 
    RTS


*INIT-----------------------------------------------------------------------------------------


LEECAR:
    MOVEM.L A1-A4/D1-D2,-(A7)               *Salvamos los registros

    MOVE.L #0,A1                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,A2                            
    MOVE.L #0,A3                            
    MOVE.L #0,A4                            
    MOVE.L #0,D1
    MOVE.L #0,D2   

    MOVE.L #TAMANO,D1                       *TAMANO en D1
    BTST #0,D0                              *Consulta bit 0
    BEQ  LC_A                               *De ser 0, el buffer es el A, si no, continua con el B

    BTST #1,D0                              *Consulta el contenido del bit 1
    BEQ LC_RB                               *De ser 0 es de recepcion (recep_B), si no, continua con transmision (trans_B)

*Trans_B:
    MOVE.L tbe,A1                          *Escritura
    MOVE.L tbl,A2                          *Lectura
    MOVE.L tbf,A3                          *Fin
    MOVE.L #3,D2                           *3: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea B.
    BRA LC                                   

*Recep_B
LC_RB:
    MOVE.L rbe,A1                          *Escritura
    MOVE.L rbl,A2                          *Lectura
    MOVE.L rbf,A3                          *Fin
    MOVE.L #1,D2                           *1: indica que se desea acceder al buffer interno de recepci´on de la l´ınea B.
    BRA LC                                   

LC_A:
    BTST #1,D0                              *Consulta bit 1
    BEQ LC_RA                               *De ser 0 es de recepcion (recep_A), si no, continua con transmision (trans_A)

*Trans_A
    MOVE.L tae,A1                          *Escritura
    MOVE.L tal,A2                          *Lectura
    MOVE.L taf,A3                          *Fin
    MOVE.L #2,D2                           *2: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea A.
    BRA LC                                

*Recep_A
LC_RA:
    MOVE.L rae,A1                          *Escritura
    MOVE.L ral,A2                          *Lectura
    MOVE.L raf,A3                          *Fin
    MOVE.L #0,D2                           *0: indica que se desea acceder al buffer interno de recepci´on de la l´ınea A.

LC:
    CMP A1,A2                              *Compara escritura y lectura
    BEQ LC_VACIO                           *Si son iguales, el buffer esta vacio
    MOVE.L #0,D0                           *Inicializamos D0
    MOVE.B (A2),D0                         *Coloca el dato en D0
    MOVE.L A2,A4                           *Puntero auxiliar A4
    ADD.L #1,A4                            *A4 + 1
    CMP A3,A2                              *Compara si el puntero de lectura esta en el final del buffer
    BNE LC_0                               *Si no esta, actualizamos punteros
    SUB.L D1,A4                            *Si esta, lo ubicamos en el inicio

LC_0:
    CMP.L #0,D2                             *Recepcion de A
    BNE LC_1                               
    MOVE.L A4,ral                  	        *Actualizamos ral
    BRA LC_FIN

LC_1:
    CMP.L #1,D2                             *Recepcion de B
    BNE LC_2                               
    MOVE.L A4,rbl	                        *Actualizamos rbl
    BRA LC_FIN

LC_2:
    CMP.L #2,D2                             *Transmision de A
    BNE LC_3                               
    MOVE.L A4,tal                  	        *Actualizamos tal
    BRA LC_FIN

LC_3:
    MOVE.L A4,tbl	                        *Actualizamos tbl
    BRA LC_FIN

LC_VACIO:
    MOVE.L #0,D0                            *Inicializamos D0
    MOVE.L #$ffffffff,D0                    *Metemos un -1 en D0
LC_FIN:
    MOVEM.L (A7)+,A1-A4/D1-D2               *Rescatamos registros 
    RTS

*LEECAR-----------------------------------------------------------------------------------------


ESCCAR:
    MOVEM.L A1-A4/D1-D3,-(A7)               *Salvamos los registros 

    MOVE.L #0,A1                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,A2                            
    MOVE.L #0,A3                            
    MOVE.L #0,A4                               
    MOVE.L #0,D2  
    MOVE.L #0,D3  
    
    MOVE.L #TAMANO,D2                       *TAMANO en D2

    BTST #0,D0                              *Consulta bit 0
    BEQ  EC_A                               *De ser 0, el buffer es el A, si no, continua con el B
	
    BTST #1,D0                            *Consulta bit 1
    BEQ EC_RB                               *De ser 0 es de recepcion (recep_B), si no, continua con transmision (trans_B)                                          

*Transimision_B
    MOVE.L tbe,A1                          *Escritura
    MOVE.L tbl,A2                          *Lectura
    MOVE.L tbf,A3                          *Fin
    MOVE.L #3,D3                           *3: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea B.
    BRA EC                                 
                                            
*Recep_B
EC_RB:
    MOVE.L rbe,A1                          *Escritura
    MOVE.L rbl,A2                          *Lectura
    MOVE.L rbf,A3                          *Fin
    MOVE.L #1,D3                           *1: indica que se desea acceder al buffer interno de recepci´on de la l´ınea B.
    BRA EC                              

EC_A:
    BTST #1,D0                             *Consulta bit 1
    BEQ EC_RA                              *De ser 0 es de recepcion (recep_A), si no, continua con transmision (trans_A)
                                            
*Trans_A
    MOVE.L tae,A1                          *Escritura
    MOVE.L tal,A2                          *Lectura
    MOVE.L taf,A3                          *Fin
    MOVE.L #2,D3                           *2: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea A.
    BRA EC                               

*Recep_A
EC_RA:
    MOVE.L rae,A1                          *Escritura
    MOVE.L ral,A2                          *Lectura
    MOVE.L raf,A3                          *Fin
    MOVE.L #0,D3                           *0: indica que se desea acceder al buffer interno de recepci´on de la l´ınea A.

EC:
    MOVE.L A1,A4                            *Puntero auxiliar A4
    ADD.L #1,A4                             *A4 + 1 
    CMP.L A1,A3                             *Comprobamos is estamos en el fin
    BNE EC_0                               
    SUB.L D2,A4                             *Apunta al inicio

EC_0:
    CMP.L A4,A2                             *Escritura y Lectura iguales?
    BEQ EC_LLENO                            *Si z=1 salto a EC_LLENO  
    MOVE.B D1,(A1)                          *Introduzco el caracter 
    MOVE.L #0,D0                            *Reinstauro D0 a 0 

    CMP.L #0,D3                             *Recepcion de A
    BNE EC_1                               
    MOVE.L A4,rae                 	        *Actualizamos rae
    BRA EC_FIN

EC_1:
    CMP.L #1,D3                             *Recepcion de B
    BNE EC_2                               
    MOVE.L A4,rbe	                        *Actualizamos rbe
    BRA EC_FIN

EC_2:
    CMP.L #2,D3                             *Transmision de A
    BNE EC_3                               
    MOVE.L A4,tae                           *Actualizamos tae
    BRA EC_FIN

EC_3:
    MOVE.L A4,tbe	                        *Actualizamos tbe
    BRA EC_FIN   
    
EC_LLENO:
	MOVE.L #0,D0                            *Inicializamos D0
    MOVE.L #$ffffffff,D0                    *Metemos un -1 en D0    
                   
EC_FIN:                                    
    MOVEM.L (A7)+,A1-A4/D1-D3               *Rescatamos registros 
	RTS

*ESCCAR-----------------------------------------------------------------------------------------


SCAN:    	
    LINK A6,#-16                            *Creamos el marco de pila para guardar los registros
	MOVE.L A1,-4(A6)                        *Salvamos los registros 
	MOVE.L D1,-8(A6)        
	MOVE.L D2,-12(A6)            

    MOVE.L #0,-16(A6)                       *Contador
    MOVE.L #0,D0                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,D1                           
    MOVE.L #0,D2                                                     
    MOVE.L #0,A1                           

	MOVE.L 8(A6),A1                         *Buffer
	MOVE.W 12(A6),D1                        *Descriptor
	MOVE.W 14(A6),D2                        *Tamaño
			
    CMP.W #0,D2			                    *Comprobamos si el tamaño es 0, si es así termina la subrutina 
	BEQ SC_FIN1
	CMP.W #0,D1                             *Comprobamos el descriptor
	BEQ SC_COPY                             *Si el descriptor es 0 saltamos a SC_A
	CMP.W #1,D1
	BEQ SC_COPY                             *Si descriptor es 1 saltamos a SC_B.
	MOVE.L #$ffffffff,D0                    *En caso de no cumplirse ninguna de las anteriores devolvemos error
	JMP SC_FIN            

SC_COPY:       
    MOVE.W 12(A6),D0                        *Ponemos en D0 el descriptor
	BSR LEECAR		                        *Lee el dato y lo devuelve en D0	 
	CMP.L #$ffffffff,D0			            *Comprueba si D0 tiene codigo error, si tiene error entonces salto a SC_FIN
	BEQ SC_FIN1			
			
	ADD.L #1,-16(A6)                        *Incrementamos el contador
	MOVE.B D0,(A1)+                         *Copiamos el dato leido en el buffer y aumentamos su direccion
	CMP.L -16(A6),D2                        *Comprobamos si el contador es igual al tamaño
	BNE SC_COPY	                            *Si no son iguales, volvemos a SC_COPY
    
SC_FIN1:
    MOVE.L -16(A6),D0
    
SC_FIN:	    
    MOVE.L -4(A6),A1                        *Rescatamos registros 
	MOVE.L -8(A6),D1        
	MOVE.L -12(A6),D2                  
	UNLK A6                                 *Destruimos marco de pila.
	RTS                                     *Retorno.                             
*SCAN-----------------------------------------------------------------------------------------


PRINT:    	
    LINK A6,#-20                            *Creamos el marco de pila para guardar los registros
	MOVE.L A1,-4(A6)                        *Salvamos los registros 
	MOVE.L D1,-8(A6)        
	MOVE.L D2,-12(A6)            
	MOVE.L D3,-16(A6)

    MOVE.L #0,A1                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,D1                            
    MOVE.L #0,D2                            
    MOVE.L #0,D3                            
    MOVE.L #0,-20(A6)                       *Contador                     

    MOVE.L 8(A6),A1                         *Buffer 
    MOVE.W 12(A6),D1                        *Descriptor 
    MOVE.W 14(A6),D2                        *Tamaño

    CMP.W #0,D2		                        *Si el tamaño es 0 se termina la subrutina 
	BEQ PR_FIN1
    CMP.W #0,D1                             *Si 0:
    BEQ PR_A                                *Buffer de Trasmision de A
    CMP.W #1,D1                             *Si 1:
    BEQ PR_B                                *Buffer de Trasmision de B
	MOVE.L #$ffffffff,D0                    *De no ser ninguno, se introduce -1 (Error) y se sale de la subrutina
    JMP PR_FIN

PR_A:
    MOVE.L #2,D3                            *Se mete un 2 en D3 para acceder al buffer de Trasmision de A
    JMP PR_BUC
PR_B:
    MOVE.L #3,D3                            *Se mete un 3 en D3 para acceder al buffer de Trasmision de B   
    
PR_BUC:  
    MOVE.B (A1)+,D1					        *Extraemos el dato y avanzamos el puntero del buffer
    MOVE.L D3,D0                            *Copiamos D3 en D0 para pasarlo como parametro a ESCCAR
    BSR ESCCAR
    CMP #$ffffffff,D0                       *Comprobamos si hubo error en ESCCAR (si hay nos salimos)
    BEQ PR_INT
    ADD.L #1,-20(A6)                        *Incrementamos el contador
    MOVE.W 14(A6),D2
    CMP.L -20(A6),D2                        *Contador y tamaño iguales termina la subrutina
    BNE PR_BUC

PR_INT:
    CMP.L #0,-20(A6)                        *Si 0
    BEQ PR_FIN1                             *Saltamos al final sin habilitar interrupciones
    MOVE.L #0,D1                            *Limpiamos D1

    MOVE.W #$2700,SR                        *Inhibimos las interrupciones

    CMP #2,D3                               *Si 2:
    BEQ PR_IMRA                             *Buffer de Transmisión de A
    BSET #4,IMR_CP                          *Como estamos en el buffer de transmisión B activamos el bit 4
    JMP PR_IMR

PR_IMRA:
    BSET #0,IMR_CP                          *Como estamos en el buffer de transmisión A activamos el bit 0 

PR_IMR:
    MOVE.B IMR_CP,IMR                       *Compiamos IMR_CP a IMR
    MOVE.W #$2000,SR                        *Activamos de nuevo las interrupciones

PR_FIN1:
    MOVE.L -20(A6),D0                       *Movemos el contador a D0
    
PR_FIN:
    MOVE.L -4(A6),A1                        *Rescatamos registros 
	MOVE.L -8(A6),D1        
	MOVE.L -12(A6),D2
    MOVE.L -16(A6),D3
    UNLK A6                                 *Destruimos el marco de pila
    RTS                    
*PRINT-----------------------------------------------------------------------------------------


RTI:        
    LINK A6,#-12      	                    *Creamos el marco de pila para guardar los registros
	MOVE.L D1,-4(A6)     	                *Salvamos los registros
	MOVE.L D2,-8(A6)
    MOVE.L D0,-12(A6)

    MOVE.L #0,D0                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,D1                            
    MOVE.L #0,D2                                                                                   

	MOVE.B ISR,D1         	                *ISR en D1
	MOVE.B IMR_CP,D2                        *IMR_CP en D2
	AND.B D2,D1         	                *Vemos que periferico interrumpe
	BTST #1,D1                              *Si bit 1 RxRDYA/FFULLA = 1:
	BNE RTI_RA         	                    *Recepcion linea A
	BTST #5,D1                              *Si bit 5 RxRDYB/FFULLB = 1:
	BNE RTI_RB       	                    *Recepcion linea B
	BTST #0,D1                              *Si bit 0 TxRDYA = 1:
	BNE RTI_TA         	                    *Transmision linea A
	BTST #4,D1                              *Si bit 4 TxRDYB = 1:
	BNE RTI_TB          	                *Transmision linea B
    JMP RTI_FIN

RTI_TA:     
    MOVE.L #2,D0 		   			        *Descriptor a 2
	BSR LEECAR		    	    	        *LLamamos a LEECAR
	CMP.L #$ffffffff,D0 			        *Si D0 es -1:
	BEQ RTI_TAI				                *Desactivamos las interrupciones de la linea de transmisión A
	MOVE.B D0,TBA           		        *El caracter leido lo movemos a TBA
    JMP RTI_FIN                     

RTI_TAI:	
    BCLR #0,IMR_CP         	                *Desactivamos el bit 0 de IMR_CP
    MOVE.B IMR_CP,IMR                       *Compiamos IMR_CP a IMR
    JMP RTI_FIN               				

RTI_RA: 
    MOVE.L #0,D1                            *Limpiamos D1
    MOVE.B RBA,D1             		        *RBA en D1			
	MOVE.L #0,D0 		                    *Buffer A de recepcion en ESCCAR
	BSR ESCCAR		  	                    *Llamamos a ESCCAR		 
    JMP RTI_FIN              		

RTI_TB:      
    MOVE.L #3,D0 		   			        *Descriptor a 3
	BSR LEECAR		    	    	        *LLamamos a LEECAR
	CMP.L #$ffffffff,D0 			        *Si D0 es -1:
	BEQ RTI_TBI                             *Desactivamos las interrupciones de la linea de transmisión B
	MOVE.B D0,TBB           		        *El caracter leido lo movemos a TBB
    JMP RTI_FIN 
			
RTI_TBI:   
    BCLR #4,IMR_CP         	                *Desactivamos el bit 4 de IMR_CP
    MOVE.B IMR_CP,IMR             		    *Compiamos IMR_CP a IMR
    JMP RTI_FIN               		

RTI_RB:
    MOVE.L #0,D1                            *Limpiamos D1
    MOVE.B RBB,D1             		        *RBB en D1
	MOVE.L #1,D0 		                    *Buffer B de recepcion en ESCCAR
	BSR ESCCAR		  	                    *Llamamos a ESCCAR
    JMP RTI_FIN              		

RTI_FIN: 	
    MOVE.L -4(A6),D1     		            *Rescatamos registros
	MOVE.L -8(A6),D2
    MOVE.L -12(A6),D0
	UNLK A6             	                *Destruimos el marco de pila
	RTE                     	    		
*RTI-------------------------------------------------------------------------------------------


INICIO: 	
            MOVE.L  #BUS_ERROR,8 		* Bus error handler
			MOVE.L  #ADDRESS_ER,12 		* Address error handler
			MOVE.L  #ILLEGAL_IN,16 		* Illegal instruction handler
			MOVE.L  #PRIV_VIOLT,32 		* Privilege violation handler
			MOVE.L  #ILLEGAL_IN,40 		* Illegal instruction handler
			MOVE.L  #ILLEGAL_IN,44 		* Illegal instruction handler
			
			BSR INIT
			MOVE.W #$2000,SR 			* Permite interrupciones
		
BUCPR:  	
            MOVE.W #TAMBS,PARTAM 		* Inicializa parametro de tama�o
			MOVE.L #BUFFER,PARDIR 		* Parametro BUFFER = comienzo del buffer
OTRAL:  	
            MOVE.W PARTAM,-(A7) 		* Tama�o de bloque
			MOVE.W #DESA,-(A7) 			* Puerto A
			MOVE.L PARDIR,-(A7) 		* Direccion de lectura
ESPL:  		
            BSR SCAN
			ADD.L #8,A7 				* Restablece la pila
			ADD.L D0,PARDIR 			* Calcula la nueva direccion de lectura
			SUB.W D0,PARTAM 			* Actualiza el numero de caracteres leidos
			BNE OTRAL 					* Si no se han leido todas los caracteres del bloque se vuelve a leer
			MOVE.W #TAMBS,CONTC 		* Inicializa contador de caracteres a imprimir
			MOVE.L #BUFFER,PARDIR 		* Parametro BUFFER = comienzo del buffer
OTRAE:  	
            MOVE.W #TAMBP,PARTAM 		* Tama�o de escritura = Tama�o de bloque
ESPE:   	
            MOVE.W PARTAM,-(A7) 		* Tama�o de escritura
			MOVE.W #DESB,-(A7) 			* Puerto B
			MOVE.L PARDIR,-(A7) 		* Direccion de escritura
			BSR PRINT
			ADD.L #8,A7					* Restablece la pila
			ADD.L D0,PARDIR 			* Calcula la nueva direccion del buffer
			SUB.W D0,CONTC 				* Actualiza el contador de caracteres
			BEQ SALIR 					* Si no quedan caracteres se acaba
			SUB.W D0,PARTAM 			* Actualiza el tamano de escritura
			BNE ESPE 					* Si no se ha escrito todo el bloque se insiste
			CMP.W #TAMBP,CONTC 			* Si el no de caracteres que quedan es menor que el tama~no establecido se imprime ese n�umero
			BHI OTRAE 					* Siguiente bloque
			MOVE.W CONTC,PARTAM
			BRA ESPE 					* Siguiente bloque
SALIR:  	
            BREAK
BUS_ERROR:  
            BREAK 						* Bus error handler
			NOP
ADDRESS_ER: 
            BREAK 						* Address error handler
			NOP
ILLEGAL_IN: 
            BREAK 						* Illegal instruction handler
			NOP
PRIV_VIOLT: 
            BREAK 						* Privilege violation handler
			NOP


