; 按键处理
F_KeyHandler:
	bbs2	Key_Flag,L_Key4Hz					; 快加到来则4Hz扫一次，控制快加频率
	bbr1	Key_Flag,L_KeyScan					; 首次按键触发
	rmb1	Key_Flag							; 复位首次触发
	jsr		L_KeyDelay
	lda		PA
	eor		#$3c								; 按键是反逻辑的，将指定的几位按键口取反
	and		#$3c
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
	bne		No_KeyUTrigger
	jmp		L_KeyUTrigger						; U键触发
No_KeyUTrigger:
	cmp		#$10
	bne		No_KeyDTrigger
	jmp		L_KeyDTrigger						; D键触发
No_KeyDTrigger:
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
	bbs0	SpecialKey_Flag,L_KeyS_ShortHandle	; 短按的特殊功能处理
	bbs1	SpecialKey_Flag,L_KeyU_ShortHandle
	bbs2	SpecialKey_Flag,L_KeyD_ShortHandle
	bbs3	SpecialKey_Flag,L_KeyF_ShortHandle

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


L_KeyD_ShortHandle:
	rts


L_KeyF_ShortHandle:
	lda		Sys_Status_Flag
	cmp		#1000B
	bne		No_SwitchState_AlarmSet				; 闹设模式切换设置内容
	jsr		SwitchState_AlarmSet
	rts
No_SwitchState_AlarmSet:
	jsr		SwitchState_AlarmDis				; 切换闹钟显示状态
	rts



; 按键触发函数，处理每个按键触发后的响应条件
L_KeyFTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

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
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

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
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

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
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

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



L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	inc		P_Temp
	bne		DelayLoop
	
	rts
