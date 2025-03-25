	.CHIP		W65C02S								; cpu��ѡ��
	.MACLIST	ON

CODE_BEG	EQU		E000H							; ��ʼ��ַ

PROG		SECTION OFFSET CODE_BEG					; �������ε�ƫ������CODE_BEG��ʼ��������֯������롣
.include	50Px1x.h								; ͷ�ļ�
.include	RAM.INC	
.include	MACRO.mac

STACK_BOT		EQU		FFH							; ��ջ�ײ�
.PROG												; ����ʼ

V_RESET:
	nop
	nop
	nop
	ldx		#STACK_BOT
	txs												; ʹ�����ֵ��ʼ����ջָ�룬��ͨ����Ϊ�����ö�ջ�ĵײ���ַ��ȷ�����������ж�ջ����ȷʹ�á�
	lda		#$07									; #$97
	sta		SYSCLK									; ����ϵͳʱ��

	lda		#00										; ��λRAM��0
	ldx		#$ff
	sta		$1800
L_Clear_Ram_Loop:
	sta		$1800,x
	dex
	bne		L_Clear_Ram_Loop

	lda		#$0
	sta		DIVC									; ��Ƶ����������ʱ����DIV�첽
	sta		IER										; �����ж�
	lda		FUSE
	sta		MF0										; Ϊ�ڲ�RC�����ṩУ׼����	

	jsr		F_Init_SystemRam						; ��ʼ��ϵͳRAM���������жϵ籣����RAM
	jsr		F_Port_Init								; ��ʼ���õ���IO��
	jsr		F_Beep_Init

	jsr		F_Timer_Init
	jsr		F_RFC_Init

	cli												; �����ж�

	jsr		L_Send_DRAM

; �ϵ紦��
; 	rmb4	IER										;  �رհ����жϱ����ϵ���̱�����
; 	lda		#1
; 	sta		Light_Level
; 	smb0	PC										; ��ʼ��������Ϊ����
; 	smb0	PC_IO_Backup
; 
 	;jsr		F_Test_Display							; �ϵ���ʾ����
	;lda		#$02
	;sta		Beep_Serial
	;smb4	Key_Flag
	;smb3	Timer_Switch

; 	jsr		F_RFC_MeasureStart						; �ϵ��¶Ȳ���
; Wait_RFC_MeasureOver:
; 	jsr		F_RFC_MeasureManage
; 	bbs0	RFC_Flag,Wait_RFC_MeasureOver
; 
; 	smb1	Timer_Flag
; 	rmb0	Timer_Flag
; 	jsr		F_SymbolRegulate
; 	jsr		F_Time_Display
; 	jsr		F_Display_Week
; 
; 	lda		#4										; �ϵ��������2��
; 	sta		Beep_Serial
; 	smb0	TMRC
; Loop_BeepTest:										; ��������
; 	jsr		F_Louding
; 	lda		Beep_Serial
; 	bne		Loop_BeepTest
; 	rmb0	TMRC
; 
; 	lda		#0001B
; 	sta		Sys_Status_Flag
; 	lda		#0
; 	sta		Sys_Status_Ordinal
; 
; 	smb4	IER										;  �ϵ���ʾ��ɣ����¿��������ж�
	bra		Global_Run


; ״̬��
MainLoop:
	lda		PC
	and		#$20
	bne		Global_Run
	;smb4	SYSCLK
	;sta		HALT									; ����
	;rmb4	SYSCLK
Global_Run:											; ȫ����Ч�Ĺ��ܴ���
	;jsr		F_KeyHandler
	jsr		IR_Test_1
	jsr		IR_Test_2
	jsr		F_IR_Decode								; �������
	jsr		F_BeepManage
	;jsr		F_PowerManage
	;jsr		F_Time_Run								; ��ʱ
	;jsr		F_SymbolRegulate
	;jsr		F_Display_Week
	;jsr		F_RFC_MeasureManage
	;jsr		F_ReturnToDisTime						; ��ʱ����ʱ��ģʽ

Status_Juge:
	bbs0	Sys_Status_Flag,Status_DisClock
	bbs1	Sys_Status_Flag,Status_DisAlarm
	bbs2	Sys_Status_Flag,Status_SetClock
	bbs3	Sys_Status_Flag,Status_SetAlarm

	bra		MainLoop
Status_DisClock:
	;jsr		F_Clock_Display
	;jsr		F_Alarm_Handler							; ��ʾ״̬�������ж�
	;bra		MainLoop
Status_DisAlarm:
	;jsr		F_Alarm_Display
	;jsr		F_Alarm_Handler							; ��ʾ״̬�������ж�
	bra		MainLoop
Status_SetClock:
	;jsr		F_Clock_Set
	bra		MainLoop
Status_SetAlarm:
	;jsr		F_Alarm_Set
	bra		MainLoop




F_ReturnToDisTime:
	bbs3	Time_Flag,L_Return_Start
	rts
L_Return_Start:
	bbr0	Sys_Status_Flag,L_Return_Juge
	bbs0	Sys_Status_Ordinal,L_Return_Juge
	nop												; ������ʱģʽ�£��򲻷���
	lda		#10
	sta		Return_MaxTime
L_Return_Juge:
	rmb3	Time_Flag
	lda		Return_Counter
	cmp		Return_MaxTime							; ��ǰģʽ�ķ���ʱ��
	bcs		L_Return_Stop
	inc		Return_Counter
	bra		L_Return_Juge_Exit
L_Return_Stop:
	lda		#0
	sta		Return_Counter
	bbr0	Sys_Status_Flag,No_TimeDis_Return		; Sys Flag��һλΪ0����ʱ��
	bbs0	Sys_Status_Ordinal,No_TimeDis_Return	; Sys Ordinal��Ϊ0����ʱ��
	;jsr		SwitchState_ClockDis					; ʱ�����������ԣ����ʱ������������
	bra		L_Return_Juge_Exit

No_TimeDis_Return:
	lda		#0
	sta		Sys_Status_Ordinal						; ��ʱ������ʱ�����򷵻�ʱ��

Return_Over:
	lda		#0001B									; �ص�ʱ��ģʽ
	sta		Sys_Status_Flag
L_Return_Juge_Exit:
	rts




; �жϷ�����
V_IRQ:
	pha
	txa
	pha
	php
	lda		IER
	and		IFR
	sta		R_Int_Backup

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrq
	bbs6	R_Int_Backup,L_LcdIrq
	jmp		L_EndIrq

L_DivIrq:
	rmb0	IFR									; ���жϱ�־λ
	jmp		I_DivIRQ_Handler

L_Timer0Irq:									; ���ڷ�����
	rmb1	IFR									; ���жϱ�־λ
	jmp		I_Timer0IRQ_Handler

L_Timer1Irq:									; ���ڿ�Ӽ�ʱ
	rmb2	IFR									; ���жϱ�־λ
	jmp		I_Timer1IRQ_Handler

L_Timer2Irq:
	rmb3	IFR									; ���жϱ�־λ
	jmp		I_Timer2IRQ_Handler

L_PaIrq:
	rmb4	IFR									; ���жϱ�־λ
	jmp		I_PaIRQ_Handler

L_LcdIrq:
	rmb6	IFR									; ���жϱ�־λ
	jmp		I_LcdIRQ_Handler

L_EndIrq:
	plp
	pla
	tax
	pla
	rti


.include	IRQ.asm
.include	ScanKey.asm
.include	Time.asm
.include	Calendar.asm
.include	Beep.asm
.include	Init.asm
.include	Disp.asm
.include	Display.asm
.include	Alarm.asm
.include	Ledtab.asm
.include	RFC.asm
.include	RFCTable.asm
.include	TemperHandle.asm
.include	PowerManage.asm
.include	TestDisplay.asm
.include	infrared.asm
.include	IR_Table.asm


.BLKB	0FFFFH-$,0FFH							; �ӵ�ǰ��ַ��FFFFȫ�����0xFF

.ORG	0FFF8H
	DB		C_PY_SEL+C_OMS_BR
	DB		C_PROTB
	DW		0FFFFH

.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ

.ENDS
.END
