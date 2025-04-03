// WaterFlowDataSource.ets
import { NetworkUtil } from 'feature1';
import { preferences } from '@kit.ArkData';
const PREFERENCES_NAME = 'listData';
let preferenceListData: preferences.Preferences | null = null;
interface  ListItem {
  engineerId:number,
  engineerName:string,
  avatarImg: string,
}
export class WaterFlowListData {
  public dataSource: BasicDataSource = new BasicDataSource();
  public netWorkUtil: NetworkUtil = new NetworkUtil();
  getData(): BasicDataSource {
    console.log('---get:'+JSON.stringify(this.dataSource))
    return this.dataSource;
  }

  async addData(): Promise<void> {
    await this.getPreferencesFromStorage()
    const preferenceListData = await this.getPreference()
    console.info(`---preferenceListData__get ${preferenceListData}`)
    if(preferenceListData){
      console.log('---从数据库得到的列表数据')
      this.dataSource.addData(JSON.parse(preferenceListData))
    }else{
      await this.netWorkUtil.getStoreHomePageEngineer().then(res=>{
        this.dataSource.addData(res);
        console.log('---接口刚刚返回列表数据')
        this.putPreference(JSON.stringify(res))
        console.log('---保存列表数据到数据库')
      })
    }
  }
  async getPreferencesFromStorage() {
    let context = getContext(this) as Context
    preferenceListData = await preferences.getPreferences(context, PREFERENCES_NAME)
  }
  async getPreference(): Promise<string> {
     let listData:string = ''
    console.log('---preferenceListData1:'+preferenceListData)
    if (preferenceListData !== null) {
     listData = await preferenceListData.get('listData','') as string;
      return listData
    }
    return listData
  }
  async putPreference(data: string) {
    if (preferenceListData !== null) {
      console.log('---存preferenceListData:'+data)
      await preferenceListData.put('listData', data)
      await preferenceListData.flush()
    }
  }
}
// 实现IDataSource接口的对象，用于瀑布流组件加载数据
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: ListItem[] = [];

  totalCount(): number {
    return this.originDataArray.length;
  }

  getData(index: number): ListItem {
    return this.originDataArray[index];
  }
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  public addData(data: ListItem[]): void {
    let len = this.originDataArray.length;
    this.originDataArray = this.originDataArray.concat(data);
    this.notifyDataAdd(len);
  }

  public clearData(): void {
    this.originDataArray = [];
    this.notifyDataReload();
  }
}