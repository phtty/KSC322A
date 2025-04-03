F_Timekeep_Run:
	bbr0	Timekeep_Flag,?TimeStop				; ͬʱ�м�ʱ������־�ͼ�ʱ��ʱ1S��־�Żᴦ��
	bbr0	Timer_Flag,?TimeStop
	rmb0	Timer_Flag
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
	lda		R_Timekeep_Sec						; ����ʱ��S
	bne		TimeDown_NoOverflow					; �벻Ϊ0��һ��û����ʱ����

	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; ���붼Ϊ0ʱ��Ϊ��ʱ����
	sec
	sbc		#1
	sta		R_Timekeep_Min						; �ֲ�Ϊ0�������룬����

	lda		#$59
	sta		R_Timekeep_Sec
	bra		TimeDown_Reflash_Dis
TimekeepDown_Complete:
	cld
	rmb0	Timekeep_Flag
	smb1	Timekeep_Flag						; ���������λ����ʱ��ɱ�־����λ��ʱ����

	jsr		F_RFC_Abort							; ��������ʱ��ѹ������ֹRFC����
	smb1	Time_Flag
	smb3	Timer_Switch						; ����21Hz���������ʱ
	bra		TimeDown_Reflash_Dis

TimeDown_NoOverflow:
	sec
	sbc		#1
	sta		R_Timekeep_Sec
	cld
TimeDown_Reflash_Dis:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY
	rts


F_Timekeep_BeepHandler:
	bbr1	Timekeep_Flag,No_Timekeep_Process	; �е���ʱ��ɱ�־λ�ٽ�����
	jmp		Timekeep_BeepProcess
No_Timekeep_Process:
	bbs4	Key_Flag,BeepingNoClose				; ����а�����ʾ�����򲻹رշ�����
	rmb7	Timer_Switch						; �رշ�����ʱ��Դ��ʱ����
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Timekeep_Flag
BeepingNoClose:
	lda		#0
	sta		TimekeepLoud_Counter
	rts


Timekeep_BeepProcess:
	bbs1	Time_Flag,?BeepStart				; ÿ����1S��һ��
	rts
?BeepStart:
	rmb1	Time_Flag
	lda		AlarmLoud_Counter
	cmp		#60
	beq		CloseBeep							; ����60S��ر�����
	lda		#4									; ���ֵ�����Ϊ4��2��
	sta		Beep_Serial
	inc		TimekeepLoud_Counter
	rts

CloseBeep:										; �������ر�����
	rmb1	RFC_Flag							; ȡ������RFC����

	rmb1	Timekeep_Flag						; �رյ���ʱ��ɱ�־

	bbs4	Key_Flag,?BeepJuge_Exit				; ����а�����ʾ�����򲻹رշ�����
	rmb7	Timer_Switch						; �رշ�����ʱ��Դ��ʱ����
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
?BeepJuge_Exit:
	rts




F_Timekeep_Display:
	bbs1	Timekeep_Flag,Timekeep_Over
	bbs6	Time_Flag,Timekeep_FlashDis
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
