F_RFC_MeasureManage:
	bbs1	RFC_Flag,L_RFC_Exit					; 存在响闹和按键音的时候，TIM0、1被占用，不进行测量
	bbs4	Key_Flag,L_RFC_Exit
	lda		Sys_Status_Flag						; 计时模式不进行测量
	cmp		#%10000
	beq		L_RFC_Exit

	bbr4	RFC_Flag,RFC_NoComplete
	rmb4	RFC_Flag
	jsr		F_RFC_MeasureStop					; 采样完成，停止进入DIV中断，关闭RFC测量功能
RFC_NoComplete:
	bbr2	Time_Flag,L_RFC_Exit				; 1S标志，计数15S
	rmb2	Time_Flag
	lda		Count_RFC
	cmp		#15
	bcs		F_RFC_MeasureStart
	inc		Count_RFC
	rts
F_RFC_MeasureStart:
	lda		#0
	sta		Count_RFC							; 满15S后，清空计数，开始采样
	sta		RFC_ChannelCount					; 采样开始，清除通道计数

	smb0	RFC_Flag
	smb5	Timer_Switch						; 打开50Hz计时

L_RFC_Exit:
	rts




F_RFC_Channel_Select:
	jsr		F_RFC_TimerReset					; 初始化RFC采样定时器状态

	lda		TMRC								; T0I设置为Frcx
	ora		#C_T0I_1
	sta		TMRC
	lda		#C_TMR0_T0I+C_TMR1_TMR0				; 配置TM0时钟源为T0I,TM1时钟源为TM0,级联TM0和TM1
	sta		TMCLK

	lda		#C_SyncWithDIV+C_DIVC_Fsub_4
	sta		DIVC								; 开启定时器同步，DIV时钟源为Fsub/4(8192Hz)

	smb0	TMRC								; 开启TMR0
	smb1	TMRC								; 开启TMR1

	ldx		RFC_ChannelCount
	lda		T_RFC_Channel,x
	sta		RFCC1

	rts




L_Get_RFC_Data:
	lda		RFC_ChannelCount
	bne		L_NoTemp							; PD2口取得温度计数值
	lda		TMR0
	sta		RFC_TempCount_L
	lda		TMR1
	sta		RFC_TempCount_M
	bra		L_Sample_Over
L_NoTemp:
	lda		RFC_ChannelCount
	cmp		#01									; PD1口取得标准电阻计数值
	bne		L_Sample_Over
	lda		TMR0
	sta		RFC_StanderCount_L
	lda		TMR1
	sta		RFC_StanderCount_M
	smb4	RFC_Flag							; 采样完成，准备计算
	rmb5	Timer_Switch
L_Sample_Over:
	lda		#0
	sta		RFCC1								; 当前通道采样完成，关闭RFC
	inc		RFC_ChannelCount

F_RFC_TimerReset:								; 等待下一通道采样开始，重置定时器状态
	rmb1	IER									; 关TMR0、1定时器和中断并清理中断标志位
	rmb1	IFR
	rmb2	IER
	rmb2	IFR
	rmb0	TMRC
	rmb1	TMRC
	lda		#$0									; 清0定时器值
	sta		TMR0
	sta		TMR1
	rts




F_RFC_MeasureStop:
	rmb0	RFC_Flag							; 清除采样启用中标志位
	rmb4	RFC_Flag

	rmb5	Timer_Switch						; 关闭50Hz计时

	jsr		L_Temper_Handle
	jsr		F_Display_Temper					; 数据处理后，显示温度和湿度

L_CLR_RFC:
	lda		#0
	sta		RFC_TempCount_H						; 清理相关变量
	sta		RFC_TempCount_M
	sta		RFC_TempCount_L
	sta		RFC_StanderCount_H
	sta		RFC_StanderCount_M
	sta		RFC_StanderCount_L

	rts



; RFC采样被打断,通常是由其他需要定时器的功能调用
; 此时需要禁用RFC采样直到此功能结束
F_RFC_Abort:
	smb1	RFC_Flag							; 禁用RFC采样
	rmb0	RFC_Flag							; 清除采样启用中标志位
	rmb4	RFC_Flag

	rmb5	Timer_Switch						; 关闭50Hz计时

	jsr		L_CLR_RFC
	sta		RFC_ChannelCount					; 重置通道计数

	rts




T_RFC_Channel:
	;db		$20	; CTRT0	PD3
	db		$10	; RS0	PD2
	db		$60	; CSRT0	PD1
