IR_ReceiveHandle:
	jsr		RepeatCode_Handle

	lda		IR_ReceivePhase
	clc
	rol
	tax
	lda		Receive_Phase_Table+1,x
	pha
	lda		Receive_Phase_Table,x
	pha
	rts										; 根据当前收码阶段，跳转到对应的收码处理函数

Receive_Phase_Table:
	dw		IR_Receive_Phase_0-1
	dw		IR_Receive_Phase_1-1
	dw		IR_Receive_Phase_2-1
	dw		IR_Receive_Phase_3-1
	dw		IR_Receive_Phase_4-1
	dw		IR_Receive_Phase_5-1



; 收码阶段0，空闲时运行，下降沿到来时开始收码
IR_Receive_Phase_0:
	lda		PD
	and		#$10
	beq		IR_Turn2Phase1
	rts
IR_Turn2Phase1:
	;lda		#$2c							; 测试用，PA4输出
	;sta		PA
	lda		#1
	sta		IR_ReceivePhase					; 收码进入阶段1
	smb3	IR_Flag							; IR开始计数

	lda		#0
	sta		IR_Counter						; 初始化变量
	lda		#32
	sta		Code_Counter
	rts


; 收码阶段1，检测引导码/重复码的第一个电平时间是否合法
IR_Receive_Phase_1:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#60
	bcc		Phase1_Abort					; 下溢，终止收码
	lda		#80
	cmp		IR_Counter
	bcc		Phase1_Abort					; 上溢，终止收码
	lda		#2
	sta		IR_ReceivePhase					; 收码进入阶段2
	lda		#0
	sta		IR_Counter
	rts
Phase1_Abort:
;	bbs5	IR_Flag,?No_Mark				; 测试用代码
;	smb0	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; 收码阶段2，区分是引导码还是重复码
IR_Receive_Phase_2:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#30
	bcc		Phase2_NoGuid					; 引导码下溢，判断是否为重复码
	lda		#38
	cmp		IR_Counter
	bcc		Phase2_Abort					; 引导码上溢，终止收码
	lda		#3
	sta		IR_ReceivePhase					; 收码进入阶段3
	lda		#0
	sta		IR_Counter
	rts
Phase2_NoGuid:
	lda		IR_Counter
	cmp		#14
	bcc		Phase2_Abort					; 重复码下溢，终止收码
	lda		#22
	cmp		IR_Counter
	bcc		Phase2_Abort					; 重复码上溢，终止收码
	lda		Repeat_Counter
	cmp		#19
	bcs		RepeatCounter_NoAdd
	inc		Repeat_Counter					; 收到重复码递增重复码计数，上限19个
RepeatCounter_NoAdd:
	;lda		#5
	;sta		Interval_Counter				; 刷新重复码间隔超时计数
	lda		#5
	sta		IR_ReceivePhase					; 若收到重复码，收码也算成功，复位收码的相应资源
	sta		IR_Counter
	lda		IR_Flag
	and		#%00110000
	sta		IR_Flag
	rts
Phase2_Abort:
;	bbs5	IR_Flag,?No_Mark				; 测试用代码
;	smb1	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; 收码阶段3，检测码元第一个电平时间是否合法
IR_Receive_Phase_3:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		#7
	cmp		IR_Counter
	bcc		Phase3_Abort					; 上溢，终止收码
	lda		#4
	sta		IR_ReceivePhase					; 收码进入阶段4
	lda		#0
	sta		IR_Counter
	rts
Phase3_Abort:
;	bbs5	IR_Flag,?No_Mark				; 测试用
;	smb2	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; 收码阶段4，区分0码和1码，并入队缓冲区，同时判断接收是否完成
IR_Receive_Phase_4:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#2
	bcc		Phase4_No0Code					; 非0码
	lda		#7
	cmp		IR_Counter
	bcc		Phase4_No0Code
	clc										; 入队0码
	jmp		Receive_AfterHandle				; 收码1bit的后处理
Phase4_No0Code:
	lda		IR_Counter
	cmp		#9
	bcc		Phase4_Abort					; 也非1码，终止收码
	lda		#20
	cmp		IR_Counter
	bcc		Phase4_Abort					; 也非1码，终止收码
	sec										; 入队1码
	jmp		Receive_AfterHandle				; 收码1bit的后处理
Phase4_Abort:
;	bbs5	IR_Flag,?No_Mark				; 测试用代码
;	smb3	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


IR_Receive_Phase_5:							; 终止码阶段，避免在空闲等待阶段意外进阶段1
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		#0
	sta		IR_ReceivePhase
	lda		#5
	sta		Interval_Counter
	rts


Receive_Abort:
	lda		#0
	sta		IR_ReceivePhase
	sta		IR_Counter						; 清空计数
;	lda		#%00100000						; 测试用代码
	sta		IR_Flag
L_Clr_CodeBuffer:
	lda		#0
	sta		ID_Code							; 清空解码缓冲区
	sta		D_Code
	sta		IA_Code
	sta		A_Code
	sta		Repeat_Counter					; 每次收码失败会断掉连续接收重复码，清空重复码个数计数
	rmb4	IR_Flag							; 关闭重复码间隔超时计时和计数开关
	rmb4	Timer_Switch
	rts


; 收码1bit的后处理
Receive_AfterHandle:
	ror		ID_Code							; 将接收到的码元入队
	ror		D_Code
	ror		IA_Code
	ror		A_Code

	dec		Code_Counter
	beq		Receive_Complete				; 若已接收32个码，则收码完成
	lda		#3
	sta		IR_ReceivePhase					; 收码回到阶段3，接收下一个码
	lda		#0
	sta		IR_Counter
	rts
Receive_Complete:
	lda		#5
	sta		IR_ReceivePhase					; 收码阶段重置为阶段0
	sta		IR_Counter						; 清空计数
	sta		Repeat_Counter					; 每次收码成功也会断掉连续接收重复码，清空重复码个数计数
	lda		#%00010100						; 复位相关标志位并打开解码标志位
	sta		IR_Flag
	smb4	Timer_Switch					; 打开32Hz计数开关，开始接收重复码并计数
	rts




RepeatCode_Handle:
	bbr4	IR_Flag,?Handle_Exit			; 要同时有重复码间隔开始计数和32Hz标志才处理
	bbs4	Timer_Flag,RepeatCounter_Handle
?Handle_Exit:
	rts
RepeatCounter_Handle:
	rmb4	Timer_Flag
	dec		Interval_Counter				; 重复码间隔计数递减
	beq		Interval_Timeout				; 减到0视为超时
	lda		Repeat_Counter
	cmp		#19
	bcc		L_IR_NoLongPress				; 连续收到19个重复码则触发长按功能
	bbs5	IR_Flag,?Handle_Exit			; 长按触发每次长按只进一次
	smb5	IR_Flag							; 长按功能触发，解码程序中会处理长按
	smb2	Timer_Switch					; 打开4Hz计数开关
?Handle_Exit:
	rts
L_IR_NoLongPress:
	rmb5	IR_Flag							; 重复码计数没到19个则没有长按功能
	rmb2	Timer_Switch					; 关闭4Hz计数开关
	rts
Interval_Timeout:
	rmb5	IR_Flag							; 复位长按处理标志
	jmp		L_Clr_CodeBuffer




; 主循环调用收码时，在主循环调用该函数即可
; 收码完成或者终止时退出循环
IR_Receive_Loop:
	jsr		IR_ReceiveHandle				; 红外接收
	;bbs4	IR_Flag,No_IR_Receiveing
	;lda		IR_Test
	;bne		No_IR_Receiveing				; 测试用代码
	lda		IR_ReceivePhase
	beq		No_IR_Receiveing
	bra		IR_Receive_Loop					; 若当前接收阶段非0，则循环接收直到收码阶段重置为0
No_IR_Receiveing:
	jsr		F_IR_Decode						; 红外解码
	rts




; 解码接收的NEC码执行对应的功能函数
F_IR_Decode:
	bbr5	IR_Flag,L_No_LongPress
	bbr2	Timer_Flag,L_No_LongPress
	rmb2	Timer_Flag
	bra		IR_Decode_Start					; 在有长按标志时，4Hz进一次解码程序执行功能
L_No_LongPress:
	bbs2	IR_Flag,IR_Decode_Start
	rts
IR_Decode_Start:
	rmb2	IR_Flag							; 每次收码完成后只解码1次
	lda		D_Code
	eor		ID_Code							; 校验数据码，若校验失败则不解码并清空缓冲区
	cmp		#$ff
	beq		IR_Code_CheckOK
	jsr		Receive_Abort
	rts

IR_Code_CheckOK:
	ldx		#0
Compare_DCode_Loop:
	lda		Table_IR_KeyCode,x
	cmp		D_Code
	beq		IR_KeyHandle					; 比对接收的数据码和表格内容，进对应的按键功能
	inx
	cpx		#21
	bcc		Compare_DCode_Loop
	rts

; 跳转至对应功能函数
IR_KeyHandle:
	jsr		L_ShutDown_Alarm				; 若此时正在响闹，则关闭闹钟，但不执行按键功能

	txa
	clc
	rol
	tax
	lda		IR_Func_JumpTable+1,x
	pha
	lda		IR_Func_JumpTable,x
	pha
	rts

IR_Func_JumpTable:
	dw		L_IR_Func_OnOff-1
	dw		L_IR_Func_12_24-1
	dw		L_IR_Func_Alarm-1
	dw		L_IR_Func_Inc-1
	dw		L_IR_Func_Set-1
	dw		L_IR_Func_Dec-1
	dw		L_IR_Func_LightStaue-1
	dw		L_IR_Func_OK-1
	dw		L_IR_Func_CF-1
	dw		L_IR_Func_TimerUp-1
	dw		L_IR_Func_TimerDown-1
	dw		L_IR_Func_0-1
	dw		L_IR_Func_1-1
	dw		L_IR_Func_2-1
	dw		L_IR_Func_3-1
	dw		L_IR_Func_4-1
	dw		L_IR_Func_5-1
	dw		L_IR_Func_6-1
	dw		L_IR_Func_7-1
	dw		L_IR_Func_8-1
	dw		L_IR_Func_9-1


L_IRCode_NoLongPress:						; 非长按功能键
	bbs5	IR_Flag,?No_LongPress
	rts
?No_LongPress:
	pla
	pla
	rts


L_ShutDown_Alarm:							; 按键关闭闹钟
	bbs2	Clock_Flag,?No_AlarmLouding
	rts
?No_AlarmLouding:
	jsr		L_CloseLoud						; 打断响闹
	pla
	pla
	rts



L_IR_Func_OnOff:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON
	rmb1	Backlight_Flag					; 关闭PWM调光开关，并关闭所有LED
	LED_SET_HIGH
	rts


L_IR_Func_12_24:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	lda		Sys_Status_Flag
	and		#%00011
	beq		IR_12_24_Exit					; 显示模式生效
	jmp		DM_SW_TimeMode					; 调用对应功能函数
IR_12_24_Exit:
	rts


L_IR_Func_Alarm:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jmp		Return_CD_Mode					; 设置模式会返回时显
?No_SetMode:
	bbs4	Sys_Status_Flag,IR_Alarm_Exit	; 计时模式无效
	jmp		SwitchState_AlarmDis			; 显示模式会进入闹显切换
IR_Alarm_Exit:
	rts


L_IR_Func_Inc:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; 只有第一下有按键音
?LongPress_BeepOFF:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		AddNum_CS						; 时设模式增数
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		AddNum_AS						; 闹设模式增数
?No_AS_Mode:
	bbr4	Sys_Status_Flag,IR_Inc_Exit
	nop										; 计时模式的按键功能
IR_Inc_Exit:
	rts


L_IR_Func_Set:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音
	lda		Sys_Status_Flag
	and		#%00101							; 时钟模式切换到设置模式
	beq		?No_CS_Mode
	jmp		SwitchState_ClockSet
?No_CS_Mode:
	lda		Sys_Status_Flag
	and		#%01010							; 闹钟模式切换到设置模式
	beq		IR_Set_Exit
	jmp		SwitchState_AlarmSet
IR_Set_Exit:
	rts


L_IR_Func_Dec:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; 只有第一下有按键音
?LongPress_BeepOFF:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		SubNum_CS						; 时设模式减数
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		SubNum_AS						; 闹设模式减数
?No_AS_Mode:
	bbr4	Sys_Status_Flag,IR_Dec_Exit
	nop										; 计时模式的按键功能
IR_Dec_Exit:
	rts


L_IR_Func_LightStaue:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	jsr		LightLevel_Change
	nop										; 亮度等级显示
	rts


L_IR_Func_OK:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jmp		Return_CD_Mode					; 设置模式会返回时显
?No_SetMode:
	bbr4	Sys_Status_Flag,IR_OK_Exit
	nop										; 计时模式开始计时功能
IR_OK_Exit:
	rts


L_IR_Func_CF:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音
	jmp		TemperMode_Change


L_IR_Func_TimerUp:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; 只有第一下有按键音
?LongPress_BeepOFF:

	nop										; 进入正计时模式，长按退出到时显

	rts


L_IR_Func_TimerDown:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; 只有第一下有按键音
?LongPress_BeepOFF:

	nop										; 进入倒计时模式，长按退出到时显
	rts


L_IR_Func_0:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为0

	rts


L_IR_Func_1:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为1

	rts


L_IR_Func_2:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为2

	rts


L_IR_Func_3:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为3

	rts


L_IR_Func_4:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为4

	rts


L_IR_Func_5:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为5

	rts


L_IR_Func_6:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为6

	rts


L_IR_Func_7:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为7

	rts


L_IR_Func_8:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为8

	rts


L_IR_Func_9:
	jsr		L_IRCode_NoLongPress			; 该按键无长按功能
	jsr		L_KeyBeep_ON					; 按键音

	nop										; 正计时设置位数为9

	rts




;IR_Test_1:
;	bbs4	IR_Flag,Receive_Complete_1
;	rts
;Receive_Complete_1:
;	rmb4	IR_Flag
;
;	ldx		#led_Month
;	jsr		F_ClrSymbol
;	ldx		#led_Date
;	jsr		F_DisSymbol
;
;	lda		A_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d1
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d0
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		IA_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d3
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d2
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		D_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d6
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d5
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		ID_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d10
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d9
;	jsr		L_Dis_7Bit_DigitDot
;
;	jsr		L_Send_DRAM
;	rts


;IR_Test_2:
;	lda		IR_Test
;	bne		Receive_Abort_1
;	rts
;Receive_Abort_1:
;	ldx		#led_Month
;	jsr		F_DisSymbol
;
;	bbr0	IR_Test,NoPhase1
;	rmb0	IR_Test
;	ldx		#led_MON1
;	jsr		F_DisSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase1:
;	bbr1	IR_Test,NoPhase2
;	rmb1	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_DisSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase2:
;	bbr2	IR_Test,NoPhase3
;	rmb2	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_DisSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase3:
;	rmb3	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_DisSymbol
;Juge_Over:
;
;	lda		Counter_Bak
;	jsr		L_A_DecToHex
;	pha
;	txa
;	ldx		#led_d0
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	pha
;	and		#$0f
;	ldx		#led_d2
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d1
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		#32
;	sec
;	sbc		Counter_Bak2
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d6
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d5
;	jsr		L_Dis_7Bit_DigitDot
;
;	jsr		L_Send_DRAM
;?Test_Over
;	rts
