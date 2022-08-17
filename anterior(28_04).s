* Inicializa el SP y el PC
**************************
        ORG     $0
        DC.L    $8000           * Pila
        DC.L    INICIO          * PC

        ORG     $400

* Buffers y punteros
*********************************
        TAMANO:  EQU     2001          *1 más para poder tener una poscion auxiliar

    * Espacio reservado para los buffers
        recep_A:    DS.B    TAMANO     *0x400 (posición de memoria en hexadecimal) recepcion de a 
        recep_B:    DS.B    TAMANO     *0xbd1 recepcion de b
        trans_A:    DS.B    TAMANO     *0x13a2 transimision de a 
        trans_B:    DS.B    TAMANO     *0x1b73 transimision de b

    * Buffer de recepcion A
        rae:     DS.B  4 * escritura
        ral:     DS.B  4 * lectura
        raf:     DS.B  4 * fin       

    * Buffer de recepcion B
        rbe:     DS.B  4 * escritura
        rbl:     DS.B  4 * lectura
        rbf:     DS.B  4 * fin       

    * Buffer de transmision A
        tae:     DS.B  4 * escritura
        tal:     DS.B  4 * lectura
        taf:     DS.B  4 * fin       

    * Buffer de transmision b
        tbe:     DS.B  4 * escritura
        tbl:     DS.B  4 * lectura
        tbf:     DS.B  4 * fin 


* Definici�n de equivalencias
*********************************

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2� escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR   	EQU	    $effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2� escritura)
CRB     EQU     $effc15	      * de control B (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB	    EQU	    $effc17       * buffer recepcion B (lectura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB	EQU	    $effc13       * de seleccion de reloj B (escritura)
IVR     EQU     $effc19       * de vector de interrupcion



INIT:
        MOVE.B #%00010000,CRA      * Reinicia el puntero MR1
        MOVE.B #%00000011,MR1A     * 8 bits por caracter.
        MOVE.B #%00000000,MR2A     * Eco desactivado.
        MOVE.B #%11001100,CSRA     * Velocidad = 38400 bps.
        MOVE.B #%00000000,ACR      * Velocidad = 38400 bps.
        MOVE.B #%00000101,CRA      * Transmision y recepcion activados.
        MOVE.B #%00010000,CRB      * Reinicia el puntero MR1
        MOVE.B #%00000011,MR1B     * 8 bits por caracter.
        MOVE.B #%00000000,MR2B     * Eco desactivado.
        MOVE.B #%11001100,CSRB     * Velocidad = 38400 bps.
        MOVE.B #%00000101,CRB      * Transmision y recepcion activados.

        MOVE.B #%01000000,IVR      * Vector de Interrrupcion 40
        MOVE.B #%00100010,IMR      *IMR

        MOVE.L #TAMANO,D0 
        SUB.L  #1,D0
        
        MOVE.L #recep_A,rae
        MOVE.L #recep_A,ral
        MOVE.L #recep_A,A0  
        MOVE.L A0,D1                     *en D1 esta 0x400
        ADD.L D0,D1                      *puntero al final               
        MOVE.L D1,raf

        MOVE.L #recep_B,rbe
        MOVE.L #recep_B,rbl
        MOVE.L #recep_B,A0
        MOVE.L A0,D1                      *en D1 está 0xbd1
        ADD.L D0,D1                       *puntero al final                         
        MOVE.L D1,rbf

        MOVE.L #trans_A,tae
        MOVE.L #trans_A,tal
        MOVE.L #trans_A,A0
        MOVE.L A0,D1                      *En d1 esta 0x13a2
        ADD.L D0,D1                       *puntero al final                   
        MOVE.L D1,taf

        MOVE.L #trans_B,tbe
        MOVE.L #trans_B,tbl
        MOVE.L #trans_B,A0
        MOVE.L A0,D1                      *En d1 esta 0x1b73
        ADD.L D0,D1                       *puntero al final           
        MOVE.L D1,tbf

        RTS


*INIT-----------------------------------------------------------------------------------------


LEECAR:
    MOVEM.L A1-A4/D2-D3,-(A7)              *Salvamos los registros

    MOVE.L #TAMANO,D2                      *TAMANO en D2
    BTST #0,D0                             *Consulta bit 0
    BEQ  LC_A                              *De ser 0, el buffer es el A, si no, continua con el B

    BTST #1,D0                             *Consulta el contenido del bit 1
    BEQ LC_RB                              *De ser 0 es de recepcion (recep_B), si no, continua con transmision (trans_B)

 *trans_B:
     MOVE.L tbe,A1                         *escritura
     MOVE.L tbl,A2                         *lectura
     MOVE.L tbf,A3                         *fin
     MOVE.L #3,D3                          *3: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea B.
     BRA LC                                   

 *recep_B
LC_RB:
     MOVE.L rbe,A1                         *escritura
     MOVE.L rbl,A2                         *lectura
     MOVE.L rbf,A3                         *fin
     MOVE.L #1,D3                          *1: indica que se desea acceder al buffer interno de recepci´on de la l´ınea B.
     BRA LC                                   

LC_A:
    BTST #1,D0                             *Consulta bit 1
    BEQ LC_RA                              *De ser 0 es de recepcion (recep_A), si no, continua con transmision (trans_A)

 *trans_A
     MOVE.L tae,A1                         *escritura
     MOVE.L tal,A2                         *lectura
     MOVE.L taf,A3                         *fin
     MOVE.L #2,D3                          *2: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea A.
     BRA LC                                

 *recep_B
LC_RA:
     MOVE.L rae,A1                         *escritura
     MOVE.L ral,A2                         *lectura
     MOVE.L raf,A3                         *fin
     MOVE.L #0,D3                          *0: indica que se desea acceder al buffer interno de recepci´on de la l´ınea A.

LC:
     CMP A1,A2                             *compara escritura y lectura
     BEQ LC_VACIO                          *Si son iguales, el buffer esta vacio
     MOVE.L #0,D0                          *Inicializamos D0
     MOVE.B (A2),D0                        *Coloca el dato en D0
     MOVE.L A2,A4                          *Puntero auxiliar A4
     ADD.L #1,A4                           *A4 + 1
     CMP A3,A2                             *compara si el puntero de lectura esta en el final del buffer
     BNE LC_0                              *Si no esta, actualizamos punteros
     SUB.L D2,A4                           *Si esta, lo ubicamos en el inicio

LC_0:
    CMP.L #0,D3                            *Recepcion de A
    BNE LC_1                               
    MOVE.L A4,ral                 	       *actualizamos ral
    BRA LC_FIN

LC_1:
    CMP.L #1,D3                            *Recepcion de B
    BNE LC_2                               
    MOVE.L A4,rbl	                       *actualizamos rbl
    BRA LC_FIN

LC_2:
    CMP.L #2,D3                            *Transmision de A
    BNE LC_3                               
    MOVE.L A4,tal                  	       *actualizamos tal
    BRA LC_FIN

LC_3:
    MOVE.L A4,tbl	                       *actualizamos tbl
    BRA LC_FIN

LC_VACIO:
    MOVE.L #0,D0                           *Inicializamos D0
    MOVE.L #$ffffffff,D0                   *Metemos un -1 en D0
LC_FIN:
    MOVEM.L (A7)+,A1-A4/D2-D3              *Rescatamos registros 
    RTS

*LEECAR-----------------------------------------------------------------------------------------


ESCCAR:
    MOVEM.L A1-A4/D1-D3,-(A7)              *Salvamos los registros 
    MOVE.L #TAMANO,D2                      *TAMANO en D2

    BTST #0,D0                             *Consulta bit 0
    BEQ  EC_A                              *De ser 0, el buffer es el A, si no, continua con el B
	
    BTST   #1,D0                           *Consulta bit 1
    BEQ EC_RB                              *De ser 0 es de recepcion (recep_B), si no, continua con transmision (trans_B)                                          

 *transimision_B
     MOVE.L tbe,A1                         *escritura
     MOVE.L tbl,A2                         *lectura
     MOVE.L tbf,A3                         *fin
     MOVE.L #3,D3                          *3: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea B.
     BRA EC                                 
                                            
 *recep_B
EC_RB:
     MOVE.L rbe,A1                         *escritura
     MOVE.L rbl,A2                         *lectura
     MOVE.L rbf,A3                         *fin
     MOVE.L #1,D3                          *1: indica que se desea acceder al buffer interno de recepci´on de la l´ınea B.
     BRA EC                              

EC_A:
    BTST   #1,D0                           *Consulta bit 1
    BEQ EC_RA                              *De ser 0 es de recepcion (recep_A), si no, continua con transmision (trans_A)
                                            
 *trans_A
     MOVE.L tae,A1                         *escritura
     MOVE.L tal,A2                        *lectura
     MOVE.L taf,A3                         *fin
     MOVE.L #2,D3                          *2: indica que se desea acceder al buffer interno de transmisi´on de la l´ınea A.
     BRA EC                               

 *recep_A
EC_RA:
     MOVE.L rae,A1                         *escritura
     MOVE.L ral,A2                         *lectura
     MOVE.L raf,A3                         *fin
     MOVE.L #0,D3                          *0: indica que se desea acceder al buffer interno de recepci´on de la l´ınea A.

EC:
    MOVE.L A1,A4                           *Puntero auxiliar A4
    ADD.L #1,A4                            *A4 + 1 
    CMP.L A1,A3                            *Comprobamos is estamos en el fin
    BNE EC_0                               
    SUB.L D2,A4                            *Apunta al inicio

EC_0:
    CMP.L A4,A2                            *Escritura y Lectura iguales?
    BEQ EC_LLENO                           *Si z=1 salto a EC_LLENO  
    MOVE.B D1,(A1)                         *Introduzco el caracter 
    MOVE.L #0,D0                           *Reinstauro D0 a 0 

    CMP.L #0,D3                            *Recepcion de A
    BNE EC_1                               
    MOVE.L A4,rae                 	       *actualizamos rae
    BRA EC_FIN

EC_1:
    CMP.L #1,D3                            *Recepcion de B
    BNE EC_2                               
    MOVE.L A4,rbe	                       *actualizamos rbe
    BRA EC_FIN

EC_2:
    CMP.L #2,D3                            *Transmision de A
    BNE EC_3                               
    MOVE.L A4,tae                          *actualizamos tae
    BRA EC_FIN

EC_3:
    MOVE.L A4,tbe	                       *actualizamos tbe
    BRA EC_FIN   
    
EC_LLENO:
	MOVE.L #0,D0                           *Inicializamos D0
    MOVE.L #$ffffffff,D0                   *Metemos un -1 en D0                   
EC_FIN:                                    
    MOVEM.L (A7)+,A1-A4/D1-D3              *Rescatamos registros 
	RTS

*ESCCAR-----------------------------------------------------------------------------------------


SCAN:    	
    LINK A6,#-20                           * creamos el marco de pila para guardar los registros
	MOVE.L A1,-4(A6)                       * salvamos los registros 
	MOVE.L D1,-8(A6)        
	MOVE.L D2,-12(A6)            
	MOVE.L D3,-16(A6)
    MOVE.L D4,-20(A6)  

	MOVE.L 8(A6),A1                        * buffer
	MOVE.W 12(A6),D1                       * descriptor
	MOVE.W 14(A6),D2                       * tamaño
    MOVE.L #0,D3                           * contador
    MOVE.L #$ffffffff,D4
			
    CMP.W #0,D2			                   * comprobamos si el tamaño es 0, si es así termina la subrutina 
	BEQ SC_FIN
	CMP.W #0,D1                            * comprobamos el descriptor
	BEQ SC_A                               * si el descriptor es 0 saltamos a SCAN_A
	CMP.W #1,D1
	BEQ SC_B                               * si descriptor es 1 saltamos a SCAN_B.
	MOVE.L #$ffffffff,D0                   * en caso de no cumplirse ninguna de las anteriores devolvemos error
	JMP SC_FIN            

SC_A:       
    MOVE.L #0,D0 		                   * buffer A de recepcion
	BSR LEECAR		                       * lee el dato y lo devuelve en D0	 
	CMP.L D0,D4 			               * comprueba si D0 tiene codigo error, si tiene error entonces salto a SC_FIN
	BEQ SC_FIN			
			
	ADD.L #1,D3                            * incrementamos el contador
	MOVE.B D0,(A1)+                        * copiamos el dato leido en el buffer y aumentamos su direccion
	CMP.L D3,D2                            * comprobamos si el contador es igual al tamaño
	BNE SC_A	                           * si no son iguales, volvemos a SC_A
	JMP SC_FIN			                   * saltamos a SC_FIN
							
SC_B:       
    MOVE.L #1,D0 		                   * buffer B de recepcion
	BSR LEECAR		               	       * lee el dato y lo devuelve en D0 
	CMP.L D0,D4 			               * comprueba si D0 tiene codigo error, si tiene error entonces salto a SC_FIN
	BEQ  SC_FIN
			
	ADD.L #1,D3                            * incrementamos contador.
	MOVE.B D0,(A1)+                        * copiamos el dato leido en el buffer y aumentamos su direccion.
	CMP.L D3,D2                            * comprobamos si el contador es igual al tamaño
	BNE SC_B	                           * si no son iguales, volvemos a SC_A 

SC_FIN:
    MOVE.L D3,D0	    
    MOVE.L -4(A6),A1                       * Rescatamos registros 
	MOVE.L -8(A6),D1        
	MOVE.L -12(A6),D2
    MOVE.L -16(A6),D3             
	MOVE.L -20(A6),D4       
	UNLK     A6                            * destruimos marco de pila.
	RTS                                    * retorno.                             
*SCAN-----------------------------------------------------------------------------------------


PRINT:    	
    RTS                             
*PRINT-----------------------------------------------------------------------------------------


INICIO:
    BSR INIT
    BREAK
*INICIO-----------------------------------------------------------------------------------------






