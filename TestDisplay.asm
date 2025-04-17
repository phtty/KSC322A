F_Test_Display:
	jsr		F_FillScreen						; 上电全显2S
	jsr		L_Send_DRAM
	lda		#2
	sta		P_Temp+4
Loop_FillScr:
	bbr0	Timer_Flag,Loop_FillScr
	rmb0	Timer_Flag
	dec		P_Temp+4
	lda		P_Temp+4
	bne		Loop_FillScr

	jsr		F_ClearScreen
	jsr		F_Display_Time
	jsr		F_DisCol
	jsr		L_Send_DRAM

;	bbr6	PB,StartUp_WakeUp
;	smb0	Backlight_Flag						; 有5V供电则置位DC标志
;StartUp_WakeUp:
;	smb3	Key_Flag							; 上电先给一个唤醒事件，免得上电不显示
;	rmb4	PD
	rts
