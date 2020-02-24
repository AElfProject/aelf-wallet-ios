# !/bin/bash

#   ••••• 注意事项 ••••••
#   用途：编译打包生成企业版 ipa ，并上传 fir.im
#   使用示例： sh exportIPA.sh "更新描述" "staging" "1" "0"
#   脚本后面跟的第一个参数为更新描述;
#             第二个参数为环境，支持 "test"、"staging"、"prod";
#             第三个参数为打包类型：1 App Store包，2 企业包;
#             第四个参数为是否开启 push 钉钉通知，= 1 开启;
#   2019.8.9

start_time="$(date +%s)"

hp_root_path="$HOME/Documents/AElfIpa"

current_time=$(date +%Y-%m-%d_%H-%M-%S)

platform="iOS"

#导出.ipa文件所在路径
export_ipa_path="${hp_root_path}/ipa/${current_time}"

if [ ! -d ${export_ipa_path} ]; then
    mkdir -p ${export_ipa_path}
fi

update_desc="$1"
pram_env="$2"
num_type=$3
enable_push="$4"

desc_env="测试环境"
num_env="1"
if [ "$pram_env" == "test" ]; then
    desc_env="测试环境"
    num_env="1"
elif [ "$pram_env" == "staging" ]; then
    desc_env="预发布环境"
    num_env="2"
elif [ "$pram_env" == "prod" ]; then
    desc_env="正式环境"
    num_env="3"
else
    echo "环境参数错误：${pram_env}，请参考脚本内使用说明。"
    exit 1
fi

cd .. # 返回上级目根目录。

#工程绝对路径
project_path=$(
    cd $(dirname $0)
    pwd
)

#工程名 将XXX替换成自己的工程名
project_name="AElfApp"

#scheme名 将XXX替换成自己的sheme名
scheme_name="AElfApp"

#打包模式 Debug/Release
development_mode=Release

InfoPlist="${project_path}/${project_name}/Resources/Info.plist"

# bundleId=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "${InfoPlist}")
#取build值
bundle_version=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${InfoPlist}")
#取APP名称
display_name=$(/usr/libexec/PlistBuddy -c "print CFBundleName" "${InfoPlist}")

desc_type=""
if [ "$num_type" == "1" ]; then # App Store包
    desc_type="Store 包"
    if [ "$num_env" == "1" ]; then # 测试包
        sed -i '' 's/let appEnv =.*/let appEnv = 2/g' $scheme_name/Resources/Enviroment.swift
        exportOptionsPlistPath=${project_path}/Script/env_test.plist
    elif [ "$num_env" == "2" ]; then # 预发布包
        sed -i '' 's/let appEnv =.*/let appEnv = 3/g' $scheme_name/Resources/Enviroment.swift
        exportOptionsPlistPath=${project_path}/Script/env_test.plist
    else # 正式包
        sed -i '' 's/let appEnv =.*/let appEnv = 4/g' $scheme_name/Resources/Enviroment.swift
        exportOptionsPlistPath=${project_path}/Script/env_test.plist
    fi

else
    desc_type="企业包" # 打企业包需要修改本脚本
    sed -i '' 's/let appEnv =.*/let appEnv = 2/g' $scheme_name/Resources/Enviroment.swift
    exportOptionsPlistPath=${project_path}/Script/exportOptions.plist
fi

desc_push=""
if [ "$enable_push" == "1" ]; then
    desc_push="开启"
else
    desc_push="关闭"
fi

echo "------ 【环境：${desc_env}   模式：${development_mode}  类型：${desc_type}  钉钉通知：${desc_push}】------"
echo "---------------- 开始清理工程 ----------------"

xcodebuild \
    clean -configuration ${development_mode} -quiet || exit

if [ "$?" == "0" ]; then
    echo "---------------- 清理完成 ----------------"
else
    echo "---------------- 清理失败，请检查日志。$0 ----------------"
fi

echo "---------------- 开始编译 ${scheme_name}: ${development_mode} ----------------"

archive_path="${export_ipa_path}/${project_name}.xcarchive"
if [ ! -d ${archive_path} ]; then
    mkdir -p ${archive_path}
fi

xcodebuild archive -workspace "${project_path}/${project_name}.xcworkspace" \
    -scheme "${scheme_name}" \
    -archivePath "$archive_path" \
    -configuration "${development_mode}"

if [ "$?" == "0" ]; then
    echo "---------------- 编译成功 ----------------"
else
    echo "---------------- 编译失败，请检查日志。$0 ----------------"
fi

echo "---------------- 开始打包 ----------------"

xcodebuild -exportArchive -archivePath "$archive_path" \
    -exportPath "${export_ipa_path}" \
    -exportOptionsPlist "${exportOptionsPlistPath}"

if [ "$?" == "0" ]; then
    echo "---------------- 打包成功 ----------------"
else
    echo "---------------- 打包失败，请检查日志。$0 ----------------"
fi

ipa_file="$export_ipa_path/$scheme_name.ipa"
if [ -f "$ipa_file" ]; then
    echo "---------------- 包已导出: ${ipa_file} ----------------"
    open $export_ipa_path
else
    echo "---------------- 导出失败: ${ipa_file}，请检查日志。$0 ----------------"
    exit 1
fi

sendDingDing() {

    token="0c35cb2d1436cf30dbc3ee28a4f493cb4915321ec99ab62b2f5b73876fd0357c"
    # token="2a8489df4af392926338aac3a2ab477e2a151eaec7b9006707e8ea24e4f4c094" # test go
    url="https://oapi.dingtalk.com/robot/send?access_token=${token}"
    result=$(curl -XPOST -s -L -H "Content-Type:application/json" -H "charset:utf-8" $url -d "
{
\"msgtype\": \"actionCard\",
"actionCard": {
\"title\": \"$1\",
\"text\": \"# $1 \n\n $2\",
\"hideAvatar\": \"0\"
}
}")

}

#上传到Fir
echo "---------------- 开始上传 ----------------"

if [ ! "$update_desc" ]; then
    update_desc="bug fixed."
fi


end_time="$(date +%s)"
total_seconds="$((end_time - start_time))s"

fir -v
fir login -T "bb90ee0e23566463f9574b4db024824e"
fir publish "${ipa_file}" -c "${update_desc}"
if [ "$?" == "0" ]; then
    echo "---------------- 上传 Fir.im 成功 ----------------"

    pub_time=$(date +%Y年%m月%d日%H时%M分%S秒)
    result="当前平台：${platform}\n\n当前版本：${bundle_version}\n\n打包耗时：${total_seconds}\n\n发布环境：${desc_env}\n\n更新描述：${update_desc}\n\n发布时间：${pub_time}"
    echo "$result"
    if [ "$enable_push" == "1" ]; then
        sendDingDing "${display_name}" "${result}"
    fi

else
    echo "---------------- 上传 Fir.im 失败，请检查日志。$? ----------------"
fi

echo -e "\033[33m---------------- RN 脚本执行完毕,耗时：${total_seconds} ---------------- \033[0m"

# https://www.cnblogs.com/zndxall/p/9692703.html
