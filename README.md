# FPGA
Verilog - модули.

- папка 3-Phase_Sine_inverter
- - Top.v - реализация трехфазного синусоедального напряжения частотой 50 Гц. 
ШИМ с функцией "мертвого времени", выходы A_p, A_n, B_p, B_n, C_p, C_n.
Заведены сигналы "Сброс", "Авария" - при срабатывании выходы ШИМ отключатся.  
- В папке Calc - имеется шаблон расчета SINE.
- В папке 3-Phase_induction motor_control - реализовано скалярное управление преобразователем частоты
-- Top.v - главный файл проекта. 