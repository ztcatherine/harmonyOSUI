import Header from '../view/header'
import PageList from '../view/list'
import { ComponentContent } from '@kit.ArkUI';
import { PromptActionClass } from '../components/PromptActionClass';
import SideBarContainerExample from '../view/slideBar'
import {WaterFlowListData} from '../view/WaterFlowListData'

@Component
export default struct Home {
  @Link pathStack: NavPathStack;
 @State waterFlowListData: WaterFlowListData = new WaterFlowListData();
  scroller: Scroller = new Scroller()
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.ctx, wrapBuilder(buildText));

 async aboutToAppear() {
    this.waterFlowListData.addData()
   console.log('---2222')
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.Top, offset: { dx: 0, dy: 0 } });
  }

  build() {
      Scroll(this.scroller){
        Column(){
          Column(){
            Header()
          }
          Column(){
              PageList({ waterFlowListData: this.waterFlowListData })

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
@Builder
function buildText():void {
  SideBarContainerExample()
}