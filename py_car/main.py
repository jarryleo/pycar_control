"""
实验名称：连接无线路由器, 并通过wifi控制小车
版本：v2.0
日期：2021.12
作者：JarryLeo
说明：通过Socket编程实现pyWiFi-ESP32与控制端UDP通信，相互收发数据。
"""

# 导入相关模块
import socket
import network
import time
import usocket
from machine import SoftI2C, Pin, Timer
from ssd1306 import SSD1306_I2C
from car import CAR

# 初始化相关模块
i2c = SoftI2C(sda=Pin(25), scl=Pin(23))
oled = SSD1306_I2C(128, 64, i2c, addr=0x3c)
# 初始化pyCar
Car = CAR()
# 初始化WIFI指示灯
wifi_led = Pin(2, Pin.OUT)
# 构建KEY对象
KEY1 = Pin(0, Pin.IN, Pin.PULL_UP)
KEY2 = Pin(12, Pin.IN, Pin.PULL_UP)
# socket
global udp_socket
# 小车开启端口
port = 27890
# 组播地址
multiGroup = "239.2.5.6"


# 显示屏函数 (4 行文字)
def screen(line1, line2="", line3="", line4=""):
    # OLED 数据显示
    oled.fill(0)  # 清屏背景黑色
    oled.text(line1, 0, 0)
    oled.text(line2, 0, 20)
    oled.text(line3, 0, 38)
    oled.text(line4, 0, 56)
    oled.show()


# WIFI连接函数
def wifi_connect(ssid, pwd):
    wlan = network.WLAN(network.STA_IF)  # STA模式
    wlan.active(True)  # 激活接口
    start_time = time.time()  # 记录时间做超时判断

    if not wlan.isconnected():
        print('Connecting to network...')
        screen('Connecting wifi', 'ssid:'+ ssid)
        wlan.connect(ssid, pwd)

        while not wlan.isconnected():
            # LED闪烁提示
            wifi_led.value(1)
            time.sleep_ms(300)
            wifi_led.value(0)
            time.sleep_ms(300)

            # 超时判断,15秒没连接成功判定为超时
            if time.time() - start_time > 15:
                screen('WIFI Timeout!')
                print('WIFI Connected Timeout!')
                break

    if wlan.isconnected():
        # LED点亮
        wifi_led.value(1)
        # 串口打印信息
        print('network information:', wlan.ifconfig())
        # OLED数据显示
        screen('IP/Subnet/GW:',
               wlan.ifconfig()[0],
               wlan.ifconfig()[1],
               wlan.ifconfig()[2])
        return True
    else:
        return False


def recv():
    global udp_socket
    print("开始接收数据:")
    while True:
        recv_data = udp_socket.recvfrom(128)
        data = recv_data[0].decode("utf-8")
        print("接收到数据:", data)
        if data == "light_on":
            Car.light_on()
        elif data == "light_off":
            Car.light_off()
        elif data == "forward":
            Car.forward()
        elif data == "backward":
            Car.backward()
        elif data == "left":
            Car.turn_left(1)
        elif data == "right":
            Car.turn_right(1)
        elif data == "turn_left":
            Car.turn_left(0)
        elif data == "turn_right":
            Car.turn_right(0)
        elif data == "stop":
            Car.stop()
        elif data[:5] == "speed":
            speed = int(data[5:])
            Car.setspeed(speed)
        # else:
        #     Car.stop()


# 小车组播自身状态
def send_heartbeat(tim):
    global udp_socket
    distance = int(Car.getDistance())
    send_data = "car:" + str(distance)
    udp_socket.sendto(send_data.encode("utf-8"), (multiGroup, port))


def start(ssid, pwd):
    global udp_socket
    # 判断WIFI是否连接成功
    if wifi_connect(ssid, pwd):
        # 创建socket UDP 通信,接收组播信息
        udp_socket = usocket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        # 允许端口复用
        udp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # 小车绑定端口
        udp_socket.bind(('', port))
        # 声明该socket为多播类型  socket.IP_MULTICAST_TTL = 10 , usocket 不存在
        udp_socket.setsockopt(socket.IPPROTO_IP, 10, 255)
        # 开启RTOS定时器，编号为-1,周期200ms，发送心跳任务
        tim = Timer(-1)
        tim.init(period=200, mode=Timer.PERIODIC, callback=send_heartbeat)

        recv()  # 死循环接收遥控器消息


def info_display():
    screen("01Studio pyCar",
           "choose wifi:",
           " 503   JarryLeo ",
           "<KEY2      KEY1>")


def fun1(KEY1):
    time.sleep_ms(10)  # 消除抖动
    if KEY1.value() == 0:  # 确认按键被按下
        start('503', 'call25627')


def fun2(KEY2):
    time.sleep_ms(10)  # 消除抖动
    if KEY2.value() == 0:  # 确认按键被按下
        start('JarryLeo', '77887788')


KEY1.irq(fun1, Pin.IRQ_FALLING)  # 定义中断，下降沿触发
KEY2.irq(fun2, Pin.IRQ_FALLING)  # 定义中断，下降沿触发

# 上电显示信息
info_display()

