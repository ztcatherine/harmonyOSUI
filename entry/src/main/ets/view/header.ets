@Preview
@Component
export default struct Header {
  build() {
    Column(){
      Flex({justifyContent:FlexAlign.SpaceBetween,alignItems:ItemAlign.Center}){
        Row(){
          Image($r('app.media.Menu'))
            .width('18vp')
            .height('12vp')
          Text('Home')
            .fontSize('16fp')
            .fontWeight(FontWeight.Bold)
            .fontColor('red')
            .margin({left:'10vp'})
        }
        Row(){
          Image($r('app.media.Bellblack'))
            .width('24vp')
            .height('24vp')
          Image($r('app.media.Basketblack'))
            .width('24vp')
            .height('24vp')
            .margin({left:'10vp'})
        }
      }
      Row() {
          // 文本输入框
          TextInput({placeholder:'What are you looking for?'})
            .width('100%')
            .height(42)
            .borderWidth(1)
            .borderColor('#CAD1D7')
            .borderRadius('4vp')
            .cancelButton({
              style:CancelButtonStyle.CONSTANT,
              icon:{
                src:$r('app.media.search'),
                size:14
              }
            })
          // 右侧搜索图片
      }.width('100%').margin({top:'20vp'})
     Row(){
        Row(){
          Image($r('app.media.Diamond'))
            .width('22vp')
            .height('22vp')
            .margin({right:5})
          Text('Beauty')
            .fontColor('#525F7F')
            .fontSize('14fp')
        }
       Divider().vertical(true).height(22).color('#172B4D').opacity(0.6).margin({ left: 16, right: 16 })
       Row(){
         Image($r("app.media.TieBow"))
           .width('22vp')
           .height('22vp')
           .margin({right:5})
         Text('Fashion')
           .fontColor('#525F7F')
           .fontSize('14fp')
       }
     }
     .margin({top:20,bottom:20})
    }
    .width('100%')
    .height('150vp')
  }
}