F_Alarm_GroupDis:
	jsr		L_AlarmDot_Blink					; 闪烁AL点指示当前闹钟组
	jsr		F_Display_Alarm
	rts




F_Alarm_GroupSet:
	jsr		L_AlarmDot_Blink

	lda		Sys_Status_Ordinal
	clc
	rol
	tax
	lda		AlarmGroupHandle_Table+1,x
	pha
	lda		AlarmGroupHandle_Table,x
	pha
	rts											; 根据当前子模式，跳转到对应的显示函数

; 根据当前闹钟组进对应设置模式
AlarmGroupHandle_Table:
	dw		F_Alarm_SwitchStatue-1
	dw		F_AlarmHour_Set-1
	dw		F_AlarmMin_Set-1
	dw		F_AlarmWorkDay_Set-1



L_AlarmDot_Blink:
	lda		Alarm_Group
	eor		#1
	sta		P_Temp
	tax											; 取非当前闹组
	lda		#1
	jsr		L_A_LeftShift_XBit					; 把1左移相应位计算出当前组闹钟开关的位号
	and		Alarm_Switch						; 和闹钟开关状态相与得出该位号是开还是关
	clc
	rol
	clc
	adc		P_Temp								; 非当前闹组加上非当前闹组状态*2即为要跳转的函数
	;jsr		L_Control_ALDot

	bbs1	Symbol_Flag,L_AlarmDot_Out
	rts
L_AlarmDot_Out:									; 闪烁当前闹组
	rmb1	Symbol_Flag
	bbs0	Symbol_Flag,No_ALDot_Display
	lda		Alarm_Group
	clc
	adc		#2
	jsr		L_Control_ALDot						; 当前组AL点半秒亮
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
No_ALDot_Display:
	rmb0	Symbol_Flag
	lda		Alarm_Group
	jsr		L_Control_ALDot						; 当前组AL点1秒灭
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




; 闹钟开关显示
F_Alarm_SwitchStatue:
	bbs1	Timer_Flag,?AlarmSW_BlinkStart
	rts
?AlarmSW_BlinkStart:
	rmb1	Timer_Flag
	bbs0	Timer_Flag,AlarmSW_UnDisplay
	ldx		Alarm_Group
	lda		#1
	jsr		L_A_LeftShift_XBit					; 把1左移相应位计算出当前组闹钟开关的位号
	and		Alarm_Switch						; 和闹钟开关状态相与得出该位号是开还是关

	beq		ALSwitch_DisOff
	lda		#2
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; 显示ON

	lda		#3
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

ALSwitch_DisOff:
	lda		#9
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; 显示--

	lda		#9
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

AlarmSW_UnDisplay:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D0_1
	jmp		F_UnDisplay_D2_3

ALSwitch_DisNum:								; 显示闹钟序号
	lda		#4
	ldx		#led_d2
	jsr		L_Dis_7Bit_WordDot

	lda		Alarm_Group							; +1为实际闹钟序号
	clc
	adc		#1
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts




F_AlarmHour_Set:
	bbs1	Timer_Flag,L_AlarmHour_Set
	rts
L_AlarmHour_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmHour_Display		; 有快加时常亮
	bbs5	IR_Flag,L_AlarmHour_Display			; 有快加时常亮
	bbs0	Timer_Flag,L_AlarmHour_Clear
L_AlarmHour_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmHour_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D0_1
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




F_AlarmMin_Set:
	bbs1	Timer_Flag,L_AlarmMin_Set
	rts
L_AlarmMin_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmMin_Display			; 有快加时常亮
	bbs5	IR_Flag,L_AlarmMin_Display			; 有快加时常亮
	bbs0	Timer_Flag,L_AlarmMin_Clear
L_AlarmMin_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmMin_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




F_AlarmWorkDay_Set:
	bbs1	Timer_Flag,L_AlarmWorkDay_Set
	rts
L_AlarmWorkDay_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs0	Timer_Flag,L_AlarmWorkDay_Clear
	ldx		#led_d1
	lda		#1
	jsr		L_Dis_7Bit_DigitDot					; 固定显示1-
	ldx		#led_d2
	lda		#10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d2+6
	jsr		F_DisSymbol

	ldx		Alarm_Group
	lda		Alarm_WorkDayAddr,x					; 显示对应闹组的工作日
	clc
	adc		#5
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmWorkDay_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




F_Alarm_Handler:
	jsr		L_IS_AlarmTrigger					; 判断闹钟是否触发
	bbr2	Clock_Flag,L_No_Alarm_Process		; 有响闹标志位再进处理
	jsr		L_Alarm_Process
	rts
L_No_Alarm_Process:
	bbs4	Key_Flag,L_LoudingNoClose			; 如果有按键提示音，则不关闭蜂鸣器
	rmb7	Timer_Switch						; 关闭蜂鸣器时钟源计时开关
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
L_LoudingNoClose:
	lda		#0
	sta		AlarmLoud_Counter
	rts


L_IS_AlarmTrigger:
	lda		Alarm_Switch
	bne		Alarm_Juge_Start					; 没有任何闹钟开启则不会判断闹钟是否触发
	rmb1	Clock_Flag
	rts
Alarm_Juge_Start:
	bbs2	Clock_Flag,L_AlarmTrigger_Exit		; 如此时仍在响闹，则不判断闹钟是否触发
	jsr		Is_Alarm_Trigger					; 判断两组闹钟触发
	bbs1	Clock_Flag,L_AlarmTrigger
	rts
L_AlarmTrigger:
	jsr		F_RFC_Abort							; 避免响闹时电压不稳终止RFC采样
	smb1	Time_Flag
	smb3	Timer_Switch						; 开启21Hz蜂鸣间隔定时
	smb2	Clock_Flag							; 开启响闹模式
	rmb1	Clock_Flag							; 关闭闹钟触发标志，避免重复进闹钟触发
L_AlarmTrigger_Exit:
	rts

L_CloseLoud:									; 结束并关闭响闹
	rmb6	Clock_Flag
	rmb1	RFC_Flag							; 取消禁用RFC采样
	lda		#0
	sta		Triggered_AlarmGroup
	sta		AlarmLoud_Counter
	rmb1	Clock_Flag							; 关闭闹钟触发标志
	rmb2	Clock_Flag							; 关闭响闹模式
	rmb5	Clock_Flag

	bbs4	Key_Flag,L_LoudingJuge_Exit			; 如果有按键提示音，则不关闭蜂鸣器
	rmb7	Timer_Switch						; 关闭闹钟相关的计时开关
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
L_LoudingJuge_Exit:
	rts




L_Alarm_Process:
	bbs1	Time_Flag,L_BeepStart				; 每响铃1S进一次
	rts
L_BeepStart:
	rmb1	Time_Flag
	lda		AlarmLoud_Counter
	cmp		#60
	beq		L_CloseLoud							; 响铃60S后关闭响闹
	lda		#8									; 响闹的序列为8，4声
	sta		Beep_Serial
	inc		AlarmLoud_Counter
	rts


; 任意一组闹钟设定值的时、分符合当前时间，就设置闹钟触发标志位,并同步至触发闹钟
; 同时判断此闹钟是否处于工作日
Is_Alarm_Trigger:
	lda		Alarm_Switch
	and		#010B
	beq		L_Alarm2_NoMatch					; 如果此闹钟没有开启，则不会判断它
	lda		R_Time_Hour
	cmp		R_Alarm2_Hour
	beq		L_Alarm2_HourMatch
L_Alarm2_NoMatch:
	lda		Alarm_Switch
	and		#001B
	beq		L_Alarm1_NoMatch					; 如果此闹钟没有开启，则不会判断它
	lda		R_Time_Hour
	cmp		R_Alarm1_Hour
	beq		L_Alarm1_HourMatch
L_Alarm1_NoMatch:
	rmb1	Clock_Flag							; 所有闹钟均未触发
	rts

L_Alarm1_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm1_Min
	beq		L_Alarm1_MinMatch
	rmb1	Clock_Flag							; 闹钟1分钟不匹配，闹钟未触发
	rts

L_Alarm2_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm2_Min
	beq		L_Alarm2_MinMatch
	bra		L_Alarm2_NoMatch					; 闹钟2分钟不匹配，判断闹钟1


L_Alarm1_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm1_SecMatch
	rmb1	Clock_Flag							; 若秒不匹配，则闹钟不触发并退出
	rts
Alarm1_SecMatch:
	lda		Alarm1_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; 若是周内全为工作日，则一定响闹
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm1_NoMatch					; 单休周天不响闹
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week
	beq		L_Alarm1_NoMatch					; 双休周天不响闹
	cmp		#6
	beq		L_Alarm1_NoMatch					; 双休周六也不响闹
?No_WorkDay_Juge:
	jsr		L_Alarm_Match_Handle
	lda		#001B
	sta		Triggered_AlarmGroup
	lda		R_Alarm1_Hour						; 将符合条件的闹钟的时、分同步至触发闹钟,方便后续的判断逻辑
	sta		R_Alarm_Hour
	lda		R_Alarm1_Min
	sta		R_Alarm_Min
	rts

L_Alarm2_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm2_SecMatch
	rmb1	Clock_Flag							; 若秒不匹配，则闹钟不触发并退出
	rts
Alarm2_SecMatch:
	lda		Alarm2_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; 若是周内全为工作日，则一定响闹
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; 单休周天不响闹
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; 双休周天不响闹
	cmp		#6
	beq		L_Alarm2_NoMatch					; 双休周六也不响闹
?No_WorkDay_Juge:
	jsr		L_Alarm_Match_Handle
	lda		#010B
	sta		Triggered_AlarmGroup
	lda		R_Alarm2_Hour						; 将符合条件的闹钟的时、分同步至触发闹钟,方便后续的判断逻辑
	sta		R_Alarm_Hour
	lda		R_Alarm2_Min
	sta		R_Alarm_Min
	rts




; 确定闹钟触发后的处理，打断当前的响闹
L_Alarm_Match_Handle:
	jsr		L_CloseLoud
	bbs4	Time_Flag,Alarm_Blocked
	smb1	Clock_Flag							; 同时满足小时和分钟的匹配，设置闹钟触发
Alarm_Blocked:
	smb4	Time_Flag							; 闹钟触发后，阻塞下一次1S内的闹钟触发
	rts




; X存商，A为余数
L_A_Div_3:
	ldx		#0
L_A_Div_3_Start:
	cmp		#3
	bcc		L_A_Div_3_Over
	sec
	sbc		#3
	inx
	bra		L_A_Div_3_Start
L_A_Div_3_Over:
	rts


; 将A左移X位
L_A_LeftShift_XBit:
	sta		P_Temp
Shift_Start:
	txa
	beq		Shift_End
	lda		P_Temp
	clc
	rol		P_Temp
	dex
	bra		Shift_Start
Shift_End:
	lda		P_Temp
	rts
