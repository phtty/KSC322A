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

	jsr		F_ClearScreen						; 从0显示到9
	jsr		L_DisSymbol_Test
	lda		#0
	sta		P_Temp+4
	jsr		L_DisDigit_Test
Loop_DisDigit:
	bbr1	Timer_Flag,Loop_DisDigit
	rmb1	Timer_Flag
	jsr		L_DisDigit_Test
	inc		P_Temp+4
	lda		P_Temp+4
	cmp		#11
	bne		Loop_DisDigit

	jsr		F_ClearScreen						; 显示PM、AL点
	lda		#0
	sta		P_Temp+4
	jsr		F_DisPM
	jsr		L_Send_DRAM
Loop_DisSymbol1:
	bbr1	Timer_Flag,Loop_DisSymbol1
	rmb1	Timer_Flag

	jsr		F_ClearScreen						; 显示dot点
	lda		#0
	sta		P_Temp+4
	jsr		F_DisCol
	jsr		F_DisAL1
	jsr		F_DisAL2
	jsr		L_Send_DRAM
Loop_DisSymbol2:
	bbr1	Timer_Flag,Loop_DisSymbol2
	rmb1	Timer_Flag

	jsr		F_ClearScreen						; 显示温度点
	lda		#0
	sta		P_Temp+4
	ldx		#led_TMPC
	jsr		F_DisSymbol
	ldx		#led_TMPF
	jsr		F_DisSymbol							; 华氏、摄氏度点
	ldx		#led_Date
	jsr		F_DisSymbol							; 华氏、摄氏度点
	ldx		#led_Month
	jsr		F_DisSymbol							; 华氏、摄氏度点
	jsr		L_Send_DRAM

;	bbr6	PB,StartUp_WakeUp
;	smb0	Backlight_Flag						; 有5V供电则置位DC标志
;StartUp_WakeUp:
;	smb3	Key_Flag							; 上电先给一个唤醒事件，免得上电不显示
;	rmb4	PD
	rts


L_DisDigit_Test:
	ldx		#led_d0
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d1
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d2
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d3
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d5
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d6
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d7
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d8
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d9
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	jsr		L_Send_DRAM
	rts

L_DisSymbol_Test:
	ldx		#led_minus
	jsr		F_DisSymbol
	lda		#1
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot					; digit4全显
	lda		#1
	ldx		#led_d8
	jsr		L_Dis_2Bit_DigitDot					; digit8全显

	rts
