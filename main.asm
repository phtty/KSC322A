	.CHIP		W65C02S								; cpu��ѡ��
	.MACLIST	ON

CODE_BEG	EQU		E000H							; ��ʼ��ַ

PROG		SECTION OFFSET CODE_BEG					; �������ε�ƫ������CODE_BEG��ʼ��������֯������롣
.include	50Px1x.h								; ͷ�ļ�
.include	RAM.INC
.include	Init.mac
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
	sta		IER										; ���������ж�
	lda		FUSE
	sta		MF0										; Ϊ�ڲ�RC�����ṩУ׼����	

	jsr		F_Init_Sys								; ��ʼ������

	cli												; �����ж�
	jsr		L_Send_DRAM

;�ϵ紦��
	rmb4	IER										; �رհ����жϱ����ϵ���̱�����
	lda		#0
	sta		Light_Level								; ��ʼ��������Ϊ����

 	jsr		F_Test_Display							; �ϵ���ʾ����

;	jsr		F_RFC_MeasureStart						; �ϵ��¶Ȳ���
;Wait_RFC_MeasureOver:
;	jsr		F_RFC_MeasureManage
;	bbs0	RFC_Flag,Wait_RFC_MeasureOver

	lda		#$02
	sta		Beep_Serial
	smb4	Key_Flag
	smb3	Timer_Switch							; �ϵ�����1��

	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal

	REFLASH_HALF_SEC								; �ϵ����̲�����S����
	smb1	Calendar_Flag							; �ϵ����̲���������ʾ����

	smb4	IER										; �ϵ���ʾ��ɣ����¿��������ж�

; ���Բ���

	bra		Global_Run


; ״̬��
MainLoop:
	jsr		F_PowerSavingMode						; ֻ��Ŧ�۵�ص�ʡ��ģʽ
Global_Run:											; ȫ����Ч�Ĺ��ܴ���
	jsr		F_Flash_Display							; ͨ����־λ�����Ƿ�ˢ����ʾ
	;jsr		F_KeyHandler
	jsr		IR_Receive_Loop							; �������
	jsr		F_BeepManage
	jsr		F_Time_Run								; ��ʱ
	jsr		F_SymbolRegulate
	jsr		F_Date_Display							; ���ں����ڸ��£���������ģʽ�����������ø��½ӹ�
	;jsr		F_RFC_MeasureManage
	jsr		F_ReturnToInitial						; ��ʱ����ʱ��ģʽ

Status_Juge:
	bbs0	Sys_Status_Flag,Status_DisTime
	bbs1	Sys_Status_Flag,Status_DisAlarm
	bbs2	Sys_Status_Flag,Status_SetClock
	bbs3	Sys_Status_Flag,Status_SetAlarm
	bbs4	Sys_Status_Flag,Status_TimeKeep

	bra		MainLoop
Status_DisTime:
	jsr		F_Time_Display
	jsr		F_Alarm_Handler							; ��ʾ״̬�������ж�
	bra		MainLoop
Status_DisAlarm:
	jsr		F_Alarm_GroupDis
	jsr		F_Alarm_Handler							; ��ʾ״̬�������ж�
	bra		MainLoop
Status_SetClock:
	jsr		F_Clock_Set
	bra		MainLoop
Status_SetAlarm:
	jsr		F_Alarm_GroupSet
	bra		MainLoop
Status_TimeKeep:
	jsr		F_Timekeep_Run
	jsr		F_Timekeep_Display
	jsr		F_Timekeep_BeepHandler
	bra		MainLoop




F_ReturnToInitial:
	bbr3	Clock_Flag,NoNeed_Return				; ͬʱ�з��س�ʼ״̬��ʱ�����ͷ��ؼ�ʱ1S��־�Żᴦ��
	bbs3	Time_Flag,L_Return_Start
NoNeed_Return:
	rts
L_Return_Start:
	rmb3	Time_Flag
	lda		Return_Counter
	cmp		Return_MaxTime							; ��ǰģʽ�ķ���ʱ��
	bcs		L_ReturnToInitial
	inc		Return_Counter
	rts
L_ReturnToInitial:
	lda		#0
	sta		Return_Counter
	rmb3	Clock_Flag
	jmp		Return_CD_Mode




F_Init_Sys:
	F_Init_SystemRam								; ��ʼ��ϵͳRAM���������жϵ籣����RAM
	F_Port_Init										; ��ʼ���õ���IO��
	F_Beep_Init

	F_Timer_Init
	F_RFC_Init
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
	cld

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrq
	bbs6	R_Int_Backup,L_LcdIrq
	jmp		L_EndIrq

L_DivIrq:										; ���ں��������ʱ��������ʱ��Դ�Լ�RFC 50Hz��������
	rmb0	IFR									; ���жϱ�־λ
	jmp		I_DivIRQ_Handler

L_Timer0Irq:
	rmb1	IFR									; ���жϱ�־λ
	jmp		I_Timer0IRQ_Handler

L_Timer1Irq:
	rmb2	IFR									; ���жϱ�־λ
	jmp		I_Timer1IRQ_Handler

L_Timer2Irq:									; ����LED��PWM���⡢32Hz����������21Hz������������Լ�4Hz��Ӽ���
	rmb3	IFR									; ���жϱ�־λ
	jmp		I_Timer2IRQ_Handler

L_PaIrq:										; ���ڰ���
	rmb4	IFR									; ���жϱ�־λ
	jmp		I_PaIRQ_Handler

L_LcdIrq:										; ������ʱ�Ͱ������
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
.include	KeyFunction.asm
.include	Time.asm
.include	Calendar.asm
.include	Beep.asm
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
.include	TimeKeep.asm


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
