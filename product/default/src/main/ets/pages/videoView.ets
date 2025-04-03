// xxx.ets
import { common } from '@kit.AbilityKit';
import { DownloadFileNew } from '../components/downLoadFileNew';
import { Decimal } from '@kit.ArkTS';
import fs from '@ohos.file.fs';
@Entry
@Component
export struct VideoView {
  @State videoSrc: string|Resource = 'https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4'
  @State previewUri: Resource = $r('app.media.IMG')
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @State isAutoPlay: boolean = false
  @State showControls: boolean = true
  fileUri = "https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4"
  @State fileDownHint: string = '0%';
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    text: SaveDescription.SAVE_FILE,
    buttonType: ButtonType.Capsule
  } // 设置安全控件按钮属性
  controller: VideoController = new VideoController()
async  aboutToAppear() {
 let value =await this.checkVideoExists()
   if(value){
     this.videoSrc = `file://${value}`
     console.log('---替换uri'+this.videoSrc)
   }
 }
  async checkVideoExists() {
    // const context = getContext(this) as common.UIAbilityContext;
    // const filesDir = context.filesDir;
    let localCacheDir:string = DownloadFileNew.getLocalCacheDir()
    let videoFilePath =`${localCacheDir}/123456.mp4`
    try {
      const stats = await fs.stat(videoFilePath);
      if (stats) {
        console.info('---视频文件存在');
        return videoFilePath;
      }
    } catch (error) {
      console.error('---判断文件是否存在时出错: ', error);
    }
    console.info('---视频文件不存在');
    return false;
  }
  build() {
    Column() {
      Video({
        src: this.videoSrc,
        previewUri: this.previewUri,
        currentProgressRate: this.curRate,
        controller: this.controller
      })
        .width('100%')
        .height(600)
        .autoPlay(this.isAutoPlay)
        .controls(this.showControls)
        .onStart(() => {
          console.info('onStart')
        })
        .onPause(() => {
          console.info('onPause')
        })
        .onFinish(() => {
          console.info('onFinish')
        })
        .onError(() => {
          console.info('onError')
        })
        .onStop(() => {
          console.info('onStop')
        })
        .onPrepared((e?: DurationObject) => {
          if (e != undefined) {
            console.info('onPrepared is ' + e.duration)
          }
        })
        .onSeeking((e?: TimeObject) => {
          if (e != undefined) {
            console.info('onSeeking is ' + e.time)
          }
        })
        .onSeeked((e?: TimeObject) => {
          if (e != undefined) {
            console.info('onSeeked is ' + e.time)
          }
        })
        .onUpdate((e?: TimeObject) => {
          if (e != undefined) {
            console.info('onUpdate is ' + e.time)
          }
        })
        .onFullscreenChange((e?: FullscreenObject) => {
          if (e != undefined) {
            console.info('onFullscreenChange is ' + e.fullscreen)
          }
        })

      Row() {
        Button('src').onClick(() => {
          this.videoSrc = 'https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4'// 切换视频源
        }).margin(5)
        Button('previewUri').onClick(() => {
          this.previewUri = $r('app.media.cardOne') // 切换视频预览海报
        }).margin(5)
        Button('controls').onClick(() => {
          this.showControls = !this.showControls // 切换是否显示视频控制栏
        }).margin(5)
      }

      Row() {
        Button('start').onClick(() => {
          this.controller.start() // 开始播放
        }).margin(2)
        Button('pause').onClick(() => {
          this.controller.pause() // 暂停播放
        }).margin(2)
        Button('stop').onClick(() => {
          this.controller.stop() // 结束播放
        }).margin(2)
        Button('reset').onClick(() => {
          this.controller.reset() // 重置AVPlayer
        }).margin(2)
        Button('setTime').onClick(() => {
          this.controller.setCurrentTime(10, SeekMode.Accurate) // 精准跳转到视频的10s位置
        }).margin(2)
      }
      Row(){
        SaveButton(this.saveButtonOptions)
          .width(100)
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
      // Row() {
      //   Button('rate 0.75').onClick(() => {
      //     this.curRate = PlaybackSpeed.Speed_Forward_0_75_X // 0.75倍速播放
      //   }).margin(5)
      //   Button('rate 1').onClick(() => {
      //     this.curRate = PlaybackSpeed.Speed_Forward_1_00_X // 原倍速播放
      //   }).margin(5)
      //   Button('rate 2').onClick(() => {
      //     this.curRate = PlaybackSpeed.Speed_Forward_2_00_X // 2倍速播放
      //   }).margin(5)
      // }
      Row(){
        Text(`${this.fileDownHint}`)
          .textOverflow({ overflow: TextOverflow.None })
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .fontColor(Color.Black)
          .width("100%")
          .fontWeight(FontWeight.Bold)

      }
    }
  }
}

interface DurationObject {
  duration: number;
}

interface TimeObject {
  time: number;
}

interface FullscreenObject {
  fullscreen: boolean;
}