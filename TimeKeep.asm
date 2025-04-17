F_Timekeep_Run:
	bbr0	Timekeep_Flag,Timekeep_NoRun		; ͬʱ�м�ʱ������־�ͼ�ʱ��ʱ1S��־�Żᴦ��
	bbs4	Time_Flag,Timekeep_Run_Start
Timekeep_NoRun
	rts
Timekeep_Run_Start:
	rmb4	Time_Flag
	REFLASH_DISPLAY

	lda		Sys_Status_Ordinal
	bne		TimekeepDown_Mode
	sed											; ����ʱ��S
	lda		R_Timekeep_Sec
	clc
	adc		#1
	sta		R_Timekeep_Sec
	cmp		#$60
	bcc		?TimeStop							; ��ʱ��δ���
	lda		#0
	sta		R_Timekeep_Sec
	lda		R_Timekeep_Min
	clc
	adc		#1
	sta		R_Timekeep_Min
?TimeStop:
	cld
	rts


TimekeepDown_Mode:
	sed
	lda		R_Timekeep_Sec
	beq		Timekeep_SecOverflowJuge			; �ֽ�λ����
	sec
	sbc		#1
	sta		R_Timekeep_Sec
	bne		TimekeepDown_NoComplete
	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; ��ʱ���
TimekeepDown_NoComplete:
	bra		TimeDown_Reflash_Dis
Timekeep_SecOverflowJuge:
	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; ��ʱ���
	sec
	sbc		#1
	sta		R_Timekeep_Min						; �ֲ�Ϊ0����֣�������
	lda		#$59
	sta		R_Timekeep_Sec
	bra		TimeDown_Reflash_Dis
TimekeepDown_Complete:
	cld
	rmb0	Timekeep_Flag
	smb1	Timekeep_Flag						; �����������λ����ʱ��ɱ�־����λ��ʱ����

	smb1	Time_Flag
	smb3	Timer_Switch						; ����21Hz���������ʱ
	lda		#0
	sta		Counter_21Hz
	sta		Louding_Counter
	smb2	Clock_Flag							; ��������ģʽ
	rmb1	Clock_Flag							; ������Ӵ���
TimeDown_Reflash_Dis:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY
	rts




F_Timekeep_Display:
	bbs3	Backlight_Flag,Timekeep_NoDisplay
	bbs1	Timekeep_Flag,Timekeep_Over
	bbs6	Time_Flag,Timekeep_FlashDis
Timekeep_NoDisplay:
	rts
Timekeep_FlashDis:
	jmp		F_Display_Timekeep


Timekeep_Over:										; ����ʱ���ʱ��˸
	bbs1	Timer_Flag,TimekeepDownOver_Start
	rts
TimekeepDownOver_Start:
	rmb1	Timer_Flag

	bbs0	Timer_Flag,TimekeepDownOver_Clr			; 1S��
	jsr		F_Display_Timekeep
	REFLASH_DISPLAY									; ��λˢ����ʾ��־
	rts
TimekeepDownOver_Clr:
	rmb0	Timer_Flag								; ��1S��־
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY									; ��λˢ����ʾ��־
	rts
