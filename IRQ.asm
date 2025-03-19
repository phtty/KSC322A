I_DivIRQ_Handler:
	sei
	inc		Counter_20ms
	lda		Counter_20ms
	cmp		#1
	beq		RFC_Start
	cmp		#11
	beq		RFC_Sample
	cli
	jmp		L_EndIrq
RFC_Start:
	jsr		F_RFC_Channel_Select
	cli
	jmp		L_EndIrq
RFC_Sample:
	jsr		L_Get_RFC_Data
	lda		#0
	sta		Counter_20ms
	cli
	jmp		L_EndIrq


I_Timer0IRQ_Handler:
	inc		Counter_16Hz
	lda		Counter_16Hz						; 16Hz����
	cmp		#192
	bcs		L_16Hz_Out
	jmp		L_EndIrq
L_16Hz_Out:
	lda		#0
	sta		Counter_16Hz
	smb6	Timer_Flag							; 16Hz��־
	jmp		L_EndIrq


I_Timer1IRQ_Handler:
	smb4	Timer_Flag							; ɨ��16Hz��־
	lda		Counter_4Hz							; 4Hz����
	cmp		#03
	bcs		L_4Hz_Out
	inc		Counter_4Hz
	jmp		L_EndIrq
L_4Hz_Out:
	lda		#$0
	sta		Counter_4Hz
	smb5	Key_Flag							; ���4Hz��־
	jmp		L_EndIrq


I_Timer2IRQ_Handler:
	smb0	Timer_Flag							; �����־
	smb0	Symbol_Flag
	lda		Counter_1Hz
	cmp		#01
	bcs		L_1Hz_Out
	inc		Counter_1Hz
	jmp		L_EndIrq
L_1Hz_Out:
	lda		#$0
	sta		Counter_1Hz
	lda		Timer_Flag
	ora		#10100110B							; 1S����S��Ϩ����1S������1S��־λ
	sta		Timer_Flag
	smb1	Backlight_Flag						; ����1S��ʱ
	smb7	Key_Flag							; DP��ʾ1S��ʱ
	smb1	Symbol_Flag
	smb7	Clock_Flag							; ����ʱ��1S��ʱ
	smb5	RFC_Flag							; 30S������ʱ
	rmb4	Clock_Flag							; �������������־
	jmp		L_EndIrq


I_PaIRQ_Handler:
	rmb4	SYSCLK
	smb0	Key_Flag
	smb1	Key_Flag							; �״δ���
	rmb3	Timer_Flag							; ������µ��½��ص��������ӱ�־λ
	rmb4	Timer_Flag							; 16Hz��ʱ
	smb1	TMRC								; �򿪿�Ӷ�ʱ

	jmp		L_EndIrq


I_LcdIRQ_Handler:
;	lda		COM_Counter
;	cmp		#3
;	bcc		COM_Display
;	lda		#0
;	sta		COM_Counter
;COM_Display:
;	jsr		L_Send_Buffer_COM

	jmp		L_EndIrq
