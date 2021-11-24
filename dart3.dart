import 'dart:isolate';
import 'dart:math';

void sort(List<Object> array) async {
  List<int> merge = [];
  SendPort senPort = array.last as SendPort;
  merge = array.first as List<int>;
  int middle = merge.length ~/ 2;

  if (merge.length < 2)
    senPort.send(merge);
  else {
    ReceivePort getPort = ReceivePort();
    Isolate isolate1 = await Isolate.spawn(
        sort, [merge.sublist(0, middle), getPort.sendPort]);
    Isolate isolate2 = await Isolate.spawn(
        sort, [merge.sublist(middle, merge.length), getPort.sendPort]);
    List<int> a = [], b = [];
    int i = 0;
    getPort.listen((message){
      switch (i){
        case 0:
          a = message;
          break;
        case 1:
          b = message;
          getPort.close();
          break;
      }
      i++;
    }, onDone: () {
      merge = [];
      while (!(a.isEmpty) || !(b.isEmpty)){
        if (a.isEmpty){
          merge.add(b.first);
          b.removeAt(0);
        } else if (b.isEmpty){
          merge.add(a.first);
          a.removeAt(0);
        } else if (a.first < b.first){
          merge.add(a.first);
          a.removeAt(0);
        } else {
          merge.add(b.first);
          b.removeAt(0);
        }
      }
      senPort.send(merge);
    });
  }
}
void main(){
  List<int> array = List.generate(10, (index) => Random().nextInt(201) - 100);
  print(array.toString());
  ReceivePort mainIsolatePort = ReceivePort();

  sort([array, mainIsolatePort.sendPort]);

  mainIsolatePort.listen((message){
    array = message;
    mainIsolatePort.close();
  }, onDone: (){
    print('Отсортировано: $array');
  });
}