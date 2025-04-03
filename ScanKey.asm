; 按键处理
F_KeyHandler:
	bbs2	Key_Flag,L_Key4Hz					; 快加到来则4Hz扫一次，控制快加频率
	bbr1	Key_Flag,L_KeyScan					; 首次按键触发
	rmb1	Key_Flag							; 复位首次触发
	jsr		L_KeyDelay
	lda		PA
	eor		#$1c								; 按键是反逻辑的，将指定的几位按键口取反
	and		#$1c
	bne		L_KeyYes							; 检测是否有按键触发
	jmp		L_KeyNoScanExit
L_KeyYes:
	rmb4	IER									; 按键确定触发后，关闭中断避免误触发
	sta		PA_IO_Backup
	bra		L_KeyHandle							; 首次触发处理结束

L_Key4Hz:
	bbr2	Timer_Flag,L_KeyScanExit
	rmb2	Timer_Flag
L_KeyScan:										; 长按处理部分
	bbr0	Key_Flag,L_KeyNoScanExit			; 没有扫键标志则为无按键处理了，判断是否取消禁用RFC采样

	bbr4	Timer_Flag,L_KeyScanExit			; 没开始快加时，用16Hz扫描
	rmb4	Timer_Flag
	lda		PA
	eor		#$3c								; 按键是反逻辑的，将指定的几位按键口取反
	and		#$3c
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_4_32Hz_Count
	jsr		F_SpecialKey_Handle					; 长按终止时，进行一次特殊按键的处理
	bra		L_KeyExit
L_4_32Hz_Count:
	bbs2	Key_Flag,Counter_NoAdd				; 在快加触发后不再继续增加计数
	inc		QuickAdd_Counter					; 否则计数溢出后会导致不触发按键功能
Counter_NoAdd:
	lda		QuickAdd_Counter
	cmp		#64
	bcs		L_QuikAdd
	rts											; 长按计时，必须满2S才有快加
L_QuikAdd:
	bbs2	Key_Flag,NoQuikAdd_Beep
	jsr		L_KeyBeep_ON
NoQuikAdd_Beep:
	smb2	Key_Flag
	rmb2	Timer_Flag
	smb2	Timer_Switch						; 开启4Hz计时


L_KeyHandle:
	lda		PA
	eor		#$3c								; 按键是反逻辑的，将指定的几位按键口取反
	and		#$3c
	cmp		#$04
	bne		No_KeySTrigger						; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeySTrigger						; S键触发
No_KeySTrigger:
	cmp		#$08
	bne		No_KeyDTrigger
	jmp		L_KeyDTrigger						; D键触发
No_KeyDTrigger:
	cmp		#$10
	bne		No_KeyUTrigger
	jmp		L_KeyUTrigger						; U键触发
No_KeyUTrigger:
	cmp		#$20
	bne		L_KeyExit
	jmp		L_KeyFTrigger						; F键触发

L_KeyExit:
	rmb4	Timer_Switch						; 关闭32Hz、4Hz计时
	rmb2	Timer_Switch
	rmb0	Key_Flag							; 清相关标志位
	rmb2	Key_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
	sta		SpecialKey_Flag
	sta		Counter_DP
	rmb4	IFR									; 复位标志位,避免中断开启时直接进入中断服务
	smb4	IER									; 按键处理结束，重新开启PA口中断
L_KeyScanExit:
	rts

L_KeyNoScanExit:								; 没有扫键的情况下是空闲状态，此时判断是否取消禁用RFC采样
	bbs4	Key_Flag,L_KeyScanExit				; 按键音和响闹模式下，则不取消禁用
	bbs2	Clock_Flag,L_KeyScanExit
	rmb1	RFC_Flag							; 取消禁用RFC采样						
	rts


F_SpecialKey_Handle:							; 特殊按键的处理
	lda		SpecialKey_Flag
	bne		SpecialKey_Handle
	rts
SpecialKey_Handle:
	bbs2	Key_Flag,SpecialKey_NoBeep
	jsr		L_KeyBeep_ON
SpecialKey_NoBeep:
	bbs0	SpecialKey_Flag,L_KeyF_ShortHandle	; 短按的特殊功能处理
	bbs1	SpecialKey_Flag,L_KeyD_ShortHandle
	bbs2	SpecialKey_Flag,L_KeyM_ShortHandle
	bbs3	SpecialKey_Flag,L_KeyU_ShortHandle
	bbs4	SpecialKey_Flag,L_KeyS_ShortHandle
L_KeyF_ShortHandle:
	lda		Sys_Status_Flag
	cmp		#1000B
	bne		No_SwitchState_AlarmSet				; 闹设模式切换设置内容
	jsr		SwitchState_AlarmSet
	rts
No_SwitchState_AlarmSet:
	jsr		SwitchState_AlarmDis				; 切换闹钟显示状态
	rts

L_KeyD_ShortHandle:
	jsr		LightLevel_Change					; 三档亮度切换
	rts

L_KeyM_ShortHandle:
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		No_SwitchState_ClockSet
	jsr		SwitchState_ClockSet				; 时设模式切换设置内容
	rts
No_SwitchState_ClockSet:
	rts

L_KeyU_ShortHandle:
	lda		Sys_Status_Flag
	and		#0011B
	beq		KeyU_NoDisMode
	lda		#0001B
	sta		Sys_Status_Flag
	jsr		DM_SW_TimeMode						; 显示模式下切换12/24h模式
	rts
KeyU_NoDisMode:
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyU
	jsr		AddNum_CS							; 时设模式增数
	rts
StatusCS_No_KeyU:
	cmp		#1000B
	bne		KeyU_ShortHandle_Exit
	jsr		AddNum_AS							; 闹设模式增数
KeyU_ShortHandle_Exit:
	rts

L_KeyS_ShortHandle:
	lda		Sys_Status_Flag
	and		#0011B
	beq		KeyS_NoDisMode
	rts
KeyS_NoDisMode:
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyS_Short
	jsr		SubNum_CS							; 时设模式减数
	rts
StatusCS_No_KeyS_Short:
	cmp		#1000B
	bne		KeyS_ShortHandle_Exit
	jsr		SubNum_AS							; 闹设模式减数
KeyS_ShortHandle_Exit:
	rts



; 按键触发函数，处理每个按键触发后的响应条件
L_KeyFTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理贪睡和响闹

	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyF
	jmp		L_KeyExit							; 时钟设置模式A键无效
StatusCS_No_KeyF:
	cmp		#1000B
	bne		StatusAS_No_KeyF
	bbr2	Key_Flag,L_ASMode_KeyF_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; 闹钟设置模式A键长按无效
L_ASMode_KeyF_ShortTri:
	smb0	SpecialKey_Flag						; 闹设模式下，A键为特殊功能按键
	rts
StatusAS_No_KeyF:
	bbs2	Key_Flag,L_DisMode_KeyF_LongTri
	smb0	SpecialKey_Flag						; 显示模式下，A键为特殊功能按键
	rts
L_DisMode_KeyF_LongTri:
	jsr		SwitchState_AlarmSet				; 从显示模式切换到闹钟设置模式
	jmp		L_KeyExit							; 快加时，不重复执行功能函数


L_KeyDTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理

	bbr2	Clock_Flag,StatusLM_No_KeyD
	jmp		L_KeyExit
StatusLM_No_KeyD:
	bbs2	Key_Flag,L_DisMode_KeyD_LongTri
	smb1	SpecialKey_Flag
	rts
L_DisMode_KeyD_LongTri:
	jsr		TemperMode_Change					; 切换摄氏-华氏度
	jmp		L_KeyExit							; 快加时，不重复执行功能函数


L_KeyMTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理贪睡和响闹

	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyM
	bbr2	Key_Flag,L_CSMode_KeyM_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; 时设模式M键长按无效
L_CSMode_KeyM_ShortTri:
	smb2	SpecialKey_Flag
	rts
StatusCS_No_KeyM:
	cmp		#1000B
	bne		StatusAS_No_KeyM
	jmp		L_KeyExit							; 闹设模式M键无效
StatusAS_No_KeyM:
	bbs2	Key_Flag,L_DisMode_KeyM_LongTri		; 判断显示模式下的M长按
	lda		Sys_Status_Flag
	and		#0011B
	beq		StatusDM_No_KeyM
	smb2	SpecialKey_Flag						; 显示模式下，M键为特殊功能按键
StatusDM_No_KeyM:
	rts
L_DisMode_KeyM_LongTri:
	jsr		SwitchState_ClockSet				; 从显示模式切换到时间设置模式
	jmp		L_KeyExit							; 快加时，不重复执行功能函数


L_KeyUTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理贪睡和响闹

	lda		Sys_Status_Flag
	and		#0011B
	beq		Status_NoDisMode_KeyU				; 时钟显和闹显U键切换12/24h
	bbr2	Key_Flag,L_DMode_KeyU_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; 显示模式U键长按无效
L_DMode_KeyU_ShortTri:
	smb3	SpecialKey_Flag
	rts
Status_NoDisMode_KeyU:
	bbr2	Key_Flag,KeyU_NoQuikAdd
	rmb3	SpecialKey_Flag
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyU_Short
	jmp		AddNum_CS							; 时设模式增数
StatusCS_No_KeyU_Short:
	cmp		#1000B
	bne		L_KeyUTrigger_Exit
	jmp		AddNum_AS							; 闹设模式增数
KeyU_NoQuikAdd:
	smb3	SpecialKey_Flag
L_KeyUTrigger_Exit:
	rts


L_KeySTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理贪睡和响闹

	lda		Sys_Status_Flag
	and		#0011B
	beq		Status_NoDisMode_KeyS				; 判断是否为显示模式
	bbr2	Key_Flag,L_DMode_KeyS_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; 显示模式D键长按无效
L_DMode_KeyS_ShortTri:
	smb4	SpecialKey_Flag
	rts
Status_NoDisMode_KeyS:
	bbr2	Key_Flag,KeyS_NoQuikAdd
	rmb4	SpecialKey_Flag
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyS
	jmp		SubNum_CS							; 时设模式减数
StatusCS_No_KeyS:
	cmp		#1000B
	bne		L_KeySTrigger_Exit
	jmp		SubNum_AS							; 闹设模式减数
KeyS_NoQuikAdd:
	smb4	SpecialKey_Flag
L_KeySTrigger_Exit:
	rts


; 按键打断贪睡和响闹
L_Key_ShutdownLoud:
	bbs2	Clock_Flag,?No_AlarmLouding
	jsr		L_CloseLoud							; 打断响闹
	pla
	pla
	jmp		L_KeyExit
?No_AlarmLouding:
	rts


; 按键触发通用功能，包括按键矩阵GPIO状态重置，唤醒屏幕
; 同时会给出是否存在唤醒事件
; 由于打断贪睡和响闹的功能B键没有，故不在本函数内处理
L_Universal_TriggerHandle:
	lda		#0
	sta		Return_Counter						; 重置返回时显模式计时

	bbs4	PD,WakeUp_Event						; 若此时熄屏，按键会导致亮屏
	bbs2	Key_Flag,?Handle_Exit
	rmb5	Time_Flag
	lda		#0
	sta		Backlight_Counter
?Handle_Exit:
	rts
WakeUp_Event:
	rmb4	PD
	smb3	Key_Flag							; 熄屏状态有按键，则触发唤醒事件
	lda		#0
	sta		Sys_Status_Ordinal					; 时钟显示模式下熄屏亮屏会回到时显
	jsr		L_Open_5020							; 亮屏开启LCD中断
	bbr2	Backlight_Flag,No_RFCMesure_KeyDeep	; 手动熄屏不会测量温湿度
	rmb2	Backlight_Flag
	jsr		F_RFC_MeasureStart					; 自动熄屏唤醒后立刻进行一次温湿度测量
No_RFCMesure_KeyDeep:
	pla
	pla
	jmp		L_KeyExit							; 唤醒触发的那次按键，没有按键功能
WakeUp_Event_Exit:
	rts


L_KeyBeep_ON:
	lda		#10B								; 设置按键提示音的响铃序列
	sta		Beep_Serial
	smb4	Key_Flag							; 置位按键提示音标志
	smb3	Timer_Switch
	rts

L_KeyBeep_OFF:
	lda		#0									; 清除按键提示音的响铃序列
	sta		Beep_Serial
	rmb4	Key_Flag							; 复位按键提示音标志
	rmb3	Timer_Switch
	rts




; 切换到闹钟显示状态
SwitchState_AlarmDis:
	lda		#5
	sta		Return_MaxTime						; 设置模式，5S返回时显

	lda		Sys_Status_Flag
	cmp		#00010B
	beq		L_Change_Group_AD					; 判断当前状态是否已经是闹钟显示
	lda		#00010B
	sta		Sys_Status_Flag						; 当前状态非闹显则切换至闹显
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号和闹钟组
	sta		Alarm_Group
	rts
L_Change_Group_AD:
	inc		Alarm_Group							; 当前状态为闹显，则递增闹钟组
	lda		Alarm_Group
	cmp		#2
	bcc		L_Group_Exit_AD
	lda		#0
	sta		Alarm_Group							; 闹钟组大于1时，回到时显模式
L_Group_Exit_AD:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到时钟设置模式
SwitchState_ClockSet:
	lda		#10
	sta		Return_MaxTime						; 设置模式，10S返回时显

	lda		Sys_Status_Flag
	cmp		#0100B
	beq		L_Change_Ordinal_CS					; 判断当前状态是否已经是时钟设置
	lda		#0100B
	sta		Sys_Status_Flag						; 当前状态非时设则切换至时设
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号
	bra		L_Ordinal_Exit_CS
L_Change_Ordinal_CS:
	inc		Sys_Status_Ordinal					; 当前状态为时设，则递增子模式序号
	lda		Sys_Status_Ordinal
	cmp		#6
	bcc		L_Ordinal_Exit_CS
Return_CD_Mode:
	lda		#0
	sta		Sys_Status_Ordinal					; 子模式序号大于5时，则回到时显模式，并清空序号
	lda		#0001B
	sta		Sys_Status_Flag
L_Ordinal_Exit_CS:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到闹钟设置模式
SwitchState_AlarmSet:
	lda		#10
	sta		Return_MaxTime						; 设置模式，10S返回时显

	lda		Sys_Status_Flag
	cmp		#1000B
	beq		L_Change_Ordinal_AS					; 判断当前状态是否已经是闹钟设置
	bbr1	Sys_Status_Flag,No_AlarmDis2Set
	lda		#1000B
	sta		Sys_Status_Flag						; 当前状态非闹设则切换至闹设
	lda		Sys_Status_Ordinal					; 若当前处于闹显状态
	clc
	rol
	clc
	adc		Sys_Status_Ordinal					; 则对当前显示的闹组设置
	sta		Sys_Status_Ordinal
	bra		L_Ordinal_Exit_AS
No_AlarmDis2Set:
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号
	lda		#1000B
	sta		Sys_Status_Flag						; 当前状态非闹设则切换至闹设
	bra		L_Ordinal_Exit_AS
L_Change_Ordinal_AS:
	inc		Sys_Status_Ordinal					; 当前状态为闹设，则递增子模式序号
	lda		Sys_Status_Ordinal
	cmp		#4
	bcc		L_Ordinal_Exit_AS
	lda		#0
	sta		Sys_Status_Ordinal					; 子模式序号大于3时，则回到时显模式，并清空序号
	lda		#0001B
	sta		Sys_Status_Flag
L_Ordinal_Exit_AS:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到正计时模式
SwitchState_TimeUpMode:
	lda		#%10000
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal
	sta		Timekeep_Flag
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	sta		Timekeep_NumberSet
	jsr		F_ClearScreen
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts


; 切换到倒计时模式
SwitchState_TimeDownMode:
	lda		#%10000
	sta		Sys_Status_Flag
	lda		#1
	sta		Sys_Status_Ordinal
	sta		Timekeep_Flag
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	sta		Timekeep_NumberSet
	jsr		F_ClearScreen
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换三档灯光亮度
; 0低亮，1半亮，2高亮
LightLevel_Change:
	inc		Light_Level
	lda		Light_Level
	cmp		#3
	bcs		LightLevel_Auto
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts
LightLevel_Auto:
	lda		#0
	sta		Light_Level
	smb3	Backlight_Flag
	nop											; 切换至自动亮度
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 时钟设置下的12、24h模式切换
ClockSet_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; 翻转12/24h模式的状态
	sta		Clock_Flag

	jsr		L_Dis_xxHr
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts

; 显示模式下12、24h模式切换
DM_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; 翻转12/24h模式的状态
	sta		Clock_Flag

	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换温度单位
TemperMode_Change:
	lda		RFC_Flag							; 取反标志位，切换华氏度和摄氏度
	eor		#00010000B
	sta		RFC_Flag
	jsr		F_Display_Temper					; 更新温度单位和温度

	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 时设模式增数
AddNum_CS:
	lda		Sys_Status_Ordinal
	bne		No_CS_TMSwitch
	jmp		ClockSet_SW_TimeMode
No_CS_TMSwitch:
	cmp		#1
	bne		No_CS_HourAdd
	jmp		L_TimeHour_Add
No_CS_HourAdd:
	cmp		#2
	bne		No_CS_MinAdd
	jmp		L_TimeMin_Add
No_CS_MinAdd:
	cmp		#3
	bne		No_CS_YearAdd
	jmp		L_DateYear_Add
No_CS_YearAdd:
	cmp		#4
	bne		No_CS_MonthAdd
	jmp		L_DateMonth_Add
No_CS_MonthAdd:
	jmp		L_DateDay_Add




; 闹设模式增数
AddNum_AS:
	ldx		Alarm_Group
	lda		Sys_Status_Ordinal
	bne		No_AlarmSwitch_AddCHG
	lda		#1
	jsr		L_A_LeftShift_XBit
	jmp		L_Alarm_Switch
No_AlarmSwitch_AddCHG:
	cmp		#1
	bne		No_AlarmHourSet_Add
	jmp		L_AlarmHour_Add						; 闹钟小时减数
No_AlarmHourSet_Add:
	cmp		#2
	bne		No_AlarmWorkdaySet_Add
	jmp		L_AlarmMin_Add						; 闹钟分钟减数
No_AlarmWorkdaySet_Add:
	jmp		L_AlarmWorkDay_Add



; 时设模式减数
SubNum_CS:
	lda		Sys_Status_Ordinal
	bne		No_CS_TMSwitch2
	jmp		ClockSet_SW_TimeMode
No_CS_TMSwitch2:
	cmp		#1
	bne		No_CS_HourSub
	jmp		L_TimeHour_Sub
No_CS_HourSub:
	cmp		#2
	bne		No_CS_MinSub
	jmp		L_TimeMin_Sub
No_CS_MinSub:
	cmp		#3
	bne		No_CS_YearSub
	jmp		L_DateYear_Sub
No_CS_YearSub:
	cmp		#4
	bne		No_CS_MonthSub
	jmp		L_DateMonth_Sub
No_CS_MonthSub:
	jmp		L_DateDay_Sub




; 闹设模式减数
SubNum_AS:
	ldx		Alarm_Group
	lda		Sys_Status_Ordinal
	cmp		#0
	bne		No_AlarmSwitch_SubCHG
	lda		#1
	jsr		L_A_LeftShift_XBit
	jmp		L_Alarm_Switch
No_AlarmSwitch_SubCHG:
	cmp		#1
	bne		No_AlarmHourSet_Sub
	jmp		L_AlarmHour_Sub						; 闹钟小时减数
No_AlarmHourSet_Sub:
	cmp		#2
	bne		No_AlarmWorkdaySet_Sub
	jmp		L_AlarmMin_Sub						; 闹钟分钟减数
No_AlarmWorkdaySet_Sub:
	jmp		L_AlarmWorkDay_Sub




; 时增加
L_TimeHour_Add:
	lda		R_Time_Hour
	cmp		#23
	bcs		TimeHour_AddOverflow
	inc		R_Time_Hour
	bra		TimeHour_Add_Exit
TimeHour_AddOverflow:
	lda		#0
	sta		R_Time_Hour
TimeHour_Add_Exit:
	;jsr		L_LightLevel_WithKeyU
	;jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 时减少
L_TimeHour_Sub:
	lda		R_Time_Hour
	beq		TimeHour_SubOverflow
	dec		R_Time_Hour
	bra		TimeHour_Sub_Exit
TimeHour_SubOverflow:
	lda		#23
	sta		R_Time_Hour
TimeHour_Sub_Exit:
	;jsr		L_LightLevel_WithKeyD
	;jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 分增加
L_TimeMin_Add:
	lda		#0
	sta		R_Time_Sec							; 调整分钟会清空秒

	lda		R_Time_Min
	cmp		#59
	bcs		TimeMin_AddOverflow
	inc		R_Time_Min
	bra		TimeMin_Add_Exit
TimeMin_AddOverflow:
	lda		#0
	sta		R_Time_Min
TimeMin_Add_Exit:
	;jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 分减少
L_TimeMin_Sub:
	lda		#0
	sta		R_Time_Sec							; 调整分钟会清空秒

	lda		R_Time_Min
	beq		TimeMin_SubOverflow
	dec		R_Time_Min
	bra		TimeMin_Sub_Exit
TimeMin_SubOverflow:
	lda		#59
	sta		R_Time_Min
TimeMin_Sub_Exit:
	;jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 年增加
L_DateYear_Add:
	lda		R_Date_Year
	cmp		#99
	bcs		DateYear_AddOverflow
	inc		R_Date_Year
	bra		DateYear_Add_Exit
DateYear_AddOverflow:
	lda		#0
	sta		R_Date_Year
DateYear_Add_Exit:
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	jsr		F_Is_Leap_Year
	;jsr		L_DisDate_Year
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 年减少
L_DateYear_Sub:
	lda		R_Date_Year
	beq		DateYear_SubOverflow
	dec		R_Date_Year
	bra		DateYear_Sub_Exit
DateYear_SubOverflow:
	lda		#99
	sta		R_Date_Year
DateYear_Sub_Exit:
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	jsr		F_Is_Leap_Year
	;jsr		L_DisDate_Year
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 月增加
L_DateMonth_Add:
	lda		R_Date_Month
	cmp		#12
	bcs		DateMonth_AddOverflow
	inc		R_Date_Month
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	bra		DateMonth_Add_Exit
DateMonth_AddOverflow:
	lda		#1
	sta		R_Date_Month
DateMonth_Add_Exit:
	;jsr		F_Date_Display
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 月减少
L_DateMonth_Sub:
	lda		R_Date_Month
	cmp		#1
	beq		DateMonth_SubOverflow
	dec		R_Date_Month
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	bra		DateMonth_Sub_Exit
DateMonth_SubOverflow:
	lda		#12
	sta		R_Date_Month
DateMonth_Sub_Exit:
	;jsr		F_Date_Display
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 日增加
L_DateDay_Add:
	inc		R_Date_Day
	jsr		L_DayOverflow_To_1					; 若当前日期超过当前月份允许的最大值，则日期变为1日
	;jsr		F_Date_Display
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 日减少
L_DateDay_Sub:
	lda		R_Date_Day
	cmp		#1
	beq		DateDay_SubOverflow
	dec		R_Date_Day
	bra		DateDay_Sub_Exit
DateDay_SubOverflow:
	bbr0	Calendar_Flag,Common_Year_Get
	ldx		R_Date_Month
	dex
	lda		L_Table_Month_Leap,x
	sta		R_Date_Day
	bra		DateDay_Sub_Exit
Common_Year_Get:
	ldx		R_Date_Month
	dex
	lda		L_Table_Month_Common,x
	sta		R_Date_Day
DateDay_Sub_Exit:
	;jsr		F_Date_Display
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts





; 闹钟开关
; A闹钟组（按bit）
L_Alarm_Switch:
	eor		Alarm_Switch
	sta		Alarm_Switch
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_Alarm_SwitchStatue				; 刷新一次闹钟开关显示
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟分增加
; X闹钟组，0~1
L_AlarmMin_Add:
	lda		Alarm_MinAddr,x
	cmp		#59
	bcs		AlarmMin_AddOverflow
	clc
	adc		#1
	sta		Alarm_MinAddr,x
	bra		AlarmMin_Add_Exit
AlarmMin_AddOverflow:
	lda		#0
	sta		Alarm_MinAddr,x
AlarmMin_Add_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmMin_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟分减少
; X闹钟组，0~1
L_AlarmMin_Sub:
	lda		Alarm_MinAddr,x
	beq		AlarmMin_SubOverflow
	sec
	sbc		#1
	sta		Alarm_MinAddr,x
	bra		AlarmMin_Sub_Exit
AlarmMin_SubOverflow:
	lda		#59
	sta		Alarm_MinAddr,x
AlarmMin_Sub_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmMin_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟时增加
; X闹钟组，0~1
L_AlarmHour_Add:
	lda		Alarm_HourAddr,x
	cmp		#23
	bcs		AlarmHour_AddOverflow
	clc
	adc		#1
	sta		Alarm_HourAddr,x
	bra		AlarmHour_Add_Exit
AlarmHour_AddOverflow:
	lda		#0
	sta		Alarm_HourAddr,x
AlarmHour_Add_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmHour_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟时减少
; X闹钟组，0~1
L_AlarmHour_Sub:
	lda		Alarm_HourAddr,x
	beq		AlarmHour_SubOverflow
	sec
	sbc		#1
	sta		Alarm_HourAddr,x
	bra		AlarmHour_Sub_Exit
AlarmHour_SubOverflow:
	lda		#23
	sta		Alarm_HourAddr,x
AlarmHour_Sub_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmHour_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟工作日增加
; X闹钟组，0~1
L_AlarmWorkDay_Add:
	lda		Alarm_WorkDayAddr,x
	cmp		#2
	bcs		AlarmWorkDay_AddOverflow
	clc
	adc		#1
	sta		Alarm_WorkDayAddr,x
	bra		AlarmWorkDay_Add_Exit
AlarmWorkDay_AddOverflow:
	lda		#0
	sta		Alarm_WorkDayAddr,x
AlarmWorkDay_Add_Exit:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟工作日减少
; X闹钟组，0~1
L_AlarmWorkDay_Sub:
	lda		Alarm_WorkDayAddr,x
	beq		AlarmWorkDay_SubOverflow
	sec
	sbc		#1
	sta		Alarm_WorkDayAddr,x
	bra		AlarmWorkDay_Sub_Exit
AlarmWorkDay_SubOverflow:
	lda		#2
	sta		Alarm_WorkDayAddr,x
AlarmWorkDay_Sub_Exit:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 倒计时模式设置计时时间
Timekeep_NumSet:
	lda		Timekeep_NumberSet
	ror											; 通过Timekeep_NumberSet的第一位判断是设置十位还是个位
	bcs		SetSingle_Number
	tax											; 设置分/秒的十位数
	lda		P_Temp
	jsr		L_LSR_4Bit
	sta		P_Temp								; 设置的数字左移到十位

	lda		TimekeepAddr,x
	and		#$0f
	ora		P_Temp
	sta		TimekeepAddr,x
	bra		NumSet_Inc
SetSingle_Number:								; 设置分/秒的个位数
	tax
	lda		TimekeepAddr,x
	and		#$f0
	ora		P_Temp
	sta		TimekeepAddr,x
NumSet_Inc:
	inc		Timekeep_NumberSet					; 每次设置完后递增Timekeep_NumberSet
	lda		Timekeep_NumberSet
	cmp		#4
	bcc		NumSet_Exit
	lda		#0
	sta		Timekeep_NumberSet					; 溢出后回到0
NumSet_Exit:
	rts




; 计时模式下启停计时
Timekeep_Pause_Continue:
	lda		Timekeep_Flag
	eor		#%01
	sta		Timekeep_Flag

	bbr0	Sys_Status_Ordinal,TimeDown_BakOver
	bbs0	Timekeep_Flag,TimeDown_BakOver
	lda		R_Timekeep_Min						; 倒计时模式下若计时开始，会备份一次初值，若计时完成会还原
	sta		R_TimekeepBak_Min
	lda		R_Timekeep_Sec
	sta		R_TimekeepBak_Sec
TimeDown_BakOver:
	rts


; 计时模式下清空计时
Timekeep_ClearCount:
	lda		#0
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	rts




; 天数上溢的判断（不增加）
L_DayOverflow_Juge:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle		; 平年闰年的表分开查
	ldx		R_Date_Month						; 查平年每月份天数表
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge
L_LeapYear_Handle:
	ldx		R_Date_Month						; 查闰年每月份天数表
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge:
	lda		P_Temp								; 当前日期和天数表的日期对比
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow
	lda		P_Temp
	sta		R_Date_Day
DateDay_NoOverflow:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 天数上溢的判断（回到1日）
L_DayOverflow_To_1:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle2	; 平年闰年的表分开查
	ldx		R_Date_Month						; 查平年每月份天数表
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge2
L_LeapYear_Handle2:
	ldx		R_Date_Month						; 查闰年每月份天数表
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge2:
	lda		P_Temp								; 当前日期和天数表的日期对比
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow2
	lda		#1
	sta		R_Date_Day
DateDay_NoOverflow2:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	inc		P_Temp
	lda		P_Temp
	cmp		#129
	bcc		DelayLoop
	
	rts
