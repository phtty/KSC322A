.Kdata
;***************************************
; RAM Address
;***************************************
RamStarAddr		EQU		1800H											;RAM的开始地址

LED_RamAddr		EQU		RamStarAddr+LED_Addr-Page0RamStarAddr			;LED RAM的地址
LED_BakRamAddr	EQU		RamStarAddr+LED_Addr_BK-Page0RamStarAddr		;LED_BK RAM的地址
IR_RamAddr		EQU		RamStarAddr+IR_Code_Addr-Page0RamStarAddr		;IR_Code的地址
Time_Addr		EQU		RamStarAddr+Time_Str_Addr-Page0RamStarAddr		;事件相关数据的地址
Alarm_MinAddr	EQU		RamStarAddr+Alarm_Min_Addr-Page0RamStarAddr		;闹钟组分钟数据地址
Alarm_HourAddr	EQU		RamStarAddr+Alarm_Hour_Addr-Page0RamStarAddr	;闹钟组小时数据地址
Alarm_WorkDayAddr	EQU	RamStarAddr+AL_WorkDay_Addr-Page0RamStarAddr	;闹钟组工作日数据地址
TimekeepAddr	EQU		RamStarAddr+Timekeep_Addr-Page0RamStarAddr	;闹钟组小时数据地址
;***************************************
;Time_Addr		EUQ		B0H
;***************************************
.PAGE0     ;page 0的内存布局
;***************************************
;---------------------------------------------------------------------
	ORG	0080H
Page0RamStarAddr		EQU		$
LED_Addr				EQU		$
LED_Ram					DS		12

LED_Addr_BK				EQU		$
LED_Ram_BK				DS		12

; IR解码缓存
IR_Code_Addr			EQU		$
A_Code					DS		1
IA_Code					DS		1
D_Code					DS		1
ID_Code					DS		1

R_Int_Backup			DS		1

Counter_1Hz				DS		1
Counter_2Hz				DS		1
Counter_4Hz				DS		1
Counter_21Hz			DS		1
Counter_32Hz			DS		1
Counter_50Hz			DS		1
Counter_256Hz			DS		1
Counter_4096Hz			DS		1

Counter_DP				DS		1
Count_RFC				DS		1

QuickAdd_Counter		DS		1
Backlight_Counter		DS		1
Return_Counter			DS		1
Return_MaxTime			DS		1
AlarmLoud_Counter		DS		1
TimekeepLoud_Counter	DS		1
IR_Counter				DS		1
Code_Counter			DS		1
Repeat_Counter			DS		1
Interval_Counter		DS		1
;Counter_Bak				DS		1
;Counter_Bak2			DS		1

Calendar_Flag			DS		1
;bit0 = 1 闰年
;bit1 = 1 日期显示更新
;bit2 = 1 星期反显

Clock_Flag				DS		1
;bit0 = 1 12h模式
;bit1 = 1 闹钟触发
;bit2 = 1 响闹模式
;bit3 = 1 
;bit4 = 1 
;bit5 = 1 
;bit6 = 1 

Timer_Flag				DS		1
;bit0 = 1 1Hz标志
;bit1 = 1 2Hz标志
;bit2 = 1 4Hz标志
;bit3 = 1 21Hz标志
;bit4 = 1 32Hz标志
;bit5 = 1 50Hz标志
;bit6 = 1 256Hz标志
;bit7 = 1 4096Hz标志

Timer_Switch			DS		1
;bit0 = 1 1Hz开关
;bit1 = 1 2Hz开关
;bit2 = 1 4Hz开关
;bit3 = 1 21Hz开关
;bit4 = 1 32Hz开关
;bit5 = 1 50Hz开关
;bit6 = 1 256Hz开关
;bit7 = 1 4096Hz开关

Time_Flag				DS		1
;bit0 = 1 走时加时1S标志
;bit1 = 1 响铃加时1S标志
;bit2 = 1 RFC采样加时1S标志
;bit3 = 1 返回初始状态加时1S标志
;bit4 = 1 清除响闹阻塞标志
;bit5 = 1 亮屏时间加时1S标志
;bit6 = 1 刷新显示标志

; 符号操作
Symbol_Flag				DS		1
;bit0 = 1 ALM点半S标志
;bit1 = 1 ALM点1S标志

Sys_Status_Flag			DS		1
;bit0 = 1 时钟显示
;bit1 = 1 闹钟显示
;bit2 = 1 设置时钟
;bit3 = 1 闹钟设置
;bit4 = 1 计时模式

Sys_Status_Ordinal		DS		1
; 子模式的序号

Key_Flag				DS		1
;bit0 = 1 扫键标志位
;bit1 = 1 首次触发
;bit2 = 1 快加标志位
;bit3 = 1 屏幕唤醒事件标志位
;bit4 = 1 按键提示音标志位
;bit5 = 1 长按扫键4Hz标志
;bit6 = 1 
;bit7 = 1 

; 长短按功能不同的按键
SpecialKey_Flag			DS		1
;bit0 = 1 Alarm键待处理				|特殊按键
;bit1 = 1 SNZ/Backlight键待处理		|特殊按键
;bit2 = 1 Mode键待处理				|特殊按键
;bit3 = 1 Up键待处理				|特殊按键
;bit4 = 1 Down键待处理				|特殊按键

RFC_Flag				DS		1
;bit0 = 1 采样启用标志位
;bit1 = 1 禁用RFC采样标志，这通常是因为TMR0、1被占用
;bit2 = 1 负温度
;bit3 = 1 华氏度模式
;bit4 = 1 温湿度测量完成标志
;bit5 = 1 
;bit6 = 1 

IR_Flag					DS		1
;bit0 = 1 检测到高电平
;bit1 = 1 检测到低电平
;bit2 = 1 开始解码标志
;bit3 = 1 IR_Counter开始计数标志
;bit4 = 1 Interval_Counter开始计数标志
;bit5 = 1 长按处理标志

;IR_Test					DS		1
;bit0 = 1 阶段1终止
;bit1 = 1 阶段2终止
;bit2 = 1 阶段3终止
;bit3 = 1 阶段4终止
;bit4 = 1 超过最大值终止

IR_ReceivePhase			DS		1
;0	接收阶段0，等待引导码/重复码到来
;1	接收阶段1，引导码/重复码的第一个电平
;2	接收阶段2，引导码/重复码的第二个电平
;3	接收阶段3，码元的第一个电平
;4	接收阶段4，码元的第二个电平
;5	接收阶段5，等待结束码

IR_DepressJuge			DS		1
;bit0 = 1 OK键松键处理标志
;bit1 = 1 正计时键松键处理标志
;bit2 = 1 倒计时键松键处理标志

Timekeep_Flag			DS		1
;bit0 = 1 计时开启
;bit1 = 1 倒计时完成标志
;bit2 = 1 

Timekeep_NumberSet		DS		1
;0	设置分钟十位
;1	设置分钟个位
;2	设置秒十位
;3	设置秒个位

Backlight_Flag			DS		1
;bit0 = 1 DC5V接入时唤醒
;bit1 = 1 PWM调光开关
;bit2 = 1 手动进入熄屏模式
;bit3 = 1 自动亮度

Light_Level				DS		1	; 亮度等级
; 0: 低亮
; 1: 半亮
; 2: 高亮

Alarm_Group				DS		1	; 闹钟组
; 0：当前操作闹钟组1
; 1：当前操作闹钟组2

Alarm_Switch			DS		1	; 各个闹钟开关
;bit0 = 1 闹钟1开启
;bit1 = 1 闹钟2开启

AL_WorkDay_Addr			EQU		$
Alarm1_WorkDay			DS		1	; 闹钟1的工作日
; 0: 1~5
; 1: 1~6
; 2: 1~7
Alarm2_WorkDay			DS		1	; 闹钟2的工作日
; 0: 1~5
; 1: 1~6
; 2: 1~7

Triggered_AlarmGroup	DS		1

RFC_ChannelCount		DS		1

RT_Div_RR_H				DS		1
RT_Div_RR_L				DS		1
RFC_TempCount_H			DS		1
RFC_TempCount_M			DS		1
RFC_TempCount_L			DS		1
RFC_StanderCount_H		DS		1
RFC_StanderCount_M		DS		1
RFC_StanderCount_L		DS		1

R_Temperature			DS		1
R_Temperature_F			DS		1

R_Temper_Comp			DS		1
R_Temper_Comp_Time		DS		1

Beep_Serial				DS		1
;响铃序列

PA_IO_Backup			DS		1
PC_IO_Backup			DS		1
PD_IO_Backup			DS		1

;---------------------------------------
Time_Str_Addr			EQU		$
R_Time_Sec				DS		1	; 时间秒
R_Time_Min				DS		1	; 时间分
R_Time_Hour				DS		1	; 时间小时
R_Alarm_Min				DS		1	; 触发闹钟分
R_Alarm_Hour			DS		1	; 触发闹钟小时
R_Date_Day				DS		1	; 日期，从1开始
R_Date_Month			DS		1	; 月份，从1开始
R_Date_Year				DS		1	; 年份，由于只计2000-2099，所以由0-99代替
R_Date_Week				DS		1	; 星期数，从1开始

Alarm_Min_Addr			EQU		$
R_Alarm1_Min			DS		1	; 闹钟1分
R_Alarm2_Min			DS		1	; 闹钟2分

Alarm_Hour_Addr			EQU		$
R_Alarm1_Hour			DS		1	; 闹钟1小时
R_Alarm2_Hour			DS		1	; 闹钟2小时

Timekeep_Addr			EQU		$
R_Timekeep_Min			DS		1	; 计时模式分钟
R_Timekeep_Sec			DS		1	; 计时模式秒

R_TimekeepBak_Min		DS		1	; 倒计时的计时备份
R_TimekeepBak_Sec		DS		1	; 倒计时的计时备份

;---------------------------------------       
P_Temp					DS		8
;---------------------------------------
;---------------------------------------
;***************************************
.ENDS
;***************************************
.Udata
;---------------------------------------
	ORG		1880H
;---------------------------------------
;---------------------------------------
.ENDS
