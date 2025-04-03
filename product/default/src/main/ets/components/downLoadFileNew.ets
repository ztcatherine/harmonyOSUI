import { common } from '@kit.AbilityKit';
import fs, { ReadOptions, WriteOptions } from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileIo, picker } from '@kit.CoreFileKit';

let TAG= "DownloadFileNew"
export class DownloadFileNew{

  /**
   * 获取应用沙箱存储目录 统一一下，方便APP设置页面删除
   * @returns
   */
  static getLocalCacheDir():string {
    let cache_dir_name = "appfiles";
    let cache_dir = getContext().cacheDir+"/"+cache_dir_name;
    console.info(`---createCacheDir cache_dir: ${cache_dir}`);
    let existAppCacheDir = fileIo.accessSync(cache_dir,fileIo.AccessModeType.EXIST)
    if (!existAppCacheDir) {
      fileIo.mkdirSync(cache_dir, true);
    }
    return cache_dir
  }

  /**
   * 下载文件到本地存储卡的下载等文件夹下
   * @param context
   * @param filePath
   * @param callback
   */
  public static downloadImagToDir(context:common.UIAbilityContext,filePath:string,callback:DownloadCallback){
    console.info(`${TAG} downloadImagToDir imagePath: ${filePath}`);
    if (!filePath.startsWith("http://")&&!filePath.startsWith("https://")) {
      callback.onError()
      return
    }
    // let defaultName = `${Date.now().toString()}.mp4`
    let defaultName = `123456.mp4`
    //1.获取本地存储卡的下载等文件夹 考虑用户体验友好，先让用户选择下载路径，再下载
    DownloadFileNew.selectDocumentPath(`${defaultName}`).then(destFilePath =>{
      if (!destFilePath||destFilePath.length<=0) {
        console.info(`${TAG} downloadImagToDir 用户取消了`);
        callback.onError()
        return
      }
      //2.获取下载到的应用沙箱目录
      let localCacheDir:string = DownloadFileNew.getLocalCacheDir()
      let srcFilePath =`${localCacheDir}/${defaultName}`
      //使用request.agent.create下载文件到沙箱目录
      let config:request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: filePath,
        method: 'GET',
        title: 'download',
        mode: request.agent.Mode.BACKGROUND,
        retry: true,
        network: request.agent.Network.ANY,
        saveas: srcFilePath,//这里要注意目录 API文档和官方文档都有详细说明
        overwrite: true
      }
      try {
        let startTime = 0
        //this.downloadTask = await request.agent.create(context,config)
        request.agent.create(context,config).then(downloadTask=>{
          if (callback.onStart) {
            callback.onStart()
          }
          downloadTask.on("progress",(progress: request.agent.Progress)=>{
            console.info(`${TAG} downloadImagToDir progress = ${JSON.stringify(progress)}`);
            if (progress) {
              callback.inProgress(progress.processed,progress.sizes[0])
            }
          })
          downloadTask.on("completed",(progress: request.agent.Progress)=>{
            console.info(`${TAG} downloadImagToDir completed time=${Date.now()-startTime}`);
            //deleteTask();
            if (downloadTask&&downloadTask.config.saveas) {
              try {
                let srcFilePath = downloadTask.config.saveas
                downloadTask.off('progress');
                downloadTask.off('completed');
                downloadTask.off('failed');
                request.agent.remove(downloadTask.tid);
                //3.将下载到应用沙箱目录中的文件 写到用户选择的存储卡中destFilePath
                DownloadFileNew.saveToDestFilePath(srcFilePath,destFilePath).then(r=>{
                  if (r) {
                    callback.onSuccess(destFilePath)
                  }else {
                    callback.onError()
                  }
                })
              } catch (err) {
                console.info(`${TAG} downloadImagToDir completed fail, err= ${JSON.stringify(err)}`);
                callback.onError()
              }
            }else {
              console.info(`${TAG} downloadImagToDir completed fail, onError downloadTask==null `);
              callback.onError()
            }
          })
          downloadTask.on("failed", async (progress)=>{
            let taskInfo = await request.agent.show(downloadTask!.tid);
            console.info(`${TAG} downloadImagToDir failed, resean = ${taskInfo.reason}, faults = ${JSON.stringify(taskInfo.faults)}`);
            callback.onError()
          })
          downloadTask.on('pause',  async (progress: request.agent.Progress) => {
            if (downloadTask) {
              let taskInfo = await request.agent.show(downloadTask.tid);
              console.info(`${TAG} pause,  resean = ${taskInfo.reason}, progress = ${progress.processed}, faults = ${JSON.stringify(taskInfo.faults)}`);
            }
          })
          downloadTask.on('resume',async (progress: request.agent.Progress) => {
            if (downloadTask) {
              let taskInfo = await request.agent.show(downloadTask.tid);
              console.info(`${TAG} resume,  resean = ${taskInfo.reason}, progress = ${progress.processed}, faults = ${JSON.stringify(taskInfo.faults)}`)
            }
          })
          startTime = Date.now()
          downloadTask.start()
        })
      } catch (err) {
        console.info(`${TAG} task  err, err  = ${JSON.stringify(err)}`)
        callback.onError()
      }
    }).catch((err:Error)=>{
      console.info(`${TAG} task  err, err111  = ${JSON.stringify(err)}`)
      callback.onError()
    })
  }

  /**
   * 获取本地存储卡的下载等文件夹
   * @param defaultName 默认文件名称（包含后缀名），用户可以在选择弹窗中修改
   * @returns
   */
  static async selectDocumentPath(defaultName:string): Promise<string>{
    try {
      let DocumentSaveOptions = new picker.DocumentSaveOptions();
      DocumentSaveOptions.newFileNames = [defaultName];
      let documentPicker = new picker.DocumentViewPicker();
      return documentPicker.save(DocumentSaveOptions).then(async (documentSaveResult) => {
        console.info(`${TAG} DocumentViewPicker.save successfully, DocumentSaveResult uri:= ${JSON.stringify(documentSaveResult)}`)
        let destFile =await fs.open(documentSaveResult[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        console.info(`${TAG} start destFile: ${destFile.path}`);
        return destFile.path
      }).catch((err:BusinessError) => {
        console.info(`${TAG} DocumentViewPicker.save failed with err:  ${JSON.stringify(err)}`);
        return ""
      });
    } catch (err) {
      console.info(`${TAG} DocumentViewPicker failed with err:  ${JSON.stringify(err)}`);
      return ""
    }
  }

  /**
   * 拷贝文件 从沙箱目录中到目标文件中
   * @param srcFilePath 沙箱目录中文件
   * @param destFilePath
   * @returns
   */
  static async saveToDestFilePath(srcFilePath:string,destFilePath:string){
    console.info(`${TAG} saveToDestFilePath srcFilePath= ${srcFilePath},destFilePath= ${destFilePath}`);
    try {
      let bufSize = 4096;
      let readSize = 0;
      let srcFile  = fs.openSync(srcFilePath, fs.OpenMode.READ_WRITE);
      console.info(`${TAG} saveToDestFilePath srcFile: ${srcFile.path} size=`+ DownloadFileNew.bytesToMB(fs.statSync(srcFile.path).size));
      let destFile = fs.openSync(destFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      console.info(`${TAG} saveToDestFilePath destFile: ${destFile.path}`);
      let buf = new ArrayBuffer(bufSize);
      let readOptions: ReadOptions = {
        offset: readSize,
        length: bufSize
      };

      let startTime = Date.now()
      let readLen = fs.readSync(srcFile.fd, buf, readOptions);
      console.info(`${TAG} readSync readLen: ${readLen}`);
      while (readLen > 0) {
        readSize += readLen;
        let writeOptions: WriteOptions = {
          length: readLen
        };
        fs.writeSync(destFile.fd, buf, writeOptions);
        readOptions.offset = readSize;
        readLen = fs.readSync(srcFile.fd, buf, readOptions);
      }
      console.info(`${TAG} write successfully 1111111 time=${Date.now()-startTime}`);
      //fs.unlinkSync(srcFile.path) //删除沙箱目录中的临时文件
      fs.closeSync(srcFile);
      fs.closeSync(destFile);
      console.info(`${TAG} close successfully 2222222 time=${Date.now()-startTime}`);
      return true
    } catch (err) {
      console.info(`${TAG} saveToDestFilePath failed with err: ${JSON.stringify(err)}`);
      return false
    }
  }

  public static bytesToMB(bytes:number){
    if(bytes>=1000){
      bytes=bytes/1000.0;
      if(bytes>=1000){
        bytes=bytes/1000.0;
        if(bytes>=1000){
          bytes=bytes/1000.0;
          return bytes+" GB";
        }else{
          return bytes+" MB";
        }
      }else{
        return bytes+" KB";
      }
    }else{
      return bytes+" Byte";
    }
  }
}

/**
 * 下载文件的返回结果
 */
interface DownloadCallback {
  onError: () => void;
  onStart?: () => void;
  inProgress: (progress: number, total: number) => void;
  onSuccess: (file: string) => void;
}
