import com.sonycsl.echo.eoj.device.airconditioner.HomeAirConditioner;
final int AIRCON_WATTS = 300 ;


//////////////////////////////
//////////////////////////////
//////////////////////////////
// Airconditoner class
//////////////////////////////
//////////////////////////////
//////////////////////////////
int pw, mode, temp ;
public class SoftAirconImpl extends HomeAirConditioner {
  public byte[] mStatus = {0x31}; // 0x80:の電源状態はOFFだと仮定します。
  public byte[] mMode = {0x41};  // 初期モードは自動モードと仮定します。
  public byte[] mTemperature = {20}; // 初期の設定温度は18度と仮定します。

  //////////////////////////////////
  // 以下、必須プロパティの適当な実装です。
  // 本当はもっときちんと実装しなければいけなさそうです。
  //////////////////////////////////
  byte[] mLocation = {0x00};
  byte[] mStandardVersion = {0x01, 0x01, 0x61, 0x00}; // 0x82
  byte[] mFaultStatus = {0x42};
  byte[] mManufacturerCode = {0,0,0};  // 0x8A Usually unused. (NodeProfies's Manufacturer code IdentificationNumber are used as a whole

  protected boolean setInstallationLocation(byte[] edt) {return true;}
  protected byte[] getInstallationLocation() {return mLocation;}
  protected byte[] getStandardVersionInformation() {return mStandardVersion;}
  protected byte[] getFaultStatus() {  return mFaultStatus;}
  protected byte[] getManufacturerCode() {return mManufacturerCode;}
  
//  protected byte[] getStatusChangeAnnouncementPropertyMap() {  return null;}
//  protected byte[] getSetPropertyMap() {return null;}
//  protected byte[] getGetPropertyMap() {return null;}


  ///////////////////////////////////////////
  /// Optional settings.
  /// See https://github.com/SonyCSL/OpenECHO/blob/master/src/com/sonycsl/echo/eoj/device/DeviceObject.java
  byte[] mBusinessFacilityCode = {0x01,0x02,0x03};  // Defined by Manifacturer (3 bytes)
  byte[] mProductCode = {'M','o','e','A','i','r','c','o','n',0x00,0x00,0x00};  // ASCII name (12 bytes)
  byte[] mProductionNumber = {'4','1','3','1','4',0x00,0x00,0x00,0x00,0x00,0x00,0x00};  // Number in ASCII (12 bytes)
  byte[] mProductionDate = {(byte)((2016>>8)&0xFF),(byte)(2016&0xFF),6,8};  // Production date in binary (YYMD)
  @Override
  protected void setupPropertyMaps(){
    super.setupPropertyMaps() ;
    addGetProperty( EPC_BUSINESS_FACILITY_CODE ); // 0x8B
    addGetProperty( EPC_PRODUCT_CODE );//0x8C;
    addGetProperty( EPC_PRODUCTION_NUMBER );//0x8D;
    addGetProperty( EPC_PRODUCTION_DATE );//0x8E
  }
  @Override
  protected byte[] getBusinessFacilityCode() { return mBusinessFacilityCode ; }
  @Override
  protected byte[] getProductCode() { return mProductCode ; }
  @Override
  protected byte[] getProductionNumber() { return mProductionNumber ; }
  @Override
  protected byte[] getProductionDate() { return mProductionDate ; }

  // 以下はわりかし真面目な実装です。
  // 電源のON/OFF操作です。
  protected boolean setOperationStatus(byte[] edt) {
    if( mStatus[0] != edt[0] ){
 // smartMeter.baseEnergy += (edt[0]==0x30 ? AIRCON_WATTS : -AIRCON_WATTS ) ;
    }
    mStatus[0] = edt[0];
    pw = edt[0]-0x30 ;
    try {
      inform().reqInformOperationStatus().send();
    } catch (IOException e) { e.printStackTrace();}
    //setupImage() ;
    return true;
  }
  // 現在の電源状態を問われた時の応答です。
  protected byte[] getOperationStatus() { return mStatus; }

  // より操作しやすい関数を作ってみました。
  // ※HomeAirConditionerからのオーバーライドではありません。
  public void setOperationStatusBoolean(boolean is_on){
    // 中でSetterを使って機器を制御します。ここで、直接setOperationStatusを
    // 呼びだしてはいけません。
    try{
      if(is_on){
        this.set().reqSetOperationStatus(new byte[]{(byte)0x30}).send();
      }else{
        this.set().reqSetOperationStatus(new byte[]{(byte)0x31}).send();
      }
    }catch (IOException e){
      e.printStackTrace();
    }
  }

  // 動作モードの変更です。
  protected boolean setOperationModeSetting(byte[] edt) {
    mMode[0] = edt[0];
    mode = edt[0] - 0x41 ;
    try {
      inform().reqInformOperationModeSetting().send();
    } catch (IOException e) { e.printStackTrace();}
    //setupImage() ;
    
    return true;
  }

  protected byte[] getOperationModeSetting() {return mMode;}

  // より操作しやすい関数を作ってみました。
  // ※HomeAirConditionerからのオーバーライドではありません。
  public void setOperationModeSettingInt(int mode) {
    byte toSend = (byte)(0x41+mode);
    try{
      this.set().reqSetOperationModeSetting(new byte[]{toSend}).send();
    } catch (IOException e){
      e.printStackTrace();
    }
  }


  // 温度の変更です
  protected boolean setSetTemperatureValue(byte[] edt) {
    temp = mTemperature[0] = edt[0];
    //setupImage() ;
    return true;
  }

  protected byte[] getSetTemperatureValue() {  return mTemperature;}

  // より操作しやすい関数を作ってみました。
  // ※HomeAirConditionerからのオーバーライドではありません。
  protected void setTemperatureValueInt(int temp) {
    try{
      this.set().reqSetSetTemperatureValue(new byte[]{(byte)temp}).send();
    } catch(IOException e){
      e.printStackTrace();
    }
  }
}