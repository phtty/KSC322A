F_Init_SystemRam:								; 系统内存初始化
	lda		#0001B
	sta		Sys_Status_Flag

	lda		#12
	sta		R_Time_Hour
	;lda		#00
	;sta		R_Time_Min
	;lda		#00
	;sta		R_Time_Sec

	lda		#12
	sta		R_Alarm1_Hour
	;lda		#00
	;sta		R_Alarm1_Min

	lda		#12
	sta		R_Alarm2_Hour
	;lda		#00
	;sta		R_Alarm2_Min

	lda		#12
	sta		R_Alarm3_Hour
	;lda		#00
	;sta		R_Alarm3_Min

	lda		#01
	sta		R_Date_Day
	lda		#01
	sta		R_Date_Month
	lda		#24
	sta		R_Date_Year
	;lda		#00
	;sta		R_Date_Week

	smb1	Backlight_Flag						; 上电亮屏

	lda		#15
	sta		Count_RFC							; RFC采样间隔

	lda		#0
	sta		Light_Level							; 初始亮度

	rts


F_Beep_Init:
	;lda		#C_T000_Fsub
	;sta		PADF1
	;rmb0	TMCLK								; TIM0选择时钟源为Fsub
	;rmb1	TMCLK

	;lda		#256-8								; 配置TIM0频率为4096Hz
	;sta		TMR0
	lda		PB									; PB3配置为输出0
	and		#$f7
	sta		PB
	lda		PB_TYPE
	ora		#$8

	rmb3	PB_TYPE								; PB3选择NMOS输出0避免漏电

	rts


F_Port_Init:
	lda		#$3c								; PA2~5设置为上拉输入，并且设置中断唤醒
	sta		PA_WAKE
	lda		#$3c
	sta		PA_DIR
	lda		#$3c
	sta		PA
	smb4	IER									; 打开PA口外部中断

	lda		#$20
	sta		PC_DIR								; PC5配置为三态输入，其他输出0
	lda		#$0
	sta		PC

	lda		PB									; PB3配置为推挽输出
	and		#$b7
	sta		PB
	lda		PB_TYPE
	ora		#$8

	lda		#$17
	sta		PD_DIR								; PD0~2、4配置为三态输入，其余为输出
	lda		#$00
	sta		PD
	sta		PD_SEG								; PD口全部作IO口使用

	rts


F_Timer_Init:
	rmb1	IER									; 关TMR0、1定时器中断
	rmb1	IFR									; 清除TMR0、1中断标志位
	rmb2	IER
	rmb2	IFR
	rmb0	TMRC								; 关闭TMR0
	rmb1	TMRC								; 关闭TMR1

	lda		#C_DIVC_Fsub_4
	sta		DIVC								; DIV时钟源为Fsub/4(8192Hz)

	; TIM2时钟源DIV,Fsub 4分频8192Hz
	lda		#256-8
	sta		TMR2								; Tim2中断频率配置为1024Hz
	lda		#C_TMR2ON
	sta		TMRC								; 开启TIM2

	lda		#C_COM_8_36_32+C_LCDIS_Rate_2		; 配置为8COM，LCD中断时钟源二分频
	sta		LCD_COM
	lda		#$0f
	sta		FRAME

	lda		#0
	sta		IFR									; 清理中断标志位
	lda		IER									; Tim2定时器中断用于PWM调光、按键扫描、蜂鸣间隔、快加频率
	ora		#C_TMR2I+C_LCDI+C_DIVI				; LCD中断用于2Hz、1Hz的半S处理、1S处理和走时
	sta		IER									; DIV中断用于红外接收、响闹时钟源，RFC测量计时

	rts



F_Timer_NormalMode:
	rmb1	IER									; 关TMR0、1定时器中断
	rmb1	IFR									; 清除TMR0、1中断标志位
	rmb2	IER
	rmb2	IFR
	lda		TMRC
	pha
	rmb0	TMRC								; 关闭TMR0
	rmb1	TMRC								; 关闭TMR1
	lda		#C_TMR1_Fsub_64+C_TMR0_Fsub			; TIM0时钟源T000
	sta		TMCLK								; TIM1时钟源Fsub/64(512Hz)
	lda		#C_T000_Fsub
	sta		PADF1								; T000选择为Fsub
	lda		#C_Asynchronous+C_DIVC_Fsub_64
	sta		DIVC								; 关闭定时器同步并选择DIV时钟源为Fsub/64(512Hz)

	lda		#256-8								; 配置TIM0频率为4096Hz
	sta		TMR0
	lda		#256-32								; 配置TIM1频率为16Hz
	sta		TMR1

	pla
	sta		TMRC

	rmb0	IER									; 关闭DIV中断
	smb1	IER									; 开TIM0、1定时器中断
	smb2	IER

	rmb0	RFC_Flag							; 清除采样启用中标志位
	rmb3	RFC_Flag
	rmb6	RFC_Flag

	rts




F_RFC_Init:
	lda		#$0f
	sta		PD_DIR								; PD0-4配置为三态输入，其余为输出
	lda		#$0
	sta		PD

	rmb6	PC_SEG

	lda		RFCC0								; PD0-3配置为RFC功能
	ora		#$0f
	sta		RFCC0

	lda		#$00
	sta		RFCC1								; 关闭RFC测量功能
	sta		PD_SEG								; PD口全部作IO口使用

	rts


F_KeyMatrix_PC4Scan_Ready:
	;rmb4	IER									; 关闭PA口中断，避免误触发中断

	rmb4	PC
	smb5	PC
	rmb4	IFR									; 复位标志位,避免中断开启时直接进入中断服务
	jsr		L_KeyDelay
	rts

F_KeyMatrix_PC5Scan_Ready:
	;rmb4	IER									; 关闭PA口中断，避免误触发中断

	smb4	PC
	rmb5	PC
	rmb4	IFR									; 复位标志位,避免中断开启时直接进入中断服务
	jsr		L_KeyDelay
	rts

F_KeyMatrix_Reset:
	bbs2	Key_Flag,L_QuikAdd_ScanReset
F_QuikAdd_Scan:
	rmb4	PC
	rmb5	PC
	rts
L_QuikAdd_ScanReset:							; 有长按时PC4,PC5输出高，避免长按时漏电
	smb4	PC
	smb5	PC									; 快加下不需要开启中断，定时扫描IO口即可
	rts
