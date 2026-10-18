package com.nikhilgaurav.edgeailab

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.roundToInt

private val bg=Color(0xFF080A12); private val panel=Color(0xFF101522); private val line=Color(0xFF283348)
private val cyan=Color(0xFF62F5E6); private val lime=Color(0xFFD9FF70); private val purple=Color(0xFFA895FF)
private val muted=Color(0xFF8C9AB4); private val white=Color(0xFFF2F6FF); private val red=Color(0xFFFF7D9B)

class MainActivity:ComponentActivity(){
 override fun onCreate(savedInstanceState:Bundle?){super.onCreate(savedInstanceState);window.statusBarColor=android.graphics.Color.rgb(8,10,18);window.navigationBarColor=android.graphics.Color.rgb(8,10,18)
  setContent{MaterialTheme(colorScheme=darkColorScheme(primary=lime,secondary=cyan,background=bg,surface=panel,onPrimary=bg,onBackground=white,onSurface=white)){EdgeApp()}}
 }
}
@Composable private fun EdgeApp(){
 var intensity by remember{mutableFloatStateOf(1f)};var seed by remember{mutableIntStateOf(7)};var runs by remember{mutableIntStateOf(0)}
 var result by remember{mutableStateOf("READY")};var confidence by remember{mutableFloatStateOf(0f)};var features by remember{mutableStateOf(listOf(31,12,127))};var ran by remember{mutableStateOf(false)}
 val ctx=LocalContext.current;val progress by animateFloatAsState(if(ran)confidence else 0f,tween(850),label="progress");val rc=if(result=="ALERT")red else lime
 Column(Modifier.fillMaxSize().background(Brush.verticalGradient(listOf(Color(0xFF10182A),bg,bg)))){
  Row(Modifier.fillMaxWidth().background(bg).padding(18.dp),verticalAlignment=Alignment.CenterVertically){
   Box(Modifier.size(42.dp).clip(RoundedCornerShape(13.dp)).background(cyan.copy(alpha=.12f)).border(1.dp,cyan.copy(alpha=.4f),RoundedCornerShape(13.dp)),contentAlignment=Alignment.Center){Icon(Icons.Default.Memory,null,tint=cyan)}
   Spacer(Modifier.width(10.dp));Column(Modifier.weight(1f)){Text("EDGE//AI",color=white,fontSize=17.sp,fontWeight=FontWeight.Black,letterSpacing=1.5.sp);Text("VISION SYSTEMS LAB",color=muted,fontSize=8.sp,letterSpacing=1.6.sp)}
   Text("● DEMO MODE",color=lime,fontSize=9.sp,fontWeight=FontWeight.Bold,modifier=Modifier.clip(CircleShape).background(Color(0xFF14251F)).padding(9.dp))
  }
  Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal=18.dp)){
   Spacer(Modifier.height(14.dp));Hero()
   Spacer(Modifier.height(14.dp));Row(horizontalArrangement=Arrangement.spacedBy(8.dp)){Metric("16×","DOT PRODUCT",Icons.Default.Bolt,Modifier.weight(1f));Metric("32-bit","ACCUMULATOR",Icons.Default.Memory,Modifier.weight(1f));Metric("105","RTL CASES",Icons.Default.CheckCircle,Modifier.weight(1f))}
   Spacer(Modifier.height(24.dp));Eyebrow("01 / INTERACTIVE LAB","SIGNAL PLAYGROUND");Text("Feed the edge.",color=white,fontSize=30.sp,fontWeight=FontWeight.Black)
   Spacer(Modifier.height(5.dp));Text("Tune the synthetic signal and run a lightweight preview classifier.",color=muted,fontSize=13.sp,lineHeight=19.sp);Spacer(Modifier.height(14.dp))
   Card(colors=CardDefaults.cardColors(containerColor=panel),shape=RoundedCornerShape(22.dp),border=BorderStroke(1.dp,line)){
    Column(Modifier.padding(15.dp)){
     Row(verticalAlignment=Alignment.CenterVertically){Column(Modifier.weight(1f)){Text("INPUT FRAME",color=white,fontWeight=FontWeight.Bold,fontSize=12.sp);Text("SYNTHETIC GRAYSCALE / 32×32",color=muted,fontSize=8.sp)};Text("SEED "+seed.toString().padStart(4,'0'),color=cyan,fontSize=9.sp,fontFamily=FontFamily.Monospace)}
     Spacer(Modifier.height(12.dp));Signal(seed,intensity,Modifier.fillMaxWidth().aspectRatio(1.32f));Spacer(Modifier.height(14.dp))
     Row(verticalAlignment=Alignment.CenterVertically){Icon(Icons.Default.Tune,null,tint=cyan,modifier=Modifier.size(17.dp));Spacer(Modifier.width(7.dp));Text("Signal intensity",color=white,fontSize=12.sp);Spacer(Modifier.weight(1f));Text(intensity.toString().take(4)+"×",color=lime,fontWeight=FontWeight.Bold,fontFamily=FontFamily.Monospace)}
     Slider(value=intensity,onValueChange={intensity=it;ran=false;result="READY"},valueRange=.25f..1.75f,colors=SliderDefaults.colors(thumbColor=lime,activeTrackColor=cyan,inactiveTrackColor=line))
     Row(verticalAlignment=Alignment.CenterVertically){Text("0.25× LOW",color=muted,fontSize=8.sp);Spacer(Modifier.weight(1f));Text("1.75× HIGH",color=muted,fontSize=8.sp);Spacer(Modifier.width(12.dp));Icon(Icons.Default.Refresh,"New frame",tint=cyan,modifier=Modifier.size(20.dp).clickable{seed=(1000..9999).random();ran=false;result="READY"})}
    }
   }
   Spacer(Modifier.height(12.dp))
   Button(onClick={val a=(31f*intensity).roundToInt().coerceIn(0,255);val b=(12f*intensity).roundToInt().coerceIn(0,100);val c=(127f*intensity).roundToInt().coerceIn(0,255);val score=a*3+b*5+c*2-350;result=if(score>=0)"ALERT" else "SAFE";confidence=(1f/(1f+kotlin.math.exp(-score/100f))).coerceIn(.05f,.99f);features=listOf(a,b,c);runs++;ran=true},modifier=Modifier.fillMaxWidth().height(54.dp),shape=RoundedCornerShape(16.dp),colors=ButtonDefaults.buttonColors(containerColor=lime,contentColor=bg)){
    Icon(Icons.Default.PlayArrow,null);Spacer(Modifier.width(8.dp));Text("RUN PREVIEW INFERENCE",fontWeight=FontWeight.ExtraBold,letterSpacing=.7.sp);Spacer(Modifier.width(8.dp));Icon(Icons.Default.ArrowOutward,null)
   }
   Spacer(Modifier.height(13.dp))
   Card(colors=CardDefaults.cardColors(containerColor=panel),shape=RoundedCornerShape(22.dp),border=BorderStroke(1.dp,rc.copy(alpha=.35f))){
    Column(Modifier.padding(17.dp)){
     Row(verticalAlignment=Alignment.CenterVertically){Text("MODEL OUTPUT",color=muted,fontSize=9.sp,fontWeight=FontWeight.Bold,letterSpacing=1.sp);Spacer(Modifier.weight(1f));Text(if(ran)"RUN #"+runs.toString().padStart(3,'0') else "WAITING",color=rc,fontSize=8.sp,fontWeight=FontWeight.Bold)}
     Spacer(Modifier.height(14.dp));Row(verticalAlignment=Alignment.CenterVertically){
      Box(Modifier.size(50.dp).clip(RoundedCornerShape(15.dp)).background(rc.copy(alpha=.1f)).border(1.dp,rc.copy(alpha=.25f),RoundedCornerShape(15.dp)),contentAlignment=Alignment.Center){AnimatedContent(result,label="symbol"){p->Text(if(p=="ALERT")"↗" else if(p=="SAFE")"✓" else "◌",color=rc,fontSize=27.sp,fontWeight=FontWeight.Black)}}
      Spacer(Modifier.width(12.dp));Column(Modifier.weight(1f)){AnimatedContent(result,label="prediction"){p->Text(p,color=rc,fontSize=25.sp,fontWeight=FontWeight.Black,letterSpacing=1.sp)};Text(if(ran)"Preview threshold result" else "Run the preview to see a result",color=muted,fontSize=10.sp)}
      Column(horizontalAlignment=Alignment.End){Text(if(ran)(confidence*100).roundToInt().toString()+"%" else "—",color=white,fontSize=21.sp,fontWeight=FontWeight.Bold);Text("CONFIDENCE",color=muted,fontSize=7.sp)}
     }
     Spacer(Modifier.height(14.dp));Box(Modifier.fillMaxWidth().height(5.dp).clip(CircleShape).background(line)){Box(Modifier.fillMaxWidth(progress.coerceIn(0f,1f)).height(5.dp).clip(CircleShape).background(Brush.horizontalGradient(listOf(cyan,rc))))}
     Spacer(Modifier.height(17.dp));Text("EXTRACTED FEATURES",color=muted,fontSize=9.sp,letterSpacing=.9.sp,fontWeight=FontWeight.Bold);Spacer(Modifier.height(10.dp))
     Feature("MEAN INTENSITY",features[0],255,cyan);Spacer(Modifier.height(9.dp));Feature("ACTIVE SIGNAL",features[1],100,lime);Spacer(Modifier.height(9.dp));Feature("PEAK RESPONSE",features[2],255,purple)
     Spacer(Modifier.height(13.dp));Text("Preview only: this screen does not execute the Python model or report real hardware latency.",color=muted,fontSize=9.sp,lineHeight=14.sp)
    }
   }
   Spacer(Modifier.height(24.dp));Eyebrow("02 / SYSTEM DESIGN","UNDER THE HOOD");Text("From code to silicon.",color=white,fontSize=25.sp,fontWeight=FontWeight.Black);Spacer(Modifier.height(13.dp))
   Card(colors=CardDefaults.cardColors(containerColor=panel),shape=RoundedCornerShape(20.dp),border=BorderStroke(1.dp,line)){Column(Modifier.padding(16.dp)){Arch("01","Python inference","Feature extraction + reference score",cyan);Connector();Arch("02","INT8 compute","16 signed values per datapath tile",lime);Connector();Arch("03","RTL accelerator","Sequential dot product + 32-bit sum",purple);Connector();Arch("04","Verification","SystemVerilog simulation + CI checks",cyan)}}
   Spacer(Modifier.height(13.dp));Card(colors=CardDefaults.cardColors(containerColor=Color(0xFF101A1A)),shape=RoundedCornerShape(18.dp),border=BorderStroke(1.dp,Color(0xFF24413A))){Row(Modifier.fillMaxWidth().padding(15.dp),verticalAlignment=Alignment.CenterVertically){Icon(Icons.Default.CheckCircle,null,tint=lime,modifier=Modifier.size(24.dp));Spacer(Modifier.width(10.dp));Column(Modifier.weight(1f)){Text("RTL regression",color=white,fontWeight=FontWeight.Bold,fontSize=13.sp);Text("3 testbenches • directed + random cases",color=muted,fontSize=9.sp)};Text("PASS",color=lime,fontSize=10.sp,fontWeight=FontWeight.Black)}}
   Spacer(Modifier.height(24.dp));Eyebrow("03 / BUILT BY","DEVELOPER")
   Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(18.dp)).background(panel).border(1.dp,line,RoundedCornerShape(18.dp)).padding(15.dp),verticalAlignment=Alignment.CenterVertically){Box(Modifier.size(46.dp).clip(RoundedCornerShape(14.dp)).background(Brush.linearGradient(listOf(cyan.copy(alpha=.2f),purple.copy(alpha=.2f)))).border(1.dp,cyan.copy(alpha=.4f),RoundedCornerShape(14.dp)),contentAlignment=Alignment.Center){Text("NG",color=lime,fontWeight=FontWeight.Black)};Spacer(Modifier.width(12.dp));Column(Modifier.weight(1f)){Text("Nikhil Gaurav",color=white,fontSize=16.sp,fontWeight=FontWeight.Bold);Text("ECE • EDGE AI & RTL PROTOTYPING",color=muted,fontSize=9.sp)};Icon(Icons.Default.Bolt,null,tint=lime)}
   Spacer(Modifier.height(12.dp));Row(horizontalArrangement=Arrangement.spacedBy(10.dp)){Link("PROJECT REPO","Source code",Icons.Default.Code,Modifier.weight(1f)){open(ctx,"https://github.com/NGAURAV951/edge-ai-riscv-vision")};Link("WEB EXPERIENCE","Open website",Icons.Default.OpenInBrowser,Modifier.weight(1f)){open(ctx,"https://ngaurav951.github.io/edge-ai-riscv-vision/")}}
   Spacer(Modifier.height(18.dp));Text("SIMULATION-FIRST PROTOTYPE / NOT A PHYSICAL FPGA BENCHMARK",color=muted,fontSize=8.sp);Spacer(Modifier.height(18.dp))
  }
  Row(Modifier.fillMaxWidth().background(Color(0xFF0A0D16)).padding(horizontal=20.dp,vertical=12.dp),verticalAlignment=Alignment.CenterVertically){Icon(Icons.Default.AccountTree,null,tint=lime,modifier=Modifier.size(15.dp));Spacer(Modifier.width(7.dp));Text("EDGE//AI",color=white,fontSize=10.sp,fontWeight=FontWeight.Black);Spacer(Modifier.weight(1f));Text("MADE BY NIKHIL GAURAV",color=muted,fontSize=8.sp)}
 }
}
@Composable private fun Hero(){
 val t=rememberInfiniteTransition(label="pulse");val pulse by t.animateFloat(.25f,.95f,infiniteRepeatable(tween(1700),RepeatMode.Reverse),label="glow")
 Card(colors=CardDefaults.cardColors(containerColor=Color(0xFF11192A)),shape=RoundedCornerShape(26.dp),border=BorderStroke(1.dp,Color(0xFF26364B))){Box{
  Canvas(Modifier.matchParentSize()){val g=24.dp.toPx();for(x in 0..(size.width/g).toInt())drawLine(Color(0xFF28364D).copy(alpha=.22f),Offset(x*g,0f),Offset(x*g,size.height),1f);for(y in 0..(size.height/g).toInt())drawLine(Color(0xFF28364D).copy(alpha=.22f),Offset(0f,y*g),Offset(size.width,y*g),1f)}
  Column(Modifier.fillMaxWidth().padding(20.dp)){Row(verticalAlignment=Alignment.CenterVertically){Box(Modifier.size(7.dp).clip(CircleShape).background(lime.copy(alpha=pulse)));Spacer(Modifier.width(7.dp));Text("HARDWARE-AWARE INTELLIGENCE",color=cyan,fontSize=9.sp,letterSpacing=1.sp,fontWeight=FontWeight.Bold)}
   Spacer(Modifier.height(16.dp));Text("Intelligence",color=white,fontSize=35.sp,fontWeight=FontWeight.Black,letterSpacing=(-1.3).sp);Row{Text("at the ",color=white,fontSize=35.sp,fontWeight=FontWeight.Black);Text("edge.",color=lime,fontSize=35.sp,fontWeight=FontWeight.Black)}
   Spacer(Modifier.height(9.dp));Text("Tiny models. Integer math. Real hardware thinking.",color=Color(0xFFB5C1D7),fontSize=13.sp)
   Box(Modifier.fillMaxWidth().height(118.dp),contentAlignment=Alignment.Center){Canvas(Modifier.fillMaxSize()){val cx=size.width/2;val cy=size.height/2;val r=minOf(size.width*.27f,size.height*.34f);for(i in 0..2)drawCircle(if(i==1)lime.copy(alpha=.18f+pulse*.12f) else cyan.copy(alpha=.18f),r*(1+i*.35f),Offset(cx,cy),style=Stroke(1.dp.toPx()));for(i in 0..7){val a=(i*45f+pulse*12f)*Math.PI/180;val p=Offset(cx+kotlin.math.cos(a).toFloat()*r*1.65f,cy+kotlin.math.sin(a).toFloat()*r*1.65f);drawLine(cyan.copy(alpha=.22f),Offset(cx,cy),p,1.dp.toPx());drawCircle(if(i%3==0)lime else cyan,2.5.dp.toPx(),p)};drawRoundRect(Brush.linearGradient(listOf(Color(0xFF1B2A3B),panel)),Offset(cx-51.dp.toPx(),cy-33.dp.toPx()),Size(102.dp.toPx(),66.dp.toPx()),androidx.compose.ui.geometry.CornerRadius(14.dp.toPx()));drawRoundRect(cyan.copy(alpha=.8f),Offset(cx-51.dp.toPx(),cy-33.dp.toPx()),Size(102.dp.toPx(),66.dp.toPx()),androidx.compose.ui.geometry.CornerRadius(14.dp.toPx()),style=Stroke(1.dp.toPx()))};Column(horizontalAlignment=Alignment.CenterHorizontally){Text("EDGE",color=white,fontSize=20.sp,fontWeight=FontWeight.Black,letterSpacing=2.sp);Text("CORE / INT8",color=lime,fontSize=8.sp,fontFamily=FontFamily.Monospace)}}
   Row(horizontalArrangement=Arrangement.spacedBy(7.dp)){Tag("INT8",cyan);Tag("RTL VERIFIED",lime);Tag("RISC-V CONCEPT",purple)}
  }
 }}
}
@Composable private fun Tag(s:String,c:Color){Box(Modifier.clip(RoundedCornerShape(8.dp)).background(c.copy(alpha=.08f)).border(1.dp,c.copy(alpha=.25f),RoundedCornerShape(8.dp)).padding(horizontal=8.dp,vertical=7.dp)){Text(s,color=c,fontSize=7.sp,fontWeight=FontWeight.Bold)}}
@Composable private fun Metric(v:String,l:String,i:androidx.compose.ui.graphics.vector.ImageVector,m:Modifier){Card(m,shape=RoundedCornerShape(15.dp),colors=CardDefaults.cardColors(containerColor=panel),border=BorderStroke(1.dp,line)){Column(Modifier.padding(9.dp)){Icon(i,null,tint=lime,modifier=Modifier.size(17.dp));Spacer(Modifier.height(8.dp));Text(v,color=white,fontSize=17.sp,fontWeight=FontWeight.Black,maxLines=1);Text(l,color=muted,fontSize=7.sp,letterSpacing=.2.sp)}}}
@Composable private fun Eyebrow(k:String,l:String){Row(verticalAlignment=Alignment.CenterVertically){Box(Modifier.width(18.dp).height(2.dp).background(lime));Spacer(Modifier.width(7.dp));Text(k,color=cyan,fontSize=9.sp,fontWeight=FontWeight.Bold,letterSpacing=.6.sp);Spacer(Modifier.weight(1f));Text(l,color=muted,fontSize=7.sp)};Spacer(Modifier.height(12.dp))}
@Composable private fun Signal(seed:Int,intensity:Float,m:Modifier){Canvas(m.clip(RoundedCornerShape(15.dp)).background(Color(0xFF080F17)).border(1.dp,cyan.copy(alpha=.2f),RoundedCornerShape(15.dp))){val cell=minOf(size.width/32f,size.height/32f);val left=(size.width-cell*32)/2;val top=(size.height-cell*32)/2;val rand=java.util.Random(seed.toLong());for(y in 0 until 32)for(x in 0 until 32){val obj=x in 12..19&&y in 8..23;val raw=if(obj)118+rand.nextInt(120) else 9+rand.nextInt(28);val v=(raw*intensity).roundToInt().coerceIn(3,255)/255f;drawRect(Color((v*.55f).coerceIn(0f,1f),(v*.98f).coerceIn(0f,1f),(v*.88f+.04f).coerceIn(0f,1f)),Offset(left+x*cell,top+y*cell),Size(cell*.88f,cell*.88f))};drawRect(lime.copy(alpha=.8f),Offset(left+12*cell,top+8*cell),Size(8*cell,16*cell),style=Stroke(1.dp.toPx()))}}
@Composable private fun Feature(l:String,v:Int,max:Int,c:Color){Row(verticalAlignment=Alignment.CenterVertically){Text(l,color=muted,fontSize=8.sp,modifier=Modifier.width(102.dp));Box(Modifier.weight(1f).height(4.dp).clip(CircleShape).background(line)){Box(Modifier.fillMaxWidth((v.toFloat()/max).coerceIn(.02f,1f)).height(4.dp).clip(CircleShape).background(c))};Spacer(Modifier.width(9.dp));Text(v.toString(),color=white,fontSize=11.sp,fontFamily=FontFamily.Monospace)}}
@Composable private fun Arch(n:String,t:String,d:String,c:Color){Row(verticalAlignment=Alignment.CenterVertically){Box(Modifier.size(36.dp).clip(RoundedCornerShape(11.dp)).background(c.copy(alpha=.1f)).border(1.dp,c.copy(alpha=.25f),RoundedCornerShape(11.dp)),contentAlignment=Alignment.Center){Text(n,color=c,fontSize=10.sp,fontWeight=FontWeight.Black,fontFamily=FontFamily.Monospace)};Spacer(Modifier.width(11.dp));Column{Text(t,color=white,fontSize=12.sp,fontWeight=FontWeight.Bold);Text(d,color=muted,fontSize=9.sp)}}}
@Composable private fun Connector(){Box(Modifier.padding(start=17.dp).width(1.dp).height(12.dp).background(line))}
@Composable private fun Link(l:String,t:String,i:androidx.compose.ui.graphics.vector.ImageVector,m:Modifier,onClick:()->Unit){Card(m.clickable(onClick=onClick),shape=RoundedCornerShape(16.dp),colors=CardDefaults.cardColors(containerColor=panel),border=BorderStroke(1.dp,line)){Column(Modifier.padding(13.dp)){Icon(i,null,tint=cyan,modifier=Modifier.size(20.dp));Spacer(Modifier.height(10.dp));Text(l,color=muted,fontSize=8.sp);Text(t,color=white,fontSize=12.sp,fontWeight=FontWeight.Bold)}}}
private fun open(c:android.content.Context,u:String){runCatching{c.startActivity(Intent(Intent.ACTION_VIEW,Uri.parse(u)))}}
