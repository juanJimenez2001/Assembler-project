*******************
* PROYECTO DE E/S *
*******************

		
        ORG     $0

        DC.L    $8000 
		        
        DC.L    INICIO
		

***************************
* Definicion de Registros *
***************************

        ORG     $400

MR1A    EQU     $effc01       
MR2A    EQU     $effc01      
SRA     EQU     $effc03       
CSRA    EQU     $effc03      
CRA     EQU     $effc05       
TBA     EQU     $effc07       
RBA     EQU     $effc07       
MR1B    EQU     $effc11       
MR2B    EQU     $effc11      
SRB     EQU     $effc13       
CSRB    EQU     $effc13       
CRB     EQU     $effc15      
TBB     EQU     $effc17      
RBB     EQU     $effc17      
ACR		EQU		$effc09	      
IMR     EQU     $effc0B       
ISR     EQU     $effc0B       
IVR     EQU    	$effc19	      

BUFFER: 	DS.B 2100 					
PARDIR: 	DC.L 0 						
PARTAM: 	DC.W 0 						
CONTC:  	DC.W 0 						
DESA:   	EQU 0 						
DESB:   	EQU 1 						
TAMBS:  	EQU 2 						
TAMBP:  	EQU 2							

*************
* Variables *
*************
COPIA_IMR: DS.B    2
A_BUF_SCAN:    DS.B  2001    
A_INI_SCAN:    DC.L  0      
A_ESC_SCAN:    DC.L  0       
A_LEC_SCAN:    DC.L  0       
A_FIN_SCAN:    DC.L  0      

B_BUF_SCAN:    DS.B  2001    
B_INI_SCAN:    DC.L  0       
B_ESC_SCAN:    DC.L  0       
B_LEC_SCAN:    DC.L  0       
B_FIN_SCAN:    DC.L  0       

A_BUF_PRINT:    DS.B  2001    
A_INI_PRINT:    DC.L  0       
A_ESC_PRINT:    DC.L  0       
A_LEC_PRINT:    DC.L  0       
A_FIN_PRINT:    DC.L  0      

B_BUF_PRINT:    DS.B  2001    
B_INI_PRINT:    DC.L  0       
B_ESC_PRINT:    DC.L  0       
B_LEC_PRINT:    DC.L  0       
B_FIN_PRINT:    DC.L  0       

********
* INIT *
********

INIT	MOVE.B          #%00010000,CRA      
		MOVE.B          #%00010000,CRB      
        MOVE.B          #%00000011,MR1A     
        MOVE.B          #%00000011,MR1B     
        MOVE.B          #%00000000,MR2A     
		MOVE.B          #%00000000,MR2B     
        MOVE.B          #%00000000,ACR     
        MOVE.B          #%11001100,CSRA    
        MOVE.B          #%11001100,CSRB     
        MOVE.B          #%00000101,CRA     
        MOVE.B          #%00000101,CRB      
		MOVE.B			#%01000000,IVR	    
		MOVE.B			#%00100010,IMR	   
		MOVE.B			#%00100010,COPIA_IMR 
		MOVE.L 			#RTI,$100          	

        MOVE.L #0,A0                	    
        MOVE.L #A_BUF_SCAN,A_INI_SCAN       
        MOVE.L #A_BUF_SCAN,A_LEC_SCAN       
        MOVE.L #A_BUF_SCAN,A_ESC_SCAN      
        MOVE.L #A_BUF_SCAN,A0         	    
        ADDA.L #2000,A0             	   
        MOVE.L A0,A_FIN_SCAN           	    

        MOVE.L #0,A0                	    
        MOVE.L #B_BUF_SCAN,B_INI_SCAN      
        MOVE.L #B_BUF_SCAN,B_LEC_SCAN       
        MOVE.L #B_BUF_SCAN,B_ESC_SCAN       
        MOVE.L #B_BUF_SCAN,A0         	    
        ADDA.L #2000,A0             	    
        MOVE.L A0,B_FIN_SCAN           	    
 
        MOVE.L #0,A0                	    
        MOVE.L #A_BUF_PRINT,A_INI_PRINT     
        MOVE.L #A_BUF_PRINT,A_LEC_PRINT     
        MOVE.L #A_BUF_PRINT,A_ESC_PRINT     
        MOVE.L #A_BUF_PRINT,A0         	    
        ADDA.L #2000,A0             	    
        MOVE.L A0,A_FIN_PRINT            	

        MOVE.L #0,A0                    	
        MOVE.L #B_BUF_PRINT,B_INI_PRINT     
        MOVE.L #B_BUF_PRINT,B_LEC_PRINT     
        MOVE.L #B_BUF_PRINT,B_ESC_PRINT     
        MOVE.L #B_BUF_PRINT,A0         	    
        ADDA.L #2000,A0             	    
        MOVE.L A0,B_FIN_PRINT           	

        ANDI.W #$2000,SR             	    
		MOVE.L #0,A0                    	
        RTS                         	    
		
		
**********
* LEECAR *
**********


LEECAR		LINK     A6,#-8           
			MOVE.L   A1,-4(A6)        
			MOVE.L   A2,-8(A6)       
			CMP.B    #0,D0            
			BEQ      LEEC_RA          
			CMP.B    #1,D0            
			BEQ      LEEC_RB          
			CMP.B    #2,D0           
			BEQ      LEEC_TA          
			CMP.B    #3,D0           
			BEQ      LEEC_TB          
			MOVE.L   #$ffffffff,D0    
			
FIN_LEEC	MOVE.L   -4(A6),A1        
			MOVE.L   -8(A6),A2        
			UNLK     A6               
			RTS                       

*-------------------------------------------------------------------------------------*

LEEC_RA		MOVE.L   A_LEC_SCAN,A1    
			MOVE.L   A_ESC_SCAN,A2    
			
			CMP.L A1,A2               
			BEQ VLEEC_RA	     	  
			
LLEEC_RA	MOVE.B (A1),D0            
			CMP.L A_FIN_SCAN,A1       
			BEQ ILEEC_RA             
			ADD.L #1,A1               
			
FLEEC_RA 	MOVE.L A1,A_LEC_SCAN      
			JMP FIN_LEEC              
			
VLEEC_RA	MOVE.L   #$ffffffff,D0	  
			JMP FIN_LEEC              

ILEEC_RA	MOVE.L A_INI_SCAN,A1      
			JMP FLEEC_RA 
			
*-------------------------------------------------------------------------------------*

LEEC_RB		MOVE.L   B_LEC_SCAN,A1    
			MOVE.L   B_ESC_SCAN,A2    
			
			CMP.L A1,A2               
			BEQ VLEEC_RB              
			
LLEEC_RB    MOVE.B (A1),D0           
			CMP.L B_FIN_SCAN,A1       
			BEQ ILEEC_RB              
			ADD.L #1,A1               
			
FLEEC_RB	MOVE.L A1,B_LEC_SCAN      
			JMP FIN_LEEC              
			
VLEEC_RB	MOVE.L   #$ffffffff,D0	 
			JMP FIN_LEEC              

ILEEC_RB	MOVE.L B_INI_SCAN,A1      
			JMP FLEEC_RB 
			
*-------------------------------------------------------------------------------------*

LEEC_TA		MOVE.L   A_LEC_PRINT,A1   
			MOVE.L   A_ESC_PRINT,A2   
			
			CMP.L A1,A2               
			BEQ VLEEC_TA         	  
			
LLEEC_TA 	MOVE.B (A1),D0            
			CMP.L A_FIN_PRINT,A1      
			BEQ ILEEC_TA              
			ADD.L #1,A1               
			
FLEEC_TA    MOVE.L A1,A_LEC_PRINT     
			JMP FIN_LEEC           	  
			
VLEEC_TA	MOVE.L   #$ffffffff,D0	  
			JMP FIN_LEEC              

ILEEC_TA	MOVE.L A_INI_PRINT,A1     
			JMP FLEEC_TA 

*-------------------------------------------------------------------------------------*

LEEC_TB	    MOVE.L   B_LEC_PRINT,A1   
			MOVE.L   B_ESC_PRINT,A2   
			
			CMP.L A1,A2              
			BEQ VLEEC_TB              
			
LLEEC_TB	MOVE.B (A1),D0            
			CMP.L B_FIN_PRINT,A1      
			BEQ ILEEC_TB           	  
			ADD.L #1,A1               
			
FLEEC_TB	MOVE.L A1,B_LEC_PRINT     
			JMP FIN_LEEC              
			
VLEEC_TB	MOVE.L   #$ffffffff,D0	  
			JMP FIN_LEEC              

ILEEC_TB	MOVE.L B_INI_PRINT,A1     
			JMP FLEEC_TB 	
	
**********
* ESCCAR *
**********

ESCCAR		LINK     A6,#-12          
			MOVE.L   A1,-4(A6)        
			MOVE.L   A2,-8(A6)        
			MOVE.L   D1,-12(A6)
			CMP.B    #0,D0            
			BEQ      ESCC_RA          
			CMP.B    #1,D0            
			BEQ      ESCC_RB         
			CMP.B    #2,D0            
			BEQ      ESCC_TA         
			CMP.B    #3,D0           
			BEQ      ESCC_TB          
			MOVE.L   #$ffffffff,D0    
FIN_ESCC	MOVE.L   -4(A6),A1        
			MOVE.L   -8(A6),A2        
			MOVE.L   -12(A6),D1
			UNLK     A6               
			RTS                       
		
*-------------------------------------------------------------------------------------*

ESCC_RA		MOVE.L   A_LEC_SCAN,A1    
			MOVE.L   A_ESC_SCAN,A2    
			
			MOVE.B D1,(A2)            
			CMP.L A_FIN_SCAN,A2       
			BEQ IESCC_RA           	 
			ADD.L #1,A2              
			CMP.L A1,A2              
			BEQ LLESC_RA	          
			
FESCC_RA	MOVE.L   #0,D0			  
			MOVE.L A2,A_ESC_SCAN      
			JMP FIN_ESCC   
			 
LLESC_RA	SUB.L #1,A2    			  
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,A_ESC_SCAN      
			JMP FIN_ESCC		
			
IESCC_RA	MOVE.L A_INI_SCAN,A2     
			CMP.L A1,A2              
			BEQ VESCC_RA           	  
			JMP FESCC_RA		
			
VESCC_RA    MOVE.L A_FIN_SCAN,A2      
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,A_ESC_SCAN      
			JMP FIN_ESCC
		 
*-------------------------------------------------------------------------------------*

ESCC_RB		MOVE.L   B_LEC_SCAN,A1    
			MOVE.L   B_ESC_SCAN,A2    
			
			MOVE.B D1,(A2)            
			CMP.L B_FIN_SCAN,A2       
			BEQ IESCC_RB              
			ADD.L #1,A2               
			CMP.L A1,A2               
			BEQ LLESC_RB	          
			
FESCC_RB	MOVE.L   #0,D0			  
			MOVE.L A2,B_ESC_SCAN      
			JMP FIN_ESCC   
			 
LLESC_RB 	SUB.L #1,A2    			 
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,B_ESC_SCAN      
			JMP FIN_ESCC		
			
IESCC_RB	MOVE.L B_INI_SCAN,A2      
			CMP.L A1,A2              
			BEQ VESCC_RB             
			JMP FESCC_RB		
			
VESCC_RB 	MOVE.L B_FIN_SCAN,A2     
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,B_ESC_SCAN      
			JMP FIN_ESCC
			
*-------------------------------------------------------------------------------------*

ESCC_TA		MOVE.L   A_LEC_PRINT,A1   
			MOVE.L   A_ESC_PRINT,A2   * A2 = puntero de escritura.
			
			MOVE.B D1,(A2)            * Inserta el dato en la posicion de escritura (8bits menos significat.)
			CMP.L A_FIN_PRINT,A2      * comparamos A2 y puntero final buffer.
			BEQ IESCC_TA              * si son iguales salto a IESCC_TA
			ADD.L #1,A2               * si son distintos incrementamos el puntero de ESCRITURA A2.
			CMP.L A1,A2               * comparamos puntero de lectura y escritura.
			BEQ LLESC_TA           	  * si son iguales salta a LLESC_TA
			
FESCC_TA	MOVE.L   #0,D0			  * escribe 0 en D0 (operacion correcta)
			MOVE.L A2,A_ESC_PRINT     * guardamos la posicion del puntero de escritura.
			JMP FIN_ESCC   
			 
LLESC_TA 	SUB.L #1,A2    			  * vuelve el puntero una posicion atras(se pierde lo insertado)
			MOVE.L   #$ffffffff,D0	  * escribe H'FFFFFFFF en D0 (buffer lleno)
			MOVE.L A2,A_ESC_PRINT     * guardamos  la posicion del puntero de escritura.
			JMP FIN_ESCC				
			
IESCC_TA	MOVE.L A_INI_PRINT,A2     * A2 <- puntero de inicio de buffer.
			CMP.L A1,A2               * comparamos puntero de lectura y escritura.
			BEQ VESCC_TA              * si son iguales salta a VESCC_TA
			JMP FESCC_TA		
			
VESCC_TA 	MOVE.L A_FIN_PRINT,A2     * A2 <- puntero de fin de buffer.
			MOVE.L   #$ffffffff,D0	  * escribe H'FFFFFFFF en D0 (buffer lleno)
			MOVE.L A2,A_ESC_PRINT     * guardamos la posicion del puntero de escritura.
			JMP FIN_ESCC
			
			
*-------------------------------------------------------------------------------------*

ESCC_TB		MOVE.L  B_LEC_PRINT,A1    
			MOVE.L   B_ESC_PRINT,A2   
			
			MOVE.B D1,(A2)           
			CMP.L B_FIN_PRINT,A2      
			BEQ IESCC_TB              
			ADD.L #1,A2               
			CMP.L A1,A2              
			BEQ LLESC_TB           	 
			
FESCC_TB	MOVE.L   #0,D0			  
			MOVE.L A2,B_ESC_PRINT     
			JMP FIN_ESCC   
			 
LLESC_TB 	SUB.L #1,A2    			  
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,B_ESC_PRINT     
			JMP FIN_ESCC			
			
IESCC_TB	MOVE.L B_INI_PRINT,A2     
			CMP.L A1,A2               
			BEQ VESCC_TB             
			JMP FESCC_TB		
			
VESCC_TB 	MOVE.L B_FIN_PRINT,A2     
			MOVE.L   #$ffffffff,D0	  
			MOVE.L A2,B_ESC_PRINT     
			JMP FIN_ESCC

			
*******
*SCAN *
*******


SCAN    	LINK     A6,#-20          
			MOVE.L   A1,-4(A6)        
			MOVE.L   D4,-8(A6)        
			MOVE.L   D5,-12(A6)       
            MOVE.L   D2,-16(A6)       
			MOVE.L   D6,-20(A6)       
			MOVE.L   8(A6),A1         
			MOVE.W   12(A6),D5       
			MOVE.W   14(A6),D4        
			CMP.W 	 #0,D4			  
			BEQ 	 SCANZ
			MOVE.L   #0,D2            
			CMP.W    #0,D5            
			BEQ      SCAN_A        
			CMP.W    #1,D5
			BEQ      SCAN_B          
			MOVE.L   #$ffffffff,D0    
			JMP 	 FIN_SCAN
SCANZ		MOVE.L   #0,D0
FIN_SCAN	MOVE.L   -4(A6),A1        
			MOVE.L   -8(A6),D4        
			MOVE.L   -12(A6),D5       
			MOVE.L   -16(A6),D2       
			MOVE.L   -20(A6),D6       
			UNLK     A6               
			RTS                       
			
			
****************
* Scan linea A *
****************


SCAN_A     	MOVE.L   #0,D0 		    
			BSR 	 LEECAR		    
			MOVE.L   #$ffffffff,D6	 
			CMP.L 	 D0,D6 			
			BEQ      F_SCANA			
			
			ADD.L #1,D2             
			MOVE.B D0,(A1)+         
			CMP.L D2,D4             
			BNE SCAN_A	            
				
			MOVE.L   D2,D0 		    
			JMP FIN_SCAN           
			
F_SCANA		MOVE.L   D2,D0			
			JMP FIN_SCAN			
							
****************
* SCAN linea B *
****************

SCAN_B     	MOVE.L   #1,D0 		    
			BSR 	 LEECAR		  	
			MOVE.L   #$ffffffff,D6	 
			CMP.L 	 D0,D6 			
			BEQ      F_SCANB
			
			ADD.L #1,D2             
			MOVE.B D0,(A1)+         
			CMP.L D2,D4             
			BNE SCAN_B	            
			
			MOVE.L   D2,D0 		   
			JMP FIN_SCAN            
			
F_SCANB		MOVE.L   D2,D0			
			JMP FIN_SCAN			
				
*********
* PRINT *
*********

PRINT:    	
    LINK A6,#-20                            *Creamos el marco de pila para guardar los registros
	MOVE.L A1,-4(A6)                        *Salvamos los registros 
	MOVE.L D1,-8(A6)        
	MOVE.L D2,-12(A6)            
	MOVE.L D3,-16(A6)
    MOVE.L D4,-20(A6)

    MOVE.L #0,A1                            *Limpiamos todos los registros a utilizar
    MOVE.L #0,D1                            
    MOVE.L #0,D2                            
    MOVE.L #0,D3                            
    MOVE.L #0,D4                            

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
    ADD.L #1,D4                             *Incrementamos el contador
    MOVE.W 14(A6),D2
    CMP.L D4,D2                             *Contador y tamaño iguales termina la subrutina
    BNE PR_BUC

PR_INT:
    CMP.L #0,D4
    BEQ PR_FIN1
    MOVE.L #0,D1                            *Limpiamos D1

    MOVE.W SR,D1                            *Guardamos SR en D1
    MOVE.W #$2700,SR                        *Inhibimos las interrupciones

    CMP #2,D3                               *Si 2:
    BEQ PR_IMRA                             *Buffer de Transmisión de A
    BSET #4,COPIA_IMR                          *Como estamos en el buffer de transmisión B activamos el bit 4
    JMP PR_IMR

PR_IMRA:
    BSET #0,COPIA_IMR                          *Como estamos en el buffer de transmisión A activamos el bit 0 

PR_IMR:
    MOVE.B COPIA_IMR,IMR                       *Compiamos IMR_CP a IMR
    MOVE.W #$2000,SR                        *Activamos de nuevo las interrupciones
    MOVE.W D1,SR                            *Restituimos el SR al valor que tenia previamente 

PR_FIN1:
    MOVE.L D4,D0                            *Movemos el contador a D0
    
PR_FIN:
    MOVE.L -4(A6),A1                        *Rescatamos registros 
	MOVE.L -8(A6),D1        
	MOVE.L -12(A6),D2
    MOVE.L -16(A6),D3
    MOVE.L -20(A6),D4
    UNLK A6                                 *Destruimos el marco de pila
    RTS                    
*PRINT----------------------------------------------------------------------------------------		

*******
* RTI *
*******				

			
RTI    		LINK     A6,#-12     	    * creamos el marco de pila 24B para guardar 6 registros de 4B.
			MOVE.L   D2,-4(A6)     	    * salvamos los registros que vamos a usar
			MOVE.L   D5,-8(A6)
			MOVE.L   A1,-12(A6)
			MOVE.B   ISR,D5         	* copiamos ISR en D5
			MOVE.B   COPIA_IMR,D2       * y la copia de IMR en D2
			AND.B    D2,D5         		* haciendo un and entre ambos se consigue saber el periferico que interrumpe
			BTST     #1,D5
			BNE      RECEP_A         	* si el bit 1 RxRDYA/FFULLA esta a 1 saltamos a recepcion por linea A
			BTST     #5,D5
			BNE      RECEP_B       	    * si el bit 5 RxRDYB/FFULLB esta a 1 saltamos a recepcion por linea B
			BTST     #0,D5
			BNE      TRANS_A         	* si el bit 0 TxRDYA esta a 1 saltamos a transmision por linea A
			BTST     #4,D5
			BNE      TRANS_B          	* si el bit 4 TxRDYB esta a 1 saltamos a transmision por linea A
FIN_RTI 	MOVE.L   -4(A6),D2     		* restauramos los registros que hemos usado
			MOVE.L   -8(A6),D5
			MOVE.L   -12(A6),A1
			UNLK     A6             	* destruimos marco de pila.
			RTE                     	* retorno.
			
******************************
* Transmision por la linea A *
******************************			

TRANS_A     MOVE.L   #2,D0 		   			* parametro de entrada de LEECAR es 2(buffer A de transmision)
			BSR LEECAR		    	    	* lee 1 dato y lo pone en D0 
				
			CMP.L #$ffffffff,D0 					* si D0 es ffffffff deshabilitar interrupciones de transmision linea A
			BEQ TRANS_AD
				
			MOVE.B D0,TBA           		* el caracter leido lo pasamos al registro del buffer de transmision TBA.           
            JMP FIN_RTI               		* saltamos a fin.

TRANS_AD	BCLR #0,COPIA_IMR                		* ponemos a 0 el bit 0 de IMR, es decir desactivamos la interrupcion.
            MOVE.B COPIA_IMR,IMR             		* y modificamos IMR
            JMP FIN_RTI               		* saltamos a fin.		
			
*****************************
* Rececpcion por la linea a	*
*****************************

RECEP_A 	MOVE.L #0,D1               		* D1 = 0.
            MOVE.B RBA,D1             		* llevamos el registro de buffer de recepcion de A a D1			
			MOVE.L   #0,D0 		            * parametro de entrada de ESCCAR es 0(buffer A de recepcion)
			BSR ESCCAR		  	            * escribe el dato en el buffer		
            JMP FIN_RTI              		* salto a FIN_RTI.
			
******************************
* Transmision por la linea b *
******************************		

TRANS_B     MOVE.L   #3,D0 		   			* parametro de entrada de LEECAR es 3(buffer B de transmision)
			BSR LEECAR		    	    	* lee 1 dato y lo pone en D0 
											
			CMP.L #$ffffffff,D0 			* si D0 es ffffffff deshabilitar interrupciones de transmision linea B
			BEQ TRANS_BD

			MOVE.B D0,TBB           		* el caracter leido lo pasamos al registro del buffer de transmision TBB.
            JMP FIN_RTI               		* saltamos a fin.
			
TRANS_BD    BCLR #4,COPIA_IMR               * ponemos a 0 el bit 4 de IMR, es decir desactivamos la interrupcion.
            MOVE.B COPIA_IMR,IMR           	* y modificamos IMR
            JMP FIN_RTI               		* saltamos a fin.

***************************
* Recepcion por la linea B*
***************************

RECEP_B 	MOVE.L #0,D1               		* D1 = 0.
            MOVE.B RBB,D1             		* llevamos el registro de buffer de recepcion de A a D1
			MOVE.L   #1,D0 		            * parametro de entrada de ESCCAR es 1(buffer B de recepcion)
			BSR ESCCAR		  	            * escribe el dato en el buffer
            JMP FIN_RTI              		* salto a FIN_RTI.
			
******
*PPAL*
******

      		

* Manejadores de excepciones
INICIO: 	MOVE.L  #BUS_ERROR,8 		* Bus error handler
			MOVE.L  #ADDRESS_ER,12 		* Address error handler
			MOVE.L  #ILLEGAL_IN,16 		* Illegal instruction handler
			MOVE.L  #PRIV_VIOLT,32 		* Privilege violation handler
			MOVE.L  #ILLEGAL_IN,40 		* Illegal instruction handler
			MOVE.L  #ILLEGAL_IN,44 		* Illegal instruction handler
			
			BSR INIT
			MOVE.W #$2000,SR 			* Permite interrupciones
		
BUCPR:  	MOVE.W #TAMBS,PARTAM 		* Inicializa parametro de tama�o
			MOVE.L #BUFFER,PARDIR 		* Parametro BUFFER = comienzo del buffer
OTRAL:  	MOVE.W PARTAM,-(A7) 		* Tama�o de bloque
			MOVE.W #DESA,-(A7) 			* Puerto A
			MOVE.L PARDIR,-(A7) 		* Direccion de lectura
ESPL:  		BSR SCAN
			ADD.L #8,A7 				* Restablece la pila
			ADD.L D0,PARDIR 			* Calcula la nueva direccion de lectura
			SUB.W D0,PARTAM 			* Actualiza el numero de caracteres leidos
			BNE OTRAL 					* Si no se han leido todas los caracteres del bloque se vuelve a leer
			MOVE.W #TAMBS,CONTC 		* Inicializa contador de caracteres a imprimir
			MOVE.L #BUFFER,PARDIR 		* Parametro BUFFER = comienzo del buffer
OTRAE:  	MOVE.W #TAMBP,PARTAM 		* Tama�o de escritura = Tama�o de bloque
ESPE:   	MOVE.W PARTAM,-(A7) 		* Tama�o de escritura
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
SALIR:  	BRA BUCPR
BUS_ERROR:  BREAK 						* Bus error handler
			NOP
ADDRESS_ER: BREAK 						* Address error handler
			NOP
ILLEGAL_IN: BREAK 						* Illegal instruction handler
			NOP
PRIV_VIOLT: BREAK 						* Privilege violation handler
			NOP