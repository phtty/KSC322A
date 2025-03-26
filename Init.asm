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
	lda		#$2c
	sta		PA_DIR
	lda		#$2c
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

	lda		#$37
	sta		PD_DIR								; PD0~2、5配置为三态输入，PD4为上拉输入
	lda		#$10
	sta		PD
	lda		#$00
	sta		PD_SEG								; PD口全部作IO口使用

	lda		PD
	sta		PD_IO_Backup						; 同步PD口当前状态和历史状态

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
	;ora		#C_TMR2I+C_LCDI+C_DIVI				; LCD中断用于2Hz、1Hz的半S处理、1S处理和走时
	ora		#C_DIVI
	sta		IER									; DIV中断用于红外接收、响闹时钟源，RFC测量计时

	rts




F_RFC_Init:
	rmb6	PC_SEG

	lda		RFCC0								; PD0-3配置为RFC功能
	ora		#$0f
	sta		RFCC0

	lda		#$00
	sta		RFCC1								; 关闭RFC测量功能
	sta		PD_SEG								; PD口全部作IO口使用

	rts
