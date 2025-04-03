
interface SlideItemType{
  icon:Resource,
  text:string
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

@ComponentV2
export struct SlideItemView {
  build() {

  }
//    @Param @Require list:SlideItemType[];
//   @Provide current: number = 0
//   @Param @Require styleSelect:SlideStyle;
//   @Param @Require styleNormal:SlideStyle;
//   @Param @Require borderSelect:BorderStyle;
//
//   build() {
// Column(){
//   ForEach(this.list,(item:ESObject,index:number)=>{
//     Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
//       Image(item.icon)
//         .width(32)
//         .height(32)
//         .margin({ right: 10 })
//       Text(item.text)
//         .fontSize('14fp')
//         .fontColor(this.current == index ? this.styleSelect.color : this.styleNormal.color)
//         .onClick(()=>{
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
//   })
// }
//   }
}