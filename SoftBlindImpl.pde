import com.sonycsl.echo.eoj.device.housingfacilities.ElectricallyOperatedShade;

//////////////////////////////
//////////////////////////////
//////////////////////////////
// Blind class
//////////////////////////////
//////////////////////////////
//////////////////////////////
int blind_open ;
public class SoftBlindImpl extends ElectricallyOperatedShade {
  public byte[] mStatus = {0x30};// 電源状態は常にONだと仮定します。
  public byte[] mOpen = {0x41};  // 初期の開閉状態は「開」だと仮定します。(閉は0x42)

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

  // 電源のON/OFF操作ですが、実際には使われないという仮定です。
  protected boolean setOperationStatus(byte[] edt) {
    mStatus[0] = edt[0];
    try {
      inform().reqInformOperationStatus().send();
    } catch (IOException e) { e.printStackTrace();}
    return true;
  }
  protected byte[] getOperationStatus() { return mStatus; }

  // 開閉状態の変更です。
  protected boolean setOpenCloseSetting(byte[] edt) {
    mOpen[0] = edt[0];
    blind_open = edt[0] - 0x41 ;
    try {
      inform().reqInformOpenCloseSetting().send();
    } catch (IOException e) { e.printStackTrace();}
    //setupImage() ;
    
    return true;
  }

  protected byte[] getOpenCloseSetting() {return mOpen;}

  // より操作しやすい関数を作ってみました。
  // ※ElectricallyOperatedShadeからのオーバーライドではありません。
  public void setOpenCloseSettingBoolean(boolean is_open){
    try{
      if(is_open){
        this.set().reqSetOpenCloseSetting(new byte[]{(byte)0x41}).send();
      }else{
        this.set().reqSetOpenCloseSetting(new byte[]{(byte)0x42}).send();
      }
    }catch (IOException e){
      e.printStackTrace();
    }
  }
  // abstractメソッドの仕方ない実装です
  protected boolean setOpenCloseSetting2(byte[] edt) {return true;}
  protected byte[] getOpenCloseSetting2() {return mOpen;}

  protected boolean setDegreeOfOpeniNgLevel(byte[] edt) {return false;}
  protected byte[] getDegreeOfOpeniNgLevel() {return null;}
  //protected boolean setOpenCloseSetting(byte[] edt) {return false;}
  //protected byte[] getOpenCloseSetting() {return null;}
  //protected byte[] getOpenCloseSetting() {  return null;}

}