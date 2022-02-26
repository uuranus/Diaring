class Memo{
  int id;
  String title="";
  String content="";
  DateTime date_created=DateTime.now();
  DateTime date_last_edited=DateTime.now();
  int indexOfColor=0;

  Memo(this.id, this.title, this.content, this.date_created,
        this.date_last_edited, this.indexOfColor);

  Memo.fromJson(this.id,Map data){
    title=data['title'];
    content=data['content'];
    date_created=DateTime.parse(data['date_created']);
    date_last_edited=DateTime.parse(data['date_last_edited']);
    indexOfColor=data['indexOfColor'];
  }
}