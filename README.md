# FPGA
Verilog - модули.

- папка 3-Phase_Sine_inverter
> Top.v - реализация трехфазного синусоедального напряжения частотой 50 Гц. 
функцией "мертвого времени", выходы A_p, A_n, B_p, B_n, C_p, C_n.
Заведены сигналы "Сброс", "Авария" - при срабатывании выходы ШИМ отключатся.  
- В папке Calc - имеется шаблон расчета SINE.
- В папке 3-Phase_induction motor_control - реализовано скалярное управление преобразователем частоты. ШИМ SVPWM - (Векторная широтно-импульсная модуляция)
	Top.v - главный файл проекта, управление осущесвляется передачей по UART частоты: 1Hz - 1....50Hz - 50, 9600; 
- папка ADC128S022 - пример работы с 8 канальным 12-разрядным АЦП по шине SPI и передача дынных с канала IN0  по UART. Cкорость обмена UART - 9600;
> файл верхнего уровня ADC128S022.v, Mathcad файл пример проверки преобразования АЦП.
- папка PID_ADC_PWM_control реализован пример ПИД регулятора с выводом PWM. В примере используется АЦП для реализации ОС с объекта RC - цепь. Система поддерживает 0.8В на выходе RC (апериодическое звено первого порядка) объекта управления.