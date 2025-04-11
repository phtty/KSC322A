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
	;jsr		F_SpecialKey_Handle					; 长按终止时，进行一次特殊按键的处理
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

KeyS_ShortHandle_Exit:
	rts


L_KeyU_ShortHandle:

KeyU_ShortHandle_Exit:
	rts


L_KeyD_ShortHandle:
	rts


L_KeyF_ShortHandle:

No_SwitchState_AlarmSet:
	rts




; 按键触发函数，处理每个按键触发后的响应条件
L_KeySTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

	lda		Sys_Status_Flag
	and		#%00101								; 时钟模式切换到设置模式
	beq		?No_CS_Mode
	jsr		SwitchState_ClockSet
	jmp		L_KeyExit							; 只执行1次按键功能
?No_CS_Mode:
	lda		Sys_Status_Flag
	and		#%01010								; 闹钟模式切换到设置模式
	beq		L_KeySTrigger_Exit
	jsr		SwitchState_AlarmSet
L_KeySTrigger_Exit:
	jmp		L_KeyExit


L_KeyUTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

	lda		Sys_Status_Flag
	and		#%10011
	beq		Status_NoDisMode_KeyU
	jsr		LightLevel_Change					; 显示模式U键亮度切换
	jmp		L_KeyExit
Status_NoDisMode_KeyU:
	lda		Sys_Status_Flag
	cmp		#%00100
	bne		StatusCS_No_KeyU
	jmp		AddNum_CS							; 时设模式增数
StatusCS_No_KeyU:
	cmp		#%01000
	bne		L_KeyUTrigger_Exit
	jmp		AddNum_AS							; 闹设模式增数
L_KeyUTrigger_Exit:
	rts


L_KeyDTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

	lda		Sys_Status_Flag
	and		#%00011
	beq		Status_NoDisMode_KeyD
	jsr		TemperMode_Change					; 显示模式D键温度单位切换
	jmp		L_KeyExit
Status_NoDisMode_KeyD:
	lda		Sys_Status_Flag
	cmp		#%00100
	bne		StatusCS_No_KeyD
	jmp		SubNum_CS							; 时设模式减数
StatusCS_No_KeyD:
	cmp		#%01000
	bne		L_KeyDTrigger_Exit
	jmp		SubNum_AS							; 闹设模式减数
L_KeyDTrigger_Exit:
	rts


L_KeyFTrigger:
	jsr		L_Universal_TriggerHandle			; 通用按键处理
	jsr		L_Key_ShutdownLoud					; 按键处理响闹

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jsr		Return_CD_Mode						; 设置模式会返回时显
	jmp		L_KeyExit
?No_SetMode:
	bbs4	Sys_Status_Flag,L_KeyFTrigger_Exit	; 计时模式无效
	jsr		SwitchState_AlarmDis				; 显示模式会进入闹显切换
L_KeyFTrigger_Exit
	jmp		L_KeyExit							; 快加时，不重复执行功能函数





; 按键打断响闹
L_Key_ShutdownLoud:
	bbr2	Clock_Flag,?No_AlarmLouding
	jsr		L_CloseLoud							; 打断响闹
	pla
	pla
	jmp		L_KeyExit
?No_AlarmLouding:
	rts


; 按键触发通用功能，包括按键矩阵GPIO状态重置，唤醒屏幕
; 同时会给出是否存在唤醒事件
L_Universal_TriggerHandle:
	lda		#0
	sta		Return_Counter						; 重置返回时显模式计时

	bbr1	Backlight_Flag,KeyWakeUp_Event			; 若此时熄屏，按键会导致亮屏
	jsr		L_KeyBeep_ON
	rts
KeyWakeUp_Event:
	bbs4	Sys_Status_Flag,?Timekeep_Mode
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal					; 按键唤醒熄屏后会回到时间显示模式
?Timekeep_Mode:
	REFLASH_DISPLAY
	smb1	Backlight_Flag
	pla
	pla
	jmp		L_KeyExit							; 熄屏唤醒的那次按键，没有按键功能




L_KeyBeep_ON:
	lda		#%10								; 设置按键提示音的响铃序列
	sta		Beep_Serial
	smb4	Key_Flag							; 置位按键提示音标志
	jsr		F_RFC_Abort							; 避免电压不稳定导致RFC采样误差
	smb3	Timer_Switch
	lda		#0
	sta		Counter_21Hz
	rts

;L_KeyBeep_OFF:
;	lda		#0									; 清除按键提示音的响铃序列
;	sta		Beep_Serial
;	rmb4	Key_Flag							; 复位按键提示音标志
;	rmb3	Timer_Switch
;	rts



L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	inc		P_Temp
	bne		DelayLoop
	
	rts
