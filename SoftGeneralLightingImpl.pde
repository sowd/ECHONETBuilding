import com.sonycsl.echo.eoj.device.housingfacilities.GeneralLighting;

final int LIGHT_WATTS = 100 ;


//////////////////////////////
//////////////////////////////
//////////////////////////////
// Light class
//////////////////////////////
//////////////////////////////
//////////////////////////////

public class SoftGeneralLightingImpl extends GeneralLighting {
  float x,y ;
  public SoftGeneralLightingImpl(float x,float y){
    this.x = x ;
    this.y = y ;
  }
  public boolean getPowerBoolean(){
    return mStatus[0] == 0x30 ;
  }
  public void setPowerBoolean(boolean bOn){
    setOperationStatus( new byte[]{bOn?(byte)0x30:(byte)0x31} ) ;
  }
  
  public byte[] mStatus = {0x31};// 初期の電源状態はOFFだと仮定します。

  //////////////////////////////////
  // 以下、必須プロパティの適当な実装です。
  // 本当はもっときちんと実装しなければいけなさそうです。
  //////////////////////////////////

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

  // 電源のON/OFF操作です。
  protected boolean setOperationStatus(byte[] edt) {
    mStatus[0] = edt[0];

    try {
      inform().reqInformOperationStatus().send();
    } catch (IOException e) { e.printStackTrace();}
    //setupImage() ;
    return true;
  }
  
  // 現在の電源状態を問われた時の応答です
  protected byte[] getOperationStatus() {
    return mStatus;
  }

  // より操作しやすい関数を作ってみました。
  // ※GeneralLightingからのオーバーライドではありません。
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
  
  protected boolean setLightingModeSetting(byte[] edt) { return false; }
  protected byte[] getLightingModeSetting(){
    return null;
  }
}