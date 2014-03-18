#define DEBUGON  // スタート時にBMA180のステータスレジスタ類を表示

#include <Wire.h>
#include <bma180.h>

#define CALIB_TIMES 10  // キャリブレーション用データ取得回数(平均値取得)

BMA180 bma180;

volatile byte newData=0;
volatile unsigned int countISR=0;
unsigned int served=0;

int offset_x;
int offset_y;
int offset_z;

/*
 * bma180のオフセット値の計算
 */
void bma180_calib(void)
{
  long valx=0;
  long valy=0;
  long valz=0;
  
  for(int i=0;i<CALIB_TIMES;++i) {
    bma180.readAccel();
    valx += bma180.x;
    valy += bma180.y;
    valz += bma180.z;
  }
  offset_x = valx / CALIB_TIMES;
  offset_y = valy / CALIB_TIMES;
  offset_z = valz / CALIB_TIMES;
  
  Serial.print("offset x : ");
  Serial.print(offset_x);
  Serial.print(",y : ");
  Serial.print(offset_y);
  Serial.print(",z : ");
  Serial.println(offset_z);
  
}

void setup()
{
  Wire.begin();
//  Serial.begin(115200);
  Serial.begin(230400);
  bma180.SetAddress((int)BMA180_DEFAULT_ADDRESS);
  bma180.SoftReset();
  bma180.enableWrite();
  int sversion;
  int id;
  bma180.getIDs(&id,&sversion);
  Serial.print("Id = ");
  Serial.print(id,DEC);
  Serial.print(" v.");
  Serial.println(sversion,HEX);
  bma180.SetFilter(bma180.F10HZ);
  bma180.setGSensitivty(bma180.G15);
  bma180.SetSMPSkip();
  bma180.disableWrite();
  delay(2000);

#ifdef DEBUGON
     bma180.readAccel();
      Serial.print("t=");
      Serial.print(bma180.temp);
      Serial.print("[");
      Serial.print(bma180.x,DEC);
      Serial.print(" ");
      Serial.print(bma180.y,DEC);
      Serial.print(" ");
      Serial.print(bma180.z,DEC);
      Serial.println("]");

     Serial.print("filter reg=");
     Serial.println(bma180.getRegValue(0x20),BIN);
     Serial.print("status_reg1=");
     Serial.println(bma180.getRegValue(0x09),BIN);
     Serial.print("status_reg2=");
     Serial.println(bma180.getRegValue(0x0A),BIN);
     Serial.print("status_reg3=");
     Serial.println(bma180.getRegValue(0x0B),BIN);
     Serial.print("status_reg4=");
     Serial.println(bma180.getRegValue(0x0C),BIN);
     Serial.print("ctrl_reg0=");
     Serial.println(bma180.getRegValue(0x0d),BIN);
     Serial.print("ctrl_reg1=");
     Serial.println(bma180.getRegValue(0x0e),BIN);
     Serial.print("ctrl_reg2=");
     Serial.println(bma180.getRegValue(0x0f),BIN);
     Serial.print("ctrl_reg3=");
     Serial.println(bma180.getRegValue(0x21),BIN);
     Serial.print("ctrl_reg4=");
     Serial.println(bma180.getRegValue(0x22),BIN);
 #endif
 
  bma180_calib();
}

void loop()
{
      bma180.readAccel();
      Serial.print(millis());
      Serial.print(",");
      Serial.print((bma180.x - offset_x),DEC);
      Serial.print(",");
      Serial.print((bma180.y - offset_y),DEC);
      Serial.print(",");
      Serial.println((bma180.z - offset_z),DEC);
      
//      delay(100);
}



