# 《寻岚记》本地原型

## 直接查看游戏

双击项目根目录的 `启动寻岚记.cmd`。

启动器会：

1. 自动检查桌面的 Godot 4.7.1；
2. 在需要时静默启动本机十人房服务；
3. 运行 Godot 游戏主场景；
4. 在关闭游戏后停止本次启动的服务进程。

若需要联机测试，在游戏的“开放世界”页点击“连接本机十人房”，再启动第二个游戏窗口即可看到同区角色。联机论剑已由服务端裁定位置、距离、冷却、HP 与胜负；云市已提供双人托管交换的开发期会话原型。账号、云存档、生产级战斗与正式交易经济仍处于后续开发阶段。

交易验证：两名玩家连接同一房间后，进入“市集”，一方发起交换，另一方接受；双方可组合非装备物品与灵石、提交报价并锁定。只有双方都锁定时服务端才会一次性结算。该功能仅用于本机开发会话，详见 `game-client/docs/online_trade_session_prototype_v01.md`。

## 开发验证

```powershell
$godot = 'C:\Users\Administrator\Desktop\Godot_v4.7.1-stable_win64.exe'
& $godot --headless --editor --quit --path game-client
& $godot --headless --path game-client --scene res://tests/runtime_smoke_runner.tscn
npm test --prefix server
```
