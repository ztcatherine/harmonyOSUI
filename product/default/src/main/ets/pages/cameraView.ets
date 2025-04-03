import web_webview from '@ohos.web.webview';
import picker from '@ohos.file.picker';
import image from '@ohos.multimedia.image';
// import { fileIo as fs } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { PermissionUtil, ToastUtil, WantUtil } from '@pura/harmony-utils';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import util from '@ohos.util';
import { BusinessError } from '@kit.BasicServicesKit';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle';
import { dataSharePredicates } from '@kit.ArkData';
import { Permissions } from '@kit.AbilityKit';
interface MyEvent {
  result: FileSelectorResult,
  fileSelector: FileSelectorParam
}
const context = getContext(this);
let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
  onDataPrepared(data: ArrayBuffer) {
    if (data === undefined) {
      console.error('---Error occurred when preparing data');
      return;
    }
    console.info('---on image data prepared');
    // 应用自定义对资源数据的处理逻辑。
  }
}
@Entry
@Component
export struct CameraView {
  controller: web_webview.WebviewController = new web_webview.WebviewController();

    // async imageToBase64(filePath:string, bufferLen = 409600) {
    //   try {
    //     // 1. 去掉 "file://" 前缀（如果是 content:// URI，需要额外处理）
    //     // 2. 打开文件并读取内容
    //     const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
    //     const stat = fileIo.statSync(filePath);
    //     const buffer = new ArrayBuffer(stat.size);
    //     fileIo.readSync(file.fd, buffer);
    //     fileIo.closeSync(file);
    //     // 3. 转换为 Base64 Buffer.from(uint8Array).toString('base64');
    //     const uint8Array = new Uint8Array(buffer);
    //     const base64 = new util.Base64Helper
    //     return `data:image/jpeg;base64,${base64}`;
    //   } catch (err) {
    //     console.error('12---Failed to read file:', JSON.stringify(err));
    //     // throw err ;
    //   }
    // }
  async  example(uri: string) {
  let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri.toString());
  let fetchOptions: photoAccessHelper.FetchOptions = {
    fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
    predicates: predicates
  };

  try {
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions);
    let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
    console.info('---getAssets photoAsset.uri : ' + photoAsset.uri);
    // 获取属性值，以标题为例；对于非默认查询的属性，get前需要在fetchColumns中添加对应列名。
    console.info('---title : ' + photoAsset.get(photoAccessHelper.PhotoKeys.TITLE));
    // 请求图片资源数据。
    let requestOptions: photoAccessHelper.RequestOptions = {
      deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
    }
    await photoAccessHelper.MediaAssetManager.requestImageData(context, photoAsset, requestOptions, new MediaDataHandler());
    console.info('---requestImageData successfully');
    fetchResult.close();
  } catch (err) {
    console.error('---getAssets failed with err: ' + err);
  }
}

  async imageUriToBase64(uri: string): Promise<string | undefined> {
    try {
      // 打开文件
      let file = await fs.open(uri, fs.OpenMode.READ_ONLY);

      // 获取文件信息
      // const fileStat = await fs.stat(uri);

      // 读取文件内容到ArrayBuffer
      const arrayBuffer = new ArrayBuffer(4096);
      await fs.read(file.fd, arrayBuffer);

      // 转换为Base64
      const uint8Array = new Uint8Array(arrayBuffer);
      await fs.close(file.fd);
      let baseSrc =  buffer.from(uint8Array).toString('base64');
      return `data:image/png;base64,${baseSrc}`;
    }catch (err) {
      console.error('---文件读取或转换失败:', err);
      return undefined
      // 可根据具体错误类型，向用户展示友好提示，比如弹出提示框等
    }

}
  async selectFile(result: FileSelectorResult): Promise<void> {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 过滤选择媒体文件类型为IMAGE
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    // 设置最大选择数量
    photoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
    let chooseFile = photoSelectResult.photoUris[0];
    // console.log('---this', this.imageToBase64);
    // await this.imageUriToBase64(chooseFile)
     let baseImg = await this.imageUriToBase64(chooseFile)
     console.log('---baseImg:'+baseImg);
    // console.log('---photoSelectResult.photoUris:'+photoSelectResult.photoUris);
    // photoSelectResult.photoUris[0] = baseImg
    // result.handleFileList(photoSelectResult.photoUris);
    // console.log('---转过之后的photoUris:'+JSON.stringify(photoSelectResult.photoUris))
     result.handleFileList([baseImg]);
    // this.webView.getWebview().runJavaScript(`window.onPhotoSelected('${base64String}')`);
  }

  build() {
    Column() {
      Button("最佳使用案例")
        .onClick(() => {
          let ps: Permissions[] = ['ohos.permission.READ_IMAGEVIDEO', 'ohos.permission.WRITE_IMAGEVIDEO'];
          PermissionUtil.requestPermissions(ps).then((result) => {
            if (result) {
              ToastUtil.showToast(`最佳使用案例授权，已通过...`);
            } else {
              PermissionUtil.requestPermissionOnSetting(ps).then((grant) => {
                ToastUtil.showToast(`最佳使用案例，结果：${grant}`);
              }).catch(() => {
                ToastUtil.showToast(`111`);
              })
            }
          })
        })
      Web({
        src: $rawfile('camera.html'),
        // src: 'https://xxx',
        controller: this.controller
      })
        .width('100%')
        .height('100%')
        .domStorageAccess(true)//设置是否开启文档对象模型存储接口（DOM Storage API）权限。
        .javaScriptAccess(true)//设置是否允许执行JavaScript脚本，默认允许执行。
        .databaseAccess(true)//设置是否开启数据库存储API权限，默认不开启。
        .mixedMode(MixedMode.All)//HTTP和HTTPS混合
        .fileAccess(true)//设置是否开启应用中文件系统的访问，默认启用。
        .imageAccess(true)//设置是否允许自动加载图片资源，默认允许。
        .geolocationAccess(true)//设置是否开启获取地理位置权限，默认开启。
        .onlineImageAccess(true)//设置是否允许从网络加载图片资源（通过HTTP和HTTPS访问的资源），默认允许访问。
        .mediaPlayGestureAccess(true)//设置有声视频播放是否需要用户手动点击，静音视频播放不受该接口管控，默认需要。
        .onShowFileSelector((event) => {
          console.log('12-----------------------------------------------------------------')
          if (event) {
            this.selectFile(event.result);
          }
          return true;
        })
    }
    .width('100%')
    .height('80%')
  }
}

