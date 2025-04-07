	.CHIP		W65C02S								; cpu的选型
	.MACLIST	ON

CODE_BEG	EQU		E000H							; 起始地址

PROG		SECTION OFFSET CODE_BEG					; 定义代码段的偏移量从CODE_BEG开始，用于组织程序代码。
.include	50Px1x.h								; 头文件
.include	RAM.INC
.include	Init.mac
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
	sta		IER										; 除能所有中断
	lda		FUSE
	sta		MF0										; 为内部RC振荡器提供校准数据	

	jsr		F_Init_Sys								; 初始化外设

	cli												; 开总中断
	jsr		L_Send_DRAM

;上电处理
	rmb4	IER										; 关闭按键中断避免上电过程被打扰
	lda		#0
	sta		Light_Level								; 初始亮度设置为低亮

 	jsr		F_Test_Display							; 上电显示部分

;	jsr		F_RFC_MeasureStart						; 上电温度测量
;Wait_RFC_MeasureOver:
;	jsr		F_RFC_MeasureManage
;	bbs0	RFC_Flag,Wait_RFC_MeasureOver

	lda		#$02
	sta		Beep_Serial
	smb4	Key_Flag
	smb3	Timer_Switch							; 上电响铃1声

	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal

	REFLASH_HALF_SEC								; 上电立刻产生半S更新
	smb1	Calendar_Flag							; 上电立刻产生日期显示更新

	smb4	IER										; 上电显示完成，重新开启按键中断

; 测试部分

	bra		Global_Run


; 状态机
MainLoop:
	jsr		F_PowerSavingMode						; 只有纽扣电池的省电模式
Global_Run:											; 全局生效的功能处理
	jsr		F_Flash_Display							; 通过标志位决定是否刷新显示
	;jsr		F_KeyHandler
	jsr		IR_Receive_Loop							; 红外接收
	jsr		F_BeepManage
	jsr		F_Time_Run								; 走时
	jsr		F_SymbolRegulate
	jsr		F_Date_Display							; 日期和星期更新，日期设置模式下由日期设置更新接管
	;jsr		F_RFC_MeasureManage
	jsr		F_ReturnToInitial						; 定时返回时显模式

Status_Juge:
	bbs0	Sys_Status_Flag,Status_DisTime
	bbs1	Sys_Status_Flag,Status_DisAlarm
	bbs2	Sys_Status_Flag,Status_SetClock
	bbs3	Sys_Status_Flag,Status_SetAlarm
	bbs4	Sys_Status_Flag,Status_TimeKeep

	bra		MainLoop
Status_DisTime:
	jsr		F_Time_Display
	jsr		F_Alarm_Handler							; 显示状态有响闹判断
	bra		MainLoop
Status_DisAlarm:
	jsr		F_Alarm_GroupDis
	jsr		F_Alarm_Handler							; 显示状态有响闹判断
	bra		MainLoop
Status_SetClock:
	jsr		F_Clock_Set
	bra		MainLoop
Status_SetAlarm:
	jsr		F_Alarm_GroupSet
	bra		MainLoop
Status_TimeKeep:
	jsr		F_Timekeep_Run
	jsr		F_Timekeep_Display
	jsr		F_Timekeep_BeepHandler
	bra		MainLoop




F_ReturnToInitial:
	bbr3	Clock_Flag,NoNeed_Return				; 同时有返回初始状态计时开启和返回加时1S标志才会处理
	bbs3	Time_Flag,L_Return_Start
NoNeed_Return:
	rts
L_Return_Start:
	rmb3	Time_Flag
	lda		Return_Counter
	cmp		Return_MaxTime							; 当前模式的返回时间
	bcs		L_ReturnToInitial
	inc		Return_Counter
	rts
L_ReturnToInitial:
	lda		#0
	sta		Return_Counter
	rmb3	Clock_Flag
	jmp		Return_CD_Mode




F_Init_Sys:
	F_Init_SystemRam								; 初始化系统RAM并禁用所有断电保留的RAM
	F_Port_Init										; 初始化用到的IO口
	F_Beep_Init

	F_Timer_Init
	F_RFC_Init
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
	cld

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrq
	bbs6	R_Int_Backup,L_LcdIrq
	jmp		L_EndIrq

L_DivIrq:										; 用于红外收码计时、蜂鸣器时钟源以及RFC 50Hz采样计数
	rmb0	IFR									; 清中断标志位
	jmp		I_DivIRQ_Handler

L_Timer0Irq:
	rmb1	IFR									; 清中断标志位
	jmp		I_Timer0IRQ_Handler

L_Timer1Irq:
	rmb2	IFR									; 清中断标志位
	jmp		I_Timer1IRQ_Handler

L_Timer2Irq:									; 用于LED的PWM调光、32Hz长按计数、21Hz蜂鸣间隔计数以及4Hz快加计数
	rmb3	IFR									; 清中断标志位
	jmp		I_Timer2IRQ_Handler

L_PaIrq:										; 用于按键
	rmb4	IFR									; 清中断标志位
	jmp		I_PaIRQ_Handler

L_LcdIrq:										; 用于走时和半秒更新
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
.include	KeyFunction.asm
.include	Time.asm
.include	Calendar.asm
.include	Beep.asm
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
.include	TimeKeep.asm


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
