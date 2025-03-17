F_PowerManage:
	jsr		L_HLightLevel_WithTime				; 7�����Ϊ����
	jsr		L_LLightLevel_WithTime				; 18�����Ϊ����

	bbs2	Clock_Flag,WakeUp_Trigger			; ����ʱ5020������ˢ������ʱ��

	bbr6	PB,No_5VDC_PWR
	bbr0	Backlight_Flag,L_5020_NoWakeUp
	rmb0	Backlight_Flag						; ����DC5Vʱ����һ������
WakeUp_Trigger:
	bbr4	PD,L_5020_NoWakeUp
	rmb4	PD
	jsr		L_Open_5020							; �������LCD�ж�
L_5020_NoWakeUp:
	lda		#0
	sta		Backlight_Counter
	smb3	Key_Flag							; ����Ļ�����¼��������л�ȥ��ʱ�򲻿��ж�
	rts

No_5VDC_PWR:
	smb0	Backlight_Flag
	bbs3	Key_Flag,WakeUp_Event_Yes
	rts
WakeUp_Event_Yes:
	lda		Backlight_Counter
	cmp		#17
	bcs		L_ShutDown_Display					; ����15S��Ͽ�5020���磬Ϩ���ȴ���������
	bbr1	Backlight_Flag,BacklightCount_NoAdd
	rmb1	Backlight_Flag
	inc		Backlight_Counter
BacklightCount_NoAdd:
	rts
L_ShutDown_Display:
	lda		#$00
	sta		Backlight_Counter
	smb4	PD									; ��Ļ���ѽ���������PD4�ر�5020
	jsr		L_Close_5020						; Ϩ����ر�LCD�ж�
	rmb3	Key_Flag
	rts



L_HLightLevel_WithTime:
	lda		R_Time_Hour
	cmp		#7
	bne		?LightLevel_Exit
	lda		R_Time_Min
	cmp		#0
	bne		?LightLevel_Exit
	lda		R_Time_Sec
	cmp		#0
	bne		?LightLevel_Exit
	smb0	PC_IO_Backup						; �޸ļ�������Ϊ����
	smb0	PC									; ����Ϊ����
	lda		#1
	sta		Backlight_Level
?LightLevel_Exit:
	rts

L_LLightLevel_WithTime:
	lda		R_Time_Hour
	cmp		#18
	bne		?LightLevel_Exit
	lda		R_Time_Min
	cmp		#0
	bne		?LightLevel_Exit
	lda		R_Time_Sec
	cmp		#0
	bne		?LightLevel_Exit
	rmb0	PC									; ����Ϊ����
	rmb0	PC_IO_Backup						; �޸ļ�������Ϊ����
	lda		#0
	sta		Backlight_Level
?LightLevel_Exit:
	rts



L_LightLevel_WithKeyU:
	lda		R_Time_Hour
	cmp		#7
	beq		KeyU_HighLight
	cmp		#18
	beq		KeyU_LowLight
	rts
KeyU_HighLight:
	smb0	PC									; ����Ϊ����
	smb0	PC_IO_Backup						; �޸ļ�������Ϊ����
	lda		#1
	sta		Backlight_Level
	rts
KeyU_LowLight:
	rmb0	PC									; ����Ϊ����
	rmb0	PC_IO_Backup						; �޸ļ�������Ϊ����
	lda		#0
	sta		Backlight_Level
	rts


L_LightLevel_WithKeyD:
	lda		R_Time_Hour
	cmp		#17
	beq		KeyD_HighLight
	cmp		#6
	beq		KeyD_LowLight
	rts
KeyD_HighLight:
	smb0	PC									; ����Ϊ����
	lda		#1
	sta		Backlight_Level
	rts
KeyD_LowLight:
	rmb0	PC									; ����Ϊ����
	lda		#0
	sta		Backlight_Level
	rts


L_Close_5020:
	rmb6	IER
	lda		PC
	and		#$0f
	sta		PC_IO_Backup
	lda		PC
	and		#$f0
	sta		PC

	lda		PD
	and		#$e0
	sta		PD_IO_Backup
	lda		PD
	and		#$1f
	sta		PD
	rts

L_Open_5020:
	lda		PC
	and		#$f0
	ora		PC_IO_Backup
	sta		PC

	lda		PD
	and		#$1f
	ora		PD_IO_Backup
	sta		PD
	smb6	IER
	rts
