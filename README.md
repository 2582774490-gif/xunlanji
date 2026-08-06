# 《寻岚记》本地原型

## 直接查看游戏

双击项目根目录的 `启动寻岚记.cmd`。

启动器会：

1. 自动检查桌面的 Godot 4.7.1；
2. 在需要时静默启动本机十人房服务；
3. 运行 Godot 游戏主场景；
4. 在关闭游戏后停止本次启动的服务进程。

若需要联机测试，在游戏的“开放世界”页点击“连接本机十人房”，再启动第二个游戏窗口即可看到同区角色。该服务目前只同步在线名册、区域和位置；账号、服务器战斗与真实交易结算仍处于后续开发阶段。

## 开发验证

```powershell
$godot = 'C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
& $godot --headless --editor --quit --path game-client
& $godot --headless --path game-client --scene res://tests/runtime_smoke_runner.tscn
npm test --prefix server
```
