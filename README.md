# BitClockRecovery

A project to recover signal clock and keep it in phase with input signal  
Tested with a M-Series signal, works.  
Cannot get locked at some specific frequencies.  
The code sucks, because I didn't have verilog developing experience at that time.  

位时钟恢复，通过检测最短的两个相同边缘间隔时钟周期并平分来恢复信号时钟，同时利用相同边沿完成相位锁定  
测试时输入m序列，恢复效果一般  
我在编写该程序时尚无Verilog开发经验，未使用状态机，思路偏软件编程  
存在部分频点失锁的情况  