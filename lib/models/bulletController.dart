class BulletController {
  List<BulletRow> list = [

  ];
  void reRender () {
    for(int i = 0; i < list.length; i++) {
      list[i].index = i;
    }
  }
}

class BulletRow {
  int index;
  int count;
  BulletRow({this.index, this.count});
}