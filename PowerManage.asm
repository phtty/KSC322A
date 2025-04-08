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
	rts

Exit_LowPower:
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
