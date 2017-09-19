import com.sonycsl.echo.eoj.profile.NodeProfile;

public class MyNodeProfile extends NodeProfile {
  byte[] mManufactureCode = {0,0,0};  // 0x8A
  byte[] mStatus = {0x30};            // 0x80
  byte[] mVersion = {1,1,1,0};        // 0x82
  byte[] mIdNumber = {(byte)0xFE,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,floor /*0*/};  // 0x83
  byte[] mUniqueId = {0,0};           // 0xBF 
  @Override
  protected byte[] getManufacturerCode() {return mManufactureCode;}
  @Override
  protected byte[] getOperatingStatus() {  return mStatus;  }
  @Override
  protected byte[] getVersionInformation() {return mVersion;}
  @Override
  protected byte[] getIdentificationNumber() {return mIdNumber;}
  @Override
  protected boolean setUniqueIdentifierData(byte[] edt) {
    if((edt[0] & 0x40) != 0x40)   return false;
    mUniqueId[0] = (byte)((edt[0] & (byte)0x7F) | (mUniqueId[0] & 0x80));
    mUniqueId[1] = edt[1];
    return true;
  }
  @Override
  protected byte[] getUniqueIdentifierData() {return mUniqueId;}
//  protected byte[] getStatusChangeAnnouncementPropertyMap() {  return null;}
//  protected byte[] getSetPropertyMap() {return null;}
//  protected byte[] getGetPropertyMap() {return null;}
  @Override
  protected void setupPropertyMaps(){
    super.setupPropertyMaps() ;
    addGetProperty( EPC_MANUFACTURER_CODE ); // 0x8B
  }  
}