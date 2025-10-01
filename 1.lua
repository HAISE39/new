elgg.import("AlGui")


import "irene.window.algui.AlGuiData"
import "irene.window.algui.AlGuiDialogBox"
import "irene.window.algui.AlGuiSoundEffect"
import "irene.window.algui.AlGuiWindowView"
import "irene.window.algui.Tools.VariousTools"
import "java.util.Locale"
import "android.view.animation.Animation"
import "android.view.Gravity"
import "android.graphics.Typeface"


-- 语音播报功能 参数 { 上下文，播报内容，机器人语言 }
-- 太烦了 就注释了
-- VariousTools.convertTextToSpeech(context, "欢迎使用Algui，如果你遇到了问题请加入QQ群聊123！", Locale.CHINA)
function initConfigurations()
    -- 文本相关📝
    gui.getMenuMainTitle().setText("Algui") --  设置ALGUI主标题文本
    gui.getMenuSubTitle().setText("版本：2.0") --  设置ALGUI副标题文本
    gui.getMenuExplanation().setText("作者：艾琳⼁仅供用于学习交流请勿用于违法用途⼁如果您有任何疑问请进游戏逆向交流群：123进行交流讨论") --  设置ALGUI说明信息文本 (如果启动了网络验证那么说明信息为网络验证公告)
    gui.getMenuBottomLeftButton().setText("隐藏/长按退出") --  设置ALGUI左下角隐藏或退出按钮文本
    -- 这是我自己写的长按退出
    gui.getMenuBottomLeftButton().setOnLongClickListener(luajava.createProxy(
        "android.view.View$OnLongClickListener",
        {
            onLongClick = function(edit)
                AlGuiBubbleNotification.Inform(context).clearW();
                gui.clearMenu();
                gui.clearBall();
                -- 清除所有浮窗
                AlGuiWindowView.clearAllViews(context);
                luajava.exit()
            end
        }
    ))
    gui.getMenuBottomRightButton().setText("最小化") --  设置ALGUI右下角最小化按钮文本

    -- 属性相关⚙️
    gui.setBallImage(null, 50, 50)         --  设置ALGUI悬浮球图片(支持gif|png|jpg…) {参数：Assets文件夹下的图片名(null代表不使用图片而是默认MOD视图)，悬浮球宽高}
    -- gui.setBallImage("icon.png", 50, 50)--  示例：这样设置悬浮球可以将assets文件夹下的icon.png图片文件设置为悬浮球
    gui.setAllViewMargins(8, 8, 8, 8)      --  设置ALGUI滚动菜单内所有视图的外边距 {参数：左，上，右，下的外边}
    AlGuiData.menuScrollWidth = 809        --  设置ALGUI窗口初始宽度
    AlGuiData.menuScrollHeight = 554       --  设置ALGUI窗口初始高度
    AlGuiData.rootLayoutFilletRadius = 0   -- 设置ALGUI窗口圆角半径
    AlGuiData.rootLayoutStrokeWidth = 0.4  --  设置ALGUI窗口描边宽度
    AlGuiData.menuTopLineFilletRadius = 20 --  设置ALGUI顶部状态线条的圆角半径
    AlGuiData.menuTransparency = 1         -- 设置ALGUI窗口透明度 (透明度范围在0和1之间)


    -- 颜色相关🎨
    AlGuiData.rootLayoutBackColor = 0xE6303030          --  设置ALGUI窗口主背景颜色 (可以理解为上下边栏的颜色)
    AlGuiData.rootLayoutStrokeColor = 0xFF616161        --  设置ALGUI窗口描边颜色
    AlGuiData.menuTopLineColor = 0xFFBDBDBD             --  设置ALGUI顶部移动状态线条未高亮时的颜色 (高亮颜色暂不支持设置)
    AlGuiData.menuMainTitleTextColor = 0xFFFFFFFF       --  设置ALGUI主标题文本颜色
    AlGuiData.menuSubTitleTextColor = 0x60FFFFFF        --  设置ALGUI副标题文本颜色
    AlGuiData.menuExplanationBackColor = 0x60FFFFFF     --  设置ALGUI说明信息背景颜色
    AlGuiData.menuExplanationTextColor = 0xFFFFFFFF     --  设置ALGUI说明信息文本颜色
    AlGuiData.menuScrollBackColor = 0x6E212121          --  设置ALGUI滚动菜单背景颜色
    AlGuiData.menuBottLeftButtonTextColor = 0xFFFFFFFF  --  设置ALGUI左下角按钮文本颜色
    AlGuiData.menuBottRightButtonTextColor = 0xFFFFFFFF --  设置ALGUI右下角按钮文本颜色
    AlGuiData.menuBottRightTriangleColor = 0xFF616161   --  设置ALGUI右下角可拉拽缩放窗口的边角颜色

    -- 配置完成后不要忘记更新ALGUI，否则可能无效😋
    gui.updateMenuAppearance() --  更新ALGUI外观
    gui.updateMenu()           --  更新ALGUI窗口
end

--📍ALGUI滚动菜单
function initMenu()
    --💥下面进入折叠菜单以及全部UI组件和交互方式的学习

    --在ALGUI滚动列表中添加作者制作的菜单，以展示最终效果(只展示了一部分UI)。
    --这些菜单的功能非常有用，你也可以选择保留它们😋
    --在滚动列表中 添加《使用说明》折叠菜单
    gui.getMenuScrollingListLayout().addView(
        gui.PrefabricatedMenu().addExplanation(null)
    )
    --在滚动列表中 添加《属性状态》折叠菜单
    gui.getMenuScrollingListLayout().addView(
        gui.PrefabricatedMenu().addAttributeStatusMenu(null)
    )
    --在滚动列表中 添加《外观设置》折叠菜单
    gui.getMenuScrollingListLayout().addView(
        gui.PrefabricatedMenu().addAppearanceSettingsMenu(null)
    )
    --在滚动列表中 添加《游戏准星》折叠菜单
    gui.getMenuScrollingListLayout().addView(
        gui.PrefabricatedMenu().addGameFrontSightMenu(null)
    )

    --💥你也可以自定义你的折叠菜单，下面以演示ALGUI各种UI使用教程以及交互方式
    --使用gui.getMenuScrollingListLayout()方法可以获取到悬浮窗滚动列表的布局
    --将滚动列表作为一个视图的父布局就代表此视图显示在滚动列表中

    --添加一个折叠菜单
    折叠菜单1 = gui.addCollapse
        (
            gui.getMenuScrollingListLayout(), --父布局
            "折叠菜单(所有视图控件演示)", 10, 0xFF000000, null, --折叠菜单文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
            3, --折叠菜单圆角半径
            0xFFFFFFFF, --折叠菜单背景颜色
            0, 0xFFC5CAE9, --折叠菜单描边大小，描边颜色
            false --折叠菜单默认是否展开 (true=默认展开，false=默认不展开)
        )

    --添加一条线 {参数：父布局，线的厚度，线的颜色，线的方向(true=横向 false=竖向)}
    gui.addLine(折叠菜单1, 0.5, 0xFFE0E0E0, true)

    --添加一个文本 {参数：父布局，文本内容，文本大小，文本颜色，文本字体(null代表跟随系统字体)}
    gui.addTextView(折叠菜单1, "这是一个普通文本", 11, 0xFF000000, null)

    --添加一个字幕文本
    gui.addMarqueeTextView
    (
        折叠菜单1, --父布局
        Gravity.LEFT, --对齐方式
        "这是一个可以滚动的字幕文本", --文本
        11, --文本大小
        0xFF000000, --文本颜色
        null, --文本字体
        5000, --滚动一次的时间 单位毫秒
        Animation.INFINITE, --重复次数
        true --是否只显示一行
    )
    --添加一个Web网站 参数：父布局，网站链接 (可能会影响外观，除非网站不大，总之没什么用除非你有特殊需求)
    --gui.addWebSite(折叠菜单1,"https://img2.imgtp.com/2024/02/14/aOxtoFpY.png")

    --添加一个HTML视图 (支持一切HTML代码) 参数：父布局，HTML代码
    gui.addWebView(折叠菜单1,
        "<html><head><style>h1, img { display: inline-block vertical-align: middle }</style></head><body><h1>这是一个HTML视图</h1><img width='10%' src='https://img2.imgtp.com/2024/02/15/h1mOgOxq.jpg' ></body></html>")


    --添加一个带按钮的输入框
    gui.addEditText
    (
        折叠菜单1, --父布局
        9, null, --输入框和按钮的文本大小，输入框和按钮的文本字体(null代表跟随系统字体)
        0xFFCECECE, "这是一个输入框", --输入框提示内容颜色，输入框提示内容
        0xC200FF00, "", --输入框输入内容颜色，输入框默认输入内容
        5, 0xA8000000, 0, 0, --输入框圆角半径, 输入框背景色, 输入框描边厚度, 输入框描边颜色
        0xFFFFFFFF, "确认", --按钮文本颜色，按钮文本
        5, 0xFF5492E5, 0, 0xFFFFFFFF, --按钮圆角半径，按钮背景色，按钮描边厚度，按钮描边颜色

        --输入框事件监听器
        AlGui.T_EditTextOnChangeListener(
            {
                beforeTextChanged = function(edit, cs, start, count, after)
                    print("beforeTextChanged", tostring(cs))
                end,
                onTextChanged = function(edit, cs, start, before, count)
                    print("onTextChanged", tostring(cs))
                end,
                afterTextChanged = function(edit, editable)
                    print("afterTextChanged", editable)
                end,
                buttonOnClick = function(edit, button, buttonText, isChecked)
                    local text = edit.getText()
                    print("按钮点击，输入：" .. text)
                end
            }
        )
    )

    --添加一个普通输入框
    edit = gui.addEditText
        (
            折叠菜单1, --父布局
            9, null, --输入框和按钮的文本大小，输入框和按钮的文本字体(null代表跟随系统字体)
            0xFFCECECE, "这是一个输入框", --输入框提示内容颜色，输入框提示内容
            0xC200FF00, "", --输入框输入内容颜色，输入框默认输入内容
            5, 0xA8000000, 0, 0, --输入框圆角半径, 输入框背景色, 输入框描边厚度, 输入框描边颜色

            --输入框事件监听器
            AlGui.T_EditTextOnChangeListener(
                {
                    beforeTextChanged = function(edit, cs, start, count, after)
                        print("beforeTextChanged", tostring(cs))
                    end,
                    onTextChanged = function(edit, cs, start, before, count)
                        print("onTextChanged", tostring(cs))
                    end,
                    afterTextChanged = function(edit, editable)
                        print("afterTextChanged", editable)
                    end,
                    buttonOnClick = function(edit, button, buttonText, isChecked)
                        local text = edit.getText()
                        print("按钮点击，输入：" .. text)
                    end
                }
            )
        )

    --添加一个普通按钮
    gui.addButton
    (
        折叠菜单1, --父布局
        "普通按钮", 11, 0xFFFFFFFF, null, --按钮文本，文本大小，文本颜色，文本字体
        5, --按钮圆角半径
        0xFF3F51B5, --按钮背景颜色
        0, 0xff000000, --按钮描边大小，描边颜色
        LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, --按钮宽高
        --按钮事件监听器
        AlGui.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    --按钮点击时执行的内容
                    --悬浮显示一个HTML窗口 {参数：上下文，窗口标题，HTML代码}
                    AlGuiWindowView.showWebView(context, "刷视频",
                        "<html><body><video width=\"100%\" height=\"auto\" controls><source src=\"" ..
                        "http://api.yujn.cn/api/xjj.php" .. "\" type=\"video/mp4\"></video></body></html>")

                    --你也可以使用isChecked来制作开关按钮
                    --[[
                    /*if isChecked then
                     --按钮开启时执行的内容
                     buttonText.setText("普通按钮：关闭")
                     back.setColor(0xFFEF5350)
                     else
                     --按钮关闭时执行的内容
                     buttonText.setText("普通按钮：开启")
                     back.setColor(0xFF4CAF50)
                     end */
                     ]]
                end,
            }
        )
    )


    --添加一个开关按钮
    gui.addSwitch
    (
        折叠菜单1, --父布局
        "开关", 11, 0xFF000000, null, --开关文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        "说明：这是一个开关", 8, 0xFF9E9E9E, null, --开关描述文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0xFF4CAF50, 0xFF66BB6A, --开关圆柄开启时的颜色 和 开关轨迹开启时的颜色
        0xFFF44336, 0xFFEF5350, --开关圆柄关闭时的颜色 和 开关轨迹关闭时的颜色
        --开关按钮事件监听器
        AlGui.T_SwitchOnChangeListener(
            {
                onClick = function(aSwitch, desc, isChecked)
                    --开关按钮点击时将执行这里的内容
                    --这将获取到开关的文本
                    local switchText = aSwitch.getText()

                    -- 获取描述信息的文本
                    local descText = desc.getText()
                    --isChecked为开关状态
                    if isChecked then
                        --开启时执行的内容
                        --右下角气泡通知 (如需了解详情，请看最后面的拓展性功能注释)
                        Inform.showSuccessNotification_Simplicity(null, switchText, "开启成功！", 5000)
                    else
                        --关闭时执行的内容
                        --右下角气泡通知 (如需了解详情，请看最后面的拓展性功能注释)
                        Inform.showSuccessNotification_Simplicity(null, switchText, "关闭成功！", 5000)
                    end
                end,
            }
        )
    )


    --添加一个整数拖动条
    gui.addSeekBarInt
    (
        折叠菜单1, --父布局
        "整数拖动条", 11, 0xFF000000, null, --文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0, 0, 100, --最小进度，初始进度，最大进度
        0xFF5492E5, 0xFF5492E5, 0xFF5492E5, --进度圆柄颜色，进度条未拖动时的颜色，进度条拖动后的颜色
        --拖动条事件监听器
        AlGui.T_SeekBarIntOnChangeListener(
            {
                onProgressChanged = function(textView, seekBar, progress, fromUser)
                    -- 当拖动条进度改变时执行的内容
                    print("onProgressChanged: 当前进度值 = " .. progress)
                end,

                onStartTrackingTouch = function(textView, seekBar, progress)
                    -- 当开始拖动拖动条时执行的内容
                    print("onStartTrackingTouch: 当前进度值 = " .. progress)
                end,

                onStopTrackingTouch = function(textView, seekBar, progress)
                    -- 当停止拖动拖动条时执行的内容
                    print("onStopTrackingTouch: 当前进度值 = " .. progress)
                end
            }
        )
    )



    --添加一个更加精准的小数拖动条
    gui.addSeekBarFloat
    (
        折叠菜单1, --父布局
        "小数拖动条", 11, 0xFF000000, null, --文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0, 0, 100, --最小进度，初始进度，最大进度
        0xFF5492E5, 0xFF5492E5, 0xFF5492E5, --进度圆柄颜色，进度条未拖动时的颜色，进度条拖动后的颜色
        --拖动条事件监听器
        AlGui.T_SeekBarFloatOnChangeListener(
            {
                onProgressChanged = function(textView, seekBar, progress, fromUser)
                    -- 当拖动条进度改变时执行的内容
                    print(string.format("onProgressChanged: 当前进度值 = %.2f，是否为用户操作 = %s", progress, tostring(fromUser)))
                end,

                onStartTrackingTouch = function(textView, seekBar, progress)
                    -- 当开始拖动拖动条时执行的内容
                    print(string.format("onStartTrackingTouch: 当前进度值 = %.2f", progress))
                end,

                onStopTrackingTouch = function(textView, seekBar, progress)
                    -- 当停止拖动拖动条时执行的内容
                    print(string.format("onStopTrackingTouch: 当前进度值 = %.2f", progress))
                end
            }
        )
    )

    --添加一个线性布局用来改变布局方向，而不是一味的垂直添加视图
    横向布局1 = gui.addLinearLayout
        (
            折叠菜单1, --父布局
            Gravity.CENTER, --子视图对齐方式
            LinearLayout.HORIZONTAL, --线性布局方向
            LinearLayout.LayoutParams.MATCH_PARENT, --线性布局宽
            LinearLayout.LayoutParams.MATCH_PARENT --线性布局高
        )

    gui.addCheckBox
    (
        横向布局1, --父布局
        "复选框1", 11, 0xFF000000, null, --复选框文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0xFF3F51B5, --复选框颜色
        --复选框事件监听器
        AlGui.T_CheckBoxOnChangeListener(
            {
                onClick = function(buttonView, isChecked)
                    -- 复选框点击时执行的内容
                    local text = buttonView.getText()

                    if isChecked then
                        -- 复选框开启时执行的内容
                        Inform.showSuccessNotification_Simplicity(
                            nil, text, "开启成功！", 5000
                        )
                    else
                        -- 复选框关闭时执行的内容
                        Inform.showSuccessNotification_Simplicity(
                            nil, text, "关闭成功！", 5000
                        )
                    end
                end
            }
        )
    )

    --添加一个复选框

    gui.addCheckBox
    (
        横向布局1, --父布局
        "复选框2", 11, 0xFF000000, null, --复选框文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0xFF3F51B5, --复选框颜色
        --复选框事件监听器
        AlGui.T_CheckBoxOnChangeListener(
            {
                onClick = function(buttonView, isChecked)
                    -- 复选框点击时执行的内容
                    local text = buttonView.getText()

                    if isChecked then
                        -- 复选框开启时执行的内容
                        Inform.showSuccessNotification_Simplicity(
                            nil, text, "开启成功！", 5000
                        )
                    else
                        -- 复选框关闭时执行的内容
                        Inform.showSuccessNotification_Simplicity(
                            nil, text, "关闭成功！", 5000
                        )
                    end
                end
            }
        )
    )

    --添加一个小按钮

    gui.addSmallButton
    (
        横向布局1, --父布局
        "开启飞天", 11, 0xFFFFFFFF, null, --小按钮文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        5, --小按钮圆角半径
        0xFF4CAF50, --小按钮背景颜色
        0, 0xff000000, --小按钮描边大小，描边颜色
        --小按钮事件监听器
        AlGui.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 按钮点击时执行的内容
                    if isChecked then
                        -- 按钮开启时执行的内容
                        buttonText.setText("关闭飞天")
                        back.setColor(0xFFEF5350) -- 红色
                    else
                        -- 按钮关闭时执行的内容
                        buttonText.setText("开启飞天")
                        back.setColor(0xFF4CAF50) -- 绿色
                    end
                end
            }
        )
    )

    --添加一个小按钮

    gui.addSmallButton
    (
        横向布局1, --父布局
        "开启无后", 11, 0xFFFFFFFF, null, --小按钮文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        5, --小按钮圆角半径
        0xFF4CAF50, --小按钮背景颜色
        0, 0xff000000, --小按钮描边大小，描边颜色
        --小按钮事件监听器
        AlGui.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 按钮点击时执行的内容
                    if isChecked then
                        -- 按钮开启时执行的内容
                        buttonText.setText("关闭无后")
                        back.setColor(0xFFEF5350) -- 红色
                    else
                        -- 按钮关闭时执行的内容
                        buttonText.setText("开启无后")
                        back.setColor(0xFF4CAF50) -- 绿色
                    end
                end
            }
        )
    )
    --至此以上就已经演示完成了ALGUI滚动列表中所有的UI组件和交互方式






    --下面自己试试吧
    --添加一个折叠菜单
    折叠菜单2 = gui.addCollapse
        (
            gui.getMenuScrollingListLayout(), --父布局
            "我的菜单", 10, 0xFF000000, null, --折叠菜单文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
            3, --折叠菜单圆角半径
            0xFFFFFFFF, --折叠菜单背景颜色
            0, 0xFFC5CAE9, --折叠菜单描边大小，描边颜色
            false --折叠菜单默认是否展开 (true=默认展开，false=默认不展开)
        )




    --💥如果你想直接在滚动列表中添加UI而不是一味的在折叠菜单中添加那么请看下面内容
    --直接将父布局设置为gui.getMenuScrollingListLayout()滚动列表布局当中即可
    --例如在滚动列表直接添加一个普通文本和一个开关按钮
    --添加一个文本 {参数：父布局，文本内容，文本大小，文本颜色，文本字体(null代表跟随系统字体)}

    gui.addTextView(gui.getMenuScrollingListLayout(), "这是一个普通文本", 11, 0xFFFFFFFF, null)
    --添加一个开关按钮
    gui.addSwitch
    (
        gui.getMenuScrollingListLayout(), --父布局
        "开关", 11, 0xFFFFFFFF, null, --开关文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        "说明：这是一个开关222", 8, 0xFF9E9E9E, null, --开关描述文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
        0xFF4CAF50, 0xFF66BB6A, --开关圆柄开启时的颜色 和 开关轨迹开启时的颜色
        0xFFF44336, 0xFFEF5350, --开关圆柄关闭时的颜色 和 开关轨迹关闭时的颜色
        --开关按钮事件监听器
        AlGui.T_SwitchOnChangeListener(
            {
                onClick = function(aSwitch, desc, isChecked)
                    -- 开关按钮点击时执行的内容

                    -- 获取开关的文本
                    local switchText = aSwitch.getText()

                    -- 获取描述信息的文本
                    local descText = desc.getText()

                    -- 根据开关状态显示气泡通知
                    if isChecked then
                        -- 开启时执行
                        Inform.showSuccessNotification_Simplicity(
                            nil, switchText, "开启成功！", 5000
                        )
                    else
                        -- 关闭时执行
                        Inform.showSuccessNotification_Simplicity(
                            nil, switchText, "关闭成功！", 5000
                        )
                    end
                end
            }
        )
    )








    --🔥[拓展性功能]ALGUI其他悬浮窗口组件使用演示😋 ━━━━━━━━━━━━━━━━━━━━━━━━━━

    --语音播报功能 参数{上下文，播报内容，机器人语言}
    -- VariousTools.convertTextToSpeech(context, "Welcome to Algui Hello, welcome. This is the voice broadcast demonstration. It has been successfully opened. This is the voice broadcast demonstration. What are you doing? This is a voice broadcast demo.", Locale.US)

    --AlGuiDialogBox [对话框组件🔧] ───────────────────────────────
    --作用：显示各种对话框
    --下面是AlGuiDialogBox使用演示
    --显示一个文本对话框 参数{上下文，标题文本，内容文本，按钮文本}
    -- AlGuiDialogBox.showTextDiaLog(context, "标题", "内容", "我知道了")
    --显示一个可以对话框空模板可以往其中添加控件
    AlGuiDialogBox.showDiaLog
    (                            --这对括号是对话框布局区域，在其中添加的视图将显示在此对话框当中
        context, 0xCEFAFAFA, 50, --上下文，对话框背景色，对话框圆角半径

        --添加一个线性布局
        gui.addLinearLayout
        (                                           --这对括号是线性布局的区域，在其中添加的视图将显示在此线性布局当中
            Gravity.CENTER,                         --子视图对齐方式
            LinearLayout.VERTICAL,                  --线性布局方向
            LinearLayout.LayoutParams.MATCH_PARENT, --线性布局宽
            LinearLayout.LayoutParams.WRAP_CONTENT, --线性布局高

            gui.addTextView("自定义布局对话框", 18, 0xFF212121, Typeface.create(Typeface.DEFAULT, Typeface.BOLD))
        )

        , --以逗号分隔

        --添加一个开关按钮
        gui.addSwitch
        (
            "开关", 11, 0xFF000000, null, --开关文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
            "说明：这是一个开关", 8, 0xFF9E9E9E, null, --开关描述文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
            0xFF4CAF50, 0xFF66BB6A, --开关圆柄开启时的颜色 和 开关轨迹开启时的颜色
            0xFFF44336, 0xFFEF5350, --开关圆柄关闭时的颜色 和 开关轨迹关闭时的颜色
            --开关按钮事件监听器
            AlGui.T_SwitchOnChangeListener(
                {
                    onClick = function(aSwitch, desc, isChecked)
                        -- 开关按钮点击时将执行这里的内容

                        -- 获取开关的文本
                        local switchText = aSwitch.getText()

                        -- 获取描述信息的文本
                        local descText = desc.getText()

                        -- 根据开关状态判断
                        if isChecked then
                            -- 开启时执行的内容
                            Inform.showSuccessNotification_Simplicity(
                                nil, switchText, "开启成功！", 5000
                            )
                        else
                            -- 关闭时执行的内容
                            Inform.showSuccessNotification_Simplicity(
                                nil, switchText, "关闭成功！", 5000
                            )
                        end
                    end
                }
            )
        )

        , --以逗号分隔

        --添加一个整数拖动条
        gui.addSeekBarInt
        (
            "整数拖动条", 11, 0xFF000000, null, --文本，文本大小，文本颜色，文本字体(null代表跟随系统字体)
            0, 0, 100, --最小进度，初始进度，最大进度
            0xFF5492E5, 0xFF5492E5, 0xFF5492E5, --进度圆柄颜色，进度条未拖动时的颜色，进度条拖动后的颜色
            --拖动条事件监听器
            AlGui.T_SeekBarIntOnChangeListener(
                {
                    onProgressChanged = function(textView, seekBar, progress, fromUser)
                        -- 当拖动条进度改变时执行的内容
                        print(string.format("onProgressChanged：进度 = %d，用户拖动 = %s", progress, tostring(fromUser)))
                    end,

                    onStartTrackingTouch = function(textView, seekBar, progress)
                        -- 当开始拖动拖动条时执行的内容
                        print("onStartTrackingTouch：进度 = " .. progress)
                    end,

                    onStopTrackingTouch = function(textView, seekBar, progress)
                        -- 当停止拖动拖动条时执行的内容
                        print("onStopTrackingTouch：进度 = " .. progress)
                    end
                }
            )
        )
    --等等…
    )
    --AlGuiWindowView [其他悬浮窗口组件🔧] ───────────────────────────────
    --作用：悬浮显示各种视图和窗口
    --下面是AlGuiWindowView使用演示
    --屏幕上悬浮显示一个霓虹灯文本

    local colors = {}
    colors[0] = 0xFFff00cc
    colors[1] = 0xFFffcc00
    colors[2] = 0xFF00ffcc
    colors[3] = 0xFFff0066
    AlGuiWindowView.showNeonLightText(
        context,                   --上下文
        "ALGUI",                   --文本
        colors,                    --文本渐变色颜色数组
        15,                        --文本大小
        null,                      --文本字体 (null代表跟随系统字体)
        Gravity.END | Gravity.TOP, --位置 (这里显示在屏幕右上角)
        0, 0                       --xy位置偏移
    )
    --屏幕上悬浮显示一个普通文本
    AlGuiWindowView.showText(
        context,                      --上下文
        "ALGUI",                      --文本
        0xFFF44336,                   --文本颜色
        15,                           --文本大小
        null,                         --文本字体 (null代表跟随系统字体)
        Gravity.END | Gravity.BOTTOM, --位置 (这里显示在屏幕右下角)
        0, 0                          --xy位置偏移
    )
    --悬浮显示一个HTML窗口 {参数：上下文，窗口标题，HTML代码}
    -- AlGuiWindowView.showWebView(context, "视频", "<html><body><video width=\"100%\" height=\"auto\" controls><source src=\"" .."https://jkapi.com/api/xjj_video?type=&apiKey=842beb41464f175c1259220f8da6bd3a" .. "\" type=\"video/mp4\"></video></body></html>")
    --悬浮显示一个网站窗口 {参数：上下文，网站标题，网站链接}
    -- AlGuiWindowView.showWebSite(context, "官网", "https://gitee.com/ByteAL/ALGUI")



    --Inform [气泡通知组件🔧] ───────────────────────────────
    --作用：在屏幕右下角显示各种气泡通知
    --我们在Inform中封装了很多不同形式的气泡通知
    --例如：成功，错误，警告，消息 它们都包含了两种外观 并且它们都包含了带按钮的形式，而且他们拥有不同的提示音效
    --下面是Inform使用演示：
    --显示一个消息气泡通知 {💠简单的外观} 参数：图标(null代表默认) 标题 内容 显示时间(毫秒)(超过这段时间将自动消失)
    Inform.showMessageNotification_Simplicity(null, "完成", "服务器已完成加载", 5000)
    --显示一个消息气泡通知 {✨精美的外观} 参数：图标(null代表默认) 标题 内容 显示时间(毫秒)(超过这段时间将自动消失)
    Inform.showMessageNotification_Exquisite(null, "完成", "服务器已完成加载", 5000)
    --显示一个消息气泡通知 {简单的外观并且带按钮} 它将一直显示直到点击了按钮
    Inform.showMessageNotification_Simplicity_Button
    (
        null, --图标(null代表默认)
        "ALGUI通知", --标题(null代表无标题)
        "如果您需要帮助请进QQ交流群：730967224来联系我们", --内容(null代表无内容)
        "取消", --消极按钮文本 (null代表没有这个按钮)
        --这是消极按钮的点击事件 (null代表默认)
        AlGuiBubbleNotification.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 消极按钮点击后执行的内容
                    -- 这里写你想执行的 Lua 逻辑
                end
            }
        ),
        "确定", --积极按钮的文本 (null代表没有某个按钮)
        --这是积极按钮的点击事件 (null代表默认)
        AlGuiBubbleNotification.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 积极按钮点击后执行的内容
                    VariousTools.joinQQGroup(context, "qeey7hum96m64eaHkKKjHC6micNY9_oI") -- 加入QQ群聊
                end
            }
        )
    )
    --以上仅演示消息的气泡通知使用方式，其他如成功，错误，警告通知使用方式都一致，你只需更改方法名称即可
    --你也可以显示一个自定义的气泡通知，因为我们拥有自定义方法，自定义通知不自带提示音你需要自己播放提示音😋
    --显示一个自定义的气泡通知
    Inform.showCustomizeNotification
    (
        0xFF009688, --通知背景颜色
        null, 0, --通知图标(null代表默认)，图标颜色(0代表不设置颜色)
        "自定义通知", 0xFFFFFFFF, --通知标题，标题颜色
        "这是一个自定义通知", 0xFFBDBDBD, --通知内容，内容颜色
        5000 --显示时间(单位毫秒)(超过这段时间将自动消失气泡)
    )
    --显示一个自定义带按钮的气泡通知
    Inform.showCustomizeButtonNotification
    (
        0xFF009688, --通知背景颜色
        null, 0, --通知图标(null代表默认)，图标颜色(0代表不设置颜色)
        "自定义通知", 0xFFFFFFFF, --通知标题(null代表无标题)，标题颜色
        "这是一个自定义通知，带按钮", 0xFFBDBDBD, --通知内容(null代表无内容)，内容颜色
        --消极按钮文本(null代表隐藏这个按钮)，消极按钮文本颜色，消极按钮背景颜色，消极按钮描边颜色(0代表不描边)
        "取消", 0xFF009688, 0xFFFFFFFF, 0,
        --这是消极按钮的点击事件 (null代表默认)
        AlGuiBubbleNotification.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 消极按钮点击后执行的内容
                    -- 这里写你想实现的逻辑，比如打印日志或其它操作
                end
            }
        ),
        --积极按钮文本(null代表隐藏这个按钮)，积极按钮文本颜色，积极按钮背景颜色，积极按钮描边颜色(0代表不描边)
        "确定", 0xFF009688, 0xFFFFFFFF, 0,
        --这是积极按钮的点击事件 (null代表默认)
        AlGuiBubbleNotification.T_ButtonOnChangeListener(
            {
                onClick = function(button, back, buttonText, isChecked)
                    -- 积极按钮点击后执行的内容
                    -- 在这里写你的 Lua 代码逻辑
                end
            }
        )

    )

    --AlGuiSoundEffect.getAudio(context) (提示音组件🔧️)
    --作用：播放各种ALGUI提示音效
    --播放音效 参数：传入AlGuiSoundEffect中内置的提示音
    --例如这是播放(消息)提示音效
    AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_MESSAGE_GTA)
    --例如这是播放(完成)提示音效
    AlGuiSoundEffect.getAudio(context).playSoundEffect(AlGuiSoundEffect.INFORM_SUCCESS)
    --等等… 内置提示音都包含在了AlGuiSoundEffect中 自行使用即可
end

Lock.Ui(function()
    if AlGui.algui then
        AlGui.algui.clearBall()
        AlGui.algui.clearMenu()
        -- 清除所有浮窗
        AlGuiWindowView.clearAllViews(context);
        gui = AlGui.newGUI(context)
    else
        gui = AlGui.GUI(context)
    end
    if AlGuiBubbleNotification.bn then
        Inform = AlGuiBubbleNotification.newInform(context)
    else
        Inform = AlGuiBubbleNotification.Inform(context)
    end
    -- 主线程无法创建UI线程
    Inform.showMessageNotification_Exquisite(null, "欢迎使用Algui", "如果你遇到了问题请加入QQ群聊123", 5000)
    initConfigurations()
    initMenu()
    -- 清除所有浮窗

    gui.showBall() --ALGUI加载完成后 调用showBall方法来显示悬浮球
    -- gui.showMenu()--你也可以选择调用showMenu方法来先显示悬浮菜单
end, nil, function(err)
    -- 清除所有浮窗
    AlGuiWindowView.clearAllViews(context);
    print(err)
    luajava.exit()
end)
