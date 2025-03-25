	.CHIP		W65C02S								; cpu的选型
	.MACLIST	ON

CODE_BEG	EQU		E000H							; 起始地址

PROG		SECTION OFFSET CODE_BEG					; 定义代码段的偏移量从CODE_BEG开始，用于组织程序代码。
.include	50Px1x.h								; 头文件
.include	RAM.INC	
.include	MACRO.mac

STACK_BOT		EQU		FFH							; 堆栈底部
.PROG												; 程序开始

V_RESET:
	nop
	nop
	nop
	ldx		#STACK_BOT
	txs												; 使用这个值初始化堆栈指针，这通常是为了设置堆栈的底部地址，确保程序运行中堆栈的正确使用。
	lda		#$07									; #$97
	sta		SYSCLK									; 设置系统时钟

	lda		#00										; 复位RAM到0
	ldx		#$ff
	sta		$1800
L_Clear_Ram_Loop:
	sta		$1800,x
	dex
	bne		L_Clear_Ram_Loop

	lda		#$0
	sta		DIVC									; 分频控制器，定时器与DIV异步
	sta		IER										; 除能中断
	lda		FUSE
	sta		MF0										; 为内部RC振荡器提供校准数据	

	jsr		F_Init_SystemRam						; 初始化系统RAM并禁用所有断电保留的RAM
	jsr		F_Port_Init								; 初始化用到的IO口
	jsr		F_Beep_Init

	jsr		F_Timer_Init
	jsr		F_RFC_Init

	cli												; 开总中断

	jsr		L_Send_DRAM

; 上电处理
; 	rmb4	IER										;  关闭按键中断避免上电过程被打扰
; 	lda		#1
; 	sta		Light_Level
; 	smb0	PC										; 初始亮度设置为高亮
; 	smb0	PC_IO_Backup
; 
 	;jsr		F_Test_Display							; 上电显示部分
	;lda		#$02
	;sta		Beep_Serial
	;smb4	Key_Flag
	;smb3	Timer_Switch

; 	jsr		F_RFC_MeasureStart						; 上电温度测量
; Wait_RFC_MeasureOver:
; 	jsr		F_RFC_MeasureManage
; 	bbs0	RFC_Flag,Wait_RFC_MeasureOver
; 
; 	smb1	Timer_Flag
; 	rmb0	Timer_Flag
; 	jsr		F_SymbolRegulate
; 	jsr		F_Time_Display
; 	jsr		F_Display_Week
; 
; 	lda		#4										; 上电蜂鸣器响2声
; 	sta		Beep_Serial
; 	smb0	TMRC
; Loop_BeepTest:										; 响铃两声
; 	jsr		F_Louding
; 	lda		Beep_Serial
; 	bne		Loop_BeepTest
; 	rmb0	TMRC
; 
; 	lda		#0001B
; 	sta		Sys_Status_Flag
; 	lda		#0
; 	sta		Sys_Status_Ordinal
; 
; 	smb4	IER										;  上电显示完成，重新开启按键中断
	bra		Global_Run


; 状态机
MainLoop:
	lda		PC
	and		#$20
	bne		Global_Run
	;smb4	SYSCLK
	;sta		HALT									; 休眠
	;rmb4	SYSCLK
Global_Run:											; 全局生效的功能处理
	;jsr		F_KeyHandler
	jsr		IR_Test_1
	jsr		IR_Test_2
	jsr		F_IR_Decode								; 红外解码
	jsr		F_BeepManage
	;jsr		F_PowerManage
	;jsr		F_Time_Run								; 走时
	;jsr		F_SymbolRegulate
	;jsr		F_Display_Week
	;jsr		F_RFC_MeasureManage
	;jsr		F_ReturnToDisTime						; 定时返回时显模式

Status_Juge:
	bbs0	Sys_Status_Flag,Status_DisClock
	bbs1	Sys_Status_Flag,Status_DisAlarm
	bbs2	Sys_Status_Flag,Status_SetClock
	bbs3	Sys_Status_Flag,Status_SetAlarm

	bra		MainLoop
Status_DisClock:
	;jsr		F_Clock_Display
	;jsr		F_Alarm_Handler							; 显示状态有响闹判断
	;bra		MainLoop
Status_DisAlarm:
	;jsr		F_Alarm_Display
	;jsr		F_Alarm_Handler							; 显示状态有响闹判断
	bra		MainLoop
Status_SetClock:
	;jsr		F_Clock_Set
	bra		MainLoop
Status_SetAlarm:
	;jsr		F_Alarm_Set
	bra		MainLoop




F_ReturnToDisTime:
	bbs3	Time_Flag,L_Return_Start
	rts
L_Return_Start:
	bbr0	Sys_Status_Flag,L_Return_Juge
	bbs0	Sys_Status_Ordinal,L_Return_Juge
	nop												; 正倒计时模式下，则不返回
	lda		#10
	sta		Return_MaxTime
L_Return_Juge:
	rmb3	Time_Flag
	lda		Return_Counter
	cmp		Return_MaxTime							; 当前模式的返回时间
	bcs		L_Return_Stop
	inc		Return_Counter
	bra		L_Return_Juge_Exit
L_Return_Stop:
	lda		#0
	sta		Return_Counter
	bbr0	Sys_Status_Flag,No_TimeDis_Return		; Sys Flag第一位为0则不是时显
	bbs0	Sys_Status_Ordinal,No_TimeDis_Return	; Sys Ordinal不为0则不是时显
	;jsr		SwitchState_ClockDis					; 时显下若有轮显，则计时结束返回日显
	bra		L_Return_Juge_Exit

No_TimeDis_Return:
	lda		#0
	sta		Sys_Status_Ordinal						; 非时显若计时结束则返回时显

Return_Over:
	lda		#0001B									; 回到时显模式
	sta		Sys_Status_Flag
L_Return_Juge_Exit:
	rts




; 中断服务函数
V_IRQ:
	pha
	txa
	pha
	php
	lda		IER
	and		IFR
	sta		R_Int_Backup

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrq
	bbs6	R_Int_Backup,L_LcdIrq
	jmp		L_EndIrq

L_DivIrq:
	rmb0	IFR									; 清中断标志位
	jmp		I_DivIRQ_Handler

L_Timer0Irq:									; 用于蜂鸣器
	rmb1	IFR									; 清中断标志位
	jmp		I_Timer0IRQ_Handler

L_Timer1Irq:									; 用于快加计时
	rmb2	IFR									; 清中断标志位
	jmp		I_Timer1IRQ_Handler

L_Timer2Irq:
	rmb3	IFR									; 清中断标志位
	jmp		I_Timer2IRQ_Handler

L_PaIrq:
	rmb4	IFR									; 清中断标志位
	jmp		I_PaIRQ_Handler

L_LcdIrq:
	rmb6	IFR									; 清中断标志位
	jmp		I_LcdIRQ_Handler

L_EndIrq:
	plp
	pla
	tax
	pla
	rti


.include	IRQ.asm
.include	ScanKey.asm
.include	Time.asm
.include	Calendar.asm
.include	Beep.asm
.include	Init.asm
.include	Disp.asm
.include	Display.asm
.include	Alarm.asm
.include	Ledtab.asm
.include	RFC.asm
.include	RFCTable.asm
.include	TemperHandle.asm
.include	PowerManage.asm
.include	TestDisplay.asm
.include	infrared.asm
.include	IR_Table.asm


.BLKB	0FFFFH-$,0FFH							; 从当前地址到FFFF全部填充0xFF

.ORG	0FFF8H
	DB		C_PY_SEL+C_OMS_BR
	DB		C_PROTB
	DW		0FFFFH

.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ

.ENDS
.END
