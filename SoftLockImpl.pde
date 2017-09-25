import com.sonycsl.echo.eoj.device.housingfacilities.ElectricLock;
//////////////////////////////
//////////////////////////////
//////////////////////////////
// Lock class
//////////////////////////////
//////////////////////////////
//////////////////////////////
int lock_locked ;
public class SoftLockImpl extends ElectricLock {
  public byte[] mStatus = {0x30};// Always on
  public byte[] mLock = {0x41};  // Locked(0x42:Unlocked)

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

  protected byte[] getOperationStatus() { return mStatus; }

  // 開閉状態の変更です。
  protected boolean setLockSetting1(byte[] edt) {
    mLock[0] = edt[0];
    lock_locked = 0x42-edt[0] ;
    try {
      inform().reqInformLockSetting1().send();
    } catch (IOException e) { e.printStackTrace();}
    //setupImage() ;
    
    return true;
  }

  protected byte[] getLockSetting1() {return mLock;}

  // より操作しやすい関数を作ってみました。
  // ※ElectricallyOperatedShadeからのオーバーライドではありません。
  public void setLockSetting1Boolean(boolean bLock){
    try{
      if(bLock){
        this.set().reqSetLockSetting1(new byte[]{(byte)0x41}).send();
      }else{
        this.set().reqSetLockSetting1(new byte[]{(byte)0x42}).send();
      }
    }catch (IOException e){
      e.printStackTrace();
    }
  }
}