F_PowerSavingMode:
	lda		PC
	and		#$20
	beq		L_Low_Power								; �ж�ʡ��ģʽ�������
	rts

L_Low_Power:
	jsr		Enter_LowPower							; �رպĵ���Դ
PS_Mode_Loop:
	smb4	SYSCLK
	sta		HALT									; ����
	rmb4	SYSCLK
	jsr		F_Time_Run								; �����ģʽ��ֻ����S�ж�������ʱ
	lda		PC
	and		#$20
	beq		PS_Mode_Loop							; ��DC�����޸ߵ�ƽ����ʡ��ģʽѭ��

	jsr		Exit_LowPower							; ����ѭ��ʹ�õ�������Դ
	rts

Enter_LowPower:
	lda		#$40
	sta		IER
	rmb1	Backlight_Flag
	LED_SET_HIGH

	rmb4	Key_Flag
	rmb6	Key_Flag
	rmb1	RFC_Flag
	rmb7	Timer_Switch							; �رշ�����ʱ��Դ
	rmb3	Timer_Switch							; �ر�21Hz��ʱ
	lda		#0
	sta		Counter_21Hz
	lda		#00
	sta		Beep_Serial
	rts

Exit_LowPower:
	lda		#$59
	sta		IER
	rmb4	IFR

	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal
	REFLASH_DISPLAY

	smb1	Backlight_Flag
	rmb3	Backlight_Flag							; �ָ���ʾ��
	rts



F_Display_LightLevel:
	bbr3	Backlight_Flag,NoDisLL
	bbs0	Timer_Flag,DisLL_Start
NoDisLL:
	rts
DisLL_Start:
	rmb0	Timer_Flag

	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	jsr		L_Dis_Lxx

	inc		Counter_LL
	lda		Counter_LL
	cmp		#3
	bcc		DisLL_Over
	lda		#0
	sta		Counter_LL
	rmb3	Backlight_Flag
DisLL_Over:
	REFLASH_DISPLAY
	rts




F_AutoLL_Get:
	bbs4	Backlight_Flag,GetLL_Start
	rts
GetLL_Start:
	rmb4	Backlight_Flag

	lda		PD
	and		#$20
	beq		High_Light_Mode
	lda		#0
	sta		Auto_LightLevel
	rts
High_Light_Mode:
	lda		#2
	sta		Auto_LightLevel
	rts


F_CloseLED_Count:
	bbr4	Clock_Flag,CloseLEDCount_Exit
	bbs7	Time_Flag,CloseLEDCount
	rts
CloseLEDCount:
	dec		CloseLED_Counter
	lda		CloseLED_Counter
	bne		CloseLEDCount_Exit
	rmb1	Backlight_Flag
	rmb1	RFC_Flag						; ��������RFC����
	rmb4	Clock_Flag
	LED_SET_HIGH
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal				; 30S��ʱ����֮��Ϩ��
	jsr		Return_CD_Mode					; ����ʱ��
CloseLEDCount_Exit:
	rts
