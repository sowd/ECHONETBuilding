import com.sonycsl.echo.eoj.device.housingfacilities.Buzzer ;
//////////////////////////////
//////////////////////////////
//////////////////////////////
// Buzzer class
//////////////////////////////
//////////////////////////////
//////////////////////////////
public class SoftBuzzerImpl extends Buzzer {
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

  byte[] mBuzzerSoundType = {0x31} ;
  protected boolean setBuzzerSoundType(byte[] edt){
    mBuzzerSoundType[0] = edt[0] ;
    return true ;
  }
  protected byte[] getBuzzerSoundType() { return mBuzzerSoundType; }
}