import java.io.IOException;
import processing.net.*;
import controlP5.*;

import com.sonycsl.echo.Echo;

final int floor = 1; // 1,2 or 3

final boolean bClickMode = false ;

ControlP5 cp5;
PImage bgImg ;

final int lightposs[][][] = {
  {// First floor
    {213,81},{273,80},{322,70},{321,100},{355,55},{397,54},{348,78},{345,100},{364,87},{385,87},{408,80},{406,100},{431,94},{210,146},{209,189},{228,144},{227,190},{275,118},{331,117},{380,117},{274,170},{273,213},{273,262},{271,308},{273,360},{334,361},{395,359},{457,362},{519,360},{579,361},{208,255},{207,302},{208,352},{208,407},{268,377},{289,377},{271,404},{289,403},{311,407},{327,406},{368,400},{436,399},{501,398},{562,399},{612,402}
  }
  ,{// Second floor
    {211,79},{252,77},{275,79},{294,66},{321,63},{292,88},{328,88},{352,75},{380,72},{404,73},{303,116},{368,117},{422,116},{210,147},{211,181},{265,153},{264,181},{288,167},{208,248},{208,301},{207,330},{209,383},{289,237},{247,238},{287,322},{246,322},{311,361},{377,360},{442,360},{511,360},{581,358},{270,404},{289,403},{308,403},{327,402},{368,400},{417,400},{451,401},{478,400},{506,399},{542,397},{578,397},{607,399}
  }
  ,{// Third floor
    {210,78},{296,78},{341,77},{385,78},{208,163},{208,217},{210,269},{210,305},{210,341},{212,395},{344,116},{399,114},{266,158},{265,208},{267,284},{282,398},{310,407},{327,407},{364,397},{421,397},{479,396},{533,397},{588,399},{342,360},{395,361},{456,361},{516,361},{577,361}
  }
};
final int lightpos[][] = lightposs[floor-1] ;

SoftGeneralLightingImpl[] lights ;

class ClickedPos{float x,y;};
ArrayList<ClickedPos> clickedPosList ;

void settings() {
  bgImg = loadImage("FloorPlans/"+floor+".jpg");
  size(800,480);
  
  if(bClickMode){
    clickedPosList = new ArrayList<ClickedPos>() ;
  } else {
    lights = new SoftGeneralLightingImpl[lightpos.length] ;
    for( int li=0;li<lightpos.length;++li ){
      lights[li] = new SoftGeneralLightingImpl(lightpos[li][0],lightpos[li][1]) ;
    }
    println(lightpos.length+" lights defined.") ;
  }
}

void setup(){
  if(bClickMode) return ;
  
  noCursor();
  /*  cp5 = new ControlP5(this);
  // The background image must be the same size as the parameters
  // into the size() method. In this program, the size of the image
  // is 650 x 360 pixels.
*/
  // System.outにログを表示するようにします。
  // Echo.addEventListener( new Echo.Logger(System.out) ) ;

  try {
      Echo.start( new MyNodeProfile(),lights);
  } catch( IOException e){ e.printStackTrace(); }


}

boolean bRandomOnOff = true ;
final int randomOnOffFreq = 60 ;
int randomOnOffCountdown = randomOnOffFreq ;

boolean prevPressed = false ;
void draw() {
  background(bgImg);
  
  if( bClickMode ){
    if( mousePressed && !prevPressed ){
      print("{"+mouseX+","+mouseY+"},") ;
      ClickedPos cp = new ClickedPos() ;
      cp.x = mouseX ;
      cp.y = mouseY ;
      
      clickedPosList.add(cp) ;
    }
    prevPressed = mousePressed ;
    
    fill(255,0,0) ;
    for( int cpi=0;cpi<clickedPosList.size();++cpi )
      ellipse( clickedPosList.get(cpi).x  , clickedPosList.get(cpi).y ,5,5) ;
    
    return ;
  }
  
  if( bRandomOnOff ){
    if( --randomOnOffCountdown == 0 ){
      randomOnOffCountdown = randomOnOffFreq + (int)( (random(1)-0.5) * randomOnOffFreq ) ;
      lights[ (int)random(lights.length) ].setPowerBoolean( random(1)<0.5 ) ;
    }
  }
  
    
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