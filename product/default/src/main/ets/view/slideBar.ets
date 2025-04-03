import { PromptActionClass } from '../components/PromptActionClass';
import { router } from '@kit.ArkUI';
interface SlideItemType{
  icon:Resource,
  text:string,
  url?:string
}
interface SlideStyle{
  color:string,
  backgroundColor?:string,
  border?:string,
  borderRadios?:string
}
interface BorderStyle{
  width?:number
  color?:string
  radius?:number
}
@Component
export default struct SideBarContainerExample {
  @State isSideBarExpanded: boolean = true
  @State slideList:SlideItemType[]= [
  {icon:$r('app.media.shop'),text:'打开相机功能、打开相册功能'},
  {icon:$r('app.media.slideItem2'),text:'鸿蒙web组件与h5交互',url:"pages/cameraView"},
  {icon:$r('app.media.sy'),text:'图片水印功能'},
  {icon:$r('app.media.videoIcon'),text:'音频播放后台播放',url:'pages/videoView'},
  {icon:$r('app.media.smIcon'),text:'扫码、自定义扫码'},
  {icon:$r('app.media.downloadIcon'),text:'图片视频保存下载'},
  {icon:$r('app.media.hjIcon'),text:'Getting started'},
  {icon:$r('app.media.logoutIcon'),text:'Logout'},
]
  @State current:number=0
  @State documentList:SlideItemType[]=[
    {icon:$r('app.media.hjIcon'),text:'Getting started'},
    {icon:$r('app.media.logoutIcon'),text:'Logout'}
  ]
    styleNormal:SlideStyle={
    color:'#8898AA',
    backgroundColor:'#FFFFFF',
    border:"none",
  }
  styleSelect:SlideStyle={
    color:'white',
    backgroundColor:'#5E72E4',
    border:"1vp",
    borderRadios:"4vp"
  }
  borderSelect:BorderStyle={
    width:5,
    color:'#5E72E4',
    radius:6
  }
  borderNone:BorderStyle={
    width:0,
    color:'#FFFFFF',
    radius:0
  }
  build() {
    SideBarContainer(SideBarContainerType.Overlay) {

      Column() {
        Flex({justifyContent:FlexAlign.SpaceBetween,alignItems:ItemAlign.Center}){
          Image($r('app.media.slideLogo'))
            .width('109vp')
            .height('32vp')
          Image($r('app.media.Menu'))
            .width('18vp')
            .height('12vp')
            .onClick(() => {
              PromptActionClass.closeDialog()
            })
        }
        .padding({top:40,left:30,right:30,bottom:40})
       Column(){
         // this.slideBuilder(this.slideList, this.current, this.styleSelect, this.styleNormal, this.borderSelect)
         Navigation(){
           List({space: 12, initialIndex: 0 }){
             ForEach(this.slideList, (item:ESObject,index:number) => {
               ListItem() {
                 Column(){
                   Row(){
                     Image(item.icon)
                       .width(32)
                       .height(32)
                       .margin({ right: 10 })
                     Text(item.text)
                       .fontSize('14fp')
                       .fontColor(this.current == index ? this.styleSelect.color : this.styleNormal.color)
                   }
                   .width('100%')
                   .height('44vp')
                   .padding({left:10})
                   .backgroundColor(this.current == index ? this.styleSelect.backgroundColor :
                   this.styleNormal.backgroundColor)
                   .border(this.current == index ? this.borderSelect:this.borderNone)
                   if(index==5){
                     Divider().strokeWidth(1).color('#8898AA').margin({top:10})
                   }
                 }

               }

               .onClick(()=>{
                 console.log('-----数组角标------', index)
                 this.current = index
                 if(item.url){
                   router.pushUrl({ url: item.url })
                   PromptActionClass.closeDialog()
                 }
               })

             }, (item: number) => item.toString())
           }
           }
         }
         //
         // ForEach(this.slideList,(item:ESObject,index:number)=>{
         //     Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
         //       Image(item.icon)
         //         .width(32)
         //         .height(32)
         //         .margin({ right: 10 })
         //       Text(item.text)
         //         .fontSize('14fp')
         //         .fontColor(this.current == index ? this.styleSelect.color : this.styleNormal.color)
         //         .onClick(()=>{
         //           console.log('-----数组角标------', index)
         //           this.current = index
         //         })
         //     }
         //     .width('100%')
         //     .height('44vp')
         //     .padding({left:10})
         //     .margin({ bottom: 10 })
         //     .backgroundColor(this.current == index ? this.styleSelect.backgroundColor :
         //     this.styleNormal.backgroundColor)
         //     .border(this.current == index ? this.borderSelect:{})
         //
         //
         // })
       // }
       .padding({left:10,right:10})
      }
      .backgroundColor('#FFFFFF')
    }
    .sideBarWidth('80%')
    .minSideBarWidth('10%')
    .showControlButton(false)
    .autoHide(false)
  }

  // @Builder
  // slideBuilder(list:SlideItemType[], current:number,styleSelect:SlideStyle,styleNormal:SlideStyle,borderSelect:BorderStyle){
  //   SlideItemView({ list:list, current:current,styleSelect:styleSelect,styleNormal:styleNormal,borderSelect:borderSelect})
  // }

}