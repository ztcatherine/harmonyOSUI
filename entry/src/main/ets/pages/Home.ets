import Header from '../view/header'
import PageList from '../view/list'
@Component
export default struct Home {
  @Link pathStack: NavPathStack;
  scroller: Scroller = new Scroller()
  build() {
      Scroll(this.scroller){
        Column(){
          Column(){
            Header()
          }
          Column(){
            PageList()
          }
          Column(){
            Image($r('app.media.homeBottom'))
              .height('206vp')
              .width('100%')
              .overlay('png', { align: Alignment.Bottom })
              .objectFit(ImageFit.Contain)
          }
          .margin({top:20,bottom:20})
        }
      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
  }
}