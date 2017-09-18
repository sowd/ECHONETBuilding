import com.sonycsl.echo.eoj.device.sensor.TemperatureSensor ;
//////////////////////////////
//////////////////////////////
//////////////////////////////
// TempSensor class
//////////////////////////////
//////////////////////////////
//////////////////////////////
int room_temp_x10 ;
public class SoftTempSensorImpl extends TemperatureSensor {
  public byte[] mStatus = {0x30};// 電源状態は常にONだと仮定します。
  public byte[] mTemp = {0,(byte)220};  // 初期温度は22度だと仮定します。

  byte[] mLocation = {0x00};
  byte[] mVersion = {0x01, 0x01, 0x61, 0x00};
  byte[] mFaultStatus = {0x42};
  byte[] mManufacturerCode = {0,0,0};

  protected boolean setInstallationLocation(byte[] edt) {return true;}
  protected byte[] getInstallationLocation() {return mLocation;}
  protected byte[] getStandardVersionInformation() {return mVersion;}
  protected byte[] getFaultStatus() {  return mFaultStatus;}
  protected byte[] getManufacturerCode() {return mManufacturerCode;}
//  protected byte[] getStatusChangeAnnouncementPropertyMap() {  return null;}
//  protected byte[] getSetPropertyMap() {return null;}
//  protected byte[] getGetPropertyMap() {return null;}

  // 電源のON/OFF操作ですが、実際には使われないという仮定です。
  protected boolean setOperationStatus(byte[] edt) {
    mStatus[0] = edt[0];
    try {
      inform().reqInformOperationStatus().send();
    } catch (IOException e) { e.printStackTrace();}
    return true;
  }
  protected byte[] getOperationStatus() { return mStatus; }

  protected byte[] getMeasuredTemperatureValue() {return mTemp;}

  // 温度変更用関数です。本来温度センサー値は外から変更できないので、
  // エミュレータ専用の機能です。
  // ※TemperatureSensorからのオーバーライドではありません。
  public void setTemp(int temp_x10){
    room_temp_x10 = temp_x10 ;
    if( temp_x10<0 )  temp_x10 = 0x10000+temp_x10 ;
    mTemp[0] = (byte)(temp_x10/256) ;
    mTemp[1] = (byte)(temp_x10%256) ;
  }
}