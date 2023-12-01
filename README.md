# QianlueDev

脚本介绍

【openwrt_build.sh】从原网安装 openwrt（不是从个人源安装）。

经测试，在 Ubuntu16上直接 clone 它的 `23.05` 分支不能编译，提示要求 gcc `v6` 以上，python `v3.6` 以上。

> 公司板子配置
>
> - Arch: MIPS
>
> - CPU: MediaTek MT7621AT
> - DRAM: 128 M

## 脚本写法 Tips

- 想把函数输出给变量，尽量不用 return $ 这种写法, 他返回的值只能是 0-255 的整数（实质是状态码），在最后一行打 echo 更好。

- TODO
