/*slep*/


/******************************参数初始化*************************************/
char getstr;                    // 存储蓝牙串口获取的8biti信息
const int Left_motor=8;         // 左电机(IN3) 输出0  前进   输出1 后退
const int Left_motor_pwm=9;     // 左电机PWM调速

const int Right_motor_pwm=10;   // 右电机PWM调速
const int Right_motor=11;       // 右电机后退(IN1)  输出0  前进   输出1 后退

const int key=A2;               // 定义按键 数字A2 接口
const int beep=A3;              // 定义蜂鸣器 数字A3 接口

const int Echo = A1;            // Echo回声脚(P2.0)
const int Trig =A0;             // Trig 触发脚(P2.1)
const int servopin=2;           // 设置舵机驱动脚到数字口2

const int SensorRight_2 = 5;   	// 左边红外避障传感器()
const int SensorLeft_2 = 6;   	// 右边红外避障传感器()

int Front_Distance = 0;         // 前探测
int Left_Distance = 0;          // 左探测
int Right_Distance = 0;         // 右探测
int Angle_Distance=0;           // 每一角度探测的值



void setup() {
   Serial.begin(9600);            // 蓝牙波透率
   
   /*电机端口*/
   /*LOW前进**HIGH后退*/
   pinMode(Left_motor,OUTPUT);     // PIN 8   8脚无PWM功能
   pinMode(Left_motor_pwm,OUTPUT); // PIN 9   (PWM)
   pinMode(Right_motor_pwm,OUTPUT);// PIN 10  (PWM) 
   pinMode(Right_motor,OUTPUT);    // PIN 11  (PWM)
   /*超声波端口*/
   pinMode(Echo, INPUT);           // 定义超声波输入脚
   pinMode(Trig, OUTPUT);          // 定义超声波输出脚
   pinMode(servopin,OUTPUT);       // 设定舵机接口为输出接口
   /*红外避障端口*/
   pinMode(SensorLeft_2, INPUT);   // 定义中间避障传感器为输入
   pinMode(SensorRight_2, INPUT);  // 定义中间避障传感器为输入
   /*其余端口初始化*/
   pinMode(key,INPUT);             // 定义按键接口为输入接口
   pinMode(beep,OUTPUT);           // 蜂鸣器
   
}

/******************************电机驱动函数************************************/
/*
*@name:run
*@function:小车前进
*/
void run() 
{
  digitalWrite(Right_motor,LOW);              // 右电机前进
  digitalWrite(Right_motor_pwm,HIGH);         // 右电机前进     
  analogWrite(Right_motor_pwm,80);           // PWM比例0~255调速，左右轮差异略增减
  
  digitalWrite(Left_motor,LOW);               // 左电机前进
  digitalWrite(Left_motor_pwm,HIGH);          // 左电机PWM     
  analogWrite(Left_motor_pwm,80);            // PWM比例0~255调速，左右轮差异略增减
  
  //delay(time * 100);                        // 执行时间，可以调整  
}
/*
*@name:brake
*@function:小车停止
*/
void brake()    
{
  digitalWrite(Right_motor_pwm,LOW);           // 右电机PWM 调速输出0      
  analogWrite(Right_motor_pwm,0);              // PWM比例0~255调速，左右轮差异略增减

  digitalWrite(Left_motor_pwm,LOW);            // 左电机PWM 调速输出0          
  analogWrite(Left_motor_pwm,0);               // PWM比例0~255调速，左右轮差异略增减
  
  //delay(time * 100);                         // 执行时间，可以调整  
}
/*
*@name:spin_left
*@function:小车左转(左轮后退，右轮前进)
*/
void spin_left()
{
  digitalWrite(Right_motor,LOW);               // 右电机前进
  digitalWrite(Right_motor_pwm,HIGH);          // 右电机前进     
  analogWrite(Right_motor_pwm,80);            // PWM比例0~255调速，左右轮差异略增减
  
  digitalWrite(Left_motor,HIGH);               // 左电机后退
  digitalWrite(Left_motor_pwm,HIGH);           // 左电机PWM     
  analogWrite(Left_motor_pwm,80);             // PWM比例0~255调速，左右轮差异略增减
  
 // delay(time * 100);	                       // 执行时间，可以调整  
}
/*
*@name:spin_right
*@function:小车右转(右轮后退，左轮前进)
*/
void spin_right()
{
  digitalWrite(Right_motor,HIGH);              // 右电机后退
  digitalWrite(Right_motor_pwm,HIGH);          // 右电机PWM输出1     
  analogWrite(Right_motor_pwm,80);            // PWM比例0~255调速，左右轮差异略增减
  
  
  digitalWrite(Left_motor,LOW);                // 左电机前进
  digitalWrite(Left_motor_pwm,HIGH);           // 左电机PWM     
  analogWrite(Left_motor_pwm,80);             // PWM比例0~255调速，左右轮差异略增减
  
  //delay(time * 100);	                       // 执行时间，可以调整    
}
/*
*@name:back
*@function:小车后退
*/
void back()
{
  digitalWrite(Right_motor,HIGH);              // 右电机后退
  digitalWrite(Right_motor_pwm,HIGH);          // 右电机前进     
  analogWrite(Right_motor_pwm,80);            // PWM比例0~255调速，左右轮差异略增减
  
  
  digitalWrite(Left_motor,HIGH);               // 左电机后退
  digitalWrite(Left_motor_pwm,HIGH);           // 左电机PWM     
  analogWrite(Left_motor_pwm,80);             // PWM比例0~255调速，左右轮差异略增减
  
  //delay(time * 100);                         // 执行时间，可以调整    
}

/******************************舵机测距函数************************************/
/*
*@name:Distance_test
*@function:量出前方距离 
*/
float Distance_test() 
{
  digitalWrite(Trig, LOW);                     // 给触发脚低电平2μs
  delayMicroseconds(2);
  digitalWrite(Trig, HIGH);                    // 给触发脚高电平10μs，这里至少是10μs
  delayMicroseconds(10);
  digitalWrite(Trig, LOW);                     // 持续给触发脚低电
  float Fdistance = pulseIn(Echo, HIGH);       // 读取高电平时间(单位：微秒)
  Fdistance= Fdistance/58;                     // 为什么除以58等于厘米，  Y米=（X秒*344）/2
                                               // X秒=（ 2*Y米）/344 ==》X秒=0.0058*Y米 ==》厘米=微秒/58
  return Fdistance;
}
/*
*@name:servopulse
*@function:定义一个脉冲函数，用来模拟方式产生PWM值舵机的范围是0.5MS到2.5MS 1.5MS 占空比是居中周期是20MS
*@attention:不同的PWM波占空比对应servo转动的不同角度
*/
void servopulse(int servopin,int myangle)
{
  int pulsewidth=(myangle*11)+500;             //将角度转化为500-2480 的脉宽值 这里的myangle就是0-180度  所以180*11+500=2480  11是为了换成90度的时候基本就是1.5MS
  digitalWrite(servopin,HIGH);                 //将舵机接口电平置高                                                           90*11+50=1490uS  就是1.5ms
  delayMicroseconds(pulsewidth);               //延时脉宽值的微秒数  这里调用的是微秒延时函数
  digitalWrite(servopin,LOW);                  //将舵机接口电平置低
  delay(20-(pulsewidth*0.001));                //延时周期内剩余时间  这里调用的是ms延时函数
}
/*
*@name:front_detection
*@function:探测前方距离
*/
void front_detection()
{
  //此处循环次数减少，为了增加小车遇到障碍物的反应速度
  for(int i=0;i<=5;i++){                       //产生PWM个数，等效延时以保证能转到响应角度
    servopulse(servopin,90);                   //模拟产生PWM
  }
  Front_Distance = Distance_test();
}
/*
*@name:left_detection
*@function:探测左边距离
*/
void left_detection()
{
  for(int i=0;i<=15;i++){                      //产生PWM个数，等效延时以保证能转到响应角度
    servopulse(servopin,175);                  //模拟产生PWM
  }
  Left_Distance = Distance_test();
}
/*
*@name:right_detection
*@function:探测右边距离
*/
void right_detection()
{
  for(int i=0;i<=15;i++){                      //产生PWM个数，等效延时以保证能转到响应角度
    servopulse(servopin,5);                    //模拟产生PWM
  }
  Right_Distance = Distance_test();
}
/*
*@name:Angle_detection
*@function:探测某一角度的值
*/
void Angle_detection(int angle)
{
  int times=10;
  //转到对应的位置
  for(int i=0;i<=times;i++){                   //产生PWM个数，等效延时以保证能转到响应角度
    servopulse(servopin,angle);                //模拟产生PWM
  }
  //开始探测距离
  Angle_Distance = Distance_test();            //Distan_test返回float，强制转化为int
  //发送距离信息                         
  if(Angle_Distance>=255)                      //将距离信息控制在255cm以；当为1111 1111时表示距离无限远
      Angle_Distance=0xFF;
  Serial.write(Angle_Distance);
}
/*
*@name:Ultrasonic_Detection
*@function:进行5-30-60-90-120-150-175度的超声波探测
*/
void Ultrasonic_Detection()
{
  Angle_detection(5);
  for(int i=30;i<=150;i+=30){
      Angle_detection(i);
  }
  Angle_detection(175);
}


/******************************其余功能函数************************************/
/*
*@name:keysacn
*@function:按键启动
*/
void keysacn()
{
  int val;
  val=digitalRead(key);                        //读取数字7 口电平值赋给val
  while(!digitalRead(key))                     //当按键没被按下时，一直循环  
    ;
  while(digitalRead(key))//当按键被按下时
  {
    delay(10);	                               //延时10ms
    val=digitalRead(key);                      //读取数字7 口电平值赋给val
    if(val==HIGH)                              //第二次判断按键是否被按下
      digitalWrite(beep,HIGH);		       //蜂鸣器响
      if(!digitalRead(key))	               //判断按键是否被松开
        digitalWrite(beep,LOW);		       //蜂鸣器停止
    else
      digitalWrite(beep,LOW);                  //蜂鸣器停止
  }
}


/******************************loop主函数************************************/
void loop() {
  keysacn();                              //按键启动
  int SR_2,SL_2;
  while(1){
    SR_2=digitalRead(SensorRight_2);
    SL_2=digitalRead(SensorLeft_2);
    front_detection();//测量前方距离
    //前方存在障碍物
    if((SR_2 == LOW || SL_2 == LOW)||(Front_Distance < 20)){
      digitalWrite(beep,HIGH);           //蜂鸣器响
      Serial.print("D");
      brake();
      delay(300);
      while(1){
          getstr=Serial.read();          //直到读到后退才能退出
          if(getstr=='B'){
            Serial.print("b");
            back(); 
            delay(1000);
            digitalWrite(beep,LOW);      //蜂鸣器停  
            break;
          }
      }
    }
    else
      digitalWrite(beep,LOW);            //蜂鸣器停    
    //接受蓝牙串口信息
    getstr=Serial.read();               //读取蓝牙串口获取的信息
    /*
    *F:前进
    *S:停下
    *B:后退
    *L:左转
    *R:右转
    *W:超声波扫描
    */
    if(getstr=='S'){
      Serial.print("s");
      brake();
    }
    else if(getstr=='F'){
      Serial.print("f");
      run();  
    }
    else if(getstr=='B'){
      Serial.print("b");
      back(); 
    }
    else if(getstr=='L'){
      Serial.print("l");
      spin_left();
    }
    else if(getstr=='R'){
      Serial.print("r");
      spin_right(); 
    }
    else if(getstr=='W'){
      Serial.print("i");                //watch start
      delay(20);
      Ultrasonic_Detection();            //进行角度扫描
      delay(20);
      Serial.print("e");                //watch end
    }
    else                                 //无指令waiting
        ;
  }
}










