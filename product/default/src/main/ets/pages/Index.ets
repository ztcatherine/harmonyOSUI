import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  pathStack: NavPathStack = new NavPathStack();
  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          // let context : Context = getContext(this) as Context
          // console.log("CacheDir:" + JSON.stringify(context))
           router.pushUrl({ url: 'pages/mainPage' })
        })
    }
    .height('100%')
    .width('100%')
  }
}