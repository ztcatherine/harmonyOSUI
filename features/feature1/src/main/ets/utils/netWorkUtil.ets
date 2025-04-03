import { APIs} from '../http/APIs';
import { ErrorType, HttpUtils, ResType } from '../http/HttpUtils';
interface  ListItem {
  engineerId:number,
  engineerName:string,
  avatarImg: string,
}
export class NetworkUtil {
  async getStoreHomePageEngineer(): Promise<ListItem[]>{
    return new Promise<ListItem[]>((resolve, reject) => {
      const url = APIs.apiPrefix + APIs.getStoreHomePageEngineer
      let result: ListItem[] = [];
      interface DataParams{
        storeId:number,
        cityId:number
      }
      interface Params {
        data:DataParams,
        pageNum:number,
        pageSize:number
      }
      const data:DataParams = {"storeId":331,"cityId":320100}
      const params: Params = {"data":data,"pageNum":1,"pageSize":10}
      HttpUtils.post(url, params).then((res: ResType) => {
        result  = res.data.list;
        console.log('---接口里面的数据:'+result)
        resolve(result)
      }).catch((err: ErrorType) => {
        console.log("---err:" + JSON.stringify(err))
      })
    })

  }
}