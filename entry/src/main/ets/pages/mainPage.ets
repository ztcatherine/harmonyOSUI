import Home from './Home';
@Preview
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State pathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  @Builder
  TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontWeight(500)
        .fontColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
    }
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .height('66vp')
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }
  build() {
    NavDestination(){
      Tabs({barPosition:BarPosition.End,controller:this.tabsController}){
        TabContent(){
          Home({ pathStack: this.pathStack })
        }
        .padding({
          left: '12vp',
          right: '12vp'
        })
        .backgroundColor('#F8F9FE')
        .tabBar(this.TabBuilder('首页', 0))
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}