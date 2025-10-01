elgg.import("AlGui")


import "irene.window.algui.AlGuiData"
import "irene.window.algui.AlGuiDialogBox"
import "irene.window.algui.AlGuiSoundEffect"
import "irene.window.algui.AlGuiWindowView"
import "android.view.Gravity"
import "android.graphics.Typeface"


-- 初始化末日科技风格UI
Lock.Ui(function()
    -- 清理旧UI
    if AlGui.algui then
        AlGui.algui.clearBall()
        AlGui.algui.clearMenu()
        AlGuiWindowView.clearAllViews(context)
        gui = AlGui.newGUI(context)
    else
        gui = AlGui.GUI(context)
    end

    -- 初始化通知系统
    if AlGuiBubbleNotification.bn then
        Inform = AlGuiBubbleNotification.newInform(context)
    else
        Inform = AlGuiBubbleNotification.Inform(context)
    end

    -- 末日科技风格配置
    gui.getMenuMainTitle().setText("末日控制系统")
    gui.getMenuSubTitle().setText("v3.1.4-ALPHA")
    gui.getMenuExplanation().setText("警告：异常环境专用系统 | 授权等级：Ω")
    gui.getMenuBottomLeftButton().setText("隐藏/长按退出")
    gui.getMenuBottomRightButton().setText("最小化")

    -- 长按退出
    gui.getMenuBottomLeftButton().setOnLongClickListener(luajava.createProxy(
        "android.view.View$OnLongClickListener",
        {
            onLongClick = function(edit)
                AlGuiBubbleNotification.Inform(context).clearW();
                gui.clearMenu();
                gui.clearBall();
                AlGuiWindowView.clearAllViews(context);
                luajava.exit()
            end
        }
    ))

    -- 样式配置 (末日科技风格)
    gui.setBallImage(null, 50, 50)
    gui.setAllViewMargins(6, 6, 6, 6)
    AlGuiData.menuScrollWidth = 820
    AlGuiData.menuScrollHeight = 580
    AlGuiData.rootLayoutFilletRadius = 2
    AlGuiData.rootLayoutStrokeWidth = 1.5
    AlGuiData.menuTopLineFilletRadius = 1
    AlGuiData.menuTransparency = 0.97
    AlGuiData.rootLayoutBackColor = 0xE6121212    -- 深黑背景
    AlGuiData.rootLayoutStrokeColor = 0xFF606060  -- 灰色边框
    AlGuiData.menuTopLineColor = 0xFFAA0000       -- 暗红色
    AlGuiData.menuMainTitleTextColor = 0xFFAA0000 -- 暗红标题
    AlGuiData.menuSubTitleTextColor = 0xFF606060
    AlGuiData.menuExplanationBackColor = 0x30121212
    AlGuiData.menuExplanationTextColor = 0xFF909090
    AlGuiData.menuScrollBackColor = 0x90101010 -- 更深的背景
    AlGuiData.menuBottLeftButtonTextColor = 0xFFAA0000
    AlGuiData.menuBottRightButtonTextColor = 0xFF606060
    AlGuiData.menuBottRightTriangleColor = 0xFF606060

    gui.updateMenuAppearance()
    gui.updateMenu()

    -- ============= 🪫 资源枯竭应对 =============
    local resourceModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "🪫 资源枯竭应对", 12, 0xFFAA0000, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 岩层勘探仪
    gui.addSwitch(
        resourceModule,
        "岩层勘探仪", 11, 0xFF909090, null,
        "扫描当前Y轴矿脉分布", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000, -- 开启颜色
        0xFF303030, 0xFF121212, -- 关闭颜色
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                if isChecked then
                    Inform.showCustomizeNotification(
                        0xFF121212,
                        null, 0,
                        "勘探启动", 0xFFAA0000,
                        "正在扫描地下50m内矿物...", 0xFF909090,
                        3000
                    )
                else
                    Inform.showCustomizeNotification(
                        0xFF121212,
                        null, 0,
                        "勘探关闭", 0xFFAA0000,
                        "矿物扫描已终止", 0xFF909090,
                        2000
                    )
                end
            end
        })
    )

    -- 枯矿预警信号
    gui.addButton(
        resourceModule,
        "枯矿预警扫描", 10, 0xFF909090, null,
        2, 0xFF303030, 1, 0xFF606060,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                Inform.showCustomizeNotification(
                    0xFF121212,
                    null, 0,
                    "区域分析", 0xFFAA0000,
                    "扫描半径128m内开采状态...", 0xFF909090,
                    2500
                )
            end
        })
    )

    -- ============= 🌫 环境抑制系统 =============
    local suppressModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "🌫 环境抑制系统", 12, 0xFF606060, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 毒雾屏障发生器
    gui.addSwitch(
        suppressModule,
        "毒雾屏障", 11, 0xFF909090, null,
        "半径32m内抑制生物生成", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000,
        0xFF303030, 0xFF121212,
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                if isChecked then
                    AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_WARNING)
                end
            end
        })
    )

    -- 区域冻结器
    gui.addSeekBarInt(
        suppressModule,
        "冻结半径", 10, 0xFF909090, null,
        8, 16, 64,
        0xFFAA0000, 0xFF303030, 0xFF606060,
        AlGui.T_SeekBarIntOnChangeListener({
            onProgressChanged = function(textView, seekBar, progress, fromUser)
                if fromUser then
                    textView.setText("冻结半径: " .. progress .. "m")
                end
            end
        })
    )

    -- ============= 🩻 躯体状态读取 =============
    local bioModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "🩻 躯体状态读取", 12, 0xFFAA0000, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 生理反馈中断器
    gui.addSwitch(
        bioModule,
        "状态屏蔽", 11, 0xFF909090, null,
        "阻断饥饿/中毒等负面效果", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000,
        0xFF303030, 0xFF121212,
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                AlGuiSoundEffect.getAudio(context).playSoundEffect(
                    isChecked and AlGuiSoundEffect.INFORM_SUCCESS or AlGuiSoundEffect.INFORM_ERROR
                )
            end
        })
    )

    -- ============= 📉 世界异常检测 =============
    local anomalyModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "📉 世界异常检测", 12, 0xFF606060, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 区块断层雷达
    gui.addButton(
        anomalyModule,
        "区块扫描", 10, 0xFF909090, null,
        2, 0xFF303030, 1, 0xFF606060,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                AlGuiWindowView.showText(
                    context,
                    "扫描中...",
                    0xFFAA0000,
                    12,
                    null,
                    Gravity.CENTER,
                    0, 0
                )
            end
        })
    )

    -- ============= 🕳 空洞边缘控制 =============
    local voidModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "🕳 空洞边缘控制", 12, 0xFFAA0000, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 虚空安全锁
    gui.addSwitch(
        voidModule,
        "虚空保护", 11, 0xFF909090, null,
        "坠落虚空时强制传送", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000,
        0xFF303030, 0xFF121212,
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                -- 虚空保护逻辑
            end
        })
    )

    -- ============= 📦 容器内容操控 =============
    local containerModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "📦 容器内容操控", 12, 0xFF606060, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 自动补给模块
    gui.addSwitch(
        containerModule,
        "自动补给", 11, 0xFF909090, null,
        "从指定容器补充消耗品", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000,
        0xFF303030, 0xFF121212,
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                -- 自动补给逻辑
            end
        })
    )

    -- ============= 📉 沉寂通道构建 =============
    local silentModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "📉 沉寂通道构建", 12, 0xFFAA0000, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 低语传送门
    gui.addButton(
        silentModule,
        "创建隐秘通道", 10, 0xFF909090, null,
        2, 0xFF303030, 1, 0xFF606060,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                -- 创建隐秘通道逻辑
            end
        })
    )

    -- ============= 📍 空间锚定系统 =============
    local anchorModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "📍 空间锚定系统", 12, 0xFF606060, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 精确标记器
    gui.addEditText(
        anchorModule,
        10, null,
        0xFF606060, "锚点名称",
        0xFF909090, "",
        2, 0x40121212, 1, 0xFF606060,
        0xFF121212, "设置",
        2, 0xFF303030, 1, 0xFF606060,
        AlGui.T_EditTextOnChangeListener({
            buttonOnClick = function(edit, button, buttonText, isChecked)
                local anchorName = edit.getText()
                if anchorName and anchorName ~= "" then
                    -- 设置锚点逻辑
                end
            end
        })
    )

    -- ============= ⚗️ 元素失衡反应 =============
    local elementModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "⚗️ 元素失衡反应", 12, 0xFFAA0000, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 能量过载终结器
    gui.addSwitch(
        elementModule,
        "过载保护", 11, 0xFF909090, null,
        "自动切断危险红石电路", 8, 0xFF606060, null,
        0xFFAA0000, 0xFF660000,
        0xFF303030, 0xFF121212,
        AlGui.T_SwitchOnChangeListener({
            onClick = function(aSwitch, desc, isChecked)
                -- 过载保护逻辑
            end
        })
    )

    -- ============= 📶 虚构系统注入 =============
    local simulateModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "📶 虚构系统注入", 12, 0xFF606060, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        4, 0x40121212, 1, 0xFF606060,
        false
    )

    -- 假界生物生成器
    gui.addButton(
        simulateModule,
        "生成伪装实体", 10, 0xFF909090, null,
        2, 0xFF303030, 1, 0xFF606060,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                -- 生成伪装实体逻辑
            end
        })
    )

    -- 功能菜单1弹框
    function showMenu1Dialog()
        al1 = AlGuiDialogBox.showDiaLog(
            context, 0xE6202020, 5,

            -- 标题
            gui.addTextView("功能菜单1", 16, 0xFF55FF55, Typeface.create(Typeface.DEFAULT, Typeface.BOLD)),

            -- 分割线
            gui.addLine(nil, 1, 0xFF555555, true),

            -- 功能按钮1
            gui.addButton(
                "自动挖矿", 12, 0xFFFFFFFF, null,
                3, 0xFF5555FF, 1, 0xFF0000AA,
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
                AlGui.T_ButtonOnChangeListener({
                    onClick = function(button, back, buttonText, isChecked)
                        AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_SUCCESS)
                        Inform.showSuccessNotification_Simplicity(null, "自动挖矿", "功能已启动", 2000)
                    end
                })
            ),

            -- 功能按钮2
            gui.addButton(
                "快速建造", 12, 0xFFFFFFFF, null,
                3, 0xFF55FF55, 1, 0xFF00AA00,
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
                AlGui.T_ButtonOnChangeListener({
                    onClick = function(button, back, buttonText, isChecked)
                        AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_SUCCESS)
                        Inform.showSuccessNotification_Simplicity(null, "快速建造", "模板选择已打开", 2000)
                    end
                })
            ),

            -- 关闭按钮
            gui.addButton(
                "关闭", 12, 0xFFFFFFFF, null,
                3, 0xFFFF5555, 1, 0xFFAA0000,
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
                AlGui.T_ButtonOnChangeListener({
                    onClick = function(button, back, buttonText, isChecked)
                        al1.dismiss()
                    end
                })
            )
        )
    end

    -- 功能菜单2弹框
    function showMenu2Dialog()
        al2 = AlGuiDialogBox.showDiaLog(
            context, 0xE6202020, 5,

            -- 标题
            gui.addTextView("功能菜单2", 16, 0xFF5555FF, Typeface.create(Typeface.DEFAULT, Typeface.BOLD)),

            -- 分割线
            gui.addLine(nil, 1, 0xFF555555, true),

            -- 开关1
            gui.addSwitch(
                "夜视模式", 12, 0xFFFFFFFF, null,
                "在黑暗中保持视野", 10, 0xFFAAAAAA, null,
                0xFF55FF55, 0xFF00AA00,
                0xFFFF5555, 0xFFAA0000,
                AlGui.T_SwitchOnChangeListener({
                    onClick = function(aSwitch, desc, isChecked)
                        if isChecked then
                            Inform.showSuccessNotification_Simplicity(null, "夜视模式", "已启用", 2000)
                        else
                            Inform.showSuccessNotification_Simplicity(null, "夜视模式", "已禁用", 2000)
                        end
                    end
                })
            ),

            -- 滑块控制
            gui.addSeekBarInt(
                "移动速度", 12, 0xFFFFFFFF, null,
                100, 100, 300,
                0xFF5555FF, 0xFF333399, 0xFF0000AA,
                AlGui.T_SeekBarIntOnChangeListener({
                    onProgressChanged = function(textView, seekBar, progress, fromUser)
                        textView.setText("移动速度: " .. progress .. "%")
                    end
                })
            ),

            -- 关闭按钮
            gui.addButton(
                "关闭", 12, 0xFFFFFFFF, null,
                3, 0xFFFF5555, 1, 0xFFAA0000,
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
                AlGui.T_ButtonOnChangeListener({
                    onClick = function(button, back, buttonText, isChecked)
                        al2.dismiss()
                    end
                })
            )
        )
    end

    -- 在主UI中添加触发按钮
    local mainModule = gui.addCollapse(
        gui.getMenuScrollingListLayout(),
        "快捷菜单", 12, 0xFFFFFF55, Typeface.create(Typeface.DEFAULT, Typeface.BOLD),
        5, 0x40202020, 1, 0xFF555555,
        false
    )

    -- 菜单1按钮
    gui.addButton(
        mainModule,
        "打开功能菜单1", 12, 0xFFFFFFFF, null,
        3, 0xFF5555FF, 1, 0xFF0000AA,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                showMenu1Dialog()
            end
        })
    )

    -- 菜单2按钮
    gui.addButton(
        mainModule,
        "打开功能菜单2", 12, 0xFFFFFFFF, null,
        3, 0xFF55FF55, 1, 0xFF00AA00,
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT,
        AlGui.T_ButtonOnChangeListener({
            onClick = function(button, back, buttonText, isChecked)
                showMenu2Dialog()
            end
        })
    )

    -- 显示悬浮球
    gui.showBall()

    -- 初始警告通知
    Inform.showCustomizeNotification(
        0xFF121212,
        null, 0,
        "系统激活警告", 0xFFAA0000,
        "异常环境控制协议已加载", 0xFF909090,
        4000
    )
    AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_WARNING)
end, nil, function(err)
    AlGuiWindowView.clearAllViews(context)
    print("系统崩溃: " .. err)
    luajava.exit()
end)
