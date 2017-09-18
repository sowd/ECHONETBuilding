import java.io.IOException;
import processing.net.*;
import controlP5.*;

import com.sonycsl.echo.Echo;

ControlP5 cp5;
PImage bgImg ;

final int lightpos[][] = {
{209,77},{275,79},{320,69},{322,100},{359,57},{347,78},{344,101},{364,89},{399,55},{387,86},{407,78},{408,100},{430,63},{428,92},{209,145},{271,145},{326,118},{363,116},{400,116},{207,193},{228,190},{270,191},{206,245},{206,275},{276,238},{274,280},{206,301},{272,322},{207,334},{206,365},{211,407},{247,388},{246,413},{270,377},{287,378},{270,407},{290,408},{306,378},{318,378},{330,377},{311,407},{331,406},{360,400},{388,400},{432,399},{496,398},{566,397},{609,398},{324,361},{376,362},{426,359},{470,362},{505,360},{558,360},{606,359},{637,364},{640,388},{637,417}
};

SoftGeneralLightingImpl[] lights ;

void settings() {
  bgImg = loadImage("FloorPlans/1.jpg");
  size(800,480);
  
  lights = new SoftGeneralLightingImpl[lightpos.length] ;
  for( int li=0;li<lightpos.length;++li ){
    lights[li] = new SoftGeneralLightingImpl(lightpos[li][0],lightpos[li][1]) ;
  }
  println(lightpos.length+" lights defined.") ;
}

void setup() {  
/*  cp5 = new ControlP5(this);
  // The background image must be the same size as the parameters
  // into the size() method. In this program, the size of the image
  // is 650 x 360 pixels.
*/
  // System.outにログを表示するようにします。
  // Echo.addEventListener( new Echo.Logger(System.out) ) ;

  try {
      Echo.start( new MyNodeProfile(),lights);
      /*
      pw = aircon.mStatus[0]-0x30 ;
      mode = aircon.mMode[0]-0x41 ;
      temp = aircon.mTemperature[0] ;
      light_pw = light.mStatus[0]-0x30 ;
      blind_open = blind.mOpen[0]-0x41 ;
      lock_locked = 0x42-lock.mLock[0] ;

      room_temp_x10 = ((exTempSensor.mTemp[0]&0xff)<<8) | (exTempSensor.mTemp[1]&0xff) ;
      if( room_temp_x10 > 0x8000 ) room_temp_x10 = room_temp_x10 - 0x10000 ;
      */
  } catch( IOException e){ e.printStackTrace(); }

  println("int[] lightpos = [");

}

boolean bRandomOnOff = true ;
final int randomOnOffFreq = 30 ;
int randomOnOffCountdown = randomOnOffFreq ;

boolean prevPressed = false ;
void draw() {
  if( mousePressed && !prevPressed ){
    print("["+mouseX+","+mouseY+"],") ;
  }
  prevPressed = mousePressed ;
  
  if( bRandomOnOff ){
    if( --randomOnOffCountdown == 0 ){
      randomOnOffCountdown = randomOnOffFreq ;
      lights[ (int)random(lights.length) ].setPowerBoolean( random(1)<0.5 ) ;
    }
  }
  
  background(bgImg);
    
  final int r = 11 ;
  for( int li=0;li<lights.length;++li ){
    SoftGeneralLightingImpl light = lights[li] ;
    if( light.getPowerBoolean() )
      fill(255,0,0) ;
    else
      fill(0,255,0) ;

    ellipse( light.x  , light.y ,r*2,r*2) ;
  }
}

// Utility functions
void setIntValueTo4Bytes( int inval,byte[] outArray,int outStartIndex ){
  outArray[outStartIndex+3] = (byte)(inval%256) ;
  outArray[outStartIndex+2] = (byte)((inval>>8)%256) ;
  outArray[outStartIndex+1] = (byte)((inval>>16)%256) ;
  outArray[outStartIndex+0] = (byte)((inval>>24)%256) ;
}
int getIntValueFrom4Bytes( byte[] srcArray,int srcStartIndex ){
  return (int)(srcArray[srcStartIndex]&0xFF)<<24
      |  (int)(srcArray[srcStartIndex+1]&0xFF)<<16
      |  (int)(srcArray[srcStartIndex+2]&0xFF)<<8
      |  (int)(srcArray[srcStartIndex+3]&0xFF) ;
}