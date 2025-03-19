// Index.ets
import { WaterFlowDataSource } from './WaterFlowDataSource';
@Preview
@Reusable
@Component
struct ReusableFlowItem {
  @State item: number = 0;

  // 从复用缓存中加入到组件树之前调用，可在此处更新组件的状态变量以展示正确的内容
  aboutToReuse(params: Record<string, number>) {
    this.item = params.item;
    console.info('Reuse item:' + this.item);
  }

  aboutToAppear() {
    console.info('new item:' + this.item);
  }

  build() {
    Image('res/waterFlowTest(' + this.item % 5 + ').jpg')
      .overlay('N' + this.item, { align: Alignment.Top })
      .objectFit(ImageFit.Fill)
      .width('100%')
      .layoutWeight(1)
  }
}

@Component
export default struct WaterFlowDemo {
  minSize: number = 80;
  maxSize: number = 180;
  fontSize: number = 24;
  colors: number[] = [0x6A5ACD, 0x00FFFF, 0x00FF7F];
  scroller: Scroller = new Scroller();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  dataCount: number = this.dataSource.totalCount();
  private itemHeightArray: number[] = [];
  @State sections: WaterFlowSections = new WaterFlowSections();
  sectionMargin: Margin = { top: 10,  bottom: 10};
  oneColumnSection: SectionOptions = {
    itemsCount: 1,
    crossCount: 1,
    columnsGap: '5vp',
    rowsGap: 10,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
     return 100
    }
  }
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    onGetItemMainSizeByIndex: (index: number) => {
      return 100;
    }
  }
  lastSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    onGetItemMainSizeByIndex: (index: number) => {
      return 100
    }
  }

  // 计算FlowItem高度
  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  // 设置FlowItem的高度数组
  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
    // 初始化瀑布流分组信息
    let sectionOptions: SectionOptions[] = [];
    let count = 0;
    let oneOrTwo = 0;
    while (count < this.dataCount) {
      if (this.dataCount - count < 20) {
        this.lastSection.itemsCount = this.dataCount - count;
        sectionOptions.push(this.lastSection);
        break;
      }
      if (oneOrTwo++% 2 === 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(0, 0, sectionOptions);
  }

  build() {
    Column({ space: 2 }) {
      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        LazyForEach(this.dataSource, (item: number) => {
          FlowItem() {
            ReusableFlowItem({ item: item })
          }
          .width('100%')
          // 以onGetItemMainSizeByIndex为准
           //.height(this.itemHeightArray[item % 100])
          .backgroundColor(this.colors[item % 3])
        }, (item: string) => item)
      }
      .columnsTemplate('1fr 1fr') // 瀑布流使用sections参数时该属性无效
      .columnsGap(10)
      .rowsGap(5)
      .backgroundColor(0xFAEEE0)
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .onScrollIndex((first: number, last: number) => {
        // 即将触底时提前增加数据
        if (last + 20 >= this.dataSource.totalCount()) {
          for (let i = 0; i < 100; i++) {
            this.dataSource.addLastItem();
          }
          // 更新数据源后同步更新sections，修改最后一个section的FlowItem数量
          const sections: Array<SectionOptions> = this.sections.values();
          let newSection: SectionOptions = sections[this.sections.length() - 1];
          newSection.itemsCount += 100;
          this.sections.update(-1, newSection);
        }
      })
    }
    .height('260vp')
  }
}