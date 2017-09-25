import com.sonycsl.echo.eoj.device.housingfacilities.SmartElectricEnergyMeter ;
import java.util.Calendar ;


// 何日前の0:00からスマートメーターのログ取得を開始したかを示す。0なら今日。
final int SMART_METER_LOG_START_DAY = 2 ;
// スマートメーターの履歴データを更新する間隔
final int SMART_METER_DATA_UPDATE_INTERVAL = 300 ;

//////////////////////////////
//////////////////////////////
//////////////////////////////
// Smart meter class (0x0288
// https://github.com/SonyCSL/OpenECHO/blob/master/src/com/sonycsl/echo/eoj/device/housingfacilities/SmartElectricEnergyMeter.java
//////////////////////////////
//////////////////////////////
//////////////////////////////
public class SoftElectricEnergyMeterImpl extends SmartElectricEnergyMeter  {
  public byte[] mStatus = {0x30};// Always on
  public byte[] mLock = {0x41};  // Locked(0x42:Unlocked)

  byte[] mLocation = {0x00};
  byte[] mVersion = {0x01, 0x01, 0x61, 0x00};
  byte[] mFaultStatus = {0x42};
  byte[] mManufacturerCode = {0,0,0};
  
  SoftElectricEnergyMeterImpl(){
    super() ;

  }

  @Override
  protected void setupPropertyMaps(){
    super.setupPropertyMaps() ;
    addGetProperty(EPC_NUMBER_OF_EFFECTIVE_DIGITS_FOR_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY ) ;  // D7
    addGetProperty(EPC_MEASURED_CUMULATIVE_AMOUNT_OF_ELECTRIC_ENERGY_NORMAL_DIRECTION ) ;        // E0
    addGetProperty(EPC_UNIT_FOR_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY_NORMAL_AND_REVERSE_DIRECTIONS ) ;  // E1
    addGetProperty(EPC_HISTORICAL_DATA_OF_MEASURED_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY_NORMAL_DIRECTION ) ;  // E2
    addSetProperty(EPC_DAY_FOR_WHICH_THE_HISTORICAL_DATA_OF_MEASURED_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY_IS_TO_BE_RETRIEVED) ;  // E5
    addGetProperty(EPC_DAY_FOR_WHICH_THE_HISTORICAL_DATA_OF_MEASURED_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY_IS_TO_BE_RETRIEVED) ;  // E5
    addGetProperty(EPC_MEASURED_INSTANTANEOUS_ELECTRIC_ENERGY ) ; // E7
    addGetProperty(EPC_MEASURED_INSTANTANEOUS_CURRENTS ) ; // E8
    addGetProperty(EPC_CUMULATIVE_AMOUNTS_OF_ELECTRIC_ENERGY_MEASURED_AT_FIXED_TIME_NORMAL_DIRECTION ) ; // EA
/*    addGetProperty( EPC_BUSINESS_FACILITY_CODE ); // 0x8B
    addGetProperty( EPC_PRODUCT_CODE );//0x8C;
    addGetProperty( EPC_PRODUCTION_NUMBER );//0x8D;
    addGetProperty( EPC_PRODUCTION_DATE );//0x8E
*/
  }


  protected boolean setInstallationLocation(byte[] edt) {return true;}
  protected byte[] getInstallationLocation() {return mLocation;}
  protected byte[] getStandardVersionInformation() {return mVersion;}
  protected byte[] getFaultStatus() {  return mFaultStatus;}
  protected byte[] getManufacturerCode() {return mManufacturerCode;}
//  protected byte[] getStatusChangeAnnouncementPropertyMap() {  return null;}
//  protected byte[] getSetPropertyMap() {return null;}
//  protected byte[] getGetPropertyMap() {return null;}

  protected byte[] getOperationStatus() { return mStatus; }
  
  
  // D7 積算電力量有効桁数 (1～8)
  byte[] numberOfEffectiveDigitsForCumulativeAmountsOfElectricEnergy = new byte[]{0x08} ;
    @Override
    protected byte[] getNumberOfEffectiveDigitsForCumulativeAmountsOfElectricEnergy() {
        return numberOfEffectiveDigitsForCumulativeAmountsOfElectricEnergy ;
    }

  // E0 積算電力量 in kWh
  // 現在はEAと同じく、getCumlativeEnergy()を用いて
  // 30分間隔サンプルの最新値を返すようになっている。
  byte[] measuredCumulativeAmountOfElectricEnergyNormalDirection = new byte[]{1,0,0,0} ;
    @Override
    protected byte[] getMeasuredCumulativeAmountOfElectricEnergyNormalDirection() {
  float energy = getCumlativeEnergy( 0 , getLatestIndexHalfHour() ) ;
  setIntValueTo4Bytes( (energy>=0 ? (int)(energy / getCumUnit()) : 0xFFFFFFFE)
    , measuredCumulativeAmountOfElectricEnergyNormalDirection
    , 4 ) ;
        return measuredCumulativeAmountOfElectricEnergyNormalDirection ;
    }

  // E1 積算電力量の単位 0～0D. 0x02は0.01kWh
  byte[] unitForCumulativeAmountsOfElectricEnergyNormalAndReverseDirections = new byte[]{0x02} ;
    @Override
    protected byte[] getUnitForCumulativeAmountsOfElectricEnergyNormalAndReverseDirections() {
        return unitForCumulativeAmountsOfElectricEnergyNormalAndReverseDirections;
    }

  // E2 積算電力量 計測値履歴１ (正方向計測値)
  // 積算履歴収集日１と該当収集日の 24 時間 48 コマ分（0 時 0 分～23 時 30 分）の正方向の定時
  // 積算電力量計測値の履歴データを時系列順に上位バイトからプロパティ値として示す。
  // 1～2 バイト目：積算履歴収集日 0x0000～0x0063(0～99) 3 バイト目以降：積算電力量計測値
  // 0x00000000～0x05F5E0FF (0～99,999,999)
  // 下の方の、getCumlativeEnergy()を用いて計算。
  byte[] historicalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection = new byte[194]  ;
  @Override
    protected byte[] getHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection() {
    int day = mDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved[0] ;
    // very naive implementation that requires O(n^2)
    historicalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection[0] = 0 ;
    historicalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection[1] = (byte)day ;

    final float cumUnit = getCumUnit() ;
    for( int di=0;di<48;++di ){
  float cumE = getCumlativeEnergy(day,di) ;
  setIntValueTo4Bytes(
    ( cumE >= 0 ? (int)(cumE/cumUnit) : 0xFFFFFFFE )
    ,historicalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection
    ,di*4+2 ) ;
    }
    return historicalDataOfMeasuredCumulativeAmountsOfElectricEnergyNormalDirection ;
  }

  // E3は逆方向の積算電力量計測値、E4は逆方向の積算電力量計測値履歴。
  // 必須プロパティだがMoekadenRoomでは意味のある値を返すように実装していない。
  // (プロパティ自体は存在するが、返答としてはエラーが返るはず

  // E5 積算履歴収集日 30分毎の計測値履歴データを収集する日を示す。 
  // 0x00～0x63 ( 0～99)  0:当日 1～99:前日の日数
  byte[] mDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved = {(byte)0} ;
  @Override
  boolean setDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved(byte[] edt) {
    //println("Day for retrieval => "+edt[0] ) ;
  mDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved[0] = edt[0] ;
  return true;
  }
  @Override
  protected byte[] getDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved() {
  return mDayForWhichTheHistoricalDataOfMeasuredCumulativeAmountsOfElectricEnergyIsToBeRetrieved ;
  }

  // E7 瞬時電力計測値 in W.
  // 0x80000001～0x7FFFFFFD (-2,147,483,647～ 2,147,483,645)
  // 下の方の、getInstantaneousEnergy()を用いて計算。
  byte[] measuredInstantaneousElectricEnergy = new byte[4] ;
  @Override
  protected byte[] getMeasuredInstantaneousElectricEnergy() {
  byte[] re = new byte[4] ;
  setIntValueTo4Bytes( (int)getInstantaneousEnergy() , re , 0 ) ;
  return re ;
  }

  // E8 瞬時電力計測値 in 0.1A.
  // 実効電流値の瞬時値を 0.1A 単位で R 相 T 相を並べて示す。単相 2 線式の場合は、T 相に0x7FFE をセット。
  // 0x8001～0x7FFD（R 相）：0x8001～0x7FFD（T 相）(-3,276.7～3,276.5):(-3,276.7～3,276.5)
  // 下のほうの、getInstantaneousCurrentR() と getInstantaneousCurrentT() を用いて計算。
  byte[] measuredInstantaneousCurrents = new byte[4] ;
  @Override
  protected byte[] getMeasuredInstantaneousCurrents() {
  float r = getInstantaneousCurrentR() , t = getInstantaneousCurrentT() ;
  byte[] buf = new byte[8] ;
  setIntValueTo4Bytes( (int)(r*10) , buf , 0 ) ;
  setIntValueTo4Bytes( (int)(t*10) , buf , 4 ) ;

  return new byte[]{buf[2],buf[3],buf[6],buf[7]} ;
  }


  // EA 最新の 30 分毎の計測時刻における積算電力量(正方向計測値)を、計測年月日を 4 バイト、
  // 計測時刻を 3 バイト、積算電力量（正方向計測値）4 バイトで示す。
  // ・計測年月日 YYYY:MM:DD ・計測時刻 hh:mm:ss ・積算電力量 10進表記で最大8桁
  // 下の方の getCumlativeEnergy() から計算される。計測年月日・時刻は現在時刻にセットされる。
    @Override
    protected byte[] getCumulativeAmountsOfElectricEnergyMeasuredAtFixedTimeNormalDirection() {
      byte[] ret = new byte[15] ;

      Calendar c = Calendar.getInstance();
      ret[0] = (byte)(c.get(Calendar.YEAR)/256) ;
      ret[1] = (byte)(c.get(Calendar.YEAR)%256) ;
      ret[2] = (byte)(c.get(Calendar.MONTH) + 1) ;
      ret[3] = (byte)(c.get(Calendar.DATE)) ;
      ret[4] = (byte)(c.get(Calendar.HOUR_OF_DAY)) ;
      ret[5] = (byte)(c.get(Calendar.MINUTE)<30 ? 0 : 30) ;
      ret[6] = 0 ;

      int indexHalfHour = getLatestIndexHalfHour() ;

      float energy = getCumlativeEnergy( indexHalfHour==47?1:0 , indexHalfHour ) ;
      int energy_long = (energy >= 0 ? (int)(energy / getCumUnit()) : 0xFFFFFFFE);
      setIntValueTo4Bytes( energy_long , ret , 7 ) ;

      return ret;
    }

  // EBはDAの逆方向版だが、MoekadenRoomでは実装していない。



  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // 電力関連値の設定・コールバック。
  // これを変更することで、任意の電力値を返すように変更できる。
  // デフォルトではランダムな値を返すようにしている。
  // ※ただし、エアコンや照明の具合でちょっとだけ増減させている。
  int baseEnergy = 0 ;
  int getInstantaneousEnergy(){ // 現在の電力瞬時値をW単位で返す。
  // Use noise() (rather than random()) for the value continuity
  return baseEnergy + (int)( noise(0.3*(int)(millis()/1000))*2000 );
  }

  // 現在の電力瞬時値（R相とT相）をA単位で返す。デフォルトは上記
  // getInstantaneousEnergy()を100で割ったもの。
  float getInstantaneousCurrentR(){ return getInstantaneousEnergy()/100.0f;  }
  float getInstantaneousCurrentT(){ return getInstantaneousEnergy()/100.0f;  }

  // 30分スロットごとの積算電力値ログ in kWh。単調増加でなくてはならない。
  // 引数１は「日」、今日を0とし、数が多くなるほど前の日の30分スロットのデータ。最大99.
  // 引数２は「３０分スロット番号」これは、0なら0:00, 1なら0:30のように、１日を30分ごとに
  //   区切った時のどの履歴を示すかのインデックス。0以上47以下の値。
  // エラーの場合は-1を返すこと。
  // 例えば、昨日の16:00のデータの場合、1,32となる。
  float[] cumLog ;
  int prevAccessLatestHalfHour = -1 ;
  final float MAX_CUMENERGY_PER_HOUR = 2.0f ;
  float getCumlativeEnergy(int day,int indexHalfHour){
  int latestHalfHour = getLatestIndexHalfHour() ;

  if( cumLog == null ){  // データ初期化。
    int loglen = (SMART_METER_LOG_START_DAY+1) * 48 ;
    cumLog = new float[loglen] ;
    cumLog[0] = 0 ;
    for( int li=1;li<loglen;++li )
      cumLog[li] = cumLog[li-1] + random(MAX_CUMENERGY_PER_HOUR/2) ;  // 30分間隔なので2で割る。
  }

  if( latestHalfHour == 0 && prevAccessLatestHalfHour == 47){
    // New day should be added to the history data (cumLog)
    float[] newLog = new float[cumLog.length+48] ;
    // Copy existing data
    for( int i = 0 ; i < cumLog.length ; ++i )  newLog[i] = cumLog[i] ;
    // add now data at the tail
    for( int i = 0 ; i < 48 ; ++i )
      newLog[cumLog.length+i] = newLog[cumLog.length+i-1] + random(MAX_CUMENERGY_PER_HOUR/2) ;
    cumLog = newLog ;
  }
  prevAccessLatestHalfHour = latestHalfHour ;

  if( day == 0 && indexHalfHour > latestHalfHour )
    return -1 ;  // 未来のデータ

  int stored_days = cumLog.length/48 ; // including today
  if( day >= stored_days )
    return -1 ;  // ログ取得開始前

  return cumLog[(stored_days-day-1)*48+indexHalfHour] ;
  }
  // 現在時刻を参照して、最新のデータが入っているlatestIndexHalfHourを返す。
  int getLatestIndexHalfHour(){
  Calendar c = Calendar.getInstance();
  return c.get(Calendar.HOUR_OF_DAY)*2 + (c.get(Calendar.MINUTE)<30 ? 0 : 1) ;
  }

  // 履歴の単位を返すユーティリティ関数。
  float getCumUnit(){
  int b = unitForCumulativeAmountsOfElectricEnergyNormalAndReverseDirections[0] ;
  return pow( 10, (b<5?-b:b-10) ) ;
  }

}