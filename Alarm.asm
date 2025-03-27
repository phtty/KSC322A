F_Alarm_GroupDis:
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

AlarmGroupHandle_Table:
	dw		F_Display_Alarm-1
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
	jsr		L_Control_ALDot

	bbs1	Symbol_Flag,L_AlarmDot_Out
	rts
L_AlarmDot_Out:									; 闪烁当前闹组
	rmb1	Symbol_Flag
	bbs0	Symbol_Flag,No_ALDot_Display
	lda		Alarm_Group
	clc
	adc		#2
	jmp		L_Control_ALDot						; 当前组AL点半秒亮
No_ALDot_Display:
	rmb0	Symbol_Flag
	lda		Alarm_Group
	jmp		L_Control_ALDot						; 当前组AL点1秒灭




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
	jmp		F_UnDisplay_D0_1
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
	bbs0	Timer_Flag,L_AlarmHour_Clear
L_AlarmHour_Display:
	jmp		F_Display_Alarm
L_AlarmHour_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jmp		F_UnDisplay_D0_1




F_AlarmMin_Set:
	bbs1	Timer_Flag,L_AlarmMin_Set
	rts
L_AlarmMin_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmMin_Display			; 有快加时直接常亮
	bbs0	Timer_Flag,L_AlarmMin_Clear
L_AlarmMin_Display:
	jmp		F_Display_Alarm
L_AlarmMin_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jmp		F_UnDisplay_D2_3




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
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts
L_AlarmWorkDay_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D0_1
	jmp		F_UnDisplay_D2_3




F_Alarm_Handler:
	jsr		L_IS_AlarmTrigger					; 判断闹钟是否触发
	bbr2	Clock_Flag,L_No_Alarm_Process		; 有响闹标志位再进处理
	jsr		L_Alarm_Process
	rts
L_No_Alarm_Process:
	bbs4	Key_Flag,L_LoudingNoClose			; 如果有按键提示音，则不关闭蜂鸣器
	rmb1	PADF0								; PB3 PWM输出控制
	rmb4	PADF0								; PB3配置为IO口
	rmb3	PB_TYPE								; PB3选择NMOS输出1避免漏电
	smb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
L_LoudingNoClose:
	lda		#0
	sta		AlarmLoud_Counter
	rts

L_IS_AlarmTrigger:
	lda		Alarm_Switch
	bne		Alarm_Juge_Start					; 没有任何闹钟开启则不会继续判断
	rmb1	Clock_Flag
	rts
Alarm_Juge_Start:
	bbs2	Clock_Flag,L_Alarm_NoStop			; 如此时仍在响闹，则直接进入响闹持续部分
	jsr		Is_Alarm_Trigger					; 判断三组闹钟触发
	bbr1	Clock_Flag,Is_Snooze				; 有闹钟触发标志位才会继续判断，否则判断贪睡
L_Start_Loud_Juge:
	lda		R_Alarm_Hour						; 触发闹钟时，同步触发的那组闹钟至贪睡闹钟
	sta		R_Snooze_Hour						; 之后贪睡触发时只需要在贪睡闹钟的基础上加5min
	lda		R_Alarm_Min
	sta		R_Snooze_Min
	bra		L_AlarmTrigger
Is_Snooze:
	bbs3	Clock_Flag,L_Snooze					; 先判断闹钟是否触发，再判断是否存在贪睡
	rts											; 如既无闹钟触发，又无贪睡，则不需要闹钟处理，直接退出
L_Snooze:
	lda		R_Time_Hour							; 贪睡模式下,用贪睡闹钟和当前时钟匹配
	cmp		R_Snooze_Hour						; 贪睡闹钟和当前时间不匹配不会进响闹模式
	bne		L_Snooze_CloseLoud
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_Snooze_CloseLoud
	bbs2	Clock_Flag,L_Alarm_NoStop
	lda		R_Time_Sec
	cmp		#00
	bne		L_Snooze_CloseLoud
L_AlarmTrigger:
	jsr		F_RFC_Abort							; 终止RFC采样并配置定时器为响闹模式
	smb1	Time_Flag
	smb0	TMRC								; 响铃定时器TIM0开启
	smb2	Clock_Flag							; 开启响闹模式
	rmb1 	Clock_Flag							; 关闭闹钟触发标志，避免重复进闹钟触发
L_Alarm_NoStop:
	bbs5	Clock_Flag,L_AlarmTrigger_Exit
	smb5	Clock_Flag							; 保存响闹模式的值,区分响闹结束状态和未响闹状态
L_AlarmTrigger_Exit:
	rts
L_Snooze_CloseLoud:
	bbr5	Clock_Flag,L_AlarmTrigger_Exit		; last==1 && now==0
	rmb5	Clock_Flag							; 响闹结束状态同步响闹模式的保存值
	bbr6	Clock_Flag,L_NoSnooze_CloseLoud		; 没有贪睡按键触发&&贪睡模式&&响闹结束状态才会自然结束贪睡模式
	rmb6	Clock_Flag							; 清贪睡按键触发
	bra		L_CloseLoud
L_NoSnooze_CloseLoud:							; 结束贪睡模式并关闭响闹
	rmb3	Clock_Flag
	rmb6	Clock_Flag
	rmb1	RFC_Flag							; 取消禁用RFC采样
	lda		#0
	sta		Triggered_AlarmGroup
L_CloseLoud:
	lda		#0
	sta		AlarmLoud_Counter
	rmb1	Clock_Flag							; 关闭闹钟触发标志
	rmb2	Clock_Flag							; 关闭响闹模式
	rmb5	Clock_Flag

	bbs4	Key_Flag,L_LoudingJuge_Exit			; 如果有按键提示音，则不关闭蜂鸣器
	rmb1	PADF0								; PB3 PWM输出控制
	rmb4	PADF0								; PB3配置为IO口
	rmb3	PB_TYPE								; PB3选择NMOS输出1避免漏电
	smb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
	rmb0	TMRC
L_LoudingJuge_Exit:
	rts




L_Alarm_Process:
	bbs1	Time_Flag,L_BeepStart				; 每响铃1S进一次
	rts
L_BeepStart:
	rmb1	Time_Flag
	lda		AlarmLoud_Counter
	cmp		#60
	beq		L_NoSnooze_CloseLoud				; 响铃60S后关闭响闹
	lda		#8									; 响闹的序列为8，4声
	sta		Beep_Serial
	inc		AlarmLoud_Counter
	rts


; 任意一组闹钟设定值的时、分符合当前时间，就设置闹钟触发标志位,并同步至触发闹钟
; 优先判断闹钟3，其次闹钟2，最后闹钟1
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
	rmb1	Clock_Flag							; 闹钟3也不匹配，闹钟未触发
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
	bra		L_Alarm2_NoMatch					; 闹钟2分钟不匹配，判断闹钟2


L_Alarm1_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm1_SecMatch
	rmb1	Clock_Flag							; 若秒不匹配，则闹钟不触发并退出
	rts
Alarm1_SecMatch:
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
	jsr		L_Alarm_Match_Handle
	lda		#010B
	sta		Triggered_AlarmGroup
	lda		R_Alarm2_Hour						; 将符合条件的闹钟的时、分同步至触发闹钟,方便后续的判断逻辑
	sta		R_Alarm_Hour
	lda		R_Alarm2_Min
	sta		R_Alarm_Min
	rts




; 确定闹钟触发后的处理，若当前在贪睡，则要重置贪睡状态
L_Alarm_Match_Handle:
	jsr		L_NoSnooze_CloseLoud
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
