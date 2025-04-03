import { common } from '@kit.AbilityKit';
import { DownloadFileNew } from '../components/downLoadFileNew';
import { Decimal } from '@kit.ArkTS';
@Preview
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  //网上自己找一个大的文件
  fileUri = "https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4"
  @State fileDownHint: string = '0%';
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_FILE,
    buttonType: ButtonType.Capsule
  } // 设置安全控件按钮属性

  build() {
    Column() {
      Text(`${this.fileDownHint}`)
        .textOverflow({ overflow: TextOverflow.None })
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontColor(Color.Black)
        .width("100%")
        .margin(40)
        .fontWeight(FontWeight.Bold)
      SaveButton(this.saveButtonOptions)
        .width(100)
        .height(50)
        .onClick(async (event, result: SaveButtonOnClickResult) => {
          console.log('---result:'+JSON.stringify(result))
          if (result == SaveButtonOnClickResult.SUCCESS) {
            DownloadFileNew.downloadImagToDir(getContext(this) as common.UIAbilityContext, this.fileUri, {
              onError: () => {
              },
              inProgress: (progress, total) => {
                let progressDecimal: Decimal = new Decimal(progress/total*100);
                let progressFixed = progressDecimal.toFixed(2)
                this.fileDownHint = `下载中：${progressFixed}%`
              },
              onSuccess: (file) => {
                this.fileDownHint = `下载完成100%，文件地址：${file}`
              }
            })
          }
        })
    }
    .height('100%')
  }
}
