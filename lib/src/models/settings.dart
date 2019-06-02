class Settings {
  String key;
  dynamic value = false;

  Settings(this.key, this.value);
}

class SettingsGroup {
  String name;
  List<Settings> childs;
  SettingsGroup(this.name, this.childs);
}